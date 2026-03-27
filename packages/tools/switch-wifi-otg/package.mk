PKG_NAME="switch-wifi-otg"
PKG_VERSION="1.0"
PKG_ARCH="any"
PKG_LICENSE="CUSTOM"
PKG_SITE="local"
PKG_URL=""
PKG_SHORTDESC="Alterna entre Wi-Fi interno e USB OTG"
PKG_LONGDESC="Ferramenta para alternar entre Wi-Fi interno e adaptador USB OTG"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
    mkdir -p ${INSTALL}/usr/config/emulationstation/scripts/
    cp ${PKG_DIR}/sources/switch_wifi.sh ${INSTALL}/usr/config/emulationstation/scripts/switch_wifi_otg.sh
    chmod +x ${INSTALL}/usr/config/emulationstation/scripts/switch_wifi_otg.sh
}