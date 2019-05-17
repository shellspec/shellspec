#shellcheck shell=sh disable=SC2004,SC2034

buffer finished

finished_end() {
  finished '=' "Finished in ${time_real:-?} seconds" \
    "(user ${time_user:-?} seconds, sys ${time_sys:-?} seconds)${LF}"
}

finished_output() {
  case $1 in (end)
    finished '>>'
  esac
}
