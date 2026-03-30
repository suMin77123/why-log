# Decision Log

A Claude Code plugin that records AI decision-making alongside code changes. Captures reasoning, alternatives considered, and trade-offs in per-change markdown documents.

[한국어 README](README.ko.md)

## Why

AI-assisted code changes lose their reasoning context. PR reviewers see **what** changed but not **why**. Developers lose context between sessions. This plugin solves that by automatically recording decision logs in `docs/decisions/` — versioned alongside your code.

## Installation

### From GitHub

```
/install github:suMin77123/decision-log
```

### From Claude Code Official Marketplace

```
/plugin install decision-log@claude-plugins-official
```

## How It Works

### Semi-Automatic (Skill)

The plugin includes a **model-invoked skill** that Claude activates automatically when it detects a significant decision point during conversation:

- Architecture choices (JWT vs sessions)
- Library/dependency selection (Prisma vs TypeORM)
- Plan approval or modification
- Bug root cause analysis
- Performance/security judgments
- Implementation branch points
- Trade-off resolutions
- Refactoring decisions

When triggered, Claude will ask for confirmation before writing:

```
I noticed a decision worth logging:
**Authentication strategy: JWT tokens over session-based auth**

Should I record this in docs/decisions/? (yes/no)
```

### Manual (`/decision-log`)

Manually create a decision log entry at any time:

```
/decision-log auth strategy
```

### PR Creation (`/decision-pr`)

Create a PR with decision summaries automatically included in the description:

```
/decision-pr main
```

This collects all decision logs from the current branch and adds a **Decision Log** section to the PR body, so reviewers can immediately see the reasoning behind changes.

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

## Hook Setup (Optional)

### Session Start Reminder

Installed automatically with the plugin. Shows a reminder at session start with the count of existing decision logs.

### Auto-Stage Decision Logs with Commits

Install the git pre-commit hook to automatically include decision logs in your commits:

```bash
# Option 1: Copy
cp hooks/pre-commit-stage-decisions .git/hooks/pre-commit

# Option 2: Symlink
ln -s ../../hooks/pre-commit-stage-decisions .git/hooks/pre-commit

# Make executable
chmod +x .git/hooks/pre-commit
```

This ensures `docs/decisions/*.md` files are staged whenever you commit, so decision logs always ship with the code they document.

## Workflow Examples

### Solo Developer

```
1. Start coding session
   -> SessionStart hook shows: "Decision logging active, 3 logs in project"

2. Brainstorm authentication approaches with Claude
   -> Claude presents JWT vs sessions vs OAuth

3. Choose JWT
   -> Skill triggers: "Decision worth logging: Auth strategy JWT. Record? (yes/no)"
   -> "yes"
   -> docs/decisions/2026-03-30-auth-strategy-jwt.md created

4. Continue implementation...

5. Later, reviewing your own code:
   -> "Why did I choose JWT?" -> check docs/decisions/
```

### Team PR Review

```
1. Developer + Claude session produces code + 2 decision logs

2. PR includes:
   - src/auth/jwt-handler.ts (new)
   - src/middleware/auth.ts (modified)
   - docs/decisions/2026-03-30-auth-strategy-jwt.md (new)
   - docs/decisions/2026-03-30-token-storage-httponly-cookies.md (new)

3. /decision-pr creates PR with:
   ## Decision Log
   - **Auth Strategy: JWT**: Chose JWT for stateless cross-service auth
   - **Token Storage: httpOnly Cookies**: Chose cookies over localStorage for XSS prevention

4. Reviewer reads decision summaries FIRST
   -> Understands WHY before reviewing HOW
   -> Fewer "why did you do it this way?" comments
```

## Noise Prevention

The skill only logs decisions that meet ALL criteria:
1. **2+ viable alternatives** were genuinely considered
2. **Future reader value** — someone would benefit from understanding the reasoning
3. **Non-obvious** — the reasoning cannot be inferred from the code alone

And always asks for user confirmation before writing.

## Compatibility

- Works alongside the [superpowers](https://github.com/obra/superpowers) plugin
- Integrates with brainstorming, plan mode, and TDD workflows
- No conflicts with other documentation plugins

## License

MIT
