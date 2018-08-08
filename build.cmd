@@echo off

:RunPowerShellScript
@@set POWERSHELL_BAT_ARGS=
@@if defined POWERSHELL_BAT_ARGS set POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%
@@PowerShell -ExecutionPolicy RemoteSigned -Command Invoke-Expression $('$args=@(^&{$args} %POWERSHELL_BAT_ARGS%);'+[String]::Join([Environment]::NewLine,$((Get-Content '%~f0') -notmatch '^^@@^|^^:'))) & goto :EOF

{
    # Start PowerShell
    $srcPath = [System.IO.Path]::GetFullPath("src")
    if (![System.IO.Directory]::Exists($srcPath)) { throw [System.IO.FileNotFoundException] "$srcPath doesn't exist!" }
    
    [string]$gameName = "retrolove"

    Write-Host "Building $gameName.love..." -NoNewline
    Remove-Item -Recurse -Force "build" | Out-Null
    New-Item "build" -Type directory -Force | Out-Null
    Compress-Archive -Path "$srcPath\*" -DestinationPath "build\$gameName.zip" -CompressionLevel "Optimal" -Force | Out-Null
    Rename-Item -Path "build\$gameName.zip" -NewName "$gameName.love" -Force | Out-Null
    [int]$fileSize = (Get-Item "build\$gameName.love").length
    Write-Host " complete, package is $fileSize bytes."

    # End PowerShell
}.Invoke($args)
