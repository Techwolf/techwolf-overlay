# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# ebuild by Techwolf Lupindo

inherit eutils mercurial

DESCRIPTION="JSON (JavaScript Object Notation) is a lightweight data-interchange format. It can represents integer, real number, string, an ordered sequence of value, and a collection of name/value pairs. This is the Linden Lab clone of the project with Linden Lab mods"
HOMEPAGE="http://jsoncpp.sourceforge.net/"

EHG_REPO_URI="https://bitbucket.org/lindenlab/3p-jsoncpp"

LICENSE="public-domain"
SLOT="0"
# KEYWORDS=""
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-util/scons"

src_compile() {
	cd "${S}/jsoncpp-src-0.5.0"
	sed -i -e "s:CCFLAGS = \"-Wall -m32\", LINKFLAGS=\"-m32\":CCFLAGS = \"-Wall ${CFLAGS}\":" SConstruct || die "sed CFLAGS failed"
	sed -i -e "s:g++-4.1:g++:g" SConstruct || die "sed g++-4.1 failed"
	sed -i -e "s: = False: = True:" SConstruct || die "sed shared libs failed"
	scons platform=linux-gcc src/lib_json || die "scons failed!"
}

src_install() {
	# Install headers
	cd "${S}/jsoncpp-src-0.5.0"
	insinto /usr/include/jsoncpp
	doins include/json/*.h
	dolib.a buildscons/linux-gcc-*/src/lib_json/libjson_*libmt.a
	dolib.so buildscons/linux-gcc-*/src/lib_json/libjson_*libmt.so
}
