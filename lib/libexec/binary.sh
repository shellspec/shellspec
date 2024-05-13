#shellcheck shell=sh disable=SC2004

# busybox 1.1.3: `-A n`, `-t o1` not supported
# busybox 1.10.2: `od -b` not working properly
od_command() {
  od -t o1 -v 2>/dev/null && return 0
  [ $? -eq 127 ] && hexdump -b -v 2>/dev/null && return 0
  od -b -v
}

octal_dump() {
  od_command | (
    while IFS= read -r line; do
      eval "set -- $line"
      [ $# -gt 1 ] || continue
      shift
      while [ $# -gt 0 ]; do echo "$1" && shift; done
    done
  ) &&:
}
