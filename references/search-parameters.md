# GetSearchResults — Filter Grammar

Every parameter below is optional, but calling `GetSearchResults` with **no** filters on a large server returns thousands of meetings. Always filter.

## Include / Exclude pattern

Many filters accept **positive IDs to include** and **negative IDs to exclude**. Two array syntaxes work interchangeably:

```
?formats=1,2,-3                     # comma list (prefer this)
?formats[]=1&formats[]=2&formats[]=-3   # PHP bracket (verbose)
```

## Meeting ID

| Param         | Example         | Effect |
|---------------|-----------------|--------|
| `meeting_ids` | `123,456,-789`  | Include 123 and 456, exclude 789 |

## Day-of-week (1=Sun ... 7=Sat)

| Param      | Example       | Effect |
|------------|---------------|--------|
| `weekdays` | `2,3,4,5,6`   | Weekdays Mon–Fri |
| `weekdays` | `-1,-7`       | Exclude weekends |

## Venue type (1=In-person, 2=Virtual, 3=Hybrid)

| Param         | Example | Effect |
|---------------|---------|--------|
| `venue_types` | `2,3`   | Virtual + Hybrid only |
| `venue_types` | `-2`    | Exclude purely virtual |

## Formats

| Param                         | Example | Effect |
|-------------------------------|---------|--------|
| `formats`                     | `17,29` | Must have BOTH 17 AND 29 (default AND) |
| `formats_comparison_operator` | `OR`    | Switch to OR logic |
| `get_used_formats`            | `1`     | Append used-formats list to response |
| `get_formats_only`            | `1`     | Return ONLY the formats list (requires `get_used_formats=1`) |

## Service bodies (regions / areas)

| Param       | Example | Effect |
|-------------|---------|--------|
| `services`  | `5,8,-12` | Meetings in bodies 5 or 8, not 12 |
| `recursive` | `1`     | Walk down the hierarchy — crucial when picking a Region and wanting all its Areas |

## Text search

| Param                     | Example | Effect |
|---------------------------|---------|--------|
| `SearchString`            | `Monday%20Night` | Full-text across meeting_name, location_text, notes, etc. Always URL-encode. |
| `StringSearchIsAnAddress` | `1`     | Treat string as address (⚠️ often fails server-side — geocode yourself instead) |
| `SearchStringRadius`      | `10` or `-5` | Positive = miles/km; negative int = "find N nearest meetings" (auto-radius) |

## Time-of-day

All 24-hour. Combine H and M for precision.

| Param           | Example | Effect |
|-----------------|---------|--------|
| `StartsAfterH`  | `18`    | Starts at or after 18:00 |
| `StartsAfterM`  | `30`    | + 30 minutes ⇒ 18:30 |
| `StartsBeforeH` | `21`    | Starts before 21:00 |
| `EndsBeforeH`   | `22`    | Ends before 22:00 |

## Duration

| Param           | Effect |
|-----------------|--------|
| `MinDurationH` / `MinDurationM` | Minimum length |
| `MaxDurationH` / `MaxDurationM` | Maximum length |

## Geographic search

| Param                      | Example | Effect |
|----------------------------|---------|--------|
| `lat_val`                  | `47.6062` | Latitude (decimal degrees) |
| `long_val`                 | `-122.3321` | Longitude |
| `geo_width`                | `10`    | Radius in **miles** |
| `geo_width_km`             | `10`    | Radius in **kilometers** (only use one) |
| `sort_results_by_distance` | `1`     | Sort nearest first |

Pass negative `geo_width` / `geo_width_km` for auto-radius (find N nearest).

## Arbitrary field search

| Param              | Example              | Effect |
|--------------------|----------------------|--------|
| `meeting_key`      | `location_municipality` | Field name |
| `meeting_key_value`| `Columbus`           | Value |

Combine to search any field returned by GetFieldKeys.

## Response shaping

| Param             | Example                                  | Effect |
|-------------------|------------------------------------------|--------|
| `data_field_key`  | `meeting_name,start_time,weekday_tinyint` | Return only these fields. **Use this** — huge payload savings. |
| `sort_keys`       | `weekday_tinyint,start_time`             | Multi-key sort |
| `sort_key`        | `weekday` / `time` / `town` / `state` / `weekday_state` | Predefined aliases |
| `page_size`       | `50`                                     | Results per page |
| `page_num`        | `2`                                      | 1-indexed |

## Published status

| Param                | Effect |
|----------------------|--------|
| *(omitted)*          | Published only (default) |
| `advanced_published=0`  | All (published + unpublished) |
| `advanced_published=-1` | Unpublished only |

## Language

| Param       | Example | Effect |
|-------------|---------|--------|
| `lang_enum` | `de`    | Language for format names in response |

## Aggregator-mode additions

Only meaningful on the one known aggregator: **`https://aggregator.bmltenabled.org/main_server/`** (or any other server where `GetServerInfo` reports `aggregator_mode_enabled=1`).

| Param                       | Effect |
|-----------------------------|--------|
| `root_server_ids=1,2`       | Limit to specific underlying roots |
| `root_server_ids=-3`        | Exclude a root |

Aggregator mode **requires** at least one filter on `GetSearchResults` or the response is empty.
