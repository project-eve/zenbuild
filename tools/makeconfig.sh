#!/bin/sh
# Usage:
#
#      ./maketestconfig.sh <conf dir> <output.img>
#
MKCONFIG_TAG="$(linuxkit pkg show-tag pkg/mkconf)"

[ $# -ne 2 ] && echo "Usage: maketestconfig.sh <conf dir> <output.img>" && exit 1

IMAGE=$2

# Ensure existence of image file
touch $IMAGE

# Docker, for unknown reasons, decides whether a passed bind mount is
# a file or a directory based on whether is a absolute pathname or a
# relative one (!).
#
# Of course, BSDs do not have the GNU specific realpath, so substitute
# it with a shell script.

case $2 in
    /*) ;;
    *) IMAGE=$PWD/$IMAGE;;
esac

(cd $1 ; tar cf - *) | docker run --privileged -v $IMAGE:/config.img -i ${MKCONFIG_TAG} /config.img
