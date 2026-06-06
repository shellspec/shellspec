# shellcheck shell=sh disable=SC2016,SC2286,SC2287,SC2288

Describe "shellspec --random"
  # Regression: SHELLSPEC_INFILE defaulted to the relative path "file", so the
  # runner's spec-list write under --random landed in the working directory,
  # leaving a stray "file" behind (and clobbering any existing ./file). The
  # write happens for any random type, so exercise both. Assert the working
  # directory gains no unexpected entries, not just that "file" is absent.
  Parameters
    specfiles
    examples
  End

  It "does not write to the working directory (--random $1)"
    random_type=$1
    project="$SHELLSPEC_WORKDIR/random_$random_type"
    @mkdir -p "$project/spec"
    : >"$project/.shellspec"
    {
      echo "Describe 'sample'"
      echo "  It 'passes'"
      echo "    When call true"
      echo "    The status should be success"
      echo "  End"
      echo "End"
    } >"$project/spec/sample_spec.sh"

    # A fresh `$shell -c` gets a writable PATH (the sandbox's read-only PATH does
    # not survive exec), so the nested binary can find its helper commands. Clear
    # the outer shellspec's SHELLSPEC_* env so the nested run derives its own
    # paths, run it from inside the project, then print any working-directory
    # entries beyond the two we created (a stray "file" would show up here).
    run_in_project() {
      "$SHELLSPEC_SHELL" -c '
        PATH=$1
        cd "$2" || exit 1
        random=$3
        shift 3
        for v in $(env | sed -n "s/^\(SHELLSPEC_[A-Za-z0-9_]*\)=.*/\1/p"); do
          unset "$v"
        done
        "$@" --random "$random" >/dev/null 2>&1 || exit 1
        ls -A | grep -vxE "\.shellspec|spec" || true
      ' shellspec-cli "$SHELLSPEC_POSIX_PATH" "$project" "$random_type" \
        "$SHELLSPEC_SHELL" "$SHELLSPEC_ROOT/shellspec" \
        --shell "$SHELLSPEC_SHELL" --fail-no-examples
    }

    When run run_in_project
    The status should be success
    The output should equal ""
  End
End
