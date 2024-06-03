#shellcheck shell=sh disable=SC2154

create_buffers finished

finished_end() {
  finished '=' "Finished in ${time_real:-?} seconds" \
    "(user: ${time_user:-n/a}${time_user:+s}," \
    "sys: ${time_sys:-n/a}${time_sys:+s})" \
    "[time: ${time_type:-not-available}]${LF}"
}

finished_output() {
  case $1 in (end)
    finished '>>>'
  esac
}
