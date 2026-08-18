#!/usr/bin/env python3
"""Isolated DEV7/DEV7.1 Generic Text and FPS split-screen contract."""
from __future__ import annotations

import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BUILDER = ROOT / "work" / "build-3Dvibe64.ps1"
SCENE = ROOT / "examples" / "basic-solid-reference.json"
HEADER_TEXT = "SS 00. SCRITTA DI TESTO"
GLYPHS = {
    " ": 0, "0": 1, "1": 2, "2": 3, "3": 4, "4": 5,
    "5": 6, "6": 7, "7": 8, "8": 9, "9": 10, ".": 11,
    "S": 12, "C": 13, "R": 14, "I": 15, "T": 16, "A": 17,
    "D": 18, "E": 19, "M": 20, "P": 21, "O": 22,
}
EXPECTED = bytes(GLYPHS[character] for character in HEADER_TEXT)
HEADER_OFFSET = (40 - len(HEADER_TEXT)) // 2


def resolve_executable(env_names: tuple[str, ...], names: tuple[str, ...]) -> Path:
    for env_name in env_names:
        value = os.environ.get(env_name, "").strip()
        if value:
            candidate = Path(value)
            if candidate.is_file():
                return candidate.resolve()
            if candidate.is_dir():
                for name in names:
                    nested = candidate / name
                    if nested.is_file():
                        return nested.resolve()
    for name in names:
        found = shutil.which(name)
        if found:
            return Path(found).resolve()
    raise AssertionError(f"required executable missing: set {env_names} or add {names} to PATH")


def build(root: Path, video: str, *extra: str) -> tuple[Path, Path]:
    command = [
        "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
        str(root / "work" / "build-3Dvibe64.ps1"),
        "-SceneFile", str(root / "examples" / "basic-solid-reference.json"),
        "-GraphicsMode", "4", "-CameraMode", "fixed", "-CameraViewport", "normal",
        "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable",
        "-HeaderText", HEADER_TEXT, "-FpsOverlayOnStart", "-VideoStandard", video,
        "-SkipCmdUpdate", *extra,
    ]
    result = subprocess.run(command, cwd=root, text=True, capture_output=True, check=False)
    assert result.returncode == 0, result.stdout + result.stderr
    return root / "work" / "3Dvibe64.asm", root / "work" / "3Dvibe64.prg"


def labels(path: Path) -> dict[str, int]:
    result: dict[str, int] = {}
    pattern = re.compile(r"^al\s+([0-9a-fA-F]+)\s+\.(\S+)$")
    for line in path.read_text(encoding="ascii").splitlines():
        match = pattern.match(line.strip())
        if match:
            result[match.group(2)] = int(match.group(1), 16)
    return result


def ram_from_snapshot(path: Path) -> memoryview:
    snapshot = path.read_bytes()
    module = snapshot.index(b"C64MEM")
    start = module + 16 + 2 + 4 + 4
    ram = memoryview(snapshot)[start : start + 65536]
    assert len(ram) == 65536
    return ram


def static_contract(asm: str) -> None:
    for token in (
        "TEXT_HEADER_CELL_ROWS = 3",
        "TEXT_HEADER_SCREEN_BYTES = TEXT_HEADER_CELL_ROWS * 40",
        "TEXT_BODY_FIRST_RASTER = $4B",
        "TEXT_BITMAP_IRQ_RASTER = $4A",
        "CAMERA_VIEWPORT_HEIGHT = $58",
        "CAMERA_VIEWPORT_ORIGIN_Y = $0C",
        "TEXT_CHARSET_GLYPH_COUNT = $17",
        "TEXT_CHARSET_BYTES = TEXT_CHARSET_GLYPH_COUNT * 8",
        "FPS_FONT_BYTE_COUNT = TEXT_CHARSET_BYTES",
    ):
        assert token in asm, token
    match = re.search(r"(?m)^text_header_string:\s*\.byte\s+([^\r\n]+)$", asm)
    assert match, "text_header_string missing"
    emitted = bytes(int(item.strip().removeprefix("$"), 16) for item in match.group(1).split(","))
    assert emitted == EXPECTED + b"\xff", (emitted, EXPECTED)
    material = asm[asm.index("apply_active_material:") : asm.index("load_face_material:")]
    assert "ldx #TEXT_HEADER_SCREEN_BYTES" in material
    assert "sta $5c00,x" in material and "sta SCREEN_B_BASE,x" in material
    assert "cpx #$e8" in material
    bitmap_mode = asm[asm.index("set_bitmap_body_mode:") : asm.index("fps_frame_done:")]
    assert "lda drawbuf" in bitmap_mode
    assert "ora #VIC_BANK_B_BITS" in bitmap_mode and "lda #VIC_D018_B" in bitmap_mode
    toggle = asm[asm.index("poll_fps_key:") : asm.index("scan_fps_key:")]
    assert "jsr wait_text_charset_safe" in toggle
    assert "jsr update_text_charset" in toggle
    assert "jsr switch_frame_barrier" not in toggle


def run_vice(vice: Path, tass: Path, sandbox: Path, video: str) -> None:
    asm_path, prg_path = build(sandbox, video)
    asm = asm_path.read_text(encoding="utf-8", errors="replace")
    static_contract(asm)

    validation = sandbox / "validation" / f"dev7-{video}"
    validation.mkdir(parents=True, exist_ok=True)
    labeled_prg = validation / "text-split.prg"
    label_path = validation / "text-split.vice.labels"
    assembled = subprocess.run(
        [str(tass), "-a", "-B", "-o", str(labeled_prg), f"--labels={label_path}",
         "--vice-labels-numeric", str(asm_path)],
        cwd=sandbox, text=True, capture_output=True, check=False,
    )
    assert assembled.returncode == 0, assembled.stdout + assembled.stderr
    assert labeled_prg.read_bytes() == prg_path.read_bytes()
    symbols = labels(label_path)
    required = {"render_frame_end", "SCREEN_B_BASE", "BITMAP_B_BASE", "fps_font_bytes"}
    assert required <= symbols.keys(), sorted(required - symbols.keys())

    snapshot = validation / "frame32.vsf"
    monitor = validation / "frame32.mon"
    monitor.write_text(
        f'load_labels "{label_path.resolve().as_posix()}"\n'
        "trace .render_frame_end\n"
        "ignore 1 31\n"
        f'command 1 "dump \\"{snapshot.resolve().as_posix()}\\""\n'
        "x\n",
        encoding="ascii",
    )
    machine_flag = "-pal" if video == "pal" else "-ntsc"
    run = subprocess.run(
        [str(vice), "-default", "+confirmonexit", "-console", "-warp", machine_flag,
         "-VICIIfilter", "0", "-joydev2", "4", "-autostartprgmode", "1",
         "-initbreak", "ready", "-moncommands", str(monitor), "-limitcycles",
         "60000000", str(labeled_prg)],
        cwd=sandbox, text=True, capture_output=True, check=False, timeout=180,
    )
    assert snapshot.is_file(), f"{video}: no frame32 snapshot; exit={run.returncode}\n{run.stdout}\n{run.stderr}"
    assert run.returncode in (0, 1), f"{video}: VICE exit {run.returncode}"

    memory = ram_from_snapshot(snapshot)
    screen_a = 0x5C00
    screen_b = symbols["SCREEN_B_BASE"]
    text_offset = 40 + HEADER_OFFSET
    assert bytes(memory[screen_a + text_offset : screen_a + text_offset + len(EXPECTED)]) == EXPECTED
    assert bytes(memory[screen_b + text_offset : screen_b + text_offset + len(EXPECTED)]) == EXPECTED
    fps_a = bytes(memory[screen_a + 40 : screen_a + 44])
    fps_b = bytes(memory[screen_b + 40 : screen_b + 44])
    assert fps_a == fps_b and fps_a[2] == GLYPHS["."]
    assert all(1 <= value <= 10 for value in (fps_a[0], fps_a[1], fps_a[3]))
    assert bytes(memory[screen_a : screen_a + 120]) == bytes(memory[screen_b : screen_b + 120])
    font = symbols["fps_font_bytes"]
    font_bytes = bytes(memory[font : font + 184])
    assert bytes(memory[0x6000 : 0x6000 + 184]) == font_bytes
    assert bytes(memory[symbols["BITMAP_B_BASE"] : symbols["BITMAP_B_BASE"] + 184]) == font_bytes


def layout_contract(sandbox: Path) -> None:
    command = [
        "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
        str(sandbox / "work" / "build-3Dvibe64.ps1"),
        "-SceneFile", str(sandbox / "examples" / "basic-solid-reference.json"),
        "-GraphicsMode", "5", "-CameraMode", "fixed", "-CameraViewport", "small",
        "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "high-basic-v2",
        "-HeaderText", HEADER_TEXT, "-FpsOverlayOnStart", "-SkipCmdUpdate",
    ]
    result = subprocess.run(command, cwd=sandbox, text=True, capture_output=True, check=False)
    assert result.returncode == 0, result.stdout + result.stderr
    asm = (sandbox / "work" / "3Dvibe64.asm").read_text(encoding="utf-8", errors="replace")
    assert "fps_font_return = *\n* = $1f00" in asm
    assert "CAMERA_VIEWPORT_HEIGHT = $50" in asm and "CAMERA_VIEWPORT_ORIGIN_Y = $0C" in asm

    no_split = command.copy()
    no_split[no_split.index("-HeaderText") : no_split.index("-HeaderText") + 4] = ["-NoFpsOverlay"]
    no_split[no_split.index("5")] = "4"
    no_split[no_split.index("small")] = "normal"
    no_split[no_split.index("high-basic-v2")] = "stable"
    result = subprocess.run(no_split, cwd=sandbox, text=True, capture_output=True, check=False)
    assert result.returncode == 0, result.stdout + result.stderr
    asm = (sandbox / "work" / "3Dvibe64.asm").read_text(encoding="utf-8", errors="replace")
    assert "FPS_OVERLAY_ENABLE = $00" in asm
    assert "CAMERA_VIEWPORT_HEIGHT = $64" in asm and "CAMERA_VIEWPORT_ORIGIN_Y = $00" in asm


def main() -> None:
    tass = resolve_executable(("TASS64_EXE", "TASS64_PATH"), ("64tass.exe", "64tass"))
    vice = resolve_executable(("VICE_X64SC", "VICE_EXE"), ("x64sc.exe", "x64sc"))
    with tempfile.TemporaryDirectory(prefix="3dvibe64-1.1.2-dev7-") as temporary:
        sandbox = Path(temporary) / "sdk"
        shutil.copytree(ROOT, sandbox)
        layout_contract(sandbox)
        run_vice(vice, tass, sandbox, "pal")
        run_vice(vice, tass, sandbox, "ntsc")
    print("DEV7_TEXT_SPLIT generic=A/B fps=A/B header=120 mapping=DEV7.1 stable=pass high-basic-v2=pass PAL=pass NTSC=pass")


if __name__ == "__main__":
    main()
