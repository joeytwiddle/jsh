DESTDIR=javadoc
mkdir -p $DESTDIR
javadoc -d $DESTDIR `find . -name "*.java"`
