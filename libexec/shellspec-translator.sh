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
    "SHELLSPEC_LINENO_BEGIN=$lineno_begin"
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "shellspec_block${block_no}() { shellspec_example_group $1"
  putsn "}; shellspec_yield${block_no}() { :;"
}

trans_block_example() {
  putsn "(" \
    "SHELLSPEC_BLOCK_NO=$_block_no" \
    "SHELLSPEC_SPECFILE=\"$specfile\"" "SHELLSPEC_ID=$id" \
    "SHELLSPEC_LINENO_BEGIN=$lineno_begin" \
    "SHELLSPEC_EXAMPLE_NO=$example_no"
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "shellspec_block${block_no}() { shellspec_example $1"
  putsn "}; shellspec_yield${block_no}() { :;"
}

trans_block_end() {
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "}; SHELLSPEC_LINENO_END=$lineno_end"
  if is_focused_lineno "$focus_lineno" "$lineno_begin" "$lineno_end"; then
    remove_focused_lineno "$focus_lineno" "$lineno_begin" "$lineno_end"
    putsn "SHELLSPEC_FOCUSED=1"
  fi
  putsn "shellspec_block${block_no}) ${1# }"
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

trans_out() {
  case $1 in
    putsn) putsn "shellspec_putsn $2" ;;
    puts)  putsn "shellspec_puts $2" ;;
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

if [ "${1:-}" = "--no-metadata" ]; then
  shift
else
  putsn "shellspec_metadata"
fi

specfile() {
  specfile=$1 focus_lineno="${2:-}"
  escape_quote specfile

  putsn "shellspec_marker '$specfile' ---"
  putsn '('
  if [ "$focus_lineno" ]; then
    putsn "SHELLSPEC_FOCUSED="
  else
    putsn "SHELLSPEC_FOCUSED=1"
  fi
  putsn "SHELLSPEC_SPECFILE='$specfile'"
  putsn "shellspec_specfile begin"
  initialize
  putsn "shellspec_marker '$specfile' BOF"
  ( translate < "$1" )
  putsn "shellspec_marker '$specfile' EOF"
  finalize
  putsn "shellspec_specfile end"
  putsn ')'
}
find_specfiles specfile "$@"

putsn "shellspec_flush"
