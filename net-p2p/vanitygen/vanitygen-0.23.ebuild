# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="Standalone command line vanity address generator."
HOMEPAGE="https://github.com/WyseNynja/vanitygen"
SRC_URI="https://github.com/WyseNynja/vanitygen/archive/deb9c734d7742e5b0c39189e569376ae117abad9.zip -> ${P}.zip"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="opencl "

DEPEND="dev-libs/openssl[-bindist]
        dev-libs/libpcre"
RDEPEND="${DEPEND}"

S="${WORKDIR}/vanitygen-deb9c734d7742e5b0c39189e569376ae117abad9"

src_prepare() {
	: # epatch "${FILESDIR}/respect-cflags.patch"
}

src_compile() {
	emake vanitygen keyconv || die "emake failed"
	use opencl && emake oclvanitygen oclvanityminer
}

src_install() {
	dobin vanitygen || die
	dobin keyconv || die

	if use opencl ; then
		dobin oclvanitygen || die
		dobin oclvanityminer || die
		dobin calc_addrs.cl || die
	fi

	dodoc README CHANGELOG || die
}
