#shellcheck shell=sh

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"

use includes replace

kcov_preprocess() {
  [ -d "$SHELLSPEC_COVERAGE_DIR" ] || return 0

  # Cleanup previous coverage data
  rm -rf "${SHELLSPEC_COVERAGE_DIR:?}/${SHELLSPEC_KCOV_FILENAME:?}"*
}

executor() {
  #shellcheck disable=SC2039
  [ "$(ulimit -n)" -lt 1024 ] && ulimit -n 1024

  #shellcheck disable=SC2034
  SHELLSPEC_COVERAGE_SETUP="$SHELLSPEC_LIB/cov/kcov-setup.sh"
  #shellcheck disable=SC2034
  SHELLSPEC_COVERAGE_ENV="$SHELLSPEC_LIB/cov/kcov-env.sh"

  # The directory of $SHELLSPEC_KCOV_IN_FILE should be empty
  # kcov try to parse files around $SHELLSPEC_KCOV_IN_FILE
  mkdir -p "${SHELLSPEC_KCOV_IN_FILE%/*}"
  translator --coverage --fd=537 "$@" > "$SHELLSPEC_KCOV_IN_FILE"

  kcov_preprocess

  #shellcheck disable=SC2039,SC2086
  "$SHELLSPEC_KCOV_PATH" \
    $SHELLSPEC_KCOV_COMMON_OPTS \
    $SHELLSPEC_KCOV_OPTS \
    --bash-method=DEBUG \
    --bash-parser="$SHELLSPEC_SHELL" \
    --bash-parse-files-in-dir=. \
    --configure=command-name="shellspec $*" \
    "$SHELLSPEC_COVERAGE_DIR" "$SHELLSPEC_KCOV_IN_FILE" 537>&1

  kcov_postprocess
}

kcov_postprocess() {
  [ -d "$SHELLSPEC_COVERAGE_DIR" ] || return 0

  ( cd "$SHELLSPEC_COVERAGE_DIR"
    # Delete unnecessary files and directories
    rm -f bash-helper.sh bash-helper-debug-trap.sh libbash_execve_redirector.so
    rmdir kcov-merged ||:

    # Swap directory and symlink
    if [ -L "$SHELLSPEC_KCOV_FILENAME" ]; then
      link=$(ls -dl "$SHELLSPEC_KCOV_FILENAME")
      link=${link#*" $SHELLSPEC_KCOV_FILENAME -> "}
      link=${link%/} && link=${link##*/}
      set -- "$link" "$SHELLSPEC_KCOV_FILENAME"
      { rm "$2" && mv "$1" "$2" && ln -s "$2" "$1"; } ||:
      edit_in_place "index.json" kcov_fix_index "$1" "$2" # kcov version = v35
      edit_in_place "index.js" kcov_fix_index "$1" "$2" # kcov version >= v36
    fi

    # Replace physical path to logical path
    cd "$SHELLSPEC_PROJECT_ROOT"
    set -- "$(pwd -P)" "$(pwd -L)" "$SHELLSPEC_KCOV_FILENAME"
    cd "$SHELLSPEC_COVERAGE_DIR"
    for file in coverage.json sonarqube.xml cobertura.xml; do
      edit_in_place "$3/$file" "kcov_fix_${file%.*}" "$1" "$2"
      ln -snf "$3/$file" "$file" ||:
    done
  ) 2>/dev/null
}

kcov_fix_index() {
  while IFS= read -r line; do
    includes "$line" "\"link\":\"$1/" && replace line "$1" "$2"
    putsn "$line"
  done
}

kcov_fix_coverage() {
  while IFS= read -r line; do
    includes "$line" "\"file\": \"$1/" && replace line "$1" "$2"
    putsn "$line"
  done
}

kcov_fix_sonarqube() {
  while IFS= read -r line; do
    includes "$line" "<file path=\"$1/" && replace line "$1" "$2"
    putsn "$line"
  done
}

kcov_fix_cobertura() {
  while IFS= read -r line; do
    includes "$line" "<source>$1" && replace line "$1" "$2"
    includes "$line" "$2/</source>" && replace line "/</source>" "</source>"
    putsn "$line"
  done
}
