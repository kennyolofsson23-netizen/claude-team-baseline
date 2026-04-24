# claude-team-baseline — personal layer installer (PowerShell)
# Run once per machine. Safe to re-run.

$ErrorActionPreference = "Stop"

$BaselineDir = (Get-Item "$PSScriptRoot\..").FullName
$ClaudeDir   = "$env:USERPROFILE\.claude"
$WorkDir     = "$env:USERPROFILE\work"

Write-Host "claude-team-baseline installer"
Write-Host "  baseline : $BaselineDir"
Write-Host "  target   : $ClaudeDir"
Write-Host ""

function Need {
    param([string]$Cmd)
    $found = Get-Command $Cmd -ErrorAction SilentlyContinue
    if (-not $found) {
        Write-Host "  [X] missing: $Cmd — install via winget"
        return $false
    }
    $ver = (& $Cmd --version 2>&1 | Select-Object -First 1)
    Write-Host "  [ok] $Cmd ($ver)"
    return $true
}

# ---------- step 1: prerequisites ----------
Write-Host "==> Step 1: checking prerequisites"
$fail = $false
if (-not (Need "git"))    { $fail = $true }
if (-not (Need "gh"))     { $fail = $true }
if (-not (Need "python")) { $fail = $true }
if (-not (Need "claude")) { $fail = $true }
if (-not (Need "uv"))     { $fail = $true }

if ($fail) {
    Write-Host ""
    Write-Host "Prerequisites missing. See HANDOVER.md Step 1."
    exit 1
}

# ---------- step 2: personal claude dir ----------
Write-Host ""
Write-Host "==> Step 2: setting up $ClaudeDir"
New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null

# back up existing CLAUDE.md
$existingMd = "$ClaudeDir\CLAUDE.md"
$sourceMd   = "$BaselineDir\dotfiles\CLAUDE.md"
if (Test-Path $existingMd) {
    if ((Get-FileHash $existingMd).Hash -ne (Get-FileHash $sourceMd).Hash) {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backup = "$existingMd.bak.$stamp"
        Copy-Item $existingMd $backup
        Write-Host "  [backup] existing CLAUDE.md -> $backup"
    }
}
Copy-Item $sourceMd $existingMd -Force
Write-Host "  [copy] personal CLAUDE.md -> $existingMd"

# settings.json
$settings = "$ClaudeDir\settings.json"
if (-not (Test-Path $settings)) {
    Copy-Item "$BaselineDir\dotfiles\settings.json" $settings
    Write-Host "  [copy] default settings.json -> $settings"
} else {
    Write-Host "  [keep] existing settings.json (will not overwrite)"
}

# ---------- step 3: work directory ----------
Write-Host ""
Write-Host "==> Step 3: work directory convention"
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null
Write-Host "  [ok] $WorkDir ready"

# ---------- step 4: python UTF-8 env ----------
Write-Host ""
Write-Host "==> Step 4: Python UTF-8 defaults (user env)"
[Environment]::SetEnvironmentVariable("PYTHONUTF8", "1", "User")
[Environment]::SetEnvironmentVariable("PYTHONIOENCODING", "utf-8", "User")
Write-Host "  [set] PYTHONUTF8=1 PYTHONIOENCODING=utf-8 (takes effect in new shells)"

# ---------- step 5: verify ----------
Write-Host ""
Write-Host "==> Step 5: verify"
& bash "$BaselineDir\scripts\verify.sh"

Write-Host ""
Write-Host "Done. Next: bash $BaselineDir\scripts\scaffold-project.sh <new-project-name>"
