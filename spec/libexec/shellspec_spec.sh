#shellcheck shell=sh disable=SC2004,SC2016

% BIN: "$SHELLSPEC_HELPERDIR/fixture/bin"
% DOT_SHELLSPEC: "fixture/dot-shellspec"
% CMDLINE: "$SHELLSPEC_HELPERDIR/fixture/proc/cmdline"
% PROC: "$SHELLSPEC_HELPERDIR/fixture/proc/"
% FINDDIRS: "$SHELLSPEC_HELPERDIR/fixture/finddirs"

Describe "libexec/shellspec.sh"
  Include "$SHELLSPEC_LIB/libexec/shellspec.sh"

  Describe "pack()"
    _packs() {
      var=''
      for i; do pack var "$i"; done
      eval "set -- $var"
      %printf '%s\n' "$@"
    }
    It "packs the values into the variable"
      When call _packs "a" "foo bar" "foo'bar" 'foo"bar'
      The line 1 of stdout should equal "a"
      The line 2 of stdout should equal "foo bar"
      The line 3 of stdout should equal "foo'bar"
      The line 4 of stdout should equal 'foo"bar'
    End
  End

  Describe "read_options_file()"
    parser() { printf '%s\n' "$@"; }

    It "reads options file"
      When call read_options_file "$SHELLSPEC_HELPERDIR/$DOT_SHELLSPEC" parser
      The line 1 of stdout should equal "--require"
      The line 2 of stdout should equal "spec_helper"
      The line 3 of stdout should equal "--format"
      The line 4 of stdout should equal "progress"
      The line 5 of stdout should equal "--pattern"
      The line 6 of stdout should equal "*_spec.sh"
      The line 7 of stdout should equal "--env"
      The line 8 of stdout should equal "TEST=a b c"
      The lines of stdout should equal 8
      The status should be success
    End

    It "does not read options file if not exist file"
      When call read_options_file "$DOT_SHELLSPEC" parser
      The stdout should be blank
      The status should be success
    End
  End

  Describe "enum_options_file()"
    callback() { printf '%s\n' "$@"; }

    Context 'When HOME environemnt variable exists, XDG_CONFIG_HOME not exists'
      Before HOME=/home/user XDG_CONFIG_HOME=''
      It "enumerates options file"
        When call enum_options_file callback
        The line 1 of stdout should eq "/home/user/.config/shellspec/options"
        The line 2 of stdout should eq "/home/user/.shellspec"
        The line 3 of stdout should eq "/home/user/.shellspec-options"
        The line 4 of stdout should eq ".shellspec"
        The line 5 of stdout should eq ".shellspec-local"
        The lines of stdout should eq 5
      End
    End

    Context 'When HOME, XDG_CONFIG_HOME environemnt variable exists'
      Before HOME=/home/user XDG_CONFIG_HOME=/home/user/config
      It "enumerates options file"
        When call enum_options_file callback
        The line 1 of stdout should eq "/home/user/config/shellspec/options"
        The line 2 of stdout should eq "/home/user/.shellspec"
        The line 3 of stdout should eq "/home/user/.shellspec-options"
        The line 4 of stdout should eq ".shellspec"
        The line 5 of stdout should eq ".shellspec-local"
        The lines of stdout should eq 5
      End
    End

    Context 'When HOME environemnt variable not exists'
      Before HOME='' XDG_CONFIG_HOME=''
      It "enumerates options file"
        When call enum_options_file callback
        The line 1 of stdout should eq ".shellspec"
        The line 2 of stdout should eq ".shellspec-local"
        The lines of stdout should eq 2
      End
    End
  End

  Describe "read_cmdline()"
    od() { @od "$@"; }
    hexdump() { @hexdump "$@"; }

    It "parses /proc/<PID>/cmdline"
      When call read_cmdline "$CMDLINE"
      The stdout should equal "/bin/sh /usr/local/bin/shellspec "
    End
  End

  Describe "read_ps()"
    Context "when procps format"
      ps() {
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
      ps() {
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
      ps() {
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
      ps() {
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

    Context "when unknown format"
      ps() {
        %text
        #|  P1D U5ER    COMMAND
        #|    1 root
        #|  001 root
        #|  111 root
      }

      It "returns nothing"
        When call read_ps 111
        The status should be success
        The stdout should equal ""
      End
    End

    Context "when ps command fails"
      ps() { echo "unknown option" >&2; exit 1; }
      It "returns nothing"
        When call read_ps 111
        The status should be success
        The stdout should equal ""
      End
    End

    Context "when ps command not found"
      ps() { exit 127; }
      It "returns nothing"
        When call read_ps 111
        The status should be success
        The stdout should equal ""
      End
    End
  End

  Describe "is_wsl()"
    Parameters
      version_linux failure
      version_wsl   success
    End

    It "detects WSL"
      # shellcheck disable=SC2034
      SHELLSPEC_PROC_VERSION="$PROC/$1"
      When call is_wsl
      The status should be "$2"
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

  Describe "command_path()"
    setup() { ret=''; }
    Before setup

    It "checks command exists"
      When call command_path "cat"
      The status should be success
    End

    It "outputs absolute path"
      When call command_path ret "cat"
      The variable ret should end with "/cat"
      The path "$ret" should be executable
    End

    It "return failure when not found command"
      BeforeCall ret="dummy"
      When call command_path no-such-a-command
      The status should be failure
      The variable ret should equal "dummy"
    End

    Context "when specified absolute path"
      It "outputs absolute path"
        When call command_path ret "$SHELLSPEC_SUPPORT_BINDIR/cat"
        The variable ret should end with "/cat"
        The path "$ret" should be executable
      End

      It "return failure when not found command"
        When call command_path ret "$SHELLSPEC_SUPPORT_BINDIR/no-such-a-file"
        The status should be failure
        The variable ret should eq ""
      End
    End
  End

  Describe "finddirs()"
    _finddirs() { "$@" | @sort; }

    Describe "finddirs fallbacks"
      finddirs_lssort() { echo lssort; }
      finddirs_find() { echo find; }
      finddirs_native() { echo native; }

      Context "when not WSL"
        is_wsl() { false; }

        It "calls finddirs_find"
          When call finddirs "path"
          The output should eq "find"
        End

        It "calls finddirs_find"
          When call finddirs "path" follow
          The output should eq "find"
        End
      End

      Context "when WSL"
        is_wsl() { true; }

        It "calls finddirs_find"
          When call finddirs "path"
          The output should eq "find"
        End

        It "calls finddirs_lssort"
          When call finddirs "path" follow
          The output should eq "lssort"
        End
      End

      Context "when find fails"
        is_wsl() { false; }
        finddirs_find() { echo "error" >&2; false; }

        It "fallback to finddirs_lssort"
          When call finddirs "path"
          The output should eq "lssort"
        End
      End

      Context "when find and lssort fails"
        is_wsl() { false; }
        finddirs_find() { echo "error" >&2; false; }
        finddirs_lssort() { echo "error" >&2; false; }

        It "fallback to finddirs_native"
          When call finddirs "path"
          The output should eq "native"
        End
      End
    End

    Parameters
      finddirs_native
      finddirs_lssort
      finddirs_find
      finddirs
    End

    It 'finds directories'
      if [ "$1" = "finddirs_find" ]; then
        Skip if "find is not found" not_found_find
      fi
      When call _finddirs "$1" "$FINDDIRS"
      The line 1 should eq "."
      The line 2 should eq "./dir1"
      The line 3 should eq "./dir1/dir1-1"
      The line 4 should eq "./dir1/dir1-2"
      The line 5 should eq "./dir2"
      The line 6 should eq "./dir2/dir2-1"
      The line 7 should eq "./dir2/dir2-2"
      The line 8 should eq "./dir3"
      The lines of stdout should eq 8
    End

    It 'follows symlinks and finds directories'
      Skip if "busybox-w32 not supported" busybox_w32
      if [ "$1" = "finddirs_find" ]; then
        Skip if "find is not found or not supported" not_supported_find
      fi
      When call _finddirs "$1" "$FINDDIRS" follow
      The line 1 should eq "."
      The line 2 should eq "./dir1"
      The line 3 should eq "./dir1/dir1-1"
      The line 4 should eq "./dir1/dir1-2"
      The line 5 should eq "./dir2"
      The line 6 should eq "./dir2/dir2-1"
      The line 7 should eq "./dir2/dir2-2"
      The line 8 should eq "./dir3"
      The line 9 should eq "./dir3/dir1"
      The line 10 should eq "./dir3/dir1/dir1-1"
      The line 11 should eq "./dir3/dir1/dir1-2"
      The line 12 should eq "./dir3/dir2"
      The line 13 should eq "./dir3/dir2/dir2-1"
      The line 14 should eq "./dir3/dir2/dir2-2"
      The lines of stdout should eq 14
    End
  End

  Describe "includes_pathstar()"
    Parameters
      "*/path"  success
      "**/path" success
      "path"    failure
    End

    It "checks includes pathstar ($1)"
      When call includes_pathstar "$1"
      The status should be "$2"
    End
  End

  Describe "check_pathstar()"
    Parameters
      "*/path"  success
      "*/path/" success
      "*/"      failure
      "*/*"     failure
      "*/pa*th" failure
    End

    It "checks pathstar ($1)"
      When call check_pathstar "$1"
      The status should be "$2"
    End
  End

  Describe "expand_pathstar()"
    Before SHELLSPEC_DEREFERENCE=''
    setup() {
      count=0
      cd "$FINDDIRS" || exit $?

      callback() {
        if [ ! "$2" ] || [ -e "$1" ]; then
          echo "$1 ($2)"
          count=$(($count+1))
        fi
      }
    }
    Before setup

    It "expands the pattern */"
      When call expand_pathstar callback "." a "*/*/.ignore" b
      The line 1 should eq "a ()"
      The line 2 should eq "b ()"
      The line 3 should eq "dir1/dir1-1/.ignore (*/*/.ignore)"
      The line 4 should eq "dir1/dir1-2/.ignore (*/*/.ignore)"
      The line 5 should eq "dir2/dir2-1/.ignore (*/*/.ignore)"
      The line 6 should eq "dir2/dir2-2/.ignore (*/*/.ignore)"
      The variable count should eq 6
    End

    It "expands the pattern **/"
      When call expand_pathstar callback "." a "**/.ignore" b
      The line 1 should eq "a ()"
      The line 2 should eq "b ()"
      The line 3 should eq "dir1/dir1-1/.ignore (**/.ignore)"
      The line 4 should eq "dir1/dir1-2/.ignore (**/.ignore)"
      The line 5 should eq "dir2/dir2-1/.ignore (**/.ignore)"
      The line 6 should eq "dir2/dir2-2/.ignore (**/.ignore)"
      The variable count should eq 6
    End

    It "expands the pattern */**/"
      When call expand_pathstar callback "." a "*/**/.ignore" b
      The line 1 should eq "a ()"
      The line 2 should eq "b ()"
      The line 3 should eq "dir1/dir1-1/.ignore (*/**/.ignore)"
      The line 4 should eq "dir1/dir1-2/.ignore (*/**/.ignore)"
      The line 5 should eq "dir2/dir2-1/.ignore (*/**/.ignore)"
      The line 6 should eq "dir2/dir2-2/.ignore (*/**/.ignore)"
      The variable count should eq 6
    End

    Context 'when --dereference option specified'
      Before SHELLSPEC_DEREFERENCE=1
      It "expands the pattern **/"
        When call expand_pathstar callback "." a "**/.ignore" b
        The line 1 should eq "a ()"
        The line 2 should eq "b ()"
        The line 3 should eq "dir1/dir1-1/.ignore (**/.ignore)"
        The line 4 should eq "dir1/dir1-2/.ignore (**/.ignore)"
        The line 5 should eq "dir2/dir2-1/.ignore (**/.ignore)"
        The line 6 should eq "dir2/dir2-2/.ignore (**/.ignore)"
        The line 7 should eq "dir3/dir1/dir1-1/.ignore (**/.ignore)"
        The line 8 should eq "dir3/dir1/dir1-2/.ignore (**/.ignore)"
        The line 9 should eq "dir3/dir2/dir2-1/.ignore (**/.ignore)"
        The line 10 should eq "dir3/dir2/dir2-2/.ignore (**/.ignore)"
        The variable count should eq 10
      End
    End
  End

  Describe "is_path_in_project()"
    Parameters
      "/path/to/project"        "/path/to/project"  success
      "/path/to/project/file"   "/path/to/project"  success
      "/path/to/project-file"   "/path/to/project"  failure
      "/spec"                   "/"                 success
    End

    It "checks path is in the project ($1)"
      When call is_path_in_project "$1" "$2"
      The status should be "$3"
    End
  End

  Describe "separate_abspath_and_range()"
    Parameters
      "/path/to/spec"           "/path/to/spec" ""
      "/path/to/spec:100"       "/path/to/spec" "100"
      "D:/path/to/spec"         "D:/path/to/spec" ""
      "D:/path/to/spec:100"     "D:/path/to/spec" "100"
      "//unc/path/to/spec"      "//unc/path/to/spec" ""
      "//unc/path/to/spec:100"  "//unc/path/to/spec" "100"
    End

    It "separates abspath and range ($1)"
      When call separate_abspath_and_range abspath range "$1"
      The variable abspath should eq "$2"
      The variable range should eq "$3"
    End
  End

  Describe "check_range()"
    Parameters
      ""          success
      "100"       success
      "100:200"   success
      "100:a"     failure
      "100:@1-1"  success
      "100:@a"    failure
    End

    It "checks range ($1)"
      When call check_range "$1"
      The status should be "$2"
    End
  End

  Describe "random_seed()"
    MAX_64BIT_PID=4194304

    Parameters
       1577936096 "$MAX_64BIT_PID" 14198 # 2020-01-02 12:34:56
       3000512096 "$MAX_64BIT_PID"  8144 # 2065-01-30 12:34:56
      11847440096 "$MAX_64BIT_PID" 98090 # 2345-06-07 12:34:56
    End

    It "returns random seed (unixtime: $1, pid:$2)"
      When call random_seed var "$1" "$2"
      The variable var should eq "$3"
    End
  End

  Describe "kcov_version()"
    Context 'when kcov not found'
      command_path() { return 1; }

      It 'returns failure'
        When run kcov_version fake_kcov
        The status should be failure
      End
    End

    Context 'when kcov exists'
      command_path() { return 0; }

      It 'returns version if --version not implemented'
        fake_kcov() { echo "kcov v35"; }
        When run kcov_version fake_kcov
        The stdout should eq "kcov v35"
        The status should be success
      End

      It 'returns empty string if --version not implemented'
        fake_kcov() {
          echo "Usage: kcov"
          echo "--version not implemented" >&2
          return 1
        }
        When run kcov_version fake_kcov
        The stdout should eq ''
        The stderr should eq ''
        The status should be success
      End
    End
  End

  Describe "kcov_version_number()"
    Parameters
      "" 0
      "v35" 35
      "kcov v35" 35
      "kcov v37-4-gbd3a" 37
    End

    It "returns version number ($1)"
      When run kcov_version_number "$1"
      The stdout should eq "$2"
    End
  End
End
