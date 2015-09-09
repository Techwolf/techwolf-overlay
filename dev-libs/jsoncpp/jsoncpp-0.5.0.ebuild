# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# ebuild by Techwolf Lupindo

inherit eutils

DESCRIPTION="JSON (JavaScript Object Notation) is a lightweight data-interchange format. It can represents integer, real number, string, an ordered sequence of value, and a collection of name/value pairs."
HOMEPAGE="http://jsoncpp.sourceforge.net/"
SRC_URI="mirror://sourceforge/jsoncpp/jsoncpp-src-${PV}.tar.gz"
RESTRICT="mirror"
LICENSE="public-domain"
SLOT="0"
# KEYWORDS=""
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-util/scons"

S="${WORKDIR}/jsoncpp-src-${PV}"

src_compile() {
	sed -i -e "s/CCFLAGS = \"-Wall\"/CCFLAGS = \"-Wall ${CFLAGS}\"/" SConstruct || die "sed CFLAGS failed"
	scons platform=linux-gcc src/lib_json || die "scons failed!"
}

src_install() {
	# Install headers
	insinto /usr/include/jsoncpp
	doins include/json/*.h
	dolib.a buildscons/linux-gcc-*/src/lib_json/libjson_*libmt.a
	dolib.so buildscons/linux-gcc-*/src/lib_json/libjson_*libmt.so
}
