"""Inspect original image alpha and write draw regions. Never rewrites artwork."""
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
PACK = ROOT / 'assets/actors'
EXTENTS = {'scrap_mite':28, 'rivet_hound':40, 'choir_drone':48,
           'rust_pilgrim':48, 'forklift_brute':68, 'cinder_spitter':42}


def rect(bounds):
    return [bounds[0],bounds[1],bounds[2]-bounds[0],bounds[3]-bounds[1]]


def main():
    entries=[]
    for e in json.loads((PACK/'sources.json').read_text(encoding='utf-8')):
        path=ROOT/e['path'].removeprefix('res://')
        with Image.open(path) as im:
            assert im.mode=='RGBA', path
            alpha=im.getchannel('A')
            assert alpha.getextrema()==(0,255),path
            visible=alpha.point(lambda v:255 if v>16 else 0)
            if e['kind']=='repair':
                half=im.width//2
                # Inspect two cells; preserve original pixels and a common pivot.
                left=visible.crop((0,0,half,im.height)).getbbox()
                right=visible.crop((half,0,half*2,im.height)).getbbox()
                assert left and right,path
                shared=(min(left[0],right[0]),min(left[1],right[1]),max(left[2],right[2]),max(left[3],right[3]))
                assert 0 < shared[0] < shared[2] < half, (path,shared)
                regions={'broken':rect(shared),'restored':rect((shared[0]+half,shared[1],shared[2]+half,shared[3]))}
            else:
                regions={'base':rect(visible.getbbox())}
            entries.append({**e,'regions':regions,'size':list(im.size),'extent':64 if e['kind']=='repair' else EXTENTS[e['slug']], 'alpha_threshold':16,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
    (PACK/'manifest.json').write_text(json.dumps({'assets':entries},indent=2)+'\n',encoding='utf-8')
    print(f'Actor manifest: {len(entries)} assets, unchanged PNGs, matched repair cells')


if __name__=='__main__': main()
