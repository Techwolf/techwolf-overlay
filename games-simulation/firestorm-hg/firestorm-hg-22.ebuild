# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. Lastest version at http://gentoo.techwolf.net/

EAPI="5"
MY_LLCODEBASE="371"
inherit mercurial secondlife versionator

DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://www.phoenixviewer.com/"

EHG_REPO_URI="http://hg.phoenixviewer.com/phoenix-firestorm-lgpl/"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="opensim avx crash-reporting openjpeg2 kdu"

DEPEND="${DEPEND}
	dev-perl/XML-XPath
	crash-reporting? ( dev-util/google-breakpad-hg )
	dev-libs/llhacdconvexdecomposition-hg
	dev-libs/glod-hg
	dev-libs/jsoncpp-hg
	media-libs/llcolladadom-hg
	dev-libs/glh-hg
	openjpeg2? ( >=media-libs/openjpeg-2.0 )
	kdu? ( media-libs/kdu )"

src_unpack() {
	# When using svc, S is the directory the checkout is copied into.
	# Set it so it matches src tarballs.
	S="${WORKDIR}/linden"
	mercurial_src_unpack
	MY_STORE_DIR="${EHG_STORE_DIR}"
	cd "${WORKDIR}"/linden

	if use vivox ; then
	  get_install_xml_value "slvoice"
	  # unpack ${SLASSET##*/} || die "Problem with unpacking ${SLASSET##*/}"
	  secondlife_unpack ${MY_STORE_DIR}/${SLASSET##*/} || die "Problem with unpacking ${MY_STORE_DIR}/${SLASSET##*/}"
	fi
}

src_prepare() {
	secondlife_src_prepare

	# fix permission
	chmod +x "${WORKDIR}/linden/indra/newview/viewer_manifest.py"
	
	if use openjpeg2 ; then
	  epatch "${FILESDIR}/NickyD_openjpeg2.patch"
	  epatch "${FILESDIR}/standalone_openjpeg2.patch"
	fi
	
	# set the channel name due to not calling the script that normally sets it.
	sed -i -e 's:@VIEWER_CHANNEL@:Firestorm Gentoo:' "${WORKDIR}/linden/indra/newview/fsversionvalues.h.in"

	# allow users to try out patches
	# put patches in /etc/portage/patches/{${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}/feature.patch
	epatch_user
}

# Linden Labs use autobuild to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	return
}
src_compile() {
	S="${WORKDIR}/linden/indra"
	cd "${S}"
	secondlife_cmake_prep

	# add opensim support option
	mycmakeargs="${mycmakeargs} $(cmake-utils_use opensim OPENSIM)"
	
	# AVX support
	mycmakeargs="${mycmakeargs} $(cmake-utils_use avx USE_AVX_OPTIMIZATION)"
	
	# Nicky 64-bit support
	if use amd64 ; then
	  mycmakeargs="${mycmakeargs} -DNDTARGET_ARCH:STRING=x64"
	 else
	  mycmakeargs="${mycmakeargs} -DNDTARGET_ARCH:STRING=x86"
	fi

	# add include path for prebuilt includes, in this case, glh_linear.h
	mycmakeargs="${mycmakeargs} -DCMAKE_INCLUDE_PATH=${WORKDIR}/linden/include"

	use crash-reporting && mycmakeargs="${mycmakeargs} -DNON_RELEASE_CRASH_REPORTING:BOOL=TRUE"
	
	# openjpeg2 suppport
	mycmakeargs="${mycmakeargs} $(cmake-utils_use openjpeg2 OPENJPEG2)"
	
	# kdu support.
	use kdu && mycmakeargs="${mycmakeargs} -DUSE_KDU:BOOL=ON"

	cmake-utils_src_configure
	cmake-utils_src_compile
}

src_install() {
	# This used to be in src_prep untill Oz added contributions.txt processing for the help->about floater.
	# Will fail with ../../doc/contributions.txt not found during the extra viewer_manifest.py copy during build.
	# viewer_manifest.py will not copy all the files
	# epatch "${FILESDIR}"/viewer_manifest_package.patch

	secondlife_viewer_manifest "--buildtype=${CMAKE_BUILD_TYPE} --copy_artwork"

	# gentoo specific stuff
	games_make_wrapper "${PN}" ./firestorm "${GAMES_DATADIR}/${PN}"
	newicon res/firestorm_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Second Life" "${PN}"_icon
	prepgamesdirs
}

