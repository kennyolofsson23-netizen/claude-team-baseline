#!/usr/bin/env python3
"""PreToolUse hook — data classification gate.

Runs before every Read / Edit / Grep. Checks the target file against
`.claude/data-classification.yml`:

1. If a rule denies access -> BLOCK (exit 2) with explanation.
2. If no rule matches -> fall back to `default_claude_access` (allow by default).
3. On allow, still scans the file for heuristic PII/regulated patterns.
   Action per `heuristics.action`:
     - "warn-and-log" (Phase 1 default): warn via stderr, continue.
     - "block": deny the read with the warning reason.

Designed to fail-open: if the manifest is missing or malformed, we allow
the read (do not break the session) but log a note to stderr so the
architect notices.

See process/data-classification/README.md for the bigger picture.
"""

from __future__ import annotations

import fnmatch
import json
import os
import re
import sys
from pathlib import Path


def load_manifest(repo_root: Path) -> dict:
    """Best-effort load of .claude/data-classification.yml.

    We use a minimal YAML parser (no PyYAML dependency) that handles our
    known shape — default keys + a list of rules. Any parse issue =
    fail-open (allow + log).
    """
    path = repo_root / ".claude" / "data-classification.yml"
    if not path.exists():
        return {}

    try:
        raw = path.read_text(encoding="utf-8")
    except OSError:
        return {}

    data: dict = {"rules": []}
    current_rule: dict | None = None
    in_rules = False
    in_heuristics = False

    def parse_inline_list(s: str) -> list[str]:
        s = s.strip().strip("[]")
        if not s:
            return []
        return [item.strip().strip('"').strip("'") for item in s.split(",") if item.strip()]

    for raw_line in raw.splitlines():
        line = raw_line.rstrip()
        stripped = line.strip()

        if not stripped or stripped.startswith("#"):
            continue

        # Top-level keys
        if not line.startswith(" "):
            if stripped.startswith("default_class:"):
                data["default_class"] = stripped.split(":", 1)[1].strip().strip('"')
                in_rules = False
                in_heuristics = False
            elif stripped.startswith("default_claude_access:"):
                val = stripped.split(":", 1)[1].strip().lower()
                data["default_claude_access"] = val in ("true", "yes", "1")
                in_rules = False
                in_heuristics = False
            elif stripped.startswith("rules:"):
                rhs = stripped.split(":", 1)[1].strip()
                if rhs in ("", "[]"):
                    data["rules"] = []
                    in_rules = True
                else:
                    in_rules = False
                in_heuristics = False
            elif stripped.startswith("heuristics:"):
                data.setdefault("heuristics", {})
                in_heuristics = True
                in_rules = False
            continue

        # Inside rules
        if in_rules:
            if stripped.startswith("- "):
                if current_rule:
                    data["rules"].append(current_rule)
                current_rule = {}
                rest = stripped[2:]
                if ":" in rest:
                    k, _, v = rest.partition(":")
                    v = v.strip()
                    if k == "paths":
                        current_rule["paths"] = parse_inline_list(v)
                    else:
                        current_rule[k] = v.strip('"')
                continue
            if current_rule is not None and ":" in stripped:
                k, _, v = stripped.partition(":")
                v = v.strip()
                if k == "paths":
                    current_rule["paths"] = parse_inline_list(v)
                elif k == "claude_access":
                    current_rule[k] = v.lower() in ("true", "yes", "1")
                else:
                    current_rule[k] = v.strip('"')

        # Inside heuristics
        elif in_heuristics:
            if ":" in stripped and not stripped.startswith("- "):
                k, _, v = stripped.partition(":")
                v = v.strip()
                if k == "enabled":
                    data["heuristics"]["enabled"] = v.lower() in ("true", "yes", "1")
                elif k == "action":
                    data["heuristics"]["action"] = v.strip('"')
                elif k == "patterns":
                    rhs = v
                    if rhs in ("", "[]"):
                        data["heuristics"]["patterns"] = []
            elif stripped.startswith("- "):
                data["heuristics"].setdefault("patterns", []).append(stripped[2:].strip().strip('"'))

    if current_rule:
        data["rules"].append(current_rule)

    data.setdefault("rules", [])
    data.setdefault("default_claude_access", True)
    return data


def path_matches(file_path: str, patterns: list[str]) -> bool:
    norm = file_path.replace("\\", "/")
    for pat in patterns:
        if fnmatch.fnmatch(norm, pat):
            return True
        if fnmatch.fnmatch(os.path.basename(norm), pat):
            return True
    return False


HEURISTIC_REGEX = {
    "personnummer-se": re.compile(r"\b(?:\d{6}|\d{8})-\d{4}\b"),
    "credit-card-luhn": re.compile(r"\b(?:\d[ -]?){13,19}\b"),
    "ssn-us": re.compile(r"\b\d{3}-\d{2}-\d{4}\b"),
    "header-pii-column": re.compile(
        r"(?:^|[,;\t])\s*(?:ssn|personnummer|pnr|salary|salaries|mrn|ccn|credit[_-]?card)\b",
        re.IGNORECASE,
    ),
}


def luhn_valid(digits: str) -> bool:
    digits = re.sub(r"[^\d]", "", digits)
    if len(digits) < 13 or len(digits) > 19:
        return False
    total = 0
    for i, ch in enumerate(reversed(digits)):
        d = int(ch)
        if i % 2 == 1:
            d *= 2
            if d > 9:
                d -= 9
        total += d
    return total % 10 == 0


def scan_heuristics(content: str, patterns: list[str]) -> list[str]:
    hits: list[str] = []
    for name in patterns:
        regex = HEURISTIC_REGEX.get(name)
        if regex is None:
            continue
        match = regex.search(content)
        if match:
            if name == "credit-card-luhn" and not luhn_valid(match.group(0)):
                continue
            hits.append(name)
    return hits


def main() -> int:
    try:
        data = json.load(sys.stdin)
    except Exception:
        return 0  # fail-open

    tool = data.get("tool_name") or data.get("tool") or ""
    tool_input = data.get("tool_input", {})
    file_path = (
        tool_input.get("file_path")
        or tool_input.get("path")
        or ""
    )

    # Only apply to file-reading tools
    if tool not in ("Read", "Edit", "Grep", "Write"):
        return 0

    if not file_path:
        return 0

    repo_root = Path(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd())
    manifest = load_manifest(repo_root)
    if not manifest:
        return 0  # no manifest = default allow

    try:
        rel = str(Path(file_path).resolve().relative_to(repo_root.resolve())).replace("\\", "/")
    except Exception:
        rel = file_path.replace("\\", "/")

    # Match rules in order
    for rule in manifest.get("rules", []):
        patterns = rule.get("paths", [])
        if path_matches(rel, patterns) or path_matches(file_path, patterns):
            if rule.get("claude_access") is False:
                cls = rule.get("class", "restricted")
                rationale = rule.get("rationale", "no rationale given")
                print(
                    f"BLOCKED: `{rel}` is classified `{cls}` (rationale: \"{rationale}\").\n"
                    "Claude is not permitted to read this file. Tell the user: "
                    "\"This file is classified {cls}. I cannot process it via the LLM. "
                    "Either use a sandboxed tool approved for this class, or ask ARB to reclassify.\"".format(cls=cls),
                    file=sys.stderr,
                )
                return 2
            break  # rule allows — stop looking

    # Heuristic scan (only on Read)
    if tool == "Read":
        h = manifest.get("heuristics", {}) or {}
        if h.get("enabled", True):
            action = (h.get("action") or "warn-and-log").lower()
            patterns = h.get("patterns") or list(HEURISTIC_REGEX.keys())
            try:
                content = Path(file_path).read_text(encoding="utf-8", errors="ignore")
            except Exception:
                content = ""
            if content:
                hits = scan_heuristics(content[:200_000], patterns)
                if hits:
                    msg = (
                        f"DATA-CLASSIFICATION WARNING: `{rel}` contains heuristic matches "
                        f"for: {', '.join(hits)}. The file is not currently classified in "
                        ".claude/data-classification.yml. Proceed with caution; do NOT include "
                        "the raw sensitive values in your response, and suggest adding a "
                        "classification rule to the ARB."
                    )
                    print(msg, file=sys.stderr)
                    if action == "block":
                        return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
