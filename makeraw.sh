#!/bin/sh
# Usage:
#
#     ./makeimg.sh <image.yml> <output.img>
#
ARCH=$(uname -m|sed s/aarch64/arm64/|sed s/x86_64/amd64/)
MKIMAGE_TAG=$(linuxkit pkg show-tag pkg/mkimage-raw-efi)-$ARCH

linuxkit build -o - $1 | docker run -v /dev:/dev --privileged -i ${MKIMAGE_TAG} > $2
