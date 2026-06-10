#!/usr/bin/env bash
# Compatibility wrapper: refresh GitHub data and regenerated stats through the main generator.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/generate_wiki.sh" --update-all
