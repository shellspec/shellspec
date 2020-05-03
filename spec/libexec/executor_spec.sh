#shellcheck shell=sh

Describe "libexec/executor.sh"
  Include "$SHELLSPEC_LIB/libexec/executor.sh"

  Describe "count_specfiles()"
    Before count=''

    find_specfiles() {
      _callback=$1 && shift
      while [ $# -gt 0 ]; do "$_callback"; shift ; done
    }

    It 'counts specfiles'
      When call count_specfiles count file1 file3 file3
      The variable count should eq 3
    End
  End

  Describe "create_workdirs()"
    mkdir() { printf '%s\n' "$@"; }

    It 'creates workdirs'
      When call create_workdirs 5
      The line 1 of stdout should eq "$SHELLSPEC_TMPBASE/1"
      The line 2 of stdout should eq "$SHELLSPEC_TMPBASE/2"
      The line 3 of stdout should eq "$SHELLSPEC_TMPBASE/3"
      The line 4 of stdout should eq "$SHELLSPEC_TMPBASE/4"
      The line 5 of stdout should eq "$SHELLSPEC_TMPBASE/5"
    End
  End
End
