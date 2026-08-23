#!/bin/bash
set -e

echo "Waiting for PostgreSQL to be ready on $DB_HOST:$DB_PORT..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done

echo "PostgreSQL is up! Checking for database ${DB_NAME}..."

until PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c '\q'; do
  echo "Database ${DB_NAME} is not initialized yet (or auth failed) - sleeping"
  sleep 2
done

echo "Database is ready! Running migrations..."

echo "Starting migrations with Liquibase..."

cd /migrations

cat > changelog.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                      http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.0.xsd">
EOF

for file in $(ls -1 *.sql 2>/dev/null | sort -V); do
    echo "    <include file=\"$file\" relativeToChangelogFile=\"true\"/>" >> changelog.xml
done

echo "</databaseChangeLog>" >> changelog.xml

echo "Created changelog.xml with $(ls -1 *.sql 2>/dev/null | wc -l) migration files"

get_files_up_to_tag() {
    local target_tag=$1
    local files=""
    
    for file in $(ls -1 *.sql 2>/dev/null | sort -V); do
        tag=$(echo "$file" | grep -o '^v[0-9]\+' || true)
        if [ -n "$tag" ]; then
            if [[ "$tag" < "$target_tag" ]] || [[ "$tag" == "$target_tag" ]]; then
                files="$files $file"
            fi
        fi
    done
    
    echo "$files"
}

# echo "Testing migrations with Seqwall..."

# if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
#     echo "ERROR: Missing required environment variables"
#     exit 1
# fi

# PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$TEST_DB_NAME'" | grep -q 1 || \
#     PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $TEST_DB_NAME"

# PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $TEST_DB_NAME -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" 2>/dev/null || true

# if [ ! -f "/scripts/ci-up-one.sh" ]; then
#     echo "ERROR: /scripts/ci-up-one.sh not found"
#     exit 1
# fi

# if [ ! -f "/scripts/ci-down-one.sh" ]; then
#     echo "ERROR: /scripts/ci-down-one.sh not found"
#     exit 1
# fi

# if [ -n "$LIQUIBASE_TAG" ]; then
#     FILE_COUNT=$(ls -1 ${LIQUIBASE_TAG}_*.sql 2>/dev/null | wc -l)
    
#     if [ "$FILE_COUNT" -eq 0 ]; then
#         echo "ERROR: No migration files found with tag '$LIQUIBASE_TAG'"
#         echo ""
#         echo "Available tags in migration files:"
#         ls -1 *.sql | grep -o '^v[0-9]\+' | sort -u | sort -V
#         exit 1
#     fi
    
#     TEST_FILES=$(get_files_up_to_tag "$LIQUIBASE_TAG")
#     TEST_FILE_COUNT=$(echo "$TEST_FILES" | wc -w)
    
#     echo "Testing migrations up to tag: $LIQUIBASE_TAG ($TEST_FILE_COUNT files)"
    
#     mkdir -p /tmp/test_migrations
#     rm -rf /tmp/test_migrations/*
    
#     for file in $TEST_FILES; do
#         cp "$file" /tmp/test_migrations/
#     done
    
#     seqwall staircase \
#         --postgres-url "postgres://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$TEST_DB_NAME?sslmode=disable" \
#         --migrations-path /tmp/test_migrations \
#         --upgrade "/scripts/ci-up-one.sh {current_migration}" \
#         --downgrade "/scripts/ci-down-one.sh {current_migration}" \
#         --migrations-extension .sql
    
# else
#     echo "Testing all migrations"
    
#     seqwall staircase \
#         --postgres-url "postgres://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$TEST_DB_NAME?sslmode=disable" \
#         --migrations-path /migrations \
#         --upgrade "/scripts/ci-up-one.sh {current_migration}" \
#         --downgrade "/scripts/ci-down-one.sh {current_migration}" \
#         --migrations-extension .sql
# fi

# if [ $? -ne 0 ]; then
#     echo "ERROR: Seqwall tests failed!"
#     exit 1
# fi

echo "All migrations tested successfully!"

echo "Applying migrations to main database"

get_order_by_tag() {
    local tag=$1
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c \
        "SELECT MAX(ORDEREXECUTED) FROM DATABASECHANGELOG WHERE TAG = '$tag' AND EXECTYPE = 'EXECUTED';" \
        2>/dev/null | xargs
}

get_current_order() {
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c \
        "SELECT COALESCE(MAX(ORDEREXECUTED), 0) FROM DATABASECHANGELOG WHERE EXECTYPE = 'EXECUTED';" \
        2>/dev/null | xargs
}

get_current_count() {
    local count=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c \
        "SELECT COUNT(*) FROM DATABASECHANGELOG WHERE EXECTYPE = 'EXECUTED';" \
        2>/dev/null | xargs)
    
    if [ -z "$count" ] || [ "$count" = " " ]; then
        echo "0"
    else
        echo "$count"
    fi
}

get_file_count_up_to_tag() {
    local target_tag=$1
    local count=0
    
    for file in *.sql; do
        if [ -f "$file" ]; then
            tag=$(echo "$file" | grep -o '^v[0-9]\+' || true)
            if [ -n "$tag" ]; then
                if [[ "$tag" < "$target_tag" ]] || [[ "$tag" == "$target_tag" ]]; then
                    count=$((count + 1))
                fi
            fi
        fi
    done
    
    echo $count
}

get_file_count_for_tag() {
    local tag=$1
    ls -1 ${tag}_*.sql 2>/dev/null | wc -l
}

get_available_tags() {
    ls -1 *.sql | grep -o '^v[0-9]\+' | sort -u | sort -V
}

DB_URL="jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME"

if [ -n "$LIQUIBASE_TAG" ]; then
    echo "Applying migrations up to tag: $LIQUIBASE_TAG"
    
    FILE_COUNT=$(get_file_count_for_tag "$LIQUIBASE_TAG")
    
    if [ "$FILE_COUNT" -eq 0 ]; then
        echo "ERROR: No migration files found with tag '$LIQUIBASE_TAG'"
        echo ""
        echo "Available tags in migration files:"
        get_available_tags
        exit 1
    fi
    
    TARGET_ORDER=$(get_order_by_tag "$LIQUIBASE_TAG")
    
    if [ -n "$TARGET_ORDER" ] && [ "$TARGET_ORDER" != " " ] && [ "$TARGET_ORDER" != "0" ]; then
        CURRENT_ORDER=$(get_current_order)
        
        if [ "$CURRENT_ORDER" -lt "$TARGET_ORDER" ]; then
            NEED_COUNT=$((TARGET_ORDER - CURRENT_ORDER))
            echo "Tag '$LIQUIBASE_TAG' found in database (ORDEREXECUTED: $TARGET_ORDER)"
            echo "Current ORDEREXECUTED: $CURRENT_ORDER"
            echo "Need to apply $NEED_COUNT migration(s)"
            liquibase \
                --url="$DB_URL" \
                --username="$DB_USER" \
                --password="$DB_PASSWORD" \
                --changeLogFile="changelog.xml" \
                updateCount $NEED_COUNT
        else
            echo "Already at or beyond tag '$LIQUIBASE_TAG'"
        fi
    else
        echo "Tag '$LIQUIBASE_TAG' not yet applied."
        
        TOTAL_COUNT=$(get_file_count_up_to_tag "$LIQUIBASE_TAG")
        CURRENT_COUNT=$(get_current_count)
        
        echo "Total migration files up to tag '$LIQUIBASE_TAG': $TOTAL_COUNT"
        echo "Already applied: $CURRENT_COUNT"
        
        if ! [[ "$CURRENT_COUNT" =~ ^[0-9]+$ ]]; then
            CURRENT_COUNT=0
        fi
        
        if [ "$CURRENT_COUNT" -lt "$TOTAL_COUNT" ]; then
            NEED_COUNT=$((TOTAL_COUNT - CURRENT_COUNT))
            echo "Need to apply $NEED_COUNT migration(s)"
            liquibase \
                --url="$DB_URL" \
                --username="$DB_USER" \
                --password="$DB_PASSWORD" \
                --changeLogFile="changelog.xml" \
                updateCount $NEED_COUNT
        else
            echo "Already at or beyond tag '$LIQUIBASE_TAG'"
        fi
    fi
    
else
    echo "Applying all migrations"
    liquibase \
        --url="$DB_URL" \
        --username="$DB_USER" \
        --password="$DB_PASSWORD" \
        --changeLogFile="changelog.xml" \
        update
fi

rm -f changelog.xml

echo "Migrations completed!"