@echo off
set "SCRAP_GODOT=%~dp0..\.runtime\godot\Godot_v4.5.1-stable_win64.exe"
if exist "%SCRAP_GODOT%" (
    start "Scrap Saint - 5x Dev" "%SCRAP_GODOT%" --path "%~dp0." -- --dev-speed=5
) else (
    if defined GODOT_BIN (
        start "Scrap Saint - 5x Dev" "%GODOT_BIN%" --path "%~dp0." -- --dev-speed=5
    ) else (
        echo Set GODOT_BIN to your Godot 4.5.1 executable, then run this launcher again.
        pause
    )
)
