#!/bin/sh
#
# @(#)realpath.sh	1.3 01/02/09
#
# Copyright 1994-2001 by Sun Microsystems, Inc.,
# 901 San Antonio Road, Palo Alto, California, 94303, U.S.A.
# All rights reserved.
#
# This software is the confidential and proprietary information
# of Sun Microsystems, Inc. ("Confidential Information").  You
# shall not disclose such Confidential Information and shall use
# it only in accordance with the terms of the license agreement
# you entered into with Sun.
#

SVPATH="$PATH"
PATH=/bin:/usr/bin
case "`uname -m`" in
    i[3-6]86)
        proc=i386
        ;;
    sparc*)
        proc=sparc
        ;;
    *)
        proc="`uname -m`"
        ;;
esac

PATH="$SVPATH"
exec `dirname $0`/$proc/`basename $0` $@

#
# Comment on purpose:
#
# The dynamic library code in glibc does not seem to canonicalize
# path names to when checking if a library has already been loaded.
# As a result, if LD_LIBRARY_PATH is set with non-canonical paths
# then the loading of libfontmanager.so-linked-against-libawt.so
# causes a duplicate loading of libawt.so (the
# System.loadLibrary("awt") call uses the canonical path name).
#
# This program is a simple workaround to the problem so that
# .java_wrapper can set LD_LIBRARY_PATH to match the canonicalization
# made by System.loadLibrary().
#
