# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "core/utils.sh"
  Include "$SHELLSPEC_LIB/core/utils.sh"

  Describe 'shellspec_is_number()'
    Parameters
      123       success
      "-123"    failure
      123.0     failure
      @         failure
      ''        failure
    End

    It 'checks if number'
      When call shellspec_is_number "$1"
      The status should be "$2"
    End
  End

  Describe 'shellspec_is_function()'
    Parameters
      foo       success
      foo123    success
      foo_123   success
      _foo_123  success
      @         failure
      ''        failure
    End

    It 'checks if function'
      When call shellspec_is_function "$1"
      The status should be "$2"
    End
  End

  Describe 'shellspec_is_identifier()'
    Parameters
      foo       success
      foo123    success
      foo_123   success
      _foo_123  success
      @         failure
      ''        failure
    End

    It 'checks if identifier'
      When call shellspec_is_identifier "$1"
      The status should be "$2"
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
    shellspec_set_long() { %putsn "$@"; }

    It 'sets long options'
      When run shellspec_set_option
      The line 1 of output should eq "-foo"
      The line 2 of output should eq "+bar"
      The lines of output should eq 2
    End
  End

  Describe 'shellspec_shopt()'
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
        When run shellspec_shopt -o nounset
        The output should include "u"
      End

      It 'unsets option'
        When run shellspec_shopt +o nounset
        The output should not include "u"
      End
    End
  End

  Describe 'shellspec_set_long()'
    set_nounset() { set -u; }
    cannot_preserve_set_in_function() {
      set +u
      set_nounset
      case $- in (*u*) false ;; (*) true ;; esac
    }
    # ksh88
    Skip if "Cannot preserve 'set' in function" cannot_preserve_set_in_function

    It 'sets long options'
      When call shellspec_set_long -nounset
      The value $- should include "u"
    End

    It 'unsets long options'
      When call shellspec_set_long +nounset
      The value $- should not include "u"
    End
  End
End
