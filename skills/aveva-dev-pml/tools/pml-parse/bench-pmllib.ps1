<#
.SYNOPSIS
  Re-run the parser-coverage benchmark against the bundled PMLLIB snapshot.
.DESCRIPTION
  Sanity gate for the bundled parser (bin\pml.dll). Parses the delivered PMLLIB
  snapshot shipped at ../../PMLLIB with the bundled tree-sitter CLI.
  Reference baseline (parser built from tree-sitter-pml @ 94.02%, 2026-10-27,
  adds ui_control_type keyword `numericinput` + $P print_statement):
      TOTAL 6075  OK 5712  FAIL 363  SUCCESS 94.02%
  (previous 93.61% baseline: FAIL 388; diff = 25 rescued, 0 regressions)
  A regression here means the DLL was swapped/built from a different grammar.
  Known failure taxonomy (do not chase): unterminated quotes glued to code,
  `*/` comment tails, `$!<arr[$!i].x>` eval-with-subscript, `=0/0` placeholders
  -- see tree-sitter-pml docs/offline-workflow.md section 8 and
  README.md "Still-failing taxonomy".
.EXAMPLE
  .\bench-pmllib.ps1                       # benchmark the bundled snapshot
  .\bench-pmllib.ps1 -Corpus D:\other\PMLLIB
#>
[CmdletBinding()]
param(
  [string]$Corpus,
  [string]$Out
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$skillRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not $Corpus) { $Corpus = Join-Path $skillRoot 'PMLLIB' }
if (-not (Test-Path $Corpus)) { throw "corpus not found: $Corpus" }

$tsExe     = Join-Path $PSScriptRoot 'bin\tree-sitter.exe'
$parserDll = Join-Path $PSScriptRoot 'bin\pml.dll'
if (-not (Test-Path $tsExe))     { throw "missing $tsExe" }
if (-not (Test-Path $parserDll)) { throw "missing $parserDll" }

$exts = @('*.pmlobj', '*.pmlfnc', '*.pmlfrm', '*.pmlmac', '*.mac')
$all = @(Get-ChildItem $Corpus -Recurse -File -Include $exts | ForEach-Object { $_.FullName })
"corpus files: $($all.Count)"

$total = 0; $ok = 0; $failLines = @()
$listFile = Join-Path ([System.IO.Path]::GetTempPath()) ("pmlbench-{0}.txt" -f [guid]::NewGuid())
try {
  for ($start = 0; $start -lt $all.Count; $start += 600) {
    $end = [Math]::Min($start + 599, $all.Count - 1)
    [System.IO.File]::WriteAllLines($listFile, $all[$start..$end], (New-Object System.Text.UTF8Encoding($false)))
    # Merge stderr via cmd. NB: do NOT name the loop source $out -- PowerShell
    # names are case-insensitive, the assignment would hit the [string]$Out
    # parameter, whose type constraint flattens the array into one joined
    # string and the per-file ERROR lines vanish (real bug, seen in testing).
    $chunk = & cmd /c "`"$tsExe`" parse -l `"$parserDll`" --lang-name pml -q --stat --paths `"$listFile`" 2>&1"
    $chunk = ($chunk | Out-String) -split '\r?\n'
    foreach ($line in $chunk) {
      $s = [string]$line
      if ($s -match 'Total parses:\s*(\d+);\s*successful parses:\s*(\d+);\s*failed parses:\s*(\d+)') {
        $total += [int]$Matches[1]; $ok += [int]$Matches[2]
      } elseif ($s -match 'ERROR|MISSING') { $failLines += $s }
    }
  }
} finally {
  Remove-Item $listFile -Force -ErrorAction SilentlyContinue
}

$bad = $total - $ok
if ($total -gt 0) {
  ("TOTAL {0}  OK {1}  FAIL {2}  SUCCESS {3:N2}%" -f $total, $ok, $bad, ($ok * 100.0 / $total))
}
"--- failure by extension ---"
$failLines | ForEach-Object { [System.IO.Path]::GetExtension((($_ -split "`t")[0]).Trim()) } |
  Group-Object | Sort-Object Count -Descending | ForEach-Object { "  {0,-9} {1}" -f $_.Name, $_.Count }
if ($Out) {
  $failLines | Set-Content $Out -Encoding UTF8
  "failures written: $Out"
}
