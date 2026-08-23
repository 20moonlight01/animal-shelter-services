#!/bin/sh
set -e

CONNECT_HOST=${CONNECT_HOST:-kafka-connect}
CONNECT_PORT=${CONNECT_PORT:-8083}
URL="http://${CONNECT_HOST}:${CONNECT_PORT}/connectors/postgres-connector/config"

echo "Waiting for Kafka Connect to be ready..."
until curl -s -o /dev/null -w "%{http_code}" "http://${CONNECT_HOST}:${CONNECT_PORT}/connectors" | grep -q "200"; do
  sleep 3
done

echo "Registering/Updating postgres-connector via PUT..."

curl -i -X PUT \
  -H "Accept:application/json" \
  -H "Content-Type:application/json" \
  -d '{
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "plugin.name": "pgoutput",
    "database.hostname": "'"${DB_HOST}"'",
    "database.port": "'"${DB_PORT}"'",
    "database.user": "'"${DEBEZIUM_USER}"'",
    "database.password": "'"${DEBEZIUM_PASSWORD}"'",
    "database.dbname": "'"${POSTGRES_DB}"'",
    "topic.prefix": "'"${DEBEZIUM_TOPIC_PREFIX}"'",
    "table.include.list": "public.donations",
    "slot.name": "'"${DEBEZIUM_SLOT_NAME}"'",
    "publication.name": "'"${DEBEZIUM_PUBLICATION_NAME}"'",
    "snapshot.mode": "initial",
    "decimal.handling.mode": "double",
    "database.connection.timezone": "UTC",
    "slot.drop.on.stop": "true"
  }' \
  "$URL"

echo -e "\nConnector task processed!"