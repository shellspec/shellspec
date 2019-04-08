#!/bin/sh
#shellcheck disable=SC2004,SC2016

set -eu

# shellcheck source=lib/libexec/translator.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/translator.sh"

block_example_group() {
  if [ "$inside_of_example" ]; then
    syntax_error "Describe/Context cannot be defined inside of Example"
    return 0
  fi

  increasese_id
  block_no=$(($block_no + 1))
  putsn "(" \
    "SHELLSPEC_BLOCK_NO=$block_no" \
    "SHELLSPEC_SPECFILE=\"$specfile\"" "SHELLSPEC_ID=$id" \
    "SHELLSPEC_LINENO_BEGIN=$lineno"
  putsn "shellspec_marker \"$specfile\":$lineno"
  putsn "shellspec_block${block_no}() { shellspec_example_group $1"
  putsn "}; shellspec_yield${block_no}() { :;"
  block_no_stack="$block_no_stack $block_no"
}

block_example() {
  if [ "$inside_of_example" ]; then
    syntax_error "It/Example/Specify/Todo cannot be defined inside of Example"
    return 0
  fi

  increasese_id
  block_no=$(($block_no + 1)) example_no=$(($example_no + 1))
  putsn "(" \
    "SHELLSPEC_BLOCK_NO=$block_no" \
    "SHELLSPEC_SPECFILE=\"$specfile\"" "SHELLSPEC_ID=$id" \
    "SHELLSPEC_LINENO_BEGIN=$lineno" \
    "SHELLSPEC_EXAMPLE_NO=$example_no"
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "shellspec_block${block_no}() { shellspec_example $1"
  putsn "}; shellspec_yield${block_no}() { :;"
  block_no_stack="$block_no_stack $block_no"
  inside_of_example="yes"
}

block_end() {
  if [ -z "$block_no_stack" ]; then
    syntax_error "unexpected 'End'"
    return 0
  fi

  decrease_id
  putsn "shellspec_marker \"$specfile\" $lineno"
  putsn "}; SHELLSPEC_LINENO_END=$lineno"
  putsn "shellspec_block${block_no_stack##* }) ${1# }"
  block_no_stack="${block_no_stack% *}"
  inside_of_example=""
}

x() { "$@"; skip; }

todo() {
  block_example "$1"
  block_end ""
}

statement() {
  if [ -z "$inside_of_example" ]; then
    syntax_error "When/The cannot be defined outside of Example"
    return 0
  fi

  putsn "SHELLSPEC_SPECFILE=\"$specfile\" SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_statement $1$2"
}

control() {
  case $1 in (before|after)
    if [ "$inside_of_example" ]; then
      syntax_error "Before/After cannot be defined inside of Example"
      return 0
    fi
  esac
  putsn "SHELLSPEC_AUX_LINENO=$lineno"
  putsn "shellspec_$1$2"
}

skip() {
  skip_id=$(($skip_id + 1))
  putsn "SHELLSPEC_SPECFILE=\"$specfile\" SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_skip ${skip_id}${1:-}"
}

data() {
  data_line=${2:-}
  trim data_line
  now=$(unixtime)
  delimiter="DATA${now}$$"

  putsn "shellspec_data() {"
  case $data_line in
    '' | '#'* | '|'*)
      case $1 in
        expand) putsn "shellspec_passthrough<<$delimiter $data_line" ;;
        raw)    putsn "shellspec_passthrough<<'$delimiter' $data_line" ;;
      esac
      while IFS= read -r line || [ "$line" ]; do
        lineno=$(($lineno + 1))
        trim line
        case $line in
          '#|'*) putsn "${line#??}" ;;
          '#'*) ;;
          End | End\ * ) break ;;
          *) syntax_error "Data texts should begin with '#|'"
            break ;;
        esac
      done
      putsn "$delimiter"
      ;;
    "'"* | '"'*) putsn "  shellspec_putsn $data_line" ;;
    *) putsn "  $data_line" ;;
  esac
  putsn "}"
  putsn "SHELLSPEC_DATA=1"
}

text_begin() {
  now=$(unixtime)
  delimiter="DATA${now}$$"

  case $1 in
    expand) putsn "shellspec_passthrough<<$delimiter ${2}" ;;
    raw)    putsn "shellspec_passthrough<<'$delimiter' ${2}" ;;
  esac
  inside_of_text=1
}

text() {
  case $1 in ('#|'*) putsn "${1#??}"; return 0; esac
  text_end
  return 1
}

text_end() {
  putsn "$delimiter"
  inside_of_text=''
}

constant() {
  if [ "$block_no_stack" ]; then
    syntax_error "Constant should be defined outside of Example Group/Example"
    return 0
  fi

  line=$1
  trim line
  name=${line%%:*} value=${line#*:}
  trim value
  if is_constant_name "$name"; then
    ( eval "putsn $name=\\'$value\\'" ) ||:
  else
    syntax_error "Constant name should match pattern [A-Z_][A-Z0-9_]*"
  fi
}

define() {
  line=$1
  trim line
  name="${line%% *}"
  case $line in (*" "*) value="${line#* }" ;; (*) value= ;; esac

  if ! is_function_name "$name"; then
    syntax_error "Def name should match pattern [a-zA-Z_][a-zA-Z0-9_]*"
    return 0
  fi

  func="$name() {${LF}shellspec_puts $value${LF}}"
  putsn "$func"
}

include() {
  if [ "$inside_of_example" ]; then
    syntax_error "Include cannot be defined inside of Example"
    return 0
  fi

  putsn "shellspec_include $1"
}

error() {
  syntax_error "${*:-}"
}

syntax_error() {
  putsn "shellspec_exit 2 \"Syntax error: $1 in $specfile line $lineno\" \"${2:-}\""
}

translate() {
  initialize_id
  inside_of_example='' inside_of_text=''
  while IFS= read -r line || [ "$line" ]; do
    lineno=$(($lineno + 1)) work=$line
    trim work

    [ "$inside_of_text" ] && text "$work" && continue

    dsl=${work%% *}
    case $dsl in
      Describe    )   block_example_group "${work#$dsl}" ;;
      xDescribe   ) x block_example_group "${work#$dsl}" ;;
      Context     )   block_example_group "${work#$dsl}" ;;
      xContext    ) x block_example_group "${work#$dsl}" ;;
      Example     )   block_example       "${work#$dsl}" ;;
      xExample    ) x block_example       "${work#$dsl}" ;;
      Specify     )   block_example       "${work#$dsl}" ;;
      xSpecify    ) x block_example       "${work#$dsl}" ;;
      It          )   block_example       "${work#$dsl}" ;;
      xIt         ) x block_example       "${work#$dsl}" ;;
      End         )   block_end           "${work#$dsl}" ;;
      Todo        )   todo                "${work#$dsl}" ;;
      When        )   statement when      "${work#$dsl}" ;;
      The         )   statement the       "${work#$dsl}" ;;
      Path        )   control path        "${work#$dsl}" ;;
      File        )   control path        "${work#$dsl}" ;;
      Dir         )   control path        "${work#$dsl}" ;;
      Before      )   control before      "${work#$dsl}" ;;
      After       )   control after       "${work#$dsl}" ;;
      Pending     )   control pending     "${work#$dsl}" ;;
      Skip        )   skip                "${work#$dsl}" ;;
      Data        )   data raw            "${work#$dsl}" ;;
      Data:raw    )   data raw            "${work#$dsl}" ;;
      Data:expand )   data expand         "${work#$dsl}" ;;
      Def         )   define              "${work#$dsl}" ;;
      Include     )   include             "${work#$dsl}" ;;
      Logger      )   control logger      "${work#$dsl}" ;;
      %text       )   text_begin raw      "${work#$dsl}" ;;
      %text:raw   )   text_begin raw      "${work#$dsl}" ;;
      %text:expand)   text_begin expand   "${work#$dsl}" ;;
      % | %const  )   constant            "${work#$dsl}" ;;
      Error       )   error               "${work#$dsl}" ;;
      *) putsn "$line" ;;
    esac
  done
}

if [ "$SHELLSPEC_SYNTAX_CHECK" ]; then
  each_file() {
  ! is_specfile "$1" && return 0
    $SHELLSPEC_SHELL -n "$1" || exit 1
  }
  find_files each_file "$@"
fi

putsn ". \"\$SHELLSPEC_LIB/bootstrap.sh\""
putsn "shellspec_metadata"
each_file() {
  ! is_specfile "$1" && return 0
  putsn '('
  specfile=$1 lineno=0 block_no=0 block_no_stack='' example_no=0 skip_id=0
  escape_quote specfile
  putsn "SHELLSPEC_SPECFILE='$specfile'"
  putsn "shellspec_specfile begin"
  putsn "shellspec_marker \"$specfile\" BOF"
  translate < "$specfile"
  putsn "shellspec_marker \"$specfile\" EOF"
  if [ "$block_no_stack" ]; then
    syntax_error "unexpected end of file (expecting 'End')"
    lineno=
    while [ "$block_no_stack" ]; do
      block_end ""
    done
  fi
  putsn "shellspec_specfile end"
  putsn ')'
}
find_files each_file "$@"
putsn "SHELLSPEC_SPECFILE=\"\""
putsn "shellspec_end"
