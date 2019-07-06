#shellcheck shell=sh

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"

executor() {
  translator --functrace --fd=537 "$@" > "$SHELLSPEC_KCOV_IN_FILE"
  #shellcheck disable=SC2039,SC2086
  "$SHELLSPEC_KCOV_PATH" --bash-method=DEBUG \
    --bash-parser="$SHELLSPEC_SHELL" \
    --bash-parse-files-in-dir="$SHELLSPEC_PROJECT_ROOT" \
    $SHELLSPEC_KCOV_COMMON_OPTS $SHELLSPEC_KCOV_OPTS \
    "$SHELLSPEC_COVERAGEDIR" "$SHELLSPEC_KCOV_IN_FILE" 537>&1
}
