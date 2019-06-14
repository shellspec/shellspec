#shellcheck shell=sh

formatters='' generators='' buffers=''

load_formatter() {
  # move main formatter of first argument to last
  set -- "$@" "$1"
  shift

  while [ $# -gt 1 ]; do
    import_generator "$1"
    shift
  done

  import_formatter "$1"

  # move main formatter to first
  #shellcheck disable=SC2086
  set -- "$1" ${formatters%$1*} ${formatters#*$1}
  formatters="$*"
}

require_formatters() {
  while [ $# -gt 0 ]; do
    import_formatter "$1"
    shift
  done
}

import_formatter() {
  case " $formatters " in (*\ $1\ *) return 0; esac
  formatters="$formatters${formatters:+ }$1"
  eval "
    ${1}_initialize() { :; }; ${1}_finalize() { :; }
    ${1}_begin() { :; }; ${1}_each() { :; }; ${1}_end() { :; }
    ${1}_output() { :; }
  "
  import "${1}_formatter"
}

import_generator() {
  case " $generators " in (*\ $1\ *) return 0; esac
  generators="${generators}${generators:+ }$1"
  eval "
    ${1}_output='results.${1}'
    ${1}_prepare() {
      : > \"\$SHELLSPEC_TMPBASE/\$${1}_output\"
    }
    ${1}_generate() {
      \"${1}_output\" \"\$@\" >> \"\$SHELLSPEC_TMPBASE/\$${1}_output\"
    }
    ${1}_cleanup() {
      remove_escape_sequence < \"\$SHELLSPEC_TMPBASE/\$${1}_output\" \
        > \"\$SHELLSPEC_REPORTDIR/\$${1}_output\"
    }
  "
  import_formatter "$1"
}

formatters() {
  #shellcheck disable=SC2145
  for f in $formatters; do "${f}_$@"; done
}

generators() {
  #shellcheck disable=SC2145
  for g in $generators; do "${g}_$@"; done
}

output_formatters() {
  formatters "$@"
  "${formatters%% *}_output" "$1"
  generators generate "$1"
  close_buffers
}

output() {
  eval "shift; while [ \$# -gt 0 ]; do \"\$1_output\" \"$1\"; shift; done"
}

create_buffers() {
  while [ $# -gt 0 ]; do
    buffer "$1"
    buffers="${buffers}${buffers:+ }$1"
    shift
  done
}

close_buffers() {
  #shellcheck disable=SC2086
  set -- $buffers
  while [ $# -gt 0 ]; do
    "$1" '>|<'
    shift
  done
}

generate_file() {
  remove_escape_sequence >> "$1"
}
