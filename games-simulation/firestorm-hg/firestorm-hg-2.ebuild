# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. Lastest version at http://gentoo.techwolf.net/

EAPI="2"
MY_LLCODEBASE="210"
inherit mercurial secondlife

DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://www.phoenixviewer.com/"

EHG_REPO_URI="http://hg.phoenixviewer.com/phoenix-firestorm-lgpl/"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${DEPEND}
	dev-perl/XML-XPath
	dev-util/google-breakpad-hg"

src_unpack() {
	# When using svc, S is the directory the checkout is copied into.
	# Set it so it matches src tarballs.
	S="${WORKDIR}/linden"
	mercurial_src_unpack
	MY_STORE_DIR="${EHG_STORE_DIR}"
	cd "${WORKDIR}"/linden
# 	if [[ ! -f "${WORKDIR}/linden/indra/llwindow/glh/glh_linear.h" ]] ; then
# 	  # need glh/glh_linear.h that is not aviable in portage.
# 	  # http://jira.secondlife.com/browse/VWR-9005
# 	  get_install_xml_value "glh_linear"
# 	  unpack ${SLASSET##*/} || die "Problem with unpacking ${SLASSET##*/}"
# 	 else
# 	  einfo "glh_linear.h found, not downloading glh package."
# 	fi
# 	if use vivox ; then
# 	  get_install_xml_value "slvoice"
# 	  unpack ${SLASSET##*/} || die "Problem with unpacking ${SLASSET##*/}"
# 	fi
}

src_prepare() {
	cp -p "${WORKDIR}/linden/indra/llcommon//llversionviewer.h.in" "${WORKDIR}/linden/indra/llcommon//llversionviewer.h"
	secondlife_src_prepare

	epatch "${FILESDIR}"/viewer_manifest_Linux_x86_64Manifest.patch
	# epatch "${FILESDIR}"/SNOW-512-3.patch
	# epatch "${FILESDIR}"/SNOW-599_cmake_pulseaudio.patch
	# epatch "${FILESDIR}"/SNOW-746_google_breakpad_v5.patch
	# epatch "${FILESDIR}"/SNOW-747_pulseaudio.patch

	# epatch "${FILESDIR}"/SNOW-651_SLPlugin_LL_TESTS.patch
	# epatch "${FILESDIR}"/SNOW-654_integration_LL_TESTS.patch

	# viewer_manifest.py will not copy all the files
	epatch "${FILESDIR}"/viewer_manifest_package.patch

	# fix permission
	chmod +x "${WORKDIR}/linden/indra/newview/viewer_manifest.py"

	# hack untill I fix it upstream
	sed -i -e '/FIRECYG/d' "${WORKDIR}/linden/indra/llcommon/CMakeLists.txt"

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
# 	cd ${D}/${GAMES_DATADIR}/${PN}
# 	mkdir indra
# 	cd indra
# 	ln -s .. newview
# 	cd "${WORKDIR}"/linden/indra/newview/
	
	# gentoo specific stuff
	games_make_wrapper "${PN}" ./firestorm "${GAMES_DATADIR}/${PN}"
	newicon res/ll_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Second Life" "${PN}"_icon
	prepgamesdirs
}

