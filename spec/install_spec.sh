#shellcheck shell=sh disable=SC2016

% FIXTURE: "$SHELLSPEC_SPECDIR/fixture/install"
% TMPBASE: "$SHELLSPEC_TMPBASE/install"

Describe "source ./install.sh"
  Intercept parse_option main

  __parse_option__() {
    :
  }

  __main__() {
    exit 0
  }

  BeforeRun "HOME=$SHELLSPEC_TMPBASE/dummy_home"

  It 'outputs usage'
    When run source ./install.sh --help
    The status should be success
    The output should be present
  End

  It "exits with an error when specified invalid option"
    When run source ./install.sh --invalid
    The status should be failure
    The error should be present
  End
End

Describe "./install.sh"
  Include ./install.sh

  Describe "exists()"
    It 'returns success when found executable file'
      When call exists sh
      The status should be success
    End

    It 'returns success when not found executable file'
      When call exists no-such-command
      The status should be failure
    End
  End

  Describe "which()"
    Context 'when PATH=/foo:/bin:/bar'
      Before PATH=/foo:/bin:/bar
      It "retrieves found path"
        When call which sh
        The output should eq "/bin/sh"
      End
    End

    Context 'when PATH=/foo:/bar'
      Before PATH=/foo:/bar
      It "retrieves nothing"
        When call which sh
        The status should eq 1
      End
    End

    Context 'when PATH='
      Before PATH=
      It "retrieves nothing"
        When call which sh
        The status should eq 1
      End
    End
  End

  Describe "prompt()"
    It 'returns yes with y'
      When call prompt "Question? [y/N] " "y"
      The stdout should eq "Question? [y/N] y"
      The status should be success
    End

    It 'returns no with n'
      When call prompt "Question? [y/N] " "n"
      The stdout should eq "Question? [y/N] n"
      The status should be failure
    End

    It 'return the answer from the input'
      Data "y"
      When call prompt "Question? [y/N] "
      The stdout should eq "Question? [y/N] "
      The status should be success
    End
  End

  Describe "fetch()"
    curl() { exit 1; }
    wget() { exit 1; }

    Context "with curl"
      Before "FETCH=curl"
      curl() {
        case $* in
          *--head*) ;;
          *) cat "$FIXTURE/b3d5591.tar.gz"
        esac
      }

      It 'fetchs archive'
        When call fetch "http://repo.test/b3d5591.tar.gz" "$TMPBASE/curl"
        The file "$TMPBASE/curl/README.md" should be exist
        The stderr should be defined # ignore stderr
      End
    End

    Context "with wget"
      Before "FETCH=wget"
      wget() {
        case $* in
          *--spider*) ;;
          *) cat "$FIXTURE/b3d5591.tar.gz"
        esac
      }

      It 'fetchs archive'
        When call fetch "http://repo.test/b3d5591.tar.gz" "$TMPBASE/wget"
        The file "$TMPBASE/wget/README.md" should be exist
        The stderr should be defined # ignore stderr
      End
    End

    Context "when can not fetch file"
      Before "FETCH=curl"
      curl() { return 1; }

      It 'does not create directory'
        When call fetch "http://repo.test/b3d5591.tar.gz" "$TMPBASE/error"
        The directory "$TMPBASE/error" should not be exist
        The status should be failure
      End
    End
  End

  Describe "git_remote_tags()"
    git() {
      %text
      #|ec87d1d2aa29d814cb6d55b9f859cfe7cd9a8551        refs/tags/0.17.0
      #|02e7ee71099b42b9bb508781cb363ab97b85a2e9        refs/tags/0.18.0
      #|d3e2a30edcbd29794b8b7ef8966e5bc859c87791        refs/tags/0.5.0
      #|40cdd9c0e415fdc6a2281db6dc81e4fadd7d3f1e        refs/tags/0.6.0
      #|0bb8cfdc84f3704d9371a9473cceb18de6a17ad9        refs/tags/latest
      #|710897366fe86fcfd237854f115817badcaf3b2b        refs/tags/latest^{}
    }

    result() {
      %text
      #|0.17.0
      #|0.18.0
      #|0.5.0
      #|0.6.0
      #|latest
    }

    It 'retrives tags'
      When call git_remote_tags
      The stdout should eq "$(result)"
    End
  End

  Describe "join()"
    Data
      #|a
      #|b
      #|c
      #|d
    End

    It 'joins by argument'
      When call join ','
      The stdout should eq "a,b,c,d"
    End
  End

  Describe "list_versions()"
    get_versions() {
      %text
      #|0.17.0
      #|latest
      #|0.18.0
      #|0.5.0
      #|0.6.0
    }

    It 'lists versions'
      When call list_versions
      The stdout should eq "latest, 0.5.0, 0.6.0, 0.17.0, 0.18.0"
    End
  End

  Describe "latest_version()"
    get_versions() {
      %text
      #|0.17.0
      #|0.18.0
      #|0.5.0
      #|0.6.0
    }

    It 'gets latest version'
      When call latest_version
      The stdout should eq "0.18.0"
    End
  End

  Describe "version_sort()"
    Data
      #|2.0.0
      #|1.0.0-alpha
      #|1.0.0
      #|1.0.0-alpha+001
      #|2.1.1
      #|latest
      #|1.0.0-beta+exp.sha.5114f85
      #|1.0.0-alpha.1
      #|1.0.0-x.7.z.92
      #|alpha
      #|2.1.0
      #|1.0.0+20130313144700
      #|1.0.0-0.3.7
      #|1.10.0
      #|1.9.0
      #|1.11.0
    End

    result() {
      %text
      #|alpha
      #|latest
      #|1.0.0-0.3.7
      #|1.0.0-alpha
      #|1.0.0-alpha+001
      #|1.0.0-alpha.1
      #|1.0.0-beta+exp.sha.5114f85
      #|1.0.0-x.7.z.92
      #|1.0.0
      #|1.0.0+20130313144700
      #|1.9.0
      #|1.10.0
      #|1.11.0
      #|2.0.0
      #|2.1.0
      #|2.1.1
    }

    It "sorts by semantic version order"
      When call version_sort
      The stdout should eq "$(result)"
    End
  End
End