#!/bin/bash

. /etc/rc.d/init.d/functions

readonly REDIS_USER="redis"
readonly REDIS_DIR="/home/apps"

usage() {
    echo "
Usage: ${0##*/} [options]

Options:

    -t|--type
    -o|--opt
    -h|--help

Examples:
    ${0##*/} -t redis -o {start|stop|restart|ping|version}

Description:
    type: redis , prefix: $REDIS_DIR/redis , port: 6379
    type: redis2, prefix: $REDIS_DIR/redis2, port: 6378
    type: redis3, prefix: $REDIS_DIR/redis3, port: 6377
"
exit 1
}

check_pass() {
    local l_type=$1
    if [[ -d "$REDIS_DIR/$l_type" ]];then
        egrep ^requirepass ${REDIS_DIR}/${rtype}/etc/redis.conf | awk '{print $2}' | sed 's/\"//g'
    else
        echo "$l_type directory not found."
        exit 1
    fi
}

check_proc_up() {
    local l_type=$1
    local l_port=$2
    local proc_cnt=$(ps -eo cmd | egrep ''"$REDIS_DIR"'/'"$l_type"'/sbin/redis-server' | grep -v grep | wc -l)

    if [[ $proc_cnt -eq 1 ]];then
        echo "$l_type($l_port) already running."
        exit 1
    fi
}

check_proc_down() {
    local l_type=$1
    local l_port=$2
    local proc_cnt=$(ps -eo cmd | egrep ''"$REDIS_DIR"'/'"$l_type"'/sbin/redis-server' | grep -v grep | wc -l)

    if [[ $proc_cnt -eq 0 ]];then
        echo "$l_type($l_port) not running."
        exit 1
    fi
}

redis_start() {
    local l_rtype=$1
    daemon --user=${REDIS_USER} ${REDIS_DIR}/${l_rtype}/sbin/redis-server ${REDIS_DIR}/${l_rtype}/etc/redis.conf
    if [[ $? -eq 0 ]];then
        echo "OK"
    fi
}

redis_stop() {
    local l_rtype=$1
    local l_port=$2
    local l_pass=$3
    if [[ "$l_pass" ]];then
        echo -e "AUTH $l_pass\nSAVE\nSHUTDOWN" | sudo -u ${REDIS_USER} ${REDIS_DIR}/${l_rtype}/bin/redis-cli -p ${l_port} | uniq
    else
        sudo -u ${REDIS_USER} ${REDIS_DIR}/${l_rtype}/bin/redis-cli -p ${l_port} SAVE
        sudo -u ${REDIS_USER} ${REDIS_DIR}/${l_rtype}/bin/redis-cli -p ${l_port} SHUTDOWN | egrep -v ^$
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
    redis  )
        port="6379"
        pass=$(check_pass)
        ;;
    redis2 )
        port="6378"
        pass=$(check_pass)
        ;;
    redis3 )
        port="6377"
        pass=$(check_pass)
        ;;
esac

case "$opt" in
    start   )
        check_proc_up ${rtype} ${port}
        echo -n "$rtype($port) start : "
        redis_start ${rtype}
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
        redis_start ${rtype}
        ;;

    ping    )
        check_proc_down ${rtype} ${port}
        echo -n "$rtype($port) PING : "
        if [[ $pass ]];then
            echo -e "AUTH $pass\nPING" | sudo -u ${REDIS_USER} ${REDIS_DIR}/${rtype}/bin/redis-cli -p ${port} | sed ':a;N;$!ba;s/^OK\n//g'
        else
            sudo -u ${REDIS_USER} ${REDIS_DIR}/${rtype}/bin/redis-cli -p ${port} PING
        fi
        ;;

    version )
        check_proc_down ${rtype} ${port}
        if [[ $pass ]];then
            echo -n "$rtype($port) : ";echo -e "AUTH $pass\nINFO" | sudo -u ${REDIS_USER} ${REDIS_DIR}/${rtype}/bin/redis-cli -p ${port} | grep redis_version | cut -d: -f2-
        else
            echo -n "$rtype($port) : ";sudo -u ${REDIS_USER} ${REDIS_DIR}/${rtype}/bin/redis-cli -p ${port} INFO | grep redis_version | cut -d: -f2-
        fi
        ;;
esac

exit 0
