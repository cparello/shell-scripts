#!/bin/bash
# System + MySQL backup script
# Copyright (c) 2019 Chris Parello
# This script is licensed under GNU GPL version 2.0 or above
# ---------------------------------------------------------------------

#########################
######TO BE MODIFIED#####

### System Setup ###
BACKUP=/backups

### MySQL Setup ###
MUSER="*"
MPASS="*"
MHOST="*"

### RSYNC server Setup ###
RSYNCDIR="*"
RSYNCUSER="*"
RSYNCPASSWORD="*"
RSYNCIP="*"

######DO NOT MAKE MODIFICATION BELOW#####
#########################################

### Binaries ###
TAR="$(which tar)"
GZIP="$(which gzip)"
FTP="$(which ftp)"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"

### Today + hour in 24h format ###
NOW=$(date +"%d%H")


## make sure directory exists
[[ -d $BACKUP ]] || mkdir $BACKUP

### Create hourly dir ###

mkdir $BACKUP/$NOW

### Get all databases name ###
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do

### Create dir for each databases, backup tables in individual files ###
  mkdir $BACKUP/$NOW/$db

  for i in `echo "show tables" | $MYSQL -u $MUSER -h $MHOST -p$MPASS $db|grep -v Tables_in_`;
  do
    FILE=$BACKUP/$NOW/$db/$i.sql.gz
    echo $i; $MYSQLDUMP --add-drop-table --allow-keywords -q -c -u $MUSER -h $MHOST -p$MPASS $db $i | $GZIP -9 > $FILE
  done
done

### Compress all tables in one nice file to upload ###

ARCHIVE=$BACKUP/$NOW.tar.gz
ARCHIVED=$BACKUP/$NOW

$TAR -cvf $ARCHIVE $ARCHIVED

###RSYNC


## CD INTO LOCAL WORKING DIRECTORY
## this is where I keep my local dump SQL files.
## the most recent one is always named dump.sql
cd ~/www/website.dev/DB

## RSYNC LATEST DUMP.SQL FILE TO REMOTE SERVER
rsync -avzP $ARCHIVED $RSYNCUSER@$RSYNCIP:/home/$RSYNCUSER/$RSYNCDIR
wait

## SSH INTO SERVER
ssh $RSYNCUSER@$RSYNCIP /bin/bash << EOF
    echo "**************************";
    echo "** Connected to remote. **"
    echo "**************************";
    echo "";

    ## CD INTO REMOTE WORKING NON-PUBLIC DIRECTORY
    ## where the dump.sql file was rsynced to
    cd $RSYNCDIR
    wait
    sleep 1

    tar -xvzf $ARCHIVED

    ## REMOVE DUMP.SQL FILE
    rm $ARCHIVED
    echo "********************************";
    echo "** Archive has been removed. **"
    echo "********************************";
    exit
EOF

### Delete the backup dir and keep archive ###

rm -rf $ARCHIVED
