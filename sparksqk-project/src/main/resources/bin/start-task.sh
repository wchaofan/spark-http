#!/usr/bin/env bash

BASEDIR=`dirname $0`
BASEDIR=`cd ${BASEDIR}/..;pwd`
TAG_HOME=$BASEDIR

. $TAG_HOME/bin/sparksql-env.sh

export JAVA_OPTS="$JAVA_OPTS -Xmx1g -Xms1g -Dtag.tmp.dir=$TAG_TMP_DIR -XX:+UseG1GC -Dhdp.version=2.2.0.0-2041 -Djava.library.path=$HADOOP_HOME/lib/native/"
CP=".:$TAG_CONF_DIR/:$HADOOP_HOME/conf/:$SPARK_HOME/conf/:$TAG_SHARE_DIR/*:$SPARK_HOME/jars/*:$HADOOP_HOME/share/hadoop/yarn/lib/*"

$JAVA -d64 ${JAVA_OPTS:-} -classpath $CP com.wangchaofan.sparksql.service.SparkExecuter $@