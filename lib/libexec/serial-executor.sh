#shellcheck shell=sh

executor() {
  translator --metadata "$@" | shell
}
