# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit cmake-utils

DESCRIPTION="A Lite IM/Chat Client for Second Life"
HOMEPAGE="http://slitechat.dooglio.net/"
SRC_URI="http://files.slitechat.org/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# KEYWORDS=""

IUSE=""

RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-libs/boost"

src_configure() {
	mycmakeargs="-DSTANDALONE:BOOL=TRUE"
	append-flags "-I/usr/include/xmlrpc-epi"
	mycmakeargs="${mycmakeargs} -DGCC_DISABLE_FATAL_WARNINGS:BOOL=TRUE"
	# Overide and set build type to "Release" instead of "Gentoo"
	CMAKE_BUILD_TYPE="Release"
	cmake-utils_src_configure
}

src_compile() {
	# CMAKE_VERBOSE=on
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	make_desktop_entry "${PN}" "${PN}"
}
