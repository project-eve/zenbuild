#!/bin/sh
# Usage:
#
#      ./makeflash.sh [-C size] <output.img>
#
ARCH=$(uname -m|sed s/aarch64/arm64/|sed s/x86_64/amd64/)
MKFLASH_TAG="$(linuxkit pkg show-tag pkg/mkflash)-$ARCH"

if [ "$1" = "-C" ]; then
    SIZE=$2
    IMAGE=$3
    dd if=/dev/zero of=$IMAGE count=$(( $SIZE * 1024 )) bs=1024
    # If we're a non-root user, the bind mount gets permissions sensitive.
    # So we go docker^Wcowboy style
    chmod ugo+w $IMAGE
else
    IMAGE=$1
fi

# Docker, for unknown reasons, decides whether a passed bind mount is
# a file or a directory based on whether is a absolute pathname or a
# relative one (!).
#
# Of course, BSDs do not have the GNU specific realpath, so substitute
# it with a shell script.

case $IMAGE in
    /*) ;;
    *) IMAGE=$PWD/$IMAGE;;
esac

docker run --privileged -v $IMAGE:/output.img -i ${MKFLASH_TAG} /output.img
