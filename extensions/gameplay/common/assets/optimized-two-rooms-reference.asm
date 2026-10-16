; 3Dvibe64
; Realtime 3D bitmap engine for C64/VIC-II.
; - Multicolor bitmap, two 8 KB frame buffers.
; - 160x100 logical lowres renderer expanded to 320x200 display pixels.
; - Data-driven indexed convex face mesh.
; - Realtime Euler rotation.
; - True perspective through reciprocal z scale table.
; - One lowres material family selected from the C64 palette.
; - Material families and reflectivity are table-driven; scene objects may pin either one or follow the active keyboard values.

* = $0801
 .byte $0b,$08,$0a,$00,$9e
 .text "2061"
 .byte 0,0,0

* = $080d

angx = $02
angy = $03
angz = $04
sinxv = $05
cosxv = $06
sinyv = $07
cosyv = $08
sinzv = $09
coszv = $0a
drawbuf = $0b
mode4_current_face_id = $0c
faceidx = $0d
t1 = $0e
t2 = $0f
vx0 = $10
vy0 = $11
vx1 = $12
vy1 = $13
vx2 = $14
vy2 = $15
ex0 = $16
ey0 = $17
ex1 = $18
ey1 = $19
dxabs = $1a
dyval = $1b
sxstep = $1c
ycur = $1d
xcur = $1e
errlo = $1f
errhi = $20
ptr0lo = $21
ptr0hi = $22
ptr1lo = $23
ptr1hi = $24
row0lo = $25
row0hi = $26
row1lo = $27
row1hi = $28
leftval = $29
rightval = $2a
startbyte = $2b
endbyte = $2c
maskv = $2d
multmp = $2e
yrow = $2f
mula = $30
mulb = $31
mulsign = $32
prodlo = $33
prodhi = $34
rx0 = $35
ry0 = $36
rz0 = $37
rx1 = $38
ry1 = $39
rz1 = $3a
scalev = $3b
fullcount = $3c
dx1v = $3d
dy1v = $3e
dx2v = $3f
dy2v = $40
p1lo = $41
p1hi = $42
crosslo = $43
crosshi = $44
dirty_ymin_a = $45
dirty_ymax_a = $46
dirty_ymin_b = $47
dirty_ymax_b = $48
maxrow = $49
shadeidx = $4a
fillbyte = $4b
face_ymin = $4c
face_ymax = $4d
bucket_min = $4e
bucket_max = $4f
sorti = $50
sortj = $51
tmpidx = $52
vx3 = $53
vy3 = $54
pattoggle = $55
m00 = $56
m01 = $57
m02 = $58
m10 = $59
m11 = $5a
m12 = $5b
m20 = $5c
m21 = $5d
m22 = $5e
spanw = $5f
spanh = $60
active_vfirst = $61
active_vend = $62
active_face_first = $63
active_face_end = $64
meshidx = $65
space_latch = $66
auto_cycle_counter = $67
active_material = $69
light_phase = $6a
light_tick = $6b
shadeptrlo = $6c
shadeptrhi = $6d
material_latch = $6e
sh_nx = $6f
sh_ny = $70
sh_nz = $71
light_intensity = $72
active_reflect_offset = $73
reflect_latch = $74
sh_lx = $75
motion_z_frac = $76
motion_z_lo = $77
dotlo = $78
dothi = $79
motion_z_hi = $7a
objidx = $7b
obj_pos_x_cur = $7c
obj_pos_y_cur = $7d
obj_depth_lo = $7e
obj_scale_cur = $7f
obj_depth_hi = $80
obj_depth_frac = $81
explorer_z_world_hi = $82
explorer_z_hi16 = $83
mul16lo = $84
mul16hi = $85
mul16mul = $86
mul16abs = $87
mul16rem = $88
mul16reslo = $89
mul16reshi = $8a
mul16sign = $8b
loaded_face_vertex_count = $8c
clip_in_x = $8d
clip_in_y = $8e
clip_out_y = $8f
clip_num = $90
clip_den = $91
clip_second_pending = $92
clip_second_count = $93
clip2_vx0 = $94
clip2_vy0 = $95
clip2_vx1 = $96
clip2_vy1 = $97
clip2_vx2 = $98
clip2_vy2 = $99
clip2_vx3 = $9a
clip2_vy3 = $9b
clip_poly_active = $9c
clip_a_count = $9d
clip_b_count = $9e
clip_prev_idx = $9f
clip_cur_idx = $a0
clip_prev_inside = $a1
clip_cur_inside = $a2
clip_out_x = $a3
object_traverse_active = $a4
near_face_crossing = $a5
q2_x0lo = ex0
q2_x0hi = ex1
q2_x1lo = m02
q2_x1hi = m10
q2_step_lo = prodlo
q2_step_hi = prodhi
q2_remainder = errlo
q2_rem_step = errhi
vxq2_0lo = rx0
vxq2_0hi = ry0
vxq2_1lo = rz0
vxq2_1hi = rx1
vxq2_2lo = ry1
vxq2_2hi = rz1
vxq2_3lo = m00
vxq2_3hi = m01
.if vxq2_0lo = vxq2_0hi || vxq2_0lo = vxq2_1lo || vxq2_0lo = vxq2_1hi || vxq2_0lo = vxq2_2lo || vxq2_0lo = vxq2_2hi || vxq2_0lo = vxq2_3lo || vxq2_0lo = vxq2_3hi || vxq2_0hi = vxq2_1lo || vxq2_0hi = vxq2_1hi || vxq2_0hi = vxq2_2lo || vxq2_0hi = vxq2_2hi || vxq2_0hi = vxq2_3lo || vxq2_0hi = vxq2_3hi || vxq2_1lo = vxq2_1hi || vxq2_1lo = vxq2_2lo || vxq2_1lo = vxq2_2hi || vxq2_1lo = vxq2_3lo || vxq2_1lo = vxq2_3hi || vxq2_1hi = vxq2_2lo || vxq2_1hi = vxq2_2hi || vxq2_1hi = vxq2_3lo || vxq2_1hi = vxq2_3hi || vxq2_2lo = vxq2_2hi || vxq2_2lo = vxq2_3lo || vxq2_2lo = vxq2_3hi || vxq2_2hi = vxq2_3lo || vxq2_2hi = vxq2_3hi || vxq2_3lo = vxq2_3hi
 .error "LegacyDirect endpoint Q2 scratch aliases"
.endif
.if q2_x0lo > $a5 || q2_x0hi > $a5 || q2_x1lo > $a5 || q2_x1hi > $a5 || q2_step_lo > $a5 || q2_step_hi > $a5 || q2_remainder > $a5 || q2_rem_step > $a5
 .error "LegacyDirect walker Q2 zero-page state is outside the private range"
.endif
vyq2_0lo = $a6
vyq2_0hi = $a7
vyq2_1lo = $a8
vyq2_1hi = $a9
vyq2_2lo = $aa
vyq2_2hi = $ab
vyq2_3lo = $ac
vyq2_3hi = $ad
.if vyq2_0lo <= near_face_crossing || vyq2_3hi != vyq2_0lo + 7
 .error "MobileNative endpoint Y-Q2 scratch must be private contiguous zero page above clipping state"
.endif
FACE_COUNT = $40
FACE_BUCKET_USED_LIST_CAPACITY = $0040
VERT_COUNT = $2E
SOURCE_FACE_COUNT = $40
SOURCE_VERT_COUNT = $2E
SHADE_VERT_COUNT = $74
SOURCE_SHADE_VERT_COUNT = $74
MEMORY_LAYOUT_HIGH_BASIC_V2 = $01
BITMAP_B_BASE = $2000
SCREEN_B_BASE = $0400
RUNTIME_BUFFER_LIMIT = $A000
; high-basic-v2 memory contract used by the mixed solid/wire path.
; $4e30-$5bff is free between the middle code and bitmap A; $8000-$9fff is
; runtime-only; high code starts at $a000 and may grow only up to I/O at $d000.
HIGH_BASIC_V2_STATIC_LOW_BASE = $4e30
HIGH_BASIC_V2_STATIC_LOW_LIMIT = $5c00
HIGH_BASIC_V2_RUNTIME_BASE = $8000
HIGH_BASIC_V2_RUNTIME_LIMIT = $a000
HIGH_BASIC_V2_CODE_HIGH_BASE = $a000
HIGH_BASIC_V2_IO_BASE = $d000
HIGH_BASIC_V2_RELOCATED_CODE_BASE = $9000
VIC_BANK_B_BITS = $03
VIC_D018_B = $18
MESH_COUNT = $02
SCENE_OBJECT_COUNT = $02
OBJECT_MODEL_CONTRACT_VERSION = $01
WORLD_SPACE_Z_UP = $01
OBJECT_SPACE_ALIGNED_WORLD = $01
SCENE_WORLD_OBJECT_PRESENT = $01
SCENE_CAMERA_OBJECT_PRESENT = $01
SCENE_LIGHT_OBJECT_COUNT = $01
SCENE_PRIMARY_LIGHT_INDEX = $00
SCENE_EXTRA_LIGHT_IGNORED_COUNT = $00
SCENE_MESH_OBJECT_COUNT = $02
MESH_INSTANCE_EXPANSION_MODE = $01
MESH_SOURCE_SHARING_RUNTIME = $00
MESH_OBJECT_KIND_MESH = $01
MESH_GEOMETRY_SOLID = $00
MESH_GEOMETRY_WIRE = $01
MESH_WIRE_IS_SPECIALIZED_MESH = $01
MESH_MATERIAL_SINGLE = $00
MESH_MATERIAL_MULTIMATERIAL = $01
MESH_MULTIMATERIAL_IS_SOLID_MESH = $01
SCENE_SOLID_MESH_OBJECT_COUNT = $02
SCENE_WIRE_MESH_OBJECT_COUNT = $00
SCENE_SINGLE_MATERIAL_MESH_OBJECT_COUNT = $00
SCENE_MULTIMATERIAL_MESH_OBJECT_COUNT = $02
SCENE_FACE_MATERIAL_TABLE_ACTIVE = $01
SCENE_FACE_SOLID_COLOR_TABLE_REQUESTED = $00
SCENE_POS_ACTIVE = $00
SCENE_VEL_X_ACTIVE = $00
SCENE_VEL_Y_ACTIVE = $00
SCENE_VEL_Z_ACTIVE = $00
SCENE_ROT_ACTIVE = $00
SCENE_ANG_X_ACTIVE = $00
SCENE_ANG_Y_ACTIVE = $00
SCENE_ANG_Z_ACTIVE = $00
SCENE_OBJECT_X_ACTIVE = $00
SCENE_OBJECT_Y_ACTIVE = $00
SCENE_OBJECT_SCALE_ACTIVE = $00
SCENE_OBJECT_VISIBILITY_ACTIVE = $00
SCENE_INSTANCE_OVERRIDES = $00
SCENE_INSTANCE_COLOR_OVERRIDE = $00
SCENE_FACE_MATERIAL_OVERRIDE = $01
SCENE_INSTANCE_MATERIAL_ALL_PINNED = $00
SCENE_INSTANCE_REFLECT_ALL_PINNED = $00
SCENE_TIMELINE_ENABLE = $00
SCENE_TIMELINE_STATE_COUNT = $00
SCENE_TIMELINE_INITIAL_STATE = $00
SCENE_GRAPHIC_INCLUDE_ENABLE = $00
SCENE_RESPAWN_ACTIVE = $00
SCENE_OSC_X_ACTIVE = $00
; === Projection Contract ===
; PROJECTION_CONTRACT_ACTIVE=1
; DEMO_PROJECTION_FOCAL=85
; PROJECTION_CONTRACT_CENTER_X=80
; PROJECTION_CONTRACT_CENTER_Y=50
; PROJECTION_CONTRACT_SCREEN_MAX_X=159
; PROJECTION_CONTRACT_SCREEN_MAX_Y=99
; PROJECTION_CONTRACT_VIEW_DEPTH_BIAS=190
; PROJ_VIEW_DEPTH_BIAS is a projection-index origin only.  Camera geometry,
; near clipping, culling, sorting, and depth buckets must never include it.
; WalkPerspectiveAlignedToSimpleCamera=1
; WalkYawPivotPreserved=1
; Projection Contract placeholder

PROJ_MODE_EXTENDED_TABLE = $01
PROJ_FOCAL = $55
PROJ_CENTER_X = $50
PROJ_CENTER_Y = $32
PROJ_SCREEN_MIN_X = $00
PROJ_SCREEN_MAX_X = $9F
PROJ_SCREEN_MIN_Y = $00
PROJ_SCREEN_MAX_Y = $63
PROJ_NEAR_MIN_DEPTH = $20
PROJ_CAMERA_FACE_MIN_DEPTH = $02
CAMERA_PLANE_CLIP_PROFILE = $01
CAMERA_SPACE_FACE_CULL_SUPPORT = $01
STABLE_FACE_CULL_PROFILE = $00
PROJ_VIEW_DEPTH_BIAS = $BE
PROJ_VIEW_DEPTH_BIAS_HI = $00
PROJ_FAR_DEPTH_CLAMP = $21
PROJ_FRUSTUM_X_NEAR = $28
PROJ_FRUSTUM_Y_NEAR = $19
PROJ_FRUSTUM_FOCAL = $2A
PROJ_CENTER_X_HALF = $28
PROJECTION_CONTRACT_ACTIVE = $01

; === Mode 4 Y-Q2 Viewport Contract ===
YQ2_VIEWPORT_CENTER_LO = $C8
YQ2_VIEWPORT_CENTER_HI = $00
; Native fixed projection yields 256+offset before it is centred.
YQ2_VIEWPORT_NATIVE_BASE_HI = $01
YQ2_VIEWPORT_MAX_LO = $8C
YQ2_VIEWPORT_MAX_HI = $01
YQ2_VIEWPORT_ROW_MAX = $63
YQ2_VIEWPORT_ROW_COUNT = $64
YQ2_VIEWPORT_CENTER_PLUS_ONE = $C9
YQ2_VIEWPORT_BELOW_CENTER_LIMIT_PLUS_ONE = $C5

; === Engine Camera Viewport Contract ===
ENGINE_CAMERA_VIEWPORT_CONFIGURABLE = $01
ENGINE_CAMERA_VIEWPORT_ALL_MODES = $01
ENGINE_CAMERA_VIEWPORT_SMALL = $00
ENGINE_CAMERA_VIEWPORT_PROFILE_ID = $00
ENGINE_CAMERA_VIEWPORT_PROJECTION_SCALED = $00
ENGINE_CAMERA_VIEWPORT_CLEAR_LIMITED = $00
MODE6_VIEWPORT_CLEAR_SPECIALIZED = $00
ENGINE_CAMERA_VIEWPORT_GROUND_LIMITED = $00
CAMERA_VIEWPORT_WIDTH = $A0
CAMERA_VIEWPORT_HEIGHT = $64
CAMERA_VIEWPORT_ORIGIN_X = $00
CAMERA_VIEWPORT_ORIGIN_Y = $00
CAMERA_VIEWPORT_CELL_ORIGIN_X = $00
CAMERA_VIEWPORT_CELL_WIDTH = $28
CAMERA_VIEWPORT_BITMAP_X_OFFSET = $00

; === 3Dvibe64 Renderer Contract ===
RENDERER_ACTIVE = $01
RENDERER_PLAN_ACTIVE = $01
RENDERER_PLAN_APPLIED = $01
GROUND_RENDER_MODE_NONE = $00
GROUND_RENDER_MODE_SIMPLE = $01
GROUND_RENDER_MODE_FULL = $02
GROUND_RENDER_MODE_HORIZON = $03
GROUND_RENDER_MODE = $00
GROUND_SIMPLE_PREFILL = $00
GROUND_HORIZON_ONLY = $00
GROUND_FULL_PLANE = $00
GROUND_OCCLUSION_ENABLE = $00
GROUND_WIRE_OCCLUSION_ENABLE = $00
GROUND_ROLL_PLANE_ENABLE = $00
FRAME_WORLD_PREFILL_ENABLE = $00
VIC_COLOR_POLICY_RUNTIME_ENABLE = $00
ENGINE_VIC_STATIC_POLICY = $01
ENGINE_CAMERA_LIMITS_ENABLE = $01
CAMERA_FULL_ENABLE = $00
ENGINE_CAMERA_PROFILE_RUNTIME_ACTIVE = $01
ENGINE_CAMERA_WALK_LITE_RUNTIME_ACTIVE = $01
ENGINE_CAMERA_MODE_CYCLE_RUNTIME_ACTIVE = $00
ENGINE_CAMERA_ROLL_RUNTIME_ACTIVE = $00
ENGINE_CAMERA_PITCH_ROLL_LOCK_ACTIVE = $00
ENGINE_CAMERA_WALK_LITE_PITCH_RUNTIME_ACTIVE = $01
ENGINE_CAMERA_WALK_LITE_PITCH_ALL_MODES = $01
ENGINE_CAMERA_WALK_LITE_YAW_PITCH_ONLY = $01
ENGINE_CAMERA_WALK_LITE_PITCH_ZERO_FASTPATH = $01
ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH = $01
ENGINE_CAMERA_FOLDED_PITCH_ZERO_FASTPATH = $01
ENGINE_CAMERA_ROLL_LOCK_ACTIVE = $01
CAMERA_FULL_RUNTIME_ACTIVE = $00
ENGINE_MODE_BUDGET_ENABLE = $01
ENGINE_FULL_RENDER_ENABLE = $00
DEPTH_BUCKETS_ENABLE = $01
FACE_FILL_CACHE_ENABLE = $01
DYNAMIC_SHADE_LEVEL = $00
RENDER_FRAME_SCAFFOLD_ACTIVE = $01
RENDER_FRAME_BEGIN_ACTIVE = $01
RENDER_WORLD_BACKGROUND_ACTIVE = $01
RENDER_SCENE_PIPELINE_ACTIVE = $01
RENDER_FRAME_END_ACTIVE = $01
ENGINE_GROUND_SIMPLE_RUNTIME_ACTIVE = $00
ENGINE_GROUND_HORIZON_ONLY_RUNTIME_ACTIVE = $00
ENGINE_MODE3_FRAME_PREFILL_RUNTIME_ACTIVE = $00
ENGINE_MODE3_CLEAR_GROUND_FUSED = $00
ENGINE_MODE3_GROUND_CELLROW_WRITE_ON_CHANGE = $00
ENGINE_MODE3_PREFILL_FALLBACK = $00
ENGINE_MODE3_FACE_PREPARE_ONCE = $00
ENGINE_MODE3_PREPARED_FACE_STATE_CACHE = $00
ENGINE_MODE3_UNCLIPPED_FACE_FASTLOAD = $00
ENGINE_MODE3_CLIP_FALLBACK = $00
ENGINE_MODE3_DRAW_RECHECK_STRIPPED = $00
ENGINE_MODE3_DIRECT_CONVEX_FILL = $00
ENGINE_MODE3_DIRECT_CONVEX_PREPARED_ONLY = $00
ENGINE_MODE3_DIRECT_CONVEX_CLIP_FALLBACK = $00
ENGINE_MODE3_DIRECT_CONVEX_TRI_QUAD = $00
ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL = $00
ENGINE_MODE3_NATIVE_CONVEX_QUAD_PREPARED_ONLY = $00
ENGINE_MODE3_NATIVE_CONVEX_QUAD_SINGLE_SPAN = $00
ENGINE_MODE3_NATIVE_CONVEX_QUAD_FAN_FALLBACK = $00
ENGINE_MODE3_NATIVE_CONVEX_QUAD_TRIANGLES_UNCHANGED = $00
ENGINE_MODE3_FAST_BOUNDS_TRACE = $00
ENGINE_MODE3_FAST_BOUNDS_8BIT = $00
ENGINE_MODE3_FAST_BOUNDS_DIRECT_LEFT_RIGHT = $00
ENGINE_MODE3_FAST_BOUNDS_OVERFLOW_FALLBACK = $00
ENGINE_MODE4_FAST_BOUNDS_TRACE = $00
ENGINE_MODE4_FAST_BOUNDS_8BIT = $00
ENGINE_MODE4_FAST_BOUNDS_DIRECT_LEFT_RIGHT = $00
ENGINE_MODE4_FAST_BOUNDS_OVERFLOW_FALLBACK = $00
ENGINE_MODE3_SPAN_HOTLOOP = $00
ENGINE_MODE3_DIRECT_INDEXED_SPANS = $00
ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS = $00
ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE = $00
ENGINE_MODE3_MATERIAL_CELL_TRANSITION = $00
ENGINE_MODE3_FRAME_PREFILL_COMPATIBLE = $01
ENGINE_MODE3_CONSOLIDATION = $00
MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE = $01
ENGINE_MODE3_CONSOLIDATION_CHECK = $00
ENGINE_MODE3_UNIVERSAL_PATHS_ONLY = $00
ENGINE_MODE3_COMPACT_FACE_QUEUE = $00
ENGINE_MODE3_NORMAL_VIEWPORT_SUPPORTED = $00
ENGINE_MODE3_SMALL_VIEWPORT_SUPPORTED = $00
ENGINE_MODE3_MULTI_OBJECT_SUPPORTED = $00
ENGINE_MODE3_FALLBACKS_PRESERVED = $00
ENGINE_MODE3_STABLE_GROUND_CELL_LAYOUT = $00
ENGINE_MODE3_STABLE_GROUND_AUTO = $00
ENGINE_MODE3_STABLE_GROUND_MULTI_OBJECT = $00
ENGINE_MODE3_STABLE_GROUND_SHARED_RAMP = $00
ENGINE_MODE3_STABLE_GROUND_SLOT_01 = $00
ENGINE_MODE3_STABLE_GROUND_OBJECT_SLOT_10 = $00
ENGINE_MODE3_STABLE_GROUND_OBJECT_SLOT_11 = $00
ENGINE_MODE3_STABLE_GROUND_COLORRAM_WRITE_STRIPPED = $00
ENGINE_MODE3_STABLE_GROUND_DOUBLE_BUFFER_SAFE = $00
ENGINE_MODE3_ADAPTIVE_CELL_POLICY = $00
ENGINE_MODE3_ADAPTIVE_SHARED_RAMP_EXACT = $00
ENGINE_MODE3_ADAPTIVE_SCREEN_PAIR_LAYOUT = $00
ENGINE_MODE3_ADAPTIVE_MULTI_RAMP = $00
ENGINE_MODE3_ADAPTIVE_GROUND_SLOT_11 = $00
ENGINE_MODE3_ADAPTIVE_OBJECT_SLOTS_01_10 = $00
ENGINE_MODE3_ADAPTIVE_COLORRAM_FIXED_GROUND = $00
ENGINE_MODE3_ADAPTIVE_HIGHLIGHT_FOLD_HIGH = $00
ENGINE_MODE3_ADAPTIVE_FACE_SOLID_COLOR = $00
ENGINE_MODE3_ADAPTIVE_DOUBLE_BUFFER_SAFE = $00
ENGINE_MODE3_ADAPTIVE_RUNTIME_MATERIAL_SAFE = $00
ENGINE_MODE3_ADAPTIVE_USER_CELL_CONFLICT = $00
ENGINE_MODE3_DEMO_CELL_COLOR_STABILITY = $00
ENGINE_MODE3_DEMO_THREE_COLOR_LAYOUT = $00
ENGINE_MODE3_DEMO_GROUND_SLOT_01_PRESERVED = $00
ENGINE_MODE3_DEMO_OBJECT_SLOT_10 = $00
ENGINE_MODE3_DEMO_OBJECT_SLOT_11 = $00
ENGINE_MODE3_DEMO_STATIC_SHADING_RESTORED = $00
ENGINE_MODE3_DEMO_NO_FACE_SOLID_OVERRIDE = $00
ENGINE_MODE3_DEMO_SHADE_FAMILY_REENCODED = $00
ENGINE_MODE3_DEMO_VIC_POLICY_OFF = $00
ENGINE_MODE3_DEMO_GROUND_BITMAP_SLOT_01 = $00
ENGINE_MODE3_DEMO_GROUND_COLORRAM_WRITE_STRIPPED = $00
ENGINE_MODE3_DEMO_DOUBLE_BUFFER_COLOR_STABLE = $00
GROUND_FULL_RUNTIME_ACTIVE = $00
VIC_BITMAP_MULTICOLOR_ENABLE = $01
VIC_BITMAP_SINGLE_PIXEL_ENABLE = $00
ENGINE_GRAPHICS_MODE = $07
ENGINE_RENDER_STYLE_WIRE = $00
ENGINE_RENDER_STYLE_HIDDEN_WIRE = $00
ENGINE_WIRE_MODE_RUNTIME_ACTIVE = $00
ENGINE_WIRE_SPEED_PASS_1 = $00
ENGINE_WIRE_SPEED_PASS_2 = $00
ENGINE_WIRE_SPEED_PASS_3 = $00
ENGINE_WIRE_DIRTY_CLEAR_ENABLE = $00
ENGINE_WIRE_HORIZON_DIRECT_DRAW = $00
ENGINE_WIRE_SOLID_FEATURES_STRIPPED = $00
ENGINE_MODE2_MASK_DIRTY_TRACK_ENABLE = $00
ENGINE_WIRE_CELL_WRITE_SKIP_SAME = $00
ENGINE_WIRE_MATERIAL_CACHE_RESET_FRAME = $00
ENGINE_MODE2_MASK_COLOR_WRITES_STRIPPED = $00
ENGINE_WIRE_LIGHT_SHADING_STRIPPED = $00
ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = $00
ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE = $00
ENGINE_WIRE_MATERIAL_COMPARE_STRIPPED = $00
ENGINE_MODE1_FACE_PASS_STRIPPED = $00
ENGINE_MODE1_EDGE_TABLE_DIRECT = $00
MODE1_OBJECT_DEPTH_SORT = $00
MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = $00
MODE2_FACE_BUCKET_PIPELINE = $00
ENGINE_MODE1_WIRE_FAST_PLOT = $00
ENGINE_MODE1_WIRE_INSCREEN_FASTPATH = $00
ENGINE_MODE1_WIRE_CLIP_FALLBACK = $00
ENGINE_MODE1_UNIVERSAL_EDGE_TRAVERSAL = $00
ENGINE_MODE1_PROJDONE_DIRECT_TEST = $00
ENGINE_MODE1_VERTEX_DRAWABLE_FALLBACK = $00
ENGINE_MODE1_WIRE_RASTER_HOTLOOP = $00
ENGINE_MODE1_WIRE_POINT_BOUNDS_STRIPPED = $00
ENGINE_MODE1_WIRE_POINT_DIRECT_ENTRY = $00
ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE = $00
ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE = $00
ENGINE_MODE2_WIRE_RASTER_HOTLOOP = $00
ENGINE_MODE2_WIRE_POINT_BOUNDS_STRIPPED = $00
ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE = $00
ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE = $00
ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW = $00
ENGINE_MODE2_WIRE_CLIP_GUARD_FALLBACK = $00
ENGINE_WIRE_SCANLINE_RUN_RASTERIZER = $00
ENGINE_WIRE_SCANLINE_RUN_SHALLOW_ONLY = $00
ENGINE_WIRE_SCANLINE_RUN_POINT_FALLBACK = $00
ENGINE_WIRE_SCANLINE_RUN_ENDPOINT_STATE_PRESERVED = $00
ENGINE_MODE1_SCANLINE_RUN_RUNTIME_ACTIVE = $00
ENGINE_MODE2_SCANLINE_RUN_RUNTIME_ACTIVE = $00
ENGINE_WIRE_STEEP_LINE_FASTPATH = $00
ENGINE_WIRE_STEEP_RATIO_2_TO_1 = $00
ENGINE_WIRE_VERTICAL_RUN_WRITER = $00
ENGINE_WIRE_STEEP_POINT_FALLBACK = $00
ENGINE_WIRE_STEEP_ENDPOINT_STATE_PRESERVED = $00
ENGINE_MODE1_STEEP_LINE_RUNTIME_ACTIVE = $00
ENGINE_MODE2_STEEP_LINE_RUNTIME_ACTIVE = $00
ENGINE_WIRE_CELL_TRANSITION_UPDATES = $00
ENGINE_WIRE_DIRTY_SAME_BYTE_SKIP = $00
ENGINE_WIRE_MATERIAL_CALL_ON_CELL_CHANGE = $00
ENGINE_WIRE_MATERIAL_DIRECT_WRITE_ENTRY = $00
ENGINE_WIRE_TRANSITION_CACHE_RESET_FRAME = $00
ENGINE_MODE1_CELL_TRANSITION_RUNTIME_ACTIVE = $00
ENGINE_MODE2_CELL_TRANSITION_RUNTIME_ACTIVE = $00
ENGINE_WIRE_8BIT_BRESENHAM = $00
ENGINE_WIRE_8BIT_INTERMEDIATE_SLOPES = $00
ENGINE_WIRE_8BIT_ERROR_ACCUMULATOR = $00
ENGINE_WIRE_16BIT_TRACE_FALLBACK = $00
ENGINE_MODE1_8BIT_BRESENHAM_RUNTIME_ACTIVE = $00
ENGINE_MODE2_8BIT_BRESENHAM_RUNTIME_ACTIVE = $00
ENGINE_WIRE_RASTER_CONSOLIDATION = $00
ENGINE_WIRE_SINGLE_SLOPE_DISPATCH = $00
ENGINE_WIRE_SINGLE_TRACE_GATE = $00
ENGINE_WIRE_TRACE_FALLBACK = $00
ENGINE_MODE1_RASTER_CONSOLIDATION_RUNTIME_ACTIVE = $00
ENGINE_MODE2_RASTER_CONSOLIDATION_RUNTIME_ACTIVE = $00
ENGINE_MODE2_HORIZON_ROW_MASK_CANDIDATE = $00
ENGINE_MODE2_HORIZON_ROW_MASK_RUNTIME_ACTIVE = $00
ENGINE_WIRE_HORIZON_ONLY_RUNTIME_ACTIVE = $00
ENGINE_WIRE_VIC_POLICY_FORCED_OFF = $00
VIC_COLOR_POLICY_REQUESTED_ENABLE = $00
VIC_COLOR_POLICY_REQUESTED_ACTIVE = $00
VIC_COLOR_POLICY_EFFECTIVE_ENABLE = $00
VIC_COLOR_POLICY_EFFECTIVE_ACTIVE = $00
WIRE_MATERIAL_COLOR_ENABLE = $00
WIRE_OBJECT_MATERIAL_PATH_ENABLE = $00
ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE = $00
ENGINE_GROUND_HORIZON_MATERIAL_ISOLATED = $00
ENGINE_GROUND_HORIZON_MATERIAL_RESTORE = $00
ENGINE_MESH_WIRE_MATERIAL_RELOAD_AFTER_GROUND = $00
ENGINE_WIRE_CAMERA_THROUGH_MESH_ENABLE = $00
ENGINE_WIRE_NEAR_CLIP_RELAXED = $00
ENGINE_WIRE_OBJECT_REJECT_RELAXED = $00
ENGINE_WIRE_EDGE_CLIP_TOLERANT = $00
ENGINE_MODE2_FACE_MASK_NEAR_TOLERANT = $00
GROUND_HORIZON_DARK_GREY_ENABLE = $00
ENGINE_GROUND_HORIZON_SCREEN_BYTE = $bb
ENGINE_GROUND_HORIZON_COLOR_RAM = $0b
ENGINE_GROUND_HORIZON_COLOR = $0b
GROUND_RUNTIME_OCCLUSION_ENABLE = $00
GROUND_RUNTIME_WIRE_OCCLUSION_ENABLE = $00
GROUND_RUNTIME_ROLL_PLANE_ENABLE = $00
ENGINE_MODE1_WIRE_PURE_RUNTIME_ACTIVE = $00
ENGINE_MODE1_WIRE_RENDER_RUNTIME_ACTIVE = $00
ENGINE_MODE1_WIRE_FACE_EDGE_RUNTIME_ACTIVE = $00
ENGINE_MODE1_HIDDEN_WIRE_RUNTIME_ACTIVE = $00
ENGINE_MODE1_POLY_FILL_RUNTIME_ACTIVE = $00
ENGINE_MODE1_WIRE_DEPTH_SORT_RUNTIME_ACTIVE = $00
ENGINE_MODE1_WIRE_OBJECT_SORT_RUNTIME_ACTIVE = $00
ENGINE_MODE1_VIC_POLICY_RUNTIME_ACTIVE = $00
ENGINE_MODE1_GROUND_OCCLUSION_RUNTIME_ACTIVE = $00
ENGINE_MODE2_HIDDEN_WIRE_RUNTIME_ACTIVE = $00
ENGINE_MODE2_WIRE_RENDER_RUNTIME_ACTIVE = $00
ENGINE_MODE2_POLY_FILL_RUNTIME_ACTIVE = $00
ENGINE_MODE2_VIC_POLICY_RUNTIME_ACTIVE = $00
ENGINE_MODE2_FACE_MASK_CONTRACT_ENABLE = $00
ENGINE_MODE2_FACE_MASK_RUNTIME_ACTIVE = $00
ENGINE_MODE2_HORIZON_BEHIND_FACE_TARGET = $00
ENGINE_MODE2_HORIZON_BEHIND_FACE_RUNTIME_ACTIVE = $00

; Historical aliases
EXPLORER_PROJ_FOCAL = PROJ_FOCAL
CAMERA_FACE_MIN_DEPTH = $01
FACE_REFLECTIVITY_ACTIVE_ONLY = $00
FACE_MATERIAL_ACTIVE_ONLY = $00
FACE_SOLID_COLOR_ENABLE = $00
VIC_COLOR_POLICY_ENABLE = $00
VIC_COLOR_POLICY_ACTIVE = $00
VIC_COLOR_POLICY_OVERLAY = $00
VIC_COLOR_FALLBACK_MODE = $00
MATERIAL_CELL_SPAN_CACHE = $01
LAZY_CONVEX_BOUNDS = $00
DIRECT_CONVEX_EDGE_SPANS = $01
SPAN_KERNEL_FILL = $01
INDEXED_OFFSET_SPAN_FILL = $00
DIRECT_CONVEX_FAN_FILL = $00
GRAPHICS_MODE = $07
RUNTIME_GRAPHICS_MODE_SWITCH = $00
WIRE_MESH_COUNT = $00
WIRE_EDGE_COUNT = $00
WIRE_DEPTH_ENTRY_COUNT = $00
WIRE_RENDER_ENABLE = $00
WIRE_OVERLAY_ENABLE = $00
WIRE_DEPTH_SORT_ENABLE = $00
WIRE_OBJECT_SORT_ENABLE = $00
WIRE_DEPTH_NEAR_BIAS = $01
WIRE_OBJECT_MATERIAL_ENABLE = $00
HIDDEN_WIRE_ENABLE = $00
HIDDEN_WIRE_DEPTH_BIAS = $30
WIRE_FACE_EDGE_ENABLE = $00
WIRE_EDGE_SOLID_COLOR_ENABLE = $00
WIRE_TWO_COLOR_MULTIMATERIAL_ENABLE = $00
WIRE_TWO_COLOR_MODE1_ENABLE = $00
WIRE_TWO_COLOR_MODE2_ENABLE = $00
WIRE_TWO_COLOR_SLOT_01_COLOR = $00
WIRE_TWO_COLOR_SLOT_10_COLOR = $00
WIRE_TWO_COLOR_SCREEN_BYTE = $00
WIRE_TWO_COLOR_FIXED_COLOR_RAM = $00
POLY_FILL_ENABLE = $01
FAST_FILL_BOUNDS_TRACE = $00
FACE_RENDER_ENABLE = $01
WIRE_PURE_ENABLE = $00
STATIC_SHADE_CACHE = $00
FULL_DYNAMIC_SHADE = $00
FLAT_DYNAMIC_SHADE = $00
MODE7_UV_CARRIER = $01
GOURAUD_BYTE_SPAN_KERNEL = $01
MODE4_DYNAMIC_SHADE_THRESHOLD_FIX = $00
STATIC_SHADE_DIRECT = $00
FRAME_FACE_FILL_CACHE = $00
MODE4_OBJECT_LIGHT_CACHE = $01
MODE4_UNCACHED_LIGHT_FALLBACK = $00
HAS_TRI_FACES = $01
FORCE_FACE_RENDER = $00
CONSERVATIVE_FACE_CULL = $01
STABLE_FACE_CULL_SCREEN_AREA_BAND = $40
STABLE_FACE_CULL_EDGE_EPSILON = $01
CONSERVATIVE_SLIVER_CULL = $01
CONSERVATIVE_CULL_NEG_AREA = $20
CONSERVATIVE_EDGE_CULL_NEG_AREA = $60
CONSERVATIVE_SLIVER_THIN_SPAN = $03
CONSERVATIVE_SLIVER_LONG_SPAN = $06
STANDARD_PROJECT_VERTEX = $00
FACE_CULL_PREP = $01
REFERENCE_PROJECTION = $00
EXTENDED_TABLE_PROJECTION = $01
EXPLORER_TABLE_PROJECTION = $00
AUTO_CYCLE_FRAMES = $00
RANDOM_MATERIAL_CYCLE = $00
RANDOM_MATERIAL_CYCLE_TICKS = $64
MOTION_Z_START_FRAC = $00
MOTION_Z_START_LO = $00
MOTION_Z_START_HI = $00
MOTION_Z_STEP_FRAC = $00
MOTION_Z_STEP_LO = $00
MOTION_Z_STEP_HI = $00
MOTION_Z_START_ON_RETURN = $00
MOTION_Z_START_ON_ZERO = $00
ANGLE_X_STEP_LO = $2b
ANGLE_X_STEP_HI = $00
ANGLE_Y_STEP_LO = $40
ANGLE_Y_STEP_HI = $00
ANGLE_Z_STEP_LO = $15
ANGLE_Z_STEP_HI = $00
MIN_FACE_AREA = $0A
SCENE_RENDER_MIN_Y = $00
VIDEO_STANDARD_AUTO = $00
VIDEO_STANDARD_FORCE_PAL = $01
VIDEO_STANDARD_FORCE_NTSC = $00
VIDEO_STANDARD_RUNTIME_DETECT = $00
VIDEO_PAL_VBLANKS_PER_SECOND = $32
VIDEO_NTSC_VBLANKS_PER_SECOND = $3c
SIMULATION_REFERENCE_HZ = $32
NTSC_SIM_TICKS_PER_6_VBLANKS = $05
VIDEO_STANDARD_INITIAL = $00
VIDEO_VBLANKS_PER_SECOND_INITIAL = $32
FPS_OVERLAY_ENABLE = $00
FPS_OVERLAY_ON_START = $00
FPS_COUNTER_ENABLE = $00
FPS_COUNTER_ONLY = $00
FPS_OVERLAY_MEMORY_CONTRACT = $01
FPS_OVERLAY_UNDER_IO_LAYOUT = $00
FPS_KEY_TOGGLE_ENABLE = $00
CONTROL_SPACE_KEY = $00
CONTROL_RETURN_KEY = $00
CONTROL_ROTATION_KEY = $00
CONTROL_LIGHT_KEY = $00
CONTROL_LOWRES_KEY = $00
CONTROL_ZERO_MOTION_KEY = $00
LOWRES_TRACE_ENABLE = $00
CONTROL_MATERIAL_KEYS = $00
CONTROL_REFLECTIVITY_KEYS = $00
REFLECTIVITY_CYCLE_OFFSET_LIMIT = $28
XCOORD_COUNT = $09
YCOORD_COUNT = $04
ZCOORD_COUNT = $0A
SCREEN_MIN_SPAN = $03
FAR_SCREEN_MIN_SPAN = $00
PATTERN_MIN_SPAN = $06
SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y = $01
MODE4_PATTERN_PROBE = $00
MODE4_PATTERN_PROBE_LATCHED_FACE = $00
MODE4_VALID_SHADE_FACE_PROBE = $00
MODE4_SHADE_STEP_LIMIT = $00
MODE5_POLYGON_OUTLINE = $00
YQ2_FAST_DIV11X8 = $01
YQ2_FAST_PIXEL_CONVERT = $01
YQ2_INLINE_BOUNDS = $01
MODE4_FACE_ID_LATCH = $01
FULL_CLEAR = $00
TRACK_DIRTY_SPANS = $00
DYNAMIC_LIGHT = $01
STATIC_RUNTIME_LIGHT = $00
STATIC_POSE = $00
INITIAL_ANGLE_X = $18
INITIAL_ANGLE_Y = $19
INITIAL_ANGLE_Z = $2F
LIGHT_PHASE_COUNT = $20
LIGHT_PHASE_MASK = $1F
LIGHT_TICK_DIV = $02
LIGHT_INTENSITY_MAX = $0A
LIGHT_PULSE_ON_SPACE = $00
MATERIAL_DEFAULT_INDEX = $00
MATERIAL_REFLECTIVITY = $00
MATERIAL_REFLECTIVITY_OFFSET = $00
MATERIAL_SCREEN_BYTE = $BF
MATERIAL_COLOR_RAM = $0F
WORLD_BACKGROUND_COLOR = $00
WORLD_GROUND_ENABLE = $00
WORLD_GROUND_COLOR = $05
WORLD_GROUND_SCREEN_BYTE = $55
WORLD_GROUND_COLOR_RAM = $05
WORLD_GROUND_Y_LO = $00
WORLD_GROUND_Y_HI = $00
WORLD_GROUND_Y_EXT = $00
WORLD_GROUND_PUBLIC_Z_LO = $00
WORLD_GROUND_PUBLIC_Z_HI = $00
WORLD_GROUND_PUBLIC_Z_EXT = $00
WORLD_GROUND_OCCLUDE = $00
WORLD_GROUND_PLANE_CLIP = $00
WORLD_GROUND_HORIZON_ONLY = $00
WORLD_GROUND_WIRE_OCCLUDE = $00
WORLD_GROUND_WIRE_MASK_HELPERS_AVAILABLE = $00
WIRE_GROUND_ROLL_X_BIAS = $B2
WIRE_GROUND_ROLL_Y_BIAS = $CE
WIRE_GROUND_ROLL_FOCAL_HALF = $55
WORLD_GROUND_HORIZON_BBOX_OCCLUDE = $00
WORLD_GROUND_ROLL_SPAN_EDGE = $00
WORLD_GROUND_VIC_POLICY_SCOPE = $00
.if WORLD_GROUND_WIRE_OCCLUDE != 0 && WORLD_GROUND_WIRE_MASK_HELPERS_AVAILABLE = 0
 .error "WORLD_GROUND_WIRE_OCCLUDE requires compact mask helpers"
.endif
CAMERA_INDEX = $00
CAMERA_HAS_POS = $01
CAMERA_HAS_ROT = $00
CAMERA_POS_X = $00
CAMERA_POS_Y = $00
CAMERA_POS_Z = $F6
CAMERA_M00 = $40
CAMERA_M01 = $00
CAMERA_M02 = $00
CAMERA_M10 = $00
CAMERA_M11 = $40
CAMERA_M12 = $00
CAMERA_M20 = $00
CAMERA_M21 = $00
CAMERA_M22 = $40
CAMERA_MOVABLE = $01
CAMERA_WALK_LITE = $01
CAMERA_SMOOTH_DEPTH_ACTIVE = $00
CAMERA_SMOOTH_DEPTH_PHASE_START = $00
CAMERA_SMOOTH_DEPTH_PHASE_STEP = $00
CAMERA_MODE_CYCLE = $00
EXPLORER_RUNTIME_MODE_INITIAL = $01
EXPLORER_MATRIX_FOLD = $01
CAMERA_RUNTIME_CONTROLS = $00
CAMERA_ROLL_ACTIVE = $00
CAMERA_ROLL_CONTROL = $00
EXPLORER_RESET_ON_SPACE = $00
EXPLORER_NEAR_CLIP = $00
EXPLORER_NEAR_SKIP_CROSS = $00
EXPLORER_NEAR_POLY = $00
MODE3_LATE_NEAR_NO_POLY = $00
CLIP_POLY_VERTEX_CAPACITY = 12
CAMERA_PLANE_CLIP_REQUIRED_VERTICES = 10
.if CAMERA_PLANE_CLIP_PROFILE != 0 && CLIP_POLY_VERTEX_CAPACITY < CAMERA_PLANE_CLIP_REQUIRED_VERTICES
 .error "camera-plane clip requires at least 10 vertices in the 12-vertex clip buffers"
.endif
EXPLORER_NEAR_FILL = $00
EXPLORER_NEAR_SKIP_DEPTH = $20
EXPLORER_TRAVERSAL_CULL = $00
EXPLORER_TRAVERSAL_HYSTERESIS = $10
EXPLORER_SCREEN_CLIP_X = $00
EXPLORER_SCREEN_CLIP_POLY = $01
EXPLORER_SCREEN_RAW = $01
EXPLORER_CAMERA_NEAR_CLIP = $00
EXPLORER_CAMERA_X_CLIP = $00
EXPLORER_CAMERA_X_LO = $00
EXPLORER_CAMERA_X_HI = $00
EXPLORER_CAMERA_X_EXT = $00
EXPLORER_CAMERA_Y_LO = $00
EXPLORER_CAMERA_Y_HI = $00
EXPLORER_CAMERA_Y_EXT = $00
EXPLORER_CAMERA_Z_LO = $00
EXPLORER_CAMERA_Z_HI = $F6
EXPLORER_CAMERA_Z_EXT = $FF
EXPLORER_CAMERA_YAW = $00
EXPLORER_CAMERA_PITCH = $00
EXPLORER_CAMERA_ROLL = $00
EXPLORER_LOOK_STEP = $01
EXPLORER_MOVE_STEP = $7F
EXPLORER_MOVE_SUBSTEPS_PER_TICK = $01
EXPLORER_YAW_PITCH_TICK_DIV = $04
EXPLORER_YAW_PITCH_REPEAT_PHASE = EXPLORER_YAW_PITCH_TICK_DIV - 1
EXPLORER_ROLL_TICK_DIV = $02
EXPLORER_ROLL_REPEAT_RELOAD = EXPLORER_ROLL_TICK_DIV - 1
EXPLORER_PITCH_NEG_MIN = $c0
EXPLORER_PITCH_POS_LIMIT = $41
EXPLORER_PITCH_POS_MAX = $40
EXPLORER_PROJ_X_NEG_MIN = $100 - PROJ_CENTER_X
EXPLORER_PROJ_X_POS_MAX = PROJ_CENTER_X
EXPLORER_PROJ_Y_NEG_MIN = $100 - PROJ_CENTER_Y + 1
EXPLORER_PROJ_Y_POS_MAX = PROJ_CENTER_Y + 1
TEXT_SPLIT_RASTER = $50
TEXT_HEADER_CELL_ROWS = 3
TEXT_HEADER_SCREEN_BYTES = TEXT_HEADER_CELL_ROWS * 40 ; 120 bytes ($78)
TEXT_BODY_FIRST_RASTER = $4B
TEXT_BITMAP_IRQ_RASTER = $4A
TEXT_CHARSET_UPDATE_RASTER = $80
TEXT_HEADER_OFFSET = $00
TEXT_CHARSET_GLYPH_COUNT = $0C
TEXT_CHARSET_BYTES = TEXT_CHARSET_GLYPH_COUNT * 8
FPS_FONT_BYTE_COUNT = TEXT_CHARSET_BYTES ; historical compatibility alias
FPS_TEXT_BASE = $CC00
FPS_TEXT_D018 = $32
FPS_TEXT_UNDER_IO = $00
FPS_TEXT_RELOCATED_D800 = $00
FPS_TEXT_CLEAR_CELLS = $78
FPS_COLORRAM_BULK_CLEAR = $00
FPS_COLORRAM_GLYPH_CELLS = $06
FPS_RUNTIME_BANK_SWITCH_IRQ_SAFE = $01
FPS_CHARSET_BASE = $C800
FPS_CHARSET_UNDER_IO = $00
FPS_CHARSET_RELOCATED_D000 = $00
ENGINE_MODE3_FPS_CHARSET_RELOCATED_D000 = $00
FPS_TEXT_BLANK = $00
FPS_TEXT_H = $0c

start:
 sei
 cld
 lda $dd02
 ora #$03
 sta $dd02
 lda #$35
 sta $01
 lda #WORLD_BACKGROUND_COLOR
 sta $d020
 sta $d021
 sta $d015
 lda #$ff
 sta $dc02
 lda #$00
 sta $dc03
 lda $dd00
 and #$fc
 ora #$02
 sta $dd00
 lda #$3b
 sta $d011
 lda #$18
 sta $d016
 lda #$78
 sta $d018
 jsr init_video_standard
 jsr init_buffers
.if MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = 0
 jsr reset_depth_full
.endif
 jsr init_fps_overlay
 jsr qc_demo_tick
 jsr lab_init_irq
 lda #INITIAL_ANGLE_X
 sta angx
 sta angx_hi
 lda #$00
 sta angx_lo
 lda #INITIAL_ANGLE_Y
 sta angy
 sta angy_hi
 lda #$00
 sta angy_lo
 lda #INITIAL_ANGLE_Z
 sta angz
 sta angz_hi
 lda #$00
 sta angz_lo
 lda #$01
 sta drawbuf
 lda #$00
 sta meshidx
 sta auto_cycle_counter
 sta light_phase
 sta light_tick
 sta material_latch
 sta reflect_latch
 sta light_pause
 sta light_latch
 sta light_pulse_enabled
 sta rotation_pause
 sta rotation_latch
 sta return_latch
.if CONTROL_LOWRES_KEY != 0
 sta lowres_latch
.endif
.if FPS_OVERLAY_ENABLE != 0
 sta fps_latch
.endif
.if CONTROL_LOWRES_KEY != 0
 sta lowres_scanline_enabled
.endif
.if CAMERA_MOVABLE != 0
 jsr explorer_init_camera
.endif
.if MOTION_Z_START_ON_RETURN != 0
 sta motion_z_enabled
.else
 lda #$01
 sta motion_z_enabled
 lda #$00
.endif
 lda #MOTION_Z_START_FRAC
 sta motion_z_frac
 lda #MOTION_Z_START_LO
 sta motion_z_lo
 lda #MOTION_Z_START_HI
 sta motion_z_hi
 lda #MATERIAL_REFLECTIVITY_OFFSET
 sta active_reflect_offset
 lda #MATERIAL_DEFAULT_INDEX
 sta active_material
 jsr apply_active_material
 jsr fps_update_digits
 lda #$01
 sta space_latch
.if SCENE_TIMELINE_ENABLE != 0
 jsr scene_timeline_reset
.endif
.if SCENE_GRAPHIC_INCLUDE_ENABLE != 0
 jsr scene_graphic_init
.endif
.if SCENE_OBJECT_COUNT = 0
 jsr set_active_mesh
.endif

main_loop:
.if FPS_OVERLAY_ENABLE != 0
 jsr poll_fps_key
.endif
.if CONTROL_SPACE_KEY != 0
 jsr poll_space
.endif
.if CONTROL_RETURN_KEY != 0 || CONTROL_LOWRES_KEY != 0 || CONTROL_LIGHT_KEY != 0 || CONTROL_ROTATION_KEY != 0 || CONTROL_ZERO_MOTION_KEY != 0
 jsr poll_control_keys
.endif
.if CONTROL_MATERIAL_KEYS != 0
 jsr poll_material_keys
.endif
.if CONTROL_REFLECTIVITY_KEYS != 0
 jsr poll_reflectivity_keys
.endif
 jsr wait_sim_tick
.if CAMERA_MOVABLE != 0 && CAMERA_RUNTIME_CONTROLS != 0
 jsr explorer_scan_keys
.if CAMERA_MODE_CYCLE != 0
 jsr explorer_poll_mode_cycle_f1
 lda explorer_runtime_mode
 beq ml_camera_events_done
.endif
.if EXPLORER_RESET_ON_SPACE != 0
 jsr explorer_poll_camera_reset
.endif
.if CAMERA_MODE_CYCLE != 0
ml_camera_events_done:
.endif
.endif
 jsr consume_video_ticks
.if CAMERA_MOVABLE != 0 && CAMERA_RUNTIME_CONTROLS != 0
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 beq ml_render_frame
.endif
 jsr explorer_prepare_view
.endif
ml_render_frame:
render_frame_begin:
.if SCENE_OBJECT_COUNT = 0
 jsr prepare_angles
.endif
.if DYNAMIC_LIGHT != 0
 jsr update_light_intensity
.if FULL_DYNAMIC_SHADE != 0
 jsr update_shade_dirty
.endif
.endif
.if MODE7_UV_CARRIER != 0 && SCENE_OBJECT_COUNT = 0
 jsr prepare_object_light_for_shade
 jsr m3_update_shades
.endif
.if CONTROL_LOWRES_KEY != 0
 jsr update_lowres_scanline_parity
.endif
.if ENGINE_MODE3_FRAME_PREFILL_RUNTIME_ACTIVE != 0
 jsr engine_mode3_frame_prefill
.else
.if CAMERA_MOVABLE != 0
.if ENGINE_WIRE_DIRTY_CLEAR_ENABLE != 0
 jsr clear_dirty
.else
 jsr clear_current_bitmap
.endif
.else
.if FULL_CLEAR != 0
 jsr clear_current_bitmap
.else
 jsr clear_dirty
.endif
.endif
.endif
.if ENGINE_WIRE_MATERIAL_CACHE_RESET_FRAME != 0
 jsr engine_wire_reset_material_cell_cache
.endif
.if VIC_COLOR_POLICY_ENABLE != 0
 jsr vic_color_policy_reset_frame
.endif
render_world_background:
.if SCENE_GRAPHIC_INCLUDE_ENABLE != 0
 jsr scene_graphic_render
.endif

render_scene_renderer:
.if CAMERA_MOVABLE != 0
 jsr render_explorer_scene_points
.else
.if SCENE_OBJECT_COUNT != 0
 jsr render_scene_objects
.else
 jsr rotate_project_vertices
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && MODE2_FACE_BUCKET_PIPELINE = 0
 jsr project_wire_vertices
 jsr draw_wire_active_mesh
.else
 jsr draw_mesh
.if WIRE_OVERLAY_ENABLE != 0
 jsr project_wire_vertices
 jsr draw_wire_active_mesh
.endif
.endif
.endif
.endif

.if VIC_COLOR_POLICY_OVERLAY != 0
 jsr vic_color_policy_overlay_conflicts
.endif
render_frame_end:
.if CONTROL_LOWRES_KEY != 0
 lda lowres_scanline_enabled
 bne ml_async_present
.endif
 jsr wait_raster
.if CONTROL_LOWRES_KEY != 0
ml_async_present:
.endif
 jsr show_buffer
 jsr fps_frame_done
 jmp main_loop

.if CONTROL_LOWRES_KEY != 0
update_lowres_scanline_parity:
 lda lowres_scanline_enabled
 bne ulsp_enabled
 lda #$00
 sta lowres_scanline_parity
 rts
ulsp_enabled:
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_parity_a
 sta lowres_scanline_parity
 clc
 adc #$01
 jsr wrap_lowres_parity
 sta lowres_parity_a
 sta lowres_parity_b
 rts
.else
 lda drawbuf
 bne ulsp_b
 lda lowres_parity_a
 sta lowres_scanline_parity
 clc
 adc #$01
 jsr wrap_lowres_parity
 sta lowres_parity_a
 rts
ulsp_b:
 lda lowres_parity_b
 sta lowres_scanline_parity
 clc
 adc #$01
 jsr wrap_lowres_parity
 sta lowres_parity_b
 rts
.endif

wrap_lowres_parity:
 ldx lowres_scanline_enabled
 cpx #$02
 bcs wlp_quarter
 and #$01
 rts
wlp_quarter:
 and #$03
 rts

lowres_row_selected:
 lda lowres_scanline_enabled
 cmp #$02
 bcs lrs_quarter
 txa
 and #$01
 cmp lowres_scanline_parity
 rts
lrs_quarter:
 txa
 and #$03
 cmp lowres_scanline_parity
 rts
.endif

wait_sim_tick:
 lda sim_vblank_count
 bne wst_done
wst_loop:
 lda sim_vblank_count
 beq wst_loop
wst_done:
 rts

consume_video_ticks:
 sei
 lda sim_vblank_count
 beq cvt_no_tick
 sec
 sbc #$01
 sta sim_vblank_count
 cli
.if VIDEO_STANDARD_FORCE_PAL != 0
 jsr advance_sim_tick
.else
 jsr schedule_video_tick
.endif
 jmp consume_video_ticks
cvt_no_tick:
 cli
cvt_done:
 rts

.if VIDEO_STANDARD_FORCE_PAL = 0
schedule_video_tick:
.if VIDEO_STANDARD_FORCE_NTSC = 0
 lda video_standard_runtime
 beq svt_advance
.endif
 inc ntsc_sim_phase
 lda ntsc_sim_phase
 cmp #$06
 bcc svt_advance
 lda #$00
 sta ntsc_sim_phase
 rts
svt_advance:
 jmp advance_sim_tick
.endif

advance_sim_tick:
 jsr qc_demo_tick
.if SCENE_GRAPHIC_INCLUDE_ENABLE != 0
 jsr scene_graphic_tick
.endif
.if SCENE_TIMELINE_ENABLE != 0
 jsr scene_timeline_tick
.endif
.if SCENE_OBJECT_COUNT != 0
.if SCENE_POS_ACTIVE != 0 || SCENE_ROT_ACTIVE != 0 || SCENE_RESPAWN_ACTIVE != 0 || SCENE_OSC_X_ACTIVE != 0
 jsr advance_scene_objects
.endif
.else
 jsr auto_cycle_mesh
 jsr advance_motion_z
.endif
.if DYNAMIC_LIGHT != 0 && STATIC_RUNTIME_LIGHT = 0
 lda light_pause
 bne ast_after_light
 jsr advance_light_phase
ast_after_light:
.endif
.if RANDOM_MATERIAL_CYCLE != 0
 jsr random_material_cycle_tick
.endif
.if STATIC_POSE = 0
.if SCENE_OBJECT_COUNT = 0
 lda rotation_pause
 bne ast_rotation_done
 clc
 lda angx_lo
 adc #ANGLE_X_STEP_LO
 sta angx_lo
 lda angx_hi
 adc #ANGLE_X_STEP_HI
 sta angx_hi
 sta angx
 clc
 lda angy_lo
 adc #ANGLE_Y_STEP_LO
 sta angy_lo
 lda angy_hi
 adc #ANGLE_Y_STEP_HI
 sta angy_hi
 sta angy
 clc
 lda angz_lo
 adc #ANGLE_Z_STEP_LO
 sta angz_lo
 lda angz_hi
 adc #ANGLE_Z_STEP_HI
 sta angz_hi
 sta angz
ast_rotation_done:
.endif
.endif
.if CAMERA_MOVABLE != 0 && CAMERA_RUNTIME_CONTROLS != 0
 jsr explorer_advance_camera_tick
.endif
.if CAMERA_SMOOTH_DEPTH_ACTIVE != 0
 jsr advance_camera_smooth_depth_ping_pong
.endif
 rts

advance_motion_z:
.if MOTION_Z_START_ON_RETURN != 0
 lda motion_z_enabled
 bne amz_enabled
 rts
amz_enabled:
.endif
 clc
 lda motion_z_frac
 adc #MOTION_Z_STEP_FRAC
 sta motion_z_frac
 lda motion_z_lo
 adc #MOTION_Z_STEP_LO
 sta motion_z_lo
 lda motion_z_hi
 adc #MOTION_Z_STEP_HI
 bcc amz_store_hi
 lda #$ff
 sta motion_z_frac
 sta motion_z_lo
amz_store_hi:
 sta motion_z_hi
 rts

.if SCENE_POS_ACTIVE != 0 || SCENE_ROT_ACTIVE != 0 || SCENE_RESPAWN_ACTIVE != 0 || SCENE_OSC_X_ACTIVE != 0
advance_scene_objects:
.if SCENE_OBJECT_COUNT != 0
 ldx #$00
aso_loop:
.if SCENE_POS_ACTIVE != 0
.if MOTION_Z_START_ON_RETURN != 0
 lda motion_z_enabled
 beq aso_skip_position
.endif
.if SCENE_VEL_X_ACTIVE != 0
 clc
 lda object_pos_x_lo,x
 adc object_vel_x_lo,x
 sta object_pos_x_lo,x
 lda object_pos_x_hi,x
 adc object_vel_x_hi,x
 sta object_pos_x_hi,x
.endif
.if SCENE_OSC_X_ACTIVE != 0
 jsr oscillate_scene_object_x_if_needed
.endif
.if SCENE_VEL_Y_ACTIVE != 0
 clc
 lda object_pos_y_lo,x
 adc object_vel_y_lo,x
 sta object_pos_y_lo,x
 lda object_pos_y_hi,x
 adc object_vel_y_hi,x
 sta object_pos_y_hi,x
.endif
.if SCENE_VEL_Z_ACTIVE != 0
 clc
 lda object_pos_z_lo,x
 adc object_vel_z_lo,x
 sta object_pos_z_lo,x
 lda object_pos_z_hi,x
 adc object_vel_z_hi,x
 sta object_pos_z_hi,x
 lda object_pos_z_ext,x
 adc object_vel_z_ext,x
 sta object_pos_z_ext,x
.endif
.if SCENE_RESPAWN_ACTIVE != 0
 jsr respawn_scene_object_if_needed
.endif
aso_skip_position:
.endif
.if STATIC_POSE = 0
.if SCENE_ROT_ACTIVE != 0
 lda rotation_pause
 bne aso_skip_rotation
.if SCENE_ANG_X_ACTIVE != 0
 clc
 lda object_ang_x_lo,x
 adc object_angvel_x_lo,x
 sta object_ang_x_lo,x
 lda object_ang_x_hi,x
 adc object_angvel_x_hi,x
 sta object_ang_x_hi,x
.endif
.if SCENE_ANG_Y_ACTIVE != 0
 clc
 lda object_ang_y_lo,x
 adc object_angvel_y_lo,x
 sta object_ang_y_lo,x
 lda object_ang_y_hi,x
 adc object_angvel_y_hi,x
 sta object_ang_y_hi,x
.endif
.if SCENE_ANG_Z_ACTIVE != 0
 clc
 lda object_ang_z_lo,x
 adc object_angvel_z_lo,x
 sta object_ang_z_lo,x
 lda object_ang_z_hi,x
 adc object_angvel_z_hi,x
 sta object_ang_z_hi,x
.endif
aso_skip_rotation:
.endif
.endif
 inx
 cpx #SCENE_OBJECT_COUNT
 bne aso_loop
.endif
 rts
.endif

.if SCENE_RESPAWN_ACTIVE != 0 || RANDOM_MATERIAL_CYCLE != 0
scene_rand:
 lda scene_rng_state
 asl
 bcc sr_no_xor
 eor #$1d
sr_no_xor:
 eor fps_cur_frames
 sta scene_rng_state
 rts
.endif

.if SCENE_RESPAWN_ACTIVE != 0
respawn_scene_object_if_needed:
 lda object_respawn_enabled,x
 beq rso_respawn_done
 lda object_pos_z_ext,x
 cmp #$ff
 bne rso_respawn_done
 lda object_pos_z_hi,x
 cmp object_respawn_near_z_hi,x
 bcs rso_respawn_done
 stx tmpidx
 jsr scene_rand
 ldx tmpidx
 and object_respawn_x_mask,x
 sec
 sbc object_respawn_x_bias,x
 sta object_pos_x_hi,x
 lda #$00
 sta object_pos_x_lo,x
 jsr scene_rand
 ldx tmpidx
 and object_respawn_y_mask,x
 sec
 sbc object_respawn_y_bias,x
 sta object_pos_y_hi,x
 lda #$00
 sta object_pos_y_lo,x
 jsr scene_rand
 ldx tmpidx
 and object_respawn_far_z_jitter_mask,x
 clc
 adc object_respawn_far_z_hi,x
 sta object_pos_z_hi,x
 lda object_respawn_far_z_ext,x
 adc #$00
 sta object_pos_z_ext,x
 lda object_respawn_far_z_lo,x
 sta object_pos_z_lo,x
 jsr scene_rand
 ldx tmpidx
 sta object_ang_x_hi,x
 lda #$00
 sta object_ang_x_lo,x
 jsr scene_rand
 ldx tmpidx
 sta object_ang_y_hi,x
 lda #$00
 sta object_ang_y_lo,x
 jsr scene_rand
 ldx tmpidx
 sta object_ang_z_hi,x
 lda #$00
 sta object_ang_z_lo,x
 ldx tmpidx
rso_respawn_done:
 rts
.endif

.if RANDOM_MATERIAL_CYCLE != 0
random_material_cycle_tick:
 inc random_material_tick
 lda random_material_tick
 cmp #RANDOM_MATERIAL_CYCLE_TICKS
 bcc rmct_done
 lda #$00
 sta random_material_tick
 jsr scene_rand
 and #$0f
 tax
 lda random_material_index_table,x
 sta t1
.if POLY_FILL_ENABLE != 0
.if FACE_MATERIAL_ACTIVE_ONLY != 0
 sta active_material
 jsr apply_active_material
.else
 ldx #$00
rmct_face_loop:
 cpx #FACE_COUNT
 beq rmct_faces_done
 lda t1
 sta face_material,x
 inx
 jmp rmct_face_loop
rmct_faces_done:
.endif
.endif
.if WIRE_OBJECT_MATERIAL_ENABLE != 0 && WIRE_MESH_COUNT != 0 && SCENE_OBJECT_COUNT != 0
 jsr scene_rand
 and #$0f
 tax
 lda random_wire_color_table,x
 sta t2
 ldx #$00
rmct_wire_loop:
 cpx #SCENE_OBJECT_COUNT
 beq rmct_done
 ldy object_mesh,x
 lda mesh_is_wire,y
 beq rmct_wire_next
 lda t2
 sta object_wire_screen,x
 sta object_wire_color,x
rmct_wire_next:
 inx
 jmp rmct_wire_loop
.endif
rmct_done:
 rts
.endif

.if SCENE_OSC_X_ACTIVE != 0
oscillate_scene_object_x_if_needed:
 lda object_osc_x_enabled,x
 beq oso_done
 lda object_vel_x_hi,x
 bmi oso_check_min
oso_check_max:
 lda object_osc_x_max_hi,x
 eor #$80
 sta mulb
 lda object_pos_x_hi,x
 eor #$80
 cmp mulb
 bcc oso_done
 bne oso_hit_max
 lda object_pos_x_lo,x
 cmp object_osc_x_max_lo,x
 bcc oso_done
oso_hit_max:
 lda object_osc_x_max_lo,x
 sta object_pos_x_lo,x
 lda object_osc_x_max_hi,x
 sta object_pos_x_hi,x
 jmp oso_reverse_vel
oso_check_min:
 lda object_osc_x_min_hi,x
 eor #$80
 sta mulb
 lda object_pos_x_hi,x
 eor #$80
 cmp mulb
 bcc oso_hit_min
 bne oso_done
 lda object_pos_x_lo,x
 cmp object_osc_x_min_lo,x
 beq oso_hit_min
 bcs oso_done
oso_hit_min:
 lda object_osc_x_min_lo,x
 sta object_pos_x_lo,x
 lda object_osc_x_min_hi,x
 sta object_pos_x_hi,x
oso_reverse_vel:
 sec
 lda #$00
 sbc object_vel_x_lo,x
 sta object_vel_x_lo,x
 lda #$00
 sbc object_vel_x_hi,x
 sta object_vel_x_hi,x
oso_done:
 rts
.endif

.if DYNAMIC_LIGHT != 0
.if STATIC_RUNTIME_LIGHT = 0
advance_light_phase:
 inc light_tick
 lda light_tick
 cmp #LIGHT_TICK_DIV
 bcc alp_done
 lda #$00
 sta light_tick
 inc light_phase
 lda light_phase
 and #LIGHT_PHASE_MASK
 sta light_phase
alp_done:
 rts
.endif

update_light_intensity:
.if DYNAMIC_LIGHT != 0
.if STATIC_RUNTIME_LIGHT != 0
 lda #LIGHT_INTENSITY_MAX
 sta light_intensity
.else
.if LIGHT_PULSE_ON_SPACE != 0
 lda light_pulse_enabled
 bne uli_use_phase_table
 lda #LIGHT_INTENSITY_MAX
 sta light_intensity
 rts
uli_use_phase_table:
.endif
 ldx light_phase
 lda light_intensity_table,x
 sta light_intensity
.endif
.endif
 rts
.endif

.if FULL_DYNAMIC_SHADE != 0
update_shade_dirty:
.if DYNAMIC_LIGHT != 0
.if FULL_DYNAMIC_SHADE != 0
.if SCENE_OBJECT_COUNT != 0
 lda #$00
 sta shade_intensity_changed
.if STATIC_RUNTIME_LIGHT = 0
 lda light_phase
 cmp shade_last_light_phase
 beq usd_scene_intensity
 sta shade_last_light_phase
usd_scene_intensity:
.endif
 lda light_intensity
 cmp shade_last_light_intensity
 beq usd_scene_reflect
 sta shade_last_light_intensity
 lda #$01
 sta shade_intensity_changed
usd_scene_reflect:
 lda active_reflect_offset
 cmp shade_last_reflect_offset
 beq usd_scene_done
 sta shade_last_reflect_offset
 lda #$01
 sta shade_intensity_changed
usd_scene_done:
 rts
.endif
 lda #$00
 sta shade_dirty
 sta shade_intensity_changed
 lda meshidx
 cmp shade_last_meshidx
 beq usd_light
 sta shade_last_meshidx
 lda #$01
 sta shade_dirty
usd_light:
 lda light_phase
 cmp shade_last_light_phase
 beq usd_intensity
 sta shade_last_light_phase
 lda #$01
 sta shade_dirty
usd_intensity:
 lda light_intensity
 cmp shade_last_light_intensity
 beq usd_reflect
 sta shade_last_light_intensity
 lda #$01
 sta shade_dirty
 sta shade_intensity_changed
usd_reflect:
 lda active_reflect_offset
 cmp shade_last_reflect_offset
 beq usd_angx_lo
 sta shade_last_reflect_offset
 lda #$01
 sta shade_dirty
 sta shade_intensity_changed
usd_angx_lo:
 lda angx_lo
 cmp shade_last_angx_lo
 beq usd_angx_hi
 sta shade_last_angx_lo
 lda #$01
 sta shade_dirty
usd_angx_hi:
 lda angx_hi
 cmp shade_last_angx_hi
 beq usd_angy_lo
 sta shade_last_angx_hi
 lda #$01
 sta shade_dirty
usd_angy_lo:
 lda angy_lo
 cmp shade_last_angy_lo
 beq usd_angy_hi
 sta shade_last_angy_lo
 lda #$01
 sta shade_dirty
usd_angy_hi:
 lda angy_hi
 cmp shade_last_angy_hi
 beq usd_angz_lo
 sta shade_last_angy_hi
 lda #$01
 sta shade_dirty
usd_angz_lo:
 lda angz_lo
 cmp shade_last_angz_lo
 beq usd_angz_hi
 sta shade_last_angz_lo
 lda #$01
 sta shade_dirty
usd_angz_hi:
 lda angz_hi
 cmp shade_last_angz_hi
 beq usd_done
 sta shade_last_angz_hi
 lda #$01
 sta shade_dirty
usd_done:
.endif
.endif
 rts
.endif

.if FPS_OVERLAY_ENABLE != 0
wait_text_charset_safe:
 ldx #TEXT_CHARSET_UPDATE_RASTER
 bne wait_raster_value
wait_raster:
 ldx #$f0
wait_raster_value:
wr1: cpx $d012
 bne wr1
wr2: cpx $d012
 beq wr2
 rts
.else
wait_raster:
wr1: lda $d012
 cmp #$f0
 bne wr1
wr2: lda $d012
 cmp #$f0
 beq wr2
 rts
.endif

init_irq:
 lda #$7f
 sta $dc0d
 sta $dd0d
 lda $dc0d
 lda $dd0d
 lda #<raster_irq
 sta $0314
 lda #>raster_irq
 sta $0315
 lda #$00
 sta irq_phase
.if FPS_OVERLAY_ENABLE != 0
 lda fps_overlay_visible
 beq init_irq_bitmap
 jsr set_text_header_mode
 jmp init_irq_mode_done
init_irq_bitmap:
 jsr set_bitmap_body_mode
init_irq_mode_done:
.else
 jsr set_bitmap_body_mode
.endif
 lda #$00
 sta $d012
 lda #$01
 sta $d019
 sta $d01a
 cli
 rts

raster_irq:
 lda #$01
 sta $d019
.if FPS_OVERLAY_ENABLE != 0
 lda fps_overlay_visible
 bne ri_overlay_enabled
 jsr set_bitmap_body_mode
 inc fps_vblank_count
 inc sim_vblank_count
 jsr demo_count_refresh
 lda fps_vblank_count
.if VIDEO_STANDARD_FORCE_PAL != 0
 cmp #VIDEO_PAL_VBLANKS_PER_SECOND
.else
.if VIDEO_STANDARD_FORCE_NTSC != 0
 cmp #VIDEO_NTSC_VBLANKS_PER_SECOND
.else
 cmp video_vblanks_per_second
.endif
.endif
 bcc ri_overlay_hidden_counter_done
 lda #$00
 sta fps_vblank_count
 lda #$01
 sta fps_second_flag
ri_overlay_hidden_counter_done:
 lda #$00
 sta irq_phase
 sta $d012
 jmp lab_irq_exit
ri_overlay_enabled:
 lda irq_phase
 bne ri_bitmap_phase_fast
ri_text_phase:
 jsr set_text_header_mode
 inc fps_vblank_count
 inc sim_vblank_count
 jsr demo_count_refresh
 lda fps_vblank_count
.if VIDEO_STANDARD_FORCE_PAL != 0
 cmp #VIDEO_PAL_VBLANKS_PER_SECOND
.else
.if VIDEO_STANDARD_FORCE_NTSC != 0
 cmp #VIDEO_NTSC_VBLANKS_PER_SECOND
.else
 cmp video_vblanks_per_second
.endif
.endif
 bcc ri_text_counter_done
 lda #$00
 sta fps_vblank_count
 lda #$01
 sta fps_second_flag
ri_text_counter_done:
 lda #TEXT_BITMAP_IRQ_RASTER
 sta $d012
 lda #$01
 sta irq_phase
 jmp lab_irq_exit

ri_bitmap_phase_fast:
 lda #$18
 sta $d016
 lda #$3b
 sta $d011
 lda #WORLD_BACKGROUND_COLOR
 sta $d020
 sta $d021
 lda #$00
 sta $d012
 sta irq_phase
 jmp lab_irq_exit
.else
 jsr set_bitmap_body_mode
 inc fps_vblank_count
 inc sim_vblank_count
 jsr demo_count_refresh
 lda fps_vblank_count
.if VIDEO_STANDARD_FORCE_PAL != 0
 cmp #VIDEO_PAL_VBLANKS_PER_SECOND
.else
.if VIDEO_STANDARD_FORCE_NTSC != 0
 cmp #VIDEO_NTSC_VBLANKS_PER_SECOND
.else
 cmp video_vblanks_per_second
.endif
.endif
 bcc ri_no_overlay_counter_done
 lda #$00
 sta fps_vblank_count
 lda #$01
 sta fps_second_flag
ri_no_overlay_counter_done:
 lda #$00
 sta $d012
 jmp lab_irq_exit
.endif

; M2: per-source-face point-light dot in the engine's object-space units.
; Q = clamp(floor(max(0, dot>>8) * intensity / 8), 0, 32).
; A quad's second triangle copies its representative, never its own normal.
m2_code_begin = *
m2_update_face_lighting_end = *

; E(texel,Q) = floor(Q/2) + 8*(texel-1), in [0,32].
; Contrasting local levels survive both extreme face lighting values.
; Prepare three quantizer bands and thresholds once per original face.
m2_prepare_face_end = *

; A=texel 1..3 -> A=opaque VIC-II pigment 1..3. No multiply/divide.
; Thresholds compare against Bayer 1..16 so carry adds the upper pigment.
; The original logical x/y anchor is shared by full and partial byte paths.
m2_composite_end = *
; A=signed-byte light position, Y:X=signed-word object position.
; Return clamp(light-object,-128,127). Do not wrap a distant front light
; behind the mesh. p1/prod scratch is dead before the existing matrix code.
m2_relative_s8:
 sta p1lo
 stx p1hi
 sty prodlo
 ldx #0
 cmp #128
 bcc m2_relative_light_positive
 dex
m2_relative_light_positive:
 stx prodhi
 sec
 lda p1lo
 sbc p1hi
 sta p1lo
 lda prodhi
 sbc prodlo
 bvc m2_relative_no_overflow
 lda prodhi
 bmi m2_relative_min
 bpl m2_relative_max
m2_relative_no_overflow:
 beq m2_relative_positive
 bmi m2_relative_check_negative
 bpl m2_relative_max
m2_relative_check_negative:
 cmp #255
 beq m2_relative_negative
 jmp m2_relative_min
m2_relative_max:
 lda #127
 rts
m2_relative_min:
 lda #128
 rts
m2_relative_positive:
 lda p1lo
 bmi m2_relative_max
 rts
m2_relative_negative:
 lda p1lo
 bpl m2_relative_min
 rts
m2_code_end = *

init_video_standard:
.if VIDEO_STANDARD_AUTO != 0
 jsr detect_video_standard
 rts
.else
.if VIDEO_STANDARD_FORCE_NTSC != 0
 lda #$01
 sta video_standard_runtime
 lda #VIDEO_NTSC_VBLANKS_PER_SECOND
 sta video_vblanks_per_second
 rts
.else
 lda #$00
 sta video_standard_runtime
 lda #VIDEO_PAL_VBLANKS_PER_SECOND
 sta video_vblanks_per_second
 rts
.endif
.endif

.if VIDEO_STANDARD_RUNTIME_DETECT != 0
detect_video_standard:
dvs_wait_low_raster:
 lda $d011
 bmi dvs_wait_low_raster
dvs_wait_high_raster:
 lda $d011
 bpl dvs_wait_high_raster
dvs_scan_high_raster:
 lda $d011
 bpl dvs_detected_ntsc
 lda $d012
 cmp #$20
 bcc dvs_scan_high_raster
dvs_detected_pal:
 lda #$00
 sta video_standard_runtime
 lda #VIDEO_PAL_VBLANKS_PER_SECOND
 sta video_vblanks_per_second
 rts
dvs_detected_ntsc:
 lda #$01
 sta video_standard_runtime
 lda #VIDEO_NTSC_VBLANKS_PER_SECOND
 sta video_vblanks_per_second
 rts
.endif

init_fps_overlay:
.if FPS_OVERLAY_ENABLE != 0
 jsr update_text_charset
 jsr init_fps_text
.endif
 lda #$00
 sta fps_vblank_count
 sta fps_second_flag
 sta ntsc_sim_phase
.if FPS_COUNTER_ENABLE != 0 || RANDOM_MATERIAL_CYCLE != 0
 sta fps_cur_frames
.endif
.if FPS_COUNTER_ENABLE != 0
 sta fps_sum
 sta fps_sample_index
 sta fps_initialized
 sta fps_last_value
 sta fps_last_tenths
 ldx #$04
ifo_samples:
 sta fps_samples,x
 dex
 bpl ifo_samples
.endif
 sta sim_vblank_count
.if FPS_OVERLAY_ENABLE != 0
 lda #FPS_OVERLAY_ON_START
 sta fps_overlay_visible
 lda #$00
 sta fps_latch
.endif
 lda #$00
 sta $d015
 jmp fps_update_digits

.if FPS_OVERLAY_ENABLE != 0
init_fps_charset = update_text_charset ; historical compatibility alias
update_text_charset:
 ldx #$00
utc_loop:
 lda text_split_visible
 beq utc_zero
 lda fps_font_bytes,x
 bne utc_store
utc_zero:
 lda #$00
utc_store:
 sta $6000,x
 sta BITMAP_B_BASE,x
 inx
 cpx #TEXT_CHARSET_BYTES
 bne utc_loop
 rts

init_fps_text:
 ldx #$00
 lda #$00
ift_clear_screen:
 sta $5c00,x
 sta SCREEN_B_BASE,x
 inx
 cpx #TEXT_HEADER_SCREEN_BYTES
 bne ift_clear_screen

 ldx #$00
ift_write_string:
 lda text_header_string,x
 cmp #$ff
 beq ift_write_done
 sta $5c28+TEXT_HEADER_OFFSET,x
 sta SCREEN_B_BASE+$0028+TEXT_HEADER_OFFSET,x
 lda #$01
 sta $d828+TEXT_HEADER_OFFSET,x
 inx
 cpx #40
 bne ift_write_string
ift_write_done:
 rts
.endif

.if FPS_OVERLAY_ENABLE != 0
set_text_header_mode:
 lda #$00
 sta $d020
 sta $d021
 jsr select_bitmap_buffer
 lda #$08
 sta $d016
 lda #$1b
 sta $d011
 rts

set_bitmap_body_mode:
 lda #WORLD_BACKGROUND_COLOR
 sta $d020
 sta $d021
 lda #$18
 sta $d016
 lda #$3b
 sta $d011
 jmp select_bitmap_buffer

select_bitmap_buffer:
 lda drawbuf
 beq sbb_show_b
sbb_show_a:
 lda $dd00
 and #$fc
 ora #$02
 sta $dd00
 lda #$78
 sta $d018
 rts
sbb_show_b:
 lda $dd00
 and #$fc
 ora #VIC_BANK_B_BITS
 sta $dd00
 lda #VIC_D018_B
 sta $d018
 rts
.else
set_text_header_mode:
 lda #$00
 sta $d020
 sta $d021
 lda $dd00
 and #$fc
 sta $dd00
 lda #$18
 sta $d011
 lda #$08
 sta $d016
 lda #FPS_TEXT_D018
 sta $d018
 rts

set_bitmap_body_mode:
 lda #WORLD_BACKGROUND_COLOR
 sta $d020
 sta $d021
 lda #$3b
 sta $d011
 lda #$18
 sta $d016
 lda drawbuf
 beq sbb_show_b
sbb_show_a:
 lda $dd00
 and #$fc
 ora #$02
 sta $dd00
 lda #$78
 sta $d018
 rts
sbb_show_b:
 lda $dd00
 and #$fc
 ora #VIC_BANK_B_BITS
 sta $dd00
 lda #VIC_D018_B
 sta $d018
 rts
.endif

fps_frame_done:
 jsr demo_count_frame
.if FPS_COUNTER_ENABLE = 0
 rts
.else
 lda fps_second_flag
 beq ffd_count_frame
 lda #$00
 sta fps_second_flag
 jsr fps_sample_second
ffd_count_frame:
 inc fps_cur_frames
 rts
.endif

fps_sample_second:
.if FPS_COUNTER_ENABLE = 0
 rts
.else
 lda fps_initialized
 bne fss_regular
 lda #$01
 sta fps_initialized
 lda fps_cur_frames
 sta p1lo
 lda #$00
 sta fps_sum
 sta fps_sample_index
 ldx #$00
fss_seed_loop:
 lda p1lo
 sta fps_samples,x
 clc
 adc fps_sum
 sta fps_sum
 inx
 cpx #$05
 bne fss_seed_loop
 lda #$00
 sta fps_cur_frames
 jmp fps_update_digits
fss_regular:
 ldx fps_sample_index
 lda fps_sum
 sec
 sbc fps_samples,x
 sta fps_sum
 lda fps_cur_frames
 sta fps_samples,x
 clc
 adc fps_sum
 sta fps_sum
 lda #$00
 sta fps_cur_frames
 inx
 cpx #$05
 bne fss_index_ok
 ldx #$00
fss_index_ok:
 stx fps_sample_index
 jmp fps_update_digits
.endif

fps_update_digits:
.if FPS_COUNTER_ENABLE = 0
 rts
.else
 lda fps_sum
 sta p1lo
 lda #$00
 sta p1hi
fud_div5_loop:
 lda p1lo
 cmp #$05
 bcc fud_div5_done
 sec
 sbc #$05
 sta p1lo
 inc p1hi
 jmp fud_div5_loop
fud_div5_done:
 lda p1hi
 sta fps_last_value
 lda p1lo
 asl
 sta fps_last_tenths
.if FPS_OVERLAY_ENABLE = 0
 rts
.else
 lda fps_overlay_visible
 beq fud_done
 lda fps_last_tenths
 clc
 adc #$01
 sta fps_digit_frac
 lda fps_last_value
 sta p1lo
 lda #$00
 sta p1hi
fud_div10_loop:
 lda p1lo
 cmp #$0a
 bcc fud_div10_done
 sec
 sbc #$0a
 sta p1lo
 inc p1hi
 jmp fud_div10_loop
fud_div10_done:
 lda p1hi
 clc
 adc #$01
 sta fps_digit_tens
 lda p1lo
 clc
 adc #$01
 sta fps_digit_ones
 lda fps_digit_tens
 sta $5c28
 sta SCREEN_B_BASE+$0028
 lda fps_digit_ones
 sta $5c29
 sta SCREEN_B_BASE+$0029
 lda #$0b
 sta $5c2a
 sta SCREEN_B_BASE+$002a
 lda fps_digit_frac
 sta $5c2b
 sta SCREEN_B_BASE+$002b
 lda #$01
 sta $d828
 sta $d829
 sta $d82a
 sta $d82b
 sta $d82c
 sta $d82d
fud_done:
 rts
.endif
.endif

set_active_mesh:
 ldx meshidx
 lda mesh_vfirst,x
 sta active_vfirst
 lda mesh_vend,x
 sta active_vend
.if WIRE_RENDER_ENABLE != 0 && WIRE_MESH_COUNT != 0
 lda mesh_is_wire,x
 beq sam_face_range
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0
 lda mesh_face_first,x
 cmp mesh_face_end,x
 bne sam_face_range
.endif
 lda mesh_edge_first,x
 sta active_face_first
 lda mesh_edge_end,x
 sta active_face_end
 rts
sam_face_range:
.endif
 lda mesh_face_first,x
 sta active_face_first
 lda mesh_face_end,x
 sta active_face_end
 rts

set_active_object:
.if SCENE_OBJECT_COUNT != 0
 ldx objidx
 lda object_mesh,x
 sta meshidx
.if SCENE_OBJECT_X_ACTIVE != 0
 lda object_pos_x_hi,x
.else
 lda #$00
.endif
 sta obj_pos_x_cur
.if SCENE_OBJECT_Y_ACTIVE != 0
 lda object_pos_y_hi,x
.else
 lda #$00
.endif
 sta obj_pos_y_cur
 lda object_pos_z_lo,x
 sta obj_depth_frac
 lda object_pos_z_hi,x
 sta obj_depth_lo
 lda object_pos_z_ext,x
 sta obj_depth_hi
.if SCENE_OBJECT_SCALE_ACTIVE != 0
 lda object_scale,x
.else
 lda #$40
.endif
 sta obj_scale_cur
.if EXPLORER_TRAVERSAL_CULL != 0
 jsr update_object_traverse_active
.endif
.if WIRE_RENDER_ENABLE != 0 && WIRE_OBJECT_MATERIAL_ENABLE != 0
 jsr restore_active_object_wire_material
.endif
 lda object_ang_x_hi,x
 sta angx
 sta angx_hi
 lda object_ang_x_lo,x
 sta angx_lo
 lda object_ang_y_hi,x
 sta angy
 sta angy_hi
 lda object_ang_y_lo,x
 sta angy_lo
 lda object_ang_z_hi,x
 sta angz
 sta angz_hi
 lda object_ang_z_lo,x
 sta angz_lo
 jsr set_active_mesh
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx objidx
 lda object_runtime_vfirst,x
 sta active_vfirst
 lda object_runtime_vend,x
 sta active_vend
 lda object_runtime_face_first,x
 sta shared_runtime_face
 lda object_source_vertex_delta,x
 sta shared_vertex_delta
 ldx meshidx
 lda mesh_vfirst,x
 sta shared_source_vertex
.endif
.endif
 rts

.if WIRE_RENDER_ENABLE != 0 && WIRE_OBJECT_MATERIAL_ENABLE != 0
restore_active_object_wire_material:
 ldx objidx
 lda object_wire_screen,x
 sta material_screen_cur
 lda object_wire_color,x
 sta material_color_cur
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 rts
.endif

.if MODE2_FACE_BUCKET_PIPELINE != 0 && WIRE_OBJECT_MATERIAL_ENABLE != 0
restore_face_owner_wire_color:
 ldy sortj
 lda face_object,y
 tax
 lda object_wire_screen,x
 sta material_screen_cur
 lda object_wire_color,x
 sta material_color_cur
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 rts
.endif

.if EXPLORER_TRAVERSAL_CULL != 0
update_object_traverse_active:
 ldx objidx
 lda object_traverse_radius,x
 ldx objidx
 ldy object_traverse_state,x
 beq uota_threshold_ready
 clc
 adc #EXPLORER_TRAVERSAL_HYSTERESIS
uota_threshold_ready:
 sta p1lo
 lda obj_pos_x_cur
 sec
 sbc explorer_cam_x_hi
 jsr abs_a8
 cmp p1lo
 bcs uota_no
 lda obj_pos_y_cur
 sec
 sbc explorer_cam_y_hi
 jsr abs_a8
 cmp p1lo
 bcs uota_no
 sec
 lda obj_depth_lo
 sbc explorer_cam_z_hi
 sta p1hi
 lda obj_depth_hi
 sbc explorer_cam_z_ext
 beq uota_z_positive
 cmp #$ff
 bne uota_no
 sec
 lda #$00
 sbc p1hi
 jmp uota_z_compare
uota_z_positive:
 lda p1hi
uota_z_compare:
 cmp p1lo
 bcs uota_no
 lda #$01
 sta object_traverse_active
 ldx objidx
 sta object_traverse_state,x
 rts
uota_no:
 lda #$00
 sta object_traverse_active
 ldx objidx
 sta object_traverse_state,x
 rts

abs_a8:
 bpl aa8_done
 eor #$ff
 clc
 adc #$01
aa8_done:
 rts
.endif

advance_active_mesh:
 inc meshidx
 lda meshidx
 cmp #MESH_COUNT
 bcc aam_mesh_ok
 lda #$00
 sta meshidx
aam_mesh_ok:
 lda #$00
 sta auto_cycle_counter
 jsr set_active_mesh
 jsr switch_frame_barrier
 rts

.if SCENE_TIMELINE_ENABLE != 0
scene_timeline_reset:
 lda #SCENE_TIMELINE_INITIAL_STATE
 sta scene_timeline_state
 jmp scene_timeline_apply_state

scene_timeline_poll_reset:
 lda #$7f
 sta $dc00
 lda $dc01
 and #$10
 bne stpr_released
 lda space_latch
 bne stpr_done
 lda #$01
 sta space_latch
 jsr scene_timeline_reset
 jmp stpr_done
stpr_released:
 lda #$00
 sta space_latch
stpr_done:
 lda #$ff
 sta $dc00
 rts

scene_timeline_tick:
 lda scene_timeline_ticks_lo
 bne stt_dec_lo
 lda scene_timeline_ticks_hi
 beq stt_next
 dec scene_timeline_ticks_hi
stt_dec_lo:
 dec scene_timeline_ticks_lo
 lda scene_timeline_ticks_lo
 ora scene_timeline_ticks_hi
 bne stt_done
stt_next:
 ldx scene_timeline_state
 lda scene_timeline_next,x
 sta scene_timeline_state
 jsr scene_timeline_apply_state
stt_done:
 rts

scene_timeline_apply_state:
 ldx scene_timeline_state
 lda scene_timeline_duration_lo,x
 sta scene_timeline_ticks_lo
 lda scene_timeline_duration_hi,x
 sta scene_timeline_ticks_hi
 lda scene_timeline_entry_base,x
 sta scene_timeline_entry
 lda #$00
 sta objidx
sta_object_loop:
 ldy scene_timeline_entry
 lda scene_timeline_mask0,y
 sta t1
 lda scene_timeline_mask1,y
 sta t2
 ldx objidx
 lda t1
 and #$01
 beq sta_no_visible
 lda scene_timeline_visible,y
 sta object_visible,x
sta_no_visible:
 lda t1
 and #$02
 beq sta_no_position
 lda scene_timeline_px_lo,y
 sta object_pos_x_lo,x
 lda scene_timeline_px_hi,y
 sta object_pos_x_hi,x
 lda scene_timeline_py_lo,y
 sta object_pos_y_lo,x
 lda scene_timeline_py_hi,y
 sta object_pos_y_hi,x
 lda scene_timeline_pz_lo,y
 sta object_pos_z_lo,x
 lda scene_timeline_pz_hi,y
 sta object_pos_z_hi,x
 lda scene_timeline_pz_ext,y
 sta object_pos_z_ext,x
sta_no_position:
 lda t1
 and #$04
 beq sta_no_rotation
 lda scene_timeline_rx_lo,y
 sta object_ang_x_lo,x
 lda scene_timeline_rx_hi,y
 sta object_ang_x_hi,x
 lda scene_timeline_ry_lo,y
 sta object_ang_y_lo,x
 lda scene_timeline_ry_hi,y
 sta object_ang_y_hi,x
 lda scene_timeline_rz_lo,y
 sta object_ang_z_lo,x
 lda scene_timeline_rz_hi,y
 sta object_ang_z_hi,x
sta_no_rotation:
 lda t1
 and #$08
 beq sta_no_scale
 lda scene_timeline_scale,y
 sta object_scale,x
sta_no_scale:
.if SCENE_INSTANCE_OVERRIDES != 0
 lda t1
 and #$10
 beq sta_no_material
 lda scene_timeline_material,y
 sta object_material_override,x
sta_no_material:
 lda t1
 and #$20
 beq sta_no_reflect
 lda scene_timeline_reflect,y
 sta object_reflectivity_override,x
sta_no_reflect:
 lda t1
 and #$40
 beq sta_no_color
 lda scene_timeline_color,y
 sta object_color_override,x
sta_no_color:
.endif
 lda t1
 and #$80
 beq sta_no_velocity
 lda scene_timeline_vx_lo,y
 sta object_vel_x_lo,x
 lda scene_timeline_vx_hi,y
 sta object_vel_x_hi,x
 lda scene_timeline_vy_lo,y
 sta object_vel_y_lo,x
 lda scene_timeline_vy_hi,y
 sta object_vel_y_hi,x
 lda scene_timeline_vz_lo,y
 sta object_vel_z_lo,x
 lda scene_timeline_vz_hi,y
 sta object_vel_z_hi,x
 lda scene_timeline_vz_ext,y
 sta object_vel_z_ext,x
sta_no_velocity:
 lda t2
 and #$01
 beq sta_no_ang_velocity
 lda scene_timeline_avx_lo,y
 sta object_angvel_x_lo,x
 lda scene_timeline_avx_hi,y
 sta object_angvel_x_hi,x
 lda scene_timeline_avy_lo,y
 sta object_angvel_y_lo,x
 lda scene_timeline_avy_hi,y
 sta object_angvel_y_hi,x
 lda scene_timeline_avz_lo,y
 sta object_angvel_z_lo,x
 lda scene_timeline_avz_hi,y
 sta object_angvel_z_hi,x
sta_no_ang_velocity:
 inc scene_timeline_entry
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bcc sta_object_loop
 rts
.endif

poll_space:
.if SCENE_TIMELINE_ENABLE != 0
 jsr scene_timeline_poll_reset
.else
.if LIGHT_PULSE_ON_SPACE != 0
 lda #$7f
 sta $dc00
 lda $dc01
 and #$10
 bne ps_released
 lda space_latch
 bne ps_done
 lda #$01
 sta space_latch
 lda light_pulse_enabled
 eor #$01
 sta light_pulse_enabled
 bne ps_pulse_started
 jmp ps_done
ps_pulse_started:
 lda #$00
 sta light_phase
 sta light_tick
 jmp ps_done
ps_released:
 lda #$00
 sta space_latch
ps_done:
 lda #$ff
 sta $dc00
.else
.if SCENE_OBJECT_COUNT = 0
.if MESH_COUNT != 1
 lda #$7f
 sta $dc00
 lda $dc01
 and #$10
 bne ps_released
 lda space_latch
 bne ps_done
 lda #$01
 sta space_latch
 jsr advance_active_mesh
 jmp ps_done
ps_released:
 lda #$00
 sta space_latch
ps_done:
 lda #$ff
 sta $dc00
.endif
.endif
.endif
.endif
 rts

.if FPS_OVERLAY_ENABLE != 0
poll_fps_key:
 jsr scan_fps_key
 cmp #$ff
 beq pfk_released
 lda fps_latch
 bne pfk_done
 lda #$01
 sta fps_latch
 jsr wait_text_charset_safe
 lda text_split_visible
 eor #$01
 sta text_split_visible
 jsr update_text_charset
 lda #$00
 sta irq_phase
 jsr fps_update_digits
 jmp pfk_done
pfk_released:
 lda #$00
 sta fps_latch
pfk_done:
 rts

scan_fps_key:
 lda #$fb
 sta $dc00
 lda $dc01
 and #$20
 beq sfk_pressed
 lda #$ff
 sta $dc00
 rts
sfk_pressed:
 lda #$ff
 sta $dc00
 lda #$00
 rts
.endif

poll_control_keys:
.if CONTROL_RETURN_KEY != 0
 jsr poll_return_motion_key
.endif
.if CONTROL_ZERO_MOTION_KEY != 0
 jsr poll_zero_motion_key
.endif
.if CONTROL_LOWRES_KEY != 0
 jsr scan_lowres_key
 cmp #$ff
 beq pcl_lowres_released
 lda lowres_latch
 bne pcl_after_lowres
 lda lowres_scanline_enabled
 clc
 adc #$01
 cmp #$03
 bcc pcl_lowres_store
 lda #$00
pcl_lowres_store:
 sta lowres_scanline_enabled
 lda #$01
 sta lowres_latch
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq pcl_lowres_full_barrier
 jsr lowres_trace_barrier
 jmp pcl_lowres_barrier_done
pcl_lowres_full_barrier:
 jsr switch_frame_barrier
pcl_lowres_barrier_done:
.else
 jsr switch_frame_barrier
.endif
 jsr fps_update_digits
 jmp pcl_after_lowres
pcl_lowres_released:
 lda #$00
 sta lowres_latch
pcl_after_lowres:
.endif
.if CONTROL_LIGHT_KEY != 0
 jsr scan_light_key
 cmp #$ff
 beq pcl_light_released
 lda light_latch
 bne pcl_after_light
 lda light_pause
 eor #$01
 sta light_pause
 lda #$01
 sta light_latch
 jmp pcl_after_light
pcl_light_released:
 lda #$00
 sta light_latch
pcl_after_light:
.endif
.if CONTROL_ROTATION_KEY != 0
 jsr scan_rotation_key
 cmp #$ff
 beq pcl_rotation_released
 lda rotation_latch
 bne pcl_done
 lda rotation_pause
 eor #$01
 sta rotation_pause
 lda #$01
 sta rotation_latch
 rts
pcl_rotation_released:
 lda #$00
 sta rotation_latch
.endif
pcl_done:
 rts

poll_return_motion_key:
.if MOTION_Z_START_ON_RETURN != 0 && CONTROL_RETURN_KEY != 0
 jsr scan_return_key
 cmp #$ff
 beq prmk_return_released
 lda return_latch
 bne prmk_done
 lda #$01
 sta return_latch
 sta motion_z_enabled
 rts
prmk_return_released:
 lda #$00
 sta return_latch
prmk_done:
.endif
 rts

poll_zero_motion_key:
.if MOTION_Z_START_ON_ZERO != 0 && CONTROL_ZERO_MOTION_KEY != 0
 jsr scan_zero_motion_key
 cmp #$ff
 beq pzmk_done
 lda #$01
 sta motion_z_enabled
pzmk_done:
.endif
 rts

scan_return_key:
.if CONTROL_RETURN_KEY != 0
 lda #$fe
 sta $dc00
 lda $dc01
 and #$02
 beq srtn_pressed
 lda #$ff
 sta $dc00
 rts
srtn_pressed:
 lda #$ff
 sta $dc00
 lda #$00
.endif
 rts

scan_zero_motion_key:
.if CONTROL_ZERO_MOTION_KEY != 0
 lda #$ef
 sta $dc00
 lda $dc01
 and #$08
 beq szmk_pressed
 lda #$ff
 sta $dc00
 rts
szmk_pressed:
 lda #$ff
 sta $dc00
 lda #$00
.endif
 rts

scan_light_key:
.if CONTROL_LIGHT_KEY != 0
 lda #$df
 sta $dc00
 lda $dc01
 and #$04
 beq slk_pressed
 lda #$ff
 sta $dc00
 rts
slk_pressed:
 lda #$ff
 sta $dc00
 lda #$00
.endif
 rts

scan_rotation_key:
.if CONTROL_ROTATION_KEY != 0
 lda #$fb
 sta $dc00
 lda $dc01
 and #$02
 beq srk_pressed
 lda #$ff
 sta $dc00
 rts
srk_pressed:
 lda #$ff
 sta $dc00
 lda #$00
.endif
 rts

.if CONTROL_LOWRES_KEY != 0
scan_lowres_key:
 lda #$f7
 sta $dc00
 lda $dc01
 and #$20
 beq slrk_pressed
 lda #$ff
 sta $dc00
 rts
slrk_pressed:
 lda #$ff
 sta $dc00
 lda #$00
 rts
.endif

poll_material_keys:
.if CONTROL_MATERIAL_KEYS != 0
 jsr scan_material_key
 cmp #$ff
 bne pm_key_down
 lda #$00
 sta material_latch
 rts
pm_key_down:
 ldx material_latch
 bne pm_done
 cmp active_material
 beq pm_latch_only
 sta active_material
 lda #$01
 sta material_latch
 jsr apply_active_material
 rts
pm_latch_only:
 lda #$01
 sta material_latch
pm_done:
.endif
 rts

poll_reflectivity_keys:
.if CONTROL_REFLECTIVITY_KEYS != 0
 jsr scan_reflectivity_key
 cmp #$ff
 bne prk_key_down
 lda #$00
 sta reflect_latch
 rts
prk_key_down:
 ldx reflect_latch
 bne prk_done
 lda #$01
 sta reflect_latch
 clc
 lda active_reflect_offset
 adc #$0a
 cmp #REFLECTIVITY_CYCLE_OFFSET_LIMIT
 bcc prk_store
 lda #$00
prk_store:
 sta active_reflect_offset
 jsr apply_active_material
 rts
prk_done:
.endif
 rts

scan_reflectivity_key:
.if CONTROL_REFLECTIVITY_KEYS != 0
 ; R key: matrix column 2, row 1. CONTROL_ROTATION_KEY is disabled in
 ; interactive-reflectivity builds so the key has a single owner.
 lda #$fb
 sta $dc00
 lda $dc01
 and #$02
 beq sref_pressed
 lda #$ff
 sta $dc00
 rts
sref_pressed:
 lda #$ff
 sta $dc00
 lda #$00
.endif
 rts

scan_material_key:
.if CONTROL_MATERIAL_KEYS != 0
 lda #$7f
 sta $dc00
 lda $dc01
 sta t1
 and #$01
 beq smk_key_1
 lda t1
 and #$08
 beq smk_key_2
 lda #$fd
 sta $dc00
 lda $dc01
 sta t1
 and #$01
 beq smk_key_3
 lda t1
 and #$08
 beq smk_key_4
 lda #$fb
 sta $dc00
 lda $dc01
 sta t1
 and #$01
 beq smk_key_5
 lda t1
 and #$08
 beq smk_key_6
 lda #$f7
 sta $dc00
 lda $dc01
 sta t1
 and #$01
 beq smk_key_7
 lda t1
 and #$08
 beq smk_key_8
 lda #$ef
 sta $dc00
 lda $dc01
 sta t1
 and #$01
 beq smk_key_9
 lda t1
 and #$08
 beq smk_key_0
 lda #$ff
 sta $dc00
 lda #$ff
 rts
smk_key_1:
 lda #$00
 jmp smk_found
smk_key_2:
 lda #$01
 jmp smk_found
smk_key_3:
 lda #$02
 jmp smk_found
smk_key_4:
 lda #$03
 jmp smk_found
smk_key_5:
 lda #$04
 jmp smk_found
smk_key_6:
 lda #$05
 jmp smk_found
smk_key_7:
 lda #$06
 jmp smk_found
smk_key_8:
 lda #$07
 jmp smk_found
smk_key_9:
 lda #$08
 jmp smk_found
smk_key_0:
.if CONTROL_ZERO_MOTION_KEY != 0
 lda #$ff
.else
 lda #$09
.endif
smk_found:
 pha
 lda #$ff
 sta $dc00
 pla
.endif
 rts

; DEV7 split-screen ownership contract:
; Header Screen RAM ($000-$077 / 120 bytes) belongs to the text layer.
; Body Screen RAM   ($078-$3E7 / 880 bytes) belongs to the material system.
apply_active_material:
 lda active_reflect_offset
 sta material_reflect_offset_cur
 clc
 adc active_material
 tay
 lda material_screen_bytes,y
 sta t1
 lda material_color_bytes,y
 sta t2
.if FPS_OVERLAY_ENABLE != 0
 ldx #TEXT_HEADER_SCREEN_BYTES
aam_screen_page0:
 lda t1
 sta $5c00,x
 sta SCREEN_B_BASE,x
 lda t2
 sta $d800,x
 inx
 bne aam_screen_page0

 ldx #$00
aam_screen_pages12:
 lda t1
 sta $5d00,x
 sta $5e00,x
 sta SCREEN_B_BASE+$0100,x
 sta SCREEN_B_BASE+$0200,x
 lda t2
 sta $d900,x
 sta $da00,x
 inx
 bne aam_screen_pages12

 ldx #$00
aam_screen_tail:
 lda t1
 sta $5f00,x
 sta SCREEN_B_BASE+$0300,x
 lda t2
 sta $db00,x
 inx
 cpx #$e8
 bne aam_screen_tail
 rts
.else
 ldx #$00
aam_screen:
 lda t1
 sta $5c00,x
 sta $5d00,x
 sta $5e00,x
 sta $5f00,x
 sta SCREEN_B_BASE,x
 sta SCREEN_B_BASE+$0100,x
 sta SCREEN_B_BASE+$0200,x
 sta SCREEN_B_BASE+$0300,x
 lda t2
 sta $d800,x
 sta $d900,x
 sta $da00,x
 sta $db00,x
 inx
 bne aam_screen
 rts
.endif

.if FACE_SOLID_COLOR_ENABLE != 0
load_face_solid_color_y:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy faceidx
.endif
 lda face_solid_color,y
 cmp #$ff
 beq lfsc_default
 sta material_color_cur
.if ENGINE_MODE3_ADAPTIVE_SCREEN_PAIR_LAYOUT != 0
 ; Adaptive mode3 layout: explicit face color occupies both Screen RAM
 ; object slots, so masked edge writes cannot expose a second pigment.
 ; Slot 11 remains the fixed ground color in global Color RAM.
 sta t1
 asl
 asl
 asl
 asl
 ora t1
 sta material_screen_cur
 lda #WORLD_GROUND_COLOR_RAM
 sta material_color_cur
 lda #$aa
 sta fillbyte
.else
.if ENGINE_MODE3_STABLE_GROUND_CELL_LAYOUT != 0
 ; Exact shared-ramp layout: slot 01 keeps the ground and slot 11 holds
 ; the shared object highlight in Color RAM.
 lda #WORLD_GROUND_SCREEN_BYTE
.else
 lda #$00
.endif
 sta material_screen_cur
 lda #$ff
 sta fillbyte
.endif
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 sec
 rts
lfsc_default:
 lda #MATERIAL_SCREEN_BYTE
 sta material_screen_cur
 lda #MATERIAL_COLOR_RAM
 sta material_color_cur
 lda #$aa
 sta fillbyte
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 clc
 rts
.endif

.if POLY_FILL_ENABLE != 0
load_face_reflectivity_y:
.if SCENE_INSTANCE_OVERRIDES != 0 && SCENE_INSTANCE_REFLECT_ALL_PINNED != 0
 ldx objidx
 lda object_reflectivity_override,x
.else
.if SCENE_INSTANCE_OVERRIDES != 0
 ldx objidx
 lda object_reflectivity_override,x
 cmp #$ff
 bne lfr_done
.endif
.if FACE_REFLECTIVITY_ACTIVE_ONLY != 0
 lda active_reflect_offset
.else
 lda face_reflect_offset,y
 cmp #$ff
 bne lfr_done
 lda active_reflect_offset
.endif
lfr_done:
.endif
 sta material_reflect_offset_cur
 rts

load_face_material:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy faceidx
.else
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
.endif
 jsr load_face_reflectivity_y
.if SCENE_INSTANCE_OVERRIDES != 0 && SCENE_INSTANCE_MATERIAL_ALL_PINNED != 0 && SCENE_FACE_MATERIAL_OVERRIDE = 0
 ldx objidx
 lda object_material_override,x
.else
.if SCENE_INSTANCE_OVERRIDES != 0
.if SCENE_FACE_MATERIAL_OVERRIDE != 0
 lda face_material_explicit,y
 cmp #$ff
 bne lfm_fixed
 ldx objidx
 lda object_material_override,x
 cmp #$ff
 bne lfm_fixed
.else
 ldx objidx
 lda object_material_override,x
 cmp #$ff
 bne lfm_fixed
.endif
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != 0
 lda active_material
.else
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy faceidx
.else
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
.endif
 lda face_material,y
 cmp #$ff
 bne lfm_fixed
 lda active_material
.endif
lfm_fixed:
.endif
 clc
 adc material_reflect_offset_cur
 tay
 lda material_screen_bytes,y
 sta material_screen_cur
 lda material_color_bytes,y
 sta material_color_cur
.if SCENE_INSTANCE_COLOR_OVERRIDE != 0
 ldx objidx
 lda object_color_override,x
 cmp #$ff
 beq lfm_color_done
 sta material_color_cur
lfm_color_done:
.endif
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 rts
.endif

apply_material_span_a:
 ldx yrow
 lda screenrowlo_a,x
 clc
 adc startbyte
 sta ptr0lo
 lda screenrowhi_a,x
 adc #$00
 sta ptr0hi
 lda colorrowlo,x
 clc
 adc startbyte
 sta ptr1lo
 lda colorrowhi,x
 adc #$00
 sta ptr1hi
 jmp apply_material_span_common

apply_material_span_b:
 ldx yrow
 lda screenrowlo_b,x
 clc
 adc startbyte
 sta ptr0lo
 lda screenrowhi_b,x
 adc #$00
 sta ptr0hi
 lda colorrowlo,x
 clc
 adc startbyte
 sta ptr1lo
 lda colorrowhi,x
 adc #$00
 sta ptr1hi

apply_material_span_common:
 ldx startbyte
 ldy #$00
ams_loop:
.if VIC_COLOR_POLICY_ENABLE != 0
 jsr vic_color_policy_claim_cell
 bcc ams_skip_write
.endif
 lda material_screen_cur
 sta (ptr0lo),y
 lda material_color_cur
 sta (ptr1lo),y
ams_skip_write:
 cpx endbyte
 beq ams_done
 inc ptr0lo
 bne ams_screen_ok
 inc ptr0hi
ams_screen_ok:
 inc ptr1lo
 bne ams_color_ok
 inc ptr1hi
ams_color_ok:
 inx
 jmp ams_loop
ams_done:
 rts


.if MATERIAL_CELL_SPAN_CACHE != 0
maybe_apply_material_span_a:
.if ENGINE_MODE3_MATERIAL_CELL_TRANSITION != 0
 lda yrow
 and #$fc
.else
 lda yrow
 lsr
 lsr
.endif
 cmp material_last_cellrow
 beq mas_a_same_cell
 sta material_last_cellrow
 lda startbyte
 sta material_cell_min
 lda endbyte
 sta material_cell_max
 jmp apply_material_span_a
mas_a_same_cell:
 lda startbyte
 cmp material_cell_min
 bcc mas_a_left_needed
 lda material_cell_max
 cmp endbyte
 bcc mas_a_right_only
mas_a_skip:
 rts
mas_a_left_needed:
 lda startbyte
 sta material_span_orig_start
 lda endbyte
 sta material_span_orig_end
 lda material_span_orig_start
 sta startbyte
 lda material_cell_min
 sec
 sbc #$01
 sta endbyte
 lda material_span_orig_start
 sta material_cell_min
 jsr apply_material_span_a
mas_a_left_done:
 lda material_cell_max
 cmp material_span_orig_end
 bcc mas_a_right_needed
 jmp material_span_restore_original
mas_a_right_only:
 lda startbyte
 sta material_span_orig_start
 lda endbyte
 sta material_span_orig_end
mas_a_right_needed:
 lda material_cell_max
 clc
 adc #$01
 sta startbyte
 lda material_span_orig_end
 sta endbyte
 sta material_cell_max
 jsr apply_material_span_a
 jmp material_span_restore_original

maybe_apply_material_span_b:
.if ENGINE_MODE3_MATERIAL_CELL_TRANSITION != 0
 lda yrow
 and #$fc
.else
 lda yrow
 lsr
 lsr
.endif
 cmp material_last_cellrow
 beq mas_b_same_cell
 sta material_last_cellrow
 lda startbyte
 sta material_cell_min
 lda endbyte
 sta material_cell_max
 jmp apply_material_span_b
mas_b_same_cell:
 lda startbyte
 cmp material_cell_min
 bcc mas_b_left_needed
 lda material_cell_max
 cmp endbyte
 bcc mas_b_right_only
mas_b_skip:
 rts
mas_b_left_needed:
 lda startbyte
 sta material_span_orig_start
 lda endbyte
 sta material_span_orig_end
 lda material_span_orig_start
 sta startbyte
 lda material_cell_min
 sec
 sbc #$01
 sta endbyte
 lda material_span_orig_start
 sta material_cell_min
 jsr apply_material_span_b
mas_b_left_done:
 lda material_cell_max
 cmp material_span_orig_end
 bcc mas_b_right_needed
 jmp material_span_restore_original
mas_b_right_only:
 lda startbyte
 sta material_span_orig_start
 lda endbyte
 sta material_span_orig_end
mas_b_right_needed:
 lda material_cell_max
 clc
 adc #$01
 sta startbyte
 lda material_span_orig_end
 sta endbyte
 sta material_cell_max
 jsr apply_material_span_b
material_span_restore_original:
 lda material_span_orig_start
 sta startbyte
 lda material_span_orig_end
 sta endbyte
 rts
.endif

auto_cycle_mesh:
.if AUTO_CYCLE_FRAMES != 0
.if MESH_COUNT != 1
 inc auto_cycle_counter
 lda auto_cycle_counter
 cmp #AUTO_CYCLE_FRAMES
 bcc acm_done
 jsr advance_active_mesh
acm_done:
.endif
.endif
 rts

switch_frame_barrier:
 jsr clear_bitmap_buffers
 jsr reset_dirty_clean
.if MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = 0
 jsr reset_depth_full
.endif
.if STANDARD_PROJECT_VERTEX != 0
 jsr reset_smooth_history
.endif
.if CONTROL_LOWRES_KEY != 0
 lda #$00
 sta lowres_scanline_parity
 sta lowres_parity_a
 sta lowres_parity_b
.endif
 rts

.if LOWRES_TRACE_ENABLE != 0
lowres_trace_barrier:
 lda #$00
 sta lowres_scanline_parity
 sta lowres_parity_a
 sta lowres_parity_b
 rts
.endif

.if STANDARD_PROJECT_VERTEX != 0
reset_smooth_history:
 ldx #$00
 lda #$00
rsh_loop:
 sta smooth_ready,x
 inx
 cpx #VERT_COUNT
 bne rsh_loop
 rts
.endif

reset_dirty_clean:
 ldx #$00
 lda #$ff
rdc_min_loop:
 sta dirtymin_a,x
 sta dirtymin_b,x
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne rdc_min_loop
 ldx #$00
 lda #$00
rdc_max_loop:
 sta dirtymax_a,x
 sta dirtymax_b,x
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne rdc_max_loop
 lda #$ff
 sta dirty_ymin_a
 sta dirty_ymin_b
 lda #$00
 sta dirty_ymax_a
 sta dirty_ymax_b
 rts

.if MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = 0
reset_depth_full:
.if FACE_RENDER_ENABLE != 0
 ldx #$00
 lda #$ff
rdf_bucket_loop:
 sta bucket_head,x
.if WIRE_DEPTH_SORT_ENABLE != 0
 sta wire_bucket_head,x
.endif
 inx
 bne rdf_bucket_loop
 lda #$00
 sta bucket_used_count
.if WIRE_DEPTH_SORT_ENABLE != 0
 sta wire_depth_entry_used
.endif
.if FACE_COUNT != 0
 lda #$ff
 ldx #FACE_COUNT
rdf_face_loop:
 dex
 sta face_next,x
 cpx #$00
 bne rdf_face_loop
.if STATIC_SHADE_DIRECT = 0
.if STATIC_SHADE_CACHE != 0
 ldx #FACE_COUNT
rdf_shade_loop:
 dex
 lda face_shade,x
 sta frame_face_shade,x
 cpx #$00
 bne rdf_shade_loop
.if FRAME_FACE_FILL_CACHE != 0
 ldx #FACE_COUNT
rdf_fill_loop:
 dex
 lda face_shade,x
 and #$7f
 tay
 lda shade_solid_bytes,y
 sta frame_face_fill,x
 cpx #$00
 bne rdf_fill_loop
.endif
.else
 lda #$00
 ldx #FACE_COUNT
rdf_shade_loop:
 dex
 sta frame_face_shade,x
 cpx #$00
 bne rdf_shade_loop
.if MODE4_SHADE_STEP_LIMIT != 0
 lda #$ff
 ldx #FACE_COUNT
rdf_shade_step_rank_loop:
 dex
 sta mode4_shade_step_rank,x
 cpx #$00
 bne rdf_shade_step_rank_loop
.endif
.endif
.endif
.endif
.endif
 rts
.endif

show_buffer:
 lda drawbuf
 eor #$01
 sta drawbuf
 rts

init_buffers:
.if LAZY_CONVEX_BOUNDS != 0
 lda #$00
 sta bounds_stamp_cur
 jsr clear_bounds_stamp
.endif
 ldx #$00
 lda #MATERIAL_SCREEN_BYTE
ib_screen:
 sta $5c00,x
 sta $5d00,x
 sta $5e00,x
 sta $5f00,x
 sta SCREEN_B_BASE,x
 sta SCREEN_B_BASE+$0100,x
 sta SCREEN_B_BASE+$0200,x
 sta SCREEN_B_BASE+$0300,x
 inx
 bne ib_screen
 ldx #$00
 lda #MATERIAL_COLOR_RAM
ib_color:
 sta $d800,x
 sta $d900,x
 sta $da00,x
 sta $db00,x
 inx
 bne ib_color
 ldx #$00
 lda #$ff
ib_dirty_min:
 sta dirtymin_a,x
 sta dirtymin_b,x
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ib_dirty_min
 ldx #$00
 lda #$00
ib_dirty_max:
 sta dirtymax_a,x
 sta dirtymax_b,x
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ib_dirty_max
 lda #$ff
 sta dirty_ymin_a
 sta dirty_ymin_b
 lda #$00
 sta dirty_ymax_a
 sta dirty_ymax_b
.if WIRE_FACE_EDGE_ENABLE != 0
 sta wire_edge_stamp
 jsr clear_all_wire_edge_marks
.endif
 jsr clear_bitmap_buffers
 rts

.if LAZY_CONVEX_BOUNDS != 0
clear_bounds_stamp:
 lda #$00
 ldx #$00
cbs_loop:
 sta bounds_stamp,x
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne cbs_loop
 rts
.endif

clear_bitmap_buffers:
 lda #$00
 ldx #$00
ib_clear_all:
 sta $6000,x
 sta $6100,x
 sta $6200,x
 sta $6300,x
 sta $6400,x
 sta $6500,x
 sta $6600,x
 sta $6700,x
 sta $6800,x
 sta $6900,x
 sta $6a00,x
 sta $6b00,x
 sta $6c00,x
 sta $6d00,x
 sta $6e00,x
 sta $6f00,x
 sta $7000,x
 sta $7100,x
 sta $7200,x
 sta $7300,x
 sta $7400,x
 sta $7500,x
 sta $7600,x
 sta $7700,x
 sta $7800,x
 sta $7900,x
 sta $7a00,x
 sta $7b00,x
 sta $7c00,x
 sta $7d00,x
 sta $7e00,x
 sta $7f00,x
 sta BITMAP_B_BASE,x
 sta BITMAP_B_BASE+$0100,x
 sta BITMAP_B_BASE+$0200,x
 sta BITMAP_B_BASE+$0300,x
 sta BITMAP_B_BASE+$0400,x
 sta BITMAP_B_BASE+$0500,x
 sta BITMAP_B_BASE+$0600,x
 sta BITMAP_B_BASE+$0700,x
 sta BITMAP_B_BASE+$0800,x
 sta BITMAP_B_BASE+$0900,x
 sta BITMAP_B_BASE+$0a00,x
 sta BITMAP_B_BASE+$0b00,x
 sta BITMAP_B_BASE+$0c00,x
 sta BITMAP_B_BASE+$0d00,x
 sta BITMAP_B_BASE+$0e00,x
 sta BITMAP_B_BASE+$0f00,x
 sta BITMAP_B_BASE+$1000,x
 sta BITMAP_B_BASE+$1100,x
 sta BITMAP_B_BASE+$1200,x
 sta BITMAP_B_BASE+$1300,x
 sta BITMAP_B_BASE+$1400,x
 sta BITMAP_B_BASE+$1500,x
 sta BITMAP_B_BASE+$1600,x
 sta BITMAP_B_BASE+$1700,x
 sta BITMAP_B_BASE+$1800,x
 sta BITMAP_B_BASE+$1900,x
 sta BITMAP_B_BASE+$1a00,x
 sta BITMAP_B_BASE+$1b00,x
 sta BITMAP_B_BASE+$1c00,x
 sta BITMAP_B_BASE+$1d00,x
 sta BITMAP_B_BASE+$1e00,x
 sta BITMAP_B_BASE+$1f00,x
 inx
 bne ib_clear_all
 rts

.if FULL_CLEAR != 0 || CAMERA_MOVABLE != 0
clear_current_bitmap:
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq ccb_full_clear
 jmp clear_current_bitmap_lowres_trace
ccb_full_clear:
.endif
.if ENGINE_CAMERA_VIEWPORT_CLEAR_LIMITED != 0
.if MODE6_VIEWPORT_CLEAR_SPECIALIZED != 0
 lda drawbuf
 bne ccb_viewport_specialized_b
 jmp clear_camera_viewport_specialized_a
ccb_viewport_specialized_b:
 jmp clear_camera_viewport_specialized_b
.else
 lda drawbuf
 bne ccb_viewport_b
ccb_viewport_a:
 ldx #$00
ccb_viewport_a_row:
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 jsr clear_camera_viewport_bitmap_row
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ccb_viewport_a_row
 rts
ccb_viewport_b:
 ldx #$00
ccb_viewport_b_row:
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
 jsr clear_camera_viewport_bitmap_row
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ccb_viewport_b_row
 rts
.endif
.endif
 lda drawbuf
 bne ccb_b
ccb_a:
 lda #$00
 ldx #$00
ccb_a_loop:
 sta $6000,x
 sta $6100,x
 sta $6200,x
 sta $6300,x
 sta $6400,x
 sta $6500,x
 sta $6600,x
 sta $6700,x
 sta $6800,x
 sta $6900,x
 sta $6a00,x
 sta $6b00,x
 sta $6c00,x
 sta $6d00,x
 sta $6e00,x
 sta $6f00,x
 sta $7000,x
 sta $7100,x
 sta $7200,x
 sta $7300,x
 sta $7400,x
 sta $7500,x
 sta $7600,x
 sta $7700,x
 sta $7800,x
 sta $7900,x
 sta $7a00,x
 sta $7b00,x
 sta $7c00,x
 sta $7d00,x
 sta $7e00,x
 sta $7f00,x
 inx
 bne ccb_a_loop
 rts
ccb_b:
 lda #$00
 ldx #$00
ccb_b_loop:
 sta BITMAP_B_BASE,x
 sta BITMAP_B_BASE+$0100,x
 sta BITMAP_B_BASE+$0200,x
 sta BITMAP_B_BASE+$0300,x
 sta BITMAP_B_BASE+$0400,x
 sta BITMAP_B_BASE+$0500,x
 sta BITMAP_B_BASE+$0600,x
 sta BITMAP_B_BASE+$0700,x
 sta BITMAP_B_BASE+$0800,x
 sta BITMAP_B_BASE+$0900,x
 sta BITMAP_B_BASE+$0a00,x
 sta BITMAP_B_BASE+$0b00,x
 sta BITMAP_B_BASE+$0c00,x
 sta BITMAP_B_BASE+$0d00,x
 sta BITMAP_B_BASE+$0e00,x
 sta BITMAP_B_BASE+$0f00,x
 sta BITMAP_B_BASE+$1000,x
 sta BITMAP_B_BASE+$1100,x
 sta BITMAP_B_BASE+$1200,x
 sta BITMAP_B_BASE+$1300,x
 sta BITMAP_B_BASE+$1400,x
 sta BITMAP_B_BASE+$1500,x
 sta BITMAP_B_BASE+$1600,x
 sta BITMAP_B_BASE+$1700,x
 sta BITMAP_B_BASE+$1800,x
 sta BITMAP_B_BASE+$1900,x
 sta BITMAP_B_BASE+$1a00,x
 sta BITMAP_B_BASE+$1b00,x
 sta BITMAP_B_BASE+$1c00,x
 sta BITMAP_B_BASE+$1d00,x
 sta BITMAP_B_BASE+$1e00,x
 sta BITMAP_B_BASE+$1f00,x
 inx
 bne ccb_b_loop
 rts

.if ENGINE_CAMERA_VIEWPORT_CLEAR_LIMITED != 0
clear_camera_viewport_bitmap_row:
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr0lo
 bcc ccvbr_ptr0_origin_ok
 inc ptr0hi
ccvbr_ptr0_origin_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr1lo
 bcc ccvbr_ptr1_origin_ok
 inc ptr1hi
ccvbr_ptr1_origin_ok:
 lda #CAMERA_VIEWPORT_CELL_WIDTH
 sta p1lo
ccvbr_loop:
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc ccvbr_ptr0_ok
 inc ptr0hi
ccvbr_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc ccvbr_ptr1_ok
 inc ptr1hi
ccvbr_ptr1_ok:
 dec p1lo
 bne ccvbr_loop
 rts
.endif



.endif

.if TRACK_DIRTY_SPANS != 0
clear_dirty:
 lda drawbuf
 bne clear_dirty_b
clear_dirty_a:
 lda dirty_ymin_a
 cmp #$ff
 bne cd_a_go
 rts
cd_a_go:
 sta yrow
 lda dirty_ymax_a
 sta maxrow
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 bne cd_a_row
.endif
cd_a_reset_dirty:
 lda #$ff
 sta dirty_ymin_a
 lda #$00
 sta dirty_ymax_a
cd_a_row:
 ldx yrow
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq cd_a_parity_ok
 jsr lowres_row_selected
 bne cd_a_next
.endif
cd_a_parity_ok:
 lda dirtymin_a,x
 cmp #$ff
 beq cd_a_next
 sta startbyte
 lda dirtymax_a,x
 sta endbyte
 lda #$ff
 sta dirtymin_a,x
 lda #$00
 sta dirtymax_a,x
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 stx yrow
 ldx startbyte
 lda row0lo
 clc
 adc byteofflo,x
 sta ptr0lo
 lda row0hi
 adc byteoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc byteofflo,x
 sta ptr1lo
 lda row1hi
 adc byteoffhi,x
 sta ptr1hi
 lda endbyte
 sec
 sbc startbyte
 clc
 adc #$01
 sta fullcount
 cmp #$05
 bcs cd_a_long
 tax
 lda #$00
 cpx #$01
 beq cd_a_clear1
 cpx #$02
 beq cd_a_clear2
 cpx #$03
 beq cd_a_clear3
cd_a_clear4:
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_a_clear3:
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_a_clear2:
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_a_clear1:
 ldy #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp cd_a_next
cd_a_long:
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq cd_a_odd_check
cd_a_pair_loop:
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc cd_a_p0_ok
 inc ptr0hi
cd_a_p0_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc cd_a_p1_ok
 inc ptr1hi
cd_a_p1_ok:
 dec p1lo
 bne cd_a_pair_loop
cd_a_odd_check:
 lda p1hi
 beq cd_a_next
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_a_next:
 lda yrow
 cmp maxrow
 beq cd_done
 inc yrow
 jmp cd_a_row

clear_dirty_b:
 lda dirty_ymin_b
 cmp #$ff
 bne cd_b_go
 rts
cd_b_go:
 sta yrow
 lda dirty_ymax_b
 sta maxrow
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 bne cd_b_row
.endif
cd_b_reset_dirty:
 lda #$ff
 sta dirty_ymin_b
 lda #$00
 sta dirty_ymax_b
cd_b_row:
 ldx yrow
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq cd_b_parity_ok
 jsr lowres_row_selected
 bne cd_b_next
.endif
cd_b_parity_ok:
 lda dirtymin_b,x
 cmp #$ff
 beq cd_b_next
 sta startbyte
 lda dirtymax_b,x
 sta endbyte
 lda #$ff
 sta dirtymin_b,x
 lda #$00
 sta dirtymax_b,x
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
 stx yrow
 ldx startbyte
 lda row0lo
 clc
 adc byteofflo,x
 sta ptr0lo
 lda row0hi
 adc byteoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc byteofflo,x
 sta ptr1lo
 lda row1hi
 adc byteoffhi,x
 sta ptr1hi
 lda endbyte
 sec
 sbc startbyte
 clc
 adc #$01
 sta fullcount
 cmp #$05
 bcs cd_b_long
 tax
 lda #$00
 cpx #$01
 beq cd_b_clear1
 cpx #$02
 beq cd_b_clear2
 cpx #$03
 beq cd_b_clear3
cd_b_clear4:
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_b_clear3:
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_b_clear2:
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_b_clear1:
 ldy #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp cd_b_next
cd_b_long:
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq cd_b_odd_check
cd_b_pair_loop:
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc cd_b_p0_ok
 inc ptr0hi
cd_b_p0_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc cd_b_p1_ok
 inc ptr1hi
cd_b_p1_ok:
 dec p1lo
 bne cd_b_pair_loop
cd_b_odd_check:
 lda p1hi
 beq cd_b_next
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_b_next:
 lda yrow
 cmp maxrow
 beq cd_done
 inc yrow
 jmp cd_b_row
cd_done:
 rts
.endif

prepare_angles:
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_object_matrix
 jsr build_coord_terms
 jmp prepare_angles_after_terms

prepare_object_matrix:
.endif
 ldx angx
 lda angx_lo
 jsr interp_sintab
 sta sinxv
 lda angx
 clc
 adc #$40
 tax
 lda angx_lo
 jsr interp_sintab
 sta cosxv
 ldx angy
 lda angy_lo
 jsr interp_sintab
 sta sinyv
 lda angy
 clc
 adc #$40
 tax
 lda angy_lo
 jsr interp_sintab
 sta cosyv
 ldx angz
 lda angz_lo
 jsr interp_sintab
 sta sinzv
 lda angz
 clc
 adc #$40
 tax
 lda angz_lo
 jsr interp_sintab
 sta coszv
 jsr prepare_matrix
.if SCENE_OBJECT_COUNT != 0
.if SCENE_OBJECT_SCALE_ACTIVE != 0
 jsr apply_object_scale_to_matrix
.endif
.endif
.if EXPLORER_MATRIX_FOLD != 0
 rts
.endif
 jsr build_coord_terms
prepare_angles_after_terms:
.if DYNAMIC_LIGHT != 0
.if SCENE_OBJECT_COUNT != 0
.if SCENE_OBJECT_SCALE_ACTIVE != 0
 lda obj_scale_cur
 cmp #$40
 beq prepare_angles_done
 jsr prepare_matrix
prepare_angles_done:
.endif
.endif
.endif
 rts

.if MODE4_OBJECT_LIGHT_CACHE != 0
prepare_object_light_for_shade:
 ldx light_phase
 lda light_pos_x,x
.if SCENE_OBJECT_X_ACTIVE != 0
 ldx obj_pos_x_cur
 ldy #0
 cpx #128
 bcc m2_x_positive
 dey
m2_x_positive:
 jsr m2_relative_s8
.endif
 sta rx0
 ldx light_phase
 lda light_pos_y,x
.if SCENE_OBJECT_Y_ACTIVE != 0
 ldx obj_pos_y_cur
 ldy #0
 cpx #128
 bcc m2_y_positive
 dey
m2_y_positive:
 jsr m2_relative_s8
.endif
 sta ry0
 ldx light_phase
 lda light_pos_z,x
 ldx obj_depth_lo
 ldy obj_depth_hi
 jsr m2_relative_s8
 sta rz0

 lda rx0
 ldx m00
 jsr m31_light_mul_s6
 sta sh_nx
 lda ry0
 ldx m10
 jsr m31_light_mul_s6
 ldx sh_nx
 jsr add_s8_sat
 sta sh_nx
 lda rz0
 ldx m20
 jsr m31_light_mul_s6
 ldx sh_nx
 jsr add_s8_sat
 sta sh_nx

 lda rx0
 ldx m01
 jsr m31_light_mul_s6
 sta sh_ny
 lda ry0
 ldx m11
 jsr m31_light_mul_s6
 ldx sh_ny
 jsr add_s8_sat
 sta sh_ny
 lda rz0
 ldx m21
 jsr m31_light_mul_s6
 ldx sh_ny
 jsr add_s8_sat
 sta sh_ny

 lda rx0
 ldx m02
 jsr m31_light_mul_s6
 sta sh_nz
 lda ry0
 ldx m12
 jsr m31_light_mul_s6
 ldx sh_nz
 jsr add_s8_sat
 sta sh_nz
 lda rz0
 ldx m22
 jsr m31_light_mul_s6
 ldx sh_nz
 jsr add_s8_sat
 sta sh_nz
 rts
.endif

.if MODE7_UV_CARRIER != 0
gouraud_update_object_shades:
gous_done:
 rts
.endif

interp_sintab:
 sta p1lo
 lda sintab,x
 sta p1hi
 inx
 lda sintab,x
 sec
 sbc p1hi
 beq is_done
 bmi is_neg
 cmp #$02
 beq is_pos2
 lda p1lo
 bpl is_done
 inc p1hi
 jmp is_done
is_pos2:
 lda p1lo
 cmp #$40
 bcc is_done
 inc p1hi
 lda p1lo
 cmp #$c0
 bcc is_done
 inc p1hi
 jmp is_done
is_neg:
 cmp #$ff
 beq is_neg1
 lda p1lo
 cmp #$40
 bcc is_done
 dec p1hi
 lda p1lo
 cmp #$c0
 bcc is_done
 dec p1hi
 jmp is_done
is_neg1:
 lda p1lo
 bpl is_done
 dec p1hi
is_done:
 lda p1hi
 rts

prepare_matrix:
 lda sinxv
 ldx sinyv
 jsr mul_s6
 sta t1
 lda cosxv
 ldx sinyv
 jsr mul_s6
 sta t2
 lda cosyv
 ldx coszv
 jsr mul_s6
 sta m00
 lda cosyv
 ldx sinzv
 jsr mul_s6
 sta m10
 lda sinyv
 eor #$ff
 clc
 adc #$01
 sta m20
 lda sinxv
 ldx cosyv
 jsr mul_s6
 sta m21
 lda cosxv
 ldx cosyv
 jsr mul_s6
 sta m22
 lda cosxv
 ldx sinzv
 jsr mul_s6
 sta p1lo
 lda t1
 ldx coszv
 jsr mul_s6
 sec
 sbc p1lo
 sta m01
 lda sinxv
 ldx sinzv
 jsr mul_s6
 sta p1lo
 lda t2
 ldx coszv
 jsr mul_s6
 clc
 adc p1lo
 sta m02
 lda cosxv
 ldx coszv
 jsr mul_s6
 sta p1lo
 lda t1
 ldx sinzv
 jsr mul_s6
 clc
 adc p1lo
 sta m11
 lda sinxv
 ldx coszv
 jsr mul_s6
 sta p1lo
 lda t2
 ldx sinzv
 jsr mul_s6
 sec
 sbc p1lo
 sta m12
 rts

apply_object_scale_to_matrix:
.if SCENE_OBJECT_COUNT != 0
 lda m00
 ldx obj_scale_cur
 jsr mul_s6
 sta m00
 lda m01
 ldx obj_scale_cur
 jsr mul_s6
 sta m01
 lda m02
 ldx obj_scale_cur
 jsr mul_s6
 sta m02
 lda m10
 ldx obj_scale_cur
 jsr mul_s6
 sta m10
 lda m11
 ldx obj_scale_cur
 jsr mul_s6
 sta m11
 lda m12
 ldx obj_scale_cur
 jsr mul_s6
 sta m12
 lda m20
 ldx obj_scale_cur
 jsr mul_s6
 sta m20
 lda m21
 ldx obj_scale_cur
 jsr mul_s6
 sta m21
 lda m22
 ldx obj_scale_cur
 jsr mul_s6
 sta m22
.endif
 rts

build_coord_terms:
 rts ; Q8 term caches are built separately

; Convert signed geometric camera depth in p1 to the non-zero unsigned
; physical projection-table index.  Negative inputs that remain <= 0 after
; the origin shift clamp to 1, so no table lookup can wrap or underflow.
projection_depth_index_from_p1:
 lda p1hi
 bmi pdifp_negative_source
 clc
 lda p1lo
 adc #PROJ_VIEW_DEPTH_BIAS
 sta p1lo
 lda p1hi
 adc #PROJ_VIEW_DEPTH_BIAS_HI
 sta p1hi
 rts
pdifp_negative_source:
 clc
 lda p1lo
 adc #PROJ_VIEW_DEPTH_BIAS
 sta p1lo
 lda p1hi
 adc #PROJ_VIEW_DEPTH_BIAS_HI
 sta p1hi
 bmi pdifp_clamp_one
 lda p1lo
 ora p1hi
 bne pdifp_done
pdifp_clamp_one:
 lda #$01
 sta p1lo
 lda #$00
 sta p1hi
pdifp_done:
 rts

load_projection_table_index:
 ldx tmpidx
 lda camera_depth_geometric_lo,x
 sta p1lo
 lda camera_depth_geometric_hi,x
 sta p1hi
 jmp projection_depth_index_from_p1

; Exact/reference projection divides by real geometric camera depth.  Clamp
; invalid or crossing depths to the same near plane used by visibility; the
; +190 physical table origin must never enter this divisor.
clamp_projection_geometric_divisor_p1:
 lda p1hi
 bmi cpgdp_clamp_near
 bne cpgdp_done
 lda p1lo
 cmp #PROJ_CAMERA_FACE_MIN_DEPTH
 bcs cpgdp_done
cpgdp_clamp_near:
 lda #PROJ_CAMERA_FACE_MIN_DEPTH
 sta p1lo
 lda #$00
 sta p1hi
cpgdp_done:
 rts

load_projection_geometric_divisor:
 ldx tmpidx
 lda camera_depth_geometric_lo,x
 sta p1lo
 lda camera_depth_geometric_hi,x
 sta p1hi
 jmp clamp_projection_geometric_divisor_p1

.if CAMERA_MOVABLE != 0
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0 && FPS_OVERLAY_ENABLE != 0
explorer_camera_low_return = *
.if MODE7_UV_CARRIER != 0
* = $8800
.else
* = $9b80
.endif
.if MODE7_UV_CARRIER != 0
.if * < $8800 || * >= $9000
 .error "Mode 6 relocated camera start address out of range ($8800..$8FFF)"
.endif
.else
.if * < $9000 || * >= $a000
 .error "Relocated camera start address out of range ($9000..$9FFF)"
.endif
.endif
explorer_camera_relocated_start = *
.endif
explorer_init_camera:
 lda #EXPLORER_CAMERA_X_LO
 sta explorer_cam_x_lo
 lda #EXPLORER_CAMERA_X_HI
 sta explorer_cam_x_hi
 lda #EXPLORER_CAMERA_X_EXT
 sta explorer_cam_x_ext
 lda #EXPLORER_CAMERA_Y_LO
 sta explorer_cam_y_lo
 lda #EXPLORER_CAMERA_Y_HI
 sta explorer_cam_y_hi
 lda #EXPLORER_CAMERA_Y_EXT
 sta explorer_cam_y_ext
 lda #EXPLORER_CAMERA_Z_LO
 sta explorer_cam_z_lo
 lda #EXPLORER_CAMERA_Z_HI
 sta explorer_cam_z_hi
 lda #EXPLORER_CAMERA_Z_EXT
 sta explorer_cam_z_ext
.if CAMERA_SMOOTH_DEPTH_ACTIVE != 0
 lda #CAMERA_SMOOTH_DEPTH_PHASE_START
 sta camera_smooth_depth_phase
.endif
 lda #EXPLORER_CAMERA_YAW
 sta explorer_cam_yaw
 lda #EXPLORER_CAMERA_PITCH
 sta explorer_cam_pitch
.if CAMERA_RUNTIME_CONTROLS != 0
 lda #$00
 sta explorer_yaw_repeat_phase
 sta explorer_pitch_repeat_phase
.if CAMERA_ROLL_CONTROL != 0
 sta explorer_roll_repeat_phase
.endif
.endif
.if CAMERA_ROLL_ACTIVE != 0
 lda #EXPLORER_CAMERA_ROLL
 sta explorer_cam_roll
 lda #$00
 sta explorer_look_yaw_acc_lo
 sta explorer_look_yaw_acc_hi
 sta explorer_look_pitch_acc_lo
 sta explorer_look_pitch_acc_hi
.endif
 rts

.if CAMERA_SMOOTH_DEPTH_ACTIVE != 0
advance_camera_smooth_depth_ping_pong:
 clc
 lda camera_smooth_depth_phase
 adc #CAMERA_SMOOTH_DEPTH_PHASE_STEP
 sta camera_smooth_depth_phase
 tay
 lda camera_smooth_depth_pos_lo,y
 sta explorer_cam_z_lo
 lda camera_smooth_depth_pos_hi,y
 sta explorer_cam_z_hi
 lda camera_smooth_depth_pos_ext,y
 sta explorer_cam_z_ext
 rts
.endif

explorer_scan_keys:
 lda #$fe
 sta $dc00
 lda $dc01
 sta explorer_key_col0
 lda #$fd
 sta $dc00
 lda $dc01
 sta explorer_key_col1
 lda #$fb
 sta $dc00
 lda $dc01
 sta explorer_key_col2
.if CAMERA_ROLL_CONTROL != 0
 lda #$ef
 sta $dc00
 lda $dc01
 sta explorer_key_col4
.endif
 lda #$bf
 sta $dc00
 lda $dc01
 sta explorer_key_col6
 lda #$7f
 sta $dc00
 lda $dc01
 sta explorer_key_col7
 lda #$ff
 sta $dc00
 rts

.if CAMERA_MODE_CYCLE != 0
explorer_scan_mode_cycle_key:
 lda #$fe
 sta $dc00
 lda $dc01
 sta explorer_key_col0
 lda #$fd
 sta $dc00
 lda $dc01
 sta explorer_key_col1
 lda #$bf
 sta $dc00
 lda $dc01
 sta explorer_key_col6
 lda #$ff
 sta $dc00
 rts
.endif

.if CAMERA_MODE_CYCLE != 0
explorer_poll_mode_cycle_f1:
 lda explorer_key_col0
 and #$10
 bne epm_f1_released
 lda explorer_key_col1
 and #$80
 beq epm_done
 lda explorer_key_col6
 and #$10
 beq epm_done
 lda explorer_mode_latch
 bne epm_done
 lda #$01
 sta explorer_mode_latch
 clc
 lda explorer_runtime_mode
 adc #$01
 cmp #$03
 bcc epm_store
 lda #$01
epm_store:
 sta explorer_runtime_mode
 lda #$00
 sta explorer_yaw_repeat_phase
 sta explorer_pitch_repeat_phase
.if CAMERA_ROLL_CONTROL != 0
 sta explorer_roll_repeat_phase
.endif
 lda explorer_runtime_mode
 cmp #$01
 beq epm_enter_lite
 rts
epm_enter_lite:
 lda #$00
 sta explorer_cam_pitch
.if CAMERA_ROLL_ACTIVE != 0
 sta explorer_cam_roll
 sta explorer_look_yaw_acc_lo
 sta explorer_look_yaw_acc_hi
 sta explorer_look_pitch_acc_lo
 sta explorer_look_pitch_acc_hi
.endif
 rts
epm_f1_released:
 lda #$00
 sta explorer_mode_latch
epm_done:
 rts
.endif

.if EXPLORER_RESET_ON_SPACE != 0
explorer_poll_camera_reset:
 lda #$00
 sta explorer_camera_tick_skip
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 beq epcr_done
.endif
 lda explorer_key_col7
 and #$10
 bne epcr_done
 jsr explorer_init_camera
 lda #$01
 sta explorer_camera_tick_skip
epcr_done:
 lda #$ff
 sta $dc00
 rts
.endif

explorer_advance_camera_tick:
.if EXPLORER_RESET_ON_SPACE != 0
 lda explorer_camera_tick_skip
 bne eact_done
.endif
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 beq eact_done
 cmp #$01
 beq eact_simple_look
.endif
.if CAMERA_ROLL_ACTIVE != 0
 jsr explorer_update_look_rolled
 jmp eact_motion
.endif
eact_simple_look:
 lda explorer_key_col0
 and #$04
 bne eact_yaw_released
 lda explorer_key_col1
 and #$80
 beq eact_yaw_left
 lda explorer_key_col6
 and #$10
 beq eact_yaw_left
eact_yaw_right:
 jsr explorer_yaw_repeat_ready
 bcc eact_after_yaw
 sec
 lda explorer_cam_yaw
 sbc #EXPLORER_LOOK_STEP
 sta explorer_cam_yaw
 jmp eact_after_yaw
eact_yaw_left:
 jsr explorer_yaw_repeat_ready
 bcc eact_after_yaw
 clc
 lda explorer_cam_yaw
 adc #EXPLORER_LOOK_STEP
 sta explorer_cam_yaw
 jmp eact_after_yaw
eact_yaw_released:
 lda #$00
 sta explorer_yaw_repeat_phase
eact_after_yaw:
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 cmp #$01
 beq eact_motion
.endif
.if CAMERA_WALK_LITE = 0 || ENGINE_CAMERA_WALK_LITE_PITCH_RUNTIME_ACTIVE != 0
 lda explorer_key_col0
 and #$80
 bne eact_pitch_released
 lda explorer_key_col1
 and #$80
 beq eact_pitch_up
 lda explorer_key_col6
 and #$10
 beq eact_pitch_up
eact_pitch_down:
 jsr explorer_pitch_repeat_ready
 bcc eact_look_done
 clc
 lda explorer_cam_pitch
 adc #EXPLORER_LOOK_STEP
 sta explorer_cam_pitch
 jmp eact_clamp_pitch
eact_pitch_up:
 jsr explorer_pitch_repeat_ready
 bcc eact_look_done
 sec
 lda explorer_cam_pitch
 sbc #EXPLORER_LOOK_STEP
 sta explorer_cam_pitch
eact_clamp_pitch:
 lda explorer_cam_pitch
 bpl eact_pitch_positive
 cmp #EXPLORER_PITCH_NEG_MIN
 bcs eact_look_done
 lda #EXPLORER_PITCH_NEG_MIN
 sta explorer_cam_pitch
 jmp eact_look_done
eact_pitch_positive:
 cmp #EXPLORER_PITCH_POS_LIMIT
 bcc eact_look_done
 lda #EXPLORER_PITCH_POS_MAX
 sta explorer_cam_pitch
 jmp eact_look_done
eact_pitch_released:
 lda #$00
 sta explorer_pitch_repeat_phase
eact_look_done:
.endif
eact_motion:
 jsr explorer_prepare_motion_axes

 ; Opposite linear commands are neutral. There is no translation repeat phase,
 ; so releasing either key immediately exposes the still-held direction.
 lda explorer_key_col1
 and #$22
 beq eact_no_ws
 cmp #$22
 beq eact_no_ws
 and #$02
 bne eact_move_s
 jsr explorer_move_forward
 jmp eact_no_ws
eact_move_s:
 jsr explorer_move_back
eact_no_ws:

 lda explorer_key_col1
 and #$04
 bne eact_check_d
 lda explorer_key_col2
 and #$04
 beq eact_no_ad
 jsr explorer_strafe_left
 jmp eact_no_ad
eact_check_d:
 lda explorer_key_col2
 and #$04
 bne eact_no_ad
 jsr explorer_strafe_right
eact_no_ad:

 lda explorer_key_col7
 and #$40
 bne eact_check_e
 lda explorer_key_col1
 and #$40
 beq eact_done
 jsr explorer_move_up
 jmp eact_done
eact_check_e:
 lda explorer_key_col1
 and #$40
 bne eact_done
 jsr explorer_move_down
eact_done:
 rts

explorer_yaw_repeat_ready:
 lda explorer_yaw_repeat_phase
 beq eyr_ready
 dec explorer_yaw_repeat_phase
 clc
 rts
eyr_ready:
 lda #EXPLORER_YAW_PITCH_REPEAT_PHASE
 sta explorer_yaw_repeat_phase
 sec
 rts

explorer_pitch_repeat_ready:
 lda explorer_pitch_repeat_phase
 beq epr_ready
 dec explorer_pitch_repeat_phase
 clc
 rts
epr_ready:
 lda #EXPLORER_YAW_PITCH_REPEAT_PHASE
 sta explorer_pitch_repeat_phase
 sec
 rts

.if CAMERA_ROLL_CONTROL != 0
explorer_roll_repeat_ready:
 lda explorer_roll_repeat_phase
 beq err_ready
 dec explorer_roll_repeat_phase
 clc
 rts
err_ready:
 lda #EXPLORER_ROLL_REPEAT_RELOAD
 sta explorer_roll_repeat_phase
 sec
 rts
.endif


explorer_prepare_motion_axes:
 lda #$00
 sec
 sbc explorer_cam_yaw
 tax
 lda sintab,x
 sta sinyv
 txa
 clc
 adc #$40
 tax
 lda sintab,x
 sta cosyv
.if CAMERA_ROLL_ACTIVE != 0
 lda #$00
 sec
 sbc explorer_cam_roll
 tax
 lda sintab,x
 sta sinzv
 txa
 clc
 adc #$40
 tax
 lda sintab,x
 sta coszv
.endif
 rts

explorer_prepare_view:
 jsr explorer_prepare_motion_axes
.if ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH != 0
 lda explorer_cam_pitch
 bne epv_engine_pitch_lookup
 lda #$00
 sta sinxv
 lda #$40
 sta cosxv
 jmp epv_engine_pitch_ready
epv_engine_pitch_lookup:
.endif
 lda #$00
 sec
 sbc explorer_cam_pitch
 tax
 lda sintab,x
 sta sinxv
 txa
 clc
 adc #$40
 tax
 lda sintab,x
 sta cosxv
.if ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH != 0
epv_engine_pitch_ready:
.endif
 rts

.if POLY_FILL_ENABLE = 0
explorer_cache_current_view:
 lda sinyv
 sta explorer_cached_siny
 lda cosyv
 sta explorer_cached_cosy
 lda sinxv
 sta explorer_cached_sinx
 lda cosxv
 sta explorer_cached_cosx
.if CAMERA_ROLL_ACTIVE != 0
 lda sinzv
 sta explorer_cached_sinz
 lda coszv
 sta explorer_cached_cosz
.endif
 rts

explorer_load_cached_view:
 lda explorer_cached_siny
 sta sinyv
 lda explorer_cached_cosy
 sta cosyv
 lda explorer_cached_sinx
 sta sinxv
 lda explorer_cached_cosx
 sta cosxv
.if CAMERA_ROLL_ACTIVE != 0
 lda explorer_cached_sinz
 sta sinzv
 lda explorer_cached_cosz
 sta coszv
.endif
 rts
.endif

explorer_move_forward:
 lda sinyv
 jsr explorer_add_x_scaled
 lda cosyv
 jsr explorer_add_z_scaled
 lda #$00
 beq emf_done
 lda sinxv
 jsr explorer_add_y_scaled
emf_done:
 rts

explorer_move_back:
 lda sinyv
 jsr explorer_negate_a
 jsr explorer_add_x_scaled
 lda cosyv
 jsr explorer_negate_a
 jsr explorer_add_z_scaled
 lda #$00
 beq emb_done
 lda sinxv
 jsr explorer_negate_a
 jsr explorer_add_y_scaled
emb_done:
 rts

explorer_strafe_left:
.if CAMERA_ROLL_ACTIVE != 0
 jsr explorer_calc_roll_right_axis
 jsr explorer_move_axis_neg
 rts
.else
 lda cosyv
 jsr explorer_negate_a
 jsr explorer_add_x_scaled
 lda sinyv
 jsr explorer_add_z_scaled
 rts
.endif

explorer_strafe_right:
.if CAMERA_ROLL_ACTIVE != 0
 jsr explorer_calc_roll_right_axis
 jsr explorer_move_axis_pos
 rts
.else
 lda cosyv
 jsr explorer_add_x_scaled
 lda sinyv
 jsr explorer_negate_a
 jsr explorer_add_z_scaled
 rts
.endif

explorer_move_up:
.if CAMERA_ROLL_ACTIVE != 0
 jsr explorer_calc_roll_up_axis
 jsr explorer_move_axis_pos
 rts
.else
 lda #$40
 jsr explorer_add_y_scaled
 rts
.endif

explorer_move_down:
.if CAMERA_ROLL_ACTIVE != 0
 jsr explorer_calc_roll_up_axis
 jsr explorer_move_axis_neg
 rts
.else
 lda #$c0
 jsr explorer_add_y_scaled
 rts
.endif

.if CAMERA_ROLL_ACTIVE != 0
explorer_calc_roll_right_axis:
 lda cosyv
 ldx coszv
 jsr mul_s6
 sta rx0
 sec
 lda #$00
 sbc sinzv
 sta ry0
 lda sinyv
 jsr explorer_negate_a
 ldx coszv
 jsr mul_s6
 sta rz0
 rts

explorer_calc_roll_up_axis:
 lda cosyv
 ldx sinzv
 jsr mul_s6
 sta rx0
 lda coszv
 sta ry0
 lda sinyv
 jsr explorer_negate_a
 ldx sinzv
 jsr mul_s6
 sta rz0
 rts

explorer_move_axis_pos:
 lda rx0
 jsr explorer_add_x_scaled
 lda ry0
 jsr explorer_add_y_scaled
 lda rz0
 jsr explorer_add_z_scaled
 rts

explorer_move_axis_neg:
 lda rx0
 jsr explorer_negate_a
 jsr explorer_add_x_scaled
 lda ry0
 jsr explorer_negate_a
 jsr explorer_add_y_scaled
 lda rz0
 jsr explorer_negate_a
 jsr explorer_add_z_scaled
 rts
.endif

explorer_add_x_scaled:
 ldx #EXPLORER_MOVE_STEP
 jsr mul_s6
 sta explorer_delta_lo
 jsr explorer_sign_extend_delta
 clc
 lda explorer_cam_x_lo
 adc explorer_delta_lo
 sta explorer_cam_x_lo
 lda explorer_cam_x_hi
 adc explorer_delta_hi
 sta explorer_cam_x_hi
 lda explorer_cam_x_ext
 adc explorer_delta_ext
 sta explorer_cam_x_ext
 rts

explorer_add_y_scaled:
 ldx #EXPLORER_MOVE_STEP
 jsr mul_s6
 sta explorer_delta_lo
 jsr explorer_sign_extend_delta
 clc
 lda explorer_cam_y_lo
 adc explorer_delta_lo
 sta explorer_cam_y_lo
 lda explorer_cam_y_hi
 adc explorer_delta_hi
 sta explorer_cam_y_hi
 lda explorer_cam_y_ext
 adc explorer_delta_ext
 sta explorer_cam_y_ext
 rts

explorer_add_z_scaled:
 ldx #EXPLORER_MOVE_STEP
 jsr mul_s6
 sta explorer_delta_lo
 jsr explorer_sign_extend_delta
 clc
 lda explorer_cam_z_lo
 adc explorer_delta_lo
 sta explorer_cam_z_lo
 lda explorer_cam_z_hi
 adc explorer_delta_hi
 sta explorer_cam_z_hi
 lda explorer_cam_z_ext
 adc explorer_delta_ext
 sta explorer_cam_z_ext
 rts

explorer_sign_extend_delta:
 lda explorer_delta_lo
 bpl esed_pos
 lda #$ff
 sta explorer_delta_hi
 sta explorer_delta_ext
 rts
esed_pos:
 lda #$00
 sta explorer_delta_hi
 sta explorer_delta_ext
 rts

explorer_negate_a:
 eor #$ff
 clc
 adc #$01
 rts

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && CAMERA_MOVABLE != 0 && MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0 && FPS_OVERLAY_ENABLE != 0
explorer_camera_relocated_end = *
.if MODE7_UV_CARRIER != 0
.if explorer_camera_relocated_end > $9000
 .error "Mode 6 relocated camera block exceeds $9000"
.endif
.else
.if explorer_camera_relocated_end > $a000
 .error "Relocated camera block exceeds $A000"
.endif
.endif
* = explorer_camera_low_return
.endif

explorer_sub_cam_x:
 sta p1lo
 bpl escx_world_pos
 lda #$ff
 jmp escx_world_ext_ready
escx_world_pos:
 lda #$00
escx_world_ext_ready:
 sta p1hi
 sec
 lda #$00
 sbc explorer_cam_x_lo
 lda p1lo
 sbc explorer_cam_x_hi
 sta explorer_rel_x_lo
 lda p1hi
 sbc explorer_cam_x_ext
 sta explorer_rel_x_hi
 rts

explorer_sub_cam_y:
 sta p1lo
 bpl escy_world_pos
 lda #$ff
 jmp escy_world_ext_ready
escy_world_pos:
 lda #$00
escy_world_ext_ready:
 sta p1hi
 sec
 lda #$00
 sbc explorer_cam_y_lo
 lda p1lo
 sbc explorer_cam_y_hi
 sta explorer_rel_y_lo
 lda p1hi
 sbc explorer_cam_y_ext
 sta explorer_rel_y_hi
 rts

explorer_sub_cam_z16:
 sec
 lda #$00
 sbc explorer_cam_z_lo
 lda rz1
 sbc explorer_cam_z_hi
 sta rz1
 lda explorer_z_world_hi
 sbc explorer_cam_z_ext
 sta explorer_z_hi16
 rts

mul_s16_s6:
 sta mul16mul
 sta mul16abs
 lda #$00
 sta mul16sign
 lda p1hi
 bpl ms16_coord_ok
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
 lda mul16sign
 eor #$80
 sta mul16sign
ms16_coord_ok:
 lda mul16mul
 bpl ms16_mul_ok
 eor #$ff
 clc
 adc #$01
 sta mul16mul
 sta mul16abs
 lda mul16sign
 eor #$80
 sta mul16sign
ms16_mul_ok:
 lda p1lo
 and #$3f
 sta mul16rem
 ldx #$06
ms16_shift_q:
 lsr p1hi
 ror p1lo
 dex
 bne ms16_shift_q
 lda p1lo
 sta mul16lo
 lda p1hi
 sta mul16hi
 lda #$00
 sta mul16reslo
 sta mul16reshi
 ldx #$08
ms16_mul_loop:
 lsr mul16mul
 bcc ms16_no_add
 clc
 lda mul16reslo
 adc mul16lo
 sta mul16reslo
 lda mul16reshi
 adc mul16hi
 sta mul16reshi
ms16_no_add:
 asl mul16lo
 rol mul16hi
 dex
 bne ms16_mul_loop
 lda mul16rem
 beq ms16_no_rem
 ldx mul16abs
 jsr mul_s6
 clc
 adc mul16reslo
 sta mul16reslo
 bcc ms16_no_rem
 inc mul16reshi
ms16_no_rem:
 lda mul16reslo
 sta p1lo
 lda mul16reshi
 sta p1hi
 lda mul16sign
 bpl ms16_done
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
ms16_done:
 rts

explorer_axis_to_byte:
 lda p1hi
 bmi eatb_negative
 bne eatb_pos_sat
 lda p1lo
 bpl eatb_done
eatb_pos_sat:
 lda #$7f
 rts
eatb_negative:
 cmp #$ff
 bne eatb_neg_sat
 lda p1lo
 bmi eatb_done
eatb_neg_sat:
 lda #$80
eatb_done:
 rts

explorer_project_axis_offset:
 lda #$00
 sta mul16sign
 lda p1hi
 bpl epao_abs_ready
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
 lda #$80
 sta mul16sign
epao_abs_ready:
 lda p1lo
 sta mul16lo
 lda p1hi
 sta mul16hi
 jsr load_projection_table_index
.if EXPLORER_TABLE_PROJECTION != 0
 lda p1hi
 bne epao_exact_project
 lda mul16hi
 bne epao_exact_project
 lda mul16lo
 bmi epao_exact_project
 ldx p1lo
 lda scene_scale_tab,x
 bmi epao_exact_project
 tax
 lda mul16lo
 jsr mul_s6_xpos_round
 cmp #$7f
 bcs epao_exact_project
 sta scalev
 sta mul16reslo
 lda #$00
 sta mul16reshi
 rts
epao_exact_project:
.endif
 jsr load_projection_geometric_divisor
 lda mul16hi
 beq epao_mul_start
epao_scale_loop:
 lsr mul16hi
 ror mul16lo
 lsr p1hi
 ror p1lo
 lda p1lo
 ora p1hi
 bne epao_depth_nonzero
 lda #$01
 sta p1lo
epao_depth_nonzero:
 lda mul16hi
 bne epao_scale_loop
epao_mul_start:
 lda #EXPLORER_PROJ_FOCAL
 sta mul16mul
 lda #$00
 sta prodlo
 sta prodhi
 sta mul16rem
 ldx #$08
epao_mul_loop:
 lsr mul16mul
 bcc epao_no_add
 lda mul16rem
 bne epao_saturate
 clc
 lda prodlo
 adc mul16lo
 sta prodlo
 lda prodhi
 adc mul16hi
 sta prodhi
 bcs epao_saturate
epao_no_add:
 asl mul16lo
 rol mul16hi
 bcc epao_shift_ok
 lda #$01
 sta mul16rem
epao_shift_ok:
 dex
 bne epao_mul_loop
 jmp epao_divide
epao_saturate:
 lda #$ff
 sta prodlo
 sta prodhi
epao_divide:
 jsr div16u
 lda prodlo
 sta mul16reslo
 lda prodhi
 sta mul16reshi
 lda prodhi
 beq epao_offset_ok
 lda #$ff
 sta scalev
 rts
epao_offset_ok:
 lda prodlo
 sta scalev
 rts

explorer_project_x16:
 jsr explorer_project_axis_offset
.if EXPLORER_SCREEN_RAW != 0
 jsr explorer_store_raw_x
.endif
 lda mul16sign
 bmi epx_left
 lda scalev
 cmp #PROJ_CENTER_X
 bcc epx_right_visible
 lda #PROJ_SCREEN_MAX_X
 jmp epx_store
epx_right_visible:
 clc
 adc #PROJ_CENTER_X
 jmp epx_store
epx_left:
 lda scalev
 cmp #(PROJ_CENTER_X + 1)
 bcc epx_left_visible
 lda #PROJ_SCREEN_MIN_X
 jmp epx_store
epx_left_visible:
 sta p1lo
 lda #PROJ_CENTER_X
 sec
 sbc p1lo
epx_store:
 ldy tmpidx
 sta sx,y
 rts

.if EXPLORER_SCREEN_RAW != 0
explorer_store_raw_x:
 ldy tmpidx
 lda mul16reshi
 cmp #$ff
 bne esrx_not_saturated
 lda mul16sign
 bmi esrx_left_saturated
 lda #$00
 sta pxrawlo,y
 lda #$7f
 sta pxrawhi,y
 rts
esrx_left_saturated:
 lda #$00
 sta pxrawlo,y
 lda #$80
 sta pxrawhi,y
 rts
esrx_not_saturated:
 lda mul16sign
 bmi esrx_left
 clc
 lda mul16reslo
 adc #PROJ_CENTER_X
 sta pxrawlo,y
 lda mul16reshi
 adc #$00
 sta pxrawhi,y
 rts
esrx_left:
 lda #PROJ_CENTER_X
 sec
 sbc mul16reslo
 sta pxrawlo,y
 lda #$00
 sbc mul16reshi
 sta pxrawhi,y
 rts
.endif

; Phase 1 mobile Native-Y Q2 projection.  The input in p1 is the signed
; 16-bit camera-space Y after yaw/pitch and, for walkFull, after roll.
; explorer_project_axis_offset performs the sole perspective division and
; leaves quotient in mul16res, remainder in cross, and the positive 16-bit
; depth divisor in p1.  The legacy sy and raw screen Y are stored before two
; bounded binary remainder steps retain the next two quotient bits.
explorer_project_yq2_16:
 jsr explorer_project_axis_offset
.if EXPLORER_SCREEN_RAW != 0
 jsr explorer_store_raw_y
.endif
 lda mul16sign
 bmi eyq2_legacy_down
 lda scalev
 cmp #(PROJ_CENTER_Y + 1)
 bcc eyq2_legacy_up_visible
 lda #PROJ_SCREEN_MIN_Y
 jmp eyq2_legacy_store
eyq2_legacy_up_visible:
 lda #PROJ_CENTER_Y
 sec
 sbc scalev
 jmp eyq2_legacy_store
eyq2_legacy_down:
 lda scalev
 cmp #PROJ_CENTER_Y
 bcc eyq2_legacy_down_visible
 lda #PROJ_SCREEN_MAX_Y
 jmp eyq2_legacy_store
eyq2_legacy_down_visible:
 clc
 adc #PROJ_CENTER_Y
eyq2_legacy_store:
 ldy tmpidx
 sta sy,y
 lda #$00
 sta mul16rem
 jsr explorer_project_yq2_fraction_bit
 jsr explorer_project_yq2_fraction_bit
 asl mul16reslo
 rol mul16reshi
 asl mul16reslo
 rol mul16reshi
 clc
 lda mul16reslo
 adc mul16rem
 sta mul16reslo
 lda mul16reshi
 adc #$00
 sta mul16reshi
 lda mul16sign
 bmi eyq2_down
eyq2_up:
 lda mul16reshi
 bne eyq2_clamp_zero
 lda mul16reslo
 cmp #YQ2_VIEWPORT_CENTER_PLUS_ONE
 bcs eyq2_clamp_zero
 lda #YQ2_VIEWPORT_CENTER_LO
 sec
 sbc mul16reslo
 sta p1lo
 lda #YQ2_VIEWPORT_CENTER_HI
 sta p1hi
 jmp eyq2_store
eyq2_down:
 lda mul16reshi
 bne eyq2_clamp_max
 lda mul16reslo
 cmp #YQ2_VIEWPORT_BELOW_CENTER_LIMIT_PLUS_ONE
 bcs eyq2_clamp_max
 clc
 adc #YQ2_VIEWPORT_CENTER_LO
 sta p1lo
 lda #YQ2_VIEWPORT_CENTER_HI
 adc #$00
 sta p1hi
 jmp eyq2_store
eyq2_clamp_zero:
 lda #$00
 sta p1lo
 sta p1hi
 jmp eyq2_store
eyq2_clamp_max:
 lda #YQ2_VIEWPORT_MAX_LO
 sta p1lo
 lda #YQ2_VIEWPORT_MAX_HI
 sta p1hi
eyq2_store:
 ldy tmpidx
 lda p1lo
 sta syq2_lo,y
 lda p1hi
 sta syq2_hi,y
 rts

explorer_project_yq2_fraction_bit:
 asl mul16rem
 asl crosslo
 rol crosshi
 lda crosshi
 cmp p1hi
 bcc eyq2_fraction_done
 bne eyq2_fraction_subtract
 lda crosslo
 cmp p1lo
 bcc eyq2_fraction_done
eyq2_fraction_subtract:
 sec
 lda crosslo
 sbc p1lo
 sta crosslo
 lda crosshi
 sbc p1hi
 sta crosshi
 inc mul16rem
eyq2_fraction_done:
 rts

; This predicate reads only the established clipping state.  It never writes
; clip buffers and allows XY-Q2 only for the original, fully visible polygon.
mobile_yq2_face_eligible:
.if EXPLORER_NEAR_POLY != 0
 lda near_face_crossing
 bne myq2_face_no
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 bne myq2_face_no
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
 lda clip_second_pending
 bne myq2_face_no
.endif
 sec
 rts
myq2_face_no:
 clc
 rts
explorer_project_y16:
 jsr explorer_project_axis_offset
.if EXPLORER_SCREEN_RAW != 0
 jsr explorer_store_raw_y
.endif
 lda mul16sign
 bmi epy_down
 lda scalev
 cmp #(PROJ_CENTER_Y + 1)
 bcc epy_up_visible
 lda #PROJ_SCREEN_MIN_Y
 jmp epy_store
epy_up_visible:
 sta p1lo
 lda #PROJ_CENTER_Y
 sec
 sbc p1lo
 jmp epy_store
epy_down:
 lda scalev
 cmp #PROJ_CENTER_Y
 bcc epy_down_visible
 lda #PROJ_SCREEN_MAX_Y
 jmp epy_store
epy_down_visible:
 clc
 adc #PROJ_CENTER_Y
epy_store:
 ldy tmpidx
 sta sy,y
 rts

.if EXPLORER_SCREEN_RAW != 0
explorer_store_raw_y:
 ldy tmpidx
 lda mul16reshi
 cmp #$ff
 bne esry_not_saturated
 lda mul16sign
 bmi esry_down_saturated
 lda #$00
 sta pyrawlo,y
 lda #$80
 sta pyrawhi,y
 rts
esry_down_saturated:
 lda #$00
 sta pyrawlo,y
 lda #$7f
 sta pyrawhi,y
 rts
esry_not_saturated:
 lda mul16sign
 bmi esry_down
 lda #PROJ_CENTER_Y
 sec
 sbc mul16reslo
 sta pyrawlo,y
 lda #$00
 sbc mul16reshi
 sta pyrawhi,y
 rts
esry_down:
 clc
 lda mul16reslo
 adc #PROJ_CENTER_Y
 sta pyrawlo,y
 lda mul16reshi
 adc #$00
 sta pyrawhi,y
 rts
.endif

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0 && WIRE_RENDER_ENABLE != 0 && WIRE_MESH_COUNT != 0
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
* = $4000
.if CAMERA_MOVABLE != 0
.endif
.endif
render_explorer_scene_points:
.if SCENE_OBJECT_COUNT != 0
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && MODE2_FACE_BUCKET_PIPELINE = 0
.if WIRE_OBJECT_SORT_ENABLE != 0
.else
 jsr explorer_cache_current_view
 lda #$00
 sta objidx
resp_wire_loop:
.if SCENE_OBJECT_VISIBILITY_ACTIVE != 0
 ldx objidx
 lda object_visible,x
 beq resp_wire_next_object
.endif
 jsr set_active_object
.if WORLD_GROUND_OCCLUDE != 0 && HIDDEN_WIRE_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WORLD_GROUND_WIRE_OCCLUDE = 0
 jsr ground_object_visible
 beq resp_wire_next_object
.endif
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_explorer_matrix_fold
.else
 jsr prepare_angles
 jsr explorer_load_cached_view
.endif
 jsr explorer_transform_project_vertices
 jsr draw_wire_active_mesh
resp_wire_next_object:
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bne resp_wire_loop
.endif
.else
 jsr begin_depth_buckets
 lda #$00
 sta objidx
resp_loop:
.if SCENE_OBJECT_VISIBILITY_ACTIVE != 0
 ldx objidx
 lda object_visible,x
 beq resp_next_object
.endif
 jsr set_active_object
.if WIRE_MESH_COUNT != 0
 ldx meshidx
 lda mesh_is_wire,x
 beq resp_solid_object
.if WORLD_GROUND_OCCLUDE != 0 && POLY_FILL_ENABLE != 0
 jsr ground_object_visible
 beq resp_next_object
.endif
.if WIRE_DEPTH_SORT_ENABLE != 0
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_explorer_matrix_fold
.else
 jsr prepare_angles
 jsr explorer_prepare_view
.if STABLE_FACE_CULL_PROFILE != 0
 jsr stable_face_cull_prepare_movable_matrix
.endif
.endif
 jsr explorer_transform_project_vertices
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0
 ldx meshidx
 lda mesh_face_first,x
 cmp mesh_face_end,x
 beq resp_wire_depth_edges
 jsr collect_active_mesh_faces
 jmp resp_next_object
resp_wire_depth_edges:
.endif
 jsr bucket_visible_wire_object
.endif
 jmp resp_next_object
resp_solid_object:
.endif
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_explorer_matrix_fold
.if MODE4_OBJECT_LIGHT_CACHE != 0
 jsr prepare_object_light_for_shade
 jsr m3_update_shades
.if MODE7_UV_CARRIER != 0
.endif
.endif
.else
 jsr prepare_angles
.if MODE4_OBJECT_LIGHT_CACHE != 0
 jsr prepare_object_light_for_shade
 jsr m3_update_shades
.if MODE7_UV_CARRIER != 0
.endif
.endif
 jsr explorer_prepare_view
.if STABLE_FACE_CULL_PROFILE != 0
 jsr stable_face_cull_prepare_movable_matrix
.endif
.endif
 jsr explorer_transform_project_vertices
 jsr collect_active_mesh_faces
resp_next_object:
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bne resp_loop
 jsr draw_depth_buckets
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0 && POLY_FILL_ENABLE = 0
 jsr draw_hidden_poly_scene_objects
.if WIRE_MESH_COUNT != 0
 jsr draw_front_wire_depth_entries
.endif
.endif
.if WIRE_OVERLAY_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE = 0
 jsr draw_wire_scene_objects
.endif
.endif
.else
 jsr explorer_prepare_view
.if STABLE_FACE_CULL_PROFILE != 0
 jsr stable_face_cull_prepare_movable_matrix
.endif
 jsr explorer_transform_project_vertices
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && MODE2_FACE_BUCKET_PIPELINE = 0
 jsr draw_wire_active_mesh
.else
 jsr draw_mesh
.if WIRE_OVERLAY_ENABLE != 0
 jsr draw_wire_active_mesh
.endif
.endif
.endif
 rts

; Q8-only: old integer polygon clip retired.
hp_legacy_transform_project_vertices = hp_unreachable
.if WIRE_FACE_EDGE_ENABLE != 0 && HIDDEN_WIRE_ENABLE = 0 && POLY_FILL_ENABLE = 0
.endif
etpv_loop = hp_unreachable
.if WORLD_GROUND_OCCLUDE != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if EXPLORER_MATRIX_FOLD != 0
etpv_fold_x_pos = hp_unreachable
etpv_fold_x_ext_ready = hp_unreachable
etpv_fold_y_pos = hp_unreachable
etpv_fold_y_ext_ready = hp_unreachable
etpv_fold_z_pos = hp_unreachable
etpv_fold_z_ext_ready = hp_unreachable
.else
.if SCENE_OBJECT_COUNT != 0
.if SCENE_OBJECT_X_ACTIVE != 0
.endif
.if SCENE_OBJECT_Y_ACTIVE != 0
.endif
etpv_local_z_pos = hp_unreachable
etpv_local_z_ready = hp_unreachable
.endif
.if SCENE_OBJECT_COUNT = 0
etpv_mesh_z_pos = hp_unreachable
etpv_mesh_z_ready = hp_unreachable
.endif
.if ENGINE_CAMERA_WALK_LITE_PITCH_RUNTIME_ACTIVE != 0
etpv_engine_walk_pitch_apply = hp_unreachable
etpv_engine_walk_pitch_done = hp_unreachable
.else
.if CAMERA_WALK_LITE != 0
.else
.if CAMERA_MODE_CYCLE != 0
etpv_pitch_runtime = hp_unreachable
.endif
.if CAMERA_MODE_CYCLE != 0
etpv_after_pitch = hp_unreachable
.endif
.endif
.endif
.if CAMERA_ROLL_ACTIVE != 0
.if CAMERA_MODE_CYCLE != 0
.endif
.if CAMERA_MODE_CYCLE != 0
etpv_skip_roll = hp_unreachable
.endif
.endif
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
.endif
etpv_depth_valid = hp_unreachable
etpv_depth_invalid = hp_unreachable
.if EXPLORER_NEAR_CLIP != 0
.if ENGINE_WIRE_CAMERA_THROUGH_MESH_ENABLE != 0
.else
.endif
.else
.endif
etpv_store_project = hp_unreachable
.if WIRE_FACE_EDGE_ENABLE != 0 && HIDDEN_WIRE_ENABLE = 0 && POLY_FILL_ENABLE = 0
etpv_wire_check_screen = hp_unreachable
etpv_wire_unsafe = hp_unreachable
.endif
etpv_mark_valid = hp_unreachable
etpv_next = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.endif
etpv_done = hp_unreachable
.endif

; Q8-only: old integer polygon clip retired.
rotate_project_vertices = hp_unreachable
rp_loop = hp_unreachable
.if WORLD_GROUND_OCCLUDE != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if SCENE_OBJECT_COUNT != 0
.if SCENE_OBJECT_X_ACTIVE != 0
.endif
.if SCENE_OBJECT_Y_ACTIVE != 0
.endif
.endif
.if CAMERA_HAS_POS != 0
.endif
.if CAMERA_HAS_ROT != 0
.endif
rp_depth_signed_ready = hp_unreachable
.if SCENE_OBJECT_COUNT != 0
.endif
.if WORLD_GROUND_PLANE_CLIP != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
rp_raw_x_positive = hp_unreachable
rp_raw_x_ready = hp_unreachable
rp_raw_y_positive = hp_unreachable
rp_raw_y_ready = hp_unreachable
.endif
rp_depth_hi_ready = hp_unreachable
.if SCENE_OBJECT_COUNT != 0
.else
.endif
rp_no_frac_round = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.endif

.if POLY_FILL_ENABLE != 0
draw_mesh:
 jsr begin_depth_buckets
 jsr collect_active_mesh_faces
 jsr draw_depth_buckets
 rts
.endif

.if WIRE_RENDER_ENABLE != 0
project_wire_vertices:
.if STANDARD_PROJECT_VERTEX != 0
 lda active_vfirst
 sta sorti
pwv_loop:
 ldx sorti
 jsr project_vertex
 inc sorti
 lda sorti
 cmp active_vend
 bne pwv_loop
.endif
 rts

.if MODE2_FACE_BUCKET_PIPELINE = 0
draw_wire_active_mesh:
.if HIDDEN_WIRE_ENABLE != 0
.if WIRE_MESH_COUNT != 0
 ldx meshidx
 lda mesh_is_wire,x
 beq dwam_hidden_poly
.if WIRE_FACE_EDGE_ENABLE != 0
 lda mesh_face_first,x
 cmp mesh_face_end,x
 beq dwam_hidden_wire_edges
 jmp draw_visible_wire_mesh
dwam_hidden_wire_edges:
.endif
 jmp draw_wire_mesh
dwam_hidden_poly:
.endif
.if WIRE_FACE_EDGE_ENABLE != 0
 jmp draw_visible_wire_mesh
.else
 rts
.endif
.else
.if ENGINE_MODE1_FACE_PASS_STRIPPED != 0 && WIRE_EDGE_COUNT != 0
 jmp draw_wire_mesh
.else
.if FACE_RENDER_ENABLE != 0
.if WIRE_MESH_COUNT != 0
 ldx meshidx
 lda mesh_is_wire,x
 bne dwam_explicit_wire
 jmp draw_wire_poly_mesh_mode1
dwam_explicit_wire:
.else
 jmp draw_wire_poly_mesh_mode1
.endif
.endif
.if WIRE_MESH_COUNT != 0
 jmp draw_wire_mesh
.endif
.endif
.endif

.if HIDDEN_WIRE_ENABLE = 0 && FACE_RENDER_ENABLE != 0
draw_wire_poly_mesh_mode1:
.if WIRE_FACE_EDGE_ENABLE != 0
.if FACE_SOLID_COLOR_ENABLE != 0
 jmp draw_wire_faces_mesh
.endif
.if CAMERA_MOVABLE != 0
 lda wire_mesh_safe_flag
 beq dwpm1_fallback
 jmp draw_wire_mesh
.else
 jsr wire_mesh_fast_safe
 bcc dwpm1_fallback
 jmp draw_wire_mesh
.endif
dwpm1_fallback:
.endif
 jmp draw_wire_faces_mesh

.if WIRE_FACE_EDGE_ENABLE != 0
.if CAMERA_MOVABLE = 0
wire_mesh_fast_safe:
 lda active_vfirst
 sta tmpidx
wmfs_loop:
 lda tmpidx
 cmp active_vend
 beq wmfs_yes
 tax
.if SCENE_OBJECT_COUNT != 0
 jsr vertex_depth_safe
 beq wmfs_no
 ldx tmpidx
.endif
 lda sx,x
 beq wmfs_no
 cmp #PROJ_SCREEN_MAX_X
 bcs wmfs_no
 lda sy,x
 beq wmfs_no
 cmp #PROJ_SCREEN_MAX_Y
 bcs wmfs_no
 inc tmpidx
 jmp wmfs_loop
wmfs_yes:
 sec
 rts
wmfs_no:
 clc
 rts
.endif
.endif
.endif

.if WIRE_EDGE_COUNT != 0
draw_wire_mesh:
.if WIRE_TWO_COLOR_MODE1_ENABLE != 0
 jsr activate_wire_two_color_palette
.else
 lda #$aa
 sta fillbyte
.endif
 ldx meshidx
 lda mesh_edge_end,x
 sta sortj
 lda mesh_edge_first,x
 sta faceidx
dwm_loop:
 lda faceidx
 cmp sortj
 beq dwm_done
 tay
 lda edge0,y
 sta clip_prev_idx
 tax
.if SCENE_OBJECT_COUNT != 0
.if ENGINE_MODE1_UNIVERSAL_EDGE_TRAVERSAL != 0
 ; projdone is finalized during engine movable-camera projection and already reflects
 ; valid depth or the camera-through-mesh near-clamp decision for any mesh vertex.
 lda projdone,x
 beq dwm_next
.else
 jsr wire_vertex_drawable
 beq dwm_next
.endif
.endif
 ldy faceidx
 lda edge1,y
 sta clip_cur_idx
 tax
.if SCENE_OBJECT_COUNT != 0
.if ENGINE_MODE1_UNIVERSAL_EDGE_TRAVERSAL != 0
 lda projdone,x
 beq dwm_next
.else
 jsr wire_vertex_drawable
 beq dwm_next
.endif
.endif
.if WORLD_GROUND_OCCLUDE != 0 && HIDDEN_WIRE_ENABLE != 0 && POLY_FILL_ENABLE = 0
 jsr ground_wire_edge_visible
 beq dwm_next
.endif
.if WIRE_TWO_COLOR_MODE1_ENABLE != 0
 ldy faceidx
 jsr load_wire_two_color_edge_pattern_y
.endif
.if ENGINE_MODE1_WIRE_FAST_PLOT != 0 && EXPLORER_SCREEN_CLIP_POLY != 0 && EXPLORER_SCREEN_RAW != 0
 ; Fast path: both raw endpoints are already inside the 160x100 viewport.
 ; This avoids the generic polygon clipper and the redundant guarded draw.
 ldx clip_prev_idx
 lda pxrawhi,x
 bne dwm_clip_fallback
 lda pxrawlo,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dwm_clip_fallback
 lda pyrawhi,x
 bne dwm_clip_fallback
 lda pyrawlo,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dwm_clip_fallback
 ldx clip_cur_idx
 lda pxrawhi,x
 bne dwm_clip_fallback
 lda pxrawlo,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dwm_clip_fallback
 lda pyrawhi,x
 bne dwm_clip_fallback
 lda pyrawlo,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dwm_clip_fallback
 ldx clip_prev_idx
 lda pxrawlo,x
 sta ex0
 lda pyrawlo,x
 sta ey0
 ldx clip_cur_idx
 lda pxrawlo,x
 sta ex1
 lda pyrawlo,x
 sta ey1
 jsr draw_wire_edge
 jmp dwm_next

dwm_clip_fallback:
 jsr clip_wire_edge_screen
 beq dwm_next
 jsr draw_wire_edge_guarded
 jmp dwm_next
.else
.if EXPLORER_SCREEN_CLIP_POLY != 0 && EXPLORER_SCREEN_RAW != 0
 jsr clip_wire_edge_screen
 beq dwm_next
.else
 ldx clip_prev_idx
 lda sx,x
 sta ex0
 lda sy,x
 sta ey0
 lda ex0
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dwm_next
 lda ey0
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dwm_next
 ldx clip_cur_idx
 lda sx,x
 sta ex1
 lda sy,x
 sta ey1
 lda ex1
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dwm_next
 lda ey1
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dwm_next
.endif
 jsr draw_wire_edge_guarded
.endif
dwm_next:
 inc faceidx
 jmp dwm_loop
dwm_done:
 rts
.endif
.endif

.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0
.if MODE2_FACE_BUCKET_PIPELINE = 0
draw_visible_wire_mesh:
 lda #$aa
 sta fillbyte
.if CAMERA_MOVABLE != 0
 jsr prepare_hidden_wire_context
.endif
.if WORLD_GROUND_WIRE_OCCLUDE != 0
 jsr draw_visible_wire_mesh_ground_mask
.if WIRE_OBJECT_MATERIAL_ENABLE != 0
 jsr restore_active_object_wire_material
.endif
.endif
.if WORLD_GROUND_HORIZON_BBOX_OCCLUDE != 0
.if CAMERA_ROLL_ACTIVE != 0
 lda explorer_cam_roll
 bne dvwm_skip_ground_erase
.endif
 lda material_screen_cur
 sta world_ground_saved_screen
 lda material_color_cur
 sta world_ground_saved_color
 jsr draw_visible_wire_mesh_ground_erase
 lda world_ground_saved_screen
 sta material_screen_cur
 lda world_ground_saved_color
 sta material_color_cur
 lda #$aa
 sta fillbyte
dvwm_skip_ground_erase:
.endif
 jsr clear_wire_edge_marks
 lda active_face_first
 sta faceidx
dvwm_loop:
 lda faceidx
 cmp active_face_end
 beq dvwm_done
 lda faceidx
 sta sortj
.if FORCE_FACE_RENDER = 0
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda #$00
 sta clip_poly_active
.endif
 jsr hidden_face_visible_camera
 bcc dvwm_next
.endif
 ldy faceidx
 jsr load_face_y
 bcc dvwm_next
 jsr loaded_wire_face_visible
 bcc dvwm_next
 jsr draw_loaded_wire_face_unique
dvwm_next:
 inc faceidx
 jmp dvwm_loop
dvwm_done:
 rts

.if WORLD_GROUND_WIRE_OCCLUDE != 0
draw_visible_wire_mesh_ground_mask:
 lda world_ground_horizon_valid
 beq wgmb_rts
.if WIRE_MESH_COUNT != 0
 ldx meshidx
 lda mesh_is_wire,x
 bne wgmb_rts
.endif
 lda active_face_first
 sta faceidx
wgmb_loop:
 lda faceidx
 cmp active_face_end
 beq wgmb_rts
 lda faceidx
 sta sortj
.if FORCE_FACE_RENDER = 0
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda #$00
 sta clip_poly_active
.endif
 jsr hidden_face_visible_camera
 bcc wgmb_next
.endif
 ldy faceidx
 jsr load_face_y
 bcc wgmb_next
 jsr loaded_wire_face_visible
 bcc wgmb_next
 jsr world_ground_clear_loaded_face
wgmb_next:
 inc faceidx
 jmp wgmb_loop
wgmb_rts:
 rts

world_ground_clear_loaded_face:
.if ENGINE_MODE2_HORIZON_ROW_MASK_RUNTIME_ACTIVE != 0
 lda #$00
 sta wire_trace_active
 jsr setup_face_y_bounds
 lda world_ground_hy0
 cmp face_ymin
 bcc wgclf_hr_done
 cmp face_ymax
 bcc wgclf_hr_visible
 beq wgclf_hr_visible
 rts
wgclf_hr_visible:
 sta yrow
 tax
 lda #$ff
 sta leftb,x
 lda #$00
 sta rightb,x
 lda vx0
 sta ex0
 lda vy0
 sta ey0
 lda vx1
 sta ex1
 lda vy1
 sta ey1
 jsr trace_edge_convex
 lda vx1
 sta ex0
 lda vy1
 sta ey0
 lda vx2
 sta ex1
 lda vy2
 sta ey1
 jsr trace_edge_convex
 lda vx2
 sta ex0
 lda vy2
 sta ey0
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne wgclf_hr_trace_2_to_0
.endif
 lda vx3
 sta ex1
 lda vy3
 sta ey1
 jsr trace_edge_convex
 lda vx3
 sta ex0
 lda vy3
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
 jmp wgclf_hr_clear
.if HAS_TRI_FACES != 0
wgclf_hr_trace_2_to_0:
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
.endif
wgclf_hr_clear:
 ldx yrow
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc wgclf_hr_done
 jsr world_ground_clear_mask_row_span
wgclf_hr_done:
 rts
.else
 lda #$00
 sta wire_trace_active
 jsr setup_face_y_bounds
 ldx face_ymin
 lda #$ff
wgclf_init_loop:
 sta leftb,x
 lda #$00
 sta rightb,x
 lda #$ff
 cpx face_ymax
 beq wgclf_init_done
 inx
 jmp wgclf_init_loop
wgclf_init_done:
 lda vx0
 sta ex0
 lda vy0
 sta ey0
 lda vx1
 sta ex1
 lda vy1
 sta ey1
 jsr trace_edge_convex
 lda vx1
 sta ex0
 lda vy1
 sta ey0
 lda vx2
 sta ex1
 lda vy2
 sta ey1
 jsr trace_edge_convex
 lda vx2
 sta ex0
 lda vy2
 sta ey0
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne wgclf_trace_2_to_0
.endif
 lda vx3
 sta ex1
 lda vy3
 sta ey1
 jsr trace_edge_convex
 lda vx3
 sta ex0
 lda vy3
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
 jmp wgclf_rows
.if HAS_TRI_FACES != 0
wgclf_trace_2_to_0:
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
.endif
wgclf_rows:
 ldx face_ymin
wgclf_row:
 stx yrow
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc wgclf_next_row
 jsr world_ground_clear_mask_row_span
wgclf_next_row:
 ldx yrow
 cpx face_ymax
 beq wgclf_done
 inx
 jmp wgclf_row
wgclf_done:
 rts
.endif

.endif

.if WORLD_GROUND_HORIZON_BBOX_OCCLUDE != 0
draw_visible_wire_mesh_ground_erase:
 lda #$00
 sta fillbyte
 sta material_screen_cur
 sta material_color_cur
 lda active_face_first
 sta faceidx
dvwmge_loop:
 lda faceidx
 cmp active_face_end
 beq dvwmge_done
 lda faceidx
 sta sortj
.if FORCE_FACE_RENDER = 0
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda #$00
 sta clip_poly_active
.endif
 jsr hidden_face_visible_camera
 bcc dvwmge_next
.endif
 ldy faceidx
 jsr load_face_y
 bcc dvwmge_next
 jsr loaded_wire_face_visible
 bcc dvwmge_next
 jsr world_ground_erase_loaded_face_bbox
 jmp dvwmge_next

world_ground_erase_loaded_face_bbox:
 lda vx0
 sta leftval
 sta rightval
 lda vy0
 sta face_ymin
 sta face_ymax
 lda vx1
 jsr wg_bbox_add_x
 lda vy1
 jsr wg_bbox_add_y
 lda vx2
 jsr wg_bbox_add_x
 lda vy2
 jsr wg_bbox_add_y
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne wg_bbox_ready
.endif
 lda vx3
 jsr wg_bbox_add_x
 lda vy3
 jsr wg_bbox_add_y
wg_bbox_ready:
 lda face_ymin
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs wg_bbox_done
 lda leftval
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs wg_bbox_done
 lda face_ymax
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcc wg_bbox_ymax_ok
 lda #PROJ_SCREEN_MAX_Y
 sta face_ymax
wg_bbox_ymax_ok:
 lda rightval
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcc wg_bbox_xmax_ok
 lda #PROJ_SCREEN_MAX_X
 sta rightval
wg_bbox_xmax_ok:
 clc
 lda leftval
 adc #$08
 sta leftval
 cmp rightval
 bcs wg_bbox_done
 sec
 lda rightval
 sbc #$08
 sta rightval
 cmp leftval
 bcc wg_bbox_done
 clc
 lda face_ymin
 adc #$06
 sta face_ymin
 cmp face_ymax
 bcs wg_bbox_done
 sec
 lda face_ymax
 sbc #$06
 sta face_ymax
 cmp face_ymin
 bcc wg_bbox_done
 ldx face_ymin
dvwmge_row:
 stx yrow
 jsr world_ground_erase_row_span
dvwmge_row_next:
 ldx yrow
 cpx face_ymax
 beq wg_bbox_done
 inx
 jmp dvwmge_row
wg_bbox_done:
 rts

wg_bbox_add_x:
 cmp leftval
 bcs wg_bbox_x_min_ok
 sta leftval
wg_bbox_x_min_ok:
 cmp rightval
 bcc wg_bbox_x_done
 sta rightval
wg_bbox_x_done:
 rts

wg_bbox_add_y:
 cmp face_ymin
 bcs wg_bbox_y_min_ok
 sta face_ymin
wg_bbox_y_min_ok:
 cmp face_ymax
 bcc wg_bbox_y_done
 sta face_ymax
wg_bbox_y_done:
 rts
dvwmge_next:
 inc faceidx
 jmp dvwmge_loop
dvwmge_done:
 rts

world_ground_erase_row_span:
 lda drawbuf
 bne wgers_b
 ldx yrow
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jmp wgers_rows_ready
wgers_b:
 ldx yrow
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
wgers_rows_ready:
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldy #$00
 lda startbyte
 cmp endbyte
 bne wgers_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 sta (ptr1lo),y
 rts
wgers_multi:
 ldx leftval
 lda startmask,x
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 sta fullcount
wgers_next_byte:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgers_ptr0_ok
 inc ptr0hi
wgers_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgers_ptr1_ok
 inc ptr1hi
wgers_ptr1_ok:
 dec fullcount
 beq wgers_end_byte
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp wgers_next_byte
wgers_end_byte:
 ldx rightval
 lda endmask,x
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 sta (ptr1lo),y
 rts
.endif

.if CAMERA_MOVABLE != 0
prepare_hidden_wire_context:
 lda explorer_cam_x_hi
 ldx explorer_cam_x_ext
 jsr hidden_saturate_i16_to_i8
 sta hidden_cam_x8
 lda explorer_cam_y_hi
 ldx explorer_cam_y_ext
 jsr hidden_saturate_i16_to_i8
 sta hidden_cam_y8
 lda explorer_cam_z_hi
 ldx explorer_cam_z_ext
 jsr hidden_saturate_i16_to_i8
 sta hidden_cam_z8
.if SCENE_OBJECT_COUNT != 0
 lda obj_depth_lo
 ldx obj_depth_hi
 jsr hidden_saturate_i16_to_i8
 sta hidden_obj_z8
.endif
 rts
.endif
.endif
.endif

.if MODE2_FACE_BUCKET_PIPELINE != 0
; Imported unchanged from rc2-dev5 Mode 2 winding validation: signed 24-bit
; shoelace area over the exact projected polygon selected by load_face_y.
mode2_screen_winding_visible:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq m2swc_normal_count
 lda clip_a_count
 jmp m2swc_count_ready
m2swc_normal_count:
.endif
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
.else
 lda #$04
.endif
m2swc_count_ready:
 cmp #$03
 bcc m2swc_hidden
 sta fullcount
 lda #$00
 sta dotlo
 sta dothi
 sta crosslo
 sta sorti
m2swc_loop:
 lda sorti
 clc
 adc #$01
 cmp fullcount
 bcc m2swc_next_ready
 lda #$00
m2swc_next_ready:
 sta sortj

 ; xi * y(i+1)
 ldx sorti
 jsr mode2_screen_winding_get_x_half
 sta t1
 ldx sortj
 jsr mode2_screen_winding_get_y
 tax
 lda t1
 jsr mul_s8_16
 clc
 lda dotlo
 adc prodlo
 sta dotlo
 lda dothi
 adc prodhi
 sta dothi
 lda crosslo
 adc #$00
 sta crosslo

 ; x(i+1) * yi
 ldx sortj
 jsr mode2_screen_winding_get_x_half
 sta t1
 ldx sorti
 jsr mode2_screen_winding_get_y
 tax
 lda t1
 jsr mul_s8_16
 sec
 lda dotlo
 sbc prodlo
 sta dotlo
 lda dothi
 sbc prodhi
 sta dothi
 lda crosslo
 sbc #$00
 sta crosslo

 inc sorti
 lda sorti
 cmp fullcount
 bne m2swc_loop
 lda crosslo
 bmi m2swc_hidden
 bne m2swc_visible
 lda dothi
 bne m2swc_visible
 lda dotlo
 cmp #$01
 bcc m2swc_hidden
m2swc_visible:
 sec
 rts
m2swc_hidden:
 clc
 rts

mode2_screen_winding_get_x_half:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq m2swc_x_normal
 lda clip_a_x,x
 lsr
 rts
m2swc_x_normal:
.endif
 cpx #$00
 bne m2swc_x1
 lda vx0
 lsr
 rts
m2swc_x1:
 cpx #$01
 bne m2swc_x2
 lda vx1
 lsr
 rts
m2swc_x2:
 cpx #$02
 bne m2swc_x3
 lda vx2
 lsr
 rts
m2swc_x3:
 lda vx3
 lsr
 rts

mode2_screen_winding_get_y:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq m2swc_y_normal
 lda clip_a_y,x
 rts
m2swc_y_normal:
.endif
 cpx #$00
 bne m2swc_y1
 lda vy0
 rts
m2swc_y1:
 cpx #$01
 bne m2swc_y2
 lda vy1
 rts
m2swc_y2:
 cpx #$02
 bne m2swc_y3
 lda vy2
 rts
m2swc_y3:
 lda vy3
 rts
.endif

.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE != 0
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
* = $4000
.endif
.if MODE2_FACE_BUCKET_PIPELINE = 0
loaded_wire_face_visible:
.if FORCE_FACE_RENDER = 0
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq lwfv_after_clip
 jsr hidden_face_visible_camera
 bcc lwfv_hidden
.endif
.endif
lwfv_after_clip:
.if WORLD_GROUND_OCCLUDE != 0
 jsr ground_face_visible
 beq lwfv_hidden
.endif
lwfv_visible:
 sec
 rts
lwfv_hidden:
 clc
 rts

hidden_face_visible_camera:
 ldy faceidx
 sty tmpidx
 jsr hidden_rotate_face_normal
 lda #$00
 sta dotlo
 sta dothi
.if CAMERA_MOVABLE != 0
 ldx hidden_cam_x8
.else
 ldx #CAMERA_POS_X
.endif
 lda sh_nx
 jsr mul_s8_16
 jsr hidden_add_dot_product
.if CAMERA_MOVABLE != 0
 ldx hidden_cam_y8
.else
 ldx #CAMERA_POS_Y
.endif
 lda sh_ny
 jsr mul_s8_16
 jsr hidden_add_dot_product
.if CAMERA_MOVABLE != 0
 ldx hidden_cam_z8
.else
 ldx #CAMERA_POS_Z
.endif
 lda sh_nz
 jsr mul_s8_16
 jsr hidden_add_dot_product
 jsr hidden_subtract_face_center_dot
.if SCENE_OBJECT_COUNT != 0
 jsr hidden_subtract_object_position_dot
.endif
 lda dothi
 bmi hfvc_hidden
 bne hfvc_visible
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq hfvc_normal_threshold
 lda dotlo
 cmp #$10
 bcc hfvc_hidden
 jmp hfvc_visible
hfvc_normal_threshold:
.endif
 lda dotlo
 cmp #$01
 bcc hfvc_hidden
hfvc_visible:
 sec
 rts
hfvc_hidden:
 clc
 rts

hidden_rotate_face_normal:
 ldy tmpidx
 lda face_normal_x,y
 ldx m00
 jsr mul_s6
 sta sh_nx
 lda face_normal_y,y
 ldx m01
 jsr mul_s6
 clc
 adc sh_nx
 sta sh_nx
 lda face_normal_z,y
 ldx m02
 jsr mul_s6
 clc
 adc sh_nx
 sta sh_nx
 lda face_normal_x,y
 ldx m10
 jsr mul_s6
 sta sh_ny
 lda face_normal_y,y
 ldx m11
 jsr mul_s6
 clc
 adc sh_ny
 sta sh_ny
 lda face_normal_z,y
 ldx m12
 jsr mul_s6
 clc
 adc sh_ny
 sta sh_ny
 lda face_normal_x,y
 ldx m20
 jsr mul_s6
 sta sh_nz
 lda face_normal_y,y
 ldx m21
 jsr mul_s6
 clc
 adc sh_nz
 sta sh_nz
 lda face_normal_z,y
 ldx m22
 jsr mul_s6
 clc
 adc sh_nz
 sta sh_nz
 rts

hidden_saturate_i16_to_i8:
 sta p1lo
 txa
 beq hs16_pos_ext
 cmp #$ff
 beq hs16_neg_ext
 bmi hs16_neg_sat
 lda #$7f
 rts
hs16_pos_ext:
 lda p1lo
 bmi hs16_pos_sat
 rts
hs16_pos_sat:
 lda #$7f
 rts
hs16_neg_ext:
 lda p1lo
 bmi hs16_in_range
hs16_neg_sat:
 lda #$80
 rts
hs16_in_range:
 lda p1lo
 rts

hidden_subtract_face_center_dot:
 ldy tmpidx
 sec
 lda dotlo
 sbc face_center_dot_lo,y
 sta dotlo
 lda dothi
 sbc face_center_dot_hi,y
 sta dothi
 rts

.if SCENE_OBJECT_COUNT != 0
hidden_subtract_object_position_dot:
.if SCENE_OBJECT_X_ACTIVE != 0
 ldx obj_pos_x_cur
 lda sh_nx
 jsr mul_s8_16
 jsr hidden_subtract_dot_product
.endif
.if SCENE_OBJECT_Y_ACTIVE != 0
 ldx obj_pos_y_cur
 lda sh_ny
 jsr mul_s8_16
 jsr hidden_subtract_dot_product
.endif
.if CAMERA_MOVABLE != 0
 ldx hidden_obj_z8
.else
 lda obj_depth_lo
 ldx obj_depth_hi
 jsr hidden_saturate_i16_to_i8
 tax
.endif
 lda sh_nz
 jsr mul_s8_16
 jsr hidden_subtract_dot_product
 rts
.endif

hidden_add_dot_product:
 clc
 lda dotlo
 adc prodlo
 sta dotlo
 lda dothi
 adc prodhi
 sta dothi
 rts

hidden_subtract_dot_product:
 sec
 lda dotlo
 sbc prodlo
 sta dotlo
 lda dothi
 sbc prodhi
 sta dothi
 rts

.endif
.endif

.if WIRE_FACE_EDGE_ENABLE != 0 && MODE2_FACE_BUCKET_PIPELINE = 0
clear_wire_edge_marks:
 inc wire_edge_stamp
 bne cwem_done
 jsr clear_all_wire_edge_marks
 inc wire_edge_stamp
cwem_done:
 rts

clear_all_wire_edge_marks:
 ldx #$00
 lda #$00
cawem_loop:
 cpx #WIRE_EDGE_COUNT
 beq cawem_done
 sta edge_drawn,x
 inx
 jmp cawem_loop
cawem_done:
 rts

draw_loaded_wire_face_unique:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlwfu_normal
 jmp draw_loaded_wire_face
dlwfu_normal:
.endif
 ldy faceidx
 lda face_edge0,y
 jsr mark_wire_edge_drawn
 bcc dlwfu_edge1
 lda vx0
 sta ex0
 lda vy0
 sta ey0
 lda vx1
 sta ex1
 lda vy1
 sta ey1
.if ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW != 0 && EXPLORER_SCREEN_CLIP_POLY != 0
 jsr draw_wire_edge
.else
 jsr draw_wire_edge_guarded
.endif
dlwfu_edge1:
 ldy faceidx
 lda face_edge1,y
 jsr mark_wire_edge_drawn
 bcc dlwfu_edge2
 lda vx1
 sta ex0
 lda vy1
 sta ey0
 lda vx2
 sta ex1
 lda vy2
 sta ey1
.if ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW != 0 && EXPLORER_SCREEN_CLIP_POLY != 0
 jsr draw_wire_edge
.else
 jsr draw_wire_edge_guarded
.endif
dlwfu_edge2:
 ldy faceidx
 lda face_edge2,y
 jsr mark_wire_edge_drawn
 bcc dlwfu_edge3
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 beq dlwfu_edge2_quad
 lda vx2
 sta ex0
 lda vy2
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
.if ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW != 0 && EXPLORER_SCREEN_CLIP_POLY != 0
 jsr draw_wire_edge
.else
 jsr draw_wire_edge_guarded
.endif
 rts
dlwfu_edge2_quad:
.endif
 lda vx2
 sta ex0
 lda vy2
 sta ey0
 lda vx3
 sta ex1
 lda vy3
 sta ey1
.if ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW != 0 && EXPLORER_SCREEN_CLIP_POLY != 0
 jsr draw_wire_edge
.else
 jsr draw_wire_edge_guarded
.endif
dlwfu_edge3:
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne dlwfu_done
.endif
 ldy faceidx
 lda face_edge3,y
 jsr mark_wire_edge_drawn
 bcc dlwfu_done
 lda vx3
 sta ex0
 lda vy3
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
.if ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW != 0 && EXPLORER_SCREEN_CLIP_POLY != 0
 jsr draw_wire_edge
.else
 jsr draw_wire_edge_guarded
.endif
dlwfu_done:
 rts

mark_wire_edge_drawn:
 tax
 lda edge_drawn,x
 cmp wire_edge_stamp
 beq mwed_skip
 lda wire_edge_stamp
 sta edge_drawn,x
.if WIRE_EDGE_SOLID_COLOR_ENABLE != 0
 jsr load_wire_edge_solid_color_x
.endif
 sec
 rts
mwed_skip:
 clc
 rts

.endif

.if FACE_RENDER_ENABLE != 0
.if MODE2_FACE_BUCKET_PIPELINE = 0
draw_wire_faces_mesh:
 lda #$aa
 sta fillbyte
.if WIRE_FACE_EDGE_ENABLE != 0
 jsr clear_wire_edge_marks
.endif
 lda active_face_first
 sta faceidx
dwfm_loop:
 lda faceidx
 cmp active_face_end
 beq dwfm_done
 sta sortj
 tay
 jsr load_face_y
 bcc dwfm_next
.if FACE_SOLID_COLOR_ENABLE != 0
 ldy sortj
 jsr load_face_solid_color_y
.endif
.if WIRE_FACE_EDGE_ENABLE != 0
 jsr draw_loaded_wire_face_unique
.else
 jsr draw_loaded_wire_face
.endif
dwfm_next:
 inc faceidx
 jmp dwfm_loop
dwfm_done:
 rts
.endif

draw_loaded_wire_face:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlwf_normal
 jmp draw_clip_wire_poly
dlwf_normal:
.endif
 lda vx0
 sta ex0
 lda vy0
 sta ey0
 lda vx1
 sta ex1
 lda vy1
 sta ey1
 jsr draw_wire_edge_guarded
 lda vx1
 sta ex0
 lda vy1
 sta ey0
 lda vx2
 sta ex1
 lda vy2
 sta ey1
 jsr draw_wire_edge_guarded
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 beq dlwf_quad
 lda vx2
 sta ex0
 lda vy2
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr draw_wire_edge_guarded
 rts
dlwf_quad:
.endif
 lda vx2
 sta ex0
 lda vy2
 sta ey0
 lda vx3
 sta ex1
 lda vy3
 sta ey1
 jsr draw_wire_edge_guarded
 lda vx3
 sta ex0
 lda vy3
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr draw_wire_edge_guarded
 rts

.if EXPLORER_SCREEN_CLIP_POLY != 0
draw_clip_wire_poly:
 lda clip_a_count
 cmp #$02
 bcc dcwp_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
dcwp_loop:
 ldx clip_prev_idx
 lda clip_a_x,x
 sta ex0
 lda clip_a_y,x
 sta ey0
 ldx clip_cur_idx
 lda clip_a_x,x
 sta ex1
 lda clip_a_y,x
 sta ey1
 jsr draw_clip_wire_edge_guarded
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne dcwp_loop
dcwp_done:
 rts

draw_clip_wire_edge_guarded:
 jsr clip_wire_edge_is_generated_cap
 bcs dcweg_skip
 jsr clip_wire_edge_is_screen_border
 bcs dcweg_skip
 jsr draw_wire_edge_guarded
dcweg_skip:
 rts

clip_wire_edge_is_generated_cap:
 ldx clip_prev_idx
 lda clip_a_flag,x
 beq cwigc_draw
 ldx clip_cur_idx
 lda clip_a_flag,x
 beq cwigc_draw
 sec
 rts
cwigc_draw:
 clc
 rts

clip_wire_edge_is_screen_border:
 lda ex0
 bne cwe_not_left
 lda ex1
 bne cwe_not_left
 sec
 rts
cwe_not_left:
 lda ex0
 cmp #PROJ_SCREEN_MAX_X
 bne cwe_not_right
 lda ex1
 cmp #PROJ_SCREEN_MAX_X
 bne cwe_not_right
 sec
 rts
cwe_not_right:
 lda ey0
 bne cwe_not_top
 lda ey1
 bne cwe_not_top
 sec
 rts
cwe_not_top:
 lda ey0
 cmp #PROJ_SCREEN_MAX_Y
 bne cwe_draw
 lda ey1
 cmp #PROJ_SCREEN_MAX_Y
 bne cwe_draw
 sec
 rts
cwe_draw:
 clc
 rts
.endif

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
* = $4000
.if CAMERA_MOVABLE != 0
.endif
.endif
draw_wire_edge_guarded:
 lda ex0
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dweg_skip
 lda ey0
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dweg_skip
 lda ex1
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dweg_skip
 lda ey1
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dweg_skip
 jmp draw_wire_edge
dweg_skip:
 rts
.endif

draw_wire_edge:
.if POLY_FILL_ENABLE = 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda #$01
 sta wire_trace_active
 jsr trace_edge_convex
 lda #$00
 sta wire_trace_active
 rts
.else
 jmp trace_edge_convex
.endif
.else
 lda #$01
 sta wire_trace_active
 jsr trace_edge_convex
 lda #$00
 sta wire_trace_active
 rts
.endif
.endif


.if WIRE_OVERLAY_ENABLE != 0 && SCENE_OBJECT_COUNT != 0
draw_wire_scene_objects:
 lda #$00
 sta objidx
dwso_loop:
.if SCENE_OBJECT_VISIBILITY_ACTIVE != 0
 ldx objidx
 lda object_visible,x
 beq dwso_next_object
.endif
 jsr set_active_object
 ldx meshidx
 lda mesh_is_wire,x
 beq dwso_next_object
.if EXPLORER_TRAVERSAL_CULL != 0
 lda object_traverse_active
 bne dwso_next_object
.endif
.if WORLD_GROUND_OCCLUDE != 0 && HIDDEN_WIRE_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WORLD_GROUND_WIRE_OCCLUDE = 0
 jsr ground_object_visible
 beq dwso_next_object
.endif
.if CAMERA_MOVABLE != 0
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_explorer_matrix_fold
.else
 jsr prepare_angles
 jsr explorer_prepare_view
.endif
 jsr explorer_transform_project_vertices
.else
 jsr prepare_angles
 jsr rotate_project_vertices
 jsr project_wire_vertices
.endif
 jsr draw_wire_active_mesh
dwso_next_object:
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bne dwso_loop
 rts
.endif

.if HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0 && POLY_FILL_ENABLE = 0 && SCENE_OBJECT_COUNT != 0
draw_hidden_poly_scene_objects:
 lda #$00
 sta objidx
dhpso_loop:
.if SCENE_OBJECT_VISIBILITY_ACTIVE != 0
 ldx objidx
 lda object_visible,x
 beq dhpso_next_object
.endif
 jsr set_active_object
.if WIRE_MESH_COUNT != 0
 ldx meshidx
 lda mesh_is_wire,x
 bne dhpso_next_object
.endif
.if EXPLORER_TRAVERSAL_CULL != 0
 lda object_traverse_active
 bne dhpso_next_object
.endif
.if WORLD_GROUND_OCCLUDE != 0 && HIDDEN_WIRE_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WORLD_GROUND_WIRE_OCCLUDE = 0
 jsr ground_object_visible
 beq dhpso_next_object
.endif
.if CAMERA_MOVABLE != 0
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_explorer_matrix_fold
.else
 jsr prepare_angles
 jsr explorer_prepare_view
.endif
 jsr explorer_transform_project_vertices
.else
 jsr prepare_angles
 jsr rotate_project_vertices
 jsr project_wire_vertices
.endif
 jsr draw_wire_active_mesh
dhpso_next_object:
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bne dhpso_loop
 rts
.if WIRE_MESH_COUNT != 0
draw_front_wire_depth_entries:
 lda hidden_solid_near_bucket
 beq dfwde_done
 cmp #$ff
 beq dfwde_done
 tax
dfwde_bucket_loop:
 dex
 stx sorti
 lda wire_bucket_head,x
 cmp #$ff
 beq dfwde_next_bucket
 sta wire_entry_cursor
dfwde_wire_loop:
 jsr draw_bucket_wire_object
 ldx wire_entry_cursor
 lda wire_next,x
 cmp #$ff
 beq dfwde_next_bucket
 sta wire_entry_cursor
 jmp dfwde_wire_loop
dfwde_next_bucket:
 ldx sorti
 cpx #$00
 bne dfwde_bucket_loop
dfwde_done:
 rts
.endif
.endif

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && ((POLY_FILL_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0) || (MODE2_FACE_BUCKET_PIPELINE != 0 && CAMERA_MOVABLE != 0))
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
* = $4000
.endif

.if POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0
begin_depth_buckets:
 jsr clear_depth_buckets
.if HIDDEN_WIRE_ENABLE != 0
 jsr clear_hidden_face_depths
.endif
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0
 jsr clear_wire_edge_marks
.endif
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WIRE_MESH_COUNT != 0
 lda #$ff
 sta hidden_solid_near_bucket
.endif
 lda #$ff
 sta bucket_min
 lda #$00
 sta bucket_max
 rts

collect_active_mesh_faces:
 lda objidx
 bne pc_collect_ready
 jsr pc_prepare
pc_collect_ready:
 lda active_face_first
 sta faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx objidx
 lda object_runtime_face_first,x
 sta shared_runtime_face
.endif
dm_collect_loop:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 jsr shared_prepare_face_vertices
.endif
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
 ldy faceidx
 lda #$00
 sta frame_face_prepare,y
.endif
 jsr pc_visible
 bcc dm_skip
 jsr load_face_visible
dm_skip:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 inc shared_runtime_face
.endif
 inc faceidx
 lda faceidx
 cmp active_face_end
 bne dm_collect_loop
 rts

.if MESH_SOURCE_SHARING_RUNTIME != 0
; Resolve the source-local topology once. All clipping, culling and raster
; consumers reuse these four runtime vertex ids for the current instance.
shared_source_face0 = face0
shared_source_face1 = face1
shared_source_face2 = face2
shared_source_face3 = face3
shared_prepare_face_vertices:
 ldy faceidx
 clc
 lda shared_source_face0,y
 adc shared_vertex_delta
 sta shared_fv0
 clc
 lda shared_source_face1,y
 adc shared_vertex_delta
 sta shared_fv1
 clc
 lda shared_source_face2,y
 adc shared_vertex_delta
 sta shared_fv2
 clc
 lda shared_source_face3,y
 adc shared_vertex_delta
 sta shared_fv3
 rts
.endif

clear_depth_buckets:
.if WIRE_DEPTH_SORT_ENABLE != 0
 lda #$00
 sta wire_depth_entry_used
.endif
 ldx bucket_used_count
 beq cdb_done
cdb_loop:
 dex
 lda bucket_used_list,x
 tay
 lda #$ff
 sta bucket_head,y
.if WIRE_DEPTH_SORT_ENABLE != 0
 sta wire_bucket_head,y
.endif
 cpx #$00
 bne cdb_loop
cdb_done:
 lda #$00
 sta bucket_used_count
 rts

.if HIDDEN_WIRE_ENABLE != 0
clear_hidden_face_depths:
 ldx #$00
chfd_loop:
 lda #$ff
 sta frame_face_shade,x
 inx
 cpx #FACE_COUNT
 bne chfd_loop
 rts
.endif

bucket_visible_face:
.if CAMERA_PLANE_CLIP_PROFILE != 0
 lda camera_plane_bucket_ready
 beq bvf_camera_plane_original
 lda camera_plane_bucket_depth
 sta p1lo
 jmp bvf_depth_ready
bvf_camera_plane_original:
.endif
; Mode 4 fixed uses the same full 16-bit depth reduction as walkLite/walkFull.
.if CAMERA_MOVABLE != 0 || GRAPHICS_MODE = $07 || GRAPHICS_MODE = $05 || GRAPHICS_MODE = $07
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 lda shared_fv0
.else
 lda face0,y
.endif
 tax
 lda sz,x
 sta p1lo
 lda szhi,x
 sta p1hi
.if MESH_SOURCE_SHARING_RUNTIME != 0
 lda shared_fv2
.else
 lda face2,y
.endif
 tax
 clc
 lda p1lo
 adc sz,x
 sta p1lo
 lda p1hi
 adc szhi,x
 sta p1hi
 bcc bvf_explorer_depth_sum_ok
 lda #$ff
 sta p1hi
 sta p1lo
bvf_explorer_depth_sum_ok:
 lsr p1hi
 ror p1lo
 ldx #$02
bvf_explorer_depth_shift:
 lsr p1hi
 ror p1lo
 dex
 bne bvf_explorer_depth_shift
 lda p1hi
 beq bvf_explorer_depth_ready
 lda #$fe
 sta p1lo
 jmp bvf_depth_ready
bvf_explorer_depth_ready:
 lda p1lo
 cmp #$ff
 bne bvf_depth_ready
 lda #$fe
 sta p1lo
.else
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 lda shared_fv0
.else
 lda face0,y
.endif
 tax
 lda szhi,x
 bne bvf_sat_depth
 lda sz,x
 sta p1lo
 lda #$00
 sta p1hi
.if MESH_SOURCE_SHARING_RUNTIME != 0
 lda shared_fv2
.else
 lda face2,y
.endif
 tax
 lda szhi,x
 bne bvf_sat_depth
 clc
 lda p1lo
 adc sz,x
 sta p1lo
 bcc bvf_engine_depth_sum_ok
 inc p1hi
bvf_engine_depth_sum_ok:
 lsr p1hi
 ror p1lo
 jmp bvf_depth_ready
bvf_sat_depth:
 lda #$fe
 sta p1lo
.endif
bvf_depth_ready:
 ; Draw connector after both shells, before near-room cubes.
 lda faceidx
 cmp #18
 bcc demo_regular_room_depth
 cmp #26
 bcs demo_regular_room_depth
 lda #75
 jmp demo_store_face_depth
demo_regular_room_depth:
 ; Y=24 is world forward, held in explorer_cam_z (Q8).
 lda explorer_cam_z_ext
 bmi demo_camera_room0
 lda explorer_cam_z_hi
 cmp #24
 bcc demo_camera_room0
 lda faceidx
 cmp #36
 bcc demo_far_room0
 cmp #54
 bcc demo_near_shell
 bcs demo_near_cube
demo_far_room0:
 cmp #26
 bcc demo_far_shell
 bcs demo_far_cube
demo_camera_room0:
 lda faceidx
 cmp #36
 bcs demo_far_room1
 cmp #26
 bcc demo_near_shell
 bcs demo_near_cube
demo_far_room1:
 cmp #54
 bcc demo_far_shell
demo_far_cube:
 lda #150
 bne demo_store_face_depth
demo_far_shell:
 lda #200
 bne demo_store_face_depth
demo_near_shell:
 lda #100
 bne demo_store_face_depth
demo_near_cube:
 lda #50
demo_store_face_depth:
 sta p1lo
.if MODE2_FACE_BUCKET_PIPELINE != 0
 ldy faceidx
 lda objidx
 sta face_object,y
.endif
.if HIDDEN_WIRE_ENABLE != 0
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy shared_runtime_face
.else
 ldy faceidx
.endif
 lda p1lo
 sta frame_face_shade,y
.endif
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WIRE_MESH_COUNT != 0
 ldy faceidx
 lda face_mesh_is_wire,y
 bne bvf_solid_near_done
 lda p1lo
 cmp hidden_solid_near_bucket
 bcs bvf_solid_near_done
 sta hidden_solid_near_bucket
bvf_solid_near_done:
.endif
 lda p1lo
 tax
 cmp bucket_min
 bcs bvf_min_ok
 sta bucket_min
bvf_min_ok:
 cmp bucket_max
 bcc bvf_max_ok
 sta bucket_max
bvf_max_ok:
 lda bucket_head,x
 cmp #$ff
 bne bvf_link_head
bvf_empty:
 txa
 ldy bucket_used_count
 sta bucket_used_list,y
 inc bucket_used_count
 lda #$ff
bvf_link_head:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy shared_runtime_face
.else
 ldy faceidx
.endif
 sta face_next,y
 tya
 sta bucket_head,x
 rts

.if WIRE_DEPTH_SORT_ENABLE != 0
bucket_visible_wire_object:
 ldx meshidx
 lda mesh_edge_end,x
 sta sortj
 lda mesh_edge_first,x
 sta faceidx
bvwe_loop:
 lda faceidx
 cmp sortj
 beq bvwe_done
 tay
 lda edge0,y
 sta clip_prev_idx
 tax
 jsr wire_vertex_drawable
 beq bvwe_next
 lda sz,x
 sta p1lo
 lda szhi,x
 sta p1hi
 ldy faceidx
 lda edge1,y
 sta clip_cur_idx
 tax
 jsr wire_vertex_drawable
 beq bvwe_next
.if WORLD_GROUND_OCCLUDE != 0 && POLY_FILL_ENABLE = 0
 jsr ground_wire_edge_visible
 beq bvwe_next
 ldx clip_cur_idx
.endif
 clc
 lda p1lo
 adc sz,x
 sta p1lo
 lda p1hi
 adc szhi,x
 sta p1hi
 bcc bvwe_depth_sum_ok
 lda #$ff
 sta p1hi
 sta p1lo
bvwe_depth_sum_ok:
.if CAMERA_MOVABLE != 0
 lsr p1hi
 ror p1lo
 lsr p1hi
 ror p1lo
 lsr p1hi
 ror p1lo
.else
 lsr p1hi
 ror p1lo
.endif
bvwe_depth_ready:
 lda p1hi
 beq bvwe_depth_low_ready
 lda #$fe
 jmp bvwe_store_depth
bvwe_depth_low_ready:
 lda p1lo
 cmp #$ff
 bne bvwe_store_depth
 lda #$fe
bvwe_store_depth:
.if WIRE_DEPTH_NEAR_BIAS != 0
 cmp #WIRE_DEPTH_NEAR_BIAS
 bcc bvwe_depth_biased
 sec
 sbc #WIRE_DEPTH_NEAR_BIAS
bvwe_depth_biased:
.endif
 sta tmpidx
.if EXPLORER_SCREEN_CLIP_POLY != 0 && EXPLORER_SCREEN_RAW != 0
 jsr clip_wire_edge_screen
 beq bvwe_next
.else
 ldx clip_prev_idx
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs bvwe_next
 sta ex0
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs bvwe_next
 sta ey0
 ldx clip_cur_idx
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs bvwe_next
 sta ex1
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs bvwe_next
 sta ey1
.endif
 lda wire_depth_entry_used
 cmp #WIRE_DEPTH_ENTRY_COUNT
 bcs bvwe_next
 lda tmpidx
 tax
 cmp bucket_min
 bcs bvwe_min_ok
 sta bucket_min
bvwe_min_ok:
 cmp bucket_max
 bcc bvwe_max_ok
 sta bucket_max
bvwe_max_ok:
 lda bucket_head,x
 cmp #$ff
 bne bvwe_link_entry
 lda wire_bucket_head,x
 cmp #$ff
 bne bvwe_link_entry
 txa
 ldy bucket_used_count
 sta bucket_used_list,y
 inc bucket_used_count
bvwe_link_entry:
 ldy wire_depth_entry_used
 lda objidx
 sta wire_entry_obj,y
 lda ex0
 sta wire_entry_x0,y
 lda ey0
 sta wire_entry_y0,y
 lda ex1
 sta wire_entry_x1,y
 lda ey1
 sta wire_entry_y1,y
 ldx tmpidx
 lda wire_bucket_head,x
 sta wire_next,y
 tya
 sta wire_bucket_head,x
 inc wire_depth_entry_used
bvwe_next:
 inc faceidx
 jmp bvwe_loop
bvwe_done:
 rts

draw_bucket_wire_object:
 ldx wire_entry_cursor
.if WIRE_OBJECT_MATERIAL_ENABLE != 0
 lda wire_entry_obj,x
 tax
 lda object_wire_screen,x
 sta material_screen_cur
 lda object_wire_color,x
 sta material_color_cur
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 ldx wire_entry_cursor
.endif
 lda #$aa
 sta fillbyte
 lda wire_entry_x0,x
 sta ex0
 lda wire_entry_y0,x
 sta ey0
 lda wire_entry_x1,x
 sta ex1
 lda wire_entry_y1,x
 sta ey1
 jmp draw_wire_edge_guarded
.endif

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE = 0
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
.if MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0
mode3_high_basic_low_segment_end = *
.endif
* = $4000
.if MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0
mode3_high_basic_middle_start = *
.endif
.endif

.if VIC_COLOR_POLICY_ENABLE != 0
vic_color_policy_reset_frame:
 lda #$00
 sta vic_color_cells_touched_lo
 sta vic_color_cells_touched_hi
 sta vic_color_conflict_count_lo
 sta vic_color_conflict_count_hi
 sta vic_color_fallback_count_lo
 sta vic_color_fallback_count_hi
 sta vic_color_fill_fallback_lo
 sta vic_color_fill_fallback_hi
 sta vic_color_wire_fallback_lo
 sta vic_color_wire_fallback_hi
 sta vic_color_max_colors_per_cell
 lda #$01
 sta vic_color_source
 ldx #$00
 lda #$ff
vcpf_clear_owner_pages:
 sta vic_color_owner_screen,x
 sta vic_color_owner_screen+$0100,x
 sta vic_color_owner_screen+$0200,x
 sta vic_color_owner_color,x
 sta vic_color_owner_color+$0100,x
 sta vic_color_owner_color+$0200,x
 inx
 bne vcpf_clear_owner_pages
 ldx #$00
 lda #$ff
vcpf_clear_owner_tail:
 sta vic_color_owner_screen+$0300,x
 sta vic_color_owner_color+$0300,x
 inx
 cpx #$e8
 bne vcpf_clear_owner_tail
.if VIC_COLOR_POLICY_OVERLAY != 0
 ldx #$00
 lda #$00
vcpf_clear_conflict_pages:
 sta vic_color_conflict_map,x
 sta vic_color_conflict_map+$0100,x
 sta vic_color_conflict_map+$0200,x
 inx
 bne vcpf_clear_conflict_pages
 ldx #$00
 lda #$00
vcpf_clear_conflict_tail:
 sta vic_color_conflict_map+$0300,x
 inx
 cpx #$e8
 bne vcpf_clear_conflict_tail
.endif
 rts

vic_color_policy_claim_cell:
 stx vic_color_saved_x
 tya
 pha
 ldx yrow
 txa
 lsr
 lsr
 tax
 lda vic_color_owner_screen_rowlo,x
 sta p1lo
 lda vic_color_owner_screen_rowhi,x
 sta p1hi
 lda vic_color_owner_color_rowlo,x
 sta shadeptrlo
 lda vic_color_owner_color_rowhi,x
 sta shadeptrhi
 ldx vic_color_saved_x
 txa
 tay
 lda (p1lo),y
 cmp #$ff
 beq vcpc_new_owner
 cmp material_screen_cur
 bne vcpc_conflict
 lda (shadeptrlo),y
 cmp material_color_cur
 bne vcpc_conflict
vcpc_allow:
 pla
 tay
 ldx vic_color_saved_x
 sec
 rts
vcpc_new_owner:
 lda material_screen_cur
 sta (p1lo),y
 lda material_color_cur
 sta (shadeptrlo),y
 inc vic_color_cells_touched_lo
 bne vcpc_new_max
 inc vic_color_cells_touched_hi
vcpc_new_max:
 lda vic_color_max_colors_per_cell
 bne vcpc_allow
 lda #$01
 sta vic_color_max_colors_per_cell
 jmp vcpc_allow
vcpc_conflict:
 inc vic_color_conflict_count_lo
 bne vcpc_conflict_max
 inc vic_color_conflict_count_hi
vcpc_conflict_max:
 lda #$02
 sta vic_color_max_colors_per_cell
.if VIC_COLOR_POLICY_OVERLAY != 0
 ldx yrow
 txa
 lsr
 lsr
 tax
 lda vic_color_conflict_rowlo,x
 sta p1lo
 lda vic_color_conflict_rowhi,x
 sta p1hi
 lda #$01
 sta (p1lo),y
.endif
.if VIC_COLOR_POLICY_ACTIVE != 0
 inc vic_color_fallback_count_lo
 bne vcpc_source_count
 inc vic_color_fallback_count_hi
vcpc_source_count:
 lda vic_color_source
 cmp #$02
 beq vcpc_wire_fallback
 inc vic_color_fill_fallback_lo
 bne vcpc_policy
 inc vic_color_fill_fallback_hi
 jmp vcpc_policy
vcpc_wire_fallback:
 inc vic_color_wire_fallback_lo
 bne vcpc_policy
 inc vic_color_wire_fallback_hi
vcpc_policy:
.if VIC_COLOR_FALLBACK_MODE = $01
 jmp vcpc_take_new_owner
.endif
.if VIC_COLOR_FALLBACK_MODE = $02
 lda vic_color_source
 cmp #$02
 beq vcpc_take_new_owner
.endif
.if VIC_COLOR_FALLBACK_MODE = $03
 jsr vic_color_policy_lowres_compat
 bcs vcpc_take_new_owner
.endif
vcpc_block:
 pla
 tay
 ldx vic_color_saved_x
 clc
 rts
vcpc_take_new_owner:
 lda material_screen_cur
 sta (p1lo),y
 lda material_color_cur
 sta (shadeptrlo),y
 jmp vcpc_allow
.if VIC_COLOR_FALLBACK_MODE = $03
; Compat fallback: prefer the most readable VIC-II lowres color, with a small
; bias for wire sources so outlines stay visible without winning every conflict.
vic_color_policy_lowres_compat:
 lda (shadeptrlo),y
 tax
 lda vic_color_lowres_luma,x
 sta vic_color_owner_luma
 lda material_color_cur
 tax
 lda vic_color_lowres_luma,x
 ldx vic_color_source
 cpx #$02
 bne vclc_compare
 clc
 adc #$02
vclc_compare:
 cmp vic_color_owner_luma
 bcc vclc_no
 sec
 rts
vclc_no:
 clc
 rts
.endif
.else
 jmp vcpc_allow
.endif

.endif




draw_depth_buckets:
 lda bucket_min
 cmp #$ff
 beq ddb_done
.if WIRE_TWO_COLOR_MODE2_ENABLE != 0
 jsr activate_wire_two_color_palette
.endif
 jsr select_draw_paths
 lda bucket_max
 tax
ddb_bucket:
 stx sorti
.if WIRE_DEPTH_SORT_ENABLE != 0
 lda wire_bucket_head,x
 cmp #$ff
 beq ddb_face_bucket
 sta wire_entry_cursor
ddb_wire_loop:
 jsr draw_bucket_wire_object
 ldx wire_entry_cursor
 lda wire_next,x
 cmp #$ff
 beq ddb_face_bucket
 sta wire_entry_cursor
 jmp ddb_wire_loop
ddb_face_bucket:
 ldx sorti
.endif
 lda bucket_head,x
 cmp #$ff
 beq ddb_next_bucket
.if MODE4_FACE_ID_LATCH != 0
 ; Exact four-byte replacement for STA sortj / LDY sortj below.
 jmp mode4_latch_current_face_id
 nop
.else
 sta sortj
.endif
ddb_face_loop:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 jsr shared_resolve_bucket_face
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy faceidx
.else
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
.endif
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
 lda frame_face_prepare,y
 beq ddb_face_full_load
 jsr engine_mode3_load_prepared_face_y
 jmp ddb_face_load_done
ddb_face_full_load:
.endif
.if MODE7_UV_CARRIER != 0
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy shared_runtime_face
.else
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
.endif
 jsr gouraud_load_face_raw_shades_y
.endif
 jsr load_face_y
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
ddb_face_load_done:
.endif
 bcc ddb_after_draw
.if SCENE_OBJECT_COUNT != 0
.if CAMERA_MOVABLE != 0
.if CONSERVATIVE_SLIVER_CULL != 0
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
 ldy sortj
 lda frame_face_prepare,y
 bne ddb_sliver_ready
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 bne ddb_skip_sliver
.endif
 jsr face_far_depth
 bne ddb_skip_sliver
 jsr face_conservative_sliver
 beq ddb_after_draw
ddb_skip_sliver:
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
ddb_sliver_ready:
.endif
.endif
.endif
.endif
.if HIDDEN_WIRE_ENABLE != 0
 lda #$00
 sta fillbyte
ddb_hidden_mask_call:
 jsr draw_loaded_face_solid_a
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0 && WIRE_MESH_COUNT != 0
 ldy sortj
 lda face_mesh_is_wire,y
 bne ddb_hidden_draw_face_edges
.if EXPLORER_SCREEN_CLIP_X != 0
 jsr draw_clip_second_load
 bcc ddb_after_draw
 lda #$00
 sta fillbyte
ddb_hidden_mask_second_only_call:
 jsr draw_loaded_face_solid_a
.endif
 jmp ddb_after_draw
ddb_hidden_draw_face_edges:
.endif
.if WIRE_TWO_COLOR_MODE2_ENABLE != 0
 ldy sortj
 jsr load_wire_two_color_face_pattern_y
.else
.if FACE_SOLID_COLOR_ENABLE != 0
 ldy sortj
 jsr load_face_solid_color_y
 bcs ddb_hidden_wire_color_ready
.endif
 lda #$aa
 sta fillbyte
ddb_hidden_wire_color_ready:
.if MODE2_FACE_BUCKET_PIPELINE != 0 && WIRE_OBJECT_MATERIAL_ENABLE != 0
 jsr restore_face_owner_wire_color
.endif
.endif
.if MODE2_FACE_BUCKET_PIPELINE != 0
 jsr draw_loaded_wire_face
.else
 jsr draw_loaded_wire_face_unique
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
 jsr draw_clip_second_load
 bcc ddb_after_draw
 lda #$00
 sta fillbyte
ddb_hidden_mask_second_call:
 jsr draw_loaded_face_solid_a
.if WIRE_TWO_COLOR_MODE2_ENABLE != 0
 ldy sortj
 jsr load_wire_two_color_face_pattern_y
.else
.if FACE_SOLID_COLOR_ENABLE != 0
 ldy sortj
 jsr load_face_solid_color_y
 bcs ddb_hidden_wire_color_second_ready
.endif
 lda #$aa
 sta fillbyte
ddb_hidden_wire_color_second_ready:
.if MODE2_FACE_BUCKET_PIPELINE != 0 && WIRE_OBJECT_MATERIAL_ENABLE != 0
 jsr restore_face_owner_wire_color
.endif
.endif
.if MODE2_FACE_BUCKET_PIPELINE != 0
 jsr draw_loaded_wire_face
.else
 jsr draw_loaded_wire_face_unique
.endif
.endif
 jmp ddb_after_draw
.endif
.if HIDDEN_WIRE_ENABLE = 0
.if FACE_SOLID_COLOR_ENABLE != 0
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
 jsr load_face_solid_color_y
 bcs ddb_solid_call
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
 jsr load_face_material
.endif
.if MODE7_UV_CARRIER != 0
 jsr gouraud_apply_face_reflectivity
 jsr draw_loaded_face_gouraud
 jmp ddb_after_draw
.endif
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
.if STATIC_SHADE_DIRECT != 0
 lda face_shade,y
 bmi ddb_pattern
 lda face_static_fill,y
 sta fillbyte
 jmp ddb_solid_call
.else
.if DYNAMIC_LIGHT != 0 || STATIC_SHADE_CACHE != 0
.if MODE4_VALID_SHADE_FACE_PROBE != 0
 ; Exact three-byte replacement for LDA frame_face_shade,Y.  The probe
 ; supplies a full, valid RC4 code and re-enters the ordinary A/B wrappers.
 jmp mode4_valid_shade_face_probe_dispatch
.else
 lda frame_face_shade,y
.endif
.else
 lda #$04
.endif
 bmi ddb_pattern
.if FRAME_FACE_FILL_CACHE != 0
 lda frame_face_fill,y
 sta fillbyte
 jmp ddb_solid_call
.else
 tay
ddb_solid_from_y:
 lda shade_solid_bytes,y
 sta fillbyte
.endif
.endif
ddb_solid_call:
 jsr draw_loaded_face_solid_a
.if MODE5_POLYGON_OUTLINE != 0
 jsr mode5_draw_loaded_polygon_outline
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
 jsr draw_clip_second_solid
.endif
 jmp ddb_after_draw
ddb_pattern:
.if MODE4_PATTERN_PROBE != 0
 ; Preserve the four-byte footprint of AND/STA below: the protected XYQ2
 ; builder and trace therefore retain their validated code addresses.
 jmp mode4_pattern_probe_dispatch
 nop
.else
 and #$7f
 sta shadeidx
.endif
.if PATTERN_MIN_SPAN != 0
.if MODE4_PATTERN_PROBE = 0 && MODE4_PATTERN_PROBE_LATCHED_FACE = 0
 lda spanw
 cmp #PATTERN_MIN_SPAN
 bcc ddb_pattern_as_solid
 lda spanh
 cmp #PATTERN_MIN_SPAN
 bcc ddb_pattern_as_solid
.endif
.endif
ddb_pattern_call:
 jsr draw_loaded_face_pattern_a
.if MODE5_POLYGON_OUTLINE != 0
 jsr mode5_draw_loaded_polygon_outline
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
 jsr draw_clip_second_pattern
.endif
.if PATTERN_MIN_SPAN != 0
 jmp ddb_after_draw
ddb_pattern_as_solid:
 lda shadeidx
.endif
ddb_pattern_zero_solid:
.if STATIC_SHADE_DIRECT != 0
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
 lda face_static_fill,y
 sta fillbyte
 jmp ddb_solid_call
.else
.if FRAME_FACE_FILL_CACHE != 0
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
 lda frame_face_fill,y
 sta fillbyte
 jmp ddb_solid_call
.else
 tay
 jmp ddb_solid_from_y
.endif
.endif
.endif
ddb_after_draw:
.if MODE4_FACE_ID_LATCH != 0
 ldx mode4_current_face_id
.else
 ldx sortj
.endif
 lda face_next,x
 cmp #$ff
 beq ddb_next_bucket
.if MODE4_FACE_ID_LATCH != 0
 ; Exact five-byte replacement for STA sortj / JMP ddb_face_loop below.
 jmp mode4_latch_current_face_id
 nop
 nop
.else
 sta sortj
 jmp ddb_face_loop
.endif
ddb_next_bucket:
 ldx sorti
 cpx bucket_min
 beq ddb_done
 dex
 jmp ddb_bucket
ddb_done:
 rts

.if MESH_SOURCE_SHARING_RUNTIME != 0
; A bucket node is a runtime face id. Its two compact identity tables resolve
; the owning instance and source-local face without duplicating topology.
shared_resolve_bucket_face:
 ldy sortj
 sty shared_runtime_face
 lda bucket_face_instance,y
 sta objidx
 tax
 lda object_mesh,x
 sta meshidx
 lda object_source_vertex_delta,x
 sta shared_vertex_delta
 lda bucket_face_local,y
 ldx meshidx
 clc
 adc mesh_face_first,x
 sta faceidx
 jsr shared_prepare_face_vertices
.if CAMERA_PLANE_CLIP_PROFILE != 0
 jsr camera_plane_face_classify
.endif
 rts
.endif

.if EXPLORER_SCREEN_CLIP_X != 0
draw_clip_second_load:
 lda clip_second_pending
 beq dcsl_no
 lda #$00
 sta clip_second_pending
 lda clip_second_count
 sta loaded_face_vertex_count
 lda clip2_vx0
 sta vx0
 lda clip2_vy0
 sta vy0
 lda clip2_vx1
 sta vx1
 lda clip2_vy1
 sta vy1
 lda clip2_vx2
 sta vx2
 lda clip2_vy2
 sta vy2
 lda clip_second_count
 cmp #$04
 beq dcsl_load_v3
 lda clip2_vx2
 sta vx3
 lda clip2_vy2
 sta vy3
 sec
 rts
dcsl_load_v3:
 lda clip2_vx3
 sta vx3
 lda clip2_vy3
 sta vy3
 sec
 rts
dcsl_no:
 clc
 rts

draw_clip_second_solid:
 jsr draw_clip_second_load
 bcc dcss_done
 jsr draw_loaded_face_solid_a
.if MODE5_POLYGON_OUTLINE != 0
 jsr mode5_draw_loaded_polygon_outline
.endif
dcss_done:
 rts

draw_clip_second_pattern:
 jsr draw_clip_second_load
 bcc dcsp_done
 jsr draw_loaded_face_pattern_a
.if MODE5_POLYGON_OUTLINE != 0
 jsr mode5_draw_loaded_polygon_outline
.endif
dcsp_done:
 rts
.endif

.if FLAT_DYNAMIC_SHADE != 0 && DYNAMIC_LIGHT != 0
update_face_shade:
.if DYNAMIC_LIGHT != 0
.if FACE_REFLECTIVITY_ACTIVE_ONLY != $01
 jsr load_face_reflectivity_y
.endif
 sty tmpidx
.if MODE4_OBJECT_LIGHT_CACHE != 0
 lda #$00
 sta dotlo
 sta dothi
 ldy tmpidx
 lda face_normal_x,y
 ldx sh_nx
 jsr mul_s8_16
 jsr add_dot_product
 ldy tmpidx
 lda face_normal_y,y
 ldx sh_ny
 jsr mul_s8_16
 jsr add_dot_product
 ldy tmpidx
 lda face_normal_z,y
 ldx sh_nz
 jsr mul_s8_16
 jsr add_dot_product
 jsr subtract_face_center_dot
.else
 jsr rotate_face_normal_for_shade
 ldx light_phase
 stx sh_lx
 lda #$00
 sta dotlo
 sta dothi
 ldx sh_lx
 lda light_pos_x,x
 tax
 lda sh_nx
 jsr mul_s8_16
 jsr add_dot_product
 ldx sh_lx
 lda light_pos_y,x
 tax
 lda sh_ny
 jsr mul_s8_16
 jsr add_dot_product
 ldx sh_lx
 lda light_pos_z,x
 tax
 lda sh_nz
 jsr mul_s8_16
 jsr add_dot_product
 jsr subtract_face_center_dot
.if SCENE_OBJECT_COUNT != 0
 jsr subtract_object_position_dot
.endif
.endif
 jsr select_face_shade_from_dot
.if MODE4_SHADE_STEP_LIMIT != 0
 jsr mode4_shade_step_limit_apply
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy shared_runtime_face
.else
 ldy tmpidx
.endif
 sta frame_face_shade,y
.if FRAME_FACE_FILL_CACHE != 0
 and #$7f
 tax
 lda shade_solid_bytes,x
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy shared_runtime_face
.else
 ldy tmpidx
.endif
 sta frame_face_fill,y
.endif
.endif
 rts
.endif

.if DYNAMIC_LIGHT != 0
.if MODE4_UNCACHED_LIGHT_FALLBACK != 0
rotate_face_normal_for_shade:
 ldy tmpidx
 lda face_normal_x,y
 ldx m00
 jsr mul_s6
 sta sh_nx
 lda face_normal_y,y
 ldx m01
 jsr mul_s6
 clc
 adc sh_nx
 sta sh_nx
 lda face_normal_z,y
 ldx m02
 jsr mul_s6
 clc
 adc sh_nx
 sta sh_nx
 lda face_normal_x,y
 ldx m10
 jsr mul_s6
 sta sh_ny
 lda face_normal_y,y
 ldx m11
 jsr mul_s6
 clc
 adc sh_ny
 sta sh_ny
 lda face_normal_z,y
 ldx m12
 jsr mul_s6
 clc
 adc sh_ny
 sta sh_ny
 lda face_normal_x,y
 ldx m20
 jsr mul_s6
 sta sh_nz
 lda face_normal_y,y
 ldx m21
 jsr mul_s6
 clc
 adc sh_nz
 sta sh_nz
 lda face_normal_z,y
 ldx m22
 jsr mul_s6
 clc
 adc sh_nz
 sta sh_nz
 rts
.endif

subtract_face_center_dot:
 ldy tmpidx
 sec
 lda dotlo
 sbc face_center_dot_lo,y
 sta dotlo
 lda dothi
 sbc face_center_dot_hi,y
 sta dothi
 rts

.if MODE4_UNCACHED_LIGHT_FALLBACK != 0
.if SCENE_OBJECT_COUNT != 0
subtract_object_position_dot:
.if SCENE_OBJECT_X_ACTIVE != 0
 ldx obj_pos_x_cur
 lda sh_nx
 jsr mul_s8_16
 jsr subtract_dot_product
.endif
.if SCENE_OBJECT_Y_ACTIVE != 0
 ldx obj_pos_y_cur
 lda sh_ny
 jsr mul_s8_16
 jsr subtract_dot_product
.endif
 ldx obj_depth_lo
 lda sh_nz
 jsr mul_s8_16
 jsr subtract_dot_product
 rts
.endif
.endif

add_dot_product:
 clc
 lda dotlo
 adc prodlo
 sta dotlo
 lda dothi
 adc prodhi
 sta dothi
 rts

.if MODE4_UNCACHED_LIGHT_FALLBACK != 0
subtract_dot_product:
 sec
 lda dotlo
 sbc prodlo
 sta dotlo
 lda dothi
 sbc prodhi
 sta dothi
 rts
.endif

select_face_shade_from_dot:
 jsr select_raw_face_shade_from_dot
.if FULL_DYNAMIC_SHADE = 0
 rts
.else
 sta t1
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy shared_runtime_face
.else
 ldy tmpidx
.endif
 lda frame_face_shade,y
 sta t2
 cmp t1
 beq sfs_keep_old
 lda shade_intensity_changed
 bne sfs_accept_new
 lda t2
 cmp #$80
 beq sfs_old_black_dark
 cmp #$00
 beq sfs_old_solid_dark
 cmp #$82
 beq sfs_old_checker_mid
 cmp #$02
 beq sfs_old_solid_high
 jmp sfs_old_white_high
sfs_old_black_dark:
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 bmi sfs_keep_old
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_dark_up_q6+1,x
 bcc sfs_keep_old
 bne sfs_accept_new
 lda dotlo
 cmp shade_hyst_dark_up_q6,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 bmi sfs_keep_old
 cmp shade_hyst_dark_up,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_solid_dark:
 lda t1
 cmp #$80
 beq sfs_old_solid_dark_down
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 bmi sfs_keep_old
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_checker_dark_up_q6+1,x
 bcc sfs_keep_old
 bne sfs_accept_new
 lda dotlo
 cmp shade_hyst_checker_dark_up_q6,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 cmp shade_hyst_checker_dark_up,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_solid_dark_down:
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 jmp sfs_keep_old
sfs_old_checker_mid:
 lda t1
 cmp #$02
 beq sfs_old_checker_mid_up
 cmp #$84
 beq sfs_old_checker_mid_up
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_solid_mid_down_q6+1,x
 bcc sfs_accept_new
 bne sfs_keep_old
 lda dotlo
 cmp shade_hyst_solid_mid_down_q6,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 cmp shade_hyst_solid_mid_down,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_checker_mid_up:
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 bmi sfs_keep_old
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_solid_mid_up_q6+1,x
 bcc sfs_keep_old
 bne sfs_accept_new
 lda dotlo
 cmp shade_hyst_solid_mid_up_q6,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 cmp shade_hyst_solid_mid_up,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_solid_high:
 lda t1
 cmp #$84
 beq sfs_old_solid_high_up
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_checker_high_down_q6+1,x
 bcc sfs_accept_new
 bne sfs_keep_old
 lda dotlo
 cmp shade_hyst_checker_high_down_q6,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 cmp shade_hyst_checker_high_down,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_solid_high_up:
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 bmi sfs_keep_old
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_checker_high_up_q6+1,x
 bcc sfs_keep_old
 bne sfs_accept_new
 lda dotlo
 cmp shade_hyst_checker_high_up_q6,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 cmp shade_hyst_checker_high_up,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_white_high:
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_solid_high_down_q6+1,x
 bcc sfs_accept_new
 bne sfs_keep_old
 lda dotlo
 cmp shade_hyst_solid_high_down_q6,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 cmp shade_hyst_solid_high_down,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_accept_new:
 lda t1
 rts
sfs_keep_old:
 lda t2
 rts
.endif

select_raw_face_shade_from_dot:
 ldx light_intensity
 beq srfs_dark
 lda dothi
 bmi srfs_dark
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 txa
 asl
 tax
 lda dothi
 cmp shade_thresh_high_q6+1,x
 bcc srfs_fix_mid_high
 bne srfs_high_exposure
 lda dotlo
 cmp shade_thresh_high_q6,x
 bcs srfs_high_exposure
srfs_fix_mid_high:
 lda dothi
 cmp shade_thresh_mid_high_q6+1,x
 bcc srfs_fix_mid
 bne srfs_mid_high_exposure
 lda dotlo
 cmp shade_thresh_mid_high_q6,x
 bcs srfs_mid_high_exposure
srfs_fix_mid:
 lda dothi
 cmp shade_thresh_mid_q6+1,x
 bcc srfs_dark
 bne srfs_checker_mid
 lda dotlo
 cmp shade_thresh_mid_q6,x
 bcs srfs_checker_mid
 jmp srfs_dark
.else
 cmp shade_thresh_high,x
 bcs srfs_high_exposure
 cmp shade_thresh_mid_high,x
 bcs srfs_mid_high_exposure
 cmp shade_thresh_mid,x
 bcs srfs_checker_mid
.endif
srfs_dark:
 lda #$00
 rts
srfs_checker_mid:
 lda material_reflect_offset_cur
 cmp #$14
 bcs srfs_checker_white_high
 cmp #$0a
 bcs srfs_checker_dark_reflect_high
 lda #$82
 rts
srfs_mid_high_exposure:
 lda material_reflect_offset_cur
 cmp #$14
 bcs srfs_solid_reflect_high
 cmp #$0a
 bcs srfs_checker_white_high
 lda #$02
 rts
srfs_high_exposure:
 lda material_reflect_offset_cur
 cmp #$14
 bcs srfs_solid_reflect_high
 cmp #$0a
 bcs srfs_checker_white_high
 lda #$84
 rts
srfs_checker_white_high:
 lda #$84
 rts
srfs_checker_dark_reflect_high:
 lda #$86
 rts
srfs_solid_reflect_high:
 lda #$04
 rts
.endif

.endif

.if FACE_RENDER_ENABLE != 0
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
engine_mode3_load_prepared_face_y:
.if EXPLORER_SCREEN_CLIP_X != 0
 lda #$00
 sta clip_second_pending
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda #$00
 sta clip_poly_active
.endif
.if EXPLORER_NEAR_POLY != 0
 lda #$00
 sta near_face_crossing
.endif
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 lda shared_fv0
.else
 lda face0,y
.endif
 tax
 lda sx,x
 sta vx0
 lda sy,x
 sta vy0
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 lda shared_fv1
.else
 lda face1,y
.endif
 tax
 lda sx,x
 sta vx1
 lda sy,x
 sta vy1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 lda shared_fv2
.else
 lda face2,y
.endif
 tax
 lda sx,x
 sta vx2
 lda sy,x
 sta vy2
.if HAS_TRI_FACES != 0
 ldy sortj
 lda face_vertex_count,y
 sta loaded_face_vertex_count
 cmp #$04
 beq sm3lpf_load_v3
 lda vx2
 sta vx3
 lda vy2
 sta vy3
 jmp sm3lpf_spans
sm3lpf_load_v3:
.else
 lda #$04
 sta loaded_face_vertex_count
.endif
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 lda shared_fv3
.else
 lda face3,y
.endif
 tax
 lda sx,x
 sta vx3
 lda sy,x
 sta vy3
sm3lpf_spans:
 ldy sortj
 lda frame_face_spanw,y
 sta spanw
 lda frame_face_spanh,y
 sta spanh
 sec
 rts
.endif

; Q8-only: old integer polygon clip retired.
hp_retired_load_face_y = hp_unreachable
.if EXPLORER_SCREEN_CLIP_X != 0
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if HAS_TRI_FACES != 0
load_face_y_v3 = hp_unreachable
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
load_face_y_clip = hp_unreachable
.if CAMERA_PLANE_CLIP_PROFILE != 0
.endif
.if WORLD_GROUND_PLANE_CLIP != 0
.if MESH_SOURCE_SHARING_RUNTIME = 0
.endif
lfy_ground_plane_no_cross = hp_unreachable
.endif
.if CAMERA_PLANE_CLIP_PROFILE != 0
.if MESH_SOURCE_SHARING_RUNTIME = 0
.endif
lfy_camera_plane_no_cross = hp_unreachable
.endif
.if EXPLORER_NEAR_POLY != 0 && MODE3_LATE_NEAR_NO_POLY = 0
.if MESH_SOURCE_SHARING_RUNTIME = 0
.endif
lfy_no_near_poly = hp_unreachable
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
lfy_no_poly = hp_unreachable
.endif
screen_face_drawable:
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 ; Retain legacy spanw/spanh production for the Mode 4 pattern dispatch,
 ; but bypass only its integer SCREEN_MIN_SPAN eligibility rejection.
.endif
 lda vx0
 sta p1lo
 sta p1hi
 lda vx1
 cmp p1lo
 bcs sfd_x1_min_ok
 sta p1lo
sfd_x1_min_ok:
 cmp p1hi
 bcc sfd_x1_max_ok
 sta p1hi
sfd_x1_max_ok:
 lda vx2
 cmp p1lo
 bcs sfd_x2_min_ok
 sta p1lo
sfd_x2_min_ok:
 cmp p1hi
 bcc sfd_x2_max_ok
 sta p1hi
sfd_x2_max_ok:
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne sfd_x_span
.endif
 lda vx3
 cmp p1lo
 bcs sfd_x3_min_ok
 sta p1lo
sfd_x3_min_ok:
 cmp p1hi
 bcc sfd_x_span
 sta p1hi
sfd_x_span:
 sec
 lda p1hi
 sbc p1lo
.if SCENE_OBJECT_COUNT != 0
 sta spanw
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 jmp sfd_y_bounds
.endif
 cmp #SCREEN_MIN_SPAN
 bcs sfd_y_bounds
 jsr face_far_depth
 beq sfd_no
 lda spanw
 cmp #FAR_SCREEN_MIN_SPAN
 bcc sfd_no
 jmp sfd_y_bounds
.else
.if PATTERN_MIN_SPAN != 0
 sta spanw
.endif
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 jmp sfd_y_bounds
.endif
 cmp #SCREEN_MIN_SPAN
 bcc sfd_no
.endif
sfd_y_bounds:
 lda vy0
 sta p1lo
 sta p1hi
 lda vy1
 cmp p1lo
 bcs sfd_y1_min_ok
 sta p1lo
sfd_y1_min_ok:
 cmp p1hi
 bcc sfd_y1_max_ok
 sta p1hi
sfd_y1_max_ok:
 lda vy2
 cmp p1lo
 bcs sfd_y2_min_ok
 sta p1lo
sfd_y2_min_ok:
 cmp p1hi
 bcc sfd_y2_max_ok
 sta p1hi
sfd_y2_max_ok:
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne sfd_y_span
.endif
 lda vy3
 cmp p1lo
 bcs sfd_y3_min_ok
 sta p1lo
sfd_y3_min_ok:
 cmp p1hi
 bcc sfd_y_span
 sta p1hi
sfd_y_span:
 sec
 lda p1hi
 sbc p1lo
.if SCENE_OBJECT_COUNT != 0
 sta spanh
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 jmp sfd_yes
.endif
 cmp #SCREEN_MIN_SPAN
 bcs sfd_yes
 jsr face_far_depth
 beq sfd_no
 lda spanh
 cmp #FAR_SCREEN_MIN_SPAN
 bcc sfd_no
.else
.if PATTERN_MIN_SPAN != 0
 sta spanh
.endif
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 jmp sfd_yes
.endif
 cmp #SCREEN_MIN_SPAN
 bcc sfd_no
.endif
sfd_yes:
 sec
 rts
sfd_no:
 clc
 rts

.if EXPLORER_SCREEN_CLIP_POLY != 0
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0
.if * > HIGH_BASIC_V2_STATIC_LOW_BASE
 .error "High-basic-v2 middle code overlaps lower static segment"
.endif
* = HIGH_BASIC_V2_CODE_HIGH_BASE
.if * != HIGH_BASIC_V2_CODE_HIGH_BASE
 .error "High-basic-v2 high code did not start at $a000"
.endif
.endif
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0 && WIRE_RENDER_ENABLE != 0 && WIRE_MESH_COUNT != 0
.if * > $5c00
 .error "High-basic-v2 middle segment overlaps video buffer A"
.endif
* = $a000
.endif
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0 && (WIRE_RENDER_ENABLE = 0 || WIRE_MESH_COUNT = 0)
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
* = $4000
.endif
; Q8-only: old integer polygon clip retired.
clip_loaded_face_poly_x = hp_unreachable
.if WIRE_RENDER_ENABLE != 0
.endif
.if EXPLORER_CAMERA_X_CLIP != 0
.endif
clip_poly_clip_screen_current = hp_unreachable
clip_poly_compact_screen_a = hp_unreachable
cpcsa_loop = hp_unreachable
cpcsa_append = hp_unreachable
cpcsa_inc_write = hp_unreachable
cpcsa_skip = hp_unreachable
cpcsa_done = hp_unreachable
.if WIRE_RENDER_ENABLE != 0
clip_poly_inside_screen_fast = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if HAS_TRI_FACES != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
cpisf_yes = hp_unreachable
cpisf_no = hp_unreachable
clip_vertex_inside_screen_fast = hp_unreachable
cvisf_no = hp_unreachable
.endif
.if EXPLORER_CAMERA_X_CLIP != 0
clip_poly_clip_camera_x_current = hp_unreachable
clip_poly_right_cam_a_to_b = hp_unreachable
cprca_loop = hp_unreachable
cprca_append_cur = hp_unreachable
cprca_cur_out = hp_unreachable
cprca_next = hp_unreachable
cprca_done = hp_unreachable
clip_poly_left_cam_b_to_a = hp_unreachable
cplcb_loop = hp_unreachable
cplcb_append_cur = hp_unreachable
cplcb_cur_out = hp_unreachable
cplcb_next = hp_unreachable
cplcb_done = hp_unreachable
clip_poly_top_cam_a_to_b = hp_unreachable
cptca_loop = hp_unreachable
cptca_append_cur = hp_unreachable
cptca_cur_out = hp_unreachable
cptca_next = hp_unreachable
cptca_done = hp_unreachable
clip_poly_bottom_cam_b_to_a = hp_unreachable
cpbcb_loop = hp_unreachable
cpbcb_append_cur = hp_unreachable
cpbcb_cur_out = hp_unreachable
cpbcb_next = hp_unreachable
cpbcb_done = hp_unreachable
clip_a_right_inside_cam = hp_unreachable
carcam_no = hp_unreachable
clip_b_left_inside_cam = hp_unreachable
cblcam_no = hp_unreachable
clip_a_top_inside_cam = hp_unreachable
catcam_no = hp_unreachable
clip_b_bottom_inside_cam = hp_unreachable
cbbcam_no = hp_unreachable
clip_append_right_intersection_cam_a_to_b = hp_unreachable
carcam_prev_inside = hp_unreachable
carcam_project = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.if MODE7_UV_CARRIER != 0
.endif
.if WIRE_RENDER_ENABLE != 0
.endif
clip_append_left_intersection_cam_b_to_a = hp_unreachable
calcam_prev_inside = hp_unreachable
calcam_project = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.if MODE7_UV_CARRIER != 0
.endif
.if WIRE_RENDER_ENABLE != 0
.endif
clip_append_top_intersection_cam_a_to_b = hp_unreachable
catcam_prev_inside = hp_unreachable
catcam_project = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.if MODE7_UV_CARRIER != 0
.endif
.if WIRE_RENDER_ENABLE != 0
.endif
clip_append_bottom_intersection_cam_b_to_a = hp_unreachable
cabcam_prev_inside = hp_unreachable
cabcam_project = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.if MODE7_UV_CARRIER != 0
.endif
.if WIRE_RENDER_ENABLE != 0
.endif
clip_cam_ratio_right_a = hp_unreachable
clip_cam_ratio_left_b = hp_unreachable
clip_cam_ratio_top_a = hp_unreachable
clip_cam_ratio_bottom_b = hp_unreachable
clip_cam_finish_ratio = hp_unreachable
clip_abs_p1 = hp_unreachable
cap1_done = hp_unreachable
clip_cam_right_dist_a = hp_unreachable
clip_cam_left_dist_b = hp_unreachable
clip_cam_top_dist_a = hp_unreachable
clip_cam_bottom_dist_b = hp_unreachable
clip_cam_norm_x_a = hp_unreachable
clip_cam_norm_x_b = hp_unreachable
clip_cam_norm_y_a = hp_unreachable
clip_cam_norm_y_b = hp_unreachable
clip_cam_norm_depth_coord = hp_unreachable
ccnd_check_fit = hp_unreachable
ccnd_coord_pos = hp_unreachable
ccnd_coord_neg = hp_unreachable
ccnd_shift = hp_unreachable
ccnd_done = hp_unreachable
ccnd_depth_ok = hp_unreachable
clip_cam_depth_byte_a = hp_unreachable
ccdba_low = hp_unreachable
ccdba_zero = hp_unreachable
clip_cam_depth_byte_b = hp_unreachable
ccdbb_low = hp_unreachable
ccdbb_zero = hp_unreachable
clip_cam_x_byte_a = hp_unreachable
clip_cam_x_byte_b = hp_unreachable
clip_cam_y_byte_a = hp_unreachable
clip_cam_y_byte_b = hp_unreachable
clip_poly_project_a_from_camera = hp_unreachable
cppafc_loop = hp_unreachable
cppafc_done = hp_unreachable
clip_project_a_x_from_camera = hp_unreachable
cpax_left_saturated = hp_unreachable
cpax_not_saturated = hp_unreachable
cpax_right_clamp = hp_unreachable
cpax_left = hp_unreachable
cpax_left_clamp = hp_unreachable
clip_project_a_y_from_camera = hp_unreachable
cpay_down_saturated = hp_unreachable
cpay_not_saturated = hp_unreachable
cpay_top_clamp = hp_unreachable
cpay_down = hp_unreachable
cpay_bottom_clamp = hp_unreachable
clip_project_axis_offset = hp_unreachable
cpao_abs_ready = hp_unreachable
cpao_scale_loop = hp_unreachable
cpao_depth_nonzero = hp_unreachable
cpao_mul_start = hp_unreachable
cpao_mul_loop = hp_unreachable
cpao_no_add = hp_unreachable
cpao_shift_ok = hp_unreachable
cpao_saturate = hp_unreachable
cpao_divide = hp_unreachable
cpao_offset_ok = hp_unreachable
clip_cam_interp_y_a_to_b = hp_unreachable
clip_cam_interp_y_b_to_a = hp_unreachable
clip_cam_interp_vx_a_to_b = hp_unreachable
clip_cam_interp_vy_a_to_b = hp_unreachable
clip_cam_interp_vz_a_to_b = hp_unreachable
clip_cam_interp_vx_b_to_a = hp_unreachable
clip_cam_interp_vy_b_to_a = hp_unreachable
clip_cam_interp_vz_b_to_a = hp_unreachable
.endif
.if CAMERA_PLANE_CLIP_PROFILE != 0
camera_plane_clip_loaded_face = hp_unreachable
cpclf_loop = hp_unreachable
cpclf_append_current = hp_unreachable
cpclf_cur_outside = hp_unreachable
cpclf_next = hp_unreachable
cpclf_done = hp_unreachable
.if WORLD_GROUND_PLANE_CLIP != 0
camera_plane_clip_a_to_b = hp_unreachable
cpcab_loop = hp_unreachable
cpcab_append_current = hp_unreachable
cpcab_cur_outside = hp_unreachable
cpcab_next = hp_unreachable
cpcab_copy_back = hp_unreachable
cpcab_done = hp_unreachable
camera_plane_inside_a = hp_unreachable
cpia_in = hp_unreachable
cpia_out = hp_unreachable
camera_plane_append_intersection_a_to_b = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
cpai_prev_outside = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
cpai_ratio = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.if WIRE_RENDER_ENABLE != 0
.endif
camera_plane_interp_vx_a_to_b = hp_unreachable
camera_plane_interp_vy_a_to_b = hp_unreachable
camera_plane_project_all_a = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
cppaa_loop = hp_unreachable
cppaa_done = hp_unreachable
.endif
camera_plane_original_inside = hp_unreachable
cpoi_in = hp_unreachable
cpoi_out = hp_unreachable
camera_plane_append_original_current = hp_unreachable
cpaoc_projected = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.if WIRE_RENDER_ENABLE != 0
.endif
camera_plane_append_original_intersection = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
cpaoi_cur_outside = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
cpaoi_ratio = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.if WIRE_RENDER_ENABLE != 0
.endif
camera_plane_interp_original_x = hp_unreachable
camera_plane_interp_original_y = hp_unreachable
camera_plane_project_clip_a_vertex = hp_unreachable
.if CAMERA_MOVABLE != 0
.else
.endif
camera_plane_project_original_intersection = hp_unreachable
.if CAMERA_MOVABLE != 0
.else
.endif
camera_plane_project_clip_a_loaded_depth = hp_unreachable
.if CAMERA_MOVABLE != 0
.if WORLD_GROUND_PLANE_CLIP != 0
.endif
.else
.endif
camera_plane_get_face_vertex = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
cpgfv_0 = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
cpgfv_1 = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
cpgfv_2 = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
camera_plane_store_bucket_from_a = hp_unreachable
cpsb_sum_ok = hp_unreachable
.if CAMERA_MOVABLE != 0 || GRAPHICS_MODE = $07 || GRAPHICS_MODE = $05 || GRAPHICS_MODE = $07
cpsb_mobile_ready = hp_unreachable
.else
cpsb_fixed_sat = hp_unreachable
.endif
cpsb_store = hp_unreachable
cpsb_done = hp_unreachable
.endif
clpx_empty = hp_unreachable
clpx_done = hp_unreachable
.if EXPLORER_NEAR_POLY != 0
clip_loaded_face_near_poly = hp_unreachable
cln_crossing = hp_unreachable
.if EXPLORER_NEAR_FILL != 0
.endif
cln_start = hp_unreachable
cln_loop = hp_unreachable
cln_append_cur = hp_unreachable
cln_cur_outside = hp_unreachable
cln_next = hp_unreachable
.if EXPLORER_CAMERA_X_CLIP != 0
.else
.endif
cln_done = hp_unreachable
.if EXPLORER_NEAR_FILL != 0
clip_near_fullscreen_fill = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.endif
near_get_face_vertex = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
ngfv_0 = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
ngfv_1 = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
ngfv_2 = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
near_append_current_vertex = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.if WIRE_RENDER_ENABLE != 0
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
.endif
near_append_intersection = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
nai_cur_outside = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
near_project_intersection = hp_unreachable
npi_den_ok = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.if WIRE_RENDER_ENABLE != 0
.endif
near_interp_x_to_t1 = hp_unreachable
near_interp_y_to_t2 = hp_unreachable
near_depth_byte = hp_unreachable
ndb_low = hp_unreachable
ndb_zero = hp_unreachable
near_project_abs_scale = hp_unreachable
npas_ok = hp_unreachable
near_project_t1_to_clip_x = hp_unreachable
nptx_right_clamp = hp_unreachable
nptx_left = hp_unreachable
nptx_left_clamp = hp_unreachable
near_project_t2_to_clip_y = hp_unreachable
npty_top_clamp = hp_unreachable
npty_down = hp_unreachable
npty_bottom_clamp = hp_unreachable
.endif
clip_poly_all_outside_screen = hp_unreachable
cpaos_no = hp_unreachable
cpaos_yes = hp_unreachable
clip_poly_all_right_screen = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if HAS_TRI_FACES != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
cpars_yes = hp_unreachable
cpars_no = hp_unreachable
clip_poly_all_left_screen = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if HAS_TRI_FACES != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
cpals_yes = hp_unreachable
cpals_no = hp_unreachable
clip_poly_all_top_screen = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if HAS_TRI_FACES != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
cpats_yes = hp_unreachable
cpats_no = hp_unreachable
clip_poly_all_bottom_screen = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if HAS_TRI_FACES != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
cpabs_yes = hp_unreachable
cpabs_no = hp_unreachable
clip_poly_needs_screen = hp_unreachable
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if HAS_TRI_FACES != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
cpnx_no = hp_unreachable
cpnx_yes = hp_unreachable
clip_poly_init_from_face = hp_unreachable
.if HAS_TRI_FACES != 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MODE7_UV_CARRIER != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MODE7_UV_CARRIER != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MODE7_UV_CARRIER != 0
.endif
.if HAS_TRI_FACES != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if MODE7_UV_CARRIER != 0
.endif
cpiff_done = hp_unreachable
clip_poly_load_vertex_a = hp_unreachable
.if WIRE_RENDER_ENABLE != 0
.endif
.if EXPLORER_NEAR_POLY != 0
.endif
clip_poly_right_a_to_b = hp_unreachable
cpra_loop = hp_unreachable
cpra_append_cur = hp_unreachable
cpra_cur_out = hp_unreachable
cpra_next = hp_unreachable
cpra_done = hp_unreachable
clip_poly_left_b_to_a = hp_unreachable
cplb_loop = hp_unreachable
cplb_append_cur = hp_unreachable
cplb_cur_out = hp_unreachable
cplb_next = hp_unreachable
cplb_done = hp_unreachable
clip_poly_top_a_to_b = hp_unreachable
cpta_loop = hp_unreachable
cpta_append_cur = hp_unreachable
cpta_cur_out = hp_unreachable
cpta_next = hp_unreachable
cpta_done = hp_unreachable
clip_poly_bottom_b_to_a = hp_unreachable
cpbb_loop = hp_unreachable
cpbb_append_cur = hp_unreachable
cpbb_cur_out = hp_unreachable
cpbb_next = hp_unreachable
cpbb_done = hp_unreachable
clip_a_right_inside = hp_unreachable
cari_yes = hp_unreachable
cari_no = hp_unreachable
clip_b_left_inside = hp_unreachable
cbli_no = hp_unreachable
clip_a_top_inside = hp_unreachable
cati_no = hp_unreachable
clip_b_bottom_inside = hp_unreachable
cbbi_yes = hp_unreachable
cbbi_no = hp_unreachable
clip_copy_a_to_b = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.if WIRE_RENDER_ENABLE != 0
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
.endif
clip_copy_b_to_a = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
.if WIRE_RENDER_ENABLE != 0
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
.endif
clip_append_right_intersection_a_to_b = hp_unreachable
carib_prev_inside = hp_unreachable
carib_interp = hp_unreachable
.if WIRE_RENDER_ENABLE != 0
.endif
clip_append_left_intersection_b_to_a = hp_unreachable
calia_prev_inside = hp_unreachable
calia_interp = hp_unreachable
.if WIRE_RENDER_ENABLE != 0
.endif
clip_append_top_intersection_a_to_b = hp_unreachable
catib_prev_inside = hp_unreachable
catib_interp = hp_unreachable
.if WIRE_RENDER_ENABLE != 0
.endif
clip_append_bottom_intersection_b_to_a = hp_unreachable
cabia_prev_inside = hp_unreachable
cabia_interp = hp_unreachable
.if WIRE_RENDER_ENABLE != 0
.endif
clip_load_inside_right_a = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
clip_load_outside_right_a = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
clora_half_den = hp_unreachable
clora_check_zero = hp_unreachable
clora_done = hp_unreachable
clip_load_inside_left_b = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
clip_load_outside_left_b = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
clolb_check_zero = hp_unreachable
clolb_nonzero = hp_unreachable
clip_load_inside_top_a = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
clita_num_ready = hp_unreachable
clip_load_outside_top_a = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
clota_check_zero = hp_unreachable
clota_nonzero = hp_unreachable
clip_load_inside_bottom_b = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
clip_load_outside_bottom_b = hp_unreachable
.if MODE7_UV_CARRIER != 0
.endif
clobb_half_den = hp_unreachable
clobb_check_zero = hp_unreachable
clobb_done = hp_unreachable
clip_halve_num_den = hp_unreachable
chnd_num_ok = hp_unreachable
clip_ratio_to_scale8 = hp_unreachable
crts_den_ok = hp_unreachable
crts_max = hp_unreachable
crts_fraction = hp_unreachable
crts_loop = hp_unreachable
crts_subtract = hp_unreachable
crts_no_subtract = hp_unreachable
crts_shift_result = hp_unreachable
clip_interp_raw_poly = hp_unreachable
.if MODE7_UV_CARRIER != 0
gouraud_interp_clip_shade = hp_unreachable
.endif
mul_s16_u8_frac = hp_unreachable
ms16u8_abs_ready = hp_unreachable
ms16u8_loop = hp_unreachable
ms16u8_no_add = hp_unreachable
ms16u8_done = hp_unreachable
clip_clamp_p1_x = hp_unreachable
ccpx_min = hp_unreachable
ccpx_max = hp_unreachable
clip_clamp_p1_y = hp_unreachable
ccpy_min = hp_unreachable
ccpy_max = hp_unreachable
clip_interp_y_poly = hp_unreachable
ciyp_neg_den_ready = hp_unreachable
ciyp_positive = hp_unreachable
ciyp_pos_den_ready = hp_unreachable
ciyp_max = hp_unreachable
ciyp_done = hp_unreachable
clip_interp_x_poly = hp_unreachable
cixp_neg_den_ready = hp_unreachable
cixp_positive = hp_unreachable
cixp_pos_den_ready = hp_unreachable
cixp_max = hp_unreachable
cixp_done = hp_unreachable
clip_mul_u8_poly = hp_unreachable
cmu8p_loop = hp_unreachable
cmu8p_no_add = hp_unreachable
clip_poly_drawable = hp_unreachable
cpd_x_loop = hp_unreachable
cpd_x_min_ok = hp_unreachable
cpd_x_next = hp_unreachable
cpd_x_span = hp_unreachable
.if SCENE_OBJECT_COUNT != 0
.else
.if PATTERN_MIN_SPAN != 0
.endif
.endif
cpd_y_bounds = hp_unreachable
cpd_y_loop = hp_unreachable
cpd_y_min_ok = hp_unreachable
cpd_y_next = hp_unreachable
cpd_y_span = hp_unreachable
.if SCENE_OBJECT_COUNT != 0
.else
.if PATTERN_MIN_SPAN != 0
.endif
.endif
cpd_yes = hp_unreachable
cpd_no = hp_unreachable
clip_poly_visible = hp_unreachable
cpv_yes = hp_unreachable
cpv_no = hp_unreachable
clip_poly_load_cull_v0 = hp_unreachable
clip_poly_load_cull_v1 = hp_unreachable
clip_poly_load_cull_v2 = hp_unreachable
clip_right_outside_x_poly = hp_unreachable
croxp_no = hp_unreachable
croxp_yes = hp_unreachable
clip_left_outside_x_poly = hp_unreachable
cloxp_yes = hp_unreachable
clip_top_outside_y_poly = hp_unreachable
ctoyp_yes = hp_unreachable
clip_bottom_outside_y_poly = hp_unreachable
cboyp_no = hp_unreachable
cboyp_yes = hp_unreachable
.endif

.if EXPLORER_SCREEN_CLIP_X != 0
clip_loaded_face_screen_x:
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 beq clfsx_quad
 rts
clfsx_quad:
.endif
 jsr clip_face_right_x_simple
 jsr clip_face_left_x_simple
 rts

clip_face_right_x_simple:
 lda #$00
 sta maskv
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_right_outside_x
 beq cfrx_mask_v1
 lda maskv
 ora #$01
 sta maskv
cfrx_mask_v1:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_right_outside_x
 beq cfrx_mask_v2
 lda maskv
 ora #$02
 sta maskv
cfrx_mask_v2:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_right_outside_x
 beq cfrx_mask_v3
 lda maskv
 ora #$04
 sta maskv
cfrx_mask_v3:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_right_outside_x
 beq cfrx_mask_eval
 lda maskv
 ora #$08
 sta maskv
cfrx_mask_eval:
 lda maskv
 cmp #$01
 beq clfr_one0
 cmp #$02
 beq clfr_one1
 cmp #$04
 beq clfr_one2
 cmp #$08
 beq clfr_one3
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_right_outside_x
 beq cfrx_v1
 jsr clip_v0_right
cfrx_v1:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_right_outside_x
 beq cfrx_v2
 jsr clip_v1_right
cfrx_v2:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_right_outside_x
 beq cfrx_v3
 jsr clip_v2_right
cfrx_v3:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_right_outside_x
 beq cfrx_done
 jsr clip_v3_right
cfrx_done:
 rts

clfr_one0:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy0
 sta clip2_vy0
 lda #PROJ_SCREEN_MAX_X
 sta vx0
 sta clip2_vx0
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 lda sx,x
 sta vx2
 lda sy,x
 sta vy2
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 lda sx,x
 sta vx3
 sta clip2_vx1
 lda sy,x
 sta vy3
 sta clip2_vy1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfr_one1:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy2
 lda #PROJ_SCREEN_MAX_X
 sta vx2
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 lda sx,x
 sta vx3
 sta clip2_vx1
 lda sy,x
 sta vy3
 sta clip2_vy1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfr_one2:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy2
 lda #PROJ_SCREEN_MAX_X
 sta vx2
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy3
 sta clip2_vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx3
 sta clip2_vx1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfr_one3:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy3
 sta clip2_vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx3
 sta clip2_vx1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta clip2_vy2
 lda #PROJ_SCREEN_MAX_X
 sta clip2_vx2
 rts

clip_face_left_x_simple:
 lda #$00
 sta maskv
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_left_outside_x
 beq cflx_mask_v1
 lda maskv
 ora #$01
 sta maskv
cflx_mask_v1:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_left_outside_x
 beq cflx_mask_v2
 lda maskv
 ora #$02
 sta maskv
cflx_mask_v2:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_left_outside_x
 beq cflx_mask_v3
 lda maskv
 ora #$04
 sta maskv
cflx_mask_v3:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_left_outside_x
 beq cflx_mask_eval
 lda maskv
 ora #$08
 sta maskv
cflx_mask_eval:
 lda maskv
 cmp #$01
 beq clfl_one0
 cmp #$02
 beq clfl_one1
 cmp #$04
 beq clfl_one2
 cmp #$08
 beq clfl_one3
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_left_outside_x
 beq cflx_v1
 jsr clip_v0_left
cflx_v1:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_left_outside_x
 beq cflx_v2
 jsr clip_v1_left
cflx_v2:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_left_outside_x
 beq cflx_v3
 jsr clip_v2_left
cflx_v3:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_left_outside_x
 beq cflx_done
 jsr clip_v3_left
cflx_done:
 rts

clfl_one0:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy0
 sta clip2_vy0
 lda #$00
 sta vx0
 sta clip2_vx0
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy1
 lda #$00
 sta vx1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 lda sx,x
 sta vx2
 lda sy,x
 sta vy2
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 lda sx,x
 sta vx3
 sta clip2_vx1
 lda sy,x
 sta vy3
 sta clip2_vy1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfl_one1:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy1
 lda #$00
 sta vx1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy2
 lda #$00
 sta vx2
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 lda sx,x
 sta vx3
 sta clip2_vx1
 lda sy,x
 sta vy3
 sta clip2_vy1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfl_one2:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy2
 lda #$00
 sta vx2
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy3
 sta clip2_vy1
 lda #$00
 sta vx3
 sta clip2_vx1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfl_one3:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy3
 sta clip2_vy1
 lda #$00
 sta vx3
 sta clip2_vx1
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta clip2_vy2
 lda #$00
 sta clip2_vx2
 rts

clip_v0_right:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_x_inside
 bne cv0r_prev
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_x_inside
 bne cv0r_next
 lda #PROJ_SCREEN_MAX_X
 sta vx0
 rts
cv0r_prev:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy0
 lda #PROJ_SCREEN_MAX_X
 sta vx0
 rts
cv0r_next:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy0
 lda #PROJ_SCREEN_MAX_X
 sta vx0
 rts

clip_v1_right:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_x_inside
 bne cv1r_prev
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_x_inside
 bne cv1r_next
 lda #PROJ_SCREEN_MAX_X
 sta vx1
 rts
cv1r_prev:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx1
 rts
cv1r_next:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx1
 rts

clip_v2_right:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_x_inside
 bne cv2r_prev
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_x_inside
 bne cv2r_next
 lda #PROJ_SCREEN_MAX_X
 sta vx2
 rts
cv2r_prev:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy2
 lda #PROJ_SCREEN_MAX_X
 sta vx2
 rts
cv2r_next:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy2
 lda #PROJ_SCREEN_MAX_X
 sta vx2
 rts

clip_v3_right:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_x_inside
 bne cv3r_prev
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_x_inside
 bne cv3r_next
 lda #PROJ_SCREEN_MAX_X
 sta vx3
 rts
cv3r_prev:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy3
 lda #PROJ_SCREEN_MAX_X
 sta vx3
 rts
cv3r_next:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_inside_right
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy3
 lda #PROJ_SCREEN_MAX_X
 sta vx3
 rts

clip_v0_left:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_x_inside
 bne cv0l_prev
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_x_inside
 bne cv0l_next
 lda #$00
 sta vx0
 rts
cv0l_prev:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy0
 lda #$00
 sta vx0
 rts
cv0l_next:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy0
 lda #$00
 sta vx0
 rts

clip_v1_left:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_x_inside
 bne cv1l_prev
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_x_inside
 bne cv1l_next
 lda #$00
 sta vx1
 rts
cv1l_prev:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy1
 lda #$00
 sta vx1
 rts
cv1l_next:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy1
 lda #$00
 sta vx1
 rts

clip_v2_left:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_x_inside
 bne cv2l_prev
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_x_inside
 bne cv2l_next
 lda #$00
 sta vx2
 rts
cv2l_prev:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy2
 lda #$00
 sta vx2
 rts
cv2l_next:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy2
 lda #$00
 sta vx2
 rts

clip_v3_left:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_x_inside
 bne cv3l_prev
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_x_inside
 bne cv3l_next
 lda #$00
 sta vx3
 rts
cv3l_prev:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy3
 lda #$00
 sta vx3
 rts
cv3l_next:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr clip_load_inside_left
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy3
 lda #$00
 sta vx3
 rts

clip_x_inside:
 jsr clip_right_outside_x
 bne cxi_no
 jsr clip_left_outside_x
 bne cxi_no
 lda #$01
 rts
cxi_no:
 lda #$00
 rts

clip_right_outside_x:
 lda pxrawhi,x
 bmi crox_no
 bne crox_yes
 lda pxrawlo,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs crox_yes
crox_no:
 lda #$00
 rts
crox_yes:
 lda #$01
 rts

clip_left_outside_x:
 lda pxrawhi,x
 bmi clox_yes
 lda #$00
 rts
clox_yes:
 lda #$01
 rts

clip_load_inside_right:
 lda pxrawlo,x
 sta clip_in_x
 lda sy,x
 sta clip_in_y
 lda #PROJ_SCREEN_MAX_X
 sec
 sbc clip_in_x
 sta clip_num
 rts

clip_load_outside_right:
 lda sy,x
 sta clip_out_y
 lda pxrawlo,x
 sec
 sbc clip_in_x
 sta clip_den
 lda pxrawhi,x
 sbc #$00
 beq clor_check_zero
 lda #$ff
 sta clip_den
 rts
clor_check_zero:
 lda clip_den
 bne clor_done
 lda #$01
 sta clip_den
clor_done:
 rts

clip_load_inside_left:
 lda pxrawlo,x
 sta clip_in_x
 sta clip_num
 lda sy,x
 sta clip_in_y
 rts

clip_load_outside_left:
 lda sy,x
 sta clip_out_y
 lda #$00
 sec
 sbc pxrawlo,x
 clc
 adc clip_in_x
 bcc clol_store
 lda #$ff
clol_store:
 bne clol_nonzero
 lda #$01
clol_nonzero:
 sta clip_den
 rts

clip_interp_y:
 sec
 lda clip_out_y
 sbc clip_in_y
 sta dy1v
 bpl ciy_positive
 eor #$ff
 clc
 adc #$01
 ldx clip_num
 jsr clip_mul_u8
 lda clip_den
 bne ciy_neg_den_ready
 lda #$01
ciy_neg_den_ready:
 sta p1lo
 lda #$00
 sta p1hi
 jsr div16u
 lda clip_in_y
 sec
 sbc prodlo
 bcs ciy_done
 lda #$00
 rts
ciy_positive:
 lda dy1v
 ldx clip_num
 jsr clip_mul_u8
 lda clip_den
 bne ciy_pos_den_ready
 lda #$01
ciy_pos_den_ready:
 sta p1lo
 lda #$00
 sta p1hi
 jsr div16u
 clc
 lda clip_in_y
 adc prodlo
 bcs ciy_max
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcc ciy_done
ciy_max:
 lda #PROJ_SCREEN_MAX_Y
ciy_done:
 rts

clip_mul_u8:
 sta mul16lo
 lda #$00
 sta mul16hi
 stx mul16mul
 lda #$00
 sta prodlo
 sta prodhi
 ldx #$08
cmu8_loop:
 lsr mul16mul
 bcc cmu8_no_add
 clc
 lda prodlo
 adc mul16lo
 sta prodlo
 lda prodhi
 adc mul16hi
 sta prodhi
cmu8_no_add:
 asl mul16lo
 rol mul16hi
 dex
 bne cmu8_loop
 rts
.endif


.if CAMERA_MOVABLE != 0
.if EXPLORER_NEAR_CLIP != 0
explorer_face_near_projected:
 ldy faceidx
.if EXPLORER_NEAR_SKIP_CROSS != 0 || EXPLORER_NEAR_POLY != 0
 lda #$00
 sta near_face_crossing
 sta maskv
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 lda projdone,x
 beq efap_skip_v0
 inc maskv
efap_skip_v0:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 lda projdone,x
 beq efap_skip_v1
 inc maskv
efap_skip_v1:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 lda projdone,x
 beq efap_skip_v2
 inc maskv
efap_skip_v2:
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 cmp #$04
 bne efap_tri_count
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 lda projdone,x
 beq efap_skip_v3
 inc maskv
efap_skip_v3:
 lda maskv
 beq efap_no
 cmp #$04
 beq efap_quad_all_valid
.if EXPLORER_NEAR_POLY != 0
 lda #$01
 sta near_face_crossing
 jmp efap_yes
.else
 jmp efap_no
.endif
efap_quad_all_valid:
.if EXPLORER_NEAR_SKIP_CROSS != 0
 jsr explorer_face_near_skip_guard
 beq efap_no
.endif
 jmp efap_yes
efap_tri_count:
 lda maskv
 beq efap_no
 cmp #$03
 beq efap_tri_all_valid
.if EXPLORER_NEAR_POLY != 0
 lda #$01
 sta near_face_crossing
 jmp efap_yes
.else
 jmp efap_no
.endif
efap_tri_all_valid:
.if EXPLORER_NEAR_SKIP_CROSS != 0
 jsr explorer_face_near_skip_guard
 beq efap_no
.endif
 jmp efap_yes
.else
 lda #$00
 sta near_face_crossing
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 lda projdone,x
 bne efap_yes
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 lda projdone,x
 bne efap_yes
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 lda projdone,x
 bne efap_yes
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 cmp #$04
 bne efap_no
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 lda projdone,x
 bne efap_yes
.endif
efap_no:
 lda #$00
 rts
efap_yes:
 lda #$01
 rts
.if EXPLORER_NEAR_SKIP_CROSS != 0
explorer_face_near_skip_guard:
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr explorer_vertex_near_skip_safe
 beq efns_no
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr explorer_vertex_near_skip_safe
 beq efns_no
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr explorer_vertex_near_skip_safe
 beq efns_no
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne efns_yes
.endif
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr explorer_vertex_near_skip_safe
 beq efns_no
efns_yes:
 lda #$01
 rts
efns_no:
 lda #$00
 rts

explorer_vertex_near_skip_safe:
 lda szhi,x
 bmi evnss_no
 bne evnss_yes
 lda sz,x
 cmp #EXPLORER_NEAR_SKIP_DEPTH
 bcc evnss_no
evnss_yes:
 lda #$01
 rts
evnss_no:
 lda #$00
 rts
.endif
.endif
.endif


.if CAMERA_PLANE_CLIP_PROFILE != 0
; Depth zero belongs to the visible side. Reject only faces whose original
; vertices are all strictly negative. Zero and mixed-sign faces take the
; camera-plane path so zero-depth originals can be projected at depth 1.
camera_plane_face_classify:
 lda #$00
 sta near_face_crossing
 sta maskv
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr camera_plane_classify_vertex
cpfc_v1:
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr camera_plane_classify_vertex
cpfc_v2:
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr camera_plane_classify_vertex
cpfc_count:
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne cpfc_ready
.endif
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr camera_plane_classify_vertex
cpfc_ready:
 lda maskv
 and #$01
 beq cpfc_hidden
 lda maskv
 and #$06
 beq cpfc_visible
 lda #$01
 sta near_face_crossing
cpfc_visible:
 lda #$01
 rts
cpfc_hidden:
 lda #$00
 rts
.endif

.if POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0
load_face_visible:
.if CAMERA_PLANE_CLIP_PROFILE != 0
 jsr camera_plane_face_classify
 beq lfv_hidden
 lda near_face_crossing
 beq lfv_camera_plane_facing_done
 sec ; demo Q8: facing checked after clipping
 nop
 nop
 bcs lfv_camera_plane_facing_done
 ; A zero-depth boundary with no strictly negative original vertex is the
 ; coplanar/touching case. Keep it visible even if Q6 normal quantization
 ; leaves a one-unit positive dot residue.
 lda maskv
 and #$02
 bne lfv_hidden
lfv_camera_plane_facing_done:
.endif
.if MODE3_LATE_NEAR_NO_POLY != 0
 lda #$00
 sta near_face_crossing
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
.if CAMERA_MOVABLE != 0
 lda projdone,x
.else
 jsr vertex_depth_safe
.endif
 beq lfv_hidden
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
.if CAMERA_MOVABLE != 0
 lda projdone,x
.else
 jsr vertex_depth_safe
.endif
 beq lfv_hidden
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
.if CAMERA_MOVABLE != 0
 lda projdone,x
.else
 jsr vertex_depth_safe
.endif
 beq lfv_hidden
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne lfv_mode3_late_near_valid
.endif
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
.if CAMERA_MOVABLE != 0
 lda projdone,x
.else
 jsr vertex_depth_safe
.endif
 beq lfv_hidden
lfv_mode3_late_near_valid:
.endif
.if CAMERA_MOVABLE != 0
.if CAMERA_PLANE_CLIP_PROFILE = 0
.if EXPLORER_NEAR_CLIP != 0
 jsr explorer_face_near_projected
 beq lfv_hidden
.else
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 lda projdone,x
 beq lfv_hidden
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 lda projdone,x
 beq lfv_hidden
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 lda projdone,x
 beq lfv_hidden
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 cmp #$04
 bne lfv_explorer_valid
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 lda projdone,x
 beq lfv_hidden
lfv_explorer_valid:
.endif
.endif
.if WORLD_GROUND_OCCLUDE != 0
 jsr ground_face_visible
 beq lfv_hidden
.endif
.endif
.if WORLD_GROUND_PLANE_CLIP != 0 && CAMERA_MOVABLE = 0
 jsr ground_face_visible
 beq lfv_hidden
.endif
.if FACE_CULL_PREP != 0
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 lda shared_fv0
.else
 lda face0,y
.endif
 tax
 lda rxbuf,x
 sta vx0
 lda rybuf,x
 eor #$ff
 clc
 adc #$01
 sta vy0
.if MESH_SOURCE_SHARING_RUNTIME != 0
 lda shared_fv1
.else
 lda face1,y
.endif
 tax
 lda rxbuf,x
 sta vx1
 lda rybuf,x
 eor #$ff
 clc
 adc #$01
 sta vy1
.if MESH_SOURCE_SHARING_RUNTIME != 0
 lda shared_fv2
.else
 lda face2,y
.endif
 tax
 lda rxbuf,x
 sta vx2
 lda rybuf,x
 eor #$ff
 clc
 adc #$01
 sta vy2
lfv_cull:
.if FORCE_FACE_RENDER = 0
.if CAMERA_PLANE_CLIP_PROFILE != 0
 lda near_face_crossing
 bne lfv_visible
.endif
.if EXPLORER_NEAR_POLY != 0
 lda near_face_crossing
 bne lfv_visible
.endif
 sec ; Q8 perspective winding is checked after clipping
 nop
 nop
 bcc lfv_hidden
.endif
.endif
lfv_visible:
.if SCENE_OBJECT_COUNT != 0
.if CAMERA_PLANE_CLIP_PROFILE = 0
.if EXPLORER_NEAR_POLY != 0
 lda near_face_crossing
 bne lfv_depth_ok
.endif
 jsr face_depth_safe
 beq lfv_hidden
lfv_depth_ok:
.endif
.endif
.if FLAT_DYNAMIC_SHADE != 0 && DYNAMIC_LIGHT != 0
.if SCENE_OBJECT_COUNT != 0
 ldy faceidx
 jsr update_face_shade
.else
 lda shade_dirty
 beq lfv_shade_done
 ldy faceidx
 jsr update_face_shade
.endif
lfv_shade_done:
.endif
.if STANDARD_PROJECT_VERTEX != 0
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr project_vertex
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr project_vertex
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr project_vertex
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne lfv_bucket
.endif
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr project_vertex
lfv_bucket:
.else
lfv_bucket:
.endif
.if SCENE_OBJECT_COUNT != 0
 ldy faceidx
 sty sortj
 jsr load_face_y
 bcc lfv_hidden
.if MODE2_FACE_BUCKET_PIPELINE != 0
 jsr mode2_screen_winding_visible
 bcc lfv_hidden
.endif
.if CONSERVATIVE_SLIVER_CULL != 0
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 bne lfv_skip_sliver
.endif
 jsr face_far_depth
 bne lfv_skip_sliver
 jsr face_conservative_sliver
 beq lfv_hidden
lfv_skip_sliver:
.endif
.endif
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
 jsr engine_mode3_cache_loaded_face_prepare
.endif
 jmp bucket_visible_face
lfv_hidden:
 clc
 rts

.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
; Cache only faces whose projected vertices are already fully inside the viewport.
; Near/screen-clipped faces remain on load_face_y, preserving the complete fallback.
engine_mode3_cache_loaded_face_prepare:
.if EXPLORER_NEAR_POLY != 0
 lda near_face_crossing
 bne sm3cfp_done
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 bne sm3cfp_done
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
 lda clip_second_pending
 bne sm3cfp_done
.endif
 ; Test the original projected vertices, not the possibly clipped vx/vy copy.
 ; This guarantees that the draw-pass fastload can safely reload sx/sy directly.
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs sm3cfp_done
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs sm3cfp_done
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs sm3cfp_done
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs sm3cfp_done
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs sm3cfp_done
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs sm3cfp_done
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne sm3cfp_store
.endif
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs sm3cfp_done
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs sm3cfp_done
sm3cfp_store:
 ldy faceidx
 lda #$01
 sta frame_face_prepare,y
 lda spanw
 sta frame_face_spanw,y
 lda spanh
 sta frame_face_spanh,y
sm3cfp_done:
 rts
.endif
.endif

.if SCENE_OBJECT_COUNT != 0
.if FACE_RENDER_ENABLE != 0
face_far_depth:
 ldy sortj
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 lda szhi,x
 beq ffd_no
 bmi ffd_no
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 lda szhi,x
 beq ffd_no
 bmi ffd_no
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 lda szhi,x
 beq ffd_no
 bmi ffd_no
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 cmp #$04
 bne ffd_yes
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 lda szhi,x
 beq ffd_no
 bmi ffd_no
ffd_yes:
 lda #$01
 rts
ffd_no:
 lda #$00
 rts

.if CONSERVATIVE_SLIVER_CULL != 0
face_conservative_sliver:
 lda spanh
 cmp #(CONSERVATIVE_SLIVER_THIN_SPAN + 1)
 bcs fcs_check_vertical
 lda spanw
 cmp #CONSERVATIVE_SLIVER_LONG_SPAN
 bcs fcs_yes
 lda #$00
 rts
fcs_check_vertical:
 lda spanw
 cmp #(CONSERVATIVE_SLIVER_THIN_SPAN + 1)
 bcs fcs_yes
 lda spanh
 cmp #CONSERVATIVE_SLIVER_LONG_SPAN
 bcs fcs_yes
 lda #$00
 rts
fcs_yes:
 lda #$01
 rts

.endif
.endif

face_depth_safe:
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv0
.else
 ldx face0,y
.endif
 jsr vertex_depth_safe
 beq fds_no
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv1
.else
 ldx face1,y
.endif
 jsr vertex_depth_safe
 beq fds_no
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv2
.else
 ldx face2,y
.endif
 jsr vertex_depth_safe
 beq fds_no
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne fds_yes
.endif
 ldy faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx shared_fv3
.else
 ldx face3,y
.endif
 jsr vertex_depth_safe
 beq fds_no
fds_yes:
 lda #$01
 rts
fds_no:
 lda #$00
 rts

vertex_depth_safe:
 lda szhi,x
 bmi vds_no
 bne vds_yes
 lda sz,x
 cmp #CAMERA_FACE_MIN_DEPTH
 bcc vds_no
vds_yes:
 lda #$01
 rts
vds_no:
 lda #$00
 rts

.if WIRE_RENDER_ENABLE != 0
wire_vertex_drawable:
.if CAMERA_MOVABLE != 0
 lda projdone,x
 beq wvd_no
.endif
 jsr vertex_depth_safe
 beq wvd_no
 lda #$01
 rts
wvd_no:
 lda #$00
 rts

.if EXPLORER_SCREEN_CLIP_POLY != 0 && EXPLORER_SCREEN_RAW != 0
clip_wire_edge_screen:
 ldx clip_prev_idx
 lda pxrawlo,x
 sta clip_a_xlo
 lda pxrawhi,x
 sta clip_a_xhi
 lda pyrawlo,x
 sta clip_a_ylo
 lda pyrawhi,x
 sta clip_a_yhi
 lda sx,x
 sta clip_a_x
 lda sy,x
 sta clip_a_y
.if WIRE_RENDER_ENABLE != 0
 lda #$00
 sta clip_a_flag
.endif
 ldx clip_cur_idx
 lda pxrawlo,x
 sta clip_a_xlo + 1
 lda pxrawhi,x
 sta clip_a_xhi + 1
 lda pyrawlo,x
 sta clip_a_ylo + 1
 lda pyrawhi,x
 sta clip_a_yhi + 1
 lda sx,x
 sta clip_a_x + 1
 lda sy,x
 sta clip_a_y + 1
.if WIRE_RENDER_ENABLE != 0
 lda #$00
 sta clip_a_flag + 1
.endif
 lda #$02
 sta clip_a_count
 jsr clip_poly_clip_screen_current
 lda clip_a_count
 cmp #$02
 bcc cwes_no
 lda clip_a_x
 sta ex0
 lda clip_a_y
 sta ey0
 lda clip_a_x + 1
 sta ex1
 lda clip_a_y + 1
 sta ey1
 lda #$01
 rts
cwes_no:
 lda #$00
 rts
.endif
.endif

.endif
.if FORCE_FACE_RENDER = 0
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && (POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || HIDDEN_WIRE_ENABLE != 0 || LOWRES_TRACE_ENABLE != 0) && (POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || HIDDEN_WIRE_ENABLE != 0 || WIRE_RENDER_ENABLE = 0 || WIRE_MESH_COUNT = 0) && (POLY_FILL_ENABLE = 0 || WIRE_DEPTH_SORT_ENABLE = 0)
.if * > $5c00
 .error "High-basic-v2 middle segment overlaps video buffer A"
.endif
.if MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0

m3_code_begin = *
; M3 shade topology is emitted by the unchanged Mode 6 builder.
; Point-light dot/intensity follow M2; no specular/reflectivity.
m3_update_shades:
 rts ; demo-only static vertex light
m3_update_shades_end = *

m3_interp_clip_q:
 sec
 lda m3_clip_q_out
 sbc m3_clip_q_in
 sta p1lo
 lda #0
 sbc #0
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 clc
 lda p1lo
 adc m3_clip_q_in
 sta m3_clip_q_result
 rts
m3_interp_clip_q_end = *

m3_prepare_span:
 sec
 lda rightval
 sbc leftval
 sta m7_den
 ldy yrow
 lda m3_leftq,y
 sta m3_qcur
 ldx m3_rightq,y
 jsr m7_dda_setup
 lda m7_q
 sta m3_qstep
 lda m7_r
 sta m3_qrem
 lda m7_dir
 sta m3_qdir
 lda #0
 sta m3_qerr
 rts
m3_prepare_span_end = *

m3_advance_q:
 clc
 lda m3_qcur
 adc m3_qstep
 sta m3_qcur
 clc
 lda m3_qerr
 adc m3_qrem
 bcs m3_q_correct
 cmp m7_den
 bcc m3_q_store
m3_q_correct:
 sec
 sbc m7_den
 sta m3_qerr
 clc
 lda m3_qcur
 adc m3_qdir
 sta m3_qcur
 rts
m3_q_store:
 sta m3_qerr
 rts
m3_advance_q_end = *

; Exact M2 compositor equation, evaluated with the current sample Q.
; E = (Q >> 1) + 8*(texel-1). Only shifts/adds, no divide/multiply.
; M3.1 C: local texel is neutral at Q=10..22.
; Q<=6: (1,1,2), Q>=26: (2,3,3). Three intermediate Q per transition.
; Existing scratch; no LUT or extra RAM. Incoming A is texel 1..3.
m3_composite:
 sta m3_base
 ldx m3_qcur
 cpx #10
 bcc m31_c_low
 cpx #23
 bcc m31_c_return
 cmp #3
 beq m31_c_return
 cpx #26
 bcs m31_c_bright
 txa
 sec
 sbc #22
 jmp m31_c_transition
m31_c_low:
 cmp #1
 beq m31_c_return
 dec m3_base
 cpx #7
 bcc m31_c_stable
 txa
 sec
 sbc #6
m31_c_transition:
 asl
 asl
 sta m3_threshold
 lda gouraud_scan_x
 and #3
 ora m2_bayer_row
 tay
 lda m3_threshold
 cmp m2_bayer,y
 lda m3_base
 adc #0
m31_c_return:
 rts
m31_c_bright:
 inc m3_base
m31_c_stable:
 lda m3_base
 rts
m31_c_instructions_end = *
m3_composite_end = *

; Saturated signed-byte result for A=-128..127, X=-64..64 (Q6 matrix).
; mulsign retains the mathematical sign, including a result truncated to zero.
m31_light_mul_s6:
 jsr mul_s6
 bit mulsign
 bmi m31_light_mul_negative
 cmp #$80
 bcc m31_light_mul_done
 lda #$7f
 rts
m31_light_mul_negative:
 cmp #$80
 bcs m31_light_mul_done
 cmp #0
 beq m31_light_mul_done
 lda #$80
m31_light_mul_done:
 rts
m31_light_mul_s6_end = *

; Q8-only: old integer polygon clip retired.
gouraud_build_edge_shades_v_q = hp_unreachable
gbes_init_v_q = hp_unreachable
gbes_edges_v_q = hp_unreachable
.if HAS_TRI_FACES != 0
.endif
gbes_close_triangle_v_q = hp_unreachable
gbes_close_common_v_q = hp_unreachable
gouraud_trace_shade_edge_v_q = hp_unreachable
gtse_ordered_v_q = hp_unreachable
r1_x_bias_done_v_q = hp_unreachable
gtse_loop_v_q = hp_unreachable
r1_edge_sample_v_q = hp_unreachable
demo_edge_x_v_correct_q = hp_unreachable
demo_edge_x_v_store_q = hp_unreachable
demo_edge_x_v_done_q = hp_unreachable
demo_edge_s_v_correct_q = hp_unreachable
demo_edge_s_v_store_q = hp_unreachable
demo_edge_s_v_done_q = hp_unreachable
gtse_horizontal_v_q = hp_unreachable
gtse_done_v_q = hp_unreachable
gouraud_store_edge_sample_v_q = hp_unreachable
seam_in_range_v_q = hp_unreachable
seam_right_check_v_q = hp_unreachable
seam_done_v_q = hp_unreachable
m3_code_end = *

m3_metadata_begin = *
gouraud_shade_value:
 .byte 11,26,16,10,12,17,20,13,16,13,14,18,18,24,13,13,14,10,10,12,19,11,12,14,19,25,22,10,9,10,17,8,8,8,8,18,17,25,25,24,19,22,13,13,20,5,5,5,5,5,5,5,5,18,18,18,18,18,18,18,18,32,32,32,32,24,10,9,16,17,11,11,20,15,13,12,14,8,8,8,8,8,8,8,8,14,24,22,19,13,10,10,16,10,9,9,5,5,5,5,5,5,5,5,18,18,18,18,18,18,18,18,32,32,32,32
gouraud_face_shade0:
 .byte $00,$00,$04,$04,$08,$08,$0C,$0C,$10,$10,$14,$14,$14,$14,$14,$14
 .byte $1B,$1B,$1F,$1F,$23,$23,$27,$27,$29,$29,$2D,$2D,$31,$31,$35,$35
 .byte $39,$39,$3D,$3D,$41,$41,$45,$45,$49,$49,$4D,$4D,$51,$51,$55,$55
 .byte $55,$55,$55,$55,$5C,$5C,$60,$60,$64,$64,$68,$68,$6C,$6C,$70,$70
gouraud_face_shade1:
 .byte $01,$02,$05,$06,$09,$0A,$0D,$0E,$11,$12,$15,$17,$18,$19,$1A,$16
 .byte $1C,$1D,$20,$21,$24,$25,$28,$18,$2A,$2B,$2E,$2F,$32,$33,$36,$37
 .byte $3A,$3B,$3E,$3F,$42,$43,$46,$47,$4A,$4B,$4E,$4F,$52,$53,$56,$58
 .byte $59,$5A,$5B,$57,$5D,$5E,$61,$62,$65,$66,$69,$6A,$6D,$6E,$71,$72
gouraud_face_shade2:
 .byte $02,$03,$06,$07,$0A,$0B,$0E,$0F,$12,$13,$16,$15,$17,$18,$19,$1A
 .byte $1D,$1E,$21,$22,$25,$26,$18,$19,$2B,$2C,$2F,$30,$33,$34,$37,$38
 .byte $3B,$3C,$3F,$40,$43,$44,$47,$48,$4B,$4C,$4F,$50,$53,$54,$57,$56
 .byte $58,$59,$5A,$5B,$5E,$5F,$62,$63,$66,$67,$6A,$6B,$6E,$6F,$72,$73
m3_metadata_end = *
m3_buffers_begin = *
m3_leftq: .fill VIEWPORT_ROW_CAPACITY,0
m3_rightq: .fill VIEWPORT_ROW_CAPACITY,0
m3_clip_a_q: .fill 12,0
m3_q0: .byte 0
m3_q1: .byte 0
m3_q2: .byte 0
m3_q3: .byte 0
m3_clip_q_in: .byte 0
m3_clip_q_out: .byte 0
m3_clip_q_result: .byte 0
m3_qcur: .byte 0
m3_qstep: .byte 0
m3_qrem: .byte 0
m3_qdir: .byte 0
m3_qerr: .byte 0
m3_threshold: .byte 0
m3_base: .byte 0
m3_buffers_end = *
mode3_high_basic_middle_end = *
* = HIGH_BASIC_V2_RELOCATED_CODE_BASE
mode3_high_basic_relocated_code_start = *
.else
.if GRAPHICS_MODE = $02 && CAMERA_MOVABLE != 0
 ; Retain the validated Mode 2 middle-segment endpoint after the depth split.
 .fill 7, $ea
.endif
* = $a000
.endif
.endif
.if VIC_COLOR_POLICY_OVERLAY != 0
vic_color_policy_overlay_conflicts:
 lda drawbuf
 bne vcpo_buffer_b
 ldx #$00
vcpo_a_pages:
 lda vic_color_conflict_map,x
 beq vcpo_a_100
 lda #$ff
 sta $5c00,x
 lda #$0a
 sta $d800,x
vcpo_a_100:
 lda vic_color_conflict_map+$0100,x
 beq vcpo_a_200
 lda #$ff
 sta $5d00,x
 lda #$0a
 sta $d900,x
vcpo_a_200:
 lda vic_color_conflict_map+$0200,x
 beq vcpo_a_next
 lda #$ff
 sta $5e00,x
 lda #$0a
 sta $da00,x
vcpo_a_next:
 inx
 bne vcpo_a_pages
 ldx #$00
vcpo_a_tail:
 lda vic_color_conflict_map+$0300,x
 beq vcpo_a_tail_next
 lda #$ff
 sta $5f00,x
 lda #$0a
 sta $db00,x
vcpo_a_tail_next:
 inx
 cpx #$e8
 bne vcpo_a_tail
 rts
vcpo_buffer_b:
 ldx #$00
vcpo_b_pages:
 lda vic_color_conflict_map,x
 beq vcpo_b_100
 lda #$ff
 sta SCREEN_B_BASE,x
 lda #$0a
 sta $d800,x
vcpo_b_100:
 lda vic_color_conflict_map+$0100,x
 beq vcpo_b_200
 lda #$ff
 sta SCREEN_B_BASE+$0100,x
 lda #$0a
 sta $d900,x
vcpo_b_200:
 lda vic_color_conflict_map+$0200,x
 beq vcpo_b_next
 lda #$ff
 sta SCREEN_B_BASE+$0200,x
 lda #$0a
 sta $da00,x
vcpo_b_next:
 inx
 bne vcpo_b_pages
 ldx #$00
vcpo_b_tail:
 lda vic_color_conflict_map+$0300,x
 beq vcpo_b_tail_next
 lda #$ff
 sta SCREEN_B_BASE+$0300,x
 lda #$0a
 sta $db00,x
vcpo_b_tail_next:
 inx
 cpx #$e8
 bne vcpo_b_tail
 rts
.endif
.if WIRE_TWO_COLOR_MULTIMATERIAL_ENABLE != 0
activate_wire_two_color_palette:
 lda #WIRE_TWO_COLOR_SCREEN_BYTE
 sta material_screen_cur
 lda #WIRE_TWO_COLOR_FIXED_COLOR_RAM
 sta material_color_cur
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 rts
.endif

.if WIRE_TWO_COLOR_MODE1_ENABLE != 0
load_wire_two_color_edge_pattern_y:
 lda wire_edge_slot,y
 cmp #$02
 beq lwtcep_slot10
 lda #$55
 sta fillbyte
 rts
lwtcep_slot10:
 lda #$aa
 sta fillbyte
 rts
.endif

.if WIRE_TWO_COLOR_MODE2_ENABLE != 0
load_wire_two_color_face_pattern_y:
 lda wire_face_slot,y
 cmp #$02
 beq lwtcfp_slot10
 lda #$55
 sta fillbyte
 rts
lwtcfp_slot10:
 lda #$aa
 sta fillbyte
 rts
.endif

.if WIRE_EDGE_SOLID_COLOR_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0
load_wire_edge_solid_color_x:
 lda wire_edge_solid_color,x
 sta material_color_cur
 lda #$00
 sta material_screen_cur
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 lda #$ff
 sta fillbyte
 rts
.endif
.if LOWRES_TRACE_ENABLE != 0
clear_current_bitmap_lowres_trace:
 jsr copy_lowres_trace_rows_from_front
 lda drawbuf
 bne ccblt_b
ccblt_a:
 ldx #$00
ccblt_a_row:
 stx yrow
 jsr lowres_row_selected
 bne ccblt_a_next
 ldx yrow
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 jsr clear_logical_bitmap_row
ccblt_a_next:
 ldx yrow
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ccblt_a_row
 rts
ccblt_b:
 ldx #$00
ccblt_b_row:
 stx yrow
 jsr lowres_row_selected
 bne ccblt_b_next
 ldx yrow
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
 jsr clear_logical_bitmap_row
ccblt_b_next:
 ldx yrow
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ccblt_b_row
 rts

clear_logical_bitmap_row:
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr0lo
 bcc clbr_origin0_ok
 inc ptr0hi
clbr_origin0_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr1lo
 bcc clbr_origin1_ok
 inc ptr1hi
clbr_origin1_ok:
.endif
 lda #CAMERA_VIEWPORT_CELL_WIDTH
 sta p1lo
clbr_loop:
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc clbr_ptr0_ok
 inc ptr0hi
clbr_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc clbr_ptr1_ok
 inc ptr1hi
clbr_ptr1_ok:
 dec p1lo
 bne clbr_loop
 rts

copy_lowres_trace_rows_from_front:
 lda drawbuf
 bne cltr_b_dest
cltr_a_dest:
 ldx #$00
cltr_a_loop:
 stx yrow
 jsr lowres_row_selected
 beq cltr_a_next
 ldx yrow
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
 jsr copy_logical_bitmap_row
cltr_a_next:
 ldx yrow
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne cltr_a_loop
 rts
cltr_b_dest:
 ldx #$00
cltr_b_loop:
 stx yrow
 jsr lowres_row_selected
 beq cltr_b_next
 ldx yrow
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jsr copy_logical_bitmap_row
cltr_b_next:
 ldx yrow
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne cltr_b_loop
 rts

copy_logical_bitmap_row:
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 clc
 lda row0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta row0lo
 bcc clbr_copy_src0_origin_ok
 inc row0hi
clbr_copy_src0_origin_ok:
 clc
 lda row1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta row1lo
 bcc clbr_copy_src1_origin_ok
 inc row1hi
clbr_copy_src1_origin_ok:
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr0lo
 bcc clbr_copy_dst0_origin_ok
 inc ptr0hi
clbr_copy_dst0_origin_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr1lo
 bcc clbr_copy_dst1_origin_ok
 inc ptr1hi
clbr_copy_dst1_origin_ok:
.endif
 lda #CAMERA_VIEWPORT_CELL_WIDTH
 sta p1lo
clbr_copy_loop:
 ldy #$00
 lda (row0lo),y
 sta (ptr0lo),y
 lda (row1lo),y
 sta (ptr1lo),y
 clc
 lda row0lo
 adc #$08
 sta row0lo
 bcc clbr_src0_ok
 inc row0hi
clbr_src0_ok:
 clc
 lda row1lo
 adc #$08
 sta row1lo
 bcc clbr_src1_ok
 inc row1hi
clbr_src1_ok:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc clbr_dst0_ok
 inc ptr0hi
clbr_dst0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc clbr_dst1_ok
 inc ptr1hi
clbr_dst1_ok:
 dec p1lo
 bne clbr_copy_loop
 rts
.endif
.if MODE2_FACE_BUCKET_PIPELINE = 0
.if CAMERA_SPACE_FACE_CULL_SUPPORT != 0
.if MEMORY_LAYOUT_HIGH_BASIC_V2 = 0
camera_plane_cull_low_return = *
* = $9500
camera_plane_cull_code_start = *
.endif
.endif
.if CAMERA_PLANE_CLIP_PROFILE != 0

; maskv: bit 0 = at least one depth >= 0, bit 1 = at least one depth < 0,
; bit 2 = at least one depth = 0.
camera_plane_classify_vertex:
 lda vzrawhi,x
 bmi cpcv_negative
 bne cpcv_positive
 lda vzrawlo,x
 beq cpcv_zero
cpcv_positive:
 lda maskv
 ora #$01
 sta maskv
 rts
cpcv_zero:
 lda maskv
 ora #$05
 sta maskv
 rts
cpcv_negative:
 lda maskv
 ora #$02
 sta maskv
 rts

camera_plane_original_on_plane:
 lda vzrawhi,x
 bne cpoop_no
 lda vzrawlo,x
 bne cpoop_no
 lda #$01
 rts
cpoop_no:
 lda #$00
 rts

; A source vertex exactly on the camera plane is retained, but its effective
; projection depth is 1 WU. X still contains the original vertex index.
camera_plane_append_original_zero:
 stx clip_out_x
 ldy clip_a_count
 lda vxrawlo,x
 sta clip_a_vxlo,y
 lda vxrawhi,x
 sta clip_a_vxhi,y
 lda vyrawlo,x
 sta clip_a_vylo,y
 lda vyrawhi,x
 sta clip_a_vyhi,y
 lda #$01
 sta clip_a_vzlo,y
 lda #$00
 sta clip_a_vzhi,y
 lda clip_a_count
 sta camera_plane_bucket_ready
 jsr camera_plane_project_original_intersection
.if MODE7_UV_CARRIER != 0
 ldx clip_cur_idx
 lda m3_q0,x
 ldy clip_a_count
 sta m3_clip_a_q,y
 lda m7_v0,x
 ldy clip_a_count
 sta m7_clip_a_v,y
 lda gouraud_vshade0,x
 ldy clip_a_count
 sta clip_a_shade,y
.endif
.if WIRE_RENDER_ENABLE != 0
 ldy clip_a_count
 lda #$00
 sta clip_a_flag,y
.endif
 inc clip_a_count
 rts
.endif

; The build derives this oriented normal from the first non-collinear
; original face triplet. Rotate it into camera space, then dot it with an
; original camera-space vertex. The sign is calibrated against the ordinary
; screen-space winding at a safe positive depth: negative is the visible side.
; Stable culling reuses the Mode 4/5 shading normal and keeps a one-WU
; geometric edge band visible. There is no frame memory or hysteresis.
.if CAMERA_SPACE_FACE_CULL_SUPPORT != 0
.if STABLE_FACE_CULL_PROFILE != 0
; The folded object-to-camera matrix is captured once per rendered object.
; This keeps the original face normal and its camera-space point in the same
; coordinate system without adding per-face transformed-normal tables.
.if EXPLORER_MATRIX_FOLD != 0
stable_face_cull_cache_matrix:
 lda m00
 sta stable_face_cull_m00
 lda m01
 sta stable_face_cull_m01
 lda m02
 sta stable_face_cull_m02
 lda m10
 sta stable_face_cull_m10
 lda m11
 sta stable_face_cull_m11
 lda m12
 sta stable_face_cull_m12
 lda m20
 sta stable_face_cull_m20
 lda m21
 sta stable_face_cull_m21
 lda m22
 sta stable_face_cull_m22
 rts
.endif

; Non-folded explorer builds already have the object matrix in m00..m22 and
; the current camera sine/cosine values in sin?v/cos?v.  Fold the three
; matrix columns into the same cache without changing the object matrix or
; the coordinate-term tables used by vertex transformation.
.if CAMERA_MOVABLE != 0 && EXPLORER_MATRIX_FOLD = 0
stable_face_cull_prepare_movable_matrix:
 ldy #$02
sfcpmm_column:
 lda m00,y
 sta rx0
 lda m10,y
 sta ry0
 lda m20,y
 sta rz0

 ; Camera yaw.
 lda rx0
 ldx cosyv
 jsr mul_s6
 sta t1
 lda rz0
 ldx sinyv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta vx3
 lda rx0
 ldx sinyv
 jsr mul_s6
 sta t1
 lda rz0
 ldx cosyv
 jsr mul_s6
 clc
 adc t1
 sta rz0
 lda vx3
 sta rx0

 ; Camera pitch, with exactly the same compile/runtime gates as the vertex
 ; transformer.
.if ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH != 0
 lda explorer_cam_pitch
 beq sfcpmm_pitch_done
.endif
.if ENGINE_CAMERA_WALK_LITE_PITCH_RUNTIME_ACTIVE != 0
 lda explorer_cam_pitch
 beq sfcpmm_pitch_done
.else
.if CAMERA_WALK_LITE != 0
 jmp sfcpmm_pitch_done
.else
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 cmp #$02
 bne sfcpmm_pitch_done
.endif
.endif
.endif
 lda ry0
 ldx cosxv
 jsr mul_s6
 sta t1
 lda rz0
 ldx sinxv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta vy3
 lda ry0
 ldx sinxv
 jsr mul_s6
 sta t1
 lda rz0
 ldx cosxv
 jsr mul_s6
 clc
 adc t1
 sta rz0
 lda vy3
 sta ry0
sfcpmm_pitch_done:

.if CAMERA_ROLL_ACTIVE != 0
.if ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH != 0
 lda explorer_cam_roll
 beq sfcpmm_roll_done
.endif
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 cmp #$02
 bne sfcpmm_roll_done
.endif
 lda rx0
 ldx coszv
 jsr mul_s6
 sta t1
 lda ry0
 ldx sinzv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta vx3
 lda rx0
 ldx sinzv
 jsr mul_s6
 sta t1
 lda ry0
 ldx coszv
 jsr mul_s6
 clc
 adc t1
 sta ry0
 lda vx3
 sta rx0
sfcpmm_roll_done:
.endif

 lda rx0
 sta stable_face_cull_m00,y
 lda ry0
 sta stable_face_cull_m10,y
 lda rz0
 sta stable_face_cull_m20,y
 dey
 bmi sfcpmm_done
 jmp sfcpmm_column
sfcpmm_done:
 rts
.endif

.if CAMERA_MOVABLE != 0
stable_face_cull_m00: .byte 0
stable_face_cull_m01: .byte 0
stable_face_cull_m02: .byte 0
stable_face_cull_m10: .byte 0
stable_face_cull_m11: .byte 0
stable_face_cull_m12: .byte 0
stable_face_cull_m20: .byte 0
stable_face_cull_m21: .byte 0
stable_face_cull_m22: .byte 0
.endif
.endif

; Demo-only: no symbolic entry/pointer/SMC consumers remain.
camera_plane_original_facing = hp_unreachable
.if STABLE_FACE_CULL_PROFILE != 0 && MODE4_OBJECT_LIGHT_CACHE != 0
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE = 0 && CAMERA_HAS_ROT != 0
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
.else
.endif
.if STABLE_FACE_CULL_PROFILE != 0
.else
.endif
cpof_visible = hp_unreachable
.if STABLE_FACE_CULL_PROFILE != 0 && MODE4_OBJECT_LIGHT_CACHE != 0
.else
.endif
cpof_hidden = hp_unreachable
.if STABLE_FACE_CULL_PROFILE != 0 && MODE4_OBJECT_LIGHT_CACHE != 0
cpof_restore_light_cache = hp_unreachable
.else
.endif
camera_plane_add_dot = hp_unreachable
camera_plane_mul_s16_s6 = hp_unreachable
cpms16_coord_ok = hp_unreachable
cpms16_mul_ok = hp_unreachable
cpms16_shift_q = hp_unreachable
cpms16_mul_loop = hp_unreachable
cpms16_no_add = hp_unreachable
cpms16_no_rem = hp_unreachable
cpms16_done = hp_unreachable

.if MEMORY_LAYOUT_HIGH_BASIC_V2 = 0
camera_plane_cull_code_end = *
.if camera_plane_cull_code_start != $9500
 .error "Camera-plane cull code did not start at $9500"
.endif
.if camera_plane_cull_code_end > $9f00
 .error "Camera-plane cull code leaves less than 256 bytes before bitmap B"
.endif
* = camera_plane_cull_low_return
.endif
.endif

; Demo-only: no symbolic entry/pointer/SMC consumers remain.
face_visible = hp_unreachable
.if STABLE_FACE_CULL_PROFILE != 0
tv_stable_positive_band = hp_unreachable
tv_stable_camera_fallback = hp_unreachable
tv_stable_camera_done = hp_unreachable
tv_stable_screen_safe = hp_unreachable
.endif
.if CONSERVATIVE_FACE_CULL != 0
tv_cons_neg = hp_unreachable
.if EXPLORER_SCREEN_CLIP_POLY != 0
.if HAS_TRI_FACES != 0
.endif
tv_cons_normal_neg = hp_unreachable
.endif
.else
.endif
tv_yes = hp_unreachable
tv_no = hp_unreachable
.endif
.endif
.endif
.if STANDARD_PROJECT_VERTEX != 0
project_vertex:
.if REFERENCE_PROJECTION != 0
 jmp project_vertex_reference
.endif
.if EXTENDED_TABLE_PROJECTION != 0
 jmp project_vertex_extended_table
.endif
.if REFERENCE_PROJECTION = 0
.if EXTENDED_TABLE_PROJECTION = 0
 lda projdone,x
 bne pv_done
 stx tmpidx
 jsr load_projection_table_index
 lda p1hi
 beq pv_index_low
 cmp #$21
 bcc pv_index_far
 lda #$01
 sta scalev
 jmp pv_scale_ready
pv_index_far:
 sec
 sbc #$01
 asl
 asl
 asl
 sta p1hi
 lda p1lo
 lsr
 lsr
 lsr
 lsr
 lsr
 ora p1hi
 tax
 lda scale_far_tab,x
 sta scalev
 jmp pv_scale_ready
pv_index_low:
 ldx p1lo
 lda scale_tab,x
 sta scalev
pv_scale_ready:
 ldx tmpidx
 lda rxbuf,x
 beq pv_x_center
 ldx scalev
 jsr mul_s6_xpos_round
 jsr m7_store_fixed_raw_x
 tax
 lda projx,x
 ldy tmpidx
 sta sx,y
 jmp pv_y_project
pv_x_center:
 lda #0
 jsr m7_store_fixed_raw_x
 ldy tmpidx
 lda #PROJ_CENTER_X
 sta sx,y
pv_y_project:
 lda rybuf,y
 beq pv_y_center
 ldx scalev
 jsr mul_s6_xpos_round
 jsr m7_store_fixed_raw_y
 tax
 lda projy,x
 ldy tmpidx
 sta sy,y
 jmp pv_mark_done
pv_y_center:
 lda #0
 jsr m7_store_fixed_raw_y
 lda #PROJ_CENTER_Y
 sta sy,y
pv_mark_done:
 jsr smooth_projected_vertex
 lda #$01
 sta projdone,y
pv_done:
 rts
.endif
.endif

.if EXTENDED_TABLE_PROJECTION != 0
project_vertex_extended_table:
 lda projdone,x
 bne pvet_done
 stx tmpidx
 jsr load_extended_scale
 ldx tmpidx
 lda rxbuf,x
 beq pvet_x_center
 ldx scalev
 jsr mul_s6_xpos_round
 jsr m7_store_fixed_raw_x
 tax
 lda projx,x
 ldy tmpidx
 sta sx,y
 jmp pvet_y_project
pvet_x_center:
 lda #0
 jsr m7_store_fixed_raw_x
 ldy tmpidx
 lda #PROJ_CENTER_X
 sta sx,y
pvet_y_project:
 lda rybuf,y
 beq pvet_y_center
 ldx scalev
 jsr mul_s6_xpos_round
 jsr m7_store_fixed_raw_y
 tax
 lda projy,x
 ldy tmpidx
 sta sy,y
 jmp pvet_mark_done
pvet_y_center:
 lda #0
 jsr m7_store_fixed_raw_y
 lda #PROJ_CENTER_Y
 sta sy,y
pvet_mark_done:
 jsr smooth_projected_vertex
 lda #$01
 sta projdone,y
pvet_done:
 rts

load_extended_scale:
 jsr load_projection_table_index
 lda p1hi
 beq les_near
 cmp #$21
 bcc les_far
 lda #$01
 sta scalev
 rts
les_near:
 lda p1lo
.if SCENE_OBJECT_COUNT != 0
 tax
 lda scene_scale_tab,x
.else
 tax
 lda scale_tab,x
.endif
 sta scalev
 rts
les_far:
 sec
 sbc #$01
 asl
 asl
 asl
 sta p1hi
 lda p1lo
 lsr
 lsr
 lsr
 lsr
 lsr
 ora p1hi
 tax
 lda scale_far_tab,x
 sta scalev
 rts
.endif

.if REFERENCE_PROJECTION != 0
project_vertex_reference:
 lda projdone,x
 bne pvr_done
 stx tmpidx
 lda rxbuf,x
 bpl pvr_x_abs_ready
 eor #$ff
 clc
 adc #$01
pvr_x_abs_ready:
 tax
 lda proj_num_lo,x
 sta prodlo
 lda proj_num_hi,x
 sta prodhi
 jsr load_projection_geometric_divisor
 jsr div16u
 lda prodhi
 beq pvr_x_quotient_ok
 lda #$ff
 jmp pvr_x_offset_ready
pvr_x_quotient_ok:
 lda prodlo
pvr_x_offset_ready:
 sta scalev
 ldx tmpidx
 lda rxbuf,x
 bmi pvr_x_left
 lda scalev
 cmp #PROJ_CENTER_X
 bcc pvr_x_right_visible
 lda #PROJ_SCREEN_MAX_X
 jmp pvr_x_store
pvr_x_right_visible:
 clc
 adc #PROJ_CENTER_X
 jmp pvr_x_store
pvr_x_left:
 lda scalev
 cmp #(PROJ_CENTER_X + 1)
 bcc pvr_x_left_visible
 lda #$00
 jmp pvr_x_store
pvr_x_left_visible:
 sta p1lo
 lda #PROJ_CENTER_X
 sec
 sbc p1lo
pvr_x_store:
 ldy tmpidx
 sta sx,y
 ldx tmpidx
 lda rybuf,x
 bpl pvr_y_abs_ready
 eor #$ff
 clc
 adc #$01
pvr_y_abs_ready:
 tax
 lda proj_num_lo,x
 sta prodlo
 lda proj_num_hi,x
 sta prodhi
 jsr load_projection_geometric_divisor
 jsr div16u
 lda prodhi
 beq pvr_y_quotient_ok
 lda #$ff
 jmp pvr_y_offset_ready
pvr_y_quotient_ok:
 lda prodlo
pvr_y_offset_ready:
 sta scalev
 ldx tmpidx
 lda rybuf,x
 bmi pvr_y_down
 lda scalev
 cmp #$33
 bcc pvr_y_up_visible
 lda #$00
 jmp pvr_y_store
pvr_y_up_visible:
 sta p1lo
 lda #PROJ_CENTER_Y
 sec
 sbc p1lo
 jmp pvr_y_store
pvr_y_down:
 lda scalev
 cmp #PROJ_CENTER_Y
 bcc pvr_y_down_visible
 lda #PROJ_SCREEN_MAX_Y
 jmp pvr_y_store
pvr_y_down_visible:
 clc
 adc #PROJ_CENTER_Y
pvr_y_store:
 ldy tmpidx
 sta sy,y
 jsr smooth_projected_vertex
 lda #$01
 sta projdone,y
pvr_done:
 rts
.endif
.endif

.if REFERENCE_PROJECTION != 0 || CAMERA_MOVABLE != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
div16u:
 lda p1hi
 bne gate4_div16_fallback
 lda p1lo
 beq gate4_div16_fallback
 lda prodhi
 cmp p1lo
 bcs gate4_div16_fallback
 ldx #$00
 stx prodhi
 stx crosshi
 ldx #$08
gate4_div16_low_loop:
 asl prodlo
 rol a
 bcs gate4_div16_low_sub
 cmp p1lo
 bcc gate4_div16_low_skip
gate4_div16_low_sub:
 sbc p1lo
 inc prodlo
gate4_div16_low_skip:
 dex
 bne gate4_div16_low_loop
 sta crosslo
 ; Preserve the original div16u scratch-register ABI as well: Y is the
 ; final trial-subtraction low byte, A its high byte, X=0, C=accepted.
 lda prodlo
 lsr a
 bcs gate4_div16_accepted
 sec
 lda crosslo
 sbc p1lo
 tay
 lda #$ff
 clv
 ldx #$01
 dex
 rts
gate4_div16_accepted:
 ldy crosslo
 lda #$00
 clv
 ldx #$01
 dex
 rts
gate4_div16_fallback:
 lda #$00
 sta crosslo
 sta crosshi
 ldx #$10
d16_loop:
 asl prodlo
 rol prodhi
 rol crosslo
 rol crosshi
 lda crosslo
 sec
 sbc p1lo
 tay
 lda crosshi
 sbc p1hi
 bcc d16_skip_sub
 sta crosshi
 sty crosslo
 inc prodlo
d16_skip_sub:
 dex
 bne d16_loop
 rts
.endif

.if STANDARD_PROJECT_VERTEX != 0
smooth_projected_vertex:
 ldy tmpidx
 lda smooth_ready,y
 bne spv_smooth
 lda sx,y
 sta sx_prev,y
 lda sy,y
 sta sy_prev,y
 lda #$01
 sta smooth_ready,y
 rts
spv_smooth:
 lda sx,y
 sta p1lo
 lda sx_prev,y
 sta p1hi
 lda p1lo
 cmp p1hi
 beq spv_x_store_prev
 bcc spv_x_neg
 sec
 sbc p1hi
 cmp #$02
 bcc spv_x_store_prev
 beq spv_x_pos_step
 lda p1lo
 jmp spv_x_store
spv_x_pos_step:
 lda p1hi
 clc
 adc #$01
 jmp spv_x_store
spv_x_neg:
 lda p1hi
 sec
 sbc p1lo
 cmp #$02
 bcc spv_x_store_prev
 beq spv_x_neg_step
 lda p1lo
 jmp spv_x_store
spv_x_neg_step:
 lda p1hi
 sec
 sbc #$01
 jmp spv_x_store
spv_x_store_prev:
 lda p1hi
spv_x_store:
 sta sx,y
 sta sx_prev,y
 lda sy,y
 sta p1lo
 lda sy_prev,y
 sta p1hi
 lda p1lo
 cmp p1hi
 beq spv_y_store_prev
 bcc spv_y_neg
 sec
 sbc p1hi
 cmp #$02
 bcc spv_y_store_prev
 beq spv_y_pos_step
 lda p1lo
 jmp spv_y_store
spv_y_pos_step:
 lda p1hi
 clc
 adc #$01
 jmp spv_y_store
spv_y_neg:
 lda p1hi
 sec
 sbc p1lo
 cmp #$02
 bcc spv_y_store_prev
 beq spv_y_neg_step
 lda p1lo
 jmp spv_y_store
spv_y_neg_step:
 lda p1hi
 sec
 sbc #$01
 jmp spv_y_store
spv_y_store_prev:
 lda p1hi
spv_y_store:
 sta sy,y
 sta sy_prev,y
 rts
.endif

.if POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0
select_draw_paths:
 lda drawbuf
 bne sdp_b
.if HIDDEN_WIRE_ENABLE = 0
 lda #<draw_loaded_face_solid_a
 sta ddb_solid_call+1
 lda #>draw_loaded_face_solid_a
 sta ddb_solid_call+2
.endif
.if HIDDEN_WIRE_ENABLE != 0 && (POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0)
 lda #<draw_loaded_face_solid_a
 sta ddb_hidden_mask_call+1
.if EXPLORER_SCREEN_CLIP_X != 0
 sta ddb_hidden_mask_second_call+1
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0 && WIRE_MESH_COUNT != 0
 sta ddb_hidden_mask_second_only_call+1
.endif
.endif
 lda #>draw_loaded_face_solid_a
 sta ddb_hidden_mask_call+2
.if EXPLORER_SCREEN_CLIP_X != 0
 sta ddb_hidden_mask_second_call+2
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0 && WIRE_MESH_COUNT != 0
 sta ddb_hidden_mask_second_only_call+2
.endif
.endif
.endif
.if HIDDEN_WIRE_ENABLE = 0
 lda #<draw_loaded_face_pattern_a
 sta ddb_pattern_call+1
 lda #>draw_loaded_face_pattern_a
 sta ddb_pattern_call+2
.endif
 rts
sdp_b:
.if HIDDEN_WIRE_ENABLE = 0
 lda #<draw_loaded_face_solid_b
 sta ddb_solid_call+1
 lda #>draw_loaded_face_solid_b
 sta ddb_solid_call+2
.endif
.if HIDDEN_WIRE_ENABLE != 0 && (POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0)
 lda #<draw_loaded_face_solid_b
 sta ddb_hidden_mask_call+1
.if EXPLORER_SCREEN_CLIP_X != 0
 sta ddb_hidden_mask_second_call+1
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0 && WIRE_MESH_COUNT != 0
 sta ddb_hidden_mask_second_only_call+1
.endif
.endif
 lda #>draw_loaded_face_solid_b
 sta ddb_hidden_mask_call+2
.if EXPLORER_SCREEN_CLIP_X != 0
 sta ddb_hidden_mask_second_call+2
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0 && WIRE_MESH_COUNT != 0
 sta ddb_hidden_mask_second_only_call+2
.endif
.endif
.endif
.if HIDDEN_WIRE_ENABLE = 0
 lda #<draw_loaded_face_pattern_b
 sta ddb_pattern_call+1
 lda #>draw_loaded_face_pattern_b
 sta ddb_pattern_call+2
.endif
 rts

.if MODE7_UV_CARRIER != 0
gouraud_load_face_raw_shades_y:
 ldx gouraud_face_shade0,y
 lda gouraud_shade_value,x
 sta m3_q0
 ldx gouraud_face_shade1,y
 lda gouraud_shade_value,x
 sta m3_q1
 ldx gouraud_face_shade2,y
 lda gouraud_shade_value,x
 sta m3_q2
 lda m7_face_u0,y
 sta gouraud_vshade0
 lda m7_face_v0,y
 sta m7_v0
 lda m7_face_u1,y
 sta gouraud_vshade1
 lda m7_face_v1,y
 sta m7_v1
 lda m7_face_u2,y
 sta gouraud_vshade2
 lda m7_face_v2,y
 sta m7_v2
 lda m7_face_texture,y
 tax
 lda m7_texture_hi,x
 sta m7_fetch+2
 jsr iu_select_surface
 rts
gouraud_apply_face_reflectivity:
 rts

; Q8-only: old integer polygon clip retired.
draw_loaded_face_gouraud = draw_clip_poly_gouraud
.if EXPLORER_SCREEN_CLIP_POLY != 0
.endif
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
.endif
dlfg_done = hp_unreachable
gouraud_build_edge_shades = hp_unreachable
gbes_init = hp_unreachable
gbes_edges = hp_unreachable
.if HAS_TRI_FACES != 0
.endif
gbes_close_triangle = hp_unreachable
gbes_close_common = hp_unreachable
gouraud_trace_shade_edge = hp_unreachable
gtse_ordered = hp_unreachable
r1_x_bias_done = hp_unreachable
gtse_loop = hp_unreachable
r1_edge_sample = hp_unreachable
demo_edge_x_correct = hp_unreachable
demo_edge_x_store = hp_unreachable
demo_edge_x_done = hp_unreachable
demo_edge_s_correct = hp_unreachable
demo_edge_s_store = hp_unreachable
demo_edge_s_done = hp_unreachable
gtse_horizontal = hp_unreachable
gtse_done = hp_unreachable
gouraud_store_edge_sample = hp_unreachable
seam_in_range = hp_unreachable
seam_left = hp_unreachable
seam_right_check = hp_unreachable
seam_done = hp_unreachable
r1_span_closed_cap = hp_unreachable
r1_cap_min0 = hp_unreachable
r1_cap_next0 = hp_unreachable
r1_cap_min1 = hp_unreachable
r1_cap_next1 = hp_unreachable
r1_cap_min2 = hp_unreachable
r1_cap_next2 = hp_unreachable
r1_cap_check_max = hp_unreachable
r1_cap_no = hp_unreachable
gouraud_fill_bounds:
.if TRACK_DIRTY_SPANS != 0
 lda drawbuf
 bne gfb_dirty_b
 lda face_ymin
 cmp dirty_ymin_a
 bcs gfb_dirty_ymin_done
 sta dirty_ymin_a
gfb_dirty_ymin_done:
 lda face_ymax
 cmp dirty_ymax_a
 bcc gfb_dirty_done
 sta dirty_ymax_a
 jmp gfb_dirty_done
gfb_dirty_b:
 lda face_ymin
 cmp dirty_ymin_b
 bcs gfb_dirty_ymin_b_done
 sta dirty_ymin_b
gfb_dirty_ymin_b_done:
 lda face_ymax
 cmp dirty_ymax_b
 bcc gfb_dirty_done
 sta dirty_ymax_b
gfb_dirty_done:
.endif
 ldx face_ymin
gfb_row:
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc gfb_next
 bne tq_fill_nonempty
 lda tq_closed,x
 beq gfb_next
tq_fill_nonempty:
 stx yrow
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
 lda drawbuf
 bne gfb_rows_b
 ldx yrow
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
 jsr apply_material_span_a
.endif
 jmp gfb_rows_ready
gfb_rows_b:
 ldx yrow
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
 jsr apply_material_span_b
.endif
gfb_rows_ready:
.if TRACK_DIRTY_SPANS != 0
 ldx yrow
 lda drawbuf
 bne gfb_dirty_span_b
 lda startbyte
 cmp dirtymin_a,x
 bcs gfb_dirty_min_a_done
 sta dirtymin_a,x
gfb_dirty_min_a_done:
 lda endbyte
 cmp dirtymax_a,x
 bcc gfb_dirty_span_done
 sta dirtymax_a,x
 jmp gfb_dirty_span_done
gfb_dirty_span_b:
 lda startbyte
 cmp dirtymin_b,x
 bcs gfb_dirty_min_b_done
 sta dirtymin_b,x
gfb_dirty_min_b_done:
 lda endbyte
 cmp dirtymax_b,x
 bcc gfb_dirty_span_done
 sta dirtymax_b,x
gfb_dirty_span_done:
.endif
 jsr m7_prepare_span
 jsr gouraud_draw_scan_span_bytes
gfb_next_restore:
 ldx yrow
gfb_next:
 cpx face_ymax
 beq gfb_done
 inx
 jmp gfb_row
gfb_done:
 rts

.if GOURAUD_BYTE_SPAN_KERNEL = 0
gouraud_plot_scan_pixel:
 lda gouraud_scan_x
 and #$03
 sta shadeidx
 lda gouraud_scan_shade
 asl
 asl
 ora shadeidx
 tay
gpsp_lut_load:
 lda gouraud_bayer_code_lut_y0,y
 sta p1lo
 ldx shadeidx
 lda gouraud_pair_clear,x
 sta maskv
 ldx gouraud_scan_x
 clc
 lda row0lo
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 clc
 lda row1lo
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldy #$00
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 rts
.else
; Gate 5 span cursor initialization occupies the retired scalar kernel's
; segment. This keeps Ground builds within the unchanged high-code window.
gouraud_init_span_pointers:
 ldx gouraud_scan_x
 clc
 lda row0lo
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 clc
 lda row1lo
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 rts
.endif
.endif

draw_loaded_face_solid_a:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlfs_a_normal
 jmp draw_clip_poly_solid_a
dlfs_a_normal:
.endif
.if DIRECT_CONVEX_FAN_FILL != 0 && WIRE_RENDER_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0
.if ENGINE_MODE3_DIRECT_CONVEX_FILL != 0
 ldy sortj
 lda frame_face_prepare,y
 beq dlfs_a_bounds
.endif
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$03
 beq dlfs_a_direct
 cmp #$04
 bne dlfs_a_bounds
dlfs_a_direct:
.endif
 jmp draw_direct_face_solid_a
dlfs_a_bounds:
.endif
 jsr build_loaded_face_bounds
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 lda xyq2_face_valid
 beq dlfs_a_done
.endif
 jmp fill_bounds_solid_a
dlfs_a_done:
 rts

draw_loaded_face_solid_b:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlfs_b_normal
 jmp draw_clip_poly_solid_b
dlfs_b_normal:
.endif
.if DIRECT_CONVEX_FAN_FILL != 0 && WIRE_RENDER_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0
.if ENGINE_MODE3_DIRECT_CONVEX_FILL != 0
 ldy sortj
 lda frame_face_prepare,y
 beq dlfs_b_bounds
.endif
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$03
 beq dlfs_b_direct
 cmp #$04
 bne dlfs_b_bounds
dlfs_b_direct:
.endif
 jmp draw_direct_face_solid_b
dlfs_b_bounds:
.endif
 jsr build_loaded_face_bounds
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 lda xyq2_face_valid
 beq dlfs_b_done
.endif
 jmp fill_bounds_solid_b
dlfs_b_done:
 rts

.if HIDDEN_WIRE_ENABLE = 0
draw_loaded_face_pattern_a:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlfp_a_normal
 jmp draw_clip_poly_pattern_a
dlfp_a_normal:
.endif
.if DIRECT_CONVEX_FAN_FILL != 0 && WIRE_RENDER_ENABLE = 0
.if ENGINE_MODE3_DIRECT_CONVEX_FILL != 0
 ldy sortj
 lda frame_face_prepare,y
 beq dlfp_a_bounds
.endif
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$03
 beq dlfp_a_direct
 cmp #$04
 bne dlfp_a_bounds
dlfp_a_direct:
.endif
 jmp draw_direct_face_pattern_a
dlfp_a_bounds:
.endif
 jsr build_loaded_face_bounds
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 lda xyq2_face_valid
 beq dlfp_a_done
.endif
.if MODE4_PATTERN_PROBE_LATCHED_FACE != 0
 jmp mode4_pattern_probe_latched_fill_a
.else
 jmp fill_bounds_pattern_a
.endif
dlfp_a_done:
 rts

draw_loaded_face_pattern_b:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlfp_b_normal
 jmp draw_clip_poly_pattern_b
dlfp_b_normal:
.endif
.if DIRECT_CONVEX_FAN_FILL != 0 && WIRE_RENDER_ENABLE = 0
.if ENGINE_MODE3_DIRECT_CONVEX_FILL != 0
 ldy sortj
 lda frame_face_prepare,y
 beq dlfp_b_bounds
.endif
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$03
 beq dlfp_b_direct
 cmp #$04
 bne dlfp_b_bounds
dlfp_b_direct:
.endif
 jmp draw_direct_face_pattern_b
dlfp_b_bounds:
.endif
 jsr build_loaded_face_bounds
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 lda xyq2_face_valid
 beq dlfp_b_done
.endif
.if MODE4_PATTERN_PROBE_LATCHED_FACE != 0
 jmp mode4_pattern_probe_latched_fill_b
.else
 jmp fill_bounds_pattern_b
.endif
dlfp_b_done:
 rts
.endif

.if EXPLORER_SCREEN_CLIP_POLY != 0
load_clip_poly_fan_triangle:
 lda #$03
 sta loaded_face_vertex_count
 lda clip_a_x
 sta vx0
 lda clip_a_y
 sta vy0
 ldx clip_cur_idx
 lda clip_a_x,x
 sta vx1
 lda clip_a_y,x
 sta vy1
 inx
 lda clip_a_x,x
 sta vx2
 sta vx3
 lda clip_a_y,x
 sta vy2
 sta vy3
.if MODE7_UV_CARRIER != 0
 lda m3_clip_a_q
 sta m3_q0
 lda m7_clip_a_v
 sta m7_v0
 lda clip_a_shade
 sta gouraud_vshade0
 ldx clip_cur_idx
 lda m3_clip_a_q,x
 sta m3_q1
 lda m7_clip_a_v,x
 sta m7_v1
 lda clip_a_shade,x
 sta gouraud_vshade1
 inx
 lda m3_clip_a_q,x
 sta m3_q2
 sta m3_q3
 lda m7_clip_a_v,x
 sta m7_v2
 sta m7_v3
 lda clip_a_shade,x
 sta gouraud_vshade2
 sta gouraud_vshade3
.endif
 jsr m7_sync_clipped_xyq2
 rts

.if MODE7_UV_CARRIER != 0
; Q8-only: old integer polygon clip retired.
hp_retired_draw_clip_poly_gouraud = hp_unreachable
dcpg_loop = hp_unreachable
dcpg_done = hp_unreachable

.endif

draw_clip_poly_solid_a:
 lda #<fill_bounds_solid_a
 sta dcp_fill_call+1
 lda #>fill_bounds_solid_a
 sta dcp_fill_call+2
 jmp draw_clip_poly_common

draw_clip_poly_solid_b:
 lda #<fill_bounds_solid_b
 sta dcp_fill_call+1
 lda #>fill_bounds_solid_b
 sta dcp_fill_call+2
 jmp draw_clip_poly_common

.if HIDDEN_WIRE_ENABLE = 0
draw_clip_poly_pattern_a:
 lda #<fill_bounds_pattern_a
 sta dcp_fill_call+1
 lda #>fill_bounds_pattern_a
 sta dcp_fill_call+2
 jmp draw_clip_poly_common

draw_clip_poly_pattern_b:
 lda #<fill_bounds_pattern_b
 sta dcp_fill_call+1
 lda #>fill_bounds_pattern_b
 sta dcp_fill_call+2
.endif
draw_clip_poly_common:
 lda clip_a_count
 cmp #$03
 bcc dcp_done
 lda #$01
 sta clip_cur_idx
dcp_loop:
 jsr load_clip_poly_fan_triangle
 jsr build_loaded_face_bounds_convex
dcp_fill_call:
 jsr fill_bounds_solid_a
 inc clip_cur_idx
 lda clip_cur_idx
 clc
 adc #$01
 cmp clip_a_count
 bcc dcp_loop
dcp_done:
 rts
.endif

.if DIRECT_CONVEX_FAN_FILL != 0 && WIRE_RENDER_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0
draw_direct_face_solid_a:
 lda #<direct_fill_span_solid_a
 sta dft_span_call+1
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+1
.endif
 lda #>direct_fill_span_solid_a
 sta dft_span_call+2
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+2
.endif
 jmp draw_direct_face_common

draw_direct_face_solid_b:
 lda #<direct_fill_span_solid_b
 sta dft_span_call+1
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+1
.endif
 lda #>direct_fill_span_solid_b
 sta dft_span_call+2
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+2
.endif
 jmp draw_direct_face_common

draw_direct_face_pattern_a:
 lda #<direct_fill_span_pattern_a
 sta dft_span_call+1
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+1
.endif
 lda #>direct_fill_span_pattern_a
 sta dft_span_call+2
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+2
.endif
 jmp draw_direct_face_common

draw_direct_face_pattern_b:
 lda #<direct_fill_span_pattern_b
 sta dft_span_call+1
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+1
.endif
 lda #>direct_fill_span_pattern_b
 sta dft_span_call+2
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+2
.endif

draw_direct_face_common:
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0


.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
.endif
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne ddf_triangle_first
.endif
 jsr direct_draw_quad_current
 bcs ddf_done
.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
ddf_triangle_first:
.endif
 jsr direct_draw_triangle_current
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne ddf_done
.endif
 lda vx1
 sta dft_save_vx1
 lda vy1
 sta dft_save_vy1
 lda vx2
 sta dft_save_vx2
 lda vy2
 sta dft_save_vy2
 lda vx2
 sta vx1
 lda vy2
 sta vy1
 lda vx3
 sta vx2
 lda vy3
 sta vy2
 jsr direct_draw_triangle_current
 lda dft_save_vx1
 sta vx1
 lda dft_save_vy1
 sta vy1
 lda dft_save_vx2
 sta vx2
 lda dft_save_vy2
 sta vy2
ddf_done:
 rts

direct_draw_triangle_current:
 lda vx0
 sta dft_x0
 lda vy0
 sta dft_y0
 lda vx1
 sta dft_x1
 lda vy1
 sta dft_y1
 lda vx2
 sta dft_x2
 lda vy2
 sta dft_y2
 jsr dft_sort_y
 lda dft_y2
 cmp dft_y0
 bne dft_nonflat
 jmp dft_done
dft_nonflat:
 lda dft_x0
 sta ex0
 lda dft_y0
 sta ey0
 lda dft_x2
 sta ex1
 lda dft_y2
 sta ey1
 jsr dft_init_long
 lda dft_y0
 cmp dft_y1
 beq dft_flat_top
 lda dft_x0
 sta ex0
 lda dft_y0
 sta ey0
 lda dft_x1
 sta ex1
 lda dft_y1
 sta ey1
 jsr dft_init_short
 lda #$00
 sta dft_short_phase
 jmp dft_loop_setup
dft_flat_top:
 lda dft_x1
 sta ex0
 lda dft_y1
 sta ey0
 lda dft_x2
 sta ex1
 lda dft_y2
 sta ey1
 jsr dft_init_short
 lda #$01
 sta dft_short_phase
dft_loop_setup:
 lda dft_y0
 sta yrow
dft_loop:
 lda dft_y2
 cmp yrow
 bcs dft_loop_active
 jmp dft_done
dft_loop_active:
 jsr dft_collect_long
 lda dft_short_phase
 bne dft_collect_short_current
 lda dft_y1
 cmp dft_y2
 beq dft_collect_short_current
 lda yrow
 cmp dft_y1
 bcc dft_collect_short_current
 ; Preserve both edge contributions on the split scanline. The established
 ; upper edge can contain a shallow horizontal run before x1, while
 ; the lower edge starts from x1 on the same row.
 jsr dft_collect_short
 lda dft_smin
 sta dft_split_min
 lda dft_smax
 sta dft_split_max
 lda dft_x1
 sta ex0
 lda dft_y1
 sta ey0
 lda dft_x2
 sta ex1
 lda dft_y2
 sta ey1
 jsr dft_init_short
 lda #$01
 sta dft_short_phase
 jsr dft_collect_short
 lda dft_split_min
 cmp dft_smin
 bcs dft_split_min_ready
 sta dft_smin
dft_split_min_ready:
 lda dft_split_max
 cmp dft_smax
 bcc dft_edges_ready
 beq dft_edges_ready
 sta dft_smax
 jmp dft_edges_ready
dft_collect_short_current:
 jsr dft_collect_short
dft_edges_ready:
 lda dft_lmin
 cmp dft_smin
 bcc dft_left_long
 lda dft_smin
 jmp dft_left_store
dft_left_long:
 lda dft_lmin
dft_left_store:
 sta leftval
 lda dft_lmax
 cmp dft_smax
 bcs dft_right_long
 lda dft_smax
 jmp dft_right_store
dft_right_long:
 lda dft_lmax
dft_right_store:
 sta rightval
 cmp leftval
 bcc dft_row_done
dft_span_call:
 jsr direct_fill_span_solid_a
dft_row_done:
 inc yrow
 jmp dft_loop
dft_done:
 rts

.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
; Native convex quad fill for prepared engine mode-3 faces. The four source
; vertices remain in mesh winding order. Starting from the topmost vertex,
; the +1 and -1 boundary chains are monotone in Y for a convex polygon. The
; existing long/short walkers trace the two chains and emit one merged span
; per scanline. A topology anomaly returns carry clear and the caller redraws
; through the validated two-triangle fan.
direct_draw_quad_current:
 lda vx0
 sta qf_x+0
 lda vy0
 sta qf_y+0
 sta yrow
 sta qf_ymax
 lda #$00
 sta qf_top_idx
 lda vx1
 sta qf_x+1
 lda vy1
 sta qf_y+1
 ldx #$01
 jsr qf_scan_y_extrema
 lda vx2
 sta qf_x+2
 lda vy2
 sta qf_y+2
 ldx #$02
 jsr qf_scan_y_extrema
 lda vx3
 sta qf_x+3
 lda vy3
 sta qf_y+3
 ldx #$03
 jsr qf_scan_y_extrema
 lda qf_ymax
 cmp yrow
 bne qf_nonflat
 clc
 rts
qf_nonflat:
 lda #$01
 sta qf_a_step
 lda qf_top_idx
 sta qf_work_idx
 lda qf_a_step
 sta qf_work_step
 jsr qf_prepare_edge
 bcc qf_fail
 lda qf_work_idx
 sta qf_a_idx
 jsr dft_init_long
 lda #$03
 sta qf_b_step
 lda qf_top_idx
 sta qf_work_idx
 lda qf_b_step
 sta qf_work_step
 jsr qf_prepare_edge
 bcc qf_fail
 lda qf_work_idx
 sta qf_b_idx
 jsr dft_init_short
qf_loop:
 jsr qf_collect_long_chain
 bcc qf_fail
 jsr qf_collect_short_chain
 bcc qf_fail
 lda dft_lmin
 cmp dft_smin
 bcc qf_left_long
 lda dft_smin
 jmp qf_left_store
qf_left_long:
 lda dft_lmin
qf_left_store:
 sta leftval
 lda dft_lmax
 cmp dft_smax
 bcs qf_right_long
 lda dft_smax
 jmp qf_right_store
qf_right_long:
 lda dft_lmax
qf_right_store:
 sta rightval
 cmp leftval
 bcc qf_row_done
dft_quad_span_call:
 jsr direct_fill_span_solid_a
qf_row_done:
 lda yrow
 cmp qf_ymax
 beq qf_success
 inc yrow
 jmp qf_loop
qf_success:
 sec
 rts
qf_fail:
 clc
 rts

; X selects the newly copied vertex. Keep the first minimum-Y vertex so
; horizontal top edges are split naturally between the two boundary chains.
qf_scan_y_extrema:
 lda qf_y,x
 cmp yrow
 bcs qf_scan_max
 sta yrow
 stx qf_top_idx
qf_scan_max:
 lda qf_y,x
 cmp qf_ymax
 bcc qf_scan_done
 sta qf_ymax
qf_scan_done:
 rts

; Build the next rising edge from qf_work_idx using +1 or -1 modulo four.
; Horizontal chain links are folded into the new start vertex. Four hops are
; the hard guard against a degenerate/all-horizontal or non-monotone polygon.
qf_prepare_edge:
 ldx qf_work_idx
 lda qf_x,x
 sta ex0
 lda qf_y,x
 sta ey0
 lda #$04
 sta qf_hops
qf_prepare_next:
 lda qf_work_idx
 clc
 adc qf_work_step
 and #$03
 sta qf_work_idx
 tax
 lda qf_y,x
 cmp ey0
 bcc qf_prepare_fail
 bne qf_prepare_rising
 lda qf_x,x
 sta ex0
 lda qf_y,x
 sta ey0
 dec qf_hops
 bne qf_prepare_next
qf_prepare_fail:
 clc
 rts
qf_prepare_rising:
 sta ey1
 lda qf_x,x
 sta ex1
 sec
 rts

; At a chain vertex the outgoing edge contributes on the same scanline as the
; incoming edge. Merge both extrema before the other chain and the span writer
; see them, preserving horizontal and shallow-edge coverage.
qf_collect_long_chain:
 jsr dft_collect_long
 lda yrow
 cmp dft_lendy
 bne qf_long_ok
 cmp qf_ymax
 beq qf_long_ok
 lda dft_lmin
 sta qf_save_min
 lda dft_lmax
 sta qf_save_max
 lda qf_a_idx
 sta qf_work_idx
 lda qf_a_step
 sta qf_work_step
 jsr qf_prepare_edge
 bcc qf_long_fail
 lda qf_work_idx
 sta qf_a_idx
 jsr dft_init_long
 jsr dft_collect_long
 lda qf_save_min
 cmp dft_lmin
 bcs qf_long_min_ready
 sta dft_lmin
qf_long_min_ready:
 lda qf_save_max
 cmp dft_lmax
 bcc qf_long_ok
 beq qf_long_ok
 sta dft_lmax
qf_long_ok:
 sec
 rts
qf_long_fail:
 clc
 rts

qf_collect_short_chain:
 jsr dft_collect_short
 lda yrow
 cmp dft_sendy
 bne qf_short_ok
 cmp qf_ymax
 beq qf_short_ok
 lda dft_smin
 sta qf_save_min
 lda dft_smax
 sta qf_save_max
 lda qf_b_idx
 sta qf_work_idx
 lda qf_b_step
 sta qf_work_step
 jsr qf_prepare_edge
 bcc qf_short_fail
 lda qf_work_idx
 sta qf_b_idx
 jsr dft_init_short
 jsr dft_collect_short
 lda qf_save_min
 cmp dft_smin
 bcs qf_short_min_ready
 sta dft_smin
qf_short_min_ready:
 lda qf_save_max
 cmp dft_smax
 bcc qf_short_ok
 beq qf_short_ok
 sta dft_smax
qf_short_ok:
 sec
 rts
qf_short_fail:
 clc
 rts
.endif

dft_sort_y:
 lda dft_y1
 cmp dft_y0
 bcs dft_sort_12
 jsr dft_swap_01
dft_sort_12:
 lda dft_y2
 cmp dft_y1
 bcs dft_sort_01_again
 jsr dft_swap_12
dft_sort_01_again:
 lda dft_y1
 cmp dft_y0
 bcs dft_sort_done
 jsr dft_swap_01
dft_sort_done:
 rts

dft_swap_01:
 lda dft_x0
 sta t1
 lda dft_x1
 sta dft_x0
 lda t1
 sta dft_x1
 lda dft_y0
 sta t1
 lda dft_y1
 sta dft_y0
 lda t1
 sta dft_y1
 rts

dft_swap_12:
 lda dft_x1
 sta t1
 lda dft_x2
 sta dft_x1
 lda t1
 sta dft_x2
 lda dft_y1
 sta t1
 lda dft_y2
 sta dft_y1
 lda t1
 sta dft_y2
 rts

dft_init_long:
 lda ex0
 sta dft_lx
 lda ey1
 sta dft_lendy
 sec
 lda ey1
 sbc ey0
 sta dft_ldy
 lda #$00
 sta dft_ltype
 lda ex1
 cmp ex0
 bcs dft_il_pos
 sec
 lda ex0
 sbc ex1
 sta dft_ldx
 lda #$ff
 sta dft_lsx
 jmp dft_il_classify
dft_il_pos:
 sec
 lda ex1
 sbc ex0
 sta dft_ldx
 lda #$01
 sta dft_lsx
dft_il_classify:
 lda dft_ldx
 beq dft_il_vert
 cmp dft_ldy
 beq dft_il_diag
 jmp dft_il_err
dft_il_vert:
 lda #$00
 sta dft_lsx
 lda #$01
 sta dft_ltype
 jmp dft_il_err
dft_il_diag:
 lda #$02
 sta dft_ltype
dft_il_err:
 lda #$00
 sta dft_lerrlo
 sta dft_lerrhi
 rts

dft_init_short:
 lda ex0
 sta dft_sx
 lda ey1
 sta dft_sendy
 sec
 lda ey1
 sbc ey0
 sta dft_sdy
 lda #$00
 sta dft_stype
 lda ex1
 cmp ex0
 bcs dft_is_pos
 sec
 lda ex0
 sbc ex1
 sta dft_sdx
 lda #$ff
 sta dft_ssx
 jmp dft_is_classify
dft_is_pos:
 sec
 lda ex1
 sbc ex0
 sta dft_sdx
 lda #$01
 sta dft_ssx
dft_is_classify:
 lda dft_sdx
 beq dft_is_vert
 cmp dft_sdy
 beq dft_is_diag
 jmp dft_is_err
dft_is_vert:
 lda #$00
 sta dft_ssx
 lda #$01
 sta dft_stype
 jmp dft_is_err
dft_is_diag:
 lda #$02
 sta dft_stype
dft_is_err:
 lda #$00
 sta dft_serrlo
 sta dft_serrhi
 rts

dft_collect_long:
 lda dft_lx
 sta dft_lmin
 sta dft_lmax
 lda yrow
 cmp dft_lendy
 beq dft_cl_done
 lda dft_ltype
 cmp #$01
 beq dft_cl_done
 cmp #$02
 bne dft_cl_general
 lda dft_lsx
 bmi dft_cl_diag_neg
 inc dft_lx
 rts
dft_cl_diag_neg:
 dec dft_lx
 rts
dft_cl_general:
 clc
 lda dft_lerrlo
 adc dft_ldx
 sta dft_lerrlo
 lda dft_lerrhi
 adc #$00
 sta dft_lerrhi
dft_cl_check:
 lda dft_lerrhi
 bne dft_cl_xstep
 lda dft_lerrlo
 cmp dft_ldy
 bcc dft_cl_done
dft_cl_xstep:
 sec
 lda dft_lerrlo
 sbc dft_ldy
 sta dft_lerrlo
 lda dft_lerrhi
 sbc #$00
 sta dft_lerrhi
 lda dft_lsx
 beq dft_cl_check
 bmi dft_cl_xneg
 inc dft_lx
 lda dft_lx
 sta dft_lmax
 jmp dft_cl_check
dft_cl_xneg:
 dec dft_lx
 lda dft_lx
 sta dft_lmin
 jmp dft_cl_check
dft_cl_done:
 rts

dft_collect_short:
 lda dft_sx
 sta dft_smin
 sta dft_smax
 lda yrow
 cmp dft_sendy
 beq dft_cs_done
 lda dft_stype
 cmp #$01
 beq dft_cs_done
 cmp #$02
 bne dft_cs_general
 lda dft_ssx
 bmi dft_cs_diag_neg
 inc dft_sx
 rts
dft_cs_diag_neg:
 dec dft_sx
 rts
dft_cs_general:
 clc
 lda dft_serrlo
 adc dft_sdx
 sta dft_serrlo
 lda dft_serrhi
 adc #$00
 sta dft_serrhi
dft_cs_check:
 lda dft_serrhi
 bne dft_cs_xstep
 lda dft_serrlo
 cmp dft_sdy
 bcc dft_cs_done
dft_cs_xstep:
 sec
 lda dft_serrlo
 sbc dft_sdy
 sta dft_serrlo
 lda dft_serrhi
 sbc #$00
 sta dft_serrhi
 lda dft_ssx
 beq dft_cs_check
 bmi dft_cs_xneg
 inc dft_sx
 lda dft_sx
 sta dft_smax
 jmp dft_cs_check
dft_cs_xneg:
 dec dft_sx
 lda dft_sx
 sta dft_smin
 jmp dft_cs_check
dft_cs_done:
 rts

direct_fill_span_pattern_a:
 ldy shadeidx
 lda yrow
 and #$01
 beq dfp_a_even
 iny
dfp_a_even:
 lda shade_pattern_bytes,y
 sta fillbyte
 jmp direct_fill_span_solid_a

direct_fill_span_pattern_b:
 ldy shadeidx
 lda yrow
 and #$01
 beq dfp_b_even
 iny
dfp_b_even:
 lda shade_pattern_bytes,y
 sta fillbyte
 jmp direct_fill_span_solid_b

direct_fill_span_solid_a:
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq dfs_a_draw
 ldx yrow
 jsr lowres_row_selected
 bne dfs_a_done
.endif
dfs_a_draw:
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 txa
 cmp dirty_ymin_a
 bcs dfs_a_dirty_ymin_ok
 sta dirty_ymin_a
dfs_a_dirty_ymin_ok:
 txa
 cmp dirty_ymax_a
 bcc dfs_a_dirty_ymax_ok
 sta dirty_ymax_a
dfs_a_dirty_ymax_ok:
.endif
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_a
.else
 jsr apply_material_span_a
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_a,x
 bcs dfs_a_dirty_min_ok
 sta dirtymin_a,x
dfs_a_dirty_min_ok:
 lda endbyte
 cmp dirtymax_a,x
 bcc dfs_a_dirty_done
 sta dirtymax_a,x
dfs_a_dirty_done:
.endif
 jmp direct_fill_span_pixels
dfs_a_done:
 rts

direct_fill_span_solid_b:
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq dfs_b_draw
 ldx yrow
 jsr lowres_row_selected
 bne dfs_b_done
.endif
dfs_b_draw:
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 txa
 cmp dirty_ymin_b
 bcs dfs_b_dirty_ymin_ok
 sta dirty_ymin_b
dfs_b_dirty_ymin_ok:
 txa
 cmp dirty_ymax_b
 bcc dfs_b_dirty_ymax_ok
 sta dirty_ymax_b
dfs_b_dirty_ymax_ok:
.endif
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_b
.else
 jsr apply_material_span_b
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_b,x
 bcs dfs_b_dirty_min_ok
 sta dirtymin_b,x
dfs_b_dirty_min_ok:
 lda endbyte
 cmp dirtymax_b,x
 bcc dfs_b_dirty_done
 sta dirtymax_b,x
dfs_b_dirty_done:
.endif
 jmp direct_fill_span_pixels
dfs_b_done:
 rts

direct_fill_span_pixels:
 ldy #$00
 lda startbyte
 cmp endbyte
 bne dfsp_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
 cmp #$ff
 bne dfsp_single_partial
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 rts
dfsp_single_partial:
.endif
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 rts
dfsp_multi:
.if INDEXED_OFFSET_SPAN_FILL != 0
 lda endbyte
 sec
 sbc startbyte
 cmp #$20
 bcs dfsp_multi_pointer
 sta fullcount
 ldy #$00
 ldx leftval
 lda startmask,x
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
 cmp #$ff
 bne dfsp_indexed_left_partial
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp dfsp_indexed_left_done
dfsp_indexed_left_partial:
.endif
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
dfsp_indexed_left_done:
.endif
 lda fullcount
 cmp #$01
 beq dfsp_indexed_end_at_08
 sec
 sbc #$01
 sta p1hi
 lda fillbyte
 ldy #$08
dfsp_indexed_mid_loop:
 sta (ptr0lo),y
 sta (ptr1lo),y
 tya
 clc
 adc #$08
 tay
 lda fillbyte
 dec p1hi
 bne dfsp_indexed_mid_loop
 jmp dfsp_indexed_draw_end_y
dfsp_indexed_end_at_08:
 ldy #$08
dfsp_indexed_draw_end_y:
 ldx rightval
 lda endmask,x
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
 cmp #$ff
 bne dfsp_indexed_end_partial
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 rts
dfsp_indexed_end_partial:
.endif
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 rts
dfsp_multi_pointer:
 ldy #$00
.endif
 ldx leftval
 lda startmask,x
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
 cmp #$ff
 bne dfsp_pointer_left_partial
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp dfsp_pointer_left_done
dfsp_pointer_left_partial:
.endif
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
dfsp_pointer_left_done:
.endif
 lda endbyte
 sec
 sbc startbyte
 sta fullcount
dfsp_next_byte:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc dfsp_next0_ok
 inc ptr0hi
dfsp_next0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc dfsp_next1_ok
 inc ptr1hi
dfsp_next1_ok:
 dec fullcount
 beq dfsp_draw_end
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp dfsp_next_byte
dfsp_draw_end:
 ldx rightval
 lda endmask,x
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
 cmp #$ff
 bne dfsp_pointer_end_partial
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 rts
dfsp_pointer_end_partial:
.endif
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 rts

dft_x0: .byte 0
dft_y0: .byte 0
dft_x1: .byte 0
dft_y1: .byte 0
dft_x2: .byte 0
dft_y2: .byte 0
dft_lx: .byte 0
dft_lendy: .byte 0
dft_ldx: .byte 0
dft_ldy: .byte 0
dft_lsx: .byte 0
dft_ltype: .byte 0
dft_lerrlo: .byte 0
dft_lerrhi: .byte 0
dft_sx: .byte 0
dft_sendy: .byte 0
dft_sdx: .byte 0
dft_sdy: .byte 0
dft_ssx: .byte 0
dft_stype: .byte 0
dft_serrlo: .byte 0
dft_serrhi: .byte 0
dft_lmin: .byte 0
dft_lmax: .byte 0
dft_smin: .byte 0
dft_smax: .byte 0
dft_split_min: .byte 0
dft_split_max: .byte 0
dft_short_phase: .byte 0
dft_save_vx1: .byte 0
dft_save_vy1: .byte 0
dft_save_vx2: .byte 0
dft_save_vy2: .byte 0
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
qf_x: .byte 0,0,0,0
qf_y: .byte 0,0,0,0
qf_top_idx: .byte 0
qf_ymax: .byte 0
qf_a_idx: .byte 0
qf_a_step: .byte 0
qf_b_idx: .byte 0
qf_b_step: .byte 0
qf_work_idx: .byte 0
qf_work_step: .byte 0
qf_hops: .byte 0
qf_save_min: .byte 0
qf_save_max: .byte 0
.endif
.endif

build_loaded_face_bounds:
 jmp build_loaded_face_bounds_convex

build_loaded_face_bounds_convex:
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 jsr mobile_yq2_face_eligible
 bcs blfbc_mobile_yq2
 ; A clipped/synthetic polygon keeps the pre-Phase-1 integer bounds path.
 lda #$01
 sta xyq2_face_valid
 jmp build_loaded_face_bounds_convex_legacy
blfbc_mobile_yq2:
 jmp build_loaded_face_bounds_xyq2
.endif
build_loaded_face_bounds_convex_legacy:
 jsr setup_face_y_bounds
.if LAZY_CONVEX_BOUNDS != 0
 inc bounds_stamp_cur
 bne bltc_lazy_ready
 jsr clear_bounds_stamp
 inc bounds_stamp_cur
bltc_lazy_ready:
 jmp bltc_init_done
.endif
 ldx face_ymin
 lda #$ff
bltc_init_loop:
 sta leftb,x
 lda #$00
 sta rightb,x
 lda #$ff
 cpx face_ymax
 beq bltc_init_done
 inx
 jmp bltc_init_loop
bltc_init_done:
 lda vx0
 sta ex0
 lda vy0
 sta ey0
 lda vx1
 sta ex1
 lda vy1
 sta ey1
 jsr trace_edge_convex
 lda vx1
 sta ex0
 lda vy1
 sta ey0
 lda vx2
 sta ex1
 lda vy2
 sta ey1
 jsr trace_edge_convex
 lda vx2
 sta ex0
 lda vy2
 sta ey0
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne blfc_trace_2_to_0
.endif
 lda vx3
 sta ex1
 lda vy3
 sta ey1
 jsr trace_edge_convex
 lda vx3
 sta ex0
 lda vy3
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
 rts
.if HAS_TRI_FACES != 0
blfc_trace_2_to_0:
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
 rts
.endif
.endif

.if MODE5_POLYGON_OUTLINE != 0 && MEMORY_LAYOUT_HIGH_BASIC_V2 = 0
; Stable Mode 5 keeps its connected edge walker in the documented free RAM
; between screen B ($8c00-$8fff) and bitmap B ($a000-$bfff).  The $9100
; base preserves a full 256-byte guard above screen B; $9f00 is the exclusive
; limit and preserves another 256-byte guard below bitmap B.
mode5_stable_low_return = *
* = $9100
mode5_stable_code_start = *
.endif

.if MODE5_POLYGON_OUTLINE != 0
; Walk only the already prepared face perimeter.  The clipped path consumes
; every clip_a edge, including generated near/screen caps.
mode5_draw_loaded_polygon_outline:
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 lda xyq2_face_valid
 beq mode5_outline_done
.endif
 inc mode5_outline_trace_active
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq mode5_outline_projected
 lda clip_a_count
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
mode5_outline_clip_loop:
 ldx clip_prev_idx
 lda clip_a_x,x
 sta ex0
 lda clip_a_y,x
 sta ey0
 ldx clip_cur_idx
 lda clip_a_x,x
 sta ex1
 lda clip_a_y,x
 sta ey1
 jsr mode5_trace_background_edge
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne mode5_outline_clip_loop
 jmp mode5_outline_finish
mode5_outline_projected:
.endif
 ldx #$00
mode5_outline_first_edges:
 lda vx0,x
 sta ex0
 lda vy0,x
 sta ey0
 lda vx1,x
 sta ex1
 lda vy1,x
 sta ey1
 txa
 pha
 jsr mode5_trace_background_edge
 pla
 tax
 inx
 inx
 cpx #$04
 bne mode5_outline_first_edges
 lda vx2
 sta ex0
 lda vy2
 sta ey0
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne mode5_outline_close
.endif
 lda vx3
 sta ex1
 lda vy3
 sta ey1
 jsr mode5_trace_background_edge
 lda vx3
 sta ex0
 lda vy3
 sta ey0
mode5_outline_close:
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr mode5_trace_background_edge
mode5_outline_finish:
 dec mode5_outline_trace_active
mode5_outline_done:
 rts

; Reuse the renderer's connected Bresenham kernel.  The active byte redirects
; each generated point to the Mode 5 background-pixel writer while ordinary
; bounds construction continues through the unchanged path.
mode5_trace_background_edge = trace_edge_convex

mode5_trace_background_horizontal:
 lda ex0
 sta xcur
mode5_horizontal_loop:
 ldx ey0
 lda xcur
 jsr update_convex_bounds
 lda xcur
 cmp ex1
 beq mode5_horizontal_done
 bcc mode5_horizontal_inc
 dec xcur
 jmp mode5_horizontal_loop
mode5_horizontal_inc:
 inc xcur
 jmp mode5_horizontal_loop
mode5_horizontal_done:
 rts

; A zero multicolor bitmap pair selects the VIC-II background register $d021,
; initialized from WORLD_BACKGROUND_COLOR.  No C64 palette index is hardcoded.
mode5_plot_background_point:
 ; load_face_y and clip_a guarantee 0..PROJ_SCREEN_MAX endpoints before fill.
 ; Rechecking here would be a redundant second line clip.
 lda drawbuf
 bne mode5_plot_buffer_b
 ldx rightval
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 jmp mode5_plot_rows_ready
mode5_plot_buffer_b:
 ldx rightval
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
mode5_plot_rows_ready:
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda startmask,x
 and endmask,x
 eor #$ff
 sta maskv
 ldy #$00
 lda (ptr0lo),y
 and maskv
 sta (ptr0lo),y
 iny
 lda (ptr0lo),y
 and maskv
 sta (ptr0lo),y
mode5_plot_done:
 rts
.endif

update_convex_bounds:
.if MODE5_POLYGON_OUTLINE != 0
 stx rightval
 sta leftval
 lda mode5_outline_trace_active
 beq ucb_mode5_bounds
 jmp mode5_plot_background_point
ucb_mode5_bounds:
 lda leftval
 ldx rightval
.endif
.if ENGINE_MODE1_WIRE_POINT_DIRECT_ENTRY != 0
 ; Engine mode 1 endpoints are already in-range before tracing.
 ; Fall through directly into plot_wire_point and return to the trace loop.
 stx rightval
 sta leftval
.else
.if WIRE_RENDER_ENABLE != 0
 stx rightval
 sta leftval
.if POLY_FILL_ENABLE = 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq ucb_bounds
 jmp plot_wire_point
ucb_bounds:
 lda leftval
 ldx rightval
.else
 jmp plot_wire_point
.endif
.else
 lda wire_trace_active
 beq ucb_bounds
 jmp plot_wire_point
ucb_bounds:
 lda leftval
 ldx rightval
.endif
.endif
.if LAZY_CONVEX_BOUNDS != 0 && WIRE_RENDER_ENABLE = 0
 sta leftval
 stx rightval
 lda bounds_stamp,x
 cmp bounds_stamp_cur
 beq ucb_lazy_seen
 lda bounds_stamp_cur
 sta bounds_stamp,x
 lda leftval
 sta leftb,x
 sta rightb,x
 rts
ucb_lazy_seen:
 lda leftval
 ldx rightval
.endif
 cmp leftb,x
 bcs ucb_left_ok
 sta leftb,x
ucb_left_ok:
 cmp rightb,x
 bcc ucb_done
 sta rightb,x
ucb_done:
 rts
.endif

.if WIRE_RENDER_ENABLE != 0
plot_wire_point:
.if WORLD_GROUND_WIRE_OCCLUDE != 0
 lda world_ground_horizon_mask_active
 beq pwp_normal
 jmp world_ground_mask_plot_point
pwp_normal:
.endif
.if ENGINE_MODE1_WIRE_POINT_BOUNDS_STRIPPED = 0 && ENGINE_MODE2_WIRE_POINT_BOUNDS_STRIPPED = 0
 ldx rightval
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bcs pwp_done
 ldx leftval
 cpx #(PROJ_SCREEN_MAX_X + 1)
 bcs pwp_done
.else
 ; Bounds are guaranteed by the edge fast path or clip fallback.
 ; Keep X on the horizontal coordinate for the dirty/material hot path.
 ldx leftval
.endif
.if TRACK_DIRTY_SPANS != 0
 lda xbyte,x
 sta startbyte
.if ENGINE_WIRE_DIRTY_SAME_BYTE_SKIP != 0
 lda drawbuf
 cmp engine_wire_last_dirty_buf
 bne pwp_dirty_transition_miss
 lda rightval
 cmp engine_wire_last_dirty_y
 bne pwp_dirty_transition_miss
 lda startbyte
 cmp engine_wire_last_dirty_x
 beq pwp_dirty_done
pwp_dirty_transition_miss:
 lda drawbuf
 sta engine_wire_last_dirty_buf
 lda rightval
 sta engine_wire_last_dirty_y
 lda startbyte
 sta engine_wire_last_dirty_x
.endif
 ldx rightval
 lda drawbuf
 bne pwp_dirty_b
 txa
 cmp dirty_ymin_a
 bcs pwp_dirty_a_ymin_ok
 sta dirty_ymin_a
pwp_dirty_a_ymin_ok:
 txa
 cmp dirty_ymax_a
 bcc pwp_dirty_a_span
 sta dirty_ymax_a
pwp_dirty_a_span:
 lda startbyte
 cmp dirtymin_a,x
 bcs pwp_dirty_a_min_ok
 sta dirtymin_a,x
pwp_dirty_a_min_ok:
 lda startbyte
 cmp dirtymax_a,x
 bcc pwp_dirty_done
 sta dirtymax_a,x
 jmp pwp_dirty_done
pwp_dirty_b:
 txa
 cmp dirty_ymin_b
 bcs pwp_dirty_b_ymin_ok
 sta dirty_ymin_b
pwp_dirty_b_ymin_ok:
 txa
 cmp dirty_ymax_b
 bcc pwp_dirty_b_span
 sta dirty_ymax_b
pwp_dirty_b_span:
 lda startbyte
 cmp dirtymin_b,x
 bcs pwp_dirty_b_min_ok
 sta dirtymin_b,x
pwp_dirty_b_min_ok:
 lda startbyte
 cmp dirtymax_b,x
 bcc pwp_dirty_done
 sta dirtymax_b,x
pwp_dirty_done:
.endif
 ldx rightval
 lda drawbuf
 bne pwp_buffer_b
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jmp pwp_rows_ready
pwp_buffer_b:
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
pwp_rows_ready:
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 lda startmask,x
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 ldy #$00
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0 || ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE != 0
.if ENGINE_WIRE_MATERIAL_CALL_ON_CELL_CHANGE != 0 && ENGINE_WIRE_CELL_WRITE_SKIP_SAME != 0 && ENGINE_WIRE_EDGE_MATERIAL_CONTEXT != 0 && VIC_COLOR_POLICY_ENABLE = 0
 lda drawbuf
 cmp engine_wire_last_cell_buf
 bne pwp_material_transition_miss
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 ldx rightval
 lda viewport_cellrow_id,x
.else
 lda rightval
.if ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE != 0 || ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE != 0
 and #$fc
.endif
.endif
 cmp engine_wire_last_cell_y
 bne pwp_material_transition_miss
 lda startbyte
 cmp engine_wire_last_cell_x
 beq pwp_done
pwp_material_transition_miss:
 lda drawbuf
 sta engine_wire_last_cell_buf
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 ldx rightval
 lda viewport_cellrow_id,x
.else
 lda rightval
.if ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE != 0 || ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE != 0
 and #$fc
.endif
.endif
 sta engine_wire_last_cell_y
 lda startbyte
 sta engine_wire_last_cell_x
 jsr plot_wire_material_write
.else
 jsr plot_wire_material
.endif
.endif
pwp_done:
 rts

.if ENGINE_WIRE_CELL_WRITE_SKIP_SAME != 0
engine_wire_reset_material_cell_cache:
 lda #$ff
 sta engine_wire_last_cell_x
 sta engine_wire_last_cell_y
 sta engine_wire_last_cell_buf
.if ENGINE_WIRE_TRANSITION_CACHE_RESET_FRAME != 0
 sta engine_wire_last_dirty_x
 sta engine_wire_last_dirty_y
 sta engine_wire_last_dirty_buf
.endif
.if ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = 0
 sta engine_wire_last_screen
 sta engine_wire_last_color
.endif
 rts

.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
engine_wire_invalidate_material_cell_cache:
 lda #$ff
 sta engine_wire_last_cell_buf
 rts
.endif
.endif

.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0 || ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE != 0
plot_wire_material:
.if ENGINE_WIRE_CELL_WRITE_SKIP_SAME != 0 && VIC_COLOR_POLICY_ENABLE = 0
 lda drawbuf
 cmp engine_wire_last_cell_buf
 bne pwm_cache_miss
 .if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 ldx rightval
 lda viewport_cellrow_id,x
.else
 lda rightval
.if ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE != 0 || ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE != 0
 and #$fc
.endif
.endif
 cmp engine_wire_last_cell_y
 bne pwm_cache_miss
.if ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE != 0 || ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE != 0
 lda startbyte
.else
 ldx leftval
 lda xbyte,x
.endif
 cmp engine_wire_last_cell_x
 bne pwm_cache_miss
.if ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = 0
 lda material_screen_cur
 cmp engine_wire_last_screen
 bne pwm_cache_miss
 lda material_color_cur
 cmp engine_wire_last_color
 bne pwm_cache_miss
.endif
 rts
pwm_cache_miss:
 lda drawbuf
 sta engine_wire_last_cell_buf
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 ldx rightval
 lda viewport_cellrow_id,x
.else
 lda rightval
.if ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE != 0 || ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE != 0
 and #$fc
.endif
.endif
 sta engine_wire_last_cell_y
.if ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE != 0 || ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE != 0
 lda startbyte
.else
 ldx leftval
 lda xbyte,x
.endif
 sta engine_wire_last_cell_x
.if ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = 0
 lda material_screen_cur
 sta engine_wire_last_screen
 lda material_color_cur
 sta engine_wire_last_color
.endif
.endif
plot_wire_material_write:
 ldx rightval
 lda drawbuf
 bne pwm_buffer_b
 lda screenrowlo_a,x
 sta ptr0lo
 lda screenrowhi_a,x
 sta ptr0hi
 jmp pwm_screen_ready
pwm_buffer_b:
 lda screenrowlo_b,x
 sta ptr0lo
 lda screenrowhi_b,x
 sta ptr0hi
pwm_screen_ready:
 lda colorrowlo,x
 sta ptr1lo
 lda colorrowhi,x
 sta ptr1hi
.if ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE != 0 || ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE != 0
 lda startbyte
.else
 ldx leftval
 lda xbyte,x
.endif
 clc
 adc ptr0lo
 sta ptr0lo
 lda ptr0hi
 adc #$00
 sta ptr0hi
.if ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE != 0 || ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE != 0
 lda startbyte
.else
 ldx leftval
 lda xbyte,x
.endif
 clc
 adc ptr1lo
 sta ptr1lo
 lda ptr1hi
 adc #$00
 sta ptr1hi
.if VIC_COLOR_POLICY_ENABLE != 0
 lda #$02
 sta vic_color_source
 lda rightval
 sta yrow
 ldx leftval
 lda xbyte,x
 tax
 jsr vic_color_policy_claim_cell
 lda #$01
 sta vic_color_source
 bcc pwm_done
.endif
 ldy #$00
 lda material_screen_cur
 sta (ptr0lo),y
 lda material_color_cur
 sta (ptr1lo),y
pwm_done:
 rts
.endif

plot_wire_horizontal:
 lda ey0
 sta rightval
 lda ex0
 cmp ex1
 bcc pwh_ordered
 beq pwh_single
 lda ex1
 sta leftval
 lda ex0
 sta face_ymax
 jmp pwh_span
pwh_ordered:
 lda ex0
 sta leftval
 lda ex1
 sta face_ymax
 jmp pwh_span
pwh_single:
 sta leftval
 jmp plot_wire_point
pwh_span:
 ldx rightval
 stx yrow
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx face_ymax
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0 || ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE != 0
.if VIC_COLOR_POLICY_ENABLE != 0
 lda #$02
 sta vic_color_source
.endif
 lda drawbuf
 bne pwh_material_b
 jsr apply_material_span_a
 jmp pwh_material_done
pwh_material_b:
 jsr apply_material_span_b
pwh_material_done:
.if VIC_COLOR_POLICY_ENABLE != 0
 lda #$01
 sta vic_color_source
.endif
.endif
.if TRACK_DIRTY_SPANS != 0
 ldx yrow
 lda drawbuf
 bne pwh_dirty_b
 txa
 cmp dirty_ymin_a
 bcs pwh_dirty_a_ymin_ok
 sta dirty_ymin_a
pwh_dirty_a_ymin_ok:
 txa
 cmp dirty_ymax_a
 bcc pwh_dirty_a_span
 sta dirty_ymax_a
pwh_dirty_a_span:
 lda startbyte
 cmp dirtymin_a,x
 bcs pwh_dirty_a_min_ok
 sta dirtymin_a,x
pwh_dirty_a_min_ok:
 lda endbyte
 cmp dirtymax_a,x
 bcc pwh_dirty_done
 sta dirtymax_a,x
 jmp pwh_dirty_done
pwh_dirty_b:
 txa
 cmp dirty_ymin_b
 bcs pwh_dirty_b_ymin_ok
 sta dirty_ymin_b
pwh_dirty_b_ymin_ok:
 txa
 cmp dirty_ymax_b
 bcc pwh_dirty_b_span
 sta dirty_ymax_b
pwh_dirty_b_span:
 lda startbyte
 cmp dirtymin_b,x
 bcs pwh_dirty_b_min_ok
 sta dirtymin_b,x
pwh_dirty_b_min_ok:
 lda endbyte
 cmp dirtymax_b,x
 bcc pwh_dirty_done
 sta dirtymax_b,x
pwh_dirty_done:
.endif
 ldx yrow
 lda drawbuf
 bne pwh_buffer_b
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jmp pwh_rows_ready
pwh_buffer_b:
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
pwh_rows_ready:
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldy #$00
 lda startbyte
 cmp endbyte
 bne pwh_multi
 ldx leftval
 lda startmask,x
 ldx face_ymax
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 rts
pwh_multi:
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 sta fullcount
pwh_next_byte:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc pwh_next0_ok
 inc ptr0hi
pwh_next0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc pwh_next1_ok
 inc ptr1hi
pwh_next1_ok:
 dec fullcount
 beq pwh_draw_end
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp pwh_next_byte
pwh_draw_end:
 ldx face_ymax
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 rts
.endif

.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
; Draw an inclusive same-column run. Inputs: leftval=x, rightval=y0, face_ymax=y1.
; The endpoint registers ex0/ex1/ey0/ey1 and the steep tracer target in fullcount are preserved.
plot_wire_vertical_run:
 ldx leftval
 lda xbyte,x
 sta startbyte
 lda startmask,x
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda rightval
 sta ycur
 lda #$ff
 sta spanh
.if TRACK_DIRTY_SPANS != 0
 lda drawbuf
 bne pvwr_dirty_global_b
 lda rightval
 cmp dirty_ymin_a
 bcs pvwr_dirty_a_ymin_ok
 sta dirty_ymin_a
pvwr_dirty_a_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_a
 bcc pvwr_loop
 sta dirty_ymax_a
 jmp pvwr_loop
pvwr_dirty_global_b:
 lda rightval
 cmp dirty_ymin_b
 bcs pvwr_dirty_b_ymin_ok
 sta dirty_ymin_b
pvwr_dirty_b_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_b
 bcc pvwr_loop
 sta dirty_ymax_b
.endif
pvwr_loop:
 lda ycur
 sta rightval
.if TRACK_DIRTY_SPANS != 0
 ldx ycur
 lda drawbuf
 bne pvwr_dirty_b
 lda startbyte
 cmp dirtymin_a,x
 bcs pvwr_dirty_a_min_ok
 sta dirtymin_a,x
pvwr_dirty_a_min_ok:
 lda startbyte
 cmp dirtymax_a,x
 bcc pvwr_dirty_done
 sta dirtymax_a,x
 jmp pvwr_dirty_done
pvwr_dirty_b:
 lda startbyte
 cmp dirtymin_b,x
 bcs pvwr_dirty_b_min_ok
 sta dirtymin_b,x
pvwr_dirty_b_min_ok:
 lda startbyte
 cmp dirtymax_b,x
 bcc pvwr_dirty_done
 sta dirtymax_b,x
pvwr_dirty_done:
.endif
 ldx ycur
 lda drawbuf
 bne pvwr_buffer_b
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jmp pvwr_rows_ready
pvwr_buffer_b:
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
pvwr_rows_ready:
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldy #$00
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0 || ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE != 0
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 ldx rightval
 lda viewport_cellrow_id,x
.else
 lda rightval
 and #$fc
.endif
 cmp spanh
 beq pvwr_material_done
 sta spanh
 jsr plot_wire_material
pvwr_material_done:
.endif
 lda ycur
 cmp face_ymax
 beq pvwr_done
 inc ycur
 jmp pvwr_loop
pvwr_done:
 rts
.endif

.if MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0 && GRAPHICS_MODE != $04 && GRAPHICS_MODE != $05 && GRAPHICS_MODE != $07
mode3_high_basic_relocated_code_end = *
.if mode3_high_basic_relocated_code_end > $a000
 .error "Mode 3 relocated full raster overlaps the high code segment"
.endif
* = $a000
mode3_high_basic_high_code_start = *
.endif
trace_edge_convex:
 lda ey0
 cmp ey1
 bcc tec_ordered
 bne tec_descending
 jmp tec_horizontal
tec_descending:
 sec
 lda ey0
 sbc ey1
 sta dyval
 lda ex0
 cmp ex1
 bcs tec_ldx_pos
 sec
 lda ex1
 sbc ex0
 sta dxabs
 lda #$ff
 sta sxstep
 jmp tec_ldx_done
tec_ldx_pos:
 sec
 lda ex0
 sbc ex1
 sta dxabs
 beq tec_lvertical
 lda #$01
 sta sxstep
tec_ldx_done:
 lda dxabs
 cmp dyval
 beq tec_ldiagonal
 lda ex1
 sta xcur
 lda ey1
 sta ycur
 lda #$00
 sta errlo
 sta errhi
.if ENGINE_MODE3_FAST_BOUNDS_TRACE != 0 || ENGINE_MODE4_FAST_BOUNDS_TRACE != 0
 ; err is always below dy. dx+dy<=256 therefore guarantees err+dx<=255.
 ; The only larger viewport combinations retain the validated 16-bit walker.
 clc
 lda dxabs
 adc dyval
 bcc sm3_fbt_l_dispatch
 beq sm3_fbt_l_dispatch
 jmp sm3_fbt_l_fallback16
sm3_fbt_l_dispatch:
 lda ey0
 sta fullcount
 lda sxstep
 bpl sm3_fbt_l_pos_dispatch
 jmp sm3_fbt_span_neg
sm3_fbt_l_pos_dispatch:
 jmp sm3_fbt_span_pos
sm3_fbt_l_fallback16:
.endif
.if ENGINE_WIRE_RASTER_CONSOLIDATION != 0
 ; Single gate for hidden-wire draw versus bounds/mask traces.
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_lconsolidated_trace_fallback
.endif
 ; One classifier: dx>dy -> scanline-run; dy>=2*dx -> vertical-run; otherwise Bresenham 8 bit.
 lda dxabs
 cmp dyval
 bcs tec_lconsolidated_scanline
 asl
 bcs tec_lconsolidated_trace_fallback
 cmp dyval
 bcc tec_lconsolidated_steep
 beq tec_lconsolidated_steep
 jmp tec_lconsolidated_bres8
tec_lconsolidated_scanline:
 lda sxstep
 bmi tec_lspan_neg
 jmp tec_lspan_pos
tec_lconsolidated_steep:
 lda ey0
 sta fullcount
 lda sxstep
 bmi tec_steep_neg
 jmp tec_steep_pos
tec_lconsolidated_bres8:
 lda ey0
 sta fullcount
 lda sxstep
 bmi tec_bres8_neg
 jmp tec_bres8_pos
tec_lconsolidated_trace_fallback:
.else
.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
 ; Use same-column runs only for strongly steep edges (dy >= 2*dx).
 lda dxabs
 asl
 bcs tec_lsteep_point_fallback
 cmp dyval
 bcc tec_lsteep_ratio_ok
 beq tec_lsteep_ratio_ok
 jmp tec_lsteep_point_fallback
tec_lsteep_ratio_ok:
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_lsteep_point_fallback
.endif
 lda ey0
 sta fullcount
 lda sxstep
 bmi tec_steep_neg
 jmp tec_steep_pos
tec_lsteep_point_fallback:
.endif
.if ENGINE_WIRE_SCANLINE_RUN_RASTERIZER != 0
 ; A shallow edge can emit several adjacent pixels on one scanline.
 ; Group dx>dy runs; strongly steep/vertical edges may use the separate column-run path.
 lda dxabs
 cmp dyval
 bcc tec_lscanline_point_fallback
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 ; Bounds/mask traces use wire_trace_active=0 and must retain per-point bounds updates.
 lda wire_trace_active
 beq tec_lscanline_point_fallback
.endif
 lda sxstep
 bmi tec_lspan_neg
 jmp tec_lspan_pos
tec_lscanline_point_fallback:
.endif
.if ENGINE_WIRE_8BIT_BRESENHAM != 0
 ; At this point scanline-run rejected dx>=dy and vertical-run rejected dy>=2*dx.
 ; The remaining wire-only range is dx<dy<2*dx, safe for an 8-bit error sum.
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 ; Hidden-wire bounds/mask traces keep the 16-bit fallback.
 lda wire_trace_active
 beq tec_lbres8_point_fallback
.endif
 lda ey0
 sta fullcount
 lda sxstep
 bpl tec_lbres8_pos_dispatch
 jmp tec_bres8_neg
tec_lbres8_pos_dispatch:
 jmp tec_bres8_pos
tec_lbres8_point_fallback:
.endif
.endif
.if DIRECT_CONVEX_EDGE_SPANS != 0
.if MODE5_POLYGON_OUTLINE != 0
 lda mode5_outline_trace_active
 bne tec_lspan_outline_skip
.endif
.if WIRE_RENDER_ENABLE != 0
 lda wire_trace_active
 bne tec_lspan_wire_skip
.endif
 lda sxstep
 bmi tec_lspan_neg
 jmp tec_lspan_pos
.if WIRE_RENDER_ENABLE != 0
tec_lspan_wire_skip:
.endif
.if MODE5_POLYGON_OUTLINE != 0
tec_lspan_outline_skip:
.endif
.endif
 lda sxstep
 bmi tec_lloop_neg
tec_lloop_pos:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey0
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_lstep_check_pos:
 lda errhi
 bne tec_lxstep_pos
 lda errlo
 cmp dyval
 bcc tec_lystep_pos
tec_lxstep_pos:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 inc xcur
.if FAST_FILL_BOUNDS_TRACE = 0 || WIRE_RENDER_ENABLE != 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 jmp tec_lstep_check_pos
tec_lystep_pos:
.if FAST_FILL_BOUNDS_TRACE != 0 && WIRE_RENDER_ENABLE = 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 inc ycur
 jmp tec_lloop_pos
tec_lloop_neg:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey0
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_lstep_check_neg:
 lda errhi
 bne tec_lxstep_neg
 lda errlo
 cmp dyval
 bcc tec_lystep_neg
tec_lxstep_neg:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 dec xcur
.if FAST_FILL_BOUNDS_TRACE = 0 || WIRE_RENDER_ENABLE != 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 jmp tec_lstep_check_neg
tec_lystep_neg:
.if FAST_FILL_BOUNDS_TRACE != 0 && WIRE_RENDER_ENABLE = 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 inc ycur
 jmp tec_lloop_neg
tec_lvertical:
.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_lvertical_point_fallback
.endif
 lda ex1
 sta leftval
 lda ey1
 sta rightval
 lda ey0
 sta face_ymax
 jmp plot_wire_vertical_run
tec_lvertical_point_fallback:
.endif
 lda ey1
 sta ycur
tec_lv_loop:
 ldx ycur
 lda ex1
 jsr update_convex_bounds
 lda ycur
 cmp ey0
 beq tec_done
 inc ycur
 jmp tec_lv_loop
tec_ldiagonal:
 lda ex1
 sta xcur
 lda ey1
 sta ycur
 lda sxstep
 bmi tec_ld_loop_neg
tec_ld_loop_pos:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey0
 beq tec_done
 inc xcur
 inc ycur
 jmp tec_ld_loop_pos
tec_ld_loop_neg:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey0
 beq tec_done
 dec xcur
 inc ycur
 jmp tec_ld_loop_neg
tec_ordered:
 sec
 lda ey1
 sbc ey0
 sta dyval
 lda ex1
 cmp ex0
 bcs tec_rdx_pos
 sec
 lda ex0
 sbc ex1
 sta dxabs
 lda #$ff
 sta sxstep
 jmp tec_rdx_done
tec_rdx_pos:
 sec
 lda ex1
 sbc ex0
 sta dxabs
 beq tec_rvertical
 lda #$01
 sta sxstep
tec_rdx_done:
 lda dxabs
 cmp dyval
 beq tec_rdiagonal
 lda ex0
 sta xcur
 lda ey0
 sta ycur
 lda #$00
 sta errlo
 sta errhi
.if ENGINE_MODE3_FAST_BOUNDS_TRACE != 0 || ENGINE_MODE4_FAST_BOUNDS_TRACE != 0
 ; Same byte-safety contract as the descending branch.
 clc
 lda dxabs
 adc dyval
 bcc sm3_fbt_r_dispatch
 beq sm3_fbt_r_dispatch
 jmp sm3_fbt_r_fallback16
sm3_fbt_r_dispatch:
 lda ey1
 sta fullcount
 lda sxstep
 bpl sm3_fbt_r_pos_dispatch
 jmp sm3_fbt_span_neg
sm3_fbt_r_pos_dispatch:
 jmp sm3_fbt_span_pos
sm3_fbt_r_fallback16:
.endif
.if ENGINE_WIRE_RASTER_CONSOLIDATION != 0
 ; Single gate for hidden-wire draw versus bounds/mask traces.
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_rconsolidated_trace_fallback
.endif
 ; One classifier: dx>dy -> scanline-run; dy>=2*dx -> vertical-run; otherwise Bresenham 8 bit.
 lda dxabs
 cmp dyval
 bcs tec_rconsolidated_scanline
 asl
 bcs tec_rconsolidated_trace_fallback
 cmp dyval
 bcc tec_rconsolidated_steep
 beq tec_rconsolidated_steep
 jmp tec_rconsolidated_bres8
tec_rconsolidated_scanline:
 lda sxstep
 bmi tec_rspan_neg
 jmp tec_rspan_pos
tec_rconsolidated_steep:
 lda ey1
 sta fullcount
 lda sxstep
 bmi tec_steep_neg
 jmp tec_steep_pos
tec_rconsolidated_bres8:
 lda ey1
 sta fullcount
 lda sxstep
 bmi tec_bres8_neg
 jmp tec_bres8_pos
tec_rconsolidated_trace_fallback:
.else
.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
 ; Use same-column runs only for strongly steep edges (dy >= 2*dx).
 lda dxabs
 asl
 bcs tec_rsteep_point_fallback
 cmp dyval
 bcc tec_rsteep_ratio_ok
 beq tec_rsteep_ratio_ok
 jmp tec_rsteep_point_fallback
tec_rsteep_ratio_ok:
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_rsteep_point_fallback
.endif
 lda ey1
 sta fullcount
 lda sxstep
 bmi tec_steep_neg
 jmp tec_steep_pos
tec_rsteep_point_fallback:
.endif
.if ENGINE_WIRE_SCANLINE_RUN_RASTERIZER != 0
 lda dxabs
 cmp dyval
 bcc tec_rscanline_point_fallback
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_rscanline_point_fallback
.endif
 lda sxstep
 bmi tec_rspan_neg
 jmp tec_rspan_pos
tec_rscanline_point_fallback:
.endif
.if ENGINE_WIRE_8BIT_BRESENHAM != 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 ; Hidden-wire bounds/mask traces keep the 16-bit fallback.
 lda wire_trace_active
 beq tec_rbres8_point_fallback
.endif
 lda ey1
 sta fullcount
 lda sxstep
 bpl tec_rbres8_pos_dispatch
 jmp tec_bres8_neg
tec_rbres8_pos_dispatch:
 jmp tec_bres8_pos
tec_rbres8_point_fallback:
.endif
.endif
.if DIRECT_CONVEX_EDGE_SPANS != 0
.if MODE5_POLYGON_OUTLINE != 0
 lda mode5_outline_trace_active
 bne tec_rspan_outline_skip
.endif
.if WIRE_RENDER_ENABLE != 0
 lda wire_trace_active
 bne tec_rspan_wire_skip
.endif
 lda sxstep
 bmi tec_rspan_neg
 jmp tec_rspan_pos
.if WIRE_RENDER_ENABLE != 0
tec_rspan_wire_skip:
.endif
.if MODE5_POLYGON_OUTLINE != 0
tec_rspan_outline_skip:
.endif
.endif
 lda sxstep
 bmi tec_rloop_neg
tec_rloop_pos:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey1
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_rstep_check_pos:
 lda errhi
 bne tec_rxstep_pos
 lda errlo
 cmp dyval
 bcc tec_rystep_pos
tec_rxstep_pos:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 inc xcur
.if FAST_FILL_BOUNDS_TRACE = 0 || WIRE_RENDER_ENABLE != 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 jmp tec_rstep_check_pos
tec_rystep_pos:
.if FAST_FILL_BOUNDS_TRACE != 0 && WIRE_RENDER_ENABLE = 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 inc ycur
 jmp tec_rloop_pos
tec_rloop_neg:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey1
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_rstep_check_neg:
 lda errhi
 bne tec_rxstep_neg
 lda errlo
 cmp dyval
 bcc tec_rystep_neg
tec_rxstep_neg:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 dec xcur
.if FAST_FILL_BOUNDS_TRACE = 0 || WIRE_RENDER_ENABLE != 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 jmp tec_rstep_check_neg
tec_rystep_neg:
.if FAST_FILL_BOUNDS_TRACE != 0 && WIRE_RENDER_ENABLE = 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 inc ycur
 jmp tec_rloop_neg
tec_rvertical:
.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_rvertical_point_fallback
.endif
 lda ex0
 sta leftval
 lda ey0
 sta rightval
 lda ey1
 sta face_ymax
 jmp plot_wire_vertical_run
tec_rvertical_point_fallback:
.endif
 lda ey0
 sta ycur
tec_rv_loop:
 ldx ycur
 lda ex0
 jsr update_convex_bounds
 lda ycur
 cmp ey1
 beq tec_done
 inc ycur
 jmp tec_rv_loop
tec_rdiagonal:
 lda ex0
 sta xcur
 lda ey0
 sta ycur
 lda sxstep
 bmi tec_rd_loop_neg
tec_rd_loop_pos:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey1
 beq tec_done
 inc xcur
 inc ycur
 jmp tec_rd_loop_pos
tec_rd_loop_neg:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey1
 beq tec_done
 dec xcur
 inc ycur
 jmp tec_rd_loop_neg
tec_done:
 rts

.if ENGINE_WIRE_8BIT_BRESENHAM != 0
; Connected 8-bit Bresenham for the intermediate y-major range dx<dy<2*dx.
; The sum err+dx is <2*dy and dy<=PROJ_SCREEN_MAX_Y, so errhi is unnecessary.
; A horizontal bridge point is emitted on x transitions to preserve the exact reference pixel set.
tec_bres8_pos:
tec_bres8_pos_loop:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp fullcount
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 cmp dyval
 bcc tec_bres8_pos_ystep
 sec
 sbc dyval
 sta errlo
 inc xcur
 ldx ycur
 lda xcur
 jsr update_convex_bounds
tec_bres8_pos_ystep:
 inc ycur
 jmp tec_bres8_pos_loop

tec_bres8_neg:
tec_bres8_neg_loop:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp fullcount
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 cmp dyval
 bcc tec_bres8_neg_ystep
 sec
 sbc dyval
 sta errlo
 dec xcur
 ldx ycur
 lda xcur
 jsr update_convex_bounds
tec_bres8_neg_ystep:
 inc ycur
 jmp tec_bres8_neg_loop
.endif

.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
; Strongly steep lines keep one vertical run per x and use a point only for
; the horizontal bridge emitted by the original connected-edge tracer.
tec_steep_pos:
 lda ycur
 sta spanw
tec_steep_pos_loop:
 lda ycur
 cmp fullcount
 beq tec_steep_pos_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 cmp dyval
 bcc tec_steep_pos_ystep
 sec
 sbc dyval
 sta errlo
 lda xcur
 sta leftval
 lda spanw
 sta rightval
 lda ycur
 sta face_ymax
 jsr plot_wire_vertical_run
 inc xcur
 lda xcur
 sta leftval
 lda ycur
 sta rightval
 jsr plot_wire_point
 inc ycur
 lda ycur
 sta spanw
 jmp tec_steep_pos_loop
tec_steep_pos_ystep:
 inc ycur
 jmp tec_steep_pos_loop
tec_steep_pos_done:
 lda xcur
 sta leftval
 lda spanw
 sta rightval
 lda ycur
 sta face_ymax
 jmp plot_wire_vertical_run

tec_steep_neg:
 lda ycur
 sta spanw
tec_steep_neg_loop:
 lda ycur
 cmp fullcount
 beq tec_steep_neg_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 cmp dyval
 bcc tec_steep_neg_ystep
 sec
 sbc dyval
 sta errlo
 lda xcur
 sta leftval
 lda spanw
 sta rightval
 lda ycur
 sta face_ymax
 jsr plot_wire_vertical_run
 dec xcur
 lda xcur
 sta leftval
 lda ycur
 sta rightval
 jsr plot_wire_point
 inc ycur
 lda ycur
 sta spanw
 jmp tec_steep_neg_loop
tec_steep_neg_ystep:
 inc ycur
 jmp tec_steep_neg_loop
tec_steep_neg_done:
 lda xcur
 sta leftval
 lda spanw
 sta rightval
 lda ycur
 sta face_ymax
 jmp plot_wire_vertical_run
.endif

.if ENGINE_MODE3_FAST_BOUNDS_TRACE != 0 || ENGINE_MODE4_FAST_BOUNDS_TRACE != 0
; C64 fast bounds edge walker. Mode 3 uses it for fallback faces;
; Mode 4 uses it for its generic left/right bounds path.
; spanw/spanh are always ordered left/right, so both tables are updated in one call.
sm3_fbt_flush_span:
 ldx ycur
 lda spanw
 cmp leftb,x
 bcs sm3_fbt_left_ok
 sta leftb,x
sm3_fbt_left_ok:
 lda spanh
 cmp rightb,x
 bcc sm3_fbt_flush_done
 sta rightb,x
sm3_fbt_flush_done:
 rts

sm3_fbt_span_pos:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp fullcount
 beq sm3_fbt_span_pos_done
 clc
 lda errlo
 adc dxabs
 sta errlo
sm3_fbt_span_pos_check:
 cmp dyval
 bcc sm3_fbt_span_pos_y
 sec
 sbc dyval
 sta errlo
 inc xcur
 lda xcur
 sta spanh
 lda errlo
 jmp sm3_fbt_span_pos_check
sm3_fbt_span_pos_y:
 jsr sm3_fbt_flush_span
 inc ycur
 jmp sm3_fbt_span_pos
sm3_fbt_span_pos_done:
 jsr sm3_fbt_flush_span
 rts

sm3_fbt_span_neg:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp fullcount
 beq sm3_fbt_span_neg_done
 clc
 lda errlo
 adc dxabs
 sta errlo
sm3_fbt_span_neg_check:
 cmp dyval
 bcc sm3_fbt_span_neg_y
 sec
 sbc dyval
 sta errlo
 dec xcur
 lda xcur
 sta spanw
 lda errlo
 jmp sm3_fbt_span_neg_check
sm3_fbt_span_neg_y:
 jsr sm3_fbt_flush_span
 inc ycur
 jmp sm3_fbt_span_neg
sm3_fbt_span_neg_done:
 jsr sm3_fbt_flush_span
 rts
.endif

.if DIRECT_CONVEX_EDGE_SPANS != 0 || ENGINE_WIRE_SCANLINE_RUN_RASTERIZER != 0
tec_flush_span:
.if ENGINE_WIRE_SCANLINE_RUN_RASTERIZER != 0
 ; Preserve the point hot loop for one-pixel runs.
 lda spanw
 cmp spanh
 bne tfs_wire_run
 ldx ycur
 lda spanw
 jmp update_convex_bounds
tfs_wire_run:
 ; Keep ex0/ex1/ey0/ey1 unchanged: trace_edge_convex still needs the
 ; original endpoint state after this run returns.
 lda ycur
 sta rightval
 lda spanw
 sta leftval
 lda spanh
 sta face_ymax
 jmp pwh_span
.else
 ldx ycur
 lda spanw
 jsr update_convex_bounds
 lda spanh
 cmp spanw
 beq tfs_done
 ldx ycur
 lda spanh
 jsr update_convex_bounds
tfs_done:
 rts
.endif

tec_lspan_pos:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp ey0
 beq tec_lspan_pos_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_lspan_pos_check:
 lda errhi
 bne tec_lspan_pos_x
 lda errlo
 cmp dyval
 bcc tec_lspan_pos_y
tec_lspan_pos_x:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 inc xcur
 lda xcur
 sta spanh
 jmp tec_lspan_pos_check
tec_lspan_pos_y:
 jsr tec_flush_span
 inc ycur
 jmp tec_lspan_pos
tec_lspan_pos_done:
 jsr tec_flush_span
 rts

tec_lspan_neg:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp ey0
 beq tec_lspan_neg_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_lspan_neg_check:
 lda errhi
 bne tec_lspan_neg_x
 lda errlo
 cmp dyval
 bcc tec_lspan_neg_y
tec_lspan_neg_x:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 dec xcur
 lda xcur
 sta spanw
 jmp tec_lspan_neg_check
tec_lspan_neg_y:
 jsr tec_flush_span
 inc ycur
 jmp tec_lspan_neg
tec_lspan_neg_done:
 jsr tec_flush_span
 rts

tec_rspan_pos:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp ey1
 beq tec_rspan_pos_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_rspan_pos_check:
 lda errhi
 bne tec_rspan_pos_x
 lda errlo
 cmp dyval
 bcc tec_rspan_pos_y
tec_rspan_pos_x:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 inc xcur
 lda xcur
 sta spanh
 jmp tec_rspan_pos_check
tec_rspan_pos_y:
 jsr tec_flush_span
 inc ycur
 jmp tec_rspan_pos
tec_rspan_pos_done:
 jsr tec_flush_span
 rts

tec_rspan_neg:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp ey1
 beq tec_rspan_neg_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_rspan_neg_check:
 lda errhi
 bne tec_rspan_neg_x
 lda errlo
 cmp dyval
 bcc tec_rspan_neg_y
tec_rspan_neg_x:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 dec xcur
 lda xcur
 sta spanw
 jmp tec_rspan_neg_check
tec_rspan_neg_y:
 jsr tec_flush_span
 inc ycur
 jmp tec_rspan_neg
tec_rspan_neg_done:
 jsr tec_flush_span
 rts
.endif

tec_horizontal:
.if MODE5_POLYGON_OUTLINE != 0
 lda mode5_outline_trace_active
 beq tec_horizontal_normal
 jmp mode5_trace_background_horizontal
tec_horizontal_normal:
.endif
.if WIRE_RENDER_ENABLE != 0
.if POLY_FILL_ENABLE = 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_horizontal_bounds
 jmp plot_wire_horizontal
tec_horizontal_bounds:
.else
 jmp plot_wire_horizontal
.endif
.else
 lda wire_trace_active
 beq tec_horizontal_bounds
 jmp plot_wire_horizontal
tec_horizontal_bounds:
.endif
.endif
 ldx ey0
 lda ex0
 jsr update_convex_bounds
 ldx ey0
 lda ex1
 jsr update_convex_bounds
 rts

.if MODE5_POLYGON_OUTLINE != 0 && MEMORY_LAYOUT_HIGH_BASIC_V2 = 0
mode5_stable_code_end = *
.if mode5_stable_code_start != $9100
 .error "Mode 5 stable relocated code did not start at $9100"
.endif
.if mode5_stable_code_end > $9f00
 .error "Mode 5 stable relocated code leaves less than 256 bytes before bitmap B"
.endif
* = mode5_stable_low_return
mode5_stable_low_resume = *
.endif

.if POLY_FILL_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0 || (HIDDEN_WIRE_ENABLE != 0 && (WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0))
setup_face_y_bounds:
 lda vy0
 sta face_ymin
 sta face_ymax
 lda vy1
 cmp face_ymin
 bcs sty_v1_min_ok
 sta face_ymin
sty_v1_min_ok:
 cmp face_ymax
 bcc sty_v1_max_ok
 sta face_ymax
sty_v1_max_ok:
 lda vy2
 cmp face_ymin
 bcs sty_v2_min_ok
 sta face_ymin
sty_v2_min_ok:
 cmp face_ymax
 bcc sty_v2_max_ok
 sta face_ymax
sty_v2_max_ok:
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne sty_done
.endif
 lda vy3
 cmp face_ymin
 bcs sty_v3_min_ok
 sta face_ymin
sty_v3_min_ok:
 cmp face_ymax
 bcc sty_done
 sta face_ymax
sty_done:
.if SCENE_OBJECT_COUNT != 0
 lda face_ymin
 cmp #SCENE_RENDER_MIN_Y
 bcs sty_done_rts
 lda #SCENE_RENDER_MIN_Y
 sta face_ymin
sty_done_rts:
.endif
 rts
.endif

.if POLY_FILL_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0 || (HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0)
fill_bounds_solid_a:
.if TRACK_DIRTY_SPANS != 0
 lda face_ymin
 cmp dirty_ymin_a
 bcs fbs_a_dirty_ymin_ok
 sta dirty_ymin_a
fbs_a_dirty_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_a
 bcc fbs_a_dirty_ymax_ok
 sta dirty_ymax_a
fbs_a_dirty_ymax_ok:
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
.endif
 ldx face_ymin
fbs_a_row:
.if LAZY_CONVEX_BOUNDS != 0
 lda bounds_stamp,x
 cmp bounds_stamp_cur
 bne fbs_a_next
.endif
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc fbs_a_next
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq fbs_a_draw
 jsr lowres_row_selected
 bne fbs_a_next
.endif
fbs_a_draw:
 stx yrow
fbs_a_fill_ready:
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_a
.else
 jsr apply_material_span_a
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_a,x
 bcs fbs_a_dirty_min_ok
 sta dirtymin_a,x
fbs_a_dirty_min_ok:
 lda endbyte
 cmp dirtymax_a,x
 bcc fbs_a_dirty_done
 sta dirtymax_a,x
fbs_a_dirty_done:
.endif
 ldy #$00
 lda startbyte
 cmp endbyte
 bne fbs_a_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbs_a_next_restore
fbs_a_multi:
.if INDEXED_OFFSET_SPAN_FILL != 0
 lda endbyte
 sec
 sbc startbyte
.if ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS != 0 && SPAN_KERNEL_FILL != 0
 cmp #$06
 bcc fbs_a_indexed_fallback
.endif
 cmp #$20
 bcs fbs_a_indexed_fallback
 sta fullcount
 ldy #$00
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda fullcount
 cmp #$01
 beq fbs_a_indexed_end_at_08
 sec
 sbc #$01
 sta p1hi
 lda fillbyte
 ldy #$08
fbs_a_indexed_mid_loop:
 sta (ptr0lo),y
 sta (ptr1lo),y
 tya
 clc
 adc #$08
 tay
 lda fillbyte
 dec p1hi
 bne fbs_a_indexed_mid_loop
 jmp fbs_a_indexed_draw_end_y
fbs_a_indexed_end_at_08:
 ldy #$08
fbs_a_indexed_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbs_a_next_restore
fbs_a_indexed_fallback:
 ldy #$00
.endif
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 cmp #$01
 bne fbs_a_maybe_three
fbs_a_two_byte:
.if SPAN_KERNEL_FILL != 0
 ldy #$08
 jmp fbs_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_two0_ok
 inc ptr0hi
fbs_a_two0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_two1_ok
 inc ptr1hi
fbs_a_two1_ok:
 jmp fbs_a_draw_end
.endif
fbs_a_maybe_three:
 cmp #$02
 bne fbs_a_maybe_four
fbs_a_three_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 jmp fbs_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_three0_mid_ok
 inc ptr0hi
fbs_a_three0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_three1_mid_ok
 inc ptr1hi
fbs_a_three1_mid_ok:
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_three0_end_ok
 inc ptr0hi
fbs_a_three0_end_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_three1_end_ok
 inc ptr1hi
fbs_a_three1_end_ok:
 jmp fbs_a_draw_end
.endif
fbs_a_maybe_four:
 cmp #$03
 bne fbs_a_maybe_five
fbs_a_four_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 jmp fbs_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_four0_mid_ok
 inc ptr0hi
fbs_a_four0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_four1_mid_ok
 inc ptr1hi
fbs_a_four1_mid_ok:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbs_a_four0_end_ok
 inc ptr0hi
fbs_a_four0_end_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbs_a_four1_end_ok
 inc ptr1hi
fbs_a_four1_end_ok:
 jmp fbs_a_draw_end
.endif
fbs_a_maybe_five:
 cmp #$04
 bne fbs_a_maybe_six
fbs_a_five_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 jmp fbs_a_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$20
 sta ptr0lo
 bcc fbs_a_five0_end_ok
 inc ptr0hi
fbs_a_five0_end_ok:
 clc
 lda ptr1lo
 adc #$20
 sta ptr1lo
 bcc fbs_a_five1_end_ok
 inc ptr1hi
fbs_a_five1_end_ok:
 jmp fbs_a_draw_end
.endif
fbs_a_maybe_six:
 cmp #$05
 bne fbs_a_multi_long
fbs_a_six_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$28
 jmp fbs_a_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$28
 sta ptr0lo
 bcc fbs_a_six0_end_ok
 inc ptr0hi
fbs_a_six0_end_ok:
 clc
 lda ptr1lo
 adc #$28
 sta ptr1lo
 bcc fbs_a_six1_end_ok
 inc ptr1hi
fbs_a_six1_end_ok:
 jmp fbs_a_draw_end
.endif
fbs_a_multi_long:
 sta fullcount
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_mid0_ok
 inc ptr0hi
fbs_a_mid0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_mid1_ok
 inc ptr1hi
fbs_a_mid1_ok:
 dec fullcount
 beq fbs_a_draw_end
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq fbs_a_mid_odd_check
fbs_a_mid_pair_loop:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbs_a_m0_noc
 inc ptr0hi
fbs_a_m0_noc:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbs_a_m1_noc
 inc ptr1hi
fbs_a_m1_noc:
 dec p1lo
 bne fbs_a_mid_pair_loop
fbs_a_mid_odd_check:
 lda p1hi
 beq fbs_a_draw_end
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_odd0_ok
 inc ptr0hi
fbs_a_odd0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_odd1_ok
 inc ptr1hi
fbs_a_odd1_ok:
fbs_a_draw_end:
 ldy #$00
fbs_a_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
fbs_a_next_restore:
 ldx yrow
fbs_a_next:
 cpx face_ymax
 beq fbs_a_done
 inx
 jmp fbs_a_row
fbs_a_done:
 rts

.endif
.if MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0 && ($04 = GRAPHICS_MODE || GRAPHICS_MODE = $05 || GRAPHICS_MODE = $07)
mode3_high_basic_relocated_code_end = *
.if CAMERA_MOVABLE != 0 && FPS_OVERLAY_ENABLE != 0 && MODE7_UV_CARRIER = 0 && mode3_high_basic_relocated_code_end > $9b80
 .error "Mode 4/5 relocated raster code overlaps relocated camera block ($9B80)"
.endif
.if mode3_high_basic_relocated_code_end > $a000
 .error "Mode 4/5 relocated full raster overlaps the high code segment"
.endif
* = $a000
mode3_high_basic_high_code_start = *
.endif
.if GOURAUD_BYTE_SPAN_KERNEL != 0
; Gate 5: exact partial-byte aggregation. The Gate 3 full-byte samples and
; the shade DDA are unchanged. Each partial byte is read/modified once per
; physical row; bitmap pointers persist until crossing a byte boundary.
; Q8-only: old integer polygon clip retired.
gouraud_build_edge_shades_v = hp_unreachable
gbes_init_v = hp_unreachable
gbes_edges_v = hp_unreachable
.if HAS_TRI_FACES != 0
.endif
gbes_close_triangle_v = hp_unreachable
gbes_close_common_v = hp_unreachable
gouraud_trace_shade_edge_v = hp_unreachable
gtse_ordered_v = hp_unreachable
r1_x_bias_done_v = hp_unreachable
gtse_loop_v = hp_unreachable
r1_edge_sample_v = hp_unreachable
demo_edge_x_v_correct = hp_unreachable
demo_edge_x_v_store = hp_unreachable
demo_edge_x_v_done = hp_unreachable
demo_edge_s_v_correct = hp_unreachable
demo_edge_s_v_store = hp_unreachable
demo_edge_s_v_done = hp_unreachable
gtse_horizontal_v = hp_unreachable
gtse_done_v = hp_unreachable
gouraud_store_edge_sample_v = hp_unreachable
seam_in_range_v = hp_unreachable
seam_right_check_v = hp_unreachable
seam_done_v = hp_unreachable
; Mode 7 affine Q4.4. No lighting and no division/multiply in the texel loop.
gouraud_draw_scan_span_bytes:
 jsr gouraud_init_span_pointers
m7_byte_dispatch:
 lda gouraud_scan_x
 and #3
 bne m7_partial
 lda gouraud_scan_end
 sec
 sbc gouraud_scan_x
 cmp #3
 bcc m7_partial
m7_full_byte:
 jmp fx_full_byte
fx_old_after_first:
 asl
 asl
 asl
 asl
 asl
 asl
 sta m7_packed
 jsr m7_advance
 jsr m7_sample
 asl
 asl
 asl
 asl
 ora m7_packed
 sta m7_packed
 jsr m7_advance
 jsr m7_sample
 asl
 asl
 ora m7_packed
 sta m7_packed
 jsr m7_advance
 jsr m7_sample
 ora m7_packed
m7_full_write:
 ldy #0
 sta (ptr0lo),y
 sta (ptr1lo),y
 lda gouraud_scan_x
 cmp gouraud_scan_end
 beq m7_span_done
 jsr m7_advance
 jmp m7_next_byte
m7_partial:
 lda #0
 sta m7_packed
 lda #255
 sta maskv
m7_partial_sample:
 lda gouraud_scan_x
 and #3
 sta shadeidx
 jsr m7_sample
 asl
 asl
 ora shadeidx
 tay
 lda m7_pair,y
 ora m7_packed
 sta m7_packed
 ldx shadeidx
 lda gouraud_pair_clear,x
 and maskv
 sta maskv
 cpx #3
 beq m7_partial_write
 lda gouraud_scan_x
 cmp gouraud_scan_end
 beq m7_partial_write
 jsr m7_advance
 jmp m7_partial_sample
m7_partial_write:
 ldy #0
 lda (ptr0lo),y
 and maskv
 ora m7_packed
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora m7_packed
 sta (ptr1lo),y
 lda gouraud_scan_x
 cmp gouraud_scan_end
 beq m7_span_done
 jsr m7_advance
m7_next_byte:
 clc
 lda ptr0lo
 adc #8
 sta ptr0lo
 bcc m7_ptr0_done
 inc ptr0hi
m7_ptr0_done:
 clc
 lda ptr1lo
 adc #8
 sta ptr1lo
 bcc m7_ptr1_done
 inc ptr1hi
m7_ptr1_done:
 jmp m7_byte_dispatch
m7_span_done:
 rts

; Texture is page aligned. (V & $f0) | (U >> 4) selects one of 256 texels.
; Operand high byte is set once per face; same texture for clipped fan.
m7_sample:
 jsr ps_sample
m7_address_begin:
 lda m7_v
 asl
 asl
 asl
 and #$f0
 sta m7_index
 lda m7_u
 lsr
 and #$0f
 ora m7_index
 tay
m7_fetch:
 lda m7_texture_0,y
m7_fetch_end:
 jmp m3_composite

; One quotient add and at most one remainder correction per channel.
; Carry from the error sum is explicitly included (span can exceed 128).
m7_advance:
 jmp ps_advance

m7_prepare_span:
 jmp ps_prepare_span

; A=start, X=end, m7_den=length. Signed magnitude quotient/remainder.
; Setup only, never in the texture fetch / per-pixel hot loop.
m7_dda_setup:
 sta m7_start
 stx m7_delta
 lda #1
 sta m7_dir
 sec
 lda m7_delta
 sbc m7_start
 bcs m7_dda_positive
 eor #255
 clc
 adc #1
 ldx #255
 stx m7_dir
m7_dda_positive:
 sta m7_r
 lda #0
 sta m7_q
 lda m7_den
 beq m7_dda_zero
 lda m7_r
m7_dda_divide:
 cmp m7_den
 bcc m7_dda_remainder
 sec
 sbc m7_den
 inc m7_q
 jmp m7_dda_divide
m7_dda_remainder:
 sta m7_r
 lda m7_dir
 bpl m7_dda_done
 sec
 lda #0
 sbc m7_q
 sta m7_q
m7_dda_done:
 rts
m7_dda_zero:
 sta m7_r
 rts

; Signed, pre-viewport table-projection result in A; return A unchanged.
; This fills the raw coordinates required by polygon UV clipping for fixed
; cameras. Walk cameras already produce their own raw 16-bit coordinates.
m7_store_fixed_raw_x:
 sta p1lo
 ldy #0
 cmp #$80
 bcc m7_raw_x_positive
 dey
m7_raw_x_positive:
 sty p1hi
 ldy tmpidx
 clc
 adc #PROJ_CENTER_X
 sta pxrawlo,y
 lda p1hi
 adc #0
 sta pxrawhi,y
 lda p1lo
 rts
m7_store_fixed_raw_y:
 sta p1lo
 ldy #0
 cmp #$80
 bcc m7_raw_y_positive
 dey
m7_raw_y_positive:
 sty p1hi
 ldy tmpidx
 sec
 lda #PROJ_CENTER_Y
 sbc p1lo
 sta pyrawlo,y
 lda #0
 sbc p1hi
 sta pyrawhi,y
 lda p1lo
 rts

m7_sync_clipped_xyq2:
 lda vx0
 sta vxq2_0lo
 lda #0
 sta vxq2_0hi
 asl vxq2_0lo
 rol vxq2_0hi
 asl vxq2_0lo
 rol vxq2_0hi
 lda vy0
 sta vyq2_0lo
 lda #0
 sta vyq2_0hi
 asl vyq2_0lo
 rol vyq2_0hi
 asl vyq2_0lo
 rol vyq2_0hi
 lda vx1
 sta vxq2_1lo
 lda #0
 sta vxq2_1hi
 asl vxq2_1lo
 rol vxq2_1hi
 asl vxq2_1lo
 rol vxq2_1hi
 lda vy1
 sta vyq2_1lo
 lda #0
 sta vyq2_1hi
 asl vyq2_1lo
 rol vyq2_1hi
 asl vyq2_1lo
 rol vyq2_1hi
 lda vx2
 sta vxq2_2lo
 lda #0
 sta vxq2_2hi
 asl vxq2_2lo
 rol vxq2_2hi
 asl vxq2_2lo
 rol vxq2_2hi
 lda vy2
 sta vyq2_2lo
 lda #0
 sta vyq2_2hi
 asl vyq2_2lo
 rol vyq2_2hi
 asl vyq2_2lo
 rol vyq2_2hi
 lda vx3
 sta vxq2_3lo
 lda #0
 sta vxq2_3hi
 asl vxq2_3lo
 rol vxq2_3hi
 asl vxq2_3lo
 rol vxq2_3hi
 lda vy3
 sta vyq2_3lo
 lda #0
 sta vyq2_3hi
 asl vyq2_3lo
 rol vyq2_3hi
 asl vyq2_3lo
 rol vyq2_3hi
 rts
.endif
.if POLY_FILL_ENABLE != 0 && HIDDEN_WIRE_ENABLE = 0
fill_bounds_pattern_a:
.if TRACK_DIRTY_SPANS != 0
 lda face_ymin
 cmp dirty_ymin_a
 bcs fbp_a_dirty_ymin_ok
 sta dirty_ymin_a
fbp_a_dirty_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_a
 bcc fbp_a_dirty_ymax_ok
 sta dirty_ymax_a
fbp_a_dirty_ymax_ok:
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
.endif
 ldy shadeidx
 lda shade_pattern_bytes,y
 sta p1lo
 iny
 lda shade_pattern_bytes,y
 sta p1hi
 eor p1lo
 sta pattoggle
 lda face_ymin
 and #$01
 beq fbp_a_even_start
 lda p1hi
 jmp fbp_a_store_start
fbp_a_even_start:
 lda p1lo
fbp_a_store_start:
 sta fillbyte
 ldx face_ymin
fbp_a_row:
.if LAZY_CONVEX_BOUNDS != 0
 lda bounds_stamp,x
 cmp bounds_stamp_cur
 bne fbp_a_next
.endif
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc fbp_a_next
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq fbp_a_draw
 jsr lowres_row_selected
 bne fbp_a_next
.endif
fbp_a_draw:
 stx yrow
fbp_a_fill_ready:
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_a
.else
 jsr apply_material_span_a
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_a,x
 bcs fbp_a_dirty_min_ok
 sta dirtymin_a,x
fbp_a_dirty_min_ok:
 lda endbyte
 cmp dirtymax_a,x
 bcc fbp_a_dirty_done
 sta dirtymax_a,x
fbp_a_dirty_done:
.endif
 ldy #$00
 lda startbyte
 cmp endbyte
 bne fbp_a_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbp_a_next_restore
fbp_a_multi:
.if INDEXED_OFFSET_SPAN_FILL != 0
 lda endbyte
 sec
 sbc startbyte
.if ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS != 0 && SPAN_KERNEL_FILL != 0
 cmp #$06
 bcc fbp_a_indexed_fallback
.endif
 cmp #$20
 bcs fbp_a_indexed_fallback
 sta fullcount
 ldy #$00
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda fullcount
 cmp #$01
 beq fbp_a_indexed_end_at_08
 sec
 sbc #$01
 sta p1hi
 lda fillbyte
 ldy #$08
fbp_a_indexed_mid_loop:
 sta (ptr0lo),y
 sta (ptr1lo),y
 tya
 clc
 adc #$08
 tay
 lda fillbyte
 dec p1hi
 bne fbp_a_indexed_mid_loop
 jmp fbp_a_indexed_draw_end_y
fbp_a_indexed_end_at_08:
 ldy #$08
fbp_a_indexed_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbp_a_next_restore
fbp_a_indexed_fallback:
 ldy #$00
.endif
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 cmp #$01
 bne fbp_a_maybe_three
fbp_a_two_byte:
.if SPAN_KERNEL_FILL != 0
 ldy #$08
 jmp fbp_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_two0_ok
 inc ptr0hi
fbp_a_two0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_two1_ok
 inc ptr1hi
fbp_a_two1_ok:
 jmp fbp_a_draw_end
.endif
fbp_a_maybe_three:
 cmp #$02
 bne fbp_a_maybe_four
fbp_a_three_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 jmp fbp_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_three0_mid_ok
 inc ptr0hi
fbp_a_three0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_three1_mid_ok
 inc ptr1hi
fbp_a_three1_mid_ok:
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_three0_end_ok
 inc ptr0hi
fbp_a_three0_end_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_three1_end_ok
 inc ptr1hi
fbp_a_three1_end_ok:
 jmp fbp_a_draw_end
.endif
fbp_a_maybe_four:
 cmp #$03
 bne fbp_a_maybe_five
fbp_a_four_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 jmp fbp_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_four0_mid_ok
 inc ptr0hi
fbp_a_four0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_four1_mid_ok
 inc ptr1hi
fbp_a_four1_mid_ok:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbp_a_four0_end_ok
 inc ptr0hi
fbp_a_four0_end_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbp_a_four1_end_ok
 inc ptr1hi
fbp_a_four1_end_ok:
 jmp fbp_a_draw_end
.endif
fbp_a_maybe_five:
 cmp #$04
 bne fbp_a_maybe_six
fbp_a_five_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 jmp fbp_a_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$20
 sta ptr0lo
 bcc fbp_a_five0_end_ok
 inc ptr0hi
fbp_a_five0_end_ok:
 clc
 lda ptr1lo
 adc #$20
 sta ptr1lo
 bcc fbp_a_five1_end_ok
 inc ptr1hi
fbp_a_five1_end_ok:
 jmp fbp_a_draw_end
.endif
fbp_a_maybe_six:
 cmp #$05
 bne fbp_a_multi_long
fbp_a_six_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$28
 jmp fbp_a_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$28
 sta ptr0lo
 bcc fbp_a_six0_end_ok
 inc ptr0hi
fbp_a_six0_end_ok:
 clc
 lda ptr1lo
 adc #$28
 sta ptr1lo
 bcc fbp_a_six1_end_ok
 inc ptr1hi
fbp_a_six1_end_ok:
 jmp fbp_a_draw_end
.endif
fbp_a_multi_long:
 sta fullcount
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_mid0_ok
 inc ptr0hi
fbp_a_mid0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_mid1_ok
 inc ptr1hi
fbp_a_mid1_ok:
 dec fullcount
 beq fbp_a_draw_end
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq fbp_a_mid_odd_check
fbp_a_mid_pair_loop:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbp_a_m0_noc
 inc ptr0hi
fbp_a_m0_noc:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbp_a_m1_noc
 inc ptr1hi
fbp_a_m1_noc:
 dec p1lo
 bne fbp_a_mid_pair_loop
fbp_a_mid_odd_check:
 lda p1hi
 beq fbp_a_draw_end
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_odd0_ok
 inc ptr0hi
fbp_a_odd0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_odd1_ok
 inc ptr1hi
fbp_a_odd1_ok:
fbp_a_draw_end:
 ldy #$00
fbp_a_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
fbp_a_next_restore:
 ldx yrow
fbp_a_next:
 cpx face_ymax
 beq fbp_a_done
 lda fillbyte
 eor pattoggle
 sta fillbyte
 inx
 jmp fbp_a_row
fbp_a_done:
 rts
.endif

.if POLY_FILL_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0 || (HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0)
fill_bounds_solid_b:
.if TRACK_DIRTY_SPANS != 0
 lda face_ymin
 cmp dirty_ymin_b
 bcs fbs_b_dirty_ymin_ok
 sta dirty_ymin_b
fbs_b_dirty_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_b
 bcc fbs_b_dirty_ymax_ok
 sta dirty_ymax_b
fbs_b_dirty_ymax_ok:
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
.endif
 ldx face_ymin
fbs_b_row:
.if LAZY_CONVEX_BOUNDS != 0
 lda bounds_stamp,x
 cmp bounds_stamp_cur
 bne fbs_b_next
.endif
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc fbs_b_next
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq fbs_b_draw
 jsr lowres_row_selected
 bne fbs_b_next
.endif
fbs_b_draw:
 stx yrow
fbs_b_fill_ready:
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_b
.else
 jsr apply_material_span_b
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_b,x
 bcs fbs_b_dirty_min_ok
 sta dirtymin_b,x
fbs_b_dirty_min_ok:
 lda endbyte
 cmp dirtymax_b,x
 bcc fbs_b_dirty_done
 sta dirtymax_b,x
fbs_b_dirty_done:
.endif
 ldy #$00
 lda startbyte
 cmp endbyte
 bne fbs_b_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbs_b_next_restore
fbs_b_multi:
.if INDEXED_OFFSET_SPAN_FILL != 0
 lda endbyte
 sec
 sbc startbyte
.if ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS != 0 && SPAN_KERNEL_FILL != 0
 cmp #$06
 bcc fbs_b_indexed_fallback
.endif
 cmp #$20
 bcs fbs_b_indexed_fallback
 sta fullcount
 ldy #$00
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda fullcount
 cmp #$01
 beq fbs_b_indexed_end_at_08
 sec
 sbc #$01
 sta p1hi
 lda fillbyte
 ldy #$08
fbs_b_indexed_mid_loop:
 sta (ptr0lo),y
 sta (ptr1lo),y
 tya
 clc
 adc #$08
 tay
 lda fillbyte
 dec p1hi
 bne fbs_b_indexed_mid_loop
 jmp fbs_b_indexed_draw_end_y
fbs_b_indexed_end_at_08:
 ldy #$08
fbs_b_indexed_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbs_b_next_restore
fbs_b_indexed_fallback:
 ldy #$00
.endif
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 cmp #$01
 bne fbs_b_maybe_three
fbs_b_two_byte:
.if SPAN_KERNEL_FILL != 0
 ldy #$08
 jmp fbs_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_two0_ok
 inc ptr0hi
fbs_b_two0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_two1_ok
 inc ptr1hi
fbs_b_two1_ok:
 jmp fbs_b_draw_end
.endif
fbs_b_maybe_three:
 cmp #$02
 bne fbs_b_maybe_four
fbs_b_three_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 jmp fbs_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_three0_mid_ok
 inc ptr0hi
fbs_b_three0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_three1_mid_ok
 inc ptr1hi
fbs_b_three1_mid_ok:
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_three0_end_ok
 inc ptr0hi
fbs_b_three0_end_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_three1_end_ok
 inc ptr1hi
fbs_b_three1_end_ok:
 jmp fbs_b_draw_end
.endif
fbs_b_maybe_four:
 cmp #$03
 bne fbs_b_maybe_five
fbs_b_four_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 jmp fbs_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_four0_mid_ok
 inc ptr0hi
fbs_b_four0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_four1_mid_ok
 inc ptr1hi
fbs_b_four1_mid_ok:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbs_b_four0_end_ok
 inc ptr0hi
fbs_b_four0_end_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbs_b_four1_end_ok
 inc ptr1hi
fbs_b_four1_end_ok:
 jmp fbs_b_draw_end
.endif
fbs_b_maybe_five:
 cmp #$04
 bne fbs_b_maybe_six
fbs_b_five_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 jmp fbs_b_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$20
 sta ptr0lo
 bcc fbs_b_five0_end_ok
 inc ptr0hi
fbs_b_five0_end_ok:
 clc
 lda ptr1lo
 adc #$20
 sta ptr1lo
 bcc fbs_b_five1_end_ok
 inc ptr1hi
fbs_b_five1_end_ok:
 jmp fbs_b_draw_end
.endif
fbs_b_maybe_six:
 cmp #$05
 bne fbs_b_multi_long
fbs_b_six_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$28
 jmp fbs_b_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$28
 sta ptr0lo
 bcc fbs_b_six0_end_ok
 inc ptr0hi
fbs_b_six0_end_ok:
 clc
 lda ptr1lo
 adc #$28
 sta ptr1lo
 bcc fbs_b_six1_end_ok
 inc ptr1hi
fbs_b_six1_end_ok:
 jmp fbs_b_draw_end
.endif
fbs_b_multi_long:
 sta fullcount
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_mid0_ok
 inc ptr0hi
fbs_b_mid0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_mid1_ok
 inc ptr1hi
fbs_b_mid1_ok:
 dec fullcount
 beq fbs_b_draw_end
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq fbs_b_mid_odd_check
fbs_b_mid_pair_loop:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbs_b_m0_noc
 inc ptr0hi
fbs_b_m0_noc:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbs_b_m1_noc
 inc ptr1hi
fbs_b_m1_noc:
 dec p1lo
 bne fbs_b_mid_pair_loop
fbs_b_mid_odd_check:
 lda p1hi
 beq fbs_b_draw_end
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_odd0_ok
 inc ptr0hi
fbs_b_odd0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_odd1_ok
 inc ptr1hi
fbs_b_odd1_ok:
fbs_b_draw_end:
 ldy #$00
fbs_b_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
fbs_b_next_restore:
 ldx yrow
fbs_b_next:
 cpx face_ymax
 beq fbs_b_done
 inx
 jmp fbs_b_row
fbs_b_done:
 rts

.endif
.if POLY_FILL_ENABLE != 0 && HIDDEN_WIRE_ENABLE = 0
fill_bounds_pattern_b:
.if TRACK_DIRTY_SPANS != 0
 lda face_ymin
 cmp dirty_ymin_b
 bcs fbp_b_dirty_ymin_ok
 sta dirty_ymin_b
fbp_b_dirty_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_b
 bcc fbp_b_dirty_ymax_ok
 sta dirty_ymax_b
fbp_b_dirty_ymax_ok:
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
.endif
 ldy shadeidx
 lda shade_pattern_bytes,y
 sta p1lo
 iny
 lda shade_pattern_bytes,y
 sta p1hi
 eor p1lo
 sta pattoggle
 lda face_ymin
 and #$01
 beq fbp_b_even_start
 lda p1hi
 jmp fbp_b_store_start
fbp_b_even_start:
 lda p1lo
fbp_b_store_start:
 sta fillbyte
 ldx face_ymin
fbp_b_row:
.if LAZY_CONVEX_BOUNDS != 0
 lda bounds_stamp,x
 cmp bounds_stamp_cur
 bne fbp_b_next
.endif
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc fbp_b_next
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq fbp_b_draw
 jsr lowres_row_selected
 bne fbp_b_next
.endif
fbp_b_draw:
 stx yrow
fbp_b_fill_ready:
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_b
.else
 jsr apply_material_span_b
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_b,x
 bcs fbp_b_dirty_min_ok
 sta dirtymin_b,x
fbp_b_dirty_min_ok:
 lda endbyte
 cmp dirtymax_b,x
 bcc fbp_b_dirty_done
 sta dirtymax_b,x
fbp_b_dirty_done:
.endif
 ldy #$00
 lda startbyte
 cmp endbyte
 bne fbp_b_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbp_b_next_restore
fbp_b_multi:
.if INDEXED_OFFSET_SPAN_FILL != 0
 lda endbyte
 sec
 sbc startbyte
.if ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS != 0 && SPAN_KERNEL_FILL != 0
 cmp #$06
 bcc fbp_b_indexed_fallback
.endif
 cmp #$20
 bcs fbp_b_indexed_fallback
 sta fullcount
 ldy #$00
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda fullcount
 cmp #$01
 beq fbp_b_indexed_end_at_08
 sec
 sbc #$01
 sta p1hi
 lda fillbyte
 ldy #$08
fbp_b_indexed_mid_loop:
 sta (ptr0lo),y
 sta (ptr1lo),y
 tya
 clc
 adc #$08
 tay
 lda fillbyte
 dec p1hi
 bne fbp_b_indexed_mid_loop
 jmp fbp_b_indexed_draw_end_y
fbp_b_indexed_end_at_08:
 ldy #$08
fbp_b_indexed_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbp_b_next_restore
fbp_b_indexed_fallback:
 ldy #$00
.endif
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 cmp #$01
 bne fbp_b_maybe_three
fbp_b_two_byte:
.if SPAN_KERNEL_FILL != 0
 ldy #$08
 jmp fbp_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_two0_ok
 inc ptr0hi
fbp_b_two0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_two1_ok
 inc ptr1hi
fbp_b_two1_ok:
 jmp fbp_b_draw_end
.endif
fbp_b_maybe_three:
 cmp #$02
 bne fbp_b_maybe_four
fbp_b_three_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 jmp fbp_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_three0_mid_ok
 inc ptr0hi
fbp_b_three0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_three1_mid_ok
 inc ptr1hi
fbp_b_three1_mid_ok:
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_three0_end_ok
 inc ptr0hi
fbp_b_three0_end_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_three1_end_ok
 inc ptr1hi
fbp_b_three1_end_ok:
 jmp fbp_b_draw_end
.endif
fbp_b_maybe_four:
 cmp #$03
 bne fbp_b_maybe_five
fbp_b_four_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 jmp fbp_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_four0_mid_ok
 inc ptr0hi
fbp_b_four0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_four1_mid_ok
 inc ptr1hi
fbp_b_four1_mid_ok:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbp_b_four0_end_ok
 inc ptr0hi
fbp_b_four0_end_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbp_b_four1_end_ok
 inc ptr1hi
fbp_b_four1_end_ok:
 jmp fbp_b_draw_end
.endif
fbp_b_maybe_five:
 cmp #$04
 bne fbp_b_maybe_six
fbp_b_five_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 jmp fbp_b_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$20
 sta ptr0lo
 bcc fbp_b_five0_end_ok
 inc ptr0hi
fbp_b_five0_end_ok:
 clc
 lda ptr1lo
 adc #$20
 sta ptr1lo
 bcc fbp_b_five1_end_ok
 inc ptr1hi
fbp_b_five1_end_ok:
 jmp fbp_b_draw_end
.endif
fbp_b_maybe_six:
 cmp #$05
 bne fbp_b_multi_long
fbp_b_six_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$28
 jmp fbp_b_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$28
 sta ptr0lo
 bcc fbp_b_six0_end_ok
 inc ptr0hi
fbp_b_six0_end_ok:
 clc
 lda ptr1lo
 adc #$28
 sta ptr1lo
 bcc fbp_b_six1_end_ok
 inc ptr1hi
fbp_b_six1_end_ok:
 jmp fbp_b_draw_end
.endif
fbp_b_multi_long:
 sta fullcount
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_mid0_ok
 inc ptr0hi
fbp_b_mid0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_mid1_ok
 inc ptr1hi
fbp_b_mid1_ok:
 dec fullcount
 beq fbp_b_draw_end
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq fbp_b_mid_odd_check
fbp_b_mid_pair_loop:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbp_b_m0_noc
 inc ptr0hi
fbp_b_m0_noc:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbp_b_m1_noc
 inc ptr1hi
fbp_b_m1_noc:
 dec p1lo
 bne fbp_b_mid_pair_loop
fbp_b_mid_odd_check:
 lda p1hi
 beq fbp_b_draw_end
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_odd0_ok
 inc ptr0hi
fbp_b_odd0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_odd1_ok
 inc ptr1hi
fbp_b_odd1_ok:
fbp_b_draw_end:
 ldy #$00
fbp_b_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
fbp_b_next_restore:
 ldx yrow
fbp_b_next:
 cpx face_ymax
 beq fbp_b_done
 lda fillbyte
 eor pattoggle
 sta fillbyte
 inx
 jmp fbp_b_row
fbp_b_done:
 rts
.endif

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0 && LOWRES_TRACE_ENABLE = 0
.if * > $5c00
 .error "High-basic-v2 middle segment overlaps video buffer A"
.endif
* = $a000
.endif
.if CAMERA_ROLL_ACTIVE != 0 && CAMERA_MOVABLE != 0
explorer_update_look_rolled:
.if CAMERA_ROLL_CONTROL != 0
 lda explorer_key_col4
 and #$90
 cmp #$90
 beq eulr_roll_released
 cmp #$00
 beq eulr_roll_released
 jsr explorer_roll_repeat_ready
 bcc eulr_prepare_axes
 lda explorer_key_col4
 and #$80
 bne eulr_roll_m
eulr_roll_n:
 clc
 lda explorer_cam_roll
 adc #EXPLORER_LOOK_STEP
 sta explorer_cam_roll
 jmp eulr_prepare_axes
eulr_roll_m:
 sec
 lda explorer_cam_roll
 sbc #EXPLORER_LOOK_STEP
 sta explorer_cam_roll
 jmp eulr_prepare_axes
eulr_roll_released:
 lda #$00
 sta explorer_roll_repeat_phase
.endif
eulr_prepare_axes:
 ldx explorer_cam_roll
 lda sintab,x
 sta t1
 txa
 clc
 adc #$40
 tax
 lda sintab,x
 sta t2
 lda #$00
 sta p1lo
 sta p1hi
 sta crosslo
 sta crosshi
 sta maskv

 lda explorer_key_col0
 and #$04
 bne eulr_yaw_released
 jsr explorer_yaw_repeat_ready
 bcc eulr_no_yaw_key
 lda explorer_key_col1
 and #$80
 beq eulr_yaw_left_key
 lda explorer_key_col6
 and #$10
 beq eulr_yaw_left_key
eulr_yaw_right_key:
 lda t2
 jsr eulr_neg_a
 jsr eulr_add_yaw_delta
 lda t1
 jsr eulr_neg_a
 jsr eulr_add_pitch_delta_from_yaw
 jmp eulr_no_yaw_key
eulr_yaw_left_key:
 lda t2
 jsr eulr_add_yaw_delta
 lda t1
 jsr eulr_add_pitch_delta_from_yaw
 jmp eulr_no_yaw_key
eulr_yaw_released:
 lda #$00
 sta explorer_yaw_repeat_phase
eulr_no_yaw_key:
 lda explorer_key_col0
 and #$80
 bne eulr_pitch_released
 jsr explorer_pitch_repeat_ready
 bcc eulr_apply_deltas
 lda explorer_key_col1
 and #$80
 beq eulr_pitch_up_key
 lda explorer_key_col6
 and #$10
 beq eulr_pitch_up_key
eulr_pitch_down_key:
 lda t1
 jsr eulr_neg_a
 jsr eulr_add_yaw_delta
 lda t2
 jsr eulr_add_pitch_delta
 jmp eulr_apply_deltas
eulr_pitch_up_key:
 lda t1
 jsr eulr_add_yaw_delta
 lda t2
 jsr eulr_neg_a
 jsr eulr_add_pitch_delta
 jmp eulr_apply_deltas
eulr_pitch_released:
 lda #$00
 sta explorer_pitch_repeat_phase
eulr_apply_deltas:
 lda p1lo
 ldx p1hi
 jsr eulr_add_yaw_acc
 lda crosslo
 ldx crosshi
 jsr eulr_add_pitch_acc
 jsr eulr_step_yaw_acc
 jmp eulr_step_pitch_acc

eulr_neg_a:
 eor #$ff
 clc
 adc #$01
 rts

eulr_add_yaw_delta:
 sta multmp
 clc
 lda p1lo
 adc multmp
 sta p1lo
 lda p1hi
 adc #$00
 sta p1hi
 lda multmp
 bpl eayd_done
 dec p1hi
eayd_done:
 rts

eulr_add_pitch_delta_from_yaw:
 sta multmp
 beq eulr_add_pitch_delta_from_yaw_restore
 lda #$01
 sta maskv
eulr_add_pitch_delta_from_yaw_restore:
 lda multmp
 jmp eulr_add_pitch_delta

eulr_add_pitch_delta:
 sta multmp
 clc
 lda crosslo
 adc multmp
 sta crosslo
 lda crosshi
 adc #$00
 sta crosshi
 lda multmp
 bpl eapd_done
 dec crosshi
eapd_done:
 rts

eulr_add_yaw_acc:
 clc
 adc explorer_look_yaw_acc_lo
 sta explorer_look_yaw_acc_lo
 txa
 adc explorer_look_yaw_acc_hi
 sta explorer_look_yaw_acc_hi
 rts

eulr_add_pitch_acc:
 clc
 adc explorer_look_pitch_acc_lo
 sta explorer_look_pitch_acc_lo
 txa
 adc explorer_look_pitch_acc_hi
 sta explorer_look_pitch_acc_hi
 rts

eulr_step_yaw_acc:
eulr_yaw_pos_check:
 lda explorer_look_yaw_acc_hi
 bmi eulr_yaw_neg_check
 bne eulr_yaw_pos_step
 lda explorer_look_yaw_acc_lo
 cmp #$40
 bcc eulr_yaw_done
eulr_yaw_pos_step:
 sec
 lda explorer_look_yaw_acc_lo
 sbc #$40
 sta explorer_look_yaw_acc_lo
 lda explorer_look_yaw_acc_hi
 sbc #$00
 sta explorer_look_yaw_acc_hi
 jsr explorer_apply_yaw_left
 jmp eulr_yaw_pos_check
eulr_yaw_neg_check:
 lda explorer_look_yaw_acc_hi
 cmp #$ff
 bne eulr_yaw_neg_step
 lda explorer_look_yaw_acc_lo
 cmp #$c1
 bcs eulr_yaw_done
eulr_yaw_neg_step:
 clc
 lda explorer_look_yaw_acc_lo
 adc #$40
 sta explorer_look_yaw_acc_lo
 lda explorer_look_yaw_acc_hi
 adc #$00
 sta explorer_look_yaw_acc_hi
 jsr explorer_apply_yaw_right
 jmp eulr_yaw_pos_check
eulr_yaw_done:
 rts

eulr_step_pitch_acc:
eulr_pitch_pos_check:
 lda explorer_look_pitch_acc_hi
 bmi eulr_pitch_neg_check
 bne eulr_pitch_pos_step
 lda explorer_look_pitch_acc_lo
 cmp #$40
 bcc eulr_pitch_done
eulr_pitch_pos_step:
 sec
 lda explorer_look_pitch_acc_lo
 sbc #$40
 sta explorer_look_pitch_acc_lo
 lda explorer_look_pitch_acc_hi
 sbc #$00
 sta explorer_look_pitch_acc_hi
 jsr explorer_apply_pitch_down
 jmp eulr_pitch_pos_check
eulr_pitch_neg_check:
 lda explorer_look_pitch_acc_hi
 cmp #$ff
 bne eulr_pitch_neg_step
 lda explorer_look_pitch_acc_lo
 cmp #$c1
 bcs eulr_pitch_done
eulr_pitch_neg_step:
 clc
 lda explorer_look_pitch_acc_lo
 adc #$40
 sta explorer_look_pitch_acc_lo
 lda explorer_look_pitch_acc_hi
 adc #$00
 sta explorer_look_pitch_acc_hi
 jsr explorer_apply_pitch_up
 jmp eulr_pitch_pos_check
eulr_pitch_done:
 rts

explorer_apply_yaw_left:
 clc
 lda explorer_cam_yaw
 adc #EXPLORER_LOOK_STEP
 sta explorer_cam_yaw
 rts
explorer_apply_yaw_right:
 sec
 lda explorer_cam_yaw
 sbc #EXPLORER_LOOK_STEP
 sta explorer_cam_yaw
 rts

explorer_apply_pitch_down:
 clc
 lda explorer_cam_pitch
 adc #EXPLORER_LOOK_STEP
 sta explorer_cam_pitch
 lda maskv
 bne explorer_apply_pitch_done
 jmp explorer_clamp_pitch
explorer_apply_pitch_up:
 sec
 lda explorer_cam_pitch
 sbc #EXPLORER_LOOK_STEP
 sta explorer_cam_pitch
 lda maskv
 bne explorer_apply_pitch_done
 jmp explorer_clamp_pitch
explorer_apply_pitch_done:
 rts

explorer_clamp_pitch:
 lda explorer_cam_pitch
 bpl ecp_pitch_positive
 cmp #EXPLORER_PITCH_NEG_MIN
 bcs ecp_done
 lda #EXPLORER_PITCH_NEG_MIN
 sta explorer_cam_pitch
 rts
ecp_pitch_positive:
 cmp #EXPLORER_PITCH_POS_LIMIT
 bcc ecp_done
 lda #EXPLORER_PITCH_POS_MAX
 sta explorer_cam_pitch
ecp_done:
 rts
.endif
mul_s6:
 sta mula
 stx mulb
 lda #$00
 sta mulsign
 lda mula
 bpl ms6_a_ok
 eor #$ff
 clc
 adc #$01
 sta mula
 lda mulsign
 eor #$80
 sta mulsign
ms6_a_ok:
 lda mulb
 bpl ms6_b_ok
 eor #$ff
 clc
 adc #$01
 sta mulb
 lda mulsign
 eor #$80
 sta mulsign
ms6_b_ok:
 lda mula
 clc
 adc mulb
 tax
 lda sqlo,x
 sta prodlo
 lda sqhi,x
 sta prodhi
 lda mula
 sec
 sbc mulb
 bcs ms6_diff_ok
 eor #$ff
 clc
 adc #$01
ms6_diff_ok:
 tax
 sec
 lda prodlo
 sbc sqlo,x
 sta prodlo
 lda prodhi
 sbc sqhi,x
 sta prodhi
 lda prodlo
 lsr
 lsr
 lsr
 lsr
 lsr
 lsr
 sta multmp
 lda prodhi
 asl
 asl
 ora multmp
 ldx mulsign
 bpl ms6_done
 eor #$ff
 clc
 adc #$01
ms6_done:
 rts

.if SCENE_OBJECT_COUNT != 0
add_s8_sat:
 sta p1lo
 txa
 sta p1hi
 clc
 lda p1lo
 adc p1hi
 sta crosslo
 lda p1lo
 eor p1hi
 bmi ass_no_overflow
 lda p1lo
 eor crosslo
 bpl ass_no_overflow
 lda p1lo
 bmi ass_neg_overflow
 lda #$7f
 rts
ass_neg_overflow:
 lda #$80
 rts
ass_no_overflow:
 lda crosslo
 rts
.endif

mul_s6_xpos_round:
 sta mula
 stx mulb
 lda #$00
 sta mulsign
 lda mula
 bpl ms6xpr_a_ok
 eor #$ff
 clc
 adc #$01
 sta mula
 lda #$80
 sta mulsign
ms6xpr_a_ok:
.if SCENE_OBJECT_COUNT != 0
 lda mulb
 bmi ms6xpr_high_scale
.endif
 lda mula
 clc
 adc mulb
 tax
 lda sqlo,x
 sta prodlo
 lda sqhi,x
 sta prodhi
 lda mula
 sec
 sbc mulb
 bcs ms6xpr_diff_ok
 eor #$ff
 clc
 adc #$01
ms6xpr_diff_ok:
 tax
 sec
 lda prodlo
 sbc sqlo,x
 sta prodlo
 lda prodhi
 sbc sqhi,x
 sta prodhi
 clc
 lda prodlo
 adc #$20
 sta prodlo
 bcc ms6xpr_round_ok
 inc prodhi
ms6xpr_round_ok:
 lda prodlo
 lsr
 lsr
 lsr
 lsr
 lsr
 lsr
 sta multmp
 lda prodhi
 asl
 asl
 ora multmp
.if SCENE_OBJECT_COUNT != 0
 cmp #$80
 bcc ms6xpr_mag_ok
 lda #$7f
ms6xpr_mag_ok:
.endif
 ldx mulsign
 bpl ms6xpr_done
 eor #$ff
 clc
 adc #$01
ms6xpr_done:
 rts

.if SCENE_OBJECT_COUNT != 0
ms6xpr_high_scale:
 lda mula
 asl
 bcs ms6xpr_high_sat
 cmp #$80
 bcs ms6xpr_high_sat
 sta multmp
 lda mulb
 cmp #$c0
 bcc ms6xpr_high_apply_sign
 clc
 lda multmp
 adc mula
 bcs ms6xpr_high_sat
 cmp #$80
 bcs ms6xpr_high_sat
 sta multmp
 lda mulb
 cmp #$e0
 bcc ms6xpr_high_apply_sign
 clc
 lda multmp
 adc mula
 bcs ms6xpr_high_sat
 cmp #$80
 bcs ms6xpr_high_sat
 sta multmp
 jmp ms6xpr_high_apply_sign
ms6xpr_high_sat:
 lda #$7f
 sta multmp
ms6xpr_high_apply_sign:
 lda multmp
 ldx mulsign
 bpl ms6xpr_high_done
 eor #$ff
 clc
 adc #$01
ms6xpr_high_done:
 rts
.endif

mul_s8_16:
 sta mula
 stx mulb
 lda #$00
 sta mulsign
 lda mula
 bpl ms8_a_ok
 eor #$ff
 clc
 adc #$01
 sta mula
 lda mulsign
 eor #$80
 sta mulsign
ms8_a_ok:
 lda mulb
 bpl ms8_b_ok
 eor #$ff
 clc
 adc #$01
 sta mulb
 lda mulsign
 eor #$80
 sta mulsign
ms8_b_ok:
 lda mula
 clc
 adc mulb
 tax
 lda sqlo,x
 sta prodlo
 lda sqhi,x
 sta prodhi
 lda mula
 sec
 sbc mulb
 bcs ms8_diff_ok
 eor #$ff
 clc
 adc #$01
ms8_diff_ok:
 tax
 sec
 lda prodlo
 sbc sqlo,x
 sta prodlo
 lda prodhi
 sbc sqhi,x
 sta prodhi
 lda mulsign
 bpl ms8_done
 sec
 lda #$00
 sbc prodlo
 sta prodlo
 lda #$00
 sbc prodhi
 sta prodhi
ms8_done:
 rts



trace_edge_convex_xq2:
 lda ey0
 cmp ey1
 bcc ssxq2_ordered
 bne ssxq2_descending
 jmp ssxq2_horizontal
ssxq2_descending:
 lda q2_x0lo
 pha
 lda q2_x0hi
 pha
 lda q2_x1lo
 pha
 lda q2_x1hi
 pha
 lda ey0
 pha
 lda ey1
 sta ey0
 pla
 sta ey1
 pla
 sta q2_x0hi
 pla
 sta q2_x0lo
 pla
 sta q2_x1hi
 pla
 sta q2_x1lo
ssxq2_ordered:
 sec
 lda ey1
 sbc ey0
 sta dyval
 lda q2_x1hi
 cmp q2_x0hi
 bcc ssxq2_negative
 bne ssxq2_positive
 lda q2_x1lo
 cmp q2_x0lo
 bcc ssxq2_negative
ssxq2_positive:
 lda #$01
 sta sxstep
 sec
 lda q2_x1lo
 sbc q2_x0lo
 sta q2_step_lo
 lda q2_x1hi
 sbc q2_x0hi
 sta q2_step_hi
 jmp ssxq2_prepare
ssxq2_negative:
 lda #$ff
 sta sxstep
 sec
 lda q2_x0lo
 sbc q2_x1lo
 sta q2_step_lo
 lda q2_x0hi
 sbc q2_x1hi
 sta q2_step_hi
ssxq2_prepare:
 ; Integer Q2 endpoints retain the already validated RC4-equivalent trace.
 ; Fractional endpoints keep the same normalized state while their Q2 DDA
 ; position is advanced exactly between scanlines.
 lda q2_x0lo
 ora q2_x1lo
 and #$03
 bne ssxq2_fractional_prepare
ssxq2_direct_prepare:
 ; LegacyDirect endpoints are exact 4*sx. Convert the unsigned Q2 delta
 ; to pixel delta, then retain RC4's connected horizontal bridge updates.
 lsr q2_step_hi
 ror q2_step_lo
 lsr q2_step_hi
 ror q2_step_lo
 lda #$00
 sta q2_remainder
 sta q2_rem_step
ssxq2_direct_loop:
 jsr solid_subpixel_xq2_plot_current
 lda ey0
 cmp ey1
 beq ssxq2_direct_done
 clc
 lda q2_remainder
 adc q2_step_lo
 sta q2_remainder
ssxq2_direct_step_check:
 lda q2_remainder
 cmp dyval
 bcc ssxq2_direct_next_row
 sec
 sbc dyval
 sta q2_remainder
 jsr solid_subpixel_xq2_advance_pixel
 jsr solid_subpixel_xq2_plot_current
 jmp ssxq2_direct_step_check
ssxq2_direct_next_row:
 inc ey0
 jmp ssxq2_direct_loop
ssxq2_direct_done:
 rts

ssxq2_fractional_prepare:
 lda dyval
 sta p1lo
 lda #$00
 sta p1hi
 jsr solid_subpixel_xq2_div16u
 lda crosslo
 sta q2_rem_step
 lda #$00
 sta q2_remainder
ssxq2_fractional_loop:
 jsr solid_subpixel_xq2_plot_current
 lda ey0
 cmp ey1
 beq ssxq2_fractional_done
 jsr solid_subpixel_xq2_pixel_current
 sta p1lo
 jsr solid_subpixel_xq2_advance_q2_step
 clc
 lda q2_remainder
 adc q2_rem_step
 sta q2_remainder
 cmp dyval
 bcc ssxq2_fractional_target
 sec
 sbc dyval
 sta q2_remainder
 jsr solid_subpixel_xq2_advance_q2_unit
ssxq2_fractional_target:
 jsr solid_subpixel_xq2_pixel_current
 sta p1hi
ssxq2_fractional_bridge:
 lda p1lo
 cmp p1hi
 beq ssxq2_fractional_next_row
 lda sxstep
 bmi ssxq2_fractional_bridge_negative
 inc p1lo
 ldx ey0
 lda p1lo
 jsr update_convex_bounds
 jmp ssxq2_fractional_bridge
ssxq2_fractional_bridge_negative:
 dec p1lo
 ldx ey0
 lda p1lo
 jsr update_convex_bounds
 jmp ssxq2_fractional_bridge
ssxq2_fractional_next_row:
 inc ey0
 jmp ssxq2_fractional_loop
ssxq2_fractional_done:
 rts

ssxq2_horizontal:
 jsr solid_subpixel_xq2_plot_current
 lda q2_x1lo
 sta q2_x0lo
 lda q2_x1hi
 sta q2_x0hi
 jsr solid_subpixel_xq2_plot_current
 rts

solid_subpixel_xq2_advance_pixel:
 lda q2_x0hi
 cmp q2_x1hi
 bne ssxq2_advance_direction
 lda q2_x0lo
 cmp q2_x1lo
 beq ssxq2_advance_done
ssxq2_advance_direction:
 lda sxstep
 bmi ssxq2_advance_negative
 clc
 lda q2_x0lo
 adc #$04
 sta q2_x0lo
 lda q2_x0hi
 adc #$00
 sta q2_x0hi
 rts
ssxq2_advance_negative:
 sec
 lda q2_x0lo
 sbc #$04
 sta q2_x0lo
 lda q2_x0hi
 sbc #$00
 sta q2_x0hi
ssxq2_advance_done:
 rts

solid_subpixel_xq2_advance_q2_step:
 lda sxstep
 bmi ssxq2_advance_q2_step_negative
 clc
 lda q2_x0lo
 adc q2_step_lo
 sta q2_x0lo
 lda q2_x0hi
 adc q2_step_hi
 sta q2_x0hi
 rts
ssxq2_advance_q2_step_negative:
 sec
 lda q2_x0lo
 sbc q2_step_lo
 sta q2_x0lo
 lda q2_x0hi
 sbc q2_step_hi
 sta q2_x0hi
 rts

solid_subpixel_xq2_advance_q2_unit:
 lda sxstep
 bmi ssxq2_advance_q2_unit_negative
 inc q2_x0lo
 bne ssxq2_advance_q2_unit_done
 inc q2_x0hi
ssxq2_advance_q2_unit_done:
 rts
ssxq2_advance_q2_unit_negative:
 lda q2_x0lo
 bne ssxq2_advance_q2_unit_low
 dec q2_x0hi
ssxq2_advance_q2_unit_low:
 dec q2_x0lo
 rts

solid_subpixel_xq2_pixel_current:
 clc
 lda q2_x0lo
 adc #$02
 sta t1
 lda q2_x0hi
 adc #$00
 sta t2
 lsr t2
 ror t1
 lsr t2
 ror t1
 lda t1
 rts

solid_subpixel_xq2_plot_current:
 jsr solid_subpixel_xq2_pixel_current
 ldx ey0
 jsr update_convex_bounds
 rts

solid_subpixel_xq2_div16u:
 lda #$00
 sta crosslo
 sta crosshi
 ldx #$10
ssxq2_div_loop:
 asl prodlo
 rol prodhi
 rol crosslo
 rol crosshi
 lda crosslo
 sec
 sbc p1lo
 tay
 lda crosshi
 sbc p1hi
 bcc ssxq2_div_skip_sub
 sta crosshi
 sty crosslo
 inc prodlo
ssxq2_div_skip_sub:
 dex
 bne ssxq2_div_loop
 rts
; Native Y-Q2 solid bounds.  This block is emitted only for the one supported
; mode-4/fixed/small/stable X=LegacyDirect, Y=Native configuration.
;
; xExact is always represented as B + R/D, with 0 <= R < D.  B, R, D,
; S and RS are deliberately distinct RAM slots: the two signed Euclidean
; divisions cannot overwrite the residual used by the next scanline.
xyq2_face_valid: .byte 0
xyq2_x0lo: .byte 0
xyq2_x0hi: .byte 0
xyq2_y0lo: .byte 0
xyq2_y0hi: .byte 0
xyq2_x1lo: .byte 0
xyq2_x1hi: .byte 0
xyq2_y1lo: .byte 0
xyq2_y1hi: .byte 0
xyq2_minlo: .byte 0
xyq2_minhi: .byte 0
xyq2_maxlo: .byte 0
xyq2_maxhi: .byte 0
xyq2_dxlo: .byte 0
xyq2_dxhi: .byte 0
xyq2_blo: .byte 0
xyq2_bhi: .byte 0
xyq2_rlo: .byte 0
xyq2_rhi: .byte 0
xyq2_dlo: .byte 0
xyq2_dhi: .byte 0
xyq2_slo: .byte 0
xyq2_shi: .byte 0
xyq2_rslo: .byte 0
xyq2_rshi: .byte 0
xyq2_nlo: .byte 0
xyq2_nhi: .byte 0
xyq2_qlo: .byte 0
xyq2_qhi: .byte 0
xyq2_divlo: .byte 0
xyq2_divhi: .byte 0
xyq2_r0lo: .byte 0
xyq2_r0hi: .byte 0
xyq2_delta: .byte 0
xyq2_row: .byte 0
xyq2_lastrow: .byte 0
xyq2_phase: .byte 0
xyq2_base: .byte 0
xyq2_negative: .byte 0
xyq2_faulted: .byte 0
xyq2_builder_sp: .byte 0
.if xyq2_face_valid < $0100 || xyq2_negative != xyq2_face_valid + $26
 .error "XYQ2 state must be contiguous RAM, never zero page"
.endif
.if xyq2_faulted != xyq2_negative + 1 || xyq2_builder_sp != xyq2_faulted + 1
 .error "XYQ2 fault-unwind state must remain private contiguous RAM"
.endif
.if xyq2_r0lo = xyq2_rslo || xyq2_r0hi = xyq2_rshi || xyq2_r0lo = xyq2_r0hi || xyq2_rslo = xyq2_rshi
 .error "XYQ2 R0 and RS must use separate state"
.endif
.if xyq2_dxhi != xyq2_dxlo + 1 || xyq2_bhi != xyq2_blo + 1 || xyq2_rhi != xyq2_rlo + 1 || xyq2_dhi != xyq2_dlo + 1 || xyq2_shi != xyq2_slo + 1 || xyq2_rshi != xyq2_rslo + 1 || xyq2_nhi != xyq2_nlo + 1 || xyq2_qhi != xyq2_qlo + 1 || xyq2_divhi != xyq2_divlo + 1 || xyq2_r0hi != xyq2_r0lo + 1
 .error "XYQ2 fractional walker requires distinct contiguous 16-bit words"
.endif
.if xyq2_blo = fillbyte || xyq2_blo = shadeidx || xyq2_blo = face_ymin || xyq2_blo = face_ymax || xyq2_rlo = fillbyte || xyq2_dlo = fillbyte || xyq2_slo = fillbyte || xyq2_rslo = fillbyte || xyq2_nlo = fillbyte || xyq2_qlo = fillbyte || xyq2_divlo = fillbyte
 .error "XYQ2 fractional scratch aliases Mode 4 fill or shade state"
.endif
.if xyq2_face_valid < $0100 || xyq2_builder_sp < $0100
 .error "XYQ2 bounds scratch must remain outside every Mode 4 zero-page state cell"
.endif
.if q2_x0lo = drawbuf || q2_x0hi = drawbuf || q2_x1lo = drawbuf || q2_x1hi = drawbuf || q2_x0lo = shadeidx || q2_x0hi = shadeidx || q2_x1lo = shadeidx || q2_x1hi = shadeidx || q2_x0lo = fillbyte || q2_x0hi = fillbyte || q2_x1lo = fillbyte || q2_x1hi = fillbyte || q2_x0lo = pattoggle || q2_x0hi = pattoggle || q2_x1lo = pattoggle || q2_x1hi = pattoggle || q2_x0lo = spanw || q2_x0hi = spanw || q2_x1lo = spanw || q2_x1hi = spanw || q2_x0lo = spanh || q2_x0hi = spanh || q2_x1lo = spanh || q2_x1hi = spanh || q2_x0lo = ptr0lo || q2_x0hi = ptr0lo || q2_x1lo = ptr0lo || q2_x1hi = ptr0lo || q2_x0lo = ptr0hi || q2_x0hi = ptr0hi || q2_x1lo = ptr0hi || q2_x1hi = ptr0hi || q2_x0lo = ptr1lo || q2_x0hi = ptr1lo || q2_x1lo = ptr1lo || q2_x1hi = ptr1lo || q2_x0lo = ptr1hi || q2_x0hi = ptr1hi || q2_x1lo = ptr1hi || q2_x1hi = ptr1hi
 .error "XYQ2 DEV2 zero-page temporaries alias Mode 4 dispatch state"
.endif
.if mode4_current_face_id >= $0100 || mode4_current_face_id = drawbuf || mode4_current_face_id = faceidx || mode4_current_face_id = sortj || mode4_current_face_id = shadeidx || mode4_current_face_id = fillbyte || mode4_current_face_id = face_ymin || mode4_current_face_id = face_ymax || mode4_current_face_id = spanw || mode4_current_face_id = spanh || mode4_current_face_id = q2_x0lo || mode4_current_face_id = q2_x0hi || mode4_current_face_id = q2_x1lo || mode4_current_face_id = q2_x1hi
 .error "Mode4 current-face latch must be a dedicated zero-page cell"
.endif
.if vyq2_0lo = q2_x0lo || vyq2_0lo = q2_x0hi || vyq2_0lo = q2_x1lo || vyq2_0lo = q2_x1hi || vyq2_0lo = q2_step_lo || vyq2_0lo = q2_step_hi || vyq2_0lo = q2_remainder || vyq2_0lo = q2_rem_step || vyq2_1lo = q2_x0lo || vyq2_1lo = q2_x0hi || vyq2_1lo = q2_x1lo || vyq2_1lo = q2_x1hi || vyq2_1lo = q2_step_lo || vyq2_1lo = q2_step_hi || vyq2_1lo = q2_remainder || vyq2_1lo = q2_rem_step || vyq2_2lo = q2_x0lo || vyq2_2lo = q2_x0hi || vyq2_2lo = q2_x1lo || vyq2_2lo = q2_x1hi || vyq2_2lo = q2_step_lo || vyq2_2lo = q2_step_hi || vyq2_2lo = q2_remainder || vyq2_2lo = q2_rem_step || vyq2_3lo = q2_x0lo || vyq2_3lo = q2_x0hi || vyq2_3lo = q2_x1lo || vyq2_3lo = q2_x1hi || vyq2_3lo = q2_step_lo || vyq2_3lo = q2_step_hi || vyq2_3lo = q2_remainder || vyq2_3lo = q2_rem_step
 .error "XYQ2 Y endpoints overlap DEV2 zero-page walker state"
.endif
.if vyq2_0lo >= $0100 || vyq2_0hi >= $0100 || vyq2_1lo >= $0100 || vyq2_1hi >= $0100 || vyq2_2lo >= $0100 || vyq2_2hi >= $0100 || vyq2_3lo >= $0100 || vyq2_3hi >= $0100
 .error "XYQ2 Y endpoints must remain private zero-page temporaries"
.endif

; Q8-only: old integer polygon clip retired.
build_loaded_face_bounds_xyq2 = hp_unreachable
xyq2_builder_done = hp_unreachable
setup_face_y_bounds_xyq2 = hp_unreachable
.if HAS_TRI_FACES != 0
.endif
xyq2_minmax_done = hp_unreachable
xyq2_first_clamp = hp_unreachable
xyq2_first_ready = hp_unreachable
xyq2_last_clamp = hp_unreachable
xyq2_last_ready = hp_unreachable
xyq2_init_bounds = hp_unreachable
xyq2_init_loop = hp_unreachable
xyq2_bounds_ready = hp_unreachable
xyq2_trace_edges = hp_unreachable
.if HAS_TRI_FACES != 0
.endif
.if HAS_TRI_FACES != 0
xyq2_trace_2_to_0 = hp_unreachable
.endif
xyq2_validate_bounds = hp_unreachable
xyq2_validate_loop = hp_unreachable
xyq2_face_yes = hp_unreachable
xyq2_face_no = hp_unreachable
xyq2_include_y = hp_unreachable
xyq2_test_max = hp_unreachable
xyq2_store_max = hp_unreachable
xyq2_store_min = hp_unreachable
xyq2_include_done = hp_unreachable
trace_edge_convex_xyq2 = hp_unreachable
xyq2_swap_endpoints = hp_unreachable
xyq2_ordered = hp_unreachable
xyq2_edge_first_clamp = hp_unreachable
xyq2_edge_first_ok = hp_unreachable
xyq2_edge_last_clamp = hp_unreachable
xyq2_edge_last_ok = hp_unreachable
xyq2_edge_prepare = hp_unreachable
xyq2_n0_loop = hp_unreachable
xyq2_n0_divide = hp_unreachable
.if YQ2_FAST_DIV11X8 != 0
xyq2_n0_divide_slow = hp_unreachable
.endif
xyq2_n0_divide_done = hp_unreachable
.if YQ2_FAST_DIV11X8 != 0
xyq2_ns_divide_slow = hp_unreachable
.endif
xyq2_ns_divide_done = hp_unreachable
xyq2_edge_row_loop = hp_unreachable
.if YQ2_INLINE_BOUNDS != 0
xyq2_inline_left_ok = hp_unreachable
xyq2_inline_bounds_done = hp_unreachable
.else
.endif
xyq2_reduce_remainder = hp_unreachable
xyq2_next_row = hp_unreachable
xyq2_edge_done = hp_unreachable
xyq2_horizontal = hp_unreachable
xyq2_integral = hp_unreachable
xyq2_pixel_from_exact = hp_unreachable
.if YQ2_FAST_PIXEL_CONVERT != 0
.endif
xyq2_phase_loop = hp_unreachable
xyq2_phase_done = hp_unreachable
.if YQ2_FAST_PIXEL_CONVERT != 0
xyq2_pixel_fast = hp_unreachable
.endif
.if YQ2_FAST_DIV11X8 != 0
xyq2_div_signed_euclid_11x8 = hp_unreachable
xyq2_div11_abs_ready = hp_unreachable
.if MODE7_UV_CARRIER != 0
xyq2_div11_seed = hp_unreachable
xyq2_div11_low_start = hp_unreachable
xyq2_div11_low_loop = hp_unreachable
xyq2_div11_low_sub = hp_unreachable
xyq2_div11_low_skip = hp_unreachable
.else
xyq2_div11_align = hp_unreachable
xyq2_div11_loop = hp_unreachable
xyq2_div11_sub = hp_unreachable
xyq2_div11_skip = hp_unreachable
.endif
xyq2_div11_neg_dec = hp_unreachable
xyq2_div11_neg_exact = hp_unreachable
xyq2_div11_done = hp_unreachable
.endif
xyq2_div_signed_euclid = hp_unreachable
xyq2_div_unsigned = hp_unreachable
xyq2_div_signed_positive = hp_unreachable
xyq2_div_unsigned_core = hp_unreachable
xyq2_div_loop = hp_unreachable
xyq2_div_subtract = hp_unreachable
xyq2_div_skip = hp_unreachable
xyq2_div_neg_decrement = hp_unreachable
xyq2_div_neg_exact = hp_unreachable
xyq2_div_done = hp_unreachable
xyq2_assert_x_endpoints = hp_unreachable
.if PROJ_SCREEN_MAX_X > $7f
.endif
xyq2_x0_low = hp_unreachable
.if PROJ_SCREEN_MAX_X > $7f
.endif
xyq2_x1_low = hp_unreachable
xyq2_walker_fault = hp_unreachable
xyq2_final_fault_halt = hp_unreachable
; Mesh data is generated below by the build script.
.if ENGINE_MODE3_ADAPTIVE_SCREEN_PAIR_LAYOUT != 0
; Adaptive engine-mode3 slots: 00=background, 01=dark pigment, 10=high/folded highlight, 11=fixed ground.
.else
; Universal material slots. 00=background only, 01=dark pigment, 10=solid high pigment, 11=reflective highlight.
.endif
; Face shade fill bytes never emit slot 00: darkest shade is clamped to dark pigment.
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0
high_basic_v2_static_return = *
.if high_basic_v2_static_return < HIGH_BASIC_V2_CODE_HIGH_BASE || high_basic_v2_static_return >= HIGH_BASIC_V2_IO_BASE
 .error "High-basic-v2 high code overlaps $a000/$d000 boundary"
.endif
* = $1ec4
.endif
.if POLY_FILL_ENABLE != 0
shade_solid_bytes:
 .byte $55,$55,$aa,$aa,$ff,$ff,$ff,$ff
shade_pattern_bytes:
 .byte $55,$55,$66,$99,$bb,$ee,$77,$dd
shade_pattern_bytes_end:
.endif
.if RANDOM_MATERIAL_CYCLE != 0
random_material_index_table:
 .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$00,$01,$02,$03,$04,$05
random_wire_color_table:
 .byte $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$01
.endif

fps_vblank_count: .byte 0
fps_second_flag: .byte 0
.if FPS_COUNTER_ENABLE != 0 || RANDOM_MATERIAL_CYCLE != 0
fps_cur_frames: .byte 0
.endif
.if FPS_COUNTER_ENABLE != 0
fps_sum: .byte 0
fps_sample_index: .byte 0
fps_initialized: .byte 0
fps_last_value: .byte 0
fps_last_tenths: .byte 0
fps_samples: .fill 5,0
.endif
.if SCENE_RESPAWN_ACTIVE != 0 || RANDOM_MATERIAL_CYCLE != 0
scene_rng_state: .byte $5a
.endif
irq_phase: .byte 0
sim_vblank_count: .byte 0
video_standard_runtime: .byte VIDEO_STANDARD_INITIAL
video_vblanks_per_second: .byte VIDEO_VBLANKS_PER_SECOND_INITIAL
ntsc_sim_phase: .byte 0
light_pause: .byte 0
light_latch: .byte 0
light_pulse_enabled: .byte 0
rotation_pause: .byte 0
rotation_latch: .byte 0
.if CONTROL_LOWRES_KEY != 0
lowres_scanline_enabled: .byte 0
lowres_latch: .byte 0
lowres_scanline_parity: .byte 0
lowres_parity_a: .byte 0
lowres_parity_b: .byte 0
.endif
motion_z_enabled: .byte 0
return_latch: .byte 0
angx_lo: .byte 0
angx_hi: .byte 0
angy_lo: .byte 0
angy_hi: .byte 0
angz_lo: .byte 0
angz_hi: .byte 0
shade_dirty: .byte 1
material_screen_cur: .byte MATERIAL_SCREEN_BYTE
material_color_cur: .byte MATERIAL_COLOR_RAM
material_reflect_offset_cur: .byte MATERIAL_REFLECTIVITY_OFFSET
.if MODE7_UV_CARRIER != 0
gouraud_vshade0: .byte 0
gouraud_vshade1: .byte 0
gouraud_vshade2: .byte 0
gouraud_vshade3: .byte 0
gouraud_edge_x0: .byte 0
gouraud_edge_y0: .byte 0
gouraud_edge_x1: .byte 0
gouraud_edge_y1: .byte 0
gouraud_edge_s0: .byte 0
gouraud_edge_s1: .byte 0
gouraud_edge_dy: .byte 0
gouraud_edge_xdir: .byte 0
gouraud_edge_sdir: .byte 0
gouraud_edge_xerr_lo: .byte 0
gouraud_edge_xerr_hi: .byte 0
gouraud_edge_serr: .byte 0
gouraud_edge_row: .byte 0
gouraud_edge_xcur: .byte 0
gouraud_edge_scur: .byte 0
gouraud_scan_x: .byte 0
gouraud_scan_end: .byte 0
gouraud_clip_shade_in: .byte 0
gouraud_clip_shade_out: .byte 0
gouraud_pair_clear: .byte $3f,$cf,$f3,$fc
.endif
.if ENGINE_WIRE_CELL_WRITE_SKIP_SAME != 0
engine_wire_last_cell_x: .byte $ff
engine_wire_last_cell_y: .byte $ff
engine_wire_last_cell_buf: .byte $ff
.if ENGINE_WIRE_CELL_TRANSITION_UPDATES != 0
engine_wire_last_dirty_x: .byte $ff
engine_wire_last_dirty_y: .byte $ff
engine_wire_last_dirty_buf: .byte $ff
.endif
.if ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = 0
engine_wire_last_screen: .byte $ff
engine_wire_last_color: .byte $ff
.endif
.endif
.if VIC_COLOR_POLICY_ENABLE != 0
vic_color_cells_touched_lo: .byte 0
vic_color_cells_touched_hi: .byte 0
vic_color_conflict_count_lo: .byte 0
vic_color_conflict_count_hi: .byte 0
vic_color_fallback_count_lo: .byte 0
vic_color_fallback_count_hi: .byte 0
vic_color_fill_fallback_lo: .byte 0
vic_color_fill_fallback_hi: .byte 0
vic_color_wire_fallback_lo: .byte 0
vic_color_wire_fallback_hi: .byte 0
vic_color_max_colors_per_cell: .byte 0
vic_color_source: .byte 1
vic_color_saved_x: .byte 0
vic_color_owner_luma: .byte 0
; Lowres compatibility ranking, from darker to lighter perceived output.
vic_color_lowres_luma:
 .byte $00,$0f,$05,$0b,$04,$07,$03,$0d,$08,$02,$0c,$01,$06,$09,$0a,$0e
.endif
.if LAZY_CONVEX_BOUNDS != 0
bounds_stamp_cur: .byte 0
.endif
.if MATERIAL_CELL_SPAN_CACHE != 0
material_last_cellrow: .byte $ff
material_cell_min: .byte 0
material_cell_max: .byte 0
material_span_orig_start: .byte 0
material_span_orig_end: .byte 0
.endif
.if RANDOM_MATERIAL_CYCLE != 0
random_material_tick: .byte 0
.endif
.if WIRE_FACE_EDGE_ENABLE != 0
wire_edge_stamp: .byte 0
.if HIDDEN_WIRE_ENABLE = 0 && POLY_FILL_ENABLE = 0 && CAMERA_MOVABLE != 0
wire_mesh_safe_flag: .byte 0
.endif
.endif
.if WIRE_RENDER_ENABLE != 0 && (POLY_FILL_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0 || (HIDDEN_WIRE_ENABLE != 0 && (WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)))
wire_trace_active: .byte 0
.endif
.if MODE5_POLYGON_OUTLINE != 0
mode5_outline_trace_active: .byte 0
.endif
.if WORLD_GROUND_HORIZON_BBOX_OCCLUDE != 0
world_ground_saved_screen: .byte 0
world_ground_saved_color: .byte 0
.endif
.if WORLD_GROUND_WIRE_OCCLUDE != 0 || WORLD_GROUND_HORIZON_ONLY != 0
world_ground_horizon_valid: .byte 0
world_ground_horizon_mask_active: .byte 0
world_ground_saved_material_screen: .byte 0
world_ground_saved_material_color: .byte 0
world_ground_hx0: .byte 0
world_ground_hy0: .byte 0
world_ground_hx1: .byte 0
world_ground_hy1: .byte 0
.endif
.if WIRE_DEPTH_SORT_ENABLE != 0
wire_depth_entry_used: .byte 0
wire_entry_cursor: .byte 0
.endif
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WIRE_MESH_COUNT != 0
hidden_solid_near_bucket: .byte $ff
.endif
.if HIDDEN_WIRE_ENABLE != 0 && MODE2_FACE_BUCKET_PIPELINE = 0
hidden_save_vx0: .byte 0
hidden_save_vy0: .byte 0
hidden_save_vx1: .byte 0
hidden_save_vy1: .byte 0
hidden_save_vx2: .byte 0
hidden_save_vy2: .byte 0
.if CAMERA_MOVABLE != 0
hidden_cam_x8: .byte 0
hidden_cam_y8: .byte 0
hidden_cam_z8: .byte 0
.if SCENE_OBJECT_COUNT != 0
hidden_obj_z8: .byte 0
.endif
.endif
.endif
.if FPS_OVERLAY_ENABLE != 0
fps_latch: .byte 0
text_split_visible: .byte FPS_OVERLAY_ON_START
fps_overlay_visible = text_split_visible ; historical compatibility alias
fps_digit_tens: .byte 1
fps_digit_ones: .byte 1
fps_digit_frac: .byte 1
text_header_string: .byte $FF
.endif

.if CAMERA_MOVABLE != 0 || WORLD_GROUND_ENABLE != 0
explorer_cam_x_lo: .byte EXPLORER_CAMERA_X_LO
explorer_cam_x_hi: .byte EXPLORER_CAMERA_X_HI
explorer_cam_x_ext: .byte EXPLORER_CAMERA_X_EXT
explorer_cam_y_lo: .byte EXPLORER_CAMERA_Y_LO
explorer_cam_y_hi: .byte EXPLORER_CAMERA_Y_HI
explorer_cam_y_ext: .byte EXPLORER_CAMERA_Y_EXT
explorer_cam_z_lo: .byte EXPLORER_CAMERA_Z_LO
explorer_cam_z_hi: .byte EXPLORER_CAMERA_Z_HI
explorer_cam_z_ext: .byte EXPLORER_CAMERA_Z_EXT
explorer_cam_yaw: .byte EXPLORER_CAMERA_YAW
explorer_cam_pitch: .byte EXPLORER_CAMERA_PITCH
.if CAMERA_RUNTIME_CONTROLS != 0 || SCENE_TIMELINE_ENABLE != 0
explorer_yaw_repeat_phase: .byte 0
explorer_pitch_repeat_phase: .byte 0
.else
; The reset helper is assembled for movable cameras even when input is absent.
; Reuse the inactive key latch so no legacy data byte is added.
explorer_yaw_repeat_phase = space_latch
explorer_pitch_repeat_phase = space_latch
.endif
.if CAMERA_RUNTIME_CONTROLS != 0
.if CAMERA_ROLL_CONTROL != 0
explorer_roll_repeat_phase: .byte 0
.endif
.endif
.if CAMERA_ROLL_ACTIVE != 0
explorer_cam_roll: .byte EXPLORER_CAMERA_ROLL
explorer_look_yaw_acc_lo: .byte 0
explorer_look_yaw_acc_hi: .byte 0
explorer_look_pitch_acc_lo: .byte 0
explorer_look_pitch_acc_hi: .byte 0
.endif
explorer_key_col0: .byte $ff
explorer_key_col1: .byte $ff
explorer_key_col2: .byte $ff
.if CAMERA_ROLL_CONTROL != 0
explorer_key_col4: .byte $ff
.endif
explorer_key_col6: .byte $ff
explorer_key_col7: .byte $ff
.if EXPLORER_RESET_ON_SPACE != 0
explorer_camera_tick_skip: .byte 0
.endif
.if CAMERA_MODE_CYCLE != 0
explorer_runtime_mode: .byte EXPLORER_RUNTIME_MODE_INITIAL
explorer_mode_latch: .byte 0
.endif
explorer_delta_lo: .byte 0
explorer_delta_hi: .byte 0
explorer_delta_ext: .byte 0
explorer_view_x_lo: .byte 0
explorer_view_x_hi: .byte 0
explorer_view_y_lo: .byte 0
explorer_view_y_hi: .byte 0
explorer_view_z_lo: .byte 0
explorer_view_z_hi: .byte 0
explorer_rel_x_lo: .byte 0
explorer_rel_x_hi: .byte 0
explorer_rel_y_lo: .byte 0
explorer_rel_y_hi: .byte 0
.if POLY_FILL_ENABLE = 0
explorer_cached_siny: .byte 0
explorer_cached_cosy: .byte 0
explorer_cached_sinx: .byte 0
explorer_cached_cosx: .byte 0
.if CAMERA_ROLL_ACTIVE != 0
explorer_cached_sinz: .byte 0
explorer_cached_cosz: .byte 0
.endif
.endif
.endif

.if CAMERA_PLANE_CLIP_PROFILE != 0
camera_plane_bucket_ready: .byte 0
camera_plane_bucket_depth: .byte 0
; Two-byte scratch for clip projection. The source vertex cache is restored
; before returning to the ordinary face pipeline.
camera_plane_saved_sx: .byte 0
camera_plane_saved_sy: .byte 0
.endif
RUNTIME_BUFFER_BASE = $8000
sx = RUNTIME_BUFFER_BASE
sy = sx + VERT_COUNT
syq2_lo = sy + VERT_COUNT
syq2_hi = syq2_lo + VERT_COUNT
RUNTIME_AFTER_SXQ2 = syq2_hi + VERT_COUNT
.if syq2_lo < $0100 || syq2_hi != syq2_lo + VERT_COUNT || RUNTIME_AFTER_SXQ2 != syq2_hi + VERT_COUNT
 .error "Y-Q2 runtime buffers must be complete non-zero-page VERT_COUNT ranges"
.endif
.if EXPLORER_SCREEN_RAW != 0
pxrawlo = RUNTIME_AFTER_SXQ2
pxrawhi = pxrawlo + VERT_COUNT
pyrawlo = pxrawhi + VERT_COUNT
pyrawhi = pyrawlo + VERT_COUNT
RUNTIME_AFTER_RAW = pyrawhi + VERT_COUNT
.else
RUNTIME_AFTER_RAW = RUNTIME_AFTER_SXQ2
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
vxrawlo = RUNTIME_AFTER_RAW
vxrawhi = vxrawlo + VERT_COUNT
vyrawlo = vxrawhi + VERT_COUNT
vyrawhi = vyrawlo + VERT_COUNT
vzrawlo = vyrawhi + VERT_COUNT
vzrawhi = vzrawlo + VERT_COUNT
RUNTIME_AFTER_NEAR = vzrawhi + VERT_COUNT
.else
RUNTIME_AFTER_NEAR = RUNTIME_AFTER_RAW
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
clip_a_xlo = RUNTIME_AFTER_NEAR
clip_a_xhi = clip_a_xlo + 12
clip_a_ylo = clip_a_xhi + 12
clip_a_yhi = clip_a_ylo + 12
clip_a_x = clip_a_yhi + 12
clip_a_y = clip_a_x + 12
.if MODE7_UV_CARRIER != 0
clip_a_shade = clip_a_y + 12
.endif
.if WIRE_RENDER_ENABLE != 0
.if MODE7_UV_CARRIER != 0
clip_a_flag = clip_a_shade + 12
.else
clip_a_flag = clip_a_y + 12
.endif
clip_b_xlo = clip_a_flag + 12
.else
.if MODE7_UV_CARRIER != 0
clip_b_xlo = clip_a_shade + 12
.else
clip_b_xlo = clip_a_y + 12
.endif
.endif
clip_b_xhi = clip_b_xlo + 12
clip_b_ylo = clip_b_xhi + 12
clip_b_yhi = clip_b_ylo + 12
clip_b_x = clip_b_yhi + 12
clip_b_y = clip_b_x + 12
.if MODE7_UV_CARRIER != 0
clip_b_shade = clip_b_y + 12
.endif
.if WIRE_RENDER_ENABLE != 0
.if MODE7_UV_CARRIER != 0
clip_b_flag = clip_b_shade + 12
.else
clip_b_flag = clip_b_y + 12
.endif
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
.if WIRE_RENDER_ENABLE != 0
clip_a_vxlo = clip_b_flag + 12
.else
.if MODE7_UV_CARRIER != 0
clip_a_vxlo = clip_b_shade + 12
.else
clip_a_vxlo = clip_b_y + 12
.endif
.endif
clip_a_vxhi = clip_a_vxlo + 12
clip_a_vylo = clip_a_vxhi + 12
clip_a_vyhi = clip_a_vylo + 12
clip_a_vzlo = clip_a_vyhi + 12
clip_a_vzhi = clip_a_vzlo + 12
clip_b_vxlo = clip_a_vzhi + 12
clip_b_vxhi = clip_b_vxlo + 12
clip_b_vylo = clip_b_vxhi + 12
clip_b_vyhi = clip_b_vylo + 12
clip_b_vzlo = clip_b_vyhi + 12
clip_b_vzhi = clip_b_vzlo + 12
RUNTIME_AFTER_CLIP_VERTEX = clip_b_vzhi + 12
.else
.if WIRE_RENDER_ENABLE != 0
RUNTIME_AFTER_CLIP_VERTEX = clip_b_flag + 12
.else
.if MODE7_UV_CARRIER != 0
RUNTIME_AFTER_CLIP_VERTEX = clip_b_shade + 12
.else
RUNTIME_AFTER_CLIP_VERTEX = clip_b_y + 12
.endif
.endif
.endif
clip_raw_in_lo = RUNTIME_AFTER_CLIP_VERTEX
clip_raw_in_hi = clip_raw_in_lo + 1
clip_raw_out_lo = clip_raw_in_hi + 1
clip_raw_out_hi = clip_raw_out_lo + 1
clip_axis_in_lo = clip_raw_out_hi + 1
clip_axis_in_hi = clip_axis_in_lo + 1
clip_num16_lo = clip_axis_in_hi + 1
clip_num16_hi = clip_num16_lo + 1
clip_den16_lo = clip_num16_hi + 1
clip_den16_hi = clip_den16_lo + 1
clip_rem_ext = clip_den16_hi + 1
RUNTIME_AFTER_CLIP = clip_rem_ext + 1
.else
RUNTIME_AFTER_CLIP = RUNTIME_AFTER_NEAR
.endif
.if STANDARD_PROJECT_VERTEX != 0
sx_prev = RUNTIME_AFTER_CLIP
sy_prev = sx_prev + VERT_COUNT
smooth_ready = sy_prev + VERT_COUNT
RUNTIME_AFTER_SMOOTH = smooth_ready + VERT_COUNT
.else
RUNTIME_AFTER_SMOOTH = RUNTIME_AFTER_CLIP
.endif
sz = RUNTIME_AFTER_SMOOTH
szhi = sz + VERT_COUNT
; Semantic aliases: sz/szhi contain camera-space geometry only.  p1lo/p1hi
; carry the checked projection index only inside projection helpers.
camera_depth_geometric_lo = sz
camera_depth_geometric_hi = szhi
projection_table_index_lo = p1lo
projection_table_index_hi = p1hi
rxbuf = szhi + VERT_COUNT
rybuf = rxbuf + VERT_COUNT
projdone = rybuf + VERT_COUNT
x_m00 = projdone + VERT_COUNT
x_m10 = x_m00 + XCOORD_COUNT
x_m20 = x_m10 + XCOORD_COUNT
y_m01 = x_m20 + XCOORD_COUNT
y_m11 = y_m01 + YCOORD_COUNT
y_m21 = y_m11 + YCOORD_COUNT
z_m02 = y_m21 + YCOORD_COUNT
z_m12 = z_m02 + ZCOORD_COUNT
z_m22 = z_m12 + ZCOORD_COUNT
leftb = z_m22 + ZCOORD_COUNT
VIEWPORT_ROW_CAPACITY = 100
rightb = leftb + VIEWPORT_ROW_CAPACITY
.if MODE7_UV_CARRIER != 0
leftshade = rightb + VIEWPORT_ROW_CAPACITY
rightshade = leftshade + VIEWPORT_ROW_CAPACITY
RUNTIME_AFTER_GOURAUD_ROWS = rightshade + VIEWPORT_ROW_CAPACITY
.else
RUNTIME_AFTER_GOURAUD_ROWS = rightb + VIEWPORT_ROW_CAPACITY
.endif
.if LAZY_CONVEX_BOUNDS != 0
bounds_stamp = RUNTIME_AFTER_GOURAUD_ROWS
dirtymin_a = bounds_stamp + VIEWPORT_ROW_CAPACITY
.else
dirtymin_a = RUNTIME_AFTER_GOURAUD_ROWS
.endif
dirtymax_a = dirtymin_a + VIEWPORT_ROW_CAPACITY
dirtymin_b = dirtymax_a + VIEWPORT_ROW_CAPACITY
dirtymax_b = dirtymin_b + VIEWPORT_ROW_CAPACITY
.if (PROJ_SCREEN_MAX_Y + 1) > VIEWPORT_ROW_CAPACITY
 .error "Viewport height exceeds per-row runtime capacity"
.endif
.if rightb != leftb + VIEWPORT_ROW_CAPACITY || dirtymax_a != dirtymin_a + VIEWPORT_ROW_CAPACITY || dirtymin_b != dirtymax_a + VIEWPORT_ROW_CAPACITY || dirtymax_b != dirtymin_b + VIEWPORT_ROW_CAPACITY
 .error "Per-row runtime arrays are not contiguous 100-byte ranges"
.endif
.if MODE7_UV_CARRIER != 0 && (leftshade != rightb + VIEWPORT_ROW_CAPACITY || rightshade != leftshade + VIEWPORT_ROW_CAPACITY)
 .error "Gouraud left/right shade rows are not contiguous 100-byte ranges"
.endif
.if MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = 0
bucket_head = dirtymax_b + VIEWPORT_ROW_CAPACITY
bucket_used_count = bucket_head + 256
bucket_used_list = bucket_used_count + 1
face_next = bucket_used_list + FACE_BUCKET_USED_LIST_CAPACITY
 .if MODE2_FACE_BUCKET_PIPELINE != 0
face_object = face_next + FACE_COUNT
RUNTIME_AFTER_FACE_OWNER = face_object + FACE_COUNT
 .else
RUNTIME_AFTER_FACE_OWNER = face_next + FACE_COUNT
 .endif
.else
RUNTIME_AFTER_FACE_OWNER = dirtymax_b + VIEWPORT_ROW_CAPACITY
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
shared_source_vertex = RUNTIME_AFTER_FACE_OWNER
shared_runtime_face = shared_source_vertex + 1
shared_vertex_delta = shared_runtime_face + 1
shared_fv0 = shared_vertex_delta + 1
shared_fv1 = shared_fv0 + 1
shared_fv2 = shared_fv1 + 1
shared_fv3 = shared_fv2 + 1
RUNTIME_AFTER_SHARED_SOURCE = shared_fv3 + 1
.else
RUNTIME_AFTER_SHARED_SOURCE = RUNTIME_AFTER_FACE_OWNER
.endif
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
frame_face_prepare = RUNTIME_AFTER_SHARED_SOURCE
frame_face_spanw = frame_face_prepare + FACE_COUNT
frame_face_spanh = frame_face_spanw + FACE_COUNT
RUNTIME_AFTER_FACE_PREPARE = frame_face_spanh + FACE_COUNT
.else
RUNTIME_AFTER_FACE_PREPARE = RUNTIME_AFTER_SHARED_SOURCE
.endif
.if STATIC_SHADE_DIRECT != 0
.if WIRE_DEPTH_SORT_ENABLE != 0
wire_bucket_head = RUNTIME_AFTER_FACE_PREPARE
wire_next = wire_bucket_head + 256
wire_entry_obj = wire_next + WIRE_DEPTH_ENTRY_COUNT
wire_entry_x0 = wire_entry_obj + WIRE_DEPTH_ENTRY_COUNT
wire_entry_y0 = wire_entry_x0 + WIRE_DEPTH_ENTRY_COUNT
wire_entry_x1 = wire_entry_y0 + WIRE_DEPTH_ENTRY_COUNT
wire_entry_y1 = wire_entry_x1 + WIRE_DEPTH_ENTRY_COUNT
RUNTIME_AFTER_WIRE_DEPTH = wire_entry_y1 + WIRE_DEPTH_ENTRY_COUNT
.else
RUNTIME_AFTER_WIRE_DEPTH = RUNTIME_AFTER_FACE_PREPARE
.endif
.if WIRE_FACE_EDGE_ENABLE != 0
edge_drawn = RUNTIME_AFTER_WIRE_DEPTH
RUNTIME_BUFFER_END = edge_drawn + WIRE_EDGE_COUNT
.else
RUNTIME_BUFFER_END = RUNTIME_AFTER_WIRE_DEPTH
.endif
.else
.if MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = 0
frame_face_shade = RUNTIME_AFTER_FACE_PREPARE
.if FRAME_FACE_FILL_CACHE != 0
frame_face_fill = frame_face_shade + FACE_COUNT
.if MODE4_SHADE_STEP_LIMIT != 0
mode4_shade_step_rank = frame_face_fill + FACE_COUNT
RUNTIME_AFTER_FACE_SHADE = mode4_shade_step_rank + FACE_COUNT
.else
RUNTIME_AFTER_FACE_SHADE = frame_face_fill + FACE_COUNT
.endif
.else
.if MODE4_SHADE_STEP_LIMIT != 0
mode4_shade_step_rank = frame_face_shade + FACE_COUNT
RUNTIME_AFTER_FACE_SHADE = mode4_shade_step_rank + FACE_COUNT
.else
RUNTIME_AFTER_FACE_SHADE = frame_face_shade + FACE_COUNT
.endif
.endif
.else
RUNTIME_AFTER_FACE_SHADE = RUNTIME_AFTER_FACE_PREPARE
.endif
.if WIRE_DEPTH_SORT_ENABLE != 0
wire_bucket_head = RUNTIME_AFTER_FACE_SHADE
wire_next = wire_bucket_head + 256
wire_entry_obj = wire_next + WIRE_DEPTH_ENTRY_COUNT
wire_entry_x0 = wire_entry_obj + WIRE_DEPTH_ENTRY_COUNT
wire_entry_y0 = wire_entry_x0 + WIRE_DEPTH_ENTRY_COUNT
wire_entry_x1 = wire_entry_y0 + WIRE_DEPTH_ENTRY_COUNT
wire_entry_y1 = wire_entry_x1 + WIRE_DEPTH_ENTRY_COUNT
RUNTIME_AFTER_WIRE_DEPTH = wire_entry_y1 + WIRE_DEPTH_ENTRY_COUNT
.else
RUNTIME_AFTER_WIRE_DEPTH = RUNTIME_AFTER_FACE_SHADE
.endif
.if WIRE_FACE_EDGE_ENABLE != 0
edge_drawn = RUNTIME_AFTER_WIRE_DEPTH
RUNTIME_BUFFER_END = edge_drawn + WIRE_EDGE_COUNT
.else
RUNTIME_BUFFER_END = RUNTIME_AFTER_WIRE_DEPTH
.endif
.endif
.if WORLD_GROUND_OCCLUDE != 0
ground_vside = RUNTIME_BUFFER_END
RUNTIME_AFTER_GROUND = ground_vside + VERT_COUNT
.else
RUNTIME_AFTER_GROUND = RUNTIME_BUFFER_END
.endif
.if VIC_COLOR_POLICY_ENABLE != 0
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0
vic_color_owner_screen = RUNTIME_AFTER_GROUND
.else
vic_color_owner_screen = $9000
.endif
vic_color_owner_color = vic_color_owner_screen + 1000
.if VIC_COLOR_POLICY_OVERLAY != 0
vic_color_conflict_map = vic_color_owner_color + 1000
RUNTIME_BUFFER_COLOR_POLICY_END = vic_color_conflict_map + 1000
.else
vic_color_conflict_map = vic_color_owner_color + 1000
RUNTIME_BUFFER_COLOR_POLICY_END = vic_color_owner_color + 1000
.endif
.else
RUNTIME_BUFFER_COLOR_POLICY_END = RUNTIME_AFTER_GROUND
.endif
.if MEMORY_LAYOUT_HIGH_BASIC_V2 = 0 && VIC_COLOR_POLICY_ENABLE != 0 && RUNTIME_BUFFER_COLOR_POLICY_END > $a000
 .error "VIC color policy block overlaps bitmap buffer B"
.endif
.if RUNTIME_BUFFER_COLOR_POLICY_END > RUNTIME_BUFFER_LIMIT
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 || VIC_COLOR_POLICY_ENABLE = 0
 .error "Runtime buffer block overlaps screen buffer B"
.endif
.endif
; Mesh: two-rooms-floor-cubes-perspective-gouraud-q8
; Quality: fast
; Renderer: 3Dvibe64 active=1 planApplied=1
; RendererPlan: name=3Dvibe64 ground=none camera=walk-lite cameraFull=0 near=none screen=poly shade=dynamic-gouraud-ordered-dither fill=small-scene-spans clear=dirty modeBudget=engine-fast
; RenderFrameScaffold: active=1 begin=render_frame_begin worldBackground=render_world_background sceneRenderer=render_scene_renderer end=render_frame_end mode=inline-fallthrough dispatch=ground-selected-by-renderer
; EngineGroundSimple: runtimeActive=0 horizonOnlyRuntime=0 engineFullRuntime=0 call= groundOccludeRuntime=0 wireOccludeRuntime=0 wireMaskHelpers=0 wireMaskData=0 wireRollRuntime=0 rollPlaneRuntime=0 meshDrawnAbove=1
; EngineMode3FramePrefill: runtimeActive=0 fusedClearGround=0 cellrowWriteOnChange=0 fallback=0 viewport=normal
; EngineMode3FacePrepareOnce: runtimeActive=0 stateCache=0 unclippedFastload=0 clipFallback=0 drawRecheckStripped=0 spanCache=width-height meshScope=all-scene-meshes scope=engine-mode3-only
; EngineMode3DirectConvexFill: runtimeActive=0 preparedOnly=0 triQuad=0 clipFallback=0 directFlag=0 fallback=bounds scope=engine-mode3-only
; EngineMode3NativeConvexQuadFill: runtimeActive=0 preparedOnly=0 singleSpanPerScanline=0 fanFallback=0 trianglesUnchanged=0 edgeChains=plus1-minus1 horizontalLinks=folded splitRow=merged scope=engine-mode3-prepared-quads-only
; EngineMode3FastBoundsTrace: runtimeActive=0 accumulator8=0 directLeftRight=0 overflowFallback16=0 byteSafeRule=dx-plus-dy-le-256 fallback=16bit scope=engine-mode3-bounds-only
; EngineMode3SpanHotloop: runtimeActive=0 directIndexed=0 boundsIndexedLong=0 boundsKernelMaxDiff=5 indexedMaxDiff=31 directByteAlignedEdges=0 materialCellTransition=0 materialKey=y-and-fc fallback=pointer-loop scope=engine-mode3-fill-only
; EngineMode3Consolidation: runtimeActive=0 check=0 framePrefillCompatible=1 universalPathsOnly=0 compactFaceQueue=0 normalViewport=0 smallViewport=0 multiObject=0 fallbacksPreserved=0 stack=frame-prefill-when-ground,face-prepare-once,direct-convex,fast-bounds,span-hotloop,static-shading scope=engine-mode3-only
; EngineMode3StableGroundCellLayout043a: runtimeActive=0 auto=0 multiObject=0 objectCount=2 sharedRamp=0 groundSlot01=0 objectSlot10=0 objectSlot11=0 groundColorRamWriteStripped=0 doubleBufferSafe=0 materialDark=255 materialHigh=255 materialHighlight=255 slotMap=none eligibility=disabled scope=engine-mode3-compatible-ground-scenes
; EngineMode3AdaptiveCellPolicy043b: runtimeActive=0 policy=disabled sharedExact=0 screenPair=0 rampCount=0 multiRamp=0 thirdColorRamps=0 highlightFoldHigh=0 faceSolidColor=0 groundSlot11=0 objectSlots01and10=0 colorRamFixedGround=0 doubleBufferSafe=0 runtimeMaterialSafe=0 runtimeMaterialDynamic=0 userCellConflict=0 slotMap=none eligibility=disabled conflictPolicy=depth-order-last-face-owns-cell scope=engine-mode3-ground-static-shading
; EngineMode3DemoCellColorStability: active=0 threeColor=0 staticShading=0 shadeVariants=4 noFaceSolidOverride=0 shadeFamilyReencoded=0 materialDark=255 materialHigh=255 materialHighlight=255 slotMap=none groundSlot01=0 objectSlot10=0 objectSlot11=0 objectSlot11Color=255 vicPolicyOff=0 groundBitmap01=0 groundColorRamWriteStripped=0 doubleBufferColorStable=0 scope=strict-check-over-universal-layout
; EngineWireContract: runtimeActive=0 engineMode=6 video=bitmap-multicolor-lowres vicMulticolor=1 singlePixel=0 requestedVic=off requestedVicEnable=0 requestedVicActive=0 effectiveVicEnable=0 effectiveVicActive=0 forcedVicOff=0 materialWirePath=0 wireObjectMaterialPath=0 materialCells=0 groundHorizonDarkGrey=0 groundHorizonScreenByte=bb groundHorizonColorRam=0b horizonMaterialIsolated=0 horizonMaterialRestore=0 meshWireMaterialReloadAfterGround=0 cameraThroughMesh=0 nearClipRelaxed=0 objectRejectRelaxed=0 edgeClipTolerant=0 mode2MaskNearTolerant=0 engineModeTerminology=1
; WireTwoColorMultimaterial: requested=0 active=0 mode1=0 mode2=0 slot01Family=none slot01Color=0 slot01Pattern=55 slot10Family=none slot10Color=0 slot10Pattern=aa screenByte=00 fixedColorRam=00 colorRamDifferentiates=0 faceCount=64 slot01Faces=0 slot10Faces=0 mode1Edges=0 mode1CrossMaterialEdges=0 mode1Owner=first-source-adjacent-face mode2FaceEdgeRefs=0 mode2UniqueEdges=0 mode2Redraws=0 mode2SameBucketTieStable=0 mode2SameBucketOrder=descending-face-index mode2SameBucketWinner=lowest-source-face-index runtimeOwnerBuffers=0
; EngineWireSpeedPass1: runtimeActive=0 dirtyClear=0 horizonDirect=0 solidFeaturesStripped=0 mode2MaskDirtyTrack=0 scope=engine-mode1-2-only visualContract=unchanged
; EngineWireSpeedPass2: runtimeActive=0 cellWriteSkipSame=0 materialCacheResetFrame=0 mode2MaskColorWritesStripped=0 scope=engine-mode1-2-only visualContract=unchanged
; EngineWireSpeedPass3Redo: runtimeActive=0 lightShadingStripped=0 mode1FacePassStripped=0 mode1EdgeTableDirect=0 scope=engine-mode1-2-only pass3Conservative=1 visualContract=unchanged
; EngineWireEdgeMaterialContext: runtimeActive=0 invalidateOnMaterialChange=0 perPixelMaterialCompareStripped=0 cacheKey=buffer-row-cell scope=engine-mode1-2-only fallback=pass2-material-aware-cache visualContract=unchanged
; EngineMode1FacePassStrip020Fix1: runtimeActive=0 generatedFaceEdgesOnly=0 wireFaceEdgeRuntime=0 sharedSupportRoutinesRetained=1 wireEdgeCount=0 noNewAsmRoutines=1 scope=engine-mode1-only
; EngineMode1WireFastPlot: runtimeActive=0 inScreenFastPath=0 clipFallback=0 fastPath=raw-endpoints-inside directDraw=draw-wire-edge fallback=clip-wire-edge-screen-plus-guard scope=engine-mode1-only visualContract=unchanged
; EngineMode1UniversalEdgeTraversal: runtimeActive=0 projdoneDirectTest=0 vertexDrawableFallback=0 meshScope=all-build-time-edge-lists cameraScope=movable-camera fallback=fixed-camera-and-non-engine-mode1 visualContract=unchanged
; EngineMode1WireRasterHotloop: runtimeActive=0 pointDirectEntry=0 pointBoundsStripped=0 materialCellRowCache=0 materialStartbyteReuse=0 meshScope=all-edge-lists endpointContract=fastpath-or-clipped scope=engine-mode1-only visualContract=unchanged
; EngineMode2WireRasterHotloop: runtimeActive=0 pointBoundsStripped=0 materialCellRowCache=0 materialStartbyteReuse=0 faceEdgeDirectDraw=0 clipGuardFallback=0 meshScope=all-visible-face-edge-lists endpointContract=inside-normal-or-guarded-clipped scope=engine-mode2-only horizonRowMaskPreserved=0 visualContract=unchanged
; EngineWireScanlineRunRasterizer029Fix1: runtimeActive=0 mode1=0 mode2=0 shallowOnly=0 pointFallback=0 endpointStatePreserved=0 runWriter=pwh-span-direct maskTraceFallback=per-point meshScope=all-meshes scope=engine-mode1-2-only visualContract=unchanged
; EngineWireSteepLineFastpath: runtimeActive=0 mode1=0 mode2=0 ratio2to1=0 verticalRunWriter=0 pointFallback=0 endpointStatePreserved=0 maskTraceFallback=per-point meshScope=all-meshes scope=engine-mode1-2-only visualContract=unchanged
; EngineWireCellTransitionUpdates: runtimeActive=0 mode1=0 mode2=0 dirtySameByteSkip=0 materialCallOnCellChange=0 materialDirectWriteEntry=0 transitionCacheResetFrame=0 pointPathOnly=1 runWritersPreserved=1 meshScope=all-meshes scope=engine-mode1-2-only visualContract=unchanged
; EngineWire8BitBresenham: runtimeActive=0 mode1=0 mode2=0 intermediateSlopes=0 errorAccumulator8bit=0 old16bitFallback=0 slopeContract=dx-lt-dy-lt-2dx maskTraceFallback=16bit meshScope=all-meshes scope=engine-mode1-2-only visualContract=pixel-identical
; EngineWireRasterConsolidation: runtimeActive=0 mode1=0 mode2=0 singleSlopeDispatch=0 singleTraceGate=0 traceFallback=0 algorithms=scanline-run,vertical-run,bresenham8 maskTraceFallback=16bit meshScope=all-meshes scope=engine-mode1-2-only visualContract=unchanged
; EngineMode2HorizonRowMask: candidate=0 runtimeActive=0 rowSource=world-ground-saved-horizon boundsInit=single-row clearRows=1 fallback=full-face-when-runtime-marker-off scope=engine-mode2-only
; EngineWireMaterialIsolation: runtimeActive=0 horizonMaterialIsolated=0 horizonMaterialRestore=0 meshWireMaterialReloadAfterGround=0 wireObjectMaterial=0 expectedHorizon=dark-grey expectedMesh=object-material
; EngineWireCameraThroughMesh: runtimeActive=0 nearClipRelaxed=0 objectRejectRelaxed=0 edgeClipTolerant=0 mode2MaskNearTolerant=0 depthInvalidVerticesProjected=near-plane markedProjected=1 scope=engine-mode1-2-only
; EngineMode2HiddenWireContract: runtimeActive=0 wire=0 hiddenWire=0 polyFill=0 vicRuntime=0 faceMaskContract=0 faceMaskRuntime=0 horizonBehindFaceTarget=0 horizonBehindFaceRuntime=0 horizonRowMaskCandidate=0 horizonRowMaskRuntime=0 maskImplementation=horizon-row-runtime-with-compile-time-full-face-fallback
; CameraProfile: mode=walkLite runtimeActive=1 walkLite=1 walkFull=0 roll=0 pitch=1
; EngineCameraViewport: configurable=1 allEngineModes=1 profile=normal small=0 logical=160x100 physical=160x100 origin=[0,0] focal=170 projectionScaled=0 clearLimited=0 groundLimited=0 cellOriginX=0 cellWidth=40 scope=graphics-modes-1-5 singleRenderer=1
; EngineMode1WirePure: runtimeActive=0 wire=0 wireFaceEdge=0 wirePure=0 hiddenWire=0 polyFill=0 wireDepth=0 wireObjectSort=0 vicRuntime=0 requestedVic=off requestedVicEnable=0 effectiveVicEnable=0 forcedVicOff=0 groundSimple=0 groundHorizonOnly=0 groundOccludeRuntime=0 cameraEngine=1 edgeDepthSortDisabled=1
; Mode1ObjectDepthSort: active=0 renderableMeshes=2 key=camera-space-origin-z order=far-to-near ties=json-order complexity=quadratic scope=engine-mode1-multi-object-only
; Mode2FaceBucketPipeline: active=0 stages=collect-load-clip-screen-winding-bucket-mask-edges classifier=shoelace-signed24 scope=engine-mode2-only
; GraphicsMode: 6 source=6 runtimeSwitch=0 wire=0 wireOverlay=0 wireDepth=0 wireDepthEntries=0 wireObjectSort=0 wireObjectMaterial=0 hiddenWire=0 wireFaceEdge=0 polyFill=1 polygonOutline=0 outlineColor=world-background lazyBounds=0 directEdgeSpans=1 spanKernel=1 indexedOffsetSpan=0 fanFill=0 fastFillBoundsTrace=0 engineMode4FastBoundsTrace=0 faceRender=1 wirePure=0 staticShade=0 staticDirect=0 fullDynamicShade=0 frameFaceFillCache=0 objectLightCache=1 objectLightCacheModes=4-5
; ClearMode: dirty
; Projection: extended-table reference=0 extendedTable=1 explorerTable=0 explorerMatrixFold=1 motionZStart256=0 motionZStep256=0 motionZStartOnReturn=0 motionZStartOnZero=0 sceneObjects=2
; SceneAxes: input=world-z-up internal=engine-y-up viewZ=depth
; ObjectModel: contract=1 worldObject=1 cameraObject=1 lightObjects=1 primaryLightIndex=0 extraLightsIgnored=0 meshObjects=2 solidMeshObjects=2 wireMeshObjects=0 singleMaterialMeshObjects=0 multimaterialMeshObjects=2 objectSpaceAlignedWorld=1 worldSpaceZUp=1 publicWorld=world-z-up internal=engine-y-up markers=contract operational=runtime-consumed
; MeshProfiles: objectKind=mesh sourceSharingRuntime=0 instanceExpansionMode=1 solidProfile=1 wireProfile=1 wireAliasType=wire normalizedAsMesh=1 meshIsWireTable=False materialSingleProfile=1 multimaterialProfile=1 multimaterialAlias=geometry:multimaterial normalizedMultimaterialAsSolid=1 faceMaterialTableActive=1 faceSolidColorTableRequested=0
; World: backgroundColor=0 grounds=0 enabledGrounds=0 groundRaster=none groundOcclude=0 groundHorizonOnly=0 groundRollSpanEdge=0 groundVicPolicyScope=procedural-prefill reservedGroundFields=material,reflectivity,extent,halfExtent
; FaceRenderMode: auto forceFaceRender=0 conservativeCull=1 negArea=32 edgeNegArea=96 sliverCull=1 sliver=thin3/long6
; FaceCullProfile: default stable=0 cameraSpaceSupport=1 strategy=screen-safe-plus-camera-space-edge-band source=original-face cameraSpaceNormal=mode45-shading screenAreaBand=64 edgeEpsilonWU=1
; CameraPlaneCull: sceneObjects=2 faceMinDepth=8 sceneRenderMinY=0 fpsOverlay=0 fpsCounter=0 objectStatePreserved=True
; Controls: fpsF=0 fpsStart=0 fpsCounterOnly=0 space=0 return=0 rotation=0 light=0 lowres=0 lowresTrace=False material=0 reflectivity=0 reflectivityCycleLevels=4 randomMaterial=0 randomMaterialTicks=100
; MaterialCellSpanCache: 1 activeOnlyMaterial=0 activeOnlyReflectivity=0 faceSolidColor=0 requested=0 wireEdgeSolidColor=0 requested=0
; VicColorPolicy: mode=off fallback=first fallbackMode=0 enable=0 active=0 overlay=0 materialSpanCache=1 cells=40x25 signature=screen+color counters=total/fill/wire
; FpsSystem: counter=0 counterOnly=0 overlay=0 keyF=0 onStart=0 memoryContract=1 underIoLayout=0 textBase=$CC00 textEnd=$CFFF textUnderIo=0 textClearCells=120 charsetBase=$C800 charsetEnd=$CFFF charsetUnderIo=0 textD018=$32 textRelocatedD800=0 charsetRelocatedD000=0 engineRelocated=0 engineMode3Relocated=0 lastValueLabel=fps_last_value lastTenthsLabel=fps_last_tenths
; InitialAngles: [24,25,47] staticPose=0
; Camera: source=scene index=0 name=camera position=[0,0,-10] rotation=[0,0,0] mode=walkLite viewport=normal movable=1 walkLite=1 walkFull=0 roll=0 nearClip=0 screenClip=poly
; WalkCameraIdleContract: inputDriven=1 startsStationary=1 poseWritesRequireInput=1 objectAnimationIndependent=1 runtimeControls=0
; CameraController: source=engine keys=WASD,Q/E,cursors rollN/M=False active=False rollActive=False noRuntimeControls=True
; MobileYQ2: active=1 viewport=normal source=camera-space-s16 division=mobile-perspective quotientBits=2 centerQ2=200 clampQ2=0..396 rows=0..99 x=LegacyDirect syLegacy=preserved faceGate=original-nonclipped-only nearSynthetic=0 screenSynthetic=0 clipBuffers=unchanged builder=DEV9-XYQ2
; CameraTiming: keyScan=main-after-wait-before-consume advance=advance-sim-tick prepareView=main-after-consume events=main-loop-once irq=counter-only
; DynamicLight: 1 source=scene:lamp:static phases=32 tickDiv=2 orbit=flat intensity=10 pulse=False pulseOnSpace=False staticPhase=-1 material=gray reflectivity=0
; StaticShade: 0 source=scene:lamp:static:phase0 light=[-12,12,16] intensity=10
; HasTriangleFaces: 1
; Effective MinFaceArea: 10
; Effective ScreenMinSpan: 3
; Effective PatternMinSpan: 6
; AutoCycleFrames: 0
; Runtime mesh records:
; 0: room1 type=mesh geometry=solid render=normal vertices=25 faces=36 shadeVertices=65 gouraudCreaseAngle=0 drawEdges=0
; 1: room2 type=mesh geometry=solid render=normal vertices=21 faces=28 shadeVertices=51 gouraudCreaseAngle=0 drawEdges=0
; Wire draw edge records: total=0 emitted=0 wireMeshes=0 pendingWireRenderer=True
; Scene objects:
; 0: room1 kind=mesh geometry=solid mesh=0 visible=1 scale64=64 material=gray reflectivity=satin
; 1: room2 kind=mesh geometry=solid mesh=1 visible=1 scale64=64 material=gray reflectivity=satin
mesh_vfirst:
 .byte $00,$19
mesh_vend:
 .byte $19,$2E
mesh_face_first:
 .byte $00,$24
mesh_face_end:
 .byte $24,$40
object_mesh:
 .byte $00,$01
object_pos_x_lo:
 .byte $00,$00
object_pos_x_hi:
 .byte $00,$00
object_pos_y_lo:
 .byte $00,$00
object_pos_y_hi:
 .byte $00,$00
object_pos_z_lo:
 .byte $00,$00
object_pos_z_hi:
 .byte $00,$30
object_pos_z_ext:
 .byte $00,$00
object_ang_x_lo:
 .byte $00,$00
object_ang_x_hi:
 .byte $00,$00
object_ang_y_lo:
 .byte $00,$00
object_ang_y_hi:
 .byte $00,$00
object_ang_z_lo:
 .byte $00,$00
object_ang_z_hi:
 .byte $00,$00
object_scale:
 .byte $40,$40
xcoord:
 .byte $E8,$ED,$F3,$F9,$00,$07,$0C,$14,$18
ycoord:
 .byte $F6,$FC,$FE,$12
zcoord:
 .byte $E8,$E9,$FC,$FD,$00,$03,$04,$17,$18,$19
vert_xi:
 .byte $00,$00,$00,$00,$08,$08,$08,$08,$03,$03,$05,$05,$04,$03,$03,$05
 .byte $05,$01,$01,$01,$01,$02,$02,$02,$02,$00,$00,$00,$00,$08,$08,$08
 .byte $08,$03,$03,$05,$05,$04,$06,$06,$06,$06,$07,$07,$07,$07
vert_yi:
 .byte $03,$03,$00,$00,$00,$00,$03,$03,$03,$00,$03,$00,$00,$03,$00,$00
 .byte $03,$00,$00,$01,$01,$01,$01,$00,$00,$03,$03,$00,$00,$00,$00,$03
 .byte $03,$00,$03,$00,$03,$00,$00,$00,$02,$02,$02,$02,$00,$00
vert_zi:
 .byte $00,$07,$07,$00,$00,$07,$07,$00,$07,$07,$07,$07,$04,$09,$09,$09
 .byte $09,$03,$05,$05,$03,$03,$05,$05,$03,$01,$08,$08,$01,$01,$08,$08
 .byte $01,$01,$01,$01,$01,$04,$02,$06,$06,$02,$02,$06,$06,$02
face0:
 .byte $00,$00,$04,$04,$03,$03,$01,$01,$0A,$0A,$0C,$0C,$0C,$0C,$0C,$0C
 .byte $00,$00,$08,$08,$0B,$0B,$0E,$0E,$08,$08,$11,$11,$15,$15,$14,$14
 .byte $12,$12,$13,$13,$19,$19,$1D,$1D,$1A,$1A,$1C,$1C,$23,$23,$25,$25
 .byte $25,$25,$25,$25,$19,$19,$26,$26,$2A,$2A,$29,$29,$27,$27,$28,$28
face1:
 .byte $01,$02,$05,$06,$04,$07,$08,$09,$06,$05,$04,$05,$0B,$09,$02,$03
 .byte $07,$06,$0D,$0E,$0F,$10,$0F,$0B,$0A,$10,$12,$13,$16,$17,$15,$18
 .byte $17,$16,$16,$15,$1A,$1B,$1E,$1F,$1F,$1E,$21,$22,$1D,$20,$21,$23
 .byte $1D,$1E,$1B,$1C,$20,$1F,$27,$28,$2B,$2C,$2A,$2D,$2C,$2B,$2B,$2A
face2:
 .byte $02,$03,$06,$07,$07,$00,$09,$02,$05,$0B,$03,$04,$05,$0B,$09,$02
 .byte $06,$01,$0E,$09,$10,$0A,$0B,$09,$10,$0D,$13,$14,$17,$18,$18,$11
 .byte $16,$13,$15,$14,$1B,$1C,$1F,$20,$1E,$1B,$22,$19,$20,$24,$1C,$21
 .byte $23,$1D,$1E,$1B,$1F,$1A,$28,$29,$2C,$2D,$2D,$26,$2B,$28,$2A,$29
face3:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
face_vertex_count:
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03

TEXTURE_MODE7 = 1
m7_v0: .byte 0
m7_v1: .byte 0
m7_v2: .byte 0
m7_v3: .byte 0
m7_u: .byte 0
m7_v: .byte 0
m7_den: .byte 0
m7_delta: .byte 0
m7_q: .byte 0
m7_r: .byte 0
m7_dir: .byte 0
m7_start: .byte 0
m7_index: .byte 0
m7_packed: .byte 0
m7_clip_a_v: .fill 12,0
m7_leftv: .fill VIEWPORT_ROW_CAPACITY,0
m7_rightv: .fill VIEWPORT_ROW_CAPACITY,0
m7_face_u0:
 .byte 0,0,0,0,0,0,0,0,83,83,107,11,11,43,107,107
 .byte 0,0,125,125,125,125,18,18,0,0,0,0,0,0,0,0
 .byte 0,0,0,0,3,3,3,3,0,0,0,0,83,83,107,43
 .byte 11,11,107,107,0,0,0,0,0,0,0,0,0,0,0,0
m7_face_u1:
 .byte 125,125,125,125,128,128,45,45,128,128,192,96,36,18,21,21
 .byte 0,0,131,131,131,131,68,68,0,0,0,0,0,0,0,0
 .byte 0,0,0,0,128,128,128,128,128,128,45,45,128,128,82,68
 .byte 96,96,21,21,0,0,0,0,0,0,0,0,0,0,0,0
m7_face_u2:
 .byte 125,0,125,0,128,0,45,0,128,83,21,96,96,68,82,21
 .byte 0,0,131,125,131,125,68,18,0,0,0,0,0,0,0,0
 .byte 0,0,0,0,128,3,128,3,128,0,45,0,128,83,21,18
 .byte 36,96,192,21,0,0,0,0,0,0,0,0,0,0,0,0
m7_face_v0:
 .byte 75,75,0,0,0,0,75,75,75,75,107,107,11,11,11,107
 .byte 0,0,75,75,0,0,36,36,0,0,0,0,0,0,0,0
 .byte 0,0,0,0,75,75,0,0,75,75,0,0,0,0,85,85
 .byte 85,85,21,85,0,0,0,0,0,0,0,0,0,0,0,0
m7_face_v1:
 .byte 75,0,0,75,0,75,75,0,75,0,21,188,92,92,92,21
 .byte 0,0,75,0,0,75,36,28,0,0,0,0,0,0,0,0
 .byte 0,0,0,0,75,0,0,75,75,0,0,75,0,75,4,4
 .byte 4,171,107,4,0,0,0,0,0,0,0,0,0,0,0,0
m7_face_v2:
 .byte 0,0,75,75,75,75,0,0,0,0,21,21,92,92,92,188
 .byte 0,0,0,0,75,75,28,28,0,0,0,0,0,0,0,0
 .byte 0,0,0,0,0,0,75,75,0,0,75,75,75,75,4,4
 .byte 4,4,107,171,0,0,0,0,0,0,0,0,0,0,0,0
m7_face_texture:
 .byte 0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
 .byte 2,2,0,0,0,0,1,1,2,2,2,2,2,2,2,2
 .byte 2,2,2,2,0,0,0,0,0,0,0,0,0,0,1,1
 .byte 1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
m7_pair:
 .byte 0,0,0,0,64,16,4,1,128,32,8,2,192,48,12,3
m7_texture_hi: .byte >m7_texture_0,>m7_texture_1,>m7_texture_2

m2_lighting_data_begin = *
m2_bayer:
 .byte 1,9,3,11,13,5,15,7,4,12,2,10,16,8,14,6
m2_bayer_row: .byte 0
m2_lighting_data_end = *
.align 256
m7_textures_begin = *
m7_texture_0:
 .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
 .byte 1,2,3,3,3,2,2,2,1,2,3,3,3,2,2,2
 .byte 1,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2
 .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
 .byte 3,2,2,2,1,2,3,3,3,2,2,2,1,2,3,3
 .byte 2,2,2,2,1,2,2,2,2,2,2,2,1,2,2,2
 .byte 2,2,2,2,1,2,2,2,2,2,2,2,1,2,2,2
 .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
 .byte 1,2,3,3,3,2,2,2,1,2,3,3,3,2,2,2
 .byte 1,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2
 .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
 .byte 3,2,2,2,1,2,3,3,3,2,2,2,1,2,3,3
 .byte 2,2,2,2,1,2,2,2,2,2,2,2,1,2,2,2
 .byte 2,2,2,2,1,2,2,2,2,2,2,2,1,2,2,2
m7_texture_1:
 .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,3,3,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,3,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 .byte 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
m7_texture_2 = m7_texture_0 ; no fetch: uniform texel2 path
m7_textures_end = *
face_shade:
 .byte $00,$80,$82,$02,$80,$00,$02,$82,$02,$82,$82,$82,$82,$82,$82,$82
 .byte $00,$00,$00,$80,$82,$02,$82,$82,$00,$00,$82,$82,$80,$80,$82,$82
 .byte $80,$80,$82,$82,$00,$80,$82,$02,$02,$82,$80,$00,$80,$00,$82,$82
 .byte $82,$82,$82,$82,$00,$00,$82,$82,$80,$80,$82,$82,$80,$80,$82,$82
face_material:
 .byte $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$09,$09,$09,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
face_reflect_offset:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
face_material_explicit:
 .byte $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$09,$09,$09,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
face_normal_x:
 .byte $3F,$3F,$C1,$C1,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$3F,$3F,$C1,$C1,$00,$00,$00,$00,$C1,$C1,$3F,$3F,$00,$00
 .byte $00,$00,$00,$00,$3F,$3F,$C1,$C1,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$C1,$C1,$3F,$3F,$00,$00,$00,$00,$00,$00
face_normal_y:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3F,$3F,$3F,$3F,$3F,$3F
 .byte $C1,$C1,$00,$00,$00,$00,$3F,$3F,$C1,$C1,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$3F,$3F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3F,$3F
 .byte $3F,$3F,$3F,$3F,$C1,$C1,$00,$00,$00,$00,$00,$00,$00,$00,$3F,$3F
face_normal_z:
 .byte $00,$00,$00,$00,$3F,$3F,$C1,$C1,$C1,$C1,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$C1,$C1
 .byte $3F,$3F,$00,$00,$00,$00,$00,$00,$C1,$C1,$3F,$3F,$3F,$3F,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$C1,$C1,$3F,$3F,$00,$00
face_center_dot_lo:
 .byte $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$C5,$C5,$C5,$C5,$C5,$C5
 .byte $C9,$C9,$04,$04,$04,$04,$C5,$C5,$C9,$C9,$76,$76,$86,$86,$7E,$7E
 .byte $7E,$7E,$82,$82,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$C5,$C5
 .byte $C5,$C5,$C5,$C5,$C9,$C9,$86,$86,$76,$76,$7E,$7E,$7E,$7E,$C1,$C1
face_center_dot_hi:
 .byte $FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FE,$FE,$FE,$FE,$FE,$FE
 .byte $FD,$FD,$FF,$FF,$FF,$FF,$FE,$FE,$FD,$FD,$02,$02,$FE,$FE,$00,$00
 .byte $00,$00,$FF,$FF,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FE,$FE
 .byte $FE,$FE,$FE,$FE,$FD,$FD,$FE,$FE,$02,$02,$00,$00,$00,$00,$FF,$FF
shade_thresh_mid:
 .byte $FF,$50,$28,$1B,$14,$10,$0E,$0C,$0A,$09,$08
shade_thresh_mid_high:
 .byte $FF,$A0,$50,$36,$28,$20,$1B,$17,$14,$12,$10
shade_thresh_high:
 .byte $FF,$F0,$78,$50,$3C,$30,$28,$23,$1E,$1B,$18
light_intensity_table:
 .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
 .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
light_pos_x:
 .byte $F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4
 .byte $F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4,$F4
light_pos_y:
 .byte $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
 .byte $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
light_pos_z:
 .byte $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
 .byte $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
material_screen_bytes:
 .byte 188,193,42,93,110,151,99,74,152,156,188,193,42,93,110,151,99,74,136,156,188,193,42,93,110,151,99,74,136,156,188,193,42,93,110,151,99,74,136,156
material_color_bytes:
 .byte 15,1,10,13,14,7,3,10,10,15,15,1,15,1,15,1,1,15,10,15,15,1,15,1,15,1,1,15,15,15,15,1,1,1,1,1,1,1,1,15
sintab:
 .byte $00,$02,$03,$05,$06,$08,$09,$0B,$0C,$0E,$10,$11,$13,$14,$16,$17
 .byte $18,$1A,$1B,$1D,$1E,$20,$21,$22,$24,$25,$26,$27,$29,$2A,$2B,$2C
 .byte $2D,$2E,$2F,$30,$31,$32,$33,$34,$35,$36,$37,$38,$38,$39,$3A,$3B
 .byte $3B,$3C,$3C,$3D,$3D,$3E,$3E,$3E,$3F,$3F,$3F,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$3F,$3F,$3F,$3E,$3E,$3E,$3D,$3D,$3C,$3C
 .byte $3B,$3B,$3A,$39,$38,$38,$37,$36,$35,$34,$33,$32,$31,$30,$2F,$2E
 .byte $2D,$2C,$2B,$2A,$29,$27,$26,$25,$24,$22,$21,$20,$1E,$1D,$1B,$1A
 .byte $18,$17,$16,$14,$13,$11,$10,$0E,$0C,$0B,$09,$08,$06,$05,$03,$02
 .byte $00,$FE,$FD,$FB,$FA,$F8,$F7,$F5,$F4,$F2,$F0,$EF,$ED,$EC,$EA,$E9
 .byte $E8,$E6,$E5,$E3,$E2,$E0,$DF,$DE,$DC,$DB,$DA,$D9,$D7,$D6,$D5,$D4
 .byte $D3,$D2,$D1,$D0,$CF,$CE,$CD,$CC,$CB,$CA,$C9,$C8,$C8,$C7,$C6,$C5
 .byte $C5,$C4,$C4,$C3,$C3,$C2,$C2,$C2,$C1,$C1,$C1,$C0,$C0,$C0,$C0,$C0
 .byte $C0,$C0,$C0,$C0,$C0,$C0,$C1,$C1,$C1,$C2,$C2,$C2,$C3,$C3,$C4,$C4
 .byte $C5,$C5,$C6,$C7,$C8,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF,$D0,$D1,$D2
 .byte $D3,$D4,$D5,$D6,$D7,$D9,$DA,$DB,$DC,$DE,$DF,$E0,$E2,$E3,$E5,$E6
 .byte $E8,$E9,$EA,$EC,$ED,$EF,$F0,$F2,$F4,$F5,$F7,$F8,$FA,$FB,$FD,$FE
sqlo:
 .byte $00,$00,$01,$02,$04,$06,$09,$0C,$10,$14,$19,$1E,$24,$2A,$31,$38
 .byte $40,$48,$51,$5A,$64,$6E,$79,$84,$90,$9C,$A9,$B6,$C4,$D2,$E1,$F0
 .byte $00,$10,$21,$32,$44,$56,$69,$7C,$90,$A4,$B9,$CE,$E4,$FA,$11,$28
 .byte $40,$58,$71,$8A,$A4,$BE,$D9,$F4,$10,$2C,$49,$66,$84,$A2,$C1,$E0
 .byte $00,$20,$41,$62,$84,$A6,$C9,$EC,$10,$34,$59,$7E,$A4,$CA,$F1,$18
 .byte $40,$68,$91,$BA,$E4,$0E,$39,$64,$90,$BC,$E9,$16,$44,$72,$A1,$D0
 .byte $00,$30,$61,$92,$C4,$F6,$29,$5C,$90,$C4,$F9,$2E,$64,$9A,$D1,$08
 .byte $40,$78,$B1,$EA,$24,$5E,$99,$D4,$10,$4C,$89,$C6,$04,$42,$81,$C0
 .byte $00,$40,$81,$C2,$04,$46,$89,$CC,$10,$54,$99,$DE,$24,$6A,$B1,$F8
 .byte $40,$88,$D1,$1A,$64,$AE,$F9,$44,$90,$DC,$29,$76,$C4,$12,$61,$B0
 .byte $00,$50,$A1,$F2,$44,$96,$E9,$3C,$90,$E4,$39,$8E,$E4,$3A,$91,$E8
 .byte $40,$98,$F1,$4A,$A4,$FE,$59,$B4,$10,$6C,$C9,$26,$84,$E2,$41,$A0
 .byte $00,$60,$C1,$22,$84,$E6,$49,$AC,$10,$74,$D9,$3E,$A4,$0A,$71,$D8
 .byte $40,$A8,$11,$7A,$E4,$4E,$B9,$24,$90,$FC,$69,$D6,$44,$B2,$21,$90
 .byte $00,$70,$E1,$52,$C4,$36,$A9,$1C,$90,$04,$79,$EE,$64,$DA,$51,$C8
 .byte $40,$B8,$31,$AA,$24,$9E,$19,$94,$10,$8C,$09,$86,$04,$82,$01,$80
sqhi:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $04,$04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$06
 .byte $06,$06,$06,$06,$06,$07,$07,$07,$07,$07,$07,$08,$08,$08,$08,$08
 .byte $09,$09,$09,$09,$09,$09,$0A,$0A,$0A,$0A,$0A,$0B,$0B,$0B,$0B,$0C
 .byte $0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D,$0E,$0E,$0E,$0E,$0F,$0F,$0F,$0F
 .byte $10,$10,$10,$10,$11,$11,$11,$11,$12,$12,$12,$12,$13,$13,$13,$13
 .byte $14,$14,$14,$15,$15,$15,$15,$16,$16,$16,$17,$17,$17,$18,$18,$18
 .byte $19,$19,$19,$19,$1A,$1A,$1A,$1B,$1B,$1B,$1C,$1C,$1C,$1D,$1D,$1D
 .byte $1E,$1E,$1E,$1F,$1F,$1F,$20,$20,$21,$21,$21,$22,$22,$22,$23,$23
 .byte $24,$24,$24,$25,$25,$25,$26,$26,$27,$27,$27,$28,$28,$29,$29,$29
 .byte $2A,$2A,$2B,$2B,$2B,$2C,$2C,$2D,$2D,$2D,$2E,$2E,$2F,$2F,$30,$30
 .byte $31,$31,$31,$32,$32,$33,$33,$34,$34,$35,$35,$35,$36,$36,$37,$37
 .byte $38,$38,$39,$39,$3A,$3A,$3B,$3B,$3C,$3C,$3D,$3D,$3E,$3E,$3F,$3F
row0lo_a:
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06
row0hi_a:
 .byte $60,$60,$60,$60,$61,$61,$61,$61,$62,$62,$62,$62,$63,$63,$63,$63
 .byte $65,$65,$65,$65,$66,$66,$66,$66,$67,$67,$67,$67,$68,$68,$68,$68
 .byte $6A,$6A,$6A,$6A,$6B,$6B,$6B,$6B,$6C,$6C,$6C,$6C,$6D,$6D,$6D,$6D
 .byte $6F,$6F,$6F,$6F,$70,$70,$70,$70,$71,$71,$71,$71,$72,$72,$72,$72
 .byte $74,$74,$74,$74,$75,$75,$75,$75,$76,$76,$76,$76,$77,$77,$77,$77
 .byte $79,$79,$79,$79,$7A,$7A,$7A,$7A,$7B,$7B,$7B,$7B,$7C,$7C,$7C,$7C
 .byte $7E,$7E,$7E,$7E
row1lo_a:
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07
row1hi_a:
 .byte $60,$60,$60,$60,$61,$61,$61,$61,$62,$62,$62,$62,$63,$63,$63,$63
 .byte $65,$65,$65,$65,$66,$66,$66,$66,$67,$67,$67,$67,$68,$68,$68,$68
 .byte $6A,$6A,$6A,$6A,$6B,$6B,$6B,$6B,$6C,$6C,$6C,$6C,$6D,$6D,$6D,$6D
 .byte $6F,$6F,$6F,$6F,$70,$70,$70,$70,$71,$71,$71,$71,$72,$72,$72,$72
 .byte $74,$74,$74,$74,$75,$75,$75,$75,$76,$76,$76,$76,$77,$77,$77,$77
 .byte $79,$79,$79,$79,$7A,$7A,$7A,$7A,$7B,$7B,$7B,$7B,$7C,$7C,$7C,$7C
 .byte $7E,$7E,$7E,$7E
row0lo_b:
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06,$40,$42,$44,$46,$80,$82,$84,$86,$C0,$C2,$C4,$C6
 .byte $00,$02,$04,$06
row0hi_b:
 .byte $20,$20,$20,$20,$21,$21,$21,$21,$22,$22,$22,$22,$23,$23,$23,$23
 .byte $25,$25,$25,$25,$26,$26,$26,$26,$27,$27,$27,$27,$28,$28,$28,$28
 .byte $2A,$2A,$2A,$2A,$2B,$2B,$2B,$2B,$2C,$2C,$2C,$2C,$2D,$2D,$2D,$2D
 .byte $2F,$2F,$2F,$2F,$30,$30,$30,$30,$31,$31,$31,$31,$32,$32,$32,$32
 .byte $34,$34,$34,$34,$35,$35,$35,$35,$36,$36,$36,$36,$37,$37,$37,$37
 .byte $39,$39,$39,$39,$3A,$3A,$3A,$3A,$3B,$3B,$3B,$3B,$3C,$3C,$3C,$3C
 .byte $3E,$3E,$3E,$3E
row1lo_b:
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07,$41,$43,$45,$47,$81,$83,$85,$87,$C1,$C3,$C5,$C7
 .byte $01,$03,$05,$07
row1hi_b:
 .byte $20,$20,$20,$20,$21,$21,$21,$21,$22,$22,$22,$22,$23,$23,$23,$23
 .byte $25,$25,$25,$25,$26,$26,$26,$26,$27,$27,$27,$27,$28,$28,$28,$28
 .byte $2A,$2A,$2A,$2A,$2B,$2B,$2B,$2B,$2C,$2C,$2C,$2C,$2D,$2D,$2D,$2D
 .byte $2F,$2F,$2F,$2F,$30,$30,$30,$30,$31,$31,$31,$31,$32,$32,$32,$32
 .byte $34,$34,$34,$34,$35,$35,$35,$35,$36,$36,$36,$36,$37,$37,$37,$37
 .byte $39,$39,$39,$39,$3A,$3A,$3A,$3A,$3B,$3B,$3B,$3B,$3C,$3C,$3C,$3C
 .byte $3E,$3E,$3E,$3E
screenrowlo_a:
 .byte $00,$00,$00,$00,$28,$28,$28,$28,$50,$50,$50,$50,$78,$78,$78,$78
 .byte $A0,$A0,$A0,$A0,$C8,$C8,$C8,$C8,$F0,$F0,$F0,$F0,$18,$18,$18,$18
 .byte $40,$40,$40,$40,$68,$68,$68,$68,$90,$90,$90,$90,$B8,$B8,$B8,$B8
 .byte $E0,$E0,$E0,$E0,$08,$08,$08,$08,$30,$30,$30,$30,$58,$58,$58,$58
 .byte $80,$80,$80,$80,$A8,$A8,$A8,$A8,$D0,$D0,$D0,$D0,$F8,$F8,$F8,$F8
 .byte $20,$20,$20,$20,$48,$48,$48,$48,$70,$70,$70,$70,$98,$98,$98,$98
 .byte $C0,$C0,$C0,$C0
screenrowhi_a:
 .byte $5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C
 .byte $5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$5D,$5D,$5D,$5D
 .byte $5D,$5D,$5D,$5D,$5D,$5D,$5D,$5D,$5D,$5D,$5D,$5D,$5D,$5D,$5D,$5D
 .byte $5D,$5D,$5D,$5D,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E
 .byte $5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E
 .byte $5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F
 .byte $5F,$5F,$5F,$5F
screenrowlo_b:
 .byte $00,$00,$00,$00,$28,$28,$28,$28,$50,$50,$50,$50,$78,$78,$78,$78
 .byte $A0,$A0,$A0,$A0,$C8,$C8,$C8,$C8,$F0,$F0,$F0,$F0,$18,$18,$18,$18
 .byte $40,$40,$40,$40,$68,$68,$68,$68,$90,$90,$90,$90,$B8,$B8,$B8,$B8
 .byte $E0,$E0,$E0,$E0,$08,$08,$08,$08,$30,$30,$30,$30,$58,$58,$58,$58
 .byte $80,$80,$80,$80,$A8,$A8,$A8,$A8,$D0,$D0,$D0,$D0,$F8,$F8,$F8,$F8
 .byte $20,$20,$20,$20,$48,$48,$48,$48,$70,$70,$70,$70,$98,$98,$98,$98
 .byte $C0,$C0,$C0,$C0
screenrowhi_b:
 .byte $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
 .byte $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05
 .byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 .byte $05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
 .byte $07,$07,$07,$07
colorrowlo:
 .byte $00,$00,$00,$00,$28,$28,$28,$28,$50,$50,$50,$50,$78,$78,$78,$78
 .byte $A0,$A0,$A0,$A0,$C8,$C8,$C8,$C8,$F0,$F0,$F0,$F0,$18,$18,$18,$18
 .byte $40,$40,$40,$40,$68,$68,$68,$68,$90,$90,$90,$90,$B8,$B8,$B8,$B8
 .byte $E0,$E0,$E0,$E0,$08,$08,$08,$08,$30,$30,$30,$30,$58,$58,$58,$58
 .byte $80,$80,$80,$80,$A8,$A8,$A8,$A8,$D0,$D0,$D0,$D0,$F8,$F8,$F8,$F8
 .byte $20,$20,$20,$20,$48,$48,$48,$48,$70,$70,$70,$70,$98,$98,$98,$98
 .byte $C0,$C0,$C0,$C0
colorrowhi:
 .byte $D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8
 .byte $D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D9,$D9,$D9,$D9
 .byte $D9,$D9,$D9,$D9,$D9,$D9,$D9,$D9,$D9,$D9,$D9,$D9,$D9,$D9,$D9,$D9
 .byte $D9,$D9,$D9,$D9,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA
 .byte $DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DA
 .byte $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
 .byte $DB,$DB,$DB,$DB
xbyte:
 .byte $00,$00,$00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03
 .byte $04,$04,$04,$04,$05,$05,$05,$05,$06,$06,$06,$06,$07,$07,$07,$07
 .byte $08,$08,$08,$08,$09,$09,$09,$09,$0A,$0A,$0A,$0A,$0B,$0B,$0B,$0B
 .byte $0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D,$0E,$0E,$0E,$0E,$0F,$0F,$0F,$0F
 .byte $10,$10,$10,$10,$11,$11,$11,$11,$12,$12,$12,$12,$13,$13,$13,$13
 .byte $14,$14,$14,$14,$15,$15,$15,$15,$16,$16,$16,$16,$17,$17,$17,$17
 .byte $18,$18,$18,$18,$19,$19,$19,$19,$1A,$1A,$1A,$1A,$1B,$1B,$1B,$1B
 .byte $1C,$1C,$1C,$1C,$1D,$1D,$1D,$1D,$1E,$1E,$1E,$1E,$1F,$1F,$1F,$1F
 .byte $20,$20,$20,$20,$21,$21,$21,$21,$22,$22,$22,$22,$23,$23,$23,$23
 .byte $24,$24,$24,$24,$25,$25,$25,$25,$26,$26,$26,$26,$27,$27,$27,$27
xofflo:
 .byte $00,$00,$00,$00,$08,$08,$08,$08,$10,$10,$10,$10,$18,$18,$18,$18
 .byte $20,$20,$20,$20,$28,$28,$28,$28,$30,$30,$30,$30,$38,$38,$38,$38
 .byte $40,$40,$40,$40,$48,$48,$48,$48,$50,$50,$50,$50,$58,$58,$58,$58
 .byte $60,$60,$60,$60,$68,$68,$68,$68,$70,$70,$70,$70,$78,$78,$78,$78
 .byte $80,$80,$80,$80,$88,$88,$88,$88,$90,$90,$90,$90,$98,$98,$98,$98
 .byte $A0,$A0,$A0,$A0,$A8,$A8,$A8,$A8,$B0,$B0,$B0,$B0,$B8,$B8,$B8,$B8
 .byte $C0,$C0,$C0,$C0,$C8,$C8,$C8,$C8,$D0,$D0,$D0,$D0,$D8,$D8,$D8,$D8
 .byte $E0,$E0,$E0,$E0,$E8,$E8,$E8,$E8,$F0,$F0,$F0,$F0,$F8,$F8,$F8,$F8
 .byte $00,$00,$00,$00,$08,$08,$08,$08,$10,$10,$10,$10,$18,$18,$18,$18
 .byte $20,$20,$20,$20,$28,$28,$28,$28,$30,$30,$30,$30,$38,$38,$38,$38
xoffhi:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
startmask:
 .byte $FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03
 .byte $FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03
 .byte $FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03
 .byte $FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03
 .byte $FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03
 .byte $FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03
 .byte $FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03
 .byte $FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03
 .byte $FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03
 .byte $FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03,$FF,$3F,$0F,$03
endmask:
 .byte $C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF
 .byte $C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF
 .byte $C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF
 .byte $C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF
 .byte $C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF
 .byte $C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF
 .byte $C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF
 .byte $C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF
 .byte $C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF
 .byte $C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF,$C0,$F0,$FC,$FF

.if EXPLORER_MATRIX_FOLD != 0
; Q8 has private 24-bit origins, matrix/terms and camera rotation.
; Preserve the Q6 object matrix used by the existing lighting pipeline.
prepare_explorer_matrix_fold:
 jmp prepare_object_matrix
.endif
.if MODE4_FACE_ID_LATCH != 0
; The bucket value in A is latched once, bounds-checked, then Y is restored
; from the dedicated cell before the ordinary face loop resumes.
mode4_latch_current_face_id:
 sta sortj
 sta mode4_current_face_id
 cmp #FACE_COUNT
 bcc mode4_latch_current_face_id_ok
 sei
mode4_latch_current_face_id_halt:
 jmp mode4_latch_current_face_id_halt
mode4_latch_current_face_id_ok:
 ldy mode4_current_face_id
 jmp ddb_face_loop
.endif
mode3_high_basic_high_code_end = *


; Q8 block core
* = $52e6
hp_block_core_begin:
hp_code_start:
explorer_transform_project_vertices:
 lda #0
 sta hp_used
 sta hp_fault
 jsr hp_origins
 bcs hc_go
 inc hp_fault
 ldx active_vfirst
 lda #0
hc_invalid:
 sta projdone,x
 inx
 cpx active_vend
 bne hc_invalid
 rts
hc_go:
 jsr hp_prepare_matrix
 jsr hp_prepare_terms
 jsr hp_build_vertices
 jsr qc_rotate_vertices
 jsr hc_project_vertices
 lda #1
 sta hp_used
 rts
hp_unreachable:
 brk
 jmp hp_unreachable
hp_mul:
 lda hp_a+1
 eor hp_b+1
 sta hp_sign
 lda hp_a+1
 bpl hp_mul_a_positive
 sec
 lda #0
 sbc hp_a
 sta hp_a
 lda #0
 sbc hp_a+1
 sta hp_a+1
hp_mul_a_positive:
 lda hp_b+1
 bpl hp_mul_b_positive
 sec
 lda #0
 sbc hp_b
 sta hp_b
 lda #0
 sbc hp_b+1
 sta hp_b+1
hp_mul_b_positive:
 lda hp_a
 sta hp_shift
 lda hp_a+1
 sta hp_shift+1
 lda #0
 sta hp_shift+2
 sta hp_shift+3
 sta hp_p
 sta hp_p+1
 sta hp_p+2
 sta hp_p+3
hp_mul_loop:
 lda hp_b
 ora hp_b+1
 beq hp_mul_done
 lsr hp_b+1
 ror hp_b
 bcc hp_mul_shift
 clc
 lda hp_p
 adc hp_shift
 sta hp_p
 lda hp_p+1
 adc hp_shift+1
 sta hp_p+1
 lda hp_p+2
 adc hp_shift+2
 sta hp_p+2
 lda hp_p+3
 adc hp_shift+3
 sta hp_p+3
hp_mul_shift:
 asl hp_shift
 rol hp_shift+1
 rol hp_shift+2
 rol hp_shift+3
 jmp hp_mul_loop
hp_mul_done:
 rts
hp_q8:
 jsr hp_mul
 clc
 lda hp_p
 adc #128
 lda hp_p+1
 adc #0
 sta hp_r
 lda hp_p+2
 adc #0
 sta hp_r+1
 jmp hp_apply_sign
hp_int_product:
 jsr hp_mul
 lda hp_p
 sta hp_r
 lda hp_p+1
 sta hp_r+1
hp_apply_sign:
 lda hp_sign
 bpl hp_sign_done
 sec
 lda #0
 sbc hp_r
 sta hp_r
 lda #0
 sbc hp_r+1
 sta hp_r+1
hp_sign_done:
 rts

; Linear interpolation of signed Q8 sine using the full 16-bit angle phase.
; Trig delta magnitude <=7. Symmetric nearest rounding, ties away from zero.
hp_sine:
 stx hp_sine_index
 lda hp_sin_lo,x
 sta hp_base
 lda hp_sin_hi,x
 sta hp_base+1
 inx
 sec
 lda hp_sin_lo,x
 sbc hp_base
 sta hp_a
 lda hp_sin_hi,x
 sbc hp_base+1
 sta hp_a+1
 lda hp_fraction
 sta hp_b
 lda #0
 sta hp_b+1
 jsr hp_q8
 clc
 lda hp_r
 adc hp_base
 sta hp_r
 lda hp_r+1
 adc hp_base+1
 sta hp_r+1
 rts

tq_full_projection:
 lda hc_sign
 ldx hc_axis
 beq tq_full_sign
 eor #128
tq_full_sign:
 cmp #128
 bcc tq_full_positive
 sec
 lda #0
 sbc hc_num+0
 sta tq_full+0
 lda #0
 sbc hc_num+1
 sta tq_full+1
 lda #0
 sbc hc_num+2
 sta tq_full+2
 jmp tq_full_center
tq_full_positive:
 lda hc_num+0
 sta tq_full+0
 lda hc_num+1
 sta tq_full+1
 lda hc_num+2
 sta tq_full+2
tq_full_center:
 ldx hc_axis
 clc
 lda tq_full+1
 adc hc_centers,x
 sta tq_full+1
 lda tq_full+2
 adc #0
 sta tq_full+2
 rts
hp_prepare_matrix:
hp_prepare_trig:
hp_prepare_terms:
qc_trig_z:
qc_trig_y:
 rts
hp_origins:
 lda explorer_cam_x_ext
 clc
 adc #16
 cmp #32
 bcs qc_origin_fail
 lda explorer_cam_y_ext
 clc
 adc #16
 cmp #32
 bcs qc_origin_fail
 lda explorer_cam_z_ext
 clc
 adc #16
 cmp #32
 bcs qc_origin_fail
 jmp hp_origin_supported
qc_origin_fail:
 clc
 rts
hp_origin_supported:
 ldx objidx
 lda object_pos_x_hi,x
 asl
 lda #0
 sbc #0
 eor #$ff
 sta hc_ext
 sec
 lda object_pos_x_lo,x
 sbc explorer_cam_x_lo
 sta hc_origin_x+0
 lda object_pos_x_hi,x
 sbc explorer_cam_x_hi
 sta hc_origin_x+1
 lda hc_ext
 sbc explorer_cam_x_ext
 sta hc_origin_x+2
 lda object_pos_y_hi,x
 asl
 lda #0
 sbc #0
 eor #$ff
 sta hc_ext
 sec
 lda object_pos_y_lo,x
 sbc explorer_cam_y_lo
 sta hc_origin_y+0
 lda object_pos_y_hi,x
 sbc explorer_cam_y_hi
 sta hc_origin_y+1
 lda hc_ext
 sbc explorer_cam_y_ext
 sta hc_origin_y+2
 lda object_pos_z_ext,x
 sta hc_ext
 sec
 lda object_pos_z_lo,x
 sbc explorer_cam_z_lo
 sta hc_origin_z+0
 lda object_pos_z_hi,x
 sbc explorer_cam_z_hi
 sta hc_origin_z+1
 lda hc_ext
 sbc explorer_cam_z_ext
 sta hc_origin_z+2
 sec
 rts
hp_build_vertices:
 lda active_vfirst
 sta hp_idx
hc_vertex_loop:
 ldy hp_idx
 ldx vert_xi,y
 lda xcoord,x
 asl
 lda #0
 sbc #0
 eor #255
 sta hc_ext
 lda hc_origin_x
 sta hc_cam_x0,y
 clc
 lda hc_origin_x+1
 adc xcoord,x
 sta hc_cam_x1,y
 sta rxbuf,y
 sta vxrawlo,y
 lda hc_origin_x+2
 adc hc_ext
 sta hc_cam_x2,y
 sta vxrawhi,y
 ldx vert_yi,y
 lda ycoord,x
 asl
 lda #0
 sbc #0
 eor #255
 sta hc_ext
 lda hc_origin_y
 sta hc_cam_y0,y
 clc
 lda hc_origin_y+1
 adc ycoord,x
 sta hc_cam_y1,y
 sta rybuf,y
 sta vyrawlo,y
 lda hc_origin_y+2
 adc hc_ext
 sta hc_cam_y2,y
 sta vyrawhi,y
 ldx vert_zi,y
 lda zcoord,x
 asl
 lda #0
 sbc #0
 eor #255
 sta hc_ext
 lda hc_origin_z
 sta hc_cam_z0,y
 clc
 lda hc_origin_z+1
 adc zcoord,x
 sta hc_cam_z1,y
 sta sz,y
 sta vzrawlo,y
 lda hc_origin_z+2
 adc hc_ext
 sta hc_cam_z2,y
 sta vzrawhi,y
 sta szhi,y
 inc hp_idx
 lda hp_idx
 cmp active_vend
 bne hc_vertex_loop
 rts
pc_prepare:
 lda #255
 sta pc_remote
 ldx #0
 lda explorer_cam_z_hi
 bmi pc_set_plane
 cmp #22
 bcc pc_set_plane
 cmp #26
 bcc pc_prepare_done
 ldx #4
pc_set_plane:
 lda #159
 sta pc_left
 lda #0
 sta pc_right
pc_portal_loop:
 ldy pc_vertices,x
 lda projdone,y
 beq pc_prepare_done
 lda sx,y
 cmp pc_left
 bcs pc_not_left
 sta pc_left
pc_not_left:
 cmp pc_right
 bcc pc_not_right
 sta pc_right
pc_not_right:
 inx
 txa
 and #3
 bne pc_portal_loop
 ; Clamped monotonic coordinates plus two-pixel conservative expansion.
 lda pc_left
 sec
 sbc #2
 bcs pc_left_ready
 lda #0
pc_left_ready:
 sta pc_left
 lda pc_right
 clc
 adc #2
 cmp #160
 bcc pc_right_ready
 lda #159
pc_right_ready:
 sta pc_right
 txa
 lsr
 lsr
 and #1
 sta pc_remote
pc_prepare_done:
 rts
pc_visible:
 lda objidx
 cmp pc_remote
 bne pc_accept
 lda faceidx
 cmp #18
 bcc pc_regular
 cmp #26
 bcc pc_accept
pc_regular:
 ldx faceidx
 lda #3
 sta pc_mask
 sta pc_count
pc_face_loop:
 ; Builder proves face0/1/2 are consecutive 64-byte topology tables.
 ldy face0,x
 lda projdone,y
 beq pc_accept
 lda sx,y
 cmp pc_left
 bcc pc_left_outside
 lda pc_mask
 and #2
 sta pc_mask
pc_left_outside:
 lda sx,y
 cmp pc_right
 beq pc_right_inside
 bcs pc_right_outside
pc_right_inside:
 lda pc_mask
 and #1
 sta pc_mask
pc_right_outside:
 txa
 clc
 adc #64
 tax
 dec pc_count
 bne pc_face_loop
 lda pc_mask
 bne pc_reject
pc_accept:
 sec
 rts
pc_reject:
 clc
 rts
pc_vertices: .byte 9,8,11,10,14,13,15,16
pc_remote: .byte 255
pc_left: .byte 0
pc_right: .byte 0
pc_mask: .byte 0
pc_count: .byte 0
.if face1-face0 != 64 || face2-face1 != 64
 .error "Portal selector topology stride changed"
.endif
hp_block_core_end:
.if * > $56ad
 .error "Q8 allocation overflow: core"
.endif

; Q8 block data
* = $c1de
hp_block_data_begin:
hp_a: .word 0
hp_b: .word 0
hp_r: .word 0
hp_base: .word 0
hp_fraction: .byte 0
hp_sine_index: .byte 0
hp_sign: .byte 0
hp_idx: .byte 0
hp_used: .byte 0
hp_p: .fill 4,0
hp_shift: .fill 4,0

hp_fault: .byte 0
cw_area: .fill 3,0
cw_prev: .byte 0
cw_cur: .byte 0
hc_origin_x: .fill 3,0
hc_origin_y: .fill 3,0
hc_origin_z: .fill 3,0
hc_ext: .fill 1,0
hc_coord: .fill 3,0
hc_depth: .fill 3,0
hc_num: .fill 6,0
hc_shift: .fill 6,0
hc_divisor: .fill 3,0
hc_remainder: .fill 4,0
hc_sign: .fill 1,0
hc_axis: .fill 1,0
hc_q: .fill 2,0
hc_integer: .fill 2,0
hc_value: .fill 3,0
hc_base: .fill 3,0
hc_factor: .fill 3,0
hc_den: .fill 3,0
hc_delta: .fill 3,0
hc_result: .fill 3,0
hc_previous: .fill 1,0
hc_current: .fill 1,0
hc_prev_inside: .fill 1,0
hc_cur_inside: .fill 1,0
hc_from: .fill 1,0
hc_to: .fill 1,0
hc_from_vertex: .fill 1,0
hc_to_vertex: .fill 1,0
hc_count: .fill 1,0
hc_out_count: .fill 1,0
hc_plane: .fill 1,0
hc_bound: .fill 3,0
hc_changed: .fill 1,0
hc_source_count: .fill 1,0
hc_face_vertices: .fill 4,0
hc_out_x: .fill 3,0
hc_out_y: .fill 3,0
hc_out_s: .fill 2,0
hc_poly_index: .fill 1,0
hc_cam_x0: .fill VERT_COUNT,0
hc_cam_x1: .fill VERT_COUNT,0
hc_cam_x2: .fill VERT_COUNT,0
hc_cam_y0: .fill VERT_COUNT,0
hc_cam_y1: .fill VERT_COUNT,0
hc_cam_y2: .fill VERT_COUNT,0
hc_cam_z0: .fill VERT_COUNT,0
hc_cam_z1: .fill VERT_COUNT,0
hc_cam_z2: .fill VERT_COUNT,0
hc_a_xlo: .fill 12,0
hc_a_xhi: .fill 12,0
hc_a_xext: .fill 12,0
hc_a_ylo: .fill 12,0
hc_a_yhi: .fill 12,0
hc_a_yext: .fill 12,0
hc_a_slo: .fill 12,0
hc_a_shi: .fill 12,0
hc_b_xlo: .fill 12,0
hc_b_xhi: .fill 12,0
hc_b_xext: .fill 12,0
hc_b_ylo: .fill 12,0
hc_b_yhi: .fill 12,0
hc_b_yext: .fill 12,0
hc_b_slo: .fill 12,0
hc_b_shi: .fill 12,0
hq_residue: .byte 0
hq_projected: .fill 3,0
tq_cache_x0: .fill VERT_COUNT,0
tq_cache_x1: .fill VERT_COUNT,0
tq_cache_x2: .fill VERT_COUNT,0
tq_cache_y0: .fill VERT_COUNT,0
tq_cache_y1: .fill VERT_COUNT,0
tq_cache_y2: .fill VERT_COUNT,0
tq_full: .fill 3,0
hc_a_vlo: .fill 12,0
hc_a_vhi: .fill 12,0
hc_b_vlo: .fill 12,0
hc_b_vhi: .fill 12,0
hc_out_v: .word 0
hc_a_qlo: .fill 12,0
hc_a_qhi: .fill 12,0
hc_b_qlo: .fill 12,0
hc_b_qhi: .fill 12,0
hc_out_q: .word 0
sxq2_lo: .fill VERT_COUNT,0
sxq2_hi: .fill VERT_COUNT,0
tq_closed: .fill VIEWPORT_ROW_CAPACITY,0
tq_edge: .byte 0
tq_from: .byte 0
tq_to: .byte 0
tq_row: .byte 0
tq_end: .byte 0
tq_pre: .byte 0
tq_work: .byte 0
tq_cap: .byte 0
tq_ch: .byte 0
tq_dy: .word 0
tq_start: .fill 3,0
tq_delta: .fill 3,0
tq_cur0: .fill 5,0
tq_cur1: .fill 5,0
tq_cur2: .fill 5,0
tq_step0: .fill 5,0
tq_step1: .fill 5,0
tq_step2: .fill 5,0
tq_err0: .fill 5,0
tq_err1: .fill 5,0
tq_rem0: .fill 5,0
tq_rem1: .fill 5,0
qc_a: .fill 3,0
qc_b: .fill 2,0
qc_r: .fill 3,0
qc_m: .fill 4,0
qc_prod: .fill 4,0
qc_sign: .fill 1,0
qc_index: .fill 1,0
qc_ys: .fill 2,0
qc_yc: .fill 2,0
qc_ps: .fill 2,0
qc_pc: .fill 2,0
qc_x: .fill 3,0
qc_y: .fill 3,0
qc_z: .fill 3,0
qc_tx: .fill 3,0
qc_ty: .fill 3,0
qc_t0: .fill 3,0
qc_t1: .fill 3,0
hc_a_wlo: .fill 12,0
hc_a_whi: .fill 12,0
hc_b_wlo: .fill 12,0
hc_b_whi: .fill 12,0
hc_out_w: .word 0
ps_lefts_lo = leftshade
ps_leftv_lo = m7_leftv
ps_lefts_hi: .fill VIEWPORT_ROW_CAPACITY,0
ps_leftv_hi: .fill VIEWPORT_ROW_CAPACITY,0
ps_leftw_lo: .fill VIEWPORT_ROW_CAPACITY,0
ps_leftw_hi: .fill VIEWPORT_ROW_CAPACITY,0
ps_rights_lo = rightshade
ps_rightv_lo = m7_rightv
ps_rights_hi: .fill VIEWPORT_ROW_CAPACITY,0
ps_rightv_hi: .fill VIEWPORT_ROW_CAPACITY,0
ps_rightw_lo: .fill VIEWPORT_ROW_CAPACITY,0
ps_rightw_hi: .fill VIEWPORT_ROW_CAPACITY,0
ps_fault: .byte 0
ps_saved_x: .byte 0
ps_a: .fill 2,0
ps_b: .fill 2,0
ps_bits: .fill 2,0
ps_prod: .fill 4,0
ps_shift: .fill 4,0
ps_num: .fill 3,0
ps_den: .fill 2,0
ps_remainder: .fill 2,0
ps_cur0: .fill 3,0
ps_cur1: .fill 3,0
ps_step0: .fill 3,0
ps_step1: .fill 3,0
ps_rem: .fill 3,0
ps_err: .fill 3,0
bk_count: .byte 0
bk_ready: .byte 0
bk_saved_x: .byte 0
bk_cur0: .fill 2,0
bk_cur1: .fill 2,0
bk_next: .fill 2,0
bk_step0: .fill 2,0
bk_step1: .fill 2,0
bk_look0: .fill 3,0
bk_look1: .fill 3,0
bk_delta: .fill 2,0
bk_future: .fill 2,0
ca_lookerr: .fill 3,0
up_inputlo = ps_prod
up_inputhi = ps_prod+2
up_remlo = ps_shift
up_remhi = ps_shift+2
.if m7_v != m7_u+1
 .error "Paired UV output must be contiguous"
.endif
rc_next: .byte 0
rc_slot: .byte 255
rc_keylo: .fill 8,0
rc_keyhi: .fill 8,0
rc_wlo: .fill 8,0
rc_whi: .fill 8,0
hp_block_data_end:
.if * > $cb17
 .error "Q8 allocation overflow: data"
.endif

; Q8 block tables
* = $e000
hp_block_tables_begin:
hp_sin_lo:
 .byte 0,6,13,19,25,31,38,44,50,56,62,68,74,80,86,92,98,104,109,115,121,126,132,137,142,147,152,157,162,167,172,177,181,185,190,194,198,202,206,209,213,216,220,223,226,229,231,234,237,239,241,243,245,247,248,250,251,252,253,254,255,255,0,0,0,0,0,255,255,254,253,252,251,250,248,247,245,243,241,239,237,234,231,229,226,223,220,216,213,209,206,202,198,194,190,185,181,177,172,167,162,157,152,147,142,137,132,126,121,115,109,104,98,92,86,80,74,68,62,56,50,44,38,31,25,19,13,6,0,250,243,237,231,225,218,212,206,200,194,188,182,176,170,164,158,152,147,141,135,130,124,119,114,109,104,99,94,89,84,79,75,71,66,62,58,54,50,47,43,40,36,33,30,27,25,22,19,17,15,13,11,9,8,6,5,4,3,2,1,1,0,0,0,0,0,1,1,2,3,4,5,6,8,9,11,13,15,17,19,22,25,27,30,33,36,40,43,47,50,54,58,62,66,71,75,79,84,89,94,99,104,109,114,119,124,130,135,141,147,152,158,164,170,176,182,188,194,200,206,212,218,225,231,237,243,250
hp_sin_hi:
 .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
hp_block_tables_end:
.if * > $e200
 .error "Q8 allocation overflow: tables"
.endif

; Q8 block projection
* = $18ec
hp_block_projection_begin:
; Camera Q16.8 -> screen Q16.8; retain exact Q2 + signed residual caches.
hc_project_vertices:
 lda active_vfirst
 sta hp_idx
hc_pv_loop:
 ldx hp_idx
 jsr hc_load_vertex_point
 jsr hc_depth_inside
 lda #0
 rol
 ldx hp_idx
 sta projdone,x
 cmp #0
 beq hc_pv_behind
 lda hc_cam_x0,x
 sta hc_coord
 lda hc_cam_x1,x
 sta hc_coord+1
 lda hc_cam_x2,x
 sta hc_coord+2
 lda #0
 sta hc_axis
 jsr hc_project_axis
 ldy hp_idx
 lda tq_full+0
 sta tq_cache_x0,y
 lda tq_full+1
 sta tq_cache_x1,y
 lda tq_full+2
 sta tq_cache_x2,y
 lda hc_q
 sta sxq2_lo,y
 lda hc_q+1
 sta sxq2_hi,y
 lda hq_residue
 lda hc_integer
 sta pxrawlo,y
 lda hc_integer+1
 sta pxrawhi,y
 jsr hc_clamp_integer
 ldy hp_idx
 sta sx,y
 ldx hp_idx
 lda hc_cam_y0,x
 sta hc_coord
 lda hc_cam_y1,x
 sta hc_coord+1
 lda hc_cam_y2,x
 sta hc_coord+2
 lda #1
 sta hc_axis
 jsr hc_project_axis
 ldy hp_idx
 lda tq_full+0
 sta tq_cache_y0,y
 lda tq_full+1
 sta tq_cache_y1,y
 lda tq_full+2
 sta tq_cache_y2,y
 lda hc_q
 sta syq2_lo,y
 lda hc_q+1
 sta syq2_hi,y
 lda hq_residue
 lda hc_integer
 sta pyrawlo,y
 lda hc_integer+1
 sta pyrawhi,y
 jsr hc_clamp_integer
 ldy hp_idx
 sta sy,y
 jmp hc_pv_next
hc_pv_behind:
 ; These are never consumed by Q8 near clipping; clear stale screen caches.
 lda #0
 sta sx,x
 sta sy,x
 sta sxq2_lo,x
 sta sxq2_hi,x
 sta syq2_lo,x
 sta syq2_hi,x
hc_pv_next:
 inc hp_idx
 lda hp_idx
 cmp active_vend
 bne hc_pv_loop
 rts
hc_depth_inside:
 lda hc_depth+2
 bmi hc_depth_no
 bne hc_depth_yes
 lda hc_depth+1
 cmp #CAMERA_FACE_MIN_DEPTH
 rts
hc_depth_yes:
 sec
 rts
hc_depth_no:
 clc
 rts

; |signed24 coordinate| * (85*256) => unsigned48 / positive24 depth.
hc_project_axis:
 lda hc_coord+2
 sta hc_sign
 bpl hc_coord_abs
 sec
 lda #0
 sbc hc_coord
 sta hc_coord
 lda #0
 sbc hc_coord+1
 sta hc_coord+1
 lda #0
 sbc hc_coord+2
 sta hc_coord+2
hc_coord_abs:
 ldx #5
 lda #0
hc_num_clear:
 sta hc_num,x
 sta hc_shift,x
 dex
 bpl hc_num_clear
 ldx #2
hc_copy_coord:
 lda hc_coord,x
 sta hc_shift,x
 lda hc_depth,x
 sta hc_divisor,x
 dex
 bpl hc_copy_coord
 ; Constant multiply, preserving eight fractional bits through screen clipping.
 lda #<21760
 sta hc_value
 lda #>21760
 sta hc_value+1
hc_project_mul_loop:
 lsr hc_value+1
 ror hc_value
 bcc hc_project_mul_shift
 clc
 lda hc_num
 adc hc_shift
 sta hc_num
 lda hc_num+1
 adc hc_shift+1
 sta hc_num+1
 lda hc_num+2
 adc hc_shift+2
 sta hc_num+2
 lda hc_num+3
 adc hc_shift+3
 sta hc_num+3
 lda hc_num+4
 adc hc_shift+4
 sta hc_num+4
 lda hc_num+5
 adc hc_shift+5
 sta hc_num+5
hc_project_mul_shift:
 asl hc_shift
 rol hc_shift+1
 rol hc_shift+2
 rol hc_shift+3
 rol hc_shift+4
 rol hc_shift+5
 lda hc_value
 ora hc_value+1
 bne hc_project_mul_loop
 jsr hc_div40
 jsr tq_full_projection
 lda hc_num
 and #63
 sta hq_residue
 ldx #6
hq_projection_to_q2:
 lsr hc_num+5
 ror hc_num+4
 ror hc_num+3
 ror hc_num+2
 ror hc_num+1
 ror hc_num
 dex
 bne hq_projection_to_q2
 ; Saturate only remote, wholly offscreen projected points. Small mesh diameter
 ; guarantees contributing front vertices fit this range; tests check this.
 lda hc_num+4
 ora hc_num+5
 ora hc_num+3
 ora hc_num+2
 bne hc_q_saturate
 lda hc_num+1
 cmp #$3e
 bcc hc_q_magnitude
hc_q_saturate:
 lda #0
 sta hq_residue
 lda #$3d
 sta hc_num+1
 lda #$ff
 sta hc_num
hc_q_magnitude:
 lda hc_axis
 beq hc_q_sign
 lda hc_sign
 eor #$80
 sta hc_sign
hc_q_sign:
 lda hc_num
 sta hc_q
 lda hc_num+1
 sta hc_q+1
 lda hc_sign
 bpl hc_q_center
 sec
 lda #0
 sbc hq_residue
 sta hq_residue
 sec
 lda #0
 sbc hc_q
 sta hc_q
 lda #0
 sbc hc_q+1
 sta hc_q+1
hc_q_center:
 ldx hc_axis
 clc
 lda hc_q
 adc hc_center_lo,x
 sta hc_q
 lda hc_q+1
 adc hc_center_hi,x
 sta hc_q+1
 ; Keep approved integer anchors: center + trunc(signed offset/4).
 lsr hc_num+1
 ror hc_num
 lsr hc_num+1
 ror hc_num
 lda hc_sign
 bpl hc_integer_center
 sec
 lda #0
 sbc hc_num
 sta hc_num
 lda #0
 sbc hc_num+1
 sta hc_num+1
hc_integer_center:
 clc
 lda hc_num
 adc hc_centers,x
 sta hc_integer
 lda hc_num+1
 adc #0
 sta hc_integer+1
 rts
hc_centers: .byte PROJ_CENTER_X,PROJ_CENTER_Y
hc_center_lo: .byte <(PROJ_CENTER_X*4),<(PROJ_CENTER_Y*4)
hc_center_hi: .byte >(PROJ_CENTER_X*4),>(PROJ_CENTER_Y*4)
hc_limits: .byte PROJ_SCREEN_MAX_X,PROJ_SCREEN_MAX_Y
hc_clamp_integer:
 lda hc_integer+1
 bmi hc_integer_zero
 bne hc_integer_limit
 ldx hc_axis
 lda hc_integer
 cmp hc_limits,x
 bcc hc_integer_done
hc_integer_limit:
 ldx hc_axis
 lda hc_limits,x
 rts
hc_integer_zero:
 lda #0
hc_integer_done:
 rts

; Restoring unsigned 48/24 (historical ABI name retained).
; Remainder needs 25 bits: keep fourth byte. All callers initialize all 6 bytes.
; trunc(delta_s16 * factor_u15 / den_u15), 0 <= factor <= denominator.
hc_ratio_product:
 lda hc_delta
 sta hp_a
 lda hc_delta+1
 sta hp_a+1
 lda hc_factor
 sta hp_b
 lda hc_factor+1
 sta hp_b+1
 jsr hp_mul
 ldx #3
hc_ratio_num:
 lda hp_p,x
 sta hc_num,x
 dex
 bpl hc_ratio_num
 lda #0
 sta hc_num+4
 sta hc_num+5
 sta hc_divisor+2
 lda hc_den
 sta hc_divisor
 lda hc_den+1
 sta hc_divisor+1
 jsr hc_div40
 lda hc_num
 sta hc_result
 lda hc_num+1
 sta hc_result+1
 lda hp_sign
 bpl hc_ratio_done
 sec
 lda #0
 sbc hc_result
 sta hc_result
 lda #0
 sbc hc_result+1
 sta hc_result+1
hc_ratio_done:
 rts
; Convex source triangle/quad -> near Q8 intersection -> screen Q8 clip -> Q2.
; Fractional shade carried as Q8 through all intersections (0..32).
load_face_y:
 sty sortj
.if MODE7_UV_CARRIER != 0
 jsr gouraud_load_face_raw_shades_y
.endif
 ldy sortj
 lda face0,y
 sta hc_face_vertices
 lda face1,y
 sta hc_face_vertices+1
 lda face2,y
 sta hc_face_vertices+2
 lda face3,y
 sta hc_face_vertices+3
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
.else
 lda #4
.endif
 sta hc_source_count
 sta loaded_face_vertex_count
 sec
 sbc #1
 sta hc_previous
 lda #0
 sta hc_current
 sta hc_count
 sta hc_changed
 sta clip_poly_active
 lda hp_fault
 bne hc_face_empty
hc_near_loop:
 ldx hc_previous
 lda hc_face_vertices,x
 tax
 lda projdone,x
 sta hc_prev_inside
 ldx hc_current
 lda hc_face_vertices,x
 tax
 lda projdone,x
 sta hc_cur_inside
 cmp hc_prev_inside
 beq hc_near_no_cross
 lda #1
 sta hc_changed
 jsr hc_near_intersection
 jsr hc_append_a
hc_near_no_cross:
 lda hc_cur_inside
 beq hc_near_outside
 ldx hc_current
.if MODE7_UV_CARRIER != 0
 lda gouraud_vshade0,x
.else
 lda #0
.endif
 sta hc_out_s+1
 lda #0
 sta hc_out_s
 lda m7_v0,x
 sta hc_out_v+1
 lda #0
 sta hc_out_v
 lda m3_q0,x
 sta hc_out_q+1
 lda #0
 sta hc_out_q
 lda hc_face_vertices,x
 tax
 lda hc_cam_z0,x
 sta hc_depth+0
 lda hc_cam_z1,x
 sta hc_depth+1
 lda hc_cam_z2,x
 sta hc_depth+2
 lda tq_cache_x0,x
 sta hc_out_x+0
 lda tq_cache_x1,x
 sta hc_out_x+1
 lda tq_cache_x2,x
 sta hc_out_x+2
 ldx hc_current
 lda hc_face_vertices,x
 tax
 lda tq_cache_y0,x
 sta hc_out_y+0
 lda tq_cache_y1,x
 sta hc_out_y+1
 lda tq_cache_y2,x
 sta hc_out_y+2
 jsr hc_append_a
 jmp hc_near_next
hc_near_outside:
 lda #1
 sta hc_changed
hc_near_next:
 lda hc_current
 sta hc_previous
 inc hc_current
 lda hc_current
 cmp hc_source_count
 bne hc_near_loop
 lda hc_count
 cmp #3
 bcc hc_face_empty
 lda #0
 sta hc_plane
hc_screen_plane:
 jsr hc_screen_pass
 lda hc_count
 cmp #3
 bcc hc_face_empty
 inc hc_plane
 lda hc_plane
 cmp #4
 bne hc_screen_plane
 jsr hq_quantize_poly
 jsr hc_commit_poly
 ; Clipped Q2 shoelace sign is perspective-correct; old camera-XY cull is not.
 jsr hc_winding_visible
 bcc hc_face_empty
 lda hc_changed
 sta clip_poly_active
 bne hc_face_ready
 jsr hc_load_fast_face
 jmp screen_face_drawable
hc_face_ready:
 ; Span metadata remains required by sliver rejection/material setup.
 lda clip_a_x
 sta spanw
 sta p1lo
 lda clip_a_y
 sta spanh
 sta p1hi
 ldx #1
hc_meta_loop:
 lda clip_a_x,x
 cmp spanw
 bcc hc_meta_xmax
 sta spanw
hc_meta_xmax:
 cmp p1lo
 bcs hc_meta_y
 sta p1lo
hc_meta_y:
 lda clip_a_y,x
 cmp spanh
 bcc hc_meta_ymax
 sta spanh
hc_meta_ymax:
 cmp p1hi
 bcs hc_meta_next
 sta p1hi
hc_meta_next:
 inx
 cpx clip_a_count
 bne hc_meta_loop
 sec
 lda spanw
 sbc p1lo
 sta spanw
 sec
 lda spanh
 sbc p1hi
 sta spanh
 sec
 rts
hc_face_empty:
 lda #0
 sta hc_count
 sta clip_a_count
 lda #1
 sta clip_poly_active
 clc
 rts

hc_near_intersection:
 ldx hc_previous
 ldy hc_current
 lda hc_prev_inside
 beq hc_near_canonical
 ldx hc_current
 ldy hc_previous
hc_near_canonical:
 stx hc_from
 sty hc_to
 lda hc_face_vertices,x
 sta hc_from_vertex
 lda hc_face_vertices,y
 sta hc_to_vertex
 tax
 ldy hc_from_vertex
 sec
 lda hc_cam_z0,x
 sbc hc_cam_z0,y
 sta hc_den
 lda hc_cam_z1,x
 sbc hc_cam_z1,y
 sta hc_den+1
 sec
 lda #0
 sbc hc_cam_z0,y
 sta hc_factor
 lda #CAMERA_FACE_MIN_DEPTH
 sbc hc_cam_z1,y
 sta hc_factor+1
 lda #0
 sta hc_depth
 sta hc_depth+2
 lda #CAMERA_FACE_MIN_DEPTH
 sta hc_depth+1
 jsr hc_near_x
 jsr hc_near_y
 lda #0
 sta hc_den+2
 sta hc_factor+2
 ldx hc_to
 ldy hc_from
 lda #0
 sta hc_delta
 sec
 lda gouraud_vshade0,x
 sbc gouraud_vshade0,y
 sta hc_delta+1
 lda #0
 sbc #0
 sta hc_delta+2
 jsr hq_ratio_product
 lda hc_result
 sta hc_out_s
 ldy hc_from
 clc
 lda hc_result+1
 adc gouraud_vshade0,y
 sta hc_out_s+1
 ldx hc_to
 ldy hc_from
 lda #0
 sta hc_delta
 sec
 lda m7_v0,x
 sbc m7_v0,y
 sta hc_delta+1
 lda #0
 sbc #0
 sta hc_delta+2
 jsr hq_ratio_product
 lda hc_result
 sta hc_out_v
 ldy hc_from
 clc
 lda hc_result+1
 adc m7_v0,y
 sta hc_out_v+1
 ldx hc_to
 ldy hc_from
 lda #0
 sta hc_delta
 sec
 lda m3_q0,x
 sbc m3_q0,y
 sta hc_delta+1
 lda #0
 sbc #0
 sta hc_delta+2
 jsr hq_ratio_product
 lda hc_result
 sta hc_out_q
 ldy hc_from
 clc
 lda hc_result+1
 adc m3_q0,y
 sta hc_out_q+1

 rts

hp_block_projection_end:
.if * > $1e60
 .error "Q8 allocation overflow: projection"
.endif

; Q8 block screen_precision
* = $595c
hp_block_screen_precision_begin:
; Q2 + signed residual [-63,63] -> exact signed Q16.8 screen value.
hq_expand_q:
 lda hc_q
 sta hq_projected
 lda hc_q+1
 sta hq_projected+1
 asl
 lda #0
 sbc #0
 eor #$ff
 sta hq_projected+2
 ldx #6
hq_expand_shift:
 asl hq_projected
 rol hq_projected+1
 rol hq_projected+2
 dex
 bne hq_expand_shift
 ldy #0
 lda hq_residue
 bpl hq_residue_positive
 dey
hq_residue_positive:
 clc
 adc hq_projected
 sta hq_projected
 tya
 adc hq_projected+1
 sta hq_projected+1
 tya
 adc hq_projected+2
 sta hq_projected+2
 rts

; Signed24 delta * unsigned24 factor / unsigned24 denominator, exact trunc0.
; hc_value is a private destructive multiplier; no caller needs its old value.
hq_quantize_poly:
 ldx #0
hq_quantize_loop:
 lda hc_a_xhi,x
 cmp #PROJ_CENTER_X
 bcs hq_quantize_x_shift
 clc
 lda hc_a_xlo,x
 adc #63
 sta hc_a_xlo,x
 lda hc_a_xhi,x
 adc #0
 sta hc_a_xhi,x
hq_quantize_x_shift:
 lsr hc_a_xhi,x
 ror hc_a_xlo,x
 lsr hc_a_xhi,x
 ror hc_a_xlo,x
 lsr hc_a_xhi,x
 ror hc_a_xlo,x
 lsr hc_a_xhi,x
 ror hc_a_xlo,x
 lsr hc_a_xhi,x
 ror hc_a_xlo,x
 lsr hc_a_xhi,x
 ror hc_a_xlo,x
 lda hc_a_yhi,x
 cmp #PROJ_CENTER_Y
 bcs hq_quantize_y_shift
 clc
 lda hc_a_ylo,x
 adc #63
 sta hc_a_ylo,x
 lda hc_a_yhi,x
 adc #0
 sta hc_a_yhi,x
hq_quantize_y_shift:
 lsr hc_a_yhi,x
 ror hc_a_ylo,x
 lsr hc_a_yhi,x
 ror hc_a_ylo,x
 lsr hc_a_yhi,x
 ror hc_a_ylo,x
 lsr hc_a_yhi,x
 ror hc_a_ylo,x
 lsr hc_a_yhi,x
 ror hc_a_ylo,x
 lsr hc_a_yhi,x
 ror hc_a_ylo,x
 inx
 cpx hc_count
 bne hq_quantize_loop
 rts
; Exact signed 24-bit shoelace sum on viewport-clipped Q2 coordinates.
; x in 0..636, y in 0..396, at most 12 vertices: sum cannot overflow s24.
; C=1 only for positive screen winding. Degenerate zero-area faces are empty.
; Scratch hc_num/hc_shift/hc_value is private, not used by SID IRQ.
hc_winding_visible:
 lda #0
 sta cw_area
 sta cw_area+1
 sta cw_area+2
 sta cw_cur
 ldx hc_count
 dex
 stx cw_prev
cw_loop:
 ldx cw_prev
 ldy cw_cur
 jsr cw_load_product
 jsr cw_multiply
 clc
 lda cw_area
 adc hc_num
 sta cw_area
 lda cw_area+1
 adc hc_num+1
 sta cw_area+1
 lda cw_area+2
 adc hc_num+2
 sta cw_area+2
 ldx cw_cur
 ldy cw_prev
 jsr cw_load_product
 jsr cw_multiply
 sec
 lda cw_area
 sbc hc_num
 sta cw_area
 lda cw_area+1
 sbc hc_num+1
 sta cw_area+1
 lda cw_area+2
 sbc hc_num+2
 sta cw_area+2
 lda cw_cur
 sta cw_prev
 inc cw_cur
 lda cw_cur
 cmp hc_count
 bne cw_loop
 lda cw_area+2
 bmi cw_hidden
 ora cw_area+1
 ora cw_area
 cmp #1
 rts
cw_hidden:
 clc
 rts
cw_load_product:
 lda hc_a_xlo,x
 sta hc_shift
 lda hc_a_xhi,x
 sta hc_shift+1
 lda #0
 sta hc_shift+2
 sta hc_num
 sta hc_num+1
 sta hc_num+2
 lda hc_a_ylo,y
 sta hc_value
 lda hc_a_yhi,y
 sta hc_value+1
 rts
cw_multiply:
 lsr hc_value+1
 ror hc_value
 bcc cw_shift
 clc
 lda hc_num
 adc hc_shift
 sta hc_num
 lda hc_num+1
 adc hc_shift+1
 sta hc_num+1
 lda hc_num+2
 adc hc_shift+2
 sta hc_num+2
cw_shift:
 asl hc_shift
 rol hc_shift+1
 rol hc_shift+2
 lda hc_value
 ora hc_value+1
 bne cw_multiply
 rts
ps_advance:
 lda bk_count
 bne ca_block
 jmp bk_exact_advance ; short tail: original carrier/Q/X advancement
ca_block:
 dec bk_count
 bne ca_shade
 stx ps_saved_x
 ldx #2
ca_commit:
 lda bk_look0,x
 sta ps_cur0,x
 lda bk_look1,x
 sta ps_cur1,x
 lda ca_lookerr,x
 sta ps_err,x
 dex
 bpl ca_commit
 ldx ps_saved_x
ca_shade:
 jsr m3_advance_q ; shade still advances at every logical pixel
 inc gouraud_scan_x
 clc
 lda bk_cur0+0
 adc bk_step0+0
 sta bk_cur0+0
 lda bk_cur1+0
 adc bk_step1+0
 sta bk_cur1+0
 clc
 lda bk_cur0+1
 adc bk_step0+1
 sta bk_cur0+1
 lda bk_cur1+1
 adc bk_step1+1
 sta bk_cur1+1
 rts
hp_block_screen_precision_end:
.if * > $5b61
 .error "Q8 allocation overflow: screen_precision"
.endif

; Q8 block clip_helpers
* = $9938
hp_block_clip_helpers_begin:
hc_load_vertex_point:
 lda hc_cam_z0,x
 sta hc_depth+0
 lda hc_cam_z1,x
 sta hc_depth+1
 lda hc_cam_z2,x
 sta hc_depth+2
 rts
hc_copy_a_to_out:
 lda hc_a_xlo,x
 sta hc_out_x+0
 lda hc_a_xhi,x
 sta hc_out_x+1
 lda hc_a_xext,x
 sta hc_out_x+2
 lda hc_a_ylo,x
 sta hc_out_y+0
 lda hc_a_yhi,x
 sta hc_out_y+1
 lda hc_a_yext,x
 sta hc_out_y+2
 lda hc_a_vlo,x
 sta hc_out_v+0
 lda hc_a_vhi,x
 sta hc_out_v+1
 lda hc_a_qlo,x
 sta hc_out_q+0
 lda hc_a_qhi,x
 sta hc_out_q+1
 lda hc_a_wlo,x
 sta hc_out_w+0
 lda hc_a_whi,x
 sta hc_out_w+1
 lda hc_a_slo,x
 sta hc_out_s+0
 lda hc_a_shi,x
 sta hc_out_s+1
 rts
hc_copy_b_to_out:
 lda hc_b_xlo,x
 sta hc_out_x+0
 lda hc_b_xhi,x
 sta hc_out_x+1
 lda hc_b_xext,x
 sta hc_out_x+2
 lda hc_b_ylo,x
 sta hc_out_y+0
 lda hc_b_yhi,x
 sta hc_out_y+1
 lda hc_b_yext,x
 sta hc_out_y+2
 lda hc_b_vlo,x
 sta hc_out_v+0
 lda hc_b_vhi,x
 sta hc_out_v+1
 lda hc_b_qlo,x
 sta hc_out_q+0
 lda hc_b_qhi,x
 sta hc_out_q+1
 lda hc_b_wlo,x
 sta hc_out_w+0
 lda hc_b_whi,x
 sta hc_out_w+1
 lda hc_b_slo,x
 sta hc_out_s+0
 lda hc_b_shi,x
 sta hc_out_s+1
 rts
hc_append_a:
 jsr ps_encode
 ldy hc_count
 cpy #12
 bcs hp_unreachable
 lda hc_out_x+0
 sta hc_a_xlo,y
 lda hc_out_x+1
 sta hc_a_xhi,y
 lda hc_out_x+2
 sta hc_a_xext,y
 lda hc_out_y+0
 sta hc_a_ylo,y
 lda hc_out_y+1
 sta hc_a_yhi,y
 lda hc_out_y+2
 sta hc_a_yext,y
 lda hc_out_v+0
 sta hc_a_vlo,y
 lda hc_out_v+1
 sta hc_a_vhi,y
 lda hc_out_q+0
 sta hc_a_qlo,y
 lda hc_out_q+1
 sta hc_a_qhi,y
 lda hc_out_w+0
 sta hc_a_wlo,y
 lda hc_out_w+1
 sta hc_a_whi,y
 lda hc_out_s+0
 sta hc_a_slo,y
 lda hc_out_s+1
 sta hc_a_shi,y
 inc hc_count
 rts
hc_append_b:
 ldy hc_out_count
 cpy #12
 bcs hp_unreachable
 lda hc_out_x+0
 sta hc_b_xlo,y
 lda hc_out_x+1
 sta hc_b_xhi,y
 lda hc_out_x+2
 sta hc_b_xext,y
 lda hc_out_y+0
 sta hc_b_ylo,y
 lda hc_out_y+1
 sta hc_b_yhi,y
 lda hc_out_y+2
 sta hc_b_yext,y
 lda hc_out_v+0
 sta hc_b_vlo,y
 lda hc_out_v+1
 sta hc_b_vhi,y
 lda hc_out_q+0
 sta hc_b_qlo,y
 lda hc_out_q+1
 sta hc_b_qhi,y
 lda hc_out_w+0
 sta hc_b_wlo,y
 lda hc_out_w+1
 sta hc_b_whi,y
 lda hc_out_s+0
 sta hc_b_slo,y
 lda hc_out_s+1
 sta hc_b_shi,y
 inc hc_out_count
 rts
hc_copy_back:
 lda hc_out_count
 sta hc_count
 ldx #0
hc_copy_back_loop:
 cpx hc_count
 beq hc_copy_back_done
 lda hc_b_xlo,x
 sta hc_a_xlo,x
 lda hc_b_xhi,x
 sta hc_a_xhi,x
 lda hc_b_xext,x
 sta hc_a_xext,x
 lda hc_b_ylo,x
 sta hc_a_ylo,x
 lda hc_b_yhi,x
 sta hc_a_yhi,x
 lda hc_b_yext,x
 sta hc_a_yext,x
 lda hc_b_vlo,x
 sta hc_a_vlo,x
 lda hc_b_vhi,x
 sta hc_a_vhi,x
 lda hc_b_qlo,x
 sta hc_a_qlo,x
 lda hc_b_qhi,x
 sta hc_a_qhi,x
 lda hc_b_wlo,x
 sta hc_a_wlo,x
 lda hc_b_whi,x
 sta hc_a_whi,x
 lda hc_b_slo,x
 sta hc_a_slo,x
 lda hc_b_shi,x
 sta hc_a_shi,x
 inx
 bne hc_copy_back_loop
hc_copy_back_done:
 rts
; raw UV are u8 with 8 clipping fraction bits; preserve both.
ps_encode:
 lda hc_depth+2
 bne ps_far_error
 lda hc_depth+1
 beq ps_depth_error
ps_depth_valid:
 cmp #1
 bne ps_encode_valid
 lda hc_depth
 bne ps_encode_valid
 sta hc_out_w
 ror
 sta hc_out_w+1
 rts
ps_far_error:
 ; Exact 256 WU allowed; preserve zero/out-of-domain fault guards.
 cmp #1
 bne ps_depth_error
 lda hc_depth
 ora hc_depth+1
 beq ps_encode_valid
ps_depth_error:
 inc ps_fault
ps_encode_valid:
 lda #255
 sta rc_slot
 lda hc_depth+2
 bne rc_uncached
 lda hc_depth+1
 beq rc_uncached
 ldx #7
rc_search:
 lda hc_depth+1
 cmp rc_keyhi,x
 bne rc_next_key
 lda hc_depth
 cmp rc_keylo,x
 beq rc_cache_hit
rc_next_key:
 dex
 bpl rc_search
rc_cache_miss:
 ldx rc_next
 stx rc_slot
 inx
 txa
 and #7
 sta rc_next
 jmp rc_uncached
rc_cache_hit:
 lda rc_wlo,x
 sta hc_num
 lda rc_whi,x
 sta hc_num+1
 jmp rc_w_ready
rc_uncached:
 ldx #5
 lda #0
-
 sta hc_num,x
 dex
 bpl -
 lda #128
 sta hc_num+2
 ldx #2
-
 lda hc_depth,x
 sta hc_divisor,x
 dex
 bpl -
 jsr hc_div40
rc_w_ready:
 lda hc_num
 sta hc_out_w
 sta ps_b
 lda hc_num+1
 sta hc_out_w+1
 sta ps_b+1
 ldx rc_slot
 bmi rc_apply_uv
 lda hc_depth
 sta rc_keylo,x
 lda hc_depth+1
 sta rc_keyhi,x
 lda hc_out_w
 sta rc_wlo,x
 lda hc_out_w+1
 sta rc_whi,x
rc_apply_uv:
 lda hc_out_s
 sta ps_a
 lda hc_out_s+1
 sta ps_a+1
 jsr ps_mul16
 lda ps_prod+2
 asl
 sta hc_out_s
 lda ps_prod+1
 asl
 lda hc_out_s
 adc #0
 sta hc_out_s
 lda ps_prod+3
 asl
 sta hc_out_s+1
 lda ps_prod+2
 asl
 lda hc_out_s+1
 adc #0
 sta hc_out_s+1
 lda hc_out_v
 sta ps_a
 lda hc_out_v+1
 sta ps_a+1
 jsr ps_mul16
 lda ps_prod+2
 asl
 sta hc_out_v
 lda ps_prod+1
 asl
 lda hc_out_v
 adc #0
 sta hc_out_v
 lda ps_prod+3
 asl
 sta hc_out_v+1
 lda ps_prod+2
 asl
 lda hc_out_v+1
 adc #0
 sta hc_out_v+1
 rts
; Unsigned16 x unsigned16 => unsigned32. ps_b preserved for V.
ps_mul16:
 ldx #3
 lda #0
-
 sta ps_prod,x
 sta ps_shift,x
 dex
 bpl -
 lda ps_a
 sta ps_shift
 lda ps_a+1
 sta ps_shift+1
 lda ps_b
 sta ps_bits
 lda ps_b+1
 sta ps_bits+1
 ldx #16
ps_mul_loop:
 lsr ps_bits+1
 ror ps_bits
 bcc ps_mul_shift
 clc
 lda ps_prod+0
 adc ps_shift+0
 sta ps_prod+0
 lda ps_prod+1
 adc ps_shift+1
 sta ps_prod+1
 lda ps_prod+2
 adc ps_shift+2
 sta ps_prod+2
 lda ps_prod+3
 adc ps_shift+3
 sta ps_prod+3
ps_mul_shift:
 asl ps_shift
 rol ps_shift+1
 rol ps_shift+2
 rol ps_shift+3
 dex
 bne ps_mul_loop
 rts
demo_x_pos_lo: .byte 0,142,163,175,0,175,163,142,0,114,93,81,0,81,93,114,0,142,163,175,0,175,163,142,0,114,93,81,0,81,93,114
demo_x_pos_hi: .byte 0,252,249,247,247,247,249,252,0,3,6,8,9,8,6,3,0,252,249,247,247,247,249,252,0,3,6,8,9,8,6,3
demo_x_delta_lo: .byte 242,244,248,253,3,8,12,14,14,12,8,3,253,248,244,242,242,244,248,253,3,8,12,14,14,12,8,3,253,248,244,242
demo_x_delta_hi: .byte 255,255,255,255,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,255,255,255,255
demo_z_pos_lo: .byte 0,167,151,187,245,28,253,94,0,162,3,228,11,69,105,89,0,89,105,69,11,228,3,162,0,94,253,28,245,187,151,167
demo_z_pos_hi: .byte 246,246,248,251,255,5,10,17,24,30,37,42,48,52,55,57,58,57,55,52,48,42,37,30,24,17,10,5,255,251,248,246
demo_z_delta_lo: .byte 3,8,13,17,21,24,26,27,27,26,24,21,17,13,8,3,253,248,243,239,235,232,230,229,229,230,232,235,239,243,248,253
demo_z_delta_hi: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
demo_yaw_pos_lo: .byte 154,113,239,199,153,68,243,113,120,127,128,64,153,122,45,250,251,89,225,171,48,135,185,143,100,157,88,2,249,75,151,111
demo_yaw_pos_hi: .byte 53,38,31,38,40,16,246,236,236,237,235,222,204,228,61,60,72,89,106,122,134,141,145,147,147,143,131,104,73,65,69,66
demo_yaw_delta_lo: .byte 195,230,27,7,159,155,214,0,4,248,203,185,96,99,255,48,65,70,63,46,29,17,7,255,241,207,147,136,221,17,243,205
demo_yaw_delta_hi: .byte 255,255,0,0,255,255,255,0,0,255,255,255,0,1,255,0,0,0,0,0,0,0,0,255,255,255,255,255,255,0,255,255
demo_pitch_pos_lo: .byte 196,223,107,19,18,199,35,53,65,110,58,140,231,186,128,78,147,208,116,71,2,102,81,203,0,143,169,148,246,51,223,6
demo_pitch_pos_hi: .byte 2,5,14,24,21,6,0,255,0,2,8,19,23,11,2,255,254,254,255,0,1,1,1,0,0,255,0,4,8,9,5,3
demo_pitch_delta_lo: .byte 12,34,39,244,199,229,252,4,9,23,45,17,207,219,243,253,1,3,3,3,2,0,254,253,254,4,16,18,1,243,245,255
demo_pitch_delta_hi: .byte 0,0,0,255,255,255,255,0,0,0,0,0,255,255,255,255,0,0,0,0,0,0,255,255,255,0,0,0,0,255,255,255
demo_bob: .byte 0,0,1,3,5,7,10,13,16,19,22,25,27,29,31,32,32,32,31,29,27,25,22,19,16,13,10,7,5,3,1,0
hp_block_clip_helpers_end:
.if * > $9ece
 .error "Q8 allocation overflow: clip_helpers"
.endif

; Q8 block poly_draw
* = $4af8
hp_block_poly_draw_begin:
; Every face uses its whole clipped convex polygon, not a fan.
draw_clip_poly_gouraud:
 lda #0
 sta face_ymin
 lda #PROJ_SCREEN_MAX_Y
 sta face_ymax
 ldx #PROJ_SCREEN_MAX_Y
tq_clear:
 lda #255
 sta leftb,x
 lda #0
 sta rightb,x
 sta tq_closed,x
 dex
 bpl tq_clear
 lda #0
 sta tq_edge
tq_edges:
 lda tq_edge
 sta tq_from
 clc
 adc #1
 cmp hc_count
 bcc tq_next_ok
 lda #0
tq_next_ok:
 sta tq_to
 jsr tq_edge_setup
 inc tq_edge
 lda tq_edge
 cmp hc_count
 bne tq_edges
 jmp gouraud_fill_bounds

tq_edge_setup:
 ldx tq_from
 ldy tq_to
 lda hc_a_yhi,x
 cmp hc_a_yhi,y
 bcc tq_ordered
 bne tq_swap
 lda hc_a_ylo,x
 cmp hc_a_ylo,y
 bcc tq_ordered
 beq tq_edge_done
tq_swap:
 sty tq_from
 stx tq_to
 ldx tq_from
 ldy tq_to
tq_ordered:
 sec
 lda hc_a_ylo,y
 sbc hc_a_ylo,x
 sta tq_dy
 lda hc_a_yhi,y
 sbc hc_a_yhi,x
 sta tq_dy+1
 lda hc_a_ylo,x
 and #3
 eor #3
 clc
 adc #1
 and #3
 sta tq_pre
 clc
 adc hc_a_ylo,x
 sta tq_work
 lda hc_a_yhi,x
 adc #0
 lsr
 ror tq_work
 lsr
 ror tq_work
 lda tq_work
 sta tq_row
 clc
 lda hc_a_ylo,y
 adc #3
 sta tq_work
 lda hc_a_yhi,y
 adc #0
 lsr
 ror tq_work
 lsr
 ror tq_work
 lda tq_work
 sta tq_end
 ; Closed screen bottom; internal edge endpoints are otherwise excluded.
 lda hc_changed
 beq tq_end_ready
 lda hc_a_yhi,y
 cmp #>(PROJ_SCREEN_MAX_Y*4)
 bne tq_end_ready
 lda hc_a_ylo,y
 cmp #<(PROJ_SCREEN_MAX_Y*4)
 bne tq_end_ready
 inc tq_end
tq_end_ready:
 lda tq_row
 cmp tq_end
 bcs tq_edge_done
 lda #0
 sta tq_cap
 lda hc_changed
 beq tq_cap_ready
 lda hc_a_xhi,x
 cmp #>(PROJ_SCREEN_MAX_X*4)
 bne tq_cap_ready
 cmp hc_a_xhi,y
 bne tq_cap_ready
 lda hc_a_xlo,x
 cmp #<(PROJ_SCREEN_MAX_X*4)
 bne tq_cap_ready
 cmp hc_a_xlo,y
 bne tq_cap_ready
 inc tq_cap
tq_cap_ready:
 lda #0
 sta tq_ch
 ldx tq_from
 ldy tq_to
 lda hc_a_xlo,x
 sta tq_start+0
 lda hc_a_xhi,x
 sta tq_start+1
 lda #0
 sta tq_start+2
 sec
 lda hc_a_xlo,y
 sbc hc_a_xlo,x
 sta tq_delta+0
 lda hc_a_xhi,y
 sbc hc_a_xhi,x
 sta tq_delta+1
 lda #0
 sbc #0
 sta tq_delta+2
 jsr tq_setup_channel
 lda #1
 sta tq_ch
 ldx tq_from
 ldy tq_to
 lda hc_a_slo,x
 sta tq_start+0
 lda hc_a_shi,x
 sta tq_start+1
 lda #0
 sta tq_start+2
 sec
 lda hc_a_slo,y
 sbc hc_a_slo,x
 sta tq_delta+0
 lda hc_a_shi,y
 sbc hc_a_shi,x
 sta tq_delta+1
 lda #0
 sbc #0
 sta tq_delta+2
 jsr tq_setup_channel
 lda #2
 sta tq_ch
 ldx tq_from
 ldy tq_to
 lda hc_a_vlo,x
 sta tq_start+0
 lda hc_a_vhi,x
 sta tq_start+1
 lda #0
 sta tq_start+2
 sec
 lda hc_a_vlo,y
 sbc hc_a_vlo,x
 sta tq_delta+0
 lda hc_a_vhi,y
 sbc hc_a_vhi,x
 sta tq_delta+1
 lda #0
 sbc #0
 sta tq_delta+2
 jsr tq_setup_channel
 lda #3
 sta tq_ch
 ldx tq_from
 ldy tq_to
 lda hc_a_wlo,x
 sta tq_start+0
 lda hc_a_whi,x
 sta tq_start+1
 lda #0
 sta tq_start+2
 sec
 lda hc_a_wlo,y
 sbc hc_a_wlo,x
 sta tq_delta+0
 lda hc_a_whi,y
 sbc hc_a_whi,x
 sta tq_delta+1
 lda #0
 sbc #0
 sta tq_delta+2
 jsr tq_setup_channel
 lda #4
 sta tq_ch
 ldx tq_from
 ldy tq_to
 lda hc_a_qlo,x
 sta tq_start+0
 lda hc_a_qhi,x
 sta tq_start+1
 lda #0
 sta tq_start+2
 sec
 lda hc_a_qlo,y
 sbc hc_a_qlo,x
 sta tq_delta+0
 lda hc_a_qhi,y
 sbc hc_a_qhi,x
 sta tq_delta+1
 lda #0
 sbc #0
 sta tq_delta+2
 jsr tq_setup_channel
tq_row_loop:
 ; ceil((integer-Q2 + remainder/dy)/4), including exact fractional ties.
 lda tq_cur0
 and #3
 bne tq_x_ceil
 lda tq_err0
 ora tq_err1
 beq tq_x_ceil
 lda #4
 bne tq_x_bias
tq_x_ceil:
 lda #3
tq_x_bias:
 clc
 adc tq_cur0
 sta tq_work
 lda tq_cur1
 adc #0
 lsr
 ror tq_work
 lsr
 ror tq_work
 ldx tq_row
 lda tq_work
 cmp leftb,x
 bcs tq_right
 sta leftb,x
 lda tq_cur0+1
 sta ps_lefts_lo,x
 lda tq_cur1+1
 sta ps_lefts_hi,x
 lda tq_cur0+2
 sta ps_leftv_lo,x
 lda tq_cur1+2
 sta ps_leftv_hi,x
 lda tq_cur0+3
 sta ps_leftw_lo,x
 lda tq_cur1+3
 sta ps_leftw_hi,x
 lda tq_cur1+4
 sta m3_leftq,x
tq_right:
 lda tq_work
 cmp rightb,x
 bcc tq_next_row
 beq tq_right_tie
 sta rightb,x
 lda tq_cap
 jmp tq_right_cap
tq_right_tie:
 lda tq_cap
 ora tq_closed,x
tq_right_cap:
 sta tq_closed,x
 lda tq_cur0+1
 sta ps_rights_lo,x
 lda tq_cur1+1
 sta ps_rights_hi,x
 lda tq_cur0+2
 sta ps_rightv_lo,x
 lda tq_cur1+2
 sta ps_rightv_hi,x
 lda tq_cur0+3
 sta ps_rightw_lo,x
 lda tq_cur1+3
 sta ps_rightw_hi,x
 lda tq_cur1+4
 sta m3_rightq,x
tq_next_row:
 inc tq_row
 lda tq_row
 cmp tq_end
 beq tq_edge_done
 ldx #0
tq_advance:
 clc
 lda tq_cur0,x
 adc tq_step0,x
 sta tq_cur0,x
 lda tq_cur1,x
 adc tq_step1,x
 sta tq_cur1,x
 lda tq_cur2,x
 adc tq_step2,x
 sta tq_cur2,x
 clc
 lda tq_err0,x
 adc tq_rem0,x
 sta tq_err0,x
 lda tq_err1,x
 adc tq_rem1,x
 sta tq_err1,x
 cmp tq_dy+1
 bcc tq_advance_done
 bne tq_correct
 lda tq_err0,x
 cmp tq_dy
 bcc tq_advance_done
tq_correct:
 sec
 lda tq_err0,x
 sbc tq_dy
 sta tq_err0,x
 lda tq_err1,x
 sbc tq_dy+1
 sta tq_err1,x
 inc tq_cur0,x
 bne tq_advance_done
 inc tq_cur1,x
 bne tq_advance_done
 inc tq_cur2,x
tq_advance_done:
 inx
 cpx #5
 bne tq_advance
 jmp tq_row_loop
tq_edge_done:
 rts
; Exact initial offset and step, then quotient/remainder additions.
tq_setup_channel:
 jmp es_setup_channel
 .fill 2,$ea
 ldx tq_ch
 clc
 lda hc_result+0
 adc tq_start+0
 sta tq_cur0,x
 lda hc_result+1
 adc tq_start+1
 sta tq_cur1,x
 lda hc_result+2
 adc tq_start+2
 sta tq_cur2,x
 lda hc_remainder+0
 sta tq_err0,x
 lda hc_remainder+1
 sta tq_err1,x
 lda #4
 jsr tq_product
 ldx tq_ch
 lda hc_result+0
 sta tq_step0,x
 lda hc_result+1
 sta tq_step1,x
 lda hc_result+2
 sta tq_step2,x
 lda hc_remainder+0
 sta tq_rem0,x
 lda hc_remainder+1
 sta tq_rem1,x
 rts
tq_product:
 sta hc_factor
 lda #0
 sta hc_factor+1
 sta hc_factor+2
 sta hc_den+2
 lda tq_dy
 sta hc_den
 lda tq_dy+1
 sta hc_den+1
 lda tq_delta+0
 sta hc_delta+0
 lda tq_delta+1
 sta hc_delta+1
 lda tq_delta+2
 sta hc_delta+2
 jsr hq_ratio_product
 ; Convert signed trunc0 to Euclidean floor + nonnegative remainder.
 lda hc_sign
 bpl tq_product_done
 lda hc_remainder
 ora hc_remainder+1
 beq tq_product_done
 sec
 lda hc_result
 sbc #1
 sta hc_result
 lda hc_result+1
 sbc #0
 sta hc_result+1
 lda hc_result+2
 sbc #0
 sta hc_result+2
 sec
 lda tq_dy
 sbc hc_remainder
 sta hc_remainder
 lda tq_dy+1
 sbc hc_remainder+1
 sta hc_remainder+1
tq_product_done:
 rts
hp_block_poly_draw_end:
.if * > $4f03
 .error "Q8 allocation overflow: poly_draw"
.endif

; Q8 block camera_yaw
* = $45f6
hp_block_camera_yaw_begin:
qc_rotate_vertices:
 lda explorer_cam_yaw
 ora qc_demo_yaw_lo
 ora qc_demo_pitch_lo

 ora explorer_cam_pitch
 bne qc_rotate_active
 rts
qc_rotate_active:
 lda #0
 sec
 sbc qc_demo_yaw_lo
 sta hp_fraction
 lda #0
 sbc explorer_cam_yaw
 tax
 jsr hp_sine
 lda hp_r+0
 sta qc_ys+0
 lda hp_r+1
 sta qc_ys+1
 ldx hp_sine_index
 txa
 clc
 adc #64
 tax
 jsr hp_sine
 lda hp_r+0
 sta qc_yc+0
 lda hp_r+1
 sta qc_yc+1
 lda #0
 sec
 sbc qc_demo_pitch_lo
 sta hp_fraction
 lda #0
 sbc explorer_cam_pitch
 tax
 jsr hp_sine
 lda hp_r+0
 sta qc_ps+0
 lda hp_r+1
 sta qc_ps+1
 ldx hp_sine_index
 txa
 clc
 adc #64
 tax
 jsr hp_sine
 lda hp_r+0
 sta qc_pc+0
 lda hp_r+1
 sta qc_pc+1
 lda active_vfirst
 sta qc_index
qc_vertex:
 ldy qc_index
 lda hc_cam_x0,y
 sta qc_x+0
 lda hc_cam_x1,y
 sta qc_x+1
 lda hc_cam_x2,y
 sta qc_x+2
 lda hc_cam_y0,y
 sta qc_y+0
 lda hc_cam_y1,y
 sta qc_y+1
 lda hc_cam_y2,y
 sta qc_y+2
 lda hc_cam_z0,y
 sta qc_z+0
 lda hc_cam_z1,y
 sta qc_z+1
 lda hc_cam_z2,y
 sta qc_z+2
 lda explorer_cam_yaw
 ora qc_demo_yaw_lo
 beq qc_pitch
 ldx #2
-
 lda qc_x,x
 sta qc_a,x
 dex
 bpl -
 ldx #1
-
 lda qc_yc,x
 sta qc_b,x
 dex
 bpl -
 jsr qc_product
 ldx #2
-
 lda qc_r,x
 sta qc_t0,x
 dex
 bpl -
 ldx #2
-
 lda qc_z,x
 sta qc_a,x
 dex
 bpl -
 ldx #1
-
 lda qc_ys,x
 sta qc_b,x
 dex
 bpl -
 jsr qc_product
 ldx #2
-
 lda qc_r,x
 sta qc_t1,x
 dex
 bpl -
 sec
 ldy #0
 ldx #3
-
 lda qc_t0,y
 sbc qc_t1,y
 sta qc_tx,y
 iny
 dex
 bne -
 ldx #2
-
 lda qc_x,x
 sta qc_a,x
 dex
 bpl -
 ldx #1
-
 lda qc_ys,x
 sta qc_b,x
 dex
 bpl -
 jsr qc_product
 ldx #2
-
 lda qc_r,x
 sta qc_t0,x
 dex
 bpl -
 ldx #2
-
 lda qc_z,x
 sta qc_a,x
 dex
 bpl -
 ldx #1
-
 lda qc_yc,x
 sta qc_b,x
 dex
 bpl -
 jsr qc_product
 ldx #2
-
 lda qc_r,x
 sta qc_t1,x
 dex
 bpl -
 clc
 ldy #0
 ldx #3
-
 lda qc_t0,y
 adc qc_t1,y
 sta qc_z,y
 iny
 dex
 bne -
 ldx #2
-
 lda qc_tx,x
 sta qc_x,x
 dex
 bpl -
 jmp qc_pitch
qc_pitch:
 lda explorer_cam_pitch
 ora qc_demo_pitch_lo
 beq qc_store
 ldx #2
-
 lda qc_y,x
 sta qc_a,x
 dex
 bpl -
 ldx #1
-
 lda qc_pc,x
 sta qc_b,x
 dex
 bpl -
 jsr qc_product
 ldx #2
-
 lda qc_r,x
 sta qc_t0,x
 dex
 bpl -
 ldx #2
-
 lda qc_z,x
 sta qc_a,x
 dex
 bpl -
 ldx #1
-
 lda qc_ps,x
 sta qc_b,x
 dex
 bpl -
 jsr qc_product
 ldx #2
-
 lda qc_r,x
 sta qc_t1,x
 dex
 bpl -
 sec
 ldy #0
 ldx #3
-
 lda qc_t0,y
 sbc qc_t1,y
 sta qc_ty,y
 iny
 dex
 bne -
 ldx #2
-
 lda qc_y,x
 sta qc_a,x
 dex
 bpl -
 ldx #1
-
 lda qc_ps,x
 sta qc_b,x
 dex
 bpl -
 jsr qc_product
 ldx #2
-
 lda qc_r,x
 sta qc_t0,x
 dex
 bpl -
 ldx #2
-
 lda qc_z,x
 sta qc_a,x
 dex
 bpl -
 ldx #1
-
 lda qc_pc,x
 sta qc_b,x
 dex
 bpl -
 jsr qc_product
 ldx #2
-
 lda qc_r,x
 sta qc_t1,x
 dex
 bpl -
 clc
 ldy #0
 ldx #3
-
 lda qc_t0,y
 adc qc_t1,y
 sta qc_z,y
 iny
 dex
 bne -
 ldx #2
-
 lda qc_ty,x
 sta qc_y,x
 dex
 bpl -
qc_store:
 ldy qc_index
 lda qc_x+0
 sta hc_cam_x0,y
 lda qc_x+1
 sta hc_cam_x1,y
 lda qc_x+2
 sta hc_cam_x2,y
 lda qc_x+1
 sta vxrawlo,y
 sta rxbuf,y
 lda qc_x+2
 sta vxrawhi,y
 lda qc_y+0
 sta hc_cam_y0,y
 lda qc_y+1
 sta hc_cam_y1,y
 lda qc_y+2
 sta hc_cam_y2,y
 lda qc_y+1
 sta vyrawlo,y
 sta rybuf,y
 lda qc_y+2
 sta vyrawhi,y
 lda qc_z+0
 sta hc_cam_z0,y
 lda qc_z+1
 sta hc_cam_z1,y
 lda qc_z+2
 sta hc_cam_z2,y
 lda qc_z+1
 sta vzrawlo,y
 sta sz,y
 lda qc_z+2
 sta vzrawhi,y
 sta szhi,y
 inc qc_index
 lda qc_index
 cmp active_vend
 bne qc_vertex
 rts
; Signed24 Q8 coordinate * signed16 Q8 trig, abs(trig)<=256.
; Round magnitude to nearest, ties away from zero. Result signed24 Q8.
; No IRQ-owned scratch, no SMC, documented 6502 instructions only.
qc_product:
 lda qc_a+2
 eor qc_b+1
 and #$80
 sta qc_sign
 lda qc_a+2
 bpl qc_product_a_positive
 sec
 lda #0
 sbc qc_a
 sta qc_a
 lda #0
 sbc qc_a+1
 sta qc_a+1
 lda #0
 sbc qc_a+2
 sta qc_a+2
qc_product_a_positive:
 lda qc_b+1
 bpl qc_product_b_positive
 sec
 lda #0
 sbc qc_b
 sta qc_b
 lda #0
 sbc qc_b+1
 sta qc_b+1
qc_product_b_positive:
 ldx #2
qc_product_copy:
 lda qc_a,x
 sta qc_m,x
 dex
 bpl qc_product_copy
 lda #0
 sta qc_m+3
 ldx #3
qc_product_clear:
 sta qc_prod,x
 dex
 bpl qc_product_clear
 ldx #9
qc_product_loop:
 lsr qc_b+1
 ror qc_b
 bcc qc_product_shift
 clc
 lda qc_prod
 adc qc_m
 sta qc_prod
 lda qc_prod+1
 adc qc_m+1
 sta qc_prod+1
 lda qc_prod+2
 adc qc_m+2
 sta qc_prod+2
 lda qc_prod+3
 adc qc_m+3
 sta qc_prod+3
qc_product_shift:
 asl qc_m
 rol qc_m+1
 rol qc_m+2
 rol qc_m+3
 dex
 bne qc_product_loop
 lda qc_prod
 cmp #128
 lda qc_prod+1
 adc #0
 sta qc_r
 lda qc_prod+2
 adc #0
 sta qc_r+1
 lda qc_prod+3
 adc #0
 sta qc_r+2
 lda qc_sign
 beq qc_product_done
 sec
 lda #0
 sbc qc_r
 sta qc_r
 lda #0
 sbc qc_r+1
 sta qc_r+1
 lda #0
 sbc qc_r+2
 sta qc_r+2
qc_product_done:
 rts
qc_demo_tick:
 lda demo_subtick
 bne demo_increment
 ldx demo_key
 lda demo_x_pos_lo,x
 sta demo_x_lo
 lda demo_x_delta_lo,x
 sta demo_x_step_lo
 lda demo_x_pos_hi,x
 sta demo_x_hi
 lda demo_x_delta_hi,x
 sta demo_x_step_hi
 lda demo_z_pos_lo,x
 sta demo_z_lo
 lda demo_z_delta_lo,x
 sta demo_z_step_lo
 lda demo_z_pos_hi,x
 sta demo_z_hi
 lda demo_z_delta_hi,x
 sta demo_z_step_hi
 lda demo_yaw_pos_lo,x
 sta demo_yaw_lo
 lda demo_yaw_delta_lo,x
 sta demo_yaw_step_lo
 lda demo_yaw_pos_hi,x
 sta demo_yaw_hi
 lda demo_yaw_delta_hi,x
 sta demo_yaw_step_hi
 lda demo_pitch_pos_lo,x
 sta demo_pitch_lo
 lda demo_pitch_delta_lo,x
 sta demo_pitch_step_lo
 lda demo_pitch_pos_hi,x
 sta demo_pitch_hi
 lda demo_pitch_delta_hi,x
 sta demo_pitch_step_hi
demo_increment:
 clc
 lda demo_x_lo
 adc demo_x_step_lo
 sta demo_x_lo
 lda demo_x_hi
 adc demo_x_step_hi
 sta demo_x_hi
 clc
 lda demo_z_lo
 adc demo_z_step_lo
 sta demo_z_lo
 lda demo_z_hi
 adc demo_z_step_hi
 sta demo_z_hi
 clc
 lda demo_yaw_lo
 adc demo_yaw_step_lo
 sta demo_yaw_lo
 lda demo_yaw_hi
 adc demo_yaw_step_hi
 sta demo_yaw_hi
 clc
 lda demo_pitch_lo
 adc demo_pitch_step_lo
 sta demo_pitch_lo
 lda demo_pitch_hi
 adc demo_pitch_step_hi
 sta demo_pitch_hi
 lda demo_x_lo
 sta explorer_cam_x_lo
 lda demo_x_hi
 sta explorer_cam_x_hi
 lda demo_x_hi
 asl
 lda #0
 sbc #0
 eor #255
 sta explorer_cam_x_ext
 lda demo_z_lo
 sta explorer_cam_z_lo
 lda demo_z_hi
 sta explorer_cam_z_hi
 lda demo_z_hi
 asl
 lda #0
 sbc #0
 eor #255
 sta explorer_cam_z_ext
 ; Head bob is tied to logical time, never to rendered frames.
 inc demo_bob_phase
 lda demo_bob_phase
 and #31
 tax
 clc
 lda demo_y_lo
 adc demo_bob,x
 sta explorer_cam_y_lo
 lda demo_y_hi
 adc #0
 sta explorer_cam_y_hi
 lda #0
 sta explorer_cam_y_ext
 lda demo_yaw_lo
 sta qc_demo_yaw_lo
 lda demo_yaw_hi
 sta explorer_cam_yaw
 lda demo_pitch_lo
 sta qc_demo_pitch_lo
 lda demo_pitch_hi
 sta explorer_cam_pitch
 inc demo_subtick
 lda demo_subtick
 and #63
 sta demo_subtick
 bne demo_tick_done
 inc demo_key
 lda demo_key
 and #31
 sta demo_key
demo_tick_done:
 rts
demo_key: .byte 0
demo_subtick: .byte 0
demo_bob_phase: .byte 0
qc_demo_yaw_lo: .byte 0
qc_demo_pitch_lo: .byte 0
demo_x_lo: .byte 0
demo_x_hi: .byte 0
demo_x_step_lo: .byte 0
demo_x_step_hi: .byte 0
demo_y_lo: .byte 0
demo_y_hi: .byte 0
demo_z_lo: .byte 0
demo_z_hi: .byte 0
demo_z_step_lo: .byte 0
demo_z_step_hi: .byte 0
demo_yaw_lo: .byte 0
demo_yaw_hi: .byte 0
demo_yaw_step_lo: .byte 0
demo_yaw_step_hi: .byte 0
demo_pitch_lo: .byte 0
demo_pitch_hi: .byte 0
demo_pitch_step_lo: .byte 0
demo_pitch_step_hi: .byte 0
demo_count_frame:
 inc demo_frames
 bne +
 inc demo_frames+1
+
 rts
demo_count_refresh:
 inc demo_refreshes
 bne +
 inc demo_refreshes+1
+
 rts
demo_frames: .word 0
demo_refreshes: .word 0
hp_block_camera_yaw_end:
.if * > $4af8
 .error "Q8 allocation overflow: camera_yaw"
.endif

; Q8 block perspective_sample
* = $4f04
hp_block_perspective_sample_begin:
bk_exact_sample:
 stx ps_saved_x
 lda ps_cur0+2
 sta ps_den
 lda ps_cur1+2
 sta ps_den+1
 lda ps_cur0+0
 sta up_inputlo+0
 lda ps_cur1+0
 sta up_inputhi+0
 lda ps_cur0+1
 sta up_inputlo+1
 lda ps_cur1+1
 sta up_inputhi+1
 jsr up_pair
 ldx ps_saved_x
 rts
; Exact floor((ps_a unsigned16 *128)/ps_den unsigned16).
; q<256: extract one integer bit followed by seven fractional bits.
; Full quotient24/remainder16 preserved. Original divider handles other inputs.
; Private absolute state only; no SMC/ZP/IRQ changes.
up_pair:
 jmp uz_pair
 ora ps_den+1
 beq up_fallback
 lda ps_den+1
 cmp #128
 bcc ut_domain_ok
 bne up_fallback
 lda ps_den
 bne up_fallback
ut_domain_ok:
 ldx #1
up_init:
 lda up_inputlo,x
 sta up_remlo,x
 lda up_inputhi,x
 sta up_remhi,x
 lda #0
 sta m7_u,x
 lda up_remhi,x
 cmp ps_den+1
 bcc up_init_next
 bne up_initial_sub
 lda up_remlo,x
 cmp ps_den
 bcc up_init_next
up_initial_sub:
 sec
 lda up_remlo,x
 sbc ps_den
 sta up_remlo,x
 lda up_remhi,x
 sbc ps_den+1
 sta up_remhi,x
 inc m7_u,x
 lda up_remhi,x
 cmp ps_den+1
 bcc up_init_next
 bne up_fallback
 lda up_remlo,x
 cmp ps_den
 bcs up_fallback
up_init_next:
 dex
 bpl up_init
 ldy #7
up_bit:
 asl up_remlo
 rol up_remhi
 sec
 lda up_remlo
 sbc ps_den
 tax
 lda up_remhi
 sbc ps_den+1
 bcc ut_append_u
 sta up_remhi
 stx up_remlo
ut_append_u:
 ; On failure R stays untouched and C0; success stores R with C1.
 rol m7_u
 asl up_remlo+1
 rol up_remhi+1
 sec
 lda up_remlo+1
 sbc ps_den
 tax
 lda up_remhi+1
 sbc ps_den+1
 bcc ut_append_v
 sta up_remhi+1
 stx up_remlo+1
ut_append_v:
 ; On failure R stays untouched and C0; success stores R with C1.
 rol m7_u+1
 dey
 bne up_bit
 rts
up_fallback:
 lda up_inputlo
 sta ps_a
 lda up_inputhi
 sta ps_a+1
 jsr ps_uv_divide
 sta m7_u
 lda up_inputlo+1
 sta ps_a
 lda up_inputhi+1
 sta ps_a+1
 jsr ps_uv_divide
 sta m7_v
 rts
ps_uv_divide:
 lda ps_den
 ora ps_den+1
 bne ps_uv_nonzero
 jmp ps_uv_fallback
ps_uv_nonzero:
 lda ps_a
 sta ps_remainder
 lda ps_a+1
 sta ps_remainder+1
 lda #0
 sta ps_num
 sta ps_num+1
 sta ps_num+2
 lda ps_remainder+1
 cmp ps_den+1
 bcc ps_uv_fraction
 bne ps_uv_integer
 lda ps_remainder
 cmp ps_den
 bcc ps_uv_fraction
ps_uv_integer:
 sec
 lda ps_remainder
 sbc ps_den
 sta ps_remainder
 lda ps_remainder+1
 sbc ps_den+1
 sta ps_remainder+1
 inc ps_num
 ; A/W>=2: do not truncate the full quotient or change its low byte.
 lda ps_remainder+1
 cmp ps_den+1
 bcc ps_uv_fraction
 bne ps_uv_fallback
 lda ps_remainder
 cmp ps_den
 bcs ps_uv_fallback
ps_uv_fraction:
 ldx #7
ps_uv_bit:
 asl ps_remainder
 rol ps_remainder+1
 bcs ps_uv_subtract
 lda ps_remainder+1
 cmp ps_den+1
 bcc ps_uv_zero_bit
 bne ps_uv_subtract
 lda ps_remainder
 cmp ps_den
 bcc ps_uv_zero_bit
ps_uv_subtract:
 sec
 lda ps_remainder
 sbc ps_den
 sta ps_remainder
 lda ps_remainder+1
 sbc ps_den+1
 sta ps_remainder+1
 sec
 jmp ps_uv_append
ps_uv_zero_bit:
 clc
ps_uv_append:
 rol ps_num
 dex
 bne ps_uv_bit
 lda ps_num
 rts
ps_uv_fallback:
 lda ps_a
 sta ps_num
 lda ps_a+1
 sta ps_num+1
 lda #0
 sta ps_num+2
 ldx #7
-
 asl ps_num
 rol ps_num+1
 rol ps_num+2
 dex
 bne -
 jsr ps_div24_16
 lda ps_num
 rts
; Unsigned numerator24/denominator16, exact floor and remainder.
; Documented 6510 instructions, private absolute scratch, no SMC.
ps_div24_16:
 lda #0
 sta ps_remainder
 sta ps_remainder+1
 lda ps_den
 ora ps_den+1
 bne ps_div_nonzero
 inc ps_fault
 lda #0
 sta ps_num
 sta ps_num+1
 sta ps_num+2
 rts
ps_div_nonzero:
 ldx #24
ps_div_loop:
 asl ps_num
 rol ps_num+1
 rol ps_num+2
 rol ps_remainder
 rol ps_remainder+1
 bcs ps_div_subtract
 lda ps_remainder+1
 cmp ps_den+1
 bcc ps_div_next
 bne ps_div_subtract
 lda ps_remainder
 cmp ps_den
 bcc ps_div_next
ps_div_subtract:
 sec
 lda ps_remainder
 sbc ps_den
 sta ps_remainder
 lda ps_remainder+1
 sbc ps_den+1
 sta ps_remainder+1
 inc ps_num
ps_div_next:
 dex
 bne ps_div_loop
 rts
iu_select_surface:
 ; X is the scene texture id. Texture 2 is provably all texel 2.
 ; Patch only main-thread call sites, between faces. IRQ never calls fill.
 cpx #2
 beq iu_select_uniform
 lda #$20
 sta m7_sample
 lda #<ps_sample
 sta m7_sample+1
 lda #>ps_sample
 sta m7_sample+2
 lda #<ps_advance
 sta m7_advance+1
 lda #>ps_advance
 sta m7_advance+2
 lda #<ps_prepare_span
 sta m7_prepare_span+1
 lda #>ps_prepare_span
 sta m7_prepare_span+2
 rts
iu_select_uniform:
 lda #$4c
 sta m7_sample
 lda #<iu_sample_uniform
 sta m7_sample+1
 lda #>iu_sample_uniform
 sta m7_sample+2
 lda #<iu_advance_uniform
 sta m7_advance+1
 lda #>iu_advance_uniform
 sta m7_advance+2
 lda #<iu_prepare_uniform
 sta m7_prepare_span+1
 lda #>iu_prepare_uniform
 sta m7_prepare_span+2
 rts
iu_sample_uniform:
 lda #2
 jmp m3_composite
iu_advance_uniform:
 jsr m3_advance_q
 inc gouraud_scan_x
 rts
iu_prepare_uniform:
 jsr m3_prepare_span
 lda yrow
 and #3
 asl
 asl
 sta m2_bayer_row
 lda leftval
 sta gouraud_scan_x
 lda rightval
 sta gouraud_scan_end
 ldx yrow
 lda tq_closed,x
 bne iu_span_closed
 dec gouraud_scan_end
iu_span_closed:
 rts
ps_sample:
 stx bk_saved_x
 lda bk_count
 beq bk_boundary
bk_cached:
 lda bk_cur1
 sta m7_u
 lda bk_cur1+1
 sta m7_v
 ldx bk_saved_x
 rts
bk_boundary:
 sec
 lda gouraud_scan_end
 sbc gouraud_scan_x
 cmp #4
 bcs bk_long
 jmp bk_exact_sample ; final 1..4 pixels: exact, never sample past edge
bk_long:
 lda bk_ready
 beq bk_seed
 lda bk_next
 sta m7_u
 lda bk_next+1
 sta m7_v
 jmp bk_start
bk_seed:
 jsr bk_exact_sample
bk_start:
 ldx #1
bk_copy_start:
 lda m7_u,x
 sta bk_cur1,x
 lda #0
 sta bk_cur0,x
 dex
 bpl bk_copy_start
 ldx #2
bk_predict_channels:
 jsr bk_predict
 lda bk_future
 sta bk_look0,x
 lda bk_future+1
 sta bk_look1,x
 lda bk_delta
 sta ca_lookerr,x
 dex
 bpl bk_predict_channels
 lda bk_look0+2
 sta ps_den
 lda bk_look1+2
 sta ps_den+1
 lda bk_look0+0
 sta up_inputlo+0
 lda bk_look1+0
 sta up_inputhi+0
 lda bk_look0+1
 sta up_inputlo+1
 lda bk_look1+1
 sta up_inputhi+1
 jsr up_pair
 lda m7_u
 sta bk_next+0
 lda m7_v
 sta bk_next+1
 ldx #1
bk_setup_steps:
 sec
 lda bk_next,x
 sbc bk_cur1,x
 sta bk_delta
 lda #0
 sbc #0
 sta bk_delta+1
 lda bk_delta
 asl
 asl
 asl
 asl
 asl
 asl
 sta bk_step0,x ; (delta mod4)*64, fraction of raw UV byte
 lsr bk_delta+1
 ror bk_delta
 lsr bk_delta+1
 ror bk_delta
 lda bk_delta
 sta bk_step1,x ; signed floor(delta/4), low byte
 dex
 bpl bk_setup_steps
 lda #4
 sta bk_count
 lda #1
 sta bk_ready
 jmp bk_cached
; Predict exact existing Euclidean carrier DDA four steps ahead.
; cur +4*step +floor((err+4*rem)/width), all carriers unsigned16.
; Width1..111; err/rem<width; correction0..4; endpoint inside span.
bk_predict:
 lda ps_step1,x
 sta bk_future+1
 lda ps_step0,x
 asl
 rol bk_future+1
 asl
 rol bk_future+1
 clc
 adc ps_cur0,x
 sta bk_future
 lda bk_future+1
 adc ps_cur1,x
 sta bk_future+1
 lda #0
 sta bk_delta+1
 lda ps_rem,x
 asl
 rol bk_delta+1
 asl
 rol bk_delta+1
 clc
 adc ps_err,x
 sta bk_delta
 bcc bk_predict_test
 inc bk_delta+1
bk_predict_test:
 lda bk_delta+1
 bne b4_high
 lda bk_delta
 cmp m7_den
 bcc bk_predict_done
bk_predict_correct:
 sbc m7_den
 sta bk_delta
 bcs b4_increment
 dec bk_delta+1
b4_increment:
 inc bk_future
 bne bk_predict_test
 inc bk_future+1
 jmp bk_predict_test
b4_high:
 sec
 lda bk_delta
 bcs bk_predict_correct
bk_predict_done:
 rts
hp_block_perspective_sample_end:
.if * > $52e5
 .error "Q8 allocation overflow: perspective_sample"
.endif

; Q8 block perspective_span
* = $cb18
hp_block_perspective_span_begin:
ps_prepare_span:
 lda #0
 sta bk_count
 sta bk_ready
 jsr m3_prepare_span
 lda yrow
 and #3
 asl
 asl
 sta m2_bayer_row
 sec
 lda rightval
 sbc leftval
 sta m7_den
 lda leftval
 sta gouraud_scan_x
 lda rightval
 sta gouraud_scan_end
 ldx yrow
 lda tq_closed,x
 bne ps_span_closed
 dec gouraud_scan_end
ps_span_closed:
 ldy yrow
 lda ps_lefts_lo,y
 sta ps_cur0+0
 lda ps_lefts_hi,y
 sta ps_cur1+0
 sec
 lda ps_rights_lo,y
 sbc ps_cur0+0
 sta hc_delta
 lda ps_rights_hi,y
 sbc ps_cur1+0
 sta hc_delta+1
 lda #0
 sbc #0
 sta hc_delta+2
 jsr ps_setup
 lda hc_result
 sta ps_step0+0
 lda hc_result+1
 sta ps_step1+0
 lda hc_remainder
 sta ps_rem+0
 lda #0
 sta ps_err+0
 ldy yrow
 lda ps_leftv_lo,y
 sta ps_cur0+1
 lda ps_leftv_hi,y
 sta ps_cur1+1
 sec
 lda ps_rightv_lo,y
 sbc ps_cur0+1
 sta hc_delta
 lda ps_rightv_hi,y
 sbc ps_cur1+1
 sta hc_delta+1
 lda #0
 sbc #0
 sta hc_delta+2
 jsr ps_setup
 lda hc_result
 sta ps_step0+1
 lda hc_result+1
 sta ps_step1+1
 lda hc_remainder
 sta ps_rem+1
 lda #0
 sta ps_err+1
 ldy yrow
 lda ps_leftw_lo,y
 sta ps_cur0+2
 lda ps_leftw_hi,y
 sta ps_cur1+2
 sec
 lda ps_rightw_lo,y
 sbc ps_cur0+2
 sta hc_delta
 lda ps_rightw_hi,y
 sbc ps_cur1+2
 sta hc_delta+1
 lda #0
 sbc #0
 sta hc_delta+2
 jsr ps_setup
 lda hc_result
 sta ps_step0+2
 lda hc_result+1
 sta ps_step1+2
 lda hc_remainder
 sta ps_rem+2
 lda #0
 sta ps_err+2
 rts
; Exact signed17 delta / unsigned8 span width, Euclidean floor.
; Normal input is a difference of unsigned16 carriers: -65535..65535.
; Callers ONLY subtract unsigned16 endpoint carriers, so sign is 00/FF.
; Restoring16/8 division, no extra state, no additional allocation block.
ps_setup:
 lda m7_den
 bne pss_nonzero
 lda #0
 sta hc_result
 sta hc_result+1
 sta hc_result+2
 sta hc_remainder
 sta hc_remainder+1
 rts
pss_nonzero:
 lda hc_delta+2
 sta hc_sign
 ; Positive: divide delta. Negative: divide abs(delta)-1, then complement
 ; quotient and denominator-1-remainder. Exactly floor, without borrow fix.
 lda hc_delta
 eor hc_sign
 sta hc_result
 lda hc_delta+1
 eor hc_sign
 sta hc_result+1
pss_unsigned:
 lda #0
 sta hc_result+2
 sta hc_remainder
 sta hc_remainder+1
 sta hc_remainder+2
 ldx #16
pss_loop:
 asl hc_result
 rol hc_result+1
 rol hc_remainder
 bcs pss_short_sub
 lda hc_remainder
 cmp m7_den
 bcc pss_short_next
pss_short_sub:
 sec
 lda hc_remainder
 sbc m7_den
 sta hc_remainder
 inc hc_result
pss_short_next:
 dex
 bne pss_loop
pss_sign:
 lda hc_sign
 bpl pss_done
 lda hc_result
 eor #255
 sta hc_result
 lda hc_result+1
 eor #255
 sta hc_result+1
 clc
 lda m7_den
 sbc hc_remainder
 sta hc_remainder
pss_done:
 rts
bk_exact_advance:
 stx ps_saved_x
 ldx #0
ps_advance_loop:
 clc
 lda ps_cur0,x
 adc ps_step0,x
 sta ps_cur0,x
 lda ps_cur1,x
 adc ps_step1,x
 sta ps_cur1,x
 clc
 lda ps_err,x
 adc ps_rem,x
 bcs ps_advance_correct
 cmp m7_den
 bcc ps_advance_store
ps_advance_correct:
 sec
 sbc m7_den
 sta ps_err,x
 inc ps_cur0,x
 bne ps_advance_next
 inc ps_cur1,x
 jmp ps_advance_next
ps_advance_store:
 sta ps_err,x
ps_advance_next:
 inx
 cpx #3
 bne ps_advance_loop
 ldx ps_saved_x
 jsr m3_advance_q
 inc gouraud_scan_x
 rts
hc_near_x:
 ldx hc_to_vertex
 ldy hc_from_vertex
 sec
 lda hc_cam_x0,x
 sbc hc_cam_x0,y
 sta hc_delta+0
 lda hc_cam_x1,x
 sbc hc_cam_x1,y
 sta hc_delta+1
 jsr hc_ratio_product
 ldy hc_from_vertex
 lda hc_result+1
 asl
 lda #0
 sbc #0
 eor #$ff
 sta hc_ext
 clc
 lda hc_cam_x0,y
 adc hc_result+0
 sta hc_coord+0
 lda hc_cam_x1,y
 adc hc_result+1
 sta hc_coord+1
 lda hc_cam_x2,y
 adc hc_ext
 sta hc_coord+2
 lda #0
 sta hc_axis
 jsr hc_project_axis
 lda tq_full+0
 sta hq_projected+0
 lda tq_full+1
 sta hq_projected+1
 lda tq_full+2
 sta hq_projected+2
 lda hq_projected+0
 sta hc_out_x+0
 lda hq_projected+1
 sta hc_out_x+1
 lda hq_projected+2
 sta hc_out_x+2
 rts
hc_near_y:
 ldx hc_to_vertex
 ldy hc_from_vertex
 sec
 lda hc_cam_y0,x
 sbc hc_cam_y0,y
 sta hc_delta+0
 lda hc_cam_y1,x
 sbc hc_cam_y1,y
 sta hc_delta+1
 jsr hc_ratio_product
 ldy hc_from_vertex
 lda hc_result+1
 asl
 lda #0
 sbc #0
 eor #$ff
 sta hc_ext
 clc
 lda hc_cam_y0,y
 adc hc_result+0
 sta hc_coord+0
 lda hc_cam_y1,y
 adc hc_result+1
 sta hc_coord+1
 lda hc_cam_y2,y
 adc hc_ext
 sta hc_coord+2
 lda #1
 sta hc_axis
 jsr hc_project_axis
 lda tq_full+0
 sta hq_projected+0
 lda tq_full+1
 sta hq_projected+1
 lda tq_full+2
 sta hq_projected+2
 lda hq_projected+0
 sta hc_out_y+0
 lda hq_projected+1
 sta hc_out_y+1
 lda hq_projected+2
 sta hc_out_y+2
 rts
hc_interpolate_x:
 ldx hc_to
 ldy hc_from
 sec
 lda hc_a_xlo,x
 sbc hc_a_xlo,y
 sta hc_delta+0
 lda hc_a_xhi,x
 sbc hc_a_xhi,y
 sta hc_delta+1
 lda hc_a_xext,x
 sbc hc_a_xext,y
 sta hc_delta+2
 jsr hq_ratio_product
 ldy hc_from
 clc
 lda hc_a_xlo,y
 adc hc_result+0
 sta hc_out_x+0
 lda hc_a_xhi,y
 adc hc_result+1
 sta hc_out_x+1
 lda hc_a_xext,y
 adc hc_result+2
 sta hc_out_x+2
 rts
hc_interpolate_y:
 ldx hc_to
 ldy hc_from
 sec
 lda hc_a_ylo,x
 sbc hc_a_ylo,y
 sta hc_delta+0
 lda hc_a_yhi,x
 sbc hc_a_yhi,y
 sta hc_delta+1
 lda hc_a_yext,x
 sbc hc_a_yext,y
 sta hc_delta+2
 jsr hq_ratio_product
 ldy hc_from
 clc
 lda hc_a_ylo,y
 adc hc_result+0
 sta hc_out_y+0
 lda hc_a_yhi,y
 adc hc_result+1
 sta hc_out_y+1
 lda hc_a_yext,y
 adc hc_result+2
 sta hc_out_y+2
 rts
hc_interpolate_s:
 ldx hc_to
 ldy hc_from
 sec
 lda hc_a_slo,x
 sbc hc_a_slo,y
 sta hc_delta+0
 lda hc_a_shi,x
 sbc hc_a_shi,y
 sta hc_delta+1
 lda #0
 sbc #0
 sta hc_delta+2
 jsr hq_ratio_product
 ldy hc_from
 clc
 lda hc_a_slo,y
 adc hc_result+0
 sta hc_out_s+0
 lda hc_a_shi,y
 adc hc_result+1
 sta hc_out_s+1
 rts
hc_load_fast_face:
 lda hc_a_xlo+0
 sta vxq2_0lo
 lda hc_a_xhi+0
 sta vxq2_0hi
 lda hc_a_ylo+0
 sta vyq2_0lo
 lda hc_a_yhi+0
 sta vyq2_0hi
 lda clip_a_x+0
 sta vx0
 lda clip_a_y+0
 sta vy0
 lda hc_a_xlo+1
 sta vxq2_1lo
 lda hc_a_xhi+1
 sta vxq2_1hi
 lda hc_a_ylo+1
 sta vyq2_1lo
 lda hc_a_yhi+1
 sta vyq2_1hi
 lda clip_a_x+1
 sta vx1
 lda clip_a_y+1
 sta vy1
 lda hc_a_xlo+2
 sta vxq2_2lo
 lda hc_a_xhi+2
 sta vxq2_2hi
 lda hc_a_ylo+2
 sta vyq2_2lo
 lda hc_a_yhi+2
 sta vyq2_2hi
 lda clip_a_x+2
 sta vx2
 lda clip_a_y+2
 sta vy2
 lda hc_a_xlo+3
 sta vxq2_3lo
 lda hc_a_xhi+3
 sta vxq2_3hi
 lda hc_a_ylo+3
 sta vyq2_3lo
 lda hc_a_yhi+3
 sta vyq2_3hi
 lda clip_a_x+3
 sta vx3
 lda clip_a_y+3
 sta vy3
 rts
hc_interpolate_v:
 ldx hc_to
 ldy hc_from
 sec
 lda hc_a_vlo,x
 sbc hc_a_vlo,y
 sta hc_delta+0
 lda hc_a_vhi,x
 sbc hc_a_vhi,y
 sta hc_delta+1
 lda #0
 sbc #0
 sta hc_delta+2
 jsr hq_ratio_product
 ldy hc_from
 clc
 lda hc_a_vlo,y
 adc hc_result+0
 sta hc_out_v+0
 lda hc_a_vhi,y
 adc hc_result+1
 sta hc_out_v+1
 rts
hc_interpolate_q:
 ldx hc_to
 ldy hc_from
 sec
 lda hc_a_qlo,x
 sbc hc_a_qlo,y
 sta hc_delta+0
 lda hc_a_qhi,x
 sbc hc_a_qhi,y
 sta hc_delta+1
 lda #0
 sbc #0
 sta hc_delta+2
 jsr hq_ratio_product
 ldy hc_from
 clc
 lda hc_a_qlo,y
 adc hc_result+0
 sta hc_out_q+0
 lda hc_a_qhi,y
 adc hc_result+1
 sta hc_out_q+1
 rts
hc_interpolate_w:
 ldx hc_to
 ldy hc_from
 sec
 lda hc_a_wlo,x
 sbc hc_a_wlo,y
 sta hc_delta+0
 lda hc_a_whi,x
 sbc hc_a_whi,y
 sta hc_delta+1
 lda #0
 sbc #0
 sta hc_delta+2
 jsr hq_ratio_product
 ldy hc_from
 clc
 lda hc_a_wlo,y
 adc hc_result+0
 sta hc_out_w+0
 lda hc_a_whi,y
 adc hc_result+1
 sta hc_out_w+1
 rts
hp_block_perspective_span_end:
.if * > $cfb8
 .error "Q8 allocation overflow: perspective_span"
.endif

; Q8 block division
* = $1e60
hp_block_division_begin:
hc_div40:
 lda hc_divisor
 ora hc_divisor+1
 ora hc_divisor+2
 beq hp_unreachable
 lda #0
 ldx #3
hc_div_clear:
 sta hc_remainder,x
 dex
 bpl hc_div_clear
 ldy #48
dt_trim_bytes:
 lda hc_num+5
 bne dt_trim_bits
 jsr dp_shift_byte
 bne dt_trim_bytes
 rts ; zero numerator: quotient and remainder are zero
dt_trim_bits:
 lda hc_num+5
 bmi dp_prepare
 asl hc_num
 rol hc_num+1
 rol hc_num+2
 rol hc_num+3
 rol hc_num+4
 rol hc_num+5
 dey
 bne dt_trim_bits
 rts
dp_small_result:
 ; All N bits consumed, N<divisor: quotient0, exact remainderN.
 ldx #255
 rts
dp_prepare:
 ; X=bit_length(divisor)-1. Prefix of this length is necessarily <divisor.
 lda hc_divisor+2
 beq dp_mid
 ldx #23
 bne dp_bit_count
dp_mid:
 lda hc_divisor+1
 beq dp_low
 ldx #15
 bne dp_bit_count
dp_low:
 lda hc_divisor
 ldx #7
dp_bit_count:
 asl
 bcs dp_count_done
 dex
 bne dp_bit_count
dp_count_done:
 txa
 beq dp_ready
 cpx #8
 bcc dp_prefix
 cpy #8
 bcc dp_prefix
 lda hc_num+5
 sta hc_remainder
 txa
 sec
 sbc #8
 tax
 jsr dp_shift_byte
 beq dp_small_result
 txa
 beq dp_ready
dp_prefix:
 asl hc_num
 rol hc_num+1
 rol hc_num+2
 rol hc_num+3
 rol hc_num+4
 rol hc_num+5
 rol hc_remainder
 rol hc_remainder+1
 rol hc_remainder+2
 dey
 beq dp_small_result
 dex
 bne dp_prefix
dp_ready:
 ldx #255
hc_div_loop:
 asl hc_num
 rol hc_num+1
 rol hc_num+2
 rol hc_num+3
 rol hc_num+4
 rol hc_num+5
 rol hc_remainder
 rol hc_remainder+1
 rol hc_remainder+2
 rol hc_remainder+3
 lda hc_remainder+3
 bne hc_div_sub
 lda hc_remainder+2
 cmp hc_divisor+2
 bcc hc_div_next
 bne hc_div_sub
 lda hc_remainder+1
 cmp hc_divisor+1
 bcc hc_div_next
 bne hc_div_sub
 lda hc_remainder
 cmp hc_divisor
 bcc hc_div_next
hc_div_sub:
 sec
 lda hc_remainder
 sbc hc_divisor
 sta hc_remainder
 lda hc_remainder+1
 sbc hc_divisor+1
 sta hc_remainder+1
 lda hc_remainder+2
 sbc hc_divisor+2
 sta hc_remainder+2
 lda hc_remainder+3
 sbc #0
 sta hc_remainder+3
 inc hc_num
hc_div_next:
 dey
 bne hc_div_loop
 rts

hp_block_division_end:
.if * > $1f70
 .error "Q8 allocation overflow: division"
.endif

; Q8 block division_helper
* = $cfb8
hp_block_division_helper_begin:
dp_shift_byte:
 lda hc_num+4
 sta hc_num+5
 lda hc_num+3
 sta hc_num+4
 lda hc_num+2
 sta hc_num+3
 lda hc_num+1
 sta hc_num+2
 lda hc_num+0
 sta hc_num+1
 lda #0
 sta hc_num
 tya
 sec
 sbc #8
 tay
 rts
hp_block_division_helper_end:
.if * > $cfe9
 .error "Q8 allocation overflow: division_helper"
.endif

; Q8 block ratio_product
* = $9ece
hp_block_ratio_product_begin:
hq_ratio_product:
 lda hc_delta+2
 sta hc_sign
 bpl hq_delta_positive
 sec
 lda #0
 sbc hc_delta+0
 sta hc_delta+0
 lda #0
 sbc hc_delta+1
 sta hc_delta+1
 lda #0
 sbc hc_delta+2
 sta hc_delta+2
hq_delta_positive:
 lda hc_delta+0
 sta hc_shift+0
 lda hc_factor+0
 sta hc_value+0
 lda hc_den+0
 sta hc_divisor+0
 lda hc_delta+1
 sta hc_shift+1
 lda hc_factor+1
 sta hc_value+1
 lda hc_den+1
 sta hc_divisor+1
 lda hc_delta+2
 sta hc_shift+2
 lda hc_factor+2
 sta hc_value+2
 lda hc_den+2
 sta hc_divisor+2
 lda #0
 sta hc_num+0
 sta hc_num+1
 sta hc_num+2
 sta hc_num+3
 sta hc_num+4
 sta hc_num+5
 sta hc_shift+3
 sta hc_shift+4
 sta hc_shift+5
 ; Zero delta: quotient and remainder are zero. Use the existing divider
 ; nevertheless, so its denominator-zero fault and scratch contract survive.
 ; hc_value is private destructive scratch, not a caller-visible output.
 lda hc_shift
 ora hc_shift+1
 ora hc_shift+2
 beq hq_mul_done
 lda hc_shift+2
 ora hc_value+2
 beq n16_small
 ldy #1
 bne n16_ready
n16_small:
 ldy #0
n16_ready:
hq_mul_loop:
 lda hc_value
 ora hc_value+1
 ora hc_value+2
 beq hq_mul_done
 lsr hc_value+2
 ror hc_value+1
 ror hc_value
 bcc hq_mul_shift
 clc
 lda hc_num+0
 adc hc_shift+0
 sta hc_num+0
 lda hc_num+1
 adc hc_shift+1
 sta hc_num+1
 lda hc_num+2
 adc hc_shift+2
 sta hc_num+2
 lda hc_num+3
 adc hc_shift+3
 sta hc_num+3
 tya
 beq hq_mul_shift
 lda hc_num+4
 adc hc_shift+4
 sta hc_num+4
 lda hc_num+5
 adc hc_shift+5
 sta hc_num+5
hq_mul_shift:
 asl hc_shift
 rol hc_shift+1
 rol hc_shift+2
 rol hc_shift+3
 tya
 beq n16_shift_done
 rol hc_shift+4
 rol hc_shift+5
n16_shift_done:
 jmp hq_mul_loop
hq_mul_done:
 jsr hc_div40
 lda hc_num+0
 sta hc_result+0
 lda hc_num+1
 sta hc_result+1
 lda hc_num+2
 sta hc_result+2
 lda hc_sign
 bpl hq_ratio_done
 sec
 lda #0
 sbc hc_result+0
 sta hc_result+0
 lda #0
 sbc hc_result+1
 sta hc_result+1
 lda #0
 sbc hc_result+2
 sta hc_result+2
hq_ratio_done:
 rts
hp_block_ratio_product_end:
.if * > $9fff
 .error "Q8 allocation overflow: ratio_product"
.endif

; Q8 block portal_screen_placement
* = $56ae
hp_block_portal_screen_placement_begin:
hc_screen_pass:
 ldx hc_plane
 lda hc_bounds_lo,x
 sta hc_bound
 lda hc_bounds_hi,x
 sta hc_bound+1
 lda #0
 sta hc_bound+2
 lda #0
 sta hc_out_count
 sta hc_current
 lda hc_count
 sec
 sbc #1
 sta hc_previous
hc_screen_loop:
 ldx hc_previous
 jsr hc_screen_inside
 lda #0
 rol
 sta hc_prev_inside
 ldx hc_current
 jsr hc_screen_inside
 lda #0
 rol
 sta hc_cur_inside
 cmp hc_prev_inside
 beq hc_screen_no_cross
 lda #1
 sta hc_changed
 jsr hc_screen_intersection
 jsr hc_append_b
hc_screen_no_cross:
 lda hc_cur_inside
 beq hc_screen_outside
 ldx hc_current
 jsr hc_copy_a_to_out
 jsr hc_append_b
 jmp hc_screen_next
hc_screen_outside:
 lda #1
 sta hc_changed
hc_screen_next:
 lda hc_current
 sta hc_previous
 inc hc_current
 lda hc_current
 cmp hc_count
 bne hc_screen_loop
 jmp hc_copy_back
hc_bounds_lo: .byte 0,0,0,0
hc_bounds_hi: .byte 0,PROJ_SCREEN_MAX_X,0,PROJ_SCREEN_MAX_Y

hc_screen_coord:
 lda hc_plane
 cmp #2
 bcs hc_screen_coord_y
 lda hc_a_xlo,x
 sta hc_value
 lda hc_a_xhi,x
 sta hc_value+1
 lda hc_a_xext,x
 sta hc_value+2
 rts
hc_screen_coord_y:
 lda hc_a_ylo,x
 sta hc_value
 lda hc_a_yhi,x
 sta hc_value+1
 lda hc_a_yext,x
 sta hc_value+2
 rts
hc_screen_inside:
 jsr hc_screen_coord
 lda hc_plane
 and #1
 bne hc_screen_upper
 lda hc_value+2
 bmi hc_screen_no
 sec
 rts
hc_screen_upper:
 lda hc_value+2
 bmi hc_screen_yes
 bne hc_screen_no
 lda hc_value+1
 cmp hc_bound+1
 bcc hc_screen_yes
 bne hc_screen_no
 lda hc_value
 cmp hc_bound
 bcc hc_screen_yes
 beq hc_screen_yes
hc_screen_no:
 clc
 rts
hc_screen_yes:
 sec
 rts

hc_screen_intersection:
 ldx hc_previous
 ldy hc_current
 lda hc_prev_inside
 beq hc_screen_canonical
 ldx hc_current
 ldy hc_previous
hc_screen_canonical:
 stx hc_from
 sty hc_to
 jsr hc_screen_coord
 lda hc_value
 sta hc_base
 lda hc_value+1
 sta hc_base+1
 lda hc_value+2
 sta hc_base+2
 sec
 lda hc_bound
 sbc hc_base
 sta hc_factor
 lda hc_bound+1
 sbc hc_base+1
 sta hc_factor+1
 lda hc_bound+2
 sbc hc_base+2
 sta hc_factor+2
 ldx hc_to
 jsr hc_screen_coord
 sec
 lda hc_value
 sbc hc_base
 sta hc_den
 lda hc_value+1
 sbc hc_base+1
 sta hc_den+1
 lda hc_value+2
 sbc hc_base+2
 sta hc_den+2
 bpl hc_screen_ratio_ready
 sec
 lda #0
 sbc hc_den
 sta hc_den
 lda #0
 sbc hc_den+1
 sta hc_den+1
 lda #0
 sbc hc_den+2
 sta hc_den+2
 sec
 lda #0
 sbc hc_factor
 sta hc_factor
 lda #0
 sbc hc_factor+1
 sta hc_factor+1
 lda #0
 sbc hc_factor+2
 sta hc_factor+2
hc_screen_ratio_ready:
 jmp lab_axis
 .fill 3,$ea
lab_clip_resume:
.if MODE7_UV_CARRIER != 0
 jsr hc_interpolate_w
 jsr hc_interpolate_s
 jsr hc_interpolate_v
 jsr hc_interpolate_q
.else
 lda #0
 sta hc_out_s
 sta hc_out_s+1
.endif
 lda hc_plane
 cmp #2
 bcs hc_screen_lock_y
 lda hc_bound
 sta hc_out_x
 lda hc_bound+1
 sta hc_out_x+1
 lda hc_bound+2
 sta hc_out_x+2
 rts
hc_screen_lock_y:
 lda hc_bound
 sta hc_out_y
 lda hc_bound+1
 sta hc_out_y+1
 lda hc_bound+2
 sta hc_out_y+2
 rts

hc_commit_poly:
 lda hc_count
 sta clip_a_count
 lda #0
 sta hc_poly_index
hc_commit_loop:
 ldx hc_poly_index
.if MODE7_UV_CARRIER != 0
 lda hc_a_shi,x
 sta clip_a_shade,x
.endif
 lda #0
 sta hc_axis
 lda hc_a_xlo,x
 sta hc_q
 lda hc_a_xhi,x
 sta hc_q+1
 jsr hc_anchor
 ldx hc_poly_index
 sta clip_a_x,x
 lda #1
 sta hc_axis
 lda hc_a_ylo,x
 sta hc_q
 lda hc_a_yhi,x
 sta hc_q+1
 jsr hc_anchor
 ldx hc_poly_index
 sta clip_a_y,x
 inc hc_poly_index
 lda hc_poly_index
 cmp hc_count
 bne hc_commit_loop
 rts
hc_anchor:
 ; Exact center-relative integer anchor of already bounded Q2 coordinate.
 ldx hc_axis
 lda hc_q+1
 cmp hc_center_hi,x
 bcc hc_anchor_ceil
 bne hc_anchor_shift
 lda hc_q
 cmp hc_center_lo,x
 bcs hc_anchor_shift
hc_anchor_ceil:
 clc
 lda hc_q
 adc #3
 sta hc_q
 lda hc_q+1
 adc #0
 sta hc_q+1
hc_anchor_shift:
 lsr hc_q+1
 ror hc_q
 lsr hc_q+1
 ror hc_q
 lda hc_q
 rts

hp_needs_screen:
 ; Preserve existing conservative cull decision for wholly inside faces.
 ldy faceidx
 lda face0,y
 jsr hc_vertex_outside
 bne hc_needs_yes
 ldy faceidx
 lda face1,y
 jsr hc_vertex_outside
 bne hc_needs_yes
 ldy faceidx
 lda face2,y
 jsr hc_vertex_outside
 bne hc_needs_yes
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #4
 bne hc_needs_no
.endif
 ldy faceidx
 lda face3,y
 jsr hc_vertex_outside
 rts
hc_needs_no:
 lda #0
 rts
hc_needs_yes:
 lda #1
 rts
hc_vertex_outside:
 tax
 lda projdone,x
 beq hc_needs_yes
 lda sxq2_hi,x
 bmi hc_needs_yes
 cmp #>(PROJ_SCREEN_MAX_X*4)
 bcc hc_outside_test_y
 bne hc_needs_yes
 lda sxq2_lo,x
 cmp #<(PROJ_SCREEN_MAX_X*4+1)
 bcs hc_needs_yes
hc_outside_test_y:
 lda syq2_hi,x
 bmi hc_needs_yes
 cmp #>(PROJ_SCREEN_MAX_Y*4)
 bcc hc_needs_no
 bne hc_needs_yes
 lda syq2_lo,x
 cmp #<(PROJ_SCREEN_MAX_Y*4+1)
 bcs hc_needs_yes
 lda #0
 rts
hp_block_portal_screen_placement_end:
.if * > $595b
 .error "Q8 allocation overflow: portal_screen_placement"
.endif

*=$e200
lab_begin:
lab_init_irq:
 lda #<lab_irq_entry
 sta $fffe
 lda #>lab_irq_entry
 sta $ffff
 lda #<lab_nmi
 sta $fffa
 lda #>lab_nmi
 sta $fffb
 jmp init_irq
lab_irq_entry:
 pha
 txa
 pha
 tya
 pha
 jmp raster_irq
lab_irq_exit:
 pla
 tay
 pla
 tax
 pla
lab_nmi:
 rti
lab_axis:
 lda hc_plane
 cmp #2
 bcs lab_clip_y
 jsr hc_interpolate_y
 jmp lab_clip_resume
lab_clip_y:
 jsr hc_interpolate_x
 jmp lab_clip_resume
lab_end:
.if * > $ff00
 .error "Experimental kernels overlap vectors/reserve"
.endif
fx_full_byte:
 lda m7_sample
 cmp #$20
 beq fx_textured
 jsr m7_sample ; exact uniform patched entry
 jmp fx_old_after_first
fx_textured:
 lda #0
 sta $f7
 lda m7_fetch+2
 sta $f8
 lda bk_count
 bne fx0_cached
 jsr ps_sample ; original block seed, prediction, quotient and short tail
 lda m7_v
 jmp fx0_address
fx0_cached:
 lda bk_cur1
 sta m7_u
 lda bk_cur1+1
 sta m7_v
fx0_address:
 asl
 asl
 asl
 and #$f0
 sta m7_index
 lda m7_u
 lsr
 and #$0f
 ora m7_index
 tay
 lda ($f7),y
fx0_m3_composite:
 sta m3_base
 ldx m3_qcur
 cpx #10
 bcc fx0_m31_c_low
 cpx #23
 bcc fx0_m31_c_return
 cmp #3
 beq fx0_m31_c_return
 cpx #26
 bcs fx0_m31_c_bright
 txa
 sec
 sbc #22
 jmp fx0_m31_c_transition
fx0_m31_c_low:
 cmp #1
 beq fx0_m31_c_return
 dec m3_base
 cpx #7
 bcc fx0_m31_c_stable
 txa
 sec
 sbc #6
fx0_m31_c_transition:
 asl
 asl
 sta m3_threshold
 lda gouraud_scan_x
 and #3
 ora m2_bayer_row
 tay
 lda m3_threshold
 cmp m2_bayer,y
 lda m3_base
 adc #0
fx0_m31_c_return:
 jmp fx0_composite_done
fx0_m31_c_bright:
 inc m3_base
fx0_m31_c_stable:
 lda m3_base
 jmp fx0_composite_done
fx0_composite_done:
 asl
 asl
 asl
 asl
 asl
 asl
 sta m7_packed
fx0_ps_advance:
 lda bk_count
 bne fx0_ca_block
 jsr bk_exact_advance
 jmp fx0_advance_done
fx0_ca_block:
 dec bk_count
 bne fx0_ca_shade
 stx ps_saved_x
 ldx #2
fx0_ca_commit:
 lda bk_look0,x
 sta ps_cur0,x
 lda bk_look1,x
 sta ps_cur1,x
 lda ca_lookerr,x
 sta ps_err,x
 dex
 bpl fx0_ca_commit
 ldx ps_saved_x
fx0_ca_shade:
fx0_m3_advance_q:
 clc
 lda m3_qcur
 adc m3_qstep
 sta m3_qcur
 clc
 lda m3_qerr
 adc m3_qrem
 bcs fx0_m3_q_correct
 cmp m7_den
 bcc fx0_m3_q_store
fx0_m3_q_correct:
 sec
 sbc m7_den
 sta m3_qerr
 clc
 lda m3_qcur
 adc m3_qdir
 sta m3_qcur
 jmp fx0_shade_done
fx0_m3_q_store:
 sta m3_qerr
 jmp fx0_shade_done
fx0_shade_done:
 inc gouraud_scan_x
 clc
 lda bk_cur0+0
 adc bk_step0+0
 sta bk_cur0+0
 lda bk_cur1+0
 adc bk_step1+0
 sta bk_cur1+0
 clc
 lda bk_cur0+1
 adc bk_step0+1
 sta bk_cur0+1
 lda bk_cur1+1
 adc bk_step1+1
 sta bk_cur1+1
fx0_advance_done:
 lda bk_count
 bne fx1_cached
 jsr ps_sample ; original block seed, prediction, quotient and short tail
 lda m7_v
 jmp fx1_address
fx1_cached:
 lda bk_cur1
 sta m7_u
 lda bk_cur1+1
 sta m7_v
fx1_address:
 asl
 asl
 asl
 and #$f0
 sta m7_index
 lda m7_u
 lsr
 and #$0f
 ora m7_index
 tay
 lda ($f7),y
fx1_m3_composite:
 sta m3_base
 ldx m3_qcur
 cpx #10
 bcc fx1_m31_c_low
 cpx #23
 bcc fx1_m31_c_return
 cmp #3
 beq fx1_m31_c_return
 cpx #26
 bcs fx1_m31_c_bright
 txa
 sec
 sbc #22
 jmp fx1_m31_c_transition
fx1_m31_c_low:
 cmp #1
 beq fx1_m31_c_return
 dec m3_base
 cpx #7
 bcc fx1_m31_c_stable
 txa
 sec
 sbc #6
fx1_m31_c_transition:
 asl
 asl
 sta m3_threshold
 lda gouraud_scan_x
 and #3
 ora m2_bayer_row
 tay
 lda m3_threshold
 cmp m2_bayer,y
 lda m3_base
 adc #0
fx1_m31_c_return:
 jmp fx1_composite_done
fx1_m31_c_bright:
 inc m3_base
fx1_m31_c_stable:
 lda m3_base
 jmp fx1_composite_done
fx1_composite_done:
 asl
 asl
 asl
 asl
 ora m7_packed
 sta m7_packed
fx1_ps_advance:
 lda bk_count
 bne fx1_ca_block
 jsr bk_exact_advance
 jmp fx1_advance_done
fx1_ca_block:
 dec bk_count
 bne fx1_ca_shade
 stx ps_saved_x
 ldx #2
fx1_ca_commit:
 lda bk_look0,x
 sta ps_cur0,x
 lda bk_look1,x
 sta ps_cur1,x
 lda ca_lookerr,x
 sta ps_err,x
 dex
 bpl fx1_ca_commit
 ldx ps_saved_x
fx1_ca_shade:
fx1_m3_advance_q:
 clc
 lda m3_qcur
 adc m3_qstep
 sta m3_qcur
 clc
 lda m3_qerr
 adc m3_qrem
 bcs fx1_m3_q_correct
 cmp m7_den
 bcc fx1_m3_q_store
fx1_m3_q_correct:
 sec
 sbc m7_den
 sta m3_qerr
 clc
 lda m3_qcur
 adc m3_qdir
 sta m3_qcur
 jmp fx1_shade_done
fx1_m3_q_store:
 sta m3_qerr
 jmp fx1_shade_done
fx1_shade_done:
 inc gouraud_scan_x
 clc
 lda bk_cur0+0
 adc bk_step0+0
 sta bk_cur0+0
 lda bk_cur1+0
 adc bk_step1+0
 sta bk_cur1+0
 clc
 lda bk_cur0+1
 adc bk_step0+1
 sta bk_cur0+1
 lda bk_cur1+1
 adc bk_step1+1
 sta bk_cur1+1
fx1_advance_done:
 lda bk_count
 bne fx2_cached
 jsr ps_sample ; original block seed, prediction, quotient and short tail
 lda m7_v
 jmp fx2_address
fx2_cached:
 lda bk_cur1
 sta m7_u
 lda bk_cur1+1
 sta m7_v
fx2_address:
 asl
 asl
 asl
 and #$f0
 sta m7_index
 lda m7_u
 lsr
 and #$0f
 ora m7_index
 tay
 lda ($f7),y
fx2_m3_composite:
 sta m3_base
 ldx m3_qcur
 cpx #10
 bcc fx2_m31_c_low
 cpx #23
 bcc fx2_m31_c_return
 cmp #3
 beq fx2_m31_c_return
 cpx #26
 bcs fx2_m31_c_bright
 txa
 sec
 sbc #22
 jmp fx2_m31_c_transition
fx2_m31_c_low:
 cmp #1
 beq fx2_m31_c_return
 dec m3_base
 cpx #7
 bcc fx2_m31_c_stable
 txa
 sec
 sbc #6
fx2_m31_c_transition:
 asl
 asl
 sta m3_threshold
 lda gouraud_scan_x
 and #3
 ora m2_bayer_row
 tay
 lda m3_threshold
 cmp m2_bayer,y
 lda m3_base
 adc #0
fx2_m31_c_return:
 jmp fx2_composite_done
fx2_m31_c_bright:
 inc m3_base
fx2_m31_c_stable:
 lda m3_base
 jmp fx2_composite_done
fx2_composite_done:
 asl
 asl
 ora m7_packed
 sta m7_packed
fx2_ps_advance:
 lda bk_count
 bne fx2_ca_block
 jsr bk_exact_advance
 jmp fx2_advance_done
fx2_ca_block:
 dec bk_count
 bne fx2_ca_shade
 stx ps_saved_x
 ldx #2
fx2_ca_commit:
 lda bk_look0,x
 sta ps_cur0,x
 lda bk_look1,x
 sta ps_cur1,x
 lda ca_lookerr,x
 sta ps_err,x
 dex
 bpl fx2_ca_commit
 ldx ps_saved_x
fx2_ca_shade:
fx2_m3_advance_q:
 clc
 lda m3_qcur
 adc m3_qstep
 sta m3_qcur
 clc
 lda m3_qerr
 adc m3_qrem
 bcs fx2_m3_q_correct
 cmp m7_den
 bcc fx2_m3_q_store
fx2_m3_q_correct:
 sec
 sbc m7_den
 sta m3_qerr
 clc
 lda m3_qcur
 adc m3_qdir
 sta m3_qcur
 jmp fx2_shade_done
fx2_m3_q_store:
 sta m3_qerr
 jmp fx2_shade_done
fx2_shade_done:
 inc gouraud_scan_x
 clc
 lda bk_cur0+0
 adc bk_step0+0
 sta bk_cur0+0
 lda bk_cur1+0
 adc bk_step1+0
 sta bk_cur1+0
 clc
 lda bk_cur0+1
 adc bk_step0+1
 sta bk_cur0+1
 lda bk_cur1+1
 adc bk_step1+1
 sta bk_cur1+1
fx2_advance_done:
 lda bk_count
 bne fx3_cached
 jsr ps_sample ; original block seed, prediction, quotient and short tail
 lda m7_v
 jmp fx3_address
fx3_cached:
 lda bk_cur1
 sta m7_u
 lda bk_cur1+1
 sta m7_v
fx3_address:
 asl
 asl
 asl
 and #$f0
 sta m7_index
 lda m7_u
 lsr
 and #$0f
 ora m7_index
 tay
 lda ($f7),y
fx3_m3_composite:
 sta m3_base
 ldx m3_qcur
 cpx #10
 bcc fx3_m31_c_low
 cpx #23
 bcc fx3_m31_c_return
 cmp #3
 beq fx3_m31_c_return
 cpx #26
 bcs fx3_m31_c_bright
 txa
 sec
 sbc #22
 jmp fx3_m31_c_transition
fx3_m31_c_low:
 cmp #1
 beq fx3_m31_c_return
 dec m3_base
 cpx #7
 bcc fx3_m31_c_stable
 txa
 sec
 sbc #6
fx3_m31_c_transition:
 asl
 asl
 sta m3_threshold
 lda gouraud_scan_x
 and #3
 ora m2_bayer_row
 tay
 lda m3_threshold
 cmp m2_bayer,y
 lda m3_base
 adc #0
fx3_m31_c_return:
 jmp fx3_composite_done
fx3_m31_c_bright:
 inc m3_base
fx3_m31_c_stable:
 lda m3_base
 jmp fx3_composite_done
fx3_composite_done:
 ora m7_packed
 jmp m7_full_write
es_setup_channel:
 lda #1
 jsr tq_product
 ldx #2
es_save_q:
 lda hc_result,x
 sta es_q,x
 dex
 bpl es_save_q
 lda hc_remainder
 sta es_r
 lda hc_remainder+1
 sta es_r+1
 lda tq_pre
 jsr es_scale
 ldx tq_ch
 clc
 lda hc_result
 adc tq_start
 sta tq_cur0,x
 lda hc_result+1
 adc tq_start+1
 sta tq_cur1,x
 lda hc_result+2
 adc tq_start+2
 sta tq_cur2,x
 lda hc_remainder
 sta tq_err0,x
 lda hc_remainder+1
 sta tq_err1,x
 lda #4
 jsr es_scale
 ldx tq_ch
 lda hc_result
 sta tq_step0,x
 lda hc_result+1
 sta tq_step1,x
 lda hc_result+2
 sta tq_step2,x
 lda hc_remainder
 sta tq_rem0,x
 lda hc_remainder+1
 sta tq_rem1,x
 rts

es_scale:
 sta es_count
 lda #0
 sta hc_result
 sta hc_result+1
 sta hc_result+2
 sta hc_remainder
 sta hc_remainder+1
 lda es_count
 beq es_done
es_loop:
 clc
 lda hc_result
 adc es_q
 sta hc_result
 lda hc_result+1
 adc es_q+1
 sta hc_result+1
 lda hc_result+2
 adc es_q+2
 sta hc_result+2
 clc
 lda hc_remainder
 adc es_r
 sta hc_remainder
 lda hc_remainder+1
 adc es_r+1
 sta hc_remainder+1
 bcs es_correct
 cmp tq_dy+1
 bcc es_next
 bne es_correct
 lda hc_remainder
 cmp tq_dy
 bcc es_next
es_correct:
 sec
 lda hc_remainder
 sbc tq_dy
 sta hc_remainder
 lda hc_remainder+1
 sbc tq_dy+1
 sta hc_remainder+1
 inc hc_result
 bne es_next
 inc hc_result+1
 bne es_next
 inc hc_result+2
es_next:
 dec es_count
 bne es_loop
es_done:
 rts
es_q: .fill 3,0
es_r: .word 0
es_count: .byte 0
lab_all_end:
.if * > $ff00
 .error "Experimental code/tables overlap vectors/reserve"
.endif

*=$efd0
uz_begin:
uz_pair:
 lda ps_den
 ora ps_den+1
 beq uz_fallback
 lda ps_den
 sta uz_denlo
 lda ps_den+1
 sta uz_denhi
 ldx #1
uz_init:
 lda up_inputlo,x
 sta uz_remlo,x
 lda up_inputhi,x
 sta uz_remhi,x
 lda #0
 sta uz_quotient,x
 lda uz_remhi,x
 cmp uz_denhi
 bcc uz_init_next
 bne uz_initial_sub
 lda uz_remlo,x
 cmp uz_denlo
 bcc uz_init_next
uz_initial_sub:
 sec
 lda uz_remlo,x
 sbc uz_denlo
 sta uz_remlo,x
 lda uz_remhi,x
 sbc uz_denhi
 sta uz_remhi,x
 lda #128
 sta uz_quotient,x
 lda uz_remhi,x
 cmp uz_denhi
 bcc uz_init_next
 bne uz_fallback
 lda uz_remlo,x
 cmp uz_denlo
 bcs uz_fallback
uz_init_next:
 dex
 bpl uz_init
 asl uz_remlo
 rol uz_remhi
 bcs uz_b0_u_sub
 lda uz_remhi
 cmp uz_denhi
 bcc uz_b0_u_next
 bne uz_b0_u_sub
 lda uz_remlo
 cmp uz_denlo
 bcc uz_b0_u_next
uz_b0_u_sub:
 sec
 lda uz_remlo
 sbc uz_denlo
 sta uz_remlo
 lda uz_remhi
 sbc uz_denhi
 sta uz_remhi
 lda uz_quotient
 ora #64
 sta uz_quotient
uz_b0_u_next:
 asl uz_remlo+1
 rol uz_remhi+1
 bcs uz_b0_v_sub
 lda uz_remhi+1
 cmp uz_denhi
 bcc uz_b0_v_next
 bne uz_b0_v_sub
 lda uz_remlo+1
 cmp uz_denlo
 bcc uz_b0_v_next
uz_b0_v_sub:
 sec
 lda uz_remlo+1
 sbc uz_denlo
 sta uz_remlo+1
 lda uz_remhi+1
 sbc uz_denhi
 sta uz_remhi+1
 lda uz_quotient+1
 ora #64
 sta uz_quotient+1
uz_b0_v_next:
 asl uz_remlo
 rol uz_remhi
 bcs uz_b1_u_sub
 lda uz_remhi
 cmp uz_denhi
 bcc uz_b1_u_next
 bne uz_b1_u_sub
 lda uz_remlo
 cmp uz_denlo
 bcc uz_b1_u_next
uz_b1_u_sub:
 sec
 lda uz_remlo
 sbc uz_denlo
 sta uz_remlo
 lda uz_remhi
 sbc uz_denhi
 sta uz_remhi
 lda uz_quotient
 ora #32
 sta uz_quotient
uz_b1_u_next:
 asl uz_remlo+1
 rol uz_remhi+1
 bcs uz_b1_v_sub
 lda uz_remhi+1
 cmp uz_denhi
 bcc uz_b1_v_next
 bne uz_b1_v_sub
 lda uz_remlo+1
 cmp uz_denlo
 bcc uz_b1_v_next
uz_b1_v_sub:
 sec
 lda uz_remlo+1
 sbc uz_denlo
 sta uz_remlo+1
 lda uz_remhi+1
 sbc uz_denhi
 sta uz_remhi+1
 lda uz_quotient+1
 ora #32
 sta uz_quotient+1
uz_b1_v_next:
 asl uz_remlo
 rol uz_remhi
 bcs uz_b2_u_sub
 lda uz_remhi
 cmp uz_denhi
 bcc uz_b2_u_next
 bne uz_b2_u_sub
 lda uz_remlo
 cmp uz_denlo
 bcc uz_b2_u_next
uz_b2_u_sub:
 sec
 lda uz_remlo
 sbc uz_denlo
 sta uz_remlo
 lda uz_remhi
 sbc uz_denhi
 sta uz_remhi
 lda uz_quotient
 ora #16
 sta uz_quotient
uz_b2_u_next:
 asl uz_remlo+1
 rol uz_remhi+1
 bcs uz_b2_v_sub
 lda uz_remhi+1
 cmp uz_denhi
 bcc uz_b2_v_next
 bne uz_b2_v_sub
 lda uz_remlo+1
 cmp uz_denlo
 bcc uz_b2_v_next
uz_b2_v_sub:
 sec
 lda uz_remlo+1
 sbc uz_denlo
 sta uz_remlo+1
 lda uz_remhi+1
 sbc uz_denhi
 sta uz_remhi+1
 lda uz_quotient+1
 ora #16
 sta uz_quotient+1
uz_b2_v_next:
 asl uz_remlo
 rol uz_remhi
 bcs uz_b3_u_sub
 lda uz_remhi
 cmp uz_denhi
 bcc uz_b3_u_next
 bne uz_b3_u_sub
 lda uz_remlo
 cmp uz_denlo
 bcc uz_b3_u_next
uz_b3_u_sub:
 sec
 lda uz_remlo
 sbc uz_denlo
 sta uz_remlo
 lda uz_remhi
 sbc uz_denhi
 sta uz_remhi
 lda uz_quotient
 ora #8
 sta uz_quotient
uz_b3_u_next:
 asl uz_remlo+1
 rol uz_remhi+1
 bcs uz_b3_v_sub
 lda uz_remhi+1
 cmp uz_denhi
 bcc uz_b3_v_next
 bne uz_b3_v_sub
 lda uz_remlo+1
 cmp uz_denlo
 bcc uz_b3_v_next
uz_b3_v_sub:
 sec
 lda uz_remlo+1
 sbc uz_denlo
 sta uz_remlo+1
 lda uz_remhi+1
 sbc uz_denhi
 sta uz_remhi+1
 lda uz_quotient+1
 ora #8
 sta uz_quotient+1
uz_b3_v_next:
 asl uz_remlo
 rol uz_remhi
 bcs uz_b4_u_sub
 lda uz_remhi
 cmp uz_denhi
 bcc uz_b4_u_next
 bne uz_b4_u_sub
 lda uz_remlo
 cmp uz_denlo
 bcc uz_b4_u_next
uz_b4_u_sub:
 sec
 lda uz_remlo
 sbc uz_denlo
 sta uz_remlo
 lda uz_remhi
 sbc uz_denhi
 sta uz_remhi
 lda uz_quotient
 ora #4
 sta uz_quotient
uz_b4_u_next:
 asl uz_remlo+1
 rol uz_remhi+1
 bcs uz_b4_v_sub
 lda uz_remhi+1
 cmp uz_denhi
 bcc uz_b4_v_next
 bne uz_b4_v_sub
 lda uz_remlo+1
 cmp uz_denlo
 bcc uz_b4_v_next
uz_b4_v_sub:
 sec
 lda uz_remlo+1
 sbc uz_denlo
 sta uz_remlo+1
 lda uz_remhi+1
 sbc uz_denhi
 sta uz_remhi+1
 lda uz_quotient+1
 ora #4
 sta uz_quotient+1
uz_b4_v_next:
 asl uz_remlo
 rol uz_remhi
 bcs uz_b5_u_sub
 lda uz_remhi
 cmp uz_denhi
 bcc uz_b5_u_next
 bne uz_b5_u_sub
 lda uz_remlo
 cmp uz_denlo
 bcc uz_b5_u_next
uz_b5_u_sub:
 sec
 lda uz_remlo
 sbc uz_denlo
 sta uz_remlo
 lda uz_remhi
 sbc uz_denhi
 sta uz_remhi
 lda uz_quotient
 ora #2
 sta uz_quotient
uz_b5_u_next:
 asl uz_remlo+1
 rol uz_remhi+1
 bcs uz_b5_v_sub
 lda uz_remhi+1
 cmp uz_denhi
 bcc uz_b5_v_next
 bne uz_b5_v_sub
 lda uz_remlo+1
 cmp uz_denlo
 bcc uz_b5_v_next
uz_b5_v_sub:
 sec
 lda uz_remlo+1
 sbc uz_denlo
 sta uz_remlo+1
 lda uz_remhi+1
 sbc uz_denhi
 sta uz_remhi+1
 lda uz_quotient+1
 ora #2
 sta uz_quotient+1
uz_b5_v_next:
 asl uz_remlo
 rol uz_remhi
 bcs uz_b6_u_sub
 lda uz_remhi
 cmp uz_denhi
 bcc uz_b6_u_next
 bne uz_b6_u_sub
 lda uz_remlo
 cmp uz_denlo
 bcc uz_b6_u_next
uz_b6_u_sub:
 sec
 lda uz_remlo
 sbc uz_denlo
 sta uz_remlo
 lda uz_remhi
 sbc uz_denhi
 sta uz_remhi
 lda uz_quotient
 ora #1
 sta uz_quotient
uz_b6_u_next:
 asl uz_remlo+1
 rol uz_remhi+1
 bcs uz_b6_v_sub
 lda uz_remhi+1
 cmp uz_denhi
 bcc uz_b6_v_next
 bne uz_b6_v_sub
 lda uz_remlo+1
 cmp uz_denlo
 bcc uz_b6_v_next
uz_b6_v_sub:
 sec
 lda uz_remlo+1
 sbc uz_denlo
 sta uz_remlo+1
 lda uz_remhi+1
 sbc uz_denhi
 sta uz_remhi+1
 lda uz_quotient+1
 ora #1
 sta uz_quotient+1
uz_b6_v_next:
 lda uz_quotient
 sta m7_u
 lda uz_quotient+1
 sta m7_v
 clc
 ldy #0
 rts
uz_fallback:
 jmp up_fallback
uz_remlo = $e8
uz_remhi = $ea
uz_denlo = $ec
uz_denhi = $ed
uz_quotient = $ee
uz_end:
uz_all_end:
 .cerror * > $f260,"UV kernel exceeds original high slot"
