#shellcheck shell=sh

Describe 'example spec'
  Describe 'foo()'
    Example '[not implement] test'
      :
    End

    Example '[success] test'
      When call true
      The exit status should be success
    End

    Example '[warn] test'
      When call false
    End
  End

  Describe 'foo()'
    Example '[pending] test'
      Pending 'atode'
      When call false
      The exit status should be success
    End

    Example '[fixed] test'
      Pending 'atode'
      When call true
      The exit status should be success
    End

    Example '[fail] test'
      Skip
      When call true
      The exit status should be failure
    End

    Context 'when second'
      calc() { aaa; echo "$@" | bc; }
      set_var() { var=$1; }
      a=10
      Skip if "shell is zsh" [ "$SHELLSPEC_SHELL_TYPE" = zsh ]

      Example '[skip] stdout matcher'
        When call calc 100 + 20 + 3
        The stdout should eq 1233
        #Debug aaaa
      End
    End

    Example 'aaaaa'
    End
  End
End
