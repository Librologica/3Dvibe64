"""Bounded planar convex SAT and callback-owned contact scheduling, no assets.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
from animated_mesh import data
from runtime_support_native import config, integer, symbol


def sat_code(c):
    config(c, (), 'sat')
    code='''; Common local planar integer domain[-63,63]; ordered convex polygons.
; C=1 overlap (inclusive contact), C=0 separated/invalid; status0/1/2.
rs_sat_query:
 lda #2
 sta rs_sat_status
'''
    for p in 'ab':
        code+=f''' lda rs_sat_{p}_count
 cmp #3
 bcc rs_sat_invalid
 cmp #17
 bcs rs_sat_invalid
 ldx #0
rs_sat_validate_{p}:
'''
        for axis in 'xz':
            code+=f' lda rs_sat_{p}_{axis},x\n clc\n adc #63\n cmp #127\n bcs rs_sat_invalid\n'
        code+=f' inx\n cpx rs_sat_{p}_count\n bcc rs_sat_validate_{p}\n'
    code+=''' ; Cheap axis-aligned rejection first.
 lda #1
 sta rs_sat_axis
 lda #0
 sta rs_sat_axis+1
 jsr rs_sat_test_axis
 bcc rs_sat_separated
 lda #0
 sta rs_sat_axis
 lda #1
 sta rs_sat_axis+1
 jsr rs_sat_test_axis
 bcc rs_sat_separated
 lda rs_sat_cached
 beq rs_sat_edges
 lda rs_sat_cache_axis
 sta rs_sat_axis
 lda rs_sat_cache_axis+1
 sta rs_sat_axis+1
 jsr rs_sat_test_axis
 bcc rs_sat_separated
rs_sat_edges:
 lda #0
 sta rs_sat_polygon
rs_sat_polygon_loop:
 lda #0
 sta rs_sat_edge
rs_sat_edge_loop:
 lda rs_sat_polygon
 bne rs_sat_edge_b
'''
    for p in 'ab':
        if p=='b':code+='rs_sat_edge_b:\n'
        code+=f''' ldx rs_sat_edge
 inx
 cpx rs_sat_{p}_count
 bcc +
 ldx #0
+
 ldy rs_sat_edge
 sec
 lda rs_sat_{p}_z,y
 sbc rs_sat_{p}_z,x
 sta rs_sat_axis
 sec
 lda rs_sat_{p}_x,x
 sbc rs_sat_{p}_x,y
 sta rs_sat_axis+1
 lda rs_sat_{p}_count
 sta rs_sat_edge_count
'''
        if p=='a':code+=' jmp rs_sat_edge_test\n'
    code+='''rs_sat_edge_test:
 jsr rs_sat_test_axis
 bcc rs_sat_separated
 inc rs_sat_edge
 lda rs_sat_edge
 cmp rs_sat_edge_count
 bcc rs_sat_edge_loop
 inc rs_sat_polygon
 lda rs_sat_polygon
 cmp #2
 bcc rs_sat_polygon_loop
 lda #0
 sta rs_sat_status
 sta rs_sat_cached
 sec
 rts
rs_sat_separated:
 lda #1
 sta rs_sat_status
 sta rs_sat_cached
 lda rs_sat_axis
 sta rs_sat_cache_axis
 lda rs_sat_axis+1
 sta rs_sat_cache_axis+1
rs_sat_invalid:
 clc
 rts
rs_sat_test_axis:
'''
    for p in 'ab':
        code+=f' lda #0\n sta rs_sat_vertex\nrs_sat_project_{p}:\n ldy rs_sat_vertex\n lda rs_sat_{p}_x,y\n sta rs_sat_coord\n lda rs_sat_{p}_z,y\n sta rs_sat_coord+1\n jsr rs_sat_dot\n'
        code+=f''' lda rs_sat_vertex
 bne rs_sat_extend_{p}
 lda rs_sat_dot_value
 sta rs_sat_{p}_min
 sta rs_sat_{p}_max
 lda rs_sat_dot_value+1
 sta rs_sat_{p}_min+1
 sta rs_sat_{p}_max+1
 jmp rs_sat_project_next_{p}
rs_sat_extend_{p}:
'''
        for op in ('min','max'):
            code+=f''' lda rs_sat_dot_value+1
 eor #128
 sta rs_sat_compare
 lda rs_sat_{p}_{op}+1
 eor #128
 cmp rs_sat_compare
'''
            if op=='min':code+=f' bcc rs_sat_skip_{p}_{op}\n bne rs_sat_set_{p}_{op}\n lda rs_sat_{p}_{op}\n cmp rs_sat_dot_value\n bcc rs_sat_skip_{p}_{op}\n'
            else:code+=f' bcc rs_sat_set_{p}_{op}\n bne rs_sat_skip_{p}_{op}\n lda rs_sat_{p}_{op}\n cmp rs_sat_dot_value\n bcs rs_sat_skip_{p}_{op}\n'
            code+=f'rs_sat_set_{p}_{op}:\n lda rs_sat_dot_value\n sta rs_sat_{p}_{op}\n lda rs_sat_dot_value+1\n sta rs_sat_{p}_{op}+1\nrs_sat_skip_{p}_{op}:\n'
        code+=f'rs_sat_project_next_{p}:\n inc rs_sat_vertex\n lda rs_sat_vertex\n cmp rs_sat_{p}_count\n bcc rs_sat_project_{p}\n'
    for a,b in [('a','b'),('b','a')]:
        code+=f''' lda rs_sat_{a}_max+1
 eor #128
 sta rs_sat_compare
 lda rs_sat_{b}_min+1
 eor #128
 cmp rs_sat_compare
 bcc rs_sat_overlap_axis_{a}
 bne rs_sat_axis_separate
 lda rs_sat_{a}_max
 cmp rs_sat_{b}_min
 bcc rs_sat_axis_separate
rs_sat_overlap_axis_{a}:
'''
    code+=''' sec
 rts
rs_sat_axis_separate:
 clc
 rts
rs_sat_dot:
 lda #0
 sta rs_sat_dot_value
 sta rs_sat_dot_value+1
 sta rs_sat_component
rs_sat_dot_component:
 ldy rs_sat_component
 lda rs_sat_coord,y
 eor rs_sat_axis,y
 sta rs_sat_sign
 lda rs_sat_coord,y
 bpl +
 eor #255
 clc
 adc #1
+
 sta rs_mul_b
 lda rs_sat_axis,y
 bpl +
 eor #255
 clc
 adc #1
+
 sta rs_mul_a
 lda #0
 sta rs_mul_a+1
 jsr rs_mul_u16_u8
 lda rs_sat_sign
 bpl +
 sec
 lda #0
 sbc rs_mul_result
 sta rs_mul_result
 lda #0
 sbc rs_mul_result+1
 sta rs_mul_result+1
+
 clc
 lda rs_sat_dot_value
 adc rs_mul_result
 sta rs_sat_dot_value
 lda rs_sat_dot_value+1
 adc rs_mul_result+1
 sta rs_sat_dot_value+1
 inc rs_sat_component
 lda rs_sat_component
 cmp #2
 bcc rs_sat_dot_component
 rts
'''
    for p in 'ab':
        code+=f'rs_sat_{p}_count: .byte 3\nrs_sat_{p}_x: .fill 16,0\nrs_sat_{p}_z: .fill 16,0\nrs_sat_{p}_min: .word 0\nrs_sat_{p}_max: .word 0\n'
    for n,s in [('status',1),('cached',1),('cache_axis',2),('axis',2),('polygon',1),('edge',1),('edge_count',1),('vertex',1),('coord',2),('component',1),('sign',1),('compare',1),('dot_value',2)]:
        code+=f'rs_sat_{n}: .fill {s},0\n'
    return code


def contacts_code(c):
    config(c, ('bodies','passes','pairBudget','query','resolve','positions','velocities','priority'), 'contacts')
    bodies=integer(c.get('bodies'),2,16,'bodies')
    passes=integer(c.get('passes',4),1,16,'passes')
    budget=integer(c.get('pairBudget',256),1,65535,'pairBudget')
    query,resolve=symbol(c.get('query')),symbol(c.get('resolve'))
    positions=c.get('positions',[]);velocities=c.get('velocities',[])
    if not isinstance(positions,list) or not 1<=len(positions)<=6 or not isinstance(velocities,list) or len(velocities)>6:
        raise ValueError('RUNTIME_CONTACTS: require1..6 position and0..6 velocity channels')
    for record in positions+velocities:
        config(record,('low','high'),'contact channel');symbol(record.get('low'));symbol(record.get('high'))
    pairs=[(a,b) for a in range(bodies) for b in range(a+1,bodies)]
    if 'priority' in c:
        p=integer(c['priority'],0,bodies-1,'priority');pairs.sort(key=lambda pair:p not in pair)
    code='; Snapshot BEFORE integration; callbacks X,Y=body IDs. Not reentrant.\nrs_contacts_snapshot:\n'
    for j,ch in enumerate(positions):
        code+=f' ldx #{bodies-1}\nrs_contact_save_{j}:\n lda {ch["low"]},x\n sta rs_contact_old_{j}_lo,x\n lda {ch["high"]},x\n sta rs_contact_old_{j}_hi,x\n dex\n bpl rs_contact_save_{j}\n'
    code+=''' lda #1
 sta rs_contact_valid
 rts
rs_contacts_solve:
 lda #2
 sta rs_contact_status
 lda rs_contact_valid
 beq rs_contact_bad
 lda #0
 sta rs_contact_queries
 sta rs_contact_queries+1
 sta rs_contact_pass
rs_contact_pass_start:
 lda #0
 sta rs_contact_hits
 sta rs_contact_pair
rs_contact_pair_loop:
 lda rs_contact_queries+1
 cmp #>RS_BUDGET
 bne rs_contact_query
 lda rs_contact_queries
 cmp #<RS_BUDGET
 beq rs_contact_rollback
rs_contact_query:
 inc rs_contact_queries
 bne +
 inc rs_contact_queries+1
+
 ldy rs_contact_pair
 lda rs_contact_pair_a,y
 tax
 lda rs_contact_pair_b,y
 tay
 jsr RS_QUERY
 bcc rs_contact_pair_next
 inc rs_contact_hits
 ldy rs_contact_pair
 lda rs_contact_pair_a,y
 tax
 lda rs_contact_pair_b,y
 tay
 jsr RS_RESOLVE
rs_contact_pair_next:
 inc rs_contact_pair
 lda rs_contact_pair
 cmp #RS_PAIRS
 bcc rs_contact_pair_loop
 lda rs_contact_hits
 beq rs_contact_success
 inc rs_contact_pass
 lda rs_contact_pass
 cmp #RS_PASSES
 bcc rs_contact_pass_start
rs_contact_rollback:
'''
    for j,ch in enumerate(positions):
        code+=f' ldx #{bodies-1}\nrs_contact_restore_{j}:\n lda rs_contact_old_{j}_lo,x\n sta {ch["low"]},x\n lda rs_contact_old_{j}_hi,x\n sta {ch["high"]},x\n dex\n bpl rs_contact_restore_{j}\n'
    for j,ch in enumerate(velocities):
        code+=f' ldx #{bodies-1}\nrs_contact_damp_{j}:\n lda {ch["high"]},x\n cmp #128\n ror\n sta {ch["high"]},x\n lda {ch["low"]},x\n ror\n sta {ch["low"]},x\n dex\n bpl rs_contact_damp_{j}\n'
    code+=''' lda #1
 sta rs_contact_status
 lda #0
 sta rs_contact_valid
rs_contact_bad:
 clc
 rts
rs_contact_success:
 lda #0
 sta rs_contact_status
 sta rs_contact_valid
 sec
 rts
rs_contact_valid: .byte 0
rs_contact_status: .byte 0
rs_contact_queries: .word 0
rs_contact_pass: .byte 0
rs_contact_hits: .byte 0
rs_contact_pair: .byte 0
'''
    for old,new in [('RS_BUDGET',str(budget)),('RS_QUERY',query),('RS_RESOLVE',resolve),('RS_PAIRS',str(len(pairs))),('RS_PASSES',str(passes))]:code=code.replace(old,new)
    code+=data('rs_contact_pair_a',[a for a,b in pairs])+data('rs_contact_pair_b',[b for a,b in pairs])
    for j in range(len(positions)):
        code+=f'rs_contact_old_{j}_lo: .fill {bodies},0\nrs_contact_old_{j}_hi: .fill {bodies},0\n'
    return code
