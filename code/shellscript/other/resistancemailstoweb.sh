cd $JPATH/code/c/tools/mail
cp -f $HOME/nsmail/Resistance .
rm -rf Resistance.ems
unpine Resistance
cd Resistance.ems
mkdir titled
export OUTDIR="titled"
emailsort *.txt
ENDUP="$HOME/joey/web/cs/genlove/admin/emails"
rm -rf $ENDUP
mv titled $ENDUP
cd $ENDUP
zip theWholeLot.zip *