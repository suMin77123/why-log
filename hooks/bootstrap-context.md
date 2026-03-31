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

## Commit & PR Integration

- **Commits:** Always `git add docs/decisions/*.md` before committing code changes.
- **PRs:** When creating a PR with `gh pr create`, automatically append a `## Why Log` section listing decisions from the branch. Use the why-log skill for the full format, or `/why-pr` as manual fallback.

## Session Limit

Maximum 5 decision logs per session. After the 5th, add sub-sections to existing logs.
