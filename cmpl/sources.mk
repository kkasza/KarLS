BINU_VER:=binutils-2.44
$(BINU_VER)-URL:=https://ftpmirror.gnu.org/gnu/binutils
$(BINU_VER)-FILE:=$(BINU_VER).tar.xz
$(BINU_VER)-SHA256:=ce2017e059d63e67ddb9240e9d4ec49c2893605035cd60e92ad53177f4377237

GCC_VER:=gcc-14.2.0
$(GCC_VER)-URL:=https://ftpmirror.gnu.org/gnu/gcc/$(GCC_VER)
$(GCC_VER)-FILE:=$(GCC_VER).tar.xz
$(GCC_VER)-SHA256:=a7b39bc69cbf9e25826c5a60ab26477001f7c08d85cec04bc0e29cabed6f3cc9

GMP_VER:=gmp-6.3.0
$(GMP_VER)-URL:=https://ftpmirror.gnu.org/gnu/gmp
$(GMP_VER)-FILE:=$(GMP_VER).tar.xz
$(GMP_VER)-SHA256:=a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898

MPFR_VER:=mpfr-4.2.2
$(MPFR_VER)-URL:=https://ftpmirror.gnu.org/gnu/mpfr
$(MPFR_VER)-FILE:=$(MPFR_VER).tar.xz
$(MPFR_VER)-SHA256:=b67ba0383ef7e8a8563734e2e889ef5ec3c3b898a01d00fa0a6869ad81c6ce01

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
LINUX_VER:=linux-6.12.21
$(LINUX_VER)-URL:=https://cdn.kernel.org/pub/linux/kernel/v6.x
$(LINUX_VER)-FILE:=$(LINUX_VER).tar.xz
$(LINUX_VER)-SHA256:=9d1ae39a2ea024d99646f645fdbbbfa4545577132ba2643e01df75e32246d6c7
endif

MUSL_VER:=musl-1.2.5
$(MUSL_VER)-URL:=https://musl.libc.org/releases
$(MUSL_VER)-FILE:=$(MUSL_VER).tar.gz
$(MUSL_VER)-SHA256:=a9a118bbe84d8764da0ea0d28b3ab3fae8477fc7e4085d90102b8596fc7c75e4

SRC_LIST:=BINU GCC GMP MPFR MPC LINUX MUSL
