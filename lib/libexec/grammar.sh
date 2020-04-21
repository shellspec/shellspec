#shellcheck shell=sh disable=SC2004

normal_block="  Describe |  Context |  Example |  Specify |  It"
focused_block="fDescribe | fContext | fExample | fSpecify | fIt"
skipped_block="xDescribe | xContext | xExample | xSpecify | xIt"
end_block="End"
normal_example="  Example |  Specify |  It"
focused_example="fExample | fSpecify | fIt"
skipped_example="xExample | xSpecify | xIt"
oneline_example="Todo"
begin_block="$normal_block | $focused_block | $skipped_block"
block_example="$normal_example | $focused_example | $skipped_example"
example="$block_example | $oneline_example"

define() {
  eval "$1() { case \$1 in ($2) return 0; esac; return 1; }"
}

define is_normal_block "$normal_block"
define is_focused_block "$focused_block"
define is_skipped_block "$skipped_block"
define is_end_block "$end_block"
define is_begin_block "$begin_block"
define is_normal_example "$normal_example"
define is_focused_example "$focused_example"
define is_skipped_example "$skipped_example"
define is_oneline_example "$oneline_example"
define is_block_example "$block_example"
define is_example "$example"

mapping() {
  case $1 in
    Describe          )   block_example_group "$2" ;;
    xDescribe         ) x block_example_group "$2" ;;
    fDescribe         ) f block_example_group "$2" ;;
    Context           )   block_example_group "$2" ;;
    xContext          ) x block_example_group "$2" ;;
    fContext          ) f block_example_group "$2" ;;
    Example           )   block_example       "$2" ;;
    xExample          ) x block_example       "$2" ;;
    fExample          ) f block_example       "$2" ;;
    Specify           )   block_example       "$2" ;;
    xSpecify          ) x block_example       "$2" ;;
    fSpecify          ) f block_example       "$2" ;;
    It                )   block_example       "$2" ;;
    xIt               ) x block_example       "$2" ;;
    fIt               ) f block_example       "$2" ;;
    End               )   block_end           "$2" ;;
    Todo              )   todo                "$2" ;;
    When              )   evaluation when     "$2" ;;
    The               )   expectation the     "$2" ;;
    Path              )   control path        "$2" ;;
    File              )   control path        "$2" ;;
    Dir               )   control path        "$2" ;;
    Before            )   control before      "$2" ;;
    After             )   control after       "$2" ;;
    BeforeCall        )   control before_call "$2" ;;
    AfterCall         )   control after_call  "$2" ;;
    BeforeRun         )   control before_run  "$2" ;;
    AfterRun          )   control after_run   "$2" ;;
    Pending           )   pending             "$2" ;;
    Set               )   control set         "$2" ;;
    Skip              )   skip                "$2" ;;
    Intercept         )   control intercept   "$2" ;;
    Data              )   data raw            "$2" ;;
    Data:raw          )   data raw            "$2" ;;
    Data:expand       )   data expand         "$2" ;;
    Parameters        )   parameters block    "$2" ;;
    Parameters:block  )   parameters block    "$2" ;;
    Parameters:dynamic)   parameters dynamic  "$2" ;;
    Parameters:matrix )   parameters matrix   "$2" ;;
    Parameters:value  )   parameters value    "$2" ;;
    Include           )   include             "$2" ;;
    %text             )   text_begin raw      "$2" ;;
    %text:raw         )   text_begin raw      "$2" ;;
    %text:expand      )   text_begin expand   "$2" ;;
    % | %const        )   constant            "$2" ;;
    %= | %putsn       )   out putsn           "$2" ;;
    %- | %puts        )   out puts            "$2" ;;
    %logger           )   out logger          "$2" ;;
    *)
      case $1 in (*\(\))
        is_function_name "${1%??}" || return 1
        case ${2%%\%*} in (*[!\ \{]*) ;; (*)
          set -- "$1" "${2#"${2%%\%*}"}"
          set -- "$1" "${2%% *}" "${2#* }"
          case $2 in
            %= | %putsn) with_function "$1" out putsn  "$3" ;;
            %- | %puts ) with_function "$1" out puts   "$3" ;;
            %logger    ) with_function "$1" out logger "$3" ;;
            *) return 1
          esac
          return 0
        esac
      esac
      return 1
  esac
}

increase_block_id() {
  [ "$block_id" ] || block_id_increased=1
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
