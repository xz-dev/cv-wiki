#!/usr/bin/env bash
# Validate wiki structure, metadata consistency, and generated visualization prerequisites.

set -euo pipefail

WIKI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WIKI_ROOT"

failures=0

pass() { printf '✅ %s\n' "$1"; }
fail() { printf '❌ %s\n' "$1"; failures=$((failures + 1)); }
warn() { printf '⚠️  %s\n' "$1"; }

require_file() {
    local path=$1
    [[ -f "$path" ]] && pass "found $path" || fail "missing $path"
}

require_dir() {
    local path=$1
    [[ -d "$path" ]] && pass "found $path/" || fail "missing $path/"
}

printf '🔍 Validating cv-wiki at %s\n\n' "$WIKI_ROOT"

for path in README.md HOW_TO_ANALYZE.md CONTRIBUTING.md CROSS_REFERENCES.md MEMORY_CLEANUP.md metadata.json; do
    require_file "$path"
done

for dir in by-year by-scale by-domain deep-dive personal-projects scripts; do
    require_dir "$dir"
done

for year in 2018 2019 2020 2021 2022 2023 2024 2025 2026; do
    require_file "by-year/${year}.md"
done

for scale in mega large medium small; do
    require_file "by-scale/${scale}-projects.md"
done

for domain in linux-kernel windows-drivers container-tech ai-infrastructure android gentoo-ecosystem; do
    require_file "by-domain/${domain}.md"
done

if jq . metadata.json >/dev/null; then
    pass 'metadata.json is valid JSON'
else
    fail 'metadata.json is invalid JSON'
fi

if python3 - <<'PY'
from pathlib import Path
path = Path('scripts/generate_visualizations.py')
compile(path.read_text(encoding='utf-8'), str(path), 'exec')
PY
then
    pass 'generate_visualizations.py compiles'
else
    fail 'generate_visualizations.py has syntax errors'
fi

if bash -n scripts/generate_wiki.sh && bash -n scripts/coverage.sh && bash -n scripts/validate.sh; then
    pass 'shell scripts parse'
else
    fail 'one or more shell scripts have syntax errors'
fi

if [[ -f generate_wiki.sh ]]; then
    bash -n generate_wiki.sh && pass 'legacy root generate_wiki.sh parses' || fail 'legacy root generate_wiki.sh has syntax errors'
fi

md_count=$(find . -type f -name '*.md' | wc -l)
metadata_total=$(jq -r '.total_prs // empty' metadata.json 2>/dev/null || true)
printf '\n📊 Summary\n'
printf -- '- Markdown files: %s\n' "$md_count"
printf -- '- metadata.total_prs: %s\n' "${metadata_total:-unknown}"

placeholder_count=$(grep -R -F '占位符 - 待AI从Memory Service提取数据填充' . --include='*.md' | wc -l || true)
if (( placeholder_count > 0 )); then
    warn "remaining placeholder markers: $placeholder_count"
else
    pass 'no placeholder markers remain'
fi

if (( failures > 0 )); then
    printf '\n❌ Validation failed with %s issue(s).\n' "$failures"
    exit 1
fi

printf '\n✅ Validation passed.\n'
