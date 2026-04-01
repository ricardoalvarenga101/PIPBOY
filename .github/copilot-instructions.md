# Instruções do Projeto PipBoy

## Visão Geral

O **PipBoy** é um firmware customizado e open source para consoles portáteis baseados no SoC **Rockchip RK3326**. É um fork do [AmberELEC](https://github.com/AmberELEC/AmberELEC), que por sua vez deriva do EmuELEC → CoreELEC → LibreELEC. O sistema é voltado para emulação de jogos retrô em hardware embarcado.

- **Nome da distribuição:** `PipBoy` (definido em `distributions/AmberELEC/options` → `DISTRONAME`)
- **Versão atual:** `r50s-20260331` (definida em `distributions/AmberELEC/version`)
- **Licença:** GPLv2-or-later
- **Senha root:** `pipboy`
- **Frontend:** EmulationStation
- **Backend de emulação:** RetroArch (libretro) + emuladores standalone

---

## Dispositivos Suportados

O projeto compila imagens para os seguintes dispositivos, todos dentro de `projects/Rockchip/devices/`:

| Dispositivo   | SoC        | CPU                         | GPU          | Notas                                             |
|---------------|------------|-----------------------------|--------------|---------------------------------------------------|
| **RG351P**    | RK3326     | Quad-Core ARM Cortex-A35    | Mali-G31 MP2 | Alvo principal de compilação                     |
| **RG351V**    | RK3326     | Quad-Core ARM Cortex-A35    | Mali-G31 MP2 | Sem Bluetooth no build padrão                    |
| **RG351MP**   | RK3326     | Quad-Core ARM Cortex-A35    | Mali-G31 MP2 | Alvo atual de desenvolvimento (`build.PipBoy-*`) |
| **RG552**     | RK3399     | Cortex-A72 + Cortex-A53     | Mali-T860 MP4| CPU diferente; inclui cores libretro extras      |

O dispositivo **RG351MP** também inclui suporte a DTBs de dispositivos compatíveis via `KERNEL_MAKE_EXTRACMD` (ver abaixo).

---

## Sobre a Pasta `r50s-dtb/` — IMPORTANTE

> **A pasta `r50s-dtb/` na raiz do projeto é uma referência de compatibilidade apenas. Ela NÃO faz parte do processo de build nem do release.**

- Contém dois arquivos: `rk3326-r50s-linux.dts` (Device Tree Source) e `rk3326-r50s-linux.dtb` (compilado)
- Representa o hardware **Game Console R50S**, um dispositivo baseado em RK3326 compatível com o firmware
- O DTB do R50S que vai na imagem gerada *não* vem desta pasta — ele é compilado pelo sistema de build do kernel dentro do device `RG351MP`, conforme declarado em `projects/Rockchip/devices/RG351MP/options`:
  ```
  KERNEL_MAKE_EXTRACMD+=" rockchip/rk3326-r50s-linux.dtb"
  ```
- Use esta pasta **somente como referência técnica** para entender o hardware R50S (pinout, periféricos, timings de memória, etc.)
- **Nunca referencie ou inclua esta pasta em targets de build, packaging ou release**

---

## Estrutura do Projeto

```
001-pipboy/
├── .github/                    # GitHub Actions CI/CD e README
│   └── workflows/              # Pipelines de build automatizadas
├── config/                     # Sistema de build: variáveis, funções, arquitetura
│   ├── options                 # Entry point principal: lê distro/project/device options
│   ├── functions               # Funções shell do buildsystem
│   ├── arch.aarch64            # Flags de compilação para aarch64
│   └── arch.arm                # Flags de compilação para arm 32-bit
├── distributions/
│   └── AmberELEC/
│       ├── options             # Configurações globais da distro (DISTRONAME, drivers, serviços)
│       ├── version             # Versão da release (LIBREELEC_VERSION, OS_VERSION)
│       └── splash/             # Splash screens e assets de branding
├── projects/
│   └── Rockchip/
│       ├── options             # Configurações do projeto (bootloader, kernel, opengles)
│       ├── packages/           # Pacotes específicos Rockchip (u-boot, rkbin, libmali, drivers RTL)
│       └── devices/
│           ├── RG351MP/options # CPU, DTBs, UBOOT_SYSTEM, extras para RG351MP
│           ├── RG351P/options  # Configs específicas do RG351P
│           ├── RG351V/options  # Configs específicas do RG351V
│           └── RG552/options   # Configs do RG552 (RK3399, cortex-a72)
├── packages/                   # Todos os pacotes do sistema
│   ├── amberelec/              # Meta-pacote: define emuladores, ferramentas e dependências
│   │   └── package.mk          # Especifica LIBRETRO_CORES, PKG_EMUS, PKG_TOOLS
│   ├── kernel/                 # Pacote do kernel Linux
│   ├── ui/                     # EmulationStation e WebUI
│   ├── games/                  # Ports e jogos
│   └── ...                     # Demais categorias (audio, network, sysutils, etc.)
├── scripts/                    # Scripts do sistema de build
│   ├── build_distro            # Script principal de build (limpeza + compilação)
│   ├── build                   # Compila um pacote específico
│   ├── clean                   # Limpa pacote específico
│   ├── image                   # Gera a imagem final
│   └── ...
├── devtools/
│   └── README.md               # Notas e comandos úteis para desenvolvimento local
├── r50s-dtb/                   # ⚠️ REFERÊNCIA APENAS — NÃO É PARTE DO BUILD/RELEASE
│   ├── rk3326-r50s-linux.dts   # Device Tree Source do Game Console R50S
│   └── rk3326-r50s-linux.dtb   # DTB compilado (referência)
├── build.PipBoy-RG351MP.aarch64/ # Diretório de saída do build (gerado, não commitar)
├── sources/                    # Fontes baixadas (cache local)
├── target/                     # Imagens geradas para deploy
├── release/                    # Artefatos de release
├── Makefile                    # Ponto de entrada: targets por device e docker
└── Dockerfile                  # Imagem de build para uso com Docker/Podman
```

---

## Sistema de Build

### Hierarquia de Configuração

As opções são carregadas em cascata pela seguinte ordem (a última sobrescreve):

1. `config/options` — defaults globais do buildsystem
2. `distributions/AmberELEC/options` — configurações da distro PipBoy
3. `projects/Rockchip/options` — configurações do projeto/plataforma
4. `projects/Rockchip/devices/<DEVICE>/options` — configurações do device específico

### Variáveis de Ambiente Obrigatórias

| Variável | Exemplo     | Descrição                          |
|----------|-------------|------------------------------------|
| `DEVICE` | `RG351MP`   | Device alvo da compilação          |
| `ARCH`   | `aarch64`   | Arquitetura (`aarch64` ou `arm`)   |
| `DISTRO` | `AmberELEC` | Nome da distro (automático)        |

### Comandos de Build

```bash
# Build completo para um device
make RG351MP        # compila aarch64 para RG351MP
make RG351P         # compila aarch64 para RG351P
make RG351V         # compila aarch64 para RG351V
make RG552          # compila aarch64 para RG552

# Build de todos os devices
make world

# Build via Docker (recomendado para ambientes limpos)
make docker-RG351MP
make docker-RG351V
make docker-RG552

# Build de um pacote específico
DEVICE=RG351MP ARCH=aarch64 make package PACKAGE=emulationstation

# Limpeza
make clean          # remove diretórios build.*
make distclean      # remove build.* e .ccache*

# Limpar e recompilar um pacote
DEVICE=RG351MP ARCH=aarch64 ./scripts/clean emulationstation
DEVICE=RG351MP ARCH=aarch64 ./scripts/build emulationstation
```

### Build com Docker

- O Docker é o método recomendado para builds reproduzíveis
- A imagem de build é `ghcr.io/amberelec/amberelec-build` por padrão
- Suporta também `podman` como alternativa ao Docker
- O diretório de trabalho dentro do container é espelhado do `$PWD` local
- O cache (`~/.cache`) é compartilhado entre host e container

```bash
# Construir a imagem Docker localmente
make docker-image-build

# Abrir shell interativo no container de build
make docker-shell

# Build completo para RG351MP via Docker
make docker-RG351MP
```

---

## Arquitetura de Hardware

### RK3326 (RG351P / RG351V / RG351MP / R50S)

- **CPU:** Quad-Core ARM Cortex-A35 @ ~1.5GHz
- **GPU:** Mali-G31 MP2
- **RAM:** 1GB DDR3L / DDR4
- **OpenGLES:** libmali (bifrost)
- **Kernel target:** `Image` (arm64)
- **DTB padrão do RG351MP:** `rk3326-rg351mp-linux.dtb`
- **DTBs adicionais no RG351MP:** `r50s`, `xu10`, `d007`, `timing_fix`

### RK3399 (RG552)

- **CPU:** Dual Cortex-A72 + Quad Cortex-A53 (big.LITTLE)
- **GPU:** Mali-T860 MP4
- **RAM:** 2GB
- **OpenGLES:** libmali (midgard)
- **DTB:** `rk3399-rg552-linux.dtb`
- **Diferencial:** suporte a cores libretro extras (bsnes, mesen, melonds, etc.) e WebUI

---

## Pacotes e Emuladores

### Meta-Pacote `amberelec`

O arquivo `packages/amberelec/package.mk` é o orquestrador principal. Ele define:

- `PKG_EMUS` — lista completa de emuladores libretro e standalone
- `PKG_TOOLS` — ferramentas do sistema (retroarch, ffmpeg, mpv, etc.)
- Lógica de exclusão de cores para devices sem suporte (ex: RG552 exclusivo)

### Cores Libretro Notáveis

- **Arcade:** fbneo, fbalpha2012/2019, mame/mame2000/2003/2010/2015/2016
- **Nintendo:** nestopia, snes9x, mgba, mupen64plus-nx, melonds (RG552 only)
- **Sega:** genesis-plus-gx, picodrive, flycast, beetle-saturn
- **Sony:** pcsx_rearmed, ppsspp, duckstation, swanstation
- **Atari:** stella, atari800, a5200, beetle-lynx
- **Misc:** scummvm, dosbox-pure, openbor, solarus

### Emuladores Standalone

`ppssppsa`, `amiberry`, `hatarisa`, `drastic`, `mupen64plussa`, `duckstation`, `gzdoom`, `lzdoom`, `raze`

---

## Drivers Wi-Fi (RTL)

Drivers Realtek embutidos na distro (definidos em `distributions/AmberELEC/options`):

```
RTL8192CU RTL8192DU RTL8192EU RTL8188EU RTL8812AU RTL8821CU
```

Drivers adicionais por device em `projects/Rockchip/devices/*/options`:

```
RTL8812AU RTL8821CU RTL8821AU RTL88x2BU RTL815x RTL8814AU RTL8852BU RTL8188FU
```

---

## Versionamento e Release

- O campo `LIBREELEC_VERSION` em `distributions/AmberELEC/version` define a versão da release
- O formato atual usado é `r50s-YYYYMMDD` (ex: `r50s-20260331`)
- Para builds de desenvolvimento, o CI usa o formato `dev-YYYYMMDD_HHMM-<sha>`
- A imagem gerada vai para o diretório `target/`

### CI/CD (GitHub Actions)

- `.github/workflows/build-main.yaml` — build automático em push para `main`/`dev`
- `.github/workflows/release-*.yaml` — pipelines de release (beta, draft, prerelease, dev)
- Builds sequenciais: RG351P → RG351V → RG351MP → RG552 (cada um depende do anterior)

---

## Sistema de Temas do EmulationStation

### Dois sistemas independentes — NÃO confundir

| Sistema | Formato | Quem chama | Finalidade |
|---|---|---|---|
| **ES built-in theme browser** (menu do ES) | `themes.json` (JSON) | EmulationStation (C++) | **Instalar/remover temas pelo menu gráfico** |
| `batocera-es-theme` (script shell) | `themes.cfg` (texto simples) | linha de comando / módulos | Instalação via terminal |

O menu "Themes Downloader" do EmulationStation **ignora completamente** o script `batocera-es-theme` e o `themes.cfg`. Ele usa a função `ApiSystem::getBatoceraThemesList()` que faz HTTP direto para a URL em `global.themes.url`.

### URL do themes.json

Configurada em `ApiSystem::getThemesUrl()` (`es-app/src/ApiSystem.cpp`):

```cpp
std::string ApiSystem::getThemesUrl() {
    auto systemsetting = SystemConf::getInstance()->get("global.themes.url");
    if (!systemsetting.empty())
        return systemsetting;
    // padrão hardcoded: AmberELEC/metadata
    return getUpdateUrl() + "/themes.json";
}
```

**Para sobrescrever sem recompilar o ES**, adicionar nos `distribution.conf.*`:
```ini
global.themes.url=https://raw.githubusercontent.com/ricardoalvarenga101/pipboy-themes/refs/heads/master/themes.json
```

Esse arquivo se encontra em:
- `packages/amberelec/config/distribution/configs/distribution.conf.351v` → RG351V e RG351MP
- `packages/amberelec/config/distribution/configs/distribution.conf.351p` → RG351P
- `packages/amberelec/config/distribution/configs/distribution.conf.552` → RG552

### Formato do `themes.json`

```json
{
  "data": [
    {
      "theme": "Nome-do-Tema",
      "author": "autor",
      "theme_url": "https://github.com/usuario/repositorio",
      "last_update": "2024-01-01",
      "up_to_date": 1,
      "size": 10,
      "screenshot": "themes/Nome-do-Tema.jpg"
    }
  ]
}
```

- `screenshot` é **opcional** — se omitido, nenhum preview é exibido
- O caminho do `screenshot` é **relativo à URL do `themes.json`**
- `size` é o tamanho em MB (usado para exibição e barra de progresso)

### Estrutura do repositório de temas (`pipboy-themes`)

```
pipboy-themes/
├── themes.json          ← lista de temas (consumido pelo ES)
├── themes.cfg           ← lista de temas (consumido pelo batocera-es-theme script)
└── themes/
    ├── Nome-do-Tema.jpg ← screenshots opcionais
    └── ...
```

### Como o ES instala um tema

Ao instalar pelo menu, o ES:
1. Lê `themes.json` via HTTP
2. Busca o branch padrão do repositório via `api.github.com/repos/<user>/<repo>`
3. Baixa `<theme_url>/archive/<branch>.zip`
4. Extrai em `/storage/.config/emulationstation/themes/`

### Por que alterações no `themes.cfg` / `batocera-es-theme` não afetam o menu do ES

O menu gráfico de temas **não usa** o script `batocera-es-theme`. Para alterar a lista do menu, é necessário:
1. Atualizar o `themes.json` no repositório remoto, **ou**
2. Definir `global.themes.url` nos `distribution.conf.*` apontando para o JSON correto

### Sincronização do `distribution.conf` em runtime

O `autostart.sh` sincroniza `/usr/config/distribution/` → `/storage/.config/distribution/` com `--exclude=configs`, portanto:
- Alterações nos `distribution.conf.*` **entram na imagem** via rebuild (`make RG351MP`)
- O diretório `configs/` no SD **não é sobrescrito** em boots subsequentes (proteção para configurações do usuário)
- Um `themes.txt` colocado manualmente em `/storage/.config/distribution/configs/` sobrescreve o `batocera-es-theme` script, mas **não afeta** o menu do ES

---

## Convenções e Boas Práticas

1. **Nunca buildar como root** — o buildsystem rejeita explicitamente (`EUID -eq 0`)
2. **Sem espaços no caminho** — o buildsystem valida e rejeita paths com espaços
3. **Limpeza antes de release** — o script `build_distro` limpa pacotes críticos antes de compilar (amberelec, emulationstation, retroarch, kernel, u-boot, etc.)
4. **Pacotes device-específicos** ficam em `projects/Rockchip/devices/<DEVICE>/packages/`
5. **Pacotes do projeto** ficam em `projects/Rockchip/packages/`
6. **Pacotes globais** ficam em `packages/`
7. **Modificar DTBs** — o local correto é `projects/Rockchip/devices/<DEVICE>/linux/`, não a pasta `r50s-dtb/`
8. **Variável BUILD_FILENAME** — o diretório `build.PipBoy-RG351MP.aarch64/` contém um arquivo `BUILD_FILENAME` que identifica o artefato da build atual

---

## Módulo WiFi OTG Toggle

O R50S tem WiFi interno embarcado (chip 2.4GHz via SDIO) que conflita com adaptadores USB externos conectados via porta OTG. O módulo `wifi_toggle_otg.sh` permite chavear entre os dois, com persistência entre reinicializações.

### Arquivos envolvidos

| Arquivo | Função |
|---|---|
| `packages/amberelec/config/distribution/modules/wifi_toggle_otg.sh` | Módulo de UI — exibido em **Tools** no EmulationStation |
| `packages/amberelec/sources/scripts/batocera-internal-wifi` | Script que efetua o enable/disable do chip interno |
| `packages/amberelec/sources/autostart.sh` | Lê `wifi.internal.disabled` no boot e chama o script acima |
| `packages/amberelec/config/distribution/modules/gamelist.xml` | Registro do módulo na lista de Tools do ES |

### Mecanismo de controle por device

O `batocera-internal-wifi` detecta o hardware em runtime via `/sys/firmware/devicetree/base/model`:

| Device | Mecanismo | GPIO / Recurso |
|---|---|---|
| Anbernic RG552 | GPIO hard power | `gpio113` |
| Anbernic RG351P | GPIO hard power | `gpio110` |
| Anbernic RG351V | GPIO hard power | `gpio5` |
| **Game Console R50S** | **rfkill (soft block)** | `phy0` |
| **Anbernic RG351MP** | **rfkill (soft block)** | `phy0` |
| outros | **rfkill (soft block)** | `phy0` |

O R50S e o RG351MP **não têm GPIO de controle de WiFi mapeado** no userspace. O `rfkill` bloqueia o driver no nível do kernel (`phy0` = WiFi interno SDIO), mantendo o adaptador OTG USB (`wlan1`+) ativo.

### Persistência da configuração

A preferência é salva via `set_ee_setting wifi.internal.disabled <0|1>` em `/storage/.config/distribution/configs/distribution.conf`. No boot, `autostart.sh` relê esse valor:

```bash
# autostart.sh — linhas ~209-211
if [ "$(get_ee_setting wifi.internal.disabled)" == "1" ]
then
  /usr/bin/batocera-internal-wifi disable-no-refresh
fi
```

`disable-no-refresh` bloqueia o chip sem tentar reiniciar o connman, pois no boot o WiFi ainda não foi iniciado.

### Fluxo do módulo (wifi_toggle_otg.sh)

```
Usuário abre Tools → WiFi Toggle (OTG)
        │
        ├─ wifi.internal.disabled == 1 (OTG ativo)
        │       └─ Pergunta: voltar ao interno?
        │               └─ YES → set_ee_setting 0 + batocera-internal-wifi enable
        │
        └─ wifi.internal.disabled != 1 (interno ativo, padrão)
                ├─ Sem wlan1+ detectado → erro "adaptador não encontrado"
                └─ Com wlan1+ detectado → pergunta: usar OTG?
                        └─ YES → set_ee_setting 1 + batocera-internal-wifi disable
```

### Adaptadores OTG testados / drivers disponíveis

Os drivers RTL já embutidos na distro que suportam adaptadores 5GHz:

```
RTL8812AU   — AC1200 dual-band (recomendado para 5GHz)
RTL8821CU   — AC600 dual-band
RTL8821AU   — AC600 dual-band
RTL88x2BU   — AC1300 dual-band
RTL8814AU   — AC1900 tri-band
RTL8852BU   — AX1800 Wi-Fi 6
```

### Como compilar/testar alterações

```bash
# Rebuild rápido (só o pacote amberelec):
DEVICE=RG351MP ARCH=aarch64 ./scripts/clean amberelec
DEVICE=RG351MP ARCH=aarch64 ./scripts/build amberelec

# Teste sem rebuild (cópia direta via SSH, senha: pipboy):
scp packages/amberelec/config/distribution/modules/wifi_toggle_otg.sh \
    root@<IP>:/usr/config/modules/
scp packages/amberelec/sources/scripts/batocera-internal-wifi \
    root@<IP>:/usr/bin/
scp packages/amberelec/config/distribution/modules/gamelist.xml \
    root@<IP>:/usr/config/modules/
```

Após copiar, reinicie o EmulationStation no dispositivo para que o `gamelist.xml` seja relido.

### Observações para o Modelo de IA

- O adaptador OTG USB aparece como `wlan1` (ou `wlan2`+); o interno é sempre `wlan0`
- Nunca assumir que `batocera-internal-wifi` funciona via GPIO no R50S — usar rfkill
- A variável `wifi.internal.disabled` já existia no `autostart.sh` antes desta feature; o que foi corrigido foi o suporte ao R50S/RG351MP no script `batocera-internal-wifi` (que antes terminava com `exit 1` para esses devices)
- O `rfkill` é soft block — não corta alimentação do chip, apenas desabilita o driver

---

## Observações para o Modelo de IA

- Ao sugerir alterações de configuração de build, sempre verificar a hierarquia completa (distro → project → device)
- O `DISTRONAME` é `PipBoy`, mas a pasta de distribuição se chama `AmberELEC` por razões históricas de fork
- Ao tratar de DTBs: o R50S é suportado via device `RG351MP`; **não há um device próprio R50S no projeto**
- A pasta `r50s-dtb/` na raiz é apenas uma referência de trabalho off-tree; nunca deve ser tratada como parte do sistema de build
- O arquivo `devtools/README.md` contém comandos e dicas de desenvolvimento local úteis
- Ao remover o cache de um pacote do build: `rm build.PipBoy-RG351MP.aarch64/.stamps/<pacote>/build_target`
- Para montar o drive externo com permissão de execução (desenvolvimento em HD externo): `sudo mount -o remount,exec /media/rialvarenga/DISPOSITIVO`
