CNT=`countlines $HOME/.dirhistory`
echo "Last 15/$CNT visited directories, and next 5:"
tail -15 $HOME/.dirhistory
echo "$PWD/  <-- You are here"
# echo "Next 3 directories:"
head -5 $HOME/.dirhistory
