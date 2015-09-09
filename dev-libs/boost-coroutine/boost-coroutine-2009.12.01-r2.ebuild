# Distributed under the terms of the GNU General Public License v2
# $Header: $
# ebuild by Techwolf Lupindo

EAPI="2"

inherit autotools eutils

DESCRIPTION="The Boost.Coroutine library contains a family of class templates that wrap function objects in coroutines."
HOMEPAGE="http://www.crystalclearsoftware.com/soc/coroutine/"
SRC_URI="http://www.boostpro.com/vault/index.php?action=downloadfile&filename=boost-coroutine-2009-12-01.tar.gz&directory=Concurrent%20Programming -> boost-coroutine-2009.12.01.tar.gz"
RESTRICT="mirror"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""

src_prepare() {
	cd "${WORKDIR}/boost-coroutine"
	epatch "${FILESDIR}"/boost-coroutine-linden.patch
}

src_install() {
	S="${WORKDIR}/boost-coroutine/boost/coroutine"
	cd "${S}"
	# fix include paths
	for file in *.hpp  detail/*.hpp ; do
	  sed -i -e 's/#include <boost\/coroutine\//#include <boost-coroutine\//g' "${file}"
	done
	insinto /usr/include/boost-coroutine
	doins *.hpp
	insinto /usr/include/boost-coroutine/detail
	doins detail/*.hpp
}
