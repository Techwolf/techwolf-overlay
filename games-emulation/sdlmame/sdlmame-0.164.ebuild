# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )
inherit eutils games python-any-r1

MY_PV="${PV/.}"

DESCRIPTION="Multiple Arcade Machine Emulator + Multi Emulator Super System (MESS)"
HOMEPAGE="http://mamedev.org/"
SRC_URI="https://github.com/mamedev/mame/releases/download/mame${MY_PV}/mame${MY_PV}s.zip -> mame-${PV}.zip"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="X alsa +arcade debug +mess opengl softlists tools"
REQUIRED_USE="|| ( arcade mess )
		debug? ( X )"
# MESS (games-emulation/sdlmess) has been merged into MAME upstream since mame-0.162 (see below) #
#  MAME/MESS build combined (default)	+arcade +mess	(mame)
#  MAME build only			+arcade -mess	(mamearcade)
#  MESS build only			-arcade +mess	(mess)

# games-emulation/sdlmametools is dropped and enabled instead by the 'tools' useflag #
DEPEND="!games-emulation/sdlmametools
	!games-emulation/sdlmess
	app-arch/unzip
	dev-db/sqlite:3
	dev-libs/expat
	media-libs/fontconfig
	media-libs/flac
	media-libs/libsdl2[sound,joystick,opengl?,video]
	media-libs/portaudio
	media-libs/sdl2-ttf
	sys-libs/zlib
	virtual/jpeg
	virtual/pkgconfig
	alsa? ( media-libs/alsa-lib
		media-libs/portmidi )
	debug? ( dev-qt/qtcore:4
		dev-qt/qtgui:4 )
	X? ( x11-libs/libX11
		x11-libs/libXinerama
		x11-proto/xineramaproto )
	${PYTHON_DEPS}"

S="${WORKDIR}"

pkg_setup() {
	games_pkg_setup
	python-any-r1_pkg_setup
}

src_unpack() {
	default
	unpack ./mame.zip
	rm -f mame.zip
}

src_compile() {
	# Workaround conflicting $ARCH variable used by both Gentoo's portage and by Mame's source build #
	#	by saving $ARCH off for compile then re-setting it #
	#	Example error:
	#		'gcc: error: amd64: No such file or directory'
	GENTOO_ARCH="${ARCH}"
	unset ARCH

	local myconf
	if use alsa; then
		myconf="${myconf} USE_SYSTEM_LIB_PORTMIDI=1"
	else
		myconf="${myconf} NO_USE_MIDI=1"
	fi

	# Disable using bundled libraries where possible #
	#  Use bundled lua to ensure correct compilation (ref. b.g.o #407091) #
	#  Disable warnings being treated as errors and enable verbose build output #
	#  Turn off BGFX being used (ref. b.g.o #556642) #
	myconf="${myconf}
		USE_SYSTEM_LIB_EXPAT=1
		USE_SYSTEM_LIB_FLAC=1
		USE_SYSTEM_LIB_JPEG=1
		USE_SYSTEM_LIB_LUA=
		USE_SYSTEM_LIB_PORTAUDIO=1
		USE_SYSTEM_LIB_SQLITE3=1
		USE_SYSTEM_LIB_ZLIB=1
		NOWERROR=1
		VERBOSE=1
		USE_BGFX=
		PTR64=$(usex amd64 "1" "")
		USE_QTDEBUG=$(usex debug "1" "")
		BIGENDIAN=$(usex ppc "1" "")
		TOOLS=$(usex tools "1" "")
		NO_OPENGL=$(usex opengl "" "1")
		NO_X11=$(usex X "" "1")
		SDL_INI_PATH="\$\$\$\$HOME/.sdlmame\;${GAMES_SYSCONFDIR}/${PN}"
	"
	use arcade && ! use mess && \
		local targetargs="SUBTARGET=arcade"
	! use arcade && use mess && \
		local targetargs="SUBTARGET=mess"

	emake ${myconf} \
		${targetargs}

	use tools && \
		emake ${myconf} -j1 TARGET=ldplayer

	ARCH="${GENTOO_ARCH}"
}

src_install() {
	if use arcade && use mess; then
		MAMEBIN="mame$(use amd64 && echo 64)$(use debug && echo d)"
		dogamesbin "${MAMEBIN}"
		dosym "${GAMES_BINDIR}/${MAMEBIN}" "${GAMES_BINDIR}/${PN}"
		dosym "${GAMES_BINDIR}/${PN}" "${GAMES_BINDIR}/mess$(use amd64 && echo 64)$(use debug && echo d)"
		dosym "${GAMES_BINDIR}/${PN}" "${GAMES_BINDIR}/sdlmess"
		newman src/osd/sdl/man/mame.6 ${PN}.6
		newman src/osd/sdl/man/mess.6 sdlmess.6
		doman src/osd/sdl/man/mame.6
		doman src/osd/sdl/man/mess.6
	elif use arcade && ! use mess; then
		MAMEBIN="mamearcade$(use amd64 && echo 64)$(use debug && echo d)"
		dogamesbin "${MAMEBIN}"
		dosym "${GAMES_BINDIR}/${MAMEBIN}" "${GAMES_BINDIR}/${PN}"
		newman src/osd/sdl/man/mame.6 ${PN}.6
		doman src/osd/sdl/man/mame.6
	elif ! use arcade && use mess; then
		MAMEBIN="mess$(use amd64 && echo 64)$(use debug && echo d)"
		dogamesbin "${MAMEBIN}"
		dosym "${GAMES_BINDIR}/${MAMEBIN}" "${GAMES_BINDIR}/${PN}"
		dosym "${GAMES_BINDIR}/${PN}" "${GAMES_BINDIR}/sdlmess"
		newman src/osd/sdl/man/mess.6 ${PN}.6
		newman src/osd/sdl/man/mess.6 sdlmess.6
		doman src/osd/sdl/man/mess.6
	fi

	insinto "${GAMES_DATADIR}/${PN}"
	doins -r src/osd/sdl/keymaps

	# Create default mame.ini and inject Gentoo settings into it #
	#  Note that '~' does not work and '$HOME' must be used #
		"${ED}${GAMES_BINDIR}/${MAMEBIN}" -noreadconfig -showconfig > "${T}/mame.ini" || \
			die "Unable to create ${GAMES_SYSCONFDIR}/${PN}/mame.ini"
		# -- Paths -- #
		for each in {rom,hash,sample,art,font,crosshair}; do
			sed -e "s:\(${each}path\)[ \t]*\(.*\):\1 \t\t\$HOME/.${PN}/\2;${GAMES_DATADIR}/${PN}/\2:" \
				-i "${T}/mame.ini"
		done
		for each in {ctrlr,cheat}; do
			sed -e "s:\(${each}path\)[ \t]*\(.*\):\1 \t\t\$HOME/.${PN}/\2;${GAMES_SYSCONFDIR}/${PN}/\2;${GAMES_DATADIR}/${PN}/\2:" \
				-i "${T}/mame.ini"
		done
		# -- Directories -- #
		for each in {cfg,nvram,memcard,input,state,snapshot,diff,commit}; do
			sed -e "s:\(${each}_directory\)[ \t]*\(.*\):\1 \t\t\$HOME/.${PN}/\2:" \
				-i "${T}/mame.ini"
		done
		# -- Keymaps -- #
		sed -e "s:\(keymap_file\)[ \t]*\(.*\):\1 \t\t\$HOME/.${PN}/\2:" \
			-i "${T}/mame.ini"
		for each in $(ls -1r ${ED}${GAMES_DATADIR}/${PN}/keymaps/km*.txt | awk -F/ '{print $NF}'); do
			sed "/^keymap_file/a \#keymap_file \t\t${GAMES_DATADIR}/${PN}/keymaps/${each}" \
				-i "${T}/mame.ini"
		done
	insinto "${GAMES_SYSCONFDIR}/${PN}"
	doins "${T}/mame.ini"

	# Create vector.ini #
        cat - > "${T}/vector.ini" <<EOF
#
# Specific options file for vector games (overrides mame.ini settings)
#

#
# VIDEO OPTIONS
#
video               soft
yuvmode             yv12
EOF
	insinto "${GAMES_SYSCONFDIR}/${PN}"
	doins "${T}/vector.ini"

	if use mess && use softlists; then
		insinto "${GAMES_DATADIR}/${PN}"
		doins -r hash
	fi

	dodoc docs/{config,mame,newvideo}.txt
	keepdir "${GAMES_DATADIR}/${PN}"/{ctrlr,cheats,roms,hash,samples,artwork,crosshair} \
		"${GAMES_SYSCONFDIR}/${PN}"/{ctrlr,cheats}

	if use tools; then
		for i in castool chdman floptool imgtool jedutil ldresample ldverify romcmp testkeys ; do
			newgamesbin ${i} ${PN}-${i}
			newman src/osd/sdl/man/${i}.1 ${PN}-${i}.1
		done
		newgamesbin ldplayer$(use amd64 && echo 64)$(use debug && echo d) ${PN}-ldplayer
		newman src/osd/sdl/man/ldplayer.1 ${PN}-ldplayer.1
	fi

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst

	elog "It is strongly recommended to change either the system-wide"
	elog "  ${GAMES_SYSCONFDIR}/${PN}/mame.ini or use a per-user setup at ~/.${PN}/mame.ini"
	elog
	if use opengl; then
		elog "You built ${PN} with opengl support and should set"
		elog "\"video\" to \"opengl\" in mame.ini to take advantage of that"
		elog
		elog "For more info see http://wiki.mamedev.org"
	fi
}
