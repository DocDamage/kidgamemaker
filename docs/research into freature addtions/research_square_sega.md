# KidGameMaker Feature Research: Square Enix & Sega Game Design Patterns

> **Research Scope**: Deep-dive analysis of 10 major Square Enix and Sega game franchises to extract 40+ specific, actionable feature ideas for KidGameMaker -- a kid-friendly (ages 5+), zero-code, stamp-based 2D platformer game creation suite.
> **Methodology**: Every feature is reverse-engineered from canonical game mechanics and reimagined for a stamp-based visual editor where a built-in LLM handles all code, logic, and system complexity invisibly.
> **Games Analyzed**: Final Fantasy series, Kingdom Hearts series, Chrono Trigger, Dragon Quest Builders 1 & 2, Sonic the Hedgehog (Mania / S3&K), NiGHTS into Dreams, Seaman, Streets of Rage 4, Odin Sphere / Muramasa, Secret of Mana / Trials of Mana.

---

## Table of Contents

1. [Transformation & Form Systems](#1-transformation--form-systems)
2. [Class & Role Systems](#2-class--role-systems)
3. [Combo & Synergy Systems](#3-combo--synergy-systems)
4. [Elemental & Status Systems](#4-elemental--status-systems)
5. [Building & Crafting Systems](#5-building--crafting-systems)
6. [Movement & Traversal Systems](#6-movement--traversal-systems)
7. [Companion & Pet Systems](#7-companion--pet-systems)
8. [Progression & Mastery Systems](#8-progression--mastery-systems)
9. [World & Narrative Systems](#9-world--narrative-systems)
10. [Minigame & Arcade Systems](#10-minigame--arcade-systems)

---

## 1. Transformation & Form Systems

### Feature 1: Summon Beast Call

- **Feature Name**: Summon Beast Call
- **Source**: Final Fantasy series (Ifrit, Shiva, Ramuh, Bahamut, Odin, Alexander, etc.)
- **Description**: The player stamps a "Summoning Circle" object on the canvas. During gameplay, when the player character stands on the circle and presses the action button, a massive summoned creature appears in the background and executes a spectacular screen-filling elemental attack. Each summon has a unique element (fire, ice, lightning, earth, holy, dark) and visual effect. After use, the circle goes on cooldown and glows dim until recharged.
- **Kid UX**: The child stamps a Summon Circle stamp on the level canvas, then taps a sticker to pick which beast appears (Ifrit for fire, Shiva for ice, etc.). A simple "Use Once Per Level" toggle can be set with a single tap. No numbers, no menus -- just tap the sticker and place.
- **LLM Automation**: The LLM generates the summon entry animation (creature rising from a portal), the attack effect (particle systems, screen shake, damage zones), elemental damage calculation, cooldown timer logic, and auto-balances damage based on level size and enemy count.
- **JSON Contract Extension**:
  ```json
  {
    "objects": [{
      "type": "summon_circle",
      "summon_id": "shiva",
      "element": "ice",
      "uses_per_level": 1,
      "cooldown_seconds": 0,
      "auto_damage_scale": true,
      "visual_tier": "epic"
    }]
  }
  ```

---

### Feature 2: Super Transformation Emeralds

- **Feature Name**: Super Transformation Emeralds
- **Source**: Sonic the Hedgehog 3 & Knuckles / Sonic Mania (Chaos Emeralds, Super Sonic)
- **Description**: Hidden throughout the level are 7 special gems (Emeralds). Collecting all 7 transforms the player character into a glowing, invincible super form with enhanced speed, a sparkly aura trail, and the ability to destroy any enemy on contact. The super form lasts for a timed duration with a draining energy meter. Hidden emerald locations can be placed via stamp.
- **Kid UX**: The child stamps the 7 Emerald stamps anywhere in the level (hidden inside question blocks, behind walls, etc.). A single toggle sets "Super Form Enabled." When a kid playtests and finds all 7, their character automatically transforms with a big flashy animation. No stat editing -- the system handles everything.
- **LLM Automation**: The LLM tracks emerald collection state, triggers the transformation sequence (invincibility, aura particles, speed boost, music change), implements the countdown timer with visual meter, handles the super-jump and enemy-destruction-on-contact logic, and restores normal form when time expires.
- **JSON Contract Extension**:
  ```json
  {
    "collectibles": {
      "emerald_set": {
        "count": 7,
        "transform_to": "super_form",
        "duration_seconds": 30,
        "effects": ["invincible", "speed_x2", "destroy_on_contact", "aura_trail"],
        "drain_rate": "gradual"
      }
    }
  }
  ```

---

### Feature 3: Drive Form Wardrobe

- **Feature Name**: Drive Form Wardrobe
- **Source**: Kingdom Hearts II (Valor Form, Wisdom Form, Master Form, Final Form, Limit Form, Anti Form)
- **Description**: The player can stamp a "Wardrobe" or "Transformation Gate" object. When the player character interacts with it, they switch to an alternate form with different abilities. Each form has a distinct visual style and power set: Speed Form (faster running, double jump), Magic Form (ranged spells, floating), Power Form (stronger attacks, ground pound), and Flight Form (gliding, hovering). Forms can be unlocked progressively or available from the start.
- **Kid UX**: The child stamps a "Wardrobe Gate" on the canvas. A sticker picker shows available forms with cute icons (bunny ears for speed, star wand for magic, muscle badge for power, wings for flight). The child taps one to assign. During play, walking through the gate instantly transforms the character with a sparkly animation.
- **LLM Automation**: The LLM manages form state switching, applies form-specific movement modifiers (speed, jump height, gravity), auto-generates form-unique animations from the base character sprite, handles form exit conditions (time limit or manual revert), and ensures form abilities feel meaningfully distinct.
- **JSON Contract Extension**:
  ```json
  {
    "objects": [{
      "type": "wardrobe_gate",
      "available_forms": ["speed", "magic", "power", "flight"],
      "form_duration": "infinite_or_timed",
      "revert_on_damage": false,
      "transform_fx": "sparkle_burst"
    }]
  }
  ```

---

### Feature 4: Shapeshift Environment Morph

- **Feature Name**: Shapeshift Environment Morph
- **Source**: NiGHTS into Dreams (NiGHTS transforms into mermaid, bobsled, roller coaster car based on level zones)
- **Description**: When the player character enters a specific zone (water area, ice slope, sky rail), they automatically morph into a context-appropriate form. In water: mermaid form with swimming physics. On ice slopes: sled form with slide controls. On sky rails: coaster form with rail-grinding. The morph is automatic and purely visual + physics-based -- no manual activation needed.
- **Kid UX**: The child stamps a "Water Zone," "Ice Zone," or "Rail Zone" area stamp over a region of the level. When they playtest, their character automatically transforms upon entering. The child can pick which morph form each zone uses from a sticker picker.
- **LLM Automation**: The LLM detects zone overlap, triggers the morph transition (smooth animation blend), swaps physics parameters for the zone (water = buoyancy + drag, ice = reduced friction + momentum, rail = locked path + speed boost), and auto-generates the morph sprites by compositing the character with the form theme.
- **JSON Contract Extension**:
  ```json
  {
    "zones": [{
      "type": "morph_zone",
      "zone_type": "water|ice|rail|wind",
      "morph_form": "mermaid|sled|coaster|balloon",
      "transition_speed": "smooth_0.5s",
      "physics_override": true
    }]
  }
  ```

---

### Feature 5: Triple-Tech Fusion Crystals

- **Feature Name**: Triple-Tech Fusion Crystals
- **Source**: Chrono Trigger (Delta Force, Delta Storm, Lifeline, Omega Flare -- triple tech combos)
- **Description**: Three player characters (or two AI companions + player) can combine their powers at a "Fusion Crystal" object to unleash a devastating triple attack. Each combination of character types produces a unique cinematic attack with combined elemental effects. For example: Fire + Ice + Lightning = "Delta Force" (shadow elemental blast). Healer + Fighter + Mage = "Lifeline" (party auto-revive aura).
- **Kid UX**: The child stamps three "Companion Start Points" (Buddy A, Buddy B, Buddy C) and one "Fusion Crystal" in the level. They tap each companion to pick its type from stickers (Fighter, Mage, Healer, Rogue). When playtesting, companions follow the player. Standing near the crystal with all three nearby triggers the big combo automatically.
- **LLM Automation**: The LLM calculates valid triple-tech combinations from the three assigned classes, generates the combo name and visual effect based on element fusion rules, handles companion AI pathfinding to stay near the player, triggers the cinematic camera + attack sequence, and computes area-of-effect damage or buff application.
- **JSON Contract Extension**:
  ```json
  {
    "companions": [
      {"id": "buddy_a", "class": "fighter", "element": "fire"},
      {"id": "buddy_b", "class": "mage", "element": "ice"},
      {"id": "buddy_c", "class": "healer", "element": "lightning"}
    ],
    "objects": [{
      "type": "fusion_crystal",
      "auto_trigger_radius": 100,
      "combo_result": "auto_calculated",
      "cinematic_duration": 3.0
    }]
  }
  ```

---

## 2. Class & Role Systems

### Feature 6: Job Badge System

- **Feature Name**: Job Badge System
- **Source**: Final Fantasy series (Warrior, Black Mage, White Mage, Thief, Dragoon, Monk, Paladin, Blue Mage, Time Mage, etc.)
- **Description**: The player character can collect "Job Badges" scattered through the level. Each badge changes the character's outfit, abilities, and playstyle when equipped. Warrior = sword swipe attack + shield block. Mage = fireball projectile from wand. Thief = fast dash + can find hidden coins. Dragoon = super-high jump + dive attack. Blue Mage = copies enemy abilities after touching them.
- **Kid UX**: The child stamps "Job Badge" items throughout the level. Tapping a badge on the canvas opens a sticker picker to choose the job (sword icon for Warrior, wand for Mage, mask for Thief, spear for Dragoon, rainbow crystal for Blue Mage). During play, touching a badge immediately swaps the character's outfit and abilities with a swirl effect. A "Job Hub" stamp lets the player swap between collected jobs.
- **LLM Automation**: The LLM generates job-appropriate sprite variations (hat swaps, weapon additions), implements each job's unique attack pattern and movement modifier, handles job-switching state management, auto-balances job power so no job is "best," and generates unique sound effects per job action.
- **JSON Contract Extension**:
  ```json
  {
    "job_system": {
      "available_jobs": ["warrior", "mage", "thief", "dragoon", "blue_mage", "monk"],
      "switch_method": "badge_touch|job_hub_menu",
      "persist_between_levels": true,
      "auto_balance_jobs": true,
      "sprite_variants": "auto_generated"
    }
  }
  ```

---

### Feature 7: Paradigm Role Switcher

- **Feature Name**: Paradigm Role Switcher
- **Source**: Final Fantasy XIII (Paradigm Shift system -- Commando, Ravager, Sentinel, Synergist, Saboteur, Medic)
- **Description**: Up to three companion characters fight alongside the player, and each can be assigned one of six roles. At any time during gameplay, the player can tap a role icon to instantly switch all companions' roles. Roles change companion behavior entirely: Fighter attacks enemies, Defender draws enemy attention and blocks, Healer restores player health, Booster gives player stat buffs, Trickster applies status ailments to enemies, Blaster builds combo meter.
- **Kid UX**: The child stamps "Buddy Start Points" and assigns each a role via stickers. During playtest, role icons appear as large, colorful buttons at the bottom of the screen. Tapping any button instantly swaps all buddies to that role set with a flash effect. Roles are shown with simple icons: sword (Fighter), shield (Defender), heart (Healer), up-arrow (Booster), sparkle (Trickster), explosion (Blaster).
- **LLM Automation**: The LLM implements the six AI behavior trees (each role has distinct decision-making), manages role-switch state transitions, auto-generates role-specific visual indicators (aura colors, weapon glows), handles companion positioning logic (Defender moves to front, Healer stays back), and computes combo multipliers from Blaster role.
- **JSON Contract Extension**:
  ```json
  {
    "paradigm_system": {
      "roles": ["fighter", "defender", "healer", "booster", "trickster", "blaster"],
      "buddy_count": 3,
      "switch_cooldown": 2.0,
      "ai_behaviors": "role_determined",
      "visual_indicators": "auto_generated"
    }
  }
  ```

---

### Feature 8: Class Evolution Tree

- **Feature Name**: Class Evolution Tree
- **Source**: Trials of Mana (class change system: Fighter -> Knight -> Paladin / etc.)
- **Description**: As the player collects experience stars throughout levels, their character can evolve into advanced classes at "Class Statues." Each class branches into two options. Starting as a Novice, they can become a Fighter (melee focus) or an Apprentice (magic focus). Fighter evolves into Knight (balanced) or Berserker (high damage, low defense). Apprentice evolves into Sorcerer (elemental magic) or Cleric (healing support). Each evolution grants a new visual outfit and new ability.
- **Kid UX**: The child stamps "Class Statues" in their levels. When playtesting, after collecting enough stars, the player's character glows and a prompt appears: "Touch statue to evolve!" At the statue, two large stickers show the evolution choices. The child taps one to pick. The character transforms with a big celebratory animation.
- **LLM Automation**: The LLM tracks star collection (invisible XP), determines when evolution thresholds are met, generates the evolution branch UI (showing two clear choices with icons), implements the stat and ability changes per class, auto-generates the upgraded sprite variants, and ensures each evolution path feels meaningfully different.
- **JSON Contract Extension**:
  ```json
  {
    "class_tree": {
      "starting_class": "novice",
      "tiers": [
        {"tier": 1, "branches": ["fighter", "apprentice"]},
        {"tier": 2, "fighter_branches": ["knight", "berserker"], "apprentice_branches": ["sorcerer", "cleric"]}
      ],
      "evolution_threshold": "stars_collected",
      "statue_type": "class_statue",
      "auto_sprites": true
    }
  }
  ```

---

## 3. Combo & Synergy Systems

### Feature 9: Double-Tech Buddy Combos

- **Feature Name**: Double-Tech Buddy Combos
- **Source**: Chrono Trigger (X-Strike, Fire Sword, Ice Sword, Antipode Bomb, Drill Kick, etc.)
- **Description**: When two characters with compatible abilities are near each other, they can perform a combined attack. Examples: Fighter + Mage = "Fire Sword" (sword swing with fire trail). Mage + Healer = "Aura Beam" (heals all allies). Two Fighters = "X-Strike" (crossing slash attack). The combo triggers automatically when both characters attack near-simultaneously.
- **Kid UX**: The child stamps two "Buddy Start Points" and picks each buddy's type from stickers. The LLM auto-calculates what combo they produce (shown in a cute thought bubble when placing). During play, buddies follow the player. When the player attacks while a buddy is nearby, there's a chance the combo triggers with a flashy animation and the combo name appears in big letters.
- **LLM Automation**: The LLM maintains a combo compatibility matrix (which class pairs produce which combos), detects proximity and simultaneous attack timing, triggers the combo cinematic, computes combined damage/healing values, generates combo names dynamically (e.g., "[ClassA] + [ClassB] = [ComboName]"), and handles the buddy AI to stay in combo range.
- **JSON Contract Extension**:
  ```json
  {
    "buddy_combos": {
      "pairs": [{
        "classes": ["fighter", "mage"],
        "combo_name": "auto_generated",
        "trigger": "proximity_attack",
        "chance_percent": 40
      }],
      "visual_fx": "cinematic_flash",
      "buddy_ai_range": 80
    }
  }
  ```

---

### Feature 10: Limit Break Rage Meter

- **Feature Name**: Limit Break Rage Meter
- **Source**: Final Fantasy VII/VIII/IX/X (Limit Break, Overdrive, Trance, Dyne)
- **Description**: As the player defeats enemies or takes damage, a "Rage Meter" fills up around their character portrait. When full, the character glows and their next attack becomes a devastating Limit Break -- a unique, cinematic super-attack. Each character class has a different Limit Break visual. Warrior = massive spinning sword slash. Mage = screen-filling elemental explosion. Thief = lightning-fast multi-hit dash attack.
- **Kid UX**: The child stamps a "Limit Break Orb" in the level (or enables it globally). No other configuration needed. During play, a colorful meter appears around the character and fills up with rainbow energy. When full, the character flashes gold and the next attack button press triggers the huge Limit Break animation. Simple and visceral.
- **LLM Automation**: The LLM tracks damage dealt, damage taken, and enemies defeated to fill the meter, detects when the meter is full, triggers the Limit Break state (gold aura, screen border effect), implements the unique attack pattern per class (different hitboxes, durations, visual effects), applies appropriate damage scaling, and resets the meter after use.
- **JSON Contract Extension**:
  ```json
  {
    "limit_break": {
      "meter_fill_methods": ["deal_damage", "take_damage", "defeat_enemy"],
      "max_meter": 100,
      "class_limit_breaks": {
        "warrior": "spinning_slash",
        "mage": "elemental_burst",
        "thief": "multi_dash"
      },
      "visual_cinematic": true,
      "invincible_during": true,
      "meter_persistence": "per_level"
    }
  }
  ```

---

### Feature 11: Link Chain Score Multiplier

- **Feature Name**: Link Chain Score Multiplier
- **Source**: NiGHTS into Dreams (Link chaining system -- collecting items in quick succession builds score multiplier)
- **Description**: When the player collects items (rings, coins, gems) in rapid succession, a "Link Chain" counter builds up. The higher the chain, the bigger a score multiplier applies. A glowing trail connects recently collected items. If too much time passes between collections, the chain breaks and the multiplier is cashed out as bonus points. This creates a risk/reward tension -- should the player rush for the next item or play safe?
- **Kid UX**: The child enables "Link Chains" with a single toggle on the level settings. During play, collected items connect with a sparkly trail. A big number appears showing the current chain. When the chain breaks, a celebratory "BONUS!" popup shows the multiplied score. The child can stamp "Chain Item" clusters to create natural chain paths through their level.
- **LLM Automation**: The LLM implements the chain timer (decays over ~2 seconds), tracks the chain counter, computes the multiplier formula (1.5x at 5, 2x at 10, 3x at 20, etc.), draws the visual connecting trail between items, handles the chain break event with bonus calculation and popup, and auto-suggests item cluster placements when the child is designing.
- **JSON Contract Extension**:
  ```json
  {
    "link_chain": {
      "enabled": true,
      "chain_decay_seconds": 2.0,
      "multiplier_tiers": [
        {"chain": 5, "multiplier": 1.5},
        {"chain": 10, "multiplier": 2.0},
        {"chain": 20, "multiplier": 3.0},
        {"chain": 50, "multiplier": 5.0}
      ],
      "visual_trail": "sparkle_line",
      "break_fx": "bonus_popup"
    }
  }
  ```

---

### Feature 12: Reaction Command Context Attacks

- **Feature Name**: Reaction Command Context Attacks
- **Source**: Kingdom Hearts II (Reaction Commands -- context-sensitive button prompts during combat)
- **Description**: When the player is near certain enemies, objects, or allies, a large context-sensitive action button appears. Pressing it performs a special cinematic move: vaulting over an enemy, countering a boss attack, riding a missile back at the shooter, swinging from a chandelier, or team-up attacks with allies. Each context has a unique, dramatic result.
- **Kid UX**: The child stamps "Reaction Targets" on enemies or objects. Tapping the stamp opens a sticker picker showing reaction types: "Bounce Off" (launch from enemy), "Ride" (hop on and control), "Counter" (auto-dodge and strike back), "Team Up" (ally joins attack), "Swing" (grab and swing from). During play, when near the target, a big glowing button appears. Tap = spectacular reaction move.
- **LLM Automation**: The LLM detects proximity between player and reaction targets, displays the appropriate contextual prompt, implements the reaction move (unique animation, camera angle, damage calculation), handles invincibility frames during the reaction, and chains reactions together if multiple targets are in range (creating combo reactions).
- **JSON Contract Extension**:
  ```json
  {
    "reaction_commands": [{
      "target_type": "enemy|object|ally",
      "reaction_type": "bounce|ride|counter|team_up|swing",
      "trigger_radius": 60,
      "invincible_during": true,
      "cinematic": true,
      "chainable": true
    }]
  }
  ```

---

### Feature 13: Beat-'Em-Up Combo Juggling

- **Feature Name**: Beat-'Em-Up Combo Juggling
- **Source**: Streets of Rage 4 (juggle combos, wall bounces, ground bounces, combo scoring tiers)
- **Description**: The platformer can include beat-'em-up style combat sections where enemies can be launched into the air and juggled with consecutive hits. Enemies bounce off screen edges (wall bounces) and can be kept airborne indefinitely with skill. A combo meter tracks consecutive hits with color-coded tiers: Yellow (Nice!), Orange (Great!), Green (Super!), Blue (Excellent!), Purple (Amazing!), Pink (Sick!), Red (Out Of This World!!!). Higher combos give exponentially more points.
- **Kid UX**: The child stamps "Brawler Zone" over a section of the level. Within this zone, combat becomes juggle-friendly. The child stamps enemy spawners and can place "Wall Bounce" boundary markers. During play, hitting enemies feels punchy and satisfying, with big hit-stop pauses on impact. The combo meter appears automatically with flashy tier names. When the combo ends, a huge bonus number counts up.
- **LLM Automation**: The LLM implements hit-stop frames (brief pause on impact for impact feel), gravity reduction on launched enemies, wall bounce physics, ground bounce detection, the combo timer (resets after ~4 seconds without a hit), tier calculation and color progression, exponential score formula, and ensures enemies don't get stuck off-screen.
- **JSON Contract Extension**:
  ```json
  {
    "brawler_zone": {
      "juggle_physics": {"gravity_scale": 0.4, "launch_power": 15},
      "wall_bounces": true,
      "ground_bounces": true,
      "combo_tiers": [
        {"hits": 8, "name": "Nice!", "color": "yellow"},
        {"hits": 16, "name": "Great!", "color": "orange"},
        {"hits": 30, "name": "Super!", "color": "green"},
        {"hits": 50, "name": "Excellent!!", "color": "blue"},
        {"hits": 75, "name": "Amazing!!", "color": "purple"},
        {"hits": 100, "name": "Sick!!", "color": "pink"},
        {"hits": 150, "name": "Out Of This World!!!", "color": "red"}
      ],
      "score_formula": "exponential"
    }
  }
  ```

---

## 4. Elemental & Status Systems

### Feature 14: Elemental Shield Pickups

- **Feature Name**: Elemental Shield Pickups
- **Source**: Sonic 3 & Knuckles / Sonic Mania (Fire Shield, Bubble Shield, Lightning Shield, Standard Shield)
- **Description**: Breaking special monitor items grants the player a protective shield with elemental powers. Fire Shield = immune to fire/lava, leaves fire trail when dashing, air dash ability. Bubble Shield = immune to drowning, allows bounce attack, breathing underwater. Lightning Shield = magnetic coin attraction, double jump with electric spark, immune to electricity. Standard Shield = one-hit protection, no special ability.
- **Kid UX**: The child stamps "Shield Monitors" on the canvas. Tapping each monitor opens a sticker picker: flame icon (Fire), water drop (Bubble), lightning bolt (Lightning), blue orb (Standard). During play, breaking the monitor (jump on it) grants the shield with a flash effect. The shield's element is shown as an orbiting bubble around the character. Only one shield at a time -- picking up a new one replaces the old.
- **LLM Automation**: The LLM implements each shield's unique passive effect (immunity zones, magnet radius, bounce physics), generates orbiting visual particles, handles shield destruction on hit (single-hit protection for Standard, element-specific protection for others), manages shield replacement rules, and auto-tints level hazards to communicate element associations.
- **JSON Contract Extension**:
  ```json
  {
    "shield_types": [
      {"type": "fire", "immunity": ["lava", "fire"], "ability": "air_dash", "trail": "fire"},
      {"type": "bubble", "immunity": ["drown", "water_pressure"], "ability": "bounce", "underwater_breath": true},
      {"type": "lightning", "immunity": ["electric"], "ability": "double_jump", "magnet_radius": 80},
      {"type": "standard", "immunity": [], "ability": "none", "hits": 1}
    ],
    "shield_monitor": {
      "break_method": "jump_on",
      "max_one": true,
      "visual_orbit": true
    }
  }
  ```

---

### Feature 15: Elemental Weakness Matching

- **Feature Name**: Elemental Weakness Matching
- **Source**: Final Fantasy series (elemental weaknesses: fire beats ice, ice beats fire, lightning beats water, holy beats dark)
- **Description**: Enemies and obstacles have visible elemental affiliations (color-coded: red = fire, blue = ice, yellow = lightning, green = earth, white = holy, purple = dark). Attacking with the matching element deals bonus damage and triggers a dramatic weakness-exposed effect. Attacking with the wrong element deals reduced damage or heals the enemy. This creates a simple puzzle layer in combat.
- **Kid UX**: The child stamps enemies and taps them to pick an element (shown by the enemy's glow color). They also stamp elemental weapon pickups or Job Badges. During play, hitting a fire enemy with ice creates a big "WEAKNESS!" flash and the enemy melts faster. The system is self-teaching through visual feedback -- kids learn the rock-paper-scissors naturally.
- **LLM Automation**: The LLM maintains the elemental wheel (fire < ice < fire, water < lightning < water, dark < holy < dark), computes damage modifiers (2x for weakness, 0.5x for resistance, 0x for absorption), generates weakness-hit visual feedback (color flash, elemental burst, "WEAKNESS!" text), tracks elemental state on enemies, and auto-suggests balanced enemy placements when designing levels.
- **JSON Contract Extension**:
  ```json
  {
    "elemental_wheel": {
      "elements": ["fire", "ice", "lightning", "water", "earth", "wind", "holy", "dark"],
      "weakness_pairs": {
        "fire": "ice", "ice": "fire",
        "water": "lightning", "lightning": "water",
        "dark": "holy", "earth": "wind"
      },
      "damage_modifiers": {"weakness": 2.0, "normal": 1.0, "resistance": 0.5, "absorb": 0.0},
      "visual_feedback": "elemental_burst_text"
    }
  }
  ```

---

### Feature 16: Status Effect Sprites

- **Feature Name**: Status Effect Sprites
- **Source**: Final Fantasy series (Poison, Sleep, Silence, Haste, Slow, Protect, Shell, Regen, Berserk, Confuse)
- **Description**: Various objects and enemy attacks can inflict colorful status effects. A "Sleep Cloud" trap makes the character snooze for 3 seconds. A "Speed Potion" makes them run super fast with sparkles. A "Shield Bubble" reduces damage. "Poison Mushroom" slowly drains health shown by green bubbles. Each effect has a clear, cartoonish visual indicator.
- **Kid UX**: The child stamps "Effect Zones" or "Effect Items." Tapping each opens a sticker picker with big, expressive icons: Zzz bubble (Sleep), lightning boots (Speed), heart shield (Protection), green skull (Poison), swirling stars (Confuse). Effects are applied on touch and last a few seconds. All effects are positive or silly -- nothing genuinely scary for a 5-year-old.
- **LLM Automation**: The LLM implements each status effect's behavior (Sleep = freeze input + Zzz particles, Speed = 2x velocity + trail, Shield = damage reduction + bubble visual, Poison = gradual health drain + green tint), manages effect durations and stacking rules, generates the status UI (small icons near character), and ensures effects are clearly communicated through animation.
- **JSON Contract Extension**:
  ```json
  {
    "status_effects": [
      {"id": "sleep", "duration": 3, "effect": "freeze_input", "visual": "zzz_particles"},
      {"id": "haste", "duration": 5, "effect": "speed_x2", "visual": "sparkle_trail"},
      {"id": "shield", "duration": 10, "effect": "damage_half", "visual": "bubble_orb"},
      {"id": "poison", "duration": 5, "effect": "health_drain_slow", "visual": "green_bubbles"},
      {"id": "confuse", "duration": 3, "effect": "reverse_controls", "visual": "star_swirl"}
    ],
    "stacking_rules": "strongest_wins",
    "visual_indicators": "icon_badge"
  }
  ```

---

### Feature 17: Materia Socket Gems

- **Feature Name**: Materia Socket Gems
- **Source**: Final Fantasy VII (Materia system -- slot gems into equipment for magic/abilities/summons/stat boosts)
- **Description**: The player finds "Socket Stations" throughout levels where they can insert colorful gems into their character's equipment. Red Gem = fire attack. Blue Gem = ice shield. Yellow Gem = lightning speed boost. Green Gem = healing over time. Purple Gem = poison touch. Gems can be combined at stations for hybrid effects (Red + Blue = Steam Blast). The number of sockets limits how many gems are active.
- **Kid UX**: The child stamps "Socket Stations" on the canvas. When playtesting, the player character approaches the station and a simple gem inventory appears as large, draggable gem stickers. The child (during play) drags gems into empty sockets. Combinations produce a "Fusion" option automatically. Gems are found as collectible items throughout levels.
- **LLM Automation**: The LLM generates the socket UI, manages gem inventory per player, computes gem combination results (fusion recipes), applies gem effects to the character's stats and abilities, generates hybrid gem visuals (color blending), and auto-balances gem power relative to level difficulty.
- **JSON Contract Extension**:
  ```json
  {
    "materia_system": {
      "gem_types": ["fire", "ice", "lightning", "heal", "poison", "shield"],
      "fusion_recipes": {
        "fire+ice": "steam_blast",
        "lightning+shield": "electric_barrier",
        "heal+fire": "regen_aura"
      },
      "max_sockets": 4,
      "station_type": "socket_station",
      "auto_balance": true
    }
  }
  ```

---

## 5. Building & Crafting Systems

### Feature 18: Smart Room Recognition

- **Feature Name**: Smart Room Recognition
- **Source**: Dragon Quest Builders 1 & 2 (room recipe system -- placing specific items in an enclosed space auto-recognizes room type)
- **Description**: When the player places specific combinations of furniture stamps inside a walled area, the game auto-recognizes a "room" and grants it special properties. Bed + Lamp = "Bedroom" (restores health when sleeping). Table + Chair + Pot = "Kitchen" (auto-cooks found ingredients into healing food). Anvil + Barrel = "Smithy" (upgrades weapons). Sign + Table = "Shop" (NPCs sell items). The room gets a name label and glows softly when recognized.
- **Kid UX**: The child stamps wall segments to make enclosed rooms, then places furniture stamps inside (beds, tables, lamps, pots, anvils). When a valid room combination is placed, a magical sparkle effect plays and the room type appears as floating text ("Bedroom!"). The child can check a "Room Recipe Book" sticker sheet to see what combinations create what rooms.
- **LLM Automation**: The LLM detects enclosed areas, checks placed item combinations against room recipe database, triggers room recognition event (name popup, soft glow effect), implements room passive effects (health regen in bedroom, crafting in kitchen), tracks room boundaries, and auto-suggests missing items when a partial room is detected.
- **JSON Contract Extension**:
  ```json
  {
    "room_recognition": {
      "recipes": [
        {"name": "Bedroom", "requires": ["bed", "light_source"], "effect": "health_regen"},
        {"name": "Kitchen", "requires": ["table", "cooking_station"], "effect": "auto_cook"},
        {"name": "Smithy", "requires": ["anvil", "barrel"], "effect": "weapon_upgrade"},
        {"name": "Shop", "requires": ["shop_sign", "table", "price_tag"], "effect": "npc_sell"}
      ],
      "detection": "enclosed_area_with_items",
      "recognition_fx": "sparkle_name_popup",
      "room_glow": "soft_tint"
    }
  }
  ```

---

### Feature 19: Crafting Recipe Discovery

- **Feature Name**: Crafting Recipe Discovery
- **Source**: Dragon Quest Builders 1 & 2, Odin Sphere (crafting and alchemy systems)
- **Description**: The player collects raw material items throughout levels (Wood, Stone, Mushroom, Crystal, Iron). At "Crafting Stations," they can combine two or three materials to create new items. The first time a valid combination is tried, the recipe is "discovered" and added to their Recipe Book. Discovery is half the fun -- experimenting with combinations yields surprises. Invalid combinations produce a playful "Poof!" dust cloud.
- **Kid UX**: The child stamps "Material Nodes" (trees for wood, rocks for stone, glowing crystals) and "Crafting Stations" throughout levels. During play, materials are collected automatically on touch. At a station, the player sees their collected materials as large stickers and taps 2-3 to try combining. Valid combos = new item appears with a fanfare. Invalid = cute "Poof!" sound and dust.
- **LLM Automation**: The LLM manages the recipe database (hundreds of valid combinations), validates player crafting attempts, generates discovered items with appropriate properties, unlocks recipes in the Recipe Book UI, implements the "Poof!" failure feedback, auto-suggests hint recipes based on materials available in the current level, and scales crafted item power to level difficulty.
- **JSON Contract Extension**:
  ```json
  {
    "crafting_system": {
      "materials": ["wood", "stone", "mushroom", "crystal", "iron", "herb", "gem"],
      "station_type": "crafting_station",
      "discovery_mode": true,
      "recipe_book": "auto_populated",
      "invalid_feedback": "poof_dust",
      "max_ingredients": 3,
      "hint_system": "material_based"
    }
  }
  ```

---

### Feature 20: Terrain Terraforming Hammer

- **Feature Name**: Terrain Terraforming Hammer
- **Source**: Dragon Quest Builders 1 & 2 (Terraforming -- raise/lower land with hammer)
- **Description**: The player character wields a special "Builder Hammer" that can modify the terrain in real-time. Pressing the action button while facing a wall breaks it (collecting the block). Pressing while facing empty space places a block. Holding up while placing raises terrain; holding down while breaking lowers it. This allows dynamic level modification -- building bridges over pits, stairs up cliffs, or walls for defense.
- **Kid UX**: The child stamps a "Builder Hammer" item somewhere in the level. When the player picks it up, their character equips a cute hammer. Large, simple on-screen buttons appear: "Break" (smash), "Build" (place), "Up" (raise), "Down" (lower). The terrain grid highlights where blocks can be placed. Breaking blocks yields collectible "Block Bits" that can be spent to place new blocks.
- **LLM Automation**: The LLM implements the terrain grid system (destructible/placeable blocks), manages block inventory (collected bits = placement currency), handles terrain modification physics (cascading blocks, structural integrity), generates particle effects for break/place actions, and ensures the player can't terraform into invalid states (e.g., trapping themselves).
- **JSON Contract Extension**:
  ```json
  {
    "terraforming": {
      "tool": "builder_hammer",
      "grid_size": 32,
      "break_yield": "block_bits",
      "place_cost": "block_bits",
      "operations": ["break", "place", "raise", "lower"],
      "physics": "cascade_gravity",
      "integrity_check": true,
      "anti_trap_validation": true
    }
  }
  ```

---

### Feature 21: Gummi Block Vehicle Builder

- **Feature Name**: Gummi Block Vehicle Builder
- **Source**: Kingdom Hearts series (Gummi Ship builder -- snap-together block-based spaceship construction)
- **Description**: Between levels, the player enters a "Vehicle Garage" where they build a custom vehicle by snapping together colored blocks on a grid. Different block types have different functions: Cockpit (required, where character sits), Engine (affects speed), Wings (affects handling), Armor (protection), Weapon (attack power), Special (shields, radar, boost). The vehicle's stats are determined by its block composition. The built vehicle then flies through a bonus "Shooting Segment" between platforming levels.
- **Kid UX**: The child enters the Garage by tapping a "Build Vehicle" button. They see a grid canvas and a palette of colorful block stamps ( cockpit, engine, wing, armor, laser, shield). They stamp blocks onto the grid, which auto-snap together. A cute robot character gives thumbs-up when the vehicle is valid (has cockpit + engine). The vehicle auto-generates a look based on the block layout. Testing the vehicle launches a fun 30-second shooting mini-game.
- **LLM Automation**: The LLM validates vehicle designs (must have cockpit + engine), computes vehicle stats from block composition (speed from engines, handling from wings, defense from armor, offense from weapons), generates the procedural vehicle sprite from the block layout, implements the shooting segment gameplay (auto-scroll, enemy waves, projectile physics), and provides the robot guide's feedback.
- **JSON Contract Extension**:
  ```json
  {
    "gummi_builder": {
      "block_types": ["cockpit", "engine", "wing", "armor", "weapon_laser", "shield", "special"],
      "grid_size": [10, 10],
      "validation_rules": ["has_cockpit", "has_engine"],
      "stat_computation": "block_aggregate",
      "shooting_segment": {
        "duration": 30,
        "enemy_waves": "auto_generated",
        "difficulty_scale": "vehicle_stats"
      },
      "guide_character": "robot_helper"
    }
  }
  ```

---

### Feature 22: Cooking Minigame

- **Feature Name**: Cooking Minigame
- **Source**: Dragon Quest Builders 1 & 2, Odin Sphere (cooking system -- combine ingredients for healing/buff food)
- **Description**: At "Cooking Pots" placed in the level, the player can combine up to 3 food ingredients to create dishes. Each dish has a healing or buff effect. Tomato + Bread = Pizza (heals 50%). Mushroom + Herb = Healing Soup (heals 100%). Spicy Pepper + Meat = Power Steak (attack boost for 30 seconds). The cooking process shows a brief, cute animation of the character stirring a pot.
- **Kid UX**: The child stamps "Ingredient" items (tomatoes, bread, mushrooms, herbs, peppers) and "Cooking Pot" stations. During play, ingredients are collected on touch. At a pot, the player sees their ingredients as large stickers and taps 1-3 to cook. A brief pot-stirring animation plays (2 seconds), then the dish pops out as a floating item. Simple, tactile, and satisfying.
- **LLM Automation**: The LLM manages the cooking recipe database, validates ingredient combinations, determines output dish and effect, generates the cooking animation, applies the dish's healing/buff effect when consumed, tracks ingredient inventory, and auto-balances healing values against level damage patterns.
- **JSON Contract Extension**:
  ```json
  {
    "cooking_system": {
      "stations": ["cooking_pot", "brick_barbecue", "fiery_pan"],
      "ingredients": ["tomato", "bread", "mushroom", "herb", "pepper", "meat", "berry"],
      "max_ingredients": 3,
      "recipes": "auto_calculated",
      "animation": "pot_stirring",
      "effects": ["heal", "attack_boost", "defense_boost", "speed_boost"]
    }
  }
  ```

---

## 6. Movement & Traversal Systems

### Feature 23: Spin Dash Charge Burst

- **Feature Name**: Spin Dash Charge Burst
- **Source**: Sonic the Hedgehog 2/3/Mania (Spin Dash -- crouch + charge = speed burst in ball form)
- **Description**: The player character can curl into a ball and charge up a super-fast dash. Holding the action button charges energy (shown by a vibrating, increasingly fast animation). Releasing launches the character forward at high speed in ball form, damaging enemies on contact and breaking through weak walls. The longer the charge, the faster and further the dash.
- **Kid UX**: The child enables "Spin Dash" on the character settings (single toggle). During play, holding the action button makes the character curl into a ball and vibrate with increasing intensity. Releasing launches them forward. A simple visual charge meter (1-3 segments) appears. Kids love the visceral feel of "charging up" and releasing.
- **LLM Automation**: The LLM implements the charge state (vibration animation scaling with charge level), the launch physics (velocity based on charge time), ball-form collision (destroy enemies, break weak blocks), charge meter UI, and ensures the dash doesn't launch the player into pits (brief hazard prediction with subtle arrow warning).
- **JSON Contract Extension**:
  ```json
  {
    "spin_dash": {
      "charge_levels": 3,
      "charge_time_per_level": 0.5,
      "velocity_multiplier": [1.5, 2.5, 4.0],
      "ball_form": true,
      "enemy_damage": true,
      "break_weak_walls": true,
      "pit_warning": true
    }
  }
  ```

---

### Feature 24: Speed Tunnel Auto-Runner

- **Feature Name**: Speed Tunnel Auto-Runner
- **Source**: Sonic the Hedgehog series (speed tunnels, loop-de-loops, corkscrew paths)
- **Description**: Special "Speed Tunnel" segments where the character auto-runs at extreme velocity through a cinematic path. The player only controls jumping timing and lane switching (if multi-lane). The tunnel can include loop-de-loops (character runs upside-down), corkscrews, and boost pads. These segments provide a thrilling change of pace from normal platforming.
- **Kid UX**: The child stamps "Speed Tunnel Entry" and "Speed Tunnel Exit" markers on the canvas. Between these markers, a glowing path appears. The child can stamp "Loop," "Corkscrew," and "Boost Pad" objects along the path. During play, entering the tunnel launches the auto-run sequence. The player taps to jump -- that's it. Pure spectacle and thrill.
- **LLM Automation**: The LLM generates the auto-run path between entry and exit markers, places spline waypoints for smooth camera following, implements loop-de-loop physics (rotation around path, gravity override), handles boost pad velocity changes, manages the transition back to normal platforming at the exit, and ensures the tunnel path is always valid (no intersecting terrain).
- **JSON Contract Extension**:
  ```json
  {
    "speed_tunnel": {
      "entry_marker": "speed_tunnel_entry",
      "exit_marker": "speed_tunnel_exit",
      "path_elements": ["loop", "corkscrew", "boost_pad", "ramp"],
      "player_control": "jump_only|lane_switch",
      "camera_mode": "cinematic_follow",
      "speed_base": 3.0,
      "speed_boost": 5.0,
      "gravity_override": "path_aligned"
    }
  }
  ```

---

### Feature 25: Flight Necklace Time-Limited Flying

- **Feature Name**: Flight Necklace Time-Limited Flying
- **Source**: NiGHTS into Dreams (flight mechanics -- time-limited free flight in 2D plane)
- **Description**: The player can collect "Flight Necklaces" that grant temporary free-flight ability. While flying, the character soars through the air in any direction, leaving a sparkly trail. Flight has a time limit shown by a shrinking star bar. Collecting "Dream Chips" while flying extends the flight time. The character can perform acrobatic moves (loops, barrel rolls) by swiping.
- **Kid UX**: The child stamps "Flight Necklace" items and "Dream Chip" clusters in the level. During play, touching a necklace grants flight mode -- the character sprouts wings and the control changes to free-directional. A star bar appears and shrinks. Collecting chips refills the bar. When time runs out, wings fade and normal platforming resumes. Very empowering and magical feeling.
- **LLM Automation**: The LLM switches the player from platforming physics to free-flight physics on necklace pickup, implements the flight timer with visual bar, handles Dream Chip collection and time extension, generates the sparkly flight trail, manages the transition back to platforming physics, and auto-places Dream Chips in sensible paths for the child designer.
- **JSON Contract Extension**:
  ```json
  {
    "flight_mode": {
      "trigger": "flight_necklace",
      "duration_seconds": 15,
      "extend_per_chip": 2,
      "physics": "free_flight_2d",
      "trail": "sparkle_line",
      "acrobatics": ["loop", "barrel_roll"],
      "exit_transition": "wing_fade_gravity"
    }
  }
  ```

---

### Feature 26: Paraloop Capture Draw

- **Feature Name**: Paraloop Capture Draw
- **Source**: NiGHTS into Dreams (Paraloop -- flying in a complete circle creates a capture vortex)
- **Description**: While in flight mode (or on specific "Flight Rails"), the player can draw a complete circle with their movement path. Successfully completing a circle creates a "Paraloop" vortex that captures all items, enemies, and collectibles inside the circle. The trail left by the character's flight shows the circle shape and flashes when the paraloop is successful.
- **Kid UX**: The child stamps "Flight Rail" paths in the level. During play, while flying on rails, the player steers with a simple swipe. Drawing a circular path triggers the paraloop with a big flash and "WHOOSH!" sound. All items inside are sucked in with a spiral animation. The system auto-detects circular paths -- the player doesn't need to be precise.
- **LLM Automation**: The LLM tracks the player's flight path, detects circular motion patterns (fuzzy matching -- doesn't need to be perfect), triggers the paraloop vortex effect when a circle is completed, calculates which entities are inside the capture radius, implements the suction animation, and awards collected items. The path trail auto-renders as a glowing line.
- **JSON Contract Extension**:
  ```json
  {
    "paraloop": {
      "trigger": "circular_flight_path",
      "detection_fuzziness": 0.3,
      "capture_radius": "path_enclosed",
      "effects": ["item_suction", "enemy_capture", "score_bonus"],
      "visual": "vortex_flash",
      "audio": "whoosh_crescendo",
      "trail_render": "glowing_line"
    }
  }
  ```

---

### Feature 27: Partner Character Abilities

- **Feature Name**: Partner Character Abilities
- **Source**: Sonic 3 & Knuckles (Tails flight, Knuckles glide/climb), Secret of Mana (3-player simultaneous)
- **Description**: The player can have an AI partner character with unique traversal abilities. Tails-style partner can fly, carrying the player for a short time. Knuckles-style partner can glide long distances and climb walls. Buddy-style partner can be thrown to hit distant switches. The partner follows the player intelligently and activates their ability on context.
- **Kid UX**: The child stamps a "Partner Start Point" and picks a partner type from stickers: "Flying Friend" (wings, can carry player), "Climbing Friend" (claws, can climb walls and glide), "Bouncy Friend" (can be thrown as projectile), "Digging Friend" (can burrow through dirt blocks). During play, the partner follows the player. Context prompts appear automatically ("Press here to fly!" when near a high ledge with a flying partner).
- **LLM Automation**: The LLM implements partner AI (follow player with slight lag, avoid hazards, catch up when far), handles partner-specific ability activation, manages the carry/glide/throw state transitions, generates partner sprite variants, and provides context-sensitive prompts based on partner + environment combinations.
- **JSON Contract Extension**:
  ```json
  {
    "partners": [
      {"type": "flying", "ability": "carry_player", "duration": 5},
      {"type": "climbing", "ability": "wall_climb_glide", "glide_ratio": 0.5},
      {"type": "bouncy", "ability": "throwable_projectile", "damage": 10},
      {"type": "digging", "ability": "burrow_through_dirt", "speed": 2.0}
    ],
    "ai_behavior": "follow_with_lag",
    "context_prompts": true,
    "auto_activate": true
  }
  ```

---

### Feature 28: Flowmotion Rail Riding

- **Feature Name**: Flowmotion Rail Riding
- **Source**: Kingdom Hearts 3D/III (Flowmotion -- grinding on rails, wall-running, pole-spinning for traversal)
- **Description**: Special "Flow Rails" are placed throughout levels. When the player jumps toward a rail, they automatically lock on and grind along it at high speed, performing flips and tricks. Jumping off a rail at the right time launches the player extra far. Wall-running segments let the character run vertically up walls. Pole-spinning launches the character in any direction.
- **Kid UX**: The child stamps "Flow Rails" (curved paths), "Wall-Run Surfaces" (vertical strips), and "Spin Poles" (tall posts) on the canvas. During play, jumping near these objects auto-locks the character into the flowmotion animation. The player taps to jump off. Time the jump at the rail's end for a super-launch (shown by a glowing "SWEET SPOT" marker).
- **LLM Automation**: The LLM implements flowmotion lock-on detection (proximity-based), generates the grinding animation and particle sparks, handles jump-off timing with distance calculation, implements wall-run physics (gravity override, auto-stick to wall), manages the spin-pole aiming reticle, and ensures flowmotion segments chain together smoothly.
- **JSON Contract Extension**:
  ```json
  {
    "flowmotion": {
      "rail_types": ["grind_rail", "wall_run", "spin_pole"],
      "lock_on_radius": 40,
      "grind_speed": 2.0,
      "sweet_spot_bonus": 1.5,
      "particle_sparks": true,
      "chain_transitions": true,
      "auto_animations": ["grind", "flip", "wall_run", "pole_spin"]
    }
  }
  ```

---

### Feature 29: Cannon Travel Rapid Transit

- **Feature Name**: Cannon Travel Rapid Transit
- **Source**: Secret of Mana (Cannon Travel -- pay to launch to new areas via giant cannons)
- **Description**: Giant "Travel Cannons" are placed at key locations. When the player interacts with a cannon, they are loaded inside, the cannon aims at a visible landing zone, and launches them in a dramatic arc across the level. The player can see their character flying through the air as a tiny spinning sprite before landing with a bounce. Cannons can connect different level sections that are otherwise far apart.
- **Kid UX**: The child stamps "Cannon Base" and "Cannon Target" pairs on the canvas. A dotted arc shows the flight path between them. During play, pressing the action button at a cannon loads the character, shows a brief countdown (3, 2, 1), then launches them along the arc with a big "BOOM!" and smoke cloud. Landing is automatic with a bounce.
- **LLM Automation**: The LLM generates the launch arc between cannon and target, implements the launch countdown and firing sequence, manages the ballistic projectile physics during flight (parabolic arc with spin), generates smoke and trail particles, handles the landing (auto-stick to terrain, bounce animation), and ensures the arc doesn't pass through solid terrain.
- **JSON Contract Extension**:
  ```json
  {
    "cannon_travel": {
      "components": ["cannon_base", "cannon_target"],
      "trajectory": "parabolic_arc",
      "countdown": 3,
      "launch_fx": ["smoke_burst", "screen_shake"],
      "flight_spin": true,
      "landing_bounce": true,
      "arc_preview": "dotted_line"
    }
  }
  ```

---

## 7. Companion & Pet Systems

### Feature 30: Dream Eater Creature Creator

- **Feature Name**: Dream Eater Creature Creator
- **Source**: Kingdom Hearts 3D (Dream Eater companions -- create creatures via recipes, raise them, they fight alongside you)
- **Description**: The player can create companion creatures by combining "Dream Parts" (collected from defeated enemies or found in levels). Each combination produces a unique creature with random color variations and personality traits. Creatures level up by fighting alongside the player and learn new abilities. They have visible happiness meters and perform cute idle animations.
- **Kid UX**: The child stamps "Dream Parts" (colored orbs: red = brave, blue = calm, yellow = energetic, green = nurturing) and "Dream Portal" creation stations. During play, combining 2-3 parts at a portal spawns a cute creature with matching colors and personality. The creature follows the player, helps in combat, and has a small heart meter showing happiness. Feeding it treats (stamped items) makes it happier and stronger.
- **LLM Automation**: The LLM manages the creature generation algorithm (part combinations -> creature type + color palette + personality), implements creature AI (combat assistance, following, idle behaviors), tracks creature XP and leveling, generates procedural creature sprites from part combinations, manages happiness mechanics, and handles creature ability unlocks as they level.
- **JSON Contract Extension**:
  ```json
  {
    "dream_eater": {
      "parts": ["brave_orb", "calm_orb", "energy_orb", "nurture_orb"],
      "creation_station": "dream_portal",
      "combination_count": [2, 3],
      "traits": ["aggressive", "defensive", "healer", "tricky"],
      "leveling": true,
      "happiness_system": true,
      "procedural_sprites": true,
      "ability_unlocks": "level_based"
    }
  }
  ```

---

### Feature 31: Nightopian A-Life Ecosystem

- **Feature Name**: Nightopian A-Life Ecosystem
- **Source**: NiGHTS into Dreams (A-Life system -- Nightopian creatures with moods, breeding, evolution)
- **Description**: Small creatures called "Dreamlings" inhabit the level. They have simple AI lives: wandering, eating found items, sleeping at night, and breeding when happy. The player's behavior affects their mood -- being friendly makes them happy and they multiply; being aggressive scares them and they hide. Over multiple playthroughs, the population evolves. Happy Dreamlings give the player bonus points and sometimes helpful items.
- **Kid UX**: The child stamps "Dreamling Nests" (where creatures spawn) and "Dreamling Food" sources. During play, cute little creatures wander around. The child (as level designer) can set the starting population and mood. The creatures have visible mood indicators (heart bubbles = happy, sweat drops = scared, Zzz = sleeping). Breeding produces baby creatures with mixed colors. The ecosystem runs autonomously.
- **LLM Automation**: The LLM implements each Dreamling's AI state machine (wander, eat, sleep, flee, breed), tracks mood and population across play sessions, handles breeding logic (color mixing, trait inheritance), generates evolutionary variations over time, implements mood-based player interactions, and manages population caps to prevent performance issues.
- **JSON Contract Extension**:
  ```json
  {
    "a_life_ecosystem": {
      "creature_name": "dreamling",
      "ai_states": ["wander", "eat", "sleep", "flee", "breed"],
      "mood_factors": ["player_friendliness", "food_availability", "population_density"],
      "breeding": {"requires_happiness": 0.7, "color_inheritance": "blend"},
      "evolution": "generational_over_sessions",
      "player_rewards": "mood_based",
      "population_cap": 20
    }
  }
  ```

---

### Feature 32: Monster Taming Whistle

- **Feature Name**: Monster Taming Whistle
- **Source**: Dragon Quest Builders 2 (monster taming -- befriend defeated monsters who then help in town)
- **Description**: After defeating an enemy, there's a chance it drops a "Friendship Token." Collecting this token and using it at a "Monster Barn" befriends that enemy type. Befriended monsters become allies -- they patrol the level, help fight other enemies, or can be ridden as mounts. Each monster type has a unique ally ability: Slimes bounce and find hidden items, Drackies fly and scout ahead, Golems smash obstacles.
- **Kid UX**: The child stamps "Monster Spawners" and a "Monster Barn." They can set a "Tameable" toggle on any enemy stamp. During play, defeating a tameable enemy sometimes drops a glowing heart token. Taking it to the barn adds that monster type as a friend. A "Call Whistle" item (stamped) lets the player summon their tamed monsters. Tamed monsters wear a cute little hat to show they're friendly.
- **LLM Automation**: The LLM handles monster defeat detection, friendship token drop chance, barn management (which types are tamed), tamed monster AI (ally behaviors per monster type), mount-riding physics for applicable monsters, generates the cute hat accessory overlay, and manages summon/dismiss via the whistle item.
- **JSON Contract Extension**:
  ```json
  {
    "monster_taming": {
      "token_drop_chance": 0.3,
      "tameable_toggle": true,
      "barn_type": "monster_barn",
      "summon_item": "call_whistle",
      "ally_behaviors": {
        "slime": "find_hidden_items",
        "dracky": "fly_scout",
        "golem": "smash_obstacles"
      },
      "mount_riding": ["golem", "sabrecat", "great_dragon"],
      "friendly_visual": "cute_hat_overlay"
    }
  }
  ```

---

## 8. Progression & Mastery Systems

### Feature 33: Sphere Grid Skill Board

- **Feature Name**: Sphere Grid Skill Board
- **Source**: Final Fantasy X (Sphere Grid -- board game-like skill progression where moving tokens unlocks abilities)
- **Description**: After completing each level, the player advances on a "Skill Board" -- a colorful grid of interconnected nodes. Each node grants a small permanent bonus: +1 health, faster speed, new ability unlock, elemental resistance. The player moves their token along paths, choosing which direction to go. Multiple characters can be on the same board, creating a shared progression system.
- **Kid UX**: After level completion, a big, colorful grid appears with the character's token on their current node. Glowing adjacent nodes show available moves. The child taps a glowing node to move there and collect its bonus. Nodes have clear icons (heart = health, wing = speed, star = ability, shield = defense). The board persists across all levels, creating long-term progression.
- **LLM Automation**: The LLM generates the Skill Board layout (branching paths with meaningful choices), tracks node activation state per player profile, applies permanent stat bonuses from activated nodes, handles the visual board rendering and path highlighting, unlocks new board sections as levels are completed, and ensures board progression feels rewarding without being overwhelming.
- **JSON Contract Extension**:
  ```json
  {
    "sphere_grid": {
      "board_layout": "auto_generated_branches",
      "node_types": ["health_up", "speed_up", "ability_unlock", "element_resist", "special"],
      "moves_per_level": 1,
      "board_sections_unlock": "level_progress",
      "shared_board": true,
      "visual_path_highlight": "glow",
      "persistence": "profile_wide"
    }
  }
  ```

---

### Feature 34: Gambit Buddy Behavior Cards

- **Feature Name**: Gambit Buddy Behavior Cards
- **Source**: Final Fantasy XII (Gambit system -- programmable ally AI using IF-THEN condition cards)
- **Description**: The player can customize their companion's AI behavior using simple "Behavior Cards" that follow IF-THEN logic. Cards are visual and use icons, not text. Example: [If Ally Low Health] -> [Use Heal]. [If Enemy Near] -> [Attack]. [If Treasure Near] -> [Get It]. Cards are prioritized top-to-bottom. More cards are unlocked as companions level up.
- **Kid UX**: The child opens the "Buddy Brain" screen by tapping a companion. They see a vertical stack of card slots. Each card has two halves: left half = condition (tappable sticker: "If Hurt," "If Enemy Near," "If Item Near"), right half = action (tappable sticker: "Use Heal," "Attack," "Get Item"). The child drags cards to reorder priority. It's visual programming made toddler-simple.
- **LLM Automation**: The LLM generates the visual card UI, implements the IF-THEN evaluation engine (checks conditions every frame, executes highest-priority matching card), handles companion AI action execution based on configured cards, unlocks new condition/action cards as companions level up, validates card combinations (prevents invalid combos), and auto-suggests helpful card setups.
- **JSON Contract Extension**:
  ```json
  {
    "gambit_cards": {
      "card_format": "if_then_icons",
      "conditions": ["ally_low_health", "enemy_near", "item_near", "boss_present", "trap_near"],
      "actions": ["use_heal", "attack", "get_item", "flee", "use_special"],
      "max_cards": 6,
      "priority_order": "top_to_bottom",
      "unlock_method": "companion_level",
      "validation": "prevent_invalid_combos"
    }
  }
  ```

---

### Feature 35: New Game+ Loop Mode

- **Feature Name**: New Game+ Loop Mode
- **Source**: Chrono Trigger (New Game+ -- restart with all levels unlocked, keep all upgrades, fight final boss at any time for different endings)
- **Description**: After completing the game once, "Loop Mode" unlocks. The player can replay any level with all their collected abilities, powers, and upgrades carried over. Enemies are tougher (visually indicated by aura color). Hidden "Loop Treasures" appear only in Loop Mode. Beating the final boss at different points in the story yields different celebratory endings. The player can also "Loop Reset" to start fresh while keeping a "Loop Badge" cosmetic.
- **Kid UX**: When the child completes all their levels, a celebratory screen announces "Loop Mode Unlocked!" with sparkles. A "Loop" button appears on the level select. In Loop Mode, levels have a rainbow border. Special "Loop Only" stamps become available (hidden treasures, tougher enemy variants). The child can stamp these new items in previously completed levels. Different endings are shown as collectible star cards.
- **LLM Automation**: The LLM tracks completion state, unlocks Loop Mode after first completion, carries over all player progression, scales enemy difficulty for Loop Mode (more health, faster movement), places Loop-exclusive items, tracks which levels the final boss was beaten on for ending variations, generates the ending star cards, and manages the Loop Reset with badge award.
- **JSON Contract Extension**:
  ```json
  {
    "new_game_plus": {
      "unlock_after": "first_completion",
      "carry_over": ["abilities", "upgrades", "collectibles", "sphere_grid_progress"],
      "enemy_scaling": {"health_mult": 1.5, "speed_mult": 1.2, "visual_aura": "chromatic"},
      "loop_exclusive_items": true,
      "ending_variations": "final_boss_timing",
      "loop_badge": "cosmetic_award",
      "loop_reset_allowed": true
    }
  }
  ```

---

### Feature 36: Phozon Absorption Growth

- **Feature Name**: Phozon Absorption Growth
- **Source**: Odin Sphere (Phozon absorption -- collect spirit energy to grow plants and gain abilities)
- **Description**: Defeated enemies release floating "Power Orbs" that can be absorbed. Collecting enough orbs causes the character to "grow" -- visual size increase, slight stat boost, and new ability glow. Collected orbs can also be spent at "Growth Shrines" to unlock skill tree nodes (health, attack, speed, special moves). The character's growth level persists across levels.
- **Kid UX**: The child enables "Power Orbs" on enemy stamps (single toggle: "Drop Orbs on Defeat"). They stamp "Growth Shrines" in levels. During play, defeating enemies releases pretty floating orbs that home toward the player. Collecting enough orbs makes the character slightly bigger with a celebratory chime. At Growth Shrines, the player spends orbs to unlock glowing nodes on a simple skill tree (tapping a node purchases it).
- **LLM Automation**: The LLM implements orb release on enemy defeat, orb homing physics, growth state tracking (size scaling, stat modifiers), generates the skill tree layout, handles orb spending and node unlocking, persists growth data across levels, and scales orb requirements per growth tier to maintain progression pacing.
- **JSON Contract Extension**:
  ```json
  {
    "phozon_growth": {
      "orb_source": "enemy_defeat",
      "orb_behavior": "homing_float",
      "growth_tiers": [
        {"orbs": 10, "size_mult": 1.1, "stat_bonus": "health+1"},
        {"orbs": 25, "size_mult": 1.2, "stat_bonus": "attack+1"},
        {"orbs": 50, "size_mult": 1.3, "stat_bonus": "special_unlock"}
      ],
      "skill_tree": {"nodes": ["health", "attack", "speed", "special"], "cost_orbs": true},
      "shrine_type": "growth_shrine",
      "persistence": "profile_wide"
    }
  }
  ```

---

## 9. World & Narrative Systems

### Feature 37: Time Travel Era Doors

- **Feature Name**: Time Travel Era Doors
- **Source**: Chrono Trigger (time travel to Prehistoric 65M BC, Middle Ages 600 AD, Present 1000 AD, Future 2300 AD, End of Time)
- **Description**: Special "Era Doors" transport the player between different versions of the same level set in different time periods. Each era has different terrain, enemies, and available items. Changes made in one era affect others (planting a tree in the past creates a forest in the present, defeating a boss in the past changes the future). Era versions are designed as parallel levels that the child can stamp.
- **Kid UX**: The child stamps "Era Doors" and picks the destination era from stickers: "Long Long Ago" (prehistoric, dinosaurs), "Olden Days" (medieval, castles), "Right Now" (modern, cities), "Far Future" (sci-fi, robots). The child can then stamp the parallel version of the level for that era. A "Time Ripple" view shows how changes in one era preview in another. The child stamps a tree in the past, toggles to the present, and sees a forest.
- **LLM Automation**: The LLM manages era state (which objects exist in which era), implements time-ripple causality (past tree -> present forest), handles era door transitions (warp with time-vortex effect), generates era-appropriate visual filters (prehistoric = warm sepia, medieval = painterly, future = neon grid), and tracks cross-era puzzle state.
- **JSON Contract Extension**:
  ```json
  {
    "time_travel": {
      "eras": ["prehistoric", "medieval", "present", "future"],
      "door_type": "era_door",
      "causality": {
        "prehistoric": {"plant_tree": "present_forest", "defeat_boss": "future_peaceful"},
        "medieval": {"save_village": "present_town"}
      },
      "era_visual_filter": true,
      "transition_fx": "time_vortex",
      "parallel_levels": true
    }
  }
  ```

---

### Feature 38: Random Encounter Adventure Paths

- **Feature Name**: Random Encounter Adventure Paths
- **Source**: Final Fantasy I-VI (random encounters on world map), Chrono Trigger (visible enemies)
- **Description**: When the player walks on "Wilderness Path" terrain stamps, random encounters can trigger. Unlike classic RPGs, enemies are visible before the encounter -- they pop up as shadows that approach the player. The encounter rate is adjustable per path stamp. Encounter types are picked from a pool based on the path's biome stamp (forest = nature enemies, cave = rock enemies, castle = knight enemies).
- **Kid UX**: The child stamps "Wilderness Paths" on the canvas. Tapping a path shows a simple slider: "Quiet" (few encounters) to "Busy" (many encounters). They also stamp "Biome Markers" (tree icon = forest, mountain = cave, flag = castle). During play, shadow shapes appear on the path and approach the player. Touching a shadow starts a brief battle section. The child can also place specific "Fixed Encounter" shadows for set-piece battles.
- **LLM Automation**: The LLM manages encounter rate per path segment, spawns visible enemy shadows approaching the player, transitions to a brief battle arena (auto-generated from terrain context), selects enemy types based on biome markers, handles battle resolution, and returns the player to their exact path position after the encounter.
- **JSON Contract Extension**:
  ```json
  {
    "random_encounters": {
      "path_type": "wilderness_path",
      "rate_slider": "quiet_to_busy",
      "biome_markers": ["forest", "cave", "castle", "desert", "snow"],
      "enemy_pools": "biome_determined",
      "visibility": "approaching_shadows",
      "battle_arena": "auto_generated",
      "fixed_encounters": true
    }
  }
  ```

---

### Feature 39: NPC Town Builder Requests

- **Feature Name**: NPC Town Builder Requests
- **Source**: Dragon Quest Builders 1 & 2 (NPCs move into your town and request specific buildings/rooms/items)
- **Description**: Friendly NPC characters placed in the level have "Wish Bubbles" showing what they want. A knight NPC wants an "Armory Room" (chest + weapons). A chef wants a "Kitchen" (pot + table). Completing their request makes them happy (heart particles), they move into the room, and they grant the player a reward item or new ability. NPCs add life and purpose to built areas.
- **Kid UX**: The child stamps "NPC" characters and taps them to pick a type (knight, chef, farmer, shopkeeper). Each NPC shows a thought bubble with a picture of what they want (simple icon). The child builds rooms using the Smart Room Recognition system. When the room matches the NPC's wish, the bubble turns into hearts and the NPC walks to their new room. A gift box appears as reward.
- **LLM Automation**: The LLM matches built rooms to NPC wishes (validates room type against request), triggers the wish-completion event (heart particles, NPC pathing to room, gift spawn), generates appropriate rewards per NPC type, manages NPC daily routines (sleep at night, work in their room), and creates new requests as previous ones are fulfilled.
- **JSON Contract Extension**:
  ```json
  {
    "npc_requests": {
      "npc_types": ["knight", "chef", "farmer", "shopkeeper", "healer"],
      "wish_format": "icon_thought_bubble",
      "room_match": "auto_validate",
      "rewards": {
        "knight": "weapon_upgrade",
        "chef": "cooking_recipe",
        "farmer": "crop_seeds",
        "shopkeeper": "shop_discount",
        "healer": "heal_aura"
      },
      "routine": true,
      "request_chain": true
    }
  }
  ```

---

### Feature 40: Trinity Mark Co-op Secrets

- **Feature Name**: Trinity Mark Co-op Secrets
- **Source**: Kingdom Hearts (Trinity Marks -- glowing marks on the ground that require specific party combinations or actions to activate)
- **Description**: Special "Trinity Marks" are stamped on the ground throughout levels. Each mark has a color indicating its activation requirement: Blue (player only), Red (player + 1 buddy), Green (player + 2 buddies), Yellow (all stand in formation). Activating a mark triggers a secret -- revealing a hidden treasure, opening a sealed door, or spawning a rare item. Some marks require a specific job class to activate.
- **Kid UX**: The child stamps "Trinity Marks" on the canvas. Tapping each opens a picker: Blue (solo), Red (need friend), Green (need two friends), Yellow (formation). The mark glows with its color in play. When requirements are met and the player stands on it, all required characters pose together, the mark flashes, and the secret is revealed. Very satisfying discovery moment.
- **LLM Automation**: The LLM validates activation requirements (player count, buddy count, class requirements), detects when all participants stand on the mark, triggers the group pose animation, reveals the associated secret (spawns treasure, opens door, etc.), plays the activation sequence (flash, sound, particles), and tracks which marks have been activated per save.
- **JSON Contract Extension**:
  ```json
  {
    "trinity_marks": {
      "colors": {
        "blue": {"requirement": "player_only"},
        "red": {"requirement": "player_plus_1_buddy"},
        "green": {"requirement": "player_plus_2_buddies"},
        "yellow": {"requirement": "formation_stand"}
      },
      "class_requirement": "optional",
      "activation_fx": "group_pose_flash",
      "secret_types": ["treasure_reveal", "door_open", "rare_spawn", "shortcut"],
      "tracking": "per_save"
    }
  }
  ```

---

### Feature 41: Moogle Mail Delivery

- **Feature Name**: Moogle Mail Delivery
- **Source**: Final Fantasy IX (Mognet -- Moogles deliver mail between locations)
- **Description**: Cute "Messenger" creatures are placed throughout levels. When the player talks to one, it delivers a message from an NPC -- which can be a hint, a quest request, a thank-you note, or a lore snippet. Messages are shown as illustrated letters with big, readable text. Some messages contain gift items. The child designer can write custom messages that appear in their levels.
- **Kid UX**: The child stamps "Messenger" characters throughout their levels. Tapping a messenger opens a simple text field where the child (or a parent) can type a short message. They can also pick a gift item sticker to attach. During play, talking to the messenger shows the illustrated letter with the custom message read aloud by text-to-speech. The gift is added to inventory.
- **LLM Automation**: The LLM generates the illustrated letter UI (fancy border, handwriting font), optionally reads the message via TTS, handles gift attachment and delivery, manages message read state (unread = envelope closed, read = envelope open), creates default hint messages if the child doesn't write custom ones, and tracks which messengers have been visited.
- **JSON Contract Extension**:
  ```json
  {
    "moogle_mail": {
      "messenger_type": "cute_messenger_creature",
      "letter_ui": "illustrated_envelope",
      "message_source": "designer_custom|llm_default",
      "tts_read_aloud": true,
      "gift_attachment": "item_sticker",
      "read_state": "envelope_open_close",
      "message_categories": ["hint", "request", "thank_you", "lore", "gift"]
    }
  }
  ```

---

## 10. Minigame & Arcade Systems

### Feature 42: Blue Sphere Bonus Stage

- **Feature Name**: Blue Sphere Bonus Stage
- **Source**: Sonic 3 & Knuckles / Sonic Mania (Special Stages -- collect blue spheres and rings in a 3D-like rotating course)
- **Description**: Passing through a "Star Ring" portal launches a bonus stage. The character auto-runs forward on a colorful checkerboard course, and the player steers left/right to collect blue spheres and avoid red spheres. Collecting all blue spheres in a section converts the entire section to bonus points. The goal is to reach the Chaos Emerald at the end of the course.
- **Kid UX**: The child stamps "Star Ring" portals in their levels. Tapping a ring opens a mini canvas for designing the bonus course layout -- they stamp blue spheres (collect), red spheres (avoid), and bumpers. The checkerboard course auto-generates from the sphere layout. During play, passing through the ring launches the bonus stage with different music. Steering is simple: tap left/right sides of screen.
- **LLM Automation**: The LLM generates the checkerboard course from the child's sphere layout, implements the auto-run steering (left/right tap), manages sphere collection state, handles the "all blue in section = bonus conversion" rule, generates the course in a faux-3D perspective, implements the Chaos Emerald reward at course completion, and transitions back to the platforming level.
- **JSON Contract Extension**:
  ```json
  {
    "blue_sphere_stage": {
      "portal_type": "star_ring",
      "course_elements": ["blue_sphere", "red_sphere", "bumper", "ring"],
      "steering": "left_right_tap",
      "perspective": "faux_3d",
      "section_bonus": "all_blue_convert",
      "reward": "chaos_emerald_or_equivalent",
      "auto_run_speed": 1.5,
      "course_generator": "layout_based"
    }
  }
  ```

---

### Feature 43: Card Battle Collectible Game

- **Feature Name**: Card Battle Collectible Game
- **Source**: Final Fantasy VIII/VI (Triple Triad, Tetra Master -- tile-based card games with elemental rules)
- **Description**: A simplified collectible card game that can be played at "Card Tables" stamped in levels. Each card has a number (1-9) on each of four sides. Players place cards on a 3x3 grid. When a card is placed adjacent to an opponent's card, the touching numbers are compared -- higher number captures the card. Some cards have elements that trigger combo captures. Winning earns new cards.
- **Kid UX**: The child stamps "Card Tables" in their levels. During play, interacting with a table opens the card game. Cards are large, colorful, and show clear numbers on each edge. The child drags cards from their hand to the grid. Numbers flash when comparing. Captured cards flip to the winner's color with a sparkle. The game takes 1-2 minutes. Simple, strategic, and satisfying.
- **LLM Automation**: The LLM generates a starter card deck (varied number distributions), implements the placement and comparison logic, handles element combo rules, manages the AI opponent (various difficulty levels), tracks the card collection, unlocks new cards as rewards, and provides visual feedback for captures (flip animation, sparkle, combo chains).
- **JSON Contract Extension**:
  ```json
  {
    "card_game": {
      "name": "tile_triad",
      "grid": "3x3",
      "card_numbers": "1-9_per_edge",
      "capture_rule": "higher_number_adjacent",
      "element_combos": true,
      "starter_deck": 10,
      "ai_opponents": ["easy", "medium", "hard"],
      "rewards": "new_cards",
      "table_type": "card_table"
    }
  }
  ```

---

### Feature 44: Synthesis Workshop Upgrades

- **Feature Name**: Synthesis Workshop Upgrades
- **Source**: Kingdom Hearts series (Synthesis Shop -- combine materials to create powerful items and equipment)
- **Description**: A "Workshop" object in the level lets the player combine collected materials into upgraded equipment and special items. The synthesis list shows possible combinations, with question marks for undiscovered recipes. Successfully synthesizing an item plays a brief "crafting" animation and a success jingle. Synthesized items grant permanent upgrades (better sword, faster boots, bigger health bar).
- **Kid UX**: The child stamps "Workshop" stations and "Material" items (metal scraps, glowing dust, monster drops, rare gems). During play, materials are collected on touch. At the workshop, the player sees a "Recipe Book" with known recipes and ??? slots for unknown ones. Tapping a recipe shows required materials. If materials are available, a "Make It!" button glows. Tapping it plays a fun crafting animation.
- **LLM Automation**: The LLM manages the recipe database (known and unknown), validates material availability, generates the crafting animation, applies equipment upgrades to the player character (stat changes, visual changes), tracks discovered vs. undiscovered recipes, suggests recipes based on current materials, and scales recipe outcomes to level progression.
- **JSON Contract Extension**:
  ```json
  {
    "synthesis_workshop": {
      "materials": ["metal_scrap", "glow_dust", "monster_drop", "rare_gem", "crystal_shard"],
      "recipe_book": {"known": [], "unknown": "???"},
      "crafting_animation": "hammer_anvil_sparkles",
      "upgrades": ["sword_power", "boots_speed", "armor_defense", "health_boost"],
      "discovery_mode": true,
      "suggestion_system": "material_based"
    }
  }
  ```

---

### Feature 45: Score Attack Time Trial Mode

- **Feature Name**: Score Attack Time Trial Mode
- **Source**: Sonic Mania (Time Attack mode), NiGHTS into Dreams (Score Attack mode), Streets of Rage 4 (Arcade mode with scoring)
- **Description**: Every level the child creates can be played in "Time Attack" mode (race the clock) or "Score Attack" mode (maximize points). In Time Attack, a timer counts up and the goal is fastest completion. Ghost data shows the player's best run as a translucent shadow. In Score Attack, points from enemies, items, combos, and secrets are tallied. Rank grades (D to S++) are awarded based on performance. Best scores are saved to a leaderboard.
- **Kid UX**: On the level select screen, each level card has three mode buttons: "Play" (normal), "Time Attack" (clock icon), "Score Attack" (star icon). Tapping a mode launches that challenge. During Time Attack, a big timer is visible. During Score Attack, a score counter and combo meter are prominent. After completion, a rank badge appears (D, C, B, A, S, S+, S++). Ghost data shows the previous best run as a shadow.
- **LLM Automation**: The LLM implements the timer system (start on first input, stop on goal reached), computes score from all point sources (enemies, items, combos, secrets, time bonus), determines rank thresholds per level (based on level complexity and content), records and replays ghost data, manages the leaderboard (personal best tracking), and generates the rank-up sequence animation.
- **JSON Contract Extension**:
  ```json
  {
    "challenge_modes": {
      "time_attack": {
        "timer": "count_up",
        "ghost_data": true,
        "rank_thresholds": "auto_calculated"
      },
      "score_attack": {
        "score_sources": ["enemies", "items", "combos", "secrets", "time_bonus"],
        "ranks": ["D", "C", "B", "A", "S", "S+", "S++"],
        "combo_multiplier": true
      },
      "leaderboard": "personal_best",
      "ghost_visual": "translucent_shadow"
    }
  }
  ```

---

### Feature 46: Weapon Pickup Environment Arsenal

- **Feature Name**: Weapon Pickup Environment Arsenal
- **Source**: Streets of Rage 4 / Golden Axe (weapons picked up from environment -- bats, knives, pipes, swords, magical elements)
- **Description**: Various weapon items can be stamped throughout levels. When the player touches a weapon, they automatically equip it, changing their attack. Weapons have limited durability (shown by a small number). Baseball Bat = wide swing, 8 hits. Knife = fast stab, 5 hits. Pipe = long reach, 6 hits. Magical Potion = screen-clear blast, 1 use. Dropped weapons can be picked up again. Breaking crates/barrels sometimes reveals hidden weapons.
- **Kid UX**: The child stamps "Weapon Crates" and "Weapon Items" (bat, knife, pipe, potion, star) on the canvas. During play, breaking a crate (jump on it) reveals the weapon with a bounce. Touching the weapon equips it -- the character's sprite changes to hold it. A small durability counter appears. Attacking uses one durability. When it reaches zero, the weapon breaks with a sound effect and the character returns to default attacks.
- **LLM Automation**: The LLM implements weapon equipping (sprite change, attack pattern change), tracks durability per weapon, generates weapon-specific hitboxes and attack animations, handles weapon dropping and re-pickup, implements crate-breaking physics, manages weapon switching (new pickup replaces current), and generates satisfying break effects when durability reaches zero.
- **JSON Contract Extension**:
  ```json
  {
    "weapon_pickups": {
      "weapons": [
        {"type": "baseball_bat", "durability": 8, "attack": "wide_swing", "range": "medium"},
        {"type": "knife", "durability": 5, "attack": "fast_stab", "range": "short"},
        {"type": "pipe", "durability": 6, "attack": "long_reach", "range": "long"},
        {"type": "magic_potion", "durability": 1, "attack": "screen_clear", "range": "full"}
      ],
      "spawn_method": "weapon_crate|direct_place",
      "equip_on_touch": true,
      "durability_ui": "small_counter",
      "break_fx": "shatter_sound_particles",
      "drop_and_repickup": true
    }
  }
  ```

---

### Feature 47: Star Move Power Attacks

- **Feature Name**: Star Move Power Attacks
- **Source**: Streets of Rage 4 (Star Moves -- limited-use super attacks that consume a Power Star)
- **Description**: Hidden throughout levels are "Power Stars" -- rare, glowing collectibles. When the player has at least one star, they can execute a "Star Move" -- a devastating, screen-clearing attack with a dramatic animation. The character becomes invincible during the move. Examples: Giant beam blast, summoning a meteor storm, transforming into a super form briefly, calling in ally bombardment.
- **Kid UX**: The child stamps "Power Star" items in secret/hard-to-reach locations. During play, collected stars appear as glowing icons below the health bar. When at least one star is available, a big "STAR MOVE!" button pulses on screen. Tapping it triggers the chosen character's ultimate attack with a cinematic intro. The star icon shatters dramatically after use.
- **LLM Automation": The LLM tracks star collection, implements the Star Move button (pulses when available, gray when not), generates the cinematic intro animation (camera zoom, character pose), executes the chosen ultimate attack pattern (varies by character/job), applies invincibility frames, handles screen-wide damage calculation, manages the star consumption, and generates the shatter effect on use.
- **JSON Contract Extension**:
  ```json
  {
    "star_moves": {
      "currency": "power_star",
      "button": "star_move_pulse",
      "invincible_during": true,
      "cinematic_intro": true,
      "moves_per_class": {
        "warrior": "giant_beam_sword",
        "mage": "meteor_storm",
        "thief": "shadow_clone_assault"
      },
      "consumption": "1_per_use",
      "visual_shatter": true
    }
  }
  ```

---

## Bonus Features

### Feature 48: Voice-Activated Creature Care

- **Feature Name**: Voice-Activated Creature Care
- **Source**: Seaman (voice-activated virtual pet -- talk to the creature, it responds and evolves)
- **Description**: A special "Voice Garden" area in the level contains a mysterious egg. The egg hatches into a small creature that responds to the player's voice (via microphone). Saying "Hello!" makes it happy. Saying "Jump!" makes it bounce. The creature grows and evolves over multiple play sessions based on how the player interacts with it. It has a visible personality (curious, shy, playful, grumpy).
- **Kid UX**: The child stamps a "Voice Garden" zone and a "Mystery Egg." During play, the egg hatches when the player taps it. A cute creature appears. A microphone icon appears when in the garden. The child can talk to their creature. The creature responds with expressive animations. Between play sessions, the creature changes -- it remembers the player! A "Creature Journal" shows its growth stages.
- **LLM Automation**: The LLM processes voice input (keyword detection for simple commands: "hello", "jump", "eat", "sleep"), maps voice interactions to creature mood/personality state, manages creature growth stages across sessions (stored in save data), generates evolution paths based on care history, creates the Creature Journal with growth photos, and handles the microphone permission and processing.
- **JSON Contract Extension**:
  ```json
  {
    "voice_creature": {
      "zone": "voice_garden",
      "start_item": "mystery_egg",
      "voice_commands": ["hello", "jump", "eat", "sleep", "come"],
      "personality_traits": ["curious", "shy", "playful", "grumpy"],
      "growth_stages": 5,
      "session_persistence": true,
      "creature_journal": true,
      "evolution_path": "care_history_based"
    }
  }
  ```

---

### Feature 49: Attraction Flow Ride Battles

- **Feature Name**: Attraction Flow Ride Battles
- **Source**: Kingdom Hearts III (Attraction Flow -- summon Disney theme park rides as attacks: Pirate Ship, Teacups, Carousel, Big Magic Mountain, etc.)
- **Description**: Collecting special "Ride Tokens" during levels allows the player to summon a theme park ride for a brief, spectacular attack sequence. The Pirate Ship swings and smashes enemies. The Teacups spin and dizzy all nearby foes. The Carousel calls ally characters to join the fight. The Roller Coaster launches the player through enemies at high speed. Each ride has a 10-15 second duration.
- **Kid UX**: The child stamps "Ride Token" items in their levels. During play, collecting tokens fills a "Ride Meter." When full, large ride icons appear at the bottom. The player taps one to summon the ride. The character hops on and the ride auto-executes its attack pattern with big, flashy visuals. Simple and spectacular -- the player mostly watches the spectacle while tapping to boost.
- **LLM Automation": The LLM manages Ride Token collection and meter filling, implements each ride's unique attack pattern (Pirate Ship = swinging arc, Teacups = spin radius, Carousel = ally summon, Coaster = rail dash), generates the ride visuals and animations, handles the 10-15 second duration with countdown, applies damage to enemies in the ride's area of effect, and transitions back to normal platforming after the ride ends.
- **JSON Contract Extension**:
  ```json
  {
    "attraction_flow": {
      "tokens": "ride_token",
      "meter_fill_per_token": 1,
      "rides": [
        {"name": "pirate_ship", "attack": "swinging_arc", "duration": 12},
        {"name": "teacups", "attack": "spin_dizzy", "duration": 10},
        {"name": "carousel", "attack": "ally_summon", "duration": 15},
        {"name": "coaster", "attack": "rail_dash", "duration": 12}
      ],
      "summon_ui": "large_ride_icons",
      "auto_attack_pattern": true,
      "player_input": "tap_to_boost"
    }
  }
  ```

---

### Feature 50: Evolving Music Soundscape

- **Feature Name**: Evolving Music Soundscape
- **Source**: NiGHTS into Dreams (A-Life music system -- tempo, pitch, and melody alter based on Nightopian mood states)
- **Description**: The level's background music dynamically changes based on gameplay state and player actions. Collecting items adds instruments to the arrangement. High combo chains increase tempo. Defeating enemies adds percussion. Visiting peaceful areas softens the melody. The music evolves organically, making each playthrough's soundtrack unique. The child designer can pick a "base melody" and the system orchestrates around it.
- **Kid UX**: The child picks a "Base Tune" from a sticker collection (happy, adventurous, mysterious, calm). During play, the music auto-evolves. The child stamps "Music Zone" areas that shift the musical mood (battle zone = intense, rest zone = gentle). No complex audio editing -- the LLM handles all music generation and dynamic mixing automatically.
- **LLM Automation**: The LLM generates a base musical arrangement from the selected tune, implements the dynamic music system (adds/removes layers based on game state), manages tempo scaling with combo chains, handles zone-based mood transitions (smooth crossfades), ensures the music never becomes unpleasant regardless of state combinations, and generates appropriate musical cues for major events (boss fight, level complete, secret found).
- **JSON Contract Extension**:
  ```json
  {
    "evolving_music": {
      "base_tunes": ["happy", "adventurous", "mysterious", "calm", "epic"],
      "dynamic_layers": {
        "item_collection": "add_instruments",
        "combo_chain": "increase_tempo",
        "enemy_defeat": "add_percussion",
        "peaceful_zone": "soften_melody"
      },
      "music_zones": ["battle", "rest", "mystery", "celebration"],
      "transition": "smooth_crossfade",
      "event_cues": ["boss_fight", "level_complete", "secret_found", "game_over"],
      "auto_generation": true
    }
  }
  ```

---

## Summary: Feature Count by Category

| Category | Count | Features |
|----------|-------|----------|
| Transformation & Form Systems | 5 | Summon Beast Call, Super Transformation Emeralds, Drive Form Wardrobe, Shapeshift Environment Morph, Triple-Tech Fusion Crystals |
| Class & Role Systems | 3 | Job Badge System, Paradigm Role Switcher, Class Evolution Tree |
| Combo & Synergy Systems | 5 | Double-Tech Buddy Combos, Limit Break Rage Meter, Link Chain Score Multiplier, Reaction Command Context Attacks, Beat-'Em-Up Combo Juggling |
| Elemental & Status Systems | 4 | Elemental Shield Pickups, Elemental Weakness Matching, Status Effect Sprites, Materia Socket Gems |
| Building & Crafting Systems | 5 | Smart Room Recognition, Crafting Recipe Discovery, Terrain Terraforming Hammer, Gummi Block Vehicle Builder, Cooking Minigame |
| Movement & Traversal Systems | 7 | Spin Dash Charge Burst, Speed Tunnel Auto-Runner, Flight Necklace Time-Limited Flying, Paraloop Capture Draw, Partner Character Abilities, Flowmotion Rail Riding, Cannon Travel Rapid Transit |
| Companion & Pet Systems | 3 | Dream Eater Creature Creator, Nightopian A-Life Ecosystem, Monster Taming Whistle |
| Progression & Mastery Systems | 4 | Sphere Grid Skill Board, Gambit Buddy Behavior Cards, New Game+ Loop Mode, Phozon Absorption Growth |
| World & Narrative Systems | 5 | Time Travel Era Doors, Random Encounter Adventure Paths, NPC Town Builder Requests, Trinity Mark Co-op Secrets, Moogle Mail Delivery |
| Minigame & Arcade Systems | 9 | Blue Sphere Bonus Stage, Card Battle Collectible Game, Synthesis Workshop Upgrades, Score Attack Time Trial Mode, Weapon Pickup Environment Arsenal, Star Move Power Attacks, Voice-Activated Creature Care, Attraction Flow Ride Battles, Evolving Music Soundscape |
| **TOTAL** | **50** | |

---

## Cross-Cutting Design Principles

### Kid-First Interaction Patterns
Every feature in this document follows these interaction principles for 5-year-old usability:

1. **Stamp to Place**: All world objects are placed by stamping on a canvas. No coordinate input, no numeric values.
2. **Sticker to Customize**: Tapping a placed object opens a sticker picker for configuration. No dropdown menus, no text input.
3. **Single Toggle for Binary Options**: Features are enabled/disabled with a big, colorful toggle switch. No checkboxes.
4. **Drag for Combination**: Combining items is done by dragging stickers together. No recipe memorization.
5. **Visual Feedback Always**: Every action produces immediate, colorful, satisfying visual feedback. No invisible state changes.
6. **No Failure Penalties**: Mistakes produce playful, non-punishing results. Invalid crafting = "Poof!" dust cloud, not lost materials.
7. **Progressive Disclosure**: Advanced options are hidden behind a "More Options" button. Core interaction stays simple.

### LLM Automation Scope
The LLM handles all complexity invisibly:

- **Physics**: All movement, collision, gravity, and projectile behavior
- **AI**: Companion pathfinding, enemy behavior, NPC routines
- **State Management**: Inventory, progression, unlocks, flags
- **Balancing**: Auto-scaling damage, health, and difficulty based on level content
- **Procedural Generation**: Sprite variants, enemy combinations, music layers
- **Validation**: Ensuring designs are completable and fair
- **Translation**: Converting visual stamps into functional game objects

### JSON Contract Philosophy
The JSON extensions shown are the **LLM's internal representation** -- not exposed to the child. They represent the structured data the LLM generates from the child's stamp placements and sticker choices. The LLM populates these contracts invisibly and uses them to generate the playable game.

---

## Source Games Reference

| Game | Developer | Key Systems Extracted |
|------|-----------|----------------------|
| Final Fantasy I-XVI | Square Enix | Summons, Job System, Limit Break, Materia, Sphere Grid, Gambit, Paradigm, ATB, Elemental Wheel, Status Effects, Triple Triad |
| Kingdom Hearts I-III | Square Enix | Drive Forms, Gummi Ship, Summons, Reaction Commands, Flowmotion, Command Deck, Dream Eaters, Trinity Marks, Synthesis, Attraction Flow, Shotlock |
| Chrono Trigger | Square Enix | Tech Combos (Single/Double/Triple), Time Travel, New Game+, Multiple Endings, X-Strike, Luminaire, Delta Force |
| Dragon Quest Builders 1 & 2 | Square Enix | Room Recognition, Crafting, Terraforming, NPC Requests, Cooking, Farming, Monster Taming |
| Sonic the Hedgehog (Mania / S3&K) | Sega | Spin Dash, Elemental Shields, Special Stages, Super Transformation, Partner Characters, Speed Tunnels, Time Attack, Blue Spheres |
| NiGHTS into Dreams | Sega | Flight Mechanics, A-Life System, Paraloop, Link Chaining, Score Attack, Shapeshift, Evolving Music |
| Seaman | Sega | Voice-Activated Creature Care, Evolution Over Time |
| Streets of Rage 4 | Sega / Guard Crush | Beat-'Em-Up Combos, Juggling, Wall Bounces, Special Attacks, Star Moves, Weapon Pickups, Combo Scoring |
| Odin Sphere / Muramasa | Vanillaware (Atlus) | 2D Action RPG, Skill Trees, Cooking, Alchemy, Phozon Absorption |
| Secret of Mana / Trials of Mana | Square Enix | Ring Menu, Weapon Forging, Class Changes, Multiplayer, Cannon Travel |

---

*Research compiled from canonical game documentation, wiki sources, and direct gameplay analysis. All features are reimagined for zero-code, stamp-based, LLM-powered kid-friendly game creation.*

*Document Version: 1.0*
*Total Features: 50*
*Target Platform: KidGameMaker (ages 5+)*
