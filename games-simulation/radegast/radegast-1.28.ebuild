# Copyright 2009-2017 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils mono games

DESCRIPTION="Lightweight client for connecting to Second Life and OpenSim based virtual worlds."
HOMEPAGE="https://code.google.com/archive/p/radegast/"
SRC_URI="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/radegast/radegast-1.28-src.zip"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="dev-lang/mono
	dev-dotnet/libgdiplus[cairo]"
DEPEND="${RDEPEND}
	dev-util/nant"

src_unpack() {
	unpack ${A}
	S="${WORKDIR}/${P}-source"
}

src_compile() {
	cd radegast || die "Failed to cd into radegast"
	chmod +x ./runprebuild.sh || die "chmod failed"
	./runprebuild.sh  || die "Prebuild failed"
	nant Release build
}

src_install() {
	cd "${S}/radegast"
	exeinto "${GAMES_DATADIR}/${PN}"
	doexe bin/Radegast.exe || die
	doexe bin/*.so || die
	insinto "${GAMES_DATADIR}/${PN}"
	doins bin/*.dll || die
	doins bin/*.wav || die
	doins bin/*.config || die
	doins bin/*.dylib || die
	doins bin/*.XML || die
	doins bin/*.xml || die
	# doins bin/*.html || die
	insinto "${GAMES_DATADIR}/${PN}/aiml"
	doins bin/aiml/*.aiml || die
	insinto "${GAMES_DATADIR}/${PN}/aiml_config"
	doins bin/aiml_config/*.xml || die
	insinto "${GAMES_DATADIR}/${PN}/openmetaverse_data"
	doins bin/openmetaverse_data/*.xml || die
	doins bin/openmetaverse_data/*.tga || die

	# gentoo specific stuff
	games_make_wrapper "${PN}" "mono ./Radegast.exe" "${GAMES_DATADIR}/${PN}"
	# todo: insert/install an icon here when upstream makes one.
	make_desktop_entry "${PN}" "${PN}"
	prepgamesdirs
}
