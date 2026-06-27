# AGENTS.md

# Codex Project Agent — Small Commercial-Ready Vertical Idle RPG v0.1

## 0. Mission

You are starting in a completely empty folder.

Ignore all prior project assumptions, previous prototypes, old worldbuilding, old assets, old issues, and old task history.

Your job is to independently create a **small commercial-ready structure** for a vertical mobile idle RPG v0.1.

This is not a tech demo. This is not a one-screen toy. This is a small but coherent release-candidate foundation that could later become a real tiny commercial mobile/web game.

The user does not want to make many detailed decisions. You must choose the game concept, title, theme, UI wording, enemies, rewards, numbers, temporary art style, and implementation structure yourself.

Do not ask the user unless the decision affects the core system, save compatibility, release direction, paid services, server features, ads, monetization, or would greatly expand scope.

If it does not affect the system, decide it yourself and implement.

---

## 1. Core Goal

Create a small vertical idle RPG v0.1 with the following qualities:

```text
1. Looks like a mobile idle RPG within the first 10 seconds
2. Runs in 540×960 vertical layout
3. Has automatic combat
4. Has visible player growth
5. Has upgrade buttons that immediately feel impactful
6. Has stage progression
7. Has a boss encounter
8. Has clear/reward flow
9. Has save/load
10. Can be built for Web
11. Has a structure that can later be expanded into a small commercial game
```

Reference genre:

```text
Vertical mobile idle RPG similar in structure to games like Mushroom Go / idle growth RPGs.
```

Do not copy IP, characters, names, art, text, or branding from existing games. Only imitate genre structure: vertical screen, auto battle, growth buttons, currency gain, stage progress, boss challenge, reward popups, repeatable progression, dense mobile UI.

---

## 2. User Preference

The user wants a “click once and make it” workflow.

Do not ask about:

```text
game title
world setting
protagonist
enemy names
boss name
currency name
stage name
upgrade names
button labels
colors
panel placement
temporary art style
placeholder shapes
simple visual effects
reward text
number formatting
minor layout choices
```

Ask only if:

```text
save format must be broken
project direction would change greatly
monetization / ads / login / server are involved
implementation scope becomes much larger than v0.1
a choice would significantly increase development time
an existing important system would have to be discarded
```

Decision rule:

```text
If it does not affect the system, do not ask.
If it can be changed later, do not ask.
If the game can continue without asking, do not ask.
Make a reasonable decision and implement.
```

---

## 3. Technology Target

Use Godot 4.x and GDScript.

The project must be suitable for Web export.

Create a normal Godot project from this empty folder.

Expected root structure:

```text
project.godot
AGENTS.md
PRODUCT_SPEC.md
BUILD_REPORT.md
scenes/
scripts/
data/
assets/
```

Recommended structure:

```text
scenes/
  Main.tscn

scripts/
  Main.gd
  GameState.gd
  GameData.gd
  CombatController.gd
  UIController.gd
  SaveManager.gd
  Effects.gd
  Verifier.gd

data/
  game_data.gd or game_data.json

assets/
  placeholders/
  ui/
```

Keep it simple. Do not over-architect. But do not scatter every number randomly across UI code. Game data should be reasonably separated so enemies, stages, upgrades, rewards, and balance can be adjusted later.

---

## 4. Product Spec File

Before implementation, create:

```text
PRODUCT_SPEC.md
```

It must include:

```text
1. Game title
2. One-sentence concept
3. Core loop
4. 540×960 screen layout
5. Upgrade list
6. Stage/boss structure
7. Save data structure
8. v0.1 scope
9. Explicitly excluded features
10. Next-update candidates
```

Do not stop after writing the document. Write it quickly, then implement immediately.

---

## 5. v0.1 Scope

Required scope:

```text
1 region
10–20 stages
3–5 normal enemy types
1 boss
4–6 upgrade buttons
automatic combat
damage numbers
level or progress growth
gold or primary currency
stage progress
boss encounter
boss clear
reward popup
save/load
simple reset or new game option
540×960 vertical layout
Web build readiness
```

Do not implement:

```text
inventory
equipment system
gacha
character collection
skill tree
quest system
multiple large regions
ads
IAP
login
server
ranking
cloud save
daily missions
complex achievement system
full audio system
formal art pipeline
```

---

## 6. Commercial-Ready Structure

The goal is not final commercial polish. The goal is a structure that could grow into a small commercial game.

Required principles:

```text
Data must be editable later.
Assets must be replaceable later.
Save data must not be careless.
UI must be mobile-first.
The first screen must not look like a developer test.
The game must have a clear loop.
The code must be understandable enough for future AI work.
```

Target middle ground:

```text
small, clean, direct, expandable
```

Avoid both extremes: one messy script with everything mixed together, or a huge abstract architecture.

---

## 7. Gameplay Loop

The first playable loop must be:

```text
Open game
→ see title/status/stage/gold
→ automatic combat starts
→ player attacks enemy
→ enemy HP decreases
→ damage number appears
→ enemy dies
→ gold/EXP reward appears
→ stage progress increases
→ player upgrades stats
→ combat gets faster/easier
→ boss appears after progress
→ boss is defeated
→ clear/reward popup appears
→ next target is shown
→ progress is saved
```

The player should understand what is happening without reading a manual. First 3 minutes must contain meaningful progress. Do not make the early game slow.

---

## 8. Screen Layout

Target resolution:

```text
540×960 portrait
```

Recommended layout:

```text
Top 0–150:
  game title
  level / stage / progress
  gold
  power or simple growth indicator

Center 150–620:
  player
  enemy
  HP bars
  damage numbers
  attack feedback
  boss warning
  reward popup / clear popup

Bottom 620–960:
  4–6 upgrade buttons
  upgrade cost
  unavailable state
  save/reset/settings small buttons if needed
```

The UI must not look like a default Godot debug screen.

Use panels, strong color contrast, button press feedback, floating numbers, small animations, and clear visual hierarchy.

Temporary graphics are acceptable, but the screen should feel like a game screen.

---

## 9. Combat Requirements

Combat can be simple.

Required:

```text
player auto attacks
enemy auto attacks or enemy pressure exists
enemy HP bar
player HP or survival pressure
damage numbers
hit flash
enemy death
reward
next enemy spawn
boss spawn
boss HP bar
boss clear
```

Suggested model:

```text
Player attacks every X seconds.
Enemy may attack every Y seconds.
Player damage depends on attack upgrade.
Enemy HP increases by stage.
Gold reward increases by stage.
Boss has more HP and time/pressure.
```

If boss timer is too much work, use a simpler boss pressure mechanic.

---

## 10. Growth Requirements

Use 4–6 upgrade buttons.

Suggested upgrades:

```text
Attack
Max HP
Defense
Attack Speed
Gold Gain
Critical Chance
```

You may rename them to fit your chosen theme.

Requirements:

```text
Each upgrade has level.
Each upgrade has cost.
Cost increases.
Button shows current level and cost.
Button changes state when unaffordable.
Upgrade immediately affects gameplay.
```

Suggested formula:

```text
cost = base_cost * pow(1.18, level)
```

Do not obsess over balance. Make the first 3 minutes feel good.

---

## 11. Stage and Boss Requirements

Use one region.

Suggested structure:

```text
Stage 1–15
Every stage has a normal enemy.
After enough kills or stage progress, stage advances.
Final stage triggers boss.
Boss defeat triggers region clear.
```

Required visual states:

```text
normal combat
stage progress
boss warning
boss battle
clear/reward
next target or "coming soon"
```

Do not implement full second region. Show a next-goal placeholder if needed.

---

## 12. Save / Load Requirements

Save is required.

Save data should include:

```text
save_version
gold
level
exp or progress
current_stage
current_enemy_progress
upgrade_levels
boss_clear_state
last_play_time
settings if any
```

Use local save.

On start:

```text
if save exists:
  load progress
else:
  start new game
```

Save after upgrade purchase, stage progress, boss clear, manual save if present, and periodic autosave.

Add a reset/new game button if simple. Use a save version field.

---

## 13. Offline Reward

If practical, implement a simple offline reward.

Example:

```text
offline_seconds = now - last_play_time
reward = estimated_gold_per_second * offline_seconds
cap = 2 hours
```

Show a simple popup:

```text
While away: Gold +1234
```

If offline reward would slow implementation too much, leave the save structure prepared and mention it in BUILD_REPORT.md.

---

## 14. Art Policy

Do not generate AI images. Do not search free assets. Do not use paid assets. Do not waste time on transparent PNG.

Use temporary in-engine art:

```text
Color shapes
Simple silhouettes
Basic icons made from drawing code
Gradient backgrounds
Panels
Particles
Damage numbers
Flash effects
```

But make it feel like a mobile game.

Good placeholder direction:

```text
player = distinct hero silhouette / capsule / simple knight shape
normal enemies = different colored monster shapes
boss = large unique silhouette
background = vertical gradient + ground band + simple decorative shapes
```

Use visual feedback to compensate for simple art:

```text
attack lunge
hit flash
screen shake for boss
floating damage
upgrade sparkle
reward popup
boss warning
clear banner
```

---

## 15. Audio Policy

Do not implement full audio in v0.1 unless it is extremely quick.

No external audio assets.

If adding audio, use generated simple tones only if easy.

Audio is optional. Visual game loop is more important.

---

## 16. Verification

Before reporting completion, verify:

```text
Godot project opens
Main scene runs
540×960 layout works
auto combat runs
upgrades work
stage progresses
boss appears
boss can be defeated
reward popup appears
save/load works
reset works if implemented
Web build is possible or instructions are clear
```

If Godot CLI is available, run a headless check. If Web export is available, build Web. If not available, report exactly what could not be run and why.

Do not fake verification.

---

## 17. Optional --verify Mode

If practical, implement:

```text
godot --headless -- --verify
```

The verifier should test:

```text
initial state valid
upgrade purchase changes stat
enemy defeat gives gold
stage progression works
boss clear sets clear state
save/load roundtrip works
```

If this takes too long, skip it and report manual verification instead.

---

## 18. Optional --shot Mode

If practical, implement:

```text
godot --headless -- --shot
```

Desired screenshots:

```text
basic combat
upgrade affordable
upgrade unaffordable
boss battle
clear popup
loaded save state
```

If screenshot mode is too slow, skip it and report manual visual verification instead.

---

## 19. Implementation Order

Use this order unless you find a faster route.

### Step 1 — Create project skeleton

```text
project.godot
scenes/Main.tscn
scripts/
data/
assets/
PRODUCT_SPEC.md
```

### Step 2 — Create main 540×960 UI

Build the vertical layout first. Before deep logic, make the screen look like a mobile game.

### Step 3 — Implement state/data

Create game state and data. Include initial values, enemies, stages, upgrades, and rewards.

### Step 4 — Implement combat loop

Auto attack, enemy HP, damage numbers, enemy death, reward, next enemy.

### Step 5 — Implement upgrades

Upgrade buttons, cost, stat changes, unaffordable state.

### Step 6 — Implement stage/boss/clear

Stage progress, boss warning, boss battle, boss clear, reward popup.

### Step 7 — Implement save/load

Save progress, load on start, reset/new game.

### Step 8 — Add juice

Add quick polish:

```text
hit flash
lunge
floating damage
button feedback
boss warning
clear banner
reward popup animation
```

### Step 9 — Verify/build/report

Run what can be run. Write BUILD_REPORT.md.

---

## 20. Do Not Overdo

Do not get stuck on:

```text
perfect balance
perfect architecture
perfect art
perfect sound
perfect animation
full release pipeline
store upload
monetization
```

This is v0.1.

The goal is:

```text
small but coherent
playable
mobile-shaped
release-oriented structure
fast to extend
```

---

## 21. Completion Report

When done, create:

```text
BUILD_REPORT.md
```

Keep it short.

Include:

```text
1. Game title and concept
2. Implemented systems
3. File/folder structure
4. Current 3-minute play flow
5. Save/load behavior
6. How to run
7. Web build status
8. Verification performed
9. Known missing features
10. Next one-click sprint recommendation
```

---

## 22. Success Criteria

Success means:

```text
The user can open the game and immediately understand it is a vertical idle RPG.
The game plays by itself.
The user can press upgrades and feel stronger.
The game progresses to a boss.
The boss can be cleared.
The game shows reward/clear state.
The save persists.
The structure can be extended.
```

Failure means:

```text
It looks like a raw test UI.
It requires user decisions before playable result.
It focuses on documents instead of implementation.
It spends time on art assets.
It has no save.
It has no boss/clear flow.
It has no upgrade feedback.
```

---

## 23. Final Instruction

Start immediately.

Do not wait for more guidance.

Do not ask about names, colors, world, enemy concepts, upgrade names, or layout details.

Choose reasonable defaults and implement.

The deliverable is a working small vertical idle RPG v0.1 candidate from an empty folder.
