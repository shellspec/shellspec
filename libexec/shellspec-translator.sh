#!/bin/sh

set -eu

# shellcheck source=lib/libexec/translator.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/translator.sh"
use constants escape_quote unixtime

delimiter="DATA-$(unixtime)-$$"

trans() {
  # shellcheck disable=SC2145
  "trans_$@"
}

trans_block_example_group() {
  putsn "(" \
    "SHELLSPEC_BLOCK_NO=$block_no" \
    "SHELLSPEC_SPECFILE=\"$specfile\"" "SHELLSPEC_ID=$id" \
    "SHELLSPEC_LINENO_BEGIN=$lineno"
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "shellspec_block${block_no}() { shellspec_example_group $1"
  putsn "}; shellspec_yield${block_no}() { :;"
}

trans_block_example() {
  putsn "(" \
    "SHELLSPEC_BLOCK_NO=$block_no" \
    "SHELLSPEC_SPECFILE=\"$specfile\"" "SHELLSPEC_ID=$id" \
    "SHELLSPEC_LINENO_BEGIN=$lineno" \
    "SHELLSPEC_EXAMPLE_NO=$example_no"
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "shellspec_block${block_no}() { shellspec_example $1"
  putsn "}; shellspec_yield${block_no}() { :;"
}

trans_block_end() {
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "}; SHELLSPEC_LINENO_END=$lineno"
  putsn "shellspec_block${block_no_stack##* }) ${1# }"
}

trans_statement() {
  putsn "SHELLSPEC_SPECFILE=\"$specfile\" SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_statement $1$2"
}

trans_control() {
  putsn "SHELLSPEC_AUX_LINENO=$lineno"
  putsn "shellspec_$1$2"
}

trans_skip() {
  putsn "SHELLSPEC_SPECFILE=\"$specfile\" SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_skip ${skip_id}${1:-}"
}

here() {
  putsn "shellspec_passthrough<<$1 $2"
}

# ash 0.3.8 (with posh) workaround
old_ash_bug_detection() {
  old_ash_bug_detection_() { read -r old_ash_bug_detection; }
  eval "old_ash_bug_detection_<<HERE${SHELLSPEC_LF}\$1${SHELLSPEC_LF}HERE"
  [ "$old_ash_bug_detection" ] && return 0
  here() {
    putsn "shellspec_passthrough \"\$@\"<<$1 $2"
  }
}
old_ash_bug_detection 1

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

trans_constant() {
  ( eval "putsn $1=\\'$2\\'" ) ||:
}

trans_define() {
  putsn "$1() {${LF}shellspec_puts $2${LF}}"
}

trans_include() {
  putsn "shellspec_include $1"
}

trans_line() {
  putsn "$1"
}

syntax_error() {
  putsn "shellspec_exit 2 \"Syntax error: $1 in $specfile line $lineno\" \"${2:-}\""
}

putsn ". \"\$SHELLSPEC_LIB/bootstrap.sh\""
if [ "${1:-}" = "--metadata" ]; then
  putsn "shellspec_metadata"
  shift
fi

specfile() {
  specfile=$1
  escape_quote specfile

  putsn "shellspec_marker \"$specfile\" ---"
  putsn '('
  putsn "SHELLSPEC_SPECFILE='$specfile'"
  putsn "shellspec_specfile begin"
  initialize
  putsn "shellspec_marker \"$specfile\" BOF"
  translate < "$specfile"
  putsn "shellspec_marker \"$specfile\" EOF"
  finalize
  putsn "shellspec_specfile end"
  putsn ')'
}
find_specfiles specfile "$@"

putsn "SHELLSPEC_SPECFILE=\"\""
putsn "shellspec_end"
