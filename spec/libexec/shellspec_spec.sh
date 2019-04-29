#shellcheck shell=sh

% DOT_SHELLSPEC: "fixture/dot-shellspec"
% CMDLINE: "$SHELLSPEC_SPECDIR/fixture/proc/cmdline"

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

  Describe "read_cmdline()"
    It "parses /proc/<PID>/cmdline"
      When call read_cmdline "$CMDLINE"
      The stdout should equal "/bin/sh /usr/local/bin/shellspec "
    End
  End

  Describe "read_ps()"
    Context "when procps format"
      process() {
        %text
        #|UID PID PPID C STIME TTY      STAT   TIME CMD
        #|uid   1    2 C Apr30 pts/0    Ss     0:00 -bash
        #|uid 001    1 C Apr30 pts/0    R+     0:00 ps -f
        #|uid 002    2 C Apr30 ?        I<     0:00 [kworker/0:0H]
        #|uid 003    3 C Apr30 ?        S      0:00 (sd-pam)
        #|uid 111    4 C Apr30 pts/0    S      0:00 /bin/sh /usr/local/bin/shellspec
      }


      It "parses and detects shell"
        When call read_ps 111
        The stdout should equal "/bin/sh /usr/local/bin/shellspec"
      End
    End

    Context "when busybox ps format 1"
      process() {
        %text
        #|  PID  Uid     VmSize Stat Command
        #|   88 root       1808 R   ps -f
        #|  111 root       1520 S   /bin/sh /usr/local/bin/shellspec
      }

      It "parses and detects shell"
        When call read_ps 111
        The stdout should equal "/bin/sh /usr/local/bin/shellspec"
      End
    End

    Context "when busybox ps format 2"
      process() {
        %text
        #|  PID USER       VSZ STAT COMMAND
        #|    1 root      1548 S    /sbin/init
        #|  001 root      1200 R    ps -f
        #|  111 root      1460 S    /bin/sh /usr/local/bin/shellspec
      }

      It "parses and detects shell"
        When call read_ps 111
        The stdout should equal "/bin/sh /usr/local/bin/shellspec"
      End
    End

    Context "when busybox ps format 3"
      process() {
        %text
        #|  PID USER    COMMAND
        #|    1 root    /bin/sh
        #|  001 root    ps -f
        #|  111 root    {shellspec} /bin/sh /usr/local/bin/shellspec
      }

      It "parses and detects shell"
        When call read_ps 111
        The stdout should equal "/bin/sh /usr/local/bin/shellspec"
      End
    End
  End

  Describe "current_shell()"
    read_cmdline() { echo "/bin/sh /usr/local/bin/shellspec spec "; }

    It "removes arguments"
      When call current_shell "/usr/local/bin/shellspec" 111
      The stdout should equal "/bin/sh"
    End

    Context "when read_cmdline empty string"
      read_cmdline() { :; }
      read_ps() { echo ps; }

      It "calls read_ps"
        When call current_shell "/usr/local/bin/shellspec" 111
        The stdout should equal "ps"
      End
    End

    Context "when read_cmdline return string"
      read_cmdline() { echo 'cmdline'; }
      read_ps() { echo ok; }

      It "does not call read_ps"
        When call current_shell "/usr/local/bin/shellspec" 111
        The stdout should equal "cmdline"
      End
    End
  End
End
