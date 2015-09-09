# Copyright 2013 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit toolchain-funcs subversion qt4-r2

DESCRIPTION="QtWebKit is an HTML rendering library, which incorporates WebKit into Nokia's Qt."
HOMEPAGE="http://hg.secondlife.com/llqtwebkit/"



LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-qt/qtcore
	dev-qt/qtgui"
RDEPEND="${DEPEND}"

src_unpack() {
	# When using svc, S is the directory the checkout is copied into.
	# S="${WORKDIR}/${P}"
	ESVN_REPO_URI="http://aircrackgui-m4.googlecode.com/svn/trunk/"
	# ESVN_PROJECT="radegast"
	subversion_src_unpack

	S="${WORKDIR}/${P}/aircrack-ng-1.1-M4"
	ESVN_REPO_URI="http://aircrackgui-m4.googlecode.com/svn/aircrack-ng/"
	subversion_src_unpack

	S="${WORKDIR}/${P}"
}

src_prepare() {
	cd ${WORKDIR}/${P}/aircrack-ng-1.1-M4
	
	# copy missing files from the aircrack svn
	cp -r "${FILESDIR}/radiotap" "${WORKDIR}/${P}/aircrack-ng-1.1-M4/src/osdep"
	
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
	
	cd ${WORKDIR}/${P}
	sed -i -e "s:aircrack-ng-1.1-M4/:/usr/bin/aircrack-ng-1.1-M4/:g" DEFINES.h
	qt4-r2_src_prepare
}

src_configure() {
	qt4-r2_src_configure
	cd ${WORKDIR}/${P}/aircrack-ng-1.1-M4
	base_src_configure
}

src_compile() {
	cd ${WORKDIR}/${P}/aircrack-ng-1.1-M4
	emake \
		CC="$(tc-getCC)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		sqlite="false" \
		UNSTABLE="false"
		
	cd ${WORKDIR}/${P}
	qt4-r2_src_compile
}

src_install() {
	dobin aircrack-GUI
	exeinto /usr/bin/aircrack-ng-1.1-M4
	doexe aircrack-ng-1.1-M4/src/airodump-ng
	doexe aircrack-ng-1.1-M4/src/aireplay-ng
	doexe aircrack-ng-1.1-M4/src/aircrack-ng
}