-- init-analytics.sql
-- Start a transaction block
BEGIN;
-- Switch to the newly created database
\c analytics_db;

-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS flink;

-- Create table if not exists
CREATE TABLE IF NOT EXISTS flink.drivers (
    id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender VARCHAR(50),
    date_of_birth DATE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

COMMIT;