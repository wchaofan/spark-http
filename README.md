# 介绍
  简单使用springboot写的一个关于spark任务提交的web服务，当前适配的集群是tbds
# 使用
  1. 在sparksql-server.sh 脚本中配置集群密钥
export hadoop_security_authentication_tbds_username=XXX
export hadoop_security_authentication_tbds_secureid=XXXX
export hadoop_security_authentication_tbds_securekey=XXXXX
  2. mvn clean package -Passembly 打包，将tar.gz 包上传服务器 解压
  3. ./bin/sparksql-server.sh start 启动服务
