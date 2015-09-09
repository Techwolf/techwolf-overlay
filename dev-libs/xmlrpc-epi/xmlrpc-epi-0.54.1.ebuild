# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# This ebuild come from http://bugs.gentoo.org/show_bug.cgi?id=127026 - Update by Techwolf Lupindo

inherit autotools eutils flag-o-matic

DESCRIPTION="An implementation of the xmlrpc protocol in C"
HOMEPAGE="http://xmlrpc-epi.sourceforge.net/"
SRC_URI="mirror://sourceforge/xmlrpc-epi/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-devel/gettext"

S="${WORKDIR}/xmlrpc"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/xmlrpc-epi-0.51-secondlife.patch
	eautoreconf
}

src_compile() {
	econf --includedir="/usr/include/xmlrpc-epi" --program-prefix="xmlrpc-epi-"
	emake || die "Make failed!"
}


src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
