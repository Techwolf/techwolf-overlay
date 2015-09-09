# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. Lastest version at http://gentoo.techwolf.net/

EAPI="2"
MY_LLCODEBASE="200"
inherit subversion secondlife

DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://secondlife.com/"

ESVN_REPO_URI="https://svn.secondlife.com/svn/linden/branches/2010/viewer_2-0-1"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${DEPEND}
	dev-perl/XML-XPath"

src_unpack() {
	# When using svc, S is the directory the checkout is copied into.
	# Set it so it matches src tarballs.
	S="${WORKDIR}/linden"
	subversion_src_unpack
	MY_STORE_DIR="${ESVN_STORE_DIR}"
	secondlife_asset_unpack
}

src_prepare() {
	secondlife_src_prepare

	epatch "${FILESDIR}"/cmake_viewer_manifest.patch
	epatch "${FILESDIR}"/SNOW-512-3.patch
	epatch "${FILESDIR}"/SNOW-599_cmake_pulseaudio.patch
	epatch "${FILESDIR}"/SNOW-504_Copy3rdPartyLibs.patch
	# epatch "${FILESDIR}"/SNOW-650_PULSEAUDIO_FOUND.patch
	epatch "${FILESDIR}"/SNOW-511_webkit_standalone.patch
	# epatch "${FILESDIR}"/SNOW-651_SLPlugin_LL_TESTS.patch
	epatch "${FILESDIR}"/SNOW-654_integration_LL_TESTS.patch

	# allow users to try out patches
	# put patches in /etc/portage/patches/{${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}/feature.patch
	epatch_user
}

# Linden Labs use ./develop.py to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	S="${WORKDIR}/linden/indra"
	secondlife_cmake_prep
	cmake-utils_src_configure
}
src_compile() {
	cmake-utils_src_compile
}

src_install() {
	secondlife_viewer_manifest "--buildtype=${CMAKE_BUILD_TYPE}"

	# Fix "unable to open: /usr/share/games/${PN}/indra/newview/skins/paths.xml" runtime error
	cd ${D}/${GAMES_DATADIR}/${PN}
	mkdir indra
	cd indra
	ln -s .. newview
	cd "${WORKDIR}"/linden/indra/newview/
	
	# gentoo specific stuff
	games_make_wrapper "${PN}" ./secondlife "${GAMES_DATADIR}/${PN}"
	newicon res/ll_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Second Life" "${PN}"_icon
	prepgamesdirs
}

