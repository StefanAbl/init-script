#!/bin/bash
set -e

alias=$1
bucket=$2

DATADIR=/var/lib/jellyfin
CONFIGDIR=/etc/jellyfin

function backup(){
  local base=$alias/$bucket/$1
  if [ "$(ls -A "$DATADIR")" ]; then
    echo mc cp --recursive $DATADIR "$base/datadir"
    mc cp --recursive $DATADIR "$base/datadir"
    else
    echo "$DATADIR is Empty"
    fi
  if [ "$(ls -A $CONFIGDIR)" ]; then
    echo mc cp --recursive $CONFIGDIR "$base/configdir"
    mc cp --recursive $CONFIGDIR "$base/configdir"
    else
    echo "$CONFIGDIR is Empty"
    fi
}

date=$(date +%Y%m%d-%H%M)
if [ "$3" == "--restore" ]; then
  base=$alias/$bucket/$4
  echo "Restoring from $base"
  backup "$date-restore"


  rm -rf ${DATADIR:?}/*
  rm -rf ${CONFIGDIR:?}/*

  mc cp --recursive "$base"/datadir/jellyfin/ $DATADIR/
  chown -R "$5" $DATADIR
  mc cp --recursive "$base"/configdir/jellyfin/ $CONFIGDIR/
  chown -R "$5" $CONFIGDIR
else
  backup "$date"
fi

usage='
Usage:
jf-backup alias bucket [--restore folder "user:group"]
where
  alias is the alias given to an S3 store instance
  bucket is the bucket in which the data should be put

when --restore is specified
  folder is the folder created by the backup script from which data should be restored
  user:group is the user/group to which ownership will be transfered after downloading the files
'
