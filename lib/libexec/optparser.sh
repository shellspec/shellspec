# shellcheck shell=sh

# shellcheck source=lib/getoptions.sh
. "$SHELLSPEC_LIB/getoptions.sh"
# shellcheck source=lib/getoptions_help.sh
. "$SHELLSPEC_LIB/getoptions_help.sh"
# shellcheck source=lib/getoptions_abbr.sh
. "$SHELLSPEC_LIB/getoptions_abbr.sh"

# shellcheck disable=SC1083
parser_definition() {
  extension "$@"
  set -- "$1" "$2" "error_handler ${3:-echo}"

  setup params export:true error:"$3" abbr:true help:usage width:36 leading:'    ' -- \
    'Usage: shellspec [options...] [files or directories...]' \
    '' \
    '  Using + instead of - for short options causes reverses the meaning' \
    ''
  param SHELL -s --shell -- \
    'Specify a path of shell [default: "auto" (the shell running shellspec)]' \
    '  ShellSpec ignores shebang and runs in the specified shell.'

  param :'set_path PATH' --path var:PATH -- \
    'Set PATH environment variable at startup' \
    "  e.g. --path /bin:/usr/bin, --path \"\$(getconf PATH)\""

  flag SANDBOX --{no-}sandbox -- \
    'Force the use of the mock instead of the actual command' \
    '  Make PATH empty (except "spec/support/bin" and mock dir) and readonly' \
    '  This is not a security feature and does not provide complete isolation'

  param SANDBOX_PATH --sandbox-path var:PATH -- \
    'Make PATH the sandbox path instead of empty (default: empty)'

  multi REQUIRES ':' --require var:MODULE -- \
    'Require a MODULE (shell script file)'

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
    'Log file for %logger directive and trace [default: /dev/tty]'

  flag KEEP_TEMPDIR --keep-tempdir -- \
    'Do not cleanup temporary directory [default: disabled]'

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
    "Show banner if exist 'spec/banner' [default: enabled]"

  param FORMATTER -f --format validate:check_formatter init:='progress' -- \
    'Choose a formatter for display | <[p]> [d] [t] [j] [f] [null] [debug]' \
    '  [p]rogress      dots [default]' \
    '  [d]ocumentation group and example names' \
    '  [t]ap           TAP format' \
    '  [j]unit         JUnit XML (time attributre with --profile)' \
    '  [f]ailures      file:line:message (suitable for editors integration)' \
    '  [null]          do not display anything' \
    '  [debug]         for developers' \
    '  custom formatter name'

  multi GENERATORS ' ' -o --output validate:check_formatter var:FORMATTER -- \
    'Choose a generator(s) to generate a report file(s) [default: none]' \
    '  You can use the same name as FORMATTER. (multiple options allowed)'

  flag COLOR --{no-}color init:"detect_color_mode $2" -- \
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

  msg -- '    You can run selected examples by specified the line numbers or ids' \
    '' \
    '      shellspec path/to/a_spec.sh:10    # Run the groups or examples that includes lines 10' \
    '      shellspec path/to/a_spec.sh:@1-5  # Run the 5th groups/examples defined in the 1st group' \
    '      shellspec a_spec.sh:10:@1:20:@2   # You can mixing multiple line numbers and ids with join by ":"' \
    ''

  flag FOCUS_FILTER -F --focus -- \
    'Run focused groups / examples only'

  param PATTERN -P --pattern init:='*_spec.sh' -- \
    'Load files matching pattern [default: "*_spec.sh"]'

  multi EXAMPLE_FILTER '|' -E --example var:PATTERN -- \
    'Run examples whose names include PATTERN'

  multi TAG_FILTER ',' -T --tag var:'TAG[:VALUE]' -- \
    'Run examples with the specified TAG'

  param DEFAULT_PATH -D --default-path init:='spec' var:PATH -- \
    'Set the default path where looks for examples [default: "spec"]'

  msg -- '' '  **** Coverage ****' ''

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
    'Initialize your project with ShellSpec | [git] [hg] [svn]' \
    '  Template: Create additional files.' \
    '    [git]   .gitignore' \
    '    [hg]    .hgignore' \
    '    [svn]   .svnignore'

  flag :mode --gen-bin on:gen-bin \
    label:'    --gen-bin [@COMMAND...]' -- \
    'Generate test support commands in spec/support/bin' \
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
  disp ":help \$1" -h --help -- '-h: short help, --help: long help'
}

extension() {
  prefix=$2
  multi() {
    name=${prefix}_$1 separator="$2"
    shift 2
    param ":multiple $name '$separator'" "init:export $name=''" "$@"
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

multiple() {
  eval "export $1=\"\${$1}\${$1:+$2}\$OPTARG\""
}

boost() {
  case $OPTARG in
    1) export "$1_PROFILER=1" "$1_PROFILER_LIMIT=0" ;;
    *) export "$1_PROFILER=" "$1_PROFILER_LIMIT=10" ;;
  esac
}

check_env_name() {
  case ${OPTARG%%\=*} in ([!a-zA-Z_]*) return 1; esac
  case ${OPTARG%%\=*} in (*[!a-zA-Z0-9_]*) return 1; esac
  return 0
}

set_path() {
  export "$1=$OPTARG"
}

set_env() {
  case $OPTARG in
    *=*) set -- "${OPTARG%%\=*}" "${OPTARG#*\=}" ;;
    *)
      eval "[ \${$OPTARG+x} ] &&:" || return 0
      eval "set -- \"\$OPTARG\" \"\${$OPTARG}\""
  esac
  export "$1=$2"
}

check_env_file() {
  case $OPTARG in
    /* | ./* | ../*) : ;;
    *) OPTARG="./$OPTARG" ;;
  esac
  [ -f "$OPTARG" ]
}

only_failures() {
  export "$1_QUICK=1" "$1_REPAIR=1"
}

next_failure() {
  export "$1_QUICK=1" "$1_REPAIR=1" "$1_FAIL_FAST_COUNT=1" "$1_RANDOM="
}

check_random() {
  case $OPTARG in
    none | none:*) return 0 ;;
    specfiles | specfiles:*) return 0 ;;
    examples | examples:*) return 0 ;;
  esac
  return 1
}

random() {
  case $OPTARG in (none | none:*)
    OPTARG=''
  esac
  case $OPTARG in
    *:*) export "$1_RANDOM=${OPTARG%%:*}" "$1_SEED=${OPTARG#*:}" ;;
    *) export "$1_RANDOM=$OPTARG" "$1_SEED=" ;;
  esac
}

xtrace() {
  case $OPTARG in
    0) export "$1_XTRACE=" "$1_XTRACE_ONLY=" ;;
    1) export "$1_XTRACE=1" "$1_XTRACE_ONLY" ;;
    2) export "$1_XTRACE=1" "$1_XTRACE_ONLY=1" ;;
  esac
}

is_terminal() { [ -t 1 ]; }
detect_color_mode() {
  export "$1_COLOR="
  [ "${NO_COLOR:-}" ] && return 0
  if is_terminal || [ "${FORCE_COLOR:-}" ]; then
    export "$1_COLOR=1"
  fi
}

quiet() {
  export "$1_SKIP_MESSAGE=quiet" "$1_PENDING_MESSAGE=quiet"
}

mode() {
  case $OPTARG in
    specfiles | examples | examples:id | examples:lineno | debug)
      export "$1_MODE=list" "$1_LIST=$OPTARG" ;;
    count) export "$1_MODE=list" "$1_LIST=" ;;
    *) export "$1_MODE=$OPTARG" "$1_LIST=" ;;
  esac
}

check_number() {
  case $OPTARG in (*[!0-9]*) return 1; esac
  return 0
}

check_formatter() {
  case $OPTARG in (*[!a-z0-9_]*) return 1; esac
  set -- progress documentation tap junit failures
  while [ $# -gt 0 ]; do
    case $1 in ($OPTARG*) OPTARG=$1; esac
    shift
  done
  return 0
}

help() {
  usage | while IFS= read -r line; do
    if [ "$1" = "--help" ]; then
      echo "${line%\ \|\ *}"
    else
      spaces=${line%%[! ]*}
      [ ${#spaces} -ge 10 ] || echo "$line"
    fi
  done
}

error_handler() {
  # $1: echo or output function
  # $2: Default error message
  # $3: Error name
  # $4: Option
  # $5-: Validator name and arguments
  case $3 in
    check_number:*) set -- "$1" "Not a number: $4" ;;
    check_formatter:*) set -- "$1" "Invalid formatter name: $4" ;;
    check_env_name:*) set -- "$1" "Invalid environment name: $4" ;;
    check_env_file:*) set -- "$1" "Not found env file: $4" ;;
    check_random:*)
      set -- "$1" "Specify in one of the following formats" "$4"
      set -- "$1" "$2 (none[:SEED], specfiles[:SEED], examples[:SEED]): $3"
  esac
  "$1" "$2"
  return 1
}
