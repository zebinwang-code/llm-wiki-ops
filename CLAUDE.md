# LLM Wiki Behavior Rules

Add these rules to your project's CLAUDE.md to enforce the four-loop lifecycle.

## Wiki Structure

* **`wiki/`**: LLM-maintained compounding knowledge base
  * Sub-dirs: `entities/`, `concepts/`, `domains/`, `analyses/`, `comparisons/`
  * `audit/` — structured human feedback (open), `audit/resolved/` — processed
  * `log/` — daily operation logs (`YYYYMMDD.md`)
  * `index.md` — master index, LLM reads first when querying wiki
  * `_schema.md` — page conventions, audit template, size limits, log format
  * LLM owns this layer: creates, updates, cross-references, flags contradictions
  * All commands that create wiki notes MUST update `wiki/index.md`
  * All wiki operations MUST log to `wiki/log/YYYYMMDD.md`

## Wiki Knowledge Cycle (Four-Loop Lifecycle)

### Loop 1: Auto-Ingest (Capture → Compile)
**Trigger:** When content-producing commands generate output
- After daily digests/research, scan for cross-project reusable methodologies or insights
- **99% of content is NOT ingested** (time-sensitive news) — only new frameworks/patterns/methods
- New documents in inbox → suggest `/wiki ingest` or batch during daily close

### Loop 2: Auto-Query (Query → Express)
**Trigger:** Every time user asks a project or domain question
- **Rule: Read wiki first, then answer.** When user asks about a wiki domain, READ `wiki/index.md` to locate relevant pages, answer from compiled knowledge — not zero-shot reasoning
- If answer produces new insights, evaluate whether to store as a wiki page
- Reference wiki pages using `[[PageName]]` format

### Loop 3: Structured Review (Distill → Decide)
**Trigger:** User-initiated or periodic
- **Anytime:** Human finds wiki error → file audit to `wiki/audit/` (not direct edit), format in `_schema.md`
- **Weekly:** `/wiki lint` — 9 checks (tags/index/dead links/orphans/contradictions/size/**unlinked concepts**/**open audit**/logs). Tag issues auto-fix; content issues escalate to user
- **Monthly:** Review health dashboard for untagged and orphan pages
- **Quarterly:** Audit wiki domain coverage — any emerging work areas not yet registered?

### Loop 4: Daily Close (Lint → Optimize)
**Trigger:** End-of-day wrap-up command
- Wiki maintenance: check new page tags, update index, quick lint, **scan open audit**
- Archive outputs to wiki / notes / project as appropriate
- Evolution trails auto-updated
- Operations recorded to `wiki/log/YYYYMMDD.md`

```
          ┌─── Loop 1: Auto-Ingest ────────────┐
          │ new sources → compile into wiki     │
          ▼                                     │
     ┌─────────┐                           ┌────┴────┐
     │  Wiki   │ ◄── Loop 4: Daily Close ── │ wrap-up │
     │(compiled)│                           └─────────┘
     └────┬────┘                                ▲
          │                                     │
          ▼                                     │
     Loop 2: Auto-Query                    Loop 3: Structured Review
     Read wiki before answering            audit/ + weekly lint
     Store new insights back               health dashboard + domain audit
          │                                     │
          └─────────────────────────────────────┘
```

## Rules

- **Read wiki first, then answer** (Loop 2 rule)
- Use wikilinks `[[NoteName]]` liberally
- No empty line after frontmatter `---`
- All wiki operations must be logged to daily log files
