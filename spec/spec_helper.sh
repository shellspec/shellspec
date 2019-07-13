#shellcheck shell=sh

set -eu

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS="$SHELLSPEC_LF$SHELLSPEC_TAB"

shellspec_redefinable shellspec_output
shellspec_redefinable shellspec_output_failure_message
shellspec_redefinable shellspec_output_failure_message_when_negated
shellspec_redefinable shellspec_on
shellspec_redefinable shellspec_off
shellspec_redefinable shellspec_is
shellspec_redefinable shellspec_syntax_dispatch
shellspec_redefinable shellspec_callback

shellspec_spec_helper_configure() {
  shellspec_import 'support/custom_matcher'

  set_subject() {
    shellspec_capture SHELLSPEC_SUBJECT subject
  }

  set_status() {
    shellspec_capture SHELLSPEC_STATUS status
  }

  set_stdout() {
    shellspec_capture SHELLSPEC_STDOUT stdout
  }

  set_stderr() {
    shellspec_capture SHELLSPEC_STDERR stderr
  }

  # modifier for test
  shellspec_syntax shellspec_modifier__modifier_
  shellspec_modifier__modifier_() {
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    shellspec_puts "$SHELLSPEC_SUBJECT"
  }

  intercept_shellspec_subject() {
    shellspec_around_invoke() {
      shellspec_output() { shellspec_puts "$1" >&2; }
      "$@"
    }
  }

  intercept_shellspec_modifier() {
    shellspec_around_invoke() {
      shellspec_output() { shellspec_puts "$1" >&2; }
      "$@"
    }
  }

  intercept_shellspec_matcher() {
    shellspec_around_invoke() {
      shellspec_output() { shellspec_puts "$1" >&2; }
      shellspec_is() { shellspec_puts "is:" "$@"; }
      shellspec_proxy "shellspec_matcher_do_match" \
                      "shellspec_matcher_do_match_positive"
      "$@"
      shellspec_if MATCHED
    }
  }

  shellspec_syntax_alias 'shellspec_subject_switch' 'shellspec_subject_value'
  switch_on() { shellspec_if "$SHELLSPEC_SUBJECT"; }
  switch_off() { shellspec_unless "$SHELLSPEC_SUBJECT"; }

  # shellcheck disable=SC2034
  LF="$SHELLSPEC_LF" TAB="$SHELLSPEC_TAB"

  posh_pattern_matching_bug() {
    # shellcheck disable=SC2194
    case "a[d]" in (*"a[d]"*) false; esac # posh <= 0.12.6
  }

  accuracy_error_bug() { # ksh on Ubuntu 18.04 on WSL
    [ "$((99999999 * 999999999))" = "99999998900000000" ]
  }

  xor_not_support_bug() { # ash 0.3.8
    if (eval ': $((0^0))') 2>/dev/null; then false; else true; fi
  }

  miscalculate_signed_32bit_int_bug() { # yash 2.30 ans = -2147483648
    ans=$((21474836478 ^ 0))
    [ "$ans" = 21474836478 ] && return 1
    [ "$ans" = -2 ] && return 1
    return 0
  }

  #shellcheck disable=SC2034
  if ( ( readonly A ) 2>/dev/null ); then
    old_ksh_readonly_bug() { false; }
  else
    old_ksh_readonly_bug() { true; }
  fi

  old_pdksh_readonly_bug() {
    # shellcheck disable=SC2034
    [ "$( ( readonly old_pdksh_readonly_bug=123 ) 2>&1 )" ]
  }
}
