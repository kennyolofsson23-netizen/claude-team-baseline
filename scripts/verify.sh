#!/usr/bin/env bash
# claude-team-baseline — verify installed state

set -uo pipefail

BASELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
FAIL=0

check() {
    local label="$1"
    local cond="$2"
    if eval "$cond" >/dev/null 2>&1; then
        echo "  [ok] $label"
    else
        echo "  [X]  $label"
        FAIL=1
    fi
}

echo "Verification"

# tool availability
check "Git Bash"     "command -v bash"
check "Python 3.12+" "python --version | grep -E '3\.1[2-9]|3\.[2-9][0-9]'"
check "Claude Code"  "command -v claude"
check "uv"           "command -v uv"
check "az"           "command -v az"

# personal baseline
check "Personal CLAUDE.md" "test -f $CLAUDE_DIR/CLAUDE.md"
check "Personal settings"  "test -f $CLAUDE_DIR/settings.json"
check "~/work/ exists"     "test -d $HOME/work"

# baseline repo sanity
check "Template .claude/"  "test -d $BASELINE_DIR/template/.claude"
check "Template CLAUDE.md" "test -f $BASELINE_DIR/template/.claude/CLAUDE.md"

# agent count (target: 13)
AGENT_COUNT=$(ls "$BASELINE_DIR/template/.claude/agents"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$AGENT_COUNT" -ge 12 ]; then
    echo "  [ok] Agents: $AGENT_COUNT found"
else
    echo "  [X]  Agents: $AGENT_COUNT found (expected 12)"
    FAIL=1
fi

# skill count (target: 5 stack-specific)
SKILL_COUNT=$(ls -d "$BASELINE_DIR/template/.claude/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$SKILL_COUNT" -ge 5 ]; then
    echo "  [ok] Skills: $SKILL_COUNT found"
else
    echo "  [X]  Skills: $SKILL_COUNT found (expected 5)"
    FAIL=1
fi

# hook count (target: 9 — auto-invoke-router + 5 safety + trigger-rules.yml + 2 validators + remind-verification)
HOOK_COUNT=$(ls "$BASELINE_DIR/template/.claude/hooks"/* 2>/dev/null | wc -l | tr -d ' ')
if [ "$HOOK_COUNT" -ge 9 ]; then
    echo "  [ok] Hooks: $HOOK_COUNT found"
else
    echo "  [X]  Hooks: $HOOK_COUNT found (expected 9)"
    FAIL=1
fi

# rules count (target: 7)
RULES_COUNT=$(ls "$BASELINE_DIR/template/.claude/rules"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$RULES_COUNT" -ge 7 ]; then
    echo "  [ok] Rules: $RULES_COUNT found"
else
    echo "  [X]  Rules: $RULES_COUNT found (expected 7)"
    FAIL=1
fi

# scaffold template sanity
for required in pyproject.toml Dockerfile azure-pipelines.yml .pre-commit-config.yaml \
                src/app.py src/main.py src/settings.py src/db.py src/errors.py \
                tests/conftest.py tests/test_smoke.py \
                alembic.ini alembic/env.py .env.example .gitignore ; do
    if [ -f "$BASELINE_DIR/template/$required" ]; then
        :
    else
        echo "  [X]  Missing in template: $required"
        FAIL=1
    fi
done

echo ""
if [ "$FAIL" -eq 0 ]; then
    echo "Ready."
    exit 0
else
    echo "One or more checks failed. Re-run install.sh or fix the missing items."
    exit 1
fi
