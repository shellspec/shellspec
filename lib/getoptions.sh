# shellcheck shell=sh
# URL: https://github.com/ko1nksm/getoptions (v2.1.0)
# License: Creative Commons Zero v1.0 Universal
# shellcheck disable=SC2016
getoptions() {
	_error='' _on=1 _off='' _export='' _plus='' _mode='' _alt='' _rest=''
	_opts='' _help='' _abbr='' _indent='' _init=@empty IFS=' '

	for i in 0 1 2 3 4 5; do
		eval "_$i() { echo \"$_indent\$@\"; }"
		_indent="$_indent	"
	done

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

	invoke() { eval '"_$@"'; }
	prehook() { invoke "$@"; }
	for i in setup flag param option disp msg; do
		eval "$i() { prehook $i \"\$@\"; }"
	done

	args() {
		on=$_on off=$_off export=$_export init=$_init _hasarg=$1
		while [ $# -gt 2 ] && [ "$3" != '--' ] && shift; do
			case $2 in
				-?) [ "$_hasarg" ] || _opts="$_opts${2#-}" ;;
				+*) _plus=1 ;;
				[!-+]*) eval "${2%%:*}=\${2#*:}"
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
		[ $# -gt 0 ] && { [ "$1" ] && _rest=$1; shift; }
		for i; do [ "$i" = '--' ] && break; eval "_${i%%:*}=\${i#*:}"; done
	}
	_flag() { args : "$@"; defvar "$@"; }
	_param() { args '' "$@"; defvar "$@"; }
	_option() { args '' "$@"; defvar "$@"; }
	_disp() { args : "$@"; }
	_msg() { args : _ "$@"; }

	"$@"
	_0 "${_rest:?}=''"

	_0 "$2() {"
	_1 'OPTIND=$(($#+1))'
	_1 'while OPTARG= && [ $# -gt 0 ]; do'
	[ "$_abbr" ] && getoptions_abbr "$@"

	args() {
		sw='' validate='' pattern='' counter='' on=$_on off=$_off export=$_export
		while [ $# -gt 1 ] && [ "$2" != '--' ] && shift; do
			case $1 in
				--\{no-\}*) sw="$sw${sw:+ | }--${1#--?no-?} | --no-${1#--?no-?}" ;;
				[-+]? | --*) sw="$sw${sw:+ | }$1" ;;
				*) eval "${1%%:*}=\"\${1#*:}\""
			esac
		done
	}
	setup() { :; }
	_flag() {
		args "$@"
		quote on "$on" && quote off "$off"
		[ "$counter" ] && on=1 off=-1 v="\$((\${$1:-0}+\${OPTARG:-0}))" || v=''
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
		quote on "$on" && quote off "$off"
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
			_5 "*) set \"pattern:$pattern\" \"\$1\"; break"
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
	wa() { _4 "eval '${1% *}' \${1+'\"\$@\"'}"; }
	_3 '--?*=*) OPTARG=$1; shift'
	wa 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}" "$@"'
	_4 ';;'
	_3 '--no-*) unset OPTARG ;;'
	[ "$_alt" ] || {
		[ "$_opts" ] && {
			_3 "-[$_opts]?*) OPTARG=\$1; shift"
			wa 'set -- "${OPTARG%"${OPTARG#??}"}" "${OPTARG#??}" "$@"'
			_4 ';;'
		}
		_3 '-[!-]?*) OPTARG=$1; shift'
		wa 'set -- "${OPTARG%"${OPTARG#??}"}" "-${OPTARG#??}" "$@"'
		_4 'OPTARG= ;;'
	}
	[ "$_plus" ] && {
		_3 '+??*) OPTARG=$1; shift'
		wa 'set -- "${OPTARG%"${OPTARG#??}"}" "+${OPTARG#??}" "$@"'
		_4 'unset OPTARG ;;'
		_3 '+*) unset OPTARG ;;'
	}
	_2 'esac'
	_2 'case $1 in'
	"$@"
	rest() {
		_3 "$1"
		_4 'while [ $# -gt 0 ]; do'
		_5 "$_rest=\"\${$_rest}" '\"\${$((${OPTIND:-0}-$#))}\""'
		_5 'shift'
		_4 'done'
		_4 'break ;;'
	}
	rest '--) shift'
	_3 "[-${_plus:++}]?*)" 'set "unknown" "$1" && break ;;'
	case $_mode in
		+) rest '*)' ;;
		*) _3 "*) $_rest=\"\${$_rest}" '\"\${$((${OPTIND:-0}-$#))}\""'
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
	_2 '*) set "Validation error ($1): $2" "$@"'
	_1 'esac'
	[ "$_error" ] && _1 "$_error" '"$@" >&2 || exit $?'
	_1 'echo "$1" >&2'
	_1 'exit 1'
	_0 '}'

	[ ! "$_help" ] || eval "shift 2; getoptions_help $1 $_help" ${3+'"$@"'}
}
