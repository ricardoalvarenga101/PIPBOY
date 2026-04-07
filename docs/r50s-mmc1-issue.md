# Problema: Segundo SD Card Não Detectado (mmcblk1)

## ✅ RESOLVIDO

**Causa raiz:** `&uart1` habilitado no DTS conflitava com `&sdio` (segundo slot SD) pelos mesmos pinos físicos GPIO1.C[0-3].

**Fix aplicado:**
- Patch: `projects/Rockchip/packages/linux/patches/RG351MP/001-r50s-disable-uart1-fix-sdio-sd2.patch`
- Adicionado `PKG_PATCH_DIRS="RG351MP"` em `projects/Rockchip/packages/linux/package.mk`
- DTS modificado diretamente em `build.PipBoy-RG351MP.aarch64/.../rk3326-r50s-linux.dts`

---

## Descrição do Problema
- Device físico: R50S tem dois slots microSD
- Slot primário (mmcblk0): ✅ Funcionando corretamente
- Slot secundário (mmcblk1): ❌ Não aparecia em `/dev/mmc*`
- Kernel boot: Carregava DTB correto (rk3326-r50s-linux.dtb)

## Causa Raiz Identificada

O DTS `rk3326-r50s-linux.dts` (kernel source) tinha **dois nós conflitando nos mesmos pinos físicos**:

| Nó | Pinos | Função |
|---|---|---|
| `&sdio` (`dwmmc@ff380000`) | GPIO1.C0-C5 | Segundo slot SD card (mmcblk1) |
| `&uart1` | GPIO1.C0 (RXD), C1 (TXD), C2 (CTS), C3 (RTS) | EXT Header P2 (inexistente no R50S) |

Como o `&uart1` probeava primeiro e alocava GPIO1.C0-C3 via `uart1_xfer` e `uart1_cts`, o driver `dwmmc@ff380000` não conseguia requisitar os mesmos pinos, falhando silenciosamente durante o boot.

O comentário no DTS confirmava que esses pinos pertencem ao **"EXT Header (P2)"**, um header externo que não existe no hardware do console R50S.

## Arquivos Modificados

1. **`projects/Rockchip/packages/linux/package.mk`** — Adicionado suporte a patches para `RG351MP`:
   ```bash
   if [[ "${DEVICE}" == RG351MP ]]; then
     PKG_PATCH_DIRS="${DEVICE}"
   fi
   ```

2. **`projects/Rockchip/packages/linux/patches/RG351MP/001-r50s-disable-uart1-fix-sdio-sd2.patch`** — Novo patch que desabilita `&uart1`:
   ```diff
   -	status = "okay";
   +	status = "disabled";
   ```

## Verificação Pós-Fix

Após rebuild e boot no device, verificar:
```bash
ls /dev/mmcblk*          # Deve mostrar mmcblk0 e mmcblk1
dmesg | grep -i mmc      # ff380000: sdio: probeado com sucesso
dmesg | grep -i uart1    # Deve mostrar uart1 disabled ou ausente
```
