FROM flink:1.18.1

# JDK is required to install pyflink
RUN apt-get update -y && apt-get install -y openjdk-11-jdk
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64

# Flink 1.18.1 requires Python 3.8
# Install commands taken from here
# https://nightlies.apache.org/flink/flink-docs-release-1.15/docs/deployment/resource-providers/standalone/docker/#using-flink-python-on-docker
RUN apt-get update -y && \
apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev libffi-dev liblzma-dev jq

RUN wget https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz && \
tar -xvf Python-3.8.3.tgz && \
cd Python-3.8.3 && \
./configure --without-tests --enable-shared && \
make -j6 && \
make install && \
ldconfig /usr/local/lib && \
cd .. && rm -f Python-3.8.3.tgz && rm -rf Python-3.8.3 && \
ln -s /usr/local/bin/python3 /usr/local/bin/python && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

# Install PyFlink
RUN python -m pip install --upgrade pip
RUN python -m pip install apache-flink==1.18.1

USER flink
RUN mkdir -p /opt/flink/usrlib /opt/flink/config
RUN wget -P /opt/flink/lib https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.2-1.18/flink-connector-jdbc-3.1.2-1.18.jar; \
    wget -P /opt/flink/lib https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.3/postgresql-42.7.3.jar; \
    wget -P /opt/flink/lib https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-postgres-cdc/3.1.0/flink-sql-connector-postgres-cdc-3.1.0.jar;