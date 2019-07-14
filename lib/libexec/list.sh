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
          decord_hash_and_filename "$hash" "$filename"
          hash=$seed && filename='' && continue ;;
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

decord_hash_and_filename() {
  case $1 in
    -*)
      set -- "$1" "$2" $((42949 - ${1#-}/100000)) $((67296 - ${1#-}%100000))
      if [ "$4" -lt 0 ]; then
        set -- "$1" "$2" $(($3 - 1)) $(($4 + 100000))
      fi
      printf "%05u%05u $2\n" "$3" "$4"
      ;;
    *) printf "%010u $2\n" "$1"
  esac
}
