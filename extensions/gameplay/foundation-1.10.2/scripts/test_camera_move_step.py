#!/usr/bin/env python3
"""Host-side regression for the DEV5 single-substep walk translation."""
from __future__ import annotations

import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "work/build-3Dvibe64.ps1").read_text(encoding="utf-8").replace("\r\n", "\n")

MOVE_STEP = 127
DEV4_SUBSTEPS = 2
DEV5_SUBSTEPS = 1
MASK24 = (1 << 24) - 1
SIGN24 = 1 << 23


def require(token: str) -> None:
    assert token in SOURCE, f"camera movement contract missing: {token}"


def block(start: str, end: str) -> str:
    first = SOURCE.index(start)
    return SOURCE[first:SOURCE.index(end, first)]


def sin_q6(phase: int) -> int:
    return int(round(math.sin((phase & 0xFF) * 2.0 * math.pi / 256.0) * 64.0))


def mul_s6(a: int, b: int) -> int:
    sign = -1 if (a < 0) ^ (b < 0) else 1
    return sign * ((abs(a) * abs(b)) // 64)


def add24(value: int, delta: int) -> int:
    raw = (value + delta) & MASK24
    return raw - (1 << 24) if raw & SIGN24 else raw


def neg(axis: tuple[int, int, int]) -> tuple[int, int, int]:
    return tuple(-value for value in axis)


def axes(mode: str, yaw: int, roll: int) -> dict[str, tuple[int, int, int]]:
    siny = sin_q6(-yaw)
    cosy = sin_q6(-yaw + 64)
    forward = (siny, 0, cosy)
    if mode == "walkFull":
        sinz = sin_q6(-roll)
        cosz = sin_q6(-roll + 64)
        right = (mul_s6(cosy, cosz), -sinz, mul_s6(-siny, cosz))
        up = (mul_s6(cosy, sinz), cosz, mul_s6(-siny, sinz))
    else:
        right = (cosy, 0, -siny)
        up = (0, 64, 0)
    return {"W": forward, "S": neg(forward), "A": neg(right), "D": right, "Q": up, "E": neg(up)}


def active_directions(keys: set[str]) -> list[str]:
    result: list[str] = []
    for positive, negative in (("W", "S"), ("A", "D"), ("Q", "E")):
        if (positive in keys) ^ (negative in keys):
            result.append(positive if positive in keys else negative)
    return result


def tick(position: tuple[int, int, int], keys: set[str], mode: str, yaw: int, roll: int,
         substeps: int = DEV5_SUBSTEPS) -> tuple[int, int, int]:
    result = position
    basis = axes(mode, yaw, roll)
    for key in active_directions(keys):
        delta = tuple(mul_s6(component, MOVE_STEP) for component in basis[key])
        for _ in range(substeps):
            result = tuple(add24(value, change) for value, change in zip(result, delta))
    return result


def run(st: int, keys: set[str], mode: str, yaw: int, roll: int,
        substeps: int = DEV5_SUBSTEPS) -> tuple[int, int, int]:
    position = (0, 0, 0)
    for _ in range(st):
        position = tick(position, keys, mode, yaw, roll, substeps)
    return position


def main() -> None:
    controls = block("explorer_advance_camera_tick:", "explorer_prepare_motion_axes:")
    require("EXPLORER_MOVE_STEP = $7f")
    require("EXPLORER_MOVE_SUBSTEPS_PER_TICK = $01")
    require("NTSC_SIM_TICKS_PER_6_VBLANKS = $05")
    require("cmp #$06\n bcc svt_advance")
    for routine in (
        "explorer_move_forward", "explorer_move_back", "explorer_strafe_left",
        "explorer_strafe_right", "explorer_move_up", "explorer_move_down",
    ):
        assert controls.count(f"jsr {routine}") == 1, routine
    assert "and #$22\n beq eact_no_ws" in controls
    assert "beq eact_no_ad" in controls
    assert "beq eact_done\n jsr explorer_move_up" in controls
    assert "normalize" not in controls.lower()

    assert MOVE_STEP / 256 == 0.49609375
    assert MOVE_STEP * 50 / 256 == 24.8046875
    assert math.isclose(MOVE_STEP * 50 / (256 * 56), 0.4429408482142857)
    assert run(256, {"W"}, "walkLite", 0, 0) == (0, 0, 32512)
    assert run(256, {"W"}, "walkFull", 0, 0) == (0, 0, 32512)

    tested = 0
    comparison_failures = 0
    opposite_failures = 0
    samples: list[dict[str, object]] = []
    key_sets = (
        {"W"}, {"S"}, {"A"}, {"D"}, {"Q"}, {"E"},
        {"W", "A"}, {"W", "Q"}, {"A", "Q"}, {"W", "A", "Q"},
        {"W", "S"}, {"A", "D"}, {"Q", "E"},
    )
    for mode in ("walkLite", "walkFull"):
        rolls = (0,) if mode == "walkLite" else (0, 64, 128)
        for yaw in (0, 64, 128, 192):
            for roll in rolls:
                for keys in key_sets:
                    tested += 1
                    dev4 = run(128, keys, mode, yaw, roll, DEV4_SUBSTEPS)
                    dev5 = run(256, keys, mode, yaw, roll, DEV5_SUBSTEPS)
                    if dev4 != dev5:
                        comparison_failures += 1
                    if keys in ({"W", "S"}, {"A", "D"}, {"Q", "E"}) and dev5 != (0, 0, 0):
                        opposite_failures += 1
                    if len(samples) < 12:
                        samples.append({"mode": mode, "yawTU": yaw, "rollTU": roll,
                                        "keys": "+".join(sorted(keys)), "rawAfter256ST": dev5})
    assert comparison_failures == 0
    assert opposite_failures == 0

    diagonal2 = math.sqrt(2) * MOVE_STEP / 256
    diagonal3 = math.sqrt(3) * MOVE_STEP / 256
    assert math.isclose(diagonal2, 0.7015825094585276)
    assert math.isclose(diagonal3, 0.8592595801028808)
    assert 50 == 60 * 5 / 6

    print(json.dumps({
        "moveStepRaw": MOVE_STEP,
        "substepsPerST": DEV5_SUBSTEPS,
        "rawAfter256CardinalST": 32512,
        "wuPerST": MOVE_STEP / 256,
        "wuPerSecond": MOVE_STEP * 50 / 256,
        "cubeSidesPerSecond": MOVE_STEP * 50 / (256 * 56),
        "dev4NEqualsDev5TwoN": comparison_failures == 0,
        "testedTrajectories": tested,
        "oppositesCancel": opposite_failures == 0,
        "diagonalNormalized": False,
        "palSTPerSecond": 50,
        "ntscSTPerSecond": 50.0,
        "samples": samples,
    }, separators=(",", ":")))


if __name__ == "__main__":
    main()
