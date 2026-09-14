import datetime
import hashlib
import json
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
data = {
    'build': '0.1.0',
    'base_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip(),
    'dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=root, text=True)),
    'godot': subprocess.check_output([sys.argv[1], '--version'], text=True).strip(),
    'viewport': [1280, 800], 'scaling': 'canvas_items', 'seed': 147,
    'timestamp_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'capture_type': 'rendered simulation fixtures; includes explicit setup budgets and Results fixture',
    'source_hashes': {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((root / 'game').glob('*')) if p.is_file()},
    'limitation': 'No human playtest or performance benchmark',
    'next_task': 'Human playtest of the shared arena and build feedback',
}
(root / 'artifacts/agent-iteration/provenance.json').write_text(json.dumps(data, indent=2), encoding='utf-8')
