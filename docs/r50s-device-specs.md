# Game Console R50S - Especificações Técnicas

## Hardware
- **SoC**: Rockchip RK3326
- **CPU**: Quad-Core ARM Cortex-A35 @ ~1.5GHz
- **GPU**: Mali-G31 MP2
- **RAM**: 1GB DDR3L/DDR4
- **Armazenamento**: Dual microSD card slots
- **OpenGLES**: libmali (bifrost)
- **Conectividade**: WiFi interno 2.4GHz (chip SDIO) + Bluetooth
- **Display**: 3.5" IPS LCD (480x854)
- **Áudio**: RK817 PMIC integrado

## SD Card Slots (Controladores MMC)

| Slot | Controlador | Endereço | DTB Status | GPIO CD | Detecção |
|------|-------------|----------|-----------|---------|----------|
| Primário | dwmmc@ff370000 | 0xff370000 | okay | GPIO0_PA3 | ✅ mmcblk0 |
| Secundário | dwmmc@ff380000 | 0xff380000 | okay | GPIO3_PB6 | ❌ mmcblk1 (não detectado) |
| eMMC | dwmmc@ff390000 | 0xff390000 | disabled | - | ✅ desabilitado |

## Compatibilidade de Build
- **Device Build**: RG351MP (R50S integrado)
- **Bootloader**: U-Boot condicional via `hwrev='r50s'`
- **DTB**: rk3326-r50s-linux.dtb (carregado automaticamente)
- **Kernel**: https://github.com/ricardoalvarenga101/kernel_rg351 branch `r50s`
- **Kernel Version Hash**: 9028022692284a7ec2ca1f80f9a7471ab1190903

## Build Process
```bash
# Build completo
make RG351MP

# Build específico do kernel com DTB
DEVICE=RG351MP ARCH=aarch64 ./scripts/build kernel

# Limpeza + rebuild
DEVICE=RG351MP ARCH=aarch64 ./scripts/clean kernel
make RG351MP
```

## GPIO Configuration
- **First SD CD**: GPIO0_PA3 (active low)
- **Second SD CD**: GPIO3_PB6 (active low)
- **Voltage IO**: vccio_sd (1.8V-3.3V)
- **Power Supply**: vcc_sd (3.3V)

## Problema conhecido
- Segundo slot (mmcblk1) não é detectado at runtime, apesar de estar habilitado no DTB
- Ambas versões do DTS (compilada e source) têm `status = "okay"` para dwmmc@ff380000
- Causa está provavelmente no kernel runtime, não na configuração estática
