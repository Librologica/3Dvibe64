"""Exhaustive host model for the exact division promoted in release 1.2.0.

All changed div16u inputs are tested; all other inputs use the unchanged
Gate 3 16-round body. XY tests cover a superset of the admitted |N|<=2032.
Models include the accumulator's ninth carry bit, not approximate division.
"""
import json
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[1]


def gate3(n, d, bits):
    q = n.copy().astype(np.int64)
    r = np.zeros_like(q)
    for bit in range(bits - 1, -1, -1):
        r = 2 * r + ((n >> bit) & 1)
        take = r >= d
        r = r - take * d
        q = ((q << 1) & ((1 << bits) - 1)) | take
    return q, r


def low8(n, d, seed):
    q = n & 255
    a = seed.copy()
    for _ in range(8):
        carry = q >> 7
        q = (q << 1) & 255
        wide = (a << 1) | carry
        a = wide & 255
        take = (wide > 255) | (a >= d)
        a = (a - take * d) & 255
        q += take
    return q, a


def main():
    div_count = xy_count = 0
    for d in range(1, 256):
        n = np.arange(d * 256, dtype=np.int64)
        q, r = low8(n, d, n >> 8)
        oldq, oldr = gate3(n, d, 16)
        assert np.array_equal(q, oldq) and np.array_equal(r, oldr), d
        assert np.array_equal(q, n // d) and np.array_equal(r, n % d)
        div_count += len(n)
        # Gate 3 aligns to 11 bits in a 16-bit register: upper bits drop.
        # Preserve this even beyond the documented 2032 bound. Normal
        # viewport endpoints permit |4*dx| as large as 2544.
        n = np.arange(32769, dtype=np.int64)
        seed = (n >> 8) & 7
        highq = np.zeros_like(seed)
        while np.any(seed >= d):
            take = seed >= d
            seed -= take * d
            highq += take
        q, r = low8(n, d, seed)
        q |= highq << 8
        oldq, oldr = gate3(n & 2047, d, 11)
        assert np.array_equal(q, oldq) and np.array_equal(r, oldr), d
        # Unchanged Euclidean signed correction, including negative exact.
        nq = -q - (r != 0)
        nr = np.where(r != 0, d - r, 0)
        assert np.array_equal(nq, (-(n & 2047)) // d)
        assert np.array_equal(nr, (-(n & 2047)) % d)
        xy_count += 65536
    # D=0 is deliberately NOT admitted to either new path.
    n = np.arange(65536, dtype=np.int64)
    q, r = gate3(n, 0, 16)
    assert np.all(q == 65535) and np.array_equal(r, n)
    result = dict(status="PASS", algorithm="byte-seeded restoring / accumulator remainder",
                  div16u_changed_inputs=div_count, xy_signed_inputs=xy_count,
                  xy_domain="All signed 16-bit N, D=1..255; preserve Gate 3 magnitude truncation to 11 bits",
                  div16u_domain="D=1..255, N=0..256*D-1",
                  fallback="Original 16-round body retained for all other 32-bit input pairs",
                  divide_by_zero_cases=65536, mismatches=0, lut_bytes=0)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
