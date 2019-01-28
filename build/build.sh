#!/bin/sh

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

if [ ! -e "/usr/bin/fakeroot" ]; then
	apt-get install fakeroot
fi


script_dir=$(cd $(dirname "$0"); pwd)
pkg_name="$(basename $(cd ..;pwd))"

MODULENAME="se3-pla"
BUILDDIR=$(cd "$script_dir"; pwd) # Same as script_dir but with a full path.
PKGDIR="${BUILDDIR}/$MODULENAME"


# Cleaning of $BUILDDIR.
rm -f "${BUILDDIR}/"*.deb
rm -rf "$PKGDIR" && mkdir -p "$PKGDIR"

# Copy the source in the "$PKGDIR" directory. Copy all
# directories in the root of this repository except the
# "build/" directory itself.
for dir in "${BUILDDIR}/../"*
do
    # Convert to the full path.
    dir=$(readlink -f "$dir")

    [ ! -d "$dir" ]            && continue
    [ "$dir" = "${BUILDDIR}" ] && continue

    cp -ra "$dir" "$PKGDIR"
done

VERSION=$(grep -i '^version:' "${PKGDIR}/DEBIAN/control" | cut -d' ' -f2)

chmod -R 755 "${PKGDIR}/DEBIAN"

# Now, it's possible to build the package.
cd "$BUILDDIR" || {
    echo "Error, impossible to change directory to \"${BUILDDIR}\"." >&2
    echo "End of the script."                                        >&2
    exit 1
}
find "$PKGDIR" -name ".empty" -delete

# dpkg --build "$PKGDIR"
# mv $PKGDIR.deb se3_$version.deb

fakeroot dpkg-deb -b "$PKGDIR" "${MODULENAME}${VERSION}.deb"


echo "OK, building succesfully..."


