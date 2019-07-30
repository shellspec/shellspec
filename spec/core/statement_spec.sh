#shellcheck shell=sh

Describe "core/statement.sh"
  Describe "shellspec_statement_preposition()"
    the() {
      shellspec_statement_ordinal() { echo "the" "$@"; }
      shellspec_statement_preposition "$@"
    }

    It "reorders parameters and calls shellspec_statement_ordinal"
      When run the C c1 c2 of B b1 b2 of A a1 a2 should equal abc
      The stdout should equal "the A a1 a2 B b1 b2 C c1 c2 should equal abc"
    End

    It "does not reorder parameters after 'should'"
      When run the C c1 c2 of B b1 b2 of A a1 a2 should equal E of D
      The stdout should equal "the A a1 a2 B b1 b2 C c1 c2 should equal E of D"
    End
  End

  Describe "shellspec_statement_ordinal()"
    the() {
      shellspec_statement_subject() { echo "the" "$@"; }
      shellspec_statement_ordinal "$@"
    }

    It "changes ordinal number to number and exchange with the next word"
      When run the 2nd line should equal abc
      The stdout should equal "the line 2 should equal abc"
    End

    It "changes ordinal name to number and exchange with the next word"
      When run the second line should equal abc
      The stdout should equal "the line 2 should equal abc"
    End

    It "does not change unknown word"
      When run the "a/b" line should equal abc
      The stdout should equal "the a/b line should equal abc"
    End
  End

  Describe "shellspec_statement_subject()"
    mock() {
      shellspec_subject() { echo "$@"; }
    }

    It "dispatches to shellspec_subject"
      BeforeRun mock
      When run shellspec_statement_subject a b c
      The stdout should equal "a b c"
    End
  End
End
