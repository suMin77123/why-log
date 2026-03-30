#!/usr/bin/env bash
# Smoke test for decision-log plugin
# Run from the plugin root directory: bash test/smoke-test.sh

set -euo pipefail

PASS=0
FAIL=0
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }

echo "=== decision-log plugin smoke test ==="
echo ""

# 1. File structure
echo "[1/5] Checking file structure..."
for f in \
  .claude-plugin/plugin.json \
  skills/decision-logging/SKILL.md \
  commands/decision-log.md \
  commands/decision-pr.md \
  hooks/hooks.json \
  hooks/session-start \
  hooks/run-hook.cmd \
  hooks/pre-commit-stage-decisions \
  package.json \
  LICENSE \
  README.md \
  README.ko.md; do
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    pass "$f exists"
  else
    fail "$f missing"
  fi
done

# 2. plugin.json validity
echo ""
echo "[2/5] Validating plugin.json..."
if command -v python3 &>/dev/null; then
  if python3 -c "import json; json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json'))" 2>/dev/null; then
    pass "plugin.json is valid JSON"
  else
    fail "plugin.json is invalid JSON"
  fi
else
  echo "  - skipped (python3 not found)"
fi

# 3. Hook executability
echo ""
echo "[3/5] Checking hook executability..."
for f in hooks/session-start hooks/run-hook.cmd hooks/pre-commit-stage-decisions; do
  if [ -x "$PLUGIN_ROOT/$f" ]; then
    pass "$f is executable"
  else
    fail "$f is not executable"
  fi
done

# 4. SessionStart hook output
echo ""
echo "[4/5] Testing SessionStart hook output..."
cd "$PLUGIN_ROOT"
HOOK_OUTPUT=$(CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" bash hooks/session-start 2>&1) || true
if echo "$HOOK_OUTPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); assert 'hookSpecificOutput' in d" 2>/dev/null; then
  pass "SessionStart hook returns valid JSON with hookSpecificOutput"
else
  fail "SessionStart hook output invalid: $HOOK_OUTPUT"
fi

# 5. SKILL.md frontmatter
echo ""
echo "[5/5] Checking SKILL.md frontmatter..."
if head -1 "$PLUGIN_ROOT/skills/decision-logging/SKILL.md" | grep -q '^\-\-\-'; then
  pass "SKILL.md has frontmatter"
else
  fail "SKILL.md missing frontmatter"
fi
if grep -q '^name:' "$PLUGIN_ROOT/skills/decision-logging/SKILL.md"; then
  pass "SKILL.md has name field"
else
  fail "SKILL.md missing name field"
fi
if grep -q '^description:' "$PLUGIN_ROOT/skills/decision-logging/SKILL.md"; then
  pass "SKILL.md has description field"
else
  fail "SKILL.md missing description field"
fi

# Summary
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
