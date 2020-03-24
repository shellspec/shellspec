#shellcheck shell=sh disable=SC2004

: "${count_specfiles:-} ${count_examples:-} ${done:-}"

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use import reset_params constants sequence replace each padding trim
use difference_values union_values match is_empty_file pluralize

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
  replace description "$VT" " "
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
        '?'  ) [ \"\$$1_buffer\" ] ;; \
        '!?' ) [ ! \"\$$1_buffer\" ] ;; \
        '='  ) $1_opened=1; shift; $1_buffer=\${*:-} ;; \
        '|=' ) $1_opened=1; shift; [ \"\$$1_buffer\" ] || $1_buffer=\${*:-} ;; \
        '+=' ) $1_opened=1; shift; $1_buffer=\$$1_buffer\${*:-} ;; \
        '<|>') $1_opened=1 ;; \
        '>|<') [ \"\$$1_flowed\" ] && $1_buffer='' $1_flowed=''; $1_opened='' ;; \
        '>>>') [ ! \"\$$1_opened\" ] || { $1_flowed=1; puts \"\$$1_buffer\"; } ;; \
      esac; \
      set -- \$?; \
      IFS=\${IFS#?}; \
      return \$1; \
    } \
  "
  eval "$EVAL"
}

xmlescape() {
  [ $# -gt 1 ] && eval "$1=\$2"
  replace "$1" '&' '&amp;'
  replace "$1" '<' '&lt;'
  replace "$1" '>' '&gt;'
  replace "$1" '"' '&quot;'
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
  quick_count=0
}

pass_quick_data() {
  i=$quick_count
  while [ "$i" -gt 0 ]; do
    eval "[ \"\${quick_$i:-}\" = \"\$1\" ] &&:" && break
    i=$(($i-1))
  done
  if [ "$i" -eq 0 ]; then
    quick_count=$(($quick_count+1)) && i=$quick_count
    set -- "$1" "$2" "${3:-}" "quick_$i"
    eval "$4=\"\$1\" $4_fail='' $4_pass=''"
  else
    set -- "$1" "$2" "${3:-}" "quick_$i"
  fi
  if [ "$3" ]; then
    eval "$4_fail=\"\$$4_fail\${$4_fail:+:}@\$2\""
  else
    eval "$4_pass=\"\$$4_pass\${$4_pass:+:}@\$2\""
  fi
}

find_quick_data() {
  i=1
  while [ "$i" -le "$quick_count" ]; do
    set -- "$1" "$2" "quick_$i"
    eval "set -- \"\$@\" \"\${$3:-}\" \"\${$3_pass:-}\" \"\${$3_fail:-}\""
    [ "$2" != "$4" ] && i=$(($i+1)) && continue
    "$1" "$4" "$5" "$6"
    break
  done
}

remove_quick_data() {
  i=1
  while [ "$i" -le "$quick_count" ]; do
    set -- "$1" "quick_$i"
    eval "set -- \"\$@\" \"\${$2:-}\""
    [ "$1" != "$3" ] && i=$(($i+1)) && continue
    unset "$2" "$2_pass" "$2_fail" ||:
    break
  done
}

list_quick_data() {
  i=1
  while [ "$i" -le "$quick_count" ]; do
    set -- "$1" "quick_$i"
    eval "set -- \"\$@\" \"\${$2:-}\" \"\${$2_pass:-}\" \"\${$2_fail:-}\""
    [ "$3" ] && "$1" "$3" "$4" "$5"
    i=$(($i+1))
  done
}

filter_quick_file() {
  line='' specfile='' ids='' done="$1" && shift
  callback() { if [ "$3" ]; then putsn "$1:$3"; fi; }
  while read_quickfile line specfile ids; do
    [ -e "$specfile" ] || continue
    pattern=''
    match_files_pattern pattern "$@"
    [ "$done" ] && match "$specfile" "$pattern" && ids=''
    filter_ids() {
      difference_values ids ":" "$2" # Remove succeeded examples
      union_values ids ":" "$3" # Add failed examples
    }
    find_quick_data filter_ids "$specfile"
    remove_quick_data "$specfile"
    callback "$specfile" "" "$ids"
  done
  list_quick_data callback
}
