#shellcheck shell=sh

Describe 'describe 1'
  before1() { echo "$SHELLSPEC_DESC before1 " >&2; }
  before2() { echo "$SHELLSPEC_DESC before2" >&2; }
  after1() { echo "$SHELLSPEC_DESC after1" >&2; }
  after2() { echo "$SHELLSPEC_DESC after2" >&2; }
  Before "before1" "before2"
  After "after1" "after2"

  Describe 'describe 1:1'
    before3() { echo "$SHELLSPEC_DESC before3 " >&2; }
    after3() { echo "$SHELLSPEC_DESC after3" >&2; }
    Before "before3"
    After "after3"

    Example 'example 1:1:1'
      Debug "example 1:1:1"
      When call :
      The status should be success
    End

    Example 'example 1:1:2'
      Debug "example 1:1:2"
      When call :
      The status should be success
    End
  End

  Describe '1:2'
    Example 'example 1:2:1'
      Debug "example 1:2:1"
      When call :
      The status should be success
    End

    Example 'example 1:2:2'
      Debug "example 1:2:2"
      When call :
      The status should be success
    End
  End
End
