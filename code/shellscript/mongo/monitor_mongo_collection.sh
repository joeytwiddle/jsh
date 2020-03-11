#!/usr/bin/env bash

db_name="$1"
collection_name="$2"

# We use .toArray() to avoid mongo's 20 document limit.  It also pretty-prints (each document takes multiple lines).
# Alternatively we can put `DBQuery.shellBatchSize = 300` before the query.  It does not persist.
jwatch eval " mongo '${db_name}' <<< 'db.${collection_name}.find({}).toArray()' | grep -v '^Implicit session' "
