#!/bin/sh
memo -t "1 hour" rpm -qa | grep "$@"
