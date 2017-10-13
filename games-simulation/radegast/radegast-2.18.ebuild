# Copyright 2009-2017 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils mono

DESCRIPTION="Lightweight client for connecting to Second Life and OpenSim based virtual worlds."
HOMEPAGE="http://radegast.org/wp/"
SRC_URI="https://github.com/radegastdev/radegast/archive/2.18.zip -> ${P}.zip
         https://github.com/openmetaversefoundation/libopenmetaverse/archive/0.9.3.zip -> libopenmetaverse-0.9.3.zip"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="dev-lang/mono
	dev-dotnet/libgdiplus[cairo]"
DEPEND="${RDEPEND}"

src_prepare() {
        mv "${WORKDIR}/libopenmetaverse-0.9.3" "${WORKDIR}/${P}"
        rmdir "${WORKDIR}/${P}/libopenmetaverse"
        mv "${WORKDIR}/${P}/libopenmetaverse-0.9.3" "${WORKDIR}/${P}/libopenmetaverse"
        default_src_prepare
}

src_compile() {
        mono Radegast/prebuild.exe /target vs2010 /exclude plug_speech
        xbuild Radegast.sln
}

src_install() {
        insinto "/usr/share/radegast/"
	doins -r bin/*

	make_wrapper "${PN}" "mono /usr/share/radegast/Radegast.exe" "/usr/share/radegast"
	# todo: insert/install an icon here when upstream makes one.
	make_desktop_entry "${PN}" "${PN}"
}
