param(
    [string]$GodotBin = "$PSScriptRoot\..\..\.runtime\godot\Godot_v4.5.1-stable_win64_console.exe",
    [string]$PythonBin = "python"
)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path "$PSScriptRoot\..").Path
$bundlePath = Join-Path $projectRoot 'artifacts\agent-iteration'
New-Item -ItemType Directory -Path $bundlePath -Force | Out-Null
& $PythonBin "$PSScriptRoot\validate_content.py"
if ($LASTEXITCODE -ne 0) { throw 'Content validation failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_repair_quality.gd 2>&1 | Tee-Object -FilePath "$bundlePath\repair_quality.log"
if ($LASTEXITCODE -ne 0) { throw 'Repair quality tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_winch.gd 2>&1 | Tee-Object -FilePath "$bundlePath\winch.log"
if ($LASTEXITCODE -ne 0) { throw 'Winch tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_relic_shop.gd 2>&1 | Tee-Object -FilePath "$bundlePath\relic_shop.log"
if ($LASTEXITCODE -ne 0) { throw 'Relic shop tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_variety.gd 2>&1 | Tee-Object -FilePath "$bundlePath\variety.log"
if ($LASTEXITCODE -ne 0) { throw 'Variety tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_optional_repairs.gd 2>&1 | Tee-Object -FilePath "$bundlePath\optional.log"
if ($LASTEXITCODE -ne 0) { throw 'Optional repair tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_shop.gd 2>&1 | Tee-Object -FilePath "$bundlePath\shop.log"
if ($LASTEXITCODE -ne 0) { throw 'Shop tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_relay.gd 2>&1 | Tee-Object -FilePath "$bundlePath\relay.log"
if ($LASTEXITCODE -ne 0) { throw 'Relay tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_arena.gd 2>&1 | Tee-Object -FilePath "$bundlePath\arena.log"
if ($LASTEXITCODE -ne 0) { throw 'Arena tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_simulation.gd 2>&1 | Tee-Object -FilePath "$bundlePath\simulation.log"
if ($LASTEXITCODE -ne 0) { throw 'Simulation tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_ui.gd 2>&1 | Tee-Object -FilePath "$bundlePath\ui.log"
if ($LASTEXITCODE -ne 0) { throw 'UI tests failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_sacred_ledger.gd 2>&1 | Tee-Object -FilePath "$bundlePath\sacred_ledger.log"
if ($LASTEXITCODE -ne 0) { throw 'Sacred ledger state/capture checks failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/run_playthroughs.gd -- --optional 2>&1 | Tee-Object -FilePath "$bundlePath\playthroughs.log"
if ($LASTEXITCODE -ne 0) { throw 'Playthrough runner failed' }
& $GodotBin --path $projectRoot -- --capture-dir=$bundlePath 2>&1 | Tee-Object -FilePath "$bundlePath\capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Capture failed' }
$commitId = git -C $projectRoot rev-parse HEAD
$godotVersion = & $GodotBin --version
$files = Get-ChildItem -LiteralPath "$projectRoot\game" -Filter '*.gd' | ForEach-Object { @{ path = $_.Name; sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash } }
@{ build = '0.1.0'; base_commit = $commitId; dirty = [bool](git -C $projectRoot status --porcelain); godot = $godotVersion; viewport = @(1280,800); scaling = 'canvas_items'; seed = 147; timestamp_utc = [DateTime]::UtcNow.ToString('o'); capture_type = 'rendered simulation fixtures; includes explicit setup budgets and Results fixture'; source_hashes = @($files); limitation = 'No human playtest or performance benchmark'; next_task = 'Human playtest of the shared arena and build feedback' } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath "$bundlePath\provenance.json" -Encoding utf8
Write-Output "Bundle ready for visual review: $bundlePath"
