FROM apache/spark:3.4.0-scala2.12-java11-python3-r-ubuntu
WORKDIR /opt/spark/work-dir
RUN wget https://repo1.maven.org/maven2/org/apache/spark/spark-hadoop-cloud_2.13/3.4.0/spark-hadoop-cloud_2.13-3.4.0.jar
RUN mv spark-hadoop-cloud_2.13-3.4.0.jar /opt/spark/jars/
ADD run_workers.sh /opt/spark/work-dir/