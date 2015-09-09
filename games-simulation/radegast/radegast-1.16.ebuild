# Copyright 2009 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils mono games

DESCRIPTION="Lightweight client for connecting to Second Life and OpenSim based virtual worlds."
HOMEPAGE="http://radegastclient.org/"
SRC_URI="http://radegast.googlecode.com/files/${P}-src.zip"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="dev-lang/mono"
DEPEND="${RDEPEND}
	dev-dotnet/nant"

src_unpack() {
	unpack ${A}
	S="${WORKDIR}/${P}-src"
}

src_compile() {
	cd radegast || die "Failed to cd into radegast"
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
	doins bin/*.html || die
	insinto "${GAMES_DATADIR}/${PN}/aiml"
	doins bin/aiml/*.aiml || die
	insinto "${GAMES_DATADIR}/${PN}/aiml_config"
	doins bin/aiml_config/*.xml || die

	# gentoo specific stuff
	games_make_wrapper "${PN}" "mono ./Radegast.exe" "${GAMES_DATADIR}/${PN}"
	# todo: insert/install an icon here when upstream makes one.
	make_desktop_entry "${PN}" "${PN}"
	prepgamesdirs
}
