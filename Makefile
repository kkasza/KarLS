#KarLS
#Complete system builder

#Components list in order
COMPONENTS:=cmpl pkg iso

.PHONY: default all cmpl kernel iso qemu install_deps clean distclean mrproper download sha256sum

default:
	@make --no-print-directory -f common.mk CALLEDFROMROOT=1
	@echo Possible components: $(COMPONENTS)

all: $(COMPONENTS)

cmpl:
	$(MAKE) -C $@ $@

pkg: cmpl
	$(MAKE) -C $@ $@

iso: pkg
	$(MAKE) -C $@ $@

install_deps:
	$(MAKE) -C cmpl $@

qemu: iso
	$(MAKE) -C $^ $@

ssh:
	$(MAKE) -C iso $@

#Targets to be run on all components
clean distclean mrproper download sha256sum:
	$(foreach var,$(COMPONENTS),\
		make --no-print-directory -C $(var) $@;)
