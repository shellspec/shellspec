#shellcheck shell=sh disable=SC2004

define_dsl() {
  eval "is_$1() { case \$1 in ($2) return 0; esac; return 1; }"
}

define_dsl normal_block  " Describe |  Context |  Example |  Specify |  It"
define_dsl focused_block "fDescribe | fContext | fExample | fSpecify | fIt"
define_dsl skipped_block "xDescribe | xContext | xExample | xSpecify | xIt"
define_dsl end_block "End"

define_dsl normal_example  " Example |  Specify |  It"
define_dsl focused_example "fExample | fSpecify | fIt"
define_dsl skipped_example "xExample | xSpecify | xIt"
define_dsl oneline_example "Todo"

is_begin_block() {
  is_normal_block "$1" || is_focused_block "$1" || is_skipped_block "$1"
}

is_example() {
  is_block_example "$1" || is_oneline_example "$1"
}

is_block_example() {
  is_normal_example "$1" || is_focused_example "$1" || is_skipped_example "$1"
}

dsl_mapping() {
  case $1 in
    Describe    )   block_example_group "$2" ;;
    xDescribe   ) x block_example_group "$2" ;;
    fDescribe   ) f block_example_group "$2" ;;
    Context     )   block_example_group "$2" ;;
    xContext    ) x block_example_group "$2" ;;
    fContext    ) f block_example_group "$2" ;;
    Example     )   block_example       "$2" ;;
    xExample    ) x block_example       "$2" ;;
    fExample    ) f block_example       "$2" ;;
    Specify     )   block_example       "$2" ;;
    xSpecify    ) x block_example       "$2" ;;
    fSpecify    ) f block_example       "$2" ;;
    It          )   block_example       "$2" ;;
    xIt         ) x block_example       "$2" ;;
    fIt         ) f block_example       "$2" ;;
    End         )   block_end           "$2" ;;
    Todo        )   todo                "$2" ;;
    When        )   statement when      "$2" ;;
    The         )   statement the       "$2" ;;
    Path        )   control path        "$2" ;;
    File        )   control path        "$2" ;;
    Dir         )   control path        "$2" ;;
    Before      )   control before      "$2" ;;
    After       )   control after       "$2" ;;
    Pending     )   control pending     "$2" ;;
    Skip        )   skip                "$2" ;;
    Data        )   data raw            "$2" ;;
    Data:raw    )   data raw            "$2" ;;
    Data:expand )   data expand         "$2" ;;
    Include     )   include             "$2" ;;
    Logger      )   control logger      "$2" ;;
    %text       )   text_begin raw      "$2" ;;
    %text:raw   )   text_begin raw      "$2" ;;
    %text:expand)   text_begin expand   "$2" ;;
    % | %const  )   constant            "$2" ;;
    %= | %putsn )   out putsn           "$2" ;;
    %- | %puts  )   out puts            "$2" ;;
    Error       )   error               "$2" ;;
    *)
      case $1 in (*\(\))
        is_function_name "${1%??}" || return 1
        case ${2%%\%*} in (*[!\ \{]*) ;; (*)
          set -- "$1" "${2#"${2%%\%*}"}"
          set -- "$1" "${2%% *}" "${2#* }"
          case $2 in
            %= | %putsn) with_function "$1" out putsn "$3" ;;
            %- | %puts ) with_function "$1" out puts  "$3" ;;
            *) return 1
          esac
          return 0
        esac
      esac
      return 1
  esac
}
