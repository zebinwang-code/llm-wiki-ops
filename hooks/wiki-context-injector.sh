#!/bin/bash
# wiki-context-injector.sh
# Loop 2 enforcement: inject relevant wiki context when user prompt matches registered
# domain keywords. Runs as a UserPromptSubmit hook — pre-LLM, so the wiki context is
# already in context when the LLM starts responding, preventing it from bypassing the
# wiki with zero-shot reasoning.
#
# Hook event: UserPromptSubmit
# Input: JSON on stdin with shape {"prompt": "...", "session_id": "..."}
# Output: stdout is injected as additionalContext into the model's context window
#
# Token budget: ~2000 tokens worst case (index excerpt ~300 + 1-2 domain pages capped at ~800 each)
# Opt-out: prompt contains "skip wiki" / "跳过wiki" / "不查知识库", or starts with "/"
#
# Configuration: Set WIKI_ROOT below to your wiki directory (containing index.md, Domains/, log/).
# Customize the domain matcher blocks in section 3 to match your own registered domains.

set -euo pipefail

# ============================================================================
# 1. Configuration — customize these for your wiki
# ============================================================================
WIKI_ROOT="${WIKI_ROOT:-$HOME/wiki}"
LOG_DIR="$WIKI_ROOT/log"
TODAY=$(date +%Y%m%d)
LOG_FILE="$LOG_DIR/${TODAY}.md"

# Fail-safe: if wiki not found, silently exit (don't break user's prompt)
[ -d "$WIKI_ROOT" ] || exit 0

# ============================================================================
# 2. Parse input — read JSON from stdin, extract prompt
# ============================================================================
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('prompt', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

[ -z "$PROMPT" ] && exit 0

# Opt-out: user explicitly said skip wiki
if echo "$PROMPT" | grep -qiE "skip wiki|跳过[[:space:]]?wiki|不查(知识库|wiki)|不用wiki"; then
    exit 0
fi

# Skip slash commands
FIRST_CHAR=$(echo "$PROMPT" | sed 's/^[[:space:]]*//' | head -c 1)
[ "$FIRST_CHAR" = "/" ] && exit 0

# ============================================================================
# 3. Domain matching — customize keyword patterns for your registered domains
# ============================================================================
# Compat: macOS bash 3.2 has no nameref (local -n). Use global array.
MATCHED=()

# Example: domain "api-platform" with its trigger keywords
# if echo "$PROMPT" | grep -qiE "api|rest|graphql|endpoint|webhook|rate limit"; then
#     MATCHED+=("api-platform")
# fi

# Example: domain "product-design"
# if echo "$PROMPT" | grep -qiE "UX|product design|competitor|PRD|user experience"; then
#     MATCHED+=("product-design")
# fi

# Example: domain "engineering-practices"
# if echo "$PROMPT" | grep -qiE "Claude[[:space:]-]?Code|\bSkill\b|Harness|Karpathy|Subagent|Agentic"; then
#     MATCHED+=("engineering-practices")
# fi

# Example: domain "knowledge-management"
# if echo "$PROMPT" | grep -qiE "PKM|Zettelkasten|LLM[[:space:]]?Wiki|knowledge management"; then
#     MATCHED+=("knowledge-management")
# fi

# --- ADD YOUR DOMAIN MATCHERS ABOVE THIS LINE ---

# No match → silent exit (most prompts go here, zero overhead)
[ ${#MATCHED[@]} -eq 0 ] && exit 0

# Deduplicate preserving order (bash-3.2 safe)
UNIQUE_MATCHED=()
for d in "${MATCHED[@]}"; do
    skip=false
    for existing in "${UNIQUE_MATCHED[@]+${UNIQUE_MATCHED[@]}}"; do
        [ "$d" = "$existing" ] && skip=true && break
    done
    $skip || UNIQUE_MATCHED+=("$d")
done

# ============================================================================
# 4. Build context block — written to stdout as additionalContext
# ============================================================================

echo "<wiki-context>"
echo "[Loop 2 Auto-Query] Relevant wiki domains detected. You MUST consult these pages and cite them with [[wikilinks]] in your answer. If none are relevant, say so explicitly."
echo ""

echo "## Matched domains"
for d in "${UNIQUE_MATCHED[@]}"; do
    echo "- $d"
done
echo ""

# Lightweight index excerpt: stats + recent activity only (~300 tokens)
if [ -f "$WIKI_ROOT/index.md" ]; then
    echo "## Wiki at a glance (from index.md)"
    echo ""
    # Extract stats section (between "## Stats" and first "##" after)
    awk '
        /^## (Stats|统计)/ {p=1}
        /^## [^S统]/ && p {p=0; exit}
        p {print}
    ' "$WIKI_ROOT/index.md"
    echo ""
    awk '
        /^## (Recent Activity|最近活动)/ {p=1}
        /^## [^R最]/ && p {p=0; exit}
        p {print}
    ' "$WIKI_ROOT/index.md"
    echo ""
fi

# Domain pages (cap at 2 to control token budget)
echo "## Relevant domain pages"
echo ""
COUNT=0
MAX_DOMAINS=2
for domain in "${UNIQUE_MATCHED[@]}"; do
    [ $COUNT -ge $MAX_DOMAINS ] && break
    # Try several possible page locations
    DOMAIN_FILE=""
    for candidate in "$WIKI_ROOT/domains/${domain}.md" "$WIKI_ROOT/Domains/${domain}.md"; do
        [ -f "$candidate" ] && DOMAIN_FILE="$candidate" && break
    done

    if [ -n "$DOMAIN_FILE" ]; then
        echo "### $domain"
        echo ""
        # Cap at 80 lines per page: ensures 2 domains + index fit under 2000 token budget
        head -80 "$DOMAIN_FILE"
        echo ""
    else
        echo "### $domain"
        echo "(domain page not found)"
        echo ""
    fi
    COUNT=$((COUNT + 1))
done

echo "</wiki-context>"

# ============================================================================
# 5. Log injection for observability (daily wiki log)
# ============================================================================
mkdir -p "$LOG_DIR"
if [ ! -f "$LOG_FILE" ]; then
    cat > "$LOG_FILE" <<HEADER
---
type: wiki-log
date: $(date +%Y-%m-%d)
---
# $(date +%Y-%m-%d) Wiki Log
HEADER
fi

NOW=$(date +%H:%M)
DOMAINS_STR=$(IFS=,; echo "${UNIQUE_MATCHED[*]}")
# Character-safe truncation (respects multi-byte Unicode)
PROMPT_PREVIEW=$(echo "$PROMPT" | tr '\n' ' ' | python3 -c "import sys; s=sys.stdin.read(); print(s[:60], end='')")
{
    echo ""
    echo "## [$NOW] query | Auto-injected wiki context (Loop 2)"
    echo "- Matched domains: $DOMAINS_STR"
    echo "- Prompt preview: ${PROMPT_PREVIEW}..."
} >> "$LOG_FILE"

exit 0
