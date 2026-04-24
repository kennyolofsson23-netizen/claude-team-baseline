# go.ps1 — the dead-simple installer for claude-team-baseline on a Windows work PC.
#
# Intended usage (paste into PowerShell as Administrator):
#
#   irm https://raw.githubusercontent.com/<YOUR-GH-USER>/claude-team-baseline/main/scripts/go.ps1 | iex
#
# Idempotent. Safe to re-run after a reboot.

$ErrorActionPreference = "Continue"
$ProgressPreference    = "SilentlyContinue"

# ---------- config ----------
# Auto-detect the source URL if the script was invoked via irm | iex.
# Users can override by setting $env:CTB_REPO_URL before running.
if (-not $env:CTB_REPO_URL) {
    # If this script was downloaded to disk with a URL context, try to derive. Otherwise fail clearly.
    $env:CTB_REPO_URL = Read-Host "Enter your GitHub URL for claude-team-baseline (e.g. https://github.com/kenny/claude-team-baseline.git)"
}
$RepoUrl = $env:CTB_REPO_URL.Trim()
$WorkDir = Join-Path $env:USERPROFILE "work"
$BaselinePath = Join-Path $WorkDir "claude-team-baseline"

function Step($n, $msg) { Write-Host ""; Write-Host "=== STEP $n — $msg ===" -ForegroundColor Cyan }
function Ok($m)         { Write-Host "  [ok] $m"  -ForegroundColor Green }
function Warn($m)       { Write-Host "  [!!] $m"  -ForegroundColor Yellow }
function Fail($m)       { Write-Host "  [X]  $m"  -ForegroundColor Red }

# ---------- precheck: admin ----------
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Fail "Must run as Administrator. Close this and right-click PowerShell -> Run as Administrator."
    exit 1
}

# ---------- step 1: install tools via winget ----------
Step 1 "Installing prerequisites via winget"

$packages = @(
    @{ Id = "Git.Git";                                 Label = "Git" }
    @{ Id = "GitHub.cli";                              Label = "GitHub CLI" }
    @{ Id = "OpenJS.NodeJS.LTS";                       Label = "Node.js LTS (for Claude CLI)" }
    @{ Id = "Python.Python.3.12";                      Label = "Python 3.12" }
    @{ Id = "Anthropic.ClaudeCode";                    Label = "Claude Code" }
    @{ Id = "astral-sh.uv";                            Label = "uv" }
    @{ Id = "Microsoft.VisualStudioCode";              Label = "VS Code" }
    @{ Id = "Docker.DockerDesktop";                    Label = "Docker Desktop" }
    @{ Id = "Microsoft.ODBCDriverForSQLServer.18";     Label = "MS ODBC Driver 18" }
)

foreach ($p in $packages) {
    $present = winget list --id $p.Id --source winget 2>&1 | Select-String $p.Id
    if ($present) { Ok ("{0} already installed" -f $p.Label); continue }
    Write-Host ("  installing {0} ..." -f $p.Label)
    winget install --id $p.Id --source winget --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
    $check = winget list --id $p.Id --source winget 2>&1 | Select-String $p.Id
    if ($check) { Ok ("{0} installed" -f $p.Label) } else { Warn ("{0} — check manually" -f $p.Label) }
}

# refresh PATH for this session
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")

# ---------- step 2: UTF-8 env ----------
Step 2 "Python UTF-8 defaults"
[Environment]::SetEnvironmentVariable("PYTHONUTF8",      "1",     "User")
[Environment]::SetEnvironmentVariable("PYTHONIOENCODING","utf-8", "User")
$env:PYTHONUTF8       = "1"
$env:PYTHONIOENCODING = "utf-8"
Ok "done"

# ---------- step 3: authenticate github ----------
Step 3 "GitHub authentication"
$authState = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  A browser window will open. Log in with the GitHub account that owns the repo."
    Write-Host "  Tip: pick HTTPS as the protocol when prompted."
    gh auth login
} else {
    Ok "gh already authenticated"
}

# ---------- step 4: clone or pull the baseline ----------
Step 4 "Baseline repo"
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

if (Test-Path $BaselinePath) {
    Ok ("Baseline already at {0} — pulling latest" -f $BaselinePath)
    Push-Location $BaselinePath
    git pull --ff-only 2>&1 | ForEach-Object { Write-Host "    $_" }
    Pop-Location
} else {
    Write-Host ("  cloning {0} -> {1}" -f $RepoUrl, $BaselinePath)
    git clone $RepoUrl $BaselinePath
    if (-not (Test-Path $BaselinePath)) { Fail "Clone failed. Check repo URL and gh auth."; exit 1 }
    Ok "cloned"
}

# ---------- step 5: install personal claude config ----------
Step 5 "Installing personal ~/.claude/ config"
$bash = "C:\Program Files\Git\bin\bash.exe"
if (-not (Test-Path $bash)) { $bash = "$env:ProgramFiles\Git\bin\bash.exe" }
if (Test-Path $bash) {
    & $bash -c "cd '$($BaselinePath -replace '\\','/')' && bash scripts/install.sh" 2>&1 |
        ForEach-Object { Write-Host "    $_" }
} else {
    Warn "Git Bash not found — reboot and re-run this script."
}

# ---------- step 6: authenticate claude ----------
Step 6 "Claude authentication"
Write-Host "  A browser window will open. Log in with your company Claude account"
Write-Host "  (or personal Pro/Max until Enterprise is provisioned)."
Write-Host "  Close the Claude session with /exit once login succeeds."
Start-Sleep -Seconds 2
try { claude } catch { Warn "Could not launch claude automatically — run 'claude' manually after reboot." }

# ---------- step 7: start the wiki ----------
Step 7 "Starting the wiki"
$pythonExe = (Get-Command python -ErrorAction SilentlyContinue).Source
if ($pythonExe) {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "python '$BaselinePath\wiki\serve.py'" -WindowStyle Minimized
    Ok "wiki starting on http://localhost:7777 (new window)"
    Start-Process "http://localhost:7777"
} else {
    Warn "Python not in PATH yet — reboot and run: python $BaselinePath\wiki\serve.py"
}

# ---------- summary ----------
Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host " Bootstrap complete."                        -ForegroundColor Green
Write-Host "==========================================="  -ForegroundColor Green
Write-Host ""
Write-Host "Next commands to run:" -ForegroundColor White
Write-Host ""
Write-Host "  # Scaffold your first test project:" -ForegroundColor Gray
Write-Host ("  bash '{0}\scripts\scaffold-project.sh' '{1}\hello-claude'" -f $BaselinePath, $WorkDir) -ForegroundColor White
Write-Host ""
Write-Host "  # Start a Claude session in any project folder:" -ForegroundColor Gray
Write-Host "  cd `$env:USERPROFILE\work\hello-claude" -ForegroundColor White
Write-Host "  claude" -ForegroundColor White
Write-Host ""
Write-Host "If anything seems off, reboot (Docker + PATH often need it) and re-run this script."
