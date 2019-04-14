#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"

initialize_id() {
  id='' id_state='begin'
}

increasese_id() {
  if [ "$id_state" = "begin" ]; then
    id=$id${id:+:}1
  else
    id_state="begin"
    case $id in
      *:*) id="${id%:*}:$((${id##*:} + 1))" ;;
      *) id=$(($id + 1)) ;;
    esac
  fi
}

decrease_id() {
  [ "$id_state" = "end" ] && id=${id%:*}
  id_state="end"
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

  increasese_id
  block_no=$(($block_no + 1))
  trans block_example_group "$@"
  block_no_stack="$block_no_stack $block_no"
}

block_example() {
  if [ "$inside_of_example" ]; then
    syntax_error "It/Example/Specify/Todo cannot be defined inside of Example"
    return 0
  fi

  increasese_id
  block_no=$(($block_no + 1)) example_no=$(($example_no + 1))
  trans block_example "$@"
  block_no_stack="$block_no_stack $block_no"
  inside_of_example="yes"
}

block_end() {
  if [ -z "$block_no_stack" ]; then
    syntax_error "unexpected 'End'"
    return 0
  fi

  decrease_id
  trans block_end "$@"
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
  trans statement "$@"
}

control() {
  case $1 in (before|after)
    if [ "$inside_of_example" ]; then
      syntax_error "Before/After cannot be defined inside of Example"
      return 0
    fi
  esac
  trans control "$@"
}

skip() {
  skip_id=$(($skip_id + 1))
  trans skip "$@"
}

data() {
  data_line=${2:-}
  trim data_line

  trans data_begin "$@"
  case $data_line in
    '' | '#'* | '|'*)
      trans data_here_begin "$1" "$data_line"
      while IFS= read -r line || [ "$line" ]; do
        lineno=$(($lineno + 1))
        trim line
        case $line in
          '#|'*) trans data_here_line "$line" ;;
          '#'*) ;;
          End | End\ * ) break ;;
          *) syntax_error "Data texts should begin with '#|'"; break ;;
        esac
      done
      trans data_here_end ;;
    "'"* | '"'*) trans data_text "$data_line" ;;
    *) trans data_func "$data_line" ;;
  esac
  trans data_end "$@"
}

text_begin() {
  trans text_begin "$@"
  inside_of_text=1
}

text() {
  case $1 in
    '#|'*) trans text "$@"; return 0 ;;
    *) text_end; return 1 ;;
  esac
}

text_end() {
  trans text_end "$@"
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
    trans constant "$name" "$value"
  else
    syntax_error "Constant name should match pattern [A-Z_][A-Z0-9_]*"
  fi
}

define() {
  line=$1
  trim line
  name="${line%% *}"
  case $line in (*" "*) value="${line#* }" ;; (*) value= ;; esac

  if is_function_name "$name"; then
    trans define "$name" "$value"
  else
    syntax_error "Def name should match pattern [a-zA-Z_][a-zA-Z0-9_]*"
  fi
}

include() {
  if [ "$inside_of_example" ]; then
    syntax_error "Include cannot be defined inside of Example"
    return 0
  fi

  trans include "$@"
}

error() {
  syntax_error "${*:-}"
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
      *) trans line "$line" ;;
    esac
  done
}
