# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools-utils mercurial

DESCRIPTION="An open-source multi-platform crash reporting system. This is Linden Labs forked/cloned version of it."
HOMEPAGE="https://bitbucket.org/lindenlab/3p-google-breakpad"
EHG_REPO_URI="https://bitbucket.org/lindenlab/3p-google-breakpad"
# lastest version without "MD5Update" build error
EHG_REVISION="81d9823"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="!dev-util/google-breakpad-svn"

src_install() {
	autotools-utils_src_install
	# move some headers into the proper spot that the client expects.
	mv "${D}/usr/include/breakpad" "${D}/usr/include/google_breakpad"
	# Install headers that some programs require to build.
	cd "${S}"
	insinto /usr/include/google_breakpad
	doins src/client/linux/handler/exception_handler.h
	doins src/client/linux/handler/minidump_descriptor.h
	insinto /usr/include/google_breakpad/client/linux/crash_generation
	doins src/client/linux/crash_generation/*.h
	insinto /usr/include/google_breakpad/processor
	doins src/processor/scoped_ptr.h
	insinto /usr/include/google_breakpad/client/linux/dump_writer_common
	doins src/client/linux/dump_writer_common/*.h
}