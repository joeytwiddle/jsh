[ "$BUILDDIR" ] || BUILDDIR=/mnt/space/apt-build-tmp
[ -w "$BUILDDIR" ] || BUILDDIR=/tmp

CPU=k6
ARCH=k6
DEBIANARCH=i386
GNUSYSTYPE=i686-linux
# GNUSYSTYPE=i386-pc-linux-gnu
## I think something here is wrong: the package gets labeled i386 although it's compiled for a k6!  But if I change the DEBIANARCH then the final package refuses to install on my system!
## gcc doesn't appear to accept CPU/ARCH=k7.  Should it?
## I found these in a debian/rules file, maybe they mean something:
##   DEB_HOST_GNU_TYPE>?= $(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)
##   DEB_BUILD_GNU_TYPE>--?= $(shell dpkg-architecture -qDEB_BUILD_GNU_TYPE)

# CFLAGS="-O3 -mcpu=$CPU -march=$ARCH"
CFLAGS="-O3 -mcpu=$CPU -march=$ARCH -funroll-loops -pipe"

## The wrapper is what ensures we use optimisation during compilation:
# export WRAP_GCC=true
## Or the alternative (if you have pentium-builder installed):
export DEBIAN_BUILDARCH=i686

## A good package to test it on is sed.  (Although if you have a genuine 386, it /might/ break it and if sed is needed to fix things you might get annoyed!)
## I don't know why Debian doesn't recognise I have a k7, and why debuild won't just build and install for that architecture when asked to.

# jsh-depends: countlines
# jsh-depends-ignore: del
# jsh-ext-depends: apt-get dpkg debuild
# jsh-ext-depends-ignore: build

rebuild_repository () {
	## Again stolen from apt-build:
	REPOSITORY=/var/cache/japt-build/repository
	mkdir -p "$REPOSITORY"
	cd "$REPOSITORY" || exit 5
	for TARGET in main japt-build dists binary-$DEBIANARCH
	do [ -e "$TARGET" ] || ln -sf . "$TARGET"
	done
	cat > Release << !
Archive: japt-build
Component: main
Origin: japt-build
Label: japt-build
Architecture: $DEBIANARCH
!
	apt-ftparchive packages . | gzip -9 > Packages.gz
}

section () {
	echo "------------------------------------------------------------------------------"
	echo ">>>>>> ($PACKAGE) $@"
	echo "------------------------------------------------------------------------------"
}

if [ ! "$1" ]
then
	rebuild_repository
	exit
fi

for PACKAGE
do

	WORKDIR="$BUILDDIR"/japt-build-$PACKAGE
	mkdir -p "$WORKDIR"
	cd "$WORKDIR"

	section "Getting build dependencies"
	apt-get build-dep "$PACKAGE" || exit 2

	section "Getting source"
	apt-get source "$PACKAGE" || exit 3

	cd ./*-*/ || exit 4

	section "Building (with gcc wrapper)"

	## Failed attempts:
	# export CFLAGS
	# eval `cat /etc/apt/apt-build.conf | tr -d ' '`
	# export APT_BUILD_WRAPPER=1 ## well, this one works if you have the apt-build wrapper diverting gcc!
	# debuild --preserve-env -b -a$DEBIANARCH -t$GNUSYSTYPE -us -uc

	if [ "$WRAP_GCC" ]
	then
		## Make our own simple wrapper: (TODO: this could factor out and go in $BUILDDIR at the start)
		## This idea comes straight from apt-build's wrapper.
		mkdir -p "$WORKDIR/bin"
		REALGCC=`which gcc`
cat > "$WORKDIR/bin/gcc" << !
echo "[gcc-wrapper] Adding \"$CFLAGS\" to \"$REALGCC \$*\"" >&2
$REALGCC "\$@" $CFLAGS
!
		## TODO: shouldn't the wrapper care what its `basename "$0"` is, and pass it on?
	# /usr/bin/\`basename \$0\` "\$@" $CFLAGS
		chmod a+x "$WORKDIR/bin/gcc"
		## Not just for gcc but for all its friends.
		for CC in cc gcc1 g++ gpp gxx
		do ln -sf "$WORKDIR/bin/gcc" "$WORKDIR/bin/$CC"
		done
		## And put it on the path:
		export PATH="$WORKDIR/bin:$PATH"
	fi
	## Now do the build using our $PATH:
	debuild --preserve-env --preserve-envvar PATH -b -a$DEBIANARCH -t$GNUSYSTYPE -us -uc || exit 5

	section "Installing"

	## Was there just one package built?
	PKGS=`ls "$WORKDIR" | grep "\.deb$"`
	if [ ! `echo -n "$PKGS" | countlines` = 1 ]
	then
		DONTDEL="Not cleaning up because more than one package was built in $WORKDIR:
$PKGS"
		## Was there just one called ${PACKAGE}_<version>_<arch>.deb ?
		PKGS=`ls "$WORKDIR" | grep "$PACKAGE""_.*\.deb$"`
	fi
	if [ `echo -n "$PKGS" | countlines` = 1 ]
	then
		PKGFILE="$WORKDIR/$PKGS"
		echo "One primary .deb was built, installing $PKGFILE ..."
		if dpkg -i "$PKGFILE"
		then
			echo "Install successful"
			[ "$DONTDEL" ] && echo "$DONTDEL" || del "$WORKDIR"
		else
			echo "Install failed"
		fi
	else
		echo "Too many or too few packages built in $WORKDIR:"
		echo "$PKGS"
	fi
	## Check for packages that we have made replacements for:
	# 'ls' | grep "\.deb$" | beforefirst _ | while read PKG; do dpkg -l "$PKG" > /dev/null && echo "$PKG"_*.deb; done
	## Faster:
	# 'ls' $PWD | grep "\.deb$" | beforefirst _ | withalldo dpkg -l | drop 5 | takecols 2 | while read PKG; do echo "$PKG"_*.deb; done
	# 'ls' $PWD | grep "\.deb$" | beforefirst _ | withalldo dpkg -l | grep "^.i" | takecols 2 | while read PKG; do echo "$PKG"_*.deb; done

done
