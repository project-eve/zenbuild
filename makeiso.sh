#!/bin/sh
# Usage:
#
#     ./makeiso.sh <image.yml> <output.iso>
#
ARCH=$(uname -m|sed s/aarch64/arm64/|sed s/x86_64/amd64/)
MKIMAGE_TAG=$(linuxkit pkg show-tag pkg/mkimage-iso-efi)-$ARCH

moby build -o - $1 | docker run -i ${MKIMAGE_TAG} > $2
