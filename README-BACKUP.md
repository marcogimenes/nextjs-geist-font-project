# Script de Backup - Unidade de Rede para Máquina Local

Este script PowerShell foi desenvolvido para fazer backup automático de arquivos de uma unidade de rede para a máquina local.

## 📋 Requisitos

- Windows 7 ou superior
- PowerShell 5.1 ou superior
- Permissões de leitura na unidade de rede
- Espaço suficiente no disco local

## 🚀 Como Usar

### Uso Básico

1. Abra o PowerShell (recomenda-se executar como Administrador)
2. Navegue até a pasta onde o script está localizado
3. Execute o comando:

```powershell
.\backup-rede.ps1 -OrigemRede "\\servidor\compartilhamento" -DestinoLocal "C:\Backup"
```

### Exemplos de Uso

#### Backup de unidade de rede mapeada:
```powershell
.\backup-rede.ps1 -OrigemRede "Z:\" -DestinoLocal "D:\Backup"
```

#### Backup incremental (apenas arquivos novos ou modificados):
```powershell
.\backup-rede.ps1 -OrigemRede "\\servidor\dados" -DestinoLocal "C:\Backup" -ModoIncremental
```

#### Backup com caminho UNC:
```powershell
.\backup-rede.ps1 -OrigemRede "\\192.168.1.100\compartilhamento" -DestinoLocal "C:\MeusBackups"
```

## 📝 Parâmetros

| Parâmetro | Descrição | Obrigatório | Exemplo |
|-----------|-----------|-------------|---------|
| `-OrigemRede` | Caminho da unidade de rede (UNC ou letra de drive) | Não* | `"\\servidor\pasta"` ou `"Z:\"` |
| `-DestinoLocal` | Caminho local onde os arquivos serão salvos | Não* | `"C:\Backup"` |
| `-ModoIncremental` | Copia apenas arquivos novos ou modificados | Não | (switch - sem valor) |

*Se não especificados, usa valores padrão: origem = `\\servidor\compartilhamento`, destino = `C:\Backup`

## ✨ Funcionalidades

- ✅ Cópia completa ou incremental de arquivos
- ✅ Preserva estrutura de pastas
- ✅ Preserva atributos e permissões dos arquivos
- ✅ Verificação de espaço em disco antes de iniciar
- ✅ Logs detalhados de todas as operações
- ✅ Tratamento de erros
- ✅ Múltiplas threads para cópia mais rápida (8 threads)
- ✅ Relatório final com estatísticas
- ✅ Mensagens coloridas no console para fácil identificação

## 📊 Logs

O script gera dois tipos de logs na pasta `[DestinoLocal]\Logs`:

1. **Log Principal** (`backup_YYYYMMDD_HHMMSS.log`):
   - Informações gerais sobre o processo
   - Erros e avisos
   - Estatísticas finais

2. **Log do Robocopy** (`robocopy_YYYYMMDD_HHMMSS.log`):
   - Detalhes de cada arquivo copiado
   - Erros específicos de cópia
   - Estatísticas detalhadas

## 🔧 Configuração de Execução de Scripts

Se for a primeira vez executando scripts PowerShell, você pode encontrar um erro de política de execução. Para resolver:

1. Abra o PowerShell como Administrador
2. Execute:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## ⚙️ Como o Script Funciona

1. **Validação**: Verifica se a origem existe e está acessível
2. **Preparação**: Cria diretórios de destino e logs se necessário
3. **Análise**: Conta arquivos e calcula tamanho total
4. **Verificação de Espaço**: Compara espaço necessário com disponível
5. **Backup**: Utiliza Robocopy para copiar os arquivos
6. **Relatório**: Gera relatório final com estatísticas

## 🔒 Segurança e Permissões

- **Recomenda-se executar como Administrador** para garantir acesso a todos os arquivos
- O script não modifica arquivos na origem, apenas lê
- Credenciais de rede devem estar configuradas no Windows (unidade mapeada ou credenciais salvas)

## 📅 Agendamento Automático

Para executar o backup automaticamente:

### Usando o Agendador de Tarefas do Windows:

1. Abra o "Agendador de Tarefas"
2. Clique em "Criar Tarefa Básica"
3. Configure o nome e descrição
4. Escolha a frequência (diária, semanal, etc.)
5. Em "Ação", escolha "Iniciar um programa"
6. Em "Programa/script": `powershell.exe`
7. Em "Adicionar argumentos":
```
-ExecutionPolicy Bypass -File "C:\caminho\para\backup-rede.ps1" -OrigemRede "\\servidor\pasta" -DestinoLocal "C:\Backup" -ModoIncremental
```

### Exemplo de Tarefa Agendada via PowerShell:

```powershell
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\Scripts\backup-rede.ps1" -OrigemRede "\\servidor\dados" -DestinoLocal "C:\Backup" -ModoIncremental'
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
$principal = New-ScheduledTaskPrincipal -UserId "SISTEMA" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "Backup Rede Diário" -Action $action -Trigger $trigger -Principal $principal -Description "Backup automático da unidade de rede"
```

## 🛠️ Solução de Problemas

### Erro: "Não é possível acessar a origem"
- Verifique se a unidade de rede está conectada
- Verifique suas credenciais de rede
- Tente acessar manualmente a pasta pelo Windows Explorer

### Erro: "Espaço insuficiente"
- Libere espaço no disco de destino
- Use o modo incremental para economizar espaço
- Escolha outro destino com mais espaço

### Erro: "Acesso negado a alguns arquivos"
- Execute o PowerShell como Administrador
- Verifique suas permissões na rede

### Script não executa
- Verifique a política de execução do PowerShell
- Execute: `Get-ExecutionPolicy` e ajuste se necessário

## 📈 Códigos de Saída do Robocopy

O script usa Robocopy internamente. Os códigos de saída são:

- **0**: Nenhum arquivo foi copiado
- **1**: Arquivos copiados com sucesso
- **2**: Arquivos extras encontrados no destino
- **3**: Arquivos copiados e extras encontrados
- **4 ou maior**: Erros durante a cópia

Códigos 0-3 são considerados sucesso, 4+ indicam problemas.

## 💡 Dicas

- Use **modo incremental** para backups frequentes (mais rápido)
- Use **modo completo** para backup inicial ou mensal
- Monitore os logs regularmente
- Configure alertas por email usando scripts adicionais
- Mantenha backups em múltiplos locais para redundância

## 📞 Suporte

Para problemas ou dúvidas, verifique os logs gerados pelo script em `[DestinoLocal]\Logs`.

## 📄 Licença

Este script é fornecido como está, sem garantias. Use por sua conta e risco.

---

**Desenvolvido para facilitar backups de redes Windows**
