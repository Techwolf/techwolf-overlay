# Copyright 1999-2007 Gentoo Foundation
# Copyright 2012-2017 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit eutils

DESCRIPTION="Linden Lab fork of jsoncpp from sourceforge"
HOMEPAGE="https://bitbucket.org/lindenlab/3p-jsoncpp"

SRC_URI="https://bitbucket.org/lindenlab/3p-jsoncpp/get/5dce1c1d278d.tar.bz2"
RESTRICT="mirror"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-util/scons"

S="${WORKDIR}/lindenlab-3p-jsoncpp-5dce1c1d278d"

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
