@echo off
set "SCRAP_GODOT=%~dp0..\.runtime\godot\Godot_v4.5.1-stable_win64.exe"
if exist "%SCRAP_GODOT%" (
    start "Scrap Saint" "%SCRAP_GODOT%" --path "%~dp0."
) else (
    echo Open project.godot with Godot 4.5.1, or set GODOT_BIN to the Godot executable.
    if defined GODOT_BIN (
        start "Scrap Saint" "%GODOT_BIN%" --path "%~dp0."
    ) else (
        pause
    )
)
