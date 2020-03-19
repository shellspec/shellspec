#shellcheck shell=sh disable=SC2004

shellspec_callback() { eval "SHELLSPEC_ORDINAL_$1=$(($2 - 1))"; }
shellspec_each shellspec_callback \
  zeroth first second third fourth fifth sixth seventh eighth ninth tenth \
  eleventh twelfth thirteenth fourteenth fifteenth \
  sixteenth seventeenth eighteenth nineteenth twentieth

# Reorder words containing 'of' before the verb
#
# example:
#     C c1 c2 of B b1 b2 of A a1 a2 should equal abc
#  => A a1 a2 B b1 b2 C c1 c2 should equal abc
shellspec_statement_preposition() {
  shellspec_work='' shellspec_i=0 shellspec_v=''

  until [ "$shellspec_v" = should ]; do
    shellspec_i=$(($shellspec_i + 1)) && shellspec_j=$shellspec_i

    while :; do
      [ $shellspec_i -gt $# ] && shellspec_i=$shellspec_j && break 2
      eval "shellspec_v=\${$shellspec_i}"
      case $shellspec_v in ( of | should ) break; esac
      shellspec_i=$(($shellspec_i + 1))
    done

    shellspec_k=$shellspec_i
    while [ $shellspec_j -lt $shellspec_k ]; do
      shellspec_k=$(($shellspec_k - 1))
      shellspec_work="\"\${$shellspec_k}\" $shellspec_work"
    done
  done

  while [ $shellspec_i -le $# ]; do
    shellspec_work="$shellspec_work \"\${$shellspec_i}\""
    shellspec_i=$(($shellspec_i + 1))
  done

  eval "set -- $shellspec_work"
  shellspec_statement_ordinal "$@"
}

shellspec_statement_ordinal() {
  shellspec_i=1 shellspec_v='' shellspec_work=''

  while [ $shellspec_i -le $# ]; do
    eval "shellspec_v=\${$shellspec_i}"

    case $shellspec_v in
      should) break ;;
      [0-9]*st|[0-9]*nd|[0-9]*rd|[0-9]*th) shellspec_v=${shellspec_v%??} ;;
      *[!0-9a-zA-Z_]*) shellspec_v='' ;;
      *) eval "shellspec_v=\"\${SHELLSPEC_ORDINAL_$shellspec_v:-}\""
    esac

    [ "$shellspec_v" ] && shellspec_i=$(($shellspec_i + 1))
    shellspec_work="$shellspec_work \"\${$shellspec_i}\" $shellspec_v"
    shellspec_i=$(($shellspec_i + 1))
  done

  while [ $shellspec_i -le $# ]; do
    shellspec_work="$shellspec_work \"\${$shellspec_i}\""
    shellspec_i=$(($shellspec_i + 1))
  done

  eval "set -- $shellspec_work"
  shellspec_statement_subject "$@"
}

shellspec_proxy 'shellspec_statement_subject' 'shellspec_subject'
shellspec_proxy 'shellspec_statement_evaluation' 'shellspec_evaluation'
