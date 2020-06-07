#shellcheck shell=sh

Describe "core/output.sh"
  Include "$SHELLSPEC_LIB/core/output.sh"
  BeforeRun shellspec_output_buf=''
  BeforeRun SHELLSPEC_OUTPUT_FD=1

  Describe "shellspec_output()"
    shellspec_output_ABC() { echo abc "$@"; }

    It "calls defined message"
      When run shellspec_output ABC 1 2 3
      The stdout should equal 'abc 1 2 3'
    End
  End

  Describe "shellspec_output_raw()"
    It "outputs as report format"
      When run shellspec_output_raw foo bar
      The stdout should equal "${SHELLSPEC_RS}foo${SHELLSPEC_US}bar"
    End
  End

  Describe "shellspec_output_raw_append()"
    It "appends to previous output"
      When run shellspec_output_raw_append baz
      The stdout should equal "${SHELLSPEC_US}baz"
    End
  End

  Describe "shellspec_output_meta()"
    It "outputs meta type"
      When run shellspec_output_meta foo
      The stdout should equal "${SHELLSPEC_RS}type:meta${SHELLSPEC_US}foo"
    End
  End

  Describe "shellspec_output_finished()"
    It "outputs finished type"
      When run shellspec_output_finished foo
      The stdout should equal "${SHELLSPEC_RS}type:finished${SHELLSPEC_US}foo"
    End
  End

  Describe "shellspec_output_begin()"
    It "outputs begin type"
      When run shellspec_output_begin foo
      The stdout should equal "${SHELLSPEC_RS}type:begin${SHELLSPEC_US}foo"
    End
  End

  Describe "shellspec_output_end()"
    It "outputs end type"
      When run shellspec_output_end foo
      The stdout should equal "${SHELLSPEC_RS}type:end${SHELLSPEC_US}foo"
    End
  End

  Describe "shellspec_output_statement()"
    It "outputs statement type with SHELLSPEC_LINENO"
      BeforeRun SHELLSPEC_LINENO=1000
      When run shellspec_output_statement foo
      The stdout should equal "${SHELLSPEC_RS}type:statement${SHELLSPEC_US}foo${SHELLSPEC_US}lineno:1000"
    End

    It "outputs statement type with SHELLSPEC_LINENO_BEGIN"
      BeforeRun SHELLSPEC_LINENO= SHELLSPEC_LINENO_BEGIN=2000
      When run shellspec_output_statement foo
      The stdout should equal "${SHELLSPEC_RS}type:statement${SHELLSPEC_US}foo${SHELLSPEC_US}lineno:2000"
    End
  End

  Describe "shellspec_output_example()"
    It "outputs example type"
      BeforeRun SHELLSPEC_LINENO_BEGIN=100 SHELLSPEC_LINENO_END=200
      When run shellspec_output_example foo
      The stdout should equal "${SHELLSPEC_RS}type:example${SHELLSPEC_US}foo${SHELLSPEC_US}lineno_range:100-200"
    End
  End

  Describe "shellspec_output_result()"
    It "outputs result type"
      When run shellspec_output_result foo
      The stdout should equal "${SHELLSPEC_RS}type:result${SHELLSPEC_US}foo"
    End
  End

  Describe "shellspec_output_if()"
    shellspec_output_IF() { echo "output if"; }

    It "outputs if switch on"
      BeforeRun "shellspec_on IF"
      When run shellspec_output_if IF
      The stdout should equal "output if"
    End

    It "does not output if switch off"
      BeforeRun "shellspec_off IF"
      When run shellspec_output_if IF
      The stdout should equal ""
      The status should be failure
    End
  End

  Describe "shellspec_output_unless()"
    shellspec_output_UNLESS() { echo "output unless"; }

    It "outputs if switch on"
      BeforeRun "shellspec_on UNLESS"
      When run shellspec_output_unless UNLESS
      The stdout should equal ""
      The status should be failure
    End

    It "does not output if switch off"
      BeforeRun "shellspec_off UNLESS"
      When run shellspec_output_unless UNLESS
      The stdout should equal "output unless"
    End
  End

  Describe "shellspec_output_failure_message()"
    shellspec_output_subject() { echo subject; }
    shellspec_output_expect() { echo expect; }
    shellspec_matcher__failure_message() { echo "$@"; }

    It "outputs failure message"
      When run shellspec_output_failure_message
      The stdout should equal "${SHELLSPEC_US}failure_message:subject expect"
    End
  End

  Describe "shellspec_output_failure_message_when_negated()"
    shellspec_output_subject() { echo subject; }
    shellspec_output_expect() { echo expect; }
    shellspec_matcher__failure_message_when_negated () { echo "$@"; }

    It "outputs failure message"
      When run shellspec_output_failure_message_when_negated
      The stdout should equal "${SHELLSPEC_US}failure_message:subject expect"
    End
  End

  Describe "shellspec_output_following_words()"
    set_syntaxes() {
      SHELLSPEC_SYNTAXES=':'
      for i in \
        shellspec_evaluation_call \
        shellspec_matcher_m1 \
        shellspec_matcher_m2 \
        shellspec_matcher_m3 \
        shellspec_matcher_m4 \
        shellspec_matcher_m5 \
        shellspec_matcher_m6 \
        shellspec_matcher_m7 \
        shellspec_matcher_m8 \
        shellspec_matcher_m9 \
        shellspec_modifier
      do
        SHELLSPEC_SYNTAXES="${SHELLSPEC_SYNTAXES}${i}:"
      done
    }
    It "outputs following_words"
      BeforeRun set_syntaxes
      When run shellspec_output_following_words shellspec_matcher
      The line 1 of stdout should equal ""
      The line 2 of stdout should equal "  m1, m2, m3, m4, m5, m6, m7, m8, "
      The line 3 of stdout should equal "  m9"
    End
  End

  Describe "shellspec_output_syntax_name()"
    mock() {
      shellspec_syntax shellspec_syntaxtype_foo_bar_baz
      shellspec_syntaxtype_foo_bar_baz() { :; }
      shellspec_syntax_dispatch syntaxtype foo_bar_baz
    }

    It "outputs syntax name"
      BeforeRun mock
      When run shellspec_output_syntax_name
      The stdout should equal 'foo bar baz syntaxtype'
    End
  End

  Describe "shellspec_output_subject()"
    It "outputs string subject"
      BeforeRun SHELLSPEC_SUBJECT=string
      When run shellspec_output_subject
      The stdout should equal '"string"'
    End

    It "outputs numeric subject"
      BeforeRun SHELLSPEC_SUBJECT=123
      When run shellspec_output_subject
      The stdout should equal '123'
    End

    It "outputs undefined subject"
      BeforeRun "unset SHELLSPEC_SUBJECT ||:"
      When run shellspec_output_subject
      The stdout should equal '<unset>'
    End
  End

  Describe "shellspec_output_expect()"
    It "outputs string expect"
      BeforeRun SHELLSPEC_EXPECT=string
      When run shellspec_output_expect
      The stdout should equal '"string"'
    End

    It "outputs numeric expect"
      BeforeRun SHELLSPEC_EXPECT=123
      When run shellspec_output_expect
      The stdout should equal '123'
    End

    It "outputs undefined expect"
      BeforeRun "unset SHELLSPEC_EXPECT ||:"
      When run shellspec_output_expect
      The stdout should equal '<unset>'
    End
  End
End
