"""Demo-only 96x60 logical adventure viewport; unchanged Q8 SDK.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import re
W,H,OX,OY=96,60,24,4
FOCAL_Q8=13056 # 85 * 0.6 * 256: exactly proportional, no aspect distortion.

def constant(source,name,value):
    s,n=re.subn(r'(?m)^'+name+r' = \$[0-9a-fA-F]+$',name+' = $'+format(value,'02X'),source)
    assert n==1,(name,n)
    return s

def table(source,name,values):
    pat=r'(?m)^'+name+r':\n(?: \.byte[^\n]*\n)+'
    old=re.search(pat,source);assert old,name
    assert len(re.findall(r'\$[0-9a-fA-F]+|(?<![A-Za-z_])\d+',old[0].split(':',1)[1]))==100,name
    data=''.join(' .byte '+','.join('$'+format(x,'02X') for x in values[i:i+16])+'\n' for i in range(0,100,16))
    return source[:old.start()]+name+':\n'+data+source[old.end():]

def adapt(source,parts):
    # This demo renders60rows, so its scanline state needs exactly60entries.
    # Address tables retain100entries for the existing source ABI; all walkers
    # and clear loops are bounded by the specialized viewport row count.
    assert source.count('VIEWPORT_ROW_CAPACITY = 100')==1
    source=source.replace('VIEWPORT_ROW_CAPACITY = 100','VIEWPORT_ROW_CAPACITY = 60')
    values={'PROJ_CENTER_X':W//2,'PROJ_CENTER_Y':H//2,
        'PROJ_SCREEN_MAX_X':W-1,'PROJ_SCREEN_MAX_Y':H-1,'PROJ_FOCAL':51,
        'PROJ_FRUSTUM_X_NEAR':W//4,'PROJ_FRUSTUM_Y_NEAR':H//4,
        'PROJ_FRUSTUM_FOCAL':26,'PROJ_CENTER_X_HALF':W//4,
        'YQ2_VIEWPORT_CENTER_LO':(H//2*4)&255,'YQ2_VIEWPORT_CENTER_HI':(H//2*4)>>8,
        'YQ2_VIEWPORT_MAX_LO':((H-1)*4)&255,'YQ2_VIEWPORT_MAX_HI':((H-1)*4)>>8,
        'YQ2_VIEWPORT_ROW_MAX':H-1,'YQ2_VIEWPORT_ROW_COUNT':H,
        'YQ2_VIEWPORT_CENTER_PLUS_ONE':H//2*4+1,
        'YQ2_VIEWPORT_BELOW_CENTER_LIMIT_PLUS_ONE':(H-1-H//2)*4+1,
        'ENGINE_CAMERA_VIEWPORT_SMALL':1,'ENGINE_CAMERA_VIEWPORT_PROFILE_ID':1,
        'ENGINE_CAMERA_VIEWPORT_PROJECTION_SCALED':1,'ENGINE_CAMERA_VIEWPORT_CLEAR_LIMITED':1,
        'CAMERA_VIEWPORT_WIDTH':W,'CAMERA_VIEWPORT_HEIGHT':H,
        'CAMERA_VIEWPORT_ORIGIN_X':OX,'CAMERA_VIEWPORT_ORIGIN_Y':OY,
        'CAMERA_VIEWPORT_CELL_ORIGIN_X':OX//4,'CAMERA_VIEWPORT_CELL_WIDTH':W//4,
        # X offset is already baked into EVERY bitmap/screen/color row pointer.
        # Keep zero here to avoid double offset in existing small-viewport clears.
        'CAMERA_VIEWPORT_BITMAP_X_OFFSET':0}
    for name,value in values.items():source=constant(source,name,value)
    for name in parts:
        parts[name]=parts[name].replace('21760',str(FOCAL_Q8)).replace('(85*256)','(51*256)')
    # Fixed-size pointer tables retain their storage/ABI; unused tail rows point
    # at the last valid viewport row. Both physical scanlines per logical row
    # and both buffers share exactly the same centered mapping.
    for buffer,base in (('a',0x6000),('b',0x2000)):
        for scan in (0,1):
            addresses=[]
            for row in range(100):
                physical=(min(row,H-1)+OY)*2+scan
                addresses.append(base+(physical//8)*320+physical%8+(OX//4)*8)
            for shift,suffix in ((0,'lo'),(8,'hi')):
                source=table(source,f'row{scan}{suffix}_{buffer}',[(v>>shift)&255 for v in addresses])
    # high-basic-v2 relocates Screen B to $0400. Never reuse the historical
    # $8C00 layout: it leaves the displayed Screen B unchanged and writes state.
    match=re.search(r'(?m)^SCREEN_B_BASE = \$([0-9a-fA-F]+)$',source)
    assert match,'Missing active Screen B layout'
    screen_b=int(match[1],16)
    for name,base in (('screenrow',0x5C00),('screenrow_b',screen_b),('colorrow',0xD800)):
        addresses=[base+((min(row,H-1)+OY)//4)*40+OX//4 for row in range(100)]
        for shift,suffix in ((0,'lo'),(8,'hi')):
            label=('screenrow'+suffix+'_a' if name=='screenrow' else
                   'screenrow'+suffix+'_b' if name=='screenrow_b' else 'colorrow'+suffix)
            source=table(source,label,[(v>>shift)&255 for v in addresses])
    return source,parts
