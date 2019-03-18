#shellcheck shell=sh

Describe "core/dsl.sh" # comment
  Describe "shellspec_example_group()"
    Example 'yield block' # comment
      example_group() {
        shellspec_off EXAMPLE
        shellspec_output() { echo "$1"; }
        shellspec_yield() { echo 'yield'; }
        shellspec_example_group
      }
      When invoke example_group
      The stdout should include 'yield'
    End
  End

  Describe "shellspec_example()"
    example() {
      shellspec_output() { echo "$1"; }
      shellspec_yield() { echo yield; }
      if [ "${1:-}" ]; then
        eval "shellspec_yield() {
          echo yield; shellspec_off NOT_IMPLEMENTED; $1;
        }"
      fi
      shellspec_example
    }

    Example 'do not yield if skipped outside of example'
      skipped_example() {
        shellspec_on SKIP
        example "$@"
      }
      block() { :; }
      When invoke skipped_example block
      The stdout should not include 'yield'
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'SKIP'
      The stdout line 3 should equal 'SKIPPED'
      The stdout line 4 should equal 'EXAMPLE_END'
    End

    Example 'output SKIPPED if skipped inside of example'
      block() { shellspec_skip 1; }
      When invoke example block
      The stdout should include 'yield'
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'SKIP'
      The stdout line 4 should equal 'SKIPPED'
      The stdout line 5 should equal 'EXAMPLE_END'
    End

    Example 'output NOT_IMPLEMENTED, TODO if example not implementd'
      When invoke example
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'NOT_IMPLEMENTED'
      The stdout line 4 should equal 'TODO'
      The stdout line 5 should equal 'EXAMPLE_END'
    End

    Example 'output FAILED if example is failed'
      block() { shellspec_on FAILED; }
      When invoke example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'FAILED'
      The stdout line 4 should equal 'EXAMPLE_END'
    End

    Example 'output UNHANDLED_STATUS, WARNED if unhandled status'
      block() { shellspec_on UNHANDLED_STATUS; }
      When invoke example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'UNHANDLED_STATUS'
      The stdout line 4 should equal 'WARNED'
      The stdout line 5 should equal 'EXAMPLE_END'
    End

    Example 'output UNHANDLED_STDOUT, WARNED if unhandled stdout'
      block() { shellspec_on UNHANDLED_STDOUT; }
      When invoke example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'UNHANDLED_STDOUT'
      The stdout line 4 should equal 'WARNED'
      The stdout line 5 should equal 'EXAMPLE_END'
    End

    Example 'output UNHANDLED_STDERR, WARNED if unhandled stderr'
      block() { shellspec_on UNHANDLED_STDERR; }
      When invoke example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'UNHANDLED_STDERR'
      The stdout line 4 should equal 'WARNED'
      The stdout line 5 should equal 'EXAMPLE_END'
    End

    Example 'output FAILED if failed inside of yield'
      block() { shellspec_on FAILED; }
      When invoke example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'FAILED'
      The stdout line 4 should equal 'EXAMPLE_END'
    End

    Example 'output FAILED if syntax error inside of yield'
      block() { shellspec_on SYNTAX_ERROR; }
      When invoke example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'FAILED'
      The stdout line 4 should equal 'EXAMPLE_END'
    End

    Example 'output SUCCEEDED'
      block() { :; }
      When invoke example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'SUCCEEDED'
      The stdout line 4 should equal 'EXAMPLE_END'
    End

    Example 'output TODO if failed and pending inside of yield'
      block() { shellspec_on FAILED PENDING; }
      When invoke example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'TODO'
      The stdout line 4 should equal 'EXAMPLE_END'
    End

    Example 'output FIXED if not failed and pending inside of yield'
      block() { shellspec_on PENDING; }
      When invoke example block
      The stdout line 1 should equal 'EXAMPLE_BEGIN'
      The stdout line 2 should equal 'yield'
      The stdout line 3 should equal 'FIXED'
      The stdout line 4 should equal 'EXAMPLE_END'
    End
  End

  Describe "shellspec_when()"
    prepare() { :; }
    spy_shellspec_when() {
      shellspec_off EVALUATION EXPECTATION
      shellspec_on NOT_IMPLEMENTED
      prepare
      shellspec_output() { echo "$1"; }
      shellspec_statement_evaluation() { :; }
      shellspec_on() { echo "on:[$*]"; }
      shellspec_off() { echo "off:[$*]"; }
      eval shellspec_when ${1+'"$@"'}
    }

    Example 'turns off the NOT_IMPLEMENTED switch'
      When invoke spy_shellspec_when call true
      The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
      The stdout line 2 should equal 'on:[EVALUATION]'
      The stdout line 3 should equal 'EVALUATION'
    End

    Example 'output SYNTAX_ERROR if missing Evaluation'
      When invoke spy_shellspec_when
      The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
      The stdout line 2 should equal 'on:[EVALUATION]'
      The stdout line 3 should equal 'SYNTAX_ERROR'
      The stdout line 4 should equal 'on:[FAILED]'
    End

    Context 'when already executed Evaluation'
      prepare() { shellspec_on EVALUATION; }
      Example 'output SYNTAX_ERROR'
        When invoke spy_shellspec_when call true
        The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
        The stdout line 2 should equal 'SYNTAX_ERROR'
        The stdout line 3 should equal 'on:[FAILED]'
      End
    End

    Context 'when already executed Expectation'
      prepare() { shellspec_on EXPECTATION; }
      Example 'output SYNTAX_ERROR'
        When invoke spy_shellspec_when call true
        The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
        The stdout line 2 should equal 'on:[EVALUATION]'
        The stdout line 3 should equal 'SYNTAX_ERROR'
        The stdout line 4 should equal 'on:[FAILED]'
      End
    End
  End

  Describe "shellspec_the()"
    spy_shellspec_the() {
      shellspec_on NOT_IMPLEMENTED
      shellspec_statement_preposition() { :; }
      shellspec_on() { echo "on:[$*]"; }
      shellspec_off() { echo "off:[$*]"; }
      shellspec_the dummy
    }

    Example 'turns off the NOT_IMPLEMENTED switch'
      When invoke spy_shellspec_the
      The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
      The stdout line 2 should equal 'on:[EXPECTATION]'
    End
  End

  Describe "shellspec_it()"
    spy_shellspec_it() {
      shellspec_on NOT_IMPLEMENTED
      shellspec_statement_advance_subject() { :; }
      shellspec_on() { echo "on:[$*]"; }
      shellspec_off() { echo "off:[$*]"; }
      shellspec_it dummy
    }

    Example 'turns off the NOT_IMPLEMENTED switch'
      When invoke spy_shellspec_it
      The stdout line 1 should equal 'off:[NOT_IMPLEMENTED]'
      The stdout line 2 should equal 'on:[EXPECTATION]'
    End
  End

  Describe "shellspec_skip()"
    prepare() { SHELLSPEC_EXAMPLE_NO=1; }
    spy_shellspec_skip() {
      prepare
      shellspec_output() { echo "$1"; }
      shellspec_skip "$@"
      shellspec_if SKIP && echo 'skip' || echo 'not skip'
      echo "skip_id:${SHELLSPEC_SKIP_ID-<unset>}"
      echo "skip_reason:${SHELLSPEC_SKIP_REASON-<unset>}"
      echo "conditional_skip:${SHELLSPEC_CONDITIONAL_SKIP-<unset>}"
    }

    Example 'turns on SKIP switch'
      When invoke spy_shellspec_skip 123 "reason"
      The stdout line 1 should equal 'SKIP'
      The stdout line 2 should equal 'skip'
      The stdout line 3 should equal 'skip_id:123'
      The stdout line 4 should equal 'skip_reason:reason'
      The stdout line 5 should equal 'conditional_skip:'
    End

    Context 'when currently outside of Example'
      prepare() { SHELLSPEC_EXAMPLE_NO=; }
      Example 'do not output SKIP'
        When invoke spy_shellspec_skip 123 "skip reason"
        The stdout line 1 should equal 'skip'
      End
    End

    Context 'when already skipped'
      prepare() { shellspec_on SKIP; }
      Example 'do nothing'
        When invoke spy_shellspec_skip 123 "skip reason"
        The stdout line 1 should equal 'skip'
        The stdout line 2 should equal 'skip_id:<unset>'
        The stdout line 3 should equal 'skip_reason:<unset>'
        The stdout line 4 should equal 'conditional_skip:<unset>'
      End
    End

    Describe "with conditional"
      Example 'skips if satisfy condition'
        When invoke spy_shellspec_skip 123 if "reason" true
        The stdout line 1 should equal 'SKIP'
        The stdout line 2 should equal 'skip'
        The stdout line 3 should equal 'skip_id:123'
        The stdout line 4 should equal 'skip_reason:reason'
        The stdout line 5 should equal 'conditional_skip:1'
      End

      Example 'do not skips if not satisfy condition'
        When invoke spy_shellspec_skip 123 if "reason" false
        The stdout line 1 should equal 'not skip'
        The stdout line 2 should equal 'skip_id:123'
        The stdout line 3 should equal 'skip_reason:reason'
        The stdout line 4 should equal 'conditional_skip:1'
      End
    End
  End

  Describe "shellspec_pending()"
    prepare() { SHELLSPEC_EXAMPLE_NO=1; }
    spy_shellspec_pending() {
      prepare
      shellspec_output() { echo "$1"; }
      shellspec_pending
      shellspec_if PENDING && echo 'pending' || echo 'not pending'
    }

    Example 'output PENDING'
      When invoke spy_shellspec_pending
      The stdout line 1 should equal 'PENDING'
      The stdout line 2 should equal 'pending'
    End

    Context 'when already failed'
      prepare() { shellspec_on FAILED; }
      Example 'do not output PENDING'
        When invoke spy_shellspec_pending
        The stdout line 1 should equal 'PENDING'
        The stdout line 2 should equal 'not pending'
      End
    End

    Context 'when already skipped'
      prepare() { shellspec_on SKIP; }
      Example 'do nothing'
        When invoke spy_shellspec_pending
        The stdout line 1 should equal 'not pending'
      End
    End

    Context 'when currently outside of Example'
      prepare() { SHELLSPEC_EXAMPLE_NO=; }
      Example 'do not output PENDING'
        When invoke spy_shellspec_pending
        The stdout line 1 should equal 'pending'
      End
    End
  End

  Describe "shellspec_debug()"
    prepare() { :; }
    spy_shellspec_debug() {
      prepare
      shellspec_output() { echo "$1"; }
      shellspec_debug
    }

    Example 'output DEBUG'
      When invoke spy_shellspec_debug
      The stdout line 1 should equal 'DEBUG'
    End

    Context 'when skipped'
      prepare() { shellspec_on SKIP; }
      Example 'do not output DEBUG'
        When invoke spy_shellspec_debug
        The stdout should be blank
      End
    End
  End
End
