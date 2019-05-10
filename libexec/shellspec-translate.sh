#!/bin/sh

set -eu

# shellcheck source=lib/libexec/translator.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/translator.sh"
use escape_quote

delimiter="DATA-$SHELLSPEC_UNIXTIME-$$"

trans() {
  # shellcheck disable=SC2145
  "trans_$@"
}

trans_block_example_group() {
  putsn "(" \
    "SHELLSPEC_BLOCK_NO=$block_no" \
    "SHELLSPEC_EXAMPLE_ID=$example_id" \
    "SHELLSPEC_LINENO_BEGIN=$lineno_begin"
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "shellspec_block${block_no}() { "
  putsn "SHELLSPEC_FOCUSED=\${SHELLSPEC_FOCUSED:-$focused}"
  putsn "SHELLSPEC_FILTER=\${SHELLSPEC_FILTER:-$filter}"
  putsn "SHELLSPEC_ENABLED=\${SHELLSPEC_ENABLED:-$enabled}"
  putsn "shellspec_example_group $1"
  putsn "}; shellspec_yield${block_no}() { :;"
}

trans_block_example() {
  putsn "(" \
    "SHELLSPEC_BLOCK_NO=$_block_no" \
    "SHELLSPEC_EXAMPLE_ID=$example_id" \
    "SHELLSPEC_LINENO_BEGIN=$lineno_begin" \
    "SHELLSPEC_EXAMPLE_NO=$example_no"
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "shellspec_block${block_no}() { "
  putsn "SHELLSPEC_FOCUSED=\${SHELLSPEC_FOCUSED:-$focused}"
  putsn "SHELLSPEC_FILTER=\${SHELLSPEC_FILTER:-$filter}"
  putsn "SHELLSPEC_ENABLED=\${SHELLSPEC_ENABLED:-$enabled}"
  putsn "shellspec_example $1"
  putsn "}; shellspec_yield${block_no}() { :;"
}

trans_block_end() {
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "}; SHELLSPEC_LINENO_END=$lineno_end"
  putsn "SHELLSPEC_ENABLED=\${SHELLSPEC_ENABLED:-$enabled}"
  putsn "shellspec_block${block_no}) ${1# }"
}

trans_statement() {
  putsn "SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_statement $1$2"
}

trans_control() {
  putsn "SHELLSPEC_AUX_LINENO=$lineno"
  putsn "shellspec_$1$2"
}

trans_skip() {
  putsn "SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_skip ${skip_id}${1:-}"
}

here() {
  # the parameters is ash 0.3.8 (and posh) workaround. #14 in contrib/bugs.sh
  putsn "eval shellspec_passthrough \${1+'\"\$@\"'}<<$1 $2"
}

trans_data_begin() {
  putsn "shellspec_data() {"
}

trans_data_here_begin() {
  case $1 in
    expand) here "$delimiter" "$2" ;;
    raw)    here "'$delimiter'" "$2" ;;
  esac
}

trans_data_here_line() {
  putsn "${1#??}"
}

trans_data_here_end() {
  putsn "$delimiter"
}

trans_data_text() {
  putsn "  shellspec_putsn $1"
}

trans_data_func() {
  putsn "  $1"
}

trans_data_end() {
  putsn "}"
  putsn "SHELLSPEC_DATA=1"
}

trans_text_begin() {
  case $1 in
    expand) here "$delimiter" "$2" ;;
    raw)    here "'$delimiter'" "$2" ;;
  esac
}

trans_text() {
  putsn "${1#??}"
}

trans_text_end() {
  putsn "$delimiter"
}

trans_out() {
  case $1 in
    putsn)  putsn "shellspec_putsn $2" ;;
    puts)   putsn "shellspec_puts $2" ;;
    logger) putsn "shellspec_logger $2" ;;
  esac
}

trans_constant() {
  ( eval "putsn $1=\\'$2\\'" ) ||:
}

trans_include() {
  putsn "shellspec_include $1"
}

trans_line() {
  putsn "$1"
}

trans_with_function() {
  putsn "$1 { "
}

syntax_error() {
  set -- "Syntax error: $1 in $specfile line $lineno" "${2:-}"
  putsn "shellspec_abort 2 \"$1\" \"$2\""
}

putsn ". \"\$SHELLSPEC_LIB/bootstrap.sh\""

no_metadata='' no_finished=''

for param in "$@"; do
  case $param in
    --no-metadata) no_metadata=1 ;;
    --no-finished) no_finished=1 ;;
    *) set -- "$@" "$param" ;;
  esac
  shift
done

filter=1
[ "$SHELLSPEC_FOCUS_FILTER" ] && filter=''
[ "$SHELLSPEC_TAG_FILTER" ] && filter=''
[ "$SHELLSPEC_EXAMPLE_FILTER" ] && filter=''

[ "$no_metadata" ] || putsn "shellspec_metadata"

specfile() {
  specfile=$1 lineno_renges="${2:-}"
  escape_quote specfile
  [ "$lineno_renges" ] && enabled='' || enabled=1

  putsn "shellspec_marker '$specfile' ---"
  putsn "(shellspec_begin '$specfile' '$enabled' '$filter'"
  initialize
  putsn "shellspec_marker '$specfile' BOF"
  ( translate < "$1" )
  putsn "shellspec_marker '$specfile' EOF"
  finalize
  putsn "shellspec_end)"
}
eval find_specfiles specfile ${1+'"$@"'}
putsn "shellspec_flush"

[ "$no_finished" ] || putsn "shellspec_finished"
