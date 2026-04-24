#!/usr/bin/env bash
# claude-team-baseline — personal layer installer
# Run once per machine. Safe to re-run.

set -euo pipefail

BASELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
WORK_DIR="$HOME/work"

echo "claude-team-baseline installer"
echo "  baseline : $BASELINE_DIR"
echo "  target   : $CLAUDE_DIR"
echo ""

# ---------- step 1: prerequisites ----------
echo "==> Step 1: checking prerequisites"

need() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "  [X] missing: $1 — install via winget or vendor installer"
        return 1
    fi
    echo "  [ok] $1 ($($1 --version 2>&1 | head -1))"
}

FAIL=0
need git    || FAIL=1
need az     || FAIL=1
need python || FAIL=1
need claude || FAIL=1
need uv     || FAIL=1

if [ "$FAIL" -eq 1 ]; then
    echo ""
    echo "Prerequisites missing. See HANDOVER.md Step 1."
    exit 1
fi

# ---------- step 2: personal claude dir ----------
echo ""
echo "==> Step 2: setting up ~/.claude/"

mkdir -p "$CLAUDE_DIR"

# back up existing CLAUDE.md if different from ours
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    if ! cmp -s "$BASELINE_DIR/dotfiles/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
        BACKUP="$CLAUDE_DIR/CLAUDE.md.bak.$(date +%Y%m%d-%H%M%S)"
        cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP"
        echo "  [backup] existing CLAUDE.md → $BACKUP"
    fi
fi

cp "$BASELINE_DIR/dotfiles/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  [copy] personal CLAUDE.md → $CLAUDE_DIR/CLAUDE.md"

# settings.json — only create if missing, never overwrite
if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$BASELINE_DIR/dotfiles/settings.json" "$CLAUDE_DIR/settings.json"
    echo "  [copy] default settings.json → $CLAUDE_DIR/settings.json"
else
    echo "  [keep] existing settings.json (will not overwrite)"
fi

# ---------- step 3: work directory convention ----------
echo ""
echo "==> Step 3: work directory convention"
mkdir -p "$WORK_DIR"
echo "  [ok] $WORK_DIR ready for project clones"

# ---------- step 4: python UTF-8 profile ----------
echo ""
echo "==> Step 4: Git Bash profile — Python UTF-8 defaults"
PROFILE="$HOME/.bashrc"
touch "$PROFILE"
if ! grep -q "PYTHONUTF8" "$PROFILE" 2>/dev/null; then
    {
        echo ""
        echo "# claude-team-baseline: Python UTF-8 defaults"
        echo "export PYTHONUTF8=1"
        echo "export PYTHONIOENCODING=utf-8"
    } >> "$PROFILE"
    echo "  [append] PYTHONUTF8 + PYTHONIOENCODING → $PROFILE"
else
    echo "  [keep] PYTHONUTF8 already in profile"
fi

# ---------- step 5: verify ----------
echo ""
echo "==> Step 5: verify"
bash "$BASELINE_DIR/scripts/verify.sh"

echo ""
echo "Done. Next: bash $BASELINE_DIR/scripts/scaffold-project.sh <new-project-name>"
