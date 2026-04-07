# PipBoy Build System - Overview

## Hierarquia de Configuração
1. `config/options` — defaults globais do buildsystem
2. `distributions/AmberELEC/options` — configurações da distro PipBoy
3. `projects/Rockchip/options` — configurações do projeto/plataforma
4. `projects/Rockchip/devices/<DEVICE>/options` — específicas do device

## Variáveis de Ambiente Obrigatórias
- `DEVICE=RG351MP` (para R50S)
- `ARCH=aarch64`
- `DISTRO=AmberELEC` (automático)

## Arquivo de Configuração Relevante
**Localização**: `projects/Rockchip/devices/RG351MP/options`

Inclui:
- CPU e GPU específicas
- DTBs compilados: `KERNEL_MAKE_EXTRACMD+=" rockchip/rk3326-r50s-linux.dtb"`
- U-Boot system selection

## Bootloader Logic
**Arquivo**: `projects/Rockchip/bootloader/install`

Seleciona DTB em runtime:
```bash
if test ${hwrev} = 'r50s'; then
    sysboot mmc 1:1 any ${scriptaddr} /extlinux/rk3326-r50s-linux.dtb.conf
else
    sysboot mmc 1:1 any ${scriptaddr} /extlinux/rk3326-rg351mp-linux.dtb.conf
fi
```

## Kernel Package Info
**Arquivo**: `projects/Rockchip/packages/linux/package.mk`

- Git Source: `https://github.com/ricardoalvarenga101/kernel_rg351`
- Branch: `r50s`
- Version: `9028022692284a7ec2ca1f80f9a7471ab1190903`
- DTB Targets: rk3326-rk351mp-linux.dtb, rk3326-r50s-linux.dtb, outros

## Comandos de Build Úteis

### Build Completo
```bash
make RG351MP              # Build aarch64 para R50S
```

### Build Docker (Recomendado)
```bash
make docker-RG351MP       # Build em container
make docker-shell         # Shell interativo no container
```

### Build Single Package
```bash
DEVICE=RG351MP ARCH=aarch64 ./scripts/build kernel
```

### Limpeza
```bash
make clean                # Remove build directories
make distclean             # Remove build + cache
```

### Clean + Rebuild específico
```bash
DEVICE=RG351MP ARCH=aarch64 ./scripts/clean kernel
rm build.PipBoy-RG351MP.aarch64/.stamps/kernel/build_target  # reset stage
make RG351MP              # Rebuild
```

## Diretórios de Output
- Build output: `build.PipBoy-RG351MP.aarch64/`
- Imagens finais: `target/`
- Artefatos de release: `release/`
- Cache local: `sources/`

## Convenções Importante
1. **Nunca buildar como root** — buildsystem rejeita explicitamente
2. **Sem espaços no caminho** — buildsystem valida e rejeita
3. **Limpeza antes de release** — script `build_distro` limpa pacotes críticos
4. **BUILD_FILENAME** — arquivo em `build.PipBoy-RG351MP.aarch64/BUILD_FILENAME` identifica artefato
