#shellcheck shell=sh

# set -eu

# shellspec_redefinable function_name
#
#  shellspec_redefinable is workaround for ksh (Version AJM 93u+ 2012-08-01)
#  ksh can not redefine existing function in some cases inside of sub shell.
#  If you have trouble in redefine function on ksh, try using shellspec_redefinable.

shellspec_spec_helper_configure() {
  # shellspec_import 'support/custom_matcher'
  :
}
