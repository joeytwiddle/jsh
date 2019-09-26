#!/usr/bin/env bash

git clean -dn | sed 's+^Would remove ++'
