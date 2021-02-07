#shellcheck shell=sh disable=SC2004,SC2016

Describe "core/clone.sh"
  Include "$SHELLSPEC_LIB/core/clone.sh"

  Describe "shellspec_clone_typeset()"
    typeset_mock() { echo typeset "$@"; }
    mock() {
      eval 'typeset() { typeset_mock "$@"; }' 2>/dev/null ||:
      alias typeset='typeset_mock' 2>/dev/null ||:
    }
    Before mock

    It "calls typeset"
      When call shellspec_clone_typeset 1 2 3
      The output should eq "typeset 1 2 3"
    End
  End

  Describe "shellspec_clone_escape()"
    Parameters
      "test1"    "'test1'"
      "te'st2"    "'te'\''st2'"
      "'test3'"    "\''test3'\'"
    End

    It "escapes single quotes ($1)"
      When call shellspec_clone_escape var "$1"
      The variable var should eq "$2"
    End
  End

  Describe "shellspec_clone_unset()"
    It "generates unset"
      When call shellspec_clone_unset foo bar:BAR
      The output should eq "unset foo BAR ||:"
    End
  End

  Describe "shellspec_clone()"
    Describe "clone check"
      clone_check() {
        var=$1
        eval "$(shellspec_clone var:VAR)"
        [ "$var" = "$VAR" ]
      }

      Parameters
        "test"
        "test$SHELLSPEC_LF"
      End

      It "clones variables"
        When call clone_check "$1"
        The status should be success
      End
    End

    shellspec_clone_dummy() { echo "clone $1 => $2"; }
    Before "SHELLSPEC_CLONE_TYPE=dummy" foo=1 bar=2

    It "calls clone function"
      When call shellspec_clone foo bar:BAR baz
      The line 1 should eq "unset foo BAR baz ||:"
      The line 2 should eq "clone foo => foo"
      The line 3 should eq "clone bar => BAR"
      The line 4 should be blank
    End
  End

  Describe 'shellspec_clone_exists_variable()'
    array_is_not_supported() {
      (eval "array=(1); array[1]=0") 2>/dev/null && return 1
      return 0
    }

    Skip if "array is not supported" array_is_not_supported
    setup() {
      var=1
      eval "array[1]=1"
    }
    Before setup

    Parameters
      # shellcheck disable=SC2218
      "var"       success
      "VAR"       failure
      "array[1]"  success
      "array[2]"  failure
    End

    It "checks variable exists"
      When call shellspec_clone_exists_variable "$1"
      The status should be "$2"
    End
  End

  BeforeCall 'var=$(var1)'
  shellspec_clone_typeset() { %= "$var"; }
  [ "$SHELLSPEC_BUILTIN_PRINT" ] || eval 'print() { printf "%s\n" "$3"; }'

  Describe "shellspec_clone_posix()"
    Specify 'var="abc"'
      var1() { %text
        #|abc
      }
      var2() { %text
        #|var2='abc'
      }
      When call shellspec_clone_posix var var2
      The output should eq "$(var2)"
    End

    Specify 'var="foo${LF}bar"'
      var1() { %text
        #|foo
        #|bar
      }
      var2() { %text
        #|var2='foo
        #|bar'
      }
      When call shellspec_clone_posix var var2
      The output should eq "$(var2)"
    End
  End

  Skip if "parameter expansion is not POSIX compliant" invalid_posix_parameter_expansion

  Describe 'shellspec_clone_bash()'
    Specify 'var=123'
      var1() { %text
        #|declare -- var="123"
      }
      var2() { %text
        #|declare -- var2="123"
      }
      When call shellspec_clone_bash var var2
      The output should eq "$(var2)"
    End

    Specify 'var="foo\nbar"'
      var1() { %text
        #|declare -- var="foo
        #|bar"
      }
      var2() { %text
        #|declare -- var2="foo
        #|bar"
      }
      When call shellspec_clone_bash var var2
      The output should eq "$(var2)"
    End

    Specify 'var=(1 2 3)'
      var1() { %text
        #|declare -a var=([0]="1" [1]="2" [2]="3")
      }
      var2() { %text
        #|declare -a var2=([0]="1" [1]="2" [2]="3")
      }
      When call shellspec_clone_bash var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -A var=([a]=1 [b]=2 [c]="foo\nbar")' # bash >= 4.x
      var1() { %text
        #|declare -A var='([a]="1" [b]="2" [c]="foo
        #|bar" )'
      }
      var2() { %text
        #|declare -A var2='([a]="1" [b]="2" [c]="foo
        #|bar" )'
      }
      When call shellspec_clone_bash var var2
      The output should eq "$(var2)"
    End
  End

  Describe 'shellspec_clone_zsh()'
    Specify 'var=123'
      var1() { %text
        #|typeset var=123
      }
      var2() { %text
        #|typeset var2=123
      }
      When call shellspec_clone_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'export var'
      var1() { %text
        #|export var=''
      }
      var2() { %text
        #|export var2=''
      }
      When call shellspec_clone_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'var=123 # 5.4.2 in function'
      var1() { %text
        #|typeset -g var=123
      }
      var2() { %text
        #|typeset var2=123
      }
      When call shellspec_clone_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'var="foo\nbar" # 4.2.5'
      var1() { %text
        #|typeset var='foo
        #|bar'
      }
      var2() { %text
        #|typeset var2='foo
        #|bar'
      }
      When call shellspec_clone_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'var="foo\nbar" # 5.3.1'
      var1() { %text
        #|typeset var=$'foo\nbar'
      }
      var2() { %text
        #|typeset var2=$'foo\nbar'
      }
      When call shellspec_clone_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'var=(1 2 3 "foo\nbar") # 4.2.5'
      var1() { %text
        #|typeset -a var
        #|var=(1 2 3 'foo
        #|var=')
      }
      var2() { %text
        #|typeset -a var2
        #|var2=(1 2 3 'foo
        #|var=')
      }
      When call shellspec_clone_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'array with global # exists?'
      var1() { %text
        #|typeset -g -a var
        #|var=(1 2 3 'foo
        #|var=')
      }
      var2() { %text
        #|typeset -a var2
        #|var2=(1 2 3 'foo
        #|var=')
      }
      When call shellspec_clone_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'var=(1 2 3 "foo\nbar") # 5.4.2'
      var1() { %text
        #|typeset -a var=( 1 2 3 $'foo\nbar' )
      }
      var2() { %text
        #|typeset -a var2=( 1 2 3 $'foo\nbar' )
      }
      When call shellspec_clone_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -A var=( a 1 b 2 ) # 5.4.2'
      var1() { %text
        #|typeset -A var=( a 1 b 2 )
      }
      var2() { %text
        #|typeset -A var2=( a 1 b 2 )
      }
      When call shellspec_clone_zsh var var2
      The output should eq "$(var2)"
    End
  End

  Describe 'shellspec_clone_ksh()'
    Specify 'var=123'
      var1() { %text
        #|var=123
      }
      var2() { %text
        #|var2=123
      }
      When call shellspec_clone_ksh var var2
      The output should eq "$(var2)"
    End

    Specify 'var="foo\nbar"'
      var1() { %text
        #|var=$'foo\nbar'
      }
      var2() { %text
        #|var2=$'foo\nbar'
      }
      When call shellspec_clone_ksh var var2
      The output should eq "$(var2)"
    End

    Specify 'var="foo\nbar" # exists?'
      var1() { %text
        #|var='foo
        #|bar'
      }
      var2() { %text
        #|var2='foo
        #|bar'
      }
      When call shellspec_clone_ksh var var2
      The output should eq "$(var2)"
    End

    Specify 'var=(1 2 3) # ksh'
      var1() { %text
        #|typeset -a var=(1 2 3)
      }
      var2() { %text
        #|typeset -a var2=(1 2 3)
      }
      When call shellspec_clone_ksh var var2
      The output should eq "$(var2)"
    End

    Specify 'var=(1 2 3) # mksh'
      var1() { %text
        #|set -A var
        #|typeset var[0]=1
        #|typeset var[1]=2
        #|typeset var[2]=3
      }
      var2() { %text
        #|set -A var2
        #|typeset var2[0]=1
        #|typeset var2[1]=2
        #|typeset var2[2]=3
      }
      When call shellspec_clone_ksh var var2
      The output should eq "$(var2)"
    End

    Specify 'readonly var # ksh'
      var1() { %text
        #|typeset -r var
      }
      var2() { %text
        #|typeset -r var2
      }
      When call shellspec_clone_ksh var var2
      The output should eq "$(var2)"
    End

    Specify 'var=(1 2 3); var[10]=10'
      var1() { %text
        #|typeset -a var=([0]=1 [1]=2 [2]=3 [10]=10)
      }
      var2() { %text
        #|typeset -a var2=([0]=1 [1]=2 [2]=3 [10]=10)
      }
      When call shellspec_clone_ksh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -A var=([a]=1 [b]=2)'
      var1() { %text
        #|typeset -A var=([a]=1 [b]=2)
      }
      var2() { %text
        #|typeset -A var2=([a]=1 [b]=2)
      }
      When call shellspec_clone_ksh var var2
      The output should eq "$(var2)"
    End
  End

  Describe 'shellspec_clone_yash()'
    Specify 'var=123'
      var1() { %text
        #|typeset var='123'
      }
      var2() { %text
        #|typeset var2='123'
      }
      When call shellspec_clone_yash var var2
      The output should eq "$(var2)"
    End

    Specify 'var="foo\nbar"'
      var1() { %text
        #|typeset var='foo
        #|var='
      }
      var2() { %text
        #|typeset var2='foo
        #|var='
      }
      When call shellspec_clone_yash var var2
      The output should eq "$(var2)"
    End

    Specify 'var=(1 2 3 "foo\nvar=bar")'
      var1() { %text
        #|var=('1' '2' '3' 'foo
        #|var=bar')
        #|typeset var
      }
      var2() { %text
        #|var2=('1' '2' '3' 'foo
        #|var=bar')
        #|typeset var2
      }
      When call shellspec_clone_yash var var2
      The output should eq "$(var2)"
    End

    Specify 'readonly var'
      var1() { %text
        #|typeset -r var
      }
      var2() { %text
        #|typeset -r var2
      }
      When call shellspec_clone_yash var var2
      The output should eq "$(var2)"
    End
  End

  Describe 'shellspec_clone_old_bash()'
    Specify 'var=123'
      var1() { %text
        #|declare -- var="123"
      }
      var2() { %text
        #|declare -- var2="123"
      }
      When call shellspec_clone_old_bash var var2
      The output should eq "$(var2)"
    End

    Specify 'var="foo\nbar"'
      var1() { %text
        #|declare -- var="foo\
        #|bar"
      }
      var2() { %text
        #|declare -- var2="foo
        #|bar"
      }
      When call shellspec_clone_old_bash var var2
      The output should eq "$(var2)"
    End

    Specify 'var=(1 2 3)'
      var1() { %text
        #|declare -a var=([0]="1" [1]="2" [2]="3")
      }
      var2() { %text
        #|declare -a var2=([0]="1" [1]="2" [2]="3")
      }
      When call shellspec_clone_old_bash var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -A var=([a]=1 [b]=2 [c]="foo\nbar")' # bash >= 4.x
      var1() { %text
        #|declare -A var='([a]="1" [b]="2" [c]="foo
        #|bar" )'
      }
      var2() { %text
        #|declare -A var2='([a]="1" [b]="2" [c]="foo
        #|bar" )'
      }
      When call shellspec_clone_old_bash var var2
      The output should eq "$(var2)"
    End
  End

  Describe 'shellspec_clone_old_zsh()'
    BeforeCall 'vars=$(vars)'

    shellspec_clone_typeset() {
      # shellcheck disable=SC2154
      if [ "$1" = "+" ]; then
        %= "$vars"
      elif [ "$1" = "-g" ]; then
        %= "$var"
      fi
    }

    Specify 'var=123'
      vars() { %text
        #|undefined funcstack
        #|var
        #|undefined functions
      }
      var1() { %text
        #|var=123
      }
      var2() { %text
        #|typeset var2
        #|var2=123
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'var="foo\nbar"'
      vars() { %text
        #|undefined funcstack
        #|var
        #|undefined functions
      }
      var1() { %text
        #|var='foo
        #|bar'
      }
      var2() { %text
        #|typeset var2
        #|var2='foo
        #|bar'
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -A var; var=(a 1 b 2)'
      vars() { %text
        #|association var
      }
      var1() { %text
        #|var=(a 1 b 2 )
      }
      var2() { %text
        #|typeset -A var2
        #|var2=(a 1 b 2 )
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -E var; var=123'
      vars() { %text
        #|float var
      }
      var1() { %text
        #|var=1.230000000e+02
      }
      var2() { %text
        #|typeset -E var2
        #|var2=1.230000000e+02
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -F var; var=123'
      vars() { %text
        #|float var
      }
      var1() { %text
        #|var=123.00000
      }
      var2() { %text
        #|typeset -F var2
        #|var2=123.00000
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -L var; var=123'
      vars() { %text
        #|left justified 3 var
      }
      var1() { %text
        #|var=123
      }
      var2() { %text
        #|typeset -L 3 var2
        #|var2=123
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -R var; var=123'
      vars() { %text
        #|right justified 3 var
      }
      var1() { %text
        #|var=123
      }
      var2() { %text
        #|typeset -R 3 var2
        #|var2=123
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -Z var; var=123'
      vars() { %text
        #|zero filled 3 var
      }
      var1() { %text
        #|var=123
      }
      var2() { %text
        #|typeset -Z 3 var2
        #|var2=123
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -a var; var=(1 2)'
      vars() { %text
        #|array var
      }
      var1() { %text
        #|var=(1 2)
      }
      var2() { %text
        #|typeset -a var2
        #|var2=(1 2)
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -i var; var=123'
      vars() { %text
        #|integer var
      }
      var1() { %text
        #|var=123
      }
      var2() { %text
        #|typeset -i var2
        #|var2=123
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -i 8 var; var=123'
      vars() { %text
        #|integer var
      }
      var1() { %text
        #|var=8#173
      }
      var2() { %text
        #|typeset -i 8 var2
        #|var2=8#173
      }
      BeforeCall "var=8#173"
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -l var; var=abc'
      vars() { %text
        #|lowercase var
      }
      var1() { %text
        #|var=abc
      }
      var2() { %text
        #|typeset -l var2
        #|var2=abc
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -r var; var=123'
      vars() { %text
        #|readonly var
      }
      var1() { %text
        #|var=123
      }
      var2() { %text
        #|typeset -r var2
        #|var2=123
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -t var; var=123'
      vars() { %text
        #|tagged var
      }
      var1() { %text
        #|var=123
      }
      var2() { %text
        #|typeset -t var2
        #|var2=123
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -u var; var=ABC'
      vars() { %text
        #|uppercase var
      }
      var1() { %text
        #|var=ABC
      }
      var2() { %text
        #|typeset -u var2
        #|var2=ABC
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -x var; var=123'
      vars() { %text
        #|exported var
      }
      var1() { %text
        #|var=123
      }
      var2() { %text
        #|typeset -x var2
        #|var2=123
      }
      When call shellspec_clone_old_zsh var var2
      The output should eq "$(var2)"
    End
  End

  Describe 'shellspec_clone_old_ksh()'
    BeforeCall 'vars=$(vars)'

    shellspec_clone_typeset() {
      %= "$vars"
    }
    shellspec_clone_set() {
      %= "$var"
    }

    Specify 'var=123'
      vars() { %text
        #|typeset -i RANDOM
        #|typeset -x PATH
        #|typeset -x TERM
      }
      var1() { %text
        #|var=123
      }
      var2() { %text
        #|var2=123
      }
      When call shellspec_clone_old_ksh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -i var'
      vars() { %text
        #|typeset -i RANDOM
        #|typeset -x PATH
        #|typeset -x TERM
        #|typeset -i var
      }
      var1() { %text
        #|var=0
      }
      var2() { %text
        #|typeset -i var2
        #|var2=0
      }
      When call shellspec_clone_old_ksh var var2
      The output should eq "$(var2)"
    End

    Specify 'typeset -x var'
      vars() { %text
        #|typeset -i RANDOM
        #|typeset -x PATH
        #|typeset -x TERM
        #|typeset -x var
      }
      var1() { :; }
      var2() { %text
        #|typeset -x var2
      }
      When call shellspec_clone_old_ksh var var2
      The output should eq "$(var2)"
    End

    Specify 'var=(1 2 3)'
      vars() { %text
        #|typeset -i RANDOM
        #|typeset -x PATH
        #|typeset -x TERM
      }
      var1() { %text
        #|var[0]=1
        #|var[1]=2
        #|var[2]=3
      }
      var2() { %text
        #|var2[0]=1
        #|var2[1]=2
        #|var2[2]=3
      }
      When call shellspec_clone_old_ksh var var2
      The output should eq "$(var2)"
    End
  End

  Describe 'shellspec_clone_old_pdksh()'
    BeforeCall 'vars=$(vars)'

    shellspec_clone_typeset() {
      %= "$vars"
    }
    shellspec_clone_set() {
      %= "$var"
    }

    Specify 'var=123'
      vars() { :; }
      var1() { :; }
      BeforeCall "unset var ||:"
      When call shellspec_clone_old_pdksh var var2
      The status should be failure
    End

    Specify 'var=123'
      vars() { %text
        #|typeset -i RANDOM
        #|typeset -i SECONDS
        #|typeset var
      }
      var1() { %text
        #|var=123
      }
      var2() { %text
        #|typeset var2
        #|var2='123'
      }
      shellspec_clone_exists_variable() { eval "$(var1)"; }
      When call shellspec_clone_old_pdksh var var2
      The output should eq "$(var2)"
    End
  End
End
