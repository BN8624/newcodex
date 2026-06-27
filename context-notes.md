# Context Notes

## 2026-06-27

- Workspace started with only `AGENTS.md`; Git is not initialized.
- Chosen game concept: `Moonwell Vanguard`, a vertical idle RPG about a small guardian clearing moonlit ruins.
- Scope is fixed to one region, 15 stages, 5 upgrades, 4 normal enemy types, one boss, local save, and simple offline gold.
- Boss naming uses `Moonbound Colossus` to keep the temporary art direction generic and replaceable.
- Implementation will favor dynamic UI from `Main.gd` to keep `Main.tscn` small while still separating game data, state, combat, save, effects, and verification scripts.
- Godot 4.7 console executable was found at `C:\Users\USER\godot-engine\Godot_v4.7-stable_win64_console.exe`.
- `godot --headless --path ... -- --verify` passed after removing fragile custom type annotations and Variant inference warnings.

## 2026-06-27 Release-Candidate Correction

- The previous build was only an MVP/playtest scaffold and was not acceptable as a user-facing release candidate.
- Immediate correction scope: improve the first screen, make the combat view feel like a complete idle RPG screen, add safer reset UX, make stage/boss/reward communication clearer, update Web playtest packaging, verify on HTTPS mobile viewport, then commit and push.
- No new external art or paid services will be introduced; polish stays in-engine so the project remains self-contained.
- Added `BattleActorView.gd` to draw hero, enemy, boss, and clear-gate silhouettes in-engine.
- Updated the main screen with an auto-battle badge, stage goal badge, enemy tag, stage path, clearer shop copy, and two-tap reset.
- Rebuilt the Web playtest pack at `build/web/index.pck`, served through Tailscale HTTPS, and verified mobile viewport load at `https://node.tail3e9e21.ts.net:10000`.
