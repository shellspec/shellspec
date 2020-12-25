#shellcheck shell=sh disable=SC2016

case $MODE in
  abort:*) exit "${MODE#*:}"
esac

shellspec_precheck_precheck() {
  echo "precheck"
  case $MODE in
    exit:*) exit "${MODE#*:}" ;;
    return:*) return "${MODE#*:}" ;;
  esac
}
