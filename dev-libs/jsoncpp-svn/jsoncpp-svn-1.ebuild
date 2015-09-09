# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# ebuild by Techwolf Lupindo

inherit eutils subversion

DESCRIPTION="JSON (JavaScript Object Notation) is a lightweight data-interchange format. It can represents integer, real number, string, an ordered sequence of value, and a collection of name/value pairs."
HOMEPAGE="http://jsoncpp.sourceforge.net/"
ESVN_REPO_URI="https://jsoncpp.svn.sourceforge.net/svnroot/jsoncpp/trunk"

LICENSE="public-domain"
SLOT="0"
# KEYWORDS=""
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-util/scons"

src_compile() {
	cd "${S}/jsoncpp"
	sed -i -e "s/CCFLAGS = \"-Wall\"/CCFLAGS = \"-Wall ${CFLAGS}\"/" SConstruct || die "sed CFLAGS failed"
	scons platform=linux-gcc src/lib_json || die "scons failed!"
}

src_install() {
	# Install headers
	cd "${S}/jsoncpp"
	insinto /usr/include/jsoncpp
	doins include/json/*.h
	dolib.a buildscons/linux-gcc-*/src/lib_json/libjson_*libmt.a
	dolib.so buildscons/linux-gcc-*/src/lib_json/libjson_*libmt.so
}
