#shellcheck shell=sh

% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "core/matchers/has/stat.sh"
  BeforeRun set_subject matcher_mock

  not_exist() { [ ! -e "$FIXTURE/$1" ]; }

  Describe 'has setgid matcher'
    Skip if "not exist setgid file" not_exist 'stat/setgid'
    Skip if "busybox-w32 not supported" busybox_w32

    Example 'example'
      Path target="$FIXTURE/stat/setgid"
      The path target should has setgid
      The path target should has setgid flag
    End

    It 'matches when path has setgid flag'
      subject() { %- "$FIXTURE/stat/setgid"; }
      When run shellspec_matcher_has_setgid
      The status should be success
    End

    It 'does not match when path does not have setgid flag'
      subject() { %- "$FIXTURE/file"; }
      When run shellspec_matcher_has_setgid
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/stat/setgid"; }
      When run shellspec_matcher_has_setgid foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End

  Describe 'has setuid matcher'
    Skip if "not exist setuid file" not_exist 'stat/setuid'
    Skip if "busybox-w32 not supported" busybox_w32

    Example 'example'
      Path target="$FIXTURE/stat/setuid"
      The path target should has setuid
      The path target should has setuid flag
    End

    It 'matches when path has setuid flag'
      subject() { %- "$FIXTURE/stat/setuid"; }
      When run shellspec_matcher_has_setuid
      The status should be success
    End

    It 'does not match when path does not have setuid flag'
      subject() { %- "$FIXTURE/file"; }
      When run shellspec_matcher_has_setuid
      The status should be failure
    End

    It 'outputs error if parameters count is invalid'
      subject() { %- "$FIXTURE/stat/setuid"; }
      When run shellspec_matcher_has_setuid foo
      The stderr should equal SYNTAX_ERROR_WRONG_PARAMETER_COUNT
    End
  End
End
