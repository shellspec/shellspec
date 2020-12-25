#shellcheck shell=sh

major_minor=${SHELLSPEC_VERSION%".${SHELLSPEC_VERSION#*.*.}"}
if [ "${major_minor%.*}" -eq 0 ] && [ "${major_minor#*.}" -lt 28 ]; then
  echo "ShellSpec version 0.28.0 or higher is required." >&2
  exit 1
fi

if (eval 'array=(1 2 3)') 2>/dev/null; then
  export SHELLSPEC_PATTERN="$SHELLSPEC_PATTERN|*_spec.array.sh"
fi

if [ "$SHELLSPEC_DEFECT_SANDBOX" ]; then
  echo "The sandbox feature was automatically disabled." >&2
  export SHELLSPEC_SANDBOX=''
fi
