# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# This ebuild come from http://bugs.gentoo.org/show_bug.cgi?id=127026 - The site http://gentoo.zugaina.org/ only host a copy.

inherit autotools eutils

DESCRIPTION="An implementation of the xmlrpc protocol in C"
HOMEPAGE="http://xmlrpc-epi.sourceforge.net/"
SRC_URI="mirror://sourceforge/xmlrpc-epi/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="samples"

DEPEND="sys-devel/gettext"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-64bit-fixes.patch
	epatch "${FILESDIR}"/${P}-gcc4.patch
	epatch "${FILESDIR}"/${P}-expat.patch
	epatch "${FILESDIR}"/${P}-secondlife.patch

	# Rename library to libxmlrpc-epi
	for file in "src/Makefile.am" "sample/Makefile.am" ; do
		sed -i 's/libxmlrpc\.la/libxmlrpc-epi.la/g ; s/libxmlrpc_la/libxmlrpc_epi_la/g' $file
	done

	eautoreconf
}

src_install() {
	dolib src/.libs/libxmlrpc-epi.so.0.0.3
	dolib src/.libs/libxmlrpc-epi.a

	# Install headers
	insinto /usr/include/xmlrpc-epi/
	for file in base64.h encodings.h queue.h simplestring.h xml_element.h \
	xml_to_xmlrpc.h xmlrpc.h xmlrpc_introspection.h ; do
		doins "src/${file}"
	done

	# Install samples, prepending xmlrpc-epi-
	if use samples ; then
		insinto /usr/bin/

		for file in sample/* ; do
			if [ -x "${file}" ] ; then
				newbin "${file}" xmlrpc-epi-`basename "${file}"`
			fi
		done
	fi
}
