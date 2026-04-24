#!/usr/bin/env python3
"""UserPromptSubmit hook — routes prompts to the right agent / skill via keyword triggers.

Reads trigger-rules.yml (in the same directory), matches the user's prompt against
trigger keywords, and injects system-reminder blocks that tell Claude which agent
to spawn or which skill to follow. Juniors never have to pick tools manually —
Claude sees the reminder and acts on it.

Format of injected reminder:
  <system-reminder>
  AUTO-INVOKE: <agent-or-skill> — <reason>
  <action instruction>
  </system-reminder>

Exits 0 always (never blocks a prompt). Hook output on stdout is appended to the
prompt Claude sees.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


RULES_PATH = Path(__file__).parent / "trigger-rules.yml"


def load_rules() -> list[dict]:
    """Parse the YAML rules file with a minimal line-based parser.

    We avoid requiring PyYAML at runtime. Expected structure:

        - name: writing-plans
          match: ["plan", "design", "architecture"]
          inject: |
            AUTO-INVOKE: writing-plans skill + architect agent.
            Produce a plan before code. ...
    """
    if not RULES_PATH.exists():
        return []

    text = RULES_PATH.read_text(encoding="utf-8")
    rules: list[dict] = []
    current: dict = {}
    capturing_inject = False
    inject_lines: list[str] = []

    for raw in text.splitlines():
        line = raw.rstrip()

        if line.startswith("- name:"):
            if current:
                if capturing_inject:
                    current["inject"] = "\n".join(inject_lines).strip()
                rules.append(current)
            current = {"name": line.split(":", 1)[1].strip()}
            capturing_inject = False
            inject_lines = []
            continue

        if capturing_inject:
            if line and not line.startswith("  "):
                current["inject"] = "\n".join(inject_lines).strip()
                capturing_inject = False
                inject_lines = []
            else:
                inject_lines.append(line.lstrip())
                continue

        if line.strip().startswith("match:"):
            # e.g.  match: ["plan", "design"]
            rhs = line.split(":", 1)[1].strip()
            matches = re.findall(r'"([^"]*)"', rhs)
            current["match"] = [m.lower() for m in matches]
            continue

        if line.strip().startswith("inject:"):
            capturing_inject = True
            inject_lines = []
            continue

    if current:
        if capturing_inject:
            current["inject"] = "\n".join(inject_lines).strip()
        rules.append(current)

    return [r for r in rules if "match" in r and "inject" in r]


def main() -> int:
    try:
        data = json.load(sys.stdin)
    except Exception:
        return 0

    prompt = (data.get("prompt") or data.get("user_prompt") or "").lower()
    if not prompt.strip():
        return 0

    rules = load_rules()
    injected: list[str] = []

    for rule in rules:
        for kw in rule.get("match", []):
            if kw and kw in prompt:
                name = rule["name"]
                body = rule["inject"]
                injected.append(
                    f"<system-reminder>\nAUTO-INVOKE: {name}\n{body}\n</system-reminder>"
                )
                break  # one injection per rule per prompt

    if injected:
        sys.stdout.write("\n\n".join(injected))
        sys.stdout.write("\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
