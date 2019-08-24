#shellcheck shell=sh

Describe "core/hook.sh"
  Before 'shellspec_create_hook example EXAMPLE'

  Describe 'shellspec_call_before_hooks()'
    Context 'when hooks are empty'
      It 'does nothing if not exists before hooks'
        When call shellspec_call_before_hooks EXAMPLE
        The stdout should be blank
      End
    End

    Context 'when hooks are exists'
      example_hooks() {
        shellspec_before_example_hook 'echo 1'
        shellspec_before_example_hook 'echo 2'
        shellspec_before_example_hook 'echo 3'
      }

      It 'calls hooks in registration order'
        BeforeCall example_hooks
        When call shellspec_call_before_hooks EXAMPLE
        The line 1 of stdout should equal 1
        The line 2 of stdout should equal 2
        The line 3 of stdout should equal 3
      End
    End
  End

  Describe 'shellspec_call_after_hooks()'
    Context 'when hooks are empty'
      It 'does nothing if not exists after hooks'
        When call shellspec_call_after_hooks EXAMPLE
        The stdout should be blank
      End
    End

    Context 'when hooks are exists'
      example_hooks() {
        shellspec_after_example_hook 'echo 1'
        shellspec_after_example_hook 'echo 2'
        shellspec_after_example_hook 'echo 3'
      }

      It 'calls hooks in reverse registration order'
        BeforeCall example_hooks
        When call shellspec_call_after_hooks EXAMPLE
        The line 1 of stdout should equal 3
        The line 2 of stdout should equal 2
        The line 3 of stdout should equal 1
      End
    End
  End
End
