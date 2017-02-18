# Copyright 2010-2017 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Id$
# Nonofficial ebuild by Techwolf. Lastest version at http://gentoo.techwolf.net/

EAPI="5"
MY_LLCODEBASE="386"
inherit secondlife versionator

DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://www.firestormviewer.org/"

MY_SOURCE="https://bitbucket.org/NickyD/phoenix-firestorm-lgpl/get/a27ad24ed750.tar.bz2"
MY_VIVOX="http://automated-builds-secondlife-com.s3.amazonaws.com/hg/repo/slvoice_3p-update-slvoice/rev/298329/arch/Linux/installer/slvoice-3.2.0002.10426.298329-linux-298329.tar.bz2"

SRC_URI="${MY_SOURCE}
	vivox? ( ${MY_VIVOX} )"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="opensim avx crash-reporting openjpeg2 kdu"

DEPEND="${DEPEND}
	crash-reporting? ( dev-util/google-breakpad-hg )
	dev-libs/llhacdconvexdecomposition-hg
	dev-libs/glod-hg
	media-libs/llcolladadom-hg
	dev-libs/glh-hg
	openjpeg2? ( media-libs/openjpeg:2 )
	kdu? ( media-libs/kdu )"

src_unpack() {
	unpack ${MY_SOURCE##*/}
	mv NickyD-phoenix-firestorm-lgpl-a27ad24ed750 linden || die "renaming to \"linden\" failed"
	S="${WORKDIR}/linden"
	cd "${S}"
	use vivox && unpack ${MY_VIVOX##*/}
}

src_prepare() {
	secondlife_src_prepare
	
	# set the channel name due to not calling the script that normally sets it.
	sed -i -e 's:@VIEWER_CHANNEL@:Firestorm Gentoo:' "${WORKDIR}/linden/indra/newview/fsversionvalues.h.in"

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
	mycmakeargs="${mycmakeargs} $(cmake-utils_use openjpeg2 ND_USE_OPENJPEG2)"
	
	# kdu support.
	use kdu && mycmakeargs="${mycmakeargs} -DUSE_KDU:BOOL=ON"
	
	export revision=$(get_version_component_range 4)

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
	# epatch "${FILESDIR}"/viewer_manifest_package.patch

	secondlife_viewer_manifest "--buildtype=${CMAKE_BUILD_TYPE} --copy_artwork"

	# gentoo specific stuff
	games_make_wrapper "${PN}" ./firestorm "${GAMES_DATADIR}/${PN}"
	newicon res/firestorm_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Second Life" "${PN}"_icon
	prepgamesdirs
}

