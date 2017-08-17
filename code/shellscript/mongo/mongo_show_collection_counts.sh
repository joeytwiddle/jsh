#!/usr/bin/env bash

# E.g.: mongo_show_collection_counts localhost/MyDB

mongo "$@" << !!! |
db.getCollectionNames().forEach(collectionName => print(collectionName + ": " + db.getCollection(collectionName).count()));
!!!
sort -n -k 2
