#!/usr/bin/env bash

mongo "$@" << !!!
show dbs;
!!!
