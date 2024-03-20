BINU_VER:=binutils-2.42
$(BINU_VER)-URL:=https://ftpmirror.gnu.org/gnu/binutils
$(BINU_VER)-FILE:=$(BINU_VER).tar.xz
$(BINU_VER)-SHA256:=f6e4d41fd5fc778b06b7891457b3620da5ecea1006c6a4a41ae998109f85a800

GCC_VER:=gcc-13.2.0
$(GCC_VER)-URL:=https://ftpmirror.gnu.org/gnu/gcc/$(GCC_VER)
$(GCC_VER)-FILE:=$(GCC_VER).tar.xz
$(GCC_VER)-SHA256:=e275e76442a6067341a27f04c5c6b83d8613144004c0413528863dc6b5c743da

GMP_VER:=gmp-6.3.0
$(GMP_VER)-URL:=https://ftpmirror.gnu.org/gnu/gmp
$(GMP_VER)-FILE:=$(GMP_VER).tar.xz
$(GMP_VER)-SHA256:=a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898

MPFR_VER:=mpfr-4.2.1
$(MPFR_VER)-URL:=https://ftpmirror.gnu.org/gnu/mpfr
$(MPFR_VER)-FILE:=$(MPFR_VER).tar.xz
$(MPFR_VER)-SHA256:=277807353a6726978996945af13e52829e3abd7a9a5b7fb2793894e18f1fcbb2

MPC_VER:=mpc-1.3.1
$(MPC_VER)-URL:=https://ftpmirror.gnu.org/gnu/mpc
$(MPC_VER)-FILE:=$(MPC_VER).tar.gz
$(MPC_VER)-SHA256:=ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8

ifeq ($(P),rpi)
LINUX_VER:=linux-5.10.110-rpi
$(LINUX_VER)-URL:=https://github.com/raspberrypi/linux/archive
$(LINUX_VER)-REALFILE:=8e1110a580887f4b82303b9354c25d7e2ff5860e.tar.gz
$(LINUX_VER)-FILE:=$(LINUX_VER).tar.gz
$(LINUX_VER)-REALDIR:=linux-8e1110a580887f4b82303b9354c25d7e2ff5860e
$(LINUX_VER)-SHA256:=e3244061e44426eafe97541633b87a71b8be1828d1bc48a18ec4c83fddb2f4c5
else
LINUX_VER:=linux-5.10.143
$(LINUX_VER)-URL:=https://cdn.kernel.org/pub/linux/kernel/v5.x
$(LINUX_VER)-FILE:=$(LINUX_VER).tar.xz
$(LINUX_VER)-SHA256:=fa2c9edef272d39dca52e057e1d41433cf1b6ab6a00d24a00333c0b735054e91
endif

MUSL_VER:=musl-1.2.5
$(MUSL_VER)-URL:=https://musl.libc.org/releases
$(MUSL_VER)-FILE:=$(MUSL_VER).tar.gz
$(MUSL_VER)-SHA256:=a9a118bbe84d8764da0ea0d28b3ab3fae8477fc7e4085d90102b8596fc7c75e4

SRC_LIST:=BINU GCC GMP MPFR MPC LINUX MUSL
