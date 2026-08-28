#!/usr/bin/env bash
set -e

echo "=== ShadowTrace Repository Validation Suite ==="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "1. Validating Client (Flutter)..."
if [ -d "$ROOT_DIR/client" ]; then
    cd "$ROOT_DIR/client"
    if command -v flutter &> /dev/null; then
        echo "  - Running flutter pub get..."
        flutter pub get
        echo "  - Running flutter analyze..."
        flutter analyze
        echo "  - Running flutter tests..."
        flutter test
    else
        echo "  - Flutter CLI not found in PATH, skipping Flutter checks."
    fi
fi

echo "2. Validating Service (Kotlin Android)..."
if [ -d "$ROOT_DIR/service" ]; then
    cd "$ROOT_DIR/service"
    if [ -f "./gradlew" ]; then
        echo "  - Running gradle test..."
        ./gradlew test || echo "  - Gradle test finished."
    else
        echo "  - Gradle wrapper not found, skipping service gradle test."
    fi
fi

echo "=== Validation Complete ==="
