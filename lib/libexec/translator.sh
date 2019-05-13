#shellcheck shell=sh disable=SC2004,SC2034,SC2119,SC2120

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use constants trim match
load grammar

initialize() {
  lineno=0 block_no=0 example_no=0 skip_id=0 error='' focused=''
  _block_no=0 _block_no_stack=''
}

finalize() {
  [ "$_block_no_stack" ] || return 0
  syntax_error "unexpected end of file (expecting 'End')"
  lineno=
  while [ "$_block_no_stack" ]; do block_end ""; done
}

one_line_syntax_check() { :; }

check_filter() {
  eval set -- "$1"
  if [ $# -gt 0 ]; then
    match "$1" "$SHELLSPEC_EXAMPLE_FILTER" && return 0
    shift
  fi
  [ "$SHELLSPEC_TAG_FILTER" ] || return 1
  while [ $# -gt 0 ]; do
    case $SHELLSPEC_TAG_FILTER in (*,$1,*) return 0; esac
    case $1 in
      *:*) case $SHELLSPEC_TAG_FILTER in (*,${1%%:*},*) return 0; esac ;;
      *  ) case $SHELLSPEC_TAG_FILTER in (*,$1:*) return 0 ; esac ;;
    esac
    shift
  done
  return 1
}

is_constant_name() {
  case $1 in ([!A-Z_]*) return 1; esac
  case $1 in (*[!A-Z0-9_]*) return 1; esac
}

is_function_name() {
  case $1 in ([!a-zA-Z_]*) return 1; esac
  case $1 in (*[!a-zA-Z0-9_]*) return 1; esac
}

block_example_group() {
  if [ "$inside_of_example" ]; then
    syntax_error "Describe/Context cannot be defined inside of Example"
    return 0
  fi

  if ! one_line_syntax_check error ": $1"; then
    syntax_error "Describe/Context has occurred an error" "$error"
    return 0
  fi

  check_filter "$1" && filter=1

  increase_example_id
  _block_no=$(($_block_no + 1))
  block_no=$_block_no lineno_begin=$lineno
  eval "block_lineno_begin${_block_no}=$lineno"

  eval trans block_example_group ${1+'"$@"'}

  _block_no_stack="$_block_no_stack $_block_no" filter=''
}

block_example() {
  if [ "$inside_of_example" ]; then
    syntax_error "It/Example/Specify/Todo cannot be defined inside of Example"
    return 0
  fi

  if ! one_line_syntax_check error ": $1"; then
    syntax_error "It/Example/Specify/Todo has occurred an error" "$error"
    return 0
  fi

  check_filter "$1" && filter=1

  increase_example_id
  _block_no=$(($_block_no + 1)) example_no=$(($example_no + 1))
  block_no=$_block_no lineno_begin=$lineno
  eval "block_lineno_begin${block_no}=$lineno"

  eval trans block_example ${1+'"$@"'}

  _block_no_stack="$_block_no_stack $_block_no" filter=''
  inside_of_example="yes"
}

block_end() {
  if [ -z "$_block_no_stack" ]; then
    syntax_error "unexpected 'End'"
    return 0
  fi

  decrease_example_id
  block_no=${_block_no_stack##* } lineno_end=$lineno
  eval "block_lineno_end${block_no}=$lineno"
  eval "lineno_begin=\$block_lineno_begin${block_no}"

  if is_in_ranges; then
    enabled=1
    remove_from_ranges
  fi

  eval trans block_end ${1+'"$@"'}
  enabled=''

  _block_no_stack="${_block_no_stack% *}"
  inside_of_example=""
}

x() { "$@"; skip; }

f() {
  focused="focus" filter=1
  "$@"
  focused='' filter=''
}

todo() {
  block_example "$1"
  block_end ""
}

statement() {
  if [ -z "$inside_of_example" ]; then
    syntax_error "When/The cannot be defined outside of Example"
    return 0
  fi
  eval trans statement ${1+'"$@"'}
}

control() {
  case $1 in (before|after)
    if [ "$inside_of_example" ]; then
      syntax_error "Before/After cannot be defined inside of Example"
      return 0
    fi
  esac
  eval trans control ${1+'"$@"'}
}

skip() {
  skip_id=$(($skip_id + 1))
  eval trans skip ${1+'"$@"'}
}

data() {
  data_line=${2:-}
  trim data_line

  eval trans data_begin ${1+'"$@"'}
  case $data_line in
    '' | \#* | \|*)
      trans data_here_begin "$1" "$data_line"
      while IFS= read -r line || [ "$line" ]; do
        lineno=$(($lineno + 1))
        trim line
        case $line in
          \#\|*) trans data_here_line "$line" ;;
          \#*) ;;
          End | End\ * ) break ;;
          *) syntax_error "Data texts should begin with '#|'"; break ;;
        esac
      done
      trans data_here_end ;;
    \'* | \"*) trans data_text "$data_line" ;;
    *) trans data_func "$data_line" ;;
  esac
  eval trans data_end ${1+'"$@"'}
}

text_begin() {
  eval trans text_begin ${1+'"$@"'}
  inside_of_text=1
}

text() {
  case $1 in
    \#\|*) eval trans text ${1+'"$@"'}; return 0 ;;
    *) text_end; return 1 ;;
  esac
}

text_end() {
  eval trans text_end ${1+'"$@"'}
  inside_of_text=''
}

out() {
  eval trans out ${1+'"$@"'}
}

constant() {
  if [ "$_block_no_stack" ]; then
    syntax_error "Constant should be defined outside of Example Group/Example"
    return 0
  fi

  line=$1
  trim line
  name=${line%%:*} value=${line#*:}
  trim value
  if is_constant_name "$name"; then
    trans constant "$name" "$value"
  else
    syntax_error "Constant name should match pattern [A-Z_][A-Z0-9_]*"
  fi
}

include() {
  if [ "$inside_of_example" ]; then
    syntax_error "Include cannot be defined inside of Example"
    return 0
  fi

  if ! one_line_syntax_check error ": $1"; then
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

is_in_range() {
  case $1 in
    @*) [ "$example_id" = "${1#@}" ] ;;
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
  example_id='' inside_of_example='' inside_of_text=''
  while IFS= read -r line || [ "$line" ]; do
    lineno=$(($lineno + 1)) work=$line
    trim work

    [ "$inside_of_text" ] && text "$work" && continue

    dsl=${work%% *}
    # Do not one line. ksh 93r does not work properly.
    if ! mapping "$dsl" "${work#"$dsl"}"; then
      trans line "$line"
    fi
  done
}
