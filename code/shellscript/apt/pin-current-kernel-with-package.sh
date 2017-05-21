#!/bin/sh

# TODO: This script only "pins" the core kernel package linux-image-foo.  If
# you have extra kernel packages such as linux-image-extra-foo, this won't be
# pinned, so it could get autoremoved.

set -e

package_name="currently-running-kernel"
package_version="1.0"

tmpdir="/tmp/pin-current-kernel-with-package.$$"

mkdir -p "${tmpdir}"
cd "${tmpdir}"

# What is the name of the package holding the currently running kernel?
current_kernel_package_name="linux-image-$(uname -r)"

# Alternatively, determine the image file used at bootup, and find the package that file belongs to.
#kernel_file="$(sed 's+[^=]*=++ ; s+ .*++' /proc/cmdline)"
#current_kernel_package_name="$(dpkg -S "/boot/vmlinuz-4.4.0-72-lowlatency" | head -n 1 | sed 's+: .*++')"
#if [ -z "$current_kernel_package_name" ]; then echo "Could not determine current kernel package" >&2; exit 3; fi

#is_package_insalled="$(apt -qq list "${current_kernel_package_name}")"
is_package_insalled="$(dpkg-query -W "${current_kernel_package_name}" 2>/dev/null)"
if [ -z "$is_package_insalled" ]; then echo "Cannot pin package ${current_kernel_package_name} because it is not installed"; exit 1; fi

echo ">> Generating package ${package_name} to pin the current kernel package (${current_kernel_package_name})"

cat > "./${package_name}" << !!!
### Commented entries have reasonable defaults.
### Uncomment to edit them.
# Source: <source package name; defaults to package name>
Section: misc
Priority: optional
# Homepage: <enter URL here; no default>
Standards-Version: 3.9.2

Package: ${package_name}
Version: ${package_version}
# Maintainer: Your Name <yourname@example.com>
# Pre-Depends: <comma-separated list of packages>
Depends: ${current_kernel_package_name}
# Recommends: <comma-separated list of packages>
# Suggests: <comma-separated list of packages>
# Provides: <comma-separated list of packages>
# Replaces: <comma-separated list of packages>
# Architecture: all
# Copyright: <copyright file; defaults to GPL2>
# Changelog: <changelog file; defaults to a generic changelog>
# Readme: <README.Debian file; defaults to a generic one>
# Extra-Files: <comma-separated list of additional files for the doc directory>
# Files: <pair of space-separated paths; First is file to include, second is destination>
#  <more pairs, if there's more than one file to include. Notice the starting space>
Description: virtual package to keep the currently running kernel installed
 This package was built by the pin-current-kernel-with-package script to keep the current kernel installed during runtime, even if it is marked as auto-installed
!!!

equivs-build "./${package_name}"
echo

package_file="./${package_name}_${package_version}_all.deb"

if [ ! -f "${package_file}" ]; then echo "Expected package file was not build: ${package_file}"; exit 2; fi

echo ">> Installing generated package ${package_name}"

sudo dpkg -i "${package_file}"
