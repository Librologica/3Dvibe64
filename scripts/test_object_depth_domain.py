#!/usr/bin/env python3
"""Host-side regression for object world-Y signed-16.8 depth validation."""
from __future__ import annotations

import json
import math
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUILDER_RELATIVE = Path("work/build-3Dvibe64.ps1")
VALUES = (-1.0, 0.0, 1.0)


def scale_q6(value: float) -> int:
    return round(value * 64)


def depth_extension(vertices: list[list[int]], scale: int) -> tuple[int, int]:
    envelope = max(
        sum(math.floor(abs(component) * scale / 64) for component in vertex)
        for vertex in vertices
    )
    return (-128, 127) if envelope >= 128 else (-envelope, envelope)


def safe_scaled_interval(bounds: tuple[int, int], camera_mode: str) -> tuple[int, int]:
    minimum_integer = -32768 - bounds[0]
    maximum_integer = 32767 - bounds[1]
    if camera_mode == "fixed":
        minimum = max(-8388608, minimum_integer * 256 - 128)
        maximum_fraction = 127
    else:
        minimum = max(-8388608, minimum_integer * 256)
        maximum_fraction = 255
    maximum = min(8388607, maximum_integer * 256 + maximum_fraction)
    return minimum, maximum


def fixed8(value: float) -> int:
    return round(value * 256)


def encode_signed16_8(scaled: int) -> tuple[int, int, int]:
    return scaled & 0xFF, (scaled >> 8) & 0xFF, (scaled >> 16) & 0xFF


def valid_depth(value: float, bounds: tuple[int, int], camera_mode: str) -> bool:
    scaled = fixed8(value)
    minimum, maximum = safe_scaled_interval(bounds, camera_mode)
    return minimum <= scaled <= maximum


def make_scene(
    name: str,
    vertices: list[list[int]],
    faces: list[list[int]],
    objects: list[dict],
    camera_mode: str,
    graphics_mode: int = 1,
) -> dict:
    return {
        "schema": 1,
        "name": name,
        "graphicsMode": graphics_mode,
        "axisConvention": "world-z-up",
        "camera": {
            "id": "camera",
            "position": [0, 0, 0],
            "rotation": [0, 0, 0],
            "mode": camera_mode,
        },
        "meshes": [
            {
                "id": "mesh",
                "type": "mesh",
                "geometry": "solid",
                "materialProfile": "single",
                "vertices": vertices,
                "faces": faces,
            }
        ],
        "lights": [
            {
                "id": "key",
                "mode": "static",
                "position": [48, 40, 48],
                "phaseCount": 32,
                "tickDiv": 2,
                "staticPhase": 0,
                "intensity": 10,
                "pulse": False,
            }
        ],
        "objects": objects,
        "world": {"backgroundColor": 0, "grounds": []},
        "contract": {
            "version": 1,
            "worldSpace": "world-z-up",
            "objectSpace": "aligned-world",
            "viewportProfile": "normal",
            "ground": False,
        },
    }


def object_record(name: str, world_y: float, scale: float = 1.0) -> dict:
    return {
        "id": name,
        "mesh": "mesh",
        "position": [0, world_y, 0],
        "rotation": [0, 0, 0],
        "angularVelocity": [0, 0, 0],
        "scale": scale,
        "visible": True,
        "material": "white",
        "reflectivity": "satin",
        "geometry": "solid",
        "materialProfile": "single",
    }


def run_builder(
    package: Path,
    scene_dir: Path,
    name: str,
    scene: dict,
    graphics_mode: int,
    camera_mode: str,
    expect_success: bool,
    expected_tokens: tuple[str, ...] = (),
    memory_layout: str = "stable",
) -> str:
    scene_path = scene_dir / f"{name}.json"
    scene_path.write_text(json.dumps(scene, indent=2), encoding="utf-8")
    result = subprocess.run(
        [
            "powershell.exe",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            str(package / BUILDER_RELATIVE),
            "-SceneFile",
            str(scene_path),
            "-GraphicsMode",
            str(graphics_mode),
            "-CameraMode",
            camera_mode,
            "-CameraViewport",
            "normal",
            "-Quality",
            "balanced",
            "-Projection",
            "table",
            "-MemoryLayout",
            memory_layout,
            "-NoFpsOverlay",
            "-SkipCmdUpdate",
        ],
        cwd=package,
        text=True,
        capture_output=True,
        env=os.environ.copy(),
    )
    output = result.stdout + result.stderr
    assert (result.returncode == 0) is expect_success, (name, result.returncode, output)
    for token in expected_tokens:
        assert token in output, (name, token, output)
    return output


def main() -> None:
    source = (ROOT / BUILDER_RELATIVE).read_text(encoding="utf-8").replace("\r\n", "\n")
    for token in (
        "function Split-Fixed16_8",
        "Frac = ($Scaled -band 255)",
        "Lo = (($Scaled -shr 8) -band 255)",
        "Hi = (($Scaled -shr 16) -band 255)",
        "function Get-ObjectDepthExtensionBounds",
        "function Validate-SceneObjectDepthDomains",
        "Validate-SceneObjectDepthDomains $EffectiveCameraMode",
        "mesh depth extension=[{5},{6}] WU",
        "signed 16.8 integer domain=[-32768,32767]",
    ):
        assert token in source, token

    point_vertices = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
    point_faces = [[0, 1, 2]]
    cube_vertices = [[x, y, z] for x in (-28, 28) for y in (-28, 28) for z in (-28, 28)]
    cube_faces = [[0, 1, 3], [0, 3, 2], [4, 6, 7], [4, 7, 5]]
    complex_reference_mesh = json.loads(
        (
            ROOT
            / "validation/mode3-complex-mesh-memory/complex-mesh-mode3-walkfull-camera-reference.json"
        ).read_text(encoding="utf-8-sig")
    )
    complex_reference_mesh_vertices = complex_reference_mesh["meshes"][0]["vertices"]
    complex_reference_mesh_faces = complex_reference_mesh["meshes"][0]["faces"]

    point_bounds = depth_extension(point_vertices, 64)
    cube_bounds = depth_extension(cube_vertices, 64)
    cube_max_bounds = depth_extension(cube_vertices, 127)
    complex_reference_mesh_bounds = depth_extension(complex_reference_mesh_vertices, scale_q6(0.95))
    assert point_bounds == (0, 0)
    assert cube_bounds == (-84, 84)
    assert cube_max_bounds == (-128, 127)
    assert complex_reference_mesh_bounds == (-89, 89)

    for bounds in (point_bounds, cube_bounds, cube_max_bounds, complex_reference_mesh_bounds):
        for camera_mode in ("fixed", "walkLite", "walkFull"):
            minimum, maximum = safe_scaled_interval(bounds, camera_mode)
            probes = (
                (minimum - 1, False),
                (minimum, True),
                (minimum + 1, True),
                *( (fixed8(value), True) for value in VALUES ),
                (maximum - 1, True),
                (maximum, True),
                (maximum + 1, False),
            )
            for scaled, expected in probes:
                assert valid_depth(scaled / 256, bounds, camera_mode) is expected

    assert encode_signed16_8(-8388608) == (0x00, 0x00, 0x80)
    assert encode_signed16_8(8388607) == (0xFF, 0xFF, 0x7F)
    assert encode_signed16_8(-256) == (0x00, 0xFF, 0xFF)
    assert encode_signed16_8(0) == (0x00, 0x00, 0x00)
    assert encode_signed16_8(256) == (0x00, 0x01, 0x00)

    tass = os.environ.get("TASS64_EXE")
    assert tass and Path(tass).is_file(), "Set TASS64_EXE to run builder integration cases"
    with tempfile.TemporaryDirectory(prefix="3dvibe64-object-depth-") as temporary:
        temp = Path(temporary)
        package = temp / "package"
        scenes = temp / "scenes"
        shutil.copytree(ROOT, package)
        scenes.mkdir()

        # Exact raw signed-16.8 endpoints and their adjacent 1/256-WU failures.
        for mode in ("fixed", "walkLite", "walkFull"):
            minimum, maximum = safe_scaled_interval(point_bounds, mode)
            for suffix, scaled, depth_valid in (
                ("min", minimum, True),
                ("below-min", minimum - 1, False),
                ("max", maximum, True),
                ("above-max", maximum + 1, False),
            ):
                name = f"point-{mode}-{suffix}"
                scene = make_scene(
                    name,
                    point_vertices,
                    point_faces,
                    [object_record("point_object", scaled / 256)],
                    mode,
                )
                if depth_valid:
                    tokens = ("Camera-plane culling requires three non-collinear vertices in face 0",)
                else:
                    tokens = (
                        "Object depth validation failed for object 'point_object'",
                        "interval=[",
                        "mesh depth extension=",
                        "scaleQ6=64/64 (1)",
                        "resulting depth interval=",
                    )
                run_builder(package, scenes, name, scene, 1, mode, False, tokens)

        # A valid center whose scaled cube geometry crosses the upper edge.
        cube_min, cube_max = safe_scaled_interval(cube_bounds, "fixed")
        crossing = make_scene(
            "cube-vertex-crosses",
            cube_vertices,
            cube_faces,
            [object_record("cube_vertex_crosses", (cube_max + 1) / 256)],
            "fixed",
        )
        run_builder(
            package,
            scenes,
            "cube-vertex-crosses",
            crossing,
            1,
            "fixed",
            False,
            ("cube_vertex_crosses", "mesh depth extension=[-84,84] WU"),
        )

        # Maximum scale, complex reference mesh, and two opposite-domain objects.
        max_min, max_max = safe_scaled_interval(cube_max_bounds, "walkFull")
        max_scale_scene = make_scene(
            "cube-max-scale",
            cube_vertices,
            cube_faces,
            [object_record("cube_max_scale", max_max / 256, 127 / 64)],
            "walkFull",
        )
        run_builder(package, scenes, "cube-max-scale", max_scale_scene, 5, "walkFull", True)

        mesh_min, mesh_max = safe_scaled_interval(complex_reference_mesh_bounds, "walkFull")
        complex_reference_mesh_scene = make_scene(
            "complex_reference_mesh-depth-limit",
            complex_reference_mesh_vertices,
            complex_reference_mesh_faces,
            [object_record("complex_reference_mesh_limit", mesh_max / 256, 0.95)],
            "walkFull",
            3,
        )
        run_builder(
            package,
            scenes,
            "complex_reference_mesh-depth-limit",
            complex_reference_mesh_scene,
            3,
            "walkFull",
            True,
            memory_layout="high-basic-v2",
        )

        opposite = make_scene(
            "two-opposite-depths",
            cube_vertices,
            cube_faces,
            [
                object_record("negative_extreme", cube_min / 256),
                object_record("positive_extreme", cube_max / 256),
            ],
            "fixed",
        )
        run_builder(package, scenes, "two-opposite-depths", opposite, 1, "fixed", True)

        # The validation is mode-independent; camera profile controls only
        # the fixed-versus-mobile fractional endpoint.
        central = make_scene(
            "mode-camera-matrix",
            cube_vertices,
            cube_faces,
            [object_record("central", 0)],
            "fixed",
        )
        for graphics_mode in range(1, 6):
            for camera_mode in ("fixed", "walkLite", "walkFull"):
                run_builder(
                    package,
                    scenes,
                    f"mode{graphics_mode}-{camera_mode}",
                    central,
                    graphics_mode,
                    camera_mode,
                    True,
                )

    print(
        "OBJECT_DEPTH_DOMAIN signed16.8=-32768..32767.99609375 "
        "fixedPointMesh=0 cube64=-84..84 cube127=-128..127 complex_reference_mesh61=-89..89 "
        "cameras=fixed/walkLite/walkFull modes=1..5 integration=pass"
    )


if __name__ == "__main__":
    main()
