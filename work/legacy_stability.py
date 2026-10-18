"""Opt-in corrections to the ordinary legacy generator, not a Q8 backend.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path


def replace_once(source: str, old: str, new: str) -> str:
    if source.count(old) != 1:
        raise ValueError(f"Legacy stability hook is not unique: {old[:90]!r}")
    return source.replace(old, new, 1)


def exact_winding(source: str) -> str:
    """Preserve all screen X bits in the Mode 2 signed24 shoelace sum.

    Y is in 0..99 (normal) or 0..79 (small). The native signed8 multiplier
    remains exact after correcting its signed interpretation of X>=128.
    Neither the polygon, its edges nor its raster samples are changed.
    """
    begin = source.index("\nmode2_screen_winding_visible:\n") + 1
    end = source.index("\n.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0", begin)
    code = source[begin:end]
    if code.count("  lsr\n"):
        raise ValueError("Unexpected source indentation")
    if code.count(" lsr\n") != 5 or code.count(" jsr mul_s8_16\n") != 2:
        raise ValueError("Mode 2 winding structure changed")
    code = code.replace("mode2_screen_winding_get_x_half", "mode2_screen_winding_get_x")
    code = code.replace(" lsr\n", "")
    for suffix in ("next", "previous"):
        hook = " jsr mul_s8_16\n"
        pos = code.index(hook)
        if suffix == "previous":
            pos = code.index(hook, pos + len(hook))
        addition = (hook + " lda t1\n bpl legacy_winding_" + suffix + "\n"
                    " clc\n lda prodhi\n adc mulb\n sta prodhi\n"
                    "legacy_winding_" + suffix + ":\n")
        code = code[:pos] + addition + code[pos + len(hook):]
    return source[:begin] + code + source[end:]


def rounded_q6(source: str) -> str:
    """Round Q6 products symmetrically and saturate signed8 outputs.

    Existing signed16 multiplication uses this same operation on its unsigned
    remainder; thus its result is rounded once rather than truncated. Native
    matrix representation, geometry buffers and raster ABI stay legacy.
    """
    begin = source.index("\nmul_s6:\n") + 1
    end = source.index("\n.if SCENE_OBJECT_COUNT != 0\nadd_s8_sat:", begin)
    code = source[begin:end]
    code = replace_once(code, " sta prodhi\n lda prodlo\n lsr\n", """ sta prodhi
 clc
 lda prodlo
 adc #$20
 sta prodlo
 bcc legacy_q6_round_ready
 inc prodhi
legacy_q6_round_ready:
 lda prodlo
 lsr
""")
    code = replace_once(code, " ldx mulsign\n bpl ms6_done\n", """ ldx mulsign
 bmi legacy_q6_negative
 cmp #$80
 bcc ms6_done
 lda #$7f
 rts
legacy_q6_negative:
 cmp #$81
 bcc legacy_q6_negate
 lda #$80
 rts
legacy_q6_negate:
""")
    return source[:begin] + code + source[end:]


def camera_rounding(source: str) -> str:
    """Round camera positions at the integer geometry boundary, not downward."""
    for axis in "xy":
        begin = source.index(f"\nexplorer_sub_cam_{axis}:\n") + 1
        end = source.index("\n rts\n", begin) + len("\n rts\n")
        code = source[begin:end]
        code = replace_once(code, f" lda #$00\n sbc explorer_cam_{axis}_lo\n",
                            f" lda #$80\n sbc explorer_cam_{axis}_lo\n")
        source = source[:begin] + code + source[end:]
    return replace_once(source, "explorer_sub_cam_z16:\n sec\n lda #$00\n",
                        "explorer_sub_cam_z16:\n sec\n lda #$80\n")


def complete_world_xy(source: str) -> str:
    """Compose local+origin in signed16 before subtracting the camera.

    The old non-folded path wrapped X/Y sums through a signed byte. The new
    helpers retain that carry/sign. Translation and camera buffers keep the
    native ABI. No new zero-page locations or per-vertex buffers are reserved.
    """
    begin = source.index("\nexplorer_transform_project_vertices:\n") + 1
    end = source.index("\nrotate_project_vertices:\n", begin)
    code = source[begin:end]
    for axis, reg in (("x", "rx0"), ("y", "ry1")):
        old = (f".if SCENE_OBJECT_{axis.upper()}_ACTIVE != 0\n clc\n lda {reg}\n"
               f" adc obj_pos_{axis}_cur\n sta {reg}\n.endif\n")
        code = replace_once(code, old, "")
        code = replace_once(code, f" lda {reg}\n jsr explorer_sub_cam_{axis}\n",
                            f" jsr legacy_world_sub_camera_{axis}\n")
    source = source[:begin] + code + source[end:]
    helpers = ".if CAMERA_MOVABLE != 0 && EXPLORER_MATRIX_FOLD = 0\n"
    for axis, reg in (("x", "rx0"), ("y", "ry1")):
        helpers += f"""legacy_world_sub_camera_{axis}:
 lda {reg}
 bpl legacy_world_{axis}_positive
 lda #$ff
 bne legacy_world_{axis}_sign_ready
legacy_world_{axis}_positive:
 lda #$00
legacy_world_{axis}_sign_ready:
 sta p1hi
.if SCENE_OBJECT_COUNT != 0 && SCENE_OBJECT_{axis.upper()}_ACTIVE != 0
 lda obj_pos_{axis}_cur
 bpl legacy_world_{axis}_origin_positive
 dec p1hi
legacy_world_{axis}_origin_positive:
 clc
 lda {reg}
 adc obj_pos_{axis}_cur
 sta p1lo
 lda p1hi
 adc #$00
 sta p1hi
.else
 lda {reg}
 sta p1lo
.endif
 sec
 lda #$80
 sbc explorer_cam_{axis}_lo
 lda p1lo
 sbc explorer_cam_{axis}_hi
 sta explorer_rel_{axis}_lo
 lda p1hi
 sbc explorer_cam_{axis}_ext
 sta explorer_rel_{axis}_hi
 rts

"""
    helpers += ".endif\n\n"
    return replace_once(source, "\nmul_s16_s6:\n", "\n" + helpers + "mul_s16_s6:\n")


def apply(source: str, profile: str) -> str:
    if profile == "historical":
        return source
    if profile not in ("corrected", "camera", "rotation"):
        raise ValueError(profile)
    source = exact_winding(source)
    if profile in ("corrected", "camera", "rotation"):
        if not re.search(r"(?m)^EXPLORER_MATRIX_FOLD = \$00$", source):
            raise ValueError("Corrected legacy requires complete-world transforms (NoExplorerMatrixFold)")
        source = rounded_q6(source)
        source = camera_rounding(source)
        source = complete_world_xy(source)
    if profile in ('camera','rotation'):
        from legacy_camera import apply as camera_apply
        source = camera_apply(source)
    if profile == 'rotation':
        from legacy_rotation import apply as rotation_apply
        source = rotation_apply(source)
    return source + f"\n; LEGACY_STABILITY_PROFILE={profile}\n"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("asm", type=Path)
    parser.add_argument("--profile", choices=("historical", "corrected", "camera", "rotation"), required=True)
    args = parser.parse_args()
    source = args.asm.read_text(encoding="utf-8-sig")
    args.asm.write_text(apply(source, args.profile), encoding="ascii")


if __name__ == "__main__":
    main()
