#shellcheck shell=sh disable=SC2154

documentation_last_id=''

create_buffers documentation

require_formatters methods conclusion finished summary references profiler
[ "$SHELLSPEC_KCOV" ] && require_formatters kcov

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
      if [ "$_id" = "$_current_id" ]; then
        until case $_description in (*$VT*) false; esac; do
          _description=${_description#*$VT} _indent="${_indent}  "
        done
      else
        while [ "${_id%%-*}" = "${_current_id%%-*}" ]; do
          _id=${_id#*-} _current_id=${_current_id#*-}
          _description=${_description#*$VT} _indent="${_indent}  "
        done
        until case $_description in (*$VT*) false; esac; do
          documentation '+=' "${_indent}${_description%%$VT*}${LF}"
          _description=${_description#*$VT} _indent="${_indent}  "
        done
      fi

      set -- "${_indent}${field_color}${_description}"
      [ "$example_index" ] && set -- "$@" "($field_note - $example_index)"
      documentation '+=' "${*:-}${RESET}${LF}"
  esac

  documentation_last_id=$_last_id
}

documentation_output() {
  output "$1" methods conclusion finished summary references
  if [ "$SHELLSPEC_KCOV" ]; then output "$1" kcov; fi
  output "$1" profiler
  documentation '>>>'
}
