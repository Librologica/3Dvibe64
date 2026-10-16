"""Optional asset-free native support emitters for external project adapters.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
No scene, route, texture, SID payload or application-specific generator.
"""
import math,re,struct
from pathlib import Path


def _symbol(name):
    if not isinstance(name,str) or not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*',name):raise ValueError('Invalid assembly symbol')
    return name


def resident_pool(slots,callback,*,prefix='pool'):
    """Bounded native recycling primitive, not a room generator or disk loader.
    callback: X=slot, A=generation low,Y=high; must preserve X, return carry set
    only after it has installed a complete slot. Failure keeps cursor/generation.
    init before use; callback owns all geometry, connectivity and recentering.
    """
    if type(slots)is not int or not 1<=slots<=32:raise ValueError('Pool slots must be 1..32')
    c=_symbol(callback);p=_symbol(prefix)
    return f'{p}_init:\n lda #0\n sta {p}_cursor\n sta {p}_generation\n sta {p}_generation+1\n ldx #{slots-1}\n-\n sta {p}_valid,x\n dex\n bpl -\n rts\n{p}_next:\n ldx {p}_cursor\n lda {p}_generation\n ldy {p}_generation+1\n jsr {c}\n bcc {p}_failed\n lda #1\n sta {p}_valid,x\n inc {p}_generation\n bne +\n inc {p}_generation+1\n+\n inc {p}_cursor\n lda {p}_cursor\n cmp #{slots}\n bcc +\n lda #0\n sta {p}_cursor\n+\n sec\n rts\n{p}_failed:\n clc\n rts\n{p}_cursor: .byte 0\n{p}_generation: .word 0\n{p}_valid: .fill {slots},0\n'


def camera_tables(*,samples=256,step_height=0.18,bank_degrees=2.5,glance_degrees=6.0):
    """Host-generated signed Q8 offsets; application owns tick/path/turn sign.
    bob is WU Q8; bank/glance are signed 16-bit Q8 phase (256 phases/turn).
    No route, target corridor, look-ahead controller or automatic camera hook.
    """
    if type(samples)is not int or not 16<=samples<=256:raise ValueError('16..256 samples required')
    if any(type(v) not in (int,float) or not math.isfinite(v) or v<0 for v in (step_height,bank_degrees,glance_degrees)):raise ValueError('Finite nonnegative amplitudes required')
    if step_height>4 or bank_degrees>30 or glance_degrees>45:raise ValueError('Camera amplitudes exceed supported limits')
    return {name:[round(amplitude*math.sin(2*math.pi*i/samples)) for i in range(samples)]
            for name,amplitude in [('bob',step_height*256),('bank',bank_degrees/360*65536),('glance',glance_degrees/360*65536)]}


def camera_assembly(tables,*,prefix='gait'):
    p=_symbol(prefix)
    if set(tables)!={'bob','bank','glance'} or len({len(v) for v in tables.values()})!=1:raise ValueError('Matching camera channels required')
    if not 16<=len(tables['bob'])<=256:raise ValueError('Invalid camera sample count')
    result=''
    for name,values in tables.items():
        if any(type(v)is not int or not -32768<=v<=32767 for v in values):raise ValueError('Signed16 samples required')
        for half,shift in [('lo',0),('hi',8)]:result+=f'{p}_{name}_{half}: .byte '+','.join(str((v>>shift)&255) for v in values)+'\n'
    return result


def parse_sid(path,*,subtune=1):
    blob=Path(path).read_bytes()
    if len(blob)<124 or blob[:4]!=b'PSID':raise ValueError('PSID v2..4 required; RSID not supported')
    version,offset,load,init,play,songs,start=struct.unpack_from('>7H',blob,4)
    if version not in (2,3,4) or offset<124 or offset>len(blob):raise ValueError('Invalid PSID header')
    if type(subtune)is not int or not 1<=subtune<=songs:raise ValueError('Invalid subtune')
    speed=int.from_bytes(blob[18:22],'big')
    if speed&(1<<min(subtune-1,31)):raise ValueError('CIA-timed SID unsupported; PAL raster cadence required')
    flags=int.from_bytes(blob[118:120],'big');clock=(flags>>2)&3
    if flags&3:raise ValueError('MUS/PSID-specific driver unsupported')
    if clock==2 or blob[122] or blob[123] or not play:raise ValueError('PAL single-SID explicit play entry required')
    payload=blob[offset:]
    if not load:
        if len(payload)<2:raise ValueError('Missing load address')
        load=int.from_bytes(payload[:2],'little');payload=payload[2:]
    init=init or load
    if not payload or not 0x200<=load<load+len(payload)<=0x10000:raise ValueError('Invalid SID load range')
    if not load<=init<load+len(payload) or not load<=play<load+len(payload):raise ValueError('SID entries outside payload')
    return dict(load=load,init=init,play=play,payload=payload,subtune=subtune,
                title=blob[22:54].split(b'\0')[0].decode('latin1'),author=blob[54:86].split(b'\0')[0].decode('latin1'))


def sid_wrapper(init,play,*,zp_start=0xf0,zp_count=8,bank=0x35,subtune=1,prefix='sid'):
    """Caller must audit/relocate its player and reserve its complete RAM/ZP.
    Wrapper code/data must remain mapped under both bank values. No payload is
    loaded or linked here. Init and tick clobber A/X/Y, preserve P/bank/ZP; no
    reentrancy. Call tick exactly once per PAL IRQ, not once per rendered view.
    """
    p=_symbol(prefix)
    if any(type(v)is not int or not 0x200<=v<=0xffff for v in (init,play)):raise ValueError('Invalid SID entry')
    if type(zp_count)is not int or not 1<=zp_count<=32 or type(zp_start)is not int or not 2<=zp_start<=256-zp_count:raise ValueError('Invalid audited zero-page range')
    if type(bank)is not int or not 0<=bank<=255 or type(subtune)is not int or not 1<=subtune<=256:raise ValueError('Invalid SID bank/subtune')
    return f'{p}_init:\n php\n sei\n jsr {p}_swap_in\n lda #{subtune-1}\n ldx #0\n ldy #0\n jsr ${init:04x}\n jsr {p}_swap_out\n plp\n rts\n{p}_tick:\n php\n sei\n jsr {p}_swap_in\n jsr ${play:04x}\n jsr {p}_swap_out\n inc {p}_calls\n bne +\n inc {p}_calls+1\n+\n plp\n rts\n{p}_swap_in:\n lda $01\n sta {p}_saved_bank\n ldx #{zp_count-1}\n-\n lda ${zp_start:02x},x\n sta {p}_engine_zp,x\n lda {p}_player_zp,x\n sta ${zp_start:02x},x\n dex\n bpl -\n lda #{bank}\n sta $01\n rts\n{p}_swap_out:\n ldx #{zp_count-1}\n-\n lda ${zp_start:02x},x\n sta {p}_player_zp,x\n lda {p}_engine_zp,x\n sta ${zp_start:02x},x\n dex\n bpl -\n lda {p}_saved_bank\n sta $01\n rts\n{p}_calls: .word 0\n{p}_saved_bank: .byte 0\n{p}_engine_zp: .fill {zp_count},0\n{p}_player_zp: .fill {zp_count},0\n'
