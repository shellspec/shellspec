#shellcheck shell=sh disable=SC2016

Describe "core/matchers.sh"
  Include "$SHELLSPEC_LIB/core/matchers.sh"

  mock() {
    shellspec_matcher__match() { "$1"; }
    shellspec_on() { echo "$@"; }
    shellspec_syntax_dispatch() { echo "$@"; }
  }
  BeforeRun mock

  It "defines a matcher"
    When run shellspec_matcher matcher-name value
    The stdout should eq "matcher matcher-name value"
  End

  Describe 'shellspec_matcher__failure_message()'
    BeforeRun shellspec_matcher

    It 'outputs failure message'
      When run shellspec_matcher__failure_message "failure message"
      The line 2 of stdout should eq "subject: failure message"
    End
  End

  Describe 'shellspec_matcher__failure_message_when_negated()'
    BeforeRun shellspec_matcher

    It 'outputs failure message'
      When run shellspec_matcher__failure_message_when_negated "failure message"
      The line 2 of stdout should eq "subject: failure message"
    End
  End

  Describe 'shellspec_matcher_do_match_positive()'
    BeforeRun shellspec_matcher

    It 'outputs MATCHED when positive'
      When run shellspec_matcher_do_match_positive true
      The line 2 of stdout should eq "MATCHED"
    End

    It 'does not output MATCHED when negative'
      When run shellspec_matcher_do_match_positive false
      The line 2 of stdout should be undefined
    End
  End

  Describe 'shellspec_matcher_do_match_negative()'
    BeforeRun shellspec_matcher

    It 'outputs MATCHED when positive'
      When run shellspec_matcher_do_match_negative true
      The line 2 of stdout should eq "MATCHED"
    End

    It 'does not output MATCHED when negative'
      When run shellspec_matcher_do_match_negative false
      The line 2 of stdout should be undefined
    End
  End

  Describe "shellspec_get_failure_message()"
    mock() {
      unset SHELLSPEC_SUBJECT SHELLSPEC_EXPECT ||:
      shellspec_matcher__failure_message() { echo positive "$@"; }
      shellspec_matcher__failure_message_when_negated () { echo negative "$@"; }
    }
    BeforeRun mock

    Context "when subject and expect are unset"
      It "outputs failure message"
        When run shellspec_get_failure_message positive
        The stdout should equal 'positive <unset> <unset>'
      End

      It "outputs failure message"
        When run shellspec_get_failure_message negative
        The stdout should equal 'negative <unset> <unset>'
      End
    End

    Context "when subject and expect are string"
      BeforeRun SHELLSPEC_SUBJECT="subject" SHELLSPEC_EXPECT="expect"
      It "outputs failure message"
        When run shellspec_get_failure_message positive
        The stdout should equal 'positive "subject" "expect"'
      End

      It "outputs failure message"
        When run shellspec_get_failure_message negative
        The stdout should equal 'negative "subject" "expect"'
      End
    End

    Context "when subject and expect are number"
      BeforeRun SHELLSPEC_SUBJECT=123 SHELLSPEC_EXPECT=456
      It "outputs failure message"
        When run shellspec_get_failure_message positive
        The stdout should equal 'positive 123 456'
      End

      It "outputs failure message"
        When run shellspec_get_failure_message negative
        The stdout should equal 'negative 123 456'
      End
    End
  End
End
