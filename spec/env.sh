#shellcheck shell=sh

if (eval 'array=(1 2 3)') 2>/dev/null; then
  SHELLSPEC_PATTERN="$SHELLSPEC_PATTERN|*_spec.array.sh"
fi
