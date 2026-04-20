# Wiki Schema — Knowledge Compilation Conventions

Copy this file to your wiki directory as `_schema.md`. LLM must follow these conventions when creating or updating wiki pages.

## Directory Structure

```
wiki/
├── index.md          # Master index (LLM reads first when querying)
├── _schema.md        # This file (structure conventions)
├── entities/         # People, companies, products, tools
├── concepts/         # Frameworks, methods, theories, patterns
├── domains/          # Topic overviews, knowledge maps (MOCs)
├── analyses/         # Query results, insights, findings
├── comparisons/      # Side-by-side analysis
├── audit/            # Human feedback (open)
│   └── resolved/     # Processed feedback
└── log/              # Daily operation logs (YYYYMMDD.md)
```

## Page Templates

### Entity

```markdown
---
type: wiki-entity
category: person|company|product|tool
created: YYYY-MM-DD
updated: YYYY-MM-DD
wiki-sources: []
tags: [wiki, entity, <domain-tag>]
---
# Entity Name

## Overview
[1-2 paragraph introduction]

## Key Facts
- **Attribute 1:** Value
- **Attribute 2:** Value

## Details
[In-depth description, linking to related concepts]

## Timeline
- YYYY-MM-DD: Event 1
- YYYY-MM-DD: Event 2

## Related
- [[Related Entity]]
- [[Related Concept]]
```

### Concept

```markdown
---
type: wiki-concept
category: framework|method|theory|pattern
created: YYYY-MM-DD
updated: YYYY-MM-DD
wiki-sources: []
tags: [wiki, concept, <domain-tag>]
---
# Concept Name

## Definition
[Clear, concise definition]

## Key Points
- Point 1
- Point 2
- Point 3

## How It Works
[Detailed explanation]

## Applications
[Real-world use cases]

## Related
- [[Related Concept 1]]
- [[Related Concept 2]]
```

### Domain (Map of Content)

```markdown
---
type: wiki-domain
created: YYYY-MM-DD
updated: YYYY-MM-DD
wiki-sources: []
source-count: 0
tags: [wiki, domain, <domain-tag>]
---
# Domain Name

## Overview
[High-level summary of this knowledge domain]

## Core Concepts
- [[Concept 1]] — one-line description
- [[Concept 2]] — one-line description

## Key Entities
- [[Entity 1]] — role/relationship
- [[Entity 2]] — role/relationship

## Current Understanding
[Synthesized analysis based on compiled sources]

## Open Questions
- [ ] Unanswered question 1
- [ ] Unanswered question 2

## Related
- [[Related Domain]]
```

### Analysis

```markdown
---
type: wiki-analysis
question: "The question that triggered this analysis"
created: YYYY-MM-DD
wiki-sources: []
tags: [wiki, analysis, <domain-tag>]
---
# Analysis Title

## Question
[The question being answered]

## Analysis
[Reasoning process based on wiki knowledge]

## Conclusion
[Key findings]

## Evidence
- From [[Page 1]]: supporting detail
- From [[Page 2]]: supporting detail

## Related
- [[Related Analysis]]
```

### Comparison

```markdown
---
type: wiki-comparison
subjects: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
wiki-sources: []
tags: [wiki, comparison, <domain-tag>]
---
# A vs B

## Dimensions

| Dimension | A | B |
|-----------|---|---|
| Dim 1 | Value | Value |
| Dim 2 | Value | Value |

## Analysis
[In-depth comparison discussion]

## Conclusion
[When to choose which]

## Related
- [[A]]
- [[B]]
```

## Source Document Triage

Before ingesting any source, classify it. Different levels have different write permissions:

| Level | Meaning | Wiki Permission | Typical Examples |
|-------|---------|-----------------|-----------------|
| `authoritative` | Latest final version | **Overwrite** wiki content, old content moves to evolution trail | Final spec v2.0, board decision |
| `superseded` | Replaced by newer version | **Evolution trail only**, don't modify wiki text | Spec v1.0 (replaced by v2.0) |
| `input` | Meeting notes, raw data | **Append** new info, but don't overwrite authoritative content | Meeting notes, survey results |
| `discussion` | Drafts, brainstorms | **Evolution trail + mark pending** | Draft proposals, discussion notes |

### Triage Rules

1. **Multiple versions of same topic** → latest = `authoritative`, older = `superseded`
2. **Meeting notes / research data** → always `input` (facts, not direction)
3. **Title contains "draft" / "discussion" / "WIP"** → default `discussion`
4. **Unsure** → ask: "Is this the current final version or an intermediate document?"

### wiki-sources Format

```yaml
wiki-sources:
  - API Design Spec v2.0 (authoritative)
  - API Design Spec v1.0 (superseded)
  - Meeting Notes 2025-03-31 (input)
```

## Version Conflict Resolution

When a new source contradicts existing wiki content:

| New Source Level | Existing Content From | Action |
|-----------------|----------------------|--------|
| authoritative | authoritative | **Overwrite** + evolution trail |
| authoritative | input/discussion | **Overwrite** |
| input | authoritative | **Don't overwrite**, append with source note |
| input | input | **Merge**, keep both |
| discussion | any | **Don't modify**, evolution trail only |
| superseded | any | **Don't modify**, evolution trail only |

### Contradiction Handling

- Authoritative vs authoritative → newer date wins, older moves to evolution trail
- Input vs authoritative → keep authoritative, mark input's claim with `> ⚠️ Contradiction:`
- Unresolved → mark `> ❓ Pending:` and add to domain page's "Open Questions"

## Evolution Trail

For pages with multiple iterations, add `## Evolution Trail` before `## Related`:

```markdown
## Evolution Trail
<!-- Only record decision turning points, not all edits -->
| Date | Source | Change |
|------|--------|--------|
| 2025-03-24 | Spec v1.0 | Initial: annual gift box $3,000-4,000/person |
| 2025-04-02 | Spec v3.0 | Simplified to 3+1 structure, dropped coffee perk |
| 2025-04-07 | Strategy Update | Quarterly light-touch replaces annual gift box |
```

### Rules

1. Only record **decision turning points** (direction changed, numbers changed, plan was killed)
2. Each record ≤ 1 line: date, source, change summary
3. When trail exceeds 10 entries, keep recent 10, fold older ones into `<details>`

## Domain Tagging

Every wiki page must include at least one registered domain tag:

```yaml
tags: [wiki, concept, machine-learning, nlp]
#      ^must  ^type   ^domain tags (at least one)
```

- Tag 1: always `wiki`
- Tag 2: page type (`entity` / `concept` / `domain` / `analysis` / `comparison`)
- Tag 3+: domain tags and topic tags
- Cross-domain pages can have multiple domain tags

### Registering New Domains

When ingested content doesn't belong to any existing domain:
1. Create new `wiki/domains/domain-name.md`
2. Register domain name, tags, and color in this schema
3. Update `index.md` first axis with new domain section

## Page Size Limits

| Page Type | Target | Split Threshold |
|-----------|--------|----------------|
| Entity | 200–500 words | > 800 words |
| Concept | 400–1200 words | > 1500 words |
| Domain | 300–800 words | Never split (MOC) |
| Analysis | 400–1200 words | > 1500 words |
| Comparison | 300–1000 words | > 1500 words |

### Split Rules

When a page exceeds its threshold:
1. Create subfolder (same name as page) + `index.md` as entry point
2. Split each independent topic into its own page
3. Original page becomes `index.md`, linking to sub-pages via wikilinks
4. `/wiki lint` auto-detects oversized pages

## Structured Audit

Audit is the structured channel for Loop 3 (human review). Humans file audit files instead of directly editing wiki pages.

### Audit File Template

Filename: `YYYYMMDD-HHMMSS-<slug>.md` (slug ≤ 30 chars)

```markdown
---
id: YYYYMMDD-HHMMSS-<4-hex>
target: "wiki page path (relative to wiki/)"
severity: error|warn|suggest|info
status: open
created: YYYY-MM-DD HH:MM
author: human|llm
anchor:
  before: "~80 chars of context before target text"
  text: "the exact text to modify"
  after: "~80 chars of context after target text"
---
## Feedback
[Describe the issue or suggestion]

## Resolution
<!-- LLM fills this after processing -->
```

### Severity Levels

| Level | Meaning | Priority |
|-------|---------|----------|
| `error` | Factual error (numbers, dates, causation) | Fix immediately |
| `warn` | Stale content (decision changed, data updated) | Fix at next lint |
| `suggest` | Wording improvement, additional info | Batch process |
| `info` | Background context, supplementary notes | Adopt when appropriate |

### Text Anchors

Use text context instead of line numbers — wiki pages are continuously edited:

- `anchor.before` — ~80 chars before target
- `anchor.text` — exact text to modify
- `anchor.after` — ~80 chars after target

**Anchor resolution priority** (when LLM processes audit):
1. Exact match of `anchor.text`
2. Full-text search for `anchor.text` (handles paragraph moves)
3. Use `before` + `after` context to locate (handles minor text edits)

### Processing Flow

1. **Scan**: `/wiki lint` scans `audit/` for open files
2. **Locate**: Find target via anchor
3. **Fix**: Modify wiki page based on severity and content
4. **Record**: Fill in `## Resolution` with what was done
5. **Archive**: Set `status: resolved`, move to `audit/resolved/`
6. **Log**: Record audit operation in today's `log/YYYYMMDD.md`

### Rejection

If audit feedback is invalid:
- Set `status: resolved`
- Write rejection reason in `## Resolution`
- Still move to `audit/resolved/` (preserve decision trail)

## Daily Operation Logs

Record all wiki operations in `log/YYYYMMDD.md` (one file per day):

```markdown
---
type: wiki-log
date: YYYY-MM-DD
---
# YYYY-MM-DD Wiki Log

## [HH:MM] <operation> | <description>
- Detail 1
- Detail 2
```

### Operation Types

`ingest` · `compile` · `lint` · `audit` · `query` · `split` · `scaffold` · `archive`

### Rules

- One file per day, entries in reverse chronological order
- `index.md` "Recent Activity" keeps only last 3 entries + pointer to `log/`
- Full history lives in `log/` directory

## General Rules

1. **Source tracking**: Every page's `wiki-sources` records information sources and their levels
2. **Update timestamp**: Update `updated` field when modifying a page
3. **Dense linking**: Use `[[wikilinks]]` liberally, minimum 3 cross-references per page
4. **Contradiction marking**: Use `> ⚠️ Contradiction:` blockquote for conflicts
5. **Atomicity**: Each page focuses on one entity/concept/topic; don't merge
6. **Frontmatter**: Must start at line 1, no empty line after `---`
7. **Page size**: Follow size limits above; oversized pages trigger split suggestions during lint
8. **Audit priority**: When correcting wiki content, process `audit/` open feedback first
