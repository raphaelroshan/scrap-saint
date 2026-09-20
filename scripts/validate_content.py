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

EXPECTED_GIFT_IDS = {
    "gift.spare_hand",
    "gift.inspection_lens",
    "gift.black_ledger",
    "gift.loose_spring",
    "gift.honest_scale",
    "gift.choir_filter",
    "gift.brass_fuse",
}

# These identifiers are executable simulation/UI contracts, not free-form copy.
GIFT_CONTRACTS = {
    "gift.spare_hand": {
        "effect": "optional_repair_progress_multiplier",
        "tradeoff": "movement_speed_multiplier_while_working",
        "offer_scope": "unfinished_repair",
        "compatible_weapon_ids": set(),
    },
    "gift.inspection_lens": {
        "effect": "reveal_major_property_and_priority_target",
        "tradeoff": "ordinary_scrap_pickup_tax",
        "offer_scope": "always",
        "compatible_weapon_ids": set(),
    },
    "gift.black_ledger": {
        "effect": "dismantle_reveals_matching_shop_tag",
        "tradeoff": "dismantle_refund_fraction",
        "offer_scope": "always",
        "compatible_weapon_ids": set(),
    },
    "gift.loose_spring": {
        "effect": "repair_completion_movement_burst",
        "tradeoff": "once_per_repair_source",
        "offer_scope": "unfinished_repair",
        "compatible_weapon_ids": set(),
    },
    "gift.honest_scale": {
        "effect": "shop_post_purchase_preview",
        "tradeoff": "no_direct_combat_effect",
        "offer_scope": "always",
        "compatible_weapon_ids": set(),
    },
    "gift.choir_filter": {
        "effect": "quiet_support_recovery_lockout",
        "tradeoff": "beam_silence_damage_multiplier",
        "offer_scope": "compatible_weapon",
        "compatible_weapon_ids": {"weapon.hymn_coil"},
    },
    "gift.brass_fuse": {
        "effect": "first_bell_stagger_marks",
        "tradeoff": "bell_cooldown_multiplier",
        "offer_scope": "compatible_weapon",
        "compatible_weapon_ids": {"weapon.bell_last_shift"},
    },
}


def is_number(value: object) -> bool:
    """JSON number check which deliberately rejects booleans."""
    return type(value) in (int, float)


def validate_gifts(manifest: dict, item_entries: list[dict]) -> None:
    """Validate the complete P16 Gift catalogue and its executable metadata."""
    enabled_gifts = manifest.get("gifts", {})
    assert isinstance(enabled_gifts, dict), "slice gifts must be an object keyed by stable id"
    assert set(enabled_gifts) == EXPECTED_GIFT_IDS, "P16 slice must enable exactly the seven approved Gifts"
    assert type(manifest.get("gift_slots")) is int and manifest["gift_slots"] == 2, "P16 slice needs exactly two Gift slots"

    catalogue_gifts = [entry for entry in item_entries if entry.get("kind") == "gift"]
    catalogue_gift_ids = unique_ids(catalogue_gifts, "Gift catalogue")
    assert catalogue_gift_ids == EXPECTED_GIFT_IDS, "Gift catalogue must contain exactly the seven approved Gifts"
    gifts_by_id = {entry["id"]: entry for entry in catalogue_gifts}
    enabled_weapon_ids = set(manifest.get("weapons", {}))
    support_enemy_ids = manifest.get("gift_rules", {}).get("support_enemy_ids", [])
    assert set(support_enemy_ids) == {"enemy.choir_drone", "enemy.rust_pilgrim"}, "Choir Filter support families must remain explicit"
    assert len(support_enemy_ids) == len(set(support_enemy_ids)), "Choir Filter support families must be unique"
    assert set(support_enemy_ids) <= set(manifest.get("enemies", {})), "Choir Filter references an unavailable enemy"
    tick_rate = manifest.get("tick_rate")
    assert type(tick_rate) is int and tick_rate > 0, "tick_rate must be a positive integer"

    required_fields = {
        "name", "description", "tags", "cost_scrap", "effect", "effect_value",
        "tradeoff", "tradeoff_value", "offer_scope", "compatible_weapon_ids", "stack_rule",
    }
    for gift_id in sorted(EXPECTED_GIFT_IDS):
        gift = gifts_by_id[gift_id]
        settings = enabled_gifts[gift_id]
        contract = GIFT_CONTRACTS[gift_id]
        assert required_fields <= set(gift), f"{gift_id}: missing fields {required_fields - set(gift)}"
        assert isinstance(gift["name"], str) and gift["name"], f"{gift_id}: name must be non-empty text"
        assert isinstance(gift["description"], str) and gift["description"], f"{gift_id}: description must be non-empty text"
        assert isinstance(settings, dict), f"{gift_id}: manifest settings must be an object"
        assert isinstance(settings.get("short"), str) and settings["short"], f"{gift_id}: missing short label"
        assert isinstance(settings.get("description"), str) and settings["description"], f"{gift_id}: missing playable description"
        assert type(gift["cost_scrap"]) is int and gift["cost_scrap"] > 0, f"{gift_id}: cost_scrap must be a positive integer"
        assert isinstance(gift["tags"], list) and gift["tags"], f"{gift_id}: tags must be a non-empty array"
        assert all(isinstance(tag, str) and tag for tag in gift["tags"]), f"{gift_id}: tags must be non-empty strings"
        assert len(gift["tags"]) == len(set(gift["tags"])), f"{gift_id}: tags must be unique"
        assert gift["stack_rule"] == "unique", f"{gift_id}: unsupported stack rule"
        assert gift["effect"] == contract["effect"], f"{gift_id}: unsupported effect id {gift['effect']}"
        assert gift["tradeoff"] == contract["tradeoff"], f"{gift_id}: unsupported tradeoff id {gift['tradeoff']}"
        assert gift["offer_scope"] == contract["offer_scope"], f"{gift_id}: incorrect offer scope"
        assert is_number(gift["effect_value"]), f"{gift_id}: effect_value must be numeric"
        assert is_number(gift["tradeoff_value"]), f"{gift_id}: tradeoff_value must be numeric"

        compatible_ids = gift["compatible_weapon_ids"]
        assert isinstance(compatible_ids, list), f"{gift_id}: compatible_weapon_ids must be an array"
        assert all(isinstance(item_id, str) and item_id for item_id in compatible_ids), f"{gift_id}: compatible weapon ids must be non-empty strings"
        assert len(compatible_ids) == len(set(compatible_ids)), f"{gift_id}: duplicate compatible weapon id"
        assert set(compatible_ids) <= enabled_weapon_ids, f"{gift_id}: compatible weapon is not enabled"
        assert set(compatible_ids) == contract["compatible_weapon_ids"], f"{gift_id}: incorrect weapon compatibility"

        effect_value = gift["effect_value"]
        tradeoff_value = gift["tradeoff_value"]
        if gift_id == "gift.spare_hand":
            assert 1.0 < effect_value <= 2.0 and 0.0 < tradeoff_value < 1.0, f"{gift_id}: multipliers outside supported range"
        elif gift_id == "gift.inspection_lens":
            assert effect_value == 1 and 0.0 < tradeoff_value < 1.0, f"{gift_id}: flag/tax values outside supported range"
        elif gift_id == "gift.black_ledger":
            sell_fraction = manifest.get("economy", {}).get("sell_fraction")
            assert is_number(sell_fraction) and effect_value == 1, f"{gift_id}: reveal flag or economy sell fraction is invalid"
            assert 0.0 < tradeoff_value < sell_fraction, f"{gift_id}: reduced refund must remain below ordinary sale value"
        elif gift_id == "gift.loose_spring":
            duration_ticks = gift.get("duration_ticks")
            assert type(duration_ticks) is int and 0 < duration_ticks <= tick_rate * 10, f"{gift_id}: duration_ticks outside supported range"
            assert 1.0 < effect_value <= 2.0 and tradeoff_value == 1, f"{gift_id}: burst/once-per-source values outside supported range"
        elif gift_id == "gift.honest_scale":
            assert effect_value == 1 and tradeoff_value == 1, f"{gift_id}: preview/no-combat flags must be enabled"
        elif gift_id == "gift.choir_filter":
            assert type(effect_value) is int and 0 < effect_value <= tick_rate * 10, f"{gift_id}: lockout ticks outside supported range"
            assert 0.0 < tradeoff_value < 1.0, f"{gift_id}: damage multiplier outside supported range"
        elif gift_id == "gift.brass_fuse":
            assert type(effect_value) is int and 0 < effect_value <= tick_rate * 10, f"{gift_id}: mark ticks outside supported range"
            assert 1.0 < tradeoff_value <= 2.0, f"{gift_id}: cooldown multiplier outside supported range"

        if gift_id != "gift.loose_spring":
            assert "duration_ticks" not in gift, f"{gift_id}: unsupported duration_ticks field"


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


def validate_expedition_graph(chapter: dict) -> None:
    """Require the rendered map and route command graph to describe one graph."""
    routes = chapter.get("routes", [])
    route_ids = unique_ids(routes, "chapter routes")
    routes_by_id = {route["id"]: route for route in routes}
    expedition_map = chapter.get("expedition_map", {})
    origin_site_id = expedition_map.get("origin_site_id")
    map_sites = expedition_map.get("sites", [])
    map_site_ids = unique_ids(map_sites, "expedition map sites")

    assert origin_site_id in map_site_ids, "expedition map origin must reference a map site"
    route_site_ids = [route.get("site_id") for route in routes]
    assert all(isinstance(site_id, str) and site_id for site_id in route_site_ids), "every route needs a destination site"
    assert len(route_site_ids) == len(set(route_site_ids)), "chapter routes must have unique destination sites"
    assert map_site_ids == {origin_site_id, *route_site_ids}, "expedition map contains an orphan or missing route site"
    origin_preview = expedition_map.get("origin_preview", {})
    for field in ("experience", "threat_preview", "optional_preview", "boss"):
        assert isinstance(origin_preview.get(field), str) and origin_preview[field], f"origin preview missing {field}"
    assert origin_preview["optional_preview"].startswith("Optional"), "origin preview must identify optional work"
    assert origin_preview.get("wave_count", 0) > 0 and origin_preview.get("wave_ticks", 0) > 0, "origin preview needs duration data"

    expected_edges: set[tuple[str, str, str]] = set()
    expected_pairs: set[tuple[str, str]] = set()
    for route in routes:
        for field in ("description", "threat_preview", "optional_preview"):
            assert isinstance(route.get(field), str) and route[field], f"{route['id']}: missing map preview {field}"
        assert route["optional_preview"].startswith("Optional"), f"{route['id']}: map preview must identify optional work"
        assert route.get("wave_count", 0) > 0 and route.get("wave_ticks", 0) > 0, f"{route['id']}: map preview needs duration data"
        assert 0 < route.get("arrival_repair_floor", 0) <= 1, f"{route['id']}: invalid arrival floor"
        from_sites = route.get("from_sites", [])
        assert from_sites, f"{route['id']}: missing graph parent"
        assert len(from_sites) == len(set(from_sites)), f"{route['id']}: duplicate graph parent"
        for from_site_id in from_sites:
            assert from_site_id in map_site_ids, f"{route['id']}: unknown graph parent {from_site_id}"
            pair = (from_site_id, route["id"])
            assert pair not in expected_pairs, f"{route['id']}: duplicate authored graph pair {from_site_id}"
            expected_pairs.add(pair)
            expected_edges.add((from_site_id, route["site_id"], route["id"]))

    edges = expedition_map.get("edges", [])
    actual_edges: set[tuple[str, str, str]] = set()
    actual_pairs: set[tuple[str, str]] = set()
    for edge in edges:
        source = edge.get("from_site_id")
        destination = edge.get("to_site_id")
        route_id = edge.get("route_id")
        assert source in map_site_ids and destination in map_site_ids, "expedition map edge references an unknown site"
        assert route_id in route_ids, f"expedition map edge references unknown route {route_id}"
        route = routes_by_id[route_id]
        assert source in route["from_sites"], f"{route_id}: map edge source is not an authored graph parent"
        assert destination == route["site_id"], f"{route_id}: map edge destination does not match route site_id"
        edge_key = (source, destination, route_id)
        edge_pair = (source, route_id)
        assert edge_key not in actual_edges, "expedition map edges must be unique"
        assert edge_pair not in actual_pairs, f"{route_id}: multiple map edges for authored parent {source}"
        actual_edges.add(edge_key)
        actual_pairs.add(edge_pair)

    assert actual_edges == expected_edges, "expedition map edges must exactly match authored route from_sites"


def validate_slice(manifest: dict, data: dict) -> None:
    items = {entry['id']: entry for entry in data['items']['items']}
    enemies = {entry['id'] for entry in data['enemies']['enemies']}
    bosses = {entry['id'] for entry in data['bosses']['bosses']}
    blessings = {entry['id'] for entry in data['blessings']['blessings']}
    evolutions = {entry['id']: entry for entry in data['items']['evolutions']}
    assert len(manifest['weapons']) == 10, 'P14 slice must enable ten role-distinct weapons'
    assert len(manifest['catalysts']) == 8, 'P15 slice must enable eight recipe-supporting catalysts'
    validate_gifts(manifest, data['items']['items'])
    assert len(manifest['enemies']) == 6, 'slice must enable six ordinary enemies'
    assert len(manifest['blessings']) == 4 and len(set(manifest['blessings'])) == 4
    assert set(manifest['blessings']) <= blessings
    assert manifest['elite'] in enemies and manifest['boss'] in bosses
    assert set(manifest['enemies']) <= enemies
    assert len(manifest['evolutions']) == 10, 'P15 slice must expose ten meaningful Evolutions'
    for kind in ('weapons', 'catalysts', 'gifts'):
        for item_id, settings in manifest[kind].items():
            assert item_id in items, f'unknown enabled item {item_id}'
            assert items[item_id]['kind'] == kind[:-1]
            assert settings.get('description'), f'missing playable description {item_id}'
    for item_id, settings in manifest['weapons'].items():
        for field in ('target_rule', 'role', 'weakness', 'counter_families'):
            assert settings.get(field), f'missing weapon role contract {item_id}.{field}'
    rank_multipliers = manifest.get('rank_damage_multipliers', [])
    assert rank_multipliers == [1.0, 1.6, 2.2], 'Rank I-III damage multipliers must remain explicit content'
    rank_behavior_ids: set[str] = set()
    rank_metadata = {'id', 'name', 'description', 'change_family'}
    rank_change_families = {'geometry', 'targeting', 'cadence', 'control', 'repair', 'resource'}
    rank_operational_fields = {
        'pierce_targets', 'mark_counter_ticks', 'width', 'control_ticks', 'push_distance',
        'orbit_contacts', 'range', 'target_count', 'seeking_motes', 'mote_seek_speed',
        'bind_ticks', 'pull_distance', 'cancel_strikes', 'quiet_ticks', 'cooldown',
        'slow_ticks', 'scrap_every', 'repair_progress', 'saint_repair',
    }
    for item_id, settings in manifest['weapons'].items():
        rank_rules = settings.get('rank_rules', {})
        assert set(rank_rules) == {'2', '3'}, f'{item_id}: needs explicit Rank II and Rank III rules'
        for rank in ('2', '3'):
            rule = rank_rules[rank]
            assert all(rule.get(field) for field in rank_metadata), f'{item_id} Rank {rank}: incomplete authored identity'
            assert rule['change_family'] in rank_change_families, f"{item_id} Rank {rank}: unsupported change family {rule['change_family']}"
            assert rule['id'] not in rank_behavior_ids, f"duplicate rank behavior id {rule['id']}"
            rank_behavior_ids.add(rule['id'])
            operational_fields = set(rule) - rank_metadata
            assert operational_fields, f'{item_id} Rank {rank}: needs behavior beyond damage scaling'
            assert operational_fields <= rank_operational_fields, f'{item_id} Rank {rank}: unsupported behavior fields {operational_fields - rank_operational_fields}'
    enabled_evolutions = set(manifest['evolutions'])
    assert enabled_evolutions == set(evolutions), 'enabled Evolution recipes must exactly match the item catalogue'
    evolution_rules = manifest.get('evolution_rules', {})
    assert enabled_evolutions == set(evolution_rules), 'enabled Evolutions and simulation rules must have exact parity'
    recipe_bases = {recipe['base_item_id'] for recipe in evolutions.values()}
    assert recipe_bases == set(manifest['weapons']), 'every enabled weapon needs exactly one Evolution recipe'
    supported_evolution_shapes = {
        'rail', 'radial', 'ashen_censer', 'long_hand', 'repair_halo', 'funeral_shots',
        'sermon', 'benediction', 'parade', 'lattice',
    }
    supported_copy_behaviors = {
        'pierce_line', 'displace', 'slow_cycles', 'pull', 'repair_on_contact',
        'seeking_volley', 'quiet_weapons', 'cluster_blast', 'redirect',
    }
    for recipe_id in manifest['evolutions']:
        recipe = evolutions[recipe_id]
        assert recipe['base_item_id'] in manifest['weapons']
        assert recipe['required_catalyst_id'] in manifest['catalysts']
        assert recipe_id in items[recipe['base_item_id']].get('evolution_ids', []), f'{recipe_id}: base does not advertise recipe'
        assert recipe_id in items[recipe['required_catalyst_id']].get('compatible_evolution_ids', []), f'{recipe_id}: catalyst does not advertise recipe'
        rule = evolution_rules[recipe_id]
        for field in ('shape', 'short', 'damage', 'cooldown', 'range', 'width'):
            assert rule.get(field) not in (None, ''), f'{recipe_id}: incomplete simulation rule {field}'
        assert rule['shape'] in supported_evolution_shapes, f"{recipe_id}: unsupported shape {rule['shape']}"
        copy = rule.get('archivist_copy', {})
        assert copy.get('shape') and copy.get('behavior'), f'{recipe_id}: missing Archivist copy contract'
        assert copy['shape'] in supported_evolution_shapes, f"{recipe_id}: unsupported Archivist shape {copy['shape']}"
        assert copy['behavior'] in supported_copy_behaviors, f"{recipe_id}: unsupported Archivist behavior {copy['behavior']}"
    for item_id in manifest['weapons']:
        expected = {recipe_id for recipe_id, recipe in evolutions.items() if recipe['base_item_id'] == item_id}
        assert set(items[item_id].get('evolution_ids', [])) == expected, f'{item_id}: Evolution backlinks must exactly match recipes'
    for item_id in manifest['catalysts']:
        expected = {recipe_id for recipe_id, recipe in evolutions.items() if recipe['required_catalyst_id'] == item_id}
        assert set(items[item_id].get('compatible_evolution_ids', [])) == expected, f'{item_id}: Evolution backlinks must exactly match recipes'
    assert manifest['economy']['reroll_costs'] == [0, 2, 4]
    assert manifest['wave_ticks'] > 0 and manifest['tick_rate'] == 60
    assert 'confluences' not in manifest, 'Confluences remain disabled for P14.1'
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
    assert len(routes) == 5, "first chapter must contain two mid-sites and three terminal sites"
    route_ids = unique_ids(routes, "chapter routes")
    expected_routes = {"route.brass_choir", "route.rootworks", "route.pale_archive", "route.red_foundry", "route.null_assembly"}
    assert route_ids == expected_routes
    assert {"route.brass_choir", "route.rootworks"} <= route_ids, "first branch routes must remain stable"
    expedition_map = chapter.get("expedition_map", {})
    assert expedition_map.get("origin_site_id") == "site.collapsed_workshop"
    map_sites = expedition_map.get("sites", [])
    map_site_ids = unique_ids(map_sites, "expedition map sites")
    required_terminal_sites = {"site.pale_archive", "site.red_foundry", "site.null_assembly"}
    assert {"site.collapsed_workshop", "site.brass_choir_relay", "site.rootworks_pump"} | required_terminal_sites <= map_site_ids
    for site in map_sites:
        assert site.get("name") and len(site.get("position", [])) == 2 and site.get("tier") in (0, 1, 2)
        assert all(0.0 <= float(value) <= 1.0 for value in site["position"]), f"{site['id']}: map position outside normalized viewport"
    validate_expedition_graph(chapter)
    edges = expedition_map.get("edges", [])
    edge_keys = {(edge.get("from_site_id"), edge.get("to_site_id"), edge.get("route_id")) for edge in edges}
    required_edges = {
        ("site.collapsed_workshop", "site.brass_choir_relay", "route.brass_choir"),
        ("site.collapsed_workshop", "site.rootworks_pump", "route.rootworks"),
        ("site.brass_choir_relay", "site.pale_archive", "route.pale_archive"),
        ("site.brass_choir_relay", "site.red_foundry", "route.red_foundry"),
        ("site.rootworks_pump", "site.red_foundry", "route.red_foundry"),
        ("site.rootworks_pump", "site.null_assembly", "route.null_assembly"),
    }
    assert required_edges <= edge_keys, "expedition map must preserve the authored two-tier graph"
    bosses_by_id = {entry["id"]: entry for entry in data["bosses"]["bosses"]}
    boss_ids = set(bosses_by_id)
    site_ids: set[str] = set()
    for route in routes:
        for field in ("site_id", "name", "description", "news", "risk", "arena_path", "boss", "objective", "pressure", "travel", "memory"):
            assert route.get(field), f"{route['id']}: missing {field}"
        assert route["site_id"] not in site_ids, f"{route['id']}: duplicate site"
        site_ids.add(route["site_id"])
        assert route.get("from_sites"), f"{route['id']}: missing graph parent"
        assert all(next_id in route_ids for next_id in route.get("next_routes", [])), f"{route['id']}: unknown child route"
        assert bool(route.get("terminal", False)) == (len(route.get("next_routes", [])) == 0), f"{route['id']}: terminal/child mismatch"
        if route.get("terminal", False):
            assert route.get("assignment_id") and route.get("risk"), f"{route['id']}: terminal route needs map metadata"
            road_nodes = route.get("road_nodes", [])
            assert road_nodes, f"{route['id']}: terminal route needs authored road nodes"
            unique_ids(road_nodes, f"{route['id']} road nodes")
            choice_ids: set[str] = set()
            for road_node in road_nodes:
                assert road_node.get("kind") in {"encounter", "merchant", "service", "passage"}
                assert road_node.get("name") and road_node.get("news") and road_node.get("risk") and road_node.get("choices")
                assert any(int(choice.get("cost", 0)) == 0 for choice in road_node["choices"]), f"{road_node['id']}: needs a free continuation"
                for choice in road_node["choices"]:
                    assert choice.get("id") and choice["id"] not in choice_ids, f"{road_node['id']}: duplicate choice ID"
                    choice_ids.add(choice["id"])
                    assert choice.get("label") and choice.get("description") and choice.get("result") and choice.get("flag")
                    assert int(choice.get("cost", -1)) >= 0
                    assert isinstance(choice.get("scrap_delta"), int) and isinstance(choice.get("structure_delta"), (int, float))
        assert route["boss"] in boss_ids, f"{route['id']}: unknown boss"
        boss = bosses_by_id[route["boss"]]
        assert len(boss.get("phase_thresholds", [])) == 2, f"{boss['id']}: missing phase thresholds"
        assert len(boss.get("phases", [])) == 3, f"{boss['id']}: destination boss needs three phases"
        for phase in boss["phases"]:
            for field in ("id", "name", "rule", "interval", "warning_ticks", "hazard_pattern", "hazard_radius", "hazard_damage", "speed", "stop_distance"):
                assert phase.get(field) not in (None, ""), f"{boss['id']}.{phase.get('id', 'unknown')}: missing {field}"
            assert phase["interval"] > phase["warning_ticks"] > 0, f"{boss['id']}.{phase['id']}: warning must resolve before next cadence"
        assert set(route["enemy_pool"]) <= set(data["enemies_by_id"]), f"{route['id']}: unknown enemy"
        assert len(route["travel"]) >= 2, f"{route['id']}: travel needs more than one beat"
        road_nodes = route.get("road_nodes", [])
        assert road_nodes, f"{route['id']}: every route needs authored in-between areas"
        unique_ids(road_nodes, f"{route['id']} road nodes")
        choice_ids: set[str] = set()
        for node in road_nodes:
            assert node.get("kind") in {"encounter", "merchant", "service", "passage"}
            assert node.get("name") and node.get("news") and node.get("risk") and node.get("choices")
            assert any(int(choice.get("cost", 0)) == 0 for choice in node["choices"]), f"{node['id']}: needs a free continuation"
            for choice in node["choices"]:
                assert choice.get("id") and choice["id"] not in choice_ids, f"{node['id']}: duplicate choice ID"
                choice_ids.add(choice["id"])
                assert choice.get("label") and choice.get("description") and choice.get("result") and choice.get("flag")
                assert int(choice.get("cost", -1)) >= 0
                assert isinstance(choice.get("scrap_delta"), int) and isinstance(choice.get("structure_delta"), (int, float))
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
        assert objective.get("type") in {"CALIBRATE_NODES", "REPAIR_PUMP", "RECOVER_SEQUENCE", "VENT_ROTATION", "QUIET_REPAIR"}
        if objective["type"] == "VENT_ROTATION":
            assert objective.get("active_interval", 0) > 0
        unique_ids(objective["nodes"], f"{route['id']} objective nodes")
        arena_path = ROOT / route["arena_path"].removeprefix("res://")
        assert arena_path.is_file(), f"{route['id']}: missing arena"
        arena = json.loads(arena_path.read_text(encoding="utf-8"))
        assert arena.get("id") and arena.get("bounds") and arena.get("start") and arena.get("entries")
        if any("arena_anchor" in phase["hazard_pattern"] for phase in boss["phases"]):
            assert arena.get("boss_anchors"), f"{route['id']}: boss needs arena anchors"
        assert route["memory"].get("id") and route["memory"].get("text") and route["memory"].get("conclusion")

    by_id = {route["id"]: route for route in routes}
    assert set(by_id["route.brass_choir"]["next_routes"]) == {"route.pale_archive", "route.red_foundry"}
    assert set(by_id["route.rootworks"]["next_routes"]) == {"route.red_foundry", "route.null_assembly"}


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
