# disable content trust for now
LINUXKIT_OPTS= --disable-content-trust

# Boot related
PKGS += boot grub xen kernel
# Userland tools
PKGS += kexec-tools xen-tools dom0-ztools qrexec-lib qrexec-dom0
# Zededa
PKGS += dnsmasq wwan wlan #test-microsvcs test-cert
# Image related
PKGS += mkimage-iso-efi mkimage-raw-efi mkrootfs-ext4 mkflash

.PHONY: push force-push build forcebuild show-tag clean dockerfiles

build: dockerfiles
	@set -e; for d in $(PKGS); do linuxkit pkg build ${LINUXKIT_OPTS} "$$d"; done

push:
	@set -e; for d in $(PKGS); do linuxkit pkg push ${LINUXKIT_OPTS} "$$d"; done

forcepush:
	@set -e; for d in $(PKGS); do linuxkit pkg push --force ${LINUXKIT_OPTS} "$$d"; done

forcebuild:
	@set -e; for d in $(PKGS); do linuxkit pkg build --force ${LINUXKIT_OPTS} "$$d"; done

show-tag:
	@set -e; for d in $(PKGS); do linuxkit pkg show-tag "$$d"; done

clean:

dockerfiles: $(addsuffix /Dockerfile, $(PKGS)/)

%: %.template FORCE
	(cd ..; ./parse-pkgs.sh pkg/$< > pkg/$@)
FORCE:
