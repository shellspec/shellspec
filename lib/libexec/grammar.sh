#shellcheck shell=sh disable=SC2004,SC2016

define_block() {
  eval "$1() { case \$1 in ($2) return 0; esac; return 1; }"
}

define_blocks() {
  : "${SHELLSPEC_GRAMMAR_BLOCKS:="${1%.*}/blocks"}"
  varname="" dsl=""
  while IFS= read -r line; do
    case $line in ("" | \#*) continue; esac
    shellspec_trim varname "${line%::=*}"
    shellspec_trim dsl "${line#*::=}"
    echo "$varname=\"$dsl\""
    echo "define_block \"is_$varname\" \"\$$varname\""
  done < "$SHELLSPEC_GRAMMAR_BLOCKS" &&:
}
eval "$(define_blocks "$SHELLSPEC_SOURCE")"

define_dsls() {
  : "${SHELLSPEC_GRAMMAR_DSLS:="${1%.*}/dsls"}"
  : "${SHELLSPEC_GRAMMAR_DIRECTIVES:="${1%.*}/directives"}"
  dsls=''

  echo 'dsl() { case $1 in'

  while IFS= read -r line; do
    case $line in ("" | \#*) continue; esac
    dsls="$dsls${dsls:+|}${line%%\=\>*}"
    echo "${line%\=\>*}) ${line#*\=\>} \"\$2\" ;;"
  done < "$SHELLSPEC_GRAMMAR_DSLS" &&:

  while IFS= read -r line; do
    case $line in ("" | \#*) continue; esac
    echo "${line%\=\>*}) ${line#*\=\>} \"\$2\" ;;"
  done < "$SHELLSPEC_GRAMMAR_DIRECTIVES" &&:

  echo '*) return 1 ;; esac; }'
  echo "is_dsl() { case \$1 in ($dsls) true ;; (*) false ; esac; }"
}
eval "$(define_dsls "$SHELLSPEC_SOURCE")"

define_directives() {
  : "${SHELLSPEC_GRAMMAR_DIRECTIVES:="${1%.*}/directives"}"
  echo 'directive() { case $2 in'
  while IFS= read -r line; do
    case $line in ("" | \#*) continue; esac
    echo "${line%\=\>*}) with_function \"\$1\" ${line#*\=\>} \"\$3\" ;;"
  done < "$SHELLSPEC_GRAMMAR_DIRECTIVES" &&:
  echo '*) return 1 ;; esac; }'
}
eval "$(define_directives "$SHELLSPEC_SOURCE")"

mapping() {
  dsl "$@" && return 0
  case $1 in (*\(\))
    is_function_name "${1%??}" || return 1
    case ${2%%\%*} in (*[!\ \{]*) return 1; esac
    set -- "$1" "${2#"${2%%\%*}"}"
    set -- "$1" "${2%% *}" "${2#* }"
    directive "$@" && return 0
  esac
  return 1
}
