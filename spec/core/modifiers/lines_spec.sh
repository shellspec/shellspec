# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "core/modifiers/lines.sh"
  BeforeRun set_subject modifier_mock

  Describe "lines modifier"
    get_text() {
      echo foo
      echo bar
      echo baz
    }
    Example 'example'
      When call get_text
      The lines of stdout should equal 3
    End

    It 'counts as 2 lines when subject is "foo<LF>bar<LF>" (with last LF)'
      subject() { printf 'foo\nbar\n'; }
      preserve() { %preserve SHELLSPEC_META:META; }
      AfterRun preserve

      When run shellspec_modifier_lines _modifier_
      The stdout should equal 2
      The variable META should eq 'number'
    End

    It 'counts as 2 lines when subject is "foo<LF>bar" (without last LF)'
      subject() { printf 'foo\nbar'; }
      When run shellspec_modifier_lines _modifier_
      The stdout should equal 2
    End

    It 'counts as 3 lines when subject is "foo<LF>bar<LF><LF>"'
      subject() { printf 'foo\nbar\n\n'; }
      When run shellspec_modifier_lines _modifier_
      The stdout should equal 3
    End

    It 'counts as 0 lines when subject is empty string'
      subject() { %- ""; }
      When run shellspec_modifier_lines _modifier_
      The stdout should equal 0
    End

    It 'can not counts lines when subject is undefined'
      subject() { false; }
      When run shellspec_modifier_lines _modifier_
      The status should be failure
    End

    It 'outputs error if next word is missing'
      subject() { printf 'foo\nbar\n'; }
      When run shellspec_modifier_lines
      The stderr should equal SYNTAX_ERROR_DISPATCH_FAILED
    End
  End
End
