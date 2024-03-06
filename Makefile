#KarLS
#Complete system builder

#Components list in order
COMPONENTS:=cmpl kernel osimg devimg

.PHONY: default all cmpl kernel osimg devimg qemu install_deps imgclean clean distclean mrproper download sha256sum

default:
	@make --no-print-directory -f common.mk CALLEDFROMROOT=1
	@echo Possible components: $(COMPONENTS)

all: $(COMPONENTS)

cmpl:
	$(MAKE) -C $@ $@

#compiling another arch. cross compiler (e.g. x86_64 after arm), then coming back (to arm)
#makes dates newer and starts compilement of an already done arch (arm after x86_64 again),
#this breaks arch-dependent symlinks for the previous compilement - that's why the |
kernel: | cmpl
	$(MAKE) -C $@ $@

osimg: kernel
	$(MAKE) -C $@ $@

devimg: osimg
	$(MAKE) -C $@ $@

qemu: devimg
	$(MAKE) -C $< $@

install_deps:
	$(MAKE) -C cmpl $@

imgclean:
#	$(MAKE) -C kernel _local_clean
	$(MAKE) -C osimg _local_clean
	$(MAKE) -C devimg _local_clean

httpd: devimg
	sudo busybox httpd
	/sbin/ifconfig | grep inet | grep -v inet6

minicom:
	sudo chmod 666 /dev/ttyACM0
	minicom

#Targets to be run on all components
clean distclean mrproper download sha256sum:
	$(foreach var,$(COMPONENTS),\
		make --no-print-directory -C $(var) $@;)
