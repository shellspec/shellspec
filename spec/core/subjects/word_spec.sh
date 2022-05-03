# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "core/subjects/word.sh"
  BeforeRun set_stdout subject_mock

  Describe "word subject"
    Example 'example'
      foobarbaz() { echo "foo bar"; echo "baz"; }
      When call foobarbaz
      The word 3 should equal "baz"
      The word 4 should be undefined
    End

    It "gets specified word of stdout when stdout is defined"
      stdout() { echo "word1 word2"; echo "word3"; }
      preserve() { %preserve SHELLSPEC_META:META; }
      AfterRun preserve

      When run shellspec_subject_word 3 _modifier_
      The stdout should equal 'word3'
      The variable META should eq 'text'
    End

    It "gets undefined when stdout is undefined"
      stdout() { false; }
      When run shellspec_subject_word 1 _modifier_
      The status should be failure
    End
  End
End
