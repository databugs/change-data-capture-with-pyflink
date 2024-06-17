# python==3.10.2
# flink_cdc.py
import os
import sys
import logging
from dotenv import load_dotenv
from pyflink.table import EnvironmentSettings, TableEnvironment, TableConfig

class FlinkCDC:
    def __init__(self):
        # Load environment variables
        load_dotenv('../.env')

        # Constants for configuration
        self.CHECKPOINT_INTERVAL = "5000"
        self.PARALLELISM_DEFAULT = "4"
        self.CHECKPOINT_MODE = "EXACTLY_ONCE"
        self.CHECKPOINTS_DIRECTORY = os.environ.get("CHECKPOINTS_DIRECTORY")
        self.SAVEPOINTS_DIRECTORY = os.environ.get("SAVEPOINTS_DIRECTORY")
        self.S3_ACCESS_KEY = os.environ.get("S3_ACCESS_KEY")
        self.S3_SECRET_KEY = os.environ.get("S3_SECRET_KEY")
        self.S3_ENDPOINT = os.environ.get("S3_ENDPOINT")
        self.CURRENT_DIR = os.getcwd()

        # Logging setup
        logging.basicConfig(stream=sys.stdout, level=logging.INFO, format="%(message)s")

        # Initialize Flink environment
        env_settings = EnvironmentSettings.in_streaming_mode()
        self.table_env = TableEnvironment.create(env_settings)

        # Table configuration
        config = TableConfig()
        config.set("execution.checkpointing.interval", self.CHECKPOINT_INTERVAL)
        config.set("parallelism.default", self.PARALLELISM_DEFAULT)
        config.set("s3.endpoint", self.S3_ENDPOINT)
        config.set("s3.path-style", "true")
        config.set("s3.access-key", self.S3_ACCESS_KEY)
        config.set("s3.secret-key", self.S3_SECRET_KEY)
        config.set("state.savepoints.dir", self.SAVEPOINTS_DIRECTORY)
        config.set("execution.checkpointing.mode", self.CHECKPOINT_MODE)
        config.set("execution.checkpointing.dir", self.CHECKPOINTS_DIRECTORY)
        config.set("pipeline.jars", f"""
            file:///{self.CURRENT_DIR}/lib/flink-sql-connector-postgres-cdc-3.1.0.jar;
            file:///{self.CURRENT_DIR}/lib/flink-connector-jdbc-3.1.2-1.18.jar;
            file:///{self.CURRENT_DIR}/lib/postgresql-42.7.3.jar
        """)

        # Apply table configuration
        self.table_env.get_config().add_configuration(config.get_configuration())

    def execute_src_stm(self):
        src_stm = f"""
        CREATE TABLE IF NOT EXISTS drivers_cdc_source (
            id INT NOT NULL,
            first_name VARCHAR(50),
            last_name VARCHAR(50),
            gender VARCHAR(50),
            date_of_birth DATE,
            created_at TIMESTAMP,
            updated_at TIMESTAMP,
            PRIMARY KEY (id) NOT ENFORCED
        ) WITH (
            'connector' = 'postgres-cdc',
            'hostname' = '{os.environ.get("HOST_MACHINE")}',
            'port' = '{os.environ.get("PROD_EXTERNAL_PORT")}',
            'username' = '{os.environ.get("PROD_USERNAME")}',
            'password' = '{os.environ.get("PROD_PASSWORD")}',
            'database-name' = '{os.environ.get("PROD_DATABASE")}',
            'schema-name' = 'flink',
            'table-name' = 'drivers',
            'slot.name' = 'flink_slot',
            'decoding.plugin.name' = 'pgoutput',
            'scan.incremental.snapshot.enabled' = 'true',
            'changelog-mode' = 'upsert'
        );
        """
        self.table_env.execute_sql(src_stm)

    def execute_jdbc_sink(self):
        jdbc_sink = f"""
        CREATE TABLE IF NOT EXISTS drivers_cdc_sink (
            id INT NOT NULL,
            first_name VARCHAR(50),
            last_name VARCHAR(50),
            gender VARCHAR(50),
            date_of_birth DATE,
            created_at TIMESTAMP,
            updated_at TIMESTAMP,
            PRIMARY KEY (id) NOT ENFORCED
        )
        WITH (
            'connector' = 'jdbc',
            'url' = '{os.environ.get("ANALYTICS_URL")}',
            'table-name' = 'flink.drivers',
            'driver' = 'org.postgresql.Driver',
            'username' = '{os.environ.get("ANALYTICS_USERNAME")}',
            'password' = '{os.environ.get("ANALYTICS_PASSWORD")}',
            'sink.buffer-flush.max-rows' = '1000',
            'sink.buffer-flush.interval' = '2s'
        );
        """
        self.table_env.execute_sql(jdbc_sink)

    def insert_data(self):
        insert_query = """
        INSERT INTO drivers_cdc_sink SELECT * FROM drivers_cdc_source;
        """
        self.table_env.execute_sql(insert_query).wait()

if __name__ == "__main__":
    flink_cdc = FlinkCDC()
    flink_cdc.execute_src_stm()
    flink_cdc.execute_jdbc_sink()
    flink_cdc.insert_data()