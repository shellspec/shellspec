#shellcheck shell=sh

Describe 'example spec'
  Example '[pending] test'
    When call true
    The value 0 should eq 0
  End

  Describe
    Example '[pending] test'
      When call true
      The status should be success
    End
  End
End
