BINU_VER:=binutils-2.39
$(BINU_VER)-URL:=https://ftpmirror.gnu.org/gnu/binutils
$(BINU_VER)-FILE:=$(BINU_VER).tar.xz
$(BINU_VER)-SHA256:=645c25f563b8adc0a81dbd6a41cffbf4d37083a382e02d5d3df4f65c09516d00

GCC_VER:=gcc-12.2.0
$(GCC_VER)-URL:=https://ftpmirror.gnu.org/gnu/gcc/$(GCC_VER)
$(GCC_VER)-FILE:=$(GCC_VER).tar.xz
$(GCC_VER)-SHA256:=e549cf9cf3594a00e27b6589d4322d70e0720cdd213f39beb4181e06926230ff

GMP_VER:=gmp-6.2.1
$(GMP_VER)-URL:=https://ftpmirror.gnu.org/gnu/gmp
$(GMP_VER)-FILE:=$(GMP_VER).tar.xz
$(GMP_VER)-SHA256:=fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2

MPFR_VER:=mpfr-4.1.0
$(MPFR_VER)-URL:=https://ftpmirror.gnu.org/gnu/mpfr
$(MPFR_VER)-FILE:=$(MPFR_VER).tar.xz
$(MPFR_VER)-SHA256:=0c98a3f1732ff6ca4ea690552079da9c597872d30e96ec28414ee23c95558a7f

MPC_VER:=mpc-1.2.1
$(MPC_VER)-URL:=https://ftpmirror.gnu.org/gnu/mpc
$(MPC_VER)-FILE:=$(MPC_VER).tar.gz
$(MPC_VER)-SHA256:=17503d2c395dfcf106b622dc142683c1199431d095367c6aacba6eec30340459

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

MUSL_VER:=musl-1.2.3
$(MUSL_VER)-URL:=https://musl.libc.org/releases
$(MUSL_VER)-FILE:=$(MUSL_VER).tar.gz
$(MUSL_VER)-SHA256:=7d5b0b6062521e4627e099e4c9dc8248d32a30285e959b7eecaa780cf8cfd4a4

SRC_LIST:=BINU GCC GMP MPFR MPC LINUX MUSL
