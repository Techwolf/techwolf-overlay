# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. Lastest version at http://gentoo.techwolf.net/

EAPI="2"
MY_LLCODEBASE="123"
inherit secondlife

MY_SOURCE="http://automated-builds-secondlife-com.s3.amazonaws.com/viewer-rc-frozen/slviewer-src-viewer-rc-frozen-1.23.5.136274.tar.gz"
MY_ARTWORK="http://automated-builds-secondlife-com.s3.amazonaws.com/viewer-rc-frozen/slviewer-artwork-viewer-rc-frozen-1.23.5.136274.zip"
MY_LIBS="http://automated-builds-secondlife-com.s3.amazonaws.com/viewer-rc-frozen/slviewer-linux-libs-viewer-rc-frozen-1.23.5.136274.tar.gz"
MY_GLH="http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/glh_linear-linux-20080812.tar.bz2"
MY_GLH64="http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/glh_linear-linux-20080613.tar.bz2"
MY_SDL="http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/SDL-1.2.5-linux-20080818.tar.bz2"
MY_VIVOX="http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/vivox-2.1.3010.6270-linux-20090309.tar.bz2"

DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://secondlife.com/"
SRC_URI="${MY_SOURCE}
	${MY_ARTWORK}
	${MY_LIBS}
	amd64? ( ${MY_GLH64} )
	x86?   ( ${MY_GLH} )
	${MY_SDL}
	vivox? ( ${MY_VIVOX} )"

SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="llwebkit llmozlib"

RDEPEND="${RDEPEND}
	llmozlib? ( net-libs/llmozlib2 )
	llwebkit? ( net-libs/llmozlib2-qtwebkit )"

S="${WORKDIR}/linden/indra"

src_unpack() {
	unpack ${MY_SOURCE##*/}
	unpack ${MY_LIBS##*/}	
	unpack ${MY_ARTWORK##*/}
	cd "${WORKDIR}"/linden

	# need glh/glh_linear.h that is not aviable in portage.
	# http://jira.secondlife.com/browse/VWR-9005
	use amd64 && unpack ${MY_GLH64##*/}
	use x86 && unpack ${MY_GLH##*/}
	
	# need the SDL package due to Linden Labs put mouse cursers in it.
	# http://jira.secondlife.com/browse/VWR-9475
	unpack ${MY_SDL##*/}
	
	use vivox && unpack ${MY_VIVOX##*/}
}

src_prepare() {
	secondlife_src_prepare
	# Gentoo and build fix patches
	cd "${S}"
	if use llmozlib && ! use llwebkit ; then
	  epatch "${FILESDIR}"/secondlife-cmake-llmozilla.patch
	  epatch "${FILESDIR}"/secondlife-llmozlib-svn.patch
	fi
	cd "${WORKDIR}"/linden
	if use llwebkit ; then
	  epatch "${FILESDIR}"/SNOW-125-autodetect_mozlib_v2.patch
	fi

	# fasttimer fix
	epatch "${FILESDIR}"/SNOW-108_Better_Fast_Timers_on_Unixoids.patch

	# allow users to try out patches
	# put patches in /etc/portage/patches/{${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}/feature.patch
	epatch_user
}

# Linden Labs use ./develop.py to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	secondlife_cmake_prep
	if  use llmozlib || use llwebkit ; then
	  mycmakeargs="${mycmakeargs} -DMOZLIB:BOOL=TRUE"
	 else
	  mycmakeargs="${mycmakeargs} -DMOZLIB:BOOL=FALSE"
	fi

	cmake-utils_src_configure
}
src_compile() {
	cmake-utils_src_compile
}

src_install() {
	secondlife_viewer_manifest ""
	
	# llmozlib is not packed with secondlife, symbolic link it to the proper place.
	use llmozlib && ln -s "../../../../../usr/$(get_libdir)/llmozlib2/runtime_release" "${D}/${GAMES_DATADIR}/${PN}/app_settings/mozilla-runtime-linux-i686"
	
	# gentoo specific stuff
	if  use llmozlib ; then
	  games_make_wrapper "${PN}" ./secondlife "${GAMES_DATADIR}/${PN}" "/usr/$(get_libdir)/llmozlib2"
	 else
	  games_make_wrapper "${PN}" ./secondlife "${GAMES_DATADIR}/${PN}"
	fi
	newicon res/ll_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Second Life" "${PN}"_icon
	prepgamesdirs
}


