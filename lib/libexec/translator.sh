#shellcheck shell=sh disable=SC2004,SC2034,SC2119,SC2120,SC2016

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use constants trim match_pattern ends_with escape_quote replace_all match includes
load grammar

initialize() {
  block_id='' block_id_increased=1 inside_of_example='' inside_of_text=''
  lineno=0 block_no=0 example_no=1 skip_id=0 error='' focused='' skipped=''
  _block_no=0 _block_no_stack='' mock_no=1 inside_of_mock='' use_dsl_in_mock=''
  parameter_count='' parameter_no=0 _parameter_count_stack=''
  parameters_need_example=''
}

finalize() {
  if [ "$_block_no_stack" ]; then
    syntax_error "Unexpected end of file (expecting 'End')"
    lineno=
    while [ "$_block_no_stack" ]; do block_end; done
  fi
  if [ ! "$block_id_increased" ]; then
    trans after_last_block ""
  fi
  trans after_block ""
}

read_specfile() {
  eval "{ IFS= read -r $1 || [ \"\$$1\" ]; } && $1=\${$1%\"\$CR\"}" && {
    lineno=$(($lineno + 1))
  }
}

one_line_syntax_check() { :; }

check_filter() {
  check_filter="$1"
  replace_all check_filter '$' "$DC1"
  replace_all check_filter '`' "$DC2"
  eval "set -- $check_filter"
  if [ $# -gt 0 ]; then
    check_filter="$1"
    replace_all check_filter "$DC1" '$'
    replace_all check_filter "$DC2" '`'
    match_pattern "$check_filter" "$SHELLSPEC_EXAMPLE_FILTER" && return 0
    shift
  fi
  [ $# -gt 0 ] || return 1
  check_tag_filter "$@"
}

check_tag_filter() {
  [ "$SHELLSPEC_TAG_FILTER" ] || return 1
  while [ $# -gt 0 ]; do
    includes ",$SHELLSPEC_TAG_FILTER," ",$1," && return 0
    case $1 in (*:*)
      includes ",$SHELLSPEC_TAG_FILTER," ",${1%%:*}," && return 0
    esac
    shift
  done
  return 1
}

is_constant_name() {
  match "$1" "[!A-Z_]*" && return 1
  match "$1" "*[!A-Z0-9_]*" && return 1
  return 0
}

is_function_name() {
  match "$1" "[!a-zA-Z_]*" && return 1
  match "$1" "*[!a-zA-Z0-9_]*" && return 1
  return 0
}

is_comment() {
  case $1 in (\# | \#\ * | \#$TAB*) return 0; esac
  return 1
}

is_embedded_text() {
  case $1 in (\#\|*) return 0; esac
  return 1
}

if_embedded_text() {
  is_embedded_text "$1" || return 1
  set -- "$@" "${1#??}"
  shift
  "$@"
}

increase_block_id() {
  [ "$block_id_increased" ] && block_id=$block_id${block_id:+-}0
  case $block_id in
    *-*) block_id=${block_id%-*}-$((${block_id##*-} + 1)) ;;
    *  ) block_id=$(($block_id + 1)) ;;
  esac
  block_id_increased=1
}

decrease_block_id() {
  if [ "$block_id_increased" ]; then
    block_id_increased=''
  else
    block_id=${block_id%-*}
  fi
}

block_example_group() {
  if [ "$inside_of_example" ]; then
    syntax_error "Describe/Context cannot be defined inside of Example"
    return 0
  fi

  if ! one_line_syntax_check error "$1"; then
    syntax_error "Describe/Context has occurred an error" "$error"
    return 0
  fi

  check_filter "$1" && filter=1

  if [ "$block_id_increased" ]; then
    trans before_first_block "$block_id"
  fi
  increase_block_id
  _block_no=$(($_block_no + 1))
  block_no=$_block_no lineno_begin=$lineno
  eval "block_lineno_begin${_block_no}=$lineno"

  eval trans block_example_group ${1+'"$@"'}

  _block_no_stack="$_block_no_stack $_block_no" filter=''
  _parameter_count_stack="$_parameter_count_stack $parameter_no:$parameter_count"
}

block_example() {
  if [ "$inside_of_example" ]; then
    syntax_error "It/Example/Specify/Todo cannot be defined inside of Example"
    return 0
  fi

  parameters_need_example=''

  if ! one_line_syntax_check error "$1"; then
    syntax_error "It/Example/Specify/Todo has occurred an error" "$error"
    return 0
  fi

  check_filter "$1" && filter=1

  if [ "$block_id_increased" ]; then
    trans before_first_block "$block_id"
  fi
  increase_block_id
  _block_no=$(($_block_no + 1))
  block_no=$_block_no lineno_begin=$lineno
  eval "block_lineno_begin${block_no}=$lineno"

  eval trans block_example ${1+'"$@"'}

  _block_no_stack="$_block_no_stack $_block_no"
  example_no=$(($example_no + ${parameter_count:-1}))
  _parameter_count_stack="$_parameter_count_stack $parameter_no:$parameter_count"
  filter='' inside_of_example="yes"
}

block_end() {
  if [ ! "$_block_no_stack" ]; then
    syntax_error "Unexpected 'End'"
    return 0
  fi

  if [ "$parameters_need_example" ]; then
    syntax_error "Not found any examples. (Missing 'End' of Parameters?)"
    parameters_need_example=''
    return 0
  fi

  if [ ! "$block_id_increased" ]; then
    trans after_last_block "${block_id%-*}"
  fi
  decrease_block_id
  block_no=${_block_no_stack##* } lineno_end=$lineno
  trans after_block "$block_no"
  eval "block_lineno_end${block_no}=$lineno"
  eval "lineno_begin=\$block_lineno_begin${block_no}"

  if is_in_ranges; then
    enabled=1
    remove_from_ranges
  fi

  eval trans block_end ${1+'"$@"'}
  enabled=''

  _block_no_stack=${_block_no_stack% *}
  parameter_count=${_parameter_count_stack##* }
  parameter_no=${parameter_count%:*}
  parameter_count=${parameter_count#*:}
  _parameter_count_stack=${_parameter_count_stack% *}
  inside_of_example=""
}

x() {
  skipped=1 skip_id=$(($skip_id + 1))
  "$@"
  skipped=''
}

f() {
  focused="focus" filter=1
  "$@"
  focused='' filter=''
}

todo() {
  block_example "$1"
  pending "$1"
  block_end
}

evaluation() {
  if [ ! "$inside_of_example" ]; then
    syntax_error "When cannot be defined outside of Example"
    return 0
  fi
  eval trans evaluation ${1+'"$@"'}
}

expectation() {
  if [ ! "$inside_of_example" ]; then
    syntax_error "The cannot be defined outside of Example"
    return 0
  fi
  eval trans expectation ${1+'"$@"'}
}

example_hook() {
  if [ "$inside_of_example" ]; then
    syntax_error "Before/After cannot be defined inside of Example"
    return 0
  fi
  eval trans control ${1+'"$@"'}
}

example_all_hook() {
  if [ "$inside_of_example" ]; then
    syntax_error "BeforeAll/AfterAll cannot be defined inside of Example"
    return 0
  fi

  if [ "$1" = "before_all" ] && [ ! "$block_id_increased" ]; then
    syntax_error "BeforeAll cannot be defined after of Example Group/Example in same block"
    return 0
  fi

  eval trans control ${1+'"$@"'}
}

control() {
  eval trans control ${1+'"$@"'}
}

pending() {
  case ${1:-} in (\#*)
    temporary_pending=${1#"#"}
    escape_quote temporary_pending
    trim temporary_pending "$temporary_pending"
    set -- "'# $temporary_pending'"
  esac
  eval trans pending ${1+'"$@"'}
}

skip() {
  skip_id=$(($skip_id + 1))
  case ${1:-} in (\#*)
    temporary_skip=${1#"#"}
    escape_quote temporary_skip
    trim temporary_skip "$temporary_skip"
    set -- "'# $temporary_skip'"
  esac
  eval trans skip ${1+'"$@"'}
}

data() {
  eval trans data_begin ${1+'"$@"'}
  case ${2:-} in
    '' | \#* | \|*)
      trans embedded_text_begin "$1" "${2:-}"
      line='' error=
      while read_specfile line; do
        trim line "$line"
        is_comment "$line" && continue # ignore comment line
        if_embedded_text "$line" trans embedded_text_line && continue
        is_end_block "${line%% *}" && break
        [ "$error" ] && continue
        error=$(syntax_error "Data text should begin with '#|' or '# '")
      done
      trans embedded_text_end
      [ ! "$error" ] || putsn "$error"
      ;;
    \'* | \"*) trans data_text "$2" ;;
    \<*) trans data_file "$2" ;;
    *) trans data_func "$2" ;;
  esac
  eval trans data_end ${1+'"$@"'}
}

text_begin() {
  eval trans embedded_text_begin ${1+'"$@"'}
  inside_of_text=1
}

text_line() {
  if_embedded_text "$1" trans embedded_text_line && return 0
  text_end
  return 1
}

text_end() {
  eval trans embedded_text_end ${1+'"$@"'}
  inside_of_text=''
}

parameters() {
  if [ "$inside_of_example" ]; then
    syntax_error "Parameters cannot be defined inside of Example"
    return 0
  fi
  parameters_need_example=1

  parameter_no=$(($parameter_no + 1))
  trans parameters_begin "$parameter_no"
  #shellcheck disable=SC2145
  "parameters_$@"
  trans parameters_end
}

parameters_generate_code() {
  trans line "$1"
  code="${code}${1}${LF}"
}

parameters_continuation_line() {
  line=$1
  shift
  while ends_with "$line"  "\\"; do
    read_specfile line ||:
    "$@" "$line"
  done
}

parameters_block() {
  while read_specfile line; do
    trim line "$line"
    is_end_block "${line%% *}" && break
    case $line in (\#* | '') continue; esac

    trans parameters "$line"
    parameter_count=$(($parameter_count + 1))
    parameters_continuation_line "$line" trans line
  done
}

parameters_value() {
  code=''
  if [ $# -gt 0 ]; then
    IFS=" $IFS"
    parameters_generate_code "for shellspec_matrix in $*; do"
    IFS=${IFS#?}
    trans parameters "\"\$shellspec_matrix\""
    code="${code}count=\$((\$count + 1))${LF}"
    parameters_generate_code "done"
  fi
  eval "parameter_count=\$(count=0${LF}${code}echo \"\$count\")"
}

parameters_matrix() {
  code='' nest=0 arguments=''

  while read_specfile line; do
    trim line "$line"
    is_end_block "${line%% *}" && break
    case $line in (\#* | '') continue; esac

    nest=$(($nest + 1))
    parameters_generate_code "for shellspec_matrix${nest} in $line"
    arguments="$arguments\"\$shellspec_matrix${nest}\" "
    parameters_continuation_line "$line" parameters_generate_code
    parameters_generate_code "do"
  done

  trans parameters "$arguments"
  code="${code}count=\$((\$count + 1))${LF}"

  while [ $nest -gt 0 ]; do
    parameters_generate_code "done"
    nest=$(($nest - 1))
  done

  eval "parameter_count=\$(count=0${LF}${code}echo \"\$count\")"
}

parameters_dynamic() {
  code=''

  while read_specfile line; do
    trim line "$line"
    is_end_block "${line%% *}" && break

    case $line in
      %data | %data\ *)
        line=${line#%data}
        trans parameters "$line"
        line='count=$(($count + 1))'
        ;;
      *) trans line "$line"
    esac
    code="${code}${line}${LF}"
  done

  eval "parameter_count=\$(count=0${LF}{ $code }>&2;echo \"\$count\")"
}

mock() {
  inside_of_mock=1
  eval trans mock_begin ${1+'"$@"'}
  mock_no=$(($mock_no + 1))
}

mock_end() {
  is_end_block "${1%% *}" || return 1
  inside_of_mock=''
  eval trans mock_end ${1+'"$@"'}
}

constant() {
  if [ "$_block_no_stack" ]; then
    syntax_error "Constant should be defined outside of Example Group/Example"
    return 0
  fi

  trim line "$1"
  name=${line%%:*} value=''
  trim value "${line#*:}"
  if is_constant_name "$name"; then
    trans constant "$name" "$value"
    eval "$name=\$value"
  else
    syntax_error "Constant name should match pattern [A-Z_][A-Z0-9_]*"
  fi
}

include() {
  if [ "$inside_of_example" ]; then
    syntax_error "Include cannot be defined inside of Example"
    return 0
  fi

  if ! one_line_syntax_check error "$1"; then
    syntax_error "Include has occurred an error" "$error"
    return 0
  fi

  eval trans include ${1+'"$@"'}
}

with_function() {
  trans with_function "$1"
  shift
  "$@"
}

out() {
  eval trans out ${1+'"$@"'}
}

is_in_range() {
  case $1 in
    @*) [ "$block_id" = "${1#@}" ] ;;
    *) [ "$lineno_begin" -le "$1" ] && [ "$1" -le "$lineno_end" ] ;;
  esac
}

is_in_ranges() {
  [ "${ranges:-}" ] || return 1
  eval "set -- $ranges"
  while [ $# -gt 0 ]; do
    is_in_range "$1" && return 0
    shift
  done
  return 1
}

remove_from_ranges() {
  eval "set -- $ranges"
  ranges=''
  while [ $# -gt 0 ]; do
    is_in_range "$1" || ranges="$ranges$1 "
    shift
  done
}

translate() {
  work=''
  while read_specfile line; do
    while ends_with "$line" "\\"; do
      read_specfile work ||:
      line="${line}${LF}${work}"
    done
    trim work "$line"
    dsl=${work%% *} rest=''

    [ "$inside_of_text" ] && text_line "$work" && continue
    translate_mock "$dsl" && continue

    trim rest "${work#"$dsl"}"
    mapping "$dsl" "$rest" || trans line "$line"
  done
}

translate_mock() {
  if [ "$inside_of_mock" ]; then
    mock_end "$1" && return 0
    is_dsl "$1" && use_dsl_in_mock=1 && return 0
  elif [ "$use_dsl_in_mock" ]; then
    syntax_error "Only directives can be used in Mock"
  fi
  return 1
}
