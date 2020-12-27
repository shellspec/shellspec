#shellcheck shell=sh disable=SC2016

% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "shellspec-init.sh"
  Include ./libexec/shellspec-init.sh

  Describe "generate()"
    Context "when the specified file exists"
      It "skips generating the file"
        When call generate "$FIXTURE/exist"
        The output should eq "   exist   $FIXTURE/exist"
      End
    End

    Context "when the specified file not exists"
      Before SHELLSPEC_CWD="$SHELLSPEC_WORKDIR"
      mkdir() { echo "mkdir:" "$@" >&2; }
      Data "dummy"

      It "generates file"
        When call generate "$SHELLSPEC_WORKDIR/init-file"
        The contents of file "$SHELLSPEC_WORKDIR/init-file" should eq "dummy"
        The output should eq "  create   $SHELLSPEC_WORKDIR/init-file"
        The stderr should eq "mkdir: -p $SHELLSPEC_WORKDIR"
      End
    End
  End

  Describe "ignore_file()"
    Before SHELLSPEC_REPORTDIR="my-report"
    Before SHELLSPEC_COVERAGEDIR="my-coverage"

    It "generates ignore file"
      When call ignore_file "/"
      The line 1 of output should eq "/.shellspec-local"
      The line 2 of output should eq "/.shellspec-quick.log"
      The line 3 of output should eq "/my-report/"
      The line 4 of output should eq "/my-coverage/"
    End

    It "generates ignore file with header"
      When call ignore_file "^" "syntax: regexp"
      The line 1 of output should eq "syntax: regexp"
      The line 2 of output should eq "^.shellspec-local"
      The line 3 of output should eq "^.shellspec-quick.log"
      The line 4 of output should eq "^my-report/"
      The line 5 of output should eq "^my-coverage/"
    End
  End
End

Describe "run shellspec-init.sh"
  Intercept main
  __main__() {
    generate() { echo "$1"; }
  }

  Before SHELLSPEC_PROJECT_NAME=proj
  Before SHELLSPEC_HELPERDIR="my-helper"

  It 'generates template'
    When run source ./libexec/shellspec-init.sh
    The line 1 of output should eq ".shellspec"
    The line 2 of output should eq "my-helper/spec_helper.sh"
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
    The line 2 of output should eq "my-helper/spec_helper.sh"
    The line 3 of output should eq "spec/proj_spec.sh"
    The line 4 of output should eq "$2"
    The lines of output should eq 4
  End
End
