@echo off
REM Script de Backup - Wrapper Batch
REM Este arquivo facilita a execucao do script PowerShell

echo ========================================
echo Script de Backup - Unidade de Rede
echo ========================================
echo.

REM Configuracoes - EDITE AQUI
set ORIGEM=\\servidor\compartilhamento
set DESTINO=C:\Backup
set MODO_INCREMENTAL=false

echo Configuracoes atuais:
echo Origem: %ORIGEM%
echo Destino: %DESTINO%
echo Modo Incremental: %MODO_INCREMENTAL%
echo.
echo IMPORTANTE: Edite este arquivo .bat para alterar as configuracoes
echo.
pause

echo.
echo Iniciando backup...
echo.

REM Executa o script PowerShell
if "%MODO_INCREMENTAL%"=="true" (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0backup-rede.ps1" -OrigemRede "%ORIGEM%" -DestinoLocal "%DESTINO%" -ModoIncremental
) else (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0backup-rede.ps1" -OrigemRede "%ORIGEM%" -DestinoLocal "%DESTINO%"
)

echo.
echo ========================================
echo Backup Finalizado
echo ========================================
echo.
pause
