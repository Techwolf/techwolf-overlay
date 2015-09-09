# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit games cmake-utils subversion qt4 git

DESCRIPTION="realXtend Naali is a viewer for accessing 3D virtual worlds."
HOMEPAGE="http://www.realxtend.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-libs/boost-1.36.0
	>=dev-libs/poco-1.3.4
	>=dev-games/ogre-1.6.1
	>=x11-libs/qt-core-4.6.1
	x11-libs/qt-phonon
	dev-lang/python:2.6
	dev-libs/xmlrpc-epi
	dev-libs/expat
	net-misc/curl
	media-libs/openjpeg
	media-libs/openal
	>=net-libs/telepathy-farsight-0.0.12.1
	net-libs/telepathy-glib
	net-libs/telepathy-qt4
	media-plugins/gst-plugins-meta
	media-plugins/gst-plugins-soup
	net-libs/farsight2
	>=dev-libs/dbus-glib-0.78
	dev-libs/glib:2
	sys-apps/dbus
	dev-util/scons
	media-libs/celt
	dev-libs/openssl
	dev-libs/protobuf"
RDEPEND="${DEPEND}"

# override the qt4 eclass exported pkg_setup
pkg_setup() {
	return
}

src_unpack() {
	EGIT_COMMIT="develop"
	EGIT_BRANCH="develop"
	EGIT_REPO_URI="git://github.com/realXtend/naali.git"
	git_fetch
	S="${WORKDIR}/${P}/depends/Caelum"
	ESVN_REPO_URI="https://caelum.svn.sourceforge.net/svnroot/caelum/trunk/Caelum/"
	subversion_src_unpack
	S="${WORKDIR}/${P}/depends/PythonQt"
	ESVN_REPO_URI="https://pythonqt.svn.sourceforge.net/svnroot/pythonqt/branches/2.0.1"
	subversion_src_unpack
	S="${WORKDIR}/${P}/depends/propertyeditor"
	ESVN_REPO_URI="http://realxtend-naali-deps.googlecode.com/svn/trunk/propertyeditor"
	subversion_src_unpack
	S="${WORKDIR}/${P}/depends/QtPropertyBrowser"
	ESVN_REPO_URI="http://realxtend-naali-deps.googlecode.com/svn/trunk/qtpropertybrowser-2.5_1-opensource"
	subversion_src_unpack
	S="${WORKDIR}/${P}"
}

src_prepare() {
	# fix python-conf b0rkage. There is no python2.6-conf, only python-config-2.6
	sed -i -e 's/unix:PYTHON_VERSION=2.6/unix:PYTHON_VERSION=/' ${WORKDIR}/${P}/depends/PythonQt/build/python.prf || die "Failed to fix PythonQt python-config check"

	# Fix the cmake modules include. cmake doesn't use current $PWD as part of module search
	sed -i -e 's/${CMAKE_MODULE_PATH} CMakeModules/${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}\/CMakeModules/' "${S}/CMakeLists.txt" || die "Failed to fix cmake module path"

	# Leave out mumble requirement for now. naali looks for mumbleclient instead of mumble.
	sed -i -e 's:add_subdirectory (MumbleVoipModule):# add_subdirectory (MumbleVoipModule):' "${S}/CMakeOptionalModulesTemplate.txt" || die "Failed to remove mumbles requirment"
}

# overide any exported src_configure
src_configure() {
	return
}

# build and install prerequestests then build naali
src_compile() {
	MY_PREFIX="${S}/depends/install"
	mkdir -p $MY_PREFIX/lib
	mkdir -p $MY_PREFIX/include

	# build Caelum
	einfo "Building Caelum"
	S="${WORKDIR}/${P}/depends/Caelum"
	cd "${S}"
	scons ${MAKEOPTS} extra_ccflags="-fPIC -DPIC" || die "Build of Caelum failed"
	mkdir -p $MY_PREFIX/etc/OGRE
	cp plugins.cfg $MY_PREFIX/etc/OGRE/
	cp libCaelum.a $MY_PREFIX/lib/
	cp main/include/* $MY_PREFIX/include/

	# build YAPE - Yet Another Property Editor
	einfo "Building YAPE - Yet Another Property Editor"
	S="${WORKDIR}/${P}/depends/propertyeditor"
	cd "${S}"
	cmake-utils_src_configure
	cmake-utils_src_compile
	cd ../propertyeditor_build
	cp -a lib/libPropertyEditor.* $MY_PREFIX/lib/
	cd ../propertyeditor
	cp lib/property*.h $MY_PREFIX/include

	# build PythonQt
	einfo "Building PythonQt"
	S="${WORKDIR}/${P}/depends/PythonQt"
	cd "${S}"
	qt4_pkg_setup
	eqmake4 PythonQt.pro
	emake || die "build of PythonQt failed"
	rm -f $MY_PREFIX/lib/libPythonQt*
	cp -a lib/libPythonQt* $MY_PREFIX/lib/
	cp src/PythonQt*.h $MY_PREFIX/include/
	cp extensions/PythonQt_QtAll/PythonQt*.h $MY_PREFIX/include/

	# build QtPropertyBrowser
	einfo "Building QtPropertyBrowser"
	S="${WORKDIR}/${P}/depends/QtPropertyBrowser"
	cd "${S}"
	qt4_pkg_setup
	# accecpt {L}GPL license.
	# GPL does not have a "accecpt" clause, so automating it is ok.
	# Interactive "accecpt" is only require for the commercial version.
	# This is NOT the commercial version
	echo license accepted > .licenseAccepted
	# Build the component as a dynamic library
	echo "SOLUTIONS_LIBRARY = yes" > config.pri
	eqmake4 qtpropertybrowser.pro
	emake || die "build of QtPropertyBrowser failed"
	cp lib/lib* $MY_PREFIX/lib/
	# luckily only extensionless headers under src match Qt*:
	cp src/qt*.h src/Qt* $MY_PREFIX/include/

	# configure and build naali
	einfo "Building naali"
	S="${WORKDIR}/${P}"
	CMAKE_USE_DIR="${S}"
	cd "${S}"
	export NAALI_DEP_PATH="${MY_PREFIX}"
	append-flags "-I/usr/include/openjpeg -I/usr/include/xmlrpc-epi"
	CMAKE_IN_SOURCE_BUILD="ON"
	cmake-utils_src_configure
	cmake-utils_src_compile -j1
}

src_install() {
	mkdir -p "${D}/${GAMES_DATADIR}/${PN}"
	cd "${WORKDIR}/${P}/bin"
	cp -a * "${D}/${GAMES_DATADIR}/${PN}"
	
	# gentoo specific stuff
	games_make_wrapper "${PN}" ./viewer "${GAMES_DATADIR}/${PN}" "${GAMES_DATADIR}/${PN}/modules/core"
#	newicon res/snowglobe_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "naali tip"
	prepgamesdirs
}
