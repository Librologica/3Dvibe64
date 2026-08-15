param(
 [ValidateSet("torus6x6", "torus8x6", "torus10x6", "torus12x6", "cube", "dual", "dual_low")]
 [string]$Mesh = "torus8x6",

 [ValidateSet("turbo", "fast", "balanced", "high")]
 [string]$Quality = "balanced",

 [string]$MeshFile = "",

 [string]$SceneFile = "",

 [string]$HeaderText = "",

 [ValidateSet("auto", "pal", "ntsc")]
 [string]$VideoStandard = "auto",

 [int]$AutoCycleFrames = 0,

 [ValidateRange(0, 5)]
 [int]$RandomMaterialCycleSeconds = 0,

 [switch]$ExperimentalLazyBounds,

 [switch]$ExperimentalDirectConvexFill,

 [switch]$NoDirectConvexFill,

 [switch]$NoNativeConvexQuadFill,

 [switch]$NoFastBoundsTrace,

 [switch]$NoMode4FastBoundsTrace,

 [switch]$NoSpanHotloop,

 [switch]$NoEngineMode3StableGroundCellLayout,

 [switch]$NoEngineMode3AdaptiveCellPolicy,

 [switch]$EngineMode3ConsolidationCheck,

 [switch]$ExperimentalSpanKernelFill,

 [switch]$NoSpanKernelFill,

 [switch]$NoWorldGroundSpanEdge,

 [switch]$ExperimentalIndexedSpanFill,

 [switch]$ExperimentalConvexFanFill,

 [switch]$ExperimentalExplorerMatrixFold,

 [switch]$NoExplorerMatrixFold,

 [int]$MinFaceAreaOverride = -1,

 [int]$ScreenMinSpanOverride = -1,

 [int]$PatternMinSpanOverride = -1,

 [ValidateSet("auto", "cull", "conservative", "force")]
 [string]$FaceRenderMode = "auto",

 [ValidateSet("default", "stable")]
 [string]$FaceCullProfile = "default",

 [ValidateSet("1", "2", "3", "4", "5")]
 [string]$GraphicsMode = "4",

 [ValidateSet("default", "late", "clip")]
 [string]$Mode4NearProfile = "default",

 [switch]$DiagnosticHalfCameraRates,

 [switch]$SolidSubpixelXQ2,

 [ValidateSet("LegacyUpscaled", "LegacyDirect", "Native")]
 [string]$SolidSubpixelXInput = "LegacyUpscaled",

 [switch]$SolidSubpixelYQ2,

 [ValidateSet("LegacyDirect", "LegacyBuffered", "LegacyPhase1", "Native", "NativeQuantized", "MobileNative")]
 [string]$SolidSubpixelYInput = "LegacyDirect",

 # One-build Mode 4 pattern-path probe.  It replaces only shadeidx at the
 # final face-pattern dispatch, so the existing wrappers and fillers remain
 # the thing being exercised.
 [switch]$Mode4PatternProbe,

 # Latched-face replacement for the original probe.  It selects the exact
 # shadeidx consumed by the bounds pattern fillers after XY-Q2 bounds exist.
 [switch]$Mode4PatternProbeLatchedFace,

 # Diagnostic proof of the complete, valid RC4 shade-code path.  Unlike the
 # old shadeidx probe this supplies full shade codes at the face dispatcher.
 [switch]$Mode4ValidShadeFaceProbe,

 # Experimental Mode 4 temporal limiter.  It is deliberately opt-in and
 # available only to the fixed/small Native-Y XY-Q2 configuration below.
 [switch]$Mode4ShadeStepLimit,

 [switch]$YQ2FastDiv11x8,

 [switch]$YQ2FastPixelConvert,

 [switch]$YQ2InlineBounds,

 [ValidateSet("off", "diagnostic", "active", "overlay", "active-overlay")]
 [string]$VicColorPolicy = "off",

 [ValidateSet("first", "last", "wire", "compat")]
 [string]$VicColorFallback = "first",

 [switch]$NoStaticShade,

 [switch]$RuntimeGraphicsModeSwitch,

 [ValidateSet("dirty", "full")]
 [string]$ClearMode = "dirty",

 [ValidateSet("stable", "high-basic-v2")]
 [string]$MemoryLayout = "stable",

 [ValidateSet("table", "reference", "extended-table")]
 [string]$Projection = "table",

 [int]$MotionZStart256 = 0,

 [int]$MotionZStep256 = 0,

 [switch]$MotionZStartOnReturn,

 [switch]$MotionZStartOnZero,

 [int]$CameraIndex = 0,

 [string]$CameraFile = "",

 [switch]$ExplorerResetOnSpace,


 [ValidateSet("none", "near")]
 [string]$ExplorerClipMode = "near",

 [ValidateSet("skip", "clamp", "poly", "fill")]
 [string]$ExplorerNearCrossMode = "skip",

 [ValidateRange(8, 64)]
 [int]$ExplorerNearSkipDepth = 32,

 [ValidateSet("normal", "hide-object", "near-object")]
 [string]$ExplorerTraversalCullMode = "normal",

 [ValidateRange(0, 64)]
 [int]$ExplorerTraversalHysteresis = 16,

 [ValidateSet("none", "x", "poly")]
 [string]$ExplorerScreenClipMode = "poly",

 [ValidateSet("", "fixed", "walkLite", "walkFull")]
 [string]$CameraMode = "",

 [ValidateSet("normal", "small")]
 [string]$CameraViewport = "normal",

 [switch]$EngineMode3DemoCellColorStability,

 [switch]$NoCameraRuntimeControls,

 [switch]$DynamicLight,

 [ValidateSet("gray", "white", "red", "green", "blue", "yellow", "cyan", "magenta", "orange", "brown")]
 [string]$MaterialFamily = "gray",

 [ValidateRange(0, 3)]
 [int]$Reflectivity = 0,

 [ValidateSet(8, 16, 32)]
 [int]$LightPhaseCount = 32,

 [int]$LightTickDiv = 2,

 [ValidateSet("flat", "tumble3d")]
 [string]$LightOrbit = "flat",

 [ValidateRange(0, 10)]
 [int]$LightIntensity = 10,

 [switch]$LightPulse,

 [switch]$LightPulseOnSpace,

 [int]$LightStaticPhase = -1,

 [switch]$StaticPose,

 [ValidateRange(0, 255)]
 [int]$InitialAngleX = 24,

 [ValidateRange(0, 255)]
 [int]$InitialAngleY = 25,

 [ValidateRange(0, 255)]
 [int]$InitialAngleZ = 47,

 [switch]$ControlSpace,

 [switch]$ControlReturn,

 [switch]$ControlRotation,


 [switch]$ControlLight,

 [switch]$ControlMaterial,

 [switch]$ControlReflectivity,

 [switch]$FpsOverlayOnStart,

 [switch]$FpsOverlay,

 [switch]$FpsCounterOnly,

 [switch]$NoFpsOverlay,

 [switch]$SkipCmdUpdate
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Public API note: a feature is promoted only when it is visible at all three
# levels: parameter/build-script surface, generated ASM, and linked runtime
# routines/buffers. Reserved fields are rejected instead of being silently
# accepted when no runtime path consumes them.

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$AsmPath = Join-Path $Root "3Dvibe64.asm"
$PrgPath = Join-Path $Root "3Dvibe64.prg"
$BuildPrgPath = Join-Path $Root "build\3Dvibe64.prg"
function Resolve-64tass {
 $candidates = New-Object System.Collections.Generic.List[string]

 if ($env:TASS64_EXE) {
 $candidates.Add($env:TASS64_EXE)
 }
 if ($env:TASS64_PATH) {
 if (Test-Path -LiteralPath $env:TASS64_PATH -PathType Leaf) {
 $candidates.Add($env:TASS64_PATH)
 } else {
 $candidates.Add((Join-Path $env:TASS64_PATH "64tass.exe"))
 }
 }

 $candidates.Add((Join-Path $Root "tools\64tass\64tass.exe"))
 $candidates.Add((Join-Path $Root "tools\64tass\64tass-1.60.3243\64tass.exe"))

 foreach ($candidate in $candidates) {
 if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
 return (Resolve-Path -LiteralPath $candidate).Path
 }
 }

 $cmd = Get-Command "64tass.exe" -ErrorAction SilentlyContinue
 if (-not $cmd) { $cmd = Get-Command "64tass" -ErrorAction SilentlyContinue }
 if ($cmd) { return $cmd.Source }

 throw @"
64tass was not found.
Install 64tass separately, then either:
- set TASS64_EXE to the full executable path;
- set TASS64_PATH to the directory that contains 64tass.exe;
- add 64tass.exe to PATH;
- or place it in work\tools\64tass\ locally.
"@
}

$Tass = Resolve-64tass

New-Item -ItemType Directory -Force -Path (Join-Path $Root "build") | Out-Null

$RendererActiveFlag = 1

# A scene may select the viewport when the caller does not. The command-line
# parameter remains authoritative and `normal` is the engine default.
if (-not $PSBoundParameters.ContainsKey("CameraViewport") -and $SceneFile.Trim().Length -gt 0) {
 $viewportScenePath = if ([IO.Path]::IsPathRooted($SceneFile)) { $SceneFile } else {
  $viewportCallerPath = Join-Path (Get-Location).Path $SceneFile
  if (Test-Path -LiteralPath $viewportCallerPath -PathType Leaf) { $viewportCallerPath } else { Join-Path (Split-Path -Parent $Root) $SceneFile }
 }
 if (Test-Path -LiteralPath $viewportScenePath -PathType Leaf) {
  $viewportSceneDoc = Get-Content -LiteralPath $viewportScenePath -Raw | ConvertFrom-Json
  if ($null -ne $viewportSceneDoc.contract -and ($viewportSceneDoc.contract.PSObject.Properties.Name -contains "viewportProfile")) {
   $viewportSceneProfile = ([string]$viewportSceneDoc.contract.viewportProfile).Trim().ToLowerInvariant()
   if ($viewportSceneProfile -ne "normal" -and $viewportSceneProfile -ne "small") {
    throw "Scene contract viewportProfile must be normal or small"
   }
   $CameraViewport = $viewportSceneProfile
  }
 }
}

# GraphicsModes 4 and 5 share the public XY-Q2 profile. Keep explicit values
# available for diagnostics, but ordinary builds select the validated Y-Q2 gates.
$Mode4FamilyDefaultsRequested = (@("4", "5") -contains $GraphicsMode.Trim().ToLowerInvariant())
if ($Mode4FamilyDefaultsRequested -and -not $PSBoundParameters.ContainsKey("ExplorerClipMode")) {
 $ExplorerClipMode = "none"
}
$Mode4NearProfileKey = $Mode4NearProfile.Trim().ToLowerInvariant()
$Mode4LateNearRequested = ($Mode4NearProfileKey -eq "late")
$Mode4CameraPlaneClipRequested = ($Mode4NearProfileKey -eq "clip")
# The existing Mode4NearProfile switch is shared by the solid GraphicsModes
# 3, 4 and 5; all three consume the same projection and reject constants.
if (($Mode4LateNearRequested -or $Mode4CameraPlaneClipRequested) -and
    -not (@("3", "4", "5") -contains $GraphicsMode.Trim())) {
 throw "Mode4NearProfile=late|clip is available only for GraphicsModes 3, 4 and 5"
}
if (($Mode4LateNearRequested -or $Mode4CameraPlaneClipRequested) -and
    $PSBoundParameters.ContainsKey("ExplorerClipMode") -and
    $ExplorerClipMode -ne "none") {
 throw "Mode4NearProfile=late|clip requires ExplorerClipMode=none"
}
if (($Mode4LateNearRequested -or $Mode4CameraPlaneClipRequested) -and
    $PSBoundParameters.ContainsKey("ExplorerNearCrossMode") -and
    $ExplorerNearCrossMode -ne "skip") {
 throw "Mode4NearProfile=late|clip does not support legacy near crossing modes"
}
if ($Mode4LateNearRequested -or $Mode4CameraPlaneClipRequested) {
 $ExplorerClipMode = "none"
}
$Mode4ClipMinDepth = if ($Mode4LateNearRequested -or $Mode4CameraPlaneClipRequested) { 1 } else { 8 }
$Mode4ProjectionMinDivisor = if ($Mode4LateNearRequested -or $Mode4CameraPlaneClipRequested) { 2 } else { 8 }
$Mode3LateNearNoPolyFlag = if ($Mode4LateNearRequested -and $GraphicsMode.Trim() -eq "3") { 1 } else { 0 }
$CameraPlaneClipProfileFlag = if ($Mode4CameraPlaneClipRequested) { 1 } else { 0 }
$FaceCullProfileKey = $FaceCullProfile.Trim().ToLowerInvariant()
$StableFaceCullRequested = ($FaceCullProfileKey -eq "stable")
if ($StableFaceCullRequested -and -not (@("4", "5") -contains $GraphicsMode.Trim())) {
 throw "FaceCullProfile=stable is available only for GraphicsModes 4 and 5"
}
if ($StableFaceCullRequested -and $FaceRenderMode -eq "force") {
 throw "FaceCullProfile=stable is incompatible with FaceRenderMode=force"
}
$StableFaceCullProfileFlag = if ($StableFaceCullRequested) { 1 } else { 0 }
$CameraSpaceFaceCullSupportFlag = if ($CameraPlaneClipProfileFlag -ne 0 -or $StableFaceCullProfileFlag -ne 0) { 1 } else { 0 }

# The physical VIC-II bitmap remains 160x100 lowres. When the DEV7 split-screen
# layer is compiled, the normal camera body starts below its three text rows.
# The small profile keeps its 128x80 geometry and is shifted down just enough
# to keep every rendered row out of the text header.
$TextHeaderCellRows = 3
$TextHeaderScreenBytes = $TextHeaderCellRows * 40
$TextHeaderLogicalHeight = $TextHeaderCellRows * 4
$TextSplitEnableFlag = if ($NoFpsOverlay.IsPresent -or $FpsCounterOnly.IsPresent) { 0 } else { 1 }
$CameraViewportKey = $CameraViewport.Trim().ToLowerInvariant()
$EngineCameraViewportConfigurableFlag = 1
$EngineCameraViewportSmallFlag = if ($CameraViewportKey -eq "small") { 1 } else { 0 }
$EngineCameraViewportAllModesFlag = $EngineCameraViewportConfigurableFlag
$EngineCameraViewportProjectionScaledFlag = $EngineCameraViewportSmallFlag
$EngineCameraViewportClearLimitedFlag = if ($EngineCameraViewportSmallFlag -ne 0 -or $TextSplitEnableFlag -ne 0) { 1 } else { 0 }
$EngineCameraViewportGroundLimitedFlag = $EngineCameraViewportSmallFlag
$CameraViewportPhysicalWidth = 160
$CameraViewportPhysicalHeight = 100
$CameraViewportWidth = if ($EngineCameraViewportSmallFlag -ne 0) { 128 } else { 160 }
$CameraViewportHeight = if ($EngineCameraViewportSmallFlag -ne 0) { 80 } elseif ($TextSplitEnableFlag -ne 0) { 88 } else { 100 }
$CameraViewportOriginX = [int](($CameraViewportPhysicalWidth - $CameraViewportWidth) / 2)
$CameraViewportOriginY = if ($EngineCameraViewportSmallFlag -ne 0) {
 [Math]::Max($TextHeaderLogicalHeight * $TextSplitEnableFlag, [int](($CameraViewportPhysicalHeight - $CameraViewportHeight) / 2))
} elseif ($TextSplitEnableFlag -ne 0) {
 $TextHeaderLogicalHeight
} else {
 0
}
$CameraViewportCenterX = [int]($CameraViewportWidth / 2)
$CameraViewportCenterY = [int]($CameraViewportHeight / 2)
$CameraViewportFocal = if ($EngineCameraViewportSmallFlag -ne 0) { 136 } else { 170 }
$CameraViewportFrustumXNear = if ($EngineCameraViewportSmallFlag -ne 0) { 32 } else { 40 }
$CameraViewportFrustumYNear = if ($EngineCameraViewportSmallFlag -ne 0) { 20 } elseif ($TextSplitEnableFlag -ne 0) { 22 } else { 25 }
$CameraViewportFrustumFocal = [int]($CameraViewportFocal / 2)
$ExplorerMoveStep = if ($DiagnosticHalfCameraRates.IsPresent) { 64 } else { 127 }
$ExplorerYawPitchTickDiv = if ($DiagnosticHalfCameraRates.IsPresent) { 8 } else { 4 }
$ExplorerRollTickDiv = if ($DiagnosticHalfCameraRates.IsPresent) { 4 } else { 2 }
$CameraViewportCellOriginX = [int]($CameraViewportOriginX / 4)
$CameraViewportCellWidth = [int]($CameraViewportWidth / 4)
$CameraViewportBitmapXOffset = $CameraViewportCellOriginX * 8
$WireGroundRollXBias = (-($CameraViewportCenterX - 2)) -band 255
$WireGroundRollYBias = (-$CameraViewportCenterY) -band 255
$WireGroundRollFocalHalf = [int]($CameraViewportFocal / 2)
$YQ2ViewportCenter = $CameraViewportCenterY * 4
$YQ2ViewportMax = ($CameraViewportHeight - 1) * 4
$YQ2ViewportRowMax = $CameraViewportHeight - 1
$YQ2ViewportRowCount = $CameraViewportHeight
$YQ2ViewportCenterPlusOne = $YQ2ViewportCenter + 1
$YQ2ViewportBelowCenterLimitPlusOne = ($YQ2ViewportMax - $YQ2ViewportCenter) + 1

function Resolve-RendererPlan {
 param(
 [int]$GraphicsModeNumber,
 [string]$Quality,
 [string]$ClearMode,
 [int]$WorldGroundEnableFlag,
 [int]$WorldGroundHorizonOnlyFlag,
 [int]$VicColorPolicyEnableFlag,
 [int]$CameraMovableFlag,
 [int]$CameraWalkLiteFlag,
 [int]$CameraRollActiveFlag,
 [int]$ExplorerNearClipFlag,
 [int]$ExplorerScreenClipPolyFlag,
 [int]$ExplorerScreenClipXFlag,
 [int]$PolyFillFlag,
 [int]$HiddenWireFlag,
 [int]$StaticShadeCacheFlag,
 [int]$FullDynamicShadeFlag
 )

 $dynamicShadeLevel = if ($FullDynamicShadeFlag -ne 0) { 2 } else { 0 }
 $targetShadeProfile = switch ($GraphicsModeNumber) {
 1 { "wire-pure" }
 2 { "hidden-wire-face-edges" }
 3 { "static-flat-cache" }
 4 { "dynamic-small-scene" }
 5 { "dynamic-small-scene-polygon-outline" }
 default { "unknown" }
 }
 $targetFillProfile = if ($GraphicsModeNumber -le 2) { "wire-only" } elseif ($GraphicsModeNumber -eq 3) { "flat-static-spans" } else { "small-scene-spans" }
 $cameraProfile = if ($CameraMovableFlag -eq 0) { "fixed" } elseif ($CameraWalkLiteFlag -ne 0) { "walk-lite" } else { "walk-full" }

 return [pscustomobject]([ordered]@{
 Name = "3Dvibe64"
 PlannerActive = 1
 PlanApplied = 1
 GroundRenderMode = if ($WorldGroundEnableFlag -eq 0) { 0 } elseif ($GraphicsModeNumber -le 2) { 3 } else { 1 }
 GroundRenderModeName = if ($WorldGroundEnableFlag -eq 0) { "none" } elseif ($GraphicsModeNumber -le 2) { "horizon-only" } else { "simple-prefill" }
 GroundSimplePrefill = if ($WorldGroundEnableFlag -ne 0 -and $GraphicsModeNumber -ge 3) { 1 } else { 0 }
 GroundFullPlane = 0
 GroundOcclusion = 0
 GroundWireOcclusion = if ($WorldGroundEnableFlag -ne 0 -and $GraphicsModeNumber -eq 2) { 1 } else { 0 }
 GroundRollPlane = 0
 FrameWorldPrefill = if ($WorldGroundEnableFlag -ne 0 -and $GraphicsModeNumber -ge 3) { 1 } else { 0 }
 VicColorPolicyRuntime = 0
 EngineVicStaticPolicy = 1
 CameraProfile = $cameraProfile
 CameraLimits = if ($CameraMovableFlag -ne 0) { 1 } else { 0 }
 CameraFull = if ($CameraMovableFlag -ne 0 -and $CameraWalkLiteFlag -eq 0) { 1 } else { 0 }
 NearClipProfile = if ($GraphicsModeNumber -le 2 -and $ExplorerNearClipFlag -ne 0) { "near-relaxed-through-mesh" } elseif ($ExplorerNearClipFlag -ne 0) { "near" } else { "none" }
 ScreenClipProfile = if ($ExplorerScreenClipPolyFlag -ne 0) { "poly" } elseif ($ExplorerScreenClipXFlag -ne 0) { "x" } else { "none" }
 FaceCullingProfile = if ($GraphicsModeNumber -le 2) { "wire-relaxed" } else { "conservative" }
 DepthSortProfile = if ($GraphicsModeNumber -ge 3) { "depth-buckets-essential" } else { "none" }
 ShadeProfile = $targetShadeProfile
 FillProfile = $targetFillProfile
 MaterialProfile = "static-single-material-preferred"
 ClearProfile = if ($WorldGroundEnableFlag -ne 0 -and $GraphicsModeNumber -le 2) { "full-clear-horizon-line" } elseif ($WorldGroundEnableFlag -ne 0) { "prefill-sky-ground" } else { $ClearMode }
 ModeBudgetProfile = "engine-$Quality"
 ModeBudget = 1
 FullRender = 0
 DepthBuckets = if ($GraphicsModeNumber -ge 3) { 1 } else { 0 }
 WireDepthSort = 0
 FaceFillCache = if ($GraphicsModeNumber -ge 4) { 1 } else { 0 }
 DynamicShadeLevel = $dynamicShadeLevel
 RuntimeGroundRenderMode = if ($WorldGroundEnableFlag -eq 0) { 0 } elseif ($GraphicsModeNumber -le 2) { 3 } else { 1 }
 RuntimeGroundOcclusion = 0
 RuntimeVicColorPolicy = $VicColorPolicyEnableFlag
 RuntimeCameraWalkLite = $CameraWalkLiteFlag
 RuntimeRollActive = $CameraRollActiveFlag
 })
}

function ByteHex([int]$v) {
 return '$' + (($v -band 255).ToString('X2'))
}

function WordHex([int]$v) {
 return '$' + (($v -band 0xffff).ToString('X4'))
}

function Convert-MulticolorByteSlots([int]$Value, [int[]]$SlotMap) {
 if ($SlotMap.Count -ne 4) {
 throw "Multicolor slot map must contain exactly four entries"
 }
 $result = 0
 foreach ($shift in @(6, 4, 2, 0)) {
 $sourceSlot = (($Value -shr $shift) -band 0x03)
 $targetSlot = [int]$SlotMap[$sourceSlot]
 if ($targetSlot -lt 0 -or $targetSlot -gt 3) {
 throw "Multicolor slot map entries must be in range 0..3"
 }
 $result = $result -bor ($targetSlot -shl $shift)
 }
 return ($result -band 255)
}

function Add-Bytes([string]$name, [int[]]$values) {
 $s = "${name}:
"
 for ($i = 0; $i -lt $values.Count; $i += 16) {
 $end = [Math]::Min($i + 15, $values.Count - 1)
 $chunk = $values[$i..$end]
 $s += " .byte " + (($chunk | ForEach-Object { ByteHex $_ }) -join ",") + "
"
 }
 return $s
}

function Add-ExpressionBytes([string]$name, [string[]]$values) {
 $s = "${name}:
"
 for ($i = 0; $i -lt $values.Count; $i += 8) {
 $end = [Math]::Min($i + 7, $values.Count - 1)
 $chunk = $values[$i..$end]
 $s += " .byte " + ($chunk -join ",") + "
"
 }
 return $s
}

function Get-SignedByte([int]$v) {
 $b = $v -band 255
 if ($b -ge 128) { return $b - 256 }
 return $b
}

function Get-S6Sin([int]$phase) {
 $v = [Math]::Round([Math]::Sin($phase * 2.0 * [Math]::PI / 256.0) * 64.0)
 if ($v -gt 64) { $v = 64 }
 if ($v -lt -64) { $v = -64 }
 return [int]$v
}

function Get-IntensityThreshold([int]$base, [int]$intensity) {
 if ($intensity -le 0) { return 255 }
 $threshold = [int][Math]::Ceiling(($base * 10.0) / [double]$intensity)
 if ($threshold -gt 255) { return 255 }
 return $threshold
}

function Get-IntensityThresholdTable([int]$base) {
 $values = @()
 for ($intensity = 0; $intensity -le 10; $intensity++) {
 $values += Get-IntensityThreshold $base $intensity
 }
 return $values
}

function Mul-S6Int([int]$a, [int]$b) {
 $sign = 1
 if ($a -lt 0) { $a = -$a; $sign = -$sign }
 if ($b -lt 0) { $b = -$b; $sign = -$sign }
 $v = [Math]::Floor(($a * $b) / 64.0)
 return [int]($sign * $v)
}

function Get-CameraMatrix([int]$pitch, [int]$yaw, [int]$roll) {
 $sinx = Get-S6Sin (-$pitch)
 $cosx = Get-S6Sin ((-$pitch) + 64)
 $siny = Get-S6Sin (-$yaw)
 $cosy = Get-S6Sin ((-$yaw) + 64)
 $sinz = Get-S6Sin (-$roll)
 $cosz = Get-S6Sin ((-$roll) + 64)

 $t1 = Mul-S6Int $sinx $siny
 $t2 = Mul-S6Int $cosx $siny

 $m00 = Mul-S6Int $cosy $cosz
 $m10 = Mul-S6Int $cosy $sinz
 $m20 = -$siny
 $m21 = Mul-S6Int $sinx $cosy
 $m22 = Mul-S6Int $cosx $cosy
 $m01 = (Mul-S6Int $t1 $cosz) - (Mul-S6Int $cosx $sinz)
 $m02 = (Mul-S6Int $t2 $cosz) + (Mul-S6Int $sinx $sinz)
 $m11 = (Mul-S6Int $t1 $sinz) + (Mul-S6Int $cosx $cosz)
 $m12 = (Mul-S6Int $t2 $sinz) - (Mul-S6Int $sinx $cosz)

 return [int[]]@($m00,$m01,$m02,$m10,$m11,$m12,$m20,$m21,$m22)
}

function Get-RotationMatrixDouble([int]$pitch, [int]$yaw, [int]$roll) {
 $sx = [Math]::Sin($pitch * 2.0 * [Math]::PI / 256.0)
 $cx = [Math]::Cos($pitch * 2.0 * [Math]::PI / 256.0)
 $sy = [Math]::Sin($yaw * 2.0 * [Math]::PI / 256.0)
 $cy = [Math]::Cos($yaw * 2.0 * [Math]::PI / 256.0)
 $sz = [Math]::Sin($roll * 2.0 * [Math]::PI / 256.0)
 $cz = [Math]::Cos($roll * 2.0 * [Math]::PI / 256.0)

 $t1 = $sx * $sy
 $t2 = $cx * $sy
 $row0 = [double[]]@(($cy * $cz), (($t1 * $cz) - ($cx * $sz)), (($t2 * $cz) + ($sx * $sz)))
 $row1 = [double[]]@(($cy * $sz), (($t1 * $sz) + ($cx * $cz)), (($t2 * $sz) - ($sx * $cz)))
 $row2 = [double[]]@(-$sy, ($sx * $cy), ($cx * $cy))
 return ,[object[]]@($row0, $row1, $row2)
}

function Transform-VectorDouble($m, [double[]]$v) {
 $x = ($m[0][0] * $v[0]) + ($m[0][1] * $v[1]) + ($m[0][2] * $v[2])
 $y = ($m[1][0] * $v[0]) + ($m[1][1] * $v[1]) + ($m[1][2] * $v[2])
 $z = ($m[2][0] * $v[0]) + ($m[2][1] * $v[1]) + ($m[2][2] * $v[2])
 return [double[]]@($x, $y, $z)
}

function Normalize-Vector([double[]]$v) {
 $len = [Math]::Sqrt(($v[0] * $v[0]) + ($v[1] * $v[1]) + ($v[2] * $v[2]))
 if ($len -lt 0.0001) {
 return [double[]]@(0.0, 0.0, 1.0)
 }
 $x = $v[0] / $len
 $y = $v[1] / $len
 $z = $v[2] / $len
 return [double[]]@($x, $y, $z)
}

function Clamp-SignedByte([int]$v, [int]$min = -127, [int]$max = 127) {
 if ($v -lt $min) { return $min }
 if ($v -gt $max) { return $max }
 return $v
}

function Get-LightPosition([int]$positionPhase, [int]$phaseCount, [string]$orbit) {
 $theta = $positionPhase * 2.0 * [Math]::PI / [double]$phaseCount
 if ($orbit -eq "flat") {
 return [int[]]@(
 (Clamp-SignedByte ([int][Math]::Round([Math]::Cos($theta) * 88.0))),
 -42,
 (Clamp-SignedByte ([int][Math]::Round([Math]::Sin($theta) * 88.0)))
 )
 }

 $turn = $positionPhase * 256.0 / [double]$phaseCount
 $local = [double[]]@(
 ([Math]::Cos($theta) * 88.0),
 0.0,
 ([Math]::Sin($theta) * 88.0)
 )
 $pitch = ([int][Math]::Round($turn + 19.0)) -band 255
 $yaw = ([int][Math]::Round(($turn * 2.0) + 43.0)) -band 255
 $roll = ([int][Math]::Round(($turn * 3.0) + 7.0)) -band 255
 $rx = -$pitch * 2.0 * [Math]::PI / 256.0
 $ry = -$yaw * 2.0 * [Math]::PI / 256.0
 $rz = -$roll * 2.0 * [Math]::PI / 256.0
 $sx = [Math]::Sin($rx); $cx = [Math]::Cos($rx)
 $sy = [Math]::Sin($ry); $cy = [Math]::Cos($ry)
 $sz = [Math]::Sin($rz); $cz = [Math]::Cos($rz)
 $t1 = $sx * $sy
 $t2 = $cx * $sy
 $v = [double[]]@(
 (($cy * $cz * $local[0]) + ((($t1 * $cz) - ($cx * $sz)) * $local[1]) + ((($t2 * $cz) + ($sx * $sz)) * $local[2])),
 (($cy * $sz * $local[0]) + ((($t1 * $sz) + ($cx * $cz)) * $local[1]) + ((($t2 * $sz) - ($sx * $cz)) * $local[2])),
 ((-$sy * $local[0]) + ($sx * $cy * $local[1]) + ($cx * $cy * $local[2]))
 )
 return [int[]]@(
 (Clamp-SignedByte ([int][Math]::Round($v[0]))),
 (Clamp-SignedByte ([int][Math]::Round($v[1] - 12.0))),
 (Clamp-SignedByte ([int][Math]::Round($v[2])))
 )
}

function Read-CameraObjects([string]$path) {
 if ($path.Trim().Length -le 0) {
 return @(
 [pscustomobject]@{ name = "default"; position = @(0,0,0); rotation = @(0,0,0) }
 )
 }

 $resolved = if ([IO.Path]::IsPathRooted($path)) { $path } else { Join-Path $Root $path }
 if (-not (Test-Path -LiteralPath $resolved)) {
 throw "CameraFile not found: $resolved"
 }
 $doc = Get-Content -LiteralPath $resolved -Raw | ConvertFrom-Json
 if (-not ($doc.PSObject.Properties.Name -contains "cameras")) {
 throw "CameraFile missing cameras array"
 }
 return @($doc.cameras)
}

function Has-Property([object]$Object, [string]$Name) {
 if ($null -eq $Object) {
 return $false
 }
 $propertyNames = @($Object.PSObject.Properties | ForEach-Object { $_.Name })
 return ($propertyNames -contains $Name)
}

function Get-PropertyValue([object]$Object, [string]$Name, [object]$Default = $null) {
 if (Has-Property $Object $Name) {
 return $Object.$Name
 }
 return $Default
}

function Get-SceneAxisConvention([object]$Doc) {
 $raw = Get-PropertyValue $Doc "axisConvention" (Get-PropertyValue $Doc "worldAxes" (Get-PropertyValue $Doc "coordinateSystem" "engine-y-up"))
 $key = ([string]$raw).Trim().ToLowerInvariant() -replace "[_ ]", "-"
 switch ($key) {
 { @("engine", "engine-y-up", "y-up", "y-up-z-depth") -contains $_ } { return "engine-y-up" }
 { @("world-z-up", "z-up", "z-up-y-forward", "x-right-y-forward-z-up") -contains $_ } { return "world-z-up" }
 default {
 throw "Scene axisConvention/worldAxes must be engine-y-up or world-z-up, got '$raw'"
 }
 }
}

function Get-SceneContractObject([object]$Doc) {
 if (Has-Property $Doc "contract") {
 return Get-PropertyValue $Doc "contract"
 }
 if (Has-Property $Doc "objectModel") {
 return Get-PropertyValue $Doc "objectModel"
 }
 return [pscustomobject]@{}
}

function Validate-SceneObjectModelContract([object]$Doc, [string]$AxisConvention) {
 $contract = Get-SceneContractObject $Doc
 if (Has-Property $contract "worldSpace") {
 $worldSpace = ([string](Get-PropertyValue $contract "worldSpace")).Trim().ToLowerInvariant() -replace "[_ ]", "-"
 if ($worldSpace.Length -gt 0 -and -not (@("world-z-up", "z-up", "x-right-y-forward-z-up") -contains $worldSpace)) {
 throw "Scene contract worldSpace must be world-z-up/z-up, got '$worldSpace'"
 }
 if ($AxisConvention -ne "world-z-up") {
 throw "Scene contract worldSpace requires axisConvention 'world-z-up'"
 }
 }
 if (Has-Property $contract "objectSpace") {
 $objectSpace = ([string](Get-PropertyValue $contract "objectSpace")).Trim().ToLowerInvariant() -replace "[_ ]", "-"
 if ($objectSpace.Length -gt 0 -and -not (@("aligned-world", "world-aligned", "same-as-world", "local-world-aligned") -contains $objectSpace)) {
 throw "Scene contract objectSpace must be aligned-world/world-aligned/same-as-world, got '$objectSpace'"
 }
 }
 if (Has-Property $contract "meshProfiles") {
 foreach ($profile in @($contract.meshProfiles)) {
 $meshProfile = ([string]$profile).Trim().ToLowerInvariant() -replace "[_ ]", "-"
 if ($meshProfile.Length -gt 0 -and -not (@("solid", "wire", "hidden-wire", "multimaterial", "multi-material") -contains $meshProfile)) {
 throw "Scene contract meshProfiles supports solid, wire, hidden-wire and multimaterial, got '$meshProfile'"
 }
 }
 }
 if (Has-Property $contract "wireAlias") {
 $wireAlias = ([string](Get-PropertyValue $contract "wireAlias")).Trim().ToLowerInvariant() -replace "[_ ]", "-"
 if ($wireAlias.Length -gt 0 -and -not (@("type-wire", "type:wire", "type=wire", "wire") -contains $wireAlias)) {
 throw "Scene contract wireAlias must describe type:wire/type-wire, got '$wireAlias'"
 }
 }
 if (Has-Property $contract "multimaterialAlias") {
 $multimaterialAlias = ([string](Get-PropertyValue $contract "multimaterialAlias")).Trim().ToLowerInvariant() -replace "[_ ]", "-"
 if ($multimaterialAlias.Length -gt 0 -and -not (@("geometry-multimaterial", "geometry:multimaterial", "geometry=multimaterial", "multimaterial", "material-profile-multimaterial", "materialprofile:multimaterial") -contains $multimaterialAlias)) {
 throw "Scene contract multimaterialAlias must describe geometry:multimaterial or materialProfile:multimaterial, got '$multimaterialAlias'"
 }
 }
}

function Read-SceneMeshGeometryKind([object]$Source, [string]$Context) {
 $sourceType = if (Has-Property $Source "type") { ([string](Get-PropertyValue $Source "type")).Trim().ToLowerInvariant() -replace "[_ ]", "-" } else { "" }
 if ($sourceType -eq "wire") {
 return "wire"
 }

 $geometryRaw = ""
 foreach ($propName in @("geometry", "meshGeometry", "geometryKind", "meshProfile")) {
 if ($geometryRaw.Length -eq 0 -and (Has-Property $Source $propName)) {
 $geometryRaw = [string](Get-PropertyValue $Source $propName)
 }
 }

 if ($geometryRaw.Trim().Length -eq 0) {
 return ""
 }

 $geometry = $geometryRaw.Trim().ToLowerInvariant() -replace "[_ ]", "-"
 switch ($geometry) {
 { @("solid", "poly", "polygon", "polygonal", "face", "faces", "surface") -contains $_ } { return "solid" }
 { @("wire", "wireframe", "edge", "edges", "edge-based", "line", "lines") -contains $_ } { return "wire" }
 { @("hidden-wire", "hidden-line") -contains $_ } { return "wire" }
 { @("multimaterial", "multi-material", "multi-material-solid", "per-face-material", "face-material", "face-materials") -contains $_ } { return "solid" }
 default { throw "Scene mesh geometry/profile must be solid, wire, hidden-wire or multimaterial for ${Context}, got '$geometryRaw'" }
 }
}

function Test-SceneHasPerFaceMaterialFields([object]$Source) {
 foreach ($propName in @("faceMaterialFamilies", "materialFamilies", "faceMaterials")) {
 if (Has-Property $Source $propName) {
 $values = @((Get-PropertyValue $Source $propName))
 if ($values.Count -gt 0) {
 return $true
 }
 }
 }
 return $false
}

function Read-SceneMeshMaterialProfile([object]$Source, [string]$Context) {
 $profileRaw = ""
 foreach ($propName in @("materialProfile", "meshMaterialProfile", "materialKind", "meshMaterial", "meshProfile", "geometry", "meshGeometry", "geometryKind")) {
 if ($profileRaw.Length -eq 0 -and (Has-Property $Source $propName)) {
 $profileRaw = [string](Get-PropertyValue $Source $propName)
 }
 }

 if ($profileRaw.Trim().Length -eq 0) {
 if (Test-SceneHasPerFaceMaterialFields $Source) {
 return "multimaterial"
 }
 return "single"
 }

 $profile = $profileRaw.Trim().ToLowerInvariant() -replace "[_ ]", "-"
 switch ($profile) {
 { @("single", "single-material", "mono", "monomaterial", "mono-material", "solid", "poly", "polygon", "polygonal", "face", "faces", "surface", "wire", "wireframe", "edge", "edges", "edge-based", "line", "lines", "hidden-wire", "hidden-line") -contains $_ } {
 if (Test-SceneHasPerFaceMaterialFields $Source) {
 return "multimaterial"
 }
 return "single"
 }
 { @("multimaterial", "multi-material", "multi-material-solid", "per-face-material", "face-material", "face-materials") -contains $_ } { return "multimaterial" }
 default { throw "Scene mesh material profile must be single or multimaterial for ${Context}, got '$profileRaw'" }
 }
}

function Convert-SceneVectorToEngine([object[]]$Values, [string]$AxisConvention) {
 if ($Values.Count -ne 3) {
 throw "Scene vector must contain 3 values"
 }
 if ($AxisConvention -eq "world-z-up") {
 return @($Values[0], $Values[2], $Values[1])
 }
 return @($Values[0], $Values[1], $Values[2])
}

function Convert-EngineVectorToScene([object[]]$Values, [string]$AxisConvention) {
 if ($Values.Count -ne 3) {
 throw "Engine vector must contain 3 values"
 }
 if ($AxisConvention -eq "world-z-up") {
 return @($Values[0], $Values[2], $Values[1])
 }
 return @($Values[0], $Values[1], $Values[2])
}

function Get-LightPositionForSceneAxes([int]$PositionPhase, [int]$PhaseCount, [string]$Orbit, [string]$AxisConvention) {
 $enginePosition = Get-LightPosition $PositionPhase $PhaseCount $Orbit
 if ($AxisConvention -eq "world-z-up") {
 $scenePosition = Convert-EngineVectorToScene @($enginePosition[0], $enginePosition[1], $enginePosition[2]) $AxisConvention
 return [int[]](Convert-SceneVectorToEngine $scenePosition $AxisConvention)
 }
 return $enginePosition
}

function Read-SceneCameraObject([object]$Camera, [string]$AxisConvention = "engine-y-up") {
 $name = [string](Get-PropertyValue $Camera "id" (Get-PropertyValue $Camera "name" "scene_camera"))
 if (-not (Has-Property $Camera "position")) {
 throw "Scene camera '$name' missing position"
 }
 $position = @($Camera.position)
 if ($position.Count -ne 3) {
 throw "Scene camera '$name' position must have 3 values"
 }

 if (Has-Property $Camera "rotation") {
 $rotation = @($Camera.rotation)
 } else {
 $pitch = [int](Get-PropertyValue $Camera "pitch" 0)
 $yaw = [int](Get-PropertyValue $Camera "yaw" 0)
 $roll = [int](Get-PropertyValue $Camera "roll" 0)
 $rotation = @($pitch, $yaw, $roll)
 }
 if ($rotation.Count -ne 3) {
 throw "Scene camera '$name' rotation must have 3 values"
 }
 $position = Convert-SceneVectorToEngine $position $AxisConvention
 $rotation = Convert-SceneVectorToEngine $rotation $AxisConvention

 $mode = ([string](Get-PropertyValue $Camera "mode" "")).Trim()
 if ($mode.Length -gt 0 -and -not (@("fixed", "walkLite", "walkFull") -contains $mode)) {
 throw "Scene camera '$name' mode must be one of: fixed, walkLite, walkFull"
 }
 $smoothDepthPingPong = Read-SceneSmoothDepthPingPong $Camera "camera '$name'"

 return [pscustomobject]@{
 name = $name
 position = @([int]$position[0], [int]$position[1], [int]$position[2])
 rotation = @([int]$rotation[0], [int]$rotation[1], [int]$rotation[2])
 mode = $mode
 depthPingPong = $smoothDepthPingPong
 }
}

function Read-SceneLightObjects([object]$Doc, [string]$AxisConvention = "engine-y-up") {
 if (-not (Has-Property $Doc "lights")) {
 return @()
 }

 $lights = @()
 $index = 0
 foreach ($light in @($Doc.lights)) {
 $name = [string](Get-PropertyValue $light "id" (Get-PropertyValue $light "name" "light_$index"))
 $runtimeStatic = $false
 if (Has-Property $light "type") {
 $lightType = ([string](Get-PropertyValue $light "type" "")).Trim()
 if ($lightType -ne "static") {
 throw "Scene light '$name' type must be 'static' when specified"
 }
 $runtimeStatic = $true
 }
 $mode = ([string](Get-PropertyValue $light "mode" "static")).Trim()
 if ($mode.Length -eq 0) {
 $mode = "static"
 }
 if (-not (@("static", "orbit", "procedural") -contains $mode)) {
 throw "Scene light '$name' mode must be one of: static, orbit, procedural"
 }

 $position = @(0, 0, 0)
 if ($mode -eq "static") {
 if (-not (Has-Property $light "position")) {
 throw "Scene light '$name' missing position"
 }
 $position = @($light.position)
 if ($position.Count -ne 3) {
 throw "Scene light '$name' position must have 3 values"
 }
 $position = Convert-SceneVectorToEngine $position $AxisConvention
 foreach ($c in $position) {
 if ([int]$c -lt -127 -or [int]$c -gt 127) {
 throw "Scene light '$name' coordinate outside signed byte range (-127..127): $c"
 }
 }
 }

 $orbit = ([string](Get-PropertyValue $light "orbit" $LightOrbit)).Trim()
 if ($orbit.Length -eq 0) {
 $orbit = $LightOrbit
 }
 if (-not (@("flat", "tumble3d") -contains $orbit)) {
 throw "Scene light '$name' orbit must be one of: flat, tumble3d"
 }

 $phaseCount = [int](Get-PropertyValue $light "phaseCount" $LightPhaseCount)
 if (-not (@(8, 16, 32) -contains $phaseCount)) {
 throw "Scene light '$name' phaseCount must be one of: 8, 16, 32"
 }
 $tickDiv = [int](Get-PropertyValue $light "tickDiv" $LightTickDiv)
 if ($tickDiv -lt 1 -or $tickDiv -gt 255) {
 throw "Scene light '$name' tickDiv must be in byte range 1..255"
 }
 $staticPhase = [int](Get-PropertyValue $light "staticPhase" $LightStaticPhase)
 if ($staticPhase -lt -1 -or $staticPhase -ge $phaseCount) {
 throw "Scene light '$name' staticPhase must be -1 or less than phaseCount"
 }

 $intensity = [int](Get-PropertyValue $light "intensity" $LightIntensity)
 if ($intensity -lt 0 -or $intensity -gt 10) {
 throw "Scene light '$name' intensity must be in range 0..10"
 }
 $pulseEnabled = $false
 if (Has-Property $light "pulse") {
 $pulse = Get-PropertyValue $light "pulse"
 if ($pulse -is [bool]) {
 $pulseEnabled = [bool]$pulse
 } elseif (Has-Property $pulse "enabled") {
 $pulseEnabled = [bool](Get-PropertyValue $pulse "enabled")
 }
 }

 $lights += ,[pscustomobject]@{
 name = $name
 mode = $mode
 position = @([int]$position[0], [int]$position[1], [int]$position[2])
 orbit = $orbit
 phaseCount = $phaseCount
 tickDiv = $tickDiv
 staticPhase = $staticPhase
 intensity = $intensity
 pulse = $pulseEnabled
 runtimeStatic = $runtimeStatic
 }
 $index++
 }
 return $lights
}

function Resolve-ScenePath([string]$Path, [string]$SceneDir) {
 if ([IO.Path]::IsPathRooted($Path)) {
 return $Path
 }
 if ($Path.StartsWith("@root/", [System.StringComparison]::OrdinalIgnoreCase) -or
 $Path.StartsWith("@root\", [System.StringComparison]::OrdinalIgnoreCase)) {
 return (Join-Path $Root $Path.Substring(6))
 }
 if ($Path.StartsWith("@scene/", [System.StringComparison]::OrdinalIgnoreCase) -or
 $Path.StartsWith("@scene\", [System.StringComparison]::OrdinalIgnoreCase)) {
 return (Join-Path $SceneDir $Path.Substring(7))
 }
 return (Join-Path $SceneDir $Path)
}

function Convert-ToFixed8([object]$Value, [string]$Name, [int]$MinScaled, [int]$MaxScaled) {
 $scaled = [int][Math]::Round(([double]$Value) * 256.0)
 if ($scaled -lt $MinScaled -or $scaled -gt $MaxScaled) {
 throw "$Name is outside 8.8 range: $Value"
 }
 return $scaled
}

function Split-Fixed8([int]$Scaled) {
 return @{
 Lo = ($Scaled -band 255)
 Hi = (($Scaled -shr 8) -band 255)
 }
}

function Split-Fixed16_8([int]$Scaled) {
 return @{
 Frac = ($Scaled -band 255)
 Lo = (($Scaled -shr 8) -band 255)
 Hi = (($Scaled -shr 16) -band 255)
 }
}

function Format-WorldUnit([double]$Value) {
 return $Value.ToString("0.########", [Globalization.CultureInfo]::InvariantCulture)
}

function Get-ObjectDepthExtensionBounds([object]$Object) {
 $meshIndex = [int]$Object.MeshIndex
 $record = $MeshRecords[$meshIndex]
 $first = [int]$record.FirstVertex
 $end = $first + [int]$record.VertexCount
 $scaleQ6 = [int]$Object.Scale
 $maxTermSum = 0
 for ($i = $first; $i -lt $end; $i++) {
  $vertex = $MeshVertices[$i]
  # Every scaled Q6 rotation coefficient has magnitude <= scaleQ6.
  # mul_s6 truncates each coordinate product toward zero before the three
  # byte terms are added, so this per-vertex L1 envelope is valid for every
  # possible object rotation without relying on ideal floating-point axes.
  $termSum = 0
  foreach ($component in @([int]$vertex[0], [int]$vertex[1], [int]$vertex[2])) {
   $termSum += [int][Math]::Floor(([Math]::Abs($component) * [double]$scaleQ6) / 64.0)
  }
  if ($termSum -gt $maxTermSum) { $maxTermSum = $termSum }
 }
 if ($maxTermSum -ge 128) {
  # The runtime additions wrap to a signed byte.  Once the analytical
  # envelope reaches that boundary, only the complete byte domain is safe.
  return [pscustomobject]@{ Min = -128; Max = 127; Envelope = 128 }
 }
 return [pscustomobject]@{ Min = -$maxTermSum; Max = $maxTermSum; Envelope = $maxTermSum }
}

function Validate-SceneObjectDepthDomains([string]$CameraMode) {
 foreach ($object in @($SceneObjects)) {
  $bounds = Get-ObjectDepthExtensionBounds $object
  $minimumCenterInteger = -32768 - [int]$bounds.Min
  $maximumCenterInteger = 32767 - [int]$bounds.Max
  # fixed rounds the stored center fraction into the whole-WU depth when
  # bit 7 is set; mobile paths currently consume the signed integer word and
  # ignore that fraction.  Validate the profile that will actually compile.
  if ($CameraMode -eq "fixed") {
   # Values from integer-0.5 through integer-1/256 round upward to integer.
   $minimumScaled = [Math]::Max(-8388608, ($minimumCenterInteger * 256) - 128)
   $maximumFraction = 127
  } else {
   $minimumScaled = [Math]::Max(-8388608, $minimumCenterInteger * 256)
   $maximumFraction = 255
  }
  $maximumScaled = ($maximumCenterInteger * 256) + $maximumFraction
  if ($maximumScaled -gt 8388607) { $maximumScaled = 8388607 }
  $requestedScaled = [int]$object.Position[2]
  if ($requestedScaled -ge $minimumScaled -and $requestedScaled -le $maximumScaled) {
   continue
  }

  $requestedWorldY = if ($object.PSObject.Properties.Name -contains "RequestedWorldY") {
   [double]$object.RequestedWorldY
  } else {
   [double]$requestedScaled / 256.0
  }
  $centerInteger = $requestedScaled -shr 8
  $fractionCarry = if ($CameraMode -eq "fixed" -and ($requestedScaled -band 255) -ge 128) { 1 } else { 0 }
  $runtimeCenter = $centerInteger + $fractionCarry
  $resultMinimum = $runtimeCenter + [int]$bounds.Min
  $resultMaximum = $runtimeCenter + [int]$bounds.Max
  $safeMinimum = [double]$minimumScaled / 256.0
  $safeMaximum = [double]$maximumScaled / 256.0
  $scaleQ6 = [int]$object.Scale
  $scale = [double]$scaleQ6 / 64.0
  throw ("Object depth validation failed for object '{0}': requested world Y={1} WU; safe world Y interval=[{2},{3}] WU for camera mode {4}; mesh depth extension=[{5},{6}] WU; scaleQ6={7}/64 ({8}); resulting depth interval=[{9},{10}] WU; signed 16.8 integer domain=[-32768,32767]." -f `
   $object.Name,
   (Format-WorldUnit $requestedWorldY),
   (Format-WorldUnit $safeMinimum),
   (Format-WorldUnit $safeMaximum),
   $CameraMode,
   $bounds.Min,
   $bounds.Max,
   $scaleQ6,
   (Format-WorldUnit $scale),
   $resultMinimum,
   $resultMaximum)
 }
}

function Read-Fixed3([object]$Object, [string]$Name, [object[]]$Default, [int]$MinScaled, [int]$MaxScaled, [string]$AxisConvention = "engine-y-up") {
 $values = @(Get-PropertyValue $Object $Name $Default)
 if ($values.Count -ne 3) {
 throw "$Name must contain 3 values"
 }
 $values = Convert-SceneVectorToEngine $values $AxisConvention
 return @(
 (Convert-ToFixed8 $values[0] "$Name[0]" $MinScaled $MaxScaled),
 (Convert-ToFixed8 $values[1] "$Name[1]" $MinScaled $MaxScaled),
 (Convert-ToFixed8 $values[2] "$Name[2]" $MinScaled $MaxScaled)
 )
}

function Read-ScenePosition([object]$Object, [string]$AxisConvention = "engine-y-up") {
 $values = @(Get-PropertyValue $Object "position" @(0,0,0))
 if ($values.Count -ne 3) {
 throw "position must contain 3 values"
 }
 $values = Convert-SceneVectorToEngine $values $AxisConvention
 return @(
 (Convert-ToFixed8 $values[0] "position[0]" -32768 32767),
 (Convert-ToFixed8 $values[1] "position[1]" -32768 32767),
 # Keep a wider diagnostic intake on the negative side so the object-aware
 # validation can report the object, mesh envelope, scale, and resulting
 # interval instead of failing first with a generic component-range error.
 (Convert-ToFixed8 $values[2] "position[2]" -16777216 16777215)
 )
}

function Read-SceneVelocity([object]$Object, [string]$AxisConvention = "engine-y-up") {
 $values = @(Get-PropertyValue $Object "velocity" @(0,0,0))
 if ($values.Count -ne 3) {
 throw "velocity must contain 3 values"
 }
 $values = Convert-SceneVectorToEngine $values $AxisConvention
 return @(
 (Convert-ToFixed8 $values[0] "velocity[0]" -32768 32767),
 (Convert-ToFixed8 $values[1] "velocity[1]" -32768 32767),
 (Convert-ToFixed8 $values[2] "velocity[2]" -8388608 8388607)
 )
}

function Read-SceneObjectRespawn([object]$Object, [string]$ObjectName, [string]$AxisConvention = "engine-y-up") {
 $disabled = [pscustomobject]@{
 Enabled = 0
 NearZHi = 0
 FarZLo = 0
 FarZHi = 0
 FarZExt = 0
 FarZJitterMask = 0
 XMask = 0
 XBias = 0
 YMask = 0
 YBias = 0
 }
 if (-not (Has-Property $Object "respawn")) {
 return $disabled
 }

 $respawn = Get-PropertyValue $Object "respawn"
 if ($respawn -is [bool]) {
 if (-not $respawn) { return $disabled }
 $respawn = [pscustomobject]@{}
 }

 $enabledValue = Get-PropertyValue $respawn "enabled" $true
 if ($enabledValue -is [bool]) {
 if (-not $enabledValue) { return $disabled }
 } elseif ([int]$enabledValue -eq 0) {
 return $disabled
 }

 $nearZ = [double](Get-PropertyValue $respawn "nearDepth" (Get-PropertyValue $respawn "nearZ" -112))
 if ($nearZ -ge 0) {
 throw "respawn.nearDepth/nearZ must be negative for scene object '$ObjectName'"
 }
 $farZ = [double](Get-PropertyValue $respawn "farDepth" (Get-PropertyValue $respawn "farZ" 180))
 if ($farZ -lt 1) {
 throw "respawn.farDepth/farZ must be positive for scene object '$ObjectName'"
 }
 $nearFixed = Convert-ToFixed8 $nearZ "respawn.nearDepth" -8388608 8388607
 $farFixed = Convert-ToFixed8 $farZ "respawn.farDepth" 0 16777215
 $nearParts = Split-Fixed16_8 $nearFixed
 $farParts = Split-Fixed16_8 $farFixed

 $zJitterMask = [int](Get-PropertyValue $respawn "depthJitterMask" (Get-PropertyValue $respawn "zJitterMask" 63))
 $xMask = [int](Get-PropertyValue $respawn "xMask" 127)
 $xBias = [int](Get-PropertyValue $respawn "xBias" 64)
 if ($AxisConvention -eq "world-z-up") {
 $yMask = [int](Get-PropertyValue $respawn "zMask" (Get-PropertyValue $respawn "yMask" 63))
 $yBias = [int](Get-PropertyValue $respawn "zBias" (Get-PropertyValue $respawn "yBias" 32))
 } else {
 $yMask = [int](Get-PropertyValue $respawn "yMask" 63)
 $yBias = [int](Get-PropertyValue $respawn "yBias" 32)
 }
 foreach ($pair in @(
 @("respawn.zJitterMask", $zJitterMask),
 @("respawn.xMask", $xMask),
 @("respawn.xBias", $xBias),
 @("respawn.yMask", $yMask),
 @("respawn.yBias", $yBias)
 )) {
 if ([int]$pair[1] -lt 0 -or [int]$pair[1] -gt 255) {
 throw "$($pair[0]) must be in byte range 0..255 for scene object '$ObjectName'"
 }
 }

 return [pscustomobject]@{
 Enabled = 1
 NearZHi = [int]$nearParts.Lo
 FarZLo = [int]$farParts.Frac
 FarZHi = [int]$farParts.Lo
 FarZExt = [int]$farParts.Hi
 FarZJitterMask = $zJitterMask
 XMask = $xMask
 XBias = $xBias
 YMask = $yMask
 YBias = $yBias
 }
}

function Read-SceneObjectOscillationX([object]$Object, [string]$ObjectName) {
 $disabled = [pscustomobject]@{
 Enabled = 0
 MinLo = 0
 MinHi = 0
 MaxLo = 0
 MaxHi = 0
 }
 $oscillation = Get-PropertyValue $Object "oscillation" (Get-PropertyValue $Object "oscillate" $null)
 if ($null -eq $oscillation) {
 return $disabled
 }
 if ($oscillation -is [bool]) {
 if (-not $oscillation) { return $disabled }
 throw "Scene object '$ObjectName' oscillation=true requires min/max values"
 }

 $axis = ([string](Get-PropertyValue $oscillation "axis" "x")).Trim().ToLowerInvariant()
 if ($axis -ne "x") {
 throw "Scene object '$ObjectName' oscillation currently supports only axis 'x'"
 }
 $enabled = [bool](Get-PropertyValue $oscillation "enabled" $true)
 if (-not $enabled) {
 return $disabled
 }

 $minValue = Get-PropertyValue $oscillation "min" (Get-PropertyValue $oscillation "minX" $null)
 $maxValue = Get-PropertyValue $oscillation "max" (Get-PropertyValue $oscillation "maxX" $null)
 if ($null -eq $minValue -or $null -eq $maxValue) {
 throw "Scene object '$ObjectName' oscillation requires min/max"
 }
 $minFixed = Convert-ToFixed8 $minValue "oscillation.min" -32768 32767
 $maxFixed = Convert-ToFixed8 $maxValue "oscillation.max" -32768 32767
 if ($minFixed -ge $maxFixed) {
 throw "Scene object '$ObjectName' oscillation min must be smaller than max"
 }
 $minSplit = Split-Fixed8 $minFixed
 $maxSplit = Split-Fixed8 $maxFixed

 return [pscustomobject]@{
 Enabled = 1
 MinLo = [int]$minSplit.Lo
 MinHi = [int]$minSplit.Hi
 MaxLo = [int]$maxSplit.Lo
 MaxHi = [int]$maxSplit.Hi
 }
}

function Read-SceneSmoothDepthPingPong([object]$Entity, [string]$Context) {
 $disabled = [pscustomobject]@{
 Enabled = 0
 MinFixed = 0
 MaxFixed = 0
 PhaseStart = 0
 PhaseStep = 0
 }
 $pingPong = Get-PropertyValue $Entity "depthPingPong" $null
 if ($null -eq $pingPong) {
 return $disabled
 }
 if ($pingPong -is [bool]) {
 if (-not $pingPong) { return $disabled }
 throw "Scene $Context depthPingPong=true requires min/max values"
 }

 $enabled = [bool](Get-PropertyValue $pingPong "enabled" $true)
 if (-not $enabled) {
 return $disabled
 }
 $easing = ([string](Get-PropertyValue $pingPong "easing" "sine")).Trim().ToLowerInvariant()
 if (@("sine", "sin", "sinusoidal", "smooth") -notcontains $easing) {
 throw "Scene $Context depthPingPong easing must be sine"
 }
 $minValue = Get-PropertyValue $pingPong "min" (Get-PropertyValue $pingPong "minDepth" $null)
 $maxValue = Get-PropertyValue $pingPong "max" (Get-PropertyValue $pingPong "maxDepth" $null)
 if ($null -eq $minValue -or $null -eq $maxValue) {
 throw "Scene $Context depthPingPong requires min/max"
 }
 $minFixed = Convert-ToFixed8 $minValue "depthPingPong.min" -8388608 16777215
 $maxFixed = Convert-ToFixed8 $maxValue "depthPingPong.max" -8388608 16777215
 if ($minFixed -ge $maxFixed) {
 throw "Scene $Context depthPingPong min must be smaller than max"
 }
 $phaseStart = [int](Get-PropertyValue $pingPong "phaseStart" 64)
 $phaseStep = [int](Get-PropertyValue $pingPong "phaseStep" 1)
 if ($phaseStart -lt 0 -or $phaseStart -gt 255) {
 throw "Scene $Context depthPingPong.phaseStart must be in byte range 0..255"
 }
 if ($phaseStep -lt 1 -or $phaseStep -gt 32) {
 throw "Scene $Context depthPingPong.phaseStep must be in range 1..32"
 }

 return [pscustomobject]@{
 Enabled = 1
 MinFixed = $minFixed
 MaxFixed = $maxFixed
 PhaseStart = $phaseStart
 PhaseStep = $phaseStep
 }
}

function Read-Scale64([object]$Object) {
 if (Has-Property $Object "scale64") {
 $scale = [int](Get-PropertyValue $Object "scale64")
 } elseif (Has-Property $Object "scale") {
 $scale = [int][Math]::Round(([double](Get-PropertyValue $Object "scale")) * 64.0)
 } elseif (Has-Property $Object "size") {
 $scale = [int][Math]::Round(([double](Get-PropertyValue $Object "size")) * 64.0)
 } else {
 $scale = 64
 }
 if ($scale -lt 1 -or $scale -gt 127) {
 throw "Object scale must resolve to 1..127 in 6-bit scale units; use scale=1.0 for normal size."
 }
 return $scale
}

$sin = @()
for ($i = 0; $i -lt 256; $i++) {
 $v = [Math]::Round([Math]::Sin($i * 2.0 * [Math]::PI / 256.0) * 64.0)
 if ($v -lt 0) { $v += 256 }
 $sin += [int]$v
}

$ProjectionContract = [ordered]@{
 Focal = $CameraViewportFocal
 ScreenCenterX = $CameraViewportCenterX
 ScreenCenterY = $CameraViewportCenterY
 ScreenMinX = 0
 ScreenMaxX = ($CameraViewportWidth - 1)
 ScreenMinY = 0
 ScreenMaxY = ($CameraViewportHeight - 1)
 PhysicalOriginX = $CameraViewportOriginX
 PhysicalOriginY = $CameraViewportOriginY
 PhysicalWidth = $CameraViewportPhysicalWidth
 PhysicalHeight = $CameraViewportPhysicalHeight
 NearMinDepth = 32
 FarDepthClamp = 33 # $21
 CameraFaceMinDepth = 8
 ViewDepthProjectionIndexBias = 190
 FrustumXNear = $CameraViewportFrustumXNear
 FrustumYNear = $CameraViewportFrustumYNear
 FrustumFocal = $CameraViewportFrustumFocal
 ProjectionMode = $Projection
 ProjectionTableMode = if ($Projection -eq "extended-table") { 1 } else { 0 }
}

$scale = @()
$sceneScale = @()
$focal = $ProjectionContract.Focal
$groundHorizonStartRows = @()
$groundHorizonStartRowsRollBiased = @()
for ($i = 0; $i -lt 256; $i++) {
 $angle = $i * 2.0 * [Math]::PI / 256.0
 $angleCos = [Math]::Cos($angle)
 $angleSin = [Math]::Sin($angle)
 if ([Math]::Abs($angleCos) -lt 0.000001) {
 $row = if ($angleSin -ge 0.0) { -($ProjectionContract.ScreenCenterY * 2.0 - 4.0) } else { ($ProjectionContract.ScreenCenterY * 4.0 - 4.0) }
 } else {
 $row = [double]$ProjectionContract.ScreenCenterY - ($focal * ($angleSin / $angleCos))
 }
 $start = [int][Math]::Ceiling($row)
 if ($start -lt $ProjectionContract.ScreenMinY) { $start = $ProjectionContract.ScreenMinY }
 if ($start -gt ($ProjectionContract.ScreenMaxY + 1)) { $start = ($ProjectionContract.ScreenMaxY + 1) }
 $groundHorizonStartRows += $start
 $rollStart = [int][Math]::Ceiling($row) + 32
 if ($rollStart -lt 0) { $rollStart = 0 }
 if ($rollStart -gt 255) { $rollStart = 255 }
 $groundHorizonStartRowsRollBiased += $rollStart
}
for ($projectionTableIndex = 0; $projectionTableIndex -lt 256; $projectionTableIndex++) {
 $cameraDepthGeometric = $projectionTableIndex - $ProjectionContract.ViewDepthProjectionIndexBias
 $projectionDivisor = [Math]::Max($Mode4ProjectionMinDivisor, $cameraDepthGeometric)
 if ($projectionDivisor -lt $ProjectionContract.NearMinDepth) {
 $v = 120
 } else {
 $v = [Math]::Round(($focal * 64.0) / $projectionDivisor)
 if ($v -gt 120) { $v = 120 }
 if ($v -lt 18) { $v = 18 }
 }
 $scale += [int]$v
 $sceneV = [Math]::Round(($focal * 64.0) / $projectionDivisor)
 if ($sceneV -gt 255) { $sceneV = 255 }
 if ($sceneV -lt 18) { $sceneV = 18 }
 $sceneScale += [int]$sceneV
}

$scaleFar = @()
for ($i = 0; $i -lt 256; $i++) {
 $projectionTableIndexMidpoint = 256 + ($i * 32) + 16
 $cameraDepthGeometricMidpoint = $projectionTableIndexMidpoint - $ProjectionContract.ViewDepthProjectionIndexBias
 $projectionDivisor = [Math]::Max($Mode4ProjectionMinDivisor, $cameraDepthGeometricMidpoint)
 $v = [Math]::Round(($focal * 64.0) / $projectionDivisor)
 if ($v -gt 120) { $v = 120 }
 if ($v -lt 1) { $v = 1 }
 $scaleFar += [int]$v
}

# Contract samples: the physical address remains geometric+bias, while every
# stored reciprocal is derived from geometric depth (or the geometric
# midpoint represented by a compressed far-table slot).
$projectionDepthAuditSamples = @(7, 8, 9, 16, 32, 64, 189, 190, 191)
foreach ($cameraDepthGeometric in $projectionDepthAuditSamples) {
 $projectionTableIndex = $cameraDepthGeometric + $ProjectionContract.ViewDepthProjectionIndexBias
 $projectionDivisor = [Math]::Max($Mode4ProjectionMinDivisor, $cameraDepthGeometric)
 if ($projectionTableIndex -le 255) {
  if ($projectionDivisor -lt $ProjectionContract.NearMinDepth) {
   $expectedScale = 120
  } else {
   $expectedScale = [Math]::Round(($focal * 64.0) / $projectionDivisor)
   if ($expectedScale -gt 120) { $expectedScale = 120 }
   if ($expectedScale -lt 18) { $expectedScale = 18 }
  }
  if ([int]$scale[$projectionTableIndex] -ne [int]$expectedScale) {
   throw "Projection scale-table semantic mismatch at geometric depth $cameraDepthGeometric (physical index $projectionTableIndex)"
  }
  $expectedSceneScale = [Math]::Round(($focal * 64.0) / $projectionDivisor)
  if ($expectedSceneScale -gt 255) { $expectedSceneScale = 255 }
  if ($expectedSceneScale -lt 18) { $expectedSceneScale = 18 }
  if ([int]$sceneScale[$projectionTableIndex] -ne [int]$expectedSceneScale) {
   throw "Projection near-table semantic mismatch at geometric depth $cameraDepthGeometric (physical index $projectionTableIndex)"
  }
 } else {
  $projectionFarHigh = ($projectionTableIndex -shr 8)
  $projectionFarLow = ($projectionTableIndex -band 255)
  $projectionFarSlot = (($projectionFarHigh - 1) * 8) + ($projectionFarLow -shr 5)
  $projectionFarIndexMidpoint = 256 + ($projectionFarSlot * 32) + 16
  $projectionFarGeometricMidpoint = $projectionFarIndexMidpoint - $ProjectionContract.ViewDepthProjectionIndexBias
  $projectionFarDivisor = [Math]::Max($Mode4ProjectionMinDivisor, $projectionFarGeometricMidpoint)
  $expectedFarScale = [Math]::Round(($focal * 64.0) / $projectionFarDivisor)
  if ($expectedFarScale -gt 120) { $expectedFarScale = 120 }
  if ($expectedFarScale -lt 1) { $expectedFarScale = 1 }
  if ([int]$scaleFar[$projectionFarSlot] -ne [int]$expectedFarScale) {
   throw "Projection far-table semantic mismatch at geometric depth $cameraDepthGeometric (physical index $projectionTableIndex, slot $projectionFarSlot)"
  }
 }
}

# Exhaustively prove that geometric signed depth plus the projection-index
# origin can never wrap into an unchecked table access.  Index 0/negative is
# clamped to 1; high=$01..$20 selects one of 256 far-table entries; high >=
# FarDepthClamp uses the existing scale=1 path without indexing a table.
$projectionFarTableMaxIndex = (($ProjectionContract.FarDepthClamp - 1) * 256) + 255
for ($cameraDepthGeometric = -32768; $cameraDepthGeometric -le 32767; $cameraDepthGeometric++) {
 $projectionTableIndexRaw = $cameraDepthGeometric + $ProjectionContract.ViewDepthProjectionIndexBias
 $projectionTableIndex = if ($projectionTableIndexRaw -le 0) { 1 } else { $projectionTableIndexRaw }
 if ($projectionTableIndex -le 255) {
  if ($projectionTableIndex -lt 1) {
   throw "Projection table near index underflow for geometric depth $cameraDepthGeometric"
  }
 } elseif ($projectionTableIndex -le $projectionFarTableMaxIndex) {
  $projectionFarHigh = ($projectionTableIndex -shr 8)
  $projectionFarLow = ($projectionTableIndex -band 255)
  $projectionFarSlot = (($projectionFarHigh - 1) * 8) + ($projectionFarLow -shr 5)
  if ($projectionFarSlot -lt 0 -or $projectionFarSlot -ge $scaleFar.Count) {
   throw "Projection far-table index overflow for geometric depth $cameraDepthGeometric (slot=$projectionFarSlot)"
  }
 }
}

$projx = @()
$projy = @()
$projNumLo = @()
$projNumHi = @()
for ($i = 0; $i -lt 256; $i++) {
 $d = if ($i -ge 128) { $i - 256 } else { $i }
 $x = $ProjectionContract.ScreenCenterX + $d
 if ($x -lt $ProjectionContract.ScreenMinX) { $x = $ProjectionContract.ScreenMinX }
 if ($x -gt $ProjectionContract.ScreenMaxX) { $x = $ProjectionContract.ScreenMaxX }
 $y = $ProjectionContract.ScreenCenterY - $d
 if ($y -lt $ProjectionContract.ScreenMinY) { $y = $ProjectionContract.ScreenMinY }
 if ($y -gt $ProjectionContract.ScreenMaxY) { $y = $ProjectionContract.ScreenMaxY }
 $projx += [int]$x
 $projy += [int]$y
 $abs = if ($i -gt 127) { 127 } else { $i }
 $num = $abs * $focal
 $projNumLo += ($num -band 255)
 $projNumHi += (($num -shr 8) -band 255)
}

$sqlo = @()
$sqhi = @()
for ($i = 0; $i -lt 256; $i++) {
 $v = [int][Math]::Floor(($i * $i) / 4.0)
 $sqlo += ($v -band 255)
 $sqhi += (($v -shr 8) -band 255)
}

function Make-RowTable([int]$base, [int]$plus) {
 $lo = @()
 $hi = @()
 for ($y = 0; $y -lt ($ProjectionContract.ScreenMaxY + 1); $y++) {
 $physicalY = $y + $ProjectionContract.PhysicalOriginY
 $py = $physicalY * 2 + $plus
 $addr = $base + (($py -band 7) + 8 * (40 * [Math]::Floor($py / 8)))
 $lo += ($addr -band 255)
 $hi += (($addr -shr 8) -band 255)
 }
 return @($lo, $hi)
}

$HighBasicV2LayoutFlag = if ($MemoryLayout -eq "high-basic-v2") { 1 } else { 0 }
$BitmapBBase = if ($HighBasicV2LayoutFlag -ne 0) { 0x2000 } else { 0xA000 }
$ScreenBBase = if ($HighBasicV2LayoutFlag -ne 0) { 0x0400 } else { 0x8C00 }
$RuntimeBufferLimit = if ($HighBasicV2LayoutFlag -ne 0) { 0xA000 } else { $ScreenBBase }
$VicBankBBits = if ($HighBasicV2LayoutFlag -ne 0) { 0x03 } else { 0x01 }
$VicD018B = if ($HighBasicV2LayoutFlag -ne 0) { 0x18 } else { 0x38 }
# The FPS counter and the visible overlay are separate build features. DEV7
# renders the text header with each bitmap buffer's own Screen RAM and with a
# compact charset stored at the start of that same buffer's bitmap. This keeps
# both stable and high-basic-v2 inside their native VIC-II banks. The canonical
# -NoFpsOverlay build remains byte-for-byte unchanged. The F key remains an
# overlay-only runtime toggle; -FpsCounterOnly emits the sampler without text,
# charset or split IRQ.
$FpsTextReservedSize = 0x0400
$FpsCharsetReservedSize = 0x0800
$FpsTextClearCells = $TextHeaderScreenBytes

function Update-FpsMemoryLayout(
 [int]$OverlayEnable,
 [int]$HighBasicEnable,
 [string]$GraphicsModeValue
) {
 if ($OverlayEnable -ne 0) {
  $script:FpsTextBase = 0x5C00
  $script:FpsCharsetBase = 0x6000
  $script:FpsTextD018 = 0x78
 } else {
  $script:FpsTextBase = if ($HighBasicEnable -ne 0) { 0xCC00 } else { 0xC000 }
  $script:FpsCharsetBase = 0xC800
  $script:FpsTextD018 = if ($HighBasicEnable -ne 0) { 0x32 } else { 0x02 }
 }
 $script:FpsOverlayUnderIoLayoutFlag = 0
 $script:FpsTextUnderIoFlag = 0
 $script:FpsCharsetUnderIoFlag = 0
 $script:FpsTextRelocationD800Flag = 0
 $script:FpsCharsetRelocationD000Flag = 0
 $script:FpsCharsetRelocationFlag = 0
 $script:Mode3FpsCharsetRelocationFlag = 0
}

function Test-AddressRangeOverlap([int]$StartA, [int]$EndA, [int]$StartB, [int]$EndB) {
 return ($StartA -le $EndB -and $StartB -le $EndA)
}

function Assert-FpsMemoryContract([int]$OverlayEnable) {
 if ($OverlayEnable -eq 0) { return }

 $pairs = @(
  [ordered]@{ Name = "A"; Screen = 0x5C00; Charset = 0x6000; D018 = 0x78 },
  [ordered]@{ Name = "B"; Screen = $ScreenBBase; Charset = $BitmapBBase; D018 = $VicD018B }
 )
 foreach ($pair in $pairs) {
  if (($pair.Screen -band 0x03ff) -ne 0) {
   throw ("Split-screen buffer {0} Screen RAM must be 1 KiB aligned: {1:X4}" -f $pair.Name, $pair.Screen)
  }
  if (($pair.Charset -band 0x07ff) -ne 0) {
   throw ("Split-screen buffer {0} charset must be 2 KiB aligned: {1:X4}" -f $pair.Name, $pair.Charset)
  }
  $textEnd = $pair.Screen + $FpsTextReservedSize - 1
  $charsetEnd = $pair.Charset + $FpsCharsetReservedSize - 1
  if (Test-AddressRangeOverlap $pair.Screen $textEnd $pair.Charset $charsetEnd) {
   throw ("Split-screen buffer {0} screen/charset ranges overlap" -f $pair.Name)
  }
  $bank = $pair.Screen -band 0xC000
  if (($pair.Charset -band 0xC000) -ne $bank) {
   throw ("Split-screen buffer {0} screen and charset must share a VIC-II bank" -f $pair.Name)
  }
  $screenIndex = [int](($pair.Screen - $bank) / 0x0400)
  $charsetIndex = [int](($pair.Charset - $bank) / 0x0800)
  $expectedD018 = (($screenIndex -band 0x0f) -shl 4) -bor (($charsetIndex -band 0x07) -shl 1)
  if ($expectedD018 -ne $pair.D018) {
   throw ("Split-screen buffer {0} D018 mismatch: expected {1:X2}, configured {2:X2}" -f $pair.Name, $expectedD018, $pair.D018)
  }
 }
 if ($TextHeaderScreenBytes -ne 120) {
  throw "Split-screen header contract requires exactly 120 Screen RAM bytes"
 }
}

$row0a = Make-RowTable 0x6000 0
$row1a = Make-RowTable 0x6000 1
$row0b = Make-RowTable $BitmapBBase 0
$row1b = Make-RowTable $BitmapBBase 1

function Make-CellRowTable([int]$base) {
 $lo = @()
 $hi = @()
 for ($y = 0; $y -lt ($ProjectionContract.ScreenMaxY + 1); $y++) {
 $physicalY = $y + $ProjectionContract.PhysicalOriginY
 $addr = $base + (40 * [Math]::Floor($physicalY / 4))
 $lo += ($addr -band 255)
 $hi += (($addr -shr 8) -band 255)
 }
 return @($lo, $hi)
}

$screenRowA = Make-CellRowTable 0x5C00
$screenRowB = Make-CellRowTable $ScreenBBase
$colorRow = Make-CellRowTable 0xD800
$viewportCellRowId = @()
for ($y = 0; $y -lt ($ProjectionContract.ScreenMaxY + 1); $y++) {
 $viewportCellRowId += [int][Math]::Floor(($y + $ProjectionContract.PhysicalOriginY) / 4)
}

$xbyte = @()
$xofflo = @()
$xoffhi = @()
$startmask = @()
$endmask = @()
$byteofflo = @()
$byteoffhi = @()
$sm = @(0xFF,0x3F,0x0F,0x03)
$em = @(0xC0,0xF0,0xFC,0xFF)
for ($x = 0; $x -lt ($ProjectionContract.ScreenMaxX + 1); $x++) {
 $physicalX = $x + $ProjectionContract.PhysicalOriginX
 $b = [Math]::Floor($physicalX / 4)
 $off = $b * 8
 $xbyte += [int]$b
 $xofflo += ($off -band 255)
 $xoffhi += (($off -shr 8) -band 255)
 $startmask += $sm[$physicalX -band 3]
 $endmask += $em[$physicalX -band 3]
}
for ($b = 0; $b -lt 40; $b++) {
 $off = $b * 8
 $byteofflo += ($off -band 255)
 $byteoffhi += (($off -shr 8) -band 255)
}

$fpsFontBytes = @(
 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, # 0: space
 0x3C,0x66,0x6E,0x76,0x66,0x66,0x3C,0x00, # 1: 0
 0x18,0x38,0x18,0x18,0x18,0x18,0x7E,0x00, # 2: 1
 0x3C,0x66,0x06,0x0C,0x18,0x30,0x7E,0x00, # 3: 2
 0x7E,0x0C,0x18,0x0C,0x06,0x66,0x3C,0x00, # 4: 3
 0x0C,0x1C,0x3C,0x6C,0x7E,0x0C,0x0C,0x00, # 5: 4
 0x7E,0x60,0x7C,0x06,0x06,0x66,0x3C,0x00, # 6: 5
 0x1C,0x30,0x60,0x7C,0x66,0x66,0x3C,0x00, # 7: 6
 0x7E,0x06,0x0C,0x18,0x30,0x30,0x30,0x00, # 8: 7
 0x3C,0x66,0x66,0x3C,0x66,0x66,0x3C,0x00, # 9: 8
 0x3C,0x66,0x66,0x3E,0x06,0x0C,0x38,0x00, # 10: 9
 0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x00, # 11: .
 0x3C,0x66,0x60,0x3C,0x06,0x66,0x3C,0x00, # 12: S
 0x3C,0x66,0x60,0x60,0x60,0x66,0x3C,0x00, # 13: C
 0x7C,0x66,0x66,0x7C,0x68,0x64,0x66,0x00, # 14: R
 0x3C,0x18,0x18,0x18,0x18,0x18,0x3C,0x00, # 15: I
 0x7E,0x18,0x18,0x18,0x18,0x18,0x18,0x00, # 16: T
 0x18,0x3C,0x66,0x66,0x7E,0x66,0x66,0x00, # 17: A
 0x78,0x6C,0x66,0x66,0x66,0x6C,0x78,0x00, # 18: D
 0x7E,0x60,0x60,0x7C,0x60,0x60,0x7E,0x00, # 19: E
 0x63,0x77,0x7F,0x6B,0x63,0x63,0x63,0x00, # 20: M
 0x7C,0x66,0x66,0x7C,0x60,0x60,0x60,0x00, # 21: P
 0x3C,0x66,0x66,0x66,0x66,0x66,0x3C,0x00  # 22: O
)

# DEV7.1 compact Generic Text mapping. Unsupported characters deliberately
# become spaces; $FF, not character code zero, terminates the generated text.
$headerGlyphMap = @{
 ' ' = 0; '0' = 1; '1' = 2; '2' = 3; '3' = 4; '4' = 5; '5' = 6; '6' = 7; '7' = 8; '8' = 9; '9' = 10; '.' = 11;
 'S' = 12; 'C' = 13; 'R' = 14; 'I' = 15; 'T' = 16; 'A' = 17; 'D' = 18; 'E' = 19; 'M' = 20; 'P' = 21; 'O' = 22
}
$headerBytes = @()
if ($HeaderText.Length -gt 40) {
 throw "HeaderText supports at most 40 characters"
}
foreach ($character in $HeaderText.ToUpperInvariant().ToCharArray()) {
 $key = [string]$character
 if ($headerGlyphMap.ContainsKey($key)) {
  $headerBytes += [int]$headerGlyphMap[$key]
 } else {
  $headerBytes += 0
 }
}
$headerBytes += 0xFF
$headerBytesStr = ($headerBytes | ForEach-Object { ByteHex $_ }) -join ","
$headerOffset = if ($HeaderText.Length -gt 0 -and $HeaderText.Length -lt 40) { [int][Math]::Floor((40 - $HeaderText.Length) / 2) } else { 0 }
$fpsFontByteCount = if ($HeaderText.Length -eq 0) { 0x60 } else { $fpsFontBytes.Count }
$fpsFontBytesEmitted = [int[]]$fpsFontBytes[0..($fpsFontByteCount - 1)]

$QualityProfiles = @{
 turbo = @{ MinFaceArea = 14; ScreenMinSpan = 4; PatternMinSpan = 8 }
 fast = @{ MinFaceArea = 10; ScreenMinSpan = 3; PatternMinSpan = 6 }
 balanced = @{ MinFaceArea = 6; ScreenMinSpan = 2; PatternMinSpan = 3 }
 high = @{ MinFaceArea = 4; ScreenMinSpan = 2; PatternMinSpan = 0 }
}
$QualityConfig = $QualityProfiles[$Quality]
$MinFaceArea = [int]$QualityConfig.MinFaceArea
$ScreenMinSpan = [int]$QualityConfig.ScreenMinSpan
$PatternMinSpan = [int]$QualityConfig.PatternMinSpan
if ($MinFaceAreaOverride -ge 0) {
 if ($MinFaceAreaOverride -gt 255) { throw "MinFaceAreaOverride must be in byte range 0..255" }
 $MinFaceArea = $MinFaceAreaOverride
}
if ($ScreenMinSpanOverride -ge 0) {
 if ($ScreenMinSpanOverride -gt 255) { throw "ScreenMinSpanOverride must be in byte range 0..255" }
 $ScreenMinSpan = $ScreenMinSpanOverride
}
if ($PatternMinSpanOverride -ge 0) {
 if ($PatternMinSpanOverride -gt 255) { throw "PatternMinSpanOverride must be in byte range 0..255" }
 $PatternMinSpan = $PatternMinSpanOverride
}
if ($NoFpsOverlay.IsPresent -and ($FpsOverlay.IsPresent -or $FpsOverlayOnStart.IsPresent)) {
 throw "NoFpsOverlay conflicts with FpsOverlay/FpsOverlayOnStart"
}
if ($FpsCounterOnly.IsPresent -and ($FpsOverlay.IsPresent -or $FpsOverlayOnStart.IsPresent)) {
 throw "FpsCounterOnly conflicts with FpsOverlay/FpsOverlayOnStart"
}
if ($FpsCounterOnly.IsPresent -and $NoFpsOverlay.IsPresent) {
 throw "FpsCounterOnly conflicts with NoFpsOverlay; choose counter-only or complete exclusion"
}
$FpsOverlayEnableFlag = if ($NoFpsOverlay.IsPresent -or $FpsCounterOnly.IsPresent) { 0 } else { 1 }
$FpsCounterOnlyFlag = if ($FpsCounterOnly.IsPresent) { 1 } else { 0 }
$FpsCounterEnableFlag = if ($FpsOverlayEnableFlag -ne 0 -or $FpsCounterOnlyFlag -ne 0) { 1 } else { 0 }
$FpsOverlayOnStartFlag = if ($FpsOverlayEnableFlag -ne 0 -and $FpsOverlayOnStart.IsPresent) { 1 } else { 0 }
$FpsOverlayMemoryContractFlag = 1
$FpsKeyToggleEnableFlag = $FpsOverlayEnableFlag
Update-FpsMemoryLayout $FpsOverlayEnableFlag $HighBasicV2LayoutFlag $GraphicsMode
$ControlSpaceFlag = if ($ControlSpace.IsPresent) { 1 } else { 0 }
$ControlReturnFlag = if ($ControlReturn.IsPresent) { 1 } else { 0 }
$ControlRotationFlag = if ($ControlRotation.IsPresent) { 1 } else { 0 }
$ControlLightFlag = if ($ControlLight.IsPresent) { 1 } else { 0 }
$ControlMaterialFlag = if ($ControlMaterial.IsPresent) { 1 } else { 0 }
$ControlReflectivityFlag = if ($ControlReflectivity.IsPresent) { 1 } else { 0 }
$RandomMaterialCycleFlag = if ($RandomMaterialCycleSeconds -gt 0) { 1 } else { 0 }
$RandomMaterialCycleTicks = if ($RandomMaterialCycleFlag -ne 0) { [int]($RandomMaterialCycleSeconds * 50) } else { 100 }
$GraphicsModeMap = @{
 "1" = 1
 "2" = 2
 "3" = 3
 "4" = 4
 "5" = 5
}
$GraphicsModeKey = $GraphicsMode.Trim().ToLowerInvariant()
$GraphicsModeNumber = [int]$GraphicsModeMap[$GraphicsModeKey]
$Mode4FamilyFlag = if ($GraphicsModeNumber -eq 4 -or $GraphicsModeNumber -eq 5) { 1 } else { 0 }
$ControlLowresFlag = if ($Mode4FamilyFlag -ne 0) { 1 } else { 0 }
$LowresTraceFlag = if ($ControlLowresFlag -ne 0) { 1 } else { 0 }
$Mode5PolygonOutlineFlag = if ($GraphicsModeNumber -eq 5) { 1 } else { 0 }
$SolidSubpixelXQ2Flag = if ($SolidSubpixelXQ2.IsPresent) { 1 } else { 0 }
$SolidSubpixelXNativeFlag = if ($SolidSubpixelXInput -eq "Native") { 1 } else { 0 }
$SolidSubpixelXLegacyDirectFlag = if ($SolidSubpixelXInput -eq "LegacyDirect") { 1 } else { 0 }
$SolidSubpixelYQ2Flag = if ($SolidSubpixelYQ2.IsPresent) { 1 } else { 0 }
$SolidSubpixelYNativeFlag = if ($SolidSubpixelYInput -eq "Native") { 1 } else { 0 }
$SolidSubpixelYLegacyDirectFlag = if ($SolidSubpixelYInput -eq "LegacyDirect") { 1 } else { 0 }
$SolidSubpixelYLegacyBufferedFlag = if ($SolidSubpixelYInput -eq "LegacyBuffered") { 1 } else { 0 }
$SolidSubpixelYLegacyPhase1Flag = if ($SolidSubpixelYInput -eq "LegacyPhase1") { 1 } else { 0 }
$SolidSubpixelYNativeQuantizedFlag = if ($SolidSubpixelYInput -eq "NativeQuantized") { 1 } else { 0 }
$SolidSubpixelYMobileNativeFlag = if ($SolidSubpixelYInput -eq "MobileNative") { 1 } else { 0 }
$SolidSubpixelYBufferedSourceFlag = if ($SolidSubpixelYNativeFlag -ne 0 -or $SolidSubpixelYLegacyBufferedFlag -ne 0 -or $SolidSubpixelYLegacyPhase1Flag -ne 0 -or $SolidSubpixelYNativeQuantizedFlag -ne 0) { 1 } else { 0 }
$SolidSubpixelYEndpointBufferFlag = if ($SolidSubpixelYBufferedSourceFlag -ne 0 -or $SolidSubpixelYMobileNativeFlag -ne 0) { 1 } else { 0 }
$SolidSubpixelYProjectionNativeFlag = if ($SolidSubpixelYNativeFlag -ne 0 -or $SolidSubpixelYNativeQuantizedFlag -ne 0 -or $SolidSubpixelYMobileNativeFlag -ne 0) { 1 } else { 0 }
$SolidSubpixelXYQ2LegacyDirectYFlag = if ($SolidSubpixelXQ2Flag -ne 0 -and $SolidSubpixelXLegacyDirectFlag -ne 0 -and $SolidSubpixelYQ2Flag -ne 0) { 1 } else { 0 }
$Mode4PatternProbeFlag = if ($Mode4PatternProbe.IsPresent) { 1 } else { 0 }
$Mode4PatternProbeLatchedFaceFlag = if ($Mode4PatternProbeLatchedFace.IsPresent) { 1 } else { 0 }
$Mode4ValidShadeFaceProbeFlag = if ($Mode4ValidShadeFaceProbe.IsPresent) { 1 } else { 0 }
$Mode4ShadeStepLimitFlag = if ($Mode4ShadeStepLimit.IsPresent) { 1 } else { 0 }
$YQ2FastDiv11x8Flag = if ($YQ2FastDiv11x8.IsPresent) { 1 } else { 0 }
$YQ2FastPixelConvertFlag = if ($YQ2FastPixelConvert.IsPresent) { 1 } else { 0 }
$YQ2InlineBoundsFlag = if ($YQ2InlineBounds.IsPresent) { 1 } else { 0 }
$Mode4FaceIdLatchFlag = if ($SolidSubpixelXYQ2LegacyDirectYFlag -ne 0) { 1 } else { 0 }
if (($Mode4PatternProbeFlag + $Mode4PatternProbeLatchedFaceFlag + $Mode4ValidShadeFaceProbeFlag) -gt 1) {
 throw "Mode4PatternProbe, Mode4PatternProbeLatchedFace and Mode4ValidShadeFaceProbe are mutually exclusive."
}
$VideoStandardKey = $VideoStandard.Trim().ToLowerInvariant()
$VideoStandardAutoFlag = if ($VideoStandardKey -eq "auto") { 1 } else { 0 }
$VideoStandardForcePalFlag = if ($VideoStandardKey -eq "pal") { 1 } else { 0 }
$VideoStandardForceNtscFlag = if ($VideoStandardKey -eq "ntsc") { 1 } else { 0 }
$VideoStandardRuntimeDetectFlag = $VideoStandardAutoFlag
$VideoStandardInitial = if ($VideoStandardForceNtscFlag -ne 0) { 1 } else { 0 }
$VideoVblanksPerSecondInitial = if ($VideoStandardForceNtscFlag -ne 0) { 60 } else { 50 }
$EngineWireModeRuntimeFlag = if ($RendererActiveFlag -ne 0 -and ($GraphicsModeNumber -eq 1 -or $GraphicsModeNumber -eq 2)) { 1 } else { 0 }
$EngineWireSpeedPass1Flag = $EngineWireModeRuntimeFlag
$EngineWireSpeedPass2Flag = $EngineWireModeRuntimeFlag
$EngineWireSpeedPass3Flag = $EngineWireModeRuntimeFlag
$EngineWireDirtyClearFlag = $EngineWireSpeedPass1Flag
$EngineWireSolidFeaturesStrippedFlag = $EngineWireSpeedPass1Flag
$EngineMode1WirePureRuntimeFlag = if ($EngineWireModeRuntimeFlag -ne 0 -and $GraphicsModeNumber -eq 1) { 1 } else { 0 }
$EngineMode2HiddenWireRuntimeFlag = if ($EngineWireModeRuntimeFlag -ne 0 -and $GraphicsModeNumber -eq 2) { 1 } else { 0 }
$Mode2FaceBucketPipelineFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { 1 } else { 0 }
$Mode1MemorySpecializationFlag = if ($GraphicsModeNumber -eq 1) { 1 } else { 0 }
$Mode2MemorySpecializationFlag = if ($GraphicsModeNumber -eq 2 -and $Mode2FaceBucketPipelineFlag -ne 0) { 1 } else { 0 }
$EngineWireCellWriteSkipSameFlag = $EngineWireSpeedPass2Flag
$EngineWireMaterialCacheResetFrameFlag = $EngineWireSpeedPass2Flag
$EngineMode2MaskColorWritesStrippedFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { 1 } else { 0 }
$EngineWireLightShadingStrippedFlag = $EngineWireSpeedPass3Flag
# keep material identity outside the hot wire-pixel loop.
# The same-cell cache is invalidated only at explicit material transitions.
$EngineWireEdgeMaterialContextFlag = $EngineWireModeRuntimeFlag
$EngineWireMaterialCacheInvalidateOnChangeFlag = $EngineWireEdgeMaterialContextFlag
$EngineWireMaterialCompareStrippedFlag = $EngineWireEdgeMaterialContextFlag
# strip the runtime face pass from engine GraphicsMode 1 while keeping the existing wire-edge renderer.
# The edge list is generated from faces at build time, so no new ASM routines or ENGINE changes are introduced.
$EngineMode1FacePassStrippedFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { 1 } else { 0 }
$EngineMode1EdgeTableDirectFlag = 0
$EngineMode1FaceEdgeListOnlyFlag = $EngineMode1FacePassStrippedFlag
# fast path for fully visible engine mode-1 edges.
# It bypasses the generic polygon clipper and the post-clip guard only when both raw endpoints are already inside the viewport.
# The validated clipper/guard path remains the fallback for border crossings and camera-through-mesh cases.
$EngineMode1WireFastPlotFlag = $EngineMode1WirePureRuntimeFlag
$EngineMode1WireInScreenFastPathFlag = $EngineMode1WireFastPlotFlag
$EngineMode1WireClipFallbackFlag = $EngineMode1WireFastPlotFlag
# universal engine mode-1 edge traversal for every mesh.
# Camera-dependent activation is resolved after the effective camera mode is known.
$EngineMode1UniversalEdgeTraversalFlag = 0
$EngineMode1ProjdoneDirectTestFlag = 0
$EngineMode1VertexDrawableFallbackFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { 1 } else { 0 }
# shorten the universal engine mode-1 point raster hot loop.
# Valid edge endpoints are already guaranteed by the in-screen fast path or clip fallback.
$EngineMode1WireRasterHotloopFlag = $EngineMode1WirePureRuntimeFlag
$EngineMode1WirePointBoundsStrippedFlag = $EngineMode1WireRasterHotloopFlag
$EngineMode1WirePointDirectEntryFlag = $EngineMode1WireRasterHotloopFlag
$EngineMode1MaterialCellRowCacheFlag = $EngineMode1WireRasterHotloopFlag
$EngineMode1MaterialStartbyteReuseFlag = $EngineMode1WireRasterHotloopFlag
# port only the safe universal wire hot-loop reductions to engine mode 2.
# Normal visible-face edges are already known to be inside the viewport when clip_poly_active=0;
# clipped polygons retain the guarded fallback. The shared point plotter reuses dirty/material cell state.
$EngineMode2WireRasterHotloopFlag = $EngineMode2HiddenWireRuntimeFlag
$EngineMode2WirePointBoundsStrippedFlag = $EngineMode2WireRasterHotloopFlag
$EngineMode2MaterialCellRowCacheFlag = $EngineMode2WireRasterHotloopFlag
$EngineMode2MaterialStartbyteReuseFlag = $EngineMode2WireRasterHotloopFlag
$EngineMode2WireFaceEdgeDirectDrawFlag = $EngineMode2WireRasterHotloopFlag
$EngineMode2WireClipGuardFallbackFlag = $EngineMode2WireRasterHotloopFlag
# group consecutive pixels belonging to the same scanline for shallow engine wire edges.
# Horizontal runs update dirty/material state once and use the existing validated horizontal-span writer.
# Vertical, diagonal, steep and horizon-mask traces retain the point rasterizer as fallback.
$EngineWireScanlineRunRasterizerFlag = $EngineWireModeRuntimeFlag
$EngineWireScanlineRunShallowOnlyFlag = $EngineWireScanlineRunRasterizerFlag
$EngineWireScanlineRunPointFallbackFlag = $EngineWireScanlineRunRasterizerFlag
$EngineWireScanlineRunEndpointStatePreservedFlag = $EngineWireScanlineRunRasterizerFlag
$EngineMode1ScanlineRunRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $EngineWireScanlineRunRasterizerFlag } else { 0 }
$EngineMode2ScanlineRunRuntimeFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { $EngineWireScanlineRunRasterizerFlag } else { 0 }
# group vertical and strongly steep wire pixels into same-column runs.
# The path is universal for every mesh and activates only when dy >= 2*dx.
# Shallower/diagonal lines and mode-2 bounds/mask traces retain the validated point path.
$EngineWireSteepLineFastpathFlag = $EngineWireModeRuntimeFlag
$EngineWireSteepRatio2To1Flag = $EngineWireSteepLineFastpathFlag
$EngineWireVerticalRunWriterFlag = $EngineWireSteepLineFastpathFlag
$EngineWireSteepPointFallbackFlag = $EngineWireSteepLineFastpathFlag
$EngineWireSteepEndpointStatePreservedFlag = $EngineWireSteepLineFastpathFlag
$EngineMode1SteepLineRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $EngineWireSteepLineFastpathFlag } else { 0 }
$EngineMode2SteepLineRuntimeFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { $EngineWireSteepLineFastpathFlag } else { 0 }
# update dirty/material state only when the point path crosses a real byte/cell transition.
# Exact same bitmap row/byte repeats skip dirty min/max work; unchanged material cells bypass the material JSR.
# Scanline/vertical run writers keep their existing range-level updates.
$EngineWireCellTransitionUpdatesFlag = $EngineWireModeRuntimeFlag
$EngineWireDirtySameByteSkipFlag = $EngineWireCellTransitionUpdatesFlag
$EngineWireMaterialCallOnCellChangeFlag = $EngineWireCellTransitionUpdatesFlag
$EngineWireMaterialDirectWriteEntryFlag = $EngineWireCellTransitionUpdatesFlag
$EngineWireTransitionCacheResetFrameFlag = $EngineWireCellTransitionUpdatesFlag
$EngineMode1CellTransitionRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $EngineWireCellTransitionUpdatesFlag } else { 0 }
$EngineMode2CellTransitionRuntimeFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { $EngineWireCellTransitionUpdatesFlag } else { 0 }
# use an 8-bit connected Bresenham loop for the remaining intermediate wire slopes.
# Scanline-run already handles dx >= dy; vertical-run handles dy >= 2*dx.
# Therefore this path receives only dx < dy < 2*dx, where err+dx stays below 256.
# Mode-2 bounds/mask traces and all non-engine paths retain the original 16-bit tracer.
$EngineWire8BitBresenhamFlag = $EngineWireModeRuntimeFlag
$EngineWire8BitIntermediateSlopesFlag = $EngineWire8BitBresenhamFlag
$EngineWire8BitErrorAccumulatorFlag = $EngineWire8BitBresenhamFlag
$EngineWire16BitTraceFallbackFlag = $EngineWire8BitBresenhamFlag
$EngineMode1Bresenham8RuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $EngineWire8BitBresenhamFlag } else { 0 }
$EngineMode2Bresenham8RuntimeFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { $EngineWire8BitBresenhamFlag } else { 0 }
# consolidate the engine-wire slope dispatcher without changing any raster algorithm.
# One ordered classifier selects scanline-run, vertical-run or 8-bit Bresenham.
# Hidden-wire bounds/mask traces are rejected once before slope classification and retain the 16-bit trace fallback.
$EngineWireRasterConsolidationFlag = if (($EngineWireScanlineRunRasterizerFlag -ne 0) -and ($EngineWireSteepLineFastpathFlag -ne 0) -and ($EngineWire8BitBresenhamFlag -ne 0)) { $EngineWireModeRuntimeFlag } else { 0 }
$EngineWireSingleSlopeDispatchFlag = $EngineWireRasterConsolidationFlag
$EngineWireSingleTraceGateFlag = $EngineWireRasterConsolidationFlag
$EngineWireTraceFallbackFlag = $EngineWireRasterConsolidationFlag
$EngineMode1RasterConsolidationRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $EngineWireRasterConsolidationFlag } else { 0 }
$EngineMode2RasterConsolidationRuntimeFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { $EngineWireRasterConsolidationFlag } else { 0 }
# engine mode 2 clears only the horizontal ground-horizon row inside visible faces.
# The existing full face-mask routine remains compiled as a runtime fallback.
$EngineMode2HorizonRowMaskCandidateFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { 1 } else { 0 }
$EngineMode2HorizonRowMaskRuntimeFlag = 0
$VicColorPolicyKey = $VicColorPolicy.Trim().ToLowerInvariant()
$RequestedVicColorPolicyKey = $VicColorPolicyKey
$VicColorPolicyEnableFlag = if ($VicColorPolicyKey -eq "off") { 0 } else { 1 }
$VicColorPolicyActiveFlag = if ($VicColorPolicyKey -eq "active" -or $VicColorPolicyKey -eq "active-overlay") { 1 } else { 0 }
$VicColorPolicyOverlayFlag = if ($VicColorPolicyKey -eq "overlay" -or $VicColorPolicyKey -eq "active-overlay") { 1 } else { 0 }
$RequestedVicColorPolicyEnableFlag = $VicColorPolicyEnableFlag
$RequestedVicColorPolicyActiveFlag = $VicColorPolicyActiveFlag
$EngineWireVicPolicyForcedOffFlag = if ($EngineWireModeRuntimeFlag -ne 0) { 1 } else { 0 }
if ($EngineWireVicPolicyForcedOffFlag -ne 0) {
 $VicColorPolicyKey = "off"
 $VicColorPolicyEnableFlag = 0
 $VicColorPolicyActiveFlag = 0
 $VicColorPolicyOverlayFlag = 0
}
$VicColorPolicyEffectiveEnableFlag = $VicColorPolicyEnableFlag
$VicColorPolicyEffectiveActiveFlag = $VicColorPolicyActiveFlag
$VicColorFallbackKey = $VicColorFallback.Trim().ToLowerInvariant()
$VicColorFallbackMap = @{
 "first" = 0
 "last" = 1
 "wire" = 2
 "compat" = 3
}
$VicColorFallbackMode = [int]$VicColorFallbackMap[$VicColorFallbackKey]
$RuntimeGraphicsModeSwitchFlag = if ($RuntimeGraphicsModeSwitch.IsPresent) { 1 } else { 0 }
if ($RuntimeGraphicsModeSwitch.IsPresent) {
 throw "RuntimeGraphicsModeSwitch is not implemented; select GraphicsMode at build time."
}
$WireOnlyRenderFlag = if ($GraphicsModeNumber -eq 1 -or $GraphicsModeNumber -eq 2) { 1 } else { 0 }
$WireRenderFlag = $WireOnlyRenderFlag
$HiddenWireFlag = if ($GraphicsModeNumber -eq 2) { 1 } else { 0 }
$WireFaceEdgeFlag = 0
$WireOverlayFlag = 0
$PolyFillFlag = if ($WireOnlyRenderFlag -ne 0) { 0 } else { 1 }
$WirePureFlag = if ($GraphicsModeNumber -eq 1) { 1 } else { 0 }
$FaceRenderEnableFlag = if (($WireOnlyRenderFlag -ne 0) -or ($PolyFillFlag -ne 0)) { 1 } else { 0 }
$StaticShadeCacheFlag = if ($GraphicsModeNumber -eq 3 -and -not $NoStaticShade.IsPresent) { 1 } else { 0 }
$FullDynamicShadeFlag = if ($Mode4FamilyFlag -ne 0) { 1 } else { 0 }
if ($EngineMode1WirePureRuntimeFlag -ne 0) {
 $WireRenderFlag = 1
 $HiddenWireFlag = 0
 $WireOverlayFlag = 0
 $PolyFillFlag = 0
 $WirePureFlag = 1
 # Keep FACE_RENDER_ENABLE compiled because it currently gates shared wire/clip/dirty-clear helpers.
 # The engine mode 1 dispatcher still bypasses the runtime face traversal below.
 $FaceRenderEnableFlag = 1
 $StaticShadeCacheFlag = 0
 $FullDynamicShadeFlag = 0
}
if ($EngineMode2HiddenWireRuntimeFlag -ne 0) {
 $WireRenderFlag = 1
 $HiddenWireFlag = 1
 $WireOverlayFlag = 0
 $PolyFillFlag = 0
 $WirePureFlag = 0
 $StaticShadeCacheFlag = 0
 $FullDynamicShadeFlag = 0
}
$StaticShadeDirectFlag = if ($StaticShadeCacheFlag -ne 0) { 1 } else { 0 }
$FrameFaceFillCacheFlag = 0
$FullClearFlag = if ($ClearMode -eq "full") { 1 } else { 0 }
if ($WireOnlyRenderFlag -ne 0) {
 $FullClearFlag = 1
}
if ($EngineWireDirtyClearFlag -ne 0) {
 $FullClearFlag = 0
}
$ValidCameraModes = @("fixed", "walkLite", "walkFull")
$RequestedCameraMode = $CameraMode.Trim()
if ($RequestedCameraMode.Length -gt 0 -and -not ($ValidCameraModes -contains $RequestedCameraMode)) {
 throw "CameraMode must be one of: fixed, walkLite, walkFull"
}
$DynamicLightFlag = if ($DynamicLight.IsPresent) { 1 } else { 0 }
$StaticPoseFlag = if ($StaticPose.IsPresent) { 1 } else { 0 }
$LightPulseOnSpaceFlag = if ($LightPulseOnSpace.IsPresent) { 1 } else { 0 }
$ReferenceProjectionFlag = if ($Projection -eq "reference") { 1 } else { 0 }
$ExtendedTableProjectionFlag = if ($Projection -eq "extended-table") { 1 } else { 0 }
$MotionZStartOnReturnFlag = if ($MotionZStartOnReturn.IsPresent) { 1 } else { 0 }
$MotionZStartOnZeroFlag = if ($MotionZStartOnZero.IsPresent) { 1 } else { 0 }
$MotionZStartGateFlag = if ($MotionZStartOnReturnFlag -ne 0 -or $MotionZStartOnZeroFlag -ne 0) { 1 } else { 0 }
$ControlZeroMotionFlag = if ($MotionZStartOnZeroFlag -ne 0) { 1 } else { 0 }
if ($AutoCycleFrames -lt 0 -or $AutoCycleFrames -gt 255) {
 throw "AutoCycleFrames must be in byte range 0..255"
}
foreach ($motionValue in @($MotionZStart256, $MotionZStep256)) {
 if ($motionValue -lt 0 -or $motionValue -gt 16777215) {
 throw "MotionZStart256 and MotionZStep256 must be unsigned 16.8 values in range 0..16777215"
 }
}
$MotionZStartFrac = $MotionZStart256 -band 255
$MotionZStartLo = ($MotionZStart256 -shr 8) -band 255
$MotionZStartHi = ($MotionZStart256 -shr 16) -band 255
$MotionZStepFrac = $MotionZStep256 -band 255
$MotionZStepLo = ($MotionZStep256 -shr 8) -band 255
$MotionZStepHi = ($MotionZStep256 -shr 16) -band 255
if ($LightTickDiv -lt 1 -or $LightTickDiv -gt 255) {
 throw "LightTickDiv must be in byte range 1..255"
}
if ($LightStaticPhase -ge $LightPhaseCount) {
 throw "LightStaticPhase must be -1 or less than LightPhaseCount"
}
if ($LightStaticPhase -lt -1) {
 throw "LightStaticPhase must be -1 or less than LightPhaseCount"
}
$MaterialScalePath = Join-Path $Root "tools\c64_material_scales.generated.json"
if (-not (Test-Path -LiteralPath $MaterialScalePath)) {
 throw "Material scale table not found: $MaterialScalePath. Run tools\generate_c64_material_scales.py first."
}
$MaterialScaleDoc = Get-Content -LiteralPath $MaterialScalePath -Raw | ConvertFrom-Json
if ([int]$MaterialScaleDoc.schema -ne 2) {
 throw "Unsupported material scale schema in $MaterialScalePath"
}
$MaterialFamilies = @($MaterialScaleDoc.families)
$MaterialReflectivityLevels = @($MaterialScaleDoc.reflectivityLevels)
$MaterialCount = [int]$MaterialFamilies.Count
if ($MaterialCount -ne 10) {
 throw "The runtime keyboard material selector expects exactly 10 material families."
}
if ($Reflectivity -lt 0 -or $Reflectivity -ge $MaterialReflectivityLevels.Count) {
 throw "Reflectivity $Reflectivity is not available in $MaterialScalePath"
}
$MaterialReflectivityOffset = $Reflectivity * $MaterialCount
$MaterialIndex = -1
for ($i = 0; $i -lt $MaterialFamilies.Count; $i++) {
 if ([string]$MaterialFamilies[$i].name -eq $MaterialFamily) {
 $MaterialIndex = $i
 break
 }
}
if ($MaterialIndex -lt 0) {
 throw "Unknown material family: $MaterialFamily"
}
$MaterialScreenBytes = @()
$MaterialColorBytes = @()
foreach ($reflectivityLevel in $MaterialReflectivityLevels) {
 $reflectivityIndex = [int]$reflectivityLevel.index
 foreach ($family in $MaterialFamilies) {
 $ramp = @($family.ramps) | Where-Object { [int]$_.reflectivity -eq $reflectivityIndex } | Select-Object -First 1
 if ($null -eq $ramp) {
 throw "Missing reflectivity $reflectivityIndex ramp for material family $($family.name)"
 }
 $dark = [int]$ramp.dark
 $high = [int]$ramp.high
 $highlight = [int]$ramp.highlight
 foreach ($color in @($dark, $high, $highlight)) {
 if ($color -eq 0) { throw "Material family must not use black for face colors: $($family.name)" }
 if ($color -lt 0 -or $color -gt 15) { throw "Material color out of C64 palette range: $($family.name)" }
 }
 $screenByte = (($dark -shl 4) -bor $high)
 if ($screenByte -ne [int]$ramp.screenByte) {
 throw "Generated screen byte mismatch for material family $($family.name), reflectivity $reflectivityIndex"
 }
 if ($highlight -ne [int]$ramp.colorRam) {
 throw "Generated color RAM mismatch for material family $($family.name), reflectivity $reflectivityIndex"
 }
 $MaterialScreenBytes += $screenByte
 $MaterialColorBytes += $highlight
 }
}
$MaterialScreenByte = [int]$MaterialScreenBytes[$MaterialReflectivityOffset + $MaterialIndex]
$MaterialColorByte = [int]$MaterialColorBytes[$MaterialReflectivityOffset + $MaterialIndex]

function Resolve-MaterialFamilyIndex([object]$Value, [string]$Context) {
 if ($null -eq $Value) {
 return 255
 }

 $s = ([string]$Value).Trim()
 if ($s.Length -eq 0 -or
 $s -ieq "active" -or
 $s -ieq "global" -or
 $s -ieq "variable" -or
 $s -ieq "default") {
 return 255
 }

 $numeric = 0
 if ([int]::TryParse($s, [ref]$numeric)) {
 if ($numeric -ge 0 -and $numeric -lt $MaterialFamilies.Count) {
 return $numeric
 }
 throw "Material index out of range for ${Context}: $numeric"
 }

 for ($i = 0; $i -lt $MaterialFamilies.Count; $i++) {
 if ([string]$MaterialFamilies[$i].name -ieq $s) {
 return $i
 }
 }

 $valid = ($MaterialFamilies | ForEach-Object { [string]$_.name }) -join ", "
 throw "Unknown material family for ${Context}: '$s'. Use active/global/variable or one of: $valid"
}

function Read-SceneObjectMaterial([object]$Object, [string]$ObjectName) {
 if (Has-Property $Object "materialOverride") {
 return Resolve-MaterialFamilyIndex (Get-PropertyValue $Object "materialOverride") "scene object '$ObjectName' materialOverride"
 }
 if (Has-Property $Object "materialFamily") {
 return Resolve-MaterialFamilyIndex (Get-PropertyValue $Object "materialFamily") "scene object '$ObjectName'"
 }
 if (Has-Property $Object "material") {
 return Resolve-MaterialFamilyIndex (Get-PropertyValue $Object "material") "scene object '$ObjectName'"
 }
 return 255
}

function Resolve-ReflectivityOffset([object]$Value, [string]$Context) {
 if ($null -eq $Value) {
 return 255
 }

 $s = ([string]$Value).Trim()
 if ($s.Length -eq 0 -or
 $s -ieq "active" -or
 $s -ieq "global" -or
 $s -ieq "variable" -or
 $s -ieq "default") {
 return 255
 }

 $numeric = 0
 if ([int]::TryParse($s, [ref]$numeric)) {
 if ($numeric -ge 0 -and $numeric -lt $MaterialReflectivityLevels.Count) {
 return ($numeric * $MaterialCount)
 }
 throw "Reflectivity index out of range for ${Context}: $numeric"
 }

 for ($i = 0; $i -lt $MaterialReflectivityLevels.Count; $i++) {
 if ([string]$MaterialReflectivityLevels[$i].name -ieq $s) {
 return ([int]$MaterialReflectivityLevels[$i].index * $MaterialCount)
 }
 }

 $valid = ($MaterialReflectivityLevels | ForEach-Object { "$([int]$_.index)/$([string]$_.name)" }) -join ", "
 throw "Unknown reflectivity for ${Context}: '$s'. Use active/global/variable or one of: $valid"
}

function Read-SceneObjectReflectivity([object]$Object, [string]$ObjectName) {
 if (Has-Property $Object "reflectivityOverride") {
 return Resolve-ReflectivityOffset (Get-PropertyValue $Object "reflectivityOverride") "scene object '$ObjectName' reflectivityOverride"
 }
 if (Has-Property $Object "materialReflectivity") {
 return Resolve-ReflectivityOffset (Get-PropertyValue $Object "materialReflectivity") "scene object '$ObjectName'"
 }
 if (Has-Property $Object "reflectivity") {
 return Resolve-ReflectivityOffset (Get-PropertyValue $Object "reflectivity") "scene object '$ObjectName'"
 }
 return 255
}

function Read-SceneObjectColorOverride([object]$Object, [string]$ObjectName) {
 if (Has-Property $Object "colorOverride") {
 return Read-C64Color (Get-PropertyValue $Object "colorOverride") "scene object '$ObjectName' colorOverride"
 }
 return 255
}

function Resolve-FaceMaterialFamily([object]$Value, [string]$Context) {
 if ($null -eq $Value) {
 return -1
 }

 $s = ([string]$Value).Trim()
 if ($s.Length -eq 0 -or
 $s -ieq "active" -or
 $s -ieq "global" -or
 $s -ieq "variable" -or
 $s -ieq "default") {
 return -1
 }

 return Resolve-MaterialFamilyIndex $Value $Context
}

function Resolve-FaceSolidColor([object]$Value, [string]$Context) {
 if ($null -eq $Value) {
 return -1
 }

 $s = ([string]$Value).Trim()
 if ($s.Length -eq 0 -or
 $s -ieq "off" -or
 $s -ieq "none" -or
 $s -ieq "default") {
 return -1
 }

 return Read-C64Color $Value $Context
}

function Read-SceneObjectWireColor([object]$Object, [string]$ObjectName) {
 if (Has-Property $Object "wireColor") {
 return Read-WireColor (Get-PropertyValue $Object "wireColor") "scene object '$ObjectName'"
 }
 return -1
}

function Read-SceneObjectVisible([object]$Object, [string]$ObjectName) {
 if (-not (Has-Property $Object "visible")) {
 return 1
 }

 $value = Get-PropertyValue $Object "visible"
 if ($value -is [bool]) {
 return $(if ($value) { 1 } else { 0 })
 }

 $s = ([string]$value).Trim()
 if ($s.Length -eq 0 -or $s -ieq "true" -or $s -ieq "yes" -or $s -ieq "on" -or $s -eq "1") {
 return 1
 }
 if ($s -ieq "false" -or $s -ieq "no" -or $s -ieq "off" -or $s -eq "0") {
 return 0
 }

 throw "visible must be boolean for scene object '$ObjectName'"
}
$MeshName = ""
$MeshVertices = @()
$MeshFaces = @()
$MeshFaceMaterials = @()
$MeshFaceMaterialFamilies = @()
$MeshFaceSolidColors = @()
$MeshFaceSolidColorUse = @()
$MeshFaceVertexCounts = @()
$MeshWireEdges = @()
$MeshRecords = @()
$SceneObjects = @()
$SceneCameraObject = $null
$SceneLightObjects = @()
$SceneTimelineObject = $null
$SceneGraphicIncludePath = ""
$SceneGraphicIncludeText = ""
$SceneSourceSharingRequested = $false
$SceneAxisConvention = "engine-y-up"
$WorldBackgroundColor = 0
$WorldGrounds = @()
$VertexMap = @{}
$CurrentMeshName = ""
$CurrentMeshFirstVertex = 0
$CurrentMeshFirstFace = 0
$CurrentMeshFirstWireEdge = 0
$CurrentMeshIsWire = $false
$CurrentMeshMaterialProfile = "single"
$CurrentMeshWireColor = -1

function Reset-Mesh {
 $script:MeshVertices = @()
 $script:MeshFaces = @()
 $script:MeshFaceMaterials = @()
 $script:MeshFaceMaterialFamilies = @()
 $script:MeshFaceSolidColors = @()
 $script:MeshFaceSolidColorUse = @()
 $script:MeshFaceVertexCounts = @()
 $script:MeshWireEdges = @()
 $script:MeshRecords = @()
 $script:SceneObjects = @()
 $script:SceneCameraObject = $null
 $script:SceneLightObjects = @()
 $script:SceneTimelineObject = $null
 $script:SceneGraphicIncludePath = ""
 $script:SceneGraphicIncludeText = ""
 $script:SceneSourceSharingRequested = $false
 $script:SceneAxisConvention = "engine-y-up"
 $script:WorldBackgroundColor = 0
 $script:WorldGrounds = @()
 $script:VertexMap = @{}
}

function Begin-MeshRecord([string]$name) {
 $script:CurrentMeshName = $name
 $script:CurrentMeshFirstVertex = $script:MeshVertices.Count
 $script:CurrentMeshFirstFace = $script:MeshFaces.Count
 $script:CurrentMeshFirstWireEdge = $script:MeshWireEdges.Count
 $script:CurrentMeshIsWire = $false
 $script:CurrentMeshMaterialProfile = "single"
 $script:CurrentMeshWireColor = -1
 $script:VertexMap = @{}
}

function Test-CurrentMeshHasPerFaceMaterialFamilies {
 $firstFace = [int]$script:CurrentMeshFirstFace
 $faceCount = [int]($script:MeshFaces.Count - $firstFace)
 if ($faceCount -le 0) {
 return $false
 }
 for ($i = 0; $i -lt $faceCount; $i++) {
 if ([int]$script:MeshFaceMaterialFamilies[$firstFace + $i] -ge 0) {
 return $true
 }
 }
 return $false
}

function End-MeshRecord([string]$name = "") {
 $recordName = if ($name.Trim().Length -gt 0) { $name } else { $script:CurrentMeshName }
 $vertexCount = $script:MeshVertices.Count - $script:CurrentMeshFirstVertex
 $faceCount = $script:MeshFaces.Count - $script:CurrentMeshFirstFace
 $wireEdgeCount = $script:MeshWireEdges.Count - $script:CurrentMeshFirstWireEdge
 if ($vertexCount -le 0 -or ($faceCount -le 0 -and $wireEdgeCount -le 0)) {
 throw "Mesh record has no renderable data: $recordName"
 }
 if ((-not $script:CurrentMeshIsWire) -and $faceCount -le 0) {
 throw "Polygon mesh record has no faces: $recordName"
 }
 if ($script:CurrentMeshIsWire -and ($script:CurrentMeshWireColor -lt 0 -or $script:CurrentMeshWireColor -gt 15)) {
 throw "Wire mesh record must define color 0..15: $recordName"
 }
 if ((-not $script:CurrentMeshIsWire) -and [string]$script:CurrentMeshMaterialProfile -eq "multimaterial" -and -not (Test-CurrentMeshHasPerFaceMaterialFamilies)) {
 throw "Multimaterial mesh profile requires faceMaterialFamilies/materialFamilies/faceMaterials for each rendered face: $recordName"
 }
 $script:MeshRecords += ,[pscustomobject]@{
 Name = $recordName
 FirstVertex = $script:CurrentMeshFirstVertex
 VertexCount = $vertexCount
 FirstFace = $script:CurrentMeshFirstFace
 FaceCount = $faceCount
 FirstWireEdge = $script:CurrentMeshFirstWireEdge
 WireEdgeCount = $wireEdgeCount
 IsWire = [bool]$script:CurrentMeshIsWire
 GeometryKind = $(if ($script:CurrentMeshIsWire) { "wire" } else { "solid" })
 MaterialProfile = $(if ($script:CurrentMeshIsWire) { "single" } else { $script:CurrentMeshMaterialProfile })
 WireColor = [int]$script:CurrentMeshWireColor
 }
}

function Add-MeshVertex([int]$x, [int]$y, [int]$z) {
 $key = "$x,$y,$z"
 if ($script:VertexMap.ContainsKey($key)) {
 return [int]$script:VertexMap[$key]
 }
 $idx = $script:MeshVertices.Count
 $script:MeshVertices += ,@($x, $y, $z)
 $script:VertexMap[$key] = $idx
 return [int]$idx
}

function V([int]$x, [int]$y, [int]$z) {
 return Add-MeshVertex $x $y $z
}

function Add-Face([int]$a, [int]$b, [int]$c, [int]$d = -1, [int]$material = -1, [int]$vertexCount = 4, [int]$materialFamily = -1, [int]$solidColor = -1, [int]$solidColorUse = 0) {
 if ($vertexCount -ne 3 -and $vertexCount -ne 4) {
 throw "Face vertex count must be 3 or 4"
 }
 if ($vertexCount -eq 4 -and $d -lt 0) {
 throw "Quad faces require a fourth vertex index"
 }
 $face = if ($vertexCount -eq 4) { @($a, $b, $c, $d) } else { @($a, $b, $c) }
 $script:MeshFaces += ,$face
 $script:MeshFaceMaterials += [int]$material
 $script:MeshFaceMaterialFamilies += [int]$materialFamily
 $script:MeshFaceSolidColors += [int]$solidColor
 $script:MeshFaceSolidColorUse += [int]$solidColorUse
 $script:MeshFaceVertexCounts += [int]$vertexCount
}

function Add-WireEdge([int]$a, [int]$b) {
 if (-not $script:CurrentMeshIsWire) {
 throw "Cannot add wire edge to polygon mesh: $script:CurrentMeshName"
 }
 if ($a -lt 0 -or $b -lt 0 -or $a -eq $b) {
 throw "Wire edge must reference two distinct vertices"
 }
 $script:MeshWireEdges += ,@($a, $b)
}

function Get-LitFaceShade([int[]]$face) {
 $p0 = $script:MeshVertices[$face[0]]
 $p1 = $script:MeshVertices[$face[1]]
 $p2 = $script:MeshVertices[$face[2]]

 $ax = [int]$p1[0] - [int]$p0[0]
 $ay = [int]$p1[1] - [int]$p0[1]
 $az = [int]$p1[2] - [int]$p0[2]
 $bx = [int]$p2[0] - [int]$p0[0]
 $by = [int]$p2[1] - [int]$p0[1]
 $bz = [int]$p2[2] - [int]$p0[2]

 $nx = $ay * $bz - $az * $by
 $ny = $az * $bx - $ax * $bz
 $nz = $ax * $by - $ay * $bx

 $len = [Math]::Sqrt($nx * $nx + $ny * $ny + $nz * $nz)
 if ($len -lt 1.0) {
 return 2
 }

 $lx = -0.40
 $ly = 0.60
 $lz = -0.70
 $llen = [Math]::Sqrt($lx * $lx + $ly * $ly + $lz * $lz)
 $dot = (($nx * $lx) + ($ny * $ly) + ($nz * $lz)) / ($len * $llen)

 if ($dot -ge 0.62) { return 6 }
 if ($dot -ge 0.22) { return 4 }
 if ($dot -ge -0.62) { return 2 }
 return 0
}

function Get-FaceCenterY([int[]]$face) {
 $sum = 0
 foreach ($idx in $face) {
 $sum += [int]$script:MeshVertices[$idx][1]
 }
 return $sum / [double]$face.Count
}

function Get-GeneralFaceMaterial([int[]]$face, [double]$meshMidY) {
 $litShade = Get-LitFaceShade $face
 $shade = if ($litShade -ge 4) { 2 } else { 0 }

 if ((Get-FaceCenterY $face) -lt $meshMidY) {
 $shade = $shade -bor 0x80
 }

 return $shade
}

function Get-FaceShadeGeometry([int]$faceIndex) {
 $face = [int[]]$script:MeshFaces[$faceIndex]
 $faceArity = [int]$script:MeshFaceVertexCounts[$faceIndex]
 $facePoints = @()
 for ($faceVertexIndex = 0; $faceVertexIndex -lt $faceArity; $faceVertexIndex++) {
 $vertexIndex = [int]$face[$faceVertexIndex]
 $facePoints += ,([double[]]@(
 [double]$script:MeshVertices[$vertexIndex][0],
 [double]$script:MeshVertices[$vertexIndex][1],
 [double]$script:MeshVertices[$vertexIndex][2]
 ))
 }

 $nx = 0.0
 $ny = 0.0
 $nz = 0.0
 for ($faceVertexIndex = 0; $faceVertexIndex -lt $facePoints.Count; $faceVertexIndex++) {
 $p = [double[]]$facePoints[$faceVertexIndex]
 $q = [double[]]$facePoints[($faceVertexIndex + 1) % $facePoints.Count]
 $nx += ($p[1] - $q[1]) * ($p[2] + $q[2])
 $ny += ($p[2] - $q[2]) * ($p[0] + $q[0])
 $nz += ($p[0] - $q[0]) * ($p[1] + $q[1])
 }
 $normal = Normalize-Vector ([double[]]@($nx, $ny, $nz))

 $cx = 0.0
 $cy = 0.0
 $cz = 0.0
 foreach ($point in $facePoints) {
 $cx += $point[0]
 $cy += $point[1]
 $cz += $point[2]
 }
 $cx = ($cx / [double]$faceArity) / 2.0
 $cy = ($cy / [double]$faceArity) / 2.0
 $cz = ($cz / [double]$faceArity) / 2.0

 $qnx = Clamp-SignedByte ([int][Math]::Round($normal[0] * 63.0)) -63 63
 $qny = Clamp-SignedByte ([int][Math]::Round($normal[1] * 63.0)) -63 63
 $qnz = Clamp-SignedByte ([int][Math]::Round($normal[2] * 63.0)) -63 63
 $qcx = Clamp-SignedByte ([int][Math]::Round($cx)) -63 63
 $qcy = Clamp-SignedByte ([int][Math]::Round($cy)) -63 63
 $qcz = Clamp-SignedByte ([int][Math]::Round($cz)) -63 63

 return [pscustomobject]@{
 Normal = $normal
 QNormal = [int[]]@($qnx, $qny, $qnz)
 QCenter = [int[]]@($qcx, $qcy, $qcz)
 }
}

function Get-RotatedFaceNormalQ([double[]]$normal, [object[]]$rotationFixed) {
 $pitch = (([int]$rotationFixed[0]) -shr 8) -band 255
 $yaw = (([int]$rotationFixed[1]) -shr 8) -band 255
 $roll = (([int]$rotationFixed[2]) -shr 8) -band 255
 $matrix = Get-RotationMatrixDouble $pitch $yaw $roll
 $rotated = Normalize-Vector (Transform-VectorDouble $matrix $normal)
 return [int[]]@(
 (Clamp-SignedByte ([int][Math]::Round($rotated[0] * 63.0)) -63 63),
 (Clamp-SignedByte ([int][Math]::Round($rotated[1] * 63.0)) -63 63),
 (Clamp-SignedByte ([int][Math]::Round($rotated[2] * 63.0)) -63 63)
 )
}

function Get-StaticShadeByteFromDotHi([int]$dotHi, [int]$intensity, [int]$reflectivityOffset) {
 if ($intensity -le 0 -or $dotHi -lt 0) {
 return 0x00
 }

 $level = $intensity
 if ($level -gt 10) { $level = 10 }
 if ($dotHi -ge [int]$script:ShadeThresholdHigh[$level]) {
 if ($reflectivityOffset -ge 0x14) { return 0x04 }
 if ($reflectivityOffset -ge 0x0a) { return 0x84 }
 return 0x84
 }
 if ($dotHi -ge [int]$script:ShadeThresholdMidHigh[$level]) {
 if ($reflectivityOffset -ge 0x14) { return 0x04 }
 if ($reflectivityOffset -ge 0x0a) { return 0x84 }
 return 0x02
 }
 if ($dotHi -ge [int]$script:ShadeThresholdMid[$level]) {
 if ($reflectivityOffset -ge 0x14) { return 0x84 }
 if ($reflectivityOffset -ge 0x0a) { return 0x86 }
 return 0x82
 }
 return 0x00
}

function Get-StaticFaceShade([int]$faceIndex, [object[]]$rotationFixed, [object[]]$positionFixed, [int]$scale64, [int]$reflectivityOffset, [int[]]$lightPosition, [int]$intensity) {
 $geometry = Get-FaceShadeGeometry $faceIndex
 $qNormal = [int[]]$geometry.QNormal
 $qCenter = [int[]]$geometry.QCenter
 $rotNormal = Get-RotatedFaceNormalQ ([double[]]$geometry.Normal) $rotationFixed

 $centerDot = [int][Math]::Round(((($qNormal[0] * $qCenter[0]) + ($qNormal[1] * $qCenter[1]) + ($qNormal[2] * $qCenter[2])) * [double]$scale64) / 64.0)
 $objectX = ([int]$positionFixed[0]) -shr 8
 $objectY = ([int]$positionFixed[1]) -shr 8
 $objectZ = ([int]$positionFixed[2]) -shr 8
 $dot = (($rotNormal[0] * [int]$lightPosition[0]) + ($rotNormal[1] * [int]$lightPosition[1]) + ($rotNormal[2] * [int]$lightPosition[2]))
 $dot -= $centerDot
 $dot -= (($rotNormal[0] * $objectX) + ($rotNormal[1] * $objectY) + ($rotNormal[2] * $objectZ))

 $dotHi = if ($dot -lt 0) { -1 } else { [int][Math]::Floor($dot / 256.0) }
 return Get-StaticShadeByteFromDotHi $dotHi $intensity $reflectivityOffset
}

function Get-MeshMidY {
 if ($script:MeshVertices.Count -eq 0) {
 return 0.0
 }
 $minY = [int]$script:MeshVertices[0][1]
 $maxY = $minY
 foreach ($v in $script:MeshVertices) {
 $y = [int]$v[1]
 if ($y -lt $minY) { $minY = $y }
 if ($y -gt $maxY) { $maxY = $y }
 }
 return ($minY + $maxY) / 2.0
}

function Get-MeshMidYRange([int]$firstVertex, [int]$vertexCount) {
 if ($vertexCount -le 0) {
 return 0.0
 }
 $minY = [int]$script:MeshVertices[$firstVertex][1]
 $maxY = $minY
 for ($i = 0; $i -lt $vertexCount; $i++) {
 $y = [int]$script:MeshVertices[$firstVertex + $i][1]
 if ($y -lt $minY) { $minY = $y }
 if ($y -gt $maxY) { $maxY = $y }
 }
 return ($minY + $maxY) / 2.0
}

function Add-TorusMesh([int]$majorSegments, [int]$tubeSegments, [int]$majorRadius, [int]$tubeRadius) {
 $baseVertex = $script:MeshVertices.Count
 for ($major = 0; $major -lt $majorSegments; $major++) {
 $u = $major * 2.0 * [Math]::PI / $majorSegments
 for ($tube = 0; $tube -lt $tubeSegments; $tube++) {
 $v = $tube * 2.0 * [Math]::PI / $tubeSegments
 $ringRadius = $majorRadius + $tubeRadius * [Math]::Cos($v)
 $x = [int][Math]::Round($ringRadius * [Math]::Cos($u))
 $y = [int][Math]::Round($tubeRadius * [Math]::Sin($v))
 $z = [int][Math]::Round($ringRadius * [Math]::Sin($u))
 [void](Add-MeshVertex $x $y $z)
 }
 }

 for ($major = 0; $major -lt $majorSegments; $major++) {
 for ($tube = 0; $tube -lt $tubeSegments; $tube++) {
 $mi0 = (($major % $majorSegments) + $majorSegments) % $majorSegments
 $mi1 = ((($major + 1) % $majorSegments) + $majorSegments) % $majorSegments
 $ti0 = (($tube % $tubeSegments) + $tubeSegments) % $tubeSegments
 $ti1 = ((($tube + 1) % $tubeSegments) + $tubeSegments) % $tubeSegments
 $a = $baseVertex + ($mi0 * $tubeSegments + $ti0)
 $b = $baseVertex + ($mi1 * $tubeSegments + $ti0)
 $c = $baseVertex + ($mi0 * $tubeSegments + $ti1)
 $d = $baseVertex + ($mi1 * $tubeSegments + $ti1)

 # Winding follows dP/dv x dP/du, i.e. outward normal for this torus parameterization.
 Add-Face $a $c $d $b
 }
 }
}

function Add-CubeMesh([int]$size) {
 $s = $size
 $v0 = V (-$s) (-$s) (-$s)
 $v1 = V $s (-$s) (-$s)
 $v2 = V $s $s (-$s)
 $v3 = V (-$s) $s (-$s)
 $v4 = V (-$s) (-$s) $s
 $v5 = V $s (-$s) $s
 $v6 = V $s $s $s
 $v7 = V (-$s) $s $s

 Add-Face $v0 $v3 $v2 $v1
 Add-Face $v4 $v5 $v6 $v7
 Add-Face $v0 $v4 $v7 $v3
 Add-Face $v1 $v2 $v6 $v5
 Add-Face $v0 $v1 $v5 $v4
 Add-Face $v3 $v7 $v6 $v2
}

function Import-SolidDocument([object]$doc, [string]$Context) {
 if (-not ($doc.PSObject.Properties.Name -contains "vertices")) {
 throw "MeshFile missing vertices array"
 }
 if (-not ($doc.PSObject.Properties.Name -contains "faces")) {
 throw "MeshFile missing faces array"
 }

 $indexMap = @()
 foreach ($vertex in $doc.vertices) {
 $items = @($vertex)
 if ($items.Count -ne 3) {
 throw "Each MeshFile vertex must have 3 coordinates"
 }
 $indexMap += Add-MeshVertex ([int]$items[0]) ([int]$items[1]) ([int]$items[2])
 }

 $materials = @()
 if ($doc.PSObject.Properties.Name -contains "materials") {
 $materials = @($doc.materials)
 }
 $faceMaterialFamilies = @()
 if ($doc.PSObject.Properties.Name -contains "faceMaterialFamilies") {
 $faceMaterialFamilies = @($doc.faceMaterialFamilies)
 } elseif ($doc.PSObject.Properties.Name -contains "materialFamilies") {
 $faceMaterialFamilies = @($doc.materialFamilies)
 } elseif ($doc.PSObject.Properties.Name -contains "faceMaterials") {
 $faceMaterialFamilies = @($doc.faceMaterials)
 }
 $faceSolidColors = @()
 if ($doc.PSObject.Properties.Name -contains "faceSolidColors") {
 $faceSolidColors = @($doc.faceSolidColors)
 } elseif ($doc.PSObject.Properties.Name -contains "solidVicFaceColors") {
 $faceSolidColors = @($doc.solidVicFaceColors)
 }
 $faceVertexCounts = @()
 if ($doc.PSObject.Properties.Name -contains "face_vertex_counts") {
 $faceVertexCounts = @($doc.face_vertex_counts)
 } elseif ($doc.PSObject.Properties.Name -contains "faceVertexCounts") {
 $faceVertexCounts = @($doc.faceVertexCounts)
 }
 if ($faceVertexCounts.Count -gt 0 -and $faceVertexCounts.Count -ne @($doc.faces).Count) {
 throw "MeshFile face_vertex_counts must match faces count"
 }
 if ($faceMaterialFamilies.Count -gt 0 -and $faceMaterialFamilies.Count -ne @($doc.faces).Count) {
 throw "MeshFile faceMaterialFamilies must match faces count"
 }
 if ($faceMaterialFamilies.Count -gt 0) {
 $script:CurrentMeshMaterialProfile = "multimaterial"
 }
 if ($faceSolidColors.Count -gt 0 -and $faceSolidColors.Count -ne @($doc.faces).Count) {
 throw "MeshFile faceSolidColors must match faces count"
 }

 $faceIndex = 0
 foreach ($face in $doc.faces) {
 $items = @($face)
 if ($items.Count -lt 3 -or $items.Count -gt 4) {
 throw "Each MeshFile face must have 3 or 4 vertex indices"
 }
 $declaredVertexCount = if ($faceVertexCounts.Count -gt 0) { [int]$faceVertexCounts[$faceIndex] } else { $items.Count }
 if ($declaredVertexCount -ne 3 -and $declaredVertexCount -ne 4) {
 throw "Each MeshFile face vertex count must be 3 or 4"
 }
 if ($declaredVertexCount -eq 4 -and $items.Count -ne 4) {
 throw "Quad MeshFile faces must have 4 vertex indices"
 }
 $a = $indexMap[[int]$items[0]]
 $b = $indexMap[[int]$items[1]]
 $c = $indexMap[[int]$items[2]]
 $d = if ($declaredVertexCount -eq 4) { $indexMap[[int]$items[3]] } else { -1 }
 $material = if ($faceIndex -lt $materials.Count) { [int]$materials[$faceIndex] } else { -1 }
 $materialFamily = if ($faceIndex -lt $faceMaterialFamilies.Count) { Resolve-FaceMaterialFamily $faceMaterialFamilies[$faceIndex] "MeshFile faceMaterialFamilies[$faceIndex]" } else { -1 }
 $solidColor = if ($faceIndex -lt $faceSolidColors.Count) { Resolve-FaceSolidColor $faceSolidColors[$faceIndex] "MeshFile faceSolidColors[$faceIndex]" } else { -1 }
 Add-Face $a $b $c $d $material $declaredVertexCount $materialFamily $solidColor 0
 $faceIndex++
 }

 if ($doc.PSObject.Properties.Name -contains "name") {
 $script:MeshName = [string]$doc.name
 } else {
 $script:MeshName = $Context
 }
}

function Import-MeshFile([string]$path) {
 $resolved = if ([IO.Path]::IsPathRooted($path)) { $path } else { Join-Path $Root $path }
 if (-not (Test-Path -LiteralPath $resolved)) {
 throw "MeshFile not found: $resolved"
 }
 $doc = Get-Content -LiteralPath $resolved -Raw | ConvertFrom-Json
 Import-SolidDocument $doc ([IO.Path]::GetFileNameWithoutExtension($resolved))
}

function Apply-SceneObjectFaceOverrides([object]$Object, [string]$ObjectName) {
 $firstFace = [int]$script:CurrentMeshFirstFace
 $faceCount = [int]($script:MeshFaces.Count - $firstFace)
 if ($faceCount -le 0) {
 return
 }

 $objectMaterialProfile = Read-SceneMeshMaterialProfile $Object "scene object '$ObjectName'"
 if ($objectMaterialProfile -eq "multimaterial") {
 $script:CurrentMeshMaterialProfile = "multimaterial"
 }

 $faceMaterialFamilies = @()
 if (Has-Property $Object "faceMaterialFamilies") {
 $faceMaterialFamilies = @((Get-PropertyValue $Object "faceMaterialFamilies"))
 } elseif (Has-Property $Object "materialFamilies") {
 $faceMaterialFamilies = @((Get-PropertyValue $Object "materialFamilies"))
 } elseif (Has-Property $Object "faceMaterials") {
 $faceMaterialFamilies = @((Get-PropertyValue $Object "faceMaterials"))
 }
 if ($faceMaterialFamilies.Count -gt 0) {
 $script:CurrentMeshMaterialProfile = "multimaterial"
 if ($faceMaterialFamilies.Count -ne $faceCount) {
 throw "scene object '$ObjectName' faceMaterialFamilies must match imported face count $faceCount"
 }
 for ($i = 0; $i -lt $faceCount; $i++) {
 $script:MeshFaceMaterialFamilies[$firstFace + $i] = Resolve-FaceMaterialFamily $faceMaterialFamilies[$i] "scene object '$ObjectName' faceMaterialFamilies[$i]"
 }
 }

 $faceSolidColors = @()
 if (Has-Property $Object "faceSolidColors") {
 $faceSolidColors = @((Get-PropertyValue $Object "faceSolidColors"))
 } elseif (Has-Property $Object "solidVicFaceColors") {
 $faceSolidColors = @((Get-PropertyValue $Object "solidVicFaceColors"))
 }
 if ($faceSolidColors.Count -gt 0) {
 if ($faceSolidColors.Count -ne $faceCount) {
 throw "scene object '$ObjectName' faceSolidColors must match imported face count $faceCount"
 }
 for ($i = 0; $i -lt $faceCount; $i++) {
 $script:MeshFaceSolidColors[$firstFace + $i] = Resolve-FaceSolidColor $faceSolidColors[$i] "scene object '$ObjectName' faceSolidColors[$i]"
 }
 }

 $faceSolidColorUseSpecified = $false
 foreach ($name in @("useFaceSolidColors", "useSolidVicFaceColors", "solidFaceColors", "solidVicFaceColorsEnabled")) {
 if (Has-Property $Object $name) {
 $faceSolidColorUseSpecified = $true
 break
 }
 }
 if ($faceSolidColorUseSpecified) {
 $useFaceSolidColors = Read-FaceSolidColorUse $Object $false "scene object '$ObjectName'"
 for ($i = 0; $i -lt $faceCount; $i++) {
 $color = [int]$script:MeshFaceSolidColors[$firstFace + $i]
 $script:MeshFaceSolidColorUse[$firstFace + $i] = if ($useFaceSolidColors -and $color -ge 0) { 1 } else { 0 }
 }
 }

 if (Has-Property $Object "faceOverrides") {
 $sparse = Get-PropertyValue $Object "faceOverrides"
 foreach ($property in $sparse.PSObject.Properties) {
 $localFace = 0
 if (-not [int]::TryParse([string]$property.Name, [ref]$localFace) -or $localFace -lt 0 -or $localFace -ge $faceCount) {
 throw "scene object '$ObjectName' faceOverrides key '$($property.Name)' is outside local face range 0..$($faceCount - 1)"
 }
 $override = $property.Value
 $globalFace = $firstFace + $localFace
 if (Has-Property $override "materialOverride") {
 $script:CurrentMeshMaterialProfile = "multimaterial"
 $script:MeshFaceMaterialFamilies[$globalFace] = Resolve-FaceMaterialFamily (Get-PropertyValue $override "materialOverride") "scene object '$ObjectName' faceOverrides.$localFace.materialOverride"
 }
 if (Has-Property $override "solidColor") {
 $color = Resolve-FaceSolidColor (Get-PropertyValue $override "solidColor") "scene object '$ObjectName' faceOverrides.$localFace.solidColor"
 $script:MeshFaceSolidColors[$globalFace] = $color
 $shading = if (Has-Property $override "shading") { [bool](Get-PropertyValue $override "shading") } else { $false }
 $script:MeshFaceSolidColorUse[$globalFace] = if ($color -ge 0 -and -not $shading) { 1 } else { 0 }
 }
 }
 }
}

function Read-C64Color([object]$Value, [string]$Context) {
 $color = [int]$Value
 if ($color -lt 0 -or $color -gt 15) {
 throw "C64 color must be in range 0..15 for $Context"
 }
 return $color
}

function Read-WireColor([object]$Value, [string]$Context) {
 return Read-C64Color $Value $Context
}

function Get-MaterialFamilyNameForC64Color([int]$Color) {
 switch ($Color) {
 1 { return "white" }
 2 { return "red" }
 3 { return "cyan" }
 4 { return "magenta" }
 5 { return "green" }
 6 { return "blue" }
 7 { return "yellow" }
 8 { return "orange" }
 9 { return "brown" }
 10 { return "red" }
 11 { return "gray" }
 12 { return "white" }
 13 { return "green" }
 14 { return "blue" }
 15 { return "gray" }
 default { return "gray" }
 }
}

function Get-WireMaterialFamilyC64Color([int]$FamilyIndex, [string]$Context) {
 if ($FamilyIndex -lt 0 -or $FamilyIndex -ge $MaterialFamilies.Count) {
 throw "Wire material family index out of range for ${Context}: $FamilyIndex"
 }

 $familyName = ([string]$MaterialFamilies[$FamilyIndex].name).Trim().ToLowerInvariant()
 $color = switch ($familyName) {
 "gray" { 15 }
 "white" { 1 }
 "red" { 2 }
 "green" { 5 }
 "blue" { 6 }
 "yellow" { 7 }
 "cyan" { 3 }
 "magenta" { 4 }
 "orange" { 8 }
 "brown" { 9 }
 default { throw "Material family '$familyName' has no canonical two-color wire pigment for $Context" }
 }
 if ($color -lt 0 -or $color -gt 15) {
 throw "Two-color wire pigment is outside the VIC-II palette for ${Context}: $color"
 }
 return [int]$color
}

function Read-BooleanField([object]$Object, [string]$Name, [bool]$Default, [string]$Context) {
 if (-not (Has-Property $Object $Name)) {
 return $Default
 }

 $value = Get-PropertyValue $Object $Name
 if ($value -is [bool]) {
 return [bool]$value
 }

 $s = ([string]$value).Trim().ToLowerInvariant()
 if (@("1", "true", "yes", "on", "enabled") -contains $s) {
 return $true
 }
 if (@("0", "false", "no", "off", "disabled") -contains $s) {
 return $false
 }
 throw "$Name must be boolean for $Context"
}

function Read-FaceSolidColorUse([object]$Object, [bool]$Default, [string]$Context) {
 foreach ($name in @("useFaceSolidColors", "useSolidVicFaceColors", "solidFaceColors", "solidVicFaceColorsEnabled")) {
 if (Has-Property $Object $name) {
 return Read-BooleanField $Object $name $Default $Context
 }
 }
 return $Default
}

function Read-WorldGroundObject([object]$Ground, [int]$Index, [string]$AxisConvention) {
 $name = [string](Get-PropertyValue $Ground "id" (Get-PropertyValue $Ground "name" "ground_$Index"))
 foreach ($reserved in @("material", "reflectivity", "extent", "halfExtent")) {
 if (Has-Property $Ground $reserved) {
 throw "world ground '$name' field '$reserved' is reserved in this milestone: the runtime consumes only enabled, z/worldZ and color"
 }
 }
 $enabled = Read-BooleanField $Ground "enabled" $true "world ground '$name'"
 $color = Read-C64Color (Get-PropertyValue $Ground "color" 5) "world ground '$name'"
 $z = [double](Get-PropertyValue $Ground "z" (Get-PropertyValue $Ground "worldZ" 0))
 $engineY = Convert-ToFixed8 $z "world ground '$name' z" -32768 32767
 $occlude = Read-BooleanField $Ground "occlude" $false "world ground '$name'"
 $mode = ([string](Get-PropertyValue $Ground "mode" (Get-PropertyValue $Ground "groundMode" (Get-PropertyValue $Ground "worldGroundMode" "simple")))).Trim().ToLowerInvariant()
 if (@("simple", "plane") -notcontains $mode) {
 throw "world ground '$name' mode must be 'simple' or 'plane'"
 }

 if ($AxisConvention -ne "world-z-up") {
 throw "world.grounds[] requires axisConvention 'world-z-up' because ground.z is a public world vertical coordinate"
 }

 return [pscustomobject]@{
 Name = $name
 Enabled = $(if ($enabled) { 1 } else { 0 })
 Color = $color
 WorldZ = $z
 EngineY = $engineY
 Occlude = $(if ($occlude) { 1 } else { 0 })
 Mode = $mode
 }
}

function Read-SceneWorldObject([object]$Doc, [string]$AxisConvention) {
 $world = if (Has-Property $Doc "world") { Get-PropertyValue $Doc "world" } else { [pscustomobject]@{} }
 $backgroundColor = Read-C64Color (Get-PropertyValue $world "backgroundColor" 0) "world.backgroundColor"
 $grounds = @()

 if (Has-Property $world "grounds") {
 $index = 0
 foreach ($ground in @($world.grounds)) {
 $grounds += ,(Read-WorldGroundObject $ground $index $AxisConvention)
 $index++
 }
 }

 return [pscustomobject]@{
 BackgroundColor = $backgroundColor
 Grounds = @($grounds)
 }
}

function Import-WireDocument([object]$doc, [string]$Context) {
 if ($doc.PSObject.Properties.Name -contains "type") {
 $docType = ([string]$doc.type).Trim().ToLowerInvariant() -replace "[_ ]", "-"
 if ($docType -eq "wire") {
 # Public alias. Internally this remains ObjectKind=Mesh, GeometryKind=Wire.
 } elseif ($docType -eq "mesh") {
 $geometryKind = Read-SceneMeshGeometryKind $doc $Context
 if ($geometryKind -ne "wire") {
 throw "Wire mesh source with type='mesh' must define geometry='wire' for $Context"
 }
 } else {
 throw "Wire mesh source type must be 'wire' or type='mesh' with geometry='wire' for $Context"
 }
 }
 if (-not ($doc.PSObject.Properties.Name -contains "vertices")) {
 throw "Wire mesh missing vertices array: $Context"
 }
 if (-not ($doc.PSObject.Properties.Name -contains "edges")) {
 throw "Wire mesh missing edges array: $Context"
 }
 $wireColorProperty = $null
 if ($doc.PSObject.Properties.Name -contains "color") {
 $wireColorProperty = "color"
 } elseif ($doc.PSObject.Properties.Name -contains "wireColor") {
 $wireColorProperty = "wireColor"
 }
 if (-not $wireColorProperty) {
 throw "Wire mesh missing color or wireColor 0..15: $Context"
 }

 $script:CurrentMeshIsWire = $true
 $script:CurrentMeshWireColor = Read-WireColor (Get-PropertyValue $doc $wireColorProperty) $Context

 $indexMap = @()
 foreach ($vertex in @($doc.vertices)) {
 $items = @($vertex)
 if ($items.Count -ne 3) {
 throw "Each wire vertex must have 3 coordinates: $Context"
 }
 $indexMap += Add-MeshVertex ([int]$items[0]) ([int]$items[1]) ([int]$items[2])
 }
 if ($indexMap.Count -le 0) {
 throw "Wire mesh must contain at least one vertex: $Context"
 }

 foreach ($edge in @($doc.edges)) {
 $items = @($edge)
 if ($items.Count -ne 2) {
 throw "Each wire edge must have 2 vertex indices: $Context"
 }
 $aIndex = [int]$items[0]
 $bIndex = [int]$items[1]
 if ($aIndex -lt 0 -or $aIndex -ge $indexMap.Count -or $bIndex -lt 0 -or $bIndex -ge $indexMap.Count) {
 throw "Wire edge references vertex outside range: $Context"
 }
 Add-WireEdge ([int]$indexMap[$aIndex]) ([int]$indexMap[$bIndex])
 }
 if (($script:MeshWireEdges.Count - $script:CurrentMeshFirstWireEdge) -le 0) {
 throw "Wire mesh must contain at least one edge: $Context"
 }

 if ($HiddenWireFlag -ne 0 -and ($doc.PSObject.Properties.Name -contains "faces")) {
 foreach ($face in @($doc.faces)) {
 $items = @($face)
 if ($items.Count -ne 3 -and $items.Count -ne 4) {
 throw "Each wire face must have 3 or 4 vertex indices: $Context"
 }
 $mapped = @()
 foreach ($item in $items) {
 $idx = [int]$item
 if ($idx -lt 0 -or $idx -ge $indexMap.Count) {
 throw "Wire face references vertex outside range: $Context"
 }
 $mapped += [int]$indexMap[$idx]
 }
 if ($mapped.Count -eq 3) {
 Add-Face $mapped[0] $mapped[1] $mapped[2] -1 -1 3
 } else {
 Add-Face $mapped[0] $mapped[1] $mapped[2] $mapped[3] -1 4
 }
 }
 }

 if ($doc.PSObject.Properties.Name -contains "name") {
 $script:MeshName = [string]$doc.name
 }
}

function Import-WireFile([string]$path) {
 $resolved = if ([IO.Path]::IsPathRooted($path)) { $path } else { Join-Path $Root $path }
 if (-not (Test-Path -LiteralPath $resolved)) {
 throw "WireFile not found: $resolved"
 }

 $doc = Get-Content -LiteralPath $resolved -Raw | ConvertFrom-Json
 Import-WireDocument $doc $resolved
 if (-not ($doc.PSObject.Properties.Name -contains "name")) {
 $script:MeshName = [IO.Path]::GetFileNameWithoutExtension($resolved)
 }
}

function Add-BuiltinMesh([string]$Name) {
 switch ($Name) {
 "cube" {
 Add-CubeMesh 28
 }
 "torus6x6" {
 Add-TorusMesh 6 6 30 10
 }
 "torus8x6" {
 Add-TorusMesh 8 6 30 10
 }
 "torus10x6" {
 Add-TorusMesh 10 6 30 10
 }
 "torus12x6" {
 Add-TorusMesh 12 6 30 10
 }
 default {
 throw "Unsupported scene builtin mesh: $Name"
 }
 }
}

function Import-SceneMeshSource([object]$Source, [string]$SceneDir) {
 $sourceType = if (Has-Property $Source "type") { ([string](Get-PropertyValue $Source "type")).Trim().ToLowerInvariant() -replace "[_ ]", "-" } else { "" }
 $geometryKind = Read-SceneMeshGeometryKind $Source "scene mesh source"
 $materialProfile = Read-SceneMeshMaterialProfile $Source "scene mesh source"
 if ($geometryKind -eq "wire" -and $materialProfile -eq "multimaterial") {
 throw "Wire mesh source cannot use multimaterial material profile"
 }
 if ($materialProfile -eq "multimaterial") {
 $script:CurrentMeshMaterialProfile = "multimaterial"
 }
 if ($geometryKind -eq "wire") {
 if (Has-Property $Source "wireFile") {
 Import-WireFile (Resolve-ScenePath ([string](Get-PropertyValue $Source "wireFile")) $SceneDir)
 return
 }
 if (Has-Property $Source "file") {
 Import-WireFile (Resolve-ScenePath ([string](Get-PropertyValue $Source "file")) $SceneDir)
 return
 }
 Import-WireDocument $Source "inline scene wire mesh"
 return
 }
 if (Has-Property $Source "wireFile") {
 Import-WireFile (Resolve-ScenePath ([string](Get-PropertyValue $Source "wireFile")) $SceneDir)
 return
 }
 if ((Has-Property $Source "vertices") -or (Has-Property $Source "faces")) {
 Import-SolidDocument $Source "inline scene solid mesh"
 return
 }
 if (Has-Property $Source "meshFile") {
 Import-MeshFile (Resolve-ScenePath ([string](Get-PropertyValue $Source "meshFile")) $SceneDir)
 return
 }
 if (Has-Property $Source "file") {
 Import-MeshFile (Resolve-ScenePath ([string](Get-PropertyValue $Source "file")) $SceneDir)
 return
 }
 if (Has-Property $Source "builtin") {
 Add-BuiltinMesh ([string](Get-PropertyValue $Source "builtin"))
 return
 }
 throw "Scene mesh source must define meshFile, wireFile, file, builtin, type='wire', or type='mesh' with geometry='wire'"
}

function Import-SceneFile([string]$path) {
 if ([IO.Path]::IsPathRooted($path)) {
 $resolved = $path
 } else {
 $currentDirectoryCandidate = Join-Path (Get-Location).Path $path
 if (Test-Path -LiteralPath $currentDirectoryCandidate -PathType Leaf) {
 $resolved = $currentDirectoryCandidate
 } else {
 $resolved = Join-Path (Split-Path -Parent $Root) $path
 }
 }
 if (-not (Test-Path -LiteralPath $resolved)) {
 throw "SceneFile not found: $resolved"
 }
 $resolved = (Resolve-Path -LiteralPath $resolved -ErrorAction Stop).Path

 $sceneDir = Split-Path -Parent $resolved
 $doc = Get-Content -LiteralPath $resolved -Raw | ConvertFrom-Json
 if ((Has-Property $doc "schema") -and [int]$doc.schema -ne 1) {
 throw "Unsupported SceneFile schema: $($doc.schema)"
 }
 if (Has-Property $doc "graphicsMode") {
 $sceneGraphicsMode = Get-PropertyValue $doc "graphicsMode"
 if (-not ($sceneGraphicsMode -is [int] -or $sceneGraphicsMode -is [long])) {
 throw "SceneFile graphicsMode must be an integer from 1 to 5"
 }
 $sceneGraphicsModeNumber = [int]$sceneGraphicsMode
 if ($sceneGraphicsModeNumber -lt 1 -or $sceneGraphicsModeNumber -gt 5) {
 throw "SceneFile graphicsMode must be an integer from 1 to 5"
 }
 }
 if (-not (Has-Property $doc "objects")) {
 throw "SceneFile missing objects array"
 }
 $axisConvention = Get-SceneAxisConvention $doc
 Validate-SceneObjectModelContract $doc $axisConvention
 $script:SceneAxisConvention = $axisConvention
 $worldObject = Read-SceneWorldObject $doc $axisConvention
 $script:WorldBackgroundColor = [int]$worldObject.BackgroundColor
 $script:WorldGrounds = @($worldObject.Grounds)
 if (Has-Property $doc "camera") {
 $script:SceneCameraObject = Read-SceneCameraObject (Get-PropertyValue $doc "camera") $axisConvention
 }
 $script:SceneLightObjects = @(Read-SceneLightObjects $doc $axisConvention)
 if (Has-Property $doc "timeline") {
 $timeline = Get-PropertyValue $doc "timeline"
 $tickRate = [int](Get-PropertyValue $timeline "tickRate" 50)
 if ($tickRate -ne 50) { throw "scene timeline tickRate must be 50" }
 $resetKey = ([string](Get-PropertyValue $timeline "resetKey" "SPACE")).Trim().ToUpperInvariant()
 if ($resetKey -ne "SPACE") { throw "scene timeline initially supports resetKey SPACE only" }
 $script:SceneTimelineObject = $timeline
 }
 if (Has-Property $doc "graphicEffect") {
 $effect = Get-PropertyValue $doc "graphicEffect"
 $effectType = ([string](Get-PropertyValue $effect "type" "include")).Trim().ToLowerInvariant()
 if ($effectType -ne "include") { throw "scene graphicEffect currently supports type 'include' only" }
 $includeName = [string](Get-PropertyValue $effect "file" "")
 if ($includeName.Trim().Length -eq 0) { throw "scene graphicEffect.file is required" }
 $includePath = Resolve-ScenePath $includeName $sceneDir
 if (-not (Test-Path -LiteralPath $includePath -PathType Leaf)) { throw "scene graphicEffect include not found: $includePath" }
 $script:SceneGraphicIncludePath = $includePath
 $script:SceneGraphicIncludeText = Get-Content -LiteralPath $includePath -Raw
 }

 $sourceById = @{}
 if (Has-Property $doc "meshes") {
 foreach ($source in @($doc.meshes)) {
 if (-not (Has-Property $source "id")) {
 throw "Each scene meshes[] entry must define id"
 }
 $sourceById[[string](Get-PropertyValue $source "id")] = $source
 }
 }

 $meshReferenceCount = @{}
 foreach ($object in @($doc.objects)) {
  if (Has-Property $object "mesh") {
   $meshRef = [string](Get-PropertyValue $object "mesh")
   if (-not $sourceById.ContainsKey($meshRef)) {
    $objectName = [string](Get-PropertyValue $object "id" "scene object")
    throw "Scene object '$objectName' references unknown mesh '$meshRef'"
   }
   if (-not $meshReferenceCount.ContainsKey($meshRef)) { $meshReferenceCount[$meshRef] = 0 }
   $meshReferenceCount[$meshRef] = [int]$meshReferenceCount[$meshRef] + 1
  }
 }
 $sharedMeshReferenceCount = @($meshReferenceCount.GetEnumerator() | Where-Object { [int]$_.Value -gt 1 }).Count
 $sourceSharingOptIn = [bool](Get-PropertyValue $doc "meshSourceSharing" $false)
 if ($sourceSharingOptIn -and (@(4, 5) -notcontains $GraphicsModeNumber)) {
  throw "meshSourceSharing is supported only in GraphicsMode 4 and 5"
 }
 if ($sourceSharingOptIn -and $sharedMeshReferenceCount -eq 0) {
  throw "meshSourceSharing requires at least one source mesh referenced by multiple instances"
 }
 $script:SceneSourceSharingRequested = (
  $sourceSharingOptIn -and
  (@(4, 5) -contains $GraphicsModeNumber) -and
  ($sharedMeshReferenceCount -gt 0)
 )
 $sharedMeshIndexById = @{}

 $objectIndex = 0
 foreach ($object in @($doc.objects)) {
 $objectName = [string](Get-PropertyValue $object "id" "object_$objectIndex")
 $source = $null
 if (Has-Property $object "mesh") {
 $meshRef = [string](Get-PropertyValue $object "mesh")
 if (-not $sourceById.ContainsKey($meshRef)) {
 throw "Scene object '$objectName' references unknown mesh '$meshRef'"
 }
 $source = $sourceById[$meshRef]
 } else {
 $source = $object
 }

  if ($script:SceneSourceSharingRequested -and (Has-Property $object "mesh")) {
   $meshRef = [string](Get-PropertyValue $object "mesh")
   if (-not $sharedMeshIndexById.ContainsKey($meshRef)) {
    Begin-MeshRecord $meshRef
    Import-SceneMeshSource $source $sceneDir
    Apply-SceneObjectFaceOverrides $source "mesh source '$meshRef'"
    End-MeshRecord $meshRef
    $sharedMeshIndexById[$meshRef] = $script:MeshRecords.Count - 1
   }
   $meshIndex = [int]$sharedMeshIndexById[$meshRef]
   if (Has-Property $object "faceOverrides") {
    if ([int]$meshReferenceCount[$meshRef] -gt 1) {
     throw "Shared mesh '$meshRef' uses source-local faceOverrides; per-instance object faceOverrides are not supported by the shared-source path"
    }
    Apply-SceneObjectFaceOverrides $object $objectName
   }
  } else {
   Begin-MeshRecord $objectName
   Import-SceneMeshSource $source $sceneDir
   Apply-SceneObjectFaceOverrides $source "mesh source for $objectName"
   Apply-SceneObjectFaceOverrides $object $objectName
   End-MeshRecord $objectName
   $meshIndex = $script:MeshRecords.Count - 1
  }

 $requestedPosition = @(Get-PropertyValue $object "position" @(0,0,0))
 $requestedWorldY = if ($axisConvention -eq "world-z-up") { [double]$requestedPosition[1] } else { [double]$requestedPosition[2] }
 $position = Read-ScenePosition $object $axisConvention
 $velocity = Read-SceneVelocity $object $axisConvention
 $rotation = Read-Fixed3 $object "rotation" @(0,0,0) 0 65535 $axisConvention
 $angularVelocity = Read-Fixed3 $object "angularVelocity" @(0,0,0) -32768 32767 $axisConvention
 $scale = Read-Scale64 $object
 $material = Read-SceneObjectMaterial $object $objectName
 $reflectivity = Read-SceneObjectReflectivity $object $objectName
 $colorOverride = Read-SceneObjectColorOverride $object $objectName
 $wireColor = Read-SceneObjectWireColor $object $objectName
 $visible = Read-SceneObjectVisible $object $objectName
 $respawn = Read-SceneObjectRespawn $object $objectName $axisConvention
 $oscillation = Read-SceneObjectOscillationX $object $objectName

 $script:SceneObjects += ,[pscustomobject]@{
 Name = $objectName
 MeshIndex = $meshIndex
 Position = $position
 RequestedWorldY = $requestedWorldY
 Velocity = $velocity
 Rotation = $rotation
 AngularVelocity = $angularVelocity
 Scale = $scale
 Material = $material
 Reflectivity = $reflectivity
 ColorOverride = $colorOverride
 InstanceOverrideProfile = [bool]((Has-Property $object "materialOverride") -or (Has-Property $object "reflectivityOverride") -or (Has-Property $object "colorOverride"))
 WireColor = $wireColor
 Visible = $visible
 Respawn = $respawn
 Oscillation = $oscillation
 }
 $objectIndex++
 }

 if ($script:SceneObjects.Count -lt 1 -or $script:SceneObjects.Count -gt 255) {
 throw "SceneFile object count must be 1..255"
 }
 $script:MeshName = if (Has-Property $doc "name") { [string]$doc.name } else { [IO.Path]::GetFileNameWithoutExtension($resolved) }
}

function Compile-SceneTimeline([object]$Timeline, [object[]]$Objects, [string]$AxisConvention) {
 if ($null -eq $Timeline) { return $null }
 $states = @((Get-PropertyValue $Timeline "states" @()))
 if ($states.Count -lt 1 -or $states.Count -gt 255) { throw "scene timeline states must contain 1..255 entries" }
 if (($states.Count * $Objects.Count) -gt 255) { throw "scene timeline state/object matrix must fit in 255 entries" }
 $objectByName = @{}
 for ($i = 0; $i -lt $Objects.Count; $i++) { $objectByName[[string]$Objects[$i].Name] = $i }
 $stateByName = @{}
 for ($i = 0; $i -lt $states.Count; $i++) {
 $id = [string](Get-PropertyValue $states[$i] "id" "state_$i")
 if ($stateByName.ContainsKey($id)) { throw "duplicate timeline state id '$id'" }
 $stateByName[$id] = $i
 }
 $durationLo=@(); $durationHi=@(); $next=@(); $entryBase=@()
 $mask0=@(); $mask1=@(); $visible=@(); $scale=@(); $material=@(); $reflect=@(); $color=@()
 $pxlo=@(); $pxhi=@(); $pylo=@(); $pyhi=@(); $pzlo=@(); $pzhi=@(); $pzext=@()
 $rxlo=@(); $rxhi=@(); $rylo=@(); $ryhi=@(); $rzlo=@(); $rzhi=@()
 $vxlo=@(); $vxhi=@(); $vylo=@(); $vyhi=@(); $vzlo=@(); $vzhi=@(); $vzext=@()
 $avxlo=@(); $avxhi=@(); $avylo=@(); $avyhi=@(); $avzlo=@(); $avzhi=@()
 $usesVelocity=$false; $usesAngularVelocity=$false; $usesVisibility=$false; $usesOverrides=$false; $usesColorOverride=$false
 for ($si = 0; $si -lt $states.Count; $si++) {
 $state=$states[$si]
 $duration=[int](Get-PropertyValue $state "duration" 1)
 if ($duration -lt 1 -or $duration -gt 65535) { throw "timeline state $si duration must be 1..65535 ticks" }
 $durationLo += ($duration -band 255); $durationHi += (($duration -shr 8) -band 255)
 $entryBase += ($si * $Objects.Count)
 $nextId = if (Has-Property $state "next") { [string](Get-PropertyValue $state "next") } elseif ($si + 1 -lt $states.Count) { [string](Get-PropertyValue $states[$si + 1] "id" "state_$($si+1)") } elseif ([bool](Get-PropertyValue $state "loop" $false)) { [string](Get-PropertyValue $state "id" "state_$si") } else { [string](Get-PropertyValue $states[0] "id" "state_0") }
 if (-not $stateByName.ContainsKey($nextId)) { throw "timeline state $si references unknown next state '$nextId'" }
 $next += [int]$stateByName[$nextId]
 $instances = Get-PropertyValue $state "instances" $null
 for ($oi = 0; $oi -lt $Objects.Count; $oi++) {
 $name=[string]$Objects[$oi].Name; $action=$null
 if ($null -ne $instances -and (Has-Property $instances $name)) { $action=Get-PropertyValue $instances $name }
 $m0=0; $m1=0; $vis=0; $sc=0; $mat=255; $refl=255; $col=255
  $pos=@(0,0,0); $rot=@(0,0,0); $vel=@(0,0,0); $avel=@(0,0,0)
  if ($null -ne $action) {
  if (Has-Property $action "visibility") { Write-Warning "timeline field 'visibility' is ignored; use 'visible'" }
  if (Has-Property $action "visible") { $m0=$m0-bor 1; $vis=Read-SceneObjectVisible $action "$name timeline state $si"; $usesVisibility=$true }
 if (Has-Property $action "position") { $m0=$m0-bor 2; $pos=Read-ScenePosition $action $AxisConvention }
 if (Has-Property $action "rotation") { $m0=$m0-bor 4; $rot=Read-Fixed3 $action "rotation" @(0,0,0) 0 65535 $AxisConvention }
 if (Has-Property $action "scale") { $m0=$m0-bor 8; $sc=Read-Scale64 $action }
 if (Has-Property $action "materialOverride") { $m0=$m0-bor 16; $mat=Read-SceneObjectMaterial $action "$name timeline state $si"; $usesOverrides=$true }
 if (Has-Property $action "reflectivityOverride") { $m0=$m0-bor 32; $refl=Read-SceneObjectReflectivity $action "$name timeline state $si"; $usesOverrides=$true }
 if (Has-Property $action "colorOverride") { $m0=$m0-bor 64; $col=Read-SceneObjectColorOverride $action "$name timeline state $si"; $usesOverrides=$true; $usesColorOverride=$true }
 if (Has-Property $action "positionVelocity") { $m0=$m0-bor 128; $tmp=[pscustomobject]@{velocity=(Get-PropertyValue $action "positionVelocity")}; $vel=Read-SceneVelocity $tmp $AxisConvention; $usesVelocity=$true }
 if (Has-Property $action "rotationVelocity") { $m1=$m1-bor 1; $tmp=[pscustomobject]@{angularVelocity=(Get-PropertyValue $action "rotationVelocity")}; $avel=Read-Fixed3 $tmp "angularVelocity" @(0,0,0) -32768 32767 $AxisConvention; $usesAngularVelocity=$true }
 }
 $mask0+=$m0; $mask1+=$m1; $visible+=$vis; $scale+=$sc; $material+=$mat; $reflect+=$refl; $color+=$col
 $p0=Split-Fixed8 ([int]$pos[0]); $p1=Split-Fixed8 ([int]$pos[1]); $p2=Split-Fixed16_8 ([int]$pos[2])
 $pxlo+=$p0.Lo; $pxhi+=$p0.Hi; $pylo+=$p1.Lo; $pyhi+=$p1.Hi; $pzlo+=$p2.Frac; $pzhi+=$p2.Lo; $pzext+=$p2.Hi
 $r0=Split-Fixed8 ([int]$rot[0]); $r1=Split-Fixed8 ([int]$rot[1]); $r2=Split-Fixed8 ([int]$rot[2])
 $rxlo+=$r0.Lo; $rxhi+=$r0.Hi; $rylo+=$r1.Lo; $ryhi+=$r1.Hi; $rzlo+=$r2.Lo; $rzhi+=$r2.Hi
 $v0=Split-Fixed8 ([int]$vel[0]); $v1=Split-Fixed8 ([int]$vel[1]); $v2=Split-Fixed16_8 ([int]$vel[2])
 $vxlo+=$v0.Lo; $vxhi+=$v0.Hi; $vylo+=$v1.Lo; $vyhi+=$v1.Hi; $vzlo+=$v2.Frac; $vzhi+=$v2.Lo; $vzext+=$v2.Hi
 $a0=Split-Fixed8 ([int]$avel[0]); $a1=Split-Fixed8 ([int]$avel[1]); $a2=Split-Fixed8 ([int]$avel[2])
 $avxlo+=$a0.Lo; $avxhi+=$a0.Hi; $avylo+=$a1.Lo; $avyhi+=$a1.Hi; $avzlo+=$a2.Lo; $avzhi+=$a2.Hi
 }
 }
 $initialId=[string](Get-PropertyValue $Timeline "initialState" (Get-PropertyValue $states[0] "id" "state_0"))
 if (-not $stateByName.ContainsKey($initialId)) { throw "timeline initialState '$initialId' is unknown" }
 return [pscustomobject]@{ StateCount=$states.Count; Initial=[int]$stateByName[$initialId]; DurationLo=$durationLo; DurationHi=$durationHi; Next=$next; EntryBase=$entryBase; Mask0=$mask0; Mask1=$mask1; Visible=$visible; Scale=$scale; Material=$material; Reflect=$reflect; Color=$color; PxLo=$pxlo; PxHi=$pxhi; PyLo=$pylo; PyHi=$pyhi; PzLo=$pzlo; PzHi=$pzhi; PzExt=$pzext; RxLo=$rxlo; RxHi=$rxhi; RyLo=$rylo; RyHi=$ryhi; RzLo=$rzlo; RzHi=$rzhi; VxLo=$vxlo; VxHi=$vxhi; VyLo=$vylo; VyHi=$vyhi; VzLo=$vzlo; VzHi=$vzhi; VzExt=$vzext; AvxLo=$avxlo; AvxHi=$avxhi; AvyLo=$avylo; AvyHi=$avyhi; AvzLo=$avzlo; AvzHi=$avzhi; UsesVelocity=$usesVelocity; UsesAngularVelocity=$usesAngularVelocity; UsesVisibility=$usesVisibility; UsesOverrides=$usesOverrides; UsesColorOverride=$usesColorOverride }
}

Reset-Mesh
if ($SceneFile.Trim().Length -gt 0) {
 if ($MeshFile.Trim().Length -gt 0) {
 throw "SceneFile and MeshFile are mutually exclusive"
 }
 Import-SceneFile $SceneFile
} elseif ($MeshFile.Trim().Length -gt 0) {
 Begin-MeshRecord "imported"
 Import-MeshFile $MeshFile
 End-MeshRecord $MeshName
} else {
 switch ($Mesh) {
 "torus6x6" {
 $MeshName = "torus_6x6_lit_quads"
 Begin-MeshRecord $MeshName
 Add-TorusMesh 6 6 30 10
 End-MeshRecord
 }
 "torus8x6" {
 $MeshName = "torus_8x6_lit_quads"
 Begin-MeshRecord $MeshName
 Add-TorusMesh 8 6 30 10
 End-MeshRecord
 }
 "torus10x6" {
 $MeshName = "torus_10x6_lit_quads"
 Begin-MeshRecord $MeshName
 Add-TorusMesh 10 6 30 10
 End-MeshRecord
 }
 "torus12x6" {
 $MeshName = "torus_12x6_lit_quads"
 Begin-MeshRecord $MeshName
 Add-TorusMesh 12 6 30 10
 End-MeshRecord
 }
 "cube" {
 $MeshName = "cube_6_quads"
 Begin-MeshRecord $MeshName
 Add-CubeMesh 28
 End-MeshRecord
 }
 "dual" {
 $MeshName = "dual_cube_torus8x6"
 Begin-MeshRecord "cube_6_quads"
 Add-CubeMesh 28
 End-MeshRecord
 Begin-MeshRecord "torus_8x6_lit_quads"
 Add-TorusMesh 8 6 30 10
 End-MeshRecord
 }
 "dual_low" {
 $MeshName = "dual_cube_torus6x6"
 Begin-MeshRecord "cube_6_quads"
 Add-CubeMesh 28
 End-MeshRecord
 Begin-MeshRecord "torus_6x6_lit_quads"
 Add-TorusMesh 6 6 30 10
 End-MeshRecord
 }
 }
}

$SceneTimelineCompiled = Compile-SceneTimeline $SceneTimelineObject @($SceneObjects) $SceneAxisConvention
$SceneTimelineFlag = if ($null -ne $SceneTimelineCompiled) { 1 } else { 0 }
$SceneGraphicIncludeFlag = if ($SceneGraphicIncludeText.Length -gt 0) { 1 } else { 0 }
if ($SceneTimelineFlag -ne 0) { $ControlSpaceFlag = 1 }
$SceneLightCount = @($SceneLightObjects).Count
if ($SceneLightCount -gt 1) {
 throw "This milestone supports at most one scene lamp/light object; extra lights would not be consumed by runtime tables"
}
$ScenePrimaryLightIndex = if ($SceneLightCount -gt 0) { 0 } else { 255 }
$SceneExtraLightIgnoredCount = 0
$EffectiveLightSource = "procedural"
$EffectiveLightIntensity = $LightIntensity
$EffectiveLightPulse = $LightPulse.IsPresent
$ScenePrimaryLight = $null
if ($SceneLightCount -gt 0) {
 $ScenePrimaryLight = @($SceneLightObjects)[0]
 $EffectiveLightSource = "scene:$($ScenePrimaryLight.name):$($ScenePrimaryLight.mode)"
 $LightPhaseCount = [int]$ScenePrimaryLight.phaseCount
 $LightTickDiv = [int]$ScenePrimaryLight.tickDiv
 $LightOrbit = [string]$ScenePrimaryLight.orbit
 $LightStaticPhase = [int]$ScenePrimaryLight.staticPhase
 $EffectiveLightIntensity = [int]$ScenePrimaryLight.intensity
 $EffectiveLightPulse = [bool]$ScenePrimaryLight.pulse
}
$SceneStaticRuntimeLightFlag = if ($SceneLightCount -gt 0 -and $ScenePrimaryLight.mode -eq "static" -and [bool]$ScenePrimaryLight.runtimeStatic) { 1 } else { 0 }
if ($SceneStaticRuntimeLightFlag -ne 0) {
 # A static runtime light still drives Mode 4/5 shading as the object rotates,
 # but it has one immutable sample and no orbital phase scheduler.
 $LightTickDiv = 1
 $LightStaticPhase = 0
 $EffectiveLightPulse = $false
}
$RuntimeLightPhaseCount = if ($SceneStaticRuntimeLightFlag -ne 0) { 1 } else { $LightPhaseCount }
$StaticShadeFallbackPhase = 16
$StaticShadeLightPhase = if ($LightStaticPhase -ge 0) {
 $LightStaticPhase
} elseif ($SceneLightCount -eq 0) {
 $StaticShadeFallbackPhase
} else {
 0
}
if ($SceneLightCount -gt 0 -and $ScenePrimaryLight.mode -eq "static") {
 $StaticShadeLightPosition = [int[]]@(
 [int]$ScenePrimaryLight.position[0],
 [int]$ScenePrimaryLight.position[1],
 [int]$ScenePrimaryLight.position[2]
 )
} else {
 $StaticShadeLightPosition = Get-LightPositionForSceneAxes $StaticShadeLightPhase $LightPhaseCount $LightOrbit $SceneAxisConvention
}
$StaticShadeLightSource = "${EffectiveLightSource}:phase$StaticShadeLightPhase"
$CameraSource = "default"
if ($CameraFile.Trim().Length -gt 0) {
 $CameraObjects = Read-CameraObjects $CameraFile
 $CameraSource = "cameraFile"
} elseif ($null -ne $SceneCameraObject) {
 if ($CameraIndex -ne 0) {
 throw "CameraIndex must be 0 when using SceneFile camera without CameraFile"
 }
 $CameraObjects = @($SceneCameraObject)
 $CameraSource = "scene"
} else {
 $CameraObjects = Read-CameraObjects ""
}
$CameraObjects = @($CameraObjects)
if ($CameraIndex -lt 0 -or $CameraIndex -ge $CameraObjects.Count) {
 throw "CameraIndex out of range: $CameraIndex"
}
$CameraObject = $CameraObjects[$CameraIndex]
$CameraName = if ($CameraObject.PSObject.Properties.Name -contains "name") { [string]$CameraObject.name } else { "camera_$CameraIndex" }
if (-not ($CameraObject.PSObject.Properties.Name -contains "position")) {
 throw "Camera object missing position: $CameraName"
}
if (-not ($CameraObject.PSObject.Properties.Name -contains "rotation")) {
 throw "Camera object missing rotation: $CameraName"
}
$CameraPosition = @($CameraObject.position)
$CameraRotation = @($CameraObject.rotation)
if ($CameraPosition.Count -ne 3) { throw "Camera position must have 3 values: $CameraName" }
if ($CameraRotation.Count -ne 3) { throw "Camera rotation must have 3 values: $CameraName" }
$CameraX = [int]$CameraPosition[0]
$CameraY = [int]$CameraPosition[1]
$CameraZ = [int]$CameraPosition[2]
$Mode2GroundCameraBoundaryFlag = if ($GraphicsModeNumber -eq 2 -and
 @($WorldGrounds | Where-Object { [int]$_.Enabled -ne 0 }).Count -gt 0) { 1 } else { 0 }
$CameraCoordinateMin = if ($Mode2GroundCameraBoundaryFlag -ne 0) { -64 } else { -63 }
$CameraCoordinateMax = if ($Mode2GroundCameraBoundaryFlag -ne 0) { 64 } else { 63 }
foreach ($c in @($CameraX,$CameraY,$CameraZ)) {
 if ($c -lt $CameraCoordinateMin -or $c -gt $CameraCoordinateMax) {
 throw "Camera coordinate out of supported engine range ($CameraCoordinateMin..$CameraCoordinateMax): $c"
 }
}
$CameraPitch = [int]$CameraRotation[0]
$CameraYaw = [int]$CameraRotation[1]
$CameraRoll = [int]$CameraRotation[2]
foreach ($r in @($CameraPitch,$CameraYaw,$CameraRoll)) {
 if ($r -lt 0 -or $r -gt 255) {
 throw "Camera rotation phase must be in byte range 0..255: $r"
 }
}
$EffectiveCameraMode = "fixed"
if (($CameraObject.PSObject.Properties.Name -contains "mode") -and ([string]$CameraObject.mode).Trim().Length -gt 0) {
 $SceneCameraMode = ([string]$CameraObject.mode).Trim()
 if (-not ($ValidCameraModes -contains $SceneCameraMode)) {
 throw "Camera mode must be one of: fixed, walkLite, walkFull"
 }
 $EffectiveCameraMode = $SceneCameraMode
}
if ($RequestedCameraMode.Length -gt 0) {
 $EffectiveCameraMode = $RequestedCameraMode
}

# Resolve the public Mode 4/5 projection only after the effective camera mode
# is known. Explicit input selectors remain diagnostic overrides; the legacy
# switches are accepted but are redundant for the public Mode 4 profile.
if ($Mode4FamilyFlag -ne 0) {
 $SolidSubpixelXQ2Flag = 1
 $SolidSubpixelYQ2Flag = 1
 if (-not $PSBoundParameters.ContainsKey("SolidSubpixelXInput")) {
  $SolidSubpixelXInput = "LegacyDirect"
 }
 if (-not $PSBoundParameters.ContainsKey("SolidSubpixelYInput")) {
  $SolidSubpixelYInput = if ($EffectiveCameraMode -eq "fixed") { "Native" } else { "MobileNative" }
 }
 $Mode4ShadeStepLimitFlag = if ($Mode4ShadeStepLimit.IsPresent -or -not $Mode4ValidShadeFaceProbe.IsPresent) { 1 } else { 0 }
 $YQ2FastDiv11x8Flag = 1
 $YQ2FastPixelConvertFlag = 1
 $YQ2InlineBoundsFlag = 1

 $SolidSubpixelXNativeFlag = if ($SolidSubpixelXInput -eq "Native") { 1 } else { 0 }
 $SolidSubpixelXLegacyDirectFlag = if ($SolidSubpixelXInput -eq "LegacyDirect") { 1 } else { 0 }
 $SolidSubpixelYNativeFlag = if ($SolidSubpixelYInput -eq "Native") { 1 } else { 0 }
 $SolidSubpixelYLegacyDirectFlag = if ($SolidSubpixelYInput -eq "LegacyDirect") { 1 } else { 0 }
 $SolidSubpixelYLegacyBufferedFlag = if ($SolidSubpixelYInput -eq "LegacyBuffered") { 1 } else { 0 }
 $SolidSubpixelYLegacyPhase1Flag = if ($SolidSubpixelYInput -eq "LegacyPhase1") { 1 } else { 0 }
 $SolidSubpixelYNativeQuantizedFlag = if ($SolidSubpixelYInput -eq "NativeQuantized") { 1 } else { 0 }
 $SolidSubpixelYMobileNativeFlag = if ($SolidSubpixelYInput -eq "MobileNative") { 1 } else { 0 }
 $SolidSubpixelYBufferedSourceFlag = if ($SolidSubpixelYNativeFlag -ne 0 -or $SolidSubpixelYLegacyBufferedFlag -ne 0 -or $SolidSubpixelYLegacyPhase1Flag -ne 0 -or $SolidSubpixelYNativeQuantizedFlag -ne 0) { 1 } else { 0 }
 $SolidSubpixelYEndpointBufferFlag = if ($SolidSubpixelYBufferedSourceFlag -ne 0 -or $SolidSubpixelYMobileNativeFlag -ne 0) { 1 } else { 0 }
 $SolidSubpixelYProjectionNativeFlag = if ($SolidSubpixelYNativeFlag -ne 0 -or $SolidSubpixelYNativeQuantizedFlag -ne 0 -or $SolidSubpixelYMobileNativeFlag -ne 0) { 1 } else { 0 }
 $SolidSubpixelXYQ2LegacyDirectYFlag = if ($SolidSubpixelXQ2Flag -ne 0 -and $SolidSubpixelXLegacyDirectFlag -ne 0 -and $SolidSubpixelYQ2Flag -ne 0) { 1 } else { 0 }
 $Mode4FaceIdLatchFlag = if ($SolidSubpixelXYQ2LegacyDirectYFlag -ne 0) { 1 } else { 0 }
}
$CameraMovableFlag = if ($EffectiveCameraMode -ne "fixed") { 1 } else { 0 }
$EmitRenderSceneObjectsFlag = if ($CameraMovableFlag -eq 0 -or $GraphicsModeNumber -eq 1) { 1 } else { 0 }
$CameraWalkLiteFlag = if ($EffectiveCameraMode -eq "walkLite") { 1 } else { 0 }
$CameraWalkFullFlag = if ($EffectiveCameraMode -eq "walkFull") { 1 } else { 0 }
$CameraSmoothDepthActiveFlag = 0
$CameraSmoothDepthPhaseStart = 0
$CameraSmoothDepthPhaseStep = 0
$cameraSmoothDepthPosLo = @()
$cameraSmoothDepthPosHi = @()
$cameraSmoothDepthPosExt = @()
if ($CameraSource -eq "scene" -and ($CameraObject.PSObject.Properties.Name -contains "depthPingPong")) {
 $cameraSmoothDepth = $CameraObject.depthPingPong
 if ([int]$cameraSmoothDepth.Enabled -ne 0) {
 if ($CameraMovableFlag -eq 0) {
 throw "Scene camera depthPingPong requires camera mode walkLite or walkFull"
 }
 $CameraSmoothDepthActiveFlag = 1
 $CameraSmoothDepthPhaseStart = [int]$cameraSmoothDepth.PhaseStart
 $CameraSmoothDepthPhaseStep = [int]$cameraSmoothDepth.PhaseStep
 $minFixed = [int]$cameraSmoothDepth.MinFixed
 $spanFixed = [int]$cameraSmoothDepth.MaxFixed - $minFixed
 for ($phase = 0; $phase -lt 256; $phase++) {
 $unitPosition = (1.0 + [Math]::Sin((2.0 * [Math]::PI * [double]$phase) / 256.0)) / 2.0
 $positionFixed = [int][Math]::Round([double]$minFixed + ([double]$spanFixed * $unitPosition))
 $positionParts = Split-Fixed16_8 $positionFixed
 $cameraSmoothDepthPosLo += [int]$positionParts.Frac
 $cameraSmoothDepthPosHi += [int]$positionParts.Lo
 $cameraSmoothDepthPosExt += [int]$positionParts.Hi
 }
 }
}
$CameraModeCycleFlag = 0
if ($CameraWalkLiteFlag -ne 0) {
 $CameraRoll = 0
}
$CameraRuntimeControlsFlag = if ($CameraMovableFlag -ne 0 -and -not $NoCameraRuntimeControls.IsPresent) { 1 } else { 0 }
$CameraWalkFullCompiledFlag = $CameraWalkFullFlag
$CameraRollControlFlag = if ($CameraWalkFullCompiledFlag -ne 0 -and $CameraRuntimeControlsFlag -ne 0) { 1 } else { 0 }
$CameraRollActiveFlag = if ($CameraWalkFullCompiledFlag -ne 0 -and ($CameraRollControlFlag -ne 0 -or $CameraRoll -ne 0)) { 1 } else { 0 }
$EngineCameraProfileRuntimeFlag = $CameraMovableFlag
$EngineCameraWalkLiteRuntimeFlag = $CameraWalkLiteFlag
$EngineCameraModeCycleRuntimeFlag = 0
$EngineCameraRollRuntimeFlag = $CameraRollActiveFlag
$EngineCameraWalkLitePitchRuntimeFlag = $CameraWalkLiteFlag
$EngineCameraWalkLitePitchAllModesFlag = $EngineCameraWalkLitePitchRuntimeFlag
$EngineCameraWalkLiteYawPitchOnlyFlag = $EngineCameraWalkLitePitchRuntimeFlag
$EngineCameraWalkLitePitchZeroFastpathFlag = $EngineCameraWalkLitePitchRuntimeFlag
$EngineCameraPitchTrigZeroFastpathFlag = $EngineCameraWalkLitePitchRuntimeFlag
$EngineCameraFoldedPitchZeroFastpathFlag = $EngineCameraWalkLitePitchRuntimeFlag
$EngineCameraRollLockFlag = if ($CameraWalkLiteFlag -ne 0) { 1 } else { 0 }
$EngineCameraPitchRollLockFlag = 0
$EngineWireCameraThroughMeshFlag = if ($EngineWireModeRuntimeFlag -ne 0 -and $CameraMovableFlag -ne 0) { 1 } else { 0 }
$EngineWireNearClipRelaxedFlag = $EngineWireCameraThroughMeshFlag
$EngineWireObjectRejectRelaxedFlag = $EngineWireCameraThroughMeshFlag
$EngineWireEdgeClipTolerantFlag = $EngineWireCameraThroughMeshFlag
$EngineMode2FaceMaskNearTolerantFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0 -and $EngineWireCameraThroughMeshFlag -ne 0) { 1 } else { 0 }
$CameraFullRuntimeFlag = $CameraWalkFullFlag
$ExplorerRuntimeModeInitial = if ($CameraWalkLiteFlag -ne 0) { 1 } else { 2 }
$ExplorerResetOnSpaceFlag = if (($CameraMovableFlag -ne 0) -and $ExplorerResetOnSpace.IsPresent) { 1 } else { 0 }
$WorldGroundPlaneRequestedFlag = if (@($WorldGrounds | Where-Object { [int]$_.Enabled -ne 0 -and [string]$_.Mode -eq "plane" }).Count -gt 0) { 1 } else { 0 }
$ExplorerNearClipFlag = if (($CameraMovableFlag -ne 0 -or $WorldGroundPlaneRequestedFlag -ne 0) -and ($ExplorerClipMode -eq "near" -or $WorldGroundPlaneRequestedFlag -ne 0)) { 1 } else { 0 }
$ExplorerNearSkipCrossFlag = if ($WorldGroundPlaneRequestedFlag -eq 0 -and $WireOnlyRenderFlag -eq 0 -and $ExplorerNearClipFlag -ne 0 -and $ExplorerNearCrossMode -eq "skip") { 1 } else { 0 }
$ExplorerNearFillFlag = if ($ExplorerNearClipFlag -ne 0 -and $ExplorerNearCrossMode -eq "fill") { 1 } else { 0 }
$ExplorerTraversalCullFlag = if (($CameraMovableFlag -ne 0) -and $ExplorerTraversalCullMode -ne "normal") { 1 } else { 0 }
$ExplorerScreenClipXFlag = if (($CameraMovableFlag -ne 0) -and $ExplorerScreenClipMode -eq "x") { 1 } else { 0 }
$ExplorerScreenClipPolyRequestedFlag = if (($CameraMovableFlag -ne 0) -and $ExplorerScreenClipMode -eq "poly") { 1 } else { 0 }
$ExplorerCameraNearClipFlag = if ($ExplorerNearClipFlag -ne 0 -and ($ExplorerScreenClipPolyRequestedFlag -ne 0 -or $WorldGroundPlaneRequestedFlag -ne 0)) { 1 } else { 0 }
$ExplorerCameraXClipFlag = if ($ExplorerNearClipFlag -ne 0 -and ($ExplorerScreenClipPolyRequestedFlag -ne 0 -or $WorldGroundPlaneRequestedFlag -ne 0)) { 1 } else { 0 }
$ExplorerNearPolyRequestedFlag = if ($WorldGroundPlaneRequestedFlag -ne 0 -or ($ExplorerNearClipFlag -ne 0 -and ($ExplorerNearCrossMode -eq "poly" -or $ExplorerNearCrossMode -eq "fill"))) { 1 } else { 0 }
$ExplorerNearPolyFlag = if ($ExplorerNearPolyRequestedFlag -ne 0 -or $ExplorerCameraNearClipFlag -ne 0) { 1 } else { 0 }
if ($Mode4CameraPlaneClipRequested) {
 # The clip profile supplies its own depth-0 pass and projection.  Ground
 # still supplies the first polygon, but must not pull in the legacy near
 # polygon or four camera-frustum passes.
 $ExplorerCameraNearClipFlag = 0
 $ExplorerCameraXClipFlag = 0
 $ExplorerNearPolyFlag = 0
}
$ExplorerScreenClipPolyFlag = if ($Mode4CameraPlaneClipRequested -or (($CameraMovableFlag -ne 0 -or $WorldGroundPlaneRequestedFlag -ne 0) -and ($ExplorerScreenClipPolyRequestedFlag -ne 0 -or $ExplorerNearPolyFlag -ne 0))) { 1 } else { 0 }
$WireScreenRawFlag = if (($WireRenderFlag -ne 0) -and ($CameraMovableFlag -ne 0)) { 1 } else { 0 }
$ExplorerScreenRawFlag = if (($ExplorerScreenClipXFlag -ne 0) -or ($ExplorerScreenClipPolyFlag -ne 0) -or ($ExplorerNearPolyFlag -ne 0) -or ($WireScreenRawFlag -ne 0)) { 1 } else { 0 }
$StandardProjectVertexFlag = if ($CameraMovableFlag -ne 0) { 0 } else { 1 }
$Mode5HighBasicQ2ProfileFlag = if ($Mode4FamilyFlag -ne 0 -and $MemoryLayout -eq "high-basic-v2") { 1 } else { 0 }
$SolidSubpixelQ2CoreProfileFlag = if ($Mode4FamilyFlag -ne 0 -and ($CameraViewportKey -eq "small" -or $CameraViewportKey -eq "normal") -and ($MemoryLayout -eq "stable" -or $Mode5HighBasicQ2ProfileFlag -ne 0) -and $PolyFillFlag -eq 1 -and $WireRenderFlag -eq 0 -and $HiddenWireFlag -eq 0 -and $FaceRenderMode -ne "force") { 1 } else { 0 }
$SolidSubpixelQ2FixedProfileFlag = if ($SolidSubpixelQ2CoreProfileFlag -ne 0 -and $EffectiveCameraMode -eq "fixed" -and $StandardProjectVertexFlag -eq 1 -and $SolidSubpixelYMobileNativeFlag -eq 0) { 1 } else { 0 }
$SolidSubpixelQ2MobileProfileFlag = if ($SolidSubpixelQ2CoreProfileFlag -ne 0 -and $CameraMovableFlag -ne 0 -and $StandardProjectVertexFlag -eq 0 -and $SolidSubpixelXQ2Flag -eq 1 -and $SolidSubpixelXLegacyDirectFlag -eq 1 -and $SolidSubpixelYQ2Flag -eq 1 -and $SolidSubpixelYMobileNativeFlag -eq 1 -and $ExplorerScreenClipPolyFlag -eq 1) { 1 } else { 0 }
if ($SolidSubpixelXQ2Flag -ne 0 -or $SolidSubpixelYQ2Flag -ne 0) {
 if ($SolidSubpixelQ2FixedProfileFlag -eq 0 -and $SolidSubpixelQ2MobileProfileFlag -eq 0) {
  throw "SolidSubpixel XY Q2 requires the fixed/small/stable profile, or the Phase-1 walkLite/walkFull MobileNative profile with X=LegacyDirect and existing poly screen clipping enabled."
 }
 if (($SolidSubpixelXNativeFlag -ne 0 -or $SolidSubpixelYProjectionNativeFlag -ne 0) -and $Projection -eq "reference") {
  throw "SolidSubpixel Native input requires a multiplication-based RC4 projection (table or extended-table)."
 }
}
if ($Mode4PatternProbeFlag -ne 0) {
 if ($GraphicsModeNumber -ne 4 -or $EffectiveCameraMode -ne "fixed" -or $CameraViewportKey -ne "small" -or $MemoryLayout -ne "stable" -or $SolidSubpixelXQ2Flag -ne 1 -or $SolidSubpixelXLegacyDirectFlag -ne 1 -or $SolidSubpixelYQ2Flag -ne 1 -or $SolidSubpixelYLegacyDirectFlag -ne 1 -or $PolyFillFlag -ne 1 -or $WireRenderFlag -ne 0 -or $HiddenWireFlag -ne 0 -or $StandardProjectVertexFlag -ne 1) {
  throw "Mode4PatternProbe requires Mode 4, fixed/small/stable solid rendering with X=LegacyDirect and Y=LegacyDirect under both Q2 gates."
 }
}
if ($Mode4PatternProbeLatchedFaceFlag -ne 0) {
 if ($GraphicsModeNumber -ne 4 -or $EffectiveCameraMode -ne "fixed" -or $CameraViewportKey -ne "small" -or $MemoryLayout -ne "stable" -or $SolidSubpixelXQ2Flag -ne 1 -or $SolidSubpixelXLegacyDirectFlag -ne 1 -or $SolidSubpixelYQ2Flag -ne 1 -or $SolidSubpixelYLegacyDirectFlag -ne 1 -or $PolyFillFlag -ne 1 -or $WireRenderFlag -ne 0 -or $HiddenWireFlag -ne 0 -or $StandardProjectVertexFlag -ne 1) {
  throw "Mode4PatternProbeLatchedFace requires Mode 4, fixed/small/stable solid rendering with X=LegacyDirect and Y=LegacyDirect under both Q2 gates."
 }
}
if ($Mode4ValidShadeFaceProbeFlag -ne 0) {
 if ($GraphicsModeNumber -ne 4 -or $EffectiveCameraMode -ne "fixed" -or $CameraViewportKey -ne "small" -or $MemoryLayout -ne "stable" -or $SolidSubpixelXQ2Flag -ne 1 -or $SolidSubpixelXLegacyDirectFlag -ne 1 -or $SolidSubpixelYQ2Flag -ne 1 -or $SolidSubpixelYLegacyDirectFlag -ne 1 -or $PolyFillFlag -ne 1 -or $WireRenderFlag -ne 0 -or $HiddenWireFlag -ne 0 -or $StandardProjectVertexFlag -ne 1) {
  throw "Mode4ValidShadeFaceProbe requires Mode 4, fixed/small/stable solid rendering with X=LegacyDirect and Y=LegacyDirect under both Q2 gates."
 }
}
if ($Mode4ShadeStepLimitFlag -ne 0) {
 $Mode4ShadeStepLimitFixedProfileFlag = if ($SolidSubpixelQ2FixedProfileFlag -ne 0 -and $SolidSubpixelXQ2Flag -eq 1 -and $SolidSubpixelXLegacyDirectFlag -eq 1 -and $SolidSubpixelYQ2Flag -eq 1 -and $SolidSubpixelYNativeFlag -eq 1) { 1 } else { 0 }
 $Mode4ShadeStepLimitMobileProfileFlag = if ($SolidSubpixelQ2MobileProfileFlag -ne 0) { 1 } else { 0 }
 if ($Mode4ShadeStepLimitFixedProfileFlag -eq 0 -and $Mode4ShadeStepLimitMobileProfileFlag -eq 0) {
  throw "Mode4ShadeStepLimit requires the fixed Native-Y or Phase-1 mobile MobileNative-Y Mode 4 XY-Q2 profile."
 }
}
# projdone is authoritative after engine movable-camera projection for every mesh vertex.
# The fixed-camera path retains wire_vertex_drawable as the compile-time fallback.
$EngineMode1UniversalEdgeTraversalFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0 -and ($CameraMovableFlag -ne 0)) { 1 } else { 0 }
$EngineMode1ProjdoneDirectTestFlag = $EngineMode1UniversalEdgeTraversalFlag
$ExplorerTableProjectionFlag = 0
$TrackDirtySpansFlag = if ($FullClearFlag -eq 0 -and $CameraMovableFlag -eq 0) { 1 } else { 0 }
if ($EngineWireDirtyClearFlag -ne 0) {
 $TrackDirtySpansFlag = 1
}
$DynamicLightFlag = if ($DynamicLight.IsPresent -or $SceneLightCount -gt 0) { 1 } else { 0 }
if ($WireOnlyRenderFlag -ne 0 -or $StaticShadeCacheFlag -ne 0) {
 $DynamicLightFlag = 0
 $ControlLightFlag = 0
 $ControlReflectivityFlag = 0
}
if ($EngineWireLightShadingStrippedFlag -ne 0) {
 $DynamicLightFlag = 0
 $ControlLightFlag = 0
 $ControlReflectivityFlag = 0
 $LightPulseOnSpaceFlag = 0
}
$Mode4DynamicShadeThresholdFixFlag = if ($Mode4FamilyFlag -ne 0 -and $FullDynamicShadeFlag -ne 0 -and $DynamicLightFlag -ne 0) { 1 } else { 0 }
if ($Mode4ShadeStepLimitFlag -ne 0 -and $Mode4DynamicShadeThresholdFixFlag -eq 0) {
 throw "Mode4ShadeStepLimit requires the Mode 4 DynamicLight Q6 shade path."
}
if ($HighBasicV2LayoutFlag -ne 0 -and $FullDynamicShadeFlag -ne 0 -and $DynamicLightFlag -ne 0) {
 $FrameFaceFillCacheFlag = 1
}
$CameraHasPos = if ($CameraX -ne 0 -or $CameraY -ne 0 -or $CameraZ -ne 0) { 1 } else { 0 }
$CameraHasRot = if ($CameraPitch -ne 0 -or $CameraYaw -ne 0 -or $CameraRoll -ne 0) { 1 } else { 0 }
$CameraMatrix = Get-CameraMatrix $CameraPitch $CameraYaw $CameraRoll
$ExplorerCameraX = $CameraX
$ExplorerCameraY = $CameraY
$ExplorerCameraZ = $CameraZ
if (($CameraMovableFlag -ne 0) -and $CameraSource -eq "default" -and
 $CameraX -eq 0 -and $CameraY -eq 0 -and $CameraZ -eq 0) {
 $ExplorerCameraZ = -64
}
$ExplorerCameraXLo = 0
$ExplorerCameraYLo = 0
$ExplorerCameraZLo = 0
$ExplorerCameraXHi = $ExplorerCameraX -band 255
$ExplorerCameraYHi = $ExplorerCameraY -band 255
$ExplorerCameraZHi = $ExplorerCameraZ -band 255
$ExplorerCameraXExt = (($ExplorerCameraX -shr 8) -band 255)
$ExplorerCameraYExt = (($ExplorerCameraY -shr 8) -band 255)
$ExplorerCameraZExt = (($ExplorerCameraZ -shr 8) -band 255)

Validate-SceneObjectDepthDomains $EffectiveCameraMode

$SourceVertexCount = $MeshVertices.Count
$SourceFaceCount = $MeshFaces.Count
$MeshCount = $MeshRecords.Count
$SceneObjectCount = $SceneObjects.Count
$MeshSourceSharingRuntimeFlag = if ($SceneSourceSharingRequested) { 1 } else { 0 }
if ($MeshSourceSharingRuntimeFlag -ne 0) {
 $VertexCount = 0
 $FaceCount = 0
 foreach ($object in $SceneObjects) {
  $record = $MeshRecords[[int]$object.MeshIndex]
  $VertexCount += [int]$record.VertexCount
  $FaceCount += [int]$record.FaceCount
 }
} else {
 $VertexCount = $SourceVertexCount
 $FaceCount = $SourceFaceCount
}
$ObjectModelContractVersion = 1
$WorldSpaceZUpFlag = if ($SceneAxisConvention -eq "world-z-up") { 1 } else { 0 }
$ObjectSpaceAlignedWorldFlag = if ($WorldSpaceZUpFlag -ne 0 -and $SceneFile.Trim().Length -gt 0) { 1 } else { 0 }
$SceneWorldObjectPresentFlag = 1
$SceneCameraObjectPresentFlag = 1
$SceneMeshObjectCount = $SceneObjectCount
$MeshInstanceExpansionModeFlag = if ($SceneObjectCount -gt 0 -and $MeshSourceSharingRuntimeFlag -eq 0) { 1 } else { 0 }
$WorldGroundCount = @($WorldGrounds).Count
$WorldGroundEnabledCount = @($WorldGrounds | Where-Object { [int]$_.Enabled -ne 0 }).Count
$WorldGroundActiveList = @($WorldGrounds | Where-Object { [int]$_.Enabled -ne 0 } | Select-Object -First 1)
$WorldGroundActive = if ($WorldGroundActiveList.Count -gt 0) { $WorldGroundActiveList[0] } else { $null }
$WorldGroundEnableFlag = if ($null -ne $WorldGroundActive) { 1 } else { 0 }
$WorldGroundMode = if ($null -ne $WorldGroundActive) { [string]$WorldGroundActive.Mode } else { "none" }
$WorldGroundPlaneFlag = if ($WorldGroundMode -eq "plane") { 1 } else { 0 }
if ($WorldGroundPlaneFlag -ne 0 -and $GraphicsModeNumber -lt 2) {
 throw "world ground mode 'plane' is available only in GraphicsMode 2, 3, 4, or 5"
}
$WorldGroundColor = if ($null -ne $WorldGroundActive) { [int]$WorldGroundActive.Color } else { 5 }
$WorldGroundScreenByte = (($WorldGroundColor -shl 4) -bor $WorldGroundColor) -band 255
$WorldGroundColorRam = $WorldGroundColor -band 15
$WorldGroundY = if ($null -ne $WorldGroundActive) { [int]$WorldGroundActive.EngineY } else { 0 }
$WorldGroundYSplit = Split-Fixed8 $WorldGroundY
$WorldGroundYExt = if ($WorldGroundY -lt 0) { 0xff } else { 0x00 }
$WorldGroundOccludeFlag = if ($WorldGroundEnableFlag -ne 0 -and
 ($WorldGroundPlaneFlag -ne 0 -or $CameraMovableFlag -ne 0 -or $WorldGroundActive.Occlude -ne 0) -and
 ($WireOnlyRenderFlag -eq 0 -or $HiddenWireFlag -ne 0) -and
 $SceneObjectCount -gt 0) { 1 } else { 0 }
$WorldGroundHorizonOnlyFlag = if ($WorldGroundEnableFlag -ne 0 -and $WorldGroundPlaneFlag -eq 0 -and $WireOnlyRenderFlag -ne 0) { 1 } else { 0 }
$WorldGroundWireOccludeFlag = if ($WorldGroundHorizonOnlyFlag -ne 0 -and
 $HiddenWireFlag -ne 0 -and
 $SceneObjectCount -gt 0) { 1 } else { 0 }
$WorldGroundHorizonBBoxOccludeFlag = 0
$WorldGroundRollSpanEdgeFlag = if ($WorldGroundEnableFlag -ne 0 -and $GraphicsModeNumber -ge 3 -and
 $CameraRollActiveFlag -ne 0 -and
 $WorldGroundHorizonOnlyFlag -eq 0 -and
 -not $NoWorldGroundSpanEdge.IsPresent) { 1 } else { 0 }
# 0 = procedural prefill/background path outside VIC color owner arbitration.
$WorldGroundVicPolicyScopeFlag = 0
$EngineGroundHorizonOnlyRuntimeFlag = if ($RendererActiveFlag -ne 0 -and $WorldGroundEnableFlag -ne 0 -and $WorldGroundPlaneFlag -eq 0 -and ($GraphicsModeNumber -eq 1 -or $GraphicsModeNumber -eq 2)) { 1 } else { 0 }
$EngineGroundSimpleRuntimeFlag = if ($RendererActiveFlag -ne 0 -and $WorldGroundEnableFlag -ne 0 -and $WorldGroundPlaneFlag -eq 0 -and $EngineGroundHorizonOnlyRuntimeFlag -eq 0) { 1 } else { 0 }
# GraphicsMode 3 engine clears sky and prefills ground in one row pass.
# The validated clear + simple-ground renderer remains compiled as fallback.
$EngineMode3FramePrefillRuntimeFlag = if ($RendererActiveFlag -ne 0 -and $GraphicsModeNumber -eq 3 -and $EngineGroundSimpleRuntimeFlag -ne 0) { 1 } else { 0 }
$EngineMode3ClearGroundFusedFlag = $EngineMode3FramePrefillRuntimeFlag
$EngineMode3GroundCellrowWriteOnChangeFlag = $EngineMode3FramePrefillRuntimeFlag
$EngineMode3PrefillFallbackFlag = $EngineMode3FramePrefillRuntimeFlag
# cache the result of the collection-time face preparation for engine mode 3.
# Fully in-viewport faces reload only projected vertices during the draw pass; clipped/near
# faces keep the complete, already validated load/clip path.
$EngineMode3FacePrepareOnceFlag = if ($RendererActiveFlag -ne 0 -and $GraphicsModeNumber -eq 3 -and $SceneObjectCount -gt 0) { 1 } else { 0 }
$EngineMode3PreparedFaceStateCacheFlag = $EngineMode3FacePrepareOnceFlag
$EngineMode3UnclippedFaceFastloadFlag = $EngineMode3FacePrepareOnceFlag
$EngineMode3ClipFallbackFlag = $EngineMode3FacePrepareOnceFlag
$EngineMode3DrawRecheckStrippedFlag = $EngineMode3FacePrepareOnceFlag
$GroundFullRuntimeFlag = $WorldGroundPlaneFlag
$Mode2GroundPlaneLineRuntimeFlag = if ($RendererActiveFlag -ne 0 -and
 $GraphicsModeNumber -eq 2 -and
 $WorldGroundEnableFlag -ne 0 -and
 $WorldGroundPlaneFlag -ne 0) { 1 } else { 0 }
$RuntimeWorldGroundOccludeFlag = if ($EngineGroundSimpleRuntimeFlag -ne 0 -or $EngineGroundHorizonOnlyRuntimeFlag -ne 0) { 0 } else { $WorldGroundOccludeFlag }
$RuntimeWorldGroundHorizonOnlyFlag = if ($Mode2GroundPlaneLineRuntimeFlag -ne 0) { 1 } elseif ($EngineGroundHorizonOnlyRuntimeFlag -ne 0) { 1 } elseif ($EngineGroundSimpleRuntimeFlag -ne 0) { 0 } else { $WorldGroundHorizonOnlyFlag }
$RuntimeWorldGroundWireOccludeFlag = 0
$RuntimeWorldGroundHorizonBBoxOccludeFlag = if ($EngineGroundSimpleRuntimeFlag -ne 0 -or $EngineGroundHorizonOnlyRuntimeFlag -ne 0) { 0 } else { $WorldGroundHorizonBBoxOccludeFlag }
$RuntimeWorldGroundRollSpanEdgeFlag = if ($EngineGroundSimpleRuntimeFlag -ne 0 -or $EngineGroundHorizonOnlyRuntimeFlag -ne 0) { 0 } else { $WorldGroundRollSpanEdgeFlag }
$GroundHorizonDarkGreyRuntimeFlag = if ($EngineGroundHorizonOnlyRuntimeFlag -ne 0 -or $Mode2GroundPlaneLineRuntimeFlag -ne 0) { 1 } else { 0 }
$EngineWireHorizonDirectDrawFlag = if ($EngineWireSpeedPass1Flag -ne 0 -and
 ($EngineGroundHorizonOnlyRuntimeFlag -ne 0 -or $Mode2GroundPlaneLineRuntimeFlag -ne 0)) { 1 } else { 0 }
$EngineMode2HorizonRowMaskRuntimeFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0 -and $EngineGroundHorizonOnlyRuntimeFlag -ne 0 -and $RuntimeWorldGroundWireOccludeFlag -ne 0 -and $EngineCameraRollRuntimeFlag -eq 0) { 1 } else { 0 }
$WorldGroundWireMaskHelpersFlag = if ($RuntimeWorldGroundWireOccludeFlag -ne 0) { 1 } else { 0 }
$WorldGroundWireMaskDataFlag = if ($RuntimeWorldGroundWireOccludeFlag -ne 0 -or $RuntimeWorldGroundHorizonOnlyFlag -ne 0) { 1 } else { 0 }
$WorldGroundWireRollRuntimeFlag = if ($WorldGroundEnableFlag -ne 0 -and
 ($EngineGroundHorizonOnlyRuntimeFlag -ne 0 -or $Mode2GroundPlaneLineRuntimeFlag -ne 0) -and
 $CameraRollActiveFlag -ne 0) { 1 } else { 0 }
if ($RuntimeWorldGroundWireOccludeFlag -ne 0 -and
 ($WorldGroundEnableFlag -eq 0 -or
  $EngineGroundHorizonOnlyRuntimeFlag -eq 0 -or
  $EngineMode2HiddenWireRuntimeFlag -eq 0 -or
  $WorldGroundWireMaskHelpersFlag -eq 0 -or
  $WorldGroundWireMaskDataFlag -eq 0)) {
 throw "WORLD_GROUND_WIRE_OCCLUDE requires Mode 2 horizon-only Ground, hidden-wire, mask helpers, and mask data"
}
$WorldGroundRenderCallAsm = ""
$WorldGroundRendererAsm = ""
$WorldGroundRollRendererAsm = ""
$WorldGroundWireRollRendererAsm = ""
$WorldGroundOcclusionAsm = ""
$WorldGroundWireMaskAsm = ""
$WorldGroundWireMaskFinalizeCallAsm = ""
if ($WorldGroundEnableFlag -ne 0) {
 $WorldGroundRenderCallAsm = " jsr render_world_ground"
 $WorldGroundRendererAsm = @'
render_world_ground:
.if CAMERA_MOVABLE != 0 || WORLD_GROUND_ENABLE != 0
.if WORLD_GROUND_WIRE_OCCLUDE != 0
 lda #$00
 sta world_ground_horizon_valid
 sta world_ground_horizon_mask_active
.endif
.if CAMERA_ROLL_ACTIVE != 0
 jsr explorer_prepare_view
.if WORLD_GROUND_HORIZON_ONLY != 0
 lda explorer_cam_roll
 bne rwg_general_plane
.else
 jsr world_ground_needs_general_plane
 bne rwg_general_plane
.endif
.endif
 ldx explorer_cam_pitch
 lda world_ground_horizon_start,x
.if CAMERA_ROLL_ACTIVE != 0
 sec
 sbc #$20
 bcs rwg_horizon_unbias_nonneg
 ; Preserve an above-viewport result as an invalid row instead of snapping it
 ; to the top edge.  world_ground_draw_horizon_row rejects this sentinel.
.if GRAPHICS_MODE < 3
 lda #$ff
.else
 lda #$00
.endif
 jmp rwg_horizon_unbias_done
rwg_horizon_unbias_nonneg:
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcc rwg_horizon_unbias_done
 lda #(PROJ_SCREEN_MAX_Y + 1)
rwg_horizon_unbias_done:
.endif
 sta p1lo
.if WORLD_GROUND_HORIZON_ONLY != 0
 jsr world_ground_draw_horizon_row
 rts
.endif
.if WORLD_GROUND_PLANE_CLIP = 0 || GRAPHICS_MODE != 2
 sec
 lda explorer_cam_y_lo
 sbc #WORLD_GROUND_Y_LO
 lda explorer_cam_y_hi
 sbc #WORLD_GROUND_Y_HI
 lda explorer_cam_y_ext
 sbc #WORLD_GROUND_Y_EXT
 bmi rwg_fill_above
rwg_fill_below:
 lda p1lo
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcc rwg_below_visible
 rts
rwg_below_visible:
 sta yrow
rwg_below_loop:
 jsr world_ground_fill_current_row
 inc yrow
 lda yrow
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bne rwg_below_loop
 rts
rwg_fill_above:
 lda p1lo
 bne rwg_above_visible
 rts
rwg_above_visible:
 sec
 sbc #$01
 sta maxrow
 lda #$00
 sta yrow
rwg_above_loop:
 jsr world_ground_fill_current_row
 lda yrow
 cmp maxrow
 beq rwg_above_done
 inc yrow
 jmp rwg_above_loop
rwg_above_done:
 rts
.endif
.if CAMERA_ROLL_ACTIVE != 0
rwg_general_plane:
.if WORLD_GROUND_HORIZON_ONLY != 0
 jmp render_world_ground_wire_roll
.else
 jmp render_world_ground_roll
.endif
.endif
.else
 rts
.endif

.if WORLD_GROUND_PLANE_CLIP = 0 || GRAPHICS_MODE != 2
world_ground_fill_current_row:
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq wgfr_draw
 ldx yrow
 jsr lowres_row_selected
 bne wgfr_done
.endif
wgfr_draw:
 lda drawbuf
 bne wgfr_b
wgfr_a:
 jsr world_ground_apply_cells_a
 ldx yrow
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 jmp world_ground_fill_bitmap_row
wgfr_b:
 jsr world_ground_apply_cells_b
 ldx yrow
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
 jmp world_ground_fill_bitmap_row
wgfr_done:
 rts
.endif

.if WORLD_GROUND_HORIZON_ONLY != 0
world_ground_draw_horizon_row:
 lda p1lo
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs wgdhr_done
.if WORLD_GROUND_WIRE_OCCLUDE != 0
 sta world_ground_hy0
 sta world_ground_hy1
 lda #$01
 sta world_ground_horizon_mask_active
 sec
 lda explorer_cam_y_lo
 sbc #WORLD_GROUND_Y_LO
 lda explorer_cam_y_hi
 sbc #WORLD_GROUND_Y_HI
 lda explorer_cam_y_ext
 sbc #WORLD_GROUND_Y_EXT
 bpl wgdhr_mask_side_ready
 lda #$81
 sta world_ground_horizon_mask_active
wgdhr_mask_side_ready:
 lda p1lo
.endif
 jsr world_ground_save_horizon_material
 jsr world_ground_setup_horizon_material
 lda #PROJ_SCREEN_MIN_X
 sta ex0
 lda #PROJ_SCREEN_MAX_X
 sta ex1
 lda p1lo
 sta ey0
 sta ey1
 jsr world_ground_save_horizon_endpoints
.if ENGINE_WIRE_HORIZON_DIRECT_DRAW != 0
 jsr plot_wire_horizontal
.else
 jsr draw_wire_edge
.endif
 jsr world_ground_restore_horizon_material
 rts
wgdhr_done:
 rts

world_ground_save_horizon_material:
 lda material_screen_cur
 sta world_ground_saved_material_screen
 lda material_color_cur
 sta world_ground_saved_material_color
 rts

world_ground_restore_horizon_material:
 lda world_ground_saved_material_screen
 sta material_screen_cur
 lda world_ground_saved_material_color
 sta material_color_cur
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 rts

world_ground_save_horizon_endpoints:
 lda ex0
 sta world_ground_hx0
 lda ey0
 sta world_ground_hy0
 lda ex1
 sta world_ground_hx1
 lda ey1
 sta world_ground_hy1
 lda #$01
 sta world_ground_horizon_valid
 rts

world_ground_setup_horizon_material:
 lda #$aa
 sta fillbyte
.if GROUND_HORIZON_DARK_GREY_ENABLE != 0
 lda #ENGINE_GROUND_HORIZON_SCREEN_BYTE
 sta material_screen_cur
 lda #ENGINE_GROUND_HORIZON_COLOR_RAM
 sta material_color_cur
.else
 lda #WORLD_GROUND_SCREEN_BYTE
 sta material_screen_cur
 lda #WORLD_GROUND_COLOR_RAM
 sta material_color_cur
.endif
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 rts
.endif

.if WORLD_GROUND_PLANE_CLIP = 0 || GRAPHICS_MODE != 2
world_ground_apply_cells_a:
 ldx yrow
 lda screenrowlo_a,x
 sta ptr0lo
 lda screenrowhi_a,x
 sta ptr0hi
 jmp world_ground_apply_cells_common

world_ground_apply_cells_b:
 ldx yrow
 lda screenrowlo_b,x
 sta ptr0lo
 lda screenrowhi_b,x
 sta ptr0hi

world_ground_apply_cells_common:
 ldx yrow
 lda colorrowlo,x
 sta ptr1lo
 lda colorrowhi,x
 sta ptr1hi
 .if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_CELL_ORIGIN_X
 sta ptr0lo
 bcc wgac_screen_origin_ok
 inc ptr0hi
wgac_screen_origin_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_CELL_ORIGIN_X
 sta ptr1lo
 bcc wgac_color_origin_ok
 inc ptr1hi
wgac_color_origin_ok:
.endif
 ldx #CAMERA_VIEWPORT_CELL_WIDTH
 ldy #$00
wgac_loop:
 lda #WORLD_GROUND_SCREEN_BYTE
 sta (ptr0lo),y
 lda #WORLD_GROUND_COLOR_RAM
 sta (ptr1lo),y
 inc ptr0lo
 bne wgac_screen_ok
 inc ptr0hi
wgac_screen_ok:
 inc ptr1lo
 bne wgac_color_ok
 inc ptr1hi
wgac_color_ok:
 dex
 bne wgac_loop
 rts

world_ground_fill_bitmap_row:
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr0lo
 bcc wgfb_origin0_ok
 inc ptr0hi
wgfb_origin0_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr1lo
 bcc wgfb_origin1_ok
 inc ptr1hi
wgfb_origin1_ok:
.endif
 ldx #CAMERA_VIEWPORT_CELL_WIDTH
 ldy #$00
wgfb_loop:
 lda #$ff
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgfb_ptr0_ok
 inc ptr0hi
wgfb_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgfb_ptr1_ok
 inc ptr1hi
wgfb_ptr1_ok:
 dex
 bne wgfb_loop
 rts
.endif

.if CAMERA_ROLL_ACTIVE != 0 && WORLD_GROUND_HORIZON_ONLY = 0
world_ground_needs_general_plane:
 lda explorer_cam_roll
 bne wgngp_yes
 lda explorer_cam_pitch
 bmi wgngp_neg
 cmp #EXPLORER_PITCH_POS_LIMIT
 bcs wgngp_yes
 lda #$00
 rts
wgngp_neg:
 cmp #EXPLORER_PITCH_NEG_MIN
 bcc wgngp_yes
 lda #$00
 rts
wgngp_yes:
 lda #$01
 rts
.endif
'@
 if ($WorldGroundWireRollRuntimeFlag -ne 0) {
 $WorldGroundWireRollRendererAsm = @'

.if WORLD_GROUND_ENABLE != 0 && WORLD_GROUND_HORIZON_ONLY != 0 && CAMERA_ROLL_ACTIVE != 0
; Compact screen-space Ground line shared by wire Modes 1 and 2.  The same
; signed cross-product coefficients are reused by the Mode 2 final mask.
render_world_ground_wire_roll:
 jsr world_ground_wire_prepare_roll_line
 jmp world_ground_wire_draw_horizon_line_roll

world_ground_wire_prepare_roll_line:
 lda #$00
 sta maxrow
 sec
 lda explorer_cam_y_lo
 sbc #WORLD_GROUND_Y_LO
 lda explorer_cam_y_hi
 sbc #WORLD_GROUND_Y_HI
 lda explorer_cam_y_ext
 sbc #WORLD_GROUND_Y_EXT
 bpl wgwpr_side_ready
 lda #$80
 sta maxrow
wgwpr_side_ready:
 ; Cross(x,y) = dx*(x-centerX+2) + dy*(y-centerY)
 ;              - focal*sin(pitch).
 lda cosxv
 ldx sinzv
 jsr mul_s6
 sta dx1v
 ldx #WIRE_GROUND_ROLL_X_BIAS
 jsr mul_s8_16
 lda prodlo
 sta rx0
 lda prodhi
 sta rx1
 lda dx1v
 ldx #$04
 jsr mul_s8_16
 lda prodlo
 sta ry0
 lda prodhi
 sta ry1
 lda cosxv
 ldx coszv
 jsr mul_s6
 sta dy1v
 ldx #WIRE_GROUND_ROLL_Y_BIAS
 jsr mul_s8_16
 lda prodlo
 sta rz0
 lda prodhi
 sta rz1
 lda sinxv
 ldx #WIRE_GROUND_ROLL_FOCAL_HALF
 jsr mul_s8_16
 asl prodlo
 rol prodhi
 sec
 lda rz0
 sbc prodlo
 sta rz0
 lda rz1
 sbc prodhi
 sta rz1
 lda maxrow
 sta t1
 rts

world_ground_wire_draw_horizon_line_roll:
.if WORLD_GROUND_WIRE_OCCLUDE != 0
 lda t1
 and #$80
 ora #$41
 sta world_ground_horizon_mask_active
.endif
 jsr world_ground_save_horizon_material
 jsr world_ground_setup_horizon_material
 lda #PROJ_SCREEN_MIN_X
 sta tmpidx
 jsr wgwrl_set_top_left
 lda #PROJ_SCREEN_MIN_X
 sta xcur
 lda #PROJ_SCREEN_MIN_Y
 sta ycur
 jsr wgwrl_scan_x_border
 jsr wgwrl_set_bottom_left
 lda #PROJ_SCREEN_MIN_X
 sta xcur
 lda #PROJ_SCREEN_MAX_Y
 sta ycur
 jsr wgwrl_scan_x_border
 jsr wgwrl_set_top_left
 lda #PROJ_SCREEN_MIN_X
 sta xcur
 lda #PROJ_SCREEN_MIN_Y
 sta ycur
 jsr wgwrl_scan_y_border
 jsr wgwrl_set_top_right
 lda #PROJ_SCREEN_MAX_X
 sta xcur
 lda #PROJ_SCREEN_MIN_Y
 sta ycur
 jsr wgwrl_scan_y_border
 lda tmpidx
 cmp #$02
 bcc wgwrl_restore_material
 jsr world_ground_save_horizon_endpoints
 jsr draw_wire_edge
wgwrl_restore_material:
 jmp world_ground_restore_horizon_material

wgwrl_set_top_left:
 clc
 lda rz0
 adc rx0
 sta crosslo
 lda rz1
 adc rx1
 sta crosshi
 rts

wgwrl_set_bottom_left:
 jsr wgwrl_set_top_left
 lda #PROJ_SCREEN_MAX_Y
 sta fullcount
 beq wgwrl_bottom_done
wgwrl_bottom_step:
 jsr wgwrl_add_cos_to_cross
 dec fullcount
 bne wgwrl_bottom_step
wgwrl_bottom_done:
 rts

wgwrl_set_top_right:
 jsr wgwrl_set_top_left
 lda #PROJ_SCREEN_MAX_X
 sta fullcount
 beq wgwrl_right_done
wgwrl_right_step:
 jsr wgwrl_add_sin_to_cross
 dec fullcount
 bne wgwrl_right_step
wgwrl_right_done:
 rts

wgwrl_scan_x_border:
wgwrl_scan_x_loop:
 jsr wgwrl_cross_is_zero
 beq wgwrl_scan_x_hit
 lda xcur
 cmp #PROJ_SCREEN_MAX_X
 beq wgwrl_scan_x_done
 lda crosshi
 and #$80
 sta t2
 jsr wgwrl_add_sin_to_cross
 lda crosshi
 and #$80
 eor t2
 bne wgwrl_scan_x_hit
 inc xcur
 jmp wgwrl_scan_x_loop
wgwrl_scan_x_hit:
 jmp wgwrl_add_endpoint
wgwrl_scan_x_done:
 rts

wgwrl_scan_y_border:
wgwrl_scan_y_loop:
 jsr wgwrl_cross_is_zero
 beq wgwrl_scan_y_hit
 lda ycur
 cmp #PROJ_SCREEN_MAX_Y
 beq wgwrl_scan_y_done
 lda crosshi
 and #$80
 sta t2
 jsr wgwrl_add_cos_to_cross
 lda crosshi
 and #$80
 eor t2
 bne wgwrl_scan_y_hit
 inc ycur
 jmp wgwrl_scan_y_loop
wgwrl_scan_y_hit:
 jmp wgwrl_add_endpoint
wgwrl_scan_y_done:
 rts

wgwrl_cross_is_zero:
 lda crosshi
 bne wgwrl_cross_not_zero
 lda crosslo
 rts
wgwrl_cross_not_zero:
 lda #$01
 rts

wgwrl_add_sin_to_cross:
 clc
 lda crosslo
 adc dx1v
 sta crosslo
 lda crosshi
 ldx dx1v
 bmi wgwrl_add_sin_neg
 adc #$00
 sta crosshi
 rts
wgwrl_add_sin_neg:
 adc #$ff
 sta crosshi
 rts

wgwrl_add_cos_to_cross:
 clc
 lda crosslo
 adc dy1v
 sta crosslo
 lda crosshi
 ldx dy1v
 bmi wgwrl_add_cos_neg
 adc #$00
 sta crosshi
 rts
wgwrl_add_cos_neg:
 adc #$ff
 sta crosshi
 rts

wgwrl_add_endpoint:
 lda tmpidx
 beq wgwrl_store_endpoint0
 cmp #$01
 bne wgwrl_endpoint_done
 lda xcur
 cmp ex0
 bne wgwrl_store_endpoint1
 lda ycur
 cmp ey0
 beq wgwrl_endpoint_done
wgwrl_store_endpoint1:
 lda xcur
 sta ex1
 lda ycur
 sta ey1
 inc tmpidx
 rts
wgwrl_store_endpoint0:
 lda xcur
 sta ex0
 lda ycur
 sta ey0
 inc tmpidx
wgwrl_endpoint_done:
 rts
.endif
'@
 }
 if ($CameraRollActiveFlag -ne 0 -and $EngineGroundHorizonOnlyRuntimeFlag -eq 0 -and $Mode2GroundPlaneLineRuntimeFlag -eq 0) {
 $WorldGroundRollRendererAsm = @'

.if WORLD_GROUND_ENABLE != 0 && CAMERA_ROLL_ACTIVE != 0
render_world_ground_roll:
 lda #$00
 sta maxrow
 sec
 lda explorer_cam_y_lo
 sbc #WORLD_GROUND_Y_LO
 lda explorer_cam_y_hi
 sbc #WORLD_GROUND_Y_HI
 lda explorer_cam_y_ext
 sbc #WORLD_GROUND_Y_EXT
 bpl rwgr_side_ready
 lda #$80
 sta maxrow
rwgr_side_ready:
 lda cosxv
 ldx sinzv
 jsr mul_s6
 sta dx1v
 ldx #$b2
 jsr mul_s8_16
 lda prodlo
 sta rx0
 lda prodhi
 sta rx1
 lda dx1v
 ldx #$04
 jsr mul_s8_16
 lda prodlo
 sta ry0
 lda prodhi
 sta ry1
 lda cosxv
 ldx coszv
 jsr mul_s6
 sta dy1v
 ldx #$ce
 jsr mul_s8_16
 lda prodlo
 sta rz0
 lda prodhi
 sta rz1
 lda sinxv
 ldx #$55
 jsr mul_s8_16
 asl prodlo
 rol prodhi
 sec
 lda rz0
 sbc prodlo
 sta rz0
 lda rz1
 sbc prodhi
 sta rz1
 lda maxrow
 sta t1
.if WORLD_GROUND_HORIZON_ONLY != 0
 jsr world_ground_draw_horizon_line_roll
 rts
.else
 lda #$00
 sta yrow
rwgr_row_loop:
 jsr world_ground_fill_current_row_roll
 lda dy1v
 bpl rwgr_add_cos_pos
 clc
 lda rz0
 adc dy1v
 sta rz0
 lda rz1
 adc #$ff
 sta rz1
 jmp rwgr_next_row
rwgr_add_cos_pos:
 clc
 lda rz0
 adc dy1v
 sta rz0
 lda rz1
 adc #$00
 sta rz1
rwgr_next_row:
 inc yrow
 lda yrow
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bne rwgr_row_loop
 rts
.endif

.if WORLD_GROUND_HORIZON_ONLY != 0
world_ground_draw_horizon_line_roll:
 jsr world_ground_setup_horizon_material
 lda #PROJ_SCREEN_MIN_X
 sta tmpidx
 jsr wgdh_set_top_left
 lda #PROJ_SCREEN_MIN_X
 sta xcur
 sta ycur
 jsr wgdh_scan_x_border
 jsr wgdh_set_bottom_left
 lda #PROJ_SCREEN_MIN_X
 sta xcur
 lda #PROJ_SCREEN_MAX_Y
 sta ycur
 jsr wgdh_scan_x_border
 jsr wgdh_set_top_left
 lda #PROJ_SCREEN_MIN_X
 sta xcur
 sta ycur
 jsr wgdh_scan_y_border
 jsr wgdh_set_top_right
 lda #PROJ_SCREEN_MAX_X
 sta xcur
 lda #PROJ_SCREEN_MIN_Y
 sta ycur
 jsr wgdh_scan_y_border
 lda tmpidx
 cmp #$02
 bcc wgdh_roll_done
 jsr world_ground_save_horizon_endpoints
 jmp draw_wire_edge
wgdh_roll_done:
 rts

wgdh_set_top_left:
 clc
 lda rz0
 adc rx0
 sta crosslo
 lda rz1
 adc rx1
 sta crosshi
 rts

wgdh_set_bottom_left:
 jsr wgdh_set_top_left
 lda #PROJ_SCREEN_MAX_Y
 sta fullcount
wgdh_bottom_step:
 jsr wgdh_add_cos_to_cross
 dec fullcount
 bne wgdh_bottom_step
 rts

wgdh_set_top_right:
 jsr wgdh_set_top_left
 lda #PROJ_SCREEN_MAX_X
 sta fullcount
wgdh_right_step:
 jsr wgdh_add_sin_to_cross
 dec fullcount
 bne wgdh_right_step
 rts

wgdh_scan_x_border:
wgdh_scan_x_loop:
 jsr wgdh_cross_is_zero
 beq wgdh_scan_x_hit
 lda xcur
 cmp #PROJ_SCREEN_MAX_X
 beq wgdh_scan_x_done
 lda crosshi
 and #$80
 sta t2
 jsr wgdh_add_sin_to_cross
 lda crosshi
 and #$80
 eor t2
 bne wgdh_scan_x_hit
 inc xcur
 jmp wgdh_scan_x_loop
wgdh_scan_x_hit:
 jmp wgdh_roll_add_endpoint
wgdh_scan_x_done:
 rts

wgdh_scan_y_border:
wgdh_scan_y_loop:
 jsr wgdh_cross_is_zero
 beq wgdh_scan_y_hit
 lda ycur
 cmp #PROJ_SCREEN_MAX_Y
 beq wgdh_scan_y_done
 lda crosshi
 and #$80
 sta t2
 jsr wgdh_add_cos_to_cross
 lda crosshi
 and #$80
 eor t2
 bne wgdh_scan_y_hit
 inc ycur
 jmp wgdh_scan_y_loop
wgdh_scan_y_hit:
 jmp wgdh_roll_add_endpoint
wgdh_scan_y_done:
 rts

wgdh_cross_is_zero:
 lda crosshi
 bne wgdh_cross_not_zero
 lda crosslo
 rts
wgdh_cross_not_zero:
 lda #$01
 rts

wgdh_add_sin_to_cross:
 clc
 lda crosslo
 adc dx1v
 sta crosslo
 lda crosshi
 ldx dx1v
 bmi wgdh_add_sin_neg
 adc #$00
 sta crosshi
 rts
wgdh_add_sin_neg:
 adc #$ff
 sta crosshi
 rts

wgdh_add_cos_to_cross:
 clc
 lda crosslo
 adc dy1v
 sta crosslo
 lda crosshi
 ldx dy1v
 bmi wgdh_add_cos_neg
 adc #$00
 sta crosshi
 rts
wgdh_add_cos_neg:
 adc #$ff
 sta crosshi
 rts

wgdh_roll_add_endpoint:
 lda tmpidx
 beq wgdh_store_endpoint0
 cmp #$01
 bne wgdh_endpoint_done
 lda xcur
 cmp ex0
 bne wgdh_store_endpoint1
 lda ycur
 cmp ey0
 beq wgdh_endpoint_done
wgdh_store_endpoint1:
 lda xcur
 sta ex1
 lda ycur
 sta ey1
 inc tmpidx
 rts
wgdh_store_endpoint0:
 lda xcur
 sta ex0
 lda ycur
 sta ey0
 inc tmpidx
wgdh_endpoint_done:
 rts
.endif

world_ground_fill_current_row_roll:
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq wgfr_roll_draw
 ldx yrow
 jsr lowres_row_selected
 bne wgfr_roll_done
.endif
wgfr_roll_draw:
 lda drawbuf
 bne wgfr_roll_b
wgfr_roll_a:
 ldx yrow
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 lda screenrowlo_a,x
 sta row0lo
 lda screenrowhi_a,x
 sta row0hi
 jmp wgfr_roll_cells
wgfr_roll_b:
 ldx yrow
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
 lda screenrowlo_b,x
 sta row0lo
 lda screenrowhi_b,x
 sta row0hi
wgfr_roll_cells:
 ldx yrow
 lda colorrowlo,x
 sta row1lo
 lda colorrowhi,x
 sta row1hi
 clc
 lda rz0
 adc rx0
 sta crosslo
 lda rz1
 adc rx1
 sta crosshi
 lda #$28
 sta fullcount
.if WORLD_GROUND_ROLL_SPAN_EDGE != 0
 lda t1
 bmi wgfr_roll_span_select_negative
 lda ry1
 bmi wgfr_roll_span_left_positive
 jmp wgfr_roll_span_right_positive
wgfr_roll_span_select_negative:
 lda ry1
 bmi wgfr_roll_span_right_negative
 jmp wgfr_roll_span_left_negative

wgfr_roll_span_right_positive:
 lda crosshi
 bpl wgfr_roll_span_fill_rest
wgfr_rp_seek:
 clc
 lda crosslo
 adc ry0
 sta p1lo
 lda crosshi
 adc ry1
 sta p1hi
 bpl wgfr_rp_edge
 lda p1lo
 sta crosslo
 lda p1hi
 sta crosshi
 inc row0lo
 bne wgfr_rp_screen_ok
 inc row0hi
wgfr_rp_screen_ok:
 inc row1lo
 bne wgfr_rp_color_ok
 inc row1hi
wgfr_rp_color_ok:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgfr_rp_ptr0_ok
 inc ptr0hi
wgfr_rp_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgfr_rp_ptr1_ok
 inc ptr1hi
wgfr_rp_ptr1_ok:
 dec fullcount
 bne wgfr_rp_seek
 jmp wgfr_roll_done
wgfr_rp_edge:
 jsr wgfr_roll_make_mask_positive
 jsr wgfr_roll_write_mask_current
 jsr wgfr_roll_advance_edge_current
 lda fullcount
 beq wgfr_roll_done
 jmp wgfr_roll_span_fill_rest

wgfr_roll_span_right_negative:
 lda crosshi
 bmi wgfr_roll_span_fill_rest
wgfr_rn_seek:
 clc
 lda crosslo
 adc ry0
 sta p1lo
 lda crosshi
 adc ry1
 sta p1hi
 bmi wgfr_rn_edge
 lda p1lo
 sta crosslo
 lda p1hi
 sta crosshi
 inc row0lo
 bne wgfr_rn_screen_ok
 inc row0hi
wgfr_rn_screen_ok:
 inc row1lo
 bne wgfr_rn_color_ok
 inc row1hi
wgfr_rn_color_ok:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgfr_rn_ptr0_ok
 inc ptr0hi
wgfr_rn_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgfr_rn_ptr1_ok
 inc ptr1hi
wgfr_rn_ptr1_ok:
 dec fullcount
 bne wgfr_rn_seek
 jmp wgfr_roll_done
wgfr_rn_edge:
 jsr wgfr_roll_make_mask_negative
 jsr wgfr_roll_write_mask_current
 jsr wgfr_roll_advance_edge_current
 lda fullcount
 beq wgfr_roll_done
 jmp wgfr_roll_span_fill_rest

wgfr_roll_span_left_positive:
 lda crosshi
 bmi wgfr_roll_done
wgfr_lp_loop:
 clc
 lda crosslo
 adc ry0
 sta p1lo
 lda crosshi
 adc ry1
 sta p1hi
 bmi wgfr_lp_edge
 ldy #$00
 lda #WORLD_GROUND_SCREEN_BYTE
 sta (row0lo),y
 lda #WORLD_GROUND_COLOR_RAM
 sta (row1lo),y
 lda #$ff
 sta (ptr0lo),y
 sta (ptr1lo),y
 lda p1lo
 sta crosslo
 lda p1hi
 sta crosshi
 inc row0lo
 bne wgfr_lp_screen_ok
 inc row0hi
wgfr_lp_screen_ok:
 inc row1lo
 bne wgfr_lp_color_ok
 inc row1hi
wgfr_lp_color_ok:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgfr_lp_ptr0_ok
 inc ptr0hi
wgfr_lp_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgfr_lp_ptr1_ok
 inc ptr1hi
wgfr_lp_ptr1_ok:
 dec fullcount
 bne wgfr_lp_loop
 jmp wgfr_roll_done
wgfr_lp_edge:
 jsr wgfr_roll_make_mask_positive
 jsr wgfr_roll_write_mask_current
 jmp wgfr_roll_done

wgfr_roll_span_left_negative:
 lda crosshi
 bpl wgfr_roll_done
wgfr_ln_loop:
 clc
 lda crosslo
 adc ry0
 sta p1lo
 lda crosshi
 adc ry1
 sta p1hi
 bpl wgfr_ln_edge
 ldy #$00
 lda #WORLD_GROUND_SCREEN_BYTE
 sta (row0lo),y
 lda #WORLD_GROUND_COLOR_RAM
 sta (row1lo),y
 lda #$ff
 sta (ptr0lo),y
 sta (ptr1lo),y
 lda p1lo
 sta crosslo
 lda p1hi
 sta crosshi
 inc row0lo
 bne wgfr_ln_screen_ok
 inc row0hi
wgfr_ln_screen_ok:
 inc row1lo
 bne wgfr_ln_color_ok
 inc row1hi
wgfr_ln_color_ok:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgfr_ln_ptr0_ok
 inc ptr0hi
wgfr_ln_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgfr_ln_ptr1_ok
 inc ptr1hi
wgfr_ln_ptr1_ok:
 dec fullcount
 bne wgfr_ln_loop
 jmp wgfr_roll_done
wgfr_ln_edge:
 jsr wgfr_roll_make_mask_negative
 jsr wgfr_roll_write_mask_current
 jmp wgfr_roll_done

wgfr_roll_span_fill_rest:
 ldy #$00
 lda #WORLD_GROUND_SCREEN_BYTE
 sta (row0lo),y
 lda #WORLD_GROUND_COLOR_RAM
 sta (row1lo),y
 lda #$ff
 sta (ptr0lo),y
 sta (ptr1lo),y
 inc row0lo
 bne wgfr_sf_screen_ok
 inc row0hi
wgfr_sf_screen_ok:
 inc row1lo
 bne wgfr_sf_color_ok
 inc row1hi
wgfr_sf_color_ok:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgfr_sf_ptr0_ok
 inc ptr0hi
wgfr_sf_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgfr_sf_ptr1_ok
 inc ptr1hi
wgfr_sf_ptr1_ok:
 dec fullcount
 bne wgfr_roll_span_fill_rest
 jmp wgfr_roll_done

wgfr_roll_advance_edge_current:
 inc row0lo
 bne wgfr_edge_screen_ok
 inc row0hi
wgfr_edge_screen_ok:
 inc row1lo
 bne wgfr_edge_color_ok
 inc row1hi
wgfr_edge_color_ok:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgfr_edge_ptr0_ok
 inc ptr0hi
wgfr_edge_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgfr_edge_ptr1_ok
 inc ptr1hi
wgfr_edge_ptr1_ok:
 dec fullcount
 rts

wgfr_roll_write_mask_current:
 lda maskv
 beq wgfr_roll_write_mask_done
 ldy #$00
 lda #WORLD_GROUND_SCREEN_BYTE
 sta (row0lo),y
 lda #WORLD_GROUND_COLOR_RAM
 sta (row1lo),y
 lda maskv
 sta (ptr0lo),y
 sta (ptr1lo),y
wgfr_roll_write_mask_done:
 rts

wgfr_roll_make_mask_positive:
 lda #$00
 sta maskv
 lda crosslo
 sta p1lo
 lda crosshi
 sta p1hi
 bmi wgfr_mpos_0_skip
 lda maskv
 ora #$c0
 sta maskv
wgfr_mpos_0_skip:
 jsr wgfr_roll_mask_add_substep
 lda p1hi
 bmi wgfr_mpos_1_skip
 lda maskv
 ora #$30
 sta maskv
wgfr_mpos_1_skip:
 jsr wgfr_roll_mask_add_substep
 lda p1hi
 bmi wgfr_mpos_2_skip
 lda maskv
 ora #$0c
 sta maskv
wgfr_mpos_2_skip:
 jsr wgfr_roll_mask_add_substep
 lda p1hi
 bmi wgfr_mpos_done
 lda maskv
 ora #$03
 sta maskv
wgfr_mpos_done:
 rts

wgfr_roll_make_mask_negative:
 lda #$00
 sta maskv
 lda crosslo
 sta p1lo
 lda crosshi
 sta p1hi
 bpl wgfr_mneg_0_skip
 lda maskv
 ora #$c0
 sta maskv
wgfr_mneg_0_skip:
 jsr wgfr_roll_mask_add_substep
 lda p1hi
 bpl wgfr_mneg_1_skip
 lda maskv
 ora #$30
 sta maskv
wgfr_mneg_1_skip:
 jsr wgfr_roll_mask_add_substep
 lda p1hi
 bpl wgfr_mneg_2_skip
 lda maskv
 ora #$0c
 sta maskv
wgfr_mneg_2_skip:
 jsr wgfr_roll_mask_add_substep
 lda p1hi
 bpl wgfr_mneg_done
 lda maskv
 ora #$03
 sta maskv
wgfr_mneg_done:
 rts

wgfr_roll_mask_add_substep:
 clc
 lda p1lo
 adc dx1v
 sta p1lo
 lda p1hi
 ldx dx1v
 bmi wgfr_roll_mask_add_neg
 adc #$00
 sta p1hi
 rts
wgfr_roll_mask_add_neg:
 adc #$ff
 sta p1hi
 rts
.else
wgfr_roll_loop:
 lda t1
 bmi wgfr_roll_fill_negative
 lda crosshi
 bmi wgfr_roll_skip_fill
 jmp wgfr_roll_fill
wgfr_roll_fill_negative:
 lda crosshi
 bpl wgfr_roll_skip_fill
wgfr_roll_fill:
 ldy #$00
 lda #WORLD_GROUND_SCREEN_BYTE
 sta (row0lo),y
 lda #WORLD_GROUND_COLOR_RAM
 sta (row1lo),y
 lda #$ff
 sta (ptr0lo),y
 sta (ptr1lo),y
wgfr_roll_skip_fill:
 clc
 lda crosslo
 adc ry0
 sta crosslo
 lda crosshi
 adc ry1
 sta crosshi
 inc row0lo
 bne wgfr_roll_screen_ok
 inc row0hi
wgfr_roll_screen_ok:
 inc row1lo
 bne wgfr_roll_color_ok
 inc row1hi
wgfr_roll_color_ok:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgfr_roll_ptr0_ok
 inc ptr0hi
wgfr_roll_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgfr_roll_ptr1_ok
 inc ptr1hi
wgfr_roll_ptr1_ok:
 dec fullcount
 bne wgfr_roll_loop
.endif
wgfr_roll_done:
 rts
.endif
'@
 }
}
if ($WorldGroundWireMaskHelpersFlag -ne 0) {
 $WorldGroundWireMaskFinalizeCallAsm = " jsr render_world_ground_wire_mask_finalize"
 $WorldGroundWireMaskAsm = @'
.if WORLD_GROUND_WIRE_OCCLUDE != 0
; Horizon-only Mode 2 uses the projected horizon as a compact screen-space
; mask.  Points on the Ground-covered side return directly to the edge
; rasterizer; visible-side points resume the normal plot path.
world_ground_mask_plot_point:
 ldx rightval
 jsr world_ground_mask_row_visible
 bcs wgmp_visible
 rts
wgmp_visible:
 jmp pwp_normal

; Input X is a projected row. Carry set means visible side or inactive mask.
world_ground_mask_row_visible:
 lda world_ground_horizon_mask_active
 beq wgmr_visible
.if CAMERA_ROLL_ACTIVE != 0
 and #$40
 bne wgmr_visible
 lda world_ground_horizon_mask_active
.endif
 bmi wgmr_camera_below
 cpx world_ground_hy0
 bcc wgmr_visible
 beq wgmr_visible
 clc
 rts
wgmr_camera_below:
 cpx world_ground_hy0
 bcs wgmr_visible
 clc
 rts
wgmr_visible:
 sec
 rts

; The optimized horizontal/vertical run writers deliberately bypass the
; point consumer.  Finalize the same mask over the completed hidden-wire
; bitmap, then restore the horizon row.
render_world_ground_wire_mask_finalize:
 lda world_ground_horizon_mask_active
 beq wgmf_done
.if CAMERA_ROLL_ACTIVE != 0
 and #$40
 bne wgmf_roll
 lda world_ground_horizon_mask_active
.endif
 bmi wgmf_camera_below
wgmf_camera_above:
 lda world_ground_hy0
 cmp #PROJ_SCREEN_MAX_Y
 bcs wgmf_redraw_horizon
 clc
 adc #$01
 sta yrow
wgmf_below_loop:
 lda #PROJ_SCREEN_MIN_X
 sta leftval
 lda #PROJ_SCREEN_MAX_X
 sta rightval
 jsr world_ground_clear_mask_row_span
 lda yrow
 cmp #PROJ_SCREEN_MAX_Y
 beq wgmf_redraw_horizon
 inc yrow
 jmp wgmf_below_loop
wgmf_camera_below:
 lda world_ground_hy0
 beq wgmf_redraw_horizon
 sec
 sbc #$01
 sta maxrow
 lda #PROJ_SCREEN_MIN_Y
 sta yrow
wgmf_above_loop:
 lda #PROJ_SCREEN_MIN_X
 sta leftval
 lda #PROJ_SCREEN_MAX_X
 sta rightval
 jsr world_ground_clear_mask_row_span
 lda yrow
 cmp maxrow
 beq wgmf_redraw_horizon
 inc yrow
 jmp wgmf_above_loop
wgmf_redraw_horizon:
 lda world_ground_hy0
 sta p1lo
 jsr world_ground_draw_horizon_row
wgmf_done:
 rts

.if CAMERA_ROLL_ACTIVE != 0
wgmf_roll:
 jsr world_ground_wire_prepare_roll_line
 jsr world_ground_wire_clear_roll_semiplane
 jmp world_ground_wire_draw_horizon_line_roll

; Incremental row/span finalizer for the tilted horizon.  It evaluates one
; four-pixel bitmap cell at a time only while seeking the single boundary;
; fully covered runs are cleared by world_ground_clear_mask_row_span.
world_ground_wire_clear_roll_semiplane:
 lda #PROJ_SCREEN_MIN_Y
 sta yrow
wgwc_rows:
 jsr world_ground_wire_clear_roll_row
 clc
 lda rz0
 adc dy1v
 sta rz0
 lda rz1
 ldx dy1v
 bmi wgwc_add_row_neg
 adc #$00
 sta rz1
 jmp wgwc_next_row
wgwc_add_row_neg:
 adc #$ff
 sta rz1
wgwc_next_row:
 lda yrow
 cmp #PROJ_SCREEN_MAX_Y
 beq wgwc_done
 inc yrow
 jmp wgwc_rows
wgwc_done:
 rts

world_ground_wire_clear_roll_row:
 lda drawbuf
 bne wgwcr_b
wgwcr_a:
 ldx yrow
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 jmp wgwcr_ptrs_ready
wgwcr_b:
 ldx yrow
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
wgwcr_ptrs_ready:
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr0lo
 bcc wgwcr_origin0_ok
 inc ptr0hi
wgwcr_origin0_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr1lo
 bcc wgwcr_origin1_ok
 inc ptr1hi
wgwcr_origin1_ok:
.endif
 clc
 lda rz0
 adc rx0
 sta crosslo
 lda rz1
 adc rx1
 sta crosshi
 lda #PROJ_SCREEN_MIN_X
 sta xcur
 lda #CAMERA_VIEWPORT_CELL_WIDTH
 sta fullcount
 lda t1
 bmi wgwcr_camera_below
wgwcr_camera_above:
 lda ry1
 bmi wgwcr_above_slope_negative
 lda crosshi
 bmi wgwcr_scan_fill_right
 jmp wgwcr_clear_full_row
wgwcr_above_slope_negative:
 lda crosshi
 bmi wgwcr_done
 jmp wgwcr_scan_fill_left
wgwcr_camera_below:
 lda ry1
 bmi wgwcr_below_slope_negative
 lda crosshi
 bmi wgwcr_scan_fill_left
 jmp wgwcr_done
wgwcr_below_slope_negative:
 lda crosshi
 bmi wgwcr_clear_full_row
 jmp wgwcr_scan_fill_right

wgwcr_scan_fill_right:
 jsr wgwcr_cross_next_cell
 lda t1
 bmi wgwcr_right_negative
 lda p1hi
 bpl wgwcr_right_make_mask
 jmp wgwcr_right_advance
wgwcr_right_negative:
 lda p1hi
 bmi wgwcr_right_make_mask
wgwcr_right_advance:
 jsr wgwcr_advance_cell
 lda fullcount
 bne wgwcr_scan_fill_right
 rts
wgwcr_right_make_mask:
 jsr wgwcr_make_current_mask
 lda maskv
 bne wgwcr_right_boundary
 jmp wgwcr_right_advance
wgwcr_right_boundary:
 jsr wgwcr_clear_partial_current
 jsr wgwcr_advance_cell
 lda fullcount
 beq wgwcr_done
 lda xcur
 sta leftval
 lda #PROJ_SCREEN_MAX_X
 sta rightval
 jmp world_ground_clear_mask_row_span

wgwcr_scan_fill_left:
 jsr wgwcr_cross_next_cell
 lda t1
 bmi wgwcr_left_negative
 lda p1hi
 bmi wgwcr_left_make_mask
 jmp wgwcr_left_advance
wgwcr_left_negative:
 lda p1hi
 bpl wgwcr_left_make_mask
wgwcr_left_advance:
 jsr wgwcr_advance_cell
 lda fullcount
 bne wgwcr_scan_fill_left
 jmp wgwcr_clear_full_row
wgwcr_left_make_mask:
 jsr wgwcr_make_current_mask
 lda maskv
 cmp #$ff
 bne wgwcr_left_boundary
 jmp wgwcr_left_advance
wgwcr_left_boundary:
 jsr wgwcr_clear_partial_current
 lda xcur
 cmp #PROJ_SCREEN_MIN_X
 beq wgwcr_done
 lda #PROJ_SCREEN_MIN_X
 sta leftval
 sec
 lda xcur
 sbc #$01
 sta rightval
 jmp world_ground_clear_mask_row_span

wgwcr_clear_full_row:
 lda #PROJ_SCREEN_MIN_X
 sta leftval
 lda #PROJ_SCREEN_MAX_X
 sta rightval
 jmp world_ground_clear_mask_row_span
wgwcr_done:
 rts

wgwcr_make_current_mask:
 lda t1
 bmi wgwcr_make_negative
wgwcr_make_positive:
 lda #$00
 sta maskv
 lda crosslo
 sta p1lo
 lda crosshi
 sta p1hi
 bmi wgwcr_mpos_0_skip
 lda maskv
 ora #$c0
 sta maskv
wgwcr_mpos_0_skip:
 jsr wgwcr_mask_add_substep
 lda p1hi
 bmi wgwcr_mpos_1_skip
 lda maskv
 ora #$30
 sta maskv
wgwcr_mpos_1_skip:
 jsr wgwcr_mask_add_substep
 lda p1hi
 bmi wgwcr_mpos_2_skip
 lda maskv
 ora #$0c
 sta maskv
wgwcr_mpos_2_skip:
 jsr wgwcr_mask_add_substep
 lda p1hi
 bmi wgwcr_mask_done
 lda maskv
 ora #$03
 sta maskv
wgwcr_mask_done:
 rts

wgwcr_make_negative:
 lda #$00
 sta maskv
 lda crosslo
 sta p1lo
 lda crosshi
 sta p1hi
 bpl wgwcr_mneg_0_skip
 lda maskv
 ora #$c0
 sta maskv
wgwcr_mneg_0_skip:
 jsr wgwcr_mask_add_substep
 lda p1hi
 bpl wgwcr_mneg_1_skip
 lda maskv
 ora #$30
 sta maskv
wgwcr_mneg_1_skip:
 jsr wgwcr_mask_add_substep
 lda p1hi
 bpl wgwcr_mneg_2_skip
 lda maskv
 ora #$0c
 sta maskv
wgwcr_mneg_2_skip:
 jsr wgwcr_mask_add_substep
 lda p1hi
 bpl wgwcr_mask_done
 lda maskv
 ora #$03
 sta maskv
 rts

wgwcr_mask_add_substep:
 clc
 lda p1lo
 adc dx1v
 sta p1lo
 lda p1hi
 ldx dx1v
 bmi wgwcr_mask_add_neg
 adc #$00
 sta p1hi
 rts
wgwcr_mask_add_neg:
 adc #$ff
 sta p1hi
 rts

wgwcr_cross_next_cell:
 clc
 lda crosslo
 adc ry0
 sta p1lo
 lda crosshi
 adc ry1
 sta p1hi
 rts

wgwcr_clear_partial_current:
 lda maskv
 beq wgwcr_partial_done
 eor #$ff
 sta t2
 ldy #$00
 lda (ptr0lo),y
 and t2
 sta (ptr0lo),y
 lda (ptr1lo),y
 and t2
 sta (ptr1lo),y
wgwcr_partial_done:
 rts

wgwcr_advance_cell:
 clc
 lda crosslo
 adc ry0
 sta crosslo
 lda crosshi
 adc ry1
 sta crosshi
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgwcr_ptr0_ok
 inc ptr0hi
wgwcr_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgwcr_ptr1_ok
 inc ptr1hi
wgwcr_ptr1_ok:
 clc
 lda xcur
 adc #$04
 sta xcur
 dec fullcount
 rts
.endif

; The hidden-wire prepass removes the horizon only where a visible face
; crosses it, so the face edge can be drawn on the final horizon row.
world_ground_clear_mask_row_span:
 lda drawbuf
 bne wgcm_b
 ldx yrow
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jmp wgcm_rows_ready
wgcm_b:
 ldx yrow
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
wgcm_rows_ready:
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 sec
 lda endbyte
 sbc startbyte
 clc
 adc #$01
 sta fullcount
 ldy #$00
wgcm_loop:
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgcm_ptr0_ok
 inc ptr0hi
wgcm_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgcm_ptr1_ok
 inc ptr1hi
wgcm_ptr1_ok:
 dec fullcount
 bne wgcm_loop
 rts
.endif
'@
}
if ($WorldGroundOccludeFlag -ne 0) {
 $WorldGroundOcclusionAsm = @'
.if WORLD_GROUND_OCCLUDE != 0
ground_store_vertex_side:
 ldy tmpidx
 ldx vert_xi,y
 lda xcoord,x
 ldx m10
 jsr mul_s6
 sta t1
 ldy tmpidx
 ldx vert_yi,y
 lda ycoord,x
 ldx m11
 jsr mul_s6
 clc
 adc t1
 sta t1
 ldy tmpidx
 ldx vert_zi,y
 lda zcoord,x
 ldx m12
 jsr mul_s6
 clc
 adc t1
 clc
 adc obj_pos_y_cur
 sec
 sbc #WORLD_GROUND_Y_HI
gsvs_store:
 ldy tmpidx
 sta ground_vside,y
 rts

ground_object_visible:
.if WORLD_GROUND_PLANE_CLIP != 0
 lda #$01
 rts
.endif
 sec
 lda explorer_cam_y_lo
 sbc #WORLD_GROUND_Y_LO
 lda explorer_cam_y_hi
 sbc #WORLD_GROUND_Y_HI
 lda explorer_cam_y_ext
 sbc #WORLD_GROUND_Y_EXT
 bmi gov_camera_below
 sec
 lda obj_pos_y_cur
 sbc #WORLD_GROUND_Y_HI
 bmi gov_no
 lda #$01
 rts
gov_camera_below:
 sec
 lda obj_pos_y_cur
 sbc #WORLD_GROUND_Y_HI
 bmi gov_yes
gov_no:
 lda #$00
 rts
gov_yes:
 lda #$01
 rts

ground_face_visible:
 sec
 lda explorer_cam_y_lo
 sbc #WORLD_GROUND_Y_LO
 lda explorer_cam_y_hi
 sbc #WORLD_GROUND_Y_HI
 lda explorer_cam_y_ext
 sbc #WORLD_GROUND_Y_EXT
 bmi gfv_camera_below
 ldy faceidx
 ldx face0,y
 lda ground_vside,x
 bpl gfv_yes
 ldx face1,y
 lda ground_vside,x
 bpl gfv_yes
 ldx face2,y
 lda ground_vside,x
 bpl gfv_yes
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 cmp #$04
 bne gfv_no
.endif
 ldx face3,y
 lda ground_vside,x
 bpl gfv_yes
gfv_no:
 lda #$00
 rts
gfv_camera_below:
 ldy faceidx
 ldx face0,y
 lda ground_vside,x
 bmi gfv_yes
 beq gfv_yes
 ldx face1,y
 lda ground_vside,x
 bmi gfv_yes
 beq gfv_yes
 ldx face2,y
 lda ground_vside,x
 bmi gfv_yes
 beq gfv_yes
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 cmp #$04
 bne gfv_no
.endif
 ldx face3,y
 lda ground_vside,x
 bmi gfv_yes
 beq gfv_yes
 lda #$00
 rts
gfv_yes:
 lda #$01
 rts

ground_wire_edge_visible:
 sec
 lda explorer_cam_y_lo
 sbc #WORLD_GROUND_Y_LO
 lda explorer_cam_y_hi
 sbc #WORLD_GROUND_Y_HI
 lda explorer_cam_y_ext
 sbc #WORLD_GROUND_Y_EXT
 bmi gwev_camera_below
 ldx clip_prev_idx
 lda ground_vside,x
 bne gwev_yes
 ldx clip_cur_idx
 lda ground_vside,x
 bne gwev_yes
 lda #$00
 rts
gwev_camera_below:
 ldx clip_prev_idx
 lda ground_vside,x
 beq gwev_yes
 ldx clip_cur_idx
 lda ground_vside,x
 beq gwev_yes
 lda #$00
 rts
gwev_yes:
 lda #$01
 rts

.if WORLD_GROUND_PLANE_CLIP != 0
; The public plane is world Z = ground.z (internal engine Y).  ground_vside
; stores the signed world-side value before camera rotation; intersections are
; then interpolated in camera space, before the existing near/screen stages.
ground_plane_face_crossing:
 ldy faceidx
 ldx face0,y
 jsr ground_plane_vertex_inside
 sta t1
 ldx face1,y
 jsr ground_plane_vertex_inside
 eor t1
 bne gpfc_yes
 ldx face2,y
 jsr ground_plane_vertex_inside
 eor t1
 bne gpfc_yes
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne gpfc_no
.endif
 ldy faceidx
 ldx face3,y
 jsr ground_plane_vertex_inside
 eor t1
 bne gpfc_yes
gpfc_no:
 lda #$00
 rts
gpfc_yes:
 lda #$01
 rts

ground_plane_vertex_inside:
 sec
 lda explorer_cam_y_lo
 sbc #WORLD_GROUND_Y_LO
 lda explorer_cam_y_hi
 sbc #WORLD_GROUND_Y_HI
 lda explorer_cam_y_ext
 sbc #WORLD_GROUND_Y_EXT
 bmi gpvi_camera_below
 lda ground_vside,x
 bmi gpvi_outside
 lda #$01
 rts
gpvi_camera_below:
 lda ground_vside,x
 bpl gpvi_zero_or_outside
 lda #$01
 rts
gpvi_zero_or_outside:
 beq gpvi_inside
gpvi_outside:
 lda #$00
 rts
gpvi_inside:
 lda #$01
 rts

.if CAMERA_PLANE_CLIP_PROFILE != 0
; Ground clipping historically borrowed these labels from legacy near-poly.
; The camera-plane profile keeps the old block excluded and redirects only
; the three compact primitives Ground actually shares.
near_get_face_vertex:
 jmp camera_plane_get_face_vertex
near_interp_x_to_t1:
 jmp camera_plane_interp_original_x
near_interp_y_to_t2:
 jmp camera_plane_interp_original_y
.endif

ground_plane_clip_loaded_face:
 lda #$01
 sta clip_poly_active
 lda #$00
 sta clip_a_count
 lda loaded_face_vertex_count
 sec
 sbc #$01
 sta clip_prev_idx
 ldx clip_prev_idx
 jsr near_get_face_vertex
 tax
 jsr ground_plane_vertex_inside
 sta clip_prev_inside
 lda #$00
 sta clip_cur_idx
gpcl_loop:
 ldx clip_cur_idx
 jsr near_get_face_vertex
 tax
 jsr ground_plane_vertex_inside
 sta clip_cur_inside
 beq gpcl_cur_outside
 lda clip_prev_inside
 bne gpcl_append_current
 jsr ground_plane_append_intersection
gpcl_append_current:
 jsr ground_plane_append_current
 jmp gpcl_next
gpcl_cur_outside:
 lda clip_prev_inside
 beq gpcl_next
 jsr ground_plane_append_intersection
gpcl_next:
 lda clip_cur_idx
 sta clip_prev_idx
 lda clip_cur_inside
 sta clip_prev_inside
 inc clip_cur_idx
 lda clip_cur_idx
 cmp loaded_face_vertex_count
 bne gpcl_loop
 lda clip_a_count
 beq gpcl_done
.if CAMERA_PLANE_CLIP_PROFILE != 0
 jsr camera_plane_clip_a_to_b
 lda clip_a_count
 beq gpcl_done
 jsr camera_plane_project_all_a
 jsr camera_plane_store_bucket_from_a
.else
.if MODE3_LATE_NEAR_NO_POLY = 0
 jsr ground_plane_clip_near_a_to_b
 lda clip_a_count
 beq gpcl_done
.endif
.endif
.if CAMERA_PLANE_CLIP_PROFILE = 0
 jsr clip_poly_project_a_from_camera
.endif
 jsr clip_poly_clip_screen_current
gpcl_done:
 rts

ground_plane_append_current:
 ldx clip_cur_idx
 jsr near_get_face_vertex
 tax
 ldy clip_a_count
 lda vxrawlo,x
 sta clip_a_vxlo,y
 lda vxrawhi,x
 sta clip_a_vxhi,y
 lda vyrawlo,x
 sta clip_a_vylo,y
 lda vyrawhi,x
 sta clip_a_vyhi,y
 lda vzrawlo,x
 sta clip_a_vzlo,y
 lda vzrawhi,x
 sta clip_a_vzhi,y
.if WIRE_RENDER_ENABLE != 0
 lda #$00
 sta clip_a_flag,y
.endif
 inc clip_a_count
 rts

ground_plane_append_intersection:
 lda clip_cur_inside
 beq gpai_cur_outside
 ldx clip_prev_idx
 jsr near_get_face_vertex
 sta clip_in_x
 ldx clip_cur_idx
 jsr near_get_face_vertex
 sta clip_out_x
 jmp gpai_ratio
gpai_cur_outside:
 ldx clip_cur_idx
 jsr near_get_face_vertex
 sta clip_in_x
 ldx clip_prev_idx
 jsr near_get_face_vertex
 sta clip_out_x
gpai_ratio:
 ldx clip_in_x
 lda ground_vside,x
 jsr ground_plane_abs_a
 sta clip_num16_lo
 lda #$00
 sta clip_num16_hi
 ldx clip_out_x
 lda ground_vside,x
 jsr ground_plane_abs_a
 clc
 adc clip_num16_lo
 sta clip_den16_lo
 lda #$00
 adc #$00
 sta clip_den16_hi
 lda clip_den16_lo
 ora clip_den16_hi
 bne gpai_ratio_ready
 lda #$01
 sta clip_den16_lo
gpai_ratio_ready:
 jsr clip_ratio_to_scale8
 jsr near_interp_x_to_t1
 jsr near_interp_y_to_t2
 jsr ground_plane_interp_z_to_a
.if CAMERA_PLANE_CLIP_PROFILE = 0
 ldx clip_a_count
 jsr clip_project_a_x_from_camera
 ldx clip_a_count
 jsr clip_project_a_y_from_camera
.endif
.if WIRE_RENDER_ENABLE != 0
 ldy clip_a_count
 lda #$01
 sta clip_a_flag,y
.endif
 inc clip_a_count
 rts

ground_plane_abs_a:
 bpl gpaa_done
 eor #$ff
 clc
 adc #$01
gpaa_done:
 rts

ground_plane_interp_z_to_a:
 ldx clip_out_x
 lda vzrawlo,x
 sta p1lo
 lda vzrawhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc vzrawlo,x
 sta p1lo
 lda p1hi
 sbc vzrawhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc vzrawlo,x
 sta p1lo
 lda p1hi
 adc vzrawhi,x
 sta p1hi
 ldy clip_a_count
 lda p1lo
 sta clip_a_vzlo,y
 lda p1hi
 sta clip_a_vzhi,y
 rts

.if CAMERA_PLANE_CLIP_PROFILE = 0
ground_plane_clip_near_a_to_b:
 lda #$00
 sta clip_b_count
 lda clip_a_count
 beq gpcn_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
gpcn_loop:
 ldx clip_prev_idx
 jsr ground_plane_near_inside_a
 sta clip_prev_inside
 ldx clip_cur_idx
 jsr ground_plane_near_inside_a
 sta clip_cur_inside
 beq gpcn_cur_outside
 lda clip_prev_inside
 bne gpcn_append_current
 jsr ground_plane_append_near_intersection_a_to_b
gpcn_append_current:
 ldx clip_cur_idx
 jsr clip_copy_a_to_b
 jmp gpcn_next
gpcn_cur_outside:
 lda clip_prev_inside
 beq gpcn_next
 jsr ground_plane_append_near_intersection_a_to_b
gpcn_next:
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne gpcn_loop
 lda #$00
 sta clip_a_count
 lda #$00
 sta clip_cur_idx
gpcn_copy_back:
 lda clip_cur_idx
 cmp clip_b_count
 beq gpcn_done
 tax
 jsr clip_copy_b_to_a
 inc clip_cur_idx
 jmp gpcn_copy_back
gpcn_done:
 rts

ground_plane_near_inside_a:
 lda clip_a_vzhi,x
 bmi gpnia_out
 bne gpnia_in
 lda clip_a_vzlo,x
 cmp #CAMERA_FACE_MIN_DEPTH
 bcc gpnia_out
gpnia_in:
 lda #$01
 rts
gpnia_out:
 lda #$00
 rts

ground_plane_append_near_intersection_a_to_b:
 lda clip_prev_inside
 beq gpani_prev_outside
 lda clip_prev_idx
 sta clip_in_x
 lda clip_cur_idx
 sta clip_out_x
 jmp gpani_ratio
gpani_prev_outside:
 lda clip_cur_idx
 sta clip_in_x
 lda clip_prev_idx
 sta clip_out_x
gpani_ratio:
 ldx clip_in_x
 sec
 lda clip_a_vzlo,x
 sbc #CAMERA_FACE_MIN_DEPTH
 sta clip_num16_lo
 lda clip_a_vzhi,x
 sbc #$00
 sta clip_num16_hi
 ldx clip_out_x
 sec
 lda #CAMERA_FACE_MIN_DEPTH
 sbc clip_a_vzlo,x
 sta p1lo
 lda #$00
 sbc clip_a_vzhi,x
 sta p1hi
 clc
 lda clip_num16_lo
 adc p1lo
 sta clip_den16_lo
 lda clip_num16_hi
 adc p1hi
 sta clip_den16_hi
 jsr clip_ratio_to_scale8
 jsr clip_cam_interp_vx_a_to_b
 jsr clip_cam_interp_vy_a_to_b
 jsr clip_cam_interp_vz_a_to_b
.if WIRE_RENDER_ENABLE != 0
 ldy clip_b_count
 lda #$01
 sta clip_b_flag,y
.endif
 inc clip_b_count
 rts
.endif

; Fixed cameras normally compile out the explorer near helpers.  A plane
; crossing still needs those same camera-space predicates and projections,
; so emit only their compact, dependency-free forms for this profile.
.if CAMERA_MOVABLE = 0
explorer_face_near_projected:
 ldy faceidx
 lda #$00
 sta near_face_crossing
 sta maskv
 ldx face0,y
 lda projdone,x
 beq gpfnp_skip_v0
 inc maskv
gpfnp_skip_v0:
 ldx face1,y
 lda projdone,x
 beq gpfnp_skip_v1
 inc maskv
gpfnp_skip_v1:
 ldx face2,y
 lda projdone,x
 beq gpfnp_skip_v2
 inc maskv
gpfnp_skip_v2:
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 cmp #$04
 bne gpfnp_tri
.endif
 ldx face3,y
 lda projdone,x
 beq gpfnp_quad_count
 inc maskv
gpfnp_quad_count:
 lda maskv
 beq gpfnp_no
 cmp #$04
 beq gpfnp_yes
 lda #$01
 sta near_face_crossing
gpfnp_yes:
 lda #$01
 rts
.if HAS_TRI_FACES != 0
gpfnp_tri:
.endif
 lda maskv
 beq gpfnp_no
 cmp #$03
 beq gpfnp_yes
 lda #$01
 sta near_face_crossing
 jmp gpfnp_yes
gpfnp_no:
 lda #$00
 rts

explorer_axis_to_byte:
 lda p1hi
 bmi gpfa_negative
 bne gpfa_pos_sat
 lda p1lo
 bpl gpfa_done
gpfa_pos_sat:
 lda #$7f
 rts
gpfa_negative:
 cmp #$ff
 bne gpfa_neg_sat
 lda p1lo
 bmi gpfa_done
gpfa_neg_sat:
 lda #$80
gpfa_done:
 rts

div16u:
 lda #$00
 sta crosslo
 sta crosshi
 ldx #$10
gpfdiv_loop:
 asl prodlo
 rol prodhi
 rol crosslo
 rol crosshi
 lda crosslo
 sec
 sbc p1lo
 tay
 lda crosshi
 sbc p1hi
 bcc gpfdiv_skip_sub
 sta crosshi
 sty crosslo
 inc prodlo
gpfdiv_skip_sub:
 dex
 bne gpfdiv_loop
 rts
.endif

.if 0
; Plane clipping needs camera-space projection and interpolation but does not
; enable the general camera-frustum polygon pass.  Keep this minimal subset
; local to the plane profile so Mode 3 does not pay for four unused frustum
; clipping passes.
clip_poly_project_a_from_camera:
 lda clip_a_count
 beq gppp_done
 lda #$00
 sta clip_cur_idx
gppp_loop:
 ldx clip_cur_idx
 jsr clip_project_a_x_from_camera
 ldx clip_cur_idx
 jsr clip_project_a_y_from_camera
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne gppp_loop
gppp_done:
 rts

clip_project_a_x_from_camera:
 stx tmpidx
 lda clip_a_vzlo,x
 sta clip_axis_in_lo
 lda clip_a_vzhi,x
 sta clip_axis_in_hi
 lda clip_a_vxlo,x
 sta p1lo
 lda clip_a_vxhi,x
 sta p1hi
 jsr clip_project_axis_offset
 ldy tmpidx
 lda mul16reshi
 cmp #$ff
 bne gppax_not_saturated
 lda mul16sign
 bmi gppax_left_saturated
 lda #$00
 sta clip_a_xlo,y
 lda #$7f
 sta clip_a_xhi,y
 lda #PROJ_SCREEN_MAX_X
 sta clip_a_x,y
 rts
gppax_left_saturated:
 lda #$00
 sta clip_a_xlo,y
 lda #$80
 sta clip_a_xhi,y
 sta clip_a_x,y
 rts
gppax_not_saturated:
 lda mul16sign
 bmi gppax_left
 clc
 lda mul16reslo
 adc #PROJ_CENTER_X
 sta clip_a_xlo,y
 lda mul16reshi
 adc #$00
 sta clip_a_xhi,y
 bne gppax_right_clamp
 lda clip_a_xlo,y
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs gppax_right_clamp
 sta clip_a_x,y
 rts
gppax_right_clamp:
 lda #PROJ_SCREEN_MAX_X
 sta clip_a_x,y
 rts
gppax_left:
 lda #PROJ_CENTER_X
 sec
 sbc mul16reslo
 sta clip_a_xlo,y
 lda #$00
 sbc mul16reshi
 sta clip_a_xhi,y
 bmi gppax_left_clamp
 lda clip_a_xlo,y
 sta clip_a_x,y
 rts
gppax_left_clamp:
 lda #$00
 sta clip_a_x,y
 rts

clip_project_a_y_from_camera:
 stx tmpidx
 lda clip_a_vzlo,x
 sta clip_axis_in_lo
 lda clip_a_vzhi,x
 sta clip_axis_in_hi
 lda clip_a_vylo,x
 sta p1lo
 lda clip_a_vyhi,x
 sta p1hi
 jsr clip_project_axis_offset
 ldy tmpidx
 lda mul16reshi
 cmp #$ff
 bne gppay_not_saturated
 lda mul16sign
 bmi gppay_down_saturated
 lda #$00
 sta clip_a_ylo,y
 lda #$80
 sta clip_a_yhi,y
 lda #$00
 sta clip_a_y,y
 rts
gppay_down_saturated:
 lda #$00
 sta clip_a_ylo,y
 lda #$7f
 sta clip_a_yhi,y
 lda #PROJ_SCREEN_MAX_Y
 sta clip_a_y,y
 rts
gppay_not_saturated:
 lda mul16sign
 bmi gppay_down
 lda #PROJ_CENTER_Y
 sec
 sbc mul16reslo
 sta clip_a_ylo,y
 lda #$00
 sbc mul16reshi
 sta clip_a_yhi,y
 bmi gppay_top_clamp
 lda clip_a_ylo,y
 sta clip_a_y,y
 rts
gppay_top_clamp:
 lda #$00
 sta clip_a_y,y
 rts
gppay_down:
 clc
 lda mul16reslo
 adc #PROJ_CENTER_Y
 sta clip_a_ylo,y
 lda mul16reshi
 adc #$00
 sta clip_a_yhi,y
 bne gppay_bottom_clamp
 lda clip_a_ylo,y
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs gppay_bottom_clamp
 sta clip_a_y,y
 rts
gppay_bottom_clamp:
 lda #PROJ_SCREEN_MAX_Y
 sta clip_a_y,y
 rts

clip_project_axis_offset:
 lda #$00
 sta mul16sign
 lda p1hi
 bpl gppao_abs_ready
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
 lda #$80
 sta mul16sign
gppao_abs_ready:
 lda p1lo
 sta mul16lo
 lda p1hi
 sta mul16hi
 lda clip_axis_in_lo
 sta p1lo
 lda clip_axis_in_hi
 sta p1hi
 jsr clamp_projection_geometric_divisor_p1
 lda mul16hi
 beq gppao_mul_start
gppao_scale_loop:
 lsr mul16hi
 ror mul16lo
 lsr p1hi
 ror p1lo
 lda p1lo
 ora p1hi
 bne gppao_depth_nonzero
 lda #$01
 sta p1lo
gppao_depth_nonzero:
 lda mul16hi
 bne gppao_scale_loop
gppao_mul_start:
 lda #EXPLORER_PROJ_FOCAL
 sta mul16mul
 lda #$00
 sta prodlo
 sta prodhi
 sta mul16rem
 ldx #$08
gppao_mul_loop:
 lsr mul16mul
 bcc gppao_no_add
 lda mul16rem
 bne gppao_saturate
 clc
 lda prodlo
 adc mul16lo
 sta prodlo
 lda prodhi
 adc mul16hi
 sta prodhi
 bcs gppao_saturate
gppao_no_add:
 asl mul16lo
 rol mul16hi
 bcc gppao_shift_ok
 lda #$01
 sta mul16rem
gppao_shift_ok:
 dex
 bne gppao_mul_loop
 jmp gppao_divide
gppao_saturate:
 lda #$ff
 sta prodlo
 sta prodhi
gppao_divide:
 jsr div16u
 lda prodlo
 sta mul16reslo
 lda prodhi
 sta mul16reshi
 lda prodhi
 beq gppao_offset_ok
 lda #$ff
 sta scalev
 rts
gppao_offset_ok:
 lda prodlo
 sta scalev
 rts

clip_cam_interp_vx_a_to_b:
 ldx clip_out_x
 lda clip_a_vxlo,x
 sta p1lo
 lda clip_a_vxhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc clip_a_vxlo,x
 sta p1lo
 lda p1hi
 sbc clip_a_vxhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc clip_a_vxlo,x
 sta p1lo
 lda p1hi
 adc clip_a_vxhi,x
 sta p1hi
 ldy clip_b_count
 lda p1lo
 sta clip_b_vxlo,y
 lda p1hi
 sta clip_b_vxhi,y
 rts

clip_cam_interp_vy_a_to_b:
 ldx clip_out_x
 lda clip_a_vylo,x
 sta p1lo
 lda clip_a_vyhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc clip_a_vylo,x
 sta p1lo
 lda p1hi
 sbc clip_a_vyhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc clip_a_vylo,x
 sta p1lo
 lda p1hi
 adc clip_a_vyhi,x
 sta p1hi
 ldy clip_b_count
 lda p1lo
 sta clip_b_vylo,y
 lda p1hi
 sta clip_b_vyhi,y
 rts

clip_cam_interp_vz_a_to_b:
 ldx clip_out_x
 lda clip_a_vzlo,x
 sta p1lo
 lda clip_a_vzhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc clip_a_vzlo,x
 sta p1lo
 lda p1hi
 sbc clip_a_vzhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc clip_a_vzlo,x
 sta p1lo
 lda p1hi
 adc clip_a_vzhi,x
 sta p1hi
 ldy clip_b_count
 lda p1lo
 sta clip_b_vzlo,y
 lda p1hi
 sta clip_b_vzhi,y
 rts
.endif
.endif
.endif
'@
}
if ($EngineGroundSimpleRuntimeFlag -ne 0) {
 $WorldGroundRenderCallAsm = if ($EngineMode3FramePrefillRuntimeFlag -ne 0) { "" } else { " jsr render_world_ground_simple_engine" }
 $WorldGroundRendererAsm = @'
render_world_ground_simple_engine:
.if WORLD_GROUND_ENABLE != 0
 ldx explorer_cam_pitch
 lda world_ground_horizon_start,x
 sta p1lo
 sec
 lda explorer_cam_y_lo
 sbc #WORLD_GROUND_Y_LO
 lda explorer_cam_y_hi
 sbc #WORLD_GROUND_Y_HI
 lda explorer_cam_y_ext
 sbc #WORLD_GROUND_Y_EXT
 bmi rwgss_fill_above
rwgss_fill_below:
 lda p1lo
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcc rwgss_below_visible
 rts
rwgss_below_visible:
 sta yrow
rwgss_below_loop:
 jsr world_ground_simple_fill_current_row_engine
 inc yrow
 lda yrow
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bne rwgss_below_loop
 rts
rwgss_fill_above:
 lda p1lo
 bne rwgss_above_visible
 rts
rwgss_above_visible:
 sec
 sbc #$01
 sta maxrow
 lda #$00
 sta yrow
rwgss_above_loop:
 jsr world_ground_simple_fill_current_row_engine
 lda yrow
 cmp maxrow
 beq rwgss_above_done
 inc yrow
 jmp rwgss_above_loop
rwgss_above_done:
 rts
.else
 rts
.endif

world_ground_simple_fill_current_row_engine:
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq wgssfr_draw
 ldx yrow
 jsr lowres_row_selected
 bne wgssfr_done
.endif
wgssfr_draw:
 lda drawbuf
 bne wgssfr_b
wgssfr_a:
 jsr world_ground_simple_apply_cells_a_engine
 ldx yrow
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 jmp world_ground_simple_fill_bitmap_row_engine
wgssfr_b:
 jsr world_ground_simple_apply_cells_b_engine
 ldx yrow
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
 jmp world_ground_simple_fill_bitmap_row_engine
wgssfr_done:
 rts

world_ground_simple_apply_cells_a_engine:
 ldx yrow
 lda screenrowlo_a,x
 sta ptr0lo
 lda screenrowhi_a,x
 sta ptr0hi
 jmp world_ground_simple_apply_cells_common_engine

world_ground_simple_apply_cells_b_engine:
 ldx yrow
 lda screenrowlo_b,x
 sta ptr0lo
 lda screenrowhi_b,x
 sta ptr0hi

world_ground_simple_apply_cells_common_engine:
 ldx yrow
 lda colorrowlo,x
 sta ptr1lo
 lda colorrowhi,x
 sta ptr1hi
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_CELL_ORIGIN_X
 sta ptr0lo
 bcc wgssac_screen_origin_ok
 inc ptr0hi
wgssac_screen_origin_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_CELL_ORIGIN_X
 sta ptr1lo
 bcc wgssac_color_origin_ok
 inc ptr1hi
wgssac_color_origin_ok:
.endif
 ldx #CAMERA_VIEWPORT_CELL_WIDTH
 ldy #$00
wgssac_loop:
 lda #WORLD_GROUND_SCREEN_BYTE
 sta (ptr0lo),y
.if ENGINE_MODE3_STABLE_GROUND_CELL_LAYOUT = 0
 ; General engine path: ground may own color-RAM slot 11.
 lda #WORLD_GROUND_COLOR_RAM
 sta (ptr1lo),y
.else
 ; Stable engine-mode3 layout: slot 11 belongs to the shared object ramp and Color RAM is global
 ; across the two bitmap buffers. Do not recolor the visible cube while
 ; prefilling the hidden buffer.
.endif
 inc ptr0lo
 bne wgssac_screen_ok
 inc ptr0hi
wgssac_screen_ok:
 inc ptr1lo
 bne wgssac_color_ok
 inc ptr1hi
wgssac_color_ok:
 dex
 bne wgssac_loop
 rts

world_ground_simple_fill_bitmap_row_engine:
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr0lo
 bcc wgssfb_origin0_ok
 inc ptr0hi
wgssfb_origin0_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr1lo
 bcc wgssfb_origin1_ok
 inc ptr1hi
wgssfb_origin1_ok:
.endif
 ldx #CAMERA_VIEWPORT_CELL_WIDTH
 ldy #$00
wgssfb_loop:
.if ENGINE_MODE3_STABLE_GROUND_CELL_LAYOUT != 0
 lda #$55
.else
 lda #$ff
.endif
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgssfb_ptr0_ok
 inc ptr0hi
wgssfb_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgssfb_ptr1_ok
 inc ptr1hi
wgssfb_ptr1_ok:
 dex
 bne wgssfb_loop
 rts

.if ENGINE_MODE3_FRAME_PREFILL_RUNTIME_ACTIVE != 0
engine_mode3_frame_prefill:
.if WORLD_GROUND_ENABLE != 0
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq sm3fp_full_frame
 jsr clear_current_bitmap_lowres_trace
 jsr render_world_ground_simple_engine
 rts
sm3fp_full_frame:
.endif
 ldx explorer_cam_pitch
 lda world_ground_horizon_start,x
 sta p1lo
 lda #$ff
 sta shadeidx
 sec
 lda explorer_cam_y_lo
 sbc #WORLD_GROUND_Y_LO
 lda explorer_cam_y_hi
 sbc #WORLD_GROUND_Y_HI
 lda explorer_cam_y_ext
 sbc #WORLD_GROUND_Y_EXT
 bmi sm3fp_camera_below
 lda #$00
 sta p1hi
 beq sm3fp_rows_init
sm3fp_camera_below:
 lda #$01
 sta p1hi
sm3fp_rows_init:
 lda #$00
 sta yrow
sm3fp_row_loop:
 lda p1hi
 bne sm3fp_ground_above
sm3fp_ground_below:
 lda yrow
 cmp p1lo
 bcc sm3fp_sky_row
 jmp sm3fp_ground_row
sm3fp_ground_above:
 lda yrow
 cmp p1lo
 bcc sm3fp_ground_row
sm3fp_sky_row:
 lda #$00
 sta fillbyte
 jsr engine_mode3_prefill_bitmap_row
 jmp sm3fp_next_row
sm3fp_ground_row:
.if ENGINE_MODE3_GROUND_CELLROW_WRITE_ON_CHANGE != 0
 ldx yrow
 lda viewport_cellrow_id,x
 cmp shadeidx
 beq sm3fp_ground_cells_done
 sta shadeidx
.endif
 lda drawbuf
 bne sm3fp_ground_cells_b
 jsr world_ground_simple_apply_cells_a_engine
 jmp sm3fp_ground_cells_done
sm3fp_ground_cells_b:
 jsr world_ground_simple_apply_cells_b_engine
sm3fp_ground_cells_done:
.if ENGINE_MODE3_STABLE_GROUND_CELL_LAYOUT != 0
 ; Four multicolor pixels encoded as 01: ground uses screen-RAM high nibble.
 lda #$55
.else
 lda #$ff
.endif
 sta fillbyte
 jsr engine_mode3_prefill_bitmap_row
sm3fp_next_row:
 inc yrow
 lda yrow
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bne sm3fp_row_loop
 rts
.else
 rts
.endif

engine_mode3_prefill_bitmap_row:
 lda drawbuf
 bne sm3fpbr_b
sm3fpbr_a:
 ldx yrow
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 jmp sm3fpbr_common
sm3fpbr_b:
 ldx yrow
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
sm3fpbr_common:
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr0lo
 bcc sm3fpbr_origin0_ok
 inc ptr0hi
sm3fpbr_origin0_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr1lo
 bcc sm3fpbr_origin1_ok
 inc ptr1hi
sm3fpbr_origin1_ok:
.endif
 ldx #CAMERA_VIEWPORT_CELL_WIDTH
 ldy #$00
sm3fpbr_loop:
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc sm3fpbr_ptr0_ok
 inc ptr0hi
sm3fpbr_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc sm3fpbr_ptr1_ok
 inc ptr1hi
sm3fpbr_ptr1_ok:
 dex
 bne sm3fpbr_loop
 rts
.endif
'@
 $WorldGroundRollRendererAsm = ""
 $WorldGroundOcclusionAsm = ""
}
$ObjectLightCacheShadeFlag = if ($FullDynamicShadeFlag -ne 0) { 1 } else { 0 }
$Mode4ObjectLightCacheFlag = if ($ObjectLightCacheShadeFlag -ne 0 -and $SceneObjectCount -gt 0 -and $DynamicLightFlag -ne 0) { 1 } else { 0 }
$EmitMode4UncachedLightFallbackFlag = if ($Mode4FamilyFlag -ne 0 -and $DynamicLightFlag -ne 0 -and $Mode4ObjectLightCacheFlag -eq 0) { 1 } else { 0 }
$WireMeshCount = @($MeshRecords | Where-Object { [bool]$_.IsWire }).Count
$PolyMeshCount = $MeshCount - $WireMeshCount
$SceneWireMeshObjectCount = 0
foreach ($object in $SceneObjects) {
 $meshRecordForObject = $MeshRecords[[int]$object.MeshIndex]
 if ([bool]$meshRecordForObject.IsWire) {
 $SceneWireMeshObjectCount++
 }
}
$SceneSolidMeshObjectCount = $SceneMeshObjectCount - $SceneWireMeshObjectCount
$SceneMultimaterialMeshObjectCount = 0
foreach ($object in $SceneObjects) {
 $meshRecordForObject = $MeshRecords[[int]$object.MeshIndex]
 if ((-not [bool]$meshRecordForObject.IsWire) -and ([string]$meshRecordForObject.MaterialProfile -eq "multimaterial")) {
 $SceneMultimaterialMeshObjectCount++
 }
}
$SceneSingleMaterialMeshObjectCount = $SceneSolidMeshObjectCount - $SceneMultimaterialMeshObjectCount
$WireFaceMeshCount = @($MeshRecords | Where-Object { [int]$_.FaceCount -gt 0 }).Count
$WireFaceEdgeFlag = if ($WireOnlyRenderFlag -ne 0 -and $WireFaceMeshCount -gt 0) { 1 } else { 0 }
if ($Mode2MemorySpecializationFlag -ne 0) {
 $WireFaceEdgeFlag = 0
}
if ($EngineMode1FacePassStrippedFlag -ne 0) {
 $WireFaceEdgeFlag = 0
}
if ($WireMeshCount -gt 0 -and ($WireOnlyRenderFlag -eq 0 -or $HiddenWireFlag -ne 0)) {
 $WireOverlayFlag = 1
 $WireRenderFlag = 1
}
$WireDepthSortFlag = if ($WireOverlayFlag -ne 0 -and ($PolyFillFlag -ne 0 -or $HiddenWireFlag -ne 0) -and $SceneObjectCount -gt 0 -and $WireMeshCount -gt 0) { 1 } else { 0 }
if ($EngineMode1WirePureRuntimeFlag -ne 0) {
 $WireDepthSortFlag = 0
}
$WireColorActiveFlag = if ($WireRenderFlag -ne 0 -and $WireMeshCount -gt 0) { 1 } else { 0 }
$FastFillBoundsTraceFlag = 0
$SourceHasTriangleFacesFlag = if (@($MeshFaceVertexCounts | Where-Object { [int]$_ -eq 3 }).Count -gt 0) { 1 } else { 0 }
$ForceFaceRenderFlag = switch ($FaceRenderMode) {
 "force" { 1 }
 "cull" { 0 }
 "conservative" { 0 }
 default { 0 }
}
$ConservativeFaceCullFlag = if ($WireOnlyRenderFlag -eq 0 -and $FaceRenderMode -ne "cull" -and $FaceRenderMode -ne "force") { 1 } else { 0 }
$ConservativeSliverCullFlag = if ($WireOnlyRenderFlag -eq 0) { $ConservativeFaceCullFlag } else { 0 }
$ConservativeCullNegArea = 32
$ConservativeEdgeCullNegArea = 96
$ConservativeSliverThinSpan = 3
$ConservativeSliverLongSpan = 6
$HasTriangleFacesFlag = $SourceHasTriangleFacesFlag
$FaceCullPrepFlag = if ($WireOnlyRenderFlag -eq 0 -and $ForceFaceRenderFlag -eq 0) { 1 } else { 0 }
if ($ForceFaceRenderFlag -ne 0) {
 if ($MinFaceAreaOverride -lt 0) { $MinFaceArea = 0 }
 if ($ScreenMinSpanOverride -lt 0 -and $ScreenMinSpan -gt 1) { $ScreenMinSpan = 1 }
}
if ($SourceVertexCount -gt 255) {
 throw "Too many source vertices for byte-sized indexed mesh: $SourceVertexCount"
}
if ($SourceFaceCount -gt 255) {
 throw "Too many source faces for byte-sized face loop: $SourceFaceCount"
}
if ($VertexCount -gt 255) {
 throw "Shared-source runtime vertex buffers exceed the byte-sized limit: $VertexCount"
}
if ($FaceCount -gt 255) {
 throw "Shared-source runtime face entries exceed the byte-sized limit: $FaceCount"
}
if ($MeshCount -lt 1 -or $MeshCount -gt 255) {
 throw "Invalid mesh catalog size: $MeshCount"
}
if ($SceneObjectCount -gt 255) {
 throw "Too many scene objects for byte-sized loop: $SceneObjectCount"
}
foreach ($v in $MeshVertices) {
 foreach ($coord in $v) {
 $c = [int]$coord
 if ($c -lt -63 -or $c -gt 63) {
 throw "Mesh coordinate out of signed 6-bit engine range (-63..63): $c"
 }
 }
}

$faceShade = @()
$faceStaticFill = @()
$faceSolidColor = @()
$StaticShadeSolidBytes = @(0x55,0x55,0xaa,0xaa,0xff,0xff,0xff,0xff)
$StaticShadePatternBytes = @(0x55,0x55,0x66,0x99,0xbb,0xee,0x77,0xdd)
$LightShadeBytes = @(0x80,0x00,0x82,0x02,0x84,0x84)
$LightIntensityTable = @()
$ShadeThresholdMid = Get-IntensityThresholdTable 8
$ShadeThresholdMidHigh = Get-IntensityThresholdTable 16
$ShadeThresholdHigh = Get-IntensityThresholdTable 24
$ShadeHystDarkUp = Get-IntensityThresholdTable 2
$ShadeHystCheckerDarkUp = Get-IntensityThresholdTable 10
$ShadeHystSolidMidDown = Get-IntensityThresholdTable 6
$ShadeHystSolidMidUp = Get-IntensityThresholdTable 18
$ShadeHystCheckerHighDown = Get-IntensityThresholdTable 14
$ShadeHystCheckerHighUp = Get-IntensityThresholdTable 26
$ShadeHystSolidHighDown = Get-IntensityThresholdTable 22
function ConvertTo-Q6ThresholdPairs([int[]]$Thresholds) {
 $pairs = @()
 foreach ($threshold in $Thresholds) {
  $q6 = [int]$threshold * 64
  $pairs += ($q6 -band 0xff)
  $pairs += (($q6 -shr 8) -band 0xff)
 }
 return $pairs
}
$ShadeThresholdMidQ6 = ConvertTo-Q6ThresholdPairs $ShadeThresholdMid
$ShadeThresholdMidHighQ6 = ConvertTo-Q6ThresholdPairs $ShadeThresholdMidHigh
$ShadeThresholdHighQ6 = ConvertTo-Q6ThresholdPairs $ShadeThresholdHigh
$ShadeHystDarkUpQ6 = ConvertTo-Q6ThresholdPairs $ShadeHystDarkUp
$ShadeHystCheckerDarkUpQ6 = ConvertTo-Q6ThresholdPairs $ShadeHystCheckerDarkUp
$ShadeHystSolidMidDownQ6 = ConvertTo-Q6ThresholdPairs $ShadeHystSolidMidDown
$ShadeHystSolidMidUpQ6 = ConvertTo-Q6ThresholdPairs $ShadeHystSolidMidUp
$ShadeHystCheckerHighDownQ6 = ConvertTo-Q6ThresholdPairs $ShadeHystCheckerHighDown
$ShadeHystCheckerHighUpQ6 = ConvertTo-Q6ThresholdPairs $ShadeHystCheckerHighUp
$ShadeHystSolidHighDownQ6 = ConvertTo-Q6ThresholdPairs $ShadeHystSolidHighDown
$faceNormalX = @()
$faceNormalY = @()
$faceNormalZ = @()
$cameraPlaneCullNormalX = @()
$cameraPlaneCullNormalY = @()
$cameraPlaneCullNormalZ = @()
$faceCenterX = @()
$faceCenterY = @()
$faceCenterZ = @()
$faceCenterDotLo = @()
$faceCenterDotHi = @()
$LightPosX = @()
$LightPosY = @()
$LightPosZ = @()
$meshFirstVertex = @()
$meshEndVertex = @()
$meshFirstFace = @()
$meshEndFace = @()
$meshIsWire = @()
$meshWireColor = @()
$objectMeshIndex = @()
$objectPosXLo = @()
$objectPosXHi = @()
$objectPosYLo = @()
$objectPosYHi = @()
$objectPosZLo = @()
$objectPosZHi = @()
$objectPosZExt = @()
$objectVelXLo = @()
$objectVelXHi = @()
$objectVelYLo = @()
$objectVelYHi = @()
$objectVelZLo = @()
$objectVelZHi = @()
$objectVelZExt = @()
$objectAngXLo = @()
$objectAngXHi = @()
$objectAngYLo = @()
$objectAngYHi = @()
$objectAngZLo = @()
$objectAngZHi = @()
$objectAngVelXLo = @()
$objectAngVelXHi = @()
$objectAngVelYLo = @()
$objectAngVelYHi = @()
$objectAngVelZLo = @()
$objectAngVelZHi = @()
$objectScale = @()
$objectWireScreen = @()
$objectWireColor = @()
$objectMaterialOverride = @()
$objectReflectivityOverride = @()
$objectColorOverride = @()
$objectRuntimeVFirst = @()
$objectRuntimeVEnd = @()
$objectRuntimeFaceFirst = @()
$objectRuntimeFaceEnd = @()
$objectSourceVertexDelta = @()
$bucketFaceInstance = @()
$bucketFaceLocal = @()
$objectTraverseRadius = @()
$objectVisible = @()
$objectRespawnEnabled = @()
$objectRespawnNearZHi = @()
$objectRespawnFarZLo = @()
$objectRespawnFarZHi = @()
$objectRespawnFarZExt = @()
$objectRespawnFarZJitterMask = @()
$objectRespawnXMask = @()
$objectRespawnXBias = @()
$objectRespawnYMask = @()
$objectRespawnYBias = @()
$objectOscXEnabled = @()
$objectOscXMinLo = @()
$objectOscXMinHi = @()
$objectOscXMaxLo = @()
$objectOscXMaxHi = @()
$faceMaterial = @()
$faceReflectivity = @()
$faceScale = @()

function Test-AnyNonZeroByte([object[]]$Values) {
 foreach ($value in $Values) {
 if ([int]$value -ne 0) {
 return $true
 }
 }
 return $false
}

function Test-AllByteEqual([object[]]$Values, [int]$Expected) {
 foreach ($value in $Values) {
 if ([int]$value -ne $Expected) {
 return $false
 }
 }
 return $true
}

function Get-ObjectTraversalRadius([object]$Object) {
 $meshIndex = [int]$Object.MeshIndex
 $record = $MeshRecords[$meshIndex]
 $first = [int]$record.FirstVertex
 $end = $first + [int]$record.VertexCount
 $maxRadius = 0.0
 for ($i = $first; $i -lt $end; $i++) {
 $v = $MeshVertices[$i]
 $x = [double]([int]$v[0])
 $y = [double]([int]$v[1])
 $z = [double]([int]$v[2])
 $radius = [Math]::Sqrt(($x * $x) + ($y * $y) + ($z * $z))
 if ($radius -gt $maxRadius) {
 $maxRadius = $radius
 }
 }
 $scaled = [Math]::Ceiling(($maxRadius * [double]([int]$Object.Scale)) / 64.0)
 $threshold = [int]$scaled + 8 + 4
 if ($threshold -gt 127) { return 127 }
 if ($threshold -lt 8) { return 8 }
 return $threshold
}

foreach ($record in $MeshRecords) {
 $meshFirstVertex += [int]$record.FirstVertex
 $meshEndVertex += ([int]$record.FirstVertex + [int]$record.VertexCount)
 $meshFirstFace += [int]$record.FirstFace
 $meshEndFace += ([int]$record.FirstFace + [int]$record.FaceCount)
 $meshIsWire += $(if ([bool]$record.IsWire) { 1 } else { 0 })
 $meshWireColor += $(if ([bool]$record.IsWire -and [int]$record.WireColor -ge 0) { [int]$record.WireColor } else { 255 })
}
$runtimeVertexCursor = 0
$runtimeFaceCursor = 0
foreach ($object in $SceneObjects) {
 $runtimeObjectIndex = $objectMeshIndex.Count
 $runtimeRecord = $MeshRecords[[int]$object.MeshIndex]
 if ($MeshSourceSharingRuntimeFlag -ne 0) {
  $objectRuntimeVFirst += $runtimeVertexCursor
  $runtimeVertexCursor += [int]$runtimeRecord.VertexCount
  $objectRuntimeVEnd += $runtimeVertexCursor
  $objectRuntimeFaceFirst += $runtimeFaceCursor
  for ($localFaceIndex = 0; $localFaceIndex -lt [int]$runtimeRecord.FaceCount; $localFaceIndex++) {
   $bucketFaceInstance += $runtimeObjectIndex
   $bucketFaceLocal += $localFaceIndex
   $runtimeFaceCursor++
  }
  $objectRuntimeFaceEnd += $runtimeFaceCursor
  $objectSourceVertexDelta += (($objectRuntimeVFirst[-1] - [int]$runtimeRecord.FirstVertex) -band 255)
 }
 $position = @($object.Position)
 $velocity = @($object.Velocity)
 $rotation = @($object.Rotation)
 $angularVelocity = @($object.AngularVelocity)
 $px = Split-Fixed8 ([int]$position[0])
 $py = Split-Fixed8 ([int]$position[1])
 $pz = Split-Fixed16_8 ([int]$position[2])
 $vx = Split-Fixed8 ([int]$velocity[0])
 $vy = Split-Fixed8 ([int]$velocity[1])
 $vz = Split-Fixed16_8 ([int]$velocity[2])
 $ax = Split-Fixed8 ([int]$rotation[0])
 $ay = Split-Fixed8 ([int]$rotation[1])
 $az = Split-Fixed8 ([int]$rotation[2])
 $avx = Split-Fixed8 ([int]$angularVelocity[0])
 $avy = Split-Fixed8 ([int]$angularVelocity[1])
 $avz = Split-Fixed8 ([int]$angularVelocity[2])
 $objectMeshIndex += [int]$object.MeshIndex
 $objectPosXLo += [int]$px.Lo
 $objectPosXHi += [int]$px.Hi
 $objectPosYLo += [int]$py.Lo
 $objectPosYHi += [int]$py.Hi
 $objectPosZLo += [int]$pz.Frac
 $objectPosZHi += [int]$pz.Lo
 $objectPosZExt += [int]$pz.Hi
 $objectVelXLo += [int]$vx.Lo
 $objectVelXHi += [int]$vx.Hi
 $objectVelYLo += [int]$vy.Lo
 $objectVelYHi += [int]$vy.Hi
 $objectVelZLo += [int]$vz.Frac
 $objectVelZHi += [int]$vz.Lo
 $objectVelZExt += [int]$vz.Hi
 $objectAngXLo += [int]$ax.Lo
 $objectAngXHi += [int]$ax.Hi
 $objectAngYLo += [int]$ay.Lo
 $objectAngYHi += [int]$ay.Hi
 $objectAngZLo += [int]$az.Lo
 $objectAngZHi += [int]$az.Hi
 $objectAngVelXLo += [int]$avx.Lo
 $objectAngVelXHi += [int]$avx.Hi
 $objectAngVelYLo += [int]$avy.Lo
 $objectAngVelYHi += [int]$avy.Hi
 $objectAngVelZLo += [int]$avz.Lo
 $objectAngVelZHi += [int]$avz.Hi
 $objectScale += [int]$object.Scale
 $objectMaterialOverride += [int]$object.Material
 $objectReflectivityOverride += [int]$object.Reflectivity
 $objectColorOverride += [int]$object.ColorOverride
 $objectRecord = $MeshRecords[[int]$object.MeshIndex]
 if ([bool]$objectRecord.IsWire -and [int]$object.WireColor -ge 0) {
 $wireColor = [int]$object.WireColor
 $objectWireScreen += ($wireColor -band 15)
 $objectWireColor += ($wireColor -band 15)
 } elseif ([bool]$objectRecord.IsWire) {
 $wireColor = if ([int]$object.WireColor -ge 0) { [int]$object.WireColor } else { [int]$objectRecord.WireColor }
 $objectWireScreen += ($wireColor -band 15)
 $objectWireColor += ($wireColor -band 15)
 } else {
 $wireMaterial = if ([int]$object.Material -eq 255) { $MaterialIndex } else { [int]$object.Material }
 $wireReflectivity = if ([int]$object.Reflectivity -eq 255) { $MaterialReflectivityOffset } else { [int]$object.Reflectivity }
 $wireMaterialOffset = $wireReflectivity + $wireMaterial
 $objectWireScreen += [int]$MaterialScreenBytes[$wireMaterialOffset]
 $objectWireColor += [int]$MaterialColorBytes[$wireMaterialOffset]
 }
 $objectTraverseRadius += Get-ObjectTraversalRadius $object
 $objectVisible += [int]$object.Visible
 $respawn = $object.Respawn
 $objectRespawnEnabled += [int]$respawn.Enabled
 $objectRespawnNearZHi += [int]$respawn.NearZHi
 $objectRespawnFarZLo += [int]$respawn.FarZLo
 $objectRespawnFarZHi += [int]$respawn.FarZHi
 $objectRespawnFarZExt += [int]$respawn.FarZExt
 $objectRespawnFarZJitterMask += [int]$respawn.FarZJitterMask
 $objectRespawnXMask += [int]$respawn.XMask
 $objectRespawnXBias += [int]$respawn.XBias
 $objectRespawnYMask += [int]$respawn.YMask
 $objectRespawnYBias += [int]$respawn.YBias
 $oscillation = $object.Oscillation
 $objectOscXEnabled += [int]$oscillation.Enabled
 $objectOscXMinLo += [int]$oscillation.MinLo
 $objectOscXMinHi += [int]$oscillation.MinHi
 $objectOscXMaxLo += [int]$oscillation.MaxLo
 $objectOscXMaxHi += [int]$oscillation.MaxHi
}
if ($MeshSourceSharingRuntimeFlag -ne 0) {
 if ($runtimeVertexCursor -ne $VertexCount -or $runtimeFaceCursor -ne $FaceCount) {
  throw "Shared-source descriptor construction disagrees with runtime counts"
 }
 if ($bucketFaceInstance.Count -ne $FaceCount -or $bucketFaceLocal.Count -ne $FaceCount) {
  throw "Shared-source bucket identity table is incomplete"
 }
}

$SceneVelXActiveFlag = if ((Test-AnyNonZeroByte $objectVelXLo) -or (Test-AnyNonZeroByte $objectVelXHi)) { 1 } else { 0 }
$SceneVelYActiveFlag = if ((Test-AnyNonZeroByte $objectVelYLo) -or (Test-AnyNonZeroByte $objectVelYHi)) { 1 } else { 0 }
$SceneVelZActiveFlag = if ((Test-AnyNonZeroByte $objectVelZLo) -or (Test-AnyNonZeroByte $objectVelZHi) -or (Test-AnyNonZeroByte $objectVelZExt)) { 1 } else { 0 }
$ScenePosActiveFlag = if (($SceneVelXActiveFlag -ne 0) -or ($SceneVelYActiveFlag -ne 0) -or ($SceneVelZActiveFlag -ne 0)) { 1 } else { 0 }
$SceneAngXActiveFlag = if ((Test-AnyNonZeroByte $objectAngVelXLo) -or (Test-AnyNonZeroByte $objectAngVelXHi)) { 1 } else { 0 }
$SceneAngYActiveFlag = if ((Test-AnyNonZeroByte $objectAngVelYLo) -or (Test-AnyNonZeroByte $objectAngVelYHi)) { 1 } else { 0 }
$SceneAngZActiveFlag = if ((Test-AnyNonZeroByte $objectAngVelZLo) -or (Test-AnyNonZeroByte $objectAngVelZHi)) { 1 } else { 0 }
$SceneRotActiveFlag = if (($SceneAngXActiveFlag -ne 0) -or ($SceneAngYActiveFlag -ne 0) -or ($SceneAngZActiveFlag -ne 0)) { 1 } else { 0 }
$SceneObjectXActiveFlag = if ((Test-AnyNonZeroByte $objectPosXHi) -or ($SceneVelXActiveFlag -ne 0)) { 1 } else { 0 }
$SceneObjectYActiveFlag = if ((Test-AnyNonZeroByte $objectPosYHi) -or ($SceneVelYActiveFlag -ne 0)) { 1 } else { 0 }
$SceneObjectScaleActiveFlag = if (Test-AllByteEqual $objectScale 0x40) { 0 } else { 1 }
$SceneObjectVisibilityActiveFlag = if ((-not (Test-AllByteEqual $objectVisible 1)) -or ($SceneTimelineFlag -ne 0 -and [bool]$SceneTimelineCompiled.UsesVisibility)) { 1 } else { 0 }
$SceneInstanceOverrideFlag = if (@($SceneObjects | Where-Object { [bool]$_.InstanceOverrideProfile }).Count -gt 0 -or ($SceneTimelineFlag -ne 0 -and [bool]$SceneTimelineCompiled.UsesOverrides)) { 1 } else { 0 }
$SceneInstanceColorOverrideFlag = if (@($SceneObjects | Where-Object { [int]$_.ColorOverride -ne 255 }).Count -gt 0 -or ($SceneTimelineFlag -ne 0 -and [bool]$SceneTimelineCompiled.UsesColorOverride)) { 1 } else { 0 }
$SceneFaceMaterialOverrideFlag = if (@($MeshFaceMaterialFamilies | Where-Object { [int]$_ -ge 0 }).Count -gt 0) { 1 } else { 0 }
$SceneInstanceMaterialAllPinnedFlag = if ($SceneInstanceOverrideFlag -ne 0 -and @($SceneObjects | Where-Object { [int]$_.Material -eq 255 }).Count -eq 0) { 1 } else { 0 }
$SceneInstanceReflectivityAllPinnedFlag = if ($SceneInstanceOverrideFlag -ne 0 -and @($SceneObjects | Where-Object { [int]$_.Reflectivity -eq 255 }).Count -eq 0) { 1 } else { 0 }
$SceneRespawnActiveFlag = if (Test-AnyNonZeroByte $objectRespawnEnabled) { 1 } else { 0 }
$SceneOscXActiveFlag = if (Test-AnyNonZeroByte $objectOscXEnabled) { 1 } else { 0 }
$ObjectLinearVelocityDataRequiredFlag = if (($ScenePosActiveFlag -ne 0) -or ($SceneOscXActiveFlag -ne 0) -or ($SceneTimelineFlag -ne 0 -and [bool]$SceneTimelineCompiled.UsesVelocity)) { 1 } else { 0 }
$ObjectAngularVelocityDataRequiredFlag = if (($SceneRotActiveFlag -ne 0) -or ($SceneTimelineFlag -ne 0 -and [bool]$SceneTimelineCompiled.UsesAngularVelocity)) { 1 } else { 0 }
if ($SceneTimelineFlag -ne 0 -and [bool]$SceneTimelineCompiled.UsesVelocity) { $ScenePosActiveFlag=1; $SceneVelXActiveFlag=1; $SceneVelYActiveFlag=1; $SceneVelZActiveFlag=1 }
if ($SceneTimelineFlag -ne 0 -and [bool]$SceneTimelineCompiled.UsesAngularVelocity) { $SceneRotActiveFlag=1; $SceneAngXActiveFlag=1; $SceneAngYActiveFlag=1; $SceneAngZActiveFlag=1 }
if ($SceneTimelineFlag -ne 0) { $SceneObjectXActiveFlag=1; $SceneObjectYActiveFlag=1; $SceneObjectScaleActiveFlag=1 }
$recordMaterialByIndex = @{}
$recordReflectivityByIndex = @{}
$recordScaleByIndex = @{}
$recordObjectByIndex = @{}
if ($SceneObjectCount -gt 0) {
 foreach ($object in $SceneObjects) {
 $recordMaterialByIndex[[int]$object.MeshIndex] = [int]$object.Material
 $recordReflectivityByIndex[[int]$object.MeshIndex] = [int]$object.Reflectivity
 $recordScaleByIndex[[int]$object.MeshIndex] = [int]$object.Scale
 $recordObjectByIndex[[int]$object.MeshIndex] = $object
 }
}
$recordIndex = 0
foreach ($record in $MeshRecords) {
 $meshMidY = Get-MeshMidYRange ([int]$record.FirstVertex) ([int]$record.VertexCount)
 $firstFace = [int]$record.FirstFace
 $endFace = $firstFace + [int]$record.FaceCount
 $materialForRecord = if ($MeshSourceSharingRuntimeFlag -ne 0) { 255 } elseif ($recordMaterialByIndex.ContainsKey($recordIndex)) { [int]$recordMaterialByIndex[$recordIndex] } else { 255 }
 $reflectivityForRecord = if ($MeshSourceSharingRuntimeFlag -ne 0) { 255 } elseif ($recordReflectivityByIndex.ContainsKey($recordIndex)) { [int]$recordReflectivityByIndex[$recordIndex] } else { 255 }
 $scaleForRecord = if ($MeshSourceSharingRuntimeFlag -ne 0) { 64 } elseif ($recordScaleByIndex.ContainsKey($recordIndex)) { [int]$recordScaleByIndex[$recordIndex] } else { 64 }
 $objectForRecord = if ($MeshSourceSharingRuntimeFlag -ne 0) { $null } elseif ($recordObjectByIndex.ContainsKey($recordIndex)) { $recordObjectByIndex[$recordIndex] } else { $null }
 $rotationForRecord = if ($null -ne $objectForRecord) { @($objectForRecord.Rotation) } else { @(0, 0, 0) }
 $positionForRecord = if ($null -ne $objectForRecord) { @($objectForRecord.Position) } else { @(0, 0, 0) }
 $staticReflectivityForRecord = if ($reflectivityForRecord -eq 255) { $MaterialReflectivityOffset } else { $reflectivityForRecord }
 for ($faceIndex = $firstFace; $faceIndex -lt $endFace; $faceIndex++) {
 $shadeForFace = 0
 if ([int]$MeshFaceMaterials[$faceIndex] -ge 0) {
 $shadeForFace = ([int]$MeshFaceMaterials[$faceIndex] -band 255)
 } elseif ($StaticShadeCacheFlag -ne 0) {
 $shadeForFace = Get-StaticFaceShade $faceIndex $rotationForRecord $positionForRecord $scaleForRecord $staticReflectivityForRecord $StaticShadeLightPosition $EffectiveLightIntensity
 } else {
 $shadeForFace = Get-GeneralFaceMaterial ([int[]]$MeshFaces[$faceIndex]) $meshMidY
 }
 $faceShade += $shadeForFace
 if ($StaticShadeDirectFlag -ne 0) {
 $solidShadeIndex = ([int]$shadeForFace) -band 0x07
 $faceStaticFill += [int]$StaticShadeSolidBytes[$solidShadeIndex]
 }
 $materialForFace = if ([int]$MeshFaceMaterialFamilies[$faceIndex] -ge 0) { [int]$MeshFaceMaterialFamilies[$faceIndex] } else { $materialForRecord }
 $faceMaterial += $materialForFace
 $faceReflectivity += $reflectivityForRecord
 $solidColorForFace = if ([int]$MeshFaceSolidColorUse[$faceIndex] -ne 0 -and [int]$MeshFaceSolidColors[$faceIndex] -ge 0) { [int]$MeshFaceSolidColors[$faceIndex] } else { 255 }
 $faceSolidColor += $solidColorForFace
 $faceScale += $scaleForRecord
 }
 $recordIndex++
}
$FaceSolidColorRequestedFlag = if (Test-AllByteEqual $faceSolidColor 0xff) { 0 } else { 1 }
$FaceSolidColorFlag = if ($FaceSolidColorRequestedFlag -ne 0 -and $GraphicsModeNumber -ge 1 -and $GraphicsModeNumber -le 5) { 1 } else { 0 }
$FaceReflectivityActiveOnlyFlag = if (Test-AllByteEqual $faceReflectivity 0xff) { 1 } else { 0 }
$FaceMaterialActiveOnlyFlag = if (Test-AllByteEqual $faceMaterial 0xff) { 1 } else { 0 }
$SceneFaceMaterialTableActiveFlag = if ($FaceMaterialActiveOnlyFlag -eq 0) { 1 } else { 0 }
$SceneFaceSolidColorTableRequestedFlag = $FaceSolidColorRequestedFlag
$WireTwoColorMultimaterialRequestedFlag = if (
 $EngineWireModeRuntimeFlag -ne 0 -and
 @($MeshRecords | Where-Object { [string]$_.MaterialProfile -eq "multimaterial" }).Count -gt 0
) { 1 } else { 0 }
$WireTwoColorMultimaterialFlag = 0
$WireTwoColorMode1Flag = 0
$WireTwoColorMode2Flag = 0
$WireTwoColorSlot01Family = 255
$WireTwoColorSlot10Family = 255
$WireTwoColorSlot01Color = 0
$WireTwoColorSlot10Color = 0
$WireTwoColorScreenByte = 0
$WireTwoColorFixedColorRam = 0
$WireTwoColorSlot01FaceCount = 0
$WireTwoColorSlot10FaceCount = 0
$WireTwoColorMode1EdgeCount = 0
$WireTwoColorMode1CrossMaterialEdgeCount = 0
$WireTwoColorMode2FaceEdgeReferenceCount = 0
$WireTwoColorMode2UniqueEdgeCount = 0
$WireTwoColorMode2EdgeRedrawCount = 0
$WireTwoColorSameBucketTieBreakStableFlag = 0
$wireFaceSlot = @()

if ($WireTwoColorMultimaterialRequestedFlag -ne 0) {
 if ($FaceCount -le 0) {
 throw "Two-color wire multimaterial requires at least one face"
 }

 $wireFamilies = New-Object System.Collections.Generic.List[int]
 for ($wireFaceIndex = 0; $wireFaceIndex -lt $FaceCount; $wireFaceIndex++) {
 $explicitFamily = [int]$MeshFaceMaterialFamilies[$wireFaceIndex]
 if ($explicitFamily -lt 0) {
 throw "Two-color wire multimaterial requires an explicit faceMaterialFamilies mapping for every face; face $wireFaceIndex is unmapped"
 }
 if (-not $wireFamilies.Contains($explicitFamily)) {
 $wireFamilies.Add($explicitFamily)
 }
 }

 if ($wireFamilies.Count -ne 2) {
 $familyNames = @($wireFamilies | ForEach-Object { [string]$MaterialFamilies[[int]$_].name }) -join ", "
 throw "Two-color wire multimaterial requires exactly two effective face material families; found $($wireFamilies.Count): $familyNames"
 }

 $WireTwoColorSlot01Family = [int]$wireFamilies[0]
 $WireTwoColorSlot10Family = [int]$wireFamilies[1]
 $WireTwoColorSlot01Color = Get-WireMaterialFamilyC64Color $WireTwoColorSlot01Family "bitmap slot 01"
 $WireTwoColorSlot10Color = Get-WireMaterialFamilyC64Color $WireTwoColorSlot10Family "bitmap slot 10"
 if ($WireTwoColorSlot01Color -eq $WireTwoColorSlot10Color) {
 throw "Two-color wire multimaterial requires two different VIC-II pigments; both families resolve to $WireTwoColorSlot01Color"
 }
 $WireTwoColorScreenByte = (($WireTwoColorSlot01Color -shl 4) -bor $WireTwoColorSlot10Color)
 if ((($WireTwoColorScreenByte -shr 4) -band 15) -ne $WireTwoColorSlot01Color -or ($WireTwoColorScreenByte -band 15) -ne $WireTwoColorSlot10Color) {
 throw "Two-color wire multimaterial screenByte is inconsistent with slots 01/10"
 }
 # Color RAM is deliberately fixed and never distinguishes the two pigments.
 # All two-color wire pixels select only bitmap slots 01 ($55) or 10 ($AA).
 $WireTwoColorFixedColorRam = $WireTwoColorSlot10Color

 for ($wireFaceIndex = 0; $wireFaceIndex -lt $FaceCount; $wireFaceIndex++) {
 $family = [int]$MeshFaceMaterialFamilies[$wireFaceIndex]
 if ($family -eq $WireTwoColorSlot01Family) {
 $wireFaceSlot += 1
 $WireTwoColorSlot01FaceCount++
 } elseif ($family -eq $WireTwoColorSlot10Family) {
 $wireFaceSlot += 2
 $WireTwoColorSlot10FaceCount++
 } else {
 throw "Two-color wire multimaterial has no slot mapping for face $wireFaceIndex family $family"
 }
 }

 if ($wireFaceSlot.Count -ne $FaceCount -or ($WireTwoColorSlot01FaceCount + $WireTwoColorSlot10FaceCount) -ne $FaceCount) {
 throw "Two-color wire multimaterial face-slot mapping is incomplete"
 }

 # Host-side topology audit only. Mode 2 retains direct face-border drawing and
 # allocates no runtime edge/owner buffer. Within a bucket the existing LIFO
 # chain draws descending face indices, so the lower/source-first face wins.
 foreach ($wireRecord in $MeshRecords) {
 $wireTopologyEdges = @{}
 $wireFirstFace = [int]$wireRecord.FirstFace
 $wireFaceEnd = $wireFirstFace + [int]$wireRecord.FaceCount
 for ($wireFaceIndex = $wireFirstFace; $wireFaceIndex -lt $wireFaceEnd; $wireFaceIndex++) {
 $wireFace = [int[]]$MeshFaces[$wireFaceIndex]
 $wireArity = [int]$MeshFaceVertexCounts[$wireFaceIndex]
 for ($wireSide = 0; $wireSide -lt $wireArity; $wireSide++) {
 $wireA = [int]$wireFace[$wireSide]
 $wireB = [int]$wireFace[($wireSide + 1) % $wireArity]
 $wireLo = [Math]::Min($wireA, $wireB)
 $wireHi = [Math]::Max($wireA, $wireB)
 $wireKey = "${wireLo}:${wireHi}"
 $WireTwoColorMode2FaceEdgeReferenceCount++
 if (-not $wireTopologyEdges.ContainsKey($wireKey)) {
 $wireTopologyEdges[$wireKey] = 1
 $WireTwoColorMode2UniqueEdgeCount++
 }
 }
 }
 }
 $WireTwoColorMode2EdgeRedrawCount = $WireTwoColorMode2FaceEdgeReferenceCount - $WireTwoColorMode2UniqueEdgeCount
 $WireTwoColorSameBucketTieBreakStableFlag = 1
 $WireTwoColorMultimaterialFlag = 1
 $WireTwoColorMode1Flag = if ($GraphicsModeNumber -eq 1) { 1 } else { 0 }
 $WireTwoColorMode2Flag = if ($GraphicsModeNumber -eq 2) { 1 } else { 0 }
}
$Mode4ReflectiveHysteresisBypassFlag = 0
if ($Mode4FamilyFlag -ne 0 -and $Mode4ShadeStepLimitFlag -ne 0 -and $faceReflectivity.Count -gt 0) {
 $allFacesReflectiveOrMirror = $true
 foreach ($faceReflectivityOffset in $faceReflectivity) {
  $effectiveReflectivityOffset = if ([int]$faceReflectivityOffset -eq 255) { [int]$MaterialReflectivityOffset } else { [int]$faceReflectivityOffset }
  $effectiveReflectivityIndex = if (($effectiveReflectivityOffset % $MaterialCount) -eq 0) { [int]($effectiveReflectivityOffset / $MaterialCount) } else { -1 }
  if ($effectiveReflectivityIndex -ne 2 -and $effectiveReflectivityIndex -ne 3) {
   $allFacesReflectiveOrMirror = $false
   break
  }
 }
 if ($allFacesReflectiveOrMirror) {
  $Mode4ReflectiveHysteresisBypassFlag = 1
 }
}

# Adaptive engine-mode3 ground/object cell policy.
# The VIC-II exposes two per-buffer Screen RAM colors and one Color RAM color
# shared by both bitmap buffers. Select the safest layout supported by the scene:
#
# Shared-ramp exact layout: ground in slot 01, one shared object
# ramp in slots 10/11; Color RAM never changes while the hidden buffer is drawn;
# 2. adaptive screen-pair layout: ground in fixed Color RAM slot 11, object colors
# in Screen RAM slots 01/10. This supports any number of material families and
# explicit solid face colors without hidden-buffer Color RAM interference.
# Reflective highlight is folded onto the high pigment when a ramp needs three
# colors. Cells touched by different object palettes remain a VIC-II ownership
# limit and are resolved by normal depth/draw order.
$EngineMode3DemoCellColorStabilityRequestedFlag = if ($EngineMode3DemoCellColorStability.IsPresent) { 1 } else { 0 }
$EngineMode3DemoCellColorStabilityFlag = $EngineMode3DemoCellColorStabilityRequestedFlag
$EngineMode3StableGroundCellLayoutFlag = 0
$EngineMode3StableGroundCellLayoutAutoFlag = 0
$EngineMode3StableGroundMultiObjectFlag = 0
$EngineMode3StableGroundSharedRampFlag = 0
$EngineMode3StableGroundSlot01Flag = 0
$EngineMode3StableGroundObjectSlot10Flag = 0
$EngineMode3StableGroundObjectSlot11Flag = 0
$EngineMode3StableGroundColorRamWriteStrippedFlag = 0
$EngineMode3StableGroundDoubleBufferSafeFlag = 0
$EngineMode3StableGroundEligibilityText = "disabled"
$EngineMode3AdaptiveCellPolicyFlag = 0
$EngineMode3AdaptiveSharedRampExactFlag = 0
$EngineMode3AdaptiveScreenPairLayoutFlag = 0
$EngineMode3AdaptiveMultiRampFlag = 0
$EngineMode3AdaptiveGroundSlot11Flag = 0
$EngineMode3AdaptiveObjectSlots0110Flag = 0
$EngineMode3AdaptiveColorRamFixedGroundFlag = 0
$EngineMode3AdaptiveHighlightFoldFlag = 0
$EngineMode3AdaptiveFaceSolidColorFlag = 0
$EngineMode3AdaptiveDoubleBufferSafeFlag = 0
$EngineMode3AdaptiveRuntimeMaterialSafeFlag = 0
$EngineMode3AdaptiveUserCellConflictFlag = 0
$EngineMode3AdaptiveRampCount = 0
$EngineMode3AdaptiveThirdColorRampCount = 0
$EngineMode3AdaptivePolicyText = "disabled"
$EngineMode3AdaptiveEligibilityText = "disabled"
$EngineMode3AdaptiveSlotMapText = "none"
$adaptiveRuntimeMaterialDynamic = $false
$EngineMode3DemoMaterialDarkColor = 255
$EngineMode3DemoMaterialHighColor = 255
$EngineMode3DemoMaterialHighlightColor = 255
$EngineMode3DemoObjectSlot11Color = 255
$EngineMode3DemoStaticShadeVariantCount = @($faceShade | Sort-Object -Unique).Count
$EngineMode3DemoSlotMapText = "none"

$engineMode3AdaptiveBaseEligible = (
 $RendererActiveFlag -ne 0 -and
 $GraphicsModeNumber -eq 3 -and
 $PolyFillFlag -ne 0 -and
 $WireRenderFlag -eq 0 -and
 $HiddenWireFlag -eq 0 -and
 -not $NoEngineMode3StableGroundCellLayout.IsPresent -and
 -not $NoEngineMode3AdaptiveCellPolicy.IsPresent -and
 $SceneObjectCount -ge 1 -and
 $WorldGroundCount -eq 1 -and
 [int]$EngineGroundSimpleRuntimeFlag -ne 0 -and
 $VicColorPolicyEffectiveEnableFlag -eq 0 -and
 $StaticShadeCacheFlag -ne 0 -and
 $StaticShadeDirectFlag -ne 0 -and
 $WorldBackgroundColor -eq 0 -and
 $WorldGroundColor -ne 0
)

if ($engineMode3AdaptiveBaseEligible) {
 $EngineMode3AdaptiveEligibilityText = "base-compatible"
 $adaptiveRampKeys = @()
 for ($adaptiveFaceIndex = 0; $adaptiveFaceIndex -lt $faceMaterial.Count; $adaptiveFaceIndex++) {
 $adaptiveMaterialIndex = if ([int]$faceMaterial[$adaptiveFaceIndex] -eq 255) { [int]$MaterialIndex } else { [int]$faceMaterial[$adaptiveFaceIndex] }
 $adaptiveReflectivityOffset = if ([int]$faceReflectivity[$adaptiveFaceIndex] -eq 255) { [int]$MaterialReflectivityOffset } else { [int]$faceReflectivity[$adaptiveFaceIndex] }
 $adaptiveRampKey = "${adaptiveReflectivityOffset}:${adaptiveMaterialIndex}"
 if ($adaptiveRampKeys -notcontains $adaptiveRampKey) {
 $adaptiveRampKeys += $adaptiveRampKey
 }
 }

 $adaptiveRampRecords = @()
 $adaptiveRampsValid = $true
 foreach ($adaptiveRampKey in $adaptiveRampKeys) {
 $adaptiveRampParts = $adaptiveRampKey.Split(':')
 $adaptiveReflectivityOffset = [int]$adaptiveRampParts[0]
 $adaptiveMaterialIndex = [int]$adaptiveRampParts[1]
 if ($adaptiveMaterialIndex -lt 0 -or $adaptiveMaterialIndex -ge $MaterialCount -or ($adaptiveReflectivityOffset % $MaterialCount) -ne 0) {
 $adaptiveRampsValid = $false
 $EngineMode3AdaptiveEligibilityText = "material-or-reflectivity-index-invalid"
 break
 }
 $adaptiveReflectivityIndex = [int]($adaptiveReflectivityOffset / $MaterialCount)
 $adaptiveRamp = @($MaterialFamilies[$adaptiveMaterialIndex].ramps | Where-Object { [int]$_.reflectivity -eq $adaptiveReflectivityIndex } | Select-Object -First 1)
 if ($adaptiveRamp.Count -ne 1) {
 $adaptiveRampsValid = $false
 $EngineMode3AdaptiveEligibilityText = "material-ramp-not-found"
 break
 }
 $adaptiveRampRecords += [pscustomobject]@{
 MaterialIndex = $adaptiveMaterialIndex
 ReflectivityOffset = $adaptiveReflectivityOffset
 TableIndex = ($adaptiveReflectivityOffset + $adaptiveMaterialIndex)
 Dark = [int]$adaptiveRamp[0].dark
 High = [int]$adaptiveRamp[0].high
 Highlight = [int]$adaptiveRamp[0].highlight
 }
 }

 if ($adaptiveRampsValid -and $adaptiveRampRecords.Count -ge 1) {
 $EngineMode3AdaptiveRampCount = $adaptiveRampRecords.Count
 $EngineMode3AdaptiveThirdColorRampCount = @($adaptiveRampRecords | Where-Object {
 $adaptiveUniqueColors = @(
 [int]$_.Dark
 [int]$_.High
 [int]$_.Highlight
 ) | Sort-Object -Unique
 $adaptiveUniqueColors.Count -gt 2
 }).Count
 $EngineMode3AdaptiveFaceSolidColorFlag = $FaceSolidColorRequestedFlag

 $adaptiveRuntimeMaterialDynamic = ($ControlMaterialFlag -ne 0 -or $ControlReflectivityFlag -ne 0 -or $RandomMaterialCycleFlag -ne 0)
 $adaptiveSharedRampExact = $false
 if ($adaptiveRampRecords.Count -eq 1 -and $FaceSolidColorRequestedFlag -eq 0 -and -not $adaptiveRuntimeMaterialDynamic) {
 $adaptiveFirstRamp = $adaptiveRampRecords[0]
 $adaptiveSharedColors = @(
 [int]$adaptiveFirstRamp.Dark,
 [int]$adaptiveFirstRamp.High,
 [int]$adaptiveFirstRamp.Highlight
 ) | Sort-Object -Unique
 $adaptiveSharedRampExact = ($adaptiveSharedColors.Count -eq 2)
 if ($adaptiveSharedRampExact) {
 foreach ($adaptiveSharedColor in $adaptiveSharedColors) {
 if ([int]$adaptiveSharedColor -eq 0 -or [int]$adaptiveSharedColor -eq $WorldGroundColor) {
 $adaptiveSharedRampExact = $false
 break
 }
 }
 }
 }

 if ($adaptiveSharedRampExact) {
 $stableRampRecord = $adaptiveRampRecords[0]
 $EngineMode3DemoMaterialDarkColor = [int]$stableRampRecord.Dark
 $EngineMode3DemoMaterialHighColor = [int]$stableRampRecord.High
 $EngineMode3DemoMaterialHighlightColor = [int]$stableRampRecord.Highlight
 $stableMaterialColors = @(
 $EngineMode3DemoMaterialDarkColor,
 $EngineMode3DemoMaterialHighColor,
 $EngineMode3DemoMaterialHighlightColor
 ) | Sort-Object -Unique

 $EngineMode3AdaptiveCellPolicyFlag = 1
 $EngineMode3AdaptiveSharedRampExactFlag = 1
 $EngineMode3AdaptiveDoubleBufferSafeFlag = 1
 $EngineMode3AdaptiveRuntimeMaterialSafeFlag = 1
 $EngineMode3AdaptivePolicyText = "shared-ramp-exact"
 $EngineMode3AdaptiveEligibilityText = "compatible-shared-two-color-ramp"
 $EngineMode3AdaptiveSlotMapText = "0-2-3-3"

 $EngineMode3StableGroundCellLayoutFlag = 1
 $EngineMode3StableGroundCellLayoutAutoFlag = if ($EngineMode3DemoCellColorStabilityRequestedFlag -eq 0) { 1 } else { 0 }
 $EngineMode3StableGroundMultiObjectFlag = if ($SceneObjectCount -gt 1) { 1 } else { 0 }
 $EngineMode3StableGroundSharedRampFlag = 1
 $EngineMode3StableGroundSlot01Flag = 1
 $EngineMode3StableGroundObjectSlot10Flag = 1
 $EngineMode3StableGroundObjectSlot11Flag = 1
 $EngineMode3StableGroundColorRamWriteStrippedFlag = 1
 $EngineMode3StableGroundDoubleBufferSafeFlag = 1
 $EngineMode3StableGroundEligibilityText = "compatible-shared-two-color-ramp"

 $stableSecondMaterialColor = [int](@($stableMaterialColors | Where-Object { [int]$_ -ne $EngineMode3DemoMaterialDarkColor })[0])
 $EngineMode3DemoObjectSlot11Color = $stableSecondMaterialColor
 $stableSemanticSlotMap = [int[]]@(
 0,
 2,
 $(if ($EngineMode3DemoMaterialHighColor -eq $EngineMode3DemoMaterialDarkColor) { 2 } else { 3 }),
 $(if ($EngineMode3DemoMaterialHighlightColor -eq $EngineMode3DemoMaterialDarkColor) { 2 } else { 3 })
 )
 $EngineMode3DemoSlotMapText = ($stableSemanticSlotMap -join "-")

 $StaticShadeSolidBytes = @($StaticShadeSolidBytes | ForEach-Object {
 Convert-MulticolorByteSlots ([int]$_) $stableSemanticSlotMap
 })
 $StaticShadePatternBytes = @($StaticShadePatternBytes | ForEach-Object {
 Convert-MulticolorByteSlots ([int]$_) $stableSemanticSlotMap
 })
 $faceStaticFill = @($faceShade | ForEach-Object {
 [int]$StaticShadeSolidBytes[([int]$_ -band 0x07)]
 })

 $stableMaterialTableIndex = [int]$stableRampRecord.TableIndex
 $MaterialScreenBytes[$stableMaterialTableIndex] = (([int]$WorldGroundScreenByte -band 0xf0) -bor ($EngineMode3DemoMaterialDarkColor -band 0x0f))
 $MaterialColorBytes[$stableMaterialTableIndex] = $EngineMode3DemoObjectSlot11Color
 $MaterialScreenByte = [int]$MaterialScreenBytes[$MaterialReflectivityOffset + $MaterialIndex]
 $MaterialColorByte = [int]$MaterialColorBytes[$MaterialReflectivityOffset + $MaterialIndex]
 } else {
 # Adaptive screen-pair layout. Screen RAM is double-buffered, so every
 # face/material may select its own dark/high pair without changing the
 # visible buffer's Color RAM. Slot 11 is fixed to the ground color.
 $EngineMode3AdaptiveCellPolicyFlag = 1
 $EngineMode3AdaptiveScreenPairLayoutFlag = 1
 $EngineMode3AdaptiveMultiRampFlag = if ($adaptiveRampRecords.Count -gt 1) { 1 } else { 0 }
 $EngineMode3AdaptiveGroundSlot11Flag = 1
 $EngineMode3AdaptiveObjectSlots0110Flag = 1
 $EngineMode3AdaptiveColorRamFixedGroundFlag = 1
 $EngineMode3AdaptiveHighlightFoldFlag = if (@($adaptiveRampRecords | Where-Object { [int]$_.Highlight -ne [int]$_.High }).Count -gt 0) { 1 } else { 0 }
 $EngineMode3AdaptiveDoubleBufferSafeFlag = 1
 $EngineMode3AdaptiveRuntimeMaterialSafeFlag = 1
 $EngineMode3AdaptiveUserCellConflictFlag = if ($adaptiveRampRecords.Count -gt 1 -or $FaceSolidColorRequestedFlag -ne 0) { 1 } else { 0 }
 $EngineMode3AdaptivePolicyText = "screen-pair-ground-color-ram"
 $EngineMode3AdaptiveEligibilityText = "compatible-adaptive-screen-pair"
 $EngineMode3AdaptiveSlotMapText = "0-1-2-2"
 $EngineMode3StableGroundEligibilityText = if ($adaptiveRampRecords.Count -gt 1) {
 "multiple-material-ramps-routed-to-adaptive-policy"
 } elseif ($adaptiveRuntimeMaterialDynamic) {
 "runtime-material-controls-routed-to-adaptive-policy"
 } else {
 "shared-ramp-not-exact-routed-to-adaptive-policy"
 }

 $screenPairSemanticSlotMap = [int[]]@(0, 1, 2, 2)
 $StaticShadeSolidBytes = @($StaticShadeSolidBytes | ForEach-Object {
 Convert-MulticolorByteSlots ([int]$_) $screenPairSemanticSlotMap
 })
 $StaticShadePatternBytes = @($StaticShadePatternBytes | ForEach-Object {
 Convert-MulticolorByteSlots ([int]$_) $screenPairSemanticSlotMap
 })
 $faceStaticFill = @($faceShade | ForEach-Object {
 [int]$StaticShadeSolidBytes[([int]$_ -band 0x07)]
 })

 # Keep the original dark/high Screen RAM pair for all 10 material
 # families. Color RAM is fixed to the ground color in every entry.
 for ($adaptiveMaterialTableIndex = 0; $adaptiveMaterialTableIndex -lt $MaterialColorBytes.Count; $adaptiveMaterialTableIndex++) {
 $MaterialColorBytes[$adaptiveMaterialTableIndex] = $WorldGroundColorRam
 }
 $MaterialScreenByte = [int]$MaterialScreenBytes[$MaterialReflectivityOffset + $MaterialIndex]
 $MaterialColorByte = $WorldGroundColorRam

 $adaptiveFirstRamp = $adaptiveRampRecords[0]
 $EngineMode3DemoMaterialDarkColor = [int]$adaptiveFirstRamp.Dark
 $EngineMode3DemoMaterialHighColor = [int]$adaptiveFirstRamp.High
 $EngineMode3DemoMaterialHighlightColor = [int]$adaptiveFirstRamp.Highlight
 $EngineMode3DemoObjectSlot11Color = $WorldGroundColorRam
 $EngineMode3DemoSlotMapText = $EngineMode3AdaptiveSlotMapText
 }
 } elseif ($adaptiveRampsValid) {
 $EngineMode3AdaptiveEligibilityText = "no-material-ramp-records"
 }
}

if ($EngineMode3DemoCellColorStabilityRequestedFlag -ne 0) {
 if ($RendererActiveFlag -eq 0 -or $GraphicsModeNumber -ne 3) {
 throw "EngineMode3DemoCellColorStability is available only with -Renderer engine -GraphicsMode 3"
 }
 if ($EngineMode3StableGroundCellLayoutFlag -eq 0) {
 throw "EngineMode3DemoCellColorStability requires the exact shared two-color-ramp layout; adaptivePolicy=$EngineMode3AdaptivePolicyText eligibility=$EngineMode3AdaptiveEligibilityText"
 }
 if ($EngineMode3DemoStaticShadeVariantCount -lt 2) {
 throw "EngineMode3DemoCellColorStability requires at least two static shade values across the scene faces"
 }
}

# Backward-compatible markers from the original one-cube demo describe only the
# exact shared-ramp tier. The adaptive tier has separate markers below.
$EngineMode3DemoThreeColorLayoutFlag = $EngineMode3StableGroundCellLayoutFlag
$EngineMode3DemoGroundSlot01PreservedFlag = $EngineMode3StableGroundCellLayoutFlag
$EngineMode3DemoObjectSlot10Flag = $EngineMode3StableGroundCellLayoutFlag
$EngineMode3DemoObjectSlot11Flag = $EngineMode3StableGroundCellLayoutFlag
$EngineMode3DemoStaticShadingRestoredFlag = $EngineMode3AdaptiveCellPolicyFlag
$EngineMode3DemoNoFaceSolidOverrideFlag = if ($FaceSolidColorRequestedFlag -eq 0) { $EngineMode3AdaptiveCellPolicyFlag } else { 0 }
$EngineMode3DemoShadeFamilyReencodedFlag = $EngineMode3AdaptiveCellPolicyFlag
$EngineMode3DemoVicPolicyOffFlag = $EngineMode3AdaptiveCellPolicyFlag
$EngineMode3DemoGroundBitmapSlot01Flag = $EngineMode3StableGroundCellLayoutFlag
$EngineMode3DemoGroundColorRamWriteStrippedFlag = $EngineMode3StableGroundCellLayoutFlag
$EngineMode3DemoDoubleBufferColorStableFlag = $EngineMode3AdaptiveDoubleBufferSafeFlag
$SceneObjectWireFixedMaterialFlag = 0
if ($WireRenderFlag -ne 0 -and $SceneObjectCount -gt 0) {
 foreach ($object in $SceneObjects) {
 if ([int]$object.Material -ne 255 -or [int]$object.Reflectivity -ne 255) {
 $SceneObjectWireFixedMaterialFlag = 1
 break
 }
 }
}
$SceneObjectWireDifferentMaterialFlag = if ($WireRenderFlag -ne 0 -and $SceneObjectCount -gt 0 -and ((-not (Test-AllByteEqual $objectWireScreen $MaterialScreenByte)) -or (-not (Test-AllByteEqual $objectWireColor $MaterialColorByte)))) { 1 } else { 0 }
$SceneObjectWireControlMaterialFlag = if ($SceneObjectWireFixedMaterialFlag -ne 0 -and ($ControlMaterialFlag -ne 0 -or $ControlReflectivityFlag -ne 0)) { 1 } else { 0 }
$EngineGroundHorizonMaterialIsolatedFlag = if ($EngineGroundHorizonOnlyRuntimeFlag -ne 0 -and $WireRenderFlag -ne 0) { 1 } else { 0 }
$EngineGroundHorizonMaterialRestoreFlag = $EngineGroundHorizonMaterialIsolatedFlag
$EngineMeshWireMaterialReloadAfterGroundFlag = if ($EngineGroundHorizonMaterialRestoreFlag -ne 0 -and $SceneObjectCount -gt 0 -and $WireRenderFlag -ne 0) { 1 } else { 0 }
$WireObjectMaterialFlag = if ($WireRenderFlag -ne 0 -and $SceneObjectCount -gt 0 -and ($WireMeshCount -gt 0 -or $SceneObjectWireDifferentMaterialFlag -ne 0 -or $SceneObjectWireControlMaterialFlag -ne 0 -or $EngineMeshWireMaterialReloadAfterGroundFlag -ne 0)) { 1 } else { 0 }
$visibleObjectWireColors = @()
for ($i = 0; $i -lt $SceneObjectCount; $i++) {
 if ([int]$objectVisible[$i] -ne 0) {
 $visibleObjectWireColors += ("{0}:{1}" -f ([int]$objectWireScreen[$i]), ([int]$objectWireColor[$i]))
 }
}
$SceneObjectWireColorDiverseFlag = if (@($visibleObjectWireColors | Select-Object -Unique).Count -gt 1) { 1 } else { 0 }
$Mode1RenderableMeshCount = @($objectVisible | Where-Object { [int]$_ -ne 0 }).Count
$Mode1ObjectDepthSortFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0 -and $Mode1RenderableMeshCount -gt 1) { 1 } else { 0 }
$WireObjectSortEligibleFlag = if ($WirePureFlag -ne 0 -or ($HiddenWireFlag -ne 0 -and $WireDepthSortFlag -eq 0)) { 1 } else { 0 }
$WireObjectSortFlag = if ($WireObjectSortEligibleFlag -ne 0 -and $SceneObjectCount -gt 1 -and ($SceneObjectWireColorDiverseFlag -ne 0 -or $SceneObjectWireControlMaterialFlag -ne 0 -or $RandomMaterialCycleFlag -ne 0)) { 1 } else { 0 }
if ($EngineMode1WirePureRuntimeFlag -ne 0) {
 $WireObjectSortFlag = $Mode1ObjectDepthSortFlag
}
$EngineMode1WireRenderRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $WireRenderFlag } else { 0 }
$EngineMode1WireFaceEdgeRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $WireFaceEdgeFlag } else { 0 }
$EngineMode1HiddenWireRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $HiddenWireFlag } else { 0 }
$EngineMode1PolyFillRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $PolyFillFlag } else { 0 }
$EngineMode1WireDepthSortRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $WireDepthSortFlag } else { 0 }
$EngineMode1WireObjectSortRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $WireObjectSortFlag } else { 0 }
$EngineMode1VicPolicyRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $VicColorPolicyEnableFlag } else { 0 }
$EngineMode1GroundOcclusionRuntimeFlag = if ($EngineMode1WirePureRuntimeFlag -ne 0) { $RuntimeWorldGroundOccludeFlag } else { 0 }
$EngineMode2WireRenderRuntimeFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { $WireRenderFlag } else { 0 }
$EngineMode2HiddenWireFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { $HiddenWireFlag } else { 0 }
$EngineMode2PolyFillRuntimeFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { $PolyFillFlag } else { 0 }
$EngineMode2VicPolicyRuntimeFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { $VicColorPolicyEnableFlag } else { 0 }
$EngineWireMaterialColorRuntimeFlag = if ($EngineWireModeRuntimeFlag -ne 0 -and $WireRenderFlag -ne 0) { 1 } else { 0 }
$EngineWireObjectMaterialPathRuntimeFlag = if ($EngineWireModeRuntimeFlag -ne 0 -and $WireObjectMaterialFlag -ne 0) { 1 } else { 0 }
$EngineWireMaterialCellsRuntimeFlag = if ($EngineWireModeRuntimeFlag -ne 0 -and $WireRenderFlag -ne 0) { 1 } else { 0 }
$EngineMode2FaceMaskContractFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { 1 } else { 0 }
$EngineMode2FaceMaskRuntimeFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0 -and $RuntimeWorldGroundWireOccludeFlag -ne 0) { 1 } else { 0 }
$EngineMode2HorizonBehindFaceTargetFlag = if ($EngineMode2HiddenWireRuntimeFlag -ne 0) { 1 } else { 0 }
$EngineMode2HorizonBehindFaceRuntimeFlag = $EngineMode2FaceMaskRuntimeFlag
if ($WireOnlyRenderFlag -ne 0) {
 $FaceReflectivityActiveOnlyFlag = 1
 $FaceMaterialActiveOnlyFlag = 1
 if ($WireColorActiveFlag -ne 0 -or $WireObjectMaterialFlag -ne 0) {
 $FaceMaterialActiveOnlyFlag = 0
 }
}
if ($FaceSolidColorFlag -ne 0) {
 $FaceMaterialActiveOnlyFlag = 0
}
if ($WireOverlayFlag -ne 0 -and $WireColorActiveFlag -ne 0) {
 $FaceMaterialActiveOnlyFlag = 0
}
$MaterialCellSpanCacheFlag = if ($HighBasicV2LayoutFlag -ne 0 -and $PolyFillFlag -ne 0 -and $WireRenderFlag -eq 0 -and $VicColorPolicyEnableFlag -eq 0 -and ($FaceMaterialActiveOnlyFlag -eq 0 -or $FaceReflectivityActiveOnlyFlag -eq 0)) { 1 } else { 0 }
$LazyConvexBoundsFlag = if ($ExperimentalLazyBounds.IsPresent -and $HighBasicV2LayoutFlag -ne 0 -and $PolyFillFlag -ne 0 -and $WireRenderFlag -eq 0) { 1 } else { 0 }
$DirectConvexEdgeSpansEligibleFlag = if ($HighBasicV2LayoutFlag -ne 0 -and $PolyFillFlag -ne 0 -and $HiddenWireFlag -eq 0) { 1 } else { 0 }
$SpanKernelFillEligibleFlag = if ($HighBasicV2LayoutFlag -ne 0 -and $PolyFillFlag -ne 0 -and $HiddenWireFlag -eq 0) { 1 } else { 0 }
$DirectConvexEdgeSpansFlag = if ($NoDirectConvexFill.IsPresent) { 0 } else { $DirectConvexEdgeSpansEligibleFlag }
$SpanKernelFillFlag = if ($NoSpanKernelFill.IsPresent) { 0 } else { $SpanKernelFillEligibleFlag }
$ExperimentalIndexedOffsetSpanFillFlag = if ($ExperimentalIndexedSpanFill.IsPresent -and $HighBasicV2LayoutFlag -ne 0 -and $PolyFillFlag -ne 0 -and $WireRenderFlag -eq 0) { 1 } else { 0 }
$IndexedOffsetSpanFillFlag = $ExperimentalIndexedOffsetSpanFillFlag
$FallbackExperimentalConvexFanFillFlag = if ($ExperimentalConvexFanFill.IsPresent -and $HighBasicV2LayoutFlag -ne 0 -and $PolyFillFlag -ne 0 -and $WireRenderFlag -eq 0 -and $HiddenWireFlag -eq 0) { 1 } else { 0 }
# promote the existing direct convex fan/span rasterizer only for engine
# GraphicsMode 3 faces already certified as fully inside the viewport by face-prepare-once.
# Near/screen-clipped and otherwise unprepared faces retain the bounds path.
$EngineMode3DirectConvexFillFlag = if ($EngineMode3FacePrepareOnceFlag -ne 0 -and $HighBasicV2LayoutFlag -ne 0 -and $PolyFillFlag -ne 0 -and $WireRenderFlag -eq 0 -and $HiddenWireFlag -eq 0 -and -not $NoDirectConvexFill.IsPresent) { 1 } else { 0 }
$EngineMode3DirectConvexPreparedOnlyFlag = $EngineMode3DirectConvexFillFlag
$EngineMode3DirectConvexClipFallbackFlag = $EngineMode3DirectConvexFillFlag
$EngineMode3DirectConvexTriQuadFlag = $EngineMode3DirectConvexFillFlag
# prepared convex quads no longer use the 0-1-2 / 0-2-3 fan.
# Two monotone boundary chains share the existing validated edge walkers and emit
# one span per scanline. Triangles and every incompatible/diagnostic case retain
# the fan or bounds fallback path.
$EngineMode3NativeConvexQuadFillFlag = if ($EngineMode3DirectConvexFillFlag -ne 0 -and -not $NoNativeConvexQuadFill.IsPresent) { 1 } else { 0 }
$EngineMode3NativeConvexQuadPreparedOnlyFlag = $EngineMode3NativeConvexQuadFillFlag
$EngineMode3NativeConvexQuadSingleSpanFlag = $EngineMode3NativeConvexQuadFillFlag
$EngineMode3NativeConvexQuadFanFallbackFlag = $EngineMode3NativeConvexQuadFillFlag
$EngineMode3NativeConvexQuadTrianglesUnchangedFlag = $EngineMode3NativeConvexQuadFillFlag
# accelerate the bounds fallback retained by engine GraphicsMode 3.
# The walker emits left/right extrema directly with an 8-bit error accumulator.
# Only the three viewport-wide dx+dy overflow combinations retain the validated 16-bit span walker.
$EngineMode3FastBoundsTraceFlag = if ($EngineMode3DirectConvexClipFallbackFlag -ne 0 -and $LazyConvexBoundsFlag -eq 0 -and -not $NoFastBoundsTrace.IsPresent) { 1 } else { 0 }
$EngineMode3FastBounds8BitFlag = $EngineMode3FastBoundsTraceFlag
$EngineMode3FastBoundsDirectLeftRightFlag = $EngineMode3FastBoundsTraceFlag
$EngineMode3FastBoundsOverflowFallbackFlag = $EngineMode3FastBoundsTraceFlag
$EngineMode4FastBoundsTraceFlag = if ($RendererActiveFlag -ne 0 -and $GraphicsModeNumber -eq 4 -and $HighBasicV2LayoutFlag -ne 0 -and $PolyFillFlag -ne 0 -and $WireRenderFlag -eq 0 -and $HiddenWireFlag -eq 0 -and $LazyConvexBoundsFlag -eq 0 -and -not $NoMode4FastBoundsTrace.IsPresent) { 1 } else { 0 }
$EngineMode4FastBounds8BitFlag = $EngineMode4FastBoundsTraceFlag
$EngineMode4FastBoundsDirectLeftRightFlag = $EngineMode4FastBoundsTraceFlag
$EngineMode4FastBoundsOverflowFallbackFlag = $EngineMode4FastBoundsTraceFlag
$FastFillBoundsTraceFlag = if ($EngineMode3FastBoundsTraceFlag -ne 0 -or $EngineMode4FastBoundsTraceFlag -ne 0) { 1 } else { 0 }
# accelerate the span writer shared by direct-convex and bounds faces.
# Direct spans use indexed byte offsets from the left pointer; bounds spans keep the
# unrolled 2..6-byte kernels and switch to indexed offsets only for longer runs.
# Material cell rows use an aligned-Y transition key instead of two shifts per span.
$EngineMode3SpanHotloopFlag = if ($EngineMode3DirectConvexFillFlag -ne 0 -and $SpanKernelFillFlag -ne 0 -and -not $NoSpanHotloop.IsPresent) { 1 } else { 0 }
$EngineMode3DirectIndexedSpanFlag = $EngineMode3SpanHotloopFlag
$EngineMode3BoundsIndexedLongSpanFlag = $EngineMode3SpanHotloopFlag
$EngineMode3DirectByteAlignedEdgeWriteFlag = $EngineMode3SpanHotloopFlag
$EngineMode3MaterialCellTransitionFlag = if ($EngineMode3SpanHotloopFlag -ne 0 -and $MaterialCellSpanCacheFlag -ne 0) { 1 } else { 0 }
if ($EngineMode3SpanHotloopFlag -ne 0) {
 $IndexedOffsetSpanFillFlag = 1
}
# final C64 GraphicsMode 3 consolidation contract.
# This adds no scene-size specialization and no new runtime raster path. It certifies
# The renderer uses the validated universal stack and keeps all required fallbacks.
$EngineMode3FramePrefillCompatibleFlag = if ($WorldGroundCount -eq 0 -or $EngineMode3FramePrefillRuntimeFlag -ne 0) { 1 } else { 0 }
$EngineMode3ConsolidationFlag = if ($RendererActiveFlag -ne 0 -and $GraphicsModeNumber -eq 3 -and $HighBasicV2LayoutFlag -ne 0 -and $EngineMode3FramePrefillCompatibleFlag -ne 0 -and $EngineMode3FacePrepareOnceFlag -ne 0 -and $EngineMode3DirectConvexFillFlag -ne 0 -and $EngineMode3FastBoundsTraceFlag -ne 0 -and $EngineMode3SpanHotloopFlag -ne 0 -and $StaticShadeCacheFlag -ne 0 -and $StaticShadeDirectFlag -ne 0) { 1 } else { 0 }
$Mode3HighBasicFullRasterRelocationFlag = if (($CameraMovableFlag -ne 0 -or $WorldGroundPlaneRequestedFlag -ne 0) -and $HighBasicV2LayoutFlag -ne 0 -and (($GraphicsModeNumber -eq 3 -and ($EngineMode3ConsolidationFlag -ne 0 -or $WorldGroundPlaneRequestedFlag -ne 0)) -or $GraphicsModeNumber -eq 4 -or $GraphicsModeNumber -eq 5)) { 1 } else { 0 }
$EngineMode3ConsolidationCheckFlag = if ($EngineMode3ConsolidationCheck.IsPresent) { 1 } else { 0 }
$EngineMode3UniversalPathsOnlyFlag = $EngineMode3ConsolidationFlag
$EngineMode3CompactFaceQueueFlag = 0
$EngineMode3NormalViewportSupportedFlag = $EngineMode3ConsolidationFlag
$EngineMode3SmallViewportSupportedFlag = $EngineMode3ConsolidationFlag
$EngineMode3MultiObjectSupportedFlag = $EngineMode3ConsolidationFlag
$EngineMode3FallbacksPreservedFlag = if ($EngineMode3ConsolidationFlag -ne 0 -and $EngineMode3DirectConvexClipFallbackFlag -ne 0 -and $EngineMode3FastBoundsOverflowFallbackFlag -ne 0) { 1 } else { 0 }
if ($EngineMode3ConsolidationCheckFlag -ne 0) {
 if ($RendererActiveFlag -eq 0 -or $GraphicsModeNumber -ne 3) {
 throw "EngineMode3ConsolidationCheck is available only with -Renderer engine -GraphicsMode 3"
 }
 if ($EngineMode3ConsolidationFlag -eq 0) {
 throw "EngineMode3ConsolidationCheck requires ground-compatible frame prefill, face-prepare-once, direct convex fill, fast bounds trace, span hotloop and static shading"
 }
 if ($LazyConvexBoundsFlag -ne 0) {
 throw "EngineMode3ConsolidationCheck rejects ExperimentalLazyBounds"
 }
 if ($SceneObjectCount -lt 1) {
 throw "EngineMode3ConsolidationCheck requires at least one scene object"
 }
 if ($CameraViewportKey -ne "normal" -and $CameraViewportKey -ne "small") {
 throw "EngineMode3ConsolidationCheck supports only normal or small engine viewports"
 }
}
$DirectConvexFanFillFlag = if ($NoDirectConvexFill.IsPresent) { 0 } elseif ($EngineMode3DirectConvexFillFlag -ne 0) { 1 } else { $FallbackExperimentalConvexFanFillFlag }
$ExplorerMatrixFoldEligibleFlag = if ($HighBasicV2LayoutFlag -ne 0 -and $SceneObjectCount -gt 0 -and ($CameraMovableFlag -ne 0)) { 1 } else { 0 }
$ExplorerMatrixFoldFlag = if ($NoExplorerMatrixFold.IsPresent) { 0 } else { $ExplorerMatrixFoldEligibleFlag }

for ($faceIndex = 0; $faceIndex -lt $MeshFaces.Count; $faceIndex++) {
 $face = [int[]]$MeshFaces[$faceIndex]
 $faceArity = [int]$MeshFaceVertexCounts[$faceIndex]
 $facePoints = @()
 for ($faceVertexIndex = 0; $faceVertexIndex -lt $faceArity; $faceVertexIndex++) {
 $vertexIndex = [int]$face[$faceVertexIndex]
 $facePoints += ,([double[]]@(
 [double]$MeshVertices[$vertexIndex][0],
 [double]$MeshVertices[$vertexIndex][1],
 [double]$MeshVertices[$vertexIndex][2]
 ))
 }
 $cameraCullCross = $null
 $cameraCullP0 = [double[]]$facePoints[0]
 for ($cameraCullI = 1; $cameraCullI -lt ($facePoints.Count - 1) -and $null -eq $cameraCullCross; $cameraCullI++) {
  for ($cameraCullJ = $cameraCullI + 1; $cameraCullJ -lt $facePoints.Count; $cameraCullJ++) {
   $cameraCullP1 = [double[]]$facePoints[$cameraCullI]
   $cameraCullP2 = [double[]]$facePoints[$cameraCullJ]
   $cameraCullE1X = $cameraCullP1[0] - $cameraCullP0[0]
   $cameraCullE1Y = $cameraCullP1[1] - $cameraCullP0[1]
   $cameraCullE1Z = $cameraCullP1[2] - $cameraCullP0[2]
   $cameraCullE2X = $cameraCullP2[0] - $cameraCullP0[0]
   $cameraCullE2Y = $cameraCullP2[1] - $cameraCullP0[1]
   $cameraCullE2Z = $cameraCullP2[2] - $cameraCullP0[2]
   $cameraCullNX = ($cameraCullE1Y * $cameraCullE2Z) - ($cameraCullE1Z * $cameraCullE2Y)
   $cameraCullNY = ($cameraCullE1Z * $cameraCullE2X) - ($cameraCullE1X * $cameraCullE2Z)
   $cameraCullNZ = ($cameraCullE1X * $cameraCullE2Y) - ($cameraCullE1Y * $cameraCullE2X)
   $cameraCullLengthSq = ($cameraCullNX * $cameraCullNX) + ($cameraCullNY * $cameraCullNY) + ($cameraCullNZ * $cameraCullNZ)
   if ($cameraCullLengthSq -gt 0.000000001) {
    $cameraCullCross = Normalize-Vector ([double[]]@($cameraCullNX, $cameraCullNY, $cameraCullNZ))
    break
   }
  }
 }
 if ($null -eq $cameraCullCross) {
  throw "Camera-plane culling requires three non-collinear vertices in face $faceIndex"
 }
 $cameraPlaneCullNormalX += Clamp-SignedByte ([int][Math]::Round($cameraCullCross[0] * 63.0)) -63 63
 $cameraPlaneCullNormalY += Clamp-SignedByte ([int][Math]::Round($cameraCullCross[1] * 63.0)) -63 63
 $cameraPlaneCullNormalZ += Clamp-SignedByte ([int][Math]::Round($cameraCullCross[2] * 63.0)) -63 63

 $nx = 0.0
 $ny = 0.0
 $nz = 0.0
 for ($faceVertexIndex = 0; $faceVertexIndex -lt $facePoints.Count; $faceVertexIndex++) {
 $p = [double[]]$facePoints[$faceVertexIndex]
 $q = [double[]]$facePoints[($faceVertexIndex + 1) % $facePoints.Count]
 $nx += ($p[1] - $q[1]) * ($p[2] + $q[2])
 $ny += ($p[2] - $q[2]) * ($p[0] + $q[0])
 $nz += ($p[0] - $q[0]) * ($p[1] + $q[1])
 }
 $normal = Normalize-Vector ([double[]]@($nx, $ny, $nz))
 $qnx = Clamp-SignedByte ([int][Math]::Round($normal[0] * 63.0)) -63 63
 $qny = Clamp-SignedByte ([int][Math]::Round($normal[1] * 63.0)) -63 63
 $qnz = Clamp-SignedByte ([int][Math]::Round($normal[2] * 63.0)) -63 63
 $faceNormalX += $qnx
 $faceNormalY += $qny
 $faceNormalZ += $qnz

 $cx = 0.0
 $cy = 0.0
 $cz = 0.0
 foreach ($point in $facePoints) {
 $cx += $point[0]
 $cy += $point[1]
 $cz += $point[2]
 }
 $cx = ($cx / [double]$faceArity) / 2.0
 $cy = ($cy / [double]$faceArity) / 2.0
 $cz = ($cz / [double]$faceArity) / 2.0
 $qcx = Clamp-SignedByte ([int][Math]::Round($cx)) -63 63
 $qcy = Clamp-SignedByte ([int][Math]::Round($cy)) -63 63
 $qcz = Clamp-SignedByte ([int][Math]::Round($cz)) -63 63
 $faceCenterX += $qcx
 $faceCenterY += $qcy
 $faceCenterZ += $qcz

 $centerScale = if ($faceIndex -lt $faceScale.Count) { [int]$faceScale[$faceIndex] } else { 64 }
 $centerDot = [int][Math]::Round(((($qnx * $qcx) + ($qny * $qcy) + ($qnz * $qcz)) * [double]$centerScale) / 64.0)
 $centerDotWord = $centerDot -band 0xffff
 $faceCenterDotLo += ($centerDotWord -band 255)
 $faceCenterDotHi += (($centerDotWord -shr 8) -band 255)
}

if ($DynamicLightFlag -ne 0) {
 for ($phase = 0; $phase -lt $RuntimeLightPhaseCount; $phase++) {
 if ($SceneLightCount -gt 0 -and $ScenePrimaryLight.mode -eq "static") {
 $lightPosition = [int[]]@(
 [int]$ScenePrimaryLight.position[0],
 [int]$ScenePrimaryLight.position[1],
 [int]$ScenePrimaryLight.position[2]
 )
 } else {
 $positionPhase = if ($LightStaticPhase -ge 0) { $LightStaticPhase } else { $phase }
 $lightPosition = Get-LightPositionForSceneAxes $positionPhase $LightPhaseCount $LightOrbit $SceneAxisConvention
 }
 $pulseTheta = $phase * 2.0 * [Math]::PI / $LightPhaseCount
 $LightPosX += [int]$lightPosition[0]
 $LightPosY += [int]$lightPosition[1]
 $LightPosZ += [int]$lightPosition[2]
 if ($EffectiveLightPulse) {
 $pulse = (1.0 - [Math]::Cos($pulseTheta)) * 0.5
 $LightIntensityTable += [int][Math]::Round($pulse * [double]$EffectiveLightIntensity)
 } else {
 $LightIntensityTable += $EffectiveLightIntensity
 }
 }
}
$vertX = @()
$vertY = @()
$vertZ = @()
foreach ($v in $MeshVertices) {
 $vertX += [int]$v[0]
 $vertY += [int]$v[1]
 $vertZ += [int]$v[2]
}

$xCoords = @($vertX | Sort-Object -Unique)
$yCoords = @($vertY | Sort-Object -Unique)
$zCoords = @($vertZ | Sort-Object -Unique)
if ($xCoords.Count -gt 255 -or $yCoords.Count -gt 255 -or $zCoords.Count -gt 255) {
 throw "Too many unique coordinate values for byte-sized contribution tables"
}
$xIndex = @{}
$yIndex = @{}
$zIndex = @{}
for ($i = 0; $i -lt $xCoords.Count; $i++) { $xIndex[[int]$xCoords[$i]] = $i }
for ($i = 0; $i -lt $yCoords.Count; $i++) { $yIndex[[int]$yCoords[$i]] = $i }
for ($i = 0; $i -lt $zCoords.Count; $i++) { $zIndex[[int]$zCoords[$i]] = $i }
$vertXi = @()
$vertYi = @()
$vertZi = @()
foreach ($v in $MeshVertices) {
 $vertXi += [int]$xIndex[[int]$v[0]]
 $vertYi += [int]$yIndex[[int]$v[1]]
 $vertZi += [int]$zIndex[[int]$v[2]]
}
$face0Data = @()
$face1Data = @()
$face2Data = @()
$face3Data = @()
$faceVertexCountData = @()
$faceEdge0Data = @()
$faceEdge1Data = @()
$faceEdge2Data = @()
$faceEdge3Data = @()
$faceMeshIsWireData = @()
for ($faceIndex = 0; $faceIndex -lt $MeshFaces.Count; $faceIndex++) {
 $face = [int[]]$MeshFaces[$faceIndex]
 $faceArity = [int]$MeshFaceVertexCounts[$faceIndex]
 $face0Data += [int]$face[0]
 $face1Data += [int]$face[1]
 $face2Data += [int]$face[2]
 $face3Data += if ($faceArity -eq 4) { [int]$face[3] } else { 0 }
 $faceVertexCountData += $faceArity
 $faceEdge0Data += 0
 $faceEdge1Data += 0
 $faceEdge2Data += 0
 $faceEdge3Data += 0
 $faceMeshIsWireData += 0
}
foreach ($record in $MeshRecords) {
 if ([bool]$record.IsWire -and [int]$record.FaceCount -gt 0) {
 $firstFace = [int]$record.FirstFace
 $endFace = $firstFace + [int]$record.FaceCount
 for ($faceIndex = $firstFace; $faceIndex -lt $endFace; $faceIndex++) {
 $faceMeshIsWireData[$faceIndex] = 1
 }
 }
}

$polyEdgeA = @()
$polyEdgeB = @()
$polyEdgeSolidColor = @()
$wireEdgeSlot = @()
$wireEdgeOwnerFace = @()
$wireEdgeCrossMaterial = @()
$meshFirstEdge = @()
$meshEndEdge = @()
foreach ($record in $MeshRecords) {
 $edgeMap = @{}
 $meshFirstEdge += $polyEdgeA.Count
 if ([bool]$record.IsWire) {
 $firstWireEdge = [int]$record.FirstWireEdge
 $endWireEdge = $firstWireEdge + [int]$record.WireEdgeCount
 for ($wireEdgeIndex = $firstWireEdge; $wireEdgeIndex -lt $endWireEdge; $wireEdgeIndex++) {
 $edge = [int[]]$MeshWireEdges[$wireEdgeIndex]
 $lo = [Math]::Min([int]$edge[0], [int]$edge[1])
 $hi = [Math]::Max([int]$edge[0], [int]$edge[1])
 $key = "${lo}:${hi}"
 if (-not $edgeMap.ContainsKey($key)) {
 $edgeMap[$key] = $polyEdgeA.Count
 }
 $polyEdgeA += [int]$edge[0]
 $polyEdgeB += [int]$edge[1]
 $polyEdgeSolidColor += 255
 $wireEdgeSlot += 0
 $wireEdgeOwnerFace += 255
 $wireEdgeCrossMaterial += 0
 }
 if ($WireFaceEdgeFlag -ne 0 -and [int]$record.FaceCount -gt 0) {
 $firstFace = [int]$record.FirstFace
 $endFace = $firstFace + [int]$record.FaceCount
 for ($faceIndex = $firstFace; $faceIndex -lt $endFace; $faceIndex++) {
 $face = [int[]]$MeshFaces[$faceIndex]
 $faceArity = [int]$MeshFaceVertexCounts[$faceIndex]
 for ($edgeIndex = 0; $edgeIndex -lt $faceArity; $edgeIndex++) {
 $a = [int]$face[$edgeIndex]
 $b = [int]$face[($edgeIndex + 1) % $faceArity]
 $lo = [Math]::Min($a, $b)
 $hi = [Math]::Max($a, $b)
 $key = "${lo}:${hi}"
 if (-not $edgeMap.ContainsKey($key)) {
 throw "Wire mesh face edge ${key} must be declared in edges for hidden-line mode: $($record.Name)"
 }
 $edgeId = [int]$edgeMap[$key]
 $edgeColor = if ($faceIndex -lt $faceSolidColor.Count) { [int]$faceSolidColor[$faceIndex] } else { 255 }
 if ($edgeColor -ne 255) {
 $prevEdgeColor = [int]$polyEdgeSolidColor[$edgeId]
 if ($prevEdgeColor -eq 255) {
 $polyEdgeSolidColor[$edgeId] = $edgeColor
 } elseif ($prevEdgeColor -ne $edgeColor -and (($edgeId -band 1) -ne 0)) {
 $polyEdgeSolidColor[$edgeId] = $edgeColor
 }
 }
 switch ($edgeIndex) {
 0 { $faceEdge0Data[$faceIndex] = $edgeId }
 1 { $faceEdge1Data[$faceIndex] = $edgeId }
 2 { $faceEdge2Data[$faceIndex] = $edgeId }
 3 { $faceEdge3Data[$faceIndex] = $edgeId }
 }
 }
 }
 }
 } elseif ($WireFaceEdgeFlag -ne 0 -or $EngineMode1FaceEdgeListOnlyFlag -ne 0) {
 $firstFace = [int]$record.FirstFace
 $endFace = $firstFace + [int]$record.FaceCount
 for ($faceIndex = $firstFace; $faceIndex -lt $endFace; $faceIndex++) {
 $face = [int[]]$MeshFaces[$faceIndex]
 $faceArity = [int]$MeshFaceVertexCounts[$faceIndex]
 for ($edgeIndex = 0; $edgeIndex -lt $faceArity; $edgeIndex++) {
 $a = [int]$face[$edgeIndex]
 $b = [int]$face[($edgeIndex + 1) % $faceArity]
 $lo = [Math]::Min($a, $b)
 $hi = [Math]::Max($a, $b)
 $key = "${lo}:${hi}"
 if (-not $edgeMap.ContainsKey($key)) {
 $edgeMap[$key] = $polyEdgeA.Count
 $polyEdgeA += $lo
 $polyEdgeB += $hi
 $polyEdgeSolidColor += 255
 $wireEdgeSlot += $(if ($WireTwoColorMode1Flag -ne 0) { [int]$wireFaceSlot[$faceIndex] } else { 0 })
 $wireEdgeOwnerFace += $faceIndex
 $wireEdgeCrossMaterial += 0
 }
 if ($WireTwoColorMode1Flag -ne 0) {
 $edgeId = [int]$edgeMap[$key]
 $candidateSlot = [int]$wireFaceSlot[$faceIndex]
 if ([int]$wireEdgeSlot[$edgeId] -ne $candidateSlot -and [int]$wireEdgeCrossMaterial[$edgeId] -eq 0) {
 $wireEdgeCrossMaterial[$edgeId] = 1
 $WireTwoColorMode1CrossMaterialEdgeCount++
 }
 }
 if ($WireFaceEdgeFlag -ne 0) {
 $edgeId = [int]$edgeMap[$key]
 $edgeColor = if ($faceIndex -lt $faceSolidColor.Count) { [int]$faceSolidColor[$faceIndex] } else { 255 }
 if ($edgeColor -ne 255) {
 $prevEdgeColor = [int]$polyEdgeSolidColor[$edgeId]
 if ($prevEdgeColor -eq 255) {
 $polyEdgeSolidColor[$edgeId] = $edgeColor
 } elseif ($prevEdgeColor -ne $edgeColor -and (($edgeId -band 1) -ne 0)) {
 $polyEdgeSolidColor[$edgeId] = $edgeColor
 }
 }
 switch ($edgeIndex) {
 0 { $faceEdge0Data[$faceIndex] = $edgeId }
 1 { $faceEdge1Data[$faceIndex] = $edgeId }
 2 { $faceEdge2Data[$faceIndex] = $edgeId }
 3 { $faceEdge3Data[$faceIndex] = $edgeId }
 }
 }
 }
 }
 }
 $meshEndEdge += $polyEdgeA.Count
}
$PolyEdgeCount = $polyEdgeA.Count
$WireTwoColorMode1EdgeCount = if ($WireTwoColorMode1Flag -ne 0) { $PolyEdgeCount } else { 0 }
if ($WireTwoColorMode1Flag -ne 0) {
 if ($wireEdgeSlot.Count -ne $PolyEdgeCount -or $wireEdgeOwnerFace.Count -ne $PolyEdgeCount) {
 throw "Two-color wire Mode 1 edge ownership mapping is incomplete"
 }
 for ($wireEdgeIndex = 0; $wireEdgeIndex -lt $PolyEdgeCount; $wireEdgeIndex++) {
 if ([int]$wireEdgeSlot[$wireEdgeIndex] -ne 1 -and [int]$wireEdgeSlot[$wireEdgeIndex] -ne 2) {
 throw "Two-color wire Mode 1 edge $wireEdgeIndex has no deterministic slot owner"
 }
 }
}
$EmitWireEdgeListFlag = if ($Mode2MemorySpecializationFlag -ne 0) { 0 } elseif ($WireRenderFlag -ne 0 -and ($WireMeshCount -gt 0 -or $WireFaceEdgeFlag -ne 0 -or $EngineMode1FaceEdgeListOnlyFlag -ne 0)) { 1 } else { 0 }
if ($EmitWireEdgeListFlag -ne 0 -and $PolyEdgeCount -gt 255) {
 throw "GraphicsMode wire currently supports up to 255 polygon edges; generated $PolyEdgeCount"
}
$EmittedWireEdgeCount = if ($EmitWireEdgeListFlag -ne 0) { $PolyEdgeCount } else { 0 }
$WireEdgeSolidColorRequestedFlag = if ($polyEdgeSolidColor.Count -gt 0 -and -not (Test-AllByteEqual $polyEdgeSolidColor 0xff)) { 1 } else { 0 }
$WireEdgeSolidColorFlag = if ($FaceSolidColorFlag -ne 0 -and $WireFaceEdgeFlag -ne 0 -and $WireOnlyRenderFlag -ne 0 -and $WireEdgeSolidColorRequestedFlag -ne 0) { 1 } else { 0 }
if ($WireEdgeSolidColorFlag -ne 0) {
 for ($i = 0; $i -lt $polyEdgeSolidColor.Count; $i++) {
 if ([int]$polyEdgeSolidColor[$i] -eq 255) {
 $polyEdgeSolidColor[$i] = $MaterialColorByte
 }
 }
}
$WireDepthEntryCount = 0
if ($WireDepthSortFlag -ne 0) {
 foreach ($object in $SceneObjects) {
 $meshIndex = [int]$object.MeshIndex
 if ([int]$meshIsWire[$meshIndex] -ne 0) {
 $record = $MeshRecords[$meshIndex]
 $usesFaceBuckets = ($HiddenWireFlag -ne 0 -and $WireFaceEdgeFlag -ne 0 -and [int]$record.FaceCount -gt 0)
 if (-not $usesFaceBuckets) {
 $WireDepthEntryCount += ([int]$meshEndEdge[$meshIndex] - [int]$meshFirstEdge[$meshIndex])
 }
 }
 }
 if ($WireDepthEntryCount -gt 255) {
 throw "GraphicsMode wire depth sort currently supports up to 255 visible wire edge entries; generated $WireDepthEntryCount"
 }
 if ($WireDepthEntryCount -eq 0) {
 $WireDepthSortFlag = 0
 $WireObjectSortEligibleFlag = if ($WirePureFlag -ne 0 -or ($HiddenWireFlag -ne 0 -and $WireDepthSortFlag -eq 0)) { 1 } else { 0 }
 $WireObjectSortFlag = if ($WireObjectSortEligibleFlag -ne 0 -and $SceneObjectCount -gt 1 -and ($SceneObjectWireColorDiverseFlag -ne 0 -or $SceneObjectWireControlMaterialFlag -ne 0 -or $RandomMaterialCycleFlag -ne 0)) { 1 } else { 0 }
 }
}

# A Mode 2 scene containing only explicit wire edges has no face to insert in
# the hidden-surface buckets. Reuse the established direct wire dispatcher in
# that narrow case; face-bearing Mode 2 scenes retain the bucket pipeline.
$Mode2WireOnlyFallbackFlag = if ($GraphicsModeNumber -eq 2 -and $FaceCount -eq 0 -and $WireMeshCount -gt 0) { 1 } else { 0 }
if ($Mode2WireOnlyFallbackFlag -ne 0) {
 $Mode2FaceBucketPipelineFlag = 0
 $Mode2MemorySpecializationFlag = 0
 $WireDepthSortFlag = 0
 $WireDepthEntryCount = 0
 $EmitWireEdgeListFlag = 1
 $EmittedWireEdgeCount = $PolyEdgeCount
}
# The used-bucket list records a depth only when its bucket receives its first
# face. It therefore cannot require more entries than the byte-sized face set.
# Wire depth sorting also uses this list for edge buckets, so retain the legacy
# 256-byte capacity whenever that independent producer is active.
$FaceBucketUsedListSpecializationFlag = if ($WireDepthSortFlag -eq 0 -and ((($GraphicsModeNumber -eq 2) -and ($Mode2FaceBucketPipelineFlag -ne 0)) -or $GraphicsModeNumber -eq 3 -or $Mode4FamilyFlag -ne 0)) { 1 } else { 0 }
$FaceBucketUsedListCapacity = if ($FaceBucketUsedListSpecializationFlag -ne 0) { [Math]::Max(1, [Math]::Min([int]$FaceCount, 255)) } else { 256 }
if ($HighBasicV2LayoutFlag -ne 0 -and $PolyFillFlag -ne 0 -and $WireDepthSortFlag -ne 0) {
 $FpsOverlayEnableFlag = 0
 $FpsOverlayOnStartFlag = 0
 if ($FpsCounterOnlyFlag -eq 0) {
 $FpsCounterEnableFlag = 0
 }
 Update-FpsMemoryLayout $FpsOverlayEnableFlag $HighBasicV2LayoutFlag $GraphicsMode
 $FpsKeyToggleEnableFlag = $FpsOverlayEnableFlag
 $ControlLowresFlag = 0
 $LowresTraceFlag = 0
}
$EmitWireObjectSortFlag = if ($GraphicsModeNumber -eq 2 -and $Mode2FaceBucketPipelineFlag -ne 0) { 0 } else { $WireObjectSortFlag }
Assert-FpsMemoryContract $FpsOverlayEnableFlag

$RendererPlan = Resolve-RendererPlan `
 -GraphicsModeNumber $GraphicsModeNumber `
 -Quality $Quality `
 -ClearMode $ClearMode `
 -WorldGroundEnableFlag $WorldGroundEnableFlag `
 -WorldGroundHorizonOnlyFlag $WorldGroundHorizonOnlyFlag `
 -VicColorPolicyEnableFlag $VicColorPolicyEnableFlag `
 -CameraMovableFlag $CameraMovableFlag `
 -CameraWalkLiteFlag $CameraWalkLiteFlag `
 -CameraRollActiveFlag $CameraRollActiveFlag `
 -ExplorerNearClipFlag $ExplorerNearClipFlag `
 -ExplorerScreenClipPolyFlag $ExplorerScreenClipPolyFlag `
 -ExplorerScreenClipXFlag $ExplorerScreenClipXFlag `
 -PolyFillFlag $PolyFillFlag `
 -HiddenWireFlag $HiddenWireFlag `
 -StaticShadeCacheFlag $StaticShadeCacheFlag `
 -FullDynamicShadeFlag $FullDynamicShadeFlag

$asm = @'
; 3Dvibe64
; Realtime 3D bitmap engine for C64/VIC-II.
; - Multicolor bitmap, two 8 KB frame buffers.
; - 160x100 logical lowres renderer expanded to 320x200 display pixels.
; - Data-driven indexed convex face mesh.
; - Realtime Euler rotation.
; - True perspective through reciprocal z scale table.
; - One lowres material family selected from the C64 palette.
; - Material families and reflectivity are table-driven; scene objects may pin either one or follow the active keyboard values.

* = $0801
 .byte $0b,$08,$0a,$00,$9e
 .text "2061"
 .byte 0,0,0

* = $080d

angx = $02
angy = $03
angz = $04
sinxv = $05
cosxv = $06
sinyv = $07
cosyv = $08
sinzv = $09
coszv = $0a
drawbuf = $0b
mode4_current_face_id = $0c
faceidx = $0d
t1 = $0e
t2 = $0f
vx0 = $10
vy0 = $11
vx1 = $12
vy1 = $13
vx2 = $14
vy2 = $15
ex0 = $16
ey0 = $17
ex1 = $18
ey1 = $19
dxabs = $1a
dyval = $1b
sxstep = $1c
ycur = $1d
xcur = $1e
errlo = $1f
errhi = $20
ptr0lo = $21
ptr0hi = $22
ptr1lo = $23
ptr1hi = $24
row0lo = $25
row0hi = $26
row1lo = $27
row1hi = $28
leftval = $29
rightval = $2a
startbyte = $2b
endbyte = $2c
maskv = $2d
multmp = $2e
yrow = $2f
mula = $30
mulb = $31
mulsign = $32
prodlo = $33
prodhi = $34
rx0 = $35
ry0 = $36
rz0 = $37
rx1 = $38
ry1 = $39
rz1 = $3a
scalev = $3b
fullcount = $3c
dx1v = $3d
dy1v = $3e
dx2v = $3f
dy2v = $40
p1lo = $41
p1hi = $42
crosslo = $43
crosshi = $44
dirty_ymin_a = $45
dirty_ymax_a = $46
dirty_ymin_b = $47
dirty_ymax_b = $48
maxrow = $49
shadeidx = $4a
fillbyte = $4b
face_ymin = $4c
face_ymax = $4d
bucket_min = $4e
bucket_max = $4f
sorti = $50
sortj = $51
tmpidx = $52
vx3 = $53
vy3 = $54
pattoggle = $55
m00 = $56
m01 = $57
m02 = $58
m10 = $59
m11 = $5a
m12 = $5b
m20 = $5c
m21 = $5d
m22 = $5e
spanw = $5f
spanh = $60
active_vfirst = $61
active_vend = $62
active_face_first = $63
active_face_end = $64
meshidx = $65
space_latch = $66
auto_cycle_counter = $67
active_material = $69
light_phase = $6a
light_tick = $6b
shadeptrlo = $6c
shadeptrhi = $6d
material_latch = $6e
sh_nx = $6f
sh_ny = $70
sh_nz = $71
light_intensity = $72
active_reflect_offset = $73
reflect_latch = $74
sh_lx = $75
motion_z_frac = $76
motion_z_lo = $77
dotlo = $78
dothi = $79
motion_z_hi = $7a
objidx = $7b
obj_pos_x_cur = $7c
obj_pos_y_cur = $7d
obj_depth_lo = $7e
obj_scale_cur = $7f
obj_depth_hi = $80
obj_depth_frac = $81
explorer_z_world_hi = $82
explorer_z_hi16 = $83
mul16lo = $84
mul16hi = $85
mul16mul = $86
mul16abs = $87
mul16rem = $88
mul16reslo = $89
mul16reshi = $8a
mul16sign = $8b
loaded_face_vertex_count = $8c
clip_in_x = $8d
clip_in_y = $8e
clip_out_y = $8f
clip_num = $90
clip_den = $91
clip_second_pending = $92
clip_second_count = $93
clip2_vx0 = $94
clip2_vy0 = $95
clip2_vx1 = $96
clip2_vy1 = $97
clip2_vx2 = $98
clip2_vy2 = $99
clip2_vx3 = $9a
clip2_vy3 = $9b
clip_poly_active = $9c
clip_a_count = $9d
clip_b_count = $9e
clip_prev_idx = $9f
clip_cur_idx = $a0
clip_prev_inside = $a1
clip_cur_inside = $a2
clip_out_x = $a3
object_traverse_active = $a4
near_face_crossing = $a5
FACE_COUNT = $0c
FACE_BUCKET_USED_LIST_CAPACITY = $0100
VERT_COUNT = $08
SOURCE_FACE_COUNT = $fd
SOURCE_VERT_COUNT = $fe
MEMORY_LAYOUT_HIGH_BASIC_V2 = $00
BITMAP_B_BASE = $a000
SCREEN_B_BASE = $8c00
RUNTIME_BUFFER_LIMIT = $8c00
; high-basic-v2 memory contract used by the mixed solid/wire path.
; $4e30-$5bff is free between the middle code and bitmap A; $8000-$9fff is
; runtime-only; high code starts at $a000 and may grow only up to I/O at $d000.
HIGH_BASIC_V2_STATIC_LOW_BASE = $4e30
HIGH_BASIC_V2_STATIC_LOW_LIMIT = $5c00
HIGH_BASIC_V2_RUNTIME_BASE = $8000
HIGH_BASIC_V2_RUNTIME_LIMIT = $a000
HIGH_BASIC_V2_CODE_HIGH_BASE = $a000
HIGH_BASIC_V2_IO_BASE = $d000
HIGH_BASIC_V2_RELOCATED_CODE_BASE = $9000
VIC_BANK_B_BITS = $01
VIC_D018_B = $38
MESH_COUNT = $01
SCENE_OBJECT_COUNT = $00
OBJECT_MODEL_CONTRACT_VERSION = $01
WORLD_SPACE_Z_UP = $00
OBJECT_SPACE_ALIGNED_WORLD = $00
SCENE_WORLD_OBJECT_PRESENT = $01
SCENE_CAMERA_OBJECT_PRESENT = $01
SCENE_LIGHT_OBJECT_COUNT = $00
SCENE_PRIMARY_LIGHT_INDEX = $ff
SCENE_EXTRA_LIGHT_IGNORED_COUNT = $00
SCENE_MESH_OBJECT_COUNT = $00
MESH_INSTANCE_EXPANSION_MODE = $00
MESH_SOURCE_SHARING_RUNTIME = $00
MESH_OBJECT_KIND_MESH = $01
MESH_GEOMETRY_SOLID = $00
MESH_GEOMETRY_WIRE = $01
MESH_WIRE_IS_SPECIALIZED_MESH = $01
MESH_MATERIAL_SINGLE = $00
MESH_MATERIAL_MULTIMATERIAL = $01
MESH_MULTIMATERIAL_IS_SOLID_MESH = $01
SCENE_SOLID_MESH_OBJECT_COUNT = $00
SCENE_WIRE_MESH_OBJECT_COUNT = $00
SCENE_SINGLE_MATERIAL_MESH_OBJECT_COUNT = $00
SCENE_MULTIMATERIAL_MESH_OBJECT_COUNT = $00
SCENE_FACE_MATERIAL_TABLE_ACTIVE = $00
SCENE_FACE_SOLID_COLOR_TABLE_REQUESTED = $00
SCENE_POS_ACTIVE = $00
SCENE_VEL_X_ACTIVE = $00
SCENE_VEL_Y_ACTIVE = $00
SCENE_VEL_Z_ACTIVE = $00
SCENE_ROT_ACTIVE = $00
SCENE_ANG_X_ACTIVE = $00
SCENE_ANG_Y_ACTIVE = $00
SCENE_ANG_Z_ACTIVE = $00
SCENE_OBJECT_X_ACTIVE = $00
SCENE_OBJECT_Y_ACTIVE = $00
SCENE_OBJECT_SCALE_ACTIVE = $00
SCENE_OBJECT_VISIBILITY_ACTIVE = $00
SCENE_INSTANCE_OVERRIDES = $00
SCENE_INSTANCE_COLOR_OVERRIDE = $00
SCENE_FACE_MATERIAL_OVERRIDE = $00
SCENE_INSTANCE_MATERIAL_ALL_PINNED = $00
SCENE_INSTANCE_REFLECT_ALL_PINNED = $00
SCENE_TIMELINE_ENABLE = $00
SCENE_TIMELINE_STATE_COUNT = $00
SCENE_TIMELINE_INITIAL_STATE = $00
SCENE_GRAPHIC_INCLUDE_ENABLE = $00
SCENE_RESPAWN_ACTIVE = $00
SCENE_OSC_X_ACTIVE = $00
; === Projection Contract ===
; PROJECTION_CONTRACT_ACTIVE=1
; PROJECTION_CONTRACT_FOCAL=170
; PROJECTION_CONTRACT_CENTER_X=80
; PROJECTION_CONTRACT_CENTER_Y=50
; PROJECTION_CONTRACT_SCREEN_MAX_X=159
; PROJECTION_CONTRACT_SCREEN_MAX_Y=99
; PROJECTION_CONTRACT_VIEW_DEPTH_BIAS=190
; PROJ_VIEW_DEPTH_BIAS is a projection-index origin only.  Camera geometry,
; near clipping, culling, sorting, and depth buckets must never include it.
; WalkPerspectiveAlignedToSimpleCamera=1
; WalkYawPivotPreserved=1
; Projection Contract placeholder

PROJ_MODE_EXTENDED_TABLE = $01
PROJ_FOCAL = $aa
PROJ_CENTER_X = $50
PROJ_CENTER_Y = $32
PROJ_SCREEN_MIN_X = $00
PROJ_SCREEN_MAX_X = $9f
PROJ_SCREEN_MIN_Y = $00
PROJ_SCREEN_MAX_Y = $63
PROJ_NEAR_MIN_DEPTH = $20
PROJ_CAMERA_FACE_MIN_DEPTH = $08
CAMERA_PLANE_CLIP_PROFILE = $00
CAMERA_SPACE_FACE_CULL_SUPPORT = $00
STABLE_FACE_CULL_PROFILE = $00
PROJ_VIEW_DEPTH_BIAS = $be
PROJ_VIEW_DEPTH_BIAS_HI = $00
PROJ_FAR_DEPTH_CLAMP = $21
PROJ_FRUSTUM_X_NEAR = $28
PROJ_FRUSTUM_Y_NEAR = $19
PROJ_FRUSTUM_FOCAL = $55
PROJ_CENTER_X_HALF = $28
PROJECTION_CONTRACT_ACTIVE = $01

; === Mode 4 Y-Q2 Viewport Contract ===
YQ2_VIEWPORT_CENTER_LO = $a0
YQ2_VIEWPORT_CENTER_HI = $00
; Native fixed projection yields 256+offset before it is centred.
YQ2_VIEWPORT_NATIVE_BASE_HI = $01
YQ2_VIEWPORT_MAX_LO = $3c
YQ2_VIEWPORT_MAX_HI = $01
YQ2_VIEWPORT_ROW_MAX = $4f
YQ2_VIEWPORT_ROW_COUNT = $50
YQ2_VIEWPORT_CENTER_PLUS_ONE = $a1
YQ2_VIEWPORT_BELOW_CENTER_LIMIT_PLUS_ONE = $9d

; === Engine Camera Viewport Contract ===
ENGINE_CAMERA_VIEWPORT_CONFIGURABLE = $00
ENGINE_CAMERA_VIEWPORT_ALL_MODES = $00
ENGINE_CAMERA_VIEWPORT_SMALL = $00
ENGINE_CAMERA_VIEWPORT_PROFILE_ID = $00
ENGINE_CAMERA_VIEWPORT_PROJECTION_SCALED = $00
ENGINE_CAMERA_VIEWPORT_CLEAR_LIMITED = $00
ENGINE_CAMERA_VIEWPORT_GROUND_LIMITED = $00
CAMERA_VIEWPORT_WIDTH = $a0
CAMERA_VIEWPORT_HEIGHT = $64
CAMERA_VIEWPORT_ORIGIN_X = $00
CAMERA_VIEWPORT_ORIGIN_Y = $00
CAMERA_VIEWPORT_CELL_ORIGIN_X = $00
CAMERA_VIEWPORT_CELL_WIDTH = $28
CAMERA_VIEWPORT_BITMAP_X_OFFSET = $00

; === 3Dvibe64 Renderer Contract ===
RENDERER_ACTIVE = $01
RENDERER_PLAN_ACTIVE = $00
RENDERER_PLAN_APPLIED = $00
GROUND_RENDER_MODE_NONE = $00
GROUND_RENDER_MODE_SIMPLE = $01
GROUND_RENDER_MODE_FULL = $02
GROUND_RENDER_MODE_HORIZON = $03
GROUND_RENDER_MODE = $02
GROUND_SIMPLE_PREFILL = $00
GROUND_HORIZON_ONLY = $00
GROUND_FULL_PLANE = $01
GROUND_OCCLUSION_ENABLE = $00
GROUND_WIRE_OCCLUSION_ENABLE = $00
GROUND_ROLL_PLANE_ENABLE = $00
FRAME_WORLD_PREFILL_ENABLE = $00
VIC_COLOR_POLICY_RUNTIME_ENABLE = $00
ENGINE_VIC_STATIC_POLICY = $00
ENGINE_CAMERA_LIMITS_ENABLE = $00
CAMERA_FULL_ENABLE = $01
ENGINE_CAMERA_PROFILE_RUNTIME_ACTIVE = $00
ENGINE_CAMERA_WALK_LITE_RUNTIME_ACTIVE = $00
ENGINE_CAMERA_MODE_CYCLE_RUNTIME_ACTIVE = $00
ENGINE_CAMERA_ROLL_RUNTIME_ACTIVE = $00
ENGINE_CAMERA_PITCH_ROLL_LOCK_ACTIVE = $00
ENGINE_CAMERA_WALK_LITE_PITCH_RUNTIME_ACTIVE = $00
ENGINE_CAMERA_WALK_LITE_PITCH_ALL_MODES = $00
ENGINE_CAMERA_WALK_LITE_YAW_PITCH_ONLY = $00
ENGINE_CAMERA_WALK_LITE_PITCH_ZERO_FASTPATH = $00
ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH = $00
ENGINE_CAMERA_FOLDED_PITCH_ZERO_FASTPATH = $00
ENGINE_CAMERA_ROLL_LOCK_ACTIVE = $00
CAMERA_FULL_RUNTIME_ACTIVE = $00
ENGINE_MODE_BUDGET_ENABLE = $00
ENGINE_FULL_RENDER_ENABLE = $01
DEPTH_BUCKETS_ENABLE = $00
FACE_FILL_CACHE_ENABLE = $00
DYNAMIC_SHADE_LEVEL = $00
RENDER_FRAME_SCAFFOLD_ACTIVE = $00
RENDER_FRAME_BEGIN_ACTIVE = $00
RENDER_WORLD_BACKGROUND_ACTIVE = $00
RENDER_SCENE_PIPELINE_ACTIVE = $00
RENDER_FRAME_END_ACTIVE = $00
ENGINE_GROUND_SIMPLE_RUNTIME_ACTIVE = $00
ENGINE_GROUND_HORIZON_ONLY_RUNTIME_ACTIVE = $00
ENGINE_MODE3_FRAME_PREFILL_RUNTIME_ACTIVE = $00
ENGINE_MODE3_CLEAR_GROUND_FUSED = $00
ENGINE_MODE3_GROUND_CELLROW_WRITE_ON_CHANGE = $00
ENGINE_MODE3_PREFILL_FALLBACK = $00
ENGINE_MODE3_FACE_PREPARE_ONCE = $00
ENGINE_MODE3_PREPARED_FACE_STATE_CACHE = $00
ENGINE_MODE3_UNCLIPPED_FACE_FASTLOAD = $00
ENGINE_MODE3_CLIP_FALLBACK = $00
ENGINE_MODE3_DRAW_RECHECK_STRIPPED = $00
ENGINE_MODE3_DIRECT_CONVEX_FILL = $00
ENGINE_MODE3_DIRECT_CONVEX_PREPARED_ONLY = $00
ENGINE_MODE3_DIRECT_CONVEX_CLIP_FALLBACK = $00
ENGINE_MODE3_DIRECT_CONVEX_TRI_QUAD = $00
ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL = $00
ENGINE_MODE3_NATIVE_CONVEX_QUAD_PREPARED_ONLY = $00
ENGINE_MODE3_NATIVE_CONVEX_QUAD_SINGLE_SPAN = $00
ENGINE_MODE3_NATIVE_CONVEX_QUAD_FAN_FALLBACK = $00
ENGINE_MODE3_NATIVE_CONVEX_QUAD_TRIANGLES_UNCHANGED = $00
ENGINE_MODE3_FAST_BOUNDS_TRACE = $00
ENGINE_MODE3_FAST_BOUNDS_8BIT = $00
ENGINE_MODE3_FAST_BOUNDS_DIRECT_LEFT_RIGHT = $00
ENGINE_MODE3_FAST_BOUNDS_OVERFLOW_FALLBACK = $00
ENGINE_MODE4_FAST_BOUNDS_TRACE = $00
ENGINE_MODE4_FAST_BOUNDS_8BIT = $00
ENGINE_MODE4_FAST_BOUNDS_DIRECT_LEFT_RIGHT = $00
ENGINE_MODE4_FAST_BOUNDS_OVERFLOW_FALLBACK = $00
ENGINE_MODE3_SPAN_HOTLOOP = $00
ENGINE_MODE3_DIRECT_INDEXED_SPANS = $00
ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS = $00
ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE = $00
ENGINE_MODE3_MATERIAL_CELL_TRANSITION = $00
ENGINE_MODE3_FRAME_PREFILL_COMPATIBLE = $00
ENGINE_MODE3_CONSOLIDATION = $00
MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE = $00
ENGINE_MODE3_CONSOLIDATION_CHECK = $00
ENGINE_MODE3_UNIVERSAL_PATHS_ONLY = $00
ENGINE_MODE3_COMPACT_FACE_QUEUE = $00
ENGINE_MODE3_NORMAL_VIEWPORT_SUPPORTED = $00
ENGINE_MODE3_SMALL_VIEWPORT_SUPPORTED = $00
ENGINE_MODE3_MULTI_OBJECT_SUPPORTED = $00
ENGINE_MODE3_FALLBACKS_PRESERVED = $00
ENGINE_MODE3_STABLE_GROUND_CELL_LAYOUT = $00
ENGINE_MODE3_STABLE_GROUND_AUTO = $00
ENGINE_MODE3_STABLE_GROUND_MULTI_OBJECT = $00
ENGINE_MODE3_STABLE_GROUND_SHARED_RAMP = $00
ENGINE_MODE3_STABLE_GROUND_SLOT_01 = $00
ENGINE_MODE3_STABLE_GROUND_OBJECT_SLOT_10 = $00
ENGINE_MODE3_STABLE_GROUND_OBJECT_SLOT_11 = $00
ENGINE_MODE3_STABLE_GROUND_COLORRAM_WRITE_STRIPPED = $00
ENGINE_MODE3_STABLE_GROUND_DOUBLE_BUFFER_SAFE = $00
ENGINE_MODE3_ADAPTIVE_CELL_POLICY = $00
ENGINE_MODE3_ADAPTIVE_SHARED_RAMP_EXACT = $00
ENGINE_MODE3_ADAPTIVE_SCREEN_PAIR_LAYOUT = $00
ENGINE_MODE3_ADAPTIVE_MULTI_RAMP = $00
ENGINE_MODE3_ADAPTIVE_GROUND_SLOT_11 = $00
ENGINE_MODE3_ADAPTIVE_OBJECT_SLOTS_01_10 = $00
ENGINE_MODE3_ADAPTIVE_COLORRAM_FIXED_GROUND = $00
ENGINE_MODE3_ADAPTIVE_HIGHLIGHT_FOLD_HIGH = $00
ENGINE_MODE3_ADAPTIVE_FACE_SOLID_COLOR = $00
ENGINE_MODE3_ADAPTIVE_DOUBLE_BUFFER_SAFE = $00
ENGINE_MODE3_ADAPTIVE_RUNTIME_MATERIAL_SAFE = $00
ENGINE_MODE3_ADAPTIVE_USER_CELL_CONFLICT = $00
ENGINE_MODE3_DEMO_CELL_COLOR_STABILITY = $00
ENGINE_MODE3_DEMO_THREE_COLOR_LAYOUT = $00
ENGINE_MODE3_DEMO_GROUND_SLOT_01_PRESERVED = $00
ENGINE_MODE3_DEMO_OBJECT_SLOT_10 = $00
ENGINE_MODE3_DEMO_OBJECT_SLOT_11 = $00
ENGINE_MODE3_DEMO_STATIC_SHADING_RESTORED = $00
ENGINE_MODE3_DEMO_NO_FACE_SOLID_OVERRIDE = $00
ENGINE_MODE3_DEMO_SHADE_FAMILY_REENCODED = $00
ENGINE_MODE3_DEMO_VIC_POLICY_OFF = $00
ENGINE_MODE3_DEMO_GROUND_BITMAP_SLOT_01 = $00
ENGINE_MODE3_DEMO_GROUND_COLORRAM_WRITE_STRIPPED = $00
ENGINE_MODE3_DEMO_DOUBLE_BUFFER_COLOR_STABLE = $00
GROUND_FULL_RUNTIME_ACTIVE = $00
VIC_BITMAP_MULTICOLOR_ENABLE = $01
VIC_BITMAP_SINGLE_PIXEL_ENABLE = $00
ENGINE_GRAPHICS_MODE = $00
ENGINE_RENDER_STYLE_WIRE = $00
ENGINE_RENDER_STYLE_HIDDEN_WIRE = $00
ENGINE_WIRE_MODE_RUNTIME_ACTIVE = $00
ENGINE_WIRE_SPEED_PASS_1 = $00
ENGINE_WIRE_SPEED_PASS_2 = $00
ENGINE_WIRE_SPEED_PASS_3 = $00
ENGINE_WIRE_DIRTY_CLEAR_ENABLE = $00
ENGINE_WIRE_HORIZON_DIRECT_DRAW = $00
ENGINE_WIRE_SOLID_FEATURES_STRIPPED = $00
ENGINE_MODE2_MASK_DIRTY_TRACK_ENABLE = $00
ENGINE_WIRE_CELL_WRITE_SKIP_SAME = $00
ENGINE_WIRE_MATERIAL_CACHE_RESET_FRAME = $00
ENGINE_MODE2_MASK_COLOR_WRITES_STRIPPED = $00
ENGINE_WIRE_LIGHT_SHADING_STRIPPED = $00
ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = $00
ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE = $00
ENGINE_WIRE_MATERIAL_COMPARE_STRIPPED = $00
ENGINE_MODE1_FACE_PASS_STRIPPED = $00
ENGINE_MODE1_EDGE_TABLE_DIRECT = $00
MODE1_OBJECT_DEPTH_SORT = $00
MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = $00
MODE2_FACE_BUCKET_PIPELINE = $00
ENGINE_MODE1_WIRE_FAST_PLOT = $00
ENGINE_MODE1_WIRE_INSCREEN_FASTPATH = $00
ENGINE_MODE1_WIRE_CLIP_FALLBACK = $00
ENGINE_MODE1_UNIVERSAL_EDGE_TRAVERSAL = $00
ENGINE_MODE1_PROJDONE_DIRECT_TEST = $00
ENGINE_MODE1_VERTEX_DRAWABLE_FALLBACK = $00
ENGINE_MODE1_WIRE_RASTER_HOTLOOP = $00
ENGINE_MODE1_WIRE_POINT_BOUNDS_STRIPPED = $00
ENGINE_MODE1_WIRE_POINT_DIRECT_ENTRY = $00
ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE = $00
ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE = $00
ENGINE_MODE2_WIRE_RASTER_HOTLOOP = $00
ENGINE_MODE2_WIRE_POINT_BOUNDS_STRIPPED = $00
ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE = $00
ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE = $00
ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW = $00
ENGINE_MODE2_WIRE_CLIP_GUARD_FALLBACK = $00
ENGINE_WIRE_SCANLINE_RUN_RASTERIZER = $00
ENGINE_WIRE_SCANLINE_RUN_SHALLOW_ONLY = $00
ENGINE_WIRE_SCANLINE_RUN_POINT_FALLBACK = $00
ENGINE_WIRE_SCANLINE_RUN_ENDPOINT_STATE_PRESERVED = $00
ENGINE_MODE1_SCANLINE_RUN_RUNTIME_ACTIVE = $00
ENGINE_MODE2_SCANLINE_RUN_RUNTIME_ACTIVE = $00
ENGINE_WIRE_STEEP_LINE_FASTPATH = $00
ENGINE_WIRE_STEEP_RATIO_2_TO_1 = $00
ENGINE_WIRE_VERTICAL_RUN_WRITER = $00
ENGINE_WIRE_STEEP_POINT_FALLBACK = $00
ENGINE_WIRE_STEEP_ENDPOINT_STATE_PRESERVED = $00
ENGINE_MODE1_STEEP_LINE_RUNTIME_ACTIVE = $00
ENGINE_MODE2_STEEP_LINE_RUNTIME_ACTIVE = $00
ENGINE_WIRE_CELL_TRANSITION_UPDATES = $00
ENGINE_WIRE_DIRTY_SAME_BYTE_SKIP = $00
ENGINE_WIRE_MATERIAL_CALL_ON_CELL_CHANGE = $00
ENGINE_WIRE_MATERIAL_DIRECT_WRITE_ENTRY = $00
ENGINE_WIRE_TRANSITION_CACHE_RESET_FRAME = $00
ENGINE_MODE1_CELL_TRANSITION_RUNTIME_ACTIVE = $00
ENGINE_MODE2_CELL_TRANSITION_RUNTIME_ACTIVE = $00
ENGINE_WIRE_8BIT_BRESENHAM = $00
ENGINE_WIRE_8BIT_INTERMEDIATE_SLOPES = $00
ENGINE_WIRE_8BIT_ERROR_ACCUMULATOR = $00
ENGINE_WIRE_16BIT_TRACE_FALLBACK = $00
ENGINE_MODE1_8BIT_BRESENHAM_RUNTIME_ACTIVE = $00
ENGINE_MODE2_8BIT_BRESENHAM_RUNTIME_ACTIVE = $00
ENGINE_WIRE_RASTER_CONSOLIDATION = $00
ENGINE_WIRE_SINGLE_SLOPE_DISPATCH = $00
ENGINE_WIRE_SINGLE_TRACE_GATE = $00
ENGINE_WIRE_TRACE_FALLBACK = $00
ENGINE_MODE1_RASTER_CONSOLIDATION_RUNTIME_ACTIVE = $00
ENGINE_MODE2_RASTER_CONSOLIDATION_RUNTIME_ACTIVE = $00
ENGINE_MODE2_HORIZON_ROW_MASK_CANDIDATE = $00
ENGINE_MODE2_HORIZON_ROW_MASK_RUNTIME_ACTIVE = $00
ENGINE_WIRE_HORIZON_ONLY_RUNTIME_ACTIVE = $00
ENGINE_WIRE_VIC_POLICY_FORCED_OFF = $00
VIC_COLOR_POLICY_REQUESTED_ENABLE = $00
VIC_COLOR_POLICY_REQUESTED_ACTIVE = $00
VIC_COLOR_POLICY_EFFECTIVE_ENABLE = $00
VIC_COLOR_POLICY_EFFECTIVE_ACTIVE = $00
WIRE_MATERIAL_COLOR_ENABLE = $00
WIRE_OBJECT_MATERIAL_PATH_ENABLE = $00
ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE = $00
ENGINE_GROUND_HORIZON_MATERIAL_ISOLATED = $00
ENGINE_GROUND_HORIZON_MATERIAL_RESTORE = $00
ENGINE_MESH_WIRE_MATERIAL_RELOAD_AFTER_GROUND = $00
ENGINE_WIRE_CAMERA_THROUGH_MESH_ENABLE = $00
ENGINE_WIRE_NEAR_CLIP_RELAXED = $00
ENGINE_WIRE_OBJECT_REJECT_RELAXED = $00
ENGINE_WIRE_EDGE_CLIP_TOLERANT = $00
ENGINE_MODE2_FACE_MASK_NEAR_TOLERANT = $00
GROUND_HORIZON_DARK_GREY_ENABLE = $00
ENGINE_GROUND_HORIZON_SCREEN_BYTE = $bb
ENGINE_GROUND_HORIZON_COLOR_RAM = $0b
ENGINE_GROUND_HORIZON_COLOR = $0b
GROUND_RUNTIME_OCCLUSION_ENABLE = $00
GROUND_RUNTIME_WIRE_OCCLUSION_ENABLE = $00
GROUND_RUNTIME_ROLL_PLANE_ENABLE = $00
ENGINE_MODE1_WIRE_PURE_RUNTIME_ACTIVE = $00
ENGINE_MODE1_WIRE_RENDER_RUNTIME_ACTIVE = $00
ENGINE_MODE1_WIRE_FACE_EDGE_RUNTIME_ACTIVE = $00
ENGINE_MODE1_HIDDEN_WIRE_RUNTIME_ACTIVE = $00
ENGINE_MODE1_POLY_FILL_RUNTIME_ACTIVE = $00
ENGINE_MODE1_WIRE_DEPTH_SORT_RUNTIME_ACTIVE = $00
ENGINE_MODE1_WIRE_OBJECT_SORT_RUNTIME_ACTIVE = $00
ENGINE_MODE1_VIC_POLICY_RUNTIME_ACTIVE = $00
ENGINE_MODE1_GROUND_OCCLUSION_RUNTIME_ACTIVE = $00
ENGINE_MODE2_HIDDEN_WIRE_RUNTIME_ACTIVE = $00
ENGINE_MODE2_WIRE_RENDER_RUNTIME_ACTIVE = $00
ENGINE_MODE2_POLY_FILL_RUNTIME_ACTIVE = $00
ENGINE_MODE2_VIC_POLICY_RUNTIME_ACTIVE = $00
ENGINE_MODE2_FACE_MASK_CONTRACT_ENABLE = $00
ENGINE_MODE2_FACE_MASK_RUNTIME_ACTIVE = $00
ENGINE_MODE2_HORIZON_BEHIND_FACE_TARGET = $00
ENGINE_MODE2_HORIZON_BEHIND_FACE_RUNTIME_ACTIVE = $00

; Historical aliases
EXPLORER_PROJ_FOCAL = PROJ_FOCAL
CAMERA_FACE_MIN_DEPTH = PROJ_CAMERA_FACE_MIN_DEPTH
FACE_REFLECTIVITY_ACTIVE_ONLY = $00
FACE_MATERIAL_ACTIVE_ONLY = $00
FACE_SOLID_COLOR_ENABLE = $00
VIC_COLOR_POLICY_ENABLE = $00
VIC_COLOR_POLICY_ACTIVE = $00
VIC_COLOR_POLICY_OVERLAY = $00
VIC_COLOR_FALLBACK_MODE = $00
MATERIAL_CELL_SPAN_CACHE = $00
LAZY_CONVEX_BOUNDS = $00
DIRECT_CONVEX_EDGE_SPANS = $00
SPAN_KERNEL_FILL = $00
INDEXED_OFFSET_SPAN_FILL = $00
DIRECT_CONVEX_FAN_FILL = $00
GRAPHICS_MODE = $04
RUNTIME_GRAPHICS_MODE_SWITCH = $00
WIRE_MESH_COUNT = $00
WIRE_EDGE_COUNT = $00
WIRE_DEPTH_ENTRY_COUNT = $00
WIRE_RENDER_ENABLE = $00
WIRE_OVERLAY_ENABLE = $00
WIRE_DEPTH_SORT_ENABLE = $00
WIRE_OBJECT_SORT_ENABLE = $00
WIRE_DEPTH_NEAR_BIAS = $01
WIRE_OBJECT_MATERIAL_ENABLE = $00
HIDDEN_WIRE_ENABLE = $00
HIDDEN_WIRE_DEPTH_BIAS = $30
WIRE_FACE_EDGE_ENABLE = $00
WIRE_EDGE_SOLID_COLOR_ENABLE = $00
WIRE_TWO_COLOR_MULTIMATERIAL_ENABLE = $00
WIRE_TWO_COLOR_MODE1_ENABLE = $00
WIRE_TWO_COLOR_MODE2_ENABLE = $00
WIRE_TWO_COLOR_SLOT_01_COLOR = $00
WIRE_TWO_COLOR_SLOT_10_COLOR = $00
WIRE_TWO_COLOR_SCREEN_BYTE = $00
WIRE_TWO_COLOR_FIXED_COLOR_RAM = $00
POLY_FILL_ENABLE = $01
FAST_FILL_BOUNDS_TRACE = $00
FACE_RENDER_ENABLE = $01
WIRE_PURE_ENABLE = $00
STATIC_SHADE_CACHE = $00
FULL_DYNAMIC_SHADE = $01
MODE4_DYNAMIC_SHADE_THRESHOLD_FIX = $00
STATIC_SHADE_DIRECT = $00
FRAME_FACE_FILL_CACHE = $00
MODE4_OBJECT_LIGHT_CACHE = $00
MODE4_UNCACHED_LIGHT_FALLBACK = $00
HAS_TRI_FACES = $00
FORCE_FACE_RENDER = $00
CONSERVATIVE_FACE_CULL = $00
STABLE_FACE_CULL_SCREEN_AREA_BAND = $40
STABLE_FACE_CULL_EDGE_EPSILON = $01
CONSERVATIVE_SLIVER_CULL = $00
CONSERVATIVE_CULL_NEG_AREA = $20
CONSERVATIVE_EDGE_CULL_NEG_AREA = $60
CONSERVATIVE_SLIVER_THIN_SPAN = $03
CONSERVATIVE_SLIVER_LONG_SPAN = $06
STANDARD_PROJECT_VERTEX = $00
FACE_CULL_PREP = $00
REFERENCE_PROJECTION = $00
EXTENDED_TABLE_PROJECTION = $00
EXPLORER_TABLE_PROJECTION = $00
AUTO_CYCLE_FRAMES = $00
RANDOM_MATERIAL_CYCLE = $00
RANDOM_MATERIAL_CYCLE_TICKS = $64
MOTION_Z_START_FRAC = $00
MOTION_Z_START_LO = $00
MOTION_Z_START_HI = $00
MOTION_Z_STEP_FRAC = $00
MOTION_Z_STEP_LO = $00
MOTION_Z_STEP_HI = $00
MOTION_Z_START_ON_RETURN = $00
MOTION_Z_START_ON_ZERO = $00
ANGLE_X_STEP_LO = $2b
ANGLE_X_STEP_HI = $00
ANGLE_Y_STEP_LO = $40
ANGLE_Y_STEP_HI = $00
ANGLE_Z_STEP_LO = $15
ANGLE_Z_STEP_HI = $00
MIN_FACE_AREA = $04
SCENE_RENDER_MIN_Y = $00
VIDEO_STANDARD_AUTO = $00
VIDEO_STANDARD_FORCE_PAL = $00
VIDEO_STANDARD_FORCE_NTSC = $00
VIDEO_STANDARD_RUNTIME_DETECT = $00
VIDEO_PAL_VBLANKS_PER_SECOND = $32
VIDEO_NTSC_VBLANKS_PER_SECOND = $3c
SIMULATION_REFERENCE_HZ = $32
NTSC_SIM_TICKS_PER_6_VBLANKS = $05
VIDEO_STANDARD_INITIAL = $00
VIDEO_VBLANKS_PER_SECOND_INITIAL = $32
FPS_OVERLAY_ENABLE = $00
FPS_OVERLAY_ON_START = $00
FPS_COUNTER_ENABLE = $00
FPS_COUNTER_ONLY = $00
FPS_OVERLAY_MEMORY_CONTRACT = $00
FPS_OVERLAY_UNDER_IO_LAYOUT = $00
FPS_KEY_TOGGLE_ENABLE = $00
CONTROL_SPACE_KEY = $00
CONTROL_RETURN_KEY = $00
CONTROL_ROTATION_KEY = $00
CONTROL_LIGHT_KEY = $00
CONTROL_LOWRES_KEY = $00
CONTROL_ZERO_MOTION_KEY = $00
LOWRES_TRACE_ENABLE = $00
CONTROL_MATERIAL_KEYS = $00
CONTROL_REFLECTIVITY_KEYS = $00
XCOORD_COUNT = $01
YCOORD_COUNT = $01
ZCOORD_COUNT = $01
SCREEN_MIN_SPAN = $02
FAR_SCREEN_MIN_SPAN = $00
PATTERN_MIN_SPAN = $00
SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y = $00
MODE4_PATTERN_PROBE = $00
MODE4_PATTERN_PROBE_LATCHED_FACE = $00
MODE4_VALID_SHADE_FACE_PROBE = $00
MODE4_SHADE_STEP_LIMIT = $00
MODE5_POLYGON_OUTLINE = $00
YQ2_FAST_DIV11X8 = $00
YQ2_FAST_PIXEL_CONVERT = $00
YQ2_INLINE_BOUNDS = $00
MODE4_FACE_ID_LATCH = $00
FULL_CLEAR = $00
TRACK_DIRTY_SPANS = $01
DYNAMIC_LIGHT = $00
STATIC_RUNTIME_LIGHT = $00
STATIC_POSE = $00
INITIAL_ANGLE_X = $18
INITIAL_ANGLE_Y = $19
INITIAL_ANGLE_Z = $2F
LIGHT_PHASE_COUNT = $10
LIGHT_PHASE_MASK = $0f
LIGHT_TICK_DIV = $04
LIGHT_INTENSITY_MAX = $0a
LIGHT_PULSE_ON_SPACE = $00
MATERIAL_DEFAULT_INDEX = $00
MATERIAL_REFLECTIVITY = $00
MATERIAL_REFLECTIVITY_OFFSET = $00
MATERIAL_SCREEN_BYTE = $bc
MATERIAL_COLOR_RAM = $01
WORLD_BACKGROUND_COLOR = $00
WORLD_GROUND_ENABLE = $00
WORLD_GROUND_COLOR = $05
WORLD_GROUND_SCREEN_BYTE = $55
WORLD_GROUND_COLOR_RAM = $05
WORLD_GROUND_Y_LO = $00
WORLD_GROUND_Y_HI = $00
WORLD_GROUND_Y_EXT = $00
WORLD_GROUND_PUBLIC_Z_LO = $00
WORLD_GROUND_PUBLIC_Z_HI = $00
WORLD_GROUND_PUBLIC_Z_EXT = $00
WORLD_GROUND_OCCLUDE = $00
WORLD_GROUND_PLANE_CLIP = $00
WORLD_GROUND_HORIZON_ONLY = $00
WORLD_GROUND_WIRE_OCCLUDE = $00
WORLD_GROUND_WIRE_MASK_HELPERS_AVAILABLE = $00
WIRE_GROUND_ROLL_X_BIAS = $b2
WIRE_GROUND_ROLL_Y_BIAS = $ce
WIRE_GROUND_ROLL_FOCAL_HALF = $55
WORLD_GROUND_HORIZON_BBOX_OCCLUDE = $00
WORLD_GROUND_ROLL_SPAN_EDGE = $00
WORLD_GROUND_VIC_POLICY_SCOPE = $00
.if WORLD_GROUND_WIRE_OCCLUDE != 0 && WORLD_GROUND_WIRE_MASK_HELPERS_AVAILABLE = 0
 .error "WORLD_GROUND_WIRE_OCCLUDE requires compact mask helpers"
.endif
CAMERA_INDEX = $00
CAMERA_HAS_POS = $00
CAMERA_HAS_ROT = $00
CAMERA_POS_X = $00
CAMERA_POS_Y = $00
CAMERA_POS_Z = $00
CAMERA_M00 = $40
CAMERA_M01 = $00
CAMERA_M02 = $00
CAMERA_M10 = $00
CAMERA_M11 = $40
CAMERA_M12 = $00
CAMERA_M20 = $00
CAMERA_M21 = $00
CAMERA_M22 = $40
CAMERA_MOVABLE = $00
CAMERA_WALK_LITE = $00
CAMERA_SMOOTH_DEPTH_ACTIVE = $00
CAMERA_SMOOTH_DEPTH_PHASE_START = $00
CAMERA_SMOOTH_DEPTH_PHASE_STEP = $00
CAMERA_MODE_CYCLE = $00
EXPLORER_RUNTIME_MODE_INITIAL = $00
EXPLORER_MATRIX_FOLD = $00
CAMERA_RUNTIME_CONTROLS = $00
CAMERA_ROLL_ACTIVE = $00
CAMERA_ROLL_CONTROL = $00
EXPLORER_RESET_ON_SPACE = $00
EXPLORER_NEAR_CLIP = $00
EXPLORER_NEAR_SKIP_CROSS = $00
EXPLORER_NEAR_POLY = $00
MODE3_LATE_NEAR_NO_POLY = $00
CLIP_POLY_VERTEX_CAPACITY = 12
CAMERA_PLANE_CLIP_REQUIRED_VERTICES = 10
.if CAMERA_PLANE_CLIP_PROFILE != 0 && CLIP_POLY_VERTEX_CAPACITY < CAMERA_PLANE_CLIP_REQUIRED_VERTICES
 .error "camera-plane clip requires at least 10 vertices in the 12-vertex clip buffers"
.endif
EXPLORER_NEAR_FILL = $00
EXPLORER_NEAR_SKIP_DEPTH = $10
EXPLORER_TRAVERSAL_CULL = $00
EXPLORER_TRAVERSAL_HYSTERESIS = $10
EXPLORER_SCREEN_CLIP_X = $00
EXPLORER_SCREEN_CLIP_POLY = $00
EXPLORER_SCREEN_RAW = $00
EXPLORER_CAMERA_NEAR_CLIP = $00
EXPLORER_CAMERA_X_CLIP = $00
EXPLORER_CAMERA_X_LO = $00
EXPLORER_CAMERA_X_HI = $00
EXPLORER_CAMERA_X_EXT = $00
EXPLORER_CAMERA_Y_LO = $00
EXPLORER_CAMERA_Y_HI = $00
EXPLORER_CAMERA_Y_EXT = $00
EXPLORER_CAMERA_Z_LO = $00
EXPLORER_CAMERA_Z_HI = $00
EXPLORER_CAMERA_Z_EXT = $00
EXPLORER_CAMERA_YAW = $00
EXPLORER_CAMERA_PITCH = $00
EXPLORER_CAMERA_ROLL = $00
EXPLORER_LOOK_STEP = $01
EXPLORER_MOVE_STEP = $7f
EXPLORER_MOVE_SUBSTEPS_PER_TICK = $01
EXPLORER_YAW_PITCH_TICK_DIV = $04
EXPLORER_YAW_PITCH_REPEAT_PHASE = EXPLORER_YAW_PITCH_TICK_DIV - 1
EXPLORER_ROLL_TICK_DIV = $02
EXPLORER_ROLL_REPEAT_RELOAD = EXPLORER_ROLL_TICK_DIV - 1
EXPLORER_PITCH_NEG_MIN = $c0
EXPLORER_PITCH_POS_LIMIT = $41
EXPLORER_PITCH_POS_MAX = $40
EXPLORER_PROJ_X_NEG_MIN = $100 - PROJ_CENTER_X
EXPLORER_PROJ_X_POS_MAX = PROJ_CENTER_X
EXPLORER_PROJ_Y_NEG_MIN = $100 - PROJ_CENTER_Y + 1
EXPLORER_PROJ_Y_POS_MAX = PROJ_CENTER_Y + 1
TEXT_SPLIT_RASTER = $50
TEXT_HEADER_CELL_ROWS = 3
TEXT_HEADER_SCREEN_BYTES = TEXT_HEADER_CELL_ROWS * 40 ; 120 bytes ($78)
TEXT_BODY_FIRST_RASTER = $4B
TEXT_BITMAP_IRQ_RASTER = $4A
TEXT_HEADER_OFFSET = $00
FPS_FONT_BYTE_COUNT = $B8
FPS_TEXT_BASE = $c000
FPS_TEXT_D018 = $02
FPS_TEXT_UNDER_IO = $00
FPS_TEXT_RELOCATED_D800 = $00
FPS_TEXT_CLEAR_CELLS = $80
FPS_COLORRAM_BULK_CLEAR = $00
FPS_COLORRAM_GLYPH_CELLS = $06
FPS_RUNTIME_BANK_SWITCH_IRQ_SAFE = $01
FPS_CHARSET_BASE = $c800
FPS_CHARSET_UNDER_IO = $00
FPS_CHARSET_RELOCATED_D000 = $00
ENGINE_MODE3_FPS_CHARSET_RELOCATED_D000 = $00
FPS_TEXT_BLANK = $00
FPS_TEXT_H = $0c

start:
 sei
 cld
 lda $dd02
 ora #$03
 sta $dd02
 lda #$36
 sta $01
 lda #WORLD_BACKGROUND_COLOR
 sta $d020
 sta $d021
 sta $d015
 lda #$ff
 sta $dc02
 lda #$00
 sta $dc03
 lda $dd00
 and #$fc
 ora #$02
 sta $dd00
 lda #$3b
 sta $d011
 lda #$18
 sta $d016
 lda #$78
 sta $d018
 jsr init_video_standard
 jsr init_buffers
.if MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = 0
 jsr reset_depth_full
.endif
 jsr init_fps_overlay
 jsr init_irq
 lda #INITIAL_ANGLE_X
 sta angx
 sta angx_hi
 lda #$00
 sta angx_lo
 lda #INITIAL_ANGLE_Y
 sta angy
 sta angy_hi
 lda #$00
 sta angy_lo
 lda #INITIAL_ANGLE_Z
 sta angz
 sta angz_hi
 lda #$00
 sta angz_lo
 lda #$01
 sta drawbuf
 lda #$00
 sta meshidx
 sta auto_cycle_counter
 sta light_phase
 sta light_tick
 sta material_latch
 sta reflect_latch
 sta light_pause
 sta light_latch
 sta light_pulse_enabled
 sta rotation_pause
 sta rotation_latch
 sta return_latch
.if CONTROL_LOWRES_KEY != 0
 sta lowres_latch
.endif
.if FPS_OVERLAY_ENABLE != 0
 sta fps_latch
.endif
.if CONTROL_LOWRES_KEY != 0
 sta lowres_scanline_enabled
.endif
.if CAMERA_MOVABLE != 0
 jsr explorer_init_camera
.endif
.if MOTION_Z_START_ON_RETURN != 0
 sta motion_z_enabled
.else
 lda #$01
 sta motion_z_enabled
 lda #$00
.endif
 lda #MOTION_Z_START_FRAC
 sta motion_z_frac
 lda #MOTION_Z_START_LO
 sta motion_z_lo
 lda #MOTION_Z_START_HI
 sta motion_z_hi
 lda #MATERIAL_REFLECTIVITY_OFFSET
 sta active_reflect_offset
 lda #MATERIAL_DEFAULT_INDEX
 sta active_material
 jsr apply_active_material
 jsr fps_update_digits
 lda #$01
 sta space_latch
.if SCENE_TIMELINE_ENABLE != 0
 jsr scene_timeline_reset
.endif
.if SCENE_GRAPHIC_INCLUDE_ENABLE != 0
 jsr scene_graphic_init
.endif
.if SCENE_OBJECT_COUNT = 0
 jsr set_active_mesh
.endif

main_loop:
.if FPS_OVERLAY_ENABLE != 0
 jsr poll_fps_key
.endif
.if CONTROL_SPACE_KEY != 0
 jsr poll_space
.endif
.if CONTROL_RETURN_KEY != 0 || CONTROL_LOWRES_KEY != 0 || CONTROL_LIGHT_KEY != 0 || CONTROL_ROTATION_KEY != 0 || CONTROL_ZERO_MOTION_KEY != 0
 jsr poll_control_keys
.endif
.if CONTROL_MATERIAL_KEYS != 0
 jsr poll_material_keys
.endif
.if CONTROL_REFLECTIVITY_KEYS != 0
 jsr poll_reflectivity_keys
.endif
 jsr wait_sim_tick
.if CAMERA_MOVABLE != 0 && CAMERA_RUNTIME_CONTROLS != 0
 jsr explorer_scan_keys
.if CAMERA_MODE_CYCLE != 0
 jsr explorer_poll_mode_cycle_f1
 lda explorer_runtime_mode
 beq ml_camera_events_done
.endif
.if EXPLORER_RESET_ON_SPACE != 0
 jsr explorer_poll_camera_reset
.endif
.if CAMERA_MODE_CYCLE != 0
ml_camera_events_done:
.endif
.endif
 jsr consume_video_ticks
.if CAMERA_MOVABLE != 0 && CAMERA_RUNTIME_CONTROLS != 0
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 beq ml_render_frame
.endif
 jsr explorer_prepare_view
.endif
ml_render_frame:
render_frame_begin:
.if SCENE_OBJECT_COUNT = 0
 jsr prepare_angles
.endif
.if DYNAMIC_LIGHT != 0
 jsr update_light_intensity
.if FULL_DYNAMIC_SHADE != 0
 jsr update_shade_dirty
.endif
.endif
.if CONTROL_LOWRES_KEY != 0
 jsr update_lowres_scanline_parity
.endif
.if ENGINE_MODE3_FRAME_PREFILL_RUNTIME_ACTIVE != 0
 jsr engine_mode3_frame_prefill
.else
.if CAMERA_MOVABLE != 0
.if ENGINE_WIRE_DIRTY_CLEAR_ENABLE != 0
 jsr clear_dirty
.else
 jsr clear_current_bitmap
.endif
.else
.if FULL_CLEAR != 0
 jsr clear_current_bitmap
.else
 jsr clear_dirty
.endif
.endif
.endif
.if ENGINE_WIRE_MATERIAL_CACHE_RESET_FRAME != 0
 jsr engine_wire_reset_material_cell_cache
.endif
.if VIC_COLOR_POLICY_ENABLE != 0
 jsr vic_color_policy_reset_frame
.endif
render_world_background:
.if SCENE_GRAPHIC_INCLUDE_ENABLE != 0
 jsr scene_graphic_render
.endif
; WORLD_GROUND_RENDER_CALL_PLACEHOLDER
render_scene_renderer:
.if CAMERA_MOVABLE != 0
 jsr render_explorer_scene_points
.else
.if SCENE_OBJECT_COUNT != 0
 jsr render_scene_objects
.else
 jsr rotate_project_vertices
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && MODE2_FACE_BUCKET_PIPELINE = 0
 jsr project_wire_vertices
 jsr draw_wire_active_mesh
.else
 jsr draw_mesh
.if WIRE_OVERLAY_ENABLE != 0
 jsr project_wire_vertices
 jsr draw_wire_active_mesh
.endif
.endif
.endif
.endif
; WORLD_GROUND_WIRE_MASK_FINALIZE_CALL_PLACEHOLDER
.if VIC_COLOR_POLICY_OVERLAY != 0
 jsr vic_color_policy_overlay_conflicts
.endif
render_frame_end:
.if CONTROL_LOWRES_KEY != 0
 lda lowres_scanline_enabled
 bne ml_async_present
.endif
 jsr wait_raster
.if CONTROL_LOWRES_KEY != 0
ml_async_present:
.endif
 jsr show_buffer
 jsr fps_frame_done
 jmp main_loop

.if CONTROL_LOWRES_KEY != 0
update_lowres_scanline_parity:
 lda lowres_scanline_enabled
 bne ulsp_enabled
 lda #$00
 sta lowres_scanline_parity
 rts
ulsp_enabled:
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_parity_a
 sta lowres_scanline_parity
 clc
 adc #$01
 jsr wrap_lowres_parity
 sta lowres_parity_a
 sta lowres_parity_b
 rts
.else
 lda drawbuf
 bne ulsp_b
 lda lowres_parity_a
 sta lowres_scanline_parity
 clc
 adc #$01
 jsr wrap_lowres_parity
 sta lowres_parity_a
 rts
ulsp_b:
 lda lowres_parity_b
 sta lowres_scanline_parity
 clc
 adc #$01
 jsr wrap_lowres_parity
 sta lowres_parity_b
 rts
.endif

wrap_lowres_parity:
 ldx lowres_scanline_enabled
 cpx #$02
 bcs wlp_quarter
 and #$01
 rts
wlp_quarter:
 and #$03
 rts

lowres_row_selected:
 lda lowres_scanline_enabled
 cmp #$02
 bcs lrs_quarter
 txa
 and #$01
 cmp lowres_scanline_parity
 rts
lrs_quarter:
 txa
 and #$03
 cmp lowres_scanline_parity
 rts
.endif

wait_sim_tick:
 lda sim_vblank_count
 bne wst_done
wst_loop:
 lda sim_vblank_count
 beq wst_loop
wst_done:
 rts

consume_video_ticks:
 sei
 lda sim_vblank_count
 beq cvt_no_tick
 sec
 sbc #$01
 sta sim_vblank_count
 cli
.if VIDEO_STANDARD_FORCE_PAL != 0
 jsr advance_sim_tick
.else
 jsr schedule_video_tick
.endif
 jmp consume_video_ticks
cvt_no_tick:
 cli
cvt_done:
 rts

.if VIDEO_STANDARD_FORCE_PAL = 0
schedule_video_tick:
.if VIDEO_STANDARD_FORCE_NTSC = 0
 lda video_standard_runtime
 beq svt_advance
.endif
 inc ntsc_sim_phase
 lda ntsc_sim_phase
 cmp #$06
 bcc svt_advance
 lda #$00
 sta ntsc_sim_phase
 rts
svt_advance:
 jmp advance_sim_tick
.endif

advance_sim_tick:
.if SCENE_GRAPHIC_INCLUDE_ENABLE != 0
 jsr scene_graphic_tick
.endif
.if SCENE_TIMELINE_ENABLE != 0
 jsr scene_timeline_tick
.endif
.if SCENE_OBJECT_COUNT != 0
.if SCENE_POS_ACTIVE != 0 || SCENE_ROT_ACTIVE != 0 || SCENE_RESPAWN_ACTIVE != 0 || SCENE_OSC_X_ACTIVE != 0
 jsr advance_scene_objects
.endif
.else
 jsr auto_cycle_mesh
 jsr advance_motion_z
.endif
.if DYNAMIC_LIGHT != 0 && STATIC_RUNTIME_LIGHT = 0
 lda light_pause
 bne ast_after_light
 jsr advance_light_phase
ast_after_light:
.endif
.if RANDOM_MATERIAL_CYCLE != 0
 jsr random_material_cycle_tick
.endif
.if STATIC_POSE = 0
.if SCENE_OBJECT_COUNT = 0
 lda rotation_pause
 bne ast_rotation_done
 clc
 lda angx_lo
 adc #ANGLE_X_STEP_LO
 sta angx_lo
 lda angx_hi
 adc #ANGLE_X_STEP_HI
 sta angx_hi
 sta angx
 clc
 lda angy_lo
 adc #ANGLE_Y_STEP_LO
 sta angy_lo
 lda angy_hi
 adc #ANGLE_Y_STEP_HI
 sta angy_hi
 sta angy
 clc
 lda angz_lo
 adc #ANGLE_Z_STEP_LO
 sta angz_lo
 lda angz_hi
 adc #ANGLE_Z_STEP_HI
 sta angz_hi
 sta angz
ast_rotation_done:
.endif
.endif
.if CAMERA_MOVABLE != 0 && CAMERA_RUNTIME_CONTROLS != 0
 jsr explorer_advance_camera_tick
.endif
.if CAMERA_SMOOTH_DEPTH_ACTIVE != 0
 jsr advance_camera_smooth_depth_ping_pong
.endif
 rts

advance_motion_z:
.if MOTION_Z_START_ON_RETURN != 0
 lda motion_z_enabled
 bne amz_enabled
 rts
amz_enabled:
.endif
 clc
 lda motion_z_frac
 adc #MOTION_Z_STEP_FRAC
 sta motion_z_frac
 lda motion_z_lo
 adc #MOTION_Z_STEP_LO
 sta motion_z_lo
 lda motion_z_hi
 adc #MOTION_Z_STEP_HI
 bcc amz_store_hi
 lda #$ff
 sta motion_z_frac
 sta motion_z_lo
amz_store_hi:
 sta motion_z_hi
 rts

.if SCENE_POS_ACTIVE != 0 || SCENE_ROT_ACTIVE != 0 || SCENE_RESPAWN_ACTIVE != 0 || SCENE_OSC_X_ACTIVE != 0
advance_scene_objects:
.if SCENE_OBJECT_COUNT != 0
 ldx #$00
aso_loop:
.if SCENE_POS_ACTIVE != 0
.if MOTION_Z_START_ON_RETURN != 0
 lda motion_z_enabled
 beq aso_skip_position
.endif
.if SCENE_VEL_X_ACTIVE != 0
 clc
 lda object_pos_x_lo,x
 adc object_vel_x_lo,x
 sta object_pos_x_lo,x
 lda object_pos_x_hi,x
 adc object_vel_x_hi,x
 sta object_pos_x_hi,x
.endif
.if SCENE_OSC_X_ACTIVE != 0
 jsr oscillate_scene_object_x_if_needed
.endif
.if SCENE_VEL_Y_ACTIVE != 0
 clc
 lda object_pos_y_lo,x
 adc object_vel_y_lo,x
 sta object_pos_y_lo,x
 lda object_pos_y_hi,x
 adc object_vel_y_hi,x
 sta object_pos_y_hi,x
.endif
.if SCENE_VEL_Z_ACTIVE != 0
 clc
 lda object_pos_z_lo,x
 adc object_vel_z_lo,x
 sta object_pos_z_lo,x
 lda object_pos_z_hi,x
 adc object_vel_z_hi,x
 sta object_pos_z_hi,x
 lda object_pos_z_ext,x
 adc object_vel_z_ext,x
 sta object_pos_z_ext,x
.endif
.if SCENE_RESPAWN_ACTIVE != 0
 jsr respawn_scene_object_if_needed
.endif
aso_skip_position:
.endif
.if STATIC_POSE = 0
.if SCENE_ROT_ACTIVE != 0
 lda rotation_pause
 bne aso_skip_rotation
.if SCENE_ANG_X_ACTIVE != 0
 clc
 lda object_ang_x_lo,x
 adc object_angvel_x_lo,x
 sta object_ang_x_lo,x
 lda object_ang_x_hi,x
 adc object_angvel_x_hi,x
 sta object_ang_x_hi,x
.endif
.if SCENE_ANG_Y_ACTIVE != 0
 clc
 lda object_ang_y_lo,x
 adc object_angvel_y_lo,x
 sta object_ang_y_lo,x
 lda object_ang_y_hi,x
 adc object_angvel_y_hi,x
 sta object_ang_y_hi,x
.endif
.if SCENE_ANG_Z_ACTIVE != 0
 clc
 lda object_ang_z_lo,x
 adc object_angvel_z_lo,x
 sta object_ang_z_lo,x
 lda object_ang_z_hi,x
 adc object_angvel_z_hi,x
 sta object_ang_z_hi,x
.endif
aso_skip_rotation:
.endif
.endif
 inx
 cpx #SCENE_OBJECT_COUNT
 bne aso_loop
.endif
 rts
.endif

.if SCENE_RESPAWN_ACTIVE != 0 || RANDOM_MATERIAL_CYCLE != 0
scene_rand:
 lda scene_rng_state
 asl
 bcc sr_no_xor
 eor #$1d
sr_no_xor:
 eor fps_cur_frames
 sta scene_rng_state
 rts
.endif

.if SCENE_RESPAWN_ACTIVE != 0
respawn_scene_object_if_needed:
 lda object_respawn_enabled,x
 beq rso_respawn_done
 lda object_pos_z_ext,x
 cmp #$ff
 bne rso_respawn_done
 lda object_pos_z_hi,x
 cmp object_respawn_near_z_hi,x
 bcs rso_respawn_done
 stx tmpidx
 jsr scene_rand
 ldx tmpidx
 and object_respawn_x_mask,x
 sec
 sbc object_respawn_x_bias,x
 sta object_pos_x_hi,x
 lda #$00
 sta object_pos_x_lo,x
 jsr scene_rand
 ldx tmpidx
 and object_respawn_y_mask,x
 sec
 sbc object_respawn_y_bias,x
 sta object_pos_y_hi,x
 lda #$00
 sta object_pos_y_lo,x
 jsr scene_rand
 ldx tmpidx
 and object_respawn_far_z_jitter_mask,x
 clc
 adc object_respawn_far_z_hi,x
 sta object_pos_z_hi,x
 lda object_respawn_far_z_ext,x
 adc #$00
 sta object_pos_z_ext,x
 lda object_respawn_far_z_lo,x
 sta object_pos_z_lo,x
 jsr scene_rand
 ldx tmpidx
 sta object_ang_x_hi,x
 lda #$00
 sta object_ang_x_lo,x
 jsr scene_rand
 ldx tmpidx
 sta object_ang_y_hi,x
 lda #$00
 sta object_ang_y_lo,x
 jsr scene_rand
 ldx tmpidx
 sta object_ang_z_hi,x
 lda #$00
 sta object_ang_z_lo,x
 ldx tmpidx
rso_respawn_done:
 rts
.endif

.if RANDOM_MATERIAL_CYCLE != 0
random_material_cycle_tick:
 inc random_material_tick
 lda random_material_tick
 cmp #RANDOM_MATERIAL_CYCLE_TICKS
 bcc rmct_done
 lda #$00
 sta random_material_tick
 jsr scene_rand
 and #$0f
 tax
 lda random_material_index_table,x
 sta t1
.if POLY_FILL_ENABLE != 0
.if FACE_MATERIAL_ACTIVE_ONLY != 0
 sta active_material
 jsr apply_active_material
.else
 ldx #$00
rmct_face_loop:
 cpx #FACE_COUNT
 beq rmct_faces_done
 lda t1
 sta face_material,x
 inx
 jmp rmct_face_loop
rmct_faces_done:
.endif
.endif
.if WIRE_OBJECT_MATERIAL_ENABLE != 0 && WIRE_MESH_COUNT != 0 && SCENE_OBJECT_COUNT != 0
 jsr scene_rand
 and #$0f
 tax
 lda random_wire_color_table,x
 sta t2
 ldx #$00
rmct_wire_loop:
 cpx #SCENE_OBJECT_COUNT
 beq rmct_done
 ldy object_mesh,x
 lda mesh_is_wire,y
 beq rmct_wire_next
 lda t2
 sta object_wire_screen,x
 sta object_wire_color,x
rmct_wire_next:
 inx
 jmp rmct_wire_loop
.endif
rmct_done:
 rts
.endif

.if SCENE_OSC_X_ACTIVE != 0
oscillate_scene_object_x_if_needed:
 lda object_osc_x_enabled,x
 beq oso_done
 lda object_vel_x_hi,x
 bmi oso_check_min
oso_check_max:
 lda object_osc_x_max_hi,x
 eor #$80
 sta mulb
 lda object_pos_x_hi,x
 eor #$80
 cmp mulb
 bcc oso_done
 bne oso_hit_max
 lda object_pos_x_lo,x
 cmp object_osc_x_max_lo,x
 bcc oso_done
oso_hit_max:
 lda object_osc_x_max_lo,x
 sta object_pos_x_lo,x
 lda object_osc_x_max_hi,x
 sta object_pos_x_hi,x
 jmp oso_reverse_vel
oso_check_min:
 lda object_osc_x_min_hi,x
 eor #$80
 sta mulb
 lda object_pos_x_hi,x
 eor #$80
 cmp mulb
 bcc oso_hit_min
 bne oso_done
 lda object_pos_x_lo,x
 cmp object_osc_x_min_lo,x
 beq oso_hit_min
 bcs oso_done
oso_hit_min:
 lda object_osc_x_min_lo,x
 sta object_pos_x_lo,x
 lda object_osc_x_min_hi,x
 sta object_pos_x_hi,x
oso_reverse_vel:
 sec
 lda #$00
 sbc object_vel_x_lo,x
 sta object_vel_x_lo,x
 lda #$00
 sbc object_vel_x_hi,x
 sta object_vel_x_hi,x
oso_done:
 rts
.endif

.if DYNAMIC_LIGHT != 0
.if STATIC_RUNTIME_LIGHT = 0
advance_light_phase:
 inc light_tick
 lda light_tick
 cmp #LIGHT_TICK_DIV
 bcc alp_done
 lda #$00
 sta light_tick
 inc light_phase
 lda light_phase
 and #LIGHT_PHASE_MASK
 sta light_phase
alp_done:
 rts
.endif

update_light_intensity:
.if DYNAMIC_LIGHT != 0
.if STATIC_RUNTIME_LIGHT != 0
 lda #LIGHT_INTENSITY_MAX
 sta light_intensity
.else
.if LIGHT_PULSE_ON_SPACE != 0
 lda light_pulse_enabled
 bne uli_use_phase_table
 lda #LIGHT_INTENSITY_MAX
 sta light_intensity
 rts
uli_use_phase_table:
.endif
 ldx light_phase
 lda light_intensity_table,x
 sta light_intensity
.endif
.endif
 rts
.endif

.if FULL_DYNAMIC_SHADE != 0
update_shade_dirty:
.if DYNAMIC_LIGHT != 0
.if FULL_DYNAMIC_SHADE != 0
.if SCENE_OBJECT_COUNT != 0
 lda #$00
 sta shade_intensity_changed
.if STATIC_RUNTIME_LIGHT = 0
 lda light_phase
 cmp shade_last_light_phase
 beq usd_scene_intensity
 sta shade_last_light_phase
usd_scene_intensity:
.endif
 lda light_intensity
 cmp shade_last_light_intensity
 beq usd_scene_reflect
 sta shade_last_light_intensity
 lda #$01
 sta shade_intensity_changed
usd_scene_reflect:
 lda active_reflect_offset
 cmp shade_last_reflect_offset
 beq usd_scene_done
 sta shade_last_reflect_offset
 lda #$01
 sta shade_intensity_changed
usd_scene_done:
 rts
.endif
 lda #$00
 sta shade_dirty
 sta shade_intensity_changed
 lda meshidx
 cmp shade_last_meshidx
 beq usd_light
 sta shade_last_meshidx
 lda #$01
 sta shade_dirty
usd_light:
 lda light_phase
 cmp shade_last_light_phase
 beq usd_intensity
 sta shade_last_light_phase
 lda #$01
 sta shade_dirty
usd_intensity:
 lda light_intensity
 cmp shade_last_light_intensity
 beq usd_reflect
 sta shade_last_light_intensity
 lda #$01
 sta shade_dirty
 sta shade_intensity_changed
usd_reflect:
 lda active_reflect_offset
 cmp shade_last_reflect_offset
 beq usd_angx_lo
 sta shade_last_reflect_offset
 lda #$01
 sta shade_dirty
 sta shade_intensity_changed
usd_angx_lo:
 lda angx_lo
 cmp shade_last_angx_lo
 beq usd_angx_hi
 sta shade_last_angx_lo
 lda #$01
 sta shade_dirty
usd_angx_hi:
 lda angx_hi
 cmp shade_last_angx_hi
 beq usd_angy_lo
 sta shade_last_angx_hi
 lda #$01
 sta shade_dirty
usd_angy_lo:
 lda angy_lo
 cmp shade_last_angy_lo
 beq usd_angy_hi
 sta shade_last_angy_lo
 lda #$01
 sta shade_dirty
usd_angy_hi:
 lda angy_hi
 cmp shade_last_angy_hi
 beq usd_angz_lo
 sta shade_last_angy_hi
 lda #$01
 sta shade_dirty
usd_angz_lo:
 lda angz_lo
 cmp shade_last_angz_lo
 beq usd_angz_hi
 sta shade_last_angz_lo
 lda #$01
 sta shade_dirty
usd_angz_hi:
 lda angz_hi
 cmp shade_last_angz_hi
 beq usd_done
 sta shade_last_angz_hi
 lda #$01
 sta shade_dirty
usd_done:
.endif
.endif
 rts
.endif

wait_raster:
wr1: lda $d012
 cmp #$f0
 bne wr1
wr2: lda $d012
 cmp #$f0
 beq wr2
 rts

init_irq:
 lda #$7f
 sta $dc0d
 sta $dd0d
 lda $dc0d
 lda $dd0d
 lda #<raster_irq
 sta $0314
 lda #>raster_irq
 sta $0315
 lda #$00
 sta irq_phase
.if FPS_OVERLAY_ENABLE != 0
 lda fps_overlay_visible
 beq init_irq_bitmap
 jsr set_text_header_mode
 jmp init_irq_mode_done
init_irq_bitmap:
 jsr set_bitmap_body_mode
init_irq_mode_done:
.else
 jsr set_bitmap_body_mode
.endif
 lda #$00
 sta $d012
 lda #$01
 sta $d019
 sta $d01a
 cli
 rts

raster_irq:
 lda #$01
 sta $d019
.if FPS_OVERLAY_ENABLE != 0
 lda fps_overlay_visible
 bne ri_overlay_enabled
 jsr set_bitmap_body_mode
 inc fps_vblank_count
 inc sim_vblank_count
 lda fps_vblank_count
.if VIDEO_STANDARD_FORCE_PAL != 0
 cmp #VIDEO_PAL_VBLANKS_PER_SECOND
.else
.if VIDEO_STANDARD_FORCE_NTSC != 0
 cmp #VIDEO_NTSC_VBLANKS_PER_SECOND
.else
 cmp video_vblanks_per_second
.endif
.endif
 bcc ri_overlay_hidden_counter_done
 lda #$00
 sta fps_vblank_count
 lda #$01
 sta fps_second_flag
ri_overlay_hidden_counter_done:
 lda #$00
 sta irq_phase
 sta $d012
 jmp $ea81
ri_overlay_enabled:
 lda irq_phase
 bne ri_bitmap_phase_fast
ri_text_phase:
 jsr set_text_header_mode
 inc fps_vblank_count
 inc sim_vblank_count
 lda fps_vblank_count
.if VIDEO_STANDARD_FORCE_PAL != 0
 cmp #VIDEO_PAL_VBLANKS_PER_SECOND
.else
.if VIDEO_STANDARD_FORCE_NTSC != 0
 cmp #VIDEO_NTSC_VBLANKS_PER_SECOND
.else
 cmp video_vblanks_per_second
.endif
.endif
 bcc ri_text_counter_done
 lda #$00
 sta fps_vblank_count
 lda #$01
 sta fps_second_flag
ri_text_counter_done:
 lda #TEXT_BITMAP_IRQ_RASTER
 sta $d012
 lda #$01
 sta irq_phase
 jmp $ea81

ri_bitmap_phase_fast:
 lda #$18
 sta $d016
 lda #$3b
 sta $d011
 lda #WORLD_BACKGROUND_COLOR
 sta $d020
 sta $d021
 lda #$00
 sta $d012
 sta irq_phase
 jmp $ea81
.else
 jsr set_bitmap_body_mode
 inc fps_vblank_count
 inc sim_vblank_count
 lda fps_vblank_count
.if VIDEO_STANDARD_FORCE_PAL != 0
 cmp #VIDEO_PAL_VBLANKS_PER_SECOND
.else
.if VIDEO_STANDARD_FORCE_NTSC != 0
 cmp #VIDEO_NTSC_VBLANKS_PER_SECOND
.else
 cmp video_vblanks_per_second
.endif
.endif
 bcc ri_no_overlay_counter_done
 lda #$00
 sta fps_vblank_count
 lda #$01
 sta fps_second_flag
ri_no_overlay_counter_done:
 lda #$00
 sta $d012
 jmp $ea81
.endif

init_video_standard:
.if VIDEO_STANDARD_AUTO != 0
 jsr detect_video_standard
 rts
.else
.if VIDEO_STANDARD_FORCE_NTSC != 0
 lda #$01
 sta video_standard_runtime
 lda #VIDEO_NTSC_VBLANKS_PER_SECOND
 sta video_vblanks_per_second
 rts
.else
 lda #$00
 sta video_standard_runtime
 lda #VIDEO_PAL_VBLANKS_PER_SECOND
 sta video_vblanks_per_second
 rts
.endif
.endif

.if VIDEO_STANDARD_RUNTIME_DETECT != 0
detect_video_standard:
dvs_wait_low_raster:
 lda $d011
 bmi dvs_wait_low_raster
dvs_wait_high_raster:
 lda $d011
 bpl dvs_wait_high_raster
dvs_scan_high_raster:
 lda $d011
 bpl dvs_detected_ntsc
 lda $d012
 cmp #$20
 bcc dvs_scan_high_raster
dvs_detected_pal:
 lda #$00
 sta video_standard_runtime
 lda #VIDEO_PAL_VBLANKS_PER_SECOND
 sta video_vblanks_per_second
 rts
dvs_detected_ntsc:
 lda #$01
 sta video_standard_runtime
 lda #VIDEO_NTSC_VBLANKS_PER_SECOND
 sta video_vblanks_per_second
 rts
.endif

init_fps_overlay:
.if FPS_OVERLAY_ENABLE != 0
 jsr init_fps_charset
 jsr init_fps_text
.endif
 lda #$00
 sta fps_vblank_count
 sta fps_second_flag
 sta ntsc_sim_phase
.if FPS_COUNTER_ENABLE != 0 || RANDOM_MATERIAL_CYCLE != 0
 sta fps_cur_frames
.endif
.if FPS_COUNTER_ENABLE != 0
 sta fps_sum
 sta fps_sample_index
 sta fps_initialized
 sta fps_last_value
 sta fps_last_tenths
 ldx #$04
ifo_samples:
 sta fps_samples,x
 dex
 bpl ifo_samples
.endif
 sta sim_vblank_count
.if FPS_OVERLAY_ENABLE != 0
 lda #FPS_OVERLAY_ON_START
 sta fps_overlay_visible
 lda #$00
 sta fps_latch
.endif
 lda #$00
 sta $d015
 jmp fps_update_digits

.if FPS_OVERLAY_ENABLE != 0
init_fps_charset:
 ldx #$00
ifc_loop:
 lda fps_font_bytes,x
 sta $6000,x
 sta BITMAP_B_BASE,x
 inx
 cpx #FPS_FONT_BYTE_COUNT
 bne ifc_loop
 rts

init_fps_text:
 ldx #$00
 lda #$00
ift_clear_screen:
 sta $5c00,x
 sta SCREEN_B_BASE,x
 inx
 cpx #TEXT_HEADER_SCREEN_BYTES
 bne ift_clear_screen

 ldx #$00
ift_write_string:
 lda text_header_string,x
 cmp #$ff
 beq ift_write_done
 sta $5c28+TEXT_HEADER_OFFSET,x
 sta SCREEN_B_BASE+$0028+TEXT_HEADER_OFFSET,x
 lda #$01
 sta $d828+TEXT_HEADER_OFFSET,x
 inx
 cpx #40
 bne ift_write_string
ift_write_done:
 rts
.endif

.if FPS_OVERLAY_ENABLE != 0
set_text_header_mode:
 lda #$00
 sta $d020
 sta $d021
 lda drawbuf
 beq sth_show_b
sth_show_a:
 lda $dd00
 and #$fc
 ora #$02
 sta $dd00
 lda #$78
 sta $d018
 jmp sth_common
sth_show_b:
 lda $dd00
 and #$fc
 ora #VIC_BANK_B_BITS
 sta $dd00
 lda #VIC_D018_B
 sta $d018
sth_common:
 lda #$08
 sta $d016
 lda #$1b
 sta $d011
 rts

set_bitmap_body_mode:
 lda #WORLD_BACKGROUND_COLOR
 sta $d020
 sta $d021
 lda #$18
 sta $d016
 lda #$3b
 sta $d011
 rts
.else
set_text_header_mode:
 lda #$00
 sta $d020
 sta $d021
 lda $dd00
 and #$fc
 sta $dd00
 lda #$18
 sta $d011
 lda #$08
 sta $d016
 lda #FPS_TEXT_D018
 sta $d018
 rts

set_bitmap_body_mode:
 lda #WORLD_BACKGROUND_COLOR
 sta $d020
 sta $d021
 lda #$3b
 sta $d011
 lda #$18
 sta $d016
 lda drawbuf
 beq sbb_show_b
sbb_show_a:
 lda $dd00
 and #$fc
 ora #$02
 sta $dd00
 lda #$78
 sta $d018
 rts
sbb_show_b:
 lda $dd00
 and #$fc
 ora #VIC_BANK_B_BITS
 sta $dd00
 lda #VIC_D018_B
 sta $d018
 rts
.endif

fps_frame_done:
.if FPS_COUNTER_ENABLE = 0
 rts
.else
 lda fps_second_flag
 beq ffd_count_frame
 lda #$00
 sta fps_second_flag
 jsr fps_sample_second
ffd_count_frame:
 inc fps_cur_frames
 rts
.endif

fps_sample_second:
.if FPS_COUNTER_ENABLE = 0
 rts
.else
 lda fps_initialized
 bne fss_regular
 lda #$01
 sta fps_initialized
 lda fps_cur_frames
 sta p1lo
 lda #$00
 sta fps_sum
 sta fps_sample_index
 ldx #$00
fss_seed_loop:
 lda p1lo
 sta fps_samples,x
 clc
 adc fps_sum
 sta fps_sum
 inx
 cpx #$05
 bne fss_seed_loop
 lda #$00
 sta fps_cur_frames
 jmp fps_update_digits
fss_regular:
 ldx fps_sample_index
 lda fps_sum
 sec
 sbc fps_samples,x
 sta fps_sum
 lda fps_cur_frames
 sta fps_samples,x
 clc
 adc fps_sum
 sta fps_sum
 lda #$00
 sta fps_cur_frames
 inx
 cpx #$05
 bne fss_index_ok
 ldx #$00
fss_index_ok:
 stx fps_sample_index
 jmp fps_update_digits
.endif

fps_update_digits:
.if FPS_COUNTER_ENABLE = 0
 rts
.else
 lda fps_sum
 sta p1lo
 lda #$00
 sta p1hi
fud_div5_loop:
 lda p1lo
 cmp #$05
 bcc fud_div5_done
 sec
 sbc #$05
 sta p1lo
 inc p1hi
 jmp fud_div5_loop
fud_div5_done:
 lda p1hi
 sta fps_last_value
 lda p1lo
 asl
 sta fps_last_tenths
.if FPS_OVERLAY_ENABLE = 0
 rts
.else
 lda fps_overlay_visible
 beq fud_done
 lda fps_last_tenths
 clc
 adc #$01
 sta fps_digit_frac
 lda fps_last_value
 sta p1lo
 lda #$00
 sta p1hi
fud_div10_loop:
 lda p1lo
 cmp #$0a
 bcc fud_div10_done
 sec
 sbc #$0a
 sta p1lo
 inc p1hi
 jmp fud_div10_loop
fud_div10_done:
 lda p1hi
 clc
 adc #$01
 sta fps_digit_tens
 lda p1lo
 clc
 adc #$01
 sta fps_digit_ones
 lda fps_digit_tens
 sta $5c28
 sta SCREEN_B_BASE+$0028
 lda fps_digit_ones
 sta $5c29
 sta SCREEN_B_BASE+$0029
 lda #$0b
 sta $5c2a
 sta SCREEN_B_BASE+$002a
 lda fps_digit_frac
 sta $5c2b
 sta SCREEN_B_BASE+$002b
 lda #$01
 sta $d828
 sta $d829
 sta $d82a
 sta $d82b
 sta $d82c
 sta $d82d
fud_done:
 rts
.endif
.endif

set_active_mesh:
 ldx meshidx
 lda mesh_vfirst,x
 sta active_vfirst
 lda mesh_vend,x
 sta active_vend
.if WIRE_RENDER_ENABLE != 0 && WIRE_MESH_COUNT != 0
 lda mesh_is_wire,x
 beq sam_face_range
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0
 lda mesh_face_first,x
 cmp mesh_face_end,x
 bne sam_face_range
.endif
 lda mesh_edge_first,x
 sta active_face_first
 lda mesh_edge_end,x
 sta active_face_end
 rts
sam_face_range:
.endif
 lda mesh_face_first,x
 sta active_face_first
 lda mesh_face_end,x
 sta active_face_end
 rts

set_active_object:
.if SCENE_OBJECT_COUNT != 0
 ldx objidx
 lda object_mesh,x
 sta meshidx
.if SCENE_OBJECT_X_ACTIVE != 0
 lda object_pos_x_hi,x
.else
 lda #$00
.endif
 sta obj_pos_x_cur
.if SCENE_OBJECT_Y_ACTIVE != 0
 lda object_pos_y_hi,x
.else
 lda #$00
.endif
 sta obj_pos_y_cur
 lda object_pos_z_lo,x
 sta obj_depth_frac
 lda object_pos_z_hi,x
 sta obj_depth_lo
 lda object_pos_z_ext,x
 sta obj_depth_hi
.if SCENE_OBJECT_SCALE_ACTIVE != 0
 lda object_scale,x
.else
 lda #$40
.endif
 sta obj_scale_cur
.if EXPLORER_TRAVERSAL_CULL != 0
 jsr update_object_traverse_active
.endif
.if WIRE_RENDER_ENABLE != 0 && WIRE_OBJECT_MATERIAL_ENABLE != 0
 jsr restore_active_object_wire_material
.endif
 lda object_ang_x_hi,x
 sta angx
 sta angx_hi
 lda object_ang_x_lo,x
 sta angx_lo
 lda object_ang_y_hi,x
 sta angy
 sta angy_hi
 lda object_ang_y_lo,x
 sta angy_lo
 lda object_ang_z_hi,x
 sta angz
 sta angz_hi
 lda object_ang_z_lo,x
 sta angz_lo
 jsr set_active_mesh
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx objidx
 lda object_runtime_vfirst,x
 sta active_vfirst
 lda object_runtime_vend,x
 sta active_vend
 lda object_runtime_face_first,x
 sta shared_runtime_face
 lda object_source_vertex_delta,x
 sta shared_vertex_delta
 ldx meshidx
 lda mesh_vfirst,x
 sta shared_source_vertex
.endif
.endif
 rts

.if WIRE_RENDER_ENABLE != 0 && WIRE_OBJECT_MATERIAL_ENABLE != 0
restore_active_object_wire_material:
 ldx objidx
 lda object_wire_screen,x
 sta material_screen_cur
 lda object_wire_color,x
 sta material_color_cur
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 rts
.endif

.if MODE2_FACE_BUCKET_PIPELINE != 0 && WIRE_OBJECT_MATERIAL_ENABLE != 0
restore_face_owner_wire_color:
 ldy sortj
 lda face_object,y
 tax
 lda object_wire_screen,x
 sta material_screen_cur
 lda object_wire_color,x
 sta material_color_cur
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 rts
.endif

.if EXPLORER_TRAVERSAL_CULL != 0
update_object_traverse_active:
 ldx objidx
 lda object_traverse_radius,x
 ldx objidx
 ldy object_traverse_state,x
 beq uota_threshold_ready
 clc
 adc #EXPLORER_TRAVERSAL_HYSTERESIS
uota_threshold_ready:
 sta p1lo
 lda obj_pos_x_cur
 sec
 sbc explorer_cam_x_hi
 jsr abs_a8
 cmp p1lo
 bcs uota_no
 lda obj_pos_y_cur
 sec
 sbc explorer_cam_y_hi
 jsr abs_a8
 cmp p1lo
 bcs uota_no
 sec
 lda obj_depth_lo
 sbc explorer_cam_z_hi
 sta p1hi
 lda obj_depth_hi
 sbc explorer_cam_z_ext
 beq uota_z_positive
 cmp #$ff
 bne uota_no
 sec
 lda #$00
 sbc p1hi
 jmp uota_z_compare
uota_z_positive:
 lda p1hi
uota_z_compare:
 cmp p1lo
 bcs uota_no
 lda #$01
 sta object_traverse_active
 ldx objidx
 sta object_traverse_state,x
 rts
uota_no:
 lda #$00
 sta object_traverse_active
 ldx objidx
 sta object_traverse_state,x
 rts

abs_a8:
 bpl aa8_done
 eor #$ff
 clc
 adc #$01
aa8_done:
 rts
.endif

advance_active_mesh:
 inc meshidx
 lda meshidx
 cmp #MESH_COUNT
 bcc aam_mesh_ok
 lda #$00
 sta meshidx
aam_mesh_ok:
 lda #$00
 sta auto_cycle_counter
 jsr set_active_mesh
 jsr switch_frame_barrier
 rts

.if SCENE_TIMELINE_ENABLE != 0
scene_timeline_reset:
 lda #SCENE_TIMELINE_INITIAL_STATE
 sta scene_timeline_state
 jmp scene_timeline_apply_state

scene_timeline_poll_reset:
 lda #$7f
 sta $dc00
 lda $dc01
 and #$10
 bne stpr_released
 lda space_latch
 bne stpr_done
 lda #$01
 sta space_latch
 jsr scene_timeline_reset
 jmp stpr_done
stpr_released:
 lda #$00
 sta space_latch
stpr_done:
 lda #$ff
 sta $dc00
 rts

scene_timeline_tick:
 lda scene_timeline_ticks_lo
 bne stt_dec_lo
 lda scene_timeline_ticks_hi
 beq stt_next
 dec scene_timeline_ticks_hi
stt_dec_lo:
 dec scene_timeline_ticks_lo
 lda scene_timeline_ticks_lo
 ora scene_timeline_ticks_hi
 bne stt_done
stt_next:
 ldx scene_timeline_state
 lda scene_timeline_next,x
 sta scene_timeline_state
 jsr scene_timeline_apply_state
stt_done:
 rts

scene_timeline_apply_state:
 ldx scene_timeline_state
 lda scene_timeline_duration_lo,x
 sta scene_timeline_ticks_lo
 lda scene_timeline_duration_hi,x
 sta scene_timeline_ticks_hi
 lda scene_timeline_entry_base,x
 sta scene_timeline_entry
 lda #$00
 sta objidx
sta_object_loop:
 ldy scene_timeline_entry
 lda scene_timeline_mask0,y
 sta t1
 lda scene_timeline_mask1,y
 sta t2
 ldx objidx
 lda t1
 and #$01
 beq sta_no_visible
 lda scene_timeline_visible,y
 sta object_visible,x
sta_no_visible:
 lda t1
 and #$02
 beq sta_no_position
 lda scene_timeline_px_lo,y
 sta object_pos_x_lo,x
 lda scene_timeline_px_hi,y
 sta object_pos_x_hi,x
 lda scene_timeline_py_lo,y
 sta object_pos_y_lo,x
 lda scene_timeline_py_hi,y
 sta object_pos_y_hi,x
 lda scene_timeline_pz_lo,y
 sta object_pos_z_lo,x
 lda scene_timeline_pz_hi,y
 sta object_pos_z_hi,x
 lda scene_timeline_pz_ext,y
 sta object_pos_z_ext,x
sta_no_position:
 lda t1
 and #$04
 beq sta_no_rotation
 lda scene_timeline_rx_lo,y
 sta object_ang_x_lo,x
 lda scene_timeline_rx_hi,y
 sta object_ang_x_hi,x
 lda scene_timeline_ry_lo,y
 sta object_ang_y_lo,x
 lda scene_timeline_ry_hi,y
 sta object_ang_y_hi,x
 lda scene_timeline_rz_lo,y
 sta object_ang_z_lo,x
 lda scene_timeline_rz_hi,y
 sta object_ang_z_hi,x
sta_no_rotation:
 lda t1
 and #$08
 beq sta_no_scale
 lda scene_timeline_scale,y
 sta object_scale,x
sta_no_scale:
.if SCENE_INSTANCE_OVERRIDES != 0
 lda t1
 and #$10
 beq sta_no_material
 lda scene_timeline_material,y
 sta object_material_override,x
sta_no_material:
 lda t1
 and #$20
 beq sta_no_reflect
 lda scene_timeline_reflect,y
 sta object_reflectivity_override,x
sta_no_reflect:
 lda t1
 and #$40
 beq sta_no_color
 lda scene_timeline_color,y
 sta object_color_override,x
sta_no_color:
.endif
 lda t1
 and #$80
 beq sta_no_velocity
 lda scene_timeline_vx_lo,y
 sta object_vel_x_lo,x
 lda scene_timeline_vx_hi,y
 sta object_vel_x_hi,x
 lda scene_timeline_vy_lo,y
 sta object_vel_y_lo,x
 lda scene_timeline_vy_hi,y
 sta object_vel_y_hi,x
 lda scene_timeline_vz_lo,y
 sta object_vel_z_lo,x
 lda scene_timeline_vz_hi,y
 sta object_vel_z_hi,x
 lda scene_timeline_vz_ext,y
 sta object_vel_z_ext,x
sta_no_velocity:
 lda t2
 and #$01
 beq sta_no_ang_velocity
 lda scene_timeline_avx_lo,y
 sta object_angvel_x_lo,x
 lda scene_timeline_avx_hi,y
 sta object_angvel_x_hi,x
 lda scene_timeline_avy_lo,y
 sta object_angvel_y_lo,x
 lda scene_timeline_avy_hi,y
 sta object_angvel_y_hi,x
 lda scene_timeline_avz_lo,y
 sta object_angvel_z_lo,x
 lda scene_timeline_avz_hi,y
 sta object_angvel_z_hi,x
sta_no_ang_velocity:
 inc scene_timeline_entry
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bcc sta_object_loop
 rts
.endif

poll_space:
.if SCENE_TIMELINE_ENABLE != 0
 jsr scene_timeline_poll_reset
.else
.if LIGHT_PULSE_ON_SPACE != 0
 lda #$7f
 sta $dc00
 lda $dc01
 and #$10
 bne ps_released
 lda space_latch
 bne ps_done
 lda #$01
 sta space_latch
 lda light_pulse_enabled
 eor #$01
 sta light_pulse_enabled
 bne ps_pulse_started
 jmp ps_done
ps_pulse_started:
 lda #$00
 sta light_phase
 sta light_tick
 jmp ps_done
ps_released:
 lda #$00
 sta space_latch
ps_done:
 lda #$ff
 sta $dc00
.else
.if SCENE_OBJECT_COUNT = 0
.if MESH_COUNT != 1
 lda #$7f
 sta $dc00
 lda $dc01
 and #$10
 bne ps_released
 lda space_latch
 bne ps_done
 lda #$01
 sta space_latch
 jsr advance_active_mesh
 jmp ps_done
ps_released:
 lda #$00
 sta space_latch
ps_done:
 lda #$ff
 sta $dc00
.endif
.endif
.endif
.endif
 rts

.if FPS_OVERLAY_ENABLE != 0
poll_fps_key:
 jsr scan_fps_key
 cmp #$ff
 beq pfk_released
 lda fps_latch
 bne pfk_done
 lda fps_overlay_visible
 eor #$01
 sta fps_overlay_visible
 lda #$01
 sta fps_latch
 lda #$00
 sta irq_phase
 jsr fps_update_digits
 jsr switch_frame_barrier
 jmp pfk_done
pfk_released:
 lda #$00
 sta fps_latch
pfk_done:
 rts

scan_fps_key:
 lda #$fb
 sta $dc00
 lda $dc01
 and #$20
 beq sfk_pressed
 lda #$ff
 sta $dc00
 rts
sfk_pressed:
 lda #$ff
 sta $dc00
 lda #$00
 rts
.endif

poll_control_keys:
.if CONTROL_RETURN_KEY != 0
 jsr poll_return_motion_key
.endif
.if CONTROL_ZERO_MOTION_KEY != 0
 jsr poll_zero_motion_key
.endif
.if CONTROL_LOWRES_KEY != 0
 jsr scan_lowres_key
 cmp #$ff
 beq pcl_lowres_released
 lda lowres_latch
 bne pcl_after_lowres
 lda lowres_scanline_enabled
 clc
 adc #$01
 cmp #$03
 bcc pcl_lowres_store
 lda #$00
pcl_lowres_store:
 sta lowres_scanline_enabled
 lda #$01
 sta lowres_latch
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq pcl_lowres_full_barrier
 jsr lowres_trace_barrier
 jmp pcl_lowres_barrier_done
pcl_lowres_full_barrier:
 jsr switch_frame_barrier
pcl_lowres_barrier_done:
.else
 jsr switch_frame_barrier
.endif
 jsr fps_update_digits
 jmp pcl_after_lowres
pcl_lowres_released:
 lda #$00
 sta lowres_latch
pcl_after_lowres:
.endif
.if CONTROL_LIGHT_KEY != 0
 jsr scan_light_key
 cmp #$ff
 beq pcl_light_released
 lda light_latch
 bne pcl_after_light
 lda light_pause
 eor #$01
 sta light_pause
 lda #$01
 sta light_latch
 jmp pcl_after_light
pcl_light_released:
 lda #$00
 sta light_latch
pcl_after_light:
.endif
.if CONTROL_ROTATION_KEY != 0
 jsr scan_rotation_key
 cmp #$ff
 beq pcl_rotation_released
 lda rotation_latch
 bne pcl_done
 lda rotation_pause
 eor #$01
 sta rotation_pause
 lda #$01
 sta rotation_latch
 rts
pcl_rotation_released:
 lda #$00
 sta rotation_latch
.endif
pcl_done:
 rts

poll_return_motion_key:
.if MOTION_Z_START_ON_RETURN != 0 && CONTROL_RETURN_KEY != 0
 jsr scan_return_key
 cmp #$ff
 beq prmk_return_released
 lda return_latch
 bne prmk_done
 lda #$01
 sta return_latch
 sta motion_z_enabled
 rts
prmk_return_released:
 lda #$00
 sta return_latch
prmk_done:
.endif
 rts

poll_zero_motion_key:
.if MOTION_Z_START_ON_ZERO != 0 && CONTROL_ZERO_MOTION_KEY != 0
 jsr scan_zero_motion_key
 cmp #$ff
 beq pzmk_done
 lda #$01
 sta motion_z_enabled
pzmk_done:
.endif
 rts

scan_return_key:
.if CONTROL_RETURN_KEY != 0
 lda #$fe
 sta $dc00
 lda $dc01
 and #$02
 beq srtn_pressed
 lda #$ff
 sta $dc00
 rts
srtn_pressed:
 lda #$ff
 sta $dc00
 lda #$00
.endif
 rts

scan_zero_motion_key:
.if CONTROL_ZERO_MOTION_KEY != 0
 lda #$ef
 sta $dc00
 lda $dc01
 and #$08
 beq szmk_pressed
 lda #$ff
 sta $dc00
 rts
szmk_pressed:
 lda #$ff
 sta $dc00
 lda #$00
.endif
 rts

scan_light_key:
.if CONTROL_LIGHT_KEY != 0
 lda #$df
 sta $dc00
 lda $dc01
 and #$04
 beq slk_pressed
 lda #$ff
 sta $dc00
 rts
slk_pressed:
 lda #$ff
 sta $dc00
 lda #$00
.endif
 rts

scan_rotation_key:
.if CONTROL_ROTATION_KEY != 0
 lda #$fb
 sta $dc00
 lda $dc01
 and #$02
 beq srk_pressed
 lda #$ff
 sta $dc00
 rts
srk_pressed:
 lda #$ff
 sta $dc00
 lda #$00
.endif
 rts

.if CONTROL_LOWRES_KEY != 0
scan_lowres_key:
 lda #$f7
 sta $dc00
 lda $dc01
 and #$20
 beq slrk_pressed
 lda #$ff
 sta $dc00
 rts
slrk_pressed:
 lda #$ff
 sta $dc00
 lda #$00
 rts
.endif

poll_material_keys:
.if CONTROL_MATERIAL_KEYS != 0
 jsr scan_material_key
 cmp #$ff
 bne pm_key_down
 lda #$00
 sta material_latch
 rts
pm_key_down:
 ldx material_latch
 bne pm_done
 cmp active_material
 beq pm_latch_only
 sta active_material
 lda #$01
 sta material_latch
 jsr apply_active_material
 rts
pm_latch_only:
 lda #$01
 sta material_latch
pm_done:
.endif
 rts

poll_reflectivity_keys:
.if CONTROL_REFLECTIVITY_KEYS != 0
 jsr scan_reflectivity_key
 cmp #$ff
 bne prk_key_down
 lda #$00
 sta reflect_latch
 rts
prk_key_down:
 ldx reflect_latch
 bne prk_done
 lda #$01
 sta reflect_latch
 clc
 lda active_reflect_offset
 adc #$0a
 cmp #$28
 bcc prk_store
 lda #$00
prk_store:
 sta active_reflect_offset
 jsr apply_active_material
 rts
prk_done:
.endif
 rts

scan_reflectivity_key:
.if CONTROL_REFLECTIVITY_KEYS != 0
 ; R key: matrix column 2, row 1. CONTROL_ROTATION_KEY is disabled in
 ; interactive-reflectivity builds so the key has a single owner.
 lda #$fb
 sta $dc00
 lda $dc01
 and #$02
 beq sref_pressed
 lda #$ff
 sta $dc00
 rts
sref_pressed:
 lda #$ff
 sta $dc00
 lda #$00
.endif
 rts

scan_material_key:
.if CONTROL_MATERIAL_KEYS != 0
 lda #$7f
 sta $dc00
 lda $dc01
 sta t1
 and #$01
 beq smk_key_1
 lda t1
 and #$08
 beq smk_key_2
 lda #$fd
 sta $dc00
 lda $dc01
 sta t1
 and #$01
 beq smk_key_3
 lda t1
 and #$08
 beq smk_key_4
 lda #$fb
 sta $dc00
 lda $dc01
 sta t1
 and #$01
 beq smk_key_5
 lda t1
 and #$08
 beq smk_key_6
 lda #$f7
 sta $dc00
 lda $dc01
 sta t1
 and #$01
 beq smk_key_7
 lda t1
 and #$08
 beq smk_key_8
 lda #$ef
 sta $dc00
 lda $dc01
 sta t1
 and #$01
 beq smk_key_9
 lda t1
 and #$08
 beq smk_key_0
 lda #$ff
 sta $dc00
 lda #$ff
 rts
smk_key_1:
 lda #$00
 jmp smk_found
smk_key_2:
 lda #$01
 jmp smk_found
smk_key_3:
 lda #$02
 jmp smk_found
smk_key_4:
 lda #$03
 jmp smk_found
smk_key_5:
 lda #$04
 jmp smk_found
smk_key_6:
 lda #$05
 jmp smk_found
smk_key_7:
 lda #$06
 jmp smk_found
smk_key_8:
 lda #$07
 jmp smk_found
smk_key_9:
 lda #$08
 jmp smk_found
smk_key_0:
.if CONTROL_ZERO_MOTION_KEY != 0
 lda #$ff
.else
 lda #$09
.endif
smk_found:
 pha
 lda #$ff
 sta $dc00
 pla
.endif
 rts

; DEV7 split-screen ownership contract:
; Header Screen RAM ($000-$077 / 120 bytes) belongs to the text layer.
; Body Screen RAM   ($078-$3E7 / 880 bytes) belongs to the material system.
apply_active_material:
 lda active_reflect_offset
 sta material_reflect_offset_cur
 clc
 adc active_material
 tay
 lda material_screen_bytes,y
 sta t1
 lda material_color_bytes,y
 sta t2
.if FPS_OVERLAY_ENABLE != 0
 ldx #TEXT_HEADER_SCREEN_BYTES
aam_screen_page0:
 lda t1
 sta $5c00,x
 sta SCREEN_B_BASE,x
 lda t2
 sta $d800,x
 inx
 bne aam_screen_page0

 ldx #$00
aam_screen_pages12:
 lda t1
 sta $5d00,x
 sta $5e00,x
 sta SCREEN_B_BASE+$0100,x
 sta SCREEN_B_BASE+$0200,x
 lda t2
 sta $d900,x
 sta $da00,x
 inx
 bne aam_screen_pages12

 ldx #$00
aam_screen_tail:
 lda t1
 sta $5f00,x
 sta SCREEN_B_BASE+$0300,x
 lda t2
 sta $db00,x
 inx
 cpx #$e8
 bne aam_screen_tail
 rts
.else
 ldx #$00
aam_screen:
 lda t1
 sta $5c00,x
 sta $5d00,x
 sta $5e00,x
 sta $5f00,x
 sta SCREEN_B_BASE,x
 sta SCREEN_B_BASE+$0100,x
 sta SCREEN_B_BASE+$0200,x
 sta SCREEN_B_BASE+$0300,x
 lda t2
 sta $d800,x
 sta $d900,x
 sta $da00,x
 sta $db00,x
 inx
 bne aam_screen
 rts
.endif

.if FACE_SOLID_COLOR_ENABLE != 0
load_face_solid_color_y:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy faceidx
.endif
 lda face_solid_color,y
 cmp #$ff
 beq lfsc_default
 sta material_color_cur
.if ENGINE_MODE3_ADAPTIVE_SCREEN_PAIR_LAYOUT != 0
 ; Adaptive mode3 layout: explicit face color occupies both Screen RAM
 ; object slots, so masked edge writes cannot expose a second pigment.
 ; Slot 11 remains the fixed ground color in global Color RAM.
 sta t1
 asl
 asl
 asl
 asl
 ora t1
 sta material_screen_cur
 lda #WORLD_GROUND_COLOR_RAM
 sta material_color_cur
 lda #$aa
 sta fillbyte
.else
.if ENGINE_MODE3_STABLE_GROUND_CELL_LAYOUT != 0
 ; Exact shared-ramp layout: slot 01 keeps the ground and slot 11 holds
 ; the shared object highlight in Color RAM.
 lda #WORLD_GROUND_SCREEN_BYTE
.else
 lda #$00
.endif
 sta material_screen_cur
 lda #$ff
 sta fillbyte
.endif
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 sec
 rts
lfsc_default:
 lda #MATERIAL_SCREEN_BYTE
 sta material_screen_cur
 lda #MATERIAL_COLOR_RAM
 sta material_color_cur
 lda #$aa
 sta fillbyte
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 clc
 rts
.endif

.if POLY_FILL_ENABLE != 0
load_face_reflectivity_y:
.if SCENE_INSTANCE_OVERRIDES != 0 && SCENE_INSTANCE_REFLECT_ALL_PINNED != 0
 ldx objidx
 lda object_reflectivity_override,x
.else
.if SCENE_INSTANCE_OVERRIDES != 0
 ldx objidx
 lda object_reflectivity_override,x
 cmp #$ff
 bne lfr_done
.endif
.if FACE_REFLECTIVITY_ACTIVE_ONLY != 0
 lda active_reflect_offset
.else
 lda face_reflect_offset,y
 cmp #$ff
 bne lfr_done
 lda active_reflect_offset
lfr_done:
.endif
.endif
 sta material_reflect_offset_cur
 rts

load_face_material:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy faceidx
.else
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
.endif
 jsr load_face_reflectivity_y
.if SCENE_INSTANCE_OVERRIDES != 0 && SCENE_INSTANCE_MATERIAL_ALL_PINNED != 0 && SCENE_FACE_MATERIAL_OVERRIDE = 0
 ldx objidx
 lda object_material_override,x
.else
.if SCENE_INSTANCE_OVERRIDES != 0
.if SCENE_FACE_MATERIAL_OVERRIDE != 0
 lda face_material_explicit,y
 cmp #$ff
 bne lfm_fixed
 ldx objidx
 lda object_material_override,x
 cmp #$ff
 bne lfm_fixed
.else
 ldx objidx
 lda object_material_override,x
 cmp #$ff
 bne lfm_fixed
.endif
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != 0
 lda active_material
.else
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy faceidx
.else
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
.endif
 lda face_material,y
 cmp #$ff
 bne lfm_fixed
 lda active_material
lfm_fixed:
.endif
.endif
 clc
 adc material_reflect_offset_cur
 tay
 lda material_screen_bytes,y
 sta material_screen_cur
 lda material_color_bytes,y
 sta material_color_cur
.if SCENE_INSTANCE_COLOR_OVERRIDE != 0
 ldx objidx
 lda object_color_override,x
 cmp #$ff
 beq lfm_color_done
 sta material_color_cur
lfm_color_done:
.endif
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 rts
.endif

apply_material_span_a:
 ldx yrow
 lda screenrowlo_a,x
 clc
 adc startbyte
 sta ptr0lo
 lda screenrowhi_a,x
 adc #$00
 sta ptr0hi
 lda colorrowlo,x
 clc
 adc startbyte
 sta ptr1lo
 lda colorrowhi,x
 adc #$00
 sta ptr1hi
 jmp apply_material_span_common

apply_material_span_b:
 ldx yrow
 lda screenrowlo_b,x
 clc
 adc startbyte
 sta ptr0lo
 lda screenrowhi_b,x
 adc #$00
 sta ptr0hi
 lda colorrowlo,x
 clc
 adc startbyte
 sta ptr1lo
 lda colorrowhi,x
 adc #$00
 sta ptr1hi

apply_material_span_common:
 ldx startbyte
 ldy #$00
ams_loop:
.if VIC_COLOR_POLICY_ENABLE != 0
 jsr vic_color_policy_claim_cell
 bcc ams_skip_write
.endif
 lda material_screen_cur
 sta (ptr0lo),y
 lda material_color_cur
 sta (ptr1lo),y
ams_skip_write:
 cpx endbyte
 beq ams_done
 inc ptr0lo
 bne ams_screen_ok
 inc ptr0hi
ams_screen_ok:
 inc ptr1lo
 bne ams_color_ok
 inc ptr1hi
ams_color_ok:
 inx
 jmp ams_loop
ams_done:
 rts


.if MATERIAL_CELL_SPAN_CACHE != 0
maybe_apply_material_span_a:
.if ENGINE_MODE3_MATERIAL_CELL_TRANSITION != 0
 lda yrow
 and #$fc
.else
 lda yrow
 lsr
 lsr
.endif
 cmp material_last_cellrow
 beq mas_a_same_cell
 sta material_last_cellrow
 lda startbyte
 sta material_cell_min
 lda endbyte
 sta material_cell_max
 jmp apply_material_span_a
mas_a_same_cell:
 lda startbyte
 cmp material_cell_min
 bcc mas_a_left_needed
 lda material_cell_max
 cmp endbyte
 bcc mas_a_right_only
mas_a_skip:
 rts
mas_a_left_needed:
 lda startbyte
 sta material_span_orig_start
 lda endbyte
 sta material_span_orig_end
 lda material_span_orig_start
 sta startbyte
 lda material_cell_min
 sec
 sbc #$01
 sta endbyte
 lda material_span_orig_start
 sta material_cell_min
 jsr apply_material_span_a
mas_a_left_done:
 lda material_cell_max
 cmp material_span_orig_end
 bcc mas_a_right_needed
 jmp material_span_restore_original
mas_a_right_only:
 lda startbyte
 sta material_span_orig_start
 lda endbyte
 sta material_span_orig_end
mas_a_right_needed:
 lda material_cell_max
 clc
 adc #$01
 sta startbyte
 lda material_span_orig_end
 sta endbyte
 sta material_cell_max
 jsr apply_material_span_a
 jmp material_span_restore_original

maybe_apply_material_span_b:
.if ENGINE_MODE3_MATERIAL_CELL_TRANSITION != 0
 lda yrow
 and #$fc
.else
 lda yrow
 lsr
 lsr
.endif
 cmp material_last_cellrow
 beq mas_b_same_cell
 sta material_last_cellrow
 lda startbyte
 sta material_cell_min
 lda endbyte
 sta material_cell_max
 jmp apply_material_span_b
mas_b_same_cell:
 lda startbyte
 cmp material_cell_min
 bcc mas_b_left_needed
 lda material_cell_max
 cmp endbyte
 bcc mas_b_right_only
mas_b_skip:
 rts
mas_b_left_needed:
 lda startbyte
 sta material_span_orig_start
 lda endbyte
 sta material_span_orig_end
 lda material_span_orig_start
 sta startbyte
 lda material_cell_min
 sec
 sbc #$01
 sta endbyte
 lda material_span_orig_start
 sta material_cell_min
 jsr apply_material_span_b
mas_b_left_done:
 lda material_cell_max
 cmp material_span_orig_end
 bcc mas_b_right_needed
 jmp material_span_restore_original
mas_b_right_only:
 lda startbyte
 sta material_span_orig_start
 lda endbyte
 sta material_span_orig_end
mas_b_right_needed:
 lda material_cell_max
 clc
 adc #$01
 sta startbyte
 lda material_span_orig_end
 sta endbyte
 sta material_cell_max
 jsr apply_material_span_b
material_span_restore_original:
 lda material_span_orig_start
 sta startbyte
 lda material_span_orig_end
 sta endbyte
 rts
.endif

auto_cycle_mesh:
.if AUTO_CYCLE_FRAMES != 0
.if MESH_COUNT != 1
 inc auto_cycle_counter
 lda auto_cycle_counter
 cmp #AUTO_CYCLE_FRAMES
 bcc acm_done
 jsr advance_active_mesh
acm_done:
.endif
.endif
 rts

switch_frame_barrier:
 jsr clear_bitmap_buffers
 jsr reset_dirty_clean
.if MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = 0
 jsr reset_depth_full
.endif
.if STANDARD_PROJECT_VERTEX != 0
 jsr reset_smooth_history
.endif
.if CONTROL_LOWRES_KEY != 0
 lda #$00
 sta lowres_scanline_parity
 sta lowres_parity_a
 sta lowres_parity_b
.endif
 rts

.if LOWRES_TRACE_ENABLE != 0
lowres_trace_barrier:
 lda #$00
 sta lowres_scanline_parity
 sta lowres_parity_a
 sta lowres_parity_b
 rts
.endif

.if STANDARD_PROJECT_VERTEX != 0
reset_smooth_history:
 ldx #$00
 lda #$00
rsh_loop:
 sta smooth_ready,x
 inx
 cpx #VERT_COUNT
 bne rsh_loop
 rts
.endif

reset_dirty_clean:
 ldx #$00
 lda #$ff
rdc_min_loop:
 sta dirtymin_a,x
 sta dirtymin_b,x
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne rdc_min_loop
 ldx #$00
 lda #$00
rdc_max_loop:
 sta dirtymax_a,x
 sta dirtymax_b,x
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne rdc_max_loop
 lda #$ff
 sta dirty_ymin_a
 sta dirty_ymin_b
 lda #$00
 sta dirty_ymax_a
 sta dirty_ymax_b
 rts

.if MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = 0
reset_depth_full:
.if FACE_RENDER_ENABLE != 0
 ldx #$00
 lda #$ff
rdf_bucket_loop:
 sta bucket_head,x
.if WIRE_DEPTH_SORT_ENABLE != 0
 sta wire_bucket_head,x
.endif
 inx
 bne rdf_bucket_loop
 lda #$00
 sta bucket_used_count
.if WIRE_DEPTH_SORT_ENABLE != 0
 sta wire_depth_entry_used
.endif
.if FACE_COUNT != 0
 lda #$ff
 ldx #FACE_COUNT
rdf_face_loop:
 dex
 sta face_next,x
 cpx #$00
 bne rdf_face_loop
.if STATIC_SHADE_DIRECT = 0
.if STATIC_SHADE_CACHE != 0
 ldx #FACE_COUNT
rdf_shade_loop:
 dex
 lda face_shade,x
 sta frame_face_shade,x
 cpx #$00
 bne rdf_shade_loop
.if FRAME_FACE_FILL_CACHE != 0
 ldx #FACE_COUNT
rdf_fill_loop:
 dex
 lda face_shade,x
 and #$7f
 tay
 lda shade_solid_bytes,y
 sta frame_face_fill,x
 cpx #$00
 bne rdf_fill_loop
.endif
.else
 lda #$00
 ldx #FACE_COUNT
rdf_shade_loop:
 dex
 sta frame_face_shade,x
 cpx #$00
 bne rdf_shade_loop
.if MODE4_SHADE_STEP_LIMIT != 0
 lda #$ff
 ldx #FACE_COUNT
rdf_shade_step_rank_loop:
 dex
 sta mode4_shade_step_rank,x
 cpx #$00
 bne rdf_shade_step_rank_loop
.endif
.endif
.endif
.endif
.endif
 rts
.endif

show_buffer:
 lda drawbuf
 eor #$01
 sta drawbuf
 rts

init_buffers:
.if LAZY_CONVEX_BOUNDS != 0
 lda #$00
 sta bounds_stamp_cur
 jsr clear_bounds_stamp
.endif
 ldx #$00
 lda #MATERIAL_SCREEN_BYTE
ib_screen:
 sta $5c00,x
 sta $5d00,x
 sta $5e00,x
 sta $5f00,x
 sta SCREEN_B_BASE,x
 sta SCREEN_B_BASE+$0100,x
 sta SCREEN_B_BASE+$0200,x
 sta SCREEN_B_BASE+$0300,x
 inx
 bne ib_screen
 ldx #$00
 lda #MATERIAL_COLOR_RAM
ib_color:
 sta $d800,x
 sta $d900,x
 sta $da00,x
 sta $db00,x
 inx
 bne ib_color
 ldx #$00
 lda #$ff
ib_dirty_min:
 sta dirtymin_a,x
 sta dirtymin_b,x
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ib_dirty_min
 ldx #$00
 lda #$00
ib_dirty_max:
 sta dirtymax_a,x
 sta dirtymax_b,x
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ib_dirty_max
 lda #$ff
 sta dirty_ymin_a
 sta dirty_ymin_b
 lda #$00
 sta dirty_ymax_a
 sta dirty_ymax_b
.if WIRE_FACE_EDGE_ENABLE != 0
 sta wire_edge_stamp
 jsr clear_all_wire_edge_marks
.endif
 jsr clear_bitmap_buffers
 rts

.if LAZY_CONVEX_BOUNDS != 0
clear_bounds_stamp:
 lda #$00
 ldx #$00
cbs_loop:
 sta bounds_stamp,x
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne cbs_loop
 rts
.endif

clear_bitmap_buffers:
 lda #$00
 ldx #$00
ib_clear_all:
 sta $6000,x
 sta $6100,x
 sta $6200,x
 sta $6300,x
 sta $6400,x
 sta $6500,x
 sta $6600,x
 sta $6700,x
 sta $6800,x
 sta $6900,x
 sta $6a00,x
 sta $6b00,x
 sta $6c00,x
 sta $6d00,x
 sta $6e00,x
 sta $6f00,x
 sta $7000,x
 sta $7100,x
 sta $7200,x
 sta $7300,x
 sta $7400,x
 sta $7500,x
 sta $7600,x
 sta $7700,x
 sta $7800,x
 sta $7900,x
 sta $7a00,x
 sta $7b00,x
 sta $7c00,x
 sta $7d00,x
 sta $7e00,x
 sta $7f00,x
 sta BITMAP_B_BASE,x
 sta BITMAP_B_BASE+$0100,x
 sta BITMAP_B_BASE+$0200,x
 sta BITMAP_B_BASE+$0300,x
 sta BITMAP_B_BASE+$0400,x
 sta BITMAP_B_BASE+$0500,x
 sta BITMAP_B_BASE+$0600,x
 sta BITMAP_B_BASE+$0700,x
 sta BITMAP_B_BASE+$0800,x
 sta BITMAP_B_BASE+$0900,x
 sta BITMAP_B_BASE+$0a00,x
 sta BITMAP_B_BASE+$0b00,x
 sta BITMAP_B_BASE+$0c00,x
 sta BITMAP_B_BASE+$0d00,x
 sta BITMAP_B_BASE+$0e00,x
 sta BITMAP_B_BASE+$0f00,x
 sta BITMAP_B_BASE+$1000,x
 sta BITMAP_B_BASE+$1100,x
 sta BITMAP_B_BASE+$1200,x
 sta BITMAP_B_BASE+$1300,x
 sta BITMAP_B_BASE+$1400,x
 sta BITMAP_B_BASE+$1500,x
 sta BITMAP_B_BASE+$1600,x
 sta BITMAP_B_BASE+$1700,x
 sta BITMAP_B_BASE+$1800,x
 sta BITMAP_B_BASE+$1900,x
 sta BITMAP_B_BASE+$1a00,x
 sta BITMAP_B_BASE+$1b00,x
 sta BITMAP_B_BASE+$1c00,x
 sta BITMAP_B_BASE+$1d00,x
 sta BITMAP_B_BASE+$1e00,x
 sta BITMAP_B_BASE+$1f00,x
 inx
 bne ib_clear_all
 rts

.if FULL_CLEAR != 0 || CAMERA_MOVABLE != 0
clear_current_bitmap:
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq ccb_full_clear
 jmp clear_current_bitmap_lowres_trace
ccb_full_clear:
.endif
.if ENGINE_CAMERA_VIEWPORT_CLEAR_LIMITED != 0
 lda drawbuf
 bne ccb_viewport_b
ccb_viewport_a:
 ldx #$00
ccb_viewport_a_row:
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 jsr clear_camera_viewport_bitmap_row
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ccb_viewport_a_row
 rts
ccb_viewport_b:
 ldx #$00
ccb_viewport_b_row:
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
 jsr clear_camera_viewport_bitmap_row
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ccb_viewport_b_row
 rts
.endif
 lda drawbuf
 bne ccb_b
ccb_a:
 lda #$00
 ldx #$00
ccb_a_loop:
 sta $6000,x
 sta $6100,x
 sta $6200,x
 sta $6300,x
 sta $6400,x
 sta $6500,x
 sta $6600,x
 sta $6700,x
 sta $6800,x
 sta $6900,x
 sta $6a00,x
 sta $6b00,x
 sta $6c00,x
 sta $6d00,x
 sta $6e00,x
 sta $6f00,x
 sta $7000,x
 sta $7100,x
 sta $7200,x
 sta $7300,x
 sta $7400,x
 sta $7500,x
 sta $7600,x
 sta $7700,x
 sta $7800,x
 sta $7900,x
 sta $7a00,x
 sta $7b00,x
 sta $7c00,x
 sta $7d00,x
 sta $7e00,x
 sta $7f00,x
 inx
 bne ccb_a_loop
 rts
ccb_b:
 lda #$00
 ldx #$00
ccb_b_loop:
 sta BITMAP_B_BASE,x
 sta BITMAP_B_BASE+$0100,x
 sta BITMAP_B_BASE+$0200,x
 sta BITMAP_B_BASE+$0300,x
 sta BITMAP_B_BASE+$0400,x
 sta BITMAP_B_BASE+$0500,x
 sta BITMAP_B_BASE+$0600,x
 sta BITMAP_B_BASE+$0700,x
 sta BITMAP_B_BASE+$0800,x
 sta BITMAP_B_BASE+$0900,x
 sta BITMAP_B_BASE+$0a00,x
 sta BITMAP_B_BASE+$0b00,x
 sta BITMAP_B_BASE+$0c00,x
 sta BITMAP_B_BASE+$0d00,x
 sta BITMAP_B_BASE+$0e00,x
 sta BITMAP_B_BASE+$0f00,x
 sta BITMAP_B_BASE+$1000,x
 sta BITMAP_B_BASE+$1100,x
 sta BITMAP_B_BASE+$1200,x
 sta BITMAP_B_BASE+$1300,x
 sta BITMAP_B_BASE+$1400,x
 sta BITMAP_B_BASE+$1500,x
 sta BITMAP_B_BASE+$1600,x
 sta BITMAP_B_BASE+$1700,x
 sta BITMAP_B_BASE+$1800,x
 sta BITMAP_B_BASE+$1900,x
 sta BITMAP_B_BASE+$1a00,x
 sta BITMAP_B_BASE+$1b00,x
 sta BITMAP_B_BASE+$1c00,x
 sta BITMAP_B_BASE+$1d00,x
 sta BITMAP_B_BASE+$1e00,x
 sta BITMAP_B_BASE+$1f00,x
 inx
 bne ccb_b_loop
 rts

.if ENGINE_CAMERA_VIEWPORT_CLEAR_LIMITED != 0
clear_camera_viewport_bitmap_row:
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr0lo
 bcc ccvbr_ptr0_origin_ok
 inc ptr0hi
ccvbr_ptr0_origin_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr1lo
 bcc ccvbr_ptr1_origin_ok
 inc ptr1hi
ccvbr_ptr1_origin_ok:
 lda #CAMERA_VIEWPORT_CELL_WIDTH
 sta p1lo
ccvbr_loop:
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc ccvbr_ptr0_ok
 inc ptr0hi
ccvbr_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc ccvbr_ptr1_ok
 inc ptr1hi
ccvbr_ptr1_ok:
 dec p1lo
 bne ccvbr_loop
 rts
.endif

.endif

.if TRACK_DIRTY_SPANS != 0
clear_dirty:
 lda drawbuf
 bne clear_dirty_b
clear_dirty_a:
 lda dirty_ymin_a
 cmp #$ff
 bne cd_a_go
 rts
cd_a_go:
 sta yrow
 lda dirty_ymax_a
 sta maxrow
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 bne cd_a_row
.endif
cd_a_reset_dirty:
 lda #$ff
 sta dirty_ymin_a
 lda #$00
 sta dirty_ymax_a
cd_a_row:
 ldx yrow
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq cd_a_parity_ok
 jsr lowres_row_selected
 bne cd_a_next
.endif
cd_a_parity_ok:
 lda dirtymin_a,x
 cmp #$ff
 beq cd_a_next
 sta startbyte
 lda dirtymax_a,x
 sta endbyte
 lda #$ff
 sta dirtymin_a,x
 lda #$00
 sta dirtymax_a,x
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 stx yrow
 ldx startbyte
 lda row0lo
 clc
 adc byteofflo,x
 sta ptr0lo
 lda row0hi
 adc byteoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc byteofflo,x
 sta ptr1lo
 lda row1hi
 adc byteoffhi,x
 sta ptr1hi
 lda endbyte
 sec
 sbc startbyte
 clc
 adc #$01
 sta fullcount
 cmp #$05
 bcs cd_a_long
 tax
 lda #$00
 cpx #$01
 beq cd_a_clear1
 cpx #$02
 beq cd_a_clear2
 cpx #$03
 beq cd_a_clear3
cd_a_clear4:
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_a_clear3:
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_a_clear2:
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_a_clear1:
 ldy #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp cd_a_next
cd_a_long:
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq cd_a_odd_check
cd_a_pair_loop:
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc cd_a_p0_ok
 inc ptr0hi
cd_a_p0_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc cd_a_p1_ok
 inc ptr1hi
cd_a_p1_ok:
 dec p1lo
 bne cd_a_pair_loop
cd_a_odd_check:
 lda p1hi
 beq cd_a_next
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_a_next:
 lda yrow
 cmp maxrow
 beq cd_done
 inc yrow
 jmp cd_a_row

clear_dirty_b:
 lda dirty_ymin_b
 cmp #$ff
 bne cd_b_go
 rts
cd_b_go:
 sta yrow
 lda dirty_ymax_b
 sta maxrow
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 bne cd_b_row
.endif
cd_b_reset_dirty:
 lda #$ff
 sta dirty_ymin_b
 lda #$00
 sta dirty_ymax_b
cd_b_row:
 ldx yrow
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq cd_b_parity_ok
 jsr lowres_row_selected
 bne cd_b_next
.endif
cd_b_parity_ok:
 lda dirtymin_b,x
 cmp #$ff
 beq cd_b_next
 sta startbyte
 lda dirtymax_b,x
 sta endbyte
 lda #$ff
 sta dirtymin_b,x
 lda #$00
 sta dirtymax_b,x
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
 stx yrow
 ldx startbyte
 lda row0lo
 clc
 adc byteofflo,x
 sta ptr0lo
 lda row0hi
 adc byteoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc byteofflo,x
 sta ptr1lo
 lda row1hi
 adc byteoffhi,x
 sta ptr1hi
 lda endbyte
 sec
 sbc startbyte
 clc
 adc #$01
 sta fullcount
 cmp #$05
 bcs cd_b_long
 tax
 lda #$00
 cpx #$01
 beq cd_b_clear1
 cpx #$02
 beq cd_b_clear2
 cpx #$03
 beq cd_b_clear3
cd_b_clear4:
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_b_clear3:
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_b_clear2:
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_b_clear1:
 ldy #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp cd_b_next
cd_b_long:
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq cd_b_odd_check
cd_b_pair_loop:
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc cd_b_p0_ok
 inc ptr0hi
cd_b_p0_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc cd_b_p1_ok
 inc ptr1hi
cd_b_p1_ok:
 dec p1lo
 bne cd_b_pair_loop
cd_b_odd_check:
 lda p1hi
 beq cd_b_next
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
cd_b_next:
 lda yrow
 cmp maxrow
 beq cd_done
 inc yrow
 jmp cd_b_row
cd_done:
 rts
.endif

prepare_angles:
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_object_matrix
 jsr build_coord_terms
 jmp prepare_angles_after_terms

prepare_object_matrix:
.endif
 ldx angx
 lda angx_lo
 jsr interp_sintab
 sta sinxv
 lda angx
 clc
 adc #$40
 tax
 lda angx_lo
 jsr interp_sintab
 sta cosxv
 ldx angy
 lda angy_lo
 jsr interp_sintab
 sta sinyv
 lda angy
 clc
 adc #$40
 tax
 lda angy_lo
 jsr interp_sintab
 sta cosyv
 ldx angz
 lda angz_lo
 jsr interp_sintab
 sta sinzv
 lda angz
 clc
 adc #$40
 tax
 lda angz_lo
 jsr interp_sintab
 sta coszv
 jsr prepare_matrix
.if SCENE_OBJECT_COUNT != 0
.if SCENE_OBJECT_SCALE_ACTIVE != 0
 jsr apply_object_scale_to_matrix
.endif
.endif
.if EXPLORER_MATRIX_FOLD != 0
 rts
.endif
 jsr build_coord_terms
prepare_angles_after_terms:
.if DYNAMIC_LIGHT != 0
.if SCENE_OBJECT_COUNT != 0
.if SCENE_OBJECT_SCALE_ACTIVE != 0
 lda obj_scale_cur
 cmp #$40
 beq prepare_angles_done
 jsr prepare_matrix
prepare_angles_done:
.endif
.endif
.endif
 rts

.if MODE4_OBJECT_LIGHT_CACHE != 0
prepare_object_light_for_shade:
 ldx light_phase
 lda light_pos_x,x
.if SCENE_OBJECT_X_ACTIVE != 0
 sec
 sbc obj_pos_x_cur
.endif
 sta rx0
 lda light_pos_y,x
.if SCENE_OBJECT_Y_ACTIVE != 0
 sec
 sbc obj_pos_y_cur
.endif
 sta ry0
 lda light_pos_z,x
 sec
 sbc obj_depth_lo
 sta rz0

 lda rx0
 ldx m00
 jsr mul_s6
 sta sh_nx
 lda ry0
 ldx m10
 jsr mul_s6
 ldx sh_nx
 jsr add_s8_sat
 sta sh_nx
 lda rz0
 ldx m20
 jsr mul_s6
 ldx sh_nx
 jsr add_s8_sat
 sta sh_nx

 lda rx0
 ldx m01
 jsr mul_s6
 sta sh_ny
 lda ry0
 ldx m11
 jsr mul_s6
 ldx sh_ny
 jsr add_s8_sat
 sta sh_ny
 lda rz0
 ldx m21
 jsr mul_s6
 ldx sh_ny
 jsr add_s8_sat
 sta sh_ny

 lda rx0
 ldx m02
 jsr mul_s6
 sta sh_nz
 lda ry0
 ldx m12
 jsr mul_s6
 ldx sh_nz
 jsr add_s8_sat
 sta sh_nz
 lda rz0
 ldx m22
 jsr mul_s6
 ldx sh_nz
 jsr add_s8_sat
 sta sh_nz
 rts
.endif

interp_sintab:
 sta p1lo
 lda sintab,x
 sta p1hi
 inx
 lda sintab,x
 sec
 sbc p1hi
 beq is_done
 bmi is_neg
 cmp #$02
 beq is_pos2
 lda p1lo
 bpl is_done
 inc p1hi
 jmp is_done
is_pos2:
 lda p1lo
 cmp #$40
 bcc is_done
 inc p1hi
 lda p1lo
 cmp #$c0
 bcc is_done
 inc p1hi
 jmp is_done
is_neg:
 cmp #$ff
 beq is_neg1
 lda p1lo
 cmp #$40
 bcc is_done
 dec p1hi
 lda p1lo
 cmp #$c0
 bcc is_done
 dec p1hi
 jmp is_done
is_neg1:
 lda p1lo
 bpl is_done
 dec p1hi
is_done:
 lda p1hi
 rts

prepare_matrix:
 lda sinxv
 ldx sinyv
 jsr mul_s6
 sta t1
 lda cosxv
 ldx sinyv
 jsr mul_s6
 sta t2
 lda cosyv
 ldx coszv
 jsr mul_s6
 sta m00
 lda cosyv
 ldx sinzv
 jsr mul_s6
 sta m10
 lda sinyv
 eor #$ff
 clc
 adc #$01
 sta m20
 lda sinxv
 ldx cosyv
 jsr mul_s6
 sta m21
 lda cosxv
 ldx cosyv
 jsr mul_s6
 sta m22
 lda cosxv
 ldx sinzv
 jsr mul_s6
 sta p1lo
 lda t1
 ldx coszv
 jsr mul_s6
 sec
 sbc p1lo
 sta m01
 lda sinxv
 ldx sinzv
 jsr mul_s6
 sta p1lo
 lda t2
 ldx coszv
 jsr mul_s6
 clc
 adc p1lo
 sta m02
 lda cosxv
 ldx coszv
 jsr mul_s6
 sta p1lo
 lda t1
 ldx sinzv
 jsr mul_s6
 clc
 adc p1lo
 sta m11
 lda sinxv
 ldx coszv
 jsr mul_s6
 sta p1lo
 lda t2
 ldx sinzv
 jsr mul_s6
 sec
 sbc p1lo
 sta m12
 rts

apply_object_scale_to_matrix:
.if SCENE_OBJECT_COUNT != 0
 lda m00
 ldx obj_scale_cur
 jsr mul_s6
 sta m00
 lda m01
 ldx obj_scale_cur
 jsr mul_s6
 sta m01
 lda m02
 ldx obj_scale_cur
 jsr mul_s6
 sta m02
 lda m10
 ldx obj_scale_cur
 jsr mul_s6
 sta m10
 lda m11
 ldx obj_scale_cur
 jsr mul_s6
 sta m11
 lda m12
 ldx obj_scale_cur
 jsr mul_s6
 sta m12
 lda m20
 ldx obj_scale_cur
 jsr mul_s6
 sta m20
 lda m21
 ldx obj_scale_cur
 jsr mul_s6
 sta m21
 lda m22
 ldx obj_scale_cur
 jsr mul_s6
 sta m22
.endif
 rts

build_coord_terms:
 ldy #$00
bct_x_loop:
 lda xcoord,y
 ldx m00
 jsr mul_s6
 sta x_m00,y
 lda xcoord,y
 ldx m10
 jsr mul_s6
 sta x_m10,y
 lda xcoord,y
 ldx m20
 jsr mul_s6
 sta x_m20,y
 iny
 cpy #XCOORD_COUNT
 bne bct_x_loop
 ldy #$00
bct_y_loop:
 lda ycoord,y
 ldx m01
 jsr mul_s6
 sta y_m01,y
 lda ycoord,y
 ldx m11
 jsr mul_s6
 sta y_m11,y
 lda ycoord,y
 ldx m21
 jsr mul_s6
 sta y_m21,y
 iny
 cpy #YCOORD_COUNT
 bne bct_y_loop
 ldy #$00
bct_z_loop:
 lda zcoord,y
 ldx m02
 jsr mul_s6
 sta z_m02,y
 lda zcoord,y
 ldx m12
 jsr mul_s6
 sta z_m12,y
 lda zcoord,y
 ldx m22
 jsr mul_s6
 sta z_m22,y
 iny
 cpy #ZCOORD_COUNT
 bne bct_z_loop
 rts

; Convert signed geometric camera depth in p1 to the non-zero unsigned
; physical projection-table index.  Negative inputs that remain <= 0 after
; the origin shift clamp to 1, so no table lookup can wrap or underflow.
projection_depth_index_from_p1:
 lda p1hi
 bmi pdifp_negative_source
 clc
 lda p1lo
 adc #PROJ_VIEW_DEPTH_BIAS
 sta p1lo
 lda p1hi
 adc #PROJ_VIEW_DEPTH_BIAS_HI
 sta p1hi
 rts
pdifp_negative_source:
 clc
 lda p1lo
 adc #PROJ_VIEW_DEPTH_BIAS
 sta p1lo
 lda p1hi
 adc #PROJ_VIEW_DEPTH_BIAS_HI
 sta p1hi
 bmi pdifp_clamp_one
 lda p1lo
 ora p1hi
 bne pdifp_done
pdifp_clamp_one:
 lda #$01
 sta p1lo
 lda #$00
 sta p1hi
pdifp_done:
 rts

load_projection_table_index:
 ldx tmpidx
 lda camera_depth_geometric_lo,x
 sta p1lo
 lda camera_depth_geometric_hi,x
 sta p1hi
 jmp projection_depth_index_from_p1

; Exact/reference projection divides by real geometric camera depth.  Clamp
; invalid or crossing depths to the same near plane used by visibility; the
; +190 physical table origin must never enter this divisor.
clamp_projection_geometric_divisor_p1:
 lda p1hi
 bmi cpgdp_clamp_near
 bne cpgdp_done
 lda p1lo
 cmp #PROJ_CAMERA_FACE_MIN_DEPTH
 bcs cpgdp_done
cpgdp_clamp_near:
 lda #PROJ_CAMERA_FACE_MIN_DEPTH
 sta p1lo
 lda #$00
 sta p1hi
cpgdp_done:
 rts

load_projection_geometric_divisor:
 ldx tmpidx
 lda camera_depth_geometric_lo,x
 sta p1lo
 lda camera_depth_geometric_hi,x
 sta p1hi
 jmp clamp_projection_geometric_divisor_p1

.if CAMERA_MOVABLE != 0
explorer_init_camera:
 lda #EXPLORER_CAMERA_X_LO
 sta explorer_cam_x_lo
 lda #EXPLORER_CAMERA_X_HI
 sta explorer_cam_x_hi
 lda #EXPLORER_CAMERA_X_EXT
 sta explorer_cam_x_ext
 lda #EXPLORER_CAMERA_Y_LO
 sta explorer_cam_y_lo
 lda #EXPLORER_CAMERA_Y_HI
 sta explorer_cam_y_hi
 lda #EXPLORER_CAMERA_Y_EXT
 sta explorer_cam_y_ext
 lda #EXPLORER_CAMERA_Z_LO
 sta explorer_cam_z_lo
 lda #EXPLORER_CAMERA_Z_HI
 sta explorer_cam_z_hi
 lda #EXPLORER_CAMERA_Z_EXT
 sta explorer_cam_z_ext
.if CAMERA_SMOOTH_DEPTH_ACTIVE != 0
 lda #CAMERA_SMOOTH_DEPTH_PHASE_START
 sta camera_smooth_depth_phase
.endif
 lda #EXPLORER_CAMERA_YAW
 sta explorer_cam_yaw
 lda #EXPLORER_CAMERA_PITCH
 sta explorer_cam_pitch
.if CAMERA_RUNTIME_CONTROLS != 0
 lda #$00
 sta explorer_yaw_repeat_phase
 sta explorer_pitch_repeat_phase
.if CAMERA_ROLL_CONTROL != 0
 sta explorer_roll_repeat_phase
.endif
.endif
.if CAMERA_ROLL_ACTIVE != 0
 lda #EXPLORER_CAMERA_ROLL
 sta explorer_cam_roll
 lda #$00
 sta explorer_look_yaw_acc_lo
 sta explorer_look_yaw_acc_hi
 sta explorer_look_pitch_acc_lo
 sta explorer_look_pitch_acc_hi
.endif
 rts

.if CAMERA_SMOOTH_DEPTH_ACTIVE != 0
advance_camera_smooth_depth_ping_pong:
 clc
 lda camera_smooth_depth_phase
 adc #CAMERA_SMOOTH_DEPTH_PHASE_STEP
 sta camera_smooth_depth_phase
 tay
 lda camera_smooth_depth_pos_lo,y
 sta explorer_cam_z_lo
 lda camera_smooth_depth_pos_hi,y
 sta explorer_cam_z_hi
 lda camera_smooth_depth_pos_ext,y
 sta explorer_cam_z_ext
 rts
.endif

explorer_scan_keys:
 lda #$fe
 sta $dc00
 lda $dc01
 sta explorer_key_col0
 lda #$fd
 sta $dc00
 lda $dc01
 sta explorer_key_col1
 lda #$fb
 sta $dc00
 lda $dc01
 sta explorer_key_col2
.if CAMERA_ROLL_CONTROL != 0
 lda #$ef
 sta $dc00
 lda $dc01
 sta explorer_key_col4
.endif
 lda #$bf
 sta $dc00
 lda $dc01
 sta explorer_key_col6
 lda #$7f
 sta $dc00
 lda $dc01
 sta explorer_key_col7
 lda #$ff
 sta $dc00
 rts

.if CAMERA_MODE_CYCLE != 0
explorer_scan_mode_cycle_key:
 lda #$fe
 sta $dc00
 lda $dc01
 sta explorer_key_col0
 lda #$fd
 sta $dc00
 lda $dc01
 sta explorer_key_col1
 lda #$bf
 sta $dc00
 lda $dc01
 sta explorer_key_col6
 lda #$ff
 sta $dc00
 rts
.endif

.if CAMERA_MODE_CYCLE != 0
explorer_poll_mode_cycle_f1:
 lda explorer_key_col0
 and #$10
 bne epm_f1_released
 lda explorer_key_col1
 and #$80
 beq epm_done
 lda explorer_key_col6
 and #$10
 beq epm_done
 lda explorer_mode_latch
 bne epm_done
 lda #$01
 sta explorer_mode_latch
 clc
 lda explorer_runtime_mode
 adc #$01
 cmp #$03
 bcc epm_store
 lda #$01
epm_store:
 sta explorer_runtime_mode
 lda #$00
 sta explorer_yaw_repeat_phase
 sta explorer_pitch_repeat_phase
.if CAMERA_ROLL_CONTROL != 0
 sta explorer_roll_repeat_phase
.endif
 lda explorer_runtime_mode
 cmp #$01
 beq epm_enter_lite
 rts
epm_enter_lite:
 lda #$00
 sta explorer_cam_pitch
.if CAMERA_ROLL_ACTIVE != 0
 sta explorer_cam_roll
 sta explorer_look_yaw_acc_lo
 sta explorer_look_yaw_acc_hi
 sta explorer_look_pitch_acc_lo
 sta explorer_look_pitch_acc_hi
.endif
 rts
epm_f1_released:
 lda #$00
 sta explorer_mode_latch
epm_done:
 rts
.endif

.if EXPLORER_RESET_ON_SPACE != 0
explorer_poll_camera_reset:
 lda #$00
 sta explorer_camera_tick_skip
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 beq epcr_done
.endif
 lda explorer_key_col7
 and #$10
 bne epcr_done
 jsr explorer_init_camera
 lda #$01
 sta explorer_camera_tick_skip
epcr_done:
 lda #$ff
 sta $dc00
 rts
.endif

explorer_advance_camera_tick:
.if EXPLORER_RESET_ON_SPACE != 0
 lda explorer_camera_tick_skip
 bne eact_done
.endif
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 beq eact_done
 cmp #$01
 beq eact_simple_look
.endif
.if CAMERA_ROLL_ACTIVE != 0
 jsr explorer_update_look_rolled
 jmp eact_motion
.endif
eact_simple_look:
 lda explorer_key_col0
 and #$04
 bne eact_yaw_released
 lda explorer_key_col1
 and #$80
 beq eact_yaw_left
 lda explorer_key_col6
 and #$10
 beq eact_yaw_left
eact_yaw_right:
 jsr explorer_yaw_repeat_ready
 bcc eact_after_yaw
 sec
 lda explorer_cam_yaw
 sbc #EXPLORER_LOOK_STEP
 sta explorer_cam_yaw
 jmp eact_after_yaw
eact_yaw_left:
 jsr explorer_yaw_repeat_ready
 bcc eact_after_yaw
 clc
 lda explorer_cam_yaw
 adc #EXPLORER_LOOK_STEP
 sta explorer_cam_yaw
 jmp eact_after_yaw
eact_yaw_released:
 lda #$00
 sta explorer_yaw_repeat_phase
eact_after_yaw:
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 cmp #$01
 beq eact_motion
.endif
.if CAMERA_WALK_LITE = 0 || ENGINE_CAMERA_WALK_LITE_PITCH_RUNTIME_ACTIVE != 0
 lda explorer_key_col0
 and #$80
 bne eact_pitch_released
 lda explorer_key_col1
 and #$80
 beq eact_pitch_up
 lda explorer_key_col6
 and #$10
 beq eact_pitch_up
eact_pitch_down:
 jsr explorer_pitch_repeat_ready
 bcc eact_look_done
 clc
 lda explorer_cam_pitch
 adc #EXPLORER_LOOK_STEP
 sta explorer_cam_pitch
 jmp eact_clamp_pitch
eact_pitch_up:
 jsr explorer_pitch_repeat_ready
 bcc eact_look_done
 sec
 lda explorer_cam_pitch
 sbc #EXPLORER_LOOK_STEP
 sta explorer_cam_pitch
eact_clamp_pitch:
 lda explorer_cam_pitch
 bpl eact_pitch_positive
 cmp #EXPLORER_PITCH_NEG_MIN
 bcs eact_look_done
 lda #EXPLORER_PITCH_NEG_MIN
 sta explorer_cam_pitch
 jmp eact_look_done
eact_pitch_positive:
 cmp #EXPLORER_PITCH_POS_LIMIT
 bcc eact_look_done
 lda #EXPLORER_PITCH_POS_MAX
 sta explorer_cam_pitch
 jmp eact_look_done
eact_pitch_released:
 lda #$00
 sta explorer_pitch_repeat_phase
eact_look_done:
.endif
eact_motion:
 jsr explorer_prepare_motion_axes

 ; Opposite linear commands are neutral. There is no translation repeat phase,
 ; so releasing either key immediately exposes the still-held direction.
 lda explorer_key_col1
 and #$22
 beq eact_no_ws
 cmp #$22
 beq eact_no_ws
 and #$02
 bne eact_move_s
 jsr explorer_move_forward
 jmp eact_no_ws
eact_move_s:
 jsr explorer_move_back
eact_no_ws:

 lda explorer_key_col1
 and #$04
 bne eact_check_d
 lda explorer_key_col2
 and #$04
 beq eact_no_ad
 jsr explorer_strafe_left
 jmp eact_no_ad
eact_check_d:
 lda explorer_key_col2
 and #$04
 bne eact_no_ad
 jsr explorer_strafe_right
eact_no_ad:

 lda explorer_key_col7
 and #$40
 bne eact_check_e
 lda explorer_key_col1
 and #$40
 beq eact_done
 jsr explorer_move_up
 jmp eact_done
eact_check_e:
 lda explorer_key_col1
 and #$40
 bne eact_done
 jsr explorer_move_down
eact_done:
 rts

explorer_yaw_repeat_ready:
 lda explorer_yaw_repeat_phase
 beq eyr_ready
 dec explorer_yaw_repeat_phase
 clc
 rts
eyr_ready:
 lda #EXPLORER_YAW_PITCH_REPEAT_PHASE
 sta explorer_yaw_repeat_phase
 sec
 rts

explorer_pitch_repeat_ready:
 lda explorer_pitch_repeat_phase
 beq epr_ready
 dec explorer_pitch_repeat_phase
 clc
 rts
epr_ready:
 lda #EXPLORER_YAW_PITCH_REPEAT_PHASE
 sta explorer_pitch_repeat_phase
 sec
 rts

.if CAMERA_ROLL_CONTROL != 0
explorer_roll_repeat_ready:
 lda explorer_roll_repeat_phase
 beq err_ready
 dec explorer_roll_repeat_phase
 clc
 rts
err_ready:
 lda #EXPLORER_ROLL_REPEAT_RELOAD
 sta explorer_roll_repeat_phase
 sec
 rts
.endif


explorer_prepare_motion_axes:
 lda #$00
 sec
 sbc explorer_cam_yaw
 tax
 lda sintab,x
 sta sinyv
 txa
 clc
 adc #$40
 tax
 lda sintab,x
 sta cosyv
.if CAMERA_ROLL_ACTIVE != 0
 lda #$00
 sec
 sbc explorer_cam_roll
 tax
 lda sintab,x
 sta sinzv
 txa
 clc
 adc #$40
 tax
 lda sintab,x
 sta coszv
.endif
 rts

explorer_prepare_view:
 jsr explorer_prepare_motion_axes
.if ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH != 0
 lda explorer_cam_pitch
 bne epv_engine_pitch_lookup
 lda #$00
 sta sinxv
 lda #$40
 sta cosxv
 jmp epv_engine_pitch_ready
epv_engine_pitch_lookup:
.endif
 lda #$00
 sec
 sbc explorer_cam_pitch
 tax
 lda sintab,x
 sta sinxv
 txa
 clc
 adc #$40
 tax
 lda sintab,x
 sta cosxv
.if ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH != 0
epv_engine_pitch_ready:
.endif
 rts

.if POLY_FILL_ENABLE = 0
explorer_cache_current_view:
 lda sinyv
 sta explorer_cached_siny
 lda cosyv
 sta explorer_cached_cosy
 lda sinxv
 sta explorer_cached_sinx
 lda cosxv
 sta explorer_cached_cosx
.if CAMERA_ROLL_ACTIVE != 0
 lda sinzv
 sta explorer_cached_sinz
 lda coszv
 sta explorer_cached_cosz
.endif
 rts

explorer_load_cached_view:
 lda explorer_cached_siny
 sta sinyv
 lda explorer_cached_cosy
 sta cosyv
 lda explorer_cached_sinx
 sta sinxv
 lda explorer_cached_cosx
 sta cosxv
.if CAMERA_ROLL_ACTIVE != 0
 lda explorer_cached_sinz
 sta sinzv
 lda explorer_cached_cosz
 sta coszv
.endif
 rts
.endif

explorer_move_forward:
 lda sinyv
 jsr explorer_add_x_scaled
 lda cosyv
 jsr explorer_add_z_scaled
 lda #$00
 beq emf_done
 lda sinxv
 jsr explorer_add_y_scaled
emf_done:
 rts

explorer_move_back:
 lda sinyv
 jsr explorer_negate_a
 jsr explorer_add_x_scaled
 lda cosyv
 jsr explorer_negate_a
 jsr explorer_add_z_scaled
 lda #$00
 beq emb_done
 lda sinxv
 jsr explorer_negate_a
 jsr explorer_add_y_scaled
emb_done:
 rts

explorer_strafe_left:
.if CAMERA_ROLL_ACTIVE != 0
 jsr explorer_calc_roll_right_axis
 jsr explorer_move_axis_neg
 rts
.else
 lda cosyv
 jsr explorer_negate_a
 jsr explorer_add_x_scaled
 lda sinyv
 jsr explorer_add_z_scaled
 rts
.endif

explorer_strafe_right:
.if CAMERA_ROLL_ACTIVE != 0
 jsr explorer_calc_roll_right_axis
 jsr explorer_move_axis_pos
 rts
.else
 lda cosyv
 jsr explorer_add_x_scaled
 lda sinyv
 jsr explorer_negate_a
 jsr explorer_add_z_scaled
 rts
.endif

explorer_move_up:
.if CAMERA_ROLL_ACTIVE != 0
 jsr explorer_calc_roll_up_axis
 jsr explorer_move_axis_pos
 rts
.else
 lda #$40
 jsr explorer_add_y_scaled
 rts
.endif

explorer_move_down:
.if CAMERA_ROLL_ACTIVE != 0
 jsr explorer_calc_roll_up_axis
 jsr explorer_move_axis_neg
 rts
.else
 lda #$c0
 jsr explorer_add_y_scaled
 rts
.endif

.if CAMERA_ROLL_ACTIVE != 0
explorer_calc_roll_right_axis:
 lda cosyv
 ldx coszv
 jsr mul_s6
 sta rx0
 sec
 lda #$00
 sbc sinzv
 sta ry0
 lda sinyv
 jsr explorer_negate_a
 ldx coszv
 jsr mul_s6
 sta rz0
 rts

explorer_calc_roll_up_axis:
 lda cosyv
 ldx sinzv
 jsr mul_s6
 sta rx0
 lda coszv
 sta ry0
 lda sinyv
 jsr explorer_negate_a
 ldx sinzv
 jsr mul_s6
 sta rz0
 rts

explorer_move_axis_pos:
 lda rx0
 jsr explorer_add_x_scaled
 lda ry0
 jsr explorer_add_y_scaled
 lda rz0
 jsr explorer_add_z_scaled
 rts

explorer_move_axis_neg:
 lda rx0
 jsr explorer_negate_a
 jsr explorer_add_x_scaled
 lda ry0
 jsr explorer_negate_a
 jsr explorer_add_y_scaled
 lda rz0
 jsr explorer_negate_a
 jsr explorer_add_z_scaled
 rts
.endif

explorer_add_x_scaled:
 ldx #EXPLORER_MOVE_STEP
 jsr mul_s6
 sta explorer_delta_lo
 jsr explorer_sign_extend_delta
 clc
 lda explorer_cam_x_lo
 adc explorer_delta_lo
 sta explorer_cam_x_lo
 lda explorer_cam_x_hi
 adc explorer_delta_hi
 sta explorer_cam_x_hi
 lda explorer_cam_x_ext
 adc explorer_delta_ext
 sta explorer_cam_x_ext
 rts

explorer_add_y_scaled:
 ldx #EXPLORER_MOVE_STEP
 jsr mul_s6
 sta explorer_delta_lo
 jsr explorer_sign_extend_delta
 clc
 lda explorer_cam_y_lo
 adc explorer_delta_lo
 sta explorer_cam_y_lo
 lda explorer_cam_y_hi
 adc explorer_delta_hi
 sta explorer_cam_y_hi
 lda explorer_cam_y_ext
 adc explorer_delta_ext
 sta explorer_cam_y_ext
 rts

explorer_add_z_scaled:
 ldx #EXPLORER_MOVE_STEP
 jsr mul_s6
 sta explorer_delta_lo
 jsr explorer_sign_extend_delta
 clc
 lda explorer_cam_z_lo
 adc explorer_delta_lo
 sta explorer_cam_z_lo
 lda explorer_cam_z_hi
 adc explorer_delta_hi
 sta explorer_cam_z_hi
 lda explorer_cam_z_ext
 adc explorer_delta_ext
 sta explorer_cam_z_ext
 rts

explorer_sign_extend_delta:
 lda explorer_delta_lo
 bpl esed_pos
 lda #$ff
 sta explorer_delta_hi
 sta explorer_delta_ext
 rts
esed_pos:
 lda #$00
 sta explorer_delta_hi
 sta explorer_delta_ext
 rts

explorer_negate_a:
 eor #$ff
 clc
 adc #$01
 rts

explorer_sub_cam_x:
 sta p1lo
 bpl escx_world_pos
 lda #$ff
 jmp escx_world_ext_ready
escx_world_pos:
 lda #$00
escx_world_ext_ready:
 sta p1hi
 sec
 lda #$00
 sbc explorer_cam_x_lo
 lda p1lo
 sbc explorer_cam_x_hi
 sta explorer_rel_x_lo
 lda p1hi
 sbc explorer_cam_x_ext
 sta explorer_rel_x_hi
 rts

explorer_sub_cam_y:
 sta p1lo
 bpl escy_world_pos
 lda #$ff
 jmp escy_world_ext_ready
escy_world_pos:
 lda #$00
escy_world_ext_ready:
 sta p1hi
 sec
 lda #$00
 sbc explorer_cam_y_lo
 lda p1lo
 sbc explorer_cam_y_hi
 sta explorer_rel_y_lo
 lda p1hi
 sbc explorer_cam_y_ext
 sta explorer_rel_y_hi
 rts

explorer_sub_cam_z16:
 sec
 lda #$00
 sbc explorer_cam_z_lo
 lda rz1
 sbc explorer_cam_z_hi
 sta rz1
 lda explorer_z_world_hi
 sbc explorer_cam_z_ext
 sta explorer_z_hi16
 rts

mul_s16_s6:
 sta mul16mul
 sta mul16abs
 lda #$00
 sta mul16sign
 lda p1hi
 bpl ms16_coord_ok
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
 lda mul16sign
 eor #$80
 sta mul16sign
ms16_coord_ok:
 lda mul16mul
 bpl ms16_mul_ok
 eor #$ff
 clc
 adc #$01
 sta mul16mul
 sta mul16abs
 lda mul16sign
 eor #$80
 sta mul16sign
ms16_mul_ok:
 lda p1lo
 and #$3f
 sta mul16rem
 ldx #$06
ms16_shift_q:
 lsr p1hi
 ror p1lo
 dex
 bne ms16_shift_q
 lda p1lo
 sta mul16lo
 lda p1hi
 sta mul16hi
 lda #$00
 sta mul16reslo
 sta mul16reshi
 ldx #$08
ms16_mul_loop:
 lsr mul16mul
 bcc ms16_no_add
 clc
 lda mul16reslo
 adc mul16lo
 sta mul16reslo
 lda mul16reshi
 adc mul16hi
 sta mul16reshi
ms16_no_add:
 asl mul16lo
 rol mul16hi
 dex
 bne ms16_mul_loop
 lda mul16rem
 beq ms16_no_rem
 ldx mul16abs
 jsr mul_s6
 clc
 adc mul16reslo
 sta mul16reslo
 bcc ms16_no_rem
 inc mul16reshi
ms16_no_rem:
 lda mul16reslo
 sta p1lo
 lda mul16reshi
 sta p1hi
 lda mul16sign
 bpl ms16_done
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
ms16_done:
 rts

explorer_axis_to_byte:
 lda p1hi
 bmi eatb_negative
 bne eatb_pos_sat
 lda p1lo
 bpl eatb_done
eatb_pos_sat:
 lda #$7f
 rts
eatb_negative:
 cmp #$ff
 bne eatb_neg_sat
 lda p1lo
 bmi eatb_done
eatb_neg_sat:
 lda #$80
eatb_done:
 rts

explorer_project_axis_offset:
 lda #$00
 sta mul16sign
 lda p1hi
 bpl epao_abs_ready
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
 lda #$80
 sta mul16sign
epao_abs_ready:
 lda p1lo
 sta mul16lo
 lda p1hi
 sta mul16hi
 jsr load_projection_table_index
.if EXPLORER_TABLE_PROJECTION != 0
 lda p1hi
 bne epao_exact_project
 lda mul16hi
 bne epao_exact_project
 lda mul16lo
 bmi epao_exact_project
 ldx p1lo
 lda scene_scale_tab,x
 bmi epao_exact_project
 tax
 lda mul16lo
 jsr mul_s6_xpos_round
 cmp #$7f
 bcs epao_exact_project
 sta scalev
 sta mul16reslo
 lda #$00
 sta mul16reshi
 rts
epao_exact_project:
.endif
 jsr load_projection_geometric_divisor
 lda mul16hi
 beq epao_mul_start
epao_scale_loop:
 lsr mul16hi
 ror mul16lo
 lsr p1hi
 ror p1lo
 lda p1lo
 ora p1hi
 bne epao_depth_nonzero
 lda #$01
 sta p1lo
epao_depth_nonzero:
 lda mul16hi
 bne epao_scale_loop
epao_mul_start:
 lda #EXPLORER_PROJ_FOCAL
 sta mul16mul
 lda #$00
 sta prodlo
 sta prodhi
 sta mul16rem
 ldx #$08
epao_mul_loop:
 lsr mul16mul
 bcc epao_no_add
 lda mul16rem
 bne epao_saturate
 clc
 lda prodlo
 adc mul16lo
 sta prodlo
 lda prodhi
 adc mul16hi
 sta prodhi
 bcs epao_saturate
epao_no_add:
 asl mul16lo
 rol mul16hi
 bcc epao_shift_ok
 lda #$01
 sta mul16rem
epao_shift_ok:
 dex
 bne epao_mul_loop
 jmp epao_divide
epao_saturate:
 lda #$ff
 sta prodlo
 sta prodhi
epao_divide:
 jsr div16u
 lda prodlo
 sta mul16reslo
 lda prodhi
 sta mul16reshi
 lda prodhi
 beq epao_offset_ok
 lda #$ff
 sta scalev
 rts
epao_offset_ok:
 lda prodlo
 sta scalev
 rts

explorer_project_x16:
 jsr explorer_project_axis_offset
.if EXPLORER_SCREEN_RAW != 0
 jsr explorer_store_raw_x
.endif
 lda mul16sign
 bmi epx_left
 lda scalev
 cmp #PROJ_CENTER_X
 bcc epx_right_visible
 lda #PROJ_SCREEN_MAX_X
 jmp epx_store
epx_right_visible:
 clc
 adc #PROJ_CENTER_X
 jmp epx_store
epx_left:
 lda scalev
 cmp #(PROJ_CENTER_X + 1)
 bcc epx_left_visible
 lda #PROJ_SCREEN_MIN_X
 jmp epx_store
epx_left_visible:
 sta p1lo
 lda #PROJ_CENTER_X
 sec
 sbc p1lo
epx_store:
 ldy tmpidx
 sta sx,y
 rts

.if EXPLORER_SCREEN_RAW != 0
explorer_store_raw_x:
 ldy tmpidx
 lda mul16reshi
 cmp #$ff
 bne esrx_not_saturated
 lda mul16sign
 bmi esrx_left_saturated
 lda #$00
 sta pxrawlo,y
 lda #$7f
 sta pxrawhi,y
 rts
esrx_left_saturated:
 lda #$00
 sta pxrawlo,y
 lda #$80
 sta pxrawhi,y
 rts
esrx_not_saturated:
 lda mul16sign
 bmi esrx_left
 clc
 lda mul16reslo
 adc #PROJ_CENTER_X
 sta pxrawlo,y
 lda mul16reshi
 adc #$00
 sta pxrawhi,y
 rts
esrx_left:
 lda #PROJ_CENTER_X
 sec
 sbc mul16reslo
 sta pxrawlo,y
 lda #$00
 sbc mul16reshi
 sta pxrawhi,y
 rts
.endif

explorer_project_y16:
 jsr explorer_project_axis_offset
.if EXPLORER_SCREEN_RAW != 0
 jsr explorer_store_raw_y
.endif
 lda mul16sign
 bmi epy_down
 lda scalev
 cmp #(PROJ_CENTER_Y + 1)
 bcc epy_up_visible
 lda #PROJ_SCREEN_MIN_Y
 jmp epy_store
epy_up_visible:
 sta p1lo
 lda #PROJ_CENTER_Y
 sec
 sbc p1lo
 jmp epy_store
epy_down:
 lda scalev
 cmp #PROJ_CENTER_Y
 bcc epy_down_visible
 lda #PROJ_SCREEN_MAX_Y
 jmp epy_store
epy_down_visible:
 clc
 adc #PROJ_CENTER_Y
epy_store:
 ldy tmpidx
 sta sy,y
 rts

.if EXPLORER_SCREEN_RAW != 0
explorer_store_raw_y:
 ldy tmpidx
 lda mul16reshi
 cmp #$ff
 bne esry_not_saturated
 lda mul16sign
 bmi esry_down_saturated
 lda #$00
 sta pyrawlo,y
 lda #$80
 sta pyrawhi,y
 rts
esry_down_saturated:
 lda #$00
 sta pyrawlo,y
 lda #$7f
 sta pyrawhi,y
 rts
esry_not_saturated:
 lda mul16sign
 bmi esry_down
 lda #PROJ_CENTER_Y
 sec
 sbc mul16reslo
 sta pyrawlo,y
 lda #$00
 sbc mul16reshi
 sta pyrawhi,y
 rts
esry_down:
 clc
 lda mul16reslo
 adc #PROJ_CENTER_Y
 sta pyrawlo,y
 lda mul16reshi
 adc #$00
 sta pyrawhi,y
 rts
.endif

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0 && WIRE_RENDER_ENABLE != 0 && WIRE_MESH_COUNT != 0
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
* = $4000
.if CAMERA_MOVABLE != 0
.endif
.endif
render_explorer_scene_points:
.if SCENE_OBJECT_COUNT != 0
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && MODE2_FACE_BUCKET_PIPELINE = 0
.if WIRE_OBJECT_SORT_ENABLE != 0
 jsr draw_wire_scene_objects_sorted
.else
 jsr explorer_cache_current_view
 lda #$00
 sta objidx
resp_wire_loop:
.if SCENE_OBJECT_VISIBILITY_ACTIVE != 0
 ldx objidx
 lda object_visible,x
 beq resp_wire_next_object
.endif
 jsr set_active_object
.if WORLD_GROUND_OCCLUDE != 0 && HIDDEN_WIRE_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WORLD_GROUND_WIRE_OCCLUDE = 0
 jsr ground_object_visible
 beq resp_wire_next_object
.endif
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_explorer_matrix_fold
.else
 jsr prepare_angles
 jsr explorer_load_cached_view
.endif
 jsr explorer_transform_project_vertices
 jsr draw_wire_active_mesh
resp_wire_next_object:
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bne resp_wire_loop
.endif
.else
 jsr begin_depth_buckets
 lda #$00
 sta objidx
resp_loop:
.if SCENE_OBJECT_VISIBILITY_ACTIVE != 0
 ldx objidx
 lda object_visible,x
 beq resp_next_object
.endif
 jsr set_active_object
.if WIRE_MESH_COUNT != 0
 ldx meshidx
 lda mesh_is_wire,x
 beq resp_solid_object
.if WORLD_GROUND_OCCLUDE != 0 && POLY_FILL_ENABLE != 0
 jsr ground_object_visible
 beq resp_next_object
.endif
.if WIRE_DEPTH_SORT_ENABLE != 0
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_explorer_matrix_fold
.else
 jsr prepare_angles
 jsr explorer_prepare_view
.if STABLE_FACE_CULL_PROFILE != 0
 jsr stable_face_cull_prepare_movable_matrix
.endif
.endif
 jsr explorer_transform_project_vertices
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0
 ldx meshidx
 lda mesh_face_first,x
 cmp mesh_face_end,x
 beq resp_wire_depth_edges
 jsr collect_active_mesh_faces
 jmp resp_next_object
resp_wire_depth_edges:
.endif
 jsr bucket_visible_wire_object
.endif
 jmp resp_next_object
resp_solid_object:
.endif
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_explorer_matrix_fold
.if MODE4_OBJECT_LIGHT_CACHE != 0
 jsr prepare_object_light_for_shade
.endif
.else
 jsr prepare_angles
.if MODE4_OBJECT_LIGHT_CACHE != 0
 jsr prepare_object_light_for_shade
.endif
 jsr explorer_prepare_view
.if STABLE_FACE_CULL_PROFILE != 0
 jsr stable_face_cull_prepare_movable_matrix
.endif
.endif
 jsr explorer_transform_project_vertices
 jsr collect_active_mesh_faces
resp_next_object:
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bne resp_loop
 jsr draw_depth_buckets
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0 && POLY_FILL_ENABLE = 0
 jsr draw_hidden_poly_scene_objects
.if WIRE_MESH_COUNT != 0
 jsr draw_front_wire_depth_entries
.endif
.endif
.if WIRE_OVERLAY_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE = 0
 jsr draw_wire_scene_objects
.endif
.endif
.else
 jsr explorer_prepare_view
.if STABLE_FACE_CULL_PROFILE != 0
 jsr stable_face_cull_prepare_movable_matrix
.endif
 jsr explorer_transform_project_vertices
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && MODE2_FACE_BUCKET_PIPELINE = 0
 jsr draw_wire_active_mesh
.else
 jsr draw_mesh
.if WIRE_OVERLAY_ENABLE != 0
 jsr draw_wire_active_mesh
.endif
.endif
.endif
 rts

explorer_transform_project_vertices:
.if WIRE_FACE_EDGE_ENABLE != 0 && HIDDEN_WIRE_ENABLE = 0 && POLY_FILL_ENABLE = 0
 lda #$01
 sta wire_mesh_safe_flag
.endif
 ldy active_vfirst
etpv_loop:
 sty tmpidx
.if WORLD_GROUND_OCCLUDE != 0
 jsr ground_store_vertex_side
 ldy tmpidx
.endif
 ldx vert_xi,y
 lda x_m00,x
 sta t1
 ldx vert_yi,y
 lda y_m01,x
 clc
 adc t1
 sta t1
 ldx vert_zi,y
 lda z_m02,x
 clc
 adc t1
 sta rx0
 ldy tmpidx
 ldx vert_xi,y
 lda x_m10,x
 sta t1
 ldx vert_yi,y
 lda y_m11,x
 clc
 adc t1
 sta t1
 ldx vert_zi,y
 lda z_m12,x
 clc
 adc t1
 sta ry1
 ldy tmpidx
 ldx vert_xi,y
 lda x_m20,x
 sta t1
 ldx vert_yi,y
 lda y_m21,x
 clc
 adc t1
 sta t1
 ldx vert_zi,y
 lda z_m22,x
 clc
 adc t1
 sta rz1
.if EXPLORER_MATRIX_FOLD != 0
 lda rx0
 bpl etpv_fold_x_pos
 lda #$ff
 jmp etpv_fold_x_ext_ready
etpv_fold_x_pos:
 lda #$00
etpv_fold_x_ext_ready:
 sta p1hi
 clc
 lda rx0
 adc explorer_view_origin_x_lo
 sta explorer_view_x_lo
 lda p1hi
 adc explorer_view_origin_x_hi
 sta explorer_view_x_hi

 lda ry1
 bpl etpv_fold_y_pos
 lda #$ff
 jmp etpv_fold_y_ext_ready
etpv_fold_y_pos:
 lda #$00
etpv_fold_y_ext_ready:
 sta p1hi
 clc
 lda ry1
 adc explorer_view_origin_y_lo
 sta explorer_view_y_lo
 lda p1hi
 adc explorer_view_origin_y_hi
 sta explorer_view_y_hi

 lda rz1
 bpl etpv_fold_z_pos
 lda #$ff
 jmp etpv_fold_z_ext_ready
etpv_fold_z_pos:
 lda #$00
etpv_fold_z_ext_ready:
 sta p1hi
 clc
 lda rz1
 adc explorer_view_origin_z_lo
 sta p1lo
 lda p1hi
 adc explorer_view_origin_z_hi
 sta p1hi
 lda p1lo
 sta explorer_view_z_lo
 lda p1hi
 sta explorer_view_z_hi
.else
.if SCENE_OBJECT_COUNT != 0
.if SCENE_OBJECT_X_ACTIVE != 0
 clc
 lda rx0
 adc obj_pos_x_cur
 sta rx0
.endif
.if SCENE_OBJECT_Y_ACTIVE != 0
 clc
 lda ry1
 adc obj_pos_y_cur
 sta ry1
.endif
 lda rz1
 sta p1lo
 bpl etpv_local_z_pos
 lda #$ff
 sta p1hi
 jmp etpv_local_z_ready
etpv_local_z_pos:
 lda #$00
 sta p1hi
etpv_local_z_ready:
 clc
 lda p1lo
 adc obj_depth_lo
 sta rz1
 lda p1hi
 adc obj_depth_hi
 sta explorer_z_world_hi
.endif
.if SCENE_OBJECT_COUNT = 0
 lda rz1
 bpl etpv_mesh_z_pos
 lda #$ff
 sta explorer_z_world_hi
 jmp etpv_mesh_z_ready
etpv_mesh_z_pos:
 lda #$00
 sta explorer_z_world_hi
etpv_mesh_z_ready:
.endif
 lda rx0
 jsr explorer_sub_cam_x
 lda ry1
 jsr explorer_sub_cam_y
 jsr explorer_sub_cam_z16
 ; Keep signed geometric camera depth through yaw/pitch/roll.  The legacy
 ; projection origin is applied later and only while producing an index.

 lda explorer_rel_x_lo
 sta p1lo
 lda explorer_rel_x_hi
 sta p1hi
 lda cosyv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda rz1
 sta p1lo
 lda explorer_z_hi16
 sta p1hi
 lda sinyv
 jsr mul_s16_s6
 sec
 lda t1
 sbc p1lo
 sta explorer_view_x_lo
 lda t2
 sbc p1hi
 sta explorer_view_x_hi

 lda explorer_rel_x_lo
 sta p1lo
 lda explorer_rel_x_hi
 sta p1hi
 lda sinyv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda rz1
 sta p1lo
 lda explorer_z_hi16
 sta p1hi
 lda cosyv
 jsr mul_s16_s6
 clc
 lda p1lo
 adc t1
 sta p1lo
 lda p1hi
 adc t2
 sta p1hi
 lda p1lo
 sta explorer_view_z_lo
 lda p1hi
 sta explorer_view_z_hi

.if ENGINE_CAMERA_WALK_LITE_PITCH_RUNTIME_ACTIVE != 0
 lda explorer_cam_pitch
 bne etpv_engine_walk_pitch_apply
 lda explorer_rel_y_lo
 sta explorer_view_y_lo
 lda explorer_rel_y_hi
 sta explorer_view_y_hi
 lda p1hi
 jmp etpv_engine_walk_pitch_done
etpv_engine_walk_pitch_apply:
 lda explorer_rel_y_lo
 sta p1lo
 lda explorer_rel_y_hi
 sta p1hi
 lda cosxv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda explorer_view_z_lo
 sta p1lo
 lda explorer_view_z_hi
 sta p1hi
 lda sinxv
 jsr mul_s16_s6
 sec
 lda t1
 sbc p1lo
 sta explorer_view_y_lo
 lda t2
 sbc p1hi
 sta explorer_view_y_hi

 lda explorer_rel_y_lo
 sta p1lo
 lda explorer_rel_y_hi
 sta p1hi
 lda sinxv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda explorer_view_z_lo
 sta p1lo
 lda explorer_view_z_hi
 sta p1hi
 lda cosxv
 jsr mul_s16_s6
 clc
 lda p1lo
 adc t1
 sta p1lo
 lda p1hi
 adc t2
 sta p1hi
etpv_engine_walk_pitch_done:
.else
.if CAMERA_WALK_LITE != 0
 lda explorer_rel_y_lo
 sta explorer_view_y_lo
 lda explorer_rel_y_hi
 sta explorer_view_y_hi
.else
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 cmp #$02
 beq etpv_pitch_runtime
 lda explorer_rel_y_lo
 sta explorer_view_y_lo
 lda explorer_rel_y_hi
 sta explorer_view_y_hi
 jmp etpv_after_pitch
etpv_pitch_runtime:
.endif
 lda explorer_rel_y_lo
 sta p1lo
 lda explorer_rel_y_hi
 sta p1hi
 lda cosxv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda explorer_view_z_lo
 sta p1lo
 lda explorer_view_z_hi
 sta p1hi
 lda sinxv
 jsr mul_s16_s6
 sec
 lda t1
 sbc p1lo
 sta explorer_view_y_lo
 lda t2
 sbc p1hi
 sta explorer_view_y_hi

 lda explorer_rel_y_lo
 sta p1lo
 lda explorer_rel_y_hi
 sta p1hi
 lda sinxv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda explorer_view_z_lo
 sta p1lo
 lda explorer_view_z_hi
 sta p1hi
 lda cosxv
 jsr mul_s16_s6
 clc
 lda p1lo
 adc t1
 sta p1lo
 lda p1hi
 adc t2
 sta p1hi
.if CAMERA_MODE_CYCLE != 0
etpv_after_pitch:
.endif
.endif
.endif
.if CAMERA_ROLL_ACTIVE != 0
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 cmp #$02
 bne etpv_skip_roll
.endif
 lda p1lo
 sta rz0
 lda p1hi
 sta rz1
 lda explorer_view_x_lo
 sta rx0
 lda explorer_view_x_hi
 sta rx1
 lda explorer_view_y_lo
 sta ry0
 lda explorer_view_y_hi
 sta ry1

 lda rx0
 sta p1lo
 lda rx1
 sta p1hi
 lda coszv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda ry0
 sta p1lo
 lda ry1
 sta p1hi
 lda sinzv
 jsr mul_s16_s6
 sec
 lda t1
 sbc p1lo
 sta explorer_view_x_lo
 lda t2
 sbc p1hi
 sta explorer_view_x_hi

 lda rx0
 sta p1lo
 lda rx1
 sta p1hi
 lda sinzv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda ry0
 sta p1lo
 lda ry1
 sta p1hi
 lda coszv
 jsr mul_s16_s6
 clc
 lda p1lo
 adc t1
 sta explorer_view_y_lo
 lda p1hi
 adc t2
 sta explorer_view_y_hi

 lda rz0
 sta p1lo
 lda rz1
 sta p1hi
.if CAMERA_MODE_CYCLE != 0
etpv_skip_roll:
.endif
.endif
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
 ldy tmpidx
 lda explorer_view_x_lo
 sta vxrawlo,y
 lda explorer_view_x_hi
 sta vxrawhi,y
 lda explorer_view_y_lo
 sta vyrawlo,y
 lda explorer_view_y_hi
 sta vyrawhi,y
 lda p1lo
 sta vzrawlo,y
 lda p1hi
 sta vzrawhi,y
.endif
 bmi etpv_depth_invalid
 bne etpv_depth_valid
 lda p1lo
 cmp #CAMERA_FACE_MIN_DEPTH
 bcc etpv_depth_invalid
etpv_depth_valid:
 lda #$01
 sta t1
 jmp etpv_store_project
etpv_depth_invalid:
.if EXPLORER_NEAR_CLIP != 0
 lda #CAMERA_FACE_MIN_DEPTH
 sta p1lo
 lda #$00
 sta p1hi
.if ENGINE_WIRE_CAMERA_THROUGH_MESH_ENABLE != 0
 lda #$01
.else
 lda #$00
.endif
 sta t1
 jmp etpv_store_project
.else
 ldy tmpidx
 lda #$00
 sta projdone,y
 jmp etpv_next
.endif
etpv_store_project:
 ldy tmpidx
 lda p1lo
 sta sz,y
 lda p1hi
 sta szhi,y
 lda explorer_view_x_lo
 sta p1lo
 lda explorer_view_x_hi
 sta p1hi
 jsr explorer_axis_to_byte
 ldy tmpidx
 sta rxbuf,y
 lda explorer_view_y_lo
 sta p1lo
 lda explorer_view_y_hi
 sta p1hi
 jsr explorer_axis_to_byte
 ldy tmpidx
 sta rybuf,y
 lda explorer_view_x_lo
 sta p1lo
 lda explorer_view_x_hi
 sta p1hi
 jsr explorer_project_x16
 lda explorer_view_y_lo
 sta p1lo
 lda explorer_view_y_hi
 sta p1hi
 jsr explorer_project_y16
.if WIRE_FACE_EDGE_ENABLE != 0 && HIDDEN_WIRE_ENABLE = 0 && POLY_FILL_ENABLE = 0
 lda wire_mesh_safe_flag
 beq etpv_mark_valid
 ldy tmpidx
 lda szhi,y
 bmi etpv_wire_unsafe
 bne etpv_wire_check_screen
 lda sz,y
 cmp #CAMERA_FACE_MIN_DEPTH
 bcc etpv_wire_unsafe
etpv_wire_check_screen:
 lda sx,y
 beq etpv_wire_unsafe
 cmp #PROJ_SCREEN_MAX_X
 bcs etpv_wire_unsafe
 lda sy,y
 beq etpv_wire_unsafe
 cmp #PROJ_SCREEN_MAX_Y
 bcc etpv_mark_valid
etpv_wire_unsafe:
 lda #$00
 sta wire_mesh_safe_flag
.endif
 ldy tmpidx
etpv_mark_valid:
 lda t1
 sta projdone,y
 jmp etpv_next
etpv_next:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 inc shared_source_vertex
.endif
 iny
 cpy active_vend
 beq etpv_done
 jmp etpv_loop
etpv_done:
 rts
.endif

rotate_project_vertices:
 ldy active_vfirst
rp_loop:
.if WORLD_GROUND_OCCLUDE != 0
 sty tmpidx
 jsr ground_store_vertex_side
 ldy tmpidx
.endif
 ldx vert_xi,y
 lda x_m00,x
 sta t1
 ldx vert_yi,y
 lda y_m01,x
 clc
 adc t1
 sta t1
 ldx vert_zi,y
 lda z_m02,x
 clc
 adc t1
 sta rx0
 ldx vert_xi,y
 lda x_m10,x
 sta t1
 ldx vert_yi,y
 lda y_m11,x
 clc
 adc t1
 sta t1
 ldx vert_zi,y
 lda z_m12,x
 clc
 adc t1
 sta ry1
 ldx vert_xi,y
 lda x_m20,x
 sta t1
 ldx vert_yi,y
 lda y_m21,x
 clc
 adc t1
 sta t1
 ldx vert_zi,y
 lda z_m22,x
 clc
 adc t1
 sta rz1
.if SCENE_OBJECT_COUNT != 0
.if SCENE_OBJECT_X_ACTIVE != 0
 lda rx0
 ldx obj_pos_x_cur
 jsr add_s8_sat
 sta rx0
.endif
.if SCENE_OBJECT_Y_ACTIVE != 0
 lda ry1
 ldx obj_pos_y_cur
 jsr add_s8_sat
 sta ry1
.endif
.endif
.if CAMERA_HAS_POS != 0
 sec
 lda rx0
 sbc #CAMERA_POS_X
 sta rx0
 sec
 lda ry1
 sbc #CAMERA_POS_Y
 sta ry1
 sec
 lda rz1
 sbc #CAMERA_POS_Z
 sta rz1
.endif
.if CAMERA_HAS_ROT != 0
 lda rx0
 ldx #CAMERA_M00
 jsr mul_s6
 sta vx3
 lda ry1
 ldx #CAMERA_M01
 jsr mul_s6
 clc
 adc vx3
 sta vx3
 lda rz1
 ldx #CAMERA_M02
 jsr mul_s6
 clc
 adc vx3
 sta vx3
 lda rx0
 ldx #CAMERA_M10
 jsr mul_s6
 sta vy3
 lda ry1
 ldx #CAMERA_M11
 jsr mul_s6
 clc
 adc vy3
 sta vy3
 lda rz1
 ldx #CAMERA_M12
 jsr mul_s6
 clc
 adc vy3
 sta vy3
 lda rx0
 ldx #CAMERA_M20
 jsr mul_s6
 sta p1lo
 lda ry1
 ldx #CAMERA_M21
 jsr mul_s6
 clc
 adc p1lo
 sta p1lo
 lda rz1
 ldx #CAMERA_M22
 jsr mul_s6
 clc
 adc p1lo
 sta p1lo
 lda vx3
 sta rx0
 lda vy3
 sta ry1
 lda p1lo
 sta rz1
.endif
 lda rz1
 sta p1lo
 lda #$00
 sta p1hi
 lda rz1
 bpl rp_depth_signed_ready
 lda #$ff
 sta p1hi
rp_depth_signed_ready:
.if SCENE_OBJECT_COUNT != 0
 clc
 lda p1lo
 adc obj_depth_lo
 sta p1lo
 lda p1hi
 adc obj_depth_hi
 sta p1hi
.endif
.if WORLD_GROUND_PLANE_CLIP != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
 lda rx0
 sta vxrawlo,y
 bpl rp_raw_x_positive
 lda #$ff
 bne rp_raw_x_ready
rp_raw_x_positive:
 lda #$00
rp_raw_x_ready:
 sta vxrawhi,y
 lda ry1
 sta vyrawlo,y
 bpl rp_raw_y_positive
 lda #$ff
 bne rp_raw_y_ready
rp_raw_y_positive:
 lda #$00
rp_raw_y_ready:
 sta vyrawhi,y
 lda p1lo
 sta vzrawlo,y
 lda p1hi
 sta vzrawhi,y
.endif
 lda rx0
 sta rxbuf,y
 lda ry1
 sta rybuf,y
 clc
 lda p1lo
 adc motion_z_lo
 sta sz,y
 lda p1hi
 adc motion_z_hi
 bcc rp_depth_hi_ready
 lda #$ff
rp_depth_hi_ready:
 sta szhi,y
.if SCENE_OBJECT_COUNT != 0
 lda obj_depth_frac
.else
 lda motion_z_frac
.endif
 bpl rp_no_frac_round
 clc
 lda sz,y
 adc #$01
 sta sz,y
 lda szhi,y
 adc #$00
 sta szhi,y
rp_no_frac_round:
 lda #$00
 sta projdone,y
.if MESH_SOURCE_SHARING_RUNTIME != 0
 inc shared_source_vertex
.endif
 iny
 cpy active_vend
 bne rp_loop
 rts

.if POLY_FILL_ENABLE != 0
draw_mesh:
 jsr begin_depth_buckets
 jsr collect_active_mesh_faces
 jsr draw_depth_buckets
 rts
.endif

.if WIRE_RENDER_ENABLE != 0
project_wire_vertices:
.if STANDARD_PROJECT_VERTEX != 0
 lda active_vfirst
 sta sorti
pwv_loop:
 ldx sorti
 jsr project_vertex
 inc sorti
 lda sorti
 cmp active_vend
 bne pwv_loop
.endif
 rts

.if MODE2_FACE_BUCKET_PIPELINE = 0
draw_wire_active_mesh:
.if HIDDEN_WIRE_ENABLE != 0
.if WIRE_MESH_COUNT != 0
 ldx meshidx
 lda mesh_is_wire,x
 beq dwam_hidden_poly
.if WIRE_FACE_EDGE_ENABLE != 0
 lda mesh_face_first,x
 cmp mesh_face_end,x
 beq dwam_hidden_wire_edges
 jmp draw_visible_wire_mesh
dwam_hidden_wire_edges:
.endif
 jmp draw_wire_mesh
dwam_hidden_poly:
.endif
.if WIRE_FACE_EDGE_ENABLE != 0
 jmp draw_visible_wire_mesh
.else
 rts
.endif
.else
.if ENGINE_MODE1_FACE_PASS_STRIPPED != 0 && WIRE_EDGE_COUNT != 0
 jmp draw_wire_mesh
.else
.if FACE_RENDER_ENABLE != 0
.if WIRE_MESH_COUNT != 0
 ldx meshidx
 lda mesh_is_wire,x
 bne dwam_explicit_wire
 jmp draw_wire_poly_mesh_mode1
dwam_explicit_wire:
.else
 jmp draw_wire_poly_mesh_mode1
.endif
.endif
.if WIRE_MESH_COUNT != 0
 jmp draw_wire_mesh
.endif
.endif
.endif

.if HIDDEN_WIRE_ENABLE = 0 && FACE_RENDER_ENABLE != 0
draw_wire_poly_mesh_mode1:
.if WIRE_FACE_EDGE_ENABLE != 0
.if FACE_SOLID_COLOR_ENABLE != 0
 jmp draw_wire_faces_mesh
.endif
.if CAMERA_MOVABLE != 0
 lda wire_mesh_safe_flag
 beq dwpm1_fallback
 jmp draw_wire_mesh
.else
 jsr wire_mesh_fast_safe
 bcc dwpm1_fallback
 jmp draw_wire_mesh
.endif
dwpm1_fallback:
.endif
 jmp draw_wire_faces_mesh

.if WIRE_FACE_EDGE_ENABLE != 0
.if CAMERA_MOVABLE = 0
wire_mesh_fast_safe:
 lda active_vfirst
 sta tmpidx
wmfs_loop:
 lda tmpidx
 cmp active_vend
 beq wmfs_yes
 tax
.if SCENE_OBJECT_COUNT != 0
 jsr vertex_depth_safe
 beq wmfs_no
 ldx tmpidx
.endif
 lda sx,x
 beq wmfs_no
 cmp #PROJ_SCREEN_MAX_X
 bcs wmfs_no
 lda sy,x
 beq wmfs_no
 cmp #PROJ_SCREEN_MAX_Y
 bcs wmfs_no
 inc tmpidx
 jmp wmfs_loop
wmfs_yes:
 sec
 rts
wmfs_no:
 clc
 rts
.endif
.endif
.endif

.if WIRE_EDGE_COUNT != 0
draw_wire_mesh:
.if WIRE_TWO_COLOR_MODE1_ENABLE != 0
 jsr activate_wire_two_color_palette
.else
 lda #$aa
 sta fillbyte
.endif
 ldx meshidx
 lda mesh_edge_end,x
 sta sortj
 lda mesh_edge_first,x
 sta faceidx
dwm_loop:
 lda faceidx
 cmp sortj
 beq dwm_done
 tay
 lda edge0,y
 sta clip_prev_idx
 tax
.if SCENE_OBJECT_COUNT != 0
.if ENGINE_MODE1_UNIVERSAL_EDGE_TRAVERSAL != 0
 ; projdone is finalized during engine movable-camera projection and already reflects
 ; valid depth or the camera-through-mesh near-clamp decision for any mesh vertex.
 lda projdone,x
 beq dwm_next
.else
 jsr wire_vertex_drawable
 beq dwm_next
.endif
.endif
 ldy faceidx
 lda edge1,y
 sta clip_cur_idx
 tax
.if SCENE_OBJECT_COUNT != 0
.if ENGINE_MODE1_UNIVERSAL_EDGE_TRAVERSAL != 0
 lda projdone,x
 beq dwm_next
.else
 jsr wire_vertex_drawable
 beq dwm_next
.endif
.endif
.if WORLD_GROUND_OCCLUDE != 0 && HIDDEN_WIRE_ENABLE != 0 && POLY_FILL_ENABLE = 0
 jsr ground_wire_edge_visible
 beq dwm_next
.endif
.if WIRE_TWO_COLOR_MODE1_ENABLE != 0
 ldy faceidx
 jsr load_wire_two_color_edge_pattern_y
.endif
.if ENGINE_MODE1_WIRE_FAST_PLOT != 0 && EXPLORER_SCREEN_CLIP_POLY != 0 && EXPLORER_SCREEN_RAW != 0
 ; Fast path: both raw endpoints are already inside the 160x100 viewport.
 ; This avoids the generic polygon clipper and the redundant guarded draw.
 ldx clip_prev_idx
 lda pxrawhi,x
 bne dwm_clip_fallback
 lda pxrawlo,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dwm_clip_fallback
 lda pyrawhi,x
 bne dwm_clip_fallback
 lda pyrawlo,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dwm_clip_fallback
 ldx clip_cur_idx
 lda pxrawhi,x
 bne dwm_clip_fallback
 lda pxrawlo,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dwm_clip_fallback
 lda pyrawhi,x
 bne dwm_clip_fallback
 lda pyrawlo,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dwm_clip_fallback
 ldx clip_prev_idx
 lda pxrawlo,x
 sta ex0
 lda pyrawlo,x
 sta ey0
 ldx clip_cur_idx
 lda pxrawlo,x
 sta ex1
 lda pyrawlo,x
 sta ey1
 jsr draw_wire_edge
 jmp dwm_next

dwm_clip_fallback:
 jsr clip_wire_edge_screen
 beq dwm_next
 jsr draw_wire_edge_guarded
 jmp dwm_next
.else
.if EXPLORER_SCREEN_CLIP_POLY != 0 && EXPLORER_SCREEN_RAW != 0
 jsr clip_wire_edge_screen
 beq dwm_next
.else
 ldx clip_prev_idx
 lda sx,x
 sta ex0
 lda sy,x
 sta ey0
 lda ex0
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dwm_next
 lda ey0
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dwm_next
 ldx clip_cur_idx
 lda sx,x
 sta ex1
 lda sy,x
 sta ey1
 lda ex1
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dwm_next
 lda ey1
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dwm_next
.endif
 jsr draw_wire_edge_guarded
.endif
dwm_next:
 inc faceidx
 jmp dwm_loop
dwm_done:
 rts
.endif
.endif

.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0
.if MODE2_FACE_BUCKET_PIPELINE = 0
draw_visible_wire_mesh:
 lda #$aa
 sta fillbyte
.if CAMERA_MOVABLE != 0
 jsr prepare_hidden_wire_context
.endif
.if WORLD_GROUND_WIRE_OCCLUDE != 0
 jsr draw_visible_wire_mesh_ground_mask
.if WIRE_OBJECT_MATERIAL_ENABLE != 0
 jsr restore_active_object_wire_material
.endif
.endif
.if WORLD_GROUND_HORIZON_BBOX_OCCLUDE != 0
.if CAMERA_ROLL_ACTIVE != 0
 lda explorer_cam_roll
 bne dvwm_skip_ground_erase
.endif
 lda material_screen_cur
 sta world_ground_saved_screen
 lda material_color_cur
 sta world_ground_saved_color
 jsr draw_visible_wire_mesh_ground_erase
 lda world_ground_saved_screen
 sta material_screen_cur
 lda world_ground_saved_color
 sta material_color_cur
 lda #$aa
 sta fillbyte
dvwm_skip_ground_erase:
.endif
 jsr clear_wire_edge_marks
 lda active_face_first
 sta faceidx
dvwm_loop:
 lda faceidx
 cmp active_face_end
 beq dvwm_done
 lda faceidx
 sta sortj
.if FORCE_FACE_RENDER = 0
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda #$00
 sta clip_poly_active
.endif
 jsr hidden_face_visible_camera
 bcc dvwm_next
.endif
 ldy faceidx
 jsr load_face_y
 bcc dvwm_next
 jsr loaded_wire_face_visible
 bcc dvwm_next
 jsr draw_loaded_wire_face_unique
dvwm_next:
 inc faceidx
 jmp dvwm_loop
dvwm_done:
 rts

.if WORLD_GROUND_WIRE_OCCLUDE != 0
draw_visible_wire_mesh_ground_mask:
 lda world_ground_horizon_valid
 beq wgmb_rts
.if WIRE_MESH_COUNT != 0
 ldx meshidx
 lda mesh_is_wire,x
 bne wgmb_rts
.endif
 lda active_face_first
 sta faceidx
wgmb_loop:
 lda faceidx
 cmp active_face_end
 beq wgmb_rts
 lda faceidx
 sta sortj
.if FORCE_FACE_RENDER = 0
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda #$00
 sta clip_poly_active
.endif
 jsr hidden_face_visible_camera
 bcc wgmb_next
.endif
 ldy faceidx
 jsr load_face_y
 bcc wgmb_next
 jsr loaded_wire_face_visible
 bcc wgmb_next
 jsr world_ground_clear_loaded_face
wgmb_next:
 inc faceidx
 jmp wgmb_loop
wgmb_rts:
 rts

world_ground_clear_loaded_face:
.if ENGINE_MODE2_HORIZON_ROW_MASK_RUNTIME_ACTIVE != 0
 lda #$00
 sta wire_trace_active
 jsr setup_face_y_bounds
 lda world_ground_hy0
 cmp face_ymin
 bcc wgclf_hr_done
 cmp face_ymax
 bcc wgclf_hr_visible
 beq wgclf_hr_visible
 rts
wgclf_hr_visible:
 sta yrow
 tax
 lda #$ff
 sta leftb,x
 lda #$00
 sta rightb,x
 lda vx0
 sta ex0
 lda vy0
 sta ey0
 lda vx1
 sta ex1
 lda vy1
 sta ey1
 jsr trace_edge_convex
 lda vx1
 sta ex0
 lda vy1
 sta ey0
 lda vx2
 sta ex1
 lda vy2
 sta ey1
 jsr trace_edge_convex
 lda vx2
 sta ex0
 lda vy2
 sta ey0
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne wgclf_hr_trace_2_to_0
.endif
 lda vx3
 sta ex1
 lda vy3
 sta ey1
 jsr trace_edge_convex
 lda vx3
 sta ex0
 lda vy3
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
 jmp wgclf_hr_clear
.if HAS_TRI_FACES != 0
wgclf_hr_trace_2_to_0:
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
.endif
wgclf_hr_clear:
 ldx yrow
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc wgclf_hr_done
 jsr world_ground_clear_mask_row_span
wgclf_hr_done:
 rts
.else
 lda #$00
 sta wire_trace_active
 jsr setup_face_y_bounds
 ldx face_ymin
 lda #$ff
wgclf_init_loop:
 sta leftb,x
 lda #$00
 sta rightb,x
 lda #$ff
 cpx face_ymax
 beq wgclf_init_done
 inx
 jmp wgclf_init_loop
wgclf_init_done:
 lda vx0
 sta ex0
 lda vy0
 sta ey0
 lda vx1
 sta ex1
 lda vy1
 sta ey1
 jsr trace_edge_convex
 lda vx1
 sta ex0
 lda vy1
 sta ey0
 lda vx2
 sta ex1
 lda vy2
 sta ey1
 jsr trace_edge_convex
 lda vx2
 sta ex0
 lda vy2
 sta ey0
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne wgclf_trace_2_to_0
.endif
 lda vx3
 sta ex1
 lda vy3
 sta ey1
 jsr trace_edge_convex
 lda vx3
 sta ex0
 lda vy3
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
 jmp wgclf_rows
.if HAS_TRI_FACES != 0
wgclf_trace_2_to_0:
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
.endif
wgclf_rows:
 ldx face_ymin
wgclf_row:
 stx yrow
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc wgclf_next_row
 jsr world_ground_clear_mask_row_span
wgclf_next_row:
 ldx yrow
 cpx face_ymax
 beq wgclf_done
 inx
 jmp wgclf_row
wgclf_done:
 rts
.endif

.endif

.if WORLD_GROUND_HORIZON_BBOX_OCCLUDE != 0
draw_visible_wire_mesh_ground_erase:
 lda #$00
 sta fillbyte
 sta material_screen_cur
 sta material_color_cur
 lda active_face_first
 sta faceidx
dvwmge_loop:
 lda faceidx
 cmp active_face_end
 beq dvwmge_done
 lda faceidx
 sta sortj
.if FORCE_FACE_RENDER = 0
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda #$00
 sta clip_poly_active
.endif
 jsr hidden_face_visible_camera
 bcc dvwmge_next
.endif
 ldy faceidx
 jsr load_face_y
 bcc dvwmge_next
 jsr loaded_wire_face_visible
 bcc dvwmge_next
 jsr world_ground_erase_loaded_face_bbox
 jmp dvwmge_next

world_ground_erase_loaded_face_bbox:
 lda vx0
 sta leftval
 sta rightval
 lda vy0
 sta face_ymin
 sta face_ymax
 lda vx1
 jsr wg_bbox_add_x
 lda vy1
 jsr wg_bbox_add_y
 lda vx2
 jsr wg_bbox_add_x
 lda vy2
 jsr wg_bbox_add_y
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne wg_bbox_ready
.endif
 lda vx3
 jsr wg_bbox_add_x
 lda vy3
 jsr wg_bbox_add_y
wg_bbox_ready:
 lda face_ymin
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs wg_bbox_done
 lda leftval
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs wg_bbox_done
 lda face_ymax
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcc wg_bbox_ymax_ok
 lda #PROJ_SCREEN_MAX_Y
 sta face_ymax
wg_bbox_ymax_ok:
 lda rightval
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcc wg_bbox_xmax_ok
 lda #PROJ_SCREEN_MAX_X
 sta rightval
wg_bbox_xmax_ok:
 clc
 lda leftval
 adc #$08
 sta leftval
 cmp rightval
 bcs wg_bbox_done
 sec
 lda rightval
 sbc #$08
 sta rightval
 cmp leftval
 bcc wg_bbox_done
 clc
 lda face_ymin
 adc #$06
 sta face_ymin
 cmp face_ymax
 bcs wg_bbox_done
 sec
 lda face_ymax
 sbc #$06
 sta face_ymax
 cmp face_ymin
 bcc wg_bbox_done
 ldx face_ymin
dvwmge_row:
 stx yrow
 jsr world_ground_erase_row_span
dvwmge_row_next:
 ldx yrow
 cpx face_ymax
 beq wg_bbox_done
 inx
 jmp dvwmge_row
wg_bbox_done:
 rts

wg_bbox_add_x:
 cmp leftval
 bcs wg_bbox_x_min_ok
 sta leftval
wg_bbox_x_min_ok:
 cmp rightval
 bcc wg_bbox_x_done
 sta rightval
wg_bbox_x_done:
 rts

wg_bbox_add_y:
 cmp face_ymin
 bcs wg_bbox_y_min_ok
 sta face_ymin
wg_bbox_y_min_ok:
 cmp face_ymax
 bcc wg_bbox_y_done
 sta face_ymax
wg_bbox_y_done:
 rts
dvwmge_next:
 inc faceidx
 jmp dvwmge_loop
dvwmge_done:
 rts

world_ground_erase_row_span:
 lda drawbuf
 bne wgers_b
 ldx yrow
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jmp wgers_rows_ready
wgers_b:
 ldx yrow
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
wgers_rows_ready:
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldy #$00
 lda startbyte
 cmp endbyte
 bne wgers_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 sta (ptr1lo),y
 rts
wgers_multi:
 ldx leftval
 lda startmask,x
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 sta fullcount
wgers_next_byte:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc wgers_ptr0_ok
 inc ptr0hi
wgers_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc wgers_ptr1_ok
 inc ptr1hi
wgers_ptr1_ok:
 dec fullcount
 beq wgers_end_byte
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp wgers_next_byte
wgers_end_byte:
 ldx rightval
 lda endmask,x
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 sta (ptr1lo),y
 rts
.endif

.if CAMERA_MOVABLE != 0
prepare_hidden_wire_context:
 lda explorer_cam_x_hi
 ldx explorer_cam_x_ext
 jsr hidden_saturate_i16_to_i8
 sta hidden_cam_x8
 lda explorer_cam_y_hi
 ldx explorer_cam_y_ext
 jsr hidden_saturate_i16_to_i8
 sta hidden_cam_y8
 lda explorer_cam_z_hi
 ldx explorer_cam_z_ext
 jsr hidden_saturate_i16_to_i8
 sta hidden_cam_z8
.if SCENE_OBJECT_COUNT != 0
 lda obj_depth_lo
 ldx obj_depth_hi
 jsr hidden_saturate_i16_to_i8
 sta hidden_obj_z8
.endif
 rts
.endif
.endif
.endif

.if MODE2_FACE_BUCKET_PIPELINE != 0
; Imported unchanged from rc2-dev5 Mode 2 winding validation: signed 24-bit
; shoelace area over the exact projected polygon selected by load_face_y.
mode2_screen_winding_visible:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq m2swc_normal_count
 lda clip_a_count
 jmp m2swc_count_ready
m2swc_normal_count:
.endif
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
.else
 lda #$04
.endif
m2swc_count_ready:
 cmp #$03
 bcc m2swc_hidden
 sta fullcount
 lda #$00
 sta dotlo
 sta dothi
 sta crosslo
 sta sorti
m2swc_loop:
 lda sorti
 clc
 adc #$01
 cmp fullcount
 bcc m2swc_next_ready
 lda #$00
m2swc_next_ready:
 sta sortj

 ; xi * y(i+1)
 ldx sorti
 jsr mode2_screen_winding_get_x_half
 sta t1
 ldx sortj
 jsr mode2_screen_winding_get_y
 tax
 lda t1
 jsr mul_s8_16
 clc
 lda dotlo
 adc prodlo
 sta dotlo
 lda dothi
 adc prodhi
 sta dothi
 lda crosslo
 adc #$00
 sta crosslo

 ; x(i+1) * yi
 ldx sortj
 jsr mode2_screen_winding_get_x_half
 sta t1
 ldx sorti
 jsr mode2_screen_winding_get_y
 tax
 lda t1
 jsr mul_s8_16
 sec
 lda dotlo
 sbc prodlo
 sta dotlo
 lda dothi
 sbc prodhi
 sta dothi
 lda crosslo
 sbc #$00
 sta crosslo

 inc sorti
 lda sorti
 cmp fullcount
 bne m2swc_loop
 lda crosslo
 bmi m2swc_hidden
 bne m2swc_visible
 lda dothi
 bne m2swc_visible
 lda dotlo
 cmp #$01
 bcc m2swc_hidden
m2swc_visible:
 sec
 rts
m2swc_hidden:
 clc
 rts

mode2_screen_winding_get_x_half:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq m2swc_x_normal
 lda clip_a_x,x
 lsr
 rts
m2swc_x_normal:
.endif
 cpx #$00
 bne m2swc_x1
 lda vx0
 lsr
 rts
m2swc_x1:
 cpx #$01
 bne m2swc_x2
 lda vx1
 lsr
 rts
m2swc_x2:
 cpx #$02
 bne m2swc_x3
 lda vx2
 lsr
 rts
m2swc_x3:
 lda vx3
 lsr
 rts

mode2_screen_winding_get_y:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq m2swc_y_normal
 lda clip_a_y,x
 rts
m2swc_y_normal:
.endif
 cpx #$00
 bne m2swc_y1
 lda vy0
 rts
m2swc_y1:
 cpx #$01
 bne m2swc_y2
 lda vy1
 rts
m2swc_y2:
 cpx #$02
 bne m2swc_y3
 lda vy2
 rts
m2swc_y3:
 lda vy3
 rts
.endif

.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE != 0
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
* = $4000
.endif
.if MODE2_FACE_BUCKET_PIPELINE = 0
loaded_wire_face_visible:
.if FORCE_FACE_RENDER = 0
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq lwfv_after_clip
 jsr hidden_face_visible_camera
 bcc lwfv_hidden
.endif
.endif
lwfv_after_clip:
.if WORLD_GROUND_OCCLUDE != 0
 jsr ground_face_visible
 beq lwfv_hidden
.endif
lwfv_visible:
 sec
 rts
lwfv_hidden:
 clc
 rts

hidden_face_visible_camera:
 ldy faceidx
 sty tmpidx
 jsr hidden_rotate_face_normal
 lda #$00
 sta dotlo
 sta dothi
.if CAMERA_MOVABLE != 0
 ldx hidden_cam_x8
.else
 ldx #CAMERA_POS_X
.endif
 lda sh_nx
 jsr mul_s8_16
 jsr hidden_add_dot_product
.if CAMERA_MOVABLE != 0
 ldx hidden_cam_y8
.else
 ldx #CAMERA_POS_Y
.endif
 lda sh_ny
 jsr mul_s8_16
 jsr hidden_add_dot_product
.if CAMERA_MOVABLE != 0
 ldx hidden_cam_z8
.else
 ldx #CAMERA_POS_Z
.endif
 lda sh_nz
 jsr mul_s8_16
 jsr hidden_add_dot_product
 jsr hidden_subtract_face_center_dot
.if SCENE_OBJECT_COUNT != 0
 jsr hidden_subtract_object_position_dot
.endif
 lda dothi
 bmi hfvc_hidden
 bne hfvc_visible
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq hfvc_normal_threshold
 lda dotlo
 cmp #$10
 bcc hfvc_hidden
 jmp hfvc_visible
hfvc_normal_threshold:
.endif
 lda dotlo
 cmp #$01
 bcc hfvc_hidden
hfvc_visible:
 sec
 rts
hfvc_hidden:
 clc
 rts

hidden_rotate_face_normal:
 ldy tmpidx
 lda face_normal_x,y
 ldx m00
 jsr mul_s6
 sta sh_nx
 lda face_normal_y,y
 ldx m01
 jsr mul_s6
 clc
 adc sh_nx
 sta sh_nx
 lda face_normal_z,y
 ldx m02
 jsr mul_s6
 clc
 adc sh_nx
 sta sh_nx
 lda face_normal_x,y
 ldx m10
 jsr mul_s6
 sta sh_ny
 lda face_normal_y,y
 ldx m11
 jsr mul_s6
 clc
 adc sh_ny
 sta sh_ny
 lda face_normal_z,y
 ldx m12
 jsr mul_s6
 clc
 adc sh_ny
 sta sh_ny
 lda face_normal_x,y
 ldx m20
 jsr mul_s6
 sta sh_nz
 lda face_normal_y,y
 ldx m21
 jsr mul_s6
 clc
 adc sh_nz
 sta sh_nz
 lda face_normal_z,y
 ldx m22
 jsr mul_s6
 clc
 adc sh_nz
 sta sh_nz
 rts

hidden_saturate_i16_to_i8:
 sta p1lo
 txa
 beq hs16_pos_ext
 cmp #$ff
 beq hs16_neg_ext
 bmi hs16_neg_sat
 lda #$7f
 rts
hs16_pos_ext:
 lda p1lo
 bmi hs16_pos_sat
 rts
hs16_pos_sat:
 lda #$7f
 rts
hs16_neg_ext:
 lda p1lo
 bmi hs16_in_range
hs16_neg_sat:
 lda #$80
 rts
hs16_in_range:
 lda p1lo
 rts

hidden_subtract_face_center_dot:
 ldy tmpidx
 sec
 lda dotlo
 sbc face_center_dot_lo,y
 sta dotlo
 lda dothi
 sbc face_center_dot_hi,y
 sta dothi
 rts

.if SCENE_OBJECT_COUNT != 0
hidden_subtract_object_position_dot:
.if SCENE_OBJECT_X_ACTIVE != 0
 ldx obj_pos_x_cur
 lda sh_nx
 jsr mul_s8_16
 jsr hidden_subtract_dot_product
.endif
.if SCENE_OBJECT_Y_ACTIVE != 0
 ldx obj_pos_y_cur
 lda sh_ny
 jsr mul_s8_16
 jsr hidden_subtract_dot_product
.endif
.if CAMERA_MOVABLE != 0
 ldx hidden_obj_z8
.else
 lda obj_depth_lo
 ldx obj_depth_hi
 jsr hidden_saturate_i16_to_i8
 tax
.endif
 lda sh_nz
 jsr mul_s8_16
 jsr hidden_subtract_dot_product
 rts
.endif

hidden_add_dot_product:
 clc
 lda dotlo
 adc prodlo
 sta dotlo
 lda dothi
 adc prodhi
 sta dothi
 rts

hidden_subtract_dot_product:
 sec
 lda dotlo
 sbc prodlo
 sta dotlo
 lda dothi
 sbc prodhi
 sta dothi
 rts

.endif
.endif

.if WIRE_FACE_EDGE_ENABLE != 0 && MODE2_FACE_BUCKET_PIPELINE = 0
clear_wire_edge_marks:
 inc wire_edge_stamp
 bne cwem_done
 jsr clear_all_wire_edge_marks
 inc wire_edge_stamp
cwem_done:
 rts

clear_all_wire_edge_marks:
 ldx #$00
 lda #$00
cawem_loop:
 cpx #WIRE_EDGE_COUNT
 beq cawem_done
 sta edge_drawn,x
 inx
 jmp cawem_loop
cawem_done:
 rts

draw_loaded_wire_face_unique:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlwfu_normal
 jmp draw_loaded_wire_face
dlwfu_normal:
.endif
 ldy faceidx
 lda face_edge0,y
 jsr mark_wire_edge_drawn
 bcc dlwfu_edge1
 lda vx0
 sta ex0
 lda vy0
 sta ey0
 lda vx1
 sta ex1
 lda vy1
 sta ey1
.if ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW != 0 && EXPLORER_SCREEN_CLIP_POLY != 0
 jsr draw_wire_edge
.else
 jsr draw_wire_edge_guarded
.endif
dlwfu_edge1:
 ldy faceidx
 lda face_edge1,y
 jsr mark_wire_edge_drawn
 bcc dlwfu_edge2
 lda vx1
 sta ex0
 lda vy1
 sta ey0
 lda vx2
 sta ex1
 lda vy2
 sta ey1
.if ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW != 0 && EXPLORER_SCREEN_CLIP_POLY != 0
 jsr draw_wire_edge
.else
 jsr draw_wire_edge_guarded
.endif
dlwfu_edge2:
 ldy faceidx
 lda face_edge2,y
 jsr mark_wire_edge_drawn
 bcc dlwfu_edge3
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 beq dlwfu_edge2_quad
 lda vx2
 sta ex0
 lda vy2
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
.if ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW != 0 && EXPLORER_SCREEN_CLIP_POLY != 0
 jsr draw_wire_edge
.else
 jsr draw_wire_edge_guarded
.endif
 rts
dlwfu_edge2_quad:
.endif
 lda vx2
 sta ex0
 lda vy2
 sta ey0
 lda vx3
 sta ex1
 lda vy3
 sta ey1
.if ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW != 0 && EXPLORER_SCREEN_CLIP_POLY != 0
 jsr draw_wire_edge
.else
 jsr draw_wire_edge_guarded
.endif
dlwfu_edge3:
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne dlwfu_done
.endif
 ldy faceidx
 lda face_edge3,y
 jsr mark_wire_edge_drawn
 bcc dlwfu_done
 lda vx3
 sta ex0
 lda vy3
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
.if ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW != 0 && EXPLORER_SCREEN_CLIP_POLY != 0
 jsr draw_wire_edge
.else
 jsr draw_wire_edge_guarded
.endif
dlwfu_done:
 rts

mark_wire_edge_drawn:
 tax
 lda edge_drawn,x
 cmp wire_edge_stamp
 beq mwed_skip
 lda wire_edge_stamp
 sta edge_drawn,x
.if WIRE_EDGE_SOLID_COLOR_ENABLE != 0
 jsr load_wire_edge_solid_color_x
.endif
 sec
 rts
mwed_skip:
 clc
 rts

.endif

.if FACE_RENDER_ENABLE != 0
.if MODE2_FACE_BUCKET_PIPELINE = 0
draw_wire_faces_mesh:
 lda #$aa
 sta fillbyte
.if WIRE_FACE_EDGE_ENABLE != 0
 jsr clear_wire_edge_marks
.endif
 lda active_face_first
 sta faceidx
dwfm_loop:
 lda faceidx
 cmp active_face_end
 beq dwfm_done
 sta sortj
 tay
 jsr load_face_y
 bcc dwfm_next
.if FACE_SOLID_COLOR_ENABLE != 0
 ldy sortj
 jsr load_face_solid_color_y
.endif
.if WIRE_FACE_EDGE_ENABLE != 0
 jsr draw_loaded_wire_face_unique
.else
 jsr draw_loaded_wire_face
.endif
dwfm_next:
 inc faceidx
 jmp dwfm_loop
dwfm_done:
 rts
.endif

draw_loaded_wire_face:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlwf_normal
 jmp draw_clip_wire_poly
dlwf_normal:
.endif
 lda vx0
 sta ex0
 lda vy0
 sta ey0
 lda vx1
 sta ex1
 lda vy1
 sta ey1
 jsr draw_wire_edge_guarded
 lda vx1
 sta ex0
 lda vy1
 sta ey0
 lda vx2
 sta ex1
 lda vy2
 sta ey1
 jsr draw_wire_edge_guarded
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 beq dlwf_quad
 lda vx2
 sta ex0
 lda vy2
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr draw_wire_edge_guarded
 rts
dlwf_quad:
.endif
 lda vx2
 sta ex0
 lda vy2
 sta ey0
 lda vx3
 sta ex1
 lda vy3
 sta ey1
 jsr draw_wire_edge_guarded
 lda vx3
 sta ex0
 lda vy3
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr draw_wire_edge_guarded
 rts

.if EXPLORER_SCREEN_CLIP_POLY != 0
draw_clip_wire_poly:
 lda clip_a_count
 cmp #$02
 bcc dcwp_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
dcwp_loop:
 ldx clip_prev_idx
 lda clip_a_x,x
 sta ex0
 lda clip_a_y,x
 sta ey0
 ldx clip_cur_idx
 lda clip_a_x,x
 sta ex1
 lda clip_a_y,x
 sta ey1
 jsr draw_clip_wire_edge_guarded
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne dcwp_loop
dcwp_done:
 rts

draw_clip_wire_edge_guarded:
 jsr clip_wire_edge_is_generated_cap
 bcs dcweg_skip
 jsr clip_wire_edge_is_screen_border
 bcs dcweg_skip
 jsr draw_wire_edge_guarded
dcweg_skip:
 rts

clip_wire_edge_is_generated_cap:
 ldx clip_prev_idx
 lda clip_a_flag,x
 beq cwigc_draw
 ldx clip_cur_idx
 lda clip_a_flag,x
 beq cwigc_draw
 sec
 rts
cwigc_draw:
 clc
 rts

clip_wire_edge_is_screen_border:
 lda ex0
 bne cwe_not_left
 lda ex1
 bne cwe_not_left
 sec
 rts
cwe_not_left:
 lda ex0
 cmp #PROJ_SCREEN_MAX_X
 bne cwe_not_right
 lda ex1
 cmp #PROJ_SCREEN_MAX_X
 bne cwe_not_right
 sec
 rts
cwe_not_right:
 lda ey0
 bne cwe_not_top
 lda ey1
 bne cwe_not_top
 sec
 rts
cwe_not_top:
 lda ey0
 cmp #PROJ_SCREEN_MAX_Y
 bne cwe_draw
 lda ey1
 cmp #PROJ_SCREEN_MAX_Y
 bne cwe_draw
 sec
 rts
cwe_draw:
 clc
 rts
.endif

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
* = $4000
.if CAMERA_MOVABLE != 0
.endif
.endif
draw_wire_edge_guarded:
 lda ex0
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dweg_skip
 lda ey0
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dweg_skip
 lda ex1
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs dweg_skip
 lda ey1
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs dweg_skip
 jmp draw_wire_edge
dweg_skip:
 rts
.endif

draw_wire_edge:
.if POLY_FILL_ENABLE = 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda #$01
 sta wire_trace_active
 jsr trace_edge_convex
 lda #$00
 sta wire_trace_active
 rts
.else
 jmp trace_edge_convex
.endif
.else
 lda #$01
 sta wire_trace_active
 jsr trace_edge_convex
 lda #$00
 sta wire_trace_active
 rts
.endif
.endif

render_scene_objects:
.if SCENE_OBJECT_COUNT != 0
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && MODE2_FACE_BUCKET_PIPELINE = 0
.if WIRE_OBJECT_SORT_ENABLE != 0
 jsr draw_wire_scene_objects_sorted
.else
 lda #$00
 sta objidx
rso_wire_loop:
.if SCENE_OBJECT_VISIBILITY_ACTIVE != 0
 ldx objidx
 lda object_visible,x
 beq rso_wire_next_object
.endif
 jsr set_active_object
.if EXPLORER_TRAVERSAL_CULL != 0
 lda object_traverse_active
 bne rso_wire_next_object
.endif
 jsr prepare_angles
 jsr rotate_project_vertices
 jsr project_wire_vertices
 jsr draw_wire_active_mesh
rso_wire_next_object:
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bne rso_wire_loop
.endif
.else
 jsr begin_depth_buckets
 lda #$00
 sta objidx
rso_loop:
.if SCENE_OBJECT_VISIBILITY_ACTIVE != 0
 ldx objidx
 lda object_visible,x
 beq rso_next_object
.endif
 jsr set_active_object
.if WIRE_MESH_COUNT != 0
 ldx meshidx
 lda mesh_is_wire,x
 beq rso_solid_object
.if WORLD_GROUND_OCCLUDE != 0 && POLY_FILL_ENABLE != 0
 jsr ground_object_visible
 beq rso_next_object
.endif
.if WIRE_DEPTH_SORT_ENABLE != 0
 jsr prepare_angles
 jsr rotate_project_vertices
 jsr project_wire_vertices
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0
 ldx meshidx
 lda mesh_face_first,x
 cmp mesh_face_end,x
 beq rso_wire_depth_edges
 jsr collect_active_mesh_faces
 jmp rso_next_object
rso_wire_depth_edges:
.endif
 jsr bucket_visible_wire_object
.endif
 jmp rso_next_object
rso_solid_object:
.endif
.if EXPLORER_TRAVERSAL_CULL != 0
 lda object_traverse_active
 bne rso_next_object
.endif
 jsr prepare_angles
.if MODE4_OBJECT_LIGHT_CACHE != 0
 jsr prepare_object_light_for_shade
.endif
 jsr rotate_project_vertices
 jsr collect_active_mesh_faces
rso_next_object:
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bne rso_loop
 jsr draw_depth_buckets
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0 && POLY_FILL_ENABLE = 0
 jsr draw_hidden_poly_scene_objects
.if WIRE_MESH_COUNT != 0
 jsr draw_front_wire_depth_entries
.endif
.endif
.if WIRE_OVERLAY_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE = 0
 jsr draw_wire_scene_objects
.endif
.endif
.endif
 rts

; LEGACY_OBJECT_SORT_ROUTINES_BEGIN
.if WIRE_OBJECT_SORT_ENABLE != 0 && SCENE_OBJECT_COUNT != 0
draw_wire_scene_objects_sorted:
.if CAMERA_MOVABLE != 0
 jsr explorer_cache_current_view
.endif
 ldx #$00
 lda #$00
dwoss_clear_loop:
 sta object_sort_drawn,x
 inx
 cpx #SCENE_OBJECT_COUNT
 bne dwoss_clear_loop
 lda #SCENE_OBJECT_COUNT
 sta wire_object_sort_remaining
dwoss_outer_loop:
 lda wire_object_sort_remaining
 beq dwoss_done
 lda #$ff
 sta wire_object_sort_best_obj
 lda #$00
 sta wire_object_sort_best_lo
 lda #$80
 sta wire_object_sort_best_hi
 lda #$00
 sta sorti
dwoss_scan_loop:
 ldx sorti
 lda object_sort_drawn,x
 bne dwoss_next_candidate
.if SCENE_OBJECT_VISIBILITY_ACTIVE != 0
 lda object_visible,x
 beq dwoss_next_candidate
.endif
 stx objidx
 jsr set_active_object
.if EXPLORER_TRAVERSAL_CULL != 0
 lda object_traverse_active
 bne dwoss_next_candidate
.endif
.if WORLD_GROUND_OCCLUDE != 0 && HIDDEN_WIRE_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WORLD_GROUND_WIRE_OCCLUDE = 0
 jsr ground_object_visible
 beq dwoss_next_candidate
.endif
 jsr wire_object_sort_depth
 lda wire_object_sort_best_obj
 cmp #$ff
 beq dwoss_take_candidate
 lda wire_object_sort_cur_hi
 eor wire_object_sort_best_hi
 bmi dwoss_signs_differ
 lda wire_object_sort_cur_hi
 cmp wire_object_sort_best_hi
 bcc dwoss_next_candidate
 bne dwoss_take_candidate
 lda wire_object_sort_cur_lo
 cmp wire_object_sort_best_lo
 bcc dwoss_next_candidate
.if MODE1_OBJECT_DEPTH_SORT != 0
 beq dwoss_next_candidate
.endif
 jmp dwoss_take_candidate
dwoss_signs_differ:
 lda wire_object_sort_cur_hi
 bmi dwoss_next_candidate
dwoss_take_candidate:
 lda sorti
 sta wire_object_sort_best_obj
 lda wire_object_sort_cur_lo
 sta wire_object_sort_best_lo
 lda wire_object_sort_cur_hi
 sta wire_object_sort_best_hi
dwoss_next_candidate:
 inc sorti
 lda sorti
 cmp #SCENE_OBJECT_COUNT
 bne dwoss_scan_loop
 lda wire_object_sort_best_obj
 cmp #$ff
 beq dwoss_done
 tax
 lda #$01
 sta object_sort_drawn,x
 dec wire_object_sort_remaining
 stx objidx
 jsr draw_wire_sorted_active_object
 jmp dwoss_outer_loop
dwoss_done:
 rts

wire_object_sort_depth:
.if CAMERA_MOVABLE != 0
 lda obj_pos_x_cur
 jsr explorer_sub_cam_x
 lda obj_pos_y_cur
 jsr explorer_sub_cam_y
 lda obj_depth_lo
 sta rz1
 lda obj_depth_hi
 sta explorer_z_world_hi
 jsr explorer_sub_cam_z16
 ; Object sorting uses the same signed geometric depth as clipping/buckets.
 lda explorer_rel_x_lo
 sta p1lo
 lda explorer_rel_x_hi
 sta p1hi
 lda sinyv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda rz1
 sta p1lo
 lda explorer_z_hi16
 sta p1hi
 lda cosyv
 jsr mul_s16_s6
 clc
 lda p1lo
 adc t1
 sta explorer_view_z_lo
 lda p1hi
 adc t2
 sta explorer_view_z_hi
 lda explorer_rel_y_lo
 sta p1lo
 lda explorer_rel_y_hi
 sta p1hi
 lda sinxv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda explorer_view_z_lo
 sta p1lo
 lda explorer_view_z_hi
 sta p1hi
 lda cosxv
 jsr mul_s16_s6
 clc
 lda p1lo
 adc t1
 sta wire_object_sort_cur_lo
 lda p1hi
 adc t2
 sta wire_object_sort_cur_hi
.else
 lda obj_depth_lo
 sta wire_object_sort_cur_lo
 lda obj_depth_hi
 sta wire_object_sort_cur_hi
.endif
 rts

draw_wire_sorted_active_object:
 jsr set_active_object
.if EXPLORER_TRAVERSAL_CULL != 0
 lda object_traverse_active
 bne dwso_sorted_done
.endif
.if WORLD_GROUND_OCCLUDE != 0 && HIDDEN_WIRE_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WORLD_GROUND_WIRE_OCCLUDE = 0
 jsr ground_object_visible
 beq dwso_sorted_done
.endif
.if CAMERA_MOVABLE != 0
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_explorer_matrix_fold
.else
 jsr prepare_angles
 jsr explorer_load_cached_view
.endif
 jsr explorer_transform_project_vertices
.else
 jsr prepare_angles
 jsr rotate_project_vertices
 jsr project_wire_vertices
.endif
 jsr draw_wire_active_mesh
dwso_sorted_done:
 rts
.endif
; LEGACY_OBJECT_SORT_ROUTINES_END

.if WIRE_OVERLAY_ENABLE != 0 && SCENE_OBJECT_COUNT != 0
draw_wire_scene_objects:
 lda #$00
 sta objidx
dwso_loop:
.if SCENE_OBJECT_VISIBILITY_ACTIVE != 0
 ldx objidx
 lda object_visible,x
 beq dwso_next_object
.endif
 jsr set_active_object
 ldx meshidx
 lda mesh_is_wire,x
 beq dwso_next_object
.if EXPLORER_TRAVERSAL_CULL != 0
 lda object_traverse_active
 bne dwso_next_object
.endif
.if WORLD_GROUND_OCCLUDE != 0 && HIDDEN_WIRE_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WORLD_GROUND_WIRE_OCCLUDE = 0
 jsr ground_object_visible
 beq dwso_next_object
.endif
.if CAMERA_MOVABLE != 0
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_explorer_matrix_fold
.else
 jsr prepare_angles
 jsr explorer_prepare_view
.endif
 jsr explorer_transform_project_vertices
.else
 jsr prepare_angles
 jsr rotate_project_vertices
 jsr project_wire_vertices
.endif
 jsr draw_wire_active_mesh
dwso_next_object:
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bne dwso_loop
 rts
.endif

.if HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0 && POLY_FILL_ENABLE = 0 && SCENE_OBJECT_COUNT != 0
draw_hidden_poly_scene_objects:
 lda #$00
 sta objidx
dhpso_loop:
.if SCENE_OBJECT_VISIBILITY_ACTIVE != 0
 ldx objidx
 lda object_visible,x
 beq dhpso_next_object
.endif
 jsr set_active_object
.if WIRE_MESH_COUNT != 0
 ldx meshidx
 lda mesh_is_wire,x
 bne dhpso_next_object
.endif
.if EXPLORER_TRAVERSAL_CULL != 0
 lda object_traverse_active
 bne dhpso_next_object
.endif
.if WORLD_GROUND_OCCLUDE != 0 && HIDDEN_WIRE_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WORLD_GROUND_WIRE_OCCLUDE = 0
 jsr ground_object_visible
 beq dhpso_next_object
.endif
.if CAMERA_MOVABLE != 0
.if EXPLORER_MATRIX_FOLD != 0
 jsr prepare_explorer_matrix_fold
.else
 jsr prepare_angles
 jsr explorer_prepare_view
.endif
 jsr explorer_transform_project_vertices
.else
 jsr prepare_angles
 jsr rotate_project_vertices
 jsr project_wire_vertices
.endif
 jsr draw_wire_active_mesh
dhpso_next_object:
 inc objidx
 lda objidx
 cmp #SCENE_OBJECT_COUNT
 bne dhpso_loop
 rts
.if WIRE_MESH_COUNT != 0
draw_front_wire_depth_entries:
 lda hidden_solid_near_bucket
 beq dfwde_done
 cmp #$ff
 beq dfwde_done
 tax
dfwde_bucket_loop:
 dex
 stx sorti
 lda wire_bucket_head,x
 cmp #$ff
 beq dfwde_next_bucket
 sta wire_entry_cursor
dfwde_wire_loop:
 jsr draw_bucket_wire_object
 ldx wire_entry_cursor
 lda wire_next,x
 cmp #$ff
 beq dfwde_next_bucket
 sta wire_entry_cursor
 jmp dfwde_wire_loop
dfwde_next_bucket:
 ldx sorti
 cpx #$00
 bne dfwde_bucket_loop
dfwde_done:
 rts
.endif
.endif

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && ((POLY_FILL_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0) || (MODE2_FACE_BUCKET_PIPELINE != 0 && CAMERA_MOVABLE != 0))
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
* = $4000
.endif

.if POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0
begin_depth_buckets:
 jsr clear_depth_buckets
.if HIDDEN_WIRE_ENABLE != 0
 jsr clear_hidden_face_depths
.endif
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0
 jsr clear_wire_edge_marks
.endif
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WIRE_MESH_COUNT != 0
 lda #$ff
 sta hidden_solid_near_bucket
.endif
 lda #$ff
 sta bucket_min
 lda #$00
 sta bucket_max
 rts

collect_active_mesh_faces:
 lda active_face_first
 sta faceidx
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx objidx
 lda object_runtime_face_first,x
 sta shared_runtime_face
.endif
dm_collect_loop:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 jsr shared_prepare_face_vertices
.endif
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
 ldy faceidx
 lda #$00
 sta frame_face_prepare,y
.endif
 jsr load_face_visible
dm_skip:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 inc shared_runtime_face
.endif
 inc faceidx
 lda faceidx
 cmp active_face_end
 bne dm_collect_loop
 rts

.if MESH_SOURCE_SHARING_RUNTIME != 0
; Resolve the source-local topology once. All clipping, culling and raster
; consumers reuse these four runtime vertex ids for the current instance.
shared_source_face0 = face0
shared_source_face1 = face1
shared_source_face2 = face2
shared_source_face3 = face3
shared_prepare_face_vertices:
 ldy faceidx
 clc
 lda shared_source_face0,y
 adc shared_vertex_delta
 sta shared_fv0
 clc
 lda shared_source_face1,y
 adc shared_vertex_delta
 sta shared_fv1
 clc
 lda shared_source_face2,y
 adc shared_vertex_delta
 sta shared_fv2
 clc
 lda shared_source_face3,y
 adc shared_vertex_delta
 sta shared_fv3
 rts
.endif

clear_depth_buckets:
.if WIRE_DEPTH_SORT_ENABLE != 0
 lda #$00
 sta wire_depth_entry_used
.endif
 ldx bucket_used_count
 beq cdb_done
cdb_loop:
 dex
 lda bucket_used_list,x
 tay
 lda #$ff
 sta bucket_head,y
.if WIRE_DEPTH_SORT_ENABLE != 0
 sta wire_bucket_head,y
.endif
 cpx #$00
 bne cdb_loop
cdb_done:
 lda #$00
 sta bucket_used_count
 rts

.if HIDDEN_WIRE_ENABLE != 0
clear_hidden_face_depths:
 ldx #$00
chfd_loop:
 lda #$ff
 sta frame_face_shade,x
 inx
 cpx #FACE_COUNT
 bne chfd_loop
 rts
.endif

bucket_visible_face:
.if CAMERA_PLANE_CLIP_PROFILE != 0
 lda camera_plane_bucket_ready
 beq bvf_camera_plane_original
 lda camera_plane_bucket_depth
 sta p1lo
 jmp bvf_depth_ready
bvf_camera_plane_original:
.endif
; Mode 4 fixed uses the same full 16-bit depth reduction as walkLite/walkFull.
.if CAMERA_MOVABLE != 0 || GRAPHICS_MODE = $04 || GRAPHICS_MODE = $05
 ldy faceidx
 lda face0,y
 tax
 lda sz,x
 sta p1lo
 lda szhi,x
 sta p1hi
 lda face2,y
 tax
 clc
 lda p1lo
 adc sz,x
 sta p1lo
 lda p1hi
 adc szhi,x
 sta p1hi
 bcc bvf_explorer_depth_sum_ok
 lda #$ff
 sta p1hi
 sta p1lo
bvf_explorer_depth_sum_ok:
 lsr p1hi
 ror p1lo
 ldx #$02
bvf_explorer_depth_shift:
 lsr p1hi
 ror p1lo
 dex
 bne bvf_explorer_depth_shift
 lda p1hi
 beq bvf_explorer_depth_ready
 lda #$fe
 sta p1lo
 jmp bvf_depth_ready
bvf_explorer_depth_ready:
 lda p1lo
 cmp #$ff
 bne bvf_depth_ready
 lda #$fe
 sta p1lo
.else
 ldy faceidx
 lda face0,y
 tax
 lda szhi,x
 bne bvf_sat_depth
 lda sz,x
 sta p1lo
 lda #$00
 sta p1hi
 lda face2,y
 tax
 lda szhi,x
 bne bvf_sat_depth
 clc
 lda p1lo
 adc sz,x
 sta p1lo
 bcc bvf_engine_depth_sum_ok
 inc p1hi
bvf_engine_depth_sum_ok:
 lsr p1hi
 ror p1lo
 jmp bvf_depth_ready
bvf_sat_depth:
 lda #$fe
 sta p1lo
.endif
bvf_depth_ready:
.if MODE2_FACE_BUCKET_PIPELINE != 0
 ldy faceidx
 lda objidx
 sta face_object,y
.endif
.if HIDDEN_WIRE_ENABLE != 0
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy shared_runtime_face
.else
 ldy faceidx
.endif
 lda p1lo
 sta frame_face_shade,y
.endif
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WIRE_MESH_COUNT != 0
 ldy faceidx
 lda face_mesh_is_wire,y
 bne bvf_solid_near_done
 lda p1lo
 cmp hidden_solid_near_bucket
 bcs bvf_solid_near_done
 sta hidden_solid_near_bucket
bvf_solid_near_done:
.endif
 lda p1lo
 tax
 cmp bucket_min
 bcs bvf_min_ok
 sta bucket_min
bvf_min_ok:
 cmp bucket_max
 bcc bvf_max_ok
 sta bucket_max
bvf_max_ok:
 lda bucket_head,x
 cmp #$ff
 bne bvf_link_head
bvf_empty:
 txa
 ldy bucket_used_count
 sta bucket_used_list,y
 inc bucket_used_count
 lda #$ff
bvf_link_head:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy shared_runtime_face
.else
 ldy faceidx
.endif
 sta face_next,y
 tya
 sta bucket_head,x
 rts

.if WIRE_DEPTH_SORT_ENABLE != 0
bucket_visible_wire_object:
 ldx meshidx
 lda mesh_edge_end,x
 sta sortj
 lda mesh_edge_first,x
 sta faceidx
bvwe_loop:
 lda faceidx
 cmp sortj
 beq bvwe_done
 tay
 lda edge0,y
 sta clip_prev_idx
 tax
 jsr wire_vertex_drawable
 beq bvwe_next
 lda sz,x
 sta p1lo
 lda szhi,x
 sta p1hi
 ldy faceidx
 lda edge1,y
 sta clip_cur_idx
 tax
 jsr wire_vertex_drawable
 beq bvwe_next
.if WORLD_GROUND_OCCLUDE != 0 && POLY_FILL_ENABLE = 0
 jsr ground_wire_edge_visible
 beq bvwe_next
 ldx clip_cur_idx
.endif
 clc
 lda p1lo
 adc sz,x
 sta p1lo
 lda p1hi
 adc szhi,x
 sta p1hi
 bcc bvwe_depth_sum_ok
 lda #$ff
 sta p1hi
 sta p1lo
bvwe_depth_sum_ok:
.if CAMERA_MOVABLE != 0
 lsr p1hi
 ror p1lo
 lsr p1hi
 ror p1lo
 lsr p1hi
 ror p1lo
.else
 lsr p1hi
 ror p1lo
.endif
bvwe_depth_ready:
 lda p1hi
 beq bvwe_depth_low_ready
 lda #$fe
 jmp bvwe_store_depth
bvwe_depth_low_ready:
 lda p1lo
 cmp #$ff
 bne bvwe_store_depth
 lda #$fe
bvwe_store_depth:
.if WIRE_DEPTH_NEAR_BIAS != 0
 cmp #WIRE_DEPTH_NEAR_BIAS
 bcc bvwe_depth_biased
 sec
 sbc #WIRE_DEPTH_NEAR_BIAS
bvwe_depth_biased:
.endif
 sta tmpidx
.if EXPLORER_SCREEN_CLIP_POLY != 0 && EXPLORER_SCREEN_RAW != 0
 jsr clip_wire_edge_screen
 beq bvwe_next
.else
 ldx clip_prev_idx
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs bvwe_next
 sta ex0
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs bvwe_next
 sta ey0
 ldx clip_cur_idx
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs bvwe_next
 sta ex1
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs bvwe_next
 sta ey1
.endif
 lda wire_depth_entry_used
 cmp #WIRE_DEPTH_ENTRY_COUNT
 bcs bvwe_next
 lda tmpidx
 tax
 cmp bucket_min
 bcs bvwe_min_ok
 sta bucket_min
bvwe_min_ok:
 cmp bucket_max
 bcc bvwe_max_ok
 sta bucket_max
bvwe_max_ok:
 lda bucket_head,x
 cmp #$ff
 bne bvwe_link_entry
 lda wire_bucket_head,x
 cmp #$ff
 bne bvwe_link_entry
 txa
 ldy bucket_used_count
 sta bucket_used_list,y
 inc bucket_used_count
bvwe_link_entry:
 ldy wire_depth_entry_used
 lda objidx
 sta wire_entry_obj,y
 lda ex0
 sta wire_entry_x0,y
 lda ey0
 sta wire_entry_y0,y
 lda ex1
 sta wire_entry_x1,y
 lda ey1
 sta wire_entry_y1,y
 ldx tmpidx
 lda wire_bucket_head,x
 sta wire_next,y
 tya
 sta wire_bucket_head,x
 inc wire_depth_entry_used
bvwe_next:
 inc faceidx
 jmp bvwe_loop
bvwe_done:
 rts

draw_bucket_wire_object:
 ldx wire_entry_cursor
.if WIRE_OBJECT_MATERIAL_ENABLE != 0
 lda wire_entry_obj,x
 tax
 lda object_wire_screen,x
 sta material_screen_cur
 lda object_wire_color,x
 sta material_color_cur
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 ldx wire_entry_cursor
.endif
 lda #$aa
 sta fillbyte
 lda wire_entry_x0,x
 sta ex0
 lda wire_entry_y0,x
 sta ey0
 lda wire_entry_x1,x
 sta ex1
 lda wire_entry_y1,x
 sta ey1
 jmp draw_wire_edge_guarded
.endif

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE = 0
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
.if MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0
mode3_high_basic_low_segment_end = *
.endif
* = $4000
.if MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0
mode3_high_basic_middle_start = *
.endif
.endif

.if VIC_COLOR_POLICY_ENABLE != 0
vic_color_policy_reset_frame:
 lda #$00
 sta vic_color_cells_touched_lo
 sta vic_color_cells_touched_hi
 sta vic_color_conflict_count_lo
 sta vic_color_conflict_count_hi
 sta vic_color_fallback_count_lo
 sta vic_color_fallback_count_hi
 sta vic_color_fill_fallback_lo
 sta vic_color_fill_fallback_hi
 sta vic_color_wire_fallback_lo
 sta vic_color_wire_fallback_hi
 sta vic_color_max_colors_per_cell
 lda #$01
 sta vic_color_source
 ldx #$00
 lda #$ff
vcpf_clear_owner_pages:
 sta vic_color_owner_screen,x
 sta vic_color_owner_screen+$0100,x
 sta vic_color_owner_screen+$0200,x
 sta vic_color_owner_color,x
 sta vic_color_owner_color+$0100,x
 sta vic_color_owner_color+$0200,x
 inx
 bne vcpf_clear_owner_pages
 ldx #$00
 lda #$ff
vcpf_clear_owner_tail:
 sta vic_color_owner_screen+$0300,x
 sta vic_color_owner_color+$0300,x
 inx
 cpx #$e8
 bne vcpf_clear_owner_tail
.if VIC_COLOR_POLICY_OVERLAY != 0
 ldx #$00
 lda #$00
vcpf_clear_conflict_pages:
 sta vic_color_conflict_map,x
 sta vic_color_conflict_map+$0100,x
 sta vic_color_conflict_map+$0200,x
 inx
 bne vcpf_clear_conflict_pages
 ldx #$00
 lda #$00
vcpf_clear_conflict_tail:
 sta vic_color_conflict_map+$0300,x
 inx
 cpx #$e8
 bne vcpf_clear_conflict_tail
.endif
 rts

vic_color_policy_claim_cell:
 stx vic_color_saved_x
 tya
 pha
 ldx yrow
 txa
 lsr
 lsr
 tax
 lda vic_color_owner_screen_rowlo,x
 sta p1lo
 lda vic_color_owner_screen_rowhi,x
 sta p1hi
 lda vic_color_owner_color_rowlo,x
 sta shadeptrlo
 lda vic_color_owner_color_rowhi,x
 sta shadeptrhi
 ldx vic_color_saved_x
 txa
 tay
 lda (p1lo),y
 cmp #$ff
 beq vcpc_new_owner
 cmp material_screen_cur
 bne vcpc_conflict
 lda (shadeptrlo),y
 cmp material_color_cur
 bne vcpc_conflict
vcpc_allow:
 pla
 tay
 ldx vic_color_saved_x
 sec
 rts
vcpc_new_owner:
 lda material_screen_cur
 sta (p1lo),y
 lda material_color_cur
 sta (shadeptrlo),y
 inc vic_color_cells_touched_lo
 bne vcpc_new_max
 inc vic_color_cells_touched_hi
vcpc_new_max:
 lda vic_color_max_colors_per_cell
 bne vcpc_allow
 lda #$01
 sta vic_color_max_colors_per_cell
 jmp vcpc_allow
vcpc_conflict:
 inc vic_color_conflict_count_lo
 bne vcpc_conflict_max
 inc vic_color_conflict_count_hi
vcpc_conflict_max:
 lda #$02
 sta vic_color_max_colors_per_cell
.if VIC_COLOR_POLICY_OVERLAY != 0
 ldx yrow
 txa
 lsr
 lsr
 tax
 lda vic_color_conflict_rowlo,x
 sta p1lo
 lda vic_color_conflict_rowhi,x
 sta p1hi
 lda #$01
 sta (p1lo),y
.endif
.if VIC_COLOR_POLICY_ACTIVE != 0
 inc vic_color_fallback_count_lo
 bne vcpc_source_count
 inc vic_color_fallback_count_hi
vcpc_source_count:
 lda vic_color_source
 cmp #$02
 beq vcpc_wire_fallback
 inc vic_color_fill_fallback_lo
 bne vcpc_policy
 inc vic_color_fill_fallback_hi
 jmp vcpc_policy
vcpc_wire_fallback:
 inc vic_color_wire_fallback_lo
 bne vcpc_policy
 inc vic_color_wire_fallback_hi
vcpc_policy:
.if VIC_COLOR_FALLBACK_MODE = $01
 jmp vcpc_take_new_owner
.endif
.if VIC_COLOR_FALLBACK_MODE = $02
 lda vic_color_source
 cmp #$02
 beq vcpc_take_new_owner
.endif
.if VIC_COLOR_FALLBACK_MODE = $03
 jsr vic_color_policy_lowres_compat
 bcs vcpc_take_new_owner
.endif
vcpc_block:
 pla
 tay
 ldx vic_color_saved_x
 clc
 rts
vcpc_take_new_owner:
 lda material_screen_cur
 sta (p1lo),y
 lda material_color_cur
 sta (shadeptrlo),y
 jmp vcpc_allow
.if VIC_COLOR_FALLBACK_MODE = $03
; Compat fallback: prefer the most readable VIC-II lowres color, with a small
; bias for wire sources so outlines stay visible without winning every conflict.
vic_color_policy_lowres_compat:
 lda (shadeptrlo),y
 tax
 lda vic_color_lowres_luma,x
 sta vic_color_owner_luma
 lda material_color_cur
 tax
 lda vic_color_lowres_luma,x
 ldx vic_color_source
 cpx #$02
 bne vclc_compare
 clc
 adc #$02
vclc_compare:
 cmp vic_color_owner_luma
 bcc vclc_no
 sec
 rts
vclc_no:
 clc
 rts
.endif
.else
 jmp vcpc_allow
.endif

.endif



; WORLD_GROUND_RENDERER_PLACEHOLDER
draw_depth_buckets:
 lda bucket_min
 cmp #$ff
 beq ddb_done
.if WIRE_TWO_COLOR_MODE2_ENABLE != 0
 jsr activate_wire_two_color_palette
.endif
 jsr select_draw_paths
 lda bucket_max
 tax
ddb_bucket:
 stx sorti
.if WIRE_DEPTH_SORT_ENABLE != 0
 lda wire_bucket_head,x
 cmp #$ff
 beq ddb_face_bucket
 sta wire_entry_cursor
ddb_wire_loop:
 jsr draw_bucket_wire_object
 ldx wire_entry_cursor
 lda wire_next,x
 cmp #$ff
 beq ddb_face_bucket
 sta wire_entry_cursor
 jmp ddb_wire_loop
ddb_face_bucket:
 ldx sorti
.endif
 lda bucket_head,x
 cmp #$ff
 beq ddb_next_bucket
.if MODE4_FACE_ID_LATCH != 0
 ; Exact four-byte replacement for STA sortj / LDY sortj below.
 jmp mode4_latch_current_face_id
 nop
.else
 sta sortj
.endif
ddb_face_loop:
.if MESH_SOURCE_SHARING_RUNTIME != 0
 jsr shared_resolve_bucket_face
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy faceidx
.else
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
.endif
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
 lda frame_face_prepare,y
 beq ddb_face_full_load
 jsr engine_mode3_load_prepared_face_y
 jmp ddb_face_load_done
ddb_face_full_load:
.endif
 jsr load_face_y
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
ddb_face_load_done:
.endif
 bcc ddb_after_draw
.if SCENE_OBJECT_COUNT != 0
.if CAMERA_MOVABLE != 0
.if CONSERVATIVE_SLIVER_CULL != 0
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
 ldy sortj
 lda frame_face_prepare,y
 bne ddb_sliver_ready
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 bne ddb_skip_sliver
.endif
 jsr face_far_depth
 bne ddb_skip_sliver
 jsr face_conservative_sliver
 beq ddb_after_draw
ddb_skip_sliver:
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
ddb_sliver_ready:
.endif
.endif
.endif
.endif
.if HIDDEN_WIRE_ENABLE != 0
 lda #$00
 sta fillbyte
ddb_hidden_mask_call:
 jsr draw_loaded_face_solid_a
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0 && WIRE_MESH_COUNT != 0
 ldy sortj
 lda face_mesh_is_wire,y
 bne ddb_hidden_draw_face_edges
.if EXPLORER_SCREEN_CLIP_X != 0
 jsr draw_clip_second_load
 bcc ddb_after_draw
 lda #$00
 sta fillbyte
ddb_hidden_mask_second_only_call:
 jsr draw_loaded_face_solid_a
.endif
 jmp ddb_after_draw
ddb_hidden_draw_face_edges:
.endif
.if WIRE_TWO_COLOR_MODE2_ENABLE != 0
 ldy sortj
 jsr load_wire_two_color_face_pattern_y
.else
.if FACE_SOLID_COLOR_ENABLE != 0
 ldy sortj
 jsr load_face_solid_color_y
 bcs ddb_hidden_wire_color_ready
.endif
 lda #$aa
 sta fillbyte
ddb_hidden_wire_color_ready:
.if MODE2_FACE_BUCKET_PIPELINE != 0 && WIRE_OBJECT_MATERIAL_ENABLE != 0
 jsr restore_face_owner_wire_color
.endif
.endif
.if MODE2_FACE_BUCKET_PIPELINE != 0
 jsr draw_loaded_wire_face
.else
 jsr draw_loaded_wire_face_unique
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
 jsr draw_clip_second_load
 bcc ddb_after_draw
 lda #$00
 sta fillbyte
ddb_hidden_mask_second_call:
 jsr draw_loaded_face_solid_a
.if WIRE_TWO_COLOR_MODE2_ENABLE != 0
 ldy sortj
 jsr load_wire_two_color_face_pattern_y
.else
.if FACE_SOLID_COLOR_ENABLE != 0
 ldy sortj
 jsr load_face_solid_color_y
 bcs ddb_hidden_wire_color_second_ready
.endif
 lda #$aa
 sta fillbyte
ddb_hidden_wire_color_second_ready:
.if MODE2_FACE_BUCKET_PIPELINE != 0 && WIRE_OBJECT_MATERIAL_ENABLE != 0
 jsr restore_face_owner_wire_color
.endif
.endif
.if MODE2_FACE_BUCKET_PIPELINE != 0
 jsr draw_loaded_wire_face
.else
 jsr draw_loaded_wire_face_unique
.endif
.endif
 jmp ddb_after_draw
.endif
.if HIDDEN_WIRE_ENABLE = 0
.if FACE_SOLID_COLOR_ENABLE != 0
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
 jsr load_face_solid_color_y
 bcs ddb_solid_call
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
 jsr load_face_material
.endif
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
.if STATIC_SHADE_DIRECT != 0
 lda face_shade,y
 bmi ddb_pattern
 lda face_static_fill,y
 sta fillbyte
 jmp ddb_solid_call
.else
.if DYNAMIC_LIGHT != 0 || STATIC_SHADE_CACHE != 0
.if MODE4_VALID_SHADE_FACE_PROBE != 0
 ; Exact three-byte replacement for LDA frame_face_shade,Y.  The probe
 ; supplies a full, valid RC4 code and re-enters the ordinary A/B wrappers.
 jmp mode4_valid_shade_face_probe_dispatch
.else
 lda frame_face_shade,y
.endif
.else
 lda #$04
.endif
 bmi ddb_pattern
.if FRAME_FACE_FILL_CACHE != 0
 lda frame_face_fill,y
 sta fillbyte
 jmp ddb_solid_call
.else
 tay
ddb_solid_from_y:
 lda shade_solid_bytes,y
 sta fillbyte
.endif
.endif
ddb_solid_call:
 jsr draw_loaded_face_solid_a
.if MODE5_POLYGON_OUTLINE != 0
 jsr mode5_draw_loaded_polygon_outline
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
 jsr draw_clip_second_solid
.endif
 jmp ddb_after_draw
ddb_pattern:
.if MODE4_PATTERN_PROBE != 0
 ; Preserve the four-byte footprint of AND/STA below: the protected XYQ2
 ; builder and trace therefore retain their validated code addresses.
 jmp mode4_pattern_probe_dispatch
 nop
.else
 and #$7f
 sta shadeidx
.endif
.if PATTERN_MIN_SPAN != 0
.if MODE4_PATTERN_PROBE = 0 && MODE4_PATTERN_PROBE_LATCHED_FACE = 0
 lda spanw
 cmp #PATTERN_MIN_SPAN
 bcc ddb_pattern_as_solid
 lda spanh
 cmp #PATTERN_MIN_SPAN
 bcc ddb_pattern_as_solid
.endif
.endif
ddb_pattern_call:
 jsr draw_loaded_face_pattern_a
.if MODE5_POLYGON_OUTLINE != 0
 jsr mode5_draw_loaded_polygon_outline
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
 jsr draw_clip_second_pattern
.endif
.if PATTERN_MIN_SPAN != 0
 jmp ddb_after_draw
ddb_pattern_as_solid:
 lda shadeidx
.endif
ddb_pattern_zero_solid:
.if STATIC_SHADE_DIRECT != 0
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
 lda face_static_fill,y
 sta fillbyte
 jmp ddb_solid_call
.else
.if FRAME_FACE_FILL_CACHE != 0
.if MODE4_FACE_ID_LATCH != 0
 ldy mode4_current_face_id
.else
 ldy sortj
.endif
 lda frame_face_fill,y
 sta fillbyte
 jmp ddb_solid_call
.else
 tay
 jmp ddb_solid_from_y
.endif
.endif
.endif
ddb_after_draw:
.if MODE4_FACE_ID_LATCH != 0
 ldx mode4_current_face_id
.else
 ldx sortj
.endif
 lda face_next,x
 cmp #$ff
 beq ddb_next_bucket
.if MODE4_FACE_ID_LATCH != 0
 ; Exact five-byte replacement for STA sortj / JMP ddb_face_loop below.
 jmp mode4_latch_current_face_id
 nop
 nop
.else
 sta sortj
 jmp ddb_face_loop
.endif
ddb_next_bucket:
 ldx sorti
 cpx bucket_min
 beq ddb_done
 dex
 jmp ddb_bucket
ddb_done:
 rts

.if MESH_SOURCE_SHARING_RUNTIME != 0
; A bucket node is a runtime face id. Its two compact identity tables resolve
; the owning instance and source-local face without duplicating topology.
shared_resolve_bucket_face:
 ldy sortj
 sty shared_runtime_face
 lda bucket_face_instance,y
 sta objidx
 tax
 lda object_mesh,x
 sta meshidx
 lda object_source_vertex_delta,x
 sta shared_vertex_delta
 lda bucket_face_local,y
 ldx meshidx
 clc
 adc mesh_face_first,x
 sta faceidx
 jsr shared_prepare_face_vertices
.if CAMERA_PLANE_CLIP_PROFILE != 0
 jsr camera_plane_face_classify
.endif
 rts
.endif

.if EXPLORER_SCREEN_CLIP_X != 0
draw_clip_second_load:
 lda clip_second_pending
 beq dcsl_no
 lda #$00
 sta clip_second_pending
 lda clip_second_count
 sta loaded_face_vertex_count
 lda clip2_vx0
 sta vx0
 lda clip2_vy0
 sta vy0
 lda clip2_vx1
 sta vx1
 lda clip2_vy1
 sta vy1
 lda clip2_vx2
 sta vx2
 lda clip2_vy2
 sta vy2
 lda clip_second_count
 cmp #$04
 beq dcsl_load_v3
 lda clip2_vx2
 sta vx3
 lda clip2_vy2
 sta vy3
 sec
 rts
dcsl_load_v3:
 lda clip2_vx3
 sta vx3
 lda clip2_vy3
 sta vy3
 sec
 rts
dcsl_no:
 clc
 rts

draw_clip_second_solid:
 jsr draw_clip_second_load
 bcc dcss_done
 jsr draw_loaded_face_solid_a
.if MODE5_POLYGON_OUTLINE != 0
 jsr mode5_draw_loaded_polygon_outline
.endif
dcss_done:
 rts

draw_clip_second_pattern:
 jsr draw_clip_second_load
 bcc dcsp_done
 jsr draw_loaded_face_pattern_a
.if MODE5_POLYGON_OUTLINE != 0
 jsr mode5_draw_loaded_polygon_outline
.endif
dcsp_done:
 rts
.endif

.if DYNAMIC_LIGHT != 0
update_face_shade:
.if DYNAMIC_LIGHT != 0
.if FACE_REFLECTIVITY_ACTIVE_ONLY != $01
 jsr load_face_reflectivity_y
.endif
 sty tmpidx
.if MODE4_OBJECT_LIGHT_CACHE != 0
 lda #$00
 sta dotlo
 sta dothi
 ldy tmpidx
 lda face_normal_x,y
 ldx sh_nx
 jsr mul_s8_16
 jsr add_dot_product
 ldy tmpidx
 lda face_normal_y,y
 ldx sh_ny
 jsr mul_s8_16
 jsr add_dot_product
 ldy tmpidx
 lda face_normal_z,y
 ldx sh_nz
 jsr mul_s8_16
 jsr add_dot_product
 jsr subtract_face_center_dot
.else
 jsr rotate_face_normal_for_shade
 ldx light_phase
 stx sh_lx
 lda #$00
 sta dotlo
 sta dothi
 ldx sh_lx
 lda light_pos_x,x
 tax
 lda sh_nx
 jsr mul_s8_16
 jsr add_dot_product
 ldx sh_lx
 lda light_pos_y,x
 tax
 lda sh_ny
 jsr mul_s8_16
 jsr add_dot_product
 ldx sh_lx
 lda light_pos_z,x
 tax
 lda sh_nz
 jsr mul_s8_16
 jsr add_dot_product
 jsr subtract_face_center_dot
.if SCENE_OBJECT_COUNT != 0
 jsr subtract_object_position_dot
.endif
.endif
 jsr select_face_shade_from_dot
.if MODE4_SHADE_STEP_LIMIT != 0
 jsr mode4_shade_step_limit_apply
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy shared_runtime_face
.else
 ldy tmpidx
.endif
 sta frame_face_shade,y
.if FRAME_FACE_FILL_CACHE != 0
 and #$7f
 tax
 lda shade_solid_bytes,x
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy shared_runtime_face
.else
 ldy tmpidx
.endif
 sta frame_face_fill,y
.endif
.endif
 rts
.endif

.if DYNAMIC_LIGHT != 0
.if MODE4_UNCACHED_LIGHT_FALLBACK != 0
rotate_face_normal_for_shade:
 ldy tmpidx
 lda face_normal_x,y
 ldx m00
 jsr mul_s6
 sta sh_nx
 lda face_normal_y,y
 ldx m01
 jsr mul_s6
 clc
 adc sh_nx
 sta sh_nx
 lda face_normal_z,y
 ldx m02
 jsr mul_s6
 clc
 adc sh_nx
 sta sh_nx
 lda face_normal_x,y
 ldx m10
 jsr mul_s6
 sta sh_ny
 lda face_normal_y,y
 ldx m11
 jsr mul_s6
 clc
 adc sh_ny
 sta sh_ny
 lda face_normal_z,y
 ldx m12
 jsr mul_s6
 clc
 adc sh_ny
 sta sh_ny
 lda face_normal_x,y
 ldx m20
 jsr mul_s6
 sta sh_nz
 lda face_normal_y,y
 ldx m21
 jsr mul_s6
 clc
 adc sh_nz
 sta sh_nz
 lda face_normal_z,y
 ldx m22
 jsr mul_s6
 clc
 adc sh_nz
 sta sh_nz
 rts
.endif

subtract_face_center_dot:
 ldy tmpidx
 sec
 lda dotlo
 sbc face_center_dot_lo,y
 sta dotlo
 lda dothi
 sbc face_center_dot_hi,y
 sta dothi
 rts

.if MODE4_UNCACHED_LIGHT_FALLBACK != 0
.if SCENE_OBJECT_COUNT != 0
subtract_object_position_dot:
.if SCENE_OBJECT_X_ACTIVE != 0
 ldx obj_pos_x_cur
 lda sh_nx
 jsr mul_s8_16
 jsr subtract_dot_product
.endif
.if SCENE_OBJECT_Y_ACTIVE != 0
 ldx obj_pos_y_cur
 lda sh_ny
 jsr mul_s8_16
 jsr subtract_dot_product
.endif
 ldx obj_depth_lo
 lda sh_nz
 jsr mul_s8_16
 jsr subtract_dot_product
 rts
.endif
.endif

add_dot_product:
 clc
 lda dotlo
 adc prodlo
 sta dotlo
 lda dothi
 adc prodhi
 sta dothi
 rts

.if MODE4_UNCACHED_LIGHT_FALLBACK != 0
subtract_dot_product:
 sec
 lda dotlo
 sbc prodlo
 sta dotlo
 lda dothi
 sbc prodhi
 sta dothi
 rts
.endif

select_face_shade_from_dot:
 jsr select_raw_face_shade_from_dot
.if FULL_DYNAMIC_SHADE = 0
 rts
.else
 sta t1
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldy shared_runtime_face
.else
 ldy tmpidx
.endif
 lda frame_face_shade,y
 sta t2
 cmp t1
 beq sfs_keep_old
 lda shade_intensity_changed
 bne sfs_accept_new
 lda t2
 cmp #$80
 beq sfs_old_black_dark
 cmp #$00
 beq sfs_old_solid_dark
 cmp #$82
 beq sfs_old_checker_mid
 cmp #$02
 beq sfs_old_solid_high
 jmp sfs_old_white_high
sfs_old_black_dark:
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 bmi sfs_keep_old
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_dark_up_q6+1,x
 bcc sfs_keep_old
 bne sfs_accept_new
 lda dotlo
 cmp shade_hyst_dark_up_q6,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 bmi sfs_keep_old
 cmp shade_hyst_dark_up,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_solid_dark:
 lda t1
 cmp #$80
 beq sfs_old_solid_dark_down
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 bmi sfs_keep_old
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_checker_dark_up_q6+1,x
 bcc sfs_keep_old
 bne sfs_accept_new
 lda dotlo
 cmp shade_hyst_checker_dark_up_q6,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 cmp shade_hyst_checker_dark_up,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_solid_dark_down:
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 jmp sfs_keep_old
sfs_old_checker_mid:
 lda t1
 cmp #$02
 beq sfs_old_checker_mid_up
 cmp #$84
 beq sfs_old_checker_mid_up
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_solid_mid_down_q6+1,x
 bcc sfs_accept_new
 bne sfs_keep_old
 lda dotlo
 cmp shade_hyst_solid_mid_down_q6,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 cmp shade_hyst_solid_mid_down,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_checker_mid_up:
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 bmi sfs_keep_old
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_solid_mid_up_q6+1,x
 bcc sfs_keep_old
 bne sfs_accept_new
 lda dotlo
 cmp shade_hyst_solid_mid_up_q6,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 cmp shade_hyst_solid_mid_up,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_solid_high:
 lda t1
 cmp #$84
 beq sfs_old_solid_high_up
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_checker_high_down_q6+1,x
 bcc sfs_accept_new
 bne sfs_keep_old
 lda dotlo
 cmp shade_hyst_checker_high_down_q6,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 cmp shade_hyst_checker_high_down,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_solid_high_up:
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 bmi sfs_keep_old
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_checker_high_up_q6+1,x
 bcc sfs_keep_old
 bne sfs_accept_new
 lda dotlo
 cmp shade_hyst_checker_high_up_q6,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_keep_old
 lda dothi
 cmp shade_hyst_checker_high_up,x
 bcs sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_old_white_high:
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 txa
 asl
 tax
 lda dothi
 cmp shade_hyst_solid_high_down_q6+1,x
 bcc sfs_accept_new
 bne sfs_keep_old
 lda dotlo
 cmp shade_hyst_solid_high_down_q6,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.else
 ldx light_intensity
 beq sfs_accept_new
 lda dothi
 bmi sfs_accept_new
 cmp shade_hyst_solid_high_down,x
 bcc sfs_accept_new
 jmp sfs_keep_old
.endif
sfs_accept_new:
 lda t1
 rts
sfs_keep_old:
 lda t2
 rts
.endif

select_raw_face_shade_from_dot:
 ldx light_intensity
 beq srfs_dark
 lda dothi
 bmi srfs_dark
.if MODE4_DYNAMIC_SHADE_THRESHOLD_FIX != 0
 txa
 asl
 tax
 lda dothi
 cmp shade_thresh_high_q6+1,x
 bcc srfs_fix_mid_high
 bne srfs_high_exposure
 lda dotlo
 cmp shade_thresh_high_q6,x
 bcs srfs_high_exposure
srfs_fix_mid_high:
 lda dothi
 cmp shade_thresh_mid_high_q6+1,x
 bcc srfs_fix_mid
 bne srfs_mid_high_exposure
 lda dotlo
 cmp shade_thresh_mid_high_q6,x
 bcs srfs_mid_high_exposure
srfs_fix_mid:
 lda dothi
 cmp shade_thresh_mid_q6+1,x
 bcc srfs_dark
 bne srfs_checker_mid
 lda dotlo
 cmp shade_thresh_mid_q6,x
 bcs srfs_checker_mid
 jmp srfs_dark
.else
 cmp shade_thresh_high,x
 bcs srfs_high_exposure
 cmp shade_thresh_mid_high,x
 bcs srfs_mid_high_exposure
 cmp shade_thresh_mid,x
 bcs srfs_checker_mid
.endif
srfs_dark:
 lda #$00
 rts
srfs_checker_mid:
 lda material_reflect_offset_cur
 cmp #$14
 bcs srfs_checker_white_high
 cmp #$0a
 bcs srfs_checker_dark_reflect_high
 lda #$82
 rts
srfs_mid_high_exposure:
 lda material_reflect_offset_cur
 cmp #$14
 bcs srfs_solid_reflect_high
 cmp #$0a
 bcs srfs_checker_white_high
 lda #$02
 rts
srfs_high_exposure:
 lda material_reflect_offset_cur
 cmp #$14
 bcs srfs_solid_reflect_high
 cmp #$0a
 bcs srfs_checker_white_high
 lda #$84
 rts
srfs_checker_white_high:
 lda #$84
 rts
srfs_checker_dark_reflect_high:
 lda #$86
 rts
srfs_solid_reflect_high:
 lda #$04
 rts
.endif

.endif

.if FACE_RENDER_ENABLE != 0
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
engine_mode3_load_prepared_face_y:
.if EXPLORER_SCREEN_CLIP_X != 0
 lda #$00
 sta clip_second_pending
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda #$00
 sta clip_poly_active
.endif
.if EXPLORER_NEAR_POLY != 0
 lda #$00
 sta near_face_crossing
.endif
 ldy sortj
 lda face0,y
 tax
 lda sx,x
 sta vx0
 lda sy,x
 sta vy0
 ldy sortj
 lda face1,y
 tax
 lda sx,x
 sta vx1
 lda sy,x
 sta vy1
 ldy sortj
 lda face2,y
 tax
 lda sx,x
 sta vx2
 lda sy,x
 sta vy2
.if HAS_TRI_FACES != 0
 ldy sortj
 lda face_vertex_count,y
 sta loaded_face_vertex_count
 cmp #$04
 beq sm3lpf_load_v3
 lda vx2
 sta vx3
 lda vy2
 sta vy3
 jmp sm3lpf_spans
sm3lpf_load_v3:
.else
 lda #$04
 sta loaded_face_vertex_count
.endif
 ldy sortj
 lda face3,y
 tax
 lda sx,x
 sta vx3
 lda sy,x
 sta vy3
sm3lpf_spans:
 ldy sortj
 lda frame_face_spanw,y
 sta spanw
 lda frame_face_spanh,y
 sta spanh
 sec
 rts
.endif

load_face_y:
.if EXPLORER_SCREEN_CLIP_X != 0
 lda #$00
 sta clip_second_pending
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda #$00
 sta clip_poly_active
.endif
 lda face0,y
 tax
 lda sx,x
 sta vx0
 lda sy,x
 sta vy0
 lda face1,y
 tax
 lda sx,x
 sta vx1
 lda sy,x
 sta vy1
 lda face2,y
 tax
 lda sx,x
 sta vx2
 lda sy,x
 sta vy2
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 sta loaded_face_vertex_count
 cmp #$04
 beq load_face_y_v3
 lda vx2
 sta vx3
 lda vy2
 sta vy3
 jmp load_face_y_clip
load_face_y_v3:
.else
 lda #$04
 sta loaded_face_vertex_count
.endif
 lda face3,y
 tax
 lda sx,x
 sta vx3
 lda sy,x
 sta vy3

load_face_y_clip:
.if CAMERA_PLANE_CLIP_PROFILE != 0
 lda #$00
 sta camera_plane_bucket_ready
.endif
.if WORLD_GROUND_PLANE_CLIP != 0
.if MESH_SOURCE_SHARING_RUNTIME = 0
 ldy sortj
 sty faceidx
.endif
 jsr ground_plane_face_crossing
 beq lfy_ground_plane_no_cross
 jsr ground_plane_clip_loaded_face
 jsr clip_poly_drawable
 bcc sfd_no
 sec
 rts
lfy_ground_plane_no_cross:
.endif
.if CAMERA_PLANE_CLIP_PROFILE != 0
 lda near_face_crossing
 beq lfy_camera_plane_no_cross
.if MESH_SOURCE_SHARING_RUNTIME = 0
 ldy sortj
 sty faceidx
.endif
 jsr camera_plane_clip_loaded_face
 jsr clip_poly_drawable
 bcc sfd_no
 sec
 rts
lfy_camera_plane_no_cross:
.endif
.if EXPLORER_NEAR_POLY != 0 && MODE3_LATE_NEAR_NO_POLY = 0
.if MESH_SOURCE_SHARING_RUNTIME = 0
 ldy sortj
 sty faceidx
.endif
 jsr explorer_face_near_projected
 beq sfd_no
 jsr clip_loaded_face_near_poly
 lda clip_poly_active
 beq lfy_no_near_poly
 jsr clip_poly_drawable
 bcc sfd_no
 sec
 rts
lfy_no_near_poly:
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
 jsr clip_loaded_face_screen_x
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
 jsr clip_loaded_face_poly_x
 lda clip_poly_active
 beq lfy_no_poly
 jmp clip_poly_drawable
lfy_no_poly:
.endif
screen_face_drawable:
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 ; Retain legacy spanw/spanh production for the Mode 4 pattern dispatch,
 ; but bypass only its integer SCREEN_MIN_SPAN eligibility rejection.
.endif
 lda vx0
 sta p1lo
 sta p1hi
 lda vx1
 cmp p1lo
 bcs sfd_x1_min_ok
 sta p1lo
sfd_x1_min_ok:
 cmp p1hi
 bcc sfd_x1_max_ok
 sta p1hi
sfd_x1_max_ok:
 lda vx2
 cmp p1lo
 bcs sfd_x2_min_ok
 sta p1lo
sfd_x2_min_ok:
 cmp p1hi
 bcc sfd_x2_max_ok
 sta p1hi
sfd_x2_max_ok:
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne sfd_x_span
.endif
 lda vx3
 cmp p1lo
 bcs sfd_x3_min_ok
 sta p1lo
sfd_x3_min_ok:
 cmp p1hi
 bcc sfd_x_span
 sta p1hi
sfd_x_span:
 sec
 lda p1hi
 sbc p1lo
.if SCENE_OBJECT_COUNT != 0
 sta spanw
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 jmp sfd_y_bounds
.endif
 cmp #SCREEN_MIN_SPAN
 bcs sfd_y_bounds
 jsr face_far_depth
 beq sfd_no
 lda spanw
 cmp #FAR_SCREEN_MIN_SPAN
 bcc sfd_no
 jmp sfd_y_bounds
.else
.if PATTERN_MIN_SPAN != 0
 sta spanw
.endif
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 jmp sfd_y_bounds
.endif
 cmp #SCREEN_MIN_SPAN
 bcc sfd_no
.endif
sfd_y_bounds:
 lda vy0
 sta p1lo
 sta p1hi
 lda vy1
 cmp p1lo
 bcs sfd_y1_min_ok
 sta p1lo
sfd_y1_min_ok:
 cmp p1hi
 bcc sfd_y1_max_ok
 sta p1hi
sfd_y1_max_ok:
 lda vy2
 cmp p1lo
 bcs sfd_y2_min_ok
 sta p1lo
sfd_y2_min_ok:
 cmp p1hi
 bcc sfd_y2_max_ok
 sta p1hi
sfd_y2_max_ok:
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne sfd_y_span
.endif
 lda vy3
 cmp p1lo
 bcs sfd_y3_min_ok
 sta p1lo
sfd_y3_min_ok:
 cmp p1hi
 bcc sfd_y_span
 sta p1hi
sfd_y_span:
 sec
 lda p1hi
 sbc p1lo
.if SCENE_OBJECT_COUNT != 0
 sta spanh
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 jmp sfd_yes
.endif
 cmp #SCREEN_MIN_SPAN
 bcs sfd_yes
 jsr face_far_depth
 beq sfd_no
 lda spanh
 cmp #FAR_SCREEN_MIN_SPAN
 bcc sfd_no
.else
.if PATTERN_MIN_SPAN != 0
 sta spanh
.endif
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 jmp sfd_yes
.endif
 cmp #SCREEN_MIN_SPAN
 bcc sfd_no
.endif
sfd_yes:
 sec
 rts
sfd_no:
 clc
 rts

.if EXPLORER_SCREEN_CLIP_POLY != 0
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0
.if * > HIGH_BASIC_V2_STATIC_LOW_BASE
 .error "High-basic-v2 middle code overlaps lower static segment"
.endif
* = HIGH_BASIC_V2_CODE_HIGH_BASE
.if * != HIGH_BASIC_V2_CODE_HIGH_BASE
 .error "High-basic-v2 high code did not start at $a000"
.endif
.endif
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0 && WIRE_RENDER_ENABLE != 0 && WIRE_MESH_COUNT != 0
.if * > $5c00
 .error "High-basic-v2 middle segment overlaps video buffer A"
.endif
* = $a000
.endif
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0 && (WIRE_RENDER_ENABLE = 0 || WIRE_MESH_COUNT = 0)
.if * > $2000
 .error "High-basic-v2 low segment overlaps bitmap buffer B"
.endif
* = $4000
.endif
clip_loaded_face_poly_x:
.if WIRE_RENDER_ENABLE != 0
 jsr clip_poly_inside_screen_fast
 bne clpx_done
.endif
 jsr clip_poly_all_outside_screen
 bne clpx_empty
 jsr clip_poly_needs_screen
 beq clpx_done
 lda #$01
 sta clip_poly_active
 jsr clip_poly_init_from_face
.if EXPLORER_CAMERA_X_CLIP != 0
 jsr clip_poly_clip_camera_x_current
 rts
.endif
 jsr clip_poly_clip_screen_current
 rts

clip_poly_clip_screen_current:
 jsr clip_poly_right_a_to_b
 lda clip_b_count
 beq clpx_empty
 jsr clip_poly_left_b_to_a
 lda clip_a_count
 beq clpx_empty
 jsr clip_poly_top_a_to_b
 lda clip_b_count
 beq clpx_empty
 jsr clip_poly_bottom_b_to_a
 lda clip_a_count
 beq clpx_empty
 jsr clip_poly_compact_screen_a
 lda clip_a_count
 beq clpx_empty
 rts

clip_poly_compact_screen_a:
 lda clip_a_count
 cmp #$02
 bcc cpcsa_done
 lda #$00
 sta clip_prev_idx
 sta clip_cur_idx
cpcsa_loop:
 lda clip_prev_idx
 beq cpcsa_append
 sec
 sbc #$01
 tax
 ldy clip_cur_idx
 lda clip_a_x,y
 cmp clip_a_x,x
 bne cpcsa_append
 lda clip_a_y,y
 cmp clip_a_y,x
 beq cpcsa_skip
cpcsa_append:
 ldx clip_cur_idx
 ldy clip_prev_idx
 cpx clip_prev_idx
 beq cpcsa_inc_write
 lda clip_a_x,x
 sta clip_a_x,y
 lda clip_a_y,x
 sta clip_a_y,y
cpcsa_inc_write:
 inc clip_prev_idx
cpcsa_skip:
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne cpcsa_loop
 lda clip_prev_idx
 sta clip_a_count
 cmp #$02
 bcc cpcsa_done
 sec
 sbc #$01
 tax
 lda clip_a_x,x
 cmp clip_a_x
 bne cpcsa_done
 lda clip_a_y,x
 cmp clip_a_y
 bne cpcsa_done
 dec clip_a_count
cpcsa_done:
 rts

.if WIRE_RENDER_ENABLE != 0
clip_poly_inside_screen_fast:
 ldy sortj
 ldx face0,y
 jsr clip_vertex_inside_screen_fast
 beq cpisf_no
 ldy sortj
 ldx face1,y
 jsr clip_vertex_inside_screen_fast
 beq cpisf_no
 ldy sortj
 ldx face2,y
 jsr clip_vertex_inside_screen_fast
 beq cpisf_no
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne cpisf_yes
.endif
 ldy sortj
 ldx face3,y
 jsr clip_vertex_inside_screen_fast
 beq cpisf_no
cpisf_yes:
 lda #$01
 rts
cpisf_no:
 lda #$00
 rts

clip_vertex_inside_screen_fast:
 lda pxrawhi,x
 bne cvisf_no
 lda pxrawlo,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs cvisf_no
 lda pyrawhi,x
 bne cvisf_no
 lda pyrawlo,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs cvisf_no
 lda #$01
 rts
cvisf_no:
 lda #$00
 rts
.endif
.if EXPLORER_CAMERA_X_CLIP != 0
clip_poly_clip_camera_x_current:
 jsr clip_poly_right_cam_a_to_b
 lda clip_b_count
 beq clpx_empty
 jsr clip_poly_left_cam_b_to_a
 lda clip_a_count
 beq clpx_empty
 jsr clip_poly_top_cam_a_to_b
 lda clip_b_count
 beq clpx_empty
 jsr clip_poly_bottom_cam_b_to_a
 lda clip_a_count
 beq clpx_empty
 jsr clip_poly_project_a_from_camera
 jmp clip_poly_clip_screen_current

clip_poly_right_cam_a_to_b:
 lda #$00
 sta clip_b_count
 lda clip_a_count
 beq cprca_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
cprca_loop:
 ldx clip_prev_idx
 jsr clip_a_right_inside_cam
 sta clip_prev_inside
 ldx clip_cur_idx
 jsr clip_a_right_inside_cam
 sta clip_cur_inside
 lda clip_cur_inside
 beq cprca_cur_out
 lda clip_prev_inside
 bne cprca_append_cur
 jsr clip_append_right_intersection_cam_a_to_b
cprca_append_cur:
 ldx clip_cur_idx
 jsr clip_copy_a_to_b
 jmp cprca_next
cprca_cur_out:
 lda clip_prev_inside
 beq cprca_next
 jsr clip_append_right_intersection_cam_a_to_b
cprca_next:
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne cprca_loop
cprca_done:
 rts

clip_poly_left_cam_b_to_a:
 lda #$00
 sta clip_a_count
 lda clip_b_count
 beq cplcb_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
cplcb_loop:
 ldx clip_prev_idx
 jsr clip_b_left_inside_cam
 sta clip_prev_inside
 ldx clip_cur_idx
 jsr clip_b_left_inside_cam
 sta clip_cur_inside
 lda clip_cur_inside
 beq cplcb_cur_out
 lda clip_prev_inside
 bne cplcb_append_cur
 jsr clip_append_left_intersection_cam_b_to_a
cplcb_append_cur:
 ldx clip_cur_idx
 jsr clip_copy_b_to_a
 jmp cplcb_next
cplcb_cur_out:
 lda clip_prev_inside
 beq cplcb_next
 jsr clip_append_left_intersection_cam_b_to_a
cplcb_next:
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_b_count
 bne cplcb_loop
cplcb_done:
 rts

clip_poly_top_cam_a_to_b:
 lda #$00
 sta clip_b_count
 lda clip_a_count
 beq cptca_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
cptca_loop:
 ldx clip_prev_idx
 jsr clip_a_top_inside_cam
 sta clip_prev_inside
 ldx clip_cur_idx
 jsr clip_a_top_inside_cam
 sta clip_cur_inside
 lda clip_cur_inside
 beq cptca_cur_out
 lda clip_prev_inside
 bne cptca_append_cur
 jsr clip_append_top_intersection_cam_a_to_b
cptca_append_cur:
 ldx clip_cur_idx
 jsr clip_copy_a_to_b
 jmp cptca_next
cptca_cur_out:
 lda clip_prev_inside
 beq cptca_next
 jsr clip_append_top_intersection_cam_a_to_b
cptca_next:
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne cptca_loop
cptca_done:
 rts

clip_poly_bottom_cam_b_to_a:
 lda #$00
 sta clip_a_count
 lda clip_b_count
 beq cpbcb_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
cpbcb_loop:
 ldx clip_prev_idx
 jsr clip_b_bottom_inside_cam
 sta clip_prev_inside
 ldx clip_cur_idx
 jsr clip_b_bottom_inside_cam
 sta clip_cur_inside
 lda clip_cur_inside
 beq cpbcb_cur_out
 lda clip_prev_inside
 bne cpbcb_append_cur
 jsr clip_append_bottom_intersection_cam_b_to_a
cpbcb_append_cur:
 ldx clip_cur_idx
 jsr clip_copy_b_to_a
 jmp cpbcb_next
cpbcb_cur_out:
 lda clip_prev_inside
 beq cpbcb_next
 jsr clip_append_bottom_intersection_cam_b_to_a
cpbcb_next:
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_b_count
 bne cpbcb_loop
cpbcb_done:
 rts

clip_a_right_inside_cam:
 jsr clip_cam_right_dist_a
 lda p1hi
 bmi carcam_no
 lda #$01
 rts
carcam_no:
 lda #$00
 rts

clip_b_left_inside_cam:
 jsr clip_cam_left_dist_b
 lda p1hi
 bmi cblcam_no
 lda #$01
 rts
cblcam_no:
 lda #$00
 rts

clip_a_top_inside_cam:
 jsr clip_cam_top_dist_a
 lda p1hi
 bmi catcam_no
 lda #$01
 rts
catcam_no:
 lda #$00
 rts

clip_b_bottom_inside_cam:
 jsr clip_cam_bottom_dist_b
 lda p1hi
 bmi cbbcam_no
 lda #$01
 rts
cbbcam_no:
 lda #$00
 rts

clip_append_right_intersection_cam_a_to_b:
 ldx clip_prev_idx
 jsr clip_a_right_inside_cam
 bne carcam_prev_inside
 lda clip_cur_idx
 sta clip_in_x
 lda clip_prev_idx
 sta clip_out_x
 jmp carcam_project
carcam_prev_inside:
 lda clip_prev_idx
 sta clip_in_x
 lda clip_cur_idx
 sta clip_out_x
carcam_project:
 jsr clip_cam_ratio_right_a
 jsr clip_cam_interp_vx_a_to_b
 jsr clip_cam_interp_vy_a_to_b
 jsr clip_cam_interp_vz_a_to_b
 ldy clip_b_count
 lda #PROJ_SCREEN_MAX_X
 sta clip_b_x,y
 sta clip_b_xlo,y
 lda #PROJ_SCREEN_MIN_X
 sta clip_b_xhi,y
.if WIRE_RENDER_ENABLE != 0
 lda #$01
 sta clip_b_flag,y
.endif
 inc clip_b_count
 rts

clip_append_left_intersection_cam_b_to_a:
 ldx clip_prev_idx
 jsr clip_b_left_inside_cam
 bne calcam_prev_inside
 lda clip_cur_idx
 sta clip_in_x
 lda clip_prev_idx
 sta clip_out_x
 jmp calcam_project
calcam_prev_inside:
 lda clip_prev_idx
 sta clip_in_x
 lda clip_cur_idx
 sta clip_out_x
calcam_project:
 jsr clip_cam_ratio_left_b
 jsr clip_cam_interp_vx_b_to_a
 jsr clip_cam_interp_vy_b_to_a
 jsr clip_cam_interp_vz_b_to_a
 ldy clip_a_count
 lda #$00
 sta clip_a_x,y
 sta clip_a_xlo,y
 sta clip_a_xhi,y
.if WIRE_RENDER_ENABLE != 0
 lda #$01
 sta clip_a_flag,y
.endif
 inc clip_a_count
 rts

clip_append_top_intersection_cam_a_to_b:
 ldx clip_prev_idx
 jsr clip_a_top_inside_cam
 bne catcam_prev_inside
 lda clip_cur_idx
 sta clip_in_x
 lda clip_prev_idx
 sta clip_out_x
 jmp catcam_project
catcam_prev_inside:
 lda clip_prev_idx
 sta clip_in_x
 lda clip_cur_idx
 sta clip_out_x
catcam_project:
 jsr clip_cam_ratio_top_a
 jsr clip_cam_interp_vx_a_to_b
 jsr clip_cam_interp_vy_a_to_b
 jsr clip_cam_interp_vz_a_to_b
 ldy clip_b_count
 lda #$00
 sta clip_b_y,y
 sta clip_b_ylo,y
 sta clip_b_yhi,y
.if WIRE_RENDER_ENABLE != 0
 lda #$01
 sta clip_b_flag,y
.endif
 inc clip_b_count
 rts

clip_append_bottom_intersection_cam_b_to_a:
 ldx clip_prev_idx
 jsr clip_b_bottom_inside_cam
 bne cabcam_prev_inside
 lda clip_cur_idx
 sta clip_in_x
 lda clip_prev_idx
 sta clip_out_x
 jmp cabcam_project
cabcam_prev_inside:
 lda clip_prev_idx
 sta clip_in_x
 lda clip_cur_idx
 sta clip_out_x
cabcam_project:
 jsr clip_cam_ratio_bottom_b
 jsr clip_cam_interp_vx_b_to_a
 jsr clip_cam_interp_vy_b_to_a
 jsr clip_cam_interp_vz_b_to_a
 ldy clip_a_count
 lda #PROJ_SCREEN_MAX_Y
 sta clip_a_y,y
 sta clip_a_ylo,y
 lda #PROJ_SCREEN_MIN_Y
 sta clip_a_yhi,y
.if WIRE_RENDER_ENABLE != 0
 lda #$01
 sta clip_a_flag,y
.endif
 inc clip_a_count
 rts

clip_cam_ratio_right_a:
 ldx clip_in_x
 jsr clip_cam_right_dist_a
 lda p1lo
 sta clip_num16_lo
 lda p1hi
 sta clip_num16_hi
 ldx clip_out_x
 jsr clip_cam_right_dist_a
 jsr clip_abs_p1
 jmp clip_cam_finish_ratio

clip_cam_ratio_left_b:
 ldx clip_in_x
 jsr clip_cam_left_dist_b
 lda p1lo
 sta clip_num16_lo
 lda p1hi
 sta clip_num16_hi
 ldx clip_out_x
 jsr clip_cam_left_dist_b
 jsr clip_abs_p1
 jmp clip_cam_finish_ratio

clip_cam_ratio_top_a:
 ldx clip_in_x
 jsr clip_cam_top_dist_a
 lda p1lo
 sta clip_num16_lo
 lda p1hi
 sta clip_num16_hi
 ldx clip_out_x
 jsr clip_cam_top_dist_a
 jsr clip_abs_p1
 jmp clip_cam_finish_ratio

clip_cam_ratio_bottom_b:
 ldx clip_in_x
 jsr clip_cam_bottom_dist_b
 lda p1lo
 sta clip_num16_lo
 lda p1hi
 sta clip_num16_hi
 ldx clip_out_x
 jsr clip_cam_bottom_dist_b
 jsr clip_abs_p1
clip_cam_finish_ratio:
 clc
 lda clip_num16_lo
 adc p1lo
 sta clip_den16_lo
 lda clip_num16_hi
 adc p1hi
 sta clip_den16_hi
 jsr clip_ratio_to_scale8
 rts

clip_abs_p1:
 lda p1hi
 bpl cap1_done
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
cap1_done:
 rts

clip_cam_right_dist_a:
 stx tmpidx
 jsr clip_cam_norm_x_a
 lda t1
 ldx #PROJ_FRUSTUM_X_NEAR
 jsr clip_mul_u8_poly
 lda prodlo
 sta clip_axis_in_lo
 lda prodhi
 sta clip_axis_in_hi
 lda t2
 ldx #PROJ_FRUSTUM_FOCAL
 jsr mul_s8_16
 sec
 lda clip_axis_in_lo
 sbc prodlo
 sta p1lo
 lda clip_axis_in_hi
 sbc prodhi
 sta p1hi
 rts

clip_cam_left_dist_b:
 stx tmpidx
 jsr clip_cam_norm_x_b
 lda t1
 ldx #PROJ_FRUSTUM_X_NEAR
 jsr clip_mul_u8_poly
 lda prodlo
 sta clip_axis_in_lo
 lda prodhi
 sta clip_axis_in_hi
 lda t2
 ldx #PROJ_FRUSTUM_FOCAL
 jsr mul_s8_16
 clc
 lda clip_axis_in_lo
 adc prodlo
 sta p1lo
 lda clip_axis_in_hi
 adc prodhi
 sta p1hi
 rts

clip_cam_top_dist_a:
 stx tmpidx
 jsr clip_cam_norm_y_a
 lda t1
 ldx #PROJ_FRUSTUM_Y_NEAR
 jsr clip_mul_u8_poly
 lda prodlo
 sta clip_axis_in_lo
 lda prodhi
 sta clip_axis_in_hi
 lda t2
 ldx #PROJ_FRUSTUM_FOCAL
 jsr mul_s8_16
 sec
 lda clip_axis_in_lo
 sbc prodlo
 sta p1lo
 lda clip_axis_in_hi
 sbc prodhi
 sta p1hi
 rts

clip_cam_bottom_dist_b:
 stx tmpidx
 jsr clip_cam_norm_y_b
 lda t1
 ldx #PROJ_FRUSTUM_Y_NEAR
 jsr clip_mul_u8_poly
 lda prodlo
 sta clip_axis_in_lo
 lda prodhi
 sta clip_axis_in_hi
 lda t2
 ldx #PROJ_FRUSTUM_FOCAL
 jsr mul_s8_16
 clc
 lda clip_axis_in_lo
 adc prodlo
 sta p1lo
 lda clip_axis_in_hi
 adc prodhi
 sta p1hi
 rts

clip_cam_norm_x_a:
 ldx tmpidx
 lda clip_a_vzlo,x
 sta p1lo
 lda clip_a_vzhi,x
 sta p1hi
 lda clip_a_vxlo,x
 sta crosslo
 lda clip_a_vxhi,x
 sta crosshi
 jmp clip_cam_norm_depth_coord

clip_cam_norm_x_b:
 ldx tmpidx
 lda clip_b_vzlo,x
 sta p1lo
 lda clip_b_vzhi,x
 sta p1hi
 lda clip_b_vxlo,x
 sta crosslo
 lda clip_b_vxhi,x
 sta crosshi
 jmp clip_cam_norm_depth_coord

clip_cam_norm_y_a:
 ldx tmpidx
 lda clip_a_vzlo,x
 sta p1lo
 lda clip_a_vzhi,x
 sta p1hi
 lda clip_a_vylo,x
 sta crosslo
 lda clip_a_vyhi,x
 sta crosshi
 jmp clip_cam_norm_depth_coord

clip_cam_norm_y_b:
 ldx tmpidx
 lda clip_b_vzlo,x
 sta p1lo
 lda clip_b_vzhi,x
 sta p1hi
 lda clip_b_vylo,x
 sta crosslo
 lda clip_b_vyhi,x
 sta crosshi

clip_cam_norm_depth_coord:
 lda p1hi
 bpl ccnd_check_fit
 lda #$00
 sta p1lo
 sta p1hi
ccnd_check_fit:
 lda p1hi
 bne ccnd_shift
 lda crosshi
 beq ccnd_coord_pos
 cmp #$ff
 beq ccnd_coord_neg
 jmp ccnd_shift
ccnd_coord_pos:
 lda crosslo
 bmi ccnd_shift
 jmp ccnd_done
ccnd_coord_neg:
 lda crosslo
 bmi ccnd_done
 jmp ccnd_shift
ccnd_shift:
 lsr p1hi
 ror p1lo
 lda crosshi
 asl
 ror crosshi
 ror crosslo
 lda p1lo
 ora p1hi
 bne ccnd_check_fit
 lda #$01
 sta p1lo
 lda #$00
 sta p1hi
 jmp ccnd_check_fit
ccnd_done:
 lda p1lo
 bne ccnd_depth_ok
 lda #$01
ccnd_depth_ok:
 sta t1
 lda crosslo
 sta t2
 rts

clip_cam_depth_byte_a:
 lda clip_a_vzhi,x
 bmi ccdba_zero
 beq ccdba_low
 lda #$ff
 rts
ccdba_low:
 lda clip_a_vzlo,x
 rts
ccdba_zero:
 lda #$00
 rts

clip_cam_depth_byte_b:
 lda clip_b_vzhi,x
 bmi ccdbb_zero
 beq ccdbb_low
 lda #$ff
 rts
ccdbb_low:
 lda clip_b_vzlo,x
 rts
ccdbb_zero:
 lda #$00
 rts

clip_cam_x_byte_a:
 lda clip_a_vxlo,x
 sta p1lo
 lda clip_a_vxhi,x
 sta p1hi
 jmp explorer_axis_to_byte

clip_cam_x_byte_b:
 lda clip_b_vxlo,x
 sta p1lo
 lda clip_b_vxhi,x
 sta p1hi
 jmp explorer_axis_to_byte

clip_cam_y_byte_a:
 lda clip_a_vylo,x
 sta p1lo
 lda clip_a_vyhi,x
 sta p1hi
 jmp explorer_axis_to_byte

clip_cam_y_byte_b:
 lda clip_b_vylo,x
 sta p1lo
 lda clip_b_vyhi,x
 sta p1hi
 jmp explorer_axis_to_byte

clip_poly_project_a_from_camera:
 lda clip_a_count
 beq cppafc_done
 lda #$00
 sta clip_cur_idx
cppafc_loop:
 ldx clip_cur_idx
 jsr clip_project_a_x_from_camera
 ldx clip_cur_idx
 jsr clip_project_a_y_from_camera
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne cppafc_loop
cppafc_done:
 rts

clip_project_a_x_from_camera:
 stx tmpidx
 lda clip_a_vzlo,x
 sta clip_axis_in_lo
 lda clip_a_vzhi,x
 sta clip_axis_in_hi
 lda clip_a_vxlo,x
 sta p1lo
 lda clip_a_vxhi,x
 sta p1hi
 jsr clip_project_axis_offset
 ldy tmpidx
 lda mul16reshi
 cmp #$ff
 bne cpax_not_saturated
 lda mul16sign
 bmi cpax_left_saturated
 lda #$00
 sta clip_a_xlo,y
 lda #$7f
 sta clip_a_xhi,y
 lda #PROJ_SCREEN_MAX_X
 sta clip_a_x,y
 rts
cpax_left_saturated:
 lda #$00
 sta clip_a_xlo,y
 lda #$80
 sta clip_a_xhi,y
 sta clip_a_x,y
 rts
cpax_not_saturated:
 lda mul16sign
 bmi cpax_left
 clc
 lda mul16reslo
 adc #PROJ_CENTER_X
 sta clip_a_xlo,y
 lda mul16reshi
 adc #$00
 sta clip_a_xhi,y
 bne cpax_right_clamp
 lda clip_a_xlo,y
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs cpax_right_clamp
 sta clip_a_x,y
 rts
cpax_right_clamp:
 lda #PROJ_SCREEN_MAX_X
 sta clip_a_x,y
 rts
cpax_left:
 lda #PROJ_CENTER_X
 sec
 sbc mul16reslo
 sta clip_a_xlo,y
 lda #$00
 sbc mul16reshi
 sta clip_a_xhi,y
 bmi cpax_left_clamp
 lda clip_a_xlo,y
 sta clip_a_x,y
 rts
cpax_left_clamp:
 lda #$00
 sta clip_a_x,y
 rts

clip_project_a_y_from_camera:
 stx tmpidx
 lda clip_a_vzlo,x
 sta clip_axis_in_lo
 lda clip_a_vzhi,x
 sta clip_axis_in_hi
 lda clip_a_vylo,x
 sta p1lo
 lda clip_a_vyhi,x
 sta p1hi
 jsr clip_project_axis_offset
 ldy tmpidx
 lda mul16reshi
 cmp #$ff
 bne cpay_not_saturated
 lda mul16sign
 bmi cpay_down_saturated
 lda #$00
 sta clip_a_ylo,y
 lda #$80
 sta clip_a_yhi,y
 lda #$00
 sta clip_a_y,y
 rts
cpay_down_saturated:
 lda #$00
 sta clip_a_ylo,y
 lda #$7f
 sta clip_a_yhi,y
 lda #PROJ_SCREEN_MAX_Y
 sta clip_a_y,y
 rts
cpay_not_saturated:
 lda mul16sign
 bmi cpay_down
 lda #PROJ_CENTER_Y
 sec
 sbc mul16reslo
 sta clip_a_ylo,y
 lda #$00
 sbc mul16reshi
 sta clip_a_yhi,y
 bmi cpay_top_clamp
 lda clip_a_ylo,y
 sta clip_a_y,y
 rts
cpay_top_clamp:
 lda #$00
 sta clip_a_y,y
 rts
cpay_down:
 clc
 lda mul16reslo
 adc #PROJ_CENTER_Y
 sta clip_a_ylo,y
 lda mul16reshi
 adc #$00
 sta clip_a_yhi,y
 bne cpay_bottom_clamp
 lda clip_a_ylo,y
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs cpay_bottom_clamp
 sta clip_a_y,y
 rts
cpay_bottom_clamp:
 lda #PROJ_SCREEN_MAX_Y
 sta clip_a_y,y
 rts

clip_project_axis_offset:
 lda #$00
 sta mul16sign
 lda p1hi
 bpl cpao_abs_ready
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
 lda #$80
 sta mul16sign
cpao_abs_ready:
 lda p1lo
 sta mul16lo
 lda p1hi
 sta mul16hi
 lda clip_axis_in_lo
 sta p1lo
 lda clip_axis_in_hi
 sta p1hi
 jsr clamp_projection_geometric_divisor_p1
 lda mul16hi
 beq cpao_mul_start
cpao_scale_loop:
 lsr mul16hi
 ror mul16lo
 lsr p1hi
 ror p1lo
 lda p1lo
 ora p1hi
 bne cpao_depth_nonzero
 lda #$01
 sta p1lo
cpao_depth_nonzero:
 lda mul16hi
 bne cpao_scale_loop
cpao_mul_start:
 lda #EXPLORER_PROJ_FOCAL
 sta mul16mul
 lda #$00
 sta prodlo
 sta prodhi
 sta mul16rem
 ldx #$08
cpao_mul_loop:
 lsr mul16mul
 bcc cpao_no_add
 lda mul16rem
 bne cpao_saturate
 clc
 lda prodlo
 adc mul16lo
 sta prodlo
 lda prodhi
 adc mul16hi
 sta prodhi
 bcs cpao_saturate
cpao_no_add:
 asl mul16lo
 rol mul16hi
 bcc cpao_shift_ok
 lda #$01
 sta mul16rem
cpao_shift_ok:
 dex
 bne cpao_mul_loop
 jmp cpao_divide
cpao_saturate:
 lda #$ff
 sta prodlo
 sta prodhi
cpao_divide:
 jsr div16u
 lda prodlo
 sta mul16reslo
 lda prodhi
 sta mul16reshi
 lda prodhi
 beq cpao_offset_ok
 lda #$ff
 sta scalev
 rts
cpao_offset_ok:
 lda prodlo
 sta scalev
 rts

clip_cam_interp_y_a_to_b:
 ldx clip_in_x
 lda clip_a_ylo,x
 sta clip_raw_in_lo
 lda clip_a_yhi,x
 sta clip_raw_in_hi
 ldx clip_out_x
 lda clip_a_ylo,x
 sta clip_raw_out_lo
 lda clip_a_yhi,x
 sta clip_raw_out_hi
 jsr clip_interp_raw_poly
 ldy clip_b_count
 lda p1lo
 sta clip_b_ylo,y
 lda p1hi
 sta clip_b_yhi,y
 jsr clip_clamp_p1_y
 ldy clip_b_count
 sta clip_b_y,y
 rts

clip_cam_interp_y_b_to_a:
 ldx clip_in_x
 lda clip_b_ylo,x
 sta clip_raw_in_lo
 lda clip_b_yhi,x
 sta clip_raw_in_hi
 ldx clip_out_x
 lda clip_b_ylo,x
 sta clip_raw_out_lo
 lda clip_b_yhi,x
 sta clip_raw_out_hi
 jsr clip_interp_raw_poly
 ldy clip_a_count
 lda p1lo
 sta clip_a_ylo,y
 lda p1hi
 sta clip_a_yhi,y
 jsr clip_clamp_p1_y
 ldy clip_a_count
 sta clip_a_y,y
 rts

clip_cam_interp_vx_a_to_b:
 ldx clip_out_x
 lda clip_a_vxlo,x
 sta p1lo
 lda clip_a_vxhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc clip_a_vxlo,x
 sta p1lo
 lda p1hi
 sbc clip_a_vxhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc clip_a_vxlo,x
 sta p1lo
 lda p1hi
 adc clip_a_vxhi,x
 sta p1hi
 ldy clip_b_count
 lda p1lo
 sta clip_b_vxlo,y
 lda p1hi
 sta clip_b_vxhi,y
 rts

clip_cam_interp_vy_a_to_b:
 ldx clip_out_x
 lda clip_a_vylo,x
 sta p1lo
 lda clip_a_vyhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc clip_a_vylo,x
 sta p1lo
 lda p1hi
 sbc clip_a_vyhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc clip_a_vylo,x
 sta p1lo
 lda p1hi
 adc clip_a_vyhi,x
 sta p1hi
 ldy clip_b_count
 lda p1lo
 sta clip_b_vylo,y
 lda p1hi
 sta clip_b_vyhi,y
 rts

clip_cam_interp_vz_a_to_b:
 ldx clip_out_x
 lda clip_a_vzlo,x
 sta p1lo
 lda clip_a_vzhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc clip_a_vzlo,x
 sta p1lo
 lda p1hi
 sbc clip_a_vzhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc clip_a_vzlo,x
 sta p1lo
 lda p1hi
 adc clip_a_vzhi,x
 sta p1hi
 ldy clip_b_count
 lda p1lo
 sta clip_b_vzlo,y
 lda p1hi
 sta clip_b_vzhi,y
 rts

clip_cam_interp_vx_b_to_a:
 ldx clip_out_x
 lda clip_b_vxlo,x
 sta p1lo
 lda clip_b_vxhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc clip_b_vxlo,x
 sta p1lo
 lda p1hi
 sbc clip_b_vxhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc clip_b_vxlo,x
 sta p1lo
 lda p1hi
 adc clip_b_vxhi,x
 sta p1hi
 ldy clip_a_count
 lda p1lo
 sta clip_a_vxlo,y
 lda p1hi
 sta clip_a_vxhi,y
 rts

clip_cam_interp_vy_b_to_a:
 ldx clip_out_x
 lda clip_b_vylo,x
 sta p1lo
 lda clip_b_vyhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc clip_b_vylo,x
 sta p1lo
 lda p1hi
 sbc clip_b_vyhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc clip_b_vylo,x
 sta p1lo
 lda p1hi
 adc clip_b_vyhi,x
 sta p1hi
 ldy clip_a_count
 lda p1lo
 sta clip_a_vylo,y
 lda p1hi
 sta clip_a_vyhi,y
 rts

clip_cam_interp_vz_b_to_a:
 ldx clip_out_x
 lda clip_b_vzlo,x
 sta p1lo
 lda clip_b_vzhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc clip_b_vzlo,x
 sta p1lo
 lda p1hi
 sbc clip_b_vzhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc clip_b_vzlo,x
 sta p1lo
 lda p1hi
 adc clip_b_vzhi,x
 sta p1hi
 ldy clip_a_count
 lda p1lo
 sta clip_a_vzlo,y
 lda p1hi
 sta clip_a_vzhi,y
 rts
.endif

.if CAMERA_PLANE_CLIP_PROFILE != 0
; Compact Sutherland-Hodgman pass against camera depth 0.  Original vertices
; are inside only at depth > 0; generated intersections are deliberately
; emitted at depth 1 so the validated projection divisor floor of 2 applies.
camera_plane_clip_loaded_face:
 lda #$01
 sta clip_poly_active
 lda #$00
 sta clip_a_count
 lda loaded_face_vertex_count
 sec
 sbc #$01
 sta clip_prev_idx
 ldx clip_prev_idx
 jsr camera_plane_get_face_vertex
 tax
 jsr camera_plane_original_inside
 sta clip_prev_inside
 lda #$00
 sta clip_cur_idx
cpclf_loop:
 ldx clip_cur_idx
 jsr camera_plane_get_face_vertex
 tax
 jsr camera_plane_original_inside
 sta clip_cur_inside
 beq cpclf_cur_outside
 lda clip_prev_inside
 bne cpclf_append_current
 ldx clip_cur_idx
 jsr camera_plane_get_face_vertex
 tax
 jsr camera_plane_original_on_plane
 bne cpclf_append_current
 jsr camera_plane_append_original_intersection
cpclf_append_current:
 jsr camera_plane_append_original_current
 jmp cpclf_next
cpclf_cur_outside:
 lda clip_prev_inside
 beq cpclf_next
 ldx clip_prev_idx
 jsr camera_plane_get_face_vertex
 tax
 jsr camera_plane_original_on_plane
 bne cpclf_next
 jsr camera_plane_append_original_intersection
cpclf_next:
 lda clip_cur_idx
 sta clip_prev_idx
 lda clip_cur_inside
 sta clip_prev_inside
 inc clip_cur_idx
 lda clip_cur_idx
 cmp loaded_face_vertex_count
 bne cpclf_loop
 lda clip_a_count
 beq cpclf_done
 jsr camera_plane_store_bucket_from_a
 jsr clip_poly_clip_screen_current
cpclf_done:
 rts

.if WORLD_GROUND_PLANE_CLIP != 0
camera_plane_clip_a_to_b:
 lda #$00
 sta clip_b_count
 lda clip_a_count
 beq cpcab_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
cpcab_loop:
 ldx clip_prev_idx
 jsr camera_plane_inside_a
 sta clip_prev_inside
 ldx clip_cur_idx
 jsr camera_plane_inside_a
 sta clip_cur_inside
 beq cpcab_cur_outside
 lda clip_prev_inside
 bne cpcab_append_current
 jsr camera_plane_append_intersection_a_to_b
cpcab_append_current:
 ldx clip_cur_idx
 jsr clip_copy_a_to_b
 jmp cpcab_next
cpcab_cur_outside:
 lda clip_prev_inside
 beq cpcab_next
 jsr camera_plane_append_intersection_a_to_b
cpcab_next:
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne cpcab_loop
 lda #$00
 sta clip_a_count
 sta clip_cur_idx
cpcab_copy_back:
 lda clip_cur_idx
 cmp clip_b_count
 beq cpcab_done
 tax
 jsr clip_copy_b_to_a
 inc clip_cur_idx
 jmp cpcab_copy_back
cpcab_done:
 rts

camera_plane_inside_a:
 lda clip_a_vzhi,x
 bmi cpia_out
cpia_in:
 lda #$01
 rts
cpia_out:
 lda #$00
 rts

camera_plane_append_intersection_a_to_b:
 lda clip_prev_inside
 beq cpai_prev_outside
 lda clip_prev_idx
 sta clip_in_x
 lda clip_cur_idx
 sta clip_out_x
 jmp cpai_ratio
cpai_prev_outside:
 lda clip_cur_idx
 sta clip_in_x
 lda clip_prev_idx
 sta clip_out_x
cpai_ratio:
 ldx clip_in_x
 lda clip_a_vzlo,x
 sta clip_num16_lo
 lda clip_a_vzhi,x
 sta clip_num16_hi
 ldx clip_out_x
 sec
 lda clip_num16_lo
 sbc clip_a_vzlo,x
 sta clip_den16_lo
 lda clip_num16_hi
 sbc clip_a_vzhi,x
 sta clip_den16_hi
 jsr clip_ratio_to_scale8
 jsr camera_plane_interp_vx_a_to_b
 jsr camera_plane_interp_vy_a_to_b
 ldy clip_b_count
 lda #$01
 sta clip_b_vzlo,y
 lda #$00
 sta clip_b_vzhi,y
.if WIRE_RENDER_ENABLE != 0
 lda #$01
 sta clip_b_flag,y
.endif
 inc clip_b_count
 rts

camera_plane_interp_vx_a_to_b:
 ldx clip_out_x
 lda clip_a_vxlo,x
 sta p1lo
 lda clip_a_vxhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc clip_a_vxlo,x
 sta p1lo
 lda p1hi
 sbc clip_a_vxhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc clip_a_vxlo,x
 sta p1lo
 lda p1hi
 adc clip_a_vxhi,x
 sta p1hi
 ldy clip_b_count
 lda p1lo
 sta clip_b_vxlo,y
 lda p1hi
 sta clip_b_vxhi,y
 rts

camera_plane_interp_vy_a_to_b:
 ldx clip_out_x
 lda clip_a_vylo,x
 sta p1lo
 lda clip_a_vyhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc clip_a_vylo,x
 sta p1lo
 lda p1hi
 sbc clip_a_vyhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc clip_a_vylo,x
 sta p1lo
 lda p1hi
 adc clip_a_vyhi,x
 sta p1hi
 ldy clip_b_count
 lda p1lo
 sta clip_b_vylo,y
 lda p1hi
 sta clip_b_vyhi,y
 rts

camera_plane_project_all_a:
 lda #$00
 sta camera_plane_bucket_ready
 ldy sortj
 lda face0,y
 sta clip_out_x
cppaa_loop:
 lda camera_plane_bucket_ready
 cmp clip_a_count
 beq cppaa_done
 jsr camera_plane_project_clip_a_vertex
 inc camera_plane_bucket_ready
 jmp cppaa_loop
cppaa_done:
 rts
.endif

camera_plane_original_inside:
 lda vzrawhi,x
 bmi cpoi_out
cpoi_in:
 lda #$01
 rts
cpoi_out:
 lda #$00
 rts

camera_plane_append_original_current:
 ldx clip_cur_idx
 jsr camera_plane_get_face_vertex
 tax
 lda vzrawhi,x
 bne cpaoc_projected
 lda vzrawlo,x
 bne cpaoc_projected
 jmp camera_plane_append_original_zero
cpaoc_projected:
 ldy clip_a_count
 lda pxrawlo,x
 sta clip_a_xlo,y
 lda pxrawhi,x
 sta clip_a_xhi,y
 lda pyrawlo,x
 sta clip_a_ylo,y
 lda pyrawhi,x
 sta clip_a_yhi,y
 lda sx,x
 sta clip_a_x,y
 lda sy,x
 sta clip_a_y,y
 lda vxrawlo,x
 sta clip_a_vxlo,y
 lda vxrawhi,x
 sta clip_a_vxhi,y
 lda vyrawlo,x
 sta clip_a_vylo,y
 lda vyrawhi,x
 sta clip_a_vyhi,y
 lda vzrawlo,x
 sta clip_a_vzlo,y
 lda vzrawhi,x
 sta clip_a_vzhi,y
.if WIRE_RENDER_ENABLE != 0
 lda #$00
 sta clip_a_flag,y
.endif
 inc clip_a_count
 rts

camera_plane_append_original_intersection:
 lda clip_cur_inside
 beq cpaoi_cur_outside
 ldx clip_prev_idx
 jsr camera_plane_get_face_vertex
 sta clip_out_x
 ldx clip_cur_idx
 jsr camera_plane_get_face_vertex
 sta clip_in_x
 jmp cpaoi_ratio
cpaoi_cur_outside:
 ldx clip_prev_idx
 jsr camera_plane_get_face_vertex
 sta clip_in_x
 ldx clip_cur_idx
 jsr camera_plane_get_face_vertex
 sta clip_out_x
cpaoi_ratio:
 ldx clip_in_x
 lda vzrawlo,x
 sta clip_num16_lo
 lda vzrawhi,x
 sta clip_num16_hi
 ldx clip_out_x
 sec
 lda clip_num16_lo
 sbc vzrawlo,x
 sta clip_den16_lo
 lda clip_num16_hi
 sbc vzrawhi,x
 sta clip_den16_hi
 jsr clip_ratio_to_scale8
 jsr camera_plane_interp_original_x
 jsr camera_plane_interp_original_y
 ldy clip_a_count
 lda #$01
 sta clip_a_vzlo,y
 lda #$00
 sta clip_a_vzhi,y
 lda clip_a_count
 sta camera_plane_bucket_ready
 jsr camera_plane_project_original_intersection
.if WIRE_RENDER_ENABLE != 0
 ldy clip_a_count
 lda #$01
 sta clip_a_flag,y
.endif
 inc clip_a_count
 rts

camera_plane_interp_original_x:
 ldx clip_out_x
 lda vxrawlo,x
 sta p1lo
 lda vxrawhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc vxrawlo,x
 sta p1lo
 lda p1hi
 sbc vxrawhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc vxrawlo,x
 sta p1lo
 lda p1hi
 adc vxrawhi,x
 sta p1hi
 ldy clip_a_count
 lda p1lo
 sta clip_a_vxlo,y
 lda p1hi
 sta clip_a_vxhi,y
 rts

camera_plane_interp_original_y:
 ldx clip_out_x
 lda vyrawlo,x
 sta p1lo
 lda vyrawhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc vyrawlo,x
 sta p1lo
 lda p1hi
 sbc vyrawhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc vyrawlo,x
 sta p1lo
 lda p1hi
 adc vyrawhi,x
 sta p1hi
 ldy clip_a_count
 lda p1lo
 sta clip_a_vylo,y
 lda p1hi
 sta clip_a_vyhi,y
 rts

; Ground-clipped vertices retain their geometric camera-space depth. Only
; true camera-plane intersections use the near-minimum projection depth 1.
camera_plane_project_clip_a_vertex:
 ldx clip_out_x
 stx tmpidx
 ldy camera_plane_bucket_ready
.if CAMERA_MOVABLE != 0
 lda clip_a_vzlo,y
 sta camera_depth_geometric_lo,x
 lda clip_a_vzhi,y
 sta camera_depth_geometric_hi,x
.else
 lda clip_a_vzlo,y
 sta sz,x
 lda clip_a_vzhi,y
 sta szhi,x
.endif
 jmp camera_plane_project_clip_a_loaded_depth

camera_plane_project_original_intersection:
 ldx clip_out_x
 stx tmpidx
.if CAMERA_MOVABLE != 0
 lda #$01
 sta camera_depth_geometric_lo,x
 lda #$00
 sta camera_depth_geometric_hi,x
.else
 lda #$01
 sta sz,x
 lda #$00
 sta szhi,x
.endif
camera_plane_project_clip_a_loaded_depth:
; Clip projection reuses tmpidx (the source face's first vertex) as the
; explorer projection destination. Preserve its cached screen point: projdone
; is already set for ordinary mesh vertices, so a later face would otherwise
; consume the last generated clip point as this source vertex.
 ldx tmpidx
 lda sx,x
 sta camera_plane_saved_sx
 lda sy,x
 sta camera_plane_saved_sy
.if CAMERA_MOVABLE != 0
 ldy camera_plane_bucket_ready
 lda clip_a_vxlo,y
 sta p1lo
 lda clip_a_vxhi,y
 sta p1hi
 jsr explorer_project_x16
 ldy camera_plane_bucket_ready
 ldx tmpidx
 lda pxrawlo,x
 sta clip_a_xlo,y
 lda pxrawhi,x
 sta clip_a_xhi,y
 lda sx,x
 sta clip_a_x,y
 lda clip_a_vylo,y
 sta p1lo
 lda clip_a_vyhi,y
 sta p1hi
 jsr explorer_project_y16
 ldy camera_plane_bucket_ready
 ldx tmpidx
 lda pyrawlo,x
 sta clip_a_ylo,y
 lda pyrawhi,x
 sta clip_a_yhi,y
 lda sy,x
 sta clip_a_y,y
.if WORLD_GROUND_PLANE_CLIP != 0
 lda vzrawlo,x
 sta camera_depth_geometric_lo,x
 lda vzrawhi,x
 sta camera_depth_geometric_hi,x
.endif
.else
 ldy camera_plane_bucket_ready
 lda clip_a_vxlo,y
 sta rxbuf,x
 lda clip_a_vylo,y
 sta rybuf,x
 lda #$00
 sta projdone,x
 jsr project_vertex
 ldy camera_plane_bucket_ready
 ldx tmpidx
 lda pxrawlo,x
 sta clip_a_xlo,y
 lda pxrawhi,x
 sta clip_a_xhi,y
 lda pyrawlo,x
 sta clip_a_ylo,y
 lda pyrawhi,x
 sta clip_a_yhi,y
 lda sx,x
 sta clip_a_x,y
 lda sy,x
 sta clip_a_y,y
 lda vxrawlo,x
 sta rxbuf,x
 lda vyrawlo,x
 sta rybuf,x
 lda vzrawlo,x
 sta sz,x
 lda vzrawhi,x
 sta szhi,x
 lda #$00
 sta projdone,x
.endif
 ldx tmpidx
 lda camera_plane_saved_sx
 sta sx,x
 lda camera_plane_saved_sy
 sta sy,x
 rts

camera_plane_get_face_vertex:
 ldy sortj
 cpx #$00
 beq cpgfv_0
 cpx #$01
 beq cpgfv_1
 cpx #$02
 beq cpgfv_2
 lda face3,y
 rts
cpgfv_0:
 lda face0,y
 rts
cpgfv_1:
 lda face1,y
 rts
cpgfv_2:
 lda face2,y
 rts

; Preserve the established coarse painter key, but derive it from the
; camera-clipped polygon before viewport clipping mutates the working arrays.
camera_plane_store_bucket_from_a:
 lda clip_a_count
 cmp #$03
 bcc cpsb_done
 lda clip_a_vzlo
 sta p1lo
 lda clip_a_vzhi
 sta p1hi
 clc
 lda p1lo
 adc clip_a_vzlo+2
 sta p1lo
 lda p1hi
 adc clip_a_vzhi+2
 sta p1hi
 bcc cpsb_sum_ok
 lda #$ff
 sta p1lo
 sta p1hi
cpsb_sum_ok:
.if CAMERA_MOVABLE != 0 || GRAPHICS_MODE = $04 || GRAPHICS_MODE = $05
 lsr p1hi
 ror p1lo
 lsr p1hi
 ror p1lo
 lsr p1hi
 ror p1lo
 lda p1hi
 beq cpsb_mobile_ready
 lda #$fe
 sta p1lo
 jmp cpsb_store
cpsb_mobile_ready:
 lda p1lo
 cmp #$ff
 bne cpsb_store
 lda #$fe
 sta p1lo
.else
 lda p1hi
 bne cpsb_fixed_sat
 lsr p1lo
 jmp cpsb_store
cpsb_fixed_sat:
 lda #$fe
 sta p1lo
.endif
cpsb_store:
 lda p1lo
 sta camera_plane_bucket_depth
 lda #$01
 sta camera_plane_bucket_ready
cpsb_done:
 rts
.endif
clpx_empty:
 lda #$01
 sta clip_poly_active
 lda #$00
 sta clip_a_count
clpx_done:
 rts

.if EXPLORER_NEAR_POLY != 0
clip_loaded_face_near_poly:
 lda near_face_crossing
 bne cln_crossing
 rts
cln_crossing:
.if EXPLORER_NEAR_FILL != 0
 jmp clip_near_fullscreen_fill
.endif
cln_start:
 lda #$01
 sta clip_poly_active
 lda #$00
 sta clip_a_count
 lda loaded_face_vertex_count
 sec
 sbc #$01
 sta clip_prev_idx
 ldx clip_prev_idx
 jsr near_get_face_vertex
 tax
 lda projdone,x
 sta clip_prev_inside
 lda #$00
 sta clip_cur_idx
cln_loop:
 ldx clip_cur_idx
 jsr near_get_face_vertex
 tax
 lda projdone,x
 sta clip_cur_inside
 beq cln_cur_outside
 lda clip_prev_inside
 bne cln_append_cur
 jsr near_append_intersection
cln_append_cur:
 jsr near_append_current_vertex
 jmp cln_next
cln_cur_outside:
 lda clip_prev_inside
 beq cln_next
 jsr near_append_intersection
cln_next:
 lda clip_cur_idx
 sta clip_prev_idx
 lda clip_cur_inside
 sta clip_prev_inside
 inc clip_cur_idx
 lda clip_cur_idx
 cmp loaded_face_vertex_count
 bne cln_loop
 lda clip_a_count
 beq cln_done
.if EXPLORER_CAMERA_X_CLIP != 0
 jsr clip_poly_clip_camera_x_current
.else
 jsr clip_poly_clip_screen_current
.endif
cln_done:
 rts

.if EXPLORER_NEAR_FILL != 0
clip_near_fullscreen_fill:
 lda #$01
 sta clip_poly_active
 lda #$04
 sta clip_a_count
 lda #$00
 sta clip_a_xlo
 sta clip_a_xhi
 sta clip_a_ylo
 sta clip_a_yhi
 sta clip_a_x
 sta clip_a_y
 sta clip_a_xhi+1
 sta clip_a_ylo+1
 sta clip_a_yhi+1
 sta clip_a_y+1
 sta clip_a_xhi+2
 sta clip_a_yhi+2
 sta clip_a_xlo+3
 sta clip_a_xhi+3
 sta clip_a_yhi+3
 sta clip_a_x+3
 lda #PROJ_SCREEN_MAX_X
 sta clip_a_xlo+1
 sta clip_a_x+1
 sta clip_a_xlo+2
 sta clip_a_x+2
 lda #PROJ_SCREEN_MAX_Y
 sta clip_a_ylo+2
 sta clip_a_y+2
 sta clip_a_ylo+3
 sta clip_a_y+3
 rts
.endif

near_get_face_vertex:
 ldy sortj
 cpx #$00
 beq ngfv_0
 cpx #$01
 beq ngfv_1
 cpx #$02
 beq ngfv_2
 lda face3,y
 rts
ngfv_0:
 lda face0,y
 rts
ngfv_1:
 lda face1,y
 rts
ngfv_2:
 lda face2,y
 rts

near_append_current_vertex:
 ldx clip_cur_idx
 jsr near_get_face_vertex
 tax
 ldy clip_a_count
 lda pxrawlo,x
 sta clip_a_xlo,y
 lda pxrawhi,x
 sta clip_a_xhi,y
 lda pyrawlo,x
 sta clip_a_ylo,y
 lda pyrawhi,x
 sta clip_a_yhi,y
 lda sx,x
 sta clip_a_x,y
 lda sy,x
 sta clip_a_y,y
.if WIRE_RENDER_ENABLE != 0
 lda #$00
 sta clip_a_flag,y
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
 lda vxrawlo,x
 sta clip_a_vxlo,y
 lda vxrawhi,x
 sta clip_a_vxhi,y
 lda vyrawlo,x
 sta clip_a_vylo,y
 lda vyrawhi,x
 sta clip_a_vyhi,y
 lda vzrawlo,x
 sta clip_a_vzlo,y
 lda vzrawhi,x
 sta clip_a_vzhi,y
.endif
 inc clip_a_count
 rts

near_append_intersection:
 lda clip_cur_inside
 beq nai_cur_outside
 ldx clip_prev_idx
 jsr near_get_face_vertex
 sta p1lo
 ldx clip_cur_idx
 jsr near_get_face_vertex
 sta p1hi
 jmp near_project_intersection
nai_cur_outside:
 ldx clip_cur_idx
 jsr near_get_face_vertex
 sta p1lo
 ldx clip_prev_idx
 jsr near_get_face_vertex
 sta p1hi

near_project_intersection:
 ldx p1lo
 stx clip_in_x
 ldx p1hi
 stx clip_out_x
 ldx p1lo
 jsr near_depth_byte
 sta clip_in_y
 ldx p1hi
 jsr near_depth_byte
 sec
 sbc clip_in_y
 bne npi_den_ok
 lda #$01
npi_den_ok:
 sta clip_den
 lda #CAMERA_FACE_MIN_DEPTH
 sec
 sbc clip_in_y
 sta clip_num
 lda clip_num
 sta clip_num16_lo
 lda #$00
 sta clip_num16_hi
 lda clip_den
 sta clip_den16_lo
 lda #$00
 sta clip_den16_hi
 jsr clip_ratio_to_scale8
 jsr near_interp_x_to_t1
 jsr near_interp_y_to_t2
 ldy clip_a_count
 lda #CAMERA_FACE_MIN_DEPTH
 sta clip_a_vzlo,y
 lda #$00
 sta clip_a_vzhi,y
 ldx clip_a_count
 jsr clip_project_a_x_from_camera
 ldx clip_a_count
 jsr clip_project_a_y_from_camera
.if WIRE_RENDER_ENABLE != 0
 ldy clip_a_count
 lda #$01
 sta clip_a_flag,y
.endif
 inc clip_a_count
 rts

near_interp_x_to_t1:
 ldx clip_out_x
 lda vxrawlo,x
 sta p1lo
 lda vxrawhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc vxrawlo,x
 sta p1lo
 lda p1hi
 sbc vxrawhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc vxrawlo,x
 sta p1lo
 lda p1hi
 adc vxrawhi,x
 sta p1hi
 ldy clip_a_count
 lda p1lo
 sta clip_a_vxlo,y
 lda p1hi
 sta clip_a_vxhi,y
 rts

near_interp_y_to_t2:
 ldx clip_out_x
 lda vyrawlo,x
 sta p1lo
 lda vyrawhi,x
 sta p1hi
 ldx clip_in_x
 sec
 lda p1lo
 sbc vyrawlo,x
 sta p1lo
 lda p1hi
 sbc vyrawhi,x
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 ldx clip_in_x
 clc
 lda p1lo
 adc vyrawlo,x
 sta p1lo
 lda p1hi
 adc vyrawhi,x
 sta p1hi
 ldy clip_a_count
 lda p1lo
 sta clip_a_vylo,y
 lda p1hi
 sta clip_a_vyhi,y
 rts

near_depth_byte:
 lda vzrawhi,x
 bmi ndb_zero
 beq ndb_low
 lda #$ff
 rts
ndb_low:
 lda vzrawlo,x
 rts
ndb_zero:
 lda #$00
 rts

near_project_abs_scale:
 ldx #EXPLORER_PROJ_FOCAL
 jsr clip_mul_u8_poly
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lda prodhi
 beq npas_ok
 lda #$ff
 rts
npas_ok:
 lda prodlo
 rts

near_project_t1_to_clip_x:
 lda t1
 bmi nptx_left
 jsr near_project_abs_scale
 sta scalev
 clc
 lda #PROJ_CENTER_X
 adc scalev
 sta clip_a_xlo,y
 lda #$00
 adc #$00
 sta clip_a_xhi,y
 lda clip_a_xhi,y
 bne nptx_right_clamp
 lda clip_a_xlo,y
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs nptx_right_clamp
 sta clip_a_x,y
 rts
nptx_right_clamp:
 lda #PROJ_SCREEN_MAX_X
 sta clip_a_x,y
 rts
nptx_left:
 eor #$ff
 clc
 adc #$01
 jsr near_project_abs_scale
 sta scalev
 lda #PROJ_CENTER_X
 sec
 sbc scalev
 sta clip_a_xlo,y
 lda #$00
 sbc #$00
 sta clip_a_xhi,y
 lda clip_a_xhi,y
 bmi nptx_left_clamp
 lda clip_a_xlo,y
 sta clip_a_x,y
 rts
nptx_left_clamp:
 lda #$00
 sta clip_a_x,y
 rts

near_project_t2_to_clip_y:
 lda t2
 bmi npty_down
 jsr near_project_abs_scale
 sta scalev
 lda #PROJ_CENTER_Y
 sec
 sbc scalev
 sta clip_a_ylo,y
 lda #$00
 sbc #$00
 sta clip_a_yhi,y
 lda clip_a_yhi,y
 bmi npty_top_clamp
 lda clip_a_ylo,y
 sta clip_a_y,y
 rts
npty_top_clamp:
 lda #$00
 sta clip_a_y,y
 rts
npty_down:
 eor #$ff
 clc
 adc #$01
 jsr near_project_abs_scale
 sta scalev
 clc
 lda #PROJ_CENTER_Y
 adc scalev
 sta clip_a_ylo,y
 lda #$00
 adc #$00
 sta clip_a_yhi,y
 lda clip_a_yhi,y
 bne npty_bottom_clamp
 lda clip_a_ylo,y
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs npty_bottom_clamp
 sta clip_a_y,y
 rts
npty_bottom_clamp:
 lda #PROJ_SCREEN_MAX_Y
 sta clip_a_y,y
 rts
.endif

clip_poly_all_outside_screen:
 jsr clip_poly_all_right_screen
 bne cpaos_yes
 jsr clip_poly_all_left_screen
 bne cpaos_yes
 jsr clip_poly_all_top_screen
 bne cpaos_yes
 jsr clip_poly_all_bottom_screen
 bne cpaos_yes
cpaos_no:
 lda #$00
 rts
cpaos_yes:
 lda #$01
 rts

clip_poly_all_right_screen:
 ldy sortj
 ldx face0,y
 jsr clip_right_outside_x_poly
 beq cpars_no
 ldy sortj
 ldx face1,y
 jsr clip_right_outside_x_poly
 beq cpars_no
 ldy sortj
 ldx face2,y
 jsr clip_right_outside_x_poly
 beq cpars_no
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne cpars_yes
.endif
 ldy sortj
 ldx face3,y
 jsr clip_right_outside_x_poly
 beq cpars_no
cpars_yes:
 lda #$01
 rts
cpars_no:
 lda #$00
 rts

clip_poly_all_left_screen:
 ldy sortj
 ldx face0,y
 jsr clip_left_outside_x_poly
 beq cpals_no
 ldy sortj
 ldx face1,y
 jsr clip_left_outside_x_poly
 beq cpals_no
 ldy sortj
 ldx face2,y
 jsr clip_left_outside_x_poly
 beq cpals_no
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne cpals_yes
.endif
 ldy sortj
 ldx face3,y
 jsr clip_left_outside_x_poly
 beq cpals_no
cpals_yes:
 lda #$01
 rts
cpals_no:
 lda #$00
 rts

clip_poly_all_top_screen:
 ldy sortj
 ldx face0,y
 jsr clip_top_outside_y_poly
 beq cpats_no
 ldy sortj
 ldx face1,y
 jsr clip_top_outside_y_poly
 beq cpats_no
 ldy sortj
 ldx face2,y
 jsr clip_top_outside_y_poly
 beq cpats_no
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne cpats_yes
.endif
 ldy sortj
 ldx face3,y
 jsr clip_top_outside_y_poly
 beq cpats_no
cpats_yes:
 lda #$01
 rts
cpats_no:
 lda #$00
 rts

clip_poly_all_bottom_screen:
 ldy sortj
 ldx face0,y
 jsr clip_bottom_outside_y_poly
 beq cpabs_no
 ldy sortj
 ldx face1,y
 jsr clip_bottom_outside_y_poly
 beq cpabs_no
 ldy sortj
 ldx face2,y
 jsr clip_bottom_outside_y_poly
 beq cpabs_no
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne cpabs_yes
.endif
 ldy sortj
 ldx face3,y
 jsr clip_bottom_outside_y_poly
 beq cpabs_no
cpabs_yes:
 lda #$01
 rts
cpabs_no:
 lda #$00
 rts

clip_poly_needs_screen:
 lda #$00
 sta maskv
 ldy sortj
 ldx face0,y
 jsr clip_right_outside_x_poly
 bne cpnx_yes
 jsr clip_left_outside_x_poly
 bne cpnx_yes
 jsr clip_top_outside_y_poly
 bne cpnx_yes
 jsr clip_bottom_outside_y_poly
 bne cpnx_yes
 ldy sortj
 ldx face1,y
 jsr clip_right_outside_x_poly
 bne cpnx_yes
 jsr clip_left_outside_x_poly
 bne cpnx_yes
 jsr clip_top_outside_y_poly
 bne cpnx_yes
 jsr clip_bottom_outside_y_poly
 bne cpnx_yes
 ldy sortj
 ldx face2,y
 jsr clip_right_outside_x_poly
 bne cpnx_yes
 jsr clip_left_outside_x_poly
 bne cpnx_yes
 jsr clip_top_outside_y_poly
 bne cpnx_yes
 jsr clip_bottom_outside_y_poly
 bne cpnx_yes
.if HAS_TRI_FACES != 0
 ldy sortj
 lda face_vertex_count,y
 cmp #$04
 bne cpnx_no
.endif
 ldy sortj
 ldx face3,y
 jsr clip_right_outside_x_poly
 bne cpnx_yes
 jsr clip_left_outside_x_poly
 bne cpnx_yes
 jsr clip_top_outside_y_poly
 bne cpnx_yes
 jsr clip_bottom_outside_y_poly
 bne cpnx_yes
cpnx_no:
 lda #$00
 rts
cpnx_yes:
 lda #$01
 rts

clip_poly_init_from_face:
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 sta clip_a_count
.else
 lda #$04
 sta clip_a_count
.endif
 ldy sortj
 ldx face0,y
 ldy #$00
 jsr clip_poly_load_vertex_a
 ldy sortj
 ldx face1,y
 ldy #$01
 jsr clip_poly_load_vertex_a
 ldy sortj
 ldx face2,y
 ldy #$02
 jsr clip_poly_load_vertex_a
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne cpiff_done
.endif
 ldy sortj
 ldx face3,y
 ldy #$03
 jsr clip_poly_load_vertex_a
cpiff_done:
 rts

clip_poly_load_vertex_a:
 lda pxrawlo,x
 sta clip_a_xlo,y
 lda pxrawhi,x
 sta clip_a_xhi,y
 lda pyrawlo,x
 sta clip_a_ylo,y
 lda pyrawhi,x
 sta clip_a_yhi,y
 lda sx,x
 sta clip_a_x,y
 lda sy,x
 sta clip_a_y,y
.if WIRE_RENDER_ENABLE != 0
 lda #$00
 sta clip_a_flag,y
.endif
.if EXPLORER_NEAR_POLY != 0
 lda vxrawlo,x
 sta clip_a_vxlo,y
 lda vxrawhi,x
 sta clip_a_vxhi,y
 lda vyrawlo,x
 sta clip_a_vylo,y
 lda vyrawhi,x
 sta clip_a_vyhi,y
 lda vzrawlo,x
 sta clip_a_vzlo,y
 lda vzrawhi,x
 sta clip_a_vzhi,y
.endif
 rts

clip_poly_right_a_to_b:
 lda #$00
 sta clip_b_count
 lda clip_a_count
 beq cpra_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
cpra_loop:
 ldx clip_prev_idx
 jsr clip_a_right_inside
 sta clip_prev_inside
 ldx clip_cur_idx
 jsr clip_a_right_inside
 sta clip_cur_inside
 lda clip_cur_inside
 beq cpra_cur_out
 lda clip_prev_inside
 bne cpra_append_cur
 jsr clip_append_right_intersection_a_to_b
cpra_append_cur:
 ldx clip_cur_idx
 jsr clip_copy_a_to_b
 jmp cpra_next
cpra_cur_out:
 lda clip_prev_inside
 beq cpra_next
 jsr clip_append_right_intersection_a_to_b
cpra_next:
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne cpra_loop
cpra_done:
 rts

clip_poly_left_b_to_a:
 lda #$00
 sta clip_a_count
 lda clip_b_count
 beq cplb_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
cplb_loop:
 ldx clip_prev_idx
 jsr clip_b_left_inside
 sta clip_prev_inside
 ldx clip_cur_idx
 jsr clip_b_left_inside
 sta clip_cur_inside
 lda clip_cur_inside
 beq cplb_cur_out
 lda clip_prev_inside
 bne cplb_append_cur
 jsr clip_append_left_intersection_b_to_a
cplb_append_cur:
 ldx clip_cur_idx
 jsr clip_copy_b_to_a
 jmp cplb_next
cplb_cur_out:
 lda clip_prev_inside
 beq cplb_next
 jsr clip_append_left_intersection_b_to_a
cplb_next:
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_b_count
 bne cplb_loop
cplb_done:
 rts

clip_poly_top_a_to_b:
 lda #$00
 sta clip_b_count
 lda clip_a_count
 beq cpta_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
cpta_loop:
 ldx clip_prev_idx
 jsr clip_a_top_inside
 sta clip_prev_inside
 ldx clip_cur_idx
 jsr clip_a_top_inside
 sta clip_cur_inside
 lda clip_cur_inside
 beq cpta_cur_out
 lda clip_prev_inside
 bne cpta_append_cur
 jsr clip_append_top_intersection_a_to_b
cpta_append_cur:
 ldx clip_cur_idx
 jsr clip_copy_a_to_b
 jmp cpta_next
cpta_cur_out:
 lda clip_prev_inside
 beq cpta_next
 jsr clip_append_top_intersection_a_to_b
cpta_next:
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne cpta_loop
cpta_done:
 rts

clip_poly_bottom_b_to_a:
 lda #$00
 sta clip_a_count
 lda clip_b_count
 beq cpbb_done
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
cpbb_loop:
 ldx clip_prev_idx
 jsr clip_b_bottom_inside
 sta clip_prev_inside
 ldx clip_cur_idx
 jsr clip_b_bottom_inside
 sta clip_cur_inside
 lda clip_cur_inside
 beq cpbb_cur_out
 lda clip_prev_inside
 bne cpbb_append_cur
 jsr clip_append_bottom_intersection_b_to_a
cpbb_append_cur:
 ldx clip_cur_idx
 jsr clip_copy_b_to_a
 jmp cpbb_next
cpbb_cur_out:
 lda clip_prev_inside
 beq cpbb_next
 jsr clip_append_bottom_intersection_b_to_a
cpbb_next:
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_b_count
 bne cpbb_loop
cpbb_done:
 rts

clip_a_right_inside:
 lda clip_a_xhi,x
 bmi cari_yes
 bne cari_no
 lda clip_a_xlo,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs cari_no
cari_yes:
 lda #$01
 rts
cari_no:
 lda #$00
 rts

clip_b_left_inside:
 lda clip_b_xhi,x
 bmi cbli_no
 lda #$01
 rts
cbli_no:
 lda #$00
 rts

clip_a_top_inside:
 lda clip_a_yhi,x
 bmi cati_no
 lda #$01
 rts
cati_no:
 lda #$00
 rts

clip_b_bottom_inside:
 lda clip_b_yhi,x
 bmi cbbi_yes
 bne cbbi_no
 lda clip_b_ylo,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs cbbi_no
cbbi_yes:
 lda #$01
 rts
cbbi_no:
 lda #$00
 rts

clip_copy_a_to_b:
 ldy clip_b_count
 lda clip_a_xlo,x
 sta clip_b_xlo,y
 lda clip_a_xhi,x
 sta clip_b_xhi,y
 lda clip_a_ylo,x
 sta clip_b_ylo,y
 lda clip_a_yhi,x
 sta clip_b_yhi,y
 lda clip_a_x,x
 sta clip_b_x,y
 lda clip_a_y,x
 sta clip_b_y,y
.if WIRE_RENDER_ENABLE != 0
 lda clip_a_flag,x
 sta clip_b_flag,y
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
 lda clip_a_vxlo,x
 sta clip_b_vxlo,y
 lda clip_a_vxhi,x
 sta clip_b_vxhi,y
 lda clip_a_vylo,x
 sta clip_b_vylo,y
 lda clip_a_vyhi,x
 sta clip_b_vyhi,y
 lda clip_a_vzlo,x
 sta clip_b_vzlo,y
 lda clip_a_vzhi,x
 sta clip_b_vzhi,y
.endif
 inc clip_b_count
 rts

clip_copy_b_to_a:
 ldy clip_a_count
 lda clip_b_xlo,x
 sta clip_a_xlo,y
 lda clip_b_xhi,x
 sta clip_a_xhi,y
 lda clip_b_ylo,x
 sta clip_a_ylo,y
 lda clip_b_yhi,x
 sta clip_a_yhi,y
 lda clip_b_x,x
 sta clip_a_x,y
 lda clip_b_y,x
 sta clip_a_y,y
.if WIRE_RENDER_ENABLE != 0
 lda clip_b_flag,x
 sta clip_a_flag,y
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
 lda clip_b_vxlo,x
 sta clip_a_vxlo,y
 lda clip_b_vxhi,x
 sta clip_a_vxhi,y
 lda clip_b_vylo,x
 sta clip_a_vylo,y
 lda clip_b_vyhi,x
 sta clip_a_vyhi,y
 lda clip_b_vzlo,x
 sta clip_a_vzlo,y
 lda clip_b_vzhi,x
 sta clip_a_vzhi,y
.endif
 inc clip_a_count
 rts

clip_append_right_intersection_a_to_b:
 ldx clip_prev_idx
 jsr clip_a_right_inside
 bne carib_prev_inside
 ldx clip_cur_idx
 jsr clip_load_inside_right_a
 ldx clip_prev_idx
 jsr clip_load_outside_right_a
 jmp carib_interp
carib_prev_inside:
 ldx clip_prev_idx
 jsr clip_load_inside_right_a
 ldx clip_cur_idx
 jsr clip_load_outside_right_a
carib_interp:
 jsr clip_interp_raw_poly
 ldy clip_b_count
 lda p1lo
 sta clip_b_ylo,y
 lda p1hi
 sta clip_b_yhi,y
 jsr clip_clamp_p1_y
 ldy clip_b_count
 sta clip_b_y,y
 lda #PROJ_SCREEN_MAX_X
 sta clip_b_x,y
 sta clip_b_xlo,y
 lda #PROJ_SCREEN_MIN_X
 sta clip_b_xhi,y
.if WIRE_RENDER_ENABLE != 0
 lda #$01
 sta clip_b_flag,y
.endif
 inc clip_b_count
 rts

clip_append_left_intersection_b_to_a:
 ldx clip_prev_idx
 jsr clip_b_left_inside
 bne calia_prev_inside
 ldx clip_cur_idx
 jsr clip_load_inside_left_b
 ldx clip_prev_idx
 jsr clip_load_outside_left_b
 jmp calia_interp
calia_prev_inside:
 ldx clip_prev_idx
 jsr clip_load_inside_left_b
 ldx clip_cur_idx
 jsr clip_load_outside_left_b
calia_interp:
 jsr clip_interp_raw_poly
 ldy clip_a_count
 lda p1lo
 sta clip_a_ylo,y
 lda p1hi
 sta clip_a_yhi,y
 jsr clip_clamp_p1_y
 ldy clip_a_count
 sta clip_a_y,y
 lda #$00
 sta clip_a_x,y
 sta clip_a_xlo,y
 sta clip_a_xhi,y
.if WIRE_RENDER_ENABLE != 0
 lda #$01
 sta clip_a_flag,y
.endif
 inc clip_a_count
 rts

clip_append_top_intersection_a_to_b:
 ldx clip_prev_idx
 jsr clip_a_top_inside
 bne catib_prev_inside
 ldx clip_cur_idx
 jsr clip_load_inside_top_a
 ldx clip_prev_idx
 jsr clip_load_outside_top_a
 jmp catib_interp
catib_prev_inside:
 ldx clip_prev_idx
 jsr clip_load_inside_top_a
 ldx clip_cur_idx
 jsr clip_load_outside_top_a
catib_interp:
 jsr clip_interp_raw_poly
 ldy clip_b_count
 lda p1lo
 sta clip_b_xlo,y
 lda p1hi
 sta clip_b_xhi,y
 jsr clip_clamp_p1_x
 ldy clip_b_count
 sta clip_b_x,y
 lda #$00
 sta clip_b_y,y
 sta clip_b_ylo,y
 sta clip_b_yhi,y
.if WIRE_RENDER_ENABLE != 0
 lda #$01
 sta clip_b_flag,y
.endif
 inc clip_b_count
 rts

clip_append_bottom_intersection_b_to_a:
 ldx clip_prev_idx
 jsr clip_b_bottom_inside
 bne cabia_prev_inside
 ldx clip_cur_idx
 jsr clip_load_inside_bottom_b
 ldx clip_prev_idx
 jsr clip_load_outside_bottom_b
 jmp cabia_interp
cabia_prev_inside:
 ldx clip_prev_idx
 jsr clip_load_inside_bottom_b
 ldx clip_cur_idx
 jsr clip_load_outside_bottom_b
cabia_interp:
 jsr clip_interp_raw_poly
 ldy clip_a_count
 lda p1lo
 sta clip_a_xlo,y
 lda p1hi
 sta clip_a_xhi,y
 jsr clip_clamp_p1_x
 ldy clip_a_count
 sta clip_a_x,y
 lda #PROJ_SCREEN_MAX_Y
 sta clip_a_y,y
 sta clip_a_ylo,y
 lda #PROJ_SCREEN_MIN_Y
 sta clip_a_yhi,y
.if WIRE_RENDER_ENABLE != 0
 lda #$01
 sta clip_a_flag,y
.endif
 inc clip_a_count
 rts

clip_load_inside_right_a:
 lda clip_a_xlo,x
 sta clip_in_x
 sta clip_axis_in_lo
 lda clip_a_xhi,x
 sta clip_axis_in_hi
 lda clip_a_y,x
 sta clip_in_y
 lda clip_a_ylo,x
 sta clip_raw_in_lo
 lda clip_a_yhi,x
 sta clip_raw_in_hi
 sec
 lda #PROJ_SCREEN_MAX_X
 sbc clip_axis_in_lo
 sta clip_num
 sta clip_num16_lo
 lda #$00
 sbc clip_axis_in_hi
 sta clip_num16_hi
 rts

clip_load_outside_right_a:
 lda clip_a_y,x
 sta clip_out_y
 lda clip_a_ylo,x
 sta clip_raw_out_lo
 lda clip_a_yhi,x
 sta clip_raw_out_hi
 sec
 lda clip_a_xlo,x
 sbc clip_axis_in_lo
 sta clip_den16_lo
 lda clip_a_xhi,x
 sbc clip_axis_in_hi
 sta clip_den16_hi
 lda clip_a_xlo,x
 sec
 sbc clip_in_x
 sta clip_den
 lda clip_a_xhi,x
 sbc #$00
 beq clora_check_zero
 cmp #$01
 beq clora_half_den
 lda #$ff
 sta clip_den
 rts
clora_half_den:
 jsr clip_halve_num_den
 rts
clora_check_zero:
 lda clip_den
 bne clora_done
 lda #$01
 sta clip_den
clora_done:
 rts

clip_load_inside_left_b:
 lda clip_b_xlo,x
 sta clip_in_x
 sta clip_axis_in_lo
 sta clip_num
 sta clip_num16_lo
 lda clip_b_xhi,x
 sta clip_axis_in_hi
 sta clip_num16_hi
 lda clip_b_y,x
 sta clip_in_y
 lda clip_b_ylo,x
 sta clip_raw_in_lo
 lda clip_b_yhi,x
 sta clip_raw_in_hi
 rts

clip_load_outside_left_b:
 lda clip_b_y,x
 sta clip_out_y
 lda clip_b_ylo,x
 sta clip_raw_out_lo
 lda clip_b_yhi,x
 sta clip_raw_out_hi
 sec
 lda clip_axis_in_lo
 sbc clip_b_xlo,x
 sta clip_den16_lo
 lda clip_axis_in_hi
 sbc clip_b_xhi,x
 sta clip_den16_hi
 lda #$00
 sec
 sbc clip_b_xlo,x
 clc
 adc clip_in_x
 sta clip_den
 bcc clolb_check_zero
 jsr clip_halve_num_den
 rts
clolb_check_zero:
 lda clip_den
 bne clolb_nonzero
 lda #$01
clolb_nonzero:
 sta clip_den
 rts

clip_load_inside_top_a:
 lda clip_a_x,x
 sta clip_in_x
 lda clip_a_xlo,x
 sta clip_raw_in_lo
 lda clip_a_xhi,x
 sta clip_raw_in_hi
 lda clip_a_ylo,x
 sta clip_axis_in_lo
 sta clip_in_y
 sta clip_num
 sta clip_num16_lo
 lda clip_a_yhi,x
 sta clip_axis_in_hi
 sta clip_num16_hi
 beq clita_num_ready
 lda #$ff
 sta clip_in_y
 sta clip_num
clita_num_ready:
 rts

clip_load_outside_top_a:
 lda clip_a_x,x
 sta clip_out_x
 lda clip_a_xlo,x
 sta clip_raw_out_lo
 lda clip_a_xhi,x
 sta clip_raw_out_hi
 sec
 lda clip_axis_in_lo
 sbc clip_a_ylo,x
 sta clip_den16_lo
 lda clip_axis_in_hi
 sbc clip_a_yhi,x
 sta clip_den16_hi
 lda #$00
 sec
 sbc clip_a_ylo,x
 clc
 adc clip_in_y
 sta clip_den
 bcc clota_check_zero
 jsr clip_halve_num_den
 rts
clota_check_zero:
 lda clip_den
 bne clota_nonzero
 lda #$01
clota_nonzero:
 sta clip_den
 rts

clip_load_inside_bottom_b:
 lda clip_b_x,x
 sta clip_in_x
 lda clip_b_xlo,x
 sta clip_raw_in_lo
 lda clip_b_xhi,x
 sta clip_raw_in_hi
 lda clip_b_ylo,x
 sta clip_axis_in_lo
 sta clip_in_y
 lda clip_b_yhi,x
 sta clip_axis_in_hi
 sec
 lda #PROJ_SCREEN_MAX_Y
 sbc clip_axis_in_lo
 sta clip_num
 sta clip_num16_lo
 lda #$00
 sbc clip_axis_in_hi
 sta clip_num16_hi
 rts

clip_load_outside_bottom_b:
 lda clip_b_x,x
 sta clip_out_x
 lda clip_b_xlo,x
 sta clip_raw_out_lo
 lda clip_b_xhi,x
 sta clip_raw_out_hi
 sec
 lda clip_b_ylo,x
 sbc clip_axis_in_lo
 sta clip_den16_lo
 lda clip_b_yhi,x
 sbc clip_axis_in_hi
 sta clip_den16_hi
 lda clip_b_ylo,x
 sec
 sbc clip_in_y
 sta clip_den
 lda clip_b_yhi,x
 beq clobb_check_zero
 cmp #$01
 beq clobb_half_den
 lda #$ff
 sta clip_den
 rts
clobb_half_den:
 jsr clip_halve_num_den
 rts
clobb_check_zero:
 lda clip_den
 bne clobb_done
 lda #$01
 sta clip_den
clobb_done:
 rts

clip_halve_num_den:
 sec
 ror clip_den
 lda clip_num
 lsr
 bne chnd_num_ok
 lda #$01
chnd_num_ok:
 sta clip_num
 rts

clip_ratio_to_scale8:
 lda clip_den16_lo
 ora clip_den16_hi
 bne crts_den_ok
 lda #$01
 sta clip_den16_lo
 lda #$00
 sta clip_den16_hi
crts_den_ok:
 lda clip_num16_hi
 cmp clip_den16_hi
 bcc crts_fraction
 bne crts_max
 lda clip_num16_lo
 cmp clip_den16_lo
 bcc crts_fraction
crts_max:
 lda #$ff
 sta scalev
 rts
crts_fraction:
 lda clip_num16_lo
 sta prodlo
 lda clip_num16_hi
 sta prodhi
 lda #$00
 sta clip_rem_ext
 sta scalev
 ldx #$08
crts_loop:
 asl prodlo
 rol prodhi
 lda #$00
 rol clip_rem_ext
 lda clip_rem_ext
 bne crts_subtract
 lda prodhi
 cmp clip_den16_hi
 bcc crts_no_subtract
 bne crts_subtract
 lda prodlo
 cmp clip_den16_lo
 bcc crts_no_subtract
crts_subtract:
 sec
 lda prodlo
 sbc clip_den16_lo
 sta prodlo
 lda prodhi
 sbc clip_den16_hi
 sta prodhi
 lda clip_rem_ext
 sbc #$00
 sta clip_rem_ext
 sec
 jmp crts_shift_result
crts_no_subtract:
 clc
crts_shift_result:
 rol scalev
 dex
 bne crts_loop
 rts

clip_interp_raw_poly:
 jsr clip_ratio_to_scale8
 sec
 lda clip_raw_out_lo
 sbc clip_raw_in_lo
 sta p1lo
 lda clip_raw_out_hi
 sbc clip_raw_in_hi
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 clc
 lda p1lo
 adc clip_raw_in_lo
 sta p1lo
 lda p1hi
 adc clip_raw_in_hi
 sta p1hi
 rts

mul_s16_u8_frac:
 sta mul16mul
 lda #$00
 sta mul16sign
 lda p1hi
 bpl ms16u8_abs_ready
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
 lda #$80
 sta mul16sign
ms16u8_abs_ready:
 lda p1lo
 sta mul16lo
 lda p1hi
 sta mul16hi
 lda #$00
 sta mul16rem
 sta prodlo
 sta prodhi
 sta mul16reslo
 ldx #$08
ms16u8_loop:
 lsr mul16mul
 bcc ms16u8_no_add
 clc
 lda prodlo
 adc mul16lo
 sta prodlo
 lda prodhi
 adc mul16hi
 sta prodhi
 lda mul16reslo
 adc mul16rem
 sta mul16reslo
ms16u8_no_add:
 asl mul16lo
 rol mul16hi
 rol mul16rem
 dex
 bne ms16u8_loop
 lda prodhi
 sta p1lo
 lda mul16reslo
 sta p1hi
 lda mul16sign
 bpl ms16u8_done
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
ms16u8_done:
 rts

clip_clamp_p1_x:
 lda p1hi
 bmi ccpx_min
 bne ccpx_max
 lda p1lo
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs ccpx_max
 rts
ccpx_min:
 lda #PROJ_SCREEN_MIN_X
 rts
ccpx_max:
 lda #PROJ_SCREEN_MAX_X
 rts

clip_clamp_p1_y:
 lda p1hi
 bmi ccpy_min
 bne ccpy_max
 lda p1lo
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs ccpy_max
 rts
ccpy_min:
 lda #PROJ_SCREEN_MIN_Y
 rts
ccpy_max:
 lda #PROJ_SCREEN_MAX_Y
 rts

clip_interp_y_poly:
 sec
 lda clip_out_y
 sbc clip_in_y
 sta dy1v
 bpl ciyp_positive
 eor #$ff
 clc
 adc #$01
 ldx clip_num
 jsr clip_mul_u8_poly
 lda clip_den
 bne ciyp_neg_den_ready
 lda #$01
ciyp_neg_den_ready:
 sta p1lo
 lda #$00
 sta p1hi
 jsr div16u
 lda clip_in_y
 sec
 sbc prodlo
 bcs ciyp_done
 lda #$00
 rts
ciyp_positive:
 lda dy1v
 ldx clip_num
 jsr clip_mul_u8_poly
 lda clip_den
 bne ciyp_pos_den_ready
 lda #$01
ciyp_pos_den_ready:
 sta p1lo
 lda #$00
 sta p1hi
 jsr div16u
 clc
 lda clip_in_y
 adc prodlo
 bcs ciyp_max
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcc ciyp_done
ciyp_max:
 lda #PROJ_SCREEN_MAX_Y
ciyp_done:
 rts

clip_interp_x_poly:
 sec
 lda clip_out_x
 sbc clip_in_x
 sta dx1v
 bpl cixp_positive
 eor #$ff
 clc
 adc #$01
 ldx clip_num
 jsr clip_mul_u8_poly
 lda clip_den
 bne cixp_neg_den_ready
 lda #$01
cixp_neg_den_ready:
 sta p1lo
 lda #$00
 sta p1hi
 jsr div16u
 lda clip_in_x
 sec
 sbc prodlo
 bcs cixp_done
 lda #$00
 rts
cixp_positive:
 lda dx1v
 ldx clip_num
 jsr clip_mul_u8_poly
 lda clip_den
 bne cixp_pos_den_ready
 lda #$01
cixp_pos_den_ready:
 sta p1lo
 lda #$00
 sta p1hi
 jsr div16u
 clc
 lda clip_in_x
 adc prodlo
 bcs cixp_max
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcc cixp_done
cixp_max:
 lda #PROJ_SCREEN_MAX_X
cixp_done:
 rts

clip_mul_u8_poly:
 sta mul16lo
 lda #$00
 sta mul16hi
 stx mul16mul
 lda #$00
 sta prodlo
 sta prodhi
 ldx #$08
cmu8p_loop:
 lsr mul16mul
 bcc cmu8p_no_add
 clc
 lda prodlo
 adc mul16lo
 sta prodlo
 lda prodhi
 adc mul16hi
 sta prodhi
cmu8p_no_add:
 asl mul16lo
 rol mul16hi
 dex
 bne cmu8p_loop
 rts

clip_poly_drawable:
 lda clip_a_count
 cmp #$03
 bcc cpd_no
 lda clip_a_x
 sta p1lo
 sta p1hi
 ldx #$01
cpd_x_loop:
 cpx clip_a_count
 beq cpd_x_span
 lda clip_a_x,x
 cmp p1lo
 bcs cpd_x_min_ok
 sta p1lo
cpd_x_min_ok:
 cmp p1hi
 bcc cpd_x_next
 sta p1hi
cpd_x_next:
 inx
 jmp cpd_x_loop
cpd_x_span:
 sec
 lda p1hi
 sbc p1lo
.if SCENE_OBJECT_COUNT != 0
 sta spanw
 cmp #SCREEN_MIN_SPAN
 bcc cpd_no
.else
.if PATTERN_MIN_SPAN != 0
 sta spanw
.endif
 cmp #SCREEN_MIN_SPAN
 bcc cpd_no
.endif
cpd_y_bounds:
 lda clip_a_y
 sta p1lo
 sta p1hi
 ldx #$01
cpd_y_loop:
 cpx clip_a_count
 beq cpd_y_span
 lda clip_a_y,x
 cmp p1lo
 bcs cpd_y_min_ok
 sta p1lo
cpd_y_min_ok:
 cmp p1hi
 bcc cpd_y_next
 sta p1hi
cpd_y_next:
 inx
 jmp cpd_y_loop
cpd_y_span:
 sec
 lda p1hi
 sbc p1lo
.if SCENE_OBJECT_COUNT != 0
 sta spanh
 cmp #SCREEN_MIN_SPAN
 bcc cpd_no
.else
.if PATTERN_MIN_SPAN != 0
 sta spanh
.endif
 cmp #SCREEN_MIN_SPAN
 bcc cpd_no
.endif
cpd_yes:
 sec
 rts
cpd_no:
 clc
 rts

clip_poly_visible:
 lda clip_a_count
 cmp #$03
 bcc cpv_no
 ldx #$00
 jsr clip_poly_load_cull_v0
 ldx #$01
 jsr clip_poly_load_cull_v1
 ldx #$02
 jsr clip_poly_load_cull_v2
 sec
 lda vy1
 sbc vy0
 sta dy1v
 sec
 lda vx2
 sbc vx0
 tax
 sec
 lda vy2
 sbc vy0
 stx dx2v
 tax
 sec
 lda vx1
 sbc vx0
 jsr mul_s8_16
 lda prodlo
 sta p1lo
 lda prodhi
 sta p1hi
 lda dy1v
 ldx dx2v
 jsr mul_s8_16
 sec
 lda p1lo
 sbc prodlo
 sta crosslo
 lda p1hi
 sbc prodhi
 sta crosshi
 lda crosshi
 bmi cpv_no
 bne cpv_yes
 lda crosslo
 cmp #$01
 bcc cpv_no
cpv_yes:
 sec
 rts
cpv_no:
 clc
 rts

clip_poly_load_cull_v0:
 lda clip_a_x,x
 lsr
 sec
 sbc #PROJ_CENTER_X_HALF
 sta vx0
 lda #PROJ_CENTER_Y
 sec
 sbc clip_a_y,x
 sta vy0
 rts

clip_poly_load_cull_v1:
 lda clip_a_x,x
 lsr
 sec
 sbc #PROJ_CENTER_X_HALF
 sta vx1
 lda #PROJ_CENTER_Y
 sec
 sbc clip_a_y,x
 sta vy1
 rts

clip_poly_load_cull_v2:
 lda clip_a_x,x
 lsr
 sec
 sbc #PROJ_CENTER_X_HALF
 sta vx2
 lda #PROJ_CENTER_Y
 sec
 sbc clip_a_y,x
 sta vy2
 rts

clip_right_outside_x_poly:
 lda pxrawhi,x
 bmi croxp_no
 bne croxp_yes
 lda pxrawlo,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs croxp_yes
croxp_no:
 lda #$00
 rts
croxp_yes:
 lda #$01
 rts

clip_left_outside_x_poly:
 lda pxrawhi,x
 bmi cloxp_yes
 lda #$00
 rts
cloxp_yes:
 lda #$01
 rts

clip_top_outside_y_poly:
 lda pyrawhi,x
 bmi ctoyp_yes
 lda #$00
 rts
ctoyp_yes:
 lda #$01
 rts

clip_bottom_outside_y_poly:
 lda pyrawhi,x
 bmi cboyp_no
 bne cboyp_yes
 lda pyrawlo,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs cboyp_yes
cboyp_no:
 lda #$00
 rts
cboyp_yes:
 lda #$01
 rts
.endif

.if EXPLORER_SCREEN_CLIP_X != 0
clip_loaded_face_screen_x:
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 beq clfsx_quad
 rts
clfsx_quad:
.endif
 jsr clip_face_right_x_simple
 jsr clip_face_left_x_simple
 rts

clip_face_right_x_simple:
 lda #$00
 sta maskv
 ldy sortj
 ldx face0,y
 jsr clip_right_outside_x
 beq cfrx_mask_v1
 lda maskv
 ora #$01
 sta maskv
cfrx_mask_v1:
 ldy sortj
 ldx face1,y
 jsr clip_right_outside_x
 beq cfrx_mask_v2
 lda maskv
 ora #$02
 sta maskv
cfrx_mask_v2:
 ldy sortj
 ldx face2,y
 jsr clip_right_outside_x
 beq cfrx_mask_v3
 lda maskv
 ora #$04
 sta maskv
cfrx_mask_v3:
 ldy sortj
 ldx face3,y
 jsr clip_right_outside_x
 beq cfrx_mask_eval
 lda maskv
 ora #$08
 sta maskv
cfrx_mask_eval:
 lda maskv
 cmp #$01
 beq clfr_one0
 cmp #$02
 beq clfr_one1
 cmp #$04
 beq clfr_one2
 cmp #$08
 beq clfr_one3
 ldy sortj
 ldx face0,y
 jsr clip_right_outside_x
 beq cfrx_v1
 jsr clip_v0_right
cfrx_v1:
 ldy sortj
 ldx face1,y
 jsr clip_right_outside_x
 beq cfrx_v2
 jsr clip_v1_right
cfrx_v2:
 ldy sortj
 ldx face2,y
 jsr clip_right_outside_x
 beq cfrx_v3
 jsr clip_v2_right
cfrx_v3:
 ldy sortj
 ldx face3,y
 jsr clip_right_outside_x
 beq cfrx_done
 jsr clip_v3_right
cfrx_done:
 rts

clfr_one0:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 ldy sortj
 ldx face3,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face0,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy0
 sta clip2_vy0
 lda #PROJ_SCREEN_MAX_X
 sta vx0
 sta clip2_vx0
 ldy sortj
 ldx face1,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face0,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx1
 ldy sortj
 ldx face1,y
 lda sx,x
 sta vx2
 lda sy,x
 sta vy2
 ldy sortj
 ldx face2,y
 lda sx,x
 sta vx3
 sta clip2_vx1
 lda sy,x
 sta vy3
 sta clip2_vy1
 ldy sortj
 ldx face3,y
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfr_one1:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
 ldx face0,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face1,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx1
 ldy sortj
 ldx face2,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face1,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy2
 lda #PROJ_SCREEN_MAX_X
 sta vx2
 ldy sortj
 ldx face2,y
 lda sx,x
 sta vx3
 sta clip2_vx1
 lda sy,x
 sta vy3
 sta clip2_vy1
 ldy sortj
 ldx face3,y
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfr_one2:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
 ldx face1,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face2,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy2
 lda #PROJ_SCREEN_MAX_X
 sta vx2
 ldy sortj
 ldx face3,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face2,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy3
 sta clip2_vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx3
 sta clip2_vx1
 ldy sortj
 ldx face3,y
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfr_one3:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
 ldx face2,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face3,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy3
 sta clip2_vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx3
 sta clip2_vx1
 ldy sortj
 ldx face0,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face3,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta clip2_vy2
 lda #PROJ_SCREEN_MAX_X
 sta clip2_vx2
 rts

clip_face_left_x_simple:
 lda #$00
 sta maskv
 ldy sortj
 ldx face0,y
 jsr clip_left_outside_x
 beq cflx_mask_v1
 lda maskv
 ora #$01
 sta maskv
cflx_mask_v1:
 ldy sortj
 ldx face1,y
 jsr clip_left_outside_x
 beq cflx_mask_v2
 lda maskv
 ora #$02
 sta maskv
cflx_mask_v2:
 ldy sortj
 ldx face2,y
 jsr clip_left_outside_x
 beq cflx_mask_v3
 lda maskv
 ora #$04
 sta maskv
cflx_mask_v3:
 ldy sortj
 ldx face3,y
 jsr clip_left_outside_x
 beq cflx_mask_eval
 lda maskv
 ora #$08
 sta maskv
cflx_mask_eval:
 lda maskv
 cmp #$01
 beq clfl_one0
 cmp #$02
 beq clfl_one1
 cmp #$04
 beq clfl_one2
 cmp #$08
 beq clfl_one3
 ldy sortj
 ldx face0,y
 jsr clip_left_outside_x
 beq cflx_v1
 jsr clip_v0_left
cflx_v1:
 ldy sortj
 ldx face1,y
 jsr clip_left_outside_x
 beq cflx_v2
 jsr clip_v1_left
cflx_v2:
 ldy sortj
 ldx face2,y
 jsr clip_left_outside_x
 beq cflx_v3
 jsr clip_v2_left
cflx_v3:
 ldy sortj
 ldx face3,y
 jsr clip_left_outside_x
 beq cflx_done
 jsr clip_v3_left
cflx_done:
 rts

clfl_one0:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 ldy sortj
 ldx face3,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face0,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy0
 sta clip2_vy0
 lda #$00
 sta vx0
 sta clip2_vx0
 ldy sortj
 ldx face1,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face0,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy1
 lda #$00
 sta vx1
 ldy sortj
 ldx face1,y
 lda sx,x
 sta vx2
 lda sy,x
 sta vy2
 ldy sortj
 ldx face2,y
 lda sx,x
 sta vx3
 sta clip2_vx1
 lda sy,x
 sta vy3
 sta clip2_vy1
 ldy sortj
 ldx face3,y
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfl_one1:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
 ldx face0,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face1,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy1
 lda #$00
 sta vx1
 ldy sortj
 ldx face2,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face1,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy2
 lda #$00
 sta vx2
 ldy sortj
 ldx face2,y
 lda sx,x
 sta vx3
 sta clip2_vx1
 lda sy,x
 sta vy3
 sta clip2_vy1
 ldy sortj
 ldx face3,y
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfl_one2:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
 ldx face1,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face2,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy2
 lda #$00
 sta vx2
 ldy sortj
 ldx face3,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face2,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy3
 sta clip2_vy1
 lda #$00
 sta vx3
 sta clip2_vx1
 ldy sortj
 ldx face3,y
 lda sx,x
 sta clip2_vx2
 lda sy,x
 sta clip2_vy2
 rts

clfl_one3:
 lda #$01
 sta clip_second_pending
 lda #$03
 sta clip_second_count
 lda #$04
 sta loaded_face_vertex_count
 lda vx0
 sta clip2_vx0
 lda vy0
 sta clip2_vy0
 ldy sortj
 ldx face2,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face3,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy3
 sta clip2_vy1
 lda #$00
 sta vx3
 sta clip2_vx1
 ldy sortj
 ldx face0,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face3,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta clip2_vy2
 lda #$00
 sta clip2_vx2
 rts

clip_v0_right:
 ldy sortj
 ldx face3,y
 jsr clip_x_inside
 bne cv0r_prev
 ldy sortj
 ldx face1,y
 jsr clip_x_inside
 bne cv0r_next
 lda #PROJ_SCREEN_MAX_X
 sta vx0
 rts
cv0r_prev:
 ldy sortj
 ldx face3,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face0,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy0
 lda #PROJ_SCREEN_MAX_X
 sta vx0
 rts
cv0r_next:
 ldy sortj
 ldx face1,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face0,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy0
 lda #PROJ_SCREEN_MAX_X
 sta vx0
 rts

clip_v1_right:
 ldy sortj
 ldx face0,y
 jsr clip_x_inside
 bne cv1r_prev
 ldy sortj
 ldx face2,y
 jsr clip_x_inside
 bne cv1r_next
 lda #PROJ_SCREEN_MAX_X
 sta vx1
 rts
cv1r_prev:
 ldy sortj
 ldx face0,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face1,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx1
 rts
cv1r_next:
 ldy sortj
 ldx face2,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face1,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy1
 lda #PROJ_SCREEN_MAX_X
 sta vx1
 rts

clip_v2_right:
 ldy sortj
 ldx face1,y
 jsr clip_x_inside
 bne cv2r_prev
 ldy sortj
 ldx face3,y
 jsr clip_x_inside
 bne cv2r_next
 lda #PROJ_SCREEN_MAX_X
 sta vx2
 rts
cv2r_prev:
 ldy sortj
 ldx face1,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face2,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy2
 lda #PROJ_SCREEN_MAX_X
 sta vx2
 rts
cv2r_next:
 ldy sortj
 ldx face3,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face2,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy2
 lda #PROJ_SCREEN_MAX_X
 sta vx2
 rts

clip_v3_right:
 ldy sortj
 ldx face2,y
 jsr clip_x_inside
 bne cv3r_prev
 ldy sortj
 ldx face0,y
 jsr clip_x_inside
 bne cv3r_next
 lda #PROJ_SCREEN_MAX_X
 sta vx3
 rts
cv3r_prev:
 ldy sortj
 ldx face2,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face3,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy3
 lda #PROJ_SCREEN_MAX_X
 sta vx3
 rts
cv3r_next:
 ldy sortj
 ldx face0,y
 jsr clip_load_inside_right
 ldy sortj
 ldx face3,y
 jsr clip_load_outside_right
 jsr clip_interp_y
 sta vy3
 lda #PROJ_SCREEN_MAX_X
 sta vx3
 rts

clip_v0_left:
 ldy sortj
 ldx face3,y
 jsr clip_x_inside
 bne cv0l_prev
 ldy sortj
 ldx face1,y
 jsr clip_x_inside
 bne cv0l_next
 lda #$00
 sta vx0
 rts
cv0l_prev:
 ldy sortj
 ldx face3,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face0,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy0
 lda #$00
 sta vx0
 rts
cv0l_next:
 ldy sortj
 ldx face1,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face0,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy0
 lda #$00
 sta vx0
 rts

clip_v1_left:
 ldy sortj
 ldx face0,y
 jsr clip_x_inside
 bne cv1l_prev
 ldy sortj
 ldx face2,y
 jsr clip_x_inside
 bne cv1l_next
 lda #$00
 sta vx1
 rts
cv1l_prev:
 ldy sortj
 ldx face0,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face1,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy1
 lda #$00
 sta vx1
 rts
cv1l_next:
 ldy sortj
 ldx face2,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face1,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy1
 lda #$00
 sta vx1
 rts

clip_v2_left:
 ldy sortj
 ldx face1,y
 jsr clip_x_inside
 bne cv2l_prev
 ldy sortj
 ldx face3,y
 jsr clip_x_inside
 bne cv2l_next
 lda #$00
 sta vx2
 rts
cv2l_prev:
 ldy sortj
 ldx face1,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face2,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy2
 lda #$00
 sta vx2
 rts
cv2l_next:
 ldy sortj
 ldx face3,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face2,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy2
 lda #$00
 sta vx2
 rts

clip_v3_left:
 ldy sortj
 ldx face2,y
 jsr clip_x_inside
 bne cv3l_prev
 ldy sortj
 ldx face0,y
 jsr clip_x_inside
 bne cv3l_next
 lda #$00
 sta vx3
 rts
cv3l_prev:
 ldy sortj
 ldx face2,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face3,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy3
 lda #$00
 sta vx3
 rts
cv3l_next:
 ldy sortj
 ldx face0,y
 jsr clip_load_inside_left
 ldy sortj
 ldx face3,y
 jsr clip_load_outside_left
 jsr clip_interp_y
 sta vy3
 lda #$00
 sta vx3
 rts

clip_x_inside:
 jsr clip_right_outside_x
 bne cxi_no
 jsr clip_left_outside_x
 bne cxi_no
 lda #$01
 rts
cxi_no:
 lda #$00
 rts

clip_right_outside_x:
 lda pxrawhi,x
 bmi crox_no
 bne crox_yes
 lda pxrawlo,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs crox_yes
crox_no:
 lda #$00
 rts
crox_yes:
 lda #$01
 rts

clip_left_outside_x:
 lda pxrawhi,x
 bmi clox_yes
 lda #$00
 rts
clox_yes:
 lda #$01
 rts

clip_load_inside_right:
 lda pxrawlo,x
 sta clip_in_x
 lda sy,x
 sta clip_in_y
 lda #PROJ_SCREEN_MAX_X
 sec
 sbc clip_in_x
 sta clip_num
 rts

clip_load_outside_right:
 lda sy,x
 sta clip_out_y
 lda pxrawlo,x
 sec
 sbc clip_in_x
 sta clip_den
 lda pxrawhi,x
 sbc #$00
 beq clor_check_zero
 lda #$ff
 sta clip_den
 rts
clor_check_zero:
 lda clip_den
 bne clor_done
 lda #$01
 sta clip_den
clor_done:
 rts

clip_load_inside_left:
 lda pxrawlo,x
 sta clip_in_x
 sta clip_num
 lda sy,x
 sta clip_in_y
 rts

clip_load_outside_left:
 lda sy,x
 sta clip_out_y
 lda #$00
 sec
 sbc pxrawlo,x
 clc
 adc clip_in_x
 bcc clol_store
 lda #$ff
clol_store:
 bne clol_nonzero
 lda #$01
clol_nonzero:
 sta clip_den
 rts

clip_interp_y:
 sec
 lda clip_out_y
 sbc clip_in_y
 sta dy1v
 bpl ciy_positive
 eor #$ff
 clc
 adc #$01
 ldx clip_num
 jsr clip_mul_u8
 lda clip_den
 bne ciy_neg_den_ready
 lda #$01
ciy_neg_den_ready:
 sta p1lo
 lda #$00
 sta p1hi
 jsr div16u
 lda clip_in_y
 sec
 sbc prodlo
 bcs ciy_done
 lda #$00
 rts
ciy_positive:
 lda dy1v
 ldx clip_num
 jsr clip_mul_u8
 lda clip_den
 bne ciy_pos_den_ready
 lda #$01
ciy_pos_den_ready:
 sta p1lo
 lda #$00
 sta p1hi
 jsr div16u
 clc
 lda clip_in_y
 adc prodlo
 bcs ciy_max
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcc ciy_done
ciy_max:
 lda #PROJ_SCREEN_MAX_Y
ciy_done:
 rts

clip_mul_u8:
 sta mul16lo
 lda #$00
 sta mul16hi
 stx mul16mul
 lda #$00
 sta prodlo
 sta prodhi
 ldx #$08
cmu8_loop:
 lsr mul16mul
 bcc cmu8_no_add
 clc
 lda prodlo
 adc mul16lo
 sta prodlo
 lda prodhi
 adc mul16hi
 sta prodhi
cmu8_no_add:
 asl mul16lo
 rol mul16hi
 dex
 bne cmu8_loop
 rts
.endif


.if CAMERA_MOVABLE != 0
.if EXPLORER_NEAR_CLIP != 0
explorer_face_near_projected:
 ldy faceidx
.if EXPLORER_NEAR_SKIP_CROSS != 0 || EXPLORER_NEAR_POLY != 0
 lda #$00
 sta near_face_crossing
 sta maskv
 ldx face0,y
 lda projdone,x
 beq efap_skip_v0
 inc maskv
efap_skip_v0:
 ldx face1,y
 lda projdone,x
 beq efap_skip_v1
 inc maskv
efap_skip_v1:
 ldx face2,y
 lda projdone,x
 beq efap_skip_v2
 inc maskv
efap_skip_v2:
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 cmp #$04
 bne efap_tri_count
.endif
 ldx face3,y
 lda projdone,x
 beq efap_skip_v3
 inc maskv
efap_skip_v3:
 lda maskv
 beq efap_no
 cmp #$04
 beq efap_quad_all_valid
.if EXPLORER_NEAR_POLY != 0
 lda #$01
 sta near_face_crossing
 jmp efap_yes
.else
 jmp efap_no
.endif
efap_quad_all_valid:
.if EXPLORER_NEAR_SKIP_CROSS != 0
 jsr explorer_face_near_skip_guard
 beq efap_no
.endif
 jmp efap_yes
efap_tri_count:
 lda maskv
 beq efap_no
 cmp #$03
 beq efap_tri_all_valid
.if EXPLORER_NEAR_POLY != 0
 lda #$01
 sta near_face_crossing
 jmp efap_yes
.else
 jmp efap_no
.endif
efap_tri_all_valid:
.if EXPLORER_NEAR_SKIP_CROSS != 0
 jsr explorer_face_near_skip_guard
 beq efap_no
.endif
 jmp efap_yes
.else
 lda #$00
 sta near_face_crossing
 ldx face0,y
 lda projdone,x
 bne efap_yes
 ldx face1,y
 lda projdone,x
 bne efap_yes
 ldx face2,y
 lda projdone,x
 bne efap_yes
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 cmp #$04
 bne efap_no
.endif
 ldx face3,y
 lda projdone,x
 bne efap_yes
.endif
efap_no:
 lda #$00
 rts
efap_yes:
 lda #$01
 rts
.if EXPLORER_NEAR_SKIP_CROSS != 0
explorer_face_near_skip_guard:
 ldy faceidx
 ldx face0,y
 jsr explorer_vertex_near_skip_safe
 beq efns_no
 ldy faceidx
 ldx face1,y
 jsr explorer_vertex_near_skip_safe
 beq efns_no
 ldy faceidx
 ldx face2,y
 jsr explorer_vertex_near_skip_safe
 beq efns_no
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne efns_yes
.endif
 ldy faceidx
 ldx face3,y
 jsr explorer_vertex_near_skip_safe
 beq efns_no
efns_yes:
 lda #$01
 rts
efns_no:
 lda #$00
 rts

explorer_vertex_near_skip_safe:
 lda szhi,x
 bmi evnss_no
 bne evnss_yes
 lda sz,x
 cmp #EXPLORER_NEAR_SKIP_DEPTH
 bcc evnss_no
evnss_yes:
 lda #$01
 rts
evnss_no:
 lda #$00
 rts
.endif
.endif
.endif


.if CAMERA_PLANE_CLIP_PROFILE != 0
; Depth zero belongs to the visible side. Reject only faces whose original
; vertices are all strictly negative. Zero and mixed-sign faces take the
; camera-plane path so zero-depth originals can be projected at depth 1.
camera_plane_face_classify:
 lda #$00
 sta near_face_crossing
 sta maskv
 ldy faceidx
 ldx face0,y
 jsr camera_plane_classify_vertex
cpfc_v1:
 ldy faceidx
 ldx face1,y
 jsr camera_plane_classify_vertex
cpfc_v2:
 ldy faceidx
 ldx face2,y
 jsr camera_plane_classify_vertex
cpfc_count:
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne cpfc_ready
.endif
 ldy faceidx
 ldx face3,y
 jsr camera_plane_classify_vertex
cpfc_ready:
 lda maskv
 and #$01
 beq cpfc_hidden
 lda maskv
 and #$06
 beq cpfc_visible
 lda #$01
 sta near_face_crossing
cpfc_visible:
 lda #$01
 rts
cpfc_hidden:
 lda #$00
 rts
.endif

.if POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0
load_face_visible:
.if CAMERA_PLANE_CLIP_PROFILE != 0
 jsr camera_plane_face_classify
 beq lfv_hidden
 lda near_face_crossing
 beq lfv_camera_plane_facing_done
 jsr camera_plane_original_facing
 bcs lfv_camera_plane_facing_done
 ; A zero-depth boundary with no strictly negative original vertex is the
 ; coplanar/touching case. Keep it visible even if Q6 normal quantization
 ; leaves a one-unit positive dot residue.
 lda maskv
 and #$02
 bne lfv_hidden
lfv_camera_plane_facing_done:
.endif
.if MODE3_LATE_NEAR_NO_POLY != 0
 lda #$00
 sta near_face_crossing
 ldy faceidx
 ldx face0,y
.if CAMERA_MOVABLE != 0
 lda projdone,x
.else
 jsr vertex_depth_safe
.endif
 beq lfv_hidden
 ldy faceidx
 ldx face1,y
.if CAMERA_MOVABLE != 0
 lda projdone,x
.else
 jsr vertex_depth_safe
.endif
 beq lfv_hidden
 ldy faceidx
 ldx face2,y
.if CAMERA_MOVABLE != 0
 lda projdone,x
.else
 jsr vertex_depth_safe
.endif
 beq lfv_hidden
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne lfv_mode3_late_near_valid
.endif
 ldy faceidx
 ldx face3,y
.if CAMERA_MOVABLE != 0
 lda projdone,x
.else
 jsr vertex_depth_safe
.endif
 beq lfv_hidden
lfv_mode3_late_near_valid:
.endif
.if CAMERA_MOVABLE != 0
.if CAMERA_PLANE_CLIP_PROFILE = 0
.if EXPLORER_NEAR_CLIP != 0
 jsr explorer_face_near_projected
 beq lfv_hidden
.else
 ldy faceidx
 ldx face0,y
 lda projdone,x
 beq lfv_hidden
 ldx face1,y
 lda projdone,x
 beq lfv_hidden
 ldx face2,y
 lda projdone,x
 beq lfv_hidden
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 cmp #$04
 bne lfv_explorer_valid
.endif
 ldx face3,y
 lda projdone,x
 beq lfv_hidden
lfv_explorer_valid:
.endif
.endif
.if WORLD_GROUND_OCCLUDE != 0
 jsr ground_face_visible
 beq lfv_hidden
.endif
.endif
.if WORLD_GROUND_PLANE_CLIP != 0 && CAMERA_MOVABLE = 0
 jsr ground_face_visible
 beq lfv_hidden
.endif
.if FACE_CULL_PREP != 0
 ldy faceidx
 lda face0,y
 tax
 lda rxbuf,x
 sta vx0
 lda rybuf,x
 eor #$ff
 clc
 adc #$01
 sta vy0
 lda face1,y
 tax
 lda rxbuf,x
 sta vx1
 lda rybuf,x
 eor #$ff
 clc
 adc #$01
 sta vy1
 lda face2,y
 tax
 lda rxbuf,x
 sta vx2
 lda rybuf,x
 eor #$ff
 clc
 adc #$01
 sta vy2
lfv_cull:
.if FORCE_FACE_RENDER = 0
.if CAMERA_PLANE_CLIP_PROFILE != 0
 lda near_face_crossing
 bne lfv_visible
.endif
.if EXPLORER_NEAR_POLY != 0
 lda near_face_crossing
 bne lfv_visible
.endif
 jsr face_visible
 bcc lfv_hidden
.endif
.endif
lfv_visible:
.if SCENE_OBJECT_COUNT != 0
.if CAMERA_PLANE_CLIP_PROFILE = 0
.if EXPLORER_NEAR_POLY != 0
 lda near_face_crossing
 bne lfv_depth_ok
.endif
 jsr face_depth_safe
 beq lfv_hidden
lfv_depth_ok:
.endif
.endif
.if DYNAMIC_LIGHT != 0
.if SCENE_OBJECT_COUNT != 0
 ldy faceidx
 jsr update_face_shade
.else
 lda shade_dirty
 beq lfv_shade_done
 ldy faceidx
 jsr update_face_shade
.endif
lfv_shade_done:
.endif
.if STANDARD_PROJECT_VERTEX != 0
 ldy faceidx
 ldx face0,y
 jsr project_vertex
 ldy faceidx
 ldx face1,y
 jsr project_vertex
 ldy faceidx
 ldx face2,y
 jsr project_vertex
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne lfv_bucket
.endif
 ldy faceidx
 ldx face3,y
 jsr project_vertex
lfv_bucket:
.else
lfv_bucket:
.endif
.if SCENE_OBJECT_COUNT != 0
 ldy faceidx
 sty sortj
 jsr load_face_y
 bcc lfv_hidden
.if MODE2_FACE_BUCKET_PIPELINE != 0
 jsr mode2_screen_winding_visible
 bcc lfv_hidden
.endif
.if CONSERVATIVE_SLIVER_CULL != 0
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 bne lfv_skip_sliver
.endif
 jsr face_far_depth
 bne lfv_skip_sliver
 jsr face_conservative_sliver
 beq lfv_hidden
lfv_skip_sliver:
.endif
.endif
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
 jsr engine_mode3_cache_loaded_face_prepare
.endif
 jmp bucket_visible_face
lfv_hidden:
 clc
 rts

.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
; Cache only faces whose projected vertices are already fully inside the viewport.
; Near/screen-clipped faces remain on load_face_y, preserving the complete fallback.
engine_mode3_cache_loaded_face_prepare:
.if EXPLORER_NEAR_POLY != 0
 lda near_face_crossing
 bne sm3cfp_done
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 bne sm3cfp_done
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
 lda clip_second_pending
 bne sm3cfp_done
.endif
 ; Test the original projected vertices, not the possibly clipped vx/vy copy.
 ; This guarantees that the draw-pass fastload can safely reload sx/sy directly.
 ldy faceidx
 ldx face0,y
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs sm3cfp_done
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs sm3cfp_done
 ldy faceidx
 ldx face1,y
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs sm3cfp_done
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs sm3cfp_done
 ldy faceidx
 ldx face2,y
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs sm3cfp_done
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs sm3cfp_done
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne sm3cfp_store
.endif
 ldy faceidx
 ldx face3,y
 lda sx,x
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs sm3cfp_done
 lda sy,x
 cmp #(PROJ_SCREEN_MAX_Y + 1)
 bcs sm3cfp_done
sm3cfp_store:
 ldy faceidx
 lda #$01
 sta frame_face_prepare,y
 lda spanw
 sta frame_face_spanw,y
 lda spanh
 sta frame_face_spanh,y
sm3cfp_done:
 rts
.endif
.endif

.if SCENE_OBJECT_COUNT != 0
.if FACE_RENDER_ENABLE != 0
face_far_depth:
 ldy sortj
 ldx face0,y
 lda szhi,x
 beq ffd_no
 bmi ffd_no
 ldx face1,y
 lda szhi,x
 beq ffd_no
 bmi ffd_no
 ldx face2,y
 lda szhi,x
 beq ffd_no
 bmi ffd_no
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 cmp #$04
 bne ffd_yes
.endif
 ldx face3,y
 lda szhi,x
 beq ffd_no
 bmi ffd_no
ffd_yes:
 lda #$01
 rts
ffd_no:
 lda #$00
 rts

.if CONSERVATIVE_SLIVER_CULL != 0
face_conservative_sliver:
 lda spanh
 cmp #(CONSERVATIVE_SLIVER_THIN_SPAN + 1)
 bcs fcs_check_vertical
 lda spanw
 cmp #CONSERVATIVE_SLIVER_LONG_SPAN
 bcs fcs_yes
 lda #$00
 rts
fcs_check_vertical:
 lda spanw
 cmp #(CONSERVATIVE_SLIVER_THIN_SPAN + 1)
 bcs fcs_yes
 lda spanh
 cmp #CONSERVATIVE_SLIVER_LONG_SPAN
 bcs fcs_yes
 lda #$00
 rts
fcs_yes:
 lda #$01
 rts

.endif
.endif

face_depth_safe:
 ldy faceidx
 ldx face0,y
 jsr vertex_depth_safe
 beq fds_no
 ldy faceidx
 ldx face1,y
 jsr vertex_depth_safe
 beq fds_no
 ldy faceidx
 ldx face2,y
 jsr vertex_depth_safe
 beq fds_no
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne fds_yes
.endif
 ldy faceidx
 ldx face3,y
 jsr vertex_depth_safe
 beq fds_no
fds_yes:
 lda #$01
 rts
fds_no:
 lda #$00
 rts

vertex_depth_safe:
 lda szhi,x
 bmi vds_no
 bne vds_yes
 lda sz,x
 cmp #CAMERA_FACE_MIN_DEPTH
 bcc vds_no
vds_yes:
 lda #$01
 rts
vds_no:
 lda #$00
 rts

.if WIRE_RENDER_ENABLE != 0
wire_vertex_drawable:
.if CAMERA_MOVABLE != 0
 lda projdone,x
 beq wvd_no
.endif
 jsr vertex_depth_safe
 beq wvd_no
 lda #$01
 rts
wvd_no:
 lda #$00
 rts

.if EXPLORER_SCREEN_CLIP_POLY != 0 && EXPLORER_SCREEN_RAW != 0
clip_wire_edge_screen:
 ldx clip_prev_idx
 lda pxrawlo,x
 sta clip_a_xlo
 lda pxrawhi,x
 sta clip_a_xhi
 lda pyrawlo,x
 sta clip_a_ylo
 lda pyrawhi,x
 sta clip_a_yhi
 lda sx,x
 sta clip_a_x
 lda sy,x
 sta clip_a_y
.if WIRE_RENDER_ENABLE != 0
 lda #$00
 sta clip_a_flag
.endif
 ldx clip_cur_idx
 lda pxrawlo,x
 sta clip_a_xlo + 1
 lda pxrawhi,x
 sta clip_a_xhi + 1
 lda pyrawlo,x
 sta clip_a_ylo + 1
 lda pyrawhi,x
 sta clip_a_yhi + 1
 lda sx,x
 sta clip_a_x + 1
 lda sy,x
 sta clip_a_y + 1
.if WIRE_RENDER_ENABLE != 0
 lda #$00
 sta clip_a_flag + 1
.endif
 lda #$02
 sta clip_a_count
 jsr clip_poly_clip_screen_current
 lda clip_a_count
 cmp #$02
 bcc cwes_no
 lda clip_a_x
 sta ex0
 lda clip_a_y
 sta ey0
 lda clip_a_x + 1
 sta ex1
 lda clip_a_y + 1
 sta ey1
 lda #$01
 rts
cwes_no:
 lda #$00
 rts
.endif
.endif

.endif
.if FORCE_FACE_RENDER = 0
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && (POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || HIDDEN_WIRE_ENABLE != 0 || LOWRES_TRACE_ENABLE != 0) && (POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || HIDDEN_WIRE_ENABLE != 0 || WIRE_RENDER_ENABLE = 0 || WIRE_MESH_COUNT = 0) && (POLY_FILL_ENABLE = 0 || WIRE_DEPTH_SORT_ENABLE = 0)
.if * > $5c00
 .error "High-basic-v2 middle segment overlaps video buffer A"
.endif
.if MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0
mode3_high_basic_middle_end = *
* = HIGH_BASIC_V2_RELOCATED_CODE_BASE
mode3_high_basic_relocated_code_start = *
.else
.if GRAPHICS_MODE = $02 && CAMERA_MOVABLE != 0
 ; Retain the validated Mode 2 middle-segment endpoint after the depth split.
 .fill 7, $ea
.endif
* = $a000
.endif
.endif
.if VIC_COLOR_POLICY_OVERLAY != 0
vic_color_policy_overlay_conflicts:
 lda drawbuf
 bne vcpo_buffer_b
 ldx #$00
vcpo_a_pages:
 lda vic_color_conflict_map,x
 beq vcpo_a_100
 lda #$ff
 sta $5c00,x
 lda #$0a
 sta $d800,x
vcpo_a_100:
 lda vic_color_conflict_map+$0100,x
 beq vcpo_a_200
 lda #$ff
 sta $5d00,x
 lda #$0a
 sta $d900,x
vcpo_a_200:
 lda vic_color_conflict_map+$0200,x
 beq vcpo_a_next
 lda #$ff
 sta $5e00,x
 lda #$0a
 sta $da00,x
vcpo_a_next:
 inx
 bne vcpo_a_pages
 ldx #$00
vcpo_a_tail:
 lda vic_color_conflict_map+$0300,x
 beq vcpo_a_tail_next
 lda #$ff
 sta $5f00,x
 lda #$0a
 sta $db00,x
vcpo_a_tail_next:
 inx
 cpx #$e8
 bne vcpo_a_tail
 rts
vcpo_buffer_b:
 ldx #$00
vcpo_b_pages:
 lda vic_color_conflict_map,x
 beq vcpo_b_100
 lda #$ff
 sta SCREEN_B_BASE,x
 lda #$0a
 sta $d800,x
vcpo_b_100:
 lda vic_color_conflict_map+$0100,x
 beq vcpo_b_200
 lda #$ff
 sta SCREEN_B_BASE+$0100,x
 lda #$0a
 sta $d900,x
vcpo_b_200:
 lda vic_color_conflict_map+$0200,x
 beq vcpo_b_next
 lda #$ff
 sta SCREEN_B_BASE+$0200,x
 lda #$0a
 sta $da00,x
vcpo_b_next:
 inx
 bne vcpo_b_pages
 ldx #$00
vcpo_b_tail:
 lda vic_color_conflict_map+$0300,x
 beq vcpo_b_tail_next
 lda #$ff
 sta SCREEN_B_BASE+$0300,x
 lda #$0a
 sta $db00,x
vcpo_b_tail_next:
 inx
 cpx #$e8
 bne vcpo_b_tail
 rts
.endif
.if WIRE_TWO_COLOR_MULTIMATERIAL_ENABLE != 0
activate_wire_two_color_palette:
 lda #WIRE_TWO_COLOR_SCREEN_BYTE
 sta material_screen_cur
 lda #WIRE_TWO_COLOR_FIXED_COLOR_RAM
 sta material_color_cur
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 rts
.endif

.if WIRE_TWO_COLOR_MODE1_ENABLE != 0
load_wire_two_color_edge_pattern_y:
 lda wire_edge_slot,y
 cmp #$02
 beq lwtcep_slot10
 lda #$55
 sta fillbyte
 rts
lwtcep_slot10:
 lda #$aa
 sta fillbyte
 rts
.endif

.if WIRE_TWO_COLOR_MODE2_ENABLE != 0
load_wire_two_color_face_pattern_y:
 lda wire_face_slot,y
 cmp #$02
 beq lwtcfp_slot10
 lda #$55
 sta fillbyte
 rts
lwtcfp_slot10:
 lda #$aa
 sta fillbyte
 rts
.endif

.if WIRE_EDGE_SOLID_COLOR_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0
load_wire_edge_solid_color_x:
 lda wire_edge_solid_color,x
 sta material_color_cur
 lda #$00
 sta material_screen_cur
.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
 jsr engine_wire_invalidate_material_cell_cache
.endif
 lda #$ff
 sta fillbyte
 rts
.endif
.if LOWRES_TRACE_ENABLE != 0
clear_current_bitmap_lowres_trace:
 jsr copy_lowres_trace_rows_from_front
 lda drawbuf
 bne ccblt_b
ccblt_a:
 ldx #$00
ccblt_a_row:
 stx yrow
 jsr lowres_row_selected
 bne ccblt_a_next
 ldx yrow
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 jsr clear_logical_bitmap_row
ccblt_a_next:
 ldx yrow
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ccblt_a_row
 rts
ccblt_b:
 ldx #$00
ccblt_b_row:
 stx yrow
 jsr lowres_row_selected
 bne ccblt_b_next
 ldx yrow
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
 jsr clear_logical_bitmap_row
ccblt_b_next:
 ldx yrow
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne ccblt_b_row
 rts

clear_logical_bitmap_row:
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr0lo
 bcc clbr_origin0_ok
 inc ptr0hi
clbr_origin0_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr1lo
 bcc clbr_origin1_ok
 inc ptr1hi
clbr_origin1_ok:
.endif
 lda #CAMERA_VIEWPORT_CELL_WIDTH
 sta p1lo
clbr_loop:
 ldy #$00
 lda #$00
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc clbr_ptr0_ok
 inc ptr0hi
clbr_ptr0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc clbr_ptr1_ok
 inc ptr1hi
clbr_ptr1_ok:
 dec p1lo
 bne clbr_loop
 rts

copy_lowres_trace_rows_from_front:
 lda drawbuf
 bne cltr_b_dest
cltr_a_dest:
 ldx #$00
cltr_a_loop:
 stx yrow
 jsr lowres_row_selected
 beq cltr_a_next
 ldx yrow
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
 jsr copy_logical_bitmap_row
cltr_a_next:
 ldx yrow
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne cltr_a_loop
 rts
cltr_b_dest:
 ldx #$00
cltr_b_loop:
 stx yrow
 jsr lowres_row_selected
 beq cltr_b_next
 ldx yrow
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jsr copy_logical_bitmap_row
cltr_b_next:
 ldx yrow
 inx
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bne cltr_b_loop
 rts

copy_logical_bitmap_row:
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 clc
 lda row0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta row0lo
 bcc clbr_copy_src0_origin_ok
 inc row0hi
clbr_copy_src0_origin_ok:
 clc
 lda row1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta row1lo
 bcc clbr_copy_src1_origin_ok
 inc row1hi
clbr_copy_src1_origin_ok:
 clc
 lda ptr0lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr0lo
 bcc clbr_copy_dst0_origin_ok
 inc ptr0hi
clbr_copy_dst0_origin_ok:
 clc
 lda ptr1lo
 adc #CAMERA_VIEWPORT_BITMAP_X_OFFSET
 sta ptr1lo
 bcc clbr_copy_dst1_origin_ok
 inc ptr1hi
clbr_copy_dst1_origin_ok:
.endif
 lda #CAMERA_VIEWPORT_CELL_WIDTH
 sta p1lo
clbr_copy_loop:
 ldy #$00
 lda (row0lo),y
 sta (ptr0lo),y
 lda (row1lo),y
 sta (ptr1lo),y
 clc
 lda row0lo
 adc #$08
 sta row0lo
 bcc clbr_src0_ok
 inc row0hi
clbr_src0_ok:
 clc
 lda row1lo
 adc #$08
 sta row1lo
 bcc clbr_src1_ok
 inc row1hi
clbr_src1_ok:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc clbr_dst0_ok
 inc ptr0hi
clbr_dst0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc clbr_dst1_ok
 inc ptr1hi
clbr_dst1_ok:
 dec p1lo
 bne clbr_copy_loop
 rts
.endif
.if MODE2_FACE_BUCKET_PIPELINE = 0
.if CAMERA_SPACE_FACE_CULL_SUPPORT != 0
.if MEMORY_LAYOUT_HIGH_BASIC_V2 = 0
camera_plane_cull_low_return = *
* = $9500
camera_plane_cull_code_start = *
.endif
.endif
.if CAMERA_PLANE_CLIP_PROFILE != 0

; maskv: bit 0 = at least one depth >= 0, bit 1 = at least one depth < 0,
; bit 2 = at least one depth = 0.
camera_plane_classify_vertex:
 lda vzrawhi,x
 bmi cpcv_negative
 bne cpcv_positive
 lda vzrawlo,x
 beq cpcv_zero
cpcv_positive:
 lda maskv
 ora #$01
 sta maskv
 rts
cpcv_zero:
 lda maskv
 ora #$05
 sta maskv
 rts
cpcv_negative:
 lda maskv
 ora #$02
 sta maskv
 rts

camera_plane_original_on_plane:
 lda vzrawhi,x
 bne cpoop_no
 lda vzrawlo,x
 bne cpoop_no
 lda #$01
 rts
cpoop_no:
 lda #$00
 rts

; A source vertex exactly on the camera plane is retained, but its effective
; projection depth is 1 WU. X still contains the original vertex index.
camera_plane_append_original_zero:
 stx clip_out_x
 ldy clip_a_count
 lda vxrawlo,x
 sta clip_a_vxlo,y
 lda vxrawhi,x
 sta clip_a_vxhi,y
 lda vyrawlo,x
 sta clip_a_vylo,y
 lda vyrawhi,x
 sta clip_a_vyhi,y
 lda #$01
 sta clip_a_vzlo,y
 lda #$00
 sta clip_a_vzhi,y
 lda clip_a_count
 sta camera_plane_bucket_ready
 jsr camera_plane_project_original_intersection
.if WIRE_RENDER_ENABLE != 0
 ldy clip_a_count
 lda #$00
 sta clip_a_flag,y
.endif
 inc clip_a_count
 rts
.endif

; The build derives this oriented normal from the first non-collinear
; original face triplet. Rotate it into camera space, then dot it with an
; original camera-space vertex. The sign is calibrated against the ordinary
; screen-space winding at a safe positive depth: negative is the visible side.
; Stable culling reuses the Mode 4/5 shading normal and keeps a one-WU
; geometric edge band visible. There is no frame memory or hysteresis.
.if CAMERA_SPACE_FACE_CULL_SUPPORT != 0
.if STABLE_FACE_CULL_PROFILE != 0
; The folded object-to-camera matrix is captured once per rendered object.
; This keeps the original face normal and its camera-space point in the same
; coordinate system without adding per-face transformed-normal tables.
.if EXPLORER_MATRIX_FOLD != 0
stable_face_cull_cache_matrix:
 lda m00
 sta stable_face_cull_m00
 lda m01
 sta stable_face_cull_m01
 lda m02
 sta stable_face_cull_m02
 lda m10
 sta stable_face_cull_m10
 lda m11
 sta stable_face_cull_m11
 lda m12
 sta stable_face_cull_m12
 lda m20
 sta stable_face_cull_m20
 lda m21
 sta stable_face_cull_m21
 lda m22
 sta stable_face_cull_m22
 rts
.endif

; Non-folded explorer builds already have the object matrix in m00..m22 and
; the current camera sine/cosine values in sin?v/cos?v.  Fold the three
; matrix columns into the same cache without changing the object matrix or
; the coordinate-term tables used by vertex transformation.
.if CAMERA_MOVABLE != 0 && EXPLORER_MATRIX_FOLD = 0
stable_face_cull_prepare_movable_matrix:
 ldy #$02
sfcpmm_column:
 lda m00,y
 sta rx0
 lda m10,y
 sta ry0
 lda m20,y
 sta rz0

 ; Camera yaw.
 lda rx0
 ldx cosyv
 jsr mul_s6
 sta t1
 lda rz0
 ldx sinyv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta vx3
 lda rx0
 ldx sinyv
 jsr mul_s6
 sta t1
 lda rz0
 ldx cosyv
 jsr mul_s6
 clc
 adc t1
 sta rz0
 lda vx3
 sta rx0

 ; Camera pitch, with exactly the same compile/runtime gates as the vertex
 ; transformer.
.if ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH != 0
 lda explorer_cam_pitch
 beq sfcpmm_pitch_done
.endif
.if ENGINE_CAMERA_WALK_LITE_PITCH_RUNTIME_ACTIVE != 0
 lda explorer_cam_pitch
 beq sfcpmm_pitch_done
.else
.if CAMERA_WALK_LITE != 0
 jmp sfcpmm_pitch_done
.else
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 cmp #$02
 bne sfcpmm_pitch_done
.endif
.endif
.endif
 lda ry0
 ldx cosxv
 jsr mul_s6
 sta t1
 lda rz0
 ldx sinxv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta vy3
 lda ry0
 ldx sinxv
 jsr mul_s6
 sta t1
 lda rz0
 ldx cosxv
 jsr mul_s6
 clc
 adc t1
 sta rz0
 lda vy3
 sta ry0
sfcpmm_pitch_done:

.if CAMERA_ROLL_ACTIVE != 0
.if ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH != 0
 lda explorer_cam_roll
 beq sfcpmm_roll_done
.endif
.if CAMERA_MODE_CYCLE != 0
 lda explorer_runtime_mode
 cmp #$02
 bne sfcpmm_roll_done
.endif
 lda rx0
 ldx coszv
 jsr mul_s6
 sta t1
 lda ry0
 ldx sinzv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta vx3
 lda rx0
 ldx sinzv
 jsr mul_s6
 sta t1
 lda ry0
 ldx coszv
 jsr mul_s6
 clc
 adc t1
 sta ry0
 lda vx3
 sta rx0
sfcpmm_roll_done:
.endif

 lda rx0
 sta stable_face_cull_m00,y
 lda ry0
 sta stable_face_cull_m10,y
 lda rz0
 sta stable_face_cull_m20,y
 dey
 bmi sfcpmm_done
 jmp sfcpmm_column
sfcpmm_done:
 rts
.endif

.if CAMERA_MOVABLE != 0
stable_face_cull_m00: .byte 0
stable_face_cull_m01: .byte 0
stable_face_cull_m02: .byte 0
stable_face_cull_m10: .byte 0
stable_face_cull_m11: .byte 0
stable_face_cull_m12: .byte 0
stable_face_cull_m20: .byte 0
stable_face_cull_m21: .byte 0
stable_face_cull_m22: .byte 0
.endif
.endif

camera_plane_original_facing:
.if STABLE_FACE_CULL_PROFILE != 0 && MODE4_OBJECT_LIGHT_CACHE != 0
 ; sh_nx/y/z hold the object-space light vector cached for Mode 4/5 shading.
 ; Stable facing temporarily reuses them for the camera-space face normal,
 ; so preserve the light cache across every original-face test.
 lda sh_nx
 pha
 lda sh_ny
 pha
 lda sh_nz
 pha
.endif
 ldy faceidx
 sty tmpidx
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda face_normal_x,y
.else
 lda camera_plane_cull_normal_x,y
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
 ldx stable_face_cull_m00
.else
 ldx m00
.endif
 jsr mul_s6
 sta sh_nx
 ldy tmpidx
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda face_normal_y,y
.else
 lda camera_plane_cull_normal_y,y
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
 ldx stable_face_cull_m01
.else
 ldx m01
.endif
 jsr mul_s6
 clc
 adc sh_nx
 sta sh_nx
 ldy tmpidx
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda face_normal_z,y
.else
 lda camera_plane_cull_normal_z,y
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
 ldx stable_face_cull_m02
.else
 ldx m02
.endif
 jsr mul_s6
 clc
 adc sh_nx
 sta sh_nx

 ldy tmpidx
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda face_normal_x,y
.else
 lda camera_plane_cull_normal_x,y
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
 ldx stable_face_cull_m10
.else
 ldx m10
.endif
 jsr mul_s6
 sta sh_ny
 ldy tmpidx
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda face_normal_y,y
.else
 lda camera_plane_cull_normal_y,y
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
 ldx stable_face_cull_m11
.else
 ldx m11
.endif
 jsr mul_s6
 clc
 adc sh_ny
 sta sh_ny
 ldy tmpidx
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda face_normal_z,y
.else
 lda camera_plane_cull_normal_z,y
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
 ldx stable_face_cull_m12
.else
 ldx m12
.endif
 jsr mul_s6
 clc
 adc sh_ny
 sta sh_ny

 ldy tmpidx
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda face_normal_x,y
.else
 lda camera_plane_cull_normal_x,y
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
 ldx stable_face_cull_m20
.else
 ldx m20
.endif
 jsr mul_s6
 sta sh_nz
 ldy tmpidx
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda face_normal_y,y
.else
 lda camera_plane_cull_normal_y,y
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
 ldx stable_face_cull_m21
.else
 ldx m21
.endif
 jsr mul_s6
 clc
 adc sh_nz
 sta sh_nz
 ldy tmpidx
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda face_normal_z,y
.else
 lda camera_plane_cull_normal_z,y
.endif
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE != 0
 ldx stable_face_cull_m22
.else
 ldx m22
.endif
 jsr mul_s6
 clc
 adc sh_nz
 sta sh_nz

.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_MOVABLE = 0 && CAMERA_HAS_ROT != 0
 ; Fixed-camera builds apply the compile-time camera matrix after the object
 ; matrix.  Keep the normal in exactly the same camera space as the vertex.
 lda sh_nx
 ldx #CAMERA_M00
 jsr mul_s6
 sta vx3
 lda sh_ny
 ldx #CAMERA_M01
 jsr mul_s6
 clc
 adc vx3
 sta vx3
 lda sh_nz
 ldx #CAMERA_M02
 jsr mul_s6
 clc
 adc vx3
 sta vx3

 lda sh_nx
 ldx #CAMERA_M10
 jsr mul_s6
 sta vy3
 lda sh_ny
 ldx #CAMERA_M11
 jsr mul_s6
 clc
 adc vy3
 sta vy3
 lda sh_nz
 ldx #CAMERA_M12
 jsr mul_s6
 clc
 adc vy3
 sta vy3

 lda sh_nx
 ldx #CAMERA_M20
 jsr mul_s6
 sta p1lo
 lda sh_ny
 ldx #CAMERA_M21
 jsr mul_s6
 clc
 adc p1lo
 sta p1lo
 lda sh_nz
 ldx #CAMERA_M22
 jsr mul_s6
 clc
 adc p1lo
 sta sh_nz
 lda vx3
 sta sh_nx
 lda vy3
 sta sh_ny
.endif

 ldy faceidx
 ldx face0,y
 lda #$00
 sta dotlo
 sta dothi
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda rxbuf,x
 ldx sh_nx
 jsr mul_s8_16
 jsr add_dot_product
.else
 lda vxrawlo,x
 sta p1lo
 lda vxrawhi,x
 sta p1hi
 lda sh_nx
 jsr camera_plane_mul_s16_s6
 jsr camera_plane_add_dot
.endif
 ldy faceidx
 ldx face0,y
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda rybuf,x
 ldx sh_ny
 jsr mul_s8_16
 jsr add_dot_product
.else
 lda vyrawlo,x
 sta p1lo
 lda vyrawhi,x
 sta p1hi
 lda sh_ny
 jsr camera_plane_mul_s16_s6
 jsr camera_plane_add_dot
.endif
 ldy faceidx
 ldx face0,y
.if STABLE_FACE_CULL_PROFILE != 0 && CAMERA_PLANE_CLIP_PROFILE = 0
 lda sz,x
 sta p1lo
 lda szhi,x
 sta p1hi
.else
 lda vzrawlo,x
 sta p1lo
 lda vzrawhi,x
 sta p1hi
.endif
 lda sh_nz
 jsr camera_plane_mul_s16_s6
 jsr camera_plane_add_dot
 lda dothi
 bmi cpof_visible
 bne cpof_hidden
 lda dotlo
.if STABLE_FACE_CULL_PROFILE != 0
 cmp #STABLE_FACE_CULL_EDGE_EPSILON + 1
 bcc cpof_visible
 bcs cpof_hidden
.else
 bne cpof_hidden
.endif
cpof_visible:
.if STABLE_FACE_CULL_PROFILE != 0 && MODE4_OBJECT_LIGHT_CACHE != 0
 ldx #$01
 bne cpof_restore_light_cache
.else
 sec
 rts
.endif
cpof_hidden:
.if STABLE_FACE_CULL_PROFILE != 0 && MODE4_OBJECT_LIGHT_CACHE != 0
 ldx #$00
cpof_restore_light_cache:
 pla
 sta sh_nz
 pla
 sta sh_ny
 pla
 sta sh_nx
 txa
 lsr
 rts
.else
 clc
 rts
.endif

camera_plane_add_dot:
 clc
 lda dotlo
 adc p1lo
 sta dotlo
 lda dothi
 adc p1hi
 sta dothi
 rts

; Signed 16-bit camera coordinate times signed Q6 normal, returning signed
; 16-bit in p1. This copy is profile-local so fixed cameras do not gain the
; explorer transform helper.
camera_plane_mul_s16_s6:
 sta mul16mul
 sta mul16abs
 lda #$00
 sta mul16sign
 lda p1hi
 bpl cpms16_coord_ok
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
 lda mul16sign
 eor #$80
 sta mul16sign
cpms16_coord_ok:
 lda mul16mul
 bpl cpms16_mul_ok
 eor #$ff
 clc
 adc #$01
 sta mul16mul
 sta mul16abs
 lda mul16sign
 eor #$80
 sta mul16sign
cpms16_mul_ok:
 lda p1lo
 and #$3f
 sta mul16rem
 ldx #$06
cpms16_shift_q:
 lsr p1hi
 ror p1lo
 dex
 bne cpms16_shift_q
 lda p1lo
 sta mul16lo
 lda p1hi
 sta mul16hi
 lda #$00
 sta mul16reslo
 sta mul16reshi
 ldx #$08
cpms16_mul_loop:
 lsr mul16mul
 bcc cpms16_no_add
 clc
 lda mul16reslo
 adc mul16lo
 sta mul16reslo
 lda mul16reshi
 adc mul16hi
 sta mul16reshi
cpms16_no_add:
 asl mul16lo
 rol mul16hi
 dex
 bne cpms16_mul_loop
 lda mul16rem
 beq cpms16_no_rem
 ldx mul16abs
 jsr mul_s6
 clc
 adc mul16reslo
 sta mul16reslo
 bcc cpms16_no_rem
 inc mul16reshi
cpms16_no_rem:
 lda mul16reslo
 sta p1lo
 lda mul16reshi
 sta p1hi
 lda mul16sign
 bpl cpms16_done
 sec
 lda #$00
 sbc p1lo
 sta p1lo
 lda #$00
 sbc p1hi
 sta p1hi
cpms16_done:
 rts

; CAMERA_PLANE_CULL_NORMAL_TABLES

.if MEMORY_LAYOUT_HIGH_BASIC_V2 = 0
camera_plane_cull_code_end = *
.if camera_plane_cull_code_start != $9500
 .error "Camera-plane cull code did not start at $9500"
.endif
.if camera_plane_cull_code_end > $9f00
 .error "Camera-plane cull code leaves less than 256 bytes before bitmap B"
.endif
* = camera_plane_cull_low_return
.endif
.endif

face_visible:
 sec
 lda vy1
 sbc vy0
 sta dy1v
 sec
 lda vx2
 sbc vx0
 tax
 sec
 lda vy2
 sbc vy0
 stx dx2v
 tax
 sec
 lda vx1
 sbc vx0
 jsr mul_s8_16
 lda prodlo
 sta p1lo
 lda prodhi
 sta p1hi
 lda dy1v
 ldx dx2v
 jsr mul_s8_16
 sec
 lda p1lo
 sbc prodlo
 sta crosslo
 lda p1hi
 sbc prodhi
 sta crosshi
.if STABLE_FACE_CULL_PROFILE != 0
 ; Only the vulnerable signed-area band around zero falls back to the original
 ; camera-space face. This keeps the general path cheap while removing rounded
 ; screen-space decisions at and immediately around the edge-on transition.
 lda crosshi
 beq tv_stable_positive_band
 cmp #$ff
 bne tv_stable_screen_safe
 lda crosslo
 cmp #(256 - STABLE_FACE_CULL_SCREEN_AREA_BAND)
 bcs tv_stable_camera_fallback
 bcc tv_stable_screen_safe
tv_stable_positive_band:
 lda crosslo
 cmp #(STABLE_FACE_CULL_SCREEN_AREA_BAND + 1)
 bcs tv_stable_screen_safe
tv_stable_camera_fallback:
 jsr camera_plane_original_facing
tv_stable_camera_done:
 rts
tv_stable_screen_safe:
.endif
 lda crosshi
.if CONSERVATIVE_FACE_CULL != 0
 bmi tv_cons_neg
 jmp tv_yes
tv_cons_neg:
 cmp #$ff
 bne tv_no
.if EXPLORER_SCREEN_CLIP_POLY != 0
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #$04
 bne tv_cons_normal_neg
.endif
 ldy faceidx
 sty sortj
 jsr clip_poly_needs_screen
 beq tv_cons_normal_neg
 lda crosslo
 cmp #(256 - CONSERVATIVE_EDGE_CULL_NEG_AREA)
 bcs tv_yes
 jmp tv_no
tv_cons_normal_neg:
.endif
 lda crosslo
 cmp #(256 - CONSERVATIVE_CULL_NEG_AREA)
 bcs tv_yes
 jmp tv_no
.else
 bmi tv_no
 bne tv_yes
 lda crosslo
 cmp #MIN_FACE_AREA
 bcc tv_no
.endif
tv_yes:
 sec
 rts
tv_no:
 clc
 rts
.endif
.endif
.endif

.if STANDARD_PROJECT_VERTEX != 0
project_vertex:
.if REFERENCE_PROJECTION != 0
 jmp project_vertex_reference
.endif
.if EXTENDED_TABLE_PROJECTION != 0
 jmp project_vertex_extended_table
.endif
.if REFERENCE_PROJECTION = 0
.if EXTENDED_TABLE_PROJECTION = 0
 lda projdone,x
 bne pv_done
 stx tmpidx
 jsr load_projection_table_index
 lda p1hi
 beq pv_index_low
 cmp #$21
 bcc pv_index_far
 lda #$01
 sta scalev
 jmp pv_scale_ready
pv_index_far:
 sec
 sbc #$01
 asl
 asl
 asl
 sta p1hi
 lda p1lo
 lsr
 lsr
 lsr
 lsr
 lsr
 ora p1hi
 tax
 lda scale_far_tab,x
 sta scalev
 jmp pv_scale_ready
pv_index_low:
 ldx p1lo
 lda scale_tab,x
 sta scalev
pv_scale_ready:
 ldx tmpidx
 lda rxbuf,x
 beq pv_x_center
 ldx scalev
 jsr mul_s6_xpos_round
 tax
 lda projx,x
 ldy tmpidx
 sta sx,y
 jmp pv_y_project
pv_x_center:
 ldy tmpidx
 lda #PROJ_CENTER_X
 sta sx,y
pv_y_project:
 lda rybuf,y
 beq pv_y_center
 ldx scalev
 jsr mul_s6_xpos_round
 tax
 lda projy,x
 ldy tmpidx
 sta sy,y
 jmp pv_mark_done
pv_y_center:
 lda #PROJ_CENTER_Y
 sta sy,y
pv_mark_done:
 jsr smooth_projected_vertex
 lda #$01
 sta projdone,y
pv_done:
 rts
.endif
.endif

.if EXTENDED_TABLE_PROJECTION != 0
project_vertex_extended_table:
 lda projdone,x
 bne pvet_done
 stx tmpidx
 jsr load_extended_scale
 ldx tmpidx
 lda rxbuf,x
 beq pvet_x_center
 ldx scalev
 jsr mul_s6_xpos_round
 tax
 lda projx,x
 ldy tmpidx
 sta sx,y
 jmp pvet_y_project
pvet_x_center:
 ldy tmpidx
 lda #PROJ_CENTER_X
 sta sx,y
pvet_y_project:
 lda rybuf,y
 beq pvet_y_center
 ldx scalev
 jsr mul_s6_xpos_round
 tax
 lda projy,x
 ldy tmpidx
 sta sy,y
 jmp pvet_mark_done
pvet_y_center:
 lda #PROJ_CENTER_Y
 sta sy,y
pvet_mark_done:
 jsr smooth_projected_vertex
 lda #$01
 sta projdone,y
pvet_done:
 rts

load_extended_scale:
 jsr load_projection_table_index
 lda p1hi
 beq les_near
 cmp #$21
 bcc les_far
 lda #$01
 sta scalev
 rts
les_near:
 lda p1lo
.if SCENE_OBJECT_COUNT != 0
 tax
 lda scene_scale_tab,x
.else
 tax
 lda scale_tab,x
.endif
 sta scalev
 rts
les_far:
 sec
 sbc #$01
 asl
 asl
 asl
 sta p1hi
 lda p1lo
 lsr
 lsr
 lsr
 lsr
 lsr
 ora p1hi
 tax
 lda scale_far_tab,x
 sta scalev
 rts
.endif

.if REFERENCE_PROJECTION != 0
project_vertex_reference:
 lda projdone,x
 bne pvr_done
 stx tmpidx
 lda rxbuf,x
 bpl pvr_x_abs_ready
 eor #$ff
 clc
 adc #$01
pvr_x_abs_ready:
 tax
 lda proj_num_lo,x
 sta prodlo
 lda proj_num_hi,x
 sta prodhi
 jsr load_projection_geometric_divisor
 jsr div16u
 lda prodhi
 beq pvr_x_quotient_ok
 lda #$ff
 jmp pvr_x_offset_ready
pvr_x_quotient_ok:
 lda prodlo
pvr_x_offset_ready:
 sta scalev
 ldx tmpidx
 lda rxbuf,x
 bmi pvr_x_left
 lda scalev
 cmp #PROJ_CENTER_X
 bcc pvr_x_right_visible
 lda #PROJ_SCREEN_MAX_X
 jmp pvr_x_store
pvr_x_right_visible:
 clc
 adc #PROJ_CENTER_X
 jmp pvr_x_store
pvr_x_left:
 lda scalev
 cmp #(PROJ_CENTER_X + 1)
 bcc pvr_x_left_visible
 lda #$00
 jmp pvr_x_store
pvr_x_left_visible:
 sta p1lo
 lda #PROJ_CENTER_X
 sec
 sbc p1lo
pvr_x_store:
 ldy tmpidx
 sta sx,y
 ldx tmpidx
 lda rybuf,x
 bpl pvr_y_abs_ready
 eor #$ff
 clc
 adc #$01
pvr_y_abs_ready:
 tax
 lda proj_num_lo,x
 sta prodlo
 lda proj_num_hi,x
 sta prodhi
 jsr load_projection_geometric_divisor
 jsr div16u
 lda prodhi
 beq pvr_y_quotient_ok
 lda #$ff
 jmp pvr_y_offset_ready
pvr_y_quotient_ok:
 lda prodlo
pvr_y_offset_ready:
 sta scalev
 ldx tmpidx
 lda rybuf,x
 bmi pvr_y_down
 lda scalev
 cmp #$33
 bcc pvr_y_up_visible
 lda #$00
 jmp pvr_y_store
pvr_y_up_visible:
 sta p1lo
 lda #PROJ_CENTER_Y
 sec
 sbc p1lo
 jmp pvr_y_store
pvr_y_down:
 lda scalev
 cmp #PROJ_CENTER_Y
 bcc pvr_y_down_visible
 lda #PROJ_SCREEN_MAX_Y
 jmp pvr_y_store
pvr_y_down_visible:
 clc
 adc #PROJ_CENTER_Y
pvr_y_store:
 ldy tmpidx
 sta sy,y
 jsr smooth_projected_vertex
 lda #$01
 sta projdone,y
pvr_done:
 rts
.endif
.endif

.if REFERENCE_PROJECTION != 0 || CAMERA_MOVABLE != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
div16u:
 lda #$00
 sta crosslo
 sta crosshi
 ldx #$10
d16_loop:
 asl prodlo
 rol prodhi
 rol crosslo
 rol crosshi
 lda crosslo
 sec
 sbc p1lo
 tay
 lda crosshi
 sbc p1hi
 bcc d16_skip_sub
 sta crosshi
 sty crosslo
 inc prodlo
d16_skip_sub:
 dex
 bne d16_loop
 rts
.endif

.if STANDARD_PROJECT_VERTEX != 0
smooth_projected_vertex:
 ldy tmpidx
 lda smooth_ready,y
 bne spv_smooth
 lda sx,y
 sta sx_prev,y
 lda sy,y
 sta sy_prev,y
 lda #$01
 sta smooth_ready,y
 rts
spv_smooth:
 lda sx,y
 sta p1lo
 lda sx_prev,y
 sta p1hi
 lda p1lo
 cmp p1hi
 beq spv_x_store_prev
 bcc spv_x_neg
 sec
 sbc p1hi
 cmp #$02
 bcc spv_x_store_prev
 beq spv_x_pos_step
 lda p1lo
 jmp spv_x_store
spv_x_pos_step:
 lda p1hi
 clc
 adc #$01
 jmp spv_x_store
spv_x_neg:
 lda p1hi
 sec
 sbc p1lo
 cmp #$02
 bcc spv_x_store_prev
 beq spv_x_neg_step
 lda p1lo
 jmp spv_x_store
spv_x_neg_step:
 lda p1hi
 sec
 sbc #$01
 jmp spv_x_store
spv_x_store_prev:
 lda p1hi
spv_x_store:
 sta sx,y
 sta sx_prev,y
 lda sy,y
 sta p1lo
 lda sy_prev,y
 sta p1hi
 lda p1lo
 cmp p1hi
 beq spv_y_store_prev
 bcc spv_y_neg
 sec
 sbc p1hi
 cmp #$02
 bcc spv_y_store_prev
 beq spv_y_pos_step
 lda p1lo
 jmp spv_y_store
spv_y_pos_step:
 lda p1hi
 clc
 adc #$01
 jmp spv_y_store
spv_y_neg:
 lda p1hi
 sec
 sbc p1lo
 cmp #$02
 bcc spv_y_store_prev
 beq spv_y_neg_step
 lda p1lo
 jmp spv_y_store
spv_y_neg_step:
 lda p1hi
 sec
 sbc #$01
 jmp spv_y_store
spv_y_store_prev:
 lda p1hi
spv_y_store:
 sta sy,y
 sta sy_prev,y
 rts
.endif

.if POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0
select_draw_paths:
 lda drawbuf
 bne sdp_b
.if HIDDEN_WIRE_ENABLE = 0
 lda #<draw_loaded_face_solid_a
 sta ddb_solid_call+1
 lda #>draw_loaded_face_solid_a
 sta ddb_solid_call+2
.endif
.if HIDDEN_WIRE_ENABLE != 0 && (POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0)
 lda #<draw_loaded_face_solid_a
 sta ddb_hidden_mask_call+1
.if EXPLORER_SCREEN_CLIP_X != 0
 sta ddb_hidden_mask_second_call+1
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0 && WIRE_MESH_COUNT != 0
 sta ddb_hidden_mask_second_only_call+1
.endif
.endif
 lda #>draw_loaded_face_solid_a
 sta ddb_hidden_mask_call+2
.if EXPLORER_SCREEN_CLIP_X != 0
 sta ddb_hidden_mask_second_call+2
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0 && WIRE_MESH_COUNT != 0
 sta ddb_hidden_mask_second_only_call+2
.endif
.endif
.endif
.if HIDDEN_WIRE_ENABLE = 0
 lda #<draw_loaded_face_pattern_a
 sta ddb_pattern_call+1
 lda #>draw_loaded_face_pattern_a
 sta ddb_pattern_call+2
.endif
 rts
sdp_b:
.if HIDDEN_WIRE_ENABLE = 0
 lda #<draw_loaded_face_solid_b
 sta ddb_solid_call+1
 lda #>draw_loaded_face_solid_b
 sta ddb_solid_call+2
.endif
.if HIDDEN_WIRE_ENABLE != 0 && (POLY_FILL_ENABLE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0)
 lda #<draw_loaded_face_solid_b
 sta ddb_hidden_mask_call+1
.if EXPLORER_SCREEN_CLIP_X != 0
 sta ddb_hidden_mask_second_call+1
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0 && WIRE_MESH_COUNT != 0
 sta ddb_hidden_mask_second_only_call+1
.endif
.endif
 lda #>draw_loaded_face_solid_b
 sta ddb_hidden_mask_call+2
.if EXPLORER_SCREEN_CLIP_X != 0
 sta ddb_hidden_mask_second_call+2
.if POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE != 0 && WIRE_FACE_EDGE_ENABLE != 0 && WIRE_MESH_COUNT != 0
 sta ddb_hidden_mask_second_only_call+2
.endif
.endif
.endif
.if HIDDEN_WIRE_ENABLE = 0
 lda #<draw_loaded_face_pattern_b
 sta ddb_pattern_call+1
 lda #>draw_loaded_face_pattern_b
 sta ddb_pattern_call+2
.endif
 rts

draw_loaded_face_solid_a:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlfs_a_normal
 jmp draw_clip_poly_solid_a
dlfs_a_normal:
.endif
.if DIRECT_CONVEX_FAN_FILL != 0 && WIRE_RENDER_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0
.if ENGINE_MODE3_DIRECT_CONVEX_FILL != 0
 ldy sortj
 lda frame_face_prepare,y
 beq dlfs_a_bounds
.endif
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$03
 beq dlfs_a_direct
 cmp #$04
 bne dlfs_a_bounds
dlfs_a_direct:
.endif
 jmp draw_direct_face_solid_a
dlfs_a_bounds:
.endif
 jsr build_loaded_face_bounds
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 lda xyq2_face_valid
 beq dlfs_a_done
.endif
 jmp fill_bounds_solid_a
dlfs_a_done:
 rts

draw_loaded_face_solid_b:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlfs_b_normal
 jmp draw_clip_poly_solid_b
dlfs_b_normal:
.endif
.if DIRECT_CONVEX_FAN_FILL != 0 && WIRE_RENDER_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0
.if ENGINE_MODE3_DIRECT_CONVEX_FILL != 0
 ldy sortj
 lda frame_face_prepare,y
 beq dlfs_b_bounds
.endif
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$03
 beq dlfs_b_direct
 cmp #$04
 bne dlfs_b_bounds
dlfs_b_direct:
.endif
 jmp draw_direct_face_solid_b
dlfs_b_bounds:
.endif
 jsr build_loaded_face_bounds
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 lda xyq2_face_valid
 beq dlfs_b_done
.endif
 jmp fill_bounds_solid_b
dlfs_b_done:
 rts

.if HIDDEN_WIRE_ENABLE = 0
draw_loaded_face_pattern_a:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlfp_a_normal
 jmp draw_clip_poly_pattern_a
dlfp_a_normal:
.endif
.if DIRECT_CONVEX_FAN_FILL != 0 && WIRE_RENDER_ENABLE = 0
.if ENGINE_MODE3_DIRECT_CONVEX_FILL != 0
 ldy sortj
 lda frame_face_prepare,y
 beq dlfp_a_bounds
.endif
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$03
 beq dlfp_a_direct
 cmp #$04
 bne dlfp_a_bounds
dlfp_a_direct:
.endif
 jmp draw_direct_face_pattern_a
dlfp_a_bounds:
.endif
 jsr build_loaded_face_bounds
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 lda xyq2_face_valid
 beq dlfp_a_done
.endif
.if MODE4_PATTERN_PROBE_LATCHED_FACE != 0
 jmp mode4_pattern_probe_latched_fill_a
.else
 jmp fill_bounds_pattern_a
.endif
dlfp_a_done:
 rts

draw_loaded_face_pattern_b:
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq dlfp_b_normal
 jmp draw_clip_poly_pattern_b
dlfp_b_normal:
.endif
.if DIRECT_CONVEX_FAN_FILL != 0 && WIRE_RENDER_ENABLE = 0
.if ENGINE_MODE3_DIRECT_CONVEX_FILL != 0
 ldy sortj
 lda frame_face_prepare,y
 beq dlfp_b_bounds
.endif
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$03
 beq dlfp_b_direct
 cmp #$04
 bne dlfp_b_bounds
dlfp_b_direct:
.endif
 jmp draw_direct_face_pattern_b
dlfp_b_bounds:
.endif
 jsr build_loaded_face_bounds
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 lda xyq2_face_valid
 beq dlfp_b_done
.endif
.if MODE4_PATTERN_PROBE_LATCHED_FACE != 0
 jmp mode4_pattern_probe_latched_fill_b
.else
 jmp fill_bounds_pattern_b
.endif
dlfp_b_done:
 rts
.endif

.if EXPLORER_SCREEN_CLIP_POLY != 0
load_clip_poly_fan_triangle:
 lda #$03
 sta loaded_face_vertex_count
 lda clip_a_x
 sta vx0
 lda clip_a_y
 sta vy0
 ldx clip_cur_idx
 lda clip_a_x,x
 sta vx1
 lda clip_a_y,x
 sta vy1
 inx
 lda clip_a_x,x
 sta vx2
 sta vx3
 lda clip_a_y,x
 sta vy2
 sta vy3
 rts

draw_clip_poly_solid_a:
 lda #<fill_bounds_solid_a
 sta dcp_fill_call+1
 lda #>fill_bounds_solid_a
 sta dcp_fill_call+2
 jmp draw_clip_poly_common

draw_clip_poly_solid_b:
 lda #<fill_bounds_solid_b
 sta dcp_fill_call+1
 lda #>fill_bounds_solid_b
 sta dcp_fill_call+2
 jmp draw_clip_poly_common

.if HIDDEN_WIRE_ENABLE = 0
draw_clip_poly_pattern_a:
 lda #<fill_bounds_pattern_a
 sta dcp_fill_call+1
 lda #>fill_bounds_pattern_a
 sta dcp_fill_call+2
 jmp draw_clip_poly_common

draw_clip_poly_pattern_b:
 lda #<fill_bounds_pattern_b
 sta dcp_fill_call+1
 lda #>fill_bounds_pattern_b
 sta dcp_fill_call+2
.endif
draw_clip_poly_common:
 lda clip_a_count
 cmp #$03
 bcc dcp_done
 lda #$01
 sta clip_cur_idx
dcp_loop:
 jsr load_clip_poly_fan_triangle
 jsr build_loaded_face_bounds_convex
dcp_fill_call:
 jsr fill_bounds_solid_a
 inc clip_cur_idx
 lda clip_cur_idx
 clc
 adc #$01
 cmp clip_a_count
 bcc dcp_loop
dcp_done:
 rts
.endif

.if DIRECT_CONVEX_FAN_FILL != 0 && WIRE_RENDER_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0
draw_direct_face_solid_a:
 lda #<direct_fill_span_solid_a
 sta dft_span_call+1
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+1
.endif
 lda #>direct_fill_span_solid_a
 sta dft_span_call+2
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+2
.endif
 jmp draw_direct_face_common

draw_direct_face_solid_b:
 lda #<direct_fill_span_solid_b
 sta dft_span_call+1
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+1
.endif
 lda #>direct_fill_span_solid_b
 sta dft_span_call+2
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+2
.endif
 jmp draw_direct_face_common

draw_direct_face_pattern_a:
 lda #<direct_fill_span_pattern_a
 sta dft_span_call+1
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+1
.endif
 lda #>direct_fill_span_pattern_a
 sta dft_span_call+2
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+2
.endif
 jmp draw_direct_face_common

draw_direct_face_pattern_b:
 lda #<direct_fill_span_pattern_b
 sta dft_span_call+1
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+1
.endif
 lda #>direct_fill_span_pattern_b
 sta dft_span_call+2
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
 sta dft_quad_span_call+2
.endif

draw_direct_face_common:
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0


.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
.endif
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne ddf_triangle_first
.endif
 jsr direct_draw_quad_current
 bcs ddf_done
.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
ddf_triangle_first:
.endif
 jsr direct_draw_triangle_current
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne ddf_done
.endif
 lda vx1
 sta dft_save_vx1
 lda vy1
 sta dft_save_vy1
 lda vx2
 sta dft_save_vx2
 lda vy2
 sta dft_save_vy2
 lda vx2
 sta vx1
 lda vy2
 sta vy1
 lda vx3
 sta vx2
 lda vy3
 sta vy2
 jsr direct_draw_triangle_current
 lda dft_save_vx1
 sta vx1
 lda dft_save_vy1
 sta vy1
 lda dft_save_vx2
 sta vx2
 lda dft_save_vy2
 sta vy2
ddf_done:
 rts

direct_draw_triangle_current:
 lda vx0
 sta dft_x0
 lda vy0
 sta dft_y0
 lda vx1
 sta dft_x1
 lda vy1
 sta dft_y1
 lda vx2
 sta dft_x2
 lda vy2
 sta dft_y2
 jsr dft_sort_y
 lda dft_y2
 cmp dft_y0
 bne dft_nonflat
 jmp dft_done
dft_nonflat:
 lda dft_x0
 sta ex0
 lda dft_y0
 sta ey0
 lda dft_x2
 sta ex1
 lda dft_y2
 sta ey1
 jsr dft_init_long
 lda dft_y0
 cmp dft_y1
 beq dft_flat_top
 lda dft_x0
 sta ex0
 lda dft_y0
 sta ey0
 lda dft_x1
 sta ex1
 lda dft_y1
 sta ey1
 jsr dft_init_short
 lda #$00
 sta dft_short_phase
 jmp dft_loop_setup
dft_flat_top:
 lda dft_x1
 sta ex0
 lda dft_y1
 sta ey0
 lda dft_x2
 sta ex1
 lda dft_y2
 sta ey1
 jsr dft_init_short
 lda #$01
 sta dft_short_phase
dft_loop_setup:
 lda dft_y0
 sta yrow
dft_loop:
 lda dft_y2
 cmp yrow
 bcs dft_loop_active
 jmp dft_done
dft_loop_active:
 jsr dft_collect_long
 lda dft_short_phase
 bne dft_collect_short_current
 lda dft_y1
 cmp dft_y2
 beq dft_collect_short_current
 lda yrow
 cmp dft_y1
 bcc dft_collect_short_current
 ; Preserve both edge contributions on the split scanline. The established
 ; upper edge can contain a shallow horizontal run before x1, while
 ; the lower edge starts from x1 on the same row.
 jsr dft_collect_short
 lda dft_smin
 sta dft_split_min
 lda dft_smax
 sta dft_split_max
 lda dft_x1
 sta ex0
 lda dft_y1
 sta ey0
 lda dft_x2
 sta ex1
 lda dft_y2
 sta ey1
 jsr dft_init_short
 lda #$01
 sta dft_short_phase
 jsr dft_collect_short
 lda dft_split_min
 cmp dft_smin
 bcs dft_split_min_ready
 sta dft_smin
dft_split_min_ready:
 lda dft_split_max
 cmp dft_smax
 bcc dft_edges_ready
 beq dft_edges_ready
 sta dft_smax
 jmp dft_edges_ready
dft_collect_short_current:
 jsr dft_collect_short
dft_edges_ready:
 lda dft_lmin
 cmp dft_smin
 bcc dft_left_long
 lda dft_smin
 jmp dft_left_store
dft_left_long:
 lda dft_lmin
dft_left_store:
 sta leftval
 lda dft_lmax
 cmp dft_smax
 bcs dft_right_long
 lda dft_smax
 jmp dft_right_store
dft_right_long:
 lda dft_lmax
dft_right_store:
 sta rightval
 cmp leftval
 bcc dft_row_done
dft_span_call:
 jsr direct_fill_span_solid_a
dft_row_done:
 inc yrow
 jmp dft_loop
dft_done:
 rts

.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
; Native convex quad fill for prepared engine mode-3 faces. The four source
; vertices remain in mesh winding order. Starting from the topmost vertex,
; the +1 and -1 boundary chains are monotone in Y for a convex polygon. The
; existing long/short walkers trace the two chains and emit one merged span
; per scanline. A topology anomaly returns carry clear and the caller redraws
; through the validated two-triangle fan.
direct_draw_quad_current:
 lda vx0
 sta qf_x+0
 lda vy0
 sta qf_y+0
 sta yrow
 sta qf_ymax
 lda #$00
 sta qf_top_idx
 lda vx1
 sta qf_x+1
 lda vy1
 sta qf_y+1
 ldx #$01
 jsr qf_scan_y_extrema
 lda vx2
 sta qf_x+2
 lda vy2
 sta qf_y+2
 ldx #$02
 jsr qf_scan_y_extrema
 lda vx3
 sta qf_x+3
 lda vy3
 sta qf_y+3
 ldx #$03
 jsr qf_scan_y_extrema
 lda qf_ymax
 cmp yrow
 bne qf_nonflat
 clc
 rts
qf_nonflat:
 lda #$01
 sta qf_a_step
 lda qf_top_idx
 sta qf_work_idx
 lda qf_a_step
 sta qf_work_step
 jsr qf_prepare_edge
 bcc qf_fail
 lda qf_work_idx
 sta qf_a_idx
 jsr dft_init_long
 lda #$03
 sta qf_b_step
 lda qf_top_idx
 sta qf_work_idx
 lda qf_b_step
 sta qf_work_step
 jsr qf_prepare_edge
 bcc qf_fail
 lda qf_work_idx
 sta qf_b_idx
 jsr dft_init_short
qf_loop:
 jsr qf_collect_long_chain
 bcc qf_fail
 jsr qf_collect_short_chain
 bcc qf_fail
 lda dft_lmin
 cmp dft_smin
 bcc qf_left_long
 lda dft_smin
 jmp qf_left_store
qf_left_long:
 lda dft_lmin
qf_left_store:
 sta leftval
 lda dft_lmax
 cmp dft_smax
 bcs qf_right_long
 lda dft_smax
 jmp qf_right_store
qf_right_long:
 lda dft_lmax
qf_right_store:
 sta rightval
 cmp leftval
 bcc qf_row_done
dft_quad_span_call:
 jsr direct_fill_span_solid_a
qf_row_done:
 lda yrow
 cmp qf_ymax
 beq qf_success
 inc yrow
 jmp qf_loop
qf_success:
 sec
 rts
qf_fail:
 clc
 rts

; X selects the newly copied vertex. Keep the first minimum-Y vertex so
; horizontal top edges are split naturally between the two boundary chains.
qf_scan_y_extrema:
 lda qf_y,x
 cmp yrow
 bcs qf_scan_max
 sta yrow
 stx qf_top_idx
qf_scan_max:
 lda qf_y,x
 cmp qf_ymax
 bcc qf_scan_done
 sta qf_ymax
qf_scan_done:
 rts

; Build the next rising edge from qf_work_idx using +1 or -1 modulo four.
; Horizontal chain links are folded into the new start vertex. Four hops are
; the hard guard against a degenerate/all-horizontal or non-monotone polygon.
qf_prepare_edge:
 ldx qf_work_idx
 lda qf_x,x
 sta ex0
 lda qf_y,x
 sta ey0
 lda #$04
 sta qf_hops
qf_prepare_next:
 lda qf_work_idx
 clc
 adc qf_work_step
 and #$03
 sta qf_work_idx
 tax
 lda qf_y,x
 cmp ey0
 bcc qf_prepare_fail
 bne qf_prepare_rising
 lda qf_x,x
 sta ex0
 lda qf_y,x
 sta ey0
 dec qf_hops
 bne qf_prepare_next
qf_prepare_fail:
 clc
 rts
qf_prepare_rising:
 sta ey1
 lda qf_x,x
 sta ex1
 sec
 rts

; At a chain vertex the outgoing edge contributes on the same scanline as the
; incoming edge. Merge both extrema before the other chain and the span writer
; see them, preserving horizontal and shallow-edge coverage.
qf_collect_long_chain:
 jsr dft_collect_long
 lda yrow
 cmp dft_lendy
 bne qf_long_ok
 cmp qf_ymax
 beq qf_long_ok
 lda dft_lmin
 sta qf_save_min
 lda dft_lmax
 sta qf_save_max
 lda qf_a_idx
 sta qf_work_idx
 lda qf_a_step
 sta qf_work_step
 jsr qf_prepare_edge
 bcc qf_long_fail
 lda qf_work_idx
 sta qf_a_idx
 jsr dft_init_long
 jsr dft_collect_long
 lda qf_save_min
 cmp dft_lmin
 bcs qf_long_min_ready
 sta dft_lmin
qf_long_min_ready:
 lda qf_save_max
 cmp dft_lmax
 bcc qf_long_ok
 beq qf_long_ok
 sta dft_lmax
qf_long_ok:
 sec
 rts
qf_long_fail:
 clc
 rts

qf_collect_short_chain:
 jsr dft_collect_short
 lda yrow
 cmp dft_sendy
 bne qf_short_ok
 cmp qf_ymax
 beq qf_short_ok
 lda dft_smin
 sta qf_save_min
 lda dft_smax
 sta qf_save_max
 lda qf_b_idx
 sta qf_work_idx
 lda qf_b_step
 sta qf_work_step
 jsr qf_prepare_edge
 bcc qf_short_fail
 lda qf_work_idx
 sta qf_b_idx
 jsr dft_init_short
 jsr dft_collect_short
 lda qf_save_min
 cmp dft_smin
 bcs qf_short_min_ready
 sta dft_smin
qf_short_min_ready:
 lda qf_save_max
 cmp dft_smax
 bcc qf_short_ok
 beq qf_short_ok
 sta dft_smax
qf_short_ok:
 sec
 rts
qf_short_fail:
 clc
 rts
.endif

dft_sort_y:
 lda dft_y1
 cmp dft_y0
 bcs dft_sort_12
 jsr dft_swap_01
dft_sort_12:
 lda dft_y2
 cmp dft_y1
 bcs dft_sort_01_again
 jsr dft_swap_12
dft_sort_01_again:
 lda dft_y1
 cmp dft_y0
 bcs dft_sort_done
 jsr dft_swap_01
dft_sort_done:
 rts

dft_swap_01:
 lda dft_x0
 sta t1
 lda dft_x1
 sta dft_x0
 lda t1
 sta dft_x1
 lda dft_y0
 sta t1
 lda dft_y1
 sta dft_y0
 lda t1
 sta dft_y1
 rts

dft_swap_12:
 lda dft_x1
 sta t1
 lda dft_x2
 sta dft_x1
 lda t1
 sta dft_x2
 lda dft_y1
 sta t1
 lda dft_y2
 sta dft_y1
 lda t1
 sta dft_y2
 rts

dft_init_long:
 lda ex0
 sta dft_lx
 lda ey1
 sta dft_lendy
 sec
 lda ey1
 sbc ey0
 sta dft_ldy
 lda #$00
 sta dft_ltype
 lda ex1
 cmp ex0
 bcs dft_il_pos
 sec
 lda ex0
 sbc ex1
 sta dft_ldx
 lda #$ff
 sta dft_lsx
 jmp dft_il_classify
dft_il_pos:
 sec
 lda ex1
 sbc ex0
 sta dft_ldx
 lda #$01
 sta dft_lsx
dft_il_classify:
 lda dft_ldx
 beq dft_il_vert
 cmp dft_ldy
 beq dft_il_diag
 jmp dft_il_err
dft_il_vert:
 lda #$00
 sta dft_lsx
 lda #$01
 sta dft_ltype
 jmp dft_il_err
dft_il_diag:
 lda #$02
 sta dft_ltype
dft_il_err:
 lda #$00
 sta dft_lerrlo
 sta dft_lerrhi
 rts

dft_init_short:
 lda ex0
 sta dft_sx
 lda ey1
 sta dft_sendy
 sec
 lda ey1
 sbc ey0
 sta dft_sdy
 lda #$00
 sta dft_stype
 lda ex1
 cmp ex0
 bcs dft_is_pos
 sec
 lda ex0
 sbc ex1
 sta dft_sdx
 lda #$ff
 sta dft_ssx
 jmp dft_is_classify
dft_is_pos:
 sec
 lda ex1
 sbc ex0
 sta dft_sdx
 lda #$01
 sta dft_ssx
dft_is_classify:
 lda dft_sdx
 beq dft_is_vert
 cmp dft_sdy
 beq dft_is_diag
 jmp dft_is_err
dft_is_vert:
 lda #$00
 sta dft_ssx
 lda #$01
 sta dft_stype
 jmp dft_is_err
dft_is_diag:
 lda #$02
 sta dft_stype
dft_is_err:
 lda #$00
 sta dft_serrlo
 sta dft_serrhi
 rts

dft_collect_long:
 lda dft_lx
 sta dft_lmin
 sta dft_lmax
 lda yrow
 cmp dft_lendy
 beq dft_cl_done
 lda dft_ltype
 cmp #$01
 beq dft_cl_done
 cmp #$02
 bne dft_cl_general
 lda dft_lsx
 bmi dft_cl_diag_neg
 inc dft_lx
 rts
dft_cl_diag_neg:
 dec dft_lx
 rts
dft_cl_general:
 clc
 lda dft_lerrlo
 adc dft_ldx
 sta dft_lerrlo
 lda dft_lerrhi
 adc #$00
 sta dft_lerrhi
dft_cl_check:
 lda dft_lerrhi
 bne dft_cl_xstep
 lda dft_lerrlo
 cmp dft_ldy
 bcc dft_cl_done
dft_cl_xstep:
 sec
 lda dft_lerrlo
 sbc dft_ldy
 sta dft_lerrlo
 lda dft_lerrhi
 sbc #$00
 sta dft_lerrhi
 lda dft_lsx
 beq dft_cl_check
 bmi dft_cl_xneg
 inc dft_lx
 lda dft_lx
 sta dft_lmax
 jmp dft_cl_check
dft_cl_xneg:
 dec dft_lx
 lda dft_lx
 sta dft_lmin
 jmp dft_cl_check
dft_cl_done:
 rts

dft_collect_short:
 lda dft_sx
 sta dft_smin
 sta dft_smax
 lda yrow
 cmp dft_sendy
 beq dft_cs_done
 lda dft_stype
 cmp #$01
 beq dft_cs_done
 cmp #$02
 bne dft_cs_general
 lda dft_ssx
 bmi dft_cs_diag_neg
 inc dft_sx
 rts
dft_cs_diag_neg:
 dec dft_sx
 rts
dft_cs_general:
 clc
 lda dft_serrlo
 adc dft_sdx
 sta dft_serrlo
 lda dft_serrhi
 adc #$00
 sta dft_serrhi
dft_cs_check:
 lda dft_serrhi
 bne dft_cs_xstep
 lda dft_serrlo
 cmp dft_sdy
 bcc dft_cs_done
dft_cs_xstep:
 sec
 lda dft_serrlo
 sbc dft_sdy
 sta dft_serrlo
 lda dft_serrhi
 sbc #$00
 sta dft_serrhi
 lda dft_ssx
 beq dft_cs_check
 bmi dft_cs_xneg
 inc dft_sx
 lda dft_sx
 sta dft_smax
 jmp dft_cs_check
dft_cs_xneg:
 dec dft_sx
 lda dft_sx
 sta dft_smin
 jmp dft_cs_check
dft_cs_done:
 rts

direct_fill_span_pattern_a:
 ldy shadeidx
 lda yrow
 and #$01
 beq dfp_a_even
 iny
dfp_a_even:
 lda shade_pattern_bytes,y
 sta fillbyte
 jmp direct_fill_span_solid_a

direct_fill_span_pattern_b:
 ldy shadeidx
 lda yrow
 and #$01
 beq dfp_b_even
 iny
dfp_b_even:
 lda shade_pattern_bytes,y
 sta fillbyte
 jmp direct_fill_span_solid_b

direct_fill_span_solid_a:
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq dfs_a_draw
 ldx yrow
 jsr lowres_row_selected
 bne dfs_a_done
.endif
dfs_a_draw:
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 txa
 cmp dirty_ymin_a
 bcs dfs_a_dirty_ymin_ok
 sta dirty_ymin_a
dfs_a_dirty_ymin_ok:
 txa
 cmp dirty_ymax_a
 bcc dfs_a_dirty_ymax_ok
 sta dirty_ymax_a
dfs_a_dirty_ymax_ok:
.endif
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_a
.else
 jsr apply_material_span_a
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_a,x
 bcs dfs_a_dirty_min_ok
 sta dirtymin_a,x
dfs_a_dirty_min_ok:
 lda endbyte
 cmp dirtymax_a,x
 bcc dfs_a_dirty_done
 sta dirtymax_a,x
dfs_a_dirty_done:
.endif
 jmp direct_fill_span_pixels
dfs_a_done:
 rts

direct_fill_span_solid_b:
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq dfs_b_draw
 ldx yrow
 jsr lowres_row_selected
 bne dfs_b_done
.endif
dfs_b_draw:
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 txa
 cmp dirty_ymin_b
 bcs dfs_b_dirty_ymin_ok
 sta dirty_ymin_b
dfs_b_dirty_ymin_ok:
 txa
 cmp dirty_ymax_b
 bcc dfs_b_dirty_ymax_ok
 sta dirty_ymax_b
dfs_b_dirty_ymax_ok:
.endif
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_b
.else
 jsr apply_material_span_b
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_b,x
 bcs dfs_b_dirty_min_ok
 sta dirtymin_b,x
dfs_b_dirty_min_ok:
 lda endbyte
 cmp dirtymax_b,x
 bcc dfs_b_dirty_done
 sta dirtymax_b,x
dfs_b_dirty_done:
.endif
 jmp direct_fill_span_pixels
dfs_b_done:
 rts

direct_fill_span_pixels:
 ldy #$00
 lda startbyte
 cmp endbyte
 bne dfsp_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
 cmp #$ff
 bne dfsp_single_partial
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 rts
dfsp_single_partial:
.endif
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 rts
dfsp_multi:
.if INDEXED_OFFSET_SPAN_FILL != 0
 lda endbyte
 sec
 sbc startbyte
 cmp #$20
 bcs dfsp_multi_pointer
 sta fullcount
 ldy #$00
 ldx leftval
 lda startmask,x
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
 cmp #$ff
 bne dfsp_indexed_left_partial
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp dfsp_indexed_left_done
dfsp_indexed_left_partial:
.endif
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
dfsp_indexed_left_done:
.endif
 lda fullcount
 cmp #$01
 beq dfsp_indexed_end_at_08
 sec
 sbc #$01
 sta p1hi
 lda fillbyte
 ldy #$08
dfsp_indexed_mid_loop:
 sta (ptr0lo),y
 sta (ptr1lo),y
 tya
 clc
 adc #$08
 tay
 lda fillbyte
 dec p1hi
 bne dfsp_indexed_mid_loop
 jmp dfsp_indexed_draw_end_y
dfsp_indexed_end_at_08:
 ldy #$08
dfsp_indexed_draw_end_y:
 ldx rightval
 lda endmask,x
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
 cmp #$ff
 bne dfsp_indexed_end_partial
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 rts
dfsp_indexed_end_partial:
.endif
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 rts
dfsp_multi_pointer:
 ldy #$00
.endif
 ldx leftval
 lda startmask,x
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
 cmp #$ff
 bne dfsp_pointer_left_partial
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp dfsp_pointer_left_done
dfsp_pointer_left_partial:
.endif
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
dfsp_pointer_left_done:
.endif
 lda endbyte
 sec
 sbc startbyte
 sta fullcount
dfsp_next_byte:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc dfsp_next0_ok
 inc ptr0hi
dfsp_next0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc dfsp_next1_ok
 inc ptr1hi
dfsp_next1_ok:
 dec fullcount
 beq dfsp_draw_end
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp dfsp_next_byte
dfsp_draw_end:
 ldx rightval
 lda endmask,x
.if ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE != 0
 cmp #$ff
 bne dfsp_pointer_end_partial
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 rts
dfsp_pointer_end_partial:
.endif
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 rts

dft_x0: .byte 0
dft_y0: .byte 0
dft_x1: .byte 0
dft_y1: .byte 0
dft_x2: .byte 0
dft_y2: .byte 0
dft_lx: .byte 0
dft_lendy: .byte 0
dft_ldx: .byte 0
dft_ldy: .byte 0
dft_lsx: .byte 0
dft_ltype: .byte 0
dft_lerrlo: .byte 0
dft_lerrhi: .byte 0
dft_sx: .byte 0
dft_sendy: .byte 0
dft_sdx: .byte 0
dft_sdy: .byte 0
dft_ssx: .byte 0
dft_stype: .byte 0
dft_serrlo: .byte 0
dft_serrhi: .byte 0
dft_lmin: .byte 0
dft_lmax: .byte 0
dft_smin: .byte 0
dft_smax: .byte 0
dft_split_min: .byte 0
dft_split_max: .byte 0
dft_short_phase: .byte 0
dft_save_vx1: .byte 0
dft_save_vy1: .byte 0
dft_save_vx2: .byte 0
dft_save_vy2: .byte 0
.if ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL != 0
qf_x: .byte 0,0,0,0
qf_y: .byte 0,0,0,0
qf_top_idx: .byte 0
qf_ymax: .byte 0
qf_a_idx: .byte 0
qf_a_step: .byte 0
qf_b_idx: .byte 0
qf_b_step: .byte 0
qf_work_idx: .byte 0
qf_work_step: .byte 0
qf_hops: .byte 0
qf_save_min: .byte 0
qf_save_max: .byte 0
.endif
.endif

build_loaded_face_bounds:
 jmp build_loaded_face_bounds_convex

build_loaded_face_bounds_convex:
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 jmp build_loaded_face_bounds_xyq2
.endif
 jsr setup_face_y_bounds
.if LAZY_CONVEX_BOUNDS != 0
 inc bounds_stamp_cur
 bne bltc_lazy_ready
 jsr clear_bounds_stamp
 inc bounds_stamp_cur
bltc_lazy_ready:
 jmp bltc_init_done
.endif
 ldx face_ymin
 lda #$ff
bltc_init_loop:
 sta leftb,x
 lda #$00
 sta rightb,x
 lda #$ff
 cpx face_ymax
 beq bltc_init_done
 inx
 jmp bltc_init_loop
bltc_init_done:
 lda vx0
 sta ex0
 lda vy0
 sta ey0
 lda vx1
 sta ex1
 lda vy1
 sta ey1
 jsr trace_edge_convex
 lda vx1
 sta ex0
 lda vy1
 sta ey0
 lda vx2
 sta ex1
 lda vy2
 sta ey1
 jsr trace_edge_convex
 lda vx2
 sta ex0
 lda vy2
 sta ey0
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne blfc_trace_2_to_0
.endif
 lda vx3
 sta ex1
 lda vy3
 sta ey1
 jsr trace_edge_convex
 lda vx3
 sta ex0
 lda vy3
 sta ey0
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
 rts
.if HAS_TRI_FACES != 0
blfc_trace_2_to_0:
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr trace_edge_convex
 rts
.endif
.endif

.if MODE5_POLYGON_OUTLINE != 0 && MEMORY_LAYOUT_HIGH_BASIC_V2 = 0
; Stable Mode 5 keeps its connected edge walker in the documented free RAM
; between screen B ($8c00-$8fff) and bitmap B ($a000-$bfff).  The $9100
; base preserves a full 256-byte guard above screen B; $9f00 is the exclusive
; limit and preserves another 256-byte guard below bitmap B.
mode5_stable_low_return = *
* = $9100
mode5_stable_code_start = *
.endif

.if MODE5_POLYGON_OUTLINE != 0
; Walk only the already prepared face perimeter.  The clipped path consumes
; every clip_a edge, including generated near/screen caps.
mode5_draw_loaded_polygon_outline:
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 lda xyq2_face_valid
 beq mode5_outline_done
.endif
 inc mode5_outline_trace_active
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 beq mode5_outline_projected
 lda clip_a_count
 sec
 sbc #$01
 sta clip_prev_idx
 lda #$00
 sta clip_cur_idx
mode5_outline_clip_loop:
 ldx clip_prev_idx
 lda clip_a_x,x
 sta ex0
 lda clip_a_y,x
 sta ey0
 ldx clip_cur_idx
 lda clip_a_x,x
 sta ex1
 lda clip_a_y,x
 sta ey1
 jsr mode5_trace_background_edge
 lda clip_cur_idx
 sta clip_prev_idx
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne mode5_outline_clip_loop
 jmp mode5_outline_finish
mode5_outline_projected:
.endif
 ldx #$00
mode5_outline_first_edges:
 lda vx0,x
 sta ex0
 lda vy0,x
 sta ey0
 lda vx1,x
 sta ex1
 lda vy1,x
 sta ey1
 txa
 pha
 jsr mode5_trace_background_edge
 pla
 tax
 inx
 inx
 cpx #$04
 bne mode5_outline_first_edges
 lda vx2
 sta ex0
 lda vy2
 sta ey0
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne mode5_outline_close
.endif
 lda vx3
 sta ex1
 lda vy3
 sta ey1
 jsr mode5_trace_background_edge
 lda vx3
 sta ex0
 lda vy3
 sta ey0
mode5_outline_close:
 lda vx0
 sta ex1
 lda vy0
 sta ey1
 jsr mode5_trace_background_edge
mode5_outline_finish:
 dec mode5_outline_trace_active
mode5_outline_done:
 rts

; Reuse the renderer's connected Bresenham kernel.  The active byte redirects
; each generated point to the Mode 5 background-pixel writer while ordinary
; bounds construction continues through the unchanged path.
mode5_trace_background_edge = trace_edge_convex

mode5_trace_background_horizontal:
 lda ex0
 sta xcur
mode5_horizontal_loop:
 ldx ey0
 lda xcur
 jsr update_convex_bounds
 lda xcur
 cmp ex1
 beq mode5_horizontal_done
 bcc mode5_horizontal_inc
 dec xcur
 jmp mode5_horizontal_loop
mode5_horizontal_inc:
 inc xcur
 jmp mode5_horizontal_loop
mode5_horizontal_done:
 rts

; A zero multicolor bitmap pair selects the VIC-II background register $d021,
; initialized from WORLD_BACKGROUND_COLOR.  No C64 palette index is hardcoded.
mode5_plot_background_point:
 ; load_face_y and clip_a guarantee 0..PROJ_SCREEN_MAX endpoints before fill.
 ; Rechecking here would be a redundant second line clip.
 lda drawbuf
 bne mode5_plot_buffer_b
 ldx rightval
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 jmp mode5_plot_rows_ready
mode5_plot_buffer_b:
 ldx rightval
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
mode5_plot_rows_ready:
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda startmask,x
 and endmask,x
 eor #$ff
 sta maskv
 ldy #$00
 lda (ptr0lo),y
 and maskv
 sta (ptr0lo),y
 iny
 lda (ptr0lo),y
 and maskv
 sta (ptr0lo),y
mode5_plot_done:
 rts
.endif

update_convex_bounds:
.if MODE5_POLYGON_OUTLINE != 0
 stx rightval
 sta leftval
 lda mode5_outline_trace_active
 beq ucb_mode5_bounds
 jmp mode5_plot_background_point
ucb_mode5_bounds:
 lda leftval
 ldx rightval
.endif
.if ENGINE_MODE1_WIRE_POINT_DIRECT_ENTRY != 0
 ; Engine mode 1 endpoints are already in-range before tracing.
 ; Fall through directly into plot_wire_point and return to the trace loop.
 stx rightval
 sta leftval
.else
.if WIRE_RENDER_ENABLE != 0
 stx rightval
 sta leftval
.if POLY_FILL_ENABLE = 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq ucb_bounds
 jmp plot_wire_point
ucb_bounds:
 lda leftval
 ldx rightval
.else
 jmp plot_wire_point
.endif
.else
 lda wire_trace_active
 beq ucb_bounds
 jmp plot_wire_point
ucb_bounds:
 lda leftval
 ldx rightval
.endif
.endif
.if LAZY_CONVEX_BOUNDS != 0 && WIRE_RENDER_ENABLE = 0
 sta leftval
 stx rightval
 lda bounds_stamp,x
 cmp bounds_stamp_cur
 beq ucb_lazy_seen
 lda bounds_stamp_cur
 sta bounds_stamp,x
 lda leftval
 sta leftb,x
 sta rightb,x
 rts
ucb_lazy_seen:
 lda leftval
 ldx rightval
.endif
 cmp leftb,x
 bcs ucb_left_ok
 sta leftb,x
ucb_left_ok:
 cmp rightb,x
 bcc ucb_done
 sta rightb,x
ucb_done:
 rts
.endif

.if WIRE_RENDER_ENABLE != 0
plot_wire_point:
.if WORLD_GROUND_WIRE_OCCLUDE != 0
 lda world_ground_horizon_mask_active
 beq pwp_normal
 jmp world_ground_mask_plot_point
pwp_normal:
.endif
.if ENGINE_MODE1_WIRE_POINT_BOUNDS_STRIPPED = 0 && ENGINE_MODE2_WIRE_POINT_BOUNDS_STRIPPED = 0
 ldx rightval
 cpx #(PROJ_SCREEN_MAX_Y + 1)
 bcs pwp_done
 ldx leftval
 cpx #(PROJ_SCREEN_MAX_X + 1)
 bcs pwp_done
.else
 ; Bounds are guaranteed by the edge fast path or clip fallback.
 ; Keep X on the horizontal coordinate for the dirty/material hot path.
 ldx leftval
.endif
.if TRACK_DIRTY_SPANS != 0
 lda xbyte,x
 sta startbyte
.if ENGINE_WIRE_DIRTY_SAME_BYTE_SKIP != 0
 lda drawbuf
 cmp engine_wire_last_dirty_buf
 bne pwp_dirty_transition_miss
 lda rightval
 cmp engine_wire_last_dirty_y
 bne pwp_dirty_transition_miss
 lda startbyte
 cmp engine_wire_last_dirty_x
 beq pwp_dirty_done
pwp_dirty_transition_miss:
 lda drawbuf
 sta engine_wire_last_dirty_buf
 lda rightval
 sta engine_wire_last_dirty_y
 lda startbyte
 sta engine_wire_last_dirty_x
.endif
 ldx rightval
 lda drawbuf
 bne pwp_dirty_b
 txa
 cmp dirty_ymin_a
 bcs pwp_dirty_a_ymin_ok
 sta dirty_ymin_a
pwp_dirty_a_ymin_ok:
 txa
 cmp dirty_ymax_a
 bcc pwp_dirty_a_span
 sta dirty_ymax_a
pwp_dirty_a_span:
 lda startbyte
 cmp dirtymin_a,x
 bcs pwp_dirty_a_min_ok
 sta dirtymin_a,x
pwp_dirty_a_min_ok:
 lda startbyte
 cmp dirtymax_a,x
 bcc pwp_dirty_done
 sta dirtymax_a,x
 jmp pwp_dirty_done
pwp_dirty_b:
 txa
 cmp dirty_ymin_b
 bcs pwp_dirty_b_ymin_ok
 sta dirty_ymin_b
pwp_dirty_b_ymin_ok:
 txa
 cmp dirty_ymax_b
 bcc pwp_dirty_b_span
 sta dirty_ymax_b
pwp_dirty_b_span:
 lda startbyte
 cmp dirtymin_b,x
 bcs pwp_dirty_b_min_ok
 sta dirtymin_b,x
pwp_dirty_b_min_ok:
 lda startbyte
 cmp dirtymax_b,x
 bcc pwp_dirty_done
 sta dirtymax_b,x
pwp_dirty_done:
.endif
 ldx rightval
 lda drawbuf
 bne pwp_buffer_b
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jmp pwp_rows_ready
pwp_buffer_b:
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
pwp_rows_ready:
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 lda startmask,x
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 ldy #$00
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0 || ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE != 0
.if ENGINE_WIRE_MATERIAL_CALL_ON_CELL_CHANGE != 0 && ENGINE_WIRE_CELL_WRITE_SKIP_SAME != 0 && ENGINE_WIRE_EDGE_MATERIAL_CONTEXT != 0 && VIC_COLOR_POLICY_ENABLE = 0
 lda drawbuf
 cmp engine_wire_last_cell_buf
 bne pwp_material_transition_miss
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 ldx rightval
 lda viewport_cellrow_id,x
.else
 lda rightval
.if ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE != 0 || ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE != 0
 and #$fc
.endif
.endif
 cmp engine_wire_last_cell_y
 bne pwp_material_transition_miss
 lda startbyte
 cmp engine_wire_last_cell_x
 beq pwp_done
pwp_material_transition_miss:
 lda drawbuf
 sta engine_wire_last_cell_buf
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 ldx rightval
 lda viewport_cellrow_id,x
.else
 lda rightval
.if ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE != 0 || ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE != 0
 and #$fc
.endif
.endif
 sta engine_wire_last_cell_y
 lda startbyte
 sta engine_wire_last_cell_x
 jsr plot_wire_material_write
.else
 jsr plot_wire_material
.endif
.endif
pwp_done:
 rts

.if ENGINE_WIRE_CELL_WRITE_SKIP_SAME != 0
engine_wire_reset_material_cell_cache:
 lda #$ff
 sta engine_wire_last_cell_x
 sta engine_wire_last_cell_y
 sta engine_wire_last_cell_buf
.if ENGINE_WIRE_TRANSITION_CACHE_RESET_FRAME != 0
 sta engine_wire_last_dirty_x
 sta engine_wire_last_dirty_y
 sta engine_wire_last_dirty_buf
.endif
.if ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = 0
 sta engine_wire_last_screen
 sta engine_wire_last_color
.endif
 rts

.if ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE != 0
engine_wire_invalidate_material_cell_cache:
 lda #$ff
 sta engine_wire_last_cell_buf
 rts
.endif
.endif

.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0 || ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE != 0
plot_wire_material:
.if ENGINE_WIRE_CELL_WRITE_SKIP_SAME != 0 && VIC_COLOR_POLICY_ENABLE = 0
 lda drawbuf
 cmp engine_wire_last_cell_buf
 bne pwm_cache_miss
 .if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 ldx rightval
 lda viewport_cellrow_id,x
.else
 lda rightval
.if ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE != 0 || ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE != 0
 and #$fc
.endif
.endif
 cmp engine_wire_last_cell_y
 bne pwm_cache_miss
.if ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE != 0 || ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE != 0
 lda startbyte
.else
 ldx leftval
 lda xbyte,x
.endif
 cmp engine_wire_last_cell_x
 bne pwm_cache_miss
.if ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = 0
 lda material_screen_cur
 cmp engine_wire_last_screen
 bne pwm_cache_miss
 lda material_color_cur
 cmp engine_wire_last_color
 bne pwm_cache_miss
.endif
 rts
pwm_cache_miss:
 lda drawbuf
 sta engine_wire_last_cell_buf
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 ldx rightval
 lda viewport_cellrow_id,x
.else
 lda rightval
.if ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE != 0 || ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE != 0
 and #$fc
.endif
.endif
 sta engine_wire_last_cell_y
.if ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE != 0 || ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE != 0
 lda startbyte
.else
 ldx leftval
 lda xbyte,x
.endif
 sta engine_wire_last_cell_x
.if ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = 0
 lda material_screen_cur
 sta engine_wire_last_screen
 lda material_color_cur
 sta engine_wire_last_color
.endif
.endif
plot_wire_material_write:
 ldx rightval
 lda drawbuf
 bne pwm_buffer_b
 lda screenrowlo_a,x
 sta ptr0lo
 lda screenrowhi_a,x
 sta ptr0hi
 jmp pwm_screen_ready
pwm_buffer_b:
 lda screenrowlo_b,x
 sta ptr0lo
 lda screenrowhi_b,x
 sta ptr0hi
pwm_screen_ready:
 lda colorrowlo,x
 sta ptr1lo
 lda colorrowhi,x
 sta ptr1hi
.if ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE != 0 || ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE != 0
 lda startbyte
.else
 ldx leftval
 lda xbyte,x
.endif
 clc
 adc ptr0lo
 sta ptr0lo
 lda ptr0hi
 adc #$00
 sta ptr0hi
.if ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE != 0 || ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE != 0
 lda startbyte
.else
 ldx leftval
 lda xbyte,x
.endif
 clc
 adc ptr1lo
 sta ptr1lo
 lda ptr1hi
 adc #$00
 sta ptr1hi
.if VIC_COLOR_POLICY_ENABLE != 0
 lda #$02
 sta vic_color_source
 lda rightval
 sta yrow
 ldx leftval
 lda xbyte,x
 tax
 jsr vic_color_policy_claim_cell
 lda #$01
 sta vic_color_source
 bcc pwm_done
.endif
 ldy #$00
 lda material_screen_cur
 sta (ptr0lo),y
 lda material_color_cur
 sta (ptr1lo),y
pwm_done:
 rts
.endif

plot_wire_horizontal:
 lda ey0
 sta rightval
 lda ex0
 cmp ex1
 bcc pwh_ordered
 beq pwh_single
 lda ex1
 sta leftval
 lda ex0
 sta face_ymax
 jmp pwh_span
pwh_ordered:
 lda ex0
 sta leftval
 lda ex1
 sta face_ymax
 jmp pwh_span
pwh_single:
 sta leftval
 jmp plot_wire_point
pwh_span:
 ldx rightval
 stx yrow
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx face_ymax
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0 || ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE != 0
.if VIC_COLOR_POLICY_ENABLE != 0
 lda #$02
 sta vic_color_source
.endif
 lda drawbuf
 bne pwh_material_b
 jsr apply_material_span_a
 jmp pwh_material_done
pwh_material_b:
 jsr apply_material_span_b
pwh_material_done:
.if VIC_COLOR_POLICY_ENABLE != 0
 lda #$01
 sta vic_color_source
.endif
.endif
.if TRACK_DIRTY_SPANS != 0
 ldx yrow
 lda drawbuf
 bne pwh_dirty_b
 txa
 cmp dirty_ymin_a
 bcs pwh_dirty_a_ymin_ok
 sta dirty_ymin_a
pwh_dirty_a_ymin_ok:
 txa
 cmp dirty_ymax_a
 bcc pwh_dirty_a_span
 sta dirty_ymax_a
pwh_dirty_a_span:
 lda startbyte
 cmp dirtymin_a,x
 bcs pwh_dirty_a_min_ok
 sta dirtymin_a,x
pwh_dirty_a_min_ok:
 lda endbyte
 cmp dirtymax_a,x
 bcc pwh_dirty_done
 sta dirtymax_a,x
 jmp pwh_dirty_done
pwh_dirty_b:
 txa
 cmp dirty_ymin_b
 bcs pwh_dirty_b_ymin_ok
 sta dirty_ymin_b
pwh_dirty_b_ymin_ok:
 txa
 cmp dirty_ymax_b
 bcc pwh_dirty_b_span
 sta dirty_ymax_b
pwh_dirty_b_span:
 lda startbyte
 cmp dirtymin_b,x
 bcs pwh_dirty_b_min_ok
 sta dirtymin_b,x
pwh_dirty_b_min_ok:
 lda endbyte
 cmp dirtymax_b,x
 bcc pwh_dirty_done
 sta dirtymax_b,x
pwh_dirty_done:
.endif
 ldx yrow
 lda drawbuf
 bne pwh_buffer_b
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jmp pwh_rows_ready
pwh_buffer_b:
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
pwh_rows_ready:
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldy #$00
 lda startbyte
 cmp endbyte
 bne pwh_multi
 ldx leftval
 lda startmask,x
 ldx face_ymax
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 rts
pwh_multi:
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 sta fullcount
pwh_next_byte:
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc pwh_next0_ok
 inc ptr0hi
pwh_next0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc pwh_next1_ok
 inc ptr1hi
pwh_next1_ok:
 dec fullcount
 beq pwh_draw_end
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 jmp pwh_next_byte
pwh_draw_end:
 ldx face_ymax
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 rts
.endif

.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
; Draw an inclusive same-column run. Inputs: leftval=x, rightval=y0, face_ymax=y1.
; The endpoint registers ex0/ex1/ey0/ey1 and the steep tracer target in fullcount are preserved.
plot_wire_vertical_run:
 ldx leftval
 lda xbyte,x
 sta startbyte
 lda startmask,x
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda rightval
 sta ycur
 lda #$ff
 sta spanh
.if TRACK_DIRTY_SPANS != 0
 lda drawbuf
 bne pvwr_dirty_global_b
 lda rightval
 cmp dirty_ymin_a
 bcs pvwr_dirty_a_ymin_ok
 sta dirty_ymin_a
pvwr_dirty_a_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_a
 bcc pvwr_loop
 sta dirty_ymax_a
 jmp pvwr_loop
pvwr_dirty_global_b:
 lda rightval
 cmp dirty_ymin_b
 bcs pvwr_dirty_b_ymin_ok
 sta dirty_ymin_b
pvwr_dirty_b_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_b
 bcc pvwr_loop
 sta dirty_ymax_b
.endif
pvwr_loop:
 lda ycur
 sta rightval
.if TRACK_DIRTY_SPANS != 0
 ldx ycur
 lda drawbuf
 bne pvwr_dirty_b
 lda startbyte
 cmp dirtymin_a,x
 bcs pvwr_dirty_a_min_ok
 sta dirtymin_a,x
pvwr_dirty_a_min_ok:
 lda startbyte
 cmp dirtymax_a,x
 bcc pvwr_dirty_done
 sta dirtymax_a,x
 jmp pvwr_dirty_done
pvwr_dirty_b:
 lda startbyte
 cmp dirtymin_b,x
 bcs pvwr_dirty_b_min_ok
 sta dirtymin_b,x
pvwr_dirty_b_min_ok:
 lda startbyte
 cmp dirtymax_b,x
 bcc pvwr_dirty_done
 sta dirtymax_b,x
pvwr_dirty_done:
.endif
 ldx ycur
 lda drawbuf
 bne pvwr_buffer_b
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jmp pvwr_rows_ready
pvwr_buffer_b:
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
pvwr_rows_ready:
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldy #$00
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0 || ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE != 0
.if ENGINE_CAMERA_VIEWPORT_SMALL != 0
 ldx rightval
 lda viewport_cellrow_id,x
.else
 lda rightval
 and #$fc
.endif
 cmp spanh
 beq pvwr_material_done
 sta spanh
 jsr plot_wire_material
pvwr_material_done:
.endif
 lda ycur
 cmp face_ymax
 beq pvwr_done
 inc ycur
 jmp pvwr_loop
pvwr_done:
 rts
.endif

.if MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0 && GRAPHICS_MODE != $04 && GRAPHICS_MODE != $05
mode3_high_basic_relocated_code_end = *
.if mode3_high_basic_relocated_code_end > $a000
 .error "Mode 3 relocated full raster overlaps the high code segment"
.endif
* = $a000
mode3_high_basic_high_code_start = *
.endif
trace_edge_convex:
 lda ey0
 cmp ey1
 bcc tec_ordered
 bne tec_descending
 jmp tec_horizontal
tec_descending:
 sec
 lda ey0
 sbc ey1
 sta dyval
 lda ex0
 cmp ex1
 bcs tec_ldx_pos
 sec
 lda ex1
 sbc ex0
 sta dxabs
 lda #$ff
 sta sxstep
 jmp tec_ldx_done
tec_ldx_pos:
 sec
 lda ex0
 sbc ex1
 sta dxabs
 beq tec_lvertical
 lda #$01
 sta sxstep
tec_ldx_done:
 lda dxabs
 cmp dyval
 beq tec_ldiagonal
 lda ex1
 sta xcur
 lda ey1
 sta ycur
 lda #$00
 sta errlo
 sta errhi
.if ENGINE_MODE3_FAST_BOUNDS_TRACE != 0 || ENGINE_MODE4_FAST_BOUNDS_TRACE != 0
 ; err is always below dy. dx+dy<=256 therefore guarantees err+dx<=255.
 ; The only larger viewport combinations retain the validated 16-bit walker.
 clc
 lda dxabs
 adc dyval
 bcc sm3_fbt_l_dispatch
 beq sm3_fbt_l_dispatch
 jmp sm3_fbt_l_fallback16
sm3_fbt_l_dispatch:
 lda ey0
 sta fullcount
 lda sxstep
 bpl sm3_fbt_l_pos_dispatch
 jmp sm3_fbt_span_neg
sm3_fbt_l_pos_dispatch:
 jmp sm3_fbt_span_pos
sm3_fbt_l_fallback16:
.endif
.if ENGINE_WIRE_RASTER_CONSOLIDATION != 0
 ; Single gate for hidden-wire draw versus bounds/mask traces.
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_lconsolidated_trace_fallback
.endif
 ; One classifier: dx>dy -> scanline-run; dy>=2*dx -> vertical-run; otherwise Bresenham 8 bit.
 lda dxabs
 cmp dyval
 bcs tec_lconsolidated_scanline
 asl
 bcs tec_lconsolidated_trace_fallback
 cmp dyval
 bcc tec_lconsolidated_steep
 beq tec_lconsolidated_steep
 jmp tec_lconsolidated_bres8
tec_lconsolidated_scanline:
 lda sxstep
 bmi tec_lspan_neg
 jmp tec_lspan_pos
tec_lconsolidated_steep:
 lda ey0
 sta fullcount
 lda sxstep
 bmi tec_steep_neg
 jmp tec_steep_pos
tec_lconsolidated_bres8:
 lda ey0
 sta fullcount
 lda sxstep
 bmi tec_bres8_neg
 jmp tec_bres8_pos
tec_lconsolidated_trace_fallback:
.else
.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
 ; Use same-column runs only for strongly steep edges (dy >= 2*dx).
 lda dxabs
 asl
 bcs tec_lsteep_point_fallback
 cmp dyval
 bcc tec_lsteep_ratio_ok
 beq tec_lsteep_ratio_ok
 jmp tec_lsteep_point_fallback
tec_lsteep_ratio_ok:
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_lsteep_point_fallback
.endif
 lda ey0
 sta fullcount
 lda sxstep
 bmi tec_steep_neg
 jmp tec_steep_pos
tec_lsteep_point_fallback:
.endif
.if ENGINE_WIRE_SCANLINE_RUN_RASTERIZER != 0
 ; A shallow edge can emit several adjacent pixels on one scanline.
 ; Group dx>dy runs; strongly steep/vertical edges may use the separate column-run path.
 lda dxabs
 cmp dyval
 bcc tec_lscanline_point_fallback
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 ; Bounds/mask traces use wire_trace_active=0 and must retain per-point bounds updates.
 lda wire_trace_active
 beq tec_lscanline_point_fallback
.endif
 lda sxstep
 bmi tec_lspan_neg
 jmp tec_lspan_pos
tec_lscanline_point_fallback:
.endif
.if ENGINE_WIRE_8BIT_BRESENHAM != 0
 ; At this point scanline-run rejected dx>=dy and vertical-run rejected dy>=2*dx.
 ; The remaining wire-only range is dx<dy<2*dx, safe for an 8-bit error sum.
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 ; Hidden-wire bounds/mask traces keep the 16-bit fallback.
 lda wire_trace_active
 beq tec_lbres8_point_fallback
.endif
 lda ey0
 sta fullcount
 lda sxstep
 bpl tec_lbres8_pos_dispatch
 jmp tec_bres8_neg
tec_lbres8_pos_dispatch:
 jmp tec_bres8_pos
tec_lbres8_point_fallback:
.endif
.endif
.if DIRECT_CONVEX_EDGE_SPANS != 0
.if MODE5_POLYGON_OUTLINE != 0
 lda mode5_outline_trace_active
 bne tec_lspan_outline_skip
.endif
.if WIRE_RENDER_ENABLE != 0
 lda wire_trace_active
 bne tec_lspan_wire_skip
.endif
 lda sxstep
 bmi tec_lspan_neg
 jmp tec_lspan_pos
.if WIRE_RENDER_ENABLE != 0
tec_lspan_wire_skip:
.endif
.if MODE5_POLYGON_OUTLINE != 0
tec_lspan_outline_skip:
.endif
.endif
 lda sxstep
 bmi tec_lloop_neg
tec_lloop_pos:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey0
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_lstep_check_pos:
 lda errhi
 bne tec_lxstep_pos
 lda errlo
 cmp dyval
 bcc tec_lystep_pos
tec_lxstep_pos:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 inc xcur
.if FAST_FILL_BOUNDS_TRACE = 0 || WIRE_RENDER_ENABLE != 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 jmp tec_lstep_check_pos
tec_lystep_pos:
.if FAST_FILL_BOUNDS_TRACE != 0 && WIRE_RENDER_ENABLE = 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 inc ycur
 jmp tec_lloop_pos
tec_lloop_neg:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey0
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_lstep_check_neg:
 lda errhi
 bne tec_lxstep_neg
 lda errlo
 cmp dyval
 bcc tec_lystep_neg
tec_lxstep_neg:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 dec xcur
.if FAST_FILL_BOUNDS_TRACE = 0 || WIRE_RENDER_ENABLE != 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 jmp tec_lstep_check_neg
tec_lystep_neg:
.if FAST_FILL_BOUNDS_TRACE != 0 && WIRE_RENDER_ENABLE = 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 inc ycur
 jmp tec_lloop_neg
tec_lvertical:
.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_lvertical_point_fallback
.endif
 lda ex1
 sta leftval
 lda ey1
 sta rightval
 lda ey0
 sta face_ymax
 jmp plot_wire_vertical_run
tec_lvertical_point_fallback:
.endif
 lda ey1
 sta ycur
tec_lv_loop:
 ldx ycur
 lda ex1
 jsr update_convex_bounds
 lda ycur
 cmp ey0
 beq tec_done
 inc ycur
 jmp tec_lv_loop
tec_ldiagonal:
 lda ex1
 sta xcur
 lda ey1
 sta ycur
 lda sxstep
 bmi tec_ld_loop_neg
tec_ld_loop_pos:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey0
 beq tec_done
 inc xcur
 inc ycur
 jmp tec_ld_loop_pos
tec_ld_loop_neg:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey0
 beq tec_done
 dec xcur
 inc ycur
 jmp tec_ld_loop_neg
tec_ordered:
 sec
 lda ey1
 sbc ey0
 sta dyval
 lda ex1
 cmp ex0
 bcs tec_rdx_pos
 sec
 lda ex0
 sbc ex1
 sta dxabs
 lda #$ff
 sta sxstep
 jmp tec_rdx_done
tec_rdx_pos:
 sec
 lda ex1
 sbc ex0
 sta dxabs
 beq tec_rvertical
 lda #$01
 sta sxstep
tec_rdx_done:
 lda dxabs
 cmp dyval
 beq tec_rdiagonal
 lda ex0
 sta xcur
 lda ey0
 sta ycur
 lda #$00
 sta errlo
 sta errhi
.if ENGINE_MODE3_FAST_BOUNDS_TRACE != 0 || ENGINE_MODE4_FAST_BOUNDS_TRACE != 0
 ; Same byte-safety contract as the descending branch.
 clc
 lda dxabs
 adc dyval
 bcc sm3_fbt_r_dispatch
 beq sm3_fbt_r_dispatch
 jmp sm3_fbt_r_fallback16
sm3_fbt_r_dispatch:
 lda ey1
 sta fullcount
 lda sxstep
 bpl sm3_fbt_r_pos_dispatch
 jmp sm3_fbt_span_neg
sm3_fbt_r_pos_dispatch:
 jmp sm3_fbt_span_pos
sm3_fbt_r_fallback16:
.endif
.if ENGINE_WIRE_RASTER_CONSOLIDATION != 0
 ; Single gate for hidden-wire draw versus bounds/mask traces.
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_rconsolidated_trace_fallback
.endif
 ; One classifier: dx>dy -> scanline-run; dy>=2*dx -> vertical-run; otherwise Bresenham 8 bit.
 lda dxabs
 cmp dyval
 bcs tec_rconsolidated_scanline
 asl
 bcs tec_rconsolidated_trace_fallback
 cmp dyval
 bcc tec_rconsolidated_steep
 beq tec_rconsolidated_steep
 jmp tec_rconsolidated_bres8
tec_rconsolidated_scanline:
 lda sxstep
 bmi tec_rspan_neg
 jmp tec_rspan_pos
tec_rconsolidated_steep:
 lda ey1
 sta fullcount
 lda sxstep
 bmi tec_steep_neg
 jmp tec_steep_pos
tec_rconsolidated_bres8:
 lda ey1
 sta fullcount
 lda sxstep
 bmi tec_bres8_neg
 jmp tec_bres8_pos
tec_rconsolidated_trace_fallback:
.else
.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
 ; Use same-column runs only for strongly steep edges (dy >= 2*dx).
 lda dxabs
 asl
 bcs tec_rsteep_point_fallback
 cmp dyval
 bcc tec_rsteep_ratio_ok
 beq tec_rsteep_ratio_ok
 jmp tec_rsteep_point_fallback
tec_rsteep_ratio_ok:
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_rsteep_point_fallback
.endif
 lda ey1
 sta fullcount
 lda sxstep
 bmi tec_steep_neg
 jmp tec_steep_pos
tec_rsteep_point_fallback:
.endif
.if ENGINE_WIRE_SCANLINE_RUN_RASTERIZER != 0
 lda dxabs
 cmp dyval
 bcc tec_rscanline_point_fallback
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_rscanline_point_fallback
.endif
 lda sxstep
 bmi tec_rspan_neg
 jmp tec_rspan_pos
tec_rscanline_point_fallback:
.endif
.if ENGINE_WIRE_8BIT_BRESENHAM != 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 ; Hidden-wire bounds/mask traces keep the 16-bit fallback.
 lda wire_trace_active
 beq tec_rbres8_point_fallback
.endif
 lda ey1
 sta fullcount
 lda sxstep
 bpl tec_rbres8_pos_dispatch
 jmp tec_bres8_neg
tec_rbres8_pos_dispatch:
 jmp tec_bres8_pos
tec_rbres8_point_fallback:
.endif
.endif
.if DIRECT_CONVEX_EDGE_SPANS != 0
.if MODE5_POLYGON_OUTLINE != 0
 lda mode5_outline_trace_active
 bne tec_rspan_outline_skip
.endif
.if WIRE_RENDER_ENABLE != 0
 lda wire_trace_active
 bne tec_rspan_wire_skip
.endif
 lda sxstep
 bmi tec_rspan_neg
 jmp tec_rspan_pos
.if WIRE_RENDER_ENABLE != 0
tec_rspan_wire_skip:
.endif
.if MODE5_POLYGON_OUTLINE != 0
tec_rspan_outline_skip:
.endif
.endif
 lda sxstep
 bmi tec_rloop_neg
tec_rloop_pos:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey1
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_rstep_check_pos:
 lda errhi
 bne tec_rxstep_pos
 lda errlo
 cmp dyval
 bcc tec_rystep_pos
tec_rxstep_pos:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 inc xcur
.if FAST_FILL_BOUNDS_TRACE = 0 || WIRE_RENDER_ENABLE != 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 jmp tec_rstep_check_pos
tec_rystep_pos:
.if FAST_FILL_BOUNDS_TRACE != 0 && WIRE_RENDER_ENABLE = 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 inc ycur
 jmp tec_rloop_pos
tec_rloop_neg:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey1
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_rstep_check_neg:
 lda errhi
 bne tec_rxstep_neg
 lda errlo
 cmp dyval
 bcc tec_rystep_neg
tec_rxstep_neg:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 dec xcur
.if FAST_FILL_BOUNDS_TRACE = 0 || WIRE_RENDER_ENABLE != 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 jmp tec_rstep_check_neg
tec_rystep_neg:
.if FAST_FILL_BOUNDS_TRACE != 0 && WIRE_RENDER_ENABLE = 0
 ldx ycur
 lda xcur
 jsr update_convex_bounds
.endif
 inc ycur
 jmp tec_rloop_neg
tec_rvertical:
.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_rvertical_point_fallback
.endif
 lda ex0
 sta leftval
 lda ey0
 sta rightval
 lda ey1
 sta face_ymax
 jmp plot_wire_vertical_run
tec_rvertical_point_fallback:
.endif
 lda ey0
 sta ycur
tec_rv_loop:
 ldx ycur
 lda ex0
 jsr update_convex_bounds
 lda ycur
 cmp ey1
 beq tec_done
 inc ycur
 jmp tec_rv_loop
tec_rdiagonal:
 lda ex0
 sta xcur
 lda ey0
 sta ycur
 lda sxstep
 bmi tec_rd_loop_neg
tec_rd_loop_pos:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey1
 beq tec_done
 inc xcur
 inc ycur
 jmp tec_rd_loop_pos
tec_rd_loop_neg:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp ey1
 beq tec_done
 dec xcur
 inc ycur
 jmp tec_rd_loop_neg
tec_done:
 rts

.if ENGINE_WIRE_8BIT_BRESENHAM != 0
; Connected 8-bit Bresenham for the intermediate y-major range dx<dy<2*dx.
; The sum err+dx is <2*dy and dy<=PROJ_SCREEN_MAX_Y, so errhi is unnecessary.
; A horizontal bridge point is emitted on x transitions to preserve the exact reference pixel set.
tec_bres8_pos:
tec_bres8_pos_loop:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp fullcount
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 cmp dyval
 bcc tec_bres8_pos_ystep
 sec
 sbc dyval
 sta errlo
 inc xcur
 ldx ycur
 lda xcur
 jsr update_convex_bounds
tec_bres8_pos_ystep:
 inc ycur
 jmp tec_bres8_pos_loop

tec_bres8_neg:
tec_bres8_neg_loop:
 ldx ycur
 lda xcur
 jsr update_convex_bounds
 lda ycur
 cmp fullcount
 beq tec_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 cmp dyval
 bcc tec_bres8_neg_ystep
 sec
 sbc dyval
 sta errlo
 dec xcur
 ldx ycur
 lda xcur
 jsr update_convex_bounds
tec_bres8_neg_ystep:
 inc ycur
 jmp tec_bres8_neg_loop
.endif

.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0
; Strongly steep lines keep one vertical run per x and use a point only for
; the horizontal bridge emitted by the original connected-edge tracer.
tec_steep_pos:
 lda ycur
 sta spanw
tec_steep_pos_loop:
 lda ycur
 cmp fullcount
 beq tec_steep_pos_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 cmp dyval
 bcc tec_steep_pos_ystep
 sec
 sbc dyval
 sta errlo
 lda xcur
 sta leftval
 lda spanw
 sta rightval
 lda ycur
 sta face_ymax
 jsr plot_wire_vertical_run
 inc xcur
 lda xcur
 sta leftval
 lda ycur
 sta rightval
 jsr plot_wire_point
 inc ycur
 lda ycur
 sta spanw
 jmp tec_steep_pos_loop
tec_steep_pos_ystep:
 inc ycur
 jmp tec_steep_pos_loop
tec_steep_pos_done:
 lda xcur
 sta leftval
 lda spanw
 sta rightval
 lda ycur
 sta face_ymax
 jmp plot_wire_vertical_run

tec_steep_neg:
 lda ycur
 sta spanw
tec_steep_neg_loop:
 lda ycur
 cmp fullcount
 beq tec_steep_neg_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 cmp dyval
 bcc tec_steep_neg_ystep
 sec
 sbc dyval
 sta errlo
 lda xcur
 sta leftval
 lda spanw
 sta rightval
 lda ycur
 sta face_ymax
 jsr plot_wire_vertical_run
 dec xcur
 lda xcur
 sta leftval
 lda ycur
 sta rightval
 jsr plot_wire_point
 inc ycur
 lda ycur
 sta spanw
 jmp tec_steep_neg_loop
tec_steep_neg_ystep:
 inc ycur
 jmp tec_steep_neg_loop
tec_steep_neg_done:
 lda xcur
 sta leftval
 lda spanw
 sta rightval
 lda ycur
 sta face_ymax
 jmp plot_wire_vertical_run
.endif

.if ENGINE_MODE3_FAST_BOUNDS_TRACE != 0 || ENGINE_MODE4_FAST_BOUNDS_TRACE != 0
; C64 fast bounds edge walker. Mode 3 uses it for fallback faces;
; Mode 4 uses it for its generic left/right bounds path.
; spanw/spanh are always ordered left/right, so both tables are updated in one call.
sm3_fbt_flush_span:
 ldx ycur
 lda spanw
 cmp leftb,x
 bcs sm3_fbt_left_ok
 sta leftb,x
sm3_fbt_left_ok:
 lda spanh
 cmp rightb,x
 bcc sm3_fbt_flush_done
 sta rightb,x
sm3_fbt_flush_done:
 rts

sm3_fbt_span_pos:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp fullcount
 beq sm3_fbt_span_pos_done
 clc
 lda errlo
 adc dxabs
 sta errlo
sm3_fbt_span_pos_check:
 cmp dyval
 bcc sm3_fbt_span_pos_y
 sec
 sbc dyval
 sta errlo
 inc xcur
 lda xcur
 sta spanh
 lda errlo
 jmp sm3_fbt_span_pos_check
sm3_fbt_span_pos_y:
 jsr sm3_fbt_flush_span
 inc ycur
 jmp sm3_fbt_span_pos
sm3_fbt_span_pos_done:
 jsr sm3_fbt_flush_span
 rts

sm3_fbt_span_neg:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp fullcount
 beq sm3_fbt_span_neg_done
 clc
 lda errlo
 adc dxabs
 sta errlo
sm3_fbt_span_neg_check:
 cmp dyval
 bcc sm3_fbt_span_neg_y
 sec
 sbc dyval
 sta errlo
 dec xcur
 lda xcur
 sta spanw
 lda errlo
 jmp sm3_fbt_span_neg_check
sm3_fbt_span_neg_y:
 jsr sm3_fbt_flush_span
 inc ycur
 jmp sm3_fbt_span_neg
sm3_fbt_span_neg_done:
 jsr sm3_fbt_flush_span
 rts
.endif

.if DIRECT_CONVEX_EDGE_SPANS != 0 || ENGINE_WIRE_SCANLINE_RUN_RASTERIZER != 0
tec_flush_span:
.if ENGINE_WIRE_SCANLINE_RUN_RASTERIZER != 0
 ; Preserve the point hot loop for one-pixel runs.
 lda spanw
 cmp spanh
 bne tfs_wire_run
 ldx ycur
 lda spanw
 jmp update_convex_bounds
tfs_wire_run:
 ; Keep ex0/ex1/ey0/ey1 unchanged: trace_edge_convex still needs the
 ; original endpoint state after this run returns.
 lda ycur
 sta rightval
 lda spanw
 sta leftval
 lda spanh
 sta face_ymax
 jmp pwh_span
.else
 ldx ycur
 lda spanw
 jsr update_convex_bounds
 lda spanh
 cmp spanw
 beq tfs_done
 ldx ycur
 lda spanh
 jsr update_convex_bounds
tfs_done:
 rts
.endif

tec_lspan_pos:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp ey0
 beq tec_lspan_pos_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_lspan_pos_check:
 lda errhi
 bne tec_lspan_pos_x
 lda errlo
 cmp dyval
 bcc tec_lspan_pos_y
tec_lspan_pos_x:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 inc xcur
 lda xcur
 sta spanh
 jmp tec_lspan_pos_check
tec_lspan_pos_y:
 jsr tec_flush_span
 inc ycur
 jmp tec_lspan_pos
tec_lspan_pos_done:
 jsr tec_flush_span
 rts

tec_lspan_neg:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp ey0
 beq tec_lspan_neg_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_lspan_neg_check:
 lda errhi
 bne tec_lspan_neg_x
 lda errlo
 cmp dyval
 bcc tec_lspan_neg_y
tec_lspan_neg_x:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 dec xcur
 lda xcur
 sta spanw
 jmp tec_lspan_neg_check
tec_lspan_neg_y:
 jsr tec_flush_span
 inc ycur
 jmp tec_lspan_neg
tec_lspan_neg_done:
 jsr tec_flush_span
 rts

tec_rspan_pos:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp ey1
 beq tec_rspan_pos_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_rspan_pos_check:
 lda errhi
 bne tec_rspan_pos_x
 lda errlo
 cmp dyval
 bcc tec_rspan_pos_y
tec_rspan_pos_x:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 inc xcur
 lda xcur
 sta spanh
 jmp tec_rspan_pos_check
tec_rspan_pos_y:
 jsr tec_flush_span
 inc ycur
 jmp tec_rspan_pos
tec_rspan_pos_done:
 jsr tec_flush_span
 rts

tec_rspan_neg:
 lda xcur
 sta spanw
 sta spanh
 lda ycur
 cmp ey1
 beq tec_rspan_neg_done
 clc
 lda errlo
 adc dxabs
 sta errlo
 lda errhi
 adc #$00
 sta errhi
tec_rspan_neg_check:
 lda errhi
 bne tec_rspan_neg_x
 lda errlo
 cmp dyval
 bcc tec_rspan_neg_y
tec_rspan_neg_x:
 sec
 lda errlo
 sbc dyval
 sta errlo
 lda errhi
 sbc #$00
 sta errhi
 dec xcur
 lda xcur
 sta spanw
 jmp tec_rspan_neg_check
tec_rspan_neg_y:
 jsr tec_flush_span
 inc ycur
 jmp tec_rspan_neg
tec_rspan_neg_done:
 jsr tec_flush_span
 rts
.endif

tec_horizontal:
.if MODE5_POLYGON_OUTLINE != 0
 lda mode5_outline_trace_active
 beq tec_horizontal_normal
 jmp mode5_trace_background_horizontal
tec_horizontal_normal:
.endif
.if WIRE_RENDER_ENABLE != 0
.if POLY_FILL_ENABLE = 0
.if HIDDEN_WIRE_ENABLE != 0 && (MODE2_FACE_BUCKET_PIPELINE != 0 || WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)
 lda wire_trace_active
 beq tec_horizontal_bounds
 jmp plot_wire_horizontal
tec_horizontal_bounds:
.else
 jmp plot_wire_horizontal
.endif
.else
 lda wire_trace_active
 beq tec_horizontal_bounds
 jmp plot_wire_horizontal
tec_horizontal_bounds:
.endif
.endif
 ldx ey0
 lda ex0
 jsr update_convex_bounds
 ldx ey0
 lda ex1
 jsr update_convex_bounds
 rts

.if MODE5_POLYGON_OUTLINE != 0 && MEMORY_LAYOUT_HIGH_BASIC_V2 = 0
mode5_stable_code_end = *
.if mode5_stable_code_start != $9100
 .error "Mode 5 stable relocated code did not start at $9100"
.endif
.if mode5_stable_code_end > $9f00
 .error "Mode 5 stable relocated code leaves less than 256 bytes before bitmap B"
.endif
* = mode5_stable_low_return
mode5_stable_low_resume = *
.endif

.if POLY_FILL_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0 || (HIDDEN_WIRE_ENABLE != 0 && (WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0))
setup_face_y_bounds:
 lda vy0
 sta face_ymin
 sta face_ymax
 lda vy1
 cmp face_ymin
 bcs sty_v1_min_ok
 sta face_ymin
sty_v1_min_ok:
 cmp face_ymax
 bcc sty_v1_max_ok
 sta face_ymax
sty_v1_max_ok:
 lda vy2
 cmp face_ymin
 bcs sty_v2_min_ok
 sta face_ymin
sty_v2_min_ok:
 cmp face_ymax
 bcc sty_v2_max_ok
 sta face_ymax
sty_v2_max_ok:
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne sty_done
.endif
 lda vy3
 cmp face_ymin
 bcs sty_v3_min_ok
 sta face_ymin
sty_v3_min_ok:
 cmp face_ymax
 bcc sty_done
 sta face_ymax
sty_done:
.if SCENE_OBJECT_COUNT != 0
 lda face_ymin
 cmp #SCENE_RENDER_MIN_Y
 bcs sty_done_rts
 lda #SCENE_RENDER_MIN_Y
 sta face_ymin
sty_done_rts:
.endif
 rts
.endif

.if POLY_FILL_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0 || (HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0)
fill_bounds_solid_a:
.if TRACK_DIRTY_SPANS != 0
 lda face_ymin
 cmp dirty_ymin_a
 bcs fbs_a_dirty_ymin_ok
 sta dirty_ymin_a
fbs_a_dirty_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_a
 bcc fbs_a_dirty_ymax_ok
 sta dirty_ymax_a
fbs_a_dirty_ymax_ok:
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
.endif
 ldx face_ymin
fbs_a_row:
.if LAZY_CONVEX_BOUNDS != 0
 lda bounds_stamp,x
 cmp bounds_stamp_cur
 bne fbs_a_next
.endif
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc fbs_a_next
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq fbs_a_draw
 jsr lowres_row_selected
 bne fbs_a_next
.endif
fbs_a_draw:
 stx yrow
fbs_a_fill_ready:
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_a
.else
 jsr apply_material_span_a
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_a,x
 bcs fbs_a_dirty_min_ok
 sta dirtymin_a,x
fbs_a_dirty_min_ok:
 lda endbyte
 cmp dirtymax_a,x
 bcc fbs_a_dirty_done
 sta dirtymax_a,x
fbs_a_dirty_done:
.endif
 ldy #$00
 lda startbyte
 cmp endbyte
 bne fbs_a_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbs_a_next_restore
fbs_a_multi:
.if INDEXED_OFFSET_SPAN_FILL != 0
 lda endbyte
 sec
 sbc startbyte
.if ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS != 0 && SPAN_KERNEL_FILL != 0
 cmp #$06
 bcc fbs_a_indexed_fallback
.endif
 cmp #$20
 bcs fbs_a_indexed_fallback
 sta fullcount
 ldy #$00
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda fullcount
 cmp #$01
 beq fbs_a_indexed_end_at_08
 sec
 sbc #$01
 sta p1hi
 lda fillbyte
 ldy #$08
fbs_a_indexed_mid_loop:
 sta (ptr0lo),y
 sta (ptr1lo),y
 tya
 clc
 adc #$08
 tay
 lda fillbyte
 dec p1hi
 bne fbs_a_indexed_mid_loop
 jmp fbs_a_indexed_draw_end_y
fbs_a_indexed_end_at_08:
 ldy #$08
fbs_a_indexed_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbs_a_next_restore
fbs_a_indexed_fallback:
 ldy #$00
.endif
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 cmp #$01
 bne fbs_a_maybe_three
fbs_a_two_byte:
.if SPAN_KERNEL_FILL != 0
 ldy #$08
 jmp fbs_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_two0_ok
 inc ptr0hi
fbs_a_two0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_two1_ok
 inc ptr1hi
fbs_a_two1_ok:
 jmp fbs_a_draw_end
.endif
fbs_a_maybe_three:
 cmp #$02
 bne fbs_a_maybe_four
fbs_a_three_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 jmp fbs_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_three0_mid_ok
 inc ptr0hi
fbs_a_three0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_three1_mid_ok
 inc ptr1hi
fbs_a_three1_mid_ok:
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_three0_end_ok
 inc ptr0hi
fbs_a_three0_end_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_three1_end_ok
 inc ptr1hi
fbs_a_three1_end_ok:
 jmp fbs_a_draw_end
.endif
fbs_a_maybe_four:
 cmp #$03
 bne fbs_a_maybe_five
fbs_a_four_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 jmp fbs_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_four0_mid_ok
 inc ptr0hi
fbs_a_four0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_four1_mid_ok
 inc ptr1hi
fbs_a_four1_mid_ok:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbs_a_four0_end_ok
 inc ptr0hi
fbs_a_four0_end_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbs_a_four1_end_ok
 inc ptr1hi
fbs_a_four1_end_ok:
 jmp fbs_a_draw_end
.endif
fbs_a_maybe_five:
 cmp #$04
 bne fbs_a_maybe_six
fbs_a_five_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 jmp fbs_a_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$20
 sta ptr0lo
 bcc fbs_a_five0_end_ok
 inc ptr0hi
fbs_a_five0_end_ok:
 clc
 lda ptr1lo
 adc #$20
 sta ptr1lo
 bcc fbs_a_five1_end_ok
 inc ptr1hi
fbs_a_five1_end_ok:
 jmp fbs_a_draw_end
.endif
fbs_a_maybe_six:
 cmp #$05
 bne fbs_a_multi_long
fbs_a_six_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$28
 jmp fbs_a_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$28
 sta ptr0lo
 bcc fbs_a_six0_end_ok
 inc ptr0hi
fbs_a_six0_end_ok:
 clc
 lda ptr1lo
 adc #$28
 sta ptr1lo
 bcc fbs_a_six1_end_ok
 inc ptr1hi
fbs_a_six1_end_ok:
 jmp fbs_a_draw_end
.endif
fbs_a_multi_long:
 sta fullcount
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_mid0_ok
 inc ptr0hi
fbs_a_mid0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_mid1_ok
 inc ptr1hi
fbs_a_mid1_ok:
 dec fullcount
 beq fbs_a_draw_end
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq fbs_a_mid_odd_check
fbs_a_mid_pair_loop:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbs_a_m0_noc
 inc ptr0hi
fbs_a_m0_noc:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbs_a_m1_noc
 inc ptr1hi
fbs_a_m1_noc:
 dec p1lo
 bne fbs_a_mid_pair_loop
fbs_a_mid_odd_check:
 lda p1hi
 beq fbs_a_draw_end
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_a_odd0_ok
 inc ptr0hi
fbs_a_odd0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_a_odd1_ok
 inc ptr1hi
fbs_a_odd1_ok:
fbs_a_draw_end:
 ldy #$00
fbs_a_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
fbs_a_next_restore:
 ldx yrow
fbs_a_next:
 cpx face_ymax
 beq fbs_a_done
 inx
 jmp fbs_a_row
fbs_a_done:
 rts

.endif
.if MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE != 0 && ($04 = GRAPHICS_MODE || GRAPHICS_MODE = $05)
mode3_high_basic_relocated_code_end = *
.if mode3_high_basic_relocated_code_end > $a000
 .error "Mode 4/5 relocated full raster overlaps the high code segment"
.endif
* = $a000
mode3_high_basic_high_code_start = *
.endif
.if POLY_FILL_ENABLE != 0 && HIDDEN_WIRE_ENABLE = 0
fill_bounds_pattern_a:
.if TRACK_DIRTY_SPANS != 0
 lda face_ymin
 cmp dirty_ymin_a
 bcs fbp_a_dirty_ymin_ok
 sta dirty_ymin_a
fbp_a_dirty_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_a
 bcc fbp_a_dirty_ymax_ok
 sta dirty_ymax_a
fbp_a_dirty_ymax_ok:
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
.endif
 ldy shadeidx
 lda shade_pattern_bytes,y
 sta p1lo
 iny
 lda shade_pattern_bytes,y
 sta p1hi
 eor p1lo
 sta pattoggle
 lda face_ymin
 and #$01
 beq fbp_a_even_start
 lda p1hi
 jmp fbp_a_store_start
fbp_a_even_start:
 lda p1lo
fbp_a_store_start:
 sta fillbyte
 ldx face_ymin
fbp_a_row:
.if LAZY_CONVEX_BOUNDS != 0
 lda bounds_stamp,x
 cmp bounds_stamp_cur
 bne fbp_a_next
.endif
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc fbp_a_next
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq fbp_a_draw
 jsr lowres_row_selected
 bne fbp_a_next
.endif
fbp_a_draw:
 stx yrow
fbp_a_fill_ready:
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_a
.else
 jsr apply_material_span_a
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_a,x
 bcs fbp_a_dirty_min_ok
 sta dirtymin_a,x
fbp_a_dirty_min_ok:
 lda endbyte
 cmp dirtymax_a,x
 bcc fbp_a_dirty_done
 sta dirtymax_a,x
fbp_a_dirty_done:
.endif
 ldy #$00
 lda startbyte
 cmp endbyte
 bne fbp_a_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbp_a_next_restore
fbp_a_multi:
.if INDEXED_OFFSET_SPAN_FILL != 0
 lda endbyte
 sec
 sbc startbyte
.if ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS != 0 && SPAN_KERNEL_FILL != 0
 cmp #$06
 bcc fbp_a_indexed_fallback
.endif
 cmp #$20
 bcs fbp_a_indexed_fallback
 sta fullcount
 ldy #$00
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda fullcount
 cmp #$01
 beq fbp_a_indexed_end_at_08
 sec
 sbc #$01
 sta p1hi
 lda fillbyte
 ldy #$08
fbp_a_indexed_mid_loop:
 sta (ptr0lo),y
 sta (ptr1lo),y
 tya
 clc
 adc #$08
 tay
 lda fillbyte
 dec p1hi
 bne fbp_a_indexed_mid_loop
 jmp fbp_a_indexed_draw_end_y
fbp_a_indexed_end_at_08:
 ldy #$08
fbp_a_indexed_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbp_a_next_restore
fbp_a_indexed_fallback:
 ldy #$00
.endif
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 cmp #$01
 bne fbp_a_maybe_three
fbp_a_two_byte:
.if SPAN_KERNEL_FILL != 0
 ldy #$08
 jmp fbp_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_two0_ok
 inc ptr0hi
fbp_a_two0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_two1_ok
 inc ptr1hi
fbp_a_two1_ok:
 jmp fbp_a_draw_end
.endif
fbp_a_maybe_three:
 cmp #$02
 bne fbp_a_maybe_four
fbp_a_three_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 jmp fbp_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_three0_mid_ok
 inc ptr0hi
fbp_a_three0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_three1_mid_ok
 inc ptr1hi
fbp_a_three1_mid_ok:
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_three0_end_ok
 inc ptr0hi
fbp_a_three0_end_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_three1_end_ok
 inc ptr1hi
fbp_a_three1_end_ok:
 jmp fbp_a_draw_end
.endif
fbp_a_maybe_four:
 cmp #$03
 bne fbp_a_maybe_five
fbp_a_four_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 jmp fbp_a_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_four0_mid_ok
 inc ptr0hi
fbp_a_four0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_four1_mid_ok
 inc ptr1hi
fbp_a_four1_mid_ok:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbp_a_four0_end_ok
 inc ptr0hi
fbp_a_four0_end_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbp_a_four1_end_ok
 inc ptr1hi
fbp_a_four1_end_ok:
 jmp fbp_a_draw_end
.endif
fbp_a_maybe_five:
 cmp #$04
 bne fbp_a_maybe_six
fbp_a_five_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 jmp fbp_a_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$20
 sta ptr0lo
 bcc fbp_a_five0_end_ok
 inc ptr0hi
fbp_a_five0_end_ok:
 clc
 lda ptr1lo
 adc #$20
 sta ptr1lo
 bcc fbp_a_five1_end_ok
 inc ptr1hi
fbp_a_five1_end_ok:
 jmp fbp_a_draw_end
.endif
fbp_a_maybe_six:
 cmp #$05
 bne fbp_a_multi_long
fbp_a_six_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$28
 jmp fbp_a_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$28
 sta ptr0lo
 bcc fbp_a_six0_end_ok
 inc ptr0hi
fbp_a_six0_end_ok:
 clc
 lda ptr1lo
 adc #$28
 sta ptr1lo
 bcc fbp_a_six1_end_ok
 inc ptr1hi
fbp_a_six1_end_ok:
 jmp fbp_a_draw_end
.endif
fbp_a_multi_long:
 sta fullcount
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_mid0_ok
 inc ptr0hi
fbp_a_mid0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_mid1_ok
 inc ptr1hi
fbp_a_mid1_ok:
 dec fullcount
 beq fbp_a_draw_end
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq fbp_a_mid_odd_check
fbp_a_mid_pair_loop:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbp_a_m0_noc
 inc ptr0hi
fbp_a_m0_noc:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbp_a_m1_noc
 inc ptr1hi
fbp_a_m1_noc:
 dec p1lo
 bne fbp_a_mid_pair_loop
fbp_a_mid_odd_check:
 lda p1hi
 beq fbp_a_draw_end
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_a_odd0_ok
 inc ptr0hi
fbp_a_odd0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_a_odd1_ok
 inc ptr1hi
fbp_a_odd1_ok:
fbp_a_draw_end:
 ldy #$00
fbp_a_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
fbp_a_next_restore:
 ldx yrow
fbp_a_next:
 cpx face_ymax
 beq fbp_a_done
 lda fillbyte
 eor pattoggle
 sta fillbyte
 inx
 jmp fbp_a_row
fbp_a_done:
 rts
.endif

.if POLY_FILL_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0 || (HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0)
fill_bounds_solid_b:
.if TRACK_DIRTY_SPANS != 0
 lda face_ymin
 cmp dirty_ymin_b
 bcs fbs_b_dirty_ymin_ok
 sta dirty_ymin_b
fbs_b_dirty_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_b
 bcc fbs_b_dirty_ymax_ok
 sta dirty_ymax_b
fbs_b_dirty_ymax_ok:
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
.endif
 ldx face_ymin
fbs_b_row:
.if LAZY_CONVEX_BOUNDS != 0
 lda bounds_stamp,x
 cmp bounds_stamp_cur
 bne fbs_b_next
.endif
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc fbs_b_next
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq fbs_b_draw
 jsr lowres_row_selected
 bne fbs_b_next
.endif
fbs_b_draw:
 stx yrow
fbs_b_fill_ready:
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_b
.else
 jsr apply_material_span_b
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_b,x
 bcs fbs_b_dirty_min_ok
 sta dirtymin_b,x
fbs_b_dirty_min_ok:
 lda endbyte
 cmp dirtymax_b,x
 bcc fbs_b_dirty_done
 sta dirtymax_b,x
fbs_b_dirty_done:
.endif
 ldy #$00
 lda startbyte
 cmp endbyte
 bne fbs_b_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbs_b_next_restore
fbs_b_multi:
.if INDEXED_OFFSET_SPAN_FILL != 0
 lda endbyte
 sec
 sbc startbyte
.if ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS != 0 && SPAN_KERNEL_FILL != 0
 cmp #$06
 bcc fbs_b_indexed_fallback
.endif
 cmp #$20
 bcs fbs_b_indexed_fallback
 sta fullcount
 ldy #$00
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda fullcount
 cmp #$01
 beq fbs_b_indexed_end_at_08
 sec
 sbc #$01
 sta p1hi
 lda fillbyte
 ldy #$08
fbs_b_indexed_mid_loop:
 sta (ptr0lo),y
 sta (ptr1lo),y
 tya
 clc
 adc #$08
 tay
 lda fillbyte
 dec p1hi
 bne fbs_b_indexed_mid_loop
 jmp fbs_b_indexed_draw_end_y
fbs_b_indexed_end_at_08:
 ldy #$08
fbs_b_indexed_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbs_b_next_restore
fbs_b_indexed_fallback:
 ldy #$00
.endif
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 cmp #$01
 bne fbs_b_maybe_three
fbs_b_two_byte:
.if SPAN_KERNEL_FILL != 0
 ldy #$08
 jmp fbs_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_two0_ok
 inc ptr0hi
fbs_b_two0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_two1_ok
 inc ptr1hi
fbs_b_two1_ok:
 jmp fbs_b_draw_end
.endif
fbs_b_maybe_three:
 cmp #$02
 bne fbs_b_maybe_four
fbs_b_three_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 jmp fbs_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_three0_mid_ok
 inc ptr0hi
fbs_b_three0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_three1_mid_ok
 inc ptr1hi
fbs_b_three1_mid_ok:
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_three0_end_ok
 inc ptr0hi
fbs_b_three0_end_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_three1_end_ok
 inc ptr1hi
fbs_b_three1_end_ok:
 jmp fbs_b_draw_end
.endif
fbs_b_maybe_four:
 cmp #$03
 bne fbs_b_maybe_five
fbs_b_four_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 jmp fbs_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_four0_mid_ok
 inc ptr0hi
fbs_b_four0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_four1_mid_ok
 inc ptr1hi
fbs_b_four1_mid_ok:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbs_b_four0_end_ok
 inc ptr0hi
fbs_b_four0_end_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbs_b_four1_end_ok
 inc ptr1hi
fbs_b_four1_end_ok:
 jmp fbs_b_draw_end
.endif
fbs_b_maybe_five:
 cmp #$04
 bne fbs_b_maybe_six
fbs_b_five_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 jmp fbs_b_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$20
 sta ptr0lo
 bcc fbs_b_five0_end_ok
 inc ptr0hi
fbs_b_five0_end_ok:
 clc
 lda ptr1lo
 adc #$20
 sta ptr1lo
 bcc fbs_b_five1_end_ok
 inc ptr1hi
fbs_b_five1_end_ok:
 jmp fbs_b_draw_end
.endif
fbs_b_maybe_six:
 cmp #$05
 bne fbs_b_multi_long
fbs_b_six_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$28
 jmp fbs_b_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$28
 sta ptr0lo
 bcc fbs_b_six0_end_ok
 inc ptr0hi
fbs_b_six0_end_ok:
 clc
 lda ptr1lo
 adc #$28
 sta ptr1lo
 bcc fbs_b_six1_end_ok
 inc ptr1hi
fbs_b_six1_end_ok:
 jmp fbs_b_draw_end
.endif
fbs_b_multi_long:
 sta fullcount
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_mid0_ok
 inc ptr0hi
fbs_b_mid0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_mid1_ok
 inc ptr1hi
fbs_b_mid1_ok:
 dec fullcount
 beq fbs_b_draw_end
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq fbs_b_mid_odd_check
fbs_b_mid_pair_loop:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbs_b_m0_noc
 inc ptr0hi
fbs_b_m0_noc:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbs_b_m1_noc
 inc ptr1hi
fbs_b_m1_noc:
 dec p1lo
 bne fbs_b_mid_pair_loop
fbs_b_mid_odd_check:
 lda p1hi
 beq fbs_b_draw_end
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbs_b_odd0_ok
 inc ptr0hi
fbs_b_odd0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbs_b_odd1_ok
 inc ptr1hi
fbs_b_odd1_ok:
fbs_b_draw_end:
 ldy #$00
fbs_b_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
fbs_b_next_restore:
 ldx yrow
fbs_b_next:
 cpx face_ymax
 beq fbs_b_done
 inx
 jmp fbs_b_row
fbs_b_done:
 rts

.endif
.if POLY_FILL_ENABLE != 0 && HIDDEN_WIRE_ENABLE = 0
fill_bounds_pattern_b:
.if TRACK_DIRTY_SPANS != 0
 lda face_ymin
 cmp dirty_ymin_b
 bcs fbp_b_dirty_ymin_ok
 sta dirty_ymin_b
fbp_b_dirty_ymin_ok:
 lda face_ymax
 cmp dirty_ymax_b
 bcc fbp_b_dirty_ymax_ok
 sta dirty_ymax_b
fbp_b_dirty_ymax_ok:
.endif
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 lda #$ff
 sta material_last_cellrow
.endif
.endif
 ldy shadeidx
 lda shade_pattern_bytes,y
 sta p1lo
 iny
 lda shade_pattern_bytes,y
 sta p1hi
 eor p1lo
 sta pattoggle
 lda face_ymin
 and #$01
 beq fbp_b_even_start
 lda p1hi
 jmp fbp_b_store_start
fbp_b_even_start:
 lda p1lo
fbp_b_store_start:
 sta fillbyte
 ldx face_ymin
fbp_b_row:
.if LAZY_CONVEX_BOUNDS != 0
 lda bounds_stamp,x
 cmp bounds_stamp_cur
 bne fbp_b_next
.endif
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc fbp_b_next
.if LOWRES_TRACE_ENABLE != 0
 lda lowres_scanline_enabled
 beq fbp_b_draw
 jsr lowres_row_selected
 bne fbp_b_next
.endif
fbp_b_draw:
 stx yrow
fbp_b_fill_ready:
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0
.if MATERIAL_CELL_SPAN_CACHE != 0
 jsr maybe_apply_material_span_b
.else
 jsr apply_material_span_b
.endif
.endif
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
 lda row1lo
 clc
 adc xofflo,x
 sta ptr1lo
 lda row1hi
 adc xoffhi,x
 sta ptr1hi
 ldx yrow
.if TRACK_DIRTY_SPANS != 0
 lda startbyte
 cmp dirtymin_b,x
 bcs fbp_b_dirty_min_ok
 sta dirtymin_b,x
fbp_b_dirty_min_ok:
 lda endbyte
 cmp dirtymax_b,x
 bcc fbp_b_dirty_done
 sta dirtymax_b,x
fbp_b_dirty_done:
.endif
 ldy #$00
 lda startbyte
 cmp endbyte
 bne fbp_b_multi
 ldx leftval
 lda startmask,x
 ldx rightval
 and endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbp_b_next_restore
fbp_b_multi:
.if INDEXED_OFFSET_SPAN_FILL != 0
 lda endbyte
 sec
 sbc startbyte
.if ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS != 0 && SPAN_KERNEL_FILL != 0
 cmp #$06
 bcc fbp_b_indexed_fallback
.endif
 cmp #$20
 bcs fbp_b_indexed_fallback
 sta fullcount
 ldy #$00
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda fullcount
 cmp #$01
 beq fbp_b_indexed_end_at_08
 sec
 sbc #$01
 sta p1hi
 lda fillbyte
 ldy #$08
fbp_b_indexed_mid_loop:
 sta (ptr0lo),y
 sta (ptr1lo),y
 tya
 clc
 adc #$08
 tay
 lda fillbyte
 dec p1hi
 bne fbp_b_indexed_mid_loop
 jmp fbp_b_indexed_draw_end_y
fbp_b_indexed_end_at_08:
 ldy #$08
fbp_b_indexed_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 jmp fbp_b_next_restore
fbp_b_indexed_fallback:
 ldy #$00
.endif
 ldx leftval
 lda startmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
 lda endbyte
 sec
 sbc startbyte
 cmp #$01
 bne fbp_b_maybe_three
fbp_b_two_byte:
.if SPAN_KERNEL_FILL != 0
 ldy #$08
 jmp fbp_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_two0_ok
 inc ptr0hi
fbp_b_two0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_two1_ok
 inc ptr1hi
fbp_b_two1_ok:
 jmp fbp_b_draw_end
.endif
fbp_b_maybe_three:
 cmp #$02
 bne fbp_b_maybe_four
fbp_b_three_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 jmp fbp_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_three0_mid_ok
 inc ptr0hi
fbp_b_three0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_three1_mid_ok
 inc ptr1hi
fbp_b_three1_mid_ok:
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_three0_end_ok
 inc ptr0hi
fbp_b_three0_end_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_three1_end_ok
 inc ptr1hi
fbp_b_three1_end_ok:
 jmp fbp_b_draw_end
.endif
fbp_b_maybe_four:
 cmp #$03
 bne fbp_b_maybe_five
fbp_b_four_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 jmp fbp_b_draw_end_y
.else
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_four0_mid_ok
 inc ptr0hi
fbp_b_four0_mid_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_four1_mid_ok
 inc ptr1hi
fbp_b_four1_mid_ok:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbp_b_four0_end_ok
 inc ptr0hi
fbp_b_four0_end_ok:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbp_b_four1_end_ok
 inc ptr1hi
fbp_b_four1_end_ok:
 jmp fbp_b_draw_end
.endif
fbp_b_maybe_five:
 cmp #$04
 bne fbp_b_maybe_six
fbp_b_five_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 jmp fbp_b_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$20
 sta ptr0lo
 bcc fbp_b_five0_end_ok
 inc ptr0hi
fbp_b_five0_end_ok:
 clc
 lda ptr1lo
 adc #$20
 sta ptr1lo
 bcc fbp_b_five1_end_ok
 inc ptr1hi
fbp_b_five1_end_ok:
 jmp fbp_b_draw_end
.endif
fbp_b_maybe_six:
 cmp #$05
 bne fbp_b_multi_long
fbp_b_six_byte:
.if SPAN_KERNEL_FILL != 0
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$28
 jmp fbp_b_draw_end_y
.else
 lda fillbyte
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$10
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$18
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$20
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$28
 sta ptr0lo
 bcc fbp_b_six0_end_ok
 inc ptr0hi
fbp_b_six0_end_ok:
 clc
 lda ptr1lo
 adc #$28
 sta ptr1lo
 bcc fbp_b_six1_end_ok
 inc ptr1hi
fbp_b_six1_end_ok:
 jmp fbp_b_draw_end
.endif
fbp_b_multi_long:
 sta fullcount
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_mid0_ok
 inc ptr0hi
fbp_b_mid0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_mid1_ok
 inc ptr1hi
fbp_b_mid1_ok:
 dec fullcount
 beq fbp_b_draw_end
 lda fullcount
 and #$01
 sta p1hi
 lda fullcount
 lsr
 sta p1lo
 beq fbp_b_mid_odd_check
fbp_b_mid_pair_loop:
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #$08
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$10
 sta ptr0lo
 bcc fbp_b_m0_noc
 inc ptr0hi
fbp_b_m0_noc:
 clc
 lda ptr1lo
 adc #$10
 sta ptr1lo
 bcc fbp_b_m1_noc
 inc ptr1hi
fbp_b_m1_noc:
 dec p1lo
 bne fbp_b_mid_pair_loop
fbp_b_mid_odd_check:
 lda p1hi
 beq fbp_b_draw_end
 ldy #$00
 lda fillbyte
 sta (ptr0lo),y
 sta (ptr1lo),y
 clc
 lda ptr0lo
 adc #$08
 sta ptr0lo
 bcc fbp_b_odd0_ok
 inc ptr0hi
fbp_b_odd0_ok:
 clc
 lda ptr1lo
 adc #$08
 sta ptr1lo
 bcc fbp_b_odd1_ok
 inc ptr1hi
fbp_b_odd1_ok:
fbp_b_draw_end:
 ldy #$00
fbp_b_draw_end_y:
 ldx rightval
 lda endmask,x
 sta maskv
 lda fillbyte
 and maskv
 sta p1lo
 lda maskv
 eor #$ff
 sta maskv
 lda (ptr0lo),y
 and maskv
 ora p1lo
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora p1lo
 sta (ptr1lo),y
fbp_b_next_restore:
 ldx yrow
fbp_b_next:
 cpx face_ymax
 beq fbp_b_done
 lda fillbyte
 eor pattoggle
 sta fillbyte
 inx
 jmp fbp_b_row
fbp_b_done:
 rts
.endif

.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0 && LOWRES_TRACE_ENABLE = 0
.if * > $5c00
 .error "High-basic-v2 middle segment overlaps video buffer A"
.endif
* = $a000
.endif
.if CAMERA_ROLL_ACTIVE != 0 && CAMERA_MOVABLE != 0
explorer_update_look_rolled:
.if CAMERA_ROLL_CONTROL != 0
 lda explorer_key_col4
 and #$90
 cmp #$90
 beq eulr_roll_released
 cmp #$00
 beq eulr_roll_released
 jsr explorer_roll_repeat_ready
 bcc eulr_prepare_axes
 lda explorer_key_col4
 and #$80
 bne eulr_roll_m
eulr_roll_n:
 clc
 lda explorer_cam_roll
 adc #EXPLORER_LOOK_STEP
 sta explorer_cam_roll
 jmp eulr_prepare_axes
eulr_roll_m:
 sec
 lda explorer_cam_roll
 sbc #EXPLORER_LOOK_STEP
 sta explorer_cam_roll
 jmp eulr_prepare_axes
eulr_roll_released:
 lda #$00
 sta explorer_roll_repeat_phase
.endif
eulr_prepare_axes:
 ldx explorer_cam_roll
 lda sintab,x
 sta t1
 txa
 clc
 adc #$40
 tax
 lda sintab,x
 sta t2
 lda #$00
 sta p1lo
 sta p1hi
 sta crosslo
 sta crosshi
 sta maskv

 lda explorer_key_col0
 and #$04
 bne eulr_yaw_released
 jsr explorer_yaw_repeat_ready
 bcc eulr_no_yaw_key
 lda explorer_key_col1
 and #$80
 beq eulr_yaw_left_key
 lda explorer_key_col6
 and #$10
 beq eulr_yaw_left_key
eulr_yaw_right_key:
 lda t2
 jsr eulr_neg_a
 jsr eulr_add_yaw_delta
 lda t1
 jsr eulr_neg_a
 jsr eulr_add_pitch_delta_from_yaw
 jmp eulr_no_yaw_key
eulr_yaw_left_key:
 lda t2
 jsr eulr_add_yaw_delta
 lda t1
 jsr eulr_add_pitch_delta_from_yaw
 jmp eulr_no_yaw_key
eulr_yaw_released:
 lda #$00
 sta explorer_yaw_repeat_phase
eulr_no_yaw_key:
 lda explorer_key_col0
 and #$80
 bne eulr_pitch_released
 jsr explorer_pitch_repeat_ready
 bcc eulr_apply_deltas
 lda explorer_key_col1
 and #$80
 beq eulr_pitch_up_key
 lda explorer_key_col6
 and #$10
 beq eulr_pitch_up_key
eulr_pitch_down_key:
 lda t1
 jsr eulr_neg_a
 jsr eulr_add_yaw_delta
 lda t2
 jsr eulr_add_pitch_delta
 jmp eulr_apply_deltas
eulr_pitch_up_key:
 lda t1
 jsr eulr_add_yaw_delta
 lda t2
 jsr eulr_neg_a
 jsr eulr_add_pitch_delta
 jmp eulr_apply_deltas
eulr_pitch_released:
 lda #$00
 sta explorer_pitch_repeat_phase
eulr_apply_deltas:
 lda p1lo
 ldx p1hi
 jsr eulr_add_yaw_acc
 lda crosslo
 ldx crosshi
 jsr eulr_add_pitch_acc
 jsr eulr_step_yaw_acc
 jmp eulr_step_pitch_acc

eulr_neg_a:
 eor #$ff
 clc
 adc #$01
 rts

eulr_add_yaw_delta:
 sta multmp
 clc
 lda p1lo
 adc multmp
 sta p1lo
 lda p1hi
 adc #$00
 sta p1hi
 lda multmp
 bpl eayd_done
 dec p1hi
eayd_done:
 rts

eulr_add_pitch_delta_from_yaw:
 sta multmp
 beq eulr_add_pitch_delta_from_yaw_restore
 lda #$01
 sta maskv
eulr_add_pitch_delta_from_yaw_restore:
 lda multmp
 jmp eulr_add_pitch_delta

eulr_add_pitch_delta:
 sta multmp
 clc
 lda crosslo
 adc multmp
 sta crosslo
 lda crosshi
 adc #$00
 sta crosshi
 lda multmp
 bpl eapd_done
 dec crosshi
eapd_done:
 rts

eulr_add_yaw_acc:
 clc
 adc explorer_look_yaw_acc_lo
 sta explorer_look_yaw_acc_lo
 txa
 adc explorer_look_yaw_acc_hi
 sta explorer_look_yaw_acc_hi
 rts

eulr_add_pitch_acc:
 clc
 adc explorer_look_pitch_acc_lo
 sta explorer_look_pitch_acc_lo
 txa
 adc explorer_look_pitch_acc_hi
 sta explorer_look_pitch_acc_hi
 rts

eulr_step_yaw_acc:
eulr_yaw_pos_check:
 lda explorer_look_yaw_acc_hi
 bmi eulr_yaw_neg_check
 bne eulr_yaw_pos_step
 lda explorer_look_yaw_acc_lo
 cmp #$40
 bcc eulr_yaw_done
eulr_yaw_pos_step:
 sec
 lda explorer_look_yaw_acc_lo
 sbc #$40
 sta explorer_look_yaw_acc_lo
 lda explorer_look_yaw_acc_hi
 sbc #$00
 sta explorer_look_yaw_acc_hi
 jsr explorer_apply_yaw_left
 jmp eulr_yaw_pos_check
eulr_yaw_neg_check:
 lda explorer_look_yaw_acc_hi
 cmp #$ff
 bne eulr_yaw_neg_step
 lda explorer_look_yaw_acc_lo
 cmp #$c1
 bcs eulr_yaw_done
eulr_yaw_neg_step:
 clc
 lda explorer_look_yaw_acc_lo
 adc #$40
 sta explorer_look_yaw_acc_lo
 lda explorer_look_yaw_acc_hi
 adc #$00
 sta explorer_look_yaw_acc_hi
 jsr explorer_apply_yaw_right
 jmp eulr_yaw_pos_check
eulr_yaw_done:
 rts

eulr_step_pitch_acc:
eulr_pitch_pos_check:
 lda explorer_look_pitch_acc_hi
 bmi eulr_pitch_neg_check
 bne eulr_pitch_pos_step
 lda explorer_look_pitch_acc_lo
 cmp #$40
 bcc eulr_pitch_done
eulr_pitch_pos_step:
 sec
 lda explorer_look_pitch_acc_lo
 sbc #$40
 sta explorer_look_pitch_acc_lo
 lda explorer_look_pitch_acc_hi
 sbc #$00
 sta explorer_look_pitch_acc_hi
 jsr explorer_apply_pitch_down
 jmp eulr_pitch_pos_check
eulr_pitch_neg_check:
 lda explorer_look_pitch_acc_hi
 cmp #$ff
 bne eulr_pitch_neg_step
 lda explorer_look_pitch_acc_lo
 cmp #$c1
 bcs eulr_pitch_done
eulr_pitch_neg_step:
 clc
 lda explorer_look_pitch_acc_lo
 adc #$40
 sta explorer_look_pitch_acc_lo
 lda explorer_look_pitch_acc_hi
 adc #$00
 sta explorer_look_pitch_acc_hi
 jsr explorer_apply_pitch_up
 jmp eulr_pitch_pos_check
eulr_pitch_done:
 rts

explorer_apply_yaw_left:
 clc
 lda explorer_cam_yaw
 adc #EXPLORER_LOOK_STEP
 sta explorer_cam_yaw
 rts
explorer_apply_yaw_right:
 sec
 lda explorer_cam_yaw
 sbc #EXPLORER_LOOK_STEP
 sta explorer_cam_yaw
 rts

explorer_apply_pitch_down:
 clc
 lda explorer_cam_pitch
 adc #EXPLORER_LOOK_STEP
 sta explorer_cam_pitch
 lda maskv
 bne explorer_apply_pitch_done
 jmp explorer_clamp_pitch
explorer_apply_pitch_up:
 sec
 lda explorer_cam_pitch
 sbc #EXPLORER_LOOK_STEP
 sta explorer_cam_pitch
 lda maskv
 bne explorer_apply_pitch_done
 jmp explorer_clamp_pitch
explorer_apply_pitch_done:
 rts

explorer_clamp_pitch:
 lda explorer_cam_pitch
 bpl ecp_pitch_positive
 cmp #EXPLORER_PITCH_NEG_MIN
 bcs ecp_done
 lda #EXPLORER_PITCH_NEG_MIN
 sta explorer_cam_pitch
 rts
ecp_pitch_positive:
 cmp #EXPLORER_PITCH_POS_LIMIT
 bcc ecp_done
 lda #EXPLORER_PITCH_POS_MAX
 sta explorer_cam_pitch
ecp_done:
 rts
.endif
mul_s6:
 sta mula
 stx mulb
 lda #$00
 sta mulsign
 lda mula
 bpl ms6_a_ok
 eor #$ff
 clc
 adc #$01
 sta mula
 lda mulsign
 eor #$80
 sta mulsign
ms6_a_ok:
 lda mulb
 bpl ms6_b_ok
 eor #$ff
 clc
 adc #$01
 sta mulb
 lda mulsign
 eor #$80
 sta mulsign
ms6_b_ok:
 lda mula
 clc
 adc mulb
 tax
 lda sqlo,x
 sta prodlo
 lda sqhi,x
 sta prodhi
 lda mula
 sec
 sbc mulb
 bcs ms6_diff_ok
 eor #$ff
 clc
 adc #$01
ms6_diff_ok:
 tax
 sec
 lda prodlo
 sbc sqlo,x
 sta prodlo
 lda prodhi
 sbc sqhi,x
 sta prodhi
 lda prodlo
 lsr
 lsr
 lsr
 lsr
 lsr
 lsr
 sta multmp
 lda prodhi
 asl
 asl
 ora multmp
 ldx mulsign
 bpl ms6_done
 eor #$ff
 clc
 adc #$01
ms6_done:
 rts

.if SCENE_OBJECT_COUNT != 0
add_s8_sat:
 sta p1lo
 txa
 sta p1hi
 clc
 lda p1lo
 adc p1hi
 sta crosslo
 lda p1lo
 eor p1hi
 bmi ass_no_overflow
 lda p1lo
 eor crosslo
 bpl ass_no_overflow
 lda p1lo
 bmi ass_neg_overflow
 lda #$7f
 rts
ass_neg_overflow:
 lda #$80
 rts
ass_no_overflow:
 lda crosslo
 rts
.endif

mul_s6_xpos_round:
 sta mula
 stx mulb
 lda #$00
 sta mulsign
 lda mula
 bpl ms6xpr_a_ok
 eor #$ff
 clc
 adc #$01
 sta mula
 lda #$80
 sta mulsign
ms6xpr_a_ok:
.if SCENE_OBJECT_COUNT != 0
 lda mulb
 bmi ms6xpr_high_scale
.endif
 lda mula
 clc
 adc mulb
 tax
 lda sqlo,x
 sta prodlo
 lda sqhi,x
 sta prodhi
 lda mula
 sec
 sbc mulb
 bcs ms6xpr_diff_ok
 eor #$ff
 clc
 adc #$01
ms6xpr_diff_ok:
 tax
 sec
 lda prodlo
 sbc sqlo,x
 sta prodlo
 lda prodhi
 sbc sqhi,x
 sta prodhi
 clc
 lda prodlo
 adc #$20
 sta prodlo
 bcc ms6xpr_round_ok
 inc prodhi
ms6xpr_round_ok:
 lda prodlo
 lsr
 lsr
 lsr
 lsr
 lsr
 lsr
 sta multmp
 lda prodhi
 asl
 asl
 ora multmp
.if SCENE_OBJECT_COUNT != 0
 cmp #$80
 bcc ms6xpr_mag_ok
 lda #$7f
ms6xpr_mag_ok:
.endif
 ldx mulsign
 bpl ms6xpr_done
 eor #$ff
 clc
 adc #$01
ms6xpr_done:
 rts

.if SCENE_OBJECT_COUNT != 0
ms6xpr_high_scale:
 lda mula
 asl
 bcs ms6xpr_high_sat
 cmp #$80
 bcs ms6xpr_high_sat
 sta multmp
 lda mulb
 cmp #$c0
 bcc ms6xpr_high_apply_sign
 clc
 lda multmp
 adc mula
 bcs ms6xpr_high_sat
 cmp #$80
 bcs ms6xpr_high_sat
 sta multmp
 lda mulb
 cmp #$e0
 bcc ms6xpr_high_apply_sign
 clc
 lda multmp
 adc mula
 bcs ms6xpr_high_sat
 cmp #$80
 bcs ms6xpr_high_sat
 sta multmp
 jmp ms6xpr_high_apply_sign
ms6xpr_high_sat:
 lda #$7f
 sta multmp
ms6xpr_high_apply_sign:
 lda multmp
 ldx mulsign
 bpl ms6xpr_high_done
 eor #$ff
 clc
 adc #$01
ms6xpr_high_done:
 rts
.endif

mul_s8_16:
 sta mula
 stx mulb
 lda #$00
 sta mulsign
 lda mula
 bpl ms8_a_ok
 eor #$ff
 clc
 adc #$01
 sta mula
 lda mulsign
 eor #$80
 sta mulsign
ms8_a_ok:
 lda mulb
 bpl ms8_b_ok
 eor #$ff
 clc
 adc #$01
 sta mulb
 lda mulsign
 eor #$80
 sta mulsign
ms8_b_ok:
 lda mula
 clc
 adc mulb
 tax
 lda sqlo,x
 sta prodlo
 lda sqhi,x
 sta prodhi
 lda mula
 sec
 sbc mulb
 bcs ms8_diff_ok
 eor #$ff
 clc
 adc #$01
ms8_diff_ok:
 tax
 sec
 lda prodlo
 sbc sqlo,x
 sta prodlo
 lda prodhi
 sbc sqhi,x
 sta prodhi
 lda mulsign
 bpl ms8_done
 sec
 lda #$00
 sbc prodlo
 sta prodlo
 lda #$00
 sbc prodhi
 sta prodhi
ms8_done:
 rts

; Mesh data is generated below by the build script.
.if ENGINE_MODE3_ADAPTIVE_SCREEN_PAIR_LAYOUT != 0
; Adaptive engine-mode3 slots: 00=background, 01=dark pigment, 10=high/folded highlight, 11=fixed ground.
.else
; Universal material slots. 00=background only, 01=dark pigment, 10=solid high pigment, 11=reflective highlight.
.endif
; Face shade fill bytes never emit slot 00: darkest shade is clamped to dark pigment.
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0
high_basic_v2_static_return = *
.if high_basic_v2_static_return < HIGH_BASIC_V2_CODE_HIGH_BASE || high_basic_v2_static_return >= HIGH_BASIC_V2_IO_BASE
 .error "High-basic-v2 high code overlaps $a000/$d000 boundary"
.endif
* = $1ec4
.endif
.if POLY_FILL_ENABLE != 0
shade_solid_bytes:
SHADE_SOLID_BYTES_DATA
shade_pattern_bytes:
SHADE_PATTERN_BYTES_DATA
shade_pattern_bytes_end:
.endif
.if RANDOM_MATERIAL_CYCLE != 0
random_material_index_table:
 .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$00,$01,$02,$03,$04,$05
random_wire_color_table:
 .byte $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$01
.endif

fps_vblank_count: .byte 0
fps_second_flag: .byte 0
.if FPS_COUNTER_ENABLE != 0 || RANDOM_MATERIAL_CYCLE != 0
fps_cur_frames: .byte 0
.endif
.if FPS_COUNTER_ENABLE != 0
fps_sum: .byte 0
fps_sample_index: .byte 0
fps_initialized: .byte 0
fps_last_value: .byte 0
fps_last_tenths: .byte 0
fps_samples: .fill 5,0
.endif
.if SCENE_RESPAWN_ACTIVE != 0 || RANDOM_MATERIAL_CYCLE != 0
scene_rng_state: .byte $5a
.endif
irq_phase: .byte 0
sim_vblank_count: .byte 0
video_standard_runtime: .byte VIDEO_STANDARD_INITIAL
video_vblanks_per_second: .byte VIDEO_VBLANKS_PER_SECOND_INITIAL
ntsc_sim_phase: .byte 0
light_pause: .byte 0
light_latch: .byte 0
light_pulse_enabled: .byte 0
rotation_pause: .byte 0
rotation_latch: .byte 0
.if CONTROL_LOWRES_KEY != 0
lowres_scanline_enabled: .byte 0
lowres_latch: .byte 0
lowres_scanline_parity: .byte 0
lowres_parity_a: .byte 0
lowres_parity_b: .byte 0
.endif
motion_z_enabled: .byte 0
return_latch: .byte 0
angx_lo: .byte 0
angx_hi: .byte 0
angy_lo: .byte 0
angy_hi: .byte 0
angz_lo: .byte 0
angz_hi: .byte 0
shade_dirty: .byte 1
material_screen_cur: .byte MATERIAL_SCREEN_BYTE
material_color_cur: .byte MATERIAL_COLOR_RAM
material_reflect_offset_cur: .byte MATERIAL_REFLECTIVITY_OFFSET
.if ENGINE_WIRE_CELL_WRITE_SKIP_SAME != 0
engine_wire_last_cell_x: .byte $ff
engine_wire_last_cell_y: .byte $ff
engine_wire_last_cell_buf: .byte $ff
.if ENGINE_WIRE_CELL_TRANSITION_UPDATES != 0
engine_wire_last_dirty_x: .byte $ff
engine_wire_last_dirty_y: .byte $ff
engine_wire_last_dirty_buf: .byte $ff
.endif
.if ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = 0
engine_wire_last_screen: .byte $ff
engine_wire_last_color: .byte $ff
.endif
.endif
.if VIC_COLOR_POLICY_ENABLE != 0
vic_color_cells_touched_lo: .byte 0
vic_color_cells_touched_hi: .byte 0
vic_color_conflict_count_lo: .byte 0
vic_color_conflict_count_hi: .byte 0
vic_color_fallback_count_lo: .byte 0
vic_color_fallback_count_hi: .byte 0
vic_color_fill_fallback_lo: .byte 0
vic_color_fill_fallback_hi: .byte 0
vic_color_wire_fallback_lo: .byte 0
vic_color_wire_fallback_hi: .byte 0
vic_color_max_colors_per_cell: .byte 0
vic_color_source: .byte 1
vic_color_saved_x: .byte 0
vic_color_owner_luma: .byte 0
; Lowres compatibility ranking, from darker to lighter perceived output.
vic_color_lowres_luma:
 .byte $00,$0f,$05,$0b,$04,$07,$03,$0d,$08,$02,$0c,$01,$06,$09,$0a,$0e
.endif
.if LAZY_CONVEX_BOUNDS != 0
bounds_stamp_cur: .byte 0
.endif
.if MATERIAL_CELL_SPAN_CACHE != 0
material_last_cellrow: .byte $ff
material_cell_min: .byte 0
material_cell_max: .byte 0
material_span_orig_start: .byte 0
material_span_orig_end: .byte 0
.endif
.if RANDOM_MATERIAL_CYCLE != 0
random_material_tick: .byte 0
.endif
.if WIRE_FACE_EDGE_ENABLE != 0
wire_edge_stamp: .byte 0
.if HIDDEN_WIRE_ENABLE = 0 && POLY_FILL_ENABLE = 0 && CAMERA_MOVABLE != 0
wire_mesh_safe_flag: .byte 0
.endif
.endif
.if WIRE_RENDER_ENABLE != 0 && (POLY_FILL_ENABLE != 0 || MODE2_FACE_BUCKET_PIPELINE != 0 || (HIDDEN_WIRE_ENABLE != 0 && (WIRE_DEPTH_SORT_ENABLE != 0 || WORLD_GROUND_WIRE_OCCLUDE != 0)))
wire_trace_active: .byte 0
.endif
.if MODE5_POLYGON_OUTLINE != 0
mode5_outline_trace_active: .byte 0
.endif
.if WORLD_GROUND_HORIZON_BBOX_OCCLUDE != 0
world_ground_saved_screen: .byte 0
world_ground_saved_color: .byte 0
.endif
.if WORLD_GROUND_WIRE_OCCLUDE != 0 || WORLD_GROUND_HORIZON_ONLY != 0
world_ground_horizon_valid: .byte 0
world_ground_horizon_mask_active: .byte 0
world_ground_saved_material_screen: .byte 0
world_ground_saved_material_color: .byte 0
world_ground_hx0: .byte 0
world_ground_hy0: .byte 0
world_ground_hx1: .byte 0
world_ground_hy1: .byte 0
.endif
.if WIRE_DEPTH_SORT_ENABLE != 0
wire_depth_entry_used: .byte 0
wire_entry_cursor: .byte 0
.endif
.if HIDDEN_WIRE_ENABLE != 0 && WIRE_DEPTH_SORT_ENABLE != 0 && POLY_FILL_ENABLE = 0 && WIRE_MESH_COUNT != 0
hidden_solid_near_bucket: .byte $ff
.endif
; LEGACY_OBJECT_SORT_STATE_BEGIN
.if WIRE_OBJECT_SORT_ENABLE != 0
wire_object_sort_remaining: .byte 0
wire_object_sort_best_obj: .byte $ff
wire_object_sort_best_lo: .byte 0
wire_object_sort_best_hi: .byte $80
wire_object_sort_cur_lo: .byte 0
wire_object_sort_cur_hi: .byte 0
.endif
; LEGACY_OBJECT_SORT_STATE_END
.if HIDDEN_WIRE_ENABLE != 0 && MODE2_FACE_BUCKET_PIPELINE = 0
hidden_save_vx0: .byte 0
hidden_save_vy0: .byte 0
hidden_save_vx1: .byte 0
hidden_save_vy1: .byte 0
hidden_save_vx2: .byte 0
hidden_save_vy2: .byte 0
.if CAMERA_MOVABLE != 0
hidden_cam_x8: .byte 0
hidden_cam_y8: .byte 0
hidden_cam_z8: .byte 0
.if SCENE_OBJECT_COUNT != 0
hidden_obj_z8: .byte 0
.endif
.endif
.endif
shade_intensity_changed: .byte 1
shade_last_meshidx: .byte $ff
shade_last_light_phase: .byte $ff
shade_last_light_intensity: .byte $ff
shade_last_reflect_offset: .byte $ff
shade_last_angx_lo: .byte $ff
shade_last_angx_hi: .byte $ff
shade_last_angy_lo: .byte $ff
shade_last_angy_hi: .byte $ff
shade_last_angz_lo: .byte $ff
shade_last_angz_hi: .byte $ff
.if FPS_OVERLAY_ENABLE != 0
fps_latch: .byte 0
fps_overlay_visible: .byte FPS_OVERLAY_ON_START
fps_digit_tens: .byte 1
fps_digit_ones: .byte 1
fps_digit_frac: .byte 1
text_header_string: .byte TEXT_HEADER_STRING_BYTES
.endif

.if CAMERA_MOVABLE != 0 || WORLD_GROUND_ENABLE != 0
explorer_cam_x_lo: .byte EXPLORER_CAMERA_X_LO
explorer_cam_x_hi: .byte EXPLORER_CAMERA_X_HI
explorer_cam_x_ext: .byte EXPLORER_CAMERA_X_EXT
explorer_cam_y_lo: .byte EXPLORER_CAMERA_Y_LO
explorer_cam_y_hi: .byte EXPLORER_CAMERA_Y_HI
explorer_cam_y_ext: .byte EXPLORER_CAMERA_Y_EXT
explorer_cam_z_lo: .byte EXPLORER_CAMERA_Z_LO
explorer_cam_z_hi: .byte EXPLORER_CAMERA_Z_HI
explorer_cam_z_ext: .byte EXPLORER_CAMERA_Z_EXT
explorer_cam_yaw: .byte EXPLORER_CAMERA_YAW
explorer_cam_pitch: .byte EXPLORER_CAMERA_PITCH
.if CAMERA_RUNTIME_CONTROLS != 0 || SCENE_TIMELINE_ENABLE != 0
explorer_yaw_repeat_phase: .byte 0
explorer_pitch_repeat_phase: .byte 0
.else
; The reset helper is assembled for movable cameras even when input is absent.
; Reuse the inactive key latch so no legacy data byte is added.
explorer_yaw_repeat_phase = space_latch
explorer_pitch_repeat_phase = space_latch
.endif
.if CAMERA_RUNTIME_CONTROLS != 0
.if CAMERA_ROLL_CONTROL != 0
explorer_roll_repeat_phase: .byte 0
.endif
.endif
.if CAMERA_ROLL_ACTIVE != 0
explorer_cam_roll: .byte EXPLORER_CAMERA_ROLL
explorer_look_yaw_acc_lo: .byte 0
explorer_look_yaw_acc_hi: .byte 0
explorer_look_pitch_acc_lo: .byte 0
explorer_look_pitch_acc_hi: .byte 0
.endif
explorer_key_col0: .byte $ff
explorer_key_col1: .byte $ff
explorer_key_col2: .byte $ff
.if CAMERA_ROLL_CONTROL != 0
explorer_key_col4: .byte $ff
.endif
explorer_key_col6: .byte $ff
explorer_key_col7: .byte $ff
.if EXPLORER_RESET_ON_SPACE != 0
explorer_camera_tick_skip: .byte 0
.endif
.if CAMERA_MODE_CYCLE != 0
explorer_runtime_mode: .byte EXPLORER_RUNTIME_MODE_INITIAL
explorer_mode_latch: .byte 0
.endif
explorer_delta_lo: .byte 0
explorer_delta_hi: .byte 0
explorer_delta_ext: .byte 0
explorer_view_x_lo: .byte 0
explorer_view_x_hi: .byte 0
explorer_view_y_lo: .byte 0
explorer_view_y_hi: .byte 0
explorer_view_z_lo: .byte 0
explorer_view_z_hi: .byte 0
explorer_rel_x_lo: .byte 0
explorer_rel_x_hi: .byte 0
explorer_rel_y_lo: .byte 0
explorer_rel_y_hi: .byte 0
.if POLY_FILL_ENABLE = 0
explorer_cached_siny: .byte 0
explorer_cached_cosy: .byte 0
explorer_cached_sinx: .byte 0
explorer_cached_cosx: .byte 0
.if CAMERA_ROLL_ACTIVE != 0
explorer_cached_sinz: .byte 0
explorer_cached_cosz: .byte 0
.endif
.endif
.endif

.if CAMERA_PLANE_CLIP_PROFILE != 0
camera_plane_bucket_ready: .byte 0
camera_plane_bucket_depth: .byte 0
; Two-byte scratch for clip projection. The source vertex cache is restored
; before returning to the ordinary face pipeline.
camera_plane_saved_sx: .byte 0
camera_plane_saved_sy: .byte 0
.endif
RUNTIME_BUFFER_BASE = $8000
sx = RUNTIME_BUFFER_BASE
sy = sx + VERT_COUNT
.if EXPLORER_SCREEN_RAW != 0
pxrawlo = sy + VERT_COUNT
pxrawhi = pxrawlo + VERT_COUNT
pyrawlo = pxrawhi + VERT_COUNT
pyrawhi = pyrawlo + VERT_COUNT
RUNTIME_AFTER_RAW = pyrawhi + VERT_COUNT
.else
RUNTIME_AFTER_RAW = sy + VERT_COUNT
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
vxrawlo = RUNTIME_AFTER_RAW
vxrawhi = vxrawlo + VERT_COUNT
vyrawlo = vxrawhi + VERT_COUNT
vyrawhi = vyrawlo + VERT_COUNT
vzrawlo = vyrawhi + VERT_COUNT
vzrawhi = vzrawlo + VERT_COUNT
RUNTIME_AFTER_NEAR = vzrawhi + VERT_COUNT
.else
RUNTIME_AFTER_NEAR = RUNTIME_AFTER_RAW
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
clip_a_xlo = RUNTIME_AFTER_NEAR
clip_a_xhi = clip_a_xlo + 12
clip_a_ylo = clip_a_xhi + 12
clip_a_yhi = clip_a_ylo + 12
clip_a_x = clip_a_yhi + 12
clip_a_y = clip_a_x + 12
.if WIRE_RENDER_ENABLE != 0
clip_a_flag = clip_a_y + 12
clip_b_xlo = clip_a_flag + 12
.else
clip_b_xlo = clip_a_y + 12
.endif
clip_b_xhi = clip_b_xlo + 12
clip_b_ylo = clip_b_xhi + 12
clip_b_yhi = clip_b_ylo + 12
clip_b_x = clip_b_yhi + 12
clip_b_y = clip_b_x + 12
.if WIRE_RENDER_ENABLE != 0
clip_b_flag = clip_b_y + 12
.endif
.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0
.if WIRE_RENDER_ENABLE != 0
clip_a_vxlo = clip_b_flag + 12
.else
clip_a_vxlo = clip_b_y + 12
.endif
clip_a_vxhi = clip_a_vxlo + 12
clip_a_vylo = clip_a_vxhi + 12
clip_a_vyhi = clip_a_vylo + 12
clip_a_vzlo = clip_a_vyhi + 12
clip_a_vzhi = clip_a_vzlo + 12
clip_b_vxlo = clip_a_vzhi + 12
clip_b_vxhi = clip_b_vxlo + 12
clip_b_vylo = clip_b_vxhi + 12
clip_b_vyhi = clip_b_vylo + 12
clip_b_vzlo = clip_b_vyhi + 12
clip_b_vzhi = clip_b_vzlo + 12
RUNTIME_AFTER_CLIP_VERTEX = clip_b_vzhi + 12
.else
.if WIRE_RENDER_ENABLE != 0
RUNTIME_AFTER_CLIP_VERTEX = clip_b_flag + 12
.else
RUNTIME_AFTER_CLIP_VERTEX = clip_b_y + 12
.endif
.endif
clip_raw_in_lo = RUNTIME_AFTER_CLIP_VERTEX
clip_raw_in_hi = clip_raw_in_lo + 1
clip_raw_out_lo = clip_raw_in_hi + 1
clip_raw_out_hi = clip_raw_out_lo + 1
clip_axis_in_lo = clip_raw_out_hi + 1
clip_axis_in_hi = clip_axis_in_lo + 1
clip_num16_lo = clip_axis_in_hi + 1
clip_num16_hi = clip_num16_lo + 1
clip_den16_lo = clip_num16_hi + 1
clip_den16_hi = clip_den16_lo + 1
clip_rem_ext = clip_den16_hi + 1
RUNTIME_AFTER_CLIP = clip_rem_ext + 1
.else
RUNTIME_AFTER_CLIP = RUNTIME_AFTER_NEAR
.endif
.if STANDARD_PROJECT_VERTEX != 0
sx_prev = RUNTIME_AFTER_CLIP
sy_prev = sx_prev + VERT_COUNT
smooth_ready = sy_prev + VERT_COUNT
RUNTIME_AFTER_SMOOTH = smooth_ready + VERT_COUNT
.else
RUNTIME_AFTER_SMOOTH = RUNTIME_AFTER_CLIP
.endif
sz = RUNTIME_AFTER_SMOOTH
szhi = sz + VERT_COUNT
; Semantic aliases: sz/szhi contain camera-space geometry only.  p1lo/p1hi
; carry the checked projection index only inside projection helpers.
camera_depth_geometric_lo = sz
camera_depth_geometric_hi = szhi
projection_table_index_lo = p1lo
projection_table_index_hi = p1hi
rxbuf = szhi + VERT_COUNT
rybuf = rxbuf + VERT_COUNT
projdone = rybuf + VERT_COUNT
x_m00 = projdone + VERT_COUNT
x_m10 = x_m00 + XCOORD_COUNT
x_m20 = x_m10 + XCOORD_COUNT
y_m01 = x_m20 + XCOORD_COUNT
y_m11 = y_m01 + YCOORD_COUNT
y_m21 = y_m11 + YCOORD_COUNT
z_m02 = y_m21 + YCOORD_COUNT
z_m12 = z_m02 + ZCOORD_COUNT
z_m22 = z_m12 + ZCOORD_COUNT
leftb = z_m22 + ZCOORD_COUNT
VIEWPORT_ROW_CAPACITY = 100
rightb = leftb + VIEWPORT_ROW_CAPACITY
.if LAZY_CONVEX_BOUNDS != 0
bounds_stamp = rightb + VIEWPORT_ROW_CAPACITY
dirtymin_a = bounds_stamp + VIEWPORT_ROW_CAPACITY
.else
dirtymin_a = rightb + VIEWPORT_ROW_CAPACITY
.endif
dirtymax_a = dirtymin_a + VIEWPORT_ROW_CAPACITY
dirtymin_b = dirtymax_a + VIEWPORT_ROW_CAPACITY
dirtymax_b = dirtymin_b + VIEWPORT_ROW_CAPACITY
.if (PROJ_SCREEN_MAX_Y + 1) > VIEWPORT_ROW_CAPACITY
 .error "Viewport height exceeds per-row runtime capacity"
.endif
.if rightb != leftb + VIEWPORT_ROW_CAPACITY || dirtymax_a != dirtymin_a + VIEWPORT_ROW_CAPACITY || dirtymin_b != dirtymax_a + VIEWPORT_ROW_CAPACITY || dirtymax_b != dirtymin_b + VIEWPORT_ROW_CAPACITY
 .error "Per-row runtime arrays are not contiguous 100-byte ranges"
.endif
.if MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = 0
bucket_head = dirtymax_b + VIEWPORT_ROW_CAPACITY
bucket_used_count = bucket_head + 256
bucket_used_list = bucket_used_count + 1
face_next = bucket_used_list + FACE_BUCKET_USED_LIST_CAPACITY
 .if MODE2_FACE_BUCKET_PIPELINE != 0
face_object = face_next + FACE_COUNT
RUNTIME_AFTER_FACE_OWNER = face_object + FACE_COUNT
 .else
RUNTIME_AFTER_FACE_OWNER = face_next + FACE_COUNT
 .endif
.else
RUNTIME_AFTER_FACE_OWNER = dirtymax_b + VIEWPORT_ROW_CAPACITY
.endif
.if MESH_SOURCE_SHARING_RUNTIME != 0
shared_source_vertex = RUNTIME_AFTER_FACE_OWNER
shared_runtime_face = shared_source_vertex + 1
shared_vertex_delta = shared_runtime_face + 1
shared_fv0 = shared_vertex_delta + 1
shared_fv1 = shared_fv0 + 1
shared_fv2 = shared_fv1 + 1
shared_fv3 = shared_fv2 + 1
RUNTIME_AFTER_SHARED_SOURCE = shared_fv3 + 1
.else
RUNTIME_AFTER_SHARED_SOURCE = RUNTIME_AFTER_FACE_OWNER
.endif
.if ENGINE_MODE3_FACE_PREPARE_ONCE != 0
frame_face_prepare = RUNTIME_AFTER_SHARED_SOURCE
frame_face_spanw = frame_face_prepare + FACE_COUNT
frame_face_spanh = frame_face_spanw + FACE_COUNT
RUNTIME_AFTER_FACE_PREPARE = frame_face_spanh + FACE_COUNT
.else
RUNTIME_AFTER_FACE_PREPARE = RUNTIME_AFTER_SHARED_SOURCE
.endif
.if STATIC_SHADE_DIRECT != 0
.if WIRE_DEPTH_SORT_ENABLE != 0
wire_bucket_head = RUNTIME_AFTER_FACE_PREPARE
wire_next = wire_bucket_head + 256
wire_entry_obj = wire_next + WIRE_DEPTH_ENTRY_COUNT
wire_entry_x0 = wire_entry_obj + WIRE_DEPTH_ENTRY_COUNT
wire_entry_y0 = wire_entry_x0 + WIRE_DEPTH_ENTRY_COUNT
wire_entry_x1 = wire_entry_y0 + WIRE_DEPTH_ENTRY_COUNT
wire_entry_y1 = wire_entry_x1 + WIRE_DEPTH_ENTRY_COUNT
RUNTIME_AFTER_WIRE_DEPTH = wire_entry_y1 + WIRE_DEPTH_ENTRY_COUNT
.else
RUNTIME_AFTER_WIRE_DEPTH = RUNTIME_AFTER_FACE_PREPARE
.endif
.if WIRE_FACE_EDGE_ENABLE != 0
edge_drawn = RUNTIME_AFTER_WIRE_DEPTH
RUNTIME_BUFFER_END = edge_drawn + WIRE_EDGE_COUNT
.else
RUNTIME_BUFFER_END = RUNTIME_AFTER_WIRE_DEPTH
.endif
.else
.if MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = 0
frame_face_shade = RUNTIME_AFTER_FACE_PREPARE
.if FRAME_FACE_FILL_CACHE != 0
frame_face_fill = frame_face_shade + FACE_COUNT
.if MODE4_SHADE_STEP_LIMIT != 0
mode4_shade_step_rank = frame_face_fill + FACE_COUNT
RUNTIME_AFTER_FACE_SHADE = mode4_shade_step_rank + FACE_COUNT
.else
RUNTIME_AFTER_FACE_SHADE = frame_face_fill + FACE_COUNT
.endif
.else
.if MODE4_SHADE_STEP_LIMIT != 0
mode4_shade_step_rank = frame_face_shade + FACE_COUNT
RUNTIME_AFTER_FACE_SHADE = mode4_shade_step_rank + FACE_COUNT
.else
RUNTIME_AFTER_FACE_SHADE = frame_face_shade + FACE_COUNT
.endif
.endif
.else
RUNTIME_AFTER_FACE_SHADE = RUNTIME_AFTER_FACE_PREPARE
.endif
.if WIRE_DEPTH_SORT_ENABLE != 0
wire_bucket_head = RUNTIME_AFTER_FACE_SHADE
wire_next = wire_bucket_head + 256
wire_entry_obj = wire_next + WIRE_DEPTH_ENTRY_COUNT
wire_entry_x0 = wire_entry_obj + WIRE_DEPTH_ENTRY_COUNT
wire_entry_y0 = wire_entry_x0 + WIRE_DEPTH_ENTRY_COUNT
wire_entry_x1 = wire_entry_y0 + WIRE_DEPTH_ENTRY_COUNT
wire_entry_y1 = wire_entry_x1 + WIRE_DEPTH_ENTRY_COUNT
RUNTIME_AFTER_WIRE_DEPTH = wire_entry_y1 + WIRE_DEPTH_ENTRY_COUNT
.else
RUNTIME_AFTER_WIRE_DEPTH = RUNTIME_AFTER_FACE_SHADE
.endif
.if WIRE_FACE_EDGE_ENABLE != 0
edge_drawn = RUNTIME_AFTER_WIRE_DEPTH
RUNTIME_BUFFER_END = edge_drawn + WIRE_EDGE_COUNT
.else
RUNTIME_BUFFER_END = RUNTIME_AFTER_WIRE_DEPTH
.endif
.endif
.if WORLD_GROUND_OCCLUDE != 0
ground_vside = RUNTIME_BUFFER_END
RUNTIME_AFTER_GROUND = ground_vside + VERT_COUNT
.else
RUNTIME_AFTER_GROUND = RUNTIME_BUFFER_END
.endif
; LEGACY_OBJECT_SORT_RUNTIME_BEGIN
.if WIRE_OBJECT_SORT_ENABLE != 0
object_sort_drawn = RUNTIME_AFTER_GROUND
RUNTIME_BUFFER_OBJECT_SORT_END = object_sort_drawn + SCENE_OBJECT_COUNT
.else
RUNTIME_BUFFER_OBJECT_SORT_END = RUNTIME_AFTER_GROUND
.endif
; LEGACY_OBJECT_SORT_RUNTIME_END
.if VIC_COLOR_POLICY_ENABLE != 0
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0
vic_color_owner_screen = RUNTIME_BUFFER_OBJECT_SORT_END
.else
vic_color_owner_screen = $9000
.endif
vic_color_owner_color = vic_color_owner_screen + 1000
.if VIC_COLOR_POLICY_OVERLAY != 0
vic_color_conflict_map = vic_color_owner_color + 1000
RUNTIME_BUFFER_COLOR_POLICY_END = vic_color_conflict_map + 1000
.else
vic_color_conflict_map = vic_color_owner_color + 1000
RUNTIME_BUFFER_COLOR_POLICY_END = vic_color_owner_color + 1000
.endif
.else
RUNTIME_BUFFER_COLOR_POLICY_END = RUNTIME_BUFFER_OBJECT_SORT_END
.endif
.if MEMORY_LAYOUT_HIGH_BASIC_V2 = 0 && VIC_COLOR_POLICY_ENABLE != 0 && RUNTIME_BUFFER_COLOR_POLICY_END > $a000
 .error "VIC color policy block overlaps bitmap buffer B"
.endif
.if RUNTIME_BUFFER_COLOR_POLICY_END > RUNTIME_BUFFER_LIMIT
.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 || VIC_COLOR_POLICY_ENABLE = 0
 .error "Runtime buffer block overlaps screen buffer B"
.endif
.endif

'@

if ($Mode4ReflectiveHysteresisBypassFlag -ne 0) {
 $hysteresisCall = ' jsr select_face_shade_from_dot'
 if ([regex]::Matches($asm, [regex]::Escape($hysteresisCall)).Count -ne 1) {
  throw "Reflective hysteresis bypass requires exactly one call site."
 }
 $asm = $asm.Replace($hysteresisCall, ' jsr select_raw_face_shade_from_dot')
}

if ($EmitRenderSceneObjectsFlag -eq 0) {
 $asm = [regex]::Replace($asm, '(?ms)^render_scene_objects:\r?\n.*?(?=^; LEGACY_OBJECT_SORT_ROUTINES_BEGIN)', '')
}
if ($EmitWireObjectSortFlag -eq 0) {
 $asm = [regex]::Replace($asm, '(?s); LEGACY_OBJECT_SORT_ROUTINES_BEGIN.*?; LEGACY_OBJECT_SORT_ROUTINES_END\r?\n?', '')
 $asm = [regex]::Replace($asm, '(?s); LEGACY_OBJECT_SORT_STATE_BEGIN.*?; LEGACY_OBJECT_SORT_STATE_END\r?\n?', '')
 $asm = [regex]::Replace($asm, '(?s); LEGACY_OBJECT_SORT_RUNTIME_BEGIN.*?; LEGACY_OBJECT_SORT_RUNTIME_END\r?\n?', '')
 $asm = [regex]::Replace($asm, '(?m)^\s*jsr draw_wire_scene_objects_sorted\r?\n', '')
 $asm = $asm.Replace('RUNTIME_BUFFER_COLOR_POLICY_END = RUNTIME_BUFFER_OBJECT_SORT_END', 'RUNTIME_BUFFER_COLOR_POLICY_END = RUNTIME_AFTER_GROUND')
 $asm = $asm.Replace('vic_color_owner_screen = RUNTIME_BUFFER_OBJECT_SORT_END', 'vic_color_owner_screen = RUNTIME_AFTER_GROUND')
}

if ($SolidSubpixelXQ2Flag -ne 0 -or $SolidSubpixelYQ2Flag -ne 0) {
 $solidSubpixelStoreAsm = if ($SolidSubpixelXNativeFlag -ne 0) { @'
solid_subpixel_xq2_store:
 ldx tmpidx
 lda rxbuf,x
 beq ssxq2_store_center
 ldx scalev
 jsr mul_s6_xpos_q2
 jmp ssxq2_store_offset_ready
ssxq2_store_center:
 lda #$00
 sta p1lo
 lda #$01
 sta p1hi
ssxq2_store_offset_ready:
 ldy tmpidx
 lda p1lo
 sta sxq2_lo,y
 lda p1hi
 sta sxq2_hi,y
 rts

mul_s6_xpos_q2:
 sta mula
 stx mulb
 lda #$00
 sta mulsign
 lda mula
 bpl ms6xq2_a_ok
 eor #$ff
 clc
 adc #$01
 sta mula
 lda #$80
 sta mulsign
ms6xq2_a_ok:
 lda mula
 clc
 adc mulb
 tax
 lda sqlo,x
 sta prodlo
 lda sqhi,x
 sta prodhi
 lda mula
 sec
 sbc mulb
 bcs ms6xq2_diff_ok
 eor #$ff
 clc
 adc #$01
ms6xq2_diff_ok:
 tax
 sec
 lda prodlo
 sbc sqlo,x
 sta prodlo
 lda prodhi
 sbc sqhi,x
 sta prodhi
 clc
 lda prodlo
 adc #$08
 sta prodlo
 lda prodhi
 adc #$00
 sta prodhi
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 ldx mulsign
 bpl ms6xq2_positive
 sec
 lda #$00
 sbc prodlo
 sta p1lo
 lda #$00
 sbc prodhi
 sta p1hi
 jmp ms6xq2_center
ms6xq2_positive:
 lda prodlo
 sta p1lo
 lda prodhi
 sta p1hi
ms6xq2_center:
 clc
 lda p1lo
 adc #$00
 sta p1lo
 lda p1hi
 adc #$01
 sta p1hi
 bmi ms6xq2_clamp_zero
 cmp #$01
 bcc ms6xq2_done
 bne ms6xq2_clamp_max
 lda p1lo
 cmp #$fc
 bcc ms6xq2_done
 beq ms6xq2_done
ms6xq2_clamp_max:
 lda #$fc
 sta p1lo
 lda #$01
 sta p1hi
 rts
ms6xq2_clamp_zero:
 lda #$00
 sta p1lo
 sta p1hi
ms6xq2_done:
 rts
'@ } elseif ($SolidSubpixelXLegacyDirectFlag -ne 0) { '' } else { @'
solid_subpixel_xq2_store:
 ldy tmpidx
 lda sx,y
 asl
 asl
 sta sxq2_lo,y
 lda #$00
 sta sxq2_hi,y
 rts
'@ }

 $solidSubpixelYStoreAsm = if ($SolidSubpixelYNativeFlag -ne 0) { @'
solid_subpixel_yq2_store:
 ldx tmpidx
 lda rybuf,x
 ldx scalev
 jsr mul_s6_yraw_q2
 ; Convert the Native Q2 offset around the effective viewport centre.
 sec
 lda #YQ2_VIEWPORT_CENTER_LO
 sbc p1lo
 sta p1lo
 lda #YQ2_VIEWPORT_NATIVE_BASE_HI
 sbc p1hi
 sta p1hi
 bmi ssyq2_clamp_zero
 cmp #YQ2_VIEWPORT_MAX_HI
 bcc ssyq2_store
 bne ssyq2_clamp_max
 lda p1lo
 cmp #YQ2_VIEWPORT_MAX_LO
 bcc ssyq2_store
 beq ssyq2_store
ssyq2_clamp_max:
 lda #YQ2_VIEWPORT_MAX_LO
 sta p1lo
 lda #YQ2_VIEWPORT_MAX_HI
 sta p1hi
 jmp ssyq2_store
ssyq2_clamp_zero:
 lda #$00
 sta p1lo
 sta p1hi
ssyq2_store:
 ldy tmpidx
 lda p1lo
 sta syq2_lo,y
 lda p1hi
 sta syq2_hi,y
 rts

mul_s6_yraw_q2:
 sta mula
 stx mulb
 lda #$00
 sta mulsign
 lda mula
 bpl msyq2_a_ok
 eor #$ff
 clc
 adc #$01
 sta mula
 lda #$80
 sta mulsign
msyq2_a_ok:
 lda mula
 clc
 adc mulb
 tax
 lda sqlo,x
 sta prodlo
 lda sqhi,x
 sta prodhi
 lda mula
 sec
 sbc mulb
 bcs msyq2_diff_ok
 eor #$ff
 clc
 adc #$01
msyq2_diff_ok:
 tax
 sec
 lda prodlo
 sbc sqlo,x
 sta prodlo
 lda prodhi
 sbc sqhi,x
 sta prodhi
 clc
 lda prodlo
 adc #$08
 sta prodlo
 lda prodhi
 adc #$00
 sta prodhi
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 ldx mulsign
 bpl msyq2_positive
 sec
 lda #$00
 sbc prodlo
 sta p1lo
 lda #$00
 sbc prodhi
 sta p1hi
 jmp msyq2_center
msyq2_positive:
 lda prodlo
 sta p1lo
 lda prodhi
 sta p1hi
msyq2_center:
 clc
 lda p1lo
 adc #$00
 sta p1lo
 lda p1hi
 adc #$01
 sta p1hi
 bmi msyq2_clamp_zero
 cmp #$01
 bcc msyq2_done
 bne msyq2_clamp_max
 lda p1lo
 cmp #$fc
 bcc msyq2_done
 beq msyq2_done
msyq2_clamp_max:
 lda #$fc
 sta p1lo
 lda #$01
 sta p1hi
 rts
msyq2_clamp_zero:
 lda #$00
 sta p1lo
 sta p1hi
msyq2_done:
 rts
'@ } elseif ($SolidSubpixelYLegacyBufferedFlag -ne 0) { @'
; Diagnostic source: store the projected legacy pixel Y through the same
; syq2 runtime buffer and face loader consumed by the XY-Q2 builder.
solid_subpixel_yq2_store:
ssyq2_tmp_lo = p1lo
ssyq2_tmp_hi = p1hi
.if ssyq2_tmp_lo = ssyq2_tmp_hi || ssyq2_tmp_lo = tmpidx || ssyq2_tmp_hi = tmpidx
 .error "LegacyBuffered Y-Q2 store temporaries alias"
.endif
 ldx tmpidx
 lda sy,x
 sta ssyq2_tmp_lo
 lda #$00
 sta ssyq2_tmp_hi
 asl ssyq2_tmp_lo
 rol ssyq2_tmp_hi
 asl ssyq2_tmp_lo
 rol ssyq2_tmp_hi
 ; The projection/helper index is never trusted for the buffer stores.
 ldx tmpidx
 lda ssyq2_tmp_lo
 sta syq2_lo,x
 lda ssyq2_tmp_hi
 sta syq2_hi,x
 rts
'@ } elseif ($SolidSubpixelYLegacyPhase1Flag -ne 0) { @'
; Diagnostic fractional source: preserve legacy geometry with a uniform
; quarter-pixel Y phase, clamped at the effective viewport Q2 endpoint.
solid_subpixel_yq2_store:
ssyq2p_tmp_lo = p1lo
ssyq2p_tmp_hi = p1hi
.if ssyq2p_tmp_lo = ssyq2p_tmp_hi || ssyq2p_tmp_lo = tmpidx || ssyq2p_tmp_hi = tmpidx
 .error "LegacyPhase1 Y-Q2 store temporaries alias"
.endif
 ldx tmpidx
 lda sy,x
 sta ssyq2p_tmp_lo
 lda #$00
 sta ssyq2p_tmp_hi
 asl ssyq2p_tmp_lo
 rol ssyq2p_tmp_hi
 asl ssyq2p_tmp_lo
 rol ssyq2p_tmp_hi
 clc
 lda ssyq2p_tmp_lo
 adc #$01
 sta ssyq2p_tmp_lo
 lda ssyq2p_tmp_hi
 adc #$00
 sta ssyq2p_tmp_hi
 lda ssyq2p_tmp_hi
 cmp #YQ2_VIEWPORT_MAX_HI
 bcc ssyq2p_store
 bne ssyq2p_clamp
 lda ssyq2p_tmp_lo
 cmp #(YQ2_VIEWPORT_MAX_LO + 1)
 bcc ssyq2p_store
ssyq2p_clamp:
 lda #YQ2_VIEWPORT_MAX_LO
 sta ssyq2p_tmp_lo
 lda #YQ2_VIEWPORT_MAX_HI
 sta ssyq2p_tmp_hi
ssyq2p_store:
 ldx tmpidx
 lda ssyq2p_tmp_lo
 sta syq2_lo,x
 lda ssyq2p_tmp_hi
 sta syq2_hi,x
 rts
'@ } elseif ($SolidSubpixelYNativeQuantizedFlag -ne 0) { @'
; Diagnostic source: run the Native Q2 projection, then quantize it to the
; nearest Q2 pixel centre before placing it in the normal syq2 buffers.
solid_subpixel_yq2_store:
 ldx tmpidx
 lda rybuf,x
 ldx scalev
 jsr mul_s6_yraw_q2
 ; Convert the Native Q2 offset around the effective viewport centre.
 sec
 lda #YQ2_VIEWPORT_CENTER_LO
 sbc p1lo
 sta p1lo
 lda #YQ2_VIEWPORT_NATIVE_BASE_HI
 sbc p1hi
 sta p1hi
 bmi ssyq2q_clamp_zero
 cmp #YQ2_VIEWPORT_MAX_HI
 bcc ssyq2q_native_ready
 bne ssyq2q_clamp_max
 lda p1lo
 cmp #YQ2_VIEWPORT_MAX_LO
 bcc ssyq2q_native_ready
 beq ssyq2q_native_ready
ssyq2q_clamp_max:
 lda #YQ2_VIEWPORT_MAX_LO
 sta p1lo
 lda #YQ2_VIEWPORT_MAX_HI
 sta p1hi
 jmp ssyq2q_native_ready
ssyq2q_clamp_zero:
 lda #$00
 sta p1lo
 sta p1hi
ssyq2q_native_ready:
 ; pixelY=floor((yNativeQ2+2)/4), constrained to the viewport row range.
 clc
 lda p1lo
 adc #$02
 sta p1lo
 lda p1hi
 adc #$00
 sta p1hi
 lsr p1hi
 ror p1lo
 lsr p1hi
 ror p1lo
 lda p1hi
 beq ssyq2q_pixel_ready
 lda #YQ2_VIEWPORT_ROW_MAX
 sta p1lo
 lda #$00
 sta p1hi
ssyq2q_pixel_ready:
 ; yQuantizedQ2=4*pixelY; propagate carry into the allowed high byte.
 asl p1lo
 rol p1hi
 asl p1lo
 rol p1hi
 ; mul_s6_yraw_q2 consumed X; reload the vertex index for both stores.
 ldx tmpidx
 lda p1lo
 sta syq2_lo,x
 lda p1hi
 sta syq2_hi,x
 rts

mul_s6_yraw_q2:
 sta mula
 stx mulb
 lda #$00
 sta mulsign
 lda mula
 bpl msyq2_a_ok
 eor #$ff
 clc
 adc #$01
 sta mula
 lda #$80
 sta mulsign
msyq2_a_ok:
 lda mula
 clc
 adc mulb
 tax
 lda sqlo,x
 sta prodlo
 lda sqhi,x
 sta prodhi
 lda mula
 sec
 sbc mulb
 bcs msyq2_diff_ok
 eor #$ff
 clc
 adc #$01
msyq2_diff_ok:
 tax
 sec
 lda prodlo
 sbc sqlo,x
 sta prodlo
 lda prodhi
 sbc sqhi,x
 sta prodhi
 clc
 lda prodlo
 adc #$08
 sta prodlo
 lda prodhi
 adc #$00
 sta prodhi
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 ldx mulsign
 bpl msyq2_positive
 sec
 lda #$00
 sbc prodlo
 sta p1lo
 lda #$00
 sbc prodhi
 sta p1hi
 jmp msyq2_center
msyq2_positive:
 lda prodlo
 sta p1lo
 lda prodhi
 sta p1hi
msyq2_center:
 clc
 lda p1lo
 adc #$00
 sta p1lo
 lda p1hi
 adc #$01
 sta p1hi
 bmi msyq2_clamp_zero
 cmp #$01
 bcc msyq2_done
 bne msyq2_clamp_max
 lda p1lo
 cmp #$fc
 bcc msyq2_done
 beq msyq2_done
msyq2_clamp_max:
 lda #$fc
 sta p1lo
 lda #$01
 sta p1hi
 rts
msyq2_clamp_zero:
 lda #$00
 sta p1lo
 sta p1hi
msyq2_done:
 rts
'@ } else { '' }

 $solidSubpixelMobileYAsm = if ($SolidSubpixelYMobileNativeFlag -ne 0) { @'
; Phase 1 mobile Native-Y Q2 projection.  The input in p1 is the signed
; 16-bit camera-space Y after yaw/pitch and, for walkFull, after roll.
; explorer_project_axis_offset performs the sole perspective division and
; leaves quotient in mul16res, remainder in cross, and the positive 16-bit
; depth divisor in p1.  The legacy sy and raw screen Y are stored before two
; bounded binary remainder steps retain the next two quotient bits.
explorer_project_yq2_16:
 jsr explorer_project_axis_offset
.if EXPLORER_SCREEN_RAW != 0
 jsr explorer_store_raw_y
.endif
 lda mul16sign
 bmi eyq2_legacy_down
 lda scalev
 cmp #(PROJ_CENTER_Y + 1)
 bcc eyq2_legacy_up_visible
 lda #PROJ_SCREEN_MIN_Y
 jmp eyq2_legacy_store
eyq2_legacy_up_visible:
 lda #PROJ_CENTER_Y
 sec
 sbc scalev
 jmp eyq2_legacy_store
eyq2_legacy_down:
 lda scalev
 cmp #PROJ_CENTER_Y
 bcc eyq2_legacy_down_visible
 lda #PROJ_SCREEN_MAX_Y
 jmp eyq2_legacy_store
eyq2_legacy_down_visible:
 clc
 adc #PROJ_CENTER_Y
eyq2_legacy_store:
 ldy tmpidx
 sta sy,y
 lda #$00
 sta mul16rem
 jsr explorer_project_yq2_fraction_bit
 jsr explorer_project_yq2_fraction_bit
 asl mul16reslo
 rol mul16reshi
 asl mul16reslo
 rol mul16reshi
 clc
 lda mul16reslo
 adc mul16rem
 sta mul16reslo
 lda mul16reshi
 adc #$00
 sta mul16reshi
 lda mul16sign
 bmi eyq2_down
eyq2_up:
 lda mul16reshi
 bne eyq2_clamp_zero
 lda mul16reslo
 cmp #YQ2_VIEWPORT_CENTER_PLUS_ONE
 bcs eyq2_clamp_zero
 lda #YQ2_VIEWPORT_CENTER_LO
 sec
 sbc mul16reslo
 sta p1lo
 lda #YQ2_VIEWPORT_CENTER_HI
 sta p1hi
 jmp eyq2_store
eyq2_down:
 lda mul16reshi
 bne eyq2_clamp_max
 lda mul16reslo
 cmp #YQ2_VIEWPORT_BELOW_CENTER_LIMIT_PLUS_ONE
 bcs eyq2_clamp_max
 clc
 adc #YQ2_VIEWPORT_CENTER_LO
 sta p1lo
 lda #YQ2_VIEWPORT_CENTER_HI
 adc #$00
 sta p1hi
 jmp eyq2_store
eyq2_clamp_zero:
 lda #$00
 sta p1lo
 sta p1hi
 jmp eyq2_store
eyq2_clamp_max:
 lda #YQ2_VIEWPORT_MAX_LO
 sta p1lo
 lda #YQ2_VIEWPORT_MAX_HI
 sta p1hi
eyq2_store:
 ldy tmpidx
 lda p1lo
 sta syq2_lo,y
 lda p1hi
 sta syq2_hi,y
 rts

explorer_project_yq2_fraction_bit:
 asl mul16rem
 asl crosslo
 rol crosshi
 lda crosshi
 cmp p1hi
 bcc eyq2_fraction_done
 bne eyq2_fraction_subtract
 lda crosslo
 cmp p1lo
 bcc eyq2_fraction_done
eyq2_fraction_subtract:
 sec
 lda crosslo
 sbc p1lo
 sta crosslo
 lda crosshi
 sbc p1hi
 sta crosshi
 inc mul16rem
eyq2_fraction_done:
 rts

; This predicate reads only the established clipping state.  It never writes
; clip buffers and allows XY-Q2 only for the original, fully visible polygon.
mobile_yq2_face_eligible:
.if EXPLORER_NEAR_POLY != 0
 lda near_face_crossing
 bne myq2_face_no
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda clip_poly_active
 bne myq2_face_no
.endif
.if EXPLORER_SCREEN_CLIP_X != 0
 lda clip_second_pending
 bne myq2_face_no
.endif
 sec
 rts
myq2_face_no:
 clc
 rts
'@ } else { '' }

 $solidSubpixelRoutinesAsm = @'
trace_edge_convex_xq2:
 lda ey0
 cmp ey1
 bcc ssxq2_ordered
 bne ssxq2_descending
 jmp ssxq2_horizontal
ssxq2_descending:
 lda q2_x0lo
 pha
 lda q2_x0hi
 pha
 lda q2_x1lo
 pha
 lda q2_x1hi
 pha
 lda ey0
 pha
 lda ey1
 sta ey0
 pla
 sta ey1
 pla
 sta q2_x0hi
 pla
 sta q2_x0lo
 pla
 sta q2_x1hi
 pla
 sta q2_x1lo
ssxq2_ordered:
 sec
 lda ey1
 sbc ey0
 sta dyval
 lda q2_x1hi
 cmp q2_x0hi
 bcc ssxq2_negative
 bne ssxq2_positive
 lda q2_x1lo
 cmp q2_x0lo
 bcc ssxq2_negative
ssxq2_positive:
 lda #$01
 sta sxstep
 sec
 lda q2_x1lo
 sbc q2_x0lo
 sta q2_step_lo
 lda q2_x1hi
 sbc q2_x0hi
 sta q2_step_hi
 jmp ssxq2_prepare
ssxq2_negative:
 lda #$ff
 sta sxstep
 sec
 lda q2_x0lo
 sbc q2_x1lo
 sta q2_step_lo
 lda q2_x0hi
 sbc q2_x1hi
 sta q2_step_hi
ssxq2_prepare:
 ; Integer Q2 endpoints retain the already validated RC4-equivalent trace.
 ; Fractional endpoints keep the same normalized state while their Q2 DDA
 ; position is advanced exactly between scanlines.
 lda q2_x0lo
 ora q2_x1lo
 and #$03
 bne ssxq2_fractional_prepare
ssxq2_direct_prepare:
 ; LegacyDirect endpoints are exact 4*sx. Convert the unsigned Q2 delta
 ; to pixel delta, then retain RC4's connected horizontal bridge updates.
 lsr q2_step_hi
 ror q2_step_lo
 lsr q2_step_hi
 ror q2_step_lo
 lda #$00
 sta q2_remainder
 sta q2_rem_step
ssxq2_direct_loop:
 jsr solid_subpixel_xq2_plot_current
 lda ey0
 cmp ey1
 beq ssxq2_direct_done
 clc
 lda q2_remainder
 adc q2_step_lo
 sta q2_remainder
ssxq2_direct_step_check:
 lda q2_remainder
 cmp dyval
 bcc ssxq2_direct_next_row
 sec
 sbc dyval
 sta q2_remainder
 jsr solid_subpixel_xq2_advance_pixel
 jsr solid_subpixel_xq2_plot_current
 jmp ssxq2_direct_step_check
ssxq2_direct_next_row:
 inc ey0
 jmp ssxq2_direct_loop
ssxq2_direct_done:
 rts

ssxq2_fractional_prepare:
 lda dyval
 sta p1lo
 lda #$00
 sta p1hi
 jsr solid_subpixel_xq2_div16u
 lda crosslo
 sta q2_rem_step
 lda #$00
 sta q2_remainder
ssxq2_fractional_loop:
 jsr solid_subpixel_xq2_plot_current
 lda ey0
 cmp ey1
 beq ssxq2_fractional_done
 jsr solid_subpixel_xq2_pixel_current
 sta p1lo
 jsr solid_subpixel_xq2_advance_q2_step
 clc
 lda q2_remainder
 adc q2_rem_step
 sta q2_remainder
 cmp dyval
 bcc ssxq2_fractional_target
 sec
 sbc dyval
 sta q2_remainder
 jsr solid_subpixel_xq2_advance_q2_unit
ssxq2_fractional_target:
 jsr solid_subpixel_xq2_pixel_current
 sta p1hi
ssxq2_fractional_bridge:
 lda p1lo
 cmp p1hi
 beq ssxq2_fractional_next_row
 lda sxstep
 bmi ssxq2_fractional_bridge_negative
 inc p1lo
 ldx ey0
 lda p1lo
 jsr update_convex_bounds
 jmp ssxq2_fractional_bridge
ssxq2_fractional_bridge_negative:
 dec p1lo
 ldx ey0
 lda p1lo
 jsr update_convex_bounds
 jmp ssxq2_fractional_bridge
ssxq2_fractional_next_row:
 inc ey0
 jmp ssxq2_fractional_loop
ssxq2_fractional_done:
 rts

ssxq2_horizontal:
 jsr solid_subpixel_xq2_plot_current
 lda q2_x1lo
 sta q2_x0lo
 lda q2_x1hi
 sta q2_x0hi
 jsr solid_subpixel_xq2_plot_current
 rts

solid_subpixel_xq2_advance_pixel:
 lda q2_x0hi
 cmp q2_x1hi
 bne ssxq2_advance_direction
 lda q2_x0lo
 cmp q2_x1lo
 beq ssxq2_advance_done
ssxq2_advance_direction:
 lda sxstep
 bmi ssxq2_advance_negative
 clc
 lda q2_x0lo
 adc #$04
 sta q2_x0lo
 lda q2_x0hi
 adc #$00
 sta q2_x0hi
 rts
ssxq2_advance_negative:
 sec
 lda q2_x0lo
 sbc #$04
 sta q2_x0lo
 lda q2_x0hi
 sbc #$00
 sta q2_x0hi
ssxq2_advance_done:
 rts

solid_subpixel_xq2_advance_q2_step:
 lda sxstep
 bmi ssxq2_advance_q2_step_negative
 clc
 lda q2_x0lo
 adc q2_step_lo
 sta q2_x0lo
 lda q2_x0hi
 adc q2_step_hi
 sta q2_x0hi
 rts
ssxq2_advance_q2_step_negative:
 sec
 lda q2_x0lo
 sbc q2_step_lo
 sta q2_x0lo
 lda q2_x0hi
 sbc q2_step_hi
 sta q2_x0hi
 rts

solid_subpixel_xq2_advance_q2_unit:
 lda sxstep
 bmi ssxq2_advance_q2_unit_negative
 inc q2_x0lo
 bne ssxq2_advance_q2_unit_done
 inc q2_x0hi
ssxq2_advance_q2_unit_done:
 rts
ssxq2_advance_q2_unit_negative:
 lda q2_x0lo
 bne ssxq2_advance_q2_unit_low
 dec q2_x0hi
ssxq2_advance_q2_unit_low:
 dec q2_x0lo
 rts

solid_subpixel_xq2_pixel_current:
 clc
 lda q2_x0lo
 adc #$02
 sta t1
 lda q2_x0hi
 adc #$00
 sta t2
 lsr t2
 ror t1
 lsr t2
 ror t1
 lda t1
 rts

solid_subpixel_xq2_plot_current:
 jsr solid_subpixel_xq2_pixel_current
 ldx ey0
 jsr update_convex_bounds
 rts

solid_subpixel_xq2_div16u:
 lda #$00
 sta crosslo
 sta crosshi
 ldx #$10
ssxq2_div_loop:
 asl prodlo
 rol prodhi
 rol crosslo
 rol crosshi
 lda crosslo
 sec
 sbc p1lo
 tay
 lda crosshi
 sbc p1hi
 bcc ssxq2_div_skip_sub
 sta crosshi
 sty crosslo
 inc prodlo
ssxq2_div_skip_sub:
 dex
 bne ssxq2_div_loop
 rts
'@

 $solidSubpixelXYQ2Asm = if ($SolidSubpixelXYQ2LegacyDirectYFlag -ne 0) { @'
; Native Y-Q2 solid bounds.  This block is emitted only for the one supported
; mode-4/fixed/small/stable X=LegacyDirect, Y=Native configuration.
;
; xExact is always represented as B + R/D, with 0 <= R < D.  B, R, D,
; S and RS are deliberately distinct RAM slots: the two signed Euclidean
; divisions cannot overwrite the residual used by the next scanline.
xyq2_face_valid: .byte 0
xyq2_x0lo: .byte 0
xyq2_x0hi: .byte 0
xyq2_y0lo: .byte 0
xyq2_y0hi: .byte 0
xyq2_x1lo: .byte 0
xyq2_x1hi: .byte 0
xyq2_y1lo: .byte 0
xyq2_y1hi: .byte 0
xyq2_minlo: .byte 0
xyq2_minhi: .byte 0
xyq2_maxlo: .byte 0
xyq2_maxhi: .byte 0
xyq2_dxlo: .byte 0
xyq2_dxhi: .byte 0
xyq2_blo: .byte 0
xyq2_bhi: .byte 0
xyq2_rlo: .byte 0
xyq2_rhi: .byte 0
xyq2_dlo: .byte 0
xyq2_dhi: .byte 0
xyq2_slo: .byte 0
xyq2_shi: .byte 0
xyq2_rslo: .byte 0
xyq2_rshi: .byte 0
xyq2_nlo: .byte 0
xyq2_nhi: .byte 0
xyq2_qlo: .byte 0
xyq2_qhi: .byte 0
xyq2_divlo: .byte 0
xyq2_divhi: .byte 0
xyq2_r0lo: .byte 0
xyq2_r0hi: .byte 0
xyq2_delta: .byte 0
xyq2_row: .byte 0
xyq2_lastrow: .byte 0
xyq2_phase: .byte 0
xyq2_base: .byte 0
xyq2_negative: .byte 0
xyq2_faulted: .byte 0
xyq2_builder_sp: .byte 0
.if xyq2_face_valid < $0100 || xyq2_negative != xyq2_face_valid + $26
 .error "XYQ2 state must be contiguous RAM, never zero page"
.endif
.if xyq2_faulted != xyq2_negative + 1 || xyq2_builder_sp != xyq2_faulted + 1
 .error "XYQ2 fault-unwind state must remain private contiguous RAM"
.endif
.if xyq2_r0lo = xyq2_rslo || xyq2_r0hi = xyq2_rshi || xyq2_r0lo = xyq2_r0hi || xyq2_rslo = xyq2_rshi
 .error "XYQ2 R0 and RS must use separate state"
.endif
.if xyq2_dxhi != xyq2_dxlo + 1 || xyq2_bhi != xyq2_blo + 1 || xyq2_rhi != xyq2_rlo + 1 || xyq2_dhi != xyq2_dlo + 1 || xyq2_shi != xyq2_slo + 1 || xyq2_rshi != xyq2_rslo + 1 || xyq2_nhi != xyq2_nlo + 1 || xyq2_qhi != xyq2_qlo + 1 || xyq2_divhi != xyq2_divlo + 1 || xyq2_r0hi != xyq2_r0lo + 1
 .error "XYQ2 fractional walker requires distinct contiguous 16-bit words"
.endif
.if xyq2_blo = fillbyte || xyq2_blo = shadeidx || xyq2_blo = face_ymin || xyq2_blo = face_ymax || xyq2_rlo = fillbyte || xyq2_dlo = fillbyte || xyq2_slo = fillbyte || xyq2_rslo = fillbyte || xyq2_nlo = fillbyte || xyq2_qlo = fillbyte || xyq2_divlo = fillbyte
 .error "XYQ2 fractional scratch aliases Mode 4 fill or shade state"
.endif
.if xyq2_face_valid < $0100 || xyq2_builder_sp < $0100
 .error "XYQ2 bounds scratch must remain outside every Mode 4 zero-page state cell"
.endif
.if q2_x0lo = drawbuf || q2_x0hi = drawbuf || q2_x1lo = drawbuf || q2_x1hi = drawbuf || q2_x0lo = shadeidx || q2_x0hi = shadeidx || q2_x1lo = shadeidx || q2_x1hi = shadeidx || q2_x0lo = fillbyte || q2_x0hi = fillbyte || q2_x1lo = fillbyte || q2_x1hi = fillbyte || q2_x0lo = pattoggle || q2_x0hi = pattoggle || q2_x1lo = pattoggle || q2_x1hi = pattoggle || q2_x0lo = spanw || q2_x0hi = spanw || q2_x1lo = spanw || q2_x1hi = spanw || q2_x0lo = spanh || q2_x0hi = spanh || q2_x1lo = spanh || q2_x1hi = spanh || q2_x0lo = ptr0lo || q2_x0hi = ptr0lo || q2_x1lo = ptr0lo || q2_x1hi = ptr0lo || q2_x0lo = ptr0hi || q2_x0hi = ptr0hi || q2_x1lo = ptr0hi || q2_x1hi = ptr0hi || q2_x0lo = ptr1lo || q2_x0hi = ptr1lo || q2_x1lo = ptr1lo || q2_x1hi = ptr1lo || q2_x0lo = ptr1hi || q2_x0hi = ptr1hi || q2_x1lo = ptr1hi || q2_x1hi = ptr1hi
 .error "XYQ2 DEV2 zero-page temporaries alias Mode 4 dispatch state"
.endif
.if mode4_current_face_id >= $0100 || mode4_current_face_id = drawbuf || mode4_current_face_id = faceidx || mode4_current_face_id = sortj || mode4_current_face_id = shadeidx || mode4_current_face_id = fillbyte || mode4_current_face_id = face_ymin || mode4_current_face_id = face_ymax || mode4_current_face_id = spanw || mode4_current_face_id = spanh || mode4_current_face_id = q2_x0lo || mode4_current_face_id = q2_x0hi || mode4_current_face_id = q2_x1lo || mode4_current_face_id = q2_x1hi
 .error "Mode4 current-face latch must be a dedicated zero-page cell"
.endif
.if vyq2_0lo = q2_x0lo || vyq2_0lo = q2_x0hi || vyq2_0lo = q2_x1lo || vyq2_0lo = q2_x1hi || vyq2_0lo = q2_step_lo || vyq2_0lo = q2_step_hi || vyq2_0lo = q2_remainder || vyq2_0lo = q2_rem_step || vyq2_1lo = q2_x0lo || vyq2_1lo = q2_x0hi || vyq2_1lo = q2_x1lo || vyq2_1lo = q2_x1hi || vyq2_1lo = q2_step_lo || vyq2_1lo = q2_step_hi || vyq2_1lo = q2_remainder || vyq2_1lo = q2_rem_step || vyq2_2lo = q2_x0lo || vyq2_2lo = q2_x0hi || vyq2_2lo = q2_x1lo || vyq2_2lo = q2_x1hi || vyq2_2lo = q2_step_lo || vyq2_2lo = q2_step_hi || vyq2_2lo = q2_remainder || vyq2_2lo = q2_rem_step || vyq2_3lo = q2_x0lo || vyq2_3lo = q2_x0hi || vyq2_3lo = q2_x1lo || vyq2_3lo = q2_x1hi || vyq2_3lo = q2_step_lo || vyq2_3lo = q2_step_hi || vyq2_3lo = q2_remainder || vyq2_3lo = q2_rem_step
 .error "XYQ2 Y endpoints overlap DEV2 zero-page walker state"
.endif
.if vyq2_0lo >= $0100 || vyq2_0hi >= $0100 || vyq2_1lo >= $0100 || vyq2_1hi >= $0100 || vyq2_2lo >= $0100 || vyq2_2hi >= $0100 || vyq2_3lo >= $0100 || vyq2_3hi >= $0100
 .error "XYQ2 Y endpoints must remain private zero-page temporaries"
.endif

build_loaded_face_bounds_xyq2:
 tsx
 stx xyq2_builder_sp
 lda #$00
 sta xyq2_face_valid
 sta xyq2_faulted
 jsr setup_face_y_bounds_xyq2
 bcc xyq2_builder_done
 jmp xyq2_trace_edges
xyq2_builder_done:
 rts
 
setup_face_y_bounds_xyq2:
 ; minYQ2/maxYQ2 are taken exclusively from the Native syq2 endpoints
 ; copied by load_face_y; vy0..vy3 are not used in this builder.
 lda vyq2_0lo
 sta xyq2_minlo
 sta xyq2_maxlo
 lda vyq2_0hi
 sta xyq2_minhi
 sta xyq2_maxhi
 lda vyq2_1lo
 sta xyq2_nlo
 lda vyq2_1hi
 sta xyq2_nhi
 jsr xyq2_include_y
 lda vyq2_2lo
 sta xyq2_nlo
 lda vyq2_2hi
 sta xyq2_nhi
 jsr xyq2_include_y
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne xyq2_minmax_done
.endif
 lda vyq2_3lo
 sta xyq2_nlo
 lda vyq2_3hi
 sta xyq2_nhi
 jsr xyq2_include_y
xyq2_minmax_done:
 ; firstRow = ceil(minYQ2 / 4), lastRow = floor(maxYQ2 / 4).
 clc
 lda xyq2_minlo
 adc #$03
 sta xyq2_nlo
 lda xyq2_minhi
 adc #$00
 sta xyq2_nhi
 lsr xyq2_nhi
 ror xyq2_nlo
 lsr xyq2_nhi
 ror xyq2_nlo
 lda xyq2_nhi
 bne xyq2_first_clamp
 lda xyq2_nlo
 cmp #$50
 bcc xyq2_first_ready
xyq2_first_clamp:
 lda #$4f
xyq2_first_ready:
 sta face_ymin
 lda xyq2_maxlo
 sta xyq2_nlo
 lda xyq2_maxhi
 sta xyq2_nhi
 lsr xyq2_nhi
 ror xyq2_nlo
 lsr xyq2_nhi
 ror xyq2_nlo
 lda xyq2_nhi
 bne xyq2_last_clamp
 lda xyq2_nlo
 cmp #$50
 bcc xyq2_last_ready
xyq2_last_clamp:
 lda #$4f
xyq2_last_ready:
 sta face_ymax
 lda face_ymin
 cmp face_ymax
 bcc xyq2_init_bounds
 beq xyq2_init_bounds
 clc
 rts
xyq2_init_bounds:
 ldx face_ymin
 lda #$ff
xyq2_init_loop:
 sta leftb,x
 lda #$00
 sta rightb,x
 lda #$ff
 cpx face_ymax
 beq xyq2_bounds_ready
 inx
 jmp xyq2_init_loop
xyq2_bounds_ready:
 sec
 rts
xyq2_trace_edges:
 lda vxq2_0lo
 sta xyq2_x0lo
 lda vxq2_0hi
 sta xyq2_x0hi
 lda vyq2_0lo
 sta xyq2_y0lo
 lda vyq2_0hi
 sta xyq2_y0hi
 lda vxq2_1lo
 sta xyq2_x1lo
 lda vxq2_1hi
 sta xyq2_x1hi
 lda vyq2_1lo
 sta xyq2_y1lo
 lda vyq2_1hi
 sta xyq2_y1hi
 jsr trace_edge_convex_xyq2
 lda vxq2_1lo
 sta xyq2_x0lo
 lda vxq2_1hi
 sta xyq2_x0hi
 lda vyq2_1lo
 sta xyq2_y0lo
 lda vyq2_1hi
 sta xyq2_y0hi
 lda vxq2_2lo
 sta xyq2_x1lo
 lda vxq2_2hi
 sta xyq2_x1hi
 lda vyq2_2lo
 sta xyq2_y1lo
 lda vyq2_2hi
 sta xyq2_y1hi
 jsr trace_edge_convex_xyq2
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne xyq2_trace_2_to_0
.endif
 lda vxq2_2lo
 sta xyq2_x0lo
 lda vxq2_2hi
 sta xyq2_x0hi
 lda vyq2_2lo
 sta xyq2_y0lo
 lda vyq2_2hi
 sta xyq2_y0hi
 lda vxq2_3lo
 sta xyq2_x1lo
 lda vxq2_3hi
 sta xyq2_x1hi
 lda vyq2_3lo
 sta xyq2_y1lo
 lda vyq2_3hi
 sta xyq2_y1hi
 jsr trace_edge_convex_xyq2
 lda vxq2_3lo
 sta xyq2_x0lo
 lda vxq2_3hi
 sta xyq2_x0hi
 lda vyq2_3lo
 sta xyq2_y0lo
 lda vyq2_3hi
 sta xyq2_y0hi
 lda vxq2_0lo
 sta xyq2_x1lo
 lda vxq2_0hi
 sta xyq2_x1hi
 lda vyq2_0lo
 sta xyq2_y1lo
 lda vyq2_0hi
 sta xyq2_y1hi
 jsr trace_edge_convex_xyq2
 jmp xyq2_validate_bounds
.if HAS_TRI_FACES != 0
xyq2_trace_2_to_0:
 lda vxq2_2lo
 sta xyq2_x0lo
 lda vxq2_2hi
 sta xyq2_x0hi
 lda vyq2_2lo
 sta xyq2_y0lo
 lda vyq2_2hi
 sta xyq2_y0hi
 lda vxq2_0lo
 sta xyq2_x1lo
 lda vxq2_0hi
 sta xyq2_x1hi
 lda vyq2_0lo
 sta xyq2_y1lo
 lda vyq2_0hi
 sta xyq2_y1hi
 jsr trace_edge_convex_xyq2
.endif
xyq2_validate_bounds:
 ldx face_ymin
xyq2_validate_loop:
 lda leftb,x
 cmp rightb,x
 bcc xyq2_face_yes
 beq xyq2_face_yes
 cpx face_ymax
 beq xyq2_face_no
 inx
 jmp xyq2_validate_loop
xyq2_face_yes:
 lda #$01
 sta xyq2_face_valid
xyq2_face_no:
 rts

xyq2_include_y:
 lda xyq2_nhi
 cmp xyq2_minhi
 bcc xyq2_store_min
 bne xyq2_test_max
 lda xyq2_nlo
 cmp xyq2_minlo
 bcc xyq2_store_min
xyq2_test_max:
 lda xyq2_nhi
 cmp xyq2_maxhi
 bcc xyq2_include_done
 bne xyq2_store_max
 lda xyq2_nlo
 cmp xyq2_maxlo
 bcc xyq2_include_done
 beq xyq2_include_done
xyq2_store_max:
 lda xyq2_nlo
 sta xyq2_maxlo
 lda xyq2_nhi
 sta xyq2_maxhi
 rts
xyq2_store_min:
 lda xyq2_nlo
 sta xyq2_minlo
 lda xyq2_nhi
 sta xyq2_minhi
xyq2_include_done:
 rts

trace_edge_convex_xyq2:
 jsr xyq2_assert_x_endpoints
 ; With integral Q2 Y endpoints, retain the complete DEV2 bridge trace.
 ; This is still the XY-Q2 builder: only its edge raster is RC4-equivalent.
 lda xyq2_y0lo
 ora xyq2_y1lo
 and #$03
 beq xyq2_integral
 lda xyq2_y0hi
 cmp xyq2_y1hi
 bcc xyq2_ordered
 bne xyq2_swap_endpoints
 lda xyq2_y0lo
 cmp xyq2_y1lo
 bcc xyq2_ordered
 bne xyq2_swap_endpoints
 jmp xyq2_horizontal
xyq2_swap_endpoints:
 ; Endpoint swaps are atomic pairs: both X bytes move with both Y bytes.
 lda xyq2_x0lo
 ldx xyq2_x1lo
 sta xyq2_x1lo
 stx xyq2_x0lo
 lda xyq2_x0hi
 ldx xyq2_x1hi
 sta xyq2_x1hi
 stx xyq2_x0hi
 lda xyq2_y0lo
 ldx xyq2_y1lo
 sta xyq2_y1lo
 stx xyq2_y0lo
 lda xyq2_y0hi
 ldx xyq2_y1hi
 sta xyq2_y1hi
 stx xyq2_y0hi
xyq2_ordered:
 ; dy = y1Q2-y0Q2, dx = x1Q2-x0Q2.
 sec
 lda xyq2_y1lo
 sbc xyq2_y0lo
 sta xyq2_dlo
 lda xyq2_y1hi
 sbc xyq2_y0hi
 sta xyq2_dhi
 sec
 lda xyq2_x1lo
 sbc xyq2_x0lo
 sta xyq2_dxlo
 lda xyq2_x1hi
 sbc xyq2_x0hi
 sta xyq2_dxhi
 ; firstEdgeRow=ceil(y0/4), lastEdgeRow=floor(y1/4), clamped 0..79.
 clc
 lda xyq2_y0lo
 adc #$03
 sta xyq2_nlo
 lda xyq2_y0hi
 adc #$00
 sta xyq2_nhi
 lsr xyq2_nhi
 ror xyq2_nlo
 lsr xyq2_nhi
 ror xyq2_nlo
 lda xyq2_nhi
 bne xyq2_edge_first_clamp
 lda xyq2_nlo
 cmp #$50
 bcc xyq2_edge_first_ok
xyq2_edge_first_clamp:
 lda #$4f
xyq2_edge_first_ok:
 sta xyq2_row
 lda xyq2_y1lo
 sta xyq2_nlo
 lda xyq2_y1hi
 sta xyq2_nhi
 lsr xyq2_nhi
 ror xyq2_nlo
 lsr xyq2_nhi
 ror xyq2_nlo
 lda xyq2_nhi
 bne xyq2_edge_last_clamp
 lda xyq2_nlo
 cmp #$50
 bcc xyq2_edge_last_ok
xyq2_edge_last_clamp:
 lda #$4f
xyq2_edge_last_ok:
 sta xyq2_lastrow
 lda xyq2_row
 cmp xyq2_lastrow
 bcc xyq2_edge_prepare
 beq xyq2_edge_prepare
 rts
xyq2_edge_prepare:
 ; delta = 4*firstEdgeRow-y0Q2, exact and constrained to 0..3.
 lda xyq2_row
 sta xyq2_nlo
 lda #$00
 sta xyq2_nhi
 asl xyq2_nlo
 rol xyq2_nhi
 asl xyq2_nlo
 rol xyq2_nhi
 sec
 lda xyq2_nlo
 sbc xyq2_y0lo
 sta xyq2_delta
 lda xyq2_nhi
 sbc xyq2_y0hi
 bne xyq2_walker_fault
 ; N0=dx*delta; B=x0+floor(N0/dy), R=N0 mod dy.
 lda #$00
 sta xyq2_nlo
 sta xyq2_nhi
 ldx xyq2_delta
xyq2_n0_loop:
 cpx #$00
 beq xyq2_n0_divide
 clc
 lda xyq2_nlo
 adc xyq2_dxlo
 sta xyq2_nlo
 lda xyq2_nhi
 adc xyq2_dxhi
 sta xyq2_nhi
 dex
 jmp xyq2_n0_loop
xyq2_n0_divide:
 lda xyq2_dlo
 sta xyq2_divlo
 lda xyq2_dhi
 sta xyq2_divhi
.if YQ2_FAST_DIV11X8 != 0
 lda xyq2_divhi
 bne xyq2_n0_divide_slow
 jsr xyq2_div_signed_euclid_11x8
 jmp xyq2_n0_divide_done
xyq2_n0_divide_slow:
.endif
 jsr xyq2_div_signed_euclid
xyq2_n0_divide_done:
 clc
 lda xyq2_x0lo
 adc xyq2_qlo
 sta xyq2_blo
 lda xyq2_x0hi
 adc xyq2_qhi
 sta xyq2_bhi
 ; Keep R0 separate while NS=4*dx is divided into S and RS.
 lda xyq2_rlo
 sta xyq2_r0lo
 lda xyq2_rhi
 sta xyq2_r0hi
 lda xyq2_dxlo
 sta xyq2_nlo
 lda xyq2_dxhi
 sta xyq2_nhi
 asl xyq2_nlo
 rol xyq2_nhi
 asl xyq2_nlo
 rol xyq2_nhi
 lda xyq2_dlo
 sta xyq2_divlo
 lda xyq2_dhi
 sta xyq2_divhi
.if YQ2_FAST_DIV11X8 != 0
 lda xyq2_divhi
 bne xyq2_ns_divide_slow
 jsr xyq2_div_signed_euclid_11x8
 jmp xyq2_ns_divide_done
xyq2_ns_divide_slow:
.endif
 jsr xyq2_div_signed_euclid
xyq2_ns_divide_done:
 lda xyq2_qlo
 sta xyq2_slo
 lda xyq2_qhi
 sta xyq2_shi
 lda xyq2_rlo
 sta xyq2_rslo
 lda xyq2_rhi
 sta xyq2_rshi
 lda xyq2_r0lo
 sta xyq2_rlo
 lda xyq2_r0hi
 sta xyq2_rhi
xyq2_edge_row_loop:
 jsr xyq2_pixel_from_exact
.if YQ2_INLINE_BOUNDS != 0
 ldx xyq2_row
 cmp leftb,x
 bcs xyq2_inline_left_ok
 sta leftb,x
xyq2_inline_left_ok:
 cmp rightb,x
 bcc xyq2_inline_bounds_done
 sta rightb,x
xyq2_inline_bounds_done:
.else
 ldx xyq2_row
 jsr update_convex_bounds
.endif
 ; Emit exactly one geometric crossing on this sample-row.  The final
 ; row is complete and must not advance the rational state any further.
 lda xyq2_row
 cmp xyq2_lastrow
 beq xyq2_edge_done
 ; Bnext=B+S, Rnext=R+RS.  This position belongs to the next row only.
 clc
 lda xyq2_blo
 adc xyq2_slo
 sta xyq2_blo
 lda xyq2_bhi
 adc xyq2_shi
 sta xyq2_bhi
 clc
 lda xyq2_rlo
 adc xyq2_rslo
 sta xyq2_rlo
 lda xyq2_rhi
 adc xyq2_rshi
 sta xyq2_rhi
 lda xyq2_rhi
 cmp xyq2_dhi
 bcc xyq2_next_row
 bne xyq2_reduce_remainder
 lda xyq2_rlo
 cmp xyq2_dlo
 bcc xyq2_next_row
xyq2_reduce_remainder:
 sec
 lda xyq2_rlo
 sbc xyq2_dlo
 sta xyq2_rlo
 lda xyq2_rhi
 sbc xyq2_dhi
 sta xyq2_rhi
 inc xyq2_blo
 bne xyq2_next_row
 inc xyq2_bhi
xyq2_next_row:
 inc xyq2_row
 jmp xyq2_edge_row_loop
xyq2_edge_done:
 rts

xyq2_horizontal:
 lda xyq2_y0lo
 and #$03
 bne xyq2_edge_done
 lda xyq2_y0lo
 sta xyq2_nlo
 lda xyq2_y0hi
 sta xyq2_nhi
 lsr xyq2_nhi
 ror xyq2_nlo
 lsr xyq2_nhi
 ror xyq2_nlo
 lda xyq2_nhi
 bne xyq2_edge_done
 lda xyq2_nlo
 cmp #$50
 bcs xyq2_edge_done
 lda xyq2_x0lo
 sta q2_x0lo
 lda xyq2_x0hi
 sta q2_x0hi
 lda xyq2_x1lo
 sta q2_x1lo
 lda xyq2_x1hi
 sta q2_x1hi
 lda xyq2_nlo
 sta ey0
 sta ey1
 jsr trace_edge_convex_xq2
 rts

xyq2_integral:
 lda xyq2_x0lo
 sta q2_x0lo
 lda xyq2_x0hi
 sta q2_x0hi
 lda xyq2_x1lo
 sta q2_x1lo
 lda xyq2_x1hi
 sta q2_x1hi
 lda xyq2_y0lo
 sta t1
 lda xyq2_y0hi
 sta t2
 lsr t2
 ror t1
 lsr t2
 ror t1
 lda t1
 sta ey0
 lda xyq2_y1lo
 sta t1
 lda xyq2_y1hi
 sta t2
 lsr t2
 ror t1
 lsr t2
 ror t1
 lda t1
 sta ey1
 jsr trace_edge_convex_xq2
 rts


; pixel=floor((B+R/D+2)/4) without discarding R/D:
; base=floor(B/4), phase=B mod 4,
; pixel=base+floor((phase*D+R+2*D)/(4*D)).
xyq2_pixel_from_exact:
 lda xyq2_bhi
 bmi xyq2_walker_fault
.if YQ2_FAST_PIXEL_CONVERT != 0
 jmp xyq2_pixel_fast
.endif
 lda xyq2_blo
 and #$03
 sta xyq2_phase
 lda xyq2_blo
 sta xyq2_nlo
 lda xyq2_bhi
 sta xyq2_nhi
 lsr xyq2_nhi
 ror xyq2_nlo
 lsr xyq2_nhi
 ror xyq2_nlo
 lda xyq2_nlo
 sta xyq2_base
 lda xyq2_rlo
 sta xyq2_r0lo
 lda xyq2_rhi
 sta xyq2_r0hi
 lda #$00
 sta xyq2_nlo
 sta xyq2_nhi
 ldx xyq2_phase
xyq2_phase_loop:
 cpx #$00
 beq xyq2_phase_done
 clc
 lda xyq2_nlo
 adc xyq2_dlo
 sta xyq2_nlo
 lda xyq2_nhi
 adc xyq2_dhi
 sta xyq2_nhi
 dex
 jmp xyq2_phase_loop
xyq2_phase_done:
 clc
 lda xyq2_nlo
 adc xyq2_r0lo
 sta xyq2_nlo
 lda xyq2_nhi
 adc xyq2_r0hi
 sta xyq2_nhi
 clc
 lda xyq2_nlo
 adc xyq2_dlo
 sta xyq2_nlo
 lda xyq2_nhi
 adc xyq2_dhi
 sta xyq2_nhi
 clc
 lda xyq2_nlo
 adc xyq2_dlo
 sta xyq2_nlo
 lda xyq2_nhi
 adc xyq2_dhi
 sta xyq2_nhi
 lda xyq2_dlo
 sta xyq2_divlo
 lda xyq2_dhi
 sta xyq2_divhi
 asl xyq2_divlo
 rol xyq2_divhi
 asl xyq2_divlo
 rol xyq2_divhi
 jsr xyq2_div_unsigned
 lda xyq2_r0lo
 sta xyq2_rlo
 lda xyq2_r0hi
 sta xyq2_rhi
 lda xyq2_qhi
 bne xyq2_walker_fault
 clc
 lda xyq2_base
 adc xyq2_qlo
 bcs xyq2_walker_fault
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs xyq2_walker_fault
 rts

.if YQ2_FAST_PIXEL_CONVERT != 0
; R remains live for the rational walker; it cannot affect floor here because
; 0<=R<D and the numerator is shifted by two complete Q2 bits.
xyq2_pixel_fast:
 clc
 lda xyq2_blo
 adc #$02
 sta xyq2_nlo
 lda xyq2_bhi
 adc #$00
 sta xyq2_nhi
 lsr xyq2_nhi
 ror xyq2_nlo
 lsr xyq2_nhi
 ror xyq2_nlo
 lda xyq2_nlo
 cmp #(PROJ_SCREEN_MAX_X + 1)
 bcs xyq2_walker_fault
 rts
.endif

.if YQ2_FAST_DIV11X8 != 0
; Exact signed Euclidean 11-bit / 8-bit restoring divmod for |N|<=2032.
xyq2_div_signed_euclid_11x8:
 lda #$00
 sta xyq2_negative
 lda xyq2_nhi
 bpl xyq2_div11_abs_ready
 sec
 lda #$00
 sbc xyq2_nlo
 sta xyq2_nlo
 lda #$00
 sbc xyq2_nhi
 sta xyq2_nhi
 lda #$01
 sta xyq2_negative
xyq2_div11_abs_ready:
 lda xyq2_nlo
 sta xyq2_qlo
 lda xyq2_nhi
 sta xyq2_qhi
 ldx #$05
xyq2_div11_align:
 asl xyq2_qlo
 rol xyq2_qhi
 dex
 bne xyq2_div11_align
 lda #$00
 sta xyq2_rlo
 sta xyq2_rhi
 ldx #$0b
xyq2_div11_loop:
 asl xyq2_qlo
 rol xyq2_qhi
 rol xyq2_rlo
 rol xyq2_rhi
 lda xyq2_rhi
 bne xyq2_div11_sub
 lda xyq2_rlo
 cmp xyq2_divlo
 bcc xyq2_div11_skip
xyq2_div11_sub:
 sec
 lda xyq2_rlo
 sbc xyq2_divlo
 sta xyq2_rlo
 lda xyq2_rhi
 sbc #$00
 sta xyq2_rhi
 lda xyq2_qlo
 ora #$01
 sta xyq2_qlo
xyq2_div11_skip:
 dex
 bne xyq2_div11_loop
 lda xyq2_negative
 beq xyq2_div11_done
 lda xyq2_rlo
 ora xyq2_rhi
 beq xyq2_div11_neg_exact
 sec
 lda xyq2_divlo
 sbc xyq2_rlo
 sta xyq2_rlo
 lda #$00
 sbc xyq2_rhi
 sta xyq2_rhi
 sec
 lda #$00
 sbc xyq2_qlo
 sta xyq2_qlo
 lda #$00
 sbc xyq2_qhi
 sta xyq2_qhi
 lda xyq2_qlo
 bne xyq2_div11_neg_dec
 dec xyq2_qhi
xyq2_div11_neg_dec:
 dec xyq2_qlo
 jmp xyq2_div11_done
xyq2_div11_neg_exact:
 sec
 lda #$00
 sbc xyq2_qlo
 sta xyq2_qlo
 lda #$00
 sbc xyq2_qhi
 sta xyq2_qhi
xyq2_div11_done:
 rts
.endif

; Signed Euclidean division: q=floor(N/D), r=N-q*D, 0<=r<D.
xyq2_div_signed_euclid:
 lda #$00
 sta xyq2_negative
 lda xyq2_nhi
 bpl xyq2_div_signed_positive
 sec
 lda #$00
 sbc xyq2_nlo
 sta xyq2_nlo
 lda #$00
 sbc xyq2_nhi
 sta xyq2_nhi
 lda #$01
 sta xyq2_negative
 jmp xyq2_div_unsigned_core
xyq2_div_unsigned:
 lda #$00
 sta xyq2_negative
xyq2_div_signed_positive:
 jmp xyq2_div_unsigned_core
xyq2_div_unsigned_core:
 lda xyq2_nlo
 sta xyq2_qlo
 lda xyq2_nhi
 sta xyq2_qhi
 lda #$00
 sta xyq2_rlo
 sta xyq2_rhi
 ldx #$10
xyq2_div_loop:
 asl xyq2_qlo
 rol xyq2_qhi
 rol xyq2_rlo
 rol xyq2_rhi
 lda xyq2_rhi
 cmp xyq2_divhi
 bcc xyq2_div_skip
 bne xyq2_div_subtract
 lda xyq2_rlo
 cmp xyq2_divlo
 bcc xyq2_div_skip
xyq2_div_subtract:
 sec
 lda xyq2_rlo
 sbc xyq2_divlo
 sta xyq2_rlo
 lda xyq2_rhi
 sbc xyq2_divhi
 sta xyq2_rhi
 ; ASL above guarantees quotient bit 0 is clear.  Set that bit directly:
 ; q is a complete 16-bit word, never a byte-sized increment.
 lda xyq2_qlo
 ora #$01
 sta xyq2_qlo
xyq2_div_skip:
 dex
 bne xyq2_div_loop
 lda xyq2_negative
 beq xyq2_div_done
 lda xyq2_rlo
 ora xyq2_rhi
 beq xyq2_div_neg_exact
 sec
 lda xyq2_divlo
 sbc xyq2_rlo
 sta xyq2_rlo
 lda xyq2_divhi
 sbc xyq2_rhi
 sta xyq2_rhi
 sec
 lda #$00
 sbc xyq2_qlo
 sta xyq2_qlo
 lda #$00
 sbc xyq2_qhi
 sta xyq2_qhi
 lda xyq2_qlo
 bne xyq2_div_neg_decrement
 dec xyq2_qhi
xyq2_div_neg_decrement:
 dec xyq2_qlo
 jmp xyq2_div_done
xyq2_div_neg_exact:
 sec
 lda #$00
 sbc xyq2_qlo
 sta xyq2_qlo
 lda #$00
 sbc xyq2_qhi
 sta xyq2_qhi
xyq2_div_done:
 rts

xyq2_assert_x_endpoints:
 lda xyq2_x0hi
 beq xyq2_x0_low
 cmp #>(PROJ_SCREEN_MAX_X * 4)
.if PROJ_SCREEN_MAX_X > $7f
 bcc xyq2_x0_low
.endif
 bne xyq2_walker_fault
 lda xyq2_x0lo
 cmp #(<(PROJ_SCREEN_MAX_X * 4) + 1)
 bcs xyq2_walker_fault
xyq2_x0_low:
 lda xyq2_x1hi
 beq xyq2_x1_low
 cmp #>(PROJ_SCREEN_MAX_X * 4)
.if PROJ_SCREEN_MAX_X > $7f
 bcc xyq2_x1_low
.endif
 bne xyq2_walker_fault
 lda xyq2_x1lo
 cmp #(<(PROJ_SCREEN_MAX_X * 4) + 1)
 bcs xyq2_walker_fault
xyq2_x1_low:
 rts


; A coordinate outside the selected viewport is a walker contract violation;
; never disguise it with a fixed-width pixel clamp.  It must also never execute
; BRK: a BRK hands control to BASIC and abandons all nested JSR return slots.
; Restore the builder-entry stack pointer, invalidate only this face, and
; return to the ordinary per-face caller instead.
xyq2_walker_fault:
 ; Final builds never discard a face silently. A contract violation remains
 ; terminal, but it carries no diagnostic color or viewport marker.
 sei
xyq2_final_fault_halt:
 jmp xyq2_final_fault_halt
'@ } else { '' }
 $solidSubpixelXYQ2Asm = $solidSubpixelXYQ2Asm.Replace('#$50', '#YQ2_VIEWPORT_ROW_COUNT').Replace('#$4f', '#YQ2_VIEWPORT_ROW_MAX')
 $solidSubpixelRoutinesAsm += "`r`n" + $solidSubpixelXYQ2Asm

 $asm = [regex]::Replace($asm, '(?m)^object_traverse_active = \$a4\r?\nnear_face_crossing = \$a5', (@'
object_traverse_active = $a4
near_face_crossing = $a5
q2_x0lo = ex0
q2_x0hi = ex1
q2_x1lo = m02
q2_x1hi = m10
q2_step_lo = prodlo
q2_step_hi = prodhi
q2_remainder = errlo
q2_rem_step = errhi
vxq2_0lo = rx0
vxq2_0hi = ry0
vxq2_1lo = rz0
vxq2_1hi = rx1
vxq2_2lo = ry1
vxq2_2hi = rz1
vxq2_3lo = m00
vxq2_3hi = m01
'@).Replace('$', '$$'))
 if ($SolidSubpixelYQ2Flag -ne 0) {
  $solidSubpixelYEndpointAliases = if ($SolidSubpixelYMobileNativeFlag -ne 0) { @'
vyq2_0lo = $a6
vyq2_0hi = $a7
vyq2_1lo = $a8
vyq2_1hi = $a9
vyq2_2lo = $aa
vyq2_2hi = $ab
vyq2_3lo = $ac
vyq2_3hi = $ad
.if vyq2_0lo <= near_face_crossing || vyq2_3hi != vyq2_0lo + 7
 .error "MobileNative endpoint Y-Q2 scratch must be private contiguous zero page above clipping state"
.endif
'@ } else { @'
vyq2_0lo = clip_in_x
vyq2_0hi = clip_in_y
vyq2_1lo = clip_out_y
vyq2_1hi = clip_num
vyq2_2lo = clip_den
vyq2_2hi = clip_second_pending
vyq2_3lo = clip_second_count
vyq2_3hi = clip2_vx0
'@ }
  $asm = $asm.Replace('vxq2_3hi = m01', ("vxq2_3hi = m01`r`n" + $solidSubpixelYEndpointAliases))
 }
 if ($SolidSubpixelXLegacyDirectFlag -ne 0) {
  $asm = $asm.Replace('vxq2_3hi = m01', @'
vxq2_3hi = m01
.if vxq2_0lo = vxq2_0hi || vxq2_0lo = vxq2_1lo || vxq2_0lo = vxq2_1hi || vxq2_0lo = vxq2_2lo || vxq2_0lo = vxq2_2hi || vxq2_0lo = vxq2_3lo || vxq2_0lo = vxq2_3hi || vxq2_0hi = vxq2_1lo || vxq2_0hi = vxq2_1hi || vxq2_0hi = vxq2_2lo || vxq2_0hi = vxq2_2hi || vxq2_0hi = vxq2_3lo || vxq2_0hi = vxq2_3hi || vxq2_1lo = vxq2_1hi || vxq2_1lo = vxq2_2lo || vxq2_1lo = vxq2_2hi || vxq2_1lo = vxq2_3lo || vxq2_1lo = vxq2_3hi || vxq2_1hi = vxq2_2lo || vxq2_1hi = vxq2_2hi || vxq2_1hi = vxq2_3lo || vxq2_1hi = vxq2_3hi || vxq2_2lo = vxq2_2hi || vxq2_2lo = vxq2_3lo || vxq2_2lo = vxq2_3hi || vxq2_2hi = vxq2_3lo || vxq2_2hi = vxq2_3hi || vxq2_3lo = vxq2_3hi
 .error "LegacyDirect endpoint Q2 scratch aliases"
.endif
.if q2_x0lo > $a5 || q2_x0hi > $a5 || q2_x1lo > $a5 || q2_x1hi > $a5 || q2_step_lo > $a5 || q2_step_hi > $a5 || q2_remainder > $a5 || q2_rem_step > $a5
 .error "LegacyDirect walker Q2 zero-page state is outside the private range"
.endif
'@)
 }
 if ($SolidSubpixelXLegacyDirectFlag -eq 0) {
  $asm = [regex]::Replace($asm, '(?m)^ jsr smooth_projected_vertex\r?\n(?= lda #\$01\r?\n sta projdone,y)', " jsr smooth_projected_vertex`r`n jsr solid_subpixel_xq2_store`r`n")
 }
 if ($SolidSubpixelYBufferedSourceFlag -ne 0) {
  $asm = [regex]::Replace($asm, '(?m)^ jsr smooth_projected_vertex\r?\n(?=(?: jsr solid_subpixel_xq2_store\r?\n)? lda #\$01\r?\n sta projdone,y)', " jsr smooth_projected_vertex`r`n jsr solid_subpixel_yq2_store`r`n")
 }
 if ($SolidSubpixelYMobileNativeFlag -ne 0) {
  $asm = [regex]::Replace($asm, '(?m)^explorer_project_y16:', ($solidSubpixelMobileYAsm.Replace('$', '$$') + "`r`nexplorer_project_y16:"))
  $mobileProjectionCall = @'
 lda explorer_view_y_lo
 sta p1lo
 lda explorer_view_y_hi
 sta p1hi
 jsr explorer_project_yq2_16
'@
  $asm = [regex]::Replace($asm, '(?m)^ lda explorer_view_y_lo\r?\n sta p1lo\r?\n lda explorer_view_y_hi\r?\n sta p1hi\r?\n jsr explorer_project_y16$', $mobileProjectionCall)
  $asm = $asm.Replace('; mode-4/fixed/small/stable X=LegacyDirect, Y=Native configuration.', '; mode-4/small/stable X=LegacyDirect with fixed Native or Phase-1 MobileNative Y.')
 }
 $asm = [regex]::Replace($asm, '(?s)load_face_y:\r?\n.*?(?=load_face_y_clip:)', (@'
load_face_y:
 lda face0,y
 tax
 lda sx,x
 sta vx0
 lda sy,x
 sta vy0
 lda sxq2_lo,x
 sta vxq2_0lo
 lda sxq2_hi,x
 sta vxq2_0hi
 lda face1,y
 tax
 lda sx,x
 sta vx1
 lda sy,x
 sta vy1
 lda sxq2_lo,x
 sta vxq2_1lo
 lda sxq2_hi,x
 sta vxq2_1hi
 lda face2,y
 tax
 lda sx,x
 sta vx2
 lda sy,x
 sta vy2
 lda sxq2_lo,x
 sta vxq2_2lo
 lda sxq2_hi,x
 sta vxq2_2hi
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 sta loaded_face_vertex_count
 cmp #$04
 beq load_face_y_v3
 lda vx2
 sta vx3
 lda vy2
 sta vy3
 lda vxq2_2lo
 sta vxq2_3lo
 lda vxq2_2hi
 sta vxq2_3hi
 jmp load_face_y_clip
load_face_y_v3:
.else
 lda #$04
 sta loaded_face_vertex_count
.endif
 lda face3,y
 tax
 lda sx,x
 sta vx3
 lda sy,x
 sta vy3
 lda sxq2_lo,x
 sta vxq2_3lo
 lda sxq2_hi,x
 sta vxq2_3hi

'@).Replace('$', '$$'))
 if ($SolidSubpixelXLegacyDirectFlag -ne 0) {
  $asm = [regex]::Replace($asm, '(?s)load_face_y:\r?\n.*?(?=load_face_y_clip:)', (@'
load_face_y:
 lda face0,y
 tax
 lda sx,x
 sta vx0
 sta vxq2_0lo
 lda #$00
 sta vxq2_0hi
 asl vxq2_0lo
 rol vxq2_0hi
 asl vxq2_0lo
 rol vxq2_0hi
 lda sy,x
 sta vy0
 lda face1,y
 tax
 lda sx,x
 sta vx1
 sta vxq2_1lo
 lda #$00
 sta vxq2_1hi
 asl vxq2_1lo
 rol vxq2_1hi
 asl vxq2_1lo
 rol vxq2_1hi
 lda sy,x
 sta vy1
 lda face2,y
 tax
 lda sx,x
 sta vx2
 sta vxq2_2lo
 lda #$00
 sta vxq2_2hi
 asl vxq2_2lo
 rol vxq2_2hi
 asl vxq2_2lo
 rol vxq2_2hi
 lda sy,x
 sta vy2
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
 sta loaded_face_vertex_count
 cmp #$04
 beq load_face_y_v3
 lda vx2
 sta vx3
 lda vy2
 sta vy3
 lda vxq2_2lo
 sta vxq2_3lo
 lda vxq2_2hi
 sta vxq2_3hi
 jmp load_face_y_clip
load_face_y_v3:
.else
 lda #$04
 sta loaded_face_vertex_count
.endif
 lda face3,y
 tax
 lda sx,x
 sta vx3
 sta vxq2_3lo
 lda #$00
 sta vxq2_3hi
 asl vxq2_3lo
 rol vxq2_3hi
 asl vxq2_3lo
 rol vxq2_3hi
 lda sy,x
 sta vy3

'@).Replace('$', '$$'))
 }
 if ($SolidSubpixelYQ2Flag -ne 0) {
  if ($SolidSubpixelYMobileNativeFlag -ne 0) {
   # Phase 1 is deliberately scoped to the four original endpoints loaded by
   # load_face_y.  Other legacy loads belong to clipping/fan code and must not
   # gain Y-Q2 reads or writes.
   $loadFaceYMatch = [regex]::Match($asm, '(?s)load_face_y:\r?\n.*?(?=load_face_y_clip:)')
   if (-not $loadFaceYMatch.Success) {
    throw "Phase-1 MobileNative could not isolate load_face_y"
   }
   $loadFaceYBlock = $loadFaceYMatch.Value
   $mobileClipStateReset = @'
load_face_y:
.if EXPLORER_SCREEN_CLIP_X != 0
 lda #$00
 sta clip_second_pending
.endif
.if EXPLORER_SCREEN_CLIP_POLY != 0
 lda #$00
 sta clip_poly_active
.endif
'@
   $loadFaceYBlock = [regex]::Replace($loadFaceYBlock, '(?m)^load_face_y:\r?\n', ($mobileClipStateReset.Replace('$', '$$') + "`r`n"))
   foreach ($endpoint in 0..3) {
    $mobileNativeY = "lda sy,x`r`n sta vy$endpoint`r`n lda syq2_lo,x`r`n sta vyq2_${endpoint}lo`r`n lda syq2_hi,x`r`n sta vyq2_${endpoint}hi"
    $loadFaceYBlock = [regex]::Replace($loadFaceYBlock, ("lda sy,x\r?\n sta vy{0}" -f $endpoint), $mobileNativeY.Replace('$', '$$'))
   }
   $asm = $asm.Substring(0, $loadFaceYMatch.Index) + $loadFaceYBlock + $asm.Substring($loadFaceYMatch.Index + $loadFaceYMatch.Length)
  } else {
   foreach ($endpoint in 0..3) {
    $legacyY = "lda sy,x`r`n sta vy$endpoint`r`n sta vyq2_${endpoint}lo`r`n lda #`$00`r`n sta vyq2_${endpoint}hi`r`n asl vyq2_${endpoint}lo`r`n rol vyq2_${endpoint}hi`r`n asl vyq2_${endpoint}lo`r`n rol vyq2_${endpoint}hi"
    $nativeY = "lda sy,x`r`n sta vy$endpoint`r`n lda syq2_lo,x`r`n sta vyq2_${endpoint}lo`r`n lda syq2_hi,x`r`n sta vyq2_${endpoint}hi`r`n clc`r`n lda vyq2_${endpoint}lo`r`n adc #`$02`r`n sta t1`r`n lda vyq2_${endpoint}hi`r`n adc #`$00`r`n sta t2`r`n lsr t2`r`n ror t1`r`n lsr t2`r`n ror t1`r`n lda t1`r`n sta vy$endpoint"
    $replacement = if ($SolidSubpixelYBufferedSourceFlag -ne 0) { $nativeY } else { $legacyY }
    # Keep the fixed-camera DEV9 substitution byte-for-byte unchanged.
    $asm = [regex]::Replace($asm, ("lda sy,x\r?\n sta vy{0}" -f $endpoint), $replacement.Replace('$', '$$'))
   }
  }
 }
 if ($SolidSubpixelXYQ2LegacyDirectYFlag -ne 0) {
  # The emitted base listing contains the gated branch; keep every legacy
  # builder byte intact and route only the supported XY-Q2 configuration.
  $null = $null
 } else {
 $asm = [regex]::Replace($asm, '(?s)(build_loaded_face_bounds_convex:\r?\n.*?bltc_init_done:\r?\n).*?(?=\.endif\r?\n\r?\nupdate_convex_bounds:)', ('${1}' + (@'
 lda vxq2_0lo
 sta q2_x0lo
 lda vxq2_0hi
 sta q2_x0hi
 lda vy0
 sta ey0
 lda vxq2_1lo
 sta q2_x1lo
 lda vxq2_1hi
 sta q2_x1hi
 lda vy1
 sta ey1
 jsr trace_edge_convex_xq2
 lda vxq2_1lo
 sta q2_x0lo
 lda vxq2_1hi
 sta q2_x0hi
 lda vy1
 sta ey0
 lda vxq2_2lo
 sta q2_x1lo
 lda vxq2_2hi
 sta q2_x1hi
 lda vy2
 sta ey1
 jsr trace_edge_convex_xq2
 lda vxq2_2lo
 sta q2_x0lo
 lda vxq2_2hi
 sta q2_x0hi
 lda vy2
 sta ey0
.if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #$04
 bne blfc_trace_2_to_0
.endif
 lda vxq2_3lo
 sta q2_x1lo
 lda vxq2_3hi
 sta q2_x1hi
 lda vy3
 sta ey1
 jsr trace_edge_convex_xq2
 lda vxq2_3lo
 sta q2_x0lo
 lda vxq2_3hi
 sta q2_x0hi
 lda vy3
 sta ey0
 lda vxq2_0lo
 sta q2_x1lo
 lda vxq2_0hi
 sta q2_x1hi
 lda vy0
 sta ey1
 jsr trace_edge_convex_xq2
 rts
.if HAS_TRI_FACES != 0
blfc_trace_2_to_0:
 lda vxq2_0lo
 sta q2_x1lo
 lda vxq2_0hi
 sta q2_x1hi
 lda vy0
 sta ey1
 jsr trace_edge_convex_xq2
 rts
.endif
'@).Replace('$', '$$') + "`n"))
 }
 if ($SolidSubpixelYMobileNativeFlag -ne 0) {
  $mobileBoundsDispatch = @'
build_loaded_face_bounds_convex:
.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0
 jsr mobile_yq2_face_eligible
 bcs blfbc_mobile_yq2
 ; A clipped/synthetic polygon keeps the pre-Phase-1 integer bounds path.
 lda #$01
 sta xyq2_face_valid
 jmp build_loaded_face_bounds_convex_legacy
blfbc_mobile_yq2:
 jmp build_loaded_face_bounds_xyq2
.endif
build_loaded_face_bounds_convex_legacy:
'@
  $asm = [regex]::Replace($asm, '(?m)^build_loaded_face_bounds_convex:\r?\n\.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0\r?\n jmp build_loaded_face_bounds_xyq2\r?\n\.endif\r?\n', ($mobileBoundsDispatch.Replace('$', '$$') + "`r`n"))
 }
 $asm = [regex]::Replace($asm, '(?s)sx = RUNTIME_BUFFER_BASE\r?\nsy = sx \+ VERT_COUNT\r?\n.*?(?=\.if EXPLORER_NEAR_POLY != 0)', (@'
sx = RUNTIME_BUFFER_BASE
sy = sx + VERT_COUNT
sxq2_lo = sy + VERT_COUNT
sxq2_hi = sxq2_lo + VERT_COUNT
RUNTIME_AFTER_SXQ2 = sxq2_hi + VERT_COUNT
.if EXPLORER_SCREEN_RAW != 0
pxrawlo = RUNTIME_AFTER_SXQ2
pxrawhi = pxrawlo + VERT_COUNT
pyrawlo = pxrawhi + VERT_COUNT
pyrawhi = pyrawlo + VERT_COUNT
RUNTIME_AFTER_RAW = pyrawhi + VERT_COUNT
.else
RUNTIME_AFTER_RAW = RUNTIME_AFTER_SXQ2
.endif
'@ + "`n"))
 if ($SolidSubpixelXLegacyDirectFlag -ne 0) {
  $asm = [regex]::Replace($asm, '(?m)^sxq2_lo = sy \+ VERT_COUNT\r?\nsxq2_hi = sxq2_lo \+ VERT_COUNT\r?\nRUNTIME_AFTER_SXQ2 = sxq2_hi \+ VERT_COUNT$', 'RUNTIME_AFTER_SXQ2 = sy + VERT_COUNT')
 }
 if ($SolidSubpixelYQ2Flag -ne 0) {
  $asm = [regex]::Replace($asm, '(?m)^RUNTIME_AFTER_SXQ2 = (.+)$', ('syq2_lo = $1' + "`r`n" + 'syq2_hi = syq2_lo + VERT_COUNT' + "`r`n" + 'RUNTIME_AFTER_SXQ2 = syq2_hi + VERT_COUNT' + "`r`n" + '.if syq2_lo < $0100 || syq2_hi != syq2_lo + VERT_COUNT || RUNTIME_AFTER_SXQ2 != syq2_hi + VERT_COUNT' + "`r`n" + ' .error "Y-Q2 runtime buffers must be complete non-zero-page VERT_COUNT ranges"' + "`r`n" + '.endif'))
 }
 $asm = $asm.Replace('; Mesh data is generated below by the build script.', ($solidSubpixelStoreAsm + "`r`n" + $solidSubpixelYStoreAsm + "`r`n" + $solidSubpixelRoutinesAsm + "`r`n; Mesh data is generated below by the build script."))
}

$asm = $asm.Replace('; PROJECTION_CONTRACT_FOCAL=170', ('; PROJECTION_CONTRACT_FOCAL=' + $ProjectionContract.Focal))
$asm = $asm.Replace('; PROJECTION_CONTRACT_CENTER_X=80', ('; PROJECTION_CONTRACT_CENTER_X=' + $ProjectionContract.ScreenCenterX))
$asm = $asm.Replace('; PROJECTION_CONTRACT_CENTER_Y=50', ('; PROJECTION_CONTRACT_CENTER_Y=' + $ProjectionContract.ScreenCenterY))
$asm = $asm.Replace('; PROJECTION_CONTRACT_SCREEN_MAX_X=159', ('; PROJECTION_CONTRACT_SCREEN_MAX_X=' + $ProjectionContract.ScreenMaxX))
$asm = $asm.Replace('; PROJECTION_CONTRACT_SCREEN_MAX_Y=99', ('; PROJECTION_CONTRACT_SCREEN_MAX_Y=' + $ProjectionContract.ScreenMaxY))
$asm = $asm.Replace('PROJ_FOCAL = $aa', ('PROJ_FOCAL = ' + (ByteHex $ProjectionContract.Focal)))
if ($Mode4LateNearRequested -or $Mode4CameraPlaneClipRequested) {
 $asm = $asm.Replace('PROJ_CAMERA_FACE_MIN_DEPTH = $08', ('PROJ_CAMERA_FACE_MIN_DEPTH = ' + (ByteHex $Mode4ProjectionMinDivisor)))
 $asm = $asm.Replace('CAMERA_PLANE_CLIP_PROFILE = $00', ('CAMERA_PLANE_CLIP_PROFILE = ' + (ByteHex $CameraPlaneClipProfileFlag)))
 $asm = $asm.Replace('CAMERA_FACE_MIN_DEPTH = PROJ_CAMERA_FACE_MIN_DEPTH', ('CAMERA_FACE_MIN_DEPTH = ' + (ByteHex $Mode4ClipMinDepth)))
}
$asm = $asm.Replace('CAMERA_SPACE_FACE_CULL_SUPPORT = $00', ('CAMERA_SPACE_FACE_CULL_SUPPORT = ' + (ByteHex $CameraSpaceFaceCullSupportFlag)))
$asm = $asm.Replace('STABLE_FACE_CULL_PROFILE = $00', ('STABLE_FACE_CULL_PROFILE = ' + (ByteHex $StableFaceCullProfileFlag)))
$cameraPlaneCullTablesAsm = ""
if ($CameraPlaneClipProfileFlag -ne 0) {
 $cameraPlaneCullTablesAsm += Add-Bytes "camera_plane_cull_normal_x" ([int[]]$cameraPlaneCullNormalX)
 $cameraPlaneCullTablesAsm += Add-Bytes "camera_plane_cull_normal_y" ([int[]]$cameraPlaneCullNormalY)
 $cameraPlaneCullTablesAsm += Add-Bytes "camera_plane_cull_normal_z" ([int[]]$cameraPlaneCullNormalZ)
}
$asm = $asm.Replace('; CAMERA_PLANE_CULL_NORMAL_TABLES', $cameraPlaneCullTablesAsm.TrimEnd())
$asm = $asm.Replace('PROJ_VIEW_DEPTH_BIAS = $be', ('PROJ_VIEW_DEPTH_BIAS = ' + (ByteHex ($ProjectionContract.ViewDepthProjectionIndexBias -band 255))))
$asm = $asm.Replace('PROJ_VIEW_DEPTH_BIAS_HI = $00', ('PROJ_VIEW_DEPTH_BIAS_HI = ' + (ByteHex (($ProjectionContract.ViewDepthProjectionIndexBias -shr 8) -band 255))))
$asm = $asm.Replace('PROJ_CENTER_X = $50', ('PROJ_CENTER_X = ' + (ByteHex $ProjectionContract.ScreenCenterX)))
$asm = $asm.Replace('PROJ_CENTER_Y = $32', ('PROJ_CENTER_Y = ' + (ByteHex $ProjectionContract.ScreenCenterY)))
$asm = $asm.Replace('PROJ_SCREEN_MIN_X = $00', ('PROJ_SCREEN_MIN_X = ' + (ByteHex $ProjectionContract.ScreenMinX)))
$asm = $asm.Replace('PROJ_SCREEN_MAX_X = $9f', ('PROJ_SCREEN_MAX_X = ' + (ByteHex $ProjectionContract.ScreenMaxX)))
$asm = $asm.Replace('PROJ_SCREEN_MIN_Y = $00', ('PROJ_SCREEN_MIN_Y = ' + (ByteHex $ProjectionContract.ScreenMinY)))
$asm = $asm.Replace('PROJ_SCREEN_MAX_Y = $63', ('PROJ_SCREEN_MAX_Y = ' + (ByteHex $ProjectionContract.ScreenMaxY)))
$asm = $asm.Replace('PROJ_FRUSTUM_X_NEAR = $28', ('PROJ_FRUSTUM_X_NEAR = ' + (ByteHex $ProjectionContract.FrustumXNear)))
$asm = $asm.Replace('PROJ_FRUSTUM_Y_NEAR = $19', ('PROJ_FRUSTUM_Y_NEAR = ' + (ByteHex $ProjectionContract.FrustumYNear)))
$asm = $asm.Replace('PROJ_FRUSTUM_FOCAL = $55', ('PROJ_FRUSTUM_FOCAL = ' + (ByteHex $ProjectionContract.FrustumFocal)))
$asm = $asm.Replace('PROJ_CENTER_X_HALF = $28', ('PROJ_CENTER_X_HALF = ' + (ByteHex ([int]($ProjectionContract.ScreenCenterX / 2)))))
$asm = $asm.Replace('EXPLORER_MOVE_STEP = $7f', ('EXPLORER_MOVE_STEP = ' + (ByteHex $ExplorerMoveStep)))
$asm = $asm.Replace('EXPLORER_YAW_PITCH_TICK_DIV = $04', ('EXPLORER_YAW_PITCH_TICK_DIV = ' + (ByteHex $ExplorerYawPitchTickDiv)))
$asm = $asm.Replace('EXPLORER_ROLL_TICK_DIV = $02', ('EXPLORER_ROLL_TICK_DIV = ' + (ByteHex $ExplorerRollTickDiv)))
$asm = $asm.Replace('YQ2_VIEWPORT_CENTER_LO = $a0', ('YQ2_VIEWPORT_CENTER_LO = ' + (ByteHex ($YQ2ViewportCenter -band 255))))
$asm = $asm.Replace('YQ2_VIEWPORT_CENTER_HI = $00', ('YQ2_VIEWPORT_CENTER_HI = ' + (ByteHex (($YQ2ViewportCenter -shr 8) -band 255))))
$asm = $asm.Replace('YQ2_VIEWPORT_NATIVE_BASE_HI = $01', ('YQ2_VIEWPORT_NATIVE_BASE_HI = ' + (ByteHex ((($YQ2ViewportCenter + 256) -shr 8) -band 255))))
$asm = $asm.Replace('YQ2_VIEWPORT_MAX_LO = $3c', ('YQ2_VIEWPORT_MAX_LO = ' + (ByteHex ($YQ2ViewportMax -band 255))))
$asm = $asm.Replace('YQ2_VIEWPORT_MAX_HI = $01', ('YQ2_VIEWPORT_MAX_HI = ' + (ByteHex (($YQ2ViewportMax -shr 8) -band 255))))
$asm = $asm.Replace('YQ2_VIEWPORT_ROW_MAX = $4f', ('YQ2_VIEWPORT_ROW_MAX = ' + (ByteHex $YQ2ViewportRowMax)))
$asm = $asm.Replace('YQ2_VIEWPORT_ROW_COUNT = $50', ('YQ2_VIEWPORT_ROW_COUNT = ' + (ByteHex $YQ2ViewportRowCount)))
$asm = $asm.Replace('YQ2_VIEWPORT_CENTER_PLUS_ONE = $a1', ('YQ2_VIEWPORT_CENTER_PLUS_ONE = ' + (ByteHex $YQ2ViewportCenterPlusOne)))
$asm = $asm.Replace('YQ2_VIEWPORT_BELOW_CENTER_LIMIT_PLUS_ONE = $9d', ('YQ2_VIEWPORT_BELOW_CENTER_LIMIT_PLUS_ONE = ' + (ByteHex $YQ2ViewportBelowCenterLimitPlusOne)))
$asm = $asm.Replace('ENGINE_CAMERA_VIEWPORT_CONFIGURABLE = $00', ('ENGINE_CAMERA_VIEWPORT_CONFIGURABLE = ' + (ByteHex $EngineCameraViewportConfigurableFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_VIEWPORT_ALL_MODES = $00', ('ENGINE_CAMERA_VIEWPORT_ALL_MODES = ' + (ByteHex $EngineCameraViewportAllModesFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_VIEWPORT_SMALL = $00', ('ENGINE_CAMERA_VIEWPORT_SMALL = ' + (ByteHex $EngineCameraViewportSmallFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_VIEWPORT_PROFILE_ID = $00', ('ENGINE_CAMERA_VIEWPORT_PROFILE_ID = ' + (ByteHex $EngineCameraViewportSmallFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_VIEWPORT_PROJECTION_SCALED = $00', ('ENGINE_CAMERA_VIEWPORT_PROJECTION_SCALED = ' + (ByteHex $EngineCameraViewportProjectionScaledFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_VIEWPORT_CLEAR_LIMITED = $00', ('ENGINE_CAMERA_VIEWPORT_CLEAR_LIMITED = ' + (ByteHex $EngineCameraViewportClearLimitedFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_VIEWPORT_GROUND_LIMITED = $00', ('ENGINE_CAMERA_VIEWPORT_GROUND_LIMITED = ' + (ByteHex $EngineCameraViewportGroundLimitedFlag)))
$asm = $asm.Replace('CAMERA_VIEWPORT_WIDTH = $a0', ('CAMERA_VIEWPORT_WIDTH = ' + (ByteHex $CameraViewportWidth)))
$asm = $asm.Replace('CAMERA_VIEWPORT_HEIGHT = $64', ('CAMERA_VIEWPORT_HEIGHT = ' + (ByteHex $CameraViewportHeight)))
$asm = $asm.Replace('CAMERA_VIEWPORT_ORIGIN_X = $00', ('CAMERA_VIEWPORT_ORIGIN_X = ' + (ByteHex $CameraViewportOriginX)))
$asm = $asm.Replace('CAMERA_VIEWPORT_ORIGIN_Y = $00', ('CAMERA_VIEWPORT_ORIGIN_Y = ' + (ByteHex $CameraViewportOriginY)))
$asm = $asm.Replace('CAMERA_VIEWPORT_CELL_ORIGIN_X = $00', ('CAMERA_VIEWPORT_CELL_ORIGIN_X = ' + (ByteHex $CameraViewportCellOriginX)))
$asm = $asm.Replace('CAMERA_VIEWPORT_CELL_WIDTH = $28', ('CAMERA_VIEWPORT_CELL_WIDTH = ' + (ByteHex $CameraViewportCellWidth)))
$asm = $asm.Replace('CAMERA_VIEWPORT_BITMAP_X_OFFSET = $00', ('CAMERA_VIEWPORT_BITMAP_X_OFFSET = ' + (ByteHex $CameraViewportBitmapXOffset)))
$asm = $asm.Replace('SOURCE_FACE_COUNT = $fd', ('SOURCE_FACE_COUNT = ' + (ByteHex $SourceFaceCount)))
$asm = $asm.Replace('SOURCE_VERT_COUNT = $fe', ('SOURCE_VERT_COUNT = ' + (ByteHex $SourceVertexCount)))
$asm = $asm.Replace('FACE_COUNT = $0c', ('FACE_COUNT = ' + (ByteHex $FaceCount)))
$asm = $asm.Replace('FACE_BUCKET_USED_LIST_CAPACITY = $0100', ('FACE_BUCKET_USED_LIST_CAPACITY = ' + (WordHex $FaceBucketUsedListCapacity)))
$asm = $asm.Replace('VERT_COUNT = $08', ('VERT_COUNT = ' + (ByteHex $VertexCount)))
$asm = $asm.Replace('MEMORY_LAYOUT_HIGH_BASIC_V2 = $00', ('MEMORY_LAYOUT_HIGH_BASIC_V2 = ' + (ByteHex $HighBasicV2LayoutFlag)))
$asm = $asm.Replace('HIGH_BASIC_V2_RELOCATED_CODE_BASE = $9000', ('HIGH_BASIC_V2_RELOCATED_CODE_BASE = ' + (WordHex $(if ($SceneTimelineFlag -ne 0) { 0x9200 } else { 0x9000 }))))
$asm = $asm.Replace('BITMAP_B_BASE = $a000', ('BITMAP_B_BASE = ' + (WordHex $BitmapBBase)))
$asm = $asm.Replace('SCREEN_B_BASE = $8c00', ('SCREEN_B_BASE = ' + (WordHex $ScreenBBase)))
$asm = $asm.Replace('RUNTIME_BUFFER_LIMIT = $8c00', ('RUNTIME_BUFFER_LIMIT = ' + (WordHex $RuntimeBufferLimit)))
$asm = $asm.Replace('VIC_BANK_B_BITS = $01', ('VIC_BANK_B_BITS = ' + (ByteHex $VicBankBBits)))
$asm = $asm.Replace('VIC_D018_B = $38', ('VIC_D018_B = ' + (ByteHex $VicD018B)))
$asm = $asm.Replace('FPS_TEXT_BASE = $c000', ('FPS_TEXT_BASE = ' + (WordHex $FpsTextBase)))
$asm = $asm.Replace('FPS_TEXT_D018 = $02', ('FPS_TEXT_D018 = ' + (ByteHex $FpsTextD018)))
$asm = $asm.Replace('FPS_TEXT_UNDER_IO = $00', ('FPS_TEXT_UNDER_IO = ' + (ByteHex $FpsTextUnderIoFlag)))
$asm = $asm.Replace('FPS_TEXT_RELOCATED_D800 = $00', ('FPS_TEXT_RELOCATED_D800 = ' + (ByteHex $FpsTextRelocationD800Flag)))
$asm = $asm.Replace('FPS_TEXT_CLEAR_CELLS = $80', ('FPS_TEXT_CLEAR_CELLS = ' + (ByteHex $FpsTextClearCells)))
$asm = $asm.Replace('FPS_CHARSET_BASE = $c800', ('FPS_CHARSET_BASE = ' + (WordHex $FpsCharsetBase)))
$asm = $asm.Replace('FPS_CHARSET_UNDER_IO = $00', ('FPS_CHARSET_UNDER_IO = ' + (ByteHex $FpsCharsetUnderIoFlag)))
# anchor the generic marker at the start of its own line.
# Its name is a suffix of the ENGINE and engine-mode3 diagnostic markers; an
# unanchored Replace() rewrote those longer lines before their specific values.
$asm = $asm.Replace("`nFPS_CHARSET_RELOCATED_D000 = `$00", ("`nFPS_CHARSET_RELOCATED_D000 = " + (ByteHex $FpsCharsetRelocationD000Flag)))
$asm = $asm.Replace('ENGINE_MODE3_FPS_CHARSET_RELOCATED_D000 = $00', ('ENGINE_MODE3_FPS_CHARSET_RELOCATED_D000 = ' + (ByteHex $Mode3FpsCharsetRelocationFlag)))
$asm = $asm.Replace('TEXT_HEADER_OFFSET = $00', ('TEXT_HEADER_OFFSET = ' + (ByteHex $headerOffset)))
$asm = $asm.Replace('FPS_FONT_BYTE_COUNT = $B8', ('FPS_FONT_BYTE_COUNT = ' + (ByteHex $fpsFontByteCount)))
$asm = $asm.Replace('TEXT_HEADER_STRING_BYTES', $headerBytesStr)
$asm = $asm.Replace('MESH_COUNT = $01', ('MESH_COUNT = ' + (ByteHex $MeshCount)))
$asm = $asm.Replace('SCENE_OBJECT_COUNT = $00', ('SCENE_OBJECT_COUNT = ' + (ByteHex $SceneObjectCount)))
$asm = $asm.Replace('OBJECT_MODEL_CONTRACT_VERSION = $01', ('OBJECT_MODEL_CONTRACT_VERSION = ' + (ByteHex $ObjectModelContractVersion)))
$asm = $asm.Replace('WORLD_SPACE_Z_UP = $00', ('WORLD_SPACE_Z_UP = ' + (ByteHex $WorldSpaceZUpFlag)))
$asm = $asm.Replace('OBJECT_SPACE_ALIGNED_WORLD = $00', ('OBJECT_SPACE_ALIGNED_WORLD = ' + (ByteHex $ObjectSpaceAlignedWorldFlag)))
$asm = $asm.Replace('SCENE_WORLD_OBJECT_PRESENT = $01', ('SCENE_WORLD_OBJECT_PRESENT = ' + (ByteHex $SceneWorldObjectPresentFlag)))
$asm = $asm.Replace('SCENE_CAMERA_OBJECT_PRESENT = $01', ('SCENE_CAMERA_OBJECT_PRESENT = ' + (ByteHex $SceneCameraObjectPresentFlag)))
$asm = $asm.Replace('SCENE_LIGHT_OBJECT_COUNT = $00', ('SCENE_LIGHT_OBJECT_COUNT = ' + (ByteHex $SceneLightCount)))
$asm = $asm.Replace('SCENE_PRIMARY_LIGHT_INDEX = $ff', ('SCENE_PRIMARY_LIGHT_INDEX = ' + (ByteHex $ScenePrimaryLightIndex)))
$asm = $asm.Replace('SCENE_EXTRA_LIGHT_IGNORED_COUNT = $00', ('SCENE_EXTRA_LIGHT_IGNORED_COUNT = ' + (ByteHex $SceneExtraLightIgnoredCount)))
$asm = $asm.Replace('SCENE_MESH_OBJECT_COUNT = $00', ('SCENE_MESH_OBJECT_COUNT = ' + (ByteHex $SceneMeshObjectCount)))
$asm = $asm.Replace('MESH_INSTANCE_EXPANSION_MODE = $00', ('MESH_INSTANCE_EXPANSION_MODE = ' + (ByteHex $MeshInstanceExpansionModeFlag)))
$asm = $asm.Replace('MESH_SOURCE_SHARING_RUNTIME = $00', ('MESH_SOURCE_SHARING_RUNTIME = ' + (ByteHex $MeshSourceSharingRuntimeFlag)))
$asm = $asm.Replace('SCENE_SOLID_MESH_OBJECT_COUNT = $00', ('SCENE_SOLID_MESH_OBJECT_COUNT = ' + (ByteHex $SceneSolidMeshObjectCount)))
$asm = $asm.Replace('SCENE_WIRE_MESH_OBJECT_COUNT = $00', ('SCENE_WIRE_MESH_OBJECT_COUNT = ' + (ByteHex $SceneWireMeshObjectCount)))
$asm = $asm.Replace('SCENE_SINGLE_MATERIAL_MESH_OBJECT_COUNT = $00', ('SCENE_SINGLE_MATERIAL_MESH_OBJECT_COUNT = ' + (ByteHex $SceneSingleMaterialMeshObjectCount)))
$asm = $asm.Replace('SCENE_MULTIMATERIAL_MESH_OBJECT_COUNT = $00', ('SCENE_MULTIMATERIAL_MESH_OBJECT_COUNT = ' + (ByteHex $SceneMultimaterialMeshObjectCount)))
$asm = $asm.Replace('SCENE_FACE_MATERIAL_TABLE_ACTIVE = $00', ('SCENE_FACE_MATERIAL_TABLE_ACTIVE = ' + (ByteHex $SceneFaceMaterialTableActiveFlag)))
$ShadeSolidBytesDirective = " .byte " + (($StaticShadeSolidBytes | ForEach-Object { '$' + (([int]$_ -band 255).ToString('x2')) }) -join ",")
$ShadePatternBytesDirective = " .byte " + (($StaticShadePatternBytes | ForEach-Object { '$' + (([int]$_ -band 255).ToString('x2')) }) -join ",")
$asm = $asm.Replace('SHADE_SOLID_BYTES_DATA', $ShadeSolidBytesDirective)
$asm = $asm.Replace('SHADE_PATTERN_BYTES_DATA', $ShadePatternBytesDirective)
$asm = $asm.Replace('SCENE_FACE_SOLID_COLOR_TABLE_REQUESTED = $00', ('SCENE_FACE_SOLID_COLOR_TABLE_REQUESTED = ' + (ByteHex $SceneFaceSolidColorTableRequestedFlag)))
$asm = $asm.Replace('SCENE_POS_ACTIVE = $00', ('SCENE_POS_ACTIVE = ' + (ByteHex $ScenePosActiveFlag)))
$asm = $asm.Replace('SCENE_VEL_X_ACTIVE = $00', ('SCENE_VEL_X_ACTIVE = ' + (ByteHex $SceneVelXActiveFlag)))
$asm = $asm.Replace('SCENE_VEL_Y_ACTIVE = $00', ('SCENE_VEL_Y_ACTIVE = ' + (ByteHex $SceneVelYActiveFlag)))
$asm = $asm.Replace('SCENE_VEL_Z_ACTIVE = $00', ('SCENE_VEL_Z_ACTIVE = ' + (ByteHex $SceneVelZActiveFlag)))
$asm = $asm.Replace('SCENE_ROT_ACTIVE = $00', ('SCENE_ROT_ACTIVE = ' + (ByteHex $SceneRotActiveFlag)))
$asm = $asm.Replace('SCENE_ANG_X_ACTIVE = $00', ('SCENE_ANG_X_ACTIVE = ' + (ByteHex $SceneAngXActiveFlag)))
$asm = $asm.Replace('SCENE_ANG_Y_ACTIVE = $00', ('SCENE_ANG_Y_ACTIVE = ' + (ByteHex $SceneAngYActiveFlag)))
$asm = $asm.Replace('SCENE_ANG_Z_ACTIVE = $00', ('SCENE_ANG_Z_ACTIVE = ' + (ByteHex $SceneAngZActiveFlag)))
$asm = $asm.Replace('SCENE_OBJECT_X_ACTIVE = $00', ('SCENE_OBJECT_X_ACTIVE = ' + (ByteHex $SceneObjectXActiveFlag)))
$asm = $asm.Replace('SCENE_OBJECT_Y_ACTIVE = $00', ('SCENE_OBJECT_Y_ACTIVE = ' + (ByteHex $SceneObjectYActiveFlag)))
$asm = $asm.Replace('SCENE_OBJECT_SCALE_ACTIVE = $00', ('SCENE_OBJECT_SCALE_ACTIVE = ' + (ByteHex $SceneObjectScaleActiveFlag)))
$asm = $asm.Replace('SCENE_OBJECT_VISIBILITY_ACTIVE = $00', ('SCENE_OBJECT_VISIBILITY_ACTIVE = ' + (ByteHex $SceneObjectVisibilityActiveFlag)))
$asm = $asm.Replace('SCENE_INSTANCE_OVERRIDES = $00', ('SCENE_INSTANCE_OVERRIDES = ' + (ByteHex $SceneInstanceOverrideFlag)))
$asm = $asm.Replace('SCENE_INSTANCE_COLOR_OVERRIDE = $00', ('SCENE_INSTANCE_COLOR_OVERRIDE = ' + (ByteHex $SceneInstanceColorOverrideFlag)))
$asm = $asm.Replace('SCENE_FACE_MATERIAL_OVERRIDE = $00', ('SCENE_FACE_MATERIAL_OVERRIDE = ' + (ByteHex $SceneFaceMaterialOverrideFlag)))
$asm = $asm.Replace('SCENE_INSTANCE_MATERIAL_ALL_PINNED = $00', ('SCENE_INSTANCE_MATERIAL_ALL_PINNED = ' + (ByteHex $SceneInstanceMaterialAllPinnedFlag)))
$asm = $asm.Replace('SCENE_INSTANCE_REFLECT_ALL_PINNED = $00', ('SCENE_INSTANCE_REFLECT_ALL_PINNED = ' + (ByteHex $SceneInstanceReflectivityAllPinnedFlag)))
$asm = $asm.Replace('SCENE_TIMELINE_ENABLE = $00', ('SCENE_TIMELINE_ENABLE = ' + (ByteHex $SceneTimelineFlag)))
$asm = $asm.Replace('SCENE_TIMELINE_STATE_COUNT = $00', ('SCENE_TIMELINE_STATE_COUNT = ' + (ByteHex $(if ($SceneTimelineFlag -ne 0) { [int]$SceneTimelineCompiled.StateCount } else { 0 }))))
$asm = $asm.Replace('SCENE_TIMELINE_INITIAL_STATE = $00', ('SCENE_TIMELINE_INITIAL_STATE = ' + (ByteHex $(if ($SceneTimelineFlag -ne 0) { [int]$SceneTimelineCompiled.Initial } else { 0 }))))
$asm = $asm.Replace('SCENE_GRAPHIC_INCLUDE_ENABLE = $00', ('SCENE_GRAPHIC_INCLUDE_ENABLE = ' + (ByteHex $SceneGraphicIncludeFlag)))
$asm = $asm.Replace('SCENE_RESPAWN_ACTIVE = $00', ('SCENE_RESPAWN_ACTIVE = ' + (ByteHex $SceneRespawnActiveFlag)))
$asm = $asm.Replace('SCENE_OSC_X_ACTIVE = $00', ('SCENE_OSC_X_ACTIVE = ' + (ByteHex $SceneOscXActiveFlag)))
$asm = $asm.Replace('FACE_REFLECTIVITY_ACTIVE_ONLY = $00', ('FACE_REFLECTIVITY_ACTIVE_ONLY = ' + (ByteHex $FaceReflectivityActiveOnlyFlag)))
$asm = $asm.Replace('FACE_MATERIAL_ACTIVE_ONLY = $00', ('FACE_MATERIAL_ACTIVE_ONLY = ' + (ByteHex $FaceMaterialActiveOnlyFlag)))
$asm = $asm.Replace('FACE_SOLID_COLOR_ENABLE = $00', ('FACE_SOLID_COLOR_ENABLE = ' + (ByteHex $FaceSolidColorFlag)))
$asm = $asm.Replace('VIC_COLOR_POLICY_ENABLE = $00', ('VIC_COLOR_POLICY_ENABLE = ' + (ByteHex $VicColorPolicyEnableFlag)))
$asm = $asm.Replace('VIC_COLOR_POLICY_ACTIVE = $00', ('VIC_COLOR_POLICY_ACTIVE = ' + (ByteHex $VicColorPolicyActiveFlag)))
$asm = $asm.Replace('VIC_COLOR_POLICY_OVERLAY = $00', ('VIC_COLOR_POLICY_OVERLAY = ' + (ByteHex $VicColorPolicyOverlayFlag)))
$asm = $asm.Replace('VIC_COLOR_FALLBACK_MODE = $00', ('VIC_COLOR_FALLBACK_MODE = ' + (ByteHex $VicColorFallbackMode)))
$asm = $asm.Replace('MATERIAL_CELL_SPAN_CACHE = $00', ('MATERIAL_CELL_SPAN_CACHE = ' + (ByteHex $MaterialCellSpanCacheFlag)))
$asm = $asm.Replace('LAZY_CONVEX_BOUNDS = $00', ('LAZY_CONVEX_BOUNDS = ' + (ByteHex $LazyConvexBoundsFlag)))
$asm = $asm.Replace('DIRECT_CONVEX_EDGE_SPANS = $00', ('DIRECT_CONVEX_EDGE_SPANS = ' + (ByteHex $DirectConvexEdgeSpansFlag)))
$asm = $asm.Replace('SPAN_KERNEL_FILL = $00', ('SPAN_KERNEL_FILL = ' + (ByteHex $SpanKernelFillFlag)))
$asm = $asm.Replace('INDEXED_OFFSET_SPAN_FILL = $00', ('INDEXED_OFFSET_SPAN_FILL = ' + (ByteHex $IndexedOffsetSpanFillFlag)))
$asm = $asm.Replace('DIRECT_CONVEX_FAN_FILL = $00', ('DIRECT_CONVEX_FAN_FILL = ' + (ByteHex $DirectConvexFanFillFlag)))
$asm = $asm.Replace('RENDERER_PLAN_ACTIVE = $00', ('RENDERER_PLAN_ACTIVE = ' + (ByteHex $RendererPlan.PlannerActive)))
$asm = $asm.Replace('RENDERER_PLAN_APPLIED = $00', ('RENDERER_PLAN_APPLIED = ' + (ByteHex $RendererPlan.PlanApplied)))
$asm = $asm.Replace('GROUND_RENDER_MODE = $02', ('GROUND_RENDER_MODE = ' + (ByteHex $RendererPlan.GroundRenderMode)))
$asm = $asm.Replace('GROUND_SIMPLE_PREFILL = $00', ('GROUND_SIMPLE_PREFILL = ' + (ByteHex $RendererPlan.GroundSimplePrefill)))
$asm = $asm.Replace('GROUND_HORIZON_ONLY = $00', ('GROUND_HORIZON_ONLY = ' + (ByteHex $EngineGroundHorizonOnlyRuntimeFlag)))
$asm = $asm.Replace('GROUND_FULL_PLANE = $01', ('GROUND_FULL_PLANE = ' + (ByteHex $RendererPlan.GroundFullPlane)))
$asm = $asm.Replace('GROUND_OCCLUSION_ENABLE = $00', ('GROUND_OCCLUSION_ENABLE = ' + (ByteHex $RendererPlan.GroundOcclusion)))
$asm = $asm.Replace('GROUND_WIRE_OCCLUSION_ENABLE = $00', ('GROUND_WIRE_OCCLUSION_ENABLE = ' + (ByteHex $RendererPlan.GroundWireOcclusion)))
$asm = $asm.Replace('GROUND_ROLL_PLANE_ENABLE = $00', ('GROUND_ROLL_PLANE_ENABLE = ' + (ByteHex $RendererPlan.GroundRollPlane)))
$asm = $asm.Replace('FRAME_WORLD_PREFILL_ENABLE = $00', ('FRAME_WORLD_PREFILL_ENABLE = ' + (ByteHex $RendererPlan.FrameWorldPrefill)))
$asm = $asm.Replace('VIC_COLOR_POLICY_RUNTIME_ENABLE = $00', ('VIC_COLOR_POLICY_RUNTIME_ENABLE = ' + (ByteHex $RendererPlan.VicColorPolicyRuntime)))
$asm = $asm.Replace('ENGINE_VIC_STATIC_POLICY = $00', ('ENGINE_VIC_STATIC_POLICY = ' + (ByteHex $RendererPlan.EngineVicStaticPolicy)))
$asm = $asm.Replace('ENGINE_CAMERA_LIMITS_ENABLE = $00', ('ENGINE_CAMERA_LIMITS_ENABLE = ' + (ByteHex $RendererPlan.CameraLimits)))
$asm = $asm.Replace('CAMERA_FULL_ENABLE = $01', ('CAMERA_FULL_ENABLE = ' + (ByteHex $RendererPlan.CameraFull)))
$asm = $asm.Replace('ENGINE_CAMERA_PROFILE_RUNTIME_ACTIVE = $00', ('ENGINE_CAMERA_PROFILE_RUNTIME_ACTIVE = ' + (ByteHex $EngineCameraProfileRuntimeFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_WALK_LITE_RUNTIME_ACTIVE = $00', ('ENGINE_CAMERA_WALK_LITE_RUNTIME_ACTIVE = ' + (ByteHex $EngineCameraWalkLiteRuntimeFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_MODE_CYCLE_RUNTIME_ACTIVE = $00', ('ENGINE_CAMERA_MODE_CYCLE_RUNTIME_ACTIVE = ' + (ByteHex $EngineCameraModeCycleRuntimeFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_ROLL_RUNTIME_ACTIVE = $00', ('ENGINE_CAMERA_ROLL_RUNTIME_ACTIVE = ' + (ByteHex $EngineCameraRollRuntimeFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_PITCH_ROLL_LOCK_ACTIVE = $00', ('ENGINE_CAMERA_PITCH_ROLL_LOCK_ACTIVE = ' + (ByteHex $EngineCameraPitchRollLockFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_WALK_LITE_PITCH_RUNTIME_ACTIVE = $00', ('ENGINE_CAMERA_WALK_LITE_PITCH_RUNTIME_ACTIVE = ' + (ByteHex $EngineCameraWalkLitePitchRuntimeFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_WALK_LITE_PITCH_ALL_MODES = $00', ('ENGINE_CAMERA_WALK_LITE_PITCH_ALL_MODES = ' + (ByteHex $EngineCameraWalkLitePitchAllModesFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_WALK_LITE_YAW_PITCH_ONLY = $00', ('ENGINE_CAMERA_WALK_LITE_YAW_PITCH_ONLY = ' + (ByteHex $EngineCameraWalkLiteYawPitchOnlyFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_WALK_LITE_PITCH_ZERO_FASTPATH = $00', ('ENGINE_CAMERA_WALK_LITE_PITCH_ZERO_FASTPATH = ' + (ByteHex $EngineCameraWalkLitePitchZeroFastpathFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH = $00', ('ENGINE_CAMERA_PITCH_TRIG_ZERO_FASTPATH = ' + (ByteHex $EngineCameraPitchTrigZeroFastpathFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_FOLDED_PITCH_ZERO_FASTPATH = $00', ('ENGINE_CAMERA_FOLDED_PITCH_ZERO_FASTPATH = ' + (ByteHex $EngineCameraFoldedPitchZeroFastpathFlag)))
$asm = $asm.Replace('ENGINE_CAMERA_ROLL_LOCK_ACTIVE = $00', ('ENGINE_CAMERA_ROLL_LOCK_ACTIVE = ' + (ByteHex $EngineCameraRollLockFlag)))
$asm = $asm.Replace('CAMERA_FULL_RUNTIME_ACTIVE = $00', ('CAMERA_FULL_RUNTIME_ACTIVE = ' + (ByteHex $CameraFullRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE_BUDGET_ENABLE = $00', ('ENGINE_MODE_BUDGET_ENABLE = ' + (ByteHex $RendererPlan.ModeBudget)))
$asm = $asm.Replace('ENGINE_FULL_RENDER_ENABLE = $01', ('ENGINE_FULL_RENDER_ENABLE = ' + (ByteHex $RendererPlan.FullRender)))
$asm = $asm.Replace('DEPTH_BUCKETS_ENABLE = $00', ('DEPTH_BUCKETS_ENABLE = ' + (ByteHex $RendererPlan.DepthBuckets)))
$asm = $asm.Replace('FACE_FILL_CACHE_ENABLE = $00', ('FACE_FILL_CACHE_ENABLE = ' + (ByteHex $RendererPlan.FaceFillCache)))
$asm = $asm.Replace('DYNAMIC_SHADE_LEVEL = $00', ('DYNAMIC_SHADE_LEVEL = ' + (ByteHex $RendererPlan.DynamicShadeLevel)))
$asm = $asm.Replace('RENDER_FRAME_SCAFFOLD_ACTIVE = $00', 'RENDER_FRAME_SCAFFOLD_ACTIVE = $01')
$asm = $asm.Replace('RENDER_FRAME_BEGIN_ACTIVE = $00', 'RENDER_FRAME_BEGIN_ACTIVE = $01')
$asm = $asm.Replace('RENDER_WORLD_BACKGROUND_ACTIVE = $00', 'RENDER_WORLD_BACKGROUND_ACTIVE = $01')
$asm = $asm.Replace('RENDER_SCENE_PIPELINE_ACTIVE = $00', 'RENDER_SCENE_PIPELINE_ACTIVE = $01')
$asm = $asm.Replace('RENDER_FRAME_END_ACTIVE = $00', 'RENDER_FRAME_END_ACTIVE = $01')
$asm = $asm.Replace('ENGINE_GROUND_SIMPLE_RUNTIME_ACTIVE = $00', ('ENGINE_GROUND_SIMPLE_RUNTIME_ACTIVE = ' + (ByteHex $EngineGroundSimpleRuntimeFlag)))
$asm = $asm.Replace('ENGINE_GROUND_HORIZON_ONLY_RUNTIME_ACTIVE = $00', ('ENGINE_GROUND_HORIZON_ONLY_RUNTIME_ACTIVE = ' + (ByteHex $EngineGroundHorizonOnlyRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE3_FRAME_PREFILL_RUNTIME_ACTIVE = $00', ('ENGINE_MODE3_FRAME_PREFILL_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode3FramePrefillRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE3_CLEAR_GROUND_FUSED = $00', ('ENGINE_MODE3_CLEAR_GROUND_FUSED = ' + (ByteHex $EngineMode3ClearGroundFusedFlag)))
$asm = $asm.Replace('ENGINE_MODE3_GROUND_CELLROW_WRITE_ON_CHANGE = $00', ('ENGINE_MODE3_GROUND_CELLROW_WRITE_ON_CHANGE = ' + (ByteHex $EngineMode3GroundCellrowWriteOnChangeFlag)))
$asm = $asm.Replace('ENGINE_MODE3_PREFILL_FALLBACK = $00', ('ENGINE_MODE3_PREFILL_FALLBACK = ' + (ByteHex $EngineMode3PrefillFallbackFlag)))
$asm = $asm.Replace('ENGINE_MODE3_FACE_PREPARE_ONCE = $00', ('ENGINE_MODE3_FACE_PREPARE_ONCE = ' + (ByteHex $EngineMode3FacePrepareOnceFlag)))
$asm = $asm.Replace('ENGINE_MODE3_PREPARED_FACE_STATE_CACHE = $00', ('ENGINE_MODE3_PREPARED_FACE_STATE_CACHE = ' + (ByteHex $EngineMode3PreparedFaceStateCacheFlag)))
$asm = $asm.Replace('ENGINE_MODE3_UNCLIPPED_FACE_FASTLOAD = $00', ('ENGINE_MODE3_UNCLIPPED_FACE_FASTLOAD = ' + (ByteHex $EngineMode3UnclippedFaceFastloadFlag)))
$asm = $asm.Replace('ENGINE_MODE3_CLIP_FALLBACK = $00', ('ENGINE_MODE3_CLIP_FALLBACK = ' + (ByteHex $EngineMode3ClipFallbackFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DRAW_RECHECK_STRIPPED = $00', ('ENGINE_MODE3_DRAW_RECHECK_STRIPPED = ' + (ByteHex $EngineMode3DrawRecheckStrippedFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DIRECT_CONVEX_FILL = $00', ('ENGINE_MODE3_DIRECT_CONVEX_FILL = ' + (ByteHex $EngineMode3DirectConvexFillFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DIRECT_CONVEX_PREPARED_ONLY = $00', ('ENGINE_MODE3_DIRECT_CONVEX_PREPARED_ONLY = ' + (ByteHex $EngineMode3DirectConvexPreparedOnlyFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DIRECT_CONVEX_CLIP_FALLBACK = $00', ('ENGINE_MODE3_DIRECT_CONVEX_CLIP_FALLBACK = ' + (ByteHex $EngineMode3DirectConvexClipFallbackFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DIRECT_CONVEX_TRI_QUAD = $00', ('ENGINE_MODE3_DIRECT_CONVEX_TRI_QUAD = ' + (ByteHex $EngineMode3DirectConvexTriQuadFlag)))
$asm = $asm.Replace('ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL = $00', ('ENGINE_MODE3_NATIVE_CONVEX_QUAD_FILL = ' + (ByteHex $EngineMode3NativeConvexQuadFillFlag)))
$asm = $asm.Replace('ENGINE_MODE3_NATIVE_CONVEX_QUAD_PREPARED_ONLY = $00', ('ENGINE_MODE3_NATIVE_CONVEX_QUAD_PREPARED_ONLY = ' + (ByteHex $EngineMode3NativeConvexQuadPreparedOnlyFlag)))
$asm = $asm.Replace('ENGINE_MODE3_NATIVE_CONVEX_QUAD_SINGLE_SPAN = $00', ('ENGINE_MODE3_NATIVE_CONVEX_QUAD_SINGLE_SPAN = ' + (ByteHex $EngineMode3NativeConvexQuadSingleSpanFlag)))
$asm = $asm.Replace('ENGINE_MODE3_NATIVE_CONVEX_QUAD_FAN_FALLBACK = $00', ('ENGINE_MODE3_NATIVE_CONVEX_QUAD_FAN_FALLBACK = ' + (ByteHex $EngineMode3NativeConvexQuadFanFallbackFlag)))
$asm = $asm.Replace('ENGINE_MODE3_NATIVE_CONVEX_QUAD_TRIANGLES_UNCHANGED = $00', ('ENGINE_MODE3_NATIVE_CONVEX_QUAD_TRIANGLES_UNCHANGED = ' + (ByteHex $EngineMode3NativeConvexQuadTrianglesUnchangedFlag)))
$asm = $asm.Replace('ENGINE_MODE3_FAST_BOUNDS_TRACE = $00', ('ENGINE_MODE3_FAST_BOUNDS_TRACE = ' + (ByteHex $EngineMode3FastBoundsTraceFlag)))
$asm = $asm.Replace('ENGINE_MODE3_FAST_BOUNDS_8BIT = $00', ('ENGINE_MODE3_FAST_BOUNDS_8BIT = ' + (ByteHex $EngineMode3FastBounds8BitFlag)))
$asm = $asm.Replace('ENGINE_MODE3_FAST_BOUNDS_DIRECT_LEFT_RIGHT = $00', ('ENGINE_MODE3_FAST_BOUNDS_DIRECT_LEFT_RIGHT = ' + (ByteHex $EngineMode3FastBoundsDirectLeftRightFlag)))
$asm = $asm.Replace('ENGINE_MODE3_FAST_BOUNDS_OVERFLOW_FALLBACK = $00', ('ENGINE_MODE3_FAST_BOUNDS_OVERFLOW_FALLBACK = ' + (ByteHex $EngineMode3FastBoundsOverflowFallbackFlag)))
$asm = $asm.Replace('ENGINE_MODE4_FAST_BOUNDS_TRACE = $00', ('ENGINE_MODE4_FAST_BOUNDS_TRACE = ' + (ByteHex $EngineMode4FastBoundsTraceFlag)))
$asm = $asm.Replace('ENGINE_MODE4_FAST_BOUNDS_8BIT = $00', ('ENGINE_MODE4_FAST_BOUNDS_8BIT = ' + (ByteHex $EngineMode4FastBounds8BitFlag)))
$asm = $asm.Replace('ENGINE_MODE4_FAST_BOUNDS_DIRECT_LEFT_RIGHT = $00', ('ENGINE_MODE4_FAST_BOUNDS_DIRECT_LEFT_RIGHT = ' + (ByteHex $EngineMode4FastBoundsDirectLeftRightFlag)))
$asm = $asm.Replace('ENGINE_MODE4_FAST_BOUNDS_OVERFLOW_FALLBACK = $00', ('ENGINE_MODE4_FAST_BOUNDS_OVERFLOW_FALLBACK = ' + (ByteHex $EngineMode4FastBoundsOverflowFallbackFlag)))
$asm = $asm.Replace('ENGINE_MODE3_SPAN_HOTLOOP = $00', ('ENGINE_MODE3_SPAN_HOTLOOP = ' + (ByteHex $EngineMode3SpanHotloopFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DIRECT_INDEXED_SPANS = $00', ('ENGINE_MODE3_DIRECT_INDEXED_SPANS = ' + (ByteHex $EngineMode3DirectIndexedSpanFlag)))
$asm = $asm.Replace('ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS = $00', ('ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS = ' + (ByteHex $EngineMode3BoundsIndexedLongSpanFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE = $00', ('ENGINE_MODE3_DIRECT_BYTE_ALIGNED_EDGE_WRITE = ' + (ByteHex $EngineMode3DirectByteAlignedEdgeWriteFlag)))
$asm = $asm.Replace('ENGINE_MODE3_MATERIAL_CELL_TRANSITION = $00', ('ENGINE_MODE3_MATERIAL_CELL_TRANSITION = ' + (ByteHex $EngineMode3MaterialCellTransitionFlag)))
$asm = $asm.Replace('ENGINE_MODE3_FRAME_PREFILL_COMPATIBLE = $00', ('ENGINE_MODE3_FRAME_PREFILL_COMPATIBLE = ' + (ByteHex $EngineMode3FramePrefillCompatibleFlag)))
$asm = $asm.Replace('ENGINE_MODE3_CONSOLIDATION = $00', ('ENGINE_MODE3_CONSOLIDATION = ' + (ByteHex $EngineMode3ConsolidationFlag)))
$asm = $asm.Replace('MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE = $00', ('MODE3_HIGH_BASIC_FULL_RASTER_RELOCATE = ' + (ByteHex $Mode3HighBasicFullRasterRelocationFlag)))
$asm = $asm.Replace('ENGINE_MODE3_CONSOLIDATION_CHECK = $00', ('ENGINE_MODE3_CONSOLIDATION_CHECK = ' + (ByteHex $EngineMode3ConsolidationCheckFlag)))
$asm = $asm.Replace('ENGINE_MODE3_UNIVERSAL_PATHS_ONLY = $00', ('ENGINE_MODE3_UNIVERSAL_PATHS_ONLY = ' + (ByteHex $EngineMode3UniversalPathsOnlyFlag)))
$asm = $asm.Replace('ENGINE_MODE3_COMPACT_FACE_QUEUE = $00', ('ENGINE_MODE3_COMPACT_FACE_QUEUE = ' + (ByteHex $EngineMode3CompactFaceQueueFlag)))
$asm = $asm.Replace('ENGINE_MODE3_NORMAL_VIEWPORT_SUPPORTED = $00', ('ENGINE_MODE3_NORMAL_VIEWPORT_SUPPORTED = ' + (ByteHex $EngineMode3NormalViewportSupportedFlag)))
$asm = $asm.Replace('ENGINE_MODE3_SMALL_VIEWPORT_SUPPORTED = $00', ('ENGINE_MODE3_SMALL_VIEWPORT_SUPPORTED = ' + (ByteHex $EngineMode3SmallViewportSupportedFlag)))
$asm = $asm.Replace('ENGINE_MODE3_MULTI_OBJECT_SUPPORTED = $00', ('ENGINE_MODE3_MULTI_OBJECT_SUPPORTED = ' + (ByteHex $EngineMode3MultiObjectSupportedFlag)))
$asm = $asm.Replace('ENGINE_MODE3_FALLBACKS_PRESERVED = $00', ('ENGINE_MODE3_FALLBACKS_PRESERVED = ' + (ByteHex $EngineMode3FallbacksPreservedFlag)))
$asm = $asm.Replace('ENGINE_MODE3_STABLE_GROUND_CELL_LAYOUT = $00', ('ENGINE_MODE3_STABLE_GROUND_CELL_LAYOUT = ' + (ByteHex $EngineMode3StableGroundCellLayoutFlag)))
$asm = $asm.Replace('ENGINE_MODE3_STABLE_GROUND_AUTO = $00', ('ENGINE_MODE3_STABLE_GROUND_AUTO = ' + (ByteHex $EngineMode3StableGroundCellLayoutAutoFlag)))
$asm = $asm.Replace('ENGINE_MODE3_STABLE_GROUND_MULTI_OBJECT = $00', ('ENGINE_MODE3_STABLE_GROUND_MULTI_OBJECT = ' + (ByteHex $EngineMode3StableGroundMultiObjectFlag)))
$asm = $asm.Replace('ENGINE_MODE3_STABLE_GROUND_SHARED_RAMP = $00', ('ENGINE_MODE3_STABLE_GROUND_SHARED_RAMP = ' + (ByteHex $EngineMode3StableGroundSharedRampFlag)))
$asm = $asm.Replace('ENGINE_MODE3_STABLE_GROUND_SLOT_01 = $00', ('ENGINE_MODE3_STABLE_GROUND_SLOT_01 = ' + (ByteHex $EngineMode3StableGroundSlot01Flag)))
$asm = $asm.Replace('ENGINE_MODE3_STABLE_GROUND_OBJECT_SLOT_10 = $00', ('ENGINE_MODE3_STABLE_GROUND_OBJECT_SLOT_10 = ' + (ByteHex $EngineMode3StableGroundObjectSlot10Flag)))
$asm = $asm.Replace('ENGINE_MODE3_STABLE_GROUND_OBJECT_SLOT_11 = $00', ('ENGINE_MODE3_STABLE_GROUND_OBJECT_SLOT_11 = ' + (ByteHex $EngineMode3StableGroundObjectSlot11Flag)))
$asm = $asm.Replace('ENGINE_MODE3_STABLE_GROUND_COLORRAM_WRITE_STRIPPED = $00', ('ENGINE_MODE3_STABLE_GROUND_COLORRAM_WRITE_STRIPPED = ' + (ByteHex $EngineMode3StableGroundColorRamWriteStrippedFlag)))
$asm = $asm.Replace('ENGINE_MODE3_STABLE_GROUND_DOUBLE_BUFFER_SAFE = $00', ('ENGINE_MODE3_STABLE_GROUND_DOUBLE_BUFFER_SAFE = ' + (ByteHex $EngineMode3StableGroundDoubleBufferSafeFlag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_CELL_POLICY = $00', ('ENGINE_MODE3_ADAPTIVE_CELL_POLICY = ' + (ByteHex $EngineMode3AdaptiveCellPolicyFlag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_SHARED_RAMP_EXACT = $00', ('ENGINE_MODE3_ADAPTIVE_SHARED_RAMP_EXACT = ' + (ByteHex $EngineMode3AdaptiveSharedRampExactFlag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_SCREEN_PAIR_LAYOUT = $00', ('ENGINE_MODE3_ADAPTIVE_SCREEN_PAIR_LAYOUT = ' + (ByteHex $EngineMode3AdaptiveScreenPairLayoutFlag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_MULTI_RAMP = $00', ('ENGINE_MODE3_ADAPTIVE_MULTI_RAMP = ' + (ByteHex $EngineMode3AdaptiveMultiRampFlag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_GROUND_SLOT_11 = $00', ('ENGINE_MODE3_ADAPTIVE_GROUND_SLOT_11 = ' + (ByteHex $EngineMode3AdaptiveGroundSlot11Flag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_OBJECT_SLOTS_01_10 = $00', ('ENGINE_MODE3_ADAPTIVE_OBJECT_SLOTS_01_10 = ' + (ByteHex $EngineMode3AdaptiveObjectSlots0110Flag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_COLORRAM_FIXED_GROUND = $00', ('ENGINE_MODE3_ADAPTIVE_COLORRAM_FIXED_GROUND = ' + (ByteHex $EngineMode3AdaptiveColorRamFixedGroundFlag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_HIGHLIGHT_FOLD_HIGH = $00', ('ENGINE_MODE3_ADAPTIVE_HIGHLIGHT_FOLD_HIGH = ' + (ByteHex $EngineMode3AdaptiveHighlightFoldFlag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_FACE_SOLID_COLOR = $00', ('ENGINE_MODE3_ADAPTIVE_FACE_SOLID_COLOR = ' + (ByteHex $EngineMode3AdaptiveFaceSolidColorFlag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_DOUBLE_BUFFER_SAFE = $00', ('ENGINE_MODE3_ADAPTIVE_DOUBLE_BUFFER_SAFE = ' + (ByteHex $EngineMode3AdaptiveDoubleBufferSafeFlag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_RUNTIME_MATERIAL_SAFE = $00', ('ENGINE_MODE3_ADAPTIVE_RUNTIME_MATERIAL_SAFE = ' + (ByteHex $EngineMode3AdaptiveRuntimeMaterialSafeFlag)))
$asm = $asm.Replace('ENGINE_MODE3_ADAPTIVE_USER_CELL_CONFLICT = $00', ('ENGINE_MODE3_ADAPTIVE_USER_CELL_CONFLICT = ' + (ByteHex $EngineMode3AdaptiveUserCellConflictFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_CELL_COLOR_STABILITY = $00', ('ENGINE_MODE3_DEMO_CELL_COLOR_STABILITY = ' + (ByteHex $EngineMode3DemoCellColorStabilityFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_THREE_COLOR_LAYOUT = $00', ('ENGINE_MODE3_DEMO_THREE_COLOR_LAYOUT = ' + (ByteHex $EngineMode3DemoThreeColorLayoutFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_GROUND_SLOT_01_PRESERVED = $00', ('ENGINE_MODE3_DEMO_GROUND_SLOT_01_PRESERVED = ' + (ByteHex $EngineMode3DemoGroundSlot01PreservedFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_OBJECT_SLOT_10 = $00', ('ENGINE_MODE3_DEMO_OBJECT_SLOT_10 = ' + (ByteHex $EngineMode3DemoObjectSlot10Flag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_OBJECT_SLOT_11 = $00', ('ENGINE_MODE3_DEMO_OBJECT_SLOT_11 = ' + (ByteHex $EngineMode3DemoObjectSlot11Flag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_STATIC_SHADING_RESTORED = $00', ('ENGINE_MODE3_DEMO_STATIC_SHADING_RESTORED = ' + (ByteHex $EngineMode3DemoStaticShadingRestoredFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_NO_FACE_SOLID_OVERRIDE = $00', ('ENGINE_MODE3_DEMO_NO_FACE_SOLID_OVERRIDE = ' + (ByteHex $EngineMode3DemoNoFaceSolidOverrideFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_SHADE_FAMILY_REENCODED = $00', ('ENGINE_MODE3_DEMO_SHADE_FAMILY_REENCODED = ' + (ByteHex $EngineMode3DemoShadeFamilyReencodedFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_VIC_POLICY_OFF = $00', ('ENGINE_MODE3_DEMO_VIC_POLICY_OFF = ' + (ByteHex $EngineMode3DemoVicPolicyOffFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_GROUND_BITMAP_SLOT_01 = $00', ('ENGINE_MODE3_DEMO_GROUND_BITMAP_SLOT_01 = ' + (ByteHex $EngineMode3DemoGroundBitmapSlot01Flag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_GROUND_COLORRAM_WRITE_STRIPPED = $00', ('ENGINE_MODE3_DEMO_GROUND_COLORRAM_WRITE_STRIPPED = ' + (ByteHex $EngineMode3DemoGroundColorRamWriteStrippedFlag)))
$asm = $asm.Replace('ENGINE_MODE3_DEMO_DOUBLE_BUFFER_COLOR_STABLE = $00', ('ENGINE_MODE3_DEMO_DOUBLE_BUFFER_COLOR_STABLE = ' + (ByteHex $EngineMode3DemoDoubleBufferColorStableFlag)))
$asm = $asm.Replace('GROUND_FULL_RUNTIME_ACTIVE = $00', ('GROUND_FULL_RUNTIME_ACTIVE = ' + (ByteHex $GroundFullRuntimeFlag)))
$asm = $asm.Replace('VIC_BITMAP_MULTICOLOR_ENABLE = $01', 'VIC_BITMAP_MULTICOLOR_ENABLE = $01')
$asm = $asm.Replace('VIC_BITMAP_SINGLE_PIXEL_ENABLE = $00', 'VIC_BITMAP_SINGLE_PIXEL_ENABLE = $00')
$asm = $asm.Replace('ENGINE_GRAPHICS_MODE = $00', ('ENGINE_GRAPHICS_MODE = ' + (ByteHex $GraphicsModeNumber)))
$asm = $asm.Replace('ENGINE_RENDER_STYLE_WIRE = $00', ('ENGINE_RENDER_STYLE_WIRE = ' + (ByteHex $WireRenderFlag)))
$asm = $asm.Replace('ENGINE_RENDER_STYLE_HIDDEN_WIRE = $00', ('ENGINE_RENDER_STYLE_HIDDEN_WIRE = ' + (ByteHex $HiddenWireFlag)))
$asm = $asm.Replace('ENGINE_WIRE_MODE_RUNTIME_ACTIVE = $00', ('ENGINE_WIRE_MODE_RUNTIME_ACTIVE = ' + (ByteHex $EngineWireModeRuntimeFlag)))
$asm = $asm.Replace('ENGINE_WIRE_SPEED_PASS_1 = $00', ('ENGINE_WIRE_SPEED_PASS_1 = ' + (ByteHex $EngineWireSpeedPass1Flag)))
$asm = $asm.Replace('ENGINE_WIRE_SPEED_PASS_2 = $00', ('ENGINE_WIRE_SPEED_PASS_2 = ' + (ByteHex $EngineWireSpeedPass2Flag)))
$asm = $asm.Replace('ENGINE_WIRE_SPEED_PASS_3 = $00', ('ENGINE_WIRE_SPEED_PASS_3 = ' + (ByteHex $EngineWireSpeedPass3Flag)))
$asm = $asm.Replace('ENGINE_WIRE_DIRTY_CLEAR_ENABLE = $00', ('ENGINE_WIRE_DIRTY_CLEAR_ENABLE = ' + (ByteHex $EngineWireDirtyClearFlag)))
$asm = $asm.Replace('ENGINE_WIRE_HORIZON_DIRECT_DRAW = $00', ('ENGINE_WIRE_HORIZON_DIRECT_DRAW = ' + (ByteHex $EngineWireHorizonDirectDrawFlag)))
$asm = $asm.Replace('ENGINE_WIRE_SOLID_FEATURES_STRIPPED = $00', ('ENGINE_WIRE_SOLID_FEATURES_STRIPPED = ' + (ByteHex $EngineWireSolidFeaturesStrippedFlag)))
$asm = $asm.Replace('ENGINE_MODE2_MASK_DIRTY_TRACK_ENABLE = $00', ('ENGINE_MODE2_MASK_DIRTY_TRACK_ENABLE = ' + (ByteHex $EngineMode2FaceMaskRuntimeFlag)))
$asm = $asm.Replace('ENGINE_WIRE_CELL_WRITE_SKIP_SAME = $00', ('ENGINE_WIRE_CELL_WRITE_SKIP_SAME = ' + (ByteHex $EngineWireCellWriteSkipSameFlag)))
$asm = $asm.Replace('ENGINE_WIRE_MATERIAL_CACHE_RESET_FRAME = $00', ('ENGINE_WIRE_MATERIAL_CACHE_RESET_FRAME = ' + (ByteHex $EngineWireMaterialCacheResetFrameFlag)))
$asm = $asm.Replace('ENGINE_MODE2_MASK_COLOR_WRITES_STRIPPED = $00', ('ENGINE_MODE2_MASK_COLOR_WRITES_STRIPPED = ' + (ByteHex $EngineMode2MaskColorWritesStrippedFlag)))
$asm = $asm.Replace('ENGINE_WIRE_LIGHT_SHADING_STRIPPED = $00', ('ENGINE_WIRE_LIGHT_SHADING_STRIPPED = ' + (ByteHex $EngineWireLightShadingStrippedFlag)))
$asm = $asm.Replace('ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = $00', ('ENGINE_WIRE_EDGE_MATERIAL_CONTEXT = ' + (ByteHex $EngineWireEdgeMaterialContextFlag)))
$asm = $asm.Replace('ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE = $00', ('ENGINE_WIRE_MATERIAL_CACHE_INVALIDATE_ON_CHANGE = ' + (ByteHex $EngineWireMaterialCacheInvalidateOnChangeFlag)))
$asm = $asm.Replace('ENGINE_WIRE_MATERIAL_COMPARE_STRIPPED = $00', ('ENGINE_WIRE_MATERIAL_COMPARE_STRIPPED = ' + (ByteHex $EngineWireMaterialCompareStrippedFlag)))
$asm = $asm.Replace('ENGINE_MODE1_FACE_PASS_STRIPPED = $00', ('ENGINE_MODE1_FACE_PASS_STRIPPED = ' + (ByteHex $EngineMode1FacePassStrippedFlag)))
$asm = $asm.Replace('ENGINE_MODE1_EDGE_TABLE_DIRECT = $00', ('ENGINE_MODE1_EDGE_TABLE_DIRECT = ' + (ByteHex $EngineMode1EdgeTableDirectFlag)))
$asm = $asm.Replace('MODE1_OBJECT_DEPTH_SORT = $00', ('MODE1_OBJECT_DEPTH_SORT = ' + (ByteHex $Mode1ObjectDepthSortFlag)))
$asm = $asm.Replace('MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = $00', ('MODE1_FACE_BUCKET_MEMORY_SPECIALIZATION = ' + (ByteHex $Mode1MemorySpecializationFlag)))
$asm = $asm.Replace('MODE2_FACE_BUCKET_PIPELINE = $00', ('MODE2_FACE_BUCKET_PIPELINE = ' + (ByteHex $Mode2FaceBucketPipelineFlag)))
$asm = $asm.Replace('ENGINE_MODE1_WIRE_FAST_PLOT = $00', ('ENGINE_MODE1_WIRE_FAST_PLOT = ' + (ByteHex $EngineMode1WireFastPlotFlag)))
$asm = $asm.Replace('ENGINE_MODE1_WIRE_INSCREEN_FASTPATH = $00', ('ENGINE_MODE1_WIRE_INSCREEN_FASTPATH = ' + (ByteHex $EngineMode1WireInScreenFastPathFlag)))
$asm = $asm.Replace('ENGINE_MODE1_WIRE_CLIP_FALLBACK = $00', ('ENGINE_MODE1_WIRE_CLIP_FALLBACK = ' + (ByteHex $EngineMode1WireClipFallbackFlag)))
$asm = $asm.Replace('ENGINE_MODE1_UNIVERSAL_EDGE_TRAVERSAL = $00', ('ENGINE_MODE1_UNIVERSAL_EDGE_TRAVERSAL = ' + (ByteHex $EngineMode1UniversalEdgeTraversalFlag)))
$asm = $asm.Replace('ENGINE_MODE1_PROJDONE_DIRECT_TEST = $00', ('ENGINE_MODE1_PROJDONE_DIRECT_TEST = ' + (ByteHex $EngineMode1ProjdoneDirectTestFlag)))
$asm = $asm.Replace('ENGINE_MODE1_VERTEX_DRAWABLE_FALLBACK = $00', ('ENGINE_MODE1_VERTEX_DRAWABLE_FALLBACK = ' + (ByteHex $EngineMode1VertexDrawableFallbackFlag)))
$asm = $asm.Replace('ENGINE_MODE1_WIRE_RASTER_HOTLOOP = $00', ('ENGINE_MODE1_WIRE_RASTER_HOTLOOP = ' + (ByteHex $EngineMode1WireRasterHotloopFlag)))
$asm = $asm.Replace('ENGINE_MODE1_WIRE_POINT_BOUNDS_STRIPPED = $00', ('ENGINE_MODE1_WIRE_POINT_BOUNDS_STRIPPED = ' + (ByteHex $EngineMode1WirePointBoundsStrippedFlag)))
$asm = $asm.Replace('ENGINE_MODE1_WIRE_POINT_DIRECT_ENTRY = $00', ('ENGINE_MODE1_WIRE_POINT_DIRECT_ENTRY = ' + (ByteHex $EngineMode1WirePointDirectEntryFlag)))
$asm = $asm.Replace('ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE = $00', ('ENGINE_MODE1_MATERIAL_CELL_ROW_CACHE = ' + (ByteHex $EngineMode1MaterialCellRowCacheFlag)))
$asm = $asm.Replace('ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE = $00', ('ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE = ' + (ByteHex $EngineMode1MaterialStartbyteReuseFlag)))
$asm = $asm.Replace('ENGINE_MODE2_WIRE_RASTER_HOTLOOP = $00', ('ENGINE_MODE2_WIRE_RASTER_HOTLOOP = ' + (ByteHex $EngineMode2WireRasterHotloopFlag)))
$asm = $asm.Replace('ENGINE_MODE2_WIRE_POINT_BOUNDS_STRIPPED = $00', ('ENGINE_MODE2_WIRE_POINT_BOUNDS_STRIPPED = ' + (ByteHex $EngineMode2WirePointBoundsStrippedFlag)))
$asm = $asm.Replace('ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE = $00', ('ENGINE_MODE2_MATERIAL_CELL_ROW_CACHE = ' + (ByteHex $EngineMode2MaterialCellRowCacheFlag)))
$asm = $asm.Replace('ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE = $00', ('ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE = ' + (ByteHex $EngineMode2MaterialStartbyteReuseFlag)))
$asm = $asm.Replace('ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW = $00', ('ENGINE_MODE2_WIRE_FACE_EDGE_DIRECT_DRAW = ' + (ByteHex $EngineMode2WireFaceEdgeDirectDrawFlag)))
$asm = $asm.Replace('ENGINE_MODE2_WIRE_CLIP_GUARD_FALLBACK = $00', ('ENGINE_MODE2_WIRE_CLIP_GUARD_FALLBACK = ' + (ByteHex $EngineMode2WireClipGuardFallbackFlag)))
$asm = $asm.Replace('ENGINE_WIRE_SCANLINE_RUN_RASTERIZER = $00', ('ENGINE_WIRE_SCANLINE_RUN_RASTERIZER = ' + (ByteHex $EngineWireScanlineRunRasterizerFlag)))
$asm = $asm.Replace('ENGINE_WIRE_SCANLINE_RUN_SHALLOW_ONLY = $00', ('ENGINE_WIRE_SCANLINE_RUN_SHALLOW_ONLY = ' + (ByteHex $EngineWireScanlineRunShallowOnlyFlag)))
$asm = $asm.Replace('ENGINE_WIRE_SCANLINE_RUN_POINT_FALLBACK = $00', ('ENGINE_WIRE_SCANLINE_RUN_POINT_FALLBACK = ' + (ByteHex $EngineWireScanlineRunPointFallbackFlag)))
$asm = $asm.Replace('ENGINE_WIRE_SCANLINE_RUN_ENDPOINT_STATE_PRESERVED = $00', ('ENGINE_WIRE_SCANLINE_RUN_ENDPOINT_STATE_PRESERVED = ' + (ByteHex $EngineWireScanlineRunEndpointStatePreservedFlag)))
$asm = $asm.Replace('ENGINE_MODE1_SCANLINE_RUN_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_SCANLINE_RUN_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1ScanlineRunRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_SCANLINE_RUN_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_SCANLINE_RUN_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2ScanlineRunRuntimeFlag)))
$asm = $asm.Replace('ENGINE_WIRE_STEEP_LINE_FASTPATH = $00', ('ENGINE_WIRE_STEEP_LINE_FASTPATH = ' + (ByteHex $EngineWireSteepLineFastpathFlag)))
$asm = $asm.Replace('ENGINE_WIRE_STEEP_RATIO_2_TO_1 = $00', ('ENGINE_WIRE_STEEP_RATIO_2_TO_1 = ' + (ByteHex $EngineWireSteepRatio2To1Flag)))
$asm = $asm.Replace('ENGINE_WIRE_VERTICAL_RUN_WRITER = $00', ('ENGINE_WIRE_VERTICAL_RUN_WRITER = ' + (ByteHex $EngineWireVerticalRunWriterFlag)))
$asm = $asm.Replace('ENGINE_WIRE_STEEP_POINT_FALLBACK = $00', ('ENGINE_WIRE_STEEP_POINT_FALLBACK = ' + (ByteHex $EngineWireSteepPointFallbackFlag)))
$asm = $asm.Replace('ENGINE_WIRE_STEEP_ENDPOINT_STATE_PRESERVED = $00', ('ENGINE_WIRE_STEEP_ENDPOINT_STATE_PRESERVED = ' + (ByteHex $EngineWireSteepEndpointStatePreservedFlag)))
$asm = $asm.Replace('ENGINE_MODE1_STEEP_LINE_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_STEEP_LINE_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1SteepLineRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_STEEP_LINE_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_STEEP_LINE_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2SteepLineRuntimeFlag)))
$asm = $asm.Replace('ENGINE_WIRE_CELL_TRANSITION_UPDATES = $00', ('ENGINE_WIRE_CELL_TRANSITION_UPDATES = ' + (ByteHex $EngineWireCellTransitionUpdatesFlag)))
$asm = $asm.Replace('ENGINE_WIRE_DIRTY_SAME_BYTE_SKIP = $00', ('ENGINE_WIRE_DIRTY_SAME_BYTE_SKIP = ' + (ByteHex $EngineWireDirtySameByteSkipFlag)))
$asm = $asm.Replace('ENGINE_WIRE_MATERIAL_CALL_ON_CELL_CHANGE = $00', ('ENGINE_WIRE_MATERIAL_CALL_ON_CELL_CHANGE = ' + (ByteHex $EngineWireMaterialCallOnCellChangeFlag)))
$asm = $asm.Replace('ENGINE_WIRE_MATERIAL_DIRECT_WRITE_ENTRY = $00', ('ENGINE_WIRE_MATERIAL_DIRECT_WRITE_ENTRY = ' + (ByteHex $EngineWireMaterialDirectWriteEntryFlag)))
$asm = $asm.Replace('ENGINE_WIRE_TRANSITION_CACHE_RESET_FRAME = $00', ('ENGINE_WIRE_TRANSITION_CACHE_RESET_FRAME = ' + (ByteHex $EngineWireTransitionCacheResetFrameFlag)))
$asm = $asm.Replace('ENGINE_MODE1_CELL_TRANSITION_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_CELL_TRANSITION_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1CellTransitionRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_CELL_TRANSITION_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_CELL_TRANSITION_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2CellTransitionRuntimeFlag)))
$asm = $asm.Replace('ENGINE_WIRE_8BIT_BRESENHAM = $00', ('ENGINE_WIRE_8BIT_BRESENHAM = ' + (ByteHex $EngineWire8BitBresenhamFlag)))
$asm = $asm.Replace('ENGINE_WIRE_8BIT_INTERMEDIATE_SLOPES = $00', ('ENGINE_WIRE_8BIT_INTERMEDIATE_SLOPES = ' + (ByteHex $EngineWire8BitIntermediateSlopesFlag)))
$asm = $asm.Replace('ENGINE_WIRE_8BIT_ERROR_ACCUMULATOR = $00', ('ENGINE_WIRE_8BIT_ERROR_ACCUMULATOR = ' + (ByteHex $EngineWire8BitErrorAccumulatorFlag)))
$asm = $asm.Replace('ENGINE_WIRE_16BIT_TRACE_FALLBACK = $00', ('ENGINE_WIRE_16BIT_TRACE_FALLBACK = ' + (ByteHex $EngineWire16BitTraceFallbackFlag)))
$asm = $asm.Replace('ENGINE_MODE1_8BIT_BRESENHAM_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_8BIT_BRESENHAM_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1Bresenham8RuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_8BIT_BRESENHAM_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_8BIT_BRESENHAM_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2Bresenham8RuntimeFlag)))
$asm = $asm.Replace('ENGINE_WIRE_RASTER_CONSOLIDATION = $00', ('ENGINE_WIRE_RASTER_CONSOLIDATION = ' + (ByteHex $EngineWireRasterConsolidationFlag)))
$asm = $asm.Replace('ENGINE_WIRE_SINGLE_SLOPE_DISPATCH = $00', ('ENGINE_WIRE_SINGLE_SLOPE_DISPATCH = ' + (ByteHex $EngineWireSingleSlopeDispatchFlag)))
$asm = $asm.Replace('ENGINE_WIRE_SINGLE_TRACE_GATE = $00', ('ENGINE_WIRE_SINGLE_TRACE_GATE = ' + (ByteHex $EngineWireSingleTraceGateFlag)))
$asm = $asm.Replace('ENGINE_WIRE_TRACE_FALLBACK = $00', ('ENGINE_WIRE_TRACE_FALLBACK = ' + (ByteHex $EngineWireTraceFallbackFlag)))
$asm = $asm.Replace('ENGINE_MODE1_RASTER_CONSOLIDATION_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_RASTER_CONSOLIDATION_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1RasterConsolidationRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_RASTER_CONSOLIDATION_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_RASTER_CONSOLIDATION_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2RasterConsolidationRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_HORIZON_ROW_MASK_CANDIDATE = $00', ('ENGINE_MODE2_HORIZON_ROW_MASK_CANDIDATE = ' + (ByteHex $EngineMode2HorizonRowMaskCandidateFlag)))
$asm = $asm.Replace('ENGINE_MODE2_HORIZON_ROW_MASK_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_HORIZON_ROW_MASK_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2HorizonRowMaskRuntimeFlag)))
$asm = $asm.Replace('ENGINE_WIRE_HORIZON_ONLY_RUNTIME_ACTIVE = $00', ('ENGINE_WIRE_HORIZON_ONLY_RUNTIME_ACTIVE = ' + (ByteHex $EngineGroundHorizonOnlyRuntimeFlag)))
$asm = $asm.Replace('ENGINE_WIRE_VIC_POLICY_FORCED_OFF = $00', ('ENGINE_WIRE_VIC_POLICY_FORCED_OFF = ' + (ByteHex $EngineWireVicPolicyForcedOffFlag)))
$asm = $asm.Replace('VIC_COLOR_POLICY_REQUESTED_ENABLE = $00', ('VIC_COLOR_POLICY_REQUESTED_ENABLE = ' + (ByteHex $RequestedVicColorPolicyEnableFlag)))
$asm = $asm.Replace('VIC_COLOR_POLICY_REQUESTED_ACTIVE = $00', ('VIC_COLOR_POLICY_REQUESTED_ACTIVE = ' + (ByteHex $RequestedVicColorPolicyActiveFlag)))
$asm = $asm.Replace('VIC_COLOR_POLICY_EFFECTIVE_ENABLE = $00', ('VIC_COLOR_POLICY_EFFECTIVE_ENABLE = ' + (ByteHex $VicColorPolicyEffectiveEnableFlag)))
$asm = $asm.Replace('VIC_COLOR_POLICY_EFFECTIVE_ACTIVE = $00', ('VIC_COLOR_POLICY_EFFECTIVE_ACTIVE = ' + (ByteHex $VicColorPolicyEffectiveActiveFlag)))
$asm = $asm.Replace('WIRE_MATERIAL_COLOR_ENABLE = $00', ('WIRE_MATERIAL_COLOR_ENABLE = ' + (ByteHex $EngineWireMaterialColorRuntimeFlag)))
$asm = $asm.Replace('WIRE_OBJECT_MATERIAL_PATH_ENABLE = $00', ('WIRE_OBJECT_MATERIAL_PATH_ENABLE = ' + (ByteHex $EngineWireObjectMaterialPathRuntimeFlag)))
$asm = $asm.Replace('ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE = $00', ('ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE = ' + (ByteHex $EngineWireMaterialCellsRuntimeFlag)))
$asm = $asm.Replace('ENGINE_GROUND_HORIZON_MATERIAL_ISOLATED = $00', ('ENGINE_GROUND_HORIZON_MATERIAL_ISOLATED = ' + (ByteHex $EngineGroundHorizonMaterialIsolatedFlag)))
$asm = $asm.Replace('ENGINE_GROUND_HORIZON_MATERIAL_RESTORE = $00', ('ENGINE_GROUND_HORIZON_MATERIAL_RESTORE = ' + (ByteHex $EngineGroundHorizonMaterialRestoreFlag)))
$asm = $asm.Replace('ENGINE_MESH_WIRE_MATERIAL_RELOAD_AFTER_GROUND = $00', ('ENGINE_MESH_WIRE_MATERIAL_RELOAD_AFTER_GROUND = ' + (ByteHex $EngineMeshWireMaterialReloadAfterGroundFlag)))
$asm = $asm.Replace('ENGINE_WIRE_CAMERA_THROUGH_MESH_ENABLE = $00', ('ENGINE_WIRE_CAMERA_THROUGH_MESH_ENABLE = ' + (ByteHex $EngineWireCameraThroughMeshFlag)))
$asm = $asm.Replace('ENGINE_WIRE_NEAR_CLIP_RELAXED = $00', ('ENGINE_WIRE_NEAR_CLIP_RELAXED = ' + (ByteHex $EngineWireNearClipRelaxedFlag)))
$asm = $asm.Replace('ENGINE_WIRE_OBJECT_REJECT_RELAXED = $00', ('ENGINE_WIRE_OBJECT_REJECT_RELAXED = ' + (ByteHex $EngineWireObjectRejectRelaxedFlag)))
$asm = $asm.Replace('ENGINE_WIRE_EDGE_CLIP_TOLERANT = $00', ('ENGINE_WIRE_EDGE_CLIP_TOLERANT = ' + (ByteHex $EngineWireEdgeClipTolerantFlag)))
$asm = $asm.Replace('ENGINE_MODE2_FACE_MASK_NEAR_TOLERANT = $00', ('ENGINE_MODE2_FACE_MASK_NEAR_TOLERANT = ' + (ByteHex $EngineMode2FaceMaskNearTolerantFlag)))
$asm = $asm.Replace('GROUND_HORIZON_DARK_GREY_ENABLE = $00', ('GROUND_HORIZON_DARK_GREY_ENABLE = ' + (ByteHex $GroundHorizonDarkGreyRuntimeFlag)))
$asm = $asm.Replace('GROUND_RUNTIME_OCCLUSION_ENABLE = $00', ('GROUND_RUNTIME_OCCLUSION_ENABLE = ' + (ByteHex $RuntimeWorldGroundOccludeFlag)))
$asm = $asm.Replace('GROUND_RUNTIME_WIRE_OCCLUSION_ENABLE = $00', ('GROUND_RUNTIME_WIRE_OCCLUSION_ENABLE = ' + (ByteHex $RuntimeWorldGroundWireOccludeFlag)))
$asm = $asm.Replace('GROUND_RUNTIME_ROLL_PLANE_ENABLE = $00', ('GROUND_RUNTIME_ROLL_PLANE_ENABLE = ' + (ByteHex $RuntimeWorldGroundRollSpanEdgeFlag)))
$asm = $asm.Replace('ENGINE_MODE1_WIRE_PURE_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_WIRE_PURE_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1WirePureRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE1_WIRE_RENDER_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_WIRE_RENDER_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1WireRenderRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE1_WIRE_FACE_EDGE_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_WIRE_FACE_EDGE_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1WireFaceEdgeRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE1_HIDDEN_WIRE_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_HIDDEN_WIRE_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1HiddenWireRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE1_POLY_FILL_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_POLY_FILL_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1PolyFillRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE1_WIRE_DEPTH_SORT_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_WIRE_DEPTH_SORT_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1WireDepthSortRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE1_WIRE_OBJECT_SORT_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_WIRE_OBJECT_SORT_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1WireObjectSortRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE1_VIC_POLICY_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_VIC_POLICY_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1VicPolicyRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE1_GROUND_OCCLUSION_RUNTIME_ACTIVE = $00', ('ENGINE_MODE1_GROUND_OCCLUSION_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode1GroundOcclusionRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_HIDDEN_WIRE_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_HIDDEN_WIRE_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2HiddenWireRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_WIRE_RENDER_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_WIRE_RENDER_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2WireRenderRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_POLY_FILL_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_POLY_FILL_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2PolyFillRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_VIC_POLICY_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_VIC_POLICY_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2VicPolicyRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_FACE_MASK_CONTRACT_ENABLE = $00', ('ENGINE_MODE2_FACE_MASK_CONTRACT_ENABLE = ' + (ByteHex $EngineMode2FaceMaskContractFlag)))
$asm = $asm.Replace('ENGINE_MODE2_FACE_MASK_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_FACE_MASK_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2FaceMaskRuntimeFlag)))
$asm = $asm.Replace('ENGINE_MODE2_HORIZON_BEHIND_FACE_TARGET = $00', ('ENGINE_MODE2_HORIZON_BEHIND_FACE_TARGET = ' + (ByteHex $EngineMode2HorizonBehindFaceTargetFlag)))
$asm = $asm.Replace('ENGINE_MODE2_HORIZON_BEHIND_FACE_RUNTIME_ACTIVE = $00', ('ENGINE_MODE2_HORIZON_BEHIND_FACE_RUNTIME_ACTIVE = ' + (ByteHex $EngineMode2HorizonBehindFaceRuntimeFlag)))
$asm = $asm.Replace('GRAPHICS_MODE = $04', ('GRAPHICS_MODE = ' + (ByteHex $GraphicsModeNumber)))
$asm = $asm.Replace('RUNTIME_GRAPHICS_MODE_SWITCH = $00', ('RUNTIME_GRAPHICS_MODE_SWITCH = ' + (ByteHex $RuntimeGraphicsModeSwitchFlag)))
$asm = $asm.Replace('WIRE_MESH_COUNT = $00', ('WIRE_MESH_COUNT = ' + (ByteHex $WireMeshCount)))
$asm = $asm.Replace('WIRE_EDGE_COUNT = $00', ('WIRE_EDGE_COUNT = ' + (ByteHex $EmittedWireEdgeCount)))
$asm = $asm.Replace('WIRE_DEPTH_ENTRY_COUNT = $00', ('WIRE_DEPTH_ENTRY_COUNT = ' + (ByteHex $WireDepthEntryCount)))
$asm = $asm.Replace('WIRE_RENDER_ENABLE = $00', ('WIRE_RENDER_ENABLE = ' + (ByteHex $WireRenderFlag)))
$asm = $asm.Replace('WIRE_OVERLAY_ENABLE = $00', ('WIRE_OVERLAY_ENABLE = ' + (ByteHex $WireOverlayFlag)))
$asm = $asm.Replace('WIRE_DEPTH_SORT_ENABLE = $00', ('WIRE_DEPTH_SORT_ENABLE = ' + (ByteHex $WireDepthSortFlag)))
$asm = $asm.Replace('WIRE_OBJECT_SORT_ENABLE = $00', ('WIRE_OBJECT_SORT_ENABLE = ' + (ByteHex $EmitWireObjectSortFlag)))
$asm = $asm.Replace('WIRE_OBJECT_MATERIAL_ENABLE = $00', ('WIRE_OBJECT_MATERIAL_ENABLE = ' + (ByteHex $WireObjectMaterialFlag)))
$asm = $asm.Replace('HIDDEN_WIRE_ENABLE = $00', ('HIDDEN_WIRE_ENABLE = ' + (ByteHex $HiddenWireFlag)))
$asm = $asm.Replace('WIRE_FACE_EDGE_ENABLE = $00', ('WIRE_FACE_EDGE_ENABLE = ' + (ByteHex $WireFaceEdgeFlag)))
$asm = $asm.Replace('WIRE_EDGE_SOLID_COLOR_ENABLE = $00', ('WIRE_EDGE_SOLID_COLOR_ENABLE = ' + (ByteHex $WireEdgeSolidColorFlag)))
$asm = $asm.Replace('WIRE_TWO_COLOR_MULTIMATERIAL_ENABLE = $00', ('WIRE_TWO_COLOR_MULTIMATERIAL_ENABLE = ' + (ByteHex $WireTwoColorMultimaterialFlag)))
$asm = $asm.Replace('WIRE_TWO_COLOR_MODE1_ENABLE = $00', ('WIRE_TWO_COLOR_MODE1_ENABLE = ' + (ByteHex $WireTwoColorMode1Flag)))
$asm = $asm.Replace('WIRE_TWO_COLOR_MODE2_ENABLE = $00', ('WIRE_TWO_COLOR_MODE2_ENABLE = ' + (ByteHex $WireTwoColorMode2Flag)))
$asm = $asm.Replace('WIRE_TWO_COLOR_SLOT_01_COLOR = $00', ('WIRE_TWO_COLOR_SLOT_01_COLOR = ' + (ByteHex $WireTwoColorSlot01Color)))
$asm = $asm.Replace('WIRE_TWO_COLOR_SLOT_10_COLOR = $00', ('WIRE_TWO_COLOR_SLOT_10_COLOR = ' + (ByteHex $WireTwoColorSlot10Color)))
$asm = $asm.Replace('WIRE_TWO_COLOR_SCREEN_BYTE = $00', ('WIRE_TWO_COLOR_SCREEN_BYTE = ' + (ByteHex $WireTwoColorScreenByte)))
$asm = $asm.Replace('WIRE_TWO_COLOR_FIXED_COLOR_RAM = $00', ('WIRE_TWO_COLOR_FIXED_COLOR_RAM = ' + (ByteHex $WireTwoColorFixedColorRam)))
$asm = $asm.Replace('POLY_FILL_ENABLE = $01', ('POLY_FILL_ENABLE = ' + (ByteHex $PolyFillFlag)))
$asm = $asm.Replace('FAST_FILL_BOUNDS_TRACE = $00', ('FAST_FILL_BOUNDS_TRACE = ' + (ByteHex $FastFillBoundsTraceFlag)))
$asm = $asm.Replace('FACE_RENDER_ENABLE = $01', ('FACE_RENDER_ENABLE = ' + (ByteHex $FaceRenderEnableFlag)))
$asm = $asm.Replace('WIRE_PURE_ENABLE = $00', ('WIRE_PURE_ENABLE = ' + (ByteHex $WirePureFlag)))
$asm = $asm.Replace('STATIC_SHADE_CACHE = $00', ('STATIC_SHADE_CACHE = ' + (ByteHex $StaticShadeCacheFlag)))
$asm = $asm.Replace('FULL_DYNAMIC_SHADE = $01', ('FULL_DYNAMIC_SHADE = ' + (ByteHex $FullDynamicShadeFlag)))
$asm = $asm.Replace('MODE4_DYNAMIC_SHADE_THRESHOLD_FIX = $00', ('MODE4_DYNAMIC_SHADE_THRESHOLD_FIX = ' + (ByteHex $Mode4DynamicShadeThresholdFixFlag)))
$asm = $asm.Replace('STATIC_SHADE_DIRECT = $00', ('STATIC_SHADE_DIRECT = ' + (ByteHex $StaticShadeDirectFlag)))
$asm = $asm.Replace('FRAME_FACE_FILL_CACHE = $00', ('FRAME_FACE_FILL_CACHE = ' + (ByteHex $FrameFaceFillCacheFlag)))
$asm = $asm.Replace('MODE4_OBJECT_LIGHT_CACHE = $00', ('MODE4_OBJECT_LIGHT_CACHE = ' + (ByteHex $Mode4ObjectLightCacheFlag)))
$asm = $asm.Replace('MODE4_UNCACHED_LIGHT_FALLBACK = $00', ('MODE4_UNCACHED_LIGHT_FALLBACK = ' + (ByteHex $EmitMode4UncachedLightFallbackFlag)))
$asm = $asm.Replace('HAS_TRI_FACES = $00', ('HAS_TRI_FACES = ' + (ByteHex $HasTriangleFacesFlag)))
$asm = $asm.Replace('FORCE_FACE_RENDER = $00', ('FORCE_FACE_RENDER = ' + (ByteHex $ForceFaceRenderFlag)))
$asm = $asm.Replace('CONSERVATIVE_FACE_CULL = $00', ('CONSERVATIVE_FACE_CULL = ' + (ByteHex $ConservativeFaceCullFlag)))
$asm = $asm.Replace('CONSERVATIVE_SLIVER_CULL = $00', ('CONSERVATIVE_SLIVER_CULL = ' + (ByteHex $ConservativeSliverCullFlag)))
$asm = $asm.Replace('CONSERVATIVE_CULL_NEG_AREA = $20', ('CONSERVATIVE_CULL_NEG_AREA = ' + (ByteHex $ConservativeCullNegArea)))
$asm = $asm.Replace('CONSERVATIVE_EDGE_CULL_NEG_AREA = $60', ('CONSERVATIVE_EDGE_CULL_NEG_AREA = ' + (ByteHex $ConservativeEdgeCullNegArea)))
$asm = $asm.Replace('CONSERVATIVE_SLIVER_THIN_SPAN = $03', ('CONSERVATIVE_SLIVER_THIN_SPAN = ' + (ByteHex $ConservativeSliverThinSpan)))
$asm = $asm.Replace('CONSERVATIVE_SLIVER_LONG_SPAN = $06', ('CONSERVATIVE_SLIVER_LONG_SPAN = ' + (ByteHex $ConservativeSliverLongSpan)))
$asm = $asm.Replace('STANDARD_PROJECT_VERTEX = $00', ('STANDARD_PROJECT_VERTEX = ' + (ByteHex $StandardProjectVertexFlag)))
$asm = $asm.Replace('FACE_CULL_PREP = $00', ('FACE_CULL_PREP = ' + (ByteHex $FaceCullPrepFlag)))
$asm = $asm.Replace('REFERENCE_PROJECTION = $00', ('REFERENCE_PROJECTION = ' + (ByteHex $ReferenceProjectionFlag)))
$asm = $asm.Replace('EXTENDED_TABLE_PROJECTION = $00', ('EXTENDED_TABLE_PROJECTION = ' + (ByteHex $ExtendedTableProjectionFlag)))
$asm = $asm.Replace('EXPLORER_TABLE_PROJECTION = $00', ('EXPLORER_TABLE_PROJECTION = ' + (ByteHex $ExplorerTableProjectionFlag)))
$asm = $asm.Replace('AUTO_CYCLE_FRAMES = $00', ('AUTO_CYCLE_FRAMES = ' + (ByteHex $AutoCycleFrames)))
$asm = $asm.Replace('RANDOM_MATERIAL_CYCLE = $00', ('RANDOM_MATERIAL_CYCLE = ' + (ByteHex $RandomMaterialCycleFlag)))
$asm = $asm.Replace('RANDOM_MATERIAL_CYCLE_TICKS = $64', ('RANDOM_MATERIAL_CYCLE_TICKS = ' + (ByteHex $RandomMaterialCycleTicks)))
$asm = $asm.Replace('MOTION_Z_START_FRAC = $00', ('MOTION_Z_START_FRAC = ' + (ByteHex $MotionZStartFrac)))
$asm = $asm.Replace('MOTION_Z_START_LO = $00', ('MOTION_Z_START_LO = ' + (ByteHex $MotionZStartLo)))
$asm = $asm.Replace('MOTION_Z_START_HI = $00', ('MOTION_Z_START_HI = ' + (ByteHex $MotionZStartHi)))
$asm = $asm.Replace('MOTION_Z_STEP_FRAC = $00', ('MOTION_Z_STEP_FRAC = ' + (ByteHex $MotionZStepFrac)))
$asm = $asm.Replace('MOTION_Z_STEP_LO = $00', ('MOTION_Z_STEP_LO = ' + (ByteHex $MotionZStepLo)))
$asm = $asm.Replace('MOTION_Z_STEP_HI = $00', ('MOTION_Z_STEP_HI = ' + (ByteHex $MotionZStepHi)))
$asm = $asm.Replace('MOTION_Z_START_ON_RETURN = $00', ('MOTION_Z_START_ON_RETURN = ' + (ByteHex $MotionZStartGateFlag)))
$asm = $asm.Replace('MOTION_Z_START_ON_ZERO = $00', ('MOTION_Z_START_ON_ZERO = ' + (ByteHex $MotionZStartOnZeroFlag)))
$asm = $asm.Replace('MIN_FACE_AREA = $04', ('MIN_FACE_AREA = ' + (ByteHex $MinFaceArea)))
$asm = $asm.Replace('VIDEO_STANDARD_AUTO = $00', ('VIDEO_STANDARD_AUTO = ' + (ByteHex $VideoStandardAutoFlag)))
$asm = $asm.Replace('VIDEO_STANDARD_FORCE_PAL = $00', ('VIDEO_STANDARD_FORCE_PAL = ' + (ByteHex $VideoStandardForcePalFlag)))
$asm = $asm.Replace('VIDEO_STANDARD_FORCE_NTSC = $00', ('VIDEO_STANDARD_FORCE_NTSC = ' + (ByteHex $VideoStandardForceNtscFlag)))
$asm = $asm.Replace('VIDEO_STANDARD_RUNTIME_DETECT = $00', ('VIDEO_STANDARD_RUNTIME_DETECT = ' + (ByteHex $VideoStandardRuntimeDetectFlag)))
$asm = $asm.Replace('VIDEO_STANDARD_INITIAL = $00', ('VIDEO_STANDARD_INITIAL = ' + (ByteHex $VideoStandardInitial)))
$asm = $asm.Replace('VIDEO_VBLANKS_PER_SECOND_INITIAL = $32', ('VIDEO_VBLANKS_PER_SECOND_INITIAL = ' + (ByteHex $VideoVblanksPerSecondInitial)))
$asm = $asm.Replace('XCOORD_COUNT = $01', ('XCOORD_COUNT = ' + (ByteHex $xCoords.Count)))
$asm = $asm.Replace('YCOORD_COUNT = $01', ('YCOORD_COUNT = ' + (ByteHex $yCoords.Count)))
$asm = $asm.Replace('ZCOORD_COUNT = $01', ('ZCOORD_COUNT = ' + (ByteHex $zCoords.Count)))
$asm = $asm.Replace('SCREEN_MIN_SPAN = $02', ('SCREEN_MIN_SPAN = ' + (ByteHex $ScreenMinSpan)))
$asm = $asm.Replace('PATTERN_MIN_SPAN = $00', ('PATTERN_MIN_SPAN = ' + (ByteHex $PatternMinSpan)))
$asm = $asm.Replace('SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y = $00', ('SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y = ' + (ByteHex $SolidSubpixelXYQ2LegacyDirectYFlag)))
$asm = $asm.Replace('MODE4_PATTERN_PROBE = $00', ('MODE4_PATTERN_PROBE = ' + (ByteHex $Mode4PatternProbeFlag)))
$asm = $asm.Replace('MODE4_PATTERN_PROBE_LATCHED_FACE = $00', ('MODE4_PATTERN_PROBE_LATCHED_FACE = ' + (ByteHex $Mode4PatternProbeLatchedFaceFlag)))
$asm = $asm.Replace('MODE4_VALID_SHADE_FACE_PROBE = $00', ('MODE4_VALID_SHADE_FACE_PROBE = ' + (ByteHex $Mode4ValidShadeFaceProbeFlag)))
$asm = $asm.Replace('MODE4_SHADE_STEP_LIMIT = $00', ('MODE4_SHADE_STEP_LIMIT = ' + (ByteHex $Mode4ShadeStepLimitFlag)))
$asm = $asm.Replace('MODE5_POLYGON_OUTLINE = $00', ('MODE5_POLYGON_OUTLINE = ' + (ByteHex $Mode5PolygonOutlineFlag)))
$asm = $asm.Replace('YQ2_FAST_DIV11X8 = $00', ('YQ2_FAST_DIV11X8 = ' + (ByteHex $YQ2FastDiv11x8Flag)))
$asm = $asm.Replace('YQ2_FAST_PIXEL_CONVERT = $00', ('YQ2_FAST_PIXEL_CONVERT = ' + (ByteHex $YQ2FastPixelConvertFlag)))
$asm = $asm.Replace('YQ2_INLINE_BOUNDS = $00', ('YQ2_INLINE_BOUNDS = ' + (ByteHex $YQ2InlineBoundsFlag)))
$asm = $asm.Replace('MODE4_FACE_ID_LATCH = $00', ('MODE4_FACE_ID_LATCH = ' + (ByteHex $Mode4FaceIdLatchFlag)))
$asm = $asm.Replace('FPS_OVERLAY_ENABLE = $00', ('FPS_OVERLAY_ENABLE = ' + (ByteHex $FpsOverlayEnableFlag)))
$asm = $asm.Replace('FPS_OVERLAY_ON_START = $00', ('FPS_OVERLAY_ON_START = ' + (ByteHex $FpsOverlayOnStartFlag)))
$asm = $asm.Replace('FPS_COUNTER_ENABLE = $00', ('FPS_COUNTER_ENABLE = ' + (ByteHex $FpsCounterEnableFlag)))
$asm = $asm.Replace('FPS_COUNTER_ONLY = $00', ('FPS_COUNTER_ONLY = ' + (ByteHex $FpsCounterOnlyFlag)))
$asm = $asm.Replace('FPS_OVERLAY_MEMORY_CONTRACT = $00', ('FPS_OVERLAY_MEMORY_CONTRACT = ' + (ByteHex $FpsOverlayMemoryContractFlag)))
$asm = $asm.Replace('FPS_OVERLAY_UNDER_IO_LAYOUT = $00', ('FPS_OVERLAY_UNDER_IO_LAYOUT = ' + (ByteHex $FpsOverlayUnderIoLayoutFlag)))
$asm = $asm.Replace('FPS_KEY_TOGGLE_ENABLE = $00', ('FPS_KEY_TOGGLE_ENABLE = ' + (ByteHex $FpsKeyToggleEnableFlag)))
$asm = $asm.Replace('CONTROL_SPACE_KEY = $00', ('CONTROL_SPACE_KEY = ' + (ByteHex $ControlSpaceFlag)))
$asm = $asm.Replace('CONTROL_RETURN_KEY = $00', ('CONTROL_RETURN_KEY = ' + (ByteHex $ControlReturnFlag)))
$asm = $asm.Replace('CONTROL_ROTATION_KEY = $00', ('CONTROL_ROTATION_KEY = ' + (ByteHex $ControlRotationFlag)))
$asm = $asm.Replace('CONTROL_LIGHT_KEY = $00', ('CONTROL_LIGHT_KEY = ' + (ByteHex $ControlLightFlag)))
$asm = $asm.Replace('CONTROL_LOWRES_KEY = $00', ('CONTROL_LOWRES_KEY = ' + (ByteHex $ControlLowresFlag)))
$asm = $asm.Replace('CONTROL_ZERO_MOTION_KEY = $00', ('CONTROL_ZERO_MOTION_KEY = ' + (ByteHex $ControlZeroMotionFlag)))
$asm = $asm.Replace('LOWRES_TRACE_ENABLE = $00', ('LOWRES_TRACE_ENABLE = ' + (ByteHex $LowresTraceFlag)))
$asm = $asm.Replace('CONTROL_MATERIAL_KEYS = $00', ('CONTROL_MATERIAL_KEYS = ' + (ByteHex $ControlMaterialFlag)))
$asm = $asm.Replace('CONTROL_REFLECTIVITY_KEYS = $00', ('CONTROL_REFLECTIVITY_KEYS = ' + (ByteHex $ControlReflectivityFlag)))
$asm = $asm.Replace('FULL_CLEAR = $00', ('FULL_CLEAR = ' + (ByteHex $FullClearFlag)))
$asm = $asm.Replace('TRACK_DIRTY_SPANS = $01', ('TRACK_DIRTY_SPANS = ' + (ByteHex $TrackDirtySpansFlag)))
$asm = $asm.Replace('DYNAMIC_LIGHT = $00', ('DYNAMIC_LIGHT = ' + (ByteHex $DynamicLightFlag)))
$asm = $asm.Replace('STATIC_RUNTIME_LIGHT = $00', ('STATIC_RUNTIME_LIGHT = ' + (ByteHex $SceneStaticRuntimeLightFlag)))
$asm = $asm.Replace('STATIC_POSE = $00', ('STATIC_POSE = ' + (ByteHex $StaticPoseFlag)))
$asm = $asm.Replace('INITIAL_ANGLE_X = $18', ('INITIAL_ANGLE_X = ' + (ByteHex $InitialAngleX)))
$asm = $asm.Replace('INITIAL_ANGLE_Y = $19', ('INITIAL_ANGLE_Y = ' + (ByteHex $InitialAngleY)))
$asm = $asm.Replace('INITIAL_ANGLE_Z = $2F', ('INITIAL_ANGLE_Z = ' + (ByteHex $InitialAngleZ)))
$asm = $asm.Replace('LIGHT_PHASE_COUNT = $10', ('LIGHT_PHASE_COUNT = ' + (ByteHex $RuntimeLightPhaseCount)))
$asm = $asm.Replace('LIGHT_PHASE_MASK = $0f', ('LIGHT_PHASE_MASK = ' + (ByteHex ($RuntimeLightPhaseCount - 1))))
$asm = $asm.Replace('LIGHT_TICK_DIV = $04', ('LIGHT_TICK_DIV = ' + (ByteHex $LightTickDiv)))
$asm = $asm.Replace('LIGHT_INTENSITY_MAX = $0a', ('LIGHT_INTENSITY_MAX = ' + (ByteHex $EffectiveLightIntensity)))
$asm = $asm.Replace('LIGHT_PULSE_ON_SPACE = $00', ('LIGHT_PULSE_ON_SPACE = ' + (ByteHex $LightPulseOnSpaceFlag)))
$asm = $asm.Replace('MATERIAL_DEFAULT_INDEX = $00', ('MATERIAL_DEFAULT_INDEX = ' + (ByteHex $MaterialIndex)))
$asm = $asm.Replace('MATERIAL_REFLECTIVITY = $00', ('MATERIAL_REFLECTIVITY = ' + (ByteHex $Reflectivity)))
$asm = $asm.Replace('MATERIAL_REFLECTIVITY_OFFSET = $00', ('MATERIAL_REFLECTIVITY_OFFSET = ' + (ByteHex $MaterialReflectivityOffset)))
$asm = $asm.Replace('MATERIAL_SCREEN_BYTE = $bc', ('MATERIAL_SCREEN_BYTE = ' + (ByteHex $MaterialScreenByte)))
$asm = $asm.Replace('MATERIAL_COLOR_RAM = $01', ('MATERIAL_COLOR_RAM = ' + (ByteHex $MaterialColorByte)))
$asm = $asm.Replace('WORLD_BACKGROUND_COLOR = $00', ('WORLD_BACKGROUND_COLOR = ' + (ByteHex $WorldBackgroundColor)))
$asm = $asm.Replace('WORLD_GROUND_ENABLE = $00', ('WORLD_GROUND_ENABLE = ' + (ByteHex $WorldGroundEnableFlag)))
$asm = $asm.Replace('WORLD_GROUND_COLOR = $05', ('WORLD_GROUND_COLOR = ' + (ByteHex $WorldGroundColor)))
$asm = $asm.Replace('WORLD_GROUND_SCREEN_BYTE = $55', ('WORLD_GROUND_SCREEN_BYTE = ' + (ByteHex $WorldGroundScreenByte)))
$asm = $asm.Replace('WORLD_GROUND_COLOR_RAM = $05', ('WORLD_GROUND_COLOR_RAM = ' + (ByteHex $WorldGroundColorRam)))
$asm = $asm.Replace('WORLD_GROUND_Y_LO = $00', ('WORLD_GROUND_Y_LO = ' + (ByteHex ([int]$WorldGroundYSplit.Lo))))
$asm = $asm.Replace('WORLD_GROUND_Y_HI = $00', ('WORLD_GROUND_Y_HI = ' + (ByteHex ([int]$WorldGroundYSplit.Hi))))
$asm = $asm.Replace('WORLD_GROUND_Y_EXT = $00', ('WORLD_GROUND_Y_EXT = ' + (ByteHex $WorldGroundYExt)))
$asm = $asm.Replace('WORLD_GROUND_PUBLIC_Z_LO = $00', ('WORLD_GROUND_PUBLIC_Z_LO = ' + (ByteHex ([int]$WorldGroundYSplit.Lo))))
$asm = $asm.Replace('WORLD_GROUND_PUBLIC_Z_HI = $00', ('WORLD_GROUND_PUBLIC_Z_HI = ' + (ByteHex ([int]$WorldGroundYSplit.Hi))))
$asm = $asm.Replace('WORLD_GROUND_PUBLIC_Z_EXT = $00', ('WORLD_GROUND_PUBLIC_Z_EXT = ' + (ByteHex $WorldGroundYExt)))
$asm = $asm.Replace('WORLD_GROUND_OCCLUDE = $00', ('WORLD_GROUND_OCCLUDE = ' + (ByteHex $RuntimeWorldGroundOccludeFlag)))
$asm = $asm.Replace('WORLD_GROUND_PLANE_CLIP = $00', ('WORLD_GROUND_PLANE_CLIP = ' + (ByteHex $WorldGroundPlaneFlag)))
$asm = $asm.Replace('WORLD_GROUND_HORIZON_ONLY = $00', ('WORLD_GROUND_HORIZON_ONLY = ' + (ByteHex $RuntimeWorldGroundHorizonOnlyFlag)))
$asm = $asm.Replace('WORLD_GROUND_WIRE_OCCLUDE = $00', ('WORLD_GROUND_WIRE_OCCLUDE = ' + (ByteHex $RuntimeWorldGroundWireOccludeFlag)))
$asm = $asm.Replace('WORLD_GROUND_WIRE_MASK_HELPERS_AVAILABLE = $00', ('WORLD_GROUND_WIRE_MASK_HELPERS_AVAILABLE = ' + (ByteHex $WorldGroundWireMaskHelpersFlag)))
$asm = $asm.Replace('WIRE_GROUND_ROLL_X_BIAS = $b2', ('WIRE_GROUND_ROLL_X_BIAS = ' + (ByteHex $WireGroundRollXBias)))
$asm = $asm.Replace('WIRE_GROUND_ROLL_Y_BIAS = $ce', ('WIRE_GROUND_ROLL_Y_BIAS = ' + (ByteHex $WireGroundRollYBias)))
$asm = $asm.Replace('WIRE_GROUND_ROLL_FOCAL_HALF = $55', ('WIRE_GROUND_ROLL_FOCAL_HALF = ' + (ByteHex $WireGroundRollFocalHalf)))
$asm = $asm.Replace('WORLD_GROUND_HORIZON_BBOX_OCCLUDE = $00', ('WORLD_GROUND_HORIZON_BBOX_OCCLUDE = ' + (ByteHex $RuntimeWorldGroundHorizonBBoxOccludeFlag)))
$asm = $asm.Replace('WORLD_GROUND_ROLL_SPAN_EDGE = $00', ('WORLD_GROUND_ROLL_SPAN_EDGE = ' + (ByteHex $RuntimeWorldGroundRollSpanEdgeFlag)))
$asm = $asm.Replace('WORLD_GROUND_VIC_POLICY_SCOPE = $00', ('WORLD_GROUND_VIC_POLICY_SCOPE = ' + (ByteHex $WorldGroundVicPolicyScopeFlag)))
$asm = $asm.Replace('; WORLD_GROUND_RENDER_CALL_PLACEHOLDER', $WorldGroundRenderCallAsm)
$asm = $asm.Replace('; WORLD_GROUND_WIRE_MASK_FINALIZE_CALL_PLACEHOLDER', $WorldGroundWireMaskFinalizeCallAsm)
$asm = $asm.Replace('; WORLD_GROUND_RENDERER_PLACEHOLDER', "")
$asm = $asm.Replace('CAMERA_INDEX = $00', ('CAMERA_INDEX = ' + (ByteHex $CameraIndex)))
$asm = $asm.Replace('CAMERA_HAS_POS = $00', ('CAMERA_HAS_POS = ' + (ByteHex $CameraHasPos)))
$asm = $asm.Replace('CAMERA_HAS_ROT = $00', ('CAMERA_HAS_ROT = ' + (ByteHex $CameraHasRot)))
$asm = $asm.Replace('CAMERA_POS_X = $00', ('CAMERA_POS_X = ' + (ByteHex $CameraX)))
$asm = $asm.Replace('CAMERA_POS_Y = $00', ('CAMERA_POS_Y = ' + (ByteHex $CameraY)))
$asm = $asm.Replace('CAMERA_POS_Z = $00', ('CAMERA_POS_Z = ' + (ByteHex $CameraZ)))
$asm = $asm.Replace('CAMERA_M00 = $40', ('CAMERA_M00 = ' + (ByteHex $CameraMatrix[0])))
$asm = $asm.Replace('CAMERA_M01 = $00', ('CAMERA_M01 = ' + (ByteHex $CameraMatrix[1])))
$asm = $asm.Replace('CAMERA_M02 = $00', ('CAMERA_M02 = ' + (ByteHex $CameraMatrix[2])))
$asm = $asm.Replace('CAMERA_M10 = $00', ('CAMERA_M10 = ' + (ByteHex $CameraMatrix[3])))
$asm = $asm.Replace('CAMERA_M11 = $40', ('CAMERA_M11 = ' + (ByteHex $CameraMatrix[4])))
$asm = $asm.Replace('CAMERA_M12 = $00', ('CAMERA_M12 = ' + (ByteHex $CameraMatrix[5])))
$asm = $asm.Replace('CAMERA_M20 = $00', ('CAMERA_M20 = ' + (ByteHex $CameraMatrix[6])))
$asm = $asm.Replace('CAMERA_M21 = $00', ('CAMERA_M21 = ' + (ByteHex $CameraMatrix[7])))
$asm = $asm.Replace('CAMERA_M22 = $40', ('CAMERA_M22 = ' + (ByteHex $CameraMatrix[8])))
$asm = $asm.Replace('CAMERA_MOVABLE = $00', ('CAMERA_MOVABLE = ' + (ByteHex $CameraMovableFlag)))
$asm = $asm.Replace('CAMERA_WALK_LITE = $00', ('CAMERA_WALK_LITE = ' + (ByteHex $CameraWalkLiteFlag)))
$asm = $asm.Replace('CAMERA_SMOOTH_DEPTH_ACTIVE = $00', ('CAMERA_SMOOTH_DEPTH_ACTIVE = ' + (ByteHex $CameraSmoothDepthActiveFlag)))
$asm = $asm.Replace('CAMERA_SMOOTH_DEPTH_PHASE_START = $00', ('CAMERA_SMOOTH_DEPTH_PHASE_START = ' + (ByteHex $CameraSmoothDepthPhaseStart)))
$asm = $asm.Replace('CAMERA_SMOOTH_DEPTH_PHASE_STEP = $00', ('CAMERA_SMOOTH_DEPTH_PHASE_STEP = ' + (ByteHex $CameraSmoothDepthPhaseStep)))
$asm = $asm.Replace('CAMERA_MODE_CYCLE = $00', ('CAMERA_MODE_CYCLE = ' + (ByteHex $CameraModeCycleFlag)))
$asm = $asm.Replace('EXPLORER_RUNTIME_MODE_INITIAL = $00', ('EXPLORER_RUNTIME_MODE_INITIAL = ' + (ByteHex $ExplorerRuntimeModeInitial)))
$asm = $asm.Replace('EXPLORER_MATRIX_FOLD = $00', ('EXPLORER_MATRIX_FOLD = ' + (ByteHex $ExplorerMatrixFoldFlag)))
$asm = $asm.Replace('CAMERA_RUNTIME_CONTROLS = $00', ('CAMERA_RUNTIME_CONTROLS = ' + (ByteHex $CameraRuntimeControlsFlag)))
$asm = $asm.Replace('CAMERA_ROLL_ACTIVE = $00', ('CAMERA_ROLL_ACTIVE = ' + (ByteHex $CameraRollActiveFlag)))
$asm = $asm.Replace('CAMERA_ROLL_CONTROL = $00', ('CAMERA_ROLL_CONTROL = ' + (ByteHex $CameraRollControlFlag)))
$asm = $asm.Replace('EXPLORER_RESET_ON_SPACE = $00', ('EXPLORER_RESET_ON_SPACE = ' + (ByteHex $ExplorerResetOnSpaceFlag)))
$asm = $asm.Replace('EXPLORER_NEAR_CLIP = $00', ('EXPLORER_NEAR_CLIP = ' + (ByteHex $ExplorerNearClipFlag)))
$asm = $asm.Replace('EXPLORER_NEAR_SKIP_CROSS = $00', ('EXPLORER_NEAR_SKIP_CROSS = ' + (ByteHex $ExplorerNearSkipCrossFlag)))
$asm = $asm.Replace('EXPLORER_NEAR_POLY = $00', ('EXPLORER_NEAR_POLY = ' + (ByteHex $ExplorerNearPolyFlag)))
$asm = $asm.Replace('MODE3_LATE_NEAR_NO_POLY = $00', ('MODE3_LATE_NEAR_NO_POLY = ' + (ByteHex $Mode3LateNearNoPolyFlag)))
$asm = $asm.Replace('EXPLORER_NEAR_FILL = $00', ('EXPLORER_NEAR_FILL = ' + (ByteHex $ExplorerNearFillFlag)))
$asm = $asm.Replace('EXPLORER_NEAR_SKIP_DEPTH = $10', ('EXPLORER_NEAR_SKIP_DEPTH = ' + (ByteHex $ExplorerNearSkipDepth)))
$asm = $asm.Replace('EXPLORER_TRAVERSAL_CULL = $00', ('EXPLORER_TRAVERSAL_CULL = ' + (ByteHex $ExplorerTraversalCullFlag)))
$asm = $asm.Replace('EXPLORER_TRAVERSAL_HYSTERESIS = $10', ('EXPLORER_TRAVERSAL_HYSTERESIS = ' + (ByteHex $ExplorerTraversalHysteresis)))
$asm = $asm.Replace('EXPLORER_SCREEN_CLIP_X = $00', ('EXPLORER_SCREEN_CLIP_X = ' + (ByteHex $ExplorerScreenClipXFlag)))
$asm = $asm.Replace('EXPLORER_SCREEN_CLIP_POLY = $00', ('EXPLORER_SCREEN_CLIP_POLY = ' + (ByteHex $ExplorerScreenClipPolyFlag)))
$asm = $asm.Replace('EXPLORER_SCREEN_RAW = $00', ('EXPLORER_SCREEN_RAW = ' + (ByteHex $ExplorerScreenRawFlag)))
$asm = $asm.Replace('EXPLORER_CAMERA_NEAR_CLIP = $00', ('EXPLORER_CAMERA_NEAR_CLIP = ' + (ByteHex $ExplorerCameraNearClipFlag)))
$asm = $asm.Replace('EXPLORER_CAMERA_X_CLIP = $00', ('EXPLORER_CAMERA_X_CLIP = ' + (ByteHex $ExplorerCameraXClipFlag)))
$asm = $asm.Replace('EXPLORER_CAMERA_X_LO = $00', ('EXPLORER_CAMERA_X_LO = ' + (ByteHex $ExplorerCameraXLo)))
$asm = $asm.Replace('EXPLORER_CAMERA_X_HI = $00', ('EXPLORER_CAMERA_X_HI = ' + (ByteHex $ExplorerCameraXHi)))
$asm = $asm.Replace('EXPLORER_CAMERA_X_EXT = $00', ('EXPLORER_CAMERA_X_EXT = ' + (ByteHex $ExplorerCameraXExt)))
$asm = $asm.Replace('EXPLORER_CAMERA_Y_LO = $00', ('EXPLORER_CAMERA_Y_LO = ' + (ByteHex $ExplorerCameraYLo)))
$asm = $asm.Replace('EXPLORER_CAMERA_Y_HI = $00', ('EXPLORER_CAMERA_Y_HI = ' + (ByteHex $ExplorerCameraYHi)))
$asm = $asm.Replace('EXPLORER_CAMERA_Y_EXT = $00', ('EXPLORER_CAMERA_Y_EXT = ' + (ByteHex $ExplorerCameraYExt)))
$asm = $asm.Replace('EXPLORER_CAMERA_Z_LO = $00', ('EXPLORER_CAMERA_Z_LO = ' + (ByteHex $ExplorerCameraZLo)))
$asm = $asm.Replace('EXPLORER_CAMERA_Z_HI = $00', ('EXPLORER_CAMERA_Z_HI = ' + (ByteHex $ExplorerCameraZHi)))
$asm = $asm.Replace('EXPLORER_CAMERA_Z_EXT = $00', ('EXPLORER_CAMERA_Z_EXT = ' + (ByteHex $ExplorerCameraZExt)))
$asm = $asm.Replace('EXPLORER_CAMERA_YAW = $00', ('EXPLORER_CAMERA_YAW = ' + (ByteHex $CameraYaw)))
$asm = $asm.Replace('EXPLORER_CAMERA_PITCH = $00', ('EXPLORER_CAMERA_PITCH = ' + (ByteHex $CameraPitch)))
$asm = $asm.Replace('EXPLORER_CAMERA_ROLL = $00', ('EXPLORER_CAMERA_ROLL = ' + (ByteHex $CameraRoll)))
$asm += "; Mesh: $MeshName
"
$asm += "; Quality: $Quality
"
$asm += "; Renderer: 3Dvibe64 active=1 planApplied=1
"
$asm += "; RendererPlan: name=$($RendererPlan.Name) ground=$($RendererPlan.GroundRenderModeName) camera=$($RendererPlan.CameraProfile) cameraFull=$($RendererPlan.CameraFull) near=$($RendererPlan.NearClipProfile) screen=$($RendererPlan.ScreenClipProfile) shade=$($RendererPlan.ShadeProfile) fill=$($RendererPlan.FillProfile) clear=$($RendererPlan.ClearProfile) modeBudget=$($RendererPlan.ModeBudgetProfile)
"
$asm += "; RenderFrameScaffold: active=1 begin=render_frame_begin worldBackground=render_world_background sceneRenderer=render_scene_renderer end=render_frame_end mode=inline-fallthrough dispatch=ground-selected-by-renderer
"
$asm += "; EngineGroundSimple: runtimeActive=$EngineGroundSimpleRuntimeFlag horizonOnlyRuntime=$EngineGroundHorizonOnlyRuntimeFlag engineFullRuntime=$GroundFullRuntimeFlag call=$($WorldGroundRenderCallAsm.Trim()) groundOccludeRuntime=$RuntimeWorldGroundOccludeFlag wireOccludeRuntime=$RuntimeWorldGroundWireOccludeFlag wireMaskHelpers=$WorldGroundWireMaskHelpersFlag wireMaskData=$WorldGroundWireMaskDataFlag wireRollRuntime=$WorldGroundWireRollRuntimeFlag rollPlaneRuntime=$RuntimeWorldGroundRollSpanEdgeFlag meshDrawnAbove=1
"
$asm += "; EngineMode3FramePrefill: runtimeActive=$EngineMode3FramePrefillRuntimeFlag fusedClearGround=$EngineMode3ClearGroundFusedFlag cellrowWriteOnChange=$EngineMode3GroundCellrowWriteOnChangeFlag fallback=$EngineMode3PrefillFallbackFlag viewport=$CameraViewportKey
"
$asm += "; EngineMode3FacePrepareOnce: runtimeActive=$EngineMode3FacePrepareOnceFlag stateCache=$EngineMode3PreparedFaceStateCacheFlag unclippedFastload=$EngineMode3UnclippedFaceFastloadFlag clipFallback=$EngineMode3ClipFallbackFlag drawRecheckStripped=$EngineMode3DrawRecheckStrippedFlag spanCache=width-height meshScope=all-scene-meshes scope=engine-mode3-only
"
$asm += "; EngineMode3DirectConvexFill: runtimeActive=$EngineMode3DirectConvexFillFlag preparedOnly=$EngineMode3DirectConvexPreparedOnlyFlag triQuad=$EngineMode3DirectConvexTriQuadFlag clipFallback=$EngineMode3DirectConvexClipFallbackFlag directFlag=$DirectConvexFanFillFlag fallback=bounds scope=engine-mode3-only
"
$asm += "; EngineMode3NativeConvexQuadFill: runtimeActive=$EngineMode3NativeConvexQuadFillFlag preparedOnly=$EngineMode3NativeConvexQuadPreparedOnlyFlag singleSpanPerScanline=$EngineMode3NativeConvexQuadSingleSpanFlag fanFallback=$EngineMode3NativeConvexQuadFanFallbackFlag trianglesUnchanged=$EngineMode3NativeConvexQuadTrianglesUnchangedFlag edgeChains=plus1-minus1 horizontalLinks=folded splitRow=merged scope=engine-mode3-prepared-quads-only
"
$asm += "; EngineMode3FastBoundsTrace: runtimeActive=$EngineMode3FastBoundsTraceFlag accumulator8=$EngineMode3FastBounds8BitFlag directLeftRight=$EngineMode3FastBoundsDirectLeftRightFlag overflowFallback16=$EngineMode3FastBoundsOverflowFallbackFlag byteSafeRule=dx-plus-dy-le-256 fallback=16bit scope=engine-mode3-bounds-only
"
$asm += "; EngineMode3SpanHotloop: runtimeActive=$EngineMode3SpanHotloopFlag directIndexed=$EngineMode3DirectIndexedSpanFlag boundsIndexedLong=$EngineMode3BoundsIndexedLongSpanFlag boundsKernelMaxDiff=5 indexedMaxDiff=31 directByteAlignedEdges=$EngineMode3DirectByteAlignedEdgeWriteFlag materialCellTransition=$EngineMode3MaterialCellTransitionFlag materialKey=y-and-fc fallback=pointer-loop scope=engine-mode3-fill-only
"
$asm += "; EngineMode3Consolidation: runtimeActive=$EngineMode3ConsolidationFlag check=$EngineMode3ConsolidationCheckFlag framePrefillCompatible=$EngineMode3FramePrefillCompatibleFlag universalPathsOnly=$EngineMode3UniversalPathsOnlyFlag compactFaceQueue=$EngineMode3CompactFaceQueueFlag normalViewport=$EngineMode3NormalViewportSupportedFlag smallViewport=$EngineMode3SmallViewportSupportedFlag multiObject=$EngineMode3MultiObjectSupportedFlag fallbacksPreserved=$EngineMode3FallbacksPreservedFlag stack=frame-prefill-when-ground,face-prepare-once,direct-convex,fast-bounds,span-hotloop,static-shading scope=engine-mode3-only
"
$asm += "; EngineMode3StableGroundCellLayout043a: runtimeActive=$EngineMode3StableGroundCellLayoutFlag auto=$EngineMode3StableGroundCellLayoutAutoFlag multiObject=$EngineMode3StableGroundMultiObjectFlag objectCount=$SceneObjectCount sharedRamp=$EngineMode3StableGroundSharedRampFlag groundSlot01=$EngineMode3StableGroundSlot01Flag objectSlot10=$EngineMode3StableGroundObjectSlot10Flag objectSlot11=$EngineMode3StableGroundObjectSlot11Flag groundColorRamWriteStripped=$EngineMode3StableGroundColorRamWriteStrippedFlag doubleBufferSafe=$EngineMode3StableGroundDoubleBufferSafeFlag materialDark=$EngineMode3DemoMaterialDarkColor materialHigh=$EngineMode3DemoMaterialHighColor materialHighlight=$EngineMode3DemoMaterialHighlightColor slotMap=$EngineMode3DemoSlotMapText eligibility=$EngineMode3StableGroundEligibilityText scope=engine-mode3-compatible-ground-scenes
"
$asm += "; EngineMode3AdaptiveCellPolicy043b: runtimeActive=$EngineMode3AdaptiveCellPolicyFlag policy=$EngineMode3AdaptivePolicyText sharedExact=$EngineMode3AdaptiveSharedRampExactFlag screenPair=$EngineMode3AdaptiveScreenPairLayoutFlag rampCount=$EngineMode3AdaptiveRampCount multiRamp=$EngineMode3AdaptiveMultiRampFlag thirdColorRamps=$EngineMode3AdaptiveThirdColorRampCount highlightFoldHigh=$EngineMode3AdaptiveHighlightFoldFlag faceSolidColor=$EngineMode3AdaptiveFaceSolidColorFlag groundSlot11=$EngineMode3AdaptiveGroundSlot11Flag objectSlots01and10=$EngineMode3AdaptiveObjectSlots0110Flag colorRamFixedGround=$EngineMode3AdaptiveColorRamFixedGroundFlag doubleBufferSafe=$EngineMode3AdaptiveDoubleBufferSafeFlag runtimeMaterialSafe=$EngineMode3AdaptiveRuntimeMaterialSafeFlag runtimeMaterialDynamic=$([int]$adaptiveRuntimeMaterialDynamic) userCellConflict=$EngineMode3AdaptiveUserCellConflictFlag slotMap=$EngineMode3AdaptiveSlotMapText eligibility=$EngineMode3AdaptiveEligibilityText conflictPolicy=depth-order-last-face-owns-cell scope=engine-mode3-ground-static-shading
"
$asm += "; EngineMode3DemoCellColorStability: active=$EngineMode3DemoCellColorStabilityFlag threeColor=$EngineMode3DemoThreeColorLayoutFlag staticShading=$EngineMode3DemoStaticShadingRestoredFlag shadeVariants=$EngineMode3DemoStaticShadeVariantCount noFaceSolidOverride=$EngineMode3DemoNoFaceSolidOverrideFlag shadeFamilyReencoded=$EngineMode3DemoShadeFamilyReencodedFlag materialDark=$EngineMode3DemoMaterialDarkColor materialHigh=$EngineMode3DemoMaterialHighColor materialHighlight=$EngineMode3DemoMaterialHighlightColor slotMap=$EngineMode3DemoSlotMapText groundSlot01=$EngineMode3DemoGroundSlot01PreservedFlag objectSlot10=$EngineMode3DemoObjectSlot10Flag objectSlot11=$EngineMode3DemoObjectSlot11Flag objectSlot11Color=$EngineMode3DemoObjectSlot11Color vicPolicyOff=$EngineMode3DemoVicPolicyOffFlag groundBitmap01=$EngineMode3DemoGroundBitmapSlot01Flag groundColorRamWriteStripped=$EngineMode3DemoGroundColorRamWriteStrippedFlag doubleBufferColorStable=$EngineMode3DemoDoubleBufferColorStableFlag scope=strict-check-over-universal-layout
"
$asm += "; EngineWireContract: runtimeActive=$EngineWireModeRuntimeFlag engineMode=$GraphicsModeNumber video=bitmap-multicolor-lowres vicMulticolor=1 singlePixel=0 requestedVic=$RequestedVicColorPolicyKey requestedVicEnable=$RequestedVicColorPolicyEnableFlag requestedVicActive=$RequestedVicColorPolicyActiveFlag effectiveVicEnable=$VicColorPolicyEffectiveEnableFlag effectiveVicActive=$VicColorPolicyEffectiveActiveFlag forcedVicOff=$EngineWireVicPolicyForcedOffFlag materialWirePath=$EngineWireMaterialColorRuntimeFlag wireObjectMaterialPath=$EngineWireObjectMaterialPathRuntimeFlag materialCells=$EngineWireMaterialCellsRuntimeFlag groundHorizonDarkGrey=$GroundHorizonDarkGreyRuntimeFlag groundHorizonScreenByte=bb groundHorizonColorRam=0b horizonMaterialIsolated=$EngineGroundHorizonMaterialIsolatedFlag horizonMaterialRestore=$EngineGroundHorizonMaterialRestoreFlag meshWireMaterialReloadAfterGround=$EngineMeshWireMaterialReloadAfterGroundFlag cameraThroughMesh=$EngineWireCameraThroughMeshFlag nearClipRelaxed=$EngineWireNearClipRelaxedFlag objectRejectRelaxed=$EngineWireObjectRejectRelaxedFlag edgeClipTolerant=$EngineWireEdgeClipTolerantFlag mode2MaskNearTolerant=$EngineMode2FaceMaskNearTolerantFlag engineModeTerminology=1
"
$wireSlot01FamilyName = if ($WireTwoColorSlot01Family -ne 255) { [string]$MaterialFamilies[$WireTwoColorSlot01Family].name } else { "none" }
$wireSlot10FamilyName = if ($WireTwoColorSlot10Family -ne 255) { [string]$MaterialFamilies[$WireTwoColorSlot10Family].name } else { "none" }
$asm += "; WireTwoColorMultimaterial: requested=$WireTwoColorMultimaterialRequestedFlag active=$WireTwoColorMultimaterialFlag mode1=$WireTwoColorMode1Flag mode2=$WireTwoColorMode2Flag slot01Family=$wireSlot01FamilyName slot01Color=$WireTwoColorSlot01Color slot01Pattern=55 slot10Family=$wireSlot10FamilyName slot10Color=$WireTwoColorSlot10Color slot10Pattern=aa screenByte=$('{0:x2}' -f $WireTwoColorScreenByte) fixedColorRam=$('{0:x2}' -f $WireTwoColorFixedColorRam) colorRamDifferentiates=0 faceCount=$FaceCount slot01Faces=$WireTwoColorSlot01FaceCount slot10Faces=$WireTwoColorSlot10FaceCount mode1Edges=$WireTwoColorMode1EdgeCount mode1CrossMaterialEdges=$WireTwoColorMode1CrossMaterialEdgeCount mode1Owner=first-source-adjacent-face mode2FaceEdgeRefs=$WireTwoColorMode2FaceEdgeReferenceCount mode2UniqueEdges=$WireTwoColorMode2UniqueEdgeCount mode2Redraws=$WireTwoColorMode2EdgeRedrawCount mode2SameBucketTieStable=$WireTwoColorSameBucketTieBreakStableFlag mode2SameBucketOrder=descending-face-index mode2SameBucketWinner=lowest-source-face-index runtimeOwnerBuffers=0
"
$asm += "; EngineWireSpeedPass1: runtimeActive=$EngineWireSpeedPass1Flag dirtyClear=$EngineWireDirtyClearFlag horizonDirect=$EngineWireHorizonDirectDrawFlag solidFeaturesStripped=$EngineWireSolidFeaturesStrippedFlag mode2MaskDirtyTrack=$EngineMode2FaceMaskRuntimeFlag scope=engine-mode1-2-only visualContract=unchanged
"
$asm += "; EngineWireSpeedPass2: runtimeActive=$EngineWireSpeedPass2Flag cellWriteSkipSame=$EngineWireCellWriteSkipSameFlag materialCacheResetFrame=$EngineWireMaterialCacheResetFrameFlag mode2MaskColorWritesStripped=$EngineMode2MaskColorWritesStrippedFlag scope=engine-mode1-2-only visualContract=unchanged
"
$asm += "; EngineWireSpeedPass3Redo: runtimeActive=$EngineWireSpeedPass3Flag lightShadingStripped=$EngineWireLightShadingStrippedFlag mode1FacePassStripped=$EngineMode1FacePassStrippedFlag mode1EdgeTableDirect=$EngineMode1EdgeTableDirectFlag scope=engine-mode1-2-only pass3Conservative=1 visualContract=unchanged
"
if ($SceneGraphicIncludeFlag -ne 0) {
 $asm += "`n; Scene graphic include: $SceneGraphicIncludePath`n"
 $asm += $SceneGraphicIncludeText
 $asm += "`n; End scene graphic include`n"
}
$asm += "; EngineWireEdgeMaterialContext: runtimeActive=$EngineWireEdgeMaterialContextFlag invalidateOnMaterialChange=$EngineWireMaterialCacheInvalidateOnChangeFlag perPixelMaterialCompareStripped=$EngineWireMaterialCompareStrippedFlag cacheKey=buffer-row-cell scope=engine-mode1-2-only fallback=pass2-material-aware-cache visualContract=unchanged
"
$asm += "; EngineMode1FacePassStrip020Fix1: runtimeActive=$EngineMode1FacePassStrippedFlag generatedFaceEdgesOnly=$EngineMode1FaceEdgeListOnlyFlag wireFaceEdgeRuntime=$WireFaceEdgeFlag sharedSupportRoutinesRetained=$FaceRenderEnableFlag wireEdgeCount=$PolyEdgeCount noNewAsmRoutines=1 scope=engine-mode1-only
"
$asm += "; EngineMode1WireFastPlot: runtimeActive=$EngineMode1WireFastPlotFlag inScreenFastPath=$EngineMode1WireInScreenFastPathFlag clipFallback=$EngineMode1WireClipFallbackFlag fastPath=raw-endpoints-inside directDraw=draw-wire-edge fallback=clip-wire-edge-screen-plus-guard scope=engine-mode1-only visualContract=unchanged
"
$asm += "; EngineMode1UniversalEdgeTraversal: runtimeActive=$EngineMode1UniversalEdgeTraversalFlag projdoneDirectTest=$EngineMode1ProjdoneDirectTestFlag vertexDrawableFallback=$EngineMode1VertexDrawableFallbackFlag meshScope=all-build-time-edge-lists cameraScope=movable-camera fallback=fixed-camera-and-non-engine-mode1 visualContract=unchanged
"
$asm += "; EngineMode1WireRasterHotloop: runtimeActive=$EngineMode1WireRasterHotloopFlag pointDirectEntry=$EngineMode1WirePointDirectEntryFlag pointBoundsStripped=$EngineMode1WirePointBoundsStrippedFlag materialCellRowCache=$EngineMode1MaterialCellRowCacheFlag materialStartbyteReuse=$EngineMode1MaterialStartbyteReuseFlag meshScope=all-edge-lists endpointContract=fastpath-or-clipped scope=engine-mode1-only visualContract=unchanged
"
$asm += "; EngineMode2WireRasterHotloop: runtimeActive=$EngineMode2WireRasterHotloopFlag pointBoundsStripped=$EngineMode2WirePointBoundsStrippedFlag materialCellRowCache=$EngineMode2MaterialCellRowCacheFlag materialStartbyteReuse=$EngineMode2MaterialStartbyteReuseFlag faceEdgeDirectDraw=$EngineMode2WireFaceEdgeDirectDrawFlag clipGuardFallback=$EngineMode2WireClipGuardFallbackFlag meshScope=all-visible-face-edge-lists endpointContract=inside-normal-or-guarded-clipped scope=engine-mode2-only horizonRowMaskPreserved=$EngineMode2HorizonRowMaskRuntimeFlag visualContract=unchanged
"
$asm += "; EngineWireScanlineRunRasterizer029Fix1: runtimeActive=$EngineWireScanlineRunRasterizerFlag mode1=$EngineMode1ScanlineRunRuntimeFlag mode2=$EngineMode2ScanlineRunRuntimeFlag shallowOnly=$EngineWireScanlineRunShallowOnlyFlag pointFallback=$EngineWireScanlineRunPointFallbackFlag endpointStatePreserved=$EngineWireScanlineRunEndpointStatePreservedFlag runWriter=pwh-span-direct maskTraceFallback=per-point meshScope=all-meshes scope=engine-mode1-2-only visualContract=unchanged
"
$asm += "; EngineWireSteepLineFastpath: runtimeActive=$EngineWireSteepLineFastpathFlag mode1=$EngineMode1SteepLineRuntimeFlag mode2=$EngineMode2SteepLineRuntimeFlag ratio2to1=$EngineWireSteepRatio2To1Flag verticalRunWriter=$EngineWireVerticalRunWriterFlag pointFallback=$EngineWireSteepPointFallbackFlag endpointStatePreserved=$EngineWireSteepEndpointStatePreservedFlag maskTraceFallback=per-point meshScope=all-meshes scope=engine-mode1-2-only visualContract=unchanged
"
$asm += "; EngineWireCellTransitionUpdates: runtimeActive=$EngineWireCellTransitionUpdatesFlag mode1=$EngineMode1CellTransitionRuntimeFlag mode2=$EngineMode2CellTransitionRuntimeFlag dirtySameByteSkip=$EngineWireDirtySameByteSkipFlag materialCallOnCellChange=$EngineWireMaterialCallOnCellChangeFlag materialDirectWriteEntry=$EngineWireMaterialDirectWriteEntryFlag transitionCacheResetFrame=$EngineWireTransitionCacheResetFrameFlag pointPathOnly=1 runWritersPreserved=1 meshScope=all-meshes scope=engine-mode1-2-only visualContract=unchanged
"
$asm += "; EngineWire8BitBresenham: runtimeActive=$EngineWire8BitBresenhamFlag mode1=$EngineMode1Bresenham8RuntimeFlag mode2=$EngineMode2Bresenham8RuntimeFlag intermediateSlopes=$EngineWire8BitIntermediateSlopesFlag errorAccumulator8bit=$EngineWire8BitErrorAccumulatorFlag old16bitFallback=$EngineWire16BitTraceFallbackFlag slopeContract=dx-lt-dy-lt-2dx maskTraceFallback=16bit meshScope=all-meshes scope=engine-mode1-2-only visualContract=pixel-identical
"
$asm += "; EngineWireRasterConsolidation: runtimeActive=$EngineWireRasterConsolidationFlag mode1=$EngineMode1RasterConsolidationRuntimeFlag mode2=$EngineMode2RasterConsolidationRuntimeFlag singleSlopeDispatch=$EngineWireSingleSlopeDispatchFlag singleTraceGate=$EngineWireSingleTraceGateFlag traceFallback=$EngineWireTraceFallbackFlag algorithms=scanline-run,vertical-run,bresenham8 maskTraceFallback=16bit meshScope=all-meshes scope=engine-mode1-2-only visualContract=unchanged
"
$asm += "; EngineMode2HorizonRowMask: candidate=$EngineMode2HorizonRowMaskCandidateFlag runtimeActive=$EngineMode2HorizonRowMaskRuntimeFlag rowSource=world-ground-saved-horizon boundsInit=single-row clearRows=1 fallback=full-face-when-runtime-marker-off scope=engine-mode2-only
"
$asm += "; EngineWireMaterialIsolation: runtimeActive=$EngineWireModeRuntimeFlag horizonMaterialIsolated=$EngineGroundHorizonMaterialIsolatedFlag horizonMaterialRestore=$EngineGroundHorizonMaterialRestoreFlag meshWireMaterialReloadAfterGround=$EngineMeshWireMaterialReloadAfterGroundFlag wireObjectMaterial=$WireObjectMaterialFlag expectedHorizon=dark-grey expectedMesh=object-material
"
$asm += "; EngineWireCameraThroughMesh: runtimeActive=$EngineWireCameraThroughMeshFlag nearClipRelaxed=$EngineWireNearClipRelaxedFlag objectRejectRelaxed=$EngineWireObjectRejectRelaxedFlag edgeClipTolerant=$EngineWireEdgeClipTolerantFlag mode2MaskNearTolerant=$EngineMode2FaceMaskNearTolerantFlag depthInvalidVerticesProjected=near-plane markedProjected=1 scope=engine-mode1-2-only
"
$asm += "; EngineMode2HiddenWireContract: runtimeActive=$EngineMode2HiddenWireRuntimeFlag wire=$EngineMode2WireRenderRuntimeFlag hiddenWire=$EngineMode2HiddenWireFlag polyFill=$EngineMode2PolyFillRuntimeFlag vicRuntime=$EngineMode2VicPolicyRuntimeFlag faceMaskContract=$EngineMode2FaceMaskContractFlag faceMaskRuntime=$EngineMode2FaceMaskRuntimeFlag horizonBehindFaceTarget=$EngineMode2HorizonBehindFaceTargetFlag horizonBehindFaceRuntime=$EngineMode2HorizonBehindFaceRuntimeFlag horizonRowMaskCandidate=$EngineMode2HorizonRowMaskCandidateFlag horizonRowMaskRuntime=$EngineMode2HorizonRowMaskRuntimeFlag maskImplementation=horizon-row-runtime-with-compile-time-full-face-fallback
"
$asm += "; CameraProfile: mode=$EffectiveCameraMode runtimeActive=$EngineCameraProfileRuntimeFlag walkLite=$EngineCameraWalkLiteRuntimeFlag walkFull=$CameraFullRuntimeFlag roll=$EngineCameraRollRuntimeFlag pitch=$EngineCameraWalkLitePitchRuntimeFlag
"
$asm += "; EngineCameraViewport: configurable=$EngineCameraViewportConfigurableFlag allEngineModes=$EngineCameraViewportAllModesFlag profile=$CameraViewportKey small=$EngineCameraViewportSmallFlag logical=${CameraViewportWidth}x${CameraViewportHeight} physical=${CameraViewportPhysicalWidth}x${CameraViewportPhysicalHeight} origin=[$CameraViewportOriginX,$CameraViewportOriginY] focal=$CameraViewportFocal projectionScaled=$EngineCameraViewportProjectionScaledFlag clearLimited=$EngineCameraViewportClearLimitedFlag groundLimited=$EngineCameraViewportGroundLimitedFlag cellOriginX=$CameraViewportCellOriginX cellWidth=$CameraViewportCellWidth scope=graphics-modes-1-5 singleRenderer=1
"
$asm += "; EngineMode1WirePure: runtimeActive=$EngineMode1WirePureRuntimeFlag wire=$EngineMode1WireRenderRuntimeFlag wireFaceEdge=$EngineMode1WireFaceEdgeRuntimeFlag wirePure=$WirePureFlag hiddenWire=$EngineMode1HiddenWireRuntimeFlag polyFill=$EngineMode1PolyFillRuntimeFlag wireDepth=$EngineMode1WireDepthSortRuntimeFlag wireObjectSort=$EngineMode1WireObjectSortRuntimeFlag vicRuntime=$EngineMode1VicPolicyRuntimeFlag requestedVic=$RequestedVicColorPolicyKey requestedVicEnable=$RequestedVicColorPolicyEnableFlag effectiveVicEnable=$VicColorPolicyEffectiveEnableFlag forcedVicOff=$EngineWireVicPolicyForcedOffFlag groundSimple=$EngineGroundSimpleRuntimeFlag groundHorizonOnly=$EngineGroundHorizonOnlyRuntimeFlag groundOccludeRuntime=$EngineMode1GroundOcclusionRuntimeFlag cameraEngine=$EngineCameraProfileRuntimeFlag edgeDepthSortDisabled=1
"
$asm += "; Mode1ObjectDepthSort: active=$Mode1ObjectDepthSortFlag renderableMeshes=$Mode1RenderableMeshCount key=camera-space-origin-z order=far-to-near ties=json-order complexity=quadratic scope=engine-mode1-multi-object-only
"
$asm += "; Mode2FaceBucketPipeline: active=$Mode2FaceBucketPipelineFlag stages=collect-load-clip-screen-winding-bucket-mask-edges classifier=shoelace-signed24 scope=engine-mode2-only
"
$asm += "; GraphicsMode: $GraphicsModeNumber source=$GraphicsMode runtimeSwitch=$RuntimeGraphicsModeSwitchFlag wire=$WireRenderFlag wireOverlay=$WireOverlayFlag wireDepth=$WireDepthSortFlag wireDepthEntries=$WireDepthEntryCount wireObjectSort=$WireObjectSortFlag wireObjectMaterial=$WireObjectMaterialFlag hiddenWire=$HiddenWireFlag wireFaceEdge=$WireFaceEdgeFlag polyFill=$PolyFillFlag polygonOutline=$Mode5PolygonOutlineFlag outlineColor=world-background lazyBounds=$LazyConvexBoundsFlag directEdgeSpans=$DirectConvexEdgeSpansFlag spanKernel=$SpanKernelFillFlag indexedOffsetSpan=$IndexedOffsetSpanFillFlag fanFill=$DirectConvexFanFillFlag fastFillBoundsTrace=$FastFillBoundsTraceFlag engineMode4FastBoundsTrace=$EngineMode4FastBoundsTraceFlag faceRender=$FaceRenderEnableFlag wirePure=$WirePureFlag staticShade=$StaticShadeCacheFlag staticDirect=$StaticShadeDirectFlag fullDynamicShade=$FullDynamicShadeFlag frameFaceFillCache=$FrameFaceFillCacheFlag objectLightCache=$Mode4ObjectLightCacheFlag objectLightCacheModes=4-5
"
$asm += "; ClearMode: $ClearMode
"
$asm += "; Projection: $Projection reference=$ReferenceProjectionFlag extendedTable=$ExtendedTableProjectionFlag explorerTable=$ExplorerTableProjectionFlag explorerMatrixFold=$ExplorerMatrixFoldFlag motionZStart256=$MotionZStart256 motionZStep256=$MotionZStep256 motionZStartOnReturn=$MotionZStartOnReturnFlag motionZStartOnZero=$MotionZStartOnZeroFlag sceneObjects=$SceneObjectCount
"
$asm += "; SceneAxes: input=$SceneAxisConvention internal=engine-y-up viewZ=depth
"
$asm += "; ObjectModel: contract=$ObjectModelContractVersion worldObject=$SceneWorldObjectPresentFlag cameraObject=$SceneCameraObjectPresentFlag lightObjects=$SceneLightCount primaryLightIndex=$ScenePrimaryLightIndex extraLightsIgnored=$SceneExtraLightIgnoredCount meshObjects=$SceneMeshObjectCount solidMeshObjects=$SceneSolidMeshObjectCount wireMeshObjects=$SceneWireMeshObjectCount singleMaterialMeshObjects=$SceneSingleMaterialMeshObjectCount multimaterialMeshObjects=$SceneMultimaterialMeshObjectCount objectSpaceAlignedWorld=$ObjectSpaceAlignedWorldFlag worldSpaceZUp=$WorldSpaceZUpFlag publicWorld=world-z-up internal=engine-y-up markers=contract operational=runtime-consumed
"
$asm += "; MeshProfiles: objectKind=mesh sourceSharingRuntime=$MeshSourceSharingRuntimeFlag instanceExpansionMode=$MeshInstanceExpansionModeFlag solidProfile=1 wireProfile=1 wireAliasType=wire normalizedAsMesh=1 meshIsWireTable=$($WireMeshCount -gt 0) materialSingleProfile=1 multimaterialProfile=1 multimaterialAlias=geometry:multimaterial normalizedMultimaterialAsSolid=1 faceMaterialTableActive=$SceneFaceMaterialTableActiveFlag faceSolidColorTableRequested=$SceneFaceSolidColorTableRequestedFlag
"
$WorldGroundRasterMode = if ($WorldGroundEnabledCount -gt 0) {
 if ($EngineGroundHorizonOnlyRuntimeFlag -ne 0) {
 "engine-horizon-line"
 } elseif ($EngineGroundSimpleRuntimeFlag -ne 0) {
 "engine-simple-prefill"
 } elseif ($RuntimeWorldGroundHorizonOnlyFlag -ne 0) {
 if ($CameraRollActiveFlag -ne 0) { "procedural-horizon-line-roll" } else { "procedural-horizon-line" }
 } elseif ($CameraRollActiveFlag -ne 0) {
 if ($RuntimeWorldGroundRollSpanEdgeFlag -ne 0) { "procedural-horizon-semiplane-span-edge" } else { "procedural-horizon-semiplane" }
 } else {
 "procedural-horizon-fill"
 }
} else {
 "none"
}
$asm += "; World: backgroundColor=$WorldBackgroundColor grounds=$WorldGroundCount enabledGrounds=$WorldGroundEnabledCount groundRaster=$WorldGroundRasterMode groundOcclude=$RuntimeWorldGroundOccludeFlag groundHorizonOnly=$RuntimeWorldGroundHorizonOnlyFlag groundRollSpanEdge=$RuntimeWorldGroundRollSpanEdgeFlag groundVicPolicyScope=procedural-prefill reservedGroundFields=material,reflectivity,extent,halfExtent
"
$asm += "; FaceRenderMode: $FaceRenderMode forceFaceRender=$ForceFaceRenderFlag conservativeCull=$ConservativeFaceCullFlag negArea=$ConservativeCullNegArea edgeNegArea=$ConservativeEdgeCullNegArea sliverCull=$ConservativeSliverCullFlag sliver=thin$ConservativeSliverThinSpan/long$ConservativeSliverLongSpan
"
$asm += "; FaceCullProfile: $FaceCullProfileKey stable=$StableFaceCullProfileFlag cameraSpaceSupport=$CameraSpaceFaceCullSupportFlag strategy=screen-safe-plus-camera-space-edge-band source=original-face cameraSpaceNormal=mode45-shading screenAreaBand=64 edgeEpsilonWU=1
"
$asm += "; CameraPlaneCull: sceneObjects=$SceneObjectCount faceMinDepth=8 sceneRenderMinY=0 fpsOverlay=$FpsOverlayEnableFlag fpsCounter=$FpsCounterEnableFlag objectStatePreserved=$($SceneObjectCount -gt 0)
"
$asm += "; Controls: fpsF=$FpsKeyToggleEnableFlag fpsStart=$FpsOverlayOnStartFlag fpsCounterOnly=$FpsCounterOnlyFlag space=$ControlSpaceFlag return=$ControlReturnFlag rotation=$ControlRotationFlag light=$ControlLightFlag lowres=$ControlLowresFlag lowresTrace=$($LowresTraceFlag -ne 0) material=$ControlMaterialFlag reflectivity=$ControlReflectivityFlag randomMaterial=$RandomMaterialCycleFlag randomMaterialTicks=$RandomMaterialCycleTicks
"
$asm += "; MaterialCellSpanCache: $MaterialCellSpanCacheFlag activeOnlyMaterial=$FaceMaterialActiveOnlyFlag activeOnlyReflectivity=$FaceReflectivityActiveOnlyFlag faceSolidColor=$FaceSolidColorFlag requested=$FaceSolidColorRequestedFlag wireEdgeSolidColor=$WireEdgeSolidColorFlag requested=$WireEdgeSolidColorRequestedFlag
"
$asm += "; VicColorPolicy: mode=$VicColorPolicyKey fallback=$VicColorFallbackKey fallbackMode=$VicColorFallbackMode enable=$VicColorPolicyEnableFlag active=$VicColorPolicyActiveFlag overlay=$VicColorPolicyOverlayFlag materialSpanCache=$MaterialCellSpanCacheFlag cells=40x25 signature=screen+color counters=total/fill/wire
"
$asm += "; FpsSystem: counter=$FpsCounterEnableFlag counterOnly=$FpsCounterOnlyFlag overlay=$FpsOverlayEnableFlag keyF=$FpsKeyToggleEnableFlag onStart=$FpsOverlayOnStartFlag memoryContract=$FpsOverlayMemoryContractFlag underIoLayout=$FpsOverlayUnderIoLayoutFlag textBase=$(WordHex $FpsTextBase) textEnd=$(WordHex ($FpsTextBase + $FpsTextReservedSize - 1)) textUnderIo=$FpsTextUnderIoFlag textClearCells=$FpsTextClearCells charsetBase=$(WordHex $FpsCharsetBase) charsetEnd=$(WordHex ($FpsCharsetBase + $FpsCharsetReservedSize - 1)) charsetUnderIo=$FpsCharsetUnderIoFlag textD018=$(ByteHex $FpsTextD018) textRelocatedD800=$FpsTextRelocationD800Flag charsetRelocatedD000=$FpsCharsetRelocationD000Flag engineRelocated=$FpsCharsetRelocationFlag engineMode3Relocated=$Mode3FpsCharsetRelocationFlag lastValueLabel=fps_last_value lastTenthsLabel=fps_last_tenths
"
$asm += "; InitialAngles: [$InitialAngleX,$InitialAngleY,$InitialAngleZ] staticPose=$StaticPoseFlag
"
$asm += "; Camera: source=$CameraSource index=$CameraIndex name=$CameraName position=[$CameraX,$CameraY,$CameraZ] rotation=[$CameraPitch,$CameraYaw,$CameraRoll] mode=$EffectiveCameraMode viewport=$CameraViewportKey movable=$CameraMovableFlag walkLite=$CameraWalkLiteFlag walkFull=$CameraWalkFullFlag roll=$CameraRollActiveFlag nearClip=$ExplorerNearClipFlag screenClip=$ExplorerScreenClipMode
"
$asm += "; WalkCameraIdleContract: inputDriven=1 startsStationary=1 poseWritesRequireInput=1 objectAnimationIndependent=1 runtimeControls=$CameraRuntimeControlsFlag
"
$asm += "; CameraController: source=engine keys=WASD,Q/E,cursors rollN/M=$($CameraRollControlFlag -ne 0) active=$($CameraRuntimeControlsFlag -ne 0) rollActive=$($CameraRollActiveFlag -ne 0) noRuntimeControls=$($NoCameraRuntimeControls.IsPresent)
"
if ($SolidSubpixelYMobileNativeFlag -ne 0) {
 $asm += "; MobileYQ2: active=1 viewport=$CameraViewportKey source=camera-space-s16 division=mobile-perspective quotientBits=2 centerQ2=$YQ2ViewportCenter clampQ2=0..$YQ2ViewportMax rows=0..$YQ2ViewportRowMax x=LegacyDirect syLegacy=preserved faceGate=original-nonclipped-only nearSynthetic=0 screenSynthetic=0 clipBuffers=unchanged builder=DEV9-XYQ2
"
}
$asm += "; CameraTiming: keyScan=main-after-wait-before-consume advance=advance-sim-tick prepareView=main-after-consume events=main-loop-once irq=counter-only
"
$asm += "; DynamicLight: $DynamicLightFlag source=$EffectiveLightSource phases=$LightPhaseCount tickDiv=$LightTickDiv orbit=$LightOrbit intensity=$EffectiveLightIntensity pulse=$EffectiveLightPulse pulseOnSpace=$($LightPulseOnSpace.IsPresent) staticPhase=$LightStaticPhase material=$MaterialFamily reflectivity=$Reflectivity
"
$asm += "; StaticShade: $StaticShadeCacheFlag source=$StaticShadeLightSource light=[$($StaticShadeLightPosition[0]),$($StaticShadeLightPosition[1]),$($StaticShadeLightPosition[2])] intensity=$EffectiveLightIntensity
"
$asm += "; HasTriangleFaces: $HasTriangleFacesFlag
"
$asm += "; Effective MinFaceArea: $MinFaceArea
"
$asm += "; Effective ScreenMinSpan: $ScreenMinSpan
"
$asm += "; Effective PatternMinSpan: $PatternMinSpan
"
$asm += "; AutoCycleFrames: $AutoCycleFrames
"
$asm += "; Runtime mesh records:
"
for ($i = 0; $i -lt $MeshRecords.Count; $i++) {
 $record = $MeshRecords[$i]
 $edgeCount = [int]$meshEndEdge[$i] - [int]$meshFirstEdge[$i]
 $recordType = if ([bool]$record.IsWire) {
 "mesh geometry=wire render=wire color=$($record.WireColor)"
 } else {
 "mesh geometry=solid render=normal"
 }
 $asm += "; ${i}: $($record.Name) type=$recordType vertices=$($record.VertexCount) faces=$($record.FaceCount) drawEdges=$edgeCount
"
}
$asm += "; Wire draw edge records: total=$PolyEdgeCount emitted=$EmittedWireEdgeCount wireMeshes=$WireMeshCount pendingWireRenderer=$($WireRenderFlag -eq 0)
"
if ($SceneObjectCount -gt 0) {
 $asm += "; Scene objects:
"
 for ($i = 0; $i -lt $SceneObjects.Count; $i++) {
 $object = $SceneObjects[$i]
 $materialName = if ([int]$object.Material -eq 255) { "active" } else { [string]$MaterialFamilies[[int]$object.Material].name }
 $reflectivityName = if ([int]$object.Reflectivity -eq 255) { "active" } else { [string]((@($MaterialReflectivityLevels) | Where-Object { ([int]$_.index * $MaterialCount) -eq [int]$object.Reflectivity } | Select-Object -First 1).name) }
 $objectRecordForComment = $MeshRecords[[int]$object.MeshIndex]
 $objectGeometryForComment = if ([bool]$objectRecordForComment.IsWire) { "wire" } else { "solid" }
 $asm += "; ${i}: $($object.Name) kind=mesh geometry=$objectGeometryForComment mesh=$($object.MeshIndex) visible=$($object.Visible) scale64=$($object.Scale) material=$materialName reflectivity=$reflectivityName
"
 }
}
if ($SceneTimelineFlag -ne 0 -and $HighBasicV2LayoutFlag -ne 0) {
 $asm += "scene_feature_static_return = *`n* = `$5300`n"
}
$asm += Add-Bytes "mesh_vfirst" ([int[]]$meshFirstVertex)
$asm += Add-Bytes "mesh_vend" ([int[]]$meshEndVertex)
$asm += Add-Bytes "mesh_face_first" ([int[]]$meshFirstFace)
$asm += Add-Bytes "mesh_face_end" ([int[]]$meshEndFace)
if ($WireMeshCount -gt 0) {
 $asm += Add-Bytes "mesh_is_wire" ([int[]]$meshIsWire)
}
if ($EmitWireEdgeListFlag -ne 0) {
 $asm += Add-Bytes "mesh_edge_first" ([int[]]$meshFirstEdge)
 $asm += Add-Bytes "mesh_edge_end" ([int[]]$meshEndEdge)
 $asm += Add-Bytes "edge0" ([int[]]$polyEdgeA)
 $asm += Add-Bytes "edge1" ([int[]]$polyEdgeB)
 if ($WireTwoColorMode1Flag -ne 0) {
 $asm += Add-Bytes "wire_edge_slot" ([int[]]$wireEdgeSlot)
 }
 if ($WireEdgeSolidColorFlag -ne 0) {
 $asm += Add-Bytes "wire_edge_solid_color" ([int[]]$polyEdgeSolidColor)
 }
}
if ($WireFaceEdgeFlag -ne 0) {
 $asm += Add-Bytes "face_edge0" ([int[]]$faceEdge0Data)
 $asm += Add-Bytes "face_edge1" ([int[]]$faceEdge1Data)
 $asm += Add-Bytes "face_edge2" ([int[]]$faceEdge2Data)
 $asm += Add-Bytes "face_edge3" ([int[]]$faceEdge3Data)
 if ($HiddenWireFlag -ne 0 -and $WireDepthSortFlag -ne 0 -and $WireMeshCount -gt 0) {
 $asm += Add-Bytes "face_mesh_is_wire" ([int[]]$faceMeshIsWireData)
 }
}
if ($SceneObjectCount -gt 0) {
 $asm += Add-Bytes "object_mesh" ([int[]]$objectMeshIndex)
 if ($MeshSourceSharingRuntimeFlag -ne 0) {
  $asm += Add-Bytes "object_runtime_vfirst" ([int[]]$objectRuntimeVFirst)
  $asm += Add-Bytes "object_runtime_vend" ([int[]]$objectRuntimeVEnd)
  $asm += Add-Bytes "object_runtime_face_first" ([int[]]$objectRuntimeFaceFirst)
  $asm += Add-Bytes "object_runtime_face_end" ([int[]]$objectRuntimeFaceEnd)
  $asm += Add-Bytes "object_source_vertex_delta" ([int[]]$objectSourceVertexDelta)
  $asm += Add-Bytes "bucket_face_instance" ([int[]]$bucketFaceInstance)
  $asm += Add-Bytes "bucket_face_local" ([int[]]$bucketFaceLocal)
 }
 if ($SceneInstanceOverrideFlag -ne 0) {
 $asm += Add-Bytes "object_material_override" ([int[]]$objectMaterialOverride)
 $asm += Add-Bytes "object_reflectivity_override" ([int[]]$objectReflectivityOverride)
 $asm += Add-Bytes "object_color_override" ([int[]]$objectColorOverride)
 }
 if ($WireObjectMaterialFlag -ne 0) {
 $asm += Add-Bytes "object_wire_screen" ([int[]]$objectWireScreen)
 $asm += Add-Bytes "object_wire_color" ([int[]]$objectWireColor)
 }
 if ($HighBasicV2LayoutFlag -ne 0 -and $PolyFillFlag -ne 0 -and $WireDepthSortFlag -ne 0) {
 $asm += @'
.if HIGH_BASIC_V2_STATIC_LOW_BASE < $456c || HIGH_BASIC_V2_STATIC_LOW_BASE >= HIGH_BASIC_V2_STATIC_LOW_LIMIT
 .error "High-basic-v2 lower static segment is outside its reserved range"
.endif
* = HIGH_BASIC_V2_STATIC_LOW_BASE

'@
 }
 $asm += Add-Bytes "object_pos_x_lo" ([int[]]$objectPosXLo)
 $asm += Add-Bytes "object_pos_x_hi" ([int[]]$objectPosXHi)
 $asm += Add-Bytes "object_pos_y_lo" ([int[]]$objectPosYLo)
 $asm += Add-Bytes "object_pos_y_hi" ([int[]]$objectPosYHi)
 $asm += Add-Bytes "object_pos_z_lo" ([int[]]$objectPosZLo)
 $asm += Add-Bytes "object_pos_z_hi" ([int[]]$objectPosZHi)
 $asm += Add-Bytes "object_pos_z_ext" ([int[]]$objectPosZExt)
 if ($ObjectLinearVelocityDataRequiredFlag -ne 0) {
 $asm += Add-Bytes "object_vel_x_lo" ([int[]]$objectVelXLo)
 $asm += Add-Bytes "object_vel_x_hi" ([int[]]$objectVelXHi)
 $asm += Add-Bytes "object_vel_y_lo" ([int[]]$objectVelYLo)
 $asm += Add-Bytes "object_vel_y_hi" ([int[]]$objectVelYHi)
 $asm += Add-Bytes "object_vel_z_lo" ([int[]]$objectVelZLo)
 $asm += Add-Bytes "object_vel_z_hi" ([int[]]$objectVelZHi)
 $asm += Add-Bytes "object_vel_z_ext" ([int[]]$objectVelZExt)
 }
 $asm += Add-Bytes "object_ang_x_lo" ([int[]]$objectAngXLo)
 $asm += Add-Bytes "object_ang_x_hi" ([int[]]$objectAngXHi)
 $asm += Add-Bytes "object_ang_y_lo" ([int[]]$objectAngYLo)
 $asm += Add-Bytes "object_ang_y_hi" ([int[]]$objectAngYHi)
 $asm += Add-Bytes "object_ang_z_lo" ([int[]]$objectAngZLo)
 $asm += Add-Bytes "object_ang_z_hi" ([int[]]$objectAngZHi)
 if ($ObjectAngularVelocityDataRequiredFlag -ne 0) {
 $asm += Add-Bytes "object_angvel_x_lo" ([int[]]$objectAngVelXLo)
 $asm += Add-Bytes "object_angvel_x_hi" ([int[]]$objectAngVelXHi)
 $asm += Add-Bytes "object_angvel_y_lo" ([int[]]$objectAngVelYLo)
 $asm += Add-Bytes "object_angvel_y_hi" ([int[]]$objectAngVelYHi)
 $asm += Add-Bytes "object_angvel_z_lo" ([int[]]$objectAngVelZLo)
 $asm += Add-Bytes "object_angvel_z_hi" ([int[]]$objectAngVelZHi)
 }
 $asm += Add-Bytes "object_scale" ([int[]]$objectScale)
 if ($ExplorerTraversalCullFlag -ne 0) {
 $asm += Add-Bytes "object_traverse_radius" ([int[]]$objectTraverseRadius)
 $asm += Add-Bytes "object_traverse_state" ([int[]](0..($SceneObjectCount - 1) | ForEach-Object { 0 }))
 }
 if ($SceneObjectVisibilityActiveFlag -ne 0) {
 $asm += Add-Bytes "object_visible" ([int[]]$objectVisible)
 }
 if ($SceneRespawnActiveFlag -ne 0) {
 $asm += Add-Bytes "object_respawn_enabled" ([int[]]$objectRespawnEnabled)
 $asm += Add-Bytes "object_respawn_near_z_hi" ([int[]]$objectRespawnNearZHi)
 $asm += Add-Bytes "object_respawn_far_z_lo" ([int[]]$objectRespawnFarZLo)
 $asm += Add-Bytes "object_respawn_far_z_hi" ([int[]]$objectRespawnFarZHi)
 $asm += Add-Bytes "object_respawn_far_z_ext" ([int[]]$objectRespawnFarZExt)
 $asm += Add-Bytes "object_respawn_far_z_jitter_mask" ([int[]]$objectRespawnFarZJitterMask)
 $asm += Add-Bytes "object_respawn_x_mask" ([int[]]$objectRespawnXMask)
 $asm += Add-Bytes "object_respawn_x_bias" ([int[]]$objectRespawnXBias)
 $asm += Add-Bytes "object_respawn_y_mask" ([int[]]$objectRespawnYMask)
 $asm += Add-Bytes "object_respawn_y_bias" ([int[]]$objectRespawnYBias)
 }
 if ($SceneOscXActiveFlag -ne 0) {
 $asm += Add-Bytes "object_osc_x_enabled" ([int[]]$objectOscXEnabled)
 $asm += Add-Bytes "object_osc_x_min_lo" ([int[]]$objectOscXMinLo)
 $asm += Add-Bytes "object_osc_x_min_hi" ([int[]]$objectOscXMinHi)
 $asm += Add-Bytes "object_osc_x_max_lo" ([int[]]$objectOscXMaxLo)
 $asm += Add-Bytes "object_osc_x_max_hi" ([int[]]$objectOscXMaxHi)
 }
}
if ($CameraSmoothDepthActiveFlag -ne 0) {
 $asm += Add-Bytes "camera_smooth_depth_phase" ([int[]]@($CameraSmoothDepthPhaseStart))
 $asm += Add-Bytes "camera_smooth_depth_pos_lo" ([int[]]$cameraSmoothDepthPosLo)
 $asm += Add-Bytes "camera_smooth_depth_pos_hi" ([int[]]$cameraSmoothDepthPosHi)
 $asm += Add-Bytes "camera_smooth_depth_pos_ext" ([int[]]$cameraSmoothDepthPosExt)
}
if ($SceneTimelineFlag -ne 0) {
 $tl=$SceneTimelineCompiled
 $asm += Add-Bytes "scene_timeline_state" ([int[]]@([int]$tl.Initial))
 $asm += Add-Bytes "scene_timeline_ticks_lo" ([int[]]@(0))
 $asm += Add-Bytes "scene_timeline_ticks_hi" ([int[]]@(0))
 $asm += Add-Bytes "scene_timeline_entry" ([int[]]@(0))
 $asm += Add-Bytes "scene_timeline_duration_lo" ([int[]]$tl.DurationLo)
 $asm += Add-Bytes "scene_timeline_duration_hi" ([int[]]$tl.DurationHi)
 $asm += Add-Bytes "scene_timeline_next" ([int[]]$tl.Next)
 $asm += Add-Bytes "scene_timeline_entry_base" ([int[]]$tl.EntryBase)
 foreach ($spec in @(
  @("mask0","Mask0"),@("mask1","Mask1"),@("visible","Visible"),@("scale","Scale"),@("material","Material"),@("reflect","Reflect"),@("color","Color"),
  @("px_lo","PxLo"),@("px_hi","PxHi"),@("py_lo","PyLo"),@("py_hi","PyHi"),@("pz_lo","PzLo"),@("pz_hi","PzHi"),@("pz_ext","PzExt"),
  @("rx_lo","RxLo"),@("rx_hi","RxHi"),@("ry_lo","RyLo"),@("ry_hi","RyHi"),@("rz_lo","RzLo"),@("rz_hi","RzHi"),
  @("vx_lo","VxLo"),@("vx_hi","VxHi"),@("vy_lo","VyLo"),@("vy_hi","VyHi"),@("vz_lo","VzLo"),@("vz_hi","VzHi"),@("vz_ext","VzExt"),
  @("avx_lo","AvxLo"),@("avx_hi","AvxHi"),@("avy_lo","AvyLo"),@("avy_hi","AvyHi"),@("avz_lo","AvzLo"),@("avz_hi","AvzHi")
 )) {
 $asm += Add-Bytes ("scene_timeline_" + $spec[0]) ([int[]]$tl.($spec[1]))
 }
}
if ($SceneTimelineFlag -ne 0 -and $HighBasicV2LayoutFlag -ne 0) {
 $asm += ".if * > `$5c00`n .error `"Scene instance/timeline tables exceed `$5300-`$5bff`"`n.endif`nscene_feature_static_end = *`n* = scene_feature_static_return`n"
}
$asm += Add-Bytes "xcoord" ([int[]]$xCoords)
$asm += Add-Bytes "ycoord" ([int[]]$yCoords)
$asm += Add-Bytes "zcoord" ([int[]]$zCoords)
$asm += Add-Bytes "vert_xi" ([int[]]$vertXi)
$asm += Add-Bytes "vert_yi" ([int[]]$vertYi)
$asm += Add-Bytes "vert_zi" ([int[]]$vertZi)
if ($FaceRenderEnableFlag -ne 0) {
 $asm += Add-Bytes "face0" ([int[]]$face0Data)
 $asm += Add-Bytes "face1" ([int[]]$face1Data)
 $asm += Add-Bytes "face2" ([int[]]$face2Data)
 $asm += Add-Bytes "face3" ([int[]]$face3Data)
 if ($HasTriangleFacesFlag -ne 0) {
 $asm += Add-Bytes "face_vertex_count" ([int[]]$faceVertexCountData)
 }
 if ($FaceSolidColorFlag -ne 0) {
 $asm += Add-Bytes "face_solid_color" $faceSolidColor
 }
 if ($WireTwoColorMode2Flag -ne 0) {
 $asm += Add-Bytes "wire_face_slot" ([int[]]$wireFaceSlot)
 }
}
if ($PolyFillFlag -ne 0) {
 $asm += Add-Bytes "face_shade" $faceShade
 if ($StaticShadeDirectFlag -ne 0) {
 $asm += Add-Bytes "face_static_fill" $faceStaticFill
 }
 if ($StaticShadeDirectFlag -ne 0) {
 if ($FaceMaterialActiveOnlyFlag -eq 0) {
 $asm += Add-Bytes "face_material" $faceMaterial
 }
 if ($FaceReflectivityActiveOnlyFlag -eq 0) {
 $asm += Add-Bytes "face_reflect_offset" $faceReflectivity
 }
 } else {
 $asm += Add-Bytes "face_material" $faceMaterial
 $asm += Add-Bytes "face_reflect_offset" $faceReflectivity
 }
 if ($SceneFaceMaterialOverrideFlag -ne 0) {
 $asm += Add-Bytes "face_material_explicit" ([int[]]@($MeshFaceMaterialFamilies | ForEach-Object { if ([int]$_ -ge 0) { [int]$_ } else { 255 } }))
 }
}
if ($DynamicLightFlag -ne 0 -or ($HiddenWireFlag -ne 0 -and $Mode2MemorySpecializationFlag -eq 0)) {
 $asm += Add-Bytes "face_normal_x" ([int[]]$faceNormalX)
 $asm += Add-Bytes "face_normal_y" ([int[]]$faceNormalY)
 $asm += Add-Bytes "face_normal_z" ([int[]]$faceNormalZ)
 $asm += Add-Bytes "face_center_dot_lo" ([int[]]$faceCenterDotLo)
 $asm += Add-Bytes "face_center_dot_hi" ([int[]]$faceCenterDotHi)
}
if ($DynamicLightFlag -ne 0) {
 if ($Mode4DynamicShadeThresholdFixFlag -ne 0) {
  $asm += Add-Bytes "shade_thresh_mid_q6" ([int[]]$ShadeThresholdMidQ6)
  $asm += Add-Bytes "shade_thresh_mid_high_q6" ([int[]]$ShadeThresholdMidHighQ6)
  $asm += Add-Bytes "shade_thresh_high_q6" ([int[]]$ShadeThresholdHighQ6)
 } else {
  $asm += Add-Bytes "shade_thresh_mid" ([int[]]$ShadeThresholdMid)
  $asm += Add-Bytes "shade_thresh_mid_high" ([int[]]$ShadeThresholdMidHigh)
  $asm += Add-Bytes "shade_thresh_high" ([int[]]$ShadeThresholdHigh)
 }
}
if ($FullDynamicShadeFlag -ne 0) {
 if ($Mode4DynamicShadeThresholdFixFlag -ne 0) {
  $asm += Add-Bytes "shade_hyst_dark_up_q6" ([int[]]$ShadeHystDarkUpQ6)
  $asm += Add-Bytes "shade_hyst_checker_dark_up_q6" ([int[]]$ShadeHystCheckerDarkUpQ6)
  $asm += Add-Bytes "shade_hyst_solid_mid_down_q6" ([int[]]$ShadeHystSolidMidDownQ6)
  $asm += Add-Bytes "shade_hyst_solid_mid_up_q6" ([int[]]$ShadeHystSolidMidUpQ6)
  $asm += Add-Bytes "shade_hyst_checker_high_down_q6" ([int[]]$ShadeHystCheckerHighDownQ6)
  $asm += Add-Bytes "shade_hyst_checker_high_up_q6" ([int[]]$ShadeHystCheckerHighUpQ6)
  $asm += Add-Bytes "shade_hyst_solid_high_down_q6" ([int[]]$ShadeHystSolidHighDownQ6)
 } else {
  $asm += Add-Bytes "shade_hyst_dark_up" ([int[]]$ShadeHystDarkUp)
  $asm += Add-Bytes "shade_hyst_checker_dark_up" ([int[]]$ShadeHystCheckerDarkUp)
  $asm += Add-Bytes "shade_hyst_solid_mid_down" ([int[]]$ShadeHystSolidMidDown)
  $asm += Add-Bytes "shade_hyst_solid_mid_up" ([int[]]$ShadeHystSolidMidUp)
  $asm += Add-Bytes "shade_hyst_checker_high_down" ([int[]]$ShadeHystCheckerHighDown)
  $asm += Add-Bytes "shade_hyst_checker_high_up" ([int[]]$ShadeHystCheckerHighUp)
  $asm += Add-Bytes "shade_hyst_solid_high_down" ([int[]]$ShadeHystSolidHighDown)
 }
}
if ($DynamicLightFlag -ne 0) {
 $asm += Add-Bytes "light_intensity_table" ([int[]]$LightIntensityTable)
 $asm += Add-Bytes "light_pos_x" ([int[]]$LightPosX)
 $asm += Add-Bytes "light_pos_y" ([int[]]$LightPosY)
 $asm += Add-Bytes "light_pos_z" ([int[]]$LightPosZ)
}
$asm += Add-Bytes "material_screen_bytes" ([int[]]$MaterialScreenBytes)
$asm += Add-Bytes "material_color_bytes" ([int[]]$MaterialColorBytes)
if ($WorldGroundEnableFlag -ne 0) {
 $groundHorizonRowsForAsm = if ($CameraRollActiveFlag -ne 0 -and $EngineGroundSimpleRuntimeFlag -eq 0) { $groundHorizonStartRowsRollBiased } else { $groundHorizonStartRows }
 $asm += Add-Bytes "world_ground_horizon_start" ([int[]]$groundHorizonRowsForAsm)
}
$WorldGroundMode3StaticLowFlag = if ($WorldGroundPlaneFlag -ne 0 -and $GraphicsModeNumber -eq 3 -and $HighBasicV2LayoutFlag -ne 0) { 1 } else { 0 }
if ($WorldGroundMode3StaticLowFlag -ne 0) {
 $asm += @'
.if * < HIGH_BASIC_V2_CODE_HIGH_BASE || * >= HIGH_BASIC_V2_IO_BASE
 .error "Mode 3 plane Ground expected high-code placement before static relocation"
.endif
world_ground_mode3_high_return = *
* = RUNTIME_BUFFER_COLOR_POLICY_END
world_ground_mode3_static_low_start = *
'@
 $asm += "`n"
}
if ($WorldGroundRendererAsm.Length -gt 0) {
 $asm += $WorldGroundRendererAsm
 $asm += "
"
}
if ($WorldGroundWireRollRendererAsm.Length -gt 0) {
 $asm += $WorldGroundWireRollRendererAsm
 $asm += "
"
}
if ($WorldGroundWireMaskAsm.Length -gt 0) {
 $asm += $WorldGroundWireMaskAsm
 $asm += "
"
}
if ($WorldGroundOcclusionAsm.Length -gt 0) {
 $asm += $WorldGroundOcclusionAsm
 $asm += "
"
}
if ($WorldGroundRollRendererAsm.Length -gt 0) {
 $asm += $WorldGroundRollRendererAsm
 $asm += "
"
}
if ($WorldGroundMode3StaticLowFlag -ne 0) {
 $asm += @'
world_ground_mode3_static_low_end = *
.if world_ground_mode3_static_low_end > mode3_high_basic_relocated_code_start
 .error "Mode 3 plane Ground static routines overlap relocated raster code"
.endif
* = world_ground_mode3_high_return
'@
 $asm += "`n"
}
$asm += Add-Bytes "sintab" $sin
if ($StandardProjectVertexFlag -ne 0) {
 $asm += Add-Bytes "scale_tab" $scale
 if ($SceneObjectCount -gt 0) {
 $asm += Add-Bytes "scene_scale_tab" $sceneScale
 }
 if ($ReferenceProjectionFlag -eq 0) {
 $asm += Add-Bytes "scale_far_tab" $scaleFar
 }
 $asm += Add-Bytes "projx" $projx
 $asm += Add-Bytes "projy" $projy
 if ($ReferenceProjectionFlag -ne 0) {
 $asm += Add-Bytes "proj_num_lo" $projNumLo
 $asm += Add-Bytes "proj_num_hi" $projNumHi
 }
} elseif ($ExplorerTableProjectionFlag -ne 0) {
 $asm += Add-Bytes "scene_scale_tab" $sceneScale
}
$asm += Add-Bytes "sqlo" $sqlo
$asm += Add-Bytes "sqhi" $sqhi
$asm += Add-Bytes "row0lo_a" ([int[]]$row0a[0])
$asm += Add-Bytes "row0hi_a" ([int[]]$row0a[1])
$asm += Add-Bytes "row1lo_a" ([int[]]$row1a[0])
$asm += Add-Bytes "row1hi_a" ([int[]]$row1a[1])
$asm += Add-Bytes "row0lo_b" ([int[]]$row0b[0])
$asm += Add-Bytes "row0hi_b" ([int[]]$row0b[1])
$asm += Add-Bytes "row1lo_b" ([int[]]$row1b[0])
$asm += Add-Bytes "row1hi_b" ([int[]]$row1b[1])
$asm += Add-Bytes "screenrowlo_a" ([int[]]$screenRowA[0])
$asm += Add-Bytes "screenrowhi_a" ([int[]]$screenRowA[1])
if ($HighBasicV2LayoutFlag -eq 0) {
 # Stable screens A ($5c00) and B ($8c00) have the same row low bytes.
 # Keep the B label as an assembler alias, preserving every runtime lookup.
 $asm += "screenrowlo_b = screenrowlo_a`n"
} else {
 $asm += Add-Bytes "screenrowlo_b" ([int[]]$screenRowB[0])
}
$asm += Add-Bytes "screenrowhi_b" ([int[]]$screenRowB[1])
$asm += Add-Bytes "colorrowlo" ([int[]]$colorRow[0])
$asm += Add-Bytes "colorrowhi" ([int[]]$colorRow[1])
if ($EngineCameraViewportSmallFlag -ne 0 -or $EngineMode3FramePrefillRuntimeFlag -ne 0) {
 $asm += Add-Bytes "viewport_cellrow_id" ([int[]]$viewportCellRowId)
}
if ($VicColorPolicyEnableFlag -ne 0) {
 $vicColorOwnerScreenLo = @()
 $vicColorOwnerScreenHi = @()
 $vicColorOwnerColorLo = @()
 $vicColorOwnerColorHi = @()
 $vicColorConflictLo = @()
 $vicColorConflictHi = @()
 for ($cellY = 0; $cellY -lt 25; $cellY++) {
 $offset = 40 * $cellY
 $vicColorOwnerScreenLo += ("<(vic_color_owner_screen + {0})" -f $offset)
 $vicColorOwnerScreenHi += (">(vic_color_owner_screen + {0})" -f $offset)
 $vicColorOwnerColorLo += ("<(vic_color_owner_color + {0})" -f $offset)
 $vicColorOwnerColorHi += (">(vic_color_owner_color + {0})" -f $offset)
 $vicColorConflictLo += ("<(vic_color_conflict_map + {0})" -f $offset)
 $vicColorConflictHi += (">(vic_color_conflict_map + {0})" -f $offset)
 }
 $asm += Add-ExpressionBytes "vic_color_owner_screen_rowlo" ([string[]]$vicColorOwnerScreenLo)
 $asm += Add-ExpressionBytes "vic_color_owner_screen_rowhi" ([string[]]$vicColorOwnerScreenHi)
 $asm += Add-ExpressionBytes "vic_color_owner_color_rowlo" ([string[]]$vicColorOwnerColorLo)
 $asm += Add-ExpressionBytes "vic_color_owner_color_rowhi" ([string[]]$vicColorOwnerColorHi)
 if ($VicColorPolicyOverlayFlag -ne 0) {
 $asm += Add-ExpressionBytes "vic_color_conflict_rowlo" ([string[]]$vicColorConflictLo)
 $asm += Add-ExpressionBytes "vic_color_conflict_rowhi" ([string[]]$vicColorConflictHi)
 }
}
$asm += Add-Bytes "xbyte" $xbyte
$asm += Add-Bytes "xofflo" $xofflo
$asm += Add-Bytes "xoffhi" $xoffhi
if ($HighBasicV2LayoutFlag -ne 0 -and $PolyFillFlag -ne 0 -and $WireDepthSortFlag -ne 0) {
 $asm += @'
.if * > HIGH_BASIC_V2_STATIC_LOW_LIMIT
 .error "High-basic-v2 lower static segment overlaps video buffer A"
.endif
.if * > HIGH_BASIC_V2_RUNTIME_BASE
 .error "High-basic-v2 lower static segment overlaps runtime buffer"
.endif
.if high_basic_v2_static_return < HIGH_BASIC_V2_CODE_HIGH_BASE || high_basic_v2_static_return >= HIGH_BASIC_V2_IO_BASE
 .error "High-basic-v2 high code boundary is invalid before tail static data"
.endif
* = high_basic_v2_static_return

'@
}
$asm += Add-Bytes "startmask" $startmask
$asm += Add-Bytes "endmask" $endmask
if ($TrackDirtySpansFlag -ne 0) {
 $asm += Add-Bytes "byteofflo" $byteofflo
 $asm += Add-Bytes "byteoffhi" $byteoffhi
}
if ($FpsOverlayEnableFlag -ne 0) {
 if ($HighBasicV2LayoutFlag -ne 0 -and $GraphicsModeNumber -ne 1) {
  # Modes 2-5 leave the last page below bitmap A unused.  Keep the compact
  # split-screen charset there so the high code/data segment remains below
  # the I/O window.  Mode 1 already uses this page and retains the canonical
  # in-segment placement.
  $asm += @'
fps_font_return = *
* = $1f00

'@
  $asm += Add-Bytes "fps_font_bytes" $fpsFontBytesEmitted
  $asm += @'
.if * > $2000
 .error "High-basic-v2 compact text charset overlaps bitmap A"
.endif
* = fps_font_return

'@
 } else {
  $asm += Add-Bytes "fps_font_bytes" $fpsFontBytesEmitted
 }
}
if ($ExplorerMatrixFoldFlag -ne 0) {
 $asm += @'

.if EXPLORER_MATRIX_FOLD != 0
explorer_view_origin_x_lo: .byte 0
explorer_view_origin_x_hi: .byte 0
explorer_view_origin_y_lo: .byte 0
explorer_view_origin_y_hi: .byte 0
explorer_view_origin_z_lo: .byte 0
explorer_view_origin_z_hi: .byte 0

prepare_explorer_matrix_fold:
 jsr prepare_object_matrix
 jsr explorer_prepare_view
 jsr explorer_prepare_folded_origin
 jsr explorer_fold_camera_matrix
.if STABLE_FACE_CULL_PROFILE != 0
 jsr stable_face_cull_cache_matrix
.endif
 jsr build_coord_terms
 jsr prepare_object_matrix
 rts

explorer_prepare_folded_origin:
 lda obj_pos_x_cur
 jsr explorer_sub_cam_x
 lda obj_pos_y_cur
 jsr explorer_sub_cam_y
 lda obj_depth_lo
 sta rz1
 lda obj_depth_hi
 sta explorer_z_world_hi
 jsr explorer_sub_cam_z16
 ; Preserve geometric depth in the folded origin.  Projection applies the
 ; legacy index origin locally after the complete view transform.

 lda explorer_rel_x_lo
 sta p1lo
 lda explorer_rel_x_hi
 sta p1hi
 lda cosyv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda rz1
 sta p1lo
 lda explorer_z_hi16
 sta p1hi
 lda sinyv
 jsr mul_s16_s6
 sec
 lda t1
 sbc p1lo
 sta explorer_view_origin_x_lo
 lda t2
 sbc p1hi
 sta explorer_view_origin_x_hi

 lda explorer_rel_x_lo
 sta p1lo
 lda explorer_rel_x_hi
 sta p1hi
 lda sinyv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda rz1
 sta p1lo
 lda explorer_z_hi16
 sta p1hi
 lda cosyv
 jsr mul_s16_s6
 clc
 lda p1lo
 adc t1
 sta explorer_view_z_lo
 lda p1hi
 adc t2
 sta explorer_view_z_hi

.if ENGINE_CAMERA_FOLDED_PITCH_ZERO_FASTPATH != 0
 lda explorer_cam_pitch
 bne epfo_engine_pitch_apply
 lda explorer_rel_y_lo
 sta explorer_view_origin_y_lo
 lda explorer_rel_y_hi
 sta explorer_view_origin_y_hi
 lda explorer_view_z_lo
 sta explorer_view_origin_z_lo
 lda explorer_view_z_hi
 sta explorer_view_origin_z_hi
 jmp epfo_engine_pitch_done
epfo_engine_pitch_apply:
.endif
 lda explorer_rel_y_lo
 sta p1lo
 lda explorer_rel_y_hi
 sta p1hi
 lda cosxv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda explorer_view_z_lo
 sta p1lo
 lda explorer_view_z_hi
 sta p1hi
 lda sinxv
 jsr mul_s16_s6
 sec
 lda t1
 sbc p1lo
 sta explorer_view_origin_y_lo
 lda t2
 sbc p1hi
 sta explorer_view_origin_y_hi

 lda explorer_rel_y_lo
 sta p1lo
 lda explorer_rel_y_hi
 sta p1hi
 lda sinxv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda explorer_view_z_lo
 sta p1lo
 lda explorer_view_z_hi
 sta p1hi
 lda cosxv
 jsr mul_s16_s6
 clc
 lda p1lo
 adc t1
 sta explorer_view_origin_z_lo
 lda p1hi
 adc t2
 sta explorer_view_origin_z_hi
.if ENGINE_CAMERA_FOLDED_PITCH_ZERO_FASTPATH != 0
epfo_engine_pitch_done:
.endif
.if CAMERA_ROLL_ACTIVE != 0
 lda explorer_view_origin_x_lo
 sta rx0
 lda explorer_view_origin_x_hi
 sta rx1
 lda explorer_view_origin_y_lo
 sta ry0
 lda explorer_view_origin_y_hi
 sta ry1

 lda rx0
 sta p1lo
 lda rx1
 sta p1hi
 lda coszv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda ry0
 sta p1lo
 lda ry1
 sta p1hi
 lda sinzv
 jsr mul_s16_s6
 sec
 lda t1
 sbc p1lo
 sta explorer_view_origin_x_lo
 lda t2
 sbc p1hi
 sta explorer_view_origin_x_hi

 lda rx0
 sta p1lo
 lda rx1
 sta p1hi
 lda sinzv
 jsr mul_s16_s6
 lda p1lo
 sta t1
 lda p1hi
 sta t2
 lda ry0
 sta p1lo
 lda ry1
 sta p1hi
 lda coszv
 jsr mul_s16_s6
 clc
 lda p1lo
 adc t1
 sta explorer_view_origin_y_lo
 lda p1hi
 adc t2
 sta explorer_view_origin_y_hi
.endif
 rts

explorer_fold_camera_matrix:
 lda m00
 ldx sinyv
 jsr mul_s6
 sta rx0
 lda m20
 ldx cosyv
 jsr mul_s6
 clc
 adc rx0
 sta rx0
 lda m01
 ldx sinyv
 jsr mul_s6
 sta ry0
 lda m21
 ldx cosyv
 jsr mul_s6
 clc
 adc ry0
 sta ry0
 lda m02
 ldx sinyv
 jsr mul_s6
 sta rz0
 lda m22
 ldx cosyv
 jsr mul_s6
 clc
 adc rz0
 sta rz0

 lda m00
 ldx cosyv
 jsr mul_s6
 sta t1
 lda m20
 ldx sinyv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta m00
 lda m01
 ldx cosyv
 jsr mul_s6
 sta t1
 lda m21
 ldx sinyv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta m01
 lda m02
 ldx cosyv
 jsr mul_s6
 sta t1
 lda m22
 ldx sinyv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta m02

.if ENGINE_CAMERA_FOLDED_PITCH_ZERO_FASTPATH != 0
 lda explorer_cam_pitch
 bne efcm_engine_pitch_apply
 lda rx0
 sta m20
 lda ry0
 sta m21
 lda rz0
 sta m22
 jmp efcm_engine_pitch_done
efcm_engine_pitch_apply:
.endif
 lda m10
 ldx sinxv
 jsr mul_s6
 sta t1
 lda rx0
 ldx cosxv
 jsr mul_s6
 clc
 adc t1
 sta m20
 lda m11
 ldx sinxv
 jsr mul_s6
 sta t1
 lda ry0
 ldx cosxv
 jsr mul_s6
 clc
 adc t1
 sta m21
 lda m12
 ldx sinxv
 jsr mul_s6
 sta t1
 lda rz0
 ldx cosxv
 jsr mul_s6
 clc
 adc t1
 sta m22

 lda m10
 ldx cosxv
 jsr mul_s6
 sta t1
 lda rx0
 ldx sinxv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta m10
 lda m11
 ldx cosxv
 jsr mul_s6
 sta t1
 lda ry0
 ldx sinxv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta m11
 lda m12
 ldx cosxv
 jsr mul_s6
 sta t1
 lda rz0
 ldx sinxv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta m12
.if ENGINE_CAMERA_FOLDED_PITCH_ZERO_FASTPATH != 0
efcm_engine_pitch_done:
.endif
.if CAMERA_ROLL_ACTIVE != 0
 lda m00
 sta rx0
 lda m01
 sta ry0
 lda m02
 sta rz0

 lda rx0
 ldx coszv
 jsr mul_s6
 sta t1
 lda m10
 ldx sinzv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta m00
 lda ry0
 ldx coszv
 jsr mul_s6
 sta t1
 lda m11
 ldx sinzv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta m01
 lda rz0
 ldx coszv
 jsr mul_s6
 sta t1
 lda m12
 ldx sinzv
 jsr mul_s6
 sta t2
 sec
 lda t1
 sbc t2
 sta m02

 lda rx0
 ldx sinzv
 jsr mul_s6
 sta t1
 lda m10
 ldx coszv
 jsr mul_s6
 clc
 adc t1
 sta m10
 lda ry0
 ldx sinzv
 jsr mul_s6
 sta t1
 lda m11
 ldx coszv
 jsr mul_s6
 clc
 adc t1
 sta m11
 lda rz0
 ldx sinzv
 jsr mul_s6
 sta t1
 lda m12
 ldx coszv
 jsr mul_s6
 clc
 adc t1
 sta m12
.endif
 rts
.endif
'@
}

if ($Mode4PatternProbeFlag -ne 0) {
 $asm += @'

.if MODE4_PATTERN_PROBE != 0
; Appended after all normal code/data: probe-only bytes cannot relocate the
; validated XYQ2 builder or either edge tracer.
mode4_pattern_probe_dispatch:
 ldy sortj
 lda mode4_pattern_probe_by_face,y
 sta shadeidx
 jmp ddb_pattern_call
; Six distinct two-byte phase pairs already resident in the RC4 table.
; The final value $05 reads bytes $05/$06, strictly inside that table.
mode4_pattern_probe_by_face:
 .byte $00,$01,$02,$03,$04,$05
.if shade_pattern_bytes + $06 >= shade_pattern_bytes_end
 .error "Mode4PatternProbe requires six in-range RC4 pattern-pair offsets"
.endif
.if FACE_COUNT != $06
 .error "Mode4PatternProbe is restricted to the six-face cube"
.endif
.endif
'@
}

if ($Mode4FaceIdLatchFlag -ne 0) {
 $asm += @'

.if MODE4_FACE_ID_LATCH != 0
; The bucket value in A is latched once, bounds-checked, then Y is restored
; from the dedicated cell before the ordinary face loop resumes.
mode4_latch_current_face_id:
 sta sortj
 sta mode4_current_face_id
 cmp #FACE_COUNT
 bcc mode4_latch_current_face_id_ok
 sei
mode4_latch_current_face_id_halt:
 jmp mode4_latch_current_face_id_halt
mode4_latch_current_face_id_ok:
 ldy mode4_current_face_id
 jmp ddb_face_loop
.endif
'@
}

if ($Mode4ValidShadeFaceProbeFlag -ne 0) {
 $asm += @'

.if MODE4_VALID_SHADE_FACE_PROBE != 0
; Full shade codes, not raw filler offsets.  Pattern entries retain bit 7;
; the normal dispatcher then converts them to the even pair offset consumed
; by fill_bounds_pattern_a/b.  Solid entries keep the normal solid wrapper.
mode4_valid_shade_face_probe_dispatch:
 ldy mode4_current_face_id
 cpy #FACE_COUNT
 bcc mode4_valid_shade_face_probe_index_ok
 jmp mode4_latch_current_face_id_halt
mode4_valid_shade_face_probe_index_ok:
 lda mode4_valid_shade_face_probe_by_face,y
 bmi mode4_valid_shade_face_probe_pattern
 tay
 jmp ddb_solid_from_y
mode4_valid_shade_face_probe_pattern:
 and #$7f
 sta shadeidx
 jmp ddb_pattern_call
; $00/$02/$04 are solid RC4 codes; $82/$84/$86 are valid, even-offset
; pattern codes.  All six are genuinely selectable by Mode 4 shading.
mode4_valid_shade_face_probe_by_face:
 .byte $00,$82,$86,$02,$84,$04
.if FACE_COUNT != $06
 .error "Mode4ValidShadeFaceProbe is restricted to the six-face cube"
.endif
.if shade_pattern_bytes + $07 >= shade_pattern_bytes_end
 .error "Mode4ValidShadeFaceProbe requires the RC4 pattern-pair table"
.endif
.endif
'@
}

if ($Mode4ShadeStepLimitFlag -ne 0) {
 $asm += @'

.if MODE4_SHADE_STEP_LIMIT != 0
; A is the code selected by the unmodified Q6 thresholds/hysteresis.  The
; per-face rank state is $ff until its first visible update; that first code
; is passed through exactly, then every later update moves by at most one
; rank.  The result is mapped back to a valid full RC4 shade code.
mode4_shade_step_limit_apply:
 sta t2
 jsr mode4_shade_rank_from_code
 sta t1
 ldy tmpidx
 lda mode4_shade_step_rank,y
 cmp #$ff
 beq mode4_shade_step_limit_first
 cmp t1
 beq mode4_shade_step_limit_store
 bcc mode4_shade_step_limit_up
 sec
 sbc #$01
 jmp mode4_shade_step_limit_store
mode4_shade_step_limit_up:
 clc
 adc #$01
mode4_shade_step_limit_store:
 sta mode4_shade_step_rank,y
 tax
 lda mode4_shade_code_by_rank,x
 rts
mode4_shade_step_limit_first:
 lda t1
 sta mode4_shade_step_rank,y
 lda t2
 rts

; Order is visual brightness, not a numerical interpretation of the raw
; byte.  $86 is the reflective checker-high variant and shares rank four.
mode4_shade_rank_from_code:
 cmp #$00
 beq mode4_shade_rank_0
 cmp #$80
 beq mode4_shade_rank_1
 cmp #$82
 beq mode4_shade_rank_2
 cmp #$02
 beq mode4_shade_rank_3
 cmp #$84
 beq mode4_shade_rank_4
 cmp #$86
 beq mode4_shade_rank_4
 cmp #$04
 beq mode4_shade_rank_5
; Invalid codes are never generated by the RC4 selector: fail dark rather
; than indexing state outside the valid six-rank mapping.
mode4_shade_rank_0:
 lda #$00
 rts
mode4_shade_rank_1:
 lda #$01
 rts
mode4_shade_rank_2:
 lda #$02
 rts
mode4_shade_rank_3:
 lda #$03
 rts
mode4_shade_rank_4:
 lda #$04
 rts
mode4_shade_rank_5:
 lda #$05
 rts
mode4_shade_code_by_rank:
 .byte $00,$80,$82,$02,$84,$04
.endif
'@
}

if ($Mode4PatternProbeLatchedFaceFlag -ne 0) {
 $asm += @'

.if MODE4_PATTERN_PROBE_LATCHED_FACE != 0
; These entries are reached only after build_loaded_face_bounds_xyq2 returns
; valid bounds.  shadeidx is the immediate selector consumed by the filler.
mode4_pattern_probe_latched_fill_a:
 jsr mode4_pattern_probe_latched_select
 jmp fill_bounds_pattern_a
mode4_pattern_probe_latched_fill_b:
 jsr mode4_pattern_probe_latched_select
 jmp fill_bounds_pattern_b
mode4_pattern_probe_latched_select:
 ldy mode4_current_face_id
 cpy #FACE_COUNT
 bcc mode4_pattern_probe_latched_select_ok
 jmp mode4_latch_current_face_id_halt
mode4_pattern_probe_latched_select_ok:
 lda mode4_pattern_probe_latched_by_face,y
 sta shadeidx
 rts
; Six distinct pairs formed only from the existing RC4 pattern bytes.
mode4_pattern_probe_latched_by_face:
 .byte $00,$01,$02,$03,$04,$05
.if shade_pattern_bytes + $06 >= shade_pattern_bytes_end
 .error "Mode4PatternProbeLatchedFace requires six in-range RC4 pattern-pair offsets"
.endif
.if FACE_COUNT != $06
 .error "Mode4PatternProbeLatchedFace is restricted to the six-face cube"
.endif
.endif
'@
}

if ($Mode3HighBasicFullRasterRelocationFlag -ne 0) {
 $asm += "`nmode3_high_basic_high_code_end = *`n"
}

if ($Mode4ShadeStepLimit.IsPresent -or $Mode4ValidShadeFaceProbe.IsPresent) {
 $ReferenceBuilderPath = Join-Path (Split-Path -Parent (Split-Path -Parent $Root)) "3Dvibe64_github-ready_0.1.0-rc4\work\build-3Dvibe64.ps1"
 if (-not (Test-Path -LiteralPath $ReferenceBuilderPath -PathType Leaf)) {
  throw "RC4 reference builder not found: $ReferenceBuilderPath"
 }
 # This host-side differential is intentionally source-bound: it first proves
 # that the cache, Q6 threshold and selector blocks are byte-for-byte equal,
 # then drives all six cube normals through 256 fixed integer light/matrix
 # poses.  Thus a non-zero result is a lookup/selector regression, not raster.
 $Mode4ShadeRegressionPython = @'
import math, pathlib, sys
rc4 = pathlib.Path(sys.argv[1]).read_text(encoding='utf-8')
dev = pathlib.Path(sys.argv[2]).read_text(encoding='utf-8')
def segment(text, marker, length):
    p = text.index(marker)
    return text[p:p + length]
for marker, length in (('$LightShadeBytes =', 2100),
                       ('prepare_object_light_for_shade:', 1100),
                       ('select_face_shade_from_dot:', 2270),
                       ('select_raw_face_shade_from_dot:', 1250)):
    if segment(rc4, marker, length) != segment(dev, marker, length):
        raise SystemExit('RC4_DEV3_SOURCE_DIVERGENCE ' + marker)
def ceildiv(a,b): return (a+b-1)//b
def table(base): return [255 if i == 0 else min(255, ceildiv(base*10,i)) for i in range(11)]
mid, midhigh, high = table(8), table(16), table(24)
def raw(dot, intensity, reflect):
    if intensity == 0 or dot < 0: return 0x00
    if dot >= high[intensity] * 64: return 0x04 if reflect >= 20 else 0x84
    if dot >= midhigh[intensity] * 64: return 0x04 if reflect >= 20 else (0x84 if reflect >= 10 else 0x02)
    if dot >= mid[intensity] * 64: return 0x84 if reflect >= 20 else (0x86 if reflect >= 10 else 0x82)
    return 0x00
rank = {0x00:0, 0x80:1, 0x82:2, 0x02:3, 0x84:4, 0x86:4, 0x04:5}
normals = ((64,0,0),(-64,0,0),(0,64,0),(0,-64,0),(0,0,64),(0,0,-64))
rc4_out=[]; dev_out=[]; jumps=[]
old=[0x00]*6; limited=[None]*6; limited_jumps=0
for pose in range(256):
    a=pose*2*math.pi/256; b=(pose*5+31)*2*math.pi/256
    # Integer Q6 cache/light input, shared by both source-identical paths.
    light=(round(48*math.cos(a)),round(48*math.sin(a)),round(48*math.cos(b)))
    intensity=1+(pose%10); reflect=(pose*7)%25
    for face, normal in enumerate(normals):
        dot=sum(n*l for n,l in zip(normal,light))
        code=raw(dot,intensity,reflect)
        rc4_out.append(code); dev_out.append(code)
        if abs(rank[code]-rank[old[face]]) > 1: jumps.append((pose,face,old[face],code))
        old[face]=code
        requested=rank[code]
        if limited[face] is None: actual=requested
        else: actual=max(limited[face]-1, min(limited[face]+1, requested))
        if limited[face] is not None and abs(actual-limited[face]) > 1: limited_jumps += 1
        limited[face]=actual
if rc4_out != dev_out: raise SystemExit('RC4_DEV3_SHADE_DIVERGENCE')
preview=','.join('p%d/f%d:%02X-%02X' % x for x in jumps[:10]) or 'none'
print('RC4_DEV3_SHADE_REGRESSION poses=256 faces=6 samples=%d divergences=0 abrupt_rank_jumps=%d step_limit_jumps=%d first=%s' % (len(rc4_out),len(jumps),limited_jumps,preview))
'@
 & python -c $Mode4ShadeRegressionPython $ReferenceBuilderPath $PSCommandPath
 if ($LASTEXITCODE -ne 0) {
  throw "RC4/DEV3 Mode 4 host-side shade regression failed with exit code $LASTEXITCODE"
 }
}

$Mode5StableRelocatedCodeFlag = if ($Mode5PolygonOutlineFlag -ne 0 -and $HighBasicV2LayoutFlag -eq 0) { 1 } else { 0 }
$CameraPlaneStableRelocatedCodeFlag = if ($CameraSpaceFaceCullSupportFlag -ne 0 -and $HighBasicV2LayoutFlag -eq 0) { 1 } else { 0 }
$StableRelocatedCodeFlag = if ($Mode5StableRelocatedCodeFlag -ne 0 -or $CameraPlaneStableRelocatedCodeFlag -ne 0) { 1 } else { 0 }
$Mode5StableSegmentLabelsPath = Join-Path $Root "build\mode5-stable-segments.labels.tmp"
$Mode3HighBasicSegmentLabelsPath = Join-Path $Root "build\mode3-high-basic-segments.labels.tmp"
if ($Mode5StableRelocatedCodeFlag -ne 0) {
 $asm += "`nmode5_stable_low_segment_end = *`n"
}
if ($StableRelocatedCodeFlag -ne 0) {
 $asm += "`nstable_relocated_low_segment_end = *`n"
}
foreach ($sharedAxis in @("x", "y", "z")) {
 $sharedNeedle = " ldx vert_${sharedAxis}i,y"
 $sharedReplacement = ".if MESH_SOURCE_SHARING_RUNTIME != 0`n ldx shared_source_vertex`n lda vert_${sharedAxis}i,x`n tax`n.else`n${sharedNeedle}`n.endif"
 $asm = $asm.Replace($sharedNeedle, $sharedReplacement)
}
for ($sharedFaceVertex = 0; $sharedFaceVertex -lt 4; $sharedFaceVertex++) {
 foreach ($sharedOpcode in @("lda", "ldx")) {
  $sharedNeedle = " ${sharedOpcode} face${sharedFaceVertex},y"
  $sharedReplacement = ".if MESH_SOURCE_SHARING_RUNTIME != 0`n ${sharedOpcode} shared_fv${sharedFaceVertex}`n.else`n${sharedNeedle}`n.endif"
  $asm = $asm.Replace($sharedNeedle, $sharedReplacement)
 }
}

function Remove-Div16uRoutineContainingLabel([string]$source, [string]$innerLabel, [bool]$required) {
 $pattern = '(?ms)^div16u:\r?\n(?:(?!^div16u:).)*?^' + [regex]::Escape($innerLabel) + ':\r?\n(?:(?!^div16u:).)*?^ rts\r?\n'
 $matches = [regex]::Matches($source, $pattern)
 if ($required -and $matches.Count -ne 1) {
  throw "Expected exactly one div16u routine containing label '$innerLabel', found $($matches.Count)"
 }
 if ($matches.Count -gt 1) {
  throw "Ambiguous div16u routine containing label '$innerLabel': found $($matches.Count)"
 }
 if ($matches.Count -eq 1) {
  return [regex]::Replace($source, $pattern, '', 1)
 }
 return $source
}

$GroundFixedDiv16uOwnerFlag = if ($RuntimeWorldGroundOccludeFlag -ne 0 -and $WorldGroundPlaneFlag -ne 0 -and $CameraMovableFlag -eq 0) { 1 } else { 0 }
if ($GroundFixedDiv16uOwnerFlag -ne 0) {
 $asm = Remove-Div16uRoutineContainingLabel $asm 'd16_loop' $true
} else {
 $asm = Remove-Div16uRoutineContainingLabel $asm 'gpfdiv_loop' $false
}

Set-Content -LiteralPath $AsmPath -Encoding ASCII -Value $asm

$tassArgs = @("-a", "-B", "-o", $PrgPath)
if ($StableRelocatedCodeFlag -ne 0) {
 Remove-Item -LiteralPath $Mode5StableSegmentLabelsPath -Force -ErrorAction SilentlyContinue
 $tassArgs += "--labels=build\mode5-stable-segments.labels.tmp"
} elseif ($Mode3HighBasicFullRasterRelocationFlag -ne 0) {
 Remove-Item -LiteralPath $Mode3HighBasicSegmentLabelsPath -Force -ErrorAction SilentlyContinue
 $tassArgs += "--labels=build\mode3-high-basic-segments.labels.tmp"
}
$tassArgs += $AsmPath
Push-Location $Root
try {
 & $Tass @tassArgs
 $tassExitCode = $LASTEXITCODE
} finally {
 Pop-Location
}
if ($tassExitCode -ne 0) {
 Remove-Item -LiteralPath $Mode5StableSegmentLabelsPath -Force -ErrorAction SilentlyContinue
 Remove-Item -LiteralPath $Mode3HighBasicSegmentLabelsPath -Force -ErrorAction SilentlyContinue
 throw "64tass failed with exit code $tassExitCode"
}
Copy-Item -LiteralPath $PrgPath -Destination $BuildPrgPath -Force

if (-not $SkipCmdUpdate.IsPresent) {
$assembleCmd = @'
@echo off
setlocal
set "PROJECT_ROOT=%~dp0"
powershell -ExecutionPolicy Bypass -File "%PROJECT_ROOT%build-3Dvibe64.ps1" -SceneFile "%PROJECT_ROOT%demo\torus-light-orbit\scene.json" -GraphicsMode 4 -Quality fast -Projection extended-table -MemoryLayout high-basic-v2 -CameraMode walkLite -MotionZStartOnReturn -ExplorerResetOnSpace -MaterialFamily red -Reflectivity 0 -LightPhaseCount 32 -LightTickDiv 6 -LightOrbit tumble3d -LightIntensity 10 -ControlReturn -ControlRotation -NoFpsOverlay -VicColorPolicy active -VicColorFallback compat -SkipCmdUpdate
exit /b %errorlevel%
'@
Set-Content -LiteralPath (Join-Path $Root "assemble-3Dvibe64.cmd") -Encoding ASCII -Value $assembleCmd

$runCmd = @'
@echo off
setlocal
set "PROJECT_ROOT=%~dp0"
set "PRG=%PROJECT_ROOT%3Dvibe64.prg"
set "VICE=%VICE_EXE%"
if "%VICE%"=="" set "VICE=x64sc.exe"

if not exist "%VICE%" (
 where "%VICE%" >nul 2>nul
 if errorlevel 1 (
 echo VICE x64sc.exe not found. Set VICE_EXE to the full emulator path or add x64sc.exe to PATH.
 exit /b 1
 )
)

powershell -ExecutionPolicy Bypass -File "%PROJECT_ROOT%build-3Dvibe64.ps1" -SceneFile "%PROJECT_ROOT%demo\torus-light-orbit\scene.json" -GraphicsMode 4 -Quality fast -Projection extended-table -MemoryLayout high-basic-v2 -CameraMode walkLite -MotionZStartOnReturn -ExplorerResetOnSpace -MaterialFamily red -Reflectivity 0 -LightPhaseCount 32 -LightTickDiv 6 -LightOrbit tumble3d -LightIntensity 10 -ControlReturn -ControlRotation -NoFpsOverlay -VicColorPolicy active -VicColorFallback compat -SkipCmdUpdate
if errorlevel 1 exit /b %errorlevel%

taskkill /IM x64sc.exe /F >nul 2>nul
"%VICE%" -autostart "%PRG%"
'@
Set-Content -LiteralPath (Join-Path $Root "run-3Dvibe64-vice.cmd") -Encoding ASCII -Value $runCmd

$headlessRunCmd = @'
@echo off
setlocal
set "PROJECT_ROOT=%~dp0"
set "PRG=%PROJECT_ROOT%3Dvibe64.prg"
set "OUT=%PROJECT_ROOT%build\headless-torus-light-orbit.png"
set "VICE=%VICE_EXE%"
if "%VICE%"=="" set "VICE=x64sc.exe"

if not exist "%VICE%" (
 where "%VICE%" >nul 2>nul
 if errorlevel 1 (
 echo VICE x64sc.exe not found. Set VICE_EXE to the full emulator path or add x64sc.exe to PATH.
 exit /b 1
 )
)

powershell -ExecutionPolicy Bypass -File "%PROJECT_ROOT%build-3Dvibe64.ps1" -SceneFile "%PROJECT_ROOT%demo\torus-light-orbit\scene.json" -GraphicsMode 4 -Quality fast -Projection extended-table -MemoryLayout high-basic-v2 -CameraMode walkLite -MotionZStartOnReturn -ExplorerResetOnSpace -MaterialFamily red -Reflectivity 0 -LightPhaseCount 32 -LightTickDiv 6 -LightOrbit tumble3d -LightIntensity 10 -ControlReturn -ControlRotation -NoFpsOverlay -VicColorPolicy active -VicColorFallback compat -AutoCycleFrames 45 -SkipCmdUpdate
if errorlevel 1 exit /b %errorlevel%

if exist "%OUT%" del "%OUT%"
"%VICE%" -console -autostartprgmode 1 -autostart "%PRG%" -limitcycles 12000000 -exitscreenshot "%OUT%"
if not exist "%OUT%" exit /b 1

powershell -ExecutionPolicy Bypass -File "%PROJECT_ROOT%build-3Dvibe64.ps1" -SceneFile "%PROJECT_ROOT%demo\torus-light-orbit\scene.json" -GraphicsMode 4 -Quality fast -Projection extended-table -MemoryLayout high-basic-v2 -CameraMode walkLite -MotionZStartOnReturn -ExplorerResetOnSpace -MaterialFamily red -Reflectivity 0 -LightPhaseCount 32 -LightTickDiv 6 -LightOrbit tumble3d -LightIntensity 10 -ControlReturn -ControlRotation -NoFpsOverlay -VicColorPolicy active -VicColorFallback compat -SkipCmdUpdate
if errorlevel 1 exit /b %errorlevel%

echo Screenshot: "%OUT%"
exit /b 0
'@
Set-Content -LiteralPath (Join-Path $Root "run-3Dvibe64-headless.cmd") -Encoding ASCII -Value $headlessRunCmd
}

$bytes = [IO.File]::ReadAllBytes($PrgPath)
$load = $bytes[0] + 256 * $bytes[1]
$end = $load + $bytes.Length - 2
$lastLoaded = $end - 1
$lowSegmentEnd = $end
$mode5StableCodeStart = 0
$mode5StableCodeEnd = 0
$cameraPlaneCullCodeStart = 0
$cameraPlaneCullCodeEnd = 0
if ($StableRelocatedCodeFlag -ne 0) {
 try {
  $segmentLabels = Get-Content -LiteralPath $Mode5StableSegmentLabelsPath
  $stableLabelNames = @("stable_relocated_low_segment_end")
  if ($Mode5StableRelocatedCodeFlag -ne 0) {
   $stableLabelNames += @("mode5_stable_code_start", "mode5_stable_code_end")
  }
  if ($CameraPlaneStableRelocatedCodeFlag -ne 0) {
   $stableLabelNames += @("camera_plane_cull_code_start", "camera_plane_cull_code_end")
  }
  foreach ($labelName in $stableLabelNames) {
   $labelLine = @($segmentLabels | Where-Object { $_ -match ("^" + [regex]::Escape($labelName) + "\s*=") })
   if ($labelLine.Count -ne 1) {
    throw "64tass did not emit the required stable relocated segment label: $labelName"
   }
   $labelValueText = (($labelLine[0] -split "=", 2)[1]).Trim()
   if ($labelValueText.StartsWith('$')) {
    $labelValue = [Convert]::ToInt32($labelValueText.Substring(1), 16)
   } else {
    $labelValue = [int]$labelValueText
   }
   switch ($labelName) {
    "stable_relocated_low_segment_end" { $lowSegmentEnd = $labelValue }
    "mode5_stable_code_start" { $mode5StableCodeStart = $labelValue }
    "mode5_stable_code_end" { $mode5StableCodeEnd = $labelValue }
    "camera_plane_cull_code_start" { $cameraPlaneCullCodeStart = $labelValue }
    "camera_plane_cull_code_end" { $cameraPlaneCullCodeEnd = $labelValue }
   }
  }
 } finally {
  Remove-Item -LiteralPath $Mode5StableSegmentLabelsPath -Force -ErrorAction SilentlyContinue
 }
}

$mode3RelocatedCodeStart = 0
$mode3RelocatedCodeEnd = 0
$mode3LowSegmentEnd = 0
$mode3MiddleStart = 0
$mode3MiddleEnd = 0
$mode3HighCodeStart = 0
$mode3HighCodeEnd = 0
$mode3RuntimeBufferEnd = 0
$mode3GroundStaticStart = 0
$mode3GroundStaticEnd = 0
if ($Mode3HighBasicFullRasterRelocationFlag -ne 0) {
 try {
  $segmentLabels = Get-Content -LiteralPath $Mode3HighBasicSegmentLabelsPath
  $mode3LabelValues = @{}
  foreach ($labelName in @("mode3_high_basic_low_segment_end", "mode3_high_basic_middle_start", "mode3_high_basic_middle_end", "mode3_high_basic_relocated_code_start", "mode3_high_basic_relocated_code_end", "mode3_high_basic_high_code_start", "mode3_high_basic_high_code_end", "RUNTIME_BUFFER_COLOR_POLICY_END")) {
   $labelLine = @($segmentLabels | Where-Object { $_ -match ("^" + [regex]::Escape($labelName) + "\s*=") })
   if ($labelLine.Count -ne 1) {
    throw "64tass did not emit the required Mode 3 high-basic label: $labelName"
   }
   $labelValueText = (($labelLine[0] -split "=", 2)[1]).Trim()
   $mode3LabelValues[$labelName] = if ($labelValueText.StartsWith('$')) { [Convert]::ToInt32($labelValueText.Substring(1), 16) } else { [int]$labelValueText }
  }
  $mode3LowSegmentEnd = [int]$mode3LabelValues["mode3_high_basic_low_segment_end"]
  $mode3MiddleStart = [int]$mode3LabelValues["mode3_high_basic_middle_start"]
  $mode3MiddleEnd = [int]$mode3LabelValues["mode3_high_basic_middle_end"]
  $mode3RelocatedCodeStart = [int]$mode3LabelValues["mode3_high_basic_relocated_code_start"]
  $mode3RelocatedCodeEnd = [int]$mode3LabelValues["mode3_high_basic_relocated_code_end"]
  $mode3HighCodeStart = [int]$mode3LabelValues["mode3_high_basic_high_code_start"]
  $mode3HighCodeEnd = [int]$mode3LabelValues["mode3_high_basic_high_code_end"]
  $mode3RuntimeBufferEnd = [int]$mode3LabelValues["RUNTIME_BUFFER_COLOR_POLICY_END"]
  if ($WorldGroundMode3StaticLowFlag -ne 0) {
   foreach ($labelName in @("world_ground_mode3_static_low_start", "world_ground_mode3_static_low_end")) {
    $labelLine = @($segmentLabels | Where-Object { $_ -match ("^" + [regex]::Escape($labelName) + "\s*=") })
    if ($labelLine.Count -ne 1) {
     throw "64tass did not emit the required Mode 3 plane Ground label: $labelName"
    }
    $labelValueText = (($labelLine[0] -split "=", 2)[1]).Trim()
    $mode3LabelValues[$labelName] = if ($labelValueText.StartsWith('$')) { [Convert]::ToInt32($labelValueText.Substring(1), 16) } else { [int]$labelValueText }
   }
   $mode3GroundStaticStart = [int]$mode3LabelValues["world_ground_mode3_static_low_start"]
   $mode3GroundStaticEnd = [int]$mode3LabelValues["world_ground_mode3_static_low_end"]
  }

  if ($mode3LowSegmentEnd -le $load -or $mode3LowSegmentEnd -gt 0x2000) {
   throw ("Mode 3 low code is outside its safe window: {0:X4}-{1:X4}, required=0801-1FFF." -f $load, ($mode3LowSegmentEnd - 1))
  }
  if ($mode3MiddleStart -ne 0x4000 -or $mode3MiddleEnd -le $mode3MiddleStart -or $mode3MiddleEnd -gt 0x5C00) {
   throw ("Mode 3 middle code is outside its safe window: {0:X4}-{1:X4}, required=4000-5BFF." -f $mode3MiddleStart, ($mode3MiddleEnd - 1))
  }
  if ($mode3RelocatedCodeStart -lt 0x9000 -or $mode3RelocatedCodeEnd -gt 0xA000 -or $mode3RelocatedCodeEnd -le $mode3RelocatedCodeStart) {
   throw ("Mode 3 relocated raster is outside its safe window: {0:X4}-{1:X4}, required=9000-9FFF." -f $mode3RelocatedCodeStart, ($mode3RelocatedCodeEnd - 1))
  }
  if ($mode3HighCodeStart -ne 0xA000 -or $mode3HighCodeEnd -gt 0xD000 -or $mode3HighCodeEnd -le $mode3HighCodeStart) {
   throw ("Mode 3 high code is outside its safe window: {0:X4}-{1:X4}, required=A000-CFFF." -f $mode3HighCodeStart, ($mode3HighCodeEnd - 1))
  }
  if ($WorldGroundMode3StaticLowFlag -ne 0 -and ($mode3GroundStaticStart -ne $mode3RuntimeBufferEnd -or $mode3GroundStaticEnd -le $mode3GroundStaticStart -or $mode3GroundStaticEnd -gt $mode3RelocatedCodeStart)) {
   throw ("Mode 3 plane Ground static code is outside its safe window: {0:X4}-{1:X4}, required={2:X4}-{3:X4}." -f $mode3GroundStaticStart, ($mode3GroundStaticEnd - 1), $mode3RuntimeBufferEnd, ($mode3RelocatedCodeStart - 1))
  }

  $mode3ProtectedRanges = @(
   [pscustomobject]@{ Name = "screen B"; Start = $ScreenBBase; End = $ScreenBBase + 0x0400 },
   [pscustomobject]@{ Name = "bitmap B"; Start = $BitmapBBase; End = $BitmapBBase + 0x2000 },
   [pscustomobject]@{ Name = "screen A"; Start = 0x5C00; End = 0x6000 },
   [pscustomobject]@{ Name = "bitmap A"; Start = 0x6000; End = 0x8000 },
   [pscustomobject]@{ Name = "runtime buffer"; Start = 0x8000; End = $mode3RuntimeBufferEnd },
   [pscustomobject]@{ Name = "high code"; Start = $mode3HighCodeStart; End = $mode3HighCodeEnd }
  )
  if ($FpsOverlayEnableFlag -ne 0) {
   $mode3ProtectedRanges += [pscustomobject]@{ Name = "FPS charset"; Start = $FpsCharsetBase; End = $FpsCharsetBase + $FpsCharsetReservedSize }
   $mode3ProtectedRanges += [pscustomobject]@{ Name = "FPS screen"; Start = $FpsTextBase; End = $FpsTextBase + $FpsTextReservedSize }
  }
  $mode3CodeRanges = @(
   [pscustomobject]@{ Name = "low code"; Start = $load; End = $mode3LowSegmentEnd },
   [pscustomobject]@{ Name = "middle code"; Start = $mode3MiddleStart; End = $mode3MiddleEnd },
   [pscustomobject]@{ Name = "relocated raster"; Start = $mode3RelocatedCodeStart; End = $mode3RelocatedCodeEnd },
   [pscustomobject]@{ Name = "high code/data"; Start = $mode3HighCodeStart; End = $mode3HighCodeEnd }
  )
  if ($WorldGroundMode3StaticLowFlag -ne 0) {
   $mode3CodeRanges += [pscustomobject]@{ Name = "plane Ground static code"; Start = $mode3GroundStaticStart; End = $mode3GroundStaticEnd }
  }
  foreach ($codeRange in $mode3CodeRanges) {
   foreach ($region in $mode3ProtectedRanges) {
    if ($codeRange.Name -eq "high code/data" -and $region.Name -eq "high code") { continue }
    if ($codeRange.Start -lt [int]$region.End -and [int]$region.Start -lt $codeRange.End) {
     throw ("Mode 3 {0} overlaps {1}: code={2:X4}-{3:X4}, region={4:X4}-{5:X4}." -f $codeRange.Name, $region.Name, $codeRange.Start, ($codeRange.End - 1), [int]$region.Start, ([int]$region.End - 1))
    }
   }
  }
 } finally {
  Remove-Item -LiteralPath $Mode3HighBasicSegmentLabelsPath -Force -ErrorAction SilentlyContinue
 }
}

# In DEV7 the header screen and compact charset intentionally live inside the
# two engine video buffers. The layout-specific segment checks below, together
# with Assert-FpsMemoryContract, replace the old external-overlay PRG overlap
# test.

if ($HighBasicV2LayoutFlag -eq 0) {
 if ($lowSegmentEnd -gt 0x5C00) {
 throw ("PRG low segment overlaps video buffer A: ExclusiveEnd={0:X4}, first video byte=5C00. Disable optional features or rebuild explicitly with -MemoryLayout high-basic-v2; layout selection is never automatic." -f $lowSegmentEnd)
 }
 if ($Mode5StableRelocatedCodeFlag -ne 0) {
  if ($mode5StableCodeStart -lt 0x9100) {
   throw ("Mode 5 stable code overlaps the screen B guard: Start={0:X4}, required minimum=9100. Rebuild explicitly with -MemoryLayout high-basic-v2; layout selection is never automatic." -f $mode5StableCodeStart)
  }
  if ($mode5StableCodeEnd -gt 0x9F00) {
   throw ("Mode 5 stable code leaves less than 256 bytes before bitmap B: ExclusiveEnd={0:X4}, maximum=9F00. Rebuild explicitly with -MemoryLayout high-basic-v2; layout selection is never automatic." -f $mode5StableCodeEnd)
  }
 }
 if ($CameraPlaneStableRelocatedCodeFlag -ne 0) {
  if ($cameraPlaneCullCodeStart -ne 0x9500) {
   throw ("Camera-plane cull stable code has an unexpected start: Start={0:X4}, required=9500." -f $cameraPlaneCullCodeStart)
  }
  if ($cameraPlaneCullCodeEnd -gt 0x9F00) {
   throw ("Camera-plane cull stable code leaves less than 256 bytes before bitmap B: ExclusiveEnd={0:X4}, maximum=9F00." -f $cameraPlaneCullCodeEnd)
  }
 }
} else {
 if ($end -ge 0xD000) {
 throw ("High-basic-v2 PRG overlaps RAM-under-I/O contract: End={0:X4}, first reserved byte=D000. Reduce data or add loader segmentation." -f $end)
 }
}
$sha = (Get-FileHash -Algorithm SHA256 -LiteralPath $PrgPath).Hash
Write-Host ("Generated {0}" -f $AsmPath)
Write-Host ("Generated {0}" -f $PrgPath)
if ($HighBasicV2LayoutFlag -eq 0) {
 $videoMargin = 0x5C00 - $lowSegmentEnd
 if ($StableRelocatedCodeFlag -ne 0) {
  $lowSegmentSize = $lowSegmentEnd - $load
  $mode5StableCodeSize = if ($Mode5StableRelocatedCodeFlag -ne 0) { $mode5StableCodeEnd - $mode5StableCodeStart } else { 0 }
  $cameraPlaneCullCodeSize = if ($CameraPlaneStableRelocatedCodeFlag -ne 0) { $cameraPlaneCullCodeEnd - $cameraPlaneCullCodeStart } else { 0 }
  $effectiveSegmentSize = $lowSegmentSize + $mode5StableCodeSize + $cameraPlaneCullCodeSize
  $highRelocatedCodeEnd = [Math]::Max($mode5StableCodeEnd, $cameraPlaneCullCodeEnd)
  $highRelocatedCodeMargin = 0xA000 - $highRelocatedCodeEnd
  Write-Host ("LoadAddress={0:X4} FileExclusiveEnd={1:X4} FileLastLoaded={2:X4} FileSize={3} EffectiveSegmentSize={4} LowSegment={0:X4}-{5:X4} LowSegmentSize={6} MarginBefore5C00={7} Mode5CodeSegment={8:X4}-{9:X4} Mode5CodeSegmentSize={10} CameraPlaneCullSegment={11:X4}-{12:X4} CameraPlaneCullSegmentSize={13} MarginBeforeA000={14} SHA256={15}" -f $load, $end, $lastLoaded, $bytes.Length, $effectiveSegmentSize, ($lowSegmentEnd - 1), $lowSegmentSize, $videoMargin, $mode5StableCodeStart, ($mode5StableCodeEnd - 1), $mode5StableCodeSize, $cameraPlaneCullCodeStart, ($cameraPlaneCullCodeEnd - 1), $cameraPlaneCullCodeSize, $highRelocatedCodeMargin, $sha)
 } else {
  Write-Host ("LoadAddress={0:X4} ExclusiveEnd={1:X4} LastLoaded={2:X4} Size={3} MarginBefore5C00={4} SHA256={5}" -f $load, $end, $lastLoaded, $bytes.Length, $videoMargin, $sha)
 }
} else {
 Write-Host ("LoadAddress={0:X4} ExclusiveEnd={1:X4} LastLoaded={2:X4} Size={3} SHA256={4}" -f $load, $end, $lastLoaded, $bytes.Length, $sha)
 if ($Mode3HighBasicFullRasterRelocationFlag -ne 0) {
  $relocatedSize = $mode3RelocatedCodeEnd - $mode3RelocatedCodeStart
  $relocatedMargin = 0xA000 - $mode3RelocatedCodeEnd
  $runtimeMargin = $mode3RelocatedCodeStart - $mode3RuntimeBufferEnd
  Write-Host ("Mode 3 full raster relocated: low={0:X4}-{1:X4} middle={2:X4}-{3:X4} segment={4:X4}-{5:X4} bytes={6} marginBeforeA000={7} runtimeEnd={8:X4} runtimeMargin={9} highSegment={10:X4}-{11:X4}; reason=ordinary mobile high-basic-v2 raster exceeds D000 without relocation." -f $load, ($mode3LowSegmentEnd - 1), $mode3MiddleStart, ($mode3MiddleEnd - 1), $mode3RelocatedCodeStart, ($mode3RelocatedCodeEnd - 1), $relocatedSize, $relocatedMargin, $mode3RuntimeBufferEnd, $runtimeMargin, $mode3HighCodeStart, ($mode3HighCodeEnd - 1))
 }
}
if ($FpsOverlayEnableFlag -ne 0) {
 Write-Host ("FPS overlay memory: charset={0:X4}-{1:X4} screen={2:X4}-{3:X4} D018={4:X2} underIO={5}" -f $FpsCharsetBase, ($FpsCharsetBase + $FpsCharsetReservedSize - 1), $FpsTextBase, ($FpsTextBase + $FpsTextReservedSize - 1), $FpsTextD018, $FpsOverlayUnderIoLayoutFlag)
} elseif ($FpsCounterOnlyFlag -ne 0) {
 Write-Host "FPS counter-only active: inspect fps_last_value and fps_last_tenths in the generated symbols/VICE monitor."
}
Write-Host ("Run: {0}" -f (Join-Path $Root "run-3Dvibe64-vice.cmd"))

exit 0
