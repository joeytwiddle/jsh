## blank a full cd quickly:
cdrecord dev=0,0,0 gracetime=2 -v speed=12 blank=fast &&
true
# eject /mnt/cdrw &&
# uneject /mnt/cdrw
