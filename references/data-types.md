# BMLT Data Types & Constants

## Weekday integers (1-indexed, Sunday-first)

| Value | Day       |
|:-----:|-----------|
| 1     | Sunday    |
| 2     | Monday    |
| 3     | Tuesday   |
| 4     | Wednesday |
| 5     | Thursday  |
| 6     | Friday    |
| 7     | Saturday  |

**Common mistake:** assuming Monday = 1 (ISO standard). In BMLT, Sunday = 1.

## Venue types

| Value | Meaning | Notes |
|:-----:|---------|-------|
| 1     | In-person | Physical location only |
| 2     | Virtual   | Online only (Zoom, etc.) — expect `virtual_meeting_link` field |
| 3     | Hybrid    | Both |

## Service body types

| Code | Name           | Usage |
|------|----------------|-------|
| `ZF` | Zonal Forum    | Spans multiple regions (e.g. SEZF) |
| `RS` | Region         | Typical top-level a user picks |
| `MA` | Metro Area     | Grouping below region |
| `AS` | Area           | Collection of groups/meetings |
| `GS` | Group Service  | Rare; single group |
| `LS` | Local Service  | Rare |

Relationships via `parent_id`. A region (`RS`) will have `parent_id` pointing at a zonal forum (or `0`). Areas will point at their region.

## Language codes (`lang_enum`)

| Code | Language |
|------|----------|
| `en` | English |
| `de` | German |
| `dk` | Danish |
| `es` | Spanish |
| `fa` | Persian / Farsi |
| `fr` | French |
| `it` | Italian |
| `pl` | Polish |
| `pt` | Portuguese |
| `sv` | Swedish |

## Core meeting field keys

Returned by `GetFieldKeys` — these are the most commonly needed:

| Key | Content |
|-----|---------|
| `id_bigint` | Meeting ID |
| `meeting_name` | Meeting name |
| `weekday_tinyint` | Day 1–7 |
| `start_time` | `HH:MM:SS` |
| `duration_time` | `HH:MM:SS` |
| `venue_type` | 1/2/3 |
| `formats` | Comma-list of format IDs |
| `service_body_bigint` | Owning service body |
| `location_text` | Venue name |
| `location_street` | Street address |
| `location_municipality` | City / town |
| `location_province` | State / province |
| `location_postal_code_1` | ZIP / postcode |
| `location_sub_province` | County |
| `latitude` | Decimal |
| `longitude` | Decimal |
| `virtual_meeting_link` | URL (Zoom etc.) |
| `phone_meeting_number` | Phone-in number |
| `virtual_meeting_additional_info` | Passwords, notes |
| `comments` | Free-text notes |

Servers can define additional custom fields — always trust `GetFieldKeys` for the authoritative list.

## Time format notes

- Stored as `HH:MM:SS` in 24-hour form.
- `start_time` is local time in the meeting's location; BMLT does **not** convert to UTC. Timezone is implied by location.
- Meetings crossing midnight: `start_time` = `23:30:00`, `duration_time` = `01:30:00` → ends at `01:00:00` next day. Don't naively add.
- `weekday_tinyint` is the day the meeting **starts** — a 11pm Saturday meeting ending 1am Sunday has weekday=7.

## Format keys (common, English)

Format IDs are **server-specific**. Names are mostly consistent. Common `key_string` values:

| Key | Meaning |
|-----|---------|
| `O`   | Open (anyone welcome) |
| `C`   | Closed (NA members / prospective members only) |
| `BEG` | Beginner / Newcomer-focused |
| `DISC`| Discussion |
| `SPKR`| Speaker |
| `LIT` | Literature study |
| `STEP`| Step study |
| `TRAD`| Tradition study |
| `WC`  | Wheelchair accessible |
| `TC`  | Temporarily closed |
| `VM`  | Virtual meeting |
| `HY`  | Hybrid meeting |
| `M`   | Men only |
| `W`   | Women only |
| `LGBT`| LGBTQ+ focused |

Always call `GetFormats` per-server to learn actual IDs before filtering.

## Change types (`GetChanges`)

Values in the `change_type` field:

- `comdef_change_type_c_comdef_meeting_change` — edit
- `comdef_change_type_c_comdef_new_meeting` — created
- `comdef_change_type_c_comdef_delete_meeting` — deleted
