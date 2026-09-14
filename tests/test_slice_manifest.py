import copy
import importlib.util
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


if __name__ == '__main__':
    unittest.main()
