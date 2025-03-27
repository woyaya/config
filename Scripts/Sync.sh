#!/bin/bash
# Variables
REALPATH=`realpath $0`
EXEC=`basename $REALPATH`
DIR=`dirname $REALPATH`
export REALPATH EXEC DIR

#1: ERR; 2:ERR+WRN; 3:ERR+WRN+INF
LOG_LEVEL=${LOG_LEVEL:-2}
LOG2LOGGER=${LOG2LOGGER:-0}
DEBUG=${DEBUG:-0}
BASE=$DIR
ROOT="/"
BACKUP="$BASE"
DRYRUN=""
#Functions
############################
USAGE(){
	echo "Back up the files/folders listed in list_file"
	echo "Usage: $1 [params] -l list_file"
	echo "     -l list_file: list file"
	echo "     -B dir: base dir, where to find functions. default: $BASE"
	echo "     -r dir: root dir, where to find file/dir if it not exist @ \"/\". default: $ROOT"
	echo "     -b dir: backup dir, sync file/dir here. default: $BACKUP"
	echo "     -H dir: home dir, Used to replace the character ‘～’. default: $HOME"
	echo "     -P script: Pre-process script(s)"
	echo "     -p script: Post-process script(s)"
	echo "     -R: reverse  the  direction(From backup dir to root dir)"
	echo "     -n: dry run, perform a trial run with no changes made"
	echo "     -v: more verbose output"
	echo "     -L: log to logger"
	echo "     -D: debug mode"
	echo "     -h: print this"

	exit -1
}
cleanup() {
	LOG "Cleanup $WORK_DIR: $DELETE"
	[ "$DELETE" != "0" ] && {
		[ -d $WORK_DIR ] && rm  -rf $WORK_DIR
	}
}
check_permission(){
	local path="$1"
	while true;do
		#[ -e "$path" -o "$path" = "/" ] && break
		[ -e "$path" ] && break
		path=`dirname "$path"`
	done
	[ -w "$path" ] || return 1
	return 0
}
get_path_real(){
	local var
	local len
	local param="$1"
	case "${param::1}" in
		'~')
			param=`echo "$1" | sed "s#^~#$HOME#"`
		;;
		'$')
			var=`echo "$1" | sed 's/\/.*//'`
			len=${#var}
			var=`eval "echo $var"`
			param="${var}${param:$len}"
		;;
	esac
	echo "$param" | sed 's/\/\+/\//g'
}
_virtual_path(){
	echo -n "$BACKUP/"
	echo "$1" | sed 's#^~#HOME#;s#^\$##'
}
get_path_virtual(){
	_virtual_path $1 | sed 's/\/\+/\//g'
}
call_scripts(){
	local script
	for script in $@
	do
		[ ! -f $script ] && {
			INF "Can not find script: $script, SKIP!"
			continue
		}
		if [ -x $script ];then
			INF "Run script: $script"
			$script
		else
			ERR "Can not execute script: $script, SKIP!"
		fi
	done
}

rsync_version(){
	[ -z "$1" ] && {
		rsync --version | sed '/version/!d;s/.*version \([0-9]\)\.\([0-9]\).* protocol.*/\1\2/'
		return
	}
	ssh -n $1 'rsync --version 2>/dev/null' | sed '/version/!d;s/.*version \([0-9]\)\.\([0-9]\).* protocol.*/\1\2/'
}
rsync_atime(){
	local rversion
	[ -n "$1" ] && rversion=`rsync_version "$1"` || rversion="$LVERSION"
	[ -z "$rversion" ] && return 1
	[ "$rversion" -ge 32 -a "$LVERSION" -ge 32 ] && {
		echo "--open-noatime"
		return 0
	}
	[ "$rversion" -lt 32 -a "$LVERSION" -lt 32 ] && {
		echo "--noatime"
		return 0
	}
	#unmatch version, 'atime' is not supported
	return 0;
}
#line_fail line descript
line_fail(){
	local _desc
	local _line=$1
	shift 1
	_desc=$@
	_desc=${_desc:-"invalid line"}
	WRN "$_desc: $_line"
	FAIL="$FAIL*<$_line>: $_desc"
}
line_succ(){
	local _desc
	local _line=$1
	shift 1
	_desc=$@
	_desc=${_desc:-"success"}
	INF "$_desc: $_line"
	SUCC="$SUCC*<$_line>: $_desc"
}

LIST=""
REVERT=""
PREPROCESS=()
POSTPROCESS=()
############################
while getopts ":B:r:b:H:l:P:p:RnvLD" opt; do
	case $opt in
		B)
			BASE=$OPTARG
		;;
		r)
			ROOT=$OPTARG
		;;
		b)
			BACKUP=$OPTARG
		;;
		H)
			HOME=$OPTARG
			export HOME
		;;
		l)
			LIST=$OPTARG
		;;
		P)
			PREPROCESS+=("$OPTARG")
		;;
		p)
			POSTPROCESS+=("$OPTARG")
		;;
		R)
			REVERT=1
		;;
		n)
			DRYRUN="-n"
		;;
		v)
			LOG_LEVEL=$((LOG_LEVEL+1))
		;;
		L)
			LOG2LOGGER=1
		;;
		D)
			DEBUG=1
			DELETE=0
			LOG_LEVEL=999
		;;
		*)
			USAGE $0
		;;
	esac
done

export DEBUG
export LOG_LEVEL
export BASE ROOT BACKUP REVERT

COMMON=$BASE/common.sh
[ ! -f $COMMON ] && COMMON=$BASE/functions/common.sh
[ ! -f $COMMON ] && COMMON=$BASE/functions/shell/common.sh
[ ! -f $COMMON ] && {
	echo "Invalid setting! file \"$COMMON\" not exist"
	exit 1
}
export COMMON
. $COMMON

[ -z "$LIST" ] && USAGE $0
[ ! -f "$LIST" ] && FAIL "Can not found list file: $LIST"
mkdir -p $BACKUP

check_dirs $BASE $ROOT $HOME || FAIL "Incomplete dirs" 
check_variables HOME || FAIL "Incomplete variables"
check_execs rsync logger sed awk wc || FAIL "Incomplete executes"

#trap cleanup EXIT

LVERSION=`rsync_version`
[ "$LOG_LEVEL" -ge "5" ] && VERBOSE="-v" || VERBOSE="-q"

if [ "$REVERT" = "1" ];then
	ACTIION="Restore"
	PRESERVE=""
else
	ACTIION="Backup"
	PRESERVE="-X"
fi
call_scripts ${PREPROCESS[@]}

FAIL=""
SUCC=""
PARAMS="-HA --mkpath -a $PRESERVE $VERBOSE $DRYRUN `rsync_atime`"
INF "Read list from $LIST"
while read LINE; do
	DBG "Process line: $LINE"
	[ -z "$LINE" ] && continue
	line=`echo "$LINE" | sed 's/^ *//;/^#/d'`
	DBG "Ignore annotation: $line"
	[ -z "$line" ] && continue
	path=`echo "$line" | awk -F, '{print $1}' | sed 's/^ *//;s/,.*//'`
	params=`echo "$line" | awk -F, '{print $2}' | sed 's/.*,//;s/ *$//'`
	check=`echo "$line" | awk -F, '{print $3}'`
	DBG "Path: $path, params: $params, check: $check"
	[ -n "$check" ] && {
		line_fail "$line" "Invalid line(Too many comma)"
		continue
	}
	check_variables path || {
		line_fail "$line" "Invalid line(Too less comma)"
		continue
	}
	if [ "$REVERT" = "1" ];then
		dist=`get_path_real "$path"`
		src=`get_path_virtual "$path"`
	else
		src=`get_path_real "$path"`
		dist=`get_path_virtual "$path"`
	fi
	INF "Src: $src, dist: $dist, params: $params"
	[ -z "$src" -o -z "$dist" ] && {
		line_fail "$LINE" "Can not find dir: <$src>,<$dist>"
		continue
	}
	[ -d "$src" -a "/" != "${src: -1}" ] && src="$src/"
	[ -f "$src" ] && mkdir -p `dirname $dist`
	params="$params $PARAMS"
	LOG "$ACTIION from $src to $dist with params($params)"
	# Backup to local device
	LOG "rsync $params $src $dist"
	rsync $params $src $dist
	if [ $? = 0 ];then
		line_succ "$LINE" "$ACTIION $src to $dist success"
	else
		line_fail "$LINE" "$ACTIION $src to $dist fail"
	fi
done <$LIST

DBG "Process end: $LIST"
[ -n "$SUCC" ] && INF "$ACTIION succ list: `echo "$SUCC" | sed 's/\*</\n\t</g'`"
[ -n "$FAIL" ] && ERR "$ACTIION fail list: `echo "$FAIL" | sed 's/\*</\n\t</g'`"

call_scripts ${POSTPROCESS[@]}

INF "$ACTIION done: $LIST"
