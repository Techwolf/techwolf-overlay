# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Replacement for the libndofdev library used by the Second Life client to handle joysticks and the 6DOF devices on Windows and Macs."
HOMEPAGE="http://www.aaue.dk/~janoc/index.php?n=Personal.3DConnexionSpaceNavigatorSupport"
SRC_URI="http://imprudenceviewer.org/download/libs/source/libndofdev-0.2.1-source.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="media-libs/libsdl"
DEPEND="${RDEPEND}"

src_compile() {
    mv libndofdev-0.2.1-source libndofdev
    cd libndofdev
    make CFLAGS="${CFLAGS}"|| die "emake failed"
}

src_install() {
    dolib.a libndofdev/libndofdev.a || die "install failed"
    insinto usr/include
    doins libndofdev/ndofdev_external.h
}
