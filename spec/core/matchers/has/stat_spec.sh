#shellcheck shell=sh

Describe "core/matchers/has/stat.sh"
  setup() { fixture="$SHELLSPEC_SPECDIR/fixture/stat"; }
  Before setup

  not_exist() { setup; [ ! -e "$fixture/$1" ]; }

  Describe 'has setgid matcher'
    Skip if "not exist setgid file" not_exist setgid

    Example 'example'
      Path target="$fixture/setgid"
      The path target should has setgid
      The path target should has setgid flag
    End
  End

  Describe 'has setuid matcher'
    Skip if "not exist setuid file" not_exist setuid

    Example 'example'
      Path target="$fixture/setuid"
      The path target should has setuid
      The path target should has setuid flag
    End
  End
End
