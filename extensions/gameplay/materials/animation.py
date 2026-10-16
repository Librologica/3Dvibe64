"""TEX-01: resident frame pages and exact integer-texel UV offsets per group.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
No texel copying at runtime; no change to projection, coverage or carrier DDA.
"""
import collections
import json
from pathlib import Path


def validate(config, asset, scene, surfaces):
    if not isinstance(config,dict) or set(config)!={'schema','running','sourceTexture','asset','materials'} or type(config['schema']) is not int or config['schema']!=1 or type(config['running']) is not bool:
        raise ValueError('Texture animation requires schema1, running, sourceTexture, asset and materials')
    if not isinstance(config['asset'],str) or not config['asset']:raise ValueError('Expected local texture frame asset')
    if not isinstance(asset,dict) or set(asset)!={'width','height','frames'} or asset['width']!=16 or asset['height']!=16:
        raise ValueError('Texture frame asset requires16x16 frames')
    frames=asset['frames']
    if not isinstance(frames,list) or not 1<=len(frames)<=4:raise ValueError('Resident atlas supports1..4 frames')
    if any(not isinstance(f,list) or len(f)!=256 or any(type(v) is not int or not 1<=v<=3 for v in f) for f in frames):raise ValueError('Texture frames require256 pigment slots1..3')
    textures={t['id']:t for t in scene['textures']}
    if not isinstance(config['sourceTexture'],str) or config['sourceTexture'] not in textures:raise ValueError('Unknown source texture')
    texture=textures[config['sourceTexture']]
    if texture['width']!=16 or texture['height']!=16 or texture['texels']!=frames[0]:raise ValueError('Frame0 must exactly match the resident source texture')
    histogram=collections.Counter(frames[0])
    if len(histogram)<2 or any(collections.Counter(f)!=histogram for f in frames):raise ValueError('Frames must be nonuniform with identical pigment counts to preserve the existing LOD fallback')
    groups=config['materials']
    if not isinstance(groups,list) or len(groups)>2:raise ValueError('This checkpoint supports up to two animated material groups')
    if len(scene['meshes'])!=1:raise ValueError('This bounded animation profile requires one source mesh')
    mesh=scene['meshes'][0];used=set();ids=set()
    for g in groups:
        if not isinstance(g,dict) or set(g)!={'id','faces','frames','ticksPerFrame','scroll'} or not isinstance(g['id'],str) or not g['id'] or g['id'] in ids:raise ValueError('Unique animated material id required')
        ids.add(g['id'])
        if not isinstance(g['faces'],list) or not g['faces']:raise ValueError('Bind material to at least one source face')
        for face in g['faces']:
            if type(face) is not int or not 0<=face<len(mesh['faces']) or face in (14,15) or face in used:raise ValueError('Invalid, reserved or multiply-bound face')
            if surfaces[face]['mode']!='texture' or mesh['faceTextures'][face]!=config['sourceTexture']:raise ValueError('Animation applies only to textured faces using the configured source')
            used.add(face)
        if type(g['ticksPerFrame']) is not int or not 1<=g['ticksPerFrame']<=255:raise ValueError('Frame duration must be1..255 simulation ticks')
        if not isinstance(g['frames'],list) or not 1<=len(g['frames'])<=16 or any(type(f) is not int or not 0<=f<len(frames) for f in g['frames']):raise ValueError('Invalid texture frame sequence')
        scroll=g['scroll']
        if not isinstance(scroll,dict) or set(scroll)!={'step','ticks'} or type(scroll['ticks']) is not int or not 1<=scroll['ticks']<=255:raise ValueError('Invalid scroll timing')
        if not isinstance(scroll['step'],list) or len(scroll['step'])!=2 or any(type(v) is not int or not -15<=v<=15 for v in scroll['step']):raise ValueError('UV step must be two signed integer texel offsets within15')
    return config


def load(path, scene, surfaces):
    path=Path(path).resolve();config=json.loads(path.read_text(encoding='utf-8-sig'))
    if not isinstance(config.get('asset'),str):raise ValueError('Texture frame asset path required')
    asset_path=(path.parent/config['asset']).resolve(strict=True)
    if not asset_path.is_relative_to(path.parent):raise ValueError('Texture asset must be inside configuration directory')
    asset=json.loads(asset_path.read_text(encoding='utf-8-sig'))
    return validate(config,asset,scene,surfaces),asset


def data(label,values):return label+': .byte '+','.join(str(v&255) for v in values)+'\n'


def adapt(source,parts,config,asset,face_count):
    groups=config['materials']
    if not groups:return source,parts
    # The source uses absolute LDA at the partial pixel and three ASL bytes
    # at each full-byte pixel. Each is a reversible three-byte SMC site.
    old=' jsr iu_select_surface\n rts\n'
    if source.count(old)!=1:raise ValueError('Texture surface bind ABI changed')
    source=source.replace(old,' jsr iu_select_surface\n jsr ta_bind\n rts\n')
    if source.count(' jsr bb_tick\n')!=1:raise ValueError('Texture tick ABI changed')
    source=source.replace(' jsr bb_tick\n',' jsr bb_tick\n jsr ta_tick\n')
    joined=source+'\n'.join(parts.values())
    for i in range(4):
        if joined.count(f'fx{i}_address:\n asl\n asl\n asl\n')!=1:raise ValueError('Full-byte texture address ABI changed')
    if joined.count('m7_address_begin:\n lda m7_v\n asl\n')!=1:raise ValueError('Partial texture address ABI changed')
    helpers=''
    for label,fetch,tail in [('ta_partial',' lda m7_fetch_dummy,y\n',' jmp m3_composite\n')]+[(f'ta_fx{i}',' lda ($f7),y\n',f' jmp fx{i}_m3_composite\n') for i in range(4)]:
        # The partial helper rejoins m7_fetch, whose selected page is shared
        # with the full-byte ($f7) reader; no duplicate copy of source texels.
        helpers+=label+':\n'
        if label=='ta_partial':helpers+=' lda m7_v\n'
        helpers+=' clc\n'+label+'_v:\n adc #0\n asl\n asl\n asl\n and #$f0\n sta m7_index\n lda m7_u\n clc\n'+label+'_u:\n adc #0\n lsr\n and #$0f\n ora m7_index\n tay\n'
        helpers+=(' jmp m7_fetch\n' if label=='ta_partial' else fetch+tail)
    kernel='''ta_tick:
 lda ta_running
 bne +
 rts
+
 ldx #0
ta_tick_loop:
 inc ta_frame_hold,x
 lda ta_frame_hold,x
 cmp ta_frame_ticks,x
 bcc ta_scroll_tick
 lda #0
 sta ta_frame_hold,x
 inc ta_cursor,x
 lda ta_cursor,x
 cmp ta_lengths,x
 bcc ta_scroll_tick
 lda #0
 sta ta_cursor,x
ta_scroll_tick:
 inc ta_scroll_hold,x
 lda ta_scroll_hold,x
 cmp ta_scroll_ticks,x
 bcc ta_next_group
 lda #0
 sta ta_scroll_hold,x
 clc
 lda ta_u,x
 adc ta_step_u,x
 and #15
 sta ta_u,x
 clc
 lda ta_v,x
 adc ta_step_v,x
 and #15
 sta ta_v,x
ta_next_group:
 inx
 cpx #TA_GROUPS
 bcc ta_tick_loop
 rts
ta_bind:
 ldy sortj
 ldx ta_face_group,y
 cpx #255
 bne ta_animated
 ; Unconfigured materials retain their original per-pixel instruction path.
 lda #$ad
 sta m7_address_begin
 lda #<m7_v
 sta m7_address_begin+1
 lda #>m7_v
 sta m7_address_begin+2
 lda #$0a
'''
    for i in range(4):
        for byte in range(3):kernel+=f' sta fx{i}_address'+('' if byte==0 else '+'+str(byte))+'\n'
    kernel+=' rts\nta_animated:\n'
    kernel+=' lda ta_u,x\n asl\n'
    for label in ['ta_partial']+[f'ta_fx{i}' for i in range(4)]:kernel+=f' sta {label}_u+1\n'
    kernel+=' lda ta_v,x\n asl\n'
    for label in ['ta_partial']+[f'ta_fx{i}' for i in range(4)]:kernel+=f' sta {label}_v+1\n'
    kernel+=''' lda ta_cursor,x
 clc
 adc ta_sequence_offsets,x
 tay
 lda ta_sequences,y
 tay
 lda ta_frame_pages,y
 sta m7_fetch+2
 lda #$4c
 sta m7_address_begin
'''
    for i in range(4):kernel+=f' sta fx{i}_address\n'
    for site,target in [('m7_address_begin','ta_partial')]+[(f'fx{i}_address',f'ta_fx{i}') for i in range(4)]:
        kernel+=f' lda #<{target}\n sta {site}+1\n lda #>{target}\n sta {site}+2\n'
    kernel+=' rts\n .cerror m7_v < $100,"Texture partial address opcode must remain absolute LDA"\n'
    # Both hooks preserve the caller's register/flag ABI. In particular the
    # face loader still needs Y=source face after material selection.
    for label in ('ta_tick','ta_bind'):
        wrapper=label+':\n php\n pha\n txa\n pha\n tya\n pha\n jsr '+label+'_internal\n pla\n tay\n pla\n tax\n pla\n plp\n rts\n'+label+'_internal:\n'
        kernel=kernel.replace(label+':\n',wrapper,1)
    parts['texture_animation_runtime']=kernel
    parts['texture_animation_helpers']=helpers
    state=f'TA_GROUPS = {len(groups)}\n'+data('ta_running',[int(config['running'])])
    for name in ('cursor','frame_hold','scroll_hold','u','v'):state+=data('ta_'+name,[0]*len(groups))
    for name,values in [('frame_ticks',[g['ticksPerFrame'] for g in groups]),('lengths',[len(g['frames']) for g in groups]),('scroll_ticks',[g['scroll']['ticks'] for g in groups]),('step_u',[g['scroll']['step'][0] for g in groups]),('step_v',[g['scroll']['step'][1] for g in groups])]:state+=data('ta_'+name,values)
    offsets=[];seq=[]
    for g in groups:offsets.append(len(seq));seq+=g['frames']
    state+=data('ta_sequence_offsets',offsets)+data('ta_sequences',seq)
    binding=[255]*face_count
    for i,g in enumerate(groups):
        for face in g['faces']:binding[face]=i
    state+=data('ta_face_group',binding)
    texture_id=config['_textureIndex']
    state+='ta_frame_pages: .byte >m7_texture_'+str(texture_id)+''.join(',>ta_frame_page'+str(i) for i in range(1,len(asset['frames'])))+'\n'
    parts['texture_animation_state']=state
    if len(asset['frames'])>1:
        size=(len(asset['frames'])-1)*256+255
        pages=f'ta_page_storage:\nta_page_aligned = (ta_page_storage + 255) & $ff00\n .fill ta_page_aligned-*,0\n'
        for i,pixels in enumerate(asset['frames'][1:],1):pages+=data('ta_frame_page'+str(i),pixels)
        pages+=f' .fill {size}-(*-ta_page_storage),0\n .cerror *-ta_page_storage != {size},"Texture page allocation size mismatch"\n'
        parts['texture_animation_pages']=pages
    return source,parts
