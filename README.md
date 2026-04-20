# LLM Wiki Ops

A methodology for building **persistent, self-maintaining knowledge bases** with LLMs. Instead of RAG (retrieve-and-derive on every query), the LLM **compiles** raw sources into a structured Markdown wiki, keeps it current through four automated loops, and queries its own compiled knowledge to answer questions.

> Inspired by [Andrej Karpathy's LLM Wiki](https://gist.github.com/karpathy/1dd0294ef9567971c1e4348a90d69285) concept, extended with source triage, structured audit, knowledge gap detection, and lifecycle automation.

## Why This Exists

LLM + Obsidian knowledge systems decay fast. The typical failure mode:

1. Initial enthusiasm: import everything, create 50 pages
2. Month 2: stop ingesting, start answering from zero-shot reasoning
3. Month 3: wiki is stale, contradicts reality, gets abandoned

**LLM Wiki Ops** prevents this by making the wiki a **living system** with four closed loops that keep knowledge flowing.

## Core Architecture

### Three Layers

```
Layer 1: Raw Sources (immutable)    → inbox/, resources/, notes/
Layer 2: Wiki (LLM-maintained)      → wiki/ (entities/concepts/domains/analyses/comparisons)
Layer 3: Schema (human-machine)     → wiki/_schema.md
```

- **Layer 1**: Humans add raw material. LLM reads but never modifies.
- **Layer 2**: LLM owns entirely — creates, updates, cross-references, flags contradictions.
- **Layer 3**: Conventions co-evolved by human and LLM. Defines page types, tagging, conflict resolution.

### Four-Loop Lifecycle

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
     Read wiki before answering            audit/ feedback + weekly lint
     Store new insights back               health dashboard + domain audit
          │                                     │
          └─────────────────────────────────────┘
```

| Loop | Trigger | Action |
|------|---------|--------|
| **1. Auto-Ingest** | New source arrives | Triage → compile into 5-15 wiki pages |
| **2. Auto-Query** | User asks a domain question | Read `wiki/index.md` first, answer from compiled knowledge |
| **3. Structured Review** | Anytime / weekly / monthly / quarterly | Process audit feedback, run 9-point lint, health dashboard |
| **4. Daily Close** | End of day | Tag check, index update, quick lint, audit scan, write daily log |

## Key Innovations

### 1. Source Document Triage

Before ingesting any source, classify it into one of four levels. Each level has different write permissions to the wiki:

| Level | Wiki Permission | When to Use |
|-------|----------------|-------------|
| `authoritative` | **Overwrite** wiki content | Latest final version, current decisions |
| `superseded` | **Evolution trail only** | Replaced by newer version |
| `input` | **Append, no override** | Meeting notes, raw data, surveys |
| `discussion` | **Evolution trail + pending** | Drafts, brainstorms, intermediate discussions |

This prevents meeting notes from overwriting final decisions, while preserving the full decision history.

### 2. Structured Audit System

Humans file feedback as structured Markdown files in `wiki/audit/` instead of editing wiki pages directly. Each audit uses **text anchors** (not line numbers) so feedback survives file edits:

```yaml
anchor:
  before: "80 chars of context before the target text"
  text: "the exact text that needs correction"
  after: "80 chars of context after the target text"
```

Four severity levels: `error` (factual) > `warn` (stale) > `suggest` (improvement) > `info` (context).

The LLM processes audits during lint: locate via anchor → fix wiki → record resolution → archive to `audit/resolved/`.

### 3. Unlinked Concept Detection

The wiki **discovers its own knowledge gaps**. During lint, it scans all pages for terms that appear 3+ times across different pages but have no dedicated wiki page. This is the wiki's growth engine — it tells you what to write next.

```
🔍 Unlinked high-frequency concepts (≥3 mentions, no wiki page):
  - "user lifecycle" (7×, in: churn-analysis, onboarding-model, retention-framework...)
  - "prompt engineering" (4×, in: harness, context-engineering...)
→ Suggest: create dedicated concept pages, or confirm as general terms
```

### 4. Version Conflict Resolution

A decision matrix for when new sources contradict existing wiki content:

| New Source | Existing Content | Action |
|-----------|-----------------|--------|
| authoritative | authoritative | **Overwrite** + evolution trail |
| authoritative | input/discussion | **Overwrite** |
| input | authoritative | **Don't overwrite**, append with source attribution |
| discussion | any | **Don't modify**, evolution trail only |

### 5. Page Size Discipline

| Page Type | Target | Split Threshold |
|-----------|--------|----------------|
| Entity | 200–500 words | > 800 words |
| Concept | 400–1200 words | > 1500 words |
| Domain | 300–800 words | Never (MOC) |
| Analysis | 400–1200 words | > 1500 words |

Oversized pages are auto-detected during lint and suggested for splitting.

### 6. Daily Operation Logs

All wiki operations log to `wiki/log/YYYYMMDD.md` (one file per day), keeping `index.md` clean:

```markdown
## [14:30] ingest | Compiled 3 new concept pages from API docs
- Created [[rate-limiting]], [[pagination-patterns]], [[error-handling]]
- Updated [[API-design]] domain page

## [16:00] audit | Processed 2 error-level audits
- Fixed incorrect date in [[product-launch]] (20250301 → 20250315)
- Rejected suggestion on [[pricing-model]] — current version is authoritative
```

## Directory Structure

```
your-wiki/
├── wiki/
│   ├── index.md              # Master index (LLM reads first)
│   ├── _schema.md            # Page conventions and rules
│   ├── entities/             # People, companies, products, tools
│   ├── concepts/             # Frameworks, methods, theories, patterns
│   ├── domains/              # Topic overviews (Maps of Content)
│   ├── analyses/             # Query results, insights, findings
│   ├── comparisons/          # Side-by-side analysis
│   ├── audit/                # Open human feedback
│   │   └── resolved/         # Processed feedback (with decisions)
│   └── log/                  # Daily operation logs (YYYYMMDD.md)
├── raw/                      # Immutable source documents
│   ├── articles/
│   ├── notes/
│   └── references/
└── CLAUDE.md                 # LLM behavior rules
```

## 9-Point Lint Checklist

`/wiki lint` performs these checks in order:

1. **Tag health** — missing `wiki` / type / domain tags → auto-fix
2. **Index completeness** — pages on disk but not in index → auto-fix
3. **Dead wikilinks** — links to non-existent pages → report
4. **Orphan pages** — zero inbound links → report
5. **Contradiction review** — unresolved `⚠️` markers → report
6. **Page size** — exceeds split threshold → suggest split
7. **Unlinked concepts** — terms appearing ≥3× without dedicated page → suggest creation
8. **Open audit scan** — unprocessed feedback in `audit/` → process by severity
9. **Log completeness** — missing today's log file → auto-create

## Quick Start

### Option A: Scaffold Script

```bash
# Clone this repo
git clone https://github.com/zebinwang-code/llm-wiki-ops.git
cd llm-wiki-ops

# Scaffold a new wiki
./scripts/scaffold.sh ~/my-wiki "My Knowledge Base"
```

### Option B: Manual Setup

1. Copy `schema.md` to your wiki directory as `_schema.md`
2. Copy `CLAUDE.md` to your project root
3. Create the directory structure (see above)
4. Create `index.md` with dual-axis navigation (by domain + by type)
5. Start ingesting sources with `/wiki ingest`

### Option C: Claude Code Skill

Copy `SKILL.md` to `~/.claude/skills/llm-wiki-ops/SKILL.md`. The skill activates when you work with wiki knowledge bases.

## Page Templates

See [templates/](templates/) for ready-to-use templates:

- [Entity](templates/entity.md) — people, companies, products, tools
- [Concept](templates/concept.md) — frameworks, methods, theories, patterns
- [Domain](templates/domain.md) — topic overviews (Maps of Content)
- [Analysis](templates/analysis.md) — query results, insights
- [Comparison](templates/comparison.md) — side-by-side analysis
- [Audit](templates/audit.md) — structured feedback

## Examples

See [examples/](examples/) for real-world examples:

- [Example index.md](examples/index.md) — dual-axis navigation
- [Example daily log](examples/log-entry.md) — operation logging format
- [Wiki Health dashboard](examples/wiki-health.md) — Obsidian Dataview health monitoring

## Design Principles

1. **Compile once, query many** — knowledge is compiled into wiki pages, not re-derived on every question
2. **Source documents are evidence** — never delete raw sources; they're the wiki's audit trail (like git history)
3. **Contradictions are features** — flag them with `⚠️`, don't hide them; unresolved tensions are knowledge
4. **Wiki writes itself** — unlinked concept detection means the wiki identifies its own gaps
5. **Feedback is structured** — audit files with text anchors, not ad-hoc edits that lose context
6. **Scale limit: ~200 pages** — beyond 100K tokens, you need a search engine; this system is for curated knowledge, not a dump

## Comparison with Other Approaches

| Feature | RAG | Karpathy LLM Wiki | lewislulu/llm-wiki-skill | **This System** |
|---------|-----|-------------------|--------------------------|-----------------|
| Knowledge persistence | No (re-derive) | Yes (compiled) | Yes (compiled) | Yes (compiled) |
| Source triage | No | No | No | **4-level permissions** |
| Lifecycle automation | No | Manual | Manual (5 ops) | **4 closed loops** |
| Human feedback | N/A | N/A | Text-anchor audit | **Text-anchor audit** |
| Knowledge gap detection | No | No | No | **Unlinked concept detection** |
| Version conflicts | N/A | N/A | N/A | **Decision matrix** |
| Page size discipline | No | Suggested | Yes (400-1200) | **Yes + auto-detect** |
| Domain organization | No | Flat | Flat (3 types) | **Multi-domain + color tags** |
| Operation logs | No | No | Daily logs | **Daily logs** |
| Health monitoring | No | No | Python lint (7 checks) | **9-point lint + Dataview** |

## Acknowledgments

- [Andrej Karpathy](https://gist.github.com/karpathy/1dd0294ef9567971c1e4348a90d69285) — the original LLM Wiki concept
- [lewislulu/llm-wiki-skill](https://github.com/lewislulu/llm-wiki-skill) — structured audit system, text anchors, lint automation
- [Tiago Forte](https://www.buildingasecondbrain.com/) — CODE/PARA methodology
- Niklas Luhmann — Zettelkasten: atomic notes + dense linking

## License

MIT
