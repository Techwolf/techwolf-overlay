# Copyright 2012 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit mercurial

DESCRIPTION="glh - is a platform-indepenedent C++ OpenGL helper library"
HOMEPAGE="https://bitbucket.org/lindenlab/3p-glh-linear"

EHG_REPO_URI="https://bitbucket.org/lindenlab/3p-glh-linear"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_install() {
	# Install headers
	cd "${S}/glh_linear"
	insinto /usr/include/GL
	doins include/GL/*.h
	insinto /usr/include/glh
	doins include/glh/*.h
	dodoc LICENSES/glh_linear.txt
}
