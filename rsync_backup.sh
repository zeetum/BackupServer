#!/bin/bash

# A file will be put in the automatic backup folder
#     success means the Tier 3 server was mounted
#     failure means the Tier 3 server was not mounted

rm /srv/data_drive/auto_backup/success
rm /srv/data_drive/auto_backup/failure

if [[ $(df -h | grep "samba") ]]
then
        touch /srv/data_drive/auto_backup/success
else
        touch /srv/data_drive/auto_backup/failure
        exit 1
fi

# The backup script which makes a complete file tree
# of the date backup. Identical files are linked using
# inodes, while different files are unique copies

# This script was found on Arch Linux, the original
# author is (cc) marcio rps AT gmail.com

# config vars
SRC="/samba/e5008s01sv010_share/" #dont forget trailing slash!
SNAP="/srv/data_drive/auto_backup"
OPTS="-rltgoi --delay-updates --delete --chmod=a-w"
MINCHANGES=1

# run this process with real low priority
ionice -c 3 -p $$
renice +12  -p $$

# sync
rsync $OPTS $SRC $SNAP/latest >> $SNAP/rsync.log

COUNT=$( wc -l $SNAP/rsync.log|cut -d" " -f1 )
if [ $COUNT -gt $MINCHANGES ] ; then
        DATETAG=$(date +%Y-%m-%d)
        if [ ! -e $SNAP/$DATETAG ] ; then
                cp -al $SNAP/latest $SNAP/$DATETAG
                chmod u+w $SNAP/$DATETAG
                mv $SNAP/rsync.log $SNAP/$DATETAG
               chmod u-w $SNAP/$DATETAG
         fi
fi
