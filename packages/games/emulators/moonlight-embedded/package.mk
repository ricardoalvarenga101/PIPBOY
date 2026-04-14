# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2024-present Ricardo Alvarenga

PKG_NAME="moonlight-embedded"
PKG_VERSION="775444287305849ebdf4736c75298ad0713e2d5d"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/moonlight-stream/moonlight-embedded"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain curl libevdev opus openssl SDL2 alsa-lib"
PKG_LONGDESC="Moonlight Embedded v2.7.1 - NVIDIA GameStream Client for Embedded Systems"
PKG_TOOLCHAIN="cmake-make"
PKG_GIT_CLONE_BRANCH="master"

pre_configure_target() {
  cd ${PKG_BUILD}
  sed -i 's/\-O[23]//' CMakeLists.txt

  # Fix for older kernels where struct input_event uses time.tv_sec/tv_usec
  # instead of input_event_sec/input_event_usec macros (added in kernel 4.16+)
  sed -i 's/ev->input_event_sec/ev->time.tv_sec/g; s/ev->input_event_usec/ev->time.tv_usec/g' \
    src/input/evdev.c
}

PKG_CMAKE_OPTS_TARGET+="-DCMAKE_BUILD_TYPE=Release \
                        -DCMAKE_SYSTEM_NAME=Linux \
                        -DCMAKE_C_FLAGS_RELEASE='-DNDEBUG' \
                        -DCMAKE_CROSSCOMPILING=ON \
                        -DUSE_SYSTEM_OPUS=ON \
                        -DUSE_SYSTEM_GLM=ON"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/lib
  mkdir -p ${INSTALL}/usr/config/moonlight-embedded
  
  # Copy binary
  cp ${PKG_BUILD}/moonlight ${INSTALL}/usr/bin/moonlight
  chmod +x ${INSTALL}/usr/bin/moonlight
  
  # Copy shared libraries
  cp ${PKG_BUILD}/libgamestream/libgamestream.so.2.7.1 ${INSTALL}/usr/lib/
  ln -sf libgamestream.so.2.7.1 ${INSTALL}/usr/lib/libgamestream.so.4
  ln -sf libgamestream.so.4 ${INSTALL}/usr/lib/libgamestream.so
  cp ${PKG_BUILD}/libgamestream/libmoonlight-common.so.2.7.1 ${INSTALL}/usr/lib/
  ln -sf libmoonlight-common.so.2.7.1 ${INSTALL}/usr/lib/libmoonlight-common.so.4
  ln -sf libmoonlight-common.so.4 ${INSTALL}/usr/lib/libmoonlight-common.so
  
  # Copy default config example
  cp ${PKG_DIR}/config/moonlight.conf.example ${INSTALL}/usr/config/moonlight-embedded/
  
  # Copy launcher script
  cp ${PKG_DIR}/moonlight.sh ${INSTALL}/usr/bin/moonlight.sh
  chmod +x ${INSTALL}/usr/bin/moonlight.sh
  
}
