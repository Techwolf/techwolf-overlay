# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

DESCRIPTION="Pixiewps is a tool written in C used to bruteforce offline the WPS pin exploiting the low or non-existing entropy of some APs (pixie dust attack)."
HOMEPAGE="https://github.com/wiire/pixiewps"
#SRC_URI="https://github.com/wiire/pixiewps/archive/v${PV}.zip"
SRC_URI="https://github.com/wiire/pixiewps/archive/fd62b81852c164cc29f0a555d19402ee001e41fa.zip"
RESTRICT="mirror"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

# S="${WORKDIR}"/pixiewps-${PV}/src
S="${WORKDIR}"/pixiewps-fd62b81852c164cc29f0a555d19402ee001e41fa/src


src_prepare() {
        sed -i 's:$(DESTDIR)$(BINDIR):$(BINDIR):' Makefile || die "sed Makefile failed"
}
