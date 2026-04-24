#!/usr/bin/env bash
# Scaffold a new Python project from the claude-team-baseline template.
#
# Usage: bash scripts/scaffold-project.sh <target-dir>
#   <target-dir> may be ".", an existing empty dir, or a new dir.
# Example:
#   bash ~/work/claude-team-baseline/scripts/scaffold-project.sh ~/work/my-new-app

set -euo pipefail

BASELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$BASELINE_DIR/template"

TARGET_DIR="${1:-}"
if [ -z "$TARGET_DIR" ]; then
    echo "Usage: bash scripts/scaffold-project.sh <target-dir>"
    exit 1
fi

# normalize path
mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
PROJECT_NAME="$(basename "$TARGET_DIR")"

echo "Scaffolding  : $PROJECT_NAME"
echo "Template     : $TEMPLATE_DIR"
echo "Target       : $TARGET_DIR"
echo ""

# refuse to scaffold into a non-empty dir (unless only a .git/ exists)
shopt -s nullglob dotglob
ENTRIES=("$TARGET_DIR"/*)
shopt -u nullglob dotglob
for e in "${ENTRIES[@]}"; do
    name="$(basename "$e")"
    if [ "$name" != ".git" ] && [ "$name" != "." ] && [ "$name" != ".." ]; then
        echo "[X] Target is not empty (found: $name)."
        echo "    Refusing to scaffold to avoid overwriting. Use an empty dir or a new one."
        exit 1
    fi
done

echo "==> Copying template"
# copy everything including dotfiles
cp -R "$TEMPLATE_DIR"/. "$TARGET_DIR"/

echo "==> Stamping project name into pyproject.toml"
if command -v sed >/dev/null 2>&1; then
    # portable in-place edit across bash / mac / linux / git-bash
    sed_inplace() {
        if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi
    }
    sed_inplace "s/project-name-here/$PROJECT_NAME/g" "$TARGET_DIR/pyproject.toml" 2>/dev/null || true
    sed_inplace "s/project-name-here/$PROJECT_NAME/g" "$TARGET_DIR/.env.example" 2>/dev/null || true
fi

echo "==> Initializing git (if not already)"
cd "$TARGET_DIR"
if [ ! -d .git ]; then
    git init -b main
fi

echo "==> Writing project README"
cat > README.md <<README
# $PROJECT_NAME

<One-line description from ARCHITECTURE.md.>

## Setup
\`\`\`bash
uv sync
cp .env.example .env   # fill in real values
uv run alembic upgrade head    # once migrations exist
uv run streamlit run src/app.py     # or: uv run uvicorn src.main:app --reload
\`\`\`

## Stack
Python 3.12 · Streamlit / FastAPI · SQLAlchemy + MSSQL · uv · ruff · pytest

## Conventions
See \`.claude/CLAUDE.md\` for the full team rules.
README

echo "==> Installing dependencies"
if command -v uv >/dev/null 2>&1; then
    uv sync || echo "  (uv sync failed — run it manually after fixing pyproject.toml)"
else
    echo "  [skip] uv not installed — run 'uv sync' after installing uv"
fi

echo "==> Running smoke tests"
if command -v uv >/dev/null 2>&1 && [ -f uv.lock ]; then
    uv run pytest tests/test_smoke.py -q || echo "  (smoke tests failed — investigate before building features)"
fi

echo "==> Initial commit"
git add -A
git -c user.name="$(git config user.name || echo Scaffold)" \
    -c user.email="$(git config user.email || echo scaffold@local)" \
    commit -m "chore: scaffold $PROJECT_NAME from claude-team-baseline" --allow-empty >/dev/null 2>&1 || true

echo ""
echo "Done."
echo ""
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Edit .env with your database connection"
echo "  3. claude     # start a session — read tasks/todo.md first"
echo "  4. Ask Claude to plan your first feature. It will follow the baseline rules."
