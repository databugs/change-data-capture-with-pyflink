#!/bin/bash
mkdir lib && cd lib
curl -o flink-connector-jdbc-3.1.2-1.18.jar https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.2-1.18/flink-connector-jdbc-3.1.2-1.18.jar
curl -o postgresql-42.7.3.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.3/postgresql-42.7.3.jar
curl -o flink-sql-connector-postgres-cdc-3.1.0.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-postgres-cdc/3.1.0/flink-sql-connector-postgres-cdc-3.1.0.jar
