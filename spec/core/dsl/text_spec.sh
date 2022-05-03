# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe '%text'
  It 'outputs to stdout'
    foo() {
      %text
      #|aaa\
      #|bbb
      #|ccc
      #|
    }

    When call foo
    The line 1 of entire output should eq "aaa\\"
    The line 2 of entire output should eq 'bbb'
    The line 3 of entire output should eq "ccc"
    The line 4 of entire output should eq ""
    The lines of entire output should eq 4
  End

  It 'outputs to variable'
    foo() {
      value=$(
        %text
        #|aaa
        #|bbb
        #|ccc
        #|
      )
    }

    When call foo
    The line 1 of value "$value" should eq 'aaa'
    The line 2 of value "$value" should eq 'bbb'
    The line 3 of value "$value" should eq "ccc"
    The lines of value "$value" should eq 3
  End

  It 'not expands the variable'
    hello() {
      %text
      #|Hello $1
    }

    When call hello world
    The output should eq 'Hello $1'
  End

  It ':raw not expands the variable'
    hello() {
      %text:raw
      #|Hello $1
    }

    When call hello world
    The output should eq 'Hello $1'
  End

  It ':expand expands the variable'
    hello() {
      %text:expand
      #|Hello $1
    }

    When call hello world
    The output should eq 'Hello world'
  End

  It 'outputs to stdout and not expands the variable with filter'
    hello() {
      %text | uppercase
      #|Hello $1
    }

    When call hello world
    The output should eq 'HELLO $1'
  End

  It ':raw outputs to stdout and not expands the variable with filter'
    hello() {
      %text:raw | uppercase
      #|Hello $1
    }

    When call hello world
    The output should eq 'HELLO $1'
  End

  It 'outputs to stdout and expands the variable with filter'
    hello() {
      %text:expand | uppercase
      #|Hello $1
    }

    When call hello world
    The output should eq 'HELLO WORLD'
  End
End
