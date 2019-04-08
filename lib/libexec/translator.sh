#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use constants find_files puts putsn escape_quote trim unixtime
# shellcheck source=lib/libexec/parser.sh
. "${SHELLSPEC_LIB:-./lib}/libexec/parser.sh"

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
