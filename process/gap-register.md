# Gap Register

Living list of things we haven't sorted yet. Add to it when you notice a gap. Review at each ARB meeting.

Format per entry: one section, small, with clear owner and status.

---

## How to use

1. **You notice something missing** — a convention, a tool, a process, a decision.
2. **Add an entry here** (or open a GitHub issue with the `gap` template — both work).
3. **Assign an owner** — the person best positioned to resolve it. If unclear, `ARB`.
4. **Tag a status** — `open`, `in-progress`, `resolved`, `parked`.
5. ARB reviews the register at each cadence meeting — decides which gaps to close next.

A resolved gap leaves the register and moves to a proper ADR or into one of the `process/` templates. We keep the history so we remember what we decided.

---

## Open gaps

### Communications channel for alerts + support
- **Status**: open
- **Owner**: Kenny
- **Why it matters**: Every runbook says "alert goes to channel X" and every support doc says "ask in channel Y" — we need to pick Teams channel(s) or email address(es).
- **Current workaround**: Ad-hoc — people DM each other.
- **Needed by**: First production app launch.

### Ivanti integration depth
- **Status**: open
- **Owner**: IT + ARB
- **Why it matters**: Runbooks and post-mortems reference Ivanti tickets. Question: manual linkage only, or automate (create Ivanti ticket from an App Insights alert)?
- **Current workaround**: Manual ticket creation.
- **Needed by**: Once we have enough alerts to feel the manual burden.

### UX graphical template
- **Status**: open
- **Owner**: UX expert + Claude
- **Why it matters**: Without a shared design system, every product ends up with a different look and feel. Juniors make design decisions they shouldn't.
- **Current workaround**: Streamlit and FastAPI defaults — functional but inconsistent.
- **Proposed first step**: UX expert fills `process/productification/design-system-brief.md` for the first real product.
- **Needed by**: Before the first customer-facing (internal-customer) UI ships.

### Data classification content
- **Status**: framework-ready, content-empty
- **Owner**: ARB
- **Why it matters**: The data-classification hook is built and running allow-by-default. We need to populate the manifest with real rules once we know what data each product handles.
- **Current workaround**: Warn + log on heuristic matches; manual review of sensitive files.
- **Needed by**: Per-product, at launch.

### First real product
- **Status**: in-progress
- **Owner**: Kenny
- **Why it matters**: The baseline is designed but untested with a real product. Until we build one, some assumptions are unverified.
- **Candidate**: `mssql-tool` — CLI-native Python tool + MCP server for on-prem MSSQL via Windows domain auth. Validates the full scaffold + ships something useful.
- **Needed by**: Asap — until then this is all theory.

### MSSQL MCP — on-prem CLI tool
- **Status**: parked — planned as first project
- **Owner**: Kenny
- **Why it matters**: On-prem MSSQL with Windows domain auth has no suitable existing MCP. Decision: build CLI-native Python tool (`pyodbc` + `Trusted_Connection=yes`) that doubles as an MCP server (`mssql-tool serve`). Team gets a useful terminal tool and Claude gets DB access via the same codebase.
- **Current workaround**: Claude reads SQLAlchemy models; cannot query the DB directly.
- **Needed by**: After first project is scaffolded and a test DB is provisioned.

### Error-tracking MCP — choose one
- **Status**: open
- **Owner**: ARB
- **Why it matters**: Sentry MCP and Azure Application Insights both give Claude access to error data. Pick one; wire one; stop there.
- **Current workaround**: Paste tracebacks into chat.
- **Needed by**: First production incident.

### Superpowers plugin — install or inline?
- **Status**: open, my recommendation: install as plugin
- **Owner**: Kenny
- **Why it matters**: Ships 14 discipline skills (TDD, planning, debugging, code review). Currently baseline relies on CLAUDE.md + agents to enforce the same behaviours — works but less explicit than having the skills themselves.
- **Current workaround**: CLAUDE.md hard-codes the key rules.
- **Proposed**: Add `claude plugin install superpowers` to SETUP.md after bootstrap.
- **Needed by**: Before team rollout ideally, but not blocking.

### On-call rotation
- **Status**: parked
- **Why it matters**: Once we have production apps, someone needs to be the first responder when alerts fire.
- **Current workaround**: Internal tools + business-hours-only means low urgency.
- **Needed by**: When we ship something that breaks outside business hours and someone notices.

### Enterprise Claude license + MDM rollout (managed-settings)
- **Status**: parked (Phase 2)
- **Owner**: IT + Kenny
- **Why it matters**: `managed-settings/example.json` is ready. Needs Enterprise license + MDM to deploy.
- **Current workaround**: Phase 1 enforcement via project `.claude/settings.json` + CI.
- **Needed by**: When team grows past ~5 devs or handles sensitive data.

### ARB volume
- **Status**: parked
- **Why it matters**: ARB is currently Kenny alone. When change-wishes or team size grow, we'll need real members + a real cadence.
- **Needed by**: When the first 2-3 change-wishes pile up in one cycle.

### Backup restore automation
- **Status**: open
- **Owner**: IT + ARB
- **Why it matters**: Monthly manual restore verification is painful and often skipped. A scripted restore-to-scratch-DB + smoke query would make it reliable.
- **Current workaround**: Manual, per-product.
- **Needed by**: Once we have 3+ production MSSQL databases.

### Secret rotation cadence
- **Status**: open
- **Owner**: IT + ARB
- **Why it matters**: Key Vault supports auto-rotation but our apps need to be written to handle it gracefully (no hard-coded validation at boot of a "current" secret).
- **Current workaround**: None (no rotation yet).
- **Needed by**: Before first annual compliance review.

### Retention + log policy
- **Status**: parked
- **Why it matters**: App Insights retention defaults to 90 days. OK for most internal, but if any app handles regulated data, retention policy must be explicit.
- **Needed by**: First product handling regulated data.

---

## Resolved gaps

*(Entries move here once closed, with a link to the ADR / PR that resolved them.)*
