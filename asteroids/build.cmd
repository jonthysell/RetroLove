@@echo off

:RunPowerShellScript
@@set POWERSHELL_BAT_ARGS=%~dp0
@@if defined POWERSHELL_BAT_ARGS set POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%
@@PowerShell -ExecutionPolicy RemoteSigned -Command Invoke-Expression $('$args=@(^&{$args} %POWERSHELL_BAT_ARGS%);'+[String]::Join([Environment]::NewLine,$((Get-Content '%~f0') -notmatch '^^@@^|^^:'))) & goto :EOF

{ 
    # Start PowerShell
    param ([string]$scriptDir)
    
    Write-Host "Building asteroids.love..."
    Remove-Item -Recurse -Force "$scriptDir\build" | Out-Null
    New-Item "$scriptDir\build" -Type directory -Force | Out-Null
    Compress-Archive -Path "$scriptDir\*.lua" -DestinationPath "$scriptDir\build\asteroids.zip" -CompressionLevel "Optimal" -Force | Out-Null
    Rename-Item -Path "$scriptDir\build\asteroids.zip" -NewName "asteroids.love" -Force | Out-Null
    
    # End PowerShell
}.Invoke($args)
