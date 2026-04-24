# Hooks — the plumbing behind the scenes

Hooks are small scripts that run at specific moments in a Claude Code session. They're the team's enforcement layer — security guards, quality gates, and the auto-invoke router.

## The 7 hooks

| Hook | Fires on | What it does |
|---|---|---|
| **auto-invoke-router.py** | Every user prompt (`UserPromptSubmit`) | Reads `trigger-rules.yml`, matches keywords, injects system-reminders that tell Claude which agent / skill to use |
| **block-dangerous.py** | Every Bash tool call (`PreToolUse`) | Blocks destructive commands: `rm -rf /`, force pushes, database drops. Warns on `git push origin main`, `docker push`, etc. |
| **block-secrets.py** | Every Write/Edit tool call (`PreToolUse`) | Blocks writes to credential files, `.env.production`, SSH keys, and images outside asset directories |
| **pre-commit-secrets.py** | Before `git commit` (`PreToolUse` on Bash git commit) | Scans staged files for secret patterns (API keys, private keys, `.env` files); blocks the commit if found |
| **commit-guard.js** | On `git commit -m "..."` | Enforces conventional commit format (`feat:`, `fix:`, `docs:`, etc.) + 72-char subject limit |
| **validate-agent-schema.js** | On Write/Edit to `agents/*.md` | Validates YAML frontmatter (name, model, tools required) before allowing agent file changes |
| **trigger-rules.yml** | (Not a hook — data read by auto-invoke-router.py) | The keyword → action mapping |

## The auto-invoke router — how Claude knows what to do

This is the most important hook. When you type a prompt, Claude Code runs `auto-invoke-router.py` before sending the prompt to Claude. The script:

1. Reads the user's prompt
2. Looks up keywords in `trigger-rules.yml`
3. For each match, appends a `<system-reminder>` to what Claude sees
4. Claude acts on the reminders — spawns the right agent, follows the right skill, applies the right rule

### Example

You type:

```
deploy this to staging
```

`auto-invoke-router.py` sees the keyword `deploy`, looks it up:

```yaml
- name: deployer
  match: ["deploy", "release", "ship to", "push to prod", "publish"]
  inject: |
    Spawn the `deployer` agent. Verify tests pass, build Docker image, push
    to <registry.company.internal>, deploy to the target from ARCHITECTURE.md
    (default Azure App Service), smoke-test, write DEPLOY.md.
```

Claude receives your prompt PLUS the injected reminder. It spawns the `deployer` agent and runs the full deploy workflow — verification, build, push, deploy, smoke-test, DEPLOY.md.

You never had to pick an agent or remember the workflow. You just said what you wanted.

### Seeing which rules fired

If you're curious what auto-invoked on a particular prompt, you can ask Claude: "which auto-invoke rules fired here?" It will list them.

## Adding a new trigger rule

Rules live in `template/.claude/hooks/trigger-rules.yml`. The format:

```yaml
- name: my-rule
  match: ["keyword one", "keyword two"]
  inject: |
    One or more sentences that will be appended to the prompt as a
    system-reminder. Keep it short — long injections bloat every session.
```

Rules are:

- Matched case-insensitively
- Matched as substrings (so "deploy" matches "deploy this", "deploying", "redeploy")
- Applied one injection per rule per prompt (no spam)

Keep keywords specific enough to avoid false positives. "test" alone would match too much — "run tests" or "write a test" is better.

## Safety hooks — what can you do if one blocks you?

If `block-dangerous.py` or `block-secrets.py` blocks a legitimate action, it means either:

1. The hook is wrong — file an issue or open a PR to adjust it
2. You're doing something you shouldn't — reconsider

For a real emergency where you need to bypass, you'd talk to the architect. **There is no developer-side override** and that's deliberate.

## Debugging hooks

All hooks write to stderr when they block or warn. If a hook is misbehaving:

```bash
# Run the hook manually with a sample input
echo '{"prompt": "deploy this"}' | python template/.claude/hooks/auto-invoke-router.py
```

The output should be the injections that would have been appended.

If a Python hook crashes, Claude Code shows the stderr in your terminal. Read it, fix it, or flag it to the architect.
