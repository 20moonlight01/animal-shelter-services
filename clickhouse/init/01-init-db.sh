#!/bin/sh
set -e

clickhouse-client -n <<EOSQL
CREATE TABLE IF NOT EXISTS donations_analytics (
    id UInt32,
    date DateTime,
    amount Decimal(10, 2),
    donor_id UInt32,
    payment_type_id UInt32,
    purpose String,
    op String,
    ts_ms UInt64
) ENGINE = ReplacingMergeTree()
PRIMARY KEY id
ORDER BY id;

CREATE TABLE IF NOT EXISTS donations_kafka_stream (
    raw_json String
) ENGINE = Kafka
SETTINGS kafka_broker_list = 'kafka:9092',
         kafka_topic_list = 'animal_shelter_cdc.public.donations',
         kafka_group_name = 'unique_animal_shelter_clickhouse_consumer_group',
         kafka_format = 'JSONAsString';

CREATE MATERIALIZED VIEW IF NOT EXISTS donations_mv TO donations_analytics AS
SELECT
    if(
        JSONExtractString(raw_json, 'payload', 'op') = 'd',
        JSONExtractUInt(raw_json, 'payload', 'before', 'id'),
        JSONExtractUInt(raw_json, 'payload', 'after', 'id')
    ) AS id,
    
    if(
        JSONExtractString(raw_json, 'payload', 'op') = 'd',
        toDateTime(JSONExtractInt(raw_json, 'payload', 'before', 'date') / 1000000),
        toDateTime(JSONExtractInt(raw_json, 'payload', 'after', 'date') / 1000000)
    ) AS date,
    
    if(
        JSONExtractString(raw_json, 'payload', 'op') = 'd',
        JSONExtract(raw_json, 'payload', 'before', 'amount', 'Decimal(10, 2)'),
        JSONExtract(raw_json, 'payload', 'after', 'amount', 'Decimal(10, 2)')
    ) AS amount,
    
    if(
        JSONExtractString(raw_json, 'payload', 'op') = 'd',
        JSONExtractUInt(raw_json, 'payload', 'before', 'donor_id'),
        JSONExtractUInt(raw_json, 'payload', 'after', 'donor_id')
    ) AS donor_id,
    
    if(
        JSONExtractString(raw_json, 'payload', 'op') = 'd',
        JSONExtractUInt(raw_json, 'payload', 'before', 'payment_type_id'),
        JSONExtractUInt(raw_json, 'payload', 'after', 'payment_type_id')
    ) AS payment_type_id,
    
    if(
        JSONExtractString(raw_json, 'payload', 'op') = 'd',
        JSONExtractString(raw_json, 'payload', 'before', 'purpose'),
        JSONExtractString(raw_json, 'payload', 'after', 'purpose')
    ) AS purpose,

    JSONExtractString(raw_json, 'payload', 'op') AS op,
    JSONExtractUInt(raw_json, 'payload', 'ts_ms') AS ts_ms
FROM donations_kafka_stream;
EOSQL