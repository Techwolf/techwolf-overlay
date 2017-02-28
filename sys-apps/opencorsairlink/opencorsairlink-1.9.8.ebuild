# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# Copyright 2017 Techwolf Lupindo

EAPI="6"

DESCRIPTION="Linux support for the Corsair H80i, H100i or H110i CPU Cooler using libusb"
HOMEPAGE="http://forum.corsair.com/forums/showthread.php?t=120092"
EGIT_COMMIT="1f85e7127151660b210f1662f675b83ccc1f972a"
SRC_URI="https://github.com/audiohacked/OpenCorsairLink/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-libs/libusb"
RDEPEND="${DEPEND}"

S="${WORKDIR}/OpenCorsairLink-${EGIT_COMMIT}"

src_compile() {
        unset LDFLAGS
        emake
}

src_install () {
        newbin OpenCorsairLink.elf OpenCorsairLink
        newbin OpenCorsairLinkPSU.elf OpenCorsairLinkPSU
        newbin Scanner.elf Scanner
        einstalldocs
}
