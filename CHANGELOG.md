# Changelog

## [2.1.0] — 2026-04-20

### Added — Loop 2 Hard Enforcement

- **`hooks/wiki-context-injector.sh`** — UserPromptSubmit hook that automatically injects relevant wiki context when the user's prompt matches registered domain keywords. Turns Loop 2 (Auto-Query) from a soft `CLAUDE.md` rule into a harness-enforced mechanism.
- **`hooks/settings.json.example`** — Claude Code settings.json snippet for hook registration, with regex pre-matcher for zero-overhead filtering.
- **`hooks/README.md`** — Installation guide, architecture explanation, tuning guidance, and observability notes.
- **`scripts/wiki-loop2-report.sh`** — Weekly effectiveness report generator. Parses `log/*.md`, aggregates query injections by domain and day, outputs markdown report, pushes macOS/Linux notification.
- **`scripts/launchagents/com.llm-wiki.loop2-weekly-report.plist.example`** — macOS LaunchAgent template for scheduled weekly reports.
- **CHANGELOG.md** — This file.

### Changed

- **SKILL.md** — Bumped to v2.1.0. Added section 5 "Loop 2 Hard Enforcement (UserPromptSubmit Hook)" documenting the mechanism, token budget, opt-out signals, and observability. Renumbered subsequent sections.
- **README.md** — Added Loop 2 hook as Key Innovation #1 with architecture diagram. Added "Option D" installation path. Updated comparison table with new "Query enforcement" row showing hard-enforcement advantage over RAG and soft-rule systems.

### Why

Loop 2 was the weakest loop in the four-loop system. The rule "read `wiki/index.md` first, then answer" lived in CLAUDE.md and relied on LLM self-discipline. Under context pressure or for seemingly simple questions, LLMs bypassed the wiki and answered from zero-shot reasoning, breaking the "compile once, query many" value proposition.

v2.1 fixes this with a `UserPromptSubmit` hook that intercepts prompts **before the LLM sees them**, matches against registered domain keywords, and injects relevant wiki content as `additionalContext`. The LLM can't skip the wiki because the wiki is already in its context.

### Measured Impact (from Phase 1 MVP)

- **Zero overhead** for non-domain prompts (regex matcher in settings.json pre-filters)
- **471–1200 tokens** injected per single-domain prompt
- **1472–2020 tokens** injected per cross-domain prompt
- **~$0.20/day** additional context cost at ~50 prompts/day (Opus 4.x pricing)

## [2.0.0] — 2026-04-20

Initial public release.

### Core Features

- Four-loop lifecycle (ingest → query → review → close)
- Source document triage (4 levels with write permissions)
- Structured audit system with text anchors
- Unlinked concept detection (knowledge gap finder)
- 9-point lint checklist
- Daily operation logs
- Page size discipline with auto-split detection
- Five page types (entity/concept/domain/analysis/comparison)
- Domain organization with color-coded tags
- Version conflict resolution matrix
- Evolution trails for decision tracking
