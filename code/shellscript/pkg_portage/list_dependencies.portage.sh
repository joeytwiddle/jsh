## Isn't this listing revdeps?  We are looking for things which complain when we remove this.
emerge -p --unmerge "$1" # sys-devel/flex-2.5.33-r3

## Similarly, shows packages depending on "$1":
equery depends "$1"

## But to list packages which "$1" depends on...?

