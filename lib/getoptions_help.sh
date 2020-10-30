# shellcheck shell=sh
# URL: https://github.com/ko1nksm/getoptions (v2.0.0)
# License: Creative Commons Zero v1.0 Universal
getoptions_help() {
	width=30 plus='' leading='  '

	pad() { p=$2; while [ ${#p} -lt "$3" ]; do p="$p "; done; eval "$1=\$p"; }

	args() {
		_type=$1 var=${2%% *} sw='' label='' hidden='' _width=$width && shift 2
		while [ $# -gt 0 ] && i=$1 && shift && [ ! "$i" = '--' ]; do
			case $i in
				--*) pad sw "$sw${sw:+, }" $((${plus:+4}+4)); sw="$sw$i" ;;
				-?) sw="$sw${sw:+, }$i" ;;
				+?) [ ! "$plus" ] || { pad sw "$sw${sw:+, }" 4; sw="$sw$i"; } ;;
				*) eval "${i%%:*}=\${i#*:}"
			esac
		done
		[ "$hidden" ] && return 0

		[ "$label" ] || case $_type in
			setup | msg) label='' _width=0 ;;
			flag | disp) label="$sw " ;;
			param) label="$sw $var " ;;
			option) label="${sw}[=$var] "
		esac
		pad label "${label:+$leading}$label" "$_width"
		[ ${#label} -le "$_width" ] && [ $# -gt 0 ] && label="$label$1" && shift
		echo "$label"
		pad label '' "$_width"
		for i; do echo "$label$i"; done
	}

	for i in 'setup :' flag param option disp 'msg :'; do
		eval "${i% *}() { args $i \"\$@\"; }"
	done

	echo "$2() {"
	echo "cat<<'GETOPTIONSHERE'"
	"$@"
	echo "GETOPTIONSHERE"
	echo "}"
}
