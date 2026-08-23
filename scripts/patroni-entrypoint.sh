#!/bin/bash
set -e

tr -d '\r' < /etc/patroni/config.yml.template | sed 's/\xc2\xa0/ /g' | envsubst > /etc/patroni/config.yml

exec patroni /etc/patroni/config.yml