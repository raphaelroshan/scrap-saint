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


if __name__ == '__main__':
    unittest.main()
