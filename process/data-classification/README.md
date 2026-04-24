# Data Classification

> Deciding what data Claude is allowed to see before it sees it.

## Why this exists

Claude Code reads files you point it at. Whatever it reads goes into the LLM. For an enterprise, that means:

- Employee PII could be exposed to a third-party LLM
- Regulated data could violate compliance rules
- Confidential strategy / financial data could leak

The mitigations Claude Enterprise offers (no training on customer data, Zero Data Retention) are necessary but not sufficient. The **tighter** question is: should this data cross the machine boundary into the LLM at all?

## How the system works

### 1. The manifest (per-project)

Every project has `.claude/data-classification.yml`:

```yaml
# Default — applies when no rule matches
default_class: employee-standard
default_claude_access: true

rules:
  - paths: ["data/finance/**", "**/payroll*.csv"]
    class: restricted-finance
    claude_access: false
    rationale: "SOX / audit"

  - paths: ["data/customer-pii/**"]
    class: restricted-pii
    claude_access: false
    rationale: "GDPR special category"
```

Starter template is allow-by-default with an **empty rules list** — we don't have regulated data yet. As real data classes appear, ARB approves additions.

### 2. The PreToolUse hook

`template/.claude/hooks/data-classification-gate.py` runs before every Read / Edit / Grep. It:

1. Checks the file path against the manifest
2. If a rule denies access → **BLOCK** the tool call and tell Claude why
3. If no rule matches → fall back to `default_claude_access` (allow)
4. Run a heuristic scan for obvious regulated patterns — **warn + log** (Phase 1); can upgrade to block later

### 3. Heuristics (Phase 1 — warn + log only)

Without a classification rule, the hook still looks for obvious signs:

- Swedish personnummer (`YYYYMMDD-XXXX`)
- Credit card numbers (Luhn-valid)
- SSNs (US format `XXX-XX-XXXX`)
- Column headers strongly suggesting PII (`ssn`, `personal_number`, `pnr`, `ccn`, `mrn`, `salary`)

When found, Claude sees a **warning** injected into context:

> The file you just read contained patterns that look like regulated data (Swedish personnummer). The file is not currently classified in `.claude/data-classification.yml`. Please (a) proceed cautiously, (b) suggest adding a classification rule, and (c) do not include the raw sensitive values in your response to the user.

### 4. The CLAUDE.md reflex

The team CLAUDE.md has a "Data classification — check before processing" section that builds the reflex: if it smells regulated and the manifest is silent, stop and ask.

## What's allowed today

Since our starter manifest is allow-by-default with no rules:

- **Everything is allowed by default.**
- The framework is in place. When we start handling real regulated data, ARB adds the rules.

## Adding a rule

Follow the change-wish process:

1. File a change-wish explaining: what data class, why restricted, which paths
2. ARB reviews
3. If approved: PR to the affected product's `.claude/data-classification.yml`
4. Optionally: the same pattern graduates to `template/.claude/data-classification.yml` so all new projects inherit it

## Classes we might adopt

- `employee-standard` — normal employee data (email, name, job title, manager) — Claude access OK
- `employee-sensitive` — HR records (compensation, reviews, PIPs) — Claude access NO
- `customer-pii` — customer personal data — depends on consent / regulation
- `restricted-finance` — salary data, payment data, financials — Claude access NO
- `restricted-health` — if we ever handle health data
- `confidential-strategy` — unreleased plans / unannounced products

None of these are active today. When the first real case appears, we draft the classification rule and ARB reviews.

## What this system does NOT do

- **Stream detection** — if a user pastes sensitive data directly into the Claude prompt, the hook can't see that. CLAUDE.md reflex catches this; juniors should be trained to notice.
- **Output redaction** — Claude's response could include sensitive data from a file it was allowed to read. The hook doesn't filter responses.
- **Full DLP** — data loss prevention is a bigger topic. Azure Purview or Microsoft Information Protection handles enterprise-wide DLP; this hook is Claude-scoped.
- **Encryption** — data is protected by Azure encryption at rest and in transit; we don't add another layer.

## Review

The manifest is reviewed annually by ARB, or whenever a new product adds a new data class. See `maintenance/calendar.md`.
