"""Use the native FPS protocol and trace selector use without target patches."""
import json
import re
from pathlib import Path
import native_compare as native


def benchmark(build,refreshes=3072):
    b,prg,labels=native.paths(build);stem=native.ROOT/'reports/fps'/build
    assembled=(b/'3Dvibe64.prg').read_bytes();load=int.from_bytes(assembled[:2],'little')
    code=assembled[labels['vs_test']-load+2:labels['vs_accept']-load+2]
    marker=bytes([0xee,labels['vs_rejected']&255,labels['vs_rejected']>>8])
    assert code.count(marker)==1
    reject=labels['vs_test']+code.index(marker)
    original=native.run
    def traced(program,path,commands):
        commands=list(commands);index=commands.index(f'ignore 5 {refreshes-1:x}')+1
        commands[index:index]=[f'trace exec ${reject:04x}','trace exec .vs_classified']
        return original(program,path,commands)
    native.run=traced
    try:native.benchmark(build,refreshes)
    finally:native.run=original
    log=Path(str(stem)+'.monitor.log').read_text(errors='replace').rsplit('Stopwatch reset to 0.',1)[1]
    rejected=[];classified=[]
    for match in re.finditer(r'#(6|7) \(Trace\s+exec [0-9a-f]+\)[^\n]*\n([^\n]+)',log,re.I):
        (rejected if match[1]=='6' else classified).append(int(re.search(r'(\d+)\s*$',match[2])[1]))
    result=json.loads(stem.with_suffix('.json').read_text(encoding='utf-8-sig'))
    result['selectorTrace']=dict(rejectedFaceCalls=len(rejected),classifiedViews=len(classified),
        rejectedAtBaseCycles=rejected,classifiedAtBaseCycles=classified,
        instrumentation='read-only VICE execution traces6/7; no target code/data writes; FPS remains trace3/native complete-view counter')
    stem.with_suffix('.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print('VISIBILITY SELECTOR',len(classified),'classified views,',len(rejected),'face calls rejected')
