# GEO / AI-Search Analysis — KeepAwake

Audit of `https://abhinav-ranish.github.io/KeepAwake/` against the `seo-geo`
methodology (Generative Engine Optimization — AI Overviews, ChatGPT search,
Perplexity). Dated 2026-06-19.

> Framing per Google's AI Optimization Guide: GEO is **SEO fundamentals applied
> to AI-search surfaces**, not a separate discipline. Findings below are scored
> against citability, structure, multi-modality, authority/recency, and technical
> accessibility.

## 1. GEO Readiness Score: **81 / 100**

| Criterion | Weight | Score | Notes |
|-----------|--------|-------|-------|
| Citability | 25% | 22 | Definition-first answer ("KeepAwake is…"), self-contained ~150-word block, front-loaded in first 30% of page. |
| Structural readability | 20% | 19 | Clean H1→H2 hierarchy, question-style headings, comparison table, lists, FAQ. |
| Multi-modal | 15% | 8 | OG image + SVG icon present, but **no real app screenshots / demo GIF / video** (multi-modal lifts selection ~156%). |
| Authority & recency | 20% | 12 | Author byline + Person schema + visible/structured dates done. **Off-site brand mentions absent** (new domain). |
| Technical accessibility | 20% | 20 | Static SSR HTML (AI crawlers don't run JS), AI crawlers allowed, llms.txt, sitemap, valid schema. |

## 2. Platform breakdown (foundation vs. off-page reality)
- **Google AI Overviews** — strongly ranking-correlated. On-page is maxed; citation depends on the page actually ranking, which needs indexing + age + links.
- **Google AI Mode** — broader pool, weights freshness + entity authority. Dates and citable passages now in place; entity authority still to build.
- **ChatGPT** — cites Wikipedia (47.9%) / Reddit (11.3%). Needs entity presence off-site.
- **Perplexity** — cites Reddit (46.7%). Needs community discussion/mentions.

## 3. AI crawler access — ✅ PASS
`robots.txt` explicitly allows GPTBot, OAI-SearchBot, ChatGPT-User, ClaudeBot,
anthropic-ai, PerplexityBot, Google-Extended, Applebot-Extended, Bingbot, CCBot.
Sitemap referenced.

## 4. llms.txt — ✅ PRESENT
`/llms.txt` published with summary, key facts, common questions, and links.
(Note: per primary-source evidence, llms.txt is not yet a proven citation lever;
present for completeness, no harm.)

## 5. Brand-mention analysis — ⚠️ GAP (off-page)
No detectable presence on Wikipedia, Reddit, YouTube, or LinkedIn yet. Brand
mentions correlate ~3× more strongly with AI visibility than backlinks — this is
the single biggest remaining lever and is **off-page** (cannot be fixed in code).

## 6. Passage-level citability — ✅ GOOD
"What is KeepAwake?" block is ~150 words (within the optimal 134–167 range),
self-contained, definition-first, and positioned in the first 30% of the page.
FAQ answers are short and self-contained.

## 7. Server-side rendering — ✅ PASS
Single static HTML file. All content (including the answer block, table, and FAQ)
is in the served HTML with no JavaScript dependency. AI crawlers see everything.

## 8. Top 5 highest-impact changes
1. **[off-page] Build brand mentions** — post to relevant subreddits, a short
   YouTube/Loom demo, Hacker News "Show HN". Highest AI-visibility lever.
2. **[on-page] Add real screenshots + a demo GIF** of the menu/dropdown — closes
   the multi-modal gap (+~156% selection) and helps image search.
3. **[off-page] Get indexed** — submit the Pages URL + sitemap to Google Search
   Console and Bing Webmaster Tools.
4. **[off-page] Inbound links** — add the site to the GitHub repo "About", README
   badge, and any personal site.
5. **[maintenance] Refresh cadence** — update the visible date on each release;
   content <3 months old is ~3× more citable.

## 9. Schema — ✅ IMPLEMENTED
`SoftwareApplication` (price 0, featureList, downloadUrl, datePublished/Modified),
`WebSite`, `FAQPage` (5 Q&A), `Person` author with `sameAs`. Valid JSON-LD.
*Optional next:* add `VideoObject` once a demo video exists.

## 10. Content reformatting — ✅ DONE this pass
- Reframed lead heading as a question ("What is KeepAwake?").
- Expanded the answer block to optimal citable length, definition-first.
- Added a question-headed comparison table (KeepAwake vs Amphetamine vs caffeinate).
- Added visible + structured publish/update dates.

---

### Bottom line
**On-page GEO/SEO is essentially maxed (technical 20/20, structure 19/20,
citability 22/25).** The remaining points are off-page — brand mentions,
indexing, links, and a demo screenshot/GIF — which depend on promotion and time,
not page code.
