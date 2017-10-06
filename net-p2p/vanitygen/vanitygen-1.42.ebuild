# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2017 Techwolf Lupindo

EAPI=6
EGIT_COMMIT="4ca34d47a78e0dab4413cfdbc6dcf431a96ed413"
GITHUBNAME="exploitagency/vanitygen-plus"

inherit webvcs

DESCRIPTION="Vanitygen PLUS! Generate vanity address for 90+ cryptocoins"
HOMEPAGE="https://github.com/exploitagency/vanitygen-plus"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="opencl "

DEPEND="dev-libs/openssl[-bindist]
        dev-libs/libpcre
        opencl? ( virtual/opencl )"
RDEPEND="${DEPEND}"


src_compile() {
	emake vanitygen keyconv
	use opencl && emake oclvanitygen oclvanityminer
}

src_install() {
	dobin vanitygen
	dobin keyconv

	if use opencl ; then
		dobin oclvanitygen
		dobin oclvanityminer
		dobin calc_addrs.cl
	fi

	einstalldocs
}
