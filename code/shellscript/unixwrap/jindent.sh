cp $* $*.b4ind
# indent -sob -br -npsl -ce -brs $*
astyle --indent=spaces=2 $*
