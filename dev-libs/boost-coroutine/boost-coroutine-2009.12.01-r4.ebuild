# Distributed under the terms of the GNU General Public License v2

# 2017 Techwolf Lupindo

EAPI="6"

inherit autotools eutils

DESCRIPTION="The Boost.Coroutine library contains a family of class templates that wrap function objects in coroutines."
HOMEPAGE="http://www.crystalclearsoftware.com/soc/coroutine/"
SRC_URI="http://github.com/boost-vault/Concurrent-Programming/blob/master/boost-coroutine-2009-12-01.tar.gz?raw=true -> boost-coroutine-2009-12-01.tar.gz"
RESTRICT="mirror"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/boost-coroutine"

src_prepare() {
	epatch "${FILESDIR}"/boost-coroutine-linden.patch
	epatch "${FILESDIR}"/boost-coroutine-linden-2.patch
	epatch "${FILESDIR}"/gcc6.patch
	eapply_user
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
