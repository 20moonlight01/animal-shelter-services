#!/bin/bash
set -e

MIGRATION_FILE=$1
MIGRATION_NAME=$(basename "$MIGRATION_FILE" .sql)

echo "DOWN: Rolling back last applied migration"

TABLE_EXISTS=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $TEST_DB_NAME -t -c \
    "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'databasechangelog');" \
    2>&1 | xargs)

if [ "$TABLE_EXISTS" != "t" ]; then
    echo "DATABASECHANGELOG table does not exist, nothing to rollback"
    exit 0
fi

RECORD_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $TEST_DB_NAME -t -c \
    "SELECT COUNT(*) FROM DATABASECHANGELOG WHERE EXECTYPE = 'EXECUTED';" \
    2>&1 | xargs)

echo "Records in DATABASECHANGELOG: $RECORD_COUNT"

if [ "$RECORD_COUNT" -eq 0 ]; then
    echo "No migrations to rollback"
    exit 0
fi

LAST_MIGRATION=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $TEST_DB_NAME -t -c \
    "SELECT FILENAME FROM DATABASECHANGELOG WHERE EXECTYPE = 'EXECUTED' ORDER BY ORDEREXECUTED DESC LIMIT 1;" \
    2>&1 | xargs)

echo "Last applied migration: $LAST_MIGRATION"

if [ -z "$LAST_MIGRATION" ] || [ "$LAST_MIGRATION" = " " ]; then
    echo "No migrations to rollback"
    exit 0
fi

liquibase \
    --url="jdbc:postgresql://$DB_HOST:$DB_PORT/$TEST_DB_NAME" \
    --username="$DB_USER" \
    --password="$DB_PASSWORD" \
    --changeLogFile="changelog.xml" \
    rollbackCount 1 2>&1

echo "Last migration rolled back"