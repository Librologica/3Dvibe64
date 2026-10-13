"""Bind native evidence to the exact program, scene, settings and captured bytes."""
import hashlib,json
from pathlib import Path

MANIFEST='capture-manifest.json'

def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest().upper()

def identity(build,standard,qualification=None):
    build=Path(build)
    return dict(programSHA256=sha(build/'3Dvibe64.prg'),sceneSHA256=sha(build/'scene.json'),
                buildSettingsSHA256=sha(build/'build.json'),fontSHA256=sha(build/'font.bin'),
                labelsSHA256=sha(build/'labels.txt'),standard=standard,
                target='x64sc stock 6510',qualification=qualification or {})

def capture_files(out):
    out=Path(out)
    names={'trace.log','run.json','capture.mon','console.log','extra-traces.json'}
    return sorted(p for p in out.iterdir() if p.is_file() and
                  (p.name in names or p.suffix in ('.vsf','.bin','.png')))

def record(build,out,standard,qualification,expected):
    out=Path(out)
    if identity(build,standard,qualification)!=expected:
        raise ValueError('CAPTURE_PROVENANCE: build changed during acquisition')
    run=json.loads((out/'run.json').read_text())
    data=dict(schema=1,identity=expected,producer=dict(method='VICE native monitor',
              command=run['command'],emulatorSHA256=sha(run['command'][0])),
              files={p.name:sha(p) for p in capture_files(out)})
    (out/MANIFEST).write_text(json.dumps(data,indent=2)+'\n',encoding='utf8',newline='\n')

def verify(build,out,standard,qualification=None):
    out=Path(out)
    if not (out/MANIFEST).is_file():
        raise ValueError('CAPTURE_PROVENANCE: missing acquisition manifest; historical captures require a new acquisition')
    try:
        data=json.loads((out/MANIFEST).read_text())
        if data['schema']!=1 or data['identity']!=identity(build,standard,qualification):
            raise ValueError('build, scene or execution settings differ')
        actual={p.name:sha(p) for p in capture_files(out)}
        if not actual or data['files']!=actual:raise ValueError('captured files differ')
        run=json.loads((out/'run.json').read_text())
        if data['producer']['method']!='VICE native monitor' or data['producer']['command']!=run['command']:
            raise ValueError('producer command differs')
        producer=Path(run['command'][0]);digest=data['producer']['emulatorSHA256']
        if not isinstance(digest,str) or len(digest)!=64 or any(c not in '0123456789ABCDEF' for c in digest):
            raise ValueError('invalid producer identity')
        if producer.is_file() and sha(producer)!=digest:raise ValueError('producer binary differs')
    except (OSError,KeyError,TypeError,json.JSONDecodeError,ValueError) as error:
        raise ValueError('CAPTURE_PROVENANCE: '+str(error)) from error
    return data
