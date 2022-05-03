# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe 'Directives'
  Describe '%puts'
    _puts() { %- "$@"; }
    _puts_long() {
      %puts "$@"
    }

    It 'puts string (%-)'
      When run _puts "test"
      The entire output should eq "test"
    End

    It 'puts string (%puts)'
      When run _puts_long "test"
      The entire output should eq "test"
    End
  End

  Describe '%putsn'
    # shellcheck disable=SC2276
    _putsn() { %= "$@"; }
    _putsn_long() {
      %putsn "$@"
    }

    It 'putsn string (%=)'
      When run _putsn "test"
      The entire output should eq "test${SHELLSPEC_LF}"
    End

    It 'putsn string (%putsn)'
      When run _putsn_long "test"
      The entire output should eq "test${SHELLSPEC_LF}"
    End
  End

  Describe '%logger'
    _logger() { %logger "$@"; }
    BeforeRun 'SHELLSPEC_LOGFILE=""'

    It 'outputs to logfile'
      When run _logger "test"
      The output should eq "test"
    End
  End

  Describe '%printf'
    _printf() { %printf "$@"; }
    It 'calls printf builtin'
      When call _printf '%03d' "1"
      The output should eq "001"
    End
  End

  Describe '%sleep'
    _sleep() { %sleep "$@"; }
    It 'calls sleep builtin'
      When call _sleep 0
      The status should eq 0
    End
  End
End
