#shellcheck shell=sh disable=SC2016

% MARK_FILE: "$SHELLSPEC_TMPBASE/before_after_each_hook"

prepare() { @rm -f "$MARK_FILE"; }
clean() { @rm "$MARK_FILE"; }
append() { %printf ' ' >> "$MARK_FILE"; }
BeforeAll 'prepare'

Describe 'BeforeEach / AfterEach hook'
  BeforeEach 'append'
  AfterEach 'clean'

  File mark-file="$MARK_FILE"

  Specify "BeforeAll calls each block"
    The length of contents of file mark-file should eq 1
  End

  Specify "BeforeAll calls each block"
    The length of contents of file mark-file should eq 1
  End
End

Describe 'Before / After hook'
  Before 'append'
  After 'clean'

  File mark-file="$MARK_FILE"

  Specify "BeforeAll calls each block"
    The length of contents of file mark-file should eq 1
  End

  Specify "BeforeAll calls each block"
    The length of contents of file mark-file should eq 1
  End
End
