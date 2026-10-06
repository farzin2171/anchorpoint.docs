<#
.SYNOPSIS
  Structural check of every ```mermaid block in the repository's Markdown files.
.DESCRIPTION
  Fails when a block is empty or does not start with a known Mermaid diagram keyword.
  This is a cheap structural check, not a full parse; a full render check can replace it later.
#>
param([string]$Root = (Split-Path -Parent $PSScriptRoot))

$known = 'flowchart','graph','sequenceDiagram','classDiagram','stateDiagram','stateDiagram-v2',
         'erDiagram','journey','gantt','pie','gitGraph','mindmap','timeline','quadrantChart','C4Context'
$failures = 0
$blocks = 0

Get-ChildItem -Path $Root -Recurse -Filter *.md -File |
    Where-Object { $_.FullName -notmatch '[\/](\.git|node_modules)[\/]' } |
    ForEach-Object {
        $text = Get-Content -Raw -Path $_.FullName
        $matches2 = [regex]::Matches($text, '(?ms)^```mermaid\s*\r?\n(.*?)^```')
        foreach ($m in $matches2) {
            $blocks++
            $body = $m.Groups[1].Value.Trim()
            $first = ($body -split '\r?\n' | Where-Object { $_.Trim() -ne '' -and $_.Trim() -notmatch '^%%' } | Select-Object -First 1)
            $word = if ($first) { ($first.Trim() -split '\s+')[0] } else { '' }
            if (-not $body -or ($known -notcontains $word)) {
                Write-Error "$($_.FullName): mermaid block is empty or starts with unknown keyword '$word'" -ErrorAction Continue
                $failures++
            }
        }
    }

Write-Host "Checked $blocks mermaid block(s); $failures failure(s)."
if ($failures -gt 0) { exit 1 }
