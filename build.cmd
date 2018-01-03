@@echo off

:RunPowerShellScript
@@set POWERSHELL_BAT_ARGS=%~1
@@if defined POWERSHELL_BAT_ARGS set POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%
@@PowerShell -ExecutionPolicy RemoteSigned -Command Invoke-Expression $('$args=@(^&{$args} %POWERSHELL_BAT_ARGS%);'+[String]::Join([Environment]::NewLine,$((Get-Content '%~f0') -notmatch '^^@@^|^^:'))) & goto :EOF

{
    # Start PowerShell
    param ([string]$gamePath)
 
    if ([string]::IsNullOrWhiteSpace($gamePath)) { throw [System.IO.FileNotFoundException] "No game specified!" }
    
    $gamePath = [System.IO.Path]::GetFullPath($gamePath.TrimEnd('\'))
    if (![System.IO.Directory]::Exists($gamePath)) { throw [System.IO.FileNotFoundException] "$gamePath doesn't exist!" }
    
    [string]$gameName = [System.IO.Path]::GetFileName($gamePath)

    Write-Host "Building $gameName.love..." -NoNewline
    Remove-Item -Recurse -Force "$gamePath\build" | Out-Null
    New-Item "$gamePath\build" -Type directory -Force | Out-Null
    Compress-Archive -Path "$gamePath\*.lua","$gamePath\*.ogg" -DestinationPath "$gamePath\build\$gameName.zip" -CompressionLevel "Optimal" -Force | Out-Null
    Rename-Item -Path "$gamePath\build\$gameName.zip" -NewName "$gameName.love" -Force | Out-Null
    [int]$fileSize = (Get-Item "$gamePath\build\$gameName.love").length
    Write-Host " complete, package is $fileSize bytes."

    # End PowerShell
}.Invoke($args)
