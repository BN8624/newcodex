# BUILD_REPORT.md

## 1. Game Title and Concept

Moonwell Vanguard is a 540x960 vertical idle RPG where a moon guardian auto-battles through the Moonwell Ruins, buys growth upgrades, and clears the Moonbound Colossus boss.

## 2. Implemented Systems

- Godot 4.x project with `scenes/Main.tscn` as the main scene.
- Mobile-first 540x960 UI with title/status, battleground, HP bars, progress, gold, power, and upgrade controls.
- Automatic player attacks, enemy pressure, player HP restoration on defeat, hit flash, lunge, shake, and floating damage numbers.
- 15-stage first region with four rotating normal enemies and one stage 15 boss.
- Gold and EXP rewards, player level growth, stage progress, boss clear banner, and post-clear placeholder target.
- Five upgrade buttons with level, cost scaling, affordability state, and immediate stat impact.
- Local JSON save/load, autosave, manual save, reset/new game, `save_version`, and capped offline gold reward.
- `--verify` mode for core state tests.

## 3. File/Folder Structure

- `project.godot`
- `export_presets.cfg`
- `scenes/Main.tscn`
- `scripts/Main.gd`
- `scripts/GameState.gd`
- `scripts/GameData.gd` equivalent data source at `data/game_data.gd`
- `scripts/CombatController.gd`
- `scripts/UIController.gd`
- `scripts/SaveManager.gd`
- `scripts/Effects.gd`
- `scripts/Verifier.gd`
- `assets/placeholders/`
- `assets/ui/`
- `PRODUCT_SPEC.md`
- `checklist.md`
- `context-notes.md`

## 4. Current 3-Minute Play Flow

The player opens the game, sees the title, stage, gold, power, HP bars, enemy, hero, and five growth buttons. Combat starts automatically, enemies take visible damage, rewards pop up after defeats, stage progress advances after three kills, upgrades become affordable quickly, and the boss appears at stage 15.

## 5. Save/Load Behavior

The game loads `user://moonwell_vanguard_save.json` on start when present. It saves after upgrades, enemy rewards, boss clear, manual save, periodic autosave, and close request. Offline reward uses `last_play_time` with a 2-hour cap.

## 6. How to Run

Open `C:\Users\USER\newcodex\project.godot` in Godot 4.7 and run the main scene.

CLI run command:

```powershell
& 'C:\Users\USER\godot-engine\Godot_v4.7-stable_win64_console.exe' --path 'C:\Users\USER\newcodex'
```

Verification command:

```powershell
& 'C:\Users\USER\godot-engine\Godot_v4.7-stable_win64_console.exe' --headless --path 'C:\Users\USER\newcodex' -- --verify
```

## 7. Web Build Status

`export_presets.cfg` includes a Web preset targeting `build/web/index.html`. Actual Web export was attempted but failed because Godot 4.7 Web export templates are not installed.

Missing templates reported by Godot:

- `C:/Users/USER/AppData/Roaming/Godot/export_templates/4.7.stable/web_nothreads_debug.zip`
- `C:/Users/USER/AppData/Roaming/Godot/export_templates/4.7.stable/web_nothreads_release.zip`

After installing Godot 4.7 export templates, run:

```powershell
New-Item -ItemType Directory -Force build\web | Out-Null
& 'C:\Users\USER\godot-engine\Godot_v4.7-stable_win64_console.exe' --headless --path 'C:\Users\USER\newcodex' --export-release 'Web' 'C:\Users\USER\newcodex\build\web\index.html'
```

## 8. Verification Performed

- Project load check passed:

```powershell
& 'C:\Users\USER\godot-engine\Godot_v4.7-stable_win64_console.exe' --headless --path 'C:\Users\USER\newcodex' --quit-after 1 --verbose
```

- Core verifier passed:

```text
PASS: initial state valid
PASS: upgrade purchase changes stat
PASS: enemy defeat gives gold
PASS: stage progression works
PASS: boss clear sets clear state
PASS: save data roundtrip works
VERIFY_RESULT: passed
```

- Web export attempted and failed only because export templates are missing.

## 9. Known Missing Features

Inventory, equipment, gacha, skill trees, quests, monetization, login, cloud save, rankings, full audio, generated screenshots, and final art assets are intentionally excluded from v0.1.

## 10. Next One-Click Sprint Recommendation

Install Godot 4.7 Web export templates, export the Web build, then add a small skill cooldown button and a second region data slice without changing the save format.
