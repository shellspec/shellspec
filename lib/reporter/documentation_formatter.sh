#shellcheck shell=sh disable=SC2004

: "${example_index:-} ${field_tag:-} ${field_type:-} ${field_note:-}"
: "${field_description:-} ${field_color:-} ${field_message:-}"

documentation_formatter() {
  formatter_begin() {
    methods
    conclusion_begin
    references_begin
    _last_specfile='' _last_id=''
  }

  formatter_format() {
    conclusion_format "$@"
    references_format "$@"

    case $field_tag in
      log) putsn "${field_color}${field_message}${RESET}" ;;
      *)
        [ "$field_type" = "result" ] || return 0
        if [ "$_last_specfile" != "$field_specfile" ]; then
          _last_specfile=$field_specfile _last_id=''
          putsn
        fi
        _id=$_last_id _current_id=$field_id
        _description=$field_description _indent='' _last_id=$field_id
        while [ "${_id%%:*}" = "${_current_id%%:*}" ]; do
          _id=${_id#*:} _current_id=${_current_id#*:}
          _description=${_description#*$VT} _indent="${_indent}  "
        done
        while :; do
          case $_description in (*$VT*) ;; (*) break ;; esac
          putsn "${_indent}${_description%%$VT*}"
          _description=${_description#*$VT} _indent="${_indent}  "
        done

        set -- "${_indent}${field_color}${_description}"
        [ "$example_index" ] && set -- "$@" "(${field_note:-} - $example_index)"
        putsn "$*${RESET}"
    esac
  }

  formatter_end() {
    putsn
    conclusion_end
    finished
    summary
    references_end
  }
}
