# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2012-2018 Techwolf Lupindo

EAPI="6"

EHG_COMMIT="a9c24a3957df"
BITBUCKETNAME="lindenlab/3p-glh-linear"

inherit webvcs

DESCRIPTION="glh - is a platform-indepenedent C++ OpenGL helper library"
HOMEPAGE="https://bitbucket.org/lindenlab/3p-glh-linear"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_install() {
	# Install headers
	cd "${S}/glh_linear"
	insinto /usr/include/GL
	doins include/GL/*.h
	insinto /usr/include/glh
	doins include/glh/*.h
	dodoc LICENSES/glh-linear.txt
}
