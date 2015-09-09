# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit cmake-utils games

DESCRIPTION="Metaverse (SL) viewer with an emphasis on usability and bold changes"
HOMEPAGE="http://imprudenceviewer.org/"

SRC_URI="http://imprudenceviewer.org/download/source/Imprudence-source-1.1.0.zip
	http://secondlife.com/developers/opensource/downloads/2008/10/slviewer-artwork-viewer_1-21-r99587.zip
	http://secondlife.com/developers/opensource/downloads/2008/10/slviewer-linux-libs-viewer_1-21-r99587.tar.gz
	http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/glh_linear-linux-20080613.tar.bz2
	http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/SDL-1.2.5-linux-20080613.tar.bz2
	vivox? ( http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/vivox-linux-20080613.tar.bz2 )"

LICENSE=""
SLOT="0"
# KEYWORDS="~amd64 ~x86"
KEYWORDS=""
IUSE="+vivox +openal +llmozlib +gstreamer fmod"
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
	gstreamer? ( media-plugins/gst-plugins-meta )"
# media-plugins/gst-plugins-meta now handles all the USE flag plugins options.

DEPEND="${RDEPEND}
	dev-libs/boost
	dev-util/pkgconfig
	sys-devel/flex
	sys-devel/bison
	>=dev-lang/python-2.4
	>=dev-util/cmake-2.4.8"

S="${WORKDIR}/linden/indra"

pkg_setup() {
	use amd64 && use fmod && ewarn "fmod is only available on x86. Disabling fmod"
}

src_unpack() {
	unpack Imprudence-source-1.1.0.zip
	cd "${WORKDIR}/Imprudence-source-1.1.0"
	mv * ../ || die "Fail to move sources to linden directory"
	cd "${WORKDIR}"
	# libs only contain the font files
	unpack slviewer-linux-libs-viewer_1-21-r99587.tar.gz
	unpack slviewer-artwork-viewer_1-21-r99587.zip
	
	cd "${WORKDIR}"/linden
	
	# need glh/glh_linear.h that is not aviable in portage.
	# http://jira.secondlife.com/browse/VWR-9005
	unpack glh_linear-linux-20080613.tar.bz2
	
	# need the SDL package due to Linden Labs put mouse cursers in it.
	# http://jira.secondlife.com/browse/VWR-9475
	unpack SDL-1.2.5-linux-20080613.tar.bz2
	
	use vivox && unpack vivox-linux-20080613.tar.bz2
	 
}

src_prepare() { 
	# Gentoo and build fix patches
	cd "${S}"
	epatch "${FILESDIR}"/secondlife-cmake-llmozilla.patch
	epatch "${FILESDIR}"/secondlife-llmozlib-svn.patch

# 	epatch "${FILESDIR}"/VWR-9499-fix_keeping_dbus_stuff_together.patch
# 	epatch "${FILESDIR}"/VWR-11474-cmake_ndof.patch
# 	cd "${WORKDIR}"/linden
# 	epatch "${FILESDIR}"/cmakeInstall.patch
	epatch "${FILESDIR}"/VWR-9557-EnableBuildWithNvidiaOrMesaHeaders_1_22_4.patch
# 	# gcc 4.3 fixes
# 	epatch "${FILESDIR}"/VWR-4456-string_to_const.patch
# 	epatch "${FILESDIR}"/VWR-10001-message.patch
# 	epatch "${FILESDIR}"/secondlife-llcrashloggerlinux.patch
	
}

# Linden Labs use ./develop.py to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	mycmakeargs="-DSTANDALONE:BOOL=TRUE
		     -DCMAKE_BUILD_TYPE:STRING=RELEASE
		     -DAPP_SHARE_DIR:STRING=${GAMES_DATADIR}/${PN}
		     -DAPP_BINARY_DIR:STRING=${GAMES_DATADIR}/${PN}/bin
		     $(cmake-utils_use openal OPENAL)
		     $(cmake-utils_use gstreamer GSTREAMER)
		     $(cmake-utils_use llmozlib MOZLIB)
		     $(cmake-utils_use dbus DBUSGLIB)
		     -DROOT_PROJECT_NAME:STRING=Imprudence"
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
	cmake-utils_src_configure
}
src_compile() {
	# CMAKE_VERBOSE=on
	cmake-utils_src_compile
}

src_install() {
	# Linden Labs uses viewer_manifest.py to install instead of cmake install
	# Because viewer_manifest.py is not called by cmake, set up enveroment that cmakes does before calling viewer_manifest.py
	cd "${S}"/newview/
	# MY_ARCH="i686" only adds libs supplied by LL for NOT standalone builds.
	# The file list for standalone on i686 matches x86_64 but for one extra file that is of no harm on x86
	MY_ARCH="x86_64"
	MY_VIEWER_CHANNEL="$(grep VIEWER_CHANNEL ${CMAKE_BUILD_DIR}/CMakeCache.txt | sed -e 's/VIEWER_CHANNEL:STRING=//')"
	MY_VIEWER_LOGIN_CHANNEL="$(grep VIEWER_LOGIN_CHANNEL ${CMAKE_BUILD_DIR}/CMakeCache.txt | sed -e 's/VIEWER_LOGIN_CHANNEL:STRING=//')"
	cp -p "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger" "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger-stripped" || die
	cp -p "${CMAKE_BUILD_DIR}/newview/imprudence-bin" "${CMAKE_BUILD_DIR}/newview/imprudence-stripped" || die
	"${WORKDIR}"/linden/indra/newview/viewer_manifest.py  --actions="copy" --channel="${MY_VIEWER_CHANNEL}" \
	    --login_channel="${MY_VIEWER_LOGIN_CHANNEL}" --arch="${MY_ARCH}" --build="${CMAKE_BUILD_DIR}/newview" --dest="${D}/${GAMES_DATADIR}/${PN}" || die
	
	# llmozlib is not packed with secondlife, symbolic link it to the proper place.
	use llmozlib && ln -s "../../../../../usr/$(get_libdir)/llmozlib2/runtime_release" "${D}/${GAMES_DATADIR}/${PN}/app_settings/mozilla-runtime-linux-i686"
	
	# check for and intall crashlogger
	if [[ ! -f "${GAMES_DATADIR}/${PN}/linux-crash-logger.bin" ]] ; then
	  exeinto "${GAMES_DATADIR}/${PN}"
	  newexe "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger" linux-crash-logger.bin || die
	fi
	
	# vivox will work with a 64 bit build with 32 bit emul libs.
	if use vivox ; then
		exeinto "${GAMES_DATADIR}/${PN}/bin"
		doexe vivox-runtime/i686-linux/SLVoice || die
		exeinto "${GAMES_DATADIR}/${PN}/lib"
		doexe vivox-runtime/i686-linux/lib* || die
	fi
	
	# gentoo specific stuff
	games_make_wrapper "${PN}" ./imprudence "${GAMES_DATADIR}/${PN}" "/usr/$(get_libdir)/llmozlib2"
	newicon res/imprudence_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Imprudence" "${PN}"_icon.png
	prepgamesdirs
}
