#!/bin/sh
DIR=`date +%m%d%y`
DEST=/db_backups/$DIR
mkdir $DEST
mongodump --host 127.0.0.1 --port 18509 --username GorilasAdmin --password Operaciones1963 --out $DEST
