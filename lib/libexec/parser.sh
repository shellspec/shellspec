#shellcheck shell=sh

is_block_statement() {
  case $1 in (Describe | Context | Example | Specify | It | End)
    return 0
  esac
  return 1
}

is_example() {
  case $1 in (Example | Specify | It)
    return 0
  esac
  return 1
}

detect_range() {
  lineno_begin=$1 lineno_end='' lineno=0
  while IFS= read -r line || [ "$line" ]; do
    trim line
    line=${line%% *}
    line=${line#x}
    lineno=$(($lineno + 1))
    [ "$lineno" -lt "$1" ] && continue
    if [ "$lineno" -eq "$1" ]; then
      is_block_statement "$line" && lineno_begin=$(($lineno + 1))
    else
      is_block_statement "$line" && lineno_end=$(($lineno - 1)) && break
    fi
  done
  echo "${lineno_begin}-${lineno_end:-$lineno}"
}
