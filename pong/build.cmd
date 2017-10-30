@@echo off

:RunPowerShellScript
@@set POWERSHELL_BAT_ARGS=%~dp0
@@if defined POWERSHELL_BAT_ARGS set POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%
@@PowerShell -ExecutionPolicy RemoteSigned -Command Invoke-Expression $('$args=@(^&{$args} %POWERSHELL_BAT_ARGS%);'+[String]::Join([Environment]::NewLine,$((Get-Content '%~f0') -notmatch '^^@@^|^^:'))) & goto :EOF

{ 
    # Start PowerShell
    param ([string]$scriptDir)
    
    Write-Host "Building pong.love..."
    New-Item "$scriptDir\build" -Type directory -Force | Out-Null
    Compress-Archive -Path "$scriptDir\*.lua" -DestinationPath "$scriptDir\build\pong.zip" -CompressionLevel "Optimal" -Force | Out-Null
    Rename-Item -Path "$scriptDir\build\pong.zip" -NewName "pong.love" -Force | Out-Null
    
    # End PowerShell
}.Invoke($args)
