# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools python

DESCRIPTION="Google C++ Mocking Framework"
HOMEPAGE="http://googlemock.googlecode.com/"
SRC_URI="http://googlemock.googlecode.com/files/${P}.tar.bz2"
RESTRICT="mirror"
LICENSE="BSD tools? ( Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="static-libs tools"

DEPEND=">=dev-util/gtest-1.4.0
	dev-lang/python"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${PV}-as_needed.patch"
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable static-libs static)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	use static-libs || rm "${D}"/usr/lib*/*.la

	dodoc CHANGES CONTRIBUTORS README

	if use tools ; then
		cd scripts/generator

		insinto /usr/share/gmock_gen
		doins -r cpp gmock_gen.py

		cat > "${T}/gmock_gen" << _EOF_
#!/bin/sh

/usr/bin/python /usr/share/gmock_gen/gmock_gen.py \$@
_EOF_
		dobin "${T}/gmock_gen"

		newdoc README README.gmock_gen
		dodoc README.cppclean

		python_need_rebuild
	fi
}

pkg_postinst() {
	use tools && python_mod_optimize /usr/share/gmock_gen
}

pkg_postrm() {
	use tools && python_mod_cleanup /usr/share/gmock_gen
}
