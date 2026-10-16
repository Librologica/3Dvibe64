"""Caller-supplied billboard input and frozen assembly emission regression."""
import hashlib,importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
GOLD={'masked': '16790fae0bedf935b285afb7efed59fe8875158777e310d09d08e34a7bd90546', 'outlined': 'e85825f64a631ee4d7806e8a098423b4331ac82378ef5cc1a197f7af120a1847'}
def main():
    for name,expected in GOLD.items():
        spec=importlib.util.spec_from_file_location('emitter_'+name,ROOT/f'extensions/gameplay/billboards/{name}.py')
        mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
        assert not hasattr(mod,'artwork') and not hasattr(mod,'scene') and not hasattr(mod,'configure_tour')
        frames=[[i%(5 if name=='outlined' else 4) for i in range(512)] for _ in range(6)]
        value=''.join(mod.kernel())+mod.post('caller-source\n',frames)
        assert hashlib.sha256(value.encode()).hexdigest()==expected,name
        for bad in [None,[],frames[:5],[[0]*511]*6,[[True]*512]*6,[[5]*512]*6]:
            try:mod.post('',bad)
            except ValueError:pass
            else:raise AssertionError('Invalid caller frames accepted')
    print('BILLBOARD EMITTER PASS; prior code/state/frame bytes identical; no artwork or scene generator')
if __name__=='__main__':main()
