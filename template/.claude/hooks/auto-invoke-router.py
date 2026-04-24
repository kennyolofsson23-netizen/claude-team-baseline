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
import sys
from pathlib import Path

import yaml


RULES_PATH = Path(__file__).parent / "trigger-rules.yml"


def load_rules() -> list[dict]:
    if not RULES_PATH.exists():
        return []
    raw = yaml.safe_load(RULES_PATH.read_text(encoding="utf-8")) or []
    return [
        r for r in raw
        if isinstance(r, dict) and "match" in r and "inject" in r
    ]


def main() -> int:
    try:
        data = json.load(sys.stdin)
    except Exception:
        return 0

    prompt = (data.get("prompt") or data.get("user_prompt") or "").lower()
    if not prompt.strip():
        return 0

    try:
        rules = load_rules()
    except Exception:
        return 0

    injected: list[str] = []

    for rule in rules:
        keywords = [str(k).lower() for k in rule.get("match", [])]
        for kw in keywords:
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
