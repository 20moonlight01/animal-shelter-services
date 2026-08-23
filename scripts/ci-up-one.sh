#!/bin/bash
set -e

MIGRATION_FILE=$1
MIGRATION_NAME=$(basename "$MIGRATION_FILE" .sql)

echo "UP: Applying migrations up to: $MIGRATION_NAME"

MIGRATION_NUM=$(echo "$MIGRATION_NAME" | cut -d'_' -f2 | sed 's/^0*//')
echo "Migration number: $MIGRATION_NUM"

TEMP_FILE="./changelog_up_to.xml"

cat > "$TEMP_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                      http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.0.xsd">
EOF

for file in $(ls -1 /migrations/*.sql 2>/dev/null | sort -V); do
    filename=$(basename "$file")
    file_num=$(echo "$filename" | cut -d'_' -f2 | sed 's/^0*//')
    if [ "$file_num" -le "$MIGRATION_NUM" ]; then
        echo "    <include file=\"$filename\" relativeToChangelogFile=\"true\"/>" >> "$TEMP_FILE"
    fi
done

echo "</databaseChangeLog>" >> "$TEMP_FILE"

echo "Created temp changelog: $TEMP_FILE"

liquibase \
    --url="jdbc:postgresql://$DB_HOST:$DB_PORT/$TEST_DB_NAME" \
    --username="$DB_USER" \
    --password="$DB_PASSWORD" \
    --changeLogFile="$TEMP_FILE" \
    update 2>&1

rm -f "$TEMP_FILE"

echo "Migrations up to $MIGRATION_NAME applied"