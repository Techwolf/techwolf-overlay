# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Unlike many other binary packages the user doesn't need to agree to a licence
# to download VMWare. The agreeing to a licence is part of the configure step
# which the user must run manually.

# Comes with it's own libssl.so.0.9.7, so CVE-2006-4339

EAPI=5

inherit eutils versionator user

MY_PN=${PN/vm/VM}
MY_PV=$(replace_version_separator 3 '-')
MY_P="${MY_PN}-${MY_PV}"
FN="VMware-server-linux-client-${MY_PV}"
S="${WORKDIR}/${PN}-distrib"

VMWARE_INSTALL_DIR=/opt/${PN//-//}
VMWARE_GROUP=${VMWARE_GROUP:-vmware}

DESCRIPTION="VMware Remote Console for Linux"
HOMEPAGE="http://www.vmware.com/"
SRC_URI="http://download3.vmware.com/software/vmserver/${FN}.zip"

LICENSE="vmware"
IUSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror strip"

DEPEND=">=sys-libs/glibc-2.3.5
	virtual/os-headers
	dev-lang/perl
	app-arch/unzip"

# vmware-server-console should not use virtual/libc as this is a
# precompiled binary package thats linked to glibc.
RDEPEND=">=sys-libs/glibc-2.3.5[multilib]

	sys-libs/zlib[abi_x86_32(-)]

	x11-libs/libICE[abi_x86_32(-)]
	x11-libs/libSM[abi_x86_32(-)]
	x11-libs/libX11[abi_x86_32(-)]
	x11-libs/libXext[abi_x86_32(-)]

	x11-libs/libXi[abi_x86_32(-)]

	x11-libs/libXt[abi_x86_32(-)]
	x11-libs/libXtst[abi_x86_32(-)]

	dev-lang/perl"

FULL_NAME="Server Console"
MY_CONFIG_PROGRAM="vmware-config-server-console.pl"
MY_CONFIG_DIR="/etc/${PN}"

pkg_setup() {
	enewgroup "${VMWARE_GROUP}"
}

src_unpack() {
	unpack ${A}
	unpack ./${MY_P}.tar.gz
}

src_prepare() {
        # use shipped libs instead of system.
	epatch "${FILESDIR}/vmsc-force-included-gtk.patch"
}

src_install() {
        echo 'libdir = "'${VMWARE_INSTALL_DIR}'/lib"' > etc/config

        # As backwards as this seems, we're installing our icons first.
        newicon doc/icon48x48.png ${PN}.png

        # Just like any good monkey, we install the documentation and man pages.
	dodoc doc/*
        cd man
        for x in *
        do
                doman ${x}/*
        done
	cd "${S}"

	# We loop through our directories and copy everything to our system.
	for x in bin lib
	do
                dodir "${VMWARE_INSTALL_DIR}"/${x}
                cp -pPR "${S}"/${x}/* "${D}""${VMWARE_INSTALL_DIR}"/${x}
	done

	# We have an /etc directory, copy it.
        dodir "${MY_CONFIG_DIR}"
        cp -pPR "${S}"/etc/* "${D}""${MY_CONFIG_DIR}"
        fowners root:${VMWARE_GROUP} "${MY_CONFIG_DIR}"
        fperms 770 "${MY_CONFIG_DIR}"

        # doenvd "${FILESDIR}"/90${PN} || die "doenvd"
        
        # create the environment
	local envd="${T}/90vmware-server-console"
	cat > "${envd}" <<-EOF
		PATH='${VMWARE_INSTALL_DIR}/bin'
		ROOTPATH='${VMWARE_INSTALL_DIR}/bin'
	EOF
	# echo 'VMWARE_USE_SHIPPED_GTK=force' >> "${envd}"

	doenvd "${envd}"

        insinto /usr/share/mime/packages
        doins "${FILESDIR}"/${PN}.xml

        insinto "${VMWARE_INSTALL_DIR}"/doc
        doins doc/EULA
        
        # Questions:
	einfo "Adding answers to ${MY_CONFIG_DIR}/locations"
	locations="${D}${MY_CONFIG_DIR}/locations"
	echo "answer BINDIR ${VMWARE_INSTALL_DIR}/bin" >> ${locations}
	echo "answer LIBDIR ${VMWARE_INSTALL_DIR}/lib" >> ${locations}
	echo "answer MANDIR ${VMWARE_INSTALL_DIR}/man" >> ${locations}
	echo "answer DOCDIR ${VMWARE_INSTALL_DIR}/doc" >> ${locations}

	# Fix an ugly GCC error on start
	rm -f "${D}${VMWARE_INSTALL_DIR}/lib/lib/libgcc_s.so.1/libgcc_s.so.1"
	make_desktop_entry ${PN} "VMWare Remote Console" ${PN} System

	dodir /usr/bin
	dosym ${VMWARE_INSTALL_DIR}/bin/${PN} /usr/bin/${PN}
}

pkg_config() {
	"${VMWARE_INSTALL_DIR}"/bin/vmware-config-server-console.pl
}

pkg_preinst() {
	# This must be done after the install to get the mtimes on each file
	# right.

	#Note: it's a bit weird to use ${D} in a preinst script but it should work
	#(drobbins, 1 Feb 2002)

	einfo "Generating ${MY_CONFIG_DIR}/locations file."
	d=`echo ${D} | wc -c`
	for x in `find ${D}${VMWARE_INSTALL_DIR} ${D}${MY_CONFIG_DIR}` ; do
		x="`echo ${x} | cut -c ${d}-`"
		if [ -d "${D}/${x}" ] ; then
			echo "directory ${x}" >> "${D}${MY_CONFIG_DIR}"/locations
		else
			echo -n "file ${x}" >> "${D}${MY_CONFIG_DIR}"/locations
			if [ "${x}" == "${MY_CONFIG_DIR}/locations" ] ; then
				echo "" >> "${D}${MY_CONFIG_DIR}"/locations
			elif [ "${x}" == "${MY_CONFIG_DIR}/not_configured" ] ; then
				echo "" >> "${D}${MY_CONFIG_DIR}"/locations
			else
				echo -n " " >> "${D}${MY_CONFIG_DIR}"/locations
				find ${D}${x} -printf %T@ >> "${D}${MY_CONFIG_DIR}"/locations
				echo "" >> "${D}${MY_CONFIG_DIR}"/locations
			fi
		fi
	done
}

pkg_postinst() {
	update-mime-database /usr/share/mime
	[[ -d "${MY_CONFIG_DIR}" ]] && chown -R root:${VMWARE_GROUP} ${MY_CONFIG_DIR}

	# This is to fix the problem where the not_configured file doesn't get
	# removed when the configuration is run. This doesn't remove the file
	# It just tells the vmware-config.pl script it can delete it.
	einfo "Updating ${MY_CONFIG_DIR}/locations"
	for x in "${MY_CONFIG_DIR}"/._cfg????_locations ; do
		if [ -f $x ] ; then
			cat $x >> "${MY_CONFIG_DIR}"/locations
			rm $x
		fi
	done

	echo
	elog "You need to run "
	elog "    emerge --config ${PN}"
	elog "to complete the install."
	echo
        elog "After configuring, run ${PN} to launch"
	echo
	ewarn "Remember, in order to run VMware ${FULL_NAME}, you have to"
	ewarn "be in the '${VMWARE_GROUP}' group."
	echo
}

pkg_postrm() {
	if ! has_version app-emulation/${PN}; then
		echo
		elog "To remove all traces of Server Console you will need to remove the files"
		elog "in /etc/vmware-server-console."
		echo
	fi
}
