<#
.SYNOPSIS
  Query the PML code graph produced by build-pml-graph.ps1.
.DESCRIPTION
  Reads graph/pml-graph.tsv.gz (built by build-pml-graph.ps1) and answers
  structural questions about the PML sources without re-parsing them.

  Modes (choose one):
    -WhoCalls <name>        who calls a global function   (!name, !!name or bare)
    -CallsOf <id-or-name>   what a node calls / references
    -CallbacksInto <method> which form gadgets invoke a method
    -FilesForDbPath <path>  which code touches a CDB element path prefix
    -Module <name>          top fan-in / fan-out for a module
    -Find <substring>       look up nodes by id or name

  Lookup contract for -WhoCalls / -CallbacksInto / -CallsOf:
    * A full node id (file#container.method, file::gadget) matches the whole
      id and always wins, in all three modes -- exact first, then a
      case-insensitive retry (ids embed path segments like Forms/).
    * An id-like argument (containing '#' or '::') that matches no node is an
      error -- it is never truncated to a name prefix (the old regex silently
      resolved 'file.pmlobj#obj.method' to a node named 'file').
    * A bare or qualified name ('!!evar', '.dbswitch', 'obj.dbswitch') matches
      node names: qualified names resolve on the LAST dot segment, falling
      back to the first segment only when the last one matches nothing.

  The graph is streamed as raw text lines instead of being materialised as
  objects: a full object load costs ~55 s under PowerShell 5.1, while scanning
  the same lines takes well under a second and every mode needs one pass.
.EXAMPLE
  .\query-graph.ps1 -WhoCalls '!!kRestoreUnits'
.EXAMPLE
  .\query-graph.ps1 -CallbacksInto .setSize
.EXAMPLE
  .\query-graph.ps1 -FilesForDbPath /TT/AssemblyADP
.EXAMPLE
  .\query-graph.ps1 -CallsOf 'aba/Forms/abaarea.pmlfrm#abaarea.name'
.OUTPUTS
  Exit 0 = matches found, 1 = no match, 2 = graph missing / bad usage.
#>
[CmdletBinding(DefaultParameterSetName = 'WhoCalls')]
param(
  [Parameter(ParameterSetName = 'WhoCalls', Mandatory)]
  [string]$WhoCalls,

  [Parameter(ParameterSetName = 'CallsOf', Mandatory)]
  [string]$CallsOf,

  [Parameter(ParameterSetName = 'CallbacksInto', Mandatory)]
  [string]$CallbacksInto,

  [Parameter(ParameterSetName = 'DbPath', Mandatory)]
  [string]$FilesForDbPath,

  [Parameter(ParameterSetName = 'Module', Mandatory)]
  [string]$Module,

  [Parameter(ParameterSetName = 'Find', Mandatory)]
  [string]$Find,

  [string]$Graph,
  [switch]$All,
  [int]$Limit = 40
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$skillRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not $Graph) { $Graph = Join-Path $skillRoot 'graph\pml-graph.tsv.gz' }
if (-not (Test-Path $Graph)) {
  Write-Error "graph not found: $Graph`nrun tools/pml-graph/build-pml-graph.ps1 first"
  exit 2
}
$Graph = (Resolve-Path $Graph).Path
$TAB = [char]9

function Get-Lines([string]$path) {
  $fs = [System.IO.File]::OpenRead($path)
  try {
    $gz = New-Object System.IO.Compression.GZipStream($fs, [System.IO.Compression.CompressionMode]::Decompress)
    try {
      $sr = New-Object System.IO.StreamReader($gz, [System.Text.Encoding]::UTF8)
      try {
        $out = New-Object System.Collections.Generic.List[string]
        while ($null -ne ($line = $sr.ReadLine())) { $out.Add($line) }
        return ,$out
      } finally { $sr.Dispose() }
    } finally { $gz.Dispose() }
  } finally { $fs.Dispose() }
}

function Normalise([string]$s) {
  $t = $s.Trim()
  if ($t -match '^!!([A-Za-z0-9_]+)') { return $Matches[1].ToLower() }
  if ($t -match '^\.([A-Za-z0-9_]+)')  { return $Matches[1].ToLower() }
  if ($t -match '^([A-Za-z0-9_]+)')    { return $Matches[1].ToLower() }
  return $t.ToLower()
}

function Resolve-Targets([string]$s) {
  # Resolve a lookup argument to node indices, shared by -WhoCalls,
  # -CallbacksInto and -CallsOf. Contract (see .SYNOPSIS):
  #   * a full node id (contains '#' or '::') matches EXACTLY -- never
  #     truncated to a name prefix (the pre-fix regex turned
  #     'file.pmlobj#obj.method' into a lookup for 'file');
  #   * a qualified name matches on the LAST dot segment ('!!obj.method' ->
  #     'method', the name callback strings and !!global.member receivers
  #     actually drive), falling back to the first segment only when the
  #     last one matches no node at all.
  $t = $s.Trim()
  $out = New-Object System.Collections.Generic.List[int]
  if ($t.Contains('#') -or $t.Contains('::')) {
    for ($i = 0; $i -lt $nodeId.Count; $i++) {
      if ($nodeId[$i] -ceq $t) { $out.Add($i) }
    }
    if ($out.Count -eq 0) {
      # Node ids embed Windows path segments (Forms/, Objects/) whose case the
      # caller rarely reproduces; PML names are case-insensitive, so retry
      # once without case after the exact pass misses.
      for ($i = 0; $i -lt $nodeId.Count; $i++) {
        if ($nodeId[$i] -ieq $t) { $out.Add($i) }
      }
    }
    return ,$out
  }
  $segs = $null
  if ($t -match '^(?:!!|!|\.)*([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*)$') {
    $segs = $Matches[1].ToLower().Split('.')
  } else {
    $n = Normalise $t
    if ($n) { $segs = @($n) }
  }
  if (-not $segs) { return ,$out }
  $last = $segs[$segs.Length - 1]
  if ($byName.ContainsKey($last)) {
    foreach ($idx in $byName[$last]) { $out.Add($idx) }
    return ,$out
  }
  if ($segs.Length -gt 1 -and $byName.ContainsKey($segs[0])) {
    foreach ($idx in $byName[$segs[0]]) { $out.Add($idx) }
  }
  return ,$out
}

function No-Match([string]$s) {
  $t = $s.Trim()
  if ($t.Contains('#') -or $t.Contains('::')) {
    Write-Output "no node with id '$t' - ids must match exactly (look one up with -Find)"
  } else {
    Write-Output "no node named '$s' in the graph"
  }
  exit 1
}

function Show-Hits($hits, [int]$limit, [bool]$all, [scriptblock]$fmt) {
  $n = $hits.Count
  $shown = 0
  foreach ($h in $hits) {
    $shown++
    if (-not $all -and $shown -gt $limit) {
      Write-Output ("  ... {0} more; use -All for the full list" -f ($n - $limit))
      break
    }
    Write-Output (& $fmt $h)
  }
}

$lines = Get-Lines $Graph

# Node tables are plain arrays keyed by row index: a PML method named "keys" or
# "count" would shadow $hash.Keys / $hash.Count, so hash keys are never enumerated.
$nodeId   = New-Object System.Collections.Generic.List[string]
$nodeName = New-Object System.Collections.Generic.List[string]
$nodeKind = New-Object System.Collections.Generic.List[string]
$nodeFile = New-Object System.Collections.Generic.List[string]
$nodeLine = New-Object System.Collections.Generic.List[int]
$byName   = @{}        # name -> List[int] (node indices)

$edgeLines = New-Object System.Collections.Generic.List[string]

foreach ($line in $lines) {
  if ($line.Length -lt 2) { continue }
  if ($line[0] -ceq 'N') {
    $p = $line.Split($TAB)
    if ($p.Length -lt 6) { continue }
    $idx = $nodeId.Count
    $nodeId.Add($p[2]); $nodeKind.Add($p[1]); $nodeFile.Add($p[3]); $nodeLine.Add([int]$p[4]); $nodeName.Add($p[5])
    if (-not $byName.ContainsKey($p[5])) { $byName[$p[5]] = New-Object System.Collections.Generic.List[int] }
    $byName[$p[5]].Add($idx)
  } else {
    $edgeLines.Add($line)
  }
}
$lines = $null

switch ($PScmdlet.ParameterSetName) {

  'WhoCalls' {
    $idxs = Resolve-Targets $WhoCalls
    if ($idxs.Count -eq 0) { No-Match $WhoCalls }
    $ids = New-Object System.Collections.Generic.HashSet[string]
    foreach ($idx in $idxs) { [void]$ids.Add($nodeId[$idx]) }
    $hits = New-Object System.Collections.Generic.List[object]
    foreach ($e in $edgeLines) {
      $p = $e.Split($TAB)
      if ($ids.Contains($p[3])) { $hits.Add($p) }
    }
    if ($hits.Count -eq 0) { Write-Output "no inbound edges for '$WhoCalls'"; exit 1 }
    Write-Output ("inbound edges for {0}: {1}" -f $WhoCalls, $hits.Count)
    Show-Hits $hits $Limit $All.IsPresent {
      param($p)
      "  {0,-20} {1}:{2}  caller {3}" -f $p[1], $p[4], $p[5], $p[2]
    }
    break
  }

  'CallsOf' {
    $idxs = Resolve-Targets $CallsOf
    if ($idxs.Count -eq 0) { No-Match $CallsOf }
    $ids = New-Object System.Collections.Generic.HashSet[string]
    foreach ($idx in $idxs) { [void]$ids.Add($nodeId[$idx]) }
    $hits = New-Object System.Collections.Generic.List[object]
    foreach ($e in $edgeLines) {
      $p = $e.Split($TAB)
      if ($ids.Contains($p[2])) { $hits.Add($p) }
    }
    if ($hits.Count -eq 0) { Write-Output "no outgoing edges for '$CallsOf'"; exit 1 }
    Write-Output ("outgoing edges for {0}: {1}" -f $CallsOf, $hits.Count)
    Show-Hits $hits $Limit $All.IsPresent {
      param($p)
      "  {0,-20} -> {1}  ({2}:{3})  {4}" -f $p[1], $p[3], $p[4], $p[5], $p[6]
    }
    break
  }

  'CallbacksInto' {
    $idxs = Resolve-Targets $CallbacksInto
    if ($idxs.Count -eq 0) { No-Match $CallbacksInto }
    $ids = New-Object System.Collections.Generic.HashSet[string]
    foreach ($idx in $idxs) { [void]$ids.Add($nodeId[$idx]) }
    $hits = New-Object System.Collections.Generic.List[object]
    foreach ($e in $edgeLines) {
      $p = $e.Split($TAB)
      if ($p[1] -ne 'callback_invokes' -and $p[1] -ne 'form_hook') { continue }
      if ($ids.Contains($p[3])) { $hits.Add($p) }
    }
    if ($hits.Count -eq 0) { Write-Output "no callbacks/form hooks into '$CallbacksInto'"; exit 1 }
    Write-Output ("hooks into $CallbacksInto : {0}" -f $hits.Count)
    Show-Hits $hits $Limit $All.IsPresent {
      param($p)
      "  {0}:{1}  {2,-20} {3}" -f $p[4], $p[5], $p[1], $p[6]
    }
    break
  }

  'DbPath' {
    $want = $FilesForDbPath.Trim().ToLower()
    $hits = New-Object System.Collections.Generic.List[object]
    foreach ($e in $edgeLines) {
      $p = $e.Split($TAB)
      if ($p[1] -ne 'touches_cdbpath') { continue }
      if ($p[6].ToLower().StartsWith($want)) { $hits.Add($p) }
    }
    if ($hits.Count -eq 0) { Write-Output "no code touches '$FilesForDbPath'"; exit 1 }
    Write-Output ("element paths under {0}: {1}" -f $FilesForDbPath, $hits.Count)
    Show-Hits $hits $Limit $All.IsPresent {
      param($p)
      "  {0}:{1}  {2}" -f $p[4], $p[5], $p[6]
    }
    break
  }

  'Module' {
    $mod = $Module.Trim().Trim('/')
    $fanOut = @{}; $fanIn = @{}
    foreach ($e in $edgeLines) {
      $p = $e.Split($TAB)
      if ($p[1] -ne 'calls_global' -and $p[1] -ne 'callback_invokes') { continue }
      if (-not $p[4].StartsWith($mod + '/')) { continue }
      if ($fanOut.ContainsKey($p[2])) { $fanOut[$p[2]]++ } else { $fanOut[$p[2]] = 1 }
      if ($fanIn.ContainsKey($p[3])) { $fanIn[$p[3]]++ } else { $fanIn[$p[3]] = 1 }
    }
    Write-Output ("module {0}: top fan-out (outgoing call sites)" -f $mod)
    $fanOut.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 |
      ForEach-Object { "  {0,5}  {1}" -f $_.Value, $_.Name }
    Write-Output ("module {0}: top fan-in (incoming call sites)" -f $mod)
    $fanIn.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 |
      ForEach-Object { "  {0,5}  {1}" -f $_.Value, $_.Name }
    break
  }

  'Find' {
    $q = $Find.ToLower()
    $hits = New-Object System.Collections.Generic.List[int]
    for ($i = 0; $i -lt $nodeId.Count; $i++) {
      if ($nodeId[$i].ToLower().Contains($q) -or $nodeName[$i].Contains($q)) { $hits.Add($i) }
    }
    if ($hits.Count -eq 0) { Write-Output "no node matching '$Find'"; exit 1 }
    Write-Output ("nodes matching '{0}': {1}" -f $Find, $hits.Count)
    Show-Hits $hits $Limit $All.IsPresent {
      param($i)
      "  {0,-9} {1}  ({2}:{3})" -f $nodeKind[$i], $nodeId[$i], $nodeFile[$i], $nodeLine[$i]
    }
    break
  }
}

exit 0
