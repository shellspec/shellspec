#shellcheck shell=sh disable=SC2004

: "${count_examples:-} ${aborted:-}"
: "${field_type:-} ${field_tag:-} ${field_description:-} ${field_message:-}"

tap_no=0
buffer tap

tap_initialize() {
  count "$@"
}

tap_begin() {
  tap '=' "1..${count_examples}${LF}"
}

tap_each() {
  _no=$tap_no _description=''
  tap '='

  case $field_type in (result)
    _no=$(($_no + 1)) _description=$(field_description)
    case $field_tag in
      succeeded) tap '=' "ok"     "$_no - ${_description}${LF}" ;;
      warned   ) tap '=' "ok"     "$_no - ${_description}${LF}" ;;
      failed   ) tap '=' "not ok" "$_no - ${_description}${LF}" ;;
      skipped  ) tap '=' "ok"     "$_no - ${_description} # skip${LF}" ;;
      todo     ) tap '=' "ok"     "$_no - ${_description} # pending${LF}" ;;
      fixed    ) tap '=' "not ok" "$_no - ${_description} # fixed${LF}" ;;
    esac
  esac

  tap_no=$_no
}

tap_end() {
  [ "$aborted" ] || return 0
  tap '=' "not ok $(($count_examples + 1)) - aborted by unexpected error${LF}"
}

tap_output() {
  case $1 in (begin | each | end )
    tap '>>'
  esac
}
