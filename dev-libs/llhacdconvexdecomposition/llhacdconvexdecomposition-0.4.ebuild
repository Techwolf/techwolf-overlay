# Copyright 1999-2007 Gentoo Foundation
# Copyright 2012-2017 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit cmake-utils

MY_COMMIT="755d85a93cd5"

DESCRIPTION="NickyD impleatation of Linden Lab convexdecomposition stub with HACD and physics stub"
HOMEPAGE="https://bitbucket.org/NickyD/3p-ndphysicsstub"
SRC_URI="https://bitbucket.org/NickyD/3p-ndphysicsstub/get/${MY_COMMIT}.tar.bz2"
RESTRICT="mirror"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/NickyD-3p-ndphysicsstub-${MY_COMMIT}"
