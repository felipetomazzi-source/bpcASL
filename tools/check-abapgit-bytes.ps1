<#
.SYNOPSIS
    Validates abapGit serialization byte conventions in this repository.

.DESCRIPTION
    Conventions (see docs/ABAPGIT-SERIALIZATION.md):
      - Metadata XML (*.xml)    : UTF-8 WITH BOM, CRLF line endings, exactly one final CRLF.
      - ABAP source/test (*.abap): UTF-8 WITHOUT BOM, CRLF line endings, exactly one final CRLF.

    Default: check only; reports each violation and exits 1 if any are found.
    With -Fix: corrects violations in place (idempotent).

.EXAMPLE
    pwsh tools/check-abapgit-bytes.ps1          # verify
    pwsh tools/check-abapgit-bytes.ps1 -Fix     # correct in place
#>
[CmdletBinding()]
param(
    [switch]$Fix
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$bom = [byte[]](0xEF, 0xBB, 0xBF)

function Get-TargetFiles {
    $files = @()
    $files += Get-ChildItem -Path $repoRoot -Recurse -Filter '*.xml'  -File | Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }
    $files += Get-ChildItem -Path $repoRoot -Recurse -Filter '*.abap' -File | Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }
    return $files
}

function Convert-ToCrlf([byte[]]$bytes) {
    $out = New-Object 'System.Collections.Generic.List[byte]'
    $i = 0
    while ($i -lt $bytes.Length) {
        $b = $bytes[$i]
        if ($b -eq 0x0D) {
            $out.Add(0x0D)
            if (($i + 1) -lt $bytes.Length -and $bytes[$i + 1] -eq 0x0A) {
                $out.Add(0x0A)
                $i++
            }
        }
        elseif ($b -eq 0x0A) {
            $out.Add(0x0D)
            $out.Add(0x0A)
        }
        else {
            $out.Add($b)
        }
        $i++
    }
    return $out.ToArray()
}

function Get-Violations([byte[]]$bytes, [bool]$wantBom) {
    $v = New-Object 'System.Collections.Generic.List[string]'

    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    if ($wantBom -and -not $hasBom)      { $v.Add('missing BOM') }
    if (-not $wantBom -and $hasBom)      { $v.Add('unexpected BOM') }

    $i = 0
    $badEol = $false
    while ($i -lt $bytes.Length -and -not $badEol) {
        if ($bytes[$i] -eq 0x0D) {
            if (($i + 1) -ge $bytes.Length -or $bytes[$i + 1] -ne 0x0A) { $badEol = $true }
            $i += 2
        }
        elseif ($bytes[$i] -eq 0x0A) {
            $badEol = $true
        }
        else {
            $i++
        }
    }
    if ($badEol) { $v.Add('non-CRLF line ending') }

    if ($bytes.Length -lt 2) { $v.Add('missing final CRLF') }
    else {
        $endsCrlf = ($bytes[$bytes.Length - 2] -eq 0x0D -and $bytes[$bytes.Length - 1] -eq 0x0A)
        if (-not $endsCrlf) { $v.Add('missing final CRLF') }
        elseif ($bytes.Length -ge 4 -and $bytes[$bytes.Length - 4] -eq 0x0D -and $bytes[$bytes.Length - 3] -eq 0x0A) {
            $v.Add('trailing blank line')
        }
    }

    return $v
}

function Fix-Bytes([byte[]]$bytes, [bool]$wantBom) {
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $bytes = $bytes[3..($bytes.Length - 1)]
    }
    $bytes = Convert-ToCrlf $bytes
    while ($bytes.Length -ge 2 -and $bytes[$bytes.Length - 2] -eq 0x0D -and $bytes[$bytes.Length - 1] -eq 0x0A) {
        $bytes = $bytes[0..($bytes.Length - 3)]
    }
    $bytes = $bytes + [byte[]](0x0D, 0x0A)
    if ($wantBom) {
        $bytes = $bom + $bytes
    }
    return $bytes
}

$files = @(Get-TargetFiles)
$failures = 0

foreach ($f in $files) {
    $rel = $f.FullName.Substring($repoRoot.Length + 1)
    $isXml = ($f.Extension -ieq '.xml')
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $violations = Get-Violations $bytes $isXml

    if ($violations.Count -eq 0) {
        # conforms
    }
    elseif ($Fix) {
        [System.IO.File]::WriteAllBytes($f.FullName, (Fix-Bytes $bytes $isXml))
        Write-Host ("FIXED  {0}" -f $rel)
    }
    else {
        $failures++
        Write-Host ("FAIL   {0}: {1}" -f $rel, ($violations -join ', '))
    }
}

if (-not $Fix) {
    $ok = $files.Count - $failures
    Write-Host ("Checked {0} files: {1} conform, {2} with violations" -f $files.Count, $ok, $failures)
    if ($failures -gt 0) { exit 1 }
    Write-Host 'All files conform to the abapGit byte conventions.'
}
