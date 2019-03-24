#shellcheck shell=sh

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture"

Describe "core/matchers/has/stat.sh"
  Before set_subject intercept_shellspec_matcher
  subject() { false; }
  not_exist() { [ ! -e "$FIXTURE/$1" ]; }

  Describe 'has setgid matcher'
    Skip if "not exist setgid file" not_exist 'stat/setgid'

    Example 'example'
      Path target="$FIXTURE/stat/setgid"
      The path target should has setgid
      The path target should has setgid flag
    End

    Context 'when path has setgid flag'
      Def subject "$FIXTURE/stat/setgid"
      It 'matches'
        When invoke shellspec_matcher has setgid
        The status should be success
      End
    End

    Context 'when path does not have setgid flag'
      Def subject "$FIXTURE/file"
      It 'does not match'
        When invoke shellspec_matcher has setgid
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher has setgid foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End

  Describe 'has setuid matcher'
    Skip if "not exist setuid file" not_exist 'stat/setuid'

    Example 'example'
      Path target="$FIXTURE/stat/setuid"
      The path target should has setuid
      The path target should has setuid flag
    End

    Context 'when path has setuid flag'
      Def subject "$FIXTURE/stat/setuid"
      It 'matches'
        When invoke shellspec_matcher has setuid
        The status should be success
      End
    End

    Context 'when path does not have setuid flag'
      Def subject "$FIXTURE/file"
      It 'does not match'
        When invoke shellspec_matcher has setuid
        The status should be failure
      End
    End

    It 'outputs error if parameters count is invalid'
      When invoke shellspec_matcher has setuid foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
      The status should be failure
    End
  End
End
