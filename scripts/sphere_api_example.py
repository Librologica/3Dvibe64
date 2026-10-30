"""Build an external source-only usage example; never write build products into SDK.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,hashlib,json,os,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def application():
    # This is caller-owned scene/order/palette policy, not part of the engine.
    spheres=[dict(position=[0,10,55],radius=12,fill=170,layer=0),dict(position=[-18,10,10],radius=4,fill=85,layer=1),
             dict(position=[20,14,24],radius=6,fill=170,layer=1),dict(position=[-25,22,58],radius=3,fill=85,layer=0)]
    code='''sphere_example_render:
 lda sphere_example_enabled
 beq sphere_example_mesh_only
 jsr er_sphere_begin_view
 lda #0
 sta sphere_example_layer
 jsr sphere_example_group
 jsr draw_depth_buckets
 lda #1
 sta sphere_example_layer
 jsr sphere_example_group
 jmp sphere_example_update
sphere_example_mesh_only:
 jsr draw_depth_buckets
sphere_example_update:
 inc sphere_example_tick
 clc
 lda sphere_example_offset
 adc sphere_example_step
 sta sphere_example_offset
 lda sphere_example_offset+1
 adc sphere_example_step+1
 sta sphere_example_offset+1
 cmp #4
 bne sphere_example_low_endpoint
 lda sphere_example_offset
 bne sphere_example_return
 lda #$c0
 sta sphere_example_step
 lda #$ff
 sta sphere_example_step+1
 rts
sphere_example_low_endpoint:
 cmp #$fc
 bne sphere_example_return
 lda sphere_example_offset
 bne sphere_example_return
 lda #64
 sta sphere_example_step
 lda #0
 sta sphere_example_step+1
sphere_example_return:
 rts
sphere_example_group:
 lda #0
 sta sphere_example_index
 sta sphere_example_sign
 lda sphere_example_offset+1
 bpl +
 lda #255
 sta sphere_example_sign
+
sphere_example_loop:
 ldx sphere_example_index
 lda sphere_example_layers,x
 cmp sphere_example_layer
 bne sphere_example_next
 clc
 lda sphere_example_x0,x
 adc sphere_example_offset
 sta er_sphere_world_x
 lda sphere_example_x1,x
 adc sphere_example_offset+1
 sta er_sphere_world_x+1
 lda sphere_example_x2,x
 adc sphere_example_sign
 sta er_sphere_world_x+2
'''
    for axis in 'yz':
        for byte in range(3):code+=f' lda sphere_example_{axis}{byte},x\n sta er_sphere_world_{axis}'+('' if byte==0 else '+'+str(byte))+'\n'
    code+=''' lda sphere_example_radius_lo,x
 sta er_sphere_radius
 lda sphere_example_radius_hi,x
 sta er_sphere_radius+1
 lda sphere_example_fills,x
 sta fillbyte
 lda #$13
 sta material_screen_cur
 lda #6
 sta material_color_cur
 jsr er_sphere_draw_world
sphere_example_next:
 inc sphere_example_index
 lda sphere_example_index
 cmp #4
 bne sphere_example_loop
 rts
sphere_example_enabled: .byte 1
sphere_example_tick: .byte 0
sphere_example_layer: .byte 0
sphere_example_index: .byte 0
sphere_example_sign: .byte 0
sphere_example_offset: .word $fc00
sphere_example_step: .word 64
'''
    def data(name,values):return name+': .byte '+','.join(str(v&255) for v in values)+'\n'
    for axis,j in zip('xyz',range(3)):
        for byte in range(3):code+=data(f'sphere_example_{axis}{byte}',[(p['position'][j]*256>>(byte*8))&255 for p in spheres])
    for name,values in [('layers',[p['layer'] for p in spheres]),('fills',[p['fill'] for p in spheres]),('radius_lo',[p['radius']*16 for p in spheres]),('radius_hi',[p['radius']*16>>8 for p in spheres])]:code+=data('sphere_example_'+name,values)
    return code,spheres


def compact_application():
    # Mode6 has less free RAM. Two unrolled caller descriptors demonstrate
    # the same world API without widening any allocator window.
    spheres=[dict(position=[0,10,55],radius=12,fill=170,layer=0),dict(position=[-18,10,10],radius=4,fill=85,layer=1)]
    code='''sphere_example_render:
 lda sphere_example_enabled
 bne sphere_example_active
 jmp draw_depth_buckets
sphere_example_active:
 jsr er_sphere_begin_view
 inc sphere_example_tick
'''
    for i,sphere in enumerate(spheres):
        if i:code+=' jsr draw_depth_buckets\n'
        for axis,position in zip('xyz',sphere['position']):
            for byte in range(3):code+=f' lda #{((position*256)>>(byte*8))&255}\n sta er_sphere_world_{axis}'+('' if byte==0 else '+'+str(byte))+'\n'
        code+=' lda sphere_example_tick\n and #63\n asl\n asl\n sta er_sphere_world_x\n'
        radius=sphere['radius']*16
        code+=f''' lda #{radius&255}
 sta er_sphere_radius
 lda #{radius>>8}
 sta er_sphere_radius+1
 lda #{sphere['fill']}
 sta fillbyte
 lda #$13
 sta material_screen_cur
 lda #6
 sta material_color_cur
 jsr er_sphere_draw_world
'''
    code+=' rts\nsphere_example_enabled: .byte 1\nsphere_example_tick: .byte 0\n'
    return code,spheres


def main():
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--mode',type=int,choices=(4,6),default=4);p.add_argument('--assembler',type=Path,default=os.environ.get('TASS64_EXE'));args=p.parse_args()
    out=args.out.resolve();assert not out.is_relative_to(ROOT),'Example outputs must stay outside SDK'
    assert not out.exists(),'Choose a new output directory';out.mkdir(parents=True)
    assert args.assembler and args.assembler.is_file(),'Set TASS64_EXE or --assembler'
    sdk=out/'sdk';sdk.mkdir()
    names=[line.partition('  ')[2] for line in (ROOT/'MANIFEST.sha256').read_text().splitlines() if '  ' in line]+['MANIFEST.sha256']
    names+=['work/sphere_impostors.py','work/sphere_impostors.asm']
    for name in sorted(set(names)):
        dest=sdk/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(ROOT/name,dest)
    vertices=[[-8,-8,-8],[8,-8,-8],[8,8,-8],[-8,8,-8],[-8,-8,8],[8,-8,8],[8,8,8],[-8,8,8]]
    faces=[[0,3,2,1],[4,5,6,7],[0,1,5,4],[3,7,6,2],[0,4,7,3],[1,2,6,5]]
    scene=dict(schema=1,name='General circle-sphere API: floating orbs and opaque cube',axisConvention='world-z-up',world=dict(backgroundColor=0),
        camera=dict(id='camera',mode='walkLite',position=[0,-45,10],rotation=[0,0,0]),lights=[dict(id='fixed',type='static',mode='static',position=[-20,-20,60],intensity=10)],
        meshes=[dict(id='cube',type='mesh',vertices=vertices,faces=faces,faceOverrides={str(i):dict(solidColor=6,shading=False) for i in range(6)})],
        objects=[dict(id='cube',mesh='cube',position=[0,35,10],rotation=[0,0,0],angularVelocity=[0,0,0],scale=1,material='blue',reflectivity=0)])
    scene_path=out/'scene.json';scene_path.write_text(json.dumps(scene,indent=2)+'\n')
    env=os.environ.copy();env['TASS64_EXE']=str(args.assembler.resolve());env['PYTHONDONTWRITEBYTECODE']='1'
    cmd=['pwsh','-NoProfile','-File',str(sdk/'work/build-3Dvibe64.ps1'),'-SceneFile',str(scene_path),'-Precision','legacy-plus','-GraphicsMode',str(args.mode),'-Quality','fast','-Projection','extended-table','-MemoryLayout','high-basic-v2','-CameraMode','walkLite','-CameraViewport','normal','-VideoStandard','pal','-NoFpsOverlay','-StaticPose','-SkipCmdUpdate','-SphereRenderer','circles']
    (out/'build-command.json').write_text(json.dumps(cmd,indent=2)+'\n')
    with (out/'build.log').open('w') as log:result=subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT)
    assert result.returncode==0,'See build.log'
    sys.path.insert(0,str(sdk/'work'))
    from legacy_plus_memory import allocate
    from legacy_plus_exact import block
    source=(sdk/'work/3Dvibe64.asm').read_text(encoding='utf-8-sig')
    source=source.replace(' jsr draw_depth_buckets\n',' jsr sphere_example_render\n')
    # The caller selects one common four-color palette for this mixed scene.
    # Native cube slot11 stays blue6; the API draws white01 and cyan10.
    a=source.index('load_face_solid_color_y:\n');b=source.index('lfsc_default:\n',a)
    chunk=source[a:b];assert chunk.count(' lda #$00\n.endif\n sta material_screen_cur')==1
    source=source[:a]+chunk.replace(' lda #$00\n.endif\n sta material_screen_cur',' lda #$13\n.endif\n sta material_screen_cur')+source[b:]
    app,spheres=application() if args.mode==4 else compact_application();(out/'application.asm').write_text(app,encoding='ascii');(out/'spheres.json').write_text(json.dumps(spheres,indent=2)+'\n')
    source=allocate(source+block('sphere_example',app),str(args.assembler.resolve()),out/'placement')
    asm=out/'sphere-example.asm';asm.write_text(source,encoding='ascii')
    def assemble(text,stem):
        path=out/(stem+'.asm');path.write_text(text,encoding='ascii')
        cmd=[str(args.assembler.resolve()),'-a','-B','--vice-labels-numeric','--labels='+str(out/(stem+'.labels')),'-o',str(out/(stem+'.prg')),str(path)]
        result=subprocess.run(cmd,capture_output=True,text=True);(out/(stem+'.build.log')).write_text(result.stdout+result.stderr);assert result.returncode==0,result.stdout+result.stderr
    assemble(source,'sphere-example');assert source.count('sphere_example_enabled: .byte 1')==1
    assemble(source.replace('sphere_example_enabled: .byte 1','sphere_example_enabled: .byte 0'),'sphere-control')
    (out/'launch.ps1').write_text('''param([ValidateSet(1,20,64)][int]$Multiplier=64,[switch]$Control,[switch]$PrintCommand)
$vice='C:\\Users\\rapso\\Documents\\ChatGPT\\VICE Fork\\vice-turbo6510\\dist\\Turbo6510-x64sc\\bin\\x64sc_u.exe'
$prg=Join-Path $PSScriptRoot $(if($Control){'sphere-control.prg'}else{'sphere-example.prg'})
$argsList=@('-default','+confirmonexit','+warp','-pal','-turbo6510',"$Multiplier",'-sound','-autostartprgmode','1','-VICIIfilter','0',$prg)
if($PrintCommand){@{executable=$vice;arguments=$argsList}|ConvertTo-Json -Depth 3;exit 0}
$quoted=@($argsList|ForEach-Object{if($_ -match '\\s'){'"'+$_+'"'}else{$_}})
Start-Process -FilePath $vice -ArgumentList $quoted -WorkingDirectory (Split-Path -Parent $vice)
''',encoding='utf-8')
    (out/'launch-demo.cmd').write_text('@echo off\r\npowershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0launch.ps1"\r\n')
    report=dict(mode=args.mode,engineSphereAPI=True,sceneSpecificEngineCode=False,callerOwnedPaletteAndLayers=True,worldPositionsNativeAxis='X,Y-up,Z-forward',orbs=spheres,motion='Triangle X offset±4WU,0.25WU per rendered view,64-view period' if args.mode==4 else 'Fractional world X offset0..63/64WU,64-view period',nativeMaterials=dict(screen=19,colorRAM=6,background=0),enabledPRGSHA256=hashlib.sha256((out/'sphere-example.prg').read_bytes()).hexdigest(),controlPRGSHA256=hashlib.sha256((out/'sphere-control.prg').read_bytes()).hexdigest(),control='Same code and data; only initial enabled byte differs')
    (out/'BUILD.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))

if __name__=='__main__':main()
