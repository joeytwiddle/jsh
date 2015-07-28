if [ -n "$*" ]
then sortfilesbydate "$@"
else sortfilesbydate *
fi |
foreachdo ls --color -ld
