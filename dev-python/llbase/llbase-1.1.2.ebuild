# Distributed under the terms of the GNU General Public License v2

# Copyright 2018 Techwolf Lupindo

EAPI=6
PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} )

EHG_COMMIT="e748cd1c1e2d"
BITBUCKETNAME="lindenlab/llbase"

inherit distutils-r1 webvcs

DESCRIPTION="Utility modules used by Linden Lab, the creators of Second Life."
HOMEPAGE="https://bitbucket.org/lindenlab/llbase"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

