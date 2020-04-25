#shellcheck shell=sh disable=SC2004

: "${count_specfiles:-} ${count_examples:-} ${done:-}"

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use import constants sequence replace_all each padding trim
use is_empty_file pluralize exists_file

count() {
  count_specfiles=0 count_examples=0
  IFS=" $IFS"
  #shellcheck shell=sh disable=SC2046
  set -- $($SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-list.sh" "$@")
  IFS=${IFS#?}
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
  done < "$2" &&:
}

field_description() {
  description=${field_description:-}
  replace_all description "$VT" " "
  putsn "$description"
}

# This is magical buffer. You can output same thing again and again until close.
#   [?] is present?   [!?] is empty?
#   [=] open and set  [|=] open and set if empty  [+=] open and append
#   [>>>] output      [<|>] open                  [>|<] close
buffer() {
  EVAL="
    $1_buffer='' $1_opened='' $1_flowed=''; \
    $1() { \
      case \${1:-} in \
        '?'  ) [ \"\$$1_buffer\" ] &&:; return \$? ;; \
        '!?' ) [ ! \"\$$1_buffer\" ] &&:; return \$? ;; \
      esac; \
      IFS=\" \$IFS\"; \
      case \${1:-} in \
        '='  ) $1_opened=1; shift; $1_buffer=\${*:-} ;; \
        '|=' ) $1_opened=1; shift; [ \"\$$1_buffer\" ] || $1_buffer=\${*:-} ;; \
        '+=' ) $1_opened=1; shift; $1_buffer=\$$1_buffer\${*:-} ;; \
        '<|>') $1_opened=1 ;; \
        '>|<') [ \"\$$1_flowed\" ] && $1_buffer='' $1_flowed=''; $1_opened='' ;; \
        '>>>') [ ! \"\$$1_opened\" ] || { $1_flowed=1; puts \"\$$1_buffer\"; } ;; \
      esac; \
      IFS=\${IFS#?}; \
    } \
  "
  eval "$EVAL"
}

xmlescape() {
  [ $# -gt 1 ] && eval "$1=\$2"
  replace_all "$1" '&' '&amp;'
  replace_all "$1" '<' '&lt;'
  replace_all "$1" '>' '&gt;'
  replace_all "$1" '"' '&quot;'
}

xmlattrs() {
  EVAL="
    $1=''; shift; \
    while [ \$# -gt 0 ]; do \
      xmlescape xmlattrs \"\${1#*\=}\"; \
      $1=\"\${$1}\${$1:+ }\${1%%\=*}=\\\"\$xmlattrs\\\"\"; \
      shift; \
    done \
  "
  eval "$EVAL"
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

inc() {
  while [ $# -gt 0 ]; do
    eval "$1=\$((\${$1} + 1))"
    shift
  done
}

read_profiler() {
  time_real_nano=0
  shellspec_shift10 time_real_nano "$3" 4

  profiler_count=0
  while IFS=" " read -r tick; do
    duration=$(($time_real_nano * $tick / $2))
    shellspec_shift10 duration "$duration" -4
    set -- "$1" "$2" "$3" "$profiler_count" "$tick" "$duration"
    eval "profiler_tick$4=\$5 profiler_time$4=\$6"
    "$@"
    profiler_count=$(($profiler_count + 1))
  done &&:
}

init_quick_data() {
  # quick_count=0
  quick_data='' executed_ids=''
}

add_quick_data() {
  [ "${3:-}" ] && quick_data="${quick_data}${quick_data:+$LF}$1:$2"
  exists_executed_ids "$1" && return 0
  executed_ids="${executed_ids}${executed_ids:+$LF}$1"
}

exists_quick_data() {
  case "${LF}${quick_data}" in (*${LF}$1:*) ;; (*) false; esac
}

exists_executed_ids() {
  case "${LF}${executed_ids}${LF}" in (*${LF}$1${LF}*) ;; (*) false; esac
}

# This is very complicated, So do not simplify with shortcut op to see coverage
filter_quick_file() {
  line='' state='' done="$1" && shift
  while read_quickfile line state; do
    if ! exists_file "${line%:*}"; then
      continue
    fi
    if exists_quick_data "$line"; then
      continue
    fi
    if exists_executed_ids "$line"; then
      continue
    fi
    if [ ! "$done" ]; then
      putsn "$line:$state"
      continue
    fi
    if match_quick_data "$line" "$@"; then
      continue
    fi
    putsn "$line:$state"
  done
  putsn "$quick_data"
}
