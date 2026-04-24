#!/usr/bin/env python3
"""Stop hook — prints the verification gate when Claude signals it is done.

Reads the transcript to check the last assistant message for completion language.
If found, prints a reminder to stderr so the developer sees it in the terminal.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

DONE_SIGNALS = [
    "done", "complete", "finished", "implemented", "all tests pass",
    "ready to merge", "ship it", "deployed", "pushed",
]

GATE = (
    "\n── VERIFICATION GATE ──────────────────────────────\n"
    "  uv run ruff format --check\n"
    "  uv run ruff check\n"
    "  uv run mypy\n"
    "  uv run pytest --cov --cov-fail-under=60\n"
    "────────────────────────────────────────────────────\n"
)


def main() -> int:
    try:
        data = json.load(sys.stdin)
    except Exception:
        return 0

    transcript_path = data.get("transcript_path", "")
    if not transcript_path:
        return 0

    try:
        transcript = json.loads(Path(transcript_path).read_text(encoding="utf-8"))
        messages = transcript if isinstance(transcript, list) else transcript.get("messages", [])

        last_assistant = next(
            (m for m in reversed(messages) if m.get("role") == "assistant"),
            None,
        )
        if not last_assistant:
            return 0

        content = str(last_assistant.get("content", "")).lower()
        if any(signal in content for signal in DONE_SIGNALS):
            print(GATE, file=sys.stderr)
    except Exception:
        pass

    return 0


if __name__ == "__main__":
    sys.exit(main())
