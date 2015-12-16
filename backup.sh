#!/bin/bash

# Original version of this script can be found here:
# https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux

##############################
## POSTGRESQL BACKUP CONFIG ##
##############################

# This dir will be created if it doesn't exist.
BACKUP_DIR=/backups/
BAK_LOG=$BACKUP_DIR/backup.log

# Optional hostname to adhere to pg_hba policies.  Will default to "localhost" if none specified.
HOSTNAME="localhost"

# Optional username to connect to database as.  Will default to "postgres" if none specified.
USERNAME=$POSTGRES_USER
PGPASSWORD=$POSTGRES_PASSWORD

# Number of days to keep daily backups
DAYS_TO_KEEP=7

###########################
#### PRE-BACKUP CHECKS ####
###########################

if [[ $(find $BAK_LOG -type f -size +5M 2>/dev/null) ]]; then
    >$BAK_LOG #empty log file if it is getting too big
fi

# Delete daily backups 7 days old or more
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "pgdump-*" -exec rm -rf '{}' ';'

#If cron job running every minute during development, remove dirs older than 2 minutes
if [[ $(cat /etc/cron.d/postgres-backup-cron | head -c 9) == "* * * * *" ]]; then
	echo "$(date) WARNING! deleting backups older than 2 minutes..."
	find $BACKUP_DIR -maxdepth 1 -mmin +2 -name "pgdump-*"
	find $BACKUP_DIR -maxdepth 1 -mmin +2 -name "pgdump-*" -exec rm -rf '{}' ';'
	echo "$(date) return code=$?"
fi

FINAL_BACKUP_DIR=$BACKUP_DIR"pgdump-`date +\%Y-\%m-\%d-\%I-\%M-\%S`/"
echo "$(date) Making backup directory in $FINAL_BACKUP_DIR"

if ! mkdir -p $FINAL_BACKUP_DIR; then
	echo "$(date) Cannot create backup directory in $FINAL_BACKUP_DIR"
	exit 1;
fi;

###########################
###### FULL BACKUPS #######
###########################
cd $PGDATA

#Figure out which databases to backup
DATABASE=minmaster
echo "$(date) Custom backup of $DATABASE"

# Will produce a custom-format backup
# http://zevross.com/blog/2014/06/11/use-postgresqls-custom-format-to-efficiently-backup-and-restore-tables/
if ! pg_dump -Fc -h $HOSTNAME -U $USERNAME $DATABASE -f $FINAL_BACKUP_DIR"$DATABASE".custom.in_progress; then
	echo "[!!ERROR!!] Failed to produce custom backup database $DATABASE"
else
	mv $FINAL_BACKUP_DIR"$DATABASE".custom.in_progress $FINAL_BACKUP_DIR"$DATABASE".custom
	echo -e "$(date) Database backed up to "$FINAL_BACKUP_DIR"$DATABASE".custom
fi

###################
###### DONE #######
###################
echo "$(date) Latest backup disk usage: $(du -hs $FINAL_BACKUP_DIR)"
echo "$(date) Total backup disk usage: $(du -hs $BACKUP_DIR)"
echo "$(date) Done."

