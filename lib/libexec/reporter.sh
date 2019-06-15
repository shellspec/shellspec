#shellcheck shell=sh

: "${count_specfiles:-} ${count_examples:-}"

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use import reset_params constants sequence replace each padding

count() {
  count_specfiles=0 count_examples=0
  #shellcheck shell=sh disable=SC2046
  set -- $($SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-list.sh" "$@")
  count_specfiles=$1 count_examples=$2
}

# $1: prefix, $2: filename
read_time_log() {
  [ -r "$2" ] || return 0
  # shellcheck disable=SC2034
  while IFS=" " read -r time_log_name time_log_value; do
    case $time_log_name in (real|user|sys) ;; (*) continue; esac
    case $time_log_value in (*[!0-9.]*) continue; esac
    eval "$1_${time_log_name}=\"\$time_log_value\""
  done < "$2"
}

field_description() {
  description=${field_description:-}
  replace description "$VT" " "
  putsn "$description"
}

# This is magical buffer. You can output same thing again and again until close.
#   [?] is present?   [!?] is empty?
#   [=] open and set  [|=] open and set if empty  [+=] open and append
#   [>>>] output      [<|>] open                  [>|<] close
buffer() {
  eval "
    $1_buffer='' $1_opened='' $1_flowed=''
    $1() {
      IFS=\" \$IFS\"
      case \${1:-} in
        '?'  ) [ \"\$$1_buffer\" ] ;;
        '!?' ) [ ! \"\$$1_buffer\" ] ;;
        '='  ) $1_opened=1; shift; $1_buffer=\${*:-} ;;
        '|=' ) $1_opened=1; shift; [ \"\$$1_buffer\" ] || $1_buffer=\${*:-} ;;
        '+=' ) $1_opened=1; shift; $1_buffer=\$$1_buffer\${*:-} ;;
        '<|>') $1_opened=1 ;;
        '>|<') [ \"\$$1_flowed\" ] && $1_buffer='' $1_flowed=''; $1_opened='' ;;
        '>>>') [ ! \"\$$1_opened\" ] || { $1_flowed=1; puts \"\$$1_buffer\"; } ;;
      esac
      set -- \$?
      IFS=\${IFS#?}
      return \$1
    }
  "
}

xmlescape() {
  [ $# -gt 1 ] && eval "$1=\$2"
  replace "$1" '&' '&amp;'
  replace "$1" '<' '&lt;'
  replace "$1" '>' '&gt;'
  replace "$1" '"' '&quot;'
}

xmlattrs() {
  eval "
    $1=''
    shift
    while [ \$# -gt 0 ]; do
      xmlescape xmlattrs \"\${1#*\=}\"
      $1=\"\${$1}\${$1:+ }\${1%%\=*}=\\\"\$xmlattrs\\\"\"
      shift
    done
  "
}

remove_escape_sequence() {
  while IFS= read -r line || [ "$line" ]; do
    text=''
    until case $line in (*$ESC*) false; esac; do
      text="${text}${line%%$ESC*}"
      line=${line#*$ESC}
      line=${line#*m} # only support SGR
    done
    putsn "${text}${line}"
  done
}
