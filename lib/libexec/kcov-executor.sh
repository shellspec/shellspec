#shellcheck shell=sh

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"

kcov_prepare() {
  [ -d "$SHELLSPEC_COVERAGE_DIR" ] || return 0

  ( cd "$SHELLSPEC_COVERAGE_DIR"

    # Cleanup previous coverage data
    if [ -L "$SHELLSPEC_KCOV_FILENAME" ]; then
      link=$(ls -dl "$SHELLSPEC_KCOV_FILENAME")
      link=${link#*" $SHELLSPEC_KCOV_FILENAME -> "}
      rm -rf "$link"
    fi
  )
}

executor() {
  #shellcheck disable=SC2039
  [ "$(ulimit -n)" -lt 1024 ] && ulimit -n 1024

  kcov_prepare

  #shellcheck disable=SC2034
  SHELLSPEC_COVERAGE_SETUP="$SHELLSPEC_LIB/cov/kcov-setup.sh"
  #shellcheck disable=SC2034
  SHELLSPEC_COVERAGE_ENV="$SHELLSPEC_LIB/cov/kcov-env.sh"

  # The directory of $SHELLSPEC_KCOV_IN_FILE should be empty
  # kcov try to parse files around $SHELLSPEC_KCOV_IN_FILE
  mkdir -p "${SHELLSPEC_KCOV_IN_FILE%/*}"
  translator --coverage --fd=537 "$@" > "$SHELLSPEC_KCOV_IN_FILE"

  #shellcheck disable=SC2039,SC2086
  "$SHELLSPEC_KCOV_PATH" \
    $SHELLSPEC_KCOV_COMMON_OPTS \
    $SHELLSPEC_KCOV_OPTS \
    --bash-method=DEBUG \
    --bash-parser="$SHELLSPEC_SHELL" \
    --bash-parse-files-in-dir=. \
    --configure=command-name="shellspec $*" \
    "$SHELLSPEC_COVERAGE_DIR" "$SHELLSPEC_KCOV_IN_FILE" 537>&1

  kcov_cleanup
}

kcov_cleanup() {
  [ -d "$SHELLSPEC_COVERAGE_DIR" ] || return 0

  ( cd "$SHELLSPEC_COVERAGE_DIR"

    # Fix symbolic link to relative path
    if [ -L "$SHELLSPEC_KCOV_FILENAME" ]; then
      link=$(ls -dl "$SHELLSPEC_KCOV_FILENAME")
      link=${link#*" $SHELLSPEC_KCOV_FILENAME -> "}
      link=${link%/}
      link=${link##*/}
      rm "$SHELLSPEC_KCOV_FILENAME" 2>/dev/null ||:
      set -- "$link" "$SHELLSPEC_KCOV_FILENAME"
      ln -snf "$@" 2>/dev/null ||:
      kcov_fix_path index.json "$@" # kcov v35 only
      kcov_fix_path index.js "$@"
    fi

    # Delete unnecessary files
    rm bash-helper.sh 2>/dev/null ||:
    rm bash-helper-debug-trap.sh 2>/dev/null ||:
    rm libbash_execve_redirector.so 2>/dev/null ||:
    rmdir kcov-merged 2>/dev/null ||:
  )
}

kcov_fix_path() {
  [ -e "$1" ] || return 0
  data=''
  while IFS= read -r line; do
    case $line in (*"$2"*)
      line="${line%%"$2"*}$3${line#*"$2"}"
    esac
    data="$data$line$SHELLSPEC_LF"
  done < "$1"
  echo "$data" > "$1"
}
