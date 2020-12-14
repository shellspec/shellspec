#shellcheck shell=sh disable=SC2016

% TMPBASE: "$SHELLSPEC_TMPBASE"
% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "shellspec-init.sh"
  Include ./libexec/shellspec-init.sh

  Describe "generate()"
    mkdir() { echo "mkdir:" "$@" >&2; }
    clean() { @rm -f "$TMPBASE/init-file"; }
    Before clean
    Data "dummy"

    It "generates file"
      When call generate "$FIXTURE/exist"
      The output should eq "   exist   $FIXTURE/exist"
    End

    It "generates file"
      When call generate "$TMPBASE/init-file"
      The contents of file "$TMPBASE/init-file" should eq "dummy"
      The output should eq "  create   $TMPBASE/init-file"
      The stderr should eq "mkdir: -p $TMPBASE"
    End
  End

  Describe "ignore_file()"
    It "generates ignore file"
      When call ignore_file "/"
      The line 1 of output should eq "/.shellspec-local"
      The line 2 of output should eq "/.shellspec-quick.log"
      The line 3 of output should eq "/report/"
      The line 4 of output should eq "/coverage/"
    End

    It "generates ignore file with header"
      When call ignore_file "^" "syntax: regexp"
      The line 1 of output should eq "syntax: regexp"
      The line 2 of output should eq "^.shellspec-local"
      The line 3 of output should eq "^.shellspec-quick.log"
      The line 4 of output should eq "^report/"
      The line 5 of output should eq "^coverage/"
    End
  End
End

Describe "run shellspec-init.sh"
  Intercept main
  __main__() {
    generate() { echo "$1"; }
  }

  BeforeRun SHELLSPEC_PROJECT_NAME=proj

  It 'generates template'
    When run source ./libexec/shellspec-init.sh
    The line 1 of output should eq ".shellspec"
    The line 2 of output should eq "spec/spec_helper.sh"
    The line 3 of output should eq "spec/proj_spec.sh"
    The lines of output should eq 3
  End

  Parameters
    git .gitignore
    hg  .hgignore
    svn .svnignore
  End

  It "generates template with ignore file ($1)"
    When run source ./libexec/shellspec-init.sh "$1"
    The line 1 of output should eq ".shellspec"
    The line 2 of output should eq "spec/spec_helper.sh"
    The line 3 of output should eq "spec/proj_spec.sh"
    The line 4 of output should eq "$2"
    The lines of output should eq 4
  End
End
