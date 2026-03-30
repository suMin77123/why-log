---
name: decision-logging
description: Use when making architectural choices, selecting between implementation alternatives, approving or modifying plans, choosing libraries or patterns, resolving trade-offs, diagnosing bug root causes, making performance or security judgments, or deciding to refactor existing code - records reasoning for future context and PR review transparency
---

# Decision Logging

Record significant decisions alongside code changes so future readers understand **WHY**, not just **WHAT**.

**Announce at start:** "I'm using the decision-logging skill to record this decision."

## Core Principle

If a future PR reviewer or your future self would ask "why did you do it this way?", log the decision.

## When to Log

**Log when ALL of these are true:**
1. Two or more viable alternatives were genuinely considered
2. The choice has consequences a future reader would want to understand
3. The reasoning is not obvious from the code itself

**Do NOT log:**
- Trivial choices (naming, formatting, obvious patterns)
- Decisions already captured in an existing log for this change
- Choices dictated by constraints with no real alternatives
- Mechanical implementation details

## Trigger Signals

| Signal | Example | Priority |
|--------|---------|----------|
| Architecture choice | "JWT vs sessions — let's go with JWT" | HIGH |
| Library/dependency selection | "Prisma vs TypeORM" | HIGH |
| Plan approval or modification | Design confirmed after brainstorming | HIGH |
| Bug root cause analysis | "Root cause is X, fixing with approach Y" | HIGH |
| Performance/security judgment | "Add index vs caching vs query optimization" | HIGH |
| Implementation branch point | "Using Strategy pattern here" | MEDIUM |
| Trade-off resolution | "Prioritize readability over performance" | MEDIUM |
| Refactoring decision | "Splitting this module because..." | MEDIUM |

## The Process

### Step 1: Identify the Decision

When you recognize a decision point from the trigger signals above, pause and assess significance using the three criteria (2+ alternatives, future reader value, non-obvious reasoning).

### Step 2: Confirm with User

Present a brief summary and ask for confirmation:

```
I noticed a decision worth logging:
**[One-line decision summary]**

Should I record this in docs/decisions/? (yes/no)
```

If the user says no, do not log. Move on.

### Step 3: Create the Decision Log

Create `docs/decisions/` directory if it does not exist.

Create a file at `docs/decisions/YYYY-MM-DD-<topic-slug>.md` using the template below.

**File naming rules:**
- Date: today's date in `YYYY-MM-DD` format
- Topic slug: lowercase, hyphenated, 3-6 words describing the decision
- If a file with the same name exists, append `-2`, `-3`, etc.
- Examples: `2026-03-30-auth-strategy-jwt-vs-session.md`, `2026-03-30-database-orm-selection.md`

### Step 4: Report

After writing, report:

```
Decision logged: docs/decisions/YYYY-MM-DD-<topic>.md
```

## Decision Log Template

Use this exact template for every decision log:

```markdown
# [Decision Title]

**Date:** YYYY-MM-DD
**Status:** Accepted
**Scope:** [Which part of the codebase this affects]

## Context

[2-4 sentences. What situation required a decision? What constraints existed?]

## Decision

[1-2 sentences stating the choice clearly.]

## Alternatives Considered

### [Alternative A Name]
- **Description:** [What this option would look like]
- **Pros:** [Bullet list]
- **Cons:** [Bullet list]

### [Alternative B Name]
- **Description:** [What this option would look like]
- **Pros:** [Bullet list]
- **Cons:** [Bullet list]

## Reasoning

[2-4 sentences explaining WHY the chosen option was selected over alternatives. Reference specific trade-offs.]

## Trade-offs Accepted

- [Trade-off 1: what we gave up and why it's acceptable]
- [Trade-off 2: ...]

## Related Code Paths

- `path/to/affected/file.ts` - [Brief description of how this file is affected]
- `path/to/other/file.ts` - [Brief description]

## Consequences

- [What this decision means for future development]
- [Any follow-up work this creates]
- [Constraints this imposes on future decisions]
```

**Status values:**
- `Accepted` — current active decision
- `Superseded by [filename]` — replaced by a newer decision
- `Deprecated` — no longer applicable

## Consolidating Related Decisions

If multiple related decisions arise in one session, create ONE log file for the cluster:

1. Use the most significant decision as the title
2. Add sub-sections for related decisions:

```markdown
## Additional Decisions

### [Sub-decision Title]
**Decision:** [Brief statement]
**Reasoning:** [1-2 sentences]
```

## Integration with Other Workflows

**With brainstorming:** Log decisions when the design is approved, not during exploration.

**With plan mode:** Decisions embedded in plan approval are prime candidates for logging.

**With TDD:** Implementation decisions during TDD (e.g., choosing test strategy) are loggable if they represent meaningful alternatives.

**With commits:** Decision logs should be committed alongside the code they document. Stage `docs/decisions/` files with your code changes.

## Updating Existing Decisions

When a new decision supersedes an old one:
1. Update the old log's status to `Superseded by [new-filename]`
2. Reference the old log in the new log's Context section

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Over-logging every small choice | Apply the 2-alternatives + impact test |
| Vague reasoning ("it seemed better") | State specific trade-offs and constraints |
| Missing code paths | Always include Related Code Paths with actual file paths |
| Logging without user confirmation | Always ask first — semi-automatic means confirm before writing |
| Stale logs left as "Accepted" | Update status when superseded |
