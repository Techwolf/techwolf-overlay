# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Replacement for the libndofdev library used by the Second Life client to handle joysticks and the 6DOF devices on Windows and Macs."
HOMEPAGE="http://www.aaue.dk/~janoc/index.php?n=Personal.3DConnexionSpaceNavigatorSupport"
SRC_URI="http://www.aaue.dk/~janoc/files/software/linux/spacenav/libndofdev-0.2.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="media-libs/libsdl"
DEPEND="${RDEPEND}"

src_compile() {
    cd libndofdev
    make CFLAGS="${CFLAGS}"|| die "emake failed"
}

src_install() {
    dolib.a libndofdev/libndofdev.a || die "install failed"
    insinto usr/include
    doins libndofdev/ndofdev_external.h
}
