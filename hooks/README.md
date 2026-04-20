# Hooks — Loop 2 Hard Enforcement

This directory contains the **mechanism** that turns Loop 2 (Auto-Query) from a soft rule ("read wiki before answering") into a hard mechanism enforced by the Claude Code harness.

## The Problem

Loop 2 is the weakest loop in the four-loop system. The rule "read `wiki/index.md` first, then answer" lives in `CLAUDE.md` and relies on LLM self-discipline. Under context pressure or for seemingly simple questions, LLMs bypass the wiki and answer from zero-shot reasoning — destroying the "compile once, query many" value proposition.

## The Solution

A `UserPromptSubmit` hook intercepts every user prompt **before the LLM sees it**, matches against registered domain keywords, and injects relevant wiki content into the context. The LLM cannot skip the wiki because the wiki is already in its context when it starts.

## Architecture

```
User Prompt
    ↓
[UserPromptSubmit Hook] ← hard interception point
    ↓
regex matcher in settings.json ← zero overhead for non-domain prompts
    ↓
wiki-context-injector.sh
    ├─ 1. Read domain keyword patterns
    ├─ 2. Match prompt against registered domains
    ├─ 3. Load matched domain pages + index excerpt
    └─ 4. Output <wiki-context> block to stdout
    ↓
LLM (wiki context already injected — cannot bypass)
    ↓
Response (cites wiki pages with [[wikilinks]])
```

## Files

- **`wiki-context-injector.sh`** — the hook script. Reads prompt from stdin (JSON), matches domain keywords, outputs wiki context to stdout.
- **`settings.json.example`** — example snippet to merge into `~/.claude/settings.json`.

## Installation

### Step 1: Customize the injector

Edit `wiki-context-injector.sh`:

1. Set `WIKI_ROOT` to your wiki directory (containing `index.md`, `domains/`, `log/`)
2. Replace the example domain-matcher blocks with patterns matching **your** registered domains. Each matcher block has this shape:

```bash
if echo "$PROMPT" | grep -qiE "keyword1|keyword2|keyword3"; then
    MATCHED+=("domain-page-name")
fi
```

The `"domain-page-name"` must match a file in `$WIKI_ROOT/domains/` (e.g., if you list `"api-platform"` it looks for `domains/api-platform.md`).

### Step 2: Copy the script to a permanent location

```bash
mkdir -p ~/.local/wiki-hooks
cp wiki-context-injector.sh ~/.local/wiki-hooks/
chmod +x ~/.local/wiki-hooks/wiki-context-injector.sh
```

### Step 3: Register the hook

Edit `~/.claude/settings.json` and merge the `hooks.UserPromptSubmit` array from `settings.json.example`. The matcher regex should be the **union of all your domain keywords** — this pre-filters prompts so the script only runs when there's potentially something to match (zero cost otherwise).

Example matcher for a tech-focused wiki:
```
"matcher": "api|rest|endpoint|UX|Claude[ -]?Code|PKM|Zettelkasten|...",
```

### Step 4: Reload

New hooks require a Claude Code config reload:
- Open the `/hooks` menu once (reloads config)
- Or restart Claude Code

### Step 5: Verify

Ask a domain question in your next Claude Code session. You should see:
- The LLM cites wiki pages with `[[wikilinks]]`
- A new `query | Auto-injected wiki context` entry in today's `wiki/log/YYYYMMDD.md`

## Token Budget

The script caps at ~2000 tokens per injection:

- Index excerpt: ~300 tokens
- Per-domain page: ~800 tokens (head 80 lines)
- Max 2 domains loaded

**Observed costs** (from Phase 1 MVP data):

| Scenario | Frequency | Tokens/prompt |
|----------|-----------|---------------|
| No match (skipped) | ~70% of prompts | 0 |
| Single domain (small) | ~20% | 450-800 |
| Single domain (large) | ~8% | 1100-1200 |
| Cross-domain (2 domains) | ~2% | 1400-2020 |

Daily estimate at 50 prompts/day: ~13K additional input tokens (~$0.20/day at Opus 4.x pricing).

## Observability

Every injection logs to `$WIKI_ROOT/log/YYYYMMDD.md` as:

```markdown
## [HH:MM] query | Auto-injected wiki context (Loop 2)
- Matched domains: domain1,domain2
- Prompt preview: <first 60 chars of prompt>...
```

Run `scripts/wiki-loop2-report.sh` (in the parent repo) to generate a weekly effectiveness report.

## Tuning

If hit rate is:

- **Too low (<20%)** — matcher regex is too narrow. Add more synonyms/variations.
- **Too high (>50%)** — matcher is catching off-topic prompts. Check log samples, tighten keywords.
- **Imbalanced** — one domain dominates. Either that's your actual focus (fine) or the domain's keywords are too broad.

## Compatibility

- Requires `python3` (for safe JSON parsing + multi-byte character handling)
- Tested on macOS bash 3.2 and Linux bash 4+
- No external dependencies beyond standard Unix tools
