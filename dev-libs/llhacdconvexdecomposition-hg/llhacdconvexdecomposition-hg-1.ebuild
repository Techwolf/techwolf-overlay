# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit base mercurial cmake-utils

DESCRIPTION="NickD impleatation of Linden Lab convexdecomposition stub with HACD"
HOMEPAGE="https://bitbucket.org/NickyD/convexdecompositionhacd"
EHG_REPO_URI="https://bitbucket.org/NickyD/convexdecompositionhacd"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_unpack() {
	mercurial_src_unpack
}

src_install() {
	cd "${S}"
	dolib.a ${CMAKE_BUILD_DIR}/Source/lib/libnd_hacdConvexDecomposition.a
	dolib.a ${CMAKE_BUILD_DIR}/Source/HACD_Lib/libhacd.a
	insinto /usr/include/hacd
	cp Source/lib/LLConvexDecomposition.h Source/lib/llconvexdecomposition.h
	doins Source/lib/llconvexdecomposition.h
	doins Source/lib/ndConvexDecomposition.h
	doins Source/HACD_Lib/inc/*.h
}