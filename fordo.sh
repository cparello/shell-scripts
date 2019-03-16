#!/bin/bash
for FILE in *.sh
do
	echo "copying $FILE"
	cp $FILE  backups
done
