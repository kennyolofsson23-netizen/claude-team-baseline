# go.ps1 — the dead-simple installer for claude-team-baseline on a Windows work PC.
#
# Intended usage (paste into PowerShell as Administrator):
#
#   $pat = "<YOUR-ADO-PAT>"
#   $headers = @{ Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat")) }
#   irm -Uri "https://dev.azure.com/<YOUR-ADO-ORG>/<YOUR-ADO-PROJECT>/_apis/git/repositories/claude-team-baseline/items?path=/scripts/go.ps1&api-version=7.0&download=true" -Headers $headers | iex
#
# Idempotent. Safe to re-run after a reboot.

$ErrorActionPreference = "Continue"
$ProgressPreference    = "SilentlyContinue"

# ---------- config ----------
# Default repo URL — when the Enterprise repo exists, change this line or override
# by setting $env:CTB_REPO_URL before running.
$DefaultRepoUrl = "https://dev.azure.com/<YOUR-ADO-ORG>/<YOUR-ADO-PROJECT>/_git/claude-team-baseline"
$RepoUrl = if ($env:CTB_REPO_URL) { $env:CTB_REPO_URL.Trim() } else { $DefaultRepoUrl }
Write-Host ("Using repo: {0}" -f $RepoUrl) -ForegroundColor Gray
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

# ---------- step 1: WSL update (required for Rancher Desktop) ----------
Step 1 "Updating WSL (required for Rancher Desktop)"
wsl --update 2>&1 | ForEach-Object { Write-Host "    $_" }
Ok "WSL updated"

# ---------- step 2: install tools via winget ----------
Step 2 "Installing prerequisites via winget"

$packages = @(
    @{ Id = "Git.Git";                                 Label = "Git" }
    @{ Id = "Microsoft.AzureCLI";                      Label = "Azure CLI" }
    @{ Id = "OpenJS.NodeJS.LTS";                       Label = "Node.js LTS (for Claude CLI)" }
    @{ Id = "Python.Python.3.12";                      Label = "Python 3.12" }
    @{ Id = "Anthropic.ClaudeCode";                    Label = "Claude Code" }
    @{ Id = "astral-sh.uv";                            Label = "uv" }
    @{ Id = "Microsoft.VisualStudioCode";              Label = "VS Code" }
    @{ Id = "SUSE.RancherDesktop";                     Label = "Rancher Desktop" }
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

# ---------- step 3: UTF-8 env ----------
Step 3 "Python UTF-8 defaults"
[Environment]::SetEnvironmentVariable("PYTHONUTF8",      "1",     "User")
[Environment]::SetEnvironmentVariable("PYTHONIOENCODING","utf-8", "User")
$env:PYTHONUTF8       = "1"
$env:PYTHONIOENCODING = "utf-8"
Ok "done"

# ---------- step 4: azure devops authentication ----------
Step 4 "Azure DevOps authentication"
$authState = az account show 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Launching Azure login (browser popup)..."
    az login | Out-Null
}
$extCheck = az extension list --query "[?name=='azure-devops']" 2>&1
if ($extCheck -notmatch "azure-devops") {
    Write-Host "  Installing Azure DevOps CLI extension..."
    az extension add --name azure-devops | Out-Null
}
$authState2 = az account show 2>&1
if ($LASTEXITCODE -ne 0) {
    Warn "Azure login failed — check browser popup and retry."
} else {
    Ok "Azure CLI authenticated and azure-devops extension ready"
}

# ---------- step 5: clone or pull the baseline ----------
Step 5 "Baseline repo"
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

if (Test-Path $BaselinePath) {
    Ok ("Baseline already at {0} — pulling latest" -f $BaselinePath)
    Push-Location $BaselinePath
    git pull --ff-only 2>&1 | ForEach-Object { Write-Host "    $_" }
    Pop-Location
} else {
    Write-Host ("  cloning {0} -> {1}" -f $RepoUrl, $BaselinePath)
    git clone $RepoUrl $BaselinePath
    if (-not (Test-Path $BaselinePath)) { Fail "Clone failed. Check repo URL and Azure DevOps auth (run: az login)."; exit 1 }
    Ok "cloned"
}

# ---------- step 6: install personal claude config ----------
Step 6 "Installing personal ~/.claude/ config"
$bash = "C:\Program Files\Git\bin\bash.exe"
if (-not (Test-Path $bash)) { $bash = "$env:ProgramFiles\Git\bin\bash.exe" }
if (Test-Path $bash) {
    & $bash -c "cd '$($BaselinePath -replace '\\','/')' && bash scripts/install.sh" 2>&1 |
        ForEach-Object { Write-Host "    $_" }
} else {
    Warn "Git Bash not found — reboot and re-run this script."
}

# ---------- step 7: start the wiki (non-blocking, happens BEFORE claude) ----------
Step 7 "Starting the wiki"
$pythonExe = (Get-Command python -ErrorAction SilentlyContinue).Source
if ($pythonExe) {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "python '$BaselinePath\wiki\serve.py'" -WindowStyle Minimized
    Ok "wiki starting on http://localhost:7777 (new window)"
    Start-Sleep -Seconds 2
    Start-Process "http://localhost:7777"
} else {
    Warn "Python not in PATH yet — reboot and run: python $BaselinePath\wiki\serve.py"
}

# ---------- step 8: claude auth reminder ----------
Step 8 "Claude authentication — do this manually"
Write-Host "  When ready, run:  claude" -ForegroundColor White
Write-Host "  A browser will open. Log in with your company Claude account"
Write-Host "  (or personal Pro/Max until Enterprise is provisioned)."
Write-Host "  We do NOT auto-launch claude here — it's interactive and blocks this script."

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
Write-Host "If anything seems off, reboot (Rancher Desktop + PATH often need it) and re-run this script."
