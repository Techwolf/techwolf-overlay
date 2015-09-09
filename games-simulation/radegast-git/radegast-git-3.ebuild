# Copyright 2009 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils mono games git-2

DESCRIPTION="Lightweight client for connecting to Second Life and OpenSim based virtual worlds."
HOMEPAGE="http://radegastclient.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror"

RDEPEND="dev-lang/mono
	dev-dotnet/libgdiplus[cairo]"
DEPEND="${RDEPEND}
	dev-dotnet/nant"

src_unpack() {
	# When using svc, S is the directory the checkout is copied into.
	# Set it so it matches the wiki build instrucktions.
	S="${WORKDIR}/radegast"
	EGIT_REPO_URI="https://github.com/radegastdev/radegast.git"
	git-2_src_unpack

	S="${WORKDIR}/libopenmetaverse"
	EGIT_REPO_URI="https://github.com/radegastdev/libopenmetaverse.git"
	unset EGIT_SOURCEDIR
	git-2_src_unpack

	S="${WORKDIR}"
}

src_compile() {
	cd radegast || die "Failed to cd into radegast"
	./runprebuild.sh build || die "Prebuild failed"
}

src_install() {
	cd "${S}/radegast"
	exeinto "${GAMES_DATADIR}/${PN}"
	doexe bin/Radegast.exe || die
	doexe bin/*.so || die
	insinto "${GAMES_DATADIR}/${PN}"
	doins bin/*.dll || die

	doins bin/*.config || die
	doins bin/*.dylib || die

	doins bin/*.xml || die
	doins bin/*.mdb
	insinto "${GAMES_DATADIR}/${PN}/aiml"
	doins bin/aiml/*.aiml || die
	insinto "${GAMES_DATADIR}/${PN}/aiml_config"
	doins bin/aiml_config/*.xml || die
	insinto "${GAMES_DATADIR}/${PN}/openmetaverse_data"
	doins bin/openmetaverse_data/*.xml || die
	doins bin/openmetaverse_data/*.tga || die
	insinto "${GAMES_DATADIR}/${PN}/openmetaverse_data/static_assets"
	doins bin/openmetaverse_data/static_assets/*-*-*-*-* || die
	insinto "${GAMES_DATADIR}/${PN}/character"
	doins bin/character/*.llm || die
	doins bin/character/*.xml || die
	insinto "${GAMES_DATADIR}/${PN}/shader_data"
	doins bin/shader_data/*.png || die
	doins bin/shader_data/*.frag || die
	doins bin/shader_data/*.vert || die

	# gentoo specific stuff
	games_make_wrapper "radegast-git" "mono ./Radegast.exe" "${GAMES_DATADIR}/${PN}"
	# todo: insert/install an icon here when upstream makes one.
	make_desktop_entry "radegast-git" "radegast-git"
	prepgamesdirs
}
