#!/usr/bin/env bash

grep -E '\.(gz|tar|tar.gz|tar.bz2|tgz|tgj|arj|taz|lzh|zip|z|Z|rar|jar|lha|7z|xz|zst)$' <<< "$1" >/dev/null
