# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# This ebuild come from http://overlays.gentoo.org/svn/dev/matsuu/secondlife/net-libs/llmozlib2/ - Zugaina.org only host a copy

inherit eutils subversion toolchain-funcs multilib

DESCRIPTION="LLMozLib2"
HOMEPAGE="http://wiki.secondlife.com/wiki/LLMozLib2"
SRC_URI=""
ESVN_REPO_URI="http://svn.secondlife.com/svn/llmozlib/trunk/${PN}"

LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
SLOT="0"
#KEYWORDS="~amd64 ~x86"
KEYWORDS=""
IUSE=""

RDEPEND=">=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.11.8
	>=dev-libs/nspr-4.6.8"
DEPEND="${RDEPEND}
	dev-util/cvs"

src_unpack() {
	subversion_src_unpack
	cd "${S}"
	sed -i \
		-e "s/\(GCC_VERSION=\).*/\1$(gcc-fullversion)/" \
		-e "s/gcc-\$GCC_VERSION/$(tc-getCC)/" \
		-e "s/g\+\+-\$GCC_VERSION/$(tc-getCXX)/" \
		build_mozilla/linux-libxul-bits/mozconfig || die
	sed -i \
		-e "/cvs login/d" \
		build_mozilla/linux-checkout_patch_build.sh || die
	
	local MOZARCH
	MOZARCH="$(uname -m)-linux"

	sed -i \
		-e "s/\(CXX=\).*/\1$(tc-getCXX)/" \
		-e "s/\(MOZARCH=\).*/\1${MOZARCH}/" \
		build-linux-llmozlib.sh || die
}

src_compile() {
	cd build_mozilla || die
	./linux-checkout_patch_build.sh || die
	cd .. || die
	./copy_products_linux.sh || die
	./build-linux-llmozlib.sh || die
}

src_install() {
	local MOZARCH="$(uname -m)-linux"

	dolib.a libllmozlib2.a  || die

	insopts -m0755
	insinto "/usr/$(get_libdir)/${PN}"
	for f in "${S}"/libraries/${MOZARCH}/runtime_release/*; do 
		doins -r "${f}"
	done
	doins "${S}"/libraries/${MOZARCH}/lib_release/libprofdirserviceprovider_s.a
	insinto "/usr/include/${PN}"
	doins ${PN}.h
	dodoc README-linux*
}
