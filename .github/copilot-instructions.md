# Copilot Instructions — cHAos (AmberELEC fork)

## Project Overview

This is **cHAos**, a custom fork of [AmberELEC](https://github.com/AmberELEC/AmberELEC), which is an open-source Linux firmware for Rockchip-based handheld gaming devices.  
The build system is derived from LibreELEC/CoreELEC and uses a custom shell-script-driven toolchain.

- **Distro name**: `cHAos` (set in `distributions/AmberELEC/options`)
- **Upstream base**: AmberELEC → EmuELEC → CoreELEC → LibreELEC
- **Workspace root**: `/home/rialvarenga/ae/`

---

## Supported Devices

| Device    | SoC     | Arch    | Kernel branch   |
|-----------|---------|---------|-----------------|
| RG351P    | RK3326  | aarch64 | r50s (tech4bot) |
| RG351V    | RK3326  | aarch64 | r50s (tech4bot) |
| RG351MP   | RK3326  | aarch64 | r50s (tech4bot) |
| RG552     | RK3399  | aarch64 | AmberELEC/kernel_rg552 |

The **RG351MP** device also covers hardware variants that share the same kernel/DTB:
- **PowKiddy Magicx XU10** — DTS: `rk3326-xu10-linux.dtb`, model: `"PowKiddy Magicx XU10"`
- **Anbernic D007** — DTS: `rk3326-d007-linux.dtb`
- **Game Console R50S** — DTS: `rk3326-r50s-linux.dtb`, model: `"Game Console R50S"`, hwrev: `r50s`

---

## Directory Structure

```
ae/
├── config/               # Global build config (functions, path, arch.*, options)
├── distributions/
│   └── AmberELEC/        # Distro-level options (DISTRONAME="cHAos", audio, BT, etc.)
├── packages/             # Generic packages (devel, emulators, etc.)
│   └── devel/
│       ├── ccache/       # ccache:host — generates host-gcc/host-g++ wrapper scripts
│       ├── libcap/       # post_unpack() creates .x86_64-linux-gnu hidden subdir
│       └── ...
├── projects/
│   └── Rockchip/
│       ├── options           # Project-level flags (BOOTLOADER, LINUX, OPENGLES=libmali)
│       ├── bootloader/
│       │   └── install       # U-Boot + rkbin image assembly; boot.ini hwrev detection
│       ├── devices/
│       │   ├── RG351MP/
│       │   │   ├── options   # Device flags: CPU=cortex-a35, DTBs, ADDITIONAL_DRIVERS
│       │   │   ├── linux/    # Kernel kconfig: linux.aarch64.conf
│       │   │   └── packages/
│       │   │       ├── odroidgoa-utils/   # Audio, volume, battery, sleep, LED services
│       │   │       │   └── sources/
│       │   │       │       ├── headphone_sense.sh  ← per-device audio routing
│       │   │       │       ├── odroidgoa_utils.sh
│       │   │       │       ├── volume_sense.sh
│       │   │       │       ├── battery.sh
│       │   │       │       └── adckeys.sh / adckeys.py
│       │   │       └── enable-oga-sleep/
│       │   ├── RG351P/
│       │   ├── RG351V/
│       │   └── RG552/
│       └── packages/
│           ├── linux/        # Kernel package.mk (git clone exfat in pre_make_target)
│           ├── u-boot/
│           ├── rkbin/
│           ├── libmali/
│           └── RTL*/         # Out-of-tree Wi-Fi drivers (RTL8852BU, RTL88x2BU, etc.)
├── scripts/              # Build entry points (build, install, image, build_distro)
├── sources/              # Downloaded source tarballs (cache)
├── target/               # Final output images
├── tools/                # Host tools (mkimage, etc.)
├── Makefile              # Convenience targets: make RG351MP, make world, etc.
└── build.cHAos-RG351MP.aarch64/   # Build output directory (generated)
    ├── toolchain/         # Cross-compilation toolchain (gcc, binutils, glibc)
    ├── .stamps/           # Build state stamps (unpack/build/install per package)
    └── linux-<hash>/      # Kernel source tree
```

---

## Build Commands

```bash
# Build image for a specific device
make RG351MP
# Equivalent to:
DEVICE=RG351MP ARCH=aarch64 ./scripts/build_distro

# Build all devices
make world

# Build a single package
DEVICE=RG351MP ARCH=aarch64 ./scripts/build PACKAGE_NAME

# Clean everything
make clean         # removes build.* dirs
make distclean     # also removes .ccache*
```

Build output lands in `build.cHAos-RG351MP.aarch64/` and the final image in `target/`.

---

## Build System Internals

- Each package lives in `packages/<category>/<name>/` or `projects/<proj>/packages/<name>/`
- Every package has a `package.mk` with lifecycle hooks:
  - `pre_unpack()`, `post_unpack()` — run before/after source extraction
  - `pre_patch()`, `post_patch()` — run before/after patch application
  - `pre_make_target()`, `make_target()`, `post_makeinstall_target()` — target build
  - `pre_make_host()`, `make_host()`, `post_makeinstall_host()` — host build
- Stamps are stored in `build.cHAos-RG351MP.aarch64/.stamps/<package>/`; deleting a stamp forces that phase to re-run.
- The toolchain is assembled in `build.cHAos-RG351MP.aarch64/toolchain/`.
- `config/functions` defines global helpers (`die`, `get_build_dir`, `get_pkg_directory`, etc.).
- `config/path` defines `BUILD`, `STAMPS`, `TOOLCHAIN` variables.

---

## Kernel

- **Source repo**: `https://github.com/tech4bot/kernel_rg351` branch `r50s`
- **Version hash**: `7843036b70b7d6fc891e07158f06b6f7d74fe33d`
- **Kernel version**: 4.4.189
- **kconfig**: `projects/Rockchip/devices/RG351MP/linux/linux.aarch64.conf`
- **package.mk**: `projects/Rockchip/packages/linux/package.mk`

### Known Issue: exFAT git clone in `pre_make_target()`

The linux `package.mk` clones `https://github.com/arter97/exfat-linux.git` (branch `old`) into `${PKG_BUILD}/fs/` during `pre_make_target()`, then renames `exfat-linux` → `exfat`. If a previous build was interrupted and `fs/exfat` or `fs/exfat-linux` already exists, the build fails with:

```
./configure: Makefile: not found
FAILURE: scripts/install linux
```

**Fix:**
```bash
KERNEL_SRC=build.cHAos-RG351MP.aarch64/linux-7843036b70b7d6fc891e07158f06b6f7d74fe33d
rm -rf ${KERNEL_SRC}/fs/exfat ${KERNEL_SRC}/fs/exfat-linux
rm -f build.cHAos-RG351MP.aarch64/.stamps/linux/build_target
rm -f build.cHAos-RG351MP.aarch64/.stamps/linux/install_target
```

---

## Toolchain: Path Sensitivity

The toolchain contains binaries and scripts with **absolute paths baked in at build time**:
- `ccache/post_makeinstall_host()` generates `toolchain/bin/host-gcc` and `host-g++` with a hardcoded `LOCAL_CC` path.
- Python, cmake, and other host tools have RPATH entries pointing to `toolchain/lib`.
- `CMakeCache.txt` caches the source directory path.
- `libtool` scripts embed the full path to the compiler.

**If the project directory is moved**, the entire toolchain must be rebuilt:
```bash
rm -rf build.cHAos-RG351MP.aarch64/toolchain
rm -rf build.cHAos-RG351MP.aarch64/.stamps
```

To find remaining stale path references:
```bash
grep -rl "/old/path/here" build.cHAos-RG351MP.aarch64/ --include="*.sh" --include="*.py" --include="Makefile" --include="*.cmake" --include="*.pc" --include="libtool" --include="config.status"
```

---

## Common Build Failures and Fixes

### `libpython3.11.so.1.0: cannot open shared object file`
RPATH in a host binary points to old toolchain path. Rebuild toolchain (delete `toolchain/` and `.stamps/`).

### `host-gcc: cannot create executables` or `libtool: error: you must specify a MODE`
`host-gcc` wrapper script or `libtool` script contains old hardcoded path. Same fix: rebuild toolchain.

### `cd: .x86_64-linux-gnu: No such file or directory` (e.g. libcap)
`post_unpack()` creates hidden subdirectories that were deleted during cleanup. Fix: re-extract the package:
```bash
rm -rf build.cHAos-RG351MP.aarch64/libcap-2.46
rm -f build.cHAos-RG351MP.aarch64/.stamps/libcap/unpack
```

### `cmake: error while loading shared libraries: libssl.so.1.1`
cmake binary RPATH broken or `CMakeCache.txt` stale from old path:
```bash
rm -rf build.cHAos-RG351MP.aarch64/cmake-*
rm -f build.cHAos-RG351MP.aarch64/.stamps/cmake/*
```

### RTL driver fails: `libpython3.11.so.1.0: cannot open shared object file`
The RTL8852BU (and other RTL) drivers invoke Python scripts at build time using the host Python from the toolchain. If the RPATH in `toolchain/bin/python3` is broken (due to project move), the build fails. Fix: rebuild Python3:host or the full toolchain.

---

## Audio System (RK3326 devices)

- Audio codec: **rk817** (built-in, I²S)
- Audio stack: **ALSA + PulseAudio**
- Audio routing control: `amixer cset name='Playback Path' [HP|SPK|SPK_HP]`
- Headphone detection: GPIO + evtest on the rk817 headset input event

### `headphone_sense.sh`
Location: `projects/Rockchip/devices/RG351MP/packages/odroidgoa-utils/sources/headphone_sense.sh`  
Reads `/sys/firmware/devicetree/base/model` to branch per device:

| Device model string        | HP GPIO | Event device             |
|----------------------------|---------|--------------------------|
| `GameMT E6`                | gpio75  | `/dev/input/event2`      |
| `PowKiddy Magicx XU10`     | gpio86  | `/dev/input/event1`      |
| `Game Console R50S`        | gpio86  | Dynamic (grep `rk817 headset` in sysfs) |

**R50S dynamic event detection:**
```bash
HP_DEV=$(grep -rl "rk817 headset" /sys/class/input/*/device/name 2>/dev/null | head -1)
DEVICE="/dev/input/$(basename $(dirname $(dirname ${HP_DEV})))"
```

When adding support for a new device:
1. Find the model string: `cat /proc/device-tree/model`
2. Find the hp-det GPIO in the DTS: search for `hp-det-gpio` or `hp-det-gpios`
3. Convert GPIO bank/pin to Linux number: `gpio_num = bank * 32 + pin`
4. Find the headset event: `grep -r "rk817 headset" /sys/class/input/*/device/name`
5. Add a new `elif` block in `headphone_sense.sh`

---

## DTB / DTS de Referência (r50s-dtb/)

Os arquivos DTB e DTS do dispositivo **Game Console R50S** usados por esta imagem estão em:

```
r50s-dtb/
├── rk3326-r50s-linux.dtb   ← binário compilado, usado no boot
└── rk3326-r50s-linux.dts   ← fonte legível, referência canônica
```

**Estes arquivos devem ser usados como referência primária** para qualquer dúvida sobre:
- Pinagem de GPIOs (headphone detect, botões, LEDs)
- Configuração de periféricos (codec de áudio rk817, ADC keys, Wi-Fi, etc.)
- Compatibilidade de device drivers com esta imagem
- Nomes de nós e propriedades do devicetree esperados pelos scripts de runtime

Sempre que houver dúvida sobre GPIOs ou mapeamento de hardware para o R50S, consultar o `r50s-dtb/rk3326-r50s-linux.dts` antes de qualquer outra fonte.

---

## Boot Chain (RG351MP / RK3326)

```
U-Boot → reads hwrev env → selects DTB via sysboot → extlinux.conf → kernel
```

- `hwrev` values and their DTBs (set in `projects/Rockchip/bootloader/install`):
  - `xu10` → `rk3326-xu10-linux.dtb`
  - `d007` → `rk3326-d007-linux.dtb`
  - `r50s` → `rk3326-r50s-linux.dtb`
  - (default) → `rk3326-rg351mp-linux.dtb`
- DTB `.conf` files are generated dynamically from DTBs found in `.install_pkg/usr/share/bootloader/`
- Kernel exposes model string via `/sys/firmware/devicetree/base/model`

---

## Out-of-Tree Wi-Fi Drivers

Defined as `ADDITIONAL_DRIVERS` in `projects/Rockchip/devices/RG351MP/options`.  
Each driver lives in `projects/Rockchip/packages/RTL*/package.mk`.  
They are kernel modules built against the target kernel headers.  
Build failures in these packages are often caused by:
1. Broken host Python (RPATH issue) — fix toolchain
2. Missing kernel headers stamp — rebuild `linux:host` first
3. API mismatch in newer kernel versions — check driver patch set

---

## Package Recipe Patterns

```bash
# Force re-unpack of a package
rm -rf build.cHAos-RG351MP.aarch64/<package-version-dir>
rm -f build.cHAos-RG351MP.aarch64/.stamps/<package>/unpack

# Force rebuild (keep sources)
rm -f build.cHAos-RG351MP.aarch64/.stamps/<package>/build_target
rm -f build.cHAos-RG351MP.aarch64/.stamps/<package>/install_target

# Build a single package in isolation
DEVICE=RG351MP ARCH=aarch64 ./scripts/build <package_name>

# Check what a package stamp directory contains
ls build.cHAos-RG351MP.aarch64/.stamps/<package>/
```

---

## Key Variables (config/path)

| Variable       | Value                                              |
|----------------|----------------------------------------------------|
| `BUILD`        | `build.cHAos-RG351MP.aarch64`                     |
| `TOOLCHAIN`    | `$BUILD/toolchain`                                 |
| `STAMPS`       | `$BUILD/.stamps`                                   |
| `TARGET_ARCH`  | `aarch64`                                          |
| `TARGET_NAME`  | `aarch64-libreelec-linux-gnu`                      |
| `DISTRONAME`   | `cHAos`                                            |
| `PROJECT`      | `Rockchip`                                         |
| `DEVICE`       | `RG351MP`                                          |
