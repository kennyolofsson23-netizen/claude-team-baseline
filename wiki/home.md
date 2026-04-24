<div class="banner">
  <h1>claude-team-baseline</h1>
  <p>The shared Claude Code configuration for our engineering team. One repo, one install script, one way of working.</p>
</div>

> **New here? Install is one PowerShell line.** Open `SETUP.md` in the repo root, copy the command, paste into PowerShell-as-Administrator, wait ~10 min. Wiki + Claude ready to go.

## What this wiki covers

This is the living documentation for our team's Claude Code setup. If you're new, start with **Getting Started**. If you're debugging, jump to **Cheat sheets** or **Troubleshooting**. Everything that affects how we build is documented here — and when we change something, we update this wiki in the same PR.

<div class="cards">
  <div class="card">
    <h3>I'm setting up my work PC</h3>
    <p>One PowerShell command installs everything and wires up the baseline.</p>
    <p><a href="#/getting-started/bootstrap.md"><strong>→ One-command setup</strong></a></p>
  </div>

  <div class="card">
    <h3>I just joined the team</h3>
    <p>How Claude works here, what we expect from you on day one.</p>
    <p><a href="#/getting-started/onboarding.md"><strong>→ Onboarding</strong></a></p>
  </div>

  <div class="card">
    <h3>I want to understand the stack</h3>
    <p>Python, Streamlit, FastAPI, MSSQL — why we picked each and how we use them.</p>
    <p><a href="#/stack/overview.md"><strong>→ The team stack</strong></a></p>
  </div>

  <div class="card">
    <h3>I need to know how Claude decides things</h3>
    <p>Agents, skills, hooks, the auto-invoke router — the plumbing behind the magic.</p>
    <p><a href="#/claude/layers.md"><strong>→ How Claude works here</strong></a></p>
  </div>

  <div class="card">
    <h3>Something's broken</h3>
    <p>Troubleshooting and the cheat sheet of commands you'll use daily.</p>
    <p><a href="#/reference/troubleshooting.md"><strong>→ Troubleshooting</strong></a></p>
  </div>

  <div class="card">
    <h3>Where is this going?</h3>
    <p>Phase 1 is what you're using now. Phase 2-4 is where we're heading.</p>
    <p><a href="#/roadmap.md"><strong>→ Roadmap</strong></a></p>
  </div>

  <div class="card">
    <h3>Product lifecycle + process</h3>
    <p>How a product goes from idea to live to retired. Governance, maintenance, docs, checklists.</p>
    <p><a href="#/process/README.md"><strong>→ Process</strong></a></p>
  </div>

  <div class="card">
    <h3>Gap register</h3>
    <p>Open questions and things we haven't sorted yet — the team's living TODO list.</p>
    <p><a href="#/process/gap-register.md"><strong>→ Gaps</strong></a></p>
  </div>
</div>

## At a glance

<span class="pill">12 agents</span>
<span class="pill">5 stack skills</span>
<span class="pill">9 hooks</span>
<span class="pill">7 rules</span>
<span class="pill pill-outline">Python 3.12</span>
<span class="pill pill-outline">Streamlit · FastAPI</span>
<span class="pill pill-outline">MSSQL</span>
<span class="pill pill-outline">uv · ruff · pytest</span>

## How to read this wiki

- **Orange code blocks** are things you run as-is in your terminal.
- **Callouts with a blue bar** on the left are things you must not skip.
- **Tables** are for quick lookups — don't try to memorise them.
- If a link is broken or a page is missing, that's a bug — tell your architect and they'll fix it.

> **Everyone on the team is learning, including the architect.** When you don't understand something, ask Claude in your editor *or* ask a teammate. No question is dumb. The only failure mode is shipping code you don't understand.

## Conventions in code snippets

```bash
# Lines starting with # are comments — skip them
$ command-you-type-at-the-prompt     # the $ is not part of the command
  output-claude-shows-you            # no $ — this is output
```

```python
# Python examples have a header line with the file path
# src/app.py
def greet(name: str) -> str:
    return f"hello {name}"
```

## Credits

This baseline was set up by Kenny as the starting point. It evolves with the team — every dev who notices a better pattern contributes a PR. The repo is the single source of truth; this wiki is its face.
