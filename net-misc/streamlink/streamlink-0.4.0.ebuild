# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5} )
PYTHON_REQ_USE='xml(+),threads(+)'
EGIT_COMMIT="0871d22b0f06dd6e3b3b5683fa31a07a29c4ca80"
GITHUBNAME="streamlink/streamlink"

inherit distutils-r1 webvcs

DESCRIPTION="CLI for extracting streams from websites to a video player of your choice"
HOMEPAGE="https://streamlink.github.io/"

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
	dev-python/pycountry[${PYTHON_USEDEP}]
	media-video/rtmpdump
	virtual/ffmpeg"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}]
                dev-python/docutils[${PYTHON_USEDEP}] )
	test? ( dev-python/mock[$(python_gen_usedep 'python2*')]
                ${RDEPEND} )"

src_prepare() {
 	default
 	eapply "${FILESDIR}/python-streamlink-0.3.0-pycrypto.patch"
}

python_configure_all() {
    # Avoid iso-639, iso3166 dependencies since we use pycountry.
    export STREAMLINK_USE_PYCOUNTRY=1
}

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	esetup.py test
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/_build/html/. )
	distutils-r1_python_install_all
}
