FROM java:8-alpine
MAINTAINER Ed Sweeney <ed@onextent.com>

EXPOSE 4040
ENV hadoop_ver 2.7.4
ENV hadoop_ver_short 2.7
ENV spark_ver 2.2.0

RUN apk add --update curl bash && \
    rm -rf /var/cache/apk/*

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
    curl http://www.us.apache.org/dist/spark/spark-${spark_ver}/spark-${spark_ver}-bin-hadoop${hadoop_ver_short}.tgz | \
        tar -zx && \
    ln -s spark-${spark_ver}-bin-hadoop${hadoop_ver_short} spark && \
    echo Spark ${spark_ver} installed in /opt

ADD files/log4j.properties /opt/spark/conf/log4j.properties
ADD files/start-common.sh files/start-worker files/start-master /
ADD files/core-site.xml /opt/spark/conf/core-site.xml
ADD files/spark-defaults.conf /opt/spark/conf/spark-defaults.conf
ADD files/metrics.properties /opt/spark/conf/metrics.properties

ENV PATH $PATH:/opt/spark/bin
