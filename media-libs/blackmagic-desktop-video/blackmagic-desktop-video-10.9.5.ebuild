# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# TODOs:
#  - fix QA notice about installing symlinks in /usr/lib

EAPI=5

inherit linux-mod

DESCRIPTION="Desktop Video - drivers and tools for products by Blackmagic Design including DeckLink and Intensity"
HOMEPAGE="http://www.blackmagicdesign.com/"
HOMEPAGE_DOWNLOAD_NAME="Desktop Video ${PV}"

SRC_URI="Blackmagic_Desktop_Video_Linux_${PV}.tar.gz"
DESKTOP_VIDEO_VERSION="10.9.5a4"
UNPACKED_DIR="desktopvideo-${DESKTOP_VIDEO_VERSION}-x86_64"

LICENSE="BlackmagicDesktopVideo"
SLOT="0"
KEYWORDS="~amd64"
IUSE="autostart"
RESTRICT="fetch"

# dependencies found via command: (ldd would include transitive dependencies)
# equery belongs $(for file in /usr/lib/libDeckLink* /usr/lib/blackmagic/*; do objdump -p $file | grep NEEDED; done 2>/dev/null | cut -b24- | sort | uniq | grep -vE 'lib(Qt5(Core|Network|Gui|Widgets)|qxcb|qgtk2|DeckLink)')
DEPEND=""
RDEPEND="${DEPEND}
	 dev-libs/glib:2
	 dev-libs/libxml2
	 media-libs/libpng:1.2
	 sys-devel/gcc
	 sys-libs/glibc
	 sys-libs/zlib
	 x11-libs/libX11
	 x11-libs/libXext
	"

# supress QA warnings about stripping etc., i.e. stuff we cannot change since we install prebuilt binaries
QA_PREBUILT="opt/blackmagic-desktop-video/usr/bin/* opt/blackmagic-desktop-video/usr/lib/*"

# for kernel module compilation
MODULE_NAMES="blackmagic(misc:${S}/usr/src/blackmagic-${DESKTOP_VIDEO_VERSION}:${S}/usr/src/blackmagic-${DESKTOP_VIDEO_VERSION}) blackmagic-io(misc:${S}/usr/src/blackmagic-io-${DESKTOP_VIDEO_VERSION}:${S}/usr/src/blackmagic-io-${DESKTOP_VIDEO_VERSION})"
BUILD_TARGETS="clean all"

pkg_nofetch() {
	#               1         2         3         4         5         6         7         8
	#      1234567890123456789012345678901234567890123456789012345678901234567890123456789012
	einfo "Please visit ${HOMEPAGE} and download \"${HOMEPAGE_DOWNLOAD_NAME}\""
	einfo "for your product from the support section and move it to ${DISTDIR}"
	einfo ""
	einfo "  expected filename: ${SRC_URI}"
	einfo ""
	einfo "If your browser downloads a .tar file you will need to rename it to .tar.gz"
}

src_unpack() {
	unpack ${A}
	
	cd ${WORKDIR}
	tar xfz Blackmagic_Desktop_Video_Linux_${DESKTOP_VIDEO_VERSION}/other/x86_64/desktopvideo-${DESKTOP_VIDEO_VERSION}-x86_64.tar.gz
	
	# symlink to what is supposed to have been prepared
	ln -s ${UNPACKED_DIR} ${P}
}

src_prepare() {
	: #epatch "${FILESDIR}/get_user_pages_4.10.patch"
}

src_compile() {
	# library/tools are binary but kernel module requires compilation
	linux-mod_src_compile
}

src_install() {
	# all pre-built binaries should go into /opt and be symlinked to usr/bin etc.
	finalinstalldir="/opt/blackmagic-desktop-video"
	installdir="${D}${finalinstalldir}"
	
	mkdir -p ${installdir}
	cp -a ${WORKDIR}/${UNPACKED_DIR}/* ${installdir}/
	
	# copy text files (readme and license) from parent directory
	cp -a ${WORKDIR}/Blackmagic_Desktop_Video_Linux_${PV}/*.txt ${installdir}/
	
	# there should a blank directory in /etc according to the archive...
	mkdir -p ${installdir}/etc/blackmagic
	chmod 755 ${installdir}/etc/blackmagic
	
	# NOTE: Not linking usr/lib/systemd as I don't use that and thus can't test it...
	symlinks=(
			'etc/init.d/DesktopVideoHelper'
			'usr/bin/BlackmagicDesktopVideoSetup'
			'usr/bin/BlackmagicFirmwareUpdater'
			'usr/bin/BlackmagicFirmwareUpdaterGui'
			'usr/lib/blackmagic'
			'usr/lib/libDeckLinkAPI.so'
			'usr/lib/libDeckLinkPreviewAPI.so'
			'usr/sbin/DesktopVideoHelper'
			'usr/share/applications/BlackmagicDesktopVideoSetup.desktop'
			'usr/share/applications/BlackmagicFirmwareUpdaterGui.desktop'
			'usr/share/doc/desktopvideo'
			'usr/share/doc/desktopvideo-gui'
			'usr/share/icons/hicolor/16x16/apps/BlackmagicDesktopVideoSetup.png'
			'usr/share/icons/hicolor/16x16/apps/BlackmagicFirmwareUpdaterGui.png'
			'usr/share/icons/hicolor/32x32/apps/BlackmagicDesktopVideoSetup.png'
			'usr/share/icons/hicolor/32x32/apps/BlackmagicFirmwareUpdaterGui.png'
			'usr/share/icons/hicolor/48x48/apps/BlackmagicDesktopVideoSetup.png'
			'usr/share/icons/hicolor/48x48/apps/BlackmagicFirmwareUpdaterGui.png'
			'usr/share/icons/hicolor/128x128/apps/BlackmagicDesktopVideoSetup.png'
			'usr/share/icons/hicolor/128x128/apps/BlackmagicFirmwareUpdaterGui.png'
			'usr/share/icons/hicolor/256x256/apps/BlackmagicDesktopVideoSetup.png'
			'usr/share/icons/hicolor/256x256/apps/BlackmagicFirmwareUpdaterGui.png'
                 )
	
	for path in "${symlinks[@]}"; do
		dosym /opt/blackmagic-desktop-video/${path} ${path}
	done
	
	# dneuge: no clue on how to use this...
	## QA notice says we should generate a linker script if we don't place libraries in /usr/lib
	## see: https://devmanual.gentoo.org/eclass-reference/toolchain-funcs.eclass/index.html
	#gen_usr_ldscript usr/lib/libDeckLinkAPI.so usr/lib/libDeckLinkPreviewAPI.so

	# don't symlink man-pages, install a copy instead
	doman usr/share/man/man1/*.1
	
	# udev rule should be placed in /lib/udev/rules.d instead
	dosym /opt/blackmagic-desktop-video/etc/udev/rules.d/55-blackmagic.rules /lib/udev/rules.d/55-blackmagic.rules
	
	# add firmware check to autostart?
	if use autostart; then
		dosym /opt/blackmagic-desktop-video/etc/xdg/autostart/BlackmagicFirmwareUpdaterGuiAutoStart.desktop /etc/xdg/autostart/BlackmagicFirmwareUpdaterGuiAutoStart.desktop
	fi
	
	# kernel module
	linux-mod_src_install
}

pkg_postinst() {
	# kernel module
	linux-mod_pkg_postinst
	
	#      12345678901234567890123456789012345678901234567890123456789012345678901234567890
	einfo ""
	einfo "Please do *NOT* report any QA errors to Gentoo or Blackmagic!"
	einfo ""
	einfo "Kernel modules are blackmagic and blackmagic-io. Try blackmagic if in doubt."
	einfo "When upgrading, please rmmod both first. Then modprobe blackmagic to see if it"
	einfo "works (it should print your devices to kernel log)."
	einfo ""
	einfo "Installed tools are BlackmagicFirmwareUpdater, BlackmagicFirmwareUpdaterGui and"
	einfo "BlackmagicDesktopVideoSetup (former BlackmagicDesktopVideoUtility and called"
	einfo "BlackmagicControlPanel before that)."
	einfo ""
	einfo "For Media Express emerge media-video/blackmagic-media-express."
	einfo ""
	if use autostart; then
		einfo "Automated update check has been installed."
	else
		einfo "Automated update check has *not* been installed this time. (set USE flag"
		einfo "autostart if you want that)"
	fi
	einfo ""
	einfo "If your product is not being recognized, there are two common reasons:"
	einfo ""
	einfo " 1) You may need to increase the vmalloc limit in your kernel."
	einfo "    This can be done by adding e.g. vmalloc=256M to your kernel boot line. You"
	einfo "    can see current usage by running"
	einfo ""
	einfo "    # grep VmallocUsed /proc/meminfo"
	einfo ""
	einfo " 2) Your firmware may be outdated. Make sure you reload the modules (or simply"
	einfo "    reboot) and then run BlackmagicFirmwareUpdater or, if you prefer,"
	einfo "    BlackmagicFirmwareUpdaterGui"
	einfo ""
	einfo "Licenses can be found in: ${finalinstalldir}/usr/share/doc/"
	einfo ""
	einfo "We are reloading udev rules now..."
	/bin/udevadm control --reload-rules || einfo " ... failed, you may want to check this before rebooting!"
}

pkg_postrm() {
	# kernel module
	linux-mod_pkg_postrm
}
