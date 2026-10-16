"""Explicit engine experiments; profile defaults remain unchanged.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
Q8={'q8-arithmetic','uv-texel','camera-table','visibility',
    'camera-extremes','degenerate-faces','zero-terms','live-attributes','adapter-outcodes','inside-planes','bounded-divide','packed-samples','unrolled-advance'}
def parse(value,family):
    if value in (None,'none',''):return set()
    if family=='mode8':
        raise ValueError('ENGINE_MODE8_RETIRED: the Mode8 experimental family (mode8-regions, mode8-rays, mode8-chars, including all and combinations) has been retired. Omit EngineExperiments or select none to use the qualified bitmap backend.')
    if family!='q8':raise ValueError('ENGINE_EXPERIMENT: unknown family '+str(family))
    allowed=Q8
    if value=='all':return set(allowed)
    values=set(value.split(',')) if isinstance(value,str) else set(value)
    if not values or not values<=allowed:raise ValueError('ENGINE_EXPERIMENT: invalid '+family+' experiment '+repr(sorted(values-allowed)))
    return values
