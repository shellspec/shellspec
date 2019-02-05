#shellcheck shell=sh disable=SC2004

shellspec_callback() { eval "SHELLSPEC_ORDINAL_$1=$2"; }
shellspec_each shellspec_callback \
  first second third fourth fifth sixth seventh eighth ninth tenth \
  eleventh twelfth thirteenth fourteenth fifteenth \
  sixteenth seventeenth eighteenth nineteenth twentieth

# Move the subject before the verb
#
# example:
#     should equal A the stdout
#  => the stdout should equal A
shellspec_statement_advance_subject() {
  shellspec_work='' shellspec_i=$(($#)) shellspec_j=0

  # Find 'the' position to advance subject
  while [ $shellspec_i -gt 0 ]; do
    eval "shellspec_v=\${$shellspec_i}"
    [ "$shellspec_v" = "the" ] && shellspec_j=$shellspec_i
    # Supports the case where "the" is included in the parameter of the matcher
    # [ "$shellspec_v" = "," ] && shellspec_j=$shellspec_i && break
    shellspec_i=$(($shellspec_i - 1))
  done

  if [ $shellspec_j -eq 0 ]; then
    shellspec_output SYNTAX_ERROR "Not found subjection (missing 'the')"
    shellspec_on FAILED
    return 1
  fi

  shellspec_callback() { shellspec_work="$shellspec_work \"\${$1}\""; }
  shellspec_sequence shellspec_callback $(($shellspec_j + 1)) $#
  shellspec_sequence shellspec_callback 1 $(($shellspec_j - 1))

  eval "set -- $shellspec_work"
  shellspec_statement_preposition "$@"
}

# Reorder words containing 'of' before the verb
#
# example:
#     C c1 c2 of B b1 b2 of A a1 a2 should equal abc
#  => A a1 a2 B b1 b2 C c1 c2 should equal abc
shellspec_statement_preposition() {
  shellspec_work='' shellspec_i=0 shellspec_v=''

  while [ "$shellspec_v" != should ]; do
    shellspec_i=$(($shellspec_i + 1)) && shellspec_j=$shellspec_i

    while :; do
      [ $shellspec_i -gt $# ] && shellspec_i=$shellspec_j && break 2
      eval "shellspec_v=\${$shellspec_i}"
      case $shellspec_v in ( of | should ) break; esac
      shellspec_i=$(($shellspec_i + 1))
    done

    shellspec_callback() { shellspec_work="\"\${$1}\" $shellspec_work"; }
    shellspec_sequence shellspec_callback $(($shellspec_i - 1)) $shellspec_j
  done

  shellspec_callback() { shellspec_work="$shellspec_work \"\${$1}\""; }
  shellspec_sequence shellspec_callback $shellspec_i $#

  eval "set -- $shellspec_work"
  shellspec_statement_ordinal "$@"
}

shellspec_statement_ordinal() {
  shellspec_i=1 shellspec_v='' shellspec_work=''

  while [ $shellspec_i -le $# ]; do
    eval "shellspec_v=\${$shellspec_i}"
    [ "$shellspec_v" = should ] && break

    case $shellspec_v in
      [0-9]*st|[0-9]*nd|[0-9]*rd|[0-9]*th) shellspec_v=${shellspec_v%??} ;;
      *[!0-9a-zA-Z_]*) shellspec_v='' ;;
      *) eval "shellspec_v=\"\${SHELLSPEC_ORDINAL_$shellspec_v:-}\""
    esac

    [ "$shellspec_v" ] && shellspec_i=$(($shellspec_i + 1))
    shellspec_work="$shellspec_work \"\${$shellspec_i}\" $shellspec_v"
    shellspec_i=$(($shellspec_i + 1))
  done

  if [ $shellspec_i -le $# ]; then
    shellspec_callback() { shellspec_work="$shellspec_work \"\${$1}\""; }
    shellspec_sequence shellspec_callback $shellspec_i $#
  fi

  eval "set -- $shellspec_work"
  shellspec_statement_subject "$@"
}

shellspec_proxy 'shellspec_statement_subject' 'shellspec_subject'
shellspec_proxy 'shellspec_statement_evaluation' 'shellspec_evaluation'
