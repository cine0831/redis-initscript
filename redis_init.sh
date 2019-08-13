#!/bin/bash
# -*-Shell-script-*-
#
#/**
# * Title    : redis all-in-one intanse launcher init script
# * Created  : 
# * Modifier : by Alex, Lee
# * Modified : 04-08-2019
# * E-mail   : cine0831@gmail.com
#**/
#
#set -e
#set -x

. /etc/rc.d/init.d/functions

readonly REDIS_USER="redis-s"
readonly REDIS_HOME="/home/redis-s"
REDIS_DIR=""

usage() {
    echo "
Usage: ${0##*/} [options]

Options:

    -t|--type
    -o|--opt
    -h|--help

Examples:
    ${0##*/} -t redis28-6379 -o {start|stop|restart|ping|version}

Description:
    Redis 2.8.x)
    type: redis28-6379, prefix: $REDIS_HOME/redis28, port: 6379
    type: redis28-6378, prefix: $REDIS_HOME/redis28, port: 6378
    type: redis28-6377, prefix: $REDIS_HOME/redis28, port: 6377
    type: redis28-6376, prefix: $REDIS_HOME/redis28, port: 6376
    type: redis28-6375, prefix: $REDIS_HOME/redis28, port: 6375
    type: redis28-6381, prefix: $REDIS_HOME/redis28, port: 6381

    Redis 5.0.x)
    type: redis50-6379, prefix: $REDIS_HOME/redis50, port: 6379
    type: redis50-6378, prefix: $REDIS_HOME/redis50, port: 6378
    type: redis50-6377, prefix: $REDIS_HOME/redis50, port: 6377
    type: redis50-6376, prefix: $REDIS_HOME/redis50, port: 6376
    type: redis50-6375, prefix: $REDIS_HOME/redis50, port: 6375
    type: redis50-6381, prefix: $REDIS_HOME/redis50, port: 6381
"
exit 1
}

check_pass() {
    local l_type=$1

    if [[ -d "$REDIS_HOME" ]];then
        egrep ^requirepass ${REDIS_HOME}/etc/redis-${port}.conf | awk '{print $2}' | sed 's/\"//g'
    else
        echo "$l_type directory not found."
        exit 1
    fi
}

check_proc_up() {
    local l_type=$1
    local l_port=$2
    local proc_cnt=$(ps -eo cmd | egrep ''"$REDIS_DIR"'/redis-server 0.0.0.0:'"${l_port}" | grep -v grep | wc -l)

    if [[ $proc_cnt -eq 1 ]];then
        echo "$l_type($l_port) already running."
        exit 1
    fi
}

check_proc_down() {
    local l_type=$1
    local l_port=$2
    local proc_cnt=$(ps -eo cmd | egrep ''"$REDIS_DIR"'/redis-server 0.0.0.0:'"${l_port}" | grep -v grep | wc -l)

    if [[ $proc_cnt -eq 0 ]];then
        echo "$l_type($l_port) not running."
        exit 1
    fi
}

redis_start() {
    local l_rtype=$1
    local l_port=$2

    redis_exist "${REDIS_DIR}/redis-server"

    daemon --user=${REDIS_USER} ${REDIS_DIR}/redis-server ${REDIS_HOME}/etc/redis-${l_port}.conf
    if [[ $? -eq 0 ]];then
        echo "OK"
    fi
}

redis_stop() {
    local l_rtype=$1
    local l_port=$2
    local l_pass=$3

    redis_exist "${REDIS_DIR}/redis-server"

    if [[ "$l_pass" ]];then
        echo -e "AUTH $l_pass\nSAVE\nSHUTDOWN" | sudo -u ${REDIS_USER} ${REDIS_DIR}/redis-cli -p ${l_port} | uniq
    else
        sudo -u ${REDIS_USER} ${REDIS_DIR}/redis-cli -p ${l_port} SAVE
        sudo -u ${REDIS_USER} ${REDIS_DIR}/redis-cli -p ${l_port} SHUTDOWN | egrep -v ^$
    fi
}

redis_exist() {
    local redis_server=$1
    if [ ! -f ${redis_server} ]; then
        echo "redis-server daemon does no exist."
        exit 1
    fi
}

ARGS=$(getopt -o ht:o: -l help,type:,opt: -- "$@")
eval set -- "$ARGS"

while true
do
    case "$1" in
        -t|--type)
            shift
            rtype="$1"
            ;;
        -o|--opt)
            shift
            opt="$1"
            ;;
        -h|--help)
            usage
            ;;
        --)
            shift; break
            ;;
    esac
    shift
done

if [[ -z "$rtype" ]] || [[ -z "$opt" ]];then
    usage
fi


case "$rtype" in
    redis28-6379 )
        REDIS_DIR="${REDIS_HOME}/redis28"
        port="6379"
        pass=$(check_pass)
        ;;
    redis28-6378 )
        REDIS_DIR="${REDIS_HOME}/redis28"
        port="6378"
        pass=$(check_pass)
        ;;
    redis28-6377 )
        REDIS_DIR="${REDIS_HOME}/redis28"
        port="6377"
        pass=$(check_pass)
        ;;
    redis28-6376 )
        REDIS_DIR="${REDIS_HOME}/redis28"
        port="6376"
        pass=$(check_pass)
        ;;
    redis28-6375 )
        REDIS_DIR="${REDIS_HOME}/redis28"
        port="6375"
        pass=$(check_pass)
        ;;
    redis28-6381 )
        REDIS_DIR="${REDIS_HOME}/redis28"
        port="6381"
        pass=$(check_pass)
        ;;
    redis50-6379 )
        REDIS_DIR="${REDIS_HOME}/redis50"
        port="6379"
        pass=$(check_pass)
        ;;
    redis50-6378 )
        REDIS_DIR="${REDIS_HOME}/redis50"
        port="6378"
        pass=$(check_pass)
        ;;
    redis50-6377 )
        REDIS_DIR="${REDIS_HOME}/redis50"
        port="6377"
        pass=$(check_pass)
        ;;
    redis50-6376 )
        REDIS_DIR="${REDIS_HOME}/redis50"
        port="6376"
        pass=$(check_pass)
        ;;
    redis50-6375 )
        REDIS_DIR="${REDIS_HOME}/redis50"
        port="6375"
        pass=$(check_pass)
        ;;
    redis50-6381 )
        REDIS_DIR="${REDIS_HOME}/redis50"
        port="6381"
        pass=$(check_pass)
        ;;
    *)
        usage
        ;;
esac

case "$opt" in
    start   )
        check_proc_up ${rtype} ${port}
        echo -n "$rtype($port) start : "
        redis_start ${rtype} ${port}
        ;;
    stop    )
        check_proc_down ${rtype} ${port}
        echo -n "$rtype($port) stop : "
        redis_stop ${rtype} ${port} ${pass}
        ;;
    restart )
        check_proc_down ${rtype} ${port}
        echo -n "$rtype($port) stop : "
        redis_stop ${rtype} ${port} ${pass}
        sleep 1
        echo -n "$rtype($port) start : "
        redis_start ${rtype} ${port}
        ;;
    ping    )
        check_proc_down ${rtype} ${port}
        echo -n "$rtype($port) PING : "
        if [[ $pass ]];then
            echo -e "AUTH $pass\nPING" | sudo -u ${REDIS_USER} ${REDIS_DIR}/redis-cli -p ${port} | sed ':a;N;$!ba;s/^OK\n//g'
        else
            sudo -u ${REDIS_USER} ${REDIS_DIR}/redis-cli -p ${port} PING
        fi
        ;;
    version )
        check_proc_down ${rtype} ${port}
        if [[ $pass ]];then
            echo -n "$rtype($port) : ";echo -e "AUTH $pass\nINFO" | sudo -u ${REDIS_USER} ${REDIS_DIR}/redis-cli -p ${port} | grep redis_version | cut -d: -f2-
        else
            echo -n "$rtype($port) : ";sudo -u ${REDIS_USER} ${REDIS_DIR}/redis-cli -p ${port} INFO | grep redis_version | cut -d: -f2-
        fi
        ;;
    *)
        usage
        ;;
esac

exit 0
