# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit base mercurial cmake-utils

DESCRIPTION="NickyD impleatation of Linden Lab 3p-glod"
HOMEPAGE="https://bitbucket.org/NickyD/llglod"
EHG_REPO_URI="https://bitbucket.org/NickyD/llglod"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_unpack() {
	mercurial_src_unpack
}
