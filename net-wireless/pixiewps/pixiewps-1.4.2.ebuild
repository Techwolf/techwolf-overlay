# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2020 Techwolf Lupindo

EAPI="6"
EGIT_COMMIT="28f68e694bdf5774300a1451c970578de0e19ce0"
GITHUBNAME="wiire/pixiewps"

inherit webvcs

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
	if use openssl ; then
	  emake OPENSSL=1
	 else
	  emake
	fi
}

src_install() {
        default
        doman pixiewps.1
}
