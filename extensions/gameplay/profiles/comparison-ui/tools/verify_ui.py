"""Native viewport confinement, original UI, precise sampling and active LOD."""
import json,re,shutil,subprocess,sys
from pathlib import Path
from native_compare import ROOT,paths,run,sha

def check_frame(ram,color,labels,tag):
    bitmap=(ROOT/'reference/ui-bitmap.bin').read_bytes()
    screen=(ROOT/'reference/ui-screen.bin').read_bytes()
    palette=(ROOT/'reference/ui-color.bin').read_bytes()
    outside=[i for i in range(1000) if not(6<=i%40<30 and 1<=i//40<16)]
    assert len(outside)==640 and len(color)==1000
    for base in (0x2000,0x6000):
        assert all(ram[base+i*8:base+i*8+8]==bitmap[i*8:i*8+8] for i in outside),(tag,'UI bitmap changed',base)
    for base in (0x400,0x5c00):
        assert all(ram[base+i]==screen[i] for i in outside),(tag,'UI screen changed',base)
    assert all((color[i]&15)==palette[i] for i in outside),(tag,'UI ColorRAM changed')
    for name in ('hp_fault','ps_fault','xyq2_faulted'):assert ram[labels[name]]==0,(tag,name)
    assert ram[labels['bk_count']]==0,(tag,'perspective batch activated')
    return dict(tag=tag,unchangedUIBitmapBytes=10240,unchangedUIScreenBytes=1280,
                unchangedUIColorCells=640,exactSamplerBatchCount=0,LODWeight=ram[labels['lg_weight']])

def lod_trace(build):
    b,prg,l=paths(build);stem=ROOT/'reports/lod-trace/mid-band'
    cmds=[f'logname "{stem}.monitor.log"','log on',f'load_labels "{b/"3Dvibe64.labels"}"',
          'break exec .render_frame_begin','x',f'> ${l["advance_sim_tick"]:04x} 60']
    for axis,value in zip('xyz',(0,0,-18*256)):
        for suffix,v in [('lo',value&255),('hi',value>>8&255),('ext',255 if value<0 else 0)]:
            cmds.append(f'> ${l["explorer_cam_"+axis+"_"+suffix]:04x} {v:02x}')
    for axis in ('yaw','pitch'):
        cmds += [f'> ${l["explorer_cam_"+axis]:04x} 00',f'> ${l["qc_demo_"+axis+"_lo"]:04x} 00']
    cmds+=['ignore 1 2','x','disable 1','trace exec .lg_set_weight','break exec .fps_frame_done','x','quit']
    info=run(prg,stem,cmds);text=Path(str(stem)+'.monitor.log').read_text()
    values=[int(v,16) for v in re.findall(r'\.C:'+f'{l["lg_set_weight"]:04x}'+r'[^\n]*A:([0-9a-f]{2})',text,re.I)]
    assert 0 in values and 16 in values and any(0<v<16 for v in values),sorted(set(values))
    info.update(result='PASS',nativeLODWeights=sorted(set(values)),calls=len(values),
                camera=[0,0,-18,0,0],meaning='0 far material;1..15 blend;16 full texture')
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2))
    return sorted(set(values))

def main():
    build='ui-outline';b,prg,l=paths(build);asm=(b/'3Dvibe64.asm').read_text()
    metadata=json.loads((b/'build.json').read_text())
    assert metadata['bitmapInterface'] and metadata['viewportLogical']==[96,60]
    assert metadata['renderedRows']==60 and metadata['perspectiveBlock']==1
    assert metadata['textureLOD']=={'fadeNear':14,'fadeFar':22}
    assert l['PROJ_SCREEN_MAX_X']==95 and l['PROJ_SCREEN_MAX_Y']==59
    assert l['VIEWPORT_ROW_CAPACITY']==60
    assert 'ps_sample:\n jmp bk_exact_sample\n' in asm and 'ps_advance:\n jmp bk_exact_advance\n' in asm
    assert all(name not in asm for name in ('sp_filter_row:','sp_render_and_fill:','lg_lod_select_disabled:'))
    assert 'cmp #96\n bcs wr_plot_return' in asm and 'cmp #60\n bcs wr_plot_return' in asm
    assert 'cmp #95\n beq wr_plot_return' in asm
    assert 'cmp #96\n bcs bb_plot_done' in asm and 'cmp #60\n bcs bb_plot_done' in asm
    for name in ('large-room.json','camera-keyframes.json'):
        assert json.loads((ROOT/'room/scenes'/name).read_text())==json.loads((ROOT/'reference'/name).read_text()),name
    for name in ('ui-bitmap.bin','ui-screen.bin','ui-color.bin'):
        assert (ROOT/'assets'/name).read_bytes()==(ROOT/'reference'/name).read_bytes(),name
    views=[]
    for tag in [f'view{k:02}' for k in range(0,48,6)]+['clip-right','clip-left','clip-top','clip-bottom']:
        stem=ROOT/f'reports/views/{build}-{tag}'
        info=json.loads(stem.with_suffix('.json').read_text())
        assert info['decodedFrameMatches']
        views.append(check_frame(stem.with_suffix('.ram').read_bytes()[2:],Path(str(stem)+'.color.ram').read_bytes()[2:],l,tag))
    previous=json.loads((ROOT/'reference/previous-demo-sha256.json').read_text())
    for name,digest in previous['files'].items():assert sha(Path(previous['root'])/name)==digest,('Previous demo modified',name)
    ui=json.loads((ROOT/'reference/ui-source.json').read_text())
    for name,digest in ui['files'].items():assert sha(Path(ui['root'])/name)==digest,('UI donor modified',name)
    for line in (ROOT/'sdk/MANIFEST.sha256').read_text().splitlines():
        digest,name=line.split('  ',1);assert sha(ROOT/'sdk'/name)==digest,name
    weights=lod_trace(build)
    portable=ROOT/'verification/portable';assert not portable.exists();portable.mkdir(parents=True)
    for name in ('src','sdk','private','assets'):shutil.copytree(ROOT/name,portable/name,ignore=shutil.ignore_patterns('__pycache__'))
    shutil.copy2(ROOT/'build_demo.py',portable/'build_demo.py')
    for name in ('room','room/scenes','room/reports','reports','artifacts'):(portable/name).mkdir(exist_ok=True)
    cmd=[sys.executable,'-B','build_demo.py','--precise','--name','portable-ui','--artifact-tag','portable-ui']
    result=subprocess.run(cmd,cwd=portable,capture_output=True,timeout=300)
    (ROOT/'reports/portable-build.log').write_bytes(result.stdout+result.stderr)
    assert result.returncode==0,result.stderr.decode(errors='replace')[-3000:]
    assert (portable/'artifacts/room-skeleton-billboard-precise-pal-portable-ui.prg').read_bytes()==prg.read_bytes()
    report=dict(result='PASS',interfaceOriginalPixels=True,viewportPhysical=[192,120],viewportOrigin=[48,8],
        preciseEveryPixel=True,renderedRows=60,verticalReconstruction=False,textureLOD=[14,22],
        nativeLODWeightsObserved=weights,sameScene=True,sameCamera=True,views=views,
        previousFilesUnchanged=len(previous['files']),UIDonorFilesUnchanged=len(ui['files']),
        SDKManifestUnchanged=True,Mode8Unchanged=True,portablePRGIdentical=True,portableCommand=cmd,
        finalPRGSHA256=sha(prg))
    (ROOT/'reports/delivery-qa.json').write_text(json.dumps(report,indent=2))
    print(json.dumps({k:v for k,v in report.items() if k!='views'},indent=2))

if __name__=='__main__':main()
