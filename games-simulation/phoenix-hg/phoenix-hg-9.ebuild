# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. Lastest version at http://gentoo.techwolf.net/

EAPI="2"
MY_LLCODEBASE="130"
inherit secondlife mercurial

IUSE="${IUSE} pulseaudio libopenjpeg2"

MY_VIVOX="http://automated-builds-secondlife-com.s3.amazonaws.com/hg/repo/3p-slvoice/rev/231678/arch/Linux/installer/slvoice-3.2.0002.10426-linux-20110601.tar.bz2"

DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://www.phoenixviewer.com/"
SRC_URI="vivox? ( ${MY_VIVOX} )"

EHG_REPO_URI="http://hg.phoenixviewer.com/phoenix-sg/"

SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="${RDEPEND}
	app-text/hunspell"

DEPEND="${DEPEND}
	app-arch/p7zip
	dev-libs/libgpg-error
	>=dev-libs/libgcrypt-1.2.0
	x11-libs/libnotify
	dev-libs/llhacdconvexdecomposition-hg
	dev-libs/glod-hg"

src_unpack() {
	# When using svc, S is the directory the checkout is copied into.
	# Set it so it matches src tarballs.
	S="${WORKDIR}/linden"
	EHG_REPO_URI="http://hg.phoenixviewer.com/phoenix-sg/"
	mercurial_src_unpack

	cd "${WORKDIR}/linden"
	# remove not needed source code
	rm -fr "${WORKDIR}"/linden/indra/libgcrypt
	rm -fr "${WORKDIR}"/linden/indra/libgpg-error

	use vivox && unpack ${MY_VIVOX##*/}

	#copy 7za from the system, sybolic link won't work.
	cp -p /usr/lib/p7zip/7za "${WORKDIR}/linden/indra/newview/linux_tools/"

	EHG_REVISION=""
	S="${WORKDIR}/colladadom"
	EHG_REPO_URI="https://bitbucket.org/lindenlab/colladadom"
	mercurial_src_unpack

	S="${WORKDIR}/linden"

}

src_prepare() {
	mycmakeargs="${mycmakeargs} $(cmake-utils_use libopenjpeg2 LIBOPENJPEG2)"
	secondlife_src_prepare

	# don't download Binaries
	sed -i -e "s/\.\/fetch_bins.sh/# \.\/fetch_bins.sh/" "${WORKDIR}/linden/indra/newview/linux_tools/wrapper.sh" || die "wrapper.sh sed failed"

	# Change to Gentoo
	sed -i -e "s/Phoenix Viewer Internal/Phoenix Viewer Gentoo/" "${WORKDIR}/linden/indra/llcommon/llversionviewer.h.in"

	# fixes to LL colladadom, remove hardcoded flags.
	sed -i -e 's/ccFlags += -m32//' "${WORKDIR}/colladadom/make/common.mk"
	sed -i -e 's/ccFlags += -m32//' "${WORKDIR}/colladadom/make/minizip.mk"
	sed -i -e 's:includeOpts += -Istage/packages/include/pcre::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += $(addprefix stage/packages/lib/release/,libpcrecpp.a libpcre.a )::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:includeOpts += -Istage/packages/include::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_system.a::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_filesystem.a::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_system-mt$(debug_suffix).a::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_filesystem-mt$(debug_suffix).a::' "${WORKDIR}/colladadom/make/dom.mk"

	# allow users to try out patches
	# put patches in /etc/portage/patches/{${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}/feature.patch
	epatch_user
}

# Linden Labs use ./develop.py to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	return
}
src_compile() {
	S="${WORKDIR}/colladadom"
	cd "${S}"
	emake CXX=g++ || die "emake failed"

	einfo "Done building colladadom"

	mkdir -p "${WORKDIR}/linden"/libraries/i686-linux/{lib_debug_client,lib_release_client}
	MY_STAGE="${WORKDIR}/linden/libraries/i686-linux/lib_release_client"
	cp "build/linux-1.4/libcollada14dom.so" "${MY_STAGE}/libcollada14dom.so"
        cp "build/linux-1.4/libcollada14dom.so.2" "${MY_STAGE}/libcollada14dom.so.2"
        cp "build/linux-1.4/libcollada14dom.so.2.2" "${MY_STAGE}/libcollada14dom.so.2.2"
        cp "build/linux-1.4/libminizip.so" "${MY_STAGE}/libminizip.so"

	MY_STAGE="${WORKDIR}/linden/libraries/i686-linux/lib_debug_client"
        cp "build/linux-1.4-d/libcollada14dom-d.so" "${MY_STAGE}/libcollada14dom-d.so"
        cp "build/linux-1.4-d/libcollada14dom-d.so.2" "${MY_STAGE}/libcollada14dom-d.so.2"
        cp "build/linux-1.4-d/libcollada14dom-d.so.2.2" "${MY_STAGE}/libcollada14dom-d.so.2.2"
        cp "build/linux-1.4-d/libminizip-d.so" "${MY_STAGE}/libminizip-d.so"
	
	mkdir -p "${WORKDIR}/linden/libraries/include/collada"
	MY_STAGE="${WORKDIR}/linden/libraries/include"
	cp -R include/* "${MY_STAGE}/collada"

	einfo "Done staging colladadom"

	S="${WORKDIR}/linden/indra"
	cd "${S}"
	secondlife_cmake_prep
	mycmakeargs="${mycmakeargs} $(cmake-utils_use pulseaudio PULSEAUDIO)"
	if has_version '>=app-text/hunspell-1.3'; then mycmakeargs="${mycmakeargs} -DHUNSPELL_NAMES=hunspell-1.3"; fi
	append-ldflags "-L${WORKDIR}/linden/libraries/i686-linux/lib_release_client"
	cmake-utils_src_configure
	cmake-utils_src_compile
}

src_install() {
	secondlife_viewer_manifest "--branding_id=snowglobe"
	cd "${WORKDIR}"/linden/libraries/i686-linux/lib_release_client/
	exeinto "${GAMES_DATADIR}/${PN}/lib"
	doexe lib*
	cd "${WORKDIR}"/linden/indra/newview/
	games_make_wrapper "${PN}" ./snowglobe "${GAMES_DATADIR}/${PN}"
	newicon res/phoenix_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Phoenix viewer" "${PN}"_icon
	prepgamesdirs
}
