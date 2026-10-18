param(
    [ValidateSet('comparison-ui','dungeon-masked','mixed-surfaces','interactive-billboard','door-entity','multiple-billboards','animated-textures','static-light','sector-visibility','shared-meshes','controlled-animation','camera-roll','room-groups')][string]$Profile='comparison-ui',
    [Parameter(Mandatory=$true)][string]$OutputDirectory,
    [Parameter(Mandatory=$true)][string]$ProjectSource,
    [string]$SurfaceConfig,
    [string]$GameplayScene,
    [string]$DoorConfig,
    [string]$TextureAnimation,
    [string]$LightBake,
    [string]$Visibility,
    [string]$SharedMeshes,
    [string]$MotionControls,
    [string]$WorldGroups,
    [switch]$FlatSpanCache
)
$ErrorActionPreference='Stop'
$taskBuildArgs=@('-B',(Join-Path $PSScriptRoot 'build-gameplay.py'),'--profile',$Profile,'--out',$OutputDirectory,'--project-source',$ProjectSource)
if($SurfaceConfig){$taskBuildArgs+=@('--surface-config',$SurfaceConfig)}
if($GameplayScene){$taskBuildArgs+=@('--gameplay-scene',$GameplayScene)}
if($DoorConfig){$taskBuildArgs+=@('--door-config',$DoorConfig)}
if($TextureAnimation){$taskBuildArgs+=@('--texture-animation',$TextureAnimation)}
if($LightBake){$taskBuildArgs+=@('--light-bake',$LightBake)}
if($Visibility){$taskBuildArgs+=@('--visibility',$Visibility)}
if($SharedMeshes){$taskBuildArgs+=@('--shared-meshes',$SharedMeshes)}
if($MotionControls){$taskBuildArgs+=@('--motion-controls',$MotionControls)}
if($WorldGroups){$taskBuildArgs+=@('--world-groups',$WorldGroups)}
if($FlatSpanCache){$taskBuildArgs+=@('--flat-span-cache')}
& python @taskBuildArgs
if($LASTEXITCODE -ne 0){exit $LASTEXITCODE}
