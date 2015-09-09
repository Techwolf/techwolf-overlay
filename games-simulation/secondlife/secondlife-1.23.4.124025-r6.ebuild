# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. For new version look here : http://gentoo.techwolf.net/

EAPI="2"

inherit cmake-utils games versionator

SECONDLIFE_MAJOR_VER=$(get_version_component_range 1-2)
SECONDLIFE_MINOR_VER=$(get_version_component_range 3)
SECONDLIFE_REVISION=$(get_version_component_range 4)
MY_PV="viewer-${SECONDLIFE_MAJOR_VER}.${SECONDLIFE_MINOR_VER}-r${SECONDLIFE_REVISION}"
MY_DATE="2009/06"
GLH_V="20080812"
GLH_V64="20080613"
SDL_V="20080818"
VIVOX_V="2.1.3010.6270-linux-20090309"
DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://secondlife.com/"
SRC_URI="http://secondlife.com/developers/opensource/downloads/${MY_DATE}/slviewer-src-${MY_PV}.tar.gz
	http://secondlife.com/developers/opensource/downloads/${MY_DATE}/slviewer-artwork-${MY_PV}.zip
	http://secondlife.com/developers/opensource/downloads/${MY_DATE}/slviewer-linux-libs-${MY_PV}.tar.gz
	amd64? ( http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/glh_linear-linux-${GLH_V64}.tar.bz2 )
	x86?   ( http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/glh_linear-linux-${GLH_V}.tar.bz2 )
	http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/SDL-1.2.5-linux-${SDL_V}.tar.bz2
	vivox? ( http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/vivox-${VIVOX_V}.tar.bz2 )"

LICENSE="GPL-2-with-Linden-Lab-FLOSS-exception"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# KEYWORDS=""

IUSE="+vivox +openal +llmozlib +gstreamer +extras fmod dbus"
RESTRICT="mirror"

# There are problems with curl if built with gnutls. http://jira.secondlife.com/browse/VWR-5601 
# There is DNS lookup problems with curl if built without c-ares.
RDEPEND="x11-libs/gtk+:2
	dev-libs/apr
	dev-libs/apr-util
	net-dns/c-ares
	net-misc/curl[-nss,-gnutls,ares]
	dev-libs/openssl
	media-libs/freetype
	media-libs/jpeg
	media-libs/libsdl
	media-libs/mesa
	media-libs/libogg
	media-libs/libvorbis
	vivox? ( amd64? ( app-emulation/emul-linux-x86-baselibs ) )
	fmod? ( =media-libs/fmod-3.75* )
	openal? ( >=media-libs/openal-1.5.304 
		media-libs/freealut )
	sys-libs/db
	dbus? ( dev-libs/dbus-glib )
	dev-libs/expat
	sys-libs/zlib
	>=dev-libs/xmlrpc-epi-0.51-r1
	media-libs/openjpeg
	media-libs/libpng
	x11-libs/pango
	llmozlib? ( net-libs/llmozlib2 )
	gstreamer? ( media-plugins/gst-plugins-meta
		    media-plugins/gst-plugins-soup )"
# media-plugins/gst-plugins-meta now handles all the USE flag plugins options.

DEPEND="${RDEPEND}
	dev-libs/boost
	dev-util/pkgconfig
	sys-devel/flex
	sys-devel/bison
	dev-lang/python
	>=dev-util/cmake-2.4.8
	dev-libs/libndofdev"

S="${WORKDIR}/linden/indra"

# Prevent warning on a binary only file
QA_TEXTRELS="usr/share/games/secondlife/lib/libvivoxsdk.so"

pkg_setup() {
	use amd64 && use fmod && ewarn "fmod is only available on x86. Disabling fmod"
	
	# uncommnet the following if there are build problems relating
	# to languages
#	eval unset ${!LC_*} LANG LANGUAGE
#	export LINGUAS=en
}

src_unpack() {
	# libs contains the font files
	unpack slviewer-linux-libs-${MY_PV}.tar.gz
	unpack slviewer-src-${MY_PV}.tar.gz
	unpack slviewer-artwork-${MY_PV}.zip
	cd "${WORKDIR}"/linden
	
	# need glh/glh_linear.h that is not aviable in portage.
	# http://jira.secondlife.com/browse/VWR-9005
	use amd64 && unpack glh_linear-linux-${GLH_V64}.tar.bz2
	use x86 && unpack glh_linear-linux-${GLH_V}.tar.bz2
	
	# need the SDL package due to Linden Labs put mouse cursers in it.
	# http://jira.secondlife.com/browse/VWR-9475
	unpack SDL-1.2.5-linux-${SDL_V}.tar.bz2
	
	use vivox && unpack vivox-${VIVOX_V}.tar.bz2
}

src_prepare() {
	# fix CRLF formatted xml files by converting them to UNIX formatting.
	find "${WORKDIR}"/linden -type f -name "*xml" -exec sed -i 's/\r$//' {} \;
	# fix version info
	sed -i \
	  -e "s/const S32 LL_VERSION_BUILD = 0;/const S32 LL_VERSION_BUILD = ${SECONDLIFE_REVISION};/" \
	  llcommon/llversionviewer.h || die "version sed failed"

	# Gentoo and build fix patches
	cd "${S}"
	epatch "${FILESDIR}"/secondlife-cmake-llmozilla.patch
	epatch "${FILESDIR}"/secondlife-llmozlib-svn.patch
	epatch "${FILESDIR}"/VWR-9499-fix_keeping_dbus_stuff_together.patch
	cd "${WORKDIR}"/linden
	epatch "${FILESDIR}"/VWR-12789-dbus-20090412.diff
	epatch "${FILESDIR}"/cmakeInstall.patch
	epatch "${FILESDIR}"/enable_gstreamer.patch
	# gcc 4.3 fixes
	epatch "${FILESDIR}"/VWR-10001-message.patch
	# epatch "${FILESDIR}"/secondlife-llcrashloggerlinux.patch
	

	# bugfixes
	epatch "${FILESDIR}"/VWR-4137-GroupInfoDates.patch
	epatch "${FILESDIR}"/SVC-580-slviewer-0-v11843-LpecRpecSwapped.patch
	#epatch "${FILESDIR}"/slviewer-0-v11843-PossibleCrashAndLeakAssetStorage.patch
	epatch "${FILESDIR}"/VWR-2003-slviewer-0-v11843-PossibleCrashDragAndDrop.patch
	#epatch "${FILESDIR}"/VWR-2683-slviewer-0-v11843-PossibleCrashSpeakerList.patch
	epatch "${FILESDIR}"/VWR-9620-slviewer-0-v11905-SendParcelSelectObjectsWrongReturnType.patch
	epatch "${FILESDIR}"/VWR-3616-slviewer-0-v120130-LandmarksDiscardButton_v2.patch
	epatch "${FILESDIR}"/VWR-5530-slviewer-0-v120150-RememberMinimizedFloatersPosition.patch
	epatch "${FILESDIR}"/slviewer-0-v12100-NoMultipleLocaleWarnings.patch
	epatch "${FILESDIR}"/VWR-8454-slviewer-0-v12160-MissingKeyword.patch
	epatch "${FILESDIR}"/VWR-8783-slviewer-0-v12160-LostConnectionOnLogin.patch
	epatch "${FILESDIR}"/VWR-9400-slviewer-0-v12160-LlhttpclientMemLeak.patch
	epatch "${FILESDIR}"/VWR-12454-slviewer-0-v12160-NewNotecardSaveButton.patch
	use openal || epatch "${FILESDIR}"/slviewer-0-v122110-DefaultToFmod.patch
	epatch "${FILESDIR}"/VWR-12686-slviewer-0-v122110-CacheSmallTextures.patch
	epatch "${FILESDIR}"/VWR-8827-slviewer-0-v122110-SaveScriptsAsMono.patch
	epatch "${FILESDIR}"/SNOW-108-fixfasttimers.diff
	epatch "${FILESDIR}"/VWR-14914-beacon.diff
	epatch "${FILESDIR}"/VWR-14914-v7.diff
	
	# UI reverts, changes, or reinstate removed features
	epatch "${FILESDIR}"/VWR-1919-slviewer-0-v12100-ReinstateShowTextureUUID.patch
	epatch "${FILESDIR}"/slviewer-0-v12160-MaxNetworkBandwidth.patch

	if use extras ; then
	  epatch "${FILESDIR}"/slviewer-0-v11913-DebugSettingsShortcutCtrlAltS.patch
	  epatch "${FILESDIR}"/slviewer-0-v12090-ShiftEscResetsCameraView.patch
	  # Spavenav support and joystick fixes, should be 1.23 and 1.24
	  epatch "${FILESDIR}"/VWR-6432-JoystickVehicles-v2_1.patch
	  # epatch "${FILESDIR}"/VWR-7800-FlycamExitNoReset.patch
	  epatch "${FILESDIR}"/VWR-10717-JoyFlyToggleV2_1.patch
	  epatch "${FILESDIR}"/VWR-11100-FlycamAppFocus.patch
	  
	  # feature patches from pjira, due to go in 1.23
	  epatch "${FILESDIR}"/VWR-508-InventoryWornTab.patch
	  epatch "${FILESDIR}"/VWR-2085-shortcutfix.patch
	  # epatch "${FILESDIR}"/VWR-3060-slviewer-0-v12200-HideIMinChatConsole.patch # implemted using different setting
	  epatch "${FILESDIR}"/WVR-4826-slviewer-0-v12300-FriendshipAndCallingcardOffersIgnoreButton.patch
	  # epatch "${FILESDIR}"/VWR-6891-LoginMRUList_1.patch
	  epatch "${FILESDIR}"/SNOW-129_saved_logins_r2.patch
	  # epatch "${FILESDIR}"/VWR-1422-last_and_fave_locations.patch # outdated patch
	  epatch "${FILESDIR}"/slviewer-0-v120110-HideNotificationsInChat_1.patch
	  # epatch "${FILESDIR}"/VWR-8008-TexturePreviewAspectRatioV2.patch # commented to http-texture and passed QA on 1.23.2
	  # epatch "${FILESDIR}"/VWR-9203-slviewer-0-v122100-FlexibleSculpties.patch # not been ported to 1.23.2 yet
	  # one user, lobo, had patching problems with below patch
	  # epatch "${FILESDIR}"/VWR-10890-graphics_pref.patch # dragging window size can achive same result.
	  epatch "${FILESDIR}"/VWR-12631-MiniMapMaxPrimSize.patch # needs to have setting stick across sessions
	  
	  # build features from pjira, slated to go in 1.23
	  epatch "${FILESDIR}"/slviewer-0-v12160-ExpandedBuildTools_v2.patch # only changes couple spinners settings from 1 to .05
	  epatch "${FILESDIR}"/VWR-9287_Select_next_part_20081227.patch
	  epatch "${FILESDIR}"/VWR-12385-IncludeNextPart.patch

	  # Dale Glass avatar scanner
	  epatch "${FILESDIR}"/avatar_list.diff
	  epatch "${FILESDIR}"/avatar_list_2.diff
	  # Misc.
	  epatch "${FILESDIR}"/copybot_protection.patch
	  epatch "${FILESDIR}"/unlimited_length_sound_uploads.patch
	  epatch "${FILESDIR}"/VWR-12678_add_crash_to_core_option.patch
	  epatch "${FILESDIR}"/avatar_names_beacons.patch
	  # Techwolf Lupindo created patches.
	  epatch "${FILESDIR}"/BuyBeacons.patch
	  # epatch "${FILESDIR}"/moreHUDs.patch # doesn't work, the extra huds are seeable by non-patch clients.
	fi
}

# Linden Labs use ./develop.py to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	mycmakeargs="-DSTANDALONE:BOOL=TRUE
		     -DAPP_SHARE_DIR:STRING=${GAMES_DATADIR}/${PN}
		     -DAPP_BINARY_DIR:STRING=${GAMES_DATADIR}/${PN}/bin
		     $(cmake-utils_use openal OPENAL)
		     $(cmake-utils_use gstreamer GSTREAMER)
		     $(cmake-utils_use llmozlib MOZLIB)
		     $(cmake-utils_use dbus DBUSGLIB)"
	if use fmod && ! use amd64 ; then
	  mycmakeargs="${mycmakeargs} -DFMOD:BOOL=TRUE"
	 else
	  mycmakeargs="${mycmakeargs} -DFMOD:BOOL=FALSE"
	fi
	# Linden Labs sse enabled processor build detection is broken, lets turn it on for
	# amd64 or (x86 and (sse or sse2))
	if { use amd64 || use sse || use sse2; }; then
	    append-flags "-DLL_VECTORIZE=1"
	fi
	# LL broke some code
	mycmakeargs="${mycmakeargs} -DGCC_DISABLE_FATAL_WARNINGS:BOOL=TRUE"
	# Don't package by default on LINUX
	mycmakeargs="${mycmakeargs} -DINSTALL:BOOL=TRUE" # somebody has very strange logic, INSTALL=No packageing. ?!
	# mycmakeargs="${mycmakeargs} -DPACKAGE:BOOL=FALSE"
	# Overide and set build type to "Release" instead of "Gentoo"
	CMAKE_BUILD_TYPE="Release"
	cmake-utils_src_configure
}
src_compile() {
	# CMAKE_VERBOSE=on
	cmake-utils_src_compile
}

src_install() {
	# Linden Labs uses viewer_manifest.py to install instead of cmake install
	# Because viewer_manifest.py is not run by cmake, set up enveroment that cmakes does before running viewer_manifest.py
	cd "${WORKDIR}"/linden/indra/newview/
	# MY_ARCH="i686" only adds libs supplied by LL for !standalone builds.
	# The file list for standalone on i686 matches x86_64 but for one extra file that is of no harm on x86
	MY_ARCH="x86_64"
	MY_VIEWER_CHANNEL="$(grep VIEWER_CHANNEL ${CMAKE_BUILD_DIR}/CMakeCache.txt | sed -e 's/VIEWER_CHANNEL:STRING=//')"
	MY_VIEWER_LOGIN_CHANNEL="$(grep VIEWER_LOGIN_CHANNEL ${CMAKE_BUILD_DIR}/CMakeCache.txt | sed -e 's/VIEWER_LOGIN_CHANNEL:STRING=//')"
	# fake stripped bins so viewer_manifest.py works and let portage do the stripping or split-debug files.
	cp -p "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger" "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger-stripped" || die
	cp -p "${CMAKE_BUILD_DIR}/newview/secondlife-bin" "${CMAKE_BUILD_DIR}/newview/secondlife-stripped" || die
	"${WORKDIR}"/linden/indra/newview/viewer_manifest.py  --actions="copy" --channel="${MY_VIEWER_CHANNEL}" \
	    --login_channel="${MY_VIEWER_LOGIN_CHANNEL}" --arch="${MY_ARCH}" --build="${CMAKE_BUILD_DIR}/newview" --dest="${D}/${GAMES_DATADIR}/${PN}" || die
	
	# Set proper channel name and keep settings seperate from other installs. Current build default: --channel "Developer"  --settings settings_developer.xml
	echo '--channel "Second Life Release" --settings settings_gentoo.xml' > "${D}/${GAMES_DATADIR}/${PN}/gridargs.dat" || die
	
	# llmozlib is not packed with secondlife, symbolic link it to the proper place.
	use llmozlib && ln -s "../../../../../usr/$(get_libdir)/llmozlib2/runtime_release" "${D}/${GAMES_DATADIR}/${PN}/app_settings/mozilla-runtime-linux-i686"
	
	# check for and intall crashlogger
	if [[ ! -f "${GAMES_DATADIR}/${PN}/linux-crash-logger.bin" ]] ; then
	  exeinto "${GAMES_DATADIR}/${PN}"
	  newexe "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger-stripped" linux-crash-logger.bin || die
	fi
	
	# vivox will work with a 64 bit build with 32 bit emul libs.
	if use vivox ; then
		exeinto "${GAMES_DATADIR}/${PN}/bin"
		doexe vivox-runtime/i686-linux/SLVoice || die
		exeinto "${GAMES_DATADIR}/${PN}/lib"
		doexe vivox-runtime/i686-linux/lib* || die
	fi
	
	# gentoo specific stuff
	games_make_wrapper "${PN}" ./secondlife "${GAMES_DATADIR}/${PN}" "/usr/$(get_libdir)/llmozlib2"
	newicon res/ll_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Second Life" "${PN}"_icon.png
	prepgamesdirs
}

pkg_postinst() {
    games_pkg_postinst
    if use amd64 && use vivox ; then
      elog "The voice binary is 32 bit and may have problems in 64 bit"
      elog "systems with greater then 4G of RAM. See this thread for details"
      elog "http://www.nvnews.net/vbulletin/showthread.php?t=127984"
    fi
}

