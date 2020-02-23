#shellcheck shell=sh disable=SC2016

shellspec_syntax 'shellspec_matcher_be_exist'
shellspec_syntax 'shellspec_matcher_be_file'
shellspec_syntax 'shellspec_matcher_be_directory'

shellspec_syntax 'shellspec_matcher_be_symlink'
shellspec_syntax 'shellspec_matcher_be_pipe'
shellspec_syntax 'shellspec_matcher_be_socket'

shellspec_syntax 'shellspec_matcher_be_readable'
shellspec_syntax 'shellspec_matcher_be_writable'
shellspec_syntax 'shellspec_matcher_be_executable'

shellspec_syntax_compound 'shellspec_matcher_be_block'
shellspec_syntax 'shellspec_matcher_be_block_device'
shellspec_syntax_compound 'shellspec_matcher_be_character'
shellspec_syntax 'shellspec_matcher_be_character_device'

shellspec_make_file_matcher() {
  SHELLSPEC_EVAL="
    shellspec_matcher_be_$1() { \
      shellspec_matcher__match() { \
        [ $2 \"\${SHELLSPEC_SUBJECT:-}\" ]; \
      }; \
      shellspec_syntax_failure_message + \
        'The specified path ${4:-${3%% *} not ${3#* }}' \
        'path: \$SHELLSPEC_SUBJECT'; \
      shellspec_syntax_failure_message - \
        'The specified path $3' \
        'path: \$SHELLSPEC_SUBJECT'; \
      shellspec_syntax_param count [ \$# -eq 0 ] || return 0; \
      shellspec_matcher_do_match; \
    }
  "
  eval "$SHELLSPEC_EVAL"
}

shellspec_make_file_matcher exist            "-e" "exists" "does not exist"
shellspec_make_file_matcher file             "-f" "is a regular file"
shellspec_make_file_matcher directory        "-d" "is a directory"

shellspec_make_file_matcher symlink          "-L" "is a symbolic link"
shellspec_make_file_matcher pipe             "-p" "is a pipe"
shellspec_make_file_matcher socket           "-S" "is a socket"

shellspec_make_file_matcher executable       "-x" "is executable"
shellspec_make_file_matcher readable         "-r" "is readable"
shellspec_make_file_matcher writable         "-w" "is writable"

shellspec_make_file_matcher block_device     "-b" "is a block device"
shellspec_make_file_matcher character_device "-c" "is a character device"
