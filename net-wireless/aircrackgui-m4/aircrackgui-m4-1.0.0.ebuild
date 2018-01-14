# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2018 Techwolf Lupindo

EAPI="6"

inherit qmake-utils epatch

DESCRIPTION="The ultimate GUI for aircrack-ng and wireless tools"
HOMEPAGE="https://code.google.com/archive/p/aircrackgui-m4/"
SRC_URI="https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/aircrackgui-m4/source-archive.zip -> ${P}.zip"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-qt/qtcore
	dev-qt/qtgui"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}/trunk

src_prepare() {
	cd "${WORKDIR}"/${PN}/aircrack-ng
	rm -r .svn
	mv * "${S}"/aircrack-ng-1.1-M4
	cd "${S}"/aircrack-ng-1.1-M4
	
	# copy missing files from the aircrack svn
	cp -r "${FILESDIR}/radiotap" "${S}/aircrack-ng-1.1-M4/src/osdep"

	epatch "${FILESDIR}/aircrack-ng-1.0_rc4-fix_build.patch"
	epatch "${FILESDIR}/aircrack-ng-1.1-parallelmake.patch"
	epatch "${FILESDIR}/aircrack-ng-1.1-sse-pic.patch"
	epatch "${FILESDIR}/aircrack-ng-1.1-CVE-2010-1159.patch"
	epatch "${FILESDIR}/aircrack-ng-1.1-respect_LDFLAGS.patch"
	epatch "${FILESDIR}"/diff-wpa-migration-mode-aircrack-ng.diff
	epatch "${FILESDIR}"/ignore-channel-1-error.patch
	epatch "${FILESDIR}"/airodump-ng.ignore-negative-one.v4.patch
	epatch "${FILESDIR}"/changeset_r1921_backport.diff

	#likely to stay after version bump
	epatch "${FILESDIR}"/airodump-ng-oui-update-path-fix.patch
	
	cd ${S}
	sed -i -e "s:aircrack-ng-1.1-M4/:/usr/bin/aircrack-ng-1.1-M4/:g" DEFINES.h
	# qt5 support
	eapply "${FILESDIR}"/qt5.patch
	
	eapply_user
}

src_configure() {
	eqmake5 "aircrack GUI.pro"
}

src_compile() {
	cd ${S}/aircrack-ng-1.1-M4
	emake \
		CC="$(tc-getCC)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		sqlite="false" \
		UNSTABLE="false"
		
	cd ${S}
	emake
}

src_install() {
	dobin aircrack-GUI
	exeinto /usr/bin/aircrack-ng-1.1-M4
	doexe aircrack-ng-1.1-M4/src/airodump-ng
	doexe aircrack-ng-1.1-M4/src/aireplay-ng
	doexe aircrack-ng-1.1-M4/src/aircrack-ng
}
