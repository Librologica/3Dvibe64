@echo off
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0launch-64mhz.ps1" %*
if errorlevel 1 (
  echo.
  echo Avvio non riuscito. Controllare il messaggio qui sopra.
  pause
  exit /b 1
)
