#shellcheck shell=sh

set -eu

log() { echo "$@" > "$SHELLSPEC_DEV_TTY"; }

if [ "${PIPEFAIL:-}" ] && PIPEFAIL=''; then
  # shellcheck disable=SC2039
  if set -o pipefail 2>/dev/null; then
    log "pipefail enabled"
  fi
fi

if [ "${EXTGLOB:-}" ] && EXTGLOB=''; then
  # shellcheck disable=SC2039
  if shopt -s extglob 2>/dev/null; then
    log "extglob enabled"
  elif setopt extendedglob 2>/dev/null; then
    log "extendedglob enabled"
  fi
fi

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS="${SHELLSPEC_LF}${SHELLSPEC_TAB}"

# Workaround for ksh
shellspec_redefinable shellspec_puts
shellspec_redefinable shellspec_putsn
shellspec_redefinable shellspec_output
shellspec_redefinable shellspec_output_failure_message
shellspec_redefinable shellspec_output_failure_message_when_negated
shellspec_redefinable shellspec_on
shellspec_redefinable shellspec_off
shellspec_redefinable shellspec_yield
shellspec_redefinable shellspec_parameters
shellspec_redefinable shellspec_profile_start
shellspec_redefinable shellspec_profile_end
shellspec_redefinable shellspec_invoke_example
shellspec_redefinable shellspec_statement_evaluation
shellspec_redefinable shellspec_statement_preposition
shellspec_redefinable shellspec_append_shell_option
shellspec_redefinable shellspec_evaluation_cleanup
shellspec_redefinable shellspec_statement_ordinal
shellspec_redefinable shellspec_statement_subject
shellspec_redefinable shellspec_subject
shellspec_redefinable shellspec_syntax_dispatch
shellspec_redefinable shellspec_set_long
shellspec_redefinable shellspec_import
shellspec_redefinable shellspec_clone
shellspec_redefinable shellspec_clone_typeset
shellspec_redefinable shellspec_clone_set
shellspec_redefinable shellspec_clone_exists_variable

# Workaround for busybox-1.1.3, ksh88
shellspec_unbuiltin "ps"
shellspec_unbuiltin "last"
shellspec_unbuiltin "sleep"
shellspec_unbuiltin "date"
shellspec_unbuiltin "wget"
shellspec_unbuiltin "mkdir"
shellspec_unbuiltin "kill"
shellspec_unbuiltin "env"
shellspec_unbuiltin "cat"
shellspec_unbuiltin "od"
shellspec_unbuiltin "hexdump"
shellspec_unbuiltin "tar"

shellspec_spec_helper_configure() {
  shellspec_import 'support/custom_matcher'

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

  set_stderr() {
    if stderr > /dev/null; then
      SHELLSPEC_STDERR=$(stderr; echo _)
      SHELLSPEC_STDERR=${SHELLSPEC_STDERR%_}
    else
      unset SHELLSPEC_STDERR ||:
    fi
  }

  # modifier for test
  shellspec_syntax shellspec_modifier__modifier_
  shellspec_modifier__modifier_() {
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    shellspec_puts "$SHELLSPEC_SUBJECT"
  }

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

  readonly_malfunction() { [ "$SHELLSPEC_DEFECT_READONLY" ]; }
  posh_shell_flag_bug() { [ "$SHELLSPEC_DEFECT_SHELLFLAG" ]; }
  not_exist_failglob() { [ ! "$SHELLSPEC_FAILGLOB_AVAILABLE" ]; }
  busybox_w32() { [ "$SHELLSPEC_BUSYBOX_W32" ]; }
  exists_tty() { [ "$SHELLSPEC_TTY" ]; }
  not_exists_shopt() { [ ! "$SHELLSPEC_SHOPT_AVAILABLE" ]; }

  shellspec_before :
  shellspec_after :
  shellspec_before_all :
  shellspec_after_all :
}
