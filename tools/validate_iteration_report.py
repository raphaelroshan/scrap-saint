import argparse
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--bundle', type=Path, required=True)
parser.add_argument('--require-scored', action='store_true')
args = parser.parse_args()
states = ['WORKSHOP_BLESSING_SELECT', 'RELAY_REPAIR_WAVE', 'SHOP_MERCY_RAIL_PATH', 'MERCY_RAIL_EVOLUTION', 'FOREMAN_ENGINE_PHASE_TWO', 'RESULTS_MEMORY_FRAGMENT']
for state in states:
    path = args.bundle / (state + '.png')
    assert path.is_file() and path.read_bytes()[:8] == b'\x89PNG\r\n\x1a\n', f'Missing/invalid capture {state}'
provenance = json.loads((args.bundle / 'provenance.json').read_text(encoding='utf-8-sig'))
for key in ['build', 'base_commit', 'godot', 'viewport', 'seed', 'timestamp_utc', 'capture_type', 'source_hashes', 'limitation', 'next_task']:
    assert key in provenance, f'Missing provenance {key}'
if args.require_scored:
    scores = json.loads((args.bundle / 'visual_review.json').read_text(encoding='utf-8-sig'))
    assert len(scores['rubric']) == 10
    assert all(isinstance(row['score'], int) and 1 <= row['score'] <= 5 and row['note'] for row in scores['rubric'])
    assert scores['limitation'] and scores['next_task']
print('PASS: rendered fixture evidence complete; this does not certify human game feel')
