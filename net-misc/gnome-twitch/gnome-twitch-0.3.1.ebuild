# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2-utils fdo-mime

DESCRIPTION="Enjoy Twitch on your GNU/Linux desktop"
HOMEPAGE="http://gnome-twitch.vinszent.com/"
SRC_URI="https://github.com/vinszent/gnome-twitch/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
DOCS="README.md CONTRIBUTING.md TODO.org"
IUSE="+gst-cairo gst-opengl gst-clutter mpv"

DEPEND=">=dev-util/meson-0.32.0
		dev-util/ninja"
RDEPEND="${DEPEND}
		>=x11-libs/gtk+-3.20
		net-libs/libsoup
		dev-libs/json-glib
		net-libs/webkit-gtk
		gst-cairo? (
			media-libs/gstreamer
			media-plugins/gst-plugins-libav
			media-libs/gst-plugins-base
			media-libs/gst-plugins-good
			media-libs/gst-plugins-bad
		)
		gst-opengl? (
			media-libs/gstreamer
			media-plugins/gst-plugins-libav
			media-libs/gst-plugins-base
			media-libs/gst-plugins-good
			media-libs/gst-plugins-bad
		)
		gst-clutter? (
			media-libs/gstreamer
			media-plugins/gst-plugins-libav
			media-libs/gst-plugins-base
			media-libs/gst-plugins-good
			media-libs/gst-plugins-bad
			>=media-libs/clutter-gst-3.0
			>=media-libs/clutter-gtk-1.0
		)
		mpv? (
			media-video/mpv[libmpv]
		)
		dev-libs/libpeas
		dev-libs/gobject-introspection"

src_compile() {
	local params
	rm -rf build
	mkdir build
	cd build

	params="--prefix=/usr --libdir=lib --buildtype=release -Ddo-post-install=false"
	if use gst-cairo ; then
		params="${params} -Dwith-player-gstreamer-cairo=true"
	fi
	if use gst-opengl ; then
		params="${params} -Dwith-player-gstreamer-opengl=true"
	fi
	if use gst-clutter ; then
		params="${params} -Dwith-player-gstreamer-clutter=true"
	fi
	if use mpv ; then
		params="${params} -Dwith-player-mpv-opengl=true"
	fi
	meson ${params} -Db_lundef=false ..
	ninja
}

src_install() {
	cd build
	DESTDIR="${D}" ninja install
	cd ..
	dodoc ${DOCS}
}

pkg_preinst() {
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
	gnome2_schemas_update
}
