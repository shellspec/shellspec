#shellcheck shell=sh disable=SC2004

: "${count_specfiles:-} ${count_examples:-}"

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use each replace padding

formatters='' generators=''

load_formatter() {
  formatters=$1
  import_formatter "$1"
}

require_formatters() {
  while [ $# -gt 0 ]; do
    case " $formatters " in (*\ $1\ *) ;; (*)
      formatters="${formatters}${formatters:+ }$1"
      import_formatter "$1"
    esac
    shift
  done
}

import_formatter() {
  eval "
    ${1}_initialize() { :; }; ${1}_finalize() { :; }
    ${1}_begin() { :; }; ${1}_each() { :; }; ${1}_end() { :; }
    ${1}_output() { :; }
  "
  import "${1}_formatter"
}

load_generators() {
  while [ $# -gt 0 ]; do
    case " $formatters $generators " in (*\ $1\ *) ;; (*)
      generators="${generators}${generators:+ }$1"
      eval "
        ${1}_output='report.${1}'
        ${1}_prepare() {
          case \$${1}_output in (*[a-z]* | *[A-Z]* | *[0-9]*)
            : > \"\$${1}_output\"
          esac
        }
        ${1}_generate() {
          case \$${1}_output in (*[a-z]* | *[A-Z]* | *[0-9]*)
            \"${1}_output\" \"\$@\" | generate_file \"\$${1}_output\"
          esac
        }
        ${1}_cleanup() { :; }
      "
      import_formatter "$1"
    esac
    shift
  done
}

generate_file() {
  remove_escape_sequence >> "$1"
}

formatters() {
  #shellcheck shell=sh disable=SC2145
  for f in $formatters $generators; do "${f}_$@"; done
}

generators() {
  #shellcheck shell=sh disable=SC2145
  for g in $generators; do "${g}_$@"; done
}

output_formatters() {
  formatters "$@"
  "${formatters%% *}_output" "$1"
  generators generate "$1"
}

output_formatter() {
  eval "shift; while [ \$# -gt 0 ]; do \"\$1_output\" \"$1\"; shift; done"
}

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
  while read -r time_log_name time_log_value; do
    case $time_log_name in (real|user|sys) ;; (*) continue; esac
    case $time_log_value in (*[!0-9.]*) continue; esac
    eval "$1_${time_log_name}=\"\$time_log_value\""
  done < "$2"
}

buffer() {
  eval "
    $1_buffer=''
    $1() {
      case \${1:-} in
        ''   ) [ \"\$$1_buffer\" ] ;;
        '='  ) shift; $1_buffer=\${*:-} ;;
        '||=') shift; $1 || $1 += \"\$@\" ;;
        '+=' ) shift; $1_buffer=\$$1_buffer\${*:-} ;;
        '>>' ) shift; puts \"\$$1_buffer\" ;;
      esac
    }
  "
}

field_description() {
  description=${field_description:-}
  replace description "$VT" " "
  putsn "$description"
}

remove_escape_sequence() {
  text=''
  while IFS= read -r line; do
    until case $line in (*$ESC*) false; esac; do
      text="${text}${line%%$ESC*}"
      line=${line#*$ESC}
      line=${line#*m} # only supported SGR
    done
    text="${text}${line}${LF}"
  done
  puts "$text"
}
