---
name: llm-wiki-ops
description: |
  LLM Wiki knowledge base operations methodology. Use when: (1) building or maintaining 
  a persistent wiki knowledge base with LLM, (2) deciding what to ingest vs skip, 
  (3) handling version conflicts between source documents, (4) setting up automated 
  knowledge lifecycle, (5) processing audit feedback, (6) detecting knowledge gaps 
  via unlinked concepts. Covers: source document triage (4 levels), three-layer 
  architecture, four-loop automation, structured audit system, unlinked concept 
  detection, daily operation logs, wiki health monitoring.
author: zebinwang-code
version: 2.1.0
date: 2026-04-20
---

# LLM Wiki Knowledge Base Operations

## Problem

LLM + note-taking systems (Obsidian, Notion, etc.) easily degrade into "built but unused" — 
after initial enthusiasm, knowledge stops compiling, the wiki rots, queries bypass the wiki 
for zero-shot reasoning, and the system is eventually abandoned.

## Context / Trigger Conditions

- User has a Markdown-based note system + LLM coding assistant (Claude Code, Cursor, etc.)
- Needs to manage multi-project knowledge with cross-project reuse
- Has many process documents (multi-version specs, meeting notes, discussion drafts) that need denoising
- Needs the LLM to answer questions using compiled knowledge, not zero-shot reasoning

## Solution

### 1. Three-Layer Architecture

```
Raw Sources (immutable)     → raw/, inbox/, notes/
Wiki (LLM-maintained)       → wiki/ (entities/concepts/domains/analyses/comparisons)
Schema (human-machine)      → wiki/_schema.md
```

### 2. Source Document Triage (Required Before Ingest)

| Level | Permission | Rule |
|-------|-----------|------|
| authoritative | Overwrite wiki text | Latest final version |
| superseded | Evolution trail only | Replaced by newer version |
| input | Append, don't overwrite | Meeting notes, data |
| discussion | Evolution trail + pending | Drafts, discussions |

### 3. Ingest Criteria

**Do ingest:** Cross-project reusable methodologies, frameworks, patterns
**Don't ingest:**
- Time-sensitive content (news, version updates) → keep in resources
- Vertical expertise (surfing technique) → keep in project
- Project execution details → keep in project folder
- Raw data → keep in analysis tools

### 4. Four-Loop Lifecycle

```
Loop 1 Auto-Ingest: new sources → check for compilable knowledge → /wiki ingest
Loop 2 Auto-Query:  UserPromptSubmit hook auto-injects wiki context for domain questions
Loop 3 Structured Review: audit/ feedback + weekly lint + monthly health + quarterly domain audit
Loop 4 Daily Close: /wrap-up integrates wiki maintenance (tag check, index, lint, audit scan)
```

### 5. Loop 2 Hard Enforcement (UserPromptSubmit Hook)

**v2.1 addition**: Loop 2 was the weakest loop because it relied on LLM self-discipline
to "read wiki before answering". v2.1 converts this from a soft CLAUDE.md rule into a
hard harness mechanism via a `UserPromptSubmit` hook.

**Mechanism**: `hooks/wiki-context-injector.sh` runs before every user prompt reaches
the LLM. If the prompt matches registered domain keywords, the hook loads the relevant
domain pages + index excerpt and injects them as `additionalContext`. The LLM cannot
bypass the wiki because the wiki is already in its context.

**Architecture**:
```
User Prompt → [UserPromptSubmit hook with regex matcher]
           → wiki-context-injector.sh (loads domain pages)
           → <wiki-context> block injected
           → LLM responds with [[wikilinks]]
           → Injection logged to log/YYYYMMDD.md as `query` op
```

**Token budget**: ~2000 tokens worst case (index 300 + 2 domain pages at 800 each).
Zero cost when prompt doesn't match any domain keyword (regex matcher pre-filters).

**Opt-out**: Prompts containing "skip wiki" / "跳过wiki" / "不查知识库", or starting with `/`,
are silently skipped.

**Observability**: `scripts/wiki-loop2-report.sh` generates weekly reports on hit rate,
domain distribution, and token cost.

See `hooks/README.md` for installation and customization.

### 6. Structured Audit (Loop 3 Core Mechanism)

When humans find wiki errors, they file audit files to `wiki/audit/` instead of editing wiki directly.

**File format**: `YYYYMMDD-HHMMSS-<slug>.md` with YAML frontmatter (id, target, severity, status, anchor)

**Severity**: `error` (factual) > `warn` (stale) > `suggest` (improvement) > `info` (context)

**Text anchors**: `anchor.before/text/after` (~80 chars context each) replaces line numbers, resistant to file edit drift

**Processing flow**: `/wiki lint` scans → anchor locate → fix wiki → record resolution → move to `audit/resolved/`

See `wiki/_schema.md` "Structured Audit" section for full specification.

### 7. Unlinked Concept Detection (Knowledge Gap Finder)

During `/wiki lint`, automatically scan all wiki pages to identify **terms appearing 3+ times without a corresponding wiki page**.

**Detection logic**:
1. Collect all wiki page titles (including aliases) → existing concept set
2. Scan all wiki page body text, extract `[[non-existent links]]` + recurring terms
3. Filter out common words and existing concepts
4. Sort by frequency, output top-10 unlinked concepts

**Rules**:
- Only detect `[[wikilink]]` references + terms appearing in 3+ different pages
- Exclude frontmatter, code blocks, blockquotes
- Results written to daily `log/YYYYMMDD.md`

### 8. Daily Operation Logs

All wiki operations log to `wiki/log/YYYYMMDD.md` (one file per day), not appended to index.md.

- Format: `## [HH:MM] <op> | <description>` + indented bullets
- Operation types: `ingest` · `lint` · `audit` · `query` · `split` · `scaffold` · `archive`
- `index.md` "Recent Activity" keeps only last 3 summaries + pointer to `log/`

### 9. Wiki Health Monitoring

- Health dashboard (e.g., Obsidian Dataview) auto-detects untagged and orphan pages
- `_schema.md` maintains domain tag registry
- `/wiki lint` full checklist:
  1. Tag health (missing wiki / type / domain tags) → auto-fix
  2. Index completeness (page on disk not in index) → auto-fix
  3. Dead wikilinks (pointing to non-existent pages) → report
  4. Orphan pages (zero inbound links) → report
  5. Contradiction review (unresolved `⚠️` markers) → report
  6. Page size detection (exceeds split threshold) → suggest split
  7. **Unlinked concepts** (≥3 mentions, no page) → suggest creation
  8. **Open audit scan** (unprocessed `audit/` feedback) → process by severity
  9. Log completeness (missing today's log file) → auto-create

## Verification

- Wiki index dual-axis navigation (by domain + by type) has no broken links
- Health dashboard shows no red alerts
- Domain questions answered by citing wiki pages, not zero-shot reasoning
- Evolution trails preserve decision change history
- `audit/` has no error-level feedback older than 7 days
- `log/` has a log file for every day with operations
- Unlinked concept count trends downward over time

## Example

API Platform project: 4 source documents (Spec v1.0 → Meeting Notes → v2.0 → Final Review), after triage and ingest:
- Wiki text reflects v2.0 final decisions (unified 5 endpoints + rate limiting)
- Evolution trail preserves full decision chain (dropped batch endpoint → restored with limits)
- Data format contradiction flagged and resolved (JSON vs protobuf)
- Consolidated from 25 to 19 pages (merged duplicates + absorbed thin pages)

## Notes

- Wiki scale limit: ~100K tokens (~200 pages). Beyond this, introduce a search engine
- Don't create an index file per project — the project homepage IS the index; wiki index is globally unique
- Process documents are never deleted — they're the wiki's evidence chain, like git history
- Domain tags auto-activate in Dataview after registration; no manual navigation maintenance needed

## References

- Andrej Karpathy, "LLM Wiki" (2026-04, GitHub Gist)
- lewislulu/llm-wiki-skill — structured audit system, text anchors, lint automation
- Tiago Forte, "Building a Second Brain" (2022) — CODE/PARA methodology
- Niklas Luhmann's Zettelkasten — atomic note + dense linking foundation
