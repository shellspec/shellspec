#shellcheck shell=sh

% DOT_SHELLSPEC: "fixture/dot-shellspec"
% CMDLINE: "$SHELLSPEC_SPECDIR/fixture/proc"

Describe "libexec/shellspec.sh"
  Include "$SHELLSPEC_LIB/libexec/shellspec.sh"

  Describe "read_dot_file()"
    parser() {
      [ "$1" = "--require" ] && [ "$2" = "spec_helper" ] &&
      [ "$3" = "--format" ] && [ "$4" = "progress" ] &&
      [ $# -eq 4 ]
      echo ok
    }

    It "reads dot file"
      When call read_dot_file "$SHELLSPEC_SPECDIR" "$DOT_SHELLSPEC" parser
      The stdout should equal "ok"
      The status should be success
    End

    It "does not read dot file if not specified directory"
      When call read_dot_file "" "$DOT_SHELLSPEC" parser
      The stdout should be blank
      The status should be success
    End
  End

  Describe "current_shell()"
    current_shell_fallback_with_proc() { echo 'fallback'; }

    Context "when procps format"
      process() {
        %text
        #|PID TTY      STAT   TIME COMMAND
        #|  1 pts/0    Ss     0:00 -bash
        #|001 pts/0    R+     0:00 ps w
        #|002 ?        I<     0:00 [kworker/0:0H]
        #|003 ?        S      0:00 (sd-pam)
        #|111 pts/0    S      0:00 /bin/sh /usr/local/bin/shellspec
      }

      It "parses and detects shell"
        When call current_shell "/usr/local/bin/shellspec" 111
        The stdout should equal "/bin/sh"
      End
    End

    Context "when busybox 1.1.3 format"
      process() {
        %text
        #|  PID  Uid     VmSize Stat Command
        #|   88 root       1808 R   ps w
        #|  111 root       1520 S   /bin/sh /usr/local/bin/shellspec
      }

      It "parses and detects shell"
        When call current_shell "/usr/local/bin/shellspec" 111
        The stdout should equal "/bin/sh"
      End
    End

    Context "when busybox ps format 1"
      process() {
        %text
        #|  PID USER       VSZ STAT COMMAND
        #|    1 root      1548 S    /sbin/init
        #|  001 root      1200 R    ps w
        #|  111 root      1460 S    /bin/sh /usr/local/bin/shellspec
      }

      It "parses and detects shell"
        When call current_shell "/usr/local/bin/shellspec" 111
        The stdout should equal "/bin/sh"
      End
    End

    Context "when busybox ps format 2"
      process() {
        %text
        #|  PID USER    TIME COMMAND
        #|    1 root    0:00 /bin/sh
        #|  001 root    0:00 ps w
        #|  111 root    0:00 {shellspec} /bin/sh /usr/local/bin/shellspec
      }

      It "parses and detects shell"
        When call current_shell "/usr/local/bin/shellspec" 111
        The stdout should equal "/bin/sh"
      End
    End

    Context "when unknown format"
      process() { echo "dummy"; }

      It "calls current_shell_fallback_with_proc"
        When call current_shell "/usr/local/bin/shellspec" 111
        The stdout should equal "fallback"
      End
    End

    Context "when ps not found"
      process() { echo "dummy"; }

      It "calls current_shell_fallback_with_proc"
        When call current_shell "/usr/local/bin/shellspec" 111
        The stdout should equal "fallback"
      End
    End
  End

  Describe "current_shell_fallback_with_proc()"
    It "parses /proc/<PID>/cmdline"
      When call current_shell_fallback_with_proc "/usr/local/bin/shellspec" "$CMDLINE"
      The stdout should equal "/bin/sh"
    End
  End
End
