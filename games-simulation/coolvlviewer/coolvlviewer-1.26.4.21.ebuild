# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. Lastest version at http://gentoo.techwolf.net/

EAPI="2"
MY_LLCODEBASE="130"
inherit secondlife mercurial

MY_SOURCE="http://sldev.free.fr/sources/slviewer-src-cool_vl_viewer-126421.tar.gz"
MY_ARTWORK="http://sldev.free.fr/sources/slviewer-artwork-cool_vl_viewer-126412.zip"
MY_DICTIONARIES="http://sldev.free.fr/libraries/dictionaries-1-20120518.tar.bz2"
MY_VIVOX="http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/vivox-2.1.3010.6270-linux-20090309.tar.bz2"

DESCRIPTION="The Cool VL Viewer is a third-party viewer for Second Life® and OpenSim grids."
HOMEPAGE="http://sldev.free.fr/"
SRC_URI="${MY_SOURCE}
	${MY_ARTWORK}
	${MY_DICTIONARIES}
	vivox? ( ${MY_VIVOX} )"

SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

RDEPEND="${RDEPEND}
	app-text/hunspell"

DEPEND="${DEPEND}
	dev-libs/llhacdconvexdecomposition-hg
	dev-libs/glod-hg"

S="${WORKDIR}/linden/indra"

src_unpack() {
	unpack ${MY_SOURCE##*/}
	unpack ${MY_ARTWORK##*/}
	cd "${WORKDIR}"/linden
	unpack ${MY_DICTIONARIES##*/}
	use vivox && unpack ${MY_VIVOX##*/}

	secondlife_colladadom_unpack
}

src_prepare() {
	secondlife_src_prepare
	
	# Do NOT hardcode -march for standalone
	sed -i -e 's:add_definitions(-march=pentium4 -mfpmath=sse)::' "${WORKDIR}/linden/indra/cmake/00-Common.cmake" || die "00-Common.cmake sed failed"
	
	# fix boost linkage
	# sed -i -e 's:set(BOOST_FILESYSTEM_LIBRARY boost_filesystem):set(BOOST_FILESYSTEM_LIBRARY boost_filesystem-mt):' "${WORKDIR}/linden/indra/cmake/Boost.cmake" || die "Boost.cmake sed failed"
	sed -i -e 's:${BOOST_REGEX_LIBRARY}:${BOOST_REGEX_LIBRARY}\n${BOOST_FILESYSTEM_LIBRARY}:' "${WORKDIR}/linden/indra/newview/CMakeLists.txt" || die "CMakeLists.txt sed failed"

	secondlife_colladadom_prepare
	
	# allow users to try out patches
	# put patches in /etc/portage/patches/{${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}/feature.patch
	epatch_user
}

# Linden Labs use ./develop.py to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	return
}
src_compile() {
	secondlife_colladadom_build

	S="${WORKDIR}/linden/indra"
	cd "${S}"
	secondlife_cmake_prep
	mycmakeargs="${mycmakeargs} $(cmake-utils_use pulseaudio PULSEAUDIO)"
	if has_version '>=app-text/hunspell-1.3'; then mycmakeargs="${mycmakeargs} -DHUNSPELL_NAMES=hunspell-1.3"; fi
	append-ldflags "-L${WORKDIR}/linden/libraries/i686-linux/lib_release_client"
	cmake-utils_src_configure
	cmake-utils_src_compile
}

src_install() {
	secondlife_viewer_manifest "--branding_id=snowglobe"
	cd "${WORKDIR}"/linden/libraries/i686-linux/lib_release_client/
	exeinto "${GAMES_DATADIR}/${PN}/lib"
	doexe lib*
	cd "${WORKDIR}"/linden/indra/newview/
	games_make_wrapper "${PN}" ./cool_vl_viewer "${GAMES_DATADIR}/${PN}"
	newicon res/ll_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Cool VL Viewer" "${PN}"_icon
	prepgamesdirs
}


