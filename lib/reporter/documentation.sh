#shellcheck shell=sh disable=SC2004

: "${example_index:-} ${field_type:-} ${field_note:-}"
: "${field_description:-} ${field_color:-} ${field_id:-}"

documentation_format() {
  case $field_type in
    meta) putsn ;;
    begin) _last_id='' ;;
    end) [ ! "$_last_id" ] || putsn ;;
    result)
      _id=$_last_id _current_id=$field_id
      _description=$field_description _indent='' _last_id=$field_id
      while [ "${_id%%-*}" = "${_current_id%%-*}" ]; do
        _id=${_id#*-} _current_id=${_current_id#*-}
        _description=${_description#*$VT} _indent="${_indent}  "
      done
      until case $_description in (*$VT*) false; esac; do
        putsn "${_indent}${_description%%$VT*}"
        _description=${_description#*$VT} _indent="${_indent}  "
      done

      set -- "${_indent}${field_color}${_description}"
      [ "$example_index" ] && set -- "$@" "(${field_note:-} - $example_index)"
      putsn "$*${RESET}"
  esac
}
