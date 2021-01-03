#shellcheck shell=sh

Describe '%putsn directive'
  Example 'outputs arguments'
    foo() { %putsn value; }
    When call foo
    The entire output should eq "value${SHELLSPEC_LF}"
  End
End

Describe '%= directive'
  Example 'is alias for %putsn'
    foo() { %= value; }
    When call foo
    The entire output should eq "value${SHELLSPEC_LF}"
  End
End

Describe '%puts directive'
  Example 'outputs arguments without last <LF>'
    foo() { %puts value; }
    When call foo
    The entire output should eq "value"
  End
End

Describe '%- directive'
  Example 'is alias for %puts'
    foo() { %- value; }
    When call foo
    The entire output should eq "value"
  End
End
