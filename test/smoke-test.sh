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

# ─────────────────────────────────────────────────────────
# 1. Required files exist
# ─────────────────────────────────────────────────────────
echo "[1/8] Required files..."
for f in \
  .claude-plugin/plugin.json \
  .cursor-plugin/plugin.json \
  .codex/INSTALL.md \
  .gemini-extension/gemini-extension.json \
  skills/why-log/SKILL.md \
  skills/why-pr/SKILL.md \
  hooks/hooks.json \
  hooks/hooks-cursor.json \
  hooks/session-start \
  hooks/run-hook.cmd \
  hooks/bootstrap-context.md \
  package.json \
  README.md \
  README.ko.md; do
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    pass "$f"
  else
    fail "$f missing"
  fi
done

# Files that must NOT exist (removed in previous versions)
for f in \
  commands/decision-log.md \
  commands/decision-pr.md \
  skills/decision-logging/SKILL.md \
  hooks/pre-commit-stage-decisions; do
  if [ -f "$PLUGIN_ROOT/$f" ]; then
    fail "$f should not exist"
  else
    pass "$f removed"
  fi
done

# ─────────────────────────────────────────────────────────
# 2. JSON files are valid and have required fields
# ─────────────────────────────────────────────────────────
echo ""
echo "[2/8] JSON validity and required fields..."
if ! command -v python3 &>/dev/null; then
  echo "  - SKIPPED (python3 not found)"
else
  # Claude Code plugin.json — must have name field
  python3 -c "
import json, sys
d = json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json'))
assert 'name' in d, 'missing name'
" 2>/dev/null && pass ".claude-plugin/plugin.json has name" || fail ".claude-plugin/plugin.json missing name"

  # Cursor plugin.json — must reference skills and hooks
  python3 -c "
import json, sys
d = json.load(open('$PLUGIN_ROOT/.cursor-plugin/plugin.json'))
assert 'skills' in d, 'missing skills'
assert 'hooks' in d, 'missing hooks'
" 2>/dev/null && pass ".cursor-plugin/plugin.json has skills+hooks" || fail ".cursor-plugin/plugin.json missing skills or hooks"

  # Gemini extension — must reference both skills
  python3 -c "
import json, sys
d = json.load(open('$PLUGIN_ROOT/.gemini-extension/gemini-extension.json'))
assert d['name'] == 'why-log', 'wrong name'
assert 'why-log' in d['skills'], 'missing why-log skill'
assert 'why-pr' in d['skills'], 'missing why-pr skill'
" 2>/dev/null && pass "gemini-extension.json has name+skills" || fail "gemini-extension.json invalid"

  # hooks.json — must define SessionStart event (nested dict format: hooks.SessionStart)
  python3 -c "
import json
d = json.load(open('$PLUGIN_ROOT/hooks/hooks.json'))
h = d.get('hooks', d)
assert 'SessionStart' in h, 'no SessionStart hook'
assert len(h['SessionStart']) > 0, 'SessionStart is empty'
" 2>/dev/null && pass "hooks.json has SessionStart event" || fail "hooks.json missing SessionStart"

  # hooks-cursor.json — must define sessionStart (nested dict format: hooks.sessionStart)
  python3 -c "
import json
d = json.load(open('$PLUGIN_ROOT/hooks/hooks-cursor.json'))
h = d.get('hooks', d)
assert 'sessionStart' in h, 'no sessionStart hook'
assert len(h['sessionStart']) > 0, 'sessionStart is empty'
" 2>/dev/null && pass "hooks-cursor.json has sessionStart" || fail "hooks-cursor.json missing sessionStart"
fi

# ─────────────────────────────────────────────────────────
# 3. Hook scripts are executable and produce correct output
# ─────────────────────────────────────────────────────────
echo ""
echo "[3/8] Hook execution..."
for f in hooks/session-start hooks/run-hook.cmd; do
  [ -x "$PLUGIN_ROOT/$f" ] && pass "$f executable" || fail "$f not executable"
done

cd "$PLUGIN_ROOT"

# Claude Code mode: must return JSON with hookSpecificOutput.additionalContext containing bootstrap content
HOOK_CC=$(CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" bash hooks/session-start 2>&1) || true
if echo "$HOOK_CC" | python3 -c "
import json, sys
d = json.load(sys.stdin)
ctx = d['hookSpecificOutput']['additionalContext']
assert 'HARD-GATE' in ctx, 'missing HARD-GATE in context'
assert 'Decision Checkpoint' in ctx, 'missing Decision Checkpoint in context'
assert 'Decision Debt Warning' in ctx, 'missing Decision Debt Warning in context'
assert 'Do NOT auto-stage' in ctx, 'missing commit behavior in context'
assert '{{DECISION_COUNT}}' not in ctx, 'placeholder not replaced'
" 2>/dev/null; then
  pass "Claude Code hook: valid JSON with required context"
else
  fail "Claude Code hook: missing required context sections"
fi

# Cursor mode: must return JSON with additional_context
HOOK_CURSOR=$(CURSOR_PLUGIN_ROOT="$PLUGIN_ROOT" bash hooks/session-start 2>&1) || true
if echo "$HOOK_CURSOR" | python3 -c "
import json, sys
d = json.load(sys.stdin)
ctx = d['additional_context']
assert 'HARD-GATE' in ctx, 'missing HARD-GATE'
assert 'Decision Checkpoint' in ctx, 'missing checkpoint'
" 2>/dev/null; then
  pass "Cursor hook: valid JSON with required context"
else
  fail "Cursor hook: missing required context sections"
fi

# ─────────────────────────────────────────────────────────
# 4. SKILL.md frontmatter (both skills)
# ─────────────────────────────────────────────────────────
echo ""
echo "[4/8] Skill frontmatter..."
if command -v python3 &>/dev/null; then
  # why-log: check YAML frontmatter has name and description
  python3 -c "
import re
content = open('$PLUGIN_ROOT/skills/why-log/SKILL.md').read()
m = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
assert m, 'no frontmatter'
fm = m.group(1)
assert 'name: why-log' in fm, 'wrong name'
assert 'description:' in fm, 'no description'
assert len([l for l in fm.split('\n') if l.startswith('description:')][0]) > 30, 'description too short'
" 2>/dev/null && pass "why-log frontmatter valid" || fail "why-log frontmatter invalid"

  python3 -c "
import re
content = open('$PLUGIN_ROOT/skills/why-pr/SKILL.md').read()
m = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
assert m, 'no frontmatter'
fm = m.group(1)
assert 'name: why-pr' in fm, 'wrong name'
assert 'description:' in fm, 'no description'
" 2>/dev/null && pass "why-pr frontmatter valid" || fail "why-pr frontmatter invalid"
else
  echo "  - SKIPPED (python3 not found)"
fi

# ─────────────────────────────────────────────────────────
# 5. why-log SKILL.md: required sections exist as ## headings
# ─────────────────────────────────────────────────────────
echo ""
echo "[5/8] why-log SKILL.md structure..."
SKILL="$PLUGIN_ROOT/skills/why-log/SKILL.md"

# Required ## sections (must appear as markdown headings, not just keywords)
for section in \
  "Key Principles" \
  "Process Flow" \
  "When to Log" \
  "Trigger Signals" \
  "The Process" \
  "Decision Log Template" \
  "Anti-Pattern" \
  "Split vs Merge" \
  "Session Limit" \
  "Commit Behavior" \
  "Auto PR Inclusion" \
  "Mermaid Diagrams in PR Body" \
  "Deferred Logging" \
  "Common Mistakes"; do
  if grep -qE "^##+ .*${section}" "$SKILL"; then
    pass "Section: $section"
  else
    fail "Missing section heading: $section"
  fi
done

# ─────────────────────────────────────────────────────────
# 6. Behavioral contracts (critical rules that must be present)
# ─────────────────────────────────────────────────────────
echo ""
echo "[6/8] Behavioral contracts..."

# HARD-GATE must contain SELF-MONITORING
if python3 -c "
import re
content = open('$SKILL').read()
gate = re.search(r'<HARD-GATE>(.*?)</HARD-GATE>', content, re.DOTALL)
assert gate, 'no HARD-GATE block'
body = gate.group(1)
assert 'SELF-MONITORING' in body, 'no SELF-MONITORING in HARD-GATE'
assert 'MUST be recorded' in body or 'MUST record' in body, 'no mandatory language'
" 2>/dev/null; then
  pass "HARD-GATE contains SELF-MONITORING + mandatory language"
else
  fail "HARD-GATE missing SELF-MONITORING or mandatory language"
fi

# Commit behavior must say NOT auto-stage
if grep -q 'Do NOT.*auto.*stage\|NOT automatically committed\|Do NOT.*automatically run' "$SKILL"; then
  pass "Commit section prohibits auto-staging"
else
  fail "Commit section does not prohibit auto-staging"
fi

# Commit behavior must ask user
if grep -q 'Ask the user' "$SKILL"; then
  pass "Commit section requires user confirmation"
else
  fail "Commit section missing user confirmation requirement"
fi

# Auto PR Inclusion must handle uncommitted files
if grep -q 'uncommitted\|local.*decision' "$SKILL" && grep -q 'regardless.*commit' "$SKILL"; then
  pass "PR inclusion handles uncommitted files"
else
  fail "PR inclusion does not handle uncommitted files"
fi

# Decision log template must have all required sections
for tmpl_section in "Context" "Decision" "Alternatives Considered" "Reasoning" "Trade-offs Accepted" "Related Code Paths" "Consequences"; do
  if grep -q "## $tmpl_section" "$SKILL"; then
    pass "Template has: $tmpl_section"
  else
    fail "Template missing: $tmpl_section"
  fi
done

# Mermaid section must have all 3 diagram types
for diagram in "flowchart LR" "flowchart TD" "timeline"; do
  if grep -q "$diagram" "$SKILL"; then
    pass "Mermaid diagram type: $diagram"
  else
    fail "Mermaid missing diagram type: $diagram"
  fi
done

# ─────────────────────────────────────────────────────────
# 7. bootstrap-context.md: required sections and consistency
# ─────────────────────────────────────────────────────────
echo ""
echo "[7/8] bootstrap-context.md content..."
BC="$PLUGIN_ROOT/hooks/bootstrap-context.md"

# Must have HARD-GATE block
if grep -q '<HARD-GATE>' "$BC" && grep -q '</HARD-GATE>' "$BC"; then
  pass "Has HARD-GATE block"
else
  fail "Missing HARD-GATE block"
fi

# Must have Decision Checkpoint section
if grep -qE '^## Decision Checkpoint' "$BC"; then
  pass "Has Decision Checkpoint section"
else
  fail "Missing Decision Checkpoint section"
fi

# Must have Decision Debt Warning section
if grep -qE '^## Decision Debt Warning' "$BC"; then
  pass "Has Decision Debt Warning section"
else
  fail "Missing Decision Debt Warning section"
fi

# Must have {{DECISION_COUNT}} placeholder (for hook substitution)
if grep -q '{{DECISION_COUNT}}' "$BC"; then
  pass "Has {{DECISION_COUNT}} placeholder"
else
  fail "Missing {{DECISION_COUNT}} placeholder"
fi

# Commit instructions must be consistent with SKILL.md (no auto-stage)
if grep -q 'Do NOT auto-stage' "$BC"; then
  pass "Commit instructions consistent (no auto-stage)"
else
  fail "Commit instructions inconsistent — should say Do NOT auto-stage"
fi

# Must reference both /why-log and /why-pr commands
if grep -q '/why-log' "$BC" && grep -q '/why-pr' "$BC"; then
  pass "References both slash commands"
else
  fail "Missing /why-log or /why-pr reference"
fi

# Deferred logging must mention Pending Decision Logs
if grep -q 'Pending Decision Logs' "$BC"; then
  pass "Has deferred logging format"
else
  fail "Missing deferred logging format"
fi

# ─────────────────────────────────────────────────────────
# 8. why-pr SKILL.md: required steps and consistency
# ─────────────────────────────────────────────────────────
echo ""
echo "[8/8] why-pr SKILL.md structure..."
SKILL_PR="$PLUGIN_ROOT/skills/why-pr/SKILL.md"

# Must have all required steps
for step in "Step 1" "Step 2" "Step 3" "Step 3.5" "Step 4" "Step 5"; do
  if grep -q "### $step" "$SKILL_PR"; then
    pass "Has $step"
  else
    fail "Missing $step"
  fi
done

# Must handle uncommitted files
if grep -q 'uncommitted\|local.*decision\|ls docs/decisions' "$SKILL_PR"; then
  pass "Handles uncommitted decision files"
else
  fail "Does not handle uncommitted decision files"
fi

# Must have mermaid diagram step
if grep -qi 'mermaid' "$SKILL_PR"; then
  pass "Has mermaid diagram generation"
else
  fail "Missing mermaid diagram generation"
fi

# PR body must include inline content (not just links)
if grep -q 'Decision:.*\[' "$SKILL_PR" || grep -q '\*\*Decision:\*\*' "$SKILL_PR"; then
  pass "PR body has inline decision content"
else
  fail "PR body missing inline decision content"
fi

# ─────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
