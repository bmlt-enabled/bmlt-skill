# Presenting Meetings

How to format BMLT results for a human. Follow these rules unless the user explicitly asks for raw JSON.

## The 3 fields you must always show

For any single meeting:

1. **`meeting_name`** — e.g. "7-ISH Group"
2. **`location_text`** — e.g. "Winter Park Presbyterian Church" (or "🌐 Online" if virtual)
3. **`start_time` + weekday** — e.g. "Sunday 7:00 AM"

Everything else is optional. Adding more detail is fine when listing a single meeting; when listing many, keep it to these three.

## Weekday integer → name

BMLT weekdays are **1=Sunday**, not ISO. Use this map:

| int | full        | short |
|:---:|-------------|-------|
| 1   | Sunday      | Sun   |
| 2   | Monday      | Mon   |
| 3   | Tuesday     | Tue   |
| 4   | Wednesday   | Wed   |
| 5   | Thursday    | Thu   |
| 6   | Friday      | Fri   |
| 7   | Saturday    | Sat   |

## Venue type → label

| value | label              | emoji (optional) |
|:-----:|--------------------|:----------------:|
| 1     | In-person          | 📍               |
| 2     | Virtual            | 🌐               |
| 3     | Hybrid             | 🔀               |

Only use emoji if the user seems to want rich formatting — skip in plain-text or terminal contexts.

## Time formatting

- `start_time` arrives as `"HH:MM:SS"` in 24-hour. Strip seconds and convert to the meeting's locale convention:
  - US servers (`regionBias: "us"` from GetServerInfo) → 12-hour: `"07:00:00"` → `"7:00 AM"`.
  - European servers → 24-hour: `"19:30:00"` → `"19:30"`.
- **Time is in the meeting's local timezone** (`time_zone` field, e.g. `"America/New_York"`). Do not silently convert to the user's timezone — a 7 PM meeting in Los Angeles is 7 PM Pacific to the attendee, not 10 PM Eastern.
- If the user explicitly asks "what time is that in my timezone", **then** convert and show both: `"7:00 PM PT (10:00 PM ET for you)"`.

## Duration

`duration_time` is `"HH:MM:SS"`. Render as:
- `"01:00:00"` → `"1 hour"` or omit (it's the default)
- `"01:30:00"` → `"1.5 hours"` or `"90 min"`
- `"00:45:00"` → `"45 min"`

Usually only worth showing when non-default.

## Address

Build from fields in this order, skipping empties, comma-separated:

```
{location_text}, {location_street}, {location_municipality}, {location_province} {location_postal_code_1}
```

Example → `"Winter Park Presbyterian Church, 4501 Wrightsville Avenue, Wilmington, NC 28403"`

Include `location_info` as a parenthetical if present (e.g. `"(Meets in the gymnasium.)"`).

## Virtual / hybrid meetings

- `virtual_meeting_link` → show as a clickable link.
- `virtual_meeting_additional_info` → show inline (often passwords, instructions).
- `phone_meeting_number` → show separately; often formatted with DTMF codes like `+1-646-876-9923,,1234567890#`.
- For hybrid: show physical address **first**, then virtual details.

## Formats

The meeting `formats` field is a comma-list of format **key strings** (`"O,D,WC,NS"`). These are human-readable:

| key | meaning (common, English) |
|-----|---------------------------|
| `O`    | Open |
| `C`    | Closed |
| `BEG`  | Beginner |
| `D`    | Discussion |
| `SPKR` | Speaker |
| `LIT`  | Literature study |
| `STEP` | Step study |
| `TRAD` | Tradition study |
| `WC`   | Wheelchair accessible |
| `VM`   | Virtual |
| `HY`   | Hybrid |
| `M`    | Men |
| `W`    | Women |
| `LGBT` | LGBTQ+ |
| `NS`   | Non-smoking |
| `HP`   | Handicapped parking |

When showing a single meeting, decode these to full names (call `GetFormats` once and cache, then look up). When showing many, leave as short codes to save space.

## Grouping large lists

For >10 meetings, **group by weekday**:

```
Sunday
  7:00 AM  7-ISH Group            Winter Park Presbyterian Church
  9:30 AM  Serenity Now           Online 🌐
  6:00 PM  Daily Reprieve         First Baptist Church

Monday
  7:00 PM  Step Study             St. James UMC
  ...
```

Within a day, sort by `start_time` ascending.

For very long lists (>50), paginate or summarize: "found 73 meetings across 6 days — showing the next 10 starting now".

## Single-meeting display template

```
🕖 Sunday 7:00 AM — 1 hour
📌 7-ISH Group
📍 Winter Park Presbyterian Church
   4501 Wrightsville Avenue, Wilmington, NC 28403
   (Meets in the gymnasium.)
🏷  Open · Discussion · Wheelchair accessible · Non-smoking
```

Drop emoji rows in plain-text contexts.

## Multi-meeting summary template

```
Found 12 Tuesday meetings in the Ohio Region (virtual only):

  6:00 PM  Living Clean Discussion       zoom.us/j/111...
  7:00 PM  Just For Today                zoom.us/j/222...
  7:30 PM  Basic Text Study              zoom.us/j/333...
  8:00 PM  Speaker Meeting (LGBTQ+)      zoom.us/j/444...
  ...

All times are America/New_York.
```

Always state the timezone at the bottom if the list spans one tz, or alongside each meeting if mixed.

## What NOT to show by default

- `id_bigint`, `worldid_mixed`, `world_id`, `format_shared_id_list` — internal IDs, not user-facing.
- `published`, `admin_notes`, `email_contact` — admin metadata.
- `bus_lines`, `train_lines`, `location_sub_province` (county) — rarely populated, rarely relevant.
- Empty-string fields — don't render as `": "`. Skip entirely.
- Raw coordinates — show a map link or address, not `"lat: 34.21, lng: -77.89"`.

## Empty result handling

If `GetSearchResults` returns `[]`, don't say "no meetings found" flatly. Diagnose:

- On the aggregator? Did you include a required filter?
- Valid weekday integer (1–7, Sunday-first)?
- Is the service body ID correct and not excluded?
- Published-only (default) — try `advanced_published=0`?

Say what you tried and suggest the next step.
