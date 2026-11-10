"""Regression: instrumentation must reflow existing placed Plus helpers.
No rendering scene; compile a tiny synthetic kernel with an adjacent helper.
"""
from pathlib import Path
import sys,shutil,tempfile,subprocess,re,json
ROOT=Path(__file__).resolve().parents[1]

def main():
    src='*=$1000\nSCENE_OBJECT_COUNT=1\nFACE_COUNT=1\nCAMERA_MOVABLE=1\nMESH_SOURCE_SHARING_RUNTIME=0\nBITMAP_B_BASE=$2000\nLR_PRODUCT_LUT_ACTIVE=0\nRUNTIME_BUFFER_COLOR_POLICY_END=$8200\nobjidx=$20\nptr0lo=$22\nptr1lo=$24\nactive_face_first=$26\nactive_face_end=$27\nset_active_object:\n rts\nsynthetic_store:\n sta (ptr0lo),y\n rts\nbase_end:\n'
    for i,axis in enumerate('xyz'):
        for j,part in enumerate(['lo','hi','ext']):src+=f'object_pos_{axis}_{part}=${0x3000+i*3+j:04x}\nexplorer_cam_{axis}_{part}=${0x3100+i*3+j:04x}\n'
    src+='\n; Plus allocation block old_helper\n* = $1004\nlpa_block_old_helper_begin:\nold_helper:\n lda #123\n rts\nlpa_block_old_helper_end:\n.cerror * > $1028,"old helper guard"\n'
    with tempfile.TemporaryDirectory(prefix='3dvibe64-fade-layout-') as temp:
        p=Path(temp);asm=p/'kernel.asm';asm.write_text(src)
        tass=shutil.which('64tass');cmd=[sys.executable,'-B',str(ROOT/'work/distance_fade_legacy.py'),str(asm),'--start','32','--end','80','--assembler',tass]
        r=subprocess.run(cmd,capture_output=True,text=True);assert r.returncode==0,r.stdout+r.stderr
        info=json.loads(asm.with_suffix('.distance-fade.json').read_text());assert info['plusReallocated']
        r=subprocess.run([tass,'-a','-B','--vice-labels-numeric','--labels='+str(p/'labels'),'-o',str(p/'kernel.prg'),str(asm)],capture_output=True,text=True);assert r.returncode==0,r.stdout+r.stderr
        l={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',(p/'labels').read_text(),re.M)}
        b=(p/'kernel.prg').read_bytes();o=int.from_bytes(b[:2],'little');assert b[l['old_helper']-o+2:l['old_helper']-o+5]==bytes([0xa9,123,0x60])
        assert b[l['synthetic_store']-o+2]==0x20 and b[l['synthetic_store']-o+5]==0x60
        assert l['old_helper']>=l['base_end'] or l['old_helper']+3<=l['synthetic_store']
    # Mode1 has intentional fall-through into relocated routines. Calls alone
    # do not cover this regression: execute the original preceding labels.
    sys.path.insert(0,str(ROOT/'work'))
    from distance_fade_legacy import wire_writers
    from py65.devices.mpu6502 import MPU
    source='GRAPHICS_MODE = $01\nMODE5_POLYGON_OUTLINE=0\nMEMORY_LAYOUT_HIGH_BASIC_V2=1\n*=$1000\ncall_writer:\n nop\nplot_wire_point:\n lda #11\npvwr_done:\n rts\ncall_clip:\n nop\nclip_poly_compact_screen_a:\n lda #22\n rts\nwire_vertex_drawable:\n rts\ncall_edge:\n nop\ntrace_edge_convex:\n lda #33\n rts\n.if MODE5_POLYGON_OUTLINE != 0 && MEMORY_LAYOUT_HIGH_BASIC_V2 = 0\nmode5_stable_code_end = *\n.endif\n'
    base,parts=wire_writers(source,{})
    for index,body in enumerate(parts.values()):base+=f'\n*=${0x2000+index*0x100:04x}\n'+body
    with tempfile.TemporaryDirectory(prefix='3dvibe64-wire-fallthrough-') as temp:
        p=Path(temp);asm=p/'kernel.asm';asm.write_text(base)
        r=subprocess.run([tass,'-a','-B','--vice-labels-numeric','--labels='+str(p/'labels'),'-o',str(p/'kernel.prg'),str(asm)],capture_output=True,text=True);assert r.returncode==0,r.stdout+r.stderr
        l={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',(p/'labels').read_text(),re.M)}
        image=(p/'kernel.prg').read_bytes();origin=int.from_bytes(image[:2],'little')
        for label,result in [('call_writer',11),('call_clip',22),('call_edge',33)]:
            cpu=MPU();cpu.memory[origin:origin+len(image)-2]=image[2:];cpu.pc=l[label]
            cpu.stPushWord(0x2fff)
            for _ in range(30):
                if cpu.pc==0x3000:break
                cpu.step()
            assert cpu.pc==0x3000 and cpu.a==result,(label,cpu.pc,cpu.a)
    print('DISTANCE_FADE_LAYOUT PASS; adjacent existing helper relocated without overlap; guards retained')
if __name__=='__main__':main()
