#!/bin/sh
#shellcheck disable=SC2004

set -eu

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
  putsn "LINENO_BEGIN=$lineno_begin" "EXAMPLE_ID=$example_id"
  putsn "FILTER=\${FILTER}${filter:-0}" "ENABLED=\${ENABLED}${enabled:-0}"
  putsn "yield"
}

trans_block_end() {
  putsn "FILTER=\${FILTER%?}" "ENABLED=\${ENABLED%?}"
  putsn "}"
  putsn "FILTER=\${FILTER}${filter:-0}" "ENABLED=\${ENABLED}${enabled:-0}"
  putsn "block${block_no}"
  putsn "FILTER=\${FILTER%?}" "ENABLED=\${ENABLED%?}"
}

yield() {
  case $ENABLED in (*1*) case $FILTER in (*1*) proc; esac; esac
}

syntax_error() {
  set -- "Syntax error: $1 in $specfile line $lineno" "${2:-}"
  putsn "abort \"$1\" \"$2\""
}

prepare() {
  specfile=$2 ranges=${3:-} filter=1
  [ "$SHELLSPEC_FOCUS_FILTER" ] && filter=''
  [ "$SHELLSPEC_TAG_FILTER" ] && filter=''
  [ "$SHELLSPEC_EXAMPLE_FILTER" ] && filter=''
  [ "$ranges" ] && enabled='' || enabled=1
  SPECFILE=$specfile
  ENABLED=$enabled
  FILTER=$filter
}

if [ "$SHELLSPEC_LIST" = "debug" ]; then
  specfile() {
    prepare "$@"
    initialize; translate < "$2"; finalize
  }
  eval find_specfiles specfile ${1+'"$@"'}
  exit
fi

if [ "$SHELLSPEC_LIST" = "specfiles" ]; then
  specfile() { putsn "$2"; }
  eval find_specfiles specfile ${1+'"$@"'}
  exit
fi

if [ "$SHELLSPEC_LIST" ]; then
  specfile() {
    prepare "$@"
    eval "$(initialize; translate < "$2"; finalize)"
  }
  # shellcheck disable=SC2153
  case ${SHELLSPEC_LIST#examples:} in
    lineno) proc() { echo "$SPECFILE:$LINENO_BEGIN"; }; ;;
    id)     proc() { echo "$SPECFILE:@$EXAMPLE_ID"; }; ;;
  esac
  eval find_specfiles specfile ${1+'"$@"'}
  exit
fi

specfile() {
  count=0
  prepare "$@"
  eval "$(initialize; translate < "$2"; finalize)"
  echo "$count"
}
proc() {
  count=$(($count + 1))
}

total=0 specfiles=0
while IFS= read -r count; do
  [ "$count" ] || exit 1
  specfiles=$(($specfiles + 1))
  total=$(($total + $count))
done <<HERE
$(eval find_specfiles specfile ${1+'"$@"'})
HERE
echo "$specfiles $total"
