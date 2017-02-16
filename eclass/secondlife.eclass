# @ECLASS: secondlife.eclass
# @MAINTAINER:
# techwolf@techwolf.net
# @BLURB: common settings and functions for Linden Labs code based secondlife
# packages
# @DESCRIPTION:
# The secondlife eclass contains common environment settings and functions for Linden
# Labs secondlife based code used by many third party viewers.

# build fails with python 3
PYTHON_COMPAT=( python{2_5,2_6,2_7} )

inherit cmake-utils games python-any-r1

LICENSE="GPL-2-with-Linden-Lab-FLOSS-exception"

# Nothing is re-distrubted, all from oriangle sources
RESTRICT="mirror"

IUSE="${IUSE} +vivox +openal +gstreamer +elfio dbus fmod tcmalloc"

RDEPEND="dev-libs/apr
	dev-libs/apr-util
	dev-libs/boost
	elfio? ( dev-libs/elfio )
	dev-libs/expat
	dbus? ( dev-libs/dbus-glib )
	dev-libs/openssl
	>=dev-libs/xmlrpc-epi-0.51-r1
	tcmalloc? ( dev-util/google-perftools )
	fmod? ( =media-libs/fmod-3.75* )
	media-libs/freetype
	virtual/jpeg
	media-libs/libogg
	media-libs/libpng
	media-libs/libsdl[X,opengl]
	media-libs/libvorbis
	<=media-libs/openjpeg-1.5.0:0
	openal? ( media-libs/openal
		media-libs/freealut )
	gstreamer? ( media-plugins/gst-plugins-meta:0.10[http] )
	net-dns/c-ares
	net-misc/curl
	sys-libs/zlib
	vivox? (
	         amd64? (
	              || (
	                     (
	                          sys-libs/zlib[abi_x86_32(-)]
	                          sys-apps/util-linux[abi_x86_32(-)]
	                          net-dns/libidn[abi_x86_32(-)]
	                          media-libs/openal[abi_x86_32(-)]
	                          media-libs/libsndfile[abi_x86_32(-)]
	                     )
	                     (
	                          app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)]
	                          app-emulation/emul-linux-x86-soundlibs[-abi_x86_32(-)]
	                     )
	                  )
	                 )
	         x86? ( net-dns/libidn
	                media-libs/openal
	                media-libs/libsndfile )
	        )
	x11-libs/gtk+:2
	x11-libs/pango[X]
	x11-libs/pangox-compat
	x11-libs/libXinerama
	virtual/opengl
	media-libs/freeglut"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/flex
	sys-devel/bison
	${PYTHON_DEPS}
	dev-libs/libndofdev
	dev-python/llbase"

# Prevent warning on binary only files
QA_TEXTRELS="usr/share/games/${PN}/lib/libvivoxsdk.so usr/share/games/${PN}/lib/libvivoxplatform.so usr/share/games/${PN}/lib/libortp.so"

# Bash can't handle floats, so we drop the "." and use a three digit verison number.
# 130 - LL snowglobe based code that switch to webkit instead of mozilla
# 200 - LL added some google tools and boost coroutine
# 210 - LL added pulseaudio support for linux
# 250 - LL v2.5.0 (220251) February 10, 2011: Added cmake option NON_RELEASE_CRASH_REPORTING
# 263 - LL v2.6.3 (227447) April 26, 2011: switch to autobuild and VS2010 for building the client instead of just the 3p-* packages.
# 271 - LL v2.7.1 (232828) June 14, 2011: mesh release. new depends: llcolladadom, glod, llconvexdecomposition or llconvexdecompositionstub or llhacdconvexdecomposition
# 320 - LL v3.2.0 (244443) November 08, 2011: STORM-1524 Fixes for viewer-autobuild for standalone. Most notiably, glh_linear
# 334 - LL v3.3.4 (264214) with spell checker.
# 340 - LL v3.4.0 (264911) with pathfinding (this version number currentelly not used)
# 350 - LL v3.5.0 (273444) with CHUI (this version number currentelly not used)
# 352 - LL v3.5.2 (276129) May 20, 2013: coroutine moved to dcoroutine
# 351 - LL v3.5.1 (274821) April 29, 2013: Server Side Appearence (SSA)
# 360 - LL v3.6.0 (277516) with Materials (this version number currentelly not used)
# 371 - LL v3.7.16 (299021) added uriparser depends, droped the 6 number for now. May have to refactor to four digit version number.
# 372 - LL v3.7.20 (296094) added packages-info.txt and depends on autobuild, but not all autobuilds will work with all clients (this version number currentelly not used)
# 372 - LL v3.7.28 (300847) May 08, 2015: Last version to support windows XP. Next version has autobuild VS2013 changes.
#
# 411 - added libvlc depends.


if [[ "${MY_LLCODEBASE}" -ge "130" ]] ; then
  IUSE="${IUSE} unit_test"
  DEPEND="${DEPEND}
	  unit_test? ( || ( dev-libs/tut dev-libs/tut-svn ) )
	  dev-libs/llqtwebkit-hg
	  || ( dev-libs/jsoncpp dev-libs/jsoncpp-svn dev-libs/jsoncpp-hg )
	  >=dev-libs/boost-1.39"
fi

if [[ "${MY_LLCODEBASE}" -ge "200" ]] ; then
  DEPEND="${DEPEND}
	  unit_test? ( dev-util/gmock )"
  if [[ "${MY_LLCODEBASE}" -ge "352" ]] ; then
    DEPEND="${DEPEND}
	    dev-libs/boost-dcoroutine"
   else
    DEPEND="${DEPEND}
	    dev-libs/boost-coroutine"
  fi
fi

if [[ "${MY_LLCODEBASE}" -ge "210" ]] ; then
  IUSE="${IUSE} pulseaudio"
fi

if [[ "${MY_LLCODEBASE}" -ge "250" ]] ; then
  IUSE="${IUSE} crash-reporting"
  DEPEND="${DEPEND}
	  crash-reporting? ( dev-util/google-breakpad-hg )"
fi

if [[ "${MY_LLCODEBASE}" -ge "271" ]] ; then
  DEPEND="${DEPEND}
          dev-libs/glod-hg
	  media-libs/llcolladadom-hg
	  dev-libs/llhacdconvexdecomposition-hg"
fi

if [[ "${MY_LLCODEBASE}" -ge "320" ]] ; then
  DEPEND="${DEPEND}
	  dev-libs/glh-hg"
fi

if [[ "${MY_LLCODEBASE}" -ge "334" ]] ; then
  DEPEND="${DEPEND}
	  app-text/hunspell"
fi

if [[ "${MY_LLCODEBASE}" -ge "371" ]] ; then
  DEPEND="${DEPEND}
	  dev-libs/uriparser"
fi

if [[ "${MY_LLCODEBASE}" -ge "411" ]] ; then
  DEPEND="${DEPEND}
	  media-video/vlc"
fi

# Internial function to take one file and convert it from DOS to UNIX if text file.
# Fixes permissions of shell, python, and source code files.
# Performance tweaks and pretty progress indecator
_check_and_convert_DOS() {
	if  echo "$1" | grep -q -E ".cpp$|.h$|.txt$|.ini$|.pem$|.xml$|.glsl$|.sh$|.py$" ; then
	  ROTATE=$((ROTATE+1))
	  case $ROTATE in
	    3) printf "\b-" ;;
	    6) printf "\b\\" ;;
	    9) printf "\b|" ;;
	    12)
	      printf "\b/"
	      ROTATE=0
	      ;;
	  esac
	  sed -i 's/\r$//' "$1"
	  if echo "$1" | grep -q -E ".sh$|.py$" ; then
	    chmod 755 "$1"
	   else
	    chmod 644 "$1"
	  fi
	 else
	  MY_DOS_FORMAT="$(file -b $1 | grep -i 'text')"
	  if [[ -n "${MY_DOS_FORMAT}" ]] ; then
	    printf "\b. "
	    sed -i 's/\r$//' "$1"
	  fi
	fi
}

# Convert all text files from DOS to UNIX
check_and_convert_DOS() {
	# Convert the src to UNIX format from DOS/Windows
	einfo "Convering source formatting from DOS to UNIX"
	printf " "
	ROTATE=0
	find "$1" -type f ! -path "*libraries*" ! -path "*installers*" ! -name "*tga" | while read i ; do _check_and_convert_DOS "$i" ; done
	einfo "Done!"
}

# live distfile check. For when file name and info is known only after doing a SVN pull
distfile_check_download() {
	ASSET="$1"
# 	if [[ -f "${MY_STORE_DIR}/${ASSET##*/}" ]] ; then
# 	  if echo "$2" | grep -q "$(md5sum ${MY_STORE_DIR}/${ASSET##*/} | awk '{print $1}')" ; then
# 	    einfo "${ASSET##*/} md5sum ok"
# 	   else
# 	    einfo "${ASSET##*/} md5sum failed, removing"
# 	    rm -f "${MY_STORE_DIR}/${ASSET##*/}"
# 	  fi
# 	fi
	if [[ ! -f "${MY_STORE_DIR}/${ASSET##*/}" ]] ; then
	  wget --directory-prefix="${MY_STORE_DIR}" "${ASSET}" || die "Problem with fetching ${ASSET##*/}"
	fi
	# the below does not work with portage 2.2.x, use secondlife_unpack instead with a full path to the downloaded file.
	# keeping the code for capility with older portage and ebuilds, it errors, but does not die.
	ln -s "${MY_STORE_DIR}/${ASSET##*/}" "${DISTDIR}/${ASSET##*/}"
}

# requires dev-perl/XML-XPath
# Many thanks to Cron Stardust that posted this example to the SLDev list.
xpath_get_value() {
    if has_version '>=dev-perl/XML-XPath-1.330'; then
        if [[ -f "${S}/autobuild.xml" ]] ; then
	  einfo "Getting $2 $1 from ${S}/autobuild.xml"
	  SLASSET=$(xpath -e "//key[text()=\"$1\"]/following-sibling::map[1]/key[text()=\"platforms\"]/following-sibling::map[1]/key[text()=\"$2\"]/following-sibling::map[1]/key[text()=\"archive\"]/following-sibling::map[1]/string[2]/text()" "${S}/autobuild.xml")
	  SLASSET_MD5SUM=$(xpath -e "//key[text()=\"$1\"]/following-sibling::map[1]/key[text()=\"platforms\"]/following-sibling::map[1]/key[text()=\"$2\"]/following-sibling::map[1]/key[text()=\"archive\"]/following-sibling::map[1]/string[1]/text()" "${S}/autobuild.xml" )
	 else
	  # some TPVs still use pre 2.6.3 build system parts.
	  einfo "Getting $2 $1 from ${S}/install.xml"
	  SLASSET=$(xpath "${S}/install.xml" "//key[text()=\"$1\"]/following-sibling::map[1]/key[text()=\"packages\"]/following-sibling::map[1]/key[text()=\"$2\"]/following-sibling::map[1]/uri/text()")
	  SLASSET_MD5SUM=$(xpath "${S}/install.xml" "//key[text()=\"$1\"]/following-sibling::map[1]/key[text()=\"packages\"]/following-sibling::map[1]/key[text()=\"$2\"]/following-sibling::map[1]/string/text()")
	fi
    else
	if [[ -f "${S}/autobuild.xml" ]] ; then
	  einfo "Getting $2 $1 from ${S}/autobuild.xml"
	  SLASSET=$(xpath "${S}/autobuild.xml" "//key[text()=\"$1\"]/following-sibling::map[1]/key[text()=\"platforms\"]/following-sibling::map[1]/key[text()=\"$2\"]/following-sibling::map[1]/key[text()=\"archive\"]/following-sibling::map[1]/string[2]/text()")
	  SLASSET_MD5SUM=$(xpath "${S}/autobuild.xml" "//key[text()=\"$1\"]/following-sibling::map[1]/key[text()=\"platforms\"]/following-sibling::map[1]/key[text()=\"$2\"]/following-sibling::map[1]/key[text()=\"archive\"]/following-sibling::map[1]/string[1]/text()")
	 else
	  # some TPVs still use pre 2.6.3 build system parts.
	  einfo "Getting $2 $1 from ${S}/install.xml"
	  SLASSET=$(xpath "${S}/install.xml" "//key[text()=\"$1\"]/following-sibling::map[1]/key[text()=\"packages\"]/following-sibling::map[1]/key[text()=\"$2\"]/following-sibling::map[1]/uri/text()")
	  SLASSET_MD5SUM=$(xpath "${S}/install.xml" "//key[text()=\"$1\"]/following-sibling::map[1]/key[text()=\"packages\"]/following-sibling::map[1]/key[text()=\"$2\"]/following-sibling::map[1]/string/text()")
	fi
    fi
}

# requires dev-perl/XML-XPath
get_install_xml_value() {
	SLASSET=""
	# url can be in linux64 or linux or linux32, its a changing target.
	use amd64 && xpath_get_value "$1" "linux64"
	[[ -z "${SLASSET}" ]] && xpath_get_value "$1" "linux"
	[[ -z "${SLASSET}" ]] && xpath_get_value "$1" "linux32"
	[[ -z "${SLASSET}" ]] && xpath_get_value "$1" "common"
	if [[ -z "${SLASSET}" ]] ; then
	  die "failed to get $1 from install.xml"
	 else
	  distfile_check_download "${SLASSET}" "${SLASSET_MD5SUM}"
	fi
}

# same as built-in unpack, but allows absolute paths.
# this is to work around permissions bug in ${DISTDIR} now that user is portage instead of root doing the build.
secondlife_unpack() {
	local srcdir
	local x
	local y y_insensitive
	local suffix suffix_insensitive
	local myfail
	local eapi=${EAPI:-0}
	[ -z "$*" ] && die "Nothing passed to the 'unpack' command"

	for x in "$@"; do
		__vecho ">>> Unpacking ${x} to ${PWD}"
		suffix=${x##*.}
		suffix_insensitive=$(LC_ALL=C tr "[:upper:]" "[:lower:]" <<< "${suffix}")
		y=${x%.*}
		y=${y##*.}
		y_insensitive=$(LC_ALL=C tr "[:upper:]" "[:lower:]" <<< "${y}")

		if [[ ${x} == "./"* ]] ; then
			srcdir=""
		elif [[ ${x} == ${DISTDIR%/}/* ]] ; then
			die "Arguments to unpack() cannot begin with \${DISTDIR}."
		elif [[ ${x} == "/"* ]] ; then
		: #	die "Arguments to unpack() cannot be absolute"
		else
			srcdir="${DISTDIR}/"
		fi
		[[ ! -s ${srcdir}${x} ]] && die "${x} does not exist"

		__unpack_tar() {
			if [[ ${y_insensitive} == tar ]] ; then
				if ___eapi_unpack_is_case_sensitive && \
					[[ tar != ${y} ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"secondary suffix '${y}' which is unofficially" \
						"supported with EAPI '${EAPI}'. Instead use 'tar'."
				fi
				$1 -c -- "$srcdir$x" | tar xof -
				__assert_sigpipe_ok "$myfail"
			else
				local cwd_dest=${x##*/}
				cwd_dest=${cwd_dest%.*}
				$1 -c -- "${srcdir}${x}" > "${cwd_dest}" || die "$myfail"
			fi
		}

		myfail="failure unpacking ${x}"
		case "${suffix_insensitive}" in
			tar)
				if ___eapi_unpack_is_case_sensitive && \
					[[ tar != ${suffix} ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'. Instead use 'tar'."
				fi
				tar xof "$srcdir$x" || die "$myfail"
				;;
			tgz)
				if ___eapi_unpack_is_case_sensitive && \
					[[ tgz != ${suffix} ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'. Instead use 'tgz'."
				fi
				tar xozf "$srcdir$x" || die "$myfail"
				;;
			tbz|tbz2)
				if ___eapi_unpack_is_case_sensitive && \
					[[ " tbz tbz2 " != *" ${suffix} "* ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'. Instead use 'tbz' or 'tbz2'."
				fi
				${PORTAGE_BUNZIP2_COMMAND:-${PORTAGE_BZIP2_COMMAND} -d} -c -- "$srcdir$x" | tar xof -
				__assert_sigpipe_ok "$myfail"
				;;
			zip|jar)
				if ___eapi_unpack_is_case_sensitive && \
					[[ " ZIP zip jar " != *" ${suffix} "* ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'." \
						"Instead use 'ZIP', 'zip', or 'jar'."
				fi
				# unzip will interactively prompt under some error conditions,
				# as reported in bug #336285
				( set +x ; while true ; do echo n || break ; done ) | \
				unzip -qo "${srcdir}${x}" || die "$myfail"
				;;
			gz|z)
				if ___eapi_unpack_is_case_sensitive && \
					[[ " gz z Z " != *" ${suffix} "* ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'. Instead use 'gz', 'z', or 'Z'."
				fi
				__unpack_tar "gzip -d"
				;;
			bz2|bz)
				if ___eapi_unpack_is_case_sensitive && \
					[[ " bz bz2 " != *" ${suffix} "* ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'. Instead use 'bz' or 'bz2'."
				fi
				__unpack_tar "${PORTAGE_BUNZIP2_COMMAND:-${PORTAGE_BZIP2_COMMAND} -d}"
				;;
			7z)
				local my_output
				my_output="$(7z x -y "${srcdir}${x}")"
				if [ $? -ne 0 ]; then
					echo "${my_output}" >&2
					die "$myfail"
				fi
				;;
			rar)
				if ___eapi_unpack_is_case_sensitive && \
					[[ " rar RAR " != *" ${suffix} "* ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'. Instead use 'rar' or 'RAR'."
				fi
				unrar x -idq -o+ "${srcdir}${x}" || die "$myfail"
				;;
			lha|lzh)
				if ___eapi_unpack_is_case_sensitive && \
					[[ " LHA LHa lha lzh " != *" ${suffix} "* ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'." \
						"Instead use 'LHA', 'LHa', 'lha', or 'lzh'."
				fi
				lha xfq "${srcdir}${x}" || die "$myfail"
				;;
			a)
				if ___eapi_unpack_is_case_sensitive && \
					[[ " a " != *" ${suffix} "* ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'. Instead use 'a'."
				fi
				ar x "${srcdir}${x}" || die "$myfail"
				;;
			deb)
				if ___eapi_unpack_is_case_sensitive && \
					[[ " deb " != *" ${suffix} "* ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'. Instead use 'deb'."
				fi
				# Unpacking .deb archives can not always be done with
				# `ar`.  For instance on AIX this doesn't work out.  If
				# we have `deb2targz` installed, prefer it over `ar` for
				# that reason.  We just make sure on AIX `deb2targz` is
				# installed.
				if type -P deb2targz > /dev/null; then
					y=${x##*/}
					local created_symlink=0
					if [ ! "$srcdir$x" -ef "$y" ] ; then
						# deb2targz always extracts into the same directory as
						# the source file, so create a symlink in the current
						# working directory if necessary.
						ln -sf "$srcdir$x" "$y" || die "$myfail"
						created_symlink=1
					fi
					deb2targz "$y" || die "$myfail"
					if [ $created_symlink = 1 ] ; then
						# Clean up the symlink so the ebuild
						# doesn't inadvertently install it.
						rm -f "$y"
					fi
					mv -f "${y%.deb}".tar.gz data.tar.gz || die "$myfail"
				else
					ar x "$srcdir$x" || die "$myfail"
				fi
				;;
			lzma)
				if ___eapi_unpack_is_case_sensitive && \
					[[ " lzma " != *" ${suffix} "* ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'. Instead use 'lzma'."
				fi
				__unpack_tar "lzma -d"
				;;
			xz)
				if ___eapi_unpack_is_case_sensitive && \
					[[ " xz " != *" ${suffix} "* ]] ; then
					eqawarn "QA Notice: unpack called with" \
						"suffix '${suffix}' which is unofficially supported" \
						"with EAPI '${EAPI}'. Instead use 'xz'."
				fi
				if ___eapi_unpack_supports_xz; then
					__unpack_tar "xz -d"
				else
					__vecho "unpack ${x}: file format not recognized. Ignoring."
				fi
				;;
			*)
				__vecho "unpack ${x}: file format not recognized. Ignoring."
				;;
		esac
	done
	# Do not chmod '.' since it's probably ${WORKDIR} and PORTAGE_WORKDIR_MODE
	# should be preserved.
	find . -mindepth 1 -maxdepth 1 ! -type l -print0 | \
		${XARGS} -0 chmod -fR a+rX,u+w,g-w,o-w
}

# snowglobe based viewers used doc/asset_urls.txt
secondlife_asset_unpack() {
	# source downloads URL variables and download suppemential packages.
	. "${S}"/doc/asset_urls.txt
	cd "${WORKDIR}"
	# einfo "Getting md5sums from ${SLASSET_MD5}"
	# MD5SUMS_OSS="$(wget -O - -q "${SLASSET_MD5}")"
	# if [[ -z "${MD5SUMS_OSS}" ]] ; then die "md5sum fetch failed: ${SLASSET_MD5}" ; fi
	distfile_check_download "${SLASSET_ART}" $(echo "${MD5SUMS_OSS}" | grep "${SLASSET_ART##*/}")
	unpack ${SLASSET_ART##*/} || die "Problem with unpacking ${SLASSET_ART##*/}"
	distfile_check_download "${SLASSET_LIBS_LINUXI386}" $(echo "${MD5SUMS_OSS}" | grep "${SLASSET_LIBS_LINUXI386##*/}")
	unpack ${SLASSET_LIBS_LINUXI386##*/} || die "Problem with unpacking ${SLASSET_LIBS_LINUXI386##*/}"
	
	cd "${WORKDIR}"/linden
	if [[ ! -f "${WORKDIR}/linden/indra/llwindow/glh/glh_linear.h" ]] ; then
	  # need glh/glh_linear.h that is not aviable in portage.
	  # http://jira.secondlife.com/browse/VWR-9005
	  get_install_xml_value "glh_linear"
	  unpack ${SLASSET##*/} || die "Problem with unpacking ${SLASSET##*/}"
	 else
	  einfo "glh_linear.h found, not downloading glh package."
	fi

	if [[ ! -f "${WORKDIR}/linden/indra/newview/res-sdl/llno.BMP" ]] ; then
	  # need the SDL package due to Linden Labs put mouse cursers in it.
	  # http://jira.secondlife.com/browse/VWR-9475
	  get_install_xml_value "SDL"
	  unpack ${SLASSET##*/} || die "Problem with unpacking ${SLASSET##*/}"
	 else
	  einfo "SDL cursers found, not downloading SDL package."
	fi

	if use vivox ; then
	  get_install_xml_value "vivox"
	  unpack ${SLASSET##*/} || die "Problem with unpacking ${SLASSET##*/}"
	fi
}

# download and unpack LL colladadom
secondlife_colladadom_unpack() {
	EHG_REVISION=""
	S="${WORKDIR}/colladadom"
	EHG_REPO_URI="https://bitbucket.org/lindenlab/colladadom"
	mercurial_src_unpack
}

# fixes to LL colladadom
secondlife_colladadom_prepare() {
	# fix hardcoded CFLAGS
	sed -i -e 's/ccFlags += -m32//' "${WORKDIR}/colladadom/make/common.mk"
	sed -i -e "s/-O2/${CFLAGS}/" "${WORKDIR}/colladadom/make/common.mk"
	sed -i -e 's/ccFlags += -m32//' "${WORKDIR}/colladadom/make/minizip.mk"
	# remove prebuilts includes
	sed -i -e 's:includeOpts += -Istage/packages/include/pcre::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += $(addprefix stage/packages/lib/release/,libpcrecpp.a libpcre.a )::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:includeOpts += -Istage/packages/include::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_system.a::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_filesystem.a::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_system-mt$(debug_suffix).a::' "${WORKDIR}/colladadom/make/dom.mk"
	sed -i -e 's:libOpts += stage/packages/lib/$(conf)/libboost_filesystem-mt$(debug_suffix).a::' "${WORKDIR}/colladadom/make/dom.mk"
}

secondlife_colladadom_build() {
	if [[ "${MY_LLCODEBASE}" -ge "263" ]] ; then
	  # call this cmake-utils internial function so we get CMAKE_BUILD_DIR defined.
	  # Linden Lab code expects packages to be in the cmake build directory. (Yea, it was a WTF moment when debugging this problem)
	  S="${WORKDIR}/linden/indra"
	  _check_build_dir
	fi
	
	S="${WORKDIR}/colladadom"
	cd "${S}"
	emake CXX=g++ || die "emake failed"

	einfo "Done building colladadom"

	if [[ "${MY_LLCODEBASE}" -ge "263" ]] ; then
	  mkdir -p "${CMAKE_BUILD_DIR}"/packages/lib/{debug,release}
	  MY_STAGE="${CMAKE_BUILD_DIR}"/packages/lib/release
	 else
	  mkdir -p "${WORKDIR}/linden"/libraries/i686-linux/{lib_debug_client,lib_release_client}
	  MY_STAGE="${WORKDIR}/linden/libraries/i686-linux/lib_release_client"
	fi
	cp "build/linux-1.4/libcollada14dom.so" "${MY_STAGE}/libcollada14dom.so"
        cp "build/linux-1.4/libcollada14dom.so.2" "${MY_STAGE}/libcollada14dom.so.2"
        cp "build/linux-1.4/libcollada14dom.so.2.2" "${MY_STAGE}/libcollada14dom.so.2.2"
        cp "build/linux-1.4/libminizip.so" "${MY_STAGE}/libminizip.so"
        cp "build/linux-1.4/libminizip.so.1" "${MY_STAGE}/libminizip.so.1"
        cp "build/linux-1.4/libminizip.so.1.2.3" "${MY_STAGE}/libminizip.so.1.2.3"

        if [[ "${MY_LLCODEBASE}" -ge "263" ]] ; then
	  MY_STAGE="${CMAKE_BUILD_DIR}"/packages/lib/debug
	 else
	  MY_STAGE="${WORKDIR}/linden/libraries/i686-linux/lib_debug_client"
	fi
        cp "build/linux-1.4-d/libcollada14dom-d.so" "${MY_STAGE}/libcollada14dom-d.so"
        cp "build/linux-1.4-d/libcollada14dom-d.so.2" "${MY_STAGE}/libcollada14dom-d.so.2"
        cp "build/linux-1.4-d/libcollada14dom-d.so.2.2" "${MY_STAGE}/libcollada14dom-d.so.2.2"
        cp "build/linux-1.4-d/libminizip-d.so" "${MY_STAGE}/libminizip-d.so"
        cp "build/linux-1.4-d/libminizip-d.so.1" "${MY_STAGE}/libminizip-d.so.1"
        cp "build/linux-1.4-d/libminizip-d.so.1.2.3" "${MY_STAGE}/libminizip-d.so.1.2.3"
	
	if [[ "${MY_LLCODEBASE}" -ge "263" ]] ; then
	  mkdir -p "${CMAKE_BUILD_DIR}/packages/include/collada"
	  MY_STAGE="${CMAKE_BUILD_DIR}/packages/include"
	 else
	  mkdir -p "${WORKDIR}/linden/libraries/include/collada"
	  MY_STAGE="${WORKDIR}/linden/libraries/include"
	fi
	cp -R include/* "${MY_STAGE}/collada"

	einfo "Done staging colladadom"
}

secondlife_cmake_prep() {
	cd "${S}"
	mycmakeargs="${mycmakeargs} -DSTANDALONE:BOOL=TRUE -DUSESYSTEMLIBS:BOOL=TRUE -DNDOF:BOOL=TRUE
		     -DAPP_SHARE_DIR:STRING=${GAMES_DATADIR}/${PN}
		     -DAPP_BINARY_DIR:STRING=${GAMES_DATADIR}/${PN}/bin
		     $(cmake-utils_use openal OPENAL)
		     $(cmake-utils_use gstreamer GSTREAMER)
		     $(cmake-utils_use dbus DBUSGLIB)
		     $(cmake-utils_use tcmalloc USE_GOOGLE_PERFTOOLS)"

	[[ "${MY_LLCODEBASE}" -ge "200" ]] && mycmakeargs="${mycmakeargs} $(cmake-utils_use unit_test LL_TESTS)"
	[[ "${MY_LLCODEBASE}" -ge "210" ]] && mycmakeargs="${mycmakeargs} $(cmake-utils_use pulseaudio PULSEAUDIO)"
	[[ "${MY_LLCODEBASE}" -ge "250" ]] && mycmakeargs="${mycmakeargs} $(cmake-utils_use crash-reporting NON_RELEASE_CRASH_REPORTING)"

	if use fmod && ! use amd64 ; then
	  mycmakeargs="${mycmakeargs} -DFMOD:BOOL=TRUE"
	 else
	  mycmakeargs="${mycmakeargs} -DFMOD:BOOL=FALSE"
	fi

	# LL like to break code from time to time
	mycmakeargs="${mycmakeargs} -DGCC_DISABLE_FATAL_WARNINGS:BOOL=TRUE"

	# Linden Labs sse enabled processor build detection is broken, lets turn it on for
	# amd64 or (x86 and (sse or sse2))
	if { use amd64 || use sse || use sse2; }; then
	    append-cflags "-DLL_VECTORIZE=1"
	    append-cxxflags "-DLL_VECTORIZE=1"
	fi

	# Don't package by default on LINUX
	if [[ "${MY_LLCODEBASE}" -ge "130" ]] ; then
	  mycmakeargs="${mycmakeargs} -DPACKAGE:BOOL=FALSE"
	 else
	  mycmakeargs="${mycmakeargs} -DINSTALL:BOOL=TRUE" # somebody has very strange logic, INSTALL=No packageing. ?!
	fi

	# Overide and set build type to "Release" instead of "Gentoo"
	CMAKE_BUILD_TYPE="Release"
	
	# OPENJPEG_VERSION needs to be set for openjpeg greater then 1.3. It was removed from openjpeg.h on 1.4 stable.
	# Don't set it if program includes it own openjpeg
	if [[ ! -f "${WORKDIR}/linden/indra/libopenjpeg/openjpeg.h" ]] ; then
	  if has_version '>=media-libs/openjpeg-1.5'; then
	      append-cflags '-DOPENJPEG_VERSION=\"1.5\"'
	      append-cxxflags '-DOPENJPEG_VERSION=\"1.5\"'
	    else
	      if has_version '>=media-libs/openjpeg-1.4'; then
		append-cflags '-DOPENJPEG_VERSION=\"1.4\"'
		append-cxxflags '-DOPENJPEG_VERSION=\"1.4\"'
	      fi
	  fi
	fi

	# huntspell fix
	if [[ -f "${WORKDIR}/linden/indra/cmake/FindHunSpell.cmake" ]] || [[ -f "${WORKDIR}/linden/indra/cmake/FindHUNSPELL.cmake" ]]; then
	  einfo "Adding \"hunspell\" to HUNSPELL_NAMES"
	  mycmakeargs="${mycmakeargs} -DHUNSPELL_NAMES=hunspell"
	fi

	# upstream set this to on, let turn it off untill they fix it. This will override any users setting. :-(
	CMAKE_VERBOSE="OFF"
	
	# if gcc >=5.x.x, set -fpermissive flags
	if tc-is-gcc && [[ $(gcc-version) > 5.0 ]]; then
	  einfo "Adding -fpermissive to gcc flags"
	  append-cflags '-fpermissive'
          append-cxxflags '-fpermissive'
        fi
}

secondlife_viewer_manifest() {
	# Linden Labs uses viewer_manifest.py to install instead of cmake install
	# Because viewer_manifest.py is not called by cmake, set up enveroment that cmakes does before calling viewer_manifest.py
	cd "${WORKDIR}"/linden/indra/newview/
	# MY_ARCH="i686" only adds libs supplied by LL for NOT standalone builds.
	# The file list for standalone on i686 matches x86_64 but for one extra file that is of no harm on x86
	einfo "Setting up environment for viewer_manifest.py"
	MY_ARCH="x86_64"
	MY_VIEWER_CHANNEL="$(grep VIEWER_CHANNEL ${CMAKE_BUILD_DIR}/CMakeCache.txt | sed -e 's/VIEWER_CHANNEL:STRING=//')"
	MY_VIEWER_LOGIN_CHANNEL="$(grep VIEWER_LOGIN_CHANNEL ${CMAKE_BUILD_DIR}/CMakeCache.txt | sed -e 's/VIEWER_LOGIN_CHANNEL:STRING=//')"
	MY_VIEWER_BINARY_NAME="$(grep VIEWER_BINARY_NAME ${CMAKE_BUILD_DIR}/CMakeCache.txt | sed -e 's/VIEWER_BINARY_NAME:STRING=//')"
	if [[ ( -f "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger" ) && ( ! -f "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger-stripped" ) ]] ; then
	  einfo "Coping ${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger to ${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger-stripped"
	  cp -p "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger" "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger-stripped" || die
	fi
	if [[ ! -f "${CMAKE_BUILD_DIR}/newview/secondlife-stripped" ]] ; then
	  einfo "Coping ${CMAKE_BUILD_DIR}/newview/${MY_VIEWER_BINARY_NAME} to ${CMAKE_BUILD_DIR}/newview/secondlife-stripped"
	  cp -p "${CMAKE_BUILD_DIR}/newview/${MY_VIEWER_BINARY_NAME}" "${CMAKE_BUILD_DIR}/newview/secondlife-stripped" || die
	fi

	if grep -q 'login_channel' "${WORKDIR}/linden/indra/newview/viewer_manifest.py" ; then
	  "${WORKDIR}"/linden/indra/newview/viewer_manifest.py  --actions="copy" \
	    --channel="${MY_VIEWER_CHANNEL} Gentoo" \
	    --login_channel="${MY_VIEWER_LOGIN_CHANNEL} Gentoo" \
	    --arch="${MY_ARCH}" \
	    --build="${CMAKE_BUILD_DIR}/newview" \
	    --dest="${D%/}/${GAMES_DATADIR}/${PN}" \
	    --grid="default" $1 || die
	else
	  "${WORKDIR}"/linden/indra/newview/viewer_manifest.py  --actions="copy" \
	    --channel="${MY_VIEWER_CHANNEL} Gentoo" \
	    --versionfile=${CMAKE_BUILD_DIR}/newview/viewer_version.txt \
	    --arch="${MY_ARCH}" \
	    --build="${CMAKE_BUILD_DIR}/newview" \
	    --dest="${D%/}/${GAMES_DATADIR}/${PN}" \
	    --grid="default" $1 || die
	fi
	
	# check for and intall crashlogger
	if [[ ( ! -f "${GAMES_DATADIR}/${PN}/linux-crash-logger.bin" ) && ( -f "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger" ) ]] ; then
	  einfo "Installing crash logger..."
	  exeinto "${GAMES_DATADIR}/${PN}"
	  newexe "${CMAKE_BUILD_DIR}/linux_crash_logger/linux-crash-logger" linux-crash-logger.bin || die
	fi

	# vivox will work with a 64 bit build with 32 bit emul libs, except for
	# libopenal due to to old a version supplied with amd64 32-bit libopenal. "undefined symbol: alcGetMixedBuffer"
	# in that case, use the vivox supplied one.
	# FIRE-16605 BUG-8471 MAINT-4876 https://jira.phoenixviewer.com/browse/FIRE-16605
	if use vivox ; then
	  einfo "Installing voice files..."
	  if [[ -f "${WORKDIR}/linden/lib/release/SLVoice" ]] ; then
	    exeinto "${GAMES_DATADIR}/${PN}/bin"
	    doexe ../../lib/release/SLVoice || die
	    exeinto "${GAMES_DATADIR}/${PN}/lib"
	    ! use amd64 && rm ../../lib/release/libvivoxoal.so.1
	    doexe ../../lib/release/lib* || die
	  else
	    exeinto "${GAMES_DATADIR}/${PN}/bin"
	    doexe vivox-runtime/i686-linux/SLVoice || die
	    ! use amd64 && rm vivox-runtime/i686-linux/libvivoxoal.so.1
	    exeinto "${GAMES_DATADIR}/${PN}/lib"
	    doexe vivox-runtime/i686-linux/lib* || die
	  fi

	  # from Linden Lab commets in viewer_manifest.py, "no - we'll re-use the viewer's own OpenAL lib"
	  if use amd64 ; then
	    # ln -s ../../../../lib32/libopenal.so "${D%/}/${GAMES_DATADIR}/${PN}/lib/libvivoxoal.so.1"
	    einfo "" # bash requires something to do.
	  else
	    ln -s ../../../../lib/libopenal.so "${D%/}/${GAMES_DATADIR}/${PN}/lib/libvivoxoal.so.1"
	  fi
	fi
}

secondlife_pkg_setup() {
	# set active python to 2.x
	# version is controled by variable before inherit
	python-any-r1_pkg_setup

	use amd64 && use fmod && ewarn "fmod is only available on x86. Disabling fmod"

	# Unset all locale related variables, they can make the
	# patches and build fail.
	eval unset ${!LC_*} LANG LANGUAGE
	#  set LINGUAS to en for the build tools, may fix an international build bug.
	export LINGUAS=en
}

# Things that effect every LL code base build that needs fixing.
secondlife_src_prepare() {
	# strip out any hardcoded cflags. We are not cross compiling. Use gento supplied flags.
	einfo "Striping out hardcoded cflags options so that ebuild supplied cflags are used."
	sed -i -e 's:-march=[a-zA-Z0-9]*::' "${WORKDIR}/linden/indra/cmake/00-Common.cmake"
	sed -i -e 's:-m32::' "${WORKDIR}/linden/indra/cmake/00-Common.cmake"
	sed -i -e 's:-m64::' "${WORKDIR}/linden/indra/cmake/00-Common.cmake"
	sed -i -e 's:-O[23]::' "${WORKDIR}/linden/indra/cmake/00-Common.cmake"
	
	# Gentoo defines _FORTIFY_SOURCE by default for gcc 4.7 and up
	if tc-is-gcc && [[ $(gcc-version) > 4.6 ]]; then
	  einfo "Removing \"add_definitions(-D_FORTIFY_SOURCE=2)\" from 00-Common.cmake"
	  sed -i -e 's:add_definitions(-D_FORTIFY_SOURCE=2):#add_definitions(-D_FORTIFY_SOURCE=2):g' "${WORKDIR}/linden/indra/cmake/00-Common.cmake"
        fi
	
	# reenable an optimization due to no longer using gcc 3.x that crash on it.
	einfo "Re-enabling tree-vectorize optimization."
	sed -i -e 's:#add_definitions(-ftree-vectorize):add_definitions(-ftree-vectorize):' "${WORKDIR}/linden/indra/cmake/00-Common.cmake"

	# Setting LDFLAGS will fail as "unrecognized option '--as-needed;-Wl'"
	# This is due to list will add ; to the APPENDed list
	# LL fixed it in 2.0
	# Fix it for all pre 2.0 based LL code.
	if grep -q 'LIST(APPEND CMAKE_EXE_LINKER_FLAGS ' "${WORKDIR}/linden/indra/newview/CMakeLists.txt" ; then
	  einfo "Fixing an improper CMAKE_EXE_LINKER_FLAGS setting."
	  sed -i -e 's/LIST(APPEND CMAKE_EXE_LINKER_FLAGS -Wl,--as-needed)/SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--as-needed")/' "${WORKDIR}/linden/indra/newview/CMakeLists.txt" || die "LDFLAG fix failed"
	  sed -i -e 's/LIST(APPEND /list(APPEND /' "${WORKDIR}/linden/indra/newview/CMakeLists.txt" || die "LDFLAG fix failed"
	  sed -i -e 's:list(APPEND CMAKE_EXE_LINKER_FLAGS -Wl,--as-needed):set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--as-needed"):' "${WORKDIR}/linden/indra/linux_crash_logger/CMakeLists.txt"
	fi

	# Make tcmalloc optional
	if use tcmalloc && grep -q "^set(USE_GOOGLE_PERFTOOLS OFF)" "${WORKDIR}/linden/indra/cmake/GooglePerfTools.cmake" ; then
	  einfo "Fixing tcmalloc/google perftools setting so it can be enabled."
	  sed -i -e 's:^set(USE_GOOGLE_PERFTOOLS OFF)::' "${WORKDIR}/linden/indra/cmake/GooglePerfTools.cmake"
	fi

	# Re-enable gstreamer for 64-bit systems.
	if grep -q '"x86_64" ]; then' "${WORKDIR}/linden/indra/newview/linux_tools/wrapper.sh" && grep -q "GStreamer is automatically disabled - for now - on 64-bit systems due" "${WORKDIR}/linden/indra/newview/linux_tools/wrapper.sh" ; then
	  einfon "Fixing gstremer for 64-bit systems -->"
	  epatch "${EBUILD%/*}/../../eclass/SNOW-589_gstreamer.patch"
	fi

	# gstreamer >=0.10.28 used a glib exteril "C" define
	# Remove the 'static' part as that becomes illegil.
	# Move the marco outside the function.
	# We are doing sed magic here. :-)
	if has_version '>=media-libs/gstreamer-0.10.28'; then
	  MY_FILE=""
	  [[ -f "${WORKDIR}/linden/indra/llmedia/llmediaimplgstreamervidplug.cpp" ]] && MY_FILE="${WORKDIR}/linden/indra/llmedia/llmediaimplgstreamervidplug.cpp"
	  [[ -f "${WORKDIR}/linden/indra/media_plugins/gstreamer010/llmediaimplgstreamervidplug.cpp" ]] && MY_FILE="${WORKDIR}/linden/indra/media_plugins/gstreamer010/llmediaimplgstreamervidplug.cpp"
	  if [[ -n "${MY_FILE}" ]] && grep -q "static GST_PLUGIN_DEFINE" "${MY_FILE}" ; then
	    einfo "Fixing ${MY_FILE} for gstreamer-0.10.28 or higher"
	    sed -i -e 's/static GST_PLUGIN_DEFINE/       GST_PLUGIN_DEFINE/' "${MY_FILE}" || die "gstreamer 0.10.28 fix failed"
	    sed -i -e ':a;N;s/void gst_slvideo_init_class (void)\n{//;ba' "${MY_FILE}" || die "gstreamer 0.10.28 fix failed"
	    sed -i -e 's/#undef PACKAGE/#undef PACKAGE\n\nvoid gst_slvideo_init_class (void)\n{/' "${MY_FILE}" || die "gstreamer 0.10.28 fix failed"
	  fi
	fi

	# Boost 1.42 fix. This affects all LL based code.
	if has_version '>=dev-libs/boost-1.42'; then
	  if ! grep -q "virtual bool is_required" ${WORKDIR}/linden/indra/newview/llcommandlineparser.cpp ; then
	    einfo "Fixing llcommandlineparser.cpp for boost 1.42 or higher"
	    sed -i -e 's:virtual bool apply_default:virtual bool is_required() const\n    {\n        return false;\n    }\n\n    virtual bool apply_default:' \
	      ${WORKDIR}/linden/indra/newview/llcommandlineparser.cpp || die "Boost 1.42 fix failed"
	  fi
	fi

	# gcc >= 4.4.3 fix. This affect all 2.0 code.
	if has_version '>=sys-devel/gcc-4.4'; then
	  if grep -q "inline LLPanelStandStopFlying" "${WORKDIR}/linden/indra/newview/llmoveview.cpp" ; then
	    einfon "Fixing a gcc 4.4.x error -->"
	    if grep -q "LLUICtrlFactory::getInstance" "${WORKDIR}/linden/indra/newview/llmoveview.cpp" ; then
	      epatch "${EBUILD%/*}/../../eclass/SNOW-609_inline_getInstance_v2.patch"
	    else
	      epatch "${EBUILD%/*}/../../eclass/VWR-23406_inline_getInstance.patch"
	    fi
	  fi
	fi

	# libpng >=1.14 fix. Affects all LL based code.
	if has_version '>=media-libs/libpng-1.4'; then
	  if grep -q "png_set_gray_1_2_4_to_8" "${WORKDIR}/linden/indra/llimage/llpngwrapper.cpp" ; then
	    einfo "Fixing llpngwrapper.{h|cpp} for libpng 1.14 or highter"
	    sed -i -e 's:#include "libpng12/png.h":#define png_infopp_NULL (png_infopp)NULL\n#include "png.h":' "${WORKDIR}/linden/indra/llimage/llpngwrapper.h"
	    sed -i -e 's:png_set_gray_1_2_4_to_8:png_set_expand_gray_1_2_4_to_8:' "${WORKDIR}/linden/indra/llimage/llpngwrapper.cpp"
	  fi
	fi

	# Make sure FindTut.cmake is not called if !unit_test
	if [[ -f "${WORKDIR}/linden/indra/cmake/LLAddBuildTest.cmake" ]] && [[ "${MY_LLCODEBASE}" -ge "130" ]] && ! use unit_test ; then
	  einfo "Fixing all CMakeLists.txt files to not include the unit framework tests"
	  find "${WORKDIR}/linden" -name "CMakeLists.txt" -exec sed -i -e 's:include(Tut):#include(Tut):' {} \;
	  find "${WORKDIR}/linden" -name "CMakeLists.txt" -exec sed -i -e 's:include(LLAddBuildTest):#include(LLAddBuildTest):' {} \;
	  
	  # added in 3.2.5, fixes "Unknown CMake command "SET_TEST_PATH"."
	  find "${WORKDIR}/linden" -name "CMakeLists.txt" -exec sed -i -e 's:add_subdirectory(${VIEWER_PREFIX}test):# add_subdirectory(${VIEWER_PREFIX}test):' {} \;
	  
	  if grep -q "LL_ADD_PROJECT_UNIT_TESTS" "${WORKDIR}/linden/indra/cmake/LLAddBuildTest.cmake" ; then
	    # 2.0 base code
	    find "${WORKDIR}/linden" -name "CMakeLists.txt" -exec sed -i -e 's:LL_ADD_PROJECT_UNIT_TESTS(:#LL_ADD_PROJECT_UNIT_TESTS(:' {} \;
	    find "${WORKDIR}/linden" -name "CMakeLists.txt" -exec sed -i -e 's:LL_ADD_INTEGRATION_TEST(.*):#&:' {} \;
	   else
	    # snowglobe 1.3 base code
	    find "${WORKDIR}/linden" -name "CMakeLists.txt" -exec sed -i -e 's:ADD_VIEWER_BUILD_TEST(:#ADD_VIEWER_BUILD_TEST(:' {} \;
	    find "${WORKDIR}/linden" -name "CMakeLists.txt" -exec sed -i -e 's:ADD_BUILD_TEST(:#ADD_BUILD_TEST(:' {} \;
	  fi
	fi

	# Enable the unit tests for LL code without LL_TESTS
	if [[ "${MY_LLCODEBASE}" -eq "130" ]] && use unit_test ; then
	  einfo "Enableing the unit tests"
	  sed -i -e 's:^ENDIF (NOT LINUX AND VIEWER)::' "${WORKDIR}/linden/indra/llmessage/CMakeLists.txt"
	  sed -i -e 's:^IF (NOT LINUX AND VIEWER)::' "${WORKDIR}/linden/indra/llmessage/CMakeLists.txt"

	    sed -i -e 's:^endif (NOT STANDALONE)::' "${WORKDIR}/linden/indra/llimage/CMakeLists.txt"
	    sed -i -e 's:^if (NOT STANDALONE)::' "${WORKDIR}/linden/indra/llimage/CMakeLists.txt"
	    sed -i -e 's:^endif (NOT STANDALONE)::' "${WORKDIR}/linden/indra/newview/CMakeLists.txt"
	    sed -i -e 's:^if (NOT STANDALONE)::' "${WORKDIR}/linden/indra/newview/CMakeLists.txt"
	  
	fi

	# dcoroutine is currenty broken on boost >= 1.61. Fallback to older coroutine that works on newer boost.
	if [[ "${MY_LLCODEBASE}" -ge "200" ]] ; then
	  # fix includes due to coroutine could not be packaged within boost package path due to gentoo uses a sybolic link.
	  # UPDATE: Gentoo DE-slotted boost, but LL is changing things around to support the new API comming out in Boost 1.53
	  #   So is keeping the seperate libs to handle the two different APIs.
	  einfo "Fixing \"include\" files to point to gentoo overlay packaged coroutine headers"
	  sed -i -e 's/#include <boost\/d\?coroutine\//#include <boost-coroutine\//g' "${WORKDIR}/linden/indra/viewer_components/login/lllogin.cpp"
	  sed -i -e 's/#include <boost\/d\?coroutine\//#include <boost-coroutine\//g' "${WORKDIR}/linden/indra/llcommon/llcoros.h"
	  sed -i -e 's/#include <boost\/d\?coroutine\//#include <boost-coroutine\//g' "${WORKDIR}/linden/indra/llcommon/lleventcoro.h"
	  sed -i -e 's/#include <boost\/d\?coroutine\//#include <boost-coroutine\//g' "${WORKDIR}/linden/indra/llcommon/tests/lleventcoro_test.cpp"
	  sed -i -e 's/#include <boost\/d\?coroutine\//#include <boost-coroutine\//g' "${WORKDIR}/linden/indra/newview/llviewerprecompiledheaders.h"
	  
	  sed -i -e 's/boost::dcoroutines/boost::coroutines/g' "${WORKDIR}/linden/indra/llcommon/llcoros.h"
	  sed -i -e 's/boost::dcoroutines/boost::coroutines/g' "${WORKDIR}/linden/indra/llcommon/llcoros.cpp"
	  sed -i -e 's/boost::dcoroutines/boost::coroutines/g' "${WORKDIR}/linden/indra/llcommon/lleventcoro.h"
	  sed -i -e 's/boost::dcoroutines/boost::coroutines/g' "${WORKDIR}/linden/indra/llcommon/tests/lleventcoro_test.cpp" 
	fi

	# append Gentoo to viewer channel name. LL is now publishing stats.
	if [[ -f "${WORKDIR}/linden/indra/llcommon/llversionviewer.h" ]]; then
	  einfo "Appending Gentoo to the viewer channel name."
	  sed -i -e 's:LL_CHANNEL = "\(.*\)":LL_CHANNEL = "\1 Gentoo":' "${WORKDIR}/linden/indra/llcommon/llversionviewer.h"
	fi

	# SNOW-783 typo bug in saving object cache files, affects ALL LL based code.
	if grep -q 'sobjects_%d_%d.slc' "${WORKDIR}/linden/indra/newview/llviewerregion.cpp" ; then
	  einfo "Fixing SNOW-783 typo bug in saving object cache files"
	  sed -i -e 's:sobjects_%d_%d.slc:objects_%d_%d.slc:' "${WORKDIR}/linden/indra/newview/llviewerregion.cpp"
	fi

	# Default group limit increase for clients that don't use the new caps system.
	if grep -q 'const S32 MAX_AGENT_GROUPS = 25' "${WORKDIR}/linden/indra/llcommon/indra_constants.h" ; then
	  einfo "Increasing MAX_AGENT_GROUPS to 50."
	  sed -i -e 's:const S32 MAX_AGENT_GROUPS = 25:const S32 MAX_AGENT_GROUPS = 50:' ${WORKDIR}/linden/indra/llcommon/indra_constants.h
	fi

	# fix an cmake warning, we want to overide the FindZLIB module with a faster one.
	sed -i -e 's:set(ROOT_PROJECT_NAME:cmake_policy(SET CMP0017 OLD)\nset(ROOT_PROJECT_NAME:' "${WORKDIR}/linden/indra/CMakeLists.txt"

	# fontconfig greater then 2.8 fix. Affects all LL based code.
	if has_version '>=media-libs/fontconfig-2.9.0'; then
	  # easer to test for patched file then to test for un-patch file.
	  if ! ( grep -q 'FcResult fresult' "${WORKDIR}/linden/indra/llwindow/llwindowsdl.cpp" || grep -q 'FcResult result' "${WORKDIR}/linden/indra/llwindow/llwindowsdl.cpp" || grep -q 'FcResult eResult' "${WORKDIR}/linden/indra/llwindow/llwindowsdl.cpp") ; then
	    einfo "Fixing llwindowsdl.cpp for fontconfig greater then 2.8"
	    epatch "${EBUILD%/*}/../../eclass/fontconfig_2.9.0.patch"
	  fi
	fi

	if has_version '>=sys-devel/bison-2.6' && grep -q 'ifdef __cplusplus' "${WORKDIR}/linden/indra/lscript/lscript_compile/indra.y" ; then
	  einfo "Patching for bison 2.6 or greater"
	  epatch "${EBUILD%/*}/../../eclass/bison_2.6.patch"
	fi
	
	# newer boost defaults to version 3 filesystem.
	if has_version '>=dev-libs/boost-1.46' && [[ -f "${WORKDIR}/linden/indra/llvfs/lldiriterator.cpp" ]]; then
	  if ! ( grep -q 'BOOST_FILESYSTEM_VERSION == 3' "${WORKDIR}/linden/indra/llvfs/lldiriterator.cpp" || grep -q 'catch (const fs::filesystem_error' "${WORKDIR}/linden/indra/llvfs/lldiriterator.cpp"); then
	    einfo "Patching for boost filesystem version 3"
	    epatch "${EBUILD%/*}/../../eclass/boost_1_44.patch"
	  fi
	fi
	
	# newer glibc defines siginfo_t fully in bits/siginfo.h
	if has_version '>=sys-libs/glibc-2.16.0'; then
	  if ! ( grep -q '#include <signal.h>' "${WORKDIR}/linden/indra/llcommon/llapp.h"); then
	    einfo "Fixing for glibc 2.16 or greater"
	    sed -i -e 's:typedef struct siginfo siginfo_t;:#include <signal.h>:' ${WORKDIR}/linden/indra/llcommon/llapp.h
	  fi
	fi

	# fix bug in BuildVersion.cmake for out of source builds
	sed -i -e 's:COMMAND ${MERCURIAL}:COMMAND ${MERCURIAL} --cwd ${CMAKE_SOURCE_DIR}:' ${WORKDIR}/linden/indra/cmake/BuildVersion.cmake
	
	# work around autobuild depends. Started at LL v3.7.28
	if [[ -f "${WORKDIR}/linden/indra/cmake/BuildPackagesInfo.cmake" ]]; then
	  einfo "Working around autobuild depend."
	  sed -i -e 's:include(BuildPackagesInfo)::' "${WORKDIR}/linden/indra/newview/CMakeLists.txt"
	  touch "${WORKDIR}/linden/indra/newview/packages-info.txt"
	fi
	
	# Fix a cmake 3.3.x bug, don't overide a cmake variable. 
	if [[ "${MY_LLCODEBASE}" -ge "351" ]]; then
	  einfo "Working around viewer cmake bug"
	  sed -i -e 's:include(ConfigurePkgConfig)::' "${WORKDIR}/linden/indra/cmake/Variables.cmake"
	fi
	
        # gcc 4.6.3 and up has problems with boost 1.57 and up.
	if has_version '>=dev-libs/boost-1.57' && grep -q ' bind(&LLCalcParser' "${WORKDIR}/linden/indra/llmath/llcalcparser.h" ; then
	  einfo "Updating LLCalcParser to use phoenix::bind"
	  sed -i -e 's/bind(&/phoenix::bind(\&/g' "${WORKDIR}/linden/indra/llmath/llcalcparser.h"
	fi
	
	# fix for boost 1.59
	if has_version '>=dev-libs/boost-1.59' && ! grep -q 'adjacent_tokens_only' "${WORKDIR}/linden/indra/newview/llcommandlineparser.cpp" ; then
	  einfo "Patching LLCLPValue for boost > 1.57"
	  epatch "${EBUILD%/*}/../../eclass/boost_1.59.patch"
	fi
	
	# fix jsoncpp include bugs. Some viewers fix this.
	# Note: Can not be fixed via cmake findpath as features.h will be picked up on system instead of jsoncpp/feature.h
	if [[ "${MY_LLCODEBASE}" -ge "263" ]] ; then
            einfo "(v2.6.3)Fixing jsoncpp includes"
            sed -i -e 's:#include "reader.h":#include "jsoncpp/reader.h":' "${WORKDIR}/linden/indra/newview/lltranslate.cpp"
        fi
        if [[ "${MY_LLCODEBASE}" -ge "382" ]] ; then
            einfo "(v3.8.2)Fixing jsoncpp includes"
            sed -i -e 's:#include "reader.h":#include "jsoncpp/reader.h":' "${WORKDIR}/linden/indra/newview/llmarketplacefunctions.cpp"
            sed -i -e 's:#include "writer.h":#include "jsoncpp/writer.h":' "${WORKDIR}/linden/indra/newview/llmarketplacefunctions.cpp"
        fi
        if [[ "${MY_LLCODEBASE}" -ge "403" ]] ; then
            einfo "(v4.0.3)Fixing jsoncpp includes"
            sed -i -e 's:#include "value.h":#include "jsoncpp/value.h":' "${WORKDIR}/linden/indra/llcommon/llsdjson.h"
            sed -i -e 's:#include "reader.h":#include "jsoncpp/reader.h":' "${WORKDIR}/linden/indra/llmessage/llcorehttputil.cpp"
            sed -i -e 's:#include "writer.h":#include "jsoncpp/writer.h":' "${WORKDIR}/linden/indra/llmessage/llcorehttputil.cpp"
        fi
        if [[ "${MY_LLCODEBASE}" -ge "477" ]] ; then
            einfo "(v4.7.7)Fixing firestorm jsoncpp includes"
            sed -i -e 's:#include "reader.h":#include "jsoncpp/reader.h":' "${WORKDIR}/linden/indra/newview/llappviewerlinux.cpp"
	fi
	
	# add findpkg for vlc for USESYSTEMLIBS
	if [[ -f "${WORKDIR}/linden/indra/cmake/LibVLCPlugin.cmake" ]] && ! grep -q 'pkg_check_modules' "${WORKDIR}/linden/indra/cmake/LibVLCPlugin.cmake"; then
            einfo "Adding pkg_check_modules for vlc."
            sed -i -e 's:else (USESYSTEMLIBS):include(FindPkgConfig)\npkg_check_modules(VLC REQUIRED vlc-plugin)\nset(VLC_INCLUDE_DIR ${VLC_INCLUDE_DIRS})\nset(VLC_PLUGIN_LIBRARIES ${VLC_LIBRARIES})\nelse (USESYSTEMLIBS):' "${WORKDIR}/linden/indra/cmake/LibVLCPlugin.cmake"
            sed -i -e 's:elseif (LINUX):elseif (LINUX AND NOT USESYSTEMLIBS):' "${WORKDIR}/linden/indra/cmake/LibVLCPlugin.cmake"
	fi
}

secondlife_pkg_postinst() {
    games_pkg_postinst
    if use amd64 && use vivox ; then
      elog ""
      elog "The voice binary is 32 bit and may have problems in 64 bit"
      elog "systems with greater then 4G of RAM. See this thread for details"
      elog "http://www.nvnews.net/vbulletin/showthread.php?t=127984"
    fi
    elog ""
    elog "If you like to add a patch or patches to the build, place patches at:"
    elog "${PORTAGE_CONFIGROOT%/}/etc/portage/patches/${CATEGORY}/${PF}/feature.patch   or"
    elog "${PORTAGE_CONFIGROOT%/}/etc/portage/patches/${CATEGORY}/${P}/feature.patch   or"
    elog "${PORTAGE_CONFIGROOT%/}/etc/portage/patches/${CATEGORY}/${PN}/feature.patch"
    
    if has_version '=x11-libs/qt-webkit-4.8.1'; then
      elog "NOTICE: webkit version 4.8.1 will not work with https over squid proxy."
      elog "If you are using squid proxy, web profiles and marketplace will not work."
    fi
}

EXPORT_FUNCTIONS pkg_setup pkg_postinst
