#!/bin/sh
#shellcheck disable=SC2004

set -eu

# shellcheck source=lib/libexec/list.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/list.sh"
# shellcheck source=lib/libexec/translator.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/translator.sh"

trans() {
  # shellcheck disable=SC2145
  case $1 in (block_example_group|block_example|block_end)
    "trans_$@"
  esac
}

trans_block_example_group() {
  putsn "block${block_no}() { "
  putsn "FILTER=\${FILTER}${filter:-0}" "ENABLED=\${ENABLED}${enabled:-0}"
}

trans_block_example() {
  putsn "block${block_no}() { "
  putsn "LINENO_BEGIN=$lineno_begin" "EXAMPLE_ID=$block_id"
  putsn "FILTER=\${FILTER}${filter:-0}" "ENABLED=\${ENABLED}${enabled:-0}"
  putsn "yield ${parameter_count:-1}"
}

trans_block_end() {
  putsn "FILTER=\${FILTER%?}" "ENABLED=\${ENABLED%?}"
  putsn "}"
  putsn "FILTER=\${FILTER}${filter:-0}" "ENABLED=\${ENABLED}${enabled:-0}"
  putsn "block${block_no}"
  putsn "FILTER=\${FILTER%?}" "ENABLED=\${ENABLED%?}"
}

yield() {
  case $ENABLED in (*1*) case $FILTER in (*1*) disp "$1"; esac; esac
}

syntax_error() {
  set -- "Syntax error: $1 in $specfile line $lineno" "${2:-}"
  putsn "abort \"$1\" \"$2\""
}

prepare() {
  specfile=$3 ranges=${4:-} filter=1
  [ "$SHELLSPEC_FOCUS_FILTER" ] && filter=''
  [ "$SHELLSPEC_TAG_FILTER" ] && filter=''
  [ "$SHELLSPEC_EXAMPLE_FILTER" ] && filter=''
  [ "$ranges" ] && enabled='' || enabled=1
  SPECFILE=$specfile
  ENABLED=$enabled
  FILTER=$filter
}

list_code() {
  specfiles=$(($specfiles + 1))
  prepare "$@"
  "$1" "$(initialize; translate < "$3"; finalize)"
}

specfiles=0 examples='' SHELLSPEC_LIST=${SHELLSPEC_LIST:-}
case ${SHELLSPEC_LIST%:*} in
  debug)
    specfile() { list_code putsn "$@"; }; ;;
  specfiles)
    specfile() { putsn "$2"; }; ;;
  examples | '')
    specfile() { list_code eval "$@"; }
    example() { examples=$(($examples + $1)); }
    # shellcheck disable=SC2153
    case ${SHELLSPEC_LIST#examples:} in
      id      ) disp() { example "$1"; putsn "$SPECFILE:@$EXAMPLE_ID"; }; ;;
      examples) disp() { example "$1"; putsn "$SPECFILE:@$EXAMPLE_ID"; }; ;;
      lineno)   disp() { example "$1"; putsn "$SPECFILE:$LINENO_BEGIN"; }; ;;
      '')       disp() { example "$1"; }; ;;
    esac
esac

if [ "${SHELLSPEC_RANDOM:-}" ]; then
  eval find_specfiles specfile ${1+'"$@"'} | shuffle "${SHELLSPEC_SEED:-}"
else
  eval find_specfiles specfile ${1+'"$@"'}
fi

[ "$SHELLSPEC_LIST" ] || echo "$specfiles ${examples:-0}"

if [ "${SHELLSPEC_COUNT_FILE:-}" ]; then
  echo "$specfiles${examples:+ }$examples" > "$SHELLSPEC_COUNT_FILE"
fi
