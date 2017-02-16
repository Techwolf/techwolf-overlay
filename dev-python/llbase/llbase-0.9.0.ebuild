# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="Utility modules used by Linden Lab, the creators of Second Life."
HOMEPAGE="https://bitbucket.org/lindenlab/llbase/src"
SRC_URI="https://bitbucket.org/lindenlab/llbase/get/bf88b8c.tar.bz2"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/lindenlab-llbase-bf88b8c88cac"
