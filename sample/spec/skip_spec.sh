#shellcheck shell=sh disable=SC2034

Describe 'example spec'
  Describe 'foo()'
    Example '[not implement] test'
      :
    End

    Example '[success] test'
      When call true
      The status should be success
    End

    Example '[warn] test'
      When call false
    End
  End

  Describe 'foo()'
    Example '[pending] test'
      Pending 'failure implementation'
      When call false
      The status should be success
    End

    Example '[fixed] test'
      Pending 'fixed implementation'
      When call true
      The status should be success
    End

    Example '[fail] test'
      Skip
      When call true
      The status should be failure
    End

    Context 'when second'
      calc() { aaa; echo "$@" | bc; }
      set_var() { var=$1; }
      a=10
      Skip if "shell is zsh" [ "$SHELLSPEC_SHELL_TYPE" = zsh ]

      Example '[skip] stdout matcher'
        When call calc 100 + 20 + 3
        The stdout should eq 1233
      End
    End
  End
End
