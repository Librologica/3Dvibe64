"""Mode 8 public host builder. Python stdlib + external 64tass only."""
import argparse, hashlib, json, os, re, shutil, subprocess
from pathlib import Path
from .contract import contract,require
from .navigation import simulate
from .walls import walls
from . import model

ROOT=Path(__file__).resolve().parents[2]
SOURCE=Path(__file__).resolve().parent
FAMILIES={'mono-opaque':'perimeter','mono-portals':'apertures','multi':'two-levels'}

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def load(p):
    def pairs(items):
        d={}
        for k,v in items:
            require(k not in d,'DUPLICATE_FIELD',k);d[k]=v
        return d
    return json.loads(Path(p).read_text(encoding='utf-8-sig'),object_pairs_hook=pairs)
def save(p,data):Path(p).write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
def labels(b):
    return {l.split()[2][1:]:int(l.split()[1],16) for l in (Path(b)/'labels.txt').read_text().splitlines()}
def emit(name,values):
    values=bytes(v&255 for v in values)
    return name+':\n'+''.join(' .byte '+','.join(f'${v:02x}' for v in values[i:i+16])+'\n' for i in range(0,len(values),16))
def replace(s,name,values):
    s,n=re.subn(r'(?m)^'+re.escape(name)+r':\n(?:[ \t]+\.byte[^\n]*\n)+',lambda m:emit(name,values),s)
    require(n==1,'SOURCE_TABLE',name);return s
def integers(v,n,field):
    require(isinstance(v,list) and len(v)==n and all(type(x)is int for x in v),'FORMAT',field+f' requires {n} integers')

def syntax(data):
    require(isinstance(data,dict) and set(data)=={'scene','navigation'},'DOCUMENT','requires exactly scene and navigation')
    s,nav=data['scene'],data['navigation']
    require(isinstance(s,dict) and isinstance(nav,dict),'FORMAT','scene/navigation must be objects')
    required={'schema','size','solid','floor','ceiling','initial','eyeHeight','doors','ramps'}
    require(required<=set(s),'MISSING_FIELD',str(sorted(required-set(s))))
    require(set(s)<=required|{'playerHeight','heightUnit','notes'},'UNKNOWN_FIELD',str(sorted(set(s)-required-{'playerHeight','heightUnit','notes'})))
    require(s['schema']=='3dvibe64-mode8-map-v1','SCHEMA','scene.schema')
    require(s.get('heightUnit','1/32 cell')=='1/32 cell','HEIGHT_UNIT','scene.heightUnit')
    if 'notes' in s:require(isinstance(s['notes'],str),'FORMAT','scene.notes must be a string')
    integers(s['size'],2,'scene.size')
    for k in ('solid','floor','ceiling'):integers(s[k],1024,'scene.'+k)
    integers(s['initial'],5,'scene.initial')
    require(type(s['eyeHeight'])is int and type(s.get('playerHeight',48))is int,'INTEGER','eyeHeight/playerHeight')
    require(isinstance(s['doors'],list) and isinstance(s['ramps'],list),'FORMAT','scene.doors/ramps must be arrays, not null')
    require(set(nav)=={'camera','nodes'},'NAV_FORMAT','navigation requires exactly camera and nodes')
    integers(nav['camera'],3,'navigation.camera')
    require(isinstance(nav['nodes'],list),'NAV_FORMAT','navigation.nodes must be an array')
    for i,v in enumerate(nav['nodes']):integers(v,2,f'navigation.nodes[{i}]')
    for i,r in enumerate(s['ramps']):
        require(isinstance(r,dict) and set(r)=={'marker','axis','origin','start','end','bottom','top'},'RAMP_FORMAT',f'scene.ramps[{i}]')
        require(r['axis']=='y' and all(type(r[k])is int for k in set(r)-{'axis'}),'RAMP_FORMAT',f'scene.ramps[{i}]')
    for i,d in enumerate(s['doors']):
        if isinstance(d,list):integers(d,4,f'scene.doors[{i}]')
        else:
            require(isinstance(d,dict) and set(d)=={'axis','plane','start','end','floor'},'DOOR_FORMAT',f'scene.doors[{i}]')
            require(d['axis'] in ('x','y') and all(type(d[k])is int for k in set(d)-{'axis'}),'DOOR_FORMAT',f'scene.doors[{i}]')

def validate(data,route=True):
    syntax(data)
    try:c=contract(data)
    except (AssertionError,KeyError,TypeError,IndexError,RecursionError) as e:raise ValueError('GEOMETRY: '+str(e)) from e
    family=FAMILIES[c['backend']]
    reference=load(SOURCE/'templates.json')[family]
    # Source templates retain camera initialization and qualified mono itineraries.
    require(data['scene']['initial']==reference['initial'],'TEMPLATE_CAMERA',family+' keeps the five initial camera values')
    if c['backend']!='multi':
        require(data['navigation']==reference['navigation'],'MONO_NAV',family+' keeps camera and nodes verbatim')
    if route:
        poses,states,blocked=simulate(data['scene'],data['navigation'],backend=c['backend'])
        require(not blocked,'AUTO_COLLISION',f'{blocked} blocked ticks in 30000; move the obstacle or restore supported route')
        lap=next((i for i,v in enumerate(states) if v['visits']>=len(data['navigation']['nodes'])),None)
        require(lap is not None,'AUTO_TOUR','no full waypoint lap in 30000 ticks')
        c.update(simulatedTicks=30000,blockedTicks=blocked,firstLapTick=lap)
    c.update(family=family,reason={'mono-opaque':'uniform floor 0, ceiling 128, no apertures or ramps',
        'mono-portals':'uniform floor 0, qualified separator and two static apertures',
        'multi':'ramps or multiple free-cell floor values; validated heightfield'}[c['backend']])
    return c

def build(scene,out,run='interactive',validate_only=False):
    data=load(scene);c=validate(data)
    print('Mode 8 backend:',c['backend'],'—',c['reason'],flush=True)
    if validate_only:
        print(json.dumps(c,indent=2));return c
    dest=Path(out).resolve()
    require(not dest.is_relative_to(ROOT),'OUTPUT_DIRECTORY','Mode 8 outputs must be outside the SDK tree')
    require(not dest.exists() or not any(dest.iterdir()),'OUTPUT_EXISTS','use a new empty output directory: '+str(dest))
    dest.mkdir(parents=True,exist_ok=True)
    template=SOURCE/'asm'/f'{c["family"]}-{run}.asm';s=template.read_text()
    geom=data['scene'];nav=data['navigation'];stats={}
    if c['backend']=='multi':
        p=model.preprocess(geom)
        for k in ('floor','ceiling','solid'):s=replace(s,k+'_map',geom[k])
        for i,values in enumerate(p['maps']):s=replace(s,'event_map_'+str(i),values)
        for i,k in enumerate(('event_floor','event_ceiling','event_riser','event_header','event_flags')):
            s=replace(s,k,[e[i] for e in p['events']]+[0]*(256-len(p['events'])))
        for i,k in enumerate(('key_plane','key_alt')):s=replace(s,k,[e[i] for e in p['keys']]+[0]*(256-len(p['keys'])))
        if run=='auto':
            require(s.count(' cmp #142\n')==1,'SOURCE_NAV','count selector')
            s=s.replace(' cmp #142\n',f' cmp #{len(nav["nodes"])}\n')
            for name,axis,shift in (('nav_xlo',0,0),('nav_xhi',0,8),('nav_ylo',1,0),('nav_yhi',1,8)):
                s=replace(s,name,[v[axis]>>shift for v in nav['nodes']])
        stats.update(keys=len(p['keys']),events=len(p['events']),profileCacheBytes=4096,profileStateBytes=448)
    else:
        ids,segs=walls(bytes(geom['solid']));planes=[0]+[x['plane']+(64 if x['bank']>=2 else 0) for x in segs]
        require(len(planes)<=97,'OWNER_CAPACITY',str(len(planes)-1))
        s=replace(s,'wall_ids',ids);s=replace(s,'fx_wall_plane',planes+[0]*(97-len(planes)))
        (dest/'map.bin').write_bytes(bytes(geom['solid']));stats['owners']=len(segs)
    shutil.copyfile(SOURCE/'font.bin',dest/'font.bin')
    asm=dest/'3Dvibe64.asm';asm.write_text(s,encoding='utf-8')
    tass=os.environ.get('TASS64_EXE')
    if not tass and os.environ.get('TASS64_PATH'):
        p=Path(os.environ['TASS64_PATH']);tass=str(p/'64tass.exe' if p.is_dir() else p)
    tass=tass or shutil.which('64tass') or shutil.which('64tass.exe')
    require(bool(tass),'DEPENDENCY','install 64tass or set TASS64_EXE')
    cmd=[tass,'-a','-B','--m6502','--labels=labels.txt','--vice-labels-numeric','--list=listing.txt','-o','3Dvibe64.prg',asm.name]
    r=subprocess.run(cmd,cwd=dest,capture_output=True)
    (dest/'assembler.log').write_bytes(r.stdout+r.stderr)
    require(r.returncode==0,'ASSEMBLER',(r.stdout+r.stderr).decode(errors='replace'))
    lab=labels(dest);require(lab['code_end']<=(0x3000 if c['backend']=='multi' else 0x2f00),'LOW_BUDGET','runtime overlaps workspace')
    report=dict(graphicsMode=8,run=run,contract=c,sceneSHA256=sha(scene),templateSHA256=sha(template),
        prgSHA256=sha(dest/'3Dvibe64.prg'),prgBytes=(dest/'3Dvibe64.prg').stat().st_size,
        codeLowBytes=lab['code_end']-0x80d,lowFree=(0x3000 if c['backend']=='multi' else 0x2f00)-lab['code_end'],
        viewport=[128,144],activeBitmapBytes=4608,videoStandard='auto',**stats)
    save(dest/'scene.json',data);save(dest/'build.json',report)
    print(json.dumps(report,indent=2));return report

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--scene',required=True);p.add_argument('--out',required=True)
    p.add_argument('--run',choices=['auto','interactive'],default='interactive');p.add_argument('--validate-only',action='store_true')
    a=p.parse_args()
    try:build(a.scene,a.out,a.run,a.validate_only)
    except (ValueError,OSError,json.JSONDecodeError) as e:p.exit(2,str(e)+'\n')
