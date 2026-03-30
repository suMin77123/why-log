# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

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

[1.0.0]: https://github.com/suMin77123/why-log/releases/tag/v1.0.0
