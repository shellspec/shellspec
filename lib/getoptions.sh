# shellcheck shell=sh disable=SC2016
# [getoptions] License: Creative Commons Zero v1.0 Universal
getoptions() {
	_error='' _on=1 _off='' _export='' _plus='' _mode='' _alt='' _rest=''
	_flags='' _nflags='' _opts='' _help='' _abbr='' _cmds='' _init=@empty IFS=' '

	_0() { echo "$@"; }
	for i in 1 2 3 4 5; do eval "_$i() { _$((${i-}-1)) \"	\$@\"; }"; done

	quote() {
		q="$2'" r=''
		while [ "$q" ]; do r="$r${q%%\'*}'\''" && q=${q#*\'}; done
		q="'${r%????}'" && q=${q#\'\'} && q=${q%\'\'}
		eval "$1=\${q:-\"''\"}"
	}
	code() {
		[ "${1#:}" = "$1" ] && c=3 || c=4
		eval "[ ! \${$c:+x} ] || $2 \"\$$c\""
	}
	kv() { eval "${2-}${1%%:*}=\${1#*:}"; }
	loop() { [ $# -gt 1 ] && [ "$2" != -- ]; }

	invoke() { eval '"_$@"'; }
	prehook() { invoke "$@"; }
	for i in setup flag param option disp msg; do
		eval "$i() { prehook $i \"\$@\"; }"
	done

	args() {
		on=$_on off=$_off export=$_export init=$_init _hasarg=$1 && shift
		while loop "$@" && shift; do
			case $1 in
				-?) [ "$_hasarg" ] && _opts="$_opts${1#-}" || _flags="$_flags${1#-}" ;;
				+?) _plus=1 _nflags="$_nflags${1#+}" ;;
				[!-+]*) kv "$1"
			esac
		done
	}
	defvar() {
		case $init in
			@none) : ;;
			@export) code "$1" _0 "export $1" ;;
			@empty) code "$1" _0 "${export:+export }$1=''" ;;
			@unset) code "$1" _0 "unset $1 ||:" "unset OPTARG ||:; ${1#:}" ;;
			*)
				case $init in @*) eval "init=\"=\${${init#@}}\""; esac
				case $init in [!=]*) _0 "$init"; return 0; esac
				quote init "${init#=}"
				code "$1" _0 "${export:+export }$1=$init" "OPTARG=$init; ${1#:}"
		esac
	}
	_setup() {
		[ "${1#-}" ] && _rest=$1
		while loop "$@" && shift; do kv "$1" _; done
	}
	_flag() { args '' "$@"; defvar "$@"; }
	_param() { args 1 "$@"; defvar "$@"; }
	_option() { args 1 "$@"; defvar "$@"; }
	_disp() { args '' "$@"; }
	_msg() { args '' _ "$@"; }

	cmd() { _mode=@ _cmds="$_cmds${_cmds:+|}'$1'"; }
	"$@"
	cmd() { :; }
	_0 "${_rest:?}=''"

	_0 "$2() {"
	_1 'OPTIND=$(($#+1))'
	_1 'while OPTARG= && [ $# -gt 0 ]; do'
	[ "$_abbr" ] && getoptions_abbr "$@"

	args() {
		sw='' validate='' pattern='' counter='' on=$_on off=$_off export=$_export
		while loop "$@" && shift; do
			case $1 in
				--\{no-\}*) i=${1#--?no-?}; sw="$sw${sw:+|}'--$i'|'--no-$i'" ;;
				[-+]? | --*) sw="$sw${sw:+|}'$1'" ;;
				*) kv "$1"
			esac
		done
		quote on "$on"
		quote off "$off"
	}
	setup() { :; }
	_flag() {
		args "$@"
		[ "$counter" ] && on=1 off=-1 v="\$((\${$1:-0}+\$OPTARG))" || v=''
		_3 "$sw)"
		_4 '[ "${OPTARG:-}" ] && OPTARG=${OPTARG#*\=} && set "noarg" "$1" && break'
		_4 "eval '[ \${OPTARG+x} ] &&:' && OPTARG=$on || OPTARG=$off"
		valid "$1" "${v:-\$OPTARG}"
		_4 ';;'
	}
	_param() {
		args "$@"
		_3 "$sw)"
		_4 '[ $# -le 1 ] && set "required" "$1" && break'
		_4 'OPTARG=$2'
		valid "$1" '$OPTARG'
		_4 'shift ;;'
	}
	_option() {
		args "$@"
		_3 "$sw)"
		_4 'set -- "$1" "$@"'
		_4 '[ ${OPTARG+x} ] && {'
		_5 'case $1 in --no-*) set "noarg" "${1%%\=*}"; break; esac'
		_5 '[ "${OPTARG:-}" ] && { shift; OPTARG=$2; } ||' "OPTARG=$on"
		_4 "} || OPTARG=$off"
		valid "$1" '$OPTARG'
		_4 'shift ;;'
	}
	valid() {
		set -- "$validate" "$pattern" "$1" "$2"
		[ "$1" ] && _4 "$1 || { set -- ${1%% *}:\$? \"\$1\" $1; break; }"
		[ "$2" ] && {
			_4 "case \$OPTARG in $2) ;;"
			_5 '*) set "pattern:'"$2"'" "$1"; break'
			_4 "esac"
		}
		code "$3" _4 "${export:+export }$3=\"$4\"" "${3#:}"
	}
	_disp() {
		args "$@"
		_3 "$sw)"
		code "$1" _4 "echo \"\${$1}\"" "${1#:}"
		_4 'exit 0 ;;'
	}
	_msg() { :; }

	[ "$_alt" ] && _2 'case $1 in -[!-]?*) set -- "-$@"; esac'
	_2 'case $1 in'
	_wa() { _4 "eval 'set -- $1' \${1+'\"\$@\"'}"; }
	_op() {
		_3 "$1) OPTARG=\$1; shift"
		_wa '"${OPTARG%"${OPTARG#??}"}" '"$2"'"${OPTARG#??}"'
		_4 "$3"
	}
	_3 '--?*=*) OPTARG=$1; shift'
	_wa '"${OPTARG%%\=*}" "${OPTARG#*\=}"'
	_4 ';;'
	_3 '--no-*) unset OPTARG ;;'
	[ "$_alt" ] || {
		[ "$_opts" ] && _op "-[$_opts]?*" '' ';;'
		[ ! "$_flags" ] || _op "-[$_flags]?*" - 'OPTARG= ;;'
	}
	[ "$_plus" ] && {
		[ "$_nflags" ] && _op "+[$_nflags]?*" + 'unset OPTARG ;;'
		_3 '+*) unset OPTARG ;;'
	}
	_2 'esac'
	_2 'case $1 in'
	"$@"
	rest() {
		_4 'while [ $# -gt 0 ]; do'
		_5 "$_rest=\"\${$_rest}" '\"\${$(($OPTIND-$#))}\""'
		_5 'shift'
		_4 'done'
		_4 'break ;;'
	}
	_3 '--)'
	[ "$_mode" = @ ] || _4 'shift'
	rest
	_3 "[-${_plus:++}]?*)"
	case $_mode in [=#]) rest ;; *) _4 'set "unknown" "$1"; break ;;'; esac
	_3 '*)'
	case $_mode in
		@)
			_4 "case \$1 in ${_cmds:-*}) ;;"
			_5 '*) set "notcmd" "$1"; break'
			_4 'esac'
			rest ;;
		[+#]) rest ;;
		*) _4 "$_rest=\"\${$_rest}" '\"\${$(($OPTIND-$#))}\""'
	esac
	_2 'esac'
	_2 'shift'
	_1 'done'
	_1 '[ $# -eq 0 ] && { OPTIND=1; unset OPTARG; return 0; }'
	_1 'case $1 in'
	_2 'unknown) set "Unrecognized option: $2" "$@" ;;'
	_2 'noarg) set "Does not allow an argument: $2" "$@" ;;'
	_2 'required) set "Requires an argument: $2" "$@" ;;'
	_2 'pattern:*) set "Does not match the pattern (${1#*:}): $2" "$@" ;;'
	_2 'notcmd) set "Not a command: $2" "$@" ;;'
	_2 '*) set "Validation error ($1): $2" "$@"'
	_1 'esac'
	[ "$_error" ] && _1 "$_error" '"$@" >&2 || exit $?'
	_1 'echo "$1" >&2'
	_1 'exit 1'
	_0 '}'

	[ ! "$_help" ] || eval "shift 2; getoptions_help $1 $_help" ${3+'"$@"'}
}
