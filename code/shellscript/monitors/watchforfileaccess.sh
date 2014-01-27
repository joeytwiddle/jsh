#!/bin/sh
# See also: package/command 'watchdog'.
# See also: watchfolderforchanges, monitorfileaccess
#jwatch ls -ul $@
# Can add -R but does become slower (and doesn't show full paths)!
#jwatch ls -ulR $@
#jwatch fasttreeprofile "$@"
# But we aren't really interested when files are access, only changed, so:
jwatch eval "fasttreeprofile $@ | dropcols 2 3"
