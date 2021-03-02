package com.wangchaofan.sparksql.pojo;

import org.apache.spark.SparkConf;
import org.apache.spark.SparkContext;
import org.apache.spark.sql.SparkSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;

/**
 * @author wangchaofan
 * @create 2020/8/11
 */
public class SparkTask {

    private static final Logger logger = LoggerFactory.getLogger(SparkTask.class);
    private static volatile SparkSession session;
    private SparkTask(){}
    private static void initSparkSession(){
        logger.info("===========>构建session<==============");
        SparkConf sparkConf = new SparkConf();
        sparkConf.set("spark.default.parallelism", "4");
        sparkConf.set("spark.executor.cores", "1");
        sparkConf.set("spark.executor.memory", "4");
        sparkConf.set("spark.yarn.jars", "hdfs://bj-mlamp-11:8020/tmp/wcf/jars/*.jar");

        //sparkConf.set("spark.default.parallelism", "4");

        session = SparkSession.builder().config(sparkConf).appName("scopa").master("yarn").enableHiveSupport().getOrCreate();

        File dir = new File("/home/workspace/client/cdh6.3.2_physical_client/scopa/conf");
        SparkContext sparkContext = session.sparkContext();
        for (File f : dir.listFiles()) {
            sparkContext.addFile("file://" + f.getAbsolutePath());
        }
    }

    public static SparkSession getSession() throws Exception {
            if(session == null){
                synchronized (SparkSession.class){
                    if (session == null){
                        initSparkSession();
                    }
                }
            }
        try {
            session.sparkContext().assertNotStopped();
        } catch (IllegalStateException e) {
            logger.warn("sparksession失效", e);
            synchronized (session) {
                session.close();
                session = null;
                initSparkSession();
            }
        }

        return session;
    }


}