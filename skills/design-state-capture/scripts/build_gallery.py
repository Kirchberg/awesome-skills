#!/usr/bin/env python3
"""Build an offline HTML gallery from a design-state capture manifest."""

from __future__ import annotations

import argparse
import html
import json
import os
import tempfile
import struct
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from urllib.parse import quote


PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


class ManifestError(ValueError):
    """An input manifest or referenced image is invalid."""


def _text(value: object, field: str, *, required: bool = True) -> str:
    if not isinstance(value, str) or (required and not value.strip()):
        requirement = "a nonempty string" if required else "a string"
        raise ManifestError(f"{field} must be {requirement}")
    return value


def _png_dimensions(path: Path) -> Tuple[int, int]:
    try:
        with path.open("rb") as stream:
            if stream.read(8) != PNG_SIGNATURE:
                raise ManifestError(f"image is not a PNG: {path}")
            length_data = stream.read(4)
            chunk_type = stream.read(4)
            if len(length_data) != 4 or len(chunk_type) != 4:
                raise ManifestError(f"PNG is truncated: {path}")
            length = struct.unpack(">I", length_data)[0]
            if chunk_type != b"IHDR" or length != 13:
                raise ManifestError(f"PNG has no valid IHDR: {path}")
            ihdr = stream.read(13)
            if len(ihdr) != 13:
                raise ManifestError(f"PNG IHDR is truncated: {path}")
            width, height = struct.unpack(">II", ihdr[:8])
            if width <= 0 or height <= 0:
                raise ManifestError(f"PNG dimensions must be positive: {path}")
            return width, height
    except OSError as exc:
        raise ManifestError(f"cannot read image {path}: {exc}") from exc


def load_cases(manifest_path: Path) -> Tuple[Dict[str, object], List[Dict[str, object]]]:
    try:
        with manifest_path.open(encoding="utf-8") as stream:
            manifest = json.load(stream)
    except (OSError, json.JSONDecodeError) as exc:
        raise ManifestError(f"cannot read manifest {manifest_path}: {exc}") from exc

    if not isinstance(manifest, dict):
        raise ManifestError("manifest must be a JSON object")
    title = _text(manifest.get("title"), "title")
    description = _text(manifest.get("description", ""), "description", required=False)
    raw_cases = manifest.get("cases")
    if not isinstance(raw_cases, list) or not raw_cases:
        raise ManifestError("cases must be a nonempty array")

    base = manifest_path.parent.resolve()
    seen_ids: set[str] = set()
    cases: list[dict[str, object]] = []
    for index, raw_case in enumerate(raw_cases, start=1):
        if not isinstance(raw_case, dict):
            raise ManifestError(f"case {index} must be an object")
        case_id = _text(raw_case.get("id"), f"case {index} id")
        if case_id in seen_ids:
            raise ManifestError(f"duplicate case id: {case_id}")
        seen_ids.add(case_id)
        case_title = _text(raw_case.get("title"), f"case {index} title")
        image = _text(raw_case.get("image"), f"case {index} image")
        if "\\" in image:
            raise ManifestError(f"case {index} image must use slash-separated relative paths")
        device_kind = _text(raw_case.get("device_kind"), f"case {index} device_kind")
        if device_kind not in {"phone", "tablet"}:
            raise ManifestError(f"case {index} device_kind must be phone or tablet")
        relative = Path(image)
        if relative.is_absolute():
            raise ManifestError(f"case {index} image must be relative to the manifest")
        resolved = (base / relative).resolve()
        try:
            resolved.relative_to(base)
        except ValueError as exc:
            raise ManifestError(f"case {index} image escapes the manifest directory") from exc
        if resolved.suffix.lower() != ".png" or not resolved.is_file():
            raise ManifestError(f"case {index} image must be an existing PNG: {image}")
        width, height = _png_dimensions(resolved)
        cases.append({
            "id": case_id,
            "title": case_title,
            "group": _text(raw_case.get("group", ""), f"case {index} group", required=False),
            "image": image,
            "device": _text(raw_case.get("device", ""), f"case {index} device", required=False),
            "device_kind": device_kind,
            "width": width,
            "height": height,
        })
    return {"title": title, "description": description}, cases


def build_html(metadata: Dict[str, object], cases: List[Dict[str, object]]) -> str:
    esc = lambda value: html.escape(str(value), quote=True)
    groups: Dict[str, List[Dict[str, object]]] = {}
    for case in cases:
        groups.setdefault(str(case["group"]).strip(), []).append(case)

    sections: list[str] = []
    for group, grouped_cases in groups.items():
        cards = []
        for case in grouped_cases:
            image_url = quote(str(case["image"]), safe="/")
            kind = str(case["device_kind"])
            device = f'<p class="device">{esc(case["device"])}</p>' if case["device"] else ""
            cards.append(
                f'<article class="card {kind}"><a href="{esc(image_url)}">'
                f'<img src="{esc(image_url)}" width="{case["width"]}" height="{case["height"]}" '
                f'alt="{esc(case["title"])}" loading="lazy"></a>'
                f'<h3>{esc(case["title"])}</h3>{device}</article>'
            )
        heading = f'<h2>{esc(group)}</h2>' if group != "" else ""
        grid_kind = " tablet-grid" if any(case["device_kind"] == "tablet" for case in grouped_cases) else ""
        sections.append(f'<section>{heading}<div class="grid{grid_kind}">{"".join(cards)}</div></section>')
    description = f'<p class="description">{esc(metadata["description"])}</p>' if metadata["description"] else ""
    return f'''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{esc(metadata["title"])}</title>
<style>
:root {{ color-scheme: light dark; font: 16px/1.4 system-ui, sans-serif; }}
body {{ margin: 0 auto; max-width: 1600px; padding: 2rem; background: Canvas; color: CanvasText; }}
h1 {{ margin: 0; }} .description {{ margin: .4rem 0 2rem; color: GrayText; }}
section {{ margin: 2rem 0; }} h2 {{ margin-bottom: 1rem; }}
.grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(min(100%, 280px), 320px)); gap: 1.25rem; justify-content: start; align-items: start; }}
.tablet-grid {{ grid-template-columns: repeat(auto-fill, minmax(min(100%, 280px), 480px)); }}
.card {{ width: 100%; max-width: 320px; min-width: 0; overflow-wrap: anywhere; }} .card.tablet {{ max-width: 480px; }}
.card a {{ display: block; border-radius: .5rem; overflow: hidden; background: color-mix(in srgb, CanvasText 8%, Canvas); }}
img {{ display: block; width: 100%; height: auto; }} h3 {{ margin: .65rem 0 0; font-size: 1rem; }} .device {{ margin: .2rem 0 0; color: GrayText; font-size: .9rem; }}
</style></head><body><header><h1>{esc(metadata["title"])}</h1>{description}</header>{"".join(sections)}</body></html>
'''


def write_gallery(output: Path, document: str, *, replace: bool) -> None:
    if output.is_symlink():
        raise ManifestError(f"output must not be a symlink: {output}")
    descriptor, temporary_name = tempfile.mkstemp(prefix=".gallery-", suffix=".html", dir=output.parent)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            stream.write(document)
            stream.flush()
            os.fsync(stream.fileno())
        if output.is_symlink():
            raise ManifestError(f"output must not be a symlink: {output}")
        if replace:
            os.replace(temporary, output)
        else:
            # Publish without overwriting a file created since the initial check.
            os.link(temporary, output)
    finally:
        temporary.unlink(missing_ok=True)


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cases_json", type=Path)
    parser.add_argument("--replace", action="store_true", help="replace an existing sibling index.html")
    args = parser.parse_args(argv)
    output = args.cases_json.resolve().parent / "index.html"
    if (output.exists() or output.is_symlink()) and not args.replace:
        print(f"error: output already exists: {output}; use --replace to regenerate", file=sys.stderr)
        return 2
    try:
        metadata, cases = load_cases(args.cases_json.resolve())
        document = build_html(metadata, cases)
        write_gallery(output, document, replace=args.replace)
    except ManifestError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    except OSError as exc:
        print(f"error: cannot write {output}: {exc}", file=sys.stderr)
        return 2
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
