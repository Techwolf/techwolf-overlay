# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2


EAPI="6"
ETYPE="sources"
K_SECURITY_UNSUPPORTED="1"

inherit eutils kernel-2
detect_version
detect_arch

KEYWORDS="-* ~amd64 ~ppc ~ppc64 ~x86"

HOMEPAGE="http://zen-kernel.org/"
DESCRIPTION="The Zen Kernel sources"
SRC_URI="${KERNEL_URI}"

UNIPATCH_LIST="${FILESDIR}/zen_master-${PV}.patch.bz2"

K_NOSETEXTRAVERSION="true"
K_EXTRAEINFO="For more info on zen-sources and details on how to report problems, see: \
${HOMEPAGE}. You may also visit #zen-sources on irc.rizon.net"
