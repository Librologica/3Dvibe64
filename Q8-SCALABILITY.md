# Q8 scalability — 1.10.0-rc1

Release candidate, separate from official 1.9.0; publishing the candidate
does not replace or promote an official SDK. Q8 arithmetic, rounding, projection, near/screen clipping,
Q2 raster and inherited render modes are unchanged.

The public Q8 builder accepts 1..255 objects and 1..255 runtime vertices.
These are encoding ceilings, not guaranteed scene sizes. Source vertices,
faces, runtime faces, mode-specific shade vertices/edges and RAM have their
own existing constraints. The assembler and allocator still reject unsafe
overlap and exhausted gaps. No fallback to lower precision.

Each object owns disjoint mesh vertex/face ranges. The existing per-object
transform adapter is now enabled for arbitrary accepted object counts. For
single meshes above 128 vertices, the same range-based adapter also replaces
the signed descending invalidation loop, so invalid vertices are cleared
through the entire range. One/two-object historical binaries remain unchanged.

MeshSourceSharing, Ground, timeline and camera roll are not added in this RC.
Initial camera rotation is zero; runtime yaw/pitch and existing stationary,
interactive and automatic camera profiles remain supported. Scaled radius
<=40 WU and existing coordinate/scale domains remain enforced.

Normalized16 keeps its separate experimental two-object/16-runtime-vertex
scope with an explicit object guard; expanding Q8 does not silently expand NF.

[Qualification / Qualificazione](Q8-QUALIFICATION.md) · [Release notes / Note RC](RELEASE-NOTES-1.10.0-rc1.md).

## Build / Compilazione

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 5 -SceneFile examples/q8/scalability/13-objects-mode5.json -Q8Camera auto -VideoStandard pal -OutputDirectory ../q8-13-objects-mode5
```

Requires Python 3, PowerShell 7, 64tass. Tests additionally require py65.
Output must be new and outside this SDK. Qualification raw commands and
native data are shipped separately with the candidate evidence package.

Italiano: i limiti di due oggetti e 96 vertici vengono sostituiti dai tetti
degli indici a byte e dai controlli reali della memoria. Non si promettono
255 oggetti con 255 vertici per qualsiasi modalità: ogni scena deve entrare
nei buffer e nei segmenti disponibili. Il backend preciso resta invariato.
