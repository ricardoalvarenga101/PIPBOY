# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="libxcrypt"
PKG_VERSION="4.4.36"
PKG_SHA256=""
PKG_LICENSE="LGPL"
PKG_SITE="https://github.com/besser82/libxcrypt"
PKG_URL="https://github.com/besser82/libxcrypt/releases/download/v${PKG_VERSION}/libxcrypt-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Extended crypt library - libcrypt replacement for glibc 2.38+"

PKG_CONFIGURE_OPTS_TARGET="--enable-shared \
                            --disable-static"

pre_configure_target() {
  # GCC 13 + -Ofast triggers a false positive stringop-overread in alg-sha1.c
  export CFLAGS="${CFLAGS} -Wno-stringop-overread"
}

makeinstall_target() {
  cd ${PKG_BUILD}/.${TARGET_NAME}
  make install DESTDIR=${INSTALL}

  mkdir -p ${SYSROOT_PREFIX}/usr/lib
  cp -PR ${INSTALL}/usr/lib/libcrypt.so* ${SYSROOT_PREFIX}/usr/lib

  mkdir -p ${SYSROOT_PREFIX}/usr/include
  cp -PR ${INSTALL}/usr/include/crypt.h ${SYSROOT_PREFIX}/usr/include

  rm -f ${INSTALL}/usr/lib/libcrypt.so
}