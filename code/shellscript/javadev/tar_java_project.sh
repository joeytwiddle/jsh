PROJECT_NAME=`basename "$PWD"`
cd ..
verbosely tar cfz /tmp/"$PROJECT_NAME"-`geekdate -fine`.tgz --exclude=.svn --exclude=classes "$PROJECT_NAME"/
find "$PROJECT_NAME"/ -name .svn | withalldo verbosely tar cfz /tmp/"$PROJECT_NAME"-svn-`geekdate -fine`.tgz
