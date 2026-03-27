DEVICE=RG351MP ARCH=aarch64 ./scripts/build emuscv > emuscv_build.log 2>&1

git ls-remote --heads https://github.com/LIJI32/SameBoy.git


exemplo de limpar e recompilar um nucleo
rm -rf build.cHAos-RG351MP.aarch64/mame2016-*
rm -f build.cHAos-RG351MP.aarch64/.stamps/mame2016/*
DEVICE=RG351MP ARCH=aarch64 ./scripts/build mame2016



## migrar projeto pra hd externo
A melhor estratégia é usar um symlink. Assim você mantém o path original e não perde nenhuma referência do toolchain.

Estratégia com symlink
Copie o projeto para o HD externo:


cp -a /home/rialvarenga/ae/ /media/rialvarenga/externo/ae/
(ou use rsync -a para mais controle)

Remova o diretório original:


rm -rf /home/rialvarenga/ae
Crie um symlink no lugar original:


ln -s /media/rialvarenga/externo/ae /home/rialvarenga/ae
Pronto. Para o sistema de build, o projeto continua em ae, então nenhuma referência quebra.


## Configurar montagem fixa do HD externo no /etc/fstab
1. Descubra o UUID do HD externo
Com o HD externo conectado, rode:


lsblk -o NAME,UUID,FSTYPE,MOUNTPOINT
ou


sudo blkid
Anote o UUID do dispositivo (ex: UUID="a1b2c3d4-e5f6-...").

2. Crie o ponto de montagem

sudo mkdir -p /media/rialvarenga/externo
3. Edite o /etc/fstab

sudo nano /etc/fstab
Adicione uma linha no final do arquivo (substituindo pelo seu UUID e FSTYPE reais):


UUID=a1b2c3d4-e5f6-...  /media/rialvarenga/externo  ext4  defaults,nofail  0  2
Explicação dos campos:

UUID=... — identifica o disco pelo UUID (não pelo nome /dev/sdX, que pode mudar)
/media/rialvarenga/externo — ponto de montagem fixo
ext4 — tipo do filesystem (pode ser ntfs-3g, exfat, etc.)
nofail — importante: se o HD não estiver conectado, o sistema inicia normalmente sem travar
0 2 — sem dump, verificação fsck no boot
4. Teste sem reiniciar

sudo mount -a
Se não retornar erro, está correto. Verifique com:


df -h | grep externo
Dica: Se o HD for NTFS, substitua ext4 por ntfs-3g e instale o pacote: sudo apt install ntfs-3g. Se for exFAT, use exfat-fuse e exfat como tipo.

make PIPBOY 2>&1 | tee build_pipboy.log



GameMT E6