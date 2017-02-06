# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

DESCRIPTION="Reaver implements a brute force attack against Wifi Protected Setup (WPS)"
HOMEPAGE="https://github.com/t6x/reaver-wps-fork-t6x"
# SRC_URI="https://github.com/t6x/reaver-wps-fork-t6x/archive/v${PV}.zip"
SRC_URI="https://github.com/t6x/reaver-wps-fork-t6x/archive/b5b4b78a71c6fca5db1aed4791a3cecfd232ee24.zip"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RDEPEND="net-libs/libpcap
         dev-db/sqlite
         net-wireless/pixiewps"
DEPEND="${RDEPEND}"
# S="${WORKDIR}"/reaver-wps-fork-t6x-${PV}/src
S="${WORKDIR}/reaver-wps-fork-t6x-b5b4b78a71c6fca5db1aed4791a3cecfd232ee24/src"

src_prepare() {
        sed -i 's: $(CONFDIR): $(DESTDIR)$(CONFDIR):g' Makefile.in || die "sed Makefile failed"
        sed -i 's:@bindir@/: $(DESTDIR)@bindir@/:g' Makefile.in || die "sed Makefile failed"
        sed -i 's:$(CONFDIR); fi:$(CONFDIR); fi\n\t	if [ ! -d $(DESTDIR)@bindir@ ]; then mkdir -p $(DESTDIR)@bindir@; fi:' Makefile.in || die "sed Makefile failed"
}

src_compile() {
        #  Bug, have to run emake twice.
        nonfatal emake
        nonfatal emake
}
