#shellcheck shell=sh

Describe "core/switch.sh"
  Describe 'shellspec_on()'
    Example "it should be variable is 1 after call shellspec_on"
      When call shellspec_on DUMMY
      The variable SHELLSPEC_SW_DUMMY should equal 1
    End
  End

  Describe 'shellspec_off()'
    Before "SHELLSPEC_DUMMY=1"

    Example "it should be variable is '' after call shellspec_on"
      When call shellspec_off DUMMY
      The variable SHELLSPEC_SW_DUMMY should equal ''
    End
  End

  Describe 'shellspec_toggle()'
    Example "it should be variable is 1 after call shellspec_toggle true"
      When call shellspec_toggle DUMMY [ "1 2" ]
      The variable SHELLSPEC_SW_DUMMY should equal 1
    End

    Example "it should be variable is '' after call shellspec_toggle false"
      When call shellspec_toggle DUMMY [ "" ]
      The variable SHELLSPEC_SW_DUMMY should equal ''
    End
  End

  Describe 'shellspec_if()'
    Context 'when switch is on'
      Before "shellspec_on DUMMY"

      Example "exit status is success"
        When call shellspec_if DUMMY
        The exit status should be success
      End
    End

    Context 'when switch is off'
      Before "shellspec_off DUMMY"

      Example "exit status is error"
        When call shellspec_if DUMMY
        The exit status should be failure
      End
    End

    Context 'when switch is undefined'
      Example "exit status is error"
        When call shellspec_if DUMMY
        The exit status should be failure
      End
    End
  End

  Describe 'shellspec_unless()'
    Context 'when switch is on'
      Before "shellspec_on DUMMY"

      Example "exit status is error"
        When call shellspec_unless DUMMY
        The exit status should be failure
      End
    End

    Context 'when switch is off'
      Before "shellspec_off DUMMY"

      Example "exit status is sussess"
        When call shellspec_unless DUMMY
        The exit status should be success
      End
    End

    Context 'when switch is undefined'
      Example "exit status is sussess"
        When call shellspec_unless DUMMY
        The exit status should be success
      End
    End
  End
End
