# regen-pmllib-index.ps1 — rebuild references/pmllib-index.md from the bundled PMLLIB snapshot.
# Usage:  powershell -NoProfile -ExecutionPolicy Bypass -File regen-pmllib-index.ps1 [-Root <PMLLIB dir>] [-ProductVersion <text>]
# Requires Windows PowerShell 5.1 or PowerShell 7+. Regenerates only the index; pmllib-idioms.md is hand-curated.
param(
    [string]$Root = (Join-Path $PSScriptRoot '..\PMLLIB'),
    [string]$ProductVersion = 'TBD (fill in, e.g. AVEVA Marine 12.1.x)'
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path $Root).Path
$outFile = Join-Path $PSScriptRoot '..\references\pmllib-index.md'

$files = Get-ChildItem $Root -Recurse -File | Where-Object {
    $_.Extension -in '.pmlfrm','.pmlfnc','.pmlobj','.pmlmac','.mac'
}

$feat = [ordered]@{
  SETFORM = '\bsetup\s+form\b'; SELECTOR= '\bselector\b'; INITOK = '\b(initcall|okcall|cancelcall)\b'
  EDG = '\b(edgcntrl|edgpacket|edgpick)'; COLL = '\bCOLLECTION\s*\('; PMLNET = '\bpmlnetcontrol\b'
  MARAPI = "\bimport\s+'marapi'"; MARUI = '!\s*mar(Ui|Drafting|Util|Dex)\b'; HANDLE = '\bhandle\s*\('
  DRAWLIST= '\bdrawlist\b'; VIEWG = '\bview\s+\.\w+'; BREAKIF = '\bBREAK\s+IF\b'
  FILEOBJ = '\bopenFile\(|object\s+FILE\b'; DEFFUNC = '\bdefine\s+function\b'; DEFOBJ = '\bdefine\s+object\b'
  DEFMETH = '\bdefine\s+method\b'; PML1GOTO= '\$GOTO|\$LABEL'; DBREF = '\bDBREF\b'; ISANY = '\bis\s+ANY\b'
}
$compiled = @{}; foreach ($k in $feat.Keys) { $compiled[$k] = [regex]::new($feat[$k], 'IgnoreCase') }
$hdrKeys = 'File','Type','Group','Keyword','Module','Author','Created','Replaces','Description'

$results = New-Object System.Collections.Generic.List[object]
foreach ($f in $files) {
    $lines = [System.IO.File]::ReadAllLines($f.FullName)
    $text = [string]::Join("`n", $lines)
    $hdr = @{}
    $n = [Math]::Min(60, $lines.Count)
    for ($i = 0; $i -lt $n; $i++) {
        $ln = $lines[$i]
        if ($ln -notmatch '^\s*--') { continue }
        foreach ($hk in $hdrKeys) {
            if (-not $hdr.ContainsKey($hk) -and $ln -match ('(?i)^\s*--\s*' + $hk + ':\s*(.+?)\s*$')) { $hdr[$hk] = $Matches[1] }
        }
        if ($hdr.ContainsKey('Description')) { break }
    }
    $flags = foreach ($k in $compiled.Keys) { if ($compiled[$k].IsMatch($text)) { $k } }
    $rel = $f.FullName.Substring($Root.Length + 1) -replace '\\','/'
    $parts = $rel.Split('/')
    $module = if ($parts.Count -gt 1) { $parts[0] } else { '(root)' }
    $results.Add([pscustomobject]@{ path=$rel; name=$f.Name; ext=$f.Extension.ToLower(); module=$module
        lines=$lines.Count; bytes=$f.Length; group=$hdr['Group']; desc=$hdr['Description']; flags=@($flags) })
}

$typeOf = @{ '.pmlfrm'='Form'; '.pmlfnc'='Function'; '.pmlobj'='Object'; '.pmlmac'='Macro'; '.mac'='Macro' }
$extOrder = @{ '.pmlfrm'=1; '.pmlfnc'=2; '.pmlobj'=3; '.pmlmac'=4; '.mac'=5 }
$flagAbbr = @{ SETFORM='FORM'; SELECTOR='SEL'; INITOK='INIT'; EDG='EDG'; COLL='COLL'; PMLNET='PNET'; MARAPI='API'
    MARUI='MUI'; HANDLE='HND'; DRAWLIST='DLW'; VIEWG='VIEW'; BREAKIF='BRK'; FILEOBJ='FIO'; DEFFUNC='FN'
    DEFOBJ='OD'; DEFMETH='MT'; PML1GOTO='P1'; DBREF='REF'; ISANY='ANY' }
function Clean([string]$s) {
    if (-not $s) { return '' }
    $s = $s -replace '\|','/' -replace '\s+',' '; $s = $s.Trim()
    if ($s.Length -gt 72) { $s = $s.Substring(0,69) + '...' }; return $s
}

$sb = New-Object System.Text.StringBuilder
$null = $sb.AppendLine('# PMLLIB Delivered Source Index')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('Machine-generated index of the bundled AVEVA-delivered PML source snapshot. Regenerate with [tools/regen-pmllib-index.ps1](../tools/regen-pmllib-index.ps1).')
$null = $sb.AppendLine('- Snapshot: bundled PMLLIB/ folder | Product version: ' + $ProductVersion + ' | Scan date: ' + (Get-Date -Format 'yyyy-MM-dd'))
$null = $sb.AppendLine('- Scope: ' + $results.Count + ' source files (.pmlfrm/.pmlfnc/.pmlobj/.mac) under [PMLLIB/](../PMLLIB/). Icons (.png) and data files excluded.')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('**How to use**: grep this file for a concept (gadget name, system object, module, flag), then open the real source via the path column. For **relational** questions (who calls `!!name`, callback wiring, change impact, code touching a CDB path) use `tools/pml-graph/query-graph.ps1` instead of grepping — see [SKILL.md](../SKILL.md) Core Framework 2d. Flags: FORM=setup form, SEL=selector, INIT=initcall/okcall, EDG=event driven graphics, COLL=COLLECTION query, PNET=pmlnetcontrol, API=marapi import, MUI=MarUi/MarDrafting, HND=HANDLE trap, DLW=drawlist, VIEW=view gadget, BRK=BREAK IF, FIO=FILE object, FN/OD/MT=define function/object/method, P1=$GOTO legacy, ANY=is ANY usage.')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('## Modules')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('| Module | Files | Forms | Functions | Objects | MB |')
$null = $sb.AppendLine('|---|---:|---:|---:|---:|---:|')
foreach ($m in ($results | Group-Object module | Sort-Object Count -Descending)) {
    $g = $m.Group
    $null = $sb.AppendLine('| ' + $m.Name + ' | ' + $g.Count + ' | ' +
        ($g | Where-Object { $_.ext -eq '.pmlfrm' }).Count + ' | ' +
        ($g | Where-Object { $_.ext -eq '.pmlfnc' }).Count + ' | ' +
        ($g | Where-Object { $_.ext -eq '.pmlobj' }).Count + ' | ' +
        [Math]::Round((($g | Measure-Object bytes -Sum).Sum/1MB),1) + ' |')
}
$null = $sb.AppendLine('')

$mds = @($results | Where-Object { $_.module -eq 'mds' })
$main = @($results | Where-Object { $_.module -ne 'mds' })
foreach ($grpName in ($main | Group-Object module | Sort-Object { -$_.Count } | ForEach-Object Name)) {
    $items = $main | Where-Object { $_.module -eq $grpName } | Sort-Object @{e={$extOrder[$_.ext]}}, name
    $null = $sb.AppendLine("## Module: $grpName (" + $items.Count + ')')
    $null = $sb.AppendLine('')
    foreach ($it in $items) {
        $fl = ($it.flags | ForEach-Object { $flagAbbr[$_] }) -join ','
        $desc = Clean $it.desc; if (-not $desc) { $desc = Clean $it.group }
        $null = $sb.AppendLine('- [' + $it.path + '](../PMLLIB/' + ($it.path -replace ' ','%20') + ') - ' +
            $typeOf[$it.ext] + ' | ' + (Clean $it.group) + ' | ' + $it.lines + 'L | ' + $fl +
            ($(if($desc){' - ' + $desc}else{''})))
    }
    $null = $sb.AppendLine('')
}
$null = $sb.AppendLine('## Module: mds (' + $mds.Count + ' - low priority, hull scantling rule library)')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('Marine Design System scantling/beam formula library, largely auto-generated per profile type. Consult only for MDS-specific work. Names: ' +
    (($mds | Sort-Object name | ForEach-Object { ($_.name -replace '\..*$','') }) -join ', '))
$null = $sb.AppendLine('')

[System.IO.File]::WriteAllText($outFile, $sb.ToString(), [System.Text.Encoding]::UTF8)
'OK: ' + $results.Count + ' files -> ' + (Resolve-Path $outFile).Path
