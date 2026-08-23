#!/bin/bash
set -e

echo "Seeding container started"

if [ "$APP_ENV" = "prod" ]; then
    echo "APP_ENV=prod, skipping seeding"
    exit 0
fi

echo "Setting up seed_config with SEED_COUNT = ${SEED_COUNT:-10}"

PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << EOF
CREATE TABLE IF NOT EXISTS seed_config (
    key TEXT PRIMARY KEY,
    value TEXT
);

INSERT INTO seed_config (key, value) 
VALUES ('seed_count', '${SEED_COUNT:-10}')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
EOF

echo "seed_config table ready"

echo "Fetching last migration file from DATABASECHANGELOG..."
LAST_MIGRATION_FILE=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c \
    "SELECT FILENAME FROM DATABASECHANGELOG WHERE EXECTYPE = 'EXECUTED' ORDER BY ORDEREXECUTED DESC LIMIT 1;" \
    2>/dev/null | xargs)

echo "Last migration file: '$LAST_MIGRATION_FILE'"

if [ -n "$LAST_MIGRATION_FILE" ]; then
    SCHEMA_TAG=$(echo "$LAST_MIGRATION_FILE" | grep -o '^v[0-9]\+' || true)
else
    SCHEMA_TAG=""
fi

echo "Schema tag: '${SCHEMA_TAG:-none}'"

echo "Running seed scripts..."

for seed in $(ls -1 /seeds/*.sql 2>/dev/null | sort -V); do
    filename=$(basename "$seed")
    seed_tag=$(echo "$filename" | grep -o '^v[0-9]\+' || true)
    
    if [ -n "$seed_tag" ]; then
        if [ -z "$SCHEMA_TAG" ]; then
            echo "Skipping: $filename (no migrations applied yet)"
            continue
        fi
        
        seed_num=${seed_tag#v}
        schema_num=${SCHEMA_TAG#v}
        
        if [ "$seed_num" -le "$schema_num" ]; then
            echo "Running: $filename (schema $SCHEMA_TAG >= $seed_tag)"
            PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$seed"
            if [ $? -ne 0 ]; then
                echo "ERROR: Failed to run $seed"
                exit 1
            fi
        else
            echo "Skipping: $filename (schema $SCHEMA_TAG < $seed_tag)"
        fi
    else
        echo "Running: $filename"
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$seed"
        if [ $? -ne 0 ]; then
            echo "ERROR: Failed to run $seed"
            exit 1
        fi
    fi
done

echo "Seeding completed successfully!"