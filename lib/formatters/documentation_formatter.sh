#shellcheck shell=sh disable=SC2004

: "${example_index:-}" "${field_tag:-}" "${field_type:-}" "${field_note:-}"
: "${field_desc:-}" "${field_color:-}" "${field_message:-}"

documentation_formatter() {
  formatter_results_begin() {
    _indent='' _nest=0 _pos=0 _flushed=''
  }

  formatter_results_format() {
    case $field_tag in
      specfile) _indent='' _nest=0 _pos=0 _flushed='';;
      example_group)
        case $field_type in
          begin)
            _flushed=
            _desc="${_indent}${field_color}${field_desc}${RESET}"
            eval "_descs_$_nest=\$_desc"
            _indent="$_indent  "
            _nest=$(($_nest + 1))
            ;;
          end)
            _indent="${_indent%  }"
            _nest=$(($_nest - 1))
            [ "$_flushed" ] && _pos=$(($_pos - 1))
            eval "unset _descs_$_nest" &&:
            ;;
        esac
    esac

    case $field_type in
      statement)
        [ "$field_tag" = "log" ] || return 0
        putsn "${_indent}${field_color}${field_message}${RESET}"
        ;;
      result)
        [ "$_pos" -eq 0 ] && putsn
        while [ $_pos -lt $_nest ]; do
          eval "_desc=\$_descs_$_pos"
          putsn "$_desc"
          _pos=$(($_pos + 1))
        done
        _flushed=1

        set -- "${_indent}${field_color}${field_desc}"
        [ "$example_index" ] && set -- "$@" "(${field_note:-} - $example_index)"
        putsn "$*${RESET}"
        ;;
    esac
  }

  formatter_results_end() {
    putsn
  }
}
