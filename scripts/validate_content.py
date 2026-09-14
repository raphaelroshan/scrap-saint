#!/usr/bin/env python3
"""Validate Scrap Saint's first-slice data contracts without external dependencies."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = {
    "items": ROOT / "content/items/first_slice.json",
    "blessings": ROOT / "content/blessings/first_slice.json",
    "enemies": ROOT / "content/enemies/first_slice.json",
    "bosses": ROOT / "content/bosses/first_slice.json",
}


def load(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict) or value.get("schema_version") != 1:
        raise AssertionError(f"{path}: expected schema_version 1 object")
    return value


def unique_ids(entries: list[dict], label: str) -> set[str]:
    ids = [entry.get("id") for entry in entries]
    if any(not isinstance(item, str) or not item for item in ids):
        raise AssertionError(f"{label}: every entry needs a stable id")
    if len(ids) != len(set(ids)):
        raise AssertionError(f"{label}: duplicate stable id")
    return set(ids)


def main() -> int:
    data = {key: load(path) for key, path in FILES.items()}
    items = data["items"].get("items", [])
    blessings = data["blessings"].get("blessings", [])
    enemies = data["enemies"].get("enemies", [])
    bosses = data["bosses"].get("bosses", [])
    evolutions = data["items"].get("evolutions", [])

    item_ids = unique_ids(items, "items")
    blessing_ids = unique_ids(blessings, "blessings")
    enemy_ids = unique_ids(enemies, "enemies")
    boss_ids = unique_ids(bosses, "bosses")
    evolution_ids = unique_ids(evolutions, "evolutions")

    if len(blessings) < 3:
        raise AssertionError("first slice needs at least three Blessings")
    if len(items) < 7:
        raise AssertionError("first slice needs at least seven item entries")
    if len(enemies) < 5:
        raise AssertionError("first slice needs at least five enemy entries")
    if len(bosses) < 1:
        raise AssertionError("first slice needs a boss")

    for blessing in blessings:
        for field in ("starting_guarantees", "shop_bias_tags", "unique_service_id", "fulfilment"):
            if not blessing.get(field):
                raise AssertionError(f"{blessing['id']}: missing {field}")
        for item_id in blessing["starting_guarantees"]:
            if item_id not in item_ids:
                raise AssertionError(f"{blessing['id']}: unknown starting item {item_id}")

    for evolution in evolutions:
        if evolution["base_item_id"] not in item_ids:
            raise AssertionError(f"{evolution['id']}: unknown base item")
        if evolution["required_catalyst_id"] not in item_ids:
            raise AssertionError(f"{evolution['id']}: unknown catalyst")
        if not evolution.get("result_geometry") or not evolution.get("result_effects"):
            raise AssertionError(f"{evolution['id']}: incomplete result contract")

    for item in items:
        for evolution_id in item.get("evolution_ids", []):
            if evolution_id not in evolution_ids:
                raise AssertionError(f"{item['id']}: unknown evolution {evolution_id}")

    for enemy in enemies:
        for field in ("role", "target_preference", "telegraph", "counter_families"):
            if not enemy.get(field):
                raise AssertionError(f"{enemy['id']}: missing {field}")

    for boss in bosses:
        for field in ("phases", "telegraph", "counter_families", "reward_choices"):
            if not boss.get(field):
                raise AssertionError(f"{boss['id']}: missing {field}")
        if len(boss["phases"]) < 2:
            raise AssertionError(f"{boss['id']}: boss needs at least two rule phases")

    print("PASS: Scrap Saint first-slice content contracts")
    print(f"  items={len(items)} evolutions={len(evolutions)} blessings={len(blessings)} enemies={len(enemies)} bosses={len(bosses)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
