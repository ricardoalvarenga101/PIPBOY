## Permissão execução external drive
sudo mount -o remount,exec /media/rialvarenga/DISPOSITIVO

## Comando para instalar uma distribuição
DEVICE=RG351MP ARCH=aarch64 ./scripts/build_distro emulationstation

## remover built target cache
rm build.PipBoy-RG351MP.aarch64/.stamps/amberelec/build_target