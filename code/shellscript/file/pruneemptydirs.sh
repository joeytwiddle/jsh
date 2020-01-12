#!/bin/sh
find . -type d -size 0 |
withalldo rmdir --ignore-fail-on-non-empty --parents
