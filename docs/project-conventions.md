# Convenções e Estrutura do Projeto PipBoy

## Informações Distribuição
- **Nome**: PipBoy
- **Pasta padrão historicamente**: AmberELEC (por razões de fork)
- **DISTRONAME**: "PipBoy" (em `distributions/AmberELEC/options`)
- **Versão formato**: r50s-YYYYMMDD (ex: r50s-20260405)
- **Libreelec Version**: Em `distributions/AmberELEC/version`

## Devices Suportados

| Device | SoC | CPU | GPU | Alvo |
|--------|-----|-----|-----|------|
| RG351P | RK3326 | Cortex-A35 | Mali-G31 MP2 | Principal |
| RG351V | RK3326 | Cortex-A35 | Mali-G31 MP2 | Build alternativo |
| RG351MP | RK3326 | Cortex-A35 | Mali-G31 MP2 | Atual (R50S integrado) |
| RG552 | RK3399 | A72 + A53 | Mali-T860 MP4 | Big.LITTLE |

## Estrutura de Pastas Importante

```
config/                      # Build system
distributions/AmberELEC/     # Distro configs
projects/Rockchip/           # Project + device configs
projects/Rockchip/devices/   # Device-específico (RG351MP, etc)
packages/                    # Todos pacotes
r50s-dtb/                   # REFERÊNCIA APENAS (não é build)
scripts/                     # Build scripts
```

## Pacote Meta Principal
- **File**: `packages/amberelec/package.mk`
- **Propósito**: Define emuladores libretro, ferramentas, dependências
- **Chaves**:
  - `PKG_EMUS` — lista emuladores
  - `PKG_TOOLS` — ferramentas do sistema
  - Lógica exclusão por device (ex: RG552-only cores)

## Drivers Compilados
### Embutidos Globalmente
```
RTL8192CU RTL8192DU RTL8192EU RTL8188EU RTL8812AU RTL8821CU
```

### Adicionais por Device
```
RTL8821AU RTL88x2BU RTL815x RTL8814AU RTL8852BU RTL8188FU
```

## WiFi Toggle OTG (R50S Específico)
- **Script**: `packages/amberelec/config/distribution/modules/wifi_toggle_otg.sh`
- **Controle**: `packages/amberelec/sources/scripts/batocera-internal-wifi`
- **Persistência**: Via `wifi.internal.disabled` no distribution.conf
- **Mecanismo R50S**: rfkill soft block (não GPIO) — `phy0`

## Update/Release System
- **Check Script**: `packages/amberelec/sources/scripts/updatecheck`
- **Upgrade Script**: `packages/amberelec/sources/scripts/amberelec-upgrade`
- **Release Fetcher**: `packages/amberelec/sources/scripts/get-release.py`
- **Default Repo**: ricardoalvarenga101/pipboy
- **Tag Format**: YYYYMMDD ou YYYYMMDD-N (ex: 20260405, 20260405-1)

## Theme System (EmulationStation)
**Importante**: Dois sistemas independentes (não confundir):

1. **ES Built-in Theme Browser** (menu gráfico)
   - Arquivo: `themes.json` (HTTP endpoint)
   - URL config: `global.themes.url`
   - Compilação: ApiSystem::getBatoceraThemesList()

2. **batocera-es-theme Script** (terminal CLI)
   - Arquivo: `themes.cfg` (texto simples)
   - Não afeta menu gráfico

## Volume/Mountpoints Padrão
- **STORAGE** (`/storage`): Preservado em updates
- **SYSTEM** (`/flash`, `/usr`): Regravado em updates
- **Config Home**: `/storage/.config/`

## Segurança/Permissões
- **Jamais buildar como root** — explicitamente rejeitado
- **Sem espaços em paths** — validação e rejeição
- **External HD precisa exec**: `sudo mount -o remount,exec /media/<path>`

## Baud Rate Serial Console
- **Padrão**: 115200
- **Alternativa**: 1500000
- **Arquivo DTS**: fiq-debugger rockchip,baudrate = <115200>

## Senha Padrão Root
- **User**: root  
- **Password**: pipboy
