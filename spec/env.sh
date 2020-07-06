#shellcheck shell=sh

if (eval 'array=(1 2 3)') 2>/dev/null; then
  export SHELLSPEC_PATTERN="$SHELLSPEC_PATTERN|*_spec.array.sh"
fi

if [ "$SHELLSPEC_DEFECT_SANDBOX" ]; then
  echo "The sandbox feature was automatically disabled." >&2
  export SHELLSPEC_SANDBOX=''
fi
