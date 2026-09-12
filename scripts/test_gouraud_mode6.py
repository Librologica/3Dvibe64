#!/usr/bin/env python3
"""Gate A-D host/build contract for GraphicsMode 6 Gouraud shading."""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUILDER = ROOT / "work" / "build-3Dvibe64.ps1"
SOURCE = BUILDER.read_text(encoding="utf-8").replace("\r\n", "\n")


def require(token: str) -> None:
    assert token in SOURCE, f"Mode 6 contract missing: {token}"


def powershell() -> str:
    shell = shutil.which("pwsh") or shutil.which("powershell.exe")
    assert shell, "PowerShell is required"
    return shell


def build(scene: Path, expect_success: bool = True, extra_args: list[str] | None = None) -> tuple[str, str]:
    env = os.environ.copy()
    assert env.get("TASS64_EXE") or shutil.which("64tass"), "Set TASS64_EXE or add 64tass to PATH"
    command = [
        powershell(), "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(BUILDER),
        "-SceneFile", str(scene), "-GraphicsMode", "6", "-Quality", "fast",
        "-Projection", "extended-table", "-MemoryLayout", "high-basic-v2",
        "-NoFpsOverlay", "-SkipCmdUpdate",
    ]
    if extra_args:
        command.extend(extra_args)
    completed = subprocess.run(command, cwd=ROOT, env=env, text=True, capture_output=True)
    output = completed.stdout + completed.stderr
    if expect_success:
        assert completed.returncode == 0, output
        asm = (ROOT / "work" / "3Dvibe64.asm").read_text(encoding="utf-8").replace("\r\n", "\n")
        return output, asm
    assert completed.returncode != 0, "expected the build to fail"
    return output, ""


def scene_doc(mesh: dict, objects: list[dict] | None = None) -> dict:
    if objects is None:
        objects = [{
            "id": "object", "mesh": mesh["id"], "position": [0, 0, 112],
            "rotation": [12, 20, 0], "angularVelocity": [0, 0, 0],
            "scale": 0.75, "visible": True, "material": "blue", "reflectivity": "gloss",
        }]
    return {
        "schema": 1, "name": "mode6_gate", "graphicsMode": 6,
        "axisConvention": "engine-y-up", "world": {"backgroundColor": 0, "grounds": []},
        "camera": {"id": "camera", "position": [0, 0, 0], "rotation": [0, 0, 0], "mode": "fixed"},
        "lights": [{"id": "key", "mode": "static", "position": [-48, 40, 32], "intensity": 10}],
        "meshes": [mesh], "objects": objects,
        "contract": {"version": 1, "viewportProfile": "normal", "ground": False},
    }


def write_scene(folder: Path, name: str, doc: dict) -> Path:
    path = folder / name
    path.write_text(json.dumps(doc), encoding="utf-8")
    return path


def runtime_mesh_shade_count(asm: str, mesh_name: str) -> int:
    match = re.search(rf"^; \d+: {re.escape(mesh_name)} .* shadeVertices=(\d+) ", asm, re.MULTILINE)
    assert match, f"shade-vertex diagnostic missing for {mesh_name}"
    return int(match.group(1))


def runtime_mesh_vertex_count(asm: str, mesh_name: str) -> int:
    match = re.search(rf"^; \d+: {re.escape(mesh_name)} .* vertices=(\d+) ", asm, re.MULTILINE)
    assert match, f"geometric-vertex diagnostic missing for {mesh_name}"
    return int(match.group(1))


def temporal_step(old: int, target: int) -> int:
    if old == 0xFF:
        return target
    if target > old + 4:
        return old + 4
    if target < old - 4:
        return old - 4
    return target


BAYER = ((0, 8, 2, 10), (12, 4, 14, 6), (3, 11, 1, 9), (15, 7, 13, 5))


def dither_code(level: int, x: int, y: int) -> int:
    threshold = BAYER[y & 3][x & 3]
    if level <= 16:
        return 2 if threshold < level else 1
    return 3 if threshold < level - 16 else 2


def lerp_u8(a: int, b: int, scale: int) -> int:
    return max(0, min(32, a + int((b - a) * scale / 255)))


def main() -> None:
    for token in (
        '[ValidateSet("1", "2", "3", "4", "5", "6", "7")]',
        "GraphicsMode 6 requires -MemoryLayout high-basic-v2",
        "$CurrentMeshGouraudCreaseAngle = 60.0",
        "Build-GouraudShadeVertices",
        "areaNormal = [double[]]$rawNormals",
        "GraphicsMode 6 supports at most 255 runtime shade vertices",
        "gouraud_update_object_shades:",
        "cmp #$05\n bcc gous_store_target",
        "gouraud_bayer4x4: .byte 0,8,2,10,12,4,14,6,3,11,1,9,15,7,13,5",
        "gouraud_pair_01: .byte $40,$10,$04,$01",
        "gouraud_pair_10: .byte $80,$20,$08,$02",
        "gouraud_pair_11: .byte $c0,$30,$0c,$03",
        "gouraud_build_edge_shades:",
        "draw_clip_poly_gouraud:",
        "gouraud_interp_clip_shade:",
        "clip_a_shade",
        "clip_b_shade",
        "REFLECTIVITY_CYCLE_OFFSET_LIMIT = $28",
        "cmp #REFLECTIVITY_CYCLE_OFFSET_LIMIT",
    ):
        require(token)

    temporal_cases = 0
    for old in [0xFF, *range(33)]:
        for target in range(33):
            value = temporal_step(old, target)
            assert 0 <= value <= 32
            if old == 0xFF:
                assert value == target
            else:
                assert abs(value - old) <= 4
            temporal_cases += 1

    codes = {dither_code(level, x, y) for level in range(33) for y in range(4) for x in range(4)}
    assert codes == {1, 2, 3}
    assert all(dither_code(0, x, y) == 1 for y in range(4) for x in range(4))
    assert all(dither_code(16, x, y) == 2 for y in range(4) for x in range(4))
    assert all(dither_code(32, x, y) == 3 for y in range(4) for x in range(4))

    clip_cases = 0
    for a in range(33):
        for b in range(33):
            assert lerp_u8(a, b, 0) == a
            assert lerp_u8(a, b, 255) == b
            for scale in (1, 64, 127, 128, 192, 254):
                value = lerp_u8(a, b, scale)
                assert min(a, b) <= value <= max(a, b)
                clip_cases += 1

    with tempfile.TemporaryDirectory(prefix="3dvibe64-mode6-") as temp_name:
        temp = Path(temp_name)
        cube_default = scene_doc({
            "id": "cube_default", "type": "mesh", "geometry": "solid",
            "materialProfile": "single", "builtin": "cube",
        })
        _, asm = build(write_scene(temp, "cube-default.json", cube_default))
        assert runtime_mesh_shade_count(asm, "object") == 24

        cube_smooth = scene_doc({
            "id": "cube_smooth", "type": "mesh", "geometry": "solid",
            "materialProfile": "single", "builtin": "cube", "gouraud": {"creaseAngle": 180},
        })
        _, asm = build(write_scene(temp, "cube-smooth.json", cube_smooth))
        assert runtime_mesh_shade_count(asm, "object") == 8

        torus_smooth = scene_doc({
            "id": "torus_smooth", "type": "mesh", "geometry": "solid",
            "materialProfile": "single", "builtin": "torus6x6", "gouraud": {"creaseAngle": 180},
        })
        _, asm = build(write_scene(temp, "torus-smooth.json", torus_smooth))
        assert runtime_mesh_shade_count(asm, "object") == 36

        _, asm = build(
            write_scene(temp, "torus-reflectivity-cycle.json", torus_smooth),
            extra_args=["-ControlReflectivity", "-ReflectivityCycleLevels", "3"],
        )
        assert "CONTROL_REFLECTIVITY_KEYS = $01" in asm
        assert "REFLECTIVITY_CYCLE_OFFSET_LIMIT = $1E" in asm
        assert "reflectivityCycleLevels=3" in asm

        duplicate_cube = scene_doc({
            "id": "duplicate_cube", "type": "mesh", "geometry": "solid",
            "materialProfile": "single", "gouraud": {"creaseAngle": 180},
            "vertices": [
                [-28, -28, -28], [-28, 28, -28], [28, 28, -28], [28, -28, -28],
                [-28, -28, 28], [28, -28, 28], [28, 28, 28], [-28, 28, 28],
                [-28, -28, -28], [-28, -28, 28], [-28, 28, 28], [-28, 28, -28],
                [28, -28, -28], [28, 28, -28], [28, 28, 28], [28, -28, 28],
                [-28, -28, -28], [28, -28, -28], [28, -28, 28], [-28, -28, 28],
                [-28, 28, -28], [-28, 28, 28], [28, 28, 28], [28, 28, -28],
            ],
            "faces": [
                [0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11],
                [12, 13, 14, 15], [16, 17, 18, 19], [20, 21, 22, 23],
            ],
        })
        _, asm = build(write_scene(temp, "duplicate-cube.json", duplicate_cube))
        assert runtime_mesh_vertex_count(asm, "object") == 8
        assert runtime_mesh_shade_count(asm, "object") == 8

        overflow_mesh = {
            "id": "overflow_cube", "type": "mesh", "geometry": "solid",
            "materialProfile": "single", "builtin": "cube",
        }
        overflow_objects = []
        for index in range(11):
            overflow_objects.append({
                "id": f"cube_{index}", "mesh": "overflow_cube", "position": [0, 0, 96 + index],
                "rotation": [0, 0, 0], "angularVelocity": [0, 0, 0], "scale": 0.5,
                "visible": True, "material": "blue", "reflectivity": "satin",
            })
        output, _ = build(write_scene(temp, "overflow.json", scene_doc(overflow_mesh, overflow_objects)), False)
        assert "at most 255 runtime shade vertices" in output

    built = []
    for relative in (
        "examples/mode6-gouraud-torus.json",
        "examples/mode6-gouraud-mixed-faces.json",
        "examples/mode6-gouraud-shared-materials.json",
        "examples/mode6-gouraud-cube-hard.json",
        "examples/mode6-gouraud-cube-smooth.json",
        "examples/mode6-gouraud-torus-fps.json",
    ):
        _, asm = build(ROOT / relative)
        assert "GRAPHICS_MODE = $06" in asm
        assert "GOURAUD_MODE6 = $01" in asm
        assert "SHADE_VERT_COUNT = $00" not in asm
        if relative.endswith("mode6-gouraud-torus.json"):
            assert runtime_mesh_shade_count(asm, "yellow_reflective_torus") == 36
        if relative.endswith("mode6-gouraud-cube-hard.json"):
            assert runtime_mesh_shade_count(asm, "cube") == 24
        if relative.endswith("mode6-gouraud-cube-smooth.json"):
            assert runtime_mesh_shade_count(asm, "cube") == 8
        assert "GOURAUD_BYTE_SPAN_KERNEL = $01" in asm
        for label in ("gouraud_bayer_code_lut_y0:", "gouraud_draw_scan_span_bytes:"):
            assert label in asm, label
        built.append(relative)

    print(json.dumps({
        "gateA": "pass", "gateB": "pass", "gateC": "pass", "gateDHostBuild": "pass",
        "cubeDefaultShadeVertices": 24, "cubeSmoothShadeVertices": 8,
        "torusSmoothShadeVertices": 36, "duplicateCubeSourceVertices": 24,
        "duplicateCubeRuntimeVertices": 8, "duplicateCubeShadeVertices": 8,
        "runtimeShadeLimit": 255,
        "temporalCases": temporal_cases, "clipInterpolationCases": clip_cases,
        "opaqueBitmapCodes": sorted(codes), "examplesBuilt": built,
    }, separators=(",", ":")))


if __name__ == "__main__":
    main()
