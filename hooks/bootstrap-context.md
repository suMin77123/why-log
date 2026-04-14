Decision logging is active. Currently {{DECISION_COUNT}} decision log(s) in this project.
Use /why-log for manual logging, /why-pr for PR creation with decision summaries. Say '/why-log off' to pause logging.

<HARD-GATE>
When you make a significant decision, you MUST record it BEFORE proceeding with implementation.
This is not optional. Do not rationalize skipping this. If you considered 2+ alternatives and picked one, log it.
</HARD-GATE>

## When to Log

**ALL three must be true:**
1. Two or more viable alternatives were genuinely considered
2. A future reader would benefit from understanding the reasoning
3. The reasoning is non-obvious from the code itself

**Trigger signals:**

| Signal | Priority |
|--------|----------|
| Architecture choice | HIGH |
| Library/dependency selection | HIGH |
| Approach selection during brainstorming | HIGH |
| Plan approval or modification | HIGH |
| Bug root cause analysis | HIGH |
| Performance/security judgment | HIGH |
| Implementation deviation from plan | MEDIUM |
| Trade-off resolution | MEDIUM |
| Refactoring decision | MEDIUM |

**Do NOT log:** naming choices, formatting, framework-forced patterns, single-alternative decisions, anything already in CLAUDE.md.

## Decision Checkpoint

**After every substantive response, run this mental check:**
1. Did I just compare 2+ alternatives?
2. Did I just recommend or choose an approach?
3. Did the user just approve, reject, or modify a plan?

If ANY answer is yes and the 3 logging criteria are met, invoke the why-log skill IMMEDIATELY before your next action. Do not batch — log each decision as it happens.

**Watch for these patterns in your own output:**
- "I recommend...", "Let's go with...", "I'll use..."
- "Option A vs Option B", "The trade-off is..."
- "Instead of X, I'll do Y because..."
- "The root cause is..."
- User responds: "yes", "go ahead", "let's do that", "sounds good" (after you presented alternatives)

## How to Log

### Normal Mode (file creation allowed)

Use the why-log skill: invoke it with the Skill tool. It contains the full template and self-review checklist.

### Restricted Mode (plan mode, brainstorming where only plan file is editable)

When you CANNOT create `docs/decisions/*.md` files, write a `## Pending Decision Logs` section at the bottom of whichever file you CAN edit (plan file, scratch buffer):

```markdown
## Pending Decision Logs

### [Decision Title]
- **Initial Request:** [What the user asked for and background]
- **Alternatives:** A vs B vs C
- **Decision:** A
- **Reasoning:** [Brief rationale]
- **Plan Changes:** [Any plan modifications related to this decision]
- **Scope:** [Affected area of codebase]
```

**You MUST flush deferred logs** as soon as file creation becomes available (after exiting plan mode, before writing implementation code):
1. Read all `## Pending Decision Logs` entries
2. Invoke the why-log skill to convert each entry into a full `docs/decisions/YYYY-MM-DD-<topic>.md` file
3. Remove the `## Pending Decision Logs` section from the source file

## Gitignore Rule

**NEVER add `docs/decisions/` to `.gitignore`.** Decision logs must remain trackable by git so they can be optionally committed. If you find `docs/decisions` in `.gitignore`, remove it.

## Commit & PR Integration

- **Commits:** A `PreToolUse` hook blocks `git commit` when unstaged decision logs exist in `docs/decisions/`. It also warns if `docs/decisions/` is in `.gitignore`. When blocked, ask the user: "Include decision logs in this commit? (y/n)". If yes: `git add docs/decisions/*.md` then commit. If no: prefix with `WHY_LOG_SKIP=1` (e.g., `WHY_LOG_SKIP=1 git commit -m "..."`).
- **Subagent Commit Guard:** PreToolUse hooks do not propagate to subagents. If you are a subagent about to run `git commit`:
  1. Check: `ls docs/decisions/*.md 2>/dev/null`
  2. If files exist, check unstaged: `git ls-files --others --exclude-standard -- 'docs/decisions/*.md'` and `git diff --name-only -- docs/decisions/`
  3. If unstaged logs found, you MUST ask the user: "Include these decision logs in the commit? (y/n)"
     - If yes: `git add docs/decisions/*.md` then commit
     - If no: prefix with `WHY_LOG_SKIP=1`
  4. Do NOT skip this check. This replaces the PreToolUse hook that cannot run in subagents.
- **PRs:** When creating a PR with `gh pr create`, automatically append a `## Why Log` section with full decision content and mermaid diagrams. Check both committed and local uncommitted decision files. Use the why-log skill for the full format, or `/why-pr` as manual fallback.

## Session Limit

Maximum 5 decision logs per session. After the 5th, add sub-sections to existing logs.

## Decision Debt Warning

If you realize you made a decision 2+ messages ago without logging it, log it NOW retroactively.
Late logging is always better than no logging. Note in the Context section: "This decision was made during [earlier phase] and logged retroactively."
