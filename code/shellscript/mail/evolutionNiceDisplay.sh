### Basically sets your evolution config files to present:
### Fields: Sender Subject Date Size
### Descending by Date, or Ascending for Lists (if filename contains "_Lists_"!)
### Now threading, well that's specified as value="1" in config.xmldb

set -e   ## break out on error, at least bash + zsh I think

EVOLDIR="$HOME/evolution"
CONFDIR="$EVOLDIR/config"
BAKDIR="/tmp/evolution_config_bak"

if test -d "$BAKDIR"; then
	echo "Backup already exists in $BAKDIR ."
	echo "Not making backup of current?"
	echo "Is this OK?  Use <Ctrl>+C if not."
	read KEY
else
	cp -a "$CONFDIR" "$BAKDIR"
fi

## Do tabs
cd "$EVOLDIR"
test ! -f config.xmldb.bak && cp config.xmldb config.xmldb.bak
cat config.xmldb.bak |
## Skipping the reset of all threading to off:
# sed 's+\(<entry name="file[^"]*" type="boolean" value="\)1"/>+\10"/>+' |
## Set that _Lists_ have threading by default:
sed 's+\(<entry name="file[^"]*_Lists_[^"]*" type="boolean" value="\)0"/>+\11"/>+' > config.xmldb

cd "$CONFDIR"
for FILE in et-header-file*
do
	ASCENDING=false
	if contains "$FILE" "_Lists_"; then
		ASCENDING=true
	fi
	cat > "$FILE" << !
<?xml version="1.0"?>
<ETableState state-version="0.10000000000000001">
  <column source="0" expansion="1.00000000000000000"/>
  <column source="3" expansion="1.00000000000000000"/>
  <column source="1" expansion="1.00000000000000000"/>
  <column source="4" expansion="1.00000000000000000"/>
  <column source="5" expansion="1.60000000000000000"/>
  <column source="6" expansion="0.50000000000000000"/>
  <column source="9" expansion="0.06000000000000000"/>
  <grouping>
    <leaf column="6" ascending="$ASCENDING"/>
  </grouping>
</ETableState>
!
done
