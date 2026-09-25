"""Recheck the audit's local links, preserved pack and capture provenance."""
from pathlib import Path
import hashlib
import json
import re
import subprocess

root = Path(__file__).resolve().parents[3]
files = [
    'AGENTS.md', 'README.md', 'roadmap.md', 'design/gameplay_contract.md',
    'docs/asset_provenance.md', 'docs/first_vertical_slice.md',
    'docs/runtime_status.md', 'docs/CHANGELOG.md', 'docs/agent_memory.md',
    'docs/agent_prompt_pack.md', 'docs/production_state.md', 'docs/qa_current.md',
    'docs/task_packets/prompt0_ownership_audit.md',
    'docs/task_packets/workshop_repair_readability.md',
    'docs/evidence/prompt0-audit/review.md',
]
checked = 0
for name in files:
    path = root / name
    for target in re.findall(r'\]\(([^)]+)\)', path.read_text(encoding='utf-8')):
        target = target.split('#')[0].strip('<>')
        if not target or '://' in target or target.startswith('mailto:'):
            continue
        assert (path.parent / target).exists(), (name, target)
        checked += 1
original = subprocess.check_output(
    ['git', 'show', '3464991:docs/ai_agent_prompt_pack.md'], cwd=root
)
assert (root / 'docs/ai_agent_prompt_pack.md').read_bytes().replace(
    b'\r\n', b'\n'
) == original.replace(b'\r\n', b'\n')
evidence = Path(__file__).parent
provenance = json.loads((evidence / 'provenance.json').read_text(encoding='utf-8'))
for entry in provenance['files']:
    assert hashlib.sha256((evidence / entry['file']).read_bytes()).hexdigest() == entry['sha256']
print(f'PASS: {checked} local links; original pack unchanged; 6 capture hashes match.')
