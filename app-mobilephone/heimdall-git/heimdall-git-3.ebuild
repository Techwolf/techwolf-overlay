# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-mobilephone/heimdall/heimdall-9999.ebuild,v 1.6 2014/03/24 17:48:11 ssuominen Exp $

EAPI=5

inherit cmake-utils udev git-2


KEYWORDS="~amd64"


EGIT_REPO_URI="git://github.com/Benjamin-Dobell/Heimdall.git
		https://github.com/Benjamin-Dobell/Heimdall.git"

DESCRIPTION="Tool suite used to flash firmware onto Samsung Galaxy S devices"
HOMEPAGE="http://www.glassechidna.com.au/products/heimdall/"

LICENSE="MIT"
SLOT="0"

# virtual/libusb is not precise enough
RDEPEND=">=dev-libs/libusb-1.0.18:1=
	dev-qt/qtcore:5=
	dev-qt/qtgui:5="
DEPEND="${RDEPEND}
	virtual/pkgconfig"


src_install() {
	dobin ${BUILD_DIR}/bin/heimdall
	dobin ${BUILD_DIR}/bin/heimdall-frontend
	udev_dorules heimdall/60-heimdall.rules
	dodoc Linux/README
}
