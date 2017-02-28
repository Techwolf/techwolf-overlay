# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# Copyright 2017 Techwolf Lupindo

EAPI="6"

inherit qmake-utils udev

DESCRIPTION="Linux support for the Corsair H80i, H100i or H110i CPU Cooler using hidraw."
HOMEPAGE="http://forum.corsair.com/forums/showthread.php?t=120092"
EGIT_COMMIT="792590c5f5a77a38d5adfbc14e046bfb2fc7bfa8"
LIB_EGIT_COMMIT="1b3c06b7862ecf82caaccb3fb3aaaca2542882bb"
SRC_URI="https://github.com/audiohacked/OpenCorsairLink/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz
        https://github.com/audiohacked/CorsairLinkLib/archive/${LIB_EGIT_COMMIT}.tar.gz -> CorsairLinkLib.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-qt/qtcore:4
        dev-qt/qtgui:4
        dev-libs/hidapi"
RDEPEND="${DEPEND}"

S="${WORKDIR}/OpenCorsairLink-${EGIT_COMMIT}"

src_unpack() {
        unpack ${P}.tar.gz
        cd ${S}
        rmdir CorsairLinkLib
        unpack CorsairLinkLib.tar.gz
        mv CorsairLinkLib-${LIB_EGIT_COMMIT} CorsairLinkLib
}

src_configure() {
	eqmake4 OpenCorsairLink.pro
}

src_install() {
        dobin OpenCorsairLinkCli
        udev_dorules udev/99-corsair-link.rules
        einstalldocs
}

pkg_postinst() {
        # reload to get the new /dev entries that will be created by the udev rules.
        udev_reload
}

