"""Fail closed on unsupported door configuration and profile inheritance."""
import importlib.util,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
spec=importlib.util.spec_from_file_location('entity_runtime',ROOT/'extensions/gameplay/entities/runtime.py')
entity=importlib.util.module_from_spec(spec);spec.loader.exec_module(entity);sys.modules['entity_runtime']=entity
spec=importlib.util.spec_from_file_location('door',ROOT/'extensions/gameplay/entities/door.py')
door=importlib.util.module_from_spec(spec);spec.loader.exec_module(door)


def main():
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    assert door.validate({'schema':1,'motion':True})['motion']
    assert not door.validate({'schema':1,'motion':False})['motion']
    invalid=[{}, {'schema':True,'motion':True},{'schema':2,'motion':True},
        {'schema':1,'motion':1},{'schema':1,'motion':False,'speed':999}]
    for cfg in invalid:
        try:door.validate(cfg)
        except ValueError:pass
        else:raise AssertionError('Unsupported door configuration accepted')
    assert door.CLEAR_Q8==12*256+64 and door.HEIGHT*256//door.STEP_Q8==72
    spec=importlib.util.spec_from_file_location('gameplay_build',ROOT/'work/build-gameplay.py')
    b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b)
    assert b.profile_chain('door-entity')==['comparison-ui','mixed-surfaces','interactive-billboard','door-entity']
    try:b.profile_chain('door-entity',('door-entity',))
    except ValueError:pass
    else:raise AssertionError('Cyclic profile accepted')
    print('DOOR CONFIG PASS;',len(invalid),'invalid configurations and cyclic inheritance refused')


if __name__=='__main__':main()
