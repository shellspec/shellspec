#shellcheck shell=sh disable=SC2016

Describe 'libexec.sh'
  Include "$SHELLSPEC_LIB/libexec.sh"

  Describe 'is_specfile()'
    Before SHELLSPEC_PATTERN="*_spec.sh"

    It 'returns success when pattern matches'
      When call is_specfile "test_spec.sh"
      The status should be success
    End

    It 'returns failure when pattern not matches'
      When call is_specfile "test.sh"
      The status should be failure
    End
  End

  Describe 'merge_specfiles()'
    is_specfile() { return 0; }
    found_specfiles() {
      found_specfiles=""
      while [ "$#" -gt 0 ]; do
        merge_specfiles "$1"
        shift
      done
      echo "$found_specfiles"
    }

    It 'merges same files'
      When call found_specfiles "a_spec.sh" "b_spec.sh" "a_spec.sh"
      The line 1 of output should eq "a_spec.sh"
      The line 2 of output should eq "b_spec.sh"
      The lines of output should eq 2
    End

    It 'merges range'
      When call found_specfiles "a_spec.sh" "b_spec.sh:1" "a_spec.sh:1" "b_spec.sh:@1-2"
      The line 1 of output should eq "a_spec.sh:1"
      The line 2 of output should eq "b_spec.sh:1:@1-2"
      The lines of output should eq 2
    End
  End

  Describe 'invoke_specfile()'
    callback() {
      echo "path:$1"
      echo "file:$2"
      echo "range:${3-<unset>}"
    }

    It 'calls callback with no range'
      When call invoke_specfile callback "a_spec.sh"
      The line 1 of output should eq "path:a_spec.sh"
      The line 2 of output should eq "file:a_spec.sh"
      The line 3 of output should eq "range:<unset>"
    End

    It 'calls callback with range'
      When call invoke_specfile callback "a_spec.sh:1:2:@1-2"
      The line 1 of output should eq "path:a_spec.sh:1:2:@1-2"
      The line 2 of output should eq "file:a_spec.sh"
      The line 3 of output should eq "range:1 2 @1-2"
    End
  End
End
