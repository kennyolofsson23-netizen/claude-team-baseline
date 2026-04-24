# Process

This directory holds the team's operating playbooks — the flows that keep products alive once they're built. The engineering side (how to code) lives in `template/.claude/`. This is the **product + operations** side (how to govern, run, and document).

Everything here is intended to be **simple and grow-with-us**. Start with the templates, fill them in as you go, promote patterns to the baseline once they're proven.

## Structure

```
process/
├── product-lifecycle/          Flows: idea → brief → build → launch → iterate → sunset
├── governance/                 ARB, change approval, security review, change-wish register
├── maintenance/                Keep-the-lights-on: calendar, patching, backups, access, incidents
├── documentation/              Templates for ADR, runbook, post-mortem, changelog
├── productification/           The "is this a real internal product?" gate
├── data-classification/        How to decide if Claude may see a file
└── gap-register.md             Living list of things we haven't sorted yet
```

Each subdirectory has its own README explaining what's in it and when to use it.

## How the pieces connect

```
Idea
  │
  ▼
Product brief          ◄── process/product-lifecycle/brief-template.md
  │
  ▼
Architect / ARB review ◄── process/governance/arb.md
  │
  ▼
SPEC.md + ARCHITECTURE.md + UX design brief
  │
  ▼
scaffold-project.sh    ◄── creates docs/ with ADRs, runbook, post-mortems, CHANGELOG
  │
  ▼
Build (feature-builder, test-writer, code-reviewer)
  │
  ▼
Launch checklist       ◄── process/product-lifecycle/launch-checklist.md
  │
  ▼
Maintenance            ◄── process/maintenance/calendar.md
  │
  ▼ (eventually)
Sunset checklist       ◄── process/product-lifecycle/sunset-checklist.md
```

At every stage, `process/` has the template. Each project has the filled-in copy in its own `docs/`.

## Who owns what

| Artifact | Owner | Edited how |
|---|---|---|
| All templates in `process/` | Architect / ARB | PR to this repo |
| `process/gap-register.md` | Everyone contributes, ARB curates | PR or GitHub issue with `gap` template |
| `process/governance/change-wishes/` | Everyone proposes, ARB decides | PR or GitHub issue with `change-wish` template |
| Per-project `docs/` (ADRs, runbook, etc.) | Project owner | Normal PR in the product repo |

## Where to start reading

- **I'm new here** → `product-lifecycle/` first, then `documentation/`
- **I have a proposal for a change** → `governance/change-wishes/README.md`
- **Something broke** → `maintenance/incident-response.md`
- **I'm launching something** → `product-lifecycle/launch-checklist.md`
- **I'm scared of a thing** → `gap-register.md` — add it there, talk about it at the next ARB
