# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="usb-modeswitch"
PKG_VERSION="2.6.1"
PKG_SHA256="5195d9e136e52f658f19e9f93e4f982b1b67bffac197d0a455cd8c2cd245fa34"
PKG_LICENSE="GPL"
PKG_SITE="https://launchpad.net/ubuntu/+source/usb-modeswitch/2.6.1-3ubuntu1"
# PKG_URL="http://www.draisberghof.de/usb_modeswitch/${PKG_NAME}-${PKG_VERSION}.orig.tar.bz2"
PKG_URL="https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/usb-modeswitch/2.6.1-3ubuntu1/usb-modeswitch_2.6.1.orig.tar.bz2"
PKG_DEPENDS_TARGET="toolchain libusb"
PKG_LONGDESC="USB_ModeSwitch - Handling Mode-Switching USB Devices on Linux"
PKG_BUILD_FLAGS="-sysroot"

makeinstall_target() {
	mkdir -p ${INSTALL}/usr/sbin
	cp usb_modeswitch ${INSTALL}/usr/sbin
}