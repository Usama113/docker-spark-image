


FROM picoded/ubuntu-base

LABEL authors="usama.javaid@outlook.com"




RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get install -y ant && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;





RUN \
  apt-get update && \
  apt-get install -y supervisor && \
  rm -rf /var/lib/apt/lists/* && \
  sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf


ENV SPARK_VERSION 2.4.4
ENV HADOOP_VERSION 2.7

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*




# download and extract Spark 
RUN wget https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz \
&&  tar -xzf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz \
&&  mv spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION /opt/spark

# Set spark home 
ENV SPARK_HOME /opt/spark
ENV PATH $SPARK_HOME/bin:$PATH

# adding conf files to all images. This will be used in supervisord for running spark master/slave
COPY master.conf /opt/conf/master.conf
COPY slave.conf /opt/conf/slave.conf
COPY history-server.conf /opt/conf/history-server.conf

# Adding configurations for history server
COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf
RUN  mkdir -p /opt/spark-events

# expose port 8080 for spark UI
EXPOSE 4040 6066 7077 8080 18080 8081

#default command: this is just an option 
CMD ["/opt/spark/bin/spark-shell", "--master", "local[*]"]
