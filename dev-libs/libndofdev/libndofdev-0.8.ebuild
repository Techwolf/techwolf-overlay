# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Replacement for the libndofdev library used by the Second Life client to handle joysticks and the 6DOF devices on Windows and Macs."
HOMEPAGE="https://github.com/janoc/libndofdev"
SRC_URI="https://github.com/janoc/libndofdev/archive/0.8.tar.gz -> libndofdev-0.8.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="media-libs/libsdl"
DEPEND="${RDEPEND}"

S="${WORKDIR}/"libndofdev-0.8

src_prepare() {
    epatch_user
}

src_compile() {
    emake CFLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
    dobin ndofdev_test
    dolib.a libndofdev.a || die "install failed"
    insinto usr/include
    doins ndofdev_external.h
}
