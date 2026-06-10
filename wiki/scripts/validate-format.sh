#!/usr/bin/env bash
# Lightweight Markdown format checks for wiki content.

set -euo pipefail

WIKI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WIKI_ROOT"

python3 - <<'PY'
from __future__ import annotations

import sys
from pathlib import Path

root = Path.cwd()
failures = 0
warnings = 0

for path in sorted(root.rglob("*.md")):
    rel = path.relative_to(root)
    data = path.read_bytes()

    if data.startswith(b"\xef\xbb\xbf"):
        print(f"❌ BOM found: {rel}")
        failures += 1

    if data and not data.endswith(b"\n"):
        print(f"❌ Missing trailing newline: {rel}")
        failures += 1

    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError as exc:
        print(f"❌ Invalid UTF-8: {rel}: {exc}")
        failures += 1
        continue

    if "\t" in text:
        print(f"⚠️  Tab characters: {rel}")
        warnings += 1

if failures:
    print(f"❌ Markdown format validation failed with {failures} issue(s), {warnings} warning(s).")
    sys.exit(1)

print(f"✅ Markdown format validation passed ({warnings} warning(s)).")
PY
