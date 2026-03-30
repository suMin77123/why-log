# Why Log

Record AI decision-making alongside code changes. Captures reasoning, alternatives, and trade-offs in per-change markdown documents — fully automatic, no manual triggers needed.

[한국어 README](README.ko.md)

## Why

AI-assisted code changes lose their reasoning context. PR reviewers see **what** changed but not **why**. Developers lose context between sessions. This plugin solves that by automatically recording decision logs in `docs/decisions/` — versioned alongside your code.

## Installation

### Claude Code

```bash
# From npm (recommended)
claude plugin add why-log

# From GitHub
claude plugin add github:suMin77123/why-log

# Pin to a specific version
claude plugin add github:suMin77123/why-log#v1.0.0
```

### Other Platforms

| Platform | Installation |
|----------|-------------|
| **Cursor** | Install via Cursor Marketplace or clone to `.cursor-plugin/` |
| **Codex** | See [Codex installation guide](.codex/INSTALL.md) |
| **Gemini CLI** | `gemini extensions install github:suMin77123/why-log` |

## How It Works

### Automatic (Zero User Intervention)

The plugin operates fully automatically through 4 stages:

**1. Session Start** — Hook injects a reminder with the count of existing decision logs.

**2. Decision Detection** — When the AI detects a significant decision point, it logs immediately without asking:

```
Decision logged: docs/decisions/2026-03-30-auth-strategy-jwt.md
```

Trigger signals:
- Architecture choices (JWT vs sessions)
- Library/dependency selection (Prisma vs TypeORM)
- Bug root cause analysis
- Performance/security judgments
- Plan approval or modification
- Implementation branch points
- Trade-off resolutions
- Refactoring decisions

**3. Commit** — The AI automatically stages `docs/decisions/*.md` alongside code changes. Decision logs ship in the same commit as the code they document.

**4. PR Creation** — When the AI creates a PR, it automatically collects decision logs from the branch and includes a **Why Log** section in the PR body:

```markdown
## Why Log

- **Auth Strategy: JWT**: Use JWT tokens — stateless cross-service auth, no shared session store
  → [`docs/decisions/2026-03-30-auth-strategy-jwt.md`](docs/decisions/2026-03-30-auth-strategy-jwt.md)

> Full reasoning and alternatives in each linked decision log.
```

### Manual (Backup)

| Command | Purpose |
|---------|---------|
| `/why-log [topic]` | Log a decision the AI didn't catch |
| `/why-pr [base-branch]` | Create a PR with decision summaries when not using the AI flow |

## Decision Log Format

Each decision is stored as `docs/decisions/YYYY-MM-DD-<topic>.md`:

```markdown
# Authentication Strategy: JWT vs Sessions

**Date:** 2026-03-30
**Status:** Accepted
**Scope:** src/auth/, src/middleware/

## Context
The app needs user authentication for API endpoints.
We're building a microservices architecture where multiple
services need to verify user identity independently.

## Decision
Use JWT tokens with httpOnly cookie storage.

## Alternatives Considered

### Session-based Auth
- **Pros:** Simple, built-in revocation
- **Cons:** Requires shared session store across services

### OAuth2 Only
- **Pros:** Delegated auth, industry standard
- **Cons:** Overkill for internal service-to-service auth

## Reasoning
JWT allows stateless verification across microservices without
a shared session store. The trade-off of complex token revocation
is acceptable given our low-risk profile.

## Trade-offs Accepted
- Token revocation requires additional infrastructure (acceptable for MVP)
- Larger request payload than session cookies (negligible impact)

## Related Code Paths
- `src/auth/jwt-handler.ts` - Token creation and verification
- `src/middleware/auth.ts` - Request authentication middleware

## Consequences
- Must implement token refresh mechanism before v2
- All new services can verify auth independently
```

## Noise Prevention

The skill only logs decisions that meet ALL criteria:
1. **2+ viable alternatives** were genuinely considered
2. **Future reader value** — someone would benefit from understanding the reasoning
3. **Non-obvious** — the reasoning cannot be inferred from the code alone

## Workflow Example

```
1. Start coding session
   -> Hook: "Decision logging active, 3 existing logs"

2. Brainstorm auth approaches with AI
   -> AI presents JWT vs sessions vs OAuth

3. Choose JWT
   -> AI automatically logs the decision
   -> "Decision logged: docs/decisions/2026-03-30-auth-strategy-jwt.md"

4. Continue implementation...

5. Commit code
   -> AI runs: git add docs/decisions/*.md + code files
   -> Decision log included in same commit

6. Create PR
   -> AI auto-includes Why Log section in PR body
   -> Reviewer sees WHY before reviewing HOW
```

## Hook Setup

### Session Start Reminder
Installed automatically with the plugin. Shows a reminder at session start with the count of existing decision logs.

### Git Pre-commit Hook (Optional)
An optional backup for non-AI commits:

```bash
cp hooks/pre-commit-stage-decisions .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## How It Differs from Brainstorming

If you use [superpowers](https://github.com/obra/superpowers) brainstorming, you might wonder: why add another plugin?

They solve different problems at different times:

| | Brainstorming | Why Log |
|---|---|---|
| **When** | Before coding — designing what to build | During coding — recording why you built it this way |
| **Output** | Design spec (`docs/superpowers/specs/`) | Decision logs (`docs/decisions/`) |
| **Trigger** | You explicitly start it | Fully automatic — detects and logs on its own |
| **Audience** | You and your team, planning | PR reviewers and your future self |

**In practice, they work together:**

1. Brainstorm "How should we build auth?" → design spec
2. Start implementing → choose JWT over sessions → **why-log records it automatically**
3. Choose bcrypt over argon2 for hashing → **why-log records it automatically**
4. Create PR → decision summaries appear in the PR body

Brainstorming decides *what to build*. Why Log captures the dozens of *why-did-you-do-it-this-way* decisions that happen during implementation — the ones no one writes down but everyone asks about in code review.

## Compatibility

- Works alongside the [superpowers](https://github.com/obra/superpowers) plugin
- Integrates with brainstorming, plan mode, and TDD workflows
- Cross-platform: Claude Code, Cursor, Codex, Gemini CLI

## License

MIT
