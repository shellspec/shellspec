#shellcheck shell=sh

# to suppress shellcheck SC2034
: "${SHELLSPEC_META:-}"

shellspec_syntax 'shellspec_modifier_contents'
shellspec_syntax 'shellspec_modifier_entire_contents'

shellspec_modifier_contents() {
  SHELLSPEC_META='text'
  if [ "${SHELLSPEC_SUBJECT+x}" ] && [ -e "${SHELLSPEC_SUBJECT:-}" ]; then
    shellspec_readfile SHELLSPEC_SUBJECT "$SHELLSPEC_SUBJECT"
    SHELLSPEC_SUBJECT=$SHELLSPEC_SUBJECT
    shellspec_chomp SHELLSPEC_SUBJECT
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}

shellspec_modifier_entire_contents() {
  SHELLSPEC_META='text'
  if [ "${SHELLSPEC_SUBJECT+x}" ] && [ -e "$SHELLSPEC_SUBJECT" ]; then
    shellspec_readfile SHELLSPEC_SUBJECT "$SHELLSPEC_SUBJECT"
  else
    unset SHELLSPEC_SUBJECT ||:
  fi

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
