# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools-utils mercurial

DESCRIPTION="An open-source multi-platform crash reporting system. This is Linden Labs forked/cloned version of it."
HOMEPAGE="http://hg.secondlife.com/3p-google-breakpad"
EHG_REPO_URI="http://hg.secondlife.com/3p-google-breakpad"
AUTOTOOLS_AUTORECONF="yes"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="!dev-util/google-breakpad-svn"

PATCHES=(
        "${FILESDIR}/569836_missing_include.patch"
)

src_install() {
	autotools-utils_src_install
	# Install headers that some programs require to build.
	cd "${S}"
	insinto /usr/include/google_breakpad
	doins src/client/linux/handler/exception_handler.h
	insinto /usr/include/google_breakpad/client/linux/crash_generation
	doins src/client/linux/crash_generation/*.h
	insinto /usr/include/google_breakpad/processor
	doins src/processor/scoped_ptr.h
}