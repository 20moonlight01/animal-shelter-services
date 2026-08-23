#!/bin/bash
set -e

mc alias set myminio http://minio:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}

mc mb myminio/${MINIO_BACKUP_BUCKET} --ignore-existing

mc admin user add myminio ${MINIO_BACKUP_USER} ${MINIO_BACKUP_PASSWORD} 2>/dev/null || echo "User already exists"

cat > /tmp/backup-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::${MINIO_BACKUP_BUCKET}",
        "arn:aws:s3:::${MINIO_BACKUP_BUCKET}/*"
      ]
    }
  ]
}
EOF

mc admin policy create myminio backup-policy /tmp/backup-policy.json

mc admin policy attach myminio backup-policy --user=${MINIO_BACKUP_USER}