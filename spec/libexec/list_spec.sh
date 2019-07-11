#shellcheck shell=sh

Describe "libexec/list.sh"
  Include "$SHELLSPEC_LIB/libexec/list.sh"

  # accuracy_check() { # ksh
  #   [ "$((99999999 * 999999999))" = "99999998900000000" ]
  # }

  xor_not_support() { # ash 0.3.8
    ! (eval ': $((0^0))') 2>/dev/null
  }

  miscalculate() { # yash 2.30 ans = -2147483648
    ans=$((21474836478 ^ 0))
    [ "$ans" = 21474836478 ] && return 1
    [ "$ans" = -2 ] && return 1
    return 0
  }

  Describe "shuffle()"
    # Skip if "it has calculation accuracy problem" accuracy_check
    Skip if "it not support xor" xor_not_support
    Skip if "it can not calculate correctly" miscalculate

    Data
      #|list1
      #|list2
      #|list3
      #|list4
      #|list5
      #|list6
      #|list7
      #|list8
      #|list9
    End

    It 'shuffles the list'
      When call shuffle seed
      The line 1 of output should eq "list8"
      The line 2 of output should eq "list7"
      The line 3 of output should eq "list2"
      The line 4 of output should eq "list9"
      The line 5 of output should eq "list1"
      The line 6 of output should eq "list5"
      The line 7 of output should eq "list3"
      The line 8 of output should eq "list6"
      The line 9 of output should eq "list4"
    End
  End
End
