#!/bin/sh
# shellcheck disable=SC2004

if [ -z "$PPID" ]; then
  echo 'Bourne Shell is not supported.' \
    'Run in a specific POSIX shell as follows.' >&2
  echo '$ ksh shellspec-time sleep 1' >&2
  exit 1
fi

set -f

: "${SHELLSPEC_TRAP:=trap}"
: "${SHELLSPEC_TIME_TYPE:=auto}"
LF='
'

"$SHELLSPEC_TRAP" : INT

datetime2unixtime() {
  set -- "$1" "${2%%-*}" "${2%%T*}" "${2##*T}"
  set -- "$1" "${2#"${2%%[!0]*}"}" "${3#*-}" "${4%%:*}" "${4#*:}"
  set -- "$1" "$2" "${3%%-*}" "${3#*-}" "$4" "${5%%:*}" "${5#*:}"
  set -- "$1" "${2:-0}" "${3#0}" "${4#0}" "${5#0}" "${6#0}" "${7#0}"
  [ "$3" -lt 3 ] && set -- "$1" $(($2-1)) $(($3+12)) "$4" "$5" "$6" "$7"
  set -- "$1" $((365*$2+$2/4-$2/100+$2/400)) "$3" "$4" "$5" "$6" "$7"
  set -- "$1" "$2" $(((306*($3+1)/10)-428)) "$4" "$5" "$6" "${7%.*}" "${7#*.}"
  eval "$1=$((($2+$3+$4-719163)*86400+$5*3600+$6*60+$7))${8:+.}${8}"
}

time_using_date() {
  date +'start %Y-%m-%dT%H:%M:%S.%N'
  "$@"
  set -- $?
  date +'end %Y-%m-%dT%H:%M:%S.%N'
  return "$1"
}

detect_time_type() {
  [ "$SHELLSPEC_TIME_TYPE" = auto ] || return 0

  if ! { time true; } >/dev/null 2>&1; then
    SHELLSPEC_TIME_TYPE=external-date && return 0
  fi

  if [ ! "${KSH_VERSION:-}" ]; then
    KSH_VERSION=$(eval 'echo ${.sh.version}')
  fi 2>/dev/null

  if [ "${BASH_VERSION:-}" ]; then
    SHELLSPEC_TIME_TYPE=bash-builtin && return 0
  fi

  if [ "${KSH_VERSION:-}" ]; then
    case $KSH_VERSION in
      *PD\ KSH*) SHELLSPEC_TIME_TYPE=pdksh-builtin ;;
      *MIRBSD\ KSH*) SHELLSPEC_TIME_TYPE=mksh-builtin ;;
      *LEGACY\ KSH*) SHELLSPEC_TIME_TYPE=lksh-builtin ;;
      *) SHELLSPEC_TIME_TYPE=ksh93-builtin ;;
    esac
    return 0
  fi

  if [ "${ZSH_VERSION:-}" ]; then
    SHELLSPEC_TIME_TYPE=zsh-builtin && return 0
  fi

  if { time -p true; } >/dev/null 2>&1; then
    SHELLSPEC_TIME_TYPE=external-time
  else
    SHELLSPEC_TIME_TYPE=legacy-time
  fi
}

detect_time_type

{
  (
    "$SHELLSPEC_TRAP" : INT

    set -- -- "$@"

    case ${LC_ALL+x} in
      ?) set -- -s LC_ALL "$LC_ALL" "$@" ;;
      *) set -- -u LC_ALL "$@" ;;
    esac
    export LC_ALL=C

    # bash or ksh93
    case ${TIMEFORMAT+x} in
      ?) set -- -s TIMEFORMAT "$TIMEFORMAT" "$@" ;;
      *) set -- -u TIMEFORMAT "$@" ;;
    esac
    TIMEFORMAT="real %R${LF}user %U${LF}sys %S"

    # zsh
    case ${TIMEFMT+x} in
      ?) set -- -s TIMEFMT "$TIMEFMT" "$@" ;;
      *) set -- -u TIMEFMT "$@" ;;
    esac
    TIMEFMT="real %*E${LF}user %*U${LF}sys %*S"

    # GNU time
    case ${TIME+x} in
      ?) set -- -s TIME "$TIME" "$@" ;;
      *) set -- -u TIME "$@" ;;
    esac
    export TIME="real %e${LF}user %U${LF}sys %S"

    # shellcheck disable=SC2016
    set -- sh -c '
      # Use Bourne shell syntax as sh may be a Bourne shell
      while [ $# -gt 0 ]; do
        case $1 in
          -s) eval "$2=\"\$3\""; export "$2"; shift 2 ;;
          -u) unset "$2"; shift ;;
          --) shift; break ;;
           *) break ;;
        esac
        shift
      done
      exec "$@" 2>&3 >&4 3>&- 4>&-
    ' "$0" "$@"

    case $SHELLSPEC_TIME_TYPE in
      external-date)
	time_using_date "$@"
        ;;
      external-bash)
        bash -c 'TIMEFORMAT=$1; shift; time "$@"' "$0" "$TIMEFORMAT" "$@"
        ;;
      external-ksh)
        ksh -c 'TIMEFORMAT=$1; shift; time "$@"' "$0" "$TIMEFORMAT" "$@"
        ;;
      external-zsh)
        zsh -c 'TIMEFMT=$1; shift; time "$@"' "$0" "$TIMEFMT" "$@"
        ;;
      bash-builtin | ksh93-builtin | zsh-builtin | legacy-time)
        time "$@"
        ;;
      mksh-builtin | lksh-builtin | pdksh-builtin | external-time | *)
        time -p "$@"
        ;;
    esac
    echo "ex $?" >&2
  ) 2>&1 | (
    "$SHELLSPEC_TRAP" '' INT

    real='' user='' sys='' type=$SHELLSPEC_TIME_TYPE ex=''

    while read -r name time; do
      # ksh88: 1m2.34s
      case $time in *m*s)
        type=ksh88-builtin
        min=${time%m*} && time=${time#*m}
        sec=${time%.*} && time=${time#*.} && time=${time%s}
        time="$(($min * 60 + $sec)).$time"
      esac

      case $name in (real | user | sys | start | end | ex)
        eval "$name=\$time"
      esac
    done

    if [ ! "$real" ]; then
      datetime2unixtime start "$start"
      datetime2unixtime end "$end"
      real=$((${end%.*} - ${start%.*}))
      case $start in
        *[!0-9.]*) ;;
        *)
          start="${start#*.}00" end="${end#*.}00"
          start="1${start%"${start#??}"}" end="3${end%"${end#??}"}"
          diff=$(($end - $start))
          real="$(( $real - ($diff < 200) )).${diff#[12]}"
      esac
    fi
    if [ "${SHELLSPEC_TIME_LOG:+x}" ]; then
      exec 2>"$SHELLSPEC_TIME_LOG"
    fi
    echo "real:${real:-0} user:$user sys:$sys type:$type" >&2
    exit "${ex:-1}"
  )
} 3>&2 4>&1
