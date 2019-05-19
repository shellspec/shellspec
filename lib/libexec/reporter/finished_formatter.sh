#shellcheck shell=sh

create_buffers finished

finished_end() {
  finished '=' "Finished in ${time_real:-?} seconds" \
    "(user ${time_user:-?} seconds, sys ${time_sys:-?} seconds)${LF}"
}

finished_output() {
  finished '>>>'
}
