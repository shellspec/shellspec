#shellcheck shell=sh

Describe "libexec/runner.sh"
  Include "$SHELLSPEC_LIB/libexec/runner.sh"

  change_permission() {
    chmod "$1" "$2"
    perm=$(ls -dl "$2")
    echo "${perm%"${perm#??????????}"}"
  }

  check_change_permission() {
    file="$SHELLSPEC_TMPBASE/check_change_permission"
    : > "$file"
    perm1=$(change_permission 644 "$file")
    perm2=$(change_permission 666 "$file")
    [ "$perm1 : $perm2" != "-rw-r--r-- : -rw-rw-rw-" ]
  }

  Describe "mktempdir()"
    Skip if 'can not change permission' check_change_permission

    Before prepare
    prepare() { dir="$SHELLSPEC_TMPBASE/mktempdir_test"; }
    entry() { ls -dl "$dir"; }

    It "makes tempdir"
      When call mktempdir "$dir"
      The status should be success
      The result of 'entry()' should start with 'drwx------'
    End
  End

  Describe "rmtempdir()"
    Before prepare
    prepare() {
      dir="$SHELLSPEC_TMPBASE/rmtempdir_test"
      mktempdir "$dir"
      [ -d "$dir" ] && [ -w "$dir" ]
    }

    It "deletes tempdir"
      Path tempdir="$dir"
      When call rmtempdir "$dir"
      The status should be success
      The path tempdir should not be exist
    End
  End
End
