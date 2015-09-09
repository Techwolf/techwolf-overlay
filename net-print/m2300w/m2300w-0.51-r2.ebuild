# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Open source Linux driver for the Konica Minolta magicolor 2300W and 2400W color laser printers."
HOMEPAGE="http://sourceforge.net/projects/m2300w/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="|| ( >=net-print/cups-filters-1.0.43-r1[foomatic] net-print/foomatic-filters )
	net-print/cups"
RDEPEND="${DEPEND}"

src_configure() {
	export FOOMATIC_RIP=/usr/libexec/cups/filter/foomatic-rip
	econf
}

src_install() {
	emake INSTROOT="${D}" install || die "emake install failed"
	
	# Avoid collision with foomatic-db
	rm "${D}"/usr/share/foomatic/db/source/{driver/m2{3,4}00w.xml,printer/Minolta-magicolor_2{3,4}00W.xml,opt/m2300w-*.xml}
}
