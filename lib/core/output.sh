#shellcheck shell=sh disable=SC2016

shellspec_output() {
  # shellcheck disable=SC2145
  "shellspec_output_$@"
}

shellspec_output_raw() {
  [ $# -gt 0 ] || return 0
  for shellspec_output_raw in "$@"; do
    case ${shellspec_output_raw%%:*} in
      message | description | evaluation | failure_message)
        shellspec_output_raw_sanitize "$shellspec_output_raw" ;;
      # shell | shell_type | shell_version | info | type) ;;
      # specfile | example_count | stdout | stderr) ;;
      # id | block_no | example_no | focused | lineno_range) ;;
      # tag | lineno | note | fail | quick | temporary | skipid) ;;
      # *) echo "Unknown reporter tag name: $shellspec_output_raw" >&2; exit 1
    esac
    set -- "$@" "$shellspec_output_raw"
    shift
  done
  IFS="${SHELLSPEC_US}${IFS}"
  shellspec_putsn "${SHELLSPEC_RS}$*${SHELLSPEC_ETB}"
  IFS=${IFS#?}
}
shellspec_output_raw_sanitize() {
  set -- "$1" "$IFS" "$-"
  set -f -u # -u: Workaround for posh 0.10.2. nounset has the effect of noglob.
  IFS="${SHELLSPEC_RS}${SHELLSPEC_US}${SHELLSPEC_ETB}"
  eval "shellspec_output_raw_sanitize_ \$${ZSH_VERSION:+=}1"
  IFS=$2
  [ "${3#*f}" != "$3" ] || set +f
  [ "${3#*u}" != "$3" ] || set +u
}
shellspec_output_raw_sanitize_() {
  IFS='?'
  shellspec_output_raw="$*"
}

shellspec_output_meta() {
  eval shellspec_output_raw type:meta ${1:+'"$@"'}
}

shellspec_output_error() {
  eval shellspec_output_raw type:error ${1:+'"$@"'}
}

shellspec_output_finished() {
  eval shellspec_output_raw type:finished ${1:+'"$@"'}
}

shellspec_output_begin() {
  eval shellspec_output_raw type:begin ${1:+'"$@"'}
}

shellspec_output_end() {
  eval shellspec_output_raw type:end ${1:+'"$@"'}
}

shellspec_output_example() {
  eval shellspec_output_raw type:example ${1:+'"$@"'} \
    "lineno_range:${SHELLSPEC_LINENO_BEGIN}-${SHELLSPEC_LINENO_END}"
}

shellspec_output_statement() {
  eval shellspec_output_raw type:statement ${1:+'"$@"'} \
    "lineno:${SHELLSPEC_LINENO:-$SHELLSPEC_LINENO_BEGIN}"
}

shellspec_output_result() {
  [ "$SHELLSPEC_XTRACE" ] && set -- "$@" "trace:$SHELLSPEC_XTRACE_FILE"
  shellspec_output_raw type:result "$@"
}

shellspec_output_if() {
  shellspec_if "$1" || return 1
  shellspec_output "$@"
}

shellspec_output_unless() {
  shellspec_unless "$1" || return 1
  shellspec_output "$@"
}
