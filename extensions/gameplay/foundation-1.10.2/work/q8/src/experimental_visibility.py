"""Conservative pre-transform object visibility and exact duplicate-face overdraw.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import math
from camera import copy
from perspective_exact import once

def apply(source,parts,ranges,lab,byte):
    if lab['GRAPHICS_MODE']<3:raise ValueError('ENGINE_VISIBILITY: polygon Modes3..7 required')
    mobile='camera_yaw' in parts
    if mobile:
        yaw=parts['camera_yaw'];a=yaw.index('qc_rotate_active:\n')+len('qc_rotate_active:\n');b=yaw.index('qc_vertex:\n')
        prep=yaw[a:b];i=prep.index(' sta qc_index\n')
        # The immediately preceding LDA loads the vertex first index.
        i=prep.rfind(' lda ',0,i);vertex_init=prep[i:];prep=prep[:i]+' rts\n'
        point_start=yaw.index(' lda explorer_cam_yaw\n',b)
        first=yaw[point_start:].replace(' jmp qc_pitch\n',' jmp ev_point_pitch\n')
        pitch=parts['camera_pitch'];end=pitch.index('qc_store:\n')
        second=pitch[:end].replace('qc_pitch:','ev_point_pitch:').replace('beq qc_store','beq ev_point_done')
        first=first.replace('beq qc_pitch','beq ev_point_pitch')
        parts['camera_yaw']=yaw[:a]+' jsr ev_prepare_camera\n'+vertex_init+yaw[b:point_start]+' jsr ev_rotate_point\n jmp qc_store\n'
        parts['camera_pitch']=pitch[end:]
        parts['visibility_camera']='ev_prepare_camera:\n'+prep+'ev_rotate_point:\n'+first+second+'ev_point_done:\n rts\n'
    code='ev_object_visible:\n jsr hp_origins\n bcs ev_origin_ok\n sec\n rts\nev_origin_ok:\n'
    if mobile:
        code+=' jsr ev_prepare_camera\n'
        if 'camera_tables' in parts:code+=' jsr qt_update\n'
        for ax in 'xyz':code+=copy('hc_origin_'+ax,'qc_'+ax)
        code+=' jsr ev_rotate_point\n'
        for ax in 'xyz':code+=copy('qc_'+ax,'ev_'+ax)
    else:
        for ax in 'xyz':code+=copy('hc_origin_'+ax,'ev_'+ax)
    # Radius inflated for matrix/trig/rounding. Wider-than-viewport 45deg cone.
    code+=' ldx objidx\n clc\n lda ev_z+1\n adc ev_radius,x\n lda ev_z+2\n adc #0\n bmi ev_reject\n'
    for ax in 'xy':
        code+=copy('ev_'+ax,'ev_abs')+f' lda ev_abs+2\n bpl ev_abs_{ax}\n sec\n'
        for j in range(3):code+=f' lda #0\n sbc ev_abs+{j}\n sta ev_abs+{j}\n'
        code+=f'ev_abs_{ax}:\n sec\n'
        for j in range(3):code+=f' lda ev_abs+{j}\n sbc ev_z+{j}\n sta ev_abs+{j}\n'
        code+=' ldx objidx\n sec\n lda ev_abs+1\n sbc ev_radius2_lo,x\n sta ev_abs+1\n lda ev_abs+2\n sbc ev_radius2_hi,x\n'
        code+=f' bmi ev_keep_{ax}\n bne ev_reject\n lda ev_abs+1\n bne ev_reject\nev_keep_{ax}:\n'
    code+=' sec\n rts\nev_reject:\n clc\n rts\n'
    parts['visibility']=code
    radii=[math.ceil(o['radiusWU'])*(4 if mobile else 2)+8 for o in ranges]
    parts['data']+=''.join(f'ev_{n}: .fill 3,0\n' for n in ['x','y','z','abs'])
    for name,values in [('ev_radius',radii),('ev_radius2_lo',[v*2&255 for v in radii]),('ev_radius2_hi',[v*2>>8 for v in radii])]:
        parts['data']+=name+': .byte '+','.join(map(str,values))+'\n'
    source=once(source,'resp_loop:\n','resp_loop:\n jsr ev_object_visible\n bcc resp_next_object\n')
    # Exact duplicates only, preserving winding, UV, material, and face shade.
    keep=[1]*lab['FACE_COUNT'];removed=[]
    fields=['face_vertex_count','face0','face1','face2','face3','face_color','face_material','face_texture','face_flags','face_shade','face_reflect_offset']
    fields=[n for n in fields if n in lab]
    # Mode7 face UV data is richer; disable dedup until its full ABI is known.
    if lab['GRAPHICS_MODE'] in (3,4,5,6):
        for obj in ranges:
            seen={}
            for f in range(obj['faceFirst'],obj['faceEnd']):
                key=tuple(byte(n,f) for n in fields)
                if key in seen:keep[f]=0;removed.append(f)
                else:seen[key]=f
    if removed:
        source=once(source,'dm_collect_loop:\n','dm_collect_loop:\n ldy faceidx\n lda ev_face_keep,y\n beq dm_skip\n')
        parts['data']+='ev_face_keep: .byte '+','.join(map(str,keep))+'\n'
    return source,dict(volume='inflated sphere in conservative45deg cone; near-crossing retained',
        radiusWU=radii,duplicateFacesRemoved=removed,overdraw='exact same-object opaque face duplicates; Mode7 retains all faces',
        camera='shared exact yaw/pitch product rounding' if mobile else 'stationary')
