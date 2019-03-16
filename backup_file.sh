#!/bin/bash

function backup_file(){
	if [ -f $1 ]
	then
	  local BACK="$(basename ${1}).$(date +%F).$$"
	  echo "Backing up $1 to ${BACK}"
	  cp $1 $BACK
	else
	 return 1
	fi
}

backup_file /etc/hosts

if [ $? -eq 0 ]
then
	echo "Backup succeeded!"
else
	echo "backup failed!"
	exit 1
fi
