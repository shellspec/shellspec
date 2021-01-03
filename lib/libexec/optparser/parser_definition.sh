# shellcheck shell=sh

# Use getoptions to generate the option parser
# https://github.com/ko1nksm/getoptions
#
# To generate the code of the option parser,
# modify the following code and run `make optparser`.

# shellcheck disable=SC1083,SC2016
parser_definition() {
  : "${2?No variable prefix specified}"
  : "${3?No message handler specified}"

  extension "$@"
  set -- "$1" "$2" "error_handler ${3:-echo}"

  setup params export:true error:"$3" abbr:true help:usage width:36 leading:'    ' -- \
    'Usage: shellspec [ -c ] [-C <directory>] [options...] [files or directories...]'

  msg -- '' '  Using + instead of - for short options causes reverses the meaning' ''

  param SHELL -s --shell -- \
    'Specify a path of shell [default: "auto" (the shell running shellspec)]' \
    '  ShellSpec ignores shebang and runs in the specified shell.'

  multi REQUIRES ' ' validate:check_module_name --require var:MODULE -- \
    'Require a MODULE (shell script file)'

  param OPTIONS -O --options var:PATH -- \
    'Specify the path to an additional options file'

  array LOAD_PATH -I --load-path var:PATH -- \
    'Specify PATH to add to $SHELLSPEC_LOAD_PATH (may be used more than once)'

  param HELPERDIR --helperdir init:="spec" var:DIRECTORY -- \
    'The directory to load helper files (spec_helper.sh, etc) [default: "spec"]'

  param :'set_path PATH' --path var:PATH -- \
    'Set PATH environment variable at startup' \
    "  e.g. --path /bin:/usr/bin, --path \"\$(getconf PATH)\""

  flag SANDBOX --{no-}sandbox -- \
    'Force the use of the mock instead of the actual command' \
    '  Make PATH empty (except "spec/support/bin" and mock dir) and readonly' \
    '  This is not a security feature and does not provide complete isolation'

  param SANDBOX_PATH --sandbox-path var:PATH -- \
    'Make PATH the sandbox path instead of empty [default: empty]'

  param EXECDIR --execdir init:='@project' validate:check_execdir var:"@LOCATION[/DIR]" \
    pattern:'@project | @project/* | @basedir | @basedir/* | @specfile | @specfile/*' -- \
    'Specify the execution directory of each specfile | [default: @project]' \
    '  [@project]   Where the ".shellspec" file is located (project root) [default]' \
    '  [@basedir]   Where the ".shellspec" or ".shellspec-basedir" file is located' \
    '  [@specfile]  Where the specfile is located' \
    '  In addition, it can be specified a directory relative to the location'

  param :set_env -e --env validate:check_env_name var:'NAME[=VALUE]' -- \
    'Set environment variable'

  param ENV_FROM --env-from validate:check_env_file var:ENV-SCRIPT -- \
    'Set environment variable from shell script file'

  flag WARNING_AS_FAILURE -w +w --{no-}warning-as-failure init:@on -- \
    'Treat warning as failure [default: enabled]'

  option FAIL_FAST_COUNT --{no-}fail-fast on:1 validate:check_number \
    label:'    --{no-}fail-fast[=COUNT]' -- \
    'Abort the run after first (or COUNT) of failures [default: disabled]'

  flag FAIL_NO_EXAMPLES --{no-}fail-no-examples -- \
    'Fail if no examples found [default: disabled]'

  flag FAIL_LOW_COVERAGE --{no-}fail-low-coverage -- \
    'Fail on low coverage [default: disabled]' \
    '  The coverage threshold is specified by the coverage option'

  param FAILURE_EXIT_CODE --failure-exit-code validate:check_number init:=101 var:CODE -- \
    'Override the exit code used when there are failing specs [default: 101]'

  param ERROR_EXIT_CODE --error-exit-code validate:check_number init:=102 var:CODE -- \
    'Override the exit code used when there are fatal errors [default: 102]'

  flag PROFILER -p +p --{no-}profile -- \
    'Enable profiling and list the slowest examples [default: disabled]' \
    '  Profiler tries to use 100% ability of 1 CPU (1 core).' \
    '  Therefore, not recommended for single(-core) CPU.'

  param PROFILER_LIMIT --profile-limit validate:check_number init:=10 var:N -- \
    'List the top N slowest examples [default: 10]'

  flag :boost --{no-}boost -- \
    'Increase the CPU frequency to boost up testing speed [default: disabled]' \
    '  Equivalent of --profile --profile-limit 0' \
    "  (Don't worry, this is not overclocking. This is joke option but works.)"

  param LOGFILE --log-file init:='/dev/tty' -- \
    'Log file for %logger directive and trace [default: "/dev/tty"]'

  param TMPDIR --tmpdir init:"export $2_TMPDIR="'${TMPDIR:-${TMP:-/tmp}}' -- \
    'Specify temporary directory [default: $TMPDIR, $TMP or "/tmp"]'

  flag KEEP_TMPDIR --keep-tmpdir -- \
    'Do not cleanup temporary directory [default: disabled]'
  flag KEEP_TMPDIR --keep-tempdir validate:'deprecated "$1" "Replace with --keep-tmpdir."' abbr: hidden:true init:@none

  msg -- '' '  The following options must be specified before other options and cannot be specified in the options file' ''

  flag DIRECTORY -c --chdir validate:'directory_not_available' init:@none \
    -- 'Change the current directory to the first path of arguments at the start'
  param DIRECTORY -C --directory validate:'directory_not_available' init:@none \
    -- 'Change the current directory at the start'

  msg -- '' '  **** Execution ****' ''

  flag QUICK -q +q --{no-}quick -- \
    'Run not-passed examples if it exists, otherwise run all [default: disabled]' \
    '  not-passed examples: failure and temporary pending examples' \
    '  Quick mode is automatically enabled. To disable quick mode,' \
    '  delete .shellspec-quick.log on the project root directory.'

  flag :only_failures -r --repair --only-failures -- \
    'Run failure examples only (Depends on quick mode)'

  flag :next_failure -n --next-failure -- \
    'Run failure examples and abort on first failure (Depends on quick mode)' \
    '  Equivalent of --repair --fail-fast --random none'

  param WORKERS -j --jobs validate:check_number init:=0 var:JOBS -- \
    'Number of parallel jobs to run [default: 0 (disabled)]'

  param :random --random validate:check_random init:='' var:"TYPE[:SEED]" -- \
    'Run examples by the specified random type | <[none]> [specfiles] [examples]' \
    '  [none]          run in the defined order [default]' \
    '  [specfiles]     randomize the order of specfiles' \
    '  [examples]      randomize the order of examples (slow)'

  flag :xtrace -x --xtrace on:1 init:=0 -- \
    'Run examples with trace output of evaluation enabled [default: disabled]' \
    '  Fall back to --xtrace-only if BASH_XTRACEFD not supported.'

  flag :xtrace -X --xtrace-only on:2 -- \
    'Run examples with trace output only enabled [default: disabled]' \
    '  The evaluation is executed, but the expectations are skipped.'

  flag DRYRUN --dry-run -- \
    'Print the formatter output without running any examples [default: disabled]'

  msg -- '' '  **** Output ****' ''

  flag BANNER --{no-}banner init:@on -- \
    'Show banner if exist "<HELPERDIR>/banner[.md]" [default: enabled]'

  param REPORTDIR --reportdir init:='report' var:DIRECTORY -- \
    'Output directory of the report [default: "report"]'

  param FORMATTER -f --format validate:check_formatter init:='progress' -- \
    'Choose a formatter for display | <[p]> [d] [t] [j] [f] [null] [debug]' \
    '  [p]rogress      dots [default]' \
    '  [d]ocumentation group and example names' \
    '  [t]ap           TAP format' \
    '  [j]unit         JUnit XML (time attributre with --profile)' \
    '  [f]ailures      file:line:message (suitable for editors integration)' \
    '  [null]          do not display anything' \
    '  [debug]         for developers' \
    '  Custom formatter name (which load from $SHELLSPEC_LOAD_PATH)'

  multi GENERATORS ' ' -o --output validate:check_formatter var:FORMATTER -- \
    'Choose a generator(s) to generate a report file(s) [default: none]' \
    '  You can use the same name as FORMATTER. (multiple options allowed)'

  flag COLOR --{no-}color init:@none -- \
    'Enable or disable color [default: enabled if the output is a TTY]' \
    '  Disable if NO_COLOR environment variable set'
  flag COLOR --{no-}colour --force-color --force-colour init:@none hidden abbr:

  param SKIP_MESSAGE --skip-message pattern:'verbose | moderate | quiet' init:='verbose' var:VERBOSITY -- \
    'Mute skip message | <[verbose]> [moderate] [quiet]' \
    '  [verbose]       do not mute any messages [default]' \
    '  [moderate]      mute repeated messages' \
    '  [quiet]         mute repeated or non-temporary messages'

  param PENDING_MESSAGE --pending-message pattern:'verbose | quiet' init:='verbose' var:VERBOSITY -- \
    'Mute pending message | <[verbose]> [quiet]' \
    '  [verbose]       do not mute any messages [default]' \
    '  [quiet]         mute non-temporary messages'

  flag :quiet --quiet -- \
    'Equivalent of --skip-message quiet --pending-message quiet'

  flag DEPRECATION_LOG --show-deprecations on:1 init:@on hidden
  flag DEPRECATION_LOG --hide-deprecations on: init:@none \
    label:'    --(show|hide)-deprecations' -- \
    'Show or hide deprecations details [default: show]'

  msg -- '' '  **** Ranges / Filters / Focus ****' ''

  msg -- '    You can run selected examples by specified the line numbers or ids' '' \
    '      shellspec path/to/a_spec.sh:10   # Run the groups or examples that includes lines 10' \
    '      shellspec path/to/a_spec.sh:@1-5 # Run the 5th groups/examples defined in the 1st group' \
    '      shellspec a_spec.sh:10:@1:20:@2  # You can mixing multiple line numbers and ids with join by ":"' ''

  flag FOCUS_FILTER -F --focus -- \
    'Run focused groups / examples only'

  param PATTERN -P --pattern init:='*_spec.sh' -- \
    'Load files matching pattern [default: "*_spec.sh"]'

  multi EXAMPLE_FILTER '|' -E --example var:PATTERN -- \
    'Run examples whose names include PATTERN'

  multi TAG_FILTER ',' -T --tag var:'TAG[:VALUE]' -- \
    'Run examples with the specified TAG'

  param DEFAULT_PATH -D init:@none validate:'deprecated "$1" "Replace with --default-path."' hidden:true
  param DEFAULT_PATH --default-path init:='spec' var:PATH -- \
    'Set the default path where looks for examples [default: "spec"]' \
    ' The path to a specfile or a directory containing specfiles'

  msg -- '' '    You can specify the path recursively by prefixing it with the pattern "*/" or "**/"' \
    '      (This is not glob patterns and requires quotes. It is also available with --default-path)' '' \
    '      shellspec "*/spec"               # The pattern "*/" matches 1 directory' \
    '      shellspec "**/spec"              # The pattern "**/" matches 0 and more directories' \
    '      shellspec "*/*/**/test_spec.sh"  # These patterns can be specified multiple times' ''

  flag DEREFERENCE -L --dereference -- \
    'Dereference all symlinks in in the above pattern [default: disabled]'

  msg -- '' '  **** Coverage ****' ''

  param COVERAGEDIR --covdir init:="coverage" var:DIRECTORY -- \
    'Output directory of the Coverage Report [default: coverage]'

  flag KCOV --{no-}kcov -- \
    'Enable coverage using kcov [default: disabled]'

  param KCOV_PATH --kcov-path init:="kcov" var:PATH -- \
    'Specify kcov path [default: kcov]'

  multi KCOV_OPTS ' ' --kcov-options var:OPTIONS -- \
    'Additional Kcov options (coverage limits, coveralls id, etc)' \
    '  Default specified options: (can be overwritten)' \
    '    --include-path=.' \
    '    --include-pattern=.sh' \
    '    --exclude-pattern=/.shellspec,/spec/,/coverage/,/report/' \
    '    --path-strip-level=1' \
    '  To include files without extension, specify --include-pattern' \
    '  without ".sh" and filter with --include-*/--exclude-* options.'

  flag COVERAGE_KSH_WORKAROUND --coverage-ksh-workaround hidden abbr:

  msg -- '' '  **** Utility ****' ''

  flag :mode --init on:init init:='runner' \
    label:'    --init [TEMPLATE...]' -- \
    'Initialize your project with ShellSpec | [spec] [git] [hg] [svn]' \
    '  Template: Create additional files.' \
    '    [spec]  example specfile' \
    '    [git]   .gitignore' \
    '    [hg]    .hgignore' \
    '    [svn]   .svnignore'

  flag :mode --gen-bin on:gen-bin \
    label:'    --gen-bin [@COMMAND...]' -- \
    'Generate test support commands in "<HELPERDIR>/support/bin"' \
    '  This is useful for run actual commands from mock/stub.'

  flag :mode --count on:count -- \
    'Count the number of specfiles and examples'

  param :mode --list pattern:'specfiles | examples | examples:id | examples:lineno | debug' \
    var:LIST -- \
    'List the specfiles/examples | [specfiles] [examples(:id|:lineno)]' \
    '  [specfiles]       list the specfiles' \
    '  [examples]        list the examples with id' \
    '  [examples:id]     alias for examples' \
    '  [examples:lineno] list the examples with lineno' \
    '  [debug]           for developer' \
    '  The order is randomized with --random but random TYPE is ignored.'

  flag :mode --syntax-check on:syntax-check -- \
    'Syntax check of the specfiles without running any examples'

  flag :mode --translate on:translate -- \
    'Output translated specfile'

  flag :mode --task on:task \
    label:'    --task [TASK]' -- \
    'Run the TASK or Show the task list if TASK is not specified'

  param DOCKER_IMAGE --docker var:DOCKER-IMAGE -- \
    'Run tests in specified docker image (EXPERIMENTAL)' \
    '  This is an experimental feature and may be changed/removed in the future.'

  disp VERSION -v --version -- 'Display the version'
  disp ':help "$1"' -h --help -- '-h: short help, --help: long help'
}

extension() {
  prefix=$2
  multi() {
    name=${prefix}_$1 separator="$2"
    shift 2
    param ":multiple $name '$separator'" "init:export $name=''" "$@"
  }
  array() {
    name=${prefix}_$1
    shift
    param ":array $name" "init:export $name=''" "$@"
  }
  prehook() {
    helper=$1 name=$2
    shift 2
    case $helper in (flag | param | option | disp)
      case $name in
        :*) name="$name $prefix" ;;
        *) name="${prefix}_${name}" ;;
      esac
    esac
    invoke "$helper" "$name" "$@"
  }
}
