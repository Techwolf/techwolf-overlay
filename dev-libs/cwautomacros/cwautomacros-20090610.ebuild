# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="cwautomacros: a collection of autoconf m4 macros"
HOMEPAGE="http://cwautomacros.berlios.de/"

SRC_URI="http://download.berlios.de/cwautomacros/cwautomacros-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# A space delimited list of portage features to restrict. man 5 ebuild
# for details.  Usually not needed.
RESTRICT="mirror"
RDEPEND=""
DEPEND="${RDEPEND}"

# The following src_compile function is implemented as default by portage, so
# you only need to call it, if you need a different behaviour.
#src_compile() {
	#emake || die "emake failed"
#}

src_install() {
	emake CWAUTOMACROSPREFIX="${D}usr" install || die "emake install failed"

}
