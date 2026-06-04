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

