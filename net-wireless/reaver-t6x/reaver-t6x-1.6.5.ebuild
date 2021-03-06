# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2017 Techwolf Lupindo

EAPI="6"
EGIT_COMMIT="a3b25763fec8b38f4baaac34fd289a759189ee14"
GITHUBNAME="t6x/reaver-wps-fork-t6x"

inherit webvcs

DESCRIPTION="Reaver implements a brute force attack against Wifi Protected Setup (WPS)"
HOMEPAGE="https://github.com/t6x/reaver-wps-fork-t6x"

LICENSE="GPL-2"
SLOT="0"
# KEYWORDS="~x86 ~amd64"
# masked untill upstream ports all the features from there old branch

RDEPEND="net-libs/libpcap
         dev-db/sqlite
         net-wireless/pixiewps"
DEPEND="${RDEPEND}"

S="${S}/src"

src_prepare() {
        # fix double lib/lib path.
        sed -i 's:CONFDIR=@localstatedir@/lib/@target@:CONFDIR=@localstatedir@/@target@:' config.mak.in || die "sed Makefile failed"
        
        # required for EAPI 6
        eapply_user
}
