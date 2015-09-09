# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit subversion qt4-r2 cmake-utils

DESCRIPTION="QAvimator is a Qt port of Vince Invincible's avimator, a bvh animation editor, created for use in the 3D metaverse Second Life."
HOMEPAGE="http://www.qavimator.org/"
SLOT="0"
KEYWORDS="~x86 ~amd64"
DEPEND="x11-libs/qt-core
	x11-libs/qt-opengl"
LICENSE="GPL-2"

ESVN_REPO_URI="https://qavimator.svn.sourceforge.net/svnroot/qavimator"

src_unpack() {
	subversion_src_unpack
}

src_compile() {
	mycmakeargs="-DINSTALL_BIN:STRING=bin -DINSTALL_DATA:STRING=/usr/share/qavimator -DINSTALL_DATA_PATH:STRING=/usr/share/qavimator"
	cmake-utils_src_compile
}

src_install() {
	HTML_DOCS="documentation"
	cmake-utils_src_install
	dodoc "${S}/TODO"
	insinto "/usr/share/doc/${PF}"
	doins ${S}/examples/*
}

