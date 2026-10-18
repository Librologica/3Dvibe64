#!/usr/bin/env python3
"""Bit-exact host verification for the Gate 1 Mode 6 Bayer LUT."""

from __future__ import annotations

import re
import os
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BAYER = (0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5)
PAIR = {
    1: (0x40, 0x10, 0x04, 0x01),
    2: (0x80, 0x20, 0x08, 0x02),
    3: (0xC0, 0x30, 0x0C, 0x03),
}


def old_code(shade: int, x: int, y: int) -> int:
    threshold = BAYER[(y & 3) * 4 + (x & 3)]
    if shade <= 16:
        slot = 2 if threshold < shade else 1
    else:
        slot = 3 if threshold < shade - 16 else 2
    return PAIR[slot][x & 3]


def parse_table(source: str, label: str) -> list[int]:
    match = re.search(
        rf"(?ms)^{re.escape(label)}:\s*\n((?:\s*\.byte[^\n]*\n)+)", source
    )
    assert match, f"missing table: {label}"
    values: list[int] = []
    for token in re.findall(r"\$([0-9A-Fa-f]{2})", match.group(1)):
        values.append(int(token, 16))
    return values


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="3dvibe64-lut-") as temporary:
        sdk = Path(temporary) / "sdk"
        shutil.copytree(ROOT, sdk, ignore=shutil.ignore_patterns("__pycache__"))
        shell = shutil.which("pwsh") or shutil.which("powershell.exe")
        assert shell, "PowerShell is required"
        run = subprocess.run([shell, "-NoProfile", "-File", str(sdk / "work/build-3Dvibe64.ps1"),
            "-SceneFile", str(sdk / "examples/mode6-gouraud-torus.json"), "-GraphicsMode", "6",
            "-MemoryLayout", "high-basic-v2", "-Quality", "fast", "-Projection", "extended-table",
            "-NoFpsOverlay", "-SkipCmdUpdate"], cwd=sdk, env=os.environ.copy(), text=True, capture_output=True)
        assert run.returncode == 0, run.stdout + run.stderr
        variant = "release-1.3.0"
        asm = sdk / "work/3Dvibe64.asm"
        source = asm.read_text(encoding="ascii")
        total = 0
        for y in range(4):
            table = parse_table(source, f"gouraud_bayer_code_lut_y{y}")
            assert len(table) == 132, (variant, y, len(table))
            for shade in range(33):
                for x in range(4):
                    actual = table[shade * 4 + x]
                    expected = old_code(shade, x, y)
                    assert actual == expected, (variant, shade, x, y, actual, expected)
                    total += 1
        assert total == 528
        assert "gpsp_lut_load:" in source
        assert "lda gouraud_bayer_code_lut_y0,y" in source
        print(f"PASS {variant}: {total} LUT entries are bit-exact")


if __name__ == "__main__":
    main()
