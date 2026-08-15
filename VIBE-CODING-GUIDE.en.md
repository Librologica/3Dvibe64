# Practical Manual for Creating Demos and PRGs with 3Dvibe64 Using Codex

## Introduction

3Dvibe64 is a 3D graphics engine designed for the Commodore 64. Its purpose is to let you describe a three-dimensional scene in a JSON file and turn that description into a `.prg` program, ready to run on a compatible C64 or in the VICE emulator.

This manual is also intended for people who do not know Assembly and have never compiled a program for the Commodore 64. You do not need to write the renderer by hand, know the VIC-II registers, or intervene directly in the 6510 routines. The work is divided into two clearly distinct parts:

- the user decides what must appear in the demo and how it must behave;
- Codex translates those requests into files, parameters, and build operations that are compatible with the engine.

The general workflow is as follows:

```text
Idea described in natural language
             ↓
Codex prepares or modifies the JSON
             ↓
The builder generates the Assembly code
             ↓
64tass compiles the code
             ↓
The PRG is produced
             ↓
VICE runs and verifies the demo
```

Each step has a precise function. The JSON contains the scene description; the builder interprets that description and generates the required Assembly code; 64tass converts the Assembly into an executable program; VICE finally lets you observe the result and check that the demo works correctly.

The user can therefore concentrate mainly on the creative and visual aspects:

- the objects included in the scene;
- the colors;
- the materials;
- the movements;
- the camera position and behavior;
- the light;
- the ground;
- the animations;
- the pacing of the sequence;
- the overall visual result.

Codex can handle the more technical activities:

- analyzing the engine structure;
- reading the official documentation and examples;
- writing or modifying the JSON;
- importing and checking meshes;
- verifying scale, orientation, winding, and geometric compatibility;
- running the builder;
- interpreting error messages;
- diagnosing clipping, culling, depth, or rasterization problems;
- compiling the PRG;
- testing it in VICE;
- saving logs, screenshots, and hashes;
- preserving already approved versions without overwriting them.

The most important principle of the entire method is simple: **the scene must be reproducibly rebuildable from the JSON and the build command**. A PRG obtained through undocumented manual changes may work, but it becomes difficult to correct, update, or reproduce. For this reason, the JSON must remain the authoritative source of the demo, while the generated Assembly must be regarded as an intermediate product.

## How to Read and Use This Manual

The first sections explain how to prepare the computer and organize the directories. The middle sections describe the engine’s main features: graphics modes, camera, viewport, memory, units of measurement, clipping, culling, Ground, materials, lights, instances, and timelines. The final sections explain how to work with Codex in an orderly way, how to compile, how to request changes, how to diagnose errors, and how to freeze an approved version.

You do not need to memorize every option. It is enough to understand the general meaning of each choice and formulate precise requests. Codex must still inspect the builder and the examples included in the release before using a parameter, because some interface details may change over time.

Read this manual together with [README.en.md](README.en.md),
[QUICKSTART.md](QUICKSTART.md), and [WORLD-METRICS.md](WORLD-METRICS.md). Readers
who want to study or modify the generated 6510/6502 code directly should use
[ASSEMBLY-GUIDE.en.md](ASSEMBLY-GUIDE.en.md).

## Contents

1. [What You Need](#1-what-you-need)
2. [How to Obtain 3Dvibe64](#2-how-to-obtain-3dvibe64)
3. [Installing the Tools](#3-installing-the-tools)
4. [Letting Codex Prepare the Environment](#4-letting-codex-prepare-the-environment)
5. [Directory Organization](#5-directory-organization)
6. [How Compilation Works](#6-how-compilation-works)
7. [Graphics Modes](#7-graphics-modes)
8. [Camera](#8-camera)
9. [Viewport and Memory](#9-viewport-and-memory)
10. [Engine Units](#10-engine-units)
11. [Near Plane and Approaching Surfaces](#11-near-plane-and-approaching-surfaces)
12. [Backface Culling](#12-backface-culling)
13. [Ground](#13-ground)
14. [Basic JSON Structure](#14-basic-json-structure)
15. [Importing a Mesh](#15-importing-a-mesh)
16. [Materials, Colors, and Patterns](#16-materials-colors-and-patterns)
17. [Static Light and Orbital Light](#17-static-light-and-orbital-light)
18. [Multiple Instances](#18-multiple-instances)
19. [Declarative Timeline](#19-declarative-timeline)
20. [Compiling a PRG](#20-compiling-a-prg)
21. [How to Start a New Demo with Codex](#21-how-to-start-a-new-demo-with-codex)
22. [How to Request Changes](#22-how-to-request-changes)
23. [How to Diagnose a Problem](#23-how-to-diagnose-a-problem)
24. [Testing in VICE](#24-testing-in-vice)
25. [Runtime Controls](#25-runtime-controls)
26. [Freezing an Approved Version](#26-freezing-an-approved-version)
27. [When a Demo Is Canonical](#27-when-a-demo-is-canonical)
28. [Common Mistakes](#28-common-mistakes)
29. [Recommended Complete Workflow](#29-recommended-complete-workflow)
30. [Complete Prompt for Starting from Scratch](#30-complete-prompt-for-starting-from-scratch)
31. [Conclusion](#conclusion)

## 1. What You Need

The recommended environment is Windows 10 or Windows 11. The main builder is written for PowerShell, and the workflow described in this manual uses paths and commands typical of Windows.

The following components are required:

- a 3Dvibe64 release;
- PowerShell;
- 64tass;
- VICE;
- Python 3;
- Git, recommended but not strictly required;
- Codex with access to the working directory.

These components do not all serve the same purpose.

The 3Dvibe64 release contains the builder, examples, documentation, and any included tests. PowerShell runs the builder. 64tass compiles the generated Assembly. VICE launches the PRG and allows it to be verified. Python is useful for checks, conversions, and automation. Git makes version management safer, although it is not required to produce a PRG. Codex coordinates the operations and modifies the requested files.

You do not need to install or configure every tool manually. You can ask Codex to inspect the computer, identify what is missing, prepare portable versions, and verify that the entire toolchain works. It is nevertheless important to give Codex a working directory in which it can read, create, and modify files without changing the official copy of the engine.

## 2. How to Obtain 3Dvibe64

### Recommended Method: Official ZIP from GitHub

For a beginner, the simplest and safest method is to download the ZIP attached to an official release of the GitHub repository.

The procedure is as follows:

1. open the GitHub link provided by the author;
2. go to the **Releases** section;
3. select the version you want to use;
4. download the official ZIP attached to the release;
5. extract the ZIP into a dedicated directory.

One possible path is:

```text
C:\3Dvibe64\3Dvibe64-release
```

It is preferable to use the ZIP published among the release attachments rather than the generic command:

```text
Code → Download ZIP
```

The two downloads are not necessarily equivalent. The **Code → Download ZIP** button normally creates an archive of the current repository contents or of the selected branch. The ZIP attached to a release, by contrast, generally identifies a precise package that has already been prepared, verified, and intended for distribution. For a first use, it is therefore easier to start from the official release package.

After extraction, it is advisable to check that the directory contains at least the documentation, the examples, and the build script. The builder is typically located at:

```text
work\build-3Dvibe64.ps1
```

When only the repository link is available, it can be given directly to Codex with a request such as this:

```text
This is the official GitHub repository of the engine:

[paste the address copied from GitHub’s Code button here]

Find the latest stable release, download the official ZIP,
verify its contents, and extract it to:

C:\3Dvibe64\official-engine

Do not modify the official copy directly.
```

The final sentence is important. The `official-engine` directory must be treated as the baseline, meaning a reference copy that must remain untouched. Demos and experiments will be created in separate copies.

The manual does not embed a specific URL because the address depends on the
repository’s final location. Copy it from the official GitHub page’s **Code**
button and paste it into the request before running it.

When the Codex environment does not allow network access, one of two things may happen:

- Codex asks for permission to access the Internet and download the package;
- Codex asks the user to download the ZIP manually and then provide its local path.

In either case, once the ZIP is available on the computer, Codex can verify its contents, extract it, and prepare a working copy.

### Alternative Method: Git

Anyone who wants to follow repository development more closely can use Git:

```powershell
git clone <address-copied-from-GitHubs-Code-button>
```

Git is more powerful than a simple ZIP archive because it allows you to:

- see which files have changed;
- compare two project states;
- create separate development branches;
- undo incorrect changes;
- return to an earlier version;
- update the project from the repository;
- verify that the baseline has not been altered;
- record the evolution of a demo in an orderly way.

Using Git does, however, require some familiarity with commits, branches, and the working tree. These concepts do not need to be addressed immediately in order to create a first demo. The official ZIP therefore remains the most direct method, while Git becomes particularly useful once the work begins to produce many variants or changes to the builder.

## 3. Installing the Tools

### PowerShell

PowerShell is already included in modern versions of Windows. It should not be confused with the older Command Prompt: the builder uses PowerShell syntax and functions.

To check that it is available, open PowerShell and enter:

```powershell
powershell.exe -NoProfile -Command "$PSVersionTable.PSVersion"
```

The `-NoProfile` option prevents any user-profile customizations from interfering with execution. If the command returns a version number without errors, PowerShell is available.

The engine builder is normally located here:

```text
work\build-3Dvibe64.ps1
```

The script should be run from the root of the working copy or invoked with a full path. On some Windows systems, script execution may be restricted by the Execution Policy; for this reason, the example commands use:

```text
-ExecutionPolicy Bypass
```

This option applies only to the process launched by the command and allows the script to run without necessarily changing the system’s permanent configuration.

### 64tass

64tass is the assembler that turns the code generated by the builder into the PRG intended for the Commodore 64. The public builder resolves the 64tass path at the beginning of its execution and, if it cannot find it, stops before writing `work\3Dvibe64.asm` and before creating the PRG. Obtaining even the ASM through the official builder therefore requires 64tass to be available through one of the supported methods.

A compatible assembler version is required; the engine documentation specifies 64tass 1.60 or later. A recommended portable location is:

```text
C:\Tools\64tass\64tass.exe
```

A portable version does not require a conventional installation: you only need to extract the files into a stable directory and tell the builder where the executable is located.

Temporary environment-variable configuration:

```powershell
$env:TASS64_EXE = "C:\Tools\64tass\64tass.exe"
& $env:TASS64_EXE --version
```

The variable remains valid for the current PowerShell session. The second command launches 64tass and displays its version, allowing you to verify that the path is correct.

The builder may also locate 64tass through other configurations, such as a `TASS64_PATH` variable, the Windows `PATH`, or a copy placed under `work\tools\64tass`. Before changing the configuration, Codex should inspect the builder and use one of the methods it actually supports.

### VICE

VICE is the emulator used to run and verify PRGs. The VICE package includes several executables; the following are especially important for this manual:

- `x64sc.exe`: accurate C64 emulation, to be used for the main tests and for authoritative rendering verification;
- `xscpu64.exe`: SuperCPU emulation with an accelerable CPU, usable as a supplementary, non-contractual test for finding sequences accidentally tied to CPU speed. It does not replace `x64sc` and is not part of the distribution’s official regression signatures.

A recommended portable path is:

```text
C:\Tools\VICE\bin
```

To point PowerShell to the main executable:

```powershell
$env:VICE_EXE = "C:\Tools\VICE\bin\x64sc.exe"
& $env:VICE_EXE -version
```

The `VICE_EXE` variable is not necessarily read by the builder: it is used in this manual as a convenient reference for starting the emulator. Codex can also record the path to `xscpu64.exe` separately when the optional accelerated test is selected. The absence of `xscpu64` does not prevent a build and does not invalidate the public contract based on `x64sc`.

VICE is not used merely to “see whether it starts.” It must be used to check for the absence of returns to BASIC, bitmap corruption, clipping errors, depth problems, and abnormal timing differences between configurations.

### Python 3

Python is used for many support activities:

- automated checks;
- running tests included in the package;
- hash verification;
- mesh import and analysis;
- OBJ conversion;
- graphical simulations;
- JSON generation or transformation;
- contract tests;
- log and screenshot processing;
- comparison of outputs produced by different builds.

To check whether Python is available:

```powershell
python --version
```

A modern version of Python 3 is recommended. If the `python` command is not recognized, the `py` launcher may be available on some systems. Codex can check both and choose the one that works.

Python does not replace PowerShell or 64tass: it is a complementary tool. The builder remains the official script for generating the Assembly and the PRG.

### Git

Git is not required for compilation, but it is strongly recommended when working on multiple revisions of the same demo or when modifying the builder.

Check it with:

```powershell
git --version
```

Even without Git, you can proceed by using directory copies and SHA-256 hashes. Git does, however, make it easier to understand exactly which files have been modified and helps prevent accidental changes from going unnoticed.

## 4. Letting Codex Prepare the Environment

Almost all of the technical setup can be entrusted to Codex, avoiding the need to search manually for every program and every path.

Codex can:

- check which tools are already installed;
- identify missing tools;
- check the available versions;
- download programs from official sources;
- install them through `winget` or another package manager;
- prepare portable versions;
- configure temporary or permanent environment variables;
- inspect the `PATH`;
- verify that the executables start;
- inspect the builder to understand how it locates 64tass;
- compile an example included in the package;
- launch the PRG in VICE;
- report paths, versions, and test results.

Depending on the computer’s security settings and the Codex environment, some operations may require explicit permission. Codex may be able to proceed directly, or it may ask for permission to:

- access the Internet;
- download files;
- start installers;
- use `winget`;
- modify the `PATH`;
- write outside the assigned workspace;
- perform administrative operations;
- launch VICE or other external programs.

Actual capabilities depend on the Codex surface, active workspace, sandbox, and
approval policy. In default local configurations, write access is normally limited
to the workspace and network access remains disabled until granted or configured.
See the current [official sandbox and approvals documentation](https://learn.chatgpt.com/docs/agent-approvals-security.md).

A complete request can be written as follows:

```text
Prepare this computer for developing demos with 3Dvibe64.

The engine release is available here:

C:\3Dvibe64\official-engine

Check whether the following are available:

- PowerShell;
- Python 3;
- Git;
- 64tass;
- VICE with x64sc and, only for the supplementary non-contractual test, xscpu64.

If anything is missing, download it exclusively from official sources
and install it, or prepare a portable version.

Ask for my permission whenever the system requires it for
downloads, installations, environment-variable changes,
or launching external programs.

Do not modify the official release. Create a separate working copy
and compile an official example to verify the environment.
```

This prompt establishes four useful constraints: use of official sources, authorization when necessary, protection of the baseline, and the requirement to perform a real test.

At the end of the setup, it is preferable to ask Codex for a report that includes:

- Python version;
- Git version;
- 64tass version;
- VICE version;
- path to each executable;
- path to the official copy;
- path to the working copy;
- build command that was executed;
- path to the test PRG;
- compilation result;
- VICE test result;
- any permissions or configurations that are still required.

A simple message such as “everything is installed” is not enough: the paths and versions make the result verifiable and allow the build to be repeated later.

## 5. Directory Organization

An orderly structure prevents working versions from being lost and makes experiments easier to compare.

Example:

```text
C:\3Dvibe64\
    official-engine\
    engine-demo-dev1\
    engine-demo-dev2\
    demo-output\
    models\
```

The directories serve different purposes:

- `official-engine` contains the baseline and must not be modified;
- `engine-demo-dev1` contains the first development copy;
- `engine-demo-dev2` may contain a later variant;
- `demo-output` collects results and diagnostics without cluttering the engine copy;
- `models` stores OBJ files and other source assets.

The official release must remain untouched. It should not be used as an experiment folder, because an accidental change would make it difficult to distinguish what belongs to the original package from what was created during development.

To create a complete copy in PowerShell:

```powershell
Copy-Item `
  -LiteralPath "C:\3Dvibe64\official-engine" `
  -Destination "C:\3Dvibe64\engine-demo-dev1" `
  -Recurse
```

`-LiteralPath` prevents special characters in the path from being interpreted as wildcards. `-Recurse` copies all subdirectories.

Diagnostic outputs should be stored outside the engine copy:

```text
C:\3Dvibe64\demo-output\
```

This directory can contain:

- experimental JSON files;
- PRGs;
- diagnostic ASM files;
- screenshots;
- logs;
- traces;
- hashes;
- technical reports;
- comparisons between builds;
- copies of build commands, when useful.

Separating the outputs has two advantages. First, the engine directory remains readable. Second, temporary files can be removed more easily without deleting anything required for the build.

## 6. How Compilation Works

The main source of a demo is the JSON file. The JSON describes the scene, while the builder automatically generates code suitable for the selected configuration.

The complete process is:

```text
scene.json
    ↓
build-3Dvibe64.ps1
    ↓
3Dvibe64.asm
    ↓
64tass
    ↓
3Dvibe64.prg
```

In detail:

1. `scene.json` contains objects, meshes, camera, light, world, and animations;
2. `build-3Dvibe64.ps1` reads the JSON and the command-line parameters;
3. the builder generates `3Dvibe64.asm`, including only the functions required by the build;
4. 64tass assembles the generated source;
5. the final result is `3Dvibe64.prg`.

The generated files are normally located at:

```text
work\3Dvibe64.asm
work\3Dvibe64.prg
```

The ASM file is an intermediate product. It should not be modified manually to create a canonical demo, because a new run of the builder will regenerate it and erase the changes.

If a required feature is missing from the engine, the correct procedure is:

1. identify the limitation precisely;
2. demonstrate that the desired behavior cannot be achieved with the JSON and the options already available;
3. modify the builder in a development copy;
4. add a general JSON or compile-time option, avoiding conditions tied to a single scene;
5. verify that the previous examples still work;
6. rebuild the PRG from the JSON;
7. document the new option and the command used.

A patch applied directly to the ASM can be useful for a quick experiment or to confirm a technical hypothesis. It should not, however, become the definitive source of the demo. The final result must be regenerable without any manual intervention after the builder has run.

## 7. Graphics Modes

3Dvibe64 provides five graphics modes. They are not simply increasing levels of quality: each uses a specialized pipeline and serves different needs. The selected mode affects the type of image, the amount of computation, the required memory, and the available features.

Before compiling, it is useful to decide what result is actually required. Using a mode that is more complex than necessary can reduce speed or memory headroom without producing a visible benefit in the scene.

### GraphicsMode 1

GraphicsMode 1 is the essential wireframe mode. It mainly draws mesh edges and minimizes the work required for filling and lighting.

It is suitable for:

- achieving the lowest possible cost;
- displaying simple meshes;
- clearly showing the geometric structure;
- creating technical demos;
- quickly checking the orientation and shape of a model;
- verifying that a mesh is transformed and projected correctly before switching to a solid mode.

Surfaces are not filled in this mode. For that reason, it may be difficult to understand which lines belong to the front or rear of a complex object. The advantage is the lower processing cost.

When the multimaterial profile supported by the engine is used, the wire modes can distinguish two color families. That configuration must, however, comply with the builder’s actual contract and should be derived from the official examples rather than improvised.

### GraphicsMode 2

GraphicsMode 2 is the hidden-wire path. It preserves the line-based appearance but handles surfaces, culling, hidden-line masking, materials, and depth order in a more advanced way.

It is useful when you want to:

- retain a wireframe style;
- reduce lines that should lie behind visible surfaces;
- show the shape of overlapping objects more clearly;
- use geometric clipping against the Ground plane while keeping a line-based representation.

Ground remains line-only: it is not filled as it is in the solid modes. Even when the `plane` geometry profile classifies and clips faces relative to the ground, Ground itself remains a horizon line rather than a colored half-plane.

### GraphicsMode 3

GraphicsMode 3 uses specialized, fast solid rendering. Faces are filled, but shading is static and calculated by the builder.

Main characteristics:

- static shading calculated before execution;
- colors and patterns assigned to faces;
- dedicated rasterizer;
- specific fast paths;
- lower cost than dynamic shading;
- no dynamic light transformation of the kind required by the later modes.

It is suitable when face colors do not need to change continuously in response to light. For example, it can be a good choice for a rotating object that uses predefined artistic shading, or for a scene in which the priority is to improve speed while retaining filled surfaces.

Mode 3 has some paths of its own, including dedicated culling. You should therefore not assume that every option available for Mode 4 and Mode 5 automatically applies to this mode as well.

### GraphicsMode 4

GraphicsMode 4 is the solid mode with dynamic shading.

Characteristics:

- normal transformation;
- dynamic lighting;
- polygon filling;
- satin, gloss, reflective, and mirror materials, according to the tables actually supported;
- support for advanced instance features;
- shared-mesh handling when requested in the JSON;
- the XY-Q2 subpixel pipeline, automatically enabled by the official profile.

It is suitable when lighting must react to object rotation or light movement. It is also the reference mode for scenes in which material variation is an important part of the visual effect.

Its cost is higher than Mode 3 because normals, light, and shading must be updated during execution. Before using it with a very heavy mesh, it is advisable to check memory, viewport size, and the number of simultaneously visible faces.

### GraphicsMode 5

GraphicsMode 5 inherits the Mode 4 pipeline and adds a one-pixel low-resolution outline.

Characteristics:

- filling with dynamic shading;
- Mode 4 materials and lighting;
- outline added after the fill;
- outline calculated from the final polygon after clipping;
- outline applied according to the existing painter order;
- use of the world background color for the border.

The fact that the outline is calculated from the final polygon is important. If a face is clipped by the near plane or by the screen boundaries, the outline follows the resulting shape rather than the original geometry that lies outside the view. Discarded faces must not leave residual outlines.

Mode 5 is suitable for a more graphic, readable, or illustration-like style. The outline does, however, have a measurable cost because it is drawn face by face after filling. In a scene that is already close to timing or memory limits, Mode 4 may be preferable.

### How to Choose Quickly

As a practical rule:

- choose Mode 1 for an essential, very lightweight wireframe;
- choose Mode 2 for hidden-wire rendering and more controlled hidden lines;
- choose Mode 3 for solid surfaces with static shading and a lower cost;
- choose Mode 4 for dynamic lighting and materials;
- choose Mode 5 when the Mode 4 result also needs an outline.

This is only an initial guide. The final choice must always be tested with the actual mesh and scene.

## 8. Camera

The camera determines the point from which the scene is viewed and how objects are transformed into view space. The three main profiles are:

```text
fixed
walkLite
walkFull
```

The names do not merely indicate how many controls are available. Each profile can produce differences in generated code, memory use, and transformation precision.

### fixed

The `fixed` camera remains stationary during execution, apart from any animation explicitly managed by the scene or by dedicated features.

It is suitable for:

- rotating objects in front of a stable viewpoint;
- automatic animations;
- benchmarks;
- mesh presentations;
- scenes controlled entirely by the timeline;
- builds in which code and memory use should be reduced.

The `fixed` path is specialized and lightweight. It generally consumes fewer resources and fits more easily within the `stable` memory layout. Its projection is, however, more compact and quantized than that of the mobile cameras; in very close, complex, or geometrically delicate scenes it may provide lower quality.

A fixed camera does not have the normal runtime translation controls. Objects and light can still continue to rotate or animate.

### walkLite

The `walkLite` camera is a simplified mobile camera.

It is useful when the scene requires:

- forward and backward movement;
- lateral movement or strafing;
- vertical movement;
- yaw;
- pitch;
- a more precise mobile transformation;

but does not require roll.

The camera starts from the pose defined in the scene and remains still until the user issues a command. The fact that the camera is stationary does not stop other animations: object rotation, orbital light, and timelines can continue to advance.

The `walkLite` profile uses the Mobile Y-Q2 transformation. If faces must be genuinely clipped while crossing the camera plane, the `clip` near profile should be selected.

### walkFull

The `walkFull` camera adds roll to the features of `walkLite` and is the most complete navigation profile.

Depending on the controls compiled into the build, it may include:

- `W` / `S`: forward and backward;
- `A` / `D`: strafe left and right;
- `Q` / `E`: vertical movement;
- cursor keys: yaw and pitch;
- `N` / `M`: roll.

Roll changes the orientation of the lateral and vertical axes. Consequently, while the camera is tilted, strafing and vertical movement can contribute to more than one world axis.

`walkFull` requires more code and more runtime data than `walkLite`. With complex meshes, geometric Ground, clipping, and many active features, the `high-basic-v2` layout may be necessary.

Unneeded controls can be removed at compile time. For example, `-NoCameraRuntimeControls` allows a mobile camera to be compiled without the runtime input infrastructure, while `-StaticPose` prevents automatic updates to the mesh pose. Removing unused features can reduce code size and processing cost.

### Note on Camera Movement

Mobile cameras advance according to simulation ticks, not according to the number of frames that are actually rendered. This prevents narrative movement from changing when the scene becomes heavier or is run on an accelerated CPU.

Diagonal movement is additive and is not normalized. Pressing two orthogonal directions therefore produces a greater total displacement than pressing only one. Opposing pairs, such as `W` and `S`, cancel each other out.

## 9. Viewport and Memory

### Viewport

The viewport is the area in which the 3D scene is rendered. A larger viewport provides a more readable image but requires more pixels to be processed. A smaller viewport reduces rasterizer work and can free additional headroom for more complex scenes.

From the command line:

```text
-CameraViewport normal
-CameraViewport small
```

In the JSON or scene contract, the field may be named `viewportProfile`. When a value is supplied explicitly on the command line, the builder must apply the precedence defined by its contract; Codex should therefore inspect the examples and the script before building.

#### normal

`normal` is the default viewport. With the Generic Text/FPS split compiled in it has a 160×88 3D body at Y=12; `-NoFpsOverlay` restores the legacy 160×100 body.

It is the most readable choice and normally the starting point. It should be used when the scene fits within the memory limits and maintains adequate speed.

#### small

`small` measures 128×80 low-resolution pixels. With the text split it starts at Y=12; without the split it is centered at Y=10.

It provides:

- fewer pixels to process;
- potentially greater speed;
- more headroom for complex scenes;
- a smaller visible area;
- objects that appear smaller on screen for the same composition.

It is one of the first options to try when rendering is too heavy, provided that the reduced visual area is acceptable.

The area outside the viewport and the VIC-II border must remain black, in accordance with the engine’s intended behavior.

### Memory Layout

Two main layouts are available:

```text
-MemoryLayout stable
-MemoryLayout high-basic-v2
```

The layout determines where code, data, and buffers are placed in C64 memory. It is not a purely cosmetic option: a scene may compile under one layout and exceed a memory window under the other.

#### stable

`stable` is the standard, compact, preferred layout.

It is suitable for:

- light or medium scenes;
- a fixed camera;
- meshes that are not too large;
- a limited number of instances;
- configurations without a heavy geometric Ground;
- builds in which too many features are not enabled simultaneously.

The builder must stop compilation when code or data intrudes into the bitmap, screen buffer, or other reserved areas. It should not switch silently to another layout.

#### high-basic-v2

`high-basic-v2` is the segmented layout for heavier builds. It also uses RAM beneath the BASIC ROM and can produce physically larger PRG files because of gaps between segments.

It is suitable for:

- large scenes;
- complex meshes;
- many instances;
- a mobile camera, especially `walkFull`;
- a Ground plane;
- complex clipping;
- complex timelines;
- solid modes with substantial runtime data.

A theoretical limit of 255 elements does not mean that every scene can actually contain 255 objects, faces, or descriptors. Many indices are one byte wide, but practical limits are often reached earlier because of memory windows, runtime buffers, and the code required by enabled features.

When a build does not fit in `stable`, the builder may suggest `high-basic-v2`, but the switch must be requested explicitly. The larger layout should not be treated as an automatic solution to every problem: if it is also exceeded, the scene will have to be simplified.

## 10. Engine Units

To describe positions, angles, and timing correctly, three units must be distinguished: WU, TU, and ST.

### WU — World Unit

WU means **World Unit**. It is the abstract linear unit used for:

- position;
- dimensions;
- distance;
- linear velocity;
- Ground height;
- camera and object coordinates, according to the supported fields.

One WU does not automatically correspond to one meter, one centimeter, or any other real-world measure. The physical scale is decided by the scene author. For example, a cube 56 WU wide can represent a small spaceship or a building: the engine imposes no real-world correspondence.

Where a fixed-point accumulator is used, one WU contains 256 positional sub-units. This allows movements smaller than one WU per tick to accumulate smoothly, even though the visible geometry is subsequently processed through quantized coordinates.

### TU — Turn Unit

TU means **Turn Unit** and is the angular unit.

A complete revolution contains 256 TU:

```text
256 TU = 360 degrees
1 TU = 1.40625 degrees
64 TU = 90 degrees
128 TU = 180 degrees
```

Angles wrap naturally through the 0–255 cycle. This system is suitable for the 256-entry trigonometric tables used by the renderer.

When specifying a rotation or angular velocity in the JSON, check whether the field uses absolute TU or TU per tick. Do not enter a value in degrees while assuming that the builder will automatically interpret it as such.

### ST — Simulation Tick

ST means **Simulation Tick**. It is the normalized step used to advance:

- object movement;
- object rotation;
- camera controls;
- light phases;
- timelines;
- depth ping-pong;
- other simulation-linked automatic behavior.

Timelines operate at 50 logical ticks per second:

```text
50 ST = 1 second
100 ST = 2 seconds
150 ST = 3 seconds
3000 ST = 1 minute
```

The normalized tick keeps event duration consistent on PAL and NTSC systems. On PAL, one ST is normally produced per VBlank. On NTSC, the engine uses five ticks for every six VBlanks, yielding a nominal 50 ST per second despite the different video refresh rate.

This means that a 150 ST sequence should last about three seconds on both PAL and NTSC. The number of frames actually rendered may change when the scene is heavy, but the simulation’s logical time should not change.

## 11. Near Plane and Approaching Surfaces

The near plane defines how faces are handled when they move very close to the camera or cross the camera plane.

The public option is:

```text
-Mode4NearProfile default|late|clip
```

The name contains `Mode4` for historical reasons, but the profile applies to GraphicsMode 3, 4, and 5.

The choice affects two distinct aspects:

- the depth at which a face is accepted;
- whether a face that crosses the camera plane is discarded entirely or clipped geometrically.

### default

The `default` profile uses conservative behavior:

- rejection below 8 WU;
- minimum perspective divisor of 8;
- removal of faces that are too close through the traditional path;
- no extreme approach to the surface.

It is the most cautious and compatible choice. It should be used when the camera does not need to move almost into contact with objects.

### late

The `late` profile delays rejection:

- visibility down to 1 WU;
- minimum perspective divisor of 2;
- rejection at zero or negative depth;
- use of the geometric divisor from 2 WU onward;
- a short perspective plateau between 1 and 2 WU;
- no polygon clipping against the camera plane.

A face that crosses the camera plane may be discarded in its entirety. This profile therefore allows the camera to move much closer than `default`, but it does not preserve only the part that remains in front of the camera.

`late` does not change backface culling and does not make meshes two-sided.

### clip

The `clip` profile performs genuine clipping against the camera plane.

Characteristics:

- it preserves the projectable portion of the face;
- it allows the camera to approach all the way to the crossing point;
- it generates projectable intersections near the camera plane;
- it uses a minimum perspective divisor of 2;
- it rejects the face only after the actual crossing;
- it works with `fixed`, `walkLite`, and `walkFull` cameras.

When geometric Ground is also active, clipping against Ground is performed before clipping against the camera plane. Camera-space culling continues to refer to the original polygon, while rasterization and the Mode 5 outline use the final post-clipping polygon.

This is the most suitable profile when the camera must genuinely move into contact with a wall or pass through a surface without the entire face disappearing in advance.

### What the Near Profiles Do Not Do

None of the three profiles automatically makes meshes visible from both sides.

Inside a closed mesh, the following still apply:

- winding;
- backface culling;
- one-sided behavior;
- the orientation of normals and faces.

A camera that enters a closed object may therefore correctly see many faces disappear. This does not necessarily indicate a near-plane error.

Legacy diagnostic options relating to exploratory clipping must not be combined at random with the `late` and `clip` profiles. Codex must follow the builder’s public contract and the examples included in the release.

## 12. Backface Culling

Backface culling removes faces that point away from the camera. It is a fundamental feature for reducing renderer workload and for correctly representing closed, one-sided objects.

For Mode 4 and Mode 5, the following are available:

```text
-FaceCullProfile default
-FaceCullProfile stable
```

### default

`default` uses the traditional culling path. It is suitable for most scenes and preserves the engine’s standard behavior.

The traditional test is based on the projected result. In nearly edge-on poses, coordinates that are very close together and quantized may sometimes cause the sign of the area to change from one frame to the next.

### stable

`stable` is recommended for objects that perform:

- roll;
- yaw;
- pitch;
- combined rotations;
- nearly edge-on poses;
- transitions in which a face is presented almost edge-on.

The profile uses camera-space data within the most delicate range in order to reduce variations caused by rounding of projected coordinates. Outside the nearly edge-on region, it may continue to use the screen-space test provided by the optimized path.

Faces that are exactly edge-on are retained according to the engine’s contract. No state is carried from one frame to the next, and no temporal hysteresis is applied.

`stable` does not enable two-sided rendering. A face that genuinely points away from the camera continues to be discarded.

Mode 3 retains its own dedicated path and does not automatically use `stable`. If Codex receives a request for stable culling in an unsupported mode, it must inspect the builder and report the limitation rather than pretending that the option was applied.

## 13. Ground

Ground represents the terrain or horizon of the scene. Two distinct concepts are available: `simple` and `plane`.

### Ground simple

`simple` is the lighter solution. It is suitable when a visual ground reference is enough and meshes do not need to be clipped geometrically against a plane in the world.

Depending on the graphics mode, it may produce a decorative horizon line or the traditional screen-space behavior. Its main advantage is a lower cost in bytes and cycles.

It is a good choice for:

- open scenes in which no object crosses the ground;
- demos in which Ground serves only as a background element;
- builds that are close to the memory limits;
- quick tests of camera and composition.

### Ground plane

`plane` defines a genuine geometric plane with clipping. Its height is expressed in WU through `ground.z` under the public `world-z-up` convention; the plane is therefore:

```text
world Z = ground.z
```

Behavior depends on the mode:

- Mode 1: the decorative horizon line remains available, without geometric occlusion or filling;
- Mode 2: Ground remains line-only, but `plane` classifies faces relative to the plane, discards those entirely on the side opposite the camera, and clips those that cross it;
- Mode 3: the half-plane can be filled, and geometry is classified and clipped;
- Mode 4: the plane is filled and lit through the dynamic path;
- Mode 5: the plane is filled, and the result can include the outline provided by the mode.

In Mode 2, a half-plane is never filled. Hidden-wire and edge processing use the polygon that results after clipping.

The Ground plane may require more memory and more cycles than `simple`. Scenes that exceed the `stable` layout must explicitly select `high-basic-v2`.

The horizon line is sensitive to roll. According to the engine convention:

```text
+32 TU  = horizon descending toward the right
-32 TU  = horizon ascending toward the right
+64 TU  = vertical horizon
```

If the line lies entirely outside the viewport, it must not be forced onto a border. The correct result is for it not to be drawn.

Camera height determines which side of the plane is visible. The retained geometric side changes when the camera crosses the plane, not merely when its height is modified without crossing it.

## 14. Basic JSON Structure

The JSON is the document that describes the scene. It must be readable both by the builder and by anyone who may need to modify the demo in the future.

The exact structure can change between releases. Before creating or modifying a scene, Codex must read:

- the main README;
- the Italian or English documentation included in the package;
- the official examples;
- the builder;
- any schema that may be present;
- the contract tests, when they help clarify fields and limits.

You should therefore not take a generic example found online and assume that every field is valid. The final authority is the builder contained in the release being used.

A basic scene normally includes:

- a schema identifier;
- a name;
- the graphics mode;
- the axis convention;
- a camera;
- one or more meshes;
- one or more objects that instantiate the meshes;
- one or more lights;
- the world, including the background color;
- an optional scene contract;
- an optional timeline.

An instructional example, close to the structure used by the engine examples, may look like this:

```json
{
  "schema": 1,
  "name": "my-demo",
  "graphicsMode": 4,
  "axisConvention": "world-z-up",

  "camera": {
    "id": "camera-main",
    "mode": "fixed",
    "position": [0, -63, 20],
    "rotation": [0, 0, 0]
  },

  "meshes": [
    {
      "id": "mesh-main",
      "type": "mesh",
      "geometry": "solid",
      "materialProfile": "single",
      "builtin": "cube"
    }
  ],

  "objects": [
    {
      "id": "object-main",
      "mesh": "mesh-main",
      "position": [0, 80, 0],
      "rotation": [0, 0, 0],
      "scale": 1,
      "visible": true,
      "material": "gray",
      "reflectivity": "satin"
    }
  ],

  "lights": [
    {
      "id": "light-main",
      "type": "static",
      "position": [-52, 12, 58],
      "intensity": 10
    }
  ],

  "world": {
    "backgroundColor": 0,
    "grounds": []
  },

  "contract": {
    "version": 1,
    "worldSpace": "world-z-up",
    "objectSpace": "aligned-world",
    "viewportProfile": "normal",
    "ground": false
  }
}
```

This example is intended to explain how the data is organized. It must not be copied without checking the release examples: fields, required values, and permitted combinations must be confirmed against the builder.

Using `"builtin": "cube"` makes the example mesh complete and buildable without
leaving empty geometry arrays. When explicit geometry is used, `vertices` and
`faces` must contain valid data; the builder rejects a polygon mesh with no faces.

A purely conceptual description may also use a textual label such as:

```json
"schema": "3dvibe64-scene"
```

You should not, however, assume that this form is accepted by the actual build. In the examples supplied with the engine, the schema is represented numerically. Codex must use the value required by the actual package.

### Axis Convention

The public convention is:

```text
world-z-up
```

This means that:

- `+X` points right and `-X` points left;
- `+Y` points forward, toward the depth of the world, and `-Y` points backward;
- `+Z` points upward and `-Z` points downward.

Z therefore normally represents vertical height. This applies to scene vectors such as object position and velocity, camera position and rotation, and the position of a static light.

Internally, the engine uses a different axis arrangement and converts scene vectors. The raw local coordinates of meshes must nevertheless be checked carefully during import: the importer must provide them in the orientation actually expected by the renderer. Simply adding `axisConvention: "world-z-up"` therefore does not replace visual and geometric verification of the mesh.

### Meshes and Objects Are Not the Same Thing

The `meshes` section describes source geometry. The `objects` section describes instances placed in the world.

A mesh can contain:

- vertices;
- faces;
- built-in geometry;
- a material profile;
- optional local face overrides.

An object can instead contain:

- a mesh reference;
- position;
- rotation;
- scale;
- visibility;
- material;
- reflectivity;
- velocity;
- instance overrides.

Separating the two concepts allows the same geometry to be used in several places in the scene, especially when the source-sharing path is enabled.

## 15. Importing a Mesh

A mesh can be supplied to Codex, for example, as an OBJ file:

```text
C:\3Dvibe64\models\object.obj
```

Importing should not consist of simply copying the coordinates. Geometry, numeric limits, and the axis convention must be checked before compilation.

A recommended request is:

```text
Import this mesh into the demo:

C:\3Dvibe64\models\object.obj

Before compiling, verify:

- number of vertices;
- number of faces;
- presence of non-triangular faces;
- winding;
- normals;
- duplicate faces;
- unused vertices;
- scale;
- world-z-up orientation;
- compatibility with the engine limits.

Do not simplify or modify the mesh without telling me.
Create a diagnostic view and compile a test PRG.
```

Each check has a specific purpose.

#### Number of Vertices and Faces

The count affects both transformation and rasterization time and memory use. One-byte indices impose theoretical limits, but the practical limit may be much lower.

#### Non-Triangular Faces

The engine can use triangles and quads in the supported paths, but an OBJ can also contain polygons with more vertices or concave faces. Codex must determine whether they need to be triangulated and report any transformation.

#### Winding

Winding is the order of the vertices in a face. It determines which side is considered the front. Reversed winding can cause a face to disappear because of backface culling.

#### Normals

Normals are essential, especially for dynamic shading. If they are inconsistent, colors may react to light in the opposite direction or discontinuously.

#### Duplicate Faces and Unused Vertices

Duplicate faces consume memory and can create overdraw or artifacts. Unused vertices produce no visible geometry but occupy space and complicate analysis.

#### Scale and Local Ranges

Local mesh coordinates are converted and quantized. In the configuration documented by the engine, local components must remain within the range accepted by the builder, and scale is converted to Q6. A nominal scale of `1.0` corresponds to `64/64`; the documented maximum representable value is `127/64`, or `1.984375`.

It is not advisable to rely on an enormous scale to compensate for a model that is too small, or vice versa. It is preferable to normalize the mesh deliberately and verify that its local coordinates fall within the accepted domain.

#### Orientation

A mesh from Blender or another application may use a different convention for the vertical axis and forward axis. Codex must check it with a diagnostic view rather than merely changing the `axisConvention` label.

If the mesh is too heavy, Codex can prepare a low-poly variant. The following must still be preserved:

- the original model;
- the derived variant;
- a report of the changes;
- the vertex and face counts before and after;
- an indication of any triangulation or removal.

No simplification may be applied silently.

## 16. Materials, Colors, and Patterns

The engine uses colors, ramps, and patterns that are compatible with the VIC-II. Not every name or combination that a user might invent actually exists in the builder tables.

To avoid incompatible configurations, Codex should be instructed to use only the families that are genuinely present.

Example:

```text
Use only the colors and patterns from the gray family already
supported by the engine.

Assign the faces a readable combination of:

- solid colors;
- checker patterns;
- satin levels;
- reflective levels.

Do not introduce pigments or patterns that are not present in the
official tables.
```

The documented material families include:

```text
gray
white
red
green
blue
yellow
cyan
magenta
orange
brown
```

They can be selected by name or, in fields that allow it, through the corresponding index. The documented reflectivity levels are:

```text
satin
gloss
reflective
mirror
```

The visual result does not depend only on the name. Each family has specific ramps, and the builder must produce the VIC-II values intended for the material.

### Explicit VIC-II Color on a Face

Faces can be given an explicit color through `faceOverrides`:

```json
{
  "faceOverrides": {
    "0": {
      "solidColor": 7,
      "shading": false
    }
  }
}
```

`solidColor` uses VIC-II values from 0 to 15.

With:

```json
"shading": false
```

the face keeps the assigned color and is not modified by dynamic lighting. This option is useful for elements that must remain graphically stable, such as a panel, a painted light, a detail, or a decorative area.

In the shared-mesh path, `faceOverrides` belongs to the source mesh and uses local face indices. It must not be inserted as a different map inside each instance.

### Override Precedence

When more than one level assigns a material or color, precedence is:

1. local override on the source face;
2. instance override;
3. source-mesh material.

This rule makes it possible to preserve a general material and change only what is needed.

### Multimaterial Wire Rendering

In the supported wire modes, the multimaterial profile can represent exactly two color families through the two available bitmap slots. The scene must map faces explicitly and must not rely on a silent fallback.

This feature is distinct from the solid materials of Modes 3–5. Codex must use the dedicated official examples when preparing a two-color wire scene.

## 17. Static Light and Orbital Light

The light can be genuinely static or belong to the orbital path. The difference is not merely visual: it determines which tables, counters, and routines are included in the build.

### Genuinely Static Light

For a genuinely compile-time static light, use:

```json
{
  "type": "static",
  "position": [-52, 12, 58]
}
```

Fields required by the contract can be added, such as intensity:

```json
{
  "id": "light-main",
  "type": "static",
  "position": [-52, 12, 58],
  "intensity": 10
}
```

This path allows the builder to omit:

- phase advancement;
- unnecessary position copies;
- orbital updates;
- light ticks;
- duplicate tables;
- unused orbital infrastructure.

The light remains fixed in the world, but shading can still change when the object rotates, because the transformed normals change relative to the light direction.

It must not be confused with the older path:

```json
{
  "mode": "static"
}
```

The latter may retain part of the orbital logic, including phase, divisor, and tables. If the goal is to obtain a genuinely static, lighter light, the `type` field provided by the dedicated path must be used.

### Orbital Light

An orbital light changes position over time and is useful for demonstrating:

- dynamic shading;
- satin effects;
- reflectivity;
- surface variation during rotation;
- differences between materials;
- cyclical lighting effects.

The main CLI options include:

```text
-LightOrbit
-LightPhaseCount
-LightTickDiv
-LightStaticPhase
```

The documented orbital profiles are `flat` and `tumble3d`. The number of phases can be 8, 16, or 32. `LightTickDiv` determines how many ST elapse before the phase advances. The complete period is therefore determined by the number of phases multiplied by the tick divisor.

`LightStaticPhase` can freeze one sample of the legacy orbital path. This is not necessarily equivalent to the genuinely static `type: "static"` light, because it may retain data and code from the orbital system.

Light speed must be tied to simulation ticks or VIC-II timing, not to the number of CPU iterations. This keeps orbit duration consistent across PAL, NTSC, and accelerated CPUs.

## 18. Multiple Instances

In Modes 4 and 5, the same mesh can be reused without emitting the source geometry more than once.

The JSON option is:

```json
{
  "meshSourceSharing": true
}
```

A mesh is declared once in the `meshes` section. Multiple objects in the `objects` section can then refer to the same identifier.

Each instance can have its own:

- position;
- rotation;
- scale;
- visibility;
- material;
- reflectivity;
- color;
- velocity;
- timeline state.

The source geometry is emitted only once, while each instance retains separate runtime buffers for:

- transformed vertices;
- projected vertices;
- current pose;
- visibility;
- participation in the global depth order.

This means that two instances can occupy different positions and rotations in the same frame. They are not merely post-render graphical copies: both participate in the 3D pipeline and in the global painter order.

The option is valid only in Modes 4 and 5. If it is requested in Mode 1, 2, or 3, the build must stop. There must also be genuine reuse: at least one mesh must be referenced by more than one instance. The engine must not silently fall back to traditional expansion.

Conceptual example:

```json
{
  "objects": [
    {
      "id": "object-blue",
      "mesh": "ship",
      "position": [-20, 80, 0],
      "colorOverride": 6
    },
    {
      "id": "object-red",
      "mesh": "ship",
      "position": [20, 120, 10],
      "colorOverride": 2
    }
  ]
}
```

Override precedence is:

1. face override;
2. instance override;
3. mesh material.

In the shared path:

- `faceOverrides` must belong to the source mesh;
- keys are local face indices;
- different `faceOverrides` maps are not allowed for separate instances of the same source;
- `materialOverride`, `reflectivityOverride`, and `colorOverride` can instead be applied to an instance.

Sharing reduces duplication of source geometry, but it does not eliminate the cost of each instance’s runtime buffers. A scene containing many copies can therefore still exhaust memory. One-byte indices impose theoretical limits of 255 in several categories, but practical limits are generally lower.

## 19. Declarative Timeline

The timeline makes it possible to construct an animated sequence without writing an Assembly scheduler by hand. The scene is divided into deterministic states; each state can set or update object properties for a specified number of ticks.

Conceptual structure:

```json
{
  "timeline": {
    "tickRate": 50,
    "resetKey": "SPACE",
    "initialState": "entry",

    "states": [
      {
        "id": "entry",
        "duration": 150,
        "next": "loop",

        "instances": {
          "object-main": {
            "visible": true,
            "positionVelocity": [0, -1, 0],
            "rotationVelocity": [0, 0, 1]
          }
        }
      },

      {
        "id": "loop",
        "duration": 500,
        "loop": true,

        "instances": {
          "object-main": {
            "position": [0, 40, 0],
            "rotation": [0, 0, 0]
          }
        }
      }
    ]
  }
}
```

### Meaning of the Main Fields

```text
tickRate
resetKey
initialState
states[].id
states[].duration
states[].next
states[].loop
states[].instances
visible
position
rotation
scale
positionVelocity
rotationVelocity
materialOverride
reflectivityOverride
colorOverride
```

- `tickRate` establishes the timing contract and must be 50;
- `resetKey` can assign `SPACE` to reset the sequence;
- `initialState` identifies the state from which execution begins;
- `id` uniquely identifies each state;
- `duration` expresses the duration in ST;
- `next` identifies the following state;
- `loop` indicates the intended looping behavior;
- `instances` contains the changes applied to objects during the state.

The correct field for visibility is:

```text
visible
```

and not:

```text
visibility
```

The incorrect field may produce a warning and be ignored. This type of error is dangerous because the JSON may appear readable and valid even though the scene does not behave as intended.

### Units Used in the Timeline

- `position` is expressed in WU;
- `rotation` is expressed in TU;
- `positionVelocity` is expressed in WU/ST;
- `rotationVelocity` is expressed in TU/ST;
- `duration` is expressed in ST.

With `tickRate: 50`, a duration of 150 corresponds to approximately three seconds.

### Main Limits

- `tickRate` must be 50;
- the timeline must contain from 1 to 255 states;
- every duration must be between 1 and 65535 ticks;
- the product of the number of states and the number of objects in the scene must not exceed 255;
- there is no general-purpose sinusoidal easing system.

The state × object matrix limit exists because the builder must represent the combinations with compact structures. It is therefore not enough to check the number of states and the number of objects separately.

### Resetting the Timeline

With:

```json
"resetKey": "SPACE"
```

the reset must restore the state, poses, visibility, and counters according to the engine contract. This is useful for repeating a sequence during testing without restarting the PRG.

### More Complex Animations

In the absence of general-purpose sinusoidal easing, more elaborate animations can be constructed with:

- several consecutive states;
- progressive velocities;
- acceleration and deceleration segments;
- precalculated tables;
- external includes that are clearly separated from the renderer.

External includes must be documented and must not turn into obscure patches applied to generated code. The demo must remain deterministically rebuildable.

## 20. Compiling a PRG

Compilation must be performed from the working copy, not from the release preserved as the baseline.

Open PowerShell and move to the correct directory:

```powershell
Set-Location "C:\3Dvibe64\engine-demo-dev1"
```

Before running the builder, set the tool paths for the current session:

```powershell
$env:TASS64_EXE = "C:\Tools\64tass\64tass.exe"
$env:VICE_EXE = "C:\Tools\VICE\bin\x64sc.exe"
```

It is advisable to verify immediately that both executables exist:

```powershell
& $env:TASS64_EXE --version
& $env:VICE_EXE -version
```

A typical build command is:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\work\build-3Dvibe64.ps1 `
  -SceneFile .\examples\my-scene.json `
  -GraphicsMode 4 `
  -CameraMode fixed `
  -CameraViewport normal `
  -Quality balanced `
  -Projection table `
  -MemoryLayout stable `
  -Mode4NearProfile default `
  -FaceCullProfile stable `
  -NoFpsOverlay `
  -SkipCmdUpdate
```

The command is split across several lines with the PowerShell continuation character. The grave accent must be the final character on the line: spaces or text after it can break the command.

### Meaning of the Parameters in the Example

- `-File` identifies the builder script;
- `-SceneFile` identifies the scene JSON;
- `-GraphicsMode 4` selects dynamic solid rendering;
- `-CameraMode fixed` forces the camera profile;
- `-CameraViewport normal` selects the 160×100 viewport;
- `-Quality balanced` uses the balanced quality profile;
- `-Projection table` uses table-based projection;
- `-MemoryLayout stable` selects the compact layout;
- `-Mode4NearProfile default` applies the conservative near profile;
- `-FaceCullProfile stable` requests stable culling in supported modes;
- `-NoFpsOverlay` removes the overlay and its associated control;
- `-SkipCmdUpdate` avoids unnecessary updates provided for by the builder.

The PRG is normally produced at:

```text
work\3Dvibe64.prg
```

The generated Assembly is also normally found under `work`. Before considering the build successful, Codex must check:

- the builder’s exit code;
- warning messages;
- 64tass messages;
- existence of the PRG;
- PRG size;
- any intrusion into memory areas;
- any suggestion to switch to `high-basic-v2`.

To launch the result:

```powershell
& $env:VICE_EXE -autostart .\work\3Dvibe64.prg
```

Simply launching it does not complete the test. VICE must remain running long enough to produce several complete frames and reveal any problem.

### Options Can Change

The available options and valid combinations can change between releases. Codex must therefore verify the builder’s actual parameters before compiling.

In particular, it must check:

- the `ValidateSet` declarations in the script;
- precedence between JSON and command-line settings;
- options that are valid only in certain modes;
- incompatibilities between switches;
- diagnostic parameters that do not belong to the public API;
- the official examples closest to the scene being built.

A flag must not be added merely because its name sounds plausible. A nonexistent, reserved, or runtime-disconnected parameter must be removed or reported.

## 21. How to Start a New Demo with Codex

A good initial request must clearly define the scope of the work. The more information is established at the beginning, the less Codex has to interpret freely.

It is useful to specify:

- the baseline;
- the directory that must remain untouched;
- the new development copy;
- the external output directory;
- the graphics mode;
- the camera profile;
- the viewport;
- the near profile;
- the culling profile;
- the type of light;
- Ground;
- the objects;
- the animations;
- the required tests;
- the files that must not be modified.

Complete example:

```text
Work from the official release:

C:\3Dvibe64\official-engine

The release must remain untouched.

Create:

C:\3Dvibe64\engine-demo-dev1

Store JSON files, PRGs, screenshots, and logs in:

C:\3Dvibe64\demo-output

Create a demo with:

- GraphicsMode 4;
- fixed camera;
- normal viewport;
- black background;
- one mesh imported from an OBJ;
- rotation around all three axes;
- static light;
- FaceCullProfile stable;
- Mode4NearProfile clip.

Check the mesh winding, normals, and limits.
Generate the JSON and compile the PRG.

Test the result in x64sc for at least 8 frames.
Do not modify VERSION, README, the manifest, or the contract.

At the end, give me the exact path to the PRG.
```

This request contains both the desired result and the safety constraints.

- The baseline is identified and protected.
- The development copy has a precise path.
- Outputs are not scattered throughout the engine directory.
- The main rendering options have already been decided.
- The mesh must be checked before the build.
- The test has a minimum duration.
- Package identity and documentation files must not be modified.
- The final result must be easy to locate.

For a more complex demo, duration, object count, timeline, runtime keys, video standard, and memory requirements can be added. It is not necessary, however, to describe every creative detail in advance: work can begin from a minimal scene and proceed through isolated variants.

## 22. How to Request Changes

A vague request leaves Codex too much room for interpretation.

For example:

```text
Make it slower.
```

This does not specify which element should slow down. It might refer to translation, rotation, light, camera, timeline, or the entire simulation.

It is better to write:

```text
Create a new variant without overwriting the previous one.

Reduce translation speed by 25%.
Keep the following unchanged:

- rotation speed;
- camera;
- light;
- materials;
- geometry;
- timeline.

Recompile and give me the new PRG.
```

The precise request defines:

- what must change;
- by how much it must change;
- what must remain identical;
- that the previous version must not be overwritten;
- that a new PRG must be generated.

### Requests About Position

Instead of “move it a little lower,” use:

```text
Move the object 8 WU downward.
```

With `world-z-up`, “downward” means reducing the Z component. It is still useful to specify both the direction and the numeric value to avoid ambiguity.

### Requests About Timing

Instead of “make it enter later,” use:

```text
Delay the entry by 50 ST, equivalent to one second.
```

This wording links the technical value to the perceived duration.

### Requests About Rotation

Instead of “make it rotate more slowly,” use:

```text
Halve the angular velocity and keep the total number of
rotations unchanged.
```

The final condition implies that the phase duration must increase if the same number of revolutions is to be preserved. Without that specification, Codex might halve the speed while keeping the same duration and produce only half of the total rotation.

### Changing One Variable at a Time

During tuning, it is preferable to change only a few parameters in each variant. If camera, material, light, speed, and geometry all change in the same step, it becomes difficult to determine which change improved or worsened the result.

A good variant should record:

- the source file;
- previous values;
- new values;
- elements declared unchanged;
- the build command;
- the new hashes of the JSON and PRG.

## 23. How to Diagnose a Problem

When a face disappears, flickers, or is drawn in the wrong place, you should not immediately request a random patch. The first task must be to identify the responsible stage.

A structured prompt is:

```text
Do not apply a patch immediately.

First identify the responsible stage by comparing at least
32 consecutive frames.

Distinguish between:

- transformation;
- winding;
- clipping;
- near plane;
- projection;
- backface culling;
- screen clipping;
- depth bucket;
- painter order;
- rasterization;
- shading;
- timeline.

Determine the first exact point at which the result becomes
incorrect.

Apply a general correction only after demonstrating the cause.
Do not use hardcoded face indices or conditions specific to this
mesh.
```

The phrase “first exact point” is fundamental. An error visible in the raster may have been caused much earlier, for example by an incorrect camera-space coordinate or an improperly clipped polygon.

### Recommended Strategy

1. reproduce the defect deterministically;
2. freeze the camera, light, and rotation if necessary;
3. identify the first problematic face or frame;
4. follow the data through the pipeline;
5. compare a correct frame with the first incorrect frame;
6. isolate a general cause;
7. apply the change in the development copy;
8. rebuild from the JSON;
9. run regression tests on other scenes.

### Data to Trace for a Problematic Face

Codex can be asked to record:

- original coordinates;
- transformed coordinates;
- camera-space coordinates;
- geometric depth;
- result of classification relative to Ground;
- result of Ground clipping;
- result of near clipping;
- projected coordinates;
- clipping against the viewport;
- signed area;
- culling decision;
- depth bucket;
- position in the painter order;
- material;
- shading level;
- whether the raster stage was reached;
- the final polygon used by the outline in Mode 5.

A useful trace must identify the frame, object, instance, and local face index. With shared meshes, a face index without the instance identifier can be ambiguous.

### Corrections to Avoid

The following are not acceptable as general solutions:

- reversing only one face because it “seems to work” without verifying its winding;
- disabling culling for the entire scene to hide a local error;
- forcing an object’s depth with a hardcoded value;
- skipping a specific index in the renderer;
- introducing a condition tied to the mesh name;
- manually editing the generated ASM without carrying the change back into the builder.

These patches may correct one frame while breaking other poses or other scenes.

## 24. Testing in VICE

VICE is an integral part of the development process. A build that finishes without errors is not automatically a correct demo.

### Main Test with x64sc

Use `x64sc` for authoritative tests because it prioritizes accurate C64 emulation.

Verify:

- at least 8 `render_frame_end` events, or an equivalent number of observable complete frames;
- no return to BASIC;
- no unexpected persistent black screen;
- no bitmap corruption;
- no abnormal wrapping;
- no visible overflow;
- no spurious edges;
- correct clipping;
- correct painter order;
- regular timing;
- correct response from the keys included in the build.

Eight frames are only the minimum for a visual smoke test. For rotations and animations, check:

- at least 32 consecutive frames;
- transitions through nearly edge-on poses;
- phases close to the near plane;
- any crossing of Ground;
- a complete animation cycle, when possible.

A periodic defect may not appear in the first few frames. If the timeline lasts several seconds, the test must cover every state and at least one complete transition.

### Optional Smoke Test with xscpu64

When available and when a supplementary non-contractual check is useful, use `xscpu64` for an additional test with an accelerable CPU. The build, authoritative rendering check, and release contract remain based on `x64sc`.

Its purpose is not to certify the final rendering in place of `x64sc`, but to identify animations that are incorrectly tied to CPU speed. Events should retain the same logical duration on:

- a normal CPU;
- an accelerated CPU;
- PAL;
- NTSC.

Smoothness and the number of rendered frames may change. The narrative timing of the sequence should not: 150 ST must continue to represent approximately three seconds.

During the comparison, measure recognizable events, such as:

- an object entering the scene;
- the beginning and end of a rotation;
- a timeline state change;
- completion of a light orbit;
- a sequence reset.

### Screenshots and Logs

Ask Codex to save the following outside the engine directory:

- screenshots;
- VICE logs;
- frame counts;
- hashes;
- diagnostic traces;
- bucket dumps, when necessary;
- any PAL versus NTSC comparisons;
- any `x64sc` versus `xscpu64` comparisons.

The recommended directory is:

```text
C:\3Dvibe64\demo-output\
```

File names should include at least the scene, mode, camera, and purpose of the test. A name such as `screen1.png` quickly becomes meaningless; a name such as `cube-mode4-fixed-nearclip-frame032.png` preserves the context.

## 25. Runtime Controls

The main options may include:

```text
-ControlRotation
-ControlLight
-ControlReflectivity
-FpsOverlay
-FpsOverlayOnStart
-NoFpsOverlay
-NoCameraRuntimeControls
-StaticPose
```

### Camera Controls

When included in the build:

- `W` / `S`: forward and backward;
- `A` / `D`: lateral movement;
- `Q` / `E`: vertical movement;
- cursor keys: yaw and pitch;
- `N` / `M`: roll in `walkFull`.

`-NoCameraRuntimeControls` keeps the mobile profile but removes camera input handling. It is useful for an automatic scene that needs the mobile pipeline but not user navigation.

### Rotation

When `ControlRotation` is active, the assigned key can pause or resume rotation. The documented key is `R`.

`-StaticPose`, by contrast, prevents automatic updates to the mesh angles. It is not necessarily equivalent to an interactive pause: it is a compile-time choice.

### Light

`-ControlLight` enables light control where the scene and selected path support it. The documented key is `L`.

### Reflectivity

`-ControlReflectivity` normally assigns `R` to cycle through reflectivity levels. This conflicts with `-ControlRotation`.

If `ControlRotation` and `ControlReflectivity` are forced together, both handlers may read `R`: the rotation handler runs first, followed immediately by the reflectivity handler. There is therefore no single owner of the key. To use `R` exclusively for reflectivity, omit `-ControlRotation`.

Before enabling multiple controls at the same time, ask Codex to verify:

- conflicts;
- precedence;
- the actual behavior of the release;
- whether the handler is genuinely present in the generated code;
- guidance from the official examples.

### Generic Text and FPS Overlay

DEV7 uses a same-bank split with three text rows above the bitmap body. `-HeaderText "..."` embeds at most 40 compact-charset characters in both video banks. Supported characters are space, digits, dot, and `S C R I T A D E M P O`; unsupported input becomes a space. The FPS counter owns the first four cells of the middle row. The `$FF` terminator is significant because zero is the valid space glyph.

The complete header can be included and toggled with `F`.

- `-FpsOverlayOnStart` displays it from startup;
- `-FpsOverlay` retains the selector defined by the contract;
- `-FpsCounterOnly` keeps sampling without the visual header;
- `-NoFpsOverlay` removes the overlay and the FPS key.

Overlay switches must not be combined incompatibly. A dense build with Generic Text may need `high-basic-v2` because the complete 184-byte compact font is emitted.

### Temporal Scanline Mode

In GraphicsMode 4 and 5 only, the feature associated with `H` may be present. Pressing the key cycles through three row-update states:

```text
0 → 1 → 2 → 0
```

- state 0: all rows are updated;
- state 1: 50 rows of alternating parity are updated;
- state 2: 25 rows are updated according to a modulo-4 class.

Rows that are skipped temporarily retain their previous contents, producing an interlaced effect and a moderate trail.

This is not simply a low-resolution mode and does not guarantee higher performance. Transformation, projection, clipping, culling, sorting, shading, and face preparation continue to be performed; the effect may even increase frame cost. Materials, filling, painter order, and the Mode 5 outline remain unchanged.

## 26. Freezing an Approved Version

When a demo reaches a satisfactory result, its directory must no longer be treated as a simple experiment. It must become an approved, immutable baseline.

A recommended request is:

```text
This version is approved.

Leave it untouched and treat it as the new baseline for the demo.

Record:

- SHA-256 of the JSON;
- SHA-256 of the PRG;
- SHA-256 of the builder;
- build command;
- modes and profiles used.

Every subsequent change must be created in a new directory
without overwriting this version.
```

Freezing the version makes it possible to answer questions such as the following with certainty:

- which JSON produced this PRG?
- which builder was used?
- which options were active?
- was the approved version modified by mistake?
- can the PRG be rebuilt byte-identically?

In PowerShell, the hashes can be calculated as follows:

```powershell
Get-FileHash -Algorithm SHA256 "C:\Path\demo.json"
Get-FileHash -Algorithm SHA256 "C:\Path\demo.prg"
Get-FileHash -Algorithm SHA256 "C:\Path\build-3Dvibe64.ps1"
```

It is advisable to save the results in a small report, for example:

```text
baseline-demo.txt
```

The report should contain:

- date on which the version was frozen;
- scene name;
- directory path;
- JSON hash;
- PRG hash;
- builder hash;
- complete build command;
- graphics mode;
- camera;
- viewport;
- memory layout;
- near profile;
- culling profile;
- video standard;
- x64sc result;
- optional xscpu64 result, clearly identified as a supplementary non-contractual test;
- any visual notes.

If external includes, imported meshes, or precalculated tables are essential for rebuilding the demo, their hashes must also be recorded.

The new variant must be created by copying the baseline into a different directory, for example:

```text
C:\3Dvibe64\engine-demo-approved\
C:\3Dvibe64\engine-demo-dev-next\
```

The folder name alone must not be trusted. The hashes provide proof that the files have not changed.

## 27. When a Demo Is Canonical

A demo can be considered canonical when its result is reproducible, documented, and obtained through the engine’s normal path.

The main criteria are:

- it is rebuilt from the JSON;
- it uses the official builder, or a builder modification that is clearly documented in the development copy;
- it does not require manual patches after ASM generation;
- any external includes are clearly separated;
- the build command is documented;
- the PRG is reproducible;
- hashes are recorded;
- `x64sc` passes the tests;
- when the supplementary test is selected, any `xscpu64` result is recorded separately and is not treated as a canonical-status requirement;
- no required but undocumented temporary files remain;
- the engine release has remained untouched;
- all essential assets have been preserved.

The word “canonical” does not mean that the demo must use only a trivial scene or exclusively the features already shown in the examples. It means that every extension must be verifiable and that the result must not depend on forgotten manual steps.

### Permitted External Effects

An external graphical effect, such as a background or decorative routine, may be acceptable if it remains clearly separate from the 3D renderer.

It should not:

- modify culling;
- replace the renderer;
- rewrite internal materials;
- introduce separate 3D passes;
- operate on global face indices;
- alter the engine pipeline;
- use hardcoded data to correct a single mesh;
- make automatic rebuilding impossible.

For example, a routine that draws stars in the background can be considered decorative. A routine that manually redraws 3D faces skipped by the renderer is no longer merely an external effect: it is replacing or correcting the pipeline and must be treated as an engine modification.

### Practical Reproducibility

To verify that a demo is genuinely canonical, Codex should be able to:

1. start from the frozen directory;
2. delete the generated outputs;
3. rerun the documented command;
4. obtain the PRG again;
5. compare its hash;
6. repeat the test in VICE.

If the PRG cannot be regenerated without remembering a manual intervention, the procedure is not yet complete.

## 28. Common Mistakes

### Modifying the Official Release

The official release should only be read and copied. Working directly inside it makes it difficult to determine whether a problem belongs to the original engine or to a later modification.

Solution: always create a separate copy before changing JSON files, the builder, examples, or documentation.

### Modifying the Generated ASM Directly

The Assembly under `work` is regenerated by the builder. A manual change:

- will be lost at the next build;
- will not be represented in the JSON;
- will make the PRG difficult to rebuild;
- can conceal the builder’s actual limitation.

An ASM patch may be used only as a temporary diagnostic experiment. If it confirms the solution, the general change must be carried into the builder or into a declared include.

### Using Descriptions That Cannot Be Measured

Avoid requests such as:

```text
faster
a little lower
much farther away
```

These expressions depend on interpretation and do not allow two variants to be compared precisely.

Prefer:

```text
increase speed by 20%
lower it by 4 WU
move the starting position from 80 to 140 WU
delay it by 75 ST
```

A measurable request allows the JSON to be checked before and after the change.

### Confusing Color, Culling, and Projection

A disappearing face may be caused by:

- winding;
- backface culling;
- the near plane;
- clipping;
- projection;
- screen clipping;
- painter order;
- degeneration;
- material;
- object position;
- numeric overflow or wrapping.

It is not necessarily a shading problem.

Changing the color may make a face more visible, but it does not correct a culling decision. Disabling culling may make it appear, but that does not prove that culling is wrong: the mesh winding may be reversed.

### Expecting to See a Mesh from the Inside

Rendering is normally one-sided. Inside a closed object, many faces are correctly discarded because their front side points outward.

The `late` and `clip` near profiles do not make meshes two-sided. Clipping preserves the geometric portion in front of the camera, but it does not change face orientation.

### Using Too Many Polygons

A modern mesh may contain thousands or millions of polygons. The fact that it can be converted to JSON does not mean that it is suitable for the C64.

To improve speed:

- simplify the mesh;
- remove invisible faces;
- remove duplicates;
- share repeated geometry;
- use the `small` viewport;
- choose Mode 3 when dynamic shading is not needed;
- use a genuinely static light;
- reduce the number of simultaneous objects;
- reduce the duration of the heaviest phases;
- remove unnecessary runtime controls;
- choose Mode 4 instead of Mode 5 when the outline is not essential.

Simplification must be controlled. Randomly reducing polygons can alter the silhouette, winding, and normals.

### Ignoring Memory

If a memory window is exceeded:

1. try `high-basic-v2`;
2. reduce vertices and faces;
3. reduce instances;
4. simplify the timeline;
5. remove unnecessary controls;
6. use static light;
7. reduce the viewport.

The switch to `high-basic-v2` must be explicit. If the scene still does not fit, do not try to bypass the build check without understanding which areas overlap.

### Assuming That 255 Is Always a Reachable Limit

Several indices and counts may have a theoretical maximum of 255, but code, buffers, clipping, timelines, and instances consume memory before that value is reached. The effective limit depends on the entire configuration.

### Forgetting Precedence Between JSON and CLI

A value in the JSON can be replaced by an explicit command-line parameter. For example, the effective camera or viewport may not match the values found by reading the JSON superficially.

Codex must record the complete command, not only the scene.

### Confusing a Genuinely Static Light with a Frozen Phase

`"type": "static"` selects the genuinely static path. An older `"mode": "static"` field or a frozen orbital phase may retain unnecessary infrastructure.

### Using `visibility` Instead of `visible`

The timeline requires `visible`. `visibility` may be ignored. A builder warning must not be disregarded.

### Enabling Conflicting Controls

`ControlRotation` and `ControlReflectivity` may share `R`. Before adding both, you must decide which function should own the key.

### Treating `H` as a Performance Mode

Temporal Scanline Mode retains most of the pipeline and can increase the cost. It should be used as an experimental visual effect, not as an automatic substitute for optimization.

### Tying Time to the CPU

A sequence that has the correct duration on `x64sc` but speeds up on `xscpu64` is probably using a counter tied to iterations or frames rather than ST. Narrative timing must remain normalized.

## 29. Recommended Complete Workflow

### Phase 1: Preparation

1. give Codex the GitHub link or the path to the ZIP;
2. download or locate the release ZIP;
3. extract it into an official directory;
4. install or configure the tools;
5. check versions and paths;
6. compile an official example;
7. verify the result in VICE;
8. record the working configuration.

The preparation phase must end with a real build. The fact that the executables respond to `--version` does not yet prove that the builder, assembler, and paths work together.

### Phase 2: New Demo

1. create a copy of the engine;
2. choose the official example closest to the desired result;
3. create a new JSON without modifying the original example;
4. import and verify the meshes;
5. select mode, camera, viewport, memory, near profile, and culling;
6. compile the first PRG;
7. run the test in `x64sc`;
8. save the screenshots, log, and command.

Starting from the closest example reduces schema errors. A Mode 5 demo with shared meshes should start from a Mode 5 example with sharing, not from a minimal wire scene.

### Phase 3: Iterative Development

1. change only a few parameters at a time;
2. use numeric values;
3. create a new variant for every significant change;
4. do not overwrite approved versions;
5. preserve screenshots and PRGs;
6. compare precisely defined variants;
7. note what must remain unchanged;
8. update the hashes of important variants.

A good iteration must be able to answer the question: “Which single change produced this difference?”

### Phase 4: Diagnosis

1. reproduce the problem deterministically;
2. freeze the camera, light, and rotation if necessary;
3. identify the pipeline stage;
4. compare at least 32 frames when the problem is temporal;
5. trace the first incorrect face;
6. correct the general cause;
7. rebuild without manual patches;
8. test regression scenes unrelated to the original case.

Diagnosis must precede modification. A patch that “seems to work” is not sufficient when it is not clear why it works.

### Phase 5: Completion

1. rebuild everything from the JSON;
2. verify the hashes;
3. test with `x64sc`;
4. when useful and available, perform an optional `xscpu64` smoke test without replacing the `x64sc` verification;
5. verify PAL and NTSC when relevant;
6. remove unnecessary temporary files;
7. preserve the command, JSON, assets, and PRG;
8. freeze the final directory;
9. create a new copy for every subsequent development step.

Completion does not consist merely of copying the PRG. The true archival unit of the demo includes at least the JSON, the builder identified by its hash, the command, the assets, the PRG, and the test report.

## 30. Complete Prompt for Starting from Scratch

The following prompt covers the entire preparation workflow. It can be adapted to the actual paths on the computer.

```text
I want to create demos and PRGs with 3Dvibe64 without manually
modifying Assembly code.

Official repository:

[paste the address copied from GitHub’s Code button here]

Prepare the development environment.

1. Find and download the ZIP of the latest stable release.
2. Extract it to:

C:\3Dvibe64\official-engine

3. Do not modify this directory.
4. Check for the presence of:
   - PowerShell;
   - Python 3;
   - Git;
   - 64tass;
   - VICE x64sc;
   - VICE xscpu64, optional and non-contractual.

5. If anything is missing, use official sources exclusively.
6. Ask for my permission whenever it is required for downloads,
   installations, administrative privileges, or launching programs.
7. Prefer portable versions of 64tass and VICE whenever possible.
8. Configure the tool paths.
9. Run the contract tests included in the release.
10. Create a working copy at:

C:\3Dvibe64\engine-demo-dev1

11. Compile an official example without modifying the release.
12. Run the PRG in x64sc for at least 8 frames.
13. If xscpu64 is available, run a brief optional smoke test and report it separately from the authoritative x64sc test.

At the end, tell me:

- which release was downloaded;
- path to the official release;
- path to the working copy;
- Python version;
- Git version;
- 64tass version;
- VICE version;
- build command;
- path to the PRG;
- SHA-256 of the PRG;
- test results.
```

### How to Adapt the Prompt

If the ZIP has already been downloaded, replace the download step with the local path. If Git is not to be installed, Codex can be asked to report its absence and proceed with copies and hashes.

If VICE cannot be launched automatically from the environment, Codex must still:

- produce the PRG;
- provide the exact launch command;
- prepare the output directory;
- explain which manual verification still needs to be performed.

If the release includes Python tests or build contracts, they must be run before modifying the builder. This provides a technical baseline against which later changes can be compared.

## Conclusion

The simplest and safest way to use 3Dvibe64 is to keep creation, compilation, verification, and version preservation clearly separated.

The recommended workflow is:

- download the official ZIP from GitHub;
- preserve an untouched copy;
- give Codex the path to the release;
- allow Codex to check and, after obtaining permission, install the required tools;
- create a separate working copy;
- describe the scene in natural language;
- turn every visual request into numbers and verifiable conditions;
- use the JSON as the authoritative source;
- let the builder and 64tass produce the PRG;
- verify the result in VICE;
- compare PAL, NTSC, and an accelerated CPU when timing matters;
- freeze every approved version with hashes and the build command.

You do not need to know Assembly to create a demo with this method. What matters most is working in an orderly way: an untouched baseline, isolated copies, precise requests, repeatable tests, and a PRG that can always be rebuilt from the JSON.

Assembly naturally remains at the heart of execution on the Commodore 64, but it should not become the point at which the user is forced to intervene manually. The builder must turn the scene description into code, while Codex must make technical decisions transparent, record the steps, and prevent a working version from being lost.

A well-organized demo is not merely a PRG that starts. It is a project whose JSON source, assets, builder, command, hashes, tests, and exact rebuilding procedure are all known.
