#!/usr/bin/env python3
"""Gate D/E Mode 6 smoke test on x64sc/xscpu64, PAL/NTSC, normal/small."""
from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
from collections import Counter
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
BUILDER = ROOT / "work" / "build-3Dvibe64.ps1"
SCENE = ROOT / "examples" / "mode6-gouraud-shared-materials.json"
PRG = ROOT / "work" / "3Dvibe64.prg"
OUT = ROOT / "work" / "gouraud-validation"


def resolve_tool(env_name: str, executable: str) -> Path:
    configured = os.environ.get(env_name)
    found = configured or shutil.which(executable)
    assert found, f"Set {env_name} or add {executable} to PATH"
    path = Path(found).resolve()
    assert path.is_file(), f"{env_name} does not name a file: {path}"
    return path


def main() -> None:
    shell = shutil.which("pwsh") or shutil.which("powershell.exe")
    assert shell, "PowerShell is required"
    assert os.environ.get("TASS64_EXE") or shutil.which("64tass"), "Set TASS64_EXE or add 64tass to PATH"
    OUT.mkdir(parents=True, exist_ok=True)
    results: list[dict[str, object]] = []
    tools = (
        ("x64sc", resolve_tool("VICE_X64SC", "x64sc"), ()),
        ("xscpu64", resolve_tool("VICE_XSCPU64", "xscpu64"), ()),
        ("turbo6510", resolve_tool("VICE_TURBO6510", "x64sc_u"), ("-turbo6510", "1")),
    )
    for standard, viewport, vice_flag in (
        ("pal", "normal", "-pal"),
        ("pal", "small", "-pal"),
        ("ntsc", "normal", "-ntsc"),
        ("ntsc", "small", "-ntsc"),
    ):
        build = subprocess.run([
            shell, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(BUILDER),
            "-SceneFile", str(SCENE), "-GraphicsMode", "6", "-Quality", "fast",
            "-Projection", "extended-table", "-MemoryLayout", "high-basic-v2",
            "-CameraViewport", viewport, "-VideoStandard", standard,
            "-NoFpsOverlay", "-SkipCmdUpdate",
        ], cwd=ROOT, text=True, capture_output=True)
        assert build.returncode == 0, build.stdout + build.stderr
        assert PRG.is_file()

        for name, tool, extra_args in tools:
            screenshot = OUT / f"mode6-shared-{standard}-{viewport}-{name}.png"
            if screenshot.exists():
                screenshot.unlink()
            subprocess.run([
                str(tool), "-console", "-warp", "-sounddev", "dummy", vice_flag,
                "-autostartprgmode", "1", "-autostart", str(PRG),
                *extra_args, "-limitcycles", "12000000", "-exitscreenshot", str(screenshot),
            ], cwd=ROOT, text=True, capture_output=True, timeout=60)
            assert screenshot.is_file() and screenshot.stat().st_size > 1000, f"{standard}/{viewport}/{name} screenshot missing"
            image = Image.open(screenshot).convert("RGB")
            colors = Counter(image.get_flattened_data())
            background, background_pixels = colors.most_common(1)[0]
            object_pixels = image.width * image.height - background_pixels
            assert object_pixels > 1000, f"{standard}/{viewport}/{name} did not render the Mode 6 objects"
            assert len(colors) >= 4, f"{standard}/{viewport}/{name} did not expose the material/dither palette"
            results.append({
                "emulator": name, "videoStandard": standard, "viewport": viewport,
                "screenshot": str(screenshot.relative_to(ROOT)).replace("\\", "/"),
                "sha256": hashlib.sha256(screenshot.read_bytes()).hexdigest(),
                "dimensions": [image.width, image.height], "uniqueRgb": len(colors),
                "backgroundRgb": list(background), "objectPixels": object_pixels,
            })

    print(json.dumps({"gateD": "pass", "results": results}, separators=(",", ":")))


if __name__ == "__main__":
    main()
