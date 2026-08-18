#!/usr/bin/env python3
"""Self-contained public 3Dvibe64 1.1.2 source-SDK contract."""
from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BUILDER_RELATIVE = Path("work/build-3Dvibe64.ps1")
VERSION = "1.1.2"
BUILDER_SHA256 = "8B16C2CB523403516B8AE667A7E1DEB21997BD03084ED6705F51F021D816997E"
PERMANENT_FILE_COUNT = 45
POINT_FIXED_MESSAGE = "Camera-plane culling requires three non-collinear vertices in face 0"

GROUND_FRAMEBUFFER_SHA256 = {
    4: "40832038ECC0F8615BEF3F6B51ED2CE1ADC0C584E19DE871A353A926A8B7C8BB",
    5: "B9D482F56D5051C8B32F82ECF1E78AEA71C2CBC1C63FB141393FA0DFEA7DFC79",
}

GROUND_ROLL_FRAMEBUFFER_SHA256 = {
    (3, 0): "F5B4F305F0782D1140618E9FA1273559EF5EE3E2BABBF0A7FF13C3411FB7436F",
    (3, 32): "E05B1124A1788637C15C070420D1A2CD4189B463E038FCAF250B8ED8EB18036C",
    (3, 64): "8D8F01EAB635F1FC7F5DB780D90F779D94136DE541CE502EC908C620E2A36DD0",
    (3, 224): "A7BB81309B574612A9D5239FC6BDB95593879466608E814397D14E35A56CC29A",
    (4, 0): "4EB770CA4A276A342E5F08E7764E5E8D9EBC68551F075A0126FD4DECC148EA25",
    (4, 32): "00133E33FE38A9DB0EBAD117A71DF67EFCD81C384352CBF3689E24CB759B4A38",
    (4, 64): "21CD9D3B11564FB2A1D6F0431AC9F042798523725A155AEB2AB3AFF8F3754866",
    (4, 224): "290883B35998F75A56DF1315CB35D634BBA19C915D8AB6AD141977BFDD1CD41C",
    (5, 0): "64E0DC7EDFDE6ADB9EE98652820F8C32F87C471D5FEFC539FB319834C832C358",
    (5, 32): "B5E9495ACD5185E0173EB68962D135EE1BAED5D84FAB47992D048B7AACBD011A",
    (5, 64): "1FCE7776D5181E7909F56AD36B1A1422AB2FBEC3C443BB6D4D2F2D246DD07FBC",
    (5, 224): "1E3510D4EECE51EC3205155FFC64AA09AF04A98DE0B0B404D3FC75EF68686561",
}

GROUND_FRAMEBUFFER_SCENE = {
    "schema": 1,
    "name": "ground_plane_crossing_framebuffer_contract",
    "graphicsMode": 4,
    "axisConvention": "world-z-up",
    "world": {
        "backgroundColor": 0,
        "grounds": [{"id": "plane", "enabled": True, "mode": "plane", "z": 0, "color": 12, "occlude": True}],
    },
    "camera": {"id": "camera", "mode": "walkFull", "position": [0, -60, 46], "rotation": [0, 0, 0]},
    "lights": [{"id": "key", "type": "static", "position": [-60, -30, 90], "intensity": 10}],
    "meshes": [{"id": "cube", "type": "mesh", "geometry": "solid", "materialProfile": "single", "builtin": "cube"}],
    "objects": [
        {
            "id": "crossing_left", "mesh": "cube", "position": [-70, 260, 32],
            "rotation": [12, 38, 64], "angularVelocity": [0, 0, 0], "scale": 0.80,
            "visible": True, "material": "red", "reflectivity": "satin",
        },
        {
            "id": "crossing_center", "mesh": "cube", "position": [0, 260, 32],
            "rotation": [86, 17, 141], "angularVelocity": [0, 0, 0], "scale": 0.80,
            "visible": True, "material": "green", "reflectivity": "satin",
        },
        {
            "id": "crossing_right", "mesh": "cube", "position": [70, 260, 32],
            "rotation": [159, 96, 28], "angularVelocity": [0, 0, 0], "scale": 0.80,
            "visible": True, "material": "blue", "reflectivity": "satin",
        },
    ],
    "contract": {"version": 1, "worldSpace": "world-z-up", "objectSpace": "aligned-world", "viewportProfile": "normal", "ground": True},
}

GROUND_ROLL_FRAMEBUFFER_SCENE = {
    "schema": 1,
    "name": "ground_plane_roll_framebuffer_contract",
    "graphicsMode": 4,
    "axisConvention": "world-z-up",
    "world": {
        "backgroundColor": 0,
        "grounds": [{"id": "plane", "enabled": True, "mode": "plane", "z": 0, "color": 12, "occlude": True}],
    },
    "camera": {"id": "camera", "mode": "walkFull", "position": [0, -60, 46], "rotation": [0, 0, 0]},
    "lights": [{"id": "key", "type": "static", "position": [-60, -30, 90], "intensity": 10}],
    "meshes": [{"id": "cube", "type": "mesh", "geometry": "solid", "materialProfile": "single", "builtin": "cube"}],
    "objects": [{"id": "above", "mesh": "cube", "position": [0, 260, 52], "rotation": [20, 35, 57], "angularVelocity": [0, 0, 0], "scale": 0.80, "visible": True, "material": "yellow", "reflectivity": "satin"}],
    "contract": {"version": 1, "worldSpace": "world-z-up", "objectSpace": "aligned-world", "viewportProfile": "normal", "ground": True},
}

SHARED_RGB_FRAMEBUFFER_SCENE = {
    "schema": 1,
    "name": "shared_rgb_material_override_framebuffer_contract",
    "graphicsMode": 4,
    "meshSourceSharing": True,
    "axisConvention": "world-z-up",
    "world": {"backgroundColor": 0, "grounds": []},
    "camera": {"id": "camera", "mode": "fixed", "position": [0, -60, 0], "rotation": [0, 0, 0]},
    "lights": [{"id": "key", "type": "static", "position": [-40, -20, 60], "intensity": 10}],
    "meshes": [{"id": "shared_cube", "type": "mesh", "geometry": "solid", "materialProfile": "single", "builtin": "cube"}],
    "objects": [
        {"id": "red_cube", "mesh": "shared_cube", "position": [-50, 120, 0], "rotation": [18, 22, 0], "scale": 0.55, "visible": True, "materialOverride": "red"},
        {"id": "green_cube", "mesh": "shared_cube", "position": [0, 120, 0], "rotation": [18, 22, 0], "scale": 0.55, "visible": True, "materialOverride": "green"},
        {"id": "blue_cube", "mesh": "shared_cube", "position": [50, 120, 0], "rotation": [18, 22, 0], "scale": 0.55, "visible": True, "materialOverride": "blue"},
    ],
}

REFERENCE_BUILDS = (
    ("mode1-wire-reference", "examples/basic-solid-reference.json", "D6091440121F8F8ABA3086D72551E2C886469E4F38E00388A844D76222AC2682", ("-GraphicsMode", "1", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable")),
    ("mode2-hidden-wire-reference", "examples/basic-solid-reference.json", "726C32CBDB26EE0030F20043CA10FAA265DF5114E99EC1D0E29127DF4B336880", ("-GraphicsMode", "2", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable")),
    ("mode3-static-solid-reference", "examples/basic-solid-reference.json", "459CB92DEDCC59A42AC25463602188C7638DE7BEE965CBA91A3BE4419590F6B2", ("-GraphicsMode", "3", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable")),
    ("mode4-dynamic-solid-normal-reference", "examples/basic-solid-reference.json", "27B4EDCD3ACC2FA35F2227B6972BAFEB8C402966ED0EE353ACBEBED3F29775CF", ("-GraphicsMode", "4", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable")),
    ("mode4-dynamic-solid-small-reference", "examples/basic-solid-reference.json", "D25ED041E53B2C19B9F3E2B46B6C110CE3B90670B52A8888BCD1599879274C8A", ("-GraphicsMode", "4", "-CameraMode", "fixed", "-CameraViewport", "small", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable")),
    ("mode4-walkLite-reference", "examples/mode4-walkfull-reference.json", "CE534BBEB406F7428B0012F7BF0A5B2EAE2312323203E2058DAF9E80D4EE6434", ("-GraphicsMode", "4", "-CameraMode", "walkLite", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable")),
    ("mode4-walkFull-auto-reference", "examples/mode4-walkfull-reference.json", "2A794961A62FF2ABF2CB32AFC0D7CEF01E6149D1D224E0873F515C600064AE07", ("-GraphicsMode", "4", "-CameraMode", "walkFull", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-VideoStandard", "auto")),
    ("mode4-walkFull-PAL-reference", "examples/mode4-walkfull-reference.json", "F22CC753350F594BC9497412121072DC2237E4BC332AD48E3B1DB2A0E5F89FE7", ("-GraphicsMode", "4", "-CameraMode", "walkFull", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-VideoStandard", "pal")),
    ("mode4-walkFull-NTSC-reference", "examples/mode4-walkfull-reference.json", "36DC6F6F76347120311221BB018F5889A0AF409059CA568546FDBF78985237DD", ("-GraphicsMode", "4", "-CameraMode", "walkFull", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-VideoStandard", "ntsc")),
    ("mode4-satin-material-reference", "examples/static-satin-material-reference.json", "20D8B6889BD39E731EF584477C1E369351B2D44E9977B3856CEAD2CEAA087EA6", ("-GraphicsMode", "4", "-CameraMode", "walkFull", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable")),
    ("mode4-reflective-material-reference", "examples/dynamic-reflective-material-reference.json", "6AEEB2A738857F4359CA6A329267E2D4B5933E0BBAA15750ABEB214F361B13A5", ("-GraphicsMode", "4", "-CameraMode", "walkFull", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable")),
)

TWO_COLOR_BUILDS = (
    ("mode1-two-color-wire-reference", "C81F5C79825DDC01171EB84EB2FE1C8A90C356AC9EFCDFD480A40EC56D35B90F", ("-GraphicsMode", "1", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-NoFpsOverlay")),
    ("mode2-two-color-hidden-wire-reference", "2B5598C68758D269DF739E2D944DAE53091DC5B1B99D183FDD17E0F1F3DC250D", ("-GraphicsMode", "2", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-NoFpsOverlay")),
)

# Build the search expressions from fragments so the public tree does not itself
# contain the retired production labels as plain text.
FORBIDDEN_TERMS = tuple(
    "".join(parts) for parts in (
        ("Star", "field"), ("Star ", "Frontier"), ("Boi", "ng Ball"),
        ("Cast", "le"), ("official", " demo"), ("demo", " ufficiale"),
        ("official", " PRG"), ("PRG", " ufficiale"),
        ("official", " artifact"), ("artefatto", " ufficiale"),
        ("validation", " demo"), ("demo", " di validazione"),
    )
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def package_files(root: Path) -> set[str]:
    return {
        path.relative_to(root).as_posix()
        for path in root.rglob("*")
        if path.is_file()
    }


def read_json(root: Path, relative: str) -> dict:
    return json.loads((root / relative).read_text(encoding="utf-8-sig"))


def check_manifest() -> None:
    entries: dict[str, str] = {}
    manifest = ROOT / "MANIFEST.sha256"
    for line in manifest.read_text(encoding="utf-8-sig").splitlines():
        digest, separator, relative = line.partition("  ")
        assert separator and len(digest) == 64 and relative, f"malformed manifest line: {line!r}"
        assert relative not in entries, f"duplicate manifest entry: {relative}"
        path = ROOT / relative
        assert path.is_file(), f"manifest path missing: {relative}"
        assert sha256(path) == digest.upper(), f"manifest hash mismatch: {relative}"
        entries[relative] = digest.upper()
    actual = package_files(ROOT) - {"MANIFEST.sha256"}
    assert set(entries) == actual, f"manifest tree mismatch: missing={sorted(actual-set(entries))} extra={sorted(set(entries)-actual)}"
    assert len(actual) + 1 == PERMANENT_FILE_COUNT, len(actual) + 1


def check_clean_tree() -> None:
    forbidden_suffixes = {".asm", ".lst", ".log", ".trace", ".tmp", ".png", ".bmp", ".gif", ".vice", ".cmd", ".zip"}
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        assert path.suffix.lower() not in forbidden_suffixes, f"temporary output included: {path.relative_to(ROOT)}"
        assert path.suffix.lower() != ".prg", f"precompiled program included: {path.relative_to(ROOT)}"
    assert not (ROOT / "artifacts").exists(), "packaged binary-artifact directory included"
    assert not (ROOT / "work" / "3Dvibe64.prg").exists()
    assert not (ROOT / "work" / "3Dvibe64.asm").exists()


def check_no_retired_references() -> None:
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        relative = path.relative_to(ROOT).as_posix()
        haystack = relative.casefold()
        if path.suffix.lower() in {".md", ".json", ".py", ".ps1", ".sha256"}:
            haystack += "\n" + path.read_text(encoding="utf-8-sig", errors="replace").casefold()
        for term in FORBIDDEN_TERMS:
            assert term.casefold() not in haystack, f"retired production reference {term!r}: {relative}"


def check_builder_and_package() -> None:
    builder = ROOT / BUILDER_RELATIVE
    assert sha256(builder) == BUILDER_SHA256, "builder hash changed"
    manifest = read_json(ROOT, "PACKAGE-MANIFEST.json")
    assert manifest["package"] == {
        "name": "3Dvibe64", "displayName": "3Dvibe64 1.1.2", "version": VERSION,
        "distribution": "source-sdk", "permanentFiles": PERMANENT_FILE_COUNT,
        "precompiledPrograms": False,
        "author": "librologica.digital",
        "softwareLicense": "PolyForm-Noncommercial-1.0.0",
        "documentationLicense": "CC-BY-NC-4.0",
    }
    assert manifest["builder"]["sha256"] == BUILDER_SHA256
    assert len(manifest["examples"]) == 8
    assert len(manifest["referenceBuilds"]) == 11
    assert manifest["renderer"]["nearProfiles"]["modes"] == [3, 4, 5]
    assert manifest["renderer"]["faceCullProfiles"]["modes"] == [4, 5]
    assert manifest["sharedScenes"]["supportedModes"] == [4, 5]
    assert manifest["textSplit"] == {
        "headerRows": 3, "headerScreenBytes": 120,
        "bodyFirstRaster": 75, "bitmapIrqRaster": 74,
        "normalBody": {"width": 160, "height": 88, "originY": 12},
        "smallBody": {"width": 128, "height": 80, "originY": 12},
        "headerTextOption": "HeaderText", "headerTextMaxCharacters": 40,
        "terminator": 255, "runtimeToggle": "complete-header",
        "fpsOnlyCharsetBytes": 96, "genericTextCharsetBytes": 184,
        "charsetLengthDerivedFromGlyphCount": True,
        "fpsDoubleBuffered": True, "sameBank": True,
    }
    framebuffer = manifest["runtimeFramebufferRegression"]
    assert framebuffer["frames"] == 32 and framebuffer["modes"] == [4, 5]
    assert framebuffer["mode4"] == GROUND_FRAMEBUFFER_SHA256[4]
    assert framebuffer["mode5"] == GROUND_FRAMEBUFFER_SHA256[5]
    roll_framebuffer = manifest["runtimeGroundRollFramebufferRegression"]
    assert roll_framebuffer["frames"] == 32 and roll_framebuffer["modes"] == [3, 4, 5]
    assert roll_framebuffer["rolls"] == [0, 32, 64, 224]
    assert roll_framebuffer["signatures"] == {f"mode{mode}-roll{roll}": digest for (mode, roll), digest in GROUND_ROLL_FRAMEBUFFER_SHA256.items()}
    source = builder.read_text(encoding="utf-8")
    for token in (
        'meshSourceSharing is supported only in GraphicsMode 4 and 5',
        'meshSourceSharing requires at least one source mesh referenced by multiple instances',
        '[ValidateSet("default", "late", "clip")]',
        '[ValidateSet("default", "stable")]',
        'STATIC_RUNTIME_LIGHT', 'MESH_SOURCE_SHARING_RUNTIME',
        'bucket_face_instance', 'bucket_face_local',
        'camera_plane_project_clip_a_vertex', 'camera_plane_project_clip_a_loaded_depth',
        'scene timeline tickRate must be 50',
        "Camera-plane culling requires three non-collinear vertices in face $faceIndex",
        'TEXT_HEADER_CELL_ROWS = 3', 'TEXT_HEADER_SCREEN_BYTES = TEXT_HEADER_CELL_ROWS * 40',
        'TEXT_BODY_FIRST_RASTER = $4B', 'TEXT_BITMAP_IRQ_RASTER = $4A',
        '[string]$HeaderText = ""', 'TEXT_CHARSET_GLYPH_COUNT = $17',
        'TEXT_CHARSET_BYTES = TEXT_CHARSET_GLYPH_COUNT * 8',
    ):
        assert token in source, f"builder contract missing: {token}"


def check_documentation() -> None:
    assert (ROOT / "VERSION").read_text(encoding="utf-8-sig").strip() == VERSION
    main = (ROOT / "README.md").read_text(encoding="utf-8-sig")
    assert main.startswith("# 3Dvibe64 1.1.2\n")
    for token in ("source SDK", "no precompiled PRG", "GraphicsMode 1–5", "meshSourceSharing", "FaceCullProfile", "Mode4NearProfile"):
        assert token in main, f"README.md does not document {token}"
    for token in ("HeaderText", "160×88", "TEXT_HEADER_SCREEN_BYTES"):
        assert token in main, f"README.md does not document DEV7 token {token}"
    for relative in ("README.en.md", "README.it.md"):
        text = (ROOT / relative).read_text(encoding="utf-8-sig").lower()
        for token in ("graphicsmode 5", "walklite", "walkfull", "high-basic-v2", "mode4nearprofile", "facecullprofile", "meshsourcesharing", "materialoverride", "reflectivityoverride", "coloroverride", "faceoverrides", "tickrate", "resetkey", "visible", "visibility", "explorerclipmode", "explorernearcrossmode", "static", "255"):
            assert token in text, f"{relative} does not document {token}"
        assert "near + poly" not in text
        assert "reset mesh rotation" not in text and "reset della rotazione della mesh" not in text
        assert "headertext" in text and "text_header_screen_bytes" in text
    software_license = (ROOT / "LICENSE").read_text(encoding="utf-8-sig")
    assert software_license.startswith("Required Notice: 3Dvibe64. Copyright © 2026 librologica.digital.\n")
    assert "# PolyForm Noncommercial License 1.0.0" in software_license
    documentation_license = (ROOT / "LICENSE-DOCUMENTATION.md").read_text(encoding="utf-8-sig")
    for token in ("librologica.digital", "CC BY-NC 4.0", "CC-BY-NC-4.0"):
        assert token in documentation_license, f"documentation license missing: {token}"
    gitignore = (ROOT / ".gitignore").read_text(encoding="utf-8-sig")
    for token in ("/work/3Dvibe64.asm", "/work/3Dvibe64.prg", "/work/tools/", "*.zip"):
        assert token in gitignore, f".gitignore missing: {token}"
    gitattributes = (ROOT / ".gitattributes").read_text(encoding="utf-8-sig")
    assert "* text=auto eol=lf" in gitattributes
    assert (ROOT / "CONTRIBUTING.md").is_file()
    assert (ROOT / "SECURITY.md").is_file()
    assert (ROOT / "scripts" / "test_dev7_text_split.py").is_file()
    examples_readme = (ROOT / "examples" / "README.md").read_text(encoding="utf-8-sig")
    for filename in (
        "wire-two-color-multimaterial.json", "basic-solid-reference.json",
        "shared-instances-timeline-static-light.json", "mode5-solid-color-outline.json",
        "ground-plane-near-clip.json",
    ):
        assert filename in examples_readme
    assert examples_readme.count("-NoFpsOverlay") >= 2


def build(root: Path, scene: str, args: tuple[str, ...], expect_ok: bool = True) -> subprocess.CompletedProcess[str]:
    command = [
        "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
        str(root / BUILDER_RELATIVE), "-SceneFile", str(root / scene), *args,
        "-SkipCmdUpdate",
    ]
    completed = subprocess.run(command, cwd=root, text=True, capture_output=True, check=False)
    if expect_ok:
        assert completed.returncode == 0, f"build failed for {scene}:\n{completed.stdout}\n{completed.stderr}"
    else:
        assert completed.returncode != 0, f"invalid build unexpectedly succeeded for {scene}"
    return completed


def clean_generated(root: Path) -> None:
    for path in (root / "work").glob("3Dvibe64.*"):
        if path.suffix.lower() in {".asm", ".prg", ".cmd", ".log"}:
            path.unlink()


def write_json(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def resolve_executable(env_names: tuple[str, ...], executable_names: tuple[str, ...]) -> Path:
    for env_name in env_names:
        value = os.environ.get(env_name, "").strip()
        if not value:
            continue
        candidate = Path(value)
        if candidate.is_file():
            return candidate.resolve()
        if candidate.is_dir():
            for executable_name in executable_names:
                nested = candidate / executable_name
                if nested.is_file():
                    return nested.resolve()
    for executable_name in executable_names:
        found = shutil.which(executable_name)
        if found:
            return Path(found).resolve()
    raise AssertionError(
        f"required executable not found: set one of {env_names} or add one of {executable_names} to PATH"
    )


def read_vice_labels(path: Path) -> dict[str, int]:
    symbols: dict[str, int] = {}
    pattern = re.compile(r"^al\s+([0-9a-fA-F]+)\s+\.(\S+)$")
    for line in path.read_text(encoding="ascii").splitlines():
        match = pattern.match(line.strip())
        if match:
            symbols[match.group(2)] = int(match.group(1), 16)
    return symbols


def read_c64_ram(snapshot_path: Path) -> memoryview:
    snapshot = snapshot_path.read_bytes()
    module = snapshot.index(b"C64MEM")
    # C64MEM header + four CPU-port bytes precede the complete 64 KiB RAM image.
    ram_start = module + 16 + 2 + 4 + 4
    memory = memoryview(snapshot)[ram_start : ram_start + 65536]
    assert len(memory) == 65536, f"incomplete C64 RAM module: {snapshot_path}"
    return memory


def ground_framebuffer_signature(label_path: Path, snapshot_path: Path) -> str:
    symbols = read_vice_labels(label_path)
    required = {
        "BITMAP_B_BASE", "SCREEN_B_BASE", "VIC_D018_B", "VIC_BANK_B_BITS",
        "WORLD_BACKGROUND_COLOR", "WORLD_GROUND_COLOR_RAM", "MATERIAL_COLOR_RAM",
    }
    assert required <= symbols.keys(), f"framebuffer labels missing: {sorted(required-symbols.keys())}"
    memory = read_c64_ram(snapshot_path)
    payload = bytearray(b"3DVIBE64-FRAMEBUFFER-V1\0")
    for name in (
        "BITMAP_B_BASE", "SCREEN_B_BASE", "VIC_D018_B", "VIC_BANK_B_BITS",
        "WORLD_BACKGROUND_COLOR", "WORLD_GROUND_COLOR_RAM", "MATERIAL_COLOR_RAM",
    ):
        payload.extend(struct.pack("<H", symbols[name]))
    bitmap_base = symbols["BITMAP_B_BASE"]
    screen_base = symbols["SCREEN_B_BASE"]
    payload.extend(memory[bitmap_base : bitmap_base + 8000])
    payload.extend(memory[screen_base : screen_base + 1000])
    return hashlib.sha256(payload).hexdigest().upper()


def ground_roll_framebuffer_signature(label_path: Path, snapshot_path: Path) -> str:
    symbols = read_vice_labels(label_path)
    required = {
        "BITMAP_B_BASE", "SCREEN_B_BASE", "VIC_D018_B", "VIC_BANK_B_BITS",
        "WORLD_BACKGROUND_COLOR", "WORLD_GROUND_COLOR_RAM", "MATERIAL_COLOR_RAM",
    }
    assert required <= symbols.keys(), f"ground-roll labels missing: {sorted(required-symbols.keys())}"
    memory = read_c64_ram(snapshot_path)
    payload = bytearray(b"3DVIBE64-GROUND-ROLL-V1\0")
    for name in (
        "BITMAP_B_BASE", "SCREEN_B_BASE", "VIC_D018_B", "VIC_BANK_B_BITS",
        "WORLD_BACKGROUND_COLOR", "WORLD_GROUND_COLOR_RAM", "MATERIAL_COLOR_RAM",
    ):
        payload.extend(struct.pack("<H", symbols[name]))
    bitmap_base = symbols["BITMAP_B_BASE"]
    screen_base = symbols["SCREEN_B_BASE"]
    payload.extend(memory[bitmap_base : bitmap_base + 8000])
    payload.extend(memory[screen_base : screen_base + 1000])
    return hashlib.sha256(payload).hexdigest().upper()


def check_ground_framebuffer_runtime() -> None:
    tass = resolve_executable(("TASS64_EXE", "TASS64_PATH"), ("64tass.exe", "64tass"))
    vice = resolve_executable(("VICE_X64SC", "VICE_EXE"), ("x64sc.exe", "x64sc"))
    with tempfile.TemporaryDirectory(prefix="3dvibe64-1.0-ground-framebuffer-") as temporary:
        sandbox = Path(temporary) / "sdk"
        shutil.copytree(ROOT, sandbox)
        scene_path = sandbox / "validation" / "ground-framebuffer.json"
        write_json(scene_path, GROUND_FRAMEBUFFER_SCENE)
        for mode in (4, 5):
            clean_generated(sandbox)
            build(sandbox, str(scene_path.relative_to(sandbox)), (
                "-GraphicsMode", str(mode), "-CameraMode", "walkFull",
                "-CameraViewport", "normal", "-Mode4NearProfile", "clip",
                "-FaceCullProfile", "stable", "-Quality", "balanced",
                "-Projection", "table", "-MemoryLayout", "high-basic-v2",
                "-NoFpsOverlay", "-StaticPose",
            ))
            asm_path = sandbox / "work" / "3Dvibe64.asm"
            prg_path = sandbox / "work" / "3Dvibe64.prg"
            labeled_prg = sandbox / "validation" / f"ground-framebuffer-mode{mode}.prg"
            label_path = sandbox / "validation" / f"ground-framebuffer-mode{mode}.vice.labels"
            assembled = subprocess.run(
                [str(tass), "-a", "-B", "-o", str(labeled_prg), f"--labels={label_path}", "--vice-labels-numeric", str(asm_path)],
                cwd=sandbox, text=True, capture_output=True, check=False,
            )
            assert assembled.returncode == 0, assembled.stdout + assembled.stderr
            assert sha256(labeled_prg) == sha256(prg_path), f"Mode {mode}: labeled reassembly changed PRG"

            snapshot_path = sandbox / "validation" / f"ground-framebuffer-mode{mode}.vsf"
            monitor_path = sandbox / "validation" / f"ground-framebuffer-mode{mode}.mon"
            label_monitor = label_path.resolve().as_posix()
            snapshot_monitor = snapshot_path.resolve().as_posix()
            monitor_path.write_text(
                f'load_labels "{label_monitor}"\n'
                "trace .render_frame_end\n"
                "ignore 1 31\n"
                f'command 1 "dump \\"{snapshot_monitor}\\""\n'
                "x\n",
                encoding="ascii",
            )
            run = subprocess.run(
                [
                    str(vice), "-default", "+confirmonexit", "-console", "-warp",
                    "-VICIIfilter", "0", "-joydev2", "4", "-autostartprgmode", "1",
                    "-initbreak", "ready", "-moncommands", str(monitor_path),
                    "-limitcycles", "60000000", str(labeled_prg),
                ],
                cwd=sandbox, text=True, capture_output=True, check=False, timeout=180,
            )
            assert snapshot_path.is_file(), (
                f"Mode {mode}: render_frame_end was not reached 32 times; "
                f"VICE exit={run.returncode}\n{run.stdout}\n{run.stderr}"
            )
            # VICE reports its intentional cycle-limit shutdown as status 1 on
            # some Windows builds; the 32nd-frame snapshot is the success gate.
            assert run.returncode in (0, 1), f"Mode {mode}: VICE exit={run.returncode}\n{run.stdout}\n{run.stderr}"
            actual = ground_framebuffer_signature(label_path, snapshot_path)
            expected = GROUND_FRAMEBUFFER_SHA256[mode]
            assert actual == expected, f"Mode {mode} framebuffer: {actual} != {expected}"


def check_ground_roll_framebuffer_runtime() -> None:
    tass = resolve_executable(("TASS64_EXE", "TASS64_PATH"), ("64tass.exe", "64tass"))
    vice = resolve_executable(("VICE_X64SC", "VICE_EXE"), ("x64sc.exe", "x64sc"))
    with tempfile.TemporaryDirectory(prefix="3dvibe64-1.0-ground-roll-") as temporary:
        sandbox = Path(temporary) / "sdk"
        shutil.copytree(ROOT, sandbox)
        scene_path = sandbox / "validation" / "ground-roll-framebuffer.json"
        for mode, roll in sorted(GROUND_ROLL_FRAMEBUFFER_SHA256):
            scene = json.loads(json.dumps(GROUND_ROLL_FRAMEBUFFER_SCENE))
            # world-z-up public rotation maps [pitch, roll, yaw] to the engine
            # [pitch, yaw, roll] camera tuple.
            scene["camera"]["rotation"][1] = roll
            write_json(scene_path, scene)
            clean_generated(sandbox)
            build_args = (
                "-GraphicsMode", str(mode), "-CameraMode", "walkFull",
                "-CameraViewport", "normal", "-Mode4NearProfile", "clip",
                "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "high-basic-v2",
                "-NoFpsOverlay", "-StaticPose", "-NoCameraRuntimeControls",
            )
            if mode >= 4:
                build_args += ("-FaceCullProfile", "stable")
            build(sandbox, str(scene_path.relative_to(sandbox)), build_args)
            asm_path = sandbox / "work" / "3Dvibe64.asm"
            prg_path = sandbox / "work" / "3Dvibe64.prg"
            tag = f"ground-roll-mode{mode}-roll{roll}"
            labeled_prg = sandbox / "validation" / f"{tag}.prg"
            label_path = sandbox / "validation" / f"{tag}.vice.labels"
            assembled = subprocess.run(
                [str(tass), "-a", "-B", "-o", str(labeled_prg), f"--labels={label_path}", "--vice-labels-numeric", str(asm_path)],
                cwd=sandbox, text=True, capture_output=True, check=False,
            )
            assert assembled.returncode == 0, assembled.stdout + assembled.stderr
            assert sha256(labeled_prg) == sha256(prg_path), f"{tag}: labeled reassembly changed PRG"
            snapshot_path = sandbox / "validation" / f"{tag}.vsf"
            monitor_path = sandbox / "validation" / f"{tag}.mon"
            monitor_path.write_text(
                f'load_labels "{label_path.resolve().as_posix()}"\n'
                "trace .render_frame_end\n"
                "ignore 1 31\n"
                f'command 1 "dump \\\"{snapshot_path.resolve().as_posix()}\\\""\n'
                "x\n",
                encoding="ascii",
            )
            run = subprocess.run(
                [str(vice), "-default", "+confirmonexit", "-console", "-warp", "-VICIIfilter", "0", "-joydev2", "4", "-autostartprgmode", "1", "-initbreak", "ready", "-moncommands", str(monitor_path), "-limitcycles", "60000000", str(labeled_prg)],
                cwd=sandbox, text=True, capture_output=True, check=False, timeout=180,
            )
            assert snapshot_path.is_file(), (
                f"{tag}: render_frame_end was not reached 32 times; "
                f"VICE exit={run.returncode}\n{run.stdout}\n{run.stderr}"
            )
            assert run.returncode in (0, 1), f"{tag}: VICE exit={run.returncode}\n{run.stdout}\n{run.stderr}"
            actual = ground_roll_framebuffer_signature(label_path, snapshot_path)
            expected = GROUND_ROLL_FRAMEBUFFER_SHA256[(mode, roll)]
            assert actual == expected, f"{tag} framebuffer: {actual} != {expected}"


def multicolor_region_counts(memory: memoryview, bitmap_base: int, screen_base: int, col_first: int, col_end: int) -> dict[int, int]:
    counts: dict[int, int] = {}
    for row in range(25):
        for col in range(col_first, col_end):
            cell = row * 40 + col
            screen = memory[screen_base + cell]
            color = memory[0xD800 + cell] & 0x0F
            for scanline in range(8):
                packed = memory[bitmap_base + row * 320 + col * 8 + scanline]
                for shift in (6, 4, 2, 0):
                    slot = (packed >> shift) & 0x03
                    if slot == 0:
                        continue
                    pigment = (screen >> 4) if slot == 1 else ((screen & 0x0F) if slot == 2 else color)
                    counts[pigment] = counts.get(pigment, 0) + 1
    return counts


def check_shared_rgb_framebuffer_runtime() -> None:
    tass = resolve_executable(("TASS64_EXE", "TASS64_PATH"), ("64tass.exe", "64tass"))
    vice = resolve_executable(("VICE_X64SC", "VICE_EXE"), ("x64sc.exe", "x64sc"))
    with tempfile.TemporaryDirectory(prefix="3dvibe64-1.1.2-shared-rgb-") as temporary:
        sandbox = Path(temporary) / "sdk"
        shutil.copytree(ROOT, sandbox)
        scene_path = sandbox / "validation" / "shared-rgb-framebuffer.json"
        write_json(scene_path, SHARED_RGB_FRAMEBUFFER_SCENE)
        for mode in (4, 5):
            clean_generated(sandbox)
            build(sandbox, str(scene_path.relative_to(sandbox)), (
                "-GraphicsMode", str(mode), "-CameraMode", "fixed", "-CameraViewport", "normal",
                "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable",
                "-FaceCullProfile", "stable", "-NoFpsOverlay",
            ))
            asm_path = sandbox / "work" / "3Dvibe64.asm"
            asm = asm_path.read_text(encoding="utf-8", errors="replace")
            assert "FACE_MATERIAL_ACTIVE_ONLY = $00" in asm
            assert "object_material_override:\n .byte $02,$03,$04" in asm
            prg_path = sandbox / "work" / "3Dvibe64.prg"
            labeled_prg = sandbox / "validation" / f"shared-rgb-mode{mode}.prg"
            label_path = sandbox / "validation" / f"shared-rgb-mode{mode}.vice.labels"
            assembled = subprocess.run(
                [str(tass), "-a", "-B", "-o", str(labeled_prg), f"--labels={label_path}", "--vice-labels-numeric", str(asm_path)],
                cwd=sandbox, text=True, capture_output=True, check=False,
            )
            assert assembled.returncode == 0, assembled.stdout + assembled.stderr
            assert sha256(labeled_prg) == sha256(prg_path), f"shared RGB Mode {mode}: labeled reassembly changed PRG"

            snapshot_path = sandbox / "validation" / f"shared-rgb-mode{mode}.vsf"
            monitor_path = sandbox / "validation" / f"shared-rgb-mode{mode}.mon"
            monitor_path.write_text(
                f'load_labels "{label_path.resolve().as_posix()}"\n'
                "trace .render_frame_end\n"
                "ignore 1 31\n"
                f'command 1 "dump \\\"{snapshot_path.resolve().as_posix()}\\\""\n'
                "x\n",
                encoding="ascii",
            )
            run = subprocess.run(
                [str(vice), "-default", "+confirmonexit", "-console", "-warp", "-VICIIfilter", "0", "-autostartprgmode", "1", "-initbreak", "ready", "-moncommands", str(monitor_path), "-limitcycles", "60000000", str(labeled_prg)],
                cwd=sandbox, text=True, capture_output=True, check=False, timeout=180,
            )
            assert snapshot_path.is_file(), (
                f"shared RGB Mode {mode}: render_frame_end was not reached 32 times; "
                f"VICE exit={run.returncode}\n{run.stdout}\n{run.stderr}"
            )
            assert run.returncode in (0, 1), f"shared RGB Mode {mode}: VICE exit={run.returncode}\n{run.stdout}\n{run.stderr}"
            symbols = read_vice_labels(label_path)
            memory = read_c64_ram(snapshot_path)
            candidates = []
            for bitmap_base, screen_base in ((0x6000, 0x5C00), (symbols["BITMAP_B_BASE"], symbols["SCREEN_B_BASE"])):
                regions = (
                    multicolor_region_counts(memory, bitmap_base, screen_base, 0, 14),
                    multicolor_region_counts(memory, bitmap_base, screen_base, 14, 26),
                    multicolor_region_counts(memory, bitmap_base, screen_base, 26, 40),
                )
                score = sum(regions[index].get(pigment, 0) for index, pigment in enumerate((2, 5, 6)))
                candidates.append((score, regions))
            _, regions = max(candidates, key=lambda item: item[0])
            for label, counts, expected in zip(("red", "green", "blue"), regions, (2, 5, 6)):
                assert counts.get(expected, 0) >= 500, f"shared RGB Mode {mode} {label}: {counts}"
                assert max(counts, key=counts.get) == expected, f"shared RGB Mode {mode} {label} is not dominant: {counts}"


def check_reference_builds() -> None:
    with tempfile.TemporaryDirectory(prefix="3dvibe64-1.0-contract-") as temporary:
        sandbox = Path(temporary) / "sdk"
        shutil.copytree(ROOT, sandbox)
        for label, scene, expected, args in REFERENCE_BUILDS:
            clean_generated(sandbox)
            build(sandbox, scene, args)
            actual = sha256(sandbox / "work" / "3Dvibe64.prg")
            assert actual == expected, f"{label}: {actual} != {expected}"
        for label, expected, args in TWO_COLOR_BUILDS:
            clean_generated(sandbox)
            build(sandbox, "examples/wire-two-color-multimaterial.json", args)
            actual = sha256(sandbox / "work" / "3Dvibe64.prg")
            assert actual == expected, f"{label}: {actual} != {expected}"


def check_schema_and_failure_contracts() -> None:
    with tempfile.TemporaryDirectory(prefix="3dvibe64-1.0-schema-") as temporary:
        sandbox = Path(temporary) / "sdk"
        shutil.copytree(ROOT, sandbox)
        basic = read_json(sandbox, "examples/basic-solid-reference.json")

        for mode in (1, 2, 3):
            scene = dict(basic)
            scene["meshSourceSharing"] = True
            path = sandbox / "validation" / f"sharing-mode{mode}.json"
            write_json(path, scene)
            result = build(sandbox, str(path.relative_to(sandbox)), ("-GraphicsMode", str(mode), "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-NoFpsOverlay"), expect_ok=False)
            assert "meshSourceSharing is supported only in GraphicsMode 4 and 5" in (result.stdout + result.stderr)

        scene = dict(basic)
        scene["meshSourceSharing"] = True
        path = sandbox / "validation" / "sharing-no-reuse.json"
        write_json(path, scene)
        result = build(sandbox, str(path.relative_to(sandbox)), ("-GraphicsMode", "4", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-NoFpsOverlay"), expect_ok=False)
        result_text = " ".join((result.stdout + result.stderr).split())
        assert "meshSourceSharing requires at least one source mesh referenced by multiple instances" in result_text, result_text

        build(sandbox, "examples/shared-instances-timeline-static-light.json", ("-GraphicsMode", "4", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-FaceCullProfile", "stable", "-NoFpsOverlay"))
        asm = (sandbox / "work" / "3Dvibe64.asm").read_text(encoding="utf-8", errors="replace")
        assert "MESH_INSTANCE_EXPANSION_MODE = $00" in asm and "MESH_SOURCE_SHARING_RUNTIME = $01" in asm
        assert "STATIC_RUNTIME_LIGHT = $01" in asm and "LIGHT_PHASE_COUNT = $01" in asm

        shared = read_json(sandbox, "examples/shared-instances-timeline-static-light.json")
        shared["objects"][0]["faceOverrides"] = {"0": {"solidColor": 7, "shading": False}}
        path = sandbox / "validation" / "instance-face-overrides.json"
        write_json(path, shared)
        result = build(sandbox, str(path.relative_to(sandbox)), ("-GraphicsMode", "4", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-NoFpsOverlay"), expect_ok=False)
        result_text = " ".join((result.stdout + result.stderr).split())
        assert "per-instance object faceOverrides are not supported by the shared-source path" in result_text, result_text

        # Per-instance material overrides must keep the draw-time material path.
        shared_material_only = read_json(sandbox, "examples/shared-instances-timeline-static-light.json")
        shared_material_only.pop("timeline", None)
        shared_material_only["meshes"][0].pop("faceOverrides", None)
        for instance in shared_material_only["objects"]:
            instance.pop("reflectivityOverride", None)
            instance.pop("colorOverride", None)
        material_only_path = sandbox / "validation" / "shared-material-only.json"
        write_json(material_only_path, shared_material_only)
        build(sandbox, str(material_only_path.relative_to(sandbox)), ("-GraphicsMode", "4", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-FaceCullProfile", "stable", "-NoFpsOverlay"))
        shared_asm = (sandbox / "work" / "3Dvibe64.asm").read_text(encoding="utf-8", errors="replace")
        assert "FACE_MATERIAL_ACTIVE_ONLY = $00" in shared_asm
        assert "SCENE_INSTANCE_MATERIAL_ALL_PINNED = $01" in shared_asm
        assert "object_material_override:" in shared_asm

        # Reflectivity-only shared instances use the same draw-time loader but
        # keep the active/global material optimization.
        shared_reflect_only = read_json(sandbox, "examples/shared-instances-timeline-static-light.json")
        shared_reflect_only.pop("timeline", None)
        shared_reflect_only["meshes"][0].pop("faceOverrides", None)
        for instance in shared_reflect_only["objects"]:
            instance.pop("materialOverride", None)
            instance.pop("colorOverride", None)
        reflect_only_path = sandbox / "validation" / "shared-reflect-only.json"
        write_json(reflect_only_path, shared_reflect_only)
        build(sandbox, str(reflect_only_path.relative_to(sandbox)), ("-GraphicsMode", "4", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-FaceCullProfile", "stable", "-NoFpsOverlay"))
        shared_asm = (sandbox / "work" / "3Dvibe64.asm").read_text(encoding="utf-8", errors="replace")
        assert "FACE_MATERIAL_ACTIVE_ONLY = $01" in shared_asm
        assert "FACE_REFLECTIVITY_ACTIVE_ONLY = $00" in shared_asm
        assert "SCENE_INSTANCE_REFLECT_ALL_PINNED = $01" in shared_asm
        assert "object_reflectivity_override:" in shared_asm and "lfm_fixed:" in shared_asm

        point = dict(basic)
        point["meshes"] = [{"id": "point", "type": "mesh", "geometry": "solid", "materialProfile": "single", "vertices": [[0, 0, 0], [1, 0, 0], [2, 0, 0]], "faces": [[0, 1, 2]]}]
        point["objects"] = [{"id": "point", "mesh": "point", "position": [0, 100, 0], "rotation": [0, 0, 0], "scale": 1, "visible": True, "geometry": "solid", "materialProfile": "single", "material": "gray", "reflectivity": "satin"}]
        path = sandbox / "validation" / "point-fixed-min.json"
        write_json(path, point)
        result = build(sandbox, str(path.relative_to(sandbox)), ("-GraphicsMode", "4", "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", "stable", "-NoFpsOverlay"), expect_ok=False)
        assert POINT_FIXED_MESSAGE in (result.stdout + result.stderr)

        for scene, mode, layout in (
            ("examples/mode5-solid-color-outline.json", "5", "stable"),
            ("examples/ground-plane-near-clip.json", "4", "high-basic-v2"),
        ):
            build(sandbox, scene, ("-GraphicsMode", mode, "-CameraMode", "fixed", "-CameraViewport", "normal", "-Quality", "balanced", "-Projection", "table", "-MemoryLayout", layout, "-Mode4NearProfile", "clip", "-NoFpsOverlay"))
            if scene.endswith("ground-plane-near-clip.json"):
                asm = (sandbox / "work" / "3Dvibe64.asm").read_text(encoding="utf-8", errors="replace")
                definitions = re.findall(r"(?m)^div16u:$", asm)
                assert len(definitions) == 1, f"expected one div16u definition, found {len(definitions)}"
                assert (sandbox / "work" / "3Dvibe64.prg").is_file()


def main() -> None:
    check_builder_and_package()
    check_manifest()
    check_clean_tree()
    check_no_retired_references()
    check_documentation()
    check_reference_builds()
    check_schema_and_failure_contracts()
    check_shared_rgb_framebuffer_runtime()
    check_ground_framebuffer_runtime()
    check_ground_roll_framebuffer_runtime()
    check_clean_tree()
    print("PUBLIC_1_1_2_CONTRACT references=11/11 twoColor=2/2 framebuffer=2/2 sharedRGB=2/2 groundRoll=12/12 sharing=pass pointFixedMin=expected-error dev7TextSplit=separate files=45 builder=exact manifest=exact tree=clean")


if __name__ == "__main__":
    main()
