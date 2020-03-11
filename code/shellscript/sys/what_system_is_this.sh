#!/usr/bin/env bash

# From: https://unix.stackexchange.com/a/6348
#
# In general, you can look for /etc/*release
#
# Some systems have multiple such files: grep -m 1 . /etc/*release
#
# One-liner: ( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1

if [ -f /etc/os-release ]
then
    # freedesktop.org and systemd
    . /etc/os-release
    operating_system="$NAME"
    system_version="$VERSION_ID"
elif type lsb_release >/dev/null 2>&1
then
    # linuxbase.org
    operating_system="$(lsb_release -si)"
    system_version="$(lsb_release -sr)"
elif [ -f /etc/lsb-release ]
then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    operating_system="$DISTRIB_ID"
    system_version="$DISTRIB_RELEASE"
elif [ -f /etc/debian_version ]
then
    # Older Debian/Ubuntu/etc.
    operating_system="Debian"
    system_version="$(cat /etc/debian_version)"
elif [ -f /etc/SuSe-release ]
then
    # Older SuSE/etc.
    operating_system="SuSE"
    # TODO
elif [ -f /etc/redhat-release ]
then
    # Older Red Hat, CentOS, etc.
    operating_system="RedHat"
    # TODO
elif [ -f /etc/gentoo-release ]
then
    operating_system="Gentoo"
    # TODO
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    operating_system="$(uname -s)"
    system_version="$(uname -r)"
fi

case $(uname -m) in
    x86_64)
        architecture=x64  # or AMD64 or Intel64 or whatever
        ;;
    i*86)
        architecture=x86  # or IA32 or Intel32 or whatever
        ;;
    *)
        architecture=unknown
        ;;
esac

echo "operating_system=\"$operating_system\""
echo "system_version=\"$system_version\""
echo "architecture=\"$architecture\""
