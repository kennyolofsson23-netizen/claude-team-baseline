# MCP Servers — team baseline

> MCP (Model Context Protocol) servers are tools Claude can call during a session. Live in `template/.mcp.json` which is copied into every scaffolded project.

## What ships in the baseline (Phase 1)

| MCP | Purpose | Cost | Risk |
|---|---|---|---|
| **context7** | Fetch current docs for Python libs, FastAPI, SQLAlchemy, Streamlit, MSSQL, etc. | Free | Very low — read-only |
| **playwright** | Run a headless browser for UI smoke tests (used by `qa-runner`) | Free | Low — local browser |
| **sequential-thinking** | Structured step-by-step reasoning for complex tasks | Free | None — pure reasoning helper |

All three are `npx`-based, no auth required, start on demand. Claude Code will prompt once to trust them per project.

## Deferred (Phase 2 — add when ready)

| MCP | Purpose | Why deferred |
|---|---|---|
| **mssql** | Let Claude inspect schema + run SELECTs against a real MSSQL database | Needs Key Vault credentials wired up — gap-register entry |
| **sentry** | Pull error data from Sentry for debugging | Only if we adopt Sentry (Azure App Insights is the Azure-native alternative — pick one). ARB decision. |
| **azure** | Query Azure resources (App Services, logs, bills) | Useful, but authentication model needs architect review. |

## How to enable a deferred MCP

1. File a change-wish with the MCP name, the permission scope, and how credentials will be handled
2. ARB reviews
3. If approved: add to `template/.mcp.json` in a PR to `claude-team-baseline`
4. Every new project inherits it

## How to remove / swap an MCP

Same process — PR to `claude-team-baseline`. Do not edit `.mcp.json` per-project locally — it diverges from the team.

## If an MCP fails to start

Each MCP is `npx`-based, so the first invocation in a project downloads the package. First-run can be slow or fail behind a corporate proxy. If one doesn't start:

- Confirm Node / npm is on PATH: `node -v && npm -v`
- Try the `npx` command manually to see the actual error
- If blocked by proxy: configure npm proxy, or pre-install the package globally and change `.mcp.json` to use the binary directly
- Last resort: remove that MCP from your local `.mcp.json` (do NOT commit; file a gap-register entry instead)

## Data sensitivity

MCPs are tool calls — whatever you pass them goes to the MCP server process. For `context7`, that's an Upstash-hosted service (check Upstash privacy terms). For `playwright`, everything stays local. For `sequential-thinking`, everything stays local.

When we add `mssql` later, its queries will go through the server-local process — no DB data leaves the machine. Still, **the data-classification gate applies**: files you Read that contain regulated data may end up in MCP inputs. The same rules apply.
