# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.4.1] - 2026-04-16

### Changed
- **PR Why Log bullet formatting** — Decision, Alternatives, Reasoning, Trade-offs fields now use `*` bullet points with sub-bullets for multi-item fields (Alternatives, Trade-offs), improving readability in PR descriptions

## [1.4.0] - 2026-04-14

### Added
- **Subagent commit guard** — text-based guard in bootstrap-context ensures subagents check for unstaged decision logs before committing (PreToolUse hooks don't propagate to subagents)

### Changed
- **All diagrams now vertical** — Alternatives Comparison changed from `flowchart LR` to `flowchart TD` for consistent top-down layout across all diagram types

## [1.3.0] - 2026-04-14

### Added
- **PreToolUse commit guard** — `PreToolUse` hook blocks `git commit` when unstaged decision logs exist in `docs/decisions/`
  - Tells AI to ask user before including decision logs in commits
  - Warns if `docs/decisions/` is in `.gitignore` (which prevents committing)
  - `WHY_LOG_SKIP=1` prefix bypasses the check when user declines
  - Claude Code only (Cursor does not support PreToolUse hooks yet)
- **Gitignore protection** — explicit instructions in SKILL.md and bootstrap-context.md to never add `docs/decisions/` to `.gitignore`

### Changed
- Commit Behavior section rewritten to reference the PreToolUse hook instead of relying on prompt-only instructions
- Smoke tests expanded with pre-commit-check functional tests

## [1.2.0] - 2026-04-13

### Added
- **Decision Checkpoint** — self-check after every response to catch missed decisions
- **Decision Debt Warning** — retroactive logging for decisions missed earlier in session
- **SELF-MONITORING** in HARD-GATE — mandatory self-check after comparing alternatives
- **Mermaid diagrams in PR body** — auto-generated flowcharts/timelines for decision visualization
  - Alternatives Comparison (flowchart TD), Decision Flow (flowchart TD), Decision Timeline
- Full inline decision content in PR body — PRs are self-contained even without committed files

### Changed
- Decision logs no longer auto-staged on commit — AI asks user before including in commits
- PR body embeds full decision content instead of compact links (supports uncommitted files)
- Smoke test rewritten with behavioral contract validation (73 tests, up from 48)

### Removed
- `hooks/pre-commit-stage-decisions` — replaced by user-confirmed commit behavior

## [1.1.0] - 2026-03-31

### Fixed
- SessionStart hook now injects full bootstrap context instead of a one-line reminder
  - AI can now automatically detect and log decisions without manual `/why-log` invocation
  - Deferred logging format included inline for plan mode / brainstorming phases
  - Strong mandatory language (`<HARD-GATE>`) ensures compliance

### Added
- `hooks/bootstrap-context.md` — externalized bootstrap context file (follows superpowers plugin pattern)
  - Trigger signal table, 3-criteria noise filter, deferred logging format, flush instructions

## [1.0.0] - 2026-03-30

### Added
- Automatic decision logging — detects architecture choices, library selections, bug root causes, and trade-off resolutions without manual triggers
- Decision log format with Context, Decision, Alternatives Considered, Reasoning, Trade-offs, and Consequences sections
- Auto-staging of `docs/decisions/*.md` on commit
- Auto-inclusion of **Why Log** section in PR body when creating PRs
- Multi-platform support: Claude Code, Cursor, Codex, Gemini CLI
- SessionStart hook with decision log count reminder
- `/why-log` manual command for decisions the AI didn't catch
- `/why-pr` command for creating PRs with decision summaries outside AI flow
- Noise prevention: 3-criteria gate (2+ alternatives, future reader value, non-obvious)
- HARD-GATE for high-priority decisions (architecture, library, bug root cause) — must log before implementation
- Session limit: max 5 decision logs per session with consolidation
- `/why-log off` toggle to pause logging for a session
- Self-review checklist for decision log quality
- Split vs Merge guidelines for related decisions
- Cross-platform hook wrapper (`run-hook.cmd`) for Windows/Unix compatibility
- Optional git pre-commit hook for non-AI commits
- Documentation in English and Korean
- Smoke test suite with 9 test sections

[1.4.1]: https://github.com/suMin77123/why-log/releases/tag/v1.4.1
[1.4.0]: https://github.com/suMin77123/why-log/releases/tag/v1.4.0
[1.3.0]: https://github.com/suMin77123/why-log/releases/tag/v1.3.0
[1.2.0]: https://github.com/suMin77123/why-log/releases/tag/v1.2.0
[1.1.0]: https://github.com/suMin77123/why-log/releases/tag/v1.1.0
[1.0.0]: https://github.com/suMin77123/why-log/releases/tag/v1.0.0
