---
name: why-log
description: Use when making architectural choices, selecting between implementation alternatives, approving or modifying plans, choosing libraries or patterns, resolving trade-offs, diagnosing bug root causes, making performance or security judgments, or deciding to refactor existing code - records reasoning for future context and PR review transparency
---

# Decision Logging

Record significant decisions alongside code changes so future readers understand **WHY**, not just **WHAT**.

**Announce at start:** "I'm using the why-log skill to record this decision."

## Key Principles

1. **Why > What** — Code shows what; logs show why
2. **Signal > Noise** — What you DON'T log matters more than what you do
3. **PR Body > Code Commit** — Decisions always appear in PR body; committing files to repo is user's choice
4. **Compact PR, Detailed Log** — PR gets a one-line summary; full reasoning lives in the log file
5. **Auto > Manual** — Default behavior requires zero user intervention
6. **Reversible** — Every decision can be Superseded or Deprecated later

<HARD-GATE>
When a HIGH priority decision is detected (architecture, library selection, approach selection,
plan modification, bug root cause, performance/security judgment), the decision MUST be recorded
BEFORE proceeding. In normal mode, write the decision log file immediately. In restricted mode
(e.g., plan mode where only the plan file is editable), use Deferred Logging.
Do not continue without recording the decision.

SELF-MONITORING: After generating any response where you compared alternatives or recommended
an approach, STOP and ask yourself: "Did I just make a loggable decision?" If yes, invoke
this skill before proceeding. This check is mandatory, not aspirational.
</HARD-GATE>

## Process Flow

```dot
digraph why_log {
  rankdir=TB;
  node [shape=box];

  "Planning" [label="Planning/brainstorming\nin progress"];
  "Coding" [label="Coding in progress"];
  "Detect_P" [label="Decision point\ndetected?" shape=diamond];
  "Detect_C" [label="Decision point\ndetected?" shape=diamond];
  "Filter" [label="Noise filter\n(3 criteria check)" shape=diamond];
  "Deferred" [label="Deferred write\n(plan file or buffer)"];
  "Write" [label="Write decision log"];
  "Review" [label="Self-review checklist"];
  "Fix" [label="Inline fix"];
  "Done" [label="Log complete"];
  "Flush" [label="Flush deferred logs\nto decision files"];
  "PlanExit" [label="Planning phase ends"];

  "Planning" -> "Detect_P";
  "Detect_P" -> "Filter" [label="yes"];
  "Detect_P" -> "Planning" [label="no"];
  "Filter" -> "Deferred" [label="pass\n(restricted mode)"];
  "Filter" -> "Write" [label="pass\n(normal mode)"];
  "Filter" -> "Planning" [label="filtered out"];
  "Filter" -> "Coding" [label="filtered out"];
  "Deferred" -> "Planning";
  "Planning" -> "PlanExit";
  "PlanExit" -> "Flush";
  "Flush" -> "Review";

  "Coding" -> "Detect_C";
  "Detect_C" -> "Filter" [label="yes"];
  "Detect_C" -> "Coding" [label="no"];
  "Write" -> "Review";
  "Review" -> "Fix" [label="issue found"];
  "Review" -> "Done" [label="pass"];
  "Fix" -> "Done";
  "Done" -> "Coding";
}
```

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
| Approach selection during brainstorming | "Let's go with approach A over B" | HIGH |
| Plan approval or modification | Design confirmed after brainstorming | HIGH |
| Plan modification | "Change the plan from X to Y because..." | HIGH |
| Bug root cause analysis | "Root cause is X, fixing with approach Y" | HIGH |
| Performance/security judgment | "Add index vs caching vs query optimization" | HIGH |
| Implementation deviation from plan | "Plan said X but implementing Y instead" | MEDIUM |
| Implementation branch point | "Using Strategy pattern here" | MEDIUM |
| Trade-off resolution | "Prioritize readability over performance" | MEDIUM |
| Refactoring decision | "Splitting this module because..." | MEDIUM |

## The Process

### Step 1: Identify the Decision

When you recognize a decision point from the trigger signals above, pause and assess significance using the three criteria (2+ alternatives, future reader value, non-obvious reasoning).

### Step 2: Create the Decision Log

**Do NOT ask for confirmation.** When a decision meets the criteria, log it immediately.

Create `docs/decisions/` directory if it does not exist.

**Important:** NEVER add `docs/decisions/` to `.gitignore`. Decision logs must remain trackable by git so they can be optionally committed. If `docs/decisions` is in `.gitignore`, remove it before proceeding.

Create a file at `docs/decisions/YYYY-MM-DD-<topic-slug>.md` using the template below.

**File naming rules:**
- Date: today's date in `YYYY-MM-DD` format
- Topic slug: lowercase, hyphenated, 3-6 words describing the decision
- If a file with the same name exists, append `-2`, `-3`, etc.
- Examples: `2026-03-30-auth-strategy-jwt-vs-session.md`, `2026-03-30-database-orm-selection.md`

### Step 3: Self-Review

After writing the log, run this checklist **inline** (no separate review pass):

1. **Title:** Does it describe a single decision? (If 2+ decisions, split into separate logs)
2. **Alternatives:** Are the listed alternatives genuinely viable? (Remove straw-man options)
3. **Reasoning:** Does it specifically reference trade-offs? (Not vague "it seemed better")
4. **Code Paths:** Do the paths in Related Code Paths actually exist?
5. **Consequences:** Are they realistic and actionable?

Fix any issues inline and move on. Do not re-review after fixing.

### Step 4: Report

After writing, briefly notify the user:

```
Decision logged: docs/decisions/YYYY-MM-DD-<topic>.md
```

Do not ask for review or approval. The user can read the log later if they want.

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

## Decision Journey

> Include this section when the decision evolved through planning/brainstorming phases.
> Omit for simple implementation-time decisions.

### Initial Request
[What the user wanted and why this work started]

### Plan Evolution
- [Plan change 1]: [Why it changed]
- [Plan change 2]: [Why it changed]

### Implementation Changes
- [Change from plan during implementation]: [Why]

### Outcome
[Final result and how it differs from the original request, if at all]
```

**Status values:**
- `Accepted` — current active decision
- `Superseded by [filename]` — replaced by a newer decision
- `Deprecated` — no longer applicable

## Anti-Pattern: Do NOT Log These

- Variable/function naming choices (naming is not a decision)
- Code formatting or style preferences
- Patterns forced by the framework (no real choice existed)
- "Decisions" with only one viable alternative (that's inevitability, not choice)
- Anything already documented in CLAUDE.md, .cursorrules, or project conventions

## Split vs Merge Decisions

**Split into separate logs when:**
- They affect different areas of the codebase
- They can be independently reversed
- Different stakeholders care about different decisions

**Merge into one log when:**
- They're cascading decisions from the same context
- Changing one necessarily changes the other
- They affect the same code paths

## Session Limit

**Maximum 5 decision logs per session.** After the 5th, consolidate further decisions into the most relevant existing log as "Additional Decisions" sub-sections instead of creating new files.

## Consolidating Related Decisions

If multiple related decisions arise in one session, or when the session limit is reached, merge them into ONE log file:

1. Use the most significant decision as the title
2. Add sub-sections for related decisions:

```markdown
## Additional Decisions

### [Sub-decision Title]
**Decision:** [Brief statement]
**Reasoning:** [1-2 sentences]
```

## Disabling Logging

If the user says "stop logging", "no more logs", `/why-log off`, or similar, **immediately stop** creating decision logs for the rest of the session. Do not ask for confirmation — just stop and acknowledge:

```
Decision logging paused for this session.
```

To re-enable, the user can say "resume logging" or `/why-log on`.

## Commit Behavior

Decision log files (`docs/decisions/*.md`) are **working artifacts** that are NOT automatically committed.

A `PreToolUse` hook automatically blocks `git commit` when unstaged decision logs exist in `docs/decisions/`. The hook also warns if `docs/decisions/` is in `.gitignore` (which prevents committing entirely).

When the hook blocks your commit:
1. **Ask the user:** "This commit has N associated decision log(s). Include them in the commit? (y/n)"
2. If the user says **yes** → `git add docs/decisions/*.md` then commit normally
3. If the user says **no** → prefix with bypass: `WHY_LOG_SKIP=1 git commit -m "..."`

Decision logs are always available locally in `docs/decisions/` for PR body inclusion regardless of commit status.

## Auto PR Inclusion

When creating a pull request with `gh pr create`, **automatically** include decision logs in the PR body. Decision logs are included **regardless of whether they are committed** to the repo.

1. **Find decision logs for this branch (both committed and local):**
   ```bash
   # Committed decision logs
   git diff --name-only $(git merge-base HEAD main)..HEAD -- docs/decisions/ 2>/dev/null
   # Uncommitted local decision logs
   ls docs/decisions/*.md 2>/dev/null
   ```
   Combine both lists and deduplicate by filename.

2. **Read each decision log file** from the local filesystem and build the `## Why Log` section with **full inline content** (since files may not be committed to the repo):

   ```markdown
   ## Why Log

   ### [Decision Title]
   * **Decision:** [Content from ## Decision section]
   * **Alternatives:**
     * [Alternative A] — [key pros/cons]
     * [Alternative B] — [key pros/cons]
   * **Reasoning:** [Content from ## Reasoning section]
   * **Trade-offs:**
     * [Trade-off 1]
     * [Trade-off 2]

   ---

   ### [Next Decision Title]
   ...

   [MERMAID DIAGRAM — see "Mermaid Diagrams in PR Body" section below]
   ```

3. **If no decision logs exist**, do not add the section — just create the PR normally.

**Important:** Since decision log files may not be committed to the repo, the PR body must be **self-contained**. Include the decision, alternatives, reasoning, and trade-offs inline. Reviewers get full context directly in the PR without needing to check out the branch.

This happens every time a PR is created, with no extra user action required.

## Auto PR Update

When pushing additional commits to a branch that **already has an open PR**, automatically update the Why Log section in the PR body. This ensures the Why Log stays current as decisions evolve.

### When to trigger

Update the PR body when **any** of these are true:
- New decision logs were created since the PR was opened
- Existing decision logs were modified
- The user explicitly asks to update the PR

### How to update

1. **Check for an existing PR on the current branch:**
   ```bash
   gh pr view --json number,body --jq '{number, body}' 2>/dev/null
   ```
   If no PR exists, skip — the Why Log will be included when the PR is created.

2. **Collect decision logs** using the same method as Auto PR Inclusion (committed + local, deduplicated).

3. **Rebuild the `## Why Log` section** with the latest content, using the same bullet format and mermaid diagram rules.

4. **Replace the section in the existing PR body:**
   - If the body contains `## Why Log`, replace everything from `## Why Log` up to (but not including) the next `## ` heading or end of body
   - If the body does not contain `## Why Log`, insert it before `## Test Plan` (or at the end if no Test Plan section exists)

5. **Update the PR:**
   ```bash
   gh pr edit <number> --body "<updated body>"
   ```

### Important

- Preserve all other sections of the PR body (Summary, Test Plan, etc.) — only replace the Why Log section
- This is automatic: do not ask the user before updating the PR body with decision logs

## Mermaid Diagrams in PR Body

When building the `## Why Log` section for a PR, **always append a mermaid diagram** at the end, after all textual decision summaries. Choose the most appropriate diagram type based on the decisions:

### Alternatives Comparison (1 decision with 2+ alternatives)

Use when a single key decision had multiple options:

````markdown
```mermaid
flowchart TD
    D{Decision Title}
    D -->|"✅ Chosen"| A["Option A<br/>key advantage"]
    D -.->|"❌"| B["Option B<br/>key disadvantage"]
    D -.->|"❌"| C["Option C<br/>key disadvantage"]
```
````

### Decision Flow (2+ sequential/dependent decisions)

Use when decisions were made in sequence, each building on the previous:

````markdown
```mermaid
flowchart TD
    P["Initial Problem"] --> D1{Decision 1}
    D1 -->|"Chosen: Option A"| R1["Result/Reason"]
    D1 -.->|"Rejected: Option B"| X1["Why rejected"]
    R1 --> D2{Decision 2}
    D2 -->|"Chosen: Option X"| R2["Result/Reason"]
    D2 -.->|"Rejected: Option Y"| X2["Why rejected"]
```
````

### Decision Timeline (3+ independent decisions across phases)

Use when multiple independent decisions were made throughout the work:

````markdown
```mermaid
timeline
    title Decision Timeline
    section Planning
        Decision 1 : Chose X over Y — reason
    section Implementation
        Decision 2 : Chose A over B — reason
        Decision 3 : Chose P over Q — reason
```
````

**Diagram selection rules:**
- 1 decision with 2+ alternatives → **Alternatives Comparison**
- 2+ sequential/dependent decisions → **Decision Flow**
- 3+ independent decisions across phases → **Decision Timeline**
- When in doubt → **Decision Flow**

**Always place the diagram at the end of the `## Why Log` section**, after all textual decision summaries.

## Deferred Logging

Some environments restrict file creation during planning phases (e.g., plan mode only allows editing the plan file). When a decision is detected but you cannot create `docs/decisions/*.md` files:

### Step 1: Record in available location

Write a `## Pending Decision Logs` section at the bottom of whichever file you CAN edit (plan file, scratch buffer, or conversation notes):

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

### Step 2: Flush after restrictions lift

As soon as file creation becomes available (e.g., after exiting plan mode, before writing any implementation code):

1. Read all `## Pending Decision Logs` entries
2. Convert each entry into a full `docs/decisions/YYYY-MM-DD-<topic>.md` file using the standard template
3. Include the Decision Journey section with Initial Request and Plan Evolution filled in
4. Remove the `## Pending Decision Logs` section from the source file
5. Notify the user: `Decision logged: docs/decisions/YYYY-MM-DD-<topic>.md (deferred from planning phase)`

### Step 3: Continue updating through implementation

As implementation progresses, update existing decision logs with:
- **Implementation Changes** entries in Decision Journey (if deviating from plan)
- **Outcome** section in Decision Journey (when the work is complete)

## Integration with Other Workflows

**With brainstorming:** Decisions happen throughout brainstorming, not just at the end. Log when:
- The user selects an approach from proposed alternatives (e.g., "Let's go with approach A")
- The user modifies or rejects a proposed design section
- The final design is approved with specific trade-offs
- If file creation is restricted during brainstorming, use Deferred Logging.

**With plan mode:** Decisions embedded in plan creation and modification are prime candidates for logging. Since plan mode typically restricts file creation, use Deferred Logging to capture decisions in the plan file and flush them when plan mode ends.

**With TDD:** Implementation decisions during TDD (e.g., choosing test strategy) are loggable if they represent meaningful alternatives.

**With commits:** Decision logs are NOT auto-staged. Ask the user before including them in a commit. They are always included in the PR body regardless.

**With PRs:** Decision logs are automatically summarized in the PR body whenever `gh pr create` is used. No separate command is needed. The `/why-pr` command exists only as a manual fallback for creating PRs outside the AI-assisted workflow.

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
| Asking for confirmation before logging | Never ask — detect and log immediately, then notify |
| Auto-staging decision logs without asking | Ask the user before including decision files in commits |
| Forgetting decision logs in PRs | Always check for and include decision logs when creating PRs |
| Stale logs left as "Accepted" | Update status when superseded |
