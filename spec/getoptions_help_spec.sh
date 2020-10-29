# shellcheck shell=sh disable=SC1083,SC2004,SC2016

Describe "getoptions_help()"
	Include ./lib/getoptions_help.sh

	usage() {
		eval "$(getoptions_help parser_definition _usage)"
		case $# in
			0) _usage ;;
			*) _usage "$@" ;;
		esac
	}

	It "generates usage"
		parser_definition() { echo 'usage'; }
		When call usage
		The output should eq "usage"
		The status should be success
	End

	It "displays usage"
		parser_definition() {
			setup width:20 plus:true -- 'usage'
			msg -- "header"
			msg label:option -- "description"
			flag FLAG_A -a +a --{no-}flag-a -- "flag a"
			param PARAM_P -p -- "param p"
			option OPTION_O -o -- "option o"
			msg -- "footer"
		}
		When call usage
		The line 1 should eq "usage"
		The line 2 should eq "header"
		The line 3 should eq "  option            description"
		The line 4 should eq "  -a, +a, --{no-}flag-a "
		The line 5 should eq "                    flag a"
		The line 6 should eq "  -p PARAM_P        param p"
		The line 7 should eq "  -o[=OPTION_O]     option o"
		The line 8 should eq "footer"
	End
End
