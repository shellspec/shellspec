#shellcheck shell=sh disable=SC2004

# busybox 1.1.3: `-A n`, `-t o1` not supported
# busybox 1.10.2: `od -b` not working properly
if echo | od -t o1 -v >/dev/null 2>&1; then
  od_command() { od -t o1 -v; }
else
  od_command() { od -b -v; }
fi

octal_dump() {
  od_command | {
    while IFS= read -r line; do
      eval "set -- $line"
      [ $# -gt 1 ] || continue
      shift
      while [ $# -gt 0 ]; do echo "$1" && shift; done
    done
  }
}

FNV_OFFSET_BASIS_32=2166136261
FNV_PRIME_32=16777619

fnv1() {
  hash=$FNV_OFFSET_BASIS_32
  while IFS= read -r oct; do
    hash=$(( (($hash * $FNV_PRIME_32) & 0xFFFFFFFF) ^ 0$oct ));
  done
  echo "$hash"
}

fnv1a() {
  hash=$FNV_OFFSET_BASIS_32
  while IFS= read -r oct; do
    hash=$(( ( ($hash ^ 0$oct) * $FNV_PRIME_32) & 0xFFFFFFFF ));
  done
  echo "$hash"
}

xorshift32() {
  y=$1
  y=$(( y ^ ((y << 13) & 0xFFFFFFFF) ))
  y=$(( y ^ (y >> 17) ))
  y=$(( y ^ ((y << 5) & 0xFFFFFFFF) ))
  echo "$y"
}
