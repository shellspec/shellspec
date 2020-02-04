#!/bin/sh
#shellcheck disable=SC2004

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
    "SHELLSPEC_GROUP_ID=$block_id" \
    "SHELLSPEC_LINENO_BEGIN=$lineno_begin"
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "shellspec_block${block_no}() { "
  [ "$focused" ] && putsn "SHELLSPEC_FOCUSED=$focused"
  [ "$filter" ] && putsn "SHELLSPEC_FILTER=$filter"
  [ "$enabled" ] && putsn "SHELLSPEC_ENABLED=$enabled"
  putsn "shellspec_example_group $1"
  putsn "}; shellspec_yield${block_no}() { :;"
}

trans_block_example() {
  putsn "(" \
    "SHELLSPEC_BLOCK_NO=$block_no" \
    "SHELLSPEC_EXAMPLE_ID=$block_id" \
    "SHELLSPEC_LINENO_BEGIN=$lineno_begin" \
    "SHELLSPEC_EXAMPLE_NO=$example_no"
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "shellspec_block${block_no}() { "
  [ "$focused" ] && putsn "SHELLSPEC_FOCUSED=$focused"
  [ "$filter" ] && putsn "SHELLSPEC_FILTER=$filter"
  [ "$enabled" ] && putsn "SHELLSPEC_ENABLED=$enabled"
  putsn "shellspec_example_block"
  putsn "}; shellspec_example${block_no}() { "
  putsn "if [ \$# -eq 0 ]"
  putsn "then shellspec_example $1 --"
  putsn "else shellspec_example $1 -- \"\$@\""
  putsn "fi"
  putsn "}; shellspec_yield${block_no}() { :;"
}

trans_block_end() {
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "}; SHELLSPEC_LINENO_END=$lineno_end"
  [ "$enabled" ] && putsn "SHELLSPEC_ENABLED=$enabled"
  putsn "shellspec_block${block_no}) ${1# }"
}

trans_statement() {
  putsn "SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_statement $1 $2"
}

trans_control() {
  putsn "SHELLSPEC_AUX_LINENO=$lineno"
  putsn "shellspec_$1 $2"
}

trans_skip() {
  putsn "SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_skip ${skip_id} ${1:-}"
}

trans_data_begin() {
  putsn "shellspec_data() {"
}

trans_data_here_begin() {
  case $1 in
    expand) putsn "cat <<$delimiter $2" ;;
    raw)    putsn "cat <<'$delimiter' $2" ;;
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

trans_data_file() {
  putsn "cat ${1#<}"
}

trans_data_end() {
  putsn "}"
  putsn "SHELLSPEC_DATA=1"
}

trans_text_begin() {
  case $1 in
    expand) putsn "cat <<$delimiter $2" ;;
    raw)    putsn "cat <<'$delimiter' $2" ;;
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

trans_parameters_begin() {
  putsn "SHELLSPEC_PARAMETER_NO=$1"
  putsn "shellspec_parameters$1() { :;"
}

trans_parameters() {
  putsn "shellspec_parameterized_example $1"
}

trans_parameters_end() {
  putsn "}"
}

trans_constant() {
  ( eval "putsn $1=\\'$2\\'" ) ||:
}

trans_include() {
  putsn "if shellspec_unless SKIP; then"
  putsn "  __SOURCED__=${1# }"
  putsn "  shellspec_coverage_start"
  putsn "  . $1"
  putsn "  shellspec_coverage_stop"
  putsn "  unset __SOURCED__ ||:"
  putsn "fi"
}

trans_line() {
  putsn "$1"
}

trans_with_function() {
  putsn "$1 { "
}

syntax_error() {
  set -- "Syntax error: $1 in $specfile line $lineno" "${2:-}"
  putsn "shellspec_abort 1 \"$1\" \"$2\""
}

metadata=1 finished=1 coverage='' fd='' spec_no=1

for param in "$@"; do
  case $param in
    --no-metadata) metadata='' ;;
    --no-finished) finished='' ;;
    --coverage   ) coverage=1 ;;
    --fd=*       ) fd=${param#*=} ;;
    --spec-no=*  ) spec_no=${param#*=} ;;
    *) set -- "$@" "$param" ;;
  esac
  shift
done

filter=1
[ "$SHELLSPEC_FOCUS_FILTER" ] && filter=''
[ "$SHELLSPEC_TAG_FILTER" ] && filter=''
[ "$SHELLSPEC_EXAMPLE_FILTER" ] && filter=''

putsn "#!/bin/sh"
putsn "shellspec_coverage_start() { :; }"
putsn "shellspec_coverage_stop() { :; }"
if [ "$coverage" ]; then
  putsn "set -o functrace"
  putsn "[ \"\$SHELLSPEC_COVERAGE_SETUP\" ] && . \"\$SHELLSPEC_COVERAGE_SETUP\""
  putsn "shellspec_coverage_stop"
fi
[ "$fd" ] && putsn "exec 1>&$fd"
putsn ". \"\$SHELLSPEC_LIB/bootstrap.sh\""
putsn "shellspec_metadata $metadata"

specfile() {
  (
    specfile=$2 ranges=${3:-} run_all=''
    escape_quote specfile
    [ "$ranges" ] && enabled='' || enabled=1
    [ "$enabled" ] && [ "$filter" ] && run_all=1

    putsn "shellspec_marker '$specfile' ---"
    putsn "(shellspec_begin '$specfile' '$spec_no'"
    putsn "if [ \"\$SHELLSPEC_ERREXIT\" ]; then set -e; else set +e; fi"
    putsn "shellspec_perform '$enabled' '$filter'"
    initialize
    putsn "shellspec_marker '$specfile' BOF"
    translate < "$2"
    putsn "shellspec_marker '$specfile' EOF"
    finalize
    putsn "shellspec_end ${run_all:+$(($example_no - 1))})"
  )
  spec_no=$(($spec_no + 1))
}
eval find_specfiles specfile ${1+'"$@"'}

putsn "shellspec_finished $finished"
