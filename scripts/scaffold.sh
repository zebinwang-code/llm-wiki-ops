#!/usr/bin/env bash
# scaffold.sh — Bootstrap a new LLM Wiki knowledge base
# Usage: ./scaffold.sh <wiki-root> "<Topic Title>"
# Example: ./scaffold.sh ~/my-wiki "API Platform Knowledge Base"

set -euo pipefail

WIKI_ROOT="${1:?Usage: scaffold.sh <wiki-root> \"<Topic Title>\"}"
TITLE="${2:-My Knowledge Base}"
TODAY=$(date +%Y-%m-%d)

echo "📚 Scaffolding LLM Wiki: $TITLE"
echo "   Location: $WIKI_ROOT"

# Create directory structure
mkdir -p "$WIKI_ROOT"/{wiki/{entities,concepts,domains,analyses,comparisons,audit/resolved,log},raw/{articles,notes,references}}

# Copy schema if available in same directory as script
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ -f "$SCRIPT_DIR/schema.md" ]; then
    cp "$SCRIPT_DIR/schema.md" "$WIKI_ROOT/wiki/_schema.md"
    echo "   ✓ Copied _schema.md"
fi

# Copy CLAUDE.md if available
if [ -f "$SCRIPT_DIR/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/CLAUDE.md" "$WIKI_ROOT/CLAUDE.md"
    echo "   ✓ Copied CLAUDE.md"
fi

# Create index.md
cat > "$WIKI_ROOT/wiki/index.md" << EOF
---
type: wiki-index
created: $TODAY
updated: $TODAY
tags: [wiki, index, meta]
---
# Wiki Index — $TITLE

> LLM reads this file first when querying. Browse by domain (Axis 1) or by type (Axis 2).

## Stats
- Total pages: 0
- Domains: 0

---

## Axis 1: By Domain

<!-- Add domains here as you ingest content -->

---

## Axis 2: By Type

### Entities
<!-- None yet -->

### Concepts
<!-- None yet -->

### Domains
<!-- None yet -->

### Analyses
<!-- None yet -->

### Comparisons
<!-- None yet -->

---

## Recent Activity

> Full history in \`log/\` directory (one file per day, format \`YYYYMMDD.md\`)

- $TODAY | init | Wiki structure created: $TITLE
EOF
echo "   ✓ Created index.md"

# Create first log entry
LOG_FILE="$WIKI_ROOT/wiki/log/$(date +%Y%m%d).md"
cat > "$LOG_FILE" << EOF
---
type: wiki-log
date: $TODAY
---
# $TODAY Wiki Log

## [$(date +%H:%M)] scaffold | Wiki structure created
- Title: $TITLE
- Directory structure initialized
- Schema and CLAUDE.md copied from llm-wiki-ops
EOF
echo "   ✓ Created first log entry"

# Create .gitkeep files for empty directories
for dir in "$WIKI_ROOT"/wiki/{entities,concepts,domains,analyses,comparisons,audit/resolved} "$WIKI_ROOT"/raw/{articles,notes,references}; do
    touch "$dir/.gitkeep"
done

echo ""
echo "✅ Wiki scaffolded successfully!"
echo ""
echo "Next steps:"
echo "  1. Review wiki/_schema.md and customize domain tags"
echo "  2. Add raw sources to raw/"
echo "  3. Run /wiki ingest to compile your first pages"
echo "  4. Set up CLAUDE.md behavior rules in your project root"
