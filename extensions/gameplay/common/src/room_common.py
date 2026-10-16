"""Single large-room textured Gouraud experiment; frozen SDK is read-only.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. No Quake assets or source code used.
"""
import argparse, hashlib, importlib.util, json, math, os, re, shutil, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RELEASE = ROOT.parent/'Release-1.5.5/3Dvibe64_github-ready_1.5.5'
MUSIC = ROOT.parent.parent/'2.5vibeVic-Gallery-Static-SID'
TASS = Path(os.environ.get('TASS64_EXE', r'C:\Users\rapso\Desktop\c64\tools\64tass\64tass-1.60.3243\64tass.exe'))
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest().upper()

def verify_release():
    lines=(RELEASE/'MANIFEST.sha256').read_text().splitlines()
    for line in lines:
        h,p=line.split('  ',1)
        assert sha(RELEASE/p)==h, f'Frozen manifest mismatch: {p}'
    expected={line.split('  ',1)[1].replace('\\','/') for line in lines}|{'MANIFEST.sha256'}
    actual={p.relative_to(RELEASE).as_posix() for p in RELEASE.rglob('*') if p.is_file()}
    assert actual==expected, f'Frozen tree changed: {actual ^ expected}'
    return dict(files=len(actual), builder=sha(RELEASE/'work/build-3Dvibe64.ps1'),
                manifest=sha(RELEASE/'MANIFEST.sha256'))

def textures():
    result=[]
    for name in ('stone','plain-floor','plain-ceiling'):
        pixels=[]
        for y in range(16):
            for x in range(16):
                if name=='stone':
                    xx=(x+(4 if (y//4)&1 else 0))&7
                    # 8x4 pixel blocks, with subtle top-edge relief, not broad
                    # high-contrast crosses. Same physical texel scale on U/V.
                    p=1 if y%4==0 or xx==0 else (3 if y%4==1 and xx in (2,3,4) else 2)
                elif name=='plain-floor':p=1
                elif name=='plain-ceiling':p=2
                else:
                    p=1
                    if (x in (4,11) and 3<=y<=12) or (y in (3,8,12) and 4<=x<=11):p=3
                    elif 3<x<12 and 2<y<14:p=2
                pixels.append(p)
        result.append(dict(id=name,width=16,height=16,texels=pixels,repeat=[4,8]))
    return result

class Mesh:
    def __init__(self,name,centre):
        self.name=name;self.centre=centre;self.vertices=[];self.faces=[];self.uv=[];self.tex=[]
    def quad(self,points,normal,texture='stone'):
        # Points given in public world X/right,Y/forward,Z/up. Local mesh uses X,Y/up,Z/forward.
        a,b,c=points[:3];u=[b[i]-a[i] for i in range(3)];v=[c[i]-a[i] for i in range(3)]
        cross=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
        # X,Z,Y permutation has negative determinant: reverse public winding.
        if texture=='stone':
            axis=1 if normal[0] else 0
            horizontal=[p[axis] for p in points]
            # Global wall anchor; subtract ONLY whole texture periods. Resetting
            # to each panel origin makes 16-WU panels jump phase every seam.
            ushift=4*math.floor(min((h+24)*2/3 for h in horizontal)/4)
            # 1 WU = 0.15 m in this DEMO ONLY. Tile period 6 WU = 0.9 m;
            # brick 8x4 px = 3x1.5 WU = 45x22.5 cm. Repeat 4 handles addressing.
            vertical=[(p[2]+10)/3 for p in points]
            shift=4*math.floor(min(vertical)/4)
            uv=[[round(((p[axis]+24)*2/3-ushift)*16)/16,
                 round(((p[2]+10)/3-shift)*16)/16] for p in points]
        else:uv=[[0,0] for _ in points] # uniform surfaces, no visible texture pattern
        if sum(cross[i]*normal[i] for i in range(3))>0:
            points=list(reversed(points));uv=list(reversed(uv))
        face=[]
        for x,y,z in points:
            p=[x-self.centre[0],z-self.centre[2],y-self.centre[1]]
            if p not in self.vertices:self.vertices.append(p)
            face.append(self.vertices.index(p))
        self.faces.append(face);self.tex.append(texture)
        self.uv.append(uv)
    def scene(self):
        return dict(id=self.name,type='mesh',geometry='solid',materialProfile='single',
                    vertices=self.vertices,faces=self.faces,texture='stone',faceTextures=self.tex,faceUV=self.uv,
                    gouraud=dict(creaseAngle=60))

def make_scene():
    m=Mesh('room',[0,0,0])
    for h0,h1 in ((-24,-8),(-8,8),(8,24)):
        for z0,z1 in ((-10,4),(4,18)):
            for x,n in ((-24,[1,0,0]),(24,[-1,0,0])):
                m.quad([(x,h0,z0),(x,h1,z0),(x,h1,z1),(x,h0,z1)],n)
            for y,n in ((-24,[0,1,0]),(24,[0,-1,0])):
                m.quad([(h0,y,z0),(h1,y,z0),(h1,y,z1),(h0,y,z1)],n)
    for z,normal,texture in ((-10,[0,0,1],'plain-floor'),(18,[0,0,-1],'plain-ceiling')):
        corners=[(-24,-24,z),(24,-24,z),(24,24,z),(-24,24,z)]
        for i in range(4):m.quad([corners[i],corners[(i+1)%4],(0,0,z)],normal,texture)
    meshes=[m]
    doc=dict(schema=1,name='large-room-mode7-gouraud-q8',graphicsMode=7,axisConvention='world-z-up',
             textureLighting='gouraud',textureCompositor='C',texturePalette=[9,12,15],
             world=dict(backgroundColor=0,grounds=[]),
             camera=dict(id='camera',position=[-8,0,0],rotation=[0,0,0],mode='walkLite'),
             lights=[dict(id='lamp',mode='static',position=[-17,0,12],intensity=10)],
             textures=textures(),meshes=[m.scene() for m in meshes],
             objects=[dict(id=m.name,mesh=m.name,position=m.centre,rotation=[0,0,0],
                           angularVelocity=[0,0,0],scale=1,visible=True,material='gray',reflectivity='satin') for m in meshes],
             contract=dict(version=1,viewportProfile='normal',ground=False))
    stats=dict(vertices=sum(len(m.vertices) for m in meshes),quads=sum(len(f)==4 for m in meshes for f in m.faces),
               triangles=sum(len(f)-2 for m in meshes for f in m.faces),
               radii=[max(math.sqrt(sum(v*v for v in p)) for p in m.vertices) for m in meshes])
    assert stats['vertices']<=96 and max(stats['radii'])<=40,stats
    (ROOT/'scenes').mkdir(exist_ok=True)
    path=ROOT/'scenes/large-room.json';path.write_text(json.dumps(doc,indent=2))
    return path,stats

def bake_static_light(source):
    """Demo-only, stationary light/mesh: true Gouraud Q varies along flat walls.

    The public point-dot model is unnormalised and constant on a flat plane;
    do not silently change it in the SDK. Bake standard diffuse/attenuated
    vertex lighting here, then keep the native Mode 7 C U/V/Q rasterizer.
    """
    def array(name):
        pat=r'(?m)^'+name+r':\n((?: \.byte[^\n]*\n)+)'
        m=re.search(pat,source);assert m,name
        values=[int(v[1:],16) if v.startswith('$') else int(v) for v in
                re.findall(r'\$[0-9A-Fa-f]+|-?\d+',m[1])]
        return m,values
    normals=[]
    for axis in 'xyz':
        _,values=array('gouraud_normal_'+axis)
        normals.append([(n+128)%256-128 for n in values])
    count=len(normals[0]);geom={}
    for corner in range(3):
        _,indices=array('face'+str(corner));_,shades=array('gouraud_face_shade'+str(corner))
        assert len(indices)==len(shades)
        for v,s in zip(indices,shades):
            assert s not in geom or geom[s]==v,('Shade vertex geometry mismatch',s)
            geom[s]=v
    scene=json.loads((ROOT/'scenes/large-room.json').read_text());vertices=scene['meshes'][0]['vertices']
    world_light=scene['lights'][0]['position'];light=[world_light[0],world_light[2],world_light[1]]
    levels=[];entries=[]
    for s in range(count):
        p=vertices[geom[s]];n=[normals[a][s] for a in range(3)]
        vector=[light[a]-p[a] for a in range(3)]
        distance=math.sqrt(sum(v*v for v in vector));length=math.sqrt(sum(v*v for v in n))
        cosine=max(0,sum(n[a]*vector[a] for a in range(3))/(length*distance))
        level=max(0,min(32,round(5+38*cosine/(1+(distance/30)**2))))
        levels.append(level);entries.append(dict(shadeVertex=s,geometryVertex=geom[s],normal=n,
                                                distance=distance,cosine=cosine,Q=level))
    a,b=array('gouraud_shade_value')
    source=source[:a.start()]+'gouraud_shade_value:\n .byte '+','.join(map(str,levels))+'\n'+source[a.end():]
    begin=source.index('m3_update_shades:\n');end=source.index('m3_update_shades_end = *',begin)
    source=source[:begin]+'m3_update_shades:\n rts ; static vertex Q baked by this DEMO, not an SDK change\n'+source[end:]
    # Unused after baking: only host code consumed these lighting metadata.
    for name in ['gouraud_normal_'+a for a in 'xyz']+['gouraud_center_dot_lo','gouraud_center_dot_hi']:
        block,_=array(name);source=source[:block.start()]+source[block.end():]
        executable='\n'.join(l.split(';',1)[0] for l in source.splitlines())
        assert not re.search(r'\b'+name+r'\b',executable),('Live lighting metadata',name)
    report=dict(model='static normalized Lambert + attenuation; demo-only',lightWorldWU=world_light,
                equation='Q=clamp(round(5+38*max(dot(unitN,unitL),0)/(1+(distanceWU/30)^2)),0,32)',
                levels=levels,entries=entries,range=[min(levels),max(levels)],runtime='native Gouraud C U/V/Q interpolation')
    (ROOT/'reports/static-light.json').write_text(json.dumps(report,indent=2))
    return source

def trajectory():
    # Calm walking tour: 20.48 seconds nominal, average ~0.47 m/s.
    poses=[]
    for i in range(64):
        a=-math.pi/2+math.tau*i/64
        x=8*math.sin(a);forward=-12*math.cos(a)
        # camera yaw convention: world forward=(-sin(yaw),cos(yaw),0).
        yaw=-math.atan2(8*math.cos(a),12*math.sin(a))*256/math.tau
        pitch=5*math.sin(2*a)
        poses.append([round(x*256),0,round(forward*256),round(yaw*256)&65535,round(pitch*256)&65535])
    data='';fields=('x','y','z','yaw','pitch')
    for f,name in enumerate(fields):
        vals=[p[f]&65535 for p in poses]
        ds=[round((((vals[(i+1)%64]-v+32768)&65535)-32768)/16)&65535 for i,v in enumerate(vals)]
        for kind,arr in (('pos',vals),('delta',ds)):
            for shift,suffix in ((0,'lo'),(8,'hi')):
                data+=f'demo_{name}_{kind}_{suffix}: .byte '+','.join(str((v>>shift)&255) for v in arr)+'\n'
    code='''qc_demo_tick:
 lda demo_subtick
 bne demo_increment
 ldx demo_key
'''
    for name in fields:
        for suffix in ('lo','hi'):
            code+=f' lda demo_{name}_pos_{suffix},x\n sta demo_{name}_{suffix}\n'
            code+=f' lda demo_{name}_delta_{suffix},x\n sta demo_{name}_step_{suffix}\n'
    code+='demo_increment:\n'
    for name in fields:
        code+=f' clc\n lda demo_{name}_lo\n adc demo_{name}_step_lo\n sta demo_{name}_lo\n lda demo_{name}_hi\n adc demo_{name}_step_hi\n sta demo_{name}_hi\n'
    for name in ('x','z'):
        for suffix in ('lo','hi'):code+=f' lda demo_{name}_{suffix}\n sta explorer_cam_{name}_{suffix}\n'
        code+=f' lda demo_{name}_hi\n asl\n lda #0\n sbc #0\n eor #255\n sta explorer_cam_{name}_ext\n'
    code+=''' ; Head bob is tied to logical time, never to rendered frames.
 inc demo_bob_phase
 lda demo_bob_phase
 and #31
 tax
 clc
 lda demo_y_lo
 adc demo_bob,x
 sta explorer_cam_y_lo
 lda demo_y_hi
 adc #0
 sta explorer_cam_y_hi
 lda #0
 sta explorer_cam_y_ext
'''
    for name in ('yaw','pitch'):
        code+=f' lda demo_{name}_lo\n sta qc_demo_{name}_lo\n lda demo_{name}_hi\n sta explorer_cam_{name}\n'
    code+=''' inc demo_subtick
 lda demo_subtick
 and #15
 sta demo_subtick
 bne demo_tick_done
 inc demo_key
 lda demo_key
 and #63
 sta demo_key
demo_tick_done:
 rts
demo_key: .byte 0
demo_subtick: .byte 0
demo_bob_phase: .byte 0
qc_demo_yaw_lo: .byte 0
qc_demo_pitch_lo: .byte 0
'''
    for name in fields:
        for kind in ('lo','hi','step_lo','step_hi'):code+=f'demo_{name}_{kind}: .byte 0\n'
    data+='demo_bob: .byte '+','.join(str(round(16*(1-math.cos(i*math.tau/32)))) for i in range(32))+'\n'
    (ROOT/'scenes/camera-keyframes.json').write_text(json.dumps(dict(ticksPerKey=16,posesQ8=poses,periodTicks=1024,
        metresPerWU=0.15,eyeHeightMetres=1.5,roomMetres=[7.2,7.2,4.2]),indent=2))
    return code,data

def music_parts():
    assert sha(MUSIC/'Gallery-Static.sid')=='4715E47BE7F74C80EF1DBFBD7879C234C039024A44E43F2C45C1B3AC619D735F'
    s=(MUSIC/'src/player.asm').read_text().replace('\r\n','\n')
    s=s[s.index('sid_init:'):s.index('code_end:')]+s.split('code_end:')[1].split('.include')[0]
    tables=(MUSIC/'build/score.inc').read_text().replace('\r\n','\n')
    names=set(re.findall(r'^(\w+):',s+tables,re.M))
    for n in sorted(names,key=len,reverse=True):
        s=re.sub(r'\b'+n+r'\b','gs_'+n,s);tables=re.sub(r'\b'+n+r'\b','gs_'+n,tables)
    return s,tables

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--name',default='room-pal-final');parser.add_argument('--silent',action='store_true')
    args=parser.parse_args()
    for d in ('reports','build','scenes','artifacts'): (ROOT/d).mkdir(exist_ok=True)
    identity=verify_release();scene,stats=make_scene()
    os.environ['TASS64_EXE']=str(TASS);os.environ['PYTHONDONTWRITEBYTECODE']='1'
    # Import read-only generator. It builds only into a separate disposable SDK copy.
    # This four-object demo exceeds the public two-object Q8 profile. Keep
    # its qualified private adapter explicit, but regenerate the underlying
    # runtime from the unmodified RC SDK, including safe presentation.
    private_adapter=ROOT.parent/'private/q8/build.py'
    spec=importlib.util.spec_from_file_location('qualified_q8',private_adapter)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    module.SDK_ROOT=RELEASE
    attach=module.attach;route,table=trajectory()
    def demo_attach(source,parts,placed=None):
        source=bake_static_light(source)
        # Demo-only wider room view. Native Q8 projector uses this constant
        # for both axes; screen clipping remains in projected coordinates.
        source,n=re.subn(r'(?m)^PROJ_FOCAL = \$[0-9a-fA-F]+$', 'PROJ_FOCAL = $55',source)
        assert n==1,'Missing projection focal constant'
        source=source.replace('; PROJECTION_CONTRACT_FOCAL=170','; DEMO_PROJECTION_FOCAL=85')
        source=source.replace('PROJ_FRUSTUM_FOCAL = $55','PROJ_FRUSTUM_FOCAL = $2A')
        # Continuous Q8 uses an explicitly emitted constant, not PROJ_FOCAL.
        for name in parts:
            parts[name]=parts[name].replace('43520','21760').replace('(170*256)','(85*256)')
        source,parts=viewport_adapter(source,parts)
        if placed is not None:
            source=source.replace('fps_frame_done:\n','fps_frame_done:\n jsr demo_count_frame\n')
            source=source.replace(' inc sim_vblank_count\n',' inc sim_vblank_count\n jsr demo_count_refresh\n')
            source=source.replace(' jsr init_irq\n',' jsr qc_demo_tick\n jsr init_irq\n')
            if not args.silent:
                source=source.replace(' jsr init_irq\n',' jsr gs_sid_init\n jsr init_irq\n')
                source=source.replace(' inc sim_vblank_count\n',' inc sim_vblank_count\n jsr gs_sid_play\n')
            source,parts=render_adapter(source,parts,placed)
            result=attach(source,parts,placed)
            return post_attach_adapter(result) if 'post_attach_adapter' in globals() else result
        parts['camera_demo']=route;parts['demo_route_tables']=table
        dynamic_parts=parts.copy()
        # Demo-only exact specialization: both objects have constant identity
        # transforms and scale 1. Camera rotation/translation stays fully Q8.
        # Fill identical signed Q8 coordinate terms without nine matrix products.
        parts['matrix']='hp_prepare_matrix:\n rts\n'
        parts['trig']='hp_prepare_trig:\n rts\n'
        for axis in ('y','z'):parts['camera_trig_'+axis]=f'qc_trig_{axis}:\n rts\n'
        terms='hp_prepare_terms:\n'
        for j,axis in enumerate('xyz'):
            terms+=f' ldx #{axis.upper()}COORD_COUNT-1\ndemo_identity_{axis}:\n lda #0\n'
            for i in range(3):
                terms+=f' sta hp_term{i}{j}_lo,x\n'
                if i!=j:terms+=f' sta hp_term{i}{j}_hi,x\n'
            terms+=f' lda {axis}coord,x\n sta hp_term{j}{j}_hi,x\n dex\n bpl demo_identity_{axis}\n'
        parts['terms']=terms+' rts\n'
        # Exact identity transform: each axis has only one nonzero local term.
        vertex='hp_build_vertices:\n lda active_vfirst\n sta hp_idx\nhc_vertex_loop:\n ldy hp_idx\n'
        for axis,cache in zip('xyz',('rxbuf','rybuf','sz')):
            vertex+=f' ldx vert_{axis}i,y\n lda {axis}coord,x\n asl\n lda #0\n sbc #0\n eor #255\n sta hc_ext\n'
            vertex+=f' lda hc_origin_{axis}\n sta hc_cam_{axis}0,y\n clc\n lda hc_origin_{axis}+1\n adc {axis}coord,x\n sta hc_cam_{axis}1,y\n sta {cache},y\n sta v{axis}rawlo,y\n'
            vertex+=f' lda hc_origin_{axis}+2\n adc hc_ext\n sta hc_cam_{axis}2,y\n sta v{axis}rawhi,y\n'
            if axis=='z':vertex+=' sta szhi,y\n'
        vertex+=' inc hp_idx\n lda hp_idx\n cmp active_vend\n bne hc_vertex_loop\n rts\n'
        v=parts['vertices'];parts['vertices']=v[:v.index('hp_build_vertices:')]+vertex
        parts['terms']='hp_prepare_terms:\n rts\n'
        parts['data'],removed=re.subn(r'(?m)^hp_term\d\d_(?:lo|hi): \.fill [XYZ]COORD_COUNT,0\n','',parts['data'])
        if not removed and placed is None:raise ValueError('Static term metadata changed')
        # Fail closed if a removed table ever acquires a live consumer.
        assert not re.search(r'\bhp_term\d\d_(?:lo|hi)\b','\n'.join(parts.values()))
        # Five static no-op entry points share one RTS. This also avoids five
        # separate 32-byte allocation guards; no runtime algorithm is changed.
        parts['matrix']='hp_prepare_matrix:\nhp_prepare_trig:\nhp_prepare_terms:\nqc_trig_z:\nqc_trig_y:\n rts\n'
        for name in ('trig','terms','camera_trig_z','camera_trig_y'):parts.pop(name)
        if 'winding_math' in parts:parts['winding']+=parts.pop('winding_math')
        for name in ('full_projection','matrix'):
            if name in parts:parts['core']+=parts.pop(name)
        for name in ('camera_pitch','camera_math'):
            if name in parts:parts['camera_yaw']+=parts.pop(name)
        # Diagnostics count complete publications, not redraws or host time.
        if globals().get('dynamic_objects',False):
            # PRIVATE scene: restore the native Q8 object transform for the
            # rotating torus. Static-identity specialization is invalid here.
            parts.clear();parts.update(dynamic_parts)
        # Demo-specific compact Q8 transform only for the central torus.
        # Static room identity paths stay byte-for-byte identical.
        from cube_runtime import adapt_vertices
        parts=adapt_vertices(parts)
        parts['camera_demo']+='''demo_count_frame:
 inc demo_frames
 bne +
 inc demo_frames+1
+
 rts
demo_count_refresh:
 inc demo_refreshes
 bne +
 inc demo_refreshes+1
+
 rts
demo_frames: .word 0
demo_refreshes: .word 0
'''
        source=source.replace('fps_frame_done:\n','fps_frame_done:\n jsr demo_count_frame\n')
        source=source.replace(' inc sim_vblank_count\n',' inc sim_vblank_count\n jsr demo_count_refresh\n')
        source=source.replace(' jsr init_irq\n',' jsr qc_demo_tick\n jsr init_irq\n')
        if not args.silent:
            code,score=music_parts();parts['demo_music_code']=code;parts['demo_music_tables']=score
            source=source.replace(' jsr init_irq\n',' jsr gs_sid_init\n jsr init_irq\n')
            source=source.replace(' inc sim_vblank_count\n',' inc sim_vblank_count\n jsr gs_sid_play\n')
        source,parts=render_adapter(source,parts,placed)
        result=attach(source,parts,placed)
        return post_attach_adapter(result) if 'post_attach_adapter' in globals() else result
    module.attach=demo_attach
    if hasattr(sys.modules.get('__main__'),'block_enabled') and sys.modules['__main__'].block_enabled:
        from block4 import pack
        module.pack=pack # demo only, final assembler block-overflow checks retained
    out=ROOT/'build'/args.name
    module.build(out,scene,standard=getattr(sys.modules['__main__'],'standard','pal'),mode=7,camera_auto=True)
    info=json.loads((out/'build.json').read_text())
    info.update(music=not args.silent,demoOnlySpecialization='static identity objects and baked static vertex lighting; mobile Q8 camera unchanged',
                demoCamera=dict(keyframes=64,ticksPerKey=16,periodTicks=1024,walkingBob=True),
                publicProfileExtension='Demo-only SID, focal 85 and static vertex light; not the silent public Q8 contract',demoFocal=85)
    (out/'build.json').write_text(json.dumps(info,indent=2))
    after=verify_release();assert after==identity
    report=dict(release=identity,geometry=stats,precision='q8',lighting='gouraud',compositor='C',originalTextures=True,
                music=not args.silent,prgSHA256=sha(out/'3Dvibe64.prg'),prgBytes=(out/'3Dvibe64.prg').stat().st_size,
                cameraTicks=1024,engineModified=False,staticVertexLighting=True)
    (ROOT/'reports'/f'{args.name}-build.json').write_text(json.dumps(report,indent=2))
    print(json.dumps(report,indent=2))

if __name__=='__main__':main()
