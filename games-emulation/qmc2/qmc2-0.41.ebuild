# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils games

MY_PV=${PV/_beta/.b}

DESCRIPTION="An MAME frontend for SDLMAME/SDLMESS"
HOMEPAGE="http://qmc2.arcadehits.net/wordpress/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug joystick opengl phonon +sdlmame sdlmess sqlite"

DEPEND=">=dev-qt/qtgui-4.7:4[accessibility]
	>=dev-qt/qtwebkit-4.7:4
	>=dev-qt/qttest-4.7:4
	phonon? ( || ( media-libs/phonon >=dev-qt/qtphonon-4.7:4 ) )
	joystick? ( media-libs/libsdl[joystick] )
	opengl? ( >=dev-qt/qtopengl-4.7:4 )
	sqlite? ( >=dev-qt/qtsql-4.7:4[sqlite] )"

RDEPEND="${DEPEND}
	sdlmame? ( games-emulation/sdlmame )
	sdlmess? ( games-emulation/sdlmess )
	x11-apps/xwininfo"

S="${WORKDIR}/${PN}"

REQUIRED_USE="|| ( sdlmame sdlmess )"

pkg_setup() {
	# Set proper parameters for make
	FLAGS="DESTDIR=${D} PREFIX=\"${GAMES_PREFIX}\" DATADIR=\"${GAMES_DATADIR}\" CTIME=0"

	use debug || FLAGS="${FLAGS} DEBUG=0"
	use joystick || FLAGS="${FLAGS} JOYSTICK=0"
	use opengl && FLAGS="${FLAGS} OPENGL=1"
	use phonon || FLAGS="${FLAGS} PHONON=0"
	use sqlite && FLAGS="${FLAGS} DATABASE=1"

	games_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}/${P}-makefile.patch"
	sed -i '1i#define OF(x) x' minizip/ioapi.h

	## This is not as it appears, ARCH means something different to qmc2's Makefile
	## then it means to the portage/portage-compatible package manager
	sed -ie 's%ifndef ARCH%ifdef ARCH%' Makefile

	use sdlmess && cp -r "${S}" "${WORKDIR}/${PN}-sdlmess"
}

src_compile() {
	if use sdlmame
	then
	    emake ${FLAGS} EMULATOR=SDLMAME || die "make failed"
	fi

	if use sdlmess
	then
	    cd "${WORKDIR}/${PN}-sdlmess"
	    emake ${FLAGS} EMULATOR=SDLMESS || die "make failed"
	fi
}

src_install() {
	if use sdlmame
	then
	    emake ${FLAGS} EMULATOR=SDLMAME install || die "make install failed"
	fi

	if use sdlmess
	then
	    cd "${WORKDIR}/${PN}-sdlmess"
	    emake ${FLAGS} EMULATOR=SDLMESS install || die "make install failed"
	fi

	## Not a big fan of doing this, but it's necessary due to build system
	sed -ie "s%${D}%/%g" "${D}etc/${PN}/${PN}.ini"
	rm "${D}etc/${PN}/${PN}.inie"

	# Remove symlink to avoid confusion
	rm "${D}/${GAMES_BINDIR}/qmc2"

	prepgamesdirs
}
