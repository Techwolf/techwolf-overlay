# Copyright 2012-2017 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit flag-o-matic

DESCRIPTION="Linden Labs fork of colladadom"
HOMEPAGE="https://bitbucket.org/lindenlab/3p-colladadom"
SRC_URI="https://bitbucket.org/lindenlab/3p-colladadom/get/5658b68153ba.tar.bz2"
RESTRICT="mirror"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/boost
        dev-libs/libxml2
        sys-libs/zlib[minizip]
        dev-libs/libpcre"
RDEPEND="${DEPEND}"

S="${WORKDIR}/lindenlab-3p-colladadom-5658b68153ba"


src_prepare() {
	# fix hardcoded CFLAGS
	sed -i -e 's/ccFlags += -m32//' "${S}/make/common.mk"
	sed -i -e "s/-O2/${CFLAGS}/" "${S}/make/common.mk"
	# remove prebuilts includes
	sed -i -e 's:includeOpts += -Istage/packages/include/pcre::' "${S}/make/dom.mk"
	sed -i -e 's:libOpts += $(addprefix stage/packages/lib/release/,libpcrecpp.a libpcre.a )::' "${S}/make/dom.mk"
	sed -i -e 's:includeOpts += -Istage/packages/include::' "${S}/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_system.a::' "${S}/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_filesystem.a::' "${S}/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_system-mt$(debug_suffix).a::' "${S}/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_filesystem-mt$(debug_suffix).a::' "${S}/make/dom.mk"

	eapply_user
}

src_compile() {
	cd "${S}"
	append-cflags "-I/usr/include/minizip -I/usr/include/libxml2"
	append-cxxflags "-I/usr/include/minizip -I/usr/include/libxml2"
	emake CXX=g++ conf=release project=dom
}

src_install () 
{
	dolib.a build/linux-1.4/libcollada14dom.a

	mkdir -p "${D}usr/include/collada"
	cp -R include/* "${D}usr/include/collada"
}
