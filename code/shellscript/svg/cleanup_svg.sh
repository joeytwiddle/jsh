#!/usr/bin/env bash

# To run faster, pre-install dependencies:
#
#     npm install -g imagemin-cli js-beautify

# Note that imagemin may change element ids, so make sure your app is not using the SVG's ids in JS or CSS.

for file
do
    cat "$file" |
    # Last time I tried, with npx 6.11.3 and node v10.14.1, npx was doing a lot of downloading, even if I had the latest version installed, so I have taken npx off for now.
    #npx -p imagemin-cli imagemin
    imagemin |
    # Format for editing (html-beautify is my favourite for SVGs)
    #npx prettier --stdin --parser html |
    #npx -p js-beautify html-beautify
    #html-beautify -s 2 - |
    dog "$file.minified"
done
