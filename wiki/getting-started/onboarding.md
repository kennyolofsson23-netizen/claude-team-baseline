# Welcome to the team

This is your day-one guide. You will not need any other documentation. When in doubt, ask Claude.

## What Claude is, here

Claude Code is your senior engineer. It knows our stack, our conventions, our testing discipline. It writes code with you, reviews your work, catches bugs, and explains concepts when you're stuck.

Rules of engagement:
- **Always ask Claude first** before writing code yourself. Describe what you want to build, let it plan, let it implement.
- **Always let Claude write the test first**. Then it implements. Then it runs everything. This is not optional.
- **Never bypass Claude's plan**. If it proposes a plan, read it. If you disagree, say so. Do not just say "ok" — it will code whatever was planned.
- **Read the code Claude writes**. Understanding the output is how you grow. Claude will explain anything you ask about.

## Your first day

### 1. Get set up

Follow `HANDOVER.md` if your machine is fresh. If your architect already set you up, skip to step 2.

### 2. Open your first project

```bash
cd ~/work
bash ~/work/claude-team-baseline/scripts/scaffold-project.sh my-first-app
cd my-first-app
claude
```

Type to Claude:

> I just joined the team. Show me around this project. Explain what each file does and how I'd add a new page.

Claude will walk you through the Streamlit app, the MSSQL data layer, the test setup, and the CI pipeline.

### 3. Do the onboarding task

Every new dev does the same task on their first day: add a "hello world" page to the scaffold app that reads one row from the database and displays it. Claude already knows how — just ask:

> Help me add a "Hello" page that reads one row from the `customers` table and shows the customer's name. Follow our standard process.

Claude will:
1. Propose a plan (test, data access, UI, wire up, verify). Read it.
2. Write a test. Run it — it fails.
3. Write the code. Run the test — it passes.
4. Run ruff, mypy, pytest, and open the page in Playwright. Show you it works.

You will watch it do this. That's deliberate. Watch once, and you'll know the rhythm for everything else you build.

### 4. Read, do not skim, the team CLAUDE.md

Open `.claude/CLAUDE.md` in your project. Read it once, slowly. These are the rules Claude follows — and therefore the rules you work inside. Ten minutes now saves you hours of confusion later.

### 5. Ask for your first real task

Tell your architect / Kenny you're ready. They'll put your first ticket in `tasks/todo.md`. Open Claude and say:

> Read tasks/todo.md and help me start on the top item.

Claude takes it from there.

---

## Rules you need to internalize

### The stack is the stack
Python, Streamlit, FastAPI (rarely), SQLAlchemy + MSSQL, uv, ruff, pytest. That's it. If you think we need something else, propose it in a PR to `claude-team-baseline`, do not just install it.

### Tests always come first
Not sometimes. Not when you remember. Every behavior gets a test before the implementation. Claude writes the test. You read it. You say "looks right". Only then does it implement.

### "Done" means verified
If you haven't run the full test suite, run ruff, run mypy, and (for UI) taken a Playwright screenshot — it's not done. Claude handles the running. Your job is to refuse to merge anything that hasn't passed.

### Ask, don't guess
Never write code you don't understand. Every time Claude outputs something confusing, stop and ask: "explain this line". Claude will. Build your mental model one piece at a time.

### Commit small, commit often
One logical change per commit. Claude will suggest commit messages that follow our convention. Use them.

### Pair with Claude, don't be typed-at
This is a conversation, not a code generator. You are driving — Claude is helping. When it suggests something, think about whether it fits the task. If it doesn't, push back.

---

## Common beginner questions

**"Claude suggested using React / MongoDB / raw SQL — should I let it?"**
No. The team CLAUDE.md forbids off-stack choices. If Claude suggests one, say "we use <our-stack>, do it that way". If you are certain our stack cannot do what's needed, tag the architect.

**"My test is failing and I don't know why."**
Paste the error into Claude. Say "diagnose this". Do not guess. Do not try to make the test pass by deleting the assertion — Claude will catch you and so will code review.

**"Claude keeps asking me to plan first. Can I skip that?"**
No. The plan is how we catch problems early. It takes 30 seconds and saves hours. Read the plan, approve it, move on.

**"I want to use a library that's not on our approved list."**
Ask Claude to check if our existing stack solves the problem first. 90% of the time it does. For the 10% where it doesn't, open a PR to `claude-team-baseline` proposing the addition.

---

## When you're stuck

In order of preference:
1. Ask Claude with a clear description of what you tried and what happened.
2. Re-read the plan Claude made. Did you skip a step?
3. Read the `.claude/CLAUDE.md` section that covers what you're trying to do.
4. Message your architect. Include: the task, what Claude said, what you tried, the error.

You will not be judged for asking. You will be judged for silently shipping broken code.

---

Welcome. You're going to do great work here.
