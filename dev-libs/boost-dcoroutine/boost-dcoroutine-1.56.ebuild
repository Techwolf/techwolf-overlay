# Distributed under the terms of the GNU General Public License v2
# $Header: $
# ebuild by Techwolf Lupindo

EAPI="5"

DESCRIPTION="Modified Boost.Coroutine library from Linden Lab."
HOMEPAGE="https://bitbucket.org/lindenlab/3p-boost/src/22cc553f433e37468031042503eb06d05de58bb3/boost/boost/dcoroutine/?at=default"
SRC_URI="http://automated-builds-secondlife-com.s3.amazonaws.com/hg/repo/boost_3p-update-boost/rev/297445/arch/Linux/installer/boost-1.57-linux-297445.tar.bz2"
RESTRICT="mirror"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-libs/boost-1.56[context]"

src_unpack() {
	# work around:
	#   * ERROR: dev-libs/boost-dcoroutine-1.56::Techwolf failed (prepare phase):
	#   *   The source directory '/var/tmp/portage/dev-libs/boost-dcoroutine-1.56/work/boost-dcoroutine-1.56' doesn't exist
	# even when src_prepare(){} exists.
	mkdir -p "${S}"
	cd "${S}"
        unpack ${A}
}

src_install() {
	S="${S}/include/boost/dcoroutine"
	cd "${S}"
	insinto /usr/include/boost/dcoroutine
	doins *.hpp
	insinto /usr/include/boost/dcoroutine/detail
	doins detail/*.hpp
}
