"""Bounded BB-03 profile with independent animation and two actor nodes."""
import billboard_multiple as multiple
import gameplay_profile


def adapt(source, parts):
    return multiple.adapt(source, parts, gameplay_profile.CONFIG)


def report():
    cfg=gameplay_profile.CONFIG
    return dict(comparison='two independently animated billboard instances and guardian-operated door',
        billboards=dict(configuration=cfg,count=len(cfg['billboards']),capacity=2,
            visible=cfg.get('visibleBillboards',[b['id'] for b in cfg['billboards']]),
            sharedSourceBytes=len(gameplay_profile.ASSET['frames'])*512,
            sharedDecodedCacheBytes=512,nearPlaneWU=4,
            ordering='full Q8 view depth; parallel view-facing planes; exact ties first configured instance on top',
            clipping='screen clipping preserves source nearest-neighbor mapping; constant-depth plane rejected wholly below4WU',
            limits='one or two instances sharing one asset/palette, wholly in front of bounded divider, pitch within14degrees; second actor has no gameplay collider'),
        occlusion='convex outer shell and one separating divider; exact Q8 depth order between parallel billboard planes')
