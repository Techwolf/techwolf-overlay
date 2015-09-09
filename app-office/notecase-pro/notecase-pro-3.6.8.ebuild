# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit eutils fdo-mime

DESCRIPTION="Hierarchical note taker (binary installation)"
HOMEPAGE="http://www.notecasepro.com/"

# binary builds
SRC_URI="amd64? ( http://www.notecasepro.com/get.php?gentoo/notecase_pro-${PV}_amd64.tar.gz )
	x86? ( http://www.notecasepro.com/get.php?gentoo/notecase_pro-${PV}_x86.tar.gz )"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.18
	dev-libs/libunique:1"

# stuff not implemented
RESTRICT="mirror test"

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	
	einfo "Notecase Pro has just been installed."
	einfo "To unlock advanced features you need to purchase a license key."
	einfo "The key file is installed using 'Help'/'Install License' menu item."
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

src_unpack() {
	unpack ${A} || die "Error unpacking binary archive"
}

src_install() {
	into /usr
	dobin usr/bin/notecase || die "dobin failed"

	insinto usr/share
	doins -r usr/share/* || die "doins failed"
}
