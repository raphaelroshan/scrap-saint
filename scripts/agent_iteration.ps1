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
& $PythonBin -m unittest discover -s "$projectRoot\tests" -p test_slice_manifest.py
if ($LASTEXITCODE -ne 0) { throw 'Manifest tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_main_menu.gd 2>&1 | Tee-Object -FilePath "$bundlePath\main-menu.log"
if ($LASTEXITCODE -ne 0) { throw 'Main menu tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_sync_contract.gd 2>&1 | Tee-Object -FilePath "$bundlePath\sync-contract.log"
if ($LASTEXITCODE -ne 0) { throw 'Sync contract tests failed' }
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
& $GodotBin --headless --path $projectRoot --script res://tests/test_chapter.gd 2>&1 | Tee-Object -FilePath "$bundlePath\chapter.log"
if ($LASTEXITCODE -ne 0) { throw 'Chapter tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_roaming_quality.gd 2>&1 | Tee-Object -FilePath "$bundlePath\roaming-quality.log"
if ($LASTEXITCODE -ne 0) { throw 'Roaming quality tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_ui.gd 2>&1 | Tee-Object -FilePath "$bundlePath\ui.log"
if ($LASTEXITCODE -ne 0) { throw 'UI tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_flow_input.gd 2>&1 | Tee-Object -FilePath "$bundlePath\flow-input.log"
if ($LASTEXITCODE -ne 0) { throw 'Flow input tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_save_flow.gd 2>&1 | Tee-Object -FilePath "$bundlePath\save-flow.log"
if ($LASTEXITCODE -ne 0) { throw 'Save flow tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_assembly.gd 2>&1 | Tee-Object -FilePath "$bundlePath\assembly.log"
if ($LASTEXITCODE -ne 0) { throw 'Assembly tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_acquisition.gd 2>&1 | Tee-Object -FilePath "$bundlePath\acquisition.log"
if ($LASTEXITCODE -ne 0) { throw 'Acquisition tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_evolutions.gd 2>&1 | Tee-Object -FilePath "$bundlePath\evolutions.log"
if ($LASTEXITCODE -ne 0) { throw 'Evolution tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_weapon_ranks.gd 2>&1 | Tee-Object -FilePath "$bundlePath\weapon-ranks.log"
if ($LASTEXITCODE -ne 0) { throw 'Weapon rank tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_weapon_presentation.gd 2>&1 | Tee-Object -FilePath "$bundlePath\weapon-presentation.log"
if ($LASTEXITCODE -ne 0) { throw 'Weapon presentation tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_presentation_quality.gd 2>&1 | Tee-Object -FilePath "$bundlePath\presentation-quality.log"
if ($LASTEXITCODE -ne 0) { throw 'Presentation quality tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/test_gift_breadth.gd 2>&1 | Tee-Object -FilePath "$bundlePath\gift-breadth.log"
if ($LASTEXITCODE -ne 0) { throw 'Gift breadth tests failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/run_playthroughs.gd -- --optional 2>&1 | Tee-Object -FilePath "$bundlePath\playthroughs.log"
if ($LASTEXITCODE -ne 0) { throw 'Playthrough runner failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/run_assembly_playthroughs.gd 2>&1 | Tee-Object -FilePath "$bundlePath\assembly-playthroughs.log"
if ($LASTEXITCODE -ne 0) { throw 'Assembly playthrough runner failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/run_evolution_playthroughs.gd 2>&1 | Tee-Object -FilePath "$bundlePath\evolution-playthroughs.log"
if ($LASTEXITCODE -ne 0) { throw 'Evolution playthrough runner failed' }
& $GodotBin --headless --path $projectRoot --script res://tests/run_gift_playthroughs.gd 2>&1 | Tee-Object -FilePath "$bundlePath\gift-playthroughs.log"
if ($LASTEXITCODE -ne 0) { throw 'Gift playthrough runner failed' }
& $GodotBin --path $projectRoot -- --capture-dir=$bundlePath 2>&1 | Tee-Object -FilePath "$bundlePath\capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_chapter.gd -- --capture-dir=$bundlePath 2>&1 | Tee-Object -FilePath "$bundlePath\chapter-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Chapter capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_core_quality.gd 2>&1 | Tee-Object -FilePath "$bundlePath\core-quality-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Core quality capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_assembly.gd 2>&1 | Tee-Object -FilePath "$bundlePath\assembly-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Assembly capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_evolutions.gd 2>&1 | Tee-Object -FilePath "$bundlePath\evolution-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Evolution capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_weapon_ranks.gd -- --capture-dir="$bundlePath" 2>&1 | Tee-Object -FilePath "$bundlePath\weapon-rank-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Weapon rank capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_weapon_animation.gd -- --capture-dir="$projectRoot\artifacts\weapon-animation" 2>&1 | Tee-Object -FilePath "$bundlePath\weapon-animation-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Weapon animation capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_manifested_nailer.gd -- --capture-dir="$projectRoot\artifacts\manifested-nailer" 2>&1 | Tee-Object -FilePath "$bundlePath\manifested-nailer-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Manifested Nailer capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_manifested_relics.gd -- --capture-dir="$projectRoot\artifacts\manifested-relics" 2>&1 | Tee-Object -FilePath "$bundlePath\manifested-relics-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Manifested relic capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_remaining_manifested_relics.gd -- --capture-dir="$projectRoot\artifacts\remaining-manifested-relics" 2>&1 | Tee-Object -FilePath "$bundlePath\remaining-manifested-relics-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Remaining manifested relic capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_game_feel.gd -- --capture-dir="$projectRoot\artifacts\game-feel" 2>&1 | Tee-Object -FilePath "$bundlePath\game-feel-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Game feel capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_gift_breadth.gd 2>&1 | Tee-Object -FilePath "$bundlePath\gift-breadth-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Gift breadth capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_sync_contract.gd 2>&1 | Tee-Object -FilePath "$bundlePath\sync-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Sync capture failed' }
& $GodotBin --path $projectRoot --script res://tests/capture_main_menu.gd 2>&1 | Tee-Object -FilePath "$bundlePath\main-menu-capture.log"
if ($LASTEXITCODE -ne 0) { throw 'Main menu capture failed' }
$commitId = git -C $projectRoot rev-parse HEAD
$godotVersion = & $GodotBin --version
$files = Get-ChildItem -LiteralPath "$projectRoot\game" -Filter '*.gd' | ForEach-Object { @{ path = $_.Name; sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash } }
@{ build = '0.6.0-preview'; base_commit = $commitId; dirty = [bool](git -C $projectRoot status --porcelain); godot = $godotVersion; viewport = @(1280,800); scaling = 'canvas_items'; seed = 147; timestamp_utc = [DateTime]::UtcNow.ToString('o'); capture_type = 'rendered simulation fixtures; includes explicit setup budgets, Results, weapon ranks, Evolutions, Gifts, destination bosses, and manifested relics'; source_hashes = @($files); limitation = 'No human playtest or rendered minimum-hardware benchmark'; next_task = 'Manifest the remaining short-lived relic families and stress-test four-weapon overlap at the actual gameplay camera' } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath "$bundlePath\provenance.json" -Encoding utf8
Write-Output "Bundle ready for visual review: $bundlePath"
