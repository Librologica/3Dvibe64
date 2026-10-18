"""Assembled exact raster/support contracts; never derives or estimates FPS.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,importlib.util,itertools,json,random,sys,tempfile,math
from pathlib import Path
from test_texture_perspective import Machine,builder,ROOT
sys.path[:0]=[str(ROOT/'extensions/gameplay'),str(ROOT/'extensions/gameplay/materials'),str(ROOT/'extensions/gameplay/visibility')]
import runtime_support as support,static_patterns as patterns,wall_occlusion as walls


def assembled(text,out,name):
    folder=out/name;folder.mkdir()
    builder.assemble(text,folder,'3Dvibe64')
    return Machine(folder)


def main():
    sys.path.insert(0,str(ROOT/'work'))
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    p=argparse.ArgumentParser();p.add_argument('--control',type=Path);p.add_argument('--exact',type=Path);p.add_argument('--out',type=Path)
    a=p.parse_args();rng=random.Random(1120);counts={}
    with tempfile.TemporaryDirectory(prefix='3dvibe64-exact-') as temp:
        out=a.out.resolve() if a.out else Path(temp)
        if out.is_relative_to(ROOT):raise ValueError('Test output must stay outside SDK')
        out.mkdir(parents=True,exist_ok=True)
        if a.control and a.exact:
            old,new=Machine(a.control),Machine(a.exact)
            for n,d in [(0,1),(0xffffff,1),(0xffffff,65535),(255,1),(256,1),(0xffffff,0)]+[(rng.randrange(1<<24),rng.randrange(1,65536)) for _ in range(3000)]:
                result=[]
                for m in (old,new):
                    m.put('ps_num',n,3);m.put('ps_den',d,2);m.put('ps_fault',0);m.call('ps_div24_16')
                    result.append((m.get('ps_num',3),m.get('ps_remainder',2),m.get('ps_fault')))
                assert result[0]==result[1],(n,d,result)
                if d:assert result[1][:2]==divmod(n,d),(n,d,result)
            counts['divisionCases']=3006
            fields=['hc_a_'+axis+suffix for axis in 'xy' for suffix in ('lo','hi','ext')]+['hc_a_slo','hc_a_shi','hc_a_vlo','hc_a_vhi','hc_a_wlo','hc_a_whi']
            for plane in range(4):
                for case in range(65):
                    x0,x1=sorted((rng.randrange(-20000,60000),rng.randrange(-20000,60000)))
                    y0,y1=sorted((rng.randrange(-10000,40000),rng.randrange(-10000,40000)))
                    pts=[(x0,y0),(x1,y0),(x1,y1),(x0,y1)];attrs=[[rng.randrange(65536) for _ in pts] for _ in range(3)];result=[]
                    for m in (old,new):
                        m.put('hc_count',4);m.put('hc_plane',plane);m.put('hc_changed',0)
                        if 'ro_active' in m.lab:m.put('ro_active',15)
                        for i,point in enumerate(pts):
                            for axis,value in zip('xy',point):
                                for j,suf in enumerate(('lo','hi','ext')):m.put('hc_a_'+axis+suf,(value>>(8*j))&255,off=i)
                            for k,attr in enumerate('svw'):
                                for j,suf in enumerate(('lo','hi')):m.put('hc_a_'+attr+suf,(attrs[k][i]>>(8*j))&255,off=i)
                        m.call('hc_screen_pass');n=m.get('hc_count')
                        result.append((n,m.get('hc_changed'),tuple(bytes(m.cpu.memory[m.lab[f]:m.lab[f]+n]) for f in fields)))
                    assert result[0]==result[1],(plane,case)
            counts['clipCases']=260
            if 'er_advance_0' in new.lab:
                for case in range(5000):
                    den=rng.choice((1,2,3,7,31,64,127,128,159,255));uniform=case%13==0
                    new.put('pu_texel',int(uniform));new.put('m7_den',den);pos=rng.randrange(256);new.put('gouraud_scan_x',pos)
                    before=[]
                    for i in range(3):
                        cur=rng.randrange(65536);step=rng.randrange(65536);err=rng.randrange(den);rem=rng.randrange(den);ca=rng.randrange(2)
                        before.append((cur,step,err,rem,ca))
                        for name,value in [('ps_cur0',cur&255),('ps_cur1',cur>>8),('ps_step0',step&255),('ps_step1',step>>8),('ps_err',err),('ps_rem',rem),('ri_ca',ca)]:new.put(name,value,off=i)
                    new.cpu.x=91;new.cpu.y=103;new.call('ps_advance')
                    assert new.cpu.x==91 and new.cpu.y==103 and new.get('gouraud_scan_x')==(pos+1)&255
                    for i,(cur,step,err,rem,ca) in enumerate(before):
                        carry=int(err+rem>=den);expected=(cur,err,ca) if uniform else ((cur+step+carry)&65535,(err+rem)%den,carry)
                        actual=(new.get('ps_cur0',off=i)+256*new.get('ps_cur1',off=i),new.get('ps_err',off=i),new.get('ri_ca',off=i))
                        assert actual==expected,(case,i,actual,expected)
                counts['advanceCases']=5000
        for v in itertools.product(range(4),repeat=4):
            from exact_raster import pack_four
            assert pack_four(v)==sum(x<<(6-2*i) for i,x in enumerate(v))
        counts['pixelPacks']=256
        cache=patterns.FlatCache();assert cache.assign('f',1,6)==cache.assign('f',1,6)
        assert cache.assign('f',2,7)!=cache.assign('f',1,6);cache.invalidate('f');assert not cache.entries
        cache.assign('typed',1,1)
        for revision,level in [(1,True),([],1)]:
            try:cache.assign('typed',revision,level)
            except ValueError:pass
            else:raise AssertionError('Invalid cache input reused a valid entry')
        palette_stub='MATERIAL_CELL_SPAN_CACHE=0\n*=$0801\nmaterial_screen_bytes:\n .byte 123,123\nmaterial_color_bytes:\n .byte 1,1\napply_material_span_a:\n inc sentinel\n rts\napply_material_span_b:\n inc sentinel\n rts\nmaybe_apply_material_span_a:\n inc sentinel\n rts\nmaterial_span_restore_original:\n inc sentinel\n rts\n.if MATERIAL_CELL_SPAN_CACHE\n.endif\nsentinel: .byte 17\n'
        pm=assembled(patterns.shared_palette(palette_stub,immutable=True),out,'palette-once')
        for entry in ['apply_material_span_a','apply_material_span_b','maybe_apply_material_span_a','material_span_restore_original']:
            pm.cpu.x=73;pm.cpu.y=91;pm.call(entry);assert pm.get('sentinel')==17 and pm.cpu.x==73 and pm.cpu.y==91
        nc=assembled('*=$0801\n'+patterns.native_cache(3)+'sp_current_row: .fill 4,99\n',out,'native-cache')
        nc.cpu.x=0;nc.call('sf_load');assert not nc.cpu.p&1 and nc.get('sp_current_row')==99
        for face in range(3):
            for level in range(17):
                nc.cpu.x=face;nc.cpu.a=level;nc.call('sf_assign');assert nc.cpu.p&1
                nc.cpu.x=face;nc.call('sf_load');assert nc.cpu.p&1
                assert [nc.get('sp_current_row',off=i) for i in range(4)]==list(patterns.pattern(level))
            nc.cpu.x=face;nc.call('sf_invalidate');nc.cpu.x=face;nc.call('sf_load');assert not nc.cpu.p&1
        for face,level in [(3,0),(255,16),(0,17),(0,255)]:
            nc.cpu.x=face;nc.cpu.a=level;nc.call('sf_assign');assert not nc.cpu.p&1
        counts['nativeCacheAssignments']=51
        tables=support.camera_tables();assert len(tables['bob'])==256
        assert max(tables['bank'])<=456 and min(tables['bank'])>=-456
        assert support.camera_assembly(tables).count('.byte')==6
        # Execute a harmless synthetic SID player: no song or payload in SDK.
        source='*=$0801\n'+support.sid_wrapper(0x1400,0x1500)+'*=$1400\n lda #7\n sta $f0\n rts\n*=$1500\n inc $f0\n lda $f0\n sta $d400\n rts\n'
        m=assembled(source,out,'sid-wrapper');m.cpu.memory[1]=0x37
        keep=[rng.randrange(256) for _ in range(8)];m.cpu.memory[0xf0:0xf8]=keep
        m.call('sid_init')
        for i in range(1024):
            m.call('sid_tick')
            assert m.cpu.memory[1]==0x37 and m.cpu.memory[0xf0:0xf8]==keep
            assert m.get('sid_calls',2)==i+1 and m.cpu.memory[0xd400]==(8+i)&255
        counts['SIDCalls']=1024
        source='*=$0801\n'+support.resident_pool(3,'recycle')+'recycle:\n lda fail\n beq +\n clc\n rts\n+\n sec\n rts\nfail: .byte 0\n'
        m=assembled(source,out,'pool');m.call('pool_init');success=0
        for i in range(1000):
            fail=int(i%7==0);m.put('fail',fail);m.call('pool_next')
            if not fail:success+=1
            assert m.get('pool_generation',2)==success and m.get('pool_cursor')==success%3
        counts['poolTransitions']=1000
        stub='ptr0lo=$20\nptr0hi=$21\nptr1lo=$22\nptr1hi=$23\nleftval=$24\nrightval=$25\nyrow=$26\ngouraud_scan_x=$27\ngouraud_scan_end=$28\n*=$0801\n'+patterns.bulk_span()+'tq_closed: .fill 100,0\ngouraud_init_span_pointers:\n lda gouraud_scan_x\n and #252\n asl\n sta ptr0lo\n sta ptr1lo\n lda #$20\n adc #0\n sta ptr0hi\n clc\n adc #$10\n sta ptr1hi\n rts\n'
        m=assembled(stub,out,'bulk');spans=0
        for left in range(160):
          for length in [1,2,3,4,7,16,31,160]:
           for closed in (0,1):
            right=min(159,left+length-1)
            if not closed and right==159:continue
            row=spans%4;fill=patterns.pattern(spans%17,0,2)[row];before=[[rng.randrange(256) for _ in range(512)] for _ in range(2)];expected=[x.copy() for x in before]
            for x in range(left,right+1):
                off=x//4*8;shift=6-2*(x&3)
                for block in expected:block[off]=(block[off]&~(3<<shift))|(fill&(3<<shift))
            for base,data in zip((0x2000,0x3000),before):m.cpu.memory[base:base+512]=data
            m.put('sp_current_row',fill,off=row);m.put('leftval',left);m.put('rightval',right if closed else right+1);m.put('yrow',row);m.put('tq_closed',closed,off=row);m.call('sp_solid')
            for base,data in zip((0x2000,0x3000),expected):assert m.cpu.memory[base:base+512]==data,(left,right,closed)
            spans+=1
        counts['bulkSpans']=spans
        # Assemble and exercise the public whole-wall kernel with independent
        # screen rectangles. This fixture has no scene or rendering demo.
        source='CONSERVATIVE_SLIVER_CULL=1\n*=$0801\nbegin_depth_buckets:\n rts\ninsert_bucket:\n sta bucket_head,x\n rts\ndraw_depth_buckets:\n rts\nddb_face_loop:\n rts\nddb_after_draw:\n rts\nbucket_head: .fill 128,0\nmaterial_screen_bytes:\n .byte 123\nmaterial_color_bytes:\n .byte 1\nface0: .byte 0,0,4,4\nface1: .byte 1,2,5,6\nface2: .byte 2,3,6,7\nprojdone: .fill 8,1\nsx: .fill 8,0\nsy: .fill 8,0\nvert_yi: .byte 0,0,1,1,0,0,1,1\nycoord: .byte 244,12\nsortj: .byte 0\n'
        raw_source=source
        mixed_source=source.replace(' .byte 123\n',' .byte 123,124\n')
        try:walls.attach(mixed_source,{'data':''},face_count=4,first_faces=[0,2],opaque_vertical_contract=True)
        except ValueError as ex:assert 'palette' in str(ex)
        else:raise AssertionError('Unqualified mixed palette accepted')
        walls.attach(mixed_source,{'data':''},face_count=4,first_faces=[0,2],opaque_vertical_contract=True,palette_indices=[0])
        parts={'data':''};source,parts=walls.attach(raw_source,parts,face_count=4,first_faces=[0,2],opaque_vertical_contract=True)
        m=assembled(source+'\n'+'\n'.join(parts.values()),out,'occlusion');rejected=0
        for i in range(1006):
            m.call('oc_reset');rects=[(20,140,10,90),(60,100,40,60)] if i<6 else []
            while len(rects)<2:
                x=rng.randrange(130);y=rng.randrange(80);rects.append((x,rng.randrange(x+1,160),y,rng.randrange(y+1,100)))
            depths=[(10,11),(30,31)] if i<6 else [(rng.randrange(100),rng.randrange(100)) for _ in range(2)]
            if i==2:depths=[(40,41),(30,31)]
            if i==3:depths=[(10,30),(30,31)]
            if i==5:depths=[(10,255),(30,31)]
            for q,(x0,x1,y0,y1) in enumerate(rects):
                for j,(x,y) in enumerate([(x0,y1),(x1,y1),(x1,y0),(x0,y0)]):
                    m.put('sx',x,off=q*4+j);m.put('sy',y,off=q*4+j);m.put('projdone',0 if i==4 and q==0 and j==0 else 1,off=q*4+j)
                for j,value in enumerate(depths[q]):m.put('oc_depth',value,off=q*2+j)
            m.call('oc_build');expected=[]
            for target in range(2):
                occ=1-target;tx0,tx1,ty0,ty1=rects[target];x0,x1,y0,y1=rects[occ]
                expected.append(int(i!=4 and 255 not in depths[target] and 255 not in depths[occ] and max(depths[occ])<min(depths[target]) and tx0>=x0+5 and tx1<=x1-5 and ty0>=y0+5 and ty1<=y1-5))
            assert [m.get('oc_hidden',off=q) for q in range(2)]==expected,(i,rects,depths)
            for f in range(4):m.cpu.y=f;m.call('oc_hidden_face');assert bool(m.cpu.p&1)==bool(expected[f//2])
            rejected+=sum(expected)
        assert rejected;counts['occlusionDecisions']=1006
        from exact_raster import uniform_gouraud,inline_gouraud,texture_page
        table=[patterns.pattern(i,0,2) for i in range(17)]
        dispatcher=uniform_gouraud(table)
        stub='yrow=$20\ngouraud_scan_shade=$21\n*=$0801\n'+dispatcher+'rightshade: .fill 4,0\nsp_current_row: .fill 4,0\nsp_solid:\n lda #1\n sta selected\n rts\ngouraud_draw_scan_span_bytes:\n lda #2\n sta selected\n rts\nselected: .byte 0\n'
        m=assembled(stub,out,'constant-gouraud');cases=0
        for row in range(4):
            for a0 in range(17):
                for a1 in range(17):
                    m.put('yrow',row);m.put('gouraud_scan_shade',a0);m.put('rightshade',a1,off=row);m.call('er_uniform_span')
                    equal=table[a0][row]==table[a1][row]
                    assert m.get('selected')==(1 if equal else 2)
                    if equal:assert m.get('sp_current_row',off=row)==table[a0][row]
                    cases+=1
        counts['constantGouraudIntervals']=cases
        oc=Machine(out/'occlusion');projection_checks=0
        for case in range(2000):
            x0=rng.uniform(-45,25);x1=x0+rng.uniform(5,50);z0=rng.uniform(8,100);z1=z0+rng.uniform(-6,30)
            pitch=rng.uniform(-.6,.6);roll=rng.uniform(-.5,.5);eye=rng.uniform(-10,10)
            world=[(x0,-12,z0),(x1,-12,z1),(x1,12,z1),(x0,12,z0)];projected=[]
            for x,y,z in world:
                y-=eye;y,z=y*math.cos(pitch)-z*math.sin(pitch),y*math.sin(pitch)+z*math.cos(pitch)
                x,y=x*math.cos(roll)-y*math.sin(roll),x*math.sin(roll)+y*math.cos(roll)
                if z<=2:break
                projected.append((80+170*x/z,50-170*y/z))
            if len(projected)!=4:continue
            oc.call('oc_reset')
            for i,(x,y) in enumerate(projected):
                oc.put('sx',max(0,min(159,round(x))),off=i);oc.put('sy',max(0,min(99,round(y))),off=i);oc.put('projdone',1,off=i)
            oc.put('oc_depth',10);oc.put('oc_depth',11,off=1);oc.call('oc_build')
            if oc.get('oc_far')==255:continue
            left,right,top,bottom=[oc.get('oc_'+name) for name in ('left','right','top','bottom')]
            for x,y in [(left,top),(right,top),(right,bottom),(left,bottom)]:
                cross=[]
                for i,(ax,ay) in enumerate(projected):
                    bx,by=projected[(i+1)%4];cross.append((bx-ax)*(y-ay)-(by-ay)*(x-ax))
                assert all(v>=0 for v in cross) or all(v<=0 for v in cross),(case,projected,(left,right,top,bottom))
            projection_checks+=1
        assert projection_checks>0;counts['perspectiveRectangles']=projection_checks
        try:uniform_gouraud([(0,0,0,0),(1,0,0,0),(0,0,0,0)])
        except ValueError:pass
        else:raise AssertionError('Unsafe constant interval accepted')
        assert texture_page([0,1,2,3]*64)==bytes([0,1,2,3]*64)
        fake='entry:\n jsr gouraud_advance_scan_pixel\n rts\ngouraud_advance_scan_pixel:\n inc value\n rts\nvalue: .byte 0\n'
        im=assembled('*=$0801\n'+inline_gouraud(fake),out,'inline');im.call('entry');assert im.get('value')==1
        assert walls.validate_quads([[-1,-1,2],[1,-1,2],[1,1,2],[-1,1,2]],[[0,1,2],[0,2,3]],[0])
        counts.update(status='PASS',FPSMeasured=False)
        if a.out:(out/'result.json').write_text(json.dumps(counts,indent=2))
        print(json.dumps(counts,indent=2),flush=True)

if __name__=='__main__':main()
