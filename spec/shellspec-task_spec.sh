#shellcheck shell=sh disable=SC2016

Describe "shellspec-task.sh"
  It "lists tasks"
    When run script ./libexec/shellspec-task.sh
    The line 1 of stdout should include "fixture:stat:prepare"
    The line 1 of stdout should include "# Prepare file stat tests"
    The line 2 of stdout should include "fixture:stat:cleanup"
    The line 2 of stdout should include "# Cleanup file stat tests"
    The line 3 of stdout should include "hello:shellspec"
    The line 3 of stdout should include "Example task"
  End

  It "lists task"
    When run script ./libexec/shellspec-task.sh "hello:shellspec"
    The stdout should eq "Hello ShellSpec"
  End
End
