#shellcheck shell=sh

%const NAME: value
% MAJOR_VERSION: "${SHELLSPEC_VERSION%%.*}"
# % OK: "$(echo_ok)" # echo_ok not found

# %const (% is short hand) directive is define constant value.
# The characters that can be used for variable name is upper capital, number
# and underscore only. It can not be define inside of the example group or
# the example.
#
# The timing of evaluation of the value is the specfile translation process.
# So you can access shellspec variables, but you can not access variable or
# function in the specfile.
#
# This feature assumed use with conditional skip. The conditional skip may runs
# outside of the examples. As a result, sometime you may need variables defined
# outside of the examples.

Describe '%const directive'
  echo_ok() { echo ok; }
  version_check() { [ "$MAJOR_VERSION" -lt "$1" ]; }

  Skip if 'too old version' version_check 1
  Example
    The variable NAME should eq 'value'
  End
End
