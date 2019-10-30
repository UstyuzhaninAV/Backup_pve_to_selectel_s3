#!/bin/bash
SUPLOAD='/usr/local/bin/supload'
VZDUMP='/usr/bin/vzdump'
VZLIST='/usr/sbin/qm'
DUMPDIR='/var/lib/vz/dump/'
S3_USERNAME='****'
S3_PASSWORD='****'
S3_BUCKET='Backup/pve'
DATE="$(date +%F)"
ADMINMAIL="****"
MAILSUBJ="Daily pve backup report at ${DATE}"
LOGFILE=/root/backup/backup-${DATE}
((
set -e
echo "Backup start `date`"
rm -rf "$DUMPDIR"
mkdir "$DUMPDIR"
touch "$LOGFILE"
for id in `"$VZLIST" list | awk '{print $1}' | tail -n +2`;
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
rm -rf "$LOGFILE"
