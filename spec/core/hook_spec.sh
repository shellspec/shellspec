#shellcheck shell=sh

Describe "core/hook.sh"
  Describe "shellspec_before_each_hook()"
    Context 'if no hooks'
      Example "do nothing"
        When call shellspec_call_before_each_hooks
        The stdout should be blank
      End
    End

    Context 'if exists hooks'
      before_each_hooks() {
        shellspec_before_each_hook 'shellspec_puts "1"'
        shellspec_before_each_hook 'shellspec_puts "2"'
        shellspec_before_each_hook 'shellspec_puts "3"'
        shellspec_call_before_each_hooks
      }

      Example "calls hooks in registration order"
        When invoke before_each_hooks
        The stdout should equal 123
      End
    End
  End

  Describe "shellspec_after_each_hook()"
    Context 'if no hooks'
      Example "do nothing"
        When call shellspec_call_after_each_hooks
        The stdout should be blank
      End
    End

    Context 'if exists hooks'
      after_each_hooks() {
        shellspec_after_each_hook 'shellspec_puts "1"'
        shellspec_after_each_hook 'shellspec_puts "2"'
        shellspec_after_each_hook 'shellspec_puts "3"'
        shellspec_call_after_each_hooks
      }

      Example "calls hooks in reverse registration order"
        When invoke after_each_hooks
        The stdout should equal 321
      End
    End
  End
End
