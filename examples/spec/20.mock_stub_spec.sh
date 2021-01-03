#shellcheck shell=sh

Describe 'mock stub example'
  unixtime() { date +%s; }
  get_next_day() { echo $(($(unixtime) + 86400)); }

  Example 'redefine date command'
    date() { echo 1546268400; }
    When call get_next_day
    The stdout should eq 1546354800
  End

  Example 'use the date command'
    # Date is not redefined because this is another subshell
    When call unixtime
    The stdout should not eq 1546268400
  End
End
