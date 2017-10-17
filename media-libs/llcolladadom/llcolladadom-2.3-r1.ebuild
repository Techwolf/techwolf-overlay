# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2012-2017 Techwolf Lupindo

EAPI="6"

EHG_COMMIT="5658b68153ba"
BITBUCKETNAME="lindenlab/3p-colladadom"

inherit flag-o-matic webvcs

DESCRIPTION="Linden Labs fork of colladadom"
HOMEPAGE="https://bitbucket.org/lindenlab/3p-colladadom"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-libs/boost
        dev-libs/libxml2
        sys-libs/zlib[minizip]
        dev-libs/libpcre"
RDEPEND="${DEPEND}"

src_prepare() {
	# fix hardcoded CFLAGS
	sed -i -e 's/ccFlags += -m32//' "${S}/make/common.mk"
	sed -i -e "s/-O2/${CFLAGS}/" "${S}/make/common.mk"

	# remove prebuilts includes
	sed -i -e '/stage\/packages\/lib\//d' "${S}/make/dom.mk"

	# DRTVWR-418: clang doesn't like returning 'false' for a pointer.
	epatch "${FILESDIR}"/return_null.patch

	if test-flag-CXX -std=c++11 ; then
	  # DRTVWR-418: Replace buggy varargs functions with variadic templates.
	  epatch "${FILESDIR}"/64_bit_c11.patch
	fi
	
	# required for EAPI 6
        eapply_user
}

src_compile() {
	if test-flag-CXX -std=c++11 ; then
	  append-cxxflags -std=c++11
	fi
	append-cflags "-I/usr/include/minizip -I/usr/include/libxml2"
	append-cxxflags "-I/usr/include/minizip -I/usr/include/libxml2"
	emake CXX=g++ conf=release project=dom
}

src_install () 
{
	dolib.a build/linux-1.4/libcollada14dom.a

	mkdir -p "${D}usr/include/collada"
	cp -R include/* "${D}usr/include/collada"
	rm -r "${D}usr/include/collada/1.5"
}
