#shellcheck shell=sh

set -eu

# shellcheck disable=SC2039
spec_helper_precheck() {
  minimum_version "$SHELLSPEC_VERSION"

  if [ "${PIPEFAIL:-}" ]; then
    if ( set -o pipefail ) 2>/dev/null; then
      info "pipefail enabled"
    else
      warn "pipefail is not available"
      unsetenv PIPEFAIL
    fi
  fi

  if [ "${EXTGLOB:-}" ]; then
    if shopt -s extglob 2>/dev/null; then
      info "extglob enabled"
      setenv EXTGLOB="extglob"
    elif setopt extendedglob 2>/dev/null; then
      info "extendedglob enabled"
      setenv EXTGLOB="extendedglob"
    else
      warn "extglob is not available"
      unsetenv EXTGLOB
    fi
  fi

  if [ "$SHELLSPEC_NOEXEC_TMPDIR" ]; then
    info "Some tests will be skipped" \
      "because the files under tmp direcotry cannot be executed"
  fi
}

# shellcheck disable=SC2039
spec_helper_loaded() {
  # http://redsymbol.net/articles/unofficial-bash-strict-mode/
  IFS="${SHELLSPEC_LF}${SHELLSPEC_TAB}"

  [ "${PIPEFAIL:-}" ] && set -o pipefail
  unset PIPEFAIL ||:

  case ${EXTGLOB:-} in
    extglob) shopt -s extglob ;;
    extendedglob) setopt extendedglob ;;
    ?*) echo "[error] EXTGLOB value is invalid: $EXTGLOB" >&2; exit 1
  esac
  unset EXTGLOB ||:
}

spec_helper_configure() {
  import 'support/custom_matcher'

  set_subject() {
    if subject > /dev/null; then
      SHELLSPEC_SUBJECT=$(subject; echo _)
      SHELLSPEC_SUBJECT=${SHELLSPEC_SUBJECT%_}
    else
      unset SHELLSPEC_SUBJECT ||:
    fi
  }

  set_status() {
    if status > /dev/null; then
      SHELLSPEC_STATUS=$(status; echo _)
      SHELLSPEC_STATUS=${SHELLSPEC_STATUS%_}
    else
      unset SHELLSPEC_STATUS ||:
    fi
  }

  set_stdout() {
    if stdout > /dev/null; then
      SHELLSPEC_STDOUT=$(stdout; echo _)
      SHELLSPEC_STDOUT=${SHELLSPEC_STDOUT%_}
    else
      unset SHELLSPEC_STDOUT ||:
    fi
  }

  set_fd() {
    SHELLSPEC_STDIO_FILE_BASE=$SHELLSPEC_WORKDIR
    if "fd$1" > /dev/null; then
      "fd$1" > "$SHELLSPEC_STDIO_FILE_BASE.fd-$1"
    else
      @rm -f "$SHELLSPEC_STDIO_FILE_BASE.fd-$1"
    fi
  }

  # modifier for test
  shellspec_syntax shellspec_modifier__modifier_
  shellspec_modifier__modifier_() {
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    shellspec_puts "$SHELLSPEC_SUBJECT"
  }

  shellspec_syntax shellspec_modifier__null_modifier_
  shellspec_modifier__null_modifier_() { :; }

  subject_mock() {
    shellspec_output() { shellspec_puts "$1" >&2; }
  }

  modifier_mock() {
    shellspec_output() { shellspec_puts "$1" >&2; }
  }

  matcher_mock() {
    shellspec_output() { shellspec_puts "$1" >&2; }
    shellspec_proxy "shellspec_matcher_do_match" "shellspec_matcher__match"
  }

  shellspec_syntax_alias 'shellspec_subject_switch' 'shellspec_subject_value'
  switch_on() { shellspec_if "$SHELLSPEC_SUBJECT"; }
  switch_off() { shellspec_unless "$SHELLSPEC_SUBJECT"; }

  posh_pattern_matching_bug() {
    # shellcheck disable=SC2194
    case "a[d]" in (*"a[d]"*) false; esac # posh <= 0.12.6
  }

  invalid_posix_parameter_expansion() {
    set -- "a*b" "a[*]"
    [ "${1#"$2"}" = "a*b" ] && return 1 || return 0
  }

  not_found_find() {
    "$SHELLSPEC_FIND" . -prune >/dev/null 2>&1 && return 1 || return 0
  }

  not_supported_find() {
    "$SHELLSPEC_FIND" -L . -prune >/dev/null 2>&1 && return 1 || return 0
  }

  readonly_malfunction() { [ "$SHELLSPEC_DEFECT_READONLY" ]; }
  posh_shell_flag_bug() { [ "$SHELLSPEC_DEFECT_SHELLFLAG" ]; }
  not_exist_failglob() { [ ! "$SHELLSPEC_FAILGLOB_AVAILABLE" ]; }
  busybox_w32() { [ "$SHELLSPEC_BUSYBOX_W32" ]; }
  exists_tty() { [ "$SHELLSPEC_TTY" ]; }
  not_exists_shopt() { [ ! "$SHELLSPEC_SHOPT_AVAILABLE" ]; }
  noexec_tmpdir() { [ "$SHELLSPEC_NOEXEC_TMPDIR" ]; }

  uppercase() {
    set -- aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ
    while IFS= read -r line; do
      for i; do shellspec_replace_all line "${i%?}" "${i#?}"; done
      echo "$line"
    done
  }

  shellspec_before :
  shellspec_after :

  before_each :
  after_each :
  before_all :
  after_all :
}
