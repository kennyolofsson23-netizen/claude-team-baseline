# Access Review

> Every quarter, answer: "who has access to what, and should they still?"

## Why

People change roles. Projects change hands. Temporary access becomes permanent because nobody removed it. The review exists to catch that.

For internal tools on Azure AD Easy Auth, most access is granted via Azure AD **group membership** — which is the right pattern, and which makes this review tractable.

## What to review — per product

### Azure AD access to the app itself

1. In the Azure portal, find the App Service or the App Registration backing Easy Auth.
2. Check "Users and groups" (if app-level assignment) or the `appRoles` claims configured.
3. For each group / role assigned: is the membership still correct? Get the group owner to attest.

### Azure AD group membership

1. For each Azure AD group granting access to a product: list members.
2. Anyone who has changed team, left the company, or no longer needs access → remove.
3. Owner of the group does the attestation; architect/ARB reviews the summary.

### Database access

1. Each product's Azure SQL database has a small set of logins: app service principal, ops DBAs, possibly a read-only analytics user.
2. Verify each login still maps to an active service principal or employee.
3. Revoke orphaned logins.

### Key Vault access policies

1. Identities with access to each Key Vault: who and why?
2. Prefer managed identities for apps (not named people).
3. Any named-person access that's no longer needed → remove.

### GitHub Enterprise repo access

1. Repo collaborators + teams.
2. CODEOWNERS current?
3. Outside contractors still in scope?

### Azure subscription IAM

1. Subscription-level role assignments — Owner, Contributor, Reader, custom roles.
2. Any unused? Any over-privileged?
3. This is usually an IT-owned review; coordinate timing.

## How to run it

1. Open an issue in the `claude-team-baseline` repo titled `Access review — YYYY-Q<n>` using the `access-review` issue template (add one if missing; gap-register-worthy).
2. Assign each product's section to its owner.
3. Each owner fills in their section within 2 weeks.
4. ARB reviews the summary, approves any anomalies or revokes.
5. Close the issue with a link to the summary.

## What to log

Append to each product's `docs/runbook.md` under `## Access review history`:
```
YYYY-Q<n> | reviewed by <name> | removed: <X accounts> | notes: ...
```

One line. Keeps history. Makes next review easier.

## Red flags to watch for

- A product with no named owner responsible for access reviews
- Service principals with Contributor or higher at subscription scope (should always be scoped to RG or lower)
- Guest users with long-standing access to internal tools
- `AAD Connect` sync-only accounts still in groups after being decommissioned
- Shared service accounts (looks like one person but used by many) — anti-pattern, should be managed identities
