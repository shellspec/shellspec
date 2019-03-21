#!/bin/sh
#shellcheck disable=SC2004,SC2016

set -eu

# shellcheck source=lib/general.sh
. "${SHELLSPEC_LIB:-./lib}/general.sh"
# shellcheck source=lib/libexec/translator.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/translator.sh"

example_count=0 block_no=0 block_no_stack='' skip_id=0
inside_of_example=''

ABORT=''
abort() {
  ABORT=$*
}

block_example_group() {
  if [ "$inside_of_example" ]; then
    abort "Describe/Context cannot be defined inside of Example"
    return 0
  fi

  increasese_id
  block_no=$(($block_no + 1))
  putsn "(" \
    "SHELLSPEC_BLOCK_NO=$block_no" \
    "SHELLSPEC_SPECFILE=\"$specfile\"" "SHELLSPEC_ID=$id" \
    "SHELLSPEC_LINENO_BEGIN=$lineno"
  putsn "shellspec_block${block_no}() { shellspec_example_group $1"
  putsn "}; shellspec_yield${block_no}() { :;"
  block_no_stack="$block_no_stack $block_no"
}

block_example() {
  if [ "$inside_of_example" ]; then
    abort "Example/Todo cannot be defined inside of Example"
    return 0
  fi

  increasese_id
  block_no=$(($block_no + 1)) example_count=$(($example_count + 1))
  putsn "(" \
    "SHELLSPEC_BLOCK_NO=$block_no" \
    "SHELLSPEC_SPECFILE=\"$specfile\"" "SHELLSPEC_ID=$id" \
    "SHELLSPEC_EXAMPLE_NO=$example_count" \
    "SHELLSPEC_LINENO_BEGIN=$lineno"
  putsn "shellspec_block${block_no}() { shellspec_example $1"
  putsn "}; shellspec_yield${block_no}() { :;"
  block_no_stack="$block_no_stack $block_no"
  inside_of_example="yes"
}

block_end() {
  if [ -z "$block_no_stack" ]; then
    abort "unexpected 'End'"
    return 0
  fi

  decrease_id
  if [ "$ABORT" ]; then
    putsn "}; SHELLSPEC_LINENO_END="
  else
    putsn "}; SHELLSPEC_LINENO_END=$lineno"
  fi
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
    abort "When/The/It cannot be defined outside of Example"
    return 0
  fi

  putsn "SHELLSPEC_SPECFILE=\"$specfile\" SHELLSPEC_LINENO=$lineno"
  putsn "shellspec_statement $1$2"
}

control() {
  case $1 in (before|after)
    if [ "$inside_of_example" ]; then
      abort "Before/After cannot be defined inside of Example"
      return 0
    fi
  esac
  putsn "shellspec_$1$2"
}

skip() {
  skip_id=$(($skip_id + 1))
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
      putsn 'while IFS= read -r shellspec_here_document; do'
      putsn '  shellspec_putsn "$shellspec_here_document"'
      case $1 in
        expand) putsn "done<<$delimiter $data_line" ;;
        raw)    putsn "done<<'$delimiter' $data_line" ;;
      esac
      while IFS= read -r line || [ "$line" ]; do
        lineno=$(($lineno + 1))
        trim line
        case $line in
          '#|'*) putsn "${line#??}" ;;
          '#'*) ;;
          End | End\ * ) break ;;
          *) abort "Data texts should begin with '#|'"
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

  putsn 'while IFS= read -r shellspec_here_document; do'
  putsn '  shellspec_putsn "$shellspec_here_document"'
  case $1 in
    expand) putsn "done<<$delimiter ${2}" ;;
    raw)    putsn "done<<'$delimiter' ${2}" ;;
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

syntax_error() {
  putsn "shellspec_exit 2 \"Syntax error: ${*:-} in $specfile line $lineno\""
}

translate() {
  initialize_id
  lineno=1 inside_of_text=''
  while IFS= read -r line || [ "$line" ]; do
    work=$line
    trim work

    [ "$inside_of_text" ] && text "$work" && lineno=$(($lineno + 1)) && continue

    case $work in
      Describe  | Describe\ * )   block_example_group "${work#Describe}"  ;;
      xDescribe | xDescribe\ *) x block_example_group "${work#xDescribe}" ;;
      Context   | Context\ *  )   block_example_group "${work#Context}"   ;;
      xContext  | xContext\ * ) x block_example_group "${work#xContext}"  ;;
      Example   | Example\ *  )   block_example       "${work#Example}"   ;;
      xExample  | xExample\ * ) x block_example       "${work#xExample}"  ;;
      Specify   | Specify\ *  )   block_example       "${work#Specify}"   ;;
      xSpecify  | xSpecify\ * ) x block_example       "${work#xSpecify}"  ;;
      End       | End\ *      )   block_end           "${work#End}"       ;;
      Todo      | Todo\ *     )   todo                "${work#Todo}"      ;;
      When      | When\ *     )   statement when      "${work#When}"      ;;
      The       | The\ *      )   statement the       "${work#The}"       ;;
      It        | It\ *       )   statement it        "${work#It}"        ;;
      Path      | Path\ *     )   control path        "${work#Path}"      ;;
      File      | File\ *     )   control path        "${work#File}"      ;;
      Dir       | Dir\ *      )   control path        "${work#Dir}"       ;;
      Before    | Before\ *   )   control before      "${work#Before}"    ;;
      After     | After\ *    )   control after       "${work#After}"     ;;
      Debug     | Debug\ *    )   control debug       "${work#Debug}"     ;;
      Pending   | Pending\ *  )   control pending     "${work#Pending}"   ;;
      Skip      | Skip\ *     )   skip                "${work#Skip}"      ;;
      Data      | Data\ *     )   data expand         "${work#Data}"      ;;
      Data:raw  | Data:raw\ * )   data raw            "${work#Data:raw}"  ;;
      %text     | %text\ *    )   text_begin expand   "${work#"%text"}"   ;;
      %text:raw | %text:raw\ *)   text_begin raw      "${work#"%text:raw"}"  ;;
      *) putsn "$line" ;;
    esac
    [ "$ABORT" ] && break
    lineno=$(($lineno + 1))
  done
}

is_specfile() {
  case $1 in (*_spec.sh) return 0; esac
  return 1
}

putsn ". \"\$SHELLSPEC_LIB/bootstrap.sh\""
putsn "shellspec_metadata"
each_file() {
  is_specfile "$1" && specfile=$1 || return 0
  escape_quote specfile
  putsn "SHELLSPEC_SPECFILE='$specfile'"
  translate < "$specfile"

  [ "$ABORT" ] && syntax_error "$ABORT"
  [ "$block_no_stack" ] || return 0
  [ "$ABORT" ] || syntax_error "unexpected end of file (expecting 'End')"
  while [ "$block_no_stack" ]; do
    putsn "shellspec_abort"
    block_end ""
  done
}
find_files each_file "$@"
putsn "SHELLSPEC_SPECFILE=\"\""
putsn "shellspec_end"
putsn "# example count: $example_count"

if [ "${SHELLSPEC_TRANS_LOG:-}" ]; then
  putsn "examples $example_count" >> "$SHELLSPEC_TRANS_LOG"
fi
