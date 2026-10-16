"""Native checks and timing of the actual generated output; no PRG instrumentation."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
from mode8.common import require_qualification_checks


def main():
    require_qualification_checks()
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',required=True,type=Path)
    p.add_argument('--benchmark',action='store_true');p.add_argument('--checks',action='store_true')
    p.add_argument('--launcher',action='store_true');a=p.parse_args();out=a.out.resolve()
    info=json.loads((out/'build.json').read_text());project=out/'project';tools=project/'tools'
    preset=info['presetData']
    digest=hashlib.sha256((out/info['program']).read_bytes()).hexdigest().upper()
    assert digest==info['PRGSHA256']
    sys.path.insert(0,str(tools))
    if info['profile']=='room-groups':
        from native_world import benchmark,paths,sha
        name=preset['buildName'];assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            from qualify_world import checks
            (out/'native-checks.json').write_text(json.dumps(checks(name),indent=2)+'\n',encoding='utf-8')
    elif info['profile'] in ('controlled-animation','camera-roll'):
        from native_compare import benchmark,paths,sha
        name=preset['buildName'];assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            from qualify_motion import checks
            (out/'native-checks.json').write_text(json.dumps(checks(name),indent=2)+'\n',encoding='utf-8')
    elif info['profile']=='shared-meshes':
        from native_compare import benchmark,paths,sha
        name=preset['buildName'];assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            from qualify_shared_meshes import checks
            (out/'native-checks.json').write_text(json.dumps(checks(name),indent=2)+'\n',encoding='utf-8')
    elif info['profile']=='sector-visibility':
        from native_compare import paths,sha
        from native_visibility import benchmark
        name=preset['buildName'];assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            from qualify_visibility import checks
            (out/'native-checks.json').write_text(json.dumps(checks(name),indent=2)+'\n',encoding='utf-8')
    elif info['profile']=='static-light':
        from native_compare import benchmark,paths,sha
        name=preset['buildName'];assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            from qualify_static_light import checks
            (out/'native-checks.json').write_text(json.dumps(checks(name),indent=2)+'\n',encoding='utf-8')
    elif info['profile']=='animated-textures':
        from native_compare import benchmark,paths,sha
        name=preset['buildName'];assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            from qualify_texture_animation import checks
            (out/'native-checks.json').write_text(json.dumps(checks(name),indent=2)+'\n',encoding='utf-8')
    elif info['profile']=='multiple-billboards':
        from native_compare import benchmark,paths,sha
        name=preset['buildName'];assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            from qualify_multiple import checks
            (out/'native-checks.json').write_text(json.dumps(checks(name),indent=2)+'\n',encoding='utf-8')
    elif info['profile']=='door-entity':
        from native_compare import benchmark,paths,sha
        name=preset['buildName'];assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            from qualify_door import checks
            (out/'native-checks.json').write_text(json.dumps(checks(name),indent=2)+'\n',encoding='utf-8')
    elif info['profile']=='interactive-billboard':
        from native_compare import benchmark,paths,sha
        name=preset['buildName'];assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            from qualify_gameplay import checks
            (out/'native-checks.json').write_text(json.dumps(checks(name),indent=2)+'\n',encoding='utf-8')
    elif info['profile']=='mixed-surfaces':
        from native_compare import benchmark,paths,sha
        name=preset['buildName'];assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            from qualify_surfaces import checks
            (out/'native-checks.json').write_text(json.dumps(checks(name),indent=2)+'\n',encoding='utf-8')
    elif info['profile']=='comparison-ui':
        from native_compare import benchmark,capture,paths,sha
        name=preset['buildName']
        assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            import qualify_billboard
            from verify_ui import check_frame,lod_trace
            qualify_billboard.main()
            capture(name,0,0,camera=[0,0,-21.5,0,0],tag='front')
            l=paths(name)[2];stem=project/f'reports/views/{name}-front'
            ui=check_frame(stem.with_suffix('.ram').read_bytes()[2:],Path(str(stem)+'.color.ram').read_bytes()[2:],l,'front')
            report=dict(result='PASS',PRGSHA256=digest,UI=ui,LODWeights=lod_trace(name),
                fullPriorOrbitAndClipChecksReusedByExactPRGSHA256=info['checkpointPRGIdentical'])
            (out/'native-checks.json').write_text(json.dumps(report,indent=2))
    else:
        from native_billboard import benchmark,paths,sha
        name=preset['buildName'];assert sha(paths(name)[1])==digest
        if a.benchmark:benchmark(name,preset['routeRefreshes'])
        if a.checks:
            from qualify_billboard import partial_proof,reactions
            report=dict(result='PASS',PRGSHA256=digest,partialOcclusion=partial_proof(name),reactions=reactions(name),
                priorPixelOraclesReusedByExactPRGSHA256=info['checkpointPRGIdentical'])
            (out/'native-checks.json').write_text(json.dumps(report,indent=2))
    if a.launcher:
        result=subprocess.run(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',
            str(project/'launch-64mhz.ps1'),'-Verify'],cwd=project,capture_output=True)
        (out/'launcher-verification.log').write_bytes(result.stdout+result.stderr)
        assert result.returncode==0
    assert hashlib.sha256((out/info['program']).read_bytes()).hexdigest().upper()==digest


if __name__=='__main__':main()
