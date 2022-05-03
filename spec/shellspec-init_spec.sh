# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "shellspec-init.sh"
  Include ./libexec/shellspec-init.sh

  Describe "generate()"
    Context "when the specified file exists"
      Before SHELLSPEC_CWD="$SHELLSPEC_PROJECT_ROOT"
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

  Describe "spec()"
    Data
      #|example
    End

    It "generates specfile"
      When call spec file contents "proj_spec.sh"
      The variable file should eq "proj_spec.sh"
      The variable contents should eq "example"
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

  Describe "default_options()"
    Context "when helperdir is spec"
      Before SHELLSPEC_HELPERDIR="spec"

      It "generates default options"
        When call default_options
        The line 1 should eq "--require spec_helper"
        The line 2 should be undefined
      End
    End

    Context "when helperdir specified"
      Before SHELLSPEC_HELPERDIR="helper"

      It "generates default options with --helperdir"
        When call default_options
        The line 1 should eq "--require spec_helper"
        The line 2 should eq "--helperdir helper"
      End
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
    When run source ./libexec/shellspec-init.sh spec
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
    When run source ./libexec/shellspec-init.sh spec "$1"
    The line 1 of output should eq ".shellspec"
    The line 2 of output should eq "my-helper/spec_helper.sh"
    The line 3 of output should eq "spec/proj_spec.sh"
    The line 4 of output should eq "$2"
    The lines of output should eq 4
  End
End
