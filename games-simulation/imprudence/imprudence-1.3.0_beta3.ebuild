# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. Lastest version at http://gentoo.techwolf.net/

EAPI="2"
MY_LLCODEBASE="123"
inherit secondlife

MY_SOURCE="http://imprudenceviewer.org/download/source/Imprudence-source-1.3.0-beta-3.zip"
MY_ARTWORK="http://imprudenceviewer.org/download/extras/imprudence-artwork-20091130.tar.bz2"
MY_GLH="http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/glh_linear-linux-20080812.tar.bz2"
MY_GLH64="http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/glh_linear-linux-20080613.tar.bz2"
MY_SDL="http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/SDL-1.2.5-linux-i686-gcc-4.1-20080915.tar.bz2"
MY_SDL64="http://imprudenceviewer.org/download/libs/SDL-1.2.12-linux64-20091230.tar.bz2"
MY_VIVOX="http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/vivox-2.1.3010.6270-linux-20090309.tar.bz2"

DESCRIPTION="Metaverse (SL) viewer with an emphasis on usability and bold changes"
HOMEPAGE="http://imprudenceviewer.org/"

SRC_URI="${MY_SOURCE}
	${MY_ARTWORK}
	amd64? ( ${MY_GLH64} )
	x86?   ( ${MY_GLH} )
	amd64? ( ${MY_SDL64} )
	x86?   ( ${MY_SDL} )
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
	cd "${WORKDIR}"/Imprudence-source-*
	mv * ../ || die "Fail to move sources to linden directory"
	cd "${WORKDIR}"/linden

	unpack ${MY_ARTWORK##*/}

	# need glh/glh_linear.h that is not aviable in portage.
	# http://jira.secondlife.com/browse/VWR-9005
	use amd64 && unpack ${MY_GLH64##*/}
	use x86 && unpack ${MY_GLH##*/}
	
	# need the SDL package due to Linden Labs put mouse cursers in it.
	# http://jira.secondlife.com/browse/VWR-9475
	use amd64 && unpack ${MY_SDL64##*/}
	use x86 && unpack ${MY_SDL##*/}
	
	use vivox && unpack ${MY_VIVOX##*/}

	# remove the prebuilt libs
	rm -fr "${WORKDIR}"/linden/libraries
}

src_prepare() {
	secondlife_src_prepare
	cd "${S}"
	if use llmozlib && ! use llwebkit ; then
	  epatch "${FILESDIR}"/secondlife-cmake-llmozilla.patch
	  epatch "${FILESDIR}"/secondlife-llmozlib-svn.patch
	fi
	cd "${WORKDIR}"/linden
	if use llwebkit ; then
	  epatch "${FILESDIR}"/SNOW-125-autodetect_mozlib_v2.patch
	fi

	# Imprudence has NIH syndrome and broke standalone, replace files with ones from LL.
	rm -f "${WORKDIR}/linden/indra/cmake/OPENAL.cmake" || die "Unable to delete OPENAL.cmake"
	cp -p "${FILESDIR}/OPENAL.cmake" "${WORKDIR}/linden/indra/cmake/OPENAL.cmake"
	rm -f "${WORKDIR}/linden/indra/cmake/GStreamer.cmake" || die "Unable to delete GStreamer.cmake"
	cp -p "${FILESDIR}/GStreamer.cmake" "${WORKDIR}/linden/indra/cmake/GStreamer.cmake"

	# llmozlib is seperate package and can be webkit instead
	sed -i -e 's/self.path(\"app_settings\/mozilla-runtime-linux-.*\")//g' indra/newview/viewer_manifest.py || die "Sed manifest fix failed"

	# Imprudence has never heard of standalone builds.
	sed -i -e 's/if self.prefix(\"..\/..\/libraries\/x86_64-linux\/lib_release_client\", dst="lib64"):/\"\"\"/' indra/newview/viewer_manifest.py || die "Sed manifest fix failed"
	sed -i -e 's/self.end_prefix(\"lib64\")/\"\"\"/' indra/newview/viewer_manifest.py || die "Sed manifest fix failed"

	# allow users to try out patches
	# put patches in /etc/portage/patches/{${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}/feature.patch
	epatch_user
}

# Linden Labs use ./develop.py to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	secondlife_cmake_prep
	mycmakeargs="${mycmakeargs} -DROOT_PROJECT_NAME:STRING=Imprudence"
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
	cp -p "${CMAKE_BUILD_DIR}/newview/imprudence-bin" "${CMAKE_BUILD_DIR}/newview/imprudence-stripped" || die "Failed to copy over the binary"
	secondlife_viewer_manifest ""
	
	# llmozlib is not packed with secondlife, symbolic link it to the proper place.
	if  use llmozlib ; then
	  use x86 && ln -s "../../../../../usr/$(get_libdir)/llmozlib2/runtime_release" "${D}/${GAMES_DATADIR}/${PN}/app_settings/mozilla-runtime-linux-i686"
	  use amd64 && ln -s "../../../../../usr/$(get_libdir)/llmozlib2/runtime_release" "${D}/${GAMES_DATADIR}/${PN}/app_settings/mozilla-runtime-linux-x86_64"
	fi
	# gentoo specific stuff
	if  use llmozlib ; then
	  games_make_wrapper "${PN}" ./imprudence "${GAMES_DATADIR}/${PN}" "/usr/$(get_libdir)/llmozlib2"
	 else
	  games_make_wrapper "${PN}" ./imprudence "${GAMES_DATADIR}/${PN}"
	fi
	newicon res/imprudence_icon.png "${PN}"_icon.png || die "Failed to create the icon"
	make_desktop_entry "${PN}" "Imprudence" "${PN}"_icon
	prepgamesdirs
}
