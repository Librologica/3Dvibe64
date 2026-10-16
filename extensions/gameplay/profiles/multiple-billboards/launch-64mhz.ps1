param([switch]$Verify)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $MyInvocation.MyCommand.Path
$taskVice=$env:VICE_TURBO6510
if(-not $taskVice){$taskVice='C:\Users\rapso\Documents\ChatGPT\VICE Fork\vice-turbo6510\dist\Turbo6510-x64sc\bin\x64sc_u.exe'}
$taskPrg=Join-Path $taskRoot 'artifacts\room-skeleton-billboard-precise-pal-multiple-billboards.prg'
$taskPalette=Join-Path $taskRoot 'assets\colodore.vpl'
foreach($taskFile in @($taskVice,$taskPrg,$taskPalette)){if(-not(Test-Path -LiteralPath $taskFile -PathType Leaf)){throw "Missing $taskFile"}}
$taskArguments=@('-default','-pal','-turbo6510','64','-autostartprgmode','1','+sound','-VICIIfilter','0','-VICIIextpal','-VICIIpalette',('"'+$taskPalette+'"'),('"'+$taskPrg+'"'))
if($Verify){
    # Exercise this actual launcher with Windows PowerShell, then quit after
    # a complete presented frame. No changes to the PRG or rendering options.
    $taskProof=Join-Path $taskRoot 'reports\launcher-smoke'
    New-Item -ItemType Directory -Path $taskProof -Force | Out-Null
    $taskLabels=(Join-Path $taskRoot 'room\build\multiple-billboards\3Dvibe64.labels').Replace('\','/')
    $taskCapture=(Join-Path $taskProof 'native.png').Replace('\','/')
    $taskMonitor=Join-Path $taskProof 'commands.mon'
    @("load_labels `"$taskLabels`"",'break exec .fps_frame_done','ignore 1 2','x',"screenshot `"$taskCapture`" 2",'quit') | Set-Content -LiteralPath $taskMonitor -Encoding Ascii
    $taskArguments=@('+confirmonexit','-console','-warp','-initbreak','ready','-moncommands',('"'+$taskMonitor+'"'))+$taskArguments
    # Keep -default first: it must precede all overrides.
    $taskArguments=@('-default')+@($taskArguments | Where-Object {$_ -ne '-default'})
    $taskProcess=Start-Process -FilePath $taskVice -ArgumentList $taskArguments -WorkingDirectory (Split-Path -Parent $taskVice) -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput (Join-Path $taskProof 'stdout.log') -RedirectStandardError (Join-Path $taskProof 'stderr.log')
    if($taskProcess.ExitCode -ne 0 -or -not(Test-Path -LiteralPath $taskCapture)){throw 'VICE launch verification failed; see reports\launcher-smoke'}
    Write-Host 'Avvio verificato: tre fotogrammi completi catturato da VICE.'
}else{
    # Visible emulator when the user explicitly invokes this launcher.
    Start-Process -FilePath $taskVice -ArgumentList $taskArguments -WorkingDirectory (Split-Path -Parent $taskVice)
}
