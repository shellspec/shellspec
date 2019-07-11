#shellcheck shell=sh

Describe "libexec/list.sh"
  Include "$SHELLSPEC_LIB/libexec/list.sh"

  Describe "shuffle()"
    Skip if "it has calculation accuracy problem" accuracy_error_bug
    Skip if "it not support xor" xor_not_support_bug
    Skip if "it can not calculate correctly" miscalculate_signed_32bit_int_bug

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
