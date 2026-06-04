# Nintendo Game Design Research for KidGameMaker
## A Comprehensive Feature Extraction from Nintendo's Design Philosophy

**Date:** Research Compilation  
**Games Analyzed:** Super Mario Maker 1 & 2, Super Mario Wonder, Zelda: Breath of the Wild & Tears of the Kingdom, Kirby Series, Animal Crossing: New Horizons, Splatoon 1/2/3, Metroid Dread, Pikmin Series  
**Total Feature Ideas:** 60+

---

## TABLE OF CONTENTS

1. [Super Mario Maker 1 & 2 Features](#1-super-mario-maker-1--2-features)
2. [Super Mario Wonder Features](#2-super-mario-wonder-features)
3. [Zelda: BotW / TotK Features](#3-zelda-botw--totk-features)
4. [Kirby Series Features](#4-kirby-series-features)
5. [Animal Crossing Features](#5-animal-crossing-features)
6. [Splatoon Features](#6-splatoon-features)
7. [Metroid Series Features](#7-metroid-series-features)
8. [Pikmin Series Features](#8-pikmin-series-features)
9. [Cross-Cutting Design Principles](#9-cross-cutting-design-principles)

---

## 1. SUPER MARIO MAKER 1 & 2 FEATURES

### Feature 1: Stamp-Based Course Part Placement
- **Nintendo Source:** Super Mario Maker 1 & 2
- **Description:** Every game element (terrain, enemies, items, gizmos) is represented as a visual stamp that can be placed on a grid. Stamps can be dragged, duplicated, and erased with simple touch interactions.
- **Kid UX:** Tap a stamp from the palette, then tap on the canvas to place it. Drag to reposition. Long-press to see variants (winged, big, parachute). Pinch to enlarge/shrink stamps.
- **LLM Automation:** The LLM maintains a spatial index of all stamps, validates placement rules (e.g., "enemies can't be placed in walls"), and auto-snaps to grid. Handles layer ordering and collision detection.
- **JSON Contract Extension:**
  ```json
  {
    "stampId": "goomba_001",
    "type": "enemy",
    "variant": "winged",
    "position": {"x": 120, "y": 300},
    "size": "normal",
    "layer": "main",
    "modifiers": ["parachute", "big"]
  }
  ```

### Feature 2: Theme Switching (Day/Night Variants)
- **Nintendo Source:** Super Mario Maker 2 (Night Mode)
- **Description:** Each level theme (Ground, Underground, Underwater, Desert, Snow, Sky, Forest, Ghost House, Airship, Castle) has a day and night variant. Night mode fundamentally alters gameplay mechanics — e.g., low gravity in Sky, upside-down controls in Underground, poison water in Forest, spotlights in Ghost House.
- **Kid UX:** A single sun/moon toggle button at the top of the screen. Tap to switch between day and night. Visual preview instantly updates the canvas background and lighting.
- **LLM Automation:** When night is toggled, the LLM swaps the active ruleset, adjusts physics constants (gravity, friction), replaces material properties (water -> poison), and reconfigures enemy behaviors.
- **JSON Contract Extension:**
  ```json
  {
    "theme": "forest",
    "timeOfDay": "night",
    "nightEffects": {
      "waterType": "poison",
      "gravityMultiplier": 1.0,
      "slippery": false
    }
  }
  ```

### Feature 3: Auto-Scroll Control
- **Nintendo Source:** Super Mario Maker 1 & 2
- **Description:** Forces the camera to move at a set speed, pushing the player forward. Multiple speeds available: slow, medium, fast, and custom. Can scroll left, right, up, or down.
- **Kid UX:** A slider with a turtle (slow), rabbit (medium), and rocket (fast) icon. Drag to set speed. Tap arrows to change scroll direction. Visual arrows on the canvas edge show direction.
- **LLM Automation:** The LLM sets the camera velocity vector, clamps player position relative to the scroll boundary, and adjusts enemy spawn timing relative to the scroll offset.
- **JSON Contract Extension:**
  ```json
  {
    "autoScroll": {
      "enabled": true,
      "speed": "medium",
      "direction": "right",
      "speedValue": 1.5
    }
  }
  ```

### Feature 4: Clear Conditions (Win State Builder)
- **Nintendo Source:** Super Mario Maker 2
- **Description:** Define alternative win conditions beyond "reach the flagpole" — e.g., "defeat 5 Goombas," "collect 30 coins," "reach goal after hitting all P-Switches." Over 50 different condition types.
- **Kid UX:** A "Win Rules" button opens a simple menu with picture cards (defeat enemies, collect items, reach goal). Tap a card, then tap the + or - buttons to set the target number. Visual counter appears on canvas.
- **LLM Automation:** Tracks condition state during gameplay, evaluates win/lose conditions, displays HUD counters, and validates that conditions are actually achievable (no soft-locks).
- **JSON Contract Extension:**
  ```json
  {
    "clearConditions": [
      {"type": "defeat_enemy", "target": "goomba", "count": 5},
      {"type": "collect_item", "target": "coin", "count": 30}
    ]
  }
  ```

### Feature 5: Sub-Areas (Warp Pipes / Doors)
- **Nintendo Source:** Super Mario Maker 1 & 2
- **Description:** Create secondary rooms accessible via pipes or doors. Each sub-area can have its own theme, enemies, and layout. Enables non-linear level design and secret areas.
- **Kid UX:** Place a pipe stamp, then tap a "Go Inside" button that appears. The canvas switches to the sub-area view. A mini-map shows connections. Color-coded pipes link together automatically.
- **LLM Automation:** Manages room graph topology, handles warp transitions with fade effects, validates that all pipe/door pairs have matching destinations, prevents infinite warp loops.
- **JSON Contract Extension:**
  ```json
  {
    "subAreas": [
      {
        "id": "sub_001",
        "theme": "underground",
        "size": {"width": 100, "height": 50},
        "entrances": [{"type": "pipe", "color": "green", "position": {"x": 10, "y": 5}}]
      }
    ]
  }
  ```

### Feature 6: ON/OFF Switch Block System
- **Nintendo Source:** Super Mario Maker 2
- **Description:** Hitting an ON/OFF switch toggles the global switch state. Dotted-Line Blocks become solid or disappear. Spike Blocks extend/retract. Conveyor belts reverse. Creates puzzle-like mechanics.
- **Kid UX:** Place the red and blue switch stamp. Place dotted-line blocks that appear as dashed outlines when inactive. Tap the switch during playtest to see the toggle effect. Visual color coding (red = ON, blue = OFF).
- **LLM Automation:** Maintains a global boolean state for ON/OFF. On toggle, updates all affected block colliders, plays transition animations, handles switch cooldown, and validates that levels remain solvable.
- **JSON Contract Extension:**
  ```json
  {
    "onOffState": false,
    "switchableElements": [
      {"type": "dotted_line_block", "state": "on_dependent", "position": {}},
      {"type": "spike_block", "retractWhen": "off"}
    ]
  }
  ```

### Feature 7: Semisolid Platforms
- **Nintendo Source:** Super Mario Maker 1 & 2
- **Description:** Platforms that can be jumped through from below but are solid from above. Available in various visual styles (tree, mushroom, bridge). Can be stacked and layered.
- **Kid UX:** Tap the semisolid stamp, drag to set width. Platform appears as a visual layer with a dotted outline on the bottom half indicating "pass-through." Player automatically passes through when jumping up.
- **LLM Automation:** Configures one-way collision detection (top surface only, no collision from below). Handles layering with other platforms and dynamic body interactions.
- **JSON Contract Extension:**
  ```json
  {
    "type": "semisolid_platform",
    "width": 5,
    "style": "mushroom",
    "collision": "one_way_top",
    "position": {"x": 0, "y": 0}
  }
  ```

### Feature 8: Track System (Moving Objects)
- **Nintendo Source:** Super Mario Maker 1 & 2
- **Description:** Place tracks to define paths for platforms, enemies, or items to follow. Supports straight segments, curves, loops. Objects on tracks can move continuously or be player-activated.
- **Kid UX:** Draw tracks by dragging a pen tool across the canvas. Snap points at grid intersections. Place an object on the track — it automatically follows the path. Tap track nodes to set speed (slow/medium/fast).
- **LLM Automation:** Converts drawn tracks into bezier paths, assigns path-following behavior to tracked objects, handles junction logic, and calculates timing for synchronized movement.
- **JSON Contract Extension:**
  ```json
  {
    "track": {
      "path": [{"x": 0, "y": 0}, {"x": 100, "y": 0}, {"x": 100, "y": 50}],
      "speed": "medium",
      "looped": false,
      "activation": "auto"
    }
  }
  ```

### Feature 9: Sound Effect Stamps
- **Nintendo Source:** Super Mario Maker 1 & 2
- **Description:** Place sound triggers throughout the level — musical notes, character voices, animal sounds, victory fanfares. Can be tied to specific actions (jumping, collecting coins, hitting blocks).
- **Kid UX:** Tap the sound note icon, select from a visual grid of sound icons (music note, dog bark, explosion, laugh). Drag the sound stamp onto any object. A speaker icon appears indicating the sound attachment.
- **LLM Automation:** Maps sound triggers to game events, handles audio spatialization (volume based on distance), manages sound priority to prevent audio clutter, validates sound-event bindings.
- **JSON Contract Extension:**
  ```json
  {
    "soundEffects": [
      {"trigger": "on_jump", "sound": "boing", "volume": 0.8, "pitch": "random"}
    ]
  }
  ```

### Feature 10: World Map Builder
- **Nintendo Source:** Super Mario Maker 2 (World Maker update)
- **Description:** Connect up to 40 levels across 8 worlds on a world map. Customize paths, add decorative elements (hills, trees, castles), place unlock conditions, and create branching routes.
- **Kid UX:** A zoomed-out map canvas. Tap to place a level dot. Draw paths between dots by dragging. Place a castle stamp for the end of each world. World themes selectable via icon grid.
- **LLM Automation:** Validates map topology (acyclic graph for progression), manages level unlock state, handles path drawing with automatic curve smoothing, generates minimap assets.
- **JSON Contract Extension:**
  ```json
  {
    "worldMap": {
      "worlds": [
        {
          "worldId": 1,
          "theme": "grass",
          "levels": [{"id": "lvl_001", "position": {"x": 2, "y": 3}}],
          "paths": [["lvl_001", "lvl_002"]]
        }
      ]
    }
  }
  ```

### Feature 11: Enemy Modifiers (Winged, Big, Parachute)
- **Nintendo Source:** Super Mario Maker 1 & 2
- **Description:** Apply visual and behavioral modifiers to any enemy: wings (adds flight), big mushroom (doubles size/HP), parachute (slows descent from above), or combinations.
- **Kid UX:** Place an enemy, then tap modifier buttons that appear: feather icon (wings), mushroom icon (big), parachute icon. Enemy sprite updates instantly with the modification. Combinations stack visually.
- **LLM Automation:** Applies behavioral modifications (adds gravity-affected flight for wings, scales hitbox and HP for big, adds parachute physics), handles stacked modifier interactions.
- **JSON Contract Extension:**
  ```json
  {
    "enemyId": "goomba_001",
    "modifiers": ["winged", "big"],
    "behaviorOverrides": {
      "flight": true,
      "hpMultiplier": 2,
      "sizeScale": 2.0
    }
  }
  ```

### Feature 12: Checkpoint Flag System
- **Nintendo Source:** Super Mario Maker 1 & 2
- **Description:** Checkpoint flags respawn the player at the flag location on death instead of the level start. Supports multiple checkpoints per level. Checkpoint toggles state (red -> green) when passed.
- **Kid UX:** Place a flag stamp. A dashed line shows the checkpoint "zone" of influence. Player respawns at the last checkpoint touched. Visual confetti effect plays when checkpoint is activated.
- **LLM Automation:** Manages respawn point state, handles checkpoint activation on player overlap, persists checkpoint state across death/resets, validates checkpoint reachability.
- **JSON Contract Extension:**
  ```json
  {
    "checkpoints": [
      {"id": "cp_001", "position": {"x": 500, "y": 100}, "zoneWidth": 32}
    ]
  }
  ```

### Feature 13: Slopes (Gentle & Steep)
- **Nintendo Source:** Super Mario Maker 2
- **Description:** Terrain that slopes at two angles — gentle (22.5 degrees) and steep (45 degrees). Slopes affect player movement speed (faster downhill, slower uphill) and enable slide-kills.
- **Kid UX:** Select the slope tool, drag to draw the slope length. Two buttons toggle gentle vs. steep. Slope preview shows as a ramp overlay on the grid. Mario automatically slides down steep slopes.
- **LLM Automation:** Generates slope colliders with proper angle physics, applies velocity modifications for slope traversal, handles slide-state detection and enemy damage from sliding.
- **JSON Contract Extension:**
  ```json
  {
    "type": "slope",
    "angle": "steep",
    "startPosition": {"x": 0, "y": 100},
    "endPosition": {"x": 100, "y": 50},
    "physics": {"slideSpeed": 2.0}
  }
  ```

### Feature 14: Clear Pipes
- **Nintendo Source:** Super Mario Maker 2 (3D World style)
- **Description:** Transparent pipes that the player enters and travels through at high speed. Can be placed in any direction and connected to form networks. Items and enemies can also travel through.
- **Kid UX:** Draw pipe segments by dragging. Pipes auto-connect at endpoints. Visual transparency shows the player/enemy inside during travel. Junction nodes allow branching paths.
- **LLM Automation:** Builds pipe network graph, handles entry/exit transitions with smooth movement, supports multi-passenger routing (items, enemies), validates pipe network connectivity.
- **JSON Contract Extension:**
  ```json
  {
    "clearPipes": [
      {
        "segments": [{"x1": 0, "y1": 0, "x2": 50, "y2": 0, "x3": 50, "y3": -30}],
        "speed": "fast",
        "bidirectional": true
      }
    ]
  }
  ```

### Feature 15: Koopaling Boss Battles
- **Nintendo Source:** Super Mario Maker 2 (3.0 update)
- **Description:** Seven unique boss characters (Larry, Iggy, Wendy, Lemmy, Roy, Morton, Ludwig) each with distinct attack patterns, movement styles, and defeat conditions.
- **Kid UX:** Place a Koopaling stamp. Each shows a unique idle animation. Tapping cycles between the seven variants. Each has different jump patterns and projectile types shown in a preview card.
- **LLM Automation:** Loads boss-specific AI behavior trees, manages boss health, phases, and defeat conditions. Handles boss-specific attacks (magic wands, shell spins, ground pounds).
- **JSON Contract Extension:**
  ```json
  {
    "boss": {
      "type": "koopaling",
      "variant": "ludwig",
      "hp": 3,
      "attackPattern": "multi_jump_shell_spin",
      "arenaBounds": {"x": 0, "y": 0, "w": 200, "h": 100}
    }
  }
  ```

---

## 2. SUPER MARIO WONDER FEATURES

### Feature 16: Wonder Flower (Level Transformation Trigger)
- **Nintendo Source:** Super Mario Wonder
- **Description:** A collectible item that, when touched, triggers a dramatic transformation of the entire level — pipes animate, enemies change behavior, new paths open, music shifts, visual style morphs. Creates a "second half" of each level.
- **Kid UX:** Place a Wonder Flower stamp. A "Wonder Preview" button shows what changes (animated transition). When the player touches the flower in play mode, the level transforms with particle effects and music change.
- **LLM Automation:** Manages level state machine (normal -> wonder mode), handles smooth transitions between level variants, orchestrates multi-system changes (terrain, enemies, music, lighting), and validates wonder-state reachability.
- **JSON Contract Extension:**
  ```json
  {
    "wonderFlower": {
      "position": {"x": 200, "y": 50},
      "transformations": [
        {"type": "terrain_morph", "targetTiles": [...], "newTiles": [...]},
        {"type": "enemy_behavior_change", "targetEnemies": [...], "newBehavior": "dance"},
        {"type": "music_change", "track": "wonder_theme"},
        {"type": "gravity_change", "multiplier": 0.5}
      ]
    }
  }
  ```

### Feature 17: Badge Equip System (Per-Level Ability Selection)
- **Nintendo Source:** Super Mario Wonder
- **Description:** Players select one badge before entering a level that grants a special ability. Three categories: Action Badges (new moves), Boost Badges (passive bonuses), Expert Badges (risk/reward).
- **Kid UX:** Before play, a badge wheel appears. Tap a badge icon to see animation preview. Badges are color-coded (orange=action, blue=boost, yellow=expert). Selected badge glows and shows a "Ready!" animation.
- **LLM Automation:** Applies badge behavior modifications to player controller, manages badge-specific cooldowns, handles badge interactions with level elements, validates badge availability per level.
- **JSON Contract Extension:**
  ```json
  {
    "badgeSystem": {
      "availableBadges": ["parachute_cap", "wall_climb", "coin_reward"],
      "badgeType": "action",
      "effect": "parachute_descent_on_r_button"
    }
  }
  ```

### Feature 18: Parachute Cap Badge
- **Nintendo Source:** Super Mario Wonder
- **Description:** Press R (or shake) in midair to deploy a parachute cap, slowing descent. Combines with Floating High Jump for extended airtime. Adds a new dimension to platforming.
- **Kid UX:** Badge icon shows a hat with a parachute. During play, a parachute icon appears next to the player when in air. Tap the action button to deploy — character's hat expands with a satisfying "pop."
- **LLM Automation:** Modifies gravity when parachute is active (0.2x normal), handles deployment/collapse timing, adds terminal velocity cap, manages animation state transitions.
- **JSON Contract Extension:**
  ```json
  {"badge": "parachute_cap", "trigger": "r_button_in_air", "gravityModifier": 0.2, "maxFallSpeed": 50}
  ```

### Feature 19: Wall-Climb Jump Badge
- **Nintendo Source:** Super Mario Wonder
- **Description:** Jump against a wall, then press jump again to kick off and climb upward. Enables vertical exploration without needing permanent wall-jump ability.
- **Kid UX:** Player slides against walls briefly. A sparkle effect shows when the wall-climb window is active. Press jump within the window to kick upward. Can chain up tall walls.
- **LLM Automation:** Detects wall collision with specific normal vectors, enables wall-slide state (reduced gravity), manages cling timer (0.5s window), applies kick-off velocity vector.
- **JSON Contract Extension:**
  ```json
  {"badge": "wall_climb", "clingTime": 0.5, "kickOffVelocity": {"x": 100, "y": -200}, "maxChains": 99}
  ```

### Feature 20: Grappling Vine Badge
- **Nintendo Source:** Super Mario Wonder
- **Description:** In midair, press R to launch a vine that grabs onto walls, pulling the player toward that surface. Functions like a grappling hook for gap crossing.
- **Kid UX:** Vine shoots out with a green arc trajectory. When it hits a wall, a visual vine connects player to wall. Player is pulled along the arc smoothly. Misses show a "splat" particle.
- **LLM Automation:** Casts a ray/arc from player position, detects valid wall targets, applies interpolated movement along arc path, handles release timing and landing state.
- **JSON Contract Extension:**
  ```json
  {"badge": "grappling_vine", "range": 150, "arcHeight": 30, "pullSpeed": 300, "validTargets": ["wall", "ceiling"]}
  ```

### Feature 21: Invisibility Badge (Expert)
- **Nintendo Source:** Super Mario Wonder
- **Description:** Player becomes invisible — enemies cannot detect or target the player. But the player also cannot see their own character well (semi-transparent). High-risk stealth gameplay.
- **Kid UX:** Player character becomes ghostly/semi-transparent. Enemies walk past without reacting. A faint shimmer effect helps the player track their own position.
- **LLM Automation:** Disables enemy targeting AI for invisible player, reduces player sprite opacity to 30%, adds shimmer particle trail, handles edge cases (invisible player + hazards still interact).
- **JSON Contract Extension:**
  ```json
  {"badge": "invisibility", "playerOpacity": 0.3, "enemyDetectionRange": 0, "shimmerTrail": true}
  ```

### Feature 22: Spring Feet Badge (Expert)
- **Nintendo Source:** Super Mario Wonder
- **Description:** Player perpetually bounces and auto-jumps higher than normal. Makes precise platforming harder but enables reaching high areas without effort.
- **Kid UX:** Player auto-bounces on landing. A spring sound plays with each bounce. Bounce height can be increased by holding jump. Visual spring coils appear under feet.
- **LLM Automation:** Overrides landing state to immediately trigger jump, manages bounce velocity inheritance, handles variable bounce height from hold duration, prevents unintended double-bounces.
- **JSON Contract Extension:**
  ```json
  {"badge": "spring_feet", "autoBounce": true, "bounceHeight": 1.5, "holdMultiplier": 2.0, "sound": "spring_boing"}
  ```

### Feature 23: Safety Bounce Badge (Boost)
- **Nintendo Source:** Super Mario Wonder
- **Description:** Player bounces back out of pits, lava, or poison swamps one time per fall. Prevents death from a single mistake. Badge has a cooldown.
- **Kid UX:** When falling into a pit, instead of dying, the player bounces back up with a safety net visual effect. Badge icon on HUD gets a red X indicating it's on cooldown. Refills at checkpoint.
- **LLM Automation:** Detects pit/death-zone entry, cancels death event, applies upward impulse velocity, triggers safety bounce animation, manages cooldown state per-fall.
- **JSON Contract Extension:**
  ```json
  {"badge": "safety_bounce", "saveFrom": ["pit", "lava", "poison"], "cooldown": "per_fall", "bounceVelocity": {"x": 0, "y": -250}}
  ```

### Feature 24: Talking Flower (NPC Commentary System)
- **Nintendo Source:** Super Mario Wonder
- **Description:** Flowers placed throughout levels that comment on gameplay, give hints, react to player actions, and add personality. Context-aware dialogue based on what the player is doing.
- **Kid UX:** Place a talking flower stamp. A speech bubble editor appears — type or speak dialogue. Set trigger conditions ("on approach", "on jump", "on coin collect nearby"). Flower animates when speaking.
- **LLM Automation:** Evaluates trigger conditions in real-time, generates context-appropriate dialogue from templates, manages speech bubble positioning, handles dialogue priority and queuing.
- **JSON Contract Extension:**
  ```json
  {
    "talkingFlowers": [
      {
        "position": {"x": 100, "y": 200},
        "triggers": [
          {"condition": "player_nearby", "radius": 50, "dialogue": "Nice jump!"},
          {"condition": "player_falling", "dialogue": "Watch out below!"}
        ]
      }
    ]
  }
  ```

### Feature 25: Dual Badge Combinations
- **Nintendo Source:** Super Mario Wonder
- **Description:** After collecting both parent badges, Dual Badges randomly appear that combine two badge effects — e.g., "Parachute Cap + Floating High Jump" gives both parachute descent AND higher jumps.
- **Kid UX:** Two badge icons fuse together with a sparkle animation. The dual badge shows both icons side by side. When equipped, both effects are active simultaneously.
- **LLM Automation:** Manages badge effect combination logic, validates compatible combinations, applies both behavior modifications to player controller, handles conflicting effect resolution.
- **JSON Contract Extension:**
  ```json
  {"badge": "dual_parachute_float", "parentBadges": ["parachute_cap", "floating_high_jump"], "effects": ["parachute_descent", "floaty_jump"]}
  ```

---

## 3. ZELDA: BOTW / TOTK FEATURES

### Feature 26: Elemental Chemistry Engine (Fire/Water/Ice/Electricity)
- **Nintendo Source:** Zelda: Breath of the Wild / Tears of the Kingdom
- **Description:** A simplified chemistry engine where elements (fire, water, ice, electricity, wind) interact with materials following intuitive rules: fire burns grass/wood, water extinguishes fire, ice freezes water, electricity conducts through metal, wind pushes objects.
- **Kid UX:** Place element source stamps (fire torch, water geyser, lightning cloud, ice crystal). Place material stamps (wooden crate, metal block, grass patch). Elements auto-interact when placed nearby. Visual effects show reactions (steam from fire+water, ice from water+cold).
- **LLM Automation:** Maintains element state machine, processes pairwise element-material interactions each tick, handles propagation (fire spreading across grass), manages visual effect spawning, ensures consistent rule application.
- **JSON Contract Extension:**
  ```json
  {
    "chemistryEngine": {
      "elements": ["fire", "water", "ice", "electricity", "wind"],
      "materials": [
        {"type": "wood", "flammable": true, "conductive": false, "meltingPoint": "fire"},
        {"type": "metal", "flammable": false, "conductive": true, "meltingPoint": null}
      ],
      "reactions": [
        {"input": ["fire", "wood"], "output": "burning_wood", "propagates": true},
        {"input": ["water", "fire"], "output": "steam", "extinguishes": true}
      ]
    }
  }
  ```

### Feature 27: Ultrahand (Grab, Rotate, Glue Objects)
- **Nintendo Source:** Zelda: Tears of the Kingdom
- **Description:** A tool to grab almost any object in the world, rotate it freely, and glue it to other objects. Enables creation of vehicles, bridges, catapults, and other contraptions from simple parts.
- **Kid UX:** Tap an object to highlight it in orange. Drag to move it around. Rotation handles appear — drag to spin. When near another object, a "glue" visual (green glow) appears. Release to fuse them together.
- **LLM Automation:** Manages object selection highlighting, handles 2D rotation gizmos, implements physics joint creation on "glue," calculates center of mass for combined objects, handles object separation (break glue).
- **JSON Contract Extension:**
  ```json
  {
    "ultrahand": {
      "selectedObject": "crate_001",
      "gluedObjects": [
        {"id": "crate_001", "position": {"x": 0, "y": 0}, "rotation": 0},
        {"id": "wheel_001", "position": {"x": 30, "y": 30}, "rotation": 0, "joint": "revolute"}
      ]
    }
  }
  ```

### Feature 28: Zonai Device Gadgets (Fans, Rockets, Wheels, Balloons)
- **Nintendo Source:** Zelda: Tears of the Kingdom
- **Description:** 27+ placeable gadgets that generate force or effects — fans produce wind, rockets produce thrust, wheels enable rolling, balloons provide lift, springs bounce, beams shoot lasers. Battery-powered and can be combined into contraptions.
- **Kid UX:** Zonai device palette shows icons: fan (blue), rocket (red), wheel (gray), balloon (yellow), spring (green). Tap to select, tap canvas to place. Battery meter shows on each device. Tap device to toggle on/off during testing.
- **LLM Automation:** Simulates each device's physics effect (fan applies force vector, rocket applies impulse, balloon applies buoyancy), manages battery drain, handles device-device interactions, validates contraption stability.
- **JSON Contract Extension:**
  ```json
  {
    "zonaiDevices": [
      {"type": "fan", "position": {}, "force": {"x": 0, "y": -200}, "batteryDrain": 0.5, "active": true},
      {"type": "rocket", "position": {}, "impulse": {"x": 0, "y": -500}, "burnTime": 3.0}
    ]
  }
  ```

### Feature 29: Autobuild (Save & Rebuild Contraptions)
- **Nintendo Source:** Zelda: Tears of the Kingdom
- **Description:** Once a contraption is built with Ultrahand, it can be saved as a "schematic" and rebuilt instantly anywhere. Saves time and encourages sharing contraption designs.
- **Kid UX:** After building a contraption, a "Save Blueprint" button appears. Tap to save — a blueprint card appears in the inventory. Tap the blueprint, then tap anywhere to instantly reconstruct the contraption. Blueprint cards show a thumbnail.
- **LLM Automation:** Serializes contraption state (object types, positions, rotations, joints), validates placement location for reconstruction, handles resource requirements, manages blueprint inventory and thumbnails.
- **JSON Contract Extension:**
  ```json
  {
    "blueprints": [
      {
        "id": "bp_airbike",
        "name": "Air Bike",
        "thumbnail": "thumb_bp01.png",
        "parts": [
          {"type": "steering_stick", "x": 0, "y": 0},
          {"type": "fan", "x": -20, "y": 0},
          {"type": "fan", "x": 20, "y": 0},
          {"type": "wheel", "x": -15, "y": 15},
          {"type": "wheel", "x": 15, "y": 15}
        ]
      }
    ]
  }
  ```

### Feature 30: Recall (Rewind Objects in Time)
- **Nintendo Source:** Zelda: Tears of the Kingdom
- **Description:** Select a moving object and rewind its trajectory backward along its recent path. Enables riding falling rocks back up, reversing projectiles, and creative puzzle-solving.
- **Kid UX:** Tap a moving object — it glows purple. A "rewind" button appears. Hold to see the object's path traced as a dotted line. Release to watch it travel backward along the path. Purple trail visual effect.
- **LLM Automation:** Records position history for movable objects (last 10 seconds), interpolates reverse trajectory, handles collision during rewind, manages object state restoration.
- **JSON Contract Extension:**
  ```json
  {"recall": {"targetObject": "boulder_003", "recordHistory": true, "historyDuration": 10, "visualTrail": true}}
  ```

### Feature 31: Ascend (Phase Through Ceilings)
- **Nintendo Source:** Zelda: Tears of the Kingdom
- **Description:** Player can phase upward through any ceiling or overhang, emerging on top. Skips vertical traversal and enables secret discovery.
- **Kid UX:** When under a ceiling, an upward arrow prompt appears. Tap to activate — player glows green and phases up through the surface, emerging on top with a green flash.
- **LLM Automation:** Raycasts upward to find nearest ceiling, validates that ceiling is within range and not too thick, handles smooth vertical interpolation through the surface.
- **JSON Contract Extension:**
  ```json
  {"ascend": {"maxThickness": 64, "range": 100, "validSurfaces": ["ceiling", "overhang", "platform"], "visualEffect": "green_phase"}}
  ```

### Feature 32: Portable Cooking Pot
- **Nintendo Source:** Zelda: Tears of the Kingdom
- **Description:** A placeable device for cooking food. Combine ingredients (meat, vegetables, spices) to create dishes with stat bonuses (hearts, stamina, speed, stealth).
- **Kid UX:** Place the cooking pot stamp. During play, approach it and an "Cook!" button appears. Select up to 5 ingredients from an ingredient palette. Stir animation plays, then a dish pops out with sparkles.
- **LLM Automation:** Implements recipe database with 100+ combinations, calculates output dish properties from ingredient attributes, manages cooking animation state, handles ingredient consumption.
- **JSON Contract Extension:**
  ```json
  {
    "cooking": {
      "potPosition": {"x": 100, "y": 50},
      "recipes": [
        {"ingredients": ["meat", "spicy_pepper"], "output": "spicy_meat_skewer", "hearts": 5}
      ]
    }
  }
  ```

---

## 4. KIRBY SERIES FEATURES

### Feature 33: Copy Ability System (Absorb Enemy Powers)
- **Nintendo Source:** Kirby Series (all games)
- **Description:** The player can inhale certain enemies and absorb their abilities, transforming appearance and gaining new attacks. 30+ copy abilities across the series (Fire, Ice, Sword, Cutter, Bomb, Spark, Stone, Wheel, Hammer, Fighter, Wing, Ninja, etc.).
- **Kid UX:** Enemy stamps that grant copy abilities have a small star icon in the corner. When the player (as Kirby) touches them, a transformation animation plays — Kirby dons a hat/costume. Ability palette shows available copy abilities. Tap to select. Each ability has a simple one-button attack.
- **LLM Automation:** Manages copy ability state machine, swaps player sprite/animations per ability, implements ability-specific attacks and projectiles, handles ability loss on taking damage.
- **JSON Contract Extension:**
  ```json
  {
    "copyAbilities": [
      {
        "id": "fire",
        "sourceEnemy": "hothead",
        "attack": {"type": "fire_breath", "damage": 2, "range": 80},
        "animation": "breath_fire",
        "hatSprite": "fire_hat.png"
      }
    ]
  }
  ```

### Feature 34: Copy Ability Mixing (Combine Two Powers)
- **Nintendo Source:** Kirby 64: The Crystal Shards / Kirby Star Allies
- **Description:** Two copy abilities can be combined to create a hybrid ability with unique properties — e.g., Fire + Sword = Flaming Sword, Ice + Bomb = Ice Bomb, Spark + Stone = Lightning Boulder.
- **Kid UX:** Player has one ability. When absorbing a different ability, a "Mix!" prompt appears. Tap to combine. Visual fusion animation plays. New hybrid ability icon shows both parent icons merged.
- **LLM Automation:** Defines combination recipes (20+ unique combos), generates hybrid attack behaviors from parent attributes, manages ability inheritance and combination restrictions.
- **JSON Contract Extension:**
  ```json
  {
    "abilityMixes": [
      {"parent1": "fire", "parent2": "sword", "output": "flaming_sword", "attack": "fire_slash"},
      {"parent1": "ice", "parent2": "bomb", "output": "ice_bomb", "attack": "freeze_explosion"}
    ]
  }
  ```

### Feature 35: Super Abilities (Temporary Mega Powers)
- **Nintendo Source:** Kirby's Return to Dream Land / Triple Deluxe
- **Description:** Ultra-powerful versions of copy abilities that destroy everything on screen. Activated by touching a glowing enemy or special item. Temporary and visually spectacular.
- **Kid UX:** A rainbow-colored enemy/item stamp with sparkles. When touched, player transforms with a massive visual effect. Screen flashes. New super-powered attack charges automatically. After 10 seconds, power fades.
- **LLM Automation:** Manages super state timer, implements screen-clearing attacks, scales damage to destroy all non-boss enemies, handles visual effects (screen shake, flashes, particles).
- **JSON Contract Extension:**
  ```json
  {"superAbility": {"baseAbility": "sword", "duration": 10, "attack": "ultra_sword_slash", "screenClear": true, "invincible": true}}
  ```

### Feature 36: Mouthful Mode (Real-World Object Possession)
- **Nintendo Source:** Kirby and the Forgotten Land
- **Description:** Kirby inhales real-world objects and takes control of them — car, traffic cone, vending machine, water balloon, staircase, etc. Each object grants unique movement or attack.
- **Kid UX:** Special large object stamps (oversized compared to enemies). When Kirby approaches, an "Inhale!" prompt appears. Tap to watch Kirby stretch and wrap around the object. Controls change to match the object — car moves fast and jumps, cone drills downward.
- **LLM Automation:** Manages possession state, swaps player collider/physics to match object shape, implements object-specific controls and abilities, handles object release/extraction.
- **JSON Contract Extension:**
  ```json
  {
    "mouthfulMode": {
      "objectType": "car",
      "controls": {"move": "drive", "jump": "hop", "attack": "charge"},
      "speedMultiplier": 2.5,
      "canFloat": false
    }
  }
  ```

### Feature 37: Helper Characters (CPU / 2P Partners)
- **Nintendo Source:** Kirby Super Star / Star Allies
- **Description:** Enemies can be turned into helper allies that follow the player and attack enemies. Supports 2-4 player co-op where friends play as different copy abilities.
- **Kid UX:** Place a "Helper Heart" item stamp. When touched, the nearest enemy transforms into a helper with the same ability. Helper follows player automatically. A "Join!" bubble appears over helper for 2P to tap.
- **LLM Automation:** Converts enemy AI to ally AI (target enemies instead of player), implements follow behavior with pathfinding, manages helper attacks and ability usage, handles player drop-in/drop-out.
- **JSON Contract Extension:**
  ```json
  {
    "helpers": [
      {"type": "ally", "ability": "sword", "behavior": "follow_and_attack", "maxHelpers": 3}
    ]
  }
  ```

---

## 5. ANIMAL CROSSING FEATURES

### Feature 38: Terrain Sculpting (Cliff & River Builder)
- **Nintendo Source:** Animal Crossing: New Horizons
- **Description:** Modify terrain in real-time — raise cliffs up to 3 levels, dig rivers and ponds, create waterfalls, build paths. Complete creative control over the landscape.
- **Kid UX:** Select the "Terrain" tool from a palette. Tap "Build Cliff" or "Dig River" buttons. Tap on the grid to modify. Visual preview shows changes before confirming. 3 cliff levels shown as progressively darker shades. Water auto-flows and connects.
- **LLM Automation:** Manages heightmap data for terrain, validates cliff placement rules (needs support), handles water flow simulation (fills connected basins), generates cliff/river visual assets per grid cell.
- **JSON Contract Extension:**
  ```json
  {
    "terrainMap": {
      "gridSize": {"w": 50, "h": 50},
      "heightMap": [[0, 0, 1, 2, ...], ...],
      "waterMap": [[false, true, true, ...], ...],
      "waterfalls": [{"x": 5, "y": 3, "fromLevel": 2, "toLevel": 1}]
    }
  }
  ```

### Feature 39: Furniture/Object Placement Grid
- **Nintendo Source:** Animal Crossing: New Horizons
- **Description:** Place decorative objects (furniture, plants, lights) on a grid with free rotation. Objects snap to grid but can be offset. Supports layering and collision detection.
- **Kid UX:** Select object from visual catalog. Drag onto canvas. Ghost preview shows placement. Tap to confirm. Rotation handle appears — drag to spin. Grid shows available space. Objects can't overlap.
- **LLM Automation:** Manages object placement grid with collision detection, handles z-layering for depth sorting, validates placement constraints (e.g., table must be on floor), manages object persistence.
- **JSON Contract Extension:**
  ```json
  {
    "placedObjects": [
      {"id": "table_wood", "position": {"x": 10, "y": 5}, "rotation": 45, "layer": "furniture"}
    ]
  }
  ```

### Feature 40: Custom Pattern Designer
- **Nintendo Source:** Animal Crossing: New Horizons
- **Description:** Pixel-art style pattern editor where kids can design custom textures for clothing, floors, walls, and flags. Supports multiple brush sizes, color palettes, and shape tools.
- **Kid UX:** Open the pattern editor — a pixel grid appears. Color palette on the side (16 colors). Tap a color, tap grid cells to fill. Pen, line, rectangle, circle, fill-bucket tools. Preview shows pattern applied to an object in real-time.
- **LLM Automation:** Stores pattern as a 2D color array, generates texture assets from pattern data, applies patterns to 3D objects as decals/textures, handles pattern sharing/saving.
- **JSON Contract Extension:**
  ```json
  {
    "customPattern": {
      "gridSize": 32,
      "pixelData": [["#FF0000", "#00FF00", ...], ...],
      "palette": ["#FF0000", "#00FF00", "#0000FF", ...],
      "appliedTo": "flag_pole_001"
    }
  }
  ```

### Feature 41: Room/Interior Designer Mode
- **Nintendo Source:** Animal Crossing: Happy Home Paradise
- **Description:** Design complete room interiors with furniture, wallpaper, flooring, lighting, and decorations. Camera switches to interior view. Supports multi-room buildings.
- **Kid UX:** Place a building stamp on the world. Tap "Enter" to go inside. Interior view shows an empty room. Wallpaper and flooring selectable from visual swatches. Furniture palette appears. Drag-and-drop furniture placement.
- **LLM Automation:** Switches camera to interior orthographic view, manages room dimensions and wall/floor rendering, handles interior lighting, validates furniture placement within room bounds.
- **JSON Contract Extension:**
  ```json
  {
    "interiorDesign": {
      "roomDimensions": {"w": 10, "h": 8},
      "wallpaper": "wallpaper_stars",
      "flooring": "floor_wood",
      "furniture": [
        {"id": "bed", "x": 2, "y": 3, "rotation": 0}
      ]
    }
  }
  ```

### Feature 42: Seasonal Event System
- **Nintendo Source:** Animal Crossing: New Horizons
- **Description:** Time-based events that change the world based on real-world date — spring blossoms, summer fireworks, autumn leaves, winter snow. Special items and activities per season.
- **Kid UX:** A "Season" toggle in settings: Auto (uses real date), Spring, Summer, Fall, Winter. Visual changes apply instantly — grass color, tree leaves, sky color, weather effects. Seasonal item stamps appear in the palette.
- **LLM Automation:** Maps real-world date to season, applies seasonal visual theme to all terrain and objects, spawns seasonal-exclusive items, handles seasonal music transitions.
- **JSON Contract Extension:**
  ```json
  {"season": "autumn", "foliageColor": "#D2691E", "groundCover": "fallen_leaves", "seasonalItems": ["pumpkin", "acorn"]}
  ```

---

## 6. SPLATOON FEATURES

### Feature 43: Ink Painting Terrain
- **Nintendo Source:** Splatoon 1, 2, 3
- **Description:** The core mechanic — shooting ink onto terrain covers it in the player's color. Inked terrain provides movement bonuses (swimming in own ink), reloads ink tank, and enables stealth.
- **Kid UX:** Player character has a paint weapon. Tap/hold to shoot paint blobs. Paint splatters on terrain and changes its color to match the player's team. Player can transform into a "swim form" to move quickly through their own ink.
- **LLM Automation:** Manages ink coverage as a 2D texture overlay per team, calculates ink percentage per grid cell, handles swim-form collision and movement speed, manages ink tank depletion/refill.
- **JSON Contract Extension:**
  ```json
  {
    "inkSystem": {
      "teamColors": {"team1": "#FF00FF", "team2": "#00FF00"},
      "inkCoverage": [[0.0, 0.5, 1.0, ...], ...],
      "inkTank": {"capacity": 100, "current": 75, "refillRate": 10}
    }
  }
  ```

### Feature 44: Turf War (Paint Coverage Scoring)
- **Nintendo Source:** Splatoon 1, 2, 3
- **Description:** Game mode where teams compete to cover the most terrain with their ink. At match end, a "results" sequence shows the ink coverage expanding outward, revealing the winner dramatically.
- **Kid UX:** "Turf War" mode selected from mode menu. Timer counts down (3 minutes). Real-time score bar shows approximate coverage. At end, dramatic reveal — the screen fills with each team's color expanding from their painted areas. Percentage displayed.
- **LLM Automation:** Calculates ink coverage percentage per team each frame, manages match timer, generates dramatic reveal sequence (gradual fill animation from paint edges), determines winner.
- **JSON Contract Extension:**
  ```json
  {
    "turfWar": {
      "duration": 180,
      "teamCoverage": {"team1": 52.3, "team2": 47.7},
      "revealAnimation": "gradual_fill_from_edges"
    }
  }
  ```

### Feature 45: Weapon Type Variants (Shooter, Roller, Charger, Slosher, Brush)
- **Nintendo Source:** Splatoon 1, 2, 3
- **Description:** Five distinct weapon archetypes: Shooters (rapid fire, mid-range), Rollers (wide paint path, close-range), Chargers (snipe, charge for range), Sloshers (lob ink over walls), Brushes (fast sweep, mobile).
- **Kid UX:** Weapon selection screen shows 5 weapon category icons. Tap to see variants within each category. Each weapon shows stats as simple bars (range, speed, power). Weapon preview shows attack pattern animation.
- **LLM Automation:** Implements each weapon's unique firing pattern and projectile behavior, manages ink consumption per shot, handles weapon-specific hitboxes and damage values.
- **JSON Contract Extension:**
  ```json
  {
    "weapon": {
      "type": "roller",
      "variant": "splat_roller",
      "inkConsumption": 10,
      "paintWidth": 64,
      "range": 40,
      "damage": 50,
      "attackPattern": "ground_roll"
    }
  }
  ```

### Feature 46: Salmon Run (Co-op Horde Mode)
- **Nintendo Source:** Splatoon 2 & 3
- **Description:** 4-player co-op mode where teams fight waves of AI enemies (Salmonids), collect golden eggs, and deposit them in a central basket. Three waves with increasing difficulty. Boss enemies drop multiple eggs.
- **Kid UX:** "Salmon Run" mode button. Matchmaking with 3 other players or AI. Wave counter shows 1/3. Enemies spawn from the water's edge. Golden eggs glow and must be carried to the basket. Boss enemies have red glow and unique shapes.
- **LLM Automation:** Manages wave spawning logic (escalating enemy count/types), tracks golden egg collection state, handles boss enemy AI and defeat conditions, calculates team score and hazard level.
- **JSON Contract Extension:**
  ```json
  {
    "salmonRun": {
      "waves": 3,
      "currentWave": 1,
      "goldenEggQuota": 12,
      "collected": 8,
      "bossSpawns": [{"type": "steelhead", "timer": 30}],
      "hazardLevel": 120
    }
  }
  ```

### Feature 47: Tableturf Battle (Card Game Mode)
- **Nintendo Source:** Splatoon 3
- **Description:** A collectible card game where players place ink-pattern cards on a grid to claim territory. 12 turns, simultaneous placement. Special attacks ink over opponent's territory. 175+ collectible cards.
- **Kid UX:** Card collection screen shows cards with ink patterns and numbers. Deck builder — drag 15 cards into a deck. During play, 4 cards in hand. Tap a card, tap grid position to place. Special meter fills — when full, "Special Attack!" button flashes.
- **LLM Automation:** Validates card placement rules (must touch own ink), resolves simultaneous placement conflicts (lower number wins overlap), calculates special point generation, manages 12-turn game flow, determines winner by ink coverage.
- **JSON Contract Extension:**
  ```json
  {
    "tableturf": {
      "boardSize": {"w": 15, "h": 15},
      "deck": [{"cardId": 45, "pattern": [[1,1],[1,0]], "value": 8, "specialCost": 3}],
      "turn": 7,
      "specialPoints": 4,
      "inkCoverage": {"player1": 89, "player2": 76}
    }
  }
  ```

---

## 7. METROID SERIES FEATURES

### Feature 48: Morph Ball (Compact Form)
- **Nintendo Source:** Metroid Series
- **Description:** Player transforms into a small ball to fit through tight spaces, roll through tunnels, and lay bombs. A signature ability that opens up new navigation paths.
- **Kid UX:** Morph Ball stamp — player taps a button to transform into a small round form. Roll by pressing left/right. In tight tunnels, player auto-transforms. Bomb button drops small explosives that destroy specific blocks.
- **LLM Automation:** Swaps player collider to small circle, enables tunnel traversal, implements bomb placement with timer and explosion, handles bomb-jump physics (player launched by own bomb explosion).
- **JSON Contract Extension:**
  ```json
  {"morphBall": {"colliderRadius": 8, "rollSpeed": 150, "bombDamage": 1, "bombCooldown": 0.5, "bombJumpForce": 200}}
  ```

### Feature 49: Screw Attack (Invincible Spin Jump)
- **Nintendo Source:** Metroid Series
- **Description:** Player's spin jump becomes a weapon — a glowing energy field surrounds the player during jumps, destroying enemies on contact and breaking special blocks. Cumulative upgrade that changes traversal fundamentally.
- **Kid UX:** Player glows green/yellow during spin jumps. Enemies explode on contact. Special "Screw Attack Blocks" flash and break when touched. Trail of energy particles follows the player.
- **LLM Automation:** Adds damage hitbox during spin jump state, manages particle trail, handles enemy destruction on contact, validates screw-attack-block destruction.
- **JSON Contract Extension:**
  ```json
  {"screwAttack": {"damage": 10, "invincibleDuringSpin": true, "breaksScrewBlocks": true, "particleTrail": "energy_spiral"}}
  ```

### Feature 50: Speed Booster / Shinespark
- **Nintendo Source:** Metroid Series (Super Metroid, Dread)
- **Description:** Running in one direction for 3+ seconds activates Speed Booster — player glows and destroys blocks/enemies on contact. Can store the charge (Shinespark) and release it to fly in any direction at super speed, breaking through walls.
- **Kid UX:** Run button held for 3 seconds — player starts glowing yellow with speed lines. Keep running to maintain. Tap down to store charge (player flashes). Tap jump + direction to release Shinespark — player becomes a comet that smashes through everything.
- **LLM Automation:** Tracks horizontal velocity and direction for boost activation, manages charge storage state (Shinespark), applies boosted movement physics, handles wall/block destruction on contact during boost.
- **JSON Contract Extension:**
  ```json
  {
    "speedBooster": {
      "chargeTime": 3.0,
      "boostSpeed": 400,
      "canStoreCharge": true,
      "shinesparkDamage": 20,
      "breaksSpeedBlocks": true
    }
  }
  ```

### Feature 51: Ice Beam / Freeze Enemies
- **Nintendo Source:** Metroid Series
- **Description:** Projectile weapon that freezes enemies solid on hit. Frozen enemies become temporary platforms. Can be combined with other beam types for elemental effects.
- **Kid UX:** Ice beam fires a blue projectile. On hit, enemy turns blue and freezes in place. Player can jump on frozen enemies as platforms. After 5 seconds, enemy thaws. Multiple freeze cycles supported.
- **LLM Automation:** Applies freeze status effect (disables AI movement), changes enemy sprite to blue tint with ice overlay, enables player platform collision on frozen enemies, manages thaw timer.
- **JSON Contract Extension:**
  ```json
  {"iceBeam": {"projectileSpeed": 200, "freezeDuration": 5.0, "becomesPlatform": true, "thawDamage": 0}}
  ```

### Feature 52: Map System with Unexplored Areas
- **Nintendo Source:** Metroid Dread / All Metroid Games
- **Description:** Auto-mapping system that reveals rooms as the player explores. Unvisited areas are blank. Visited rooms show layout. Color-coded markers indicate item locations, save points, and unexplored doors.
- **Kid UX:** Map overlay accessible with a single button tap. Rooms appear as colored blocks. The player's current room pulses. Unexplored rooms are dark. Item markers (energy tanks, missiles) show as glowing dots. Doors the player hasn't been through shimmer.
- **LLM Automation:** Procedurally fills map data as player enters rooms, manages fog-of-war for unexplored areas, handles room color-coding by region, syncs item pickup state to map markers.
- **JSON Contract Extension:**
  ```json
  {
    "mapData": {
      "rooms": [{"id": "r_001", "visited": true, "bounds": {}, "exits": ["r_002"]}],
      "markers": [{"type": "energy_tank", "roomId": "r_003", "collected": false}]
    }
  }
  ```

### Feature 53: Wall Jump / Space Jump (Infinite Wall-Climbing)
- **Nintendo Source:** Metroid Series
- **Description:** Jump between opposing walls to climb vertical shafts. Space Jump upgrades this to infinite midair jumps for full flight capability.
- **Kid UX:** Jump toward a wall — player briefly clings. Tap jump to kick off in the opposite direction. Chain between two walls to climb. With Space Jump, spin in air and tap jump repeatedly to fly.
- **LLM Automation:** Detects wall collision during air state, enables brief wall-cling (0.3s), applies wall-kick velocity vector, Space Jump removes cling requirement for infinite air jumps.
- **JSON Contract Extension:**
  ```json
  {"wallJump": {"clingTime": 0.3, "kickVelocity": {"x": 150, "y": -180}, "spaceJump": false}}
  ```

---

## 8. PIKMIN SERIES FEATURES

### Feature 54: Pikmin Type System (Elemental Companions)
- **Nintendo Source:** Pikmin Series
- **Description:** Color-coded companion creatures with elemental resistances and unique abilities. Red (fireproof, strong attack), Blue (waterproof, swim), Yellow (electricity-proof, throw high), Purple (heavy, strong carry), White (fast, poison-resistant), Rock (hard, break crystals), Winged (fly, carry over obstacles), Ice (freeze water and enemies).
- **Kid UX:** Pikmin sprouts appear in the ground. Tap to pluck. Color-coded stem flowers identify type. Tap "Throw" button + direction to toss Pikmin. Pikmin auto-return if they miss. Type icons in HUD show how many of each are in the squad.
- **LLM Automation:** Manages Pikmin squad composition and count per type, implements type-specific behaviors and immunities, handles Pikmin throwing physics and return logic, manages elemental damage/resistance calculations.
- **JSON Contract Extension:**
  ```json
  {
    "pikminTypes": [
      {"color": "red", "immuneTo": "fire", "attackMultiplier": 1.5, "canSwim": false},
      {"color": "blue", "immuneTo": "water", "attackMultiplier": 1.0, "canSwim": true},
      {"color": "ice", "immuneTo": "freeze", "attackMultiplier": 0.7, "freezeAbility": true}
    ]
  }
  ```

### Feature 55: Pikmin Squad Management (Throw, Recall, Swarm)
- **Nintendo Source:** Pikmin Series
- **Description:** Command a squad of up to 100 Pikmin. Throw individual Pikmin to attack enemies, carry objects, or activate mechanisms. Whistle to recall scattered Pikmin. Swarm command sends all Pikmin rushing forward.
- **Kid UX:** "Whistle" button (circle around player) — tap to recall. "Throw" — tap and drag to aim, release to throw one Pikmin at a time. "Swarm" — tap to send all Pikmin rushing in the facing direction. Squad number shows as a counter.
- **LLM Automation:** Manages squad list with individual Pikmin state, implements throw arc and targeting, handles whistle recall with pathfinding, manages swarm behavior and collision.
- **JSON Contract Extension:**
  ```json
  {"squad": {"maxSize": 100, "currentPikmin": [{"type": "red", "state": "following"}], "commandMode": "throw"}}
  ```

### Feature 56: Object Carrying & Transport Puzzles
- **Nintendo Source:** Pikmin Series
- **Description:** Objects (fruit, ship parts, treasures) require a certain number of Pikmin to carry. Pikmin walk in formation around the object and carry it back to base. Heavy objects need more Pikmin (Purple = 10x carry strength).
- **Kid UX:** Object stamps show a number indicating "Pikmin needed." When enough Pikmin are thrown at an object, they automatically grab it and begin carrying. A dotted line shows the path back to base. Progress bar shows carrying completion.
- **LLM Automation:** Calculates carry weight vs. assigned Pikmin strength, generates carrying formation positions, manages pathfinding back to base, handles speed based on Pikmin count, manages object delivery and reward.
- **JSON Contract Extension:**
  ```json
  {"carryObject": {"id": "fruit_001", "weight": 15, "assignedPikmin": 8, "destination": "onion_base", "progress": 0.6}}
  ```

### Feature 57: Time-of-Day Cycle with Day Limit
- **Nintendo Source:** Pikmin Series
- **Description:** Each game "day" has a time limit (approx. 13-18 minutes). Sun moves across the sky. At sunset, all Pikmin must be recalled or they are lost. Creates urgency and strategic decision-making.
- **Kid UX:** Sun position shown at top of screen as an arc. Timer shows remaining daylight. Sky color transitions from blue to orange to red as time passes. Warning chime at 1-minute remaining. At sunset, screen darkens and any stranded Pikmin are shown.
- **LLM Automation:** Manages game time progression (scaled from real time), updates sun position and sky color gradient, triggers sunset sequence and end-of-day evaluation, handles stranded Pikmin consequences.
- **JSON Contract Extension:**
  ```json
  {"dayCycle": {"dayLength": 900, "currentTime": 600, "sunsetWarningAt": 60, "skyGradient": ["#4A90D9", "#F5A623", "#D0021B"]}}
  ```

### Feature 58: Onion Base (Creature Spawning & Healing)
- **Nintendo Source:** Pikmin Series
- **Description:** The Onion is the player's home base — a floating creature that sprouts new Pikmin from collected nutrients, heals Pikmin, and serves as the transport destination. Different colored Onions for each Pikmin type.
- **Kid UX:** Onion stamp floats above the ground. Tap to open a menu: "Sprout Pikmin" (converts collected items into new sprouts), "Heal" (recalls injured Pikmin for recovery), "Deposit" (drops off carried objects). Visual sprouts grow from the ground nearby.
- **LLM Automation:** Manages Onion inventory (nutrients/seeds), calculates Pikmin sprout generation rate, handles Pikmin healing over time, processes object deposits and reward distribution.
- **JSON Contract Extension:**
  ```json
  {"onion": {"color": "red", "position": {}, "storedNutrients": 45, "pikminCapacity": 100, "activeSprouts": 12}}
  ```

---

## 9. CROSS-CUTTING DESIGN PRINCIPLES

### Feature 59: Nintendo's "Kishotenketsu" (Non-Conflict Progression)
- **Nintendo Source:** Across all Nintendo games
- **Description:** Nintendo's signature level design pattern: Introduce (new mechanic), Develop (expand possibilities), Twist (subvert expectations), Conclusion (synthesize learning). Levels teach through play, not tutorials.
- **Kid UX:** Level flow naturally introduces one new element at a time. First encounter is safe (no death). Second encounter combines with known elements. Third encounter surprises. Kid learns without frustration.
- **LLM Automation:** Analyzes level layout for learning curve validity, suggests element introduction ordering, validates difficulty progression, generates optional hint talking-flowers for stuck players.
- **JSON Contract Extension:**
  ```json
  {"levelFlow": {"introduceAt": 10, "developAt": 40, "twistAt": 70, "conclusionAt": 90, "element": "on_off_switch"}}
  ```

### Feature 60: Progressive Disclosure (Tools Unlock Over Time)
- **Nintendo Source:** Animal Crossing, Mario Maker Story Mode
- **Description:** Not all tools are available immediately. Kids unlock new stamps, abilities, and features by playing and completing simple challenges. Prevents overwhelming new users.
- **Kid UX:** New features appear grayed out with a lock icon. A tooltip shows "Complete 3 levels to unlock!" When unlocked, a celebratory animation plays with the new tool glowing. Unlocks feel like rewards.
- **LLM Automation:** Manages player progression state, validates unlock conditions, triggers unlock events with animations, handles feature gating based on player experience level.
- **JSON Contract Extension:**
  ```json
  {"unlocks": [{"featureId": "wonder_flower", "condition": "complete_3_levels", "unlocked": false}]}
  ```

### Feature 61: Emergent Physics Playground
- **Nintendo Source:** Zelda: BotW/TotK, Mario Maker
- **Description:** Objects follow consistent physics rules that combine in unexpected ways. A fan + balloon + basket = hot air balloon. A bomb + slope = bowling. The game doesn't script these — physics does.
- **Kid UX:** Place any objects. They interact naturally. There's no "wrong" way to combine things. Combinations that "should" work intuitively (fan pushing a cart) actually do. Kids feel like inventors.
- **LLM Automation:** Physics engine handles rigid body dynamics, collision responses, force application from devices, joint constraints for glued objects. Ensures consistent, intuitive behavior.
- **JSON Contract Extension:**
  ```json
  {"physics": {"gravity": 500, "friction": 0.3, "restitution": 0.4, "enableEmergentCombinations": true}}
  ```

### Feature 62: Share & Remix (Community Content)
- **Nintendo Source:** Mario Maker Course World, Animal Crossing Dream Islands, Splatoon Shared Designs
- **Description:** Players can share their creations with others via codes, and play/remix creations from other players. Remixing creates a copy that can be modified while crediting the original creator.
- **Kid UX:** "Share" button generates a simple 6-character code (e.g., "ABC-123"). "Play Others" shows trending creations as thumbnails. "Remix" button on any creation makes an editable copy. Original creator credited.
- **LLM Automation:** Manages content storage and retrieval, generates shareable codes, handles content moderation filters, tracks remix lineage, manages trending/popularity algorithms.
- **JSON Contract Extension:**
  ```json
  {"sharing": {"code": "ABC-123", "originalCreator": "KidDesigner5", "remixOf": null, "likes": 42, "plays": 156}}
  ```

---

## IMPLEMENTATION PRIORITY MATRIX

| Priority | Feature | Complexity | Impact | Source Game |
|----------|---------|-----------|--------|-------------|
| P0 | Stamp-Based Course Part Placement | Medium | Critical | Mario Maker |
| P0 | Theme Switching (Day/Night) | Low | High | Mario Maker 2 |
| P0 | Copy Ability System | Medium | High | Kirby |
| P0 | Ink Painting Terrain | High | High | Splatoon |
| P0 | Morph Ball | Low | Medium | Metroid |
| P1 | Clear Conditions | Medium | High | Mario Maker 2 |
| P1 | Sub-Areas (Warp Pipes) | Medium | High | Mario Maker |
| P1 | Badge Equip System | Medium | High | Mario Wonder |
| P1 | Wonder Flower | High | Very High | Mario Wonder |
| P1 | Elemental Chemistry Engine | High | High | Zelda BotW |
| P1 | Pikmin Type System | Medium | Medium | Pikmin |
| P1 | Terrain Sculpting | High | Medium | Animal Crossing |
| P2 | Enemy Modifiers | Low | Medium | Mario Maker |
| P2 | ON/OFF Switch System | Low | Medium | Mario Maker 2 |
| P2 | Checkpoint Flags | Low | Medium | Mario Maker |
| P2 | Slopes | Low | Medium | Mario Maker 2 |
| P2 | Parachute Cap Badge | Low | Medium | Mario Wonder |
| P2 | Ultrahand (Grab/Glue) | High | High | Zelda TotK |
| P2 | Autobuild Blueprints | Medium | High | Zelda TotK |
| P2 | Copy Ability Mixing | Medium | Medium | Kirby 64 |
| P2 | Helper Characters | Medium | Medium | Kirby |
| P2 | Turf War Scoring | Medium | High | Splatoon |
| P2 | Weapon Type Variants | Medium | Medium | Splatoon |
| P2 | Screw Attack | Low | Medium | Metroid |
| P2 | Speed Booster | Medium | Medium | Metroid |
| P2 | Pikmin Squad Management | Medium | Medium | Pikmin |
| P3 | Auto-Scroll Control | Low | Low | Mario Maker |
| P3 | Track System | Medium | Medium | Mario Maker |
| P3 | Sound Effect Stamps | Low | Low | Mario Maker |
| P3 | World Map Builder | High | Medium | Mario Maker 2 |
| P3 | Clear Pipes | Medium | Medium | Mario Maker 2 |
| P3 | Koopaling Bosses | Medium | Low | Mario Maker 2 |
| P3 | Wall-Climb Jump Badge | Low | Medium | Mario Wonder |
| P3 | Grappling Vine Badge | Medium | Medium | Mario Wonder |
| P3 | Invisibility Badge | Low | Low | Mario Wonder |
| P3 | Spring Feet Badge | Low | Low | Mario Wonder |
| P3 | Safety Bounce Badge | Low | Medium | Mario Wonder |
| P3 | Talking Flower | Low | Medium | Mario Wonder |
| P3 | Dual Badge Combinations | Medium | Medium | Mario Wonder |
| P3 | Zonai Device Gadgets | High | High | Zelda TotK |
| P3 | Recall (Rewind) | Medium | Medium | Zelda TotK |
| P3 | Ascend | Low | Medium | Zelda TotK |
| P3 | Portable Cooking Pot | Medium | Low | Zelda TotK |
| P3 | Super Abilities | Medium | Low | Kirby |
| P3 | Mouthful Mode | High | Medium | Kirby |
| P3 | Furniture/Object Placement | Medium | Low | Animal Crossing |
| P3 | Custom Pattern Designer | Medium | Low | Animal Crossing |
| P3 | Room/Interior Designer | High | Low | Animal Crossing HHP |
| P3 | Seasonal Event System | Low | Low | Animal Crossing |
| P3 | Salmon Run (Horde Mode) | High | Medium | Splatoon |
| P3 | Tableturf Battle | High | Low | Splatoon 3 |
| P3 | Ice Beam | Low | Low | Metroid |
| P3 | Map System | Medium | Medium | Metroid |
| P3 | Wall Jump / Space Jump | Medium | Medium | Metroid |
| P3 | Object Carrying Puzzles | Medium | Medium | Pikmin |
| P3 | Time-of-Day Cycle | Low | Low | Pikmin |
| P3 | Onion Base | Medium | Low | Pikmin |

---

## SUMMARY OF KEY NINTENDO DESIGN PRINCIPLES FOR KidGameMaker

1. **Immediate Visual Feedback** — Every action produces an instant, delightful visual/sound response. No delayed gratification.

2. **Progressive Complexity** — Start with one mechanic, layer in complexity. Never overwhelm on screen one.

3. **Joyful Discovery** — Hide surprises. The "aha!" moment is Nintendo's core currency. Wonder Flowers embody this.

4. **Consistent Internal Logic** — Once a rule is learned, it always applies. Fire always burns wood. Pikmin always drown in water (except Blue). Kids build mental models.

5. **No Wrong Answers** — In creation mode, there's no failure. In play mode, death is a teaching tool, not punishment. Safety Bounce from Mario Wonder is the model.

6. **Share & Celebrate** — Every creation wants an audience. Mario Maker's Course World, Animal Crossing's Dream Islands — sharing is the loop.

7. **Tactile Satisfaction** — Every interaction should "feel" good — bounce squash, ink splat, brick break. Physics and particles matter.

8. **Player as Magician** — Zelda's chemistry engine makes the player feel smart. The game doesn't tell you metal attracts lightning — it lets you discover it.

---

*This document serves as the primary design reference for extracting Nintendo-inspired features into the KidGameMaker platform. Each feature has been analyzed for its suitability for ages 5+ with zero-code, stamp-based interaction.*
