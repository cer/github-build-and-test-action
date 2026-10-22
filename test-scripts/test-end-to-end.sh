#!/bin/bash -e
# Runs the build-and-test action's test workflow locally with act.

cd "$(dirname "$0")/.."

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# act's git library cannot resolve gradle/actions@v4, because that tag points
# to another tag rather than a commit. git can, so clone it and have act use the clone.
git clone --quiet --depth 1 --branch v4 https://github.com/gradle/actions "$WORK_DIR/gradle-actions"

act workflow_dispatch \
  -W .github/workflows/test-build-and-test.yaml \
  -P ubuntu-24.04=catthehacker/ubuntu:act-24.04 \
  --use-new-action-cache \
  --local-repository "gradle/actions@v4=$WORK_DIR/gradle-actions" \
  --artifact-server-path "$WORK_DIR/artifacts" \
  "$@"

echo "=== All tests passed ==="
