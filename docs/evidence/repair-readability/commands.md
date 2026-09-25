# Commands and result interpretation

Working directory: `C:/Users/Raph/Documents/ChatGPT/Scrap saint/source`. PowerShell; pinned Godot 4.5.1. Native and test processes used separate APPDATA directories under ignored artifacts, preserving normal player saves. The final source hashes are in provenance.json; the exported files have their own BUILD.json and SHA256SUMS.txt.

```powershell
$godot = '../.runtime/godot/Godot_v4.5.1-stable_win64_console.exe'
$python = 'C:/Users/Raph/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
$env:APPDATA = Join-Path (Get-Location) 'artifacts/iteration-userdata'
New-Item -ItemType Directory -Force $env:APPDATA | Out-Null
& ./scripts/agent_iteration.ps1 -GodotBin $godot -PythonBin $python
```

Result: exit 0; content validation, 34 Python tests, all runner suites, all five policy matrices and native captures completed. The loop started before the final hazard-layout correction. The simulation and content did not change, so the policy outcomes remain applicable. Final verification below covers the presentation corrections; do not describe every first-loop frame as a final-layout capture.

```powershell
$env:APPDATA = Join-Path (Get-Location) 'artifacts/final-check-userdata'
New-Item -ItemType Directory -Force $env:APPDATA,artifacts/final-checks | Out-Null
foreach ($suite in (Get-ChildItem tests/test_*.gd | Sort-Object Name)) {
    & $godot --headless --path . --script $suite.FullName *> "artifacts/final-checks/$($suite.BaseName).log"
    if ($LASTEXITCODE -ne 0) { exit 1 }
}
# Repeated after the separate Save & Title / Gift-layout correction:
& $godot --headless --path . --script tests/test_flow_input.gd
& $godot --headless --path . --script tests/test_save_flow.gd
```

Result: all 33 suites exited 0. Exact per-suite assertion counts are in validation.json and logs/. Two asset validators report asset coverage rather than assertion totals. ObjectDB exit warnings in fixtures are retained, not counted as clean shutdowns.

```powershell
$env:APPDATA = (New-Item -ItemType Directory -Force artifacts/repair-readability-userdata).FullName
& $godot --path . --resolution 1280x800 --script tests/capture_repair_readability.gd
& $godot --path . --resolution 1920x1080 --script tests/capture_repair_readability.gd -- --capture-size=1920x1080
```

Result: both exited 0; 60 configured frames per window, each checking unchanged state hash after rendering. The first window saves 1280x800 PNGs; the 1920x1080 window saves a 1728x1080 content raster. Final Foreman captures were inspected at both sizes; they supersede the earlier ring/title collision.

```powershell
& $godot --headless --path . --export-release 'Windows Desktop' build/releases/scrap-saint-0.6.0-preview-20260925/windows/ScrapSaint.exe
$env:APPDATA = (New-Item -ItemType Directory -Force artifacts/final-package-delivery-userdata).FullName
$gameExe = (Resolve-Path build/releases/scrap-saint-0.6.0-preview-20260925/windows/ScrapSaint.exe).Path
$qaScript = (Resolve-Path docs/evidence/repair-readability/package_capture.gd).Path
$qaLog = Join-Path (Get-Location) 'artifacts/package-natural.log'
$qaOutput = (Join-Path (Get-Location) 'artifacts/package-natural').Replace('\','/')
$process = Start-Process -FilePath $gameExe -ArgumentList @('--resolution','1280x800','--script',('"'+$qaScript+'"'),'--log-file',('"'+$qaLog+'"'),'--',('"--package-output='+$qaOutput+'"')) -WindowStyle Hidden -PassThru -Wait
$process.ExitCode
```

Result: export and native packaged run exit 0. The external QA harness uses packaged game resources, the existing normal-economy policy, existing start/lifecycle handlers and the real Results button. It captures title, shop, a two-Gift shop, site clear, map, road, arrival, Results and restart. It does not inject boss victories or award economy. Seed 147 wins after 12 shops; the restart shows earned unlocks. This is accelerated fixed-tick automated play, not a human 1x session.

The ordinary exported executable was also launched with `--quit-after 180` and a log file, without a script or development flags; the native Compatibility renderer initialized successfully. External `tests/test_flow_input.gd` against the package verifies synthetic UI activation separately; its boss-completion shortcuts are fixture behavior, not the natural-run policy.

```powershell
& $python tools/validate_iteration_report.py --bundle artifacts/agent-iteration --require-scored
git diff --check
```

The scored evidence check validates the required capture bundle and ten-row rubric; it does not certify game feel. Final source/capture hashes, export artifact hashes, document links and Git whitespace were checked before delivery.

Final wrapped delivery: ordinary native boot exit 0, external packaged flow test 107 checks/0 failures, ZIP CRC integrity passed. package-build.json and package-archive.json record source, executable/PCK and archive SHA-256 values. Work is paused at the user’s request.
