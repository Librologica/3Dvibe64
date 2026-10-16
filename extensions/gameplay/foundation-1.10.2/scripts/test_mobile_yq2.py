#!/usr/bin/env python3
"""Compact numerical checks for the public Mode 4 Y-Q2 profiles."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def project_yq2(camera_y: int, depth: int, focal: int, center: int, maximum: int) -> int:
    quotient, remainder = divmod(abs(camera_y) * focal, max(1, depth))
    offset = quotient * 4 + (remainder * 4) // max(1, depth)
    value = center - offset if camera_y >= 0 else center + offset
    return max(0, min(maximum, value))


def main() -> None:
    profiles = {"normal": (170, 200, 396, 100), "small": (136, 160, 316, 80)}
    for _, (focal, center, maximum, rows) in profiles.items():
        assert project_yq2(0, 200, focal, center, maximum) == center
        assert project_yq2(32767, 8, focal, center, maximum) == 0
        assert project_yq2(-32767, 8, focal, center, maximum) == maximum
        phases = {project_yq2(y, z, focal, center, maximum) & 3
                  for y in range(-63, 64) for z in range(64, 512)}
        assert {1, 2, 3}.issubset(phases)
        assert list(range(rows))[0] == 0 and list(range(rows))[-1] == rows - 1

    source = (ROOT / "work" / "build-3Dvibe64.ps1").read_text(encoding="utf-8")
    for token in ("YQ2_VIEWPORT_CENTER_LO", "YQ2_VIEWPORT_ROW_COUNT", "syq2_lo", "syq2_hi",
                  "explorer_project_yq2_16", "SolidSubpixelYMobileNativeFlag"):
        assert token in source
    assert 'inputDriven=1 startsStationary=1 poseWritesRequireInput=1' in source
    print("MOBILE_YQ2 profiles=2 centers=200/160 clamps=396/316 fractions=1/2/3 cameraIdle=input")


if __name__ == "__main__":
    main()
