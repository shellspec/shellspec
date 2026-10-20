# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "default spec paths"
  setup_project() {
    PROJECT="$SHELLSPEC_WORKDIR/path-project"
    @mkdir -p "$PROJECT/spec" "$PROJECT/nested"
    : > "$PROJECT/.shellspec"
    : > "$PROJECT/spec/example_spec.sh"
    : > "$PROJECT/nested/local_spec.sh"
  }
  Before setup_project

  list_from_nested() {
    cd "$PROJECT/nested" || return
    @env "PATH=$SHELLSPEC_PATH" "$SHELLSPEC_SHELL" "$SHELLSPEC_ROOT/shellspec" --list specfiles "$@"
  }

  It "finds the default path relative to the project root"
    When run list_from_nested
    The status should be success
    The stdout should eq "spec/example_spec.sh"
    The stderr should be blank
  End

  It "expands default path patterns relative to the project root"
    When run list_from_nested --default-path "**/example_spec.sh"
    The status should be success
    The stdout should eq "spec/example_spec.sh"
    The stderr should be blank
  End

  It "keeps explicit paths relative to the invocation directory"
    When run list_from_nested ../spec
    The status should be success
    The stdout should eq "spec/example_spec.sh"
    The stderr should be blank
  End

  It "keeps explicit path patterns relative to the invocation directory"
    When run list_from_nested "**/local_spec.sh"
    The status should be success
    The stdout should eq "nested/local_spec.sh"
    The stderr should be blank
  End
End
