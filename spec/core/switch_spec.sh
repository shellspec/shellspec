#shellcheck shell=sh

Describe "core/switch.sh"
  Describe 'shellspec_on()'
    Example "called then the switch should be on"
      When call shellspec_on DUMMY
      The switch DUMMY should satisfy switch_on
    End
  End

  Describe 'shellspec_off()'
    Before "SHELLSPEC_DUMMY=1"

    Example "called then the switch should be off"
      When call shellspec_off DUMMY
      The switch DUMMY should satisfy switch_off
    End
  End

  Describe 'shellspec_toggle()'
    Example "called then the switch should be on if condition is succeed"
      When call shellspec_toggle DUMMY true
      The switch DUMMY should satisfy switch_on
    End

    Example "called then the switch should be off if condition is failed"
      When call shellspec_toggle DUMMY false
      The switch DUMMY should satisfy switch_off
    End
  End

  Describe 'shellspec_if()'
    Context 'when switch is on'
      Before "shellspec_on DUMMY"
      Example "returns true"
        When call shellspec_if DUMMY
        The status should be success
      End
    End

    Context 'when switch is off'
      Before "shellspec_off DUMMY"
      Example "returns false"
        When call shellspec_if DUMMY
        The status should be failure
      End
    End

    Context 'when switch is undefined'
      Example "returns false"
        When call shellspec_if DUMMY
        The status should be failure
      End
    End
  End

  Describe 'shellspec_unless()'
    Context 'when switch is on'
      Before "shellspec_on DUMMY"
      Example "returns false"
        When call shellspec_unless DUMMY
        The status should be failure
      End
    End

    Context 'when switch is off'
      Before "shellspec_off DUMMY"
      Example "returns true"
        When call shellspec_unless DUMMY
        The status should be success
      End
    End

    Context 'when switch is undefined'
      Example "returns true"
        When call shellspec_unless DUMMY
        The status should be success
      End
    End
  End
End
