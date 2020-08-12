# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2020 Techwolf Lupindo

EAPI="6"
EGIT_COMMIT="a6b3fa514c0c9a6ad5dc931040218451c64ce150"
GITHUBNAME="wiire/pixiewps"

inherit flag-o-matic webvcs

DESCRIPTION="Pixiewps is a tool written in C used to bruteforce offline the WPS pin exploiting the low or non-existing entropy of some APs (pixie dust attack)."
HOMEPAGE="https://github.com/wiire/pixiewps"

LICENSE="GPL-3+"
SLOT="0"
IUSE="openssl"
KEYWORDS="~x86 ~amd64"

RDEPEND="openssl? ( dev-libs/openssl )"



src_prepare() {
        sed -i 's:/usr/local:/usr:' Makefile || die "sed Makefile failed"
        eapply_user
}

src_compile() {
	append-cppflags '-DPIXIE_BIN=\"pixie-core\"'
	if use openssl ; then
	  emake OPENSSL=1
	 else
	  emake
	fi
}

src_install() {
        newbin pixiewps pixie-core
	newbin pixiewrapper pixiewps
	einstalldocs
        doman pixiewps.1
}
