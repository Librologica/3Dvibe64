"""WORLD-01 bounded graph, data-only channels, CRC and placement contracts."""
import copy,importlib.util,json,binascii
from pathlib import Path
from gameplay_test_inputs import FIXTURES
ROOT=Path(__file__).resolve().parents[1]


def main():
    spec=importlib.util.spec_from_file_location('world',ROOT/'extensions/gameplay/world/groups.py')
    w=importlib.util.module_from_spec(spec);spec.loader.exec_module(w)
    cfg=json.loads((FIXTURES/'extensions/gameplay/profiles/room-groups/assets/world-groups.json').read_text())
    checked=w.validate(cfg);checked['groups'][0]['halfWidth']=18;assert cfg['groups'][0]['halfWidth']==24
    for count in range(2,9):
        d=copy.deepcopy(cfg);d['groups']=[]
        for i in range(count):
            g=copy.deepcopy(cfg['groups'][0]);g['id']=f'g{i}';g['neighbors']=[f'g{j}' for j in (i-1,i+1) if 0<=j<count];d['groups'].append(g)
        w.validate(d)
    bad=[]
    def reject(fn):
        d=copy.deepcopy(cfg);fn(d);bad.append(d)
    for key,value in [('schema',True),('schema',2),('enabled',1),('autoTransitions',0),('capacityBytes',1025),('capacityBytes',True),('extra',0),('groups',[]),('groups',cfg['groups'][:1]),('groups',cfg['groups']*5)]:reject(lambda d,k=key,v=value:d.update({k:v}))
    for key,value in [('id','../bad'),('id','A'),('rooms',True),('rooms',3),('halfWidth',True),('halfWidth',17),('halfWidth',25),('halfWidth',20.5),('floorLevel',-1),('floorLevel',33),('floorLevel',False),('doorIndex',0),('doorIndex',4),('doorIndex',True),('initialOpen',1),('neighbors',[]),('neighbors',['absent']),('neighbors',[cfg['groups'][0]['id']]),('neighbors',[cfg['groups'][1]['id']]*2),('extra',1)]:reject(lambda d,k=key,v=value:d['groups'][0].update({k:v}))
    reject(lambda d:d['groups'][1].update(id=d['groups'][0]['id']))
    d=copy.deepcopy(cfg);d['groups']*=2
    for i,g in enumerate(d['groups']):d['groups'][i]=dict(g,id=f'g{i}',neighbors=[f'g{i^1}'])
    bad.append(d)
    for d in bad:
        try:w.validate(d)
        except ValueError:pass
        else:raise AssertionError('Invalid world accepted')
    # Synthetic exact channel widths exercise serialization independently of ASM.
    base={name:[0]*(21 if name in w.CHANNELS[:6] else 32) for name in w.CHANNELS}
    base['xcoord']=[0]*5;base['ycoord']=[0]*4;base['zcoord']=[0]*4
    base['xcoord'][:3]=[232,24,0];base['mx_face_index'][28:32]=[2]*4
    base['op_face_plane'][:4]=[104,104,152,152]
    groups=w.compile_groups(cfg,base)
    assert groups[0]['channels']==base
    assert groups[1]['channels']['xcoord'][:3]==[236,20,0]
    assert groups[1]['channels']['op_face_plane'][:4]==[108,108,148,148]
    assert groups[1]['channels']['gouraud_face_shade0'][8:12]==[10]*4
    assert len(w.CHANNELS)==27 and len(w.FIELDS)==14
    for i,g in enumerate(groups):
        blob=g['blob'];assert len(blob)==762<1024 and g['payloadBytes']==748
        assert blob[:8]==b'WG01'+bytes([i,2,21,32])
        assert binascii.crc_hqx(blob[:-2],0xffff)==int.from_bytes(blob[-2:],'little')==g['CRC16']
        assert bytes(v for n in w.CHANNELS for v in g['channels'][n])==blob[12:-2]
    print(f'WORLD GROUPS PASS;2..8 connected reciprocal groups;{len(bad)} invalid inputs refused;27 whitelisted channels,762byte CRC packages')


if __name__=='__main__':main()
