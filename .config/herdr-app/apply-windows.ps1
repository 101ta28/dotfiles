[CmdletBinding()]
param(
    [string]$ConfigDir
)

$ErrorActionPreference = 'Stop'

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'Use keys.json directly on Linux. Run this script on Windows.'
}

if ([string]::IsNullOrWhiteSpace($ConfigDir)) {
    $ConfigDir = if ($env:HERDR_APP_HOME) {
        $env:HERDR_APP_HOME
    } else {
        Join-Path $env:USERPROFILE '.config\herdr-app'
    }
}
$ConfigDir = [IO.Path]::GetFullPath($ConfigDir)
$commonPath = Join-Path $PSScriptRoot 'keys.json'
$targetPath = Join-Path $ConfigDir 'keys.json'

if ($targetPath -eq [IO.Path]::GetFullPath($commonPath)) {
    throw 'Choose the app configuration directory, not this repository directory.'
}

$content = [IO.File]::ReadAllText($commonPath)
$null = $content | ConvertFrom-Json

if ((Test-Path -LiteralPath $targetPath -PathType Leaf) -and
    ([IO.File]::ReadAllText($targetPath).TrimEnd() -eq $content.TrimEnd())) {
    return [pscustomobject]@{ Path = $targetPath; Changed = $false; Backup = $null }
}

New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
$id = [Guid]::NewGuid().ToString('N')
$tempPath = Join-Path $ConfigDir ".keys-$id.tmp"
$backupPath = $null
try {
    [IO.File]::WriteAllText($tempPath, $content, [Text.UTF8Encoding]::new($false))
    if (Test-Path -LiteralPath $targetPath) {
        $backupPath = "$targetPath.bak-$id"
        # Back up and replace the complete file so Herdr never sees partial JSON.
        [IO.File]::Replace($tempPath, $targetPath, $backupPath)
    } else {
        [IO.File]::Move($tempPath, $targetPath)
    }
} finally {
    if (Test-Path -LiteralPath $tempPath) {
        Remove-Item -LiteralPath $tempPath
    }
}
[pscustomobject]@{ Path = $targetPath; Changed = $true; Backup = $backupPath }
