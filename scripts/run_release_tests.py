#!/usr/bin/env python3
"""Run public contracts in independent clean SDK copies; never write into the SDK."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
from mode8.common import require_qualification_checks
TESTS = (
    "test_stable_package.py",
    "test_reusable_render.py", "test_documentation.py", "test_exact_release.py", "test_legacy_plus.py", "test_legacy_plus_exact.py", "test_exact_panels.py", "test_exact_material_cache.py",
    "test_sphere_impostors.py",
    "test_billboard_emitter.py",
    "test_mixed_surfaces.py",
    "test_billboard_scene.py",
    "test_door_entity.py",
    "test_multiple_billboards.py",
    "test_texture_animation.py",
    "test_light_bake.py",
    "test_sector_visibility.py",
    "test_shared_meshes.py",
    "test_controlled_motion.py",
    "test_world_groups.py",
    "test_common_level.py",

    "test_dev_gameplay.py",
    "test_release_contract.py", "test_world_metrics.py", "test_gouraud_mode6.py",
    "test_optimization_gate1_lut.py", "test_optimization_gate3_span.py",
    "test_optimization_gate4_division.py", "test_mobile_yq2.py",
    "test_camera_move_step.py", "test_camera_angular_repeat.py",
    "test_object_depth_domain.py", "test_gouraud_mode6_emulators.py",
    "test_dev7_text_split.py", "test_mode7.py", "test_mode8.py", "test_precision_q8.py",
    "test_mode8_lintels.py",
    "test_texture_perspective.py",
    "test_texture_uvzp.py",
    "test_texture_fast.py",
    "test_line_hybrid.py", "test_texture_lod.py", "test_frame_presentation.py",
    "test_normalized16.py", "test_maintenance_host.py", "test_maintenance_numeric.py",
    "test_engine_experiments.py", "test_mode8_retirement.py", "test_qualification_guard.py",
)

def copy_package(root,dest):
    """Copy exactly the current package bytes, including uncommitted candidate edits.

    The manifest is the distribution file list. Do not use git archive HEAD:
    that could silently test a different revision from the current candidate.
    """
    root=root.resolve();dest=dest.resolve();dest.mkdir(parents=True,exist_ok=True)
    entries=['MANIFEST.sha256']
    for line in (root/'MANIFEST.sha256').read_text(encoding='utf-8-sig').splitlines():
        digest,separator,name=line.partition('  ')
        if not separator or len(digest)!=64 or not name:raise ValueError('Malformed source manifest')
        source=(root/name).resolve()
        if not source.is_relative_to(root) or '.git' in Path(name).parts or not source.is_file():
            raise ValueError('Invalid package input: '+name)
        entries.append(name)
    if len(set(entries))!=len(entries):raise ValueError('Duplicate package entry')
    for name in entries:
        target=dest/name;target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(root/name,target)


def main():
    require_qualification_checks()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tests", nargs="*", help="Optional test filenames; omit for self-contained suite, or all registered gates with --test-inputs")
    parser.add_argument('--test-inputs',type=Path,help='External historical examples/validation for legacy regression tests')
    args = parser.parse_args()
    unknown = set(args.tests) - set(TESTS)
    if unknown:
        parser.error("Unknown tests: " + ", ".join(sorted(unknown)))
    env = os.environ.copy()
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    failures = []
    selected=args.tests or (TESTS if args.test_inputs else ('test_stable_package.py','test_reusable_render.py','test_legacy_plus_exact.py','test_exact_panels.py','test_exact_material_cache.py','test_documentation.py','test_legacy_plus.py','test_dev_gameplay.py','test_release_contract.py','test_exact_release.py','test_billboard_emitter.py','test_mixed_surfaces.py','test_billboard_scene.py','test_door_entity.py','test_multiple_billboards.py','test_texture_animation.py','test_light_bake.py','test_sector_visibility.py','test_shared_meshes.py','test_controlled_motion.py','test_world_groups.py','test_common_level.py'))
    if not args.tests and not args.test_inputs:
        selected=(*selected,'test_sphere_impostors.py')
    for name in selected:
        started = time.monotonic()
        print(f"START {name}", flush=True)
        with tempfile.TemporaryDirectory(prefix="3dvibe64-release-test-") as temporary:
            sdk = Path(temporary) / "sdk"
            copy_package(ROOT,sdk)
            if args.test_inputs and name not in ('test_documentation.py','test_release_contract.py','test_dev_gameplay.py','test_exact_release.py'):
                source=args.test_inputs.resolve(strict=True)
                if source.is_relative_to(ROOT):raise ValueError('Test inputs must stay outside SDK')
                for category in ('examples','validation'):
                    if (source/category).exists():shutil.copytree(source/category,sdk/category)
            result = subprocess.run([sys.executable, "-B", str(sdk / "scripts" / name)], cwd=sdk, env=env)
        print(f"{'PASS' if result.returncode == 0 else 'FAIL'} {name} elapsed={time.monotonic()-started:.1f}s", flush=True)
        if result.returncode:
            failures.append(name)
    if failures:
        raise SystemExit("Failed: " + ", ".join(failures))
    print("RELEASE PUBLIC TESTS: PASS", flush=True)

if __name__ == "__main__":
    main()
