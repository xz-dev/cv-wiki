#!/usr/bin/env bash
# Compatibility wrapper for the reference validator mentioned by CROSS_REFERENCES.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/check-links.sh"
