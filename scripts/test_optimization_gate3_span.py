#!/usr/bin/env python3
"""Exhaustive host model for the Gate 3 byte-oriented Gouraud span kernel."""

from __future__ import annotations

import random
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "work" / "build-3Dvibe64.ps1").read_text(encoding="utf-8")
BAYER = ((0, 8, 2, 10), (12, 4, 14, 6), (3, 11, 1, 9), (15, 7, 13, 5))
CLEAR = (0x3F, 0xCF, 0xF3, 0xFC)


def code(level: int, x: int, y: int) -> int:
    threshold = BAYER[y & 3][x & 3]
    if level <= 16:
        pair = 2 if threshold < level else 1
    else:
        pair = 3 if threshold < level - 16 else 2
    return pair << (6 - 2 * (x & 3))


def shades(left: int, right: int, start: int, end: int) -> list[int]:
    span = end - start
    delta = abs(right - left)
    direction = 1 if right >= left else -1
    shade = left
    error = 0
    values = []
    for x in range(start, end + 1):
        values.append(shade)
        if x == end or span == 0:
            continue
        error += delta
        while error >= span:
            error -= span
            shade += direction
    return values


def scalar(initial: bytearray, y: int, start: int, end: int, values: list[int]) -> bytearray:
    out = bytearray(initial)
    for x, shade in zip(range(start, end + 1), values):
        byte = x >> 2
        phase = x & 3
        out[byte] = (out[byte] & CLEAR[phase]) | code(shade, x, y)
    return out


def byte_kernel(initial: bytearray, y: int, start: int, end: int, values: list[int]) -> bytearray:
    out = bytearray(initial)
    x = start
    index = 0
    while x <= end:
        if (x & 3) == 0 and end - x >= 3:
            out[x >> 2] = (
                code(values[index], x, y)
                | code(values[index + 1], x + 1, y)
                | code(values[index + 2], x + 2, y)
                | code(values[index + 3], x + 3, y)
            )
            x += 4
            index += 4
        else:
            byte = x >> 2
            phase = x & 3
            out[byte] = (out[byte] & CLEAR[phase]) | code(values[index], x, y)
            x += 1
            index += 1
    return out


def main() -> None:
    for token in (
        "$Mode6ByteSpanKernelFlag = $Mode6GouraudFlag",
        "GOURAUD_BYTE_SPAN_KERNEL = $00",
        "gouraud_draw_scan_span_bytes:",
        "gouraud_advance_scan_pixel:",
        "sta (ptr0lo),y\n sta (ptr1lo),y",
    ):
        assert token in SOURCE, token

    rng = random.Random(0x6510)
    cases = 0
    for y in range(4):
        for start in range(32):
            for end in range(start, 32):
                for left in range(33):
                    for right in range(33):
                        initial = bytearray(rng.randrange(256) for _ in range(8))
                        values = shades(left, right, start, end)
                        expected = scalar(initial, y, start, end, values)
                        actual = byte_kernel(initial, y, start, end, values)
                        assert actual == expected, (y, start, end, left, right)
                        cases += 1
    print(f"PASS Gate3 span model: {cases} exhaustive spans, bit-exact")


if __name__ == "__main__":
    main()
