<#
.SYNOPSIS
  Offline PML syntax checker / parser (tree-sitter-pml).
.DESCRIPTION
  Bundled, zero-dependency syntax gate for generated or edited PML sources.
  Uses tools/pml-parse/bin/tree-sitter.exe + pml.dll (grammar baseline:
  94.02% clean-parse on the 6075-file delivered PMLLIB, 22/22 unit corpus).
  Files that tree-sitter flags still parse to a usable tree -- an ERROR node
  is a "review this construct" signal, not proof the file cannot compile.
.EXAMPLE
  .\parse-pml.ps1 MyScript.pmlfnc                # single file: print syntax tree + verdict
.EXAMPLE
  .\parse-pml.ps1 C:\work\myapp -Recurse         # batch a folder tree, summary + failure lines
.EXAMPLE
  .\parse-pml.ps1 .\myapp -Recurse -Out fail.txt # also write failure details to a file
.OUTPUTS
  Exit code 0 = all clean, 2 = some files contain ERROR/MISSING nodes, 1 = tool/usage error.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory, Position = 0)]
  [string]$Path,
  [switch]$Recurse,
  [switch]$Tree,
  [string]$Out
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$bin     = Join-Path $PSScriptRoot 'bin'
$tsExe   = Join-Path $bin 'tree-sitter.exe'
$parserDll = Join-Path $bin 'pml.dll'
if (-not (Test-Path $tsExe))     { throw "missing $tsExe" }
if (-not (Test-Path $parserDll)) { throw "missing $parserDll" }

$exts = @('.pml', '.pmlobj', '.pmlfnc', '.pmlfrm', '.pmlmac', '.mac')

$resolved = Resolve-Path $Path
if ((Get-Item $resolved).PSIsContainer) {
  # NB: -Include on Get-ChildItem is only honoured with -Recurse or a wildcard
  # path, so filter by extension explicitly instead.
  $files = @(Get-ChildItem $resolved -Recurse:$Recurse -File |
    Where-Object { $exts -contains $_.Extension.ToLower() })
} else {
  $files = @(Get-Item $resolved)
}
if ($files.Count -eq 0) { Write-Warning 'no PML files found'; exit 0 }
"files: $($files.Count)"

# Single file (or -Tree): show the full syntax tree.
if ($files.Count -eq 1 -and -not $Recurse -and $Tree) {
  & $tsExe parse -l $parserDll --lang-name pml $files[0].FullName 2>&1
  $code = $LASTEXITCODE
  if ($code -eq 0) { 'CLEAN' } else { 'HAS ERROR NODES' }
  exit $(if ($code -eq 0) { 0 } else { 2 })
}

# Batch: quiet stat mode in chunks (same method as the 94.02% baseline bench).
$total = 0; $ok = 0; $failLines = @()
$listFile = Join-Path ([System.IO.Path]::GetTempPath()) ("pmlparse-{0}.txt" -f [guid]::NewGuid())
try {
  $all = @($files | ForEach-Object { $_.FullName })
  for ($start = 0; $start -lt $all.Count; $start += 600) {
    $end = [Math]::Min($start + 599, $all.Count - 1)
    [System.IO.File]::WriteAllLines($listFile, $all[$start..$end], (New-Object System.Text.UTF8Encoding($false)))
    # tree-sitter writes the per-file ERROR lines to STDERR. Merge both
    # streams through cmd so they arrive as one reliably-capturable text
    # stream regardless of host / redirect quirks.
    # NB: do NOT name this $out -- PowerShell variable names are
    # case-insensitive, so it collides with the [string]$Out parameter and
    # the type constraint flattens native output into ONE space-joined
    # string (per-file ERROR lines then hide inside the Total line's branch).
    $chunk = & cmd /c "`"$tsExe`" parse -l `"$parserDll`" --lang-name pml -q --stat --paths `"$listFile`" 2>&1"
    $chunk = ($chunk | Out-String) -split '\r?\n'
    foreach ($line in $chunk) {
      $s = [string]$line
      if ($s -match 'Total parses:\s*(\d+);\s*successful parses:\s*(\d+);\s*failed parses:\s*(\d+)') {
        $total += [int]$Matches[1]; $ok += [int]$Matches[2]
      } elseif ($s -match 'ERROR|MISSING') {
        $failLines += $s
        $firstErr = if ($s -match '((ERROR|MISSING)[^)]*\[[^\]]+\]\s*-\s*\[[^\]]+\])') { $Matches[1] } else { 'ERROR' }
        $fp = ($s -split "`t")[0].Trim()
        "FAIL  $fp  ->  $firstErr"
      }
    }
  }
} finally {
  Remove-Item $listFile -Force -ErrorAction SilentlyContinue
}

$bad = $total - $ok
""
if ($total -gt 0) {
  ("TOTAL {0}  OK {1}  FAIL {2}  SUCCESS {3:N2}%" -f $total, $ok, $bad, ($ok * 100.0 / $total))
}
if ($Out -and $failLines.Count -gt 0) {
  $failLines | Set-Content $Out -Encoding UTF8
  "failures written: $Out"
}
exit $(if ($bad -eq 0) { 0 } else { 2 })
