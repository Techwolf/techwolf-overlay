# Distributed under the terms of the GNU General Public License v2

# copyright 2017 Techwolf Lupindo

EAPI="6"

EHG_COMMIT="3759de77d30b"
BITBUCKETNAME="lindenlab/p64_3p-google_breakpad"

inherit webvcs

DESCRIPTION="An open-source multi-platform crash reporting system. This is Linden Labs forked/cloned version of it."
HOMEPAGE="https://bitbucket.org/lindenlab/3p-google-breakpad"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_prepare() {
	eapply "${FILESDIR}/0002-replace-struct-ucontext-with-ucontext_t.patch"
	eapply_user
}

src_install() {
	emake DESTDIR="${D}" install

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
