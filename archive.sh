#!/bin/bash

read -p "Enter a username: " USER

#USER=$1   #user
# Where to place the backups.
BACKUP_DIR=/var/www/html/shell/backups/$USER

echo "Executing script: $0"
echo "Archiving user: $USER"

#lock account
passwd -1 $USER

# Create the backup backup directory if it does not exist.
[ -d "$BACKUP_DIR" ] || {
  mkdir -p $BACKUP_DIR
  chmod 775 $BACKUP_DIR
  chgrp vagrant $BACKUP_DIR
}


# create archive of home
tar cf ${BACKUP_DIR}/${USER}.tar.gz ./

