#!/bin/bash
set -eo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OBJECT_NAME="backup_${TIMESTAMP}.sql.gz"
BUCKET_PATH="myminio/${BUCKET_BACKUP_NAME}"

mc alias set myminio http://minio:9000 ${MINIO_BACKUP_USER} ${MINIO_BACKUP_PASSWORD}

PGPASSWORD=${POSTGRES_PASSWORD} pg_dump \
    -h ${POSTGRES_HOST} \
    -p ${POSTGRES_PORT} \
    -U ${POSTGRES_USER} \
    -d ${POSTGRES_DB} \
    | gzip \
    | mc pipe "${BUCKET_PATH}/${OBJECT_NAME}"

mc ls ${BUCKET_PATH} | sort -r | tail -n +$((BACKUP_RETENTION_COUNT + 1)) | while read line; do
    FILE=$(echo $line | awk '{print $NF}')
    if [ -n "$FILE" ]; then
        mc rm ${BUCKET_PATH}/$FILE
    fi
done