#shellcheck shell=sh disable=SC2004

: "${example_index:-} ${field_type:-} ${field_note:-}"
: "${field_description:-} ${field_color:-} ${field_id:-}"

documentation_last_id=''
buffer documentation

documentation_format() {
  _id='' _current_id='' _description='' _indent=''
  _last_id=$documentation_last_id
  documentation clear

  case $field_type in
    meta) documentation_append ;;
    begin) _last_id='' ;;
    end) [ ! "$_last_id" ] || documentation_append ;;
    result)
      _id=$_last_id _current_id=$field_id
      _description=$field_description _indent='' _last_id=$field_id
      while [ "${_id%%-*}" = "${_current_id%%-*}" ]; do
        _id=${_id#*-} _current_id=${_current_id#*-}
        _description=${_description#*$VT} _indent="${_indent}  "
      done
      until case $_description in (*$VT*) false; esac; do
        documentation_append "${_indent}${_description%%$VT*}"
        _description=${_description#*$VT} _indent="${_indent}  "
      done

      set -- "${_indent}${field_color}${_description}"
      [ "$example_index" ] && set -- "$@" "($field_note - $example_index)"
      documentation_append "$*${RESET}"
  esac

  documentation_last_id=$_last_id
}

documentation_output() {
  case $1 in
    format)
      methods_output format
      documentation_puts ;;
    end)
      documentation_puts
      conclusion_output end
      finished_output end
      summary_output end
      references_output end
      ;;
  esac
}
