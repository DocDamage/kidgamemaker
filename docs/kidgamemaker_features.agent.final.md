# KidGameMaker: The Ultimate Feature Compendium
## 350+ Ideas from AAA & Indie Studios for the World's Most Magical Kid-Friendly Game Maker

---

# Section 00: Executive Summary

## KidGameMaker Feature Compendium — Executive Summary

---

### 1. The KidGameMaker Vision

**KidGameMaker** is a **kid-friendly**, **zero-code**, **stamp-based** 2D platformer game creation suite designed for children ages 5 and up. At its core is a radical design philosophy: **make the complex invisible**. While professional game engines overwhelm users with toolbars, scripting panels, and asset pipelines, KidGameMaker presents a single, intuitive canvas where children place **visual stamps** — characters, enemies, platforms, power-ups, decorations — by simply dragging and dropping them into their world. Every stamp has built-in behaviors. A "goomba" stamp knows how to walk and turn at ledges. A "coin" stamp knows to spin, glow, and disappear when touched. A "spring" stamp knows to bounce. The child sees magic. Behind the scenes, a **built-in LLM (large language model)** handles all the complexity invisibly — resolving conflicts, generating code, suggesting connections, and adapting behaviors so that kids never encounter a text editor, a syntax error, or a debugging session.

The product architecture is intentionally dual-layered. The **editor** is built with **Svelte** and **Tauri**, delivering a lightweight, cross-platform desktop application with a responsive visual canvas. Games are executed by a **Godot 4 runner**, giving creators access to professional-grade physics, rendering, and audio without any of the associated complexity. The LLM bridge sits between these two layers, interpreting the child's intent (expressed through stamps, voice commands, and natural-language prompts) and translating it into precise game logic inside the Godot runtime.

Our guiding design principle is borrowed from **Shigeru Miyamoto**'s philosophy of **"teach through play"**: every interaction should be discoverable, every result should be immediately visible, and every mistake should be fun. If a 5-year-old can figure it out without reading a manual, we've succeeded.

---

### 2. Research Methodology

This Feature Compendium was constructed through systematic analysis of **more than 30 landmark games** spanning six decades and every major genre, from AAA blockbusters to indie masterpieces to purpose-built kid creation tools. Our research was organized across **six research dimensions**:

| Dimension | Focus | Key Titles Studied |
|---|---|---|
| **Level Design & Mechanics** | Platforming physics, level construction tools, mechanical depth | *Super Mario Maker 2*, *Super Mario Bros. Wonder*, *Celeste*, *Hollow Knight*, *Shovel Knight* |
| **Player Agency & Creation** | User-generated content systems, building mechanics, creative toolsets | *Dragon Quest Builders 2*, *Dreams* (Media Molecule), *Game Builder Garage*, *Bloxels*, *Terraria* |
| **Combat & Progression** | Enemy design, boss encounters, item systems, upgrade trees | *Dark Souls*, *Elden Ring*, *Dead Cells*, *Hades*, *Mega Man*, *Monster Hunter Rise* |
| **Narrative & Worldbuilding** | Story delivery, environmental storytelling, character design | *The Legend of Zelda: Breath of the Wild / Tears of the Kingdom*, *Chrono Trigger*, *Final Fantasy VII*, *Okami*, *Phoenix Wright: Ace Attorney* |
| **AI Systems & Adaptation** | Procedural generation, adaptive difficulty, emergent behavior | *Splatoon 3*, *Animal Crossing: New Horizons*, *Pikmin 4*, *Metroid Dread*, *Axiom Verge* |
| **Accessibility & Voice UX** | Voice control, tactile interfaces, age-appropriate UX, inclusive design | *Kodu Game Lab*, *Scratch Jr*, *Kingdom Hearts* (Command Menu), *Street Fighter VI* (Modern Controls) |

For each title, our team conducted deep mechanical analysis — reverse-engineering player-facing systems, mapping interaction graphs, cataloging emergent behaviors, and identifying which features could be reimagined as **stamp-based, zero-code primitives** suitable for a 5-year-old audience. We paid special attention to features that produce **maximum expressivity from minimum input**, a principle central to the KidGameMaker philosophy.

---

### 3. Document Overview

The KidGameMaker Feature Compendium is organized into **11 chapters**, containing **345+ individual feature ideas**. Each chapter represents a major subsystem of the KidGameMaker platform. Every feature entry includes a title, priority classification (Core / Expansion / Premium), a detailed description, mechanical specification, and cross-references to related features.

| Chapter | Section | Feature Count | Description |
|---|---|---|---|
| **01** | Terrain & Level Geometry | ~35 | Ground types, slopes, one-way platforms, moving platforms, auto-scrolling, destructible terrain, liquids, layered parallax backgrounds |
| **02** | Enemies & Hazards | ~40 | Enemy stamp families (ground, flying, aquatic), patrol patterns, projectile shooters, traps, spawners, hazard interactions |
| **03** | Player Characters & Power-Ups | ~35 | Character stamp templates, movement abilities, transformations, power-up states, multiplayer character variants |
| **04** | Items, Collectibles & Economy | ~30 | Coins, gems, keys, inventory stamps, shop systems, reward loops, combo chains, secret counters |
| **05** | Bosses & Mini-Bosses | ~30 | Boss stamp families, phase transitions, weak-point systems, arena design, pattern-based combat |
| **06** | Physics & Environmental Systems | ~30 | Gravity zones, wind, buoyancy, magnetism, portal mechanics, conveyor belts, switches, pressure plates |
| **07** | Narrative & Dialogue Tools | ~25 | NPC stamps, dialogue trees, quest systems, cutscene triggers, environmental storytelling elements |
| **08** | Audio & Visual Effects | ~30 | Music stamps, sound effect triggers, particle systems, screen effects, animation states, palette swaps |
| **09** | Creation & Publishing Tools | ~40 | Multiplayer editing, template worlds, tutorial systems, sharing/gallery, remix mechanics, version history |
| **10** | **AI & Voice-Assisted Creation** *(Signature Chapter)* | ~35 | **LLM-powered voice commands**, natural-language level generation, auto-balancing, smart enemy placement, AI co-designer, procedural level generation, adaptive difficulty |
| **11** | Accessibility & Inclusivity | ~25 | Colorblind modes, dyslexia-friendly fonts, one-handed controls, screen reader support, parental moderation tools |

Every feature in the compendium has been evaluated against our **Kid-Friendly Design Criteria**: can a 5-year-old understand it within 30 seconds of seeing it? If not, it was either redesigned as a stamp abstraction or reserved for an advanced/parental mode.

---

### 4. Key Highlights

The KidGameMaker platform introduces several features that have no precedent in kid-focused game creation tools. These are our signature innovations:

**Voice-Assisted Level Creation.** A child can speak to KidGameMaker — "add ten bad guys," "make this room really spooky," "give me a boss that shoots fire," — and the LLM interprets the request, selects appropriate stamps, places them intelligently, and configures their behaviors. Voice is not a gimmick; it is a primary input modality. This draws on research from **Splatoon 3**'s lobby communication systems and **Animal Crossing**'s conversational NPC interactions, but applies it to creation rather than gameplay.

**The AI Co-Designer.** When a child builds a level, the AI co-designer watches their progress and makes contextual suggestions — "this section looks hard, want me to add a checkpoint?" or "you placed three springs in a row — want a secret room here?" Inspired by **Media Molecule's Dreams** assistant tools and **Game Builder Garage**'s Nodon's contextual help, the AI co-designer goes further by actively proposing additions based on pattern recognition across the 345-feature library.

**Natural-Language Behavior Editing.** Instead of coding enemy AI or configuring switch logic, a child can describe what they want: "this enemy should get scared when the player is big" or "this door opens when all the coins are collected." The LLM generates the underlying logic and presents the result as a visible, modifiable stamp connection on the canvas. This capability is unique in the kid creation space — no existing tool (Scratch Jr, Bloxels, Kodu, or even Mario Maker 2) allows behavioral modification through plain speech.

**Procedural Fill & Auto-Balance.** The LLM can generate complete platforming sections, background decorations, or enemy encounters based on a single stamp placement or a brief voice description. It can also **auto-balance** difficulty by analyzing playtest telemetry and adjusting enemy placement, checkpoint frequency, and power-up availability. This draws directly on **Celeste's** assist mode philosophy and **Hades'** adaptive difficulty research from Supergiant Games.

**Cross-Game Stamp Ecosystem.** Inspired by **Terraria's** item depth and **Dragon Quest Builders 2's** blueprint system, stamps can be combined in emergent ways that produce behaviors not explicitly programmed. Placing a "magnet" stamp near a "coin" stamp causes automatic attraction. Adding a "fire" stamp to any enemy produces a burning variant. This combinatorial explosion gives 345 features the expressive range of thousands — but every combination is discoverable through play, not documentation.

**Smart Enemy Placement.** Drawing on **FromSoftware's** philosophy of deliberate, environmental enemy positioning (where every enemy placement in *Dark Souls* and *Elden Ring* tells a story), the LLM can analyze a child's level layout and suggest enemy positions that create tension, reward exploration, or teach mechanics. A child stamps "add enemies" and the AI places them with intent — archers on high ground, ambush enemies behind blind corners, patrollers on flat surfaces.

---

### 5. How to Use This Document

This compendium serves as the **single source of truth** for KidGameMaker feature development. It is structured for three audiences:

**For Developers:** Each chapter provides the complete functional specification for its subsystem. Features are tagged with **Core** (must ship in v1.0), **Expansion** (v1.x updates), or **Premium** (post-launch content packs). Cross-references between features indicate dependencies — implement the Core terrain system before moving platforms, for example. The AI/Voice chapter (10) should be read in conjunction with every other chapter, as LLM integration touches all subsystems.

**For Designers:** Feature entries include the *player-facing experience* — what a child sees and does — alongside the *implementation notes*. Pay attention to the **Kid-Friendly Design Criteria** callouts, which flag features requiring special UX attention to remain accessible to the 5+ audience.

**For Stakeholders & Leadership:** Use the chapter summaries at the top of each section for roadmap planning. The feature counts per chapter provide scoping estimates. The Key Highlights section above should inform marketing positioning and competitive differentiation strategy. Note that the **AI & Voice-Assisted Creation** chapter is not a bonus feature — it is the platform's core differentiator and should be resourced accordingly.

This document is a living specification. As research expands and playtesting reveals new insights, features will be added, reprioritized, and refined. The 345+ entries in this compendium represent the foundation of a platform that could redefine what children believe they are capable of creating.

---

*KidGameMaker Feature Compendium v1.0 — 345+ features across 11 chapters, synthesized from 30+ games across Nintendo, FromSoftware, Capcom, Konami, Square Enix, Sega, and the indie community.*


---

# Chapter 1: Core Movement & Traversal

The foundation of every great platformer is how it feels to move. A 5-year-old may not have the vocabulary to describe "coyote time" or "dash i-frames," but they know instantly whether jumping feels good. This chapter catalogs over 40 movement and traversal features extracted from decades of platformer design excellence across Nintendo, Sega, Square Enix, Capcom, Konami, and critically acclaimed indie studios. Each feature has been reimagined for KidGameMaker's stamp-based, zero-code paradigm where a backend LLM handles all physics programming, collision logic, and animation state management invisibly.

The features are organized by thematic category rather than by source game. This grouping reveals how apparently disparate games converge on the same mechanical solutions — wall jumps appear in Metroid, Celeste, and Mega Man X for the same fundamental reason (vertical traversal between parallel surfaces), but each implementation carries unique tuning parameters that KidGameMaker exposes through intuitive stamp customization.

---

## 1.1 Basic Platforming Enhancements

### Wall Jump / Wall Climb

**Source Game:** Metroid (all 2D entries), Celeste, Mega Man X, Mario Wonder (Wall-Climb Jump Badge)

**Description:** The player character jumps toward a vertical wall, briefly clings to it (reduced sliding speed), and can then press jump again to kick off in the opposite direction with upward momentum. Chaining wall jumps between two parallel walls enables infinite vertical ascension ("chimneying"). The cling timer — how long the player remains stuck to the wall before sliding off — determines how forgiving the mechanic feels. Celeste's 0.3-second cling is considered the gold standard for accessibility.

**Kid UX:** A child stamps a "Wall Climb Zone" stamp (a vertical strip with handhold sparkles) onto any wall tile. Tapping the stamp opens a simple slider: "Easy" (0.6s cling, auto-kick toward nearest wall), "Normal" (0.3s cling), "Tricky" (0.15s cling, no auto-aim). The LLM auto-generates the visual effect — dust particles when clinging, a satisfying "push-off" squish animation on kick. A chain counter appears (1, 2, 3...) as the child successfully chimney-jumps.

**LLM Automation:** Detects wall collision during air state, applies wall-slide physics (reduced gravity typically 25-30% of normal), manages cling timer, calculates wall-kick velocity vector (horizontal away from wall + vertical upward impulse), resets air abilities (dash, double jump) on wall jump, distinguishes wall-jumpable surfaces from non-clingable surfaces via zone stamp metadata, and renders dust/sparkle particles at the contact point.

**JSON Contract Extension:**
```json
{
  "wallJump": {
    "enabled": true,
    "clingTimeSeconds": 0.3,
    "kickVelocityX": 200,
    "kickVelocityY": -250,
    "maxWallSlideSpeed": 60,
    "normalGravity": 900,
    "wallSlideGravity": 240,
    "resetsAirAbilities": true,
    "wallJumpZones": [
      {"x": 500, "y": 300, "height": 200, "clingMultiplier": 1.0}
    ]
  }
}
```

### Double Jump & Triple Jump

**Source Game:** Ori and the Blind Forest, Sonic the Hedgehog, Super Mario 64, Shovel Knight

**Description:** A fundamental aerial mobility upgrade where pressing the jump button a second (or third) time while airborne produces an additional upward impulse. The second jump is typically smaller than the first to prevent infinite height gain. Triple jumps usually require a rhythm input — pressing too quickly may not register the third jump, adding a small skill gate. Some games (Ori) grant double jumps via collectible pickups, making them a rewarding progression milestone.

**Kid UX:** The child stamps "Double Jump Boots" or "Triple Jump Feather" collectible stamps in the level. When the player touches the pickup, their character's shoes/feathers glow and a "JUMP x2" badge appears on screen. In subsequent jumps, the character leaves a colored trail on the second (and third) jump. The child can set the jump height via a simple stamp toggle: "Big Boost" (second jump nearly as strong as first), "Little Hop" (small correction jump), or "Super Triple" (Mario-style bounding).

**LLM Automation:** Tracks current jump count in air (0 = grounded, 1 = first jump, 2 = double jump, etc.), validates multi-jump input timing, applies diminishing velocity per additional jump (typically 80% then 60% of base jump force), generates visual trail effects on secondary jumps, manages collectible state persistence (once acquired, double jump persists across the level or permanently), and renders the collectible glow on player sprite to indicate the upgrade is active.

**JSON Contract Extension:**
```json
{
  "multiJump": {
    "maxJumps": 3,
    "jumpVelocities": [-300, -240, -180],
    "requiresCollectible": true,
    "collectibleId": "double_jump_boots",
    "trailColors": ["#FFD700", "#FF69B4", "#00BFFF"],
    "rhythmWindowSeconds": 0.3,
    "persistAcrossLevels": false
  }
}
```

### Dash / Air Dash

**Source Game:** Celeste (8-directional dash), Hollow Knight (grounded + air dash), Mega Man X, Dead Cells, Bloodborne

**Description:** A rapid horizontal (or multi-directional) burst of movement that propels the player a fixed distance at high speed. Dashes typically grant brief invincibility frames and can cross gaps too wide for normal jumping. Celeste's dash is the genre benchmark — 8-directional, fixed distance, refreshes on ground contact or dash crystal pickup. Hollow Knight's dash is horizontal-only but can be upgraded to a shadow dash that pierces enemies.

**Kid UX:** The child stamps a "Dash Crystal" (sparkly diamond) to grant the dash ability, or enables it globally on the hero. A "Dash" button appears in play with a circular cooldown indicator. Tapping dash while holding a direction performs the dash in that direction. The child can configure the dash via stamp toggles: "Straight Line" (Hollow Knight style), "Any Direction" (Celeste style), or "Through Enemies" (Shadow Dash). A rainbow trail follows the dash.

**LLM Automation:** Handles dash input detection and direction calculation, applies impulse force over a fixed duration (typically 0.15-0.2 seconds), grants invincibility frames during dash (usually 0.1s), manages dash availability state (used/available/refreshed), processes refresh triggers (ground touch, dash crystal, wall jump), renders dash trail VFX, plays dash SFX, and prevents dash-through-solid-wall clipping via collision prediction.

**JSON Contract Extension:**
```json
{
  "dashSystem": {
    "dashDistance": 120,
    "dashSpeed": 600,
    "dashDuration": 0.15,
    "cooldown": 0.5,
    "invincibilityFrames": 0.1,
    "directions": 8,
    "refreshOn": ["ground_touch", "dash_crystal", "wall_jump"],
    "trailVfx": "rainbow_streak",
    "shadowDash": false,
    "maxAirDashes": 1
  }
}
```

### Ground Pound / Butt Bounce

**Source Game:** Super Mario Bros. 3 (Tanooki Statue), Super Mario 64 (Ground Pound), Kirby (Stone form), Shovel Knight (Shovel Drop)

**Description:** Pressing down+attack while airborne causes the player to rapidly descend in a stomping motion. On impact with an enemy, the player bounces back upward. On impact with the ground, a shockwave or crater effect may damage nearby enemies. The ground pound transforms the player's vertical momentum into downward force, making it both a traversal tool (fast descent) and a combat move.

**Kid UX:** The child stamps a "Stomp Power" stamp onto the hero. In play, pressing the stomp button while in air causes the character to flip upside-down and plummet with a trail. On hitting an enemy, the character bounces up automatically with a spring sound. The child can stamp "Crater Ground" zones where stomps create visible impact craters with particle effects. A combo counter tracks consecutive bounces.

**LLM Automation:** Detects air state + stomp input, overrides vertical velocity to rapid downward constant, applies stomp hitbox beneath player during descent, calculates bounce velocity on enemy impact, generates crater particles and screen shake on ground impact, manages consecutive bounce chain tracking, and ensures the stomp cannot be initiated too close to the ground (minimum air time requirement).

**JSON Contract Extension:**
```json
{
  "groundPound": {
    "downwardSpeed": 800,
    "bounceVelocityY": -350,
    "bounceVelocityBoostPerChain": -40,
    "shockwaveRadius": 60,
    "shockwaveDamage": 2,
    "minAirTimeBeforeStomp": 0.1,
    "craterEnabled": true,
    "chainCounter": true,
    "vfx": "stomp_trail_and_crater"
  }
}
```

### Slide / Crawl

**Source Game:** Mega Man (slide under projectiles), Super Mario (crouch), Sonic (roll), Castlevania (crouch/crawl)

**Description:** A low-profile movement state entered by pressing down while grounded. The player's hitbox shrinks vertically (typically to 40-60% of standing height), enabling passage through narrow gaps and ducking under enemy attacks. Some implementations (Mega Man) convert the slide into a horizontal dash with reduced friction. Sonic's roll converts the slide into a momentum-based attack form.

**Kid UX:** The child stamps "Low Tunnel" segments (1-tile-high gaps) in their level geometry. The LLM auto-detects these passages and enables the slide/crawl mechanic when the hero approaches. A "DUCK" button appears in play (down arrow). Tapping it makes the character crouch with a cute compression animation. Moving while crouched initiates a slide. The child can configure slide behavior: "Fast Slide" (Mega Man dash), "Roll Attack" (Sonic-style damage on contact), or "Sneak" (silent movement for stealth).

**LLM Automation:** Reduces player hitbox height on crouch input (typically from full height to 50%), handles slide physics (reduced friction, momentum conservation), manages slide attack hitbox (if roll attack enabled), detects tunnel auto-fit (shrinks hitbox automatically when entering 1-tile gaps), distinguishes crouch-only (stationary) from slide (moving) states, and prevents standing up in insufficient vertical space.

**JSON Contract Extension:**
```json
{
  "slideCrawl": {
    "crouchHeightPercent": 50,
    "slideFriction": 0.1,
    "slideSpeed": 250,
    "slideDuration": 0.4,
    "enableRollAttack": false,
    "rollDamage": 2,
    "autoShrinkInTunnels": true,
    "tunnelHeightThreshold": 32
  }
}
```

### Rope Swing / Vine Climb

**Source Game:** Donkey Kong Country (vine swinging), Super Mario Wonder (grappling vine badge), Zelda (rope climbing), Axiom Verge

**Description:** Interactive rope or vine objects that the player can grab and either climb up/down or swing from like a pendulum. Swinging physics follow a simple harmonic oscillator model — the player builds momentum by timing swings, then releases at the peak of forward arc to launch across gaps. Climbing is typically vertical with simple up/down input.

**Kid UX:** The child stamps "Vine" or "Rope" objects from the decoration palette. Vines hang from ceilings; ropes span between two anchor points. In play, jumping near a vine/rope makes the character auto-grab it (magnetic snap within 20 pixels). Swipe left/right to swing, up/down to climb. Release to let go. The child can stamp "Swing Target" indicators showing where a perfect release will land.

**LLM Automation:** Implements pendulum physics on swingable ropes (gravity-driven arc with angular momentum), handles magnetic grab detection (player proximity + jump input), manages climb state (vertical movement along rope with reduced speed), calculates release velocity from swing angle and angular velocity, generates rope bending and swaying visual animations, and predicts/draws trajectory arc when swinging to help with timing.

**JSON Contract Extension:**
```json
{
  "ropeSwing": {
    "ropeType": "vine|rope|chain",
    "grabMagnetRadius": 24,
    "swingGravity": 400,
    "maxSwingAngle": 75,
    "climbSpeed": 80,
    "releaseVelocityMultiplier": 1.2,
    "predictTrajectory": true,
    "swayAnimation": "rope_bend_physics"
  }
}
```

---

## 1.2 Advanced Traversal

### Grappling Hook

**Source Game:** Super Mario Wonder (Grappling Vine Badge), Axiom Verge, Zelda (Hookshot), Hollow Knight

**Description:** A projectile-based traversal tool that fires a line from the player to a designated anchor point (wall, ceiling, or specially marked target), then rapidly pulls the player toward that point along a curved arc. Unlike a simple teleport, the grappling hook preserves a sense of physical movement — the player swings slightly as they travel. Some implementations allow the player to release mid-grapple for aerial maneuvering.

**Kid UX:** The child stamps "Grapple Point" anchors (ring targets) on walls and ceilings. These appear as small metallic rings. In play, when the player is within range of a grapple point, a subtle line connects the hero to the target. Tapping the grapple button fires a vine/chain, and the hero is pulled along the arc smoothly. The child can set grapple range per point via a tap-to-cycle toggle: Short, Medium, or Long.

**LLM Automation:** Detects nearby grapple points within range, calculates arc trajectory from player position to anchor, applies interpolated movement along the arc with easing, handles grapple release (player can let go mid-flight to preserve momentum), validates line-of-sight to grapple point (can't grapple through walls), generates grapple line/beam visual, and manages cooldown between grapples.

**JSON Contract Extension:**
```json
{
  "grapplingHook": {
    "range": 180,
    "arcHeight": 40,
    "pullSpeed": 400,
    "validTargets": ["grapple_point_wall", "grapple_point_ceiling"],
    "lineOfSightRequired": true,
    "allowMidAirRelease": true,
    "cooldown": 0.3,
    "vfx": "vine_chain_beam",
    "autoAimRadius": 50
  }
}
```

### Ledge Grab / Ledge Vault

**Source Game:** Zelda series (all 3D entries), Prince of Persia, Tomb Raider, Hollow Knight (ledge hang)

**Description:** When the player's upward jump arc brings them within proximity of a platform edge, they automatically (or on button press) grab the ledge and hang there. From the hanging state, the player can press jump to vault up onto the platform, or press down to drop. This mechanic prevents the frustrating "just missed the edge" moments in platformers and adds a sense of physicality to navigation.

**Kid UX:** The child stamps "Ledge Grab" zone markers along platform edges (small hand icons). The LLM auto-detects most platform edges and applies grab zones, but the stamp can add grab capability to otherwise smooth surfaces. In play, when the hero barely misses a jump, they auto-grab the edge with a "whew!" animation (character dangles by fingertips). Tap jump to pull up, tap down to let go. The child can disable auto-grab on specific edges by tapping to toggle.

**LLM Automation:** Detects when player's jump arc intersects with a grab-zone-equipped platform edge, transitions player to hanging state (frozen position, no gravity), accepts jump input for vault (applies small upward + forward impulse onto platform), accepts down input for release (returns to normal air state with gravity), generates hanging animation and "grabbing" dust particles, and ensures grab zones are visually subtle in play but visible in editor mode.

**JSON Contract Extension:**
```json
{
  "ledgeGrab": {
    "grabZoneWidth": 16,
    "grabZoneHeight": 8,
    "vaultVelocityX": 50,
    "vaultVelocityY": -120,
    "hangGravity": 0,
    "autoDetectPlatformEdges": true,
    "manualGrabRequired": false,
    "allowLedgeHangTime": "infinite",
    "vfx": "finger_dust_sparkle"
  }
}
```

### Wall Run / Ceiling Run

**Source Game:** Sonic the Hedgehog (corkscrew walls), Kingdom Hearts 3D (Flowmotion wall-run), Metroid (Speed Booster vertical walls), Matrix-inspired games

**Description:** The player can run along vertical walls and even upside-down across ceilings for a limited duration. Wall running requires continuous horizontal input and enough momentum — if the player stops or slows, gravity reasserts itself. Ceiling running is typically time-limited and transitions into a drop when the timer expires.

**Kid UX:** The child stamps "Wall-Run Surface" strips (glowing vertical bands) and "Ceiling-Run Zone" patches (checkerboard ceiling patterns) on their level. In play, approaching a wall-run surface at sufficient speed causes the character to stick to it and run upward. A "magnet meter" appears and drains while wall-running — when empty, the character falls. Tapping jump during a wall-run launches the character off the wall.

**LLM Automation:** Detects wall-run surface collision at sufficient horizontal velocity, overrides gravity and orients player to wall surface, manages magnet meter depletion (drains over time while on wall/ceiling), handles gravity reassertion on meter depletion or input cessation, calculates launch velocity on jump input during wall-run, generates appropriate footstep/spark particles on non-floor surfaces, and transitions smoothly between wall-run and ceiling-run at corners.

**JSON Contract Extension:**
```json
{
  "wallRun": {
    "minEntrySpeed": 150,
    "magnetMeterMax": 3.0,
    "drainRateWall": 1.0,
    "drainRateCeiling": 1.5,
    "runSpeed": 200,
    "launchVelocityX": 100,
    "launchVelocityY": -250,
    "validSurfaces": ["wall_run_zone", "ceiling_run_zone"],
    "sparkParticles": true,
    "meterRechargeRate": 2.0
  }
}
```

### Teleport / Blink

**Source Game:** Axiom Verge (Address Disruptor/teleport), Final Fantasy (Warp spell), Hollow Knight (Dream Gate), Zelda (Farore's Wind)

**Description:** Instantaneous repositioning of the player character to a target location within line of sight. Unlike the grappling hook, teleportation has no travel time — the player vanishes and reappears. Most implementations limit teleport range and require line of sight to prevent clipping through walls. Some versions (Hollow Knight's Dream Gate) allow setting a personal warp point that can be returned to at any time.

**Kid UX:** The child stamps "Blink Pickup" items to grant the ability, or enables it on the hero. A "Blink" button appears in play. When pressed, a targeting reticle appears at the cursor/finger position. Valid teleport locations glow green; blocked locations glow red. Tapping a valid spot instantly moves the hero there with a sparkle vanish-appear effect. The child can set range via stamp toggle: Short (1 screen), Medium (2 screens), or Long (anywhere visible).

**LLM Automation:** Handles blink input and targeting mode, validates destination (line of sight check, no solid terrain at destination, within range), manages cooldown between blinks (typically 2-5 seconds), generates vanish particle effect at origin and appear effect at destination, handles edge cases (blinking onto moving platforms, blinking out of hazard zones), and renders the targeting reticle with validity coloring.

**JSON Contract Extension:**
```json
{
  "teleportBlink": {
    "range": 300,
    "lineOfSightRequired": true,
    "cooldown": 3.0,
    "targetingMode": "cursor_follow",
    "validColor": "#00FF00",
    "invalidColor": "#FF0000",
    "vanishVfx": "sparkle_vanish",
    "appearVfx": "sparkle_appear",
    "allowMovingPlatformTarget": true
  }
}
```

### Charge Jump / Super Jump

**Source Game:** Mega Man X (charge-based vertical dash), Super Mario (spring shoes), Shovel Knight, Castlevania (Gravity Boots / super jump relics)

**Description:** Holding the jump button (or a dedicated charge button) accumulates energy, indicated by a visual charging effect. Releasing at full charge produces a dramatically higher jump than a normal press. The charge mechanic adds a risk/reward dimension — the player must commit to standing still while charging, making them vulnerable. Some implementations allow charging while moving at reduced speed.

**Kid UX:** The child stamps a "Charge Spring" upgrade on the hero. In play, holding the jump button causes the character to crouch and compress with a charging visual (energy rings expanding). A 3-segment charge meter fills. Releasing at segment 1 = normal jump, segment 2 = 1.5x height, segment 3 = 2x height with trail effect. The child can set charge time via stamp toggle: "Fast" (0.5s per segment), "Normal" (1s), or "Slow" (1.5s).

**LLM Automation:** Tracks charge button hold duration, updates charge level (0-3 segments), renders charging visual effects (crouching animation, expanding energy rings, charge meter UI), calculates jump velocity based on charge level on release, cancels charge on damage taken or jump button release at insufficient charge, plays escalating charge sound, and generates full-charge launch particles.

**JSON Contract Extension:**
```json
{
  "chargeJump": {
    "chargeLevels": 3,
    "timePerLevel": 0.8,
    "jumpVelocities": [-300, -450, -600],
    "allowMoveWhileCharging": true,
    "moveSpeedWhileCharging": 50,
    "cancelOnDamage": true,
    "chargeVfx": "expanding_energy_rings",
    "chargeSfx": "escalating_hum",
    "fullChargeTrail": true
  }
}
```

### Bounce Pad / Spring Launch

**Source Game:** Sonic the Hedgehog (spring pads), Super Mario (note blocks, springboards), Kirby, Mega Man

**Description:** Placed objects that launch the player upward (or in a specific direction) on contact. Springs can be static (always active), player-activated (must press down to charge, then release), or switch-triggered (only active when a switch is held). Multi-tier springs provide different launch heights based on how long the player holds the activation button.

**Kid UX:** The child stamps "Spring" objects from the item palette. Springs come in three visual variants: Yellow Spring (standard bounce), Red Spring (super high bounce), and Green Spring (diagonal bounce). Dragging the spring rotates it to aim in any direction. Tapping a spring opens a toggle: "Always Active" or "Switch Triggered" (child then stamps a switch and drags a connection line). In play, touching a spring launches the character with a satisfying "boing!"

**LLM Automation:** Detects player-spring collision, calculates launch velocity vector based on spring aim direction and power tier, applies impulse to player on contact, generates spring compression and release animation, plays spring SFX with pitch variation based on power tier, handles switch-triggered springs (active/inactive state), and ensures springs cannot launch the player into solid terrain.

**JSON Contract Extension:**
```json
{
  "bouncePad": {
    "springTypes": {
      "yellow": {"power": 400, "direction": "up"},
      "red": {"power": 700, "direction": "up"},
      "green": {"power": 500, "direction": "diagonal"}
    },
    "aimable": true,
    "switchTriggerable": true,
    "compressionAnimation": true,
    "sfxPitchVariation": true,
    "predictLandingIndicator": true
  }
}
```

---

## 1.3 Flight & Swimming

### Glide / Cape Glide

**Source Game:** Super Mario World (cape feather), Kirby (wing ability), Zelda (Deku Leaf), Ori (Kuro's Feather), Kingdom Hearts (glide ability)

**Description:** While airborne, the player can hold a button to deploy a gliding surface (cape, wings, leaf) that dramatically reduces fall speed and converts horizontal input into forward gliding momentum. Gliding typically provides only limited lift — the player descends slowly but cannot gain altitude without external updrafts. Some implementations (Mario's cape) allow a "dive and pull up" maneuver to generate lift through skilled play.

**Kid UX:** The child stamps a "Glide Wings" or "Magic Cape" collectible in the level. When acquired, a "GLIDE" button appears during jumps. Holding it deploys the cape/wings with a whoosh sound and a cloth-flutter animation. The character descends at about 20% of normal fall speed. The child can stamp "Wind Updraft" zones (visible rising leaves) that push the gliding character upward.

**LLM Automation:** Reduces gravity while glide button is held (typically to 15-25% of normal), converts horizontal input into gliding momentum with smooth acceleration, manages glide deployment/collapse animations, handles wind updraft collision (applies upward force to counteract descent), calculates glide speed cap (typically 200-250 horizontal), and transitions smoothly from gliding to falling to landing states.

**JSON Contract Extension:**
```json
{
  "glide": {
    "gravityWhileGliding": 180,
    "normalGravity": 900,
    "horizontalAcceleration": 300,
    "maxGlideSpeed": 220,
    "deployAnimation": "cape_unfurl",
    "updraftForce": -350,
    "updraftZones": ["wind_column"],
    "allowDiveForLift": true,
    "diveLiftVelocity": -200
  }
}
```

### Jetpack / Thruster Hover

**Source Game:** Existing KidGameMaker feature enhancement; Mega Man (Rush Jet), Cave Story (Booster), Terraria

**Description:** A limited-duration hover ability where the player's vertical descent is arrested or reversed by thrusting. Jetpacks typically consume fuel that regenerates on the ground, creating a resource-management mini-game during aerial sections. Unlike gliding, jetpacks can gain altitude — but only for as long as fuel lasts.

**Kid UX:** The child stamps a "Jetpack" or "Rocket Belt" item in the level. When collected, the character equips it visually. A "Hover" button appears in play. Holding it produces upward thrust with a flame particle effect. A fuel bar (small rocket icon) depletes and refills on ground contact. The child can configure fuel duration via stamp toggle: "Short Bursts" (2s), "Medium" (4s), or "Long Flights" (6s).

**LLM Automation:** Manages fuel resource (depletes while hover active, regenerates on ground), applies upward thrust force while hover button held, generates flame/thruster particles during hover, manages fuel bar UI, prevents hover when fuel depleted, handles fuel regeneration rate (typically 1.5x depletion rate for faster ground recovery), and ensures hover cannot be used indefinitely.

**JSON Contract Extension:**
```json
{
  "jetpack": {
    "maxFuel": 4.0,
    "fuelDepletionRate": 1.0,
    "fuelRegenRate": 1.5,
    "thrustForce": -350,
    "maxHoverSpeed": 120,
    "fuelBarUI": true,
    "thrusterParticles": "flame_trail",
    "requireGroundToRegen": true,
    "equipVisual": "rocket_belt_back"
  }
}
```

### Underwater Swimming

**Source Game:** Sonic the Hedgehog (underwater zones), Super Mario (underwater stages), Ecco the Dolphin, Metroid (Maridia)

**Description:** Physics change fundamentally when the player enters water: gravity is reduced (or reversed to create buoyancy), movement becomes slower and more fluid, and the player may need to manage an air/breath meter. Underwater sections often feature unique hazards (currents, jellyfish, drowning risk) and can be entered from any water surface.

**Kid UX:** The child stamps "Water Zone" area markers over sections of the level. The water zone renders with a blue tint, bubble particles, and wave surface animation. When the hero enters, they automatically switch to swimming physics — press up/down/left/right to swim in any direction. The child can enable/disable a "Breath Meter" toggle on the water stamp. If enabled, a bubble counter appears and the hero must find "Air Pocket" stamps (rising bubbles) to refill.

**LLM Automation:** Switches player physics to water mode on zone entry (reduced gravity, increased drag, 6-directional movement), manages breath meter (depletes over time underwater, refills at surface or air pockets), generates water visual effects (blue tint, bubble particles, caustic light patterns), handles water surface transition (auto-float to surface when pressing up), applies water-specific hazards (current forces, enemy behaviors), and manages drowning state on breath depletion.

**JSON Contract Extension:**
```json
{
  "underwaterSwimming": {
    "waterGravity": 200,
    "normalGravity": 900,
    "waterDrag": 0.7,
    "swimSpeed": 120,
    "swimAcceleration": 80,
    "breathEnabled": true,
    "maxBreath": 10.0,
    "breathDepletionRate": 1.0,
    "airPocketRefill": 10.0,
    "surfaceAutoFloat": true,
    "waterTint": "#1A5C7A",
    "bubbleParticles": true
  }
}
```

### Mermaid Morph / Auto Swim Form

**Source Game:** NiGHTS into Dreams (environment morphing), Mega Man (Rush Marine), Kirby (various aquatic forms)

**Description:** A specialized transformation that activates automatically when entering water. The player's sprite changes to a swim-optimized form (mermaid tail, diving suit, submarine form), movement physics switch to specialized swim controls, and water-specific abilities become available (bubble attacks, sonar detection, rapid turning). The transformation reverses on exiting water.

**Kid UX:** The child stamps a "Morph Zone" overlay on water areas and selects the swim form from a sticker picker: "Mermaid Tail" (elegant swim), "Sub Form" (Rush Marine style), or "Fish Form" (fast swimmer). When the hero enters the water zone, a sparkly transformation sequence plays automatically. The swim form has a unique button: "Bubble Blast" or "Sonar Ping." On exiting water, the character transforms back with a splash.

**LLM Automation:** Detects water zone entry and triggers morph sequence (sparkle transition + sprite swap), applies swim-form physics (optimized for underwater movement), enables swim-form-specific abilities, handles morph reversal on zone exit, generates transformation VFX (sparkles, splash), manages swim-form collision shape differences, and ensures smooth transition between forms without physics disruption.

**JSON Contract Extension:**
```json
{
  "mermaidMorph": {
    "triggerZone": "water_zone",
    "swimForm": "mermaid_tail",
    "transformVfx": "sparkle_sequence",
    "swimSpeedMultiplier": 1.3,
    "specialAbility": "bubble_blast",
    "revertOnExit": true,
    "exitSplashVfx": true,
    "spriteVariants": ["mermaid", "submarine", "fish_form"]
  }
}
```

### Free Flight Mode

**Source Game:** Creative mode / sandbox (KidGameMaker), NiGHTS into Dreams (flight segments), Kingdom Hearts (Peter Pan flight), Kirby (wing ability full flight)

**Description:** Unrestricted flight in any direction with no time or fuel limits. This is typically a creative-mode-only feature that enables rapid world exploration and level building assistance. The player can ascend, descend, and hover freely, passing through any terrain.

**Kid UX:** The child enables "Free Flight" from the level settings (a big toggle with a wing icon). In play, a flight joystick appears — drag in any direction to fly. Flight speed is adjustable via a stamp slider: "Slow Explore" (cruising speed), "Fast Zip" (rapid traversal), or "Noclip" (pass through walls). Double-tapping jump in creative mode also toggles flight.

**LLM Automation:** Switches player to free-flight physics mode (no gravity, 8-directional movement at constant speed), disables terrain collision in noclip mode, manages flight speed based on setting, generates flight trail particles, handles smooth acceleration/deceleration on input changes, and auto-exits flight mode if the player enters play-test mode from the editor.

**JSON Contract Extension:**
```json
{
  "freeFlight": {
    "enabled": false,
    "speed": 200,
    "directions": 8,
    "noclip": false,
    "trailVfx": "cloud_puffs",
    "creativeModeOnly": true,
    "doubleJumpToggle": true,
    "acceleration": 400,
    "deceleration": 600
  }
}
```

---

## 1.4 Speed & Momentum Systems

### Spin Dash

**Source Game:** Sonic the Hedgehog 2/3/Mania (the definitive charge-and-release burst)

**Description:** The player crouches and holds a button to charge energy, indicated by a vibrating, increasingly fast animation. Releasing the button launches the character forward at super-speed in a ball form, damaging enemies on contact and breaking through destructible walls. The charge has multiple levels — each additional charge cycle increases launch speed.

**Kid UX:** The child stamps a "Spin Dash" ability stamp on the hero. In play, holding the action button makes the character curl into a ball and vibrate with increasing intensity — a 3-segment charge meter fills. Recharging plays a revving sound that escalates. Releasing launches the character forward. The child can stamp "Breakable Wall" blocks (cracked appearance) that only shatter from spin dash impacts.

**LLM Automation:** Implements charge state with vibration animation scaling to charge level, manages charge level state machine (1-3 segments based on hold duration), applies launch velocity on release ( tiered: 1.5x, 2.5x, 4.0x base speed), enables ball-form collision (enemy damage + destructible wall breaking), generates charge particles (dust gathering at feet), plays escalating rev SFX, and provides brief pit-warning arrow if aimed toward a gap.

**JSON Contract Extension:**
```json
{
  "spinDash": {
    "chargeLevels": 3,
    "chargeTimePerLevel": 0.5,
    "velocityMultipliers": [1.5, 2.5, 4.0],
    "ballForm": true,
    "enemyDamageOnContact": true,
    "breaksDestructibleWalls": true,
    "pitWarning": true,
    "chargeVfx": "vibration_and_dust",
    "chargeSfx": "escalating_rev"
  }
}
```

### Speed Booster / Shinespark

**Source Game:** Metroid series (Speed Booster, Shinespark charge, shinespark puzzles)

**Description:** Running in a single direction for approximately 3 seconds activates the Speed Booster — the player character begins glowing with speed lines, becomes capable of destroying blocks and enemies on contact, and can smash through special "Speed Booster Blocks." The player can store this charge (Shinespark) by crouching, then release it to fly in any direction at super-speed for a limited distance. This mechanic turns traversal into a puzzle — the player must maintain a running start, store the charge, and navigate to the target without bumping into walls.

**Kid UX:** The child stamps "Speed Booster Blocks" (yellow blocks with a running figure icon) in their level. The hero automatically has the Speed Booster ability. Running straight for 3 seconds causes the character to glow yellow with speed lines. The child can stamp "Shinespark Lane" indicators showing optimal charge paths. In play, the glow and "whoosh" sound make the power-up feel incredible.

**LLM Automation:** Tracks horizontal velocity and direction consistency for boost activation (3 seconds of uninterrupted running in one direction), manages charge storage state (Shinespark) on crouch input, applies boosted movement physics (increased speed, damage on contact with enemies/blocks), handles Shinespark release (directional dash at 4x normal speed), destroys Speed Booster Blocks on contact during boost, and generates speed line particles + glow effect.

**JSON Contract Extension:**
```json
{
  "speedBooster": {
    "chargeTime": 3.0,
    "boostSpeed": 400,
    "canStoreCharge": true,
    "shinesparkDistance": 300,
    "shinesparkDamage": 10,
    "breaksSpeedBlocks": true,
    "glowColor": "#FFD700",
    "speedLineVfx": true,
    "maintainChargeOnCrouch": true
  }
}
```

### Slope Physics

**Source Game:** Super Mario Maker 2 (gentle and steep slopes), Sonic (hills and slopes everywhere)

**Description:** Angled terrain that modifies player velocity based on gravity — the player accelerates when moving downhill and decelerates (or slides) when moving uphill. Steep slopes may be too sharp to walk up, requiring the player to find an alternate path or use a speed boost. Slopes also enable slide-kills (sliding down a slope while in ball/slide form damages enemies).

**Kid UX:** The child stamps "Slope" terrain tiles from the terrain palette. Two variants are available: "Gentle Slope" (22.5-degree angle, walkable) and "Steep Slope" (45-degree angle, causes sliding). Slopes snap to terrain edges automatically. In play, the character automatically slides down steep slopes with arms-flailing animation. The child can stamp "Ice Slope" variants with reduced friction for longer slides.

**LLM Automation:** Generates slope colliders with proper angle physics, applies velocity modifications for slope traversal (acceleration downhill, deceleration uphill), handles slide-state detection on steep slopes, enables slide-kill hitbox when sliding into enemies, manages friction differences between normal and ice slopes, and ensures smooth transitions between slope and flat terrain.

**JSON Contract Extension:**
```json
{
  "slopePhysics": {
    "gentleAngle": 22.5,
    "steepAngle": 45,
    "downhillAcceleration": 200,
    "uphillDeceleration": 150,
    "steepSlideSpeed": 250,
    "slideKillEnabled": true,
    "iceFriction": 0.05,
    "normalFriction": 0.3,
    "autoSnapToTerrain": true
  }
}
```

### Loop-de-Loop Auto-Pilot

**Source Game:** Sonic the Hedgehog (Green Hill Zone loops), Sonic Mania

**Description:** Special pre-authored track segments where the player character runs through a complete 360-degree loop. These segments are typically auto-piloted — the player only needs to maintain forward momentum, and the game handles the physics of running upside-down through the loop's apex. Loop-de-loops are both spectacular visual set-pieces and gating mechanisms (the player must have enough speed to complete the loop).

**Kid UX:** The child stamps "Loop-de-Loop" track pieces from a special terrain palette. The stamp places a pre-shaped loop that auto-connects to adjacent terrain. A "Need Speed!" indicator appears on the loop stamp if the entry angle requires more speed than base movement provides. In play, entering a loop at sufficient speed auto-orients the character to the loop path, and they run through it with camera-following-the-curve effect.

**LLM Automation:** Generates loop track path (elliptical or circular spline), handles player orientation to track surface during loop traversal, enforces minimum entry speed for loop completion (player falls off if too slow), manages gravity override during loop (player sticks to track surface via normal force), generates camera-follow-spline behavior for cinematic loop viewing, and places loop track pieces with auto-terrain-connection.

**JSON Contract Extension:**
```json
{
  "loopDeLoop": {
    "trackShape": "circular",
    "minEntrySpeed": 250,
    "autoPilot": true,
    "playerSticksToTrack": true,
    "cameraFollowsTrack": true,
    "autoConnectTerrain": true,
    "fallOffIfTooSlow": true,
    "trackVfx": "speed_lines_on_surface"
  }
}
```

### Rail Grinding

**Source Game:** Sonic (grinding rails), Kingdom Hearts 3D/III (Flowmotion rail riding)

**Description:** The player jumps toward a rail and magnetically locks onto it, sliding along at high speed. While grinding, the player can jump off at any point — timing the jump at rail ends or special "sweet spot" markers produces an extra-far leap. Rails can be curved, looped, or branching. Grinding provides both spectacle and efficient traversal.

**Kid UX:** The child stamps "Grind Rail" paths by drawing curved lines on the canvas. Rails appear as metallic tracks with slight glow. "Sweet Spot" markers (glowing rings) can be stamped at rail ends for bonus launch. In play, jumping near a rail auto-locks the character into a grinding pose with spark particles. Tap jump to dismount. Sweet spots produce a "DING!" sound and bonus launch height.

**LLM Automation:** Generates grind rail path from drawn curve (spline interpolation), implements magnetic lock-on detection (player proximity + jump input within radius), applies rail-slide physics (constant speed along path, gravity irrelevant), handles jump-off velocity calculation (distance based on current speed and sweet spot proximity), generates grinding spark particles, manages rail-to-rail transitions at junctions, and ensures rails are visually connected to terrain.

**JSON Contract Extension:**
```json
{
  "railGrinding": {
    "lockOnRadius": 30,
    "grindSpeed": 300,
    "drawPath": true,
    "pathSmoothing": "catmull_rom",
    "sweetSpotBonus": 1.5,
    "sparkParticles": true,
    "allowMidRailJump": true,
    "railToRailTransition": true,
    "grindAnimation": "crouch_balance"
  }
}
```

### Time Slow / Bullet Time

**Source Game:** Zelda: Breath of the Wild (Flurry Rush), Bayonetta (Witch Time), Max Payne

**Description:** A time-dilation effect that triggers under specific conditions — typically when the player dodges an attack at the last moment or activates a special ability. During time slow, everything except the player moves at reduced speed (typically 20-30% of normal), enabling precise positioning, extended reaction windows, and dramatic combat sequences. Time slow can also be implemented as a placed zone stamp.

**Kid UX:** The child stamps "Slow-Mo Zone" areas (purple-tinted bubbles) in their level. Any entity entering the zone has time slow applied. Alternatively, the child can stamp a "Focus Amulet" on the hero that triggers time slow on perfect dodge. In play, entering a slow zone causes everything to shift to purple tones with a deep bass sound. The player moves at normal speed while enemies crawl. A "TIME SLOW" badge pulses on screen.

**LLM Automation:** Detects zone entry or dodge-trigger condition, applies global time scale reduction (typically 0.2x for enemies, projectiles, environmental hazards), exempts player from time scale reduction, manages slow-duration timer, handles smooth entry/exit transitions (ramp time scale over 0.3s), renders time slow visual effects (purple tint, motion trails on moving objects, deep bass audio filter), and ensures time slow does not affect UI or menus.

**JSON Contract Extension:**
```json
{
  "timeSlow": {
    "trigger": "zone_entry|dodge_perfect",
    "timeScaleEnemies": 0.2,
    "timeScaleProjectiles": 0.2,
    "timeScaleEnvironment": 0.3,
    "playerTimeScale": 1.0,
    "duration": 3.0,
    "rampDuration": 0.3,
    "visualTint": "#800080",
    "audioPitchShift": -0.5,
    "motionTrails": true
  }
}
```

---

## 1.5 Comparison Tables

### Movement Feature Comparison Matrix

| Feature | Source | Input Complexity | Kid Age Suitability | Key UX Stamp |
|---------|--------|-----------------|---------------------|--------------|
| Wall Jump | Metroid, Celeste | 2-button (jump + directional) | 5-6 years | Wall Climb Zone strip |
| Double Jump | Ori, Mario | 1-button (tap jump twice) | 4-5 years | Jump Boots collectible |
| Dash | Celeste, Hollow Knight | 1-button + direction | 5-6 years | Dash Crystal |
| Ground Pound | Mario 64, Kirby | 1-button (down+attack in air) | 5-6 years | Stomp Power stamp |
| Slide | Mega Man, Sonic | 1-button (down while moving) | 5-6 years | Low Tunnel auto-detect |
| Grappling Hook | Mario Wonder, Zelda | 1-button (auto-aim) | 5-6 years | Grapple Point anchor |
| Ledge Grab | Zelda, Prince of Persia | Automatic | 4-5 years | Ledge Grab zone marker |
| Wall Run | Sonic, Kingdom Hearts | Hold direction at wall | 6-7 years | Wall-Run Surface strip |
| Teleport | Axiom Verge, Hollow Knight | Tap + target selection | 6-7 years | Blink Pickup item |
| Charge Jump | Mega Man X, Mario | Hold jump to charge | 5-6 years | Charge Spring upgrade |
| Bounce Pad | Sonic, Mario | Automatic on contact | 4-5 years | Spring object (aimable) |
| Glide | Mario World, Kirby | Hold button in air | 5-6 years | Glide Wings collectible |
| Jetpack | Cave Story, KidGameMaker | Hold hover button | 5-6 years | Jetpack/Rocket Belt item |
| Swimming | Sonic, Mario | Directional in water zones | 4-5 years | Water Zone area marker |
| Mermaid Morph | NiGHTS, Mega Man | Automatic on zone entry | 4-5 years | Morph Zone overlay |
| Spin Dash | Sonic | Hold to charge, release | 5-6 years | Spin Dash ability stamp |
| Speed Booster | Metroid | Run straight 3 seconds | 6-7 years | Speed Booster Block |
| Slope Physics | Mario Maker 2 | Automatic on terrain | 4-5 years | Slope terrain tile |
| Loop-de-Loop | Sonic | Maintain forward momentum | 5-6 years | Loop-de-Loop track piece |
| Rail Grinding | Sonic, Kingdom Hearts | Jump near rail | 5-6 years | Grind Rail path stamp |
| Time Slow | Zelda, Bayonetta | Zone entry or perfect dodge | 6-7 years | Slow-Mo Zone bubble |

### Physics Parameter Presets by Feel

| Feel Goal | Gravity | Jump Velocity | Air Control | Friction | Dash Speed |
|-----------|---------|---------------|-------------|----------|------------|
| Floaty / Gentle | 500 | -250 | 0.9 | 0.1 | 400 |
| Tight / Responsive | 900 | -350 | 0.5 | 0.3 | 600 |
| Heavy / Weighty | 1200 | -400 | 0.3 | 0.5 | 500 |
| Sonic-Fast | 800 | -300 | 0.4 | 0.05 | 800 |
| Celeste-Precise | 900 | -320 | 1.0 | 0.2 | 600 |
| Mario-Bouncy | 1000 | -350 | 0.6 | 0.3 | N/A |

The LLM automatically applies these presets when a child stamps a "Feel" selector on their level. A child can stamp "Floaty World" or "Fast World" as global modifiers, and the LLM adjusts all physics constants accordingly. These presets are derived from the canonical feel of their source games — Celeste's high air control enables precise platforming, while Sonic's low friction enables sustained speed. The child does not see numbers; they see friendly icons (cloud = floaty, lightning = fast, weight = heavy) and the LLM handles the mathematical tuning invisibly.

---

## 1.6 Combinatorial Movement System

The true power of KidGameMaker's movement system emerges when features are combined. The LLM automatically handles interaction between movement mechanics — a child can enable Wall Jump, Double Jump, and Dash simultaneously, and the system manages the state transitions seamlessly.

### Classic Combinations and Their Source Games

**Wall Jump + Double Jump** (Celeste): The wall jump resets the double jump counter, enabling chains of wall-jump → double-jump → wall-jump that can scale infinite vertical spaces.

**Dash + Glide** (Hollow Knight, Kingdom Hearts): Dashing in mid-air transitions smoothly into a glide, extending horizontal range dramatically. The dash provides initial burst; the glide sustains the traversal.

**Spin Dash + Slope** (Sonic): Spin dashing at the top of a slope converts potential energy into massive speed at the bottom, which can then be carried into a loop-de-loop.

**Ground Pound + Bounce Pad** (Mario): Performing a ground pound onto a bounce pad produces a super-bounce (typically 1.5x normal height), rewarding creative combo play.

**Time Slow + Dash** (Zelda, Bayonetta): Dashing during time slow creates the illusion of teleportation — the player crosses the room in what appears to be an instant from the enemy's perspective.

The LLM's **combinatorial state machine** manages all possible transitions between movement states (grounded, airborne, wall-clinging, dashing, gliding, swimming, sliding, grinding, etc.) with priority rules that prevent contradictory states (the player cannot simultaneously be wall-running and swimming, for example). The JSON contract's `movementStateMachine` block encodes these transitions:

```json
{
  "movementStateMachine": {
    "states": ["grounded", "airborne", "wall_clinging", "dashing", "gliding", "swimming", "sliding", "grinding", "charging"],
    "transitionRules": [
      {"from": "airborne", "to": "wall_clinging", "condition": "wall_collision"},
      {"from": "wall_clinging", "to": "airborne", "condition": "jump_input", "resets": ["double_jump", "dash"]},
      {"from": "dashing", "to": "gliding", "condition": "dash_end + glide_button", "priority": 1},
      {"from": "airborne", "to": "ground_pound", "condition": "down + attack"},
      {"from": "ground_pound", "to": "airborne", "condition": "enemy_bounce"},
      {"from": "any", "to": "swimming", "condition": "water_zone_entry"},
      {"from": "grinding", "to": "airborne", "condition": "jump_input"}
    ]
  }
}
```

The child sees none of this complexity. They place stamps, and the LLM generates a movement system that feels as polished as the source games it draws from.



## 1.7 Additional Movement Features

### Coyote Time

**Source Game:** Celeste, Super Meat Boy, virtually all modern platformers

**Description:** A brief grace period (typically 0.05-0.1 seconds) after the player leaves a platform during which they can still jump as if grounded. Named after the cartoon trope where Wile E. Coyote runs off a cliff and doesn't fall until he looks down. Coyote time prevents the frustrating experience of pressing jump a split-second after leaving a platform edge.

**Kid UX:** This is a global setting the child can toggle in level settings. A "Helpful Jumps" stamp with a coyote icon enables the feature. No visible UI during play — the child simply notices that jumps feel more forgiving. The LLM can show a subtle visual cue (a ghost platform outline briefly appears where the player left) if visual feedback mode is enabled.

**LLM Automation:** Tracks time since player left grounded state, allows jump input for configurable duration after leaving platform, applies grounded jump velocity during coyote window, renders optional ghost platform outline at edge during window, and ensures coyote time does not apply if player has been airborne for longer than the window.

**JSON Contract Extension:**
```json
{
  "coyoteTime": {
    "enabled": true,
    "duration": 0.08,
    "visualFeedback": false,
    "ghostPlatformOutline": false,
    "appliesTo": ["single_jump", "double_jump_activation"]
  }
}
```

### Jump Buffer

**Source Game:** Celeste, Hollow Knight, Ori

**Description:** If the player presses the jump button a few frames before landing, the input is "buffered" and the jump executes immediately on landing. This eliminates the frustrating experience of pressing jump slightly too early and getting no response. Combined with coyote time, jump buffering creates the responsive, "just works" feel of modern platformers.

**Kid UX:** A global setting enabled alongside coyote time via the "Helpful Jumps" stamp. The child doesn't see anything during play, but the jumps feel incredibly responsive. For learning purposes, a "Buffer Ring" option can show a brief expanding ring at the landing point when a buffered jump triggers.

**LLM Automation:** Stores jump input in a buffer on press, validates buffer on next ground contact (executes jump if within buffer window), clears buffer on jump execution or timeout, renders optional buffer ring VFX at landing point, and manages buffer duration (typically 0.05-0.1 seconds).

**JSON Contract Extension:**
```json
{
  "jumpBuffer": {
    "enabled": true,
    "bufferDuration": 0.07,
    "executeOnLanding": true,
    "clearOnJump": true,
    "visualBufferRing": false
  }
}
```

### Ice Physics / Slippery Surfaces

**Source Game:** Super Mario (ice stages), Mega Man (Ice Man stage), Celeste (ice walls)

**Description:** Surfaces with dramatically reduced friction that cause the player to slide and skid. On ice, the player cannot stop instantly — input changes produce gradual acceleration and deceleration. Ice surfaces create traversal puzzles where precise momentum management is required.

**Kid UX:** The child stamps "Ice Floor" terrain tiles (shiny blue/white appearance). In play, the character slips and slides on ice with a skidding animation. The child can adjust friction via a stamp toggle: "Slightly Slippery" (0.2 friction), "Very Slippery" (0.05 friction), or "Impossible" (0.01 friction, pure momentum conservation).

**LLM Automation:** Overrides ground friction on ice surface contact (reduces from default 0.3 to ice value), applies momentum conservation (player retains horizontal velocity longer), generates ice-specific movement animations (skidding, sliding), renders ice surface visual effects (sparkle particles, reflection), handles transition between normal and ice surfaces (gradual friction change), and applies ice physics to all entities (enemies slide too).

**JSON Contract Extension:**
```json
{
  "icePhysics": {
    "friction": 0.05,
    "normalFriction": 0.3,
    "accelerationOnIce": 100,
    "decelerationOnIce": 20,
    "visual": "ice_sparkle",
    "affectsEnemies": true,
    "transitionDuration": 0.2
  }
}
```

### Conveyor Belt / Moving Floor

**Source Game:** Mega Man (conveyor belts in countless stages), Super Mario (moving platforms), Terraria

**Description:** Floor surfaces that automatically move entities standing on them in a specified direction. Conveyor belts can push the player, enemies, and items. They come in two directions (left or right) and various speeds. Conveyor belts create traversal puzzles where the player must fight against the belt's motion or use it to gain speed.

**Kid UX:** The child stamps "Conveyor Belt" floor tiles with direction arrows. Tapping a belt opens speed options: "Slow Walk" (gentle push), "Fast Run" (strong push), or "Sprint" (very strong push). Belts have animated rollers or tread marks to show direction. In play, stepping on a belt pushes the character in the arrow direction.

**LLM Automation:** Applies horizontal force to entities standing on conveyor belt surface (direction and magnitude based on belt configuration), generates belt animation (scrolling tread marks, rotating rollers), handles player input combined with belt force (player can fight against or ride with the belt), applies belt force to items and enemies, and ensures belt force is consistent across all entity types.

**JSON Contract Extension:**
```json
{
  "conveyorBelt": {
    "speedTiers": {
      "slow": 80,
      "medium": 160,
      "fast": 280
    },
    "direction": "left|right",
    "forceMode": "continuous",
    "affectsPlayer": true,
    "affectsEnemies": true,
    "affectsItems": true,
    "visualAnimation": "scrolling_tread",
    "arrowIndicator": true
  }
}
```

### Wind Zone / Current

**Source Game:** Celeste (wind-swept ridge), Ori (wind gusts), Mario (wind stages), Okami (Galestorm)

**Description:** An environmental zone that applies continuous directional force to the player and projectiles. Wind can push the player horizontally (making forward movement difficult) or vertically (creating updrafts that extend jump height). Wind zones have configurable strength and direction.

**Kid UX:** The child stamps "Wind Zone" areas (semi-transparent arrows showing direction and strength). In play, entering a wind zone pushes the character and causes their hair/cloak to flutter with wind animation. Wind strength is shown by arrow density (sparse = gentle breeze, dense = strong gale). The child can set wind direction by rotating the stamp.

**LLM Automation:** Applies continuous directional force to player while within wind zone boundaries, affects projectile trajectories (arrows curve, fireballs drift), generates wind visual effects (streaming particle lines, fluttering hair/cape animations), handles wind sound effects (gentle breeze to howling gale based on strength), applies force to lightweight entities (items, small enemies), and renders wind zone boundaries in editor mode.

**JSON Contract Extension:**
```json
{
  "windZone": {
    "forceX": 200,
    "forceY": 0,
    "affectsPlayer": true,
    "affectsProjectiles": true,
    "affectsItems": true,
    "affectsEnemies": "light_only",
    "visual": "streaming_particles",
    "particleDensity": "medium",
    "sfx": "wind_howl",
    "strengthScale": 1.0
  }
}
```

### Gravity Flip Zone

**Source Game:** VVVVVV (gravity flipping), Celeste (gravity helpers), Portal

**Description:** A zone where gravity is inverted — the player falls toward the ceiling instead of the floor. Gravity flips can be toggled zones (entering the zone flips gravity) or one-time triggers (hitting a switch flips gravity globally). Some implementations allow mid-air gravity flipping for ceiling-walking traversal puzzles.

**Kid UX:** The child stamps "Gravity Flip" zones (purple-tinted areas with up-arrow icons). Entering the zone causes the character to fall upward toward the ceiling. The child can set the flip mode: "Zone Only" (gravity normalizes when exiting), "Global Toggle" (flips for entire level until another flip zone is hit), or "Timed" (flip lasts 5 seconds then reverts). A visual flip effect (screen rotates 180 degrees) makes the transition clear.

**LLM Automation:** Inverts gravity vector on zone entry (positive gravity becomes negative), handles smooth transition (player gradually falls upward rather than snapping), manages camera orientation (can flip with gravity or remain fixed based on setting), applies gravity flip to all entities within zone, renders gravity zone visual tint and particle effects, and ensures player can walk on ceiling while gravity is inverted.

**JSON Contract Extension:**
```json
{
  "gravityFlip": {
    "flipMode": "zone_only|global_toggle|timed",
    "timedDuration": 5.0,
    "transitionSmoothing": 0.3,
    "flipCamera": true,
    "affectsEnemies": true,
    "affectsItems": true,
    "zoneTint": "#800080",
    "flipVfx": "spin_transition",
    "enterSfx": "gravity_shift_whoosh"
  }
}
```

### Ladder Climbing

**Source Game:** Castlevania (ladder climbing), Mega Man, Terraria, Mario (vine climbing)

**Description:** Vertical climbable objects (ladders, vines, ropes) that the player can ascend and descend by pressing up or down. While on a ladder, the player is locked to the ladder's center axis and can move freely up and down at constant speed. Jumping off a ladder at any point transitions to normal air physics.

**Kid UX:** The child stamps "Ladder" objects (wooden ladders, vine ladders, rope ladders) from the decoration palette. Ladders snap to vertical alignment. In play, pressing up near a ladder causes the character to grab it and begin climbing. A climbing animation plays. Pressing jump at any time lets go. The child can set ladder speed: "Slow" (careful climb), "Normal", or "Fast" (scramble).

**LLM Automation:** Detects ladder collision (player within horizontal proximity + up input), transitions player to ladder state (locks X position to ladder center, enables vertical movement), handles climb input (up/down at ladder climb speed), manages jump-off (applies small upward impulse + releases ladder lock), generates climbing animation (hand-over-hand), renders ladder-specific VFX (dust particles falling from ladder), and handles ladder top/bottom transitions (auto-dismount at top).

**JSON Contract Extension:**
```json
{
  "ladderClimb": {
    "climbSpeed": 100,
    "grabRadiusX": 15,
    "lockToCenter": true,
    "jumpOffVelocityY": -200,
    "jumpOffVelocityX": 50,
    "autoDismountAtTop": true,
    "climbAnimation": "hand_over_hand",
    "ladderTypes": ["wooden", "vine", "rope", "chain"]
  }
}
```

### Portal Pad / Warp Point

**Source Game:** Portal (portal gun concept), Axiom Verge (teleportation), Hollow Knight (Stag Stations), Dark Souls (warp bonfires)

**Description:** Paired teleportation pads that instantly transport the player from one location to another. Unlike the single-target Blink ability, portal pads are pre-placed level objects that create persistent fast-travel links. Entering Pad A always transports to Pad B, and vice versa.

**Kid UX:** The child stamps "Portal Pad" objects in pairs. Each pad has a color and symbol (Blue-Star, Red-Moon, Green-Sun, etc.). A line connects paired pads in edit mode. In play, stepping on a pad causes the character to shrink with a sparkle, then grow at the destination pad. The child can set transition: "Instant" (no delay) or "Sparkle" (0.5s animation).

**LLM Automation:** Manages portal pad pairing (each pad linked to exactly one partner), detects player standing on portal pad, triggers teleport transition effect (shrink/grow sparkle), moves player to partner pad coordinates, maintains facing direction through teleport, generates portal glow and particle effects at both pads, handles cooldown between teleports (prevents immediate re-teleport), and ensures pads are visually distinct by color/symbol.

**JSON Contract Extension:**
```json
{
  "portalPad": {
    "pairs": [
      {"padA": {"x": 200, "y": 300, "color": "blue", "symbol": "star"},
       "padB": {"x": 800, "y": 300, "color": "blue", "symbol": "star"}}
    ],
    "transitionType": "sparkle",
    "transitionDuration": 0.5,
    "cooldown": 1.0,
    "maintainFacing": true,
    "padGlow": true,
    "enterSfx": "warp_sparkle",
    "exitSfx": "warp_appear"
  }
}
```

### Quick Drop / Fast Fall

**Source Game:** Celeste (fast fall), Super Smash Bros. (fast fall), most modern platformers

**Description:** Pressing down while airborne causes the player to fall at dramatically increased speed. Quick drop allows the player to control their descent timing precisely, enabling tight platforming sequences where the player must drop through gaps between hazards. Some implementations add a landing effect (small shockwave or dust burst) when fast-falling.

**Kid UX:** Enabled globally via the hero settings. In play, pressing down while in air causes the character to adopt a diving pose and fall at 2-3x normal speed. A wind trail effect streams above the character. On landing from a fast fall, a small dust burst plays. The child can toggle "Landing Shock" — a tiny AOE damage effect on fast-fall landing.

**LLM Automation:** Detects down input during air state, applies fast-fall gravity multiplier (typically 2.0-3.0x normal gravity), generates fast-fall visual effect (diving pose, wind trail above character), handles landing detection from fast-fall state, applies optional landing shockwave damage and VFX, manages fast-fall cancellation (releasing down returns to normal fall), and plays fast-fall SFX (wind rushing).

**JSON Contract Extension:**
```json
{
  "quickDrop": {
    "gravityMultiplier": 2.5,
    "input": "down_while_airborne",
    "divingPose": true,
    "windTrail": true,
    "landingDustBurst": true,
    "landingShockwave": false,
    "shockwaveDamage": 2,
    "shockwaveRadius": 30,
    "cancelOnRelease": true,
    "sfx": "wind_rush"
  }
}
```

### Sticky Surface / Climbable Wall

**Source Game:** Celeste (certain walls allow infinite clinging), Mega Man X (certain walls), Monster Hunter (spider webs)

**Description:** Special wall surfaces that allow the player to cling indefinitely without sliding. Unlike normal wall-jump surfaces where the cling timer eventually expires, sticky surfaces let the player hang forever, plan their next move, and jump off at their leisure. Sticky surfaces are typically visually distinct (mossy walls, honeycombs, spider webs).

**Kid UX:** The child stamps "Sticky Wall" zone strips (green mossy texture, honeycomb pattern, or web pattern). In play, jumping onto a sticky wall causes the character to cling without sliding — no timer, no panic. The character can hang there indefinitely, even letting go of the controls. Pressing jump kicks off normally. The child can mix sticky and normal walls in the same level.

**LLM Automation:** Detects sticky wall collision during air state, applies infinite cling (no slide, no timer), renders sticky wall visual distinction (moss, honey, web overlay), generates cling pose animation (character pressed against wall with grip VFX), handles jump-off from sticky wall (normal wall jump physics), and ensures sticky wall zones override default wall-jump slide behavior.

**JSON Contract Extension:**
```json
{
  "stickySurface": {
    "clingType": "infinite",
    "slideSpeed": 0,
    "visualStyles": ["mossy", "honeycomb", "spider_web", "magnetic"],
    "jumpOffVelocityX": 200,
    "jumpOffVelocityY": -250,
    "gripVfx": "surface_cling_particles",
    "overridesDefaultWallBehavior": true
  }
}
```

### Zip Line / Tightrope

**Source Game:** Donkey Kong Country (rope rails), Zelda (tightropes), Spider-Man (web zip)

**Description:** A diagonal or horizontal line that the player can grab and slide along. Zip lines are one-way — the player grabs at the high end and slides to the low end by gravity. Tightropes are horizontal and require careful balancing (the player can walk across but may fall off if moving too fast). Both provide traversal across wide gaps.

**Kid UX:** The child stamps "Zip Line" objects by drawing a line between two points. The line auto-angles downward. In play, jumping near the high end causes the character to grab the zip line and slide down with a zipping sound. "Tightrope" variants (horizontal lines) require the child to balance — a "wobble" animation plays and moving too fast causes a fall. The child can place zip lines at any angle.

**LLM Automation:** Generates zip line path from drawn points (spline interpolation), detects player proximity to zip line entry point, transitions player to zip state (slides along line at gravity-accelerated speed), handles zip dismount at end point (automatic jump-off), generates zip line visual (cable with pulley handle), plays zipping SFX with pitch increasing with speed, manages tightrope balance mechanic (wobble meter based on movement speed), and handles fall-off on tightrope (if wobble exceeds threshold).

**JSON Contract Extension:**
```json
{
  "zipLine": {
    "type": "zip_line|tightrope",
    "acceleration": 150,
    "maxSpeed": 400,
    "entryRadius": 30,
    "autoDismount": true,
    "dismountVelocityY": -100,
    "tightropeWobbleThreshold": 0.7,
    "tightropeMaxWalkSpeed": 80,
    "visual": "cable_with_pulley",
    "sfx": "zip_pitch_increase"
  }
}
```

### Moving Platform / Track System

**Source Game:** Celeste (moving blocks), Super Mario (platforms on tracks), Terraria

**Description:** Platforms that follow a predefined path (straight, looping, or back-and-forth) at a set speed. The player can stand on moving platforms and be carried along their path. Track systems allow the child designer to draw complex platform routes. Moving platforms can be solid (carry the player) or semisolid (pass-through from below).

**Kid UX:** The child stamps a "Moving Platform" and then draws its path by dragging (dotted line shows the route). Tapping the platform opens speed options: "Slow Ride", "Cruise", or "Fast Dash". Loop and back-and-forth modes are toggleable. In play, the platform follows the drawn path smoothly. The child can also stamp "Track Switch" levers that change platform routes.

**LLM Automation:** Generates platform path from drawn points (Catmull-Rom spline for smooth curves), manages platform position along path over time, handles player-parenting when standing on platform (player moves with platform), supports path modes (loop, back-and-forth, one-shot), manages track switch states (alternative paths activated by switches), generates platform movement animation, and ensures platform collision is consistent throughout movement.

**JSON Contract Extension:**
```json
{
  "movingPlatform": {
    "pathType": "drawn_spline",
    "pathSmoothing": "catmull_rom",
    "speed": 100,
    "movementMode": "loop|back_forth|one_shot",
    "waitAtEndpoints": 1.0,
    "carryPlayer": true,
    "semisolid": false,
    "trackSwitches": true,
    "easing": "ease_in_out",
    "pathPreview": "dotted_line"
  }
}
```

### Screen Wrap

**Source Game:** Asteroids, Pac-Man, various indie platformers

**Description:** When the player exits one edge of the screen, they reappear on the opposite edge. Screen wrap creates interesting traversal and combat possibilities — the player can jump off the top and fall from the bottom, or walk off the right and appear on the left. This is typically a level-specific mechanic for puzzle-oriented stages.

**Kid UX:** The child stamps "Wrap Edge" markers on any or all screen edges. An arrow icon on each edge shows the wrap direction. In play, walking off the right edge causes the character to smoothly slide in from the left. The child can enable wrap on: horizontal only, vertical only, or all edges. A "Wrap Zone" stamp limits screen wrap to specific areas.

**LLM Automation:** Detects player position relative to screen/viewport edges, manages wrap transition (player exits one edge, appears at opposite edge), handles wrap on horizontal edges (left-right), vertical edges (top-bottom), or both, generates wrap visual effect (character fades out at exit edge, fades in at entry edge), ensures wrapped entities (player, projectiles, items) maintain velocity through wrap, and supports camera handling during wrap (smooth camera adjustment or dual-view).

**JSON Contract Extension:**
```json
{
  "screenWrap": {
    "wrapHorizontal": true,
    "wrapVertical": false,
    "affectsPlayer": true,
    "affectsProjectiles": true,
    "affectsItems": false,
    "wrapVfx": "fade_transition",
    "maintainVelocity": true,
    "cameraMode": "smooth_adjust"
  }
}
```

### Super Emeralds / Flight Transformation

**Source Game:** Sonic 3 & Knuckles (Super Sonic flight), NiGHTS (full flight mode)

**Description:** Collecting all special items (typically 7 emeralds) transforms the player into a super-powered form with enhanced speed, invincibility, and the ability to fly. The super form has a time limit that drains while active but can be extended by collecting rings or other energy items. This serves as both a reward for thorough exploration and an empowerment fantasy.

**Kid UX:** The child stamps 7 "Emerald" collectibles throughout the level (hidden in question blocks, behind walls, in hard-to-reach spots). A single toggle sets "Super Form Enabled." When the player collects all 7, a dramatic transformation sequence plays — the character glows golden, gains a sparkling aura, and sprouts energy wings. Flight controls appear (up to fly higher, down to descend). The super meter drains gradually; collecting rings refills it.

**LLM Automation:** Tracks emerald collection state (0-7), triggers transformation sequence on 7th emerald (cinematic flash, sprite change, music shift), applies super form modifications (invincibility, 2x speed, flight ability, aura trail), manages super meter (drains over time, refills on ring collection), handles super form expiration (character returns to normal with a fade), generates aura trail particles during super form, and plays transformation/expiration SFX.

**JSON Contract Extension:**
```json
{
  "superForm": {
    "requiredItems": 7,
    "itemType": "emerald",
    "duration": 30,
    "effects": {
      "invincible": true,
      "speedMultiplier": 2.0,
      "flightEnabled": true,
      "destroyOnContact": true,
      "auraTrail": true
    },
    "meterDrainRate": 1.0,
    "ringRefillAmount": 5,
    "transformVfx": "golden_flash_sequence",
    "expireVfx": "fade_to_normal",
    "musicChange": true
  }
}
```



### Climbable Net / Mesh

**Source Game:** Donkey Kong Country (rope nets), Monster Hunter (vine walls), various platformers

**Description:** A grid-like climbable surface that the player can scale in any direction — up, down, left, right, and diagonally. Unlike ladders (vertical only), nets allow full 2D movement. The player is locked to the net's grid while climbing and can jump off at any time. Nets are often placed over large gaps or hazardous areas.

**Kid UX:** The child stamps "Climbable Net" grid objects (rope mesh, chain-link, or vine web patterns). Nets can be resized by dragging. In play, jumping onto a net causes the character to grab it and climb in any direction using directional input. A climbing animation plays with hand-over-hand movement. Pressing jump launches the character off the net in the input direction.

**LLM Automation:** Detects net collision and transitions player to net-climbing state, locks player to net grid and enables 8-directional movement at reduced speed, handles jump-off from net (applies velocity in input direction), generates climbing animation (hands and feet grip the net mesh), renders net-specific VFX (net sway, dust particles), and manages net-to-net transitions (adjacent nets allow seamless climbing between them).

**JSON Contract Extension:**
```json
{
  "climbableNet": {
    "climbSpeed": 80,
    "directions": 8,
    "jumpOffVelocity": 200,
    "gridSnap": true,
    "visualStyles": ["rope_mesh", "chain_link", "vine_web"],
    "swayAnimation": true,
    "netToNetTransition": true
  }
}
```

### Ceiling Swing / Spider Hang

**Source Game:** Spider-Man (web-swinging), Donkey Kong (vine hanging), Metroid (ceiling grip), various indie games

**Description:** The player can attach to ceilings and certain overhead objects, hanging upside-down and swinging. From the hanging state, the player can swing back and forth to build momentum, then release to launch across gaps. Ceiling hanging provides access to secret areas and alternate paths through levels.

**Kid UX:** The child stamps "Ceiling Hook" or "Overhead Bar" objects on ceilings and overhangs. In play, jumping up to an overhead bar causes the character to grab and hang upside-down. Left/right input swings the character like a pendulum. Pressing jump at the peak of a forward swing launches the character with momentum. The child can stamp "Monkey Bar" sequences — multiple bars in a row for continuous swinging.

**LLM Automation:** Detects overhead bar collision with upward jump, transitions player to hanging state (upside-down, locked to bar position), implements pendulum swing physics (gravity-driven arc with momentum conservation), calculates release velocity from swing angle and angular momentum, generates hanging/swinging animations (character dangles, arms extended), renders appropriate VFX (swing dust, grip sparks on bar), and manages bar-to-bar transitions (reaching distance of next bar auto-grabs).

**JSON Contract Extension:**
```json
{
  "ceilingSwing": {
    "grabRadius": 24,
    "swingGravity": 300,
    "maxSwingAngle": 80,
    "releaseVelocityMultiplier": 1.3,
    "barToBarAutoGrab": true,
    "barToBarDistance": 100,
    "hangingAnimation": "upside_down_dangle",
    "swingVfx": "bar_grip_sparkle",
    "releaseVfx": "launch_dust_burst"
  }
}
```

### Water Current / Flow Direction

**Source Game:** Ecco the Dolphin (water currents), Mario (water currents in New Soup), Ori (water flows), Celeste (water sections)

**Description:** Underwater zones with directional currents that push the player and entities in a fixed direction. Swimming against a strong current is slow or impossible; swimming with it provides a speed boost. Currents can change direction periodically (tidal currents) or be switch-activated, creating timing puzzles.

**Kid UX:** The child stamps "Water Current" zones within water areas. Direction arrows show flow direction and strength (single arrow = gentle, triple arrow = strong). In play, the current pushes the character and all swimming entities. The child can stamp "Current Switch" levers that reverse flow direction. Strong currents that are too powerful to swim against require the player to wait for a switch or find an alternate path.

**LLM Automation:** Applies continuous directional force to player and entities within current zone while underwater, scales player swim speed (reduced against current, boosted with current), manages current direction switching (via switches or timed tidal changes), generates current visual effects (flowing bubble trails, directional particle streams), handles current sound effects (gentle flow to rushing torrent based on strength), and applies current force to projectiles and items.

**JSON Contract Extension:**
```json
{
  "waterCurrent": {
    "forceX": 150,
    "forceY": 0,
    "swimAgainstMultiplier": 0.3,
    "swimWithMultiplier": 1.5,
    "switchable": true,
    "tidalMode": false,
    "tidalInterval": 10,
    "visual": "flowing_bubble_trails",
    "sfx": "water_flow",
    "tooStrongToSwimAgainst": false
  }
}
```

### Cloud Platform / Vanishing Platform

**Source Game:** Super Mario (vanishing platforms), Celeste (crumbling blocks), Donkey Kong (cloud platforms), various platformers

**Description:** Platforms that disappear shortly after being stepped on, reappearing after a cooldown. Cloud platforms have a fluffy white appearance and begin to dissipate (fade and shrink) when the player stands on them, fully vanishing after 1-2 seconds. They reappear after 3-5 seconds. This creates tense platforming sequences where the player must keep moving.

**Kid UX:** The child stamps "Cloud Platform" objects (fluffy white platforms with a gentle bobbing animation). Tapping a cloud opens a timer toggle: "Patient Cloud" (3s before vanish, 5s respawn), "Nervous Cloud" (1.5s before vanish, 3s respawn), or "Storm Cloud" (0.8s before vanish, 2s respawn). In play, stepping on a cloud causes it to darken and shrink. If the player jumps off before it fully vanishes, it returns to normal. If it vanishes beneath them, they fall.

**LLM Automation:** Detects player standing on cloud platform, starts vanish timer on contact, renders vanish visual progression (platform fades from opaque → translucent → gone over the timer duration), handles platform collision toggle (solid → pass-through when vanished), manages respawn timer (platform reappears with fade-in), generates vanish VFX (cloud puffs dispersing) and respawn VFX (cloud re-forming), and ensures player falls through if standing on platform when it vanishes.

**JSON Contract Extension:**
```json
{
  "cloudPlatform": {
    "vanishTime": 2.0,
    "respawnTime": 4.0,
    "vanishVfx": "cloud_puff_dispersal",
    "respawnVfx": "cloud_reform",
    "bobbingAnimation": true,
    "bobAmplitude": 5,
    "bobSpeed": 1.0,
    "fadeBeforeVanish": true,
    "respawnFadeIn": true,
    "allowJumpOffToSave": true
  }
}
```



---

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



---

# Chapter 3: Character Classes, Forms & Abilities

> *"Who do I want to be today?"* — The most exciting question a 5-year-old can ask before starting a game.

This chapter captures the full spectrum of character identity systems found across AAA and indie games, reimagined for stamp-based creation. Every feature here answers a child's desire to transform, specialize, and grow. From the moment a kid stamps their first Job Badge to the triumphant activation of a Limit Break, these systems make the hero feel personal. The LLM handles all stat-balancing, form-switching logic, and ability-cooldown management — invisible complexity that leaves only magic on the screen.

---

## 3.1 Class & Job Systems

The foundation of character identity. These features let a child answer the fundamental RPG question — "what do I want to be?" — with nothing more complicated than a tap on a stamp. Each system draws from decades of class-based design, distilled to its purest, most expressive essence.

#### Job Badge System

- **Source Game:** *Final Fantasy* series (Warrior, Black Mage, White Mage, Thief, Dragoon, Blue Mage, etc.)
- **Description:** The player character can collect **Job Badges** scattered through the level. Each badge changes the character's outfit, abilities, and playstyle when equipped. Warrior grants a sword swipe and shield block. Mage launches fireball projectiles from a wand. Thief enables a fast dash and reveals hidden coins. Dragoon unlocks a super-high jump and devastating dive attack. Blue Mage copies enemy abilities after touching them. Jobs are represented as colorful badge stamps that can be swapped at any time.
- **Kid UX:** The child stamps **Job Badge** items throughout the level. Tapping a badge on the canvas opens a sticker picker to choose the job — a sword icon for Warrior, a wand for Mage, a mask for Thief, a spear for Dragoon, a rainbow crystal for Blue Mage. During play, touching a badge immediately swaps the character's outfit and abilities with a swirl effect. A **Job Hub** stamp lets the player swap between collected jobs at any time.
- **LLM Automation:** Generates job-appropriate sprite variations (hat swaps, weapon additions), implements each job's unique attack pattern and movement modifier, handles job-switching state management, auto-balances job power so no single job dominates, and generates unique sound effects per job action. The LLM also manages job persistence across levels when configured.
- **JSON Contract Extension:**
```json
{
  "jobSystem": {
    "availableJobs": ["warrior", "mage", "thief", "dragoon", "blueMage", "monk"],
    "switchMethod": "badgeTouchOrJobHubMenu",
    "persistBetweenLevels": true,
    "autoBalanceJobs": true,
    "spriteVariants": "autoGenerated"
  }
}
```

#### Paradigm Role Switcher

- **Source Game:** *Final Fantasy XIII* (Paradigm Shift — Commando, Ravager, Sentinel, Synergist, Saboteur, Medic)
- **Description:** Up to three companion characters fight alongside the player, and each can be assigned one of six combat roles. At any time during gameplay, the player can tap a role icon to instantly switch all companions' behavior. Fighter attacks enemies aggressively. Defender draws enemy attention and blocks. Healer restores player health. Booster gives the player stat buffs. Trickster applies status ailments to enemies. Blaster builds a combo meter for devastating finishers.
- **Kid UX:** The child stamps **Buddy Start Points** and assigns each a role via stickers. During playtest, role icons appear as large, colorful buttons at the bottom of the screen. Tapping any button instantly swaps all buddies to that role set with a flash effect. Roles are shown with simple icons: a sword for Fighter, a shield for Defender, a heart for Healer, an upward arrow for Booster, a sparkle for Trickster, and an explosion for Blaster.
- **LLM Automation:** Implements six distinct AI behavior trees per role, manages role-switch state transitions, auto-generates role-specific visual indicators (aura colors, weapon glows), handles companion positioning logic (Defender moves to front, Healer stays back), and computes combo multipliers from the Blaster role. All six AI profiles run simultaneously, with the active role determining which behavior tree takes priority.
- **JSON Contract Extension:**
```json
{
  "paradigmSystem": {
    "roles": ["fighter", "defender", "healer", "booster", "trickster", "blaster"],
    "buddyCount": 3,
    "switchCooldown": 2.0,
    "aiBehaviors": "roleDetermined",
    "visualIndicators": "autoGenerated"
  }
}
```

#### Class Evolution Tree

- **Source Game:** *Trials of Mana* (Fighter → Knight / Berserker, Apprentice → Sorcerer / Cleric)
- **Description:** As the player collects **experience stars** throughout levels, their character can evolve into advanced classes at **Class Statues**. Each class branches into two distinct options. Starting as a Novice, they can become a Fighter (melee focus) or an Apprentice (magic focus). Fighter evolves into Knight (balanced defender) or Berserker (high damage, low defense). Apprentice evolves into Sorcerer (elemental magic) or Cleric (healing support). Each evolution grants a new visual outfit and signature ability.
- **Kid UX:** The child stamps **Class Statues** in their levels. When playtesting, after collecting enough stars, the player's character glows and a prompt appears: *"Touch statue to evolve!"* At the statue, two large stickers show the evolution choices with clear icons. The child taps one to pick. The character transforms with a celebratory animation — new outfit, new particle effects, and a banner announcing the new class name.
- **LLM Automation:** Tracks star collection as invisible experience points, determines when evolution thresholds are met, generates the evolution branch UI showing two clear choices with icons and stat previews, implements the stat and ability changes per class, auto-generates upgraded sprite variants for each evolution path, and ensures each branch feels meaningfully distinct through differentiated movement, attack, and visual profiles.
- **JSON Contract Extension:**
```json
{
  "classTree": {
    "startingClass": "novice",
    "tiers": [
      {"tier": 1, "branches": ["fighter", "apprentice"]},
      {"tier": 2, "fighter_branches": ["knight", "berserker"], "apprentice_branches": ["sorcerer", "cleric"]}
    ],
    "evolutionThreshold": "starsCollected",
    "statueType": "classStatue",
    "autoSprites": true
  }
}
```

#### Blue Mage Copy System

- **Source Game:** *Final Fantasy* series (Blue Mage — learns enemy abilities by experiencing them)
- **Description:** A special job variant where the player character learns new abilities by touching or being hit by enemy attacks. Each enemy has a hidden teachable ability. The first time the player encounters a fire-breathing enemy while in Blue Mage mode, they learn **Fire Breath**. The first time they touch an electric enemy, they learn **Thunder Spark**. The ability library grows organically through play, turning every enemy encounter into a potential unlock.
- **Kid UX:** The child stamps a **Blue Mage Badge** — it has a rainbow crystal icon. During play, when the Blue Mage touches an enemy, a brief *"Learn!"* popup appears with the ability icon. The learned ability is added to a simple ability wheel (three icons visible at a time, swipe to see more). Each learned ability shows a tiny portrait of the enemy that taught it. Kids love the "gotta catch 'em all" feeling of filling their ability collection.
- **LLM Automation:** Maintains an enemy-to-ability mapping database, detects learning triggers (touch enemy while in Blue Mage mode), validates that the ability hasn't been learned already, generates the Learn popup, adds the ability to the player's loadout, manages ability wheel UI updates, and auto-balances copied ability damage relative to the original enemy's version (typically 80% of enemy power to preserve game balance).
- **JSON Contract Extension:**
```json
{
  "blueMage": {
    "learnTrigger": "touchEnemyWhileBlueMage",
    "abilityLibrary": [],
    "maxAbilities": 20,
    "damageScaling": 0.8,
    "learnAnimation": "rainbowSparkle",
    "enemyAbilityMap": {
      "fire_slime": "fireBreath",
      "thunder_bat": "thunderSpark",
      "ice_wolf": "iceFang"
    }
  }
}
```

#### Relic Power-Up Gating

- **Source Game:** *Castlevania: Symphony of the Night* (Soul of Bat, Leap Stone, Form of Mist, Gravity Boots)
- **Description:** The player collects **Relic** items — permanent power-ups that grant new traversal abilities which in turn unlock previously inaccessible areas of the map. Each relic opens new design space: the **Bat Relic** enables flight, the **Mist Relic** lets the player pass through barred gates, the **Leap Stone** grants a double jump, and **Gravity Boots** allow walking on ceilings. Relics are placed in the world as collectible stamps and create a natural progression curve — early areas require no relics, mid-game areas need one or two, and late-game challenges demand mastery of all relic abilities combined.
- **Kid UX:** The child stamps a **Relic Chest** on the canvas. A popup shows a big, colorful icon of the relic inside — bat wings for Bat Form, a swirl cloud for Mist Form, a spring boot for Leap Stone. Tapping the chest places the relic as a collectible. When the player opens the chest during play, a dramatic animation plays and the new ability is permanently unlocked. Areas that require specific relics are marked with **colored sparkles** matching the relic icon. The relic collection screen shows all acquired relics as glowing badges and locked ones as silhouettes with a hint about where to find them.
- **LLM Automation:** Maintains a directed acyclic graph of gating dependencies (Bat Relic enables flight paths, Mist Form enables barred gates, Leap Stone enables high platforms), auto-validates map reachability to ensure no soft-locks, calculates which areas become accessible after each relic acquisition and highlights them on the map, handles relic state persistence across all sessions, and auto-generates appropriate sparkles and visual indicators on gated areas based on the required relic type.
- **JSON Contract Extension:**
```json
{
  "relics": [
    {"id": "soulOfBat", "name": "Bat Form", "unlockType": "flight", "prereq": null},
    {"id": "leapStone", "name": "Super Jump", "unlockType": "doubleJump", "prereq": null},
    {"id": "formOfMist", "name": "Mist Form", "unlockType": "phaseThroughGates", "prereq": null},
    {"id": "gravityBoots", "name": "Ceiling Walk", "unlockType": "ceilingWalk", "prereq": "leapStone"}
  ],
  "gates": [
    {"id": "mistGate1", "requiredRelic": "formOfMist", "regionId": "underground"},
    {"id": "highLedge1", "requiredRelic": "leapStone", "regionId": "skyTower"}
  ],
  "reachabilityGraph": {"nodes": [], "edges": []}
}
```

#### Equipment Slot System

- **Source Game:** *Castlevania: Symphony of the Night* (Right Hand, Left Hand, Head, Body, Accessory)
- **Description:** A five-slot equipment system governs the character's visible gear and stats: **Right Hand** (weapon), **Left Hand** (shield or secondary weapon), **Head** (helmet or hat), **Body** (armor or clothing), and **Accessory** (rings, amulets, charms). Each slot accepts one item. Equipment changes the character's visible sprite appearance and modifies core stats — weapons increase attack power, armor increases defense, helmets may grant special vision effects, and accessories provide unique passive bonuses. The system creates a tangible sense of character building through physical items.
- **Kid UX:** The child stamps **Equipment** items throughout the level — swords, shields, helmets, armor pieces, rings. When the player collects an equipment item, a **body outline popup** appears with five glowing drop zones: head, body, left hand, right hand, and accessory slot. The child drags the item into the matching slot. Items snap into place with a satisfying sound and the character sprite updates instantly to show the equipped gear — a wooden sword appears in hand, a knight helmet appears on head, a cape flows behind. Tapping any slot shows the currently equipped item and its visual effect. Set bonuses are highlighted when multiple matching items are equipped.
- **LLM Automation:** Computes aggregate stats from all equipped items (attack = weapon base + STR modifier, defense = armor + helmet + shield values, special = accessory passives), handles equipment-exclusive interactions (certain shields boost certain swords, matched sets grant bonus effects), manages resistance calculations (fire armor reduces fire damage by a percentage), auto-generates equipment-appropriate sprite composites by layering gear visuals onto the base character, validates equipment level requirements, and manages inventory for unequipped items.
- **JSON Contract Extension:**
```json
{
  "equipmentSlots": ["rightHand", "leftHand", "head", "body", "accessory"],
  "equipment": [
    {"id": "woodenSword", "slot": "rightHand", "stats": {"attack": 5}, "element": "slash"},
    {"id": "ironShield", "slot": "leftHand", "stats": {"defense": 3}, "blockChance": 0.2}
  ],
  "setBonuses": [
    {"items": ["knightHelm", "knightArmor", "knightShield"], "bonus": "damageReductionPlus10"}
  ]
}
```

---

## 3.2 Transformation Systems

Transformation is the purest expression of childhood imagination — the desire to become something bigger, faster, stranger. These features capture that magic, from invincible super forms to absurd object possession, all triggered by simple stamps and taps.

#### Super Transformation Emeralds

- **Source Game:** *Sonic 3 & Knuckles / Sonic Mania* (Chaos Emeralds → Super Sonic)
- **Description:** Hidden throughout the level are seven special gems (Emeralds). Collecting all seven transforms the player character into a glowing, invincible super form with enhanced speed, a sparkly aura trail, and the ability to destroy any enemy on contact. The super form lasts for a timed duration with a gradually draining energy meter. Hidden emerald locations can be placed via stamp anywhere in the level — inside question blocks, behind walls, floating above pits.
- **Kid UX:** The child stamps the seven **Emerald** stamps anywhere in the level. A single toggle sets *"Super Form Enabled."* When a kid playtests and finds all seven, their character automatically transforms with a big flashy animation — golden glow, music change, aura trail. A rainbow energy meter appears and slowly drains. No stat editing needed — the system handles everything. Finding that last emerald triggers an automatic, cinematic transformation sequence.
- **LLM Automation:** Tracks emerald collection state across the level, triggers the transformation sequence (invincibility, aura particles, speed boost, music change), implements the countdown timer with visual meter depletion, handles the super-jump and enemy-destruction-on-contact logic, restores normal form when energy expires, and auto-balances super form duration based on level length (typically 20-40 seconds).
- **JSON Contract Extension:**
```json
{
  "collectibles": {
    "emeraldSet": {
      "count": 7,
      "transformTo": "superForm",
      "durationSeconds": 30,
      "effects": ["invincible", "speed_x2", "destroyOnContact", "auraTrail"],
      "drainRate": "gradual"
    }
  }
}
```

#### Drive Form Wardrobe

- **Source Game:** *Kingdom Hearts II* (Valor Form, Wisdom Form, Master Form, Final Form, Limit Form, Anti Form)
- **Description:** The player can stamp a **Wardrobe Gate** object. When the player character interacts with it, they switch to an alternate form with different abilities. Each form has a distinct visual style and power set: **Speed Form** (faster running, double jump), **Magic Form** (ranged spells, floating hover), **Power Form** (stronger attacks, ground pound shockwave), and **Flight Form** (gliding, aerial hover). Forms can be unlocked progressively or available from the start. Each form changes the character's color palette and outfit silhouette.
- **Kid UX:** The child stamps a **Wardrobe Gate** on the canvas. A sticker picker shows available forms with cute icons: bunny ears for Speed, a star wand for Magic, a muscle badge for Power, wings for Flight. The child taps one to assign. During play, walking through the gate instantly transforms the character with a sparkly animation — the sprite morphs, particles burst, and a form-specific jingle plays. A small icon in the corner shows the active form. Walking through again reverts to normal.
- **LLM Automation:** Manages form state switching with smooth animation blending, applies form-specific movement modifiers (Speed = 1.5x velocity, Magic = hover gravity, Power = 2x damage, Flight = glide physics), auto-generates form-unique animations from the base character sprite, handles form exit conditions (time limit or manual revert at the gate), and ensures each form's abilities feel meaningfully distinct through differentiated physics constants and attack hitboxes.
- **JSON Contract Extension:**
```json
{
  "objects": [{
    "type": "wardrobeGate",
    "availableForms": ["speed", "magic", "power", "flight"],
    "formDuration": "infiniteOrTimed",
    "revertOnDamage": false,
    "transformFx": "sparkleBurst"
  }]
}
```

#### Copy Ability System

- **Source Game:** *Kirby* series (30+ copy abilities — Fire, Ice, Sword, Cutter, Bomb, Spark, Stone, Wheel, Hammer, etc.)
- **Description:** The player can absorb enemy powers by touching them, transforming their appearance and gaining new attacks. Each copy ability comes with a visual **hat/costume change** and a signature one-button attack. Fire ability breathes a flame stream. Sword ability swings a blade with a three-hit combo. Stone ability turns the character into an invincible heavy rock that drops from the air. Bomb ability places timed explosives. The hat system makes each ability instantly recognizable — kids learn to identify powers by silhouette alone.
- **Kid UX:** Enemy stamps that grant copy abilities have a small star icon in the corner. When the player touches them, a transformation animation plays — the character dons a themed hat or costume. An **ability palette** shows available copy abilities. Tap to select or cycle through. Each ability has a simple one-button attack. The hat persists on the character sprite until the ability is discarded (tap a "drop" button) or the player takes damage. Copy abilities can be pre-assigned to enemies in edit mode via a simple sticker picker.
- **LLM Automation:** Manages copy ability state machine with 30+ ability variants, swaps player sprite and animations per ability (hat compositing + body animation), implements ability-specific attacks and projectiles (flame stream hitbox, sword slash arc, bomb fuse timer), handles ability loss on taking damage (hat flies off with physics), and auto-generates hat variants for custom abilities by compositing themed accessories onto the base sprite.
- **JSON Contract Extension:**
```json
{
  "copyAbilities": [{
    "id": "fire",
    "sourceEnemy": "hothead",
    "attack": {"type": "fireBreath", "damage": 2, "range": 80},
    "animation": "breathFire",
    "hatSprite": "fire_hat.png"
  }]
}
```

#### Copy Ability Mixing

- **Source Game:** *Kirby 64: The Crystal Shards / Kirby Star Allies* (Fire + Sword = Flaming Sword, Ice + Bomb = Ice Bomb)
- **Description:** Two copy abilities can be combined to create a **hybrid ability** with unique properties and spectacular visuals. Fire + Sword produces a **Flaming Sword** that leaves a fire trail on every swing. Ice + Bomb creates an **Ice Bomb** that freezes enemies in its blast radius. Spark + Stone becomes a **Lightning Boulder** that rolls with crackling energy. The combination recipes create emergent depth — kids experiment endlessly to find all the hybrids.
- **Kid UX:** Player has one active ability. When absorbing a different ability, a **"Mix!"** prompt appears with a sparkle. Tap to combine. A visual fusion animation plays — the two hat sprites merge with a swirl effect. The new hybrid ability icon shows both parent icons overlapping with a glow effect. During play, the hybrid attack triggers both parent effects simultaneously. The LLM auto-generates combination previews so kids can see what mixing two abilities will create before committing.
- **LLM Automation:** Defines combination recipes (25+ unique combos in the base system), generates hybrid attack behaviors by compositing parent attack attributes (Fire's burn + Sword's slash = flaming slash with burn DoT), manages ability inheritance and combination restrictions (some abilities cannot mix), creates hybrid visual effects by blending parent particle systems, and auto-balances hybrid abilities so they're stronger than either parent individually but not game-breaking.
- **JSON Contract Extension:**
```json
{
  "abilityMixes": [
    {"parent1": "fire", "parent2": "sword", "output": "flamingSword", "attack": "fireSlash"},
    {"parent1": "ice", "parent2": "bomb", "output": "iceBomb", "attack": "freezeExplosion"}
  ]
}
```

#### Super Abilities

- **Source Game:** *Kirby's Return to Dream Land / Triple Deluxe* (Ultra Sword, Monster Flame, Flare Beam, Snow Bowl)
- **Description:** Ultra-powerful versions of copy abilities that destroy everything on screen. Activated by touching a **glowing rainbow enemy** or a special item stamp. Temporary and visually spectacular — the screen flashes, the character grows to giant size, and a single button press unleashes a screen-clearing attack. The **Ultra Sword** slashes across the entire screen. The **Monster Flame** sends a massive fire dragon across the level. The **Snow Bowl** freezes and shatters every enemy. These are rare, cinematic power moments that make kids cheer.
- **Kid UX:** A **rainbow-colored enemy/item stamp** with sparkles indicates a super ability source. When touched, the player transforms with a massive visual effect — screen flash, giant growth, music shift. A single **"SUPER!"** button appears. Tapping it unleashes the screen-clearing attack with a dramatic animation. After 10 seconds, the power fades and normal gameplay resumes. The rarity of super ability sources makes each one feel special and earned.
- **LLM Automation:** Manages super state timer (typically 10 seconds), implements screen-clearing attacks with massive hitboxes that cover the entire play area, scales damage to destroy all non-boss enemies instantly (bosses take heavy damage but survive), handles visual effects (screen shake, full-screen flash, particle explosions), prevents super ability spam by limiting sources to 1-2 per level, and manages the return to normal form with a smooth transition.
- **JSON Contract Extension:**
```json
{
  "superAbility": {
    "baseAbility": "sword",
    "duration": 10,
    "attack": "ultraSwordSlash",
    "screenClear": true,
    "invincible": true,
    "bossDamagePercent": 0.25
  }
}
```

#### Mouthful Mode

- **Source Game:** *Kirby and the Forgotten Land* (Car, Traffic Cone, Vending Machine, Water Balloon, Staircase possession)
- **Description:** The player character inhales real-world objects and takes control of them. Each object grants unique movement or attack capabilities. The **Car** moves fast, jumps over gaps, and charges through barriers. The **Traffic Cone** drills downward through soft ground. The **Vending Machine** shoots cans as projectiles. The **Water Balloon** grows as it absorbs water, then bursts to flood areas. The **Staircase** unfolds to reach high platforms. Mouthful Mode transforms platforming into absurd, creative problem-solving.
- **Kid UX:** Special **large object stamps** (oversized compared to normal items) appear in the palette. When the player approaches, an **"Inhale!"** prompt appears. Tap to watch the character stretch and wrap around the object in a comical animation. Controls change to match the object — the Car has a gas pedal and steering buttons, the Cone has a drill button, the Vending Machine has a shoot button. A **"Spit Out"** button returns the object and restores normal form. Object stamps are categorized in a special "Mouthful" palette section.
- **LLM Automation:** Manages possession state, swaps player collider and physics to match object shape (Car = rectangle collider with wheel physics, Cone = narrow downward hitbox), implements object-specific controls and abilities per Mouthful type, handles object release and extraction animation, manages collision responses unique to each form (Car breaks barriers, Cone drills through dirt blocks), and auto-generates Mouthful-appropriate interaction zones when the child places a Mouthful object in the level.
- **JSON Contract Extension:**
```json
{
  "mouthfulMode": {
    "objectType": "car",
    "controls": {"move": "drive", "jump": "hop", "attack": "charge"},
    "speedMultiplier": 2.5,
    "canFloat": false,
    "specialCollision": ["break_barriers", "jump_gaps"]
  }
}
```

#### Morph Ball Compact Form

- **Source Game:** *Metroid* series (Samus Aran's signature Morph Ball)
- **Description:** The player transforms into a small ball to fit through tight spaces, roll through tunnels, and lay bombs. The Morph Ball is a traversal upgrade that opens up entirely new navigation paths — crawlspaces under platforms, narrow shafts between walls, and bomb-able block puzzles. The compact form sacrifices attack power for mobility and puzzle-solving capability.
- **Kid UX:** A **Morph Ball stamp** is placed on the character or collected as an upgrade. The player taps a "Roll" button to transform into a small round form. In tight tunnels, the player auto-transforms. A **Bomb button** appears in Morph Ball mode — tap to drop small explosives that destroy specific cracked blocks and damage enemies below. The ball rolls smoothly with left/right controls and has a satisfying bounce on jumps. Morph Ball-only passages are marked with a subtle visual indicator (slightly wider cracks, small openings).
- **LLM Automation:** Swaps player collider to a small circle (typically 8px radius), enables tunnel traversal through one-way collision zones, implements bomb placement with timed fuse and explosion radius, handles bomb-jump physics (player launched upward by their own bomb explosion, a classic Metroid technique), manages Morph Ball toggle state with smooth sprite swap, and auto-validates that Morph Ball passages are only traversable in ball form.
- **JSON Contract Extension:**
```json
{
  "morphBall": {
    "colliderRadius": 8,
    "rollSpeed": 150,
    "bombDamage": 1,
    "bombCooldown": 0.5,
    "bombJumpForce": 200,
    "autoTransformInTunnels": true
  }
}
```

#### Shapeshift Environment Morph

- **Source Game:** *NiGHTS into Dreams* (NiGHTS transforms into mermaid, bobsled, roller coaster car per zone)
- **Description:** When the player character enters a specific zone (water area, ice slope, sky rail), they **automatically morph** into a context-appropriate form. In water: **Mermaid Form** with swimming physics and underwater dash. On ice slopes: **Sled Form** with slide controls and momentum-based acceleration. On sky rails: **Coaster Form** with rail-grinding physics and boost pads. The morph is automatic and purely visual-plus-physics — no manual activation needed. The environment itself triggers the transformation.
- **Kid UX:** The child stamps a **Morph Zone** area stamp over a region of the level — Water Zone (blue overlay), Ice Zone (white overlay), or Rail Zone (yellow overlay). When they playtest, their character automatically transforms upon entering. The child can pick which morph form each zone uses from a sticker picker. Morph zones are visible in edit mode as colored overlays and subtly indicated in play mode (sparkle borders). The transition between forms is a smooth half-second animation with particle effects.
- **LLM Automation:** Detects zone overlap between player and morph regions, triggers the morph transition with smooth animation blend, swaps physics parameters per zone type (Water = buoyancy + drag + swim speed, Ice = reduced friction + momentum conservation, Rail = locked path following + speed boost from pads), and auto-generates morph sprites by compositing the character with themed elements (mermaid tail, sled base, coaster wheels).
- **JSON Contract Extension:**
```json
{
  "zones": [{
    "type": "morphZone",
    "zoneType": "water|ice|rail|wind",
    "morphForm": "mermaid|sled|coaster|balloon",
    "transitionSpeed": "smooth_0.5s",
    "physicsOverride": true
  }]
}
```

---

## 3.3 Badge, Charm & Passive Modifiers

Not every ability needs to be activated. These systems grant passive bonuses, modifiers, and loadout depth through simple equip-and-forget mechanics. The design philosophy here is "decisions before action" — kids choose their build, then play with the benefits.

#### Badge Equip System

- **Source Game:** *Super Mario Wonder* (Action Badges, Boost Badges, Expert Badges)
- **Description:** Players select one badge before entering a level that grants a special ability. Three categories provide clear decision framing: **Action Badges** add new moves (Parachute Cap for slow descent, Wall-Climb Jump for vertical scaling, Grappling Vine for gap crossing), **Boost Badges** grant passive bonuses (Coin Reward increases coin drops, Safety Bounce saves the player from one pitfall), and **Expert Badges** create risk/reward scenarios (Spring Feet auto-bounces, Invisibility makes the player undetectable but also hard to see). Badges are level-scoped — each level can have a different badge loadout.
- **Kid UX:** Before play, a **badge wheel** appears with all collected badges. Tap a badge icon to see an animation preview of its effect. Badges are color-coded: orange for Action, blue for Boost, yellow for Expert. The selected badge glows and shows a *"Ready!"* animation. During play, the badge's effect is always active — no button presses needed for most. The Parachute Cap deploys automatically when falling; the Wall-Climb sparkles show when near a wall. Badge effects are visually communicated so kids always know what their badge is doing.
- **LLM Automation:** Applies badge behavior modifications to the player controller at level start, manages badge-specific cooldowns and state, handles badge interactions with level elements (e.g., Grappling Vine auto-aims to nearest valid wall target), validates badge availability per level (some badges may be locked until certain conditions are met), and auto-balances badge effects to ensure no single badge trivializes level design.
- **JSON Contract Extension:**
```json
{
  "badgeSystem": {
    "availableBadges": ["parachuteCap", "wallClimb", "coinReward", "safetyBounce", "springFeet"],
    "badgeType": "action",
    "effect": "parachuteDescentOnFall",
    "categoryColors": {
      "action": "#FF8800",
      "boost": "#4488FF",
      "expert": "#FFCC00"
    }
  }
}
```

#### Dual Badge Combinations

- **Source Game:** *Super Mario Wonder* (Dual Badges — Parachute Cap + Floating High Jump)
- **Description:** After collecting both parent badges, **Dual Badges** randomly appear that combine two badge effects into one super-badge. The fusion creates emergent interactions: Parachute Cap + Floating High Jump gives both slow descent AND higher jumps, enabling unprecedented aerial navigation. Wall-Climb Jump + Grappling Vine creates a Spider-Climb badge that lets the player stick to and climb any surface. Dual badges are rare rewards for dedicated badge collectors.
- **Kid UX:** Two badge icons **fuse together** with a sparkle animation when a dual badge is available. The dual badge shows both parent icons side by side with a connecting glow. When equipped, both effects are active simultaneously. A thought-bubble preview appears showing the combined effect in action. Dual badges are color-coded purple to indicate their rarity. The LLM auto-generates valid combinations and prevents incompatible fusions.
- **LLM Automation:** Manages badge effect combination logic with validation for compatible pairings, applies both behavior modifications to the player controller simultaneously, handles conflicting effect resolution (e.g., one badge increases gravity, another decreases — the LLM computes a sensible compromise or prioritizes the stronger effect), and generates fusion recipes dynamically based on the badge collection state.
- **JSON Contract Extension:**
```json
{
  "badge": "dualParachuteFloat",
  "parentBadges": ["parachuteCap", "floatingHighJump"],
  "effects": ["parachuteDescent", "floatyJump"],
  "rarity": "dual",
  "color": "#AA44FF"
}
```

#### Charm System

- **Source Game:** *Hollow Knight* (40+ equippable Charms with Notch costs)
- **Description:** The player collects **Charms** — equippable badges that grant passive abilities and modify gameplay. Each Charm costs a certain number of **Notches** to equip; the player has limited Notches (typically 3-11), forcing meaningful loadout decisions. **Wayward Compass** shows the player's location on the mini-map. **Gathering Swarm** auto-collects dropped coins. **Dashmaster** reduces dash cooldown. **Fragile Heart** grants +2 HP. **Spell Twister** reduces spell cost. The Notch system creates a genuine strategic layer — kids learn to budget their Notches just like managing allowance.
- **Kid UX:** The child stamps **Charm** stamps (shield-shaped icons with picture symbols). Tapping a charm opens a **Socket Board** with 3-5 empty circles (Notches). Drag charms into sockets to equip. Each charm's icon visually communicates its function: a compass badge shows the mini-map, a magnet badge pulls coins, a heart badge adds HP, a lightning badge speeds up actions. Charm cost is shown as small dot indicators on the charm itself. When Notches are full, unequipping one charm is required before adding another. The Socket Board is accessible from a charm button in the HUD.
- **LLM Automation:** Manages Notch capacity and Charm cost validation (prevents over-slotting), applies all passive effects from equipped Charms simultaneously, handles Charm synergy detection (e.g., Dashmaster + Sprintmaster = hidden bonus effect), auto-generates Charm icons with clear visual symbols, tracks Charm collection progress, and manages Charm acquisition (found in levels, earned from challenges, or purchased from merchants).
- **JSON Contract Extension:**
```json
{
  "badgeSystem": {
    "notchCapacity": 5,
    "equippedBadges": [
      {"badgeId": "compass", "name": "Mini Map", "cost": 1, "effect": "showMinimap"},
      {"badgeId": "magnet", "name": "Coin Pull", "cost": 2, "effect": "autoCollectRadius100"},
      {"badgeId": "extraHeart", "name": "Tougher", "cost": 3, "effect": "maxHpPlus2"}
    ],
    "synergies": [
      {"badges": ["dashMaster", "sprintMaster"], "bonusEffect": "dashSpeedPlus20"}
    ],
    "socketBoardVisual": "charmNotchCircleGrid"
  }
}
```

#### Badge Unlocks via Challenges

- **Source Game:** *Super Mario Wonder* / *Hollow Knight* (badge/charm rewards for completing challenges)
- **Description:** Badges and Charms are not all available from the start. Players earn them by completing specific **Challenge Stamps** placed throughout levels. A *"Defeat 5 Enemies Without Getting Hit"* challenge awards the **Ninja Badge** (temporary invisibility after a perfect fight). A *"Collect 100 Coins in One Level"* challenge awards the **Magnet Charm** (auto-pull coins). A *"Reach the Top of the Tower"* challenge awards the **Climber Badge** (faster wall-climbing). Challenges add progression depth and reward mastery.
- **Kid UX:** The child stamps **Challenge Badges** in their levels — each shows a goal with a picture (5 crossed-out enemies, 100 coins, a tower). When a player completes the challenge during playtest, a **"Challenge Complete!"** banner appears with confetti, and the reward badge is added to their collection. Challenge badges can be placed anywhere: some are visible at level start, others are hidden behind secret walls. The badge collection screen shows locked badges as silhouettes with the challenge condition written below.
- **LLM Automation:** Tracks challenge completion state per player profile, validates challenge conditions in real-time (kill counters, coin totals, time limits), triggers badge unlock events with celebratory animations, manages the badge collection UI with locked/unlocked states, auto-generates challenge difficulty scaling based on level complexity, and ensures challenges are achievable without requiring feats of inhuman precision.
- **JSON Contract Extension:**
```json
{
  "badgeChallenges": [
    {"badgeId": "ninjaBadge", "condition": "defeat5NoDamage", "progress": 0, "target": 5},
    {"badgeId": "magnetCharm", "condition": "collect100Coins", "progress": 0, "target": 100}
  ]
}
```

---

## 3.4 Ability Acquisition & Upgrade

These features handle how abilities are obtained, improved, and customized over time. From materia socketing to limit breaks, they provide long-term progression hooks that keep kids engaged across multiple play sessions.

#### Limit Break Rage Meter

- **Source Game:** *Final Fantasy VII/VIII/IX/X* (Limit Break, Overdrive, Trance, Dyne)
- **Description:** As the player defeats enemies or takes damage, a **Rage Meter** fills up around their character portrait. When full, the character glows gold and their next attack becomes a devastating **Limit Break** — a unique, cinematic super-attack. Each character class has a different Limit Break visual. Warrior unleashes a massive spinning sword slash that fills the screen. Mage triggers a screen-filling elemental explosion. Thief performs a lightning-fast multi-hit dash attack that strikes every enemy. The Limit Break is a moment of pure power fantasy.
- **Kid UX:** The child stamps a **Limit Break Orb** in the level (or enables it globally). No other configuration needed. During play, a colorful meter appears around the character and fills with rainbow energy as they fight. When full, the character flashes gold, a *"LIMIT READY!"* banner appears, and the next attack button press triggers the huge Limit Break animation with screen shake, hit-stop on every impact, and dramatic music. The meter resets after use. Different classes get visually distinct Limit Breaks so kids want to try them all.
- **LLM Automation:** Tracks damage dealt, damage taken, and enemies defeated to fill the meter using a weighted formula, detects when the meter reaches maximum, triggers the Limit Break state (gold aura, screen border effect, music shift), implements the unique attack pattern per class (different hitboxes, durations, visual effects, and damage formulas), applies appropriate damage scaling (typically 5-10x normal attack damage), and resets the meter after the Limit Break completes.
- **JSON Contract Extension:**
```json
{
  "limitBreak": {
    "meterFillMethods": ["dealDamage", "takeDamage", "defeatEnemy"],
    "maxMeter": 100,
    "classLimitBreaks": {
      "warrior": "spinningSlash",
      "mage": "elementalBurst",
      "thief": "multiDash"
    },
    "visualCinematic": true,
    "invincibleDuring": true,
    "meterPersistence": "perLevel"
  }
}
```

#### Materia Socket Gems

- **Source Game:** *Final Fantasy VII* (Materia — slot gems into equipment for magic/abilities/summons/stat boosts)
- **Description:** The player finds **Socket Stations** throughout levels where they can insert colorful **Materia Gems** into their character's equipment. Red Gem = fire attack modifier. Blue Gem = ice shield passive. Yellow Gem = lightning speed boost. Green Gem = healing over time. Purple Gem = poison touch on attacks. Gems can be combined at stations for hybrid effects: Red + Blue = **Steam Blast** (fire and ice area attack). The number of sockets limits how many gems are active, creating meaningful equipment decisions.
- **Kid UX:** The child stamps **Socket Stations** on the canvas. When playtesting, the player character approaches the station and a simple gem inventory appears as large, draggable gem stickers. The child drags gems into empty sockets on a character equipment outline. Combinations of adjacent gems produce a **"Fusion"** option automatically — a glow effect appears between compatible gems. Gems are found as collectible items throughout levels, appearing as colored sparkle orbs. Each gem's color is bright and saturated for instant recognition.
- **LLM Automation:** Generates the socket UI with equipment outline and socket slots, manages gem inventory per player, computes gem combination results from fusion recipes (25+ combinations), applies gem effects to the character's stats and abilities (additive modifiers), generates hybrid gem visuals through color blending, auto-balances gem power relative to level difficulty, and handles gem removal/replacement at socket stations.
- **JSON Contract Extension:**
```json
{
  "materiaSystem": {
    "gemTypes": ["fire", "ice", "lightning", "heal", "poison", "shield"],
    "fusionRecipes": {
      "fire+ice": "steamBlast",
      "lightning+shield": "electricBarrier",
      "heal+fire": "regenAura"
    },
    "maxSockets": 4,
    "stationType": "socketStation",
    "autoBalance": true
  }
}
```

#### Weapon Skill Swapping

- **Source Game:** *Elden Ring* (Ashes of War — attach skills to weapons)
- **Description:** Special combat abilities can be attached to and detached from weapons freely. A **Skill Gem** might add a spinning slash, a charge thrust, a parry counter, or a magic projectile. The player can experiment with different skill-weapon combinations to find synergies. Skills have visual cooldown indicators and distinct animation profiles. A heavy sword with a dash-thrust skill becomes a charge weapon. A light dagger with a spin-slash skill becomes a crowd-control tool.
- **Kid UX:** The child stamps **Skill Gem** stamps (star-shaped icons in different colors) and weapon stamps. Dragging a gem onto a weapon's "socket" indicator attaches it — the gem glows and the weapon sprite updates with a visual effect matching the skill. Tapping the skill button in play triggers the move. The child can drag different gems onto the same weapon to swap, with the old gem returning to inventory. A **Skill Preview** plays when attaching, showing a ghost animation of the skill. Visual socket indicators appear on all weapon stamps.
- **LLM Automation:** Validates gem-weapon compatibility (some skills require specific weapon types), applies skill parameters to the weapon entity (damage, hitbox shape, animation set), generates appropriate animation and VFX for each skill-weapon combination, manages skill cooldown with radial fill indicator on the UI button, saves current skill loadout, auto-generates skill preview ghost animation when socketed, and prevents incompatible combinations with a gentle "bloop" sound and shake animation.
- **JSON Contract Extension:**
```json
{
  "weaponSkills": {
    "weaponId": "ironSword",
    "equippedSkill": {
      "skillId": "spinSlash",
      "animation": "playerSpinAttack",
      "vfx": "swooshCircle",
      "cooldown": 3.0,
      "damageMultiplier": 2.0,
      "hitboxShape": "circleAroundPlayer"
    },
    "compatibleSkills": ["spinSlash", "dashThrust", "groundSlam", "magicWave"]
  }
}
```

#### Fragment Upgrade System

- **Source Game:** *Hollow Knight* (Mask Shards — 4 shards = +1 HP mask; Vessel Fragments — 3 fragments = +1 soul vessel)
- **Description:** The player collects fragment items hidden throughout levels. Collecting enough fragments (typically 3-4) permanently upgrades a stat. **Heart Pieces** (1/4 of a heart shape) increase max HP when four are assembled. **Magic Drops** (1/3 of a crystal) increase max magic when three are collected. **Speed Shards** boost movement speed when enough are gathered. Fragments are deliberately hidden in hard-to-reach places, encouraging thorough exploration. Finding the final fragment to complete a set triggers one of the most satisfying moments in game design.
- **Kid UX:** The child stamps **Heart Piece** stamps (bright red quarter-heart shapes) hidden throughout the level — behind walls, above pits, at the end of optional challenge rooms. When the hero collects 4, the LLM auto-combines them into a full heart with a big **"DING!"** animation — the heart assembles piece by piece with a celebratory chime, and max HP increases by one. The HUD shows collected fragments as a **pie chart** filling up. Heart pieces are red, magic drops are blue, speed shards are green — color-coded for instant recognition.
- **LLM Automation:** Tracks fragment collection count per type, detects when the threshold is reached (4/4 heart pieces, 3/3 magic drops), triggers the upgrade on threshold hit with satisfying combination animation, updates max HP or magic pool, resets the fragment counter with visual carryover, distributes fragment placements to reward exploration (the LLM auto-suggests fragment hiding spots when the child is designing), and shows a fragment radar indicator if a specific "Treasure Sense" badge is equipped.
- **JSON Contract Extension:**
```json
{
  "fragmentUpgrades": [
    {
      "type": "maxHp",
      "fragmentName": "heartPiece",
      "fragmentsNeeded": 4,
      "fragmentsCollected": 2,
      "upgradeAmount": 1,
      "visual": "heartPieChart",
      "combineAnimation": "heartAssemble"
    },
    {
      "type": "maxMagic",
      "fragmentName": "magicDrop",
      "fragmentsNeeded": 3,
      "fragmentsCollected": 1,
      "upgradeAmount": 25,
      "visual": "jarFillUp"
    }
  ]
}
```

#### Summon Beast Call

- **Source Game:** *Final Fantasy* series (Ifrit, Shiva, Ramuh, Bahamut, Odin, Alexander)
- **Description:** The player stamps a **Summoning Circle** object on the canvas. During gameplay, when the player character stands on the circle and presses the action button, a massive summoned creature appears in the background and executes a spectacular screen-filling elemental attack. Each summon has a unique element and visual spectacle: **Ifrit** (fire — a volcanic eruption across the screen), **Shiva** (ice — everything freezes and shatters), **Ramuh** (lightning — bolts strike every enemy), **Bahamut** (non-elemental — a colossal energy beam). After use, the circle goes on cooldown and glows dim until recharged. Summons are cinematic power moments that make kids gasp.
- **Kid UX:** The child stamps a **Summon Circle** stamp on the level canvas, then taps a sticker to pick which beast appears (flame lion for Ifrit, ice queen for Shiva, lightning sage for Ramuh, dragon for Bahamut). A simple *"Use Once Per Level"* toggle can be set with a single tap. During play, standing on the circle makes a **"SUMMON!"** button appear. Tapping it triggers the cinematic — the screen darkens, the summoned creature appears in a burst of element-colored particles, and the attack sweeps across the level. Enemies take massive damage with dramatic hit reactions. No numbers, no complex menus — just tap the sticker, place the circle, and experience the spectacle.
- **LLM Automation:** Generates the summon entry animation (creature rising from a portal with appropriate particle effects for the element), implements the attack effect (particle systems, screen shake, full-screen damage zones that hit all enemies), calculates elemental damage scaled to enemy count and level difficulty, manages cooldown timer logic with visual dimming on the circle, auto-balances damage based on level size (single-target burst in small levels, AoE in large levels), and ensures the cinematic doesn't interrupt player movement (enemies take damage during the animation while the player remains in control).
- **JSON Contract Extension:**
```json
{
  "objects": [{
    "type": "summonCircle",
    "summonId": "shiva",
    "element": "ice",
    "usesPerLevel": 1,
    "cooldownSeconds": 0,
    "autoDamageScale": true,
    "visualTier": "epic"
  }]
}
```

#### Spell Casting with Resource

- **Source Game:** *Hollow Knight* (Vengeful Spirit, Howling Wraiths, Desolate Dive, Shade Soul)
- **Description:** Special abilities consume a resource called **Soul** (or Magic) gathered by striking enemies. Spells include a forward fireball (**Vengeful Spirit**), an upward area-of-effect shockwave (**Howling Wraiths**), a diving ground-pound (**Desolate Dive**), and powered-up versions found later. Each spell costs Soul to cast — typically 33 units per spell — and Soul is gained by hitting enemies with melee attacks (about 11 Soul per hit). This creates a satisfying melee-to-magic loop: attack enemies to gather Soul, then unleash it as powerful spells.
- **Kid UX:** The child stamps **Magic Spark** pickups on the canvas. Hitting enemies fills a **Magic Jar** — shown as a visual container at the top of the screen that fills with glowing liquid. The child stamps a **Spell Book** near the hero start; tapping it assigns a spell from a sticker picker: "Fireball," "Jump Smash," or "Shield Bubble." In play, a spell button appears when the jar has enough magic. Single-tap to cast — the spell consumes a portion of the jar's contents. The jar refills automatically by hitting enemies. Spell upgrades are found as hidden **Spell Scrolls** that power up existing spells with bigger visual effects.
- **LLM Automation:** Manages the Soul/Magic resource pool (fills on enemy melee hits, empties on spell cast), handles spell cooldowns and costs per spell type, generates projectile entities or area hitboxes with appropriate damage values, manages spell upgrade tiers (e.g., Vengeful Spirit → Shade Soul with larger hitbox and more damage), plays casting animations and VFX per spell type, auto-balances Soul gain rate so the jar refills at a steady pace during combat, and displays the Magic Jar fill state as a smooth visual liquid animation.
- **JSON Contract Extension:**
```json
{
  "spellSystem": {
    "magicPoolMax": 100,
    "magicCurrent": 0,
    "soulGainPerHit": 11,
    "knownSpells": [
      {"spellId": "fireball", "cost": 33, "damage": 25, "type": "projectile", "direction": "forward"},
      {"spellId": "diveSmash", "cost": 33, "damage": 30, "type": "aoeAroundPlayer", "invincibilityFrames": 0.4}
    ],
    "equippedSpell": "fireball",
    "upgradeScrolls": [" empoweredFireball", "megaDive"]
  }
}
```

#### Rally Health Regain

- **Source Game:** *Bloodborne* (Rally system — recover lost HP by dealing damage quickly)
- **Description:** When the player takes damage, a portion of lost HP becomes **"faded"** — shown in orange on the health bar instead of disappearing entirely. Dealing damage to enemies within a short window (4-5 seconds) recovers the faded HP back to full health. This encourages aggressive, risk-taking play — taking a hit then immediately fighting back to heal. The system turns damage into a temporary setback rather than a permanent loss, making combat feel dynamic and rewarding boldness.
- **Kid UX:** When the hero gets hit, lost HP shows as **orange chunks** on the health bar instead of vanishing. A small "clock" icon appears next to the bar, shrinking rapidly. Hitting enemies fills the orange chunks back to red with each successful attack — a green **+HP** number floats up with every hit. The child doesn't need to stamp anything; Rally is a global game mechanic enabled by placing a **Rally Badge** stamp in the level. The orange-to-red transition is visually satisfying and creates a natural "fight back!" incentive. If the clock expires before the player lands a hit, the orange fades permanently.
- **LLM Automation:** Splits damage into "permanent loss" (50%) and "faded/rallyable" (50%) portions on every hit taken, displays faded HP in distinct orange color with a smooth transition, starts the rally timer countdown (4 seconds by default) on damage taken, calculates HP recovery per damage dealt to enemies (e.g., 30% of damage dealt is recovered as HP), gradually fades rallyable HP to permanent loss if the timer expires, shows rally recovery amount as floating green text on every successful hit, and auto-adjusts the rally window size based on the child's performance (wider window for players who struggle, tighter for skilled players).
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
    "timerVisual": "shrinkingClock",
    "expireRate": "gradual",
    "rallyText": "+{amount} HP!"
  }
}
```

#### Trick Weapon Transformation

- **Source Game:** *Bloodborne* (Threaded Cane, Ludwig's Holy Blade, Hunter Axe — all switch between two forms)
- **Description:** Weapons can **transform between two distinct forms** mid-combat with a flourish animation. One form is typically fast and short-ranged; the other is slow but long-ranged or more powerful. The Threaded Cane switches from a quick sword to a sweeping whip. Ludwig's Holy Blade transforms from a one-handed sword to a massive two-handed greatsword. The transformation itself can deal damage — switching forms at the right moment creates a unique attack opportunity. This doubles the player's moveset without needing to swap weapons, giving every weapon two personalities.
- **Kid UX:** The child stamps a **Transformer Weapon** stamp (shown as a sword with a morph arrow). The weapon has two visual states shown as small icons: **Mode A** (fast icon) and **Mode B** (power icon). A **"Switch"** button in play toggles between them with a cool flash animation and a mechanical sound. The LLM auto-generates both forms' animations. Mode A = quick, short-range slashes with a small hitbox. Mode B = slower, wider sweeps with a large hitbox. The transform animation itself has a small hitbox — switching at the right moment hits nearby enemies. Visual trails differ per mode: quick silver streaks for Mode A, heavy red arcs for Mode B.
- **LLM Automation:** Manages two stat profiles per weapon (Mode A: fast attack speed, short range, small hitbox / Mode B: slow attack speed, long range, large hitbox, higher damage), handles transform animation timing and interruption rules, applies transform-hitbox damage on the switch frame (enemies caught in the transformation take bonus damage), generates appropriate hitboxes and attack animations per form, saves current form state across level transitions, plays unique transform SFX per weapon type, and ensures both forms have visually distinct silhouettes so kids can tell which mode is active at a glance.
- **JSON Contract Extension:**
```json
{
  "trickWeapon": {
    "weaponId": "threadedCane",
    "currentForm": "compact",
    "forms": {
      "compact": {"damage": 12, "speed": 1.2, "range": 60, "hitbox": "shortArc", "visual": "shortCane"},
      "extended": {"damage": 20, "speed": 0.8, "range": 140, "hitbox": "longWhip", "visual": "whipForm"}
    },
    "transformDamage": 8,
    "transformHitbox": "smallBurst",
    "transformVfx": "crackFlash",
    "transformTime": 0.6
  }
}
```

#### Phozon Absorption Growth

- **Source Game:** *Odin Sphere* (Phozon absorption — collect spirit energy to grow plants and gain abilities)
- **Description:** Defeated enemies release floating **Power Orbs** that can be absorbed. Collecting enough orbs causes the character to **"grow"** — a visible size increase accompanied by a stat boost and a new ability glow. Collected orbs can also be spent at **Growth Shrines** to unlock skill tree nodes: more health, increased attack power, faster movement speed, and new special moves. The character's growth level persists across levels, creating a long-term sense of progression that kids can see — their character literally gets bigger and stronger over time.
- **Kid UX:** The child enables **Power Orbs** on enemy stamps with a single toggle: *"Drop Orbs on Defeat."* They stamp **Growth Shrines** in levels (glowing pillars with skill tree branches). During play, defeating enemies releases pretty floating orbs that home toward the player with a chime. Collecting enough orbs makes the character **slightly bigger** with a celebratory *"DING!"* and a size-up animation. At Growth Shrines, the player spends orbs to unlock glowing nodes on a simple skill tree — tapping a node purchases it with a sparkle effect. The skill tree has four branches: Heart (health), Sword (attack), Wing (speed), and Star (special moves). Character size scales with growth tier.
- **LLM Automation:** Implements orb release on enemy defeat (each enemy drops 1-3 orbs based on strength), handles orb homing physics (gentle acceleration toward player when within pickup radius), tracks growth state (size scaling multiplier, stat modifiers per tier), generates the skill tree layout with four branches and 5 nodes per branch, handles orb spending and node unlocking with immediate stat application, persists growth data across all levels and sessions, and scales orb requirements per growth tier to maintain progression pacing (Tier 1 = 10 orbs, Tier 2 = 25, Tier 3 = 50, Tier 4 = 100).
- **JSON Contract Extension:**
```json
{
  "phozonGrowth": {
    "orbSource": "enemyDefeat",
    "orbBehavior": "homingFloat",
    "growthTiers": [
      {"orbs": 10, "sizeMult": 1.1, "statBonus": "healthPlus1"},
      {"orbs": 25, "sizeMult": 1.2, "statBonus": "attackPlus1"},
      {"orbs": 50, "sizeMult": 1.3, "statBonus": "specialUnlock"}
    ],
    "skillTree": {"nodes": ["health", "attack", "speed", "special"], "nodesPerBranch": 5},
    "shrineType": "growthShrine",
    "persistence": "profileWide"
  }
}
```

---

## 3.5 Elemental & Status Specialization

Elements add a rock-paper-scissors layer to combat that even young children intuitively understand. Fire beats ice. Ice freezes water. Water puts out fire. These systems encode that elemental logic into tangible, visual mechanics.

#### Elemental Shield Pickups

- **Source Game:** *Sonic 3 & Knuckles / Sonic Mania* (Fire Shield, Bubble Shield, Lightning Shield)
- **Description:** Breaking special **Shield Monitor** items grants the player a protective shield with elemental powers. **Fire Shield** = immune to fire and lava hazards, leaves a fire trail when dashing, grants an air-dash ability. **Bubble Shield** = immune to drowning, allows a bounce attack, enables breathing underwater. **Lightning Shield** = magnetic coin attraction within radius, grants a double jump with electric spark, immune to electricity. **Standard Shield** = one-hit protection with no special ability. Only one shield at a time — picking up a new one replaces the old.
- **Kid UX:** The child stamps **Shield Monitors** on the canvas. Tapping each monitor opens a sticker picker: flame icon (Fire), water drop (Bubble), lightning bolt (Lightning), blue orb (Standard). During play, breaking the monitor (jumping on it) grants the shield with a flash effect. The shield's element is shown as an orbiting bubble around the character in the matching color. When the shield absorbs a hit, it pops with a dramatic burst and the character is briefly invincible. Shield monitors respawn after a delay for replayability.
- **LLM Automation:** Implements each shield's unique passive effect (Fire = lava immunity + air dash physics, Bubble = underwater breathing + bounce on jump press, Lightning = coin magnet radius + double jump enabled, Standard = single hit absorption only), generates orbiting visual particles in the element's color, handles shield destruction on hit (Standard breaks on any hit; elemental shields break on non-elemental hits but absorb their element), manages shield replacement rules (new shield overwrites old), and auto-tints level hazards to communicate element associations visually.
- **JSON Contract Extension:**
```json
{
  "shieldTypes": [
    {"type": "fire", "immunity": ["lava", "fire"], "ability": "airDash", "trail": "fire"},
    {"type": "bubble", "immunity": ["drown"], "ability": "bounce", "underwaterBreath": true},
    {"type": "lightning", "immunity": ["electric"], "ability": "doubleJump", "magnetRadius": 80},
    {"type": "standard", "immunity": [], "ability": "none", "hits": 1}
  ],
  "shieldMonitor": {
    "breakMethod": "jumpOn",
    "maxOne": true,
    "visualOrbit": true
  }
}
```

#### Elemental Weakness Wheel

- **Source Game:** *Final Fantasy* series / *Mega Man* series (circular elemental weakness chain)
- **Description:** Enemies and obstacles have visible elemental affiliations (color-coded: red = fire, blue = ice, yellow = lightning, green = earth, white = holy, purple = dark). Attacking with the matching element deals bonus damage and triggers a dramatic **"WEAKNESS!"** flash with the element's color. Attacking with the wrong element deals reduced damage or is fully resisted. This creates a simple puzzle layer in combat — observe the enemy's color, equip the matching element, profit. The weakness wheel forms a circular chain: Fire ↔ Ice, Water ↔ Lightning, Earth ↔ Wind, Dark ↔ Holy.
- **Kid UX:** The child stamps enemies and taps them to pick an element affiliation (shown by the enemy's glow color and a small element icon). They also stamp elemental weapon pickups or Job Badges. During play, hitting a fire enemy with ice creates a big **"WEAKNESS!"** flash in blue — the enemy shudders and takes double damage with bonus hit-stop. The system is self-teaching through visual feedback — kids learn the rock-paper-scissors naturally through color matching. Enemies with no weakness take normal damage from everything.
- **LLM Automation:** Maintains the elemental wheel mapping (Fire weak to Ice, Ice weak to Fire; Water weak to Lightning, Lightning weak to Water; Dark weak to Holy, Earth weak to Wind), computes damage modifiers (2.0x for weakness hit, 1.0x for normal, 0.5x for resistance, 0.0x for absorption), generates weakness-hit visual feedback (color flash matching the attack element, burst particles, floating "WEAKNESS!" text), tracks elemental state on enemies, and auto-suggests balanced enemy element placements when the child is designing levels (ensuring variety so the player needs to switch strategies).
- **JSON Contract Extension:**
```json
{
  "elementalWheel": {
    "elements": ["fire", "ice", "lightning", "water", "earth", "wind", "holy", "dark"],
    "weaknessPairs": {
      "fire": "ice", "ice": "fire",
      "water": "lightning", "lightning": "water",
      "dark": "holy", "earth": "wind"
    },
    "damageModifiers": {"weakness": 2.0, "normal": 1.0, "resistance": 0.5, "absorb": 0.0},
    "visualFeedback": "elementalBurstText"
  }
}
```

#### Status Effect Sprites

- **Source Game:** *Final Fantasy* series (Poison, Sleep, Haste, Slow, Protect, Regen, Berserk, Confuse)
- **Description:** Various objects and enemy attacks inflict colorful status effects that temporarily modify gameplay. A **Sleep Cloud** trap makes the character snooze for 3 seconds with Zzz particles. A **Speed Potion** makes them run super fast with rainbow sparkles. A **Shield Bubble** reduces incoming damage with a visible force field. A **Poison Mushroom** slowly drains health shown by green bubbles. **Confuse** reverses controls with swirling star effects. Every effect has a clear, cartoonish visual indicator that communicates its function without any text.
- **Kid UX:** The child stamps **Effect Zones** or **Effect Items** throughout levels. Tapping each opens a sticker picker with big, expressive icons: a Zzz bubble for Sleep, lightning boots for Speed, a heart shield for Protection, a green skull for Poison, swirling stars for Confuse, a rainbow star for Power-Up. Effects are applied on touch and last a few seconds. All negative effects are framed as silly rather than scary — being "sleepy" or "dizzy" is funny, not frightening. The character's sprite tint changes to match the effect color (green tint for poison, yellow for haste, purple for confuse).
- **LLM Automation:** Implements each status effect's behavior (Sleep = freeze player input + Zzz particles for 3 seconds, Speed = 2x velocity + sparkle trail for 5 seconds, Shield = 50% damage reduction + bubble overlay for 10 seconds, Poison = gradual health drain + green tint for 5 seconds, Confuse = reverse left/right input + star swirl for 3 seconds), manages effect durations and stacking rules (typically strongest effect wins when overlapping), generates status UI indicators (small icons floating near the character), and ensures all effects are clearly communicated through distinct animation and color coding.
- **JSON Contract Extension:**
```json
{
  "statusEffects": [
    {"id": "sleep", "duration": 3, "effect": "freezeInput", "visual": "zzzParticles"},
    {"id": "haste", "duration": 5, "effect": "speed_x2", "visual": "sparkleTrail"},
    {"id": "shield", "duration": 10, "effect": "damageHalf", "visual": "bubbleOrb"},
    {"id": "poison", "duration": 5, "effect": "healthDrainSlow", "visual": "greenBubbles"},
    {"id": "confuse", "duration": 3, "effect": "reverseControls", "visual": "starSwirl"}
  ],
  "stackingRules": "strongestWins",
  "visualIndicators": "iconBadge"
}
```

---

## Comparison Tables

### Class System Comparison

| System | Source | Core Decision | Kid Interaction | Depth |
|--------|--------|--------------|-----------------|-------|
| Job Badge | *Final Fantasy* | Which job fits this level? | Tap badge to swap | Medium — 6+ jobs |
| Paradigm Roles | *Final Fantasy XIII* | Which role does my buddy need? | Tap role icon mid-combat | High — 6 roles, 3 buddies |
| Class Evolution | *Trials of Mana* | Which branch feels right? | Tap evolution choice at statue | High — 2-tier branching tree |
| Blue Mage Copy | *Final Fantasy* | What can I learn from enemies? | Touch enemies to copy abilities | Very High — emergent library |

### Transformation System Comparison

| System | Source | Trigger | Duration | Kid Appeal |
|--------|--------|---------|----------|------------|
| Super Emeralds | *Sonic* | Collect 7 gems | Timed (30s) | Very High — invincible power fantasy |
| Drive Form Wardrobe | *Kingdom Hearts II* | Walk through gate | Until reverted | High — sparkly costume changes |
| Copy Ability | *Kirby* | Touch enemy | Until hit/dropped | Very High — hat collection |
| Copy Ability Mix | *Kirby 64* | Absorb while holding ability | Until hit/dropped | Very High — experiment combos |
| Super Ability | *Kirby* | Touch rainbow item | 10 seconds | Very High — screen-clearing spectacle |
| Mouthful Mode | *Kirby Forgotten Land* | Inhale large object | Until spit out | Very High — silly object control |
| Morph Ball | *Metroid* | Tap roll button | Until cancelled | Medium — puzzle traversal |
| Environment Morph | *NiGHTS* | Enter zone | While in zone | High — automatic transformation |

### Passive Modifier System Comparison

| System | Source | Equip Limit | Kid-Friendly? | Strategic Depth |
|--------|--------|-------------|---------------|-----------------|
| Badge Equip | *Mario Wonder* | 1 per level | Very — color-coded categories | Low-Medium — pick one |
| Dual Badge | *Mario Wonder* | 1 (combined) | Very — visual fusion | Medium — emergent combos |
| Charm System | *Hollow Knight* | Notch budget | Moderate — notch counting | High — build optimization |
| Badge Challenges | *Mario Wonder* | Earn before equip | Very — challenge rewards | Medium — progression unlocks |

### Elemental System Comparison

| System | Source | Elements | Interaction Type | Visual Clarity |
|--------|--------|----------|-----------------|---------------|
| Elemental Shields | *Sonic 3* | Fire, Water, Lightning | Passive immunity | Very High — orbiting bubbles |
| Weakness Wheel | *Final Fantasy / Mega Man* | 8 elements | Active combat modifier | High — color-coded weakness flash |
| Status Effects | *Final Fantasy* | Sleep, Haste, Poison, etc. | Temporary state changes | Very High — distinct animations per effect |


---

# Chapter 4: Companions, Pets & Multiplayer

> *"Every hero needs a friend."* — This chapter captures the full spectrum of companionship in games, from a loyal cat warrior to a swarm of obedient Pikmin, from AI buddy pathfinding to local drop-in co-op. Every system is designed so a 5-year-old can summon, befriend, and command allies through stamps, taps, and simple gestures. The LLM handles all AI behavior trees, squad coordination algorithms, and co-op session management — invisibly weaving friendship into gameplay.

---

## 4.1 Companion Systems

These features provide the player with persistent AI allies who fight, heal, and assist throughout their adventure. Each companion system brings a distinct personality and mechanical identity, turning solitary platforming into shared journeys.

#### Familiar Companion System

- **Source Game:** *Castlevania: Symphony of the Night* (Faerie, Bat, Ghost, Demon, Sword Familiar)
- **Description:** A floating companion creature follows the player and provides context-sensitive assistance. Five familiar types offer distinct personalities and abilities: the **Faerie** auto-heals when the player's HP drops below 25% and cures status ailments with a tiny hammer; the **Bat** shoots seeking fireballs at nearby enemies; the **Ghost** latches onto enemies to drain HP and transfer it to the player; the **Demon** casts area-of-effect spells independently; the **Sword Familiar** physically attacks nearby enemies and eventually becomes so powerful it can be wielded as a weapon. Familiars level up as the player defeats enemies, growing stronger and unlocking new abilities over time.
- **Kid UX:** The child opens a **Familiar** stamp palette and stamps a familiar orb onto the player character. The familiar immediately appears and begins following with a cute bobbing animation. Tapping the familiar toggles it on/off with a happy/sad face animation. Familiar type is selected via sticker picker with expressive icons: a faerie with a wand, a bat with flame, a ghost with a heart, a demon with horns, a sword with wings. The familiar's level is shown as small stars below it — defeating enemies fills the star meter. Familiars never die permanently; they simply retreat when overwhelmed and return after a short rest.
- **LLM Automation:** Handles all familiar AI behavior trees per type (attack radius, heal triggers at HP thresholds, pathfinding to stay near player, spell casting cooldowns), manages familiar stat scaling (familiar levels up as player defeats enemies, gaining +HP, +damage, and reduced cooldowns), auto-triggers context-sensitive abilities (faerie uses hammer when player is petrified, bat fires when enemy enters range), handles familiar rendering as an overlay sprite that follows the player with smooth interpolation, and manages the Sword Familiar's unique progression into a wieldable weapon at max level.
- **JSON Contract Extension:**
```json
{
  "familiars": [{
    "id": "faerie",
    "behaviorType": "healerSupport",
    "triggerConditions": [
      {"type": "hpBelow", "threshold": 0.25, "action": "usePotion"},
      {"type": "statusAilment", "action": "useCureHammer"}
    ],
    "attackRadius": 100,
    "levelScaling": {"maxLevel": 99, "expPerKill": 1, "hpPerLevel": 2, "damagePerLevel": 1}
  }]
}
```

#### Helper Characters (Enemy Conversion)

- **Source Game:** *Kirby Super Star / Star Allies* (Helper Heart system)
- **Description:** Enemies can be converted into helper allies that follow the player and attack other enemies using the same abilities they had as foes. A fire-breathing enemy becomes a fire-breathing ally. A sword-wielding enemy becomes a sword-wielding partner. This system transforms the enemy roster into a recruitment pool — every defeated foe is a potential friend. Supports up to 3 helpers following the player simultaneously, creating a small adventuring party.
- **Kid UX:** The child stamps a **Helper Heart** item. When the player touches it, the nearest enemy transforms into a helper with a shower of hearts and sparkles. The helper wears a small crown to show it's friendly. A **"Join!"** bubble appears over the helper for a second player to tap for drop-in co-op. Helpers follow the player automatically and attack enemies on sight. Tapping a helper opens a simple command wheel: "Stay," "Follow," "Attack" — three big icons. The helper limit of 3 is shown as heart slots at the top of the screen.
- **LLM Automation:** Converts enemy AI to ally AI (targets switch from player to other enemies), implements follow behavior with pathfinding that avoids hazards and stays within screen bounds, manages helper attacks using the same ability definitions the enemy had, handles player drop-in/drop-out by converting helper control to player 2 input, manages the 3-helper limit (newest conversion replaces oldest if at cap), and generates the helper crown visual overlay to distinguish allies from enemies.
- **JSON Contract Extension:**
```json
{
  "helpers": [{
    "type": "ally",
    "ability": "fireBreath",
    "behavior": "followAndAttack",
    "maxHelpers": 3,
    "visualCrown": true,
    "convertFromEnemy": true
  }]
}
```

#### Spirit Companion Summon

- **Source Game:** *Elden Ring* (Spirit Ashes — wolves, jellyfish, mimic tear, skeletons)
- **Description:** Consumable **Friend Crystal** items summon AI-controlled ally spirits to fight alongside the player. Different spirits have radically different behaviors: **Wolves** swarm enemies in packs, flanking and overwhelming. **Jellyfish** floats overhead and rains poison down on foes. **Skeletons** revive once after dying, creating relentless pressure. **Birds** dive-bomb from above. **Golems** tank damage and draw enemy attention. Each summon costs one Friend Crystal and lasts for a timed duration (typically 30 seconds) or until the spirit's HP is depleted.
- **Kid UX:** The child stamps a **Friend Crystal** on the canvas. Tapping it opens a companion picker: wolf, bird, ghost, or robot (cartoon stamps with expressive faces). The LLM auto-assigns AI behavior per type. In play, a **"Call Friend"** button with the selected companion's portrait summons the ally for a limited time. The companion auto-fights and follows the player. A sparkle poof animation plays on summon, and a gentle fade with heart particles plays when the summon expires. Friend Crystals are collected as pickups throughout levels — shown as glowing crystals in the element color matching the spirit type.
- **LLM Automation:** Selects and applies AI behavior profile per companion type (wolf = swarm melee with pack coordination, jellyfish = ranged poison from above, skeleton = melee with one revive, bird = dive attack pattern), manages summon duration countdown and despawn on expiry, handles companion targeting and pathfinding with obstacle avoidance, plays despawn animation on expiry, limits max active companions (typically 1-3 depending on crystal tier), auto-balances companion stats to be helpful but not carry the fight (typically 30-50% of player damage output), and manages crystal inventory consumption per summon.
- **JSON Contract Extension:**
```json
{
  "spiritCompanions": [{
    "id": "sparkyWolf",
    "type": "wolf",
    "aiProfile": "swarmMelee",
    "summonCost": {"item": "friendCrystal", "amount": 1},
    "duration": 30,
    "cooldown": 60,
    "stats": {"hp": 50, "damage": 8, "speed": 120},
    "revives": 0,
    "summonVfx": "crystalBurst",
    "despawnVfx": "sparkleFade"
  }]
}
```

#### Palico Cat Companion

- **Source Game:** *Monster Hunter* series (Palicoes — cat warriors with gadgets and armor)
- **Description:** A fully customizable cat companion that assists in combat, healing, trapping, and gathering. The Palico wears equipable armor and wields a tiny weapon, both visible on its sprite. Its **Gadget** determines its primary support role: **Vigorwasp Spray** heals the player when HP is low, **Flashfly Cage** blinds enemies, **Shield Spire** draws enemy aggro, **Plunderblade** steals items from monsters, **Coral Orchestra** plays buff-granting songs, **Meowlotov Cocktail** throws explosive jars. The Palico levels up independently, gaining HP and damage as it fights alongside the player.
- **Kid UX:** The child stamps a **Palico** (cute cartoon cat warrior) next to the player start point. Tapping the Palico opens a **customization screen**: big armor slot icons (head, body, weapon), a **Gadget** selection grid with illustrated cards (healing horn, flash bomb, trap net), and a **personality picker** (brave, cautious, friendly). The Palico's armor updates on the sprite instantly when equipped. During play, the Palico follows the player, fights with small attack animations, and auto-uses its gadget when conditions are met (healing when player is hurt, flashing when enemies cluster). Level-up is celebrated with a "Level Up!" pop and a new star on the Palico's badge.
- **LLM Automation:** Handles Palico AI (engages enemies at medium range, retreats at low HP, uses gadget on cooldown or trigger condition), manages Palico equipment stats (armor = damage reduction, weapon = attack power), handles gadget abilities (healing radius, flash blind duration, trap placement), tracks Palico experience and leveling curve, generates appropriate combat animations per equipped weapon type (sword slashes, boomerang throws, drum bashes), and manages Palico knockdown recovery (Palico retreats when defeated, then revives after a cooldown rather than dying permanently).
- **JSON Contract Extension:**
```json
{
  "palico": {
    "level": 5,
    "equipment": {"weapon": "palicoSword", "armor": "palicoBoneSet"},
    "gadget": {"id": "vigorwasp", "type": "heal", "cooldown": 30, "trigger": "playerHpBelow50Percent"},
    "supportMoves": ["heal", "trap", "flash"],
    "personality": "brave",
    "aiRange": 150,
    "reviveCooldown": 60
  }
}
```

#### Rush Adapter Dog

- **Source Game:** *Mega Man* series (Rush Coil, Rush Jet, Rush Marine, Rush Search)
- **Description:** A robot dog companion that transforms into various utility forms on command, each providing a distinct traversal or puzzle-solving ability. **Rush Coil** becomes a springboard for super-high jumps. **Rush Jet** transforms into a flying platform for aerial sections. **Rush Marine** enables underwater swimming with propeller boost. **Rush Search** digs at soft ground to uncover hidden items. All forms share a single **energy pool** — transforming and using abilities depletes energy, which regenerates slowly over time. This creates a resource-management puzzle: which form to use, and when?
- **Kid UX:** The child stamps a **Robot Dog** companion next to the player. A popup shows four big icons: a spring for Coil, a jet for Jet, a submarine for Marine, a shovel for Search. Tapping an icon transforms the dog with a flash and a mechanical "clank-shwoosh" sound. **Rush Coil** = the dog becomes a bouncy platform the player jumps on. **Rush Jet** = the dog becomes a flying vehicle the player rides. **Rush Marine** = the dog becomes a submersible for underwater sections. **Rush Search** = the dog digs at marked spots, uncovering treasure. An energy meter appears above Rush and depletes with each use — shown as shrinking green blocks. Energy slowly refills when Rush is in dog form.
- **LLM Automation:** Manages Rush energy pool (depletes on transformation and ability use, regenerates at 1 unit per 2 seconds when in base form), handles transformation state machine with collision profile changes per form (spring = bouncy platform physics, jet = flight movement with inertia, marine = underwater buoyancy + dash boost, search = dig spot detection + treasure spawn), auto-detects dig spots for Rush Search (ground patches with subtle visual indicator), and ensures Rush follows the player intelligently when not in active form (pathfinding with slight lag for charm).
- **JSON Contract Extension:**
```json
{
  "rushForms": [
    {"id": "rushCoil", "energyCost": 4, "type": "springboard", "bounceHeight": 300},
    {"id": "rushJet", "energyCost": 2, "type": "vehicle", "speed": 200, "duration": 10},
    {"id": "rushMarine", "energyCost": 2, "type": "underwater", "speed": 150, "boost": true},
    {"id": "rushSearch", "energyCost": 6, "type": "dig", "detectRadius": 100}
  ],
  "rushEnergy": {"max": 28, "current": 28, "regenRate": 1, "regenInBaseFormOnly": true}
}
```

#### Dream Eater Creature Creator

- **Source Game:** *Kingdom Hearts 3D* (Dream Eaters — create creatures via recipes, raise them, they fight alongside you)
- **Description:** The player creates companion creatures by combining **Dream Parts** collected from defeated enemies or found in levels. Each combination produces a unique creature with procedural color variations and personality traits. Creatures level up by fighting alongside the player and learn new abilities at specific level thresholds. They have visible **happiness meters** shown as heart icons, and perform cute idle animations (dancing when happy, sulking when neglected). Feeding them treats increases both happiness and stats. The creature creation system turns companion acquisition into a creative activity — no two Dream Eaters are exactly alike.
- **Kid UX:** The child stamps **Dream Parts** (colored orbs: red = brave, blue = calm, yellow = energetic, green = nurturing) and a **Dream Portal** creation station. During play, combining 2-3 parts at the portal spawns a cute creature with colors matching the input parts and a personality derived from the combination (red + yellow = energetic brave fighter, blue + green = calm nurturing healer). The creature follows the player, helps in combat with auto-attacks, and has a small heart meter showing happiness. Feeding it treat items (stamped or found) makes hearts burst from the creature and its stats increase slightly. The creature's name can be typed or spoken after creation.
- **LLM Automation:** Manages the creature generation algorithm (part combinations map to creature type + color palette + personality trait), implements creature AI (combat assistance with auto-targeting, following behavior with pathfinding, idle animation selection based on happiness), tracks creature XP and leveling with automatic ability unlocks at thresholds, generates procedural creature sprites from part combinations through layered compositing, manages happiness mechanics (happiness decays slowly, feeding restores it, low happiness reduces combat effectiveness), and handles creature ability unlocks as they gain experience.
- **JSON Contract Extension:**
```json
{
  "dreamEater": {
    "parts": ["braveOrb", "calmOrb", "energyOrb", "nurtureOrb"],
    "creationStation": "dreamPortal",
    "combinationCount": [2, 3],
    "traits": ["aggressive", "defensive", "healer", "tricky"],
    "leveling": true,
    "happinessSystem": true,
    "proceduralSprites": true,
    "abilityUnlocks": "levelBased",
    "maxActive": 2
  }
}
```

#### NPC Questline Stamps

- **Source Game:** *Dark Souls* series (Solaire's quest, Siegmeyer's journey, Ranni's epic questline)
- **Description:** An NPC companion that appears in specific locations with dialogue that progresses based on player actions — finding items, defeating bosses, or reaching new areas. NPC companions move between waypoints or landmarks as their quest advances. Some questlines branch based on choices (help the NPC or abandon them). Rewards include unique abilities, rare items, or unlocking new level areas. The questline system turns a simple companion into a narrative journey that unfolds across multiple play sessions.
- **Kid UX:** The child stamps an **NPC Stamp** (cartoon character with a speech bubble). Tapping it opens a **dialogue composer**: the child types or speaks what the NPC says at each stage, and stamps an **Item Gift** to give as a reward. The child stamps numbered **Location Stamps** (1, 2, 3) showing where the NPC moves throughout the level. A **Quest Tracker** appears in the HUD showing the current stage: *"Find the NPC's lost hat!"* with a picture of the hat. Completing the quest triggers a celebratory animation and the reward item spawns. Questlines can span multiple levels — the NPC remembers the player's progress.
- **LLM Automation:** Manages quest state machine (not started → active → progressed → complete → rewarded), triggers NPC movement between waypoints on key events (item collected, boss defeated, area reached), auto-generates dialogue trees from the child's spoken input, handles branching logic (player choices determine which path the quest takes), manages inventory rewards and ability unlocks at quest completion, saves quest progress across all sessions and levels, auto-generates a simple portrait for the NPC based on their stamp appearance, and ensures quest objectives are achievable (validates that required items exist in the level).
- **JSON Contract Extension:**
```json
{
  "npcs": [{
    "id": "blinkyTheGhost",
    "name": "Blinky the Ghost",
    "locations": [
      {"stage": 0, "x": 400, "y": 300, "dialogue": "Have you seen my hat?"},
      {"stage": 1, "x": 1500, "y": 500, "dialogue": "You found it! Here's a Super Jump!"}
    ],
    "questTrigger": {"type": "itemCollected", "itemId": "ghostHat"},
    "reward": {"type": "abilityUnlock", "ability": "superJump"},
    "currentStage": 0,
    "portraitAutoGen": true
  }]
}
```

#### Companion Equipment Sharing

- **Source Game:** *Monster Hunter* (Palico armor/weapon crafting) / *Final Fantasy* (companion gear)
- **Description:** Companion characters can be equipped with their own weapons, armor, and accessories just like the player. A Palico's tiny sword increases its attack damage. Its armor reduces damage taken. Special companion accessories grant unique behaviors: a **Healing Bell** causes the companion to periodically restore player HP, a **Treasure Nose** makes the companion lead the player to hidden items, a **Battle Horn** boosts both characters' attack speed when danger is near. Companion equipment is found as special small-sized item stamps throughout levels.
- **Kid UX:** The child stamps **Companion Gear** items — tiny helmets, small swords, miniature shields, little bells. Tapping a companion opens its **equipment screen** (a smaller version of the player's equipment outline with 3-4 slots). Dragging gear onto the companion updates its sprite immediately: the sword appears in its paw, the helmet on its head, the bell around its neck. Companion gear is visually distinct from player gear (smaller, cuter proportions). A **stats comparison** shows before/after numbers with green arrows for improvements. Finding a new companion weapon in a treasure chest is a genuine moment of excitement.
- **LLM Automation:** Manages companion equipment inventory separate from player inventory, computes companion stats from equipped gear (attack = weapon base + level scaling, defense = armor + helmet, special = accessory passive), handles equipment appearance layering on companion sprites (generates composite visuals for gear combinations), implements accessory-specific behaviors (Healing Bell = periodic HP restore with 30s cooldown, Treasure Nose = proximity-based hidden item detection with sparkle trail, Battle Horn = 15% attack speed buff when enemies within 200px), and auto-balances companion equipment drops to match level difficulty.
- **JSON Contract Extension:**
```json
{
  "companionEquipment": {
    "slots": ["weapon", "armor", "accessory"],
    "items": [
      {"id": "palicoSword", "attack": 8, "slot": "weapon"},
      {"id": "healingBell", "effect": "periodicHeal", "cooldown": 30, "slot": "accessory"},
      {"id": "treasureNose", "effect": "itemRadar", "radius": 150, "slot": "accessory"}
    ],
    "autoBalance": true,
    "visualLayering": true
  }
}
```

---

## 4.2 Pet & Follower Systems

These features focus on creatures that follow the player not for combat, but for friendship, discovery, and emotional connection. Pets don't just help — they make the world feel alive.

#### Animal Feeding & Following

- **Source Game:** *Okami* (feed animals for Praise orbs and friendship)
- **Description:** Various animals roam the game world — dogs, cats, rabbits, birds, deer, monkeys. Feeding them their preferred food type causes them to permanently follow the player, providing minor stat boosts and occasional treasure discovery. Each animal type has distinct preferences: dogs want meat, cats want fish, rabbits want carrots, birds want seeds. Once fed, the animal follows at a distance, plays idle animations, and occasionally digs at spots to uncover hidden items. Follower slots are limited (typically 3), so kids must choose their companions carefully.
- **Kid UX:** The child stamps **Animal** stamps throughout the level: dogs, cats, rabbits, birds, deer. Each animal has a thought bubble showing what food it wants (bone icon for dogs, fish for cats, carrot for rabbits, seed for birds). The child stamps **Food Bag** items. When the player gives the right food, hearts burst above the animal and it starts following the player with a happy hop or wag. Tapping a following animal opens a simple interaction menu: "Pet" (plays cute animation), "Stay" (animal waits here), "Go Home" (animal leaves party). The follower limit is shown as three heart slots in the HUD.
- **LLM Automation:** Manages animal AI states (wander when wild, follow at distance when fed, play idle animations, occasionally dig at treasure spots), tracks which animals have been fed and are following, applies follower bonuses per animal type (dog = +5% attack, cat = +10% luck, rabbit = +5% speed, bird = reveals hidden items), handles animal dig spot detection and treasure spawning, manages follower slot allocation (new follower prompts to dismiss existing one if at cap), and generates unique idle behaviors per animal type.
- **JSON Contract Extension:**
```json
{
  "animals": [
    {"id": "dog", "preferredFood": "meat", "followBonus": {"str": 1}, "special": "digForTreasure"},
    {"id": "cat", "preferredFood": "fish", "followBonus": {"lck": 2}, "special": "findSecretPath"},
    {"id": "rabbit", "preferredFood": "carrot", "followBonus": {"speed": 1.1}, "special": "none"}
  ],
  "followerSlots": {"max": 3, "current": []},
  "feedRange": 50,
  "followDistance": 100
}
```

#### Monster Taming Whistle

- **Source Game:** *Dragon Quest Builders 2* (befriend defeated monsters who then help in town)
- **Description:** After defeating an enemy, there's a chance it drops a **Friendship Token** — a glowing heart that floats from the defeated foe. Collecting this token and delivering it to a **Monster Barn** permanently befriends that enemy type. Befriended monsters become allies: they patrol the level, help fight other enemies, and can be ridden as mounts. Each monster type has a unique ally ability — Slimes bounce and find hidden items, Drackies fly and scout ahead, Golems smash obstacles, Sabrecats provide fast ground travel. Tamed monsters wear a tiny hat to show they're friendly.
- **Kid UX:** The child stamps **Monster Spawners** and a **Monster Barn** building. They can set a **"Tameable"** toggle on any enemy stamp (shown as a small heart icon on the enemy). During play, defeating a tameable enemy sometimes drops a glowing Friendship Token that floats upward. The player touches it to collect. Taking the token to the barn adds that monster type as a permanent friend, shown on a **Tame Board** with portraits of all befriended monsters. A **Call Whistle** item (stamped or earned) lets the player summon one tamed monster to their side. Tamed monsters wear a cute little top hat — the universal symbol of friendship.
- **LLM Automation:** Handles monster defeat detection and Friendship Token drop chance (typically 25-30% per tameable enemy), manages the Monster Barn registry (which types are tamed, their count, their level), implements tamed monster AI (ally behaviors per monster type: slime = bounce + item find, dracky = fly + reveal map, golem = smash barriers, sabrecat = fast mount), handles mount-riding physics for applicable monsters (movement speed increase, jump height changes), generates the cute hat accessory overlay on tamed monster sprites, and manages summon/dismiss via the Call Whistle item with a cooldown.
- **JSON Contract Extension:**
```json
{
  "monsterTaming": {
    "tokenDropChance": 0.3,
    "tameableToggle": true,
    "barnType": "monsterBarn",
    "summonItem": "callWhistle",
    "allyBehaviors": {
      "slime": "findHiddenItems",
      "dracky": "flyScout",
      "golem": "smashObstacles",
      "sabrecat": "fastMount"
    },
    "mountRiding": ["golem", "sabrecat", "greatDragon"],
    "friendlyVisual": "cuteHatOverlay",
    "maxTamedTypes": 10
  }
}
```

#### Soul Absorption Companion

- **Source Game:** *Castlevania: Aria of Sorrow* (Soul system — absorb enemy souls for abilities)
- **Description:** Defeating enemies sometimes releases their **soul** as a floating colored orb. Absorbing the soul grants the player that enemy's ability. Four soul types create distinct mechanical categories: **Bullet Souls** grant active attacks (throw bones, breathe fire, launch projectiles), **Guardian Souls** provide toggle buffs (transform into mist, summon a protective familiar), **Enchanted Souls** give passive stat boosts (increased strength, faster movement, higher luck), and **Ability Souls** grant permanent traversal upgrades (double jump, sliding, breaking walls). Only one Bullet, one Guardian, and up to three Enchanted souls can be active at once — forcing loadout decisions.
- **Kid UX:** The child stamps **Enemy Soul** orbs onto enemy stamps. The enemy gets a colored aura indicating soul type: red for Bullet (attack), blue for Guardian (buff), yellow for Enchanted (passive), silver for Ability (permanent). When the player defeats this enemy in-game, a glowing soul may float out with a "swoosh" sound. Touching it absorbs the ability with a flash. Absorbed souls appear as colorful badges in a **Soul Collection** screen, organized by type in four tabs. Dragging a soul into an active slot equips it. Ability souls auto-equip and are permanent. The soul collection screen shows a completion counter — "23 of 100 souls found!"
- **LLM Automation:** Handles soul drop RNG per enemy (typically 10-20% base chance, modified by luck stat), categorizes souls by type and applies the appropriate behavior (Bullet = active skill button, Guardian = toggle with MP drain, Enchanted = always-on passive modifier, Ability = permanent flag), manages equip limits (1 Bullet, 1 Guardian, 3 Enchanted, unlimited Ability), implements soul-specific attack behaviors and visual effects, tracks collection completion across all sessions, and auto-balances soul drop rates to ensure the player gets a steady stream of new abilities without overwhelming them.
- **JSON Contract Extension:**
```json
{
  "souls": [
    {"id": "skeletonSoul", "type": "bullet", "ability": "throwBone", "dropRate": 0.15, "dropFrom": "skeleton"},
    {"id": "mistSoul", "type": "guardian", "ability": "mistForm", "dropRate": 0.10, "mpDrain": 5}
  ],
  "soulSlots": {"bullet": 1, "guardian": 1, "enchanted": 3, "ability": -1},
  "soulCollection": {"total": 100, "collected": 0, "byType": {"bullet": 0, "guardian": 0, "enchanted": 0, "ability": 0}}
}
```

#### Beast Riding Mount System

- **Source Game:** *Monster Hunter* (mounting monsters) / *Zelda: Breath of the Wild* (horse taming)
- **Description:** Tamed large creatures can be ridden as mounts, dramatically changing traversal speed and capability. A **Sabrecat** runs at 3x player speed and jumps higher. A **Great Bird** flies for short distances, gliding over gaps. A **Golem** walks slowly but is immune to environmental hazards (lava, poison, spikes). A **Dolphin** enables fast underwater travel. Mounts are acquired through the Monster Taming system or found as wild creatures that require calming (feed them their favorite food while approaching slowly). Each mount has a stamina meter that depletes during sprinting or flying.
- **Kid UX:** The child stamps **Mount Spawn Points** in their level — each shows a silhouette of the mount type (cat, bird, golem, dolphin). Tapping the spawn sets the mount type via sticker picker. During play, approaching a mount shows a **"Ride!"** prompt. Tapping it triggers a mounting animation — the character hops on. Mount-specific controls appear: a **sprint button** for the Sabrecat, an **ascend/descend** control for the Great Bird, a **stomp button** for the Golem. The stamina meter appears as shrinking carrots above the mount. Dismounting is a single button tap with a graceful jump-off animation. Mounts wait patiently where dismounted, shown with a small saddle icon.
- **LLM Automation:** Manages mount state (wild, tamed, riding, waiting), implements mount-specific physics (Sabrecat = high ground speed + jump boost, Great Bird = flight with gravity override + glide on descent, Golem = slow speed + hazard immunity + heavy stomp attack, Dolphin = underwater speed boost + surface jumping), handles the mounting/dismounting animation and state transitions, manages stamina depletion and regeneration (stamina drains during sprint/fly, recovers when walking or idle), generates mount-specific composite sprites (character sprite positioned on mount), and handles mount waiting behavior (mount stays at dismount location, can be called with a whistle button within range).
- **JSON Contract Extension:**
```json
{
  "mounts": [
    {"id": "sabrecat", "speed": 3.0, "jumpBoost": 1.5, "stamina": 100, "special": "sprint"},
    {"id": "greatBird", "speed": 1.5, "flight": true, "stamina": 80, "special": "glide"},
    {"id": "golem", "speed": 0.6, "hazardImmunity": true, "stamina": 200, "special": "stomp"},
    {"id": "dolphin", "speed": 2.5, "swimOnly": true, "stamina": 120, "special": "surfaceJump"}
  ],
  "tameMethod": "feedWhileApproaching",
  "dismountJump": true,
  "callWhistleRange": 500
}
```

---

## 4.3 Squad & Swarm Management

These systems give the player control over multiple units simultaneously — throwing, recalling, and directing swarms of small creatures to solve puzzles, carry objects, and overwhelm enemies.

#### Pikmin Squad Management

- **Source Game:** *Pikmin* series (command a squad of up to 100 Pikmin)
- **Description:** The player commands a squad of small, plant-like creatures called **Pikmin**. Three core commands form the entire control scheme: **Throw** — aim and toss individual Pikmin to attack enemies, activate switches, or reach items; **Whistle** — blow a whistle to recall scattered Pikmin to the player's side, with a circular radius that expands the longer the button is held; **Swarm** — send all Pikmin rushing in the facing direction to attack or carry. Pikmin follow in a loose group, bobbing along behind the player. Squad size is shown as a number counter that updates in real-time as Pikmin are thrown, lost, or sprouted.
- **Kid UX:** The child stamps **Pikmin Onions** (the creatures' home bases) and **Pikmin Sprouts** in the ground. Plucking a sprout adds one Pikmin to the squad — shown as a small number increase. The **Throw** button lets the player aim with a directional indicator and tap to toss one Pikmin at a time. The **Whistle** button (big circle icon) expands outward when held — Pikmin within the circle rush back to the player. The **Swarm** button (arrow icon) sends all Pikmin charging forward. Squad count appears as a bold number next to the player portrait. Pikmin are tiny, cute, and die with a sad ghost float — but the Onion sprouts new ones over time.
- **LLM Automation:** Manages squad list with individual Pikmin state (following, thrown, attacking, carrying, dead), implements throw arc and targeting physics (parabolic arc affected by aim direction, auto-targets nearest valid entity in aim cone), handles whistle recall with pathfinding that avoids hazards and reunites scattered Pikmin, manages swarm behavior (all following Pikmin charge forward with collision detection for enemy engagement and item pickup), handles Pikmin death (defeated Pikmin leave a spirit that floats upward, squad count decreases), manages Pikmin sprouting from Onions over time (new Pikmin appear as sprouts that can be plucked), and ensures squad size never exceeds the maximum of 100.
- **JSON Contract Extension:**
```json
{
  "squad": {
    "maxSize": 100,
    "currentPikmin": [{"type": "red", "state": "following"}],
    "commandMode": "throw",
    "throwArc": {"gravity": 300, "maxDistance": 200},
    "whistleRadius": 150,
    "swarmDuration": 3.0,
    "sproutRate": "1_per_10_seconds"
  }
}
```

#### Pikmin Type System

- **Source Game:** *Pikmin* series (Red, Blue, Yellow, Purple, White, Rock, Winged, Ice)
- **Description:** Color-coded Pikmin types each have elemental resistances and unique abilities that make them suited for different tasks. **Red Pikmin** are fireproof and deal 1.5x attack damage — ideal for fighting fire enemies. **Blue Pikmin** are waterproof and can swim — essential for water sections. **Yellow Pikmin** are electricity-proof, can be thrown higher, and conduct electricity to activate circuits. **Purple Pikmin** are heavy (count as 10 for carrying) and stun enemies with ground pounds. **White Pikmin** are fast, poison-resistant, and can find buried treasure. **Rock Pikmin** shatter crystal barriers. **Winged Pikmin** fly over obstacles and carry items through the air. **Ice Pikmin** freeze water surfaces and enemies.
- **Kid UX:** Pikmin sprouts appear in the ground near their matching-colored Onion — red sprouts near the Red Onion, blue near the Blue Onion. Tapping a sprout plucks it, and the Pikmin's color is immediately visible. The HUD shows a breakdown by type: **R:12 B:8 Y:5** — simple color-coded counters. When the player aims a throw, a **type indicator** shows which Pikmin will be thrown next (they're thrown in plucked order). Type-specific interactions are taught through visual feedback: throwing a Red Pikmin into fire shows it walking through unharmed; throwing a Blue Pikmin into water shows it swimming happily while others would drown. Type icons appear as colored dots above each Pikmin for easy identification at a glance.
- **LLM Automation:** Manages Pikmin squad composition and count per type, implements type-specific behaviors and immunities (Red = no fire damage, Blue = swim physics instead of drown, Yellow = higher throw arc + no electric damage, Purple = 10x carry weight + stun on throw impact, White = 1.5x speed + buried item detection radius, Rock = crystal barrier destruction on impact, Winged = flight path for thrown trajectory + aerial carrying, Ice = freeze water surface on contact + slow enemies), handles elemental damage/resistance calculations per type, and auto-suggests type diversity when the child is designing levels (ensuring water sections have Blue sprouts, fire sections have Red sprouts).
- **JSON Contract Extension:**
```json
{
  "pikminTypes": [
    {"color": "red", "immuneTo": "fire", "attackMultiplier": 1.5, "canSwim": false, "special": "highDamage"},
    {"color": "blue", "immuneTo": "water", "attackMultiplier": 1.0, "canSwim": true, "special": "waterTraversal"},
    {"color": "yellow", "immuneTo": "electric", "attackMultiplier": 1.0, "throwHeight": 1.5, "special": "conductElectricity"},
    {"color": "purple", "immuneTo": "wind", "attackMultiplier": 1.2, "carryWeight": 10, "special": "groundStun"},
    {"color": "white", "immuneTo": "poison", "attackMultiplier": 0.8, "speedMultiplier": 1.5, "special": "treasureDetect"},
    {"color": "rock", "immuneTo": "crush", "attackMultiplier": 1.3, "special": "shatterCrystal"},
    {"color": "winged", "immuneTo": "ground", "attackMultiplier": 0.7, "special": "flight"},
    {"color": "ice", "immuneTo": "freeze", "attackMultiplier": 0.7, "special": "freezeEnemiesAndWater"}
  ]
}
```

#### Pikmin Object Carrying

- **Source Game:** *Pikmin* series (multi-unit transport puzzles)
- **Description:** Objects throughout the level (fruit, ship parts, treasures, bridge pieces) require a certain number of Pikmin to carry. When enough Pikmin are thrown at or directed toward a carryable object, they automatically grab it at designated attachment points and begin carrying it toward the nearest Onion or base. Carrying speed scales with Pikmin count — more Pikmin = faster transport. Heavy objects require more Pikmin (Purple Pikmin count as 10). The carrying system turns object transport into a satisfying group activity — a line of Pikmin marching with a giant strawberry is one of gaming's most charming sights.
- **Kid UX:** **Carryable object stamps** show a small number indicating "Pikmin needed" (e.g., a strawberry shows "8" in the corner). When enough Pikmin are thrown at the object, they automatically run to grab points and lift the object with a synchronized heave-ho animation. A **dotted path line** shows the route to the nearest Onion. A progress bar fills as the object nears its destination. The player can whistle to redirect carrying Pikmin mid-route — the dotted line updates dynamically. Objects that require bridge construction show a ghost outline of the completed bridge, and Pikmin carry planks one by one to fill it in. Large objects need more Pikmin, and the HUD shows **"Need 5 more!"** if insufficient Pikmin are assigned.
- **LLM Automation:** Calculates carry weight versus assigned Pikmin strength (each Pikmin = 1 carry unit, Purple = 10), generates carrying formation positions around the object (Pikmin position themselves at grab points), manages pathfinding to the nearest Onion or destination base (recalculates if the route is blocked), handles carrying speed based on Pikmin count ratio (at 100% required = normal speed, at 200% = double speed), manages object delivery and reward spawn at the destination, and auto-validates that carryable objects have valid paths to their destinations (no soft-locks from unreachable objects).
- **JSON Contract Extension:**
```json
{
  "carryObject": {
    "id": "fruit_001",
    "weight": 15,
    "assignedPikmin": 8,
    "destination": "onionBase",
    "progress": 0.6,
    "speedPerPikmin": 5,
    "grabPoints": 8,
    "redirectable": true
  }
}
```

#### Pikmin Onion Base

- **Source Game:** *Pikmin* series (Onion — the creature spawning and healing hub)
- **Description:** The **Onion** is the Pikmin squad's home base — a floating, bulbous creature that sprouts new Pikmin from collected nutrients, heals injured Pikmin, and serves as the destination for carried objects. Each Pikmin color type has its own Onion (Red Onion, Blue Onion, Yellow Onion). When enough carried objects are delivered, the Onion produces new Pikmin sprouts that can be plucked. The Onion follows the player at a height, beacon-like, and can be called to land at specific zones. It provides a safe zone where enemies cannot enter and Pikmin automatically heal.
- **Kid UX:** The child stamps an **Onion** near the level start — it floats gently with a colored glow matching its Pikmin type (red, blue, yellow). Tapping the Onion opens a simple menu: **"Sprout Pikmin"** (converts delivered items into new sprouts), **"Heal"** (recalls injured Pikmin for gradual recovery), and **"Land Here"** (the Onion floats to the tapped location). When objects are delivered, the Onion glows brighter and new sprouts pop from the ground nearby — shown as tiny leaf shoots that wiggle. Plucking a sprout (tap it) adds one Pikmin to the squad with a satisfying "pop!" sound. The Onion's follower count is displayed as a number on its side.
- **LLM Automation:** Manages Onion inventory (nutrients collected from delivered objects), calculates Pikmin sprout generation rate (typically 1 sprout per 3 small objects delivered), handles Pikmin healing over time when near the Onion (1 HP per 2 seconds), processes object deposits and spawns reward items at the Onion's location, manages Onion following behavior (floats above player at offset height, smooth movement), implements the Onion landing/takeoff animation state, creates the safe zone radius around the Onion where enemy AI cannot enter, and auto-distributes sprouts among multiple Onions when multiple Pikmin types are in the squad.
- **JSON Contract Extension:**
```json
{
  "onion": {
    "color": "red",
    "position": {"x": 100, "y": 200},
    "storedNutrients": 45,
    "pikminCapacity": 100,
    "activeSprouts": 12,
    "sproutRate": "1_per_3_objects",
    "healRate": "1hp_per_2sec",
    "safeZoneRadius": 100,
    "followOffset": {"x": 0, "y": -80}
  }
}
```

#### Pikmin Day Cycle Timer

- **Source Game:** *Pikmin* series (sunset time limit — recover all Pikmin before dark)
- **Description:** Each game "day" has a time limit (approximately 10-15 minutes of real time). The sun moves across the sky as a visible arc. As sunset approaches, the sky shifts from blue to orange to deep red. At sunset, any Pikmin not recalled to the Onion are lost — they scatter in panic and cannot survive the night. This creates gentle urgency that encourages strategic planning: kids must balance exploration, combat, carrying, and recall timing. The day cycle is optional and can be disabled for a more relaxed experience.
- **Kid UX:** The **sun position** is shown at the top of the screen as an arc that the sun icon slowly traverses from left (morning) to right (evening). A simple **timer** shows remaining daylight as a shrinking bar. The sky color transitions from bright blue through warm orange to deep red as time passes. A **warning chime** plays at 1 minute remaining. When sunset hits, the screen darkens, a gentle "night falls" message appears, and any Pikmin not at the Onion sadly scatter. A **"Recall All!"** button whistles all Pikmin back to their Onions instantly. The day cycle toggle is a simple sun/moon stamp: tap to enable or disable.
- **LLM Automation:** Manages game time progression (scales real time to game time, typically 10 real minutes = 1 game day), updates sun position along the arc and sky color gradient (blue #4A90D9 → orange #F5A623 → red #D0021B), triggers the sunset warning chime at 60 seconds remaining, handles the end-of-day sequence (screen darkens, lost Pikmin scatter animation, saved Pikmin count displayed), auto-triggers the Recall All function when the panic button is pressed, and manages day-to-day persistence (Pikmin squad carries over, collected items persist, environment resets partially).
- **JSON Contract Extension:**
```json
{
  "dayCycle": {
    "dayLength": 600,
    "currentTime": 0,
    "sunsetWarningAt": 60,
    "skyGradient": ["#4A90D9", "#F5A623", "#D0021B"],
    "optional": true,
    "pikminSurviveNight": false,
    "recallAllButton": true
  }
}
```

---

## 4.4 Buddy & Co-op Systems

These features enable multiple characters to act in concert — whether through AI-controlled buddies with complementary abilities, combo attacks between characters, or true local co-op play.

#### Buddy Character Stamps

- **Source Game:** *Sonic 3 & Knuckles* (Tails flight, Knuckles glide/climb) / *Secret of Mana* (3-player simultaneous)
- **Description:** The player can have an AI partner character with unique traversal abilities that complement the main hero. **Flying Friend** (Tails-style) can fly and carry the player for a short time, reaching high platforms. **Climbing Friend** (Knuckles-style) can glide long distances and climb walls. **Bouncy Friend** can be thrown as a projectile to hit distant switches. **Digging Friend** can burrow through soft dirt blocks. **Strong Friend** can push heavy blocks and break walls. Each buddy type opens different traversal paths, encouraging replay with different companions.
- **Kid UX:** The child stamps a **Buddy Start Point** and picks a buddy type from a sticker row: **Flying Friend** (wings icon), **Climbing Friend** (claws icon), **Bouncy Friend** (spring icon), **Digging Friend** (shovel icon), **Strong Friend** (muscle icon). During play, the buddy follows the player with a slight delay for charm. Context prompts appear automatically: *"Press here to fly!"* appears when near a high ledge with a flying buddy, *"Throw buddy?"* appears near distant switches with a bouncy buddy. The buddy's portrait appears in the corner with their ability icon. Tapping the portrait triggers the buddy's special ability on demand.
- **LLM Automation:** Implements buddy AI (follows player with smooth interpolation and slight lag, avoids hazards automatically, catches up when far behind), handles buddy-specific ability activation (Flying = carry player for 5 seconds, Climbing = wall-climb and glide, Bouncy = thrown projectile physics, Digging = burrow through dirt blocks, Strong = push heavy objects and break weak walls), manages the carry/throw/glide state transitions, generates buddy sprite variants that match the main character's color scheme, and provides context-sensitive prompts based on buddy type plus environment combinations (detects high ledge + flying buddy = show fly prompt).
- **JSON Contract Extension:**
```json
{
  "buddies": [
    {"type": "flying", "ability": "carryPlayer", "duration": 5, "trigger": "contextPrompt"},
    {"type": "climbing", "ability": "wallClimbAndGlide", "glideRatio": 0.5},
    {"type": "bouncy", "ability": "thrownProjectile", "damage": 10, "range": 200},
    {"type": "digging", "ability": "burrowThroughDirt", "speed": 2.0},
    {"type": "strong", "ability": "pushAndBreak", "pushWeight": 100, "breakDamage": 50}
  ],
  "aiBehavior": "followWithLag",
  "contextPrompts": true,
  "maxBuddies": 2
}
```

#### Triple-Tech Fusion Crystals

- **Source Game:** *Chrono Trigger* (Delta Force, Delta Storm, Lifeline, Omega Flare — triple tech combos)
- **Description:** Three characters (the player plus two AI buddies) can combine their powers at a **Fusion Crystal** object to unleash a devastating triple attack. Each combination of character classes produces a unique cinematic attack with combined elemental effects. Fighter + Mage + Healer = **"Lifeline"** (party auto-revive aura with healing beams). Fighter + Ice Mage + Lightning Mage = **"Delta Force"** (a colossal shadow-elemental blast). Fire Mage + Ice Mage + Sword Fighter = **"Delta Storm"** (elemental tornado that damages all enemies). The triple-tech is the ultimate expression of teamwork — three characters becoming one force.
- **Kid UX:** The child stamps three **Buddy Start Points** (Buddy A, Buddy B, Buddy C) and one **Fusion Crystal** in the level. They tap each buddy to pick its type from stickers (Fighter, Mage, Healer, Rogue, each with a distinct color). When playtesting, companions follow the player. Standing near the Fusion Crystal with all three buddies nearby triggers a **"FUSION READY!"** banner. Tapping the crystal initiates the cinematic triple-tech — the screen darkens, the three characters pose together, and the spectacular attack plays with screen-filling particles and a dramatic name announcement. Each unique class combination produces a different attack, encouraging experimentation.
- **LLM Automation:** Calculates valid triple-tech combinations from the three assigned classes using a combo recipe database (30+ unique triple-techs), generates the combo name and visual effect based on element fusion rules (fire + ice = steam explosion, lightning + sword = thunder blade, healing + light = radiant blessing), handles companion AI pathfinding to stay near the player and within fusion crystal range, triggers the cinematic camera sequence (slow-motion character poses, attack animation, screen effects), computes area-of-effect damage or buff application with appropriate scaling (triple-techs deal 5-8x normal damage to justify the setup), and prevents fusion spam with a per-crystal cooldown.
- **JSON Contract Extension:**
```json
{
  "companions": [
    {"id": "buddyA", "class": "fighter", "element": "fire"},
    {"id": "buddyB", "class": "mage", "element": "ice"},
    {"id": "buddyC", "class": "healer", "element": "lightning"}
  ],
  "objects": [{
    "type": "fusionCrystal",
    "autoTriggerRadius": 100,
    "comboResult": "autoCalculated",
    "cinematicDuration": 3.0,
    "cooldown": 30.0,
    "uniqueCombos": 30
  }]
}
```

#### Double-Tech Buddy Combos

- **Source Game:** *Chrono Trigger* (X-Strike, Fire Sword, Ice Sword, Antipode Bomb, Drill Kick)
- **Description:** When two characters with compatible abilities are near each other, they can perform a **combined attack** that triggers automatically or on demand. Fighter + Mage = **"Fire Sword"** (sword swing with a trailing fire wave). Mage + Healer = **"Aura Beam"** (heals all allies in a line). Two Fighters = **"X-Strike"** (crossing slash attack that hits a wide area). The combo triggers when both characters attack near-simultaneously while in proximity, or when the player taps a **"Combo!"** button that appears when conditions are met.
- **Kid UX:** The child stamps two **Buddy Start Points** and picks each buddy's type from stickers. A **thought bubble** appears when placing showing what combo the pair produces: *"Fighter + Mage = Fire Sword!"* with a small preview icon. During play, buddies follow the player. When the player attacks while a buddy is nearby and their combo is off cooldown, a **"COMBO!"** prompt flashes. Tapping it triggers the flashy combo animation with both characters' names and the attack name in big stylized letters. Combo attacks have a 10-second cooldown, shown as a radial fill on the combo button. The combo name and a brief effect description appear in a banner across the screen.
- **LLM Automation:** Maintains a combo compatibility matrix (which class pairs produce which combos — 20+ unique combinations), detects proximity (both characters within 80 pixels) and simultaneous attack timing (attacks within 0.5 seconds of each other), triggers the combo cinematic (brief freeze-frame, combined attack animation, damage application), computes combined damage or healing values with scaling (combo attacks deal 2.5-4x normal damage), generates combo names dynamically from the participating classes (e.g., "Fire Fighter + Ice Mage = Steam Blade"), and handles buddy AI positioning to stay within combo trigger range.
- **JSON Contract Extension:**
```json
{
  "buddyCombos": {
    "pairs": [{
      "classes": ["fighter", "mage"],
      "comboName": "fireSword",
      "trigger": "proximityAttack",
      "chancePercent": 100,
      "cooldown": 10.0,
      "damageMultiplier": 3.0
    }],
    "visualFx": "cinematicFlash",
    "buddyAiRange": 80,
    "autoPrompt": true
  }
}
```

#### Local Co-op Drop-In

- **Source Game:** *Super Mario Maker 2* / *Secret of Mana* (drop-in 2P with screen sharing)
- **Description:** A second player can join the game at any time by tapping a **"Join!"** bubble that appears over a helper character or at the level start. Both players share the same screen (no split-screen), with the camera smoothly tracking a midpoint between both characters. Player 1 controls the hero; Player 2 controls a buddy character with identical abilities. Both players can attack, jump, and use abilities independently. If one player falls behind, they're automatically warped to the leading player. Co-op turns every level into a shared experience.
- **Kid UX:** A **"2P Join"** button is always visible at the edge of the screen. Tapping it opens a character picker with the available buddy types. Player 2 taps their choice and appears with a sparkle at Player 1's location. Each player's character has a colored arrow above their head (P1 = blue, P2 = red). The camera smoothly follows both players — if they separate too far, the screen subtly zooms out. If one player falls in a pit, they respawn on the other player after 2 seconds. Both players can trigger combo attacks together by attacking near-simultaneously. A **"Leave"** button lets Player 2 drop out at any time, converting their character back to AI buddy control.
- **LLM Automation:** Manages co-op session state (drop-in, drop-out, player count), handles camera tracking for two players (calculates midpoint, zooms to keep both visible, enforces minimum and maximum zoom bounds), implements Player 2 input mapping (mirrors Player 1 controls on a second input device), handles the warp-respawn for fallen players (detects pit death, waits 2 seconds, spawns on surviving player with invincibility frames), manages combo attack detection between two human players (more reliable than AI timing), and gracefully converts Player 2's character to AI buddy control on drop-out.
- **JSON Contract Extension:**
```json
{
  "coop": {
    "maxPlayers": 2,
    "dropIn": true,
    "dropOut": true,
    "cameraMode": "sharedTracking",
    "maxPlayerDistance": 400,
    "respawnOnPartner": true,
    "respawnDelay": 2.0,
    "playerColors": ["#4488FF", "#FF4444"],
    "comboBetweenPlayers": true,
    "aiTakeoverOnLeave": true
  }
}
```

#### Dual-Character Switching

- **Source Game:** *Castlevania: Portrait of Ruin* (Jonathan the warrior + Charlotte the spellcaster)
- **Description:** Two playable characters with distinct stats, equipment, and abilities share the same screen, but only one is player-controlled at a time. The other follows as an AI companion with basic auto-attack behavior. Switching is instant — tap the **SWAP** button and control transfers seamlessly. Jonathan is a warrior with high STR, melee attacks, and physical skills. Charlotte is a spellcaster with high INT, ranged magic, and support spells. Both characters have separate HP and MP pools, separate equipment loadouts, and separate skill sets. Some puzzles require both characters' abilities to solve.
- **Kid UX:** The child stamps a **Hero** character and a **Partner** character with distinct class icons. Both appear on screen. A big colorful **"SWAP"** button at the screen edge switches control between them with a flash transition. The partner auto-follows and auto-attacks nearby enemies with a simple AI. The child can drag equipment onto either character's body outline independently — both have their own weapon, armor, and accessory slots. Character portraits in the HUD show HP/MP for both, with the active character highlighted with a golden border. Puzzles that require both characters show **"Need Both!"** indicators — a pressure plate that needs Jonathan's weight plus Charlotte's magic activation, for example.
- **LLM Automation:** Manages partner AI (follows player with configurable distance, auto-attacks enemies within radius, casts spells when enemy in range and MP sufficient), handles HP and MP pools separately per character, manages shared inventory versus character-specific equipment loadouts, triggers combo attacks when both characters attack the same target simultaneously (bonus damage and special effects), handles the instant switch state transfer (camera focus, control input routing, active character flag), and manages dual-character puzzle validation (ensures levels with swap mechanics are solvable).
- **JSON Contract Extension:**
```json
{
  "characters": [
    {"id": "jonathan", "role": "warrior", "stats": {"str": 12, "int": 4}, "equipment": {}},
    {"id": "charlotte", "role": "mage", "stats": {"str": 5, "int": 14}, "equipment": {}}
  ],
  "switchCooldown": 0.5,
  "partnerAI": {"followDist": 80, "attackRadius": 120, "spellTrigger": "enemyInRange"},
  "dualCombos": [{"condition": "bothAttackSameTarget", "bonusDamage": 1.5, "effect": "elementalBurst"}]
}
```

#### AI Buddy Pathfinding

- **Source Game:** *Sonic the Hedgehog* (Tails AI) / *Portrait of Ruin* (partner AI)
- **Description:** The underlying AI system that makes all buddy and companion characters feel alive. Buddies follow the player with a slight, charming lag — they don't teleport to position but run, jump, and navigate obstacles to catch up. The AI avoids hazards (pits, spikes, enemies when low HP), takes shortcuts when possible, and activates context-appropriate abilities (flying over gaps, climbing walls, attacking enemies). Buddy AI has three modes: **Follow** (stay near player), **Attack** (engage enemies aggressively), and **Stay** (hold position). Mode can be toggled via a simple command wheel.
- **Kid UX:** The buddy character simply follows and helps — no complex commands needed. When the player jumps, the buddy jumps shortly after. When the player attacks, the buddy attacks the same target. If the buddy falls behind too far, a quick warp with a sparkle brings them back. Tapping the buddy opens a **command wheel** with three icons: a heart for Follow, a sword for Attack, a flag for Stay. The buddy's current mode is shown as a small icon above their head. The buddy never gets stuck for more than 3 seconds — the LLM ensures reliable pathfinding with automatic warp as fallback. Buddy AI behavior is invisible magic — kids just see a helpful friend who always seems to know what to do.
- **LLM Automation:** Implements A* pathfinding with platforming awareness (the buddy plans jump trajectories, not just flat ground paths), handles hazard avoidance (pits detected via raycast, enemies avoided when buddy HP below 25%), manages follow behavior with smooth acceleration/deceleration and slight intentional lag (0.3-0.5 seconds) for organic feel, handles automatic catch-up warp when buddy is off-screen for more than 3 seconds, implements mode-specific AI (Follow = stay within 100px, Attack = seek and destroy enemies within 200px, Stay = hold position and only attack enemies that approach), and manages buddy animation state mirroring (jump when player jumps, attack when player attacks) with natural timing variation.
- **JSON Contract Extension:**
```json
{
  "buddyAI": {
    "pathfinding": "aStarWithPlatforming",
    "hazardAvoidance": true,
    "followLag": 0.5,
    "catchupWarpDelay": 3.0,
    "modes": {
      "follow": {"targetDist": 100, "engageEnemies": false},
      "attack": {"seekRadius": 200, "engageEnemies": true, "priority": "nearestEnemy"},
      "stay": {"holdPosition": true, "engageEnemiesInRange": 50}
    },
    "autoJump": true,
    "autoAttack": true,
    "lowHpRetreat": 0.25
  }
}
```

#### Co-op Puzzle Pressure Plates

- **Source Game:** *Portal 2* / *Zelda: Four Swords* (cooperative puzzles requiring multiple characters)
- **Description:** Special puzzle elements that require two or more characters to activate simultaneously. **Pressure Plates** must have both players (or the player and their buddy) standing on them at the same time to open doors or trigger events. **Heavy Switches** need the combined weight of the player plus Pikmin or a buddy to depress. **Dual Levers** must be pulled simultaneously by two characters. **Light Beams** need one character to hold a mirror while the other stands on an activation tile. These puzzles naturally encourage co-op play and make having a buddy feel essential rather than optional.
- **Kid UX:** The child stamps **Pressure Plate** pairs that are color-matched (both red, both blue). When one plate is stepped on, it glows halfway; when both are activated, they glow fully and a connecting energy beam appears between them. **Heavy Switches** show a weight number — the player's weight is 1, each Pikmin adds 0.1, and a buddy adds 1. The switch depresses when enough weight is applied. **Dual Levers** show left and right positions with big hand icons. During co-op, each player naturally goes to one lever. Solo players can command their buddy to hold a lever via the command wheel. Puzzle solutions trigger dramatic results: doors slide open, bridges extend, treasures rise from the ground.
- **LLM Automation:** Detects simultaneous activation state for all paired puzzle elements (pressure plates, levers, switches), calculates combined weight for heavy switches (player weight + buddy weight + Pikmin count × 0.1), validates that paired elements are both active before triggering the result, handles the visual connection beam between paired elements (pulses when partially active, solid when fully active), generates appropriate puzzle result animations (door open, bridge extend, treasure rise), ensures co-op puzzles are solvable in single-player mode via buddy command or Pikmin weight, and auto-validates that paired elements have valid paired targets (no orphaned plates or levers).
- **JSON Contract Extension:**
```json
{
  "coopPuzzles": {
    "pressurePlates": [
      {"id": "plateA", "pairId": "redPair", "position": {"x": 100, "y": 300}, "weightRequired": 1},
      {"id": "plateB", "pairId": "redPair", "position": {"x": 500, "y": 300}, "weightRequired": 1}
    ],
    "heavySwitches": [
      {"id": "heavy1", "weightRequired": 2.5, "currentWeight": 0}
    ],
    "dualLevers": [
      {"id": "leverPair1", "leftPosition": {"x": 200, "y": 400}, "rightPosition": {"x": 400, "y": 400}}
    ],
    "result": {"type": "openDoor", "targetId": "puzzleDoor1"}
  }
}
```

#### Companion Revival System

- **Source Game:** *Monster Hunter* (Palico revive vigorwasp) / *Left 4 Dead* (teammate revival)
- **Description:** When a companion's HP reaches zero, they don't die permanently — instead, they enter a **Downed State** where they crawl slowly and cannot attack. The player (or another companion) has 30 seconds to reach the downed companion and hold a **"Revive!"** button to bring them back with 25% HP. If not revived in time, the companion retreats to the last safe point and must be re-summoned or found. This system keeps companions feeling durable while creating dramatic "save your friend!" moments that kids find emotionally engaging.
- **Kid UX:** When a companion's HP hits zero, a dramatic **"Oh no!"** sound plays, the companion falls with a sad animation, and a **countdown timer** (30 seconds) appears above them as a shrinking red circle. The companion crawls slowly toward the player with a *"Help!"* speech bubble. The player runs over and holds the **Revive** button (big heart icon) for 2 seconds — a healing beam connects player to companion, and the companion stands up with 25% HP and a grateful **"Thanks!"** animation. If revival fails, the companion fades with sparkles and reappears at the last checkpoint. The countdown timer creates genuine urgency without being punishing.
- **LLM Automation:** Detects companion HP reaching zero, triggers downed state (disables attacks, reduces movement speed to crawl, enables revive interaction), manages the 30-second countdown timer with visual shrinking circle and escalating warning sounds at 10 seconds, handles the revival interaction (player within 50px + revive button held for 2 seconds = companion restored to 25% HP with invincibility frames), implements retreat behavior if countdown expires (companion fades, respawns at last checkpoint or Onion), prevents permanent companion death (all companions are revivable or respawnable), and manages companion AI during downed state (crawl toward player at 20% normal speed).
- **JSON Contract Extension:**
```json
{
  "companionRevival": {
    "downedDuration": 30,
    "reviveHoldTime": 2.0,
    "reviveHpPercent": 0.25,
    "reviveRange": 50,
    "invincibilityAfterRevive": 3.0,
    "crawlSpeedMultiplier": 0.2,
    "respawnIfNotRevived": true,
    "respawnLocation": "lastCheckpoint"
  }
}
```

---

## 4.5 Living World & Ecosystem

These features create self-sustaining creature populations that evolve, breed, and react to the player's behavior — making the game world feel like a living ecosystem rather than a static stage.

#### Nightopian A-Life Ecosystem

- **Source Game:** *NiGHTS into Dreams* (A-Life system — Nightopian creatures with moods, breeding, evolution)
- **Description:** Small creatures called **Dreamlings** inhabit the level autonomously. They have simple AI-driven lives: wandering, eating found items, sleeping at night, fleeing from danger, and breeding when happy. The player's behavior directly affects their mood — being friendly (feeding, not attacking) makes them happy and they multiply; being aggressive scares them and they hide in burrows. Over multiple playthroughs, the population evolves — colors shift, behaviors adapt, and the ecosystem becomes unique to that player's interaction history. Happy Dreamlings give the player bonus points and sometimes drop helpful items. This system makes every level feel like a living world.
- **Kid UX:** The child stamps **Dreamling Nests** (small burrows in the ground or trees where creatures spawn) and **Dreamling Food** sources (berry bushes, flower patches). During play, cute little creatures wander around with visible mood indicators: **heart bubbles** = happy, **sweat drops** = scared, **Zzz** = sleeping, **music notes** = breeding. Breeding produces baby Dreamlings with mixed parent colors. The ecosystem runs autonomously — the child can observe without interacting. Tapping a Dreamling pets it, increasing happiness. The population is capped at 20 per level to prevent performance issues. A **population meter** in the corner shows current count and average mood.
- **LLM Automation:** Implements each Dreamling's AI state machine (wander when happy, eat when food nearby, sleep during night phases, flee when player attacks or enemies approach, breed when happiness > 0.7 and partner nearby), tracks mood and population across play sessions (persisted per level), handles breeding logic (color blending between parents, trait inheritance with small random mutations), generates evolutionary variations over time (colors shift toward dominant parent hues, behaviors become more docile if player is friendly), implements mood-based player interactions (happy Dreamlings approach player, scared ones flee, neutral ones ignore), manages population cap enforcement (breeding pauses when at maximum), and handles reward drops from happy Dreamlings (bonus points, occasional item drops).
- **JSON Contract Extension:**
```json
{
  "aLifeEcosystem": {
    "creatureName": "dreamling",
    "aiStates": ["wander", "eat", "sleep", "flee", "breed"],
    "moodFactors": ["playerFriendliness", "foodAvailability", "populationDensity", "enemyProximity"],
    "breeding": {"requiresHappiness": 0.7, "colorInheritance": "blend", "mutationChance": 0.1},
    "evolution": "generationalOverSessions",
    "playerRewards": "moodBased",
    "populationCap": 20,
    "foodSources": ["berryBush", "flowerPatch"],
    "sleepSchedule": "nightTime"
  }
}
```

#### Creature Evolution & Breeding Lab

- **Source Game:** *Pokemon* (evolution lines) / *Monster Hunter* (creature breeding)
- **Description:** A dedicated **Breeding Lab** stamp allows the player to combine two companion creatures or tamed monsters to produce offspring with inherited traits. The baby inherits the primary type from Parent A and the secondary ability from Parent B, with a chance of random **mutation** — a completely new trait neither parent had. As creatures gain experience through combat, they **evolve** through visual stages: Stage 1 (baby) → Stage 2 (juvenile) → Stage 3 (adult) → Stage 4 (elder, optional). Each evolution changes the creature's sprite, size, and unlocks a new ability. Evolution is triggered at experience thresholds and celebrated with a transformative animation.
- **Kid UX:** The child stamps a **Breeding Lab** building (cute science lab with heart decorations). Tapping it opens a **pairing screen** showing all available creatures as portrait cards. The child drags two cards into the parent slots. A **prediction preview** shows the likely offspring type and a question mark for potential mutations. Tapping **"Breed!"** starts a short animation — the two creatures dance together, a baby creature hatches from an egg with a mix of both parents' colors. For evolution, creatures gain stars as they fight. At 3 stars, an **"Evolve!"** prompt appears — tapping it triggers the evolution sequence: the creature glows, transforms, and emerges bigger and more impressive. Evolution is irreversible and deeply satisfying.
- **LLM Automation:** Manages the breeding algorithm (primary type from Parent A, secondary ability from Parent B, 15% mutation chance producing a random new trait), handles offspring generation (procedural sprite compositing blending parent colors and features at 50/50 ratio), implements experience tracking per creature with automatic star gain on combat participation, manages evolution triggers at threshold checks (Stage 2 at 3 stars, Stage 3 at 8 stars, Stage 4 at 15 stars), generates evolution transformation animations (glow → sprite swap → particle burst → new form), handles mutation trait assignment from a pool of rare abilities, and manages the breeding cooldown (parents cannot breed again for 5 minutes, shown as a sleeping icon).
- **JSON Contract Extension:**
```json
{
  "breedingLab": {
    "parents": [{"id": "creatureA"}, {"id": "creatureB"}],
    "offspring": {
      "primaryType": "parentA",
      "secondaryAbility": "parentB",
      "mutationChance": 0.15,
      "mutationPool": ["rareFire", "rareIce", "rareLightning", "rareHeal"]
    },
    "evolution": {
      "stages": [
        {"stage": 1, "name": "baby", "starThreshold": 0},
        {"stage": 2, "name": "juvenile", "starThreshold": 3},
        {"stage": 3, "name": "adult", "starThreshold": 8},
        {"stage": 4, "name": "elder", "starThreshold": 15}
      ]
    },
    "breedCooldown": 300
  }
}
```

#### Companion Command Wheel

- **Source Game:** *Final Fantasy XII* (Gambit system simplified) / *Pikmin* (command whistle)
- **Description:** A radial command menu that gives the player direct control over companion and pet behaviors. The wheel appears when the player taps and holds on a companion, displaying context-sensitive commands: **Attack** (target the nearest enemy), **Stay** (hold position), **Follow** (return to following), **Use Ability** (trigger the companion's special skill), **Heal Me** (companion uses healing item if available), **Fetch** (grab a distant item). Commands are represented as large, colorful icons that even pre-readers can understand. The command wheel puts the player in the role of a leader directing their team.
- **Kid UX:** The child **taps and holds** on any companion — a radial **Command Wheel** appears around the companion with 4-6 large icons: a sword for Attack, a flag for Stay, a heart for Follow, a star for Use Ability, a potion for Heal, a hand for Fetch. Releasing the finger on an icon executes the command. The companion responds with a happy acknowledgment animation and a small speech bubble showing the command icon (e.g., a sword bubble = "I'll attack!"). The command wheel only shows actions the companion can actually perform in the current context — if no enemies are near, the Attack icon is dimmed. Commands are learned through experimentation; the LLM tracks which commands a child uses most and puts those icons in the most accessible positions.
- **LLM Automation:** Generates the radial command wheel UI with context-sensitive icon availability (Attack only shown when enemies in range, Heal only when companion has healing ability and player HP < 100%, Fetch only when items in range), handles command execution and companion AI state switching (Attack = seek and destroy nearest enemy, Stay = disable movement and hold position, Follow = resume follow AI, Use Ability = trigger companion's equipped special), manages command acknowledgment (companion plays reaction animation + speech bubble), tracks command usage frequency for UI personalization, and ensures the command wheel appears within 0.2 seconds of tap-and-hold for responsive feel.
- **JSON Contract Extension:**
```json
{
  "commandWheel": {
    "commands": [
      {"id": "attack", "icon": "sword", "context": "enemyInRange"},
      {"id": "stay", "icon": "flag", "context": "always"},
      {"id": "follow", "icon": "heart", "context": "notAlreadyFollowing"},
      {"id": "useAbility", "icon": "star", "context": "abilityOffCooldown"},
      {"id": "heal", "icon": "potion", "context": "playerHpBelow100"},
      {"id": "fetch", "icon": "hand", "context": "itemInRange"}
    ],
    "appearDelay": 0.2,
    "contextSensitive": true,
    "trackUsage": true,
    "acknowledgeAnimation": true
  }
}
```

---

## Comparison Tables

### Companion System Comparison

| System | Source | Role | Combat? | Customizable? | Kid Appeal |
|--------|--------|------|---------|--------------|------------|
| Familiar | *Castlevania* | Passive assist | Limited | Level-up only | High — floating pet |
| Helper (Converted Enemy) | *Kirby* | Active fighter | Yes | Inherits enemy ability | Very High — enemy becomes friend |
| Spirit Summon | *Elden Ring* | Timed ally | Yes | Type selection | High — crystal magic |
| Palico | *Monster Hunter* | Full combat partner | Yes | Full gear + gadget | Very High — customizable cat |
| Rush Adapter | *Mega Man* | Transformation tool | No | Form selection | Very High — robot dog |
| Dream Eater | *Kingdom Hearts 3D* | Created companion | Yes | Full creation system | Very High — make your own |
| Soul Absorption | *Castlevania* | Ability source | Yes | Loadout system | Medium — collection focused |

### Pet & Follower Comparison

| System | Source | Acquired By | Provides | Limit |
|--------|--------|-------------|----------|-------|
| Animal Feeding | *Okami* | Give preferred food | Stat boosts + treasure | 3 slots |
| Monster Taming | *DQ Builders 2* | Friendship token at barn | Combat + mounts | Barn capacity |
| Pikmin Squad | *Pikmin* | Sprout from Onion | Combat + carrying | 100 total |
| Pikmin Types | *Pikmin* | Color-specific Onion | Elemental abilities | Type-distributed |

### Co-op & Combo Comparison

| System | Source | Players | Trigger | Effect |
|--------|--------|---------|---------|--------|
| Buddy Stamps | *Sonic/Secret of Mana* | 1P + AI | Context prompt | Traversal assist |
| Triple-Tech | *Chrono Trigger* | 1P + 2 AI | Fusion Crystal | Cinematic mega-attack |
| Double-Tech | *Chrono Trigger* | 1P + 1 AI | Proximity attack | Combined attack |
| Local Co-op | *Mario Maker 2* | 2P human | Drop-in anytime | Shared screen play |
| Dual-Character | *Portrait of Ruin* | 1P (swappable) + AI | SWAP button | Two distinct playstyles |
| Buddy AI | *Sonic* | 1P + AI | Automatic | Follow + auto-attack |

### Squad Management Comparison

| Feature | Source | Unit Count | Core Commands | Primary Use |
|---------|--------|------------|--------------|-------------|
| Pikmin Squad | *Pikmin* | Up to 100 | Throw, whistle, swarm | Combat + carrying |
| Pikmin Types | *Pikmin* | 8 variants | Type-distributed | Elemental puzzles |
| Pikmin Carry | *Pikmin* | Variable per object | Auto-assign to carry points | Object transport |
| A-Life Ecosystem | *NiGHTS* | Up to 20 | Indirect (mood-based) | Living world simulation |


---

# 5. World Building, Terrain & Environment

The world is the stage upon which every adventure unfolds. This chapter transforms the blank canvas into a living, breathing landscape that reacts to the player's presence, changes with the passage of time, and invites creative expression at every turn. Drawing from Nintendo's mastery of environmental design — the chemistry-driven playgrounds of Zelda, the sculptable islands of Animal Crossing, the ink-soaked arenas of Splatoon, and the endlessly inventive construction kits of Mario Maker — these features give young creators god-like powers over their game worlds. Every terrain tool, every weather effect, every interior design option is accessible through stamps, taps, and drag gestures. The LLM silently manages physics, elemental reactions, and procedural generation so that the child sees only magic.

---

## 5.1 Terrain Sculpting & Landscape Tools

The foundation of every world is its ground. These features give children complete creative control over the shape and texture of their landscapes, from rolling hills to towering cliffs to winding rivers.

### Terrain Sculpting (Cliff & River Builder)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Animal Crossing: New Horizons |
| **Description** | A real-time terrain modification system that lets children raise and lower land to create cliffs up to three levels high, dig rivers and ponds, and craft cascading waterfalls. The terrain responds to sculpting commands with immediate visual feedback — water auto-flows into connected basins, cliff faces auto-generate appropriate textures, and waterfalls appear automatically when water flows over a cliff edge. |
| **Kid UX** | The child selects the **Terrain Wand** stamp from the tools palette. Four large buttons appear: "Make Hill," "Dig River," "Make Lake," and "Make Waterfall." Tapping "Make Hill" and then tapping the canvas raises a circle of land one level. Tapping the same spot again raises it to level two, then three. "Dig River" creates a water channel that the child draws by dragging their finger — water fills the channel as they draw, connecting to nearby water automatically. Cliff faces darken at higher elevations, giving an immediate sense of verticality. |
| **LLM Automation** | Maintains a heightmap data structure for the entire terrain grid, validates cliff placement rules (ensuring cliffs have adequate support and don't create impossible overhangs), simulates water flow physics (filling connected basins, calculating flow direction, generating waterfall detection at cliff edges), and auto-generates appropriate visual assets per grid cell (grass, dirt, stone textures based on elevation and water proximity). |
| **JSON Contract Extension** | `terrainMap: { gridSize, heightMap[][], waterMap[][], waterfalls[], cliffFaces[] }` |

### Terrain Painting Grid

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Animal Crossing: New Horizons / Dragon Quest Builders 2 |
| **Description** | A cell-based heightmap editing system where each grid cell can be independently painted with terrain types — grass, dirt, sand, snow, stone, wood planks, or custom patterns. The grid provides the underlying structure for all terrain sculpting operations, ensuring that every modification aligns cleanly with the game world's spatial indexing. |
| **Kid UX** | The child taps the **Terrain Palette** button to reveal a color-grid of terrain types, each represented by a large, textured square stamp: green grass, brown dirt, yellow sand, white snow, gray stone, brown wood. The child taps a terrain type, then taps or drags across the canvas to "paint" the ground. Painted terrain transitions blend smoothly at edges via auto-generated border tiles. A "Magic Fill" option floods an enclosed area with the selected terrain. |
| **LLM Automation** | Maintains the 2D terrain type grid aligned with the heightmap, generates smooth transition tiles at terrain boundaries (blending grass into dirt, sand into water), handles terrain-type-specific physics properties (sand has reduced friction, ice is slippery, snow leaves footprints), and optimizes rendering via terrain chunking. |
| **JSON Contract Extension** | `terrainPaintGrid: { cellSize, terrainTypes[][], blendTransitions, physicsOverrides }` |

### Terraforming Hammer (Real-Time Build/Break)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dragon Quest Builders 1 & 2 |
| **Description** | An in-game tool that lets the player character modify terrain during gameplay, not just in the editor. The hero wields a cartoon hammer to break terrain blocks (collecting them as resources) and place new blocks from their inventory. This enables dynamic bridge-building over pits, staircase construction up cliffs, and wall-building for defense. |
| **Kid UX** | The child stamps a **Builder Hammer** item somewhere in the level. When the hero picks it up during play, three large on-screen buttons appear: "Smash" (breaks the block in front), "Build" (places a block from inventory), and a block-selector showing collected block types. Breaking dirt blocks yields brown "Block Bits" that can be spent to place new blocks. The terrain grid highlights valid placement spots in green. The system prevents the child from trapping themselves — the LLM will not allow placement that creates an inescapable pit around the player. |
| **LLM Automation** | Implements the destructible terrain grid with per-block HP and type tracking, manages block inventory (bits collected = placement currency), enforces structural integrity checks (cascading block physics for unsupported terrain), validates anti-trap placement rules, and generates satisfying particle bursts for every break and place action. |
| **JSON Contract Extension** | `terraforming: { tool, gridSize, breakYield, placeCost, operations[], antiTrapValidation, cascadeGravity }` |

### Slope Placement (Gentle & Steep)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Super Mario Maker 2 |
| **Description** | Terrain ramps at two angles — gentle (22.5 degrees) and steep (45 degrees) — that affect player movement speed automatically. Characters slide down steep slopes, run faster downhill, and slow climbing uphill. Slopes enable slide-kill mechanics where the player damages enemies by sliding into them. |
| **Kid UX** | The child selects the **Slope** stamp and drags to set its length and direction. Two toggle buttons appear: "Gentle Hill" (shallow angle, shown with a long ramp icon) and "Steep Hill" (sharp angle, shown with a steep ramp icon). Characters automatically slide down steep slopes with arms-flailing animations. The child can stamp "Slide Bumpers" at the bottom of slopes to launch the player into the air. |
| **LLM Automation** | Generates slope colliders with proper angular physics, applies velocity modifications for slope traversal (acceleration downhill, deceleration uphill), detects slide-state activation on steep slopes, handles slide-kill collision damage against enemies, and auto-generates ramp visual assets matching the terrain type. |
| **JSON Contract Extension** | `slopes: { angle, startPosition, endPosition, physics: { slideSpeed, climbSlowdown }, slideKillEnabled }` |

### Destructible Terrain Blocks

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Shovel Knight / Zelda |
| **Description** | Specialized terrain blocks that react to player actions — dirt blocks can be dug through, bomb blocks explode when hit, fragile walls crumble from attacks, and ice blocks melt from fire. Destructible blocks hide secrets, create shortcuts, and reward experimentation. |
| **Kid UX** | The child stamps **Dirt Block**, **Bomb Block**, **Fragile Wall**, and **Ice Block** terrain stamps. Dirt blocks show a cracked surface; bomb blocks have a visible fuse; fragile walls have spiderweb cracks; ice blocks shimmer blue. When the hero attacks a dirt block, it crumbles with brown dust particles. Bomb blocks flash red before detonating in a circular blast. Broken blocks stay broken for the rest of the play session. |
| **LLM Automation** | Manages destruction trigger detection per block type (attack, fire, explosion), handles block HP and destruction state transitions, spawns appropriate debris particles and sound effects, reveals hidden content behind destroyed blocks, and persists destruction state across the session. |
| **JSON Contract Extension** | `destructibleBlocks: { blockTypes: { dirt, bomb, fragile_wall, ice_block }, destructionStatePersists, hiddenBehindChance }` |

### Semisolid Platforms (Jump-Through)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Super Mario Maker 1 & 2 |
| **Description** | Platforms that can be jumped through from below but are solid from above. Available in visual styles including wooden bridge, mushroom cap, tree branch, and cloud. Semisolid platforms can be stacked and layered to create complex vertical structures without blocking upward movement. |
| **Kid UX** | The child taps the **Semisolid** stamp and drags to set its width. A dotted outline on the bottom half indicates the pass-through zone. When the hero jumps upward through the platform, they pass cleanly through it. Landing on top from above treats it as solid ground. The child can layer multiple semisolids to create tiered platforms and branching paths. |
| **LLM Automation** | Configures one-way collision detection (top surface solid, bottom and sides pass-through), handles layering with other platforms, manages dynamic body interactions when the player stands on or passes through, and auto-generates appropriate visual assets for each semisolid style. |
| **JSON Contract Extension** | `semisolidPlatforms: { width, style, collision: one_way_top, layer }` |

---

## 5.2 Pathways, Transport & Traversal Geometry

Getting around should be as fun as the destination. These features create dynamic pathways that move, connect, and transform the world into a playground of kinetic possibility.

### Clear Pipes (Transparent Transport Tubes)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Super Mario Maker 2 (3D World style) |
| **Description** | Transparent pipe segments that transport the player, enemies, and items at high speed through any path the child draws. Pipes auto-connect at endpoints, support branching junctions, and show their passengers clearly during transit. The transparency creates a delightful visual of characters zipping through the world. |
| **Kid UX** | The child stamps **Pipe Entry** and **Pipe Exit** markers, then draws pipe segments between them by dragging. Pipes render as transparent tubes with a subtle glass sheen. The child can tap pipe nodes to create branching paths. During play, entering a pipe launches the hero at high speed — visible as a small figure shooting through the tube. Junction nodes show arrow indicators for direction selection. Enemies and items placed inside pipes travel through them automatically. |
| **LLM Automation** | Builds the pipe network graph from drawn segments, handles smooth entry/exit transitions with velocity preservation, supports multi-passenger routing (player, enemies, items), validates pipe network connectivity, manages junction direction logic, and renders transparent pipe visuals with passenger visibility. |
| **JSON Contract Extension** | `clearPipes: { segments[], speed, bidirectional, junctionNodes[], networkGraph }` |

### Track Systems (Moving Object Paths)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Super Mario Maker 1 & 2 |
| **Description** | Drawable paths that moving objects — platforms, enemies, coins, even hazards — follow automatically. Tracks support straight segments, curves, and loops. Objects placed on tracks follow the path continuously or wait for player activation. Multiple objects can share a track, creating synchronized moving sequences. |
| **Kid UX** | The child selects the **Track Pen** tool and draws a path by dragging across the canvas. Snap points appear at grid intersections. The child places a platform, enemy, or item on the track — it automatically attaches and begins following the path. Tapping track nodes cycles between speeds: "Slow" (turtle icon), "Medium" (bunny icon), "Fast" (rocket icon). A "Loop" toggle makes objects repeat the path indefinitely. |
| **LLM Automation** | Converts drawn track paths into smooth bezier curves, assigns path-following behavior to tracked entities, handles speed changes at track nodes, manages loop vs. one-shot path completion, calculates synchronized timing for multiple objects on shared tracks, and validates track paths don't intersect solid terrain. |
| **JSON Contract Extension** | `tracks: { path[], speed, looped, activation, attachedEntities[] }` |

### Auto-Scroll Camera Control

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Super Mario Maker 1 & 2 |
| **Description** | Forces the camera to move at a set speed in a chosen direction, pushing the player forward and creating timed platforming challenges. Multiple speeds and directions allow for everything from slow cinematic reveals to frantic escape sequences. The auto-scroll boundary prevents the player from being left behind. |
| **Kid UX** | A **Scroll Controller** stamp with a large directional arrow pad. The child taps an arrow to set scroll direction (up, down, left, right), then drags a speed slider with animal icons: "Turtle" (slow, gentle exploration), "Bunny" (medium, steady pressure), "Rocket" (fast, intense chase). Visual arrows on the canvas edge indicate the scroll direction during editing. The child can place multiple scroll zones to change speed mid-level. |
| **LLM Automation** | Sets camera velocity vector per scroll zone, clamps player position relative to the scroll boundary (soft push at edge), adjusts enemy spawn timing relative to scroll offset, handles zone transitions between different scroll speeds, and prevents the player from being crushed between the scroll edge and terrain. |
| **JSON Contract Extension** | `autoScroll: { enabled, speed, direction, speedValue, zones[] }` |

### Speed Tunnel Auto-Runner

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Sonic the Hedgehog series |
| **Description** | Special high-speed segments where the character auto-runs through a cinematic path at extreme velocity. The player controls only jump timing and optional lane switching. Speed tunnels can include loop-de-loops, corkscrew paths, and boost pads for pure spectacle. |
| **Kid UX** | The child stamps a **Speed Tunnel Entry** marker and a **Speed Tunnel Exit** marker. Between them, a glowing path preview appears. The child can stamp **Loop**, **Corkscrew**, and **Boost Pad** objects along the path. During play, entering the tunnel launches the auto-run — the hero zips along the path automatically while the child taps to jump over obstacles. Pure thrill with minimal input complexity. |
| **LLM Automation** | Generates the auto-run spline path between entry and exit markers, places spline waypoints for smooth camera following, implements loop-de-loop physics (rotation around path, gravity override), handles boost pad velocity changes, manages the transition back to normal platforming at the exit, and validates the tunnel path doesn't intersect solid terrain. |
| **JSON Contract Extension** | `speedTunnels: { entryMarker, exitMarker, pathElements[], playerControl, cameraMode, speedBase, gravityOverride }` |

### Cannon Travel Rapid Transit

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Secret of Mana |
| **Description** | Giant cannons placed at key locations launch the player in a dramatic arc across the level. The player sees their character flying through the air as a tiny spinning sprite before landing with a bounce. Cannons connect distant level sections and create memorable transit moments. |
| **Kid UX** | The child stamps a **Cannon Base** and a **Cannon Target** as a connected pair. A dotted parabolic arc shows the flight path between them. During play, pressing the action button at a cannon loads the character, shows a brief countdown (3, 2, 1 with big numbers), then launches them along the arc with a "BOOM!" sound and smoke cloud. Landing is automatic with a satisfying bounce animation. |
| **LLM Automation** | Generates the parabolic launch arc between cannon and target, implements the countdown and firing sequence, manages ballistic projectile physics during flight (parabolic arc with character spin), generates smoke and trail particles, handles auto-stick landing with bounce animation, and validates that the arc doesn't pass through solid terrain. |
| **JSON Contract Extension** | `cannonTravel: { components, trajectory, countdown, launchFx, flightSpin, landingBounce, arcPreview }` |

---

## 5.3 Elemental Chemistry Engine

The world is not static — it reacts. Borrowing the systemic brilliance of Zelda: Breath of the Wild and Tears of the Kingdom, the Elemental Chemistry Engine makes the environment an active participant in gameplay. Fire burns, water flows, ice freezes, electricity conducts, and wind pushes. Children place elements and watch them interact according to intuitive physical rules that they discover through playful experimentation.

### Core Element Sources

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Zelda: Breath of the Wild / Tears of the Kingdom |
| **Description** | Five elemental source types that the child can place anywhere in the world: **Fire Torches** (burn grass, wood, enemies; spread across flammable terrain), **Water Geysers** (extinguish fire, freeze into ice platforms, conduct electricity), **Ice Crystals** (freeze water, create slippery surfaces, melt into water when heated), **Lightning Clouds** (shock entities in water, activate metal objects, chain between conductive materials), and **Wind Fans** (push objects and players, extinguish small fires, activate pinwheels). |
| **Kid UX** | The child opens the **Elements** stamp palette and taps an element source. Fire torches flicker with orange particles; water geysers pulse with blue bubbles; ice crystals shimmer with frost; lightning clouds crackle with electricity; wind fans spin slowly. The child stamps them onto the canvas. Placing a fire torch next to a wooden crate immediately sets the crate ablaze with spreading fire. Placing a water geyser next to fire produces a dramatic steam cloud. Every combination produces visible, immediate feedback. |
| **LLM Automation** | Maintains the element state machine with pairwise interaction rules, processes element-material interactions each physics tick (fire spread across flammable terrain, water flow into basins, ice formation at water+cold interfaces, electricity conduction through metal, wind force application), manages propagation for spreading effects (fire, water), generates appropriate visual effects for every reaction (steam, explosions, frozen platforms, electric arcs), and ensures consistent, discoverable rule application across the entire world. |
| **JSON Contract Extension** | `chemistryEngine: { elements[], materials[], reactions[], propagationRules }` |

### Elemental Reaction Matrix

The Chemistry Engine supports a rich web of interactions that children discover through experimentation:

| Element A | + | Element B | = | Result |
|-----------|---|-----------|---|--------|
| Fire | + | Wood | = | Burning wood (spreads across flammable terrain) |
| Fire | + | Grass | = | Burning grass (leaves ash, damages entities) |
| Water | + | Fire | = | Steam cloud (obscures vision, deals minor damage) |
| Water | + | Hot Surface | = | Steam (disperses after 3 seconds) |
| Ice | + | Water | = | Frozen platform (solid, slippery surface) |
| Fire | + | Ice | = | Water pool (slippery, conducts electricity) |
| Electricity | + | Water | = | Shocked area (damages all entities in water) |
| Electricity | + | Metal | = | Conducted shock (chains to nearby metal) |
| Wind | + | Fire | = | Fire spread (pushes flames in wind direction) |
| Wind | + | Cloud | = | Moving cloud (relocates weather effect) |
| Fire | + | Explosive Barrel | = | Explosion (AOE damage, destroys nearby terrain) |
| Ice | + | Slippery Surface | = | Extra slippery (characters slide further) |

### Material Property System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Zelda: Breath of the Wild |
| **Description** | Every terrain and object stamp carries invisible material properties that determine how it interacts with elements. Wood is **flammable** and floats. Metal is **conductive** and magnetic. Stone is **heat-resistant** and breakable. Grass is **flammable** and can be cut. Ice is **slippery** and meltable. Water is **extinguishing** and freezable. The LLM manages these properties without exposing complexity to the child. |
| **Kid UX** | Material properties are entirely implicit — the child learns them through experimentation. Dropping a metal block near a lightning cloud causes it to spark. Dropping wood near fire causes it to burn. The world teaches its own rules through consistent, predictable reactions. A "Discovery Journal" stamp auto-populates with pictures of reactions the child has witnessed, creating a personal encyclopedia of element combinations. |
| **LLM Automation** | Tags every placed stamp with material properties based on its visual type, evaluates element-material interactions each frame, handles material state transitions (wood -> burning_wood -> ash), manages floating/sinking physics for materials in water, applies magnetic forces from electrical sources to metal objects, and auto-generates the Discovery Journal entries from witnessed reactions. |
| **JSON Contract Extension** | `materialProperties: { wood: { flammable, float }, metal: { conductive, magnetic }, stone: { heatResistant, breakable }, grass: { flammable, cuttable }, ice: { slippery, meltable }, water: { extinguishing, freezable } }` |

---

## 5.4 Zonai Device Gadgets

The Zonai devices from Zelda: Tears of the Kingdom represent one of the most exciting mechanical toolkits in modern game design. KidGameMaker distills these physics-driven gadgets into a palette of simple stamps that combine in emergent, physics-based ways. A child who stamps a fan, a balloon, and a basket has created a hot air balloon — no scripting required.

### Zonai Device Palette

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Zelda: Tears of the Kingdom |
| **Description** | A collection of physics-driven device stamps that generate force, motion, and effects: **Fan** (applies directional force vector, pushes objects and players), **Rocket** (explosive vertical thrust, burns out after 3 seconds), **Wheel** (rolling locomotion when powered), **Balloon** (buoyant lift, fills with hot air), **Spring** (bounce physics, launches entities upward), **Beam Emitter** (laser projectile, damages on contact), **Cannon** (projectile launcher, fires spherical objects), and **Battery** (power source for all devices, drains during use). |
| **Kid UX** | The child opens the **Gadgets** stamp palette showing cartoon icons: a blue fan, red rocket, gray wheel, yellow balloon, green spring, purple beam, orange cannon, and green battery. Each device stamp shows a small battery meter when placed. Tapping a placed device toggles it on/off during editing. During playtest, devices activate automatically when the player approaches or when linked to triggers. The child can drag devices onto each other to "glue" them into contraptions — a fan glued to a crate creates a pushable air platform. |
| **LLM Automation** | Simulates each device's physics effect (fan = continuous force vector, rocket = impulse burst, balloon = buoyancy force, spring = impulse on contact, beam = raycast damage, cannon = projectile spawn with velocity), manages battery drain across all connected devices, handles device-device interactions (two fans facing each other = hover platform), validates contraption stability, and generates emergent behavior from simple physics combinations. |
| **JSON Contract Extension** | `zonaiDevices: [{ type, position, force/buoyancy/impulse, batteryDrain, active, linkedDevices[] }]` |

### Autobuild (Contraption Blueprint System)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Zelda: Tears of the Kingdom |
| **Description** | Once the child builds a contraption by gluing Zonai devices together, they can save it as a "blueprint" and rebuild it instantly anywhere in their level. Blueprints appear as collectible cards with auto-generated thumbnails showing the contraption's appearance. This encourages iterative invention and sharing of designs. |
| **Kid UX** | After building a contraption, a **"Save Blueprint"** button glows. Tapping it saves the contraption as a blueprint card in the inventory. The card shows a cute thumbnail of the invention. During editing or gameplay, tapping the blueprint and then tapping anywhere reconstructs the contraption instantly with a satisfying "snap-together" animation and sound. Blueprint cards can be shared with friends via the community features. |
| **LLM Automation** | Serializes contraption state (device types, relative positions, rotations, joint connections), validates placement location for reconstruction (ensures enough open space), manages blueprint inventory and thumbnail generation, handles resource requirements for reconstruction, and ensures blueprints are portable across levels. |
| **JSON Contract Extension** | `blueprints: [{ id, name, thumbnail, parts[], joints[], creator }]` |

### Zonai Device Comparison

| Device | Primary Effect | Kid-Friendly Name | Battery Use | Best Combined With |
|--------|---------------|-------------------|-------------|-------------------|
| Fan | Directional push | "Wind Maker" | Low/medium | Wheel (car), Balloon (airship) |
| Rocket | Vertical thrust burst | "Zoom Stick" | High (burns out) | Crate (rocket platform) |
| Wheel | Rolling motion | "Round Mover" | Medium | Fan (self-driving car) |
| Balloon | Lift/buoyancy | "Floaty Bubble" | Low | Fan (dirigible), Spring (bouncy airship) |
| Spring | Vertical bounce | "Bouncy Pad" | None (passive) | Any surface (trampoline) |
| Beam | Damage ray | "Zap Zap" | Medium | Rotating platform (turret) |
| Cannon | Projectile launch | "Pop Pop" | Medium | Auto-trigger (defense system) |
| Battery | Power source | "Energy Box" | Drainable | All devices (extends runtime) |

---

## 5.5 Environmental Conditions

Static worlds feel artificial. These features introduce time, weather, seasons, and environmental hazards that make the game world feel alive, unpredictable, and responsive to the player's journey.

### Weather System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Zelda: Breath of the Wild / Animal Crossing |
| **Description** | Dynamic weather states that affect gameplay: **Rain** (makes surfaces slippery, extinguishes fire, fills water basins), **Snow** (creates snow accumulation, reduces visibility, freezes water), **Thunderstorm** (lightning strikes tall metal objects, rain + electricity combo), **Fog** (reduces visibility range, stealth bonus), and **Sandstorm** (pushes entities, reduces visibility, damages over time in desert). Weather can be set per-level, per-zone, or left to cycle dynamically. |
| **Kid UX** | The child stamps a **Weather Controller** in their level. Tapping it opens a weather wheel with five icons: rain cloud, snowflake, lightning bolt, fog bank, and swirling sand. Tapping an icon sets the weather, which applies immediately across the level. A "Random" option (dice icon) cycles weather every 2-3 minutes for variety. Each weather state has dramatic visual effects — raindrops splashing on surfaces, snowflakes accumulating on terrain, fog rolling in from edges. |
| **LLM Automation** | Manages weather state transitions with smooth visual crossfades, applies weather-specific physics modifications (rain = reduced friction, snow = snow accumulation layers, lightning = random strike targeting on tall/metal objects), handles weather-element interactions (rain extinguishes fire, snow freezes water), and generates appropriate ambient audio and particle effects for each weather state. |
| **JSON Contract Extension** | `weather: { current, transitionTime, effects: { rain: { slippery, extinguishesFire }, snow: { accumulation, freezesWater }, storm: { lightningStrikes }, fog: { visibilityRange }, sandstorm: { pushForce, damageOverTime } } }` |

### Day/Night Cycle

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Zelda / Secret of Mana / Okami |
| **Description** | A time-of-day system that transitions the world through dawn, day, dusk, and night. Each phase changes lighting, sky color, ambient sounds, and which entities are active. Night brings out nocturnal enemies and glowing collectibles; day activates friendly NPCs and certain puzzles. The cycle can run in real-time or be triggered manually. |
| **Kid UX** | The child stamps a **Sun/Moon Dial** in their level. A large circular slider shows the day as a colorful arc — orange dawn, bright blue day, purple dusk, dark blue night. Dragging the slider changes the time instantly, showing the lighting shift. Certain enemy stamps have a sun icon (day only) or moon icon (night only). The child stamps a "Sleeping Enemy" and sees it only appears at night. A "Night Flower" collectible only glows and becomes collectible after dark. |
| **LLM Automation** | Manages the time progression (real-time cycle or manual control), applies smooth lighting transitions and sky gradient changes, shows/hides time-specific entities based on their active hours, modifies enemy behavior (nocturnal enemies sleep during day), adjusts ambient audio (birds by day, crickets by night), and handles Okami-style brush-triggered time changes (draw a sun to force day). |
| **JSON Contract Extension** | `dayNightCycle: { cycleDuration, currentTime, phases[], timeSpecificEntities[], skyGradient[] }` |

### Seasonal Event System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Animal Crossing: New Horizons |
| **Description** | Time-based visual themes that transform the entire world based on season: **Spring** (cherry blossoms, blooming flowers, gentle rain), **Summer** (bright sunshine, beach items, fireworks at night), **Autumn** (falling leaves, orange foliage, harvest items), and **Winter** (snow covering all terrain, ice physics, holiday decorations). Each season brings exclusive stamps and collectibles. |
| **Kid UX** | A **Season** toggle in level settings offers five options: "Auto" (uses real-world date), Spring (pink cherry blossom icon), Summer (bright sun icon), Fall (orange leaf icon), and Winter (snowflake icon). Switching applies the visual theme instantly — grass changes color, trees swap foliage, the sky shifts hue, and seasonal item stamps appear in the palette. Spring brings "Cherry Blossom" and "Flower Seed" stamps. Winter brings "Snowman" and "Ice Slide" stamps. Each season feels like a different world. |
| **LLM Automation** | Maps real-world date to season when "Auto" is selected, applies seasonal visual themes to all terrain and foliage stamps, swaps tree and grass sprites for seasonal variants, spawns season-exclusive item stamps in the palette, handles seasonal music crossfades, and manages seasonal collectible availability. |
| **JSON Contract Extension** | `season: { mode, currentSeason, foliageColor, groundCover, seasonalItems[], seasonalStamps[], musicTheme }` |

### Wind Zones

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Celeste / Zelda |
| **Description** | Directional force fields that push players, enemies, projectiles, and loose objects. Wind zones can be gentle (affects jump arc slightly), strong (pushes entities continuously), or gusty (intermittent strong pushes). Wind carries leaves, snow, or sand particles for visual flair and interacts with fire (spreading it) and clouds (moving them). |
| **Kid UX** | The child stamps a **Wind Blower** (a fan with a large directional arrow). Dragging the arrow changes wind direction. Tapping the blower opens a strength picker: "Breeze" (gentle push, small arrow), "Windy" (strong push, medium arrow), "Storm" (powerful push, large arrow). During play, wind-affected zones show streaming particle lines indicating direction. Characters lean into the wind while walking against it and get pushed while standing still. |
| **LLM Automation** | Applies continuous directional force to all dynamic bodies within the wind zone, affects jump trajectory calculations (wind from below extends jumps, headwind shortens them), handles particle streamer rendering, manages wind-element interactions (spreading fire, moving clouds), and applies appropriate character animation leaning based on wind direction and strength. |
| **JSON Contract Extension** | `windZones: { position, width, height, forceVector, strength, particles, affectsElements }` |

### Rising Hazards (Lava / Water / Poison)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Celeste / Ori / Mario |
| **Description** | Upward-moving danger layers that force the player to climb continuously. Lava rises from below, water floods upward, or poison gas descends from above. Rising hazards create time pressure without a visible timer — the threat is visceral and spatial. The child controls the speed, starting height, and maximum height of the hazard. |
| **Kid UX** | The child stamps a **Rising Lava** or **Rising Water** zone at the bottom of their level. Tapping it opens simple controls: a speed slider ("Slow Creep" to "Fast Flood") and a max-height line that can be dragged. During play, the hazard rises steadily, bubbling and glowing. The player must climb platforms to stay ahead of it. Reaching the top of the level before the hazard does creates a dramatic escape. The child can also stamp "Drain" triggers that lower the hazard when activated. |
| **LLM Automation** | Manages the hazard's vertical position over time with configurable rise speed, applies damage on contact (lava = instant, water = drowning timer, poison = gradual damage), renders rising VFX (bubbles, steam, glow), handles platform reactivity (lava melts ice platforms, water makes wood float), and manages drain trigger responses. |
| **JSON Contract Extension** | `risingHazards: { type, riseSpeed, maxHeight, currentHeight, damageOnContact, drainTriggers[], visualFx }` |

### Gravity Flip Zones

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Celeste / VVVVVV / Castlevania |
| **Description** | Special zones where gravity inverts — the ceiling becomes the floor and vice versa. Characters walk on ceilings, jump downward, and all physics objects fall upward. Gravity zones can be toggled by switches, triggered on entry, or always active within their boundaries. They create mind-bending level designs that challenge spatial intuition. |
| **Kid UX** | The child stamps a **Gravity Zone** over an area (shown as a purple-tinted overlay with floating sparkles). A toggle sets the gravity direction: "Normal" (down), "Flipped" (up), or "Toggle on Entry." When the hero enters a flip zone, the camera smoothly rotates 180 degrees, the character falls to the ceiling, and controls remap naturally. The transition includes a brief "float" moment where gravity is zero, creating a magical sensation. |
| **LLM Automation** | Detects player entry/exit from gravity zones, applies smooth gravity direction transitions with zero-G float period, remaps input controls for inverted gravity (left/right relative to current floor), handles all physics bodies within the zone, manages camera rotation with smooth interpolation, and ensures entities don't get stuck at zone boundaries. |
| **JSON Contract Extension** | `gravityZones: { bounds, gravityDirection, transitionType, cameraRotation, floatDuration }` |

---

## 5.6 Interior Design & Room Systems

Not all adventure happens outdoors. These features let children design enclosed spaces — houses, castles, shops, dungeons — with intelligent room recognition that rewards thoughtful furniture placement.

### Room/Interior Designer

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Animal Crossing: Happy Home Paradise |
| **Description** | A dedicated interior editing mode for enclosed spaces. When the player stamps a building on the world map and taps "Go Inside," the view switches to an interior perspective. The child can place wallpaper, flooring, lighting, and furniture with the same stamp-based ease as exterior terrain. Multi-room buildings are supported with door connections between rooms. |
| **Kid UX** | The child stamps a **House**, **Castle**, or **Cave** building on the world map. Tapping "Enter" switches the canvas to interior view — an empty room with walls and floor. Wallpaper and flooring are selected from visual swatch grids (tap a pattern to apply). A furniture palette appears with categories: chairs, tables, beds, lights, decorations. Drag-and-drop furniture placement with automatic grid snap. Tapping a placed furniture item rotates it. A "Lighting" slider changes room brightness from dim candlelight to bright sunshine. |
| **LLM Automation** | Switches camera to interior orthographic or perspective view, manages room dimensions and wall/floor rendering with proper depth sorting, handles interior lighting with dynamic shadows, validates furniture placement within room bounds (no clipping through walls), manages multi-room building topology, and generates appropriate exterior building visuals from the interior layout. |
| **JSON Contract Extension** | `interiorDesign: { roomDimensions, wallpaper, flooring, furniture[], lighting, connectedRooms[], exteriorVisual }` |

### Smart Room Recognition

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dragon Quest Builders 1 & 2 |
| **Description** | An intelligent system that auto-detects functional rooms based on furniture combinations within enclosed spaces. When specific item sets are placed inside a walled area, the room is recognized and gains special properties — a **Bedroom** (bed + lamp) slowly heals occupants, a **Kitchen** (table + cooking pot) auto-creates food items, a **Smithy** (anvil + barrel) enables weapon upgrades, and a **Shop** (sign + table + price tag) spawns an NPC shopkeeper. |
| **Kid UX** | The child stamps wall segments to create enclosed rooms, then places furniture stamps inside. When a valid room combination is detected, magical sparkle effects play and the room type appears as floating text: "Bedroom!" or "Kitchen!" A **Room Recipe Book** stamp shows pictorial recipes — Bed + Lamp = Bedroom, Table + Pot = Kitchen. The child can check partially completed rooms to see which items are missing (shown as grayed-out icons). When a room is recognized, it glows softly with a colored aura matching its function (pink for bedroom, orange for kitchen, gray for smithy, gold for shop). |
| **LLM Automation** | Detects enclosed areas using wall segment analysis, checks placed item combinations against the room recipe database, triggers room recognition events (name popup, soft glow effect, ambient particle color), implements room passive effects (health regen in bedroom, auto-cooking timer in kitchen), tracks room boundaries for effect application, and auto-suggests missing items when a partial room is detected. |
| **JSON Contract Extension** | `roomRecognition: { recipes[], detectionMethod, recognitionFx, roomGlow, passiveEffects }` |

### Furniture Placement Grid

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Animal Crossing: New Horizons |
| **Description** | A snap-to-grid decoration system for placing objects in both interior rooms and exterior spaces. Objects snap to a half-tile grid for precise positioning, support free rotation, and include collision detection so they cannot overlap. Objects auto-sort by depth layer for proper 2.5D visual rendering. |
| **Kid UX** | The child selects an object from the **Decorations** palette (tables, chairs, plants, lights, rugs, wall hangings). A ghost preview appears under the cursor, snapping to the grid as the child moves it. Tapping places the object. A rotation handle appears — dragging it spins the object in 45-degree increments. Objects can't be placed on top of each other (the ghost turns red when overlapping). Wall-mounted items (shelves, paintings) auto-snap to wall surfaces. The grid can be toggled visible/hidden. |
| **LLM Automation** | Manages object placement grid with collision detection, handles z-layering and depth sorting for proper rendering (objects in front obscure objects behind), validates placement constraints (tables must be on floor, paintings on walls, chandeliers on ceilings), manages object persistence across saves, and generates appropriate shadow effects beneath placed objects. |
| **JSON Contract Extension** | `furnitureGrid: { objects[], position, rotation, layer, collisionBox, snapToGrid, constraints }` |

### Custom Pattern Designer

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Animal Crossing: New Horizons |
| **Description** | A pixel-art style pattern editor where children design custom textures for clothing, floors, walls, and flags. Patterns are applied to objects in the world as decals or full textures, allowing complete personalization of the game world's visual identity. |
| **Kid UX** | The child opens the **Pattern Studio** from the tools menu. A pixel grid appears (16x16 or 32x32, selectable). A color palette of 16-32 colors lines the side. The child taps a color, then taps grid cells to fill them. Tools include: Pen (single pixel), Line (drag to draw), Rectangle (drag to fill), Circle, and Fill-Bucket (flood fill). A real-time preview shows the pattern applied to a sample object (shirt, floor tile, or flag). Patterns can be named, saved to a personal gallery, and applied to any compatible stamp by dragging the pattern onto it. |
| **LLM Automation** | Stores patterns as 2D color arrays, generates texture assets from pattern data at appropriate resolutions, applies patterns to 3D objects as decals or textures with proper UV mapping, manages pattern gallery (save, load, rename, delete), handles pattern sharing between players, and auto-generates pattern thumbnails. |
| **JSON Contract Extension** | `customPatterns: [{ id, name, gridSize, pixelData[][], palette[], appliedTo[], thumbnail }]` |

### Safe Room System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Resident Evil series / Castlevania |
| **Description** | Designated safe zones where enemies cannot enter, players can save progress, heal over time, and manage inventory. Safe rooms have distinctive visual themes — calming music, warm lighting, and comforting decorations. They serve as emotional relief valves in intense levels. |
| **Kid UX** | The child stamps a **Safe Room Zone** over an area (boundary glows soft blue). Inside, they place a **Save Crystal** (glowing blue orb), an **Item Box** (shared storage accessible from any safe room), and optionally a **Healing Statue** (slowly regenerates HP when nearby). Enemies that touch the safe room boundary bounce away with a gentle shimmer effect. The background music softens to a gentle ambient melody. A warm lantern glow auto-generates around save crystals. |
| **LLM Automation** | Creates an invisible collision boundary that repels enemy AI, auto-switches background music and ambience when the player enters, enables save functionality at save crystals, manages the item box as shared inventory accessible from any safe room, applies gradual healing when near healing statues, and resets all status ailments on entry. |
| **JSON Contract Extension** | `safeRooms: [{ zone, saveCrystal, itemBox, healingStatue, enemyBlocking, musicTheme, healOverTime }]` |

---

## 5.7 Ink Painting Terrain & Special Environment Systems

Beyond traditional terrain, these features create transformative environmental mechanics that redefine how the player interacts with the world itself.

### Ink Painting Terrain (Splatoon System)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Splatoon 1, 2, 3 |
| **Description** | The player shoots colored ink onto terrain, covering it in their team's color. Inked terrain provides movement bonuses (swimming quickly through own ink), reloads the ink tank, and enables stealth (hiding in ink makes the player invisible to enemies). Enemy ink slows movement and deals damage. The ink coverage system turns every level into a dynamic, changing canvas. |
| **Kid UX** | The player character equips a **Paint Weapon** (stamp-selectable from shooter, roller, brush, and charger types). Tapping/holding the action button shoots paint blobs that splatter on terrain, changing its color to match the player's team. A "Swim" button transforms the character into a squid form that moves quickly through their own ink and can hide completely. The ink tank (shown as a colorful bar) depletes with shots and refills while swimming in own ink. The child can toggle "Turf War Mode" which scores based on paint coverage percentage. |
| **LLM Automation** | Manages ink coverage as a 2D texture overlay per team, calculates ink percentage per grid cell for scoring, handles swim-form collision and movement speed modifications, manages ink tank depletion and refill rates, processes ink-on-ink interactions (friendly ink = swimmable, enemy ink = damaging), and generates the dramatic Turf War reveal sequence at match end (screen fills with each team's color expanding from painted areas). |
| **JSON Contract Extension** | `inkSystem: { teamColors, inkCoverage[][], inkTank, swimForm, enemyInkDamage, turfWarScoring }` |

### Splatoon Weapon Types for Terrain Painting

| Weapon Type | Behavior | Kid-Friendly Name | Ink Pattern |
|-------------|----------|-------------------|-------------|
| Shooter | Rapid fire, medium range | "Squirt Gun" | Circular splatters |
| Roller | Wide path while moving, close range | "Paint Roller" | Wide trail behind player |
| Charger | Hold to charge, long-range line | "Power Blaster" | Long line of ink |
| Brush | Fast sweep, mobile | "Paint Brush" | Wide arc in facing direction |
| Slosher | Lobs ink over walls | "Bucket Toss" | Parabolic arc splash |

### Turf War Mode (Paint Coverage Scoring)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Splatoon series |
| **Description** | A game mode where teams compete to cover the most terrain with their ink. At match end, a dramatic reveal sequence fills the screen with each team's color expanding from their painted areas, culminating in a percentage score. The mode transforms level design into a strategic painting contest. |
| **Kid UX** | The child enables **Turf War Mode** from the level settings. A timer counts down from 3 minutes. The real-time score bar shows approximate coverage. At match end, the dramatic reveal plays — the screen starts blank and fills with each team's color expanding outward from their painted areas. Percentage scores display with fanfare. The child can place "Ink Refill" stations and "Super Jump" pads (instant travel to teammate locations) as strategic stamps. |
| **LLM Automation** | Calculates ink coverage percentage per team each frame, manages match timer, generates the dramatic reveal sequence (gradual fill animation originating from paint edges), determines winner by coverage percentage, and places ink-refill and super-jump stamp options in the editor palette when Turf War Mode is enabled. |
| **JSON Contract Extension** | `turfWar: { duration, teamCoverage, revealAnimation, powerUps[] }` |

### Celestial Brush Drawing (Okami Miracles)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Okami |
| **Description** | A drawing system where the player pauses time and draws simple strokes on the screen to perform miracles. Straight lines slash through enemies and objects, circles revive dead plants and create bloom effects, filled circles spawn explosive cherry bombs, spirals create wind, and horizontal lines slow time. The Celestial Brush turns the screen itself into an interactive canvas. |
| **Kid UX** | The child stamps a **Brush Goddess** item in the level. During play, holding the "Brush" button freezes time and turns the screen into a parchment texture. The child draws strokes with their finger: straight line = slash attack, circle = revive plants and bloom flowers, filled circle = bomb, spiral = wind, horizontal line = slow time. Each stroke triggers its miracle with spectacular ink-wash animation. An **Ink Meter** (shown as a paint bottle) depletes with each stroke and refills over time. The child can stamp "Brush Technique Scrolls" to unlock new miracles. |
| **LLM Automation** | Implements stroke recognition (straight line vs. circle vs. spiral vs. horizontal line), detects what the stroke intersects with (enemies, broken objects, water sources, plants), executes the corresponding miracle effect with appropriate particles and damage calculations, manages ink meter consumption and regeneration, and tracks which brush techniques have been unlocked. |
| **JSON Contract Extension** | `brushTechniques: [{ id, stroke, cost, effect, damage, unlockScroll }], inkMeter: { max, current, regenRate }` |

### Constellation Unlocking

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Okami |
| **Description** | Scattered throughout the world are constellation patterns made of glowing star dots. Drawing lines to connect the stars in the correct order summons a celestial spirit that teaches a new brush technique or restores a major ability. Each constellation has a unique creature associated with it. |
| **Kid UX** | The child stamps a **Star Pattern** on the background of their level. Glowing star dots appear in a recognizable shape. The child draws lines connecting the stars; the system auto-snaps drawn lines to the nearest star. When all stars are connected in a valid pattern, a majestic celestial creature materializes with an ink-wash animation and grants a reward — a new brush technique, a permanent stat upgrade, or a special item. Each constellation creature is unique (dragon, phoenix, rabbit, dragonfly). |
| **LLM Automation** | Validates constellation line connections (auto-snaps to nearest star within radius), detects completion (all stars connected in valid pattern), triggers the summon animation and creature appearance, unlocks the associated reward, tracks completed constellations, and generates appropriate celestial creature visuals per constellation. |
| **JSON Contract Extension** | `constellations: [{ id, starPositions[], reward, creature, completed }]` |

---

## 5.8 Environment Comparison Summary

The following table summarizes the key environmental features and their source inspirations for quick reference:

| Feature Category | Key Source Games | Feature Count | Core Kid Interaction |
|-----------------|-----------------|---------------|---------------------|
| Terrain Sculpting | Animal Crossing, DQ Builders | 6 | Stamp terrain, drag to sculpt |
| Pathways & Transport | Mario Maker, Sonic, Secret of Mana | 6 | Draw paths, stamp entry/exit markers |
| Elemental Chemistry | Zelda BotW/TotK | 3 | Place element stamps, watch reactions |
| Zonai Gadgets | Zelda TotK | 3 | Stamp devices, drag to combine |
| Environmental Conditions | Zelda, AC, Celeste | 6 | Tap weather/time controllers |
| Interior Design | AC Happy Home, DQ Builders | 5 | Enter buildings, place furniture |
| Ink & Brush Systems | Splatoon, Okami | 4 | Shoot paint, draw brush strokes |
| **TOTAL** | | **~38 features** | |

The world building features in this chapter represent the largest and most visually dramatic category in KidGameMaker. A child who masters terrain sculpting, understands the elemental chemistry engine, and experiments with Zonai contraptions can create worlds that feel alive — worlds that react, transform, and surprise. The LLM's role is to ensure that every experiment produces satisfying results, that physics always behave intuitively, and that the emergent combinations (fan + balloon + basket = hot air balloon) work exactly as a child would expect. The world is the teacher, and every interaction is a lesson in cause and effect.


---

# 6. Items, Crafting & Economy

Every adventure needs treasures to find, materials to gather, recipes to discover, and rewards to spend. This chapter covers the complete item ecosystem of KidGameMaker — from the coins that spill from defeated enemies to the complex crafting systems that turn raw materials into powerful gear. Drawing from the loot-driven satisfaction of Monster Hunter, the methodical inventory management of Resident Evil, the Praise-gathering restoration of Okami, and the discovery-driven cooking of Zelda, these systems transform collection into a core pillar of the play experience. Every feature is designed so that a 5-year-old can engage through stamps, taps, and drag gestures while the LLM handles all numeric balancing, recipe validation, and inventory state management invisibly.

---

## 6.1 Currency & Collection Systems

Currency is the language of reward. These features establish multiple collectible resource types that motivate exploration, mark progression, and feed into crafting and shop economies.

### Multi-Type Currency System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Mario (Coins), Sonic (Rings), Zelda (Rupees), Dark Souls (Souls) |
| **Description** | A flexible currency system supporting multiple coin types with different visual identities and value tiers. Copper coins are common (1 unit), silver coins are uncommon (5 units), gold coins are rare (10 units), and special star pieces or gems function as premium collectibles. Currency is dropped by enemies, found in breakable objects, hidden in secret areas, and awarded for quest completion. |
| **Kid UX** | The child stamps **Coin** and **Gem** items throughout their level. A tap on a coin stamp cycles through visual variants: copper penny, silver coin, gold coin, red ruby, blue sapphire, green emerald, purple amethyst. Each has a distinctive sparkle effect. During play, coins bounce when dropped and home toward the player when approached. The HUD shows a large coin icon with the total count in big, friendly numbers. Currency is collected automatically on proximity — no need to press a button. |
| **LLM Automation** | Manages currency inventory per player with support for multiple currency types, handles drop physics (bounce on spawn, magnetic homing when player is near), calculates currency values from defeated enemies and destroyed objects, manages HUD display with large readable numbers, and auto-balances currency distribution throughout the level so the player always feels rewarded but never overwhelmed. |
| **JSON Contract Extension** | `currency: { types: { copper: 1, silver: 5, gold: 10, ruby: 50, sapphire: 50, emerald: 50 }, currentTotals{}, dropSources[], magneticRadius }` |

### Currency Loss on Death (Recovery Run)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dark Souls (Bloodstains), Hollow Knight (Shade), Shovel Knight |
| **Description** | When the player is defeated, all collected currency is dropped at the death location as a glowing orb. The player respawns at the last checkpoint and must return to the death location to reclaim their lost wealth. Dying again before reclaiming the first orb permanently loses the first drop. This creates palpable tension and a "one more try" motivation loop. |
| **Kid UX** | When the hero falls, a large **"Ghost Me"** (a cute translucent ghost version of the hero) appears at the death spot, holding all the lost coins. The hero respawns at the last campfire. The ghost waves cheerfully and hops to guide the player back. A pulsing arrow at the screen edge points toward the ghost's location. Touching the ghost causes it to merge back into the hero with a happy sparkle and coin-restored chime. If the hero falls before reaching the ghost, the ghost disappears with a sad but gentle poof — no harsh penalty message, just an opportunity to find more coins. |
| **LLM Automation** | Tracks per-session currency total, spawns the ghost entity at death coordinates carrying the dropped amount, handles collision detection for reclamation, manages the "one chance" rule (first ghost disappears if the player dies again), ensures the ghost never spawns in an impossible-to-reach location, auto-adjusts drop amounts based on level design, and fades out permanently lost currency with a gentle effect rather than a punishing message. |
| **JSON Contract Extension** | `deathRecovery: { ghostEntity, carriesCurrency, currencyAmount, position, state, retrievalTrigger, directionIndicator }` |

### Link Chain Score Multiplier

| Attribute | Detail |
|-----------|--------|
| **Source Game** | NiGHTS into Dreams |
| **Description** | When the player collects items (coins, rings, gems) in rapid succession, a "Link Chain" counter builds up. The higher the chain, the bigger the score multiplier that applies to all subsequent collections. A glowing trail connects recently collected items. If too much time passes between collections, the chain breaks and the accumulated bonus points are cashed out in a celebratory burst. This creates rhythmic, risk-reward tension around collection patterns. |
| **Kid UX** | The child enables **Link Chains** with a single toggle in level settings. During play, collected items connect with a sparkly trail that grows brighter as the chain increases. A big number shows the current chain count: "Chain: 5!" When the chain breaks, a celebratory **"BONUS!"** popup displays the multiplied score with confetti. The child can stamp **"Chain Item"** clusters in curved paths to create natural chain routes through their level, encouraging the player to collect quickly. |
| **LLM Automation** | Implements the chain timer (decays over ~2 seconds without a new collection), tracks the chain counter, computes the multiplier formula (1.5x at 5 chain, 2x at 10, 3x at 20, 5x at 50), draws the visual connecting trail between collected items, handles the chain break event with bonus calculation and popup celebration, and auto-suggests optimal item cluster placements for chain routes during level design. |
| **JSON Contract Extension** | `linkChain: { enabled, chainDecaySeconds, multiplierTiers[], visualTrail, breakFx }` |

### Praise / Power-Up Orb Collection

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Okami |
| **Description** | Restoring nature and helping the world earns Praise — golden orbs that magnetize toward the player with a satisfying chime. Blooming wilted flowers, feeding animals, reviving dead trees, and clearing cursed zones all generate Praise. Collecting enough Praise allows the player to upgrade their attributes: more health, more ink for brush techniques, larger inventory, or stronger attacks. |
| **Kid UX** | The child stamps **"Wilted Flower"** clusters, **"Hungry Animal"** sprites, and **"Dead Tree"** objects throughout their level. When the player uses the Bloom brush technique on a wilted flower, it bursts open and golden Praise orbs float out, magnetizing toward the player with a bright chime. Feeding an animal generates a heart burst and Praise orbs. Collecting enough orbs triggers a **"LEVEL UP!"** banner. A simple upgrade screen shows four big icons: Heart (more health), Ink Bottle (more brush uses), Bag (more inventory), Star (stronger attack). The child (as player) taps one to upgrade. |
| **LLM Automation** | Tracks Praise total across the save file, manages upgrade thresholds (each upgrade costs progressively more), applies attribute increases on upgrade selection, spawns Praise orbs from restoration events (bloom, feed, revive), handles orb magnetization physics, generates the upgrade UI with clear iconography, and ensures Praise income scales appropriately with level design. |
| **JSON Contract Extension** | `praiseSystem: { currentPraise, upgradeCosts{ health, ink, purse, attack }, praiseSources{ bloomFlower, feedAnimal, reviveTree } }` |

### Seven Emeralds / Star Piece Transformation

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Sonic the Hedgehog 3 & Knuckles |
| **Description** | Seven special gems are hidden throughout the level. Collecting all seven transforms the player character into a glowing, invincible super form with enhanced speed, a sparkly aura trail, and the ability to destroy any enemy on contact. The super form lasts for a timed duration with a visible energy meter that drains gradually. Hidden emerald locations can be placed via stamp anywhere in the level. |
| **Kid UX** | The child stamps the **7 Emerald** stamps in hidden locations (inside question blocks, behind secret walls, at the end of difficult platforming challenges). During play, collecting an emerald plays a distinctive chime and the emerald takes its place in a HUD circle — an empty slot fills with color. Collecting all seven triggers a spectacular transformation sequence: the character glows golden, a sparkly aura trail follows every movement, the music shifts to an epic theme, and enemies are destroyed simply by touching them. A rainbow energy meter drains slowly; when empty, the character returns to normal with a gentle fade. |
| **LLM Automation** | Tracks emerald collection state across all seven positions, triggers the transformation sequence when the seventh is collected (invincibility, aura particles, speed boost, music change), implements the countdown timer with visual energy meter, handles super-jump and enemy-destruction-on-contact logic, restores normal form when time expires, and ensures emeralds are placed in locations that are challenging but reachable. |
| **JSON Contract Extension** | `collectibles: { emeraldSet: { count: 7, transformTo, duration, effects, drainRate } }` |

---

## 6.2 Crafting & Recipe Discovery

Discovery is the soul of crafting. These features let children combine materials into new items, with the joy of experimentation rewarded by surprising outcomes.

### Crafting Recipe Discovery

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dragon Quest Builders 1 & 2 / Monster Hunter |
| **Description** | The player collects raw material items throughout levels (wood, stone, mushroom, crystal, iron, herb). At **Crafting Stations**, they can combine two or three materials to create new items. The first time a valid combination is tried, the recipe is "discovered" and permanently added to their **Recipe Book**. Discovery is half the fun — experimenting with combinations yields surprises. Invalid combinations produce a playful "Poof!" dust cloud with no penalty. |
| **Kid UX** | The child stamps **Material Nodes** throughout their level: tree stamps yield wood, rock stamps yield stone, glowing crystal stamps yield crystal shards, mushroom stamps yield mushrooms. They also stamp **Crafting Station** objects (workbenches, anvils, cauldrons). During play, materials are collected automatically on touch. At a crafting station, the player sees their collected materials as large, draggable stickers. They drag 2-3 materials into the crafting slots. Valid combinations produce a new item with a fanfare sparkle. Invalid combinations show a cute "Poof!" puff of dust and a gentle giggle sound. No materials are lost on failure. The **Recipe Book** auto-populates with discovered combinations shown as ingredient pictures + arrow + result picture. |
| **LLM Automation** | Manages the recipe database (hundreds of valid combinations), validates player crafting attempts against known recipes, generates discovered items with appropriate properties, unlocks recipes in the Recipe Book UI with ingredient pictograms, implements the "Poof!" failure feedback with no material loss, auto-suggests hint recipes based on materials available in the current level, and scales crafted item power relative to level difficulty. |
| **JSON Contract Extension** | `craftingSystem: { materials[], stationType, discoveryMode, recipeBook, invalidFeedback, maxIngredients, hintSystem }` |

### Crafting Recipe Examples

The following table illustrates sample recipes that children discover through experimentation:

| Ingredient A | + | Ingredient B | (+ | Ingredient C) | = | Result | Effect |
|-------------|---|-------------|---|-----------------|---|--------|--------|
| Wood | + | Wood | | | = | Wooden Plank | Building material |
| Wood | + | Stone | | | = | Stone Axe | Weapon (+2 damage) |
| Stone | + | Crystal | | | = | Magic Gem | Socket gem (elemental power) |
| Mushroom | + | Herb | | | = | Healing Potion | Restores 3 hearts |
| Herb | + | Herb | + | Flower | = | Super Potion | Restores all hearts |
| Iron | + | Wood | | | = | Iron Sword | Weapon (+5 damage) |
| Iron | + | Crystal | + | Magic Gem | = | Enchanted Sword | Weapon (+8 damage, elemental) |
| Feather | + | Wood | | | = | Arrow | Ammunition for bow |
| String | + | Stick | | | = | Fishing Rod | Enables fishing minigame |

### Monster Part Breaking & Collection

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Monster Hunter series |
| **Description** | Large enemies and bosses have breakable body parts — head, wings, tail, claws. Dealing enough concentrated damage to a specific part causes it to break, changing the monster's behavior and adding extra reward materials to the collection pool. Severed tails become interactable objects on the ground that can be carved for unique materials. |
| **Kid UX** | The child stamps a **Big Monster** on the canvas. Tapping the monster shows dotted outlines around breakable parts: head, wings, tail, each with a small colored HP bar. During play, hitting a specific part depletes its individual HP bar. When a part's bar empties, a dramatic break animation plays — the tail falls off with a satisfying crack, horn chips fly, wing membrane tears. Broken parts change the monster's attack patterns (no tail = no tail whip attack). The severed tail lies on the ground as a glowing, carveable object that yields unique "Tail Material" for crafting. |
| **LLM Automation** | Tracks per-part damage thresholds independently from overall monster HP, triggers break animations and visual effects at thresholds, modifies monster moveset when parts break (e.g., broken tail disables tail swipe attack), spawns severed parts as carveable objects on the ground, adds part-break materials to the reward pool, and generates appropriate hit effects when specific parts are targeted. |
| **JSON Contract Extension** | `monsterParts: [{ id, breakThreshold, severable, behaviorChange }], partBreakRewards: { tail: [materials], head: [materials], wings: [materials] }` |

### Synthesis Workshop (Advanced Crafting)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Kingdom Hearts series |
| **Description** | A dedicated crafting station for combining collected materials into powerful equipment and special items. The synthesis list shows possible combinations with question marks for undiscovered recipes. Successfully synthesizing an item plays a brief "crafting" animation with hammer strikes and sparkles. Synthesized items grant permanent upgrades — better swords, faster boots, bigger health bars. |
| **Kid UX** | The child stamps a **Workshop** station (anvil with tools and a glowing book). During play, the player opens the workshop to see a **Recipe Book** with known recipes and **"???"** slots for unknown ones. Tapping a recipe shows required materials as picture icons. If materials are available, a **"Make It!"** button glows green. Tapping it plays a fun hammering animation (2-3 strikes with sparkles) and the new item pops out. The child can stamp **Material Chests** throughout their level containing metal scraps, glowing dust, monster drops, and rare gems. |
| **LLM Automation** | Manages the recipe database (known and unknown), validates material availability for selected recipes, generates the crafting animation sequence, applies equipment upgrades to the player character (stat changes, visual changes to character sprite), tracks discovered vs. undiscovered recipes, suggests recipes based on current materials, and scales recipe outcomes to level progression. |
| **JSON Contract Extension** | `synthesisWorkshop: { materials[], recipeBook, craftingAnimation, upgrades[], discoveryMode, suggestionSystem }` |

### NPC Town Builder Requests

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dragon Quest Builders 1 & 2 |
| **Description** | Friendly NPCs placed in the level display "Wish Bubbles" showing what they want the player to build. A knight wants an "Armory Room" (chest + weapons), a chef wants a "Kitchen" (pot + table), a farmer wants a "Farm" (dirt + seeds). Completing their request makes them happy, causes them to move into the room, and grants a unique reward. |
| **Kid UX** | The child stamps **NPC** characters and taps each to pick a type: knight, chef, farmer, shopkeeper. Each NPC shows a thought bubble with a simple picture of what they want (a sword icon for the knight, a pot icon for the chef). The child builds rooms using the Smart Room Recognition system. When the room matches the NPC's wish, the bubble turns into floating hearts, the NPC walks to their new room, and a **gift box** appears as a reward. The NPC then performs appropriate idle animations in their room (the chef stirs a pot, the knight polishes a sword). |
| **LLM Automation** | Matches built rooms to NPC wishes by validating room type against request requirements, triggers the wish-completion event (heart particles, NPC pathing to room, gift spawn), generates appropriate rewards per NPC type (knight = weapon upgrade, chef = cooking recipe, farmer = crop seeds), manages NPC daily routines (sleep at night, work in their room during day), and creates new requests as previous ones are fulfilled to create a progression chain. |
| **JSON Contract Extension** | `npcRequests: { npcTypes[], wishFormat, roomMatch, rewards{}, requestChain }` |

---

## 6.3 Cooking & Food Systems

Food is joy. These features transform ingredient gathering into a delightful culinary minigame where timing, combination, and creativity produce dishes with magical effects.

### Cooking Pot / BBQ Mini-Game

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Monster Hunter series / Dragon Quest Builders |
| **Description** | A timing-based cooking minigame where the player cooks raw ingredients on a spit or in a pot. Timing determines quality: undercooked gives less effect, perfectly cooked gives maximum benefit, and burnt gives nothing. The classic "So Tasty!" celebration plays on a perfect cook. Different food types (meat, fish, vegetables) produce different stat-boosting dishes. |
| **Kid UX** | The child stamps a **BBQ Spit** or **Cooking Pot** in their level. The player drags up to 3 food ingredients (meat, fish, mushrooms, herbs, berries) into the cooking slots. A cooking mini-game starts: meat rotates on a spit while a color meter fills from blue (raw) through yellow (perfect) to red (burnt). The player taps when the color is in the golden zone. **"So Tasty!"** confetti bursts on perfect timing. Different food combinations produce different dishes shown as cute food art: Meat + Herb = "Healing Steak" (restores HP), Fish + Mushroom = "Smart Soup" (boosts magic), Berry + Berry = "Sweet Tart" (boosts speed). |
| **LLM Automation** | Manages the timing window calculation (perfect zone occupies the middle 30% of the cook duration, good zone the middle 60%, raw and burnt occupy the outer 20% each), plays appropriate result animations, applies the corresponding buff to the player based on food type and cook quality, manages ingredient consumption, tracks discovered food recipes, and generates the "So Tasty!" confetti burst on perfect cooks. |
| **JSON Contract Extension** | `cooking: { timingZones{ undercooked, perfect, burnt }, recipes[], animationTriggers, buffEffects }` |

### Portable Cooking (Ingredient Mixing)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Zelda: Tears of the Kingdom |
| **Description** | A placeable cooking device where the player combines ingredients to create dishes with various buff effects — health restoration, temporary attack boost, speed increase, cold resistance, or stealth enhancement. The output dish is determined by ingredient attributes, not rigid recipes, enabling creative experimentation. |
| **Kid UX** | The child stamps a **Cooking Pot** object. During play, the player approaches it and a "Cook!" button appears. Up to 5 ingredients are selected from the ingredient palette by tapping. A brief stirring animation plays (2 seconds) with rising steam particles colored by the ingredients. Then a dish pops out as a floating item with sparkles. A **Food Journal** auto-records every dish created with its ingredient list and effect, shown as cute food illustrations. The child can stamp **Ingredient Plants** and **Meat Sources** throughout the level. |
| **LLM Automation** | Implements the ingredient attribute database (each ingredient has health, stamina, attack, defense, speed, stealth, and resistance values), calculates output dish properties from the sum and interaction of ingredient attributes, manages the cooking animation state, handles ingredient consumption, auto-balances healing values against level damage patterns, and populates the Food Journal with discovered dishes. |
| **JSON Contract Extension** | `cooking: { potPosition, recipes{ ingredients[], output, hearts, buffType, buffDuration }, foodJournal[] }` |

### Cooking Dish Effect Types

| Dish Effect | Visual Icon | Ingredient Source | Duration |
|-------------|-------------|-------------------|----------|
| Heal Hearts | Red heart | Meats, mushrooms, herbs | Instant |
| Attack Boost | Orange sword | Spicy peppers, meat | 30 seconds |
| Defense Boost | Blue shield | Tough vegetables, shellfish | 30 seconds |
| Speed Boost | Green boot | Swift herbs, caffeine plants | 20 seconds |
| Cold Resistance | White snowflake | Warm spices, fatty meats | 60 seconds |
| Stealth Boost | Purple eye | Silent herbs, ghost mushrooms | 30 seconds |

---

## 6.4 Consumables & Healing

Health management creates meaningful decisions. These features provide various healing and restoration mechanics that balance scarcity, convenience, and strategic depth for young players.

### Flask Healing System (Limited Restores)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dark Souls (Estus Flask) / Elden Ring (Flask of Crimson Tears) |
| **Description** | A healing item with a fixed number of uses per rest. Drinking the flask restores a portion of HP but consumes one charge. Charges are only replenished by resting at a checkpoint. This creates gentle strategic tension around when to heal without being punishing for children. |
| **Kid UX** | The child stamps a **Potion Bottle** on the hero or enables it globally. A simple number picker sets charges from 1-5 (default 3). During play, a **"Drink"** button appears in the corner with a bottle icon and charge count (e.g., "3/3"). Single-tap to drink. A glug-glug drinking animation plays with rising green sparkle numbers showing HP restored. The bottle icon shows a red X when empty. Charges refill automatically when touching a checkpoint. The child can stamp **Potion Refill** pickups that add one charge when collected. |
| **LLM Automation** | Tracks charges per rest cycle, handles heal amount calculation (auto-balanced to restore approximately 50% of max HP per use), prevents overhealing beyond max HP, plays drink animation and heal VFX with floating +HP numbers, replenishes charges on checkpoint touch, auto-balances heal amount based on total player HP and level difficulty, and manages the empty/full visual state of the flask UI. |
| **JSON Contract Extension** | `healingFlask: { maxCharges, currentCharges, healAmount, healType, replenishOn, useAnimation, cooldown }` |

### Custom Mix Buff Flask

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Elden Ring (Flask of Wondrous Physick) |
| **Description** | A special flask where the player combines two found "crystal tear" items before resting. Each tear provides a distinct timed buff — increased damage, faster movement, HP regeneration, damage negation, etc. Mixing two different tears creates a hybrid buff cocktail. The effect lasts for a fixed duration after consumption. |
| **Kid UX** | The child stamps a **Mixing Bottle** and **Crystal Tear** pickups throughout their level. Crystal tears are color-coded: red tear = power up, blue tear = speed up, green tear = heal over time, yellow tear = shield. At the mixing bottle, the player drags two tears into the slots. The mixed bottle glows with both colors. During play, tapping the bottle drinks the mix — the hero glows with swirling dual colors. A shrinking colored ring around the player shows remaining buff time. When the ring disappears, the buff fades with a gentle chime. |
| **LLM Automation** | Manages discovered tear inventory, calculates combined buff effects based on tear compatibility (additive for same-type, multiplicative for different-type), applies timed status effects on consumption, stacks visual aura per buff type, auto-balances buff magnitudes for kid-friendly gameplay, and displays remaining buff time as a shrinking colored ring around the player sprite. |
| **JSON Contract Extension** | `customMixFlask: { slotCount: 2, currentMix[{ tearId, effect, duration }], duration, cooldown, visualAura, timeRemainingRing }` |

### Herb Combining System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Resident Evil series |
| **Description** | Three herb colors create different healing effects through simple combination: Green Herb heals, Green + Green = full heal, Green + Red = full heal + max HP boost, Green + Blue = heal + poison cure, and the legendary Green + Red + Blue = full heal + max boost + poison cure + damage reduction. The color-coded system is intuitive and the combinations feel like magical alchemy. |
| **Kid UX** | The child stamps **Herb** items: green leaf, red flower, blue berry. In the inventory screen, dragging one herb onto another triggers a combination animation — colored sparkles mix together and a new item appears with a distinct icon. G+G = "Big Green Herb" (big heal). G+R = "Rainbow Herb" (super heal + max HP boost). G+B = "Cleanse Herb" (heal + cure poison). G+R+B = "Ultimate Herb" (all effects + temporary defense boost). The result icons use clear color combinations so the child can deduce recipes through experimentation. |
| **LLM Automation** | Maintains the herb combination recipe table, validates drag-to-combine interactions, plays the combination sparkle animation, applies correct healing values and status effects when the combined herb is used, updates inventory (removes ingredients, adds result), and tracks discovered herb combinations in the Recipe Book. |
| **JSON Contract Extension** | `herbRecipes: [{ ingredients[], result, heal, cures[], maxHpBoost, defenseUp }]` |

### Rally Health Regain (Aggressive Healing)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Bloodborne |
| **Description** | When the player takes damage, a portion of lost HP becomes "faded" (shown in orange on the health bar) instead of being permanently lost. Dealing damage to enemies within a short window recovers the faded HP. This encourages aggressive play — taking a hit then fighting back to heal. |
| **Kid UX** | When the hero is hit, lost HP shows as **orange chunks** on the health bar instead of disappearing entirely. A small clock icon appears next to the bar. Hitting enemies fills the orange chunks back to red with each successful attack. The orange chunks gradually fade to black if the player doesn't attack within ~4 seconds. No stamps needed — it's an automatic game mechanic that rewards brave play. The child can stamp a **"Rally Badge"** to enable or disable the system per level. |
| **LLM Automation** | Splits damage into "permanent loss" and "faded/rallyable" portions (50/50 split for kid-friendliness), displays faded HP in distinct orange color, starts the rally timer on damage taken, calculates HP recovery per damage dealt to enemies (e.g., 30% of damage dealt = HP recovered), gradually fades rallyable HP to permanent loss if the timer expires, and shows rally recovery amount as floating green text on each successful hit. |
| **JSON Contract Extension** | `rallySystem: { enabled, rallyPercent, rallyWindowSeconds, fadeColor, permanentColor, timerVisual }` |

---

## 6.5 Equipment & Upgrades

Progression feels tangible when it changes how the player looks and fights. These features create visible, meaningful equipment systems that reward effort with power.

### Equipment Slot System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Castlevania: Symphony of the Night |
| **Description** | A five-slot equipment system: Right Hand (weapon), Left Hand (shield or second weapon), Head (helmet/hat), Body (armor), and Accessory (ring, amulet, scarf). Each slot accepts one item. Equipment changes the character's visible appearance and modifies core stats (strength, defense, magic, luck). Set bonuses reward matching equipment pieces. |
| **Kid UX** | The child stamps **equipment items** throughout their level: sword stamps, shield stamps, helmet stamps, armor stamps, accessory stamps. When the player opens the equipment screen, they see a cute **body outline** with five glowing drop zones. Dragging a "Sword" stamp onto the right hand slot equips it — the character sprite updates instantly to show the sword. Dragging a "Knight Helmet" onto the head slot changes the character's head appearance. Matching sets (e.g., all Knight equipment) produce a golden glow and bonus stat popup. |
| **LLM Automation** | Computes aggregate stats from all equipped items, handles equipment-exclusive interactions (certain shields boost certain swords), manages resistance calculations (fire armor reduces fire damage), auto-generates stat tooltips as simple icon+number displays, tracks set bonus eligibility, and updates the player sprite composite to reflect all equipped gear visually. |
| **JSON Contract Extension** | `equipmentSlots: { rightHand, leftHand, head, body, accessory }, equippedItems[], setBonuses[], statAggregates }` |

### Weapon Upgrade Tiers

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Dark Souls / Hollow Knight |
| **Description** | Weapons improve through discrete tiers using collected materials. Each tier increases damage by a meaningful amount and changes the weapon's visual appearance (wooden -> iron -> steel -> gold -> crystal). Higher tiers require rarer materials found in harder areas. The upgrade path creates long-term progression goals. |
| **Kid UX** | The child stamps an **Upgrade Anvil** (cartoon anvil with sparkles). Tapping it opens a tier picker showing 1-5 stars. The LLM auto-generates visual upgrade progression — a wooden sword at 1 star gains iron bands at 2 stars, becomes steel at 3 stars, gold at 4 stars, and crystal at 5 stars. The child stamps **Material Tokens** (colored gems) on the canvas as collectible pickups. In play, touching the anvil with enough tokens upgrades the hero's weapon with a spectacular power-up animation (sparkles, power chord sound, sprite flash). |
| **LLM Automation** | Manages material inventory, calculates upgrade eligibility (tokens needed per tier), applies stat increases per tier, changes weapon sprite and visual effects on upgrade, plays satisfying upgrade animation, auto-balances material spawn rates per area difficulty, persists upgrades across sessions, and generates appropriate tier names (Rusty, Iron, Steel, Golden, Legendary). |
| **JSON Contract Extension** | `upgradeSystem: { type: weapon, tiers[{ tier, damage, materialsNeeded, visual }], currentTier, materialsInventory }` |

### Armor Capsules (Hidden Upgrades)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Mega Man X series |
| **Description** | Hidden capsules scattered throughout levels that permanently upgrade the player's abilities. Foot Parts enable dashing, Body Parts reduce damage taken, Head Parts allow breaking ceiling blocks and improve energy efficiency, and Arm Parts upgrade the charge shot. Each capsule is hidden behind a breakable wall or at the end of an optional challenge path. |
| **Kid UX** | The child stamps **"Dr. Light Capsules"** (glowing tubes with a hologram figure inside) hidden in their level — behind destructible walls, at the top of difficult platforming sections, or underwater. When the player finds and enters a capsule, a celebratory cutscene plays: a body part glows with an upgrade icon (lightning bolt for dash, shield for armor, star for helmet, fist for arm cannon). The player sprite updates to show the new armor piece visually. Each capsule grants a permanent ability that changes how the player traverses the level. |
| **LLM Automation** | Tracks which capsules have been collected per save file, applies permanent ability flags on collection (canDash, damageReductionPercent, canBreakCeilings, canChargeSpecial), updates the player sprite to show progressive armor visual upgrades, ensures capsules require prerequisite exploration abilities (e.g., dash capsule is placed behind a wall that requires dash to reach, creating a chain), and plays the capsule discovery cutscene sequence. |
| **JSON Contract Extension** | `armorCapsules: [{ id, ability, prereq, visual, collected }], abilityFlags: { canDash, canAirDash, canChargeSpecial, damageReduction }` |

### Weapon Skill Swapping (Materia-Style)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Elden Ring (Ashes of War) / Final Fantasy VII (Materia) |
| **Description** | Special combat abilities can be attached to and detached from weapons freely. A "Skill Gem" might add a spinning slash, a charge thrust, a parry, or a magic projectile. The player can experiment with different skill-weapon combinations to find synergies. Skills have cooldowns and visual effects. |
| **Kid UX** | The child stamps **"Skill Gem"** stamps (star-shaped icons in different colors: red for attack skills, blue for defense, green for magic). Dragging a gem onto a weapon "socket" attaches it — the gem glows and the weapon sprite updates to show the new capability. Tapping the skill button in play triggers the move with a cool flash animation. The child can drag different gems onto the same weapon to swap. A "Skill Wheel" UI shows up to 4 equipped skills as large, colorful buttons with icon previews of what they do. |
| **LLM Automation** | Validates gem-weapon compatibility, applies skill parameters to the weapon entity, generates appropriate animation and VFX for each skill combination, manages skill cooldowns, saves current skill loadout, generates skill preview animations when socketed, prevents incompatible combinations gracefully, and auto-balances skill power relative to weapon tier. |
| **JSON Contract Extension** | `weaponSkills: { weaponId, equippedSkill{ skillId, animation, vfx, cooldown, damageMultiplier, hitboxShape }, compatibleSkills[] }` |

### Fragment-Based Permanent Upgrades

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Hollow Knight (Mask Shards / Vessel Fragments) |
| **Description** | Fragment items hidden throughout the world that permanently upgrade stats when enough are collected. Four Heart Pieces combine into one extra max HP. Three Magic Drops combine into one extra magic vessel. Fragments encourage thorough exploration — finding the final piece to complete a set is deeply satisfying. |
| **Kid UX** | The child stamps **"Heart Piece"** stamps (each showing 1/4 of a heart shape) hidden throughout the level — behind difficult jumps, inside secret rooms, at the end of combat challenges. When the hero collects 4 pieces, the LLM auto-combines them into a full heart with a spectacular "DING!" animation and confetti. The HUD shows collected fragments as a pie chart filling up. Heart Pieces increase max HP. Star Pieces increase max magic. Shield Pieces increase defense. The child can see at a glance how close they are to the next upgrade. |
| **LLM Automation** | Tracks fragment collection count per type, detects when the threshold is reached (e.g., 4/4 heart pieces), triggers the combination animation and upgrade, updates max HP/magic/defense, resets the fragment counter with visual carryover, distributes fragment placements to reward exploration, and optionally shows a fragment radar pulse when a specific "Compass Badge" is equipped. |
| **JSON Contract Extension** | `fragmentUpgrades: [{ type, fragmentName, fragmentsNeeded, fragmentsCollected, upgradeAmount, visual, combineAnimation }]` |

---

## 6.6 Inventory Management

What you can carry shapes how you play. These features create satisfying constraints around inventory that make every item choice meaningful.

### Grid Inventory (Tetris-Style)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Resident Evil series |
| **Description** | Items take up specific shapes on a limited-size grid. The player must rotate and arrange items to fit everything they want to carry. Key items, weapons, ammo, healing herbs, and food all occupy different grid shapes. An "Auto-Arrange" button helps organize, but manual optimization is part of the fun. |
| **Kid UX** | The child stamps an **Inventory Box** or enables the grid on the hero. A grid pops up (6x4 squares). Each collected item becomes a colorful block of specific shape: potion = 1x1 square, sword = 1x2 rectangle, shotgun = L-shaped (2x2 missing one corner), armor = 2x2 square, key = 1x1. Items are dragged to position and double-tapped to rotate 90 degrees. Items that don't fit must be stored in an **Item Box** (accessible from safe rooms). An **"Auto-Sort"** button (robot icon) helps younger children organize. The grid uses bright colors and clear item art so shapes are visually distinct. |
| **LLM Automation** | Validates item placement (no overlaps, within grid bounds), handles rotation of item shapes, enforces capacity limits, manages the auto-arrange algorithm using a simple bin-packing heuristic, tracks which items are in inventory vs. equipped vs. stored, and generates appropriate grid shapes for all item types. |
| **JSON Contract Extension** | `inventoryGrid: { width, height, itemShapes[{ id, shape[][], rotatable }], currentLayout[], itemBox[] }` |

### Item Box (Shared Storage)

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Resident Evil / Castlevania |
| **Description** | A shared storage system accessible from any safe room or designated checkpoint. Items placed in the Item Box are available at all other Item Box locations, creating a network of shared inventory. This lets the player store excess items without losing them, reducing the pressure of inventory constraints. |
| **Kid UX** | The child stamps an **Item Box** inside safe rooms (a colorful chest with a glowing lid). Tapping the box opens the storage screen, split into "Inventory" and "Box" sections. Dragging items between sections transfers them. A large number shows box capacity (e.g., "12/20"). Items in the box appear at every other Item Box the player finds, creating a magical sense of connected storage. The box lid opens with a satisfying creak and sparkle when accessed. |
| **LLM Automation** | Manages the shared Item Box inventory as a global save variable, handles item transfer between inventory and box, enforces box capacity limits, ensures item availability at all linked box locations, syncs box state across all access points, and generates appropriate open/close animations. |
| **JSON Contract Extension** | `itemBox: { sharedInventory[], capacity, currentCount, linkedLocations[], accessPoints[] }` |

---

## 6.7 Shops & Economy

Commerce creates worldbuilding. These features establish NPC merchants, quest-based rewards, and economic loops that make the game world feel inhabited and purposeful.

### NPC Merchant System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Castlevania (Librarian) / Monster Hunter (Item Shop) / Shovel Knight (Chester) |
| **Description** | A friendly NPC merchant who buys and sells items. The player can sell collected treasures, gems, and duplicate items for currency, then purchase healing items, equipment, weapon skills, or key items. Shop inventory expands as the player progresses through the game, creating a sense of the world's economy growing alongside the player. |
| **Kid UX** | The child stamps a **Shopkeeper** NPC onto their canvas (a friendly character behind a counter). Tapping the shopkeeper opens a shop screen split into **"Buy"** and **"Sell"**. Items appear as big stamps with price tags in coin icons. The player drags items from their inventory to the "Sell" side to get gold coins. Then drags desired items from the "Buy" side to purchase. The gold coin counter updates in real-time. Unaffordable items are grayed out with a small lock icon. A "Special Deal!" bubble occasionally appears over random items with a discount. The shopkeeper has expressive reactions — happy when buying, thoughtful when selling. |
| **LLM Automation** | Manages the merchant's inventory and pricing per level progression, validates purchase transactions (sufficient funds, inventory space), calculates sell values (typically 25-50% of buy price), manages shop inventory unlocking (new items appear after certain progression flags like defeating a boss or reaching a new area), tracks merchant relationship level (discounts for repeat business), generates shopkeeper dialogue, restocks shops between level visits, and handles "sold out" state for limited-stock items. |
| **JSON Contract Extension** | `merchant: { shopkeeperId, inventory[{ itemId, buyPrice, sellPrice, stock, unlockCondition }], currency, playerBalance, discountRate, restockOn }` |

### Quest Board System

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Castlevania: Portrait of Ruin / Monster Hunter |
| **Description** | NPCs and bulletin boards offer optional quests with specific objectives: defeat X enemies, find an item, bloom all flowers in an area, defeat a specific boss without taking damage. Completing quests rewards unique items, Praise, currency, or unlocks new stamps. Quests provide structured goals that guide exploration and reward mastery. |
| **Kid UX** | The child stamps a **Quest Board** (big wooden sign with colorful paper notices pinned to it) or a **Villager NPC** with a "!" bubble. Tapping it shows 2-3 quest cards with fun icons: "Defeat 5 Bats!" (bat icon x5), "Find the Red Gem!" (ruby icon), "Cook a Meal!" (pot icon). The player accepts a quest by tapping it. A **Quest Tracker** appears at the edge of the screen showing progress ("Bats: 3/5"). Completing a quest auto-triggers a reward burst with fanfare and a checkmark on the quest card. |
| **LLM Automation** | Tracks quest progress (kill counters, item possession checks, area exploration flags, crafting completion), validates completion conditions against quest requirements, triggers reward distribution on completion, manages quest state machine (available -> active -> completed -> turned in), generates new quests procedurally based on level content, displays progress in the Quest Tracker HUD, and manages quest reward scaling. |
| **JSON Contract Extension** | `quests: [{ id, giver, objective{ type, target, count }, reward[], state, progress, trackerPosition }]` |

### Enemy Drop Tables

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Castlevania: Symphony of the Night |
| **Description** | Each enemy type has a unique drop table with common, uncommon, and rare items. Defeating an enemy rolls against its drop table to determine what (if anything) is dropped. Drop chance is influenced by the player's Luck stat. Some rare items have very low drop rates, creating exciting "jackpot" moments. |
| **Kid UX** | The child stamps an enemy, then taps a **"treasure bag"** icon that appears above the enemy stamp. A simple 3-slot popup shows: **Common** (big brown bag, 70% chance), **Uncommon** (sparkly blue bag, 25% chance), and **Rare** (rainbow gold bag, 5% chance). The child drags item stamps into each slot to set drops. During play, defeated enemies bounce an item bag that opens with a sparkle to reveal the drop. Rare drops produce a dramatic slow-motion reveal with a golden glow. The player can equip a "Lucky Charm" accessory to increase drop rates (shown as bigger bag icons). |
| **LLM Automation** | Manages RNG roll on enemy defeat (modified by player Luck stat), handles drop physics (item bounces once, then magnetizes toward player), manages drop table definitions per enemy type, tracks drop rate modifiers from equipment and badges, generates appropriate rarity VFX (common = small sparkle, rare = golden glow + slow motion), and ensures drop tables are balanced so rare drops feel special but not frustrating. |
| **JSON Contract Extension** | `dropTables: { enemyId: { common{ itemId, baseChance }, uncommon{ itemId, baseChance }, rare{ itemId, baseChance } }, luckScaling }` |

---

## 6.8 Special Item Systems

Beyond standard consumables and equipment, these features introduce unique item mechanics that create memorable moments and deep crafting interactions.

### Trap Crafting & Deployment

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Monster Hunter series |
| **Description** | Players can craft and deploy traps that immobilize enemies — Pitfall Traps sink monsters into the ground, Shock Traps paralyze with electricity, and Tranq Bombs put enemies to sleep. Traps are essential for capturing monsters alive (which yields bonus rewards) and creating tactical advantages in combat. |
| **Kid UX** | The child stamps **Trap Blueprints** at crafting stations: "Pitfall Trap" requires a Net + Trap Tool, "Shock Trap" requires a Thunderbug + Trap Tool. Crafted traps appear as items in inventory. The child stamps **Trap Placement Zones** on the ground. During play, the player places a trap by tapping the zone — it becomes hidden until triggered. When a monster walks over it: Pitfall = monster sinks into the ground, immobilized for 10 seconds; Shock = monster twitches with electricity, stunned for 8 seconds. A **"Capture!"** icon appears when the monster is weak enough + trapped. |
| **LLM Automation** | Handles trap trigger detection (enemy proximity and step-on validation), applies immobilization or paralysis status with appropriate duration, manages trap visibility state (hidden until triggered, then visible during effect), tracks monster HP threshold for capture eligibility (typically below 20%), handles capture rewards vs. slay rewards, and manages trap inventory and crafting recipe validation. |
| **JSON Contract Extension** | `trapTypes: [{ id, duration, effect, trigger, craftingRecipe }], captureMechanic: { hpThreshold, requiresTrap, bonusRewards }` |

### Collectible Stamps & Album

| Attribute | Detail |
|-----------|--------|
| **Source Game** | NiGHTS into Dreams / Animal Crossing |
| **Description** | Special decorative stamps that the player collects throughout their adventures. Each collectible stamp features artwork of an enemy, item, location, or character encountered in the game. Collected stamps fill a **Collector's Album** organized by category. Completing album pages grants bonus rewards and bragging rights. |
| **Kid UX** | Every time the player defeats a new enemy type, discovers a new item, or visits a new location for the first time, a **"New Stamp!"** popup appears with a beautiful illustration. The player taps to add it to their Collector's Album — a digital scrapbook organized into pages: "Enemies," "Items," "Places," "Friends." Each page shows empty slots for undiscovered stamps as gray outlines. Completing a full page produces a **"Page Complete!** celebration with a special reward (new costume color, bonus currency, or exclusive stamp). The album is accessible from the main menu and becomes a visual diary of the player's journey. |
| **LLM Automation** | Tracks first-time discoveries per save file, generates collectible stamp artwork from entity sprites (auto-composed into decorative borders), manages album page organization and completion detection, triggers page-complete celebrations and rewards, saves album state persistently, and generates album reward tiers (bronze for 25% complete, silver for 50%, gold for 100%). |
| **JSON Contract Extension** | `collectibleAlbum: { categories[], stamps[{ id, category, unlocked, artwork }], completionProgress, pageRewards[], totalCollected }` |

### Key Item & Door Matching

| Attribute | Detail |
|-----------|--------|
| **Source Game** | Resident Evil / Zelda |
| **Description** | Progression requires finding specific key items and using them at matching environmental objects. Keys are color-coded and shape-coded to their doors: a Red Diamond Key opens a Red Diamond Door, a Blue Circle Key opens a Blue Circle Door. The visual matching makes the system intuitive for children while creating satisfying lock-and-key puzzles. |
| **Kid UX** | The child stamps a **Key Door** with a colored/shaped keyhole: a red diamond shape, a blue circle, a gold star. They then stamp the matching **Key** item somewhere else in the level. The key item shows the same colored shape icon. When the player finds the key and brings it to the door, the shapes snap together with a satisfying "click" sound and the door opens with a sparkle. The child can create multi-key puzzles by stamping several doors and scattering their keys throughout the level. |
| **LLM Automation** | Validates key-door matching by color and shape, handles key consumption on use (optional — some keys are reusable), manages puzzle state for multi-key sequences, checks solution correctness, triggers open animations on successful match, and ensures keys are placed in locations reachable without the key they're meant to open (no soft-lock validation). |
| **JSON Contract Extension** | `keyItems: [{ id, shape, color, consumable, reusable }], keyDoors: [{ id, requiredKey, state }]` |

---

## 6.9 Economy & Item System Comparison

| Feature Category | Key Source Games | Feature Count | Core Kid Interaction |
|-----------------|-----------------|---------------|---------------------|
| Currency & Collection | Mario, Sonic, Dark Souls, Okami | 4 | Collect on proximity, recovery runs |
| Crafting & Discovery | DQ Builders, Monster Hunter, KH | 4 | Drag materials to combine |
| Cooking & Food | Monster Hunter, Zelda | 2 | Timing-based minigame, ingredient mixing |
| Consumables & Healing | Dark Souls, Resident Evil, Bloodborne | 4 | Tap to use, drag to combine herbs |
| Equipment & Upgrades | Castlevania, Mega Man X, Dark Souls | 5 | Drag to equip, find capsules |
| Inventory Management | Resident Evil | 2 | Drag shapes on grid, shared storage |
| Shops & Economy | Castlevania, MH, Shovel Knight | 3 | Buy/sell with shopkeeper |
| Special Item Systems | Monster Hunter, RE, Zelda | 3 | Deploy traps, match keys |
| **TOTAL** | | **~31 features** | |

The items, crafting, and economy systems in KidGameMaker transform collection from a passive activity into an active adventure. Every coin collected, every recipe discovered, every dish cooked, and every weapon upgraded represents a meaningful choice made by the player — or a thoughtful design decision by the child creator. The LLM's invisible hand ensures that economies stay balanced, that crafting combinations always produce satisfying results, and that inventory management never becomes frustrating. The result is a rich ecosystem of rewards where every player feels like a master chef, a legendary blacksmith, and a treasure hunter all at once.


---

# Chapter 7: Rules, Logic & Puzzle Systems

## 7.1 Trigger & Switch Systems

The foundation of any interactive game world is the cause-and-effect relationship between player actions and environmental responses. This section transforms the static canvas into a living, reactive playground where every stamp can become a participant in a grand chain of consequences. Drawing from Mario Maker 2's celebrated switch mechanics, Zelda's time-honored pressure plates, and the intuitive rule-based systems of Kodu Game Lab, KidGameMaker provides a complete vocabulary of trigger types that a five-year-old can deploy with single taps.

**ON/OFF Switch Block System.** Source: *Super Mario Maker 2.* The quintessential toggle mechanic: hitting a switch stamp changes a global boolean state, instantly affecting every connected element in the level. Dotted-line blocks phase between solid and ethereal, spike blocks extend and retract, conveyor belts reverse direction, and doors open or seal. For a child, the experience is pure magical cause-and-effect: they place a bright red switch stamp on the wall, stamp a trail of blue dotted-line blocks across a pit, and tap the switch during playtest to watch the blocks shimmer into existence. The LLM maintains the global `onOffState` boolean, wires all switchable elements to listen for state changes, manages transition animations, and validates that the level remains solvable in both states. Each switch can optionally be assigned a color channel (red, blue, green, yellow), allowing multiple independent toggle networks within a single level. The JSON contract extends with `"onOffState": false` and a `"switchableElements"` array mapping each affected stamp to its on-state and off-state properties.

**Floor Button / Pressure Plate.** Source: *The Legend of Zelda, Terraria.* A ground-level trigger activated when the player or any physics object rests upon it. Unlike the momentary hit of an ON/OFF switch, pressure plates stay active as long as weight is present. A child stamps a circular metal plate on the floor and draws a wire line from it to a heavy stone door; when their hero stands on the plate, the door rumbles open, and the moment they step off, it slowly grinds shut. The LLM handles collision detection between the plate zone and any entity with mass, manages the continuous activation state, and supports configurable behaviors: stay-open (requires constant weight), toggle (press once to switch), and timed (stays active for N seconds after release). Pressure plates can also discriminate by entity type, enabling puzzles where only a heavy crate or an enemy triggers the mechanism.

**Wall Lever.** Source: *Super Mario Maker 2, Castlevania.* A vertical wall-mounted switch that toggles between up and down positions with a satisfying mechanical snap. Levers are inherently directional: they can be configured as one-way (always toggles the same direction) or two-way (flips back and forth). A child stamps a lever beside a drawbridge and taps it during play; the lever snaps down with a chunky animation and the drawbridge rotates to span a moat. The LLM generates lever-pull animations, manages the toggle state machine, supports timed auto-reset (lever flips back after 5 seconds), and can chain multiple levers into combination locks where levers must be set in a specific pattern.

**Target Hit Trigger.** Source: *The Legend of Zelda, Super Mario Maker 2.* A switch activated by striking it with a projectile or weapon. Target switches come in multiple visual forms: bullseye panels, crystal orbs, and bell-shaped gongs. A child places a target on a high ledge that can only be reached by an arrow shot, then draws a wire from the target to a hidden door; hitting the target from across a chasm becomes a satisfying precision challenge. The LLM registers the target as a damage-receiving entity with a specific hitbox, validates that the required projectile type matches (arrow, fireball, or any attack), and triggers the connected action on successful hit. Targets can require multiple hits, sequential hits from different angles, or specific elemental damage types.

**Coin Collection Trigger.** Source: *Super Mario Maker 2.* A conditional trigger that activates when the player has collected a specified number of coins (or any collectible type). A child stamps a golden gate blocking the exit and configures it to open only after 30 coins are gathered; as the player collects coins, a visual counter fills, and the gate dramatically unlocks when the threshold is reached. The LLM maintains a running tally of the specified collectible, displays a HUD counter with filling animation, and triggers the gate-open event on threshold crossing. The system supports multiple collectible types beyond coins: stars, keys, gems, or custom collectibles. Advanced variants include "collect all in zone" (requires gathering every coin in a marked region) and "collect in order" (coins must be touched in a specific sequence).

**Button Sequence Puzzle.** Source: *Resident Evil, The Legend of Zelda.* A set of numbered or colored buttons that must be pressed in the correct order to unlock a reward. A child stamps three glowing rune buttons on a wall and sets the secret sequence to "red, blue, red"; pressing them in the wrong order causes a gentle buzz and reset, while the correct sequence triggers a triumphant fanfare and opens a treasure vault. The LLM manages the input buffer, validates each press against the solution sequence, provides immediate audio-visual feedback for correct and incorrect entries, and supports multiple attempt modes: unlimited tries, limited tries (three strikes), and time-limited sequences. The solution sequence can be revealed through environmental clues: a painting above the buttons, a story block hint, or constellation patterns.

**Proximity Sensor Trigger.** Source: *LittleBigPlanet, Dreams.* An invisible (or softly glowing) zone that activates when the player enters its radius. Unlike touch triggers that require direct contact, proximity sensors offer a larger activation window and can discriminate by entity type. A child stamps a proximity zone around a sleeping dragon; when the hero gets within 100 pixels, the dragon wakes with a roar and begins chasing. The LLM manages circular or rectangular detection zones, supports configurable radii, handles enter/exit/stay event types, and can combine multiple proximity zones with AND/OR logic. Visual debug outlines appear in edit mode, hidden during play.

**Timer Trigger.** Source: *Super Mario Maker 2, Kodu Game Lab.* A trigger that fires after a configurable delay, optionally repeating on an interval. Timer triggers are the glue of sequential puzzles: a child stamps a timer that starts when a switch is hit, giving the player 10 seconds to cross a bridge before it retracts. The LLM manages countdown display (optional on-screen timer), supports pause-on-damage and pause-on-pause behaviors, and can chain timers into complex sequences. Timer triggers can also be configured as "beat the clock" challenges where the timer drives the win condition.

**Countdown Cascade.** Source: *Super Mario Maker 2 P-Switch timer.* An extension of the timer trigger where multiple timed events fire in sequence, creating a rhythm of environmental changes. A child configures a cascade: at 0 seconds a bridge appears, at 5 seconds a wall of coins materializes, at 10 seconds the exit unlocks. The LLM orchestrates the entire sequence from a single trigger event, managing the timeline, spawning effects at each beat, and providing audio cues that help the player anticipate upcoming changes.

**Chain Reaction Trigger.** Source: *Zelda TotK chemistry engine, Mario Maker.* A trigger designed to propagate across multiple connected objects, creating spectacular chain reactions. A child stamps a row of explosive barrels connected by fuse lines; hitting the first barrel ignites a fuse that sequentially detonates each barrel with perfectly timed delays. The LLM calculates propagation timing based on fuse length, manages the chain state (which links are active, burned, or pending), and ensures deterministic behavior so the child can build puzzles around predictable chain timing.

## 7.2 Door, Key & Gate Systems

Doors are the grammar of game progression: they create the "I can't go there... yet" tension that drives exploration and reward. This section transforms simple barriers into a rich language of gating mechanisms, drawing from Resident Evil's iconic key-item matching, Castlevania's ability-based relic gating, and Dark Souls' fog gates that signal the gravity of what lies beyond.

**Color-Coded Key Door.** Source: *Bloxels, Zelda games.* The foundational gating mechanic: a door stamp and a key stamp share a color code, and collecting the key permanently unlocks all matching doors. A child stamps a red door blocking the path, hides a red key at the top of a challenging platforming section, and the system auto-wires the connection. When the player grabs the key, all red doors play an unlocking animation with satisfying particle effects. The LLM auto-generates the key-door binding from matching color assignments, validates that every key has at least one corresponding door (warning if orphaned), manages the visual state transitions (locked → unlocking → open), and supports multi-key configurations where collecting three blue keys opens a grand treasure vault.

**Key Item Puzzle.** Source: *Resident Evil series.* An extension of color-coded keys where the lock requires a specific item type rather than a generic key. A child stamps a "Crest Socket" on a door and hides a "Sun Crest" item in a puzzle room; only the Sun Crest will fit, and collecting it adds a permanent inventory entry. The LLM manages the inventory check, validates item-lock compatibility, plays a unique insertion animation per item type, and supports consumed-key versus retained-key modes. This system enables narrative gating where the player must recover the King's Signet Ring from a tomb to open the throne room.

**Relic Power-Up Gating.** Source: *Castlevania: Symphony of the Night.* The most sophisticated form of ability gating: certain areas are reachable only after the player acquires a specific traversal relic. A child stamps a "Bat Form" relic in a treasure chest and places "Mist Gate" barriers throughout the level that only bat-form players can pass through. The LLM maintains a directed acyclical graph of gating dependencies, auto-detects which relics are required for each gate type, marks accessible and inaccessible gates with colored sparkles based on the player's current relic collection, and validates full map reachability to prevent soft-locks. Supported gate types include: Double-Jump Ledge (requires Leap Stone), Mist Passage (requires Mist Form), Bat Tunnel (requires Bat Form), Swim Depth (requires Merman Scale), and Breakable Wall (requires sufficient strength upgrade).

**Fog Gate Boss Arena.** Source: *Dark Souls, Elden Ring.* A dramatic barrier that blocks entry to a boss encounter until the boss is defeated. A child stamps a "Sparkly Door" (swirling purple particles) at a corridor entrance; walking into it triggers a "whoosh" transition and seals the exit until the boss HP reaches zero. The LLM auto-generates enclosed arena geometry behind the fog gate, seals all exits on entry, triggers the boss intro animation, reopens the gate on boss defeat with a victory fanfare, and auto-saves pre-boss state for respawn. Fog gates can be configured with auto-enter (walk in to start) or confirmation prompts (tap to enter) for younger children who might find boss fights intimidating.

**Secret / Illusory Wall.** Source: *Dark Souls, Castlevania: Symphony of the Night.* A wall tile that appears completely normal but disappears or becomes transparent when the player attacks it, rolls into it, or uses a specific ability. A child stamps a "Secret Wall" (visually identical to normal walls, with an optional tiny sparkle hint) and places a treasure room behind it; when the hero bumps it, the wall shimmers and fades away. The LLM renders secret walls identically to normal walls during play, handles the trigger collision (bump, attack, or ability-specific), plays the dissolve or slide-away animation, toggles the collision layer off, and can auto-generate a contextual reward behind the wall based on level progression. Discovery of secret walls is tracked and celebrated with a "Secret Found!" notification.

**Shortcut Opening.** Source: *Dark Souls (Firelink to Parish elevator).* A one-way passage that, once unlocked from the far side, becomes a permanent fast connection between two distant areas. A child stamps a "Blocked Door" at the village entrance and an "Unlock Lever" at the castle end; pulling the lever permanently opens the door, allowing future traversals to bypass the dangerous forest. The LLM generates the connecting geometry (elevator shaft, tunnel, ladder), wires the lever-to-door state toggle, saves the shortcut as permanently unlocked in session state, and plays a satisfying fanfare on first unlock. Shortcuts represent one of the most profound expressions of player progression: territory that was once dangerous becomes safely traversable.

**Combination Lock Door.** Source: *Resident Evil symbol puzzles.* A door secured by a multi-symbol combination that must be discovered through exploration. A child stamps a door with three rotating dial slots and hides clues throughout the level (a painting shows "sun-moon-star", a story block whispers the sequence); the player rotates each dial to the correct symbol to unlock. The LLM manages dial rotation input, validates the entered combination against the solution, provides audio-visual feedback for correct and incorrect entries, and supports progressive hinting (first wrong attempt: no hint; second: clue glows faintly; third: solution preview). Combination locks can use symbols, numbers, colors, or custom icons.

**Multi-Conditional Gate.** Source: *Super Mario Maker 2 Clear Conditions, Dark Souls fog gates.* A gate that requires multiple different conditions to be satisfied simultaneously: collect all stars AND defeat the miniboss AND pull the lever. A child stamps an ornate golden gate and opens a checklist menu where they assign three different condition stamps; the gate displays progress with filling runes as each condition is met, then dramatically opens when all are complete. The LLM tracks each condition independently, displays aggregate progress on the gate itself, and manages the final opening sequence. This system enables sophisticated puzzle design where multiple objectives must be completed in any order before progression is granted.

## 7.3 Puzzle Mechanics

Puzzles are the intellect of the game world: they invite the player to pause, observe, reason, and discover. This section adapts some of the most celebrated puzzle systems in gaming history for the stamp-based canvas, ensuring that every puzzle type can be placed, configured, and solved by a five-year-old without a single line of code.

**Glyph Drawing System.** Source: *Castlevania: Order of Ecclesia.* Players absorb magical glyphs by tracing simple symbols onto the screen. A child stamps a "Glyph Source" on an enemy or pedestal; a glowing magical symbol appears, and the child traces it with their finger (simple 2-3 stroke shapes: circle, zigzag, straight line, triangle). Successfully tracing the glyph absorbs it into the player's spell repertoire. The LLM validates trace accuracy with a generous 85% success threshold for children, manages the three-slot glyph equip system (left arm, right arm, back), computes Glyph Union results when two compatible glyphs are equipped (fire + sword = flaming sword), and tracks absorbed glyphs across sessions. Glyph tracing is forgiving: the system auto-snaps strokes to the intended shape when the child gets close, ensuring success feels earned but achievable.

**Constellation Unlocking.** Source: *Okami.* Scattered throughout a level are glowing star dots arranged in the shape of a constellation. Using a celestial brush (or simply drawing a line between stars), the player connects the dots in the correct order to summon a celestial spirit and unlock a reward. A child stamps a star pattern on a night-sky background; the kid draws lines connecting the stars, and when the constellation is complete, a majestic creature materializes with ink-wash animation and teaches a new ability. The LLM validates connections by proximity (auto-snaps to nearest star), detects constellation completion, triggers the summon animation, and associates each constellation with a unique reward. Constellations can be simple (3-4 stars for young children) to complex (15+ stars for advanced builders).

**Evidence Collection & Presentation.** Source: *Phoenix Wright: Ace Attorney.* A detective-puzzle system where players gather evidence items and present them to expose contradictions in NPC testimony. A child stamps "Evidence" items throughout a level (a photo, a document, a key), collects them into an "Evidence Folder" (briefcase icon), and during a "Talk" encounter with an NPC, drags evidence onto contradicting statements. A dramatic "OBJECTION!" animation plays on success. The LLM manages evidence inventory, validates evidence-to-contradiction matching, tracks which testimony sections have been exposed, and advances the narrative on successful presentations. For KidGameMaker, the system is simplified to single-evidence matches with generous visual feedback, but the core satisfaction of catching a lie is preserved.

**Secret-Hiding Lock System (Psyche-Locks).** Source: *Phoenix Wright: Ace Attorney (Justice for All).* When an NPC is hiding a secret, colorful padlock icons appear around them during dialogue. Breaking each lock requires presenting the correct piece of evidence. A child stamps an NPC with a "Has Secret" flag; 1-5 colorful locks appear around the character's portrait, and the player drags evidence items to shatter them with glass-breaking animations. The LLM generates the appropriate number of locks based on secret depth (more locks = deeper secret), validates evidence-to-lock matching, triggers lock-break animations with escalating drama, and reveals secret dialog when all locks are broken. This system transforms simple NPC conversations into satisfying mini-puzzles.

**Confidence Penalty Bar.** Source: *Phoenix Wright: Ace Attorney.* Instead of traditional health, the player has a Confidence meter (represented by glowing stars) that depletes when they present wrong evidence or make mistakes. Running out means a gentle retry from the last checkpoint. A child stamps a "Judge" NPC in their level; the star bar appears at the top, and wrong answers cause stars to shatter with dramatic but kid-friendly animations. The LLM tracks confidence value, applies penalties for wrong answers, restores stars for correct ones, triggers the retry gavel animation at zero, and manages checkpoint respawn. The system is inherently forgiving: stars can be partially restored by finding hidden evidence, and the penalty for wrong answers is gentle enough that exploration is encouraged over perfection.

**Match-3 Switch Panel.** Source: *Puzzle & Dragons, Candy Crush.* A grid of colored tiles that the player swaps to create lines of three or more matching colors. A child stamps a 6x6 switch panel in their level; swapping adjacent tiles causes matches to clear with satisfying cascades, and completing a target pattern (clear 20 red tiles) triggers a level-wide event. The LLM manages the swap input, validates matches (horizontal and vertical), processes cascades (new tiles fall in, creating chain reactions), tracks progress toward the target condition, and triggers the win event on completion. Match-3 panels can be integrated into platformer levels as literal floor panels the player steps on to swap, or as standalone puzzle rooms.

**Weight Balance Scale.** Source: *Zelda: Tears of the Kingdom, Portal 2.* A seesaw or scale platform that tilts based on the mass of objects placed upon it. A child stamps a balance platform and two crate types (light wood crate, heavy stone crate); placing a heavy crate on one side tilts the platform, creating a ramp to a high ledge. The LLM simulates weight physics per entity, calculates platform tilt angle from the torque balance, supports multiple weight sources on each side, and can require specific total weights to trigger events (both pans must balance to open the door). The system naturally teaches children about balance and equivalence in an embodied, playful way.

**Light Beam Redirector.** Source: *Zelda: Twilight Princess, The Talos Principle.* A system of light sources, mirrors, and receivers that the player arranges to direct beams of light to targets. A child stamps a "Sun Crystal" (light source), places rotatable mirror stamps, and a "Light Target" that triggers an event when illuminated. Rotating mirrors redirects the beam; the goal is to hit all targets simultaneously. The LLM casts ray paths from light sources, calculates reflections off mirror angles, detects receiver illumination, renders visible beam paths with particle effects, and triggers connected events when all required targets are lit. Beam puzzles can use colored light filters (red + blue beams = purple target activation) for combinatorial depth.

## 7.4 Custom Rule Engine

The Custom Rule Engine is the brain of KidGameMaker: it transforms the canvas from a static diorama into a dynamic, responsive game world. Inspired by Kodu Game Lab's groundbreaking natural-language programming, Dreams' elegant microchip grouping, and the event-driven simplicity of Scratch Jr, this engine gives children the power of game logic without a single line of code.

**When/Do Rule Cards.** Source: *Kodu Game Lab.* The crown jewel of kid-friendly programming: game rules are created using sentence-like cards that read as natural language. Each rule has a "WHEN" card (condition) and a "DO" card (action). Example: [WHEN "see player nearby"] [DO "jump toward"] or [WHEN "player collects coin"] [DO "spawn confetti"]. Cards snap together like puzzle pieces, and only compatible cards connect. A child wants to make an enemy chase the player: they tap "WHEN", select a picture card showing an eye (see player), then tap "DO" and select a running figure (move toward). The cards snap together with a satisfying click, and the enemy immediately behaves this way during playtest. The LLM parses When/Do pairs into game logic, handles underlying pathfinding and line-of-sight calculations, and suggests complementary rules (after "WHEN see player DO chase", it suggests "WHEN get hurt DO run away"). The system supports a rich vocabulary of conditions: see, hear, touch, timer, health below, distance to, collected, and defeated; and actions: move toward, jump, shoot, spawn, destroy, animate, change color, and play sound.

**Brainbox Logic Grouping.** Source: *Dreams (Microchips), LittleBigPlanet.* Complex logic can be grouped into visual containers called "Brainboxes" that appear as small colorful boxes on the canvas. Multiple behaviors, triggers, and rules can be placed inside a Brainbox, which has labeled input/output ports. This lets kids build reusable logic modules: a "Patrol Enemy" Brainbox contains all the rules for walking back and forth, and can be stamped anywhere with identical behavior. A child selects a group of Behavibods that make an enemy patrol, taps "Put in Brainbox", and the complex logic collapses into a neat box labeled with a custom icon. They stamp five more Brainboxes across the level, and each enemy patrols independently. The LLM handles the abstraction: creating the reusable module, managing variable scoping so each instance operates independently, and exposing configurable parameters (speed, patrol range) as Brainbox input ports.

**Event-Driven Trigger System.** Source: *Scratch Jr (Yellow Trigger Blocks).* Game events are triggered by colored icon blocks: "When Game Starts" (green flag), "When Player Touches" (hand icon), "When Key Pressed" (keyboard icon), "When All Collected" (star icon), "When Timer Ends" (clock icon). These are visual, icon-based triggers that children place on the canvas and connect to action stamps with finger-drawn wires. A child stamps a "When Player Touches" trigger on a platform, then stamps a "Spawn Enemy" action and draws a line between them; during playtest, walking onto that platform spawns an enemy. The LLM compiles trigger-action pairs into efficient event handlers, handles collision detection registration, manages event propagation for overlapping triggers, and prevents common mistakes like triggers that fire every frame instead of once.

**Clear Condition Builder.** Source: *Super Mario Maker 2.* Children define alternative win conditions beyond "reach the flagpole" by selecting from picture cards: defeat specific enemies, collect items, reach the goal within a time limit, complete without taking damage, or activate all switches. Each clear condition appears as a big colorful stamp that sits at the top of the screen during play, showing progress with filling animations. A child taps the "Win Rules" trophy icon, selects picture cards for "Collect all stars" and "Don't get hurt", and sets target numbers with plus/minus buttons. The LLM tracks condition state during gameplay, evaluates win/lose conditions, displays HUD counters, and validates that conditions are actually achievable (warning if "defeat all enemies" is selected but no enemies are placed). Clear conditions can be combined with AND logic (must do both) or OR logic (either condition wins).

**Sub-Areas / Warp Pipes.** Source: *Super Mario Maker 1 & 2.* Secondary rooms accessible via pipes or doors, each with its own theme, enemies, and layout. A child places a green pipe stamp, taps "Go Inside", and the canvas switches to a sub-area view showing a miniature room. Color-coded pipes automatically link: the green pipe in the main area connects to the green pipe in the sub-area. The LLM manages the room graph topology, handles warp transitions with fade effects, validates that all pipe pairs have matching destinations, prevents infinite warp loops, and enforces memory budgets per sub-area. Sub-areas enable non-linear level design, secret rooms, and dramatic pacing changes (a tight underground section followed by an open sky section).

**Logic Gate System.** Source: *LittleBigPlanet, Dreams.* For children ready to graduate from simple trigger-action pairs, logic gates provide AND, OR, NOT, and XOR operations. A child stamps an AND gate and draws two input wires from separate pressure plates and one output wire to a door; both plates must be pressed simultaneously for the door to open. The LLM renders gates as friendly shapes (AND = hexagon, OR = circle, NOT = triangle), evaluates logic every frame, and visualizes gate state with color coding (green = true, red = false). Logic gates can be nested within Brainboxes and combined to create sophisticated puzzles: "open the vault only if both guards are defeated AND the timer has not expired."

**Counter & Variable System.** Source: *Game Builder Garage (Counter Nodon), Dreams.* Numeric variables that can be incremented, decremented, and compared against thresholds. A child stamps a counter, sets its initial value to 0, and wires three separate coin triggers to its "+1" input; when the counter reaches 5, it fires an output event that opens a door. The LLM manages variable storage per level, handles arithmetic operations (add, subtract, set, reset), supports comparison operations (equals, greater than, less than), and displays current values in edit mode. Counters enable score tracking, multi-step puzzle sequencing, and progressive difficulty within a single level.

**Randomizer Module.** Source: *Dreams (Randomizer Nodon), Mario Maker.* A module that selects one of several outputs at random each time it fires, creating unpredictable and replayable level elements. A child stamps a randomizer with four output wires leading to different enemy spawner positions; each time the player enters the room, enemies appear in a different arrangement. The LLM manages the probability distribution (equal by default, configurable per output), ensures true randomness with seed-based reproducibility, and supports weighted randomization (one outcome more likely than others). Randomizers are perfect for creating levels that feel fresh on every playthrough.

**State Machine Builder.** Source: *Game Builder Garage, Dreams.* A visual finite state machine where nodes represent states and edges represent transitions. A child builds a simple door state machine: "Closed" state connects to "Opening" via "player has key" transition, "Opening" connects to "Open" via "animation complete" transition. The LLM renders states as rounded boxes with custom labels, transitions as labeled arrows with condition stamps attached, and highlights the current active state during playtest. State machines are ideal for multi-phase boss fights, complex door systems, and NPC dialogue trees.

**Global Event Bus.** Source: *Mario Maker 2 ON/OFF switch (global state).* A broadcast system where any trigger can fire a named global event, and any number of receivers can listen for it. A child stamps a "Defeat Boss" trigger that broadcasts "BOSS_DOWN" and stamps five different doors that all listen for "BOSS_DOWN"; defeating the boss opens every door simultaneously. The LLM maintains the global event registry, handles one-to-many broadcast semantics, provides a visual event bus diagram showing all connections, and supports event namespaces ("WORLD1_DOOR_OPEN" vs "WORLD2_DOOR_OPEN") to prevent conflicts in large levels. The global event bus is the connective tissue that enables large-scale coordinated events across an entire level.

**Rule Priority System.** Source: *Kodu Game Lab rule prioritization.* When multiple rules apply to the same entity, a priority number determines which rule takes precedence. A child gives their enemy two rules: "WHEN see player DO chase" at priority 1 and "WHEN at edge of cliff DO turn around" at priority 2. When both conditions are true simultaneously, the higher-priority rule (don't fall) wins. The LLM evaluates all active rules every tick, sorts by priority, executes the highest matching rule, and provides a visual priority stack in edit mode. Priority enables sophisticated behavior trees without the complexity of traditional programming: enemies can have safety overrides, patrol rules, and chase rules all coexisting in a single entity.

**Touch-Sensor Behavior Attachments.** Source: *LittleBigPlanet (Sackbot behavior chips), Kodu.* Pre-built behavior modules that can be attached to any stamp via drag-and-drop: Patrol (walk between waypoints), Chase (follow the player), Jump (hop periodically or when near edges), Shoot (fire projectiles at intervals), Flee (run away from player), and Sleep (stationary until player approaches). A child drags a "Chase" behavior chip onto an enemy stamp and adjusts a single slider for chase speed; the enemy immediately gains player-following intelligence. The LLM generates appropriate pathfinding per behavior type, handles edge cases (enemy falls in a pit → respawn at start), ensures behaviors don't conflict (chase + flee would cancel out), and auto-tunes parameters for the level's difficulty setting.


---

# Chapter 8: AI-Assisted Magic Features

## 8.1 AI Generation Tools

This is the heart of KidGameMaker's differentiation: a suite of AI-powered creation tools that transform a child's spoken description into a fully playable game level within seconds. Where traditional game engines demand mastery of complex interfaces, KidGameMaker's AI Generation Tools make the gap between imagination and instantiation nearly invisible. These tools are not assistive add-ons; they are the primary creative interface, designed to make a five-year-old feel like a sorcerer who simply speaks their world into existence.

**Magic Stamp Generator.** Source: *Roblox AI Texture Generator, DALL-E/Midjourney.* The crown jewel of AI-assisted creation. A child describes anything they can imagine: "a purple dragon with glitter wings and a friendly smile," and within three seconds, a game-ready stamp asset appears in their palette. The generated stamp comes complete with a transparent background, art style matching the existing asset library, auto-cropped edges, and a generated thumbnail icon. The child can immediately drag it onto the canvas and the stamp behaves like any other: it collides, it casts shadows, it can be wired to triggers. The LLM backend runs a full generation pipeline: parsing the child's description for disambiguation and safety filtering, generating the image via a fine-tuned diffusion model with kid-safe prompt engineering, auto-removing the background via segmentation, applying style transfer to match the game's existing palette, generating a thumbnail, and caching the result for instant reuse. For children with motor disabilities who cannot draw, this feature removes the artistic barrier entirely; for all children, it transforms asset creation from a technical skill into an act of pure imagination. The JSON contract extends with `"stamp_generation"` containing the prompt, style match flag, auto-transparency toggle, and generation metadata including safety scores.

**Talk-to-Build Assistant.** Source: *Minecraft Copilot, AI Dungeon.* The child speaks a full level description: "I want a jungle level with monkeys swinging on vines, a treasure chest behind a waterfall, and a big friendly tiger at the end," and the AI translates this into a complete, playable, balanced level. The canvas populates with jungle-themed terrain, monkey enemy stamps on vine platforms, a waterfall with a hidden alcove containing a treasure chest, and a large tiger boss at the goal. Every element is logically positioned: monkeys swing on pre-placed vines, the waterfall occludes the treasure room entrance, and the tiger has appropriate health for its position. The LLM backend runs a complete NLU pipeline: extracting entities (jungle = biome theme; monkeys = NPC stamps; treasure chest = objective item), mapping descriptions to stamp library entries via semantic similarity, applying Spelunky-style room chunk generation with age-appropriate difficulty curves, auto-balancing platform gaps and enemy density, and rendering the result as stamp arrangements on the canvas. The child can then edit any element: move the tiger left, add more vines, replace the chest with a key. Talk-to-Build supports iterative refinement: "add more trees" adds trees without regenerating the entire level, and "make it spookier" swaps bright jungle stamps for shadowy variants while preserving layout. The JSON contract captures parsed entities, layout algorithm selection, and the generated level ID for iterative editing.

**Smart Story Writer.** Source: *AI Dungeon dynamic storytelling, Roblox AI avatar customization.* When a child places stamps on the canvas, the AI analyzes the adjacency graph and auto-generates a narrative quest that binds the elements together. A dragon stamp next to a castle stamp and a princess stamp produces: "Once upon a time, a brave hero needed to rescue the royal puppy from the sleepy dragon who had curled up around the Crystal Castle!" A friendly book icon appears with a sparkle; tapping it reveals the generated story and a "Use This Story" button that sets the narrative as the level's intro text. The LLM performs stamp graph analysis to identify potential character roles and settings, generates age-appropriate prose at a 5-7 reading level, validates content for scary or inappropriate themes, auto-generates quest objectives linked to stamp positions ("reach the castle" = navigate to castle stamp coordinates), and persists story state across play sessions. The system supports branching narratives: when the child adds a "villain lair" stamp in a new area, the AI suggests a plot twist where the dragon was actually protecting the puppy from the real villain. The JSON contract captures the adjacency graph, generated narrative, reading level, TTS audio URL, and quest objective mappings.

**AI Level Balancer.** Source: *AI-powered playtesting research (Wayline 2025), procedural puzzle validation.* After a child places stamps, the AI automatically validates playability before the child ever presses play. Can the level actually be completed? Are all platform jumps reachable given the player's current movement abilities? Is the enemy density appropriate for the target age? The balancer makes its work visible but non-intrusive: subtle green glow pulses under platforms that form a valid traversal path, red dashed lines appear under gaps that exceed the player's jump range, and a gentle message appears: "I made sure your level is super fun!" The LLM backend converts the stamp layout to a traversability graph, runs an A* pathfinding agent that simulates the player's exact jump physics, calculates a predicted difficulty score based on expected completion time and death count for the target age bracket, and silently adjusts platform positions by a few pixels when gaps are near the threshold of reachability. The balancer also runs 1,000 simulated playthroughs to identify soft-locks: platforms that look reachable but require frame-perfect jumps, or doors that require keys placed behind them. When issues are found, the balancer either auto-fixes (nudges a platform closer) or surfaces a gentle suggestion to the child. The JSON contract captures the solvability graph, predicted difficulty, auto-adjustment list, and simulation completion rate.

**AI Playtest Buddy.** Source: *Deep reinforcement learning playtesting (GameDeveloper.com 2021).* A virtual robot character that plays the child's level before publication, leaving behind a trail of colorful footprints showing the path taken and placing emoji reaction stickers where it experienced frustration, delight, or confusion. The child clicks "Test My Level!" and the robot runs through at 4x speed, leaving a rainbow trail. At the end, the robot gives a thumbs-up and places three stickers: a smiley face at the fun part, a thinking face where it paused, and a star at the finish. The child can watch a replay of the robot's run to see exactly where it struggled. The LLM backend runs a reinforcement learning agent trained on platformer mechanics, capturing every position, velocity, and action in a trajectory log. Frustration is detected via death clustering analysis (died 5 times in the same spot = frustration zone), flow state is estimated via velocity variance analysis (smooth, consistent movement = flow), and emoji placement is driven by sentiment analysis of the agent's experience metrics. The Playtest Buddy is also an accessibility scanner: it identifies unreachable platforms, timing-based obstacles that are too demanding, and sections where the one-tap wonder mode would be necessary for motor-impaired players. The JSON contract captures the full agent trajectory, frustration zone coordinates, flow zone coordinates, completion time, and emoji feedback placements.

**Magic Asset Suggester.** Source: *Microsoft Copilot, GitHub Copilot context-aware suggestions.* While a child builds a level, the AI continuously analyzes the current stamp composition and suggests logical next additions. The child places a pirate ship stamp, and the stamp palette subtly highlights a water tile, a parrot, and a treasure chest with gentle sparkle animations. A small text bubble appears: "Pirates need the sea!" Tapping the highlighted water tile places it pre-positioned adjacent to the ship. The LLM maintains a stamp ontology graph modeling semantic relationships (pirate ship → water, parrot, treasure, island), applies collaborative filtering from level compositions across the community, ranks suggestions by contextual relevance, and pre-positions suggested stamps at the most logical location. The system includes suggestion cooldown to prevent fatigue: it offers at most three suggestions per minute and respects when the child ignores repeated hints. For children with executive function challenges, the suggester reduces decision paralysis by narrowing infinite possibilities to a curated few. The JSON contract captures the placed stamp ID, ranked suggestions with relevance scores, semantic relations, suggested positions, and kid-friendly rationale text.

**AI-Generated Level Descriptions.** Source: *Roblox AI Code Assist, procedural narrative generation.* When a child publishes a level, the AI auto-generates a catchy, kid-friendly title and description based on the stamps used and the level layout. The title field fills with "The Crystal Castle Adventure" and the description reads: "Help the brave bunny hop through sparkly caves to find the golden carrot!" The child can accept, edit, or regenerate. The LLM analyzes stamp inventory to identify dominant themes (3 dragon stamps + castle stamp + knight stamp = dragon-castle-knight), generates creative titles using alliteration and age-appropriate vocabulary, creates 1-2 sentence hooks emphasizing gameplay objective and mood, extracts keywords for discovery tagging (#dragons #castle #easy), and offers translations in 12+ languages. A TTS preview lets children who cannot yet read hear their level description read aloud. The JSON contract captures the stamp inventory analysis, generated title and description, auto-tags, translations, and TTS preview URL.

**AI Playtest Heatmap.** Source: *Game analytics heatmap systems, AI playtesting research.* After the AI Playtest Buddy runs through a level, it generates a visual heatmap overlay showing predicted player behavior: warm colors indicate areas where players will spend the most time, cool colors show areas that might be skipped, and red clusters highlight predicted death zones. A child can toggle the heatmap overlay in edit mode to see where their level might be too hard or too empty. The LLM aggregates thousands of simulated playthroughs into spatial probability distributions, calculates dwell time per grid cell, identifies chokepoints where progress stalls, and flags underutilized areas that could benefit from additional content. The heatmap becomes a design teaching tool: children learn to read the visual patterns and intuitively improve their level layouts. The JSON contract stores the heatmap as a 2D probability array with annotations for each flagged zone.

## 8.2 Voice & Natural Language

Voice is the most natural interface for children who cannot yet read fluently, who find typing laborious, or who simply think aloud as they create. This section covers the full spectrum of voice-powered features, from stamp placement to NPC personality generation to adaptive music composition. Every voice feature is designed with child-specific speech patterns in mind: higher pitch, variable pronunciation, incomplete sentences, and boundless imaginative vocabulary.

**Speak-to-Stamp.** Source: *Voice commands for gaming, Mage Arena voice-activated spells.* The child says a stamp name and it appears on the canvas. "Put a dragon here!" while pointing at the screen, and a dragon stamp materializes at their finger position. "Make the platforms higher!" and all platforms rise by one grid unit. "Rainbow theme!" and the level palette shifts to prismatic colors. The LLM backend runs real-time speech recognition optimized for children's voices (fine-tuned on child speech datasets covering ages 4-12), classifies the intent (PLACE_STAMP, MODIFY_LEVEL, CHANGE_THEME, PLAY_COMMAND), maps spoken words to stamp library entries via semantic similarity ("scary monster" matches the ogre stamp), resolves position references ("here" maps to the current touch point or screen center), and provides misunderstanding recovery: when confidence is low, three visual guesses appear for the child to tap. The voice model adapts to each child's speech patterns over time, improving recognition accuracy with every session. The JSON contract captures speech recognition confidence, classified intent, entity mappings, position resolution, and adaptation state.

**Voice-to-Game Commands.** Source: *Microsoft Copilot Voice, AI Dungeon.* A natural language interface for complex level operations. "Make a castle level with dragons and a lava pit" triggers the full Talk-to-Build pipeline. "Make the first half easy and the second half hard" adjusts difficulty parameters across the level midpoint. "Add a secret room behind the waterfall" stamps a sub-area entrance. The LLM parses rich multi-clause commands, extracts multiple operations, sequences them logically, and confirms execution with a summary: "I made a castle with 3 dragons, a lava pit, and a secret room!" The system supports undo by voice ("Oops, remove the lava pit") and refinement ("More dragons!" adds two more dragon stamps in appropriate positions). For children who think in stories rather than spatial layouts, voice commands remove the abstraction barrier between imagination and creation entirely.

**Voice NPC Dialog Generator.** Source: *ReadSpeaker TTS for gaming, AI voice synthesis.* Any NPC stamp placed in a level automatically receives a unique personality, a set of contextual dialog lines, and an AI-generated voice. A child places a frog stamp; the frog now introduces itself as "Freddy the Frog" with a warm, friendly baritone voice. When the player approaches, the frog says "Hop hop! You're doing great!" When the player completes a quest, the frog exclaims "Ribbit! You found my lily pad! Thank you!" The LLM assigns a personality archetype based on stamp type (frogs are friendly and encouraging, dragons are proud but fair, robots are logical and helpful), generates 5-10 contextual dialog lines using the personality and level context, synthesizes speech via a TTS engine with emotion tags (happy, sad, excited, calm), and generates lip-sync animation data for speaking sprites. Each NPC's voice is unique: a voice fingerprint hash ensures that no two frogs sound identical. The JSON contract captures personality archetype, all dialog lines with triggers and emotion tags, voice ID, and lip-sync phoneme data.

**Auto-Music Composer.** Source: *Suno/Udio AI music generation, No Man's Sky procedural score.* AI generates a unique, seamlessly looping soundtrack for each level based on its biome theme, mood, and stamp composition. As a child creates a spooky cave level, the music becomes mysterious and minor-key. When they add a treasure chest, a bright chime layer joins. During play, the music swells during tricky platforming sections and relaxes in safe zones. The LLM analyzes stamp composition for mood extraction (dark stamps = minor key; bright stamps = major key; dense enemy placement = faster tempo), constructs a music generation prompt specifying genre, tempo, key, and mood, generates a track via an API, auto-edits it to a seamless loop using beat detection, separates stems into 3-4 layers (melody, rhythm, ambience, effects), and drives a runtime mixer that layers stems based on gameplay intensity. The system crossfades between layers at bar boundaries so transitions are musically smooth. A visual stem indicator shows active music layers as colored bars for deaf and hard-of-hearing children. The JSON contract captures mood analysis, all stem audio URLs with intensity ranges, loop metadata, and the current mixer state.

**Voice-Recorded Sound Effects.** Source: *WarioWare D.I.Y. sound recorder.* Children record their own voice to create custom sound effects for stamps. A monster stamp can use the child's "Raaaar!" recording; the AI pitch-shifts it lower and adds a subtle reverb to make it sound appropriately big but not scary. A fairy stamp uses the child's giggle pitched up with a sparkly effect. The LLM handles recording with a 5-second limit and noise gate, detects the child's voice signature to reject accidental non-voice recordings, applies context-appropriate effects (monster = lower pitch + reverb, fairy = higher pitch + sparkle, robot = vocoder), normalizes volume to safe levels, and manages the per-user sound effect library. All recordings pass through a parent moderation queue before being available for sharing. The JSON contract stores recording metadata, applied effects, normalized volume, and moderation status.

**Read-to-Me Everything.** Source: *The Last of Us Part II TTS system.* Every text element in the entire application, menus, dialog boxes, story text, level descriptions, settings labels, and tutorial instructions, can be read aloud via high-quality text-to-speech. A child taps any text and a warm, kid-appropriate voice reads it aloud. Menu items announce themselves when highlighted. Story text auto-reads with word-by-word visual highlighting synchronized to the audio. The LLM tags every UI element for TTS eligibility, handles tap-to-speak events, manages a TTS engine with kid-optimized voice profiles, provides word-level synchronization for visual highlighting, supports speed control from 0.5x to 2.0x playback (turtle to rabbit slider), auto-detects language, and offers 20+ language voices. Voice profiles include friendly male, friendly female, and character voices (wise wizard, cheerful fairy). The JSON contract stores TTS preferences, selected voice profile, playback speed, highlighting toggle, and auto-read settings.

**Voice Name Everything.** Source: *Speech-to-text naming systems.* Children name their levels, characters, and creations by speaking rather than typing. A child taps the name field and says "Dragon Mountain" ; the text fills in, and the AI reads it back for confirmation: "Your level is called Dragon Mountain! Want to keep it?" The LLM runs a child-optimized ASR model, applies safety filtering to all transcriptions, auto-capitalizes and adds basic punctuation, suggests fun alternatives for generic names ("Dragon Mountain" could become "Dragon Mountain Adventure" or "The Fiery Peak"), performs phonetic similarity checks to catch accidental inappropriate homophones, and plays a voice confirmation before saving. Translation support enables multilingual children to name creations in any supported language. The JSON contract captures the transcription, safety filter status, auto-punctuation flag, LLM suggestions, phonetic check result, and voice confirmation URL.

## 8.3 Procedural Generation

Procedural generation is the engine of infinite variety: it ensures that no two playthroughs are identical, that children always have fresh content to explore, and that the creative process can begin from inspiration rather than a blank canvas. This section covers the complete procedural generation stack, from room-based level assembly to enemy behavior scaling to quest auto-weaving.

**Chunk-Based Level Generator.** Source: *Spelunky 2, Dead Cells.* The child selects a theme (Forest, Castle, Space, Underwater, Candy Land) and the AI generates a complete platformer level from hand-designed room "chunks" that are procedurally arranged and populated. A child taps "Make Me a Level!" and picks "Jungle"; a full level appears with a start point, platforms, enemies, and goal flag. Every tap generates a completely different layout while maintaining consistent quality. The LLM backend maintains a template library of 50+ hand-designed room chunks per biome: start rooms, combat rooms, platforming challenges, rest rooms, treasure rooms, and boss rooms. A graph-based layout generator ensures a valid path from start to goal, a difficulty curve algorithm spaces challenges progressively (easy rooms early, harder rooms later), a stamp population engine fills rooms with biome-appropriate stamps, and a validation engine ensures solvability via pathfinding. Each generated level has a seed, allowing "remix this level" functionality that produces a deterministic variant. The JSON contract captures the selected biome, room chunk list, level graph, seed, generated stamp positions, and difficulty curve profile.

**Biome World Generator.** Source: *No Man's Sky, Terraria.* Generates entire 2D worlds with multiple biomes, terrain features, cave systems, and weather patterns using multi-octave Perlin noise. A child spins a "World Wheel" and lands on "Ice Cream Canyon"; a sprawling landscape generates with candy ground, ice cream mountain stamps, sprinkle particle effects, and a discovery checklist ("Find the Secret Crystal Cave!"). The LLM generates heightmaps and biome masks from noise functions, applies biome transition smoothing for natural borders, generates cave systems via cellular automata, places stamps procedurally (trees on grass, crystals in caves, snowmen on ice), assigns weather effects per biome, and auto-generates a discovery checklist of landmarks and secrets. Each world is unique but navigable, with terrain edges that are always predictable and haptic feedback on boundary transitions. The JSON contract stores the world seed, biome mask, heightmap, cave system entrances, placed stamps with biome associations, weather assignment, and discovery checklist.

**Procedural Enemy Scaling.** Source: *Risk of Rain 2, Diablo.* Enemy stamps automatically scale their behavior complexity based on their position in the level and the player's demonstrated skill history. Early enemies simply walk back and forth. Enemies near the end patrol platforms and jump over gaps. If the child has beaten many levels, enemies get cuter accessories (a tiny hat, sparkly glasses) while being slightly smarter. The LLM assigns enemy tiers based on distance-from-start, adjusts base difficulty from a player skill history model (win rate, death count, completion time), scales behavior tree complexity across four tiers (patrol → patrol+jump → chase+jump → all+projectiles), and adds visual differentiation via accessories to signal tier without being scary. The scaling is invisible: children simply feel that the game is fair and matched to their abilities. The JSON contract stores each enemy's assigned tier, behavior tree type, skill adjustment factor, visual accessory, and stat multipliers.

**Smart Room Connector.** Source: *Binding of Isaac, dungeon generation algorithms.* When a child stamps individual room shapes on the canvas, the AI automatically generates connecting corridors, ensures every room is reachable, and places doors at logical connection points. A child stamps a bedroom, a kitchen, and a garden; the AI draws cute doorways between them with hallway stamps matching the room themes. The LLM detects room bounding boxes from stamp clusters, applies a Minimum Spanning Tree algorithm to connect rooms with shortest valid corridors, places doors at closest wall points, selects corridor stamp themes to match connected rooms, adds optional bonus paths for exploration, and validates that no room is isolated. This system removes the need for precise spatial planning: children think in rooms, and the AI handles the plumbing. The JSON contract captures room boundaries, all connections with corridor stamp lists, door positions, and reachability validation status.

**Procedural Quest Weaver.** Source: *Procedural quest generation research (ScienceDirect 2022).* The AI generates mini-quest chains based on the stamps present in a level. A cat stamp, a tree stamp, and a fish stamp produce: "Find the cat (at the tree) → Catch the fish → Feed the cat." A puppy stamp and a bone stamp produce: "Help the puppy find his bone!" The LLM tags stamps with semantic roles (animal = quest giver/seeker, item = objective, location = destination), chains objectives into logical sequences (fetch, delivery, escort, find), assigns rewards proportional to quest complexity, tracks progress with visual indicators, and generates quest text at the appropriate reading level. Quests can branch: presenting the bone to the puppy might trigger a follow-up quest to find the puppy's house. Visual arrows point toward quest targets, providing clear direction for children who need structured goals. The JSON contract captures the stamp semantic roles, quest chain with step descriptions and target stamps, quest type, branching paths, and visual arrow configuration.

**Remix Generator.** Source: *No Man's Sky seed regeneration, Mario Maker course remix.* The AI takes any existing level and generates a remixed version with a different biome, rearranged elements, added challenges, or a converted game mode. A child taps "Remix!" on their forest level and it transforms into a winter wonderland: trees become pine trees, ground becomes snow, enemies wear tiny scarves, and a "Time Attack!" crown appears for racing a ghost to the finish. The LLM parses the level structure to extract the platform graph and challenge sequencing, applies biome swap by replacing all stamps with themed equivalents (tree → palm tree, rock → coral), applies challenge modifiers (time attack adds a ghost racer, collectathon scatters coins), preserves the original difficulty level, maintains a seed for reproducibility, and tracks remix lineage for attribution. Remixing supports children with cognitive differences by providing fresh content from familiar foundations, reducing creative starting anxiety while teaching level design through variation. The JSON contract stores the source level ID, remix type, seed, stamp swap mappings, and lineage chain.

**Procedural Background Generator.** Source: *Terraria parallax backgrounds, Dreams scene backdrop.* The AI generates layered parallax backgrounds unique to each level's theme and stamp composition. A child creates a space level and the background generates with twinkling star layers at different depths, distant nebulae in soft purples, and occasional shooting stars. Adding more enemy stamps introduces subtle dark clouds in the background. The LLM maps stamp density and types to background layer parameters: more trees = denser forest backdrop, more water = reflective surface layers, enemy density = atmospheric tension (storm clouds for high danger, rainbow for peaceful). Each layer scrolls at a different parallax speed, creating convincing depth. The system generates backgrounds procedurally from theme descriptors, ensuring every level has a unique visual atmosphere without requiring any artistic input from the child.

## 8.4 Adaptive Intelligence

Adaptive Intelligence is the invisible hand that ensures every child succeeds, regardless of their physical abilities, cognitive style, or prior gaming experience. These features never announce themselves; they simply create an experience where the child always feels capable, challenged appropriately, and supported. Drawing from Left 4 Dead's legendary AI Director, Celeste's groundbreaking assist mode, and Mario Kart's rubber-banding, this section defines the most sophisticated yet invisible systems in KidGameMaker.

**Invisible Helper Fairy.** Source: *Left 4 Dead AI Director, Resident Evil 4 dynamic difficulty.* An always-on system that invisibly adjusts game parameters in real-time based on player performance. When a child struggles with a jump sequence, platforms subtly extend their timing windows by 0.2 seconds. An enemy's fireball moves 10% slower. A hidden bounce pad materializes under likely fall zones. When the child is succeeding, everything runs at normal parameters. No visible indicators announce these adjustments: the child simply feels capable. The LLM backend runs a continuous performance telemetry pipeline tracking death rate per section, completion time variance, and input precision. A stress detector analyzes input patterns (rapid button mashing = frustration; smooth inputs = flow). The parameter adjustment engine modifies 15+ invisible variables: platform timing extensions, enemy speed, projectile velocity, checkpoint density, hint frequency, and collectible magnetism. Adjustments are rate-limited to 5% per death to prevent sudden perceptible changes, with ceiling and floor caps ensuring the game never becomes trivial or impossibly hard. The child's typical skill band persists across sessions, so returning players find the game calibrated to their growth. The JSON contract stores the current stress level, all adjustment values, rate limits, difficulty caps, and session persistence band.

**Smart Tutorial Whisperer.** Source: *AI-generated tutorials, adaptive hint systems.* The AI observes where a child struggles and generates contextual, just-in-time tutorial hints delivered by a friendly mascot character. When a child keeps falling in the same pit, a friendly owl pops up: "Try jumping while running: hold the blue button and press the green button together!" The owl demonstrates with a ghost animation, then watches the child try. On success, the owl cheers and disappears. The LLM clusters death events to identify repeated failure locations, classifies failure mode (missed jump, didn't see enemy, wrong timing, confusion), generates age-appropriate hint text matched to the failure mode, creates a ghost replay demonstration, and optimizes delivery timing via flow-state detection: hints never interrupt during success streaks. Hint frequency is personalized per child: some children want frequent guidance, others prefer to figure things out independently. The system learns each child's preference and adapts. The JSON contract captures failure cluster data, failure mode classification, generated hint text and format, delivery timing, and owl character state.

**Smart Checkpoint Dropper.** Source: *Celeste Assist Mode, Left 4 Dead relax phases.* The AI analyzes death patterns and automatically adjusts checkpoint placement to minimize frustration while preserving challenge. When a child falls in a pit three times, a glowing checkpoint flag appears just before it with a sparkle animation that frames it as a discovered reward. "Woohoo, I'm getting farther!" The child feels improvement, not assistance. The LLM maintains a death heatmap tracking failure clustering, calculates a checkpoint need score from death density and time since last checkpoint, positions the checkpoint at the nearest safe platform before the death zone, and uses a cooldown requiring at least three attempts before triggering to prevent checkpoint spam. As the child succeeds consistently, checkpoints subtly space out, gradually returning the level to its original challenge curve. The JSON contract stores the death heatmap, checkpoint need score, suggested position, trigger attempt threshold, cooldown state, and gradual removal rate.

**Emotional Flow Guardian.** Source: *Left 4 Dead AI Director intensity tracking, RE4 dynamic difficulty.* The AI monitors the child's emotional state via play patterns and orchestrates level pacing to maintain an optimal challenge-relaxation cycle. After a tricky series of jumps, the child enters a calm section with floating coins, gentle music, and no enemies. Then the path narrows for the next challenge. The rhythm feels like a fun roller coaster: exciting but never overwhelming. The LLM classifies flow state from death rate, input consistency, completion velocity, and pause frequency. A three-phase cycle manager alternates BUILD_UP (increasing challenge), PEAK (maximum safe challenge), and RELAX (easy recovery section). During RELAX phases, the system dynamically injects rest platforms, coin bonuses, and safe zones. During BUILD_UP phases, challenge ramps through tighter jumps and more enemies. If stress exceeds a threshold, an immediate RELAX phase triggers as an override. Cycle timing personalizes to each child's typical emotional recovery speed. The JSON contract captures current phase, flow score, stress threshold, phase timing configuration, dynamic injection list, and stress override status.

**Ghost Racer Friend.** Source: *Mario Kart Time Trial ghost system, Forza Drivatar.* The AI generates a friendly ghost character that runs through the level at a pace matched to the child's best time plus a small challenge margin. The ghost is translucent and sparkly, wearing a cute hat to distinguish it from the player. "Can you catch your ghost?" When the child beats the ghost, it claps enthusiastically and gives a high-five animation. If the child never catches the ghost, it subtly slows by 2% each attempt until the race feels close and winnable. The LLM records the child's best trajectory with timing, sets ghost pace to best_time * 0.95 for gentle challenge, scripts supportive reactions (claps on kid win, waves encouragingly when ahead), applies dynamic pace adjustment based on catch rate, and triggers celebration choreography on kid victory. The ghost provides implicit teaching: children learn optimal paths by watching their own previous best, making improvement feel organic. The JSON contract stores the ghost path, pace multiplier, best time, supportive behavior configuration, visual differentiation, and adjustment parameters.

**Rubber Band Buddy System.** Source: *Mario Kart rubber-banding, Forza Drivatar.* In any competitive or cooperative mode, AI companions and opponents automatically adjust their performance to stay near the child's skill level, never too far ahead or behind. If the child falls behind in a race, the AI friend "trips" on a banana peel (plausibly). If the child is ahead, the AI friend catches up with a determined expression and a tiny speed boost. The race always feels close and exciting, and the AI friend celebrates the child's win more enthusiastically than its own. The LLM tracks position delta between child and AI in real-time, applies subtle speed adjustments via a rubber band force function, selects plausible failure animations when the AI needs to slow down (trip, stop to look at a butterfly, take a wrong path briefly), and scripts emotional reactions that always frame the child as the winner regardless of outcome. A parental setting can disable rubber-banding for competitive play between skilled siblings. The JSON contract stores position delta, rubber band force, AI behavior selection, emotional script, and parental competitive mode toggle.

**Virtual Co-Pilot.** Source: *Microsoft Copilot Voice, Siri/Alexa in-game assistant.* A friendly AI companion character (customizable robot, wizard, or animal) that floats at the edge of the screen and responds to natural language requests. "I'm stuck..." "Want me to show you a hint? Or should I try the tricky part for you?" "Show me a hint!" The Co-Pilot demonstrates a ghost jump. "Thanks!" "You got it! Let me know if you need anything else!" The LLM backend runs a conversational model fine-tuned on kid-friendly game assistance, with full awareness of the current game state: level layout, player position, recent deaths, and available abilities. The Co-Pilot routes intents to hint generation, play demonstration, creative suggestions, or emotional support. All responses pass through a safety filter ensuring age-appropriateness and positive framing. The Co-Pilot remembers the child's preferences and past conversations across sessions, building a genuine sense of companionship. A parent dashboard shows all Co-Pilot conversations for safety oversight. The JSON contract captures the companion ID, selected personality, conversation history, game state access flag, intent routing, safety filter status, and persistent memory.

**Daily Surprise Box.** Source: *Kid-friendly daily reward systems.* Each day a child logs in, they open a surprise box containing a random creative reward: a new stamp, a filter, a costume piece, or a scrapbook sticker. The box shakes, pops open with confetti, and announces the reward: "You got the Sparkle Unicorn Stamp!" The LLM manages a reward pool of 500+ collectible items, applies weighted random selection favoring items that match the child's play patterns (jungle level builders receive jungle-themed rewards), implements streak bonuses for consecutive days, converts duplicates to "shiny" versions after 7 days, generates excitement text for each drop, and choreographs animation to reward rarity. There are no consumables, no pay-to-win mechanics, and no monetization: every reward is a creative tool. The JSON contract stores reward pool categories, personalization weights, streak multiplier, duplicate protection days, animation choreography, and monetization-free guarantee.

**Parent Magic Mirror.** Source: *Xbox Family Settings, parental dashboard analytics.* A companion app where parents view their child's creative activity with pride-focused framing. Weekly summaries read: "This week Jordan created 4 levels and discovered the Jungle theme! Their favorite stamp was the Fire Dragon." The LLM aggregates activity data (levels created, play time, stamps used, stories written), generates natural-language weekly summaries, identifies "pride moments" where the child's work is particularly creative or shows improvement, and suggests conversation starters: "Ask Jordan about the story they wrote for their castle level!" The dashboard is celebration-only: no punitive metrics, no guilt-inducing screen time warnings. Safety alerts trigger only for genuinely concerning patterns. Accessibility settings can be managed remotely, and parents of children with disabilities can monitor which assist features are active and how their child is progressing. The JSON contract stores the weekly summary with all metrics, LLM-generated narrative, safety alerts, pride moments, conversation starters, and accessible settings management.

**Season of Wonder.** Source: *Seasonal content events, kid-safe event design.* Monthly themed events bring fresh stamps, music, and decorations: "Space Month," "Dinosaur Discovery," "Under the Sea." The home screen transforms with gentle thematic decorations. New themed stamps appear in the palette. Special event challenges feed into the Achievement Scrapbook. Critically, there is no FOMO: all content becomes permanently available after the event ends. The child simply keeps everything. The LLM rotates 12 pre-planned themes, generates theme-specific stamp packs (20-30 new stamps per theme), creates AI-generated theme music and ambient soundscapes, themes the home screen with background and mascot costume changes, generates LLM-written theme narratives and character dialogs, and ensures post-event permanence. The predictable monthly rhythm helps children who benefit from routine, while the novelty of new content maintains engagement without changing core mechanics. The JSON contract stores the current theme, new stamp list, theme music URL, home screen theme, event challenges, and the fomo-free permanence flag.

**Magic Photo Studio.** Source: *Game photo modes (Cyberpunk 2077, Blue Protocol).* Children freeze gameplay at any moment and enter a photo editing mode with filters, stickers, frames, and drawing tools. The AI suggests fun compositions: "Add confetti!" "Put a crown on the character!" A child taps the camera icon during play, the game freezes with a click sound, and they can drag the camera, apply filters ("Make it rainbow!" "Make it spooky!"), add stickers, and draw on top. The LLM captures frames at 60fps with instant freeze, applies 20+ kid-friendly filters (rainbow, vintage, comic book, sparkle, underwater), manages a sticker library searchable by description, analyzes the frame to propose three fun composition arrangements, auto-detects the character position for best crop suggestions, and handles sharing through COPPA-compliant family-only channels. The JSON contract captures filter selections, applied stickers, AI suggestions, crop recommendation, and share target configuration.

**Magic Music Weaver.** Source: *iMUSE (LucasArts), FMOD adaptive audio.* AI-generated music that transitions seamlessly between moods and intensities based on gameplay state. Using stem-based architecture, individual instrument layers fade in and out dynamically as the child plays. Exploring a calm forest, gentle flutes and soft drums play. Encountering an enemy, drums intensify and brass joins. Defeating the enemy, everything calms. The transitions are so smooth that the child simply feels the mood shift. The LLM splits each generated track into 4-6 stem layers (melody, harmony, rhythm, percussion, effects), classifies game state to an intensity score (0.0 = calm exploration, 1.0 = intense combat), crossfades stems based on intensity with bar-boundary synchronization, generates AI transition fills for musical continuity between states, and applies dynamic tempo shifts (slows 5% during pause-and-think mode). A visual stem indicator shows active music layers as colored bars for deaf and hard-of-hearing children, and haptic feedback syncs to the percussion beat. The JSON contract stores all stems with intensity ranges, current intensity, mixer state, transition fill catalog, and tempo adaptation settings.

**Push-Notify Playdate.** Source: *COPPA-compliant creative prompts.* Parent-approved push notifications deliver creative prompts and social updates: "What will you build today?" or "Alex shared a new level with you!" Never monetization-focused. Never external links. The LLM personalizes prompts based on recent activity: "Last time you built a castle — try adding a dragon!" Parents control frequency (daily, weekly, off) and content type (rewards, social, creative prompts). Delivery timing optimizes for the child's typical play window. All notifications use fun character icons and gentle language, never pressure or urgency. The JSON contract captures notification templates, personalized prompt, parent controls, delivery window, and the zero-monetization guarantee.


---

# Chapter 9: Accessibility & Assist Features

> **"Every child can play. Every child can create. No exceptions."**
>
> This chapter documents 25+ features that ensure KidGameMaker is universally accessible to children of all abilities. Accessibility is not a stretch goal or a Phase-D afterthought — it is a foundational design pillar that permeates every system. Every feature in this chapter draws from industry-leading accessibility innovations, adapted for a stamp-based creation tool where a 5-year-old is the primary user.

---

## 9.1 Visual Accessibility

### Super See Mode

| Field | Details |
|-------|---------|
| **Feature Name** | Super See Mode |
| **Source Game** | The Last of Us Part II (Naughty Dog, 2020) — High Contrast Display |
| **Description** | Transforms any level into a high-contrast mode where interactive elements are clearly color-coded: platforms glow bright blue, enemies are outlined in red, collectibles pulse gold, and hazards flash orange. Background layers desaturate to soft gray, eliminating visual clutter. |
| **Kid UX** | A 5-year-old opens the Magic Settings menu and taps the rainbow glasses icon. The colorful background instantly fades to soft gray while all important game elements pop with bright, clear colors and thick outlines. "Everything is so easy to see now!" The child can still play normally — only the visuals have changed. |
| **LLM Automation** | Backend: (1) Stamp category classifier tags every element at level-load time into semantic categories (platform, enemy, collectible, hazard, NPC, background); (2) Color palette assignment per category uses accessibility-safe colors meeting WCAG AAA contrast ratios; (3) Outline renderer adds 3px stroke to all interactive elements; (4) Background shader desaturates and dims non-interactive layers to 15% saturation; (5) Glow post-processing effect on collectibles and hazards at 60fps; (6) Persistent per-child preference saved to cloud profile. |
| **JSON Contract Extension** | `{"super_see_mode": {"enabled": "boolean", "category_colors": {"platform": "#0066FF", "enemy": "#FF0000", "collectible": "#FFD700", "hazard": "#FF8800", "npc": "#00FF00"}, "outline_width_px": "3", "background_desaturation": "0.85", "glow_intensity": "float", "colorblind_preset": "protanopia|deuteranopia|tritanopia|none"}}` |

**Why It Matters:** Super See Mode is the single most impactful visual accessibility feature in KidGameMaker. The Last of Us Part II set the industry standard with over 60 accessibility options; KidGameMaker adapts its crown jewel for children. A child with low vision can suddenly see platforms they would otherwise miss. A child with ADHD can focus on gameplay-relevant elements without distracting background detail. The WCAG AAA contrast ratios ensure compliance with the highest international accessibility standards.

---

### Colorblind Palette Adaptation

| Field | Details |
|-------|---------|
| **Feature Name** | Colorblind Palette Adaptation |
| **Source Game** | The Last of Us Part II (2020) — colorblind presets for Protanopia, Deuteranopia, Tritanopia |
| **Description** | Three distinct color-remapping profiles that shift the entire game's palette to compensate for the three major types of color vision deficiency. Each profile is independently selectable and previewed in real-time. |
| **Kid UX** | Parent opens the accessibility menu and selects "See Colors Better." Three friendly animal icons appear: Bear (for red-green help), Fox (for green-red help), and Owl (for blue-yellow help). Tapping each instantly previews the color shift on a sample scene. The child picks the one that looks clearest to them. |
| **LLM Automation** | Backend: (1) Daltonization algorithm remaps RGB values per colorblind type using LMS color-space transformation; (2) Pattern and texture differentiation added where color alone conveys information (striped platforms, dotted enemies); (3) Shape cues supplement color-coded elements; (4) Universal design verification ensures every color-coded mechanic has a non-color visual indicator. |
| **JSON Contract Extension** | `{"colorblind_mode": {"type": "protanopia|deuteranopia|tritanopia|none", "daltonization_strength": "float(0-1)", "pattern_supplement": "boolean", "universal_design_check": "boolean"}}` |

---

### Sound-to-Light Translator

| Field | Details |
|-------|---------|
| **Feature Name** | Sound-to-Light Translator |
| **Source Game** | The Last of Us Part II — awareness indicators for deaf/hard-of-hearing players |
| **Description** | All audio events — enemy footsteps, collectible chimes, hazard alarms, approaching projectile whooshes — are translated into visual indicators: directional pulses emanate from the sound source, on-screen ripples indicate distance, and color flashes communicate urgency. |
| **Kid UX** | An enemy approaches from the left side of the screen. A gentle blue ripple emanates from the left edge, growing larger as the enemy gets closer. A collectible coin sits on a high platform — it pulses with a golden glow even when off-screen, with an arrow pointing toward it. The child sees everything they need to, even in silent mode. |
| **LLM Automation** | Backend: (1) Audio event classification tags all sounds with type (footstep, collect, hazard, projectile) and spatial direction; (2) Visual indicator selector maps sound categories to visual patterns — direction ripple for movement, glow pulse for collectibles, orange flash for hazards; (3) Indicator intensity scales with audio volume and proximity; (4) Off-screen edge indicators show arrows pointing toward important sounds outside the viewport; (5) Character portrait in the corner reacts with facial expressions (surprised = danger, happy = collectible) for emotional context. |
| **JSON Contract Extension** | `{"sound_to_light": {"indicator_types": [{"sound_category": "string", "visual_pattern": "ripple|glow|flash|arrow", "color": "string", "directional": "boolean"}], "edge_indicators": "boolean", "character_portrait_reactions": "boolean", "intensity_scale": "float(0-1)"}}` |

---

### Screen Edge Directional Indicators

| Field | Details |
|-------|---------|
| **Feature Name** | Screen Edge Directional Indicators |
| **Source Game** | Fortnite (visualize sound effects), TLOU2 (awareness indicators) |
| **Description** | Thin colored bars appear at the screen edges to indicate the direction of off-screen sounds and important events. The bar's height represents proximity, and its color represents event type. |
| **Kid UX** | The child hears (or sees via Sound-to-Light) a treasure chest somewhere to the right, off-screen. A small golden bar rises on the right edge of the screen, pulsing gently. As the child moves closer, the bar grows taller. When the chest enters the screen, the bar fades away. |
| **LLM Automation** | Backend: (1) Spatial audio analysis determines direction and distance to sound sources; (2) Edge bar renderer places indicators on appropriate screen borders; (3) Height interpolation based on proximity with exponential falloff; (4) Color mapping tied to KidGameMaker's semantic color system; (5) Fade-out when source enters viewport. |
| **JSON Contract Extension** | `{"edge_indicators": {"enabled": "boolean", "bar_max_height_px": "40", "proximity_sensitivity": "float", "fade_on_viewport_enter": "boolean", "color_map": {"collectible": "#FFD700", "enemy": "#FF0000", "hazard": "#FF8800"}}}` |

---

### Sensitivity Safe Zone

| Field | Details |
|-------|---------|
| **Feature Name** | Sensitivity Safe Zone |
| **Source Game** | Xbox Adaptive Controller philosophy, TLOU2 motion sickness options, sensory-friendly game design |
| **Description** | A comprehensive sensory control panel that allows parents and children to reduce or eliminate screen shake, flashing effects, particle density, motion blur, camera dolly zoom, and loud sounds. Includes a persistent center-dot option for spatial grounding. |
| **Kid UX** | Parent opens "Comfort Settings" and sees simple picture toggles: a shaking phone icon for screen shake, a lightning bolt for flashing effects, confetti for particles, a speaker for loud sounds. Each toggle has three positions: Full (normal), Gentle (reduced), and Off. Changes apply instantly — the child never sees an overwhelming effect. |
| **LLM Automation** | Backend: (1) All visual effects tagged with intensity categories at asset-import time (shake, flash, motion, particles, dolly_zoom); (2) Effect renderer reads comfort settings and applies attenuation multipliers; (3) Flashing effects converted to gentle fade when set to reduced; (4) Particle culling scales max particle count by setting level; (5) Audio limiter hard-caps at 70dB for gentle setting; (6) Center dot renderer always-on when enabled; (7) Per-child comfort profile auto-loaded on login. |
| **JSON Contract Extension** | `{"sensitivity_safe": {"screen_shake": "full|reduced|off", "flashing_effects": "full|dim|off", "particle_density": "full|reduced|minimal", "motion_blur": "full|reduced|off", "sound_volume_cap_db": "70|80|90", "center_dot": "boolean", "dolly_zoom": "on|off"}}` |

---

### Font Size & Dyslexia-Friendly Reader

| Field | Details |
|-------|---------|
| **Feature Name** | Font Size & Dyslexia-Friendly Reader |
| **Source Game** | Industry best practice — OpenDyslexic font research |
| **Description** | All in-game text can be scaled to 150% and 200% sizes. A dyslexia-friendly font mode switches all UI text to a weighted typeface designed to reduce character rotation confusion (b/d/p/q distinction). Word-spacing increases and line-height expands for easier reading. |
| **Kid UX** | The child taps the "Bigger Words" button in settings. All text in menus, dialogue boxes, and story blocks grows larger. If dyslexia-friendly mode is on, the letters become slightly heavier at the bottom, making them easier to distinguish. Dialogue boxes widen to accommodate longer lines with more breathing room. |
| **LLM Automation** | Backend: (1) Dynamic font scaling system reflows all UI containers at 1.5x and 2.0x sizes; (2) OpenDyslexic-weighted font family loaded on toggle; (3) Word-spacing and line-height CSS variables adjusted; (4) Container bounds recalculated to prevent text overflow; (5) Combined with Read-to-Me Everything for multimodal text support. |
| **JSON Contract Extension** | `{"font_accessibility": {"scale_factor": "1.0|1.5|2.0", "dyslexia_font": "boolean", "word_spacing_px": "int", "line_height_multiplier": "float"}}` |

---

## 9.2 Motor Accessibility

### One-Tap Wonder Mode

| Field | Details |
|-------|---------|
| **Feature Name** | One-Tap Wonder Mode |
| **Source Game** | Xbox Adaptive Controller support paradigm, one-button games design |
| **Description** | The entire platformer controlled with a single input — anywhere on screen. The character auto-runs forward; the child only decides WHEN to jump by tapping anywhere. The AI handles all movement direction, obstacle avoidance, and timing automatically. |
| **Kid UX** | The child taps anywhere on the screen and their character jumps over the next obstacle. The character runs forward automatically and even slows down before tricky jumps. A gentle highlight appears under the character when a jump is approaching, giving a subtle timing cue. If the child doesn't tap, the character stops at edges rather than falling. |
| **LLM Automation** | Backend: (1) Auto-run system moves character forward at optimal speed; (2) Jump cue predictor analyzes upcoming terrain and provides visual highlight 0.5s before recommended jump time; (3) Auto-pilot steering guides character toward safe paths when multiple routes exist; (4) Jump timing auto-correction within a 100ms forgiveness window; (5) Edge detection ensures character stops before cliffs if no tap received; (6) Graduated mode can add a second tap region for "high jump" as the child builds skill. |
| **JSON Contract Extension** | `{"one_tap_mode": {"input_type": "single_tap|adaptive_switch|eye_gaze", "auto_run_speed": "float", "jump_cue_highlight": "boolean", "auto_correct_window_ms": "100", "edge_stop": "boolean", "graduated_second_tap": "boolean"}}` |

---

### Auto-Pilot Companion

| Field | Details |
|-------|---------|
| **Feature Name** | Auto-Pilot Companion |
| **Source Game** | Celeste Assist Mode (infinite dashes, slowdown), TLOU2 traversal assistance |
| **Description** | A toggleable companion creature — shaped as a firefly, robot, or butterfly — that assists with specific actions the child finds challenging. The companion can catch the player if they fall, suggest jump timing through brightness pulses, provide soft auto-aim for projectiles, and even demonstrate difficult sections as a ghost replay. |
| **Kid UX** | A cute glowing firefly follows the character. When a difficult jump approaches, the firefly glows brighter and pulses — the child knows to jump on the brightest pulse. If the child misses the jump, the firefly catches them and gently lifts them to the platform. "The firefly saved me!" The child can choose to let the firefly "show how it's done" and watch a demonstration anytime. |
| **LLM Automation** | Backend: (1) Multi-assist module system: catch_assist, aim_assist, timing_assist, demo_assist — each independently toggleable; (2) Catch trigger activates when fall trajectory intersects with a safe platform within catch radius; (3) Aim assist provides soft lock-on to nearest enemy with gradual acquisition (never snapping); (4) Timing assist encodes recommended jump moment in firefly pulse frequency; (5) Demo mode records optimal AI path and plays it as ghost demonstration with narration; (6) Assist intensity slider from "gentle hint" to "full help." |
| **JSON Contract Extension** | `{"auto_pilot": {"companion_type": "firefly|robot|butterfly", "active_assists": [{"assist_id": "catch|aim|timing|demo", "intensity": "float(0-1)"}], "catch_prediction": {"fall_detected": "boolean", "safe_platform_nearby": "boolean"}, "demo_mode": {"optimal_path": [{"x": "float", "y": "float"}], "playback_speed": "float"}}}` |

---

### Pause-and-Think Mode

| Field | Details |
|-------|---------|
| **Feature Name** | Pause-and-Think Mode |
| **Source Game** | Cognitive accessibility best practices, TLOU2 slow motion while aiming |
| **Description** | Game time freezes automatically whenever the child stops providing input for a configurable duration (default 2 seconds). The freeze allows unlimited planning time. Time resumes smoothly when the child acts. Smart triggers can also auto-freeze when an enemy is spotted or a hazard is detected. |
| **Kid UX** | The child reaches a tricky platforming section and pauses to think. The screen gently softens with a subtle vignette, and a small "Thinking Time" badge appears. The character stays frozen mid-action. The child studies the layout, plans their moves, and presses jump — everything resumes smoothly. No pressure. Think as long as needed. |
| **LLM Automation** | Backend: (1) Input idle timer triggers pause at configurable threshold (default 2s, range 1-10s); (2) Smooth time dilation: gameplay slows to freeze over 0.3s for a gentle transition; (3) Visual feedback via soft vignette and optional "Thinking Time" badge; (4) Smart freeze triggers: enemy enters proximity, hazard detected, branching path available; (5) Resume on any input with 0.1s ease-in; (6) Parental override for freeze conditions and duration. |
| **JSON Contract Extension** | `{"pause_think": {"freeze_trigger": "idle_timer|enemy_proximity|hazard|branching_path", "idle_threshold_seconds": "float", "time_dilation_speed": "0.3", "smart_freeze_enabled": "boolean", "resume_ease_in_seconds": "0.1", "parental_override": "boolean"}}` |

---

### Jump Timing Highlight

| Field | Details |
|-------|---------|
| **Feature Name** | Jump Timing Highlight |
| **Source Game** | Rhythm game visual cue systems, platformer accessibility mods |
| **Description** | A predictive visual cue that appears at the edge of platforms, indicating the optimal moment to press the jump button. The cue takes the form of a pulsing ring or bouncing arrow that peaks at the ideal frame. |
| **Kid UX** | The child approaches a gap between platforms. A soft glowing ring appears at the platform edge, pulsing gently. The child learns to press jump when the ring is at its brightest and largest. After a few successful jumps, they start to feel the rhythm naturally and can turn the cue down or off. |
| **LLM Automation** | Backend: (1) Trajectory prediction calculates required jump velocity for each gap; (2) Timing cue renders as pulse animation peaking at optimal jump frame; (3) Cue intensity adjustable from subtle glow to prominent arrow; (4) Adaptive fading: cue reduces prominence automatically as the child demonstrates consistent success; (5) Disabled automatically when One-Tap Wonder Mode is active. |
| **JSON Contract Extension** | `{"jump_timing_highlight": {"visual_style": "pulse_ring|bounce_arrow|sparkle_line", "intensity": "subtle|medium|prominent", "adaptive_fade": "boolean", "peak_frame_offset": "int"}}` |

---

### Adaptive Controller & Switch Support

| Field | Details |
|-------|---------|
| **Feature Name** | Adaptive Controller & Switch Support |
| **Source Game** | Xbox Adaptive Controller (Microsoft), AbleNet switches |
| **Description** | Full compatibility with the Xbox Adaptive Controller and single-switch input devices. Large programmable buttons, switch inputs, and USB joystick alternatives are all supported with automatic input remapping. |
| **Kid UX** | A child uses a large red AbleNet switch connected to the tablet. Each press of the big red button makes the character jump. The auto-run system handles forward movement. The child can play entire levels with a single large button press, building confidence and having fun alongside friends. |
| **LLM Automation** | Backend: (1) Adaptive controller input API integration via MFi and Bluetooth; (2) Switch debouncing with 150ms cooldown to prevent accidental double-inputs; (3) One-switch scanning mode for menu navigation (auto-cycles through options, switch press to select); (4) Two-switch mode for binary navigation (switch A = next, switch B = select); (5) Auto-detection of connected adaptive hardware; (6) Input calibration wizard for sensitivity tuning. |
| **JSON Contract Extension** | `{"adaptive_controller": {"enabled": "boolean", "controller_type": "xbox_adaptive|ablenet|custom_switch", "switch_mode": "one_switch_scan|two_switch_binary", "debounce_ms": "150", "auto_detect": "boolean"}}` |

---

### Input Buffer & Forgiving Timing

| Field | Details |
|-------|---------|
| **Feature Name** | Input Buffer & Forgiving Timing |
| **Source Game** | Celeste (generous coyote time, input buffering), modern platformer design |
| **Description** | Platforming timing windows are deliberately generous: coyote time (jump can be pressed briefly after leaving a platform), input buffering (jump pressed before landing is queued), and extended invincibility frames after taking damage. These invisible assists make the game feel fair without appearing to lower the bar. |
| **Kid UX** | The child presses jump a split-second after running off a platform. In a strict game, they would fall. In KidGameMaker, the jump still executes — the platform gave them a little "credit." They don't know why it felt easier; they just know they made the jump and feel proud. |
| **LLM Automation** | Backend: (1) Coyote time window: 100ms after leaving platform edge where jump still registers; (2) Input buffer: 80ms pre-landing jump input is queued and executes on touchdown; (3) Post-damage invincibility: 2.0s with flashing visual feedback; (4) All windows adjustable per child's assist profile; (5) Ghost inputs (accidental double-taps) filtered with 50ms minimum press duration. |
| **JSON Contract Extension** | `{"input_forgiveness": {"coyote_time_ms": "100", "input_buffer_ms": "80", "post_damage_iframes_seconds": "2.0", "ghost_input_filter_ms": "50", "adaptive_window_scaling": "boolean"}}` |

---

## 9.3 Cognitive & Communication Accessibility

### Symbol Speak Communication (AAC)

| Field | Details |
|-------|---------|
| **Feature Name** | Symbol Speak Communication (AAC) |
| **Source Game** | AAC (Augmentative and Alternative Communication) best practices, symbol-based communication for non-verbal children |
| **Description** | All in-game communication — NPC dialogues, quest descriptions, tutorial text, menu labels — can be displayed as picture symbols alongside or instead of text. Children can also "reply" to NPCs using symbol selection. Based on PCS (Picture Communication Symbols) and Widget symbol libraries. |
| **Kid UX** | An NPC asks "Will you help me find my ball?" The dialog displays text AND picture symbols: [help] [find] [ball] [question mark]. The child can answer by tapping symbols: [yes] [help] or [no] [later]. Every game text element has a symbol overlay available. Symbol size is configurable from small beside-text to large replacing-text for pre-readers. |
| **LLM Automation** | Backend: (1) Text-to-symbol parser converts all game text to symbol sequences using an AAC symbol library of 5000+ symbols; (2) Symbol sentence builder arranges symbols left-to-right in grammatical order; (3) Three display modes: small beside text, medium overlapping, large replacing text; (4) Symbol response interface for NPC interactions with Yes/No/Help/Later/Fun/Hard options; (5) Custom symbol upload support for personalized vocabulary; (6) Symbol-to-speech: tapping symbols reads them aloud via TTS. |
| **JSON Contract Extension** | `{"symbol_speak": {"symbol_library": "pcs|widget|custom", "display_mode": "beside_text|replace_text", "symbol_size": "small|medium|large", "response_symbols": ["yes", "no", "help", "later", "fun", "hard"], "tts_on_tap": "boolean"}}` |

---

### Difficulty Rainbow Slider

| Field | Details |
|-------|---------|
| **Feature Name** | Difficulty Rainbow Slider |
| **Source Game** | Celeste Assist Mode (granular toggles), God of War difficulty presets |
| **Description** | A child-friendly difficulty selector that replaces intimidating text labels ("Easy/Normal/Hard") with five colorful animal characters, each representing a difficulty setting. Each animal shows what changes via simple icon previews. Children can mix-and-match individual assist options to create a custom experience. |
| **Kid UX** | The child opens settings and sees five adorable animals arranged on a rainbow arc: Snail (very gentle — infinite jumps, no damage), Bunny (gentle — extra health, slower enemies), Cat (medium — balanced experience), Fox (challenging — faster enemies, fewer pickups), and Tiger (super challenging — one-hit kills, speed runs). Tapping each animal shows simple icons of what changes: hearts for health, clocks for speed, wings for jump help. The child can pick Bunny AND turn on wing help for a fully custom experience. |
| **LLM Automation** | Backend: (1) Five base difficulty presets map to parameter bundles: enemy count, platform timing window, player health, hint frequency, enemy projectile speed; (2) Independent assist toggles (infinite jumps, slow motion, invincibility frames, auto-aim) can override any preset; (3) LLM generates kid-friendly descriptions for each setting change; (4) Adaptive recommendation engine suggests settings based on play history and death patterns; (5) Parental lock option on certain settings; (6) Achievement eligibility preserved across all settings — no penalty for playing on "easier" modes. |
| **JSON Contract Extension** | `{"rainbow_slider": {"selected_character": "snail|bunny|cat|fox|tiger", "active_assists": [{"assist_id": "string", "icon": "heart|clock|wing|star|shield", "enabled": "boolean"}], "adaptive_recommendation": "string", "parental_lock": "boolean", "achievement_eligibility": "boolean"}}` |

---

### Granular Assist Toggles

| Field | Details |
|-------|---------|
| **Feature Name** | Granular Assist Toggles |
| **Source Game** | Celeste Assist Mode (individual toggle system) |
| **Description** | Beyond the Rainbow Slider presets, every assist type can be toggled independently with fine-grained control. This empowers children with specific disabilities to enable exactly what they need and nothing more. |
| **Kid UX** | A 6-year-old with dyspraxia turns on "Extra Jump Time" and "No Knockback" but leaves everything else at default. A 7-year-old with anxiety turns on "Infinite Health" and "Slow Motion" for their first playthrough. Each child creates their own perfect experience. |
| **LLM Automation** | Backend: (1) 15+ independent assist parameters each with range sliders: game_speed (50%-100%), extra_midair_jumps (0-5), invincibility (boolean), auto_aim_strength (0-100%), platform_edge_extension (0-20px), enemy_projectile_speed (25%-100%), infinite_dashes (boolean), infinite_stamina (boolean), no_knockback (boolean), extra_health (1-10 hearts), hint_frequency (low/medium/high), checkpoint_density (normal/dense/very_dense), death_penalty (none/mild/full); (2) Preset combinations auto-saved per child profile; (3) Suggested presets based on common accessibility needs. |
| **JSON Contract Extension** | `{"granular_assists": {"game_speed_percent": "float(50-100)", "extra_midair_jumps": "int(0-5)", "invincibility": "boolean", "auto_aim_strength": "float(0-1)", "no_knockback": "boolean", "extra_hearts": "int(1-10)", "hint_frequency": "low|medium|high", "death_penalty": "none|mild|full"}}` |

---

### Auto-Aim for Projectiles

| Field | Details |
|-------|---------|
| **Feature Name** | Auto-Aim for Projectiles |
| **Source Game** | TLOU2 lock-on targeting, modern shooter accessibility |
| **Description** | When the player uses any projectile attack — fireballs, arrows, boomerangs, or thrown items — a soft lock-on system gently guides the projectile toward the nearest valid target. The assist never feels like cheating; it simply reduces the precision required for directional aiming. |
| **Kid UX** | The child presses the fireball button. Instead of flying straight (and probably missing), the fireball curves slightly toward the nearby enemy. The child still chooses the general direction and timing, but the game helps with precision. At higher assist levels, a subtle targeting reticle shows which enemy will be targeted. |
| **LLM Automation** | Backend: (1) Proximity-based target selection within a cone in the facing direction; (2) Projectile trajectory correction applied as a gentle curve (max 15 degrees deflection); (3) Target preview reticle shown at high assist levels; (4) Correction strength scales with assist setting: gentle (5 degrees), medium (10 degrees), strong (15 degrees); (5) Respects line-of-sight — won't curve through walls. |
| **JSON Contract Extension** | `{"auto_aim": {"enabled": "boolean", "max_deflection_degrees": "float", "target_cone_angle": "float", "show_reticle": "boolean", "respect_line_of_sight": "boolean"}}` |

---

### Story Simplification Mode

| Field | Details |
|-------|---------|
| **Feature Name** | Story Simplification Mode |
| **Source Game** | Cognitive accessibility best practices, simplified language frameworks |
| **Description** | Reduces the complexity of all narrative text to a target reading level (ages 5-6). Long paragraphs become short sentences. Complex vocabulary is replaced with common words. Symbol Speak overlays become more prominent. This mode ensures that pre-readers and children with reading difficulties can fully understand the narrative. |
| **Kid UX** | A story block that normally reads: "The valiant protagonist must traverse the perilous chasm to retrieve the ancient artifact before the nefarious sorcerer claims it for his own!" simplifies to: "Jump across the big hole! Get the treasure before the bad guy!" The child laughs and understands exactly what to do. |
| **LLM Automation** | Backend: (1) LLM text simplification pipeline reduces vocabulary to Dolch sight words and age-appropriate alternatives; (2) Long sentences broken into short declarative statements; (3) Passive voice converted to active voice; (4) Symbol density increased in simplified mode; (5) TTS narration speed slightly reduced; (6) Simplification applied to all story blocks, NPC dialogue, and quest descriptions in real-time. |
| **JSON Contract Extension** | `{"story_simplification": {"target_reading_level": "int(5-12)", "vocabulary_set": "dolch_sight|age_appropriate", "max_sentence_length": "int", "symbol_density": "normal|high", "tts_speed": "float(0.5-1.5)"}}` |

---

## 9.4 Reading & Audio Accessibility

### Read-to-Me Everything

| Field | Details |
|-------|---------|
| **Feature Name** | Read-to-Me Everything |
| **Source Game** | TLOU2 text-to-speech system, ReadSpeaker TTS for gaming |
| **Description** | Every text element in the game — menus, dialogues, stories, level descriptions, settings labels, tutorial text — can be read aloud via high-quality text-to-speech. The child can tap any text to hear it, or enable auto-read for continuous narration. |
| **Kid UX** | The child taps any text and a warm, friendly voice reads it aloud. Menu items announce themselves when highlighted. Story text auto-reads with synchronized word-by-word highlighting in a soft blue glow. The voice is kid-appropriate, never robotic. A turtle/rabbit slider adjusts speed from slow and clear to normal pace. |
| **LLM Automation** | Backend: (1) Full UI element tagging for TTS eligibility; (2) Tap-to-speak event handler on all text elements; (3) TTS engine with kid-optimized voice model (natural-sounding, warm tone, trained on child-friendly content); (4) Word-level synchronization for visual highlighting; (5) Speed control: 0.5x to 2.0x playback; (6) Language auto-detection with 20+ language support; (7) Voice profile selection: Friendly Male, Friendly Female, or Character Voices. |
| **JSON Contract Extension** | `{"read_to_me": {"tts_enabled": "boolean", "tap_to_speak": "boolean", "voice_profile": "friendly_male|friendly_female|character", "playback_speed": "float(0.5-2.0)", "word_highlighting": "boolean", "auto_read_stories": "boolean", "supported_languages": ["string"]}}` |

---

### Haptic Beat Buddy

| Field | Details |
|-------|---------|
| **Feature Name** | Haptic Beat Buddy |
| **Source Game** | Nintendo Switch HD Rumble, PS5 DualSense haptic feedback |
| **Description** | Rich haptic feedback patterns synchronized to gameplay events, music beats, and terrain types. Each surface produces a distinct tactile sensation; every action provides physical confirmation. For children who cannot hear or see well, haptics become a primary information channel. |
| **Kid UX** | The child walks on grass — a gentle continuous rumble. They jump on stone — a sharp quick pulse. They collect a coin — a satisfying ding-like vibration. An enemy approaches — heartbeat-style pulsing intensifies with proximity. The controller or tablet feels alive with information. |
| **LLM Automation** | Backend: (1) Haptic event mapper assigns vibration patterns to 100+ game events; (2) Music beat extractor syncs haptic pulses to percussion; (3) Terrain haptic textures: grass = smooth low-amplitude continuous, stone = short high-amplitude pulses, ice = slippery sliding pattern; (4) Proximity-based intensity: enemies trigger heartbeat that speeds up as they approach; (5) Platform abstraction supports HD Rumble, DualSense, mobile vibration, and adaptive controllers; (6) Haptic strength adjustable or convertible to on-screen visual pulse. |
| **JSON Contract Extension** | `{"haptic_beat": {"enabled": "boolean", "event_patterns": [{"event": "string", "pattern_type": "continuous|pulse|heartbeat|slide", "amplitude": "float"}], "terrain_textures": [{"terrain": "grass|stone|ice|sand", "pattern": "string"}], "proximity_patterns": [{"target_type": "enemy|collectible|hazard", "base_pattern": "string"}], "strength_multiplier": "float(0-1)"}}` |

---

## 9.5 Adaptive Intelligence & Support

### Smart Checkpoint Dropper

| Field | Details |
|-------|---------|
| **Feature Name** | Smart Checkpoint Dropper |
| **Source Game** | Celeste Assist Mode, Left 4 Dead relax phase recovery |
| **Description** | AI analyzes death patterns and dynamically adjusts checkpoint placement. Frequent deaths in one section trigger a closer checkpoint. As the child improves, checkpoints subtly space out. The checkpoint never appears to be "given" — it is presented as a discovery with a sparkle animation. |
| **Kid UX** | The child falls in the same pit three times. On the fourth attempt, a glowing checkpoint flag appears just before the pit with a celebratory sparkle. "Woohoo, I'm getting farther!" The child feels improvement, not handouts. After a streak of successes, the next checkpoint appears farther ahead, matching their growing skill. |
| **LLM Automation** | Backend: (1) Death heatmap tracks clustering of failure events per zone; (2) Checkpoint need score = death density × average time since last checkpoint; (3) Optimal checkpoint position calculated as nearest safe platform before death zone; (4) Visual feedback designed to look like "discovery" not "assistance" — sparkle animation frames it as a reward; (5) Minimum 3-attempt cooldown before checkpoint trigger to prevent spam; (6) Gradual removal: as child succeeds consistently, checkpoints space out to match skill growth. |
| **JSON Contract Extension** | `{"smart_checkpoint": {"death_heatmap": [{"zone_id": "string", "death_count": "int"}], "checkpoint_need_score": "float", "suggested_position": {"x": "float", "y": "float"}, "trigger_attempts": "int", "gradual_removal_rate": "float"}}` |

---

### Virtual Co-Pilot Companion

| Field | Details |
|-------|---------|
| **Feature Name** | Virtual Co-Pilot Companion |
| **Source Game** | Microsoft Copilot Voice (Mico character), conversational AI assistants |
| **Description** | A friendly AI companion character that children can talk to for help, creative suggestions, or emotional support. The Co-Pilot understands the full game context — current level, player position, recent failures — and responds with encouragement, hints, or demonstrations. |
| **Kid UX** | A cute floating robot named "Chip" hovers at the edge of the screen. The child taps Chip and says "I'm stuck..." Chip responds: "Want me to show you a hint? Or should I try the tricky part for you?" The child says "Show me!" Chip demonstrates a ghost jump. After success, Chip cheers: "You got it! You're amazing!" |
| **LLM Automation** | Backend: (1) Conversational LLM fine-tuned on kid-friendly game assistance; (2) Game state awareness — Co-Pilot has access to current level layout, player position, recent death clusters; (3) Intent routing: hint_request, play_assist, creative_suggestion, emotional_support; (4) Response safety filter ensures all outputs are age-appropriate, positive, and constructive; (5) Memory across sessions: Co-Pilot remembers child's preferences and past conversations; (6) Parent dashboard visibility for all Co-Pilot conversations. |
| **JSON Contract Extension** | `{"virtual_copilot": {"companion_id": "string", "personality": "helpful_robot|friendly_wizard|cheerful_animal", "game_state_access": "boolean", "intent": "hint|play_assist|creative|emotional", "safety_filter": "boolean", "parent_visible": "boolean", "conversation_memory": "boolean"}}` |

---

### Assist Mode Presets Library

| Field | Details |
|-------|---------|
| **Feature Name** | Assist Mode Presets Library |
| **Source Game** | Celeste Assist Mode, Forza accessibility presets |
| **Description** | Pre-configured assist bundles designed for specific accessibility needs. Instead of manually toggling dozens of options, parents or therapists can select a preset that matches the child's needs. Presets are labeled by benefit, not disability. |
| **Kid UX** | Parent opens the "Helpful Settings" menu and sees friendly preset cards: "Gentle Explorer" (for children who want a relaxed experience), "Focus Helper" (reduces distractions), "Steady Hands" (motor assistance), "Clear View" (visual enhancements), "Calm Play" (reduces intensity). Each card shows a simple before/after preview. |
| **LLM Automation** | Backend: (1) 8 curated presets each configuring 15+ parameters: Gentle Explorer (low enemy count, infinite health, slow motion), Focus Helper (reduced particles, Super See Mode, no screen shake), Steady Hands (input buffering, auto-aim, forgiving timing), Clear View (high contrast, large text, Sound-to-Light), Calm Play (no time limits, gentle music, pause-and-think), Independent Reader (Symbol Speak + Read-to-Me + simplified text), Social Creator (co-op assist, shared checkpoints, guided building); (2) Custom preset save slots for therapists and parents; (3) Preset import/export via shareable codes. |
| **JSON Contract Extension** | `{"assist_presets": {"selected_preset": "string", "custom_presets": [{"name": "string", "settings": "object"}], "preset_categories": ["gentle_explorer", "focus_helper", "steady_hands", "clear_view", "calm_play", "independent_reader", "social_creator"]}}` |

---

## Feature Summary: Accessibility Coverage Matrix

| Accessibility Need | Features Addressing It |
|-------------------|----------------------|
| Low vision / Blindness | Super See Mode, Sound-to-Light, Read-to-Me, Haptic Beat Buddy, Screen Edge Indicators |
| Colorblindness (all 3 types) | Colorblind Palette Adaptation, Super See Mode, pattern/texture supplements |
| Deaf / Hard of hearing | Sound-to-Light Translator, Screen Edge Indicators, Haptic Beat Buddy, visual subtitles |
| Motor impairments | One-Tap Wonder Mode, Adaptive Controller Support, Auto-Pilot Companion, Input Buffer, Eye Control (Ch 8) |
| Cognitive / Learning differences | Symbol Speak, Story Simplification, Pause-and-Think, Virtual Co-Pilot, Granular Assists |
| Dyslexia | Dyslexia-Friendly Font, Read-to-Me Everything, Word Highlighting, Symbol Speak |
| ADHD / Focus challenges | Super See Mode, Sensitivity Safe Zone, Focus Helper preset, Pause-and-Think |
| Anxiety / Sensory processing | Sensitivity Safe Zone, Calm Play preset, Smart Checkpoint Dropper, Emotional Flow Guardian (Ch 8) |
| Non-verbal communication | Symbol Speak (AAC), Voice Naming, TTS for all interactions |
| Autism spectrum | Sensitivity Safe Zone, Predictable timing, Symbol Speak, Consistent haptic feedback |



---

# Chapter 10: Modern UX, Social & Polish

> **"The difference between a good tool and a beloved tool is polish."**
>
> This chapter covers the social, creative-sharing, and user-experience features that transform KidGameMaker from a functional creation tool into a vibrant creative platform. Every feature here is judged by one standard: does it make a child feel proud of what they created? From the photo mode that captures their best moments to the community gallery that celebrates their work, these 30 features form the emotional heart of the KidGameMaker experience.

---

## 10.1 Capture & Sharing

### Magic Photo Studio

| Field | Details |
|-------|---------|
| **Feature Name** | Magic Photo Studio |
| **Source Game** | Cyberpunk 2077 Photo Mode, Blue Protocol Photo Mode, Nintendo Switch Capture Button |
| **Description** | A full-featured in-game photography system that lets children freeze gameplay at any moment, enter a free-camera editing mode, apply kid-friendly filters and stickers, draw on the screenshot, and save or share their creations. The AI suggests fun compositions based on what's happening in the frame. |
| **Kid UX** | The child taps the camera icon during play. The game freezes with a satisfying shutter-click sound and a brief white flash. Now the child can drag the camera anywhere, zoom in and out, apply filters ("Make it rainbow!" "Make it spooky!"), add stickers from a massive library, and draw with colorful brushes. A sparkle-stamp tool lets them add glitter anywhere. Tap save — the photo appears in their personal gallery with a confetti celebration. |
| **LLM Automation** | Backend: (1) Frame capture at 60fps with freeze on trigger; (2) Filter pipeline with 20+ kid-friendly filters: rainbow overlay, vintage sepia, comic book halftone, sparkle glow, underwater distortion, night-vision green; (3) Sticker library with 500+ decorations searchable by voice description; (4) AI Composition Suggester analyzes frame content and proposes 3 fun arrangements ("Add confetti!" "Put a crown on the character!" "Zoom in on the dragon!"); (5) Auto-framing detects character position and suggests optimal crop; (6) COPPA-compliant sharing pipeline to family-only contacts. |
| **JSON Contract Extension** | `{"photo_studio": {"freeze_frame": "boolean", "filters": [{"id": "string", "name": "string", "tts_name": "string", "category": "fun|mood|artistic"}], "sticker_library_size": "int", "ai_suggestions": [{"suggestion": "string", "applied_stickers": ["string"]}], "share_targets": ["family_list|parent_approval|local_only"], "drawing_tools": ["brush|stamp|text|emoji"]}}` |

**Why It Matters:** The Photo Studio is not merely a screenshot tool — it is a creativity amplifier. When a child spends ten minutes decorating a screenshot of their level with stickers, filters, and drawings, they are engaging in a secondary act of creation. The Photo Studio transforms ephemeral gameplay moments into tangible artifacts of pride. Every shared photo becomes an invitation for another child to play, remix, and create.

---

### Replay Theater

| Field | Details |
|-------|---------|
| **Feature Name** | Replay Theater |
| **Source Game** | Mario Kart ghost replay system, Mario Kart World time trials |
| **Description** | Every playthrough is automatically recorded as a deterministic replay (input log, not video file) that children can watch, save favorite moments from, and share. The system auto-detects exciting moments and marks them with star icons on a timeline for easy navigation. |
| **Kid UX** | After completing a level, the child taps "Watch My Run!" The replay plays at normal speed with their actual inputs visible as colorful button icons that flash when pressed. Exciting moments — near-miss jumps, coin-collection streaks, perfect landings — are marked with star icons on the timeline at the bottom. The child can tap any star to jump directly to that moment. Speed controls let them watch in slow-motion (0.25x) or fast-forward (4x). |
| **LLM Automation** | Backend: (1) Input log recording captures timestamp + action for fully deterministic replay (~5KB per minute instead of ~50MB for video); (2) Highlight detection algorithm identifies: near-death experiences (HP dropped below 20%), perfect jumps (cleared gap by <5px margin), coin streaks (5+ coins in 3 seconds), speed-run sections (completed faster than 80th percentile); (3) Auto-edit mode generates a 30-second "best of" compilation with music; (4) Ghost overlay can show AI optimal path for comparison; (5) Timeline renderer with star markers at highlight timestamps; (6) Storage optimization: only input logs saved, video rendered on-demand. |
| **JSON Contract Extension** | `{"replay_theater": {"input_log": [{"timestamp": "float", "action": "string"}], "highlight_moments": [{"timestamp": "float", "type": "near_death|perfect_jump|coin_streak|speed_run", "star_rating": "int(1-3)"}], "auto_edit_duration_seconds": "30", "playback_speed": "float(0.25-4.0)", "ghost_overlay_enabled": "boolean"}}` |

---

### Screenshot & Video Trailer Maker

| Field | Details |
|-------|---------|
| **Feature Name** | Screenshot & Video Trailer Maker |
| **Source Game** | Roblox video recording, Minecraft Replay Mod |
| **Description** | An automatic trailer generator that compiles the best moments from a child's level — dramatic screenshots, exciting gameplay clips, and cinematic camera movements — into a shareable 30-second trailer with music and title cards. |
| **Kid UX** | The child taps "Make a Trailer!" on their published level. After a brief "Working my magic..." animation with a cute robot editor, a trailer plays: an opening shot of the level's start, a quick-cut montage of the coolest moments (jumping over lava, defeating a boss, collecting treasure), and a title card with the level's name. The child claps and immediately wants to share it. |
| **LLM Automation** | Backend: (1) Level analysis identifies dramatic locations (largest gaps, most enemies, boss arenas, treasure rooms); (2) Replay data from playtest sessions extracted for best moments; (3) Cinematic camera path auto-generated using spline interpolation between key viewpoints; (4) Auto-edit algorithm selects 5-8 best clips and arranges them with beat-matched cuts to background music; (5) Title card generated from level name and dominant theme; (6) Export to MP4 at 720p with COPPA-safe music library. |
| **JSON Contract Extension** | `{"trailer_maker": {"auto_select_clips": "boolean", "clip_count": "int(5-8)", "music_track": "string", "title_card_text": "string", "export_resolution": "720p", "export_format": "mp4", "beat_matched_cuts": "boolean"}}` |

---

### One-Tap Share to Family

| Field | Details |
|-------|---------|
| **Feature Name** | One-Tap Share to Family |
| **Source Game** | COPPA-compliant social features, family-sharing patterns |
| **Description** | Children can share their levels, photos, and replay clips with a parent-approved list of family members and friends. No open internet interaction. Parents manage the sharing circle through a companion app. Sharing includes levels, photo studio creations, scrapbook pages, and replay highlights. |
| **Kid UX** | The child finishes a level and taps the big "Share with Family!" button. A list shows approved contacts with friendly faces: Mom, Dad, Cousin Alex, Friend Jordan. The child taps each name — green checkmarks appear. "Sent!" On Mom's phone, a notification appears: "Jordan made a new level: Crystal Castle Adventure!" Mom taps and plays. |
| **LLM Automation** | Backend: (1) Family circle management: parent invites via secure link, approves all members; (2) Content sharing pipeline packages level data + screenshot + description for delivery; (3) LLM auto-generates share preview text describing the level; (4) Play analytics sent to parent dashboard (time played, levels created, achievements earned); (5) Moderation AI scans all shared content for safety; (6) Pre-written positive comment phrases only ("Amazing!" "So creative!" "I loved the dragon!"); (7) Full COPPA compliance — no personal data exposed, no external links. |
| **JSON Contract Extension** | `{"family_share": {"members": [{"name": "string", "relationship": "string", "approved": "boolean"}], "share_types": ["level|photo|replay|scrapbook_page"], "auto_description": "string", "safety_moderation": "boolean", "comment_phrases": ["string"], "coppa_compliant": "boolean"}}` |

---

### Remixable Asset System

| Field | Details |
|-------|---------|
| **Feature Name** | Remixable Asset System |
| **Source Game** | Dreams (Media Molecule, 2020) — remixable creations with full attribution |
| **Description** | Every level, character, behavior, and creation that a child makes can be marked as "Remix Me!" Other children can then take that creation, modify it, and publish their own version — with automatic attribution to every creator in the remix chain. This creates a culture of collaborative building and iterative improvement. |
| **Kid UX** | Jordan publishes "Space Adventure" and marks it "Remix Me!" with a sparkly remix icon. Alex finds it in the community gallery, taps "Remix," and the entire level opens in their editor with every stamp editable. Alex adds more aliens and changes the background to purple. When published, it shows: "Space Adventure: Purple Edition (remixed from Space Adventure by Jordan)." Both children feel proud — Jordan inspired someone, Alex created something new. |
| **LLM Automation** | Backend: (1) Remix chain tracking: parent-child relationships stored as directed graph; (2) Asset deduplication: only the "diff" between original and remix stored, reducing storage by 80%+; (3) Attribution chain maintained through every generation of remix; (4) Content moderation at each remix level to prevent inappropriate content propagation; (5) Remix notification: original creator receives a happy notification when their work is remixed; (6) Remix counter on each creation showing how many remixes it inspired. |
| **JSON Contract Extension** | `{"remix_system": {"is_remixable": "boolean", "parent_id": "string|null", "remix_chain": ["game_id"], "attribution": {"original_creator": "string", "remix_count": "int"}, "diff_storage": {"added": [], "removed": [], "modified": []}}}` |

---

## 10.2 Progression & Motivation

### Achievement Scrapbook

| Field | Details |
|-------|---------|
| **Feature Name** | Achievement Scrapbook |
| **Source Game** | Kid-friendly battle pass design, sticker book reward psychology |
| **Description** | A virtual sticker book where children collect achievement stickers across themed pages. Instead of a traditional battle pass with time-limited FOMO, the Scrapbook is cumulative and permanent. Each page has a theme ("Jungle Explorer," "Platform Master," "Boss Slayer," "Friend Maker") and stickers are earned by completing natural gameplay activities. |
| **Kid UX** | The child opens their Scrapbook and sees beautifully illustrated pages with empty sticker outlines. Tapping an outline shows how to earn it: "Jump 100 times!" or "Defeat your first dragon!" Each jump they make fills the outline a little more with a colorful progress wash. When complete, a celebration animation plays — confetti, fanfare, and the sticker appears in full color with a satisfying "pop." |
| **LLM Automation** | Backend: (1) Achievement template library with 200+ kid-friendly achievements across 8 categories: Exploration, Creativity, Social, Persistence, Combat, Collection, Mastery, and Friendship; (2) Granular progress tracking: each action contributes a percentage toward completion; (3) LLM-generated achievement descriptions at appropriate reading level; (4) Sticker art auto-generated to match level theme and achievement type; (5) Page theming groups related achievements into collectible sets; (6) Celebration choreography on completion with confetti + fanfare + character cheer; (7) Share integration: completed pages can be shown to family with one tap. |
| **JSON Contract Extension** | `{"achievement_scrapbook": {"pages": [{"theme": "string", "stickers": [{"achievement_id": "string", "description": "string", "progress_current": "int", "progress_total": "int", "completed": "boolean", "sticker_art_url": "string"}]}], "celebration_type": "confetti|fanfare|character_cheer", "time_limited": "false", "cumulative": "true"}}` |

---

### Daily Surprise Box

| Field | Details |
|-------|---------|
| **Feature Name** | Daily Surprise Box |
| **Source Game** | Animal Crossing daily rewards, Splatoon daily gear rotation |
| **Description** | Each day a child logs in, they receive a surprise gift box containing a random creative reward: a new stamp, a new photo filter, a costume piece for their character, or a sticker for their Scrapbook. The box opening is a fun mini-animation. Crucially, rewards are never consumable or pay-to-win — always creative content. No monetization. No FOMO. |
| **Kid UX** | The child opens KidGameMaker and sees a gift box bouncing on the home screen with a "1" badge. They tap it — the box shakes, bounces, then pops open with a burst of confetti and a cheerful chime. "You got the Sparkle Unicorn Stamp!" The new stamp appears immediately in their palette, ready to use. If it's a duplicate after 7 days, it becomes a shiny "Rainbow" version instead. |
| **LLM Automation** | Backend: (1) Reward pool of 500+ collectible items across 6 categories: stamps, filters, costumes, stickers, themes, and music tracks; (2) Weighted random selection favors items matching child's play patterns (likes jungle levels → jungle-themed rewards); (3) Streak bonus: consecutive login days increase rare drop chance by 5% per day, max 50%; (4) Duplicate protection: after 7 days, duplicates convert to "shiny" alternate versions; (5) LLM generates excitement text for each drop personalized to the child's history; (6) Animation choreography syncs to reward rarity (common = simple pop, legendary = explosion + rainbow); (7) Parent notification of daily reward (no monetization, purely engagement). |
| **JSON Contract Extension** | `{"daily_surprise": {"reward_pool_categories": ["stamp|filter|costume|sticker|theme|music"], "personalized_weights": "boolean", "streak_bonus_multiplier": "float", "duplicate_protection_days": "7", "rarity_tiers": ["common|uncommon|rare|legendary"], "animation_choreography": "pop|shake_spin|explosion", "monetization_free": "true"}}` |

---

### Progressive Unlock System

| Field | Details |
|-------|---------|
| **Feature Name** | Progressive Unlock System |
| **Source Game** | Super Mario Maker 2 Story Mode, Animal Crossing tool progression |
| **Description** | Not all creation tools are available from the start. Children unlock new stamps, abilities, editor features, and themes by playing and completing simple challenges. This prevents overwhelming new users while making every unlock feel like a celebration. Tools are introduced one at a time with guided tutorials. |
| **Kid UX** | The child sees a new stamp category in the palette — it's grayed out with a friendly lock icon. Tapping it shows: "Complete 3 levels to unlock the Dragon stamps!" The child plays three levels, and on completion, a celebratory animation plays: the lock shatters with sparkles, the dragon stamps appear in full color, and the guide character cheers. The child feels accomplished and immediately wants to try their new stamps. |
| **LLM Automation** | Backend: (1) Unlock dependency graph manages 150+ unlockable items with prerequisite conditions; (2) Challenge validation: complete N levels, defeat N enemies, collect N items, build a level with N stamps, share a level, get a like; (3) Unlock event triggers celebration animation and guide character reaction; (4) Feature gating ensures new users see only core tools (20 stamps, basic enemies, simple terrain) and unlock advanced features (boss builder, logic system, custom music) progressively; (5) Alternative unlock path: parents can manually unlock items for children who need immediate access. |
| **JSON Contract Extension** | `{"progressive_unlocks": {"unlocked_items": ["string"], "pending_unlocks": [{"item_id": "string", "condition": "string", "progress": "int", "required": "int"}], "celebration_on_unlock": "boolean", "parent_override": "boolean"}}` |

---

### New Game Plus Cycles

| Field | Details |
|-------|---------|
| **Feature Name** | New Game Plus Cycles |
| **Source Game** | Dark Souls NG+, Chrono Trigger New Game+ |
| **Description** | After completing their game once, children unlock "Adventure Again+" mode. They replay levels with all their collected abilities, powers, and upgrades carried over. Enemies are tougher (visually indicated by fun aura colors), hidden "Plus Treasures" appear only in NG+, and beating the final boss at different points yields different celebratory endings. |
| **Kid UX** | The child completes all their levels. A huge celebration screen announces "Adventure Again+ Unlocked!" with fireworks. A sparkling "+" button appears on the level select. In Plus Mode, levels have rainbow borders and enemies wear silly hats to show they're tougher. The child finds "Plus Only" stamps — a golden treasure chest that wasn't there before! Different endings are shown as collectible star cards. |
| **LLM Automation** | Backend: (1) Completion detection triggers NG+ unlock with celebration sequence; (2) Player progression carried over: all abilities, upgrades, collectibles, sphere grid progress; (3) Enemy scaling: +50% health, +20% speed, + aura color change per NG+ cycle; (4) Plus-exclusive item placement algorithm hides 3-5 bonus items per level only accessible in NG+; (5) Ending variation tracking: which levels had final boss defeated determines ending; (6) Loop badge cosmetic awarded per completed cycle; (7) Maximum 9 NG+ cycles with escalating challenge and exclusive rewards. |
| **JSON Contract Extension** | `{"new_game_plus": {"unlock_after": "first_completion", "carry_over": ["abilities", "upgrades", "collectibles"], "enemy_scaling": {"health_mult": "1.5", "speed_mult": "1.2", "visual_aura": "chromatic"}, "plus_exclusive_items": "boolean", "ending_variations": "int", "current_cycle": "int(0-9)", "loop_badge": "string"}}` |

---

### Multiple Endings System

| Field | Details |
|-------|---------|
| **Feature Name** | Multiple Endings System |
| **Source Game** | Chrono Trigger (12+ endings), Castlevania SotN (multiple endings based on relic collection) |
| **Description** | Levels and world maps can have multiple endings based on player choices, completion percentage, or specific actions. Endings range from simple variations (different final dialogue) to dramatically different conclusions (rescue the puppy vs. defeat the villain). All endings are positive and celebratory — there are no "bad" endings, only different ones. |
| **Kid UX** | The child stamps an "Ending Door" at the end of their level and configures three endings: "Hero Ending" (defeat the boss), "Friend Ending" (befriend the boss), "Secret Ending" (collect all 100 coins). When playing, the child befriends the boss instead of fighting — they reach the Ending Door and see the Friend Ending: the boss throws a party! They play again, collect all coins, and unlock the Secret Ending: a treasure parade! Every ending earns them a star card for their collection. |
| **LLM Automation** | Backend: (1) Ending condition evaluator checks flags at endgame trigger: collected items, defeated bosses, NPC friendship states, completion percentage, time taken; (2) Ending selection picks the highest-priority matching ending; (3) Ending star cards generated as collectible rewards; (4) LLM generates kid-friendly ending narration appropriate to the child's choices; (5) Ending tree visualization in editor shows how choices branch; (6) All endings guaranteed positive — no child ever feels punished for their play style. |
| **JSON Contract Extension** | `{"multiple_endings": {"endings": [{"ending_id": "string", "name": "string", "conditions": [{"type": "item_collected|boss_defeated|npc_friendly|completion_percent", "target": "string", "value": "int"}], "priority": "int"}], "ending_star_cards": "boolean", "all_positive": "true"}}` |

---

### Kishotenketsu Level Flow

| Field | Details |
|-------|---------|
| **Feature Name** | Kishotenketsu Level Flow |
| **Source Game** | Nintendo's signature level design pattern across Mario, Zelda, and Kirby |
| **Description** | An AI-guided level design advisor that helps children structure their levels following the Kishotenketsu pattern: **Ki** (Introduce — present a new mechanic safely), **Sho** (Develop — expand possibilities with the mechanic), **Ten** (Twist — subvert expectations), **Ketsu** (Conclude — synthesize learning into a final challenge). The guide character suggests where each phase should go. |
| **Kid UX** | The child is building a level with moving platforms. Chip the guide character pops up: "Let's use the Platform Pattern! First, put ONE moving platform somewhere safe so players can try it." The child places it. "Great! Now add MORE platforms going different directions!" The child expands. "Ooh, now make one go REALLY fast as a surprise!" The child adds the twist. "Finally, put a big challenge that uses ALL the platform types!" The level flows like a Nintendo masterpiece. |
| **LLM Automation** | Backend: (1) Level structure analyzer identifies dominant mechanics and suggests Kishotenketsu phase placement; (2) Phase validation: Ki section has safe introduction with no death penalty, Sho section has 2-3 variations, Ten section has unexpected twist, Ketsu section synthesizes all elements; (3) Difficulty curve algorithm ensures challenge increases across phases; (4) Talking flower hint placement at each phase transition; (5) Alternative pattern suggestions: "Try the Secret Pattern!" or "Try the Boss Build-Up Pattern!" |
| **JSON Contract Extension** | `{"kishotenketsu": {"phase_placement": {"introduce_at": "percent", "develop_at": "percent", "twist_at": "percent", "conclude_at": "percent"}, "dominant_mechanic": "string", "difficulty_validation": "boolean", "talking_flower_hints": "boolean"}}` |

---

### Season of Wonder Events

| Field | Details |
|-------|---------|
| **Feature Name** | Season of Wonder Events |
| **Source Game** | Animal Crossing seasonal events, Splatoon Splatfests |
| **Description** | Monthly themed events bring new stamps, music, decorations, and challenges. Themes are kid-friendly: "Space Month," "Dinosaur Discovery," "Under the Sea," "Robot Workshop." Crucially, there is no FOMO — all event content becomes permanently available after the event ends. |
| **Kid UX** | The child opens KidGameMaker in October and the home screen has transformed with gentle falling leaves and a friendly banner: "It's Dinosaur Discovery Month!" New dinosaur stamps appear in the palette — T-Rex, Triceratops, Pteranodon. Special dinosaur-themed challenges appear in the Scrapbook ("Hatch 5 dino eggs!"). After the month ends, the dinosaur stamps stay forever. The child never feels they missed out. |
| **LLM Automation** | Backend: (1) 12 pre-planned monthly themes with 20-30 new stamps per theme; (2) Theme-specific stamp pack generation; (3) AI-generated theme music and ambient soundscapes; (4) Home screen theming: background, decorations, guide character costume changes; (5) Special event challenges feed into Achievement Scrapbook; (6) LLM-generated theme narrative and character dialogues; (7) Post-event: all stamps move to permanent library — nothing is ever lost; (8) No time-limited mechanics that create anxiety. |
| **JSON Contract Extension** | `{"season_of_wonder": {"current_theme": "string", "theme_month": "int(1-12)", "new_stamps": [{"id": "string", "name": "string"}], "theme_music_url": "string", "event_challenges": [{"challenge_id": "string", "scrapbook_sticker_id": "string"}], "post_event_permanence": "true", "fomo_free": "true"}}` |

---

## 10.3 Community & Social

### Community Gallery with Kid-Safe Moderation

| Field | Details |
|-------|---------|
| **Feature Name** | Community Gallery |
| **Source Game** | Super Mario Maker 2 (Course World), Dreams (Dream Surfing) |
| **Description** | A curated browsable gallery where children discover, play, and rate levels created by other kids. All content passes through AI moderation + human review before appearing publicly. Rating is simplified to a single heart ("I loved it!") — no negative feedback, no star ratings, no competitive pressure. |
| **Kid UX** | The child taps "Play Games" and sees a colorful grid of level thumbnails made by other kids. Filters at the top show fun categories: "Adventure," "Puzzle," "Silly," "Hard." They tap one showing a candy-themed level, play it, and at the end tap the big heart button. The creator gets a happy notification: "Someone loved your level!" The child can optionally send a voice comment saying "Your level was awesome!" which is transcribed and moderated. |
| **LLM Automation** | Backend: (1) AI moderation pipeline scans all shared content: text (profanity, PII detection), images (inappropriate content), level data (impossible levels flagged for review); (2) Human review queue for borderline content; (3) Category auto-classification by level content analysis; (4) Personalized recommendation engine suggests levels based on play history; (5) "Featured" section curated by KidGameMaker team highlighting exceptional creations; (6) Trending algorithm based on play count and heart count, age-gated; (7) Search by keyword with voice input support. |
| **JSON Contract Extension** | `{"community_gallery": {"levels": [{"id": "string", "title": "string", "creator": "string", "thumbnail": "url", "category": "string", "hearts": "int", "play_count": "int", "moderation_status": "approved|pending|rejected"}], "featured_ids": ["string"], "personalized_recommendations": ["string"]}}` |

---

### Family Circle

| Field | Details |
|-------|---------|
| **Feature Name** | Family Circle |
| **Source Game** | COPPA-compliant social features, Xbox Family Settings |
| **Description** | A closed social network where children can share creations, send messages, and play levels made only by approved family members and friends. Parents have full control over circle membership through a companion app. All interactions are positive and pre-moderated. |
| **Kid UX** | Jordan finishes a dragon level and taps "Share to Family Circle!" A list shows approved contacts: Mom, Dad, Grandma, Cousin Sam. Jordan taps all four. Green checkmarks appear with happy sounds. Grandma receives a notification on her tablet, taps it, and plays Jordan's level. She sends back a voice message: "I loved the dragon, Jordan!" Jordan hears it and beams. |
| **LLM Automation** | Backend: (1) Family circle management via secure parent invitation links; (2) Content sharing within circle only — no public exposure; (3) LLM auto-generates share preview descriptions; (4) Voice message transcription + safety filter; (5) Activity feed showing family members' recent creations; (6) Parent dashboard tracks circle activity and can revoke access; (7) Full COPPA compliance with zero personal data collection from children. |
| **JSON Contract Extension** | `{"family_circle": {"members": [{"name": "string", "relationship": "string", "approved": "boolean"}], "activity_feed": [{"member": "string", "action": "string", "level_id": "string"}], "parent_controls": "boolean", "coppa_compliant": "true"}}` |

---

### Co-Creation Mode

| Field | Details |
|-------|---------|
| **Feature Name** | Co-Creation Mode |
| **Source Game** | Super Mario Maker 2 (Co-op Building), Roblox Studio Team Create |
| **Description** | Multiple children can build the same level simultaneously in real-time, either locally (pass-the-device or same-network tablets) or online (invite-based). Each child has a unique cursor color and can see what others are placing. Conflict resolution prevents overwriting. |
| **Kid UX** | Two siblings sit on the couch with their tablets. Jordan builds the ground terrain while Alex places enemies. They see each other's cursors on screen — Jordan's is blue, Alex's is red. Alex accidentally tries to place an enemy where Jordan just put a platform. The game gently nudges Alex's enemy to the nearest valid spot. They laugh, collaborate, and build a level together faster than either could alone. |
| **LLM Automation** | Backend: (1) Operational transforms for real-time collaboration: concurrent edits merged without conflicts; (2) Cursor synchronization across devices with color-coded identifiers; (3) Soft collision avoidance: when two children place stamps in the same spot, the second stamp is auto-nudged to the nearest valid adjacent position; (4) Region locking: a child can "hold" an area they're working on; (5) Voice chat integration (Family Circle only) for collaborative communication; (6) Undo is per-user — each child can undo only their own actions. |
| **JSON Contract Extension** | `{"co_creation": {"mode": "local_pass|local_network|online_invite", "players": [{"id": "string", "name": "string", "cursor_color": "string", "cursor_position": {"x": "float", "y": "float"}}], "conflict_resolution": "soft_nudge|region_lock", "undo_scope": "per_user"}}` |

---

### Player Message System

| Field | Details |
|-------|---------|
| **Feature Name** | Player Message System |
| **Source Game** | Dark Souls soapstone messages ("Try jumping," "Illusory wall ahead") |
| **Description** | Children can leave short, templated hint messages in their levels that other players can read. Messages use a Mad Libs-style template system to ensure safety and readability. Messages that receive lots of "Applause" ratings from other players heal the author's character slightly as a reward. |
| **Kid UX** | The child stamps a "Message Board" (wooden signpost) in their level. Tapping it opens a word picker: they select from friendly templates like "[Bouncy] [Enemy] Ahead!" "Try [Jumping]!" "Secret [Wall]!" "[Treasure] is near!" Each word has a matching icon. In play, the message appears as a small signpost. Other children can tap it to read and give it a thumbs-up. |
| **LLM Automation** | Backend: (1) Message template database with 50+ kid-safe templates; (2) Word bank validation: only approved vocabulary can be inserted; (3) Message storage per level with coordinate positioning; (4) Rating aggregation: "Applause" count displayed on each message; (5) Author reward: highly-applauded messages grant a small Scrapbook bonus; (6) Content filter prevents any inappropriate word combinations; (7) Auto-suggestion of contextually relevant templates based on nearby stamps. |
| **JSON Contract Extension** | `{"player_messages": {"templates": [{"template": "{adjective} {noun} ahead!", "slots": ["adjective", "noun"]}], "word_bank": {"adjective": ["bouncy", "sneaky", "giant", "friendly", "spiky"], "noun": ["enemy", "treasure", "secret", "hole", "friend"]}, "messages": [{"id": "string", "x": "float", "y": "float", "template": "int", "filled_words": ["string"], "applause": "int"}]}}` |

---

### Parent / Teacher Dashboard

| Field | Details |
|-------|---------|
| **Feature Name** | Parent / Teacher Dashboard |
| **Source Game** | Xbox Family Settings, Google Family Link |
| **Description** | A companion web dashboard where parents and teachers view a child's creative activity, manage settings, and celebrate achievements. The dashboard uses pride-focused framing — no punitive metrics, only celebration of creativity and growth. Teachers can use it to track student progress in classroom settings. |
| **Kid UX** | Not directly visible to children (except optionally: "Mom saw your level!" heart notification). The child experiences parental engagement as praise and interest in their creations. Parent receives a weekly summary: "This week Jordan created 4 levels, discovered the Jungle theme, and earned 12 Scrapbook stickers! Their favorite stamp is the Fire Dragon." |
| **LLM Automation** | Backend: (1) Activity aggregation: levels created, play time, stamps used, stories written, remixes made; (2) LLM-generated weekly summary in natural language with pride-focused framing; (3) Safety alerts: only for genuinely concerning patterns (excessive play time, repeated content flag attempts); (4) Setting management: difficulty controls, accessibility options, circle management, time limits; (5) Pride moments: AI identifies child's best work and highlights it; (6) Suggested conversation starters: "Ask Jordan about the story they wrote for their castle level!"; (7) Classroom mode: teacher view with class-wide aggregation and privacy controls. |
| **JSON Contract Extension** | `{"parent_dashboard": {"weekly_summary": {"levels_created": "int", "play_time_minutes": "int", "favorite_stamps": ["string"], "llm_narrative": "string"}, "safety_alerts": [{"type": "string", "severity": "low|medium|high"}], "settings_management": ["difficulty|accessibility|circle|time_limits"], "pride_moments": [{"level_id": "string", "why_special": "string"}], "classroom_mode": "boolean"}}` |

---

## 10.4 Editor Polish & Delight

### Interactive Guide Character

| Field | Details |
|-------|---------|
| **Feature Name** | Interactive Guide Character |
| **Source Game** | Game Builder Garage (Bob), Dreams (MmDreamQueen) |
| **Description** | A friendly animated character — named "Chip" — serves as the child's companion throughout the creation process. Chip appears during first-time use of each feature, offers encouragement, celebrates successes, detects struggle patterns, and provides contextual help. Chip has personality: cheerful, slightly goofy, never judgmental. |
| **Kid UX** | When a child first opens the editor, Chip (a small floating robot with big eyes) appears and waves. "Hi! I'm Chip! Let's make a game together!" When the child places their first character stamp, Chip claps and a little celebration particle burst plays. If the child repeatedly undoes the same action, Chip gently appears: "Need a hint? I can help!" Chip can be dismissed with a tap or summoned anytime by tapping the Chip icon. |
| **LLM Automation** | Backend: (1) LLM powers Chip's dynamic dialogue generation based on what the child is doing; (2) Struggle detection: repeated undo, long idle periods, rapid error-prone actions trigger Chip appearance; (3) Contextual hint generation: Chip analyzes the current level state and suggests relevant next steps; (4) Tutorial step sequencing: Chip introduces features one at a time based on the child's progress; (5) Personality consistency: always encouraging, never condescending; (6) Voice synthesis for Chip's dialogue with warm, friendly tone; (7) Skip tutorial option for experienced children. |
| **JSON Contract Extension** | `{"guide_character": {"name": "Chip", "trigger_events": ["first_visit|first_stamp|struggle_detected|success_celebration"], "dialogue": [{"trigger": "string", "text": "string", "celebration": "boolean"}], "struggle_detection": "boolean", "llm_dialogue": "boolean"}}` |

---

### Smart Undo/Redo Dog (Undodog)

| Field | Details |
|-------|---------|
| **Feature Name** | Smart Undo/Redo Dog (Undodog) |
| **Source Game** | Super Mario Maker 2 (Undodog) |
| **Description** | A persistent, personality-filled undo/redo system personified by "Undodog," a cute animated dog character who literally reverses the child's actions by walking backward through them. Undo history is visual — children can see a strip of recent actions and tap any point to jump back to that state. |
| **Kid UX** | The child accidentally deletes a large section they built. They tap the "Undo" button and Undodog walks backward across the screen, magically restoring each stamp one by one with a happy bark. The child giggles. They learn that mistakes are easily fixable and build confidence to experiment wildly. Redo shows Undodog walking forward, re-applying actions. |
| **LLM Automation** | Backend: (1) Structured operation history maintained with intelligent grouping: "placed 5 blocks in a row" = one undo unit, not five; (2) Visual undo strip showing recent actions as thumbnail icons; (3) State snapshots at key intervals for fast restoration of any point; (4) Undodog animation system: walks between actions, barks on restore, wags tail on redo; (5) Collision detection for undo operations to prevent restoring stamps into invalid positions; (6) Branching undo: if the child undoes then does something new, a new branch is created rather than losing redo history. |
| **JSON Contract Extension** | `{"undodog": {"undo_stack": [{"action": "stamp|delete|move|resize", "data": "object"}], "grouping_enabled": "boolean", "visual_strip": "boolean", "animation": "walk_bark_wag", "branching_history": "boolean"}}` |

---

### Frequent Play-Test Toggle

| Field | Details |
|-------|---------|
| **Feature Name** | Frequent Play-Test Toggle |
| **Source Game** | Super Mario Maker 2 (Y button instant play/edit switch) |
| **Description** | A large, always-visible "Play" button that instantly switches from edit mode to play mode in less than one second. No compile step. No loading screen. The child's current level is immediately playable. Another tap returns to edit mode with all changes preserved. |
| **Kid UX** | The child builds a platform section, taps the big green "Play" button, immediately plays through it, dies on a badly placed enemy, taps "Edit" and fixes the enemy position. Total iteration time: under 10 seconds. The child learns through rapid iteration — build, test, adjust, test again. The speed of the loop is addictive. |
| **LLM Automation** | Backend: (1) Hot-reloading game state: editor changes persist into the running game world without full restarts; (2) State serialization: edit mode state saved, play mode state loaded, reverse on toggle; (3) Spawn point auto-set to nearest safe position to the current camera view; (4) Play-test monitoring: AI silently tracks death locations and completion times during play-test; (5) Post-playtest suggestion: "You died 5 times at the same spot — want me to suggest a fix?"; (6) Sub-second toggle target: <800ms from edit to play on all supported devices. |
| **JSON Contract Extension** | `{"play_test_toggle": {"toggle_speed_target_ms": "800", "spawn_point": "camera_nearest_safe", "auto_suggest": "boolean", "death_tracking": "boolean", "hot_reload": "boolean"}}` |

---

### Magic Wand Auto-Complete

| Field | Details |
|-------|---------|
| **Feature Name** | Magic Wand Auto-Complete |
| **Source Game** | AI level completion tools, Dreams Impossible Geometry correction |
| **Description** | When a child starts building a level structure — a wall, a platform section, a room — but leaves it visibly incomplete, the Magic Wand can finish it intelligently. The AI analyzes the pattern the child started and completes it in a way that matches their intent. The child can accept, modify, or undo the completion. |
| **Kid UX** | The child draws three sides of a castle wall but gets tired. They tap the Magic Wand icon. The wand sparkles and the fourth wall appears, completing the rectangle. "Ooh, it finished my castle!" The child taps the checkmark to accept, or drags to adjust the auto-completed section. The AI also adds corner towers because it recognized a "castle" pattern from the child's partial build. |
| **LLM Automation** | Backend: (1) Pattern recognition analyzes partially completed structures and identifies intended shape (rectangle, circle, path, staircase); (2) Structural completion fills in missing segments following the established pattern; (3) Context-aware enhancement: completing a castle adds towers, completing a path adds decorative edges; (4) Preview mode shows completion as ghost outlines before acceptance; (5) Child can accept (checkmark), adjust (drag completed elements), or reject (X button); (6) Learning from child's style: auto-complete improves over time based on child's past completions. |
| **JSON Contract Extension** | `{"magic_wand": {"pattern_types": ["rectangle|circle|path|staircase|castle"], "completion_preview": "boolean", "context_enhancements": "boolean", "child_style_learning": "boolean", "accept_method": "checkmark_drag_x"}}` |

---

### Performance Thermometer

| Field | Details |
|-------|---------|
| **Feature Name** | Performance Thermometer |
| **Source Game** | Dreams (Thermometer), Game Builder Garage (512 Nodon limit) |
| **Description** | A friendly visual indicator showing how "heavy" a level is becoming. As children add stamps, effects, and behaviors, the thermometer slowly rises. When it gets high, the guide character suggests optimizations. The thermometer uses intuitive colors: green (plenty of room), yellow (getting full), red (almost full — time to optimize). |
| **Kid UX** | The child stamps 50 individual enemies across their level. The thermometer rises to yellow. Chip the guide pops up: "Wow, so many bad guys! Want me to help you make them smarter? Instead of 50 separate enemies, we can use a 'Patrol Group' that makes them all walk together!" The child taps "Yes" and the thermometer drops back to green. The child learns optimization naturally. |
| **LLM Automation** | Backend: (1) Continuous performance estimation: CPU usage from AI/pathfinding, memory from entity count, render cost from particle/poly count; (2) Composite "heat" score calculated from all three metrics; (3) Color mapping: green <50%, yellow 50-80%, red >80%; (4) Optimization suggestions triggered at yellow: merge similar stamps, reduce particle density, use Brainbox logic groups, simplify collision meshes; (5) Auto-optimize button: one tap applies safe optimizations with child confirmation; (6) Hard cap at 100% prevents crashes — level cannot exceed capacity. |
| **JSON Contract Extension** | `{"performance_thermometer": {"cpu_usage": "float(0-1)", "memory_usage": "float(0-1)", "render_cost": "float(0-1)", "composite_heat": "float(0-1)", "color": "green|yellow|red", "suggestions": [{"issue": "string", "fix": "string", "estimated_savings": "float"}]}}` |

---

### Progressive Onboarding Flow

| Field | Details |
|-------|---------|
| **Feature Name** | Progressive Onboarding Flow |
| **Source Game** | Nintendo's progressive disclosure, Duol onboarding |
| **Description** | First-time users experience a carefully crafted onboarding sequence that introduces core concepts one at a time through guided mini-challenges. Each step teaches one skill: place a stamp, move a stamp, erase a stamp, test play, undo, add an enemy, add a collectible. By the end, the child has built a simple complete level. |
| **Kid UX** | The child opens KidGameMaker for the first time. The screen shows only three stamps: ground, player, and goal flag. Chip says: "Tap the ground stamp, then tap here to make a floor!" The child does it. "Now tap the player and put them on the ground!" Step by step, over 10 minutes, the child builds their first level and plays it. New stamps and tools appear only after the child masters the previous ones. |
| **LLM Automation** | Backend: (1) 12-step onboarding sequence with checkpoint validation at each step; (2) Conditional advancement: child must successfully complete action before next tool unlocks; (3) Dynamic pacing: faster learners progress quickly, hesitant learners get more encouragement; (4) Onboarding state saved across sessions — child can resume where they left off; (5) Skip available for experienced children; (6) Post-onboarding celebration with first level auto-saved and shareable. |
| **JSON Contract Extension** | `{"onboarding": {"current_step": "int(0-12)", "completed_steps": ["int"], "unlocked_tools": ["string"], "pacing_mode": "adaptive|fast|gentle", "celebration_on_complete": "boolean"}}` |

---

### Level Validation & Playability Guardian

| Field | Details |
|-------|---------|
| **Feature Name** | Level Validation & Playability Guardian |
| **Source Game** | Mario Maker course clear validation, AI playtesting research |
| **Description** | Before a child publishes a level, an AI playtester runs through it to verify it is actually completable. The AI detects soft-locks (unreachable goals, impossible jumps, broken triggers) and suggests fixes. Levels cannot be published until they pass validation, though the child can always keep editing. |
| **Kid UX** | The child taps "Share My Level!" A cute robot character appears and says "Let me check if your level is super fun!" The robot runs through the level at 4x speed, leaving a rainbow trail. If it finds a problem — like an impossible jump — it places a little flag there with a suggestion: "This jump looks tricky! Want me to move the platform closer?" The child taps "Yes" and the fix applies automatically. When validation passes, the robot gives a thumbs-up. |
| **LLM Automation** | Backend: (1) RL agent trained on platformer mechanics navigates the level using same physics as player; (2) Trajectory logging captures every position, velocity, and action; (3) Solvability validation: A* pathfinding + jump physics confirms start-to-goal reachability; (4) Soft-lock detection: unreachable collectibles, broken trigger chains, orphaned enemy spawners; (5) Auto-fix suggestions with child-friendly explanations; (6) Validation report with emoji-based feedback (thumbs up, thinking face, star); (7) Fast validation: completes in <3 seconds for most levels. |
| **JSON Contract Extension** | `{"playability_guardian": {"validation_status": "pass|needs_fix|unplayable", "agent_trajectory": [{"x": "float", "y": "float", "action": "string"}], "issues": [{"type": "impossible_jump|soft_lock|broken_trigger", "position": {"x": "float", "y": "float"}, "suggestion": "string"}], "completion_time_seconds": "float"}}` |

---

### Push-Notify Playdate Reminders

| Field | Details |
|-------|---------|
| **Feature Name** | Push-Notify Playdate Reminders |
| **Source Game** | Parent-controlled push notification design |
| **Description** | Parent-approved push notifications with creative prompts: "What will you build today?" or "Alex shared a new level with you!" Never monetization-focused. Parents control frequency and content type. Notifications use fun character icons and never pressure. |
| **Kid UX** | With parent setup complete, the child receives a gentle notification with Chip's face: "Your Daily Surprise Box is ready!" or "Mom played your level and left a star!" Tapping opens directly to the relevant feature. The child feels connected to their family's engagement with their creations. |
| **LLM Automation** | Backend: (1) Notification template library with 50+ creative prompts; (2) LLM personalizes prompts based on recent activity: "Last time you built a castle — try adding a dragon!"; (3) Parent control panel: frequency (daily/weekly/off), content type (rewards|social|creative_prompts|all); (4) Delivery optimization: sent during child's typical play time window; (5) Zero marketing content, zero external links, zero purchase prompts ever; (6) Creative prompts support children who benefit from starting ideas. |
| **JSON Contract Extension** | `{"push_playdate": {"templates": ["string"], "personalized_prompt": "string", "parent_controls": {"frequency": "daily|weekly|off", "content_types": ["rewards|social|creative_prompts"]}, "zero_monetization": "true"}}` |

---

## Feature Summary: Modern UX, Social & Polish

| Category | Feature Count | Key Emotional Goal |
|----------|--------------|-------------------|
| Capture & Sharing | 5 | "I made something worth showing" |
| Progression & Motivation | 7 | "I'm getting better every day" |
| Community & Social | 6 | "My creations matter to others" |
| Editor Polish & Delight | 7 | "This tool understands me" |
| **Total** | **25+** | **Pride. Connection. Delight.** |



---

# Chapter 11: Special Systems & Minigames

> **"The best games are not just one game — they are a hundred games wearing a single game's clothes."**
>
> This chapter documents the alternative modes, bonus stages, and special one-off mechanics that add variety, surprise, and depth to KidGameMaker. These are the features that children discover unexpectedly — the bonus stage that appears after collecting 100 coins, the card game they can play during loading screens, the time-travel mechanic that blows their minds. Every feature here is designed to spark joy and expand what a "kid-friendly game creator" can mean.

---

## 11.1 Competitive & Creative Minigames

### Turf War Paint Mode

| Field | Details |
|-------|---------|
| **Feature Name** | Turf War Paint Mode |
| **Source Game** | Splatoon 1/2/3 (Nintendo, 2015-2022) — Turf War |
| **Description** | A game mode where two teams compete to cover the most terrain with their color of paint by shooting it from paint weapons. At the end of a timed match, a dramatic reveal sequence expands each team's paint coverage, and the winner is declared by percentage. Kid-friendly weapons include paint rollers, paint brushes, and splatter shots. |
| **Kid UX** | The child selects "Paint Battle!" from the mode menu. They pick a paint roller (big and satisfying) and a team color (pink vs. blue). The level loads and the child gleefully rolls paint across the floor, covering every surface. Their character can transform into a "swim form" to move quickly through their own paint. When time runs out, the screen dramatically fills with each team's color expanding from the edges — "Pink Team: 62%! Blue Team: 38%! Pink Team wins!" Confetti everywhere. |
| **LLM Automation** | Backend: (1) Paint coverage tracked as 2D texture overlay per team with per-cell percentage; (2) Weapon-specific paint patterns: roller = wide path, brush = fast sweep, shot = splash radius; (3) Swim-form collision detection allows fast movement only on own-paint surfaces; (4) Dramatic reveal sequence: paint coverage expands from edges with bar-boundary synchronized music; (5) Score calculation: percentage coverage per team with sub-percent precision; (6) Auto-balancing: if one team is AI-controlled, subtle rubber-banding ensures competitive but fair match. |
| **JSON Contract Extension** | `{"turf_war": {"team_colors": {"team1": "#FF69B4", "team2": "#4169E1"}, "duration_seconds": "180", "paint_coverage": [["float"]], "weapons": [{"type": "roller|brush|shot", "paint_width": "int", "paint_rate": "float"}], "reveal_animation": "gradual_fill_from_edges"}}` |

---

### Tableturf Battle Card Game

| Field | Details |
|-------|---------|
| **Feature Name** | Tableturf Battle Card Game |
| **Source Game** | Splatoon 3 (Nintendo, 2022) — Tableturf Battle |
| **Description** | A grid-based territory card game where players place ink-pattern cards on a board to claim the most squares. Cards have different shapes (like Tetris pieces covered in ink) and special abilities. Twelve turns, simultaneous placement, special attacks that ink over opponent territory. 150+ collectible cards. |
| **Kid UX** | The child opens their card collection — 150 colorful cards with ink patterns and cute creature artwork. They build a 15-card deck by dragging favorites into a deck slot. During play, 4 cards are in hand. The child taps a card shaped like an L, then taps where to place it on the 15×15 grid — the L-shape fills with their color. The opponent does the same simultaneously. When the special meter fills, the child unleashes a "Special Attack" that splatters ink over the opponent's territory. Most squares at turn 12 wins. |
| **LLM Automation** | Backend: (1) Card shape validation: placement must touch own-ink edge; (2) Simultaneous turn resolution: both placements processed, overlap resolved (lower card number wins); (3) Special point generation per placement; (4) 12-turn game flow management; (5) Win determination by ink square count; (6) Card rarity system: common/uncommon/rare/legendary with 150+ unique designs; (7) Deck-building advisor suggests synergistic card combinations; (8) Tournament mode with bracket progression. |
| **JSON Contract Extension** | `{"tableturf": {"board_size": {"w": "15", "h": "15"}, "deck_size": "15", "hand_size": "4", "cards": [{"card_id": "int", "pattern": [["int"]], "ink_value": "int", "special_cost": "int"}], "turn": "int(1-12)", "special_points": "int", "ink_coverage": {"player1": "int", "player2": "int"}}}` |

---

### Salmon Run Co-op Horde Mode

| Field | Details |
|-------|---------|
| **Feature Name** | Salmon Run Co-op Horde Mode |
| **Source Game** | Splatoon 2/3 — Salmon Run |
| **Description** | A wave-based cooperative mode where up to 4 players (or AI teammates) defend a central basket from waves of approaching enemies. Players defeat special boss enemies that drop golden eggs, which must be carried back to the basket. Three waves with escalating difficulty. Kid-friendly with silly enemies and egg-collecting mechanics. |
| **Kid UX** | The child taps "Team Up!" and is matched with 3 AI partners (or friends in Family Circle). Wave 1 begins: "Collect 8 Golden Eggs!" Silly fish-like enemies waddle from the water's edge. The child defeats a big boss enemy — it explodes into 3 golden eggs. The child runs over, picks one up (it wiggles!), and carries it back to the basket. "7 more to go!" After wave 3, the escape helicopter arrives and everyone celebrates. |
| **LLM Automation** | Backend: (1) Wave spawning logic with escalating enemy count and types per wave; (2) Golden egg tracking: quota per wave, collection state, basket delivery validation; (3) Boss enemy AI with unique attack patterns per boss type; (4) Egg carrying physics: slows player movement, drops on damage; (5) Team AI: partners assist with egg collection, call for help, revive downed players; (6) Hazard level scaling based on team performance; (7) Escape sequence generation for successful wave 3 completion. |
| **JSON Contract Extension** | `{"salmon_run": {"waves": "3", "current_wave": "int(1-3)", "golden_egg_quota": "int", "collected": "int", "boss_spawns": [{"type": "string", "timer": "float"}], "hazard_level": "int", "team_size": "int(1-4)"}}` |

---

### Blue Sphere Bonus Stage

| Field | Details |
|-------|---------|
| **Feature Name** | Blue Sphere Bonus Stage |
| **Source Game** | Sonic the Hedgehog 3 & Knuckles (Sega, 1994) — Special Stage |
| **Description** | A pseudo-3D bonus stage where the player runs across a spherical checkerboard surface, collecting blue spheres and avoiding red ones. Touching a blue sphere turns it into a red sphere, making navigation increasingly treacherous. A ring counter serves as a timer — collecting rings extends the stage. Kid-friendly with bright colors and bouncy physics. |
| **Kid UX** | The child collects 50 rings in a level and a "BONUS!" portal appears. They enter and find themselves running on a giant colorful sphere. Blue spheres are scattered everywhere — the child runs into them and they pop with a satisfying chime, turning red. "Collect all blue spheres!" The child strategizes, planning routes that don't trap them behind red spheres. When all blues are collected, a huge fanfare plays and they win a Chaos Emerald. |
| **LLM Automation** | Backend: (1) Spherical surface mapping: 2D player movement projected onto 3D sphere; (2) Sphere state management: blue → red on contact, with state validation; (3) Ring counter as timer: depletes over time, collecting rings refills; (4) Win condition: all blue spheres collected without touching red; (5) Lose condition: touch red sphere or ring counter reaches zero; (6) Progressive difficulty: larger spheres, more red spheres, faster ring depletion across stages; (7) Emerald reward system: 7 emeralds total, each from a harder stage. |
| **JSON Contract Extension** | `{"blue_sphere": {"sphere_radius": "float", "blue_spheres": [{"x": "float", "y": "float", "collected": "boolean"}], "red_spheres": [{"x": "float", "y": "float"}], "ring_counter": "int", "win_condition": "all_blue_collected", "emerald_reward": "int(1-7)"}}` |

---

### Score Attack Time Trial

| Field | Details |
|-------|---------|
| **Feature Name** | Score Attack Time Trial |
| **Source Game** | Sonic (Time Attack), NiGHTS into Dreams (score chaining) |
| **Description** | A speed-run mode where children race through a level as fast as possible while maintaining combo multipliers. Time and score are tracked simultaneously. A ghost replay of the child's best run plays alongside them, providing self-competition. Rankings go from D to S++ with generous thresholds for kids. |
| **Kid UX** | The child taps "Time Attack!" on their favorite level. A 3-2-1 countdown, then GO! The child races through, collecting coins for speed boosts. Their best ghost — a translucent sparkly version of their character — runs the optimal path beside them. "Can I beat my ghost?" They cross the finish line. "New Record! 45 seconds! Rank: A+!" The ghost celebrates with them, not against them. |
| **LLM Automation** | Backend: (1) Millisecond-precise timer with lap-split tracking; (2) Ghost replay system: records and plays back child's best input log as translucent character; (3) Combo multiplier: collecting items in rapid succession builds score multiplier (decays after 2 seconds without collection); (4) Rank calculation: D/C/B/A/S/S++ thresholds calibrated for children's typical completion times; (5) Personal leaderboard: tracks best time, best score, and best combo per level; (6) Ghost improvement: ghost gets slightly faster with each of child's improvements, never impossibly ahead. |
| **JSON Contract Extension** | `{"time_trial": {"best_time_seconds": "float", "current_time": "float", "combo_multiplier": "float", "rank": "D|C|B|A|S|S++", "ghost_replay": {"enabled": "boolean", "ghost_input_log": [{"timestamp": "float", "action": "string"}]}, "personal_leaderboard": [{"date": "string", "time": "float", "score": "int"}]}}` |

---

### Card Battle Collectible Game

| Field | Details |
|-------|---------|
| **Feature Name** | Card Battle Collectible Game |
| **Source Game** | Final Fantasy VIII Triple Triad, Kingdom Hearts Chain of Memories |
| **Description** | A simplified collectible card battle system using a 3×3 grid. Players place numbered cards on the grid; when a card is placed adjacent to an opponent's card with a higher number on the touching edge, the opponent's card flips to the player's color. The player with the most cards at the end wins. |
| **Kid UX** | The child opens their card binder — 50 cards with cute monster artwork and numbers on each edge (top, bottom, left, right). They pick 5 cards for a quick battle. The 3×3 grid appears. The child places a card with 8 on top in the center. The opponent places a card below it with 7 on top — 8 beats 7, so the opponent's card FLIPS to the child's color! "I got your card!" After all 9 grid slots are filled, most cards wins. |
| **LLM Automation** | Backend: (1) 3×3 grid state management with ownership tracking; (2) Adjacency comparison: when a card is placed, compare touching edges with adjacent opponent cards, flip if higher; (3) Card collection system: 100+ cards with 4 edge values each (1-10); (4) Special card abilities: some cards have elemental bonuses or combo flips; (5) AI opponent with 3 difficulty levels; (6) Card pack opening animation with rarity glow effects; (7) Trading system within Family Circle. |
| **JSON Contract Extension** | `{"card_battle": {"grid": [[{"card_id": "string", "owner": "player1|player2|null"}]], "player_deck": [{"card_id": "string", "top": "int(1-10)", "bottom": "int(1-10)", "left": "int(1-10)", "right": "int(1-10)", "element": "fire|water|earth|wind|null"}], "flip_rules": "higher_wins", "special_abilities": "boolean"}}` |

---

### Fishing Minigame

| Field | Details |
|-------|---------|
| **Feature Name** | Fishing Minigame |
| **Source Game** | Stardew Valley, Terraria, Monster Hunter |
| **Description** | A timing-based fishing mechanic where the child casts a line into water, waits for a bite, then plays a simple timing mini-game to reel the fish in. A moving indicator must be kept inside a success zone by tapping at the right rhythm. Different fishing spots yield different fish rarities. |
| **Kid UX** | The child stamps a "Fishing Spot" in a water area of their level. During play, they stand next to it and tap the action button. A bobber floats on the water... then SPLASH! A bite! A simple bar appears with a moving dot. The child taps to keep the dot in the green zone. "Reel it in!" The dot bounces around — the child taps rhythmically. Success! "You caught a Golden Fish!" It goes into their collection book with a satisfying "ding." |
| **LLM Automation** | Backend: (1) Casting physics: line arc based on tap timing; (2) Bite detection: random wait 2-8 seconds, bite probability based on fishing spot rarity tier; (3) Reeling mini-game: moving dot with physics-based momentum, tap applies upward force; (4) Rarity system: common/uncommon/rare/legendary fish per spot; (5) Collection book tracking with completion percentage; (6) Fish behavior patterns: some fish move the dot slowly, others erratically; (7) Weather and time-of-day influence on available fish types. |
| **JSON Contract Extension** | `{"fishing": {"spots": [{"position": {"x": "float", "y": "float"}, "rarity_tier": "common|uncommon|rare|legendary"}], "minigame": {"green_zone_size": "float", "dot_speed": "float", "success_duration_required": "float"}, "collection_book": [{"fish_id": "string", "name": "string", "rarity": "string", "times_caught": "int"}]}}` |

---

### Cooking Minigame

| Field | Details |
|-------|---------|
| **Feature Name** | Cooking Minigame |
| **Source Game** | Monster Hunter (BBQ Spit), Dragon Quest Builders (Cooking Pot) |
| **Description** | A timing-based cooking mechanic where the child combines ingredients at a cooking station and plays a simple timing game to cook them perfectly. Undercooked gives a small buff, perfect gives a large buff, burnt gives nothing. Different ingredient combinations create different dishes. |
| **Kid UX** | The child stamps a "Cooking Pot" and some "Mushroom" and "Meat" ingredient items. During play, they bring the ingredients to the pot and select them. A cooking animation starts: meat rotates on a spit, and a color meter fills (blue → yellow → red). The child taps when the color is in the golden zone. "So Tasty!" confetti bursts. The cooked dish pops out as a floating item — "Healing Soup" — which restores health when eaten. |
| **LLM Automation** | Backend: (1) Ingredient combination database: 50+ valid recipes from 2-3 ingredient combinations; (2) Timing zones: undercooked (small heal), perfect (full heal + buff), burnt (no effect); (3) Recipe discovery: first-time combinations auto-added to recipe book; (4) Buff effects per dish: healing, attack boost, defense boost, speed boost; (5) Cooking animation choreography with particle effects; (6) Invalid combination handling: playful "Poof!" dust cloud with gentle sound; (7) Master chef tracker: cook every recipe for a Scrapbook achievement. |
| **JSON Contract Extension** | `{"cooking": {"stations": ["cooking_pot", "bbq_spit", "fiery_pan"], "ingredients": ["tomato", "bread", "mushroom", "herb", "pepper", "meat", "berry"], "recipes": [{"ingredients": ["string"], "result": "string", "heal_amount": "int", "buff": "string|null"}], "timing_zones": {"undercooked": ["0", "0.4"], "perfect": ["0.4", "0.7"], "burnt": ["0.7", "1.0"]}, "recipe_book": [{"recipe_id": "string", "discovered": "boolean"}]}}` |

---

### Attraction Flow Rides

| Field | Details |
|-------|---------|
| **Feature Name** | Attraction Flow Rides |
| **Source Game** | Kingdom Hearts 3 (Disney attraction rides as combat sequences) |
| **Description** | Themed on-rails shooter sequences where the player's character rides through a spectacular scripted scene — a roller coaster through space, a pirate ship battle, a carousel of lights — while tapping to shoot at targets. These are "set piece" experiences that showcase what KidGameMaker levels can become. |
| **Kid UX** | The child stamps an "Attraction Entrance" in their level. During play, the character jumps in and the perspective shifts: they're now riding a roller coaster through a neon-lit city! Targets appear — balloons, bells, stars — and the child taps them to shoot. The coaster loops and dives automatically while the child focuses on aiming. At the end, a massive firework display and a score tally: "You hit 45/50 targets! Amazing!" The child cheers and wants to ride again. |
| **LLM Automation** | Backend: (1) On-rails camera path following a pre-defined spline curve; (2) Target spawning system: targets appear at scripted positions along the path with difficulty-appropriate timing; (3) Hit detection with generous hitboxes and visual feedback; (4) Score tracking: hits, misses, combo streaks; (5) Rank assignment at ride end based on hit percentage; (6) Spline path editor: children can draw ride paths with their finger; (7) Themed scenery auto-generated along the path (city, jungle, space, ocean); (8) End-of-ride spectacle: fireworks, confetti, slow-motion final target. |
| **JSON Contract Extension** | `{"attraction_ride": {"theme": "roller_coaster|pirate_ship|carousel|space_shooter", "camera_path": [{"x": "float", "y": "float", "z": "float", "rotation": "float"}], "targets": [{"position": {"x": "float", "y": "float"}, "type": "string", "spawn_time": "float"}], "score": {"hits": "int", "misses": "int", "combo_best": "int"}, "rank": "D|C|B|A|S"}}` |

---

### Boss Rush Tower

| Field | Details |
|-------|---------|
| **Feature Name** | Boss Rush Tower |
| **Source Game** | Mega Man Boss Rush, Castlevania Boss Rush, Hollow Knight Pantheon |
| **Description** | A challenge mode where the player fights multiple bosses back-to-back with limited healing between fights. Bosses are fought in sequence on different "floors" of a tower. A timer tracks speed. The child can select which bosses to include from those they've placed in their levels. |
| **Kid UX** | The child stamps a "Boss Tower" in their world. Entering it shows all the bosses they've created, each on a different floor. They select five favorites. An elevator takes them to floor 1: "Goblin King!" Fight! After each boss, a single healing flower briefly blooms. Floor 2: "Shadow Knight!" Floor 3: "Dragon Pup!" At the top, a golden crown badge appears: "Boss Master!" The child flexes and wants to try again faster. |
| **LLM Automation** | Backend: (1) Boss sequence queue management with health carry-over between fights; (2) Limited healing: 1-2 healing items placed between fights, amount scales with boss count; (3) Inter-boss elevator transition animation with floor counter; (4) Timer tracking for speed-run leaderboards; (5) Boss selection UI showing all created bosses with difficulty ratings; (6) Victory card generation with stats: time, damage taken, healing used, boss count; (7) Difficulty scaling: subsequent NG+ cycles add boss attack patterns. |
| **JSON Contract Extension** | `{"boss_rush": {"selected_bosses": [{"boss_id": "string", "floor": "int"}], "heal_between_fights": "int", "timer_enabled": "boolean", "victory_card": {"time_seconds": "float", "damage_taken": "int", "bosses_defeated": "int"}}}` |

---

## 11.2 Special One-Off Mechanics

### Ink Painting Terrain Transformation

| Field | Details |
|-------|---------|
| **Feature Name** | Ink Painting Terrain Transformation |
| **Source Game** | Splatoon (Nintendo) — core ink mechanic |
| **Description** | A stamp-based mechanic where shooting "ink" onto terrain temporarily transforms its properties. The player's ink color makes surfaces bouncy, slippery, or sticky depending on the ink type. Enemies slow down when walking on enemy ink. This mechanic can be layered into any KidGameMaker level for dynamic terrain modification. |
| **Kid UX** | The child stamps "Bouncy Ink" in their palette. During play, shooting it onto normal ground makes that patch glow pink and bouncy. The child shoots a line of bouncy ink across a pit and jumps across it like a trampoline. Their friend shoots "Slippery Ink" (blue) and slides across it at high speed. The terrain becomes a canvas for creative traversal. |
| **LLM Automation** | Backend: (1) Ink overlay texture system: 2D grid tracks ink type and intensity per cell; (2) Terrain modifier application: bouncy ink adds spring physics, slippery ink reduces friction to 0.1, sticky ink increases traction and wall-cling; (3) Ink decay: non-player ink fades over 30 seconds; (4) Cross-ink interaction: opposing inks neutralize on contact creating a "splat" particle burst; (5) Performance optimization: ink grid rendered as composite texture, not individual particles; (6) Ink weapon types: splatter (area), roller (path), charger (line), brush (wide sweep). |
| **JSON Contract Extension** | `{"ink_terrain": {"ink_types": [{"type": "bouncy|slippery|sticky", "color": "string", "physics_effect": "string"}], "grid_resolution": "int", "decay_time_seconds": "30", "weapon_types": ["splatter|roller|charger|brush"], "cross_ink_interaction": "neutralize"}}` |

---

### Celestial Brush Drawing

| Field | Details |
|-------|---------|
| **Feature Name** | Celestial Brush Drawing |
| **Source Game** | Okami (Clover Studio/Capcom, 2006) — Celestial Brush |
| **Description** | A drawing mechanic where the player can pause time and draw strokes on the screen to perform miracles. Straight lines slash through enemies and obstacles. Circles around wilted plants make them bloom. Filled circles become bombs. Spirals create wind. Horizontal lines slow time. The screen takes on a parchment texture while drawing. |
| **Kid UX** | The child holds the "Brush" button and the screen freezes, turning into a beautiful ink-wash parchment. They draw a straight line across an enemy — SLASH! — ink cuts through it. They draw a circle around a dead flower — BLOOM! — it bursts into color. They draw a big filled circle — BOOM! — it becomes a cherry bomb that explodes after 3 seconds. Drawing feels like real magic. |
| **LLM Automation** | Backend: (1) Real-time stroke recognition: straight line vs. circle vs. spiral vs. horizontal line with tolerance thresholds; (2) Stroke-to-effect mapping: straight line = slash damage along path, circle = bloom/revive, filled circle = bomb spawn, spiral = wind force, horizontal line = slow time; (3) Intersection detection: what entities does the stroke pass through; (4) Ink meter consumption per technique (regenerates over time); (5) Parchment overlay shader with ink-wash aesthetic; (6) Unlocked technique tracking: child discovers brush powers progressively; (7) Screen freeze with smooth time-dilation transition. |
| **JSON Contract Extension** | `{"celestial_brush": {"techniques": [{"id": "power_slash", "stroke": "straight_line", "ink_cost": "1", "effect": "damage_line_intersect"}, {"id": "bloom", "stroke": "circle", "ink_cost": "1", "effect": "revive_plant"}, {"id": "cherry_bomb", "stroke": "filled_circle", "ink_cost": "3", "effect": "explosion"}, {"id": "galestorm", "stroke": "spiral", "ink_cost": "2", "effect": "wind_push"}], "ink_meter": {"max": "10", "current": "int", "regen_rate": "1 per 2s"}, "stroke_tolerance": "float"}}` |

---

### Time Travel Era Doors

| Field | Details |
|-------|---------|
| **Feature Name** | Time Travel Era Doors |
| **Source Game** | Chrono Trigger (Square, 1995) — time travel to 65M BC, 600 AD, 1000 AD, 2300 AD |
| **Description** | Special "Era Doors" transport the player between different versions of the same level set in different time periods. Each era has different terrain, enemies, and available items. Changes made in one era affect others: planting a tree in the past creates a forest in the present, defeating a boss in the past changes the future. |
| **Kid UX** | The child stamps an "Era Door" and picks the destination: "Long Long Ago" (prehistoric with dinosaurs), "Olden Days" (medieval with castles), "Right Now" (modern with cities), or "Far Future" (sci-fi with robots). They build each era version of the level in separate tabs. During play, the child plants a tree in the past, takes the Era Door to the present, and sees a full-grown forest! "I changed time!" Their mind is blown. |
| **LLM Automation** | Backend: (1) Era state management: parallel level data stores for each time period; (2) Time-ripple causality system: changes in past eras propagate to future eras via rule engine (tree planted in past → forest in present); (3) Era door transition: warp with time-vortex visual effect; (4) Era-appropriate visual filters: prehistoric = warm sepia, medieval = painterly, future = neon grid overlay; (5) Cross-era puzzle tracking: which changes have been made, which effects are visible; (6) Era-appropriate enemy and stamp substitution: dinosaur → knight → robot for the same encounter slot. |
| **JSON Contract Extension** | `{"time_travel": {"eras": ["prehistoric", "medieval", "present", "future"], "causality_rules": [{"cause": {"era": "prehistoric", "action": "plant_tree", "position": {"x": "float", "y": "float"}}, "effect": {"era": "present", "action": "spawn_forest", "position": {"x": "float", "y": "float"}}}], "era_filters": {"prehistoric": "warm_sepia", "medieval": "painterly", "future": "neon_grid"}, "door_transition": "time_vortex"}}` |

---

### Inverted Mirror World

| Field | Details |
|-------|---------|
| **Feature Name** | Inverted Mirror World |
| **Source Game** | Castlevania: Symphony of the Night (Konami, 1997) — Inverted Castle |
| **Description** | After completing a level or world, an "upside-down" mirror version unlocks where gravity is flipped (ceiling becomes floor). The level layout is identical but gravity pulls upward, making every jump, enemy placement, and platform feel completely different. New exclusive items and harder enemy variants appear only in the inverted version. |
| **Kid UX** | The child defeats the final boss. A magical mirror portal appears with a "?" symbol. They enter and — WHOOSH! — the entire world flips upside-down. The ground they walked on is now the ceiling. They fall "up" toward it. "Whoa! Everything is backwards!" The same castle they explored is now a topsy-turvy challenge. A chest that was on the floor is now on the ceiling. The child cackles with delight at the disorienting fun. |
| **LLM Automation** | Backend: (1) Gravity inversion: Y-axis gravity multiplied by -1, all floor collisions become ceiling collisions; (2) Level geometry auto-flip: all stamp Y-coordinates mirrored around level center line; (3) Enemy AI adjustment: patrolling enemies adapt to inverted gravity, projectile trajectories recalculated; (4) Exclusive inverted-item placement: 3-5 bonus items placed in locations only accessible with inverted gravity; (5) Visual flip transition: screen rotates 180 degrees with vortex effect; (6) Completion tracking: separate completion percentage for normal and inverted versions; (7) Both versions contribute to total 100% completion. |
| **JSON Contract Extension** | `{"inverted_world": {"gravity_multiplier": "-1", "auto_flip_geometry": "boolean", "exclusive_items": [{"item_id": "string", "inverted_position": {"x": "float", "y": "float"}}], "transition_animation": "180_rotate_vortex", "completion_separate": "boolean"}}` |

---

### Recall Time Rewind

| Field | Details |
|-------|---------|
| **Feature Name** | Recall Time Rewind |
| **Source Game** | Zelda: Tears of the Kingdom (Nintendo, 2023) — Recall ability |
| **Description** | The player can select a moving object and reverse its trajectory backward along its recent path. A falling boulder can be ridden back upward. A thrown enemy projectile can be sent back at the attacker. The path is visualized as a dotted line, and the object glows purple during rewind. |
| **Kid UX** | A boulder falls from a cliff. The child taps the "Rewind" button, then taps the boulder. It glows purple and a dotted line traces its fall path. The child holds the rewind button and watches the boulder float back UP the cliff, following the exact path it fell. The child rides on top, reaching a secret area at the top! "I rode a rock back in time!" |
| **LLM Automation** | Backend: (1) Position history recording for all movable objects: last 10 seconds at 60fps; (2) Reverse trajectory interpolation: object moves backward along recorded path at player-controlled speed; (3) Collision handling during rewind: player can stand on/ride rewinding objects; (4) Visual trail rendering: dotted line shows full path, purple glow on active target; (5) Rewind duration cap: max 10 seconds to prevent exploits; (6) Valid target filtering: only objects with recorded movement can be rewound (static objects excluded); (7) Audio: reverse-playback sound effect synchronized to rewind speed. |
| **JSON Contract Extension** | `{"recall": {"target_object": "string", "history_duration_seconds": "10", "rewind_speed": "float(0.5-3.0)", "visual_trail": "dotted_line", "glow_color": "#9B30FF", "max_rewind_seconds": "10", "rideable_during_rewind": "boolean"}}` |

---

### Ascend Phase-Through

| Field | Details |
|-------|---------|
| **Feature Name** | Ascend Phase-Through |
| **Source Game** | Zelda: Tears of the Kingdom (Nintendo, 2023) — Ascend ability |
| **Description** | The player can phase upward through any ceiling or solid overhang, emerging on top. This allows vertical traversal through otherwise solid terrain, creating shortcuts and secret discovery opportunities. A green glow and upward arrow indicate valid Ascend surfaces. |
| **Kid UX** | The child is in a cave and sees a treasure chest on a high ledge above, but there's no way up. An upward arrow appears near the ceiling. The child taps "Ascend" — their character glows green and phases straight up through the rock! They emerge on top of the cliff, right next to the treasure. "I walked through the ceiling!" |
| **LLM Automation** | Backend: (1) Ascend validation: raycast upward from player to detect ceiling within range (max 64px); (2) Ceiling thickness check: must be within valid thickness range (not too thick); (3) Smooth vertical interpolation through the surface with green glow trail; (4) Landing position validation: ensure emergence point is safe (no hazards, solid ground); (5) Ascend availability indicator: upward arrow appears when under valid surface; (6) Cooldown: 2-second cooldown between Ascend uses to prevent spam; (7) Visual effect: green phase distortion shader during transit. |
| **JSON Contract Extension** | `{"ascend": {"max_range": "64", "max_thickness": "32", "valid_surfaces": ["ceiling", "overhang", "platform"], "visual_effect": "green_phase", "cooldown_seconds": "2", "indicator_arrow": "boolean"}}` |

---

### Morph Vehicle Building

| Field | Details |
|-------|---------|
| **Feature Name** | Morph Vehicle Building |
| **Source Game** | Zelda: Tears of the Kingdom — Ultrahand ability |
| **Description** | A tool that allows children to grab almost any object in the world, rotate it freely, and attach it to other objects. Build vehicles, bridges, catapults, flying machines — anything that physics allows. Objects are connected with visible green "glue" bonds and behave as a single physics body. |
| **Kid UX** | The child taps "Build Mode." They tap a wooden crate — it highlights in orange. They drag it, then tap a wheel stamp and attach it to the crate's corner. Tap another wheel, attach to the other corner. Now they have a cart! They place their character on it and push — it rolls down a slope! "I made a car!" They add a fan and it becomes a fan-powered hovercraft. The possibilities feel infinite. |
| **LLM Automation** | Backend: (1) Object selection and highlighting system with orange glow; (2) 2D rotation gizmo for free rotation of grabbed objects; (3) Physics joint creation on "glue": weld joint for rigid attachment, revolute joint for wheels, distance joint for springs; (4) Combined rigid body physics: attached objects calculate shared center of mass; (5) Joint stress visualization: bonds glow red when under strain, break if overstressed; (6) Blueprint save: successful vehicles can be saved as stamps and placed instantly elsewhere; (7) Stability validation: warns if vehicle design is physically unstable. |
| **JSON Contract Extension** | `{"vehicle_building": {"selected_object": "string|null", "attached_objects": [{"object_id": "string", "position": {"x": "float", "y": "float"}, "rotation": "float", "joint_type": "weld|revolute|distance|spring"}], "blueprint_save": "boolean", "stress_visualization": "boolean", "stability_validation": "boolean"}}` |

---

### Digging for Buried Treasures

| Field | Details |
|-------|---------|
| **Feature Name** | Digging for Buried Treasures |
| **Source Game** | Okami (Clover Studio, 2006) — digging mechanic |
| **Description** | Special "soft ground" patches scattered throughout levels that the player can dig at to uncover hidden items, currency, or secrets. Dig spots have subtle visual cues (slightly raised dirt mound with tiny sparkles) that observant players notice. Treasure contents are randomized per spot. |
| **Kid UX** | The child spots a slightly raised dirt patch with a tiny sparkle. They stand on it and press the "Dig" action. Their character burrows into the ground with a puff of dirt, then pops back up holding a shiny treasure! "I found a Ruby Gem!" The dirt patch flattens after digging. Some spots respawn after a level restart, others are one-time discoveries. |
| **LLM Automation** | Backend: (1) Dig spot placement validation: only on walkable terrain, not inside walls; (2) Loot table system per spot: common (70%: coins), uncommon (20%: gems), rare (8%: equipment), legendary (2%: special stamp); (3) Dig animation: burrow → underground pause → emerge with item; (4) Visual cue system: subtle sparkle when player is within 100px of undug spot; (5) Respawn logic: some spots respawn on level re-entry, others are permanently consumed; (6) Treasure magnetization: found items gently float toward player; (7) Dig spot density limiter: max 3 per screen to prevent clutter. |
| **JSON Contract Extension** | `{"dig_spots": [{"spot_id": "string", "position": {"x": "float", "y": "float"}, "loot_table": [{"item_id": "string", "weight": "float"}], "visual_cue_radius": "100", "respawn": "boolean", "dug": "boolean"}]}` |

---

### Gummi Block Vehicle Builder

| Field | Details |
|-------|---------|
| **Feature Name** | Gummi Block Vehicle Builder |
| **Source Game** | Kingdom Hearts (Square Enix, 2002) — Gummi Ship builder |
| **Description** | A snap-together vehicle construction system using colorful block pieces on a grid. Different block types provide different functions: cockpit (required), engine (speed), wing (handling), armor (defense), weapon (attack power). The built vehicle flies through a bonus shooting segment between platforming levels. |
| **Kid UX** | Between levels, the child enters the "Vehicle Garage." They see a grid canvas and a palette of colorful blocks — red cockpit, blue engines, yellow wings, green lasers. They stamp blocks onto the grid, snapping together a funny-looking spaceship. A cute robot guide gives a thumbs-up: "Looks ready to fly!" They launch into a 30-second bonus shooting segment, blasting asteroids and collecting stars. The vehicle's stats are determined by its block composition — more engines = faster, more wings = better turning. |
| **LLM Automation** | Backend: (1) Grid-based block placement with snap-to-grid behavior; (2) Vehicle validation: must contain at least 1 cockpit and 1 engine; (3) Stat computation from block composition: speed from engines, handling from wings, defense from armor, offense from weapons; (4) Procedural vehicle sprite generation from block layout; (5) Bonus shooting segment: auto-scroll with enemy wave generation scaled to vehicle stats; (6) Block unlocking: new block types discovered through level progression; (7) Blueprint save/load: favorite designs stored as stamps. |
| **JSON Contract Extension** | `{"gummi_builder": {"block_types": ["cockpit", "engine", "wing", "armor", "weapon_laser", "shield", "special"], "grid_size": ["10", "10"], "validation_rules": ["has_cockpit", "has_engine"], "stat_computation": "block_aggregate", "shooting_segment": {"duration": "30", "difficulty_scale": "vehicle_stats"}}}` |

---

### Phozon Absorption Growth

| Field | Details |
|-------|---------|
| **Feature Name** | Phozon Absorption Growth |
| **Source Game** | Odin Sphere (Vanillaware, 2007) — Phozon absorption system |
| **Description** | Defeated enemies release floating "Power Orbs" that the player absorbs by touching. Collecting enough orbs causes the character to visibly grow larger — a visual size increase with a slight stat boost. Collected orbs can also be spent at "Growth Shrines" to unlock skill tree nodes (more health, stronger attacks, faster movement). |
| **Kid UX** | The child defeats a slime enemy. It pops into 5 pretty floating orbs that home toward the player with a chime. The orbs are absorbed and a small "Growth" meter fills. After absorbing 20 orbs — POOF! — the character grows slightly bigger with a celebratory flash! "I'm bigger!" At a Growth Shrine, the child spends 50 orbs to unlock a glowing node: "+1 Heart!" The character now has more maximum health. Growth feels tangible and exciting. |
| **LLM Automation** | Backend: (1) Orb release on enemy defeat: quantity scales with enemy difficulty; (2) Orb homing physics: gentle acceleration toward player within pickup radius; (3) Growth state tracking: size scaling (1.0x → 1.3x max), stat modifiers per growth tier; (4) Skill tree generation: branching paths for health/attack/speed/special upgrades; (5) Orb spending validation at Growth Shrines; (6) Growth persistence across levels; (7) Visual feedback: character sprite scales smoothly, aura glow intensifies with growth level. |
| **JSON Contract Extension** | `{"phozon_growth": {"orb_source": "enemy_defeat", "orb_behavior": "homing_float", "growth_tiers": [{"orbs_required": "int", "size_multiplier": "float", "stat_bonus": "string"}], "skill_tree_nodes": [{"node_id": "string", "cost_orbs": "int", "effect": "string"}], "shrine_type": "growth_shrine", "persistence": "profile_wide"}}` |

---

### Sphere Grid Skill Board

| Field | Details |
|-------|---------|
| **Feature Name** | Sphere Grid Skill Board |
| **Source Game** | Final Fantasy X (Square, 2001) — Sphere Grid |
| **Description** | After completing each level, the child advances on a colorful grid board. Each node grants a permanent bonus: +1 health, faster speed, new ability unlock, elemental resistance. The child chooses which direction to move, creating a personalized progression path. Multiple characters can share the same board. |
| **Kid UX** | After finishing a level, a big colorful grid appears with the child's character token on their current node. Glowing adjacent nodes show available moves. The child taps a heart-shaped node — their token moves there with a sparkle trail, and they gain +1 max health forever! They can see their whole progression history as a glowing path across the board. "I have 10 hearts now!" |
| **LLM Automation** | Backend: (1) Auto-generated branching board layout with meaningful path choices; (2) Node state tracking per player profile: activated/deactivated; (3) Permanent stat application from activated nodes; (4) Board section unlocking: new sections become available as more levels are completed; (5) Visual path highlighting: shows child's journey across the board; (6) Shared board support: multiple characters on same board create visible competition/collaboration; (7) LLM-generated node descriptions appropriate to child's reading level. |
| **JSON Contract Extension** | `{"sphere_grid": {"board_layout": "auto_generated_branches", "node_types": ["health_up", "speed_up", "ability_unlock", "element_resist", "special"], "moves_per_level": "1", "board_sections_unlock": "level_progress", "shared_board": "boolean", "visual_path_highlight": "glow"}}` |

---

## 11.3 Community & Persistent Systems

### Message Board Signs

| Field | Details |
|-------|---------|
| **Feature Name** | Message Board Signs |
| **Source Game** | Dark Souls (FromSoftware) — soapstone messages |
| **Description** | A community hint system where players leave templated messages on wooden signposts throughout levels. Messages use a safe word-bank system (no free typing) to ensure kid-friendly content. Highly-rated messages appear more frequently. This creates a sense of shared discovery and community wisdom. |
| **Kid UX** | The child is stuck on a tricky jump. They spot a small wooden signpost ahead. Walking up to it reveals: "Try jumping here! — left by SparkleKid7" with 42 thumbs-up. The child tries jumping at that spot and discovers a secret platform! Grateful, they place their own sign after a boss fight: "Use fire attack! — left by Jordan" to help future players. |
| **LLM Automation** | Backend: (1) Template + word-bank system: 100+ safe message templates with fillable slots; (2) Message placement validation: only on signpost stamps, max 1 message per signpost; (3) Rating system: thumbs-up only, no downvotes; (4) Message visibility: highest-rated messages shown by default, new messages mixed in for discovery; (5) Author attribution with kid-safe username; (6) Content filter: AI scan of all word combinations before publication; (7) Context-aware suggestions: "This area has a secret — suggest 'Try looking up!' template." |
| **JSON Contract Extension** | `{"message_boards": {"signposts": [{"signpost_id": "string", "position": {"x": "float", "y": "float"}, "messages": [{"template_id": "string", "filled_words": ["string"], "author": "string", "thumbs_up": "int"}]}], "word_bank": ["string"], "max_messages_per_signpost": "1"}}` |

---

## Feature Summary: Special Systems & Minigames Overview

| Category | Feature | Source Game | Player Count | Session Length |
|----------|---------|-------------|--------------|----------------|
| Competitive | Turf War Paint Mode | Splatoon | 2-4 | 3 min |
| Competitive | Tableturf Card Game | Splatoon 3 | 2 | 5 min |
| Cooperative | Salmon Run Horde | Splatoon 2/3 | 1-4 | 5 min |
| Solo Challenge | Blue Sphere Bonus | Sonic 3&K | 1 | 1-2 min |
| Solo Challenge | Score Attack Time Trial | Sonic / NiGHTS | 1 | 1-3 min |
| Competitive | Card Battle Collectible | FF8 Triple Triad | 2 | 3 min |
| Collection | Fishing Minigame | Stardew / MH | 1 | Variable |
| Crafting | Cooking Minigame | Monster Hunter | 1 | 1 min |
| Spectacle | Attraction Flow Rides | KH3 | 1 | 1-2 min |
| Challenge | Boss Rush Tower | Mega Man / HK | 1 | 5-10 min |
| Special Mechanic | Ink Painting Terrain | Splatoon | Any | Ongoing |
| Special Mechanic | Celestial Brush Drawing | Okami | 1 | Ongoing |
| Special Mechanic | Time Travel Era Doors | Chrono Trigger | 1 | Ongoing |
| Special Mechanic | Inverted Mirror World | Castlevania SotN | 1 | Ongoing |
| Special Mechanic | Recall Time Rewind | Zelda TotK | 1 | Ongoing |
| Special Mechanic | Ascend Phase-Through | Zelda TotK | 1 | Ongoing |
| Special Mechanic | Morph Vehicle Building | Zelda TotK | 1 | Ongoing |
| Collection | Digging for Treasures | Okami | 1 | Variable |
| Vehicle Builder | Gummi Block Builder | Kingdom Hearts | 1 | 2-3 min |
| Progression | Phozon Absorption Growth | Odin Sphere | 1 | Ongoing |
| Progression | Sphere Grid Skill Board | FFX | 1 | Ongoing |
| Community | Message Board Signs | Dark Souls | Any | Ongoing |



---

# Section 12: Implementation Roadmap

The 345+ features catalogued across the preceding eleven chapters represent KidGameMaker's complete creative vision. Not every feature can ship on day one, and not every feature is equally urgent. This roadmap establishes a four-phase prioritization matrix, a complexity-versus-impact analysis for the top-priority items, and a strategy for evolving the JSON contract that binds the Svelte/Tauri editor to the Godot 4 runner. The goal is to deliver a system that feels complete at each milestone while building toward the full feature set.

---

## 12.1 Phase-by-Phase Priority Matrix

### Phase A: Foundation (P0) — "It Feels Like a Real Engine"

Phase A delivers the minimum viable feature set that makes KidGameMaker feel complete rather than like a prototype. These are the mechanics players expect from any commercial platformer or action game. Without them, the product feels broken. With them, a child can ship a game that genuinely impresses.

**Movement & Traversal (Core Layer)** — Implement wall jump, double jump, dash (with cooldown meter), glide (with stamina depletion), ledge grab, and ground pound. These six features cover the traversal vocabulary of modern platformers from *Celeste* to *Super Mario Odyssey*. Each is a single-action mechanic that requires only state-machine wiring and minimal parameter tuning. The JSON contract needs only a `movement_id` enum and a `params` block for duration, speed, and cooldown values. The stamp system already supports placing these as movement-tool stamps on any entity.

**Combat Fundamentals** — Sword combo (three-hit string with finisher), charge shot (hold-to-charge with visual indicator), parry (frame-perfect with generous 8-frame window), and shield block. These four mechanics form the complete defense-and-offense loop. The combo system requires an input-buffer timer; the charge shot needs an `is_charging` state flag and a scalar `charge_ratio` exported to the JSON; the parry needs a brief invulnerability window and a counter-attack state transition. All are well-understood problems with established Godot patterns.

**Rules Engine Primitives** — Switch-and-door pairs, key-and-lock systems, pressure plates, collectible counters, and win-condition triggers. These are the puzzle grammar. Each rule is a small finite-state machine: `on_activated -> set_target_state`. The editor already represents these as connection lines between stamps; Phase A simply hardens the runtime evaluation to handle the ten most common rule patterns.

**AI-Assisted Quality of Life** — The Level Balancer (auto-tune enemy density and platform spacing for target difficulty) and the Smart Tutorial Whisperer (context-sensitive hint system that watches player failure patterns and suggests mechanics before frustration sets in). These two features are KidGameMaker's signature AI layer and should ship early so every game made in the platform benefits from them from the start.

Phase A estimate: 14 core features, 10–12 weeks.

---

### Phase B: Depth (P1) — "Every Game Feels Different"

Phase B introduces systems that create meaningful variety between games. Where Phase A gives every player the same toolbox, Phase B gives them different toolboxes that dramatically change how a game plays.

**Classes & Job Badges** — Eight starter classes (Warrior, Mage, Rogue, Archer, Paladin, Necromancer, Engineer, Bard), each with a unique starting ability, stat profile, and equip-restriction set. The JSON contract adds a `class_id` field to the player entity and a `class_definitions` lookup table. Badge icons use the existing sprite-slicing pipeline; no new asset tooling is required.

**Transformation System** — Super-form triggers (Super Sonic, Super Saiyan, Fire Mario), copy-ability absorption (Kirby-style), and temporary power-up forms (Tanooki suit, Metal form). Each transformation swaps the player's sprite sheet, movement parameters, and ability set. The JSON contract extends `player_state` with a `transform_stack` array so multiple forms can queue and expire independently.

**Companions & Familiars** — Three companion archetypes: damage familiars (floating orb that fires projectiles), utility familiars (Pikmin-style followers that carry objects and press buttons), and spirit ashes (summonable ghost allies with timed lifespan). Each companion type requires a new AI behavior tree node and a `companion` entity definition in JSON. The Pikmin-style followers are the highest complexity due to swarm pathfinding, but Godot 4's navigation mesh and `NavigationAgent2D` handle the heavy lifting.

**Crafting & Cooking** — Recipes with ingredient requirements, crafting stations, and consumable output items. The system needs a `recipe_book` JSON block, an `inventory` state tracker, and a simple UI panel in the editor for recipe discovery. Cooking adds status-effect food buffs, requiring a `status_effects` array on the player entity.

**Boss Constructor** — A multi-phase boss builder where creators define phase transitions via HP thresholds, each phase swapping attack patterns, movement behaviors, and vulnerability windows. The JSON contract adds a `boss_phases` array with per-phase `trigger_condition`, `behavior_override`, and `vulnerability_flags`. This is the single most requested feature from playtesters.

**Elemental Chemistry Engine** — Fire melts ice into water, water conducts lightning, lightning ignites oil, oil burns into smoke, smoke blocks sight. A five-element interaction matrix with 25 pairwise reactions. Each reaction is a rule predicate (`if element_a touches element_b then spawn element_c`), compactly represented as a lookup table in JSON. Implementation is straightforward; design balance is the challenge.

Phase B estimate: 48 features across six subsystems, 14–16 weeks.

---

### Phase C: Magic (P2) — "Only KidGameMaker Does This"

Phase C is KidGameMaker's competitive moat. These features are not just nice to have; they are the reason a family chooses this tool over any other. They leverage AI and procedural generation to make creation effortless.

**Magic Stamp Generator** — Text-to-image stamp creation. A child types "flying blue robot cat" and receives a transparent-background sprite sheet ready to drop on the canvas. Integrates with the existing asset-inbox pipeline for auto-slicing and frame detection. Requires an image-generation backend endpoint; the editor UI is a text field and a "Generate" button.

**Talk-to-Build Voice Assistant** — Speech-to-level-design. A child says "make a platform that moves up and down" and the system places a moving-platform stamp, configures its path points, and opens the parameter panel pre-filled with sensible defaults. Uses a speech-to-text layer feeding into a natural-language-to-JSON-template translator. The "secret sauce" is the template library that maps common phrases to pre-validated stamp configurations.

**Procedural Level Generation** — Creator-defined constraints (biome, length, difficulty, theme) fed into a grammar-based generator that produces full platforming levels as stamp collections. The output is standard KidGameMaker JSON that can be edited by hand or accepted as-is. The generator runs server-side and returns a level file; no runtime integration needed.

**Adaptive Difficulty — Helper Fairy** — A real-time difficulty adjustment agent that monitors player performance (death rate, completion time, item usage) and subtly tweaks enemy HP, platform spacing, and hint frequency. The agent communicates via the existing `game_events` telemetry stream and writes adjustments to a `difficulty_override` block in the runner's live state.

**Voice NPC Dialog** — Text-to-speech for NPC lines with per-character voice profiles. A child writes dialog in the editor; the runner speaks it aloud using a lightweight voice synthesis layer. Voice profiles (gruff, squeaky, regal, robotic) are selectable from a dropdown. No backend dependency; runs locally in Godot via speech synthesis libraries.

**Auto-Music Composer** — Mood-driven procedural music. The creator selects a mood (battle, exploration, puzzle, boss) and a tempo; the system generates a looping track that reacts to gameplay events (intensity rises when enemies appear, shifts to minor key on player damage). Exports to the existing audio-inbox pipeline as a `.ogg` loop.

**Ghost Racer** — Time-trial mode where a translucent replay of the creator's best run appears as a competitor. Records input sequences and replays them on a ghost entity. Uses the `input_recording` and `ghost_playback` JSON blocks, leveraging the deterministic runner for frame-accurate replay.

Phase C estimate: 26 features, 12–14 weeks.

---

### Phase D: Polish (P3) — "A Product Worth Sharing"

Phase D transforms KidGameMaker from a powerful creation tool into a social platform and a lasting experience. These features focus on expression, community, and replayability.

**Photo Studio** — In-game screenshot mode with freeze-frame, camera orbit, filter overlays, and sticker placement. Outputs PNGs to the community gallery. A single stamp-entity with camera control and filter post-processing.

**Replay Theater** — Full gameplay recording with rewind, slow-motion, and highlight auto-detection (deaths, boss kills, speed-run splits). Uses the Ghost Racer recording pipeline but extends it to full video-like playback with scrubbing controls.

**Achievement Scrapbook** — Creator-defined achievements ("Collect 100 coins," "Beat the boss without taking damage") with custom badge art. Scrapbook layout auto-generates from achievement definitions in the project JSON.

**Community Gallery** — Web-based showcase of published games with rating, tagging, and remix forking. Requires a lightweight backend for project storage and metadata indexing; the runner and editor already handle JSON serialization.

**New Game Plus** — Post-completion mode that carries over upgrades, unlocks hard-mode enemy variants, and introduces remix rules (mirrored levels, speed runs, limited lives). NG+ flags live in a `completion_carryover` JSON block.

**Minigames** — Turf War (Splatoon-style territory painting), Card Battles (deck-building combat), and three additional arcade-style minigames. Each is a self-contained rule set packaged as a "game mode template" that creators can drop into their projects.

**Seasonal Events** — Time-limited stamps, themes, and challenge modes that rotate monthly. Event content is delivered via JSON patch files downloaded to the asset inbox. No client update required.

Phase D estimate: 32 features, 10–12 weeks.

---

## 12.2 Complexity vs. Impact Analysis

The following table identifies the fifteen highest-priority features across all four phases, scored by implementation complexity (engineering effort, unknowns, integration risk) and player impact (how dramatically the feature improves the creator or player experience). Features with high impact and medium-or-lower complexity are the optimal development targets.

| # | Feature | Source Inspiration | Complexity | Impact | Phase |
|---|---------|-------------------|------------|--------|-------|
| 1 | Wall Jump / Dash / Double Jump | Celeste, Hollow Knight | Low | Critical | A |
| 2 | Sword Combo + Charge Shot + Parry | Zelda, Hollow Knight | Medium | Critical | A |
| 3 | Switch-Door-Key Rule System | Zelda, Portal | Low | Critical | A |
| 4 | AI Level Balancer | KidGameMaker Original | Medium | High | A |
| 5 | Smart Tutorial Whisperer | KidGameMaker Original | Medium | High | A |
| 6 | Boss Phase Constructor | Dark Souls, Cuphead | High | Critical | B |
| 7 | Classes & Job Badges | Final Fantasy, Terraria | Medium | High | B |
| 8 | Elemental Chemistry Engine | Zelda: BotW, Divinity OS | Medium | High | B |
| 9 | Pikmin-Style Companion Swarm | Pikmin, Spirit Ashes | High | High | B |
| 10 | Crafting & Cooking System | Zelda, Stardew Valley | Medium | Medium | B |
| 11 | Magic Stamp Generator (Text-to-Sprite) | KidGameMaker Original | High | Critical | C |
| 12 | Talk-to-Build Voice Assistant | KidGameMaker Original | High | Critical | C |
| 13 | Procedural Level Generator | Spelunky, Hades | High | High | C |
| 14 | Adaptive Difficulty (Helper Fairy) | KidGameMaker Original | Medium | High | C |
| 15 | Community Gallery + Remix Forking | Roblox, Minecraft | Medium | High | D |

**Analysis.** The eight features ranked Critical impact are non-negotiable for product-market fit. Items 1–3 (core movement and rules) are low-complexity and should be the very first engineering tasks. Items 6 and 11–12 (boss constructor, Magic Stamp, Talk-to-Build) are the highest complexity but also the strongest differentiators; they require dedicated prototyping sprints before full implementation. Items 4–5 and 14 (AI-assisted quality-of-life features) punch above their weight: medium complexity, high impact, and they improve every game made on the platform automatically.

---

## 12.3 JSON Contract Evolution Strategy

KidGameMaker's architecture depends on a clean separation between the Svelte/Tauri editor (which produces project JSON) and the Godot 4 runner (which consumes it). As the feature set expands from the current Phase 9 baseline through Phases A–D, the JSON schema must grow without breaking existing projects.

### Backward-Compatible Schema Versioning

Every project file carries a top-level `schema_version` field (current: `"1.9.0"`, Phase A target: `"2.0.0"`). The runner implements a version-compatibility layer that upgrades older project files on load using a chain of migration functions: `migrate_1_9_to_2_0`, `migrate_2_0_to_2_1`, and so on. Each migration is a pure function that takes a JSON object and returns a modified JSON object with deprecated fields remapped to their modern equivalents and new fields populated with sensible defaults. Migrations are tested against a corpus of real project files from each historical phase to prevent regressions. Breaking schema changes are reserved for major version bumps and are announced two release cycles in advance.

### Sidecar Metadata Block Extension Plan

Large feature additions do not bloat the core entity format. Instead, they attach as sidecar metadata blocks keyed by feature domain. For example, the elemental chemistry system adds a top-level `"elemental_rules"` array; the class system adds a `"class_definitions"` lookup table; the companion system adds a `"companion_behaviors"` dictionary. Each sidecar block is self-describing with a `"_meta"` sub-field that declares its feature domain and minimum schema version. The runner only loads sidecar blocks for features it supports, gracefully ignoring unknown domains. This pattern keeps the core `entity`, `level`, and `tilemap` structures stable while allowing unlimited orthogonal extension.

### Runtime Template Expansion Strategy

KidGameMaker supports template macros — reusable JSON fragments that expand at runtime. A template reference like `{ "$template": "boss_phase_standard", "$params": { "hp_threshold": 0.5 } }` is resolved by the runner against a built-in template library before the scene is instantiated. Phase C's procedural level generator and Talk-to-Build assistant both produce template-heavy JSON rather than raw scene data, which dramatically reduces file sizes and ensures generated content follows best-practice patterns. Templates are versioned independently of the schema and can be hot-updated via the asset inbox without a client release. Creators can also define custom templates in their project, enabling a library of reusable components that improve with every project.

The combination of versioned migrations, sidecar metadata blocks, and runtime template expansion ensures that KidGameMaker's JSON contract remains a stable, evolvable foundation for the full 345-feature vision — and for whatever features come after it.


---

