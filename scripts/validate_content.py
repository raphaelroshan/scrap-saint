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
    "frames": ROOT / "content/frames/first_chapter.json",
    "progression": ROOT / "content/progression/first_chapter.json",
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


def validate_slice(manifest: dict, data: dict) -> None:
    items = {entry['id']: entry for entry in data['items']['items']}
    enemies = {entry['id'] for entry in data['enemies']['enemies']}
    bosses = {entry['id'] for entry in data['bosses']['bosses']}
    blessings = {entry['id'] for entry in data['blessings']['blessings']}
    evolutions = {entry['id']: entry for entry in data['items']['evolutions']}
    assert len(manifest['weapons']) == 10, 'P14 slice must enable ten role-distinct weapons'
    assert len(manifest['catalysts']) == 4, 'slice must enable four useful catalysts'
    assert len(manifest['gifts']) == 3 and manifest['gift_slots'] == 2, 'P14 slice needs three Gifts and two slots'
    assert len(manifest['enemies']) == 6, 'slice must enable six ordinary enemies'
    assert len(manifest['blessings']) == 4 and len(set(manifest['blessings'])) == 4
    assert set(manifest['blessings']) <= blessings
    assert manifest['elite'] in enemies and manifest['boss'] in bosses
    assert set(manifest['enemies']) <= enemies
    assert len(manifest['evolutions']) == 2
    for kind in ('weapons', 'catalysts', 'gifts'):
        for item_id, settings in manifest[kind].items():
            assert item_id in items, f'unknown enabled item {item_id}'
            assert items[item_id]['kind'] == kind[:-1]
            assert settings.get('description'), f'missing playable description {item_id}'
    for gift_id in manifest['gifts']:
        gift = items[gift_id]
        for field in ('effect', 'effect_value', 'tradeoff', 'tradeoff_value', 'stack_rule'):
            assert gift.get(field) not in (None, ''), f'{gift_id}: missing {field}'
        assert gift['stack_rule'] == 'unique'
    for item_id, settings in manifest['weapons'].items():
        for field in ('target_rule', 'role', 'weakness', 'counter_families'):
            assert settings.get(field), f'missing weapon role contract {item_id}.{field}'
    for recipe_id in manifest['evolutions']:
        assert recipe_id in evolutions
        recipe = evolutions[recipe_id]
        assert recipe['base_item_id'] in manifest['weapons']
        assert recipe['required_catalyst_id'] in manifest['catalysts']
    assert manifest['economy']['reroll_costs'] == [0, 2, 4]
    assert manifest['wave_ticks'] > 0 and manifest['tick_rate'] == 60
    assert 'confluences' not in manifest, 'Confluences remain disabled for P14'
    assert len(manifest.get('wave_profiles', [])) == manifest['wave_count']
    for profile in manifest['wave_profiles']:
        assert profile.get('name') and profile.get('pressure') and profile.get('counters')
        assert profile.get('primary') in manifest['enemies']
        assert profile.get('support') and set(profile['support']) <= set(manifest['enemies'])
        assert profile.get('spawn_interval', 0) >= manifest['combat']['spawn_minimum']
    machines = manifest.get('optional_repairs', {}).get('machines', [])
    assert len(machines) == 3 and len({machine['id'] for machine in machines}) == 3
    for machine in machines:
        assert machine.get('name') and machine.get('description') and machine.get('reward')


def validate_chapter(data: dict) -> None:
    chapter_path = ROOT / "content/chapter/first_chapter.json"
    chapter = json.loads(chapter_path.read_text(encoding="utf-8"))
    routes = chapter.get("routes", [])
    assert len(routes) == 2, "first chapter must offer exactly two destination routes"
    route_ids = unique_ids(routes, "chapter routes")
    assert route_ids == {"route.brass_choir", "route.rootworks"}
    boss_ids = {entry["id"] for entry in data["bosses"]["bosses"]}
    site_ids: set[str] = set()
    for route in routes:
        for field in ("site_id", "name", "description", "news", "arena_path", "boss", "objective", "pressure", "travel", "memory"):
            assert route.get(field), f"{route['id']}: missing {field}"
        assert route["site_id"] not in site_ids, f"{route['id']}: duplicate site"
        site_ids.add(route["site_id"])
        assert route["boss"] in boss_ids, f"{route['id']}: unknown boss"
        assert set(route["enemy_pool"]) <= set(data["enemies_by_id"]), f"{route['id']}: unknown enemy"
        assert len(route["travel"]) >= 2, f"{route['id']}: travel needs more than one beat"
        assert 0.0 <= float(route.get("arrival_repair_floor", -1)) <= 1.0, f"{route['id']}: invalid arrival repair floor"
        profiles = route.get("wave_profiles", [])
        assert len(profiles) == route["wave_count"], f"{route['id']}: every destination wave needs an authored profile"
        for profile in profiles:
            assert profile.get("name") and profile.get("pressure") and profile.get("counters")
            assert profile.get("primary") in route["enemy_pool"]
            assert profile.get("support") and set(profile["support"]) <= set(route["enemy_pool"])
            assert profile.get("primary_weight", 0) > 0 and profile.get("spawn_interval", 0) > 0
        objective = route["objective"]
        assert objective.get("id") and objective.get("description") and objective.get("nodes")
        unique_ids(objective["nodes"], f"{route['id']} objective nodes")
        arena_path = ROOT / route["arena_path"].removeprefix("res://")
        assert arena_path.is_file(), f"{route['id']}: missing arena"
        arena = json.loads(arena_path.read_text(encoding="utf-8"))
        assert arena.get("id") and arena.get("bounds") and arena.get("start") and arena.get("entries")
        assert route["memory"].get("id") and route["memory"].get("text") and route["memory"].get("conclusion")


def validate_progression(data: dict) -> None:
    frames = data["frames"].get("frames", [])
    progression = data["progression"]
    frame_ids = unique_ids(frames, "frames")
    assert len(frames) == 3, "first chapter needs three role-distinct frames"
    for frame in frames:
        for field in ("name", "role", "structure", "speed", "starting_rule", "tradeoff", "description"):
            assert frame.get(field) not in (None, ""), f"{frame['id']}: missing {field}"
        assert frame["structure"] > 0 and frame["speed"] > 0

    blessing_ids = {entry["id"] for entry in data["blessings"]["blessings"]}
    recipe_ids = {entry["id"] for entry in data["items"]["evolutions"]}
    starts = progression.get("starting_unlocks", {})
    assert set(starts.get("frames", [])) <= frame_ids
    assert set(starts.get("blessings", [])) <= blessing_ids
    assert set(starts.get("recipes", [])) <= recipe_ids

    chapter = json.loads((ROOT / "content/chapter/first_chapter.json").read_text(encoding="utf-8"))
    route_sites = {route["site_id"] for route in chapter["routes"]}
    route_memories = {route["memory"]["id"] for route in chapter["routes"]}
    known_sites = route_sites | {"site.collapsed_workshop"}
    assert set(starts.get("sites", [])) <= known_sites
    memory_ids = unique_ids(progression.get("memories", []), "progression memories")
    assert route_memories <= memory_ids, "every destination memory must be durable progression content"
    for memory in progression.get("memories", []):
        assert memory.get("site_id") in known_sites and memory.get("text")

    reward_catalogues = {"frame": frame_ids, "blessing": blessing_ids, "site": known_sites, "recipe": recipe_ids}
    unique_ids(progression.get("unlocks", []), "progression unlocks")
    for unlock in progression.get("unlocks", []):
        assert unlock.get("condition") and unlock.get("reason")
        assert unlock.get("reward_type") in reward_catalogues
        assert unlock.get("reward_id") in reward_catalogues[unlock["reward_type"]]


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
    validate_slice(load(ROOT / 'content/slices/first_shift.json'), data)
    data["enemies_by_id"] = enemy_ids
    validate_chapter(data)
    validate_progression(data)

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

    print("PASS: Scrap Saint first-slice and first-chapter content contracts")
    print(f"  items={len(items)} evolutions={len(evolutions)} blessings={len(blessings)} frames={len(data['frames']['frames'])} enemies={len(enemies)} bosses={len(bosses)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
