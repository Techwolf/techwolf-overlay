# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# ebuild by Techwolf Lupindo

inherit autotools eutils subversion

DESCRIPTION="TUT is a small and portable unit test framework for C++"
HOMEPAGE="http://tut-framework.sourceforge.net/"
ESVN_REPO_URI="https://tut-framework.svn.sourceforge.net/svnroot/tut-framework"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""

# src_compile() {
#     # there is no compiling, so just add a patch here
#     # to remain at EAPT 1
#     cd "${S}/trunk/include/tut"
#     epatch "${FILESDIR}/skip_test.patch"
# }

src_install() {
	# Install headers
	cd "${S}/trunk/include"
	insinto /usr/include/
	doins tut*.h
	insinto /usr/include/tut
	doins tut/*.hpp
}
