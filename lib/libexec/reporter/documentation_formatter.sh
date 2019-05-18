#shellcheck shell=sh

: "${example_index:-} ${field_type:-} ${field_note:-}"
: "${field_description:-} ${field_color:-} ${field_id:-}"

documentation_last_id=''
buffer documentation

require_formatters methods conclusion finished summary references

documentation_each() {
  _id='' _current_id='' _description='' _indent=''
  _last_id=$documentation_last_id
  documentation '='

  case $field_type in
    meta) documentation '+=' "${LF}" ;;
    begin) _last_id='' ;;
    end) [ ! "$_last_id" ] || documentation '+=' "${LF}" ;;
    result)
      _id=$_last_id _current_id=$field_id
      _description=$field_description _indent='' _last_id=$field_id
      while [ "${_id%%-*}" = "${_current_id%%-*}" ]; do
        _id=${_id#*-} _current_id=${_current_id#*-}
        _description=${_description#*$VT} _indent="${_indent}  "
      done
      until case $_description in (*$VT*) false; esac; do
        documentation '+=' "${_indent}${_description%%$VT*}${LF}"
        _description=${_description#*$VT} _indent="${_indent}  "
      done

      set -- "${_indent}${field_color}${_description}"
      [ "$example_index" ] && set -- "$@" "($field_note - $example_index)"
      documentation '+=' "${*:-}${RESET}${LF}"
  esac

  documentation_last_id=$_last_id
}

documentation_output() {
  output "$1" methods conclusion finished summary references
  case $1 in (each)
    documentation '>>'
  esac
}
