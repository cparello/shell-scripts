#!/bin/bash

#----------------------------------------------
# I WROTE A SIMPLE SCRIPT TO:
# - RSYNC A DUMP SQL FILE TO REMOTE SERVER
# - THEN EXPORT A BACKUP SQL FILE
# - THEN IMPORT THE DUMP SQL FILE
# - THEN REMOVE THE DUMP SQL FILE
#----------------------------------------------
#  This work is licensed under a Creative Commons
#  Attribution-ShareAlike 3.0 Unported License;
#  see http://creativecommons.org/licenses/by-sa/3.0/
#  for more information.
#----------------------------------------------


## CD INTO LOCAL WORKING DIRECTORY
## this is where I keep my local dump SQL files.
## the most recent one is always named dump.sql
cd ~/www/website.dev/DB

## RSYNC LATEST DUMP.SQL FILE TO REMOTE SERVER
rsync -avzP dump.sql _USER_@111.222.333.444:/home/_USER_/website.com/backups
wait

## SSH INTO SERVER
ssh _USER_@111.222.333.444 /bin/bash << EOF
    echo "**************************";
    echo "** Connected to remote. **"
    echo "**************************";
    echo "";

    ## CD INTO REMOTE WORKING NON-PUBLIC DIRECTORY
    ## where the dump.sql file was rsynced to
    cd website.com/backups
    wait
    sleep 1

    ## RUN MYSQLDUMP COMMAND
    ## save the SQL with date stamp
    mysqldump --host=localhost --user=root --password=_PASSWORD_ _DATABASE_ > `date +%Y-%m-%d`.sql;
    echo "***************************************";
    echo "** `date +%Y-%m-%d`.SQL has been imported. **"
    echo "***************************************";
    echo "";
    wait
    sleep 1

    ## IMPORT DUMP.SQL COMMAND
    mysql --host=localhost --user=root --password=_PASSWORD_ _DATABASE_ < dump.sql;
    echo "*********************************";
    echo "** DUMP.SQL has been imported. **"
    echo "*********************************";
    echo "";
    wait
    sleep 1

    ## REMOVE DUMP.SQL FILE
    rm dump.sql
    echo "********************************";
    echo "** DUMP.SQL has been removed. **"
    echo "********************************";
    exit
EOF
