## Could be renamed: get_high_fidelity_sub_mirror
echo "Warning: May not be browseable (use -k or wget_get_browseable_copy for that).  This kind of backup has more fidelity to the original, but may not work when placed on a different domain, and won't pass checksum comparisons."
echo
sleep 1
wget --mirror --no-parent "$@"
## Some more useful options:
# -k -e robots=off --wait 1
