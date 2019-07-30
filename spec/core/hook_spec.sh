#shellcheck shell=sh

Describe "core/hook.sh"
  Describe 'shellspec_create_hook()'
    It 'does nothing if not exists hooks'
      empty_hooks() {
        shellspec_create_hook empty EXAMPLE
        shellspec_call_empty_hooks
      }
      When call empty_hooks
      The stdout should be blank
    End

    It 'calls hooks in registration order if exists hooks'
      example_hooks() {
        shellspec_create_hook example EXAMPLE
        shellspec_example_hook 'echo 1'
        shellspec_example_hook 'echo 2'
        shellspec_example_hook 'echo 3'
        shellspec_call_example_hooks
      }
      When call example_hooks
      The line 1 of stdout should equal 1
      The line 2 of stdout should equal 2
      The line 3 of stdout should equal 3
    End

    It 'calls hooks in reverse registration order if exists hooks'
      example_rev_hooks() {
        shellspec_create_hook example_rev EXAMPLE_REV rev
        shellspec_example_rev_hook 'echo 1'
        shellspec_example_rev_hook 'echo 2'
        shellspec_example_rev_hook 'echo 3'
        shellspec_call_example_rev_hooks
      }
      When call example_rev_hooks
      The line 1 of stdout should equal 3
      The line 2 of stdout should equal 2
      The line 3 of stdout should equal 1
    End
  End
End
