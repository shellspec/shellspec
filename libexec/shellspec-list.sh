#!/bin/sh
#shellcheck disable=SC2004

set -eu

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use trim
load grammar

specfiles=0 count=0
specfile() {
  specfile=$1 specfiles=$(($specfiles + 1))
  if [ "${SHELLSPEC_LIST:-}" = "specfiles" ]; then
    echo "$specfile"
  else
    if [ "${2:-}" ]; then
      count_lineno "$2" < "$specfile"
    elif [ "${SHELLSPEC_FOCUS:-}" ]; then
      count_focus < "$specfile"
    else
      count_all < "$specfile"
    fi
  fi
}

count_all() {
  lineno=0 example_id=''
  while IFS= read -r line || [ "$line" ]; do
    trim line
    line=${line%% *} lineno=$(($lineno + 1))
    is_begin_block "$line" && increase_example_id
    is_end_block "$line" && decrease_example_id
    is_example "$line" || continue
    case ${SHELLSPEC_LIST:-} in
      examples:id) echo "$specfile@$example_id" ;;
      examples:lineno) echo "$specfile:$lineno" ;;
    esac
    count=$(($count + 1))
  done
}

count_lineno() {
  lineno=0 block_no=0 block_no_stack='' block='' example_id=''
  while IFS= read -r line || [ "$line" ]; do
    trim line
    lineno=$(($lineno + 1)) line=${line%% *}

    if is_begin_block "$line"; then
      increase_example_id
      block_no=$(($block_no + 1))
      block_no_stack="$block_no_stack $block_no"
      eval "block_${block_no}=$lineno"
    fi

    case " $1 " in (*\ $lineno\ *)
      eval "block_${block_no}=\"@ \${block_${block_no}#@ }\""
    esac

    if is_end_block "$line"; then
      decrease_example_id
      no=${block_no_stack##* }
      eval "block_${no}=\"\${block_${no}:-} $lineno\""
      block_no_stack="${block_no_stack% *}"
    fi

    if is_example "$line"; then
      eval "example_$lineno="
      eval "example_id_$lineno=\$example_id"
    else
      eval "unset example_$lineno example_id_$lineno ||:"
    fi
  done

  i=1
  while [ $i -le $block_no ]; do
    eval "block=\${block_$i:-}"
    case $block in (@*)
      range=${block#@ }
      j=${range% *}
      range=${range#* }
      while [ "$j" -le "$range" ]; do
        eval "if [ \"\${example_$j+x}\" ]; then example_$j=1; fi"
        j=$(($j + 1))
      done
    esac
    i=$(($i + 1))
  done

  i=1
  while [ $i -le $lineno ]; do
    if eval "[ \"\${example_$i:-}\" ]"; then
      case ${SHELLSPEC_LIST:-} in
        examples:id) eval echo "\$specfile@\$example_id_$i" ;;
        examples:lineno) echo "$specfile:$i" ;;
      esac
      count=$(($count + 1))
    fi
    i=$(($i + 1))
  done
}

count_focus() {
  focused='' nest=0 lineno=0 example_id=''
  while IFS= read -r line || [ "$line" ]; do
    trim line
    lineno=$(($lineno + 1))
    line=${line%% *}
    is_begin_block "$line" && increase_example_id
    is_end_block "$line" && decrease_example_id
    is_focused_block "$line" && focused=1
    [ "$focused" ] || continue
    is_begin_block "$line" && nest=$(($nest + 1))
    if is_example "$line"; then
      case ${SHELLSPEC_LIST:-} in
        examples:id) echo "$specfile@$example_id" ;;
        examples:lineno) echo "$specfile:$lineno" ;;
      esac
      count=$(($count + 1))
    fi
    is_end_block "$line" && nest=$(($nest - 1))
    [ "$nest" -ne 0 ] || focused=''
  done
}

find_specfiles specfile "$@"

[ "${SHELLSPEC_LIST:-}" ] || echo "$specfiles $count"
