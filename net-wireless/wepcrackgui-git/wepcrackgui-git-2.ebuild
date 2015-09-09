# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit git-2 mono multilib

DESCRIPTION="A GUI for aircrack-ng written in C#"
HOMEPAGE="http://sourceforge.net/projects/wepcrackgui/"
SRC_URI=""
EGIT_REPO_URI="git://wepcrackgui.git.sourceforge.net/gitroot/wepcrackgui/wepcrackgui"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

# currently fails to build with debug off due to missing files.
IUSE="+debug gtk qt4"

DEPEND="dev-lang/mono
	gtk? ( dev-dotnet/gtk-sharp )
	qt4? ( kde-base/qyoto 
	       kde-base/kdebindings-meta[csharp] )"
RDEPEND="${DEPEND}
	net-wireless/aircrack-ng
	net-wireless/mdk"

src_configure() {

	if use qt4 ; then
	  ./configure --prefix=/usr --libdir=/usr/$(get_libdir) --config=DEBUGQT
        else
          ./configure --prefix=/usr --libdir=/usr/$(get_libdir) --config=DEBUGGTK
        fi;
	  
	# Fix a makefile bug that effects the locale diretory.
	sed -i -e "s,@expanded_libdir@,/usr/$(get_libdir)," WepCrackLocalization/Makefile
}

src_install() {
	emake DESTDIR="${D}" install
	
	# This is a mono program. Everything was installed in one subdirectory.
	# So all we need is a wrapper to cd and run it.
	make_wrapper wepcrack ./wepcrack "/usr/$(get_libdir)/wepcrack"
}
