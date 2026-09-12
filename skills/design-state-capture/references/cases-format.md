# cases.json Format

Place this file in the output folder alongside `index.html`. PNGs may be stored alongside it or in a `screenshots` subfolder. Paths are relative and must stay within the output folder.

```json
{
  "title": "Profile",
  "description": "Profile screen states",
  "cases": [
    {
      "id": "profile-loaded",
      "title": "Data loaded",
      "group": "Profile",
      "image": "screenshots/01-profile-loaded.png",
      "device": "Selected simulator name",
      "device_kind": "phone",
      "capture_method": "temporary-ui-model",
      "captured_at": "2026-09-11T12:00:00+03:00"
    }
  ]
}
```

`title` and a nonempty `cases` list are required; each capture must have a unique `id`, a clear `title`, an `image`, and a `device_kind` (`phone` or `tablet`). `description`, `group`, and `device` are optional. Groups appear in order of first occurrence; captures within a group follow their JSON order. Put different devices in separate groups with clear names.

Additional fields support verification and reproducibility and are not displayed in the gallery. Examples include `capture_method`, `captured_at`, `locale`, `theme`, and `notes`. Do not put secrets or complete API responses in them. List uncaptured states separately in the report instead of adding them as successful entries.

The generator checks paths, identifier uniqueness, and PNG headers. This does not verify which screen was captured: inspect each image separately.
