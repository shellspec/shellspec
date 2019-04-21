#!/bin/sh
#shellcheck disable=SC2004

set -eu

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
load grammar

focus='' list=''
for arg in "$@"; do
  case $arg in
    --focus) focus=1 ;;
    --list-specfiles) list=specfiles ;;
    --list-examples) list=examples ;;
    *) set -- "$@" "$arg" ;;
  esac
  shift
done

specfiles=0 count=0
specfile() {
  specfile=$1
  specfiles=$(($specfiles + 1))
  if [ "$list" = "specfiles" ]; then
    echo "$specfile"
  else
    if [ "${2:-}" ]; then
      count_lineno "$2" < "$specfile"
    elif [ "$focus" ]; then
      count_focus < "$specfile"
    else
      count_all < "$specfile"
    fi
  fi
}

count_all() {
  lineno=0
  while read -r line || [ "$line" ]; do
    lineno=$(($lineno + 1))
    if is_example "${line%% *}"; then
      [ "$list" = "examples" ] && echo "$specfile:$lineno"
    else
      continue
    fi
    count=$(($count + 1))
  done
}

count_lineno() {
  lineno=0 block_no=0 block_no_stack='' block=''
  while read -r line || [ "$line" ]; do
    lineno=$(($lineno + 1)) line=${line%% *}

    if is_begin_block "$line"; then
      block_no=$(($block_no + 1))
      block_no_stack="$block_no_stack $block_no"
      eval "block_${block_no}=$lineno"
    fi

    case " $1 " in (*\ $lineno\ *)
      eval "block_${block_no}=\"@ \${block_${block_no}#@ }\""
    esac

    if is_end_block "$line"; then
      no=${block_no_stack##* }
      eval "block_${no}=\"\${block_${no}:-} $lineno\""
      block_no_stack="${block_no_stack% *}"
    fi

    if is_example "$line"; then
      eval "example_$lineno="
    else
      eval "if [ \"\${example_$lineno+x}\" ]; then unset example_$lineno; fi"
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
      [ "$list" = "examples" ] && echo "$specfile:$i"
      count=$(($count + 1))
    fi
    i=$(($i + 1))
  done
}

count_focus() {
  focused='' nest=0 lineno=0
  while read -r line || [ "$line" ]; do
    lineno=$(($lineno + 1))
    line=${line%% *}
    is_focused_block "$line" && focused=1
    [ "$focused" ] || continue
    is_begin_block "$line" && nest=$(($nest + 1))
    if is_example "$line"; then
      [ "$list" = "examples" ] && echo "$specfile:$lineno"
      count=$(($count + 1))
    fi
    is_end_block "$line" && nest=$(($nest - 1))
    [ "$nest" -ne 0 ] || focused=''
  done
}

find_specfiles specfile "$@"

if [ "$list" = "" ]; then
  echo "$specfiles $count"
fi
