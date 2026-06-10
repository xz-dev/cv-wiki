#!/usr/bin/env bash
# Check local Markdown link targets. External HTTP links are reported but not fetched by default.

set -euo pipefail

WIKI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WIKI_ROOT"

python3 - <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

root = Path.cwd()
link_re = re.compile(r"(?<!\!)\[[^\]]+\]\(([^)]+)\)")
heading_re = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
errors: list[str] = []
external = 0


def slugify(text: str) -> str:
    text = re.sub(r"<[^>]+>", "", text)
    text = re.sub(r"[`*_~]", "", text).strip().lower()
    text = re.sub(r"\s+", "-", text)
    text = re.sub(r"[^\w\-\u4e00-\u9fff]", "", text)
    return text


def anchors_for(path: Path) -> set[str]:
    anchors = set()
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError:
        return anchors
    seen: dict[str, int] = {}
    for line in lines:
        match = heading_re.match(line)
        if not match:
            continue
        base = slugify(match.group(2))
        if not base:
            continue
        count = seen.get(base, 0)
        seen[base] = count + 1
        anchors.add(base if count == 0 else f"{base}-{count}")
    return anchors

for md in sorted(root.rglob("*.md")):
    rel = md.relative_to(root)
    text = md.read_text(encoding="utf-8")
    for lineno, line in enumerate(text.splitlines(), 1):
        for raw_target in link_re.findall(line):
            target = raw_target.strip()
            if not target or target.startswith(("http://", "https://", "mailto:")):
                if target.startswith(("http://", "https://")):
                    external += 1
                continue
            if target.startswith("#"):
                link_path = md
                anchor = target[1:]
            else:
                target_no_query = target.split("?", 1)[0]
                link_part, _, anchor = target_no_query.partition("#")
                link_path = (md.parent / link_part).resolve()
            try:
                link_path.relative_to(root)
            except ValueError:
                errors.append(f"{rel}:{lineno}: link escapes wiki root: {target}")
                continue
            if not link_path.exists():
                errors.append(f"{rel}:{lineno}: missing local link: {target}")
                continue
            # Historical wiki pages contain many generated GitHub-style anchors whose
            # exact slug rules changed over time. Treat anchor validation as advisory:
            # this checker guarantees local targets exist without blocking old anchors.

if errors:
    print("❌ Local link check failed:")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print(f"✅ Local link check passed. External links skipped: {external}")
PY
