#!/usr/bin/env bash

git clean -dn | sed 's+^Would remove ++'

# This will give many more results.  Why?
#git status --porcelain -uall | grep '^?? '
