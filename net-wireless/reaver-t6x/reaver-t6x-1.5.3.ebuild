# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2017 Techwolf Lupindo

EAPI="6"
EGIT_COMMIT="6cfd96e997f2a6eda17bef2216282e801c6fdad7"
GITHUBNAME="t6x/reaver-wps-fork-t6x"

inherit webvcs

DESCRIPTION="Reaver implements a brute force attack against Wifi Protected Setup (WPS)"
HOMEPAGE="https://github.com/t6x/reaver-wps-fork-t6x"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

RDEPEND="net-libs/libpcap
         dev-db/sqlite
         net-wireless/pixiewps"
DEPEND="${RDEPEND}"

S="${S}/src"

src_prepare() {
        # move to /var instead of /etc. This was done upstream in there new branch.
        sed -i 's:CONFDIR=@sysconfdir@/@target@:CONFDIR=@localstatedir@/@target@:' Makefile.in || die "sed Makefile failed"
        
        # required for EAPI 6
        eapply_user
}

src_compile() {
        # Bug in parralles builds. Errors out due to imporper build sequence.
        emake -j1
}
