#shellcheck shell=sh

Describe "core/utils.sh"
  Include "$SHELLSPEC_LIB/core/utils.sh"

  Describe 'shellspec_is()'
    Describe 'number'
      It 'succeeds with a numeric value'
        When call shellspec_is number 123
        The status should be success
      End

      It 'fails with a not numeric value'
        When call shellspec_is number abc
        The status should be failure
      End

      It 'fails with a zero length string'
        When call shellspec_is number ''
        The status should be failure
      End

      It 'fails with a empty'
        When call shellspec_is number
        The status should be failure
      End
    End

    Describe 'funcname'
      It 'succeeds with valid function name foo_bar'
        When call shellspec_is funcname foo_bar
        The status should be success
      End

      It 'succeeds with valid function name foo123'
        When call shellspec_is funcname foo123
        The status should be success
      End

      It 'fails with invalid function name'
        When call shellspec_is funcname foo+bar
        The status should be failure
      End

      It 'fails with start with number'
        When call shellspec_is funcname 0foo_bar
        The status should be failure
      End

      It 'fails with a zero length string'
        When call shellspec_is funcname ''
        The status should be failure
      End

      It 'fails with a empty'
        When call shellspec_is funcname
        The status should be failure
      End
    End

    It 'raise error with invalid type'
      When run shellspec_is invalid-type
      The error should be present
      The status should be failure
    End
  End

  Describe 'shellspec_capture()'
    Context 'when function outputs "ok"'
      func() { %- "ok"; }
      It 'captures "ok"'
        When call shellspec_capture var func
        The variable var should equal ok
      End
    End

    Context 'when function outputs "ok<LF>"'
      func() { %= "ok"; }
      It 'captures "ok<LF>"'
        When call shellspec_capture var func
        The variable var should equal "ok${IFS%?}"
      End
    End

    Context 'when function return false'
      func() { false; }
      It 'can not capture'
        When call shellspec_capture var func
        The variable var should be undefined
      End
    End
  End

  Describe 'shellspec_append_set()'
    Before op=''

    append_set() {
      while [ $# -gt 0 ]; do
        shellspec_append_set op "$1"
        shift
      done
    }

    It 'appends shell options'
      When call append_set foo:on bar:off
      The variable op should eq "set -o foo;set +o bar;"
    End

    It 'raise error when specified invalid parameter'
      When run shellspec_append_set op 'foo:err'
      The stderr should be present
      The status should be failure
    End
  End

  Describe 'shellspec_append_shopt()'
    Before op=''

    append_shopt() {
      while [ $# -gt 0 ]; do
        shellspec_append_shopt op "$1"
        shift
      done
    }

    It 'appends shell options'
      When call append_shopt foo:on bar:off
      The variable op should eq "shellspec_shopt -o foo;shellspec_shopt +o bar;"
    End

    It 'raise error when specified invalid parameter'
      When run shellspec_append_shopt options 'foo:err'
      The stderr should be present
      The status should be failure
    End
  End

  Describe 'shellspec_set_option()'
    BeforeRun 'SHELLSPEC_SHELL_OPTIONS="set -o foo;set +o bar;"'
    shellspec_set_long() { %= "$@"; }

    It 'sets long options'
      When run shellspec_set_option
      The line 1 of output should eq "-foo"
      The line 2 of output should eq "+bar"
      The lines of output should eq 2
    End
  End

  Describe 'shellspec_shopt()'
    # shellcheck disable=SC2039,SC2123
    not_exists_shopt() { (PATH=''; ! shopt -s nullglob 2>/dev/null &&:); }
    Skip if "'shopt' not implemented" not_exists_shopt

    Describe "shopt option"
      AfterRun "shopt -p nullglob ||:"

      It 'sets option'
        When run shellspec_shopt -o nullglob
        The output should eq "shopt -s nullglob"
      End

      It 'unsets option'
        When run shellspec_shopt +o nullglob
        The output should eq "shopt -u nullglob"
      End
    End

    Describe "sh option"
      AfterRun 'echo $-'

      It 'sets option'
        When run shellspec_shopt -o allexport
        The output should include "a"
      End

      It 'unsets option'
        When run shellspec_shopt +o allexport
        The output should not include "a"
      End
    End
  End

  Describe 'shellspec_set_long()'
    set_allexport() { set -a; }
    cannot_preserve_set_in_function() {
      set +a
      set_allexport
      case $- in (*a*) false ;; (*) true ;; esac
    }
    # ksh88
    Skip if "Cannot preserve 'set' in function" cannot_preserve_set_in_function

    It 'sets long options'
      When call shellspec_set_long -allexport
      The value $- should include "a"
    End

    It 'unsets long options'
      When call shellspec_set_long +allexport
      The value $- should not include "a"
    End
  End
End
