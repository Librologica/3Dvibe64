"""Public map/parser/router/build contracts. No emulator dependency."""
from pathlib import Path
import copy,hashlib,json,os,shutil,subprocess,sys,tempfile,unittest
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
from mode8.build import validate,load,build
from mode8.font import font
from mode8.contract import valid_pose

FAMILIES=('perimeter','apertures','two-levels')
BASE={k:load(ROOT/f'examples/mode8/{k}.json') for k in FAMILIES}
SUITE=unittest.TestSuite()

def add(name,fn):
    SUITE.addTest(unittest.FunctionTestCase(fn,description=name))

for family in FAMILIES:
    for suffix in ('','-tutorial'):
        def positive(family=family,suffix=suffix):
            c=validate(load(ROOT/f'examples/mode8/{family}{suffix}.json'))
            assert c['family']==family and c['blockedTicks']==0 and c['firstLapTick']>0
        add('valid map / route '+family+suffix,positive)

def bad(name,family,edit,code):
    def check():
        d=copy.deepcopy(BASE[family]);edit(d)
        try:validate(d)
        except ValueError as e:assert code in str(e),(name,str(e),code)
        else:raise AssertionError('Malformed input accepted: '+name)
    add('reject '+name,check)

bad('missing scene','perimeter',lambda d:d.pop('scene'),'DOCUMENT')
bad('extra root','perimeter',lambda d:d.update(meshes=[]),'DOCUMENT')
bad('null scene','perimeter',lambda d:d.update(scene=None),'FORMAT')
bad('schema','perimeter',lambda d:d['scene'].update(schema='polygon'),'SCHEMA')
bad('unknown geometry option','perimeter',lambda d:d['scene'].update(fov=55),'UNKNOWN_FIELD')
bad('missing array','perimeter',lambda d:d['scene'].pop('solid'),'MISSING_FIELD')
bad('size','perimeter',lambda d:d['scene'].update(size=[31,32]),'SIZE')
bad('null doors','perimeter',lambda d:d['scene'].update(doors=None),'FORMAT')
bad('null ramps','perimeter',lambda d:d['scene'].update(ramps=None),'FORMAT')
bad('short array','perimeter',lambda d:d['scene']['solid'].pop(),'FORMAT')
bad('boolean integer','perimeter',lambda d:d['scene']['solid'].__setitem__(0,True),'FORMAT')
bad('invalid solid ID','perimeter',lambda d:d['scene']['solid'].__setitem__(0,2),'SOLID')
bad('open border','perimeter',lambda d:d['scene']['solid'].__setitem__(0,0),'BORDER')
bad('eye height','perimeter',lambda d:d['scene'].update(eyeHeight=31),'CAMERA_HEIGHT')
bad('null player height','perimeter',lambda d:d['scene'].update(playerHeight=None),'INTEGER')
bad('units','perimeter',lambda d:d['scene'].update(heightUnit='WU'),'HEIGHT_UNIT')
bad('initial shape','perimeter',lambda d:d['scene']['initial'].pop(),'FORMAT')
bad('yaw range','perimeter',lambda d:(d['scene']['initial'].__setitem__(2,512),d['navigation']['camera'].__setitem__(2,512)),'INITIAL_POSE')
bad('camera mismatch','perimeter',lambda d:d['navigation']['camera'].__setitem__(0,1000),'CAMERA')
bad('camera footprint','perimeter',lambda d:d['scene']['solid'].__setitem__((4864>>8)*32+(2406>>8),1),'INITIAL_POSE')
bad('camera arbitrary','perimeter',lambda d:(d['scene']['initial'].__setitem__(2,129),d['navigation']['camera'].__setitem__(2,129)),'TEMPLATE_CAMERA')
bad('null nodes','perimeter',lambda d:d['navigation'].update(nodes=None),'NAV_FORMAT')
bad('waypoint float','perimeter',lambda d:d['navigation']['nodes'][0].__setitem__(0,1.5),'FORMAT')
bad('waypoint range','perimeter',lambda d:d['navigation']['nodes'][0].__setitem__(0,8192),'NAV_COORD')
bad('mono route override','perimeter',lambda d:d['navigation']['nodes'][1].__setitem__(0,d['navigation']['nodes'][1][0]+1),'MONO_NAV')
bad('opaque ceiling','perimeter',lambda d:d['scene']['ceiling'].__setitem__(100,96),'MONO_CEILING')
bad('aperture rectangle','apertures',lambda d:d['scene']['doors'][0].__setitem__(0,9),'MONO_APERTURES')
bad('aperture header','apertures',lambda d:d['scene']['ceiling'].__setitem__(14*32+10,65),'MONO_QUOTE')
bad('separator breach','apertures',lambda d:d['scene']['solid'].__setitem__(14*32+16,0),'MONO_SEPARATOR')
bad('ramp formula','two-levels',lambda d:d['scene']['ramps'][0].update(origin=12),'RAMP_FORMULA')
bad('ramp footprint','two-levels',lambda d:d['scene']['solid'].__setitem__(11*32+8,1),'RAMP_FOOTPRINT')
bad('headroom','two-levels',lambda d:d['scene']['ceiling'].__setitem__(2*32+3,40),'HEADROOM')
bad('floor quote','two-levels',lambda d:d['scene']['floor'].__setitem__(2*32+3,1),'MULTI_QUOTE')
bad('discontinuous join','two-levels',lambda d:d['scene']['floor'].__setitem__(2*32+3,32),'MULTI_GEOMETRY')
bad('door metadata','two-levels',lambda d:d['scene']['doors'].pop(),'DOOR_METADATA')
bad('door coordinate','two-levels',lambda d:d['scene']['doors'][0].update(plane=31),'DOOR_BOUNDS')
bad('door height','two-levels',lambda d:d['scene']['doors'][0].update(floor=64),'DOOR_CELL')
bad('multi node capacity','two-levels',lambda d:d['navigation'].update(nodes=d['navigation']['nodes']+d['navigation']['nodes'][:19]),'MULTI_NAV_CAPACITY')

def owner_overflow(d):
    s=d['scene']
    for y in range(5,26,2):
        for x in range(5,27,2):s['solid'][32*y+x]=1
bad('owner capacity','perimeter',owner_overflow,'OWNER_CAPACITY')

def event_overflow(d):
    s=d['scene']
    for i in range(32,320):
        if not s['solid'][i] and s['ceiling'][i]!=80:s['ceiling'][i]=97+i%95
bad('global event and key tables','two-levels',event_overflow,'EVENT_CAPACITY')

def path_overflow(d):
    s=d['scene']
    for x in range(1,31):
        i=3*32+x
        if s['ceiling'][i]!=80:
            s['solid'][i]=0;s['floor'][i]=0;s['ceiling'][i]=128+x%2
bad('per-ray event path (not global capacity)','two-levels',path_overflow,'PATH_CAPACITY')
bad('blocked automatic route','perimeter',lambda d:d['scene']['solid'].__setitem__((d['navigation']['nodes'][10][1]>>8)*32+(d['navigation']['nodes'][10][0]>>8),1),'AUTO_COLLISION')
bad('navigation global capacity','perimeter',lambda d:d['navigation'].update(nodes=[[500,500]]*194),'NAV_CAPACITY')

def default_player():
    d=copy.deepcopy(BASE['perimeter']);d['scene'].pop('playerHeight')
    assert validate(d,route=False)['family']=='perimeter'
add('absent playerHeight uses 48',default_player)

def duplicate_key():
    with tempfile.TemporaryDirectory() as t:
        p=Path(t)/'input.json';p.write_text('{"scene":0,"scene":1}')
        try:load(p)
        except ValueError as e:assert 'DUPLICATE_FIELD' in str(e)
        else:raise AssertionError('Duplicate accepted')
add('duplicate JSON field',duplicate_key)
add('font reproducible from explicit patterns',lambda:unittest.TestCase().assertEqual(font(),(ROOT/'work/mode8/font.bin').read_bytes()))

manifest=load(ROOT/'PACKAGE-MANIFEST.json')
for family in FAMILIES:
    for suffix in ('','-tutorial'):
        for mode in ('interactive','auto'):
            def reproducible(family=family,suffix=suffix,mode=mode):
                with tempfile.TemporaryDirectory(prefix='mode8-build-') as t:
                    scene=ROOT/f'examples/mode8/{family}{suffix}.json'
                    r1=build(scene,Path(t)/'a',mode);r2=build(scene,Path(t)/'b',mode)
                    assert r1['prgSHA256']==r2['prgSHA256']
                    if not suffix:
                        refs=manifest['mode8']['referenceBuilds']
                        expected=next(r['sha256'] for r in refs if r['family']==family and r['run']==mode)
                        assert r1['prgSHA256']==expected
            add('reproducible '+family+suffix+' '+mode,reproducible)

def public_command(extra,ok):
    cmd=[shutil.which('pwsh') or 'powershell','-NoProfile','-File',str(ROOT/'work/build-3Dvibe64.ps1'),
         '-GraphicsMode','8','-SceneFile',str(ROOT/'examples/mode8/perimeter.json'),'-ValidateOnly',*extra]
    r=subprocess.run(cmd,capture_output=True,text=True)
    assert (r.returncode==0)==ok,(cmd,r.stdout,r.stderr)
add('public validation dispatch',lambda:public_command([],True))
add('reject explicit polygon option',lambda:public_command(['-Quality','fast'],False))
add('reject explicit video override',lambda:public_command(['-VideoStandard','pal'],False))

if __name__=='__main__':
    result=unittest.TextTestRunner(verbosity=2).run(SUITE)
    print(f'MODE8 PUBLIC: {result.testsRun-len(result.failures)-len(result.errors)}/{result.testsRun} PASS')
    raise SystemExit(not result.wasSuccessful())
