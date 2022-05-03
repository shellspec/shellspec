# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

% MARK_FILE: "$SHELLSPEC_TMPBASE/before_after_each_all"

BeforeAll 'var=0'
Describe 'BeforeAll / AfterAll hook'
  prepare() { @rm -f "$MARK_FILE"; }
  append() { %printf ' ' >> "$MARK_FILE"; }
  clean() { @rm "$MARK_FILE"; }

  BeforeAll 'prepare'
  BeforeAll 'append'
  AfterAll 'clean'

  File mark-file="$MARK_FILE"

  Specify "BeforeAll calls once per block"
    The length of contents of file mark-file should eq 1
  End

  Specify "BeforeAll shares the state"
    The length of contents of file mark-file should eq 1
  End
End

Example
  The variable var should eq 0
End
