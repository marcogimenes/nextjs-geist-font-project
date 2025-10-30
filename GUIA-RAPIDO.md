# Guia Rápido - Sistema de Backup de Rede

## 📦 Arquivos Incluídos

Este repositório agora contém um sistema completo de backup para Windows:

1. **backup-rede.ps1** - Script principal do PowerShell
2. **executar-backup.bat** - Arquivo batch para execução fácil
3. **config-backup-exemplo.ps1** - Exemplo de arquivo de configuração
4. **README-BACKUP.md** - Documentação completa
5. **GUIA-RAPIDO.md** - Este arquivo (início rápido)

## 🚀 Início Rápido (3 Passos)

### ⚠️ IMPORTANTE: Antes de Executar

**NÃO execute o script sem editar as configurações primeiro!** Os caminhos padrão (`\\servidor\compartilhamento` e `C:\Backup`) são apenas exemplos e precisam ser alterados para seus caminhos reais.

### Opção 1: Usando o Arquivo Batch (Mais Fácil)

1. **⚠️ EDITE PRIMEIRO** o arquivo `executar-backup.bat`:
   - Clique com botão direito → Editar (ou abra com Bloco de Notas)
   - **OBRIGATÓRIO:** Altere a linha `set ORIGEM=\\servidor\compartilhamento` para sua unidade de rede real
   - **OBRIGATÓRIO:** Altere a linha `set DESTINO=C:\Backup` para onde quer salvar os arquivos
   - Salve o arquivo (Ctrl+S)

2. **Execute** dando duplo clique em `executar-backup.bat`

3. **Pronto!** O backup será executado automaticamente

### Opção 2: Usando PowerShell Diretamente

1. **Abra** o PowerShell (botão direito → Executar como Administrador)

2. **Navegue** até a pasta do script:
   ```powershell
   cd "C:\caminho\para\a\pasta"
   ```

3. **Execute** o comando:
   ```powershell
   .\backup-rede.ps1 -OrigemRede "\\servidor\pasta" -DestinoLocal "C:\Backup"
   ```

## 💡 Exemplos Práticos

### Backup de Unidade Z: para C:\Backup
```powershell
.\backup-rede.ps1 -OrigemRede "Z:\" -DestinoLocal "C:\Backup"
```

### Backup Incremental (apenas arquivos novos)
```powershell
.\backup-rede.ps1 -OrigemRede "\\servidor\dados" -DestinoLocal "C:\Backup" -ModoIncremental
```

### Backup de Servidor Específico
```powershell
.\backup-rede.ps1 -OrigemRede "\\192.168.1.100\compartilhamento" -DestinoLocal "D:\Backups"
```

## 📝 Onde Ficam os Logs?

Os logs são salvos em: `[DestinoLocal]\Logs\`

Exemplo: Se você escolheu `C:\Backup` como destino, os logs estarão em `C:\Backup\Logs\`

## ⚙️ Primeira Execução

Se aparecer um erro sobre "política de execução", execute isto uma vez:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 🔄 Backup Automático (Agendado)

Para fazer backup automático todo dia:

1. Abra o **Agendador de Tarefas** do Windows
2. Clique em **Criar Tarefa Básica**
3. Nome: "Backup Diário"
4. Gatilho: Diariamente às 2:00 AM
5. Ação: Iniciar um programa
   - Programa: `powershell.exe`
   - Argumentos: `-ExecutionPolicy Bypass -File "C:\caminho\backup-rede.ps1" -OrigemRede "\\servidor\pasta" -DestinoLocal "C:\Backup" -ModoIncremental`

## 🆘 Problemas Comuns

| Problema | Solução |
|----------|---------|
| "Não consegue acessar a rede" | Verifique se a unidade está mapeada no Windows |
| "Espaço insuficiente" | Libere espaço ou use modo incremental |
| "Acesso negado" | Execute como Administrador |
| Script não executa | Configure a política de execução (veja acima) |

## 📖 Documentação Completa

Para informações detalhadas, consulte: **README-BACKUP.md**

## 🎯 Recomendações

- ✅ Use **modo completo** uma vez por semana/mês
- ✅ Use **modo incremental** diariamente
- ✅ Verifique os logs regularmente
- ✅ Teste a restauração dos backups periodicamente
- ✅ Mantenha backups em múltiplos locais

---

**Precisa de ajuda?** Consulte o README-BACKUP.md ou verifique os logs em `[DestinoLocal]\Logs\`
