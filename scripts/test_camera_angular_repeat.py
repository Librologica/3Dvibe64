#!/usr/bin/env python3
"""Deterministic host model for DEV5 yaw, pitch, and roll repeat phases."""
from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "work/build-3Dvibe64.ps1").read_text(encoding="utf-8").replace("\r\n", "\n")

YAW_PITCH_DIV = 4
ROLL_DIV = 2


def require(token: str) -> None:
    assert token in SOURCE, f"angular repeat contract missing: {token}"


@dataclass
class RepeatAxis:
    divisor: int
    phase: int = 0
    value: int = 0
    updates: int = 0

    def tick(self, command: int, clamp: tuple[int, int] | None = None) -> bool:
        # 0 means released; 2 models simultaneous logical opposites.
        if command not in (-1, 1):
            self.phase = 0
            return False
        if self.phase:
            self.phase -= 1
            return False
        self.phase = self.divisor - 1
        candidate = self.value + command
        if clamp is not None:
            candidate = min(clamp[1], max(clamp[0], candidate))
        else:
            candidate &= 0xFF
        self.value = candidate
        self.updates += 1
        return True

    def reset(self, value: int = 0) -> None:
        self.phase = 0
        self.value = value


def held_updates(duration: int, divisor: int) -> int:
    axis = RepeatAxis(divisor)
    for _ in range(duration):
        axis.tick(1)
    return axis.updates


def ntsc_sim_ticks(vblanks: int) -> int:
    phase = 0
    ticks = 0
    for _ in range(vblanks):
        phase += 1
        if phase < 6:
            ticks += 1
        else:
            phase = 0
    return ticks


def main() -> None:
    require("EXPLORER_LOOK_STEP = $01")
    require("EXPLORER_YAW_PITCH_TICK_DIV = $04")
    require("EXPLORER_ROLL_TICK_DIV = $02")
    require("explorer_yaw_repeat_phase: .byte 0")
    require("explorer_pitch_repeat_phase: .byte 0")
    require("explorer_roll_repeat_phase: .byte 0")
    require("explorer_yaw_repeat_ready:")
    require("explorer_pitch_repeat_ready:")
    require("explorer_roll_repeat_ready:")
    require("sta explorer_yaw_repeat_phase\n sta explorer_pitch_repeat_phase")
    require("jsr explorer_init_camera\n lda #$01\n sta explorer_camera_tick_skip")

    expected_yaw_pitch = {0: 0, 1: 1, 2: 1, 3: 1, 4: 1, 5: 2, 9: 3, 256: 64}
    expected_roll = {0: 0, 1: 1, 2: 1, 3: 2, 4: 2, 5: 3, 256: 128}
    assert {n: held_updates(n, YAW_PITCH_DIV) for n in expected_yaw_pitch} == expected_yaw_pitch
    assert {n: held_updates(n, ROLL_DIV) for n in expected_roll} == expected_roll

    for direction in (-1, 1):
        yaw = RepeatAxis(YAW_PITCH_DIV)
        pitch = RepeatAxis(YAW_PITCH_DIV)
        roll = RepeatAxis(ROLL_DIV)
        for _ in range(256):
            yaw.tick(direction)
            pitch.tick(direction, (-64, 64))
            roll.tick(direction)
        assert yaw.updates == 64 and roll.updates == 128
        assert yaw.value == ((direction * 64) & 0xFF)
        assert pitch.value == direction * 64
        assert roll.value == ((direction * 128) & 0xFF)

    # Release and logical opposites both clear the phase. The next valid press
    # therefore updates immediately, including a direction remaining after an
    # opposed pair is released.
    for divisor in (YAW_PITCH_DIV, ROLL_DIV):
        axis = RepeatAxis(divisor)
        assert axis.tick(1)
        assert not axis.tick(1)
        assert not axis.tick(0) and axis.phase == 0
        assert axis.tick(-1)
        assert not axis.tick(2) and axis.phase == 0
        assert axis.tick(1)

    # Reset reinitializes both angle and repeat state. The reset ST itself is
    # skipped by explorer_camera_tick_skip; a still-held key updates on the next ST.
    reset_axis = RepeatAxis(YAW_PITCH_DIV)
    reset_axis.tick(1)
    reset_axis.tick(1)
    reset_axis.reset(17)
    assert reset_axis.phase == 0 and reset_axis.value == 17
    assert reset_axis.tick(1) and reset_axis.value == 18

    # Independent phases: each newly pressed axis responds immediately even if
    # another axis is already part-way through its repeat period.
    yaw = RepeatAxis(YAW_PITCH_DIV)
    pitch = RepeatAxis(YAW_PITCH_DIV)
    roll = RepeatAxis(ROLL_DIV)
    combined_trace: list[dict[str, object]] = []
    for st in range(1, 17):
        y = yaw.tick(1)
        p = pitch.tick(1 if st >= 3 else 0, (-64, 64))
        r = roll.tick(1 if st >= 2 else 0)
        combined_trace.append({"st": st, "yaw": y, "pitch": p, "roll": r})
    assert [x["st"] for x in combined_trace if x["yaw"]] == [1, 5, 9, 13]
    assert [x["st"] for x in combined_trace if x["pitch"]] == [3, 7, 11, 15]
    assert [x["st"] for x in combined_trace if x["roll"]] == [2, 4, 6, 8, 10, 12, 14, 16]

    # Pitch remains clamped even though repeat timing continues deterministically.
    pitch = RepeatAxis(YAW_PITCH_DIV, value=63)
    for _ in range(9):
        pitch.tick(1, (-64, 64))
    assert pitch.updates == 3 and pitch.value == 64

    # PAL and NTSC feed the exact same ST-domain controller. 307 NTSC VBlanks
    # produce the same 256 ST as 256 PAL VBlanks.
    assert ntsc_sim_ticks(307) == 256
    assert ntsc_sim_ticks(306) == 255
    assert 60 * 5 / 6 == 50

    print(json.dumps({
        "yawPitchDivisorST": YAW_PITCH_DIV,
        "rollDivisorST": ROLL_DIV,
        "firstPressImmediate": True,
        "yawPitchUpdates256ST": 64,
        "rollUpdates256ST": 128,
        "yawPitchDegreesPerSecond": 17.578125,
        "rollDegreesPerSecond": 35.15625,
        "releaseResetsPhase": True,
        "oppositesResetPhase": True,
        "resetMakesNextHeldTickImmediate": True,
        "independentPhases": True,
        "runtimeBytesWalkLite": 2,
        "runtimeBytesWalkFull": 3,
        "palVblanksFor256ST": 256,
        "ntscVblanksFor256ST": 307,
        "combinedTrace": combined_trace,
    }, separators=(",", ":")))


if __name__ == "__main__":
    main()
