# Arquivos Device Tree Source (DTS) - R50S

## Localização dos Arquivos
- **Compiled DTB**: `r50s-dtb/rk3326-r50s-linux.dts`
- **Repository Source**: `r50s-dtb/rk3326-r50s-linux-dts-repositorio.dts`
- **Build Origin**: Compilado do kernel durante `make RG351MP` via `KERNEL_MAKE_EXTRACMD+=" rockchip/rk3326-r50s-linux.dtb"`

## Estrutura de Referência (NÃO é parte do build)
- **Pasta**: `r50s-dtb/` é apenas referência de compatibilidade
- **Nota**: Não é usada no sistema de build; DTB vem do kernel git repository
- **Propósito**: Documentar hardware do R50S (pinout, periféricos, timing de memória)

## Configuração do Primeiro SD (SDMMC)
```dts
&sdmmc {
    bus-width = <4>;
    cap-mmc-highspeed;
    cap-sd-highspeed;
    supports-sd;
    card-detect-delay = <800>;
    ignore-pm-notify;
    cd-gpios = <&gpio0 RK_PA3 GPIO_ACTIVE_LOW>;
    sd-uhs-sdr12;
    sd-uhs-sdr25;
    sd-uhs-sdr50;
    sd-uhs-sdr104;
    vqmmc-supply = <&vccio_sd>;
    vmmc-supply = <&vcc_sd>;
    status = "okay";
};
```

## Configuração do Segundo SD (SDIO)
```dts
&sdio {
    bus-width = <4>;
    cap-mmc-highspeed;
    cap-sd-highspeed;
    supports-sd;
    card-detect-delay = <800>;
    ignore-pm-notify;
    cd-gpios = <&gpio3 RK_PB6 GPIO_ACTIVE_LOW>;
    sd-uhs-sdr12;
    sd-uhs-sdr25;
    sd-uhs-sdr50;
    sd-uhs-sdr104;
    vqmmc-supply = <&vccio_sd>;
    vmmc-supply = <&vcc_sd>;
    status = "okay";
};
```

## Versão Compilada (Hex Format)
- Primeiro MMC: `dwmmc@ff370000 { status = "okay"; cd-gpios = <0x5c 0x03 0x01>; }`
- Segundo MMC: `dwmmc@ff380000 { status = "okay"; cd-gpios = <0x96 0x0e 0x01>; }`

## Verificação de Status
Ambas versões têm a mesma configuração; diferença é apenas em formato (legível vs compilado).
Conclusão: **DTB está correto, problema está em runtime do kernel**.

## eMMC (Desabilitado)
```dts
&emmc {
    status = "disabled";
};
```
