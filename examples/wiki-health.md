---
type: meta
created: 2025-01-15
tags: [wiki, meta]
---
# Wiki Health Dashboard

> Open this page in Obsidian to see live Dataview results. All queries auto-update.

## 🔴 Pages Without Domain Tags (must fix)

These pages don't belong to any domain — they won't appear in Axis 1 navigation:

```dataview
TABLE tags AS "Current Tags", type AS "Type"
FROM "wiki"
WHERE type != null
  AND !contains(tags, "api") AND !contains(tags, "product-design")
  AND !contains(tags, "engineering") AND !contains(tags, "pkm")
  AND !contains(tags, "meta")
  AND !contains(file.name, "_schema") AND !contains(file.name, "index")
  AND !contains(file.name, "Wiki Health")
SORT file.name ASC
```

> **How to fix:** Add the correct domain tag to the page's frontmatter tags. See `_schema.md` for registered domains.

---

## 🟡 Orphan Pages (zero inbound links)

Wiki pages that no other page links to:

```dataview
LIST
FROM "wiki"
WHERE type != null
  AND !contains(tags, "meta") AND !contains(tags, "index")
  AND length(file.inlinks) = 0
  AND !contains(file.name, "_schema") AND !contains(file.name, "index")
  AND !contains(file.name, "Wiki Health")
```

---

## 📊 Overview

```dataview
TABLE WITHOUT ID
  length(rows) AS "Total Pages",
  length(filter(rows, (r) => r.type = "wiki-entity")) AS "Entities",
  length(filter(rows, (r) => r.type = "wiki-concept")) AS "Concepts",
  length(filter(rows, (r) => r.type = "wiki-domain")) AS "Domains",
  length(filter(rows, (r) => r.type = "wiki-analysis")) AS "Analyses",
  length(filter(rows, (r) => r.type = "wiki-comparison")) AS "Comparisons"
FROM "wiki"
WHERE type != null AND !contains(tags, "meta")
GROUP BY true
```

---

## ✅ Recently Updated

```dataview
TABLE updated AS "Updated", type AS "Type"
FROM "wiki"
WHERE type != null AND !contains(tags, "meta")
SORT updated DESC
LIMIT 10
```
