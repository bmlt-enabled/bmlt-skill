# Sample Response Shapes

Real (trimmed) responses from `https://bmlt.sezf.org/main_server/`. Use these to know what fields come back without hitting `GetFieldKeys` first. Field strings are BMLT-wide; values are illustrative only.

> All numeric values come back as **strings** (`"1"`, not `1`). JSON booleans are rare — `published` is `"1"`/`"0"`, not `true`/`false`.

---

## GetSearchResults — single meeting

```json
{
  "id_bigint": "6071",
  "worldid_mixed": "G00297615",
  "service_body_bigint": "99",
  "service_body_name": "Coastal Carolina Area",
  "weekday_tinyint": "1",
  "venue_type": "1",
  "start_time": "07:00:00",
  "duration_time": "01:00:00",
  "time_zone": "America/New_York",
  "formats": "O,D,WC,NS",
  "format_shared_id_list": "8,17,33,37",
  "lang_enum": "en",
  "longitude": "-77.8870283",
  "latitude": "34.2148718",
  "published": "1",
  "root_server_uri": "https://bmlt.sezf.org/main_server",
  "meeting_name": "7-ISH Group",
  "location_text": "Winter Park Presbyterian Church",
  "location_street": "4501 Wrightsville Avenue",
  "location_municipality": "Wilmington",
  "location_sub_province": "New Hanover",
  "location_province": "NC",
  "location_postal_code_1": "28403",
  "location_nation": "US",
  "location_info": "Meets in the gymnasium.",
  "location_neighborhood": "",
  "location_city_subsection": "",
  "comments": "",
  "virtual_meeting_link": "",
  "virtual_meeting_additional_info": "",
  "phone_meeting_number": "",
  "bus_lines": "",
  "train_lines": "",
  "contact_name_1": "",
  "contact_phone_1": "",
  "contact_email_1": "",
  "distance_in_miles": "",
  "distance_in_km": ""
}
```

**Key field notes:**

- `weekday_tinyint` — 1=Sun…7=Sat.
- `venue_type` — 1=in-person, 2=virtual, 3=hybrid.
- `time_zone` — IANA tz of the **meeting's location**. Always present on modern servers.
- `formats` — comma-delimited *key strings* (human codes). Use for display.
- `format_shared_id_list` — comma-delimited *numeric IDs*. Use for cross-server format matching.
- `distance_in_miles` / `distance_in_km` — populated only when a geographic search was performed.
- Virtual meetings populate `virtual_meeting_link` and often leave physical address fields blank.
- Hybrid meetings have **both** a physical address **and** `virtual_meeting_link`.

---

## GetSearchResults — virtual / hybrid variants

**Virtual-only** (`venue_type: "2"`):

```json
{
  "meeting_name": "Just For Today Zoom",
  "weekday_tinyint": "4",
  "start_time": "20:00:00",
  "venue_type": "2",
  "time_zone": "America/New_York",
  "virtual_meeting_link": "https://zoom.us/j/1234567890",
  "virtual_meeting_additional_info": "Passcode: recovery",
  "phone_meeting_number": "+1-646-876-9923,,1234567890#",
  "location_text": "",
  "location_street": "",
  "location_municipality": "",
  "latitude": "0",
  "longitude": "0"
}
```

**Hybrid** (`venue_type: "3"`): same as in-person + `virtual_meeting_link` populated.

---

## GetServiceBodies — single entry

```json
{
  "id": "20",
  "parent_id": "42",
  "name": "South Florida Region",
  "description": "South Florida Region",
  "type": "RS",
  "url": "https://sfrna.net",
  "helpline": "844-623-5674",
  "world_id": "RG633"
}
```

- `parent_id` = `"0"` for top-level.
- `type` values: `ZF` / `RS` / `MA` / `AS` / `GS` / `LS`.

---

## GetFormats — single format

```json
{
  "key_string": "BEG",
  "name_string": "Beginners",
  "description_string": "This meeting is focused on the needs of new members of NA.",
  "lang": "en",
  "id": "1",
  "world_id": "BEG",
  "format_type_enum": "FC3",
  "root_server_uri": "https://bmlt.sezf.org/main_server"
}
```

- `id` is **server-local** — never reuse across servers.
- `world_id` is the NAWS-registered global code — **do** use this for cross-server matching.
- `key_string` is the short display code (appears in meeting `formats` field).
- `format_type_enum` — `FC1` (type), `FC2` (topic), `FC3` (audience), `FCL` (location).

---

## GetChanges — single change

```json
{
  "date_int": "1774996532",
  "date_string": "10:35 PM, 3/31/2026",
  "change_type": "comdef_change_type_change",
  "change_id": "78962",
  "meeting_id": "15459",
  "meeting_name": "5:30 Group",
  "user_id": "26",
  "user_name": "Gold Coast Area",
  "service_body_id": "23",
  "service_body_name": "Gold Coast Area",
  "meeting_exists": "1",
  "details": "The meeting was published.",
  "json_data": {
    "before": { "...full meeting snapshot..." },
    "after":  { "...full meeting snapshot..." }
  }
}
```

- `change_type` values: `comdef_change_type_change`, `comdef_change_type_new`, `comdef_change_type_delete`, etc.
- `json_data.before` / `json_data.after` contain full meeting snapshots — diff these for field-level changes.
- `meeting_exists: "0"` means the meeting was deleted.

---

## GetFieldKeys — single entry

```json
{
  "key": "meeting_name",
  "description": "Meeting Name"
}
```

Flat array. `description` is localized per `lang_enum` (server default).

---

## GetFieldValues — single entry

```json
{
  "location_municipality": "Columbus",
  "ids": "1234,5678,9012"
}
```

`ids` is a comma-delimited list of meetings with that value.

---

## GetServerInfo — top-level fields

```json
{
  "version": "4.2.0",
  "versionInt": "4002000",
  "langs": "da,de,el,en,es,fa,fr,it,pl,pt,ru,sv",
  "nativeLang": "en",
  "centerLongitude": "-79.793701171875",
  "centerLatitude": "36.065752051707",
  "centerZoom": "10",
  "defaultDuration": "1:00:00",
  "regionBias": "us",
  "distanceUnits": "mi",
  "semanticAdmin": "1",
  "aggregator_mode_enabled": "0",
  "available_keys": "id_bigint,service_body_bigint,weekday_tinyint,..."
}
```

- `aggregator_mode_enabled` — the thing to check when deciding whether filters are required.
- `distanceUnits` — `"mi"` or `"km"`; defaults for unqualified radius params.
- `available_keys` — the per-server list of field keys you can pass to `data_field_key` / `meeting_key`.

---

## GetCoverageArea

```json
{
  "nw_corner_longitude": "-85.6051",
  "nw_corner_latitude": "38.1234",
  "se_corner_longitude": "-75.2341",
  "se_corner_latitude": "24.5617"
}
```

Bounding box of every published meeting on the server.

---

## GetNAWSDump

CSV, not JSON. First row is headers:

```
Committee,CommitteeName,AddDate,AreaRegion,ParentName,Delete,...
```

The `Delete` column is `D` for deleted meetings, empty otherwise. Import directly into NAWS tools.
