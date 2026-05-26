#!/bin/bash
# MongoDB RBAC initialisation script for the UniFi Network Application.
# Runs once on first container start when /data/db is empty.
#
# mongo:7.0+ ships only mongosh; the old `mongo` binary was removed in 6.0.
# Double-quoted --eval lets bash expand ${...} env vars before the JS reaches mongosh.

mongosh \
  --username "$MONGO_INITDB_ROOT_USERNAME" \
  --password "$MONGO_INITDB_ROOT_PASSWORD" \
  --authenticationDatabase "$MONGO_AUTHSOURCE" \
  --eval "
    db.getSiblingDB('${MONGO_AUTHSOURCE}').createUser({
      user: '${MONGO_USER}',
      pwd:  '${MONGO_PASS}',
      roles: [
        { role: 'clusterMonitor', db: 'admin' },
        { role: 'dbOwner', db: '${MONGO_DBNAME}' },
        { role: 'dbOwner', db: '${MONGO_DBNAME}_stat' },
        { role: 'dbOwner', db: '${MONGO_DBNAME}_audit' },
        { role: 'dbOwner', db: '${MONGO_DBNAME}_restore' }
      ]
    });
  "
