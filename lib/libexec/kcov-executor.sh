#shellcheck shell=sh

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"

executor() {
  #shellcheck disable=SC2039
  [ "$(ulimit -n)" -lt 1024 ] && ulimit -n 1024

  # The directory of $SHELLSPEC_KCOV_IN_FILE should be empty.
  # kcov try to parse files around $SHELLSPEC_KCOV_IN_FILE.
  mkdir -p "${SHELLSPEC_KCOV_IN_FILE%/*}"
  translator --functrace --fd=537 "$@" > "$SHELLSPEC_KCOV_IN_FILE"

  #shellcheck disable=SC2039,SC2086
  "$SHELLSPEC_KCOV_PATH" \
    $SHELLSPEC_KCOV_COMMON_OPTS \
    $SHELLSPEC_KCOV_OPTS \
    --bash-method=DEBUG \
    --bash-parser="$SHELLSPEC_SHELL" \
    --bash-parse-files-in-dir=. \
    "$SHELLSPEC_COVERAGEDIR" "$SHELLSPEC_KCOV_IN_FILE" 537>&1

  # Fix symbolic link to relative path
  ( cd "$SHELLSPEC_COVERAGEDIR"
    if [ -L "$SHELLSPEC_KCOV_FILENAME" ]; then
      link=$(ls -dl "$SHELLSPEC_KCOV_FILENAME")
      link=${link#*" $SHELLSPEC_KCOV_FILENAME -> "}
      link=${link%/}
      link=${link##*/}
      rm "$SHELLSPEC_KCOV_FILENAME"
      ln -s "$link" "$SHELLSPEC_KCOV_FILENAME"
    fi
  )
}
