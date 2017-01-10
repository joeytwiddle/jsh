#!/usr/bin/env bash

mongo "$@" << !!!
var collections = db.getCollectionNames();

for (var c of collections) {
	var count = db.getCollection(c).count();
	print(c + ": " + count);
}
!!!
