# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2018 Techwolf Lupindo

EAPI="6"

EGIT_COMMIT="da882973fd87c7e5eba19f0b1d39d86a4271b9a2"
GITHUBNAME="audiohacked/OpenCorsairLink"

inherit webvcs

DESCRIPTION="Linux support for the Corsair H80i, H100i or H110i CPU Cooler using libusb"
HOMEPAGE="http://forum.corsair.com/forums/showthread.php?t=120092"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-libs/libusb"
RDEPEND="${DEPEND}"

src_compile() {
        unset LDFLAGS
        emake
}

src_install () {
        newbin OpenCorsairLink.elf OpenCorsairLink
        einstalldocs
}
