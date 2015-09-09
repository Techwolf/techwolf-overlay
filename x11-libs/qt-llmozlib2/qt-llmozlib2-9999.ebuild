# work in progress of doing a sloted Qt build of same verion, but patched.
# Probelly won't finish due to patches are upstream and system qt works ok.

EAPI="2"
inherit git

DESCRIPTION="Qt version forked from Qt 4.6 with patches from SL Jira for llmozlib2 webkit version"
HOMEPAGE="http://gitorious.org/~taladar/qt/taladars-clone"

EGIT_REPO_URI="git://gitorious.org/~taladar/qt/taladars-clone.git"
EGIT_BRANCH="secondlife-llmozlib2-webkit"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-db/sqlite"
DEPEND="${RDEPEND}"

# function taken/copied from qt-build eclass.
qt_mkspecs_dir() {
	# Allows us to define which mkspecs dir we want to use.
	local spec

	case ${CHOST} in
		*-freebsd*|*-dragonfly*)
			spec="freebsd" ;;
		*-openbsd*)
			spec="openbsd" ;;
		*-netbsd*)
			spec="netbsd" ;;
		*-darwin*)
			spec="darwin" ;;
		*-linux-*|*-linux)
			spec="linux" ;;
		*)
			die "Unknown CHOST, no platform choosen."
	esac

	CXX=$(tc-getCXX)
	if [[ ${CXX/g++/} != ${CXX} ]]; then
		spec="${spec}-g++"
	elif [[ ${CXX/icpc/} != ${CXX} ]]; then
		spec="${spec}-icc"
	else
		die "Unknown compiler ${CXX}."
	fi
	if [[ -n "${LIBDIR/lib}" ]]; then
		spec="${spec}-${LIBDIR/lib}"
	fi

	echo "${spec}"
}

# function to allow redirection in a find command
add_no_strip() {
	echo "CONFIG+=nostrip" >> "$1"
}

src_prepare() {
	# Don't pre-strip, bug 235026
	find "${S}" -name '*.pro' | while read i ; do add_no_strip "$i" ; done

	# Bug 172219
	sed -e "s:QMAKE_CFLAGS_RELEASE.*=.*:QMAKE_CFLAGS_RELEASE=${CFLAGS}:" \
		-e "s:QMAKE_CXXFLAGS_RELEASE.*=.*:QMAKE_CXXFLAGS_RELEASE=${CXXFLAGS}:" \
		-e "s:QMAKE_LFLAGS_RELEASE.*=.*:QMAKE_LFLAGS_RELEASE=${LDFLAGS}:" \
		-e "s:X11R6/::" \
		-i "${S}"/mkspecs/$(qt_mkspecs_dir)/qmake.conf || die "sed ${S}/mkspecs/$(qt_mkspecs_dir)/qmake.conf failed"

	sed -e "s:QMAKE_CFLAGS_RELEASE.*=.*:QMAKE_CFLAGS_RELEASE=${CFLAGS}:" \
		-e "s:QMAKE_CXXFLAGS_RELEASE.*=.*:QMAKE_CXXFLAGS_RELEASE=${CXXFLAGS}:" \
		-e "s:QMAKE_LFLAGS_RELEASE.*=.*:QMAKE_LFLAGS_RELEASE=${LDFLAGS}:" \
		-i "${S}"/mkspecs/common/g++.conf || die "sed ${S}/mkspecs/common/g++.conf failed"

	# bug 172219
	sed -i -e "s:CXXFLAGS.*=:CXXFLAGS=${CXXFLAGS} :" \
		"${S}/qmake/Makefile.unix" || die "sed qmake/Makefile.unix CXXFLAGS failed"
	sed -i -e "s:LFLAGS.*=:LFLAGS=${LDFLAGS} :" \
		"${S}/qmake/Makefile.unix" || die "sed qmake/Makefile.unix LDFLAGS failed"
}

src_configure() {
	./configure -qt-sql-driver-sqlite -system-sqlite -opensource -confirm-license --prefix=/opt/qt-llmozlib2 || die
}

src_install() {
	emake INSTALL_ROOT="${D}" install || die "make install failed"
}
