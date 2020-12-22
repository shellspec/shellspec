#shellcheck shell=sh

% SIGNAL: "$SHELLSPEC_TMPBASE/profiler.test"

# This Include do not place inside of Describe. posh fails
# shellcheck disable=SC2034
SHELLSPEC_REQUIRES=''
Include "$SHELLSPEC_LIB/bootstrap.sh"

Describe 'bootstrap.sh'
  Describe 'shellspec_load_requires()'
    shellspec_import() {
      echo "import" "$1"
      case $1 in
        bar) eval "shellspec_bar_configure() { echo configure bar; }";;
      esac
    }

    It 'does not load anything without required scripts'
      When call shellspec_load_requires ""
      The stdout should eq "import core"
    End

    It 'loads required scripts'
      When call shellspec_load_requires "foo bar"
      The line 1 of stdout should eq "import foo"
      The line 2 of stdout should eq "import bar"
      The line 3 of stdout should eq "import core"
      The line 4 of stdout should eq "configure bar"
    End
  End

  Describe 'shellspec_profile_wait()'
    fake_profiler() {
      (
        while [ ! -s "$SIGNAL" ]; do :; done
        : > "$SIGNAL"
      ) &
    } 2>/dev/null
    Before fake_profiler
    BeforeCall "SHELLSPEC_PROFILER_SIGNAL='$SIGNAL'"

    It 'waits until signal file is empty'
      When call shellspec_profile_wait
      The file "$SIGNAL" should be empty file
    End
  End
End
