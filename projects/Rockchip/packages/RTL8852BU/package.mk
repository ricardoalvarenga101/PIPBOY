# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present AmberELEC (https://github.com/AmberELEC)

PKG_NAME="RTL8852BU"
PKG_VERSION="5d4eec5"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/morrownr/rtl8852bu-20240418"
PKG_URL="https://github.com/morrownr/rtl8852bu-20240418/archive/5d4eec5.tar.gz"
PKG_SHA256="b11acf6ef6c47cb8994985b574160119a282e7f76ef7490044030506b8d6e004"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Realtek RTL8852BU/RTL8832BU Linux 4.4-5.x driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

post_unpack() {
  # Fix "Argument list too long": dash/sh pwd sempre retorna caminho real,
  # ignorando symlinks. O kernel usa $(src) = M=, que vem do $(shell pwd).
  # Patcheia o Makefile para usar um symlink curto diretamente.
  local SHORT="/tmp/r8852"
  sed -i "s|M=\$(shell pwd)|M=${SHORT}|g"          ${PKG_BUILD}/Makefile
  sed -i "s|M ?= \$(shell pwd)|M := ${SHORT}|g"    ${PKG_BUILD}/Makefile
  sed -i "s|OUT_DIR ?= \$(shell pwd)|OUT_DIR := ${SHORT}|g" ${PKG_BUILD}/Makefile
}

pre_make_target() {
  unset LDFLAGS
  # Cria o symlink curto esperado pelo Makefile patcheado
  ln -sfn ${PKG_BUILD} /tmp/r8852
}

make_target() {
  make V=1 \
       ARCH=${TARGET_KERNEL_ARCH} \
       KSRC=$(kernel_path) \
       CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
       CONFIG_POWER_SAVING=n
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp *.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
}