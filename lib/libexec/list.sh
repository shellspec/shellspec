#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
load binary

shuffle() {
  octal_dump | {
    FNV_OFFSET_BASIS_32=2166136261
    FNV_PRIME_32=16777619

    seed=$(puts "${1:-}" | octal_dump | {
      hash=$FNV_OFFSET_BASIS_32
      while IFS= read -r oct; do
        hash=$(( ( ($hash ^ 0$oct) * $FNV_PRIME_32) & 0xFFFFFFFF ))
      done
      echo "$hash"
    })

    hash=$seed filename='' printf_octal_bug=''
    [ "$(printf '\101' 2>/dev/null ||:)" = "A" ] || printf_octal_bug=0

    while IFS= read -r oct; do
      case $oct in
        012)
          # xorshift32
          hash=$(( $hash ^ (($hash << 13) & 0xFFFFFFFF) ))
          hash=$(( $hash ^ ($hash >> 17) ))
          hash=$(( $hash ^ (($hash << 5) & 0xFFFFFFFF) ))
          printf "%010d $filename\n" "$hash"
          hash=$seed filename=''
          continue ;;
        1??) filename="$filename\\$printf_octal_bug$oct" ;;
        *  ) filename="$filename\\$oct" ;;
      esac
      # fnv1a
      hash=$(( ( ($hash ^ 0$oct) * $FNV_PRIME_32) & 0xFFFFFFFF ))
    done | sort | while IFS= read -r line; do putsn "${line#* }"; done
  }
}
