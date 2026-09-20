import copy
import importlib.util
import json
from pathlib import Path
import unittest

root = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('validator', root / 'scripts/validate_content.py')
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


class ManifestTests(unittest.TestCase):
    def setUp(self):
        self.manifest = validator.load(root / 'content/slices/first_shift.json')
        self.data = {key: validator.load(path) for key, path in validator.FILES.items()}

    def gift(self, gift_id):
        return next(item for item in self.data['items']['items'] if item['id'] == gift_id)

    def test_enabled_slice(self):
        validator.validate_slice(self.manifest, self.data)

    def test_reject_missing_item(self):
        settings = self.manifest['weapons'].pop('weapon.nailer_small_mercies')
        self.manifest['weapons']['weapon.missing'] = settings
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_unavailable_recipe(self):
        self.manifest['evolutions'] = ['evolution.missing']
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_scope_growth(self):
        self.manifest['weapons']['weapon.unapproved_extra'] = copy.deepcopy(next(iter(self.manifest['weapons'].values())))
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_missing_rank_behavior(self):
        weapon = self.manifest['weapons']['weapon.nailer_small_mercies']
        weapon['rank_rules']['2'] = {
            'id': 'rank.nailer.empty', 'name': 'EMPTY', 'description': 'Only presentation.',
            'change_family': 'geometry',
        }
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_unknown_rank_field(self):
        self.manifest['weapons']['weapon.nailer_small_mercies']['rank_rules']['2']['unowned_magic'] = 1
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_duplicate_rank_id(self):
        duplicate = self.manifest['weapons']['weapon.nailer_small_mercies']['rank_rules']['2']['id']
        self.manifest['weapons']['weapon.bell_last_shift']['rank_rules']['2']['id'] = duplicate
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_orphan_evolution_rule(self):
        self.manifest['evolution_rules']['evolution.orphan'] = copy.deepcopy(next(iter(self.manifest['evolution_rules'].values())))
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_inexact_evolution_backlink(self):
        items = {item['id']: item for item in self.data['items']['items']}
        items['weapon.nailer_small_mercies']['evolution_ids'].append('evolution.great_toll')
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_unsupported_evolution_shape(self):
        self.manifest['evolution_rules']['evolution.mercy_rail']['shape'] = 'unimplemented_shape'
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_inexact_gift_manifest(self):
        self.manifest['gifts'].pop('gift.honest_scale')
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_extra_catalogue_gift(self):
        extra = copy.deepcopy(self.gift('gift.honest_scale'))
        extra['id'] = 'gift.unapproved'
        self.data['items']['items'].append(extra)
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_wrong_gift_slot_count(self):
        self.manifest['gift_slots'] = 3
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_unsupported_gift_effect(self):
        self.gift('gift.loose_spring')['effect'] = 'unimplemented_effect'
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_mismatched_gift_tradeoff(self):
        self.gift('gift.brass_fuse')['tradeoff'] = 'beam_silence_damage_multiplier'
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_non_numeric_gift_value(self):
        self.gift('gift.choir_filter')['effect_value'] = '120'
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_boolean_gift_value(self):
        self.gift('gift.honest_scale')['tradeoff_value'] = True
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_out_of_range_gift_value(self):
        self.gift('gift.spare_hand')['tradeoff_value'] = 1.2
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_missing_gift_duration(self):
        self.gift('gift.loose_spring').pop('duration_ticks')
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_incorrect_gift_offer_scope(self):
        self.gift('gift.loose_spring')['offer_scope'] = 'always'
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_unknown_compatible_weapon(self):
        self.gift('gift.choir_filter')['compatible_weapon_ids'] = ['weapon.missing']
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_incorrect_gift_compatibility(self):
        self.gift('gift.brass_fuse')['compatible_weapon_ids'] = ['weapon.hymn_coil']
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_duplicate_gift_compatibility(self):
        self.gift('gift.brass_fuse')['compatible_weapon_ids'].append('weapon.bell_last_shift')
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)

    def test_reject_unknown_choir_filter_support_family(self):
        self.manifest['gift_rules']['support_enemy_ids'].append('enemy.missing')
        with self.assertRaises(AssertionError):
            validator.validate_slice(self.manifest, self.data)


class ExpeditionGraphTests(unittest.TestCase):
    def setUp(self):
        chapter_path = root / 'content/chapter/first_chapter.json'
        self.chapter = json.loads(chapter_path.read_text(encoding='utf-8'))

    def assert_rejected(self, chapter):
        with self.assertRaises(AssertionError):
            validator.validate_expedition_graph(chapter)

    def test_accept_exact_edge_route_parity(self):
        validator.validate_expedition_graph(self.chapter)

    def test_reject_destination_mismatch(self):
        chapter = copy.deepcopy(self.chapter)
        chapter['expedition_map']['edges'][0]['to_site_id'] = 'site.rootworks_pump'
        self.assert_rejected(chapter)

    def test_reject_missing_edge(self):
        chapter = copy.deepcopy(self.chapter)
        chapter['expedition_map']['edges'].pop()
        self.assert_rejected(chapter)

    def test_reject_duplicate_edge(self):
        chapter = copy.deepcopy(self.chapter)
        chapter['expedition_map']['edges'].append(copy.deepcopy(chapter['expedition_map']['edges'][0]))
        self.assert_rejected(chapter)

    def test_reject_unknown_route_edge(self):
        chapter = copy.deepcopy(self.chapter)
        chapter['expedition_map']['edges'][0]['route_id'] = 'route.orphan'
        self.assert_rejected(chapter)

    def test_reject_orphan_map_site(self):
        chapter = copy.deepcopy(self.chapter)
        chapter['expedition_map']['sites'].append({
            'id': 'site.orphan', 'name': 'Orphan', 'position': [0.5, 0.5], 'tier': 1,
        })
        self.assert_rejected(chapter)

    def test_reject_duplicate_authored_parent(self):
        chapter = copy.deepcopy(self.chapter)
        chapter['routes'][0]['from_sites'].append(chapter['routes'][0]['from_sites'][0])
        self.assert_rejected(chapter)

    def test_reject_missing_optional_map_preview(self):
        chapter = copy.deepcopy(self.chapter)
        chapter['routes'][0].pop('optional_preview')
        self.assert_rejected(chapter)

    def test_reject_imperative_optional_map_preview(self):
        chapter = copy.deepcopy(self.chapter)
        chapter['routes'][0]['optional_preview'] = 'Repair every relay to proceed.'
        self.assert_rejected(chapter)

    def test_reject_incomplete_origin_site_clear_memory(self):
        chapter = copy.deepcopy(self.chapter)
        chapter['expedition_map']['origin_preview']['clear_memory'].pop('conclusion')
        self.assert_rejected(chapter)


if __name__ == '__main__':
    unittest.main()
