## Summary: Gentoo takes up the most space by leaving old versions of distfiles in /usr/portage/distfiles
## and partial or completed builds in /var/tmp/portage/*/*.

echo "Start `date`" >> cleanup.log
df -h / >> cleanup.log

du -sh /var/tmp/ccache

## Partial/failed builds:
dusk /var/tmp/portage/*/*
del /var/tmp/portage/*/*
# rm -rf /var/tmp/portage/*/*

if [ "$FULL_CLEAN" ]
then

	## Often do nothing:
	emerge -a --clean
	emerge -a --depclean

	## SLOW and often does nothing:
	eclean -p distfiles
	eclean -p packages
	eclean -p --destructive distfiles
	eclean -p --destructive packages

fi

## But there are still files left, so:
dush /usr/portage/distfiles/
del /usr/portage/distfiles/*
# rm -rf /usr/portage/distfiles/*

if [ "$FIX_SYSTEM" ]
then

	## Apparently we need to do this after doing the above.
	## (I think "the above" must refer to eclean --destructive which actually
	## often does nothing on an already tidy system!)
	# revdep-rebuild -a
	revdep-rebuild -v -- --ask

	## Stuff that need recompiling since USE flags have changed.
	emerge --ask --newuse world
	## Full update (include new versions added to this release):
	# emerge --ask --update --newuse --deep world
	# --empty 

fi

echo "End `date`" >> cleanup.log
df -h / >> cleanup.log

