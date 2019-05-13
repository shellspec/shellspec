#shellcheck shell=sh disable=SC2004,SC2034

finished_end() {
  putsn "Finished in ${time_real:-?} seconds" \
    "(user ${time_user:-?} seconds, sys ${time_sys:-?} seconds)"
}
