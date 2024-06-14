-- Connect to the production_db
\c production_db;

-- Ensure replication slot exist
DO $$
BEGIN
    -- Check if the replication slot 'flink_slot' already exists
    IF NOT EXISTS (SELECT 1 FROM pg_catalog.pg_replication_slots WHERE slot_name = 'flink_slot') THEN
        -- Create replication slot 'flink_slot' for logical replication using 'pgoutput' plugin
        PERFORM pg_create_logical_replication_slot('flink_slot', 'pgoutput');
    END IF;
END;
$$ LANGUAGE plpgsql;