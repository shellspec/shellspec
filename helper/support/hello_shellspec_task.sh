#shellcheck shell=sh

set -eu

task "hello:shellspec" "Sample task"

hello_shellspec_task() {
  echo "Hello ShellSpec"
}
