# shellcheck shell=sh
# [getoptions_help] License: Creative Commons Zero v1.0 Universal
getoptions_help() {
	_width='30,12' _plus='' _leading='  '

	pad() { p=$2; while [ ${#p} -lt "$3" ]; do p="$p "; done; eval "$1=\$p"; }
	kv() { eval "${2-}${1%%:*}=\${1#*:}"; }
	sw() { pad sw "$sw${sw:+, }" "$1"; sw="$sw$2"; }

	args() {
		_type=$1 var=${2%% *} sw='' label='' hidden='' && shift 2
		while [ $# -gt 0 ] && i=$1 && shift && [ "$i" != -- ]; do
			case $i in
				--*) sw $((${_plus:+4}+4)) "$i" ;;
				-?) sw 0 "$i" ;;
				+?) [ ! "$_plus" ] || sw 4 "$i" ;;
				*) [ "$_type" = setup ] && kv "$i" _; kv "$i"
			esac
		done
		[ "$hidden" ] && return 0 || len=${_width%,*}

		[ "$label" ] || case $_type in
			setup | msg) label='' len=0 ;;
			flag | disp) label="$sw " ;;
			param) label="$sw $var " ;;
			option) label="${sw}[=$var] "
		esac
		[ "$_type" = cmd ] && label=${label:-$var } len=${_width#*,}
		pad label "${label:+$_leading}$label" "$len"
		[ ${#label} -le "$len" ] && [ $# -gt 0 ] && label="$label$1" && shift
		echo "$label"
		pad label '' "$len"
		for i; do echo "$label$i"; done
	}

	for i in setup flag param option disp 'msg -' cmd; do
		eval "${i% *}() { args $i \"\$@\"; }"
	done

	echo "$2() {"
	echo "cat<<'GETOPTIONSHERE'"
	"$@"
	echo "GETOPTIONSHERE"
	echo "}"
}
