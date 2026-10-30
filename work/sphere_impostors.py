"""Optional scene-independent circle/sphere APIs for the native legacy-plus renderer.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,json,re
from pathlib import Path
from legacy_plus_exact import block,constant

HERE=Path(__file__).resolve().parent


def install(source):
    if 'ENGINE_CIRCLE_SPHERES = 1' in source:raise ValueError('SPHERE_API: already installed')
    for name,expected in [('CAMERA_WALK_LITE',1),('MEMORY_LAYOUT_HIGH_BASIC_V2',1),('FPS_OVERLAY_ENABLE',0),('PROJ_SCREEN_MAX_X',159),('PROJ_SCREEN_MAX_Y',99)]:
        if constant(source,name)!=expected:raise ValueError('SPHERE_PROFILE: requires legacy-plus walkLite normal/high-basic-v2/NoFpsOverlay')
    if constant(source,'GRAPHICS_MODE') not in (4,6) or 'LEGACY_PLUS_NEAR_SCREEN_Q4=1' not in source:
        raise ValueError('SPHERE_PROFILE: requires native legacy-plus Mode4 or Mode6')
    if not 1<=constant(source,'PROJ_FOCAL')<=255:raise ValueError('SPHERE_PROFILE: focal must fit one unsigned byte')
    # Copy only the engine's current view transform, not an application copy.
    start=source.index(' lda explorer_rel_x_lo\n sta p1lo\n lda explorer_rel_x_hi\n sta p1hi\n ldx #0\n jsr lr_mul_s16_q10\n',source.index('explorer_transform_project_vertices:\n'))
    end=source.index('etpv_engine_walk_pitch_done:\n',start)+len('etpv_engine_walk_pitch_done:\n')
    view=source[start:end]+'.endif\n'
    for label in ('etpv_engine_walk_pitch_apply','etpv_engine_walk_pitch_done'):view=view.replace(label,'er_sphere_'+label)
    world='''; Call once per view after editing camera angles, before world-space draws.
er_sphere_begin_view:
 jmp lr_prepare
er_sphere_draw_world:
 jsr er_sphere_world_to_camera
 bcc er_sphere_world_return
 jmp er_sphere_draw_camera
er_sphere_world_return:
 rts
er_sphere_world_to_camera:
 lda #0
 sta er_sphere_valid
'''
    for axis,lo,hi in [('x','explorer_rel_x_lo','explorer_rel_x_hi'),('y','explorer_rel_y_lo','explorer_rel_y_hi'),('z','rz1','explorer_z_hi16')]:
        world+=f''' sec
 lda er_sphere_world_{axis}
 sbc explorer_cam_{axis}_lo
 sta lc_fraction
 lda er_sphere_world_{axis}+1
 sbc explorer_cam_{axis}_hi
 sta p1lo
 lda er_sphere_world_{axis}+2
 sbc explorer_cam_{axis}_ext
 sta p1hi
 bvs er_sphere_world_reject
 bmi er_sphere_world_negative_{axis}
 cmp #4
 bcs er_sphere_world_reject
 bcc er_sphere_world_pack_{axis}
er_sphere_world_negative_{axis}:
 cmp #$fc
 bcc er_sphere_world_reject
er_sphere_world_pack_{axis}:
 jsr lc_pack_q4
 lda p1lo
 sta {lo}
 lda p1hi
 sta {hi}
'''
    world+=view+''' lda p1lo
 sta er_sphere_camera_z
 lda p1hi
 sta er_sphere_camera_z+1
 lda explorer_view_x_lo
 sta er_sphere_camera_x
 lda explorer_view_x_hi
 sta er_sphere_camera_x+1
 lda explorer_view_y_lo
 sta er_sphere_camera_y
 lda explorer_view_y_hi
 sta er_sphere_camera_y+1
 lda #0
 sta er_sphere_status
 sec
 rts
er_sphere_world_reject:
 lda #6
 sta er_sphere_status
 clc
 rts
er_sphere_world_x: .fill 3,0
er_sphere_world_y: .fill 3,0
er_sphere_world_z: .fill 3,0
'''
    text=(HERE/'sphere_impostors.asm').read_text(encoding='ascii')
    sections=re.split(r'(?m)^; SPHERE BLOCK (\w+)\n',text)
    assert len(sections)==7
    source='ENGINE_CIRCLE_SPHERES = 1\nER_SPHERE_MAX_RADIUS_Q2 = 252\n'+source
    source+=block('sphere_world',world)
    for i in range(1,len(sections),2):source+=block('sphere_'+sections[i],sections[i+1])
    squares=''
    for suffix,shift in [('lo',0),('hi',8)]:
        squares+='er_circle_square_'+suffix+':\n'
        for i in range(0,256,16):squares+=' .byte '+','.join(str(((j*j)>>shift)&255) for j in range(i,i+16))+'\n'
    source+=block('sphere_squares',squares)
    return source


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('asm',type=Path);args=parser.parse_args()
    args.asm.write_text(install(args.asm.read_text(encoding='utf-8-sig')),encoding='ascii')
    args.asm.with_suffix('.sphere-api.json').write_text(json.dumps(dict(enabled=True,representation='Screen-aligned circle impostor',worldInput='signed24 Q8 native X/Y-up/Z-forward',cameraInput='signed16 Q4',radiusInput='unsigned Q4 world radius1..16383',screenCenter='signed16 Q2',screenRadius='unsigned Q2,1..252',nativeMaterials=True,sceneSpecificData=False,automaticSorting=False,automaticLighting=False,defaultRendererChanged=False),indent=2)+'\n')
