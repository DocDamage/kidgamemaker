# KidGameMaker Feature Research: FromSoftware & Critically Acclaimed Indie Platformers

## Research Overview

This document extracts 60+ specific, actionable feature ideas from 10 landmark games for integration into **KidGameMaker** -- a zero-code, stamp-based 2D platformer game creation suite targeting ages 5+. All features are analyzed through the lens of: (1) what makes the original compelling, (2) how a 5-year-old can interact with it via stamps/taps, and (3) what the backend LLM automates invisibly.

---

## SECTION 1: FromSoftware Games (Dark Souls 1/2/3, Elden Ring, Bloodborne)

---

### Feature 1: Rest Point Respawn Loop

- **Feature Name:** `RestPointRespawnLoop`
- **Source:** Dark Souls 1, 2, 3 / Elden Ring (Bonfires / Sites of Grace)
- **Description:** A checkpoint system where touching a glowing rest point fully heals the player but also respawns all defeated enemies. Creates a risk/reward tension around whether to push forward or return to safety. The bonfire becomes a lighthouse of safety in hostile territory.
- **Kid UX:** Child stamps a "Campfire Stamp" (orange/yellow flame icon) onto the canvas. Tapping it opens a bubble menu: "Set as Start Here." The LLM automatically wires it as the player's respawn point. Optionally, child can stamp a "Zzz" icon near it to show enemies sleep there. Single-tap to set, drag to position.
- **LLM Automation:** Handles respawn coordinate storage, enemy respawn table reset on rest, heal-to-full trigger, camera snap on respawn, death-screen bypass (instant respawn for kids), and auto-saves player progress at the rest point. Prevents placement inside kill zones or mid-air.
- **JSON Contract Extension:**
  ```json
  {
    "restPoints": [{
      "id": "uuid",
      "x": 1200, "y": 400,
      "healOnTouch": true,
      "respawnEnemies": true,
      "cameraTarget": {"x": 1200, "y": 380},
      "discovered": false,
      "linkedShortcutIds": [],
      "ambientParticles": "embers"
    }]
  }
  ```

---

### Feature 2: Collection Currency Loss on Defeat

- **Feature Name:** `CurrencyDropOnDefeat`
- **Source:** Dark Souls (Souls), Bloodborne (Blood Echoes), Hollow Knight (Geo)
- **Description:** The player collects a currency from defeated enemies and hidden pickups. On defeat, all collected currency is dropped at the death location as a glowing orb. The player has one life (or a timer) to return to that spot and reclaim it. Dying again permanently loses the first orb. This creates palpable tension without being punishing for kids.
- **Kid UX:** Child stamps a "Sparkle Coin" stamp on enemies or hidden spots. Defeated enemies automatically drop coin particles. If the hero falls, a big floating coin appears where they fell with a pulsing arrow pointing to it. The child can stamp a "Treasure Bag" on any enemy to mark it as a coin-carrier. Visual-only, no complex UI.
- **LLM Automation:** Tracks per-session currency total, spawns pickup entity at death coordinates, handles collision detection for reclamation, manages the "one chance" rule, auto-adjusts drop amount based on child's level (never drops below 0), and fades out permanently lost currency with a gentle poof effect rather than a punishing message.
- **JSON Contract Extension:**
  ```json
  {
    "currencySystem": {
      "currencyName": "Sparkles",
      "current": 150,
      "dropped": {
        "amount": 75,
        "x": 2400, "y": 300,
        "reclaimable": true,
        "despawnTimer": 120
      },
      "sources": [{"type": "enemy_drop", "baseAmount": 10, "multiplier": 1.0}]
    }
  }
  ```

---

### Feature 3: Illusory Secret Walls

- **Feature Name:** `IllusoryWall`
- **Source:** Dark Souls 1, 2, 3 (illusory walls hit to reveal)
- **Description:** Seemingly normal wall tiles that disappear or slide away when the player attacks/rolls into them, revealing hidden passages, treasure rooms, or shortcuts. Often subtly hinted at by messages left by other players or slightly different visual cues.
- **Kid UX:** Child stamps a "Secret Wall" stamp (looks like a normal wall with a tiny sparkle) onto any wall tile. The LLM auto-hides its special nature. When the hero bumps it, it shimmers and fades away. The child can stamp a "Question Mark" hint nearby as a subtle clue. Single-tap stamp placement.
- **LLM Automation:** Renders wall identically to normal walls, handles collision detection for "bump" trigger, plays dissolve/shimmer animation on reveal, toggles collision layer off, reveals hidden room geometry behind, and can auto-generate a small treasure reward behind the wall based on level context.
- **JSON Contract Extension:**
  ```json
  {
    "secretWalls": [{
      "id": "uuid",
      "tileX": 45, "tileY": 12,
      "trigger": "bump",
      "revealAnimation": "shimmer_dissolve",
      "hintStampId": "uuid_or_null",
      "hiddenBehind": ["coin_x10", "shortcut_passage"],
      "reused": false
    }]
  }
  ```

---

### Feature 4: Shortcut Opening

- ** Feature Name:** `ShortcutUnlock`
- **Source:** Dark Souls 1 (famous elevator from Firelink to Parish), all FromSoftware games
- **Description:** A one-way or locked passage that, once opened from the far side, creates a permanent fast connection between two distant areas. The player fights through a dangerous area, unlocks the shortcut (often an elevator, door, or collapsing ladder), and then future traversals can bypass the danger. Creates a profound sense of progression and territory conquered.
- **Kid UX:** Child stamps a "Blocked Door" stamp at one end and an "Unlock Lever" stamp at the other end. Tapping the lever stamp sets it as the unlock trigger. A visual dotted line connects them in edit mode (hidden in play). When the hero touches the lever, a "Kaboom!" particle plays and the door opens permanently.
- **LLM Automation:** Generates the connecting geometry (elevator shaft, tunnel, ladder), wires the lever-to-door state toggle, saves the shortcut as permanently unlocked in session state, auto-adjusts enemy respawns when using the shortcut (skips respawned enemies), and plays a satisfying fanfare on first unlock.
- **JSON Contract Extension:**
  ```json
  {
    "shortcuts": [{
      "id": "uuid",
      "entryPoint": {"x": 800, "y": 300, "type": "blocked_door"},
      "exitPoint": {"x": 3500, "y": 200, "type": "open_passage"},
      "trigger": {"type": "lever", "x": 3400, "y": 200},
      "state": "locked",
      "unlockAnimation": "gate_raise",
      "permanent": true
    }]
  }
  ```

---

### Feature 5: Boss Fog Gate

- **Feature Name:** `BossFogGate`
- **Source:** Dark Souls 1, 2, 3 / Elden Ring
- **Description:** A glowing wall of mist/energy that blocks the entrance to a boss arena. Walking into it triggers a "Enter the mist?" confirmation (or auto-enters), then plays a dramatic entry animation. Once entered, the player cannot retreat until the boss is defeated or the player dies. The fog gate becomes a psychological barrier signifying a major challenge.
- **Kid UX:** Child stamps a "Sparkly Door" stamp (swirling purple/white particles) at a corridor entrance. Tapping it opens a bubble: "Boss Room?" with a crown icon. The LLM auto-generates an arena platform behind it. In play, walking into it plays a "whoosh" and the hero appears in the arena. A simple crown icon appears at the top.
- **LLM Automation:** Generates enclosed arena geometry behind the fog gate, auto-places the stamped boss enemy inside, seals the exit until boss HP reaches 0, triggers boss intro animation, locks camera to arena bounds, plays victory fanfare and reopens gate on boss defeat, and auto-saves pre-boss state for respawn.
- **JSON Contract Extension:**
  ```json
  {
    "fogGates": [{
      "id": "uuid",
      "position": {"x": 2000, "y": 400},
      "bossId": "boss_entity_uuid",
      "arenaBounds": {"x1": 2100, "x2": 3000, "y1": 300, "y2": 500},
      "sealed": true,
      "entered": false,
      "victoryState": "pending",
      "introAnimation": "boss_gate_enter",
      "exitUnlockedOn": "boss_defeat"
    }]
  }
  ```

---

### Feature 6: NPC Questline Stamps

- **Feature Name:** `NPCQuestline`
- **Source:** Dark Souls series (Solaire, Siegmeyer, Ranni), Elden Ring (Ranni's entire quest)
- **Description:** An NPC that appears in specific locations with dialogue that progresses based on player actions -- finding items, defeating bosses, or reaching new areas. NPCs move between rest points or landmarks. Some questlines branch based on choices. Rewards unique items or unlock areas on completion.
- **Kid UX:** Child stamps an "NPC Stamp" (cartoon character with speech bubble). Tapping it opens a dialogue composer: child types or speaks what the NPC says, and stamps an "Item Gift" to give. The child stamps numbered "Location Stamps" (1, 2, 3) showing where the NPC moves. Single-tap to talk in play mode.
- **LLM Automation:** Manages quest state machine (not started -> active -> progressed -> complete), triggers NPC movement between waypoints on key events, auto-generates dialogue trees, handles branching logic, manages inventory rewards, saves quest progress across sessions, and auto-generates simple portrait art for the NPC.
- **JSON Contract Extension:**
  ```json
  {
    "npcs": [{
      "id": "uuid",
      "name": "Blinky the Ghost",
      "locations": [
        {"stage": 0, "x": 400, "y": 300, "dialogue": "Have you seen my hat?"},
        {"stage": 1, "x": 1500, "y": 500, "dialogue": "You found it! Here's a Super Jump!"}
      ],
      "questTrigger": {"type": "item_collected", "itemId": "ghost_hat"},
      "reward": {"type": "ability_unlock", "ability": "super_jump"},
      "currentStage": 0,
      "portraitAutoGen": true
    }]
  }
  ```

---

### Feature 7: Flask Healing System

- **Feature Name:** `LimitedFlaskHeal`
- **Source:** Dark Souls (Estus Flask), Elden Ring (Flask of Crimson Tears)
- **Description:** A healing item with a fixed number of uses per rest. Drinking the flask restores a portion of HP but consumes one charge. Charges are only replenished by resting at a checkpoint. This forces strategic decisions -- chug early and risk having none for the boss, or conserve and risk dying now.
- **Kid UX:** Child stamps a "Potion Bottle" stamp onto the HUD area (or auto-placed by LLM). Tapping it sets how many charges (1-5 via simple number bubbles). In play, a "Drink" button appears in the corner with a bottle icon and charge count (3/3). Single-tap to drink. Visual glug-glug animation.
- **LLM Automation:** Tracks charges per rest cycle, handles heal amount calculation, prevents overhealing, plays drink animation + heal VFX, replenishes charges on rest point touch, auto-balances heal amount based on total player HP (e.g., 50% per flask), and shows floating +HP numbers.
- **JSON Contract Extension:**
  ```json
  {
    "healingFlask": {
      "maxCharges": 3,
      "currentCharges": 3,
      "healAmount": 50,
      "healType": "percent_of_max_hp",
      "replenishOn": "rest_point_touch",
      "useAnimation": "drink_potion",
      "cooldownSeconds": 1.5,
      "autoReplenishOnDeath": true
    }
  }
  ```

---

### Feature 8: Weapon/Ability Upgrade Tiers

- **Feature Name:** `TieredUpgradeSystem`
- **Source:** Dark Souls (Titanite Shards -> Large Shards -> Chunks -> Slabs), Hollow Knight (Nail upgrades)
- **Description:** Equipment improves through discrete tiers using collected materials. Each tier increases damage by a meaningful amount and may change visual appearance. Higher tiers require rarer materials found in harder areas. Creates long-term progression goals.
- **Kid UX:** Child stamps an "Upgrade Anvil" stamp (cartoon anvil with sparkles). Tapping it opens a tier picker: 1-5 stars. The LLM auto-generates the upgrade visual progression. Child stamps "Material Tokens" (colored gems) on the canvas -- these become collectible pickups. In play, touching the anvil with enough tokens upgrades the hero's weapon visually.
- **LLM Automation:** Manages material inventory, calculates upgrade eligibility, applies stat increases per tier, changes weapon sprite/visuals on upgrade, plays satisfying upgrade animation (sparkles + power-up sound), auto-balances material spawn rates per area, and persists upgrades across sessions.
- **JSON Contract Extension:**
  ```json
  {
    "upgradeSystem": {
      "type": "weapon",
      "tiers": [
        {"tier": 1, "damage": 10, "materialsNeeded": {"red_gem": 3}, "visual": "wooden_sword"},
        {"tier": 2, "damage": 18, "materialsNeeded": {"red_gem": 5, "blue_gem": 2}, "visual": "iron_sword"},
        {"tier": 3, "damage": 30, "materialsNeeded": {"blue_gem": 5, "gold_gem": 1}, "visual": "gold_sword"}
      ],
      "currentTier": 1,
      "materialsInventory": {"red_gem": 0, "blue_gem": 0, "gold_gem": 0}
    }
  }
  ```

---

### Feature 9: Parry/Counter Window

- **Feature Name:** `TimedParry`
- **Source:** Dark Souls (parry with shield), Bloodborne (gun parry), Dead Cells
- **Description:** Pressing the block button at the exact moment an enemy attack connects triggers a parry -- the attack is nullified, the enemy is staggered, and the player gets a free critical hit window. The timing window is tight (usually 2-6 frames), creating a high-skill defensive option that feels incredible to land.
- **Kid UX:** Child stamps a "Bounce Shield" stamp on the hero or as a pickup. In play, a "Block" button appears. When an enemy attacks, a quick spark appears -- tapping Block within the spark window triggers a "POW!" parry that stuns the enemy. Visual cue: enemy flashes yellow just before hitting. Very forgiving window for kids (0.5 seconds).
- **LLM Automation:** Detects incoming attack collision frames, shows telegraphing flash, measures input timing within parry window, nullifies damage on successful parry, triggers enemy stun state, opens critical hit opportunity window, plays satisfying counter VFX, and auto-adjusts parry window size based on child's age/performance.
- **JSON Contract Extension:**
  ```json
  {
    "parrySystem": {
      "enabled": true,
      "windowFrames": 15,
      "visualTelegraph": "yellow_flash",
      "onSuccess": {
        "nullifyDamage": true,
        "enemyStunDuration": 2.0,
        "criticalWindowDuration": 3.0,
        "damageMultiplier": 3.0,
        "vfx": "star_burst_parry"
      },
      "autoAdjustWindow": true
    }
  }
  ```

---

### Feature 10: New Game Plus Cycles

- **Feature Name:** `NewGamePlus`
- **Source:** Dark Souls 1, 2, 3 (NG+), Dead Cells (infinite scaling)
- **Description:** After completing the game, the player can start over while retaining all levels, equipment, and abilities. Enemies have increased HP and damage, new item placements appear, and sometimes new content unlocks. The game becomes a personal scaling challenge.
- **Kid UX:** Child stamps a "Plus Crown" stamp anywhere (or auto-placed by LLM on game completion). After finishing, a big "Play Again +" button appears. The LLM auto-increases enemy sizes (they get slightly bigger each cycle) and changes their colors. Child can stamp "New Gift" stamps that only appear in NG+. Single-tap to begin NG+.
- **LLM Automation:** Persists player inventory/abilities to new cycle, scales enemy HP/damage by +20% per NG+ level, changes enemy color palettes per cycle, places NG+-exclusive items, tracks highest NG+ level, maintains a "Platinum Crown" badge for each completed cycle, and auto-generates a victory lap ending sequence.
- **JSON Contract Extension:**
  ```json
  {
    "newGamePlus": {
      "enabled": true,
      "currentCycle": 0,
      "enemyHpMultiplier": 1.2,
      "enemyDamageMultiplier": 1.15,
      "retainInventory": true,
      "retainAbilities": true,
      "cycleExclusiveItems": [{"cycle": 1, "itemIds": ["rainbow_sword"]}],
      "cycleBadge": "gold_crown",
      "visualChanges": {"enemyScaleFactor": 1.1, "colorShiftHue": 30}
    }
  }
  ```

---

### Feature 11: Spirit Companion Summon

- **Feature Name:** `SpiritCompanion`
- **Source:** Elden Ring (Spirit Ashes -- wolves, jellyfish, mimic tear, skeletons)
- **Description:** Consumable items that summon AI-controlled ally spirits to fight alongside the player. Different spirits have different behaviors -- wolves swarm, jellyfish floats and poisons, skeletons revive after dying once. The summoned spirits distract enemies and deal damage until their duration expires or they die.
- **Kid UX:** Child stamps a "Friend Crystal" stamp on the canvas. Tapping it opens a companion picker: wolf, bird, ghost, or robot (cartoon stamps). The LLM auto-assigns AI behavior per type. In play, a "Call Friend" button summons the companion for a limited time. The companion auto-fights and follows. Visual: sparkle poof on summon.
- **LLM Automation:** Selects and applies AI behavior profile (melee/ranged/flying/reviving) per companion type, manages summon duration and cooldown, handles companion targeting and pathfinding, plays despawn animation on expiry, limits max active companions (typically 1-3), and auto-balances companion stats to be helpful but not carry.
- **JSON Contract Extension:**
  ```json
  {
    "spiritCompanions": [{
      "id": "uuid",
      "name": "Sparky Wolf",
      "type": "wolf",
      "aiProfile": "swarm_melee",
      "summonCost": {"item": "friend_crystal", "amount": 1},
      "duration": 30,
      "cooldown": 60,
      "stats": {"hp": 50, "damage": 8, "speed": 120},
      "revives": 0,
      "summonVfx": "crystal_burst",
      "despawnVfx": "sparkle_fade"
    }]
  }
  ```

---

### Feature 12: Custom Mix Buff Flask

- **Feature Name:** `CustomMixBuff`
- **Source:** Elden Ring (Flask of Wondrous Physick -- mix 2 crystal tears for custom buffs)
- **Description:** A special flask where the player combines two found "crystal tear" items before resting. Each tear provides a distinct timed buff: increased damage, faster movement, HP regen, damage negation, etc. Mixing two different tears creates a hybrid buff cocktail. The effect lasts for a fixed duration after consumption.
- **Kid UX:** Child stamps a "Mixing Bottle" stamp. Tapping it opens a shelf of "Magic Drop" stamps (red drop = power up, blue drop = speed up, green drop = heal over time). Child drags two drops into the bottle. In play, tapping the bottle drinks the mix. The hero glows the mixed colors. Lasts ~20 seconds.
- **LLM Automation:** Manages discovered tear inventory, calculates combined buff effects (additive or multiplicative based on tear compatibility), applies timed status effects on consumption, stacks visual aura per buff type, auto-balances buff magnitudes, and displays remaining buff time as a shrinking colored ring around the player.
- **JSON Contract Extension:**
  ```json
  {
    "customMixFlask": {
      "slotCount": 2,
      "currentMix": [
        {"tearId": "red_power", "effect": {"stat": "damage", "multiplier": 1.5}},
        {"tearId": "blue_speed", "effect": {"stat": "moveSpeed", "multiplier": 1.3}}
      ],
      "duration": 20,
      "cooldown": 45,
      "replenishOn": "rest_point_touch",
      "visualAura": "mixed_red_blue_glow",
      "timeRemainingRing": true
    }
  }
  ```

---

### Feature 13: Weapon Skill Swapping

- **Feature Name:** `WeaponSkillSwap`
- **Source:** Elden Ring (Ashes of War)
- **Description:** Special combat abilities can be attached to and detached from weapons freely. An "Ash of War" might add a spinning slash, a charge thrust, a parry, or a magic projectile. The player can experiment with different skill-weapon combinations to find synergies. Skills cost stamina/mana to use.
- **Kid UX:** Child stamps a "Skill Gem" stamp (star-shaped icon) and a "Sword" stamp. Dragging the gem onto the sword "socket" it. The skill gem glows on the sword. Tapping the skill button in play triggers the move. Child can drag different gems onto the same weapon to swap. Visual socket indicators appear on weapons.
- **LLM Automation:** Validates gem-weapon compatibility, applies skill parameters to weapon entity, generates appropriate animation and VFX for the skill combination, manages skill cooldown/cost, saves current skill loadout, auto-generates skill preview animation when socketed, and prevents incompatible combinations gracefully.
- **JSON Contract Extension:**
  ```json
  {
    "weaponSkills": {
      "weaponId": "iron_sword",
      "equippedSkill": {
        "skillId": "spin_slash",
        "name": "Spinny Slash",
        "animation": "player_spin_attack",
        "vfx": "swoosh_circle",
        "cooldown": 3.0,
        "cost": {"type": "stamina", "amount": 30},
        "damageMultiplier": 2.0,
        "hitboxShape": "circle_around_player"
      },
      "compatibleSkills": ["spin_slash", "dash_thrust", "ground_slam", "magic_wave"]
    }
  }
  ```

---

### Feature 14: Stealth Crouch System

- **Feature Name:** `StealthCrouch`
- **Source:** Elden Ring (crouching/stealth), Sekiro (stealth deathblows)
- **Description:** The player can crouch to reduce visibility, move slower, and sneak past enemies. Enemies have vision cones; entering the cone alerts them. Stealth kills from behind deal massive damage. Certain grass/foliage tiles enhance stealth when crouched in.
- **Kid UX:** Child stamps "Tall Grass" stamps (green tufts) on the ground. A "Sneak" button appears in play -- tapping it makes the hero crouch (smaller hitbox). Enemies show eye icons above their heads: closed (asleep), half-open (patrolling), open (alerted). Walking into tall grass while sneaking hides the hero completely. Simple and visual.
- **LLM Automation:** Calculates enemy vision cones based on facing direction, toggles stealth state on crouch input, renders semi-transparent hero when hidden in grass, manages enemy awareness states (unaware -> suspicious -> alerted), triggers stealth-critical damage on back attacks, auto-generates patrol paths for enemies, and draws vision cone debug hints in editor mode.
- **JSON Contract Extension:**
  ```json
  {
    "stealthSystem": {
      "crouchSpeedMultiplier": 0.5,
      "crouchHitboxScale": 0.6,
      "visionConeAngle": 90,
      "visionConeRange": 200,
      "stealthGrassIds": ["tall_grass", "bush", "leaf_pile"],
      "stealthDamageMultiplier": 5.0,
      "awarenessStates": ["unaware", "suspicious", "alerted"],
      "alertDelay": 1.5,
      "enemyEyeIcons": true
    }
  }
  ```

---

### Feature 15: Trick Weapon Transformation

- **Feature Name:** `TrickWeaponTransform`
- **Source:** Bloodborne (Threaded Cane, Ludwig's Holy Blade, Hunter Axe -- all switch between 2 modes)
- **Description:** Weapons can transform between two distinct forms mid-combat with a flourish animation. One form might be fast and short-ranged; the other slow but long-ranged. The transformation itself can deal damage. This doubles the player's moveset without needing to swap weapons.
- **Kid UX:** Child stamps a "Transformer Weapon" stamp (sword that extends into spear). The weapon has two visual states. A "Switch" button in play toggles between them with a cool flash animation. The LLM auto-generates both forms. Child can stamp "Mode A" and "Mode B" labels. Transform deals a small AOE knockback.
- **LLM Automation:** Manages two stat profiles per weapon (formA: fast/short, formB: slow/long), handles transform animation and timing, applies transform-AOE damage on switch, generates appropriate hitboxes per form, saves current form state, plays unique transform SFX, and ensures both forms have distinct visual silhouettes.
- **JSON Contract Extension:**
  ```json
  {
    "trickWeapon": {
      "weaponId": "threaded_cane",
      "currentForm": "compact",
      "forms": {
        "compact": {
          "damage": 12, "speed": 1.2, "range": 60, "hitbox": "short_arc",
          "visual": "short_cane", "animationSet": "fast_swings"
        },
        "extended": {
          "damage": 20, "speed": 0.8, "range": 140, "hitbox": "long_whip",
          "visual": "whip_form", "animationSet": "wide_sweeps"
        }
      },
      "transformDamage": 8,
      "transformHitbox": "small_burst",
      "transformVfx": "crack_flash",
      "transformTime": 0.6
    }
  }
  ```

---

### Feature 16: Rally Health Regain

- **Feature Name:** `RallyRegain`
- **Source:** Bloodborne (Rally system)
- **Description:** When the player takes damage, a portion of lost HP becomes "faded" (shown in orange on the health bar) instead of being permanently lost. Dealing damage to enemies within a short window (3-5 seconds) recovers the faded HP. This encourages aggressive play -- taking a hit then immediately fighting back to heal.
- **Kid UX:** When the hero gets hit, lost HP shows as yellow chunks on the health bar instead of disappearing. A small "clock" icon appears. Hitting enemies fills the yellow chunks back to red. Child doesn't need to stamp anything -- it's a global game mechanic. The LLM auto-enables it when any "Rally" stamp is placed.
- **LLM Automation:** Splits damage into "permanent loss" and "faded/rallyable" portions (e.g., 50/50 split), displays faded HP in distinct color, starts rally timer on damage taken, calculates HP recovery per damage dealt to enemies, gradually fades rallyable HP to permanent loss if timer expires, and shows rally amount as floating text on hits.
- **JSON Contract Extension:**
  ```json
  {
    "rallySystem": {
      "enabled": true,
      "rallyPercent": 0.5,
      "rallyWindowSeconds": 4.0,
      "rallyRatio": 0.3,
      "fadeColor": "#FFA500",
      "permanentColor": "#FF0000",
      "timerVisual": "shrinking_clock",
      "expireRate": "gradual",
      "rallyText": "+{amount} HP!"
    }
  }
  ```

---

### Feature 17: Procedural Mini-Dungeon Generator

- **Feature Name:** `ProceduralMiniDungeon`
- **Source:** Bloodborne (Chalice Dungeons)
- **Description:** Self-contained dungeon areas with procedurally generated layouts, enemy placements, and treasure. Each dungeon has a theme (forest, cave, sewer, castle) and a fixed depth (3-5 layers). The final layer always contains a boss. Players use found "chalice" items to generate new dungeons, creating infinite replayable content.
- **Kid UX:** Child stamps a "Dungeon Door" stamp (stone arch with question mark). Tapping it opens a theme picker: "Cave", "Castle", "Forest" (cartoon icons). The LLM auto-generates a 3-room dungeon with the chosen theme. Child stamps a "Boss Crown" in the last room. Each dungeon door generates a unique layout every time the game is played.
- **LLM Automation:** Generates room layouts using prefab tilesets for the selected theme, places enemy encounters using difficulty-appropriate spawn tables, distributes treasure pickups throughout, guarantees a rest point at mid-dungeon, generates a boss room with appropriate arena at the end, seeds the random generation so the same door always generates the same dungeon within a playthrough, and auto-balasures enemy density based on child player's death count.
- **JSON Contract Extension:**
  ```json
  {
    "proceduralDungeons": [{
      "doorId": "uuid",
      "theme": "cave",
      "depth": 3,
      "roomCount": 5,
      "seed": "auto_per_session",
      "enemyDensity": "medium",
      "treasureRooms": 1,
      "midDungeonRest": true,
      "bossRoomId": "auto_generated",
      "tileset": "cave_tileset_01",
      "decorators": ["stalactites", "mushrooms", "crystals"],
      "clearReward": "cave_chalice_reward_pool"
    }]
  }
  ```

---

### Feature 18: Player Message System

- **Feature Name:** `PlayerMessageSystem`
- **Source:** Dark Souls series (soapstone messages: "Try jumping", "Illusory wall ahead", "Be wary of monster")
- **Description:** Players can leave short, templated messages on the ground that other players can read and rate. Messages use a Mad Libs-style template system ("[Noun] ahead", "Be wary of [Adjective] [Noun]", "Try [Verb]"). Messages that get high ratings heal the message's author. This creates a communal help/hint system.
- **Kid UX:** Child stamps a "Message Board" stamp (wooden signpost). Tapping it opens a word picker: "[Bouncy] [Enemy] Ahead!", "Try [Jumping]!", "Secret [Wall]!". The LLM auto-fills appropriate icons. In play, message boards appear as small signposts; tapping them reads the hint. Child can rate it a thumbs up.
- **LLM Automation:** Manages message template database, validates word combinations, stores messages per level with coordinates, handles rating aggregation, shows most-rated messages first, filters inappropriate content, auto-suggests contextually relevant templates based on nearby entities, and shows a happy notification when the child's message gets rated.
- **JSON Contract Extension:**
  ```json
  {
    "playerMessages": {
      "templates": [
        {"template": "{adjective} {noun} ahead!", "slots": ["adjective", "noun"]},
        {"template": "Try {verb}!", "slots": ["verb"]},
        {"template": "{noun} but {adjective}!", "slots": ["noun", "adjective"]}
      ],
      "wordBank": {
        "adjective": ["bouncy", "sneaky", "giant", "friendly", "spiky"],
        "noun": ["enemy", "treasure", "secret", "hole", "friend"],
        "verb": ["jumping", "running", "hiding", "rolling"]
      },
      "messagesInLevel": [{
        "id": "uuid",
        "x": 600, "y": 300,
        "template": 0,
        "filledWords": ["giant", "enemy"],
        "author": "player_name",
        "rating": 12
      }],
      "ratingReward": "small_heal"
    }
  }
  ```

---

## SECTION 2: Hollow Knight Features

---

### Feature 19: Badge Charm Equip System

- **Feature Name:** `BadgeEquipSystem`
- **Source:** Hollow Knight (Charm System -- 40+ equippable badges)
- **Description:** The player collects "charms" -- equippable badges that grant passive abilities. Charms cost "notches" to equip; the player has limited notches (typically 3-11), forcing loadout decisions. Charms include: Wayward Compass (shows location on map), Gathering Swarm (auto-collects dropped geo), Dashmaster (reduces dash cooldown), Fragile Heart (+2 HP), Spell Twister (spells cost less soul), etc.
- **Kid UX:** Child stamps "Badge" stamps (shield-shaped icons with pictures). Tapping a badge opens a "Socket Board" with 3-5 empty circles (notches). Drag badges into sockets to equip. Badge icons show what they do: compass badge = mini-map appears, heart badge = +1 HP, magnet badge = coin auto-collect. Very visual, no text needed.
- **LLM Automation:** Manages notch capacity and badge cost validation, applies all passive effects from equipped badges, handles badge synergy detection (e.g., Dashmaster + Sprintmaster = bonus effect), prevents over-slotting, auto-generates badge icons if child doesn't stamp custom ones, and provides visual feedback when badges activate.
- **JSON Contract Extension:**
  ```json
  {
    "badgeSystem": {
      "notchCapacity": 5,
      "equippedBadges": [
        {"badgeId": "compass", "name": "Mini Map", "cost": 1, "effect": "show_minimap"},
        {"badgeId": "magnet", "name": "Coin Pull", "cost": 2, "effect": "auto_collect_radius_100"},
        {"badgeId": "extra_heart", "name": "Tougher", "cost": 3, "effect": "max_hp_plus_2"}
      ],
      "synergies": [
        {"badges": ["dash_master", "sprint_master"], "bonusEffect": "dash_speed_plus_20"}
      ],
      "socketBoardVisual": "charm_notch_circle_grid"
    }
  }
  ```

---

### Feature 20: Limited Inventory Map Drawing

- **Feature Name:** `FogOfWarMap`
- **Source:** Hollow Knight (Cornifer sells maps, map drawn as you explore, quill required)
- **Description:** The map is not fully revealed at the start. The player must purchase/find a map for each area, then the map fills in as they explore (fog of war). The player can place custom pins on the map to remember interesting locations. A compass charm is needed to see their current position on the map.
- **Kid UX:** Child stamps a "Map Scroll" stamp in the UI area. In play, the map auto-draws as the hero walks (cartoon pencil lines appear). Unexplored areas show as blank parchment. Child can stamp "Pin" icons on the map (star, skull, question mark). A "Compass Badge" stamp makes a dot appear on the map showing where the hero is.
- **LLM Automation:** Tracks explored tile regions and updates map texture accordingly, manages map scroll pickup requirement (no map UI until found), renders custom pins on map, handles compass badge position tracking, auto-draws terrain features as they're revealed, and saves map exploration state across sessions.
- **JSON Contract Extension:**
  ```json
  {
    "mapSystem": {
      "requiresMapScroll": true,
      "mapScrollAcquired": false,
      "explorationRadius": 150,
      "fogOfWar": true,
      "autoDraw": true,
      "playerPins": [
        {"type": "star", "x": 1200, "y": 400, "note": "cool place"},
        {"type": "skull", "x": 2500, "y": 600, "note": "hard enemy"}
      ],
      "compassBadgeRequired": true,
      "exploredTiles": [[0,0], [0,1], [1,0]],
      "revealStyle": "pencil_sketch"
    }
  }
  ```

---

### Feature 21: Spell Casting with Resource

- **Feature Name:** `SpellCasting`
- **Source:** Hollow Knight (Vengeful Spirit, Howling Wraiths, Desolate Dive, Shade Soul)
- **Description:** Special abilities that consume a resource ("soul") gathered by striking enemies. Spells include: forward fireball (Vengeful Spirit), upward AOE (Howling Wraiths), dive attack (Desolate Dive), and powered-up versions found later. Casting spells requires holding a button then pressing attack, or dedicated spell buttons.
- **Kid UX:** Child stamps "Magic Spark" pickups on the canvas. Hitting enemies fills a "Magic Jar" (visual at top). Child stamps a "Spell Book" stamp near the hero start -- tapping it assigns a spell: "Fireball", "Jump Smash", or "Shield Bubble". In play, a spell button appears when the jar has enough magic. Single-tap to cast.
- **LLM Automation:** Manages soul/magic resource pool (fills on enemy hits, empties on spell cast), handles spell cooldowns and costs, generates projectile entities with appropriate hitboxes, manages spell upgrade tiers (e.g., Vengeful Spirit -> Shade Soul), plays casting animations and VFX, and auto-balances soul gain rate.
- **JSON Contract Extension:**
  ```json
  {
    "spellSystem": {
      "magicPoolMax": 100,
      "magicCurrent": 0,
      "soulGainPerHit": 11,
      "knownSpells": [
        {
          "spellId": "fireball",
          "name": "Fireball",
          "cost": 33,
          "damage": 25,
          "type": "projectile",
          "direction": "forward",
          "cooldown": 0.5,
          "upgradePath": ["fireball", "bigger_fireball", "mega_fireball"]
        },
        {
          "spellId": "dive_smash",
          "name": "Dive Smash",
          "cost": 33,
          "damage": 30,
          "type": "aoe_around_player",
          "invincibilityFrames": 0.4,
          "cooldown": 1.0
        }
      ],
      "equippedSpell": "fireball"
    }
  }
  ```

---

### Feature 22: Fragments for Max HP/Special Upgrades

- **Feature Name:** `FragmentUpgrade`
- **Source:** Hollow Knight (Mask Shards = 4 shards = +1 HP mask; Vessel Fragments = 3 fragments = +1 soul vessel)
- **Description:** The player collects fragment items. Collecting enough fragments (typically 3-4) permanently upgrades a stat -- usually max HP or max magic. Fragments are hidden throughout the world, encouraging thorough exploration. Finding the final fragment to complete a set is deeply satisfying.
- **Kid UX:** Child stamps "Heart Piece" stamps (1/4 of a heart shape) hidden throughout the level. When the hero collects 4, the LLM auto-combines them into a full heart and adds +1 max HP. A big "DING!" animation plays. The HUD shows collected fragments as a pie chart filling up. Child can see at a glance how close they are to the next upgrade.
- **LLM Automation:** Tracks fragment collection count per type, detects when threshold is reached (e.g., 4/4 mask shards), triggers upgrade on threshold hit, plays satisfying combination animation, updates max HP/magic, resets fragment counter with visual carryover, distributes fragment placements to reward exploration, and shows fragment radar if a specific badge is equipped.
- **JSON Contract Extension:**
  ```json
  {
    "fragmentUpgrades": [
      {
        "type": "max_hp",
        "fragmentName": "Heart Piece",
        "fragmentsNeeded": 4,
        "fragmentsCollected": 2,
        "upgradeAmount": 1,
        "visual": "heart_pie_chart",
        "combineAnimation": "heart_assemble",
        "sound": "ding_complete"
      },
      {
        "type": "max_magic",
        "fragmentName": "Magic Drop",
        "fragmentsNeeded": 3,
        "fragmentsCollected": 1,
        "upgradeAmount": 25,
        "visual": "jar_fill_up"
      }
    ]
  }
  ```

---

### Feature 23: Dream World Layer

- **Feature Name:** `DreamWorldLayer`
- **Source:** Hollow Knight (Dream Nail -- enter dream worlds of sleeping enemies, Dream Bosses, White Palace)
- **Description:** A secondary "dream" dimension layered on top of the real world. Using the Dream Nail on certain sleeping enemies or objects transports the player to a surreal version of the area with different platforming challenges, dream-exclusive enemies, and unique rewards. The dream world often has a distinct visual filter (wavering, ethereal colors).
- **Kid UX:** Child stamps a "Sleeping Enemy" stamp (enemy with Zzz bubbles). Tapping it opens option: "Has Dream World?" Child stamps a "Dream Gate" stamp on the sleeping enemy. When the hero uses the "Dream Nail" ability, they shimmer and the screen ripples -- the dream version loads. Child can stamp dream-exclusive platforms and treasures in a separate "Dream Layer" tab.
- **LLM Automation:** Manages dream/real world state toggle, applies dream visual filter (color shift, subtle wave distortion), loads dream layer geometry from separate data, handles dream nail activation collision, manages dream-exclusive entities, ensures the player returns to the exact real-world position on exit, and auto-generates ethereal versions of real-world terrain.
- **JSON Contract Extension:**
  ```json
  {
    "dreamWorldLayer": {
      "activationItem": "dream_nail",
      "visualFilter": "ethereal_wavering",
      "dreamColorShift": {"hueShift": -30, "saturation": 1.3, "brightness": 1.2},
      "dreamEntities": [
        {"entityId": "sleeping_enemy_1", "dreamX": 1200, "dreamY": 400, "dreamPlatforms": [...]},
        {"entityId": "dream_warrior_1", "dreamX": 3000, "dreamY": 600, "isBoss": true}
      ],
      "exitCondition": "reach_dream_exit_or_die",
      "returnToRealPosition": true
    }
  }
  ```

---

### Feature 24: Arena Boss Rush (Pantheon)

- **Feature Name:** `BossRushPantheon`
- **Source:** Hollow Knight (Godmaster DLC Pantheons -- fight 5-10 bosses back-to-back with limited healing)
- **Description:** A special challenge area where the player fights multiple bosses in sequence without returning to the rest point. Between bosses, a very brief healing opportunity (often just 1-2 mask units). Defeating all bosses in the pantheon unlocks harder variants. This is the ultimate skill test.
- **Kid UX:** Child stamps a "Boss Tower" stamp (tower with multiple crown icons on floors). Tapping it opens a floor selector -- child stamps boss enemies on each floor. The LLM auto-generates an elevator sequence between floors. After each boss, a "Healing Flower" briefly blooms. In play, the hero rides an elevator to each floor and fights. Victory gives a "Boss Master" badge.
- **LLM Automation:** Manages boss sequence queue, handles elevator/transition between bosses, provides limited healing item between rounds, tracks boss defeat states within the pantheon run, scales boss HP/damage for pantheon context, plays floor-complete fanfare, manages continue-from-current-floor on respawn, and generates a victory leaderboard time.
- **JSON Contract Extension:**
  ```json
  {
    "bossRushPantheon": {
      "pantheonId": "uuid",
      "name": "Boss Tower",
      "floors": [
        {"floor": 1, "bossId": "goblin_king", "healBetween": 1},
        {"floor": 2, "bossId": "shadow_knight", "healBetween": 1},
        {"floor": 3, "bossId": "dragon_pup", "healBetween": 2},
        {"floor": 4, "bossId": "dark_wizard", "healBetween": 0},
        {"floor": 5, "bossId": "final_boss", "healBetween": 0}
      ],
      "currentFloor": 0,
      "healFlowerDuration": 5,
      "transitionAnimation": "elevator_rise",
      "reward": "pantheon_crown_badge"
    }
  }
  ```

---

### Feature 25: Permanent Ability Bench Rest

- **Feature Name:** `BenchRestCrafting`
- **Source:** Hollow Knight (Benches -- rest, equip charms, change loadouts)
- **Description:** Benches serve as safe havens where the player can rest (heal and respawn), but more importantly, they are the ONLY place where the player can change their equipped charms/abilities. This forces commitment to a loadout during exploration and creates meaningful decisions about what to equip before heading out.
- **Kid UX:** Child stamps a "Cozy Bench" stamp (wooden bench with a lantern). The hero can sit on it (cute animation). Tapping the bench in edit mode opens the Badge Equip screen. In play, sitting on the bench opens a bubble: "Change Badges?" -- tapping yes opens the socket board. A warm glow surrounds the bench.
- **LLM Automation:** Sets respawn point to bench location on sit, opens loadout change UI only while sitting, applies healing on sit completion, prevents ability changes away from benches, plays sitting/resting animation, manages bench discovery state, and auto-generates a lantern glow effect.
- **JSON Contract Extension:**
  ```json
  {
    "benchSystem": {
      "benchesInLevel": [{
        "id": "uuid",
        "x": 800, "y": 350,
        "discovered": false,
        "loadoutChangeAllowed": true,
        "healOnSit": true,
        "respawnOnSit": true,
        "sittingAnimation": "hero_sit_bench",
        "ambientEffect": "lantern_glow",
        "uiOpensOn": "sit_complete"
      }],
      "onlyChangeLoadoutAtBench": true
    }
  }
  ```

---

## SECTION 3: Celeste Features

---

### Feature 26: 8-Directional Air Dash

- **Feature Name:** `AirDash8Way`
- **Source:** Celeste (Madeline's dash -- 8-directional in air, refreshes on ground or touch special objects)
- **Description:** The player can dash once while airborne in any of 8 directions (cardinal + diagonal). The dash covers a fixed distance at high speed and grants brief invincibility. The dash refreshes when touching the ground, certain objects (dash crystals), or moving platforms. This is the core mechanic that makes Celeste's platforming feel incredible.
- **Kid UX:** Child stamps a "Dash Crystal" stamp (sparkly diamond) -- touching it gives a mid-air dash refresh. The hero has a single dash in air by default. A "Dash" button appears in play. The child can drag a direction arrow stamp to set default dash direction, or use joystick/ swipe. Leaves a colored trail behind the hero. Feels super responsive.
- **LLM Automation:** Handles dash physics (impulse + fixed distance + end-lag), manages dash availability state (used/available), refreshes dash on ground touch or crystal pickup, processes 8-directional input, grants brief post-dash coyote time, renders dash trail VFX, plays dash SFX, and prevents dash through solid walls.
- **JSON Contract Extension:**
  ```json
  {
    "dashSystem": {
      "dashDistance": 120,
      "dashSpeed": 600,
      "dashDuration": 0.15,
      "endLag": 0.1,
      "invincibilityFrames": 0.1,
      "maxAirDashes": 1,
      "refreshOn": ["ground_touch", "dash_crystal", "moving_platform"],
      "directions": 8,
      "trailVfx": "rainbow_streak",
      "trailDuration": 0.3,
      "inputType": "flick_joystick_or_button_plus_direction"
    }
  }
  ```

---

### Feature 27: Wall Jump & Wall Slide

- **Feature Name:** `WallJumpSlide`
- **Source:** Celeste (wall sliding and jumping between parallel walls)
- **Description:** When touching a wall in mid-air, the player slides down slowly instead of falling. Pressing jump while sliding launches the player away from the wall and slightly upward. The player can alternate wall jumps to ascend narrow vertical shafts ("chimneying"). Wall jumping resets the air dash.
- **Kid UX:** The hero auto-slides down walls with a little puff of dust. Pressing jump while against a wall launches them off it. Child can stamp "Slippery Wall" stamps (ice-like) that the hero can't grip, and "Sticky Wall" stamps (mossy) that allow longer slide time. Visual: the hero makes a cute pushing-against-wall pose.
- **LLM Automation:** Detects wall collision in mid-air, applies wall slide physics (reduced gravity), handles wall jump input and direction calculation, resets air abilities on wall jump, manages maximum wall slide time before slipping, renders wall-cling dust particles, and distinguishes between wall-jumpable and non-wall-jumpable surfaces.
- **JSON Contract Extension:**
  ```json
  {
    "wallSystem": {
      "wallSlideSpeed": 40,
      "normalGravity": 300,
      "wallSlideGravity": 80,
      "wallJumpForceX": 250,
      "wallJumpForceY": 280,
      "maxWallSlideTime": 2.0,
      "wallJumpResetsDash": true,
      "wallJumpResetsDoubleJump": true,
      "dustParticleEffect": "wall_slide_sparks",
      "wallTypes": {
        "normal": {"slideable": true, "jumpable": true},
        "slippery": {"slideable": false, "jumpable": false},
        "sticky": {"slideable": true, "jumpable": true, "maxSlideTime": 5.0}
      }
    }
  }
  ```

---

### Feature 28: Dream Blocks (Phase Through)

- **Feature Name:** `DreamBlockPhase`
- **Source:** Celeste (Dream Blocks -- player dashes into them and phases through, moving in straight line at dash speed)
- **Description:** Special blocks that are normally solid. When the player dashes into them, they become ethereal and the player continues moving through them in a straight line, exiting out the other side. If the block is longer than the dash distance, the player gets "stuck" in the block and dies. This creates precise dash-distance puzzles.
- **Kid UX:** Child stamps a "Dream Block" stamp (glowing pink/purple block with star pattern). It looks solid but shimmers. When the hero dashes into it, they become a glowing silhouette that travels straight through. Child stamps an "Exit Sparkle" on the far side to mark where the hero pops out. Visual: the block ripples like water when passed through.
- **LLM Automation:** Detects dash collision with dream block, switches player to ethereal state, continues movement in dash direction through the block, restores player state on exit, handles "stuck in block" death if dash distance exceeded, renders ethereal transition VFX, manages dream block visual state (solid -> shimmering -> solid), and auto-validates that dream block thickness doesn't exceed dash range in child-created levels.
- **JSON Contract Extension:**
  ```json
  {
    "dreamBlocks": [{
      "blockId": "uuid",
      "tileStart": {"x": 20, "y": 10},
      "tileEnd": {"x": 24, "y": 10},
      "thickness": 4,
      "maxDashClear": 5,
      "phaseSpeed": 400,
      "visualState": "shimmering_pink",
      "phaseVfx": "ethereal_trail",
      "exitSparkle": true,
      "autoValidateThickness": true,
      "killIfStuck": true
    }]
  }
  ```

---

### Feature 29: Collectible Multi-Challenge Reward

- **Feature Name:** `StrawberryCollection`
- **Source:** Celeste (Strawberries -- optional collectibles, often behind optional challenge screens, must touch ground safely to collect)
- **Description:** Optional collectibles (strawberries) placed in hard-to-reach locations. The player must complete a challenge to reach them AND return to safety without dying. If the player dies while carrying a strawberry, it resets to its original position. This creates risk/reward tension for completionists.
- **Kid UX:** Child stamps a "Shiny Berry" stamp (glowing fruit with sparkle) in hard-to-reach spots. The hero grabs it with a "pop!" sound. The berry floats behind the hero. If the hero falls in a pit, the berry flies back to its start. Collecting all berries in a level gives a gold star on the level select. Simple and motivating.
- **LLM Automation:** Detects strawberry pickup collision, attaches visual follower to player, tracks safe-ground validation (must touch stable ground to permanently collect), handles death-based reset (strawberry flies back to spawn), counts total/per-level, displays collection progress on level select, and auto-generates challenging but fair placements based on level geometry.
- **JSON Contract Extension:**
  ```json
  {
    "strawberrySystem": {
      "strawberries": [{
        "id": "uuid",
        "x": 1500, "y": 200,
        "collected": false,
        "followingPlayer": false,
        "safeGroundRequired": true,
        "resetOnDeath": true,
        "resetAnimation": "berry_fly_home",
        "levelId": "level_1"
      }],
      "collectionReward": {"allInLevel": "gold_star", "allInGame": "berry_master_crown"},
      "pickupVfx": "pop_sparkle",
      "trackerUI": "floating_berry_counter"
    }
  }
  ```

---

### Feature 30: Assist Mode with Toggleable Helpers

- **Feature Name:** `KidAssistMode`
- **Source:** Celeste (Assist Mode -- infinite dashes, invincibility, slowdown to 50-80% speed, extra air jumps)
- **Description:** A set of accessibility toggles that make the game easier without changing level design. Options include: game speed reduction (50%-80%), infinite air dashes, infinite stamina, invincibility (can't die), and extra mid-air jumps. Each toggle is independent. The game explicitly tells players "It's okay to use Assist Mode."
- **Kid UX:** A "Help Menu" button (heart icon) is always visible. Tapping it opens friendly toggle switches: "Extra Bouncy" (extra jumps), "Super Speed" (more dashes), "Strong Shield" (take less damage), "Slow Motion" (game runs slower). Each has a cute icon. The LLM auto-adjusts gameplay parameters. No shame, no penalty -- the game says "You're awesome for playing your way!"
- **LLM Automation:** Applies gameplay parameter overrides per toggle state, manages infinite resource flags, handles invincibility (nullify all damage), applies game speed scaling (affects physics, animations, timers), saves assist preferences per player profile, displays assist indicator only if child opts in, and auto-suggests assist toggles based on death count patterns.
- **JSON Contract Extension:**
  ```json
  {
    "assistMode": {
      "enabled": true,
      "toggles": {
        "infiniteAirDashes": {"enabled": false, "label": "Extra Bouncy", "icon": "infinite_jump"},
        "invincibility": {"enabled": false, "label": "Strong Shield", "icon": "shield_glow"},
        "gameSpeed": {"enabled": false, "value": 0.7, "range": [0.5, 1.0], "label": "Slow Motion", "icon": "snail"},
        "infiniteAirJumps": {"enabled": false, "label": "Super Jumps", "icon": "wings"},
        "noKnockback": {"enabled": false, "label": "Steady Feet", "icon": "anchor"}
      },
      "noPenalty": true,
      "encouragementMessage": "You're awesome for playing your way!",
      "autoSuggest": true,
      "suggestThreshold": 5
    }
  }
  ```

---

### Feature 31: B-Side Remix Levels

- **Feature Name:** `RemixBSide`
- **Source:** Celeste (Cassette Tapes unlock B-Sides -- harder remixes of chapters with new mechanics arrangements)
- **Description:** Collectible cassette tapes hidden in levels unlock "B-Side" versions -- the same level geometry but with much harder enemy/obstacle placement, new mechanics introduced earlier, and stricter timing requirements. B-Sides are for players who want more challenge from familiar content.
- **Kid UX:** Child stamps a "Cassette Tape" stamp (rainbow cassette) hidden in a level. Finding it unlocks a "Remix Mode" for that level. In the level select, the level gets a "B" badge. The LLM auto-generates the remix by: moving platforms faster, adding more enemies, requiring more precise jumps. Child can toggle between Normal and Remix.
- **LLM Automation:** Generates B-Side variant by remixing existing level elements (faster moving platforms, tighter jump windows, additional hazards, different enemy placement), preserves core level geometry, manages cassette tape unlock state, displays B-Side availability, applies appropriate difficulty scaling, and ensures B-Side is challenging but completable.
- **JSON Contract Extension:**
  ```json
  {
    "bSideSystem": {
      "cassetteLocations": [{"levelId": "1", "x": 3000, "y": 400}],
      "bSideVariants": {
        "level_1": {
          "unlocked": false,
          "remixRules": {
            "platformSpeedMultiplier": 1.5,
            "extraEnemies": true,
            "hazardCountMultiplier": 2,
            "stricterTiming": true,
            "newMechanic": "dream_blocks"
          }
        }
      },
      "bSideBadge": "rainbow_B",
      "completionReward": "cassette_master_badge"
    }
  }
  ```

---

## SECTION 4: Shovel Knight Features

---

### Feature 32: Pogo Bounce Attack

- **Feature Name:** `PogoBounce`
- **Source:** Shovel Knight (Shovel Drop -- down-thrust to bounce off enemies, spikes, and certain platforms)
- **Description:** Pressing down+attack while airborne causes the player to thrust their weapon downward. If this hits an enemy, hazard, or special surface, the player bounces upward with significant height. This allows for continuous aerial combat and reaching high areas. The pogo is the signature mechanic.
- **Kid UX:** The hero has a "Shovel Drop" button in play. Pressing it while in air thrusts downward. Hitting an enemy bounces the hero up with a spring sound. Child can stamp "Bouncy Spikes" (safe to bounce on) and "Bouncy Mushrooms" that amplify the bounce height. Visual: the hero's weapon glows during the drop.
- **LLM Automation:** Handles down+attack input detection, applies downward hitbox, checks collision with pogo-valid entities (enemies, bouncy surfaces, certain hazards), applies bounce velocity on hit, manages consecutive pogo chaining, renders weapon trail during drop, plays satisfying bounce SFX, and prevents pogo on non-bounceable surfaces.
- **JSON Contract Extension:**
  ```json
  {
    "pogoSystem": {
      "activation": "down_plus_attack_in_air",
      "bounceVelocityY": -400,
      "bounceVelocityBoostPerChain": -50,
      "maxChain": 10,
      "hitboxSize": {"width": 30, "height": 20},
      "pogoValidEntities": ["enemy_any", "bouncy_spike", "bouncy_mushroom", "green_slime"],
      "mushroomBoostMultiplier": 1.5,
      "trailVfx": "shovel_drop_trail",
      "bounceSfx": "spring_boing",
      "chainCounter": true
    }
  }
  ```

---

### Feature 33: Equipable Sub-Weapon (Relic) System

- **Feature Name:** `RelicSubWeapon`
- **Source:** Shovel Knight (Relics -- flame wand, chaos sphere, propeller dagger, throw anchor, war horn, alchemy coin, fishing rod)
- **Description:** The player finds or purchases secondary weapons called "relics." Each relic costs mana/magic to use and provides a unique ability: flame wand (forward fireball), chaos sphere (bouncing energy ball), propeller dagger (horizontal dash attack), throw anchor (heavy downward projectile), war horn (screen-clearing AOE), etc. Only one relic can be active at a time, chosen from a menu.
- **Kid UX:** Child stamps "Relic Box" stamps (treasure chests) containing relics. The hero opens them and gets a new power. A "Relic" button appears in play with the selected relic's icon. Tapping "Relic Switch" opens a grid of collected relics; tap to equip. Each relic has limited uses shown as dots below the button. Finding a "Magic Jar" pickup refills uses.
- **LLM Automation:** Manages relic inventory and discovery state, handles relic equip/unequip, tracks relic uses per-rest, processes relic-specific logic (projectile spawning, AOE damage, dash attack), manages mana/use costs, generates relic pickup from treasure chests, auto-balances relic power vs. use limits, and renders appropriate relic icon on the UI button.
- **JSON Contract Extension:**
  ```json
  {
    "relicSystem": {
      "collectedRelics": [
        {"relicId": "flame_wand", "name": "Fire Wand", "uses": 20, "maxUses": 20, "cost": 1},
        {"relicId": "chaos_sphere", "name": "Bouncy Ball", "uses": 10, "maxUses": 10, "cost": 2},
        {"relicId": "propeller_dagger", "name": "Zoom Dash", "uses": 15, "maxUses": 15, "cost": 1}
      ],
      "equippedRelic": "flame_wand",
      "replenishOn": "rest_point_touch",
      "useLimitBalancing": true,
      "projectileDefinitions": {
        "flame_wand": {"type": "forward_fireball", "damage": 15, "speed": 300},
        "chaos_sphere": {"type": "bouncing_ball", "damage": 20, "speed": 200, "bounces": 5}
      }
    }
  }
  ```

---

### Feature 34: Checkpoint Destruction (Risk/Reward)

- **Feature Name:** `CheckpointGamble`
- **Source:** Shovel Knight (Checkpoints can be destroyed for treasure -- but lose the checkpoint)
- **Description:** The game's checkpoints are floating orbs. The player can choose to attack and destroy a checkpoint, releasing a shower of treasure. However, the checkpoint is permanently destroyed -- if the player dies after this, they respawn at the previous checkpoint. This creates a meaningful risk/reward decision at every checkpoint.
- **Kid UX:** Checkpoints are "Save Crystals" (glowing orbs). The hero can choose to "Smash for Treasure!" or "Keep Safe." A bubble appears with a hammer icon and a treasure icon. Tapping treasure smashes it -- coins fly out! But the crystal breaks. Child stamps "Safe Crystal" or "Treasure Crystal" to pre-decide. In play, the choice bubble appears.
- **LLM Automation:** Detects player choice at checkpoint, handles checkpoint destruction (removes respawn point), calculates and spawns treasure value based on distance from last checkpoint, plays destruction VFX and treasure shower, updates respawn chain to skip destroyed checkpoints, saves destruction state across sessions, and auto-balances treasure value to be tempting but fair.
- **JSON Contract Extension:**
  ```json
  {
    "checkpointSystem": {
      "checkpoints": [{
        "id": "uuid",
        "x": 1000, "y": 400,
        "state": "intact",
        "destroyable": true,
        "treasureValue": 150,
        "destructionVfx": "crystal_shatter_gold_burst",
        "respawnActive": true
      }],
      "choiceBubble": {
        "prompt": "Smash for treasure?",
        "options": ["keep_safe", "smash_it"],
        "timeout": 10
      },
      "treasureScaling": "distance_from_last_checkpoint"
    }
  }
  ```

---

### Feature 35: Destructible Terrain Blocks

- **Feature Name:** `DestructibleTerrain`
- **Source:** Shovel Knight (dirt blocks destroyed by digging, bomb blocks, breakable walls)
- **Description:** Certain terrain blocks can be destroyed by player actions. Shovel Knight has dirt blocks that can be dug through, bomb blocks that explode when hit, and fragile walls that break from any attack. Destructible blocks hide secrets, shortcuts, or treasure.
- **Kid UX:** Child stamps "Dirt Block" stamps (brown blocks with grass top), "Bomb Block" stamps (red blocks with a fuse), and "Fragile Wall" stamps (cracked stone). The hero can break them by jumping into them from below (like Mario bricks), hitting them, or using abilities. Dirt blocks can be dug through by holding the attack button.
- **LLM Automation:** Handles collision detection for block destruction triggers (attack from below, direct hit, ability-specific), manages block HP and destruction state, spawns appropriate debris particles on break, reveals hidden content behind/within blocks, saves destruction state (blocks stay broken), and distinguishes between one-hit blocks and multi-hit blocks.
- **JSON Contract Extension:**
  ```json
  {
    "destructibleBlocks": {
      "blockTypes": {
        "dirt": {"hp": 1, "trigger": "attack_or_dig", "drops": ["coin_small"], "debris": "brown_chunks"},
        "bomb": {"hp": 1, "trigger": "any_hit", "explosion": true, "explosionRadius": 100, "debris": "red_blast"},
        "fragile_wall": {"hp": 2, "trigger": "attack", "drops": ["secret_passage"], "debris": "stone_rubble"},
        "ice_block": {"hp": 1, "trigger": "fire_attack_only", "debris": "water_splash"}
      },
      "destructionStatePersists": true,
      "hiddenBehindChance": 0.2
    }
  }
  ```

---

### Feature 36: Multiple Campaign Characters (Different Movesets)

- **Feature Name:** `MultiCharacterCampaign`
- **Source:** Shovel Knight (Shovel Knight, Plague Knight, Specter Knight, King Knight -- each has entirely different movement, combat, and level design)
- **Description:** The base game has multiple playable characters, each with fundamentally different abilities. Plague Knight has explosive jumps and bomb crafting. Specter Knight can wall-climb and uses a scythe. King Knight has a shoulder bash and crown throw. Levels are remixed for each character's capabilities.
- **Kid UX:** Child stamps a "Character Select" stamp at the level start. Tapping it opens character portraits: "Knight" (balanced), "Ghost" (can fly through walls), "Ninja" (wall jump + dash), "Princess" (double jump + glide). The LLM auto-adjusts level elements to match each character. Child stamps a "Designed For: [Character]" stamp to set the intended character.
- **LLM Automation:** Manages character selection and ability profiles, validates level compatibility with selected character, auto-remixes level geometry per character (e.g., adds more wall-jump sections for Ninja), applies character-specific physics and hitboxes, manages character unlock progression, generates character-specific ending sequences, and ensures each character feels meaningfully different.
- **JSON Contract Extension:**
  ```json
  {
    "characterSystem": {
      "characters": [
        {
          "id": "knight",
          "name": "Knight",
          "abilities": ["jump", "attack", "pogo", "shield_block"],
          "moveSpeed": 200,
          "jumpHeight": 250,
          "hp": 5
        },
        {
          "id": "ghost",
          "name": "Ghost",
          "abilities": ["float", "phase_through_walls", "scare_attack"],
          "moveSpeed": 150,
          "jumpHeight": 100,
          "hp": 3,
          "unique": "can_phase_through_thin_walls"
        },
        {
          "id": "ninja",
          "name": "Ninja",
          "abilities": ["wall_jump", "air_dash", "shuriken_throw"],
          "moveSpeed": 250,
          "jumpHeight": 220,
          "hp": 4
        }
      ],
      "selectedCharacter": "knight",
      "levelRemixPerCharacter": true,
      "unlockProgression": ["knight", "ghost", "ninja"]
    }
  }
  ```

---

## SECTION 5: Ori Series Features

---

### Feature 37: Bash Launch Off Enemies/Projectiles

- **Feature Name:** `BashMechanic`
- **Source:** Ori and the Blind Forest (Bash -- hold to freeze time, aim, then launch off enemies/projectiles in any direction)
- **Description:** The player holds a button near an enemy or projectile to freeze time, draws an aim line in the opposite direction of desired launch, then releases to catapult themselves while the enemy/projectile is launched the other way. This is Ori's signature mechanic -- it turns enemies and their attacks into mobility tools.
- **Kid UX:** Child stamps a "Bash Orb" stamp (glowing blue sphere) that can be attached to enemies or placed as standalone objects. When the hero is near a bashable object, a "Bash!" button appears. Tapping it freezes time, shows a rainbow aim arrow. Dragging sets direction. Releasing launches the hero. Enemies get dizzy stars after being bashed.
- **LLM Automation:** Detects nearby bashable entities within radius, triggers time freeze on bash initiation, renders aim arrow following input direction, calculates launch vectors (hero launched one way, entity the other), applies launch forces on release, restores normal time, manages bash cooldown, renders time-freeze visual effect (desaturated world + blue tint), and handles entity stun after being bashed.
- **JSON Contract Extension:**
  ```json
  {
    "bashSystem": {
      "bashRadius": 80,
      "timeFreezeDuration": 5.0,
      "launchForce": 600,
      "aimInput": "drag_direction",
      "bashableEntities": ["enemy_any", "projectile_any", "bash_orb"],
      "entityStunDuration": 2.0,
      "cooldown": 0.5,
      "visual": {
        "timeFreezeFilter": "blue_desaturate",
        "aimArrow": "rainbow_directional",
        "launchTrail": "blue_streak"
      },
      "maxBashTargets": 1
    }
  }
  ```

---

### Feature 38: Ability Tree Progression

- **Feature Name:** `AbilityTree`
- **Source:** Ori and the Blind Forest (ability tree -- spend spirit light to unlock Double Jump, Bash, Stomp, Kuro's Feather, Charge Jump, Climb, Light Burst, etc.)
- **Description:** The player collects "Spirit Light" (XP) and spends it on an ability tree to unlock new movement and combat abilities. The tree has three branches: Efficiency (combat), Utility (exploration), and Survival (HP/regen). Abilities are unlocked in order within each branch.
- **Kid UX:** Child stamps "Spirit Light" pickups (glowing orbs) throughout the level. Collecting them fills a "Light Jar." A "Grow" button opens a tree diagram with glowing nodes. Tapping an unlocked node purchases the ability: "Double Jump", "Glide", "Ground Smash", "Wall Climb", "Light Burst." Each ability adds a new button to the play UI. The tree has cute icons, no text needed.
- **LLM Automation:** Tracks Spirit Light collection and total, manages ability tree state (locked/unlocked/purchased), validates purchase eligibility (prerequisites, sufficient light), applies new abilities to player on unlock, generates ability tutorial prompts on first use, renders ability tree with proper node connections, and auto-suggests next ability based on play style.
- **JSON Contract Extension:**
  ```json
  {
    "abilityTree": {
      "branches": {
        "movement": [
          {"id": "double_jump", "cost": 100, "unlocked": false, "prereq": null, "icon": "two_wings"},
          {"id": "glide", "cost": 200, "unlocked": false, "prereq": "double_jump", "icon": "feather"},
          {"id": "bash", "cost": 400, "unlocked": false, "prereq": "glide", "icon": "circular_arrows"}
        ],
        "combat": [
          {"id": "spirit_smash", "cost": 100, "unlocked": false, "prereq": null, "icon": "fist"},
          {"id": "spirit_arc", "cost": 300, "unlocked": false, "prereq": "spirit_smash", "icon": "bow"}
        ],
        "survival": [
          {"id": "hp_plus", "cost": 150, "unlocked": false, "prereq": null, "icon": "heart_plus"}
        ]
      },
      "spiritLight": 250,
      "autoSuggestNext": true
    }
  }
  ```

---

### Feature 39: Shard Equip System (Mini-Upgrades)

- **Feature Name:** `ShardEquip`
- **Source:** Ori and the Will of the Wisps (Shard system -- equipable upgrades like Triple Jump, Quickshot, Finesse, Lifelong, etc.)
- **Description:** The player finds "shards" -- equippable upgrades that provide passive bonuses. Shards are more granular than Hollow Knight's charms. Examples: Triple Jump (extra air jump), Lifelong (1-up), Finesse (+15% melee damage), Energy (faster energy regen). Shards cost "slot" capacity; stronger shards cost more slots.
- **Kid UX:** Child stamps "Shard" stamps (small crystal icons with symbols). Tapping a shard shows what it does with icons: wing symbol = extra jump, heart = +HP, sword = +damage. Shards are dragged into "Shard Slots" on the hero. The hero has 3-5 slots shown as empty circles. Filling all slots creates a rainbow glow around the hero.
- **LLM Automation:** Manages shard inventory and slot capacity, validates shard-slot fitting, applies all equipped shard effects, handles shard synergy bonuses, renders equipped shard icons on the HUD, manages shard discovery and rarity tiers, and auto-balances shard availability so the player has meaningful choices.
- **JSON Contract Extension:**
  ```json
  {
    "shardSystem": {
      "slotCapacity": 5,
      "equippedShards": [
        {"shardId": "triple_jump", "name": "Extra Bounce", "slots": 2, "effect": "extra_air_jump"},
        {"shardId": "finesse", "name": "Stronger Hits", "slots": 2, "effect": "damage_plus_15_percent"},
        {"shardId": "vitality", "name": "More Hearts", "slots": 1, "effect": "hp_plus_1"}
      ],
      "shardInventory": ["triple_jump", "finesse", "vitality", "quickshot"],
      "synergies": [
        {"shards": ["finesse", "quickshot"], "bonus": "damage_plus_25_percent"}
      ]
    }
  }
  ```

---

### Feature 40: Escape Sequence (Timed Auto-Scroll)

- **Feature Name:** `EscapeSequence`
- **Source:** Ori and the Blind Forest (Ginso Tree escape, Forlorn Ruins escape), Will of the Wisps (Wellspring escape)
- **Description:** A cinematic sequence where the player must rapidly platform through a collapsing/breaking level while dramatic music plays. The camera auto-scrolls or the environment falls apart behind the player. Death sends the player back to the start of the sequence. These are high-tension set-pieces that test mastery of the game's mechanics.
- **Kid UX:** Child stamps an "Escape Start" stamp (alarm bell icon) and an "Escape End" stamp (flag icon). Tapping the start stamp opens a theme picker: "Flood" (water rises), "Collapse" (ceiling falls), "Chase" (big monster follows). The LLM auto-generates the escape sequence between the two points. In play, a dramatic countdown plays, and the chosen hazard actively pursues the hero.
- **LLM Automation:** Generates escape sequence path between start and end markers, applies auto-scrolling camera or active hazard (rising lava, falling rocks, pursuing monster), places temporary platforms that appear/disappear, manages death-restart at sequence start, plays dramatic music, sequences VFX for the hazard, tracks best completion time, and auto-balances platform spacing based on player's current ability set.
- **JSON Contract Extension:**
  ```json
  {
    "escapeSequences": [{
      "id": "uuid",
      "name": "Tree Escape",
      "startPoint": {"x": 0, "y": 2000},
      "endPoint": {"x": 5000, "y": 2000},
      "hazardType": "rising_water",
      "hazardSpeed": 100,
      "cameraMode": "auto_scroll_right",
      "tempPlatformSequence": [...],
      "deathRestartAt": "sequence_start",
      "music": "dramatic_escape_theme",
      "bestTime": null,
      "sequenceLength": 60
    }]
  }
  ```

---

## SECTION 6: Dead Cells Features

---

### Feature 41: Run-Based Mutation Selection

- **Feature Name:** `MutationSelection`
- **Source:** Dead Cells (Choose 3 mutations per run -- Brutality/Tactics/Survival branches, e.g., combo healing, poison on hit, extra jumps)
- **Description:** At set points during a run (after each biome/level), the player chooses 1 of 3 randomly offered mutations. Mutations are color-coded to stat branches and provide powerful passive effects: healing on kill, burning enemies explode, extra mid-air jumps, poison spreads, etc. The player ends up with 3 mutations that define their build for that run.
- **Kid UX:** After completing a level, three "Mutation Card" stamps appear (glowing cards with icons). Child taps one to select it. The card shows what it does in pictures: heart+skull = heal on kill, fire+arrow = fire spreads, wing+wing = extra jump. Three slots at the top show current mutations. The LLM auto-generates the selection based on the child's play style (combat-focused gets damage mutations).
- **LLM Automation:** Generates 3 random mutation offers weighted by player's current build, manages mutation inventory (max 3), applies all mutation passive effects, handles mutation synergy combos, tracks which mutations have been offered/selected, adapts offer weights based on play style analytics, and renders mutation icons on persistent HUD slots.
- **JSON Contract Extension:**
  ```json
  {
    "mutationSystem": {
      "maxMutations": 3,
      "currentMutations": [
        {"id": "heal_on_kill", "branch": "survival", "effect": "restore_2hp_per_kill"},
        {"id": "burn_spread", "branch": "brutality", "effect": "burning_enemies_explode_50dmg"}
      ],
      "offerPool": [
        {"id": "extra_jump", "branch": "tactics", "effect": "extra_midair_jump"},
        {"id": "poison_weapon", "branch": "brutality", "effect": "attacks_inflict_poison"},
        {"id": "combo_heal", "branch": "survival", "effect": "every_15_hits_heal_1hp"}
      ],
      "selectionTiming": "after_each_level",
      "autoWeightByPlaystyle": true,
      "mutationSlots": [{"slot": 1, "filled": true}, {"slot": 2, "filled": true}, {"slot": 3, "filled": false}]
    }
  }
  ```

---

### Feature 42: Biome Path Selection

- **Feature Name:** `BiomePathSelect`
- **Source:** Dead Cells (After each biome, choose the next path -- different biomes have different difficulty and reward profiles)
- **Description:** The level select is not linear -- it's a branching path through different biomes. After completing a level, the player chooses which biome to tackle next. Each biome has a difficulty rating, special enemies, unique rewards, and different paths lead to different final bosses. This creates run variety and strategic path planning.
- **Kid UX:** Child stamps "Portal" stamps at level ends. Tapping a portal opens a map with branching paths. Each path shows: a biome icon (forest, castle, sewer), a star difficulty (1-5), and a reward preview (sword icon = weapon, heart = HP upgrade). Child taps the path they want. The LLM auto-generates the biome using the selected theme and difficulty.
- **LLM Automation:** Generates biome level using selected theme and difficulty parameters, manages biome path graph (which biomes connect to which), scales enemy difficulty and reward quality per biome tier, ensures at least one valid path to the final boss exists, generates biome-specific enemy palettes, tracks which biomes have been visited in current run, and auto-balances path difficulty progression.
- **JSON Contract Extension:**
  ```json
  {
    "biomePath": {
      "currentBiome": "prison",
      "availablePaths": [
        {"biome": "forest", "difficulty": 2, "reward": "weapon_drop", "theme": "green_forest"},
        {"biome": "sewer", "difficulty": 3, "reward": "rare_relic", "theme": "purple_sewer"},
        {"biome": "castle", "difficulty": 4, "reward": "upgrade_materials", "theme": "gray_castle"}
      ],
      "biomeGraph": {
        "prison": ["forest", "sewer"],
        "forest": ["castle", "cave"],
        "sewer": ["cave", "tower"]
      },
      "finalBossPaths": ["castle", "tower"],
      "runHistory": ["prison"],
      "difficultyScaling": "biome_depth_based"
    }
  }
  ```

---

### Feature 43: Cursed Chest (High Risk, High Reward)

- **Feature Name:** `CursedChest`
- **Source:** Dead Cells (Cursed Chests -- one-hit kill until you kill X enemies, but gives powerful reward)
- **Description:** Opening a cursed chest gives a powerful reward (rare weapon, lots of cells/currency, or a guaranteed high-tier item) but inflicts "Curse" -- the player dies in a single hit from anything until they kill a set number of enemies (typically 10). This creates extreme tension where every enemy encounter is life-or-death.
- **Kid UX:** Child stamps a "Spooky Chest" stamp (purple chest with a skull lock). Tapping it sets the curse count (3-10 enemy kills via number picker). Inside, child stamps a "Super Prize" (golden weapon, crown). In play, opening the chest gives the prize but the hero glows purple and a "Curse: 10" counter appears. Each enemy kill ticks it down. One hit = defeat. Thrilling!
- **LLM Automation:** Handles chest open trigger, inflicts curse status (max HP effectively becomes 1), displays curse counter HUD, decrements on enemy kills, removes curse when counter reaches 0, spawns reward item on open, plays curse VFX (purple aura), ensures curse persists across rooms/levels until cleared, and warns player with screen edge pulse when at 1 HP under curse.
- **JSON Contract Extension:**
  ```json
  {
    "cursedChest": {
      "chestId": "uuid",
      "position": {"x": 3500, "y": 400},
      "curseKillsRequired": 10,
      "curseState": {
        "active": false,
        "killsRemaining": 10,
        "playerMaxHpDuringCurse": 1
      },
      "reward": {"type": "rare_weapon", "weaponId": "legendary_sword"},
      "visual": {
        "chest": "purple_skull_chest",
        "curseAura": "purple_flame",
        "counterStyle": "skull_number"
      },
      "curseWarning": {"screenEdgePulse": true, "heartbeatSound": true}
    }
  }
  ```

---

### Feature 44: Weapon Affix System

- **Feature Name:** `WeaponAffix`
- **Source:** Dead Cells (Weapon/shield affixes -- "+X% damage to burning enemies", "poisons on hit", "burns nearby enemies on kill", "extra damage but +X% damage taken")
- **Description:** Weapons and shields randomly roll with 1-2 affixes when found. Affixes modify behavior: damage bonuses under conditions, status effect application, AOE effects, trade-offs (more damage but more damage taken), color scaling, etc. This makes every weapon drop exciting and creates build-defining moments.
- **Kid UX:** Weapons found in treasure have bonus stamps attached: a "Fire" stamp = burns enemies, a "Star" stamp = extra damage, a "Heart" stamp = heals on kill. Child can see these bonus icons on the weapon's picture. When equipping, the LLM reads the stamps and applies the effects. Child can drag bonus stamps onto weapons in the editor.
- **LLM Automation:** Generates random affix pool on weapon spawn, validates affix compatibility (no conflicting affixes), applies affix effects in combat (status effects, damage mods, AOE triggers), renders affix icons on weapon UI, manages affix description generation, saves affix state with weapon, and auto-balances affix power based on weapon tier.
- **JSON Contract Extension:**
  ```json
  {
    "weaponAffix": {
      "maxAffixes": 2,
      "affixPool": [
        {"id": "burn_on_hit", "type": "status", "effect": "inflict_burn_3s", "visual": "fire_icon"},
        {"id": "bonus_vs_burning", "type": "conditional_damage", "effect": "plus_40_percent_vs_burning", "visual": "flame_sword"},
        {"id": "poison_spread", "type": "on_kill", "effect": "poison_cloud_on_kill", "visual": "green_burst"},
        {"id": "glass_cannon", "type": "tradeoff", "effect": "plus_50_percent_damage, plus_30_percent_damage_taken", "visual": "cracked_sword"}
      ],
      "currentAffixes": ["burn_on_hit", "bonus_vs_burning"],
      "incompatiblePairs": [["burn_on_hit", "freeze_on_hit"]],
      "rarityWeightByBiome": true
    }
  }
  ```

---

### Feature 45: Timed Reward Doors

- ** Feature Name:** `TimedRewardDoor`
- **Source:** Dead Cells (Timed doors -- reach the door within X minutes to get a big reward, can only open once per run)
- **Description:** At certain points in the biome path, there are sealed doors with a timer. If the player reaches the door before the time limit (counting from run start), it opens and gives a large reward (rare blueprint, lots of cells, powerful weapon). The timer creates pressure to play fast and efficiently. The door can only be opened once per save file.
- **Kid UX:** Child stamps a "Race Door" stamp (door with a stopwatch icon). Tapping it sets the time limit (1-5 minutes via simple number picker). Behind the door, child stamps a "Mega Prize" (giant golden chest). In play, a timer counts up from level start. If the hero reaches the door before time's up, it opens with a fanfare. If not, it stays locked but a message says "Try faster next time!"
- **LLM Automation:** Starts timer on run start, checks door open condition on player proximity (time <= limit), handles door open/locked state, spawns reward on open, plays appropriate VFX and SFX, manages one-time-open state per save, displays timer HUD, and auto-calculates fair time limits based on level length.
- **JSON Contract Extension:**
  ```json
  {
    "timedDoors": [{
      "doorId": "uuid",
      "position": {"x": 2000, "y": 400},
      "timeLimitSeconds": 120,
      "reward": {"cells": 100, "itemId": "timed_door_weapon_pool"},
      "state": "locked",
      "oneTimeOpen": true,
      "visual": "golden_stopwatch_door",
      "openVfx": "fanfare_burst",
      "lockedMessage": "Too slow! Try faster next time!",
      "timerDisplay": "top_right_count_up"
    }]
  }
  ```

---

## SECTION 7: Hades Features

---

### Feature 46: God Boon Selection (Run-Upgrades)

- **Feature Name:** `GodBoon`
- **Source:** Hades (Olympian god boons -- Zeus=lightning chain, Athena=deflect, Aphrodite=charm/weak, Artemis=critical, Ares=bleed/doom, Dionysus=hangover/poison, Hermes=speed, Poseidon=knockback)
- **Description:** At specific rooms during a run, an Olympian god offers a boon -- a blessing that modifies the player's attacks, special, cast, or dash. Each god has a theme: Zeus adds chain lightning, Athena adds deflect on attack/dash, Aphrodite weakens enemies, etc. Boons can be upgraded in rarity (common->rare->epic->heroic) and can be combined for Duo Boons.
- **Kid UX:** Child stamps a "God Statue" stamp (glowing pedestal). Tapping it opens a god picker: "Thunder" (Zeus-lightning icon), "Shield" (Athena-shield icon), "Heart" (Aphrodite-heart icon), "Arrow" (Artemis-bow icon). Each god offers 3 blessing stamps. Child taps one to equip. The hero's attacks gain the god's visual effect. Stacking 2 gods unlocks "Super Combo" blessings.
- **LLM Automation:** Generates boon offers based on current weapon/build, manages boon inventory and slot assignment (attack/special/cast/dash), applies boon effects to appropriate actions, upgrades boons via Pom of Power, handles Duo Boon unlock when prerequisites met, renders god-themed VFX on attacks (lightning bolts, pink hearts, owl feathers), and auto-balances boon power for kid-friendly difficulty.
- **JSON Contract Extension:**
  ```json
  {
    "godBoonSystem": {
      "availableGods": ["zeus", "athena", "aphrodite", "artemis", "ares"],
      "equippedBoons": {
        "attack": {"god": "zeus", "boonId": "lightning_strike", "rarity": "rare", "effect": "chain_lightning_on_hit"},
        "dash": {"god": "athena", "boonId": "divine_dash", "rarity": "common", "effect": "deflect_on_dash"},
        "special": null,
        "cast": null
      },
      "duoBoons": {
        "unlocked": [],
        "availableWhen": {"zeus_athena": "lightning_deflect_combo"}
      },
      "pomUpgrades": {"maxPoms": 5, "powerScaling": 1.2},
      "boonSlots": ["attack", "special", "cast", "dash"]
    }
  }
  ```

---

### Feature 47: Keepsake System (Starter Bonuses)

- **Feature Name:** `KeepsakeStarter`
- **Source:** Hades (Keepsakes -- equippable mementos from NPCs that provide a starting bonus for the run)
- **Description:** Before starting a run, the player equips one "keepsake" -- a memento from an NPC that provides a benefit for that run. Examples: +25 starting HP, a specific god's boon in the first room, +10% speed, +1 death defiance. Keepsakes level up with use, becoming more powerful. This gives the player control over how their run starts.
- **Kid UX:** Child stamps a "Keepsake Box" stamp (small jewelry box). Tapping it opens collected trinkets: "Lucky Coin" (+coins), "Friend Photo" (+HP), "Shiny Rock" (+speed). Child drags one into the "Take With You" slot. That bonus applies for the entire level. Keepsakes gain a star after 3 uses, becoming stronger.
- **LLM Automation:** Manages keepsake collection and unlock state, applies keepsake effect on run start, tracks keepsake usage count, handles keepsake leveling (+1 star per threshold), generates keepsake from NPC relationship milestones, renders keepsake icon on run-start screen, and auto-suggests keepsakes based on level difficulty.
- **JSON Contract Extension:**
  ```json
  {
    "keepsakeSystem": {
      "collectedKeepsakes": [
        {"id": "lucky_coin", "name": "Lucky Coin", "effect": "plus_50_starting_coins", "uses": 5, "level": 2, "maxLevel": 3},
        {"id": "friend_photo", "name": "Friend Photo", "effect": "plus_25_starting_hp", "uses": 3, "level": 1, "maxLevel": 3},
        {"id": "shiny_rock", "name": "Shiny Rock", "effect": "plus_10_percent_speed", "uses": 8, "level": 3, "maxLevel": 3}
      ],
      "equippedKeepsake": "lucky_coin",
      "levelThresholds": [3, 6, 10],
      "levelScaling": {"hp": [25, 38, 50], "coins": [50, 75, 100], "speed": [1.1, 1.15, 1.2]},
      "suggestByDifficulty": true
    }
  }
  ```

---

### Feature 48: Progressive Narrative Between Runs

- **Feature Name:** `ProgressiveNarrative`
- **Source:** Hades (Zagreus's relationships progress between deaths, new dialogue, story advancement)
- **Description:** Death is not failure -- it's a narrative opportunity. Each time the player returns to the hub, NPCs have new dialogue that advances the story. Relationships develop through gift-giving, story beats unlock based on number of attempts, and the overarching narrative progresses regardless of player skill. This reframes the roguelike loop as a story experience.
- **Kid UX:** Between levels, the hero returns to a "Home Base" area. NPC stamps are there; tapping them shows a speech bubble with new dialogue. Child can stamp "Gift" items (flowers, cookies) on NPCs to make them happier. A "Story Book" stamp shows how many story scenes have been unlocked. The LLM auto-generates contextually appropriate dialogue.
- **LLM Automation:** Manages narrative state machine across runs, generates contextually appropriate dialogue based on recent events (bosses defeated, boons chosen, deaths occurred), tracks relationship levels per NPC, handles gift acceptance and relationship progression, unlocks new story beats at relationship thresholds, saves narrative state persistently, and provides voice-narrated or text-to-speech dialogue.
- **JSON Contract Extension:**
  ```json
    {
      "narrativeSystem": {
        "npcs": [
          {
            "npcId": "mom_ghost",
            "name": "Mom Ghost",
            "relationshipLevel": 3,
            "giftsGiven": 2,
            "dialogueTree": "mom_ghost_tree_01",
            "latestDialogue": "You've come so far, little one!",
            "nextThreshold": 5
          }
        ],
        "storyBeatsUnlocked": ["first_death", "first_boss", "first_full_clear"],
        "totalRuns": 15,
        "narrativeProgression": "persistent_across_sessions",
        "giftItems": ["flower", "cookie", "drawing"],
        "storyBookPageCount": 12
      }
    }
  ```

---

### Feature 49: Difficulty Modifier (Heat/Pact)

- **Feature Name:** `DifficultyModifier`
- **Source:** Hades (Pact of Punishment -- toggle individual difficulty modifiers: harder bosses, more enemy HP, tighter timer, less healing, etc.)
- **Description:** The player can individually toggle difficulty modifiers, each adding "heat" points. Modifiers include: harder bosses (new attack patterns), +enemy HP%, +enemy damage%, shorter timer, less healing from fountains, shop prices increased, etc. Each heat level increases reward quality. This lets players fine-tune challenge to their skill level.
- **Kid UX:** A "Challenge Menu" (flame icon) shows toggle switches with pictures: "Big Enemies" (enemy gets bigger), "Fast Timer" (clock speeds up), "Less Healing" (smaller potion), "Super Boss" (boss crown glows red). Each toggle adds flame points. More flames = better prizes at the end. Child controls their own challenge level. No pressure.
- **LLM Automation:** Applies individual difficulty modifiers per toggle state, calculates total heat points, scales rewards by heat level, modifies enemy parameters (HP, damage, scale), adds boss attack patterns at high heat, adjusts timer limits, modifies healing amounts, scales shop prices, tracks highest heat cleared per level, and generates heat-appropriate reward chests.
- **JSON Contract Extension:**
  ```json
  {
    "difficultyModifiers": {
      "heatPoints": 0,
      "toggles": {
        "harder_bosses": {"heat": 2, "enabled": false, "effect": "boss_new_attack_patterns", "visual": "red_crown"},
        "enemy_hp_plus_50": {"heat": 1, "enabled": false, "effect": "enemy_hp_multiplier_1.5", "visual": "bigger_enemy"},
        "enemy_damage_plus_50": {"heat": 1, "enabled": false, "effect": "enemy_damage_multiplier_1.5", "visual": "angry_face"},
        "timer_minus_30": {"heat": 1, "enabled": false, "effect": "time_limit_multiplier_0.7", "visual": "fast_clock"},
        "less_healing": {"heat": 1, "enabled": false, "effect": "healing_multiplier_0.5", "visual": "small_potion"}
      },
      "rewardScaling": {"perHeatPoint": "plus_10_percent_reward"},
      "highestHeatCleared": {"level_1": 0},
      "maxHeat": 20
    }
  }
  ```

---

## SECTION 8: Axiom Verge Features

---

### Feature 50: Environment Glitch Gun

- **Feature Name:** `GlitchGun`
- **Source:** Axiom Verge (Address Disruptor -- glitch gun that corrupts environment and enemies)
- **Description:** A special weapon that doesn't deal damage directly but "glitches" whatever it hits. Glitched enemies may become friendly, change behavior, or drop different items. Glitched blocks may become passable, start moving, or reveal hidden passages. Glitched doors may open. The entire game world has a "glitched" alternate state accessible through this mechanic.
- **Kid UX:** Child stamps a "Glitch Ray" stamp (zigzag beam icon) as a hero ability or pickup. Child stamps "Glitch Target" stamps on walls, enemies, and doors -- these are objects that react to glitching. In play, the "Glitch" button fires a rainbow zigzag beam. Hit a wall = it becomes ghostly (passable). Hit an enemy = it turns friendly (smiley face). Hit a door = it opens. Very magical and surprising.
- **LLM Automation:** Manages glitch state per entity (normal/glitched), applies glitch effects based on entity type (enemy behavior change, wall collision toggle, door state toggle), renders glitch VFX on affected entities (rainbow static, vertex jitter), handles glitch reversion (some glitches are permanent, some timed), generates hidden content behind glitched walls, and ensures glitch effects are visually obvious and kid-delighting.
- **JSON Contract Extension:**
  ```json
  {
    "glitchGun": {
      "beamRange": 200,
      "beamWidth": 20,
      "cooldown": 0.5,
      "glitchEffects": {
        "wall": {"effect": "toggle_collision", "reversible": false, "visual": "rainbow_static_wall"},
        "enemy": {"effect": "become_friendly", "reversible": true, "duration": 30, "visual": "smiley_face_overlay"},
        "door": {"effect": "force_open", "reversible": false, "visual": "glitch_unlock_sparkle"},
        "platform": {"effect": "start_moving", "reversible": true, "visual": "jitter_motion"}
      },
      "hiddenPassages": [
        {"tileX": 30, "tileY": 10, "glitchReveals": "secret_room_with_treasure"}
      ],
      "glitchVfx": "rainbow_zigzag_beam",
      "affectedEntitiesGlow": true
    }
  }
  ```

---

### Feature 51: Drone Teleportation

- **Feature Name:** `DroneTeleport`
- **Source:** Axiom Verge (drone that can be launched and teleported to)
- **Description:** The player launches a small drone that they can control remotely. The drone can squeeze through narrow passages the player cannot. At any time, the player can teleport to the drone's current location. This is used for accessing otherwise unreachable areas, scouting ahead, and solving spatial puzzles.
- **Kid UX:** Child stamps a "Mini Drone" stamp (tiny robot icon) as a hero ability. A "Launch Drone" button appears in play. Tapping it launches a tiny controllable robot. The hero freezes in place. Arrow buttons control the drone. A "Go To Drone!" button teleports the hero to the drone with a sparkle swap. The drone can fit through "Tiny Tunnel" stamps.
- **LLM Automation:** Spawns controllable drone entity on launch, switches input control to drone, renders player character as semi-transparent while drone active, handles teleport swap (drone position -> player position), manages drone health (destroyed if hit), handles drone recall on command, ensures drone can't go too far from player, and auto-places "tiny tunnel" entrances for drone-only passages.
- **JSON Contract Extension:**
  ```json
  {
    "droneTeleport": {
      "droneSpeed": 150,
      "maxDistanceFromPlayer": 800,
      "droneHealth": 1,
      "controlMode": "remote_switch",
      "teleportVfx": "sparkle_swap",
      "droneVisual": "tiny_robot",
      "playerFrozenDuringRemote": true,
      "recallOnHit": true,
      "tinyTunnelPassage": true,
      "launchCost": 0,
      "cooldown": 2.0
    }
  }
  ```

---

## SECTION 9: Cross-Cutting Systems (Applicable to Multiple Games)

---

### Feature 52: Death Currency Recovery Run

- **Feature Name:** `DeathRecoveryRun`
- **Source:** Dark Souls (bloodstain retrieval), Hollow Knight (shade fight), Dead Cells (lose cells on death)
- **Description:** When the player dies, they respawn at the last checkpoint but must return to their death location to recover lost resources. In Dark Souls, it's a bloodstain pickup. In Hollow Knight, you must fight your "shade" (shadow self) to reclaim geo. This creates a "one more try" loop where even death has a recovery mini-objective.
- **Kid UX:** When the hero falls, a "Ghost Me" stamp appears at the death spot (cute ghost version of the hero). The hero respawns at the last campfire. The ghost holds all the lost coins. Touching the ghost merges it back -- coins restored! If the hero falls before reaching the ghost, it disappears with a sad poof. The ghost waves at the hero to guide them back.
- **LLM Automation:** Spawns ghost entity at death coordinates carrying dropped currency, manages ghost state (waiting/retrieved/lost), handles merge collision and currency restoration, calculates ghost position persistence across sessions, plays cute ghost animations (wave, hop, sad poof), shows directional indicator pointing to ghost location, and ensures ghost doesn't spawn in impossible-to-reach locations.
- **JSON Contract Extension:**
  ```json
  {
    "deathRecovery": {
      "ghostEntity": {
        "spawnAtDeath": true,
        "carriesCurrency": true,
        "currencyAmount": 75,
        "position": {"x": 2400, "y": 300},
        "state": "waiting"
      },
      "retrievalTrigger": "player_touch",
      "onSuccess": {"restoreCurrency": true, "vfx": "ghost_merge_happy"},
      "onFailure": {"currencyLost": true, "vfx": "ghost_sad_poof"},
      "ghostAnimations": ["wave", "hop", "sad_when_player_dies"],
      "directionIndicator": true
    }
  }
  ```

---

### Feature 53: Wall-of-Death Chase Sequence

- **Feature Name:** `WallOfDeathChase`
- **Source:** Celeste (Badeline chase segments), Ori (Wellspring escape), Dead Cells (various timed sections)
- **Description:** A sequence where a dangerous entity or hazard pursues the player from behind, forcing continuous forward movement. The pursuer is often invincible and will kill on contact. The player must platform quickly and precisely while the "wall of death" closes in. These are intense set-pieces that test mechanical mastery.
- **Kid UX:** Child stamps a "Chase Start" stamp (starting line) and a "Chase End" stamp (finish flag). Tapping the start stamp opens a hazard picker: "Giant Slime" (bouncy monster), "Dark Fog" (creeping darkness), "Rockslide" (boulders from behind). The LLM auto-generates a forward-scrolling level section. In play, the hazard chases the hero! The screen edge glows red. Exciting and dramatic.
- **LLM Automation:** Spawns pursuer entity on sequence start, manages pursuer speed (slightly slower than max player speed to create tension but not feel unfair), handles instant-kill on contact, auto-scrolls camera to enforce forward movement, generates appropriate platforming challenges in the chase path, plays dramatic chase music, manages sequence completion on reaching end flag, and auto-balances difficulty for kid players (pursuer is slightly slower).
- **JSON Contract Extension:**
  ```json
  {
    "chaseSequence": {
      "startTrigger": {"type": "player_touch", "x": 100, "y": 400},
      "endTrigger": {"type": "reach_flag", "x": 3000, "y": 400},
      "pursuer": {
        "type": "giant_slime",
        "speed": 180,
        "damage": 999,
        "visual": "huge_bouncing_blob",
        "screenShake": true
      },
      "cameraMode": "forced_scroll",
      "scrollSpeed": 200,
      "sequencePlatforms": "auto_generated",
      "deathRestartAt": "chase_start",
      "completionReward": "chase_survivor_badge",
      "kidMode": {"pursuerSpeedMultiplier": 0.8, "extraPlatformWidth": 1.3}
    }
  }
  ```

---

### Feature 54: Environmental Hazard Push

- **Feature Name:** `EnvironmentalHazard`
- **Source:** Celeste (wind, snowballs, moving platforms), Ori (rising water, falling branches), Hollow Knight (infection/acid)
- **Description:** The level environment itself is hazardous -- wind pushes the player, rising lava/flood water forces upward movement, falling icicles create temporary platforms, slippery ice reduces friction. Environmental hazards are not enemies but they create dynamic platforming challenges.
- **Kid UX:** Child stamps "Wind Blower" stamps (fan with arrow showing direction), "Lava Rise" stamps (red zone that rises over time), "Ice Floor" stamps (shiny blue ground), "Falling Rock" stamps (rocks that fall and become platforms). Tapping any hazard stamp opens strength settings (gentle/strong). The LLM auto-generates appropriate VFX for each.
- **LLM Automation:** Applies directional force for wind zones, manages rising/falling hazard timing, applies friction modifiers for ice/slippery surfaces, handles falling object physics and platform creation on landing, renders appropriate VFX (wind lines, lava bubbles, ice sparkle), manages hazard damage on contact, and auto-validates that hazard combinations are fair for kids.
- **JSON Contract Extension:**
  ```json
  {
    "environmentalHazards": {
      "windZones": [
        {"x": 500, "y": 300, "width": 800, "height": 200, "forceX": 150, "forceY": 0, "visual": "wind_lines", "strength": "gentle"}
      ],
      "risingHazards": [
        {"type": "lava", "startY": 800, "riseSpeed": 30, "maxY": 200, "damage": 10, "visual": "lava_bubbles"}
      ],
      "frictionModifiers": [
        {"type": "ice", "tiles": [...], "friction": 0.1, "visual": "ice_sparkle"}
      ],
      "fallingPlatforms": [
        {"type": "rock", "spawnX": 1200, "spawnY": -100, "fallSpeed": 200, "becomesPlatform": true, "visual": "falling_boulder"}
      ]
    }
  }
  ```

---

### Feature 55: NPC Shop with Currency

- **Feature Name:** `NPCShop`
- **Source:** Shovel Knight (Chester's shop), Hollow Knight (various vendors), Dead Cells (shops between biomes)
- **Description:** A friendly NPC sells items, abilities, or upgrades for collected currency. Shops appear at checkpoints or between levels. Items have prices displayed. The player can browse and purchase. Stock may be limited or randomized. Some shops move locations or have special conditions.
- **Kid UX:** Child stamps a "Shop Tent" stamp (colorful tent with a flag). Tapping it opens a shelf where child stamps items for sale (weapons, badges, hearts) and sets prices with coin number stamps. An "NPC Keeper" stamp stands nearby. In play, tapping the keeper opens a shop bubble showing items with price tags. The hero's coin count is shown. Tap item + confirm to buy.
- **LLM Automation:** Manages shop inventory and pricing, handles purchase transactions (deduct currency, add item), generates shop stock if not explicitly set (procedural stock), manages shopkeeper NPC dialogue, plays purchase VFX, ensures player can't purchase unaffordable items (grayed out), restocks shops between rests, and handles "sold out" state.
- **JSON Contract Extension:**
  ```json
  {
    "npcShop": {
      "shopId": "uuid",
      "shopkeeperId": "chester_clone",
      "position": {"x": 1500, "y": 400},
      "inventory": [
        {"itemId": "health_potion", "price": 50, "stock": 3, "type": "consumable"},
        {"itemId": "fire_wand", "price": 200, "stock": 1, "type": "weapon"},
        {"itemId": "speed_badge", "price": 150, "stock": 1, "type": "badge"}
      ],
      "restockOn": "rest_point_touch",
      "currencyType": "coins",
      "autoGenerateStock": true,
      "purchaseVfx": "coin_sparkle",
      "unaffordableVisual": "grayed_out_with_lock"
    }
  }
  ```

---

### Feature 56: Teleport Warp Network

- **Feature Name:** `WarpNetwork`
- **Source:** Hollow Knight (Stag Stations), Ori (Spirit Wells), Dark Souls (Lordvessel warping)
- **Description:** After reaching certain mid-game milestones, the player gains the ability to fast-travel between discovered rest points/checkpoints. This eliminates tedious backtracking and opens up the world for exploration. Warp points must be discovered first by reaching them on foot.
- **Kid UX:** Child stamps "Warp Pad" stamps (glowing circles with symbols) near checkpoints. Tapping a placed warp pad opens a symbol picker (star, moon, sun, heart). Matching warp pads connect. In play, standing on a warp pad opens a map showing all discovered warp points; tap to teleport. A rainbow beam effect plays during warp.
- **LLM Automation:** Manages warp pad discovery state, handles warp network graph (which pads connect), validates warp eligibility (must be discovered), plays warp animation (beam up at source, beam down at destination), manages warp cooldown, ensures warp doesn't work during combat, and auto-generates warp pad pairs for child-created levels.
- **JSON Contract Extension:**
  ```json
  {
    "warpNetwork": {
      "warpPads": [
        {"id": "pad_1", "x": 400, "y": 300, "symbol": "star", "discovered": true, "connectedTo": ["pad_2"]},
        {"id": "pad_2", "x": 3500, "y": 500, "symbol": "moon", "discovered": true, "connectedTo": ["pad_1", "pad_3"]},
        {"id": "pad_3", "x": 2000, "y": 200, "symbol": "sun", "discovered": false, "connectedTo": ["pad_2"]}
      ],
      "warpAnimation": "rainbow_beam",
      "warpDuration": 2.0,
      "combatLockout": true,
      "requiresDiscovery": true,
      "cooldown": 5.0
    }
  }
  ```

---

### Feature 57: Daily Run Challenge

- **Feature Name:** `DailyRun`
- **Source:** Dead Cells (Daily Run), Hades (no direct equivalent but Pact system enables similar)
- **Description:** A special seeded run that is the same for all players on a given day. Players compete for the best time/score on identical level layouts, enemy placements, and item availability. Daily runs have special rules or modifiers. Leaderboards show how the player ranks against others.
- **Kid UX:** A "Daily Challenge" stamp (calendar with a star) on the main menu. Tapping it generates today's special level. A "Today" stamp ensures the same level for everyone. After completing, a "Scoreboard" stamp shows the child's time with a medal (gold/silver/bronze). Child can stamp "Beat This!" to challenge friends. Very motivating.
- **LLM Automation:** Generates daily seed from date (same seed = same level for all players), applies daily modifier (e.g., "No Jumping Day", "Super Speed Day"), tracks completion time/score, manages local leaderboard storage, generates daily-appropriate level geometry, rotates modifiers by day of week, and creates shareable challenge codes for friend competition.
- **JSON Contract Extension:**
  ```json
  {
    "dailyRun": {
      "seedSource": "date_based",
      "dailyModifier": "all_enemies_drop_coins",
      "modifierRotation": {
        "monday": "speed_boost_day",
        "tuesday": "extra_jumps_day",
        "wednesday": "no_enemies_day",
        "thursday": "double_coins_day",
        "friday": "random_weapons_day",
        "saturday": "boss_rush_day",
        "sunday": "all_powerups_day"
      },
      "leaderboard": {
        "playerBest": 120,
        "medal": "gold",
        "rank": 1
      },
      "shareCode": "DAILY_20241201",
      "reward": "daily_champion_badge"
    }
  }
  ```

---

### Feature 58: Moving Platform Variety Pack

- **Feature Name:** `MovingPlatformPack`
- **Source:** Celeste (moving platforms, falling platforms, crumble blocks), Shovel Knight (moving platforms), Ori (light-activated platforms)
- **Description:** A variety of platform types that create dynamic level geometry: horizontal/vertical moving platforms, platforms that fall shortly after being stepped on, platforms that crumble and don't respawn until rest, platforms that move when the player is on them, and platforms activated by switches/player actions.
- **Kid UX:** Child stamps platform stamps with different behaviors: "Moving" stamp (arrow shows path), "Falling" stamp (cracks on surface), "Crumble" stamp (dust particles), "Switch" stamp (button that moves linked platforms), "Track" stamp (dotted line showing movement path). Dragging the arrow extends the path. The LLM auto-generates smooth movement along the path.
- **LLM Automation:** Manages platform movement along defined paths, handles falling platform trigger (step -> delay -> fall), manages crumble platform state (intact -> crumbling -> gone -> respawn on rest), processes switch-to-platform linkage, calculates platform collision and player-parenting while standing on them, renders appropriate visual states, and validates platform paths don't intersect solid walls.
- **JSON Contract Extension:**
  ```json
  {
    "movingPlatforms": {
      "platformTypes": {
        "horizontal_move": {"speed": 100, "path": "auto_linear", "carryPlayer": true},
        "vertical_move": {"speed": 80, "path": "auto_linear", "carryPlayer": true},
        "falling": {"fallDelay": 0.5, "fallSpeed": 300, "respawnOn": "rest_point_touch", "visual": "cracked_surface"},
        "crumble": {"crumbleDelay": 0.3, "respawnOn": "rest_point_touch", "visual": "dust_particles"},
        "switch_activated": {"linkedSwitchId": "uuid", "moveOnActivate": true, "stayMoved": true}
      },
      "pathSystem": {
        "pathType": "linear_loop",
        "waypoints": [{"x": 500, "y": 300}, {"x": 900, "y": 300}],
        "easing": "ease_in_out",
        "waitAtEndpoints": 1.0
      }
    }
  }
  ```

---

### Feature 59: Progressive Difficulty (Boss Cells)

- **Feature Name:** `ProgressiveDifficulty`
- **Source:** Dead Cells (Boss Stem Cells -- beat the game with X active to unlock X+1), Hades (Heat system)
- **Description:** The player starts at difficulty 0. Beating the final boss at difficulty N unlocks difficulty N+1, which adds new enemy types, more enemy HP/damage, new hazards, and better rewards. This creates a natural skill-progression curve where the game grows with the player. Each difficulty tier is a meaningful jump.
- **Kid UX:** After defeating the final boss, a "Difficulty Crown" stamp appears with numbered gems (0-5). Child taps the crown to set the level's difficulty. Higher numbers = bigger enemies, more of them, and shinier treasure. The LLM auto-adjusts everything. A "My Best" stamp shows the highest difficulty cleared. Child feels proud of each new number.
- **LLM Automation:** Manages difficulty tier unlock state, applies scaling factors per tier (enemy HP, damage, spawn count, new enemy types), handles difficulty-specific entity spawning, ensures tier N must be beaten to unlock tier N+1, generates appropriate reward scaling, renders difficulty badge on level select, and auto-balances tier jumps for kid players (smaller increments).
- **JSON Contract Extension:**
  ```json
  {
    "progressiveDifficulty": {
      "currentTier": 0,
      "maxUnlockedTier": 0,
      "tierScaling": {
        "0": {"enemyHp": 1.0, "enemyDamage": 1.0, "enemyCount": 1.0, "newEnemies": []},
        "1": {"enemyHp": 1.3, "enemyDamage": 1.2, "enemyCount": 1.2, "newEnemies": ["shield_enemy"]},
        "2": {"enemyHp": 1.6, "enemyDamage": 1.4, "enemyCount": 1.4, "newEnemies": ["mage_enemy"]},
        "3": {"enemyHp": 2.0, "enemyDamage": 1.6, "enemyCount": 1.6, "newEnemies": ["mini_boss"]},
        "4": {"enemyHp": 2.5, "enemyDamage": 2.0, "enemyCount": 2.0, "newEnemies": ["elite_enemy"]}
      },
      "tierBadge": "difficulty_crown",
      "unlockRequirement": "beat_previous_tier",
      "kidModeIncrement": 0.5
    }
  }
  ```

---

### Feature 60: Combo/Hit Streak System

- ** Feature Name:** `HitComboStreak`
- **Source:** Dead Cells (combo meter, healing on kill streaks with certain mutations), Bloodborne (Rally), Celeste (speedrun timing)
- **Description:** A system that rewards continuous successful play. Hitting enemies without taking damage builds a combo counter. Higher combos increase score, may trigger healing (with appropriate badge), and can activate special effects. Taking damage resets the combo. This incentivizes aggressive, skillful play.
- **Kid UX:** A "Combo Counter" appears at the top of the screen: "Hits: 3" with a small flame that gets bigger. At 5 hits, the hero glows. At 10 hits, a "SUPER!" badge flashes. Child stamps a "Combo Prize" stamp that drops when the combo reaches a set number. The LLM auto-tracks and displays the counter with exciting animations.
- **LLM Automation:** Tracks consecutive hits without taking damage, manages combo tier thresholds (5, 10, 15, 20), applies tier effects (glow, healing, damage boost, special drop), resets combo on player damage, renders combo counter UI with escalating intensity, plays combo milestone sounds, and auto-balances combo thresholds for kid players (lower thresholds).
- **JSON Contract Extension:**
  ```json
  {
    "comboSystem": {
      "enabled": true,
      "comboCounter": 0,
      "tierThresholds": {
        "5": {"label": "Nice!", "effect": "player_glow", "heal": 0},
        "10": {"label": "Great!", "effect": "damage_boost_1.2x", "heal": 1},
        "15": {"label": "Amazing!", "effect": "damage_boost_1.5x", "heal": 2},
        "20": {"label": "SUPER!", "effect": "invincibility_burst_3s", "heal": 3}
      },
      "resetOn": ["player_take_damage", "combo_timeout_5s"],
      "counterVisual": "flame_growth",
      "milestoneVfx": "star_burst",
      "timeoutSeconds": 5,
      "kidModeThresholds": [3, 6, 10, 15]
    }
  }
  ```

---

## SECTION 10: Meta-Systems & Editor UX

---

### Feature 61: Stamp-Based Game Creation (Core Editor)

- **Feature Name:** `StampBasedEditor`
- **Source:** Synthesis of all games' level design approaches
- **Description:** The fundamental KidGameMaker paradigm. Everything is placed via stamps on a canvas. Terrain stamps create walkable surfaces. Enemy stamps add opponents. Item stamps add collectibles. Trigger stamps add interactive events. The LLM interprets stamp placement and relationships to generate functional game code invisibly.
- **Kid UX:** Child taps a category tab (World, Enemies, Items, Triggers, Heroes). Each tab shows cartoon stamps. Child taps a stamp, then taps on the canvas to place it. Stamps snap to grid. A long-press on a placed stamp opens its settings (simple toggles and number pickers). Undo button removes last stamp. Shake device to clear all. The canvas auto-zooms to fit the level.
- **LLM Automation:** Converts stamp placements to level geometry data, validates stamp configurations (no floating enemies, no unreachable items), auto-generates missing supporting elements (e.g., places ground under enemy stamps), manages stamp relationship graph (switches linked to doors, levers to bridges), auto-tiles terrain edges, generates collision data, and produces playable game output from stamp configuration.
- **JSON Contract Extension:**
  ```json
  {
    "stampEditor": {
      "stampCategories": ["world", "enemies", "items", "triggers", "heroes", "decorations"],
      "stampPlacement": {"mode": "tap_to_place", "snapToGrid": true, "gridSize": 32},
      "stampConfig": {
        "openMethod": "long_press",
        "settings": ["toggles", "number_picker", "color_picker"]
      },
      "autoValidation": true,
      "autoGenerateSupportingElements": true,
      "undoStackSize": 50,
      "canvasAutoZoom": true,
      "stampRelationshipGraph": true
    }
  }
  ```

---

### Feature 62: Smart Playtesting (AI Child Simulator)

- **Feature Name:** `AIPlaytest`
- **Source:** Dead Cells (extensive playtesting for procedural balance), Celeste (assist mode analytics)
- **Description:** The LLM can simulate playing the child's created level to detect problems: unreachable areas, impossible jumps, enemy placements that are too hard or too easy, soft-locks, and missing checkpoints. It provides gentle suggestions like "Maybe add a rest point here?" or "This jump might be too far for little players."
- **Kid UX:** A "Test It!" button (robot icon) in the editor. Tapping it shows a tiny robot playing the level. The robot leaves a trail showing its path. Green dots = easy, yellow = tricky, red = impossible. A friendly speech bubble says: "I had trouble here, maybe add a platform?" or "This part was super fun!" The child can accept suggestions with one tap.
- **LLM Automation:** Runs pathfinding simulation from start to end, analyzes jump distances vs. player capabilities, detects unreachable collectible placements, evaluates enemy density per screen, identifies missing checkpoint coverage, generates gentle kid-friendly suggestions, renders playtest path visualization, auto-fixes common issues on child approval, and validates level is completable.
- **JSON Contract Extension:**
  ```json
  {
    "aiPlaytest": {
      "simulationSpeed": "fast",
      "testMetrics": [
        "completion_possible",
        "death_estimate",
        "checkpoint_coverage",
        "collectible_reachability",
        "difficulty_curve",
        "soft_lock_risk"
      ],
      "visualization": {
        "pathTrail": true,
        "difficultyHeatmap": true,
        "suggestionBubbles": true
      },
      "suggestionTone": "gentle_encouraging",
      "autoFixOptions": ["add_checkpoint", "add_platform", "reduce_enemies"],
      "kidFriendlyLanguage": true
    }
  }
  ```

---

## Appendix A: Feature Count by Source Game

| Source Game | Features Extracted |
|-------------|-------------------|
| Dark Souls 1/2/3 | 10 (Rest Point, Currency Loss, Illusory Walls, Shortcuts, Fog Gates, NPC Questlines, Flask Heal, Upgrades, Parry, NG+, Messages) |
| Elden Ring | 5 (Spirit Companion, Custom Mix Flask, Weapon Skills, Stealth Crouch, NG+ overlap) |
| Bloodborne | 4 (Trick Weapons, Rally, Chalice Dungeons, overall design philosophy) |
| Hollow Knight | 7 (Badge System, Fog Map, Spells, Fragments, Dream World, Boss Rush, Bench Rest) |
| Celeste | 6 (Air Dash, Wall Jump, Dream Blocks, Strawberries, Assist Mode, B-Sides, Wind/Hazards) |
| Shovel Knight | 5 (Pogo, Relics, Checkpoint Gamble, Destructible Blocks, Multi-Character) |
| Ori Series | 5 (Bash, Ability Tree, Shards, Escape Sequences, Warp Network) |
| Dead Cells | 6 (Mutations, Biome Paths, Cursed Chests, Weapon Affixes, Timed Doors, Boss Cells) |
| Hades | 4 (God Boons, Keepsakes, Progressive Narrative, Heat System) |
| Axiom Verge | 2 (Glitch Gun, Drone Teleport) |
| Cross-Cutting | 10+ (Death Recovery, Chase Sequences, Environmental Hazards, NPC Shops, Combo System, Moving Platforms, Daily Runs, etc.) |

**Total Distinct Feature Ideas: 62**

---

## Appendix B: UX Complexity Tiers

| Tier | Interaction Pattern | Examples | Age Suitability |
|------|-------------------|----------|-----------------|
| 1 | Single stamp placement | Rest points, enemies, items | 4-5 years |
| 2 | Stamp + tap config | Flask charges, fog gates, shops | 5-6 years |
| 3 | Drag to connect | Shortcuts, switches-to-doors, badges-to-slots | 6-7 years |
| 4 | Stamp + menu selection | Relic choice, boon selection, mutations | 7-8 years |
| 5 | Multi-step composition | Custom mix flask, trick weapon modes, dream layers | 8+ years |

All features in this document are designed with Tier 1-3 as the primary interaction, with Tier 4-5 available for advanced users but never required.

---

## Appendix C: LLM Automation Responsibilities Summary

The backend LLM handles the following categories invisibly:

1. **Code Generation:** Converts all stamp placements to executable game logic
2. **Validation:** Ensures levels are completable, fair, and bug-free
3. **Balancing:** Auto-scales difficulty, rewards, and enemy stats for kid players
4. **Content Generation:** Procedural dungeons, B-side remixes, daily challenges, dialogue
5. **State Management:** Saves/loads all progress, inventory, unlocks, and narrative state
6. **Visual Polish:** Auto-generates particles, animations, transitions, and effects
7. **Analytics:** Tracks play patterns to suggest assist mode toggles and difficulty adjustments
8. **Safety:** Filters content, prevents soft-locks, ensures no frustrating dead-ends

---

*Document Version: 1.0*
*Research Scope: 10 landmark games, 62 feature extractions*
*Target Platform: KidGameMaker (ages 5+, zero-code, stamp-based)*
