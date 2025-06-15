@echo off
setlocal enabledelayedexpansion

:: Creazione punto di ripristino
echo [!] CREAZIONE PUNTO DI RIPRISTINO...
powershell -command "Checkpoint-Machine -Description 'Prima ottimizzazione'"

:: Disinstallazione dei programmi non necessari
echo [+] DISINSTALLAZIONE SOFTWARE INUTILI...
set "prodotti="
for /f "tokens=2 delims=*abc" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" ^| findstr /r /c:"DisplayName"') do (
    set "nome=%%a"
    if not "!nome!"=="Microsoft Edge" echo Y | msiexec /x !nome! /qn /l*v %windir%\temp_uninstall.log >nul
)

:: Rimozione avvio automatico non necessari
echo [*] OTTIMIZZAZIONE AVVIO AUTOMATICO...
for /f "skip=1 tokens=5*" %%i in ('tasklist ^| findstr /I "^""') do (
    set "nome=%%i"
    set "descrizione=%%j"
    if "!descrizione!" neq "" echo Y | taskkill /f /im !nome! >nul
)

:: Configurazione rete avanzata
echo [-]: CONFIGURAZIONE SCHEDA DI RETE...
powershell -command {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    Set-ItemProperty -path $regPath -name "PerformBandwidthThrottling" -value 0
    Set-ItemProperty -path "$regPath\Dns" -name "(DisableRotation)" -value 1
    
    # Attivare efficiente TCP/IP
    netsh interface tcp set global autotuning=enabled
}

:: Ottimizzazione processi in background
echo [°] OTTIMIZZAZIONE PROCESSI...
powershell -command "Set-Service 'wlanauto' -StartupType Disabled"
powershell -command "Set-Service 'Remote Differential Compression Client Service' -StartupType Disabled"

:: Avvisi di sicurezza
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo AVVISO: Lo script ha eseguito le operazioni. Si consiglia:
echo 1) Scansione antivirus completa
echo 2) Verifica funzionalità critiche del sistema
echo 3) Ripristino punti di ripristino periodici
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

endlocal

exit /b
