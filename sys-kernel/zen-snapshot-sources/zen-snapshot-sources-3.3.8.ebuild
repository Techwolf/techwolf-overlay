# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
ETYPE="sources"
K_SECURITY_UNSUPPORTED="1"

inherit eutils kernel-2
detect_version
detect_arch

KEYWORDS="-* ~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

HOMEPAGE="http://zen-kernel.org/"
DESCRIPTION="The Zen Kernel sources"
SRC_URI="${KERNEL_URI}"

K_NOSETEXTRAVERSION="true"
K_EXTRAEINFO="For more info on zen-sources and details on how to report problems, see: \
${HOMEPAGE}. You may also visit #zen-sources on irc.rizon.net"

src_prepare(){
	epatch "${FILESDIR}/zen_master-${PV}.patch.bz2"
}
