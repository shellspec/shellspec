#shellcheck shell=sh

Describe "core/hook.sh"
  prepare() { :; }
  shellspec_around_invoke() { prepare; "$@"; }

  Describe 'shellspec_call_before_hooks()'
    It 'does nothing if not exists hooks'
      When call shellspec_call_before_hooks
      The stdout should be blank
    End

    It 'calls hooks in registration order if exists hooks'
      prepare() {
        shellspec_before_hook 'shellspec_puts "1"'
        shellspec_before_hook 'shellspec_puts "2"'
        shellspec_before_hook 'shellspec_puts "3"'
      }
      When invoke shellspec_call_before_hooks
      The stdout should equal 123
    End
  End

  Describe 'shellspec_call_after_hooks()'
    It 'does nothing if not exists hooks'
      When call shellspec_call_after_hooks
      The stdout should be blank
    End

    It 'calls hooks in reverse registration order if exists hooks'
      prepare() {
        shellspec_after_hook 'shellspec_puts "1"'
        shellspec_after_hook 'shellspec_puts "2"'
        shellspec_after_hook 'shellspec_puts "3"'
      }
      When invoke shellspec_call_after_hooks
      The stdout should equal 321
    End
  End
End
