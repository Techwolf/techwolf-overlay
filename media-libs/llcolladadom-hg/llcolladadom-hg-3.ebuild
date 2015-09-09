# Copyright 2012 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit base flag-o-matic mercurial

DESCRIPTION="Linden Labs fork of colladadom"
HOMEPAGE="https://bitbucket.org/lindenlab/3p-colladadom"
EHG_REPO_URI="https://bitbucket.org/lindenlab/3p-colladadom"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/boost
        dev-libs/libxml2
        sys-libs/zlib"
RDEPEND="${DEPEND}"

src_unpack() {
	mercurial_src_unpack
}

src_prepare() {
	# fix hardcoded CFLAGS
	sed -i -e 's/ccFlags += -m32//' "${S}/make/common.mk"
	sed -i -e "s/-O2/${CFLAGS}/" "${S}/make/common.mk"
	sed -i -e 's/ccFlags += -m32//' "${S}/make/minizip.mk"
	# remove prebuilts includes
	sed -i -e 's:includeOpts += -Istage/packages/include/pcre::' "${S}/make/dom.mk"
	sed -i -e 's:libOpts += $(addprefix stage/packages/lib/release/,libpcrecpp.a libpcre.a )::' "${S}/make/dom.mk"
	sed -i -e 's:includeOpts += -Istage/packages/include::' "${S}/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_system.a::' "${S}/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_filesystem.a::' "${S}/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_system-mt$(debug_suffix).a::' "${S}/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_filesystem-mt$(debug_suffix).a::' "${S}/make/dom.mk"

	# allow users to try out patches
	# put patches in /etc/portage/patches/{${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}/feature.patch
	epatch_user
}

src_compile() {
	cd "${S}"
	append-cflags "-I/usr/include/minizip -I/usr/include/libxml2"
	append-cxxflags "-I/usr/include/minizip -I/usr/include/libxml2"
	emake CXX=g++ conf=release project=dom || die "emake failed"
}

src_install () 
{
	dolib.a build/linux-1.4/libcollada14dom.a

	mkdir -p "${D}usr/include/collada"
	cp -R include/* "${D}usr/include/collada"
}