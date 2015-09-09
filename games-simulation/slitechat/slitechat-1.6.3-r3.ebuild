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

RDEPEND="net-dns/libidn"
DEPEND="${RDEPEND}
	dev-libs/boost"

PATCHES=( "${FILESDIR}"/slitechat-1.6.3-addr-temp.patch )

src_configure() {
	sed -i -e 's/GUI/SLiteChat/' SLiteChat/CMakeLists.txt
	# Remove extra include
	sed -i -e 's:include( FindBoost )::' cmake/Boost.cmake
	# Remove boost static requirment
	sed -i -e 's:set( Boost_USE_STATIC_LIBS ON )::' cmake/Boost.cmake
	# Remove outdated boost version requirment
	# NOTE: will fail to build with boost 1.48.0 due to a boost/Qt upstream bug.
	# TODO: figure out how to determine !1.48.0 and pass that to cmake boost find_package
	sed -i -e 's:1.34 ::' cmake/Boost.cmake
	mycmakeargs="-DSTANDALONE:BOOL=TRUE"
	append-flags "-I/usr/include/xmlrpc-epi"
	# gcc 4.7 exposes a bug in the upstream code.
	append-cflags $(test-flags-CC -fpermissive)
	append-cxxflags $(test-flags-CC -fpermissive)
	mycmakeargs="${mycmakeargs} -DGCC_DISABLE_FATAL_WARNINGS:BOOL=TRUE"
	# Overide and set build type to "Release" instead of "Gentoo"
	CMAKE_BUILD_TYPE="Release"
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	make_desktop_entry "${PN}" "${PN}"
}
