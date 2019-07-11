#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
load binary

FNV_OFFSET_BASIS_32=2166136261
FNV_PRIME_32=16777619

shuffle() {
  OCT='0' HEX='0x'
  (eval ': $((16#FF))') 2>/dev/null && OCT='8#' HEX='16#'

  octal_dump | {
    seed=$(puts "${1:-}" | octal_dump | gen_seed)
    hash=$seed filename='' printf_octal_bug=''
    [ "$(printf '\101' 2>/dev/null ||:)" = "A" ] || printf_octal_bug=0

    while IFS= read -r oct; do
      case $oct in
        012)
          # xorshift32
          hash=$(( $hash ^ ((($hash & ${HEX}7FFFF) << 13) & ${HEX}FFFFFFFF) ))
          hash=$(( $hash ^ (($hash >> 17) & ${HEX}7FFF)))
          hash=$(( $hash ^ ((($hash & ${HEX}7FFFFFF) << 5) & ${HEX}FFFFFFFF) ))
          if [ "$hash" -lt 0 ]; then
            left=$((42949 + $hash / 100000)) right=$((67296 + $hash % 100000))
            [ "$right" -lt 0 ] && left=$(($left - 1)) right=$(($right + 100000))
            printf "%05u%05u $filename\n" "$left" "$right"
          else
            printf "%010u $filename\n" "$hash"
          fi
          hash=$seed filename=''
          continue ;;
        1??) filename="$filename\\$printf_octal_bug$oct" ;;
        *  ) filename="$filename\\$oct" ;;
      esac
      # fnv1a
      hash=$(( ( ($hash ^ ${OCT}${oct}) * $FNV_PRIME_32) & ${HEX}FFFFFFFF ))
    done | sort | while IFS= read -r line; do putsn "${line#* }"; done
  }
}

gen_seed() {
  hash=$FNV_OFFSET_BASIS_32
  while IFS= read -r oct; do
    hash=$(( ( ($hash ^ ${OCT}${oct}) * $FNV_PRIME_32) & ${HEX}FFFFFFFF ))
  done
  echo "$hash"
}
