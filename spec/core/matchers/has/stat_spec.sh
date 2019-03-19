#shellcheck shell=sh

Describe "core/matchers/has/stat.sh"
  readonly fixture="$SHELLSPEC_SPECDIR/fixture/stat"

  not_exist() { [ ! -e "$fixture/$1" ]; }

  Describe 'has setgid matcher'
    Skip if "not exist setgid file" not_exist setgid

    Example 'should has setgid'
      Path target="$fixture/setgid"
      The path target should has setgid
      The path target should has setgid flag
    End
  End

  Describe 'has setuid matcher'
    Skip if "not exist setuid file" not_exist setuid

    Example 'should has setuid'
      Path target="$fixture/setuid"
      The path target should has setuid
      The path target should has setuid flag
    End
  End
End
