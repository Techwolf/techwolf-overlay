# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Replacement for the libndofdev library used by the Second Life client to handle joysticks and the 6DOF devices on Windows and Macs."
HOMEPAGE="https://github.com/janoc/libndofdev"
SRC_URI="https://github.com/janoc/libndofdev/archive/0.5.zip -> libndofdev-0.5.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="media-libs/libsdl"
DEPEND="${RDEPEND}"

src_prepare() {
    epatch_user
}

src_compile() {
    # add SpaceExplorer support
    # sed -i -e 's:ID.product == 0xc626) || // SpaceNavigators:ID.product == 0xc626) || // SpaceNavigators\n                     (ID.product == 0xc627) || // SpaceExplorer (untested):' "${WORKDIR}/libndofdev/ndofdev.c"
    # cd libndofdev
    make CFLAGS="${CFLAGS}"|| die "emake failed"
}

src_install() {
    dolib.a libndofdev.a || die "install failed"
    insinto usr/include
    doins ndofdev_external.h
}
