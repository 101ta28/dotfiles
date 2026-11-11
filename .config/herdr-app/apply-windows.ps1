[CmdletBinding()]
param(
    [string]$ConfigDir
)

$ErrorActionPreference = 'Stop'

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'Use keys.json directly on Linux. This script applies the Windows override.'
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
$overridePath = Join-Path $PSScriptRoot 'keys.windows.json'
$targetPath = Join-Path $ConfigDir 'keys.json'

if ($targetPath -eq [IO.Path]::GetFullPath($commonPath)) {
    throw 'Choose the app configuration directory, not this repository directory.'
}

$keys = Get-Content -LiteralPath $commonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$windowsKeys = Get-Content -LiteralPath $overridePath -Raw -Encoding UTF8 | ConvertFrom-Json
# Only Ctrl+J needs Windows key events; all other bindings come from the common file.
$ctrlJ = $windowsKeys.terminal.'ctrl-j'
if ([string]::IsNullOrWhiteSpace($ctrlJ)) {
    throw 'keys.windows.json must define terminal.ctrl-j.'
}
$keys.terminal.'ctrl-j' = $ctrlJ
$content = ($keys | ConvertTo-Json -Depth 20) + [Environment]::NewLine

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
