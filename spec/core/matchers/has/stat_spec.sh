#shellcheck shell=sh

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture/stat"

Describe "core/matchers/has/stat.sh"
  not_exist() { [ ! -e "$FIXTURE/$1" ]; }

  Describe 'has setgid matcher'
    Skip if "not exist setgid file" not_exist setgid

    Example 'should has setgid'
      Path target="$FIXTURE/setgid"
      The path target should has setgid
      The path target should has setgid flag
    End
  End

  Describe 'has setuid matcher'
    Skip if "not exist setuid file" not_exist setuid

    Example 'should has setuid'
      Path target="$FIXTURE/setuid"
      The path target should has setuid
      The path target should has setuid flag
    End
  End
End
