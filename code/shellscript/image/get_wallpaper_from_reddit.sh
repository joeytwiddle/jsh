#!/usr/bin/env bash
#
# See also: https://github.com/tsarjak/WallpapersFromReddit/
#

# Options
#subreddit=wallpaper
#subreddit=earthporn
subreddit=random

#random_subreddit_pool=(wallpaper earthporn MostBeautiful photographs)
# There are some questionable wallpapers, and similar for photographs.  We could perhaps limit the number we choose from.
random_subreddit_pool=(earthporn MostBeautiful)

set -e

tmpdir="$(mktemp -d)"
cd "$tmpdir"

if [ -n "$DEBUG" ]
then
    mkdir -p /tmp/get_wallpaper_from_reddit.debug
    cd /tmp/get_wallpaper_from_reddit.debug
fi

# Docs: https://github.com/reddit-archive/reddit/wiki/API

# Reddit likes us to provide an accurate user agent, for throttling purposes
user_agent='Linux:get_wallpaper_from_reddit.sh:0.0.1 (by /u/the-real-joeytwiddle)'

#if [ "$subreddit" = random ]
#then subreddit="$( [ $(($RANDOM % 100)) -lt 50 ] && echo "wallpaper" || echo "earthporn" )"
#fi

if [ "$subreddit" = random ]
then subreddit="${random_subreddit_pool[$(($RANDOM % ${#random_subreddit_pool[@]}))]}"
fi

#url="https://www.reddit.com/r/${subreddit}.json?limit=50"
#url="https://www.reddit.com/r/${subreddit}/top.json?t=year&limit=100"
url="https://www.reddit.com/r/${subreddit}.json?limit=100"

# Do not keep requesting results if we are debugging
if [ ! -f results.json ]
then curl -s -A "$user_agent" "$url" -o results.json
fi

result="$(
  node -e "
    const results = JSON.parse(require('fs').readFileSync('./results.json', 'utf-8'))

    const safePosts = results.data.children.filter(item => !item.data.over_18 && !item.data.banned_by && !item.data.banned_at_utc && (item.data.reports ? item.data.reports.length === 0 : true))

    const sortedPosts = safePosts.sort((a, b) => b.data.ups - a.data.ups)

    const chosenPost = sortedPosts[Math.floor(Math.random() * 50)]

    //console.error(chosenPost)

    console.log(chosenPost.data.url, chosenPost.data.permalink)
  "
)"

IFS=" " read -r image_url permalink <<< "$result"

permalink="https://reddit.com${permalink}"

curl -s "$image_url" -o beautiful_image.jpg



# TODO: Lots of the code below has hard-coded values.  You may want to change this, or make things more dynamic.

# TODO: Should be a separate script
wallpaper_dir="$HOME"/Pictures/Wallpapers

# Shrink down to desktop size (in case the source image was huge)
convert beautiful_image.jpg -quality 95 -geometry "2073600@>" "${wallpaper_dir}/manjaro-new.jpg"

#rotate -nozip -max 10 "${wallpaper_dir}/manjaro-lockscreen.jpg"
for n in $(seq 29 -1 0)
do
	if [ -f "${wallpaper_dir}/manjaro-lockscreen.${n}.jpg" ]
	then
		# Amazingly, if expr outputs zero, it also returns an error exit code!
		next="$(expr "$n" + 1 || true)"
		mv -f "${wallpaper_dir}/manjaro-lockscreen.${n}.jpg" "${wallpaper_dir}/manjaro-lockscreen.${next}.jpg"
	fi
done
if [ -f "${wallpaper_dir}/manjaro-lockscreen.jpg" ]
then mv -f "${wallpaper_dir}/manjaro-lockscreen.jpg" "${wallpaper_dir}/manjaro-lockscreen.0.jpg"
fi

# TODO: Should output to "$1"
filename="${wallpaper_dir}/manjaro-lockscreen.jpg"
mv -f "${wallpaper_dir}/manjaro-new.jpg" "$filename"

printf "%s (%s) %s\n" "$(date)" "$(stat -c '%s' "$filename")" "$permalink" >> "$HOME/Pictures/Wallpapers/get_wallpaper_from_reddit.log"

cd /
rm -rf "$tmpdir"
