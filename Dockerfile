FROM java:openjdk-8-jdk
MAINTAINER Ed Sweeney <ed@onextent.com>

EXPOSE 4040
ENV hadoop_ver 2.6.1
ENV spark_ver 2.0.2

# Get Hadoop from US Apache mirror and extract just the native
# libs. (Until we care about running HDFS with these containers, this
# is all we need.)
RUN mkdir -p /opt && \
    cd /opt && \
    curl http://www.us.apache.org/dist/hadoop/common/hadoop-${hadoop_ver}/hadoop-${hadoop_ver}.tar.gz | \
        tar -zx hadoop-${hadoop_ver}/lib/native && \
    ln -s hadoop-${hadoop_ver} hadoop && \
    echo Hadoop ${hadoop_ver} native libraries installed in /opt/hadoop/lib/native

# Get Spark from US Apache mirror.
RUN mkdir -p /opt && \
    cd /opt && \
    curl http://www.us.apache.org/dist/spark/spark-${spark_ver}/spark-${spark_ver}-bin-hadoop2.6.tgz | \
        tar -zx && \
    ln -s spark-${spark_ver}-bin-hadoop2.6 spark && \
    echo Spark ${spark_ver} installed in /opt

# if numpy is installed on a driver it needs to be installed on all
# workers, so install it everywhere
RUN apt-get update && \
    apt-get install -y python-numpy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD files/log4j.properties /opt/spark/conf/log4j.properties
ADD files/start-common.sh files/start-worker files/start-master /
ADD files/core-site.xml /opt/spark/conf/core-site.xml
ADD files/spark-defaults.conf /opt/spark/conf/spark-defaults.conf
ADD files/metrics.properties /opt/spark/conf/metrics.properties
ENV PATH $PATH:/opt/spark/bin

