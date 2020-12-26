#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use import constants sequence replace_all each padding trim wrap
use is_empty_file pluralize exists_file readfile

notice() { warn "$@" 2>&1; }

count_examples() {
  set -- "$SHELLSPEC_LIBEXEC/shellspec-list.sh" "$@"
  #shellcheck shell=sh disable=SC2046
  set -- "$2" "$(script=$1; shift 2; $SHELLSPEC_SHELL "$script" "$@")"
  eval "$1=\${2#* }"
}

# $1: prefix, $2: filename
read_time_log() {
  eval "$1_real='' $1_user='' $1_sys=''"
  [ -r "$2" ] || return 1
  # shellcheck disable=SC2034
  while IFS= read -r line; do
    case $line in (real[\ $TAB]*|user[\ $TAB]*|sys[\ $TAB]*)
      case ${line##*[ $TAB]} in (*[!0-9.]*) continue; esac
      eval "$1_${line%%[ $TAB]*}=\"\${line##*[ \$TAB]}\""
    esac
  done < "$2" &&:
  eval "[ \"\$$1_real\" ] && [ \"\$$1_user\" ] && [ \"\$$1_sys\" ]"
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
      IFS=\" \$IFS\"; \
      case \${1:-} in \
        '?'  ) [ \"\$$1_buffer\" ] &&: ;; \
        '!?' ) [ ! \"\$$1_buffer\" ] &&: ;; \
        '='  ) $1_opened=1; shift; $1_buffer=\${*:-} ;; \
        '|=' ) $1_opened=1; shift; [ \"\$$1_buffer\" ] || $1_buffer=\${*:-} ;; \
        '+=' ) $1_opened=1; shift; $1_buffer=\$$1_buffer\${*:-} ;; \
        '<|>') $1_opened=1 ;; \
        '>|<') [ \"\$$1_flowed\" ] && $1_buffer='' $1_flowed=''; $1_opened='' ;; \
        '>>>') [ ! \"\$$1_opened\" ] || { $1_flowed=1; puts \"\$$1_buffer\"; } ;; \
      esac &&:; \
      set -- \$?; \
      IFS=\${IFS#?}; \
      return \$1; \
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

xmlcdata() {
  eval "$1=\$2"
  if [ "$2" ]; then
    replace_all "$1" ']]>' ']]]]><![CDATA[>'
    eval "$1=\"<![CDATA[\${$1}]]>\""
  fi
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

output_trace() {
  # shellcheck disable=SC2154
  while IFS= read -r output_trace; do
    case $output_trace in (*@SHELLSPEC_XTRACE_OFF@*) break; esac
    putsn "$output_trace"
  done
}

base() {
  base_ "$1" "$2" $(($# - 2))
  eval "eval $1=\${$1}"
}
base_() {
  set -- "$1" "$2" "$3" ""
  while [ "$2" -ne 0 ]; do
    set -- "$1" $(($2 / $3)) "$3" "\${$(($2 % $3 + 2))}$4"
  done
  eval "$1=\${4}"
}

base26() {
  base "$1" "$2" a b c d e f g h i j k l m n o p q r s t u v w x y z
}

tssv_parse() {
  set -- "$1" "$2" "$US"
  tssv_buf=''
  while IFS= read -r tssv_line || [ "$tssv_line" ]; do
    case $tssv_line in
      $RS*)
        if [ "$tssv_buf" ]; then
          tssv_fields "$@" "$tssv_buf" || return $?
        fi
        tssv_buf=${tssv_line#?}
        ;;
      *) tssv_buf="$tssv_buf${tssv_buf:+$LF}${tssv_line}"
    esac
  done
  [ ! "$tssv_buf" ] || tssv_fields "$@" "$tssv_buf"
}

tssv_fields() {
  tssv_prefix=$1 tssv_callback=$2
  tssv_oldifs=$IFS && IFS=$3 && eval "set -- \$4" && IFS=$tssv_oldifs

  for tssv_field; do
    eval "${tssv_prefix}_${tssv_field%%:*}=\${tssv_field#*:}"
    set -- "$@" "${tssv_field%%:*}"
    shift
  done

  "$tssv_callback" "$@"
}
