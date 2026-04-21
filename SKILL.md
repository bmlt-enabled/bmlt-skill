---
name: bmlt
description: Query BMLT root servers for Narcotics Anonymous meeting data. Use for NA meeting lookup, service bodies, formats, NAWS exports, or any `*/main_server/client_interface/*` URL.
---

# BMLT Skill

Query any BMLT (Basic Meeting List Tool) root server for Narcotics Anonymous meeting data. BMLT is the world-standard meeting list system for NA, serving hundreds of regions globally. This skill teaches you how to build correct URLs against the **Semantic API** — no MCP server, no SDK, just HTTP.

## Decision flow

When the user asks a BMLT question, work through these steps in order:

1. **Identify the root server.** If the user hasn't named one, load the aggregator list (see [Discovering servers](#discovering-servers)) and either ask the user to pick, or infer from context (e.g. "NA meetings in Ohio" → `bmlt.naohio.org`). A BMLT root URL always ends in `/main_server/` or similar — everything hangs off `{rootURL}client_interface/{format}/`.
2. **Pick the endpoint.** See [references/api-endpoints.md](references/api-endpoints.md). For "find meetings" questions → `GetSearchResults`. For "what formats/regions/service bodies exist?" → `GetFormats` / `GetServiceBodies`. For exports → `GetNAWSDump` (CSV only).
3. **Build parameters.** See [references/search-parameters.md](references/search-parameters.md) for the full filter grammar. Always URL-encode values.
4. **Fetch** using `WebFetch` (preferred) or `curl` / `Bash`. BMLT responses are public and CORS-open, no auth needed.
5. **Present results** human-readably — don't dump raw JSON unless the user asked for it. Follow [references/presenting-meetings.md](references/presenting-meetings.md): show `meeting_name + location_text + start_time` for each, group by day, keep times in the meeting's local timezone.

## Discovering servers

The canonical list of every known BMLT root server is maintained in the aggregator repo:

```
https://raw.githubusercontent.com/bmlt-enabled/aggregator/refs/heads/main/serverList.json
```

Shape: `[{ "id": "99", "name": "Aotearoa New Zealand Region", "url": "https://bmlt.nzna.org/main_server/" }, ...]`

Fetch this once per session (it rarely changes). Match on `name` fuzzily — users say "Ohio" but the entry is "Ohio Region".

## Typical workflow: find meetings near a location

This is the 80% use case. The recommended pattern mirrors how the crumb-widget selector works:

1. **Pick root server** from the aggregator list.
2. **Call `GetServiceBodies`** on that server. Filter results by `type`:
   - `ZF` = Zonal Forum (multi-region, e.g. "Southeastern Zonal Forum")
   - `RS` = Region (e.g. "Ohio Region") — usually what users mean by "my region"
   - `AS` = Area (sub-region, e.g. "Central Ohio Area")
   - `MA` = Metro Area / other grouping
   Service bodies have `parent_id` forming a tree: ZF → RS → AS → MA.
3. **Call `GetSearchResults`** with `services={id}&recursive=1` to pull all meetings under a region (or a specific area).

Alternative fast path — if user gives a city/address, skip service bodies and go straight to geographic search:

```
?switcher=GetSearchResults&lat_val={lat}&long_val={lng}&geo_width_km=10&sort_results_by_distance=1
```

Geocode the address yourself (e.g. via Nominatim) rather than passing `StringSearchIsAnAddress=1` — the BMLT-side geocoder often fails or requires a Google API key server-side.

## Format rules (critical)

The `{format}` in the URL path determines which endpoints work:

| Format | Endpoints |
|--------|-----------|
| `json` | all except GetNAWSDump |
| `jsonp` | all except GetNAWSDump (add `&callback=name`) |
| `tsml` | **only** GetSearchResults |
| `csv` | **only** GetNAWSDump |

Getting this wrong returns HTTP 422. See [references/api-endpoints.md](references/api-endpoints.md).

## Data value cheatsheet

- **Weekdays** are 1-indexed **starting Sunday**: `1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat`. This trips people up — Monday is **2**, not 1.
- **Venue types**: `1=In-person, 2=Virtual, 3=Hybrid`.
- **Times**: 24-hour. Meetings span midnight by having `start_time` near 23:59 — handle carefully.
- **Negative IDs exclude**: `formats=-17` means "exclude format 17". Works for `meeting_ids`, `formats`, `services`, `venue_types`, `weekdays`, `root_server_ids`.
- **Array params**: PHP-style `?formats[]=1&formats[]=2` OR comma-list `?formats=1,2` — both work, prefer comma-list for brevity.

Full reference: [references/data-types.md](references/data-types.md).

## Common recipes

See [examples/common-queries.md](examples/common-queries.md) for ready-to-paste URLs covering:

- Meetings near me (geographic)
- Virtual-only meetings in a region
- Today's meetings in the next 2 hours
- All meetings for a specific service body (recursive)
- Changes to meetings this month
- Format lookup in a specific language

## Aggregator servers

**Default to querying a specific root server** — each region/area runs its own, and that's where the authoritative data for their meetings lives. The aggregator is a niche tool, not a shortcut.

The only known BMLT server running in **aggregator mode** is `https://aggregator.bmltenabled.org/main_server/`. It combines data from every entry in the `serverList.json`. **Only** reach for it when:

- The user explicitly wants a worldwide / cross-server search (e.g. "all virtual NA meetings globally right now").
- You need to compare meetings across multiple regions in a single query.
- The region is unknown and a geographic search spanning multiple roots is needed.

When you do use it:

- `GetSearchResults` **requires** at least one filter (`services`, `root_server_ids`, `meeting_ids`, geographic coords, or pagination) — otherwise returns `[]`.
- `root_server_ids` scopes down to specific underlying servers.

Any other root URL can be assumed to be non-aggregator (single-server mode). If you're unsure, call `GetServerInfo` and check `aggregator_mode_enabled`.

## Gotchas & failure modes

- **Empty `[]` response ≠ error.** BMLT often returns empty arrays for invalid params rather than HTTP errors. Re-check param names and values.
- **422 on format mismatch** — see format rules above.
- **`StringSearchIsAnAddress` 500s** without a server-side Google API key. Geocode client-side instead.
- **Auto-radius with negative `SearchStringRadius`** — a negative int means "find this many nearest meetings" not "distance in km". Useful but surprising.
- **Unpublished meetings hidden by default.** Add `advanced_published=0` (all) or `advanced_published=-1` (unpublished only) when needed.
- **`data_field_key` is your friend** for large regions — cuts response size by ~80% when you only need a few fields: `&data_field_key=meeting_name,start_time,weekday_tinyint,location_text,virtual_meeting_link`.

## Available resources in this skill

- [`references/api-endpoints.md`](references/api-endpoints.md) — all 9 endpoints, params, format support
- [`references/search-parameters.md`](references/search-parameters.md) — full GetSearchResults filter grammar
- [`references/sample-responses.md`](references/sample-responses.md) — real JSON shapes per endpoint — **read before formatting output**
- [`references/presenting-meetings.md`](references/presenting-meetings.md) — how to display results to a human (weekday/venue/time formatting, grouping)
- [`references/data-types.md`](references/data-types.md) — weekdays, venue types, field keys, language codes
- [`examples/common-queries.md`](examples/common-queries.md) — recipe book of ready-to-use URLs
- [`scripts/bmlt.sh`](scripts/bmlt.sh) — thin shell helper for fetching/formatting BMLT responses

## Semantic workshop

For interactive API exploration, point users at **https://semantic.bmlt.app** — official sandbox that builds and tests URLs against any root server.
