# Agents — what each one does

An "agent" in Claude Code is a purpose-built sub-engineer you can spawn for a specific task. The main Claude session delegates to an agent, the agent does focused work with its own instruction set, and returns a result.

**You almost never pick an agent manually.** The [auto-invoke router](hooks.md) fires the right agent based on your prompt. This page documents what each one does so you can recognize the output.

## The 12 agents

| Agent | Fires when | What it does |
|---|---|---|
| **architect** | You ask to plan, design, or architect something | Produces SPEC.md + ARCHITECTURE.md before any code is written. Picks Streamlit vs FastAPI vs pure API based on the product profile. |
| **spec-writer** | You ask for user stories, requirements, or acceptance criteria | Writes SPEC.md with user stories in "As X, I want Y, so that Z" form + testable acceptance criteria. |
| **feature-builder** | You ask to implement a feature after a plan exists | Writes the code following the plan. Test-first rhythm. Commits per feature. |
| **test-writer** | You ask to write tests, add tests, cover behaviour | Writes pytest tests. Tests mirror src/ layout. Uses real MSSQL for DB tests — never mocks the database. |
| **test-architect** | You need a testing strategy for a big feature | Produces a TEST_PLAN.md — test pyramid, E2E flows, property-based candidates. |
| **code-reviewer** | You ask to review, check your work, or say "ready for PR" | Blocking code review — correctness, types, error handling, style, security smells. You don't merge until it signs off. |
| **security-reviewer** | Your prompt mentions auth, login, password, token, secret, crypto | OWASP-style review. Injection risks, secret exposure, auth flaws. |
| **performance-reviewer** | Your prompt mentions slow, optimize, N+1, hot path | Looks for N+1 queries, bundle size, memory leaks, unnecessary loops. |
| **qa-runner** | You say "done", "finished", "ready to ship", "complete" | Runs the full verification gate: ruff format, ruff check, mypy, pytest with coverage. Blocks the "done" claim if anything fails. |
| **error-detective** | You paste a traceback or say "bug", "error", "crash" | Diagnoses root cause, reproduces the issue, proposes + applies a fix. |
| **refactoring-specialist** | You ask to refactor, clean up, simplify, extract | Behaviour-preserving structural changes only. One refactoring per commit. Tests pass before and after. |
| **deployer** | You say "deploy", "release", "ship", "push to prod" | Full verification gate, Docker build, push to registry, Azure App Service deploy, smoke test, write DEPLOY.md. |
| **project-scaffolder** | You say "new project", "scaffold", "start a new" | Copies the baseline template, runs `uv sync`, initializes git, runs smoke test. |

## What you'll see when an agent fires

The auto-invoke hook inserts a message like:

```
<system-reminder>
AUTO-INVOKE: deployer
Spawn the `deployer` agent. Verify tests pass, build Docker image, push
to <registry.company.internal>, deploy to the target from ARCHITECTURE.md
(default Azure App Service), smoke-test, write DEPLOY.md.
</system-reminder>
```

You don't see this in your terminal — Claude sees it before deciding what to do. The result to you is: Claude starts following the agent's instructions.

## How to know which agent is working

If you want to know, just ask Claude: "which agent is running this?" It will tell you.

If Claude is NOT using an agent when it should be, you can force it:

> Use the code-reviewer agent to check my work.

Or:

> Spawn the security-reviewer agent for this auth flow.

But in most cases the auto-invoke router handles it.

## Modifying an agent

Every agent is a markdown file in `.claude/agents/`. To change one:

1. Open a PR to `claude-team-baseline`
2. Edit `template/.claude/agents/<name>.md`
3. Architect reviews
4. Merge → every project picks it up on next pull

Do NOT edit `.claude/agents/` in your own project. The team version will overwrite it on the next scaffold or baseline-bump.

## Creating a new agent

If a task is delegated repeatedly (≥ 2 times) and doesn't match an existing agent, it's a candidate for a new agent. Open a PR to `claude-team-baseline` proposing it. Use an existing agent as a template — see `template/.claude/agents/code-reviewer.md` for the simplest structure.
