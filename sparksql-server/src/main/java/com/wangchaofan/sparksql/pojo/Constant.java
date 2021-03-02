package com.wangchaofan.sparksql.pojo;

/**
 * @author pbb
 */
public class Constant {

    public static final String EN = "en";
    public static final String CN = "cn";
    public static final String DATA_TYPE = "dataType";
    public static final String SPRING_CONFIG_KEYWORD = "application";
    public static final String SPARK_CONFIG_PREFIX = "spark";
    public static final String APP_NAME = "spark-server-task";
    public static final String TAG_PACKAGE_PREFIX = "com.mininglamp";
    public static final String TAG_HOME = "tag.home";
    public static final String TAG_BIN_HOME = "tag.bin.dir";
    public static final String TAG_TMP_HOME = "tag.tmp.dir";

    public static final String TEST_SQL = "select 1 from dual";
    public static final String PREVIEW_SQL = "select * from %s limit %s";
    public static final String FIELDS_SQL = "desc %s";
    public static final String MYSQL_ALL_TABLES = "show tables";

    public static final Integer PREVIEW_NUM = 20;


    public static final String STATUS_CODE = "statusCode";
    public static final String MESSAGE = "message";
    public static final String DATA = "data";
    //----------------spark default---------------

    public static final String SPARK_MASTER = "spark.master";
    public static final String SPARK_DEFAULT_MASTER = "yarn";
    public static final String SPARK_EXECUTOR_INSTANCES = "spark.executor.instances";
    public static final String SPARK_EXECUTOR_CORES = "spark.executor.cores";
    public static final String SPARK_EXECUTOR_MEMORY = "spark.executor.memory";
}
