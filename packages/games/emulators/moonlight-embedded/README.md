# Moonlight Embedded para PipBoy

Moonlight é um cliente open-source para NVIDIA GameStream que permite jogar seus jogos de PC remotamente em seu dispositivo PipBoy.

## Requisitos

- Um PC NVIDIA GeForce com GameStream habilitado
- Wi-Fi conectado com baixa latência (recomendado 5GHz)
- Mesmo nome de usuário no PC (ou configuração manual no config)

## Primeira Utilização

1. **Inicie o Moonlight** pelo menu "Emulators" do EmulationStation
2. **Descoberta de PC**: O Moonlight procurará por PCs na rede
3. **Emparelhamento**: Selecione seu PC e confirme o código de emparelhamento
4. **Seleção de Jogo**: Escolha um jogo para começar a jogar

## Configuração

Os arquivos de configuração são armazenados em `/storage/.config/moonlight-embedded/`

### Resolução Customizada

Para usar a resolução **485x450** ou qualquer outra personalizada:

1. **Via SSH:**
   ```bash
   ssh root@<seu-pip-boy-ip>
   # Edite o arquivo de configuração
   cat > /storage/.config/moonlight-embedded/moonlight.conf << 'EOF'
   resolution=485x450
   fps=30
   bitrate=5000
   codec=hevc
   EOF
   ```

2. **Via Script (recomendado):**
   - Use o script `moonlight-config.sh` no menu Tools
   - Selecione "Configurar Resolução"
   - Digite a resolução desejada (ex: 485x450)

### Resoluções Recomendadas por Uso

- **485x450** - Alguns displaylinks e GPUs com stretch
- **640x360** - Baixa latência, usando menos bandwidth
- **1280x720** - Equilíbrio ideal para RG351MP
- **1920x1080** - Máxima qualidade (requer 5GHz e ótima latência)

### Controle de Entrada

- Mapeamento de controle é automático via SDL2
- Pressione `ESC` ou o botão SELECT para voltar ao menu

## Problemas Comuns

### PC Não Detectado
- Verifique se o PC e o PipBoy estão na mesma rede
- Tente reiniciar o PC e reexecutar o Moonlight
- Verifique que GameStream está habilitado no NVIDIA Control Panel

### Lag/Latência Alta
- Use 5GHz Wi-Fi (mais estável), não 2.4GHz
- Reduza a resolução em `/storage/.config/moonlight-embedded/.moonlight/moonlight.conf`
- Reduzir FPS de 60 para 30 também ajuda

### Botões Não Funcionam
- Verifique o mapeamento de controle no Moonlight ou use `gptokeyb`

## Mais Informações

- Repositório oficial: https://github.com/irtimmer/moonlight-embedded
- Wiki: https://github.com/irtimmer/moonlight-embedded/wiki
