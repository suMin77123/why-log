---
name: why-pr
description: Manual fallback for creating a PR with decision log summaries — use only when the automatic PR inclusion from why-log skill was not triggered (e.g., creating a PR without AI assistance)
---

# Decision-Aware PR Creation (Manual)

**Announce at start:** "I'm using the why-pr skill to create a PR with decision log summaries."

> **Note:** This is a manual fallback. When the why-log skill is active, decision logs are automatically included in PRs. Use `/why-pr` only when creating a PR outside the normal AI-assisted workflow.

## Context

- Current branch: !`git branch --show-current`
- Base branch: !`echo "${ARGUMENTS:-main}"`
- Recent commits: !`git log --oneline -10`
- Decision logs in this branch: !`git diff --name-only $(echo "${ARGUMENTS:-main}")...HEAD -- docs/decisions/ 2>/dev/null || echo "No decision logs found"`

## Instructions

Create a pull request that includes a summary of all decision logs from this branch.

### Step 1: Determine Base Branch

The base branch defaults to `main`. If the user provided an argument, use that instead.

### Step 2: Collect Decision Logs

Find all `docs/decisions/*.md` files — both committed and uncommitted:

```bash
# Committed decision logs on this branch
git diff --name-only ${BASE_BRANCH}...HEAD -- docs/decisions/ 2>/dev/null
# Uncommitted local decision logs
ls docs/decisions/*.md 2>/dev/null
```

Combine both lists and deduplicate by filename. If no decision log files are found, skip to Step 4 and create the PR without a Why Log section.

### Step 3: Build Decision Summary

For each decision log file found:
1. Read the file contents from the local filesystem
2. Extract the title (first `# ` heading)
3. Extract key sections: `## Decision`, `## Alternatives Considered`, `## Reasoning`, `## Trade-offs Accepted`
4. Format as inline content (since files may not be committed to the repo):
   ```markdown
   ### [Decision Title]
   **Decision:** [Content from ## Decision section]
   **Alternatives:** [Summary from ## Alternatives Considered — each alternative name with key pros/cons]
   **Reasoning:** [Content from ## Reasoning section]
   **Trade-offs:** [Content from ## Trade-offs Accepted section]
   ```

Separate multiple decisions with `---`.

### Step 3.5: Generate Mermaid Diagram

Based on the decision logs collected, generate a mermaid diagram and append it to the Why Log section:

- **1 decision with 2+ alternatives** → Alternatives Comparison (`flowchart TD`): show chosen option with ✅ and rejected options with ❌
- **2+ sequential/dependent decisions** → Decision Flow (`flowchart TD`): show decision chain with chosen/rejected paths
- **3+ independent decisions across phases** → Decision Timeline (`timeline`): group by Planning/Implementation phases

Place the diagram at the end of the `## Why Log` section, after all textual summaries.

### Step 4: Push and Create PR

1. Push the current branch to the remote:
   ```bash
   git push -u origin HEAD
   ```

2. Build the PR body using this structure:

   **If decision logs were found:**
   ```markdown
   ## Summary
   [Brief description of the changes in this PR, derived from commit messages]

   ## Why Log

   ### [Decision Title]
   **Decision:** [Decision content]
   **Alternatives:** [Alternatives summary]
   **Reasoning:** [Reasoning content]
   **Trade-offs:** [Trade-offs content]

   ---

   [More decisions if any...]

   [MERMAID DIAGRAM — see Step 3.5]

   ## Test Plan
   - [ ] [Testing checklist items based on the changes]
   ```

   **If no decision logs were found:**
   ```markdown
   ## Summary
   [Brief description of the changes in this PR, derived from commit messages]

   ## Test Plan
   - [ ] [Testing checklist items based on the changes]
   ```

3. Create the PR:
   ```bash
   gh pr create --title "[concise PR title]" --body "[constructed body]"
   ```

### Step 5: Report

Show the PR URL to the user:

```
PR created: [URL]
```

If decision logs were included, also report:
```
Included [N] decision log(s) in the PR description.
```

## Notes

- Always push the current branch before creating the PR
- The base branch defaults to `main` but can be overridden via arguments
- Keep the PR title under 70 characters
- The Why Log section goes between Summary and Test Plan for visibility
- If `gh` CLI is not available or not authenticated, inform the user and provide the PR body text so they can create it manually
