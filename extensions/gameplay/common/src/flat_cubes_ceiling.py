"""Property-derived static cube flat shading and black ceiling checker.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Private demo only.
"""
import json,math
from pathlib import Path
import optimizations as op
ROOT=Path(__file__).resolve().parents[1]

def classify(scene):
    ranges=json.loads((ROOT/'reports/scene.json').read_text())['ranges']
    codes=[];planes=[];ceilings=[]
    for oi,(obj,mesh) in enumerate(zip(scene['objects'],scene['meshes'])):
        if oi==3:codes += [254]*len(mesh['faces']);continue
        first=ranges[oi]['first'];cube_first=ranges[oi]['cubeFirst']-first
        groups={}
        for fi in range(cube_first,len(mesh['faces'])):
            pts=[mesh['vertices'][v] for v in mesh['faces'][fi]]
            axes=[axis for axis in range(3) if len({p[axis] for p in pts})==1]
            assert len(axes)==1,('nonplanar cube face',oi,fi)
            axis=axes[0];groups.setdefault((axis,pts[0][axis]),[]).append(fi)
        local=[255]*len(mesh['faces'])
        for (axis,coord),ids in groups.items():
            vertices={tuple(mesh['vertices'][v]) for fi in ids for v in mesh['faces'][fi]}
            c=[(min(p[a] for p in vertices)+max(p[a] for p in vertices))/2 for a in range(3)]
            p,q,r=[mesh['vertices'][v] for v in mesh['faces'][ids[0]]]
            u=[q[a]-p[a] for a in range(3)];v=[r[a]-p[a] for a in range(3)]
            n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
            world=[c[0]+obj['position'][0],c[1]+obj['position'][2],c[2]+obj['position'][1]]
            lamp=[-12,12,(0,48,160)[oi]+16]
            d=[lamp[a]-world[a] for a in range(3)]
            cosine=max(0,sum(n[a]*d[a] for a in range(3))/math.sqrt(sum(t*t for t in n)*sum(t*t for t in d)))
            code=0 if cosine<.2 else 4 if cosine>=.65 else 2
            for fi in ids:local[fi]=code
            planes.append(dict(object=oi,faces=[first+i for i in ids],axis=axis,plane=coord,
                centerWorld=world,lampWorld=lamp,cosine=cosine,flatCode=code))
        for fi,face in enumerate(mesh['faces'][:cube_first]):
            ys={mesh['vertices'][v][1]+obj['position'][2] for v in face}
            if ys=={18}:
                assert mesh['faceTextures'][fi]=='plain-ceiling'
                local[fi]=253;ceilings.append(first+fi)
        codes+=local
    assert len(codes)==119 and len(planes)==10 and len(ceilings)==10
    assert sum(c<6 for c in codes)==21
    return codes,dict(staticCubePlanes=planes,ceilingFaces=ceilings,
        kinds={'253':'ceiling far-LOD fill','254':'rotating flat cube','255':'unlit room'},
        ceilingPattern='shared lg_far_sample: modal gray 2 (75%) + highlight 3 (25%)',
        ceilingPhysicalMotif=[4,8],ceilingModal=2,ceilingAccent=3,fadeNear=14,fadeFar=22)

def hooks(source,scene):
    codes,report=classify(scene)
    (ROOT/'reports/surface-contract.json').write_text(json.dumps(report,indent=2))
    source=op.once(source,'fc_finish_bounds:\n lda sortj\n','''fc_finish_bounds:
 ldy sortj
 lda sc_face_codes,y
 cmp #6
 bcs sc_nonstatic
 sta fc_code
 jmp sc_inclusive_setup
sc_nonstatic:
 lda sortj
''')
    source=op.once(source,' sta fc_code\n ldx face_ymin\nfc_inclusive:\n',
        ' sta fc_code\nsc_inclusive_setup:\n ldx face_ymin\nfc_inclusive:\n')
    # Y is the original face id at op_uniform_select; lg_select preserves it
    # for a truly uniform texture. Patch only between faces, outside IRQ.
    source=op.once(source,'lg_bind_uniform:\n sta iu_sample_uniform+1\n lda lg_weight\n','''lg_bind_uniform:
 sta iu_sample_uniform+1
 lda sc_face_codes,y
 cmp #253
 bne sc_uniform_original
 lda #2
 sta lg_modal
 lda #3
 sta lg_accent
 lda #<sc_ceiling_sample
 sta iu_sample_uniform+3
 lda #>sc_ceiling_sample
 sta iu_sample_uniform+4
 ldx lg_texture
 lda op_uniform
 rts
sc_uniform_original:
 lda lg_weight
''')
    source+='''\n*=$4000
sc_ceiling_sample:
 ; Exactly the same renderer and phase as far-LOD surfaces. Only the
 ; ceiling pigments differ: gray base and light-gray accent, no black.
 jmp lg_far_sample
sc_face_codes:
 .byte '''+','.join(map(str,codes))+'\n'
    return source
