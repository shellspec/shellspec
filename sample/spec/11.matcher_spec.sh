#shellcheck shell=sh

Describe 'matcher sample'
  Describe 'status matchers'
    Describe 'be success matcher'
      It 'checks if status is successful'
        When call true
        The status should be success # status is 0
      End
    End

    Describe 'be failure matcher'
      It 'checks if status is failed'
        When call false
        The status should be failure # status is 1-255
      End
    End

    # If you want to check status number, use equal matcher.
  End

  Describe 'stat matchers'
    Describe 'be exist'
      It 'checks if path is exist'
        The path 'data.txt' should be exist
      End

      It 'checks if path is file'
        The path 'data.txt' should be file
      End

      It 'checks if path is directory'
        The path 'data.txt' should be directory
      End
    End

    # There are many other stat matchers.
    #   be empty, be symlink, be pipe, be socket, be readable, be writable,
    #   be executable, be block_device, be character_device,
    #   has setgid, has setuid
  End

  Describe 'variable matchers'
    Before 'prepare'

    Describe 'be defined'
      prepare() { var=''; }
      It 'checks if variable is defined'
        The value "$var" should be defined
      End
    End

    Describe 'be undefined'
      prepare() { unset var; }
      It 'checks if variable is undefined'
        The variable var should be undefined
      End
    End

    Describe 'be present'
      prepare() { var=123; }
      It 'checks if variable is present'
        The value "$var" should be present # non-zero length string
      End
    End

    Describe 'be blank'
      prepare() { var=""; }
      It 'checks if variable is blank'
        The value "$var" should be blank # unset or zero length string
      End
    End
  End

  Describe 'string matchers'
    Describe 'equal'
      It 'checks if subject equals specified string'
        The value "foobarbaz" should equal "foobarbaz"
      End
    End

    Describe 'start with'
      It 'checks if subject start with specified string'
        The value "foobarbaz" should start with "foo"
      End
    End

    Describe 'end with'
      It 'checks if subject end with specified string'
        The value "foobarbaz" should end with "baz"
      End
    End

    Describe 'include'
      It 'checks if subject include specified string'
        The value "foobarbaz" should include "bar"
      End
    End

    Describe 'match'
      It 'checks if subject match specified pattern'
        # Using shell script's pattern matching
        The value "foobarbaz" should match "f??bar*"
      End
    End
  End

  Describe 'satisfy matcher'
    greater_than() { [ "$SHELLSPEC_SUBJECT" -gt "$1" ]; }

    It 'checks if satisfy condition'
      The value 10 should satisfy greater_than 5
    End
  End
End
