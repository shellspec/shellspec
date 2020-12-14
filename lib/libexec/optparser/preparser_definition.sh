# shellcheck shell=sh

# Use getoptions to generate the option parser
# https://github.com/ko1nksm/getoptions
#
# To generate the code of the option parser,
# modify the following code and run `make optparser`.

# shellcheck disable=SC1083,SC2016
preparser_definition() {
  setup   REST abbr:true error:error_message mode:'='
  flag    DIRECTORY -c --chdir on:'' init:@unset
  param   DIRECTORY -C --directory validate:check_directory init:@none
}
