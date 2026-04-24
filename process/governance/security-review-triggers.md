# Security Review Triggers

> When does a change need explicit security attention? This matrix. Anything here triggers the `security-reviewer` agent at minimum; anything starred (★) also requires ARB sign-off before merge.

## Triggers

| If your change… | Trigger | What happens |
|---|---|---|
| Touches authentication code (login, logout, token validation) ★ | Yes | `security-reviewer` agent runs + ARB sign-off |
| Touches authorization code (who-can-do-what) ★ | Yes | `security-reviewer` + ARB |
| Handles PII (personal data of any individual) ★ | Yes | `security-reviewer` + ARB + data-classification manifest updated |
| Handles financial data (salary, payments, budget) ★ | Yes | `security-reviewer` + ARB + manifest update |
| Calls an external API with credentials | Yes | `security-reviewer` agent |
| Accepts file uploads from users | Yes | `security-reviewer` agent |
| Writes user input to the database (even via ORM) | Yes | `security-reviewer` agent |
| Renders user input in HTML (Jinja, Streamlit text) | Yes | `security-reviewer` agent |
| Builds SQL queries with variables | Yes | `security-reviewer` agent (even ORM use gets a glance for injection) |
| Adds a new dependency that gets network access | Yes | `security-reviewer` agent |
| Introduces a background job that runs as a service account | Yes | `security-reviewer` agent |
| Exposes a new HTTP endpoint to internal users | Soft yes — spot check | `security-reviewer` if the endpoint reads data |
| Changes the Azure AD Easy Auth configuration ★ | Yes | `security-reviewer` + ARB |
| Changes the `.claude/data-classification.yml` file ★ | Yes | ARB |
| Adds a service account or changes its permissions ★ | Yes | ARB + IT |
| Changes Key Vault access policies ★ | Yes | ARB + IT |
| Modifies the PreToolUse hook `block-secrets.py` or `data-classification-gate.py` ★ | Yes | ARB |

## How to run the `security-reviewer` agent

It fires automatically on the keywords in `trigger-rules.yml`. You can also force it:

> spawn the security-reviewer agent on this diff

The agent looks for OWASP-pattern issues: injection, broken auth, sensitive data exposure, XXE, access control flaws, security misconfig, XSS, deserialization, vulnerable dependencies, insufficient logging.

## Scope of a security review in Phase 1

Internal-only apps behind Azure AD Easy Auth mean the outer threat surface is small. Most real risks are:

1. **Privilege misuse** — a user with legitimate login accessing data they shouldn't
2. **Dependency CVEs** — libraries with known vulnerabilities (Dependabot helps)
3. **Data leakage via logs** — PII written to App Insights
4. **Insecure deserialization** — JSON payloads with unexpected content
5. **Misconfigured role assignments** — service accounts with more permissions than needed

Deeper penetration testing is a Phase 2 consideration once we have products handling high-value data.

## What to do with a security-reviewer finding

Every finding has a severity. Treat as:

- **Critical / High** → block merge, fix before continuing
- **Medium** → fix before launch, OK to merge the current PR but a follow-up must be filed
- **Low / Informational** → note in the PR, consider for a future refactor

If the finding looks wrong, push back in the PR — the agent makes mistakes too. But the default is "fix it".

## Annual security sweep

Once per year (or after any security incident), run a security audit against all live products — not just on PR diffs. This is a gap item until we have the first few products; noted in `gap-register.md`.
