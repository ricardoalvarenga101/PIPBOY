# Índice de Documentação - PipBoy & R50S

## 📚 Documentação Disponível

### 1. **r50s-device-specs.md**
Especificações técnicas do Game Console R50S
- Hardware: RK3326, CPU, GPU, RAM
- SD Card slots e controladores MMC
- Compatibilidade com RG351MP build
- GPIO configuration
- Problema conhecido (mmcblk1 não detectado)

### 2. **dts-files-reference.md**
Device Tree Source file reference
- Localização dos arquivos DTS
- Configuração SDMMC (primeiro slot)
- Configuração SDIO (segundo slot)
- Versão compilada vs source
- eMMC (desabilitado)

### 3. **build-system-overview.md**
Guia de build do projeto PipBoy
- Hierarquia de configuração
- Variáveis de ambiente
- Bootloader logic
- Kernel package info
- Comandos úteis (build, clean, etc)
- Diretórios de output

### 4. **r50s-mmc1-issue.md**
Investigação detalhada: Segundo SD card não detectado
- Descrição do problema
- Verificações já realizadas
- GPIO config e conclusões
- Testes necessários (próximos passos)
- Possíveis causas

### 5. **project-conventions.md**
Convenções e estrutura geral do projeto
- Informações de distribuição
- Devices suportados
- Estrutura de pastas
- Pacote meta principal
- Drivers WiFi compilados
- WiFi Toggle OTG (R50S específico)
- Update/Release system
- Theme system (importante: dois tipos)
- Permissões e segurança

## 🗺️ Como Usar Esta Documentação

### Para entender Device R50S
→ Comece em **r50s-device-specs.md**

### Para compilar firmware
→ Consulte **build-system-overview.md**

### Para debugar DTB
→ Veja **dts-files-reference.md**

### Para investigar problema MMC1
→ Leia **r50s-mmc1-issue.md**

### Para convenções gerais
→ Referência rápida em **project-conventions.md**

## 🔑 Informações Críticas

### Build Device R50S
```bash
make RG351MP              # Build padrão
make docker-RG351MP       # Build recomendado (container)
```

### Bootloader detecta R50S via
```bash
if test ${hwrev} = 'r50s'; then
    # Carrega DTB R50S
fi
```

### Kernel Source R50S
- Repository: `https://github.com/ricardoalvarenga101/kernel_rg351`
- Branch: `r50s`
- DTB compilado: `rk3326-r50s-linux.dtb`

### Problema Atual
- Primeiro MMC (mmcblk0): ✅ Funcionando
- Segundo MMC (mmcblk1): ❌ Não detectado em runtime
- Causa: Não é DTB (ambas versões corretas), é kernel runtime
- Próximo teste: Inserir SD antes de ligar device

## 📝 Atualizações Recomendadas
- Se descobrir nova informação: atualizar arquivo relevante
- Se encontrar solução para MMC1: atualizar **r50s-mmc1-issue.md**
- Se mudar processo build: atualizar **build-system-overview.md**
