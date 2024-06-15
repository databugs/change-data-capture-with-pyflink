# Change Data Capture With Pyflink
This repository contains a comprehensive implementation of Change Data Capture (CDC) using Apache Flink with Python (PyFlink)

## What is Change Data Capture?
The main goal of CDC is to provide a mechanism to track and record changes made to data in a database, such as inserts, updates, and deletes, in real-time or near real-time.

This allows for use cases like data replication, ensuring that the target database remains in sync with the source database.

## Change Data Capture with Pyflink 
PyFlink is an Apache Flink Python API that provides a way to implement CDC using Flink's streaming data processing capabilities and high fualt tolerance.

## Setup
1. **Clone the repository**
    ```
    git clone https://github.com/databugs/change-data-capture-with-pyflink.git
    ```
2. **Navigate to the project folder**
    ```
    cd change-data-capture-with-pyflink
    ```
3. **Create a secrets file**
    This file will hold all the environmental variables needed for the setup to be successful.

    All the vairables can be found in this `./config/app.txt`, but we need it in a `.env` file in the root directory.

    ```
    cp ./config/app.txt .env
    ```
    If the above command doesn't work for you, you can copy the contents of the file and manually create the `.env` file and paste the contents inside it.

    >Do not modify the database names. They are manually referenced in the init scripts.

4. **Start the services**
    ```
    docker-compose up -d
    ```
    Wait for all services to start running.

5. **View all running containers**
    ```
    docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'
    ```
    You will see the names of all the three services you have started:
    - production_db: the db you monitor for activities like `insert`, `update`, and `delete`.
    - analytics_db: the db were those activities will be replicated.
    - minio: for flink checkpointing

6. **Prepare a Python virtual environment**
    ```bash
    python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt
    ```
    The above script will create a python virtual environment, activate it, and install all the libraries in `requirements.txt`

7. **Run the python script: flink_cdc.py**
    ```
    python ./pyflink-jobs/flink_cdc.py
    ```
    This will start the flink job. Do not kill the terminal. Flink will continue to run to monitor and stream all changes in the `production_db` to the `analytics_db` in real time.

## CDC in Practice
In the `/test-scripts/` folder, there is a file named `cdc_test.sql`. There are a number of queries there with comments on what they do.

You are expected to run all those queries one after the other againt the `production_db`.

After each run, query the analytics db to confirm that those changes are also replicated there.