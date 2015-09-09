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
MY_DATE="2009/03"
GLH_V="20080812"
SDL_V="20080818"
MY_X86="i686-gcc-4.1-20080915"
VIVOX_V="2.1.3010.6151-linux-20090218"
DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://secondlife.com/"
SRC_URI="http://secondlife.com/developers/opensource/downloads/${MY_DATE}/slviewer-src-${MY_PV}.tar.gz
	http://secondlife.com/developers/opensource/downloads/${MY_DATE}/slviewer-artwork-${MY_PV}.zip
	http://secondlife.com/developers/opensource/downloads/${MY_DATE}/slviewer-linux-libs-${MY_PV}.tar.gz
	amd64? ( http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/glh_linear-linux-${GLH_V}.tar.bz2 )
	x86?   ( http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/glh_linear-linux-${MY_X86}.tar.bz2 )
	amd64? ( http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/SDL-1.2.5-linux-${SDL_V}.tar.bz2 )
	x86?   ( http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/SDL-1.2.5-linux-${MY_X86}.tar.bz2 )
	vivox? ( http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/vivox-${VIVOX_V}.tar.bz2 )
	coolsl? ( http://sldev.free.fr/patches/122110/slviewer-0-v12160-RevertUIchanges_v8-artwork-patch.zip )"

LICENSE="GPL-2-with-Linden-Lab-FLOSS-exception"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# KEYWORDS=""

IUSE="+vivox +openal +llmozlib +gstreamer +extras coolsl restrainedlife fmod dbus alsa oss esd pulse"
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
	dev-libs/dbus-glib
	dev-libs/expat
	sys-libs/zlib
	>=dev-libs/xmlrpc-epi-0.51-r1
	media-libs/openjpeg
	media-libs/libpng
	x11-libs/pango
	llmozlib? ( net-libs/llmozlib2 )
	gstreamer? ( media-libs/gst-plugins-base
		    media-plugins/gst-plugins-soup
		    media-plugins/gst-plugins-mad
		    media-plugins/gst-plugins-ffmpeg
		    alsa? ( media-plugins/gst-plugins-alsa )
		    oss? ( media-plugins/gst-plugins-oss )
		    esd? ( media-plugins/gst-plugins-esd )
		    pulse? ( media-plugins/gst-plugins-pulse ) )"

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
	
	# Unset all locale related variables, they can make the
	# patches and build fail.
	eval unset ${!LC_*} LANG LANGUAGE
	#  set LINGUAS to en for the build tools, may fix an international build bug.
	export LINGUAS=en
}

src_unpack() {
	# libs contains the font files
	unpack slviewer-linux-libs-${MY_PV}.tar.gz
	unpack slviewer-src-${MY_PV}.tar.gz
	unpack slviewer-artwork-${MY_PV}.zip
	use coolsl && unpack slviewer-0-v12160-RevertUIchanges_v8-artwork-patch.zip
	cd "${WORKDIR}"/linden
	
	# need glh/glh_linear.h that is not aviable in portage.
	# http://jira.secondlife.com/browse/VWR-9005
	use amd64 && unpack glh_linear-linux-${GLH_V}.tar.bz2
	use x86 && unpack glh_linear-linux-${MY_X86}.tar.bz2
	
	# need the SDL package due to Linden Labs put mouse cursers in it.
	# http://jira.secondlife.com/browse/VWR-9475
	use amd64 && unpack SDL-1.2.5-linux-${SDL_V}.tar.bz2
	use x86 && unpack SDL-1.2.5-linux-${MY_X86}.tar.bz2
	
	use vivox && unpack vivox-${VIVOX_V}.tar.bz2
}

src_prepare() {
	# fix version info
# 	sed -i \
# 	  -e "s/const S32 LL_VERSION_BUILD = 0;/const S32 LL_VERSION_BUILD = ${SECONDLIFE_REVISION};/" \
# 	  llcommon/llversionviewer.h || die "version sed failed"
	  
	# Gentoo and build fix patches
	cd "${S}"
	epatch "${FILESDIR}"/secondlife-cmake-llmozilla.patch
	epatch "${FILESDIR}"/secondlife-llmozlib-svn.patch
	epatch "${FILESDIR}"/VWR-9256.patch
	epatch "${FILESDIR}"/VWR-9499-fix_keeping_dbus_stuff_together.patch
	epatch "${FILESDIR}"/VWR-11474-cmake_ndof.patch
	cd "${WORKDIR}"/linden
	epatch "${FILESDIR}"/cmakeInstall.patch
	epatch "${FILESDIR}"/VWR-9557-EnableBuildWithNvidiaOrMesaHeaders_1_22_4.patch
	# gcc 4.3 fixes
	epatch "${FILESDIR}"/VWR-4456-string_to_const.patch
	epatch "${FILESDIR}"/VWR-10001-message.patch
	epatch "${FILESDIR}"/secondlife-llcrashloggerlinux.patch
	

	# bugfixes
	epatch "${FILESDIR}"/VWR-4137-GroupInfoDates.patch
	epatch "${FILESDIR}"/VWR-9257-tofu.patch
	# this patch will crash on startup without or default settings file
	# epatch "${FILESDIR}"/VWR-11068-spillover.patch
	epatch "${FILESDIR}"/SVC-580-slviewer-0-v11843-LpecRpecSwapped.patch
	epatch "${FILESDIR}"/slviewer-0-v11843-PossibleCrashAndLeakAssetStorage.patch
	epatch "${FILESDIR}"/VWR-1294-slviewer-0-v11843-WorkerThreadWhenTerminating.patch
	use coolsl && epatch "${FILESDIR}"/VWR-1603-slviewer-0-v11843-Duckwalk.patch
	epatch "${FILESDIR}"/VWR-2003-slviewer-0-v11843-PossibleCrashDragAndDrop.patch
	epatch "${FILESDIR}"/VWR-2683-slviewer-0-v11843-PossibleCrashSpeakerList.patch
	use coolsl && epatch "${FILESDIR}"/VWR-2876-slviewer-0-v11860-KeepCachedSounds.patch
	epatch "${FILESDIR}"/VWR-4371-slviewer-0-v11905-AmbiantMasterVolume.patch
	epatch "${FILESDIR}"/VWR-10837-slviewer-0-v11905-LLimageTGA_DeleteColorMapFix.patch
	epatch "${FILESDIR}"/VWR-9127-slviewer-0-v11905-EditKeysInDialogs.patch
	epatch "${FILESDIR}"/VWR-9517-slviewer-0-v11905-LlfontglRenderWrongParams.patch
	epatch "${FILESDIR}"/VWR-9620-slviewer-0-v11905-SendParcelSelectObjectsWrongReturnType.patch
	epatch "${FILESDIR}"/VWR-3616-slviewer-0-v120130-LandmarksDiscardButton_v2.patch
	epatch "${FILESDIR}"/VWR-5530-slviewer-0-v120150-RememberMinimizedFloatersPosition.patch
	epatch "${FILESDIR}"/slviewer-0-v12100-NoMultipleLocaleWarnings.patch
	epatch "${FILESDIR}"/VWR-5575-slviewer-0-v12160-FilePickerLocaleCrash.patch
	use coolsl && epatch "${FILESDIR}"/VWR-7896-slviewer-0-v12160-VisitedLandmarks.patch
	epatch "${FILESDIR}"/VWR-8454-slviewer-0-v12160-MissingKeyword.patch
	epatch "${FILESDIR}"/VWR-8783-slviewer-0-v12160-LostConnectionOnLogin.patch
	epatch "${FILESDIR}"/VWR-9400-slviewer-0-v12160-LlhttpclientMemLeak.patch
	epatch "${FILESDIR}"/VWR-12454-slviewer-0-v12160-NewNotecardSaveButton.patch
	use openal || epatch "${FILESDIR}"/slviewer-0-v122110-DefaultToFmod.patch
	epatch "${FILESDIR}"/VWR-10759-slviewer-0-v12280-LlmediaImplGstreamerFix.patch
	epatch "${FILESDIR}"/VWR-12686-slviewer-0-v122110-CacheSmallTextures.patch
	epatch "${FILESDIR}"/VWR-8827-slviewer-0-v122110-SaveScriptsAsMono.patch
	epatch "${FILESDIR}"/VWR-12789-dbus-20090412.diff
	
	# UI reverts, changes, or reinstate removed features
	epatch "${FILESDIR}"/VWR-1919-slviewer-0-v12100-ReinstateShowTextureUUID.patch
	use coolsl && epatch "${FILESDIR}"/VWR-2290-slviewer-0-v12100-AllowDiscardForCreator.patch
	use coolsl && epatch "${FILESDIR}"/VWR-1752-slviewer-0-v11905-InventoryDoubleClickActions_v2.patch
	use coolsl && epatch "${FILESDIR}"/slviewer-0-v11905-MoonBrightness.patch
	use extras && ! use restrainedlife && epatch "${FILESDIR}"/slviewer-0-v11913-DebugSettingsShortcutCtrlAltS.patch
	use extras && epatch "${FILESDIR}"/slviewer-0-v12090-ShiftEscResetsCameraView.patch
	use coolsl && epatch "${FILESDIR}"/slviewer-0-v120130-LargePrims.patch
	use extras && epatch "${FILESDIR}"/slviewer-0-v120150-ShiftReturnWhisper.patch
	use coolsl && epatch "${FILESDIR}"/slviewer-0-v12100-ReinstateOldSearchTabs_v2.patch
	use coolsl && ! use restrainedlife && epatch "${FILESDIR}"/VWR-3093-slviewer-0-v122110-MUposeStyleAndOOCautoClose_v2.patch
	epatch "${FILESDIR}"/slviewer-0-v12160-MaxNetworkBandwidth.patch
	use coolsl && epatch "${FILESDIR}"/slviewer-0-v122110-MoreGridsDynamic.patch
	use coolsl && epatch "${FILESDIR}"/VWR-2808-slviewer-0-v12200-OldTrackingDotsInMinimap.patch
	use coolsl && epatch "${FILESDIR}"/slviewer-0-v12230-TeleportHistory.patch
	use coolsl && epatch "${FILESDIR}"/slviewer-0-v122110-CoolPreferences_v8.patch
	use coolsl && epatch "${FILESDIR}"/VWR-721-slviewer-0-v12270-CommonDateAndTimeFormats.patch
	use coolsl && epatch "${FILESDIR}"/slviewer-0-v12280-RevertUIchanges_v8.patch
	use coolsl || epatch "${FILESDIR}"/VWR-7913-slviewer-0-v12160-TeleportHistory.patch # due in 1.23
	use coolsl && use restrainedlife && epatch "${FILESDIR}"/slviewer-1-v11905-InventoryDoubleClickActions_v2_RestrainedLife_addon.patch
	use restrainedlife && epatch "${FILESDIR}"/slviewer-1-v12160-TeleportHistory_RestrainedLife_addon_v2.patch
	use restrainedlife && epatch "${FILESDIR}"/slviewer-2-v122110-RestrainedLife_v116f.patch
	# use restrainedlife && epatch "${FILESDIR}"/slviewer-9-v12160-AdjustRejects.patch

	if use extras ; then
	  # Spavenav support and joystick fixes, should be 1.23
	  epatch "${FILESDIR}"/VWR-5297-spacenav02-linden.patch
	  epatch "${FILESDIR}"/VWR-6358-JoystickOKCancel-V3.patch
	  epatch "${FILESDIR}"/VWR-6482-JoystickUnconstrainedv2.patch
	  epatch "${FILESDIR}"/VWR-6550-JoystickRun-For-VWR-6482.patch
	  epatch "${FILESDIR}"/VWR-6432-JoystickVehicles-v2.patch
	  use coolsl || epatch "${FILESDIR}"/VWR-8341-FlycamIndicator.patch
	  # use coolsl && epatch "${FILESDIR}"/VWR-8341a-FlycamIndicator.patch
	  epatch "${FILESDIR}"/VWR-6348-VWR-7383-MoveInBuildAndClearAFK.patch
	  epatch "${FILESDIR}"/VWR-7800-FlycamExitNoReset.patch
	  epatch "${FILESDIR}"/VWR-10717-JoyFlyToggleV2.patch
	  epatch "${FILESDIR}"/VWR-11100-FlycamAppFocus.patch
	  
	  # feature patches from pjira, due to go in 1.23
	  epatch "${FILESDIR}"/VWR-508-InventoryWornTab.patch
	  epatch "${FILESDIR}"/VWR-2085-shortcutfix.patch
	  epatch "${FILESDIR}"/VWR-2681-TabbedResidentChooser.patch
	  epatch "${FILESDIR}"/VWR-9540-stats_bar_persistent_pos.patch
	  epatch "${FILESDIR}"/VWR-3060-slviewer-0-v12200-HideIMinChatConsole.patch
	  epatch "${FILESDIR}"/VWR-4826-slviewer-0-v12260-FriendshipAndCallingcardOffersIgnoreButton.patch
	  # may be causing crash on startup, tested without it, still crashes without it
	  epatch "${FILESDIR}"/VWR-6891-LoginMRUList.patch
	  # epatch "${FILESDIR}"/VWR-1422-last_and_fave_locations.patch # outdated patch
	  epatch "${FILESDIR}"/slviewer-0-v120110-HideNotificationsInChat.patch
	  epatch "${FILESDIR}"/VWR-8008-TexturePreviewAspectRatioV2.patch
	  epatch "${FILESDIR}"/VWR-8080-attachment_pie_menu.patch
	  epatch "${FILESDIR}"/VWR-9203-slviewer-0-v122100-FlexibleSculpties.patch
	  # one user, lobo, had patching problems with below patch
	  # epatch "${FILESDIR}"/VWR-10890-graphics_pref.patch
	  epatch "${FILESDIR}"/VWR-12631-MiniMapMaxPrimSize.patch
	  
	  # build features from pjira, slated to go in 1.23
	  epatch "${FILESDIR}"/VWR-7827+box+dimple+3.patch
	  epatch "${FILESDIR}"/VWR-7877+cut+default.patch
	  epatch "${FILESDIR}"/slviewer-0-v12160-ExpandedBuildTools_v2.patch
	  epatch "${FILESDIR}"/VWR-9287_Select_next_part_20081227.patch
	  epatch "${FILESDIR}"/VWR-12385-IncludeNextPart.patch
	  epatch "${FILESDIR}"/VWR-5082-slviewer-0-v12200-BulkSetPermissions_v2.patch
	  # Dale Glass avatar scanner
	  epatch "${FILESDIR}"/avatar_list_ex.patch
	  use coolsl && epatch "${FILESDIR}"/avatar_list_cl.patch
	  use coolsl || epatch "${FILESDIR}"/avatar_list_ncl.patch
	  use restrainedlife && epatch "${FILESDIR}"/avatar_list_rl.patch
	  use restrainedlife || epatch "${FILESDIR}"/avatar_list_nrl.patch
	  # disable crashlogger so we can get core dumps
	  edos2unix "${WORKDIR}/linden/indra/newview/app_settings/cmd_line.xml"
	  epatch "${FILESDIR}"/VWR-12678_add_crash_to_core_option.patch
	fi
}

# Linden Labs use ./develop.py to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	mycmakeargs="-DSTANDALONE:BOOL=TRUE
		     -DCMAKE_BUILD_TYPE:STRING=RELEASE
		     -DINSTALL:BOOL=TRUE
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
	cmake-utils_src_configure
}
src_compile() {
	# CMAKE_VERBOSE=on
	cmake-utils_src_compile
}

# Linden Labs uses viewer_manifest.py to install instead of cmake install
src_install() {
	cd "${S}"/newview/
	# MY_ARCH="i686" only adds libs supplied by LL for NOT standalone builds.
	# The file list for standalone on i686 matches x86_64 but for one extra file that is of no harm on x86
	MY_ARCH="x86_64"
	# BUG:there is no secondlife-stripped, create non-stripped one for viewer_manifest.py and let portage do the stripping.
	mv "${CMAKE_BUILD_DIR}/newview/secondlife-bin" "${WORKDIR}/linden/indra/newview/secondlife-stripped" || die
	"${S}"/newview/viewer_manifest.py  --actions="copy" --arch="${MY_ARCH}" --dest="${D}/${GAMES_DATADIR}/${PN}" || die
	
	# Set proper channel name and keep settings seperate from other installs.
	echo '--settings settings_gentoo.xml' >> "${D}/${GAMES_DATADIR}/${PN}/gridargs.dat" || die
	
	# llmozlib is not packed with secondlife, symbolic link it to the proper place.
	use llmozlib && ln -s "../../../../../usr/$(get_libdir)/llmozlib2/runtime_release" "${D}/${GAMES_DATADIR}/${PN}/app_settings/mozilla-runtime-linux-i686"
	
	# install crashlogger
	exeinto "${GAMES_DATADIR}/${PN}"
	newexe "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger" linux-crash-logger.bin || die
	
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

