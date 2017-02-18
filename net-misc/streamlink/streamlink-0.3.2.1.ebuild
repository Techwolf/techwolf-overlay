
# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5} )
PYTHON_REQ_USE='xml(+),threads(+)'

inherit distutils-r1

DESCRIPTION="CLI for extracting streams from websites to a video player of your choice"
HOMEPAGE="https://streamlink.github.io/"
SRC_URI="https://github.com/${PN}/${PN}/archive/0774653c34b93bf2e71c3a94ef97aa10dce351ab.tar.gz -> ${P}.tar.gz"

KEYWORDS="~amd64 ~arm ~x86"
LICENSE="BSD-2 MIT"
SLOT="0"
IUSE="doc test"

RDEPEND="dev-python/pycrypto[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	virtual/python-futures[${PYTHON_USEDEP}]
	virtual/python-singledispatch[${PYTHON_USEDEP}]
	dev-python/backports-shutil_which[$(python_gen_usedep 'python2*')]
	dev-python/backports-shutil_get_terminal_size[$(python_gen_usedep 'python2*')]
	media-video/rtmpdump"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}]
                dev-python/docutils[${PYTHON_USEDEP}] )
	test? ( dev-python/mock
                ${RDEPEND} )
	dev-python/pycountry[${PYTHON_USEDEP}]"

S="${WORKDIR}"/streamlink-0774653c34b93bf2e71c3a94ef97aa10dce351ab

src_prepare() {
 	default
 	eapply "${FILESDIR}/python-streamlink-0.3.0-pycrypto.patch"
}

python_compile_all() {
        export STREAMLINK_USE_PYCOUNTRY="true"
	use doc && emake -C docs html
}

python_test() {
	esetup.py test
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/_build/html/. )
	distutils-r1_python_install_all
}
