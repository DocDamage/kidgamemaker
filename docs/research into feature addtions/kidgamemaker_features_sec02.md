# Chapter 2: Combat, Weapons & Boss Design

Combat transforms a traversal sandbox into a living game world. When a 5-year-old places their first enemy stamp and discovers that their hero can defeat it with a satisfying attack, they have learned the fundamental loop of action games: obstacle presents, player responds, reward follows. This chapter catalogs over 35 combat, weapon, and boss design features extracted from decades of design excellence across Zelda, Hollow Knight, Mega Man, Monster Hunter, Street Fighter, Dark Souls, and many more.

Every feature in this chapter has been reimagined for KidGameMaker's stamp-based paradigm. The child places a "Sword" stamp on their hero and the LLM automatically generates hitboxes, combo timings, hit-stop frames, knockback calculations, and death animations. The child stamps a "Boss" and the LLM generates a multi-phase encounter with telegraphed attacks, a dramatic entrance sequence, and appropriate rewards. All complexity is invisible; only the magic of combat is visible on the screen.

---

## 2.1 Melee Combat

### Sword Slash Combo

**Source Game:** Zelda: A Link to the Past (3-hit combo), Hollow Knight (nail strikes), Shovel Knight (shovel swing), Dead Cells

**Description:** A rapid sequence of melee attacks triggered by repeated presses of the attack button. The first swing is a quick horizontal arc, the second follows with a vertical strike, and the third is a powerful finishing move with larger hitbox, more damage, and longer recovery. The combo window — the time between attacks before the combo resets — determines how accessible the system feels. Hollow Knight uses approximately 0.4 seconds between hits; Dead Cells extends this to 0.6 seconds for accessibility.

**Kid UX:** The child stamps a "Sword" item onto the hero. In play, tapping the attack button performs a swing with a satisfying swoosh sound and white trail effect. Three rapid taps produce the full combo — the third hit has a bigger arc and a "POW!" impact effect. The child can configure the combo via stamp toggles: "Quick Swipes" (fast, low damage), "Heavy Strikes" (slow, high damage), or "Balanced." Different weapon stamps (sword, axe, hammer) have different combo timings and visual trails.

**LLM Automation:** Manages combo state machine (hit 1 → hit 2 → hit 3 → reset), validates combo timing window on each attack input, scales damage per combo step (typically 1.0x → 1.2x → 1.8x), generates hitbox shapes per swing arc (horizontal arc, vertical arc, large sweep), applies hit-stop frames on enemy contact (brief 50ms pause for impact feel), manages combo reset timer, and renders attack trail VFX and impact particles.

**JSON Contract Extension:**
```json
{
  "meleeCombo": {
    "maxComboHits": 3,
    "comboWindow": 0.5,
    "damageMultipliers": [1.0, 1.2, 1.8],
    "hitboxShapes": ["horizontal_arc", "vertical_arc", "large_sweep"],
    "hitstopDuration": 0.05,
    "swingSpeeds": [0.25, 0.2, 0.35],
    "knockbackValues": [100, 120, 200],
    "trailVfx": "white_swoosh",
    "impactVfx": "spark_burst",
    "resetOn": ["timeout", "take_damage"]
  }
}
```

### Charge Attack / Spin Attack

**Source Game:** Zelda (spin attack), Shovel Knight (charge slash), Mega Man X (charge shot applied to melee), Castlevania (item crash), Bloodborne (charged heavy attacks)

**Description:** Holding the attack button accumulates charge energy, releasing a powerful area-of-effect attack. The spin attack — a 360-degree circular swing — is the most common implementation, dealing damage to all enemies within radius and often reflecting projectiles. Higher charge levels produce larger hitboxes, more damage, and flashier visual effects.

**Kid UX:** The child stamps a "Spin Attack" ability on the hero. In play, holding the attack button causes the character to glow with an expanding aura (3 charge levels: yellow, orange, red). Releasing performs a spinning attack with expanding ring hitbox. The child can set charge time via toggle: "Quick Spin" (0.5s), "Power Spin" (1.5s), or "Super Spin" (2.5s with screen shake). "Charge Ring" stamps on the ground show AOE range.

**LLM Automation:** Tracks charge button hold duration, updates charge level state (0-3 segments), renders charging visual effects (expanding glow aura, particle gathering), calculates AOE hitbox radius based on charge level, applies damage to all enemies within radius on release, generates spin animation (360-degree rotation over 0.4 seconds), manages hit-stop on each enemy hit, plays escalating charge sound, and generates expanding ring VFX on release.

**JSON Contract Extension:**
```json
{
  "chargeAttack": {
    "chargeLevels": 3,
    "timePerLevel": 0.8,
    "aoeRadius": [60, 100, 160],
    "damagePerLevel": [5, 10, 20],
    "chargeColors": ["#FFD700", "#FF8C00", "#FF0000"],
    "spinDuration": 0.4,
    "screenShakeOnLevel3": true,
    "reflectProjectiles": true,
    "cancelOnDamage": true,
    "chargeVfx": "gathering_sparkles"
  }
}
```

### Counter / Parry

**Source Game:** Dead Cells (shield parry), Street Fighter III (parry), Bloodborne (gun parry), Dark Souls, Hollow Knight

**Description:** Pressing the block button at the exact moment an enemy attack connects triggers a parry — the attack is completely nullified, the enemy is staggered, and the player gets a free counter-attack window. The timing window is typically tight (2-6 frames in competitive games), but for KidGameMaker it is expanded to 0.3-0.5 seconds with clear visual telegraphing.

**Kid UX:** The child stamps a "Shield" or "Parry Gem" on the hero. In play, a "Block" button appears. When an enemy is about to attack, a bright yellow flash appears over the enemy (telegraph). Tapping Block within the flash window triggers a dramatic "CLANG!" parry — the enemy staggers back with dizzy stars, and the hero glows gold for a 2-second counter-attack window. The child can set parry difficulty: "Easy" (0.5s window), "Normal" (0.3s), or "Tricky" (0.15s).

**LLM Automation:** Detects incoming attack from enemies within range, shows telegraphing flash (yellow warning indicator) 0.3s before attack connects, measures block input timing within parry window, nullifies all damage on successful parry, triggers enemy stagger state (2-3 seconds of vulnerability), opens critical hit opportunity window for player (gold glow + 2x damage), plays parry VFX (sparks, screen flash, freeze-frame), and auto-adjusts parry window based on child's performance history.

**JSON Contract Extension:**
```json
{
  "parrySystem": {
    "parryWindow": 0.3,
    "telegraphDuration": 0.3,
    "telegraphColor": "#FFD700",
    "onSuccess": {
      "nullifyDamage": true,
      "enemyStunDuration": 2.5,
      "counterWindow": 3.0,
      "counterDamageMultiplier": 2.0,
      "vfx": "golden_spark_burst",
      "sfx": "clang_parried"
    },
    "onFail": {
      "blockDamageReduction": 0.5,
      "knockback": 50
    },
    "autoAdjustWindow": true,
    "freezeFrameOnParry": 0.1
  }
}
```

### Trick Weapon Transform

**Source Game:** Bloodborne (Threaded Cane, Ludwig's Holy Blade, Hunter Axe)

**Description:** A weapon that transforms between two distinct forms mid-combat with a flourish animation. One form is typically fast and short-ranged (cane mode), while the other is slow but long-ranged (whip mode). The transformation itself can deal damage in a small AOE around the player. This effectively doubles the player's moveset without requiring weapon swapping.

**Kid UX:** The child stamps a "Transformer Weapon" (a sword that extends into a spear). A "Switch" button appears in play. Tapping it triggers a cool transformation flash — the weapon morphs between Mode A (fast swipes) and Mode B (heavy sweeps). Each mode has its own combo string. The child can stamp "Mode A" and "Mode B" labels to customize. The transform deals a small AOE knockback.

**LLM Automation:** Manages two stat profiles per weapon (Mode A: fast/short/low damage, Mode B: slow/long/high damage), handles transform animation and timing (0.5s flourish), applies transform-AOE damage and knockback on switch, generates appropriate hitboxes per mode, saves current mode state, plays unique transform SFX, and ensures both modes have distinct visual silhouettes for clear readability.

**JSON Contract Extension:**
```json
{
  "trickWeapon": {
    "weaponId": "threaded_cane",
    "currentForm": "compact",
    "forms": {
      "compact": {"damage": 8, "speed": 1.4, "range": 50, "hitbox": "short_arc"},
      "extended": {"damage": 16, "speed": 0.7, "range": 120, "hitbox": "long_whip"}
    },
    "transformDamage": 6,
    "transformKnockback": 80,
    "transformVfx": "flash_burst",
    "transformSfx": "mechanical_click",
    "transformTime": 0.5
  }
}
```

### Throw / Grapple Enemies

**Source Game:** Super Mario Bros. 2 (pickup and throw), Kirby (inhale and spit), Donkey Kong Country (barrel throw), Monster Hunter (clutch claw)

**Description:** The player can grab certain enemies or objects, lift them overhead, carry them while moving at reduced speed, and throw them as projectiles. Thrown enemies damage other enemies on contact and can break special blocks. Some implementations allow aiming the throw arc with directional input.

**Kid UX:** The child stamps a "Grabby Hands" ability on the hero. In play, jumping onto or standing next to a grabbable enemy shows a "LIFT" prompt. Tapping it hoists the enemy overhead — the character waddles with reduced speed. Tapping attack throws the enemy in the facing direction. The child can stamp "Fragile Block" walls that shatter when hit by thrown enemies.

**LLM Automation:** Detects grabbable enemies within grab radius, transitions grabbed enemy to carried state (follows player position overhead), applies speed reduction while carrying (typically 50%), handles throw input (applies projectile arc physics to carried enemy), calculates throw damage on impact with other enemies/blocks, generates grab/lift/throw animations, manages enemy-enemy collision damage, and handles thrown enemy destruction on impact.

**JSON Contract Extension:**
```json
{
  "throwEnemy": {
    "grabRadius": 30,
    "carrySpeedMultiplier": 0.5,
    "throwVelocityX": 300,
    "throwVelocityY": -100,
    "throwDamage": 5,
    "enemyOnEnemyDamage": true,
    "breaksFragileBlocks": true,
    "grabVfx": "glow_outline",
    "throwVfx": "spin_trail",
    "maxCarryTime": 5.0
  }
}
```

### Beat-'Em-Up Combo Juggling

**Source Game:** Streets of Rage 4 (juggle combos, wall bounces, combo scoring tiers)

**Description:** Enemies launched into the air can be kept aloft with consecutive hits, creating spectacle and extended combos. Enemies bounce off screen edges (wall bounces) and can be juggled indefinitely with skill. A combo meter tracks consecutive hits with color-coded tiers and escalating announcements.

**Kid UX:** The child stamps a "Brawler Zone" over a level section. Within this zone, combat becomes juggle-friendly. The child can stamp "Wall Bounce" boundary markers. In play, hitting enemies produces satisfying hit-stop pauses. Launched enemies stay airborne longer. A combo counter appears: 5 hits = "Nice!", 10 = "Great!", 20 = "Awesome!", 50+ = "UNBELIEVABLE!" with rainbow text.

**LLM Automation:** Implements hit-stop frames (brief 50ms pause on impact for impact feel), reduces gravity on launched enemies (to 40% of normal), handles wall bounce physics (enemies rebound off screen edges), tracks combo counter (increments on hit, resets on timeout or player damage), manages combo tier thresholds and color progression, applies score multipliers per tier, and ensures juggled enemies don't get stuck off-screen.

**JSON Contract Extension:**
```json
{
  "juggleSystem": {
    "hitstopDuration": 0.05,
    "launchedGravityScale": 0.4,
    "wallBounces": true,
    "comboTiers": [
      {"hits": 5, "label": "Nice!", "color": "#FFFF00", "multiplier": 1.0},
      {"hits": 10, "label": "Great!", "color": "#FFA500", "multiplier": 1.5},
      {"hits": 20, "label": "Awesome!", "color": "#00FF00", "multiplier": 2.0},
      {"hits": 50, "label": "UNBELIEVABLE!", "color": "#FF00FF", "multiplier": 3.0}
    ],
    "comboTimeout": 2.0,
    "scoreMultiplier": "tier_based"
  }
}
```

---

## 2.2 Ranged Combat

### Charge Shot

**Source Game:** Mega Man X (3-level charge), Shovel Knight (relic charge), Metroid (charge beam), Hollow Knight (spell charging)

**Description:** Holding the attack button charges the weapon through 2-3 visual levels before releasing a more powerful projectile. Level 1 = normal single shot. Level 2 = larger projectile with 2x damage. Level 3 = massive beam (or piercing shot) with 4x damage. The charging visual communicates level clearly — color shifts from yellow to orange to red, with particle intensity increasing.

**Kid UX:** The child stamps a "Charge Buster" on the hero. In play, holding attack generates a charging orb that grows and changes color: yellow (level 1), orange (level 2), red (level 3). Releasing fires the appropriately-sized projectile. The child can configure charge time: "Fast Charge" (0.5s per level), "Normal" (1s), or "Slow" (1.5s). A charge meter appears above the hero.

**LLM Automation:** Manages charge level state machine (0→1→2→3 based on hold duration), scales projectile properties by charge level (size, damage, speed, piercing capability), handles charge-cancel conditions (jumping, taking damage, releasing at insufficient charge), renders charging visual effects (growing orb, escalating particles, color shifts), generates appropriate projectile entity on release, and plays charging sound that escalates with level.

**JSON Contract Extension:**
```json
{
  "chargeShot": {
    "levels": [
      {"level": 0, "chargeTime": 0, "damage": 2, "size": 10, "color": "#FFFFFF"},
      {"level": 1, "chargeTime": 0.5, "damage": 4, "size": 20, "color": "#FFFF00"},
      {"level": 2, "chargeTime": 1.5, "damage": 8, "size": 35, "color": "#FF8800"},
      {"level": 3, "chargeTime": 2.5, "damage": 16, "size": 60, "color": "#FF0000", "piercing": true}
    ],
    "cancelActions": ["jump", "hurt", "dash"],
    "particleIntensity": "level_scaled",
    "chargeSfx": "escalating_hum",
    "releaseVfx": "muzzle_flash"
  }
}
```

### Bow & Arrow

**Source Game:** Zelda (bow), Ori (Spirit Arc), Monster Hunter (bow weapon type), Hades (Coronacht bow)

**Description:** A projectile weapon with an arc trajectory affected by gravity. Arrows travel in a parabolic path and can be aimed with directional input. Charging the bow increases arrow speed and range, making the arc flatter. Arrows can be recovered after firing (picking them up from where they landed) to encourage ammo conservation.

**Kid UX:** The child stamps a "Bow" item on the hero. In play, holding the attack button draws the bow back (visual string pull with escalating tension). Aiming is automatic toward the nearest enemy (soft lock-on within 45-degree arc), or can be overridden with directional input. Releasing fires the arrow with a swoosh sound. The child can stamp "Quiver" pickups to grant limited ammo (e.g., 10 arrows). Arrows stick into surfaces and can be picked back up.

**LLM Automation:** Handles bow draw state (hold to charge, release to fire), calculates arrow trajectory with gravity-affected parabolic arc, manages charge level (affects arrow speed and damage), implements soft auto-aim toward nearest enemy within arc, generates arrow entity with appropriate physics, handles arrow sticking into surfaces on impact, enables arrow pickup from stuck arrows, manages ammo count (if limited ammo enabled), and renders bowstring draw animation.

**JSON Contract Extension:**
```json
{
  "bowArrow": {
    "chargeLevels": 3,
    "arrowSpeed": [200, 350, 500],
    "arrowDamage": [2, 4, 8],
    "gravity": 300,
    "maxRange": 400,
    "softLockOn": true,
    "lockAngle": 45,
    "limitedAmmo": true,
    "maxAmmo": 20,
    "recoverable": true,
    "stickInSurfaces": true,
    "drawAnimation": "string_pull",
    "trajectoryPreview": true
  }
}
```

### Magic Projectile

**Source Game:** Final Fantasy (magic spells), Okami (Celestial Brush projectiles), Hollow Knight (spells), Zelda (magic rods), Castlevania (sub-weapons)

**Description:** Auto-aimed or manually aimed projectile attacks that consume a resource (magic/mana/MP). Different spell types have distinct behaviors: fireball (fast, explosive AOE), ice shard (slows enemies), lightning bolt (chains to nearby enemies), and wind gust (pushes enemies back). Magic projectiles typically home toward the nearest target if auto-aim is enabled.

**Kid UX:** The child stamps a "Magic Wand" or "Spell Book" item on the hero. A "Magic Meter" (colored bottle icon) appears on the HUD. The child stamps "Magic Drop" pickups (blue orbs) to refill magic. In play, tapping the spell button fires the currently equipped spell. The child can stamp different "Spell Type" badges: Fireball (red star), Ice (blue snowflake), Lightning (yellow bolt), Wind (green swirl). Each has a unique visual.

**LLM Automation:** Manages magic resource (MP consumption per cast, pickup restoration), handles spell selection and casting, generates projectile entities per spell type (fireball = explosive AOE, ice = slow effect, lightning = chain to nearby, wind = pushback force), implements auto-aim (targets nearest enemy within 60-degree forward arc), manages spell cooldowns, renders spell-specific VFX and SFX, and handles spell upgrade tiers if applicable.

**JSON Contract Extension:**
```json
{
  "magicProjectile": {
    "magicPoolMax": 100,
    "spellTypes": {
      "fireball": {"cost": 10, "damage": 8, "speed": 300, "aoe": 40, "element": "fire"},
      "ice_shard": {"cost": 8, "damage": 4, "speed": 250, "slowDuration": 3, "element": "ice"},
      "lightning": {"cost": 12, "damage": 6, "speed": 500, "chainTargets": 3, "element": "lightning"},
      "wind_gust": {"cost": 6, "damage": 2, "speed": 200, "pushback": 150, "element": "wind"}
    },
    "autoAim": true,
    "autoAimArc": 60,
    "equippedSpell": "fireball",
    "cooldown": 0.5
  }
}
```

### Boomerang

**Source Game:** Zelda (boomerang), Castlevania (cross sub-weapon), Shovel Knight (chaos sphere)

**Description:** A thrown projectile that follows a curved path away from the player, reaches a maximum distance, then curves back to return. If the player moves, the boomerang adjusts its return path to track toward the player's new position. The boomerang can hit enemies both on the way out and on the return trip, and can collect items on its return path.

**Kid UX:** The child stamps a "Boomerang" item on the hero. In play, tapping attack throws a curved projectile that flies outward in an arc, then returns. The boomerang passes through enemies (damaging them) and collects any dropped items on the return trip, pulling them toward the hero. The child can set boomerang behavior: "Straight Return" (comes directly back) or "Homing Return" (tracks hero position).

**LLM Automation:** Generates boomerang entity with elliptical flight path (outward arc then return), manages boomerang state (outbound → turning → inbound → caught), calculates curved trajectory using parametric equations, detects enemy collision on both outbound and inbound paths, enables item collection on return path, adjusts return trajectory based on player movement (homing), generates boomerang spinning visual and whoosh SFX, and handles boomerang catch on return (auto-catch when within radius).

**JSON Contract Extension:**
```json
{
  "boomerang": {
    "maxDistance": 200,
    "flightSpeed": 250,
    "damage": 3,
    "canHitMultiple": true,
    "collectItemsOnReturn": true,
    "itemMagnetRadius": 40,
    "homingReturn": true,
    "autoCatchRadius": 30,
    "spinVfx": "rotating_blur",
    "whooshSfx": "wind_whoosh"
  }
}
```

### Bomb Placement

**Source Game:** Zelda (bombs), Super Mario (Bob-ombs), Mega Man (Bomb Man), Monster Hunter (Barrel Bombs)

**Description:** Placeable explosive objects with a timed fuse. After placement, a bomb counts down (typically 3 seconds, with a blinking visual), then explodes in a circular radius dealing damage to enemies and destroying certain terrain types. Bombs can be placed while moving and will remain at the placement location. Some implementations allow bomb-throwing for ranged placement.

**Kid UX:** The child stamps a "Bomb Bag" item on the hero. A "BOMB" button appears in play with a count (e.g., "10"). Tapping it places a bomb at the hero's feet. The bomb blinks red with escalating speed, then explodes with a fireball effect and screen shake. The child can stamp "Bombable Wall" blocks (cracked appearance) that only shatter from explosions. Bomb refills are stamped as "Bomb Pickup" items.

**LLM Automation:** Manages bomb inventory count, spawns bomb entity at player position on placement input, handles fuse timer (3-second countdown with escalating blink rate), calculates explosion AOE (circular radius, typically 60-80 pixels), applies damage to enemies within radius, destroys bombable terrain blocks within radius, generates explosion VFX (fireball sprite, screen shake, smoke particles), plays fuse tick SFX escalating to explosion sound, and handles chain reactions (bombs exploding other bombs).

**JSON Contract Extension:**
```json
{
  "bomb": {
    "fuseTime": 3.0,
    "explosionRadius": 70,
    "damage": 10,
    "maxInventory": 20,
    "throwable": false,
    "bombableWallTag": "bombable",
    "chainReaction": true,
    "fuseBlinkRate": [1.0, 0.5, 0.25],
    "explosionVfx": "fireball_burst",
    "screenShake": true,
    "smokeDuration": 2.0
  }
}
```

---

## 2.3 Special Moves

### Limit Break / Super Moves

**Source Game:** Final Fantasy VII (Limit Break), Street Fighter (Super Combos), Kingdom Hearts (Limit commands), Hades (Call / Greater Call)

**Description:** A powerful cinematic attack that fills a special gauge through combat actions (dealing damage, taking hits, defeating enemies). When the gauge is full, the player's next attack button press triggers a spectacular, screen-filling super move with invincibility frames. Each character class or weapon type has a unique Limit Break animation and effect.

**Kid UX:** The child stamps a "Power Crystal" on the hero. During play, a colorful gauge fills below the health bar as the hero fights (rainbow energy). When full, the hero flashes gold and a "SUPER!" badge pulses over the attack button. Tapping attack triggers the Limit Break — a massive animated attack (warrior = giant sword swing, mage = screen-filling explosion). The child can pick the Limit Break style from a sticker picker.

**LLM Automation:** Tracks Limit Break gauge fill from damage dealt (10% of damage), damage taken (15% of damage), and enemy defeats (20% per kill), detects when gauge reaches 100%, triggers Limit Break state (gold aura, screen border pulse, "SUPER!" UI), implements unique attack pattern per Limit Break type, applies invincibility during execution, computes AOE damage with appropriate scaling, generates cinematic camera zoom and freeze-frame on activation, and resets gauge to 0 after use.

**JSON Contract Extension:**
```json
{
  "limitBreak": {
    "gaugeMax": 100,
    "fillRate": {
      "dealDamage": 0.1,
      "takeDamage": 0.15,
      "defeatEnemy": 20
    },
    "limitBreaks": {
      "warrior": {"name": "Omnislash", "damage": 50, "duration": 3, "invincible": true},
      "mage": {"name": "Ultima", "damage": 40, "duration": 2.5, "screenFill": true, "invincible": true},
      "thief": {"name": "Shadow Dance", "damage": 30, "duration": 2, "multiHit": 8, "invincible": true}
    },
    "cinematicZoom": true,
    "freezeFrameOnActivate": 0.3,
    "goldAura": true,
    "gaugePersistence": "per_level"
  }
}
```

### Elemental Specials

**Source Game:** Mega Man (elemental boss weapons), Monster Hunter (elemental weapons), Final Fantasy (elemental magic)

**Description:** Special attacks imbued with elemental properties — fire, ice, lightning, earth, wind. Each element produces a distinct status effect on enemies: fire applies a damage-over-time burn, ice freezes enemies solid (they become temporary platforms), lightning chains to nearby targets, earth creates defensive barriers, and wind pushes enemies away.

**Kid UX:** The child stamps an "Element Badge" on the hero and selects an element from a sticker picker: Flame (red), Ice (blue), Lightning (yellow), Earth (green), Wind (cyan). The hero's attacks gain the element's visual effect (fire trails, ice crystals, lightning sparks). The child stamps "Elemental Enemy" variants that show weakness (e.g., a fire enemy melts when hit by ice). "WEAKNESS!" flashes on elemental counter-hits.

**LLM Automation:** Manages elemental state per equipped weapon/ability, applies elemental effects on hit (fire = burn DOT, ice = freeze, lightning = chain, earth = armor break, wind = pushback), maintains elemental weakness chart (fire weak to ice, ice weak to fire, etc.), calculates damage modifiers based on element matchups (2x for weakness, 0.5x for resistance), renders elemental VFX on attacks and impacts, and manages elemental status effect durations.

**JSON Contract Extension:**
```json
{
  "elementalSpecials": {
    "elements": {
      "fire": {"status": "burn", "dotDamage": 2, "dotDuration": 3, "weakTo": "ice", "resists": "fire"},
      "ice": {"status": "freeze", "freezeDuration": 4, "becomesPlatform": true, "weakTo": "fire", "resists": "ice"},
      "lightning": {"status": "shock", "chainRadius": 80, "chainTargets": 3, "weakTo": "earth", "resists": "lightning"},
      "earth": {"status": "armor_break", "defenseReduction": 0.5, "weakTo": "wind", "resists": "earth"},
      "wind": {"status": "pushback", "pushForce": 200, "weakTo": "lightning", "resists": "wind"}
    },
    "weaknessMultiplier": 2.0,
    "resistanceMultiplier": 0.5,
    "visualFeedback": "elemental_burst_text"
  }
}
```

### Celestial Brush

**Source Game:** Okami (Celestial Brush — draw miracles on frozen screen)

**Description:** A drawing-based magic system where time freezes and the player draws simple strokes on the screen to perform miracles. A straight line through an enemy deals instant damage (Power Slash). A circle around a dead plant revives it (Bloom). A filled circle creates an explosive bomb (Cherry Bomb). A spiral creates a wind gust (Galestorm). The brush system transforms combat into a creative, tactile experience.

**Kid UX:** The child stamps a "Brush Goddess" item on the hero. In play, holding the "Brush" button freezes time and turns the screen into a parchment texture. The child draws strokes: straight line = slash attack, circle = revive/bloom, filled circle = bomb, spiral = wind, horizontal line = water spout. Each stroke triggers its miracle with spectacular ink-wash animation. The LLM auto-recognizes strokes.

**LLM Automation:** Implements stroke recognition engine (straight line vs. circle vs. spiral vs. zigzag detection with tolerance thresholds), freezes all game entities on brush activation, detects what the stroke intersects with (enemies, plants, water sources, wind targets), executes corresponding miracle effect, manages ink meter consumption (refills over time), renders ink-wash visual style during brush mode, and tracks which brush techniques have been discovered.

**JSON Contract Extension:**
```json
{
  "celestialBrush": {
    "brushTechniques": [
      {"id": "power_slash", "stroke": "straight_line", "cost": 1, "effect": "damage_line_intersect", "damage": 15},
      {"id": "bloom", "stroke": "circle", "cost": 1, "effect": "revive_plant"},
      {"id": "cherry_bomb", "stroke": "filled_circle", "cost": 3, "effect": "explosion", "damage": 25, "radius": 80},
      {"id": "galestorm", "stroke": "spiral", "cost": 2, "effect": "wind_push", "force": 300},
      {"id": "waterspout", "stroke": "vertical_line", "cost": 2, "effect": "water_geyser", "height": 250}
    ],
    "inkMeterMax": 10,
    "inkRegenRate": 1,
    "timeFreezeDuringBrush": true,
    "strokeTolerance": 20,
    "minStrokeLength": 30,
    "parchmentTint": "#F5DEB3",
    "inkColor": "#000000"
  }
}
```

### Shoryuken-Style Uppercut

**Source Game:** Street Fighter (Shoryuken — Rising Dragon Fist), Smash Bros. (up-special moves), Dead Cells, Hollow Knight (Desolate Dive)

**Description:** An invincible-rise attack where the player launches upward with a powerful strike, gaining both offensive hitboxes and invulnerability frames. The uppercut serves dual purpose — it is both an attack and an aerial recovery tool. On the way up, the hitbox damages and launches enemies. At the peak, the player enters a brief vulnerable state before falling.

**Kid UX:** The child stamps a "Dragon Uppercut" ability on the hero. In play, pressing up + attack performs a rising punch with a dragon-shaped flame trail. The hero is invincible during the rise and damages any enemy in the path. The child can set uppercut height via toggle: "Small Hop" (1 tile), "High Rise" (3 tiles), or "Sky High" (5 tiles). A landing shockwave can be enabled.

**LLM Automation:** Detects up+attack input combination, transitions player to uppercut state (overrides gravity, applies continuous upward velocity), adds damage hitbox along the rising path, grants invincibility frames during ascent, manages vulnerable state at peak (brief window where player can be hit), applies landing shockwave damage on ground contact (if enabled), generates rising trail VFX (dragon shape, flame, or energy depending on visual theme), and plays rising whoosh SFX.

**JSON Contract Extension:**
```json
{
  "shoryuken": {
    "input": "up_plus_attack",
    "riseSpeed": 500,
    "riseDuration": 0.4,
    "damage": 12,
    "invincibleDuringRise": true,
    "vulnerableAtPeak": 0.2,
    "landingShockwave": true,
    "shockwaveRadius": 50,
    "shockwaveDamage": 5,
    "trailVfx": "dragon_flame_rise",
    "riseSfx": "dragon_roar_whoosh"
  }
}
```

### Hadoken / Fireball

**Source Game:** Street Fighter (Hadoken), Mario (fire flower), Mega Man (fire weapons), Zelda (fire rod)

**Description:** A simple, satisfying projectile fired horizontally. The fireball travels in a straight line at moderate speed, dealing damage to the first enemy it contacts and then dissipating. This is the quintessential beginner-friendly ranged attack — aim forward, press button, watch enemy get hit. Multiple fireballs can exist simultaneously.

**Kid UX:** The child stamps a "Fireball Power" on the hero. In play, tapping the attack button launches a fireball in the facing direction. The fireball has a trailing flame effect and explodes on enemy contact with a satisfying "pop." The child can set fireball behavior: "Bounce" (bounces off walls), "Pierce" (goes through enemies), or "Explode" (AOE on impact). A rapid-fire mode can be enabled.

**LLM Automation:** Generates fireball projectile entity on attack input, applies horizontal velocity in facing direction, manages fireball lifetime (auto-destroy after max range or time), detects enemy collision (damage on contact, then destroy or pierce based on mode), generates trail particles (flame/smoke), handles wall collision (bounce or destroy based on mode), manages multi-fireball limits (max 3 on screen simultaneously), and plays launch and impact SFX.

**JSON Contract Extension:**
```json
{
  "fireball": {
    "speed": 300,
    "damage": 3,
    "maxOnScreen": 3,
    "maxRange": 400,
    "mode": "explode|bounce|pierce",
    "aoeRadius": 30,
    "trailVfx": "flame_trail",
    "impactVfx": "fire_pop",
    "rapidFire": false,
    "rapidFireInterval": 0.2,
    "launchSfx": "fire_whoosh",
    "impactSfx": "fire_burst"
  }
}
```

---

## 2.4 Boss Fight Constructor

### Boss Fog Gate

**Source Game:** Dark Souls (fog gates), Hollow Knight (boss arenas), Mega Man (boss room doors)

**Description:** A dramatic entrance to a boss arena — typically a wall of mist, energy, or a sealed door that blocks the entrance. Walking into it triggers a confirmation prompt (or auto-enters after a brief pause), then plays a dramatic entry animation. Once entered, the player cannot retreat until the boss is defeated. The fog gate creates a psychological barrier that signals a major challenge ahead.

**Kid UX:** The child stamps a "Boss Door" (swirling purple/white particles, crown icon above) at a corridor entrance. Tapping it opens a bubble: "Boss Room?" with a crown icon. The LLM auto-generates an arena platform behind it. In play, walking into it plays a "whoosh" and the hero appears in the arena. The child can customize the door appearance: "Misty Gate" (Dark Souls style), "Iron Portcullis" (castle style), or "Magic Barrier" (sparkly style).

**LLM Automation:** Generates enclosed arena geometry behind the fog gate (ensures flat fighting ground, boundary walls), auto-places the stamped boss enemy inside the arena, seals the exit until boss HP reaches 0, triggers boss intro animation on player entry, locks camera to arena bounds (with slight padding), plays victory fanfare and reopens gate on boss defeat, auto-saves pre-boss state for respawn, and handles the entry transition effect (whoosh, fade, or warp).

**JSON Contract Extension:**
```json
{
  "bossFogGate": {
    "gateType": "mist|portcullis|magic_barrier",
    "bossId": "boss_entity_uuid",
    "arenaBounds": {"width": 600, "height": 300, "floorY": 200},
    "sealedUntilDefeat": true,
    "introAnimation": "boss_gate_enter",
    "introDuration": 2.0,
    "cameraLockToArena": true,
    "victoryUnlock": true,
    "victoryFanfare": true,
    "savePreBossState": true,
    "entryTransition": "purple_whoosh"
  }
}
```

### Boss Phases

**Source Game:** Mega Man (bosses change patterns at 50% HP), Hollow Knight (multiple boss phases with visual changes), Dark Souls (phase transitions), Monster Hunter (enraged state)

**Description:** Bosses have multiple behavioral phases triggered at specific HP thresholds. Each phase introduces new attack patterns, changes the boss's visual appearance, and often alters the arena. Phase 1 is typically simple and telegraphed; the final phase is fast and dangerous. The HP threshold for phase changes is typically 66% and 33% for 3-phase bosses, or 50% for 2-phase bosses.

**Kid UX:** The child stamps a "Boss" enemy and taps it to open the phase editor. For each phase, the child stamps attack pattern markers: "Jump Attack", "Projectile Spray", "Charge Rush", "Summon Minions." The child sets HP thresholds via simple sliders: Phase 2 at 50% HP, Phase 3 at 25% HP. Each phase can have a different color glow (Phase 1 = normal, Phase 2 = red aura, Phase 3 = enraged with steam). The LLM auto-generates appropriate telegraph animations for each attack.

**LLM Automation:** Tracks boss HP and monitors phase transition thresholds, manages phase state machine (Phase 1 → Phase 2 → Phase 3), applies phase-specific attack pattern changes (different cooldowns, different projectile counts, different movement speeds), renders phase transition VFX (color shift, aura change, steam/energy effects), modifies boss sprite/animations per phase, adjusts arena hazards per phase (e.g., floor becomes lava in Phase 3), and triggers phase transition invulnerability frames.

**JSON Contract Extension:**
```json
{
  "bossPhases": {
    "phases": [
      {
        "phase": 1,
        "hpThreshold": 1.0,
        "attacks": ["slow_projectile", "jump_slam"],
        "moveSpeed": 80,
        "auraColor": "#FFFFFF"
      },
      {
        "phase": 2,
        "hpThreshold": 0.5,
        "attacks": ["fast_projectile", "charge_rush", "summon_minions"],
        "moveSpeed": 120,
        "auraColor": "#FF0000",
        "transitionVfx": "red_burst"
      },
      {
        "phase": 3,
        "hpThreshold": 0.25,
        "attacks": ["rapid_projectile", "desperate_charge", "arena_hazard"],
        "moveSpeed": 160,
        "auraColor": "#FF00FF",
        "transitionVfx": "steam_and_lightning"
      }
    ],
    "transitionInvulnerability": 2.0
  }
}
```

### Boss Part Breaking

**Source Game:** Monster Hunter (tail cutting, horn breaking, wing tearing), Dark Souls (boss tail cuts for weapons)

**Description:** Large bosses have multiple destructible body parts (head, wings, tail, horns, armor plates). Dealing concentrated damage to a specific part causes it to break, producing a dramatic break animation, modifying the boss's behavior, and granting bonus rewards. Breaking a tail may disable tail swipe attacks; breaking horns may reduce charge damage. This creates meaningful targeting decisions during combat.

**Kid UX:** The child stamps a "Big Boss" and taps it to open the part editor. Dotted outlines appear around breakable parts: head, wings, tail. The child taps each part to set its HP threshold and break reward. In play, each part shows a small damage indicator when hit. When a part breaks, a dramatic crack animation plays (tail falls off, horn chips, wing tears). The fallen part becomes a collectible item. The child stamps "Target Reticle" indicators to suggest which part to aim for.

**LLM Automation:** Tracks per-part damage independently from main boss HP, triggers break animation when part damage threshold is reached, modifies boss moveset when parts break (e.g., broken tail = no tail swipe attack), spawns severed part as collectible entity, applies part-specific visual damage (cracked horn, torn wing, severed tail), manages break rewards (extra drops, guaranteed rare item), renders target reticle UI for player aim assistance, and ensures break effects persist for the remainder of the fight.

**JSON Contract Extension:**
```json
{
  "bossPartBreak": {
    "parts": [
      {"id": "tail", "hp": 200, "breakVfx": "tail_sever", "behaviorChange": "disable_tail_swipe", "reward": "tail_item"},
      {"id": "left_horn", "hp": 150, "breakVfx": "horn_chip", "behaviorChange": "reduce_charge_damage", "reward": "horn_chip_item"},
      {"id": "wings", "hp": 300, "breakVfx": "wing_tear", "behaviorChange": "reduce_fly_frequency", "reward": "wing_membrane_item"}
    ],
    "showTargetReticle": true,
    "partDamageIndicators": true,
    "spawnCollectibleOnBreak": true,
    "visualDamageProgression": true
  }
}
```

### Boss Weakness Wheel

**Source Game:** Mega Man (rock-paper-scissors boss weapon weaknesses), Monster Hunter (elemental weaknesses)

**Description:** A circular system where each boss is weak to a specific weapon or element obtained from another boss. The weakness relationships form a closed loop: Boss A is weak to Weapon B, Boss B is weak to Weapon C, Boss C is weak to Weapon A. Using the correct weakness weapon deals 3-4x damage and may stun the boss. This creates a discovery and experimentation layer to combat.

**Kid UX:** The child stamps 3+ boss enemies and then stamps "Weakness Link" lines between them. Dragging a line from Boss A to Boss B means "Boss A is weak to Boss B's weapon." A circular weakness wheel diagram auto-generates in the corner showing all relationships with element icons. In play, hitting a boss with its weakness weapon produces a big "WEAKNESS!" flash and the boss takes massive damage with a unique stagger animation.

**LLM Automation:** Validates that weakness chains form a closed cycle (no orphaned bosses, no self-references), computes damage multipliers based on weakness matchups (3.0x for correct weakness, 1.0x for neutral, 0.5x for resistance), generates weakness wheel visualization for player reference, triggers weakness-hit visual feedback (elemental burst, "WEAKNESS!" text, unique stagger animation), manages weapon acquisition from defeated bosses, and auto-suggests balanced weakness wheel layouts.

**JSON Contract Extension:**
```json
{
  "weaknessWheel": {
    "elementalWheel": {
      "fire": {"weakTo": "ice", "resists": "fire"},
      "ice": {"weakTo": "lightning", "resists": "ice"},
      "lightning": {"weakTo": "fire", "resists": "lightning"}
    },
    "bossSpecific": {
      "fire_dragon": {"weakTo": "ice_weapon", "damageMult": 3.0, "staggerOnWeakness": true},
      "ice_golem": {"weakTo": "lightning_weapon", "damageMult": 3.0, "staggerOnWeakness": true},
      "lightning_bird": {"weakTo": "fire_weapon", "damageMult": 3.0, "staggerOnWeakness": true}
    },
    "visualFeedback": "weakness_burst_text",
    "staggerDuration": 2.0
  }
}
```

### Boss Medley Rush

**Source Game:** Mega Man (Boss Rush rooms), Castlevania (Boss Rush modes), Hollow Knight (Pantheon of Hallownest), Street Fighter (Arcade Mode)

**Description:** After completing the main game, a "Boss Rush" challenge unlocks where the player faces all bosses back-to-back with limited or no healing between fights. This is the ultimate test of mastery — the player must defeat every boss they have previously conquered, but without the opportunity to restock or recover. Victory grants a special badge or reward.

**Kid UX:** The child stamps a "Boss Tower" portal in their level. Entering it opens a menu showing all boss stamps in a vertical tower layout. The child selects which bosses to include (tap to toggle). During the rush, a big timer counts up. Between each boss fight, a single "Healing Flower" briefly blooms (restores 2 HP). After the final boss, a "BOSS MASTER" badge appears with completion time.

**LLM Automation:** Sequences boss encounters in the selected order, manages player HP carry-over between fights (resets on death), places single inter-fight healing item (limited duration), tracks completion time, generates "Boss Rush" specific UI (boss queue, timer, healing flower indicator), handles continue-from-current-floor on respawn, scales boss HP slightly downward for kid accessibility (-20%), and generates a victory card with stats and time.

**JSON Contract Extension:**
```json
{
  "bossMedleyRush": {
    "towerId": "boss_tower_1",
    "selectedBosses": ["boss_1", "boss_2", "boss_3", "boss_4", "boss_5"],
    "healBetweenFights": true,
    "healAmount": 2,
    "healFlowerDuration": 5,
    "hpCarryOver": true,
    "timer": true,
    "bossHpScaleForKids": 0.8,
    "continueFromCurrentFloor": true,
    "victoryBadge": "boss_master",
    "victoryCard": {"showTime": true, "showDamageTaken": true, "showHealsUsed": true}
  }
}
```

### Boss Scale & Camera

**Source Game:** Monster Hunter (oversized monster encounters), Shadow of the Colossus, Zelda (giant bosses), Hollow Knight (large bosses like the Radiance)

**Description:** Large bosses require special camera handling — the camera zooms out to frame the entire boss, the player's relative size diminishes, and the boss's attacks have massive hitboxes that require precise positioning. The scale difference creates a David-vs-Goliath feeling that makes victory especially satisfying.

**Kid UX:** The child stamps a "Giant Boss" variant (2x, 3x, or 4x normal size via size toggle). The LLM auto-adjusts the camera: on boss entry, the camera smoothly zooms out to frame both player and boss. The boss's attacks have visible telegraph zones (red warning areas on the ground). The child can stamp "Safe Zone" indicators where the player can hide during big attacks.

**LLM Automation:** Adjusts camera zoom and follow behavior for large boss encounters (zoom out to fit boss in frame, smooth follow with deadzone), scales boss sprite and hitbox proportionally, generates telegraph indicators for large attacks (red warning zones on ground before impact), manages boss attack hitbox scaling (larger but with longer telegraphs for fairness), handles boss death animation with appropriate scale (massive collapse), and adjusts screen shake intensity to match boss size.

**JSON Contract Extension:**
```json
{
  "bossScaleCamera": {
    "bossScale": 3.0,
    "cameraZoom": 0.5,
    "cameraFollowMode": "smooth_follow",
    "cameraDeadzone": 100,
    "telegraphGroundMarkers": true,
    "telegraphDuration": 1.5,
    "attackHitboxScale": 1.5,
    "screenShakeIntensity": 1.5,
    "deathCollapseAnimation": "giant_fall",
    "zoomTransitionDuration": 1.0
  }
}
```

### Boss Health Bar & Name Card

**Source Game:** Dark Souls (boss health bar + name at screen bottom), Monster Hunter (monster HP bar + part break indicators), Hollow Knight (boss mask display)

**Description:** A prominent UI element that appears when entering a boss fight, displaying the boss's name and a large health bar. In many games, the health bar has multiple segments representing different phases. The name card establishes the boss's identity and importance, making the encounter feel cinematic from the first moment.

**Kid UX:** The child stamps a boss and types (or speaks) its name: "DRAGON KING." The LLM auto-generates a dramatic name card that appears on boss entry — the boss's name slides in from the left with a slash sound, and a segmented health bar appears at the top of the screen. The child can customize the name card style: "Dark Fantasy" (gothic text), "Cartoon" (bold colors), or "Pixel" (retro style). Health bar color changes per phase.

**LLM Automation:** Generates boss name card UI on boss encounter start (name slides in with dramatic SFX), renders segmented health bar (each segment represents a phase or 25% HP), updates health bar in real-time as boss takes damage, applies phase-transition visual changes to health bar (color shift, pulse effect), handles boss name card dismiss on defeat (shatters or fades with victory fanfare), supports multiple styles (gothic, cartoon, pixel), and auto-generates dramatic reveal animation.

**JSON Contract Extension:**
```json
{
  "bossHealthBar": {
    "bossName": "Dragon King",
    "nameCardStyle": "gothic|cartoon|pixel",
    "healthSegments": 4,
    "segmentColors": ["#00FF00", "#FFFF00", "#FF8800", "#FF0000"],
    "nameCardAnimation": "slide_from_left",
    "nameCardSfx": "slash_whoosh",
    "dismissOnDefeat": "shatter",
    "showPhaseIndicator": true,
    "position": "top_center",
    "screenShakeOnPhaseChange": true
  }
}
```

---

## 2.5 Weapon System Comparison Tables

### Melee Weapon Types

| Weapon Type | Source Game | Speed | Range | Damage | Special Property | Kid UX Stamp |
|-------------|------------|-------|-------|--------|-----------------|--------------|
| Sword | Zelda, Hollow Knight | Medium | Short | Medium | 3-hit combo | Sword item stamp |
| Axe | Shovel Knight, Monster Hunter | Slow | Medium | High | Shield-breaking | Axe item stamp |
| Hammer | Mario, Shovel Knight | Very Slow | Short | Very High | Ground pound combo | Hammer item stamp |
| Spear | Hollow Knight, Monster Hunter | Medium | Long | Medium | Pierces through enemies | Spear item stamp |
| Whip | Castlevania | Medium | Long | Low | Multi-target arc | Whip item stamp |
| Fists | Street Fighter, Kirby | Fast | Very Short | Low | Rapid combo jabs | Fist item stamp |
| Claws | Monster Hunter, Dead Cells | Very Fast | Short | Medium | Dash-attack lunge | Claw item stamp |
| Scythe | Hollow Knight, Castlevania | Slow | Long | High | Wide sweep arc | Scythe item stamp |

### Ranged Weapon Types

| Weapon Type | Source Game | Projectile | Speed | Ammo | Special Property | Kid UX Stamp |
|-------------|------------|------------|-------|------|-----------------|--------------|
| Bow | Zelda, Ori | Arrow (arc) | Medium | Limited | Recoverable arrows | Bow item stamp |
| Fireball | Mario, Street Fighter | Fireball (straight) | Fast | Infinite | Bounce/Pierce/Explode modes | Fire Power stamp |
| Charge Shot | Mega Man X | Energy beam | Slow | Energy-based | 3 charge levels | Charge Buster stamp |
| Boomerang | Zelda | Curved return | Medium | Infinite | Collects items on return | Boomerang item stamp |
| Magic Spell | FF, Hollow Knight | Elemental orb | Varies | Mana-based | Elemental status effects | Magic Wand stamp |
| Bomb | Zelda, Mega Man | Placed explosive | N/A | Limited | Terrain destruction | Bomb Bag stamp |
| Shuriken | Dead Cells, Ninja games | Star projectile | Fast | Limited | Multi-throw spread | Star item stamp |
| Gun | Mega Man, Cave Story | Bullet (straight) | Very Fast | Energy-based | Rapid fire | Blaster stamp |

### Boss Design Pattern Templates

| Pattern Name | Source Game | Description | Kid UX Implementation |
|-------------|------------|-------------|----------------------|
| The Brawler | Street Fighter | Close-range melee attacks, telegraphed swings | Stamp "Melee Attack" markers |
| The Shooter | Mega Man | Projectile patterns, aimed shots, bullet curtains | Stamp "Projectile Spray" arcs |
| The Summoner | Castlevania | Spawns minions, avoids direct combat | Stamp "Summon Point" markers |
| The Charger | Monster Hunter | Rush attacks, tail swipes, part breaks | Stamp "Charge Lane" indicators |
| The Transformer | Dark Souls | Phase changes with new moveset per phase | Use phase editor with 2-3 phases |
| The Puzzle Boss | Zelda | Requires specific item/weakness to damage | Stamp "Weakness" element badge |
| The Timer Boss | Dead Cells | Escalating difficulty over time | Enable enraged timer toggle |
| The Arena Boss | Hollow Knight | Environmental hazards change the fight | Stamp arena hazard zones |

---

## 2.6 Integration with Movement Systems

The combat system does not exist in isolation from the movement systems described in Chapter 1. The LLM automatically manages the interaction between combat and movement states, creating the fluid feel that defines great action games.

### Combat-Movement State Interactions

**Air Combat:** All melee and ranged attacks can be used mid-air, with modified properties. Aerial attacks typically have slightly reduced damage but grant extended air time (a tiny upward impulse on each swing prevents the player from falling during a combo). The ground pound from Chapter 1 serves as the aerial-to-ground combat transition.

**Dash Attack:** Initiating an attack during a dash produces a dash-attack — a lunging strike with extended range and a brief hitbox extension. This combines the mobility of Chapter 1's dash system with the combat mechanics of this chapter. The dash attack inherits the dash's invincibility frames for the first 50% of its duration.

**Wall Combat:** While wall-clinging (Chapter 1), the player can perform a wall-kick attack — pressing attack during a wall cling launches the player off the wall with a damage hitbox, functioning as both movement and offense simultaneously. This mechanic appears in Hollow Knight (wall-kick nail strike) and is a favorite of advanced players.

**Combo Resets:** Taking damage resets the melee combo counter and cancels any active charge attack. The LLM applies a brief "hurt" state (0.3 seconds of invulnerability with a knockback impulse) before returning control to the player. This punishment is gentle for kid players — the combo reset is the primary consequence, not massive health loss.

### The Complete Combat-Movement State Machine

```json
{
  "combatMovementIntegration": {
    "aerialAttackProperties": {
      "damageMultiplier": 0.9,
      "airTimeExtension": -30,
      "allowComboInAir": true
    },
    "dashAttack": {
      "enabled": true,
      "rangeExtension": 1.5,
      "inheritsDashIFrames": true,
      "iFrameDuration": 0.08
    },
    "wallKickAttack": {
      "enabled": true,
      "launchVelocityX": 200,
      "launchVelocityY": -150,
      "damage": 5,
      "hitbox": "lunge_arc"
    },
    "hurtState": {
      "duration": 0.3,
      "invincible": true,
      "knockbackVelocity": 150,
      "comboReset": true,
      "chargeCancel": true,
      "flashSprite": true
    },
    "comboTimeout": 0.5,
    "maxComboHits": 3,
    "comboDamageScaling": [1.0, 1.2, 1.8]
  }
}
```

The child never sees this JSON. They place a "Sword" stamp, a "Boss" stamp, and a "Dash Crystal" stamp, and the LLM weaves them into a cohesive combat experience where every system interoperates seamlessly. The sword has a 3-hit combo, the boss reacts with telegraphed attacks, and the dash crystal enables both traversal and combat options. This is the KidGameMaker magic — the creative power of professional game design, accessible to a 5-year-old through stamps, taps, and the invisible intelligence of the LLM.



## 2.7 Additional Combat & Boss Features

### Hit Stop / Hit Pause

**Source Game:** Street Fighter II (pioneered hit-stop), Hollow Knight, Dead Cells, Monster Hunter, virtually all modern action games

**Description:** A brief freeze-frame (typically 2-8 frames, or 30-120 milliseconds) that occurs when an attack connects with an enemy. The game world pauses for a tiny instant, making the impact feel visceral and satisfying. Hit stop is one of the most important tools for making combat feel "punchy" — without it, attacks feel like they pass through enemies without weight.

**Kid UX:** A global setting the child stamps as "Impact Feel" with three options: "Soft" (2-frame pause, gentle), "Punchy" (5-frame pause, satisfying), or "Heavy" (8-frame pause + screen shake, dramatic). No visible UI during play — the child simply experiences attacks feeling more impactful. The LLM auto-adjusts hit stop duration based on attack type (light attacks = shorter, heavy attacks = longer).

**LLM Automation:** Triggers freeze-frame on successful attack-enemy collision, manages hit stop duration based on attack weight (light: 0.03s, medium: 0.06s, heavy: 0.12s), pauses relevant entities (attacker animation, victim animation, particles) while maintaining background animation, scales hit stop with combo count (longer pauses on later combo hits for escalating impact), generates impact flash VFX during hit stop, and ensures hit stop does not affect UI or input responsiveness.

**JSON Contract Extension:**
```json
{
  "hitStop": {
    "enabled": true,
    "baseDuration": 0.05,
    "lightAttackDuration": 0.03,
    "heavyAttackDuration": 0.12,
    "comboScaling": 0.01,
    "impactFlash": true,
    "affectsAttacker": true,
    "affectsVictim": true,
    "affectsBackground": false,
    "maxDuration": 0.15
  }
}
```

### Screen Shake on Impact

**Source Game:** Super Smash Bros., Mega Man X (explosion shake), Hollow Knight, Dead Cells

**Description:** Camera shake that triggers on heavy impacts, explosions, boss landings, and powerful attacks. Screen shake intensity scales with the impact force — a light hit produces a subtle tremor, while a boss's ground-pound creates a violent shake that communicates the attack's danger. Well-tuned screen shake makes combat feel physical without disorienting the player.

**Kid UX:** The child stamps a "Camera Shake" global setting with three presets: "Gentle" (subtle tremors, kid-friendly), "Cinematic" (moderate shake for drama), or "Intense" (violent shake for spectacle). The child can also stamp "Shake Trigger" zones on specific events (boss landings, bomb explosions). In play, heavy impacts trigger satisfying camera rumbles.

**LLM Automation:** Triggers camera offset displacement on configured events (heavy hits, explosions, boss impacts), manages shake intensity and duration (scales with impact force: light = 2px/0.1s, heavy = 8px/0.3s, boss = 15px/0.5s), applies shake decay (smooth falloff from peak to zero), ensures shake never displaces camera beyond viewport bounds, handles shake combination (multiple overlapping shakes sum intensity), and provides accessibility toggle to disable shake for motion-sensitive players.

**JSON Contract Extension:**
```json
{
  "screenShake": {
    "enabled": true,
    "intensityScale": 1.0,
    "lightHit": {"amplitude": 2, "duration": 0.1},
    "heavyHit": {"amplitude": 8, "duration": 0.3},
    "bossImpact": {"amplitude": 15, "duration": 0.5},
    "explosion": {"amplitude": 10, "duration": 0.4},
    "decayCurve": "exponential",
    "maxCumulativeAmplitude": 20,
    "accessibilityDisable": true
  }
}
```

### Invincibility Frames (i-Frames)

**Source Game:** Dark Souls, Hollow Knight, Mega Man, virtually all action games

**Description:** A brief period of complete invulnerability that triggers when the player takes damage, performs a dodge/dash, or uses certain special moves. During i-frames, the player's sprite typically flashes to communicate the invulnerable state. I-frames prevent the player from being stun-locked by rapid enemy attacks and reward well-timed defensive actions.

**Kid UX:** Enabled globally on the hero. When the hero takes damage, they flash white and become briefly invincible — enemy attacks pass through harmlessly. The child can set i-frame duration via stamp toggle: "Brief" (0.5s, challenging), "Normal" (1.0s, standard), or "Long" (1.5s, forgiving). A "Dash i-Frames" option extends invulnerability to the entire dash duration.

**LLM Automation:** Applies invulnerability flag on damage taken (prevents further damage and knockback), renders i-frame visual feedback (sprite flashing at 10Hz, semi-transparency), manages i-frame duration timer, cancels i-frames if player performs an attack (in some implementations), stacks with dash i-frames if both are enabled, ensures enemy projectiles pass through player during i-frames without triggering collision, and handles boss-specific i-frame interactions (some attacks pierce i-frames).

**JSON Contract Extension:**
```json
{
  "invincibilityFrames": {
    "onDamageDuration": 1.0,
    "onDashDuration": 0.1,
    "onSpecialMoveDuration": 0.5,
    "visualFlashRate": 10,
    "visualAlpha": 0.7,
    "cancelOnAttack": false,
    "spriteFlash": true,
    "passThroughProjectiles": true,
    "bossPierce": false
  }
}
```

### Damage Type System

**Source Game:** Monster Hunter (cutting/impact/pierce), Hollow Knight (nail arts), Dark Souls (damage types), Castlevania

**Description:** Attacks are categorized by damage type: Cutting (swords, claws), Impact (hammers, fists), and Piercing (spears, arrows). Different enemy types have resistances and weaknesses to specific damage types. A rock-hard enemy might resist cutting but be vulnerable to impact; a flying enemy might resist impact but be vulnerable to piercing. This creates weapon-choice strategy.

**Kid UX:** The child stamps enemies and taps them to set resistance icons: a shield with a sword (cutting resistance), a shield with a hammer (impact resistance), or a shield with an arrow (piercing resistance). When the player attacks with a matching weapon type, "RESIST!" appears with reduced damage numbers. When hitting a weakness, "WEAK!" appears with bonus damage. The child can also set weapon damage types on hero equipment stamps.

**LLM Automation:** Maintains damage type definitions (cutting, impact, piercing, elemental), manages enemy resistance table (each enemy has modifiers per damage type), calculates final damage (base damage × type modifier × weakness multiplier), generates appropriate hit feedback text ("RESIST!", "WEAK!", "NORMAL"), renders damage number colors by effectiveness (gray = resist, white = normal, yellow = weak, red = critical), and handles armor/defense calculations per damage type.

**JSON Contract Extension:**
```json
{
  "damageTypes": {
    "types": ["cutting", "impact", "piercing"],
    "enemyResistances": {
      "rock_golem": {"cutting": 0.3, "impact": 1.5, "piercing": 0.8},
      "flying_bat": {"cutting": 1.0, "impact": 0.5, "piercing": 1.5},
      "soft_slime": {"cutting": 1.2, "impact": 0.8, "piercing": 0.8}
    },
    "feedbackText": true,
    "damageNumberColors": {
      "resist": "#888888",
      "normal": "#FFFFFF",
      "weak": "#FFD700",
      "critical": "#FF0000"
    }
  }
}
```

### Weapon Upgrade Anvil

**Source Game:** Dark Souls (blacksmiths), Monster Hunter (upgrade tree), Shovel Knight (Chester's shop), Zelda (fairy fountains)

**Description:** A stationary object where the player can spend collected materials to upgrade their weapon's damage, add elemental properties, or increase attack speed. Upgrades are permanent for the current run/level and provide visible changes to the weapon's appearance (glow effects, size increases, particle trails).

**Kid UX:** The child stamps an "Upgrade Anvil" (glowing anvil with sparkles) in their level. Tapping it opens a simple upgrade screen: "Make Stronger" (costs 10 gems, +2 damage), "Add Fire" (costs 20 gems, fire element), "Make Faster" (costs 15 gems, +20% speed). Costs are paid from collected currency. The weapon visually upgrades with each tier — glowing aura, flame trails, etc.

**LLM Automation:** Manages upgrade currency validation (checks player has sufficient gems/materials), applies weapon stat upgrades on purchase (damage, speed, element), generates weapon visual evolution per upgrade tier (Tier 1 = iron glow, Tier 2 = golden aura, Tier 3 = elemental trails), handles upgrade persistence (weapons stay upgraded for the level/run), plays upgrade animation (hammer strike + sparkle burst), manages upgrade cost scaling (each subsequent upgrade costs more), and prevents re-purchasing the same upgrade.

**JSON Contract Extension:**
```json
{
  "weaponUpgrade": {
    "anvilPosition": {"x": 500, "y": 300},
    "upgradeTiers": [
      {"tier": 1, "cost": 10, "damageBonus": 2, "visual": "iron_glow"},
      {"tier": 2, "cost": 25, "damageBonus": 5, "speedBonus": 0.1, "visual": "golden_aura"},
      {"tier": 3, "cost": 50, "element": "fire", "damageBonus": 8, "visual": "flame_trail"}
    ],
    "currencyType": "gems",
    "upgradeAnimation": "hammer_sparkle",
    "visualEvolution": true,
    "maxTier": 3
  }
}
```

### Enemy Drop Table

**Source Game:** Castlevania (enemy-specific drops), Monster Hunter (carves and rewards), Dark Souls (soul drops), Diablo

**Description:** Each enemy type has a defined loot table — a list of items that can drop on defeat, each with its own probability. Common drops include currency and healing items; rare drops include weapons, upgrade materials, and collectibles. The drop table system makes enemy encounters more rewarding and encourages farming specific enemies for desired items.

**Kid UX:** The child stamps an enemy and taps a "Treasure Bag" icon that appears above it. A simple drop table editor opens with three slots: Common (big bag, 70% chance), Uncommon (sparkly bag, 25% chance), and Rare (rainbow bag, 5% chance). The child drags item stamps into each slot. In play, defeated enemies drop the appropriate item with a satisfying bounce animation. Rare drops have a golden glow and fanfare sound.

**LLM Automation:** Manages per-enemy drop table definitions (common/uncommon/rare slots with probabilities), rolls RNG on enemy defeat to determine drops, applies luck stat modifiers to drop rates (if luck system enabled), spawns drop entities with appropriate physics (bounce, then magnetize toward player), generates drop rarity VFX (common = no glow, uncommon = silver sparkle, rare = golden glow + fanfare), tracks drop history per session, and handles guaranteed first-drop logic (first kill always drops at least uncommon).

**JSON Contract Extension:**
```json
{
  "enemyDropTable": {
    "drops": {
      "goblin": {
        "common": {"item": "small_coin", "chance": 0.70, "quantity": [1, 3]},
        "uncommon": {"item": "health_potion", "chance": 0.25, "quantity": 1},
        "rare": {"item": "goblin_dagger", "chance": 0.05, "quantity": 1}
      }
    },
    "rarityVfx": {
      "common": "none",
      "uncommon": "silver_sparkle",
      "rare": "golden_glow_fanfare"
    },
    "magnetizeToPlayer": true,
    "guaranteeFirstDrop": true,
    "luckStatModifier": 0.01
  }
}
```

### Status Effect Infliction

**Source Game:** Final Fantasy (status spells), Monster Hunter (elemental blights), Hollow Knight (infection), Dark Souls (toxic, bleed)

**Description:** Attacks can inflict persistent status effects that alter enemy behavior over time. Poison deals damage over time; Burn deals damage and reduces attack power; Freeze immobilizes; Sleep disables the enemy until woken; Confusion causes enemies to attack each other. Status effects add strategic depth beyond raw damage.

**Kid UX:** The child stamps "Status Infliction" badges on weapons or hero abilities: Poison Badge (green skull), Burn Badge (red flame), Freeze Badge (blue crystal), Sleep Badge (purple Zzz), Confusion Badge (yellow swirl). When the player hits an enemy, a chance exists to apply the status. Inflicted enemies show the status icon above their heads and exhibit altered behavior.

**LLM Automation:** Manages status effect definitions (poison = DOT, burn = DOT + attack down, freeze = immobilize, sleep = disable AI, confuse = retarget to other enemies), calculates infliction chance per hit (typically 20-30%), applies status effects to enemy state machine, renders status icons above affected enemies, manages status durations and tick rates (poison ticks every 1s for 5s), handles status interactions (burn melts freeze, poison + burn = toxic for extra damage), and generates status-specific VFX (green bubbles for poison, orange flames for burn).

**JSON Contract Extension:**
```json
{
  "statusEffects": {
    "effects": {
      "poison": {"tickDamage": 2, "tickInterval": 1.0, "duration": 5.0, "inflictChance": 0.25, "visual": "green_bubbles"},
      "burn": {"tickDamage": 3, "attackReduction": 0.3, "duration": 4.0, "inflictChance": 0.20, "visual": "orange_flames"},
      "freeze": {"immobilize": true, "duration": 3.0, "inflictChance": 0.15, "visual": "ice_crystal", "shatterBonusDamage": 10},
      "sleep": {"disableAI": true, "duration": 6.0, "inflictChance": 0.20, "visual": "zzz_particles", "wakeOnDamage": true},
      "confuse": {"retargetToAllies": true, "duration": 4.0, "inflictChance": 0.15, "visual": "star_swirl"}
    },
    "stackRules": "replace_same",
    "combos": {"poison+burn": "toxic", "burn+freeze": "melt"}
  }
}
```

### Weapon Switching / Dual Wield

**Source Game:** Devil May Cry (style switching), Dark Souls (weapon swapping), Dead Cells (two-weapon system), Mega Man (weapon wheel)

**Description:** The player can equip two (or more) weapons simultaneously and switch between them during combat. Each weapon has its own combo string and special properties. Switching weapons mid-combo can create hybrid combos that blend moves from both weapons. Some systems allow true dual-wielding where both weapons attack simultaneously.

**Kid UX:** The child stamps two weapon items on the hero (primary and secondary). In play, a "SWITCH" button appears. Tapping it swaps between weapons with a quick flourish animation. The child can enable "Dual Wield" mode where both weapons attack simultaneously (one in each hand) with combined damage but reduced speed. A small weapon icon in the corner shows the currently equipped weapon.

**LLM Automation:** Manages weapon inventory (primary slot, secondary slot), handles weapon switch input (tap switch button), applies weapon-specific stats and hitboxes on switch, generates switch animation (flourish, brief pause), supports dual-wield mode (combined damage, modified animation, both weapons visible), manages hybrid combos (attack 1 with weapon A, switch, attack 2 with weapon B = unique combo), and renders equipped weapon sprite on player character.

**JSON Contract Extension:**
```json
{
  "weaponSwitch": {
    "maxWeapons": 2,
    "switchAnimation": "flourish",
    "switchTime": 0.2,
    "dualWield": false,
    "dualWieldDamageMultiplier": 1.5,
    "dualWieldSpeedMultiplier": 0.8,
    "hybridCombos": true,
    "hybridComboBonus": 1.2,
    "weaponIcons": true,
    "switchButton": "Y_or_triangle"
  }
}
```

### Skill Gem / Materia Socketing

**Source Game:** Final Fantasy VII (Materia system), Diablo (gem socketing), Path of Exile (skill gems), Kingdom Hearts (ability equips)

**Description:** Weapons and armor have socket slots where the player can insert gems or orbs that grant new abilities, passive bonuses, or elemental properties. Socketed gems can be swapped at any time, encouraging experimentation. Combining different gems in linked sockets creates synergy bonuses.

**Kid UX:** The child stamps a weapon with visible socket circles (1-3 sockets). The child then stamps "Skill Gems" (colored orbs): Red Gem = fire damage, Blue Gem = ice damage, Green Gem = poison damage, Yellow Gem = speed boost, Purple Gem = lifesteal. Dragging a gem into a socket equips it. Linked sockets (shown with glowing chains between them) create combo bonuses. Tapping a socketed gem removes it.

**LLM Automation:** Manages socket slots per weapon (1-3 sockets, visually represented), handles gem insertion/removal via drag-and-drop, applies gem effects to weapon stats (fire gem = +fire damage + burn chance), calculates socket link bonuses (two linked gems of same element = enhanced effect), generates gem VFX on weapon (flame for fire gem, frost for ice gem), manages gem inventory, and validates gem-weapon compatibility.

**JSON Contract Extension:**
```json
{
  "skillGem": {
    "socketCount": 3,
    "gemTypes": {
      "red_fire": {"damageBonus": 5, "element": "fire", "burnChance": 0.2},
      "blue_ice": {"damageBonus": 3, "element": "ice", "freezeChance": 0.15},
      "green_poison": {"damageBonus": 4, "element": "poison", "poisonChance": 0.25},
      "yellow_speed": {"speedBonus": 0.2, "attackSpeed": 1.2},
      "purple_lifesteal": {"lifestealPercent": 0.1}
    },
    "linkBonuses": {
      "same_element_linked": 1.5,
      "triple_same": 2.0
    },
    "socketLinkVisual": "glowing_chain",
    "gemVfxOnWeapon": true
  }
}
```

### Summon Ally / Call for Help

**Source Game:** Final Fantasy (summons), Elden Ring (Spirit Ashes), Castlevania (familiars), Hades (companion keepsakes)

**Description:** The player can summon a temporary AI-controlled ally to fight alongside them. Summoned allies have their own attacks, health bars, and behavior patterns. They typically persist for a limited duration or until defeated. Summons provide distraction, additional damage, and support abilities (healing, buffs).

**Kid UX:** The child stamps a "Summon Bell" item on the hero. In play, a "CALL" button appears with a cooldown ring. Tapping it summons an ally (wolf, fairy, knight, ghost) with a sparkle poof. The ally auto-attacks enemies and follows the player. A small health bar appears above the ally. The child can pick the ally type from a sticker picker: "Wolf" (melee attacker), "Fairy" (healer), "Knight" (tank), "Ghost" (ranged magic).

**LLM Automation:** Spawns ally entity on summon input, applies AI behavior profile per ally type (wolf = melee aggressive, fairy = heal player when HP low, knight = tank and draw aggro, ghost = ranged spell attacks), manages ally duration (typically 30 seconds) or HP-based persistence, handles ally death (despawn with fade), manages summon cooldown (typically 60 seconds), renders ally health bar and status indicators, and generates summon/despawn VFX (sparkle poof in/out).

**JSON Contract Extension:**
```json
{
  "summonAlly": {
    "allyTypes": {
      "wolf": {"hp": 30, "damage": 5, "behavior": "melee_aggressive", "speed": 120},
      "fairy": {"hp": 15, "healAmount": 5, "behavior": "heal_support", "healTrigger": "player_hp_below_50%"},
      "knight": {"hp": 60, "damage": 3, "behavior": "tank_draw_aggro", "defense": 3},
      "ghost": {"hp": 20, "damage": 8, "behavior": "ranged_spell", "range": 150}
    },
    "duration": 30,
    "cooldown": 60,
    "maxAllies": 1,
    "summonVfx": "sparkle_poof",
    "despawnVfx": "sparkle_fade",
    "showAllyHealthBar": true
  }
}
```

### Guard / Block Stance

**Source Game:** Dark Souls (shield block), Monster Hunter (guard), Zelda (shield), Street Fighter (block)

**Description:** Holding a block button raises a defensive stance or shield that reduces incoming damage from the facing direction. Blocking consumes stamina (or has a durability limit) and reduces movement speed. Well-timed blocks can lead into parries (see Counter/Parry feature above). Some attacks are unblockable and must be dodged instead.

**Kid UX:** The child stamps a "Shield" item on the hero. In play, holding the block button raises the shield — the character adopts a defensive stance with reduced movement. A "Shield Bar" appears and depletes as damage is blocked. The shield has directional coverage (frontal only). The child can stamp "Unblockable Attack" markers on certain enemy attacks (red glow indicates dodge-only).

**LLM Automation:** Detects block input (hold), reduces player movement speed while blocking (typically 30% of normal), applies directional damage reduction from front-facing attacks (typically 80-100% damage nullified), manages shield stamina/bar depletion (depletes based on blocked damage), handles unblockable attacks (red glow warning, damage bypasses block), generates block VFX (shield glow, impact sparks on successful block), and manages guard-break state (shield bar depleted = stagger).

**JSON Contract Extension:**
```json
{
  "blockGuard": {
    "movementSpeedWhileBlocking": 0.3,
    "damageReduction": 0.9,
    "shieldBarMax": 50,
    "shieldDepletionPerDamage": 1,
    "shieldRegenRate": 5,
    "blockAngle": 120,
    "unblockableWarning": true,
    "unblockableColor": "#FF0000",
    "blockVfx": "shield_glow_impact_sparks",
    "guardBreakStunDuration": 1.5
  }
}
```

### Reflect Projectiles

**Source Game:** Zelda (shield reflect), Dark Souls (parry reflect), Mega Man (shield weapons), Hollow Knight (Dreamshield)

**Description:** A defensive mechanic where perfectly timed blocks or dedicated reflect abilities send enemy projectiles back at the attacker. Reflected projectiles retain their damage properties but become player-aligned, damaging enemies instead. Some projectiles are designated as "reflectable" while others (typically boss mega-attacks) cannot be reflected.

**Kid UX:** The child stamps a "Reflect Badge" on the hero or equips a reflect shield. In play, pressing block at the exact moment a projectile hits sends it flying back with a "BING!" sound and a bright flash. The reflected projectile leaves a rainbow trail. The child can stamp "Reflectable" and "Unreflectable" markers on enemy projectiles. Reflected projectiles that hit enemies deal 2x damage.

**LLM Automation:** Detects projectile-block collision timing (frame-perfect or small window), validates projectile is reflectable (checks reflectable tag), reverses projectile velocity vector on successful reflect, changes projectile alignment from enemy to player, applies damage multiplier to reflected projectile (typically 2.0x), generates reflect VFX (bright flash, rainbow trail, "BING!" sound), manages reflect timing window (0.1-0.2 seconds), and handles special reflect interactions (some projectiles split into multiple on reflect).

**JSON Contract Extension:**
```json
{
  "reflectProjectiles": {
    "timingWindow": 0.15,
    "damageMultiplier": 2.0,
    "trailColor": "rainbow",
    "reflectSfx": "bright_bing",
    "reflectVfx": "flash_rainbow_trail",
    "onlyReflectableTag": true,
    "velocityReverse": true,
    "alignmentSwitch": true,
    "specialSplitOnReflect": false
  }
}
```

### Finishing Move / Takedown

**Source Game:** God of War (takedowns), Doom (glory kills), Dead Cells, Hollow Knight (nail art finishers), Mortal Kombat (fatalities, kid-friendly version)

**Description:** A dramatic, cinematic attack performed on a low-health enemy that instantly defeats them with a spectacular animation. Finishing moves trigger when an enemy's HP falls below a threshold (typically 20-25%). The player must press a specific button within range to initiate the takedown. During the animation, both player and enemy are invincible.

**Kid UX:** The child stamps a "Takedown" ability on the hero. In play, when an enemy drops below 25% HP, a "FINISH!" prompt appears above them with a button icon. Tapping the button triggers a dramatic takedown animation — the hero performs a cool finishing strike while the enemy flashes and dissolves with particle effects. No blood; enemies dissolve into sparkles, stars, or confetti. The child can pick takedown style from stickers.

**LLM Automation:** Monitors enemy HP for takedown threshold (typically 25%), displays "FINISH!" prompt with button icon when threshold reached, validates player proximity on takedown input (must be within melee range), triggers cinematic takedown animation (both entities locked, invincible), instant-kills the enemy on animation completion, generates spectacular dissolution VFX (sparkles, stars, confetti — kid-friendly), grants bonus rewards for takedown kills (extra currency, health drop), and manages takedown animation duration (1-2 seconds).

**JSON Contract Extension:**
```json
{
  "finishingMove": {
    "hpThreshold": 0.25,
    "proximityRadius": 40,
    "input": "action_button",
    "animationDuration": 1.5,
    "invincibleDuring": true,
    "instantKill": true,
    "dissolutionVfx": "sparkle_confetti_burst",
    "bonusReward": {"currency": 10, "healthDropChance": 0.5},
    "promptText": "FINISH!",
    "promptColor": "#FFD700"
  }
}
```

### AOE Attack Indicator

**Source Game:** League of Legends (skillshot indicators), Monster Hunter (attack warnings), Dark Souls (AOE markers), most modern action games

**Description:** Visual ground markers that show the area of effect for attacks — both player special moves and enemy attacks. Red warning zones appear on the ground before an enemy's AOE attack lands, giving the player time to dodge. Player AOE indicators (when charging a spin attack, for example) show friendly targeting zones.

**Kid UX:** A global setting the child stamps as "Attack Warnings." When enabled, enemy AOE attacks show red warning circles/zones on the ground before impact. Player AOE attacks show blue targeting indicators while charging. The child can set warning duration: "Quick" (0.5s, challenging), "Normal" (1.0s), or "Generous" (1.5s, forgiving). Warning shapes include circles, cones, and lines.

**LLM Automation:** Generates AOE warning indicators for telegraphed attacks (red zones for enemies, blue for player), manages warning duration before attack impact, supports multiple warning shapes (circle = radial AOE, cone = directional, line = beam), fades warning from transparent to opaque as impact approaches, handles player dodge validation (was player outside zone on impact?), and ensures warnings are visually clear but don't obscure gameplay.

**JSON Contract Extension:**
```json
{
  "aoeIndicator": {
    "enemyWarningColor": "#FF0000",
    "playerTargetingColor": "#0088FF",
    "warningDuration": 1.0,
    "shapes": ["circle", "cone", "line", "rectangle"],
    "fadeInAsImpactApproaches": true,
    "transparency": 0.4,
    "borderHighlight": true,
    "appliesTo": ["enemy_aoe", "player_charged_aoe", "boss_attacks"]
  }
}
```

### Combo Counter UI

**Source Game:** Devil May Cry (style ranking), Streets of Rage (combo counter), Dead Cells, Monster Hunter

**Description:** A prominent on-screen display that tracks consecutive hits without taking damage. The counter escalates through named tiers (D → C → B → A → S → SS → SSS) with corresponding visual flair. Higher combos award score multipliers and can trigger special bonuses (healing on extended combos, damage boosts, etc.).

**Kid UX:** A "Combo Counter" appears at the top of the screen during combat. It starts as a small number and grows with each hit. At 5 hits: "Nice!" in yellow. 10 hits: "Great!" in orange. 20 hits: "Awesome!" in green. 50+ hits: "LEGENDARY!" in rainbow with screen effects. The child can stamp "Combo Prize" chests that unlock when the combo counter reaches a set number. The combo timer (time before reset) is shown as a shrinking ring.

**LLM Automation:** Tracks consecutive hits on enemies without player taking damage, manages combo tier thresholds and labels, renders combo counter UI with escalating size and color, handles combo timeout (resets after 2-3 seconds without a hit), applies tier-based score multipliers, triggers tier announcement text ("Nice!", "Great!", "Awesome!", "LEGENDARY!"), manages combo prize unlocks at threshold combos, and resets combo on player damage or timeout.

**JSON Contract Extension:**
```json
{
  "comboCounter": {
    "timeout": 2.5,
    "tiers": [
      {"hits": 5, "label": "Nice!", "color": "#FFFF00", "multiplier": 1.0},
      {"hits": 10, "label": "Great!", "color": "#FFA500", "multiplier": 1.2},
      {"hits": 20, "label": "Awesome!", "color": "#00FF00", "multiplier": 1.5},
      {"hits": 50, "label": "LEGENDARY!", "color": "rainbow", "multiplier": 2.0}
    ],
    "visual": "growing_number_with_flame",
    "timeoutRing": true,
    "announcementText": true,
    "resetOn": ["player_take_damage", "combo_timeout"]
  }
}
```

### Death / Respawn Mechanics

**Source Game:** Dark Souls (bonfire respawn), Hollow Knight (bench respawn), Celeste (instant restart), Shovel Knight (checkpoint respawn)

**Description:** The system that handles player defeat — where they respawn, what they retain, and what consequences (if any) apply. KidGameMaker uses a gentle approach: the player respawns at the last checkpoint/rest point with no penalty. A "Ghost Run" system shows the player's previous death location as a cute ghost that can be touched to recover a small reward.

**Kid UX:** The child stamps "Checkpoint" flags (fluttering flagpoles) throughout the level. The hero respawns at the last touched checkpoint on defeat. A brief "Oops!" animation plays (character sits up, rubs head, dusts off). The child can stamp "Death Ghosts" — a cute translucent ghost of the hero appears at each death spot. Touching the ghost gives 1 bonus coin and makes it wave happily before disappearing.

**LLM Automation:** Manages checkpoint activation (player touches flag → becomes active respawn point), handles death sequence (brief pause, "Oops!" animation, fade to checkpoint), spawns death ghost at death coordinates (cute translucent sprite that waves), manages ghost collection (touch to get coin, ghost waves and fades), ensures respawn at most recently activated checkpoint, handles checkpoint reachability validation, and generates respawn VFX (character pops in with sparkle).

**JSON Contract Extension:**
```json
{
  "deathRespawn": {
    "respawnAt": "last_checkpoint",
    "deathAnimation": "oops_sit_up",
    "deathDuration": 1.5,
    "fadeToCheckpoint": true,
    "spawnDeathGhost": true,
    "ghostReward": {"coins": 1},
    "ghostVfx": "wave_and_fade",
    "respawnVfx": "sparkle_pop_in",
    "penalty": "none",
    "maxGhostsPerCheckpoint": 1
  }
}
```

