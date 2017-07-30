# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2017 Techwolf Lupindo

EAPI="6"

EHG_COMMIT="d55e117c0073"
BITBUCKETNAME="NickyD/llglod"

inherit cmake-utils webvcs

DESCRIPTION="NickyD impleatation of Linden Lab 3p-glod"
HOMEPAGE="https://bitbucket.org/NickyD/llglod"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_install() {
	cmake-utils_src_install
	# LL changed to libGLOD, so make a copy of both for either LL or TPV viewers.
	cp -p ${D}/usr/lib/libglod.so ${D}/usr/lib/libGLOD.so
}
