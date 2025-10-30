# Arquivo de Configuracao de Exemplo para Backup
# Copie este arquivo e edite conforme necessario

# ====================================
# CONFIGURACOES BASICAS
# ====================================

# Caminho da unidade de rede (origem do backup)
# Exemplos:
#   - Caminho UNC: \\servidor\compartilhamento
#   - Unidade mapeada: Z:\
#   - IP direto: \\192.168.1.100\dados
$OrigemRede = "\\servidor\compartilhamento"

# Caminho local onde os arquivos serao salvos (destino do backup)
# Exemplos:
#   - C:\Backup
#   - D:\Backups\RedeEmpresa
#   - E:\BackupDiario
$DestinoLocal = "C:\Backup"

# Modo de backup
# $true = Incremental (apenas arquivos novos ou modificados)
# $false = Completo (todos os arquivos)
$ModoIncremental = $false

# ====================================
# EXEMPLO DE USO
# ====================================

# Para usar este arquivo de configuracao:
# 1. Edite os valores acima conforme sua necessidade
# 2. Salve o arquivo com um nome descritivo (ex: config-backup-empresa.ps1)
# 3. Execute o backup usando este arquivo:
#    .\backup-rede.ps1 -OrigemRede $OrigemRede -DestinoLocal $DestinoLocal -ModoIncremental:$ModoIncremental

# ====================================
# EXEMPLOS DE CONFIGURACAO
# ====================================

# Exemplo 1: Backup completo de servidor de arquivos
# $OrigemRede = "\\servidor-arquivos\documentos"
# $DestinoLocal = "C:\Backup\Documentos"
# $ModoIncremental = $false

# Exemplo 2: Backup incremental de unidade mapeada
# $OrigemRede = "Z:\"
# $DestinoLocal = "D:\Backup\UnidadeZ"
# $ModoIncremental = $true

# Exemplo 3: Backup de NAS usando IP
# $OrigemRede = "\\192.168.1.200\backup"
# $DestinoLocal = "E:\Backup\NAS"
# $ModoIncremental = $true
