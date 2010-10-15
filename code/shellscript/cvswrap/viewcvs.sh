#!/bin/sh
REPOSANDDIR=`cat CVS/Repository`
HOSTNAME=`hostname -f`
browse "http://$HOSTNAME/cgi-bin/viewcvs.cgi/$REPOSANDDIR?sortby=date#dirlist"
