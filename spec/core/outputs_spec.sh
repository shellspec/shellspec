#shellcheck shell=sh

Describe "core/outputs.sh"
  Include "$SHELLSPEC_LIB/core/outputs.sh"
  setup() {
    RS="${SHELLSPEC_RS}" US="${SHELLSPEC_US}" ETB="${SHELLSPEC_ETB}" LF="${SHELLSPEC_LF}"
  }
  Before setup

  Describe "shellspec_output_METADATA"
    BeforeRun SHELLSPEC_INFO=info SHELLSPEC_SHELL=shell
    BeforeRun SHELLSPEC_SHELL_TYPE=type SHELLSPEC_SHELL_VERSION=version

    It "outputs METADATA"
      When run shellspec_output_METADATA
      The output should eq "${RS}type:meta${US}info:info${US}shell:shell${US}shell_type:type${US}shell_version:version${ETB}"
    End
  End

  Describe "shellspec_output_FINISHED"
    It "outputs FINISHED"
      When run shellspec_output_FINISHED
      The output should eq "${RS}type:finished${ETB}"
    End
  End

  Describe "shellspec_output_BEGIN"
    BeforeRun SHELLSPEC_SPECFILE=specfile
    It "outputs BEGIN"
      When run shellspec_output_BEGIN
      The output should eq "${RS}type:begin${US}specfile:specfile${ETB}"
    End
  End

  Describe "shellspec_output_END"
    BeforeRun SHELLSPEC_EXAMPLE_COUNT=123
    It "outputs END"
      When run shellspec_output_END
      The output should eq "${RS}type:end${US}example_count:123${ETB}"
    End
  End

  Describe "shellspec_output_EXAMPLE"
    BeforeRun SHELLSPEC_EXAMPLE_ID=id SHELLSPEC_BLOCK_NO=1
    BeforeRun SHELLSPEC_EXAMPLE_NO=2 SHELLSPEC_EXAMPLE_NO=3
    BeforeRun SHELLSPEC_FOCUSED=1 SHELLSPEC_DESCRIPTION=desc
    BeforeRun SHELLSPEC_STDOUT_FILE=stdout SHELLSPEC_STDERR_FILE=stderr
    BeforeRun SHELLSPEC_LINENO_BEGIN=10 SHELLSPEC_LINENO_END=20
    It "outputs EXAMPLE"
      When run shellspec_output_EXAMPLE
      The output should eq "${RS}type:example${US}id:id${US}block_no:1${US}example_no:3${US}focused:1${US}description:desc${US}stdout:stdout${US}stderr:stderr${US}lineno_range:10-20${ETB}"
    End
  End

  Describe "shellspec_output_EVALUATION"
    BeforeRun SHELLSPEC_EVALUATION=evaluation SHELLSPEC_LINENO=123
    It "outputs EVALUATION"
      When run shellspec_output_EVALUATION
      The output should eq "${RS}type:statement${US}tag:evaluation${US}note:${US}fail:${US}evaluation:evaluation${US}lineno:123${ETB}"
    End
  End

  Describe "shellspec_output_SKIP"
    BeforeRun SHELLSPEC_SKIP_ID=12 SHELLSPEC_SKIP_REASON=reason SHELLSPEC_LINENO=123

    Context "when temporary skip"
      mock() { shellspec_is_temporary_skip() { true; }; }
      BeforeRun mock

      It "outputs SKIP"
        When run shellspec_output_SKIP
        The output should eq "${RS}type:statement${US}tag:skip${US}note:SKIPPED${US}fail:${US}skipid:12${US}temporary:y${US}message:reason${US}lineno:123${ETB}"
      End
    End

    Context "when temporary skip and no reason"
      mock() { shellspec_is_temporary_skip() { true; }; }
      BeforeRun mock SHELLSPEC_SKIP_REASON=""

      It "outputs SKIP"
        When run shellspec_output_SKIP
        The output should eq "${RS}type:statement${US}tag:skip${US}note:SKIPPED${US}fail:${US}skipid:12${US}temporary:y${US}message:# Temporarily skipped${US}lineno:123${ETB}"
      End
    End

    Context "when not temporary skip"
      mock() { shellspec_is_temporary_skip() { false; }; }
      BeforeRun mock

      It "outputs SKIP"
        When run shellspec_output_SKIP
        The output should eq "${RS}type:statement${US}tag:skip${US}note:SKIPPED${US}fail:${US}skipid:12${US}temporary:${US}message:reason${US}lineno:123${ETB}"
      End
    End
  End

  Describe "shellspec_output_PENDING"
    BeforeRun SHELLSPEC_PENDING_REASON=reason SHELLSPEC_LINENO=123

    Context "when temporary skip"
      mock() { shellspec_is_temporary_pending() { true; }; }
      BeforeRun mock

      It "outputs PENDING"
        When run shellspec_output_PENDING
        The output should eq "${RS}type:statement${US}tag:pending${US}note:PENDING${US}fail:${US}pending:y${US}temporary:y${US}message:reason${US}lineno:123${ETB}"
      End
    End

    Context "when temporary skip and no reason"
      mock() { shellspec_is_temporary_pending() { true; }; }
      BeforeRun mock SHELLSPEC_PENDING_REASON=""

      It "outputs PENDING"
        When run shellspec_output_PENDING
        The output should eq "${RS}type:statement${US}tag:pending${US}note:PENDING${US}fail:${US}pending:y${US}temporary:y${US}message:# Temporarily pended${US}lineno:123${ETB}"
      End
    End

    Context "when not temporary skip"
      mock() {
        shellspec_is_temporary_pending() { false; }
      }
      BeforeRun mock

      It "outputs PENDING"
        When run shellspec_output_PENDING
        The output should eq "${RS}type:statement${US}tag:pending${US}note:PENDING${US}fail:${US}pending:y${US}temporary:${US}message:reason${US}lineno:123${ETB}"
      End
    End
  End

  Describe "shellspec_output_NOT_IMPLEMENTED"
    BeforeRun SHELLSPEC_PENDING_REASON=reson SHELLSPEC_LINENO=123
    It "outputs NOT_IMPLEMENTED"
      When run shellspec_output_NOT_IMPLEMENTED
      The output should eq "${RS}type:statement${US}tag:pending${US}note:PENDING${US}fail:${US}pending:y${US}temporary:${US}message:reson${US}lineno:123${ETB}"
    End
  End

  Describe "shellspec_output_NO_EXPECTATION"
    BeforeRun SHELLSPEC_LINENO=123

    Context 'when not specified waring as failure'
      BeforeRun SHELLSPEC_WARNING_AS_FAILURE=''
      It "outputs NO_EXPECTATION"
        When run shellspec_output_NO_EXPECTATION
        The output should eq "${RS}type:statement${US}tag:warn${US}note:WARNING${US}fail:${US}message:Not found any expectation${US}failure_message:${US}lineno:123${ETB}"
      End
    End

    Context 'when specified waring as failure'
      BeforeRun SHELLSPEC_WARNING_AS_FAILURE=1
      It "outputs NO_EXPECTATION"
        When run shellspec_output_NO_EXPECTATION
        The output should eq "${RS}type:statement${US}tag:warn${US}note:WARNING${US}fail:y${US}message:Not found any expectation${US}failure_message:${US}lineno:123${ETB}"
      End
    End
  End

  Describe "shellspec_output_UNHANDLED_STATUS"
    BeforeRun SHELLSPEC_LINENO_BEGIN=100 SHELLSPEC_LINENO_END=200 SHELLSPEC_STATUS=12

    Context 'when not specified waring as failure'
      BeforeRun SHELLSPEC_WARNING_AS_FAILURE=''
      It "outputs UNHANDLED_STATUS"
        When run shellspec_output_UNHANDLED_STATUS
        The output should eq "${RS}type:statement${US}tag:warn${US}note:WARNING${US}fail:${US}message:It exits with status non-zero but not found expectation${US}failure_message:status:12${LF}${US}lineno:100-200${ETB}"
      End
    End

    Context 'when specified waring as failure'
      BeforeRun SHELLSPEC_WARNING_AS_FAILURE=1
      It "outputs UNHANDLED_STATUS"
        When run shellspec_output_UNHANDLED_STATUS
        The output should eq "${RS}type:statement${US}tag:warn${US}note:WARNING${US}fail:y${US}message:It exits with status non-zero but not found expectation${US}failure_message:status:12${LF}${US}lineno:100-200${ETB}"
      End
    End
  End

  Describe "shellspec_output_UNHANDLED_STDOUT"
    mock() { shellspec_head() { eval "$1=stdout"; }; }
    BeforeRun mock SHELLSPEC_LINENO_BEGIN=100 SHELLSPEC_LINENO_END=200

    Context 'when not specified waring as failure'
      BeforeRun SHELLSPEC_WARNING_AS_FAILURE=''
      It "outputs UNHANDLED_STATUS"
        When run shellspec_output_UNHANDLED_STDOUT
        The output should eq "${RS}type:statement${US}tag:warn${US}note:WARNING${US}fail:${US}message:There was output to stdout but not found expectation${US}failure_message:stdout:stdout${LF}${US}lineno:100-200${ETB}"
      End
    End

    Context 'when specified waring as failure'
      BeforeRun SHELLSPEC_WARNING_AS_FAILURE=1
      It "outputs UNHANDLED_STATUS"
        When run shellspec_output_UNHANDLED_STDOUT
        The output should eq "${RS}type:statement${US}tag:warn${US}note:WARNING${US}fail:y${US}message:There was output to stdout but not found expectation${US}failure_message:stdout:stdout${LF}${US}lineno:100-200${ETB}"
      End
    End
  End

  Describe "shellspec_output_UNHANDLED_STDERR"
    mock() { shellspec_head() { eval "$1=stderr"; }; }
    BeforeRun mock SHELLSPEC_LINENO_BEGIN=100 SHELLSPEC_LINENO_END=200

    Context 'when not specified waring as failure'
      BeforeRun SHELLSPEC_WARNING_AS_FAILURE=''
      It "outputs UNHANDLED_STATUS"
        When run shellspec_output_UNHANDLED_STDERR
        The output should eq "${RS}type:statement${US}tag:warn${US}note:WARNING${US}fail:${US}message:There was output to stderr but not found expectation${US}failure_message:stderr:stderr${LF}${US}lineno:100-200${ETB}"
      End
    End

    Context 'when specified waring as failure'
      BeforeRun SHELLSPEC_WARNING_AS_FAILURE=1
      It "outputs UNHANDLED_STATUS"
        When run shellspec_output_UNHANDLED_STDERR
        The output should eq "${RS}type:statement${US}tag:warn${US}note:WARNING${US}fail:y${US}message:There was output to stderr but not found expectation${US}failure_message:stderr:stderr${LF}${US}lineno:100-200${ETB}"
      End
    End
  End
End
