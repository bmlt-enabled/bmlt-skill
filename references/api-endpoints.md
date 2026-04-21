# BMLT Semantic API — Endpoints

All URLs follow: `{rootURL}client_interface/{format}/?switcher={endpoint}&...`

Example base: `https://bmlt.sezf.org/main_server/client_interface/json/?switcher=GetSearchResults`

## Format × endpoint compatibility

| Endpoint            | json | jsonp | tsml | csv |
|---------------------|:----:|:-----:|:----:|:---:|
| GetSearchResults    |  ✅  |  ✅   |  ✅  |  ❌ |
| GetFormats          |  ✅  |  ✅   |  ❌  |  ❌ |
| GetServiceBodies    |  ✅  |  ✅   |  ❌  |  ❌ |
| GetChanges          |  ✅  |  ✅   |  ❌  |  ❌ |
| GetFieldKeys        |  ✅  |  ✅   |  ❌  |  ❌ |
| GetFieldValues      |  ✅  |  ✅   |  ❌  |  ❌ |
| GetNAWSDump         |  ❌  |  ❌   |  ❌  |  ✅ |
| GetServerInfo       |  ✅  |  ✅   |  ❌  |  ❌ |
| GetCoverageArea     |  ✅  |  ✅   |  ❌  |  ❌ |

Mismatches return **422 Unprocessable Entity**.

---

## 1. GetSearchResults

Search for meetings. The workhorse — see [search-parameters.md](search-parameters.md) for the full parameter grammar.

Minimal call returns all published meetings on the server (can be huge — always filter).

---

## 2. GetFormats

Retrieve meeting format definitions (Open, Closed, Speaker, Beginner, etc.). Format IDs are **server-specific** — don't assume ID 17 means the same thing on two different servers.

| Param         | Type   | Notes |
|---------------|--------|-------|
| `lang_enum`   | string | `en`, `de`, `fr`, `es`, `it`, `pt`, `pl`, `sv`, `dk`, `fa` |
| `show_all`    | `0/1`  | `1` = include unused formats |
| `format_ids`  | csv    | Include (positive) or exclude (negative) specific IDs |
| `key_strings` | csv    | Filter by format key string (e.g. `O,C,BEG`) |

---

## 3. GetServiceBodies

List service bodies (the org-chart above meetings). Hierarchy via `parent_id`. `type` values:

- `ZF` — Zonal Forum (top; spans multiple regions)
- `RS` — Region
- `AS` — Area
- `MA` — Metro / Group of Areas
- `GS` — Group Service (rare)
- `LS` — Local Service (rare)

| Param       | Type  | Notes |
|-------------|-------|-------|
| `services`  | csv   | Include/exclude specific IDs (negative = exclude) |
| `recursive` | `0/1` | Include children of selected services |
| `parents`   | `0/1` | Include ancestors of selected services |

Each entry has: `id, name, description, type, parent_id, url, helpline, world_id, ...`

---

## 4. GetChanges

Meeting change history. Good for "what's new this month" audits.

| Param             | Type       | Notes |
|-------------------|------------|-------|
| `start_date`      | `YYYY-MM-DD` | Inclusive |
| `end_date`        | `YYYY-MM-DD` | Inclusive |
| `meeting_id`      | int        | Single meeting only |
| `service_body_id` | int        | Limit to a service body |

Fields include `change_type` (`comdef_change_type_c_comdef_meeting_change`, `...delete`, etc.), `change_date`, `user_id_bigint`, `before_object`, `after_object`.

---

## 5. GetFieldKeys

No parameters. Returns the list of meeting field keys available on this server (keys + human-readable descriptions). Server-specific — some servers add custom fields.

---

## 6. GetFieldValues

Distinct values for a single field. Useful for building dropdowns ("all towns with meetings", "all states"). Can be slow on large servers.

| Param              | Type   | Notes |
|--------------------|--------|-------|
| `meeting_key`      | string | **Required.** Field key (see GetFieldKeys). Common: `location_municipality`, `location_province`, `location_postal_code_1`. |
| `specific_formats` | csv    | Limit to meetings with these formats |
| `all_formats`      | `0/1`  | Include all formats (not just specific) |

---

## 7. GetNAWSDump

CSV export in NAWS (Narcotics Anonymous World Services) import format. **CSV format only.**

| Param   | Type | Notes |
|---------|------|-------|
| `sb_id` | int  | **Required.** Service body ID. |

Deleted meetings are included with `D` in the `Delete` column.

---

## 8. GetServerInfo

No parameters. Returns version, admin settings, enabled features, timezone, aggregator status, available languages.

Check `server_version` and `aggregator_mode_enabled` to adapt queries.

---

## 9. GetCoverageArea

No parameters. Returns bounding box of all meetings on the server: `{nw_corner_longitude, nw_corner_latitude, se_corner_longitude, se_corner_latitude}`. Useful for centering a map.
