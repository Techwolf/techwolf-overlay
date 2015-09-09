# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils toolchain-funcs multilib subversion cmake-utils

DESCRIPTION="An open-source JPEG 2000 codec written in C"
HOMEPAGE="http://www.openjpeg.org/"

ESVN_REPO_URI="http://openjpeg.googlecode.com/svn/trunk/"

LICENSE="BSD-2"
SLOT="0"
#KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
KEYWORDS=""
IUSE="tools"

DEPEND="tools? ( >=media-libs/tiff-3.8.2 )"
RDEPEND=${DEPEND}

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	# fixes some crashes
	epatch "${FILESDIR}"/crashfix.patch
}

src_configure() {
	mycmakeargs="-DBUILD_SHARED_LIBS:BOOL=ON
		    $(cmake-utils_use tools BUILD_EXAMPLES)
		    -DINCLUDE_INSTALL_DIR:PATH=/usr/include"
	cmake-utils_src_configure
}