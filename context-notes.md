# Context Notes

## 2026-06-27

- Workspace started with only `AGENTS.md`; Git is not initialized.
- Chosen game concept: `Moonwell Vanguard`, a vertical idle RPG about a small guardian clearing moonlit ruins.
- Scope is fixed to one region, 15 stages, 5 upgrades, 4 normal enemy types, one boss, local save, and simple offline gold.
- Boss naming uses `Moonbound Colossus` to keep the temporary art direction generic and replaceable.
- Implementation will favor dynamic UI from `Main.gd` to keep `Main.tscn` small while still separating game data, state, combat, save, effects, and verification scripts.
- Godot 4.7 console executable was found at `C:\Users\USER\godot-engine\Godot_v4.7-stable_win64_console.exe`.
- `godot --headless --path ... -- --verify` passed after removing fragile custom type annotations and Variant inference warnings.
