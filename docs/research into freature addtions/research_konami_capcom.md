# KidGameMaker Feature Research: Konami & Capcom Game Design Patterns
## Extracted from: Castlevania, Metal Gear Solid, Mega Man, Monster Hunter, Street Fighter, Okami, Resident Evil, Phoenix Wright

---

> **Design Principle:** Every feature must be activatable by a 5-year-old through simple stamps, single-taps, or drag gestures. All complexity is handled invisibly by the backend LLM.

---

## Section 1: CASTLEVANIA (Symphony of the Night & Metroidvanias)

---

### Feature 1: Relic Power-Up Gating
- **Source:** Castlevania: Symphony of the Night
- **Description:** The player collects permanent power-up relics that grant new traversal abilities (double jump, mist form, bat form, wolf form, gravity boots) which in turn unlock previously inaccessible areas of the map. Each relic opens new design space for level creation.
- **Kid UX:** Kid stamps a "Relic Chest" on the canvas. A popup shows a big, colorful icon of the relic (e.g., bat wings for Bat Form). Tapping the icon equips it. When the kid stamps a "Mist Gate" or "High Ledge," the LLM auto-detects which relics are needed and marks them with colored sparkles if the player has the matching relic.
- **LLM Automation:** The LLM maintains a directed acyclical graph of gating dependencies (e.g., Bat Form requires Soul of Bat; certain ledges require Leap Stone). It auto-validates map reachability, ensures no soft-locks, and calculates which areas become accessible after each relic acquisition.
- **JSON Contract Extension:**
  ```json
  {
    "relics": [{"id": "soul_of_bat", "name": "Bat Form", "unlockType": "flight", "prereq": null}],
    "gates": [{"id": "mist_grate_1", "requiredRelic": "form_of_mist", "regionId": "underground"}],
    "reachabilityGraph": {"nodes": [...], "edges": [...]}
  }
  ```

---

### Feature 2: Familiar Companion System
- **Source:** Castlevania: Symphony of the Night
- **Description:** A floating companion creature follows the player and provides passive assistance. Types include: Faerie (auto-heal when low HP, cures status), Bat (shoots fireballs at enemies), Ghost (latches onto enemies to drain HP), Demon (casts spells), Sword Familiar (attacks nearby enemies independently, eventually becomes equippable).
- **Kid UX:** Kid opens a "Familiar" stamp palette and stamps a familiar orb onto the player character. The familiar immediately appears and follows. Tapping the familiar toggles it on/off with a happy/sad face animation.
- **LLM Automation:** The LLM handles all familiar AI behavior trees (attack radius, heal triggers at HP thresholds, pathfinding to stay near player), stat scaling (familiar levels up as player defeats enemies), and auto-triggers abilities based on context (e.g., faerie uses hammer when player is petrified).
- **JSON Contract Extension:**
  ```json
  {
    "familiars": [{
      "id": "faerie",
      "behaviorType": "healer_support",
      "triggerConditions": [{"type": "hp_below", "threshold": 0.25, "action": "use_potion"}],
      "attackRadius": 100,
      "levelScaling": {"maxLevel": 99, "expPerKill": 1}
    }]
  }
  ```

---

### Feature 3: Equipment Slot System
- **Source:** Castlevania: Symphony of the Night
- **Description:** A 5-slot equipment system: Right Hand (weapon), Left Hand (shield or second weapon), Head (helmet), Body (armor), Accessory. Each slot accepts one item. Equipment changes visible character appearance and modifies stats (STR, CON, INT, LCK).
- **Kid UX:** Kid drags a "Sword" stamp or "Shield" stamp onto a body-outline popup with 5 glowing drop zones (head, body, left hand, right hand, accessory). Items snap into place with a satisfying sound. The character sprite updates instantly to show the equipped gear.
- **LLM Automation:** The LLM computes aggregate stats from all equipped items, handles equipment-exclusive interactions (e.g., certain shields boost certain swords), manages resistance calculations (fire armor reduces fire damage), and auto-generates appropriate stat tooltips.
- **JSON Contract Extension:**
  ```json
  {
    "equipmentSlots": ["rightHand", "leftHand", "head", "body", "accessory"],
    "equipment": [{"id": "crissaegrim", "slot": "rightHand", "stats": {"STR": 5, "attackSpeed": 3}, "element": "slash"}],
    "setBonuses": [{"items": ["shield_rod", "alucard_shield"], "bonus": "shield_spell"}]
  }
  ```

---

### Feature 4: Stat-Based Character Progression
- **Source:** Castlevania: Symphony of the Night
- **Description:** Five core stats govern gameplay: STR (physical damage), CON (defense/HP), INT (magic damage/spell effectiveness), LCK (drop rates/critical hits), and a leveling system where defeating enemies grants EXP to raise stats.
- **Kid UX:** Kid stamps a "Level Up Orb" on the canvas. When the player touches it, a big colorful burst plays and one stat (chosen by tapping one of 4 big icons: Muscle=STR, Heart=CON, Star=INT, Clover=LCK) increases. Numbers float above the player showing the gain.
- **LLM Automation:** The LLM manages the EXP curve, calculates damage formulas (damage = attacker.STR * weaponMultiplier - defender.CON * armorMultiplier), determines drop rates scaled by LCK, and auto-balances enemy stats to player level.
- **JSON Contract Extension:**
  ```json
  {
    "stats": {"STR": 10, "CON": 8, "INT": 6, "LCK": 5},
    "expCurve": "polynomial",
    "levelFormula": "baseHP + CON * 5 + level * 2",
    "damageFormula": "(attacker.STR * weapon.power) / (1 + defender.CON * 0.1)"
  }
  ```

---

### Feature 5: Breakable Secret Walls
- **Source:** Castlevania: Symphony of the Night
- **Description:** Certain walls in the environment look slightly different and can be destroyed by attacking them, revealing hidden rooms containing rare items, relics, or shortcuts.
- **Kid UX:** Kid stamps a "Secret Wall" stamp onto any wall tile. The wall gets a very subtle crack visual (LLM auto-applies). When the player attacks it, the wall shatters with a crumble animation, revealing whatever is behind. Kid can stamp items, enemies, or portals behind the secret wall.
- **LLM Automation:** The LLM auto-applies the cracked visual cue, handles destruction physics (particle burst, sound trigger), reveals the hidden area, and tracks secret-discovery statistics for the player.
- **JSON Contract Extension:**
  ```json
  {
    "secretWalls": [{"tileId": "wall_42", "visualCue": "subtle_crack", "requiredPower": "any_attack", "hiddenContent": ["item_id_123"], "oneTime": true}]
  }
  ```

---

### Feature 6: Save Room & Warp Room Network
- **Source:** Castlevania: Symphony of the Night
- **Description:** Dedicated safe rooms where players can save progress (red rooms) and teleport between discovered locations (blue/yellow warp rooms). Enemies cannot enter these rooms.
- **Kid UX:** Kid stamps a "Save Crystal" or "Warp Mirror" onto the canvas. Save crystals glow blue; warp mirrors glow gold. Stepping on either triggers a full-screen sparkle transition. The warp mirror shows a mini-map of all discovered warp points as glowing dots; tapping one teleports there.
- **LLM Automation:** The LLM manages the warp room graph (only visited warp rooms are selectable), ensures enemy AI cannot path into safe rooms, auto-saves player state at save crystals, and handles the transition effects.
- **JSON Contract Extension:**
  ```json
  {
    "saveRooms": [{"id": "save_1", "position": [120, 340], "type": "save"}],
    "warpNetwork": {"nodes": ["warp_1", "warp_2", "warp_3"], "edges": "fully_connected"},
    "safeRoomFlags": ["no_enemies", "heal_over_time", "reset_status_ailments"]
  }
  ```

---

### Feature 7: Inverted World / Mirror Castle
- **Source:** Castlevania: Symphony of the Night (Inverted Castle)
- **Description:** After completing the main castle, an inverted version unlocks -- the entire map is flipped upside-down with harder enemies, new bosses, and exclusive items. This effectively doubles content using the same map layout.
- **Kid UX:** Kid stamps a "Mirror Portal" at the end of their level. After defeating the final boss, a cutscene plays and the entire map inverts (gravity flips, ceiling becomes floor). New enemy stamps and item stamps become available in the palette. The kid can toggle between Normal and Inverted views with a big sun/moon button.
- **LLM Automation:** The LLM auto-generates the inverted version of the map (flip Y coordinates), scales enemy stats by a multiplier, replaces loot tables with inverted-exclusive drops, and tracks completion percentage across both castles.
- **JSON Contract Extension:**
  ```json
  {
    "worldVersions": ["normal", "inverted"],
    "invertTransform": {"scaleY": -1, "gravityFlip": true},
    "enemyScaling": {"inverted": {"hpMult": 2.0, "damageMult": 1.5, "expMult": 2.5}},
    "exclusiveDrops": {"inverted": ["alucard_sword", "alucard_shield", "dracula_relics"]}
  }
  ```

---

### Feature 8: Spell Command Input System (Simplified)
- **Source:** Castlevania: Symphony of the Night
- **Description:** Special spells activated by directional inputs + button combinations (e.g., Down-Forward-Attack for Hellfire, Hold Up + Attack for Summon Spirit). Over 20 spells exist with varying MP costs and effects.
- **Kid UX:** Kid stamps a "Spell Scroll" item onto the canvas. When the player collects it, a spell icon appears in a hotbar at the bottom of the screen. Tapping the spell icon casts it instantly -- no complex inputs. Spells have cooldown timers shown as a radial fill on the icon.
- **LLM Automation:** The LLM handles MP costs, cooldown management, collision detection for spell hitboxes, damage calculation modified by INT stat, and unlocks spell icons as the player discovers scrolls.
- **JSON Contract Extension:**
  ```json
  {
    "spells": [{"id": "hellfire", "mpCost": 15, "damage": 25, "element": "fire", "cooldown": 3.0, "unlockScrollId": "scroll_hellfire"}],
    "spellHotbar": {"maxSlots": 4, "cooldownVisual": "radial_fill"}
  }
  ```

---

### Feature 9: Enemy Item Drop System
- **Source:** Castlevania: Symphony of the Night
- **Description:** Each enemy has a unique drop table with common, uncommon, and rare items. Drop chance is influenced by the player's Luck (LCK) stat. Some items have drop rates as low as 0.5%.
- **Kid UX:** Kid stamps an enemy, then taps a "treasure bag" icon that appears above the enemy stamp. A simple 3-slot popup shows: Common (big bag, 70%), Uncommon (sparkly bag, 25%), Rare (rainbow bag, 5%). Kid drags items into each slot. When the player defeats this enemy in-game, the appropriate item drops with a satisfying bounce animation.
- **LLM Automation:** The LLM manages RNG roll on defeat (modified by player LCK), handles drop physics (item bounces, then magnetizes toward player), manages inventory pickup, and applies Luck stat modifiers to drop rates.
- **JSON Contract Extension:**
  ```json
  {
    "dropTables": {
      "enemy_id": {
        "common": {"itemId": "potion", "baseChance": 0.70, "luckScaling": 0.01},
        "uncommon": {"itemId": "hi_potion", "baseChance": 0.25, "luckScaling": 0.02},
        "rare": {"itemId": "rare_sword", "baseChance": 0.05, "luckScaling": 0.05}
      }
    }
  }
  ```

---

### Feature 10: Soul Absorption System
- **Source:** Castlevania: Aria of Sorrow
- **Description:** Defeating enemies sometimes releases their soul, which the player can absorb to gain that enemy's ability. Four soul types: Bullet Souls (active attacks), Guardian Souls (passive/toggle buffs), Enchanted Souls (passive stat boosts), and Ability Souls (permanent traversal upgrades).
- **Kid UX:** Kid stamps an "Enemy Soul" orb onto an enemy stamp. The enemy gets a colored aura (red=attack, blue=buff, yellow=passive, silver=ability). When the player defeats this enemy in-game, a glowing soul may float out; touching it absorbs the ability. Absorbed souls appear as colorful badges in a "Soul Collection" screen.
- **LLM Automation:** The LLM handles soul drop RNG, categorizes souls by type, manages equip limits (only 1 of each type active), applies passive enchanted soul bonuses, and handles guardian soul MP drain while active.
- **JSON Contract Extension:**
  ```json
  {
    "souls": [{"id": "skeleton_soul", "type": "bullet", "ability": "throw_bone", "dropRate": 0.15, "dropFrom": "skeleton"}],
    "soulSlots": {"bullet": 1, "guardian": 1, "enchanted": 3, "ability": -1},
    "soulCollection": {"total": 100, "collected": []}
  }
  ```

---

### Feature 11: Glyph Drawing System
- **Source:** Castlevania: Order of Ecclesia
- **Description:** Players absorb magical glyphs (symbols) from enemies or the environment and equip them in 3 slots (left arm, right arm, back). Glyph Unions combine equipped glyphs for powerful combo attacks. Glyphs include weapons (sword, axe, bow), spells (fire, ice, lightning), and transformations.
- **Kid UX:** Kid stamps a "Glyph Source" onto an enemy or object. A glowing magical symbol appears. The kid traces the symbol with their finger (simple 2-3 stroke shapes: circle, zigzag, line). Successfully tracing it absorbs the glyph. Glyph badges appear in a palette; dragging a glyph onto one of 3 body slots equips it. Combining two matching glyphs auto-triggers a Glyph Union (spectacular combo animation).
- **LLM Automation:** The LLM validates glyph trace accuracy (90%+ = success), manages the 3-slot equipment system, computes Glyph Union results based on element combinations (fire + sword = flaming sword), handles MP consumption, and tracks absorbed glyphs.
- **JSON Contract Extension:**
  ```json
  {
    "glyphs": [{"id": "confodere", "type": "weapon", "element": "slash", "mpCost": 5, "tracePattern": "zigzag"}],
    "glyphSlots": ["leftArm", "rightArm", "back"],
    "glyphUnions": [{"combo": ["confodere", "ignis"], "result": "flame_sword_union", "damage": 40}],
    "absorbedGlyphs": []
  }
  ```

---

### Feature 12: Dual-Character Switching
- **Source:** Castlevania: Portrait of Ruin
- **Description:** Two playable characters (Jonathan the warrior + Charlotte the spellcaster) that can be switched between instantly. Each has different stats, equipment, and abilities. Both share the same screen but only one is player-controlled at a time; the other follows as a companion with basic AI.
- **Kid UX:** Kid stamps a "Hero" character, then stamps a "Partner" character. Both appear on screen. A big colorful "SWAP" button at the screen edge switches control between them. The partner auto-follows and auto-attacks nearby enemies. Kid can drag equipment onto either character's body outline independently.
- **LLM Automation:** The LLM manages partner AI (follow distance, auto-attack radius, spell casting when enemy in range), handles HP/MP separately per character, manages shared inventory vs. character-specific equipment, and triggers combo attacks when both characters attack the same target simultaneously.
- **JSON Contract Extension:**
  ```json
  {
    "characters": [
      {"id": "jonathan", "role": "warrior", "stats": {"STR": 12, "INT": 4}, "equipment": {...}},
      {"id": "charlotte", "role": "mage", "stats": {"STR": 5, "INT": 14}, "equipment": {...}}
    ],
    "switchCooldown": 0.5,
    "partnerAI": {"followDist": 80, "attackRadius": 120, "spellTrigger": "enemy_in_range"},
    "dualCombos": [{"condition": "both_attack_same_target", "bonusDamage": 1.5}]
  }
  ```

---

## Section 2: METAL GEAR SOLID

---

### Feature 13: Stealth Detection Phases
- **Source:** Metal Gear Solid series
- **Description:** A three-phase stealth system: NORMAL (enemy patrols on routine paths), CAUTION (enemy heard something and investigates the area), ALERT (enemy spotted the player and attacks). Each phase has distinct enemy AI behavior and visual indicators.
- **Kid UX:** Kid stamps a "Guard" enemy, then stamps a "Vision Cone" trail extending from the guard in any direction. The cone shows the guard's sight range (green=normal, yellow=caution, red=alert). Tapping the guard toggles between stationary and patrol route modes. Stealth sections auto-highlight when the player crouches.
- **LLM Automation:** The LLM implements the full stealth AI state machine: Normal->Caution (sound trigger or peripheral vision), Caution->Alert (direct line of sight), Alert->Evasion (countdown timer), Evasion->Normal. Handles sound propagation, line-of-sight checks, and shared enemy alert (one guard alerts others).
- **JSON Contract Extension:**
  ```json
  {
    "stealthPhases": ["normal", "caution", "alert", "evasion"],
    "visionCones": {"normal": {"angle": 90, "range": 200, "color": "#00FF00"}, "alert": {"angle": 120, "range": 300, "color": "#FF0000"}},
    "soundPropagation": {"wallDampening": 0.5, "alertRadius": 150},
    "phaseTransitions": {"alert_to_evasion": 10.0, "evasion_to_normal": 15.0}
  }
  ```

---

### Feature 14: Cardboard Box Hiding
- **Source:** Metal Gear Solid series
- **Description:** The player can hide inside a cardboard box to become invisible to guards. Guards will ignore the box in Normal phase but may investigate it during Caution. Some boxes are themed for specific areas (e.g., a snow box for snowy areas) and blend in better.
- **Kid UX:** Kid stamps a "Cardboard Box" item onto the canvas. When the player touches it, they pop inside with a comical animation (feet sticking out). The player becomes a box that can slide around slowly. Tapping a "Pop Out" button exits the box.
- **LLM Automation:** The LLM handles the visibility state change (player sprite replaced by box sprite), reduces movement speed while boxed, modifies guard AI detection (box is invisible to normal patrol, suspicious in caution, obvious in alert), and manages box inventory (different box types for different areas).
- **JSON Contract Extension:**
  ```json
  {
    "hideables": [{"id": "cardboard_box", "camouflageRating": 0.8, "moveSpeedMult": 0.3, "alertSuspicion": 0.3}],
    "stealthStates": {"hidden": {"detectable": false, "moveable": true}, "exposed": {"detectable": true, "moveable": true}}
  }
  ```

---

### Feature 15: Codec Communication System
- **Source:** Metal Gear Solid series
- **Description:** The player can call support characters via radio (codec) to receive mission hints, backstory, gameplay tips, and emotional support. Each contact has a unique frequency and personality.
- **Kid UX:** Kid stamps a "Codec Station" or "Radio" item. Tapping it opens a contact list with big character portraits. Tapping a character initiates a fun chat bubble conversation where the character gives hints about nearby secrets or the current area. Characters have expressive face icons.
- **LLM Automation:** The LLM generates context-aware dialog based on the player's current location, recent actions, and stuck-points. It tracks which hints have been given, provides progressively more specific hints if the player remains stuck, and manages character voice/personality consistency.
- **JSON Contract Extension:**
  ```json
  {
    "codecContacts": [{"id": "colonel", "frequency": "140.85", "hintTopics": ["boss_weakness", "item_location"], "personality": "military"}],
    "hintTriggers": [{"areaId": "area_3", "condition": "player_stuck_60s", "hintLevel": "vague"}],
    "conversationHistory": []
  }
  ```

---

### Feature 16: Boss-Specific Weakness Mechanics
- **Source:** Metal Gear Solid (Psycho Mantis reads controller inputs, Vulcan Raven uses a tank, The End is a sniper duel)
- **Description:** Bosses have unique mechanics that require unconventional strategies -- Psycho Mantis reads the player's movement patterns and dodges everything unless the controller is unplugged and moved to port 2; The End is an extended sniper duel requiring patience and thermal goggles.
- **Kid UX:** Kid stamps a "Boss Stamp" on the canvas, then taps a "Special Weakness" button. A visual wheel shows weakness types: "Pattern Break" (change your movement), "Environment Use" (use objects in the room), "Wait & Watch" (patience wins). The kid picks one and stamps a corresponding interaction object. For Pattern Break, the boss gets confused stars when the player moves differently.
- **LLM Automation:** The LLM tracks player behavior patterns (movement tendencies, attack rhythms) and has the boss adapt if the player is predictable. For Pattern Break bosses, it detects when the player changes their pattern and triggers a vulnerability window. Handles unique boss AI per type.
- **JSON Contract Extension:**
  ```json
  {
    "bossWeaknessTypes": ["pattern_break", "environmental", "elemental", "tool_specific"],
    "bossAI": {"type": "pattern_reader", "adaptationSpeed": 5.0, "vulnerabilityWindow": 3.0},
    "behaviorTracker": {"attackPatterns": [], "movementPatterns": [], "lastChanged": 0}
  }
  ```

---

### Feature 17: Camouflage / Disguise Index
- **Source:** Metal Gear Solid 3, 4
- **Description:** The player's visibility is determined by how well their outfit matches the environment. Different camouflage patterns (woodland, desert, urban) and face paint reduce detection probability. A numerical camo index (0-100%) shows current stealth effectiveness.
- **Kid UX:** Kid stamps a "Costume Rack" item. Tapping it shows big outfit icons (leaf pattern for forest, sand color for desert, gray for city). Dragging an outfit onto the player changes their appearance instantly. A large percentage number appears showing how well they blend in -- 90%+ means they're nearly invisible.
- **LLM Automation:** The LLM samples the environment pixels around the player, compares them to the equipped camouflage pattern, calculates a real-time camo index (0-100), and applies this as a multiplier to enemy detection range and speed.
- **JSON Contract Extension:**
  ```json
  {
    "camouflage": [{"id": "woodland", "matchTerrain": ["forest", "grass"], "baseIndex": 80}],
    "camoCalculation": {"sampleRadius": 50, "pixelComparison": "average_color"},
    "detectionModifier": {"formula": "baseDetection * (1 - camoIndex/100)"}
  }
  ```

---

### Feature 18: Decoy Items & Distractions
- **Source:** Metal Gear Solid series
- **Description:** The player can throw or place items that create sounds or visual distractions to lure guards away from their posts. Examples: empty magazine clip (noise lure), dirty magazine (guard stops to look), sleeping gas grenade.
- **Kid UX:** Kid stamps a "Noise Maker" or "Shiny Object" onto the canvas. Guards within range get a "?" above their heads and walk toward the distraction. A dotted line shows the lure path. Kid can also stamp "Sleepy Gas" clouds that put guards to sleep on contact.
- **LLM Automation:** The LLM handles sound propagation from the distraction point, calculates which guards are within hearing range, modifies guard patrol paths to investigate, manages distraction duration, and handles sleep/knockout status effects.
- **JSON Contract Extension:**
  ```json
  {
    "distractionItems": [
      {"id": "noise_maker", "soundRadius": 200, "guardReaction": "investigate", "duration": 5.0},
      {"id": "sleep_gas", "effectRadius": 80, "statusEffect": "sleep", "duration": 10.0}
    ]
  }
  ```

---

## Section 3: MEGA MAN / MEGA MAN X

---

### Feature 19: Boss Weapon Acquisition
- **Source:** Mega Man / Mega Man X series
- **Description:** Defeating each boss permanently grants the player that boss's signature weapon. Each weapon has unique properties, damage values, and special effects. Weapons draw from a shared weapon energy pool.
- **Kid UX:** Kid stamps a "Boss" on the canvas with a big weapon icon above it. After defeating the boss in-game, a dramatic weapon-grab animation plays, and the new weapon appears in the weapon wheel at the bottom of the screen as a colorful new icon. Each weapon has a bright, distinctive visual.
- **LLM Automation:** The LLM manages the weapon energy pool (shared across all special weapons), handles weapon swapping, computes damage based on the weapon vs. enemy weakness chart, and generates the weapon-get cutscene sequence.
- **JSON Contract Extension:**
  ```json
  {
    "bossWeapons": [{"id": "shotgun_ice", "fromBoss": "chill_penguin", "element": "ice", "energyCost": 2, "damage": 20}],
    "weaponEnergy": {"max": 28, "current": 28, "refillOnDeath": true},
    "weaponWheel": {"maxSlots": 8, "currentWeapons": []}
  }
  ```

---

### Feature 20: Elemental Weakness Wheel
- **Source:** Mega Man series (rock-paper-scissors boss weaknesses)
- **Description:** Each boss is weak to one specific weapon obtained from another boss, forming a circular weakness chain (e.g., Fire boss weak to Ice weapon, Ice boss weak to Electric weapon, Electric boss weak to Fire weapon). Using the correct weapon deals 2-4x damage.
- **Kid UX:** Kid stamps a boss, then a "Weakness Link" line appears. Kid drags the line to another boss to create a weakness relationship. The line becomes red (strong weakness) or blue (resistance). A circular weakness wheel diagram auto-generates in the corner showing all relationships.
- **LLM Automation:** The LLM validates that weakness chains form valid cycles (no orphaned bosses, no self-references), computes damage multipliers based on weakness matchups, and auto-generates the weakness wheel visualization.
- **JSON Contract Extension:**
  ```json
  {
    "weaknessWheel": {
      "elemental": {"fire": {"weakTo": "ice", "resists": "electric"}, "ice": {"weakTo": "electric", "resists": "fire"}},
      "bossSpecific": {"chill_penguin": {"weakTo": "fire_wave", "damageMult": 3.0}}
    }
  }
  ```

---

### Feature 21: Armor Part Capsules
- **Source:** Mega Man X series
- **Description:** Hidden capsules scattered throughout stages that permanently upgrade X's abilities: Foot Parts (dash ability), Body Parts (damage reduction), Head Parts (break ceilings, energy efficiency), Arm Parts (charge shot upgrade, charge special weapons). X2 adds: air dash, double charge shot. X3 adds: chip upgrades.
- **Kid UX:** Kid stamps a "Dr. Light Capsule" (glowing tube with a hologram) hidden in their level. When the player finds and enters it, a dramatic cutscene plays and a body part glows with an upgrade icon (lightning bolt for dash, shield for armor, star for helmet, fist for buster). The player sprite updates to show the new armor piece.
- **LLM Automation:** The LLM tracks which capsules have been collected, applies permanent ability flags (canDash, damageReductionPercent, canChargeWeapons), updates the player sprite to show progressive armor visual upgrades, and ensures capsules require prerequisite parts (e.g., Head Part needed for some capsules).
- **JSON Contract Extension:**
  ```json
  {
    "armorCapsules": [
      {"id": "foot_parts", "ability": "dash", "prereq": null, "visual": "white_leg_armor"},
      {"id": "body_parts", "ability": "damage_half", "prereq": "foot_parts", "visual": "white_chest_armor"},
      {"id": "arm_parts", "ability": "charge_special", "prereq": "head_parts", "visual": "red_buster"}
    ],
    "collectedCapsules": [],
    "abilityFlags": {"canDash": false, "canAirDash": false, "canChargeSpecial": false}
  }
  ```

---

### Feature 22: Charge Shot System
- **Source:** Mega Man X series
- **Description:** Holding the attack button charges the Mega Buster through 2-3 visual levels before releasing a more powerful shot. Level 1 = normal, Level 2 = large shot, Level 3 = massive beam (with Arm Parts). Special weapons can also be charged.
- **Kid UX:** Kid stamps a "Charger" upgrade onto the player character. A charge meter appears above the player (fills with color: yellow -> orange -> red). The player holds the attack button to charge; releasing fires the appropriately-sized projectile. Visual particles intensify as charge level increases.
- **LLM Automation:** The LLM manages charge level state machine (0->1->2->3), scales projectile size/damage by charge level, handles charge-cancel (jumping cancels charge), manages particle effects per level, and supports charged special weapons when Arm Parts are collected.
- **JSON Contract Extension:**
  ```json
  {
    "chargeSystem": {
      "levels": [
        {"level": 1, "chargeTime": 0.5, "damageMult": 1, "sizeMult": 1, "color": "#FFFF00"},
        {"level": 2, "chargeTime": 1.5, "damageMult": 2, "sizeMult": 2, "color": "#FF8800"},
        {"level": 3, "chargeTime": 2.5, "damageMult": 4, "sizeMult": 3, "color": "#FF0000"}
      ],
      "cancelActions": ["jump", "dash", "hurt"],
      "particleIntensity": "level_scaled"
    }
  }
  ```

---

### Feature 23: Rush Adapter (Companion Transformations)
- **Source:** Mega Man series (Rush, Treble, Beat)
- **Description:** A robot dog companion (Rush) that transforms into various utility forms: Rush Coil (springboard for high jumps), Rush Jet (flying platform), Rush Marine (underwater movement), Rush Search (digging for secrets). Limited by shared energy.
- **Kid UX:** Kid stamps a "Robot Dog" companion next to the player. A popup shows 4 big icons: Spring, Jet, Submarine, Shovel. Tapping an icon transforms the dog with a flash animation. Spring = bouncy platform (player jumps on it), Jet = dog becomes a flying vehicle, Sub = underwater swimming, Shovel = digs for buried items.
- **LLM Automation:** The LLM manages Rush energy (depletes on use, regenerates over time), handles transformation state machine, collision for each form (spring physics, flight movement, underwater controls), and auto-detects dig spots for Rush Search.
- **JSON Contract Extension:**
  ```json
  {
    "rushForms": [
      {"id": "rush_coil", "energyCost": 4, "type": "springboard", "bounceHeight": 300},
      {"id": "rush_jet", "energyCost": 2, "type": "vehicle", "speed": 200, "duration": 10},
      {"id": "rush_marine", "energyCost": 2, "type": "underwater", "speed": 150},
      {"id": "rush_search", "energyCost": 6, "type": "dig", "detectRadius": 100}
    ],
    "rushEnergy": {"max": 28, "current": 28, "regenRate": 1}
  }
  ```

---

### Feature 24: Battle Chip Deck System
- **Source:** Mega Man Battle Network
- **Description:** A deck-building combat system where the player collects Battle Chips (attack cards) and builds a folder (deck) of 30 chips. In combat, 5 random chips are drawn each turn; the player selects up to 5 to use. Chips have codes (letters) and can be combined for "Program Advances" (super combos).
- **Kid UX:** Kid stamps a "Chip Folder" item. A card-collection screen opens showing all collected chips as big, colorful trading cards with attack values and fun artwork. Kid drags 30 cards into their folder. In combat, 5 cards appear at the bottom each turn; kid taps a card to use it. Matching letter codes glow -- selecting compatible cards triggers a "Program Advance" with a spectacular combo animation.
- **LLM Automation:** The LLM manages the 30-card folder validation, handles random draws each turn, detects Program Advance combos (3+ chips with sequential codes), computes damage based on chip stats + Navi stats, and manages chip rarity and collection progress.
- **JSON Contract Extension:**
  ```json
  {
    "battleChips": [{"id": "cannon", "code": "A", "damage": 40, "element": "null", "rarity": "common"}],
    "folder": {"maxSize": 30, "current": [], "maxPerChip": 5},
    "programAdvances": [{"chips": ["sword", "widesword", "longsword"], "result": "lifesword", "damage": 400}],
    "drawPerTurn": 5
  }
  ```

---

### Feature 25: Grid-Based Tactical Movement
- **Source:** Mega Man Battle Network
- **Description:** Combat takes place on a 6x3 grid split between player (left 3 columns) and enemies (right 3 columns). Both player and enemies can only move on their panels. Panel types affect combat (cracked, broken, grass, ice, poison, holy).
- **Kid UX:** Kid stamps a "Battle Grid" onto the canvas. A 6x3 colored grid appears: blue panels on the left, red panels on the right. Kid stamps player on blue, enemies on red. Special "Panel" stamps can be placed: cracked (one hit breaks), grass (heals standing on it), ice (slides). Characters move one panel at a time with tap controls.
- **LLM Automation:** The LLM enforces grid movement rules (1 panel per move, no enemy panels), handles panel state transitions (normal->cracked->broken), applies panel effects (grass heals, poison damages, ice causes sliding), and validates attack ranges based on grid positions.
- **JSON Contract Extension:**
  ```json
  {
    "battleGrid": {"width": 6, "height": 3, "playerColumns": [0,1,2], "enemyColumns": [3,4,5]},
    "panelTypes": {
      "normal": {"effect": null},
      "cracked": {"effect": "break_on_hit", "transitionTo": "broken"},
      "grass": {"effect": "heal_5_per_turn"},
      "ice": {"effect": "slide_movement"},
      "poison": {"effect": "damage_5_per_turn"}
    }
  }
  ```

---

## Section 4: MONSTER HUNTER

---

### Feature 26: Weapon Type Selection
- **Source:** Monster Hunter series
- **Description:** 14 distinct weapon types, each with unique movesets, combo strings, and mechanics: Great Sword (charge attacks), Long Sword (spirit gauge), Sword & Shield (fast + item use), Dual Blades (demon mode), Hammer (KO damage), Hunting Horn (buff songs), Lance (counter-block), Gunlance (shelling combos), Switch Axe (transform between axe/sword), Charge Blade (phial system), Insect Glaive (kinsect buffs), Bow (charge shots), Light Bowgun (rapid fire), Heavy Bowgun (siege mode).
- **Kid UX:** Kid stamps a "Weapon Rack" item. 14 big, distinct weapon icons appear in a scrollable row. Tapping a weapon shows a short animated preview of its basic attack. The kid drags their chosen weapon onto the player character. The player sprite updates to wield that weapon. A simple 3-hit combo is available via rapid attack taps.
- **LLM Automation:** The LLM implements the full moveset for each weapon type (combo trees, charge mechanics, special abilities like Demon Mode or Spirit Gauge), handles hitbox generation per attack frame, computes damage type (cutting/impact/pierce), and manages weapon-specific UI (gauges, ammo counters).
- **JSON Contract Extension:**
  ```json
  {
    "weaponTypes": [
      {"id": "great_sword", "damageType": "cutting", "mechanic": "charge_levels", "comboLength": 3, "mobility": "slow"},
      {"id": "dual_blades", "damageType": "cutting", "mechanic": "demon_mode", "comboLength": 8, "mobility": "fast"},
      {"id": "hunting_horn", "damageType": "impact", "mechanic": "melody_buffs", "comboLength": 4, "mobility": "medium"}
    ],
    "equippedWeapon": "great_sword",
    "weaponMovesets": {"great_sword": {"charge1": {"time": 1.0, "damage": 50}, "charge2": {"time": 2.5, "damage": 120}}}
  }
  ```

---

### Feature 27: Elemental Damage System
- **Source:** Monster Hunter series
- **Description:** Weapons and monsters have elemental affinities: Fire, Water, Thunder, Ice, and Dragon. Hitting a monster with its elemental weakness deals bonus damage; hitting a resistance deals reduced damage. Visual feedback shows element-appropriate hit effects.
- **Kid UX:** Kid stamps a weapon, then taps an "Element" sparkle to assign it: red=Fire, blue=Water, yellow=Thunder, white=Ice, purple=Dragon. Monster stamps also get elemental affinity icons (flame for fire-weak monster). When the player hits the monster, big colored damage numbers appear and elemental burst particles match the element color.
- **LLM Automation:** The LLM maintains an elemental effectiveness chart per monster (e.g., Rathalos: weak to Dragon, resistant to Fire), applies damage multipliers based on weapon element vs. monster hitzone effectiveness, and generates appropriate hitstop and particle effects.
- **JSON Contract Extension:**
  ```json
  {
    "elements": ["fire", "water", "thunder", "ice", "dragon"],
    "elementalEffectiveness": {
      "rathalos": {"fire": 0.0, "water": 0.15, "thunder": 0.25, "ice": 0.15, "dragon": 0.35}
    },
    "weaponElement": {"id": "thunder_sword", "element": "thunder", "value": 250}
  }
  ```

---

### Feature 28: Palico Companion System
- **Source:** Monster Hunter series (Palicoes)
- **Description:** A cat companion that assists in combat, healing, trapping, and gathering. Palicoes have: support moves (healing bubble, trap setup), Palico Gadgets (various tools), and can be customized with armor/weapon loadouts.
- **Kid UX:** Kid stamps a "Palico" (cute cat warrior) next to the player. Tapping the Palico opens a customization screen: big armor slots, tiny weapon choices, and a "Gadget" selection (healing horn, trap net, flash bomb). The Palico follows the player, fights with small attacks, and auto-uses its gadget when appropriate.
- **LLM Automation:** The LLM handles Palico AI (engage enemies at medium range, retreat at low HP, use gadget on cooldown or trigger condition), manages Palico equipment stats, handles gadget abilities (healing radius, trap placement), and tracks Palico experience/leveling.
- **JSON Contract Extension:**
  ```json
  {
    "palico": {
      "level": 5,
      "equipment": {"weapon": "palico_sword", "armor": "palico_bone_set"},
      "gadget": {"id": "vigorwasp", "type": "heal", "cooldown": 30, "trigger": "player_hp_below_50%"},
      "supportMoves": ["heal", "trap", "flash"]
    }
  }
  ```

---

### Feature 29: Item Crafting & Combining
- **Source:** Monster Hunter series
- **Description:** Players combine two items to create new, more powerful items. Examples: Potion + Honey = Mega Potion; Trap Tool + Net = Pitfall Trap; Bomb Casing + Barrel = Barrel Bomb. Over 200 combinations exist.
- **Kid UX:** Kid stamps a "Crafting Bench" onto the canvas. Two big "+" slots appear. Kid drags any two item stamps into the slots. If a valid combination exists, a glowing arrow appears pointing to the result item with a "Craft!" button. Invalid combinations show a gentle shake animation. A recipe book icon shows discovered combinations as colorful pictures.
- **LLM Automation:** The LLM maintains the full recipe database, validates combinations, handles success/fail animation, manages inventory updates (consume ingredients, add result), and auto-adds new recipes to the kid's recipe book when discovered.
- **JSON Contract Extension:**
  ```json
  {
    "craftingRecipes": [
      {"id": "mega_potion", "ingredients": ["potion", "honey"], "result": "mega_potion", "quantity": 1},
      {"id": "pitfall_trap", "ingredients": ["trap_tool", "net"], "result": "pitfall_trap", "quantity": 1}
    ],
    "discoveredRecipes": [],
    "craftingBench": {"slots": 2, "allowExperimentation": true}
  }
  ```

---

### Feature 30: Monster Part Breaking
- **Source:** Monster Hunter series
- **Description:** Monsters have breakable body parts (head, wings, tail, claws). Dealing enough concentrated damage to a part causes it to break, changing the monster's behavior and adding extra reward items at quest end. Severing a tail creates a new interactable object on the ground.
- **Kid UX:** Kid stamps a "Big Monster" on the canvas. Tapping the monster shows dotted outlines around breakable parts: head, wings, tail, each with a small HP bar. When a part's HP bar empties in-game, a dramatic break animation plays (tail falls off, horn cracks, wing tears). Broken parts change the monster's attack patterns.
- **LLM Automation:** The LLM tracks per-part damage thresholds, triggers break animations at thresholds, modifies monster moveset when parts break (e.g., broken tail = reduced tail swipe range), spawns severed parts as carvable objects, and adds part-break rewards to the quest reward pool.
- **JSON Contract Extension:**
  ```json
  {
    "monsterParts": [
      {"id": "tail", "breakThreshold": 500, "severable": true, "behaviorChange": "tail_swiper_disabled"},
      {"id": "head", "breakThreshold": 800, "severable": false, "behaviorChange": "charge_speed_reduced"}
    ],
    "partBreakRewards": {"tail": ["rathalos_tail", "rathalos_scale"], "head": ["rathalos_wing"]}
  }
  ```

---

### Feature 31: Cooking / Steak Mini-Game
- **Source:** Monster Hunter series
- **Description:** Before a hunt, the player can cook raw meat on a BBQ spit to create well-done steaks that restore stamina. Timing matters: undercooked gives less stamina, burnt gives nothing. The classic "so tasty!" celebration plays on a perfect cook.
- **Kid UX:** Kid stamps a "BBQ Spit" item. A cooking mini-game starts: meat rotates on a spit, and a color meter fills (blue->yellow->red). Kid taps when the color is in the golden zone. "So Tasty!" confetti bursts on perfect timing. Different food items (meat, fish, mushroom) give different stat boosts.
- **LLM Automation:** The LLM manages the timing window (perfect/good/burnt zones), plays the appropriate result animation, applies the corresponding buff to the player (stamina restore, attack up, defense up based on food type + cook quality), and manages ingredient consumption.
- **JSON Contract Extension:**
  ```json
  {
    "cooking": {
      "timingZones": {"undercooked": [0, 0.4], "perfect": [0.4, 0.7], "burnt": [0.7, 1.0]},
      "recipes": [{"id": "well_done_steak", "ingredient": "raw_meat", "perfectBuff": {"stamina": 50, "duration": 600}}],
      "animationTriggers": {"perfect": "so_tasty_confetti", "burnt": "smoke_poof"}
    }
  }
  ```

---

### Feature 32: Traps & Status Effects
- **Source:** Monster Hunter series
- **Description:** Players can deploy traps (Pitfall Trap = sink into ground, immobilized; Shock Trap = paralysis for duration; Tranq Bomb = sleep/capture). Traps are essential for capturing monsters alive for bonus rewards.
- **Kid UX:** Kid stamps a "Pitfall Trap" or "Shock Trap" onto the ground. The trap is hidden until triggered. When a monster walks over it: Pitfall = monster sinks into the ground and can't move for 10 seconds; Shock = monster twitches with electricity and is stunned. A "Capture" icon appears when the monster is weak enough + trapped.
- **LLM Automation:** The LLM handles trap trigger detection, applies immobilization status, manages trap duration, tracks monster HP threshold for capture eligibility, and handles capture rewards vs. slay rewards.
- **JSON Contract Extension:**
  ```json
  {
    "trapTypes": [
      {"id": "pitfall", "duration": 10, "effect": "immobilize", "trigger": "monster_step_on"},
      {"id": "shock_trap", "duration": 8, "effect": "paralyze", "trigger": "monster_step_on"}
    ],
    "captureMechanic": {"hpThreshold": 0.20, "requiresTrap": true, "bonusRewards": ["capture_gem"]},
    "statusEffects": ["immobilize", "paralyze", "sleep", "poison", "stun"]
  }
  ```

---

## Section 5: STREET FIGHTER

---

### Feature 33: Special Move Input System (Kid-Simplified)
- **Source:** Street Fighter series
- **Description:** Classic special moves performed via directional inputs + attack (Hadoken = Down, Down-Forward, Forward + Punch; Shoryuken = Forward, Down, Down-Forward + Punch; Tatsumaki = Down, Back, Kick). Each character has 3+ unique special moves.
- **Kid UX:** Kid stamps a "Special Move" icon onto their character. A visual wheel appears showing 3 big directional gestures (swipe right then tap = fireball, swipe up then tap = uppercut, swipe circle then tap = spin kick). The child draws the gesture on-screen and the move executes. Special moves have cooldown meters.
- **LLM Automation:** The LLM implements gesture recognition (swipe patterns mapped to move inputs), manages move execution with proper startup/active/recovery frames, handles invincibility frames for uppercut-type moves, and balances damage/cooldown per move.
- **JSON Contract Extension:**
  ```json
  {
    "specialMoves": [
      {"id": "hadoken", "gesture": "swipe_right_tap", "startup": 12, "active": 4, "recovery": 20, "damage": 60, "projectile": true},
      {"id": "shoryuken", "gesture": "swipe_up_tap", "startup": 4, "active": 8, "recovery": 30, "damage": 120, "invincible": true}
    ],
    "gestureRecognition": {"tolerance": 30, "maxGestureTime": 0.5}
  }
  ```

---

### Feature 34: Super Combo Gauge (Kid-Simplified)
- **Source:** Street Fighter Alpha, SF4, SF5, SF6
- **Description:** A meter that fills as the player deals and receives damage. When full (or at partial levels), the player can execute a devastating Super Combo / Critical Art / Ultra move. SF6's Drive System adds multiple uses (Drive Impact, Drive Parry, Overdrive).
- **Kid UX:** Kid stamps a "Power Crystal" on their character. A colorful gauge fills below the health bar as they fight (yellow -> orange -> red -> flashing rainbow). When full, a big "SUPER!" badge pulses. Tapping it executes a spectacular cinematic super move. The gauge has 3 segments; each segment can power a different super level.
- **LLM Automation:** The LLM tracks gauge fill from damage dealt/received, validates super move availability (full gauge = Level 3 super, 2 segments = Level 2, etc.), handles cinematic freeze-frame on super activation, computes super damage with scaling (less damage when used in a combo), and manages invincibility/armor properties.
- **JSON Contract Extension:**
  ```json
  {
    "superGauge": {"maxSegments": 3, "currentSegments": 0, "fillRate": {"dealDamage": 0.1, "takeDamage": 0.15}},
    "superMoves": [
      {"id": "level_1_super", "cost": 1, "damage": 200, "cinematic": false},
      {"id": "level_3_super", "cost": 3, "damage": 450, "cinematic": true, "invincibleStartup": true}
    ]
  }
  ```

---

### Feature 35: Parry / Counter System
- **Source:** Street Fighter III: 3rd Strike (Parry), SF4 (Focus Attack), SF6 (Drive Parry)
- **Description:** A defensive technique where pressing forward (or down for low attacks) at the exact moment an attack connects negates all damage and opens the opponent for a counter. Perfect parry freezes the screen and guarantees a punish.
- **Kid UX:** Kid stamps a "Shield" icon on their character. A parry timing window appears when an enemy attacks: a shrinking circle converges on a sweet spot. Kid taps anywhere when the circle is smallest. Success = golden flash, enemy is stunned, free counter-attack. Failure = normal block or take damage. Visual and audio cues make timing clear.
- **LLM Automation:** The LLM detects incoming attack frames, displays the timing window (2-6 frame parry window depending on difficulty), validates timing on player tap, applies parry freeze effect on success, stuns attacker for punish window, and tracks parry success rate for scoring.
- **JSON Contract Extension:**
  ```json
  {
    "parrySystem": {
      "windowFrames": 4,
      "timingDisplay": "shrinking_circle",
      "successEffects": {"freeze": 0.5, "stunDuration": 2.0, "counterWindow": true},
      "types": ["high_parry", "low_parry"]
    }
  }
  ```

---

### Feature 36: Character Archetype System
- **Source:** Street Fighter series
- **Description:** Characters fit competitive archetypes: Zoner (keeps distance, fireballs), Grappler (slow but devastating command grabs), Rushdown (fast, applies constant pressure), Shoto (balanced with fireball/uppercut), Turtle (defensive, counter-attacks). Each archetype teaches different skills.
- **Kid UX:** Kid stamps a "Fighter Select" portal. 6 big character stamps appear with descriptive icons: "Fireball Fighter" (zoner), "Strong Grabber" (grappler), "Speedy Attacker" (rushdown), "All-Rounder" (shoto), "Tough Defender" (turtle), "Tricky Teleporter" (mix-up). Tapping a character shows a short animated preview of their playstyle.
- **LLM Automation:** The LLM auto-configures character stats (walk speed, jump arc, health, damage) and available movesets based on archetype, provides AI behavior patterns that match the archetype (zoner AI keeps distance, grappler AI approaches), and suggests counter-strategies.
- **JSON Contract Extension:**
  ```json
    {
    "archetypes": [
      {"id": "zoner", "speed": "slow", "range": "long", "keyMechanic": "projectile", "examples": ["guile", "dhalsim"]},
      {"id": "grappler", "speed": "slow", "range": "short", "keyMechanic": "command_grab", "examples": ["zangief"]},
      {"id": "rushdown", "speed": "fast", "range": "short", "keyMechanic": "frame_trap", "examples": ["cammy", "ibuki"]}
    ],
    "characterStats": {"walkSpeed": 100, "jumpHeight": 150, "health": 1000, "stunThreshold": 500}
  }
  ```

---

## Section 6: OKAMI

---

### Feature 37: Celestial Brush Drawing
- **Source:** Okami
- **Description:** The player can pause time and draw on the screen to perform miracles. Core techniques include: Power Slash (straight line through enemy = instant damage), Rejuvenation (trace broken object = repair), Bloom (circle around dead plant = revive), Waterspout (line from water source to target), Cherry Bomb (draw circle = explosive), Galestorm (draw spiral = wind), Veil of Mist (draw horizontal line = slow time).
- **Kid UX:** Kid stamps a "Brush Goddess" item. During gameplay, holding a "Brush" button freezes time and turns the screen into a parchment texture. The kid draws simple strokes: straight line = slash attack, circle = revive plants/bloom flowers, filled circle = bomb, horizontal line = wind, vertical line = water spout. Each stroke triggers its miracle with spectacular ink-wash animation.
- **LLM Automation:** The LLM implements stroke recognition (straight line vs. circle vs. spiral), detects what the stroke intersects with (enemies, broken objects, water sources), executes the corresponding effect with appropriate particles, manages ink meter consumption, and tracks which brush techniques have been unlocked.
- **JSON Contract Extension:**
  ```json
  {
    "brushTechniques": [
      {"id": "power_slash", "stroke": "straight_line", "cost": 1, "effect": "damage_line_intersect", "damage": 30},
      {"id": "bloom", "stroke": "circle", "cost": 1, "effect": "revive_plant", "praiseReward": 10},
      {"id": "cherry_bomb", "stroke": "filled_circle", "cost": 3, "effect": "explosion", "damage": 80, "radius": 100},
      {"id": "galestorm", "stroke": "spiral", "cost": 2, "effect": "wind_push", "force": 500},
      {"id": "waterspout", "stroke": "vertical_line", "cost": 2, "effect": "water_geyser", "height": 300}
    ],
    "inkMeter": {"max": 10, "current": 10, "regenRate": 1},
    "strokeRecognition": {"tolerance": 20, "minStrokeLength": 30}
  }
  ```

---

### Feature 38: Praise / Power-Up Orb Collection
- **Source:** Okami
- **Description:** Restoring nature (blooming flowers, feeding animals, reviving trees) earns Praise (glowing orbs). Collecting enough Praise allows the player to upgrade their attributes: more health (Solar Energy), more ink pots, more purse size, and stronger attacks.
- **Kid UX:** Kid stamps "Wilted Flower" clusters throughout their level. When the player uses the Bloom brush technique on them, flowers burst open and golden Praise orbs float out, magnetizing toward the player with a satisfying chime. Collecting enough orbs makes a big "LEVEL UP!" banner appear. A simple screen shows 4 big icons: Heart (more health), Ink Bottle (more brush uses), Bag (more inventory), Star (stronger attack). Kid taps one to upgrade.
- **LLM Automation:** The LLM tracks Praise total, manages upgrade thresholds (each upgrade costs progressively more), applies attribute increases on upgrade selection, spawns Praise orbs from bloom/restoration events, and handles the orb magnetization physics.
- **JSON Contract Extension:**
  ```json
  {
    "praiseSystem": {
      "currentPraise": 0,
      "upgradeCosts": {"health": [100, 300, 600, 1000], "ink": [150, 400, 700], "purse": [200, 500], "attack": [500, 1000]},
      "praiseSources": {"bloom_flower": 5, "feed_animal": 20, "revive_tree": 30, "restore_landmark": 100}
    }
  }
  ```

---

### Feature 39: Animal Following & Feeding
- **Source:** Okami
- **Description:** Various animals roam the world. Feeding them (with specific food types: seeds for birds, meat for dogs/cats, fish for aquatic creatures) causes them to permanently follow the player, providing minor stat boosts and Praise rewards.
- **Kid UX:** Kid stamps animals throughout the level: dogs, cats, rabbits, birds, monkeys. Each animal has a thought bubble showing what food it wants (bone, carrot, seed). Kid stamps "Food Bag" items. When the player gives the right food, hearts appear above the animal and it starts following the player, occasionally finding hidden items.
- **LLM Automation:** The LLM manages animal AI (follow at distance, play idle animations, occasionally dig at hidden spots), tracks which animals have been fed/follow, applies follower bonuses (e.g., dog follower = +5% attack, cat follower = +10% luck), and handles animal dig spots for treasure.
- **JSON Contract Extension:**
  ```json
  {
    "animals": [
      {"id": "dog", "preferredFood": "meat", "followBonus": {"STR": 1}, "special": "dig_for_treasure"},
      {"id": "cat", "preferredFood": "fish", "followBonus": {"LCK": 2}, "special": "find_secret_path"},
      {"id": "rabbit", "preferredFood": "carrot", "followBonus": {"speed": 1.1}, "special": "none"}
    ],
    "followerSlots": {"max": 3, "current": []}
  }
  ```

---

### Feature 40: Constellation Unlocking
- **Source:** Okami
- **Description:** Scattered throughout the world are constellation patterns made of glowing dots. Using the Celestial Brush to connect the dots in the correct order summons a Brush God (celestial spirit) that teaches a new brush technique or restores a major ability.
- **Kid UX:** Kid stamps a "Star Pattern" on the night sky background of their level. Glowing star dots appear. The kid draws lines connecting the stars in any order; when the constellation is complete, a majestic celestial creature materializes with an ink-wash animation and teaches a new brush power. Each constellation has a unique creature (dragon, phoenix, rabbit, dragonfly).
- **LLM Automation:** The LLM validates constellation line connections (proximity-based, auto-snaps to nearest star), detects completion (all stars connected in valid pattern), triggers the summon animation, unlocks the associated brush technique, and tracks completed constellations.
- **JSON Contract Extension:**
  ```json
  {
    "constellations": [
      {"id": "tachigami", "stars": [[100,50], [150,80], [200,50], [150,20]], "reward": "power_slash", "creature": "mouse_god"},
      {"id": "sakigami", "stars": [[300,100], [340,130], [320,170], [280,170], [260,130]], "reward": "bloom", "creature": "monkey_god"}
    ],
    "validation": {"autoSnap": true, "snapRadius": 30, "requireAllConnected": true}
  }
  ```

---

### Feature 41: Time of Day System
- **Source:** Okami
- **Description:** The game transitions between day and night. Certain events, enemies, and items only appear at specific times. Drawing a circle in the sky (Sunrise technique) changes night to day; drawing a crescent changes day to night.
- **Kid UX:** Kid stamps a "Sun/Moon Dial" in their level. The background tint shifts between bright day colors and dark blue night colors. Certain enemy stamps have a sun icon (day only) or moon icon (night only). Kid stamps these enemies and they only appear during their time. A big sun/moon button in the HUD lets the player trigger time changes if they have the brush technique.
- **LLM Automation:** The LLM manages the day/night cycle timer (real-time or triggered), controls background tint/filter transitions, shows/hides time-specific entities, modifies enemy behavior (some sleep at night), and handles the brush-triggered time change.
- **JSON Contract Extension:**
  ```json
  {
    "timeOfDay": {"cycleDuration": 300, "transitionTime": 10, "current": "day"},
    "timeSpecificEntities": [
      {"id": "night_ghost", "appearAt": "night", "disappearAt": "day"},
      {"id": "sun_sprite", "appearAt": "day", "disappearAt": "night"}
    ],
    "timeChange": {"brushTechnique": "sunrise/crescent", "instant": true}
  }
  ```

---

### Feature 42: Digging for Treasures
- **Source:** Okami
- **Description:** The player can dig at soft ground patches to uncover hidden items, money, or secrets. Dig spots are subtle visual cues (slightly disturbed earth) that observant players notice.
- **Kid UX:** Kid stamps "Soft Ground" patches onto walkable areas. These appear as slightly raised dirt mounds. When the player stands on one and uses the Dig action, they burrow into the ground and pop up with a treasure item (random from the spot's loot table). Sparkle particles indicate diggable spots when the player is near.
- **LLM Automation:** The LLM handles dig spot detection (player proximity + action input), randomly selects from the spot's loot table, plays the burrow-and-emerge animation, spawns the item, and tracks which dig spots have been used (one-time vs. respawning).
- **JSON Contract Extension:**
  ```json
  {
    "digSpots": [
      {"id": "spot_1", "lootTable": ["coin", "coin", "coin", "rare_gem"], "respawn": false, "visualCue": "dirt_mound"}
    ]
  }
  ```

---

## Section 7: RESIDENT EVIL

---

### Feature 43: Grid Inventory Management
- **Source:** Resident Evil series
- **Description:** Items take up specific shapes on a limited-size grid (tetris-style). The player must rotate and arrange items to fit everything they want to carry. Key items, weapons, ammo, and healing items all occupy different grid shapes.
- **Kid UX:** Kid stamps an "Inventory Box" item. A grid pops up (6x4 squares). Each item stamp the kid collects becomes a colorful block of specific shape: potion = 1x1, gun = 2x1, shotgun = L-shape, key = 1x1. Kid drags and rotates items to fit them in the grid. Items that don't fit must be left behind. An "Auto-Arrange" button helps organize.
- **LLM Automation:** The LLM validates item placement (no overlaps, within grid bounds), handles rotation, enforces capacity limits, manages the auto-arrange algorithm, and tracks which items are in the inventory box vs. equipped.
- **JSON Contract Extension:**
  ```json
  {
    "inventoryGrid": {"width": 6, "height": 4},
    "itemShapes": [
      {"id": "handgun", "shape": [[1,1]], "rotatable": true},
      {"id": "shotgun", "shape": [[1,1],[1,0]], "rotatable": true},
      {"id": "green_herb", "shape": [[1]], "rotatable": false}
    ]
  }
  ```

---

### Feature 44: Herb Combining System
- **Source:** Resident Evil series
- **Description:** Three herb colors create different healing effects: Green Herb = heal; Green + Green = full heal; Green + Red = full heal + max boost; Green + Blue = heal + poison cure; Green + Red + Blue = full heal + max boost + poison cure + damage reduction.
- **Kid UX:** Kid stamps "Herb" items: green leaf, red flower, blue berry. In the inventory, dragging one herb onto another of a different color triggers a combination animation (sparkles mixing). The result appears as a new item: "Mixed Herb G+G" (big heal), "Mixed Herb G+R" (super heal), or "Rainbow Herb" (all effects). Simple color-coded result icons make effects clear.
- **LLM Automation:** The LLM maintains the herb combination recipe table, validates valid combinations, handles the combination animation, applies the correct healing values and status effects when used, and manages herb inventory updates.
- **JSON Contract Extension:**
  ```json
  {
    "herbRecipes": [
      {"ingredients": ["green", "green"], "result": "mixed_gg", "heal": 100, "cures": []},
      {"ingredients": ["green", "red"], "result": "mixed_gr", "heal": 999, "cures": [], "maxHpBoost": true},
      {"ingredients": ["green", "red", "blue"], "result": "mixed_grb", "heal": 999, "cures": ["poison"], "maxHpBoost": true, "defenseUp": true}
    ]
  }
  ```

---

### Feature 45: Safe Room System
- **Source:** Resident Evil series
- **Description:** Designated safe rooms where enemies cannot enter, players can save progress (via typewriter), heal, and manage inventory. Safe rooms have a distinctive calming music and visual theme (often contains an item box and a save point).
- **Kid UX:** Kid stamps a "Safe Room Zone" over an area of their level. The zone boundary glows soft blue. Enemies that touch the boundary bounce away (invisible wall). Inside, kid stamps a "Typewriter" (save point) and an "Item Box" (shared storage). The background music softens and a gentle heartbeat ambient plays.
- **LLM Automation:** The LLM creates an invisible collision boundary that repels enemy AI, auto-switches background music/ambience when the player enters, enables the save function at the typewriter, and manages the item box as shared inventory accessible from any safe room.
- **JSON Contract Extension:**
  ```json
  {
    "safeRooms": [{"id": "safe_1", "zone": {"x": 100, "y": 200, "w": 300, "h": 200}}],
    "safeRoomProperties": {
      "enemyBlocking": true,
      "musicChange": "safe_room_theme",
      "saveEnabled": true,
      "sharedStorage": "item_box"
    }
  }
  ```

---

### Feature 46: Key Item & Environmental Puzzles
- **Source:** Resident Evil series
- **Description:** Progression requires finding specific key items (emblem, crest, keycard, crank handle) and using them at matching environmental objects. Keys are consumed on use. Puzzles include: arranging symbols, pressing buttons in order, finding combinations in notes.
- **Kid UX:** Kid stamps a "Key Door" with a colored/shaped keyhole (red diamond, blue circle, gold star). Kid then stamps a matching "Key" item somewhere in the level. When the player finds the key and brings it to the door, the shapes snap together with a satisfying click and the door opens. For symbol puzzles, kid stamps 3 glowing buttons; tapping them in the right order opens the path.
- **LLM Automation:** The LLM validates key-door matching (shape/color), handles key consumption on use, manages puzzle state (which buttons pressed, in what order), checks solution correctness, and triggers open animations on success.
- **JSON Contract Extension:**
  ```json
  {
    "keyItems": [{"id": "red_diamond_key", "shape": "diamond", "color": "red", "consumable": true}],
    "keyDoors": [{"id": "door_a", "requiredKey": "red_diamond_key", "state": "locked"}],
    "puzzles": [{"id": "symbol_puzzle_1", "type": "button_sequence", "solution": [2,3,1], "reward": "chest_opens"}]
  }
  ```

---

## Section 8: PHOENIX WRIGHT

---

### Feature 47: Evidence Collection & Presentation
- **Source:** Phoenix Wright: Ace Attorney
- **Description:** The player investigates crime scenes to find evidence items (photos, documents, objects). During cross-examination, the player must present the correct evidence at the right statement to expose contradictions in witness testimony.
- **Kid UX:** Kid stamps "Evidence" items throughout their level: a "Photo" stamp, a "Document" stamp, a "Key Item" stamp. When the player touches evidence, it flies into an "Evidence Folder" (shown as a briefcase icon). During a "Talk" encounter with an NPC, speech bubbles appear. If the kid has placed a contradiction in the testimony, the player can tap the Evidence Folder and drag a piece of evidence onto the contradicting statement. A dramatic "OBJECTION!" animation plays on success.
- **LLM Automation:** The LLM manages evidence inventory, validates evidence-to-contradiction matching (only specific evidence exposes specific lies), tracks the contradiction flag state per testimony section, handles the objection sequence animation, and advances the story on successful presentations.
- **JSON Contract Extension:**
  ```json
  {
    "evidence": [{"id": "crime_photo", "type": "photo", "description": "Shows victim at 9PM"}],
    "testimonies": [{
      "witnessId": "witness_1",
      "statements": [
        {"text": "I saw the victim at 8PM", "contradiction": "crime_photo", "exposed": false}
      ]
    }],
    "presentation": {"requireMatch": true, "successAnimation": "objection", "failPenalty": 1}
  }
  ```

---

### Feature 48: Health Bar as Penalty System (Psyche-Lock Simplified)
- **Source:** Phoenix Wright: Ace Attorney
- **Description:** Instead of a traditional health bar, the player has a "Confidence" bar that depletes when they present wrong evidence or make mistakes in court. Running out of confidence means game over. In Justice for All, this replaces the 5-strike system.
- **Kid UX:** Kid stamps a "Judge" NPC in their level. A big golden "Confidence" bar appears at the top of the screen (represented by a row of glowing stars). Wrong answers cause stars to shatter and fall off. Correct answers restore a star. At 0 stars, the judge stamps their gavel and the player must retry from the last checkpoint. Visual feedback is dramatic but kid-friendly.
- **LLM Automation:** The LLM tracks confidence value (0-100 or star count), applies penalties for wrong evidence presentation, applies rewards for correct presentations, triggers the game-over gavel animation at 0, and manages checkpoint respawn.
- **JSON Contract Extension:**
  ```json
  {
    "penaltySystem": {
      "type": "confidence_bar",
      "max": 5,
      "current": 5,
      "wrongPenalty": 1,
      "correctReward": 0,
      "gameOverAtZero": true,
      "visual": "stars"
    }
  }
  ```

---

### Feature 49: Secret-Hiding Lock System
- **Source:** Phoenix Wright: Ace Attorney (Psyche-Lock system simplified)
- **Description:** When a character is hiding a secret, colored locks appear around them. Breaking the locks requires presenting specific evidence or profiles to prove the truth. More locks = deeper secret. Breaking all locks reveals the truth.
- **Kid UX:** Kid stamps an NPC with a "Has Secret" flag. When the player talks to this NPC, 1-5 colorful padlock icons appear around them. The player can drag evidence items from their folder onto the locks. Correct evidence shatters a lock with a glass-breaking animation and sound. All locks broken = the character tells their secret (new dialog, new evidence, or new area unlocked).
- **LLM Automation:** The LLM generates the appropriate number of locks based on secret depth, validates evidence-to-lock matching, triggers lock-break animations, reveals secret dialog when all locks break, and tracks which character secrets have been fully revealed.
- **JSON Contract Extension:**
  ```json
  {
    "secrets": [{
      "characterId": "npc_suspect",
      "lockCount": 3,
      "solutions": ["evidence_photo", "evidence_document", "profile_witness"],
      "revealReward": "new_dialog_branch",
      "broken": [false, false, false]
    }]
  }
  ```

---

## Section 9: CROSS-GAME SYSTEMS & META FEATURES

---

### Feature 50: Boss Medley Rush Mode
- **Source:** Mega Man (Boss Rush), Castlevania (Boss Rush), Street Fighter (Arcade Mode)
- **Description:** After completing the main game, a "Boss Rush" mode unlocks where the player fights all bosses back-to-back with limited healing between fights. A timer tracks speed. Leaderboards encourage replay.
- **Kid UX:** Kid stamps a "Boss Tower" portal in their level. Entering it opens a menu showing all boss stamps the kid has placed, with their icons in a vertical tower. Kid selects which bosses to include. During the rush, a big timer counts up, and the player faces each boss sequentially in an arena. Between fights, a single healing orb appears.
- **LLM Automation:** The LLM sequences boss encounters, manages health carry-over between fights, places the single inter-fight heal, tracks completion time, generates a "Victory Card" with stats, and manages leaderboard storage.
- **JSON Contract Extension:**
  ```json
  {
    "bossRush": {
      "availableBosses": ["boss_1", "boss_2", "boss_3"],
      "selectedBosses": [],
      "healBetween": true,
      "healAmount": 50,
      "timer": true,
      "leaderboard": {"track": ["time", "damageTaken", "healsUsed"]}
    }
  }
  ```

---

### Feature 51: Merchant / Shop System
- **Source:** Castlevania (Librarian), Monster Hunter (Item Shop), Okami (Merchant), Resident Evil (Item Box merchant in RE4)
- **Description:** An NPC merchant who buys and sells items. The player can sell collected treasures/gems for currency, then purchase healing items, equipment, or key items. Shop inventory can expand as the player progresses.
- **Kid UX:** Kid stamps a "Shopkeeper" NPC onto the canvas. Tapping the shopkeeper opens a shop screen split into "Buy" and "Sell". Items appear as big stamps with prices. Kid drags items from their inventory to the "Sell" side (gems, duplicates) to get gold coins. Then drags desired items from the "Buy" side to their inventory. Gold coin counter updates in real-time.
- **LLM Automation:** The LLM manages the player's currency balance, validates transactions (sufficient funds, inventory space), handles sell values (typically 25-50% of buy price), manages shop inventory unlocking (new items appear after certain progression flags), and tracks merchant relationship (discounts for repeat business).
- **JSON Contract Extension:**
  ```json
  {
    "merchant": {
      "inventory": [{"itemId": "potion", "buyPrice": 50, "sellPrice": 20, "unlockCondition": "default"}],
      "currency": "gold",
      "playerBalance": 0,
      "discountRate": 0.0,
      "refreshOnVisit": false
    }
  }
  ```

---

### Feature 52: Quest Board from NPCs
- **Source:** Castlevania: Portrait of Ruin / Order of Ecclesia (villager quests), Monster Hunter (Quest Board)
- **Description:** NPCs offer optional quests with specific objectives: defeat X enemies, find an item, defeat a specific boss, bloom all flowers in an area. Completing quests rewards unique items, Praise, or currency.
- **Kid UX:** Kid stamps a "Quest Board" (big wooden sign with papers pinned to it) or a "Villager" NPC with a "!" bubble. Tapping it shows 3 quest cards with fun icons and simple text: "Defeat 5 Bats!" (bat icon x5), "Find the Red Gem!" (gem icon). Kid can accept a quest by tapping it. A quest tracker appears at the edge of the screen showing progress. Completing a quest auto-triggers a reward burst.
- **LLM Automation:** The LLM tracks quest progress (kill counters, item possession checks, area exploration flags), validates completion conditions, triggers reward distribution, manages quest state (available -> active -> completed -> turned in), and generates new quests procedurally.
- **JSON Contract Extension:**
  ```json
  {
    "quests": [{
      "id": "quest_1",
      "giver": "villager_old_man",
      "objective": {"type": "defeat", "target": "bat", "count": 5},
      "reward": [{"itemId": "red_gem", "quantity": 1}],
      "state": "available"
    }]
  }
  ```

---

### Feature 53: Multiple Ending System
- **Source:** Castlevania (multiple endings based on relic collection), Mega Man X (Zero's fate), Phoenix Wright (case outcomes)
- **Description:** The game has multiple endings based on player choices, completion percentage, or specific actions taken. A "True Ending" requires 100% completion or specific conditions. Different endings provide different final scenes and rewards.
- **Kid UX:** Kid stamps "Ending Trigger" items in their level with condition labels: "Good Ending" (requires all relics), "Bad Ending" (defeat final boss without key items), "Secret Ending" (requires all quests complete). The kid can view their level's ending tree as a branching diagram. Each ending stamp shows a small preview thumbnail.
- **LLM Automation:** The LLM evaluates ending conditions at the endgame trigger point, selects the appropriate ending based on flags (collected relics, completion percentage, choices made), plays the corresponding ending sequence, and unlocks new game+ or bonus content if true ending achieved.
- **JSON Contract Extension:**
  ```json
  {
    "endings": [
      {"id": "bad_ending", "conditions": [{"type": "missing_relic", "relicId": "heart_of_vlad"}], "unlocks": []},
      {"id": "good_ending", "conditions": [{"type": "has_all_relics", "count": 5}], "unlocks": ["new_game_plus"]},
      {"id": "true_ending", "conditions": [{"type": "completion", "percent": 100}, {"type": "all_quests"}], "unlocks": ["new_game_plus", "secret_character"]}
    ]
  }
  ```

---

### Feature 54: Combo Chain Counter
- **Source:** Street Fighter (combo counter), Monster Hunter (hit counter), Devil May Cry (style ranking)
- **Description:** Hitting enemies in quick succession without taking damage builds a combo counter displayed prominently on screen. Higher combos award more points, better drops, or style ratings (D -> C -> B -> A -> S -> SS -> SSS).
- **Kid UX:** A big combo number appears in the corner when the player hits enemies rapidly. Numbers count up with each hit. After 5 hits: "NICE!" appears. 10 hits: "GREAT!" 20 hits: "AWESOME!" 50+ hits: "UNBELIEVABLE!" with rainbow text. Taking damage or waiting too long resets the counter with a dramatic fade.
- **LLM Automation:** The LLM tracks the combo counter (increments on enemy hit, resets on player hurt or timeout), manages the combo timer (resets after 2 seconds without a hit), determines rank thresholds, applies combo-based score multipliers, and triggers rank announcement events.
- **JSON Contract Extension:**
  ```json
  {
    "comboSystem": {
      "counter": 0,
      "timeout": 2.0,
      "ranks": [
        {"threshold": 5, "rank": "D", "multiplier": 1.0},
        {"threshold": 10, "rank": "C", "multiplier": 1.5},
        {"threshold": 20, "rank": "A", "multiplier": 2.0},
        {"threshold": 50, "rank": "S", "multiplier": 3.0}
      ]
    }
  }
  ```

---

### Feature 55: Stamp-Driven Environmental Storytelling
- **Source:** All games (environmental storytelling)
- **Description:** The level itself tells a story through visual details: bloodstains, scattered notes, broken furniture, mysterious symbols. These details don't require explicit narration but create atmosphere and hint at secrets.
- **Kid UX:** Kid stamps "Story Details" throughout their level: a broken chair, a bloodstain (kid-friendly version: a spilled potion), a mysterious note with scribbles, a wanted poster, paw prints leading somewhere. Each detail stamp has an optional "hint" popup the kid can type. When players examine these details in-game, a thought bubble appears with the kid's hint text.
- **LLM Automation:** The LLM categorizes story detail stamps by type, auto-generates contextual thought bubbles if the kid didn't write custom text, tracks which story details the player has examined, and uses examined details to inform hint dialog from codec/merchant NPCs.
- **JSON Contract Extension:**
  ```json
  {
    "storyDetails": [
      {"id": "detail_1", "type": "broken_furniture", "position": [100, 200], "customText": "Something violent happened here...", "examined": false}
    ],
    "examinationTracking": true,
    "autoGenerateHints": true
  }
  ```

---

## Summary: Feature Count by Source Game

| Game | Feature Count | Feature IDs |
|------|-------------|-------------|
| Castlevania: SOTN | 9 | 1-9 |
| Castlevania: Aria/Dawn/Ecclesia/Portrait | 3 | 10-12 |
| Metal Gear Solid | 6 | 13-18 |
| Mega Man / Mega Man X | 6 | 19-23 |
| Mega Man Battle Network | 2 | 24-25 |
| Monster Hunter | 7 | 26-32 |
| Street Fighter | 4 | 33-36 |
| Okami | 6 | 37-42 |
| Resident Evil | 4 | 43-46 |
| Phoenix Wright | 3 | 47-49 |
| Cross-Game Meta | 7 | 50-55 |
| **TOTAL** | **55** | |

---

## Design Principles Summary

1. **Every interaction is a stamp, tap, or drag.** No typing required, no complex menus, no multi-step sequences.
2. **Visual feedback is immediate and exaggerated.** Particles, screen shakes, color flashes, big text popups.
3. **The LLM handles all math, validation, and AI.** Kids place stamps; the system makes it work.
4. **Progression is visible.** Stats, equipment, and unlocks all have visual representations that change the player's appearance.
5. **Failure is gentle.** Wrong answers in puzzle systems give feedback but don't hard-lock progress.
6. **Complex systems are surfaced as simple patterns.** Elemental wheels, weakness chains, and recipe combinations all use visual matching rather than memory.

---

*Research compiled from Castlevania Wiki, Mega Man Knowledge Base, Monster Hunter Wiki, Okami Wiki, Street Fighter Wiki, Resident Evil Wiki, and Ace Attorney Wiki. Feature designs adapted for KidGameMaker stamp-based, zero-code paradigm.*
