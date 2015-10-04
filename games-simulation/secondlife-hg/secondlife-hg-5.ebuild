# Copyright 2010-2015 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. Lastest version at http://techwolf.github.io/

EAPI="5"
MY_LLCODEBASE="371"
inherit mercurial secondlife

DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://secondlife.com/"

EHG_REPO_URI="https://bitbucket.org/lindenlab/viewer-bear"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${DEPEND}
	dev-perl/XML-XPath"

src_unpack() {
	# When using svc, S is the directory the checkout is copied into.
	# Set it so it matches src tarballs.
	S="${WORKDIR}/linden"
	mercurial_src_unpack
	MY_STORE_DIR="${EHG_STORE_DIR}"
	cd "${WORKDIR}"/linden
	if use vivox ; then
	  get_install_xml_value "slvoice"
	  secondlife_unpack ${MY_STORE_DIR}/${SLASSET##*/} || die "Problem with unpacking ${MY_STORE_DIR}/${SLASSET##*/}"
	fi
}

src_prepare() {
	secondlife_src_prepare

	# cmake standalone webkit fix.
	epatch "${FILESDIR}"/v3_usesystemlibs.patch

	# jsoncpp fixes, note that open-54 causes build errors, so different custom fix is used here.
	epatch "${FILESDIR}"/v3_jsoncpp_v2.patch
	
	# ndPhysicsstub
	epatch "${FILESDIR}"/ndPhysicsstub_ef260ca4432a.patch
	sed -i -e 's:add_subdirectory(${LLPHYSICSEXTENSIONS_SRC_DIR} llphysicsextensions):# add_subdirectory(${LLPHYSICSEXTENSIONS_SRC_DIR} llphysicsextensions):' "${WORKDIR}/linden/indra/newview/CMakeLists.txt"
	
	# uniparser fix for standalone
	epatch "${FILESDIR}"/v3_uniparser_cdde5dd542b5.patch
	
	# 64 bit fixes
	epatch "${FILESDIR}"/v3_64bit_326cc5af6282.patch
	epatch "${FILESDIR}"/v3_64bit_2409c7e101b1.patch
	epatch "${FILESDIR}"/v3_64bit_fixes.patch
	
	# LL code uses google_breakpad prefix while google headers don't use a prefix, causing "headers not found" errors.
	epatch "${FILESDIR}"/v3_breakpad_29dfb71f7a28.patch
	
	# gcc warnings
	epatch "${FILESDIR}"/v3_gcc_warnings.patch
	
	# gcc errors
	epatch "${FILESDIR}"/v3_gcc_errors.patch
	
	# usesystemlibs colladadom
	epatch "${FILESDIR}"/v3_colladadom_standalone_60e6ef631abb_v2.patch

	# allow users to try out patches
	# put patches in /etc/portage/patches/{${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}/feature.patch
	epatch_user
}

# Linden Labs use autobuild to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	S="${WORKDIR}/linden/indra"
	cd "${S}"
	secondlife_cmake_prep
	cmake-utils_src_configure
}
src_compile() {
	S="${WORKDIR}/linden/indra"
	cmake-utils_src_compile
}

src_install() {
	# This used to be in src_prep untill Oz added contributions.txt processing for the help->about floater.
	# Will fail with ../../doc/contributions.txt not found during the extra viewer_manifest.py copy during build.
	# viewer_manifest.py will not copy all the files
	epatch "${FILESDIR}"/viewer_manifest_package.patch

	secondlife_viewer_manifest "--buildtype=${CMAKE_BUILD_TYPE}"
	
	# gentoo specific stuff
	games_make_wrapper "${PN}" ./secondlife "${GAMES_DATADIR}/${PN}"
	newicon icons/release/secondlife_256.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Second Life" "${PN}"_icon
	prepgamesdirs
}

