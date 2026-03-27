PKG_NAME="switch-sd"
PKG_VERSION="1.0"
PKG_ARCH="any"
PKG_LICENSE="CUSTOM"
PKG_SITE="local"
PKG_URL=""
PKG_SHORTDESC="Switch de apontamento para outro cartão SD"
PKG_LONGDESC="Ferramenta para redirecionar roms, bios, saves e configs para o segundo cartão SD"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
    mkdir -p ${INSTALL}/usr/config/emulationstation/scripts/
    cp ${PKG_DIR}/sources/switch_sd.sh ${INSTALL}/usr/config/emulationstation/scripts/switch_sd.sh
    chmod +x ${INSTALL}/usr/config/emulationstation/scripts/switch_sd.sh
}