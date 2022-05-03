# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "core/switch.sh"
  Describe 'shellspec_on()'
    It "turns on the switch"
      When call shellspec_on DUMMY
      The switch DUMMY should satisfy switch_on
    End
  End

  Describe 'shellspec_off()'
    Before "SHELLSPEC_DUMMY=1"

    It "turns off the switch"
      When call shellspec_off DUMMY
      The switch DUMMY should satisfy switch_off
    End
  End

  Describe 'shellspec_toggle()'
    It "turns on the switch if condition is succeed"
      When call shellspec_toggle DUMMY true
      The switch DUMMY should satisfy switch_on
    End

    It "turns off the switch if condition is failed"
      When call shellspec_toggle DUMMY false
      The switch DUMMY should satisfy switch_off
    End
  End

  Describe 'shellspec_if()'
    Context 'when switch is on'
      Before "shellspec_on DUMMY"
      It "returns true"
        When call shellspec_if DUMMY
        The status should be success
      End
    End

    Context 'when switch is off'
      Before "shellspec_off DUMMY"
      It "returns false"
        When call shellspec_if DUMMY
        The status should be failure
      End
    End

    Context 'when switch is undefined'
      It "returns false"
        When call shellspec_if DUMMY
        The status should be failure
      End
    End
  End

  Describe 'shellspec_unless()'
    Context 'when switch is on'
      Before "shellspec_on DUMMY"
      It "returns false"
        When call shellspec_unless DUMMY
        The status should be failure
      End
    End

    Context 'when switch is off'
      Before "shellspec_off DUMMY"
      It "returns true"
        When call shellspec_unless DUMMY
        The status should be success
      End
    End

    Context 'when switch is undefined'
      It "returns true"
        When call shellspec_unless DUMMY
        The status should be success
      End
    End
  End
End
