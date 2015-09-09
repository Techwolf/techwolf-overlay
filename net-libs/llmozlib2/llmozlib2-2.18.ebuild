# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Ycarus. For new version look here : http://gentoo.zugaina.org/
# This ebuild is a modified version by Ycarus of the ebuild from http://bugs.gentoo.org/show_bug.cgi?id=127026

inherit autotools eutils flag-o-matic toolchain-funcs multilib fdo-mime autotools subversion

DESCRIPTION="Linden Labs Mozilla Library (customized for secondlife)"
HOMEPAGE="http://wiki.secondlife.com/wiki/LLMozLib2"
ESVN_REPO_URI="/trunk/${PN}"
ESVN_REPO_URI="http://svn.secondlife.com/svn/llmozlib${ESVN_REPO_URI%%.*}/"
ESVN_REVISION="${P/*.}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-util/cvs
	=sys-devel/gcc-3.4*
	sys-apps/gawk
	>=dev-lang/perl-5.4
	app-arch/unzip
	app-arch/zip
	>=dev-libs/libIDL-0.8.0
	x11-libs/gtk+"
# libllmozlib2.a (the only output file) is a static lib, so no RDEPENDs
RDEPEND=""
ESVN_PATCHES="${FILESDIR}/${P}-gentoo.patch"

src_compile() {
	# follow the instructions in README-linux.txt
	cd "${S}/build_mozilla" || die "failed to cd ${S}/build_mozilla"
	einfo "checking out the latest firefox from CVS (inefficient)"
	einfo "instead of trying to pick apart what linden labs is doing"
	./linux-checkout_patch_build.sh || die
	cd "${S}" || die "failed to cd ${S}"
	./copy_products_linux.sh || die
	./build-linux-llmozlib.sh || die
}

src_install() {
	cd "${S}" || die "failed to cd ${S}"
	LIBNAME="`sed -e 's/LIBNAME=//p;d' build-linux-llmozlib.sh | head -n1`"
        dodir "/usr/$(get_libdir)/${PN}"
	insinto "/usr/$(get_libdir)/${PN}"
	doins "${LIBNAME}.a" 
	doins "libraries/`uname -m`-linux/lib_release"/*
	dodir "/usr/$(get_libdir)/${PN}/runtime_release/"
	cp -r "libraries/`uname -m`-linux/runtime_release"/* "${D}/usr/$(get_libdir)/${PN}/runtime_release/"
	insinto "/usr/include/${PN}"
        doins ${PN}.h

}
