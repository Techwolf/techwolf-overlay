# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# ebuild by Techwolf Lupindo

EAPI="2"

inherit eutils mercurial qt4-r2

DESCRIPTION="QtWebKit is an HTML rendering library, which incorporates WebKit into Nokia's Qt."
HOMEPAGE="http://hg.secondlife.com/llqtwebkit/"
EHG_REPO_URI="https://bitbucket.org/lindenlab/3p-llqtwebkit"
EHG_REVISION="llqtwebkit"

LICENSE="GPL-2-with-Linden-Lab-FLOSS-exception"
SLOT="0"
KEYWORDS=""
# KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="x11-libs/qt-core
	x11-libs/qt-opengl
	x11-libs/qt-webkit"
RDEPEND="${DEPEND}"

S="${WORKDIR}/llqtwebkit"

src_unpack() {
	mercurial_src_unpack
}

src_configure() {
	# change from static to shared
	sed -i -e "s/ static / shared /" llqtwebkit.pro
	sed -i -e "s/ staticlib / sharedlib /" llqtwebkit.pro
	eqmake4 llqtwebkit.pro DEFINES+=VANILLA_QT
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	# Install header and libery
	cd "${S}"
	insinto /usr/include
	doins llqtwebkit.h
	dolib libllqtwebkit.so*
}