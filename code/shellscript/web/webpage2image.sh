#!/bin/sh

url="$1"
image="$2"

if [ -z "$image" ]
then image="out.png"
fi

# So far for me this just rendered white images :-P
# apt-get install cutycapt xvfb
#xvfb-run --server-args="-screen 0, 1280x1200x24" cutycapt --url="${url}" --out="${image}"

# wkhtmltopdf requires the HTML be already downloaded :-/

# url-to-image is not maintained, but the fork url2img is
# Original: https://www.npmjs.com/package/url-to-image#command-line-interface-cli
# Maintained: https://www.npmjs.com/package/url2img
# npm install -g url2img
