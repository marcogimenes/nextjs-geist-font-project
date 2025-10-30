# Script de Backup de Unidade de Rede para Máquina Local
# Autor: Marco Gimenes
# Data: 2025-10-30

<#
.SYNOPSIS
    Script para realizar backup de arquivos de uma unidade de rede para a máquina local.

.DESCRIPTION
    Este script copia todos os arquivos de uma unidade de rede especificada 
    para um diretório local, mantendo a estrutura de pastas e criando logs 
    detalhados da operação.

.PARAMETER OrigemRede
    Caminho da unidade de rede (ex: \\servidor\compartilhamento ou Z:\)

.PARAMETER DestinoLocal
    Caminho local onde os arquivos serão armazenados (ex: C:\Backup)

.PARAMETER ModoIncremental
    Se especificado, faz backup apenas de arquivos novos ou modificados

.EXAMPLE
    .\backup-rede.ps1 -OrigemRede "\\servidor\dados" -DestinoLocal "C:\Backup"
    
.EXAMPLE
    .\backup-rede.ps1 -OrigemRede "Z:\" -DestinoLocal "D:\Backup" -ModoIncremental
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$OrigemRede = "\\servidor\compartilhamento",
    
    [Parameter(Mandatory=$false)]
    [string]$DestinoLocal = "C:\Backup",
    
    [Parameter(Mandatory=$false)]
    [switch]$ModoIncremental = $false
)

# Configurações
$LogDir = "$DestinoLocal\Logs"
$DataHora = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = "$LogDir\backup_$DataHora.log"

# Função para escrever no log e na tela
function Write-Log {
    param(
        [string]$Mensagem,
        [ValidateSet("INFO", "AVISO", "ERRO", "SUCESSO")]
        [string]$Nivel = "INFO"
    )
    
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMensagem = "[$TimeStamp] [$Nivel] $Mensagem"
    
    # Escreve no arquivo de log
    Add-Content -Path $LogFile -Value $LogMensagem
    
    # Escreve na tela com cores
    switch ($Nivel) {
        "INFO"    { Write-Host $LogMensagem -ForegroundColor Cyan }
        "AVISO"   { Write-Host $LogMensagem -ForegroundColor Yellow }
        "ERRO"    { Write-Host $LogMensagem -ForegroundColor Red }
        "SUCESSO" { Write-Host $LogMensagem -ForegroundColor Green }
    }
}

# Função para validar se o caminho existe
function Test-PathExists {
    param([string]$Path)
    
    if (-not (Test-Path -Path $Path)) {
        return $false
    }
    return $true
}

# Função principal de backup
function Start-BackupRede {
    try {
        Write-Log "========================================" "INFO"
        Write-Log "Iniciando processo de backup" "INFO"
        Write-Log "========================================" "INFO"
        Write-Log "Origem: $OrigemRede" "INFO"
        Write-Log "Destino: $DestinoLocal" "INFO"
        Write-Log "Modo Incremental: $ModoIncremental" "INFO"
        Write-Log "========================================" "INFO"
        
        # Verifica se a origem existe
        if (-not (Test-PathExists -Path $OrigemRede)) {
            Write-Log "ERRO: O caminho de origem não existe ou não está acessível: $OrigemRede" "ERRO"
            Write-Log "Verifique se a unidade de rede está mapeada e acessível." "ERRO"
            return $false
        }
        
        # Cria o diretório de destino se não existir
        if (-not (Test-PathExists -Path $DestinoLocal)) {
            Write-Log "Criando diretório de destino: $DestinoLocal" "INFO"
            New-Item -ItemType Directory -Path $DestinoLocal -Force | Out-Null
        }
        
        # Cria o diretório de logs se não existir
        if (-not (Test-PathExists -Path $LogDir)) {
            Write-Log "Criando diretório de logs: $LogDir" "INFO"
            New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        }
        
        # Conta os arquivos na origem
        Write-Log "Contando arquivos na origem..." "INFO"
        $TotalArquivos = (Get-ChildItem -Path $OrigemRede -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
        Write-Log "Total de arquivos encontrados: $TotalArquivos" "INFO"
        
        # Calcula o tamanho total
        $TamanhoTotal = (Get-ChildItem -Path $OrigemRede -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $TamanhoTotalMB = [math]::Round($TamanhoTotal / 1MB, 2)
        $TamanhoTotalGB = [math]::Round($TamanhoTotal / 1GB, 2)
        Write-Log "Tamanho total: $TamanhoTotalMB MB ($TamanhoTotalGB GB)" "INFO"
        
        # Verifica espaço disponível no destino
        $DestinoLetra = Split-Path -Path $DestinoLocal -Qualifier
        $EspacoLivre = (Get-PSDrive -Name $DestinoLetra.TrimEnd(':')).Free
        $EspacoLivreGB = [math]::Round($EspacoLivre / 1GB, 2)
        Write-Log "Espaço disponível no destino: $EspacoLivreGB GB" "INFO"
        
        if ($EspacoLivre -lt $TamanhoTotal) {
            Write-Log "AVISO: Espaço insuficiente no destino!" "AVISO"
            Write-Log "Necessário: $TamanhoTotalGB GB | Disponível: $EspacoLivreGB GB" "AVISO"
            $resposta = Read-Host "Deseja continuar mesmo assim? (S/N)"
            if ($resposta -ne 'S' -and $resposta -ne 's') {
                Write-Log "Backup cancelado pelo usuário" "AVISO"
                return $false
            }
        }
        
        # Realiza o backup usando robocopy
        Write-Log "Iniciando cópia de arquivos..." "INFO"
        $RobocopyLog = "$LogDir\robocopy_$DataHora.log"
        
        if ($ModoIncremental) {
            # Modo incremental - copia apenas arquivos novos ou modificados
            Write-Log "Executando backup incremental..." "INFO"
            $RobocopyArgs = @(
                $OrigemRede,
                $DestinoLocal,
                "/E",           # Copia subdiretórios, incluindo vazios
                "/COPYALL",     # Copia todas as informações do arquivo
                "/R:3",         # Número de repetições em caso de falha
                "/W:10",        # Tempo de espera entre repetições (segundos)
                "/MT:8",        # Usa 8 threads para cópia mais rápida
                "/XO",          # Exclui arquivos mais antigos
                "/LOG:$RobocopyLog",
                "/NP",          # Não mostra progresso
                "/TEE"          # Saída para console e log
            )
        } else {
            # Modo completo - copia todos os arquivos
            Write-Log "Executando backup completo..." "INFO"
            $RobocopyArgs = @(
                $OrigemRede,
                $DestinoLocal,
                "/E",           # Copia subdiretórios, incluindo vazios
                "/COPYALL",     # Copia todas as informações do arquivo
                "/R:3",         # Número de repetições em caso de falha
                "/W:10",        # Tempo de espera entre repetições (segundos)
                "/MT:8",        # Usa 8 threads para cópia mais rápida
                "/LOG:$RobocopyLog",
                "/NP",          # Não mostra progresso
                "/TEE"          # Saída para console e log
            )
        }
        
        $RobocopyProcess = Start-Process -FilePath "robocopy.exe" -ArgumentList $RobocopyArgs -Wait -PassThru -NoNewWindow
        $ExitCode = $RobocopyProcess.ExitCode
        
        # Robocopy exit codes:
        # 0 = Nenhum arquivo copiado
        # 1 = Arquivos copiados com sucesso
        # 2 = Arquivos extras no destino
        # 3 = Arquivos copiados e arquivos extras
        # 4+ = Erros
        
        if ($ExitCode -lt 8) {
            Write-Log "Backup concluído com sucesso!" "SUCESSO"
            Write-Log "Código de saída do Robocopy: $ExitCode" "INFO"
            
            # Gera relatório final
            Write-Log "========================================" "INFO"
            Write-Log "RELATÓRIO FINAL" "INFO"
            Write-Log "========================================" "INFO"
            
            $ArquivosDestino = (Get-ChildItem -Path $DestinoLocal -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notlike "*\Logs\*" } | Measure-Object).Count
            $TamanhoDestino = (Get-ChildItem -Path $DestinoLocal -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notlike "*\Logs\*" } | Measure-Object -Property Length -Sum).Sum
            $TamanhoDestinoGB = [math]::Round($TamanhoDestino / 1GB, 2)
            
            Write-Log "Arquivos no destino: $ArquivosDestino" "INFO"
            Write-Log "Tamanho total copiado: $TamanhoDestinoGB GB" "INFO"
            Write-Log "Log detalhado salvo em: $RobocopyLog" "INFO"
            Write-Log "========================================" "INFO"
            
            return $true
        } else {
            Write-Log "Backup concluído com erros!" "ERRO"
            Write-Log "Código de saída do Robocopy: $ExitCode" "ERRO"
            Write-Log "Verifique o log detalhado em: $RobocopyLog" "ERRO"
            return $false
        }
        
    } catch {
        Write-Log "Erro durante o processo de backup: $($_.Exception.Message)" "ERRO"
        Write-Log "Detalhes: $($_.Exception.StackTrace)" "ERRO"
        return $false
    }
}

# Inicia a execução
try {
    # Verifica se está executando como administrador
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Host "AVISO: Este script não está sendo executado como administrador." -ForegroundColor Yellow
        Write-Host "Alguns arquivos podem não ser copiados devido a permissões." -ForegroundColor Yellow
        Write-Host ""
    }
    
    # Cria o diretório de logs se não existir (antes de iniciar o log)
    if (-not (Test-Path -Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
    
    # Executa o backup
    $resultado = Start-BackupRede
    
    if ($resultado) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "BACKUP CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Confira os logs em: $LogFile" -ForegroundColor Cyan
        exit 0
    } else {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "BACKUP CONCLUÍDO COM ERROS!" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "Confira os logs em: $LogFile" -ForegroundColor Cyan
        exit 1
    }
    
} catch {
    Write-Host "Erro fatal durante a execução do script: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
