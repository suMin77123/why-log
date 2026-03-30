---
description: Create a PR with decision log summaries included in the PR description
argument-hint: [base-branch]
allowed-tools: [Read, Glob, Grep, Bash]
---

# Decision-Aware PR Creation

## Context

- Current branch: !`git branch --show-current`
- Base branch: !`echo "${ARGUMENTS:-main}"`
- Recent commits: !`git log --oneline -10`
- Decision logs in this branch: !`git diff --name-only $(echo "${ARGUMENTS:-main}")...HEAD -- docs/decisions/ 2>/dev/null || echo "No decision logs found"`

## Instructions

Create a pull request that includes a summary of all decision logs from this branch.

### Step 1: Collect Decision Logs

Find all `docs/decisions/*.md` files added or modified in this branch compared to the base branch:

```bash
git diff --name-only ${ARGUMENTS:-main}...HEAD -- docs/decisions/
```

### Step 2: Build Decision Summary

For each decision log file found:
1. Read the file
2. Extract the title (first `# ` heading) and the `## Decision` section
3. Format as a bullet point: `- **[Title]**: [Decision summary]`

### Step 3: Create PR

Use `gh pr create` with the following body structure:

```markdown
## Summary
[Brief description of the changes in this PR]

## Decision Log
[For each decision found:]
- **[Decision Title]**: [1-line decision summary]
  - See: `docs/decisions/YYYY-MM-DD-<topic>.md`

## Test Plan
[Testing checklist]
```

### Step 4: Report

Show the PR URL to the user.

### Notes

- If no decision logs are found, create the PR normally without the Decision Log section
- The base branch defaults to `main` but can be overridden via arguments
- Always push the current branch before creating the PR
