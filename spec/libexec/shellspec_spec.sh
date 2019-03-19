#shellcheck shell=sh

Describe "libexec/shellspec.sh"
  # shellcheck source=lib/libexec/shellspec.sh
  . "$SHELLSPEC_LIB/libexec/shellspec.sh"

  Describe "read_dot_file()"
    setup() { dot_shellspec="fixture/dot-shellspec"; }
    Before setup

    parser() {
      [ "$1" = "--require" ] && [ "$2" = "spec_helper" ] &&
      [ "$3" = "--format" ] && [ "$4" = "progress" ] &&
      [ $# -eq 4 ]
      echo ok
    }

    Example "read dot file"
      When call read_dot_file "$SHELLSPEC_SPECDIR" "$dot_shellspec" parser
      The stdout should equal "ok"
      The status should be success
    End

    Example "do not read dot file if not specified directory"
      When call read_dot_file "" "$dot_shellspec" parser
      The stdout should be blank
      The status should be success
    End
  End

  Describe "current_shell()"
    Context "parse procps format"
      fake_ps() {
        echo "PID TTY      STAT   TIME COMMAND"
        echo "  1 pts/0    Ss     0:00 -bash"
        echo "001 pts/0    R+     0:00 ps w"
        echo "002 ?        I<     0:00 [kworker/0:0H]"
        echo "003 ?        S      0:00 (sd-pam)"
        echo " $$ pts/0    S      0:00 /bin/sh /usr/local/bin/shellspec"
      }

      Example "and detect shell"
        When call current_shell "/usr/local/bin/shellspec" fake_ps
        The stdout should equal "/bin/sh"
      End
    End

    Context "parse busybox ps format"
      fake_ps() {
        echo "  PID USER       VSZ STAT COMMAND"
        echo "    1 root      1548 S    /sbin/init"
        echo "  001 root      1200 R    ps w"
        echo "   $$ root      1460 S    /bin/sh /usr/local/bin/shellspec"
      }

      Example "and detect shell"
        When call current_shell "/usr/local/bin/shellspec" fake_ps
        The stdout should equal "/bin/sh"
      End
    End

    Context "parse busybox ps format 2"
      fake_ps() {
        echo "  PID USER    TIME COMMAND"
        echo "    1 root    0:00 /bin/sh"
        echo "  001 root    0:00 ps w"
        echo "   $$ root    0:00 {shellspec} /bin/sh /usr/local/bin/shellspec"
      }

      Example "and detect shell"
        When call current_shell "/usr/local/bin/shellspec" fake_ps
        The stdout should equal "/bin/sh"
      End
    End
  End
End
