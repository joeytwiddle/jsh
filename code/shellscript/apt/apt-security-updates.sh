# From: https://help.ubuntu.com/community/AutomaticSecurityUpdates
echo "**************"
date
aptitude update
release=`lsb_release -cs`
#release='precise'
# --assume-yes 
aptitude safe-upgrade -o Aptitude::Delete-Unused=false --target-release "${release}-security"
echo "Security updates (if any) installed"
