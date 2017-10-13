# Copyright 2017 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: webvcs.eclass
# @MAINTAINER: techwolf.lupindo@gmail.com
# @BLURB: Some common code that is usefull for taking snapshots off of popular vcs hosting sites
# set variables before inherting this eclass

RESTRICT="mirror"

# @ECLASS-VARIABLE: EGIT_COMMIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# The commit identifier to check out a snapshot.

# @ECLASS-VARIABLE: GITHUBNAME
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set this to the github account and repository name seperatated by a /
# example: GITHUBNAME="nant/nant"

if [[ -n "$EGIT_COMMIT" ]] ;  then
    GITHUBACC=${GITHUBNAME%/*}
    GITHUBREPO=${GITHUBNAME#*/}
    SRC_URI="https://github.com/${GITHUBACC}/${GITHUBREPO}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.${EGIT_COMMIT:0:5}.tar.gz"
    S="${WORKDIR}/${GITHUBREPO}-${EGIT_COMMIT}"
fi

# @ECLASS-VARIABLE: EHG_COMMIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# The commit identifier to check out a snapshot.

# @ECLASS-VARIABLE: BITBUCKETNAME
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set this to the bitbucket account and repository name seperatated by a /
# example: BITBUCKETNAME="lindenlab/llbase"

if [[ -n "$EHG_COMMIT" ]] ;  then
    BITBUCKETACC=${BITBUCKETNAME%/*}
    BITBUCKETREPO=${BITBUCKETNAME#*/}
    SRC_URI="https://bitbucket.org/${BITBUCKETACC}/${BITBUCKETREPO}/get/${EHG_COMMIT}.tar.bz2 -> ${P}.${EHG_COMMIT:0:5}.tar.bz2"
    S="${WORKDIR}/${BITBUCKETACC}-${BITBUCKETREPO}-${EHG_COMMIT}"
fi
