# Common BMLT Query Recipes

Replace `{ROOT}` with a root server URL ending in `/main_server/` (or similar — see the aggregator list). All URLs here use `json` format — swap to `jsonp` / `tsml` where applicable.

## 1. List every root server on earth

```
https://raw.githubusercontent.com/bmlt-enabled/aggregator/refs/heads/main/serverList.json
```

Returns `[{id, name, url}, ...]`. Cache per session.

## 2. Get service body hierarchy for a server

```
{ROOT}client_interface/json/?switcher=GetServiceBodies
```

Then filter client-side: `.filter(b => b.type === 'RS')` for regions.

## 3. All published meetings in a region (recursive)

```
{ROOT}client_interface/json/?switcher=GetSearchResults&services={regionId}&recursive=1
```

Add `&data_field_key=id_bigint,meeting_name,weekday_tinyint,start_time,location_text,location_municipality,venue_type` to keep payload small.

## 4. Virtual meetings only

```
{ROOT}client_interface/json/?switcher=GetSearchResults&services={regionId}&recursive=1&venue_types=2
```

## 5. Tonight's meetings still starting (after now, before bedtime)

For Tuesday 7pm–10pm filter:

```
{ROOT}client_interface/json/?switcher=GetSearchResults&services={regionId}&recursive=1&weekdays=3&StartsAfterH=19&StartsBeforeH=22
```

(Weekday 3 = Tuesday.)

## 6. Meetings within 10 km of a point

```
{ROOT}client_interface/json/?switcher=GetSearchResults&lat_val=47.6062&long_val=-122.3321&geo_width_km=10&sort_results_by_distance=1
```

Want the 20 nearest regardless of distance? Use auto-radius:

```
{ROOT}client_interface/json/?switcher=GetSearchResults&lat_val=47.6062&long_val=-122.3321&geo_width_km=-20&sort_results_by_distance=1
```

## 7. Meetings matching text

```
{ROOT}client_interface/json/?switcher=GetSearchResults&SearchString=serenity
```

URL-encode multi-word strings: `SearchString=sunday%20morning`.

## 8. All formats defined on a server (in German)

```
{ROOT}client_interface/json/?switcher=GetFormats&lang_enum=de
```

## 9. What changed in a region last month

```
{ROOT}client_interface/json/?switcher=GetChanges&start_date=2026-03-01&end_date=2026-03-31&service_body_id={regionId}
```

## 10. NAWS CSV export for a region

```
{ROOT}client_interface/csv/?switcher=GetNAWSDump&sb_id={regionId}
```

Note the `csv` in the path — required for this endpoint.

## 11. What distinct towns have meetings?

```
{ROOT}client_interface/json/?switcher=GetFieldValues&meeting_key=location_municipality
```

Returns `[{location_municipality, ids}, ...]`.

## 12. Is this server an aggregator?

```
{ROOT}client_interface/json/?switcher=GetServerInfo
```

Look for `aggregator_mode_enabled`. If `1`, `GetSearchResults` needs at least one filter.

In practice there is only **one** known aggregator — `https://aggregator.bmltenabled.org/main_server/` — which aggregates every server in the `serverList.json`. Example: all virtual meetings across every NA root server in the world:

```
https://aggregator.bmltenabled.org/main_server/client_interface/json/?switcher=GetSearchResults&venue_types=2&data_field_key=meeting_name,weekday_tinyint,start_time,virtual_meeting_link,root_server_uri
```

## 13. Open (non-closed) beginner-friendly speaker meetings Monday evenings

Two-pass approach — first discover format IDs on the server, then query:

```
# Step 1: get format IDs
{ROOT}client_interface/json/?switcher=GetFormats&key_strings=O,BEG,SPKR

# Step 2: search (imagine IDs came back as 1, 4, 29)
{ROOT}client_interface/json/?switcher=GetSearchResults&services={regionId}&recursive=1&weekdays=2&StartsAfterH=17&formats=1,4,29&formats_comparison_operator=AND
```

## 14. Shape-minimized meeting list (for a UI)

```
{ROOT}client_interface/json/?switcher=GetSearchResults&services={regionId}&recursive=1&data_field_key=id_bigint,meeting_name,weekday_tinyint,start_time,duration_time,location_text,location_municipality,latitude,longitude,venue_type,virtual_meeting_link,formats&sort_keys=weekday_tinyint,start_time
```

Drops ~40 fields you don't need. Payload shrinks dramatically on large regions.

## 15. Coverage bounding box (for centering a map)

```
{ROOT}client_interface/json/?switcher=GetCoverageArea
```
