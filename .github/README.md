# PIPBOY Game Console R50S / RG351MP

![Splash Screen](https://github.com/ricardoalvarenga101/PIPBOY/blob/r50s-configuration/distributions/AmberELEC/splash/splash-854l.png?raw=true)

---

Firmware customizado e open source para os consoles portáteis **Game Console R50S** baseados no SoC **Rockchip RK3326**.

Este projeto é compatível com:
- **Game Console R50S**
- **Anbernic RG351MP**
- Outros dispositivos baseados em RK3326 (com adaptações)

## Especificações Técnicas
- **SoC:** Rockchip RK3326
- **CPU:** Quad-Core ARM Cortex-A35
- **GPU:** Mali-G31 MP2
- **RAM:** 1GB DDR3L
- **Tela:** IPS 3.5" 480x320 (R50S) / 640x480 (RG351MP)
- **Armazenamento:** microSD
- **Áudio:** Codec RK817, alto-falante estéreo, saída P2
- **Conectividade:** Wi-Fi (opcional), USB-C, OTG
- **Sistema:** Linux customizado (AmberELEC/PIPBOY)

## Compatibilidade de Firmware
- **Firmware:** AmberELEC, PIPBOY, custom builds
- **Kernel:** Linux 5.x customizado para RK3326
- **Device Tree:** rk3326-r50s-linux.dts, rk3326-rg351mp-linux.dts
- **Bootloader:** U-Boot customizado

## Como Clonar o Projeto
```bash
git clone https://github.com/seuusuario/001-pipboy.git
cd 001-pipboy
```

## Como Compilar
```bash
make RG351MP
```
Ou para outros dispositivos, ajuste o alvo conforme necessário.

## Como Subir para o Cartão SD
1. Compile a imagem conforme instruções acima.
2. Grave a imagem no cartão microSD usando o balenaEtcher, dd ou ferramenta similar.
3. Insira o cartão no console e ligue o dispositivo.

## Créditos
- Projeto baseado em AmberELEC, EmuELEC, CoreELEC, Lakka e Batocera.
- Splash screen e customizações por rsalvarenga.

---

> Para dúvidas, consulte a [wiki oficial](https://amberelec.org) ou entre no [Discord](https://discord.gg/W9F9xxRseu).
    <td>RG351MP<sup>[2]</sup></td>
  </tr>
  <tr>
    <td rowspan="2">PowKiddy</td>
    <td>RGB20S<sup>[3]</sup></td>
  </tr>
  <tr>
    <td>Magicx XU10<sup>[3]</sup></td>
  </tr>
  <tr>
    <td rowspan="2">Game Console<br />Game Station</td>
    <td>R35S<sup>[3]</sup></td>
  </tr>
  <tr>
    <td>R36S<sup>[3]</sup></td>
  </tr>
  <tr>
    <td>SZDiiER</td>
    <td>D007 Plus<sup>[3]</sup></td>
  </tr>
</table>
<!--devices-->

> [!IMPORTANT]
> <sup>[1]</sup> use the RG351P image<br>
> <sup>[2]</sup> for RG351V and RG351MP devices with v2 display the use of the [pre-release image](https://github.com/AmberELEC/AmberELEC-prerelease/releases) is mandatory<br>
> <sup>[3]</sup> use the RG351MP [pre-release image](https://github.com/AmberELEC/AmberELEC-prerelease/releases)

> [!CAUTION]
> Do not replace or rename any of the `.dtb` files after flashing a new image or updating from an older AmberELEC release.
> To simplify the process and reduce complexity, we're determining which display the device is using, so no manual interaction is necessary.
  
## Installation

Please visit our Website [Installation](https://amberelec.org/installation#overview) page for installation instructions.

## Building from Source
Building AmberELEC from source is a fairly simple process. It is recommended to have a minimum of 4 cores, 16GB of RAM, and an SSD with 200GB of free space. The build environment used to develop these steps uses Ubuntu 20.04, your mileage may vary when building on other distributions.

> [!IMPORTANT]
> On Ubuntu 20.04 it's required to add the following apt-repository as golang 1.17 or higher is required for building AmberELEC:<br>
> ```sudo add-apt-repository ppa:longsleep/golang-backports```

```
sudo apt update && sudo apt upgrade

sudo apt install gcc make git unzip wget xz-utils libsdl2-dev libsdl2-mixer-dev libfreeimage-dev libfreetype6-dev libcurl4-openssl-dev rapidjson-dev libasound2-dev libgl1-mesa-dev build-essential libboost-all-dev cmake fonts-droid-fallback libvlc-dev libvlccore-dev vlc-bin texinfo premake4 golang libssl-dev curl patchelf xmlstarlet patchutils gawk gperf xfonts-utils default-jre python xsltproc libjson-perl lzop libncurses5-dev device-tree-compiler u-boot-tools rsync p7zip unrar libparse-yapp-perl zip binutils-aarch64-linux-gnu dos2unix p7zip-full libvpx-dev meson rdfind

git clone https://github.com/AmberELEC/AmberELEC.git AmberELEC

cd AmberELEC

make clean

make world
```

The make world process will build and generate a image which will be located in AmberELEC/release. Follow the installation steps to write your image to a microSD.
It will build for the RG351P/M, RG351V, RG351MP and for the RG552.

To create the image for the RG351P/M just ``make RG351P``, and just for the RG351V ``make RG351V``, and just for the RG351MP ``make RG351MP``, and just for the RG552 ``make RG552``.

## Building from Source - Docker
Building with Docker simplifies the build process as any dependencies, with the exception of `make`, are contained within the docker image - all CPU/RAM/Disk/build time requirements remain similar. 

NOTE: Make can be installed with `sudo apt update && sudo apt install -y make` on Ubuntu-based systems.

All make commands are available via docker, by prepending `docker-`. `make RG351V` becomes `make docker-RG351V` and `make clean` becomes `make docker-clean`.

New docker make commands: 
- `make docker-image-build` - Builds the docker image based on the Dockerfile. This is not required unless changes are needed locally. 
- `make docker-image-pull` - Pulls docker image from dockerhub. This will update to the latest image and replace any locally built changes to the docker file.
- `make docker-shell` - (advanced) Launches a shell inside the docker build container. This allows running any development commands like `./scripts/build`, etc, which aren't in the Makefile.
  - NOTE: Errors like `groups: cannot find name for group ID 1002` and the user being listed as `I have no name!` are OK and a result of mapping the host user/group into the docker container where the host user/groups may not exist.

Example building with docker:
```
git clone https://github.com/AmberELEC/AmberELEC.git AmberELEC
cd AmberELEC
make docker-clean
make docker-world
```

## Automated Dev Builds
Builds are automatically run on commits to `main` and for Pull Requests (*PR's*) from previous committers.

Development builds can be found looking for the green checkmarks next to commit history. Artifacts are generated for each build which can be used to update the RG351P/RG351V and are stored for 30 days by GitHub. Note that due to Github Action limitations, artifacts are zipped (.img.gz and .tar are inside the zip file).

All artifacts generated by builds should be considered 'unstable' and only used by developers or advanced users who want to test the latest code.

See: [Build Overview](workflows/README.md) for more information.

### GitHub Actions and Forks
Builds use GitHub actions (`.github/workflow`) to execute. GitHub validates that changes to the `.github/workflow` folder require a special `workflow` permission. 

When using [Personal Access Token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) to push in upstream changes from AmberELEC into your fork, you may get an error similar to the following:

```
! [remote rejected] main -> main (refusing to allow a Personal Access Token to create or update workflow `.github/workflows/README.md` without `workflow` scope)
error: failed to push some refs to 'https://github.com/my-AmberELEC-fork/AmberELEC.git'
```

To fix, edit the [Personal Access Token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) to add `workflow` permissions (or create a new token with workflow permission).

Alternatively, [ssh-key authentication](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) can be used.
