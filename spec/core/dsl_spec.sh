#shellcheck shell=sh

Describe "core/dsl.sh" # comment
  Describe "shellspec_example_group()"
    Example 'calls yield block'
      shellspec_around_invoke() {
        shellspec_output() { echo "$1"; }
        shellspec_yield() { echo 'yield'; }
        "$@"
      }
      When invoke shellspec_example_group
      The stdout should include 'yield'
    End
  End

  Describe "shellspec_example()"
    prepare() { :; }
    shellspec_around_invoke() {
      prepare
      shellspec_output() { echo "$1"; }
      shellspec_yield() { echo yield; }
      if [ "${2:-}" ]; then
        eval "shellspec_yield() {
          echo yield; shellspec_off NOT_IMPLEMENTED; $2;
        }"
      fi
      "$@"
    }

    Example 'do not yield if skipped outside of example'
      prepare() { shellspec_on SKIP; }
      block() { :; }
      When invoke shellspec_example block
      The stdout should not include 'yield'
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'SKIP'
      The stdout line 3 should equal 'SKIPPED'
      The stdout line 4 should equal 'EXAMPLE_END'
    End

    Example 'outpus SKIPPED if skipped inside of example'
      block() { shellspec_skip 1; }
      When invoke shellspec_example block
      The stdout should include 'yield'
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'SKIP'
      The stdout line 4 should equal 'SKIPPED'
      The stdout line 5 should equal 'EXAMPLE_END'
    End

    Example 'outputs NOT_IMPLEMENTED, TODO if example not implementd'
      When invoke shellspec_example
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'NOT_IMPLEMENTED'
      The stdout line 4 should equal 'TODO'
      The stdout line 5 should equal 'EXAMPLE_END'
    End

    Example 'outputs FAILED if example is failed'
      block() { shellspec_on FAILED; }
      When invoke shellspec_example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'FAILED'
      The stdout line 4 should equal 'EXAMPLE_END'
    End

    Example 'outputs UNHANDLED_STATUS, WARNED if unhandled status'
      block() { shellspec_on UNHANDLED_STATUS; }
      When invoke shellspec_example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'UNHANDLED_STATUS'
      The stdout line 4 should equal 'WARNED'
      The stdout line 5 should equal 'EXAMPLE_END'
    End

    Example 'outputs UNHANDLED_STDOUT, WARNED if unhandled stdout'
      block() { shellspec_on UNHANDLED_STDOUT; }
      When invoke shellspec_example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'UNHANDLED_STDOUT'
      The stdout line 4 should equal 'WARNED'
      The stdout line 5 should equal 'EXAMPLE_END'
    End

    Example 'outputs UNHANDLED_STDERR, WARNED if unhandled stderr'
      block() { shellspec_on UNHANDLED_STDERR; }
      When invoke shellspec_example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'UNHANDLED_STDERR'
      The stdout line 4 should equal 'WARNED'
      The stdout line 5 should equal 'EXAMPLE_END'
    End

    Example 'outputs FAILED if failed inside of yield'
      block() { shellspec_on FAILED; }
      When invoke shellspec_example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'FAILED'
      The stdout line 4 should equal 'EXAMPLE_END'
    End

    Example 'outputs SUCCEEDED'
      block() { :; }
      When invoke shellspec_example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'SUCCEEDED'
      The stdout line 4 should equal 'EXAMPLE_END'
    End

    Example 'outputs TODO if failed and pending inside of yield'
      block() { shellspec_on FAILED PENDING; }
      When invoke shellspec_example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'TODO'
      The stdout line 4 should equal 'EXAMPLE_END'
    End

    Example 'outputs FIXED if not failed and pending inside of yield'
      block() { shellspec_on PENDING; }
      When invoke shellspec_example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'FIXED'
      The stdout line 4 should equal 'EXAMPLE_END'
    End
  End

  Describe "shellspec_when()"
    prepare() { :; }
    shellspec_around_invoke() {
      shellspec_off EVALUATION EXPECTATION
      shellspec_on NOT_IMPLEMENTED
      prepare
      shellspec_output() { echo "$1"; }
      shellspec_statement_evaluation() { :; }
      shellspec_on() { echo "on:[$*]"; }
      shellspec_off() { echo "off:[$*]"; }
      "$@"
    }

    Example 'turns off the NOT_IMPLEMENTED switch'
      When invoke shellspec_when call true
      The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
      The stdout line 2 should equal 'on:[EVALUATION]'
      The stdout line 3 should equal 'EVALUATION'
    End

    Example 'outputs SYNTAX_ERROR if missing Evaluation'
      When invoke shellspec_when
      The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
      The stdout line 2 should equal 'on:[EVALUATION]'
      The stdout line 3 should equal 'SYNTAX_ERROR'
      The stdout line 4 should equal 'on:[FAILED]'
    End

    Context 'when already executed Evaluation'
      prepare() { shellspec_on EVALUATION; }
      Example 'outputs SYNTAX_ERROR'
        When invoke shellspec_when call true
        The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
        The stdout line 2 should equal 'SYNTAX_ERROR'
        The stdout line 3 should equal 'on:[FAILED]'
      End
    End

    Context 'when already executed Expectation'
      prepare() { shellspec_on EXPECTATION; }
      Example 'outputs SYNTAX_ERROR'
        When invoke shellspec_when call true
        The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
        The stdout line 2 should equal 'on:[EVALUATION]'
        The stdout line 3 should equal 'SYNTAX_ERROR'
        The stdout line 4 should equal 'on:[FAILED]'
      End
    End
  End

  Describe "shellspec_statement()"
    prepare() { :; }
    shellspec__statement_() { echo called; }
    shellspec_around_invoke() {
      prepare
      "$@"
      shellspec_if SYNTAX_ERROR && echo 'syntax_error' || echo 'not syntax_error'
      shellspec_if FAILED && echo 'failed' || echo 'not failed'
    }

    Context 'When execute statement exit normally'
      Example 'it not syntax_error and not failed'
        When invoke shellspec_statement _statement_ dummy
        The stdout should include 'not syntax_error'
        The stdout should include 'not failed'
        The stdout should include called
      End
    End

    Context 'When execute statement exit normally'
      prepare() { shellspec_on SYNTAX_ERROR; }
      Example 'it not syntax_error and not failed'
        When invoke shellspec_statement _statement_ dummy
        The stdout should include 'syntax_error'
        The stdout should include 'failed'
        The stdout should include called
      End
    End

    Context 'When if skipped'
      prepare() { shellspec_on SKIP; }
      Example 'statement not called'
        When invoke shellspec_statement _statement_ dummy
        The stdout should not include called
      End
    End
  End

  Describe "shellspec_the()"
    shellspec_around_invoke() {
      shellspec_on NOT_IMPLEMENTED
      shellspec_statement_preposition() { :; }
      shellspec_on() { echo "on:[$*]"; }
      shellspec_off() { echo "off:[$*]"; }
      "$@"
    }

    Example 'turns off the NOT_IMPLEMENTED switch'
      When invoke shellspec_the dummy
      The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
      The stdout line 2 should equal 'on:[EXPECTATION]'
    End
  End

  Describe "shellspec_it()"
    shellspec_around_invoke() {
      shellspec_on NOT_IMPLEMENTED
      shellspec_statement_advance_subject() { :; }
      shellspec_on() { echo "on:[$*]"; }
      shellspec_off() { echo "off:[$*]"; }
      "$@"
    }

    Example 'turns off the NOT_IMPLEMENTED switch'
      When invoke shellspec_it dummy
      The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
      The stdout line 2 should equal 'on:[EXPECTATION]'
    End
  End

  Describe "shellspec_skip()"
    prepare() { SHELLSPEC_EXAMPLE_NO=1; }
    shellspec_around_invoke() {
      prepare
      shellspec_output() { echo "$1"; }
      "$@"
      shellspec_if SKIP && echo 'skip' || echo 'not skip'
      echo "skip_id:${SHELLSPEC_SKIP_ID-<unset>}"
      echo "skip_reason:${SHELLSPEC_SKIP_REASON-<unset>}"
      echo "conditional_skip:${SHELLSPEC_CONDITIONAL_SKIP-<unset>}"
      echo "example_no:${SHELLSPEC_EXAMPLE_NO-<unset>}"
    }

    Example 'turns on SKIP switch'
      When invoke shellspec_skip 123 "reason"
      The stdout line 1 should equal 'SKIP'
      The stdout line 2 should equal 'skip'
      The stdout line 3 should equal 'skip_id:123'
      The stdout line 4 should equal 'skip_reason:reason'
      The stdout line 5 should equal 'conditional_skip:'
    End

    Context 'when currently outside of Example'
      prepare() { SHELLSPEC_EXAMPLE_NO=; }
      Example 'do not outputs SKIP'
        When invoke shellspec_skip 123 "skip reason"
        The stdout line 1 should equal 'skip'
      End
    End

    Context 'when already skipped'
      prepare() { shellspec_on SKIP; }
      Example 'do nothing'
        When invoke shellspec_skip 123 "skip reason"
        The stdout line 1 should equal 'skip'
        The stdout line 2 should equal 'skip_id:<unset>'
        The stdout line 3 should equal 'skip_reason:<unset>'
        The stdout line 4 should equal 'conditional_skip:<unset>'
      End
    End

    Describe "with conditional"
      Example 'skips if satisfy condition'
        When invoke shellspec_skip 123 if "reason" true
        The stdout line 1 should equal 'SKIP'
        The stdout line 2 should equal 'skip'
        The stdout line 3 should equal 'skip_id:123'
        The stdout line 4 should equal 'skip_reason:reason'
        The stdout line 5 should equal 'conditional_skip:1'
      End

      Example 'do not skips if not satisfy condition'
        When invoke shellspec_skip 123 if "reason" false
        The stdout line 1 should equal 'not skip'
        The stdout line 2 should equal 'skip_id:123'
        The stdout line 3 should equal 'skip_reason:reason'
        The stdout line 4 should equal 'conditional_skip:1'
      End
    End
  End

  Describe "shellspec_pending()"
    prepare() { SHELLSPEC_EXAMPLE_NO=1; }
    shellspec_around_invoke() {
      prepare
      shellspec_output() { echo "$1"; }
      "$@"
      shellspec_if PENDING && echo 'pending' || echo 'not pending'
    }

    Example 'outputs PENDING'
      When invoke shellspec_pending
      The stdout line 1 should equal 'PENDING'
      The stdout line 2 should equal 'pending'
    End

    Context 'when already failed'
      prepare() { shellspec_on FAILED; }
      Example 'do not outputs PENDING'
        When invoke shellspec_pending
        The stdout line 1 should equal 'PENDING'
        The stdout line 2 should equal 'not pending'
      End
    End

    Context 'when already skipped'
      prepare() { shellspec_on SKIP; }
      Example 'do nothing'
        When invoke shellspec_pending
        The stdout line 1 should equal 'not pending'
      End
    End

    Context 'when currently outside of Example'
      prepare() { SHELLSPEC_EXAMPLE_NO=; }
      Example 'do not outputs PENDING'
        When invoke shellspec_pending
        The stdout line 1 should equal 'pending'
      End
    End
  End

  Describe "shellspec_debug()"
    prepare() { :; }
    shellspec_around_invoke() {
      prepare
      shellspec_output() { echo "$1"; }
      "$@"
    }

    Example 'outputs DEBUG'
      When invoke shellspec_debug
      The stdout line 1 should equal 'DEBUG'
    End

    Context 'when skipped'
      prepare() { shellspec_on SKIP; }
      Example 'do not outputs DEBUG'
        When invoke shellspec_debug
        The stdout should be blank
      End
    End
  End
End
