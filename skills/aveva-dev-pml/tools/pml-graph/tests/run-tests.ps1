<#
.SYNOPSIS
  Regression test for tools/pml-graph (builder + query tool).
.DESCRIPTION
  Builds a graph from the small fixtures under tests/fixtures and asserts the
  shape of the output: node kinds, the resolved call edge, the callback edges,
  member ownership, overload handling, CDB path capture and interop imports.
  Runs entirely offline against the bundled tree-sitter grammar.

  Also verifies build determinism: a second build must produce a graph whose
  decompressed content hashes identically.
.EXAMPLE
  .\run-tests.ps1
.OUTPUTS
  Exit 0 = all assertions passed, 1 = a failure, 2 = setup problem.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$here      = $PSScriptRoot
$toolDir   = Split-Path -Parent $here
$fixtures  = Join-Path $here 'fixtures'
$builder   = Join-Path $toolDir 'build-pml-graph.ps1'
$queryTool = Join-Path $toolDir 'query-graph.ps1'
$TAB = [char]9

if (-not (Test-Path $builder))   { throw "missing $builder" }
if (-not (Test-Path $queryTool)) { throw "missing $queryTool" }

$work    = Join-Path ([System.IO.Path]::GetTempPath()) ("pmlgraph-test-{0}" -f [guid]::NewGuid())
$outA    = Join-Path $work 'a'
$outB    = Join-Path $work 'b'
New-Item -ItemType Directory -Force -Path $outA, $outB | Out-Null

$failures = New-Object System.Collections.Generic.List[string]
$checks   = 0

function Check([string]$what, [bool]$ok, [string]$detail) {
  $script:checks++
  if ($ok) {
    Write-Output ("  ok    {0}" -f $what)
  } else {
    Write-Output ("  FAIL  {0}{1}" -f $what, $(if ($detail) { " -- $detail" } else { '' }))
    $script:failures.Add($what)
  }
}

function Read-Graph([string]$path) {
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

try {
  Write-Output 'building graph from fixtures...'
  $psExe = (Get-Process -Id $PID).Path
  $build = & $psExe -NoProfile -ExecutionPolicy Bypass -File $builder -Source $fixtures -Out $outA 2>&1
  $buildExit = $LASTEXITCODE
  Write-Output ("  builder exit {0}" -f $buildExit)
  Check 'builder succeeds on the fixtures' ($buildExit -eq 0) ($build | Select-Object -Last 3 | Out-String)

  $graphA = Join-Path $outA 'pml-graph.tsv.gz'
  Check 'graph file written' (Test-Path $graphA) $graphA
  if (-not (Test-Path $graphA)) { throw 'no graph output' }

  $rows = Read-Graph $graphA
  $nodes = @($rows | Where-Object { $_.StartsWith('N') })
  $edges = @($rows | Where-Object { $_.StartsWith('E') })

  # --- definitions -------------------------------------------------------
  $fnNodes = @($nodes | Where-Object { $_.Split($TAB)[1] -eq 'function' })
  $objNodes = @($nodes | Where-Object { $_.Split($TAB)[1] -eq 'object' })
  $formNodes = @($nodes | Where-Object { $_.Split($TAB)[1] -eq 'form' })
  $methNodes = @($nodes | Where-Object { $_.Split($TAB)[1] -eq 'method' })
  $memberNodes = @($nodes | Where-Object { $_.Split($TAB)[1] -eq 'member' })
  $gadgetNodes = @($nodes | Where-Object { $_.Split($TAB)[1] -eq 'gadget' })

  Check 'two global functions found' ($fnNodes.Count -eq 2) "got $($fnNodes.Count)"
  Check 'one object found' ($objNodes.Count -eq 1) "got $($objNodes.Count)"
  Check 'one form found' ($formNodes.Count -eq 1) "got $($formNodes.Count)"
  Check 'five methods found (2 form + 3 object)' ($methNodes.Count -eq 5) "got $($methNodes.Count)"
  Check 'three members found (2 object + 1 form)' ($memberNodes.Count -eq 3) "got $($memberNodes.Count)"
  Check 'gadgets found' ($gadgetNodes.Count -ge 3) "got $($gadgetNodes.Count)"

  # overloaded .describe keeps both definitions
  $describe = @($methNodes | Where-Object { $_.Split($TAB)[5] -eq 'describe' })
  Check 'overloaded .describe yields two method nodes' ($describe.Count -eq 2) "got $($describe.Count)"
  $overloadFlagged = @($describe | Where-Object { $_.Split($TAB)[6] -eq 'overload' })
  Check 'second .describe is flagged as overload' ($overloadFlagged.Count -eq 1) "got $($overloadFlagged.Count)"

  # --- call resolution ---------------------------------------------------
  $callEdges = @($edges | Where-Object { $_.Split($TAB)[1] -eq 'calls_global' })
  $toRound = @($callEdges | Where-Object { $_.Split($TAB)[3] -eq 'graphsampleround.pmlfnc#graphsampleround' })
  Check 'call from add -> round resolved' ($toRound.Count -ge 1) "got $($toRound.Count)"
  $callers = @($toRound | ForEach-Object { $_.Split($TAB)[2] } | Sort-Object -Unique)
  Check 'the caller is the add function' ($callers -contains 'graphsampleadd.pmlfnc#graphsampleadd') ($callers -join ', ')

  $toAdd = @($callEdges | Where-Object { $_.Split($TAB)[3] -eq 'graphsampleadd.pmlfnc#graphsampleadd' })
  Check 'form methods call !!graphSampleAdd' ($toAdd.Count -ge 2) "got $($toAdd.Count)"

  $builtinEdges = @($edges | Where-Object { $_.Split($TAB)[1] -eq 'calls_builtin' })
  Check 'built-in STRING() calls captured' ($builtinEdges.Count -ge 2) "got $($builtinEdges.Count)"

  # --- callbacks ---------------------------------------------------------
  $cbEdges = @($edges | Where-Object { $_.Split($TAB)[1] -eq 'callback_invokes' })
  $cbToApply = @($cbEdges | Where-Object { $_.Split($TAB)[3] -like '*graphsampleform.applyvalue*' })
  Check 'gadget callbacks resolve to .applyValue' ($cbToApply.Count -ge 2) "got $($cbToApply.Count)"
  $cbToRound = @($cbEdges | Where-Object { $_.Split($TAB)[3] -eq 'graphsampleround.pmlfnc#graphsampleround' })
  Check 'callback calling a global function resolves' ($cbToRound.Count -ge 1) "got $($cbToRound.Count)"
  $unresolvedCb = @($cbEdges | Where-Object { $_.Split($TAB)[3].StartsWith('unresolved:') })
  Check 'no unresolved callbacks in the fixtures' ($unresolvedCb.Count -eq 0) "got $($unresolvedCb.Count)"

  # --- ownership, members, interop, paths --------------------------------
  $memberOf = @($edges | Where-Object { $_.Split($TAB)[1] -eq 'member_of' })
  Check 'all members owned by their container' ($memberOf.Count -eq 3) "got $($memberOf.Count)"

  $dbPaths = @($edges | Where-Object { $_.Split($TAB)[1] -eq 'touches_cdbpath' })
  Check 'CDB path captured' ($dbPaths.Count -eq 1) "got $($dbPaths.Count)"
  if ($dbPaths.Count -eq 1) {
    Check 'CDB path value normalised' ($dbPaths[0].Split($TAB)[6] -eq '/GRAPH/FIXTURE-AREA') $dbPaths[0]
  }

  $imports = @($edges | Where-Object { $_.Split($TAB)[1] -eq 'imports_dll' })
  Check 'import dll captured' ($imports.Count -eq 1) "got $($imports.Count)"
  if ($imports.Count -eq 1) {
    Check 'import dll value is gridcontrol' ($imports[0].Split($TAB)[3] -eq 'dll:gridcontrol') $imports[0]
  }

  $hooks = @($edges | Where-Object { $_.Split($TAB)[1] -eq 'form_hook' })
  Check 'init clause produces a form_hook' ($hooks.Count -ge 1) "got $($hooks.Count)"

  # --- metadata ----------------------------------------------------------
  $metaPath = Join-Path $outA 'pml-graph.meta.json'
  Check 'metadata written' (Test-Path $metaPath) $metaPath
  if (Test-Path $metaPath) {
    $meta = Get-Content $metaPath -Raw | ConvertFrom-Json
    Check 'metadata schema matches' ($meta.schema -eq 1) "schema $($meta.schema)"
    Check 'metadata node count matches graph' ($meta.nodeCount -eq $nodes.Count) "$($meta.nodeCount) vs $($nodes.Count)"
    Check 'metadata edge count matches graph' ($meta.edgeCount -eq $edges.Count) "$($meta.edgeCount) vs $($edges.Count)"
    Check 'metadata records the fixture file count' ($meta.sourceFiles -eq 4) "got $($meta.sourceFiles)"
    Check 'no fixture file has a parse error' ($meta.filesWithParseError -eq 0) "got $($meta.filesWithParseError)"
  }

  # --- query tool --------------------------------------------------------
  $whoOut = & $psExe -NoProfile -ExecutionPolicy Bypass -File $queryTool -Graph $graphA -WhoCalls '!!graphSampleRound' -Limit 5 2>&1
  Check 'query -WhoCalls finds callers' (($whoOut -join "`n") -match 'graphsampleadd') ($whoOut -join ' | ')

  # -WhoCalls by FULL node id: exact match, no truncation to a name prefix.
  # (Pre-fix, id 'x.pmlfnc#name' was regex-truncated to 'x' and silently
  # resolved to the wrong node when a same-prefixed node existed.)
  $whoId = & $psExe -NoProfile -ExecutionPolicy Bypass -File $queryTool -Graph $graphA -WhoCalls 'graphsampleround.pmlfnc#graphsampleround' -Limit 5 2>&1
  Check 'query -WhoCalls accepts a full node id' (($whoId -join "`n") -match 'graphsampleadd') ($whoId -join ' | ')

  # -CallbacksInto by FULL node id reaches the same gadget edges as the name.
  $cbId = & $psExe -NoProfile -ExecutionPolicy Bypass -File $queryTool -Graph $graphA -CallbacksInto 'graphsampleform.pmlfrm#graphsampleform.applyvalue' -Limit 5 2>&1
  Check 'query -CallbacksInto accepts a full node id' (($cbId -join "`n") -match 'callback_invokes') ($cbId -join ' | ')

  # Qualified names resolve on the LAST dot segment (the method a callback
  # actually drives), not on the first segment.
  $cbQ = & $psExe -NoProfile -ExecutionPolicy Bypass -File $queryTool -Graph $graphA -CallbacksInto '!!graphSampleForm.applyValue' -Limit 5 2>&1
  Check 'qualified -CallbacksInto resolves last segment' (($cbQ -join "`n") -match 'callback_invokes') ($cbQ -join ' | ')

  # A non-matching id is a loud error with a -Find hint, never a silent
  # fallback to the truncated prefix.
  $badId = & $psExe -NoProfile -ExecutionPolicy Bypass -File $queryTool -Graph $graphA -WhoCalls 'graphsampleround.pmlfnc#no.such.method' 2>&1
  Check 'unknown full id fails loudly' ((($badId -join "`n") -match 'match exactly') -and ($LASTEXITCODE -eq 1)) ($badId -join ' | ')

  $cbOut = & $psExe -NoProfile -ExecutionPolicy Bypass -File $queryTool -Graph $graphA -CallbacksInto '.applyValue' -Limit 5 2>&1
  Check 'query -CallbacksInto finds the gadget' (($cbOut -join "`n") -match 'apply') ($cbOut -join ' | ')

  $pathOut = & $psExe -NoProfile -ExecutionPolicy Bypass -File $queryTool -Graph $graphA -FilesForDbPath '/GRAPH' -Limit 5 2>&1
  Check 'query -FilesForDbPath finds the path' (($pathOut -join "`n") -match '/GRAPH/FIXTURE-AREA') ($pathOut -join ' | ')

  $findOut = & $psExe -NoProfile -ExecutionPolicy Bypass -File $queryTool -Graph $graphA -Find 'graphsample' -Limit 5 2>&1
  Check 'query -Find lists nodes' (($findOut -join "`n") -match 'graphsample') ($findOut -join ' | ')

  # --- determinism -------------------------------------------------------
  Write-Output 'rebuilding to check determinism...'
  $build2 = & $psExe -NoProfile -ExecutionPolicy Bypass -File $builder -Source $fixtures -Out $outB 2>&1
  $hashA = (Get-FileHash (Join-Path $outA 'pml-graph.tsv.gz') -Algorithm SHA256).Hash
  $hashB = (Get-FileHash (Join-Path $outB 'pml-graph.tsv.gz') -Algorithm SHA256).Hash
  Check 'second build is byte-identical' ($hashA -eq $hashB) "$hashA vs $hashB"

  Write-Output ''
  if ($failures.Count -gt 0) {
    Write-Output ("{0} of {1} checks FAILED:" -f $failures.Count, $checks)
    $failures | ForEach-Object { Write-Output ('  - ' + $_) }
    exit 1
  }
  Write-Output ("all {0} checks passed" -f $checks)
  exit 0
} finally {
  Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
}
