# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="The world’s leading JPEG2000 software development toolkit"
HOMEPAGE="http://kakadusoftware.com/"

SRC_URI="KDUv6_4_1-01149L.zip"
RESTRICT="fetch"

LICENSE="no-source-code"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=${DEPEND}

S="${WORKDIR}/v6_4_1-01149L"

src_prepare() {
	# static build
	sed -i -e 's:# KDU_GLIBS:KDU_GLIBS:' "${S}/coresys/make/Makefile-Linux-x86-32-gcc"
	sed -i -e 's:# KDU_GLIBS:KDU_GLIBS:' "${S}/coresys/make/Makefile-Linux-x86-64-gcc"
}

src_compile() {
	cd "${S}/coresys/make"
	if use amd64 ; then
          emake -f Makefile-Linux-x86-64-gcc libkdu.a || die "emake failed"
        else
          emake -f Makefile-Linux-x86-32-gcc libkdu.a || die "emake failed"
        fi
}

src_install() {
	# Install headers
	cd "${S}/coresys"
	insinto /usr/include/kdu
	doins common/*.h
	cd "${S}/apps"
	doins image/*.h
	doins compressed_io/*.h
	# Install the libary
	dolib.a ${S}/lib/Linux-x86-*-gcc/libkdu.a
}