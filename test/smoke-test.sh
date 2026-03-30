#!/usr/bin/env bash
# Smoke test for why-log plugin
# Run from the plugin root directory: bash test/smoke-test.sh

set -euo pipefail

PASS=0
FAIL=0
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }

echo "=== why-log plugin smoke test ==="
echo ""

# 1. File structure
echo "[1/7] Checking file structure..."
for f in \
  .claude-plugin/plugin.json \
  .cursor-plugin/plugin.json \
  .codex/INSTALL.md \
  skills/why-log/SKILL.md \
  skills/why-pr/SKILL.md \
  hooks/hooks.json \
  hooks/hooks-cursor.json \
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

# 2. Verify old files are removed
echo ""
echo "[2/7] Checking old files are removed..."
for f in \
  commands/decision-log.md \
  commands/decision-pr.md \
  skills/decision-logging/SKILL.md; do
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    fail "$f should have been removed"
  else
    pass "$f correctly removed"
  fi
done

# 3. plugin.json validity (all platforms)
echo ""
echo "[3/7] Validating plugin.json files..."
if command -v python3 &>/dev/null; then
  for f in .claude-plugin/plugin.json .cursor-plugin/plugin.json; do
    if python3 -c "import json; json.load(open('$PLUGIN_ROOT/$f'))" 2>/dev/null; then
      pass "$f is valid JSON"
    else
      fail "$f is invalid JSON"
    fi
  done
  # hooks JSON
  for f in hooks/hooks.json hooks/hooks-cursor.json; do
    if python3 -c "import json; json.load(open('$PLUGIN_ROOT/$f'))" 2>/dev/null; then
      pass "$f is valid JSON"
    else
      fail "$f is invalid JSON"
    fi
  done
else
  echo "  - skipped (python3 not found)"
fi

# 4. Hook executability
echo ""
echo "[4/7] Checking hook executability..."
for f in hooks/session-start hooks/run-hook.cmd hooks/pre-commit-stage-decisions; do
  if [ -x "$PLUGIN_ROOT/$f" ]; then
    pass "$f is executable"
  else
    fail "$f is not executable"
  fi
done

# 5. SessionStart hook output
echo ""
echo "[5/7] Testing SessionStart hook output..."
cd "$PLUGIN_ROOT"
HOOK_OUTPUT=$(CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" bash hooks/session-start 2>&1) || true
if echo "$HOOK_OUTPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); assert 'hookSpecificOutput' in d" 2>/dev/null; then
  pass "Claude Code hook returns valid JSON with hookSpecificOutput"
else
  fail "Claude Code hook output invalid: $HOOK_OUTPUT"
fi

HOOK_OUTPUT_CURSOR=$(CURSOR_PLUGIN_ROOT="$PLUGIN_ROOT" bash hooks/session-start 2>&1) || true
if echo "$HOOK_OUTPUT_CURSOR" | python3 -c "import json,sys; d=json.load(sys.stdin); assert 'additional_context' in d" 2>/dev/null; then
  pass "Cursor hook returns valid JSON with additional_context"
else
  fail "Cursor hook output invalid: $HOOK_OUTPUT_CURSOR"
fi

# 6. SKILL.md frontmatter (why-log)
echo ""
echo "[6/7] Checking why-log SKILL.md..."
SKILL_FILE="$PLUGIN_ROOT/skills/why-log/SKILL.md"
if head -1 "$SKILL_FILE" | grep -q '^\-\-\-'; then
  pass "SKILL.md has frontmatter"
else
  fail "SKILL.md missing frontmatter"
fi
if grep -q '^name: why-log' "$SKILL_FILE"; then
  pass "SKILL.md name is why-log"
else
  fail "SKILL.md name is not why-log"
fi
if grep -q 'Do NOT ask for confirmation' "$SKILL_FILE"; then
  pass "SKILL.md has no-confirmation rule"
else
  fail "SKILL.md missing no-confirmation rule"
fi
if grep -q 'Auto PR Inclusion' "$SKILL_FILE"; then
  pass "SKILL.md has auto PR inclusion"
else
  fail "SKILL.md missing auto PR inclusion"
fi
if grep -q 'Auto-Staging on Commit' "$SKILL_FILE"; then
  pass "SKILL.md has auto-staging on commit"
else
  fail "SKILL.md missing auto-staging on commit"
fi

# 7. SKILL.md frontmatter (why-pr)
echo ""
echo "[7/7] Checking why-pr SKILL.md..."
SKILL_PR="$PLUGIN_ROOT/skills/why-pr/SKILL.md"
if head -1 "$SKILL_PR" | grep -q '^\-\-\-'; then
  pass "why-pr SKILL.md has frontmatter"
else
  fail "why-pr SKILL.md missing frontmatter"
fi
if grep -q '^name: why-pr' "$SKILL_PR"; then
  pass "why-pr SKILL.md name is why-pr"
else
  fail "why-pr SKILL.md name is not why-pr"
fi

# Summary
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
