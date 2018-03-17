#!/bin/sh
# Usage:
#
#     ./makerootfs.sh <image.yml> <fs> <output.img>
#
# The following env variables change the behaviour of this script
#     ZEN_DEFAULT_BOOT - sets the default GRUB menu entry. See 
#                        pkg/mkrootfs*/make-rootfs for details:
#                          0 is the default
#                          1 is qemu specific boot arguments


ARCH=$(uname -m|sed s/aarch64/arm64/|sed s/x86_64/amd64/)

usage() {
    echo "Usage:"
    echo
    echo "$0 <image.yml> {ext4|squash} <output.img>"
    echo
    exit 1
}

if [ $# -ne 3 ]; then
    usage
fi

case $2 in
    ext4) MKROOTFS_PKG=mkrootfs-ext4 ;;
    squash) MKROOTFS_PKG=mkrootfs-squash ;;
    *) usage
esac
MKROOTFS_TAG="$(linuxkit pkg show-tag pkg/${MKROOTFS_PKG})-$ARCH"

linuxkit build -o - $1 | docker run -e ZEN_DEFAULT_BOOT -v /dev:/dev --privileged -i ${MKROOTFS_TAG} > $3
