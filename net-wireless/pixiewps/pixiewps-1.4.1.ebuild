# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2018 Techwolf Lupindo

EAPI="6"
EGIT_COMMIT="d6e760af7b2371e9458f04dec6d95e9b207fbf8b"
GITHUBNAME="wiire/pixiewps"

inherit webvcs

DESCRIPTION="Pixiewps is a tool written in C used to bruteforce offline the WPS pin exploiting the low or non-existing entropy of some APs (pixie dust attack)."
HOMEPAGE="https://github.com/wiire/pixiewps"

LICENSE="GPL-3+"
SLOT="0"
IUSE="openssl"
KEYWORDS="~x86 ~amd64"

RDEPEND="openssl? ( dev-libs/openssl )"

S="${S}/src"

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
        doman ../pixiewps.1
}
