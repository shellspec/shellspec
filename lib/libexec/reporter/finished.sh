#shellcheck shell=sh disable=SC2004,SC2034

buffer finished

finished_end() {
  finished append "Finished in ${time_real:-?} seconds" \
    "(user ${time_user:-?} seconds, sys ${time_sys:-?} seconds)"
}

finished_output() {
  case $1 in
    end) finished output
  esac
}
