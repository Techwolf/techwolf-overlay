# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2017 Techwolf Lupindo

EAPI="6"
EGIT_COMMIT="3c8daf98dfd34372dfbe480ab3eef1b59a2b014a"
GITHUBNAME="wiire/pixiewps"

inherit webvcs

DESCRIPTION="Pixiewps is a tool written in C used to bruteforce offline the WPS pin exploiting the low or non-existing entropy of some APs (pixie dust attack)."
HOMEPAGE="https://github.com/wiire/pixiewps"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~x86 ~amd64"

S="${S}/src"

src_install() {
        default
        doman ../pixiewps.1
}
