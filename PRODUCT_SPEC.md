# PRODUCT_SPEC.md

## 1. Game Title

Moonwell Vanguard

## 2. One-Sentence Concept

A lone moon guardian automatically fights through ruined shrine stages, spends earned moon gold on growth, and defeats the sealed boss of the first region.

## 3. Core Loop

Open the game, watch automatic combat, earn Moon Gold and EXP from defeated enemies, buy immediate stat upgrades, advance through 15 stages, challenge the Moonbound Colossus boss, clear the region, and keep progress through local save.

## 4. 540x960 Screen Layout

- Top 0-150: title, stage, player level, gold, power, and progress.
- Center 150-620: gradient battleground, hero silhouette, enemy silhouette, HP bars, damage numbers, reward popups, boss warning, and clear banner.
- Bottom 620-960: five upgrade buttons plus save and reset controls.

## 5. Upgrade List

- Moon Blade: increases attack damage.
- Guardian Heart: increases max HP.
- Ward Plate: reduces incoming damage.
- Quick Ritual: increases attack speed.
- Gold Charm: increases gold earned.

## 6. Stage/Boss Structure

- One region: Moonwell Ruins.
- Stages 1-14 rotate four normal enemy types.
- Each stage requires three enemy defeats to advance.
- Stage 15 is the boss encounter against the Moonbound Colossus.
- Boss clear marks v0.1 complete and shows a next-region placeholder.

## 7. Save Data Structure

- `save_version`
- `gold`
- `player_level`
- `exp`
- `current_stage`
- `current_enemy_progress`
- `upgrade_levels`
- `boss_clear_state`
- `last_play_time`
- `settings`

## 8. v0.1 Scope

- Godot 4.x project targeting Web export.
- Portrait 540x960 layout.
- Automatic combat with enemy pressure.
- Damage numbers, hit flash, lunge feedback, reward popup, and boss clear popup.
- Five upgrade buttons with scaling costs.
- Local save/load, manual save, reset, periodic autosave, and capped offline reward.
- Verification script for core state behavior.
- In-engine drawn hero, enemy, boss, and clear target silhouettes so the first screen reads as a complete mobile idle RPG instead of a raw UI test.
- Safer two-tap reset flow for public playtest builds.

## 9. Explicitly Excluded Features

Inventory, equipment, gacha, character collection, skill tree, quests, multiple regions, ads, IAP, login, server, rankings, cloud save, daily missions, achievements, external art assets, and full audio are excluded from v0.1.

## 10. Next-Update Candidates

- Second region with two new enemy families.
- Lightweight equipment slots.
- Skill cooldown button.
- Generated simple sound effects.
- Second-region content slice and final store packaging.
