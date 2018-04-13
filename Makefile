PATH := $(CURDIR)/build-tools/bin:$(PATH)

# How large to we want the disk to be in Mb
MEDIA_SIZE=700

ZARCH=$(shell uname -m)
DOCKER_ARCH_TAG_aarch64=arm64
DOCKER_ARCH_TAG_x86_64=amd64
DOCKER_ARCH_TAG=$(DOCKER_ARCH_TAG_$(ZARCH))

FALLBACK_IMG_aarch64=fallback_aarch64.img
FALLBACK_IMG_x86_64=fallback.img
FALLBACK_IMG=$(FALLBACK_IMG_$(ZARCH))

ROOTFS_IMG_aarch64=rootfs_aarch64.img
ROOTFS_IMG_x86_64=rootfs.img
ROOTFS_IMG=$(ROOTFS_IMG_$(ZARCH))

QEMU_OPTS_aarch64= -machine virt,gic_version=3 -machine virtualization=true -cpu cortex-a57 -machine type=virt
# -drive file=./bios/flash0.img,format=raw,if=pflash -drive file=./bios/flash1.img,format=raw,if=pflash
# [ -f bios/flash1.img ] || dd if=/dev/zero of=bios/flash1.img bs=1048576 count=64
QEMU_OPTS_x86_64= -cpu SandyBridge
QEMU_OPTS_COMMON= -m 4096 -smp 4 -serial mon:stdio -bios ./bios/OVMF.fd \
	-net nic,vlan=0 -net user,id=eth0,vlan=0,net=192.168.1.0/24,dhcpstart=192.168.1.10,hostfwd=tcp::2222-:22 \
	-net nic,vlan=1 -net user,id=eth1,vlan=1,net=192.168.2.0/24,dhcpstart=192.168.2.10
QEMU_OPTS=$(QEMU_OPTS_COMMON) $(QEMU_OPTS_$(ZARCH))

DOCKER_UNPACK= _() { C=`docker create $$1 fake` ; docker export $$C | tar -xf - $$2 ; docker rm $$C ; } ; _

.PHONY: run pkgs build-pkgs help build-tools

all: help

help:
	@echo zenbuild: LinuxKit-based Xen images composer
	@echo
	@echo amd64 targets:
	@echo "   'make fallback.img'   builds an image with the fallback"
	@echo "                         bootloader"
	@echo "   'make run'            run fallback.img image using qemu'"
	@echo

build-tools:
	${MAKE} -C build-tools all

build-pkgs: build-tools
	make -C build-pkgs

pkgs: build-tools build-pkgs
	make -C pkg

bios:
	mkdir bios

bios/EFI: bios
	cd bios ; $(DOCKER_UNPACK) $(shell make -s -C pkg PKGS=grub show-tag)-$(DOCKER_ARCH_TAG) EFI
	cd bios/EFI/BOOT ; mv BOOTAA64GNU.EFI B ; rm BOOT* ; mv B BOOTAA64.EFI
	(echo "set root=(hd0)" ; echo "chainloader /EFI/BOOT/BOOTAA64GNU.EFI" ; echo boot) > bios/EFI/BOOT/grub.cfg

bios/OVMF.fd: bios
	cd bios ; $(DOCKER_UNPACK) $(shell make -s -C build-pkgs BUILD-PKGS=uefi show-tag)-$(DOCKER_ARCH_TAG) OVMF.fd

# run-installer
#
# This creates an image equivalent to fallback.img (called target.img)
# through the installer. It's the long road to fallback.img. Good for
# testing.
#
run-installer:
	dd if=/dev/zero of=target.img count=750000 bs=1024
	qemu-system-$(ZARCH) $(QEMU_OPTS) -hda target.img -cdrom installer.iso -boot d

run-fallback run: bios/OVMF.fd
	qemu-system-$(ZARCH) $(QEMU_OPTS) -drive file=$(FALLBACK_IMG),format=raw

run-rootfs: bios/OVMF.fd bios/EFI $(ROOTFS_IMG)
	qemu-system-$(ZARCH) $(QEMU_OPTS) -drive file=$(ROOTFS_IMG),format=raw -drive file=fat:rw:./bios/,format=raw 

images/%.yml: parse-pkgs.sh images/%.yml.in
	./parse-pkgs.sh $@.in > $@
	# the following is a horrible hack that needs to go away ASAP
	if [ "$(ZARCH)" != `uname -m` ] ; then \
	   sed -e 's#-amd64\s*$$##' -e 's#-arm64\s*$$##' \
               -e '/linuxkit|zededa\/[^:]*:/s#\s*$$#-$(DOCKER_ARCH_TAG)#' -E -i.orig $@ ;\
	   echo "WARNING: We are assembling a $(ZARCH) image on `uname -m`. Things may break." ;\
        fi

$(ROOTFS_IMG): images/fallback.yml
	./makerootfs.sh images/fallback.yml squash $@

config.img:
	./maketestconfig.sh config.img

$(FALLBACK_IMG): $(ROOTFS_IMG) config.img
	# FIXME: the following is a workaround for GRUB on aarch64
	if [ "$(ZARCH)" == aarch64 ] ; then \
	  rm -f grub.tar 2>/dev/null || : ;\
          $(DOCKER_UNPACK) $(shell make -s -C pkg PKGS=grub show-tag)-$(DOCKER_ARCH_TAG) EFI ;\
	  mv EFI/BOOT/BOOTAA64.EFI EFI/BOOT/B ; rm -f EFI/BOOT/BOOT* ; mv EFI/BOOT/B EFI/BOOT/BOOTAA64.EFI ;\
          (echo 'gptprio.next -d dev -u uuid' ;\
           echo 'set root=$$dev' ;\
           echo 'chainloader ($$dev)/EFI/BOOT/BOOTAA64GNU.EFI' ;\
           echo 'boot' ;\
           echo 'reboot') > EFI/BOOT/grub.cfg ;\
          tar cf grub.tar EFI ; rm -rf EFI ;\
          GRUB_IMG=grub.tar ;\
        fi ;\
	tar c $${GRUB_IMG} $(ROOTFS_IMG) config.img | ./makeflash.sh -C ${MEDIA_SIZE} $@

.PHONY: pkg_installer
pkg_installer: $(ROOTFS_IMG) config.img
	cp $(ROOTFS_IMG) config.img pkg/installer
	make -C pkg PKGS=installer LINUXKIT_OPTS="--disable-content-trust --disable-cache" forcebuild

#
# INSTALLER IMAGE CREATION:
#
# Use makeiso instead of linuxkit own's format because the
# former are able to boot on our platforms.

installer.iso: images/installer.yml pkg_installer
	./makeiso.sh images/installer.yml installer.iso	

.PHONY: FORCE
FORCE:
