---
description: Manually create a decision log entry for a recent or current decision
argument-hint: [decision topic]
allowed-tools: [Read, Write, Glob, Grep, Bash]
---

# Manual Decision Log

## Context

- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5`
- Existing decision logs: !`ls docs/decisions/ 2>/dev/null || echo "No decision logs yet"`

## Instructions

Create a decision log entry using the decision-logging skill.

1. If the user provided a topic via `$ARGUMENTS`, use it. Otherwise ask what decision to document.
2. Create `docs/decisions/` directory if it does not exist.
3. Follow the decision-logging skill process:
   - Identify the decision and alternatives considered
   - Use the template from the skill
   - Write to `docs/decisions/YYYY-MM-DD-<topic-slug>.md`
4. Stage the new file: `git add docs/decisions/<filename>.md`
5. Report the file path to the user.
