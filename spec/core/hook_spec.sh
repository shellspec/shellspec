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
        shellspec_before_hook 'echo 1'
        shellspec_before_hook 'echo 2'
        shellspec_before_hook 'echo 3'
      }
      When invoke shellspec_call_before_hooks
      The line 1 of stdout should equal 1
      The line 2 of stdout should equal 2
      The line 3 of stdout should equal 3
    End
  End

  Describe 'shellspec_call_after_hooks()'
    It 'does nothing if not exists hooks'
      When call shellspec_call_after_hooks
      The stdout should be blank
    End

    It 'calls hooks in reverse registration order if exists hooks'
      prepare() {
        shellspec_after_hook 'echo 1'
        shellspec_after_hook 'echo 2'
        shellspec_after_hook 'echo 3'
      }
      When invoke shellspec_call_after_hooks
      The line 1 of stdout should equal 3
      The line 2 of stdout should equal 2
      The line 3 of stdout should equal 1
    End
  End
End
