#!/usr/bin/env bash
# Lacktorget Intel — Mac setup for Johannes
# Run: bash <(curl -fsSL https://raw.githubusercontent.com/kennyolofsson23-netizen/claude-team-baseline/main/scripts/setup-mac-lacktorget.sh)
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}  [ok]${NC} $*"; }
warn() { echo -e "${YELLOW}  [!]${NC} $*"; }
die()  { echo -e "${RED}  [X]${NC} $*"; exit 1; }

echo ""
echo "==> Lacktorget Intel — Mac setup"
echo ""

# 1. Homebrew
echo "==> Step 1: Homebrew"
if ! command -v brew &>/dev/null; then
  warn "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi
ok "brew $(brew --version | head -1)"

# 2. GitHub CLI
echo ""
echo "==> Step 2: GitHub CLI"
if ! command -v gh &>/dev/null; then
  brew install gh
fi
ok "gh $(gh --version | head -1)"

# 3. Node
echo ""
echo "==> Step 3: Node.js"
if ! command -v node &>/dev/null; then
  brew install node
fi
ok "node $(node --version)"

# 4. Claude Code
echo ""
echo "==> Step 4: Claude Code"
if ! command -v claude &>/dev/null; then
  npm install -g @anthropic-ai/claude-code
fi
ok "claude $(claude --version 2>&1 | head -1)"

# 5. GitHub auth
echo ""
echo "==> Step 5: GitHub login"
if ! gh auth status &>/dev/null; then
  warn "Logging in to GitHub..."
  gh auth login
fi
ok "logged in as $(gh api user --jq .login)"

# 6. ~/.claude config
echo ""
echo "==> Step 6: Claude config (~/.claude)"
mkdir -p ~/.claude

cat > ~/.claude/settings.json << 'SETTINGS'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-6",
  "autoUpdates": true,
  "theme": "dark",
  "dangerouslySkipPermissions": true,
  "permissions": {
    "allow": [
      "Bash(git*)", "Bash(npm *)", "Bash(npx *)", "Bash(node *)", "Bash(ls *)", "Bash(cat *)"
    ],
    "deny": [
      "Read(**/.env)", "Read(**/.env.*)", "Bash(rm -rf /*)", "Bash(git push --force*)"
    ]
  }
}
SETTINGS
ok "settings.json written"

cat > ~/.claude/CLAUDE.md << 'CLAUDEMD'
# Personal Claude Instructions
- Concise over verbose. Show the answer, not the reasoning.
- If I paste an error, diagnose and fix.
- Projects live in ~/work/<project-name>/
- Active project: lacktorget-intel (Next.js 15, TypeScript, Prisma 7, Neon)
CLAUDEMD
ok "CLAUDE.md written"

cat > ~/.claude/.mcp.json << 'MCPJSON'
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
MCPJSON
ok ".mcp.json written"

# 7. Clone project
echo ""
echo "==> Step 7: Clone lacktorget-intel"
mkdir -p ~/work
if [ -d ~/work/lacktorget-intel ]; then
  warn "~/work/lacktorget-intel already exists, pulling latest..."
  git -C ~/work/lacktorget-intel pull
else
  gh repo clone kennyolofsson23-netizen/lacktorget-intel ~/work/lacktorget-intel
fi
ok "cloned to ~/work/lacktorget-intel"

# 8. Install deps
echo ""
echo "==> Step 8: npm install"
cd ~/work/lacktorget-intel && npm install
ok "dependencies installed"

echo ""
echo "================================================================"
echo " Done! Start working with:"
echo ""
echo "   cd ~/work/lacktorget-intel && claude"
echo "================================================================"
echo ""
