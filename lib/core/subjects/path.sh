#shellcheck shell=sh

shellspec_syntax 'shellspec_subject_path'
shellspec_syntax_alias 'shellspec_subject_file' 'shellspec_subject_path'
shellspec_syntax_alias 'shellspec_subject_dir' 'shellspec_subject_path'
shellspec_syntax_alias 'shellspec_subject_directory' 'shellspec_subject_path'

shellspec_subject_path() {
  shellspec_syntax_param count [ $# -ge 1 ] || return 0

  # shellcheck disable=SC2034
  SHELLSPEC_META='path'
  SHELLSPEC_SUBJECT="$1"

  if shellspec_includes "$SHELLSPEC_PATH_ALIAS" "|$1="; then
    SHELLSPEC_SUBJECT=${SHELLSPEC_PATH_ALIAS#*"|$1="}
    SHELLSPEC_SUBJECT=${SHELLSPEC_SUBJECT%%\|*}
  fi

  shift

  eval shellspec_syntax_dispatch modifier ${1+'"$@"'}
}
