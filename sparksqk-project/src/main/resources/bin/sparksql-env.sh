#!/usr/bin/env bash

BASEDIR=`dirname $0`
BASEDIR=`cd ${BASEDIR}/..;pwd`

export HADOOP_HOME=/home/workspace/client/tbds4.0_client/hadoop
export SPARK_HOME=/home/workspace/client/tbds4.0_client/spark
export hadoop_security_authentication_tbds_username=XXX
export hadoop_security_authentication_tbds_secureid=.......
export hadoop_security_authentication_tbds_securekey=.......

if [ -d ${BASEDIR}/logs ];then
  SPARKSQL_LOG_DIR=${BASEDIR}/logs
fi

if [ -d ${BASEDIR}/pids ];then
  SPARKSQL_PID_DIR=${BASEDIR}/pids
fi

if [ -d ${BASEDIR}/conf ];then
  SPARKSQL_CONF_DIR=${BASEDIR}/conf
fi

if [ -d ${BASEDIR}/lib ];then
  SPARKSQL_LIB_DIR=${BASEDIR}/lib
fi

if [ -d ${BASEDIR}/share ];then
  SPARKSQL_SHARE_DIR=${BASEDIR}/share
fi

if [ -d ${BASEDIR}/bin ];then
  SPARKSQL_BIN_DIR=${BASEDIR}/bin
fi

if [ -d ${BASEDIR}/tmp ];then
  SPARKSQL_TMP_DIR=${BASEDIR}/tmp
fi

export SPARKSQL_CONF_DIR=${SPARKSQL_CONF_DIR:-/usr/lib/SPARKSQL/conf}
export SPARKSQL_BIN_DIR=${SPARKSQL_BIN_DIR:-/usr/lib/SPARKSQL/bin}
export SPARKSQL_TMP_DIR=${SPARKSQL_TMP_DIR:-/usr/lib/SPARKSQL/tmp}
export SPARKSQL_LIB_DIR=${SPARKSQL_LIB_DIR:-/usr/lib/SPARKSQL/lib}
export SPARKSQL_SHARE_DIR=${SPARKSQL_SHARE_DIR:-/usr/lib/SPARKSQL/share}
export SPARKSQL_LOG_DIR=${SPARKSQL_LOG_DIR:-/var/log/SPARKSQL}
export SPARKSQL_PID_DIR=${SPARKSQL_PID_DIR:-/var/run/SPARKSQL}

if [ -z $JAVA_HOME ]; then
    JAVA=$(which java)
else
    JAVA="$JAVA_HOME/bin/java"
fi

export JAVA
echo "[INFO] Using java in $JAVA"
