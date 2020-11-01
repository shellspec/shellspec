# shellcheck shell=sh disable=SC1083,SC2004,SC2016

Describe "getoptions_abbr()"
	Include ./lib/getoptions.sh
	Include ./lib/getoptions_abbr.sh

	parse() {
		eval "$(getoptions parser_definition _parse)"
		case $# in
			0) _parse ;;
			*) _parse "$@" ;;
		esac
	}

	It "generates option parser with abbreviation module"
		parser_definition() { setup ARGS abbr:true; }
		getoptions_abbr() { echo 'getoptions_abbr called' >&2; }
		When call parse
		The stderr should eq 'getoptions_abbr called'
		The status should be success
	End

	Describe 'Default error handler'
		Context "when specified an ambiguous option"
			It "displays error"
				parser_definition() {
					setup ARGS abbr:true
					flag FLAG --flag-a
					flag FLAG --flag-b
				}
				When run parse --flag
				The stderr should eq "Ambiguous option: --flag (could be --flag-a, --flag-b)"
				The status should be failure
			End
		End
	End

	Describe 'custom error handler'
		myerror() {
			case $2 in
				ambiguous)
					echo "message: $1"
					echo "error name: $2"
					echo "option: $3"
					echo "candidate $(($# - 3)): $4 $5"
					echo "$OPTARG"
					return 12
			esac
			return 0
		}

		Context "when specified an ambiguous option"
			It "displays error"
				parser_definition() {
					setup ARGS abbr:true error:myerror
					flag FLAG --flag-a
					flag FLAG --flag-b
				}
				When run parse --flag
				The line 1 of stderr should eq "message: Ambiguous option: --flag (could be --flag-a, --flag-b)"
				The line 2 of stderr should eq "error name: ambiguous"
				The line 3 of stderr should eq "option: --flag"
				The line 4 of stderr should eq "candidate 2: --flag-a --flag-b"
				The line 5 of stderr should eq "--flag-a, --flag-b"
				The status should eq 12
			End
		End
	End

	Context "when abbreviation attribute specified"
		parser_definition() {
			setup  ARGS abbr:true
			flag   FLAG --flag
			param  PARAM --param
			option OPTION --{no-}option
		}
		It "treats an abbreviation option"
			When call parse --p=value
			The variable PARAM should eq "value"
		End

		It "treats an abbreviation option"
			When call parse --o
			The variable OPTION should eq 1
		End

		It "treats an abbreviation option"
			When call parse --n
			The variable OPTION should eq ''
		End
	End

	Context "when hide attribute specified"
		parser_definition() {
			setup ARGS abbr:true
			flag  FLAG --flag -- hidden
			param PARAM --param hidden:true
		}

		It "does not treat as an abbreviation option"
			When run parse --p value
			The stderr should eq "Unrecognized option: --p"
			The status should be failure
		End
	End

	Context "when the specified option contains metacharacters"
		parser_definition() {
			setup ARGS abbr:true
			flag  FLAG_A --flag-a
			flag  FLAG_B --flag-b
		}

		It "does not match an abbreviation option"
			When run parse '--*'
			The stderr should eq "Unrecognized option: --*"
			The status should be failure
		End
	End
End
