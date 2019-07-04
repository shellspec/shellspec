#shellcheck shell=sh

Describe "core/dsl.sh"
  Describe "shellspec_example_group()"
    shellspec_around_invoke() {
      shellspec_output() { echo "$1"; }
      shellspec_yield() { echo 'yield'; }
      "$@"
    }
    It 'calls yield block'
      When invoke shellspec_example_group
      The stdout should include 'yield'
    End
  End

  Describe "shellspec_invoke_example()"
    prepare() { :; }
    shellspec_around_invoke() {
      prepare
      shellspec_output() { echo "$1"; }
      shellspec_yield() { echo yield; }
      if [ "${2:-}" ]; then
        eval "shellspec_yield() {
          echo yield
          shellspec_off NOT_IMPLEMENTED
          $2
        }"
      fi
      "$@"
    }

    It 'skippes the all if skipped outside of example'
      prepare() { shellspec_on SKIP; }
      block() { :; }
      When invoke shellspec_invoke_example block
      The stdout should not include 'yield'
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'SKIP'
      The stdout line 3 should equal 'SKIPPED'
    End

    It 'skipps the rest if skipped inside of example'
      block() { shellspec_skip 1; }
      When invoke shellspec_invoke_example block
      The stdout should include 'yield'
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'SKIP'
      The stdout line 4 should equal 'SKIPPED'
    End

    It 'is fail if failed before skipping'
      block() { shellspec_on FAILED; shellspec_skip 1; }
      When invoke shellspec_invoke_example block
      The stdout should include 'yield'
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'SKIP'
      The stdout line 4 should equal 'FAILED'
    End

    It 'is unimplemented if there is nothing inside of example'
      When invoke shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'NOT_IMPLEMENTED'
      The stdout line 4 should equal 'TODO'
    End

    It 'is failed if FAILED switch is on'
      block() { shellspec_on FAILED; }
      When invoke shellspec_invoke_example block
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'FAILED'
    End

    It 'is warned and be status unhandled if UNHANDLED_STATUS switch is on'
      block() { shellspec_on UNHANDLED_STATUS; }
      When invoke shellspec_invoke_example block
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'UNHANDLED_STATUS'
      The stdout line 4 should equal 'WARNED'
    End

    It 'is warned and be stdout unhandled if UNHANDLED_STDOUT switch is on'
      block() { shellspec_on UNHANDLED_STDOUT; }
      When invoke shellspec_invoke_example block
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'UNHANDLED_STDOUT'
      The stdout line 4 should equal 'WARNED'
    End

    It 'is warned and be stderr unhandled if UNHANDLED_STDOUT switch is on'
      block() { shellspec_on UNHANDLED_STDERR; }
      When invoke shellspec_invoke_example block
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'UNHANDLED_STDERR'
      The stdout line 4 should equal 'WARNED'
    End

    It 'is success if example ends successfully'
      block() { :; }
      When invoke shellspec_invoke_example block
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'SUCCEEDED'
    End

    It 'is todo if FAILED and PENDING switch is on'
      block() { shellspec_on FAILED PENDING; }
      When invoke shellspec_invoke_example block
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'TODO'
    End

    It 'is fixed if PENDING switch is on but not FAILED'
      block() { shellspec_on PENDING; }
      When invoke shellspec_invoke_example block
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'FIXED'
    End
  End

  Describe "shellspec_when()"
    prepare() { :; }
    shellspec_around_invoke() {
      shellspec_off EVALUATION EXPECTATION
      shellspec_on NOT_IMPLEMENTED
      prepare
      shellspec_output() { echo "output:$1"; }
      shellspec_statement_evaluation() { :; }
      shellspec_on() { echo "on:$*"; }
      shellspec_off() { echo "off:$*"; }
      "$@"
    }

    Context 'when evaluation runs successfully'
      It 'turns off the NOT_IMPLEMENTED switch'
        When invoke shellspec_when call true
        The stdout should include 'off:NOT_IMPLEMENTED'
      End

      It 'turns on the EVALUATION switch'
        When invoke shellspec_when call true
        The stdout should include 'on:EVALUATION'
      End

      It 'outputs EVALUATION'
        When invoke shellspec_when call true
        The stdout should include 'output:EVALUATION'
      End
    End

    Context 'when evaluation type missing'
      It 'turns off the NOT_IMPLEMENTED switch'
        When invoke shellspec_when
        The stdout should include 'off:NOT_IMPLEMENTED'
      End

      It 'turns on the EVALUATION switch'
        When invoke shellspec_when
        The stdout should include 'on:EVALUATION'
      End

      It 'turns on the FAILED switch'
        When invoke shellspec_when
        The stdout should include 'on:FAILED'
      End

      It 'outputs SYNTAX_ERROR'
        When invoke shellspec_when
        The stdout should include 'output:SYNTAX_ERROR'
      End
    End

    Context 'when already executed evaluation'
      prepare() { shellspec_on EVALUATION; }
      It 'is syntax error'
        When invoke shellspec_when call true
        The stdout line 1 should equal 'off:NOT_IMPLEMENTED'
        The stdout line 2 should equal 'output:SYNTAX_ERROR_EVALUATION'
        The stdout line 3 should equal 'on:FAILED'
      End
    End

    Context 'when already executed expectation'
      prepare() { shellspec_on EXPECTATION; }

      It 'turns off the NOT_IMPLEMENTED switch'
        When invoke shellspec_when
        The stdout should include 'off:NOT_IMPLEMENTED'
      End

      It 'turns on the EVALUATION switch'
        When invoke shellspec_when
        The stdout should include 'on:EVALUATION'
      End

      It 'turns on the FAILED switch'
        When invoke shellspec_when
        The stdout should include 'on:FAILED'
      End

      It 'outputs SYNTAX_ERROR'
        When invoke shellspec_when
        The stdout should include 'output:SYNTAX_ERROR'
      End
    End
  End

  Describe "shellspec_statement()"
    prepare() { :; }
    shellspec_around_invoke() {
      prepare
      "$@"
      shellspec_if SYNTAX_ERROR && echo 'SYNTAX_ERROR:on' || echo 'SYNTAX_ERROR:off'
      shellspec_if FAILED && echo 'FAILED:on' || echo 'FAILED:off'
    }

    Context 'when execute statement exit normally'
      shellspec__statement_() { echo 'called'; }

      It 'turns off the SYNTAX_ERROR switch'
        When invoke shellspec_statement _statement_ dummy
        The stdout should include 'SYNTAX_ERROR:off'
      End

      It 'turns off the FAILED switch'
        When invoke shellspec_statement _statement_ dummy
        The stdout should include 'FAILED:off'
      End

      It 'calls specified statement'
        When invoke shellspec_statement _statement_ dummy
        The stdout should include 'called'
      End
    End

    Context 'when execute statement is syntax error'
      shellspec__statement_() { shellspec_on SYNTAX_ERROR; }

      It 'turns on the SYNTAX_ERROR switch'
        When invoke shellspec_statement _statement_ dummy
        The stdout should include 'SYNTAX_ERROR:on'
      End

      It 'turns on the FAILED switch'
        When invoke shellspec_statement _statement_ dummy
        The stdout should include 'FAILED:on'
      End

      It 'does not call specified statement'
        When invoke shellspec_statement _statement_ dummy
        The stdout should not include 'called'
      End
    End

    Context 'when already skipped'
      shellspec__statement_() { echo 'called'; }
      prepare() { shellspec_on SKIP; }

      It 'does not call specified statement'
        When invoke shellspec_statement _statement_ dummy
        The stdout should not include 'called'
      End
    End
  End

  Describe "shellspec_the()"
    shellspec_around_invoke() {
      shellspec_on NOT_IMPLEMENTED
      shellspec_statement_preposition() { :; }
      shellspec_on() { echo "on:$*"; }
      shellspec_off() { echo "off:$*"; }
      "$@"
    }

    It 'turns off the NOT_IMPLEMENTED switch'
      When invoke shellspec_the dummy
      The stdout should include 'off:NOT_IMPLEMENTED'
    End

    It 'turns on the EXPECTATION switch'
      When invoke shellspec_the dummy
      The stdout should include 'on:EXPECTATION'
    End
  End

  Describe "shellspec_skip()"
    example_no() { SHELLSPEC_EXAMPLE_NO=1; }
    prepare() { :; }
    shellspec_around_invoke() {
      example_no
      prepare
      shellspec_output() { echo "output:$1"; }
      "$@"
      shellspec_if SKIP && echo 'SKIP:on' || echo 'SKIP:off'
      echo "skip_id:${SHELLSPEC_SKIP_ID-[unset]}"
      echo "skip_reason:${SHELLSPEC_SKIP_REASON-[unset]}"
      echo "example_no:${SHELLSPEC_EXAMPLE_NO-[unset]}"
    }

    Context 'when inside of example'
      It 'outputs SKIP'
        When invoke shellspec_skip 123 "reason"
        The stdout should include 'output:SKIP'
      End

      It 'turns on the SKIP switch'
        When invoke shellspec_skip 123 "reason"
        The stdout should include 'SKIP:on'
      End

      It 'sets skip related variables'
        When invoke shellspec_skip 123 "reason"
        The stdout should include 'skip_id:123'
        The stdout should include 'skip_reason:reason'
        The stdout should include 'example_no:1'
      End
    End

    Context 'when outside of example'
      example_no() { SHELLSPEC_EXAMPLE_NO=; }

      It 'does not output SKIP'
        When invoke shellspec_skip 123 "skip reason"
        The stdout line 1 should equal 'SKIP:on'
      End
    End

    Context 'when already skipped'
      prepare() { shellspec_on SKIP; }

      It 'does not output SKIP'
        When invoke shellspec_skip 123 "skip reason"
        The stdout should not include 'output:SKIP'
      End

      It 'turns on the SKIP switch'
        When invoke shellspec_skip 123 "skip reason"
        The stdout should include 'SKIP:on'
      End

      It 'sets skip related variables'
        When invoke shellspec_skip 123 "skip reason"
        The stdout should include 'skip_id:[unset]'
        The stdout should include 'skip_reason:[unset]'
        The stdout should include 'example_no:1'
      End
    End

    Describe "with conditional"
      Context 'when satisfy condition'
        It 'outputs SKIP'
          When invoke shellspec_skip 123 if "reason" true
          The stdout should include 'output:SKIP'
        End

        It 'turns on the SKIP switch'
          When invoke shellspec_skip 123 "skip reason"
          The stdout should include 'SKIP:on'
        End
      End

      Context 'when not satisfy condition'
        It 'does not outputs SKIP'
          When invoke shellspec_skip 123 if "reason" false
          The stdout should include 'SKIP:off'
        End

        It 'turns off the SKIP switch'
          When invoke shellspec_skip 123 if "reason" false
          The stdout should include 'SKIP:off'
        End
      End
    End
  End

  Describe "shellspec_pending()"
    example_no() { SHELLSPEC_EXAMPLE_NO=1; }
    prepare() { :; }
    shellspec_around_invoke() {
      example_no
      prepare
      shellspec_output() { echo "output:$1"; }
      "$@"
      shellspec_if PENDING && echo 'pending:on' || echo 'pending:off'
    }

    Context 'when inside of example'
      It 'outputs PENDING'
        When invoke shellspec_pending
        The stdout should include 'output:PENDING'
      End

      It 'turns on the PENDING switch'
        When invoke shellspec_pending
        The stdout should include 'pending:on'
      End
    End

    Context 'when already failed'
      prepare() { shellspec_on FAILED; }

      It 'does not output PENDING'
        When invoke shellspec_pending
        The stdout should include 'output:PENDING'
      End

      It 'turns off the PENDING switch'
        When invoke shellspec_pending
        The stdout should include 'pending:off'
      End
    End

    Context 'when already skipped'
      prepare() { shellspec_on SKIP; }

      It 'does not output PENDING'
        When invoke shellspec_pending
        The stdout should not include 'output:PENDING'
      End

      It 'turns off the PENDING switch'
        When invoke shellspec_pending
        The stdout should include 'pending:off'
      End
    End

    Context 'when outside of example'
      prepare() { SHELLSPEC_EXAMPLE_NO=; }

      It 'does not output PENDING'
        When invoke shellspec_pending
        The stdout should not include 'output:PENDING'
      End

      It 'turns on the PENDING switch'
        When invoke shellspec_pending
        The stdout should include 'pending:on'
      End
    End
  End
End
