#!/usr/bin/env bash

BASEDIR=`dirname $0`
BASEDIR=`cd ${BASEDIR}/..;pwd`
SPARKSQL_HOME=$BASEDIR

. $SPARKSQL_HOME/bin/sparksql-env.sh

export SPARKSQL_PID_FILE=$SPARKSQL_PID_DIR/sparksql.pid
export SPARKSQL_LOG_FILE=sparksql-server.log

JAVA_OPTS="$JAVA_OPTS -Dsparksql.home=$SPARKSQL_HOME -Dsparksql.tmp.dir=$SPARKSQL_TMP_DIR -Dsparksql.bin.dir=$SPARKSQL_BIN_DIR -Dsparksql.conf.dir=$SPARKSQL_CONF_DIR -Dplugin.home=$PLUGIN_HOME -Dsparksql.log.dir=$SPARKSQL_LOG_DIR"
JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses"
JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=9199"
# 防止Tomcat生成sessionId时间过长（随机数生成器）
JAVA_OPTS="$JAVA_OPTS -Djava.security.egd=file:/dev/./urandom"
PID_MARK=$(echo -n $SPARKSQL_HOME | md5sum | cut -d ' ' -f1)
#export JAVA_OPTS="$JAVA_OPTS -Xmx4g -Xms4g -XX:+UseG1GC"

export JAVA_OPTS="$JAVA_OPTS -Xmx4g -Xms4g -XX:+UseG1GC -Dsparksql.tmp.dir=$SPARKSQL_TMP_DIR -XX:+UseG1GC -Dhdp.version=2.2.0.0-2041 -Djava.library.path=$HADOOP_HOME/lib/native/"
CP=".:$SPARKSQL_CONF_DIR:$HADOOP_HOME/conf/:$SPARK_HOME/conf:$SPARKSQL_HOME/compute_dep/*:$SPARKSQL_LIB_DIR/*:$SPARKSQL_SHARE_DIR/*:$SPARK_HOME/jars/*:$HADOOP_HOME/share/hadoop/yarn/lib/*"
cmd=$1
shift

function get_pid_from_mark() {
    PID=`ps -ef | grep "$PID_MARK" | grep -v "grep" | awk '{print $2}'`
    #PID 的长度不为0 并且 不能为空字符串 则 当前服务已经启动
    if [ -n "$PID" ] && [ "$PID" != "" ];then
        ps -f -p $PID >/dev/null 2>&1
        if [ $? == 0 ];then
            echo $PID
        else
            echo ""
        fi
    fi
}

function kill_gracefully() {
    kill -15 $1
}

function kill_force() {
    kill -9 $1
}

function status() {
    if [ -f "$SPARKSQL_PID_FILE" ]; then
      if [ -s "$SPARKSQL_PID_FILE" ]; then
        echo "Existing PID file found during start."
        if [ -r "$SPARKSQL_PID_FILE" ]; then
          PID=`cat "$SPARKSQL_PID_FILE"`
          ps -f -p $PID >/dev/null 2>&1
          if [ $? -eq 0 ] ; then
            echo "sparksql server appears to still be running with PID $PID. Start aborted."
            echo "If the following process is not a sparksql process, remove the PID file and try again:"
            ps -f -p $PID
            exit 1
          else
            echo "Removing/clearing stale PID file."
            rm -f "$SPARKSQL_PID_FILE" >/dev/null 2>&1
            if [ $? != 0 ]; then
              if [ -w "$SPARKSQL_PID_FILE" ]; then
                cat /dev/null > "$SPARKSQL_PID_FILE"
              else
                echo "Unable to remove or clear stale PID file. Start aborted."
                exit 1
              fi
            fi
          fi
        else
          echo "Unable to read PID file. Start aborted."
          exit 1
        fi
      else
        rm -f "$SPARKSQL_PID_FILE" >/dev/null 2>&1
        if [ $? != 0 ] && [ ! -w "$SPARKSQL_PID_FILE" ]; then
            echo "Unable to remove or write to empty PID file. Start aborted."
            exit 1
        fi
      fi
    else
       PID=$(get_pid_from_mark)
       #PID 的长度不为0 并且 不能为空字符串 则 当前服务已经启动
       if [ -n "$PID" ] && [ "$PID" != "" ];then
            ps -f -p $PID
            if [ $? == 0 ];then
               echo "sparksql server appears to still be running with PID $PID. Start aborted."
               exit 1
            fi
       fi
    fi
}

function print_help() {
    echo "Usage: $0 action [args..]"
    echo
    echo "The following actions are available:"
    echo "  start       start service"
    echo "  stop        stop service"
    echo "  version     print jar file version"
    echo
    echo "Action 'start' has no arguments."
    echo
    echo "Action 'stop' has two optional arguments:"
    echo "  -f          force stop"
    echo "  -g          graceful stop (default if no argument is specified)"
    echo
    echo "Action 'version' can have multiple parameters separated by whitespace which should be directory or jar file."
}

case $cmd in
    start)
        status
        nohup $JAVA -d64 -D$PID_MARK \
        ${JAVA_OPTS:-} \
        -classpath $CP com.wangchaofan.sparksql.MyApplication --spring.config.location=$SPARKSQL_CONF_DIR/application.properties $@ >> $SPARKSQL_LOG_DIR/$SPARKSQL_LOG_FILE 2>&1 &
        if [ $? == 0 ];then
            echo $! > "$SPARKSQL_PID_FILE"
            echo "sparksql server started."
        fi
    ;;
    stop)
        if [ -z "$SPARKSQL_PID_FILE" ]; then
            PID=$(cat $SPARKSQL_PID_FILE)
        else
            PID=$(get_pid_from_mark)
        fi
        # PID 的值为空字符串或者长度为0时 确定服务 已经停止
        if [ -z "$PID" ] || [ "$PID" == "" ];then
            echo "sparksql server has already stopped."
            exit 1
        else
            if [ $# -eq 0 ];then
                kill_gracefully $PID
            else
                case $1 in
                    -f)
                        kill_force $PID
                    ;;
                    -g)
                        kill_gracefully $PID
                    ;;
                    *)
                        print_help
                        exit 1
                    ;;
                esac
            fi
        fi
        if [ $? -ne 0 ] ; then
             echo "Can't stop sparksql server automatically."
             echo "Please find the correct process and stop it manually!"
        else
             rm -rf $SPARKSQL_PID_FILE
             echo "sparksql server stopped."
        fi
    ;;
    *)
        print_help
    ;;
esac
