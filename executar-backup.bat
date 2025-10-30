@echo off
REM Script de Backup - Wrapper Batch
REM Este arquivo facilita a execucao do script PowerShell

echo ========================================
echo Script de Backup - Unidade de Rede
echo ========================================
echo.

REM Configuracoes - EDITE AQUI ANTES DE EXECUTAR!
set ORIGEM=\\servidor\compartilhamento
set DESTINO=C:\Backup
set MODO_INCREMENTAL=false

echo Configuracoes atuais:
echo Origem: %ORIGEM%
echo Destino: %DESTINO%
echo Modo Incremental: %MODO_INCREMENTAL%
echo.
echo ========================================
echo ATENCAO: Verifique as configuracoes!
echo ========================================
echo.
echo Os caminhos acima sao exemplos!
echo.
echo Se os caminhos estiverem incorretos:
echo 1. Feche esta janela
echo 2. Clique com botao direito em executar-backup.bat
echo 3. Escolha "Editar"
echo 4. Altere ORIGEM e DESTINO com seus caminhos reais
echo 5. Salve e execute novamente
echo.
echo Se os caminhos estiverem corretos, pressione qualquer tecla...
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
