# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. Lastest version at http://gentoo.techwolf.net/

EAPI="5"
MY_LLCODEBASE="263"
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

	if [[ ! -f "${WORKDIR}/linden/indra/llwindow/glh/glh_linear.h" ]] ; then
	  # need glh/glh_linear.h that is not aviable in portage.
	  # http://jira.secondlife.com/browse/VWR-9005
	  get_install_xml_value "glh_linear"
	  unpack ${SLASSET##*/} || die "Problem with unpacking ${SLASSET##*/}"
	 else
	  einfo "glh_linear.h found, not downloading glh package."
	fi

	if use vivox ; then
	  get_install_xml_value "slvoice"
	  unpack ${SLASSET##*/} || die "Problem with unpacking ${SLASSET##*/}"
	fi

	EHG_REVISION=""
	S="${WORKDIR}/colladadom"
	EHG_REPO_URI="https://bitbucket.org/lindenlab/colladadom"
	mercurial_src_unpack
	S="${WORKDIR}/llconvexdecomposition"
	EHG_REPO_URI="https://bitbucket.org/lindenlab/llconvexdecomposition"
	mercurial_src_unpack
	S="${WORKDIR}/glod"
	EHG_REPO_URI="https://bitbucket.org/lindenlab/glod"
	mercurial_src_unpack

	S="${WORKDIR}/linden"
}

src_prepare() {
	cp -p "${WORKDIR}/linden/indra/llcommon/llversionviewer.h.in" "${WORKDIR}/linden/indra/llcommon/llversionviewer.h"
	secondlife_src_prepare

	# viewer 3 standalone build fixes, one missing include and cmake webkit fix.
	epatch "${FILESDIR}"/v3_standalone.patch

	# OPEN-38 patch
	epatch "${FILESDIR}"/v3_OPEN-36.patch

	# jsoncpp fixes, note that open-54 causes build errors, so different custom fix is used here.
	epatch "${FILESDIR}"/v3_jsoncpp.patch

	# fix permission
	chmod +x "${WORKDIR}/linden/indra/newview/viewer_manifest.py"

	# fixes to LL colladadom, remove hardcoded flags and make standalone compatiable.
	sed -i -e 's/ccFlags += -m32//' "${WORKDIR}/colladadom/make/common.mk"
	sed -i -e 's/ccFlags += -m32//' "${WORKDIR}/colladadom/make/minizip.mk"
	sed -i -e 's:includeOpts += -Istage/packages/include/pcre::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += $(addprefix stage/packages/lib/release/,libpcrecpp.a libpcre.a )::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:includeOpts += -Istage/packages/include::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_system.a::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_filesystem.a::' "${WORKDIR}/colladadom/make/dom.mk"

	# fix for llconvexdecomposition, missing #include and api fix.
	sed -i -e "s:#include <memory>:#include <memory>\n#include <string.h>:" "${WORKDIR}/llconvexdecomposition/Source/lib/LLConvexDecompositionStubImpl.cpp"
	sed -i -e 's:bool vertex_based:bool vertex_based = false:' "${WORKDIR}/llconvexdecomposition/Source/lib/LLConvexDecompositionStubImpl.h"
	sed -i -e 's:bool vertex_based:bool vertex_based = false:' "${WORKDIR}/llconvexdecomposition/Source/lib/LLConvexDecomposition.h"

	# fixes to glod, remove LL hardcoded flags.
	sed -i -e 's:cc=gcc-4.1::g' "${WORKDIR}/glod/Makefile.conf"
	sed -i -e 's:CC=g++-4.1::g' "${WORKDIR}/glod/Makefile.conf"
	sed -i -e 's:-m32::g' "${WORKDIR}/glod/src/Makefile"
	sed -i -e "s:-m32:${CFLAGS} -fPIC:g" "${WORKDIR}/glod/src/vds/Makefile"
	sed -i -e 's:-fno-stack-protector::g' "${WORKDIR}/glod/src/Makefile"
	sed -i -e 's:-fno-stack-protector::g' "${WORKDIR}/glod/src/vds/Makefile"
	sed -i -e 's:-fno-stack-protector::g' "${WORKDIR}/glod/src/xbs/Makefile"

	# fix permission
	chmod +x "${WORKDIR}/linden/indra/newview/viewer_manifest.py"

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
	# do cmake confure so we get CMAKE_BUILD_DIR defined, Linden Lab code expects packages to be in the cmake build directory. (Yea, it was a WTF moment when debugging this problem)
	S="${WORKDIR}/linden/indra"
	cd "${S}"
	secondlife_cmake_prep
	mycmakeargs="${mycmakeargs} $(cmake-utils_use pulseaudio PULSEAUDIO)"
	if has_version '>=app-text/hunspell-1.3'; then mycmakeargs="${mycmakeargs} -DHUNSPELL_NAMES=hunspell-1.3"; fi
	append-flags "-I${WORKDIR}/linden/include"
	append-ldflags "-L${CMAKE_BUILD_DIR}/packages/lib/release"
	cmake-utils_src_configure
	filter-ldflags "-L${CMAKE_BUILD_DIR}/packages/lib/release"
	filter-flags "-I${WORKDIR}/linden/include"

	S="${WORKDIR}/colladadom"
	cd "${S}"
	emake CXX=g++ || die "emake failed"

	einfo "Done building colladadom"

	mkdir -p "${CMAKE_BUILD_DIR}"/packages/lib/{debug,release}
	MY_STAGE="${CMAKE_BUILD_DIR}"/packages/lib/release
	cp "build/linux-1.4/libcollada14dom.so" "${MY_STAGE}/libcollada14dom.so"
        cp "build/linux-1.4/libcollada14dom.so.2" "${MY_STAGE}/libcollada14dom.so.2"
        cp "build/linux-1.4/libcollada14dom.so.2.2" "${MY_STAGE}/libcollada14dom.so.2.2"
        cp "build/linux-1.4/libminizip.so" "${MY_STAGE}/libminizip.so"

	MY_STAGE="${CMAKE_BUILD_DIR}"/packages/lib/debug
        cp "build/linux-1.4-d/libcollada14dom-d.so" "${MY_STAGE}/libcollada14dom-d.so"
        cp "build/linux-1.4-d/libcollada14dom-d.so.2" "${MY_STAGE}/libcollada14dom-d.so.2"
        cp "build/linux-1.4-d/libcollada14dom-d.so.2.2" "${MY_STAGE}/libcollada14dom-d.so.2.2"
        cp "build/linux-1.4-d/libminizip-d.so" "${MY_STAGE}/libminizip-d.so"
	
	mkdir -p "${CMAKE_BUILD_DIR}/packages/include/collada"
	MY_STAGE="${CMAKE_BUILD_DIR}/packages/include"
	cp -R include/* "${MY_STAGE}/collada"

	einfo "Done staging colladadom"

	S="${WORKDIR}/llconvexdecomposition"
	cd "${S}/Source"
	emake RELEASE_CXXFLAGS="${CXXFLAGS}" DEBUG_CXXFLAGS="${CXXFLAGS}" -C lib -f Makefile_stub || die "emake failed"
	einfo "Done building llconvexdecomposition"
	cp "lib/debug_stub/libllconvexdecompositionstub.a" "${CMAKE_BUILD_DIR}/packages/lib/debug/libllconvexdecompositionstub.a" || die "copying libllconvexdecompositionstub.a failed"
        cp "lib/release_stub/libllconvexdecompositionstub.a" "${CMAKE_BUILD_DIR}/packages/lib/release/libllconvexdecompositionstub.a" || die "copying libllconvexdecompositionstub.a failed"
	cp "lib/LLConvexDecomposition.h" "${CMAKE_BUILD_DIR}/packages/include/llconvexdecomposition.h" || die "copying llconvexdecomposition.h failed"
	einfo "Done staging llconvexdecomposition"

	S="${WORKDIR}/glod"
	cd "${S}"
	append-flags "-fPIC"
	make -C src clean
	make -j1 -C src release || die "emake failed"
	filter-flags "-fPIC"
	einfo "Done building glod"
	cp "lib/libGLOD.so" "${CMAKE_BUILD_DIR}/packages/lib/release/libglod.so" || die "copying libGLOD.so failed"
	mkdir -p "${CMAKE_BUILD_DIR}/packages/include/glod"
	cp "include/glod.h" "${CMAKE_BUILD_DIR}/packages/include/glod/glod.h" || die "copying glod.h failed"
	einfo "Done staging glod"

	S="${WORKDIR}/linden/indra"
	cmake-utils_src_compile
}

src_install() {
	# This used to be in src_prep untill Oz added contributions.txt processing for the help->about floater.
	# Will fail with ../../doc/contributions.txt not found during the extra viewer_manifest.py copy during build.
	# viewer_manifest.py will not copy all the files
	epatch "${FILESDIR}"/viewer_manifest_package.patch

	secondlife_viewer_manifest "--buildtype=${CMAKE_BUILD_TYPE}"

	# include the stuff from the extra packages built during src_compile
	cd "${CMAKE_BUILD_DIR}/packages/lib/release/"
	exeinto "${GAMES_DATADIR}/${PN}/lib"
	doexe lib*
	cd "${WORKDIR}"/linden/indra/newview/
	
	# gentoo specific stuff
	games_make_wrapper "${PN}" ./firestorm "${GAMES_DATADIR}/${PN}"
	newicon res/firestorm_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Second Life" "${PN}"_icon
	prepgamesdirs
}

