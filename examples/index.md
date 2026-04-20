---
type: wiki-index
created: 2025-01-15
updated: 2025-04-20
tags: [wiki, index, meta]
---
# Wiki Index

> LLM reads this file first when querying. Humans: browse by domain (Axis 1) or by type (Axis 2).

## Stats
- Total pages: 42 (incl. 1 archived)
- Domains: 4

---

## Axis 1: By Domain

### 🔴 API Platform
> Domain overview → [[API Platform]]

| Type | Pages |
|------|-------|
| Entities | [[Stripe API]] · [[Twilio]] |
| Concepts | [[Rate Limiting]] · [[Pagination Patterns]] · [[Error Handling]] · [[Webhook Design]] |
| Analyses | [[API Latency Optimization Study]] |

### 🟢 Product Design
> Domain overview → [[Product Design]]

| Type | Pages |
|------|-------|
| Concepts | [[Jobs To Be Done]] · [[Kano Model]] · [[Feature Prioritization]] |
| Comparisons | [[JTBD vs User Stories]] |

### 🟣 Engineering Practices
> Domain overview → [[Engineering Practices]]

| Type | Pages |
|------|-------|
| Entities | [[Claude Code]] · [[Cursor]] |
| Concepts | [[Context Engineering]] · [[Agentic Workflows]] · [[Test-Driven Development]] |

### 🔵 Knowledge Management
> Domain overview → [[Knowledge Management]]

| Type | Pages |
|------|-------|
| Concepts | [[Zettelkasten]] · [[PARA Method]] · [[LLM Wiki]] · [[Progressive Summarization]] |
| Comparisons | [[PKM Tools Comparison]] |

---

## Axis 2: By Type

### Entities
- [[Stripe API]] — Payment processing API, gold standard for developer experience `🔴`
- [[Twilio]] — Communication APIs (SMS, voice, video) `🔴`
- [[Claude Code]] — Anthropic's CLI coding assistant `🟣`
- [[Cursor]] — AI-first code editor `🟣`

### Concepts
- [[Rate Limiting]] — Token bucket vs sliding window algorithms `🔴`
- [[Pagination Patterns]] — Cursor vs offset pagination trade-offs `🔴`
- [[Error Handling]] — Structured error responses with retry guidance `🔴`
- [[Webhook Design]] — Event-driven API notifications `🔴`
- [[Jobs To Be Done]] — Demand-side innovation framework `🟢`
- [[Kano Model]] — Feature satisfaction classification `🟢`
- [[Feature Prioritization]] — RICE, ICE, and weighted scoring `🟢`
- [[Context Engineering]] — Managing LLM context windows effectively `🟣`
- [[Agentic Workflows]] — Multi-step LLM task execution patterns `🟣`
- [[Test-Driven Development]] — Write tests first, then implementation `🟣`
- [[Zettelkasten]] — Luhmann's slip-box note method `🔵`
- [[PARA Method]] — Projects/Areas/Resources/Archives `🔵`
- [[LLM Wiki]] — Karpathy pattern: LLM compiles persistent knowledge `🔵`
- [[Progressive Summarization]] — Four-layer progressive highlighting `🔵`

### Domains
- [[API Platform]] — API design, scaling, and developer experience `🔴`
- [[Product Design]] — Cross-product reusable design frameworks `🟢`
- [[Engineering Practices]] — Development tools and methodology `🟣`
- [[Knowledge Management]] — PKM theory + AI-enhanced practice `🔵`

### Analyses
- [[API Latency Optimization Study]] — P99 from 450ms to 120ms `🔴`

### Comparisons
- [[JTBD vs User Stories]] — When to use which framework `🟢`
- [[PKM Tools Comparison]] — Obsidian/Notion/Logseq/Roam `🔵`

### Archived
- [[REST vs GraphQL]] — Superseded by unified API gateway decision `🔴`

---

## Recent Activity

> Full history in `log/` directory (one file per day, format `YYYYMMDD.md`)

- 2025-04-20 | compile | Wiki infra upgrade v2.0: added audit/ + log/ + page size limits + unlinked concept detection
- 2025-04-19 | ingest | Compiled webhook design patterns from Stripe docs
- 2025-04-18 | lint | Weekly lint: fixed 3 tag issues, flagged 2 orphan pages
