<#
.SYNOPSIS
  Build a queryable code graph for PML sources using the bundled tree-sitter grammar.
.DESCRIPTION
  Extracts definitions, calls, callbacks, interop and CDB path references from
  PML 1 / PML 2 sources and writes a deterministic graph (gzipped TSV) plus a small
  JSON metadata file. Reuses tools/pml-parse/bin/{tree-sitter.exe,pml.dll} -- no
  node, compiler, network or Graphviz required.

  Per chunk the builder runs:
      tree-sitter.exe query queries/pml-graph.scm -l pml.dll --lang-name pml --paths <list>
  and redirects through cmd, because a PowerShell '>' on 5.1 writes UTF-16LE and
  would corrupt the captured callback text of any non-ASCII source.

  Output is deterministic (fixed ordering, no timestamps), so rebuilding the same
  snapshot twice yields identical bytes and -Check can detect drift.
.EXAMPLE
  .\build-pml-graph.ps1
.EXAMPLE
  .\build-pml-graph.ps1 -Check
.EXAMPLE
  .\build-pml-graph.ps1 -Source D:\work\app -Out D:\work\graph
.OUTPUTS
  Exit 0 = success / no drift, 2 = -Check found drift or a resolution floor missed.
#>
[CmdletBinding()]
param(
  [string]$Source,
  [string]$Out,
  [switch]$Check,
  [int]$ChunkSize = 3000,
  [double]$MinCallResolution = 0.95,
  [double]$MinCallbackResolution = 0.95
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$GRAPH_SCHEMA = 1

$skillRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not $Source) { $Source = Join-Path $skillRoot 'PMLLIB' }
if (-not $Out)    { $Out    = Join-Path $skillRoot 'graph' }
$Source = (Resolve-Path $Source).Path
$graphFile = Join-Path $Out 'pml-graph.tsv.gz'
$metaFile  = Join-Path $Out 'pml-graph.meta.json'

$tsExe     = Join-Path $PSScriptRoot '..\pml-parse\bin\tree-sitter.exe'
$parserDll = Join-Path $PSScriptRoot '..\pml-parse\bin\pml.dll'
$queryFile = Join-Path $PSScriptRoot 'queries\pml-graph.scm'
foreach ($f in @($tsExe, $parserDll, $queryFile)) {
  if (-not (Test-Path $f)) { throw "missing $f" }
}
$tsExe     = (Resolve-Path $tsExe).Path
$parserDll = (Resolve-Path $parserDll).Path
$queryFile = (Resolve-Path $queryFile).Path

$exts = @('.pml', '.pmlfnc', '.pmlobj', '.pmlfrm', '.pmlmac', '.mac')
$files = @(Get-ChildItem $Source -Recurse -File |
  Where-Object { $exts -contains $_.Extension.ToLower() } |
  Sort-Object FullName | ForEach-Object { $_.FullName })
if ($files.Count -eq 0) { throw "no PML source files under $Source" }

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$TAB = [char]9
$NL  = "`n"

# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------
$nameRe       = [regex]'^(?:!!|!|\.)?([A-Za-z0-9_]+)'
$cbGlobalRe   = [regex]'!!([A-Za-z_][A-Za-z0-9_]*)\s*\('
$cbThisCallRe = [regex]'!this\.([A-Za-z_][A-Za-z0-9_]*)\s*\('
$cbThisRefRe  = [regex]'!this\.([A-Za-z_][A-Za-z0-9_]*)'

function Get-Rel([string]$full) {
  $f = $full.Trim()
  if ($f.StartsWith($Source, [StringComparison]::OrdinalIgnoreCase)) {
    return ($f.Substring($Source.Length).TrimStart('\', '/') -replace '\\', '/')
  }
  return ($f -replace '\\', '/')
}

$nameCache = @{}
function Clean-Name([string]$s) {
  if (-not $s) { return '' }
  $hit = $nameCache[$s]
  if ($null -ne $hit) { return $hit }
  $t = $s.Trim()
  $m = $nameRe.Match($t)
  if ($m.Success) { $r = $m.Groups[1].Value.ToLower() }
  else { $r = ($t.ToLower() -replace '[^a-z0-9_]', '_') }
  $nameCache[$s] = $r
  return $r
}

function Clean-Cell([string]$s) {
  if ($null -eq $s) { return '' }
  if ($s.IndexOf($TAB) -lt 0) { return $s.Trim() }
  return ($s -replace "`t", ' ').Trim()
}

# ---------------------------------------------------------------------------
# 1. query pass -> normalised rows in a temp file
# ---------------------------------------------------------------------------
#   D  rel  row  erow  kind  raw-name          definition
#   E  rel  row  kind  text                   simple reference
#   G  rel  row  uiType  uiName  callback     gadget + callback literal
#   C  rel  row  clause  callback             form-level clause (init/okcall/...)
#   M  rel  row  obj  prop  read|write        global member access
#   A  rel  row  name                         $LABEL target
#   R  rel  row  dollar  arg                  $GOTO and friends
#   X  rel                                    file contains (ERROR) nodes
#
# Rows are grouped per file (the CLI emits file headers), and the whole pass is
# written with plain locals -- a hashtable or function call per capture roughly
# doubles the runtime under PowerShell 5.1.
$capRe  = [regex]'^\s{4}capture: (?:\d+ - )?([\w.]+), start: \((\d+), (\d+)\), end: \((\d+), (\d+)\)(?:, text: `(.*)`)?\r?$'
$normFile = Join-Path ([System.IO.Path]::GetTempPath()) ("pmlgraph-norm-{0}.tsv" -f [guid]::NewGuid())
$tmpList  = Join-Path ([System.IO.Path]::GetTempPath()) ("pmlgraph-{0}.txt" -f [guid]::NewGuid())
$tmpOut   = Join-Path ([System.IO.Path]::GetTempPath()) ("pmlgraph-{0}.out" -f [guid]::NewGuid())

$swBuild = [Diagnostics.Stopwatch]::StartNew()
$norm    = New-Object System.IO.StreamWriter($normFile, $false, $utf8NoBom)
$counters = @{ def = 0; gadget = 0; clause = 0; member = 0; label = 0; goto = 0; error = 0; ref = 0 }

try {
  for ($start = 0; $start -lt $files.Count; $start += $ChunkSize) {
    $end = [Math]::Min($start + $ChunkSize - 1, $files.Count - 1)
    [System.IO.File]::WriteAllLines($tmpList, $files[$start..$end], $utf8NoBom)
    & cmd /c "`"$tsExe`" query `"$queryFile`" -l `"$parserDll`" --lang-name pml --paths `"$tmpList`" > `"$tmpOut`" 2>nul"
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 1) {
      throw "tree-sitter query failed for the chunk starting at file #$start (exit $LASTEXITCODE)"
    }

    $reader = [System.IO.File]::OpenText($tmpOut)
    $curRel = ''
    # one slot block reused for every match; sniffed by the capture-name switch
    $sDefKind = ''; $sDefRow = 0; $sDefEr = 0; $sDefName = ''
    $sUiName = ''; $sUiRow = 0; $sUiType = ''; $sUiCb = ''
    $sCmdName = ''; $sCmdRow = 0; $sCmdStr = ''
    $sDollar = ''; $sDollarRow = 0; $sDollarArg = ''
    $sGmObj = ''; $sGmProp = ''; $sGmWrite = $false; $sGmRow = 0
    $sSingle = ''; $sSingleRow = 0; $sSingleText = ''
    $sErr = $false
    $pending = $false
    try {
      while ($null -ne ($line = $reader.ReadLine())) {
        if ($line.Length -eq 0) { continue }
        $isHeader = $false
        $isPattern = $false
        if ($line[0] -ne ' ') { $isHeader = $true }
        elseif ($line.Length -gt 2 -and $line[2] -eq 'p') { $isPattern = $true }

        if ($isHeader -or $isPattern) {
          # emit whatever the accumulated slots describe, then reset
          if ($pending -and $curRel) {
            if ($sDefKind) {
              $norm.WriteLine('D'+$TAB+$curRel+$TAB+$sDefRow+$TAB+$sDefEr+$TAB+$sDefKind+$TAB+$sDefName)
              $counters['def'] = $counters['def'] + 1
            } elseif ($sUiName) {
              $norm.WriteLine('G'+$TAB+$curRel+$TAB+$sUiRow+$TAB+$sUiType+$TAB+$sUiName+$TAB+$sUiCb)
              $counters['gadget'] = $counters['gadget'] + 1
            } elseif ($sCmdName) {
              $norm.WriteLine('C'+$TAB+$curRel+$TAB+$sCmdRow+$TAB+$sCmdName+$TAB+$sCmdStr)
              $counters['clause'] = $counters['clause'] + 1
            } elseif ($sDollar) {
              if ($sDollar -eq '$LABEL') {
                $norm.WriteLine('A'+$TAB+$curRel+$TAB+$sDollarRow+$TAB+$sDollarArg)
                $counters['label'] = $counters['label'] + 1
              } elseif ($sDollar -eq '$GOTO') {
                $norm.WriteLine('R'+$TAB+$curRel+$TAB+$sDollarRow+$TAB+$sDollar+$TAB+$sDollarArg)
                $counters['goto'] = $counters['goto'] + 1
              }
            } elseif ($sGmObj) {
              $o = Clean-Name $sGmObj
              $p = Clean-Name $sGmProp
              if ($o -and $p) {
                $mode = 'read'
                if ($sGmWrite) { $mode = 'write' }
                $norm.WriteLine('M'+$TAB+$curRel+$TAB+$sGmRow+$TAB+$o+$TAB+$p+$TAB+$mode)
                $counters['member'] = $counters['member'] + 1
              }
            } elseif ($sErr) {
              $norm.WriteLine('X'+$TAB+$curRel)
              $counters['error'] = $counters['error'] + 1
            } elseif ($sSingle) {
              $norm.WriteLine('E'+$TAB+$curRel+$TAB+$sSingleRow+$TAB+$sSingle+$TAB+$sSingleText)
              $counters['ref'] = $counters['ref'] + 1
            }
            $sDefKind = ''; $sDefName = ''
            $sUiName = ''; $sUiType = ''; $sUiCb = ''
            $sCmdName = ''; $sCmdStr = ''
            $sDollar = ''; $sDollarArg = ''
            $sGmObj = ''; $sGmProp = ''; $sGmWrite = $false
            $sSingle = ''; $sSingleText = ''
            $sErr = $false
            $pending = $false
          }
          if ($isHeader) { $curRel = Get-Rel $line }
          continue
        }

        $m = $capRe.Match($line)
        if (-not $m.Success) { continue }
        $pending = $true
        $tx = ''
        if ($m.Groups[6].Success) { $tx = $m.Groups[6].Value }
        $rw = [int]$m.Groups[2].Value
        switch ($m.Groups[1].Value) {
          # The name node gives the identity; the matching @span.* node (same
          # match, no text because it is multi-line) gives the body extent.
          'def.function' { $sDefKind = 'function'; $sDefName = $tx }
          'def.object'   { $sDefKind = 'object';   $sDefName = $tx }
          'def.form'     { $sDefKind = 'form';     $sDefName = $tx }
          'def.method'   { $sDefKind = 'method';   $sDefName = $tx }
          'span.function' { $sDefRow = $rw; $sDefEr = [int]$m.Groups[4].Value }
          'span.object'   { $sDefRow = $rw; $sDefEr = [int]$m.Groups[4].Value }
          'span.form'     { $sDefRow = $rw; $sDefEr = [int]$m.Groups[4].Value }
          'span.method'   { $sDefRow = $rw; $sDefEr = [int]$m.Groups[4].Value }
          'ui.name'      { $sUiName = $tx; $sUiRow = $rw }
          'ui.type'      { $sUiType = $tx }
          'ui.callback'  { $sUiCb = $tx }
          'cmd.name'     { $sCmdName = $tx.ToLower(); $sCmdRow = $rw }
          'cmd.string'   { $sCmdStr = $tx }
          'cmd.dollar'   { $sDollar = $tx.ToUpper(); $sDollarRow = $rw }
          'cmd.arg'      { $sDollarArg = $tx }
          'gm.object'    { $sGmObj = $tx; $sGmRow = $rw }
          'gm.property'  { $sGmProp = $tx }
          'mark.write'   { $sGmWrite = $true }
          'parse.error'  { $sErr = $true }
          'member'       { $sSingle = 'member_decl'; $sSingleRow = $rw; $sSingleText = $tx }
          'ref.global'   { $sSingle = 'call';    $sSingleRow = $rw; $sSingleText = $tx }
          'ref.builtin'  { $sSingle = 'builtin'; $sSingleRow = $rw; $sSingleText = $tx }
          'ref.dbpath'   { $sSingle = 'dbpath';  $sSingleRow = $rw; $sSingleText = $tx }
          'import.dll'   { $sSingle = 'dll';     $sSingleRow = $rw; $sSingleText = $tx }
          'import.namespace' { $sSingle = 'ns';  $sSingleRow = $rw; $sSingleText = $tx }
          'ref.new.type' { $sSingle = 'new';     $sSingleRow = $rw; $sSingleText = $tx }
        }
      }
      # trailing match at end of chunk
      if ($pending -and $curRel) {
        if ($sDefKind) {
          $norm.WriteLine('D'+$TAB+$curRel+$TAB+$sDefRow+$TAB+$sDefEr+$TAB+$sDefKind+$TAB+$sDefName)
          $counters['def'] = $counters['def'] + 1
        } elseif ($sUiName) {
          $norm.WriteLine('G'+$TAB+$curRel+$TAB+$sUiRow+$TAB+$sUiType+$TAB+$sUiName+$TAB+$sUiCb)
          $counters['gadget'] = $counters['gadget'] + 1
        } elseif ($sCmdName) {
          $norm.WriteLine('C'+$TAB+$curRel+$TAB+$sCmdRow+$TAB+$sCmdName+$TAB+$sCmdStr)
          $counters['clause'] = $counters['clause'] + 1
        } elseif ($sDollar) {
          if ($sDollar -eq '$LABEL') {
            $norm.WriteLine('A'+$TAB+$curRel+$TAB+$sDollarRow+$TAB+$sDollarArg)
            $counters['label'] = $counters['label'] + 1
          } elseif ($sDollar -eq '$GOTO') {
            $norm.WriteLine('R'+$TAB+$curRel+$TAB+$sDollarRow+$TAB+$sDollar+$TAB+$sDollarArg)
            $counters['goto'] = $counters['goto'] + 1
          }
        } elseif ($sGmObj) {
          $o = Clean-Name $sGmObj
          $p = Clean-Name $sGmProp
          if ($o -and $p) {
            $mode = 'read'
            if ($sGmWrite) { $mode = 'write' }
            $norm.WriteLine('M'+$TAB+$curRel+$TAB+$sGmRow+$TAB+$o+$TAB+$p+$TAB+$mode)
            $counters['member'] = $counters['member'] + 1
          }
        } elseif ($sErr) {
          $norm.WriteLine('X'+$TAB+$curRel)
          $counters['error'] = $counters['error'] + 1
        } elseif ($sSingle) {
          $norm.WriteLine('E'+$TAB+$curRel+$TAB+$sSingleRow+$TAB+$sSingle+$TAB+$sSingleText)
          $counters['ref'] = $counters['ref'] + 1
        }
      }
    } finally { $reader.Close() }
  }
} finally {
  $norm.Close()
  Remove-Item $tmpList, $tmpOut -Force -ErrorAction SilentlyContinue
  # the CLI drops a stub log.html into the CWD while initialising its config
  Remove-Item (Join-Path (Get-Location).Path 'log.html') -Force -ErrorAction SilentlyContinue
}
$phaseQuery = $swBuild.Elapsed.TotalSeconds

# ---------------------------------------------------------------------------
# 2. read the normalised rows back, grouped per file
# ---------------------------------------------------------------------------
$rowsByFile = @{}                    # rel -> List[string[]]
$relOrder   = New-Object System.Collections.Generic.List[string]
$reader = [System.IO.File]::OpenText($normFile)
try {
  while ($null -ne ($line = $reader.ReadLine())) {
    $f = $line.Split($TAB)
    $rel = $f[1]
    if (-not $rowsByFile.ContainsKey($rel)) {
      $rowsByFile[$rel] = New-Object System.Collections.Generic.List[object]
      $relOrder.Add($rel)
    }
    $rowsByFile[$rel].Add($f)
  }
} finally { $reader.Close() }
$phaseRead = $swBuild.Elapsed.TotalSeconds - $phaseQuery

# ---------------------------------------------------------------------------
# 3. definitions -> nodes, and a per-file owner lookup table
# ---------------------------------------------------------------------------
$nodeLines = New-Object System.Collections.Generic.List[string]
$nodeIds   = New-Object System.Collections.Generic.HashSet[string]
$fileContainer = @{}                 # rel -> container node id (object/form)
$defsByFile = @{}                    # rel -> sorted defs
$maxRowByFile = @{}

function Add-Node([string]$id, [string]$kind, [string]$file, [int]$line, [string]$name, [string]$flags) {
  if ($nodeIds.Add($id)) {
    $nodeLines.Add('N' + $TAB + $kind + $TAB + $id + $TAB + $file + $TAB + $line + $TAB + $name + $TAB + $flags)
  }
}

$errorFiles = New-Object System.Collections.Generic.HashSet[string]
foreach ($rel in $relOrder) {
  $defs = New-Object System.Collections.Generic.List[object]
  $maxRow = 0
  foreach ($f in $rowsByFile[$rel]) {
    if ($f[0] -eq 'D') {
      $defs.Add([pscustomobject]@{
        row = [int]$f[2]; erow = [int]$f[3]; kind = $f[4]; raw = $f[5]; name = (Clean-Name $f[5])
      })
      if ([int]$f[3] -gt $maxRow) { $maxRow = [int]$f[3] }
    } elseif ($f[0] -eq 'X') {
      [void]$errorFiles.Add($rel)
    }
  }
  $sorted = @($defs | Sort-Object row, @{Expression = 'erow'; Descending = $true})
  $defsByFile[$rel] = $sorted
  $maxRowByFile[$rel] = $maxRow + 1

  # A file holds at most one object/form definition; its methods may sit inside it
  # or after its `endobject` / `endform` (verified in abadefaults.pmlobj and
  # abaarea.pmlfrm), so the container is remembered per file, not per span.
  foreach ($d in $sorted) {
    if ($d.kind -eq 'function') {
      Add-Node ($rel + '#' + $d.name) 'function' $rel ($d.row + 1) $d.name ''
    } elseif ($d.kind -eq 'object') {
      Add-Node ($rel + '#' + $d.name) 'object' $rel ($d.row + 1) $d.name ''
      $fileContainer[$rel] = $rel + '#' + $d.name
    } elseif ($d.kind -eq 'form') {
      Add-Node ($rel + '#' + $d.name) 'form' $rel ($d.row + 1) $d.name ''
      $fileContainer[$rel] = $rel + '#' + $d.name
    } elseif ($d.kind -eq 'method') {
      $flag = ''
      $container = $fileContainer[$rel]
      if (-not $container) {
        $stem = Clean-Name ([System.IO.Path]::GetFileNameWithoutExtension($rel))
        $container = $rel + '#' + $stem
        $fileContainer[$rel] = $container
        $flag = 'orphan-method'
      }
      $id = $container + '.' + $d.name
      $k2 = 2
      while ($nodeIds.Contains($id)) {
        # PML overloads by parameter list: 1562 (file, method) pairs repeat
        $id = $container + '.' + $d.name + '~' + $k2
        $flag = 'overload'
        $k2++
      }
      Add-Node $id 'method' $rel ($d.row + 1) $d.name $flag
      $d | Add-Member -NotePropertyName id -NotePropertyValue $id -Force
    }
  }
}

# ---------------------------------------------------------------------------
# 4. global name -> declaring files (file basename AND declared name, both aliases)
# ---------------------------------------------------------------------------
$nameToFiles = @{}
foreach ($rel in $relOrder) {
  $base = [System.IO.Path]::GetFileNameWithoutExtension($rel).ToLower()
  if (-not $nameToFiles.ContainsKey($base)) { $nameToFiles[$base] = New-Object System.Collections.Generic.List[string] }
  if (-not $nameToFiles[$base].Contains($rel)) { $nameToFiles[$base].Add($rel) }
  foreach ($d in $defsByFile[$rel]) {
    if ($d.name -and $d.kind -ne 'method') {
      if (-not $nameToFiles.ContainsKey($d.name)) { $nameToFiles[$d.name] = New-Object System.Collections.Generic.List[string] }
      if (-not $nameToFiles[$d.name].Contains($rel)) { $nameToFiles[$d.name].Add($rel) }
    }
  }
}

# memoised: a handful of helpers (kRestoreUnits, mdsdacControl, ...) accounts for
# most call sites, so a cache removes nearly all repeated resolution work.
# Returns a string[] (not a List): PowerShell unrolls a List returned from a
# function into the pipeline, so a caller doing $targets[0] would index into the
# first *string* and silently get a single character.
$resolveCache = @{}
function Resolve-Global([string]$name) {
  $cached = $resolveCache[$name]
  if ($null -ne $cached) { return ,$cached }
  $out = New-Object System.Collections.Generic.List[string]
  if ($nameToFiles.ContainsKey($name)) {
    foreach ($rel in $nameToFiles[$name]) {
      $base = [System.IO.Path]::GetFileNameWithoutExtension($rel).ToLower()
      if ($base -eq $name) { $out.Add($rel + '#' + $name); continue }
      foreach ($d in $defsByFile[$rel]) {
        if ($d.name -eq $name -and $d.kind -ne 'method') { $out.Add($rel + '#' + $name); break }
      }
    }
  }
  $arr = $out.ToArray()
  $resolveCache[$name] = $arr
  return ,$arr
}

# ---------------------------------------------------------------------------
# 5. edges
# ---------------------------------------------------------------------------
$edgeLines = New-Object System.Collections.Generic.List[string]
$edgeSeen  = New-Object System.Collections.Generic.HashSet[string]
$stats     = [ordered]@{
  calls_global = 0; calls_unresolved = 0; calls_builtin = 0
  reads_global = 0; writes_global = 0
  touches_cdbpath = 0; instantiates = 0
  imports_dll = 0; uses_namespace = 0
  callback_invokes = 0; form_hook = 0
  member_of = 0; goto_label = 0
}
$unresolvedNames = New-Object System.Collections.Generic.HashSet[string]
$cbStat = @{ total = 0; resolved = 0; unresolved = 0; thisRefs = 0 }

function Add-Edge([string]$type, [string]$src, [string]$dst, [string]$file, [int]$line, [string]$detail) {
  if (-not $src -or -not $dst -or $src -eq $dst) { return }
  # One edge per (type, caller, callee, call site): a helper called twice from the
  # same routine remains two sites, so -WhoCalls reports every location.
  if (-not $edgeSeen.Add($type + $TAB + $src + $TAB + $dst + $TAB + $file + ':' + $line)) { return }
  if ($stats.Contains($type)) { $stats[$type] = $stats[$type] + 1 }
  $edgeLines.Add('E' + $TAB + $type + $TAB + $src + $TAB + $dst + $TAB + $file + $TAB + $line + $TAB + (Clean-Cell $detail))
}

$phaseNodes = $swBuild.Elapsed.TotalSeconds - $phaseQuery - $phaseRead

foreach ($rel in $relOrder) {
  $defs = $defsByFile[$rel]
  $container = $fileContainer[$rel]
  $maxRow = $maxRowByFile[$rel]

  # ownerByRow[row] = innermost definition containing that row. Filled
  # outer-to-inner (defs are sorted by row asc, erow desc) so the last writer wins.
  $ownerByRow = New-Object 'object[]' $maxRow
  foreach ($d in $defs) {
    $id = $d.id
    if (-not $id) { $id = $rel + '#' + $d.name }
    $last = $d.erow
    if ($last -ge $maxRow) { $last = $maxRow - 1 }
    for ($r = $d.row; $r -le $last; $r++) { $ownerByRow[$r] = $id }
  }
  $fallbackOwner = $container
  if (-not $fallbackOwner) { $fallbackOwner = $rel }

  $gadgetRows = New-Object System.Collections.Generic.List[object]
  foreach ($f in $rowsByFile[$rel]) {
    $tag = $f[0]
    if ($tag -eq 'D' -or $tag -eq 'X') { continue }
    $row = [int]$f[2]
    $owner = $fallbackOwner
    if ($row -lt $maxRow -and $null -ne $ownerByRow[$row]) { $owner = $ownerByRow[$row] }

    if ($tag -eq 'M') {
      $dst = 'global:' + $f[3] + '.' + $f[4]
      if ($f[5] -eq 'write') { Add-Edge 'writes_global' $owner $dst $rel ($row + 1) ($f[3] + '.' + $f[4]) }
      else { Add-Edge 'reads_global' $owner $dst $rel ($row + 1) ($f[3] + '.' + $f[4]) }
      continue
    }
    if ($tag -eq 'G') {
      $gadgetRows.Add($f)
      if ($f[4]) {
        $nm = Clean-Name $f[4]
        Add-Node ($owner + '::' + $nm) 'gadget' $rel ($row + 1) $nm $f[3]
      }
      continue
    }
    if ($tag -eq 'A') {
      $nm = Clean-Cell $f[3]
      if ($nm) { Add-Node ($rel + '@label:' + $nm.ToLower()) 'label' $rel ($row + 1) $nm '' }
      continue
    }
    if ($tag -eq 'C') {
      $clause = $f[3]
      if ($clause -notmatch '^(init|initcall|okcall|cancelcall|applycall)$') { continue }
      $txt = ''
      if ($f.Length -gt 4) { $txt = $f[4] }
      foreach ($mm in $cbThisCallRe.Matches($txt)) {
        $n = $mm.Groups[1].Value.ToLower()
        $candidate = $container + '.' + $n
        $dst = 'unresolved:this.' + $n
        if ($nodeIds.Contains($candidate)) { $dst = $candidate }
        Add-Edge 'form_hook' $owner $dst $rel ($row + 1) ($clause + ' ' + $txt)
      }
      continue
    }
    if ($tag -eq 'R') {
      $nm = (Clean-Cell $f[4]).ToLower()
      if (-not $nm) { continue }
      Add-Edge 'goto_label' $owner ($rel + '@label:' + $nm) $rel ($row + 1) ($f[3] + ' ' + $f[4])
      continue
    }
    if ($tag -eq 'E') {
      $kind = $f[3]; $text = $f[4]
      if ($kind -eq 'member_decl') {
        $nm = Clean-Name $text
        if ($container -and $nm) {
          $mid = $container + '.' + $nm
          Add-Node $mid 'member' $rel ($row + 1) $nm ''
          Add-Edge 'member_of' $container $mid $rel ($row + 1) $nm
        }
        continue
      }
      if ($kind -eq 'call') {
        $n = Clean-Name $text
        if (-not $n) { continue }
        $targets = Resolve-Global $n
        if ($targets.Count -gt 0) {
          $detail = $text
          if ($targets.Count -gt 1) { $detail = $text + ' [ambiguous]' }
          foreach ($t in $targets) { Add-Edge 'calls_global' $owner $t $rel ($row + 1) $detail }
        } else {
          Add-Edge 'calls_unresolved' $owner ('unresolved:' + $n) $rel ($row + 1) $text
          [void]$unresolvedNames.Add($n)
        }
        continue
      }
      if ($kind -eq 'builtin') {
        $n = Clean-Name $text
        if ($n) { Add-Edge 'calls_builtin' $owner ('builtin:' + $n) $rel ($row + 1) $text }
        continue
      }
      if ($kind -eq 'dbpath') {
        $p = Clean-Cell $text
        if ($p.StartsWith('/')) { Add-Edge 'touches_cdbpath' $owner ('cdb:' + $p) $rel ($row + 1) $p }
        continue
      }
      if ($kind -eq 'dll') {
        $n = ($text -replace '^[''"]', '' -replace '[''"]$', '').ToLower()
        if ($n) { Add-Edge 'imports_dll' $owner ('dll:' + $n) $rel ($row + 1) $text }
        continue
      }
      if ($kind -eq 'ns') {
        $n = ($text -replace '^[''"]', '' -replace '[''"]$', '').ToLower()
        if ($n) { Add-Edge 'uses_namespace' $owner ('ns:' + $n) $rel ($row + 1) $text }
        continue
      }
      if ($kind -eq 'new') {
        $n = Clean-Name $text
        if ($n) { Add-Edge 'instantiates' $owner ('type:' + $n) $rel ($row + 1) $text }
        continue
      }
    }
  }

  # callbacks: gadget -> the concrete call target(s) named in its callback text
  foreach ($f in $gadgetRows) {
    $raw = $f[5]
    if (-not $raw) { continue }
    $row = [int]$f[2]
    $owner = $fallbackOwner
    if ($row -lt $maxRow -and $null -ne $ownerByRow[$row]) { $owner = $ownerByRow[$row] }
    $gid = $owner + '::' + (Clean-Name $f[4])

    foreach ($mm in $cbGlobalRe.Matches($raw)) {
      $cbStat.total = $cbStat.total + 1
      $n = $mm.Groups[1].Value.ToLower()
      $targets = Resolve-Global $n
      if ($targets.Count -gt 0) {
        $cbStat.resolved = $cbStat.resolved + 1
        Add-Edge 'callback_invokes' $gid $targets[0] $rel ($row + 1) $raw
      } else {
        $cbStat.unresolved = $cbStat.unresolved + 1
        Add-Edge 'callback_invokes' $gid ('unresolved:global.' + $n) $rel ($row + 1) $raw
      }
    }

    foreach ($mm in $cbThisCallRe.Matches($raw)) {
      $cbStat.total = $cbStat.total + 1
      $cbStat.thisRefs = $cbStat.thisRefs + 1
      $n = $mm.Groups[1].Value.ToLower()
      $candidate = $container + '.' + $n
      if ($nodeIds.Contains($candidate)) {
        Add-Edge 'callback_invokes' $gid $candidate $rel ($row + 1) $raw
        $cbStat.resolved = $cbStat.resolved + 1
      } else {
        Add-Edge 'callback_invokes' $gid ('unresolved:this.' + $n) $rel ($row + 1) $raw
        $cbStat.unresolved = $cbStat.unresolved + 1
      }
    }

    # a bare !this.name is a gadget or a declared member of the form, not a method
    foreach ($mm in $cbThisRefRe.Matches($raw)) {
      $rest = $raw.Substring($mm.Index + $mm.Length)
      if ([regex]::IsMatch($rest, '^\s*\(')) { continue }
      $cbStat.total = $cbStat.total + 1
      $cbStat.thisRefs = $cbStat.thisRefs + 1
      $n = $mm.Groups[1].Value.ToLower()
      $hit = $null
      $candidate = $owner + '::' + $n
      if ($nodeIds.Contains($candidate)) { $hit = $candidate }
      else {
        $candidate = $container + '.' + $n
        if ($nodeIds.Contains($candidate)) { $hit = $candidate }
      }
      if ($hit) {
        Add-Edge 'callback_invokes' $gid $hit $rel ($row + 1) $raw
        $cbStat.resolved = $cbStat.resolved + 1
      } else {
        Add-Edge 'callback_invokes' $gid ('unresolved:this-ref.' + $n) $rel ($row + 1) $raw
        $cbStat.unresolved = $cbStat.unresolved + 1
      }
    }
  }
}

# ---------------------------------------------------------------------------
# 6. deterministic output
# ---------------------------------------------------------------------------
$swBuild.Stop()

$nodeSort = New-Object 'System.Collections.Generic.List[string]'
$nodeSort.AddRange($nodeLines)
$nodeSort.Sort([StringComparer]::Ordinal)
$edgeSort = New-Object 'System.Collections.Generic.List[string]'
$edgeSort.AddRange($edgeLines)
$edgeSort.Sort([StringComparer]::Ordinal)

$callTotal = $stats['calls_global'] + $stats['calls_unresolved']
$callRate = 0.0
if ($callTotal -gt 0) { $callRate = [Math]::Round($stats['calls_global'] * 100.0 / $callTotal, 2) }
$cbRate = 0.0
if ($cbStat.total -gt 0) { $cbRate = [Math]::Round($cbStat.resolved * 100.0 / $cbStat.total, 2) }

# source fingerprint: (relative path, size) over the scanned files, so -Check can
# distinguish "same input" from "PMLLIB changed but the counts happened to match".
$fp = New-Object System.Text.StringBuilder
foreach ($f in $files) { $null = $fp.Append((Get-Rel $f)).Append(':').Append((Get-Item $f).Length).Append($NL) }
$sha = [System.Security.Cryptography.SHA256]::Create()
$sourceHash = [Convert]::ToBase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($fp.ToString())))

$kindTally = @{}
foreach ($nl in $nodeSort) {
  $kk = $nl.Split($TAB)[1]
  if ($kindTally.ContainsKey($kk)) { $kindTally[$kk] = $kindTally[$kk] + 1 } else { $kindTally[$kk] = 1 }
}
$nodesByKind = [ordered]@{}
foreach ($kk in ($kindTally.Keys | Sort-Object)) { $nodesByKind[$kk] = $kindTally[$kk] }

if ($Check) {
  if (-not (Test-Path $graphFile)) { Write-Output "DRIFT: graph not built yet ($graphFile)"; exit 2 }
  if (-not (Test-Path $metaFile))  { Write-Output "DRIFT: metadata missing ($metaFile)"; exit 2 }
  $old = (Get-Content $metaFile -Raw) | ConvertFrom-Json
  $bad = @()
  if ($old.schema -ne $GRAPH_SCHEMA) { $bad += "schema $($old.schema) != $GRAPH_SCHEMA" }
  if ($old.sourceHash -ne $sourceHash) { $bad += 'source hash changed (PMLLIB files added / removed / resized)' }
  if ($old.sourceFiles -ne $files.Count) { $bad += "file count $($old.sourceFiles) != $($files.Count)" }
  if ($old.nodeCount -ne $nodeIds.Count) { $bad += "node count $($old.nodeCount) != $($nodeIds.Count)" }
  if ($old.edgeCount -ne $edgeSort.Count) { $bad += "edge count $($old.edgeCount) != $($edgeSort.Count)" }
  if ($bad.Count -gt 0) {
    Write-Output 'DRIFT detected:'
    $bad | ForEach-Object { Write-Output ('  - ' + $_) }
    Write-Output 'run build-pml-graph.ps1 to refresh'
    exit 2
  }
  Write-Output ("OK graph is current: {0} files, {1} nodes, {2} edges" -f $files.Count, $nodeIds.Count, $edgeSort.Count)
  exit 0
}

$meta = [ordered]@{
  schema      = $GRAPH_SCHEMA
  generator   = 'tools/pml-graph/build-pml-graph.ps1'
  grammar     = 'tools/pml-parse/bin/pml.dll (tree-sitter-pml, language ABI 15)'
  cli         = 'tree-sitter 0.27.1'
  sourceRoot  = 'PMLLIB/'
  sourceHash  = $sourceHash
  sourceFiles = $files.Count
  nodeCount   = $nodeIds.Count
  edgeCount   = $edgeSort.Count
  nodesByKind = $nodesByKind
  edgesByType = $stats
  callResolutionPercent     = $callRate
  callbackResolutionPercent = $cbRate
  callbackCalls             = $cbStat.total
  unresolvedGlobals         = @($unresolvedNames | Sort-Object)
  filesWithParseError       = $errorFiles.Count
  matchCounts = $counters
}

$outDir = Split-Path -Parent $graphFile
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }

$fs = [System.IO.File]::Create($graphFile)
try {
  $gz = New-Object System.IO.Compression.GZipStream($fs, [System.IO.Compression.CompressionMode]::Compress)
  try {
    $w = New-Object System.IO.StreamWriter($gz, $utf8NoBom)
    try {
      foreach ($n in $nodeSort) { $w.WriteLine($n) }
      foreach ($e in $edgeSort) { $w.WriteLine($e) }
    } finally { $w.Dispose() }
  } finally { $gz.Dispose() }
} finally { $fs.Dispose() }

[System.IO.File]::WriteAllText($metaFile, ($meta | ConvertTo-Json -Depth 6), $utf8NoBom)

$sizeKB = [Math]::Round((Get-Item $graphFile).Length / 1KB)
Write-Output ("files      : {0}" -f $files.Count)
Write-Output ("nodes      : {0}" -f $nodeIds.Count)
Write-Output ("edges      : {0}" -f $edgeSort.Count)
Write-Output ("call res.  : {0}%" -f $callRate)
Write-Output ("callback   : {0}%  ({1} calls, {2} unresolved)" -f $cbRate, $cbStat.total, $cbStat.unresolved)
Write-Output ("parse errs : {0} files with (ERROR)" -f $errorFiles.Count)
Write-Output ("graph      : {0} ({1} KB)" -f $graphFile, $sizeKB)
Write-Output ("meta       : {0}" -f $metaFile)
Write-Output ("elapsed    : {0:N1}s  (query {1:N1}s, read {2:N1}s, nodes {3:N1}s)" -f $swBuild.Elapsed.TotalSeconds, $phaseQuery, $phaseRead, $phaseNodes)

$fail = $false
if ($callRate -lt ($MinCallResolution * 100)) {
  Write-Output ("FAIL: call resolution {0}% < {1}%" -f $callRate, ($MinCallResolution * 100)); $fail = $true
}
if ($cbStat.total -gt 0 -and $cbRate -lt ($MinCallbackResolution * 100)) {
  Write-Output ("FAIL: callback resolution {0}% < {1}%" -f $cbRate, ($MinCallbackResolution * 100)); $fail = $true
}
if ($fail) { exit 2 }
exit 0
