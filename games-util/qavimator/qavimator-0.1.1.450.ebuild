# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2017 Techwolf Lupindo

EAPI="6"

EHG_COMMIT="618c858c6764"
BITBUCKETNAME="QAvimator_Team/qavimator"

inherit cmake-utils webvcs

DESCRIPTION="QAvimator is a Qt port of Vince Invincible's avimator, a bvh animation editor, created for use in the 3D metaverse Second Life."
HOMEPAGE="http://www.qavimator.org/"
SLOT="0"
KEYWORDS="~x86 ~amd64"
DEPEND="dev-qt/qtwidgets"
LICENSE="GPL-2"

src_prepare() {
        sed -i -e 's:./data:/usr/share/qavimator/data:' "${S}/src/constants.cpp"
	default_src_prepare
}

src_configure() {
        local mycmakeargs=(
                -DINSTALL_BIN:STRING=bin
                -DINSTALL_DATA:STRING=/usr/share/qavimator
        )

        cmake-utils_src_configure
}

src_install() {
	HTML_DOCS="documentation"
	cmake-utils_src_install
	insinto "/usr/share/qavimator/examples"
	doins ${S}/examples/*
	doicon src/icons/qavimator.ico
	make_desktop_entry qavimator QAvimator qavimator.ico
}
