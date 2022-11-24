#!/bin/bash
#
# This script will build a linux kernel and needs the following packages to be installed:
# build-essential flex bison bc libelf-dev libssl-dev

set -euo pipefail

linux="linux-6.0.9"

build_kernel() {
  wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/$linux.tar.xz"
  tar xf "$linux.tar.xz"
  cd "$linux"
  make defconfig
  make -j4
  cd ..
}

build_initramfs() {
  gcc -static -o init init.c
  mkdir rootfs
  cp init rootfs/
  cd rootfs
  find -print0 | cpio -0oH newc | gzip > ../initramfs.cpio.gz
  cd ..
  rm -rf rootfs
}


build_kernel
build_initramfs

qemu-system-x86_64 -kernel "$linux/arch/x86/boot/bzImage" -initrd initramfs.cpio.gz
