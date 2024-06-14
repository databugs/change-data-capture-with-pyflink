-- init-production.sql
-- Start a transaction block
BEGIN;
-- Switch to the newly created database
\c production_db;

-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS flink;

-- Create table if not exists
CREATE TABLE IF NOT EXISTS flink.drivers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(50),
    date_of_birth DATE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create or replace function to update timestamps
CREATE OR REPLACE FUNCTION update_driver_timestamps()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        NEW.created_at := NOW(); -- Set created_at for new records
    END IF;

    NEW.updated_at := NOW(); -- Always update updated_at

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function before insert or update
CREATE TRIGGER update_drivers_timestamps
BEFORE INSERT OR UPDATE ON flink.drivers
FOR EACH ROW EXECUTE FUNCTION update_driver_timestamps();

-- Ensure publication exists
DO $$
BEGIN
    -- Check if the publication 'flink_pub' already exists
    IF NOT EXISTS (SELECT 1 FROM pg_catalog.pg_publication WHERE pubname = 'flink_pub') THEN
        -- Create publication 'flink_pub' for the specified tables
        CREATE PUBLICATION flink_pub FOR TABLE flink.drivers;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Insert 5 rows into the 'drivers' table
INSERT INTO flink.drivers (first_name, last_name, gender, date_of_birth)
VALUES
    ('John', 'Doe', 'Male', '1990-01-01'),
    ('Jane', 'Smith', 'Female', '1995-02-02'),
    ('Michael', 'Johnson', 'Male', '1992-03-03'),
    ('Emily', 'Brown', 'Female', '1997-04-04'),
    ('David', 'Garcia', 'Male', '1994-05-05');

-- Commit the transaction
COMMIT;