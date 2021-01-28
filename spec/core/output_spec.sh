#shellcheck shell=sh

Describe "core/output.sh"
  Include "$SHELLSPEC_LIB/core/output.sh"
  setup() {
    RS="${SHELLSPEC_RS}" US="${SHELLSPEC_US}" ETB="${SHELLSPEC_ETB}"
  }
  Before setup
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
      When run shellspec_output_raw message:foo message:bar
      The stdout should equal "${RS}message:foo${US}message:bar${ETB}"
    End
  End

  Describe "shellspec_output_meta()"
    It "outputs meta type"
      When run shellspec_output_meta shell:sh
      The stdout should equal "${RS}type:meta${US}shell:sh${ETB}"
    End
  End

  Describe "shellspec_output_finished()"
    It "outputs finished type"
      When run shellspec_output_finished
      The stdout should equal "${RS}type:finished${ETB}"
    End
  End

  Describe "shellspec_output_begin()"
    It "outputs begin type"
      When run shellspec_output_begin specfile:test_spec.sh
      The stdout should equal "${RS}type:begin${US}specfile:test_spec.sh${ETB}"
    End
  End

  Describe "shellspec_output_end()"
    It "outputs end type"
      When run shellspec_output_end example_count:1
      The stdout should equal "${RS}type:end${US}example_count:1${ETB}"
    End
  End

  Describe "shellspec_output_statement()"
    It "outputs statement type with SHELLSPEC_LINENO"
      BeforeRun SHELLSPEC_LINENO=1000
      When run shellspec_output_statement tag:foo
      The stdout should equal "${RS}type:statement${US}tag:foo${US}lineno:1000${ETB}"
    End

    It "outputs statement type with SHELLSPEC_LINENO_BEGIN"
      BeforeRun SHELLSPEC_LINENO= SHELLSPEC_LINENO_BEGIN=2000
      When run shellspec_output_statement tag:foo
      The stdout should equal "${RS}type:statement${US}tag:foo${US}lineno:2000${ETB}"
    End
  End

  Describe "shellspec_output_example()"
    It "outputs example type"
      BeforeRun SHELLSPEC_LINENO_BEGIN=100 SHELLSPEC_LINENO_END=200
      When run shellspec_output_example id:1
      The stdout should equal "${RS}type:example${US}id:1${US}lineno_range:100-200${ETB}"
    End
  End

  Describe "shellspec_output_result()"
    It "outputs result type"
      When run shellspec_output_result tag:foo
      The stdout should equal "${RS}type:result${US}tag:foo${ETB}"
    End
  End

  Describe "shellspec_output_error()"
    It "outputs error type"
      When run shellspec_output_error foo
      The stdout should equal "${RS}type:error${US}foo${ETB}"
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
End
