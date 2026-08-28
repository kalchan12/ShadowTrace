#!/usr/bin/env bash
set -e

echo "=== Formatting ShadowTrace Codebase ==="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -d "$ROOT_DIR/client" ]; then
    echo "Formatting Flutter / Dart code..."
    cd "$ROOT_DIR/client"
    if command -v dart &> /dev/null; then
        dart format .
    fi
fi

echo "Formatting complete."
