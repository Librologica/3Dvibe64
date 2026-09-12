#!/usr/bin/env python3
"""Public Mode 7 parser, PNG, R1 math and frozen binary references.

Run through run_release_tests.py: build products stay in a disposable SDK.
"""
import copy
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("mode7", ROOT / "work/mode7.py")
backend = importlib.util.module_from_spec(spec)
spec.loader.exec_module(backend)

def read(name):
    return json.loads((ROOT / "examples" / name).read_text(encoding="utf-8-sig"))

def prepared(doc, folder=None):
    return backend.prepare_scene(doc, folder or ROOT / "examples")

def rejected(doc, folder=None):
    try:
        prepared(doc, folder)
    except ValueError:
        return
    raise AssertionError("Invalid texture scene accepted")

def parser_checks():
    scene = read("mode7-cube-gouraud.json")
    explicit = prepared(scene)
    default = copy.deepcopy(scene)
    default.pop("textureCompositor")
    assert prepared(default) == explicit
    assert explicit["_mode7"]["compositor"] == "C"
    for compositor in ("A", "B", "C"):
        d = copy.deepcopy(scene); d["textureCompositor"] = compositor
        assert prepared(d)["_mode7"].get("compositor", "A") == compositor
    plain = read("mode7-cube.json")
    d = copy.deepcopy(plain); d.pop("textureLighting", None)
    d2 = copy.deepcopy(d); d2["textureLighting"] = "none"
    assert prepared(d) == prepared(d2)
    assert "gouraudLighting" not in prepared(d)["_mode7"]
    assert "flatLighting" not in prepared(d)["_mode7"]
    assert "flatLighting" in prepared(read("mode7-cube-flat.json"))["_mode7"]
    for value in (0, 4, -1, 1.0, True):
        d = copy.deepcopy(scene); d["textures"][0]["texels"][0] = value; rejected(d)
    for field, value in (("width", 8), ("height", 32), ("texels", [1]*255), ("repeat", [3, 1])):
        d = copy.deepcopy(scene); d["textures"][0][field] = value; rejected(d)
    for u in (-0.0625, 16, 0.01):
        d = copy.deepcopy(scene); d["meshes"][0]["faceUV"][0][0][0] = u; rejected(d)
    d = copy.deepcopy(scene); d["meshSourceSharing"] = True; rejected(d)
    for repeat in (1,2,4,8,16):
        d = copy.deepcopy(scene); d["textures"][0]["repeat"] = [repeat,repeat]
        result = prepared(d)["_mode7"]
        assert result["textures"][0]["texels"] == explicit["_mode7"]["textures"][0]["texels"]
        for v in range(256):
            for u in range(256):
                fast = (((v*repeat>>4)&15)<<4) | ((u*repeat>>4)&15)
                assert fast == ((v*repeat//16)%16)*16 + (u*repeat//16)%16
    multi = prepared(read("mode7-multi-texture.json"))["_mode7"]
    assert len(set(multi["textureIds"])) > 1
    assert len(explicit["_mode7"]["uvs"]) == 12
    print("MODE7 parser/default-C/UV/seam/quad/multi/repeat PASS", flush=True)

def png_checks():
    inline = read("mode7-cube-gouraud.json")
    png = read("mode7-cube-png.json")
    png["name"] = inline["name"]
    assert prepared(png) == prepared(inline)
    for mutate in (
        lambda t: t.pop("sourceColors"),
        lambda t: t.update(sourceColors=["#542C18"]*3),
        lambda t: t.update(texels=[1]*256),
        lambda t: t.update(source="textures/bricks.bmp"),
        lambda t: t.update(sourceColors=["#000000","#D06820","#C8C8C8"]),
    ):
        d = copy.deepcopy(png); mutate(d["textures"][0]); rejected(d)
    with tempfile.TemporaryDirectory(prefix="mode7-png-negative-") as temp:
        folder = Path(temp)
        with Image.open(ROOT/"examples/textures/bricks.png") as source:
            image = source.convert("RGBA")
        cases = {"small.png": image.resize((8,8)), "one-color.png": Image.new("RGB",(16,16),(84,44,24))}
        alpha = image.copy(); alpha.putpixel((0,0),(84,44,24,0)); cases["alpha.png"] = alpha
        fourth = image.copy(); fourth.putpixel((0,0),(0,255,0,255)); cases["fourth.png"] = fourth
        for name, image in cases.items():
            image.save(folder/name)
            d = copy.deepcopy(png); d["textures"][0]["source"] = name; rejected(d, folder)
    print("MODE7 PNG/inline equivalent; strict negative cases PASS", flush=True)

def r1_math():
    count = 0
    for dx in range(-159,160):
        for dy in range(1,100):
            q,r = divmod(abs(dx),dy); direction = 1 if dx >= 0 else -1
            x = 0; error = dy-1 if dx >= 0 else 0
            for k in range(dy+1):
                assert x == -(-(dx*k)//dy)
                count += 1
                x += direction*q; error += r
                if error >= dy: error -= dy; x += direction
    assert count == 1610631
    print("MODE7 R1 exact edge increments:", count, "PASS", flush=True)

def references():
    package = json.loads((ROOT/"PACKAGE-MANIFEST.json").read_text(encoding="utf-8-sig"))
    assert package["renderer"]["graphicsModes"] == list(range(1,8))
    for relative, expected in package["mode7"]["backendHashes"].items():
        assert hashlib.sha256((ROOT/relative).read_bytes()).hexdigest().upper() == expected, relative
    shell = shutil.which("pwsh") or shutil.which("powershell.exe")
    assert shell and (os.environ.get("TASS64_EXE") or shutil.which("64tass"))
    for row in package["mode7"]["referenceBuilds"]:
        result = subprocess.run([shell,"-NoProfile","-ExecutionPolicy","Bypass","-File",
            str(ROOT/"work/build-3Dvibe64.ps1"),"-SceneFile",str(ROOT/row["scene"]),
            *row["arguments"],"-SkipCmdUpdate"],cwd=ROOT,text=True,capture_output=True)
        assert result.returncode == 0, result.stdout + result.stderr
        digest = hashlib.sha256((ROOT/"work/3Dvibe64.prg").read_bytes()).hexdigest().upper()
        assert digest == row["sha256"], (row["label"],digest,row["sha256"])
        print("MODE7 R1 reference exact",row["label"],digest,flush=True)

if __name__ == "__main__":
    parser_checks(); png_checks(); r1_math(); references()
    print("MODE7 PUBLIC CONTRACT: PASS", flush=True)
