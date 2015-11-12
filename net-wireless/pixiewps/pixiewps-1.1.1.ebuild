# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

DESCRIPTION="Pixiewps is a tool written in C used to bruteforce offline the WPS pin exploiting the low or non-existing entropy of some APs (pixie dust attack)."
HOMEPAGE="https://github.com/wiire/pixiewps"
SRC_URI="https://github.com/wiire/pixiewps/archive/08a78c3c2712523d9106c3a20e31c081dabe558a.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RDEPEND="dev-libs/openssl"
DEPEND="${RDEPEND}"
S="${WORKDIR}"/pixiewps-08a78c3c2712523d9106c3a20e31c081dabe558a/src


src_prepare() {
        sed -i 's:install $(TARGET) $(BINDIR)/$(TARGET):install -d $(BINDIR):' Makefile || die "sed Makefile failed"
}
