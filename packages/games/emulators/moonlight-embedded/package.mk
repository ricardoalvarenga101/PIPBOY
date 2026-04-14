# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2024-present Ricardo Alvarenga

PKG_NAME="moonlight-embedded"
PKG_VERSION="5.0.1"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/irtimmer/moonlight-embedded"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libcurl libevdev libopus openssl SDL2 alsa-lib"
PKG_LONGDESC="Moonlight Embedded - NVIDIA GameStream Client for Embedded Systems"
PKG_TOOLCHAIN="cmake-make"
PKG_GIT_CLONE_BRANCH="master"

pre_configure_target() {
  cd ${PKG_BUILD}
  sed -i 's/\-O[23]//' CMakeLists.txt
}

PKG_CMAKE_OPTS_TARGET+="-DCMAKE_BUILD_TYPE=Release \
                        -DCMAKE_SYSTEM_NAME=Linux \
                        -DCMAKE_C_FLAGS_RELEASE='-DNDEBUG' \
                        -DCMAKE_CROSSCOMPILING=ON \
                        -DUSE_SYSTEM_OPUS=ON \
                        -DUSE_SYSTEM_GLM=ON"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/moonlight-embedded
  
  # Copy binary
  cp ${PKG_BUILD}/moonlight ${INSTALL}/usr/bin/moonlight
  chmod +x ${INSTALL}/usr/bin/moonlight
  
  # Copy default configuration files from package dir
  if [ -d ${PKG_DIR}/config ]; then
    cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/moonlight-embedded/
    find ${INSTALL}/usr/config/moonlight-embedded -type f -name "*.sh" -exec chmod +x {} \;
  fi
  
  # Copy launcher script
  cp ${PKG_DIR}/moonlight.sh ${INSTALL}/usr/bin/moonlight.sh
  chmod +x ${INSTALL}/usr/bin/moonlight.sh
  
  # Copy config utility to modules directory for easy access
  mkdir -p ${INSTALL}/usr/config/modules
  cp ${PKG_DIR}/config/moonlight-config.sh ${INSTALL}/usr/config/modules/
  chmod +x ${INSTALL}/usr/config/modules/moonlight-config.sh
}
