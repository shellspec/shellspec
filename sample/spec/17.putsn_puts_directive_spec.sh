#shellcheck shell=sh

Describe '%putsn directive'
  Example 'outputs arguments'
    func() { %putsn value; }
    When call func
    The entire output should eq "value${SHELLSPEC_LF}"
  End
End

Describe '%= directive'
  Example 'is alias for %putsn'
    func() { %= value; }
    When call func
    The entire output should eq "value${SHELLSPEC_LF}"
  End
End

Describe '%puts directive'
  Example 'outputs arguments without last <LF>'
    func() { %puts value; }
    When call func
    The entire output should eq "value"
  End
End

Describe '%- directive'
  Example 'is alias for %puts'
    func() { %- value; }
    When call func
    The entire output should eq "value"
  End
End
