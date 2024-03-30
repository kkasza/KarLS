#!/bin/sh

tar -C / -xvJf /mnt/iso/packages/musl-1.2.5.txz
tar -C / -xvJf /mnt/iso/packages/grub-2.12.txz

mkdir /mnt/target
ln -s /mnt/target/boot /boot
