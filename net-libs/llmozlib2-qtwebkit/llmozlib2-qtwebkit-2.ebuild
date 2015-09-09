# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# ebuild by Techwolf Lupindo

EAPI="2"
inherit git-2 qt4-r2

DESCRIPTION="llmozlib2 version using qt instead of xulrunner (used as dependency for Second Life)"
HOMEPAGE="http://omvviewer.byteme.org.uk/mozlib-webkit.shtml"

EGIT_REPO_URI="http://git.byteme.org.uk/mozlibqt.git/"

LICENSE="GPL-2-with-Linden-Lab-FLOSS-exception"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-db/sqlite
	x11-libs/qt-webkit"
DEPEND="${RDEPEND}"

S="${WORKDIR}/llmozlib2"

src_unpack() {
	git-2_src_unpack
}

src_configure() {
	cd "${S}/llmozlib2"
	# remove some features that require patches upsteam to the Qt package itself.
	sed -i -e "s/authenticator->tryAgainLater/\/\/ authenticator->tryAgainLater/g" llnetworkaccessmanager.cpp
	sed -i -e "s/#define WEBHISTORYPATCH/#undef WEBHISTORYPATCH/" llembeddedbrowserwindow.cpp
	# change from static to shared
	sed -i -e "s/CONFIG += static/CONFIG += shared/" llmozlib2.pro || die "Problem in removing static build option"
	sed -i -e "s/Q_IMPORT_PLUGIN/\/\/Q_IMPORT_PLUGIN/" llembeddedbrowserwindow.cpp || die "Problem in removing Q_IMPORT_PLUGIN build option"
	# fix a path issue
	echo "QMAKE_LFLAGS_SHLIB *= \"--rpath=/usr/lib/qt4/plugins/imageformats\"" >> llmozlib2.pri
	eqmake4 llmozlib2.pro 
}

src_compile() {
	cd "${S}/llmozlib2"
	emake || die "emake failed"
}

src_install() {
	cd "${S}/llmozlib2"
	insinto /usr/include
	doins llmozlib2.h
	dolib libllmozlib2.so*
}

