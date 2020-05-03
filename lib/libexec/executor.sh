#shellcheck shell=sh disable=SC2004

count_specfiles() {
  eval "$1=0; found_specfile() { $1=\$((\$$1 + 1)); }"
  shift
  eval find_specfiles found_specfile ${1+'"$@"'}
}

create_workdirs() {
  i=0
  while [ "$i" -lt "$1" ] && i=$(($i + 1)); do
    set -- "$@" "$SHELLSPEC_TMPBASE/$i"
  done
  shift
  [ $# -eq 0 ] || mkdir "$@"
}
