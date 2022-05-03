# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

% FIXTURE: "$SHELLSPEC_HELPERDIR/fixture"

Describe "shellspec-load-env.sh"
  BeforeRun 'export SHELLSPEC_ENV_FROM=$FIXTURE/env-script.sh'
  BeforeRun 'export SHELLSPEC_LIBEXEC=$FIXTURE'
  BeforeRun 'export SHELLSPEC_MODE=dummy-mode'
  It 'loads env file'
    When run script ./libexec/shellspec-load-env.sh
    The line 1 of stdout should eq "env-script"
    The line 2 of stdout should eq "dummy mode"
  End
End
