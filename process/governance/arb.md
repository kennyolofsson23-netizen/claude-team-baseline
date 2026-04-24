# Architectural Review Board (ARB)

## What the ARB is

The ARB is the forum where **technical and product decisions that outlast a single product** are made. One person or several — today it's Kenny alone; it grows with the team.

The ARB exists so that:
- The stack does not fragment across products
- Security and data-classification decisions happen once, not per-project
- Change wishes from the team have a predictable place to land
- Mistakes become lessons that the whole team inherits, not tribal knowledge held by the person who made them

## What the ARB decides

**Always an ARB decision**:
- Changes to the approved stack (new language, new framework, new database)
- New SaaS or cloud service dependencies (anything billed separately)
- Changes to the permissions / security model
- Changes to data-classification rules
- Creating, retiring, or materially re-scoping a product
- Changes to this `process/` directory and to `template/.claude/`

**Product-level decisions** (not ARB):
- Which features to build in a sprint
- Implementation choices inside the approved stack
- UI copy and small UX decisions

**Informed by ARB, decided by owner**:
- Feature priorities within a product
- Deploy cadence for a specific product

## Who sits on the ARB

Currently: **Kenny** (sole ruler).

As the team grows, expected additions:
- Architect / tech lead (if different from the sole ruler)
- Security representative (for security-sensitive decisions)
- Product representative (for lifecycle + priority decisions)
- UX representative (for cross-product design decisions)

Keep it small. A 10-person ARB decides nothing.

## Cadence

| Type | Frequency | Format | Who |
|---|---|---|---|
| **Standing ARB review** | Every 2 weeks, 30 minutes | Teams meeting | ARB members |
| **Async change wishes** | Continuous | GitHub issues with the `change-wish` template | Anyone in the team can file |
| **Emergency ARB** | Ad hoc | Called by the architect when something can't wait | Architect + at least one other reviewer |

Until the team actually has 2-3 change wishes to discuss, the standing ARB can be a solo 5-minute review by Kenny. As volume grows, grow the meeting.

## How a decision gets made

1. Someone files a **change wish** (GitHub issue, `change-wish` template) — see `governance/change-wishes/TEMPLATE.md`
2. Wish appears in the register (`governance/change-wishes/`) or tracked in GitHub
3. ARB reviews at the next cadence meeting
4. Decision recorded on the issue + (if material) in the affected repo as an ADR
5. If approved and requires code changes — PR to `claude-team-baseline` follows the decision
6. Decision communicated in the relevant Teams channel

## Decision outcomes

Each change wish gets one of:

- **Approved — do now** → PR follows, gets merged
- **Approved — defer** → added to a milestone or gap-register entry
- **Declined** → reason recorded; wish remains visible so others don't refile
- **Needs more info** → back to the proposer with specific questions

## Records

All decisions are recorded somewhere public to the team:

- **GitHub issue** with labels (`approved`, `declined`, `deferred`)
- **ADR** in the affected repo for technical decisions with long-term impact
- **Gap register entry** if the decision is "yes but we need to solve X first"

No verbal-only decisions. If it wasn't written down, it didn't happen.
