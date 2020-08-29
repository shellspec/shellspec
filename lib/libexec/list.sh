#shellcheck shell=sh disable=SC2004

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
load binary

FNV_OFFSET_BASIS_32=2166136261
FNV_PRIME_32=16777619
[ $((010)) -eq 8 ] && OCT_PREFIX="0" || OCT_PREFIX="8#"

shuffle() {
  octal_dump | (
    seed=$(puts "${1:-}" | octal_dump | gen_seed)
    hash=$seed filename='' oct_bug=''
    [ "$("$SHELLSPEC_PRINTF" '\101' 2>/dev/null ||:)" = "A" ] || oct_bug=0


    while IFS= read -r oct; do
      case $oct in
        012)
          # xorshift32
          hash=$(( $hash ^ (($hash << 13) & 4294967295) ))
          hash=$(( $hash ^ (($hash >> 17) & 32767) ))
          hash=$(( $hash ^ (($hash << 5) & 4294967295) ))
          decord_hash_and_filename "$hash" "$filename"
          hash=$seed && filename='' && continue ;;
        1??) filename="${filename}\\${oct_bug}${oct}" ;;
        *  ) filename="${filename}\\${oct}" ;;
      esac
      fnv1a "$oct"
    done | sort | while IFS= read -r line; do putsn "${line#* }"; done
  )
}

gen_seed() {
  hash=$FNV_OFFSET_BASIS_32
  while IFS= read -r oct; do
    fnv1a "$oct"
  done
  echo "$hash"
}

fnv1a() {
  set -- $(( $hash ^ ${OCT_PREFIX}$1 )) "$FNV_PRIME_32" 65535 4294967295
  hash=$(( ( (((( $1 >> 16) * $2) & $3) << 16) + (($1 & $3) * $2) ) & $4 ))
}

decord_hash_and_filename() {
  case $1 in
    -2147483648) "$SHELLSPEC_PRINTF" "%010u $2\n" "2147483648" ;;
    -*)
      set -- "$1" "$2" $((42949 - ${1#-} / 100000)) $((67296 - ${1#-} % 100000))
      [ "$4" -lt 0 ] && set -- "$1" "$2" $(($3 - 1)) $(($4 + 100000))
      "$SHELLSPEC_PRINTF" "%05u%05u $2\n" "$3" "$4" ;;
    *) "$SHELLSPEC_PRINTF" "%010u $2\n" "$1" ;;
  esac
}
