# Permissions and safety model

The baseline enforces safety in four layers. The higher the layer, the harder it is to bypass.

## The four layers

| Layer | Enforces what | Where it lives | Who owns it | Bypassable? |
|---|---|---|---|---|
| 1. Managed Claude settings | AI-side: what Claude can run, read, write | `C:\Program Files\ClaudeCode\managed-settings.json` (Phase 2) | IT + architect | No |
| 2. Project Claude settings | Same as above, project-scoped | `.claude/settings.json` in repo | Architect via PR | Architect only |
| 3. Git hooks + CI | File-side: what gets committed and what passes CI | `.pre-commit-config.yaml`, `azure-pipelines.yml` | Architect via PR | Branch policies block merge |
| 4. Required reviewers (Phase 2) | Merge-side: who must approve stack changes | ADO branch policies → Required reviewers | Architect | ADO branch protection |

Together, these mean: Claude refuses to suggest off-stack code, pre-commit refuses to stage off-stack files, CI blocks merge on violations, CODEOWNERS requires architect approval for stack-defining changes.

Today we have layers 2 and 3 active. Layer 1 comes with Phase 2 (Enterprise license). Layer 4 comes after Phase 2 as the team grows.

## What's in the deny-list (layer 2, phase 1 — active today)

From `template/.claude/settings.json`:

### Read deny
- `**/.env` and `**/.env.*` — prevents accidental secret reading
- `**/secrets/**`, `**/.ssh/**`, `**/id_rsa*`, `**/*.pem`, `**/*.key`

### Write deny
- `**/*.tsx`, `**/*.jsx` — the React escape hatch is closed by default
- `**/*.vue`, `**/*.svelte` — same for other JS frameworks
- `**/package.json` — no Node deps added by accident
- `**/package-lock.json`

### Bash deny
- `rm -rf /*`
- `git push --force*` and `git push -f *`
- `npm install react*` / `next*` / `vue*` / `svelte*`
- `npx create-react-app*`
- `npm create vite*`
- `pnpm add react*` / `yarn add react*`

### Bash allow (common dev commands)
- `git *`, `az repos pr *`, `az boards work-item *`, `az repos show*`
- `uv *`, `ruff *`, `mypy *`, `pytest*`
- `streamlit run*`, `uvicorn *`, `alembic *`
- `docker build *`, `docker run *`
- `curl -fsS *`, `ls *`, `cat *`, `which *`

If you need a command not on the allow-list, Claude will ask you. Approve it once if it's safe; or push back if it's not.

## The "no off-stack code" enforcement chain

Say a dev prompts Claude: "add React to this app".

1. **Layer 2 (Claude settings)**: The `Bash(npm install react*)` deny prevents Claude from running the install. Claude refuses verbally: "Our stack is Python + Streamlit + FastAPI. React isn't approved. Do you want me to..."
2. **Layer 2 (Write deny)**: Even if the dev types `.tsx` code by hand and asks Claude to edit it, the `Write(**/*.tsx)` deny prevents Claude from writing it.
3. **Layer 3 (Pre-commit)**: If the dev bypasses Claude and writes the `.tsx` file manually, the pre-commit hook refuses to stage it. The dev can still `git commit --no-verify` — it's not a hard block yet.
4. **Layer 3 (CI)**: The `--no-verify` bypass doesn't save them. CI re-runs the pre-commit checks on the PR, fails, and blocks merge.
5. **Layer 4 (Required reviewers)** — Phase 2: Even if CI were fixed, ADO branch policies require architect approval before merge.

At every layer a loud signal is produced: deny message, hook stderr, CI red-X. There's no silent failure.

## When a legitimate request gets blocked

It happens. Someone writes an image uploader and the `block-secrets.py` hook gets picky about a `*.png` test fixture. Fix it in the baseline:

1. Open a PR to `claude-team-baseline`
2. Update the hook (e.g. add the test fixture's directory to the allow-list)
3. Architect reviews — is this a real false-positive, or is the dev trying to work around?
4. Merge → next `git pull` in every project picks it up

Don't edit your local `.claude/` to work around a hook — your next scaffold will reset it.

## What's still possible — the residual risk

Even with all four layers, a determined developer on their own laptop can:

- Write `.tsx` files directly to disk without going through Claude
- `git commit --no-verify` to bypass pre-commit
- Push to a fork of the repo that doesn't have CODEOWNERS

The point isn't to make it impossible — it's to make it **loud, slow, and visible** so it gets caught in code review or an audit log (Phase 2). That's the realistic bar for an enterprise setup.

## Phase 2 adds

When the Enterprise license arrives:

- **`disableBypassPermissionsMode: "disable"`** — `--dangerously-skip-permissions` stops working
- **`allowManagedPermissionRulesOnly: true`** — devs can't widen the allow-list locally
- **`allowManagedMcpServersOnly: true`** — no rogue MCP servers in cloned repos
- **Forced SSO** — personal Claude accounts stop working on company machines
- **Audit PostToolUse hook** — every tool call logged to central logging
- **CODEOWNERS + branch protection** — stack-defining files need architect approval

All of this is ready in `managed-settings/example.json`. Flip the switch when the license lands.
