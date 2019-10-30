#!/bin/bash
SUPLOAD='/usr/local/bin/supload'
VZDUMP='/usr/bin/vzdump'
VZLIST='/usr/sbin/vzlist'
DUMPDIR='/var/lib/vz/dump/'
S3_USERNAME='***'
S3_PASSWORD='***'
S3_BUCKET='Backup/pve'
d=`date +%Y%m%d`
LOGFILE='/root/backup/backup_$d.log'
((
set -e
echo "Backup start `date`"
rm -rf "$DUMPDIR"
mkdir "$DUMPDIR"
for id in `"$VZLIST" --all | awk '{print $1}' | tail -n +2`; 
do 
    "$VZDUMP" $id -mode snapshot --dumpdir "$DUMPDIR" --compress gzip
    for file in `ls "$DUMPDIR"`;
    do
        "$SUPLOAD" -u "$S3_USERNAME" -k "$S3_PASSWORD" -d 7d "$S3_BUCKET" "$DUMPDIR"/vzdump-qemu-*.vma.gz
        rm "$DUMPDIR"/$file
    done
done
rm -rf "$DUMPDIR"/*
echo "Backup complete `date`"
) 2>&1) | tee "$LOGFILE"
"$SUPLOAD" -u "$S3_USERNAME" -k "$S3_PASSWORD" -d 7d "$S3_BUCKET" "$LOGFILE"
