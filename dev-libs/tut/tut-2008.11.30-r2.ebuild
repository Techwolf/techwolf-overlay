# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# ebuild by Techwolf Lupindo

inherit autotools eutils

DESCRIPTION="TUT is a small and portable unit test framework for C++"
HOMEPAGE="http://tut-framework.sourceforge.net/"
SRC_URI="mirror://sourceforge/tut-framework/TUT-2008-11-30.tar.gz "
RESTRICT="mirror"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""

src_unpack() {
    unpack ${A}
    cd "${WORKDIR}/tut-2008-11-30/tut"
    epatch "${FILESDIR}/skip_test.patch"
}

src_install() {
	S="${WORKDIR}/tut-2008-11-30"
	# Install headers
	cd "${S}"
	insinto /usr/include/
	doins tut*.h
	insinto /usr/include/tut
	doins tut/*.hpp
}
