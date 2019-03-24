if [ -n "$*" ]
then sortfilesbydate "$@"
else sortfilesbydate *
fi |
foreachdo ls --color -ld --block-size="'1"
