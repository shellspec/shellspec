# shellcheck shell=sh disable=SC1083,SC2004,SC2016

Describe "getoptions()"
	Include ./lib/getoptions.sh

	parse() {
		eval "$(getoptions parser_definition _parse)"
		case $# in
			0) _parse ;;
			*) _parse "$@" ;;
		esac
	}

	restargs() {
		parse "$@"
		eval "set -- $ARGS"
		if [ $# -gt 0 ]; then
			echo "$@"
		fi
	}

	It "generates option parser"
		parser_definition() { setup ARGS; echo 'called' >&2; }
		When call parse
		The word 1 of stderr should eq "called"
		The status should be success
	End

	It "generates option parser with help"
		parser_definition() { setup ARGS help:usage; }
		getoptions_help() { echo 'getoptions_help called'; }
		When call parse
		The output should eq 'getoptions_help called'
		The status should be success
	End

	Describe 'handling arguments'
		Context 'when scanning mode is default'
			parser_definition() {
				setup ARGS -- 'foo bar'
				flag FLAG_A -a
			}
			Specify "treats non-options as arguments"
				When call restargs -a 1 -a 2 -a 3 - -- -a
				The variable FLAG_A should eq 1
				The output should eq "1 2 3 - -a"
			End
		End

		Context "when scanning mode is '+'"
			parser_definition() {
				setup ARGS mode:'+'
				flag FLAG_A -a
			}
			Specify "treats rest following a non-option as arguments"
				When call restargs -a 1 -a 2 -a 3 -- -a
				The variable FLAG_A should eq 1
				The output should eq "1 -a 2 -a 3 -- -a"
			End

			Specify "treats -- as not arguments"
				When call restargs -a -- -a
				The variable FLAG_A should eq 1
				The output should eq "-a"
			End
		End

		Context "when scanning mode is '#'"
			parser_definition() {
				setup ARGS mode:'#'
				flag FLAG_A -a
			}

			Specify "treats rest following a non-option as arguments"
				When call restargs -a 1 -a 2 -a 3 -- -a
				The variable FLAG_A should eq 1
				The output should eq "1 -a 2 -a 3 -- -a"
			End

			Specify "treats rest following a non-option or an unknown option as arguments"
				When call restargs -a -a -x 2 -a 3 -- -a
				The variable FLAG_A should eq 1
				The output should eq "-x 2 -a 3 -- -a"
			End

			Specify "treats -- as not arguments"
				When call restargs -a -- -a
				The variable FLAG_A should eq 1
				The output should eq "-a"
			End
		End

		Context "when scanning mode is '@'"
			parser_definition() {
				setup ARGS mode:'@'
				flag FLAG_A -a
			}
			Specify "treats rest following a non-option as arguments"
				When call restargs -a 1 -a 2 -a 3 -- -a
				The variable FLAG_A should eq 1
				The output should eq "1 -a 2 -a 3 -- -a"
			End

			Specify "treats -- as arguments"
				When call restargs -a -- -a
				The variable FLAG_A should eq 1
				The output should eq "-- -a"
			End
		End

		Context "when scanning mode is '='"
			parser_definition() {
				setup ARGS mode:'='
				flag FLAG -f
				param PARAM -p
			}
			Specify "treats rest following an unknown option as arguments"
				When call restargs -p 1 -f a -p 2 b -x -p 3
				The variable PARAM should eq 2
				The output should eq "a b -x -p 3"
			End
		End

		Context 'when the plus attribute disabled (default)'
			parser_definition() { setup ARGS; }
			Specify "treats as arguments"
				When call restargs +o
				The output should eq "+o"
			End
		End
	End

	Describe 'parser function'
		Context 'when the option parser ends normally'
			parser_definition() {
				setup ARGS
				flag FLAG_A -a
			}
			It "resets OPTIND and OPTARG"
				# Workaround for ksh 88
				foo() { [ "$OPTIND" -eq 1 ] || unset OPTIND; }
				OPTIND=1 && foo

				When call parse -a
				The variable OPTIND should eq 1
				The variable OPTARG should be undefined
			End
		End
	End

	Describe 'Default error handler'
		Context "when specified unknown option"
			parser_definition() { setup ARGS; }
			It "displays error"
				When run parse -x
				The stderr should eq "Unrecognized option: -x"
				The status should be failure
			End
		End

		Context "when specified unknown long option"
			parser_definition() { setup ARGS; }
			It "displays error"
				When run parse --long
				The stderr should eq "Unrecognized option: --long"
				The status should be failure
			End
		End

		Context "when specified an argument to flag"
			parser_definition() { setup ARGS; flag FLAG --flag; }
			It "displays error"
				When run parse --flag=value
				The stderr should eq "Does not allow an argument: --flag"
				The status should be failure
			End
		End

		Context "when missing an argument for parameter"
			parser_definition() { setup ARGS; param PARAM --param; }
			It "displays error"
				When run parse --param
				The stderr should eq "Requires an argument: --param"
				The status should be failure
			End
		End

		Context 'when the plus attribute enabled'
			parser_definition() { setup ARGS plus:true; }
			It "displays error if unknown +option specified"
				When run restargs +o
				The stderr should eq "Unrecognized option: +o"
				The status should be failure
			End
		End
	End

	Describe 'alternative mode'
		parser_definition() {
			setup ARGS alt:true
			flag FLAG --flag
			param PARAM --param
			option OPTION --option
		}
		It "allow long options to start with a single '-'"
			When call parse -flag -param p -option=o
			The variable FLAG should eq 1
			The variable PARAM should eq "p"
			The variable OPTION should eq "o"
		End
	End

	Describe 'prehook'
		parser_definition() {
			prehook() { echo "$@" >&2; invoke "$@"; }
			setup ARGS alt:true
			flag FLAG --flag
			param PARAM --param
			option OPTION --option
			msg -- 'message'
		}
		It "called before helper functions is called"
			When call parse -flag -param p -option=o
			The line 1 of stderr should eq "setup ARGS alt:true"
			The line 2 of stderr should eq "flag FLAG --flag"
			The line 3 of stderr should eq "param PARAM --param"
			The line 4 of stderr should eq "option OPTION --option"
			The line 5 of stderr should eq "msg -- message"
			The line 6 of stderr should eq "flag FLAG --flag"
			The line 7 of stderr should eq "param PARAM --param"
			The line 8 of stderr should eq "option OPTION --option"
			The line 9 of stderr should eq "msg -- message"
		End
	End

	Describe 'custom error handler'
		parser_definition() {
			setup RESTARGS error
			param PARAM -p
			param PARAM -q
			param PARAM --pattern pattern:'foo | bar'
			param VALID -v validate:'valid "$1"'
			param ARG --arg validate:arg
			flag  FLAG --flag
		}
		valid() { [ "$1" = "-v" ] && return 3; }
		arg() { false; }
		error() {
			case $2 in
				unknown) echo "custom $2: $3 [$OPTARG]"; return 20 ;;
				valid:3) echo "valid $2: $3 [$OPTARG]"; return 30 ;;
				pattern:'foo | bar') echo "pattern $2: $3 [$OPTARG]"; return 40 ;;
				arg:*) echo "invalid argument [$OPTARG]"; return 1 ;;
				noarg) echo "noarg [$OPTARG]"; return 1 ;;
			esac
			[ "$3" = "-q" ] && echo "$1 [$OPTARG]" && return 1
			return 0
		}

		It "display custom error message"
			When run parse -x
			The stderr should eq "custom unknown: -x []"
			The status should eq 20
		End

		It "display default error message when custom error handler succeeded"
			When run parse -p
			The stderr should eq "Requires an argument: -p"
			The status should eq 1
		End

		It "receives default error message"
			When run parse -q
			The stderr should eq "Requires an argument: -q []"
			The status should eq 1
		End

		It "receives exit status of custom validation"
			When run parse -v value
			The stderr should eq "valid valid:3: -v [value]"
			The status should eq 30
		End

		It "receives pattern"
			When run parse --pattern baz
			The stderr should eq "pattern pattern:foo | bar: --pattern [baz]"
			The status should eq 40
		End

		It "can refer to the OPTARG variable"
			When run parse --arg argument
			The stderr should eq "invalid argument [argument]"
			The status should eq 1
		End

		It "can refer to the OPTARG variable"
			When run parse --flag=argument
			The stderr should eq "noarg [argument]"
			The status should eq 1
		End
	End

	Describe 'flag helper'
		It "handles flags"
			parser_definition() {
				setup ARGS
				flag FLAG_A -a
				flag FLAG_B +b
				flag FLAG_C --flag-c
				flag FLAG_D --{no-}flag-d
				flag FLAG_E --no-flag-e
				flag FLAG_F --{no-}flag-f
			}
			When call parse -a +b --flag-c --flag-d --no-flag-e --no-flag-f
			The variable FLAG_A should eq 1
			The variable FLAG_B should eq ""
			The variable FLAG_C should eq 1
			The variable FLAG_D should eq 1
			The variable FLAG_E should eq ""
			The variable FLAG_F should eq ""
		End

		It "can change the set value"
			parser_definition() {
				setup ARGS
				flag FLAG_A -a on:ON off:OFF
				flag FLAG_B +b on:ON off:OFF
			}
			When call parse -a +b
			The variable FLAG_A should eq "ON"
			The variable FLAG_B should eq "OFF"
		End

		It "set initial value when not specified flag"
			BeforeCall FLAG_N=none FLAG_E=""
			parser_definition() {
				setup ARGS
				flag FLAG_A -a on:ON off:OFF init:@on
				flag FLAG_B -b on:ON off:OFF init:@off
				flag FLAG_C -c on:ON off:OFF init:'FLAG_C=func'
				flag FLAG_D -d on:ON off:OFF
				flag FLAG_Q -q on:"a'b\""
				flag FLAG_U -u init:@unset
				flag FLAG_N -n init:@none
				flag FLAG_E -n init:@export
			}
			When call parse -q
			The variable FLAG_A should eq "ON"
			The variable FLAG_B should eq "OFF"
			The variable FLAG_C should eq "func"
			The variable FLAG_D should eq ""
			The variable FLAG_Q should eq "a'b\""
			The variable FLAG_U should be undefined
			The variable FLAG_N should eq "none"
			The variable FLAG_E should be exported
		End

		It "can be used combined short flags"
			parser_definition() {
				setup ARGS
				flag FLAG_A -a
				flag FLAG_B -b
				flag FLAG_C -c
				flag FLAG_D +d init:@on
				flag FLAG_E +e init:@on
				flag FLAG_F +f init:@on
			}
			When call parse -abc +def
			The variable FLAG_A should be present
			The variable FLAG_B should be present
			The variable FLAG_C should be present
			The variable FLAG_D should be blank
			The variable FLAG_E should be blank
			The variable FLAG_F should be blank
		End

		It "counts flags"
			parser_definition() {
				setup ARGS
				flag COUNT -c +c counter:true
			}
			When call parse -c -c -c +c -c
			The variable COUNT should eq 3
		End

		It "calls the function"
			parser_definition() {
				setup ARGS
				flag :'foo "$1"' -f on:ON
			}
			foo() { echo "set [$OPTARG] : ${*:-}"; }
			When run parse -f
			The output should eq "set [ON] : -f"
		End

		It "calls the validator"
			valid() { echo "$OPTARG" "$@"; }
			parser_definition() {
				setup ARGS
				flag FLAG -f +f on:ON off:OFF validate:'valid "$1"'
			}
			When call parse -f +f
			The line 1 should eq "ON -f"
			The line 2 should eq "OFF +f"
		End

		Context 'when common flag value is specified'
			parser_definition() {
				setup ARGS on:ON off:OFF
				flag FLAG_A -a
				flag FLAG_B +b
			}
			It "can change the set value"
				When call parse -a +b
				The variable FLAG_A should eq "ON"
				The variable FLAG_B should eq "OFF"
			End
		End
	End

	Describe 'param helper'
		It "handles parameters"
			parser_definition() {
				setup ARGS
				param PARAM_P -p
				param PARAM_Q -q
				param PARAM   --param
			}
			When call parse -p value1 -qvalue2 --param=value3
			The variable PARAM_P should eq "value1"
			The variable PARAM_Q should eq "value2"
			The variable PARAM should eq "value3"
		End

		It "remains initial value when not specified parameter"
			parser_definition() {
				setup ARGS
				param PARAM_P -p init:="initial"
			}
			When call parse
			The variable PARAM_P should eq "initial"
		End

		It "calls the function"
			parser_definition() {
				setup ARGS
				param :'foo "$1"' -p
			}
			foo() { echo "set [$OPTARG] : ${*:-}"; }
			When run parse -p 123
			The output should eq "set [123] : -p"
		End

		It "calls the validator"
			valid() { echo "$OPTARG" "$@"; }
			parser_definition() {
				setup ARGS
				param PARAM_P -p validate:'valid "$1"'
				param PARAM_Q -q validate:'valid "$1"'
				param PARAM   --param validate:'valid "$1"'
			}
			When call parse -p value1 -qvalue2 --param=value3
			The line 1 should eq "value1 -p"
			The line 2 should eq "value2 -q"
			The line 3 should eq "value3 --param"
		End

		Context 'when specified pattern attribute'
			Parameters
				FOO success stdout ""
				BAZ failure stderr "Does not match the pattern (FOO | BAR): -p"
			End

			It "checks if it matches the pattern"
				parser_definition() {
					setup ARGS
					param PARAM -p pattern:'FOO | BAR'
				}
				When run parse -p "$1"
				The status should be "$2"
				The "$3" should eq "$4"
			End
		End
	End

	Describe 'option helper'
		It "handles options"
			parser_definition() {
				setup ARGS
				option OPTION   --option
				option OPTION_O -o on:"default"
				option OPTION_P -p
				option OPTION_N --no-option off:"omission"
			}
			When call parse  --option=value1 -o -pvalue2 --no-option
			The variable OPTION should eq "value1"
			The variable OPTION_O should eq "default"
			The variable OPTION_P should eq "value2"
			The variable OPTION_N should eq "omission"
		End

		Context "when specified an argument to --no-option"
			parser_definition() {
				setup ARGS
				option OPTION --no-option
			}
			It "displays error"
				When run parse --no-option=value
				The stderr should eq "Does not allow an argument: --no-option"
				The status should be failure
			End
		End

		It "remains initial value when not specified parameter"
			parser_definition() {
				setup ARGS
				option OPTION_O -p init:="initial"
			}
			When call parse
			The variable OPTION_O should eq "initial"
		End

		It "calls the function"
			parser_definition() {
				setup ARGS
				option :'foo "$1"' -o
			}
			foo() { echo "set [$OPTARG] : ${*:-}"; }
			When run parse -o123
			The output should eq "set [123] : -o"
		End

		It "calls the validator"
			valid() { echo "$OPTARG" "$@"; }
			parser_definition() {
				setup ARGS
				option OPTION_O -o validate:'valid "$1"' on:"default"
				option OPTION_P -p validate:'valid "$1"'
				option OPTION   --option validate:'valid "$1"'
			}
			When call parse -o -pvalue1 --option=value2
			The line 1 should eq "default -o"
			The line 2 should eq "value1 -p"
			The line 3 should eq "value2 --option"
		End

		Context 'when specified pattern attribute'
			Parameters
				foo success stdout ""
				baz failure stderr "Does not match the pattern (foo | bar): -o"
			End

			It "checks if it matches the pattern"
				parser_definition() {
					setup ARGS
					option OPTION -o pattern:'foo | bar'
				}
				When run parse -o"$1"
				The status should be "$2"
				The "$3" should eq "$4"
			End
		End
	End

	Describe 'disp helper'
		BeforeRun VERSION=1.0

		It "displays the variable"
			parser_definition() {
				setup ARGS
				disp VERSION -v
			}
			When run parse -v
			The output should eq "1.0"
		End

		It "calls the function"
			version() { echo "func: $VERSION"; }
			parser_definition() {
				setup ARGS
				disp :version -v
			}
			When run parse -v
			The output should eq "func: 1.0"
		End
	End

	Describe 'msg helper'
		It "does nothing"
			parser_definition() {
				setup ARGS
				msg -- 'test' 'foo bar'
			}
			When run parse
			The output should be blank
		End
	End

	Describe 'subcommand'
		parser_definition() {
			setup ARGS
			flag FLAG -f
			cmd list
		}

		Context "when specify a subcommand that exists"
			Specify "treat subcommands and the rest as arguments"
				When call restargs -f list -g 1 2
				The output should eq "list -g 1 2"
				The variable FLAG should eq "1"
			End
		End

		Context "when not specify a subcommand"
			Specify "parse global options only"
				When call restargs -f
				The output should eq ""
				The variable FLAG should eq "1"
			End
		End

		Context "when no subcommand and only arguments are passed"
			Specify "the first argument is --"
				When call restargs -f -- list 1 2
				The output should eq "-- list 1 2"
				The variable FLAG should eq "1"
			End
		End

		Context "when specify a subcommand that not exists"
			Specify "displays error"
				When run restargs -f unknown -g 1 2
				The error should eq "Not a command: unknown"
				The status should be failure
			End
		End
	End
End
