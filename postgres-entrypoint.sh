#!/bin/bash

/docker-entrypoint.sh $@

set -u # Treat unset variables as an error when substituting.

if [ ! -f /.postgres_password_env_set ]; then
	#Adding env vars to /etc/environment so cron job can use them
	echo "PGDATA=$PGDATA" >> /etc/environment
	echo "POSTGRES_DATABASE=$POSTGRES_DATABASE" >> /etc/environment
	echo "POSTGRES_USER=$POSTGRES_USER" >> /etc/environment
	echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> /etc/environment
	touch /.postgres_password_env_set
fi

if [ ! -f "$PGDATA/.max_connections_set" ]; then
	echo "max_connections=800" >> "$PGDATA/postgresql.conf"
	touch "$PGDATA/.max_connections_set"
fi

cron
echo "$(date) container started. cron job: $(cat /etc/cron.d/postgres-backup-cron | head -1)" >> /backups/backup.log

exec gosu postgres "$@"
