"""Execute the mono-portals lintel invariants; no historical workspace required.

Requires 64tass and py65 (requirements-tests.txt). Generated builds stay in a
temporary directory. Synthetic routine states do not expand the map contract.
"""
from pathlib import Path
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "work"))
from mode8.build import build, load
from mode8.contract import valid_pose
from mode8.reference import adapter
from mode8.trace import Trace


def main():
    scene = ROOT / "examples/mode8/apertures.json"
    data = load(scene)
    config, oracle, meta = adapter(data)
    views = 0
    with tempfile.TemporaryDirectory(prefix="mode8-lintels-") as temp:
        for run in ("auto", "interactive"):
            out = Path(temp) / run
            build(scene, out, run)
            trace = Trace(out, config["backend"], meta)
            memory, labels = trace.c.memory, trace.l
            # Owner and exit plane are identical: only the front plane differs.
            # Include both viewport ends and an internal group.
            for changed in (None, 0, 15, 31):
                for label, value in (("lower_owner", 1), ("upper_owner", 9),
                                     ("fx_exit_plane", 79), ("fx_near_plane", 78)):
                    memory[labels[label]:labels[label] + 64] = [value] * 64
                if changed is not None:
                    memory[labels["fx_near_plane"] + 2 * changed] = 77
                trace.execute(labels["ss_mark"], False)
                actual = memory[labels["ss_flags"]:labels["ss_flags"] + 32]
                expected = [int(changed is not None and abs(i - changed) <= 1)
                            for i in range(32)]
                assert actual == expected, (run, changed, actual, expected)
            # Exit must clear stale state before the first exit-cell read.
            memory[labels["portal_inside"]] = 1
            trace.c.pc = labels["rx_continue_portal"]
            for _ in range(10):
                pc = trace.c.pc
                if memory[pc] == 0xA0 and memory[pc + 1] == 0:
                    break
                trace.c.step()
            else:
                raise AssertionError("exit-cell read not reached")
            assert memory[labels["portal_inside"]] == 0, run
            # Fresh persistent RAM: camera before, under and beyond each lintel.
            trace = Trace(out, config["backend"], meta)
            for x in (10.5, 22.5):
                for y in (13.5, 14.5, 15.5):
                    for yaw in (0, 256, 511):
                        pose = [int(x * 256), int(y * 256), yaw, 32, 0]
                        assert valid_pose(data["scene"], pose), pose
                        _, actual = trace.view(pose)
                        expected = oracle(pose)[0]
                        assert actual == expected, (run, pose, "bitmap mismatch")
                        views += 1
            print("PASS lintel invariants and bitmap:", run, flush=True)
    print(f"MODE8 LINTELS: PASS both templates; {views} complete bitmap views")


if __name__ == "__main__":
    main()
