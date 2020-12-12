# shellcheck shell=sh disable=SC2016,SC2154
# [getoptions_abbr] License: Creative Commons Zero v1.0 Universal
getoptions_abbr() {
	abbr() {
		_3 "case '$1' in"
		_4 '"$1") OPTARG=; break ;;'
		_4 '$1*) OPTARG="$OPTARG '"$1"'"'
		_3 'esac'
	}
	args() {
		abbr=1
		shift
		for i; do
			case $i in
				--) break ;;
				[!-+]*) eval "${i%%:*}=\${i#*:}"
			esac
		done
		[ "$abbr" ] || return 0

		for i; do
			case $i in
				--) break ;;
				--\{no-\}*) abbr "--${i#--\{no-\}}"; abbr "--no-${i#--\{no-\}}" ;;
				--*) abbr "$i"
			esac
		done
	}
	setup() { :; }
	for i in flag param option disp; do
		eval "_$i()" '{ args "$@"; }'
	done
	msg() { :; }
	_2 'set -- "${1%%\=*}" "${1#*\=}" "$@"'
	[ "$_alt" ] && _2 'case $1 in -[!-]?*) set -- "-$@"; esac'
	_2 'while [ ${#1} -gt 2 ]; do'
	_3 'case $1 in (*[!a-zA-Z0-9_-]*) break; esac'
	"$@"
	_3 'break'
	_2 'done'
	_2 'case ${OPTARG# } in'
	_3 '*\ *)'
	_4 'eval "set -- $OPTARG $1 $OPTARG"'
	_4 'OPTIND=$((($#+1)/2)) OPTARG=$1; shift'
	_4 'while [ $# -gt "$OPTIND" ]; do OPTARG="$OPTARG, $1"; shift; done'
	_4 'set "Ambiguous option: $1 (could be $OPTARG)" ambiguous "$@"'
	[ "$_error" ] && _4 "$_error" '"$@" >&2 || exit $?'
	_4 'echo "$1" >&2'
	_4 'exit 1 ;;'
	_3 '?*)'
	_4 '[ "$2" = "$3" ] || OPTARG="$OPTARG=$2"'
	_4 "shift 3; eval 'set -- \"\${OPTARG# }\"' \${1+'\"\$@\"'}; OPTARG= ;;"
	_3 '*) shift 2'
	_2 'esac'
}
