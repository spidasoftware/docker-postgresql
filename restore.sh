#!/bin/bash

set -u # Treat unset variables as an error when substituting.
PGPASSWORD=$POSTGRES_PASSWORD

#restore from backup dir arg passed in
DIR=$1

#if no arg restore from latest backup
if [[ $# -eq 0 ]]; then
	echo "No directory specified. Restoring from latest backup..."
	DIR=$(ls -td /backups/pgdump-* | head -n 1) #find latest backup
fi

#if no backup dir found exit
if [ -z "$DIR" ]; then
	echo "No backup directory found."
	exit
fi

pg_restore --verbose --dbname=$POSTGRES_DATABASE --clean --username=$POSTGRES_USER $DIR/$POSTGRES_DATABASE.custom
