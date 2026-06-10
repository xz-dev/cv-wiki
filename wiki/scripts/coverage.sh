#!/usr/bin/env bash
# Report wiki content coverage and remaining placeholder files.

set -euo pipefail

WIKI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WIKI_ROOT"

placeholder_pattern="占位符 - 待AI从Memory Service提取数据填充"

printf '# Wiki Coverage Report\n\n'
printf -- '- Wiki root: `%s`\n' "$WIKI_ROOT"
printf -- '- Markdown files: %s\n' "$(find . -type f -name '*.md' | wc -l)"
printf -- '- Total files: %s\n' "$(find . -type f | wc -l)"
printf -- '- Total size: %s KB\n' "$(du -sk . | awk '{print $1}')"
printf -- '- Placeholder markers: %s\n\n' "$(grep -R -F "$placeholder_pattern" . --include='*.md' | wc -l || true)"

printf '## Directory coverage\n\n'
printf '| Directory | Markdown files | Placeholder files |\n'
printf '|---|---:|---:|\n'
for dir in by-year by-scale by-domain deep-dive personal-projects deep-dive/websites; do
    if [[ -d "$dir" ]]; then
        md_count=$(find "$dir" -maxdepth 1 -type f -name '*.md' | wc -l)
        placeholder_count=$(grep -R -l -F "$placeholder_pattern" "$dir" --include='*.md' 2>/dev/null | wc -l || true)
        printf '| `%s/` | %s | %s |\n' "$dir" "$md_count" "$placeholder_count"
    fi
done

printf '\n## Remaining placeholder files\n\n'
placeholder_files=$(grep -R -l -F "$placeholder_pattern" . --include='*.md' 2>/dev/null | sort || true)
if [[ -z "$placeholder_files" ]]; then
    printf 'None.\n'
else
    while IFS= read -r file; do
        [[ -n "$file" ]] && printf -- '- `%s`\n' "${file#./}"
    done <<< "$placeholder_files"
fi
