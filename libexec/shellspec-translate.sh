#!/bin/sh
#shellcheck disable=SC2004,SC2016

set -eu

# shellcheck source=lib/libexec/translator.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/translator.sh"
use escape_quote

delimiter="DELIMITER-$SHELLSPEC_UNIXTIME-$$"

trans() {
  # shellcheck disable=SC2145
  "trans_$@"
}

trans_block_example_group() {
  putsn "("
  [ "$skipped" ] && trans_skip ""
  putsn "shellspec_group_id $block_id $block_no"
  putsn "SHELLSPEC_LINENO_BEGIN=$lineno_begin"
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "shellspec_block${block_no}() { "
  putsn "shellspec_filter '$enabled' '$focused' '$filter'"
  putsn "shellspec_example_group $1"
  putsn "}; shellspec_yield${block_no}() { :;"
}

trans_block_example() {
  putsn "("
  [ "$skipped" ] && trans_skip ""
  putsn "shellspec_example_id $block_id $example_no $block_no"
  putsn "SHELLSPEC_LINENO_BEGIN=$lineno_begin"
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "shellspec_block${block_no}() { "
  putsn "shellspec_filter '$enabled' '$focused' '$filter'"
  putsn "shellspec_example_block"
  putsn "}; shellspec_example${block_no}() { "
  putsn "if [ \$# -eq 0 ]"
  putsn "then shellspec_example ${1:-@} --"
  putsn "else shellspec_example ${1:-@} -- \"\$@\""
  putsn "fi"
  putsn "}; shellspec_yield${block_no}() { :;"
}

trans_block_end() {
  set -- "${1:-}"
  putsn "}; SHELLSPEC_LINENO_END=$lineno_end"
  putsn "shellspec_filter '$enabled'"
  putsn "shellspec_block${block_no}) ${1# }"
  putsn "shellspec_marker \"$specfile\" $lineno"
}

trans_before_first_block() {
  putsn "shellspec_before_first_block"
}

trans_after_last_block() {
  putsn "shellspec_after_last_block"
}

trans_after_block() {
  putsn "shellspec_after_block"
}

trans_evaluation() {
  putsn "SHELLSPEC_LINENO=$lineno"
  putsn "if [ \$# -eq 0 ]"
  putsn "then shellspec_invoke_data"
  putsn "else shellspec_invoke_data \"\$@\""
  putsn "fi"
  putsn "shellspec_statement $1 $2"
  putsn "if [ -e \"\$SHELLSPEC_VARS_FILE\" ]; then"
  putsn "  . \"\$SHELLSPEC_VARS_FILE\""
  putsn "fi"
}

trans_expectation() {
  putsn "SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_statement $1 $2"
}

trans_control() {
  putsn "SHELLSPEC_AUX_LINENO=$lineno"
  putsn "shellspec_$1 $2"
}

trans_pending() {
  putsn "SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_pending ${1:-}"
}

trans_skip() {
  putsn "SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_skip $skip_id ${1:-}"
}

trans_data_begin() {
  putsn "shellspec_data() {"
}

trans_data_text() {
  putsn "  shellspec_putsn $1"
}

trans_data_func() {
  putsn "  $1"
}

trans_data_file() {
  putsn "shellspec_cat $1"
}

trans_data_end() {
  putsn "}"
  putsn "SHELLSPEC_DATA=1"
}

trans_embedded_text_begin() {
  case $1 in
    expand) putsn "shellspec_cat <<DATA-$delimiter $2" ;;
    raw)    putsn "shellspec_cat <<'DATA-$delimiter' $2" ;;
  esac
}

trans_embedded_text_line() {
  putsn "$1"
}

trans_embedded_text_end() {
  putsn "DATA-$delimiter"
}

trans_out() {
  case $1 in
    logger)   putsn "shellspec_logger $2" ;;
    preserve) putsn "shellspec_preserve $2" ;;
    printf)   putsn "shellspec_printf $2" ;;
    puts)     putsn "shellspec_puts $2" ;;
    putsn)    putsn "shellspec_putsn $2" ;;
    sleep)    putsn "shellspec_sleep $2" ;;
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

trans_mock_begin() {
  putsn "shellspec_unsetf ${1%% *} ||:"
  putsn "shellspec_after_mock shellspec_unmock_${mock_no}"
  putsn "shellspec_unmock_${mock_no}() {"
  putsn "  shellspec_unmock $1"
  putsn "}"
  putsn "<<'MOCK-$delimiter' shellspec_mock $1"
}

trans_mock_end() {
  putsn "MOCK-$delimiter"
}

trans_constant() {
  ( eval "putsn $1=\\'$2\\'" ) ||:
}

trans_include() {
  # Do not use the dot command in a function. The behavior will be different
  putsn 'if shellspec_unless SKIP; then'
  putsn "  eval shellspec_pack SHELLSPEC_OLDARGS \${1+'\"\$@\"'}"
  putsn '  shellspec_include_pack __SOURCED__ SHELLSPEC_ARGS' "$1"
  putsn '  eval "set -- $SHELLSPEC_ARGS"'
  putsn '  shellspec_coverage_start'
  putsn '  . "$__SOURCED__"'
  putsn '  shellspec_coverage_stop'
  putsn '  eval "set -- $SHELLSPEC_OLDARGS"'
  putsn '  unset __SOURCED__ SHELLSPEC_ARGS SHELLSPEC_OLDARGS ||:'
  putsn 'fi'
}

trans_line() {
  putsn "$1"
}

trans_with_function() {
  putsn "$1 { "
}

syntax_error() {
  set -- "Syntax error: $1 in $specfile line $lineno" "${2:-}"
  putsn "shellspec_abort $SHELLSPEC_ERROR_EXIT_CODE \"$1\" \"$2\" 2>&3"
}

metadata=1 finished=1 coverage='' fd='' spec_no=1 progress=''

for param in "$@"; do
  case $param in
    --no-metadata) metadata='' ;;
    --no-finished) finished='' ;;
    --coverage   ) coverage=1 ;;
    --fd=*       ) fd=${param#*=} ;;
    --spec-no=*  ) spec_no=${param#*=} ;;
    --progress   ) progress=1 ;;
    *) set -- "$@" "$param" ;;
  esac
  shift
done

filter=1
[ "$SHELLSPEC_FOCUS_FILTER" ] && filter=''
[ "$SHELLSPEC_TAG_FILTER" ] && filter=''
[ "$SHELLSPEC_EXAMPLE_FILTER" ] && filter=''

putsn "#!/bin/sh"
putsn "export SHELLSPEC_PATH=\"\${SHELLSPEC_PATH:-\$PATH}\""
putsn "SHELLSPEC_SPECFILE=''"
putsn "SHELLSPEC_DATA=''"
putsn "SHELLSPEC_WORKDIR=\"\$SHELLSPEC_TMPBASE\""
putsn "SHELLSPEC_MOCK_BINDIR=\"\$SHELLSPEC_WORKDIR/$spec_no\""
putsn "SHELLSPEC_STDIO_FILE_BASE=\"\$SHELLSPEC_WORKDIR\""
puts "PATH=\"\$SHELLSPEC_MOCK_BINDIR:\$SHELLSPEC_SUPPORT_BINDIR"
if [ "$SHELLSPEC_SANDBOX" ]; then
  putsn "\${SHELLSPEC_SANDBOX_PATH:+:}\$SHELLSPEC_SANDBOX_PATH\""
  putsn "readonly PATH"
else
  putsn "\${PATH:+:}\$PATH\""
fi
putsn "[ \"\$SHELLSPEC_DEBUG_TRAP\" ] && trap - DEBUG"
putsn "shellspec_coverage_setup() { shellspec_coverage_disabled; }"
[ "$coverage" ] && putsn ". \"\${SHELLSPEC_COVERAGE_SETUP:-/dev/null}\""
[ "$fd" ] && putsn "exec 1>&$fd"
putsn ". \"\$SHELLSPEC_LIB/bootstrap.sh\""
putsn "shellspec_coverage_setup \"\$SHELLSPEC_SHELL_TYPE\""
putsn "shellspec_metadata $metadata"

specfile_count=0
progress() { :; }
if [ "$progress" ]; then
  count_specfile() { specfile_count=$(($specfile_count + 1)); }
  eval find_specfiles count_specfile ${1+'"$@"'}
  progress() { puts "$@" > "$SHELLSPEC_DEV_TTY"; }
fi

specfile() {
  [ -e "$2" ] || return 0
  progress "${CR}Translate[$spec_no/$specfile_count]: $2${ESC}[K"
  (
    specfile=$2 ranges=${3:-} run_all='' execdir=$SHELLSPEC_EXECDIR
    escape_quote specfile
    escape_quote execdir
    [ "$ranges" ] && enabled='' || enabled=1
    [ "$enabled" ] && [ "$filter" ] && run_all=1

    putsn "shellspec_marker '$specfile' ---"
    putsn "(shellspec_begin '$specfile' '$spec_no'"
    putsn "shellspec_execdir '$execdir'"
    putsn "shellspec_perform '$enabled' '$filter'"
    initialize
    putsn "shellspec_marker '$specfile' BOF"
    translate < "$2"
    putsn "shellspec_marker '$specfile' EOF"
    finalize
    putsn "shellspec_end ${run_all:+$(($example_no - 1))})"
  )
  wait # Workaround for ksh88. Segmentation fault when processing many files.
  spec_no=$(($spec_no + 1))
}
eval find_specfiles specfile ${1+'"$@"'}
progress "${CR}${ESC}[2K"

putsn "shellspec_finished $finished"
