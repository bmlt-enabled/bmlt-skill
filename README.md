# bmlt-skill

A Claude agent skill that teaches AI assistants how to query any [BMLT](https://bmlt.app) (Basic Meeting List Tool) root server for Narcotics Anonymous meeting data.

Knowledge-only — no MCP server, no install — Claude uses `WebFetch` / `curl` directly once this skill is loaded.

## Install

Via the [skills CLI](https://skills.sh):

```bash
npx skills add bmlt-enabled/bmlt-skill          # project-local (.claude/skills/bmlt/)
npx skills add bmlt-enabled/bmlt-skill -g -y    # user-global (~/.claude/skills/bmlt/), no prompts
```

Or clone/copy the directory into `~/.claude/skills/bmlt/` (user-global) or `<project>/.claude/skills/bmlt/` (project-local).

## Update

```bash
npx skills check                 # list available updates without installing
npx skills update                # update all installed skills (auto-detects scope)
npx skills update bmlt           # update just this skill
npx skills update -g             # user-global installs only
npx skills update -p             # project installs only
```

The CLI pulls the latest `main` of this repo each run — any push here is picked up on the next `update`.

## What it covers

- All 9 Semantic API endpoints (`GetSearchResults`, `GetFormats`, `GetServiceBodies`, `GetChanges`, `GetFieldKeys`, `GetFieldValues`, `GetNAWSDump`, `GetServerInfo`, `GetCoverageArea`)
- Full filter grammar for `GetSearchResults`
- Server discovery via the aggregator `serverList.json`
- Service body hierarchy (`ZF → RS → AS → MA`)
- Common recipe book (nearest meetings, virtual only, tonight's list, NAWS export…)
- Gotchas: format×endpoint matrix, weekday indexing, aggregator-mode filter requirement, published-status flags

## Files

```
SKILL.md                        main skill — frontmatter + decision flow
references/
  api-endpoints.md              9 endpoints with params & format compat
  search-parameters.md          GetSearchResults filter grammar
  sample-responses.md           real JSON shapes per endpoint
  presenting-meetings.md        how to format results for a human
  data-types.md                 weekdays, venue types, field keys, langs
examples/
  common-queries.md             ready-to-paste URL recipes
scripts/
  bmlt.sh                       thin curl/jq helper
```

## Try it

```bash
scripts/bmlt.sh servers                                                   # list every known root
scripts/bmlt.sh call https://bmlt.sezf.org/main_server/ GetServerInfo
scripts/bmlt.sh call https://bmlt.sezf.org/main_server/ GetSearchResults "services=5&recursive=1&venue_types=2"
```
