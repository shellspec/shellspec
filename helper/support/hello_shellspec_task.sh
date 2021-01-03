#shellcheck shell=sh

set -eu

task "hello:shellspec" "Example task"

hello_shellspec_task() {
  echo "Hello ShellSpec"
}
