"""Asset-free fixed-point scene dynamics and compiler reference contracts.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
No AI, scene, model, route, material palette or music is bundled here.
Native support is emitted by work/runtime_support_native.py; these functions
are also independent correctness oracles, never emulated FPS measurements.
"""
from dataclasses import dataclass
import math


def integer(value, lo, hi, name='value'):
    if type(value) is not int or not lo <= value <= hi:
        raise ValueError(f'{name}: integer {lo}..{hi} required')
    return value


def signed(value, bits=16):
    integer(bits, 2, 32, 'bits')
    value &= (1 << bits)-1
    return value-(1 << bits) if value & (1 << (bits-1)) else value


def smooth(value, target, shift=3, *, angular=False):
    """Signed16 Q8 filter. Linear overflow snaps, angular errors wrap shortest.

    Tiny residuals snap to target, avoiding one-sided arithmetic-shift drift.
    Exactly half a turn takes the negative direction, by signed16 convention.
    """
    integer(value, -32768, 32767);integer(target, -32768, 32767)
    integer(shift, 1, 7, 'shift')
    difference = signed(target-value) if angular else target-value
    if not angular and not -32768 <= difference <= 32767:
        return target
    if abs(difference) < 1 << shift:
        return target
    return signed(value+(difference >> shift))


def easing_table(steps=64, scale=256):
    integer(steps, 2, 255, 'steps');integer(scale, 1, 32767, 'scale')
    return [round((1-math.cos(math.pi*i/steps))*scale/2) for i in range(steps+1)]


@dataclass
class Hysteresis:
    enter: int
    leave: int
    active: bool = False

    def __post_init__(self):
        integer(self.enter, 0, 32766);integer(self.leave, self.enter+1, 32767)

    def update(self, distance):
        integer(distance, 0, 32767, 'distance')
        self.active = distance <= (self.leave if self.active else self.enter)
        return self.active


def sphere_outside(center, radius, focal, half_width=80, half_height=50, near=8):
    """Conservative sphere-vs-frustum using a containing axis-aligned box.

    All quantities use one common integer spatial scale. L1 plane support is
    deliberately looser than Euclidean support, never rejects a visible sphere.
    A one-logical-pixel side margin protects rounded native raster coverage.
    """
    if len(center) != 3:
        raise ValueError('Three camera-space coordinates required')
    x, y, z = center
    integer(radius, 0, 32767, 'radius');integer(focal, 1, 255, 'focal')
    if z+radius < near:
        return True
    if z+radius <= 0:
        return False
    return ((abs(x)-radius)*focal > (z+radius)*(half_width+1) or
            (abs(y)-radius)*focal > (z+radius)*(half_height+1))


def rebase(channels, delta):
    """Translate every registered signed16 channel by the same Q8 offset.

    Channels include render, physics, projectiles, particles AND camera. The
    operation preserves relative coordinates modulo16 bits. The application
    must retire distant objects before signed16 local-range ambiguity arises.
    """
    integer(delta, -32768, 32767, 'delta')
    return [[signed(value-delta) for value in channel] for channel in channels]


def grid_anchor(position, spacing):
    """World-locked repeating grid: one square lattice, including negative cells.

    Camera/world position selects a snapped origin; topology is application data.
    Use this same anchor for both axes and avoid a second screen-space lattice.
    """
    integer(spacing,1,32767,'spacing')
    if len(position)!=2:raise ValueError('Two ground-plane coordinates required')
    return tuple((v//spacing)*spacing for v in position)


def lfsr16(state):
    integer(state, 1, 65535, 'nonzero seed')
    result = (state >> 1) ^ (0xb400 if state & 1 else 0)
    return result, (result ^ (result >> 8)) & 255


def sphere_sample(state, attempts=8):
    """Bounded rejection inside radius31, matching the native cosmetic stream."""
    integer(attempts, 1, 32, 'attempts')
    for _ in range(attempts):
        point = []
        for _ in range(3):
            state, value = lfsr16(state);point.append((value & 63)-31)
        if sum(v*v for v in point) <= 31*31:
            return state, tuple(point)
    return state, (0, 0, 0)


def advance_particles(positions, velocities, lives):
    if not len(positions) == len(velocities) == len(lives):
        raise ValueError('Particle arrays must match')
    result = []
    for position, velocity, life in zip(positions, velocities, lives):
        if len(position) != 3 or len(velocity) != 3:
            raise ValueError('Three particle axes required')
        integer(life, 0, 255)
        result.append(tuple(signed(p+v) for p, v in zip(position, velocity)) if life else tuple(position))
    return result, [max(0, life-1) for life in lives]


def convex_polygon(points):
    if not isinstance(points, (list, tuple)) or not 3 <= len(points) <= 16:
        raise ValueError('Convex collider requires3..16 vertices')
    result = [tuple(p) for p in points]
    if any(len(p) != 2 for p in result) or len(set(result)) != len(result):
        raise ValueError('Distinct planar vertices required')
    signs = []
    # Every other point must lie on the same side of every ordered edge.
    # Consecutive turns alone also accept self-intersecting star polygons.
    for a, b in zip(result, result[1:]+result[:1]):
        for c in result:
            cross = (b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
            if cross:
                signs.append(cross > 0)
    if not signs or len(set(signs)) != 1:
        raise ValueError('Nondegenerate ordered convex polygon required')
    return result


def sat_overlap(a, b, cached_axis=None):
    """Exact integer planar SAT; touching counts as contact.

    Returns (contact, separating_axis). A previous separating axis can reject
    immediately but cannot prove contact; every edge axis is then checked.
    """
    a, b = convex_polygon(a), convex_polygon(b)
    axes = [] if cached_axis is None else [cached_axis]
    for poly in (a, b):
        axes += [(-(q[1]-p[1]), q[0]-p[0]) for p, q in zip(poly, poly[1:]+poly[:1])]
    for nx, nz in axes:
        if nx == nz == 0:
            continue
        pa = [nx*x+nz*z for x, z in a];pb = [nx*x+nz*z for x, z in b]
        if max(pa) < min(pb) or max(pb) < min(pa):
            return False, (nx, nz)
    return True, None


def broad_aabb(a, b):
    """Inclusive cheap bound test before SAT, independent of render visibility."""
    return all(min(p[i] for p in a) <= max(p[i] for p in b) and
               min(p[i] for p in b) <= max(p[i] for p in a) for i in (0, 1))


def solve_bounded(state, query, resolve, *, passes=8, pair_budget=1024, priority=None):
    """Generic bounded sequential contact controller, callback-owned bodies.

    Snapshot/restore positions through state['positions']; callbacks own collider
    data and response. Exhaustion rolls back all positions and damps velocities,
    as an explicit stability policy, without silently disabling player pairs.
    No FPS or host-time based adaptive behavior is involved.
    """
    integer(passes, 1, 32, 'passes');integer(pair_budget, 1, 65535, 'pair_budget')
    count = len(state['positions']);integer(count, 2, 32, 'bodies')
    original = [tuple(p) for p in state['positions']]
    pairs = [(a, b) for a in range(count) for b in range(a+1, count)]
    if priority is not None:
        integer(priority, 0, count-1, 'priority');pairs.sort(key=lambda pair: priority not in pair)
    used = 0
    for iteration in range(passes):
        changed = False
        for a, b in pairs:
            if used == pair_budget:
                break
            used += 1
            if query(a, b):
                resolve(a, b);changed = True
        else:
            if not changed:
                return dict(converged=True, queries=used, passes=iteration+1, rolledBack=False)
            continue
        break
    state['positions'] = original
    if 'velocities' in state:
        state['velocities'] = [tuple(v >> 1 for v in velocity) for velocity in state['velocities']]
    return dict(converged=False, queries=used, passes=iteration+1, rolledBack=True)


def binary_fragment_scales(parent_volume, child_volumes, fraction=.5):
    """Host compiler: inexpensive runtime scales from actual template volumes.

    Shapes are supplied by the application. This is volume-aware model selection,
    not a claim of arbitrary mesh cutting or exact continuous fracture physics.
    """
    if len(child_volumes) != 2 or not all(math.isfinite(v) and v > 0 for v in (parent_volume, *child_volumes)):
        raise ValueError('Positive finite parent and two template volumes required')
    if not isinstance(fraction, (int, float)) or not 0 < fraction < 1:
        raise ValueError('Mass fraction must lie strictly between0 and1')
    return tuple((parent_volume*weight/volume)**(1/3) for weight, volume in zip((fraction, 1-fraction), child_volumes))


def fragment_choices(parent_id, children, state):
    """Two distinct child templates, neither identical to the parent template."""
    candidates = list(dict.fromkeys(x for x in children if x != parent_id))
    if len(candidates) < 2:
        raise ValueError('Two distinct non-parent templates required')
    state, r = lfsr16(state);first = candidates.pop(r % len(candidates))
    state, r = lfsr16(state)
    return state, (first, candidates[r % len(candidates)])


def mesh_volume(vertices, faces):
    """Absolute oriented volume of a closed, consistently wound polygon mesh."""
    edges={};total=0
    if not vertices or not faces or any(len(v)!=3 or not all(math.isfinite(x) for x in v) for v in vertices):
        raise ValueError('Finite3D mesh required')
    for face in faces:
        if len(face) not in (3,4) or len(set(face))!=len(face):raise ValueError('Triangles/quads required')
        for i in face:integer(i,0,len(vertices)-1,'vertex index')
        for a,b in zip(face,face[1:]+face[:1]):edges[a,b]=edges.get((a,b),0)+1
        a=vertices[face[0]]
        for i in range(1,len(face)-1):
            b,c=vertices[face[i]],vertices[face[i+1]]
            total+=sum(a[k]*(b[(k+1)%3]*c[(k+2)%3]-b[(k+2)%3]*c[(k+1)%3]) for k in range(3))/6
    if any(n!=1 or edges.get((b,a))!=1 for (a,b),n in edges.items()) or abs(total)<1e-9:
        raise ValueError('Closed consistently wound nonzero mesh required')
    return abs(total)


def fragment_plan(parent, children, volumes, scale_q6=64, fraction=.5):
    """Compile two Q6 scales; report quantization error, never silently clamp.

    Application supplies models/volumes. Children start near the same origin;
    separation and mass-balanced impulses use fragment_spawn, with a grace timer.
    """
    integer(scale_q6,1,255,'parent scale')
    if len(children)!=2 or len(set(children))!=2 or parent in children:
        raise ValueError('Two distinct non-parent children required')
    scaled=volumes[parent]*(scale_q6/64)**3
    ratios=binary_fragment_scales(scaled,[volumes[i] for i in children],fraction)
    scales=[round(r*64) for r in ratios]
    for s in scales:integer(s,1,255,'representable Q6 child scale')
    actual=sum(volumes[i]*(s/64)**3 for i,s in zip(children,scales))
    return dict(children=list(children),scales=scales,relativeVolumeError=actual/scaled-1,
                parentVolume=scaled,childVolume=actual)


def fragment_spawn(position, velocity, axis, *, fraction=.5, separation=.25, impulse=1, grace=8):
    """Mass-balanced COM positions/velocities; bounded initial separation.

    Grace is metadata for caller-owned sibling collision eligibility. It never
    disables projectile/player contacts. This is template fracture, no mesh cut.
    """
    integer(grace,0,255,'grace')
    if any(len(v)!=3 for v in (position,velocity,axis)) or not 0<fraction<1 or not 0<=separation<=1 or impulse<0:
        raise ValueError('Finite3D vectors, positive impulse and separation0..1 required')
    if not all(math.isfinite(x) for vec in (position,velocity,axis) for x in vec) or not all(math.isfinite(v) for v in (separation,impulse,fraction)):
        raise ValueError('Finite fragment values required')
    length=math.sqrt(sum(x*x for x in axis))
    if not length:raise ValueError('Nonzero separation axis required')
    unit=[x/length for x in axis]
    return [dict(position=[p+sign*weight*separation*n for p,n in zip(position,unit)],
                 velocity=[v+sign*weight*impulse*n for v,n in zip(velocity,unit)],siblingGrace=grace)
            for sign,weight in [(-1,1-fraction),(1,fraction)]]


def solid_lamp_colors(vertices, faces, lamp, *, dark, bright, threshold=.5, emissive=None):
    """Host-side local-space point-lamp bake; colors stay fixed under rotation."""
    for c in (dark, bright):
        integer(c, 0, 15, 'VIC-II color')
    if len(lamp) != 3 or not all(math.isfinite(v) for v in lamp) or not -1 <= threshold <= 1:
        raise ValueError('Finite local lamp and threshold -1..1 required')
    emissive = emissive or {};result = []
    for index, face in enumerate(faces):
        if len(face) not in (3, 4):
            raise ValueError('Triangle or quad faces required')
        a, b, c = [vertices[i] for i in face[:3]]
        u = [b[i]-a[i] for i in range(3)];v = [c[i]-a[i] for i in range(3)]
        n = [u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0]]
        center = [sum(vertices[j][i] for j in face)/len(face) for i in range(3)]
        d = [lamp[i]-center[i] for i in range(3)]
        length = math.sqrt(sum(x*x for x in n)*sum(x*x for x in d))
        if not length:
            raise ValueError('Degenerate face or lamp at face center')
        value = bright if sum(x*y for x, y in zip(n, d))/length >= threshold else dark
        result.append(integer(emissive.get(index, value), 0, 15, 'emissive color'))
    return result
