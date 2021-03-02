package com.wangchaofan.sparksql.service;

import com.wangchaofan.sparksql.manager.SparkManager;
import com.wangchaofan.sparksql.pojo.SparkTask;
import org.apache.spark.sql.SparkSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;
import java.util.Properties;

/**
 * sql:select store.s_store_name ,avg(ss_sales_price)  from store_sales join store where store.s_store_sk = store_sales.ss_store_sk group by store.s_store_name;
 *     select * from store left join store_sales on store.s_store_sk=store_sales.ss_store_sk
 *
 *
 *
 * @author wangchaofan
 * @create 2020/8/11
 */
@RestController
public class SparkService {

    private static final Logger Log = LoggerFactory.getLogger(SparkService.class);

    @GetMapping("/test")
    public String getTest(){
        Properties properties = new Properties();
        InputStream resourceAsStream = SparkService.class.getClassLoader().getResourceAsStream("conf/spark-conf.properties");
        try {
            properties.load(resourceAsStream);
        } catch (IOException e) {
            Log.error("加载配置文件失败！", e);
            System.exit(1);
        }

        return properties.toString();
    }



    @PostMapping("/sparksql")
    public void getTask(@RequestBody Map<String,String> map) throws Exception {
        Log.info("开始构建");
        long current = System.currentTimeMillis();
        SparkSession session = SparkTask.getSession();
        System.out.println("构建session连接花费时间："+(System.currentTimeMillis() - current) / 1000 + "s");
        String database = map.get("database");
        String sql = map.get("sql");
        System.out.println("开始执行sql");
        session.sql(database);
        session.sql(sql);
        System.out.println("执行sql花费时间："+(System.currentTimeMillis() - current) / 1000 + "s");
    }

    @PostMapping("/sparksql2")
    public String getTask2(@RequestBody Map<String,String> map) throws Exception {
        Log.info("============>start build<=================");
        long current = System.currentTimeMillis();
        SparkSession sparkSession = SparkManager.getSession2();
        double buildTime = (double) (System.currentTimeMillis() - current)/1000;
        Log.info("=========================build session time :"+buildTime+ "s");
        String database = map.get("database");
        String sql = map.get("sql");
        sparkSession.sql(database);
        sparkSession.sql(sql);
        double l1 = (double)(System.currentTimeMillis() - current) / 1000;
        Log.info("===============>excuter sql time :"+ (l1-buildTime)+ "s");

        return sparkSession.sparkContext().applicationId();
    }

    @GetMapping("/aop")
    public void testAOP(){


    }

}