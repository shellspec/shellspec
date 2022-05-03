# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "libexec/list.sh"
  Include "$SHELLSPEC_LIB/libexec/list.sh"
  od() { @od "$@"; }
  hexdump() { @hexdump "$@"; }
  sort() { eval @sort ${1+'"$@"'}; }

  Describe "shuffle()"
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

  Describe "gen_seed()"
    Parameters
       "abcd" "1402706709"
    End

    _gen_seed() { echo "$1"| octal_dump | gen_seed; }

    It "generates seed ($1)"
      When call _gen_seed "$1"
      The output should eq "$2"
    End
  End

  Describe "decord_hash_and_filename()"
    Parameters
       "3633671424" "3633671424"
       "-661295872" "3633671424"
      "-2147483648" "2147483648"
    End

    It "decords hash and filename ($1)"
      When call decord_hash_and_filename "$1" "\061\062\063\064"
      The output should eq "$2 1234"
    End
  End
End
