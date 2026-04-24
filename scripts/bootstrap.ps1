# One-shot bootstrap for claude-team-baseline on a fresh Windows work PC.
#
# Run as Administrator in PowerShell 7+:
#
#   PowerShell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1 -RepoUrl "<your-git-host-url>"
#
# Or, if you already git-cloned the baseline and just want to finish setup:
#
#   PowerShell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1
#
# Idempotent — safe to re-run.

param(
    [string]$RepoUrl = "",
    [string]$WorkDir = "$env:USERPROFILE\work"
)

$ErrorActionPreference = "Continue"   # keep going if one winget line fails
$ProgressPreference    = "SilentlyContinue"

function Step($n, $msg) { Write-Host ""; Write-Host "=== STEP $n — $msg ===" -ForegroundColor Cyan }
function Ok($msg)       { Write-Host "  [ok] $msg" -ForegroundColor Green }
function Warn($msg)     { Write-Host "  [!!] $msg" -ForegroundColor Yellow }
function Fail($msg)     { Write-Host "  [X]  $msg" -ForegroundColor Red }

# Require admin
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Fail "This script must run as Administrator. Right-click PowerShell -> Run as Administrator."
    exit 1
}

# ---------- STEP 1 — prerequisites via winget ----------
Step 1 "Installing prerequisites via winget"

$packages = @(
    @{ Id = "Git.Git";                                    Label = "Git"                        },
    @{ Id = "GitHub.cli";                                 Label = "GitHub CLI"                 },
    @{ Id = "OpenJS.NodeJS.LTS";                          Label = "Node.js LTS (for Claude)"   },
    @{ Id = "Python.Python.3.12";                         Label = "Python 3.12"                },
    @{ Id = "Anthropic.ClaudeCode";                       Label = "Claude Code"                },
    @{ Id = "astral-sh.uv";                               Label = "uv (Python dep manager)"    },
    @{ Id = "Microsoft.VisualStudioCode";                 Label = "VS Code"                    },
    @{ Id = "Docker.DockerDesktop";                       Label = "Docker Desktop"             },
    @{ Id = "Microsoft.ODBCDriverForSQLServer.18";        Label = "MS ODBC Driver 18"          }
)

foreach ($p in $packages) {
    Write-Host ("  installing {0} ({1})" -f $p.Label, $p.Id)
    $installed = winget list --id $p.Id --source winget 2>&1 | Select-String $p.Id
    if ($installed) {
        Ok ("{0} already installed" -f $p.Label)
        continue
    }
    winget install --id $p.Id --source winget --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
    $check = winget list --id $p.Id --source winget 2>&1 | Select-String $p.Id
    if ($check) { Ok ("{0} installed" -f $p.Label) } else { Warn ("{0} — winget returned non-zero. Check manually." -f $p.Label) }
}

# Refresh PATH in this session so newly installed tools are reachable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# ---------- STEP 2 — user env vars ----------
Step 2 "Setting Python UTF-8 defaults"
[Environment]::SetEnvironmentVariable("PYTHONUTF8",      "1",     "User")
[Environment]::SetEnvironmentVariable("PYTHONIOENCODING","utf-8", "User")
$env:PYTHONUTF8       = "1"
$env:PYTHONIOENCODING = "utf-8"
Ok "PYTHONUTF8=1 PYTHONIOENCODING=utf-8 (User env)"

# ---------- STEP 3 — work directory ----------
Step 3 "Work directory"
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null
Ok $WorkDir

# ---------- STEP 4 — clone or link baseline ----------
Step 4 "Baseline repo"
$BaselinePath = Join-Path $WorkDir "claude-team-baseline"

if (Test-Path $BaselinePath) {
    Ok "Baseline already present at $BaselinePath"
    if ($RepoUrl -ne "") {
        Write-Host "  Pulling latest..."
        & git -C $BaselinePath pull --ff-only 2>&1 | ForEach-Object { Write-Host "    $_" }
    }
} else {
    if ($RepoUrl -eq "") {
        Warn "No -RepoUrl provided and baseline not cloned yet."
        Write-Host "  Either:"
        Write-Host "    A) re-run this script with: -RepoUrl <your-git-host-url>"
        Write-Host "    B) manually: git clone <url> $BaselinePath"
        Write-Host "  Then re-run this script to finish setup."
        exit 1
    }
    Write-Host ("  Cloning {0} -> {1}" -f $RepoUrl, $BaselinePath)
    & git clone $RepoUrl $BaselinePath
    if (-not (Test-Path $BaselinePath)) {
        Fail "Clone failed. Check the repo URL and your GitHub auth (run: gh auth login)."
        exit 1
    }
    Ok "Cloned"
}

# ---------- STEP 5 — run install.sh via Git Bash ----------
Step 5 "Running install.sh (Git Bash)"
$bash = "C:\Program Files\Git\bin\bash.exe"
if (-not (Test-Path $bash)) {
    $bash = "$env:ProgramFiles\Git\bin\bash.exe"
}
if (Test-Path $bash) {
    & $bash -c "cd '$($BaselinePath -replace '\\','/')' && bash scripts/install.sh" 2>&1 |
        ForEach-Object { Write-Host "    $_" }
} else {
    Warn "Git Bash not found. Reboot and re-run, or run manually:"
    Write-Host "    bash $BaselinePath\scripts\install.sh"
}

# ---------- STEP 6 — open Claude login ----------
Step 6 "Next steps"
Write-Host ""
Write-Host "  1. If Docker / Claude did not register in PATH, REBOOT and re-run this script." -ForegroundColor White
Write-Host "  2. Authenticate:"                                                                   -ForegroundColor White
Write-Host "       gh auth login"                                                                 -ForegroundColor Gray
Write-Host "       claude          # browser popup for Claude login"                              -ForegroundColor Gray
Write-Host "  3. Scaffold your first project:"                                                    -ForegroundColor White
Write-Host ("       bash {0}\scripts\scaffold-project.sh {1}\hello-claude" -f $BaselinePath, $WorkDir) -ForegroundColor Gray
Write-Host "  4. Open the wiki (browsable docs):"                                                 -ForegroundColor White
Write-Host ("       start {0}\wiki\index.html" -f $BaselinePath)                                  -ForegroundColor Gray
Write-Host ""
Write-Host "Bootstrap complete." -ForegroundColor Green
