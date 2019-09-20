#!/usr/bin/env bash

# npm install -g imagemin-cli prettier

for file
do
    cat "$file" |
    imagemin |
    prettier --stdin --parser html |
    dog "$file.minified"
done
