package com.wangchaofan.sparksql.manager;

import com.google.common.base.Preconditions;
import com.wangchaofan.sparksql.pojo.Constant;
import org.apache.spark.sql.SparkSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.Properties;

/**
 * @author wangchaofan
 * @create 2020/8/13
 */
public class SparkManager {
    private static final Logger log = LoggerFactory.getLogger(SparkManager.class);
    private static volatile SparkSession session;

    public static SparkSession getSession() {
        /* 指定hive的metastore的端口  默认为9083 在hive-site.xml中查看 .config("hive.metastore.uris", "thrift://192.168.40.51:9083")
           指定hive的warehouse目录   .config("spark.sql.warehouse.dir", "hdfs://192.168.40.51:9000/user/hive/warehouse")

            conf配置文件有这些配置
         */
        Properties properties = new Properties();
        InputStream resourceAsStream = SparkManager.class.getClassLoader().getResourceAsStream("spark-conf.properties");
        Preconditions.checkNotNull(resourceAsStream, "spark-conf.properties 配置文件不存在！");
        try {
            properties.load(resourceAsStream);
        } catch (IOException e) {
            log.error("加载配置文件失败！", e);
            System.exit(1);
        }

        SparkSession.Builder builder = SparkSession
                .builder()
                .enableHiveSupport()
                .appName(Constant.APP_NAME);

        Enumeration<?> e = properties.propertyNames();
        while (e.hasMoreElements()) {
            String key = e.nextElement().toString();
            String value = properties.getProperty(key);
            log.info(key + ": " + value);
            builder.config(key, value);
        }
        return builder.getOrCreate();
    }


    public static SparkSession getSession2() throws Exception {
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
            log.warn("sparksession失效", e);
            synchronized (session) {
                session.close();
                session = null;
                initSparkSession();
            }
        }

        return session;
    }
    private static void initSparkSession(){
        session = getSession();
    }
}