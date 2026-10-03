<# Check repository abapGit files without changing them; -Fix repairs bytes.
   Validate committed blobs separately after staging: this checks the worktree. #>
[CmdletBinding()]
param([switch]$Fix)
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
$bom = [byte[]](0xEF, 0xBB, 0xBF)

function Get-Violations([byte[]]$bytes, [bool]$wantBom) {
    $v = New-Object 'System.Collections.Generic.List[string]'
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191
    if ($hasBom -ne $wantBom) { $v.Add('incorrect BOM') }
    try { $text = $utf8.GetString($bytes) } catch { $v.Add('invalid UTF-8'); return $v }
    if ($text.Contains("`r")) { $v.Add('non-LF line ending') }
    if (-not $text.EndsWith("`n")) { $v.Add('missing final LF') }
    elseif ($text.EndsWith("`n`n")) { $v.Add('trailing blank line') }
    return $v
}

function Fix-Bytes([byte[]]$bytes, [bool]$wantBom) {
    # Strict decode: do not replace invalid bytes silently.
    $text = $utf8.GetString($bytes).TrimStart([char]0xFEFF)
    $text = $text.Replace("`r`n", "`n").Replace("`r", "`n").TrimEnd([char]10) + "`n"
    $result = $utf8.GetBytes($text)
    if ($wantBom) { $result = $bom + $result }
    return $result
}

$files = @(Get-Item -LiteralPath (Join-Path $repoRoot '.abapgit.xml'))
$files += @(Get-ChildItem (Join-Path $repoRoot 'src') -Recurse -File | Where-Object { $_.Extension -in '.xml', '.abap' })
$failures = 0
foreach ($file in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $wantBom = $file.Extension -eq '.xml'
    $violations = @(Get-Violations $bytes $wantBom)
    if ($violations.Count -gt 0 -and $Fix) {
        $bytes = Fix-Bytes $bytes $wantBom
        $violations = @(Get-Violations $bytes $wantBom)
        if ($violations.Count -gt 0) { throw "Repair failed: $($file.Name): $($violations -join ', ')" }
        [System.IO.File]::WriteAllBytes($file.FullName, $bytes)
        Write-Host "FIXED $($file.Name)"
    }
    if ($violations.Count -gt 0) {
        $failures++
        Write-Host "FAIL $($file.Name): $($violations -join ', ')"
    }
}
Write-Host "Checked $($files.Count) files; violations: $failures"
if ($failures -gt 0) { exit 1 }
