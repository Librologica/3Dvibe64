"""External instruction instrumentation, never inserted into a PRG."""
import sys,re,hashlib
from collections import Counter,defaultdict
from .common import ROOT,load,sha
from py65.devices.mpu6502 import MPU

def labels(b):return {l.split()[2][1:]:int(l.split()[1],16) for l in (b/'labels.txt').read_text().splitlines()}

class Trace:
    def __init__(self,b,backend,meta):
        self.b=b;self.multi=backend=='multi';self.l=labels(b);l=self.l;self.c=MPU();self.meta=meta
        d=(b/'3Dvibe64.prg').read_bytes();a=int.from_bytes(d[:2],'little');self.c.memory[a:a+len(d)-2]=d[2:]
        src=(b/'3Dvibe64.asm').read_text()
        names=set(re.findall(r'(?m)^\s*jsr\s+([A-Za-z_]\w*)',src))
        self.phases=['compose_screen'] if self.multi else ['raycast_layers','select_strips','compose_screen']
        names.update(self.phases);names.update(('trace_path','band_address','fill_rows','ss_band_draw','scalar_fill','lazy_samples'))
        self.points={l[n]:n for n in sorted(names) if n in l}
        groups=load(ROOT/'work/mode8/profile-groups.json')[2 if self.multi else 0 if backend=='mono-opaque' else 1]['groups']
        self.categories={n:g['category'] for g in groups for n in g['routines']}
        self.hooks={l[n]:n for n in ('ray_next','ss_sample','ss_reuse_sample','sr_restore_coarse','portal_exit','ss_refine','trace_path','trace_advance','trace_event_counted','cache_miss','cache_complete','lazy_need_group','project_profile','get_profile','dda_read') if n in l}
        self.step_points={l[n] for n in l if re.fullmatch(r'dda_q[0-3]_(?:[xy]r|xd)',n) or n=='portal_exit_test'}
        self.coarse_phase=True
        self.execute(l['init_masks'] if self.multi else l['layout_copy_tables'],False)
        self.execute(l['vp_clear_frame'],False)

    def execute(self,pc,instrument=True):
        c=self.c;m=c.memory;l=self.l;c.pc=pc;c.sp=253;m[0x1fe:0x200]=[254,1]
        current='entry';stack=[];start=c.processorCycles
        cost=Counter();calls=Counter();cnt=Counter();cells=Counter();events=Counter();profiles=Counter();shared=Counter()
        while c.pc!=0x1ff:
            pc=c.pc;op=m[pc]
            if pc in self.points:current=self.points[pc];calls[current]+=1
            if instrument:
                if pc==l.get('geometry_begin'):self.coarse_phase=True
                if pc==l.get('geometry_end'):self.coarse_phase=False
                hook=self.hooks.get(pc)
                if hook:
                    cnt[hook]+=1
                    if hook=='ray_next':cnt['fineRaysActual' if m[l['ss_active']] else 'mainRaysActual']+=1
                    if hook=='trace_path':cnt['mainRaysActual' if self.coarse_phase else 'fineRaysActual']+=1
                    if hook=='get_profile':profiles[c.a]+=1
                    if hook=='dda_read':
                        addr=m[pc+1]+256*m[pc+2]+c.y;idx=addr&1023;bank=(addr-0x4400)//1024
                        cells[f'boundary-map:{bank}:cell:{idx%32},{idx//32}']+=1
                    if hook=='trace_event_counted':events['encountered:'+str(c.x)]+=1
                if not self.multi:
                    if pc in self.step_points:cnt['ddaStepsActual']+=1
                    if op==0xb1 and m[pc+1]==0x30:
                        addr=m[0x30]+256*m[0x31]+c.y;idx=addr-0x3c00
                        if 0<=idx<1024:cells[f'cell:{idx%32},{idx//32}']+=1
                else:
                    if op==0x8e and m[pc+1]+256*m[pc+2]==l['current_event']:events['processed:'+str(c.x)]+=1
                    if op==0x91 and m[pc+1]==l['p_out']:
                        addr=m[l['p_out']]+256*m[l['p_out']+1]+c.y
                        if 0x8a00<=addr<0x9a00:cnt['profileSampleWrites']+=1
            t=c.processorCycles
            if op==0x20:stack.append(current)
            c.step();dt=c.processorCycles-t;cost[current]+=dt
            if instrument and self.multi and current in ('project_profile','p_div32x16','p_mul8','p_mul32x16','fh_ratio','fh_height_delta','p_lookup_g','ramp_endpoint_correction','lazy_samples'):
                shared[m[l['p_key']]]+=dt
            if op==0x60 and stack:current=stack.pop()
            if c.processorCycles-start>4000000:raise AssertionError(('runaway',hex(c.pc)))
        return dict(cycles=c.processorCycles-start,cost=cost,calls=calls,counters=cnt,cells=cells,events=events,profiles=profiles,shared=shared)

    def view(self,pose):
        c=self.c;m=c.memory;l=self.l
        for a,v in zip((0x26,0x28,0x2a),pose[:3]):m[a]=v&255;m[a+1]=v>>8
        if self.multi:m[0x2d]=pose[3];m[0x2f]=pose[4]
        m[6]=0;total={k:Counter() for k in ('cost','calls','counters','cells','events','profiles','shared')};ph={}
        for phase in self.phases:
            r=self.execute(l[phase]);ph[phase]=r['cycles']
            for k in total:total[k].update(r[k])
        cycles=sum(ph.values());assert sum(total['cost'].values())==cycles
        categories=Counter()
        for k,v in total['cost'].items():categories[self.categories.get(k,'unclassified:'+k)]+=v
        assert not any(k.startswith('unclassified:') for k in categories),categories
        cnt=total['counters']
        if self.multi:
            cnt['ddaStepsActual']=m[0xf3]+256*m[0xf4];cnt['refinedGroups']=m[l['frame_fine'] if 'frame_fine' in l else 0x3274]
            cnt['profileRequests']=cnt['get_profile'];cnt['profilePrepares']=cnt['project_profile']
            cnt['profileCacheHitRequests']=cnt['get_profile']-cnt['cache_miss'];cnt['generatedBlockRequests']=cnt['lazy_need_group']
            cnt['encounteredEvents']=sum(v for k,v in total['events'].items() if k.startswith('encountered:'))
            cnt['processedEvents']=sum(v for k,v in total['events'].items() if k.startswith('processed:'))
            def profile(k):
                plane,alt=self.meta['p']['keys'][k]
                return f"plane:{'y' if plane&64 else 'x'}:{plane&63}:"+(f'ramp-marker:{alt}' if alt in (254,255) else f'height:{alt}')
            total['profiles']={profile(k):v for k,v in total['profiles'].items()}
            total['shared']={profile(k):v for k,v in total['shared'].items()}
            def event(k):
                kind,i=k.split(':');e=self.meta['p']['events'][int(i)]
                return kind+':'+','.join(profile(v) if v!=255 else 'none' for v in e[:4])+f':flags{e[4]}'
            total['events']={event(k):v for k,v in total['events'].items()}
        else:
            cnt['refinedGroups']=m[l['ss_refined_count']];cnt['fineDirectionRequests']=m[l['ss_rays']]
            cnt['coarseRayReuses']=m[l['sr_hits']]
            cnt['adjacentRayReuses']=cnt['ss_sample']-cnt['fineDirectionRequests']
            assert cnt['fineRaysActual']+cnt['coarseRayReuses']==cnt['fineDirectionRequests']
            cnt['ownerDiscontinuities']=sum(m[l['lower_owner']+i]!=m[l['lower_owner']+i+2] for i in range(0,62,2))
            cnt['upperOwnerDiscontinuities']=sum(m[l['upper_owner']+i]!=m[l['upper_owner']+i+2] for i in range(0,62,2))
            cnt['exitPlaneDiscontinuities']=sum(m[l['fx_exit_plane']+i]!=m[l['fx_exit_plane']+i+2] for i in range(0,62,2))
            cnt['projections']=total['calls']['fx_height']+total['calls']['layer_heights']
        bitmap=bytes(m[0x63c0:0x7f40])
        return dict(pose=pose,cycles=cycles,phase=ph,exclusiveCycles=dict(categories),
                    **{k:dict(v) for k,v in total.items()},bitmapSHA256=hashlib.sha256(bitmap).hexdigest().upper()),bitmap
