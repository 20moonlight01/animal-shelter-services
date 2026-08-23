#!/bin/bash
set -e

sed -i "s|\${BACKUP_INTERVAL}|${BACKUP_INTERVAL}|g" /etc/crontabs/root

crond -f -l 2