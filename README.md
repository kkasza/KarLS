# KarLS
KarLS / Karl's absolutely reduced Linux System

KarLS is an **experimental** busybox/musl based mini distro, built completely from sources.
It is currently tested on KVM/QEMU - including Google Compute Engine - and VMware.
Also tested and works on Asus' excellent but EOL Chromebook C302C(A) - after unlocking UEFI and scrubbing chromeos ofc. See doc/ for more info.
It supports only x86_64, and raspberry pi support is planned - I have previous experience with cross-compiling to the PI.

KarLS is a hobby thing, that started out like sort of a reproduciple Linux From Scratch.
Buildroot also gave KarLS lots of inspiration of course, that's a great professional project. For any production project I highly recommend BR.
Karls uses an own gcc/binutils/musl/ccache etc. toolchain, as BR does.

> [!WARNING]
> Currently, KarLS is aiming to reach *minimal* usability, a.k.a. 1.0. - still far away from there.

## To compile natively (I build on Debian 12):
* *make install_deps* - apt install a few packages - uses sudo
* *make cmpl* - compile the musl based gcc compiler toolchain
* *make pkg* - compile the packages, then package them into .kpm format
* *make iso* - compile and build the installation iso image

## To compile in a Docker container
Download the **dockerfile** from the *docker-build* subdirectory of this repo into an empty directory. No need to clone the whole git.
Run **docker build -t karls-builder .** in the new subdirectory. I recommend running this in a detachable terminal like *tmux*, as it runs for a long time.
This will setup a minimal Debian based container and run the whole build process. It will require around 16 GB.
See *docker-build/README.md* for some more information.

## Other useful commands:
### / main directory and /cmpl /pkg / iso subdirectories
* *make download* - download all required sources before doing anything (normally done right before the compilation of the program starts)
* *make sha256sum* - verify all sources with sha256sum (this is done **everytime** right after download, so this is a double-check option)
* *make clean* - delete compiled sources
* *make distclean* - delete compiled sources, patched sources\ **and** compiler cache (ccache)
* *make mrproper* - like distclean, but delete downloaded srouces too.
* *make genpatch* - generate patch file from patched source package $PPKG (in */src subdirectory), $PTCNAME is the name of ther patch, $PTCCOMMENT is the patch comment - see /common.mk

### in cmpl/ subdirectory
* *make reset_cmpl* - delete compiler and extract it as a vanilla unomdified version since the last compalation - useful for testing package library dependecies

### in pkg/ subdirectory
* *make busybox-config* - run make menuconfig in patched busybox source, make a diff file in pkg/busybox directory with config changes
* *make kernel-config* - run make menuconfig in patched kernel source, make a diff file in pkg/kernel directory with config changes

### in iso/ subdirectory
* *make rebuild_initrd* - rebuild the initrd for the install iso, after changing kernel/modules, etc.
* *make rebuild_iso* - rebuild iso, after changing packages - initrd stays the same!
* *make gcp_image* - package the qemu installed disk image as a Google Compute Engine image, for uploading as a custom GCE image
* *make qemu* - start qemu with the installation iso in a virtual cdrom drive - works in / main directory too
* *make ssh* - ssh into the running qemu system after installation - works in / main directory too
