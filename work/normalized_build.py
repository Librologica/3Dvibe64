"""Experimental Normalized16 geometry; no implicit replacement of legacy/Q8.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0.
"""
import argparse,json,re,sys
from pathlib import Path

ROOT=Path(__file__).resolve().parent
sys.path[:0]=[str(ROOT/'q8'),str(ROOT/'q8/src')]
from build import build as q8_build,validate as q8_validate
from normalized import make_parts

def validate(spec,mode,standard,out):
    q8_validate(spec,mode,standard,Path(out).resolve())
    if spec.get('texturePrecision','affine')!='affine' or spec.get('textureQuality','standard')!='standard' or spec.get('textureLOD','off')!='off':
        raise ValueError('NORMALIZED_PROFILE: Mode7 affine only; perspective/fast/LOD remain Q8')
    if any(k in spec for k in ('textureLODNear','textureLODFar')):
        raise ValueError('NORMALIZED_PROFILE: no LOD distances')
    if mode==4:
        # The proven Mode4 loader has four corners. Do not silently reinterpret
        # triangles: use the Q8 exporter for such scenes until separately tested.
        for mesh in spec.get('meshes',[]):
            if mesh.get('builtin')!='cube' and (not mesh.get('faces') or any(len(face)!=4 for face in mesh['faces'])):
                raise ValueError('NORMALIZED_MODE4: four-corner faces required')

def adapter(source,parts,lab):
    lab=dict(lab)
    if lab['VERT_COUNT']>16:
        raise ValueError('NORMALIZED_VERTEX_BUDGET: this experimental qualification covers at most 16 runtime vertices')
    lab.setdefault('CAMERA_FACE_MIN_DEPTH',lab.get('PROJ_CAMERA_FACE_MIN_DEPTH',8))
    # The camera adapter splits hp_prepare_matrix's OBJECT-angle trig tails
    # into these fragments. They are not the old per-vertex camera rotation.
    tails={name:parts[name] for name in ('camera_trig_y','camera_trig_z') if name in parts}
    result=make_parts(parts,lab)
    result.update(tails)
    if lab['GRAPHICS_MODE']>=6:
        code='\n'.join(s for n,s in result.items() if n!='data')+'\n'+source
        code='\n'.join(line.split(';',1)[0] for line in code.splitlines())
        def retire(m):
            return m[0] if re.search(r'\b'+re.escape(m[1])+r'\b',code) else ''
        result['data']=re.sub(r'(?m)^(\w+): \.(?:fill|byte|word) [^\n]*\n',retire,result['data'])
        names=('normalized_matrix','normalized_vertices','normalized_math','normalized_planes','normalized_intersection','projection','nf_attributes')
        result['nf_geometry']=''.join(result.pop(n) for n in names)
        # One protected placement for cooperating face-ABI helpers, not five
        # artificial 32-byte inter-fragment guards. The assembler still guards
        # the combined executable region; instructions/state are unchanged.
        names=('clip_helpers','winding','winding_math','winding_multiply')
        result['nf_face_abi']=''.join(result.pop(n) for n in names if n in result)
    return source,result

def build(out,scene,mode,standard='pal',camera='stationary',frame_presentation='safe'):
    if camera not in ('stationary','interactive'):
        raise ValueError('NORMALIZED_CAMERA: stationary or interactive only')
    if frame_presentation not in ('safe','legacy'):
        raise ValueError('NORMALIZED_PRESENTATION: safe or legacy only')
    spec=json.loads(Path(scene).read_text(encoding='utf-8-sig'))
    validate(spec,mode,standard,out)
    # An explicit independent adapter. Unselected Q8 code generation is unchanged.
    output=q8_build(out,scene,mode=mode,standard=standard,camera_mobile=camera!='stationary',camera_auto=camera=='auto',frame_presentation=frame_presentation,geometry_adapter=adapter)
    path=output/'build.json';meta=json.loads(path.read_text())
    meta.update(precision='normalized16',experimental=True,geometryFormat='signed16, unit 2^e/16 WU, e0..4',
                rasterFormat='Q2',texturePrecision='affine' if mode==7 else None,
                publicScope='bounded mesh profile; not private shuttle adapter',
                recommendation='Opt-in experiment; legacy default and Q8 precise path retained')
    path.write_text(json.dumps(meta,indent=2))
    return output

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True);p.add_argument('--scene',type=Path,required=True)
    p.add_argument('--mode',type=int,required=True);p.add_argument('--standard',choices=['pal','ntsc'],default='pal')
    p.add_argument('--camera',choices=['stationary','interactive'],default='stationary')
    p.add_argument('--frame-presentation',choices=['safe','legacy'],default='safe');a=p.parse_args()
    try:build(a.out,a.scene,a.mode,a.standard,a.camera,a.frame_presentation)
    except (ValueError,KeyError,TypeError) as e:raise SystemExit(f'Normalized16 build refused: {e}')
