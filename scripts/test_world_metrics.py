#!/usr/bin/env python3
"""Repeatable host-side audit of the public 3Dvibe64 1.1.1 metric contract."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BUILDER = ROOT / "work" / "build-3Dvibe64.ps1"
SOURCE = BUILDER.read_text(encoding="utf-8").replace("\r\n", "\n")
VERSION = "1.1.1"
BUILDER_SHA256 = "FE1B51C2957638CCB31ABF6FAB54C456FDF0D1F839183DA4AEAFA2A642596C2D"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def require(token: str) -> None:
    assert token in SOURCE, f"builder metric contract missing: {token}"


def hex_constant(name: str) -> int:
    match = re.search(rf"(?m)^{re.escape(name)} = \$([0-9a-fA-F]+)$", SOURCE)
    assert match, f"constant not found: {name}"
    return int(match.group(1), 16)


def check_package_and_documentation() -> None:
    assert (ROOT / "VERSION").read_text(encoding="utf-8-sig").strip() == VERSION
    assert sha256(BUILDER) == BUILDER_SHA256
    package = json.loads((ROOT / "PACKAGE-MANIFEST.json").read_text(encoding="utf-8-sig"))
    assert package["package"]["version"] == VERSION
    assert package["builder"]["sha256"] == BUILDER_SHA256
    near = package["renderer"]["nearProfiles"]
    assert near == {"option": "Mode4NearProfile", "modes": [3, 4, 5], "values": ["default", "late", "clip"]}
    assert package["renderer"]["groundModes"] == ["simple", "plane"]

    document = (ROOT / "WORLD-METRICS.md").read_text(encoding="utf-8-sig")
    for token in (
        "WU", "TU", "ST", "world-z-up", "signed 16.8", "127/256",
        "ground.z", "world Z = ground.z", "Mode4NearProfile",
        "minimum accepted depth = 1 WU", "projection_divisor = max(2",
        "Sutherland-Hodgman", "post-clipping polygon",
        "three explicit profiles", "default", "late", "clip",
    ):
        assert token in document, token
    conclusion = document[document.index("## Audit conclusion / Conclusione dell'audit"):]
    assert "three explicit profiles" in conclusion
    assert "tre profili espliciti" in conclusion


def main() -> None:
    check_package_and_documentation()

    require('if ($AxisConvention -eq "world-z-up") {\n return @($Values[0], $Values[2], $Values[1])')
    assert SOURCE.count("Convert-SceneVectorToEngine") >= 7
    require("function Split-Fixed8")
    require("function Split-Fixed16_8")
    require("function Get-ObjectDepthExtensionBounds")
    require("function Validate-SceneObjectDepthDomains")
    require("Object depth validation failed for object")
    require("signed 16.8 integer domain=[-32768,32767]")

    # WU is the abstract linear unit, TU is 1/256 turn, and ST is the
    # normalized simulation tick. PAL and NTSC both target 50 ST/s.
    assert -8388608 / 256 == -32768
    assert 8388607 / 256 == 32767.99609375
    assert 1 / 256 == 0.00390625
    require("NTSC_SIM_TICKS_PER_6_VBLANKS = $05")
    require("advance_sim_tick:")

    # The default keeps 8 WU, while late and clip deliberately use an
    # independent 1-WU acceptance threshold with projection divisor 2.
    assert hex_constant("PROJ_CAMERA_FACE_MIN_DEPTH") == 8
    assert hex_constant("PROJ_VIEW_DEPTH_BIAS") == 190
    require('$Mode4ClipMinDepth = if ($Mode4LateNearRequested -or $Mode4CameraPlaneClipRequested) { 1 } else { 8 }')
    require('$Mode4ProjectionMinDivisor = if ($Mode4LateNearRequested -or $Mode4CameraPlaneClipRequested) { 2 } else { 8 }')
    require("camera_plane_clip_loaded_face:")
    require("camera_plane_classify_vertex:")
    require("camera_plane_original_facing:")

    # Ground is Z-up in authored coordinates; plane Ground remains line-only
    # in Mode 2 and uses post-clipping polygons in Modes 3–5.
    require('"world-z-up"')
    require("world ground mode 'plane' is available only in GraphicsMode 2, 3, 4, or 5")
    require("ground_vside = RUNTIME_BUFFER_END")
    require("RUNTIME_AFTER_GROUND = ground_vside + VERT_COUNT")

    # Public walk controls retain the frozen 127/256 WU/ST linear step.
    assert hex_constant("EXPLORER_MOVE_STEP") == 127
    assert hex_constant("EXPLORER_MOVE_SUBSTEPS_PER_TICK") == 1
    assert hex_constant("EXPLORER_YAW_PITCH_TICK_DIV") == 4
    assert hex_constant("EXPLORER_ROLL_TICK_DIV") == 2
    assert 127 / 256 * 50 == 24.8046875

    print("WORLD_METRICS_1_1_1 axes=pass depth=pass nearProfiles=default-late-clip ground=pass timing=pass")


if __name__ == "__main__":
    main()
