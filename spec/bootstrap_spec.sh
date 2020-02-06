#shellcheck shell=sh

% SIGNAL: "$SHELLSPEC_TMPBASE/profiler.test"

# This Include do not place inside of Describe. posh fails
Include "$SHELLSPEC_LIB/bootstrap.sh"

Describe 'bootstrap.sh'
  Describe 'shellspec_profile_wait()'
    fake_profiler() {
      (
        while [ ! -s "$SIGNAL" ]; do :; done
        : > "$SIGNAL"
      ) &
    }
    Before fake_profiler
    BeforeCall "SHELLSPEC_PROFILER_SIGNAL='$SIGNAL'"

    It 'waits until signal file is empty'
      When call shellspec_profile_wait
      The file "$SIGNAL" should be empty file
    End
  End
End
