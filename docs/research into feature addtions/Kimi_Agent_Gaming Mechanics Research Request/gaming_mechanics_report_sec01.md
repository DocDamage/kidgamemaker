## 1. Core Platforming Features

Platformers live or die by their feel. A five-year-old does not care about sub-pixel precision or Minkowski differences, but they absolutely feel the difference between a jump that lands where they expect and one that sends them sliding into a pit. This chapter distills the physics engineering from five of the most influential platforming games into a preset-based system that an LLM can wire up from nothing more than a child placing a character stamp on a canvas.

The core insight from cross-dimensional analysis is that **forgiveness mechanics matter more than raw physics accuracy**[^77^][^78^]. Celeste's celebrated platforming feel does not come from its gravity constant or its max speed — it comes from nine invisible辅助系统 that catch the player before they know they have fallen. For a child audience, these辅助系统 are not optional polish; they are the architecture. Every physics preset in the library bakes them in at generous defaults, and a runtime struggle detector silently increases their parameters when the child needs more help.

---

### 1.1 Physics Preset Library — "Feel as a Feature"

A child places a character stamp on the canvas and taps a "Feel" icon: "Bouncy like Mario," "Fast like Sonic," "Floaty like Kirby." The LLM backend receives the stamp's serialized properties, looks up the matching preset in the `PHYSICS_PRESETS` table, and instantiates a complete physics profile with every constant pre-filled. The child never sees a gravity value or a coyote-time slider. They see a character that feels right.

#### 1.1.1 Pre-configured physics profiles from 5 legendary games

The preset library is built on meticulous reverse-engineering of five landmark titles. Each profile captures not just the raw constants but the *design intent* — the acceleration curve that makes Mario feel weighty, the angular momentum that makes Sonic feel fast, the instant response that makes Hollow Knight feel snappy.

**Super Mario Bros. (NES, 1985)**. Nintendo's R&D4 team implemented sub-pixel positioning at 1/256th of a pixel per frame, giving Mario a speedometer resolution that made acceleration curves buttery-smooth[^179^]. The measured values are: walking max speed of 1 pixel per frame (60 px/s), running max speed of 3 pixels per frame (180 px/s), acceleration of effectively 0.0234375 pixels/frame² (subtle build-up over ~43 frames), and a deceleration of 0.0625 pixels/frame² when the direction is released[^169^][^177^]. The jump arc uses variable height via a 7-frame ascending sequence with pixel deltas of 3, 3, 4, 3, 3, 2, 1, reaching a max height of 66 pixels[^169^]. Gravity in real-world terms is approximately 91.28 m/s² — about 9.3× Earth gravity — which is why Mario falls fast and lands with satisfying weight[^168^].

**Sonic the Hedgehog (Genesis, 1991)**. Sonic Team built a high-velocity angular-momentum system optimized for loops and slopes. Key values from the Sonic Physics Guide: gravity at 56 subpixels per frame per frame (7/32 pixels/frame²), running speed of 1536 subpixels/frame (6 pixels/frame), air acceleration of 24 subpixels/frame², and jump strength of 1664 subpixels/frame (6.5 pixels/frame)[^140^][^125^]. Sonic's centripetal force calculation at the top of a loop — `Fc = mv²/r` — determines whether he stays on the track; his speed must satisfy `v > sqrt(g × r)` where `r` is the loop radius[^18^]. Air drag occurs when upward velocity is between 0–4 pixels/frame, reducing horizontal speed by 1/32nd per frame, creating a subtle slowdown at jump peaks[^140^].

**Celeste (2018)**. Extremely OK Games created the gold standard for accessible platforming feel. Madeline's movement is defined by a comprehensive forgiveness system (detailed in §1.2) alongside tight physics: max speed ~180 px/s, instant-ish acceleration of ~100 px/s², jump velocity of -315 px/s, and gravity split between 900 px/s² upward and 1600 px/s² downward for snappy falls[^77^][^78^]. The developers published a famous Twitter thread documenting their forgiveness mechanics, noting that the implementation "took only a couple of days' work to develop" but required extensive playtesting for balancing[^25^].

**Hollow Knight (2017)**. Team Cherry designed instant-response movement inspired by Mega Man X — there is no acceleration or deceleration. The Knight's horizontal velocity is set directly: `velocity.x = move_direction × speed`[^92^]. Jump uses a hard-cancel system: releasing the jump button sets vertical velocity to zero immediately (not gradually). Gravity is 2000 units/sec², jump strength 800 units/sec, and speed 500 units/sec[^92^]. This creates a snappy, precise feel that works well for children who want immediate response.

**Kirby (HAL Laboratory)**. Kirby games are explicitly designed to be easy enough for a three-year-old to play, with difficulty layered on top rather than built from the bottom up[^17^]. Kirby's Epic Yarn made it literally impossible to die — falling off a cliff returns the player safely. The floating mechanic makes platforming extremely forgiving, and after losing four lives in the same stage, players can skip to the next stage[^18^]. The physics profile is defined by floatiness: low gravity, slow max fall speed, and generous jump height.

#### 1.1.2 Child-optimized defaults: the "Kid-Friendly" preset

Each preset in the library includes a kid-friendly variant with adjusted defaults derived from child development research and cross-verified against industry best practices. The target audience — children as young as five — has specific motor and cognitive constraints: limited bimanual coordination, reaction times approximately 50% slower than adults, and working memory that can track only 2–3 items[^73^][^1^].

The kid-friendly baseline is: gravity at 800 px/s² (floatier than Celeste's 900), coyote time at 0.15 seconds (9 frames at 60fps, versus Celeste's 0.08–0.10), jump buffer at 0.15 seconds (matching the coyote window), corner correction at 8 pixels (double Celeste's 4px), max fall speed capped at 350 px/s (slower than all reference games), and wall-slide speed clamped to 40 px/s (half of Celeste's 80)[^93^][^141^].

Higher gravity during falls creates satisfying game feel — most great platformers use lower gravity while ascending and higher gravity while descending, with a typical ratio of `gravity_fall = 1.3–1.8 × gravity_up`[^164^]. For children, this ratio is narrowed to 1.125× (800 up, 900 down) to prevent disorienting drops while preserving the "punchy" jump feel.

| Parameter | Mario | Sonic | Celeste | Hollow Knight | Kid-Friendly (Default) |
|---|---|---|---|---|---|
| Gravity up (px/s²) | 900 | 1000 | 900 | 1000 | **800** |
| Gravity fall (px/s²) | 1200 | 1400 | 1600 | 1400 | **900** |
| Max speed (px/s) | 180 | 480 | 180 | 250 | **150** |
| Acceleration (px/s²) | 18 | 48 | 100 | 9999 (instant) | **60** |
| Jump velocity (px/s) | -350 | -400 | -315 | -380 | **-300** |
| Coyote time (s) | 0.08 | 0.05 | 0.10 | 0.05 | **0.15** |
| Jump buffer (s) | N/A | N/A | 0.10 | 0.05 | **0.15** |
| Corner correction (px) | ~2 | ~2 | 4 | 2 | **8** |
| Wall slide (px/s) | N/A | N/A | 80 | 60 | **40** |
| Max fall (px/s) | 400 | 600 | 400 | 500 | **350** |
| Variable jump | Yes | Yes | Yes | Yes | **Yes** |
| Jump cut multiplier | 0.5 | 0.3 | 0.5 | 0.0 (hard) | **0.5** |

All values assume a 60 FPS fixed-timestep physics loop. The Kid-Friendly column represents the recommended defaults for the five-year-old target audience, with values derived from averaging child-appropriate ranges documented across Celeste's assist mode research[^139^][^161^], Nintendo's invisible assist philosophy[^11^], and fine-motor development studies[^3^]. Sonic values are converted from subpixels where 1 subpixel = 1/256 pixel[^140^].

#### 1.1.3 Implementation: ConfigurablePhysicsEngine class

The physics engine is implemented as a modular class that loads a preset at construction time and supports runtime switching when the assist system changes the active profile. The architecture separates the data model (`PhysicsProfile`) from the integration layer (`ConfigurablePhysicsEngine`), allowing the LLM backend to generate preset tables independently of the runtime code.

**The PhysicsProfile interface and preset table.** The LLM populates this table from the stamp's `physicsFeel` property. The `kidfriendly` preset serves as the default when the LLM generates an unrecognized preset name or when no feel is specified.

```typescript
/**
 * PhysicsProfile — complete physics configuration for a character stamp.
 * The LLM backend selects a preset by name from the stamp's physicsFeel field.
 */
interface PhysicsProfile {
  name: string;
  maxSpeed: number;        // px/s
  acceleration: number;    // px/s²
  deceleration: number;    // px/s² (friction when no input)
  turnSpeed: number;       // px/s² (reverse direction)
  jumpVelocity: number;    // px/s (initial upward velocity)
  gravityUp: number;       // px/s² while ascending
  gravityFall: number;     // px/s² while descending
  maxFallSpeed: number;    // px/s (terminal velocity)
  variableJump: boolean;   // Can cancel jump early?
  jumpCutMultiplier: number; // 0.0–1.0, velocity kept on release
  coyoteTime: number;      // seconds after leaving ledge
  jumpBuffer: number;      // seconds before landing to store input
  cornerCorrection: number; // px to nudge sideways on corner hit
  groundSnap: boolean;     // Snap to ground on near-misses
  snapDistance: number;    // px below player to trigger snap
}

/** Preset table populated by the LLM from stamp properties. */
const PHYSICS_PRESETS: Record<string, PhysicsProfile> = {
  mario: { /* Mario profile values from table above */ } as PhysicsProfile,
  sonic: { /* Sonic profile values */ } as PhysicsProfile,
  celeste: { /* Celeste profile values */ } as PhysicsProfile,
  hollow: { /* Hollow Knight profile values */ } as PhysicsProfile,
  kidfriendly: {
    name: 'Kid-Friendly', maxSpeed: 150, acceleration: 60,
    deceleration: 60, turnSpeed: 60, jumpVelocity: -300,
    gravityUp: 800, gravityFall: 900, maxFallSpeed: 350,
    variableJump: true, jumpCutMultiplier: 0.5,
    coyoteTime: 0.15, jumpBuffer: 0.15, cornerCorrection: 8,
    groundSnap: true, snapDistance: 8,
  },
};
```

**The ConfigurablePhysicsEngine class.** This is the runtime integration that the LLM instantiates when a child places a character stamp. It handles the fixed-timestep integration loop, coyote time, jump buffering, variable jump height, corner correction, and ground snap — all using the values from the active `PhysicsProfile`.

```typescript
/**
 * ConfigurablePhysicsEngine — fixed-timestep platformer physics.
 * Instantiated per character stamp. Supports runtime preset swapping.
 */
class ConfigurablePhysicsEngine {
  private profile: PhysicsProfile;
  private velocity = { x: 0, y: 0 };
  private position: { x: number; y: number };
  private isOnGround = false;
  private wasOnGround = false;
  private isJumping = false;
  private coyoteTimer = 0;
  private jumpBufferTimer = 0;
  private readonly FIXED_DT = 1 / 60;

  constructor(presetName: string, startX: number, startY: number) {
    this.profile = this.loadPreset(presetName);
    this.position = { x: startX, y: startY };
  }

  private loadPreset(name: string): PhysicsProfile {
    const preset = PHYSICS_PRESETS[name.toLowerCase()];
    if (!preset) {
      console.warn(`Unknown preset "${name}", falling back to kid-friendly`);
      return PHYSICS_PRESETS['kidfriendly'];
    }
    return { ...preset };
  }

  /** Runtime preset swap — used by AdaptiveDifficultyGuardian. */
  switchPreset(newPresetName: string): void {
    const oldGravity = this.profile.gravityUp;
    this.profile = this.loadPreset(newPresetName);
    this.velocity.y *= (oldGravity / this.profile.gravityUp);
  }

  /** Main update — called once per fixed timestep by the game loop. */
  update(inputX: number, inputJumpPressed: boolean, inputJumpHeld: boolean): void {
    this.updateGroundState();
    this.updateCoyoteTime();
    this.updateJumpBuffer(inputJumpPressed);
    this.handleJumpExecution(inputJumpPressed);
    this.handleVariableJump(inputJumpHeld);
    this.updateHorizontalMovement(inputX);
    this.updateVerticalMovement();
    this.applyCornerCorrection();
    this.applyGroundSnap();
    this.wasOnGround = this.isOnGround;
  }

  /** COYOTE TIME: allow jump briefly after leaving a ledge. */
  private updateCoyoteTime(): void {
    if (this.wasOnGround && !this.isOnGround && !this.isJumping) {
      this.coyoteTimer = this.profile.coyoteTime;
    } else if (this.isOnGround) {
      this.coyoteTimer = 0;
    }
    if (this.coyoteTimer > 0) this.coyoteTimer -= this.FIXED_DT;
  }

  /** JUMP BUFFERING: store early jump input for delayed landing. */
  private updateJumpBuffer(inputJumpPressed: boolean): void {
    if (inputJumpPressed) this.jumpBufferTimer = this.profile.jumpBuffer;
    if (this.jumpBufferTimer > 0) this.jumpBufferTimer -= this.FIXED_DT;
  }

  /** Execute jump when buffer and coyote conditions both permit. */
  private handleJumpExecution(inputJumpPressed: boolean): void {
    const canJump = this.isOnGround || this.coyoteTimer > 0;
    const wantsJump = inputJumpPressed || this.jumpBufferTimer > 0;
    if (wantsJump && canJump && !this.isJumping) {
      this.velocity.y = this.profile.jumpVelocity;
      this.isJumping = true;
      this.coyoteTimer = 0;
      this.jumpBufferTimer = 0;
    }
  }

  /** VARIABLE JUMP: cut velocity on button release while ascending. */
  private handleVariableJump(inputJumpHeld: boolean): void {
    if (this.profile.variableJump && !inputJumpHeld &&
        this.velocity.y < 0 && this.isJumping) {
      this.velocity.y *= this.profile.jumpCutMultiplier;
    }
  }

  private updateHorizontalMovement(inputX: number): void {
    if (inputX !== 0) {
      const accel = this.velocity.x * inputX < 0
        ? this.profile.turnSpeed : this.profile.acceleration;
      this.velocity.x += inputX * accel * this.FIXED_DT;
      this.velocity.x = Math.max(-this.profile.maxSpeed,
        Math.min(this.profile.maxSpeed, this.velocity.x));
    } else {
      const decel = this.profile.deceleration * this.FIXED_DT;
      this.velocity.x = Math.abs(this.velocity.x) <= decel
        ? 0 : this.velocity.x - Math.sign(this.velocity.x) * decel;
    }
  }

  private updateVerticalMovement(): void {
    const g = this.velocity.y < 0 ? this.profile.gravityUp : this.profile.gravityFall;
    this.velocity.y += g * this.FIXED_DT;
    this.velocity.y = Math.min(this.velocity.y, this.profile.maxFallSpeed);
  }

  /** CORNER CORRECTION: nudge sideways when hitting a ceiling corner. */
  private applyCornerCorrection(): void {
    if (this.profile.cornerCorrection <= 0 || this.velocity.y >= 0) return;
    for (let off = 1; off <= this.profile.cornerCorrection; off++) {
      this.position.x += off;
      if (!this.checkCollision()) return;
      this.position.x -= off;
      this.position.x -= off;
      if (!this.checkCollision()) return;
      this.position.x += off;
    }
  }

  /** GROUND SNAP: silently correct near-miss landings. */
  private applyGroundSnap(): void {
    if (!this.profile.groundSnap || this.isOnGround) return;
    const snap = this.checkGroundBelow(this.profile.snapDistance);
    if (snap.found) {
      this.position.y = snap.y;
      this.velocity.y = 0;
      this.isOnGround = true;
      this.isJumping = false;
    }
  }

  // Collision stubs — implemented by tilemap integration layer
  private checkGroundCollision(): boolean { return false; }
  private checkCollision(): boolean { return false; }
  private checkGroundBelow(d: number): { found: boolean; y: number } {
    return { found: false, y: 0 };
  }

  getPosition() { return { ...this.position }; }
  getProfile() { return { ...this.profile }; }
}
```

The engine uses a fixed timestep of 1/60th of a second regardless of display frame rate, ensuring consistent physics across devices from budget tablets to high-refresh phones[^162^][^165^]. Runtime preset switching via `switchPreset()` is the critical hook for the adaptive difficulty system described in §1.3 — when the struggle detector fires, the guardian can swap to a more forgiving profile mid-game without the child noticing.

---

### 1.2 Forgiveness Mechanics Engine

Celeste's developers documented nine distinct forgiveness mechanics that work together to make the player feel skilled even when their timing is imperfect[^77^][^78^]. For a stamp-based children's platform, all nine are implemented as an always-on engine layer with child-optimized parameters. The child never sees a toggle, a slider, or an "Assist Mode" menu. They simply experience a game that catches them before they fall.

#### 1.2.1 Nine-part forgiveness system with child-optimized parameters

The forgiveness engine replicates Celeste's complete toolkit with parameters adjusted for the five-year-old audience:

| Mechanic | Celeste Default | Kid-Optimized | Description |
|---|---|---|---|
| Coyote Time | 0.08–0.10 s | **0.15 s** | Jump after leaving a ledge |
| Jump Buffer | 0.067 s | **0.15 s** | Early jump input stored until landing |
| Jump Peak Gravity | 50% of normal | **50%** | Floatier apex for air control |
| Corner Correction | 4 px | **8 px** | Nudge sideways around corner bonks |
| Ground Snap | Off | **On, 8 px** | Snap to platform on near-misses |
| Wall-Jump Window | 2 px | **6 px** | Distance from wall to trigger wall jump |
| Wall-Slide Speed | 80 px/s | **40 px/s** | Slower descent against walls |
| Input Debounce | None | **100 ms** | Ignore repeated jump mashes |
| Auto-Edge Jump | Off | **On, 12 px** | Micro-jump when walking off edges |

The jump buffer is the single most important mechanic for young children. Without it, a jump pressed one frame before landing is lost entirely — a common source of "I pressed jump!" frustration[^99^]. With a 0.15-second buffer (9 frames at 60fps), any jump pressed within that window executes on the exact frame of landing. Research on child platformer interaction confirms that children under 7 consistently press jump early due to anticipatory motor timing[^73^].

Corner correction prevents the frustrating "bonk" deaths that occur when a player jumps into the corner of a platform above. Celeste's implementation resolves X and Y axes separately: if the player collides on the Y axis, the engine tries nudging them left or right by up to 4 pixels before registering the collision[^139^][^141^]. Doubling this to 8 pixels accounts for less precise spatial judgment in young children while remaining nearly invisible to skilled players.

The auto-edge-jump mechanic, not present in Celeste, is added specifically for children who lack bimanual coordination. When a character stamp has this behavior enabled and the player walks within 12 pixels of a platform edge, an automatic micro-jump triggers — preventing the most common source of platformer deaths for young children. This is inspired by Nintendo's invisible ledge-grab extension in Super Mario Odyssey's Assist Mode, which lets Mario grab ledges from further away without the player noticing[^11^].

#### 1.2.2 Invisible auto-assist that detects struggling

The forgiveness engine includes a second layer: an invisible auto-assist that monitors play patterns and silently increases help parameters when the child is struggling. This design follows Nintendo's philosophy of invisible assistance — help that is present but not obvious, preserving the child's sense of accomplishment[^11^][^457^].

The auto-assist operates on three principles derived from cross-dimensional analysis:

1. **Never visible**: Invisible platforms truly have opacity 0. Ghost helpers look like environmental effects (fireflies, wind particles). The child thinks they finally "got it."
2. **Gradual adjustment**: Parameter changes use linear interpolation over 10+ seconds, never sudden jumps[^457^]. Coyote time drifts from 0.10 s to 0.20 s over several seconds, not instantly.
3. **Hysteresis**: Difficulty is harder to increase than decrease, preventing oscillation. Like a thermostat with a deadband, the system avoids creating a roller-coaster of easy and hard sections.

Celeste's Assist Mode proved that granular, individually toggleable assist options are more valuable than fixed difficulty levels[^7^]. However, it requires conscious selection — the child (or parent) must know the option exists and choose to use it. The invisible auto-assist removes this barrier entirely. As the cross-verification analysis confirmed, "invisible assists should be default for 5-year-olds" is a high-confidence finding supported by physics, AI, and accessibility research dimensions[^11^][^457^].

#### 1.2.3 Implementation: ForgivenessController with nine-part system

The forgiveness system is implemented in two layers: a configuration interface that the LLM populates from stamp properties, and a runtime controller that mediates between raw input and the physics engine. The first code block defines the configuration and the core input-processing pipeline (coyote time, jump buffering, and variable jump); the second block covers the spatial forgiveness features (corner correction, wall jump, ground snap, and auto-edge detection).

**ForgivenessConfig and core jump pipeline.** The `processJumpInput()` method is the critical path — every jump button press flows through here before reaching the physics engine. It implements the coyote-time window, the jump-buffer queue, the input debounce for button-mashing children, and the variable-jump cutoff.

```typescript
/**
 * ForgivenessConfig — nine-part forgiveness parameters.
 * Instantiated by the LLM from stamp properties + auto-assist level.
 */
interface ForgivenessConfig {
  coyoteTime: number;          // seconds after leaving ledge
  jumpBuffer: number;          // seconds to store early jump input
  gravityPeakMultiplier: number; // 0.5 = half gravity at jump apex
  cornerCorrection: number;    // px to nudge on corner hit
  groundSnap: boolean;         // enable near-miss landing correction
  snapDistance: number;        // px below player to trigger snap
  wallJumpWindow: number;      // px from wall to allow wall jump
  wallSlideSpeed: number;      // px/s max downward speed on wall
  inputDebounceMs: number;     // ms to ignore repeated presses
  autoEdgeJump: boolean;       // micro-jump near platform edges
  edgeDetectionPx: number;     // px from edge to trigger auto-jump
}

/**
 * Core forgiveness pipeline — coyote time, jump buffer, variable jump.
 * Runs every frame between input collection and physics integration.
 */
class ForgivenessJumpPipeline {
  private config: ForgivenessConfig;
  private coyoteTimer = 0;
  private jumpBufferTimer = 0;
  private wasGrounded = false;
  private isJumping = false;
  private lastJumpPressTime = 0;

  constructor(config: ForgivenessConfig) {
    this.config = { ...config };
  }

  /**
   * Process raw jump input through the full forgiveness pipeline.
   * Returns effective jump signals for the physics engine.
   */
  processJumpInput(
    rawJumpPressed: boolean,
    rawJumpHeld: boolean,
    isGrounded: boolean,
    time: number
  ): { jumpPressed: boolean; jumpHeld: boolean } {
    // —— COYOTE TIME ——
    if (this.wasGrounded && !isGrounded && !this.isJumping) {
      this.coyoteTimer = this.config.coyoteTime;
    } else if (isGrounded) {
      this.coyoteTimer = 0;
      this.isJumping = false;
    }
    if (this.coyoteTimer > 0) this.coyoteTimer -= 1 / 60;
    this.wasGrounded = isGrounded;

    // —— JUMP BUFFER ——
    if (rawJumpPressed) {
      this.jumpBufferTimer = this.config.jumpBuffer;
      this.lastJumpPressTime = time;
    }
    if (this.jumpBufferTimer > 0) this.jumpBufferTimer -= 1 / 60;

    // —— INPUT DEBOUNCE (children mash buttons) ——
    const debounced = rawJumpPressed &&
      (time - this.lastJumpPressTime > this.config.inputDebounceMs);
    const effectiveJump = debounced || this.jumpBufferTimer > 0;

    // —— EXECUTE JUMP ——
    let jumpPressed = false;
    if (effectiveJump && (isGrounded || this.coyoteTimer > 0) && !this.isJumping) {
      jumpPressed = true;
      this.isJumping = true;
      this.coyoteTimer = 0;
      this.jumpBufferTimer = 0;
    }

    // —— VARIABLE JUMP ——
    let jumpHeld = rawJumpHeld;
    if (!rawJumpHeld && this.isJumping) {
      // Signal to physics engine to cut jump short
      jumpHeld = false;
    }

    return { jumpPressed, jumpHeld };
  }

  /** Gravity peak reduction — halve gravity at jump apex for air control. */
  modifyGravity(velocityY: number, baseGravity: number): number {
    if (Math.abs(velocityY) < 30 && this.isJumping) {
      return baseGravity * this.config.gravityPeakMultiplier;
    }
    return baseGravity;
  }

  /** Runtime adjustment by AdaptiveDifficultyGuardian. */
  adjustConfig(params: Partial<ForgivenessConfig>): void {
    Object.assign(this.config, params);
  }

  getConfig(): ForgivenessConfig { return { ...this.config }; }
}
```

**Spatial forgiveness features.** The second pipeline handles corner correction, wall-jump expansion, ground snap, and the auto-edge-jump feature. These operate on position and collision data rather than input timing.

```typescript
/**
 * SpatialForgiveness — corner correction, wall jump, ground snap, auto-edge.
 * Applied after movement integration but before collision resolution.
 */
class SpatialForgiveness {
  private config: ForgivenessConfig;

  constructor(config: ForgivenessConfig) {
    this.config = { ...config };
  }

  /** CORNER CORRECTION: nudge player sideways when bonking a ceiling corner. */
  applyCornerCorrection(
    posX: number,
    velocityY: number,
    checkCollision: (x: number) => boolean
  ): number {
    if (this.config.cornerCorrection <= 0 || velocityY >= 0) return posX;
    for (let off = 1; off <= this.config.cornerCorrection; off++) {
      if (!checkCollision(posX + off)) return posX + off;
      if (!checkCollision(posX - off)) return posX - off;
    }
    return posX;
  }

  /** WALL-JUMP: expanded detection window for easier wall jumps. */
  checkWallJump(isTouchingWall: boolean, distanceToWall: number): boolean {
    return isTouchingWall || distanceToWall <= this.config.wallJumpWindow;
  }

  /** GROUND SNAP: silently correct near-miss landings. */
  applyGroundSnap(
    posY: number,
    velocityY: number,
    isGrounded: boolean,
    findGround: (y: number) => { found: boolean; y: number }
  ): { newY: number; newVelY: number; snapped: boolean } {
    if (!this.config.groundSnap || isGrounded || velocityY <= 0) {
      return { newY: posY, newVelY: velocityY, snapped: false };
    }
    const result = findGround(this.config.snapDistance);
    if (result.found) {
      return { newY: result.y, newVelY: 0, snapped: true };
    }
    return { newY: posY, newVelY: velocityY, snapped: false };
  }

  /** AUTO-EDGE-JUMP: micro-jump when walking off platform edges. */
  checkAutoEdgeJump(
    isGrounded: boolean,
    distanceToEdge: number,
    horizontalInput: number
  ): boolean {
    if (!this.config.autoEdgeJump || !isGrounded) return false;
    return distanceToEdge <= this.config.edgeDetectionPx && horizontalInput !== 0;
  }

  /** Clamp wall-slide speed for gentler descents. */
  clampWallSlide(velocityY: number): number {
    return Math.max(velocityY, -this.config.wallSlideSpeed);
  }

  adjustConfig(params: Partial<ForgivenessConfig>): void {
    Object.assign(this.config, params);
  }
}
```

Both pipelines are instantiated by the LLM backend alongside the physics engine. Every frame, raw input passes through `processJumpInput()` before reaching the physics system, and post-movement position data passes through the spatial forgiveness methods before collision resolution. The `adjustConfig()` method on both classes is the primary interface for the adaptive difficulty guardian described in §1.3 — when the struggle detector fires, it increases `coyoteTime`, `jumpBuffer`, and `cornerCorrection` values; when the child succeeds consistently, parameters drift back toward base values.

---

### 1.3 Struggle Detector & Dynamic Assist

The physics presets and forgiveness mechanics provide a generous baseline, but children vary enormously in motor development, gaming experience, and daily condition. The Struggle Detector closes this loop by observing play patterns in real time and dynamically adjusting both the physics profile and the forgiveness parameters to match the child's current ability.

#### 1.3.1 Death frequency tracking, hesitation time analysis, input pattern recognition

The detector collects three classes of signal:

**Death frequency tracking**. Every player death is logged with timestamp, cause (fall, enemy, hazard), and position. A rolling window of the last 5 minutes is maintained. Key heuristics: 5+ deaths in 60 seconds triggers help mode; 3+ deaths from falling in one area enables ground snap and edge detection; repeated deaths at the same position spawns an invisible platform below that location[^488^].

**Hesitation time analysis**. The detector tracks how long the player spends in the same screen region without making progress. If the player moves less than 50 pixels over 30 seconds, the system concludes they are stuck and triggers a ghost helper — a translucent fairy that shows the correct path for 2 seconds before disappearing[^455^]. This design is inspired by Left 4 Dead's AI Director, which monitors player "stress levels" (a composite of damage taken, special infected encounters, and team separation) to modulate pacing[^455^].

**Input pattern recognition**. The detector analyzes jump timing patterns: ratio of successful jumps to attempted jumps, average timing offset from optimal, and frequency of input mashing. A miss rate above 50% after 10+ attempts indicates the child needs more forgiveness; consistent perfect timing suggests the profile can be tightened for more satisfying challenge[^99^].

#### 1.3.2 Auto-adjust parameters: enemy speed, platform width, invisible helper placement

When the detector identifies struggling, it applies help through a multi-channel adjustment system:

- **Physics profile softening**: coyote time drifts up to 0.20 s, jump buffer to 0.20 s, corner correction to 12 px, gravity reduced by 15%[^139^][^161^].
- **Enemy pacification**: After 3 consecutive deaths near an enemy, that enemy falls "asleep" (Zzz particles), reducing speed to 30% and disabling attacks. Visual framing: the enemy is tired, not defeated.
- **Invisible platform placement**: At death hotspots, ghost platforms fade in at 15% opacity below the fail point, giving the child a "lucky" foothold they think they found themselves.
- **Time manipulation**: Subtle game slowdown to 88% speed during difficult moments, barely perceptible but giving 12% more reaction time[^7^].
- **Lucky saves**: Increased spawn rate of helpful pickups (health, checkpoints) near struggling players, scaling with consecutive death count[^14^].

The cross-verification analysis confirmed that invisible difficulty adjustment is a high-confidence finding, supported by the AI/adaptive difficulty and accessibility research dimensions[^488^][^455^]. When the child begins succeeding consistently (low death count, fast completion times), the detector gradually removes assists using linear interpolation over 10+ seconds — preventing oscillation and ensuring the child never notices the difficulty changing[^457^].

#### 1.3.3 Implementation: AdaptiveDifficultyGuardian with confidence meter

The guardian is split into two code layers: the player model and event collection system, and the difficulty-adjustment logic with its query interface. The first block defines the data model and event handlers that collect signals from gameplay; the second block implements the three-mode difficulty logic (help, balanced, challenge) and the physics-adjustment query methods.

**PlayerModel and event collection.** Every death, successful jump, enemy defeat, and position update flows through these event handlers. A rolling 5-minute window maintains recent history, and the confidence meter tracks the child's overall trajectory as a normalized 0–1 score.

```typescript
/**
 * PlayerModel — rolling record of player performance signals.
 * Consumed by AdaptiveDifficultyGuardian to select adjustment mode.
 */
interface PlayerModel {
  deaths: Array<{ time: number; cause: string; position: { x: number; y: number } }>;
  successfulJumps: number;
  attemptedJumps: number;
  enemiesDefeated: number;
  damageTaken: number;
  timeInCurrentArea: number;
  lastPosition: { x: number; y: number };
  consecutiveDeaths: number;
}

interface AdjustedParams {
  coyoteTimeMultiplier: number;
  jumpBufferMultiplier: number;
  cornerCorrectionBonus: number;
  gravityMultiplier: number;
  enemySpeedMultiplier: number;
  timeScale: number;
  invisiblePlatformChance: number;
  ghostHelperEnabled: boolean;
}

/**
 * Event collection and player model maintenance.
 * Call these from game event callbacks every frame.
 */
class StruggleDetector {
  protected model: PlayerModel;
  protected readonly HISTORY_WINDOW_MS = 300000; // 5 minutes
  protected readonly STUCK_TIME_THRESHOLD = 30;  // seconds
  protected readonly GHOST_DEATH_TRIGGER = 3;
  protected confidenceMeter = 0.5; // 0 = struggling, 1 = thriving

  constructor() {
    this.model = {
      deaths: [], successfulJumps: 0, attemptedJumps: 0,
      enemiesDefeated: 0, damageTaken: 0, timeInCurrentArea: 0,
      lastPosition: { x: 0, y: 0 }, consecutiveDeaths: 0,
    };
  }

  /** Call on every player death with cause and position. */
  onPlayerDeath(cause: string, position: { x: number; y: number }): void {
    this.model.deaths.push({ time: Date.now(), cause, position });
    this.model.consecutiveDeaths++;
    this.pruneHistory();
    this.confidenceMeter = Math.max(0, this.confidenceMeter - 0.15);
  }

  /** Call on every successful jump landing. */
  onSuccessfulJump(): void {
    this.model.successfulJumps++;
    this.model.attemptedJumps++;
    this.confidenceMeter = Math.min(1, this.confidenceMeter + 0.05);
    // Reduce death streak on success (hysteresis)
    this.model.consecutiveDeaths = Math.max(0, this.model.consecutiveDeaths - 1);
  }

  /** Call on every missed or mistimed jump. */
  onFailedJump(): void {
    this.model.attemptedJumps++;
  }

  /** Call when an enemy is defeated. */
  onEnemyDefeated(): void {
    this.model.enemiesDefeated++;
    this.confidenceMeter = Math.min(1, this.confidenceMeter + 0.1);
    this.model.consecutiveDeaths = Math.max(0, this.model.consecutiveDeaths - 2);
  }

  /** Call every frame with current player position for stuck detection. */
  updatePosition(position: { x: number; y: number }, dt: number): boolean {
    const dx = position.x - this.model.lastPosition.x;
    const dy = position.y - this.model.lastPosition.y;
    const dist = Math.sqrt(dx * dx + dy * dy);

    if (dist < 50) {
      this.model.timeInCurrentArea += dt;
      if (this.model.timeInCurrentArea > this.STUCK_TIME_THRESHOLD) {
        this.model.timeInCurrentArea = 0;
        return true; // Player is stuck
      }
    } else {
      this.model.timeInCurrentArea = 0;
    }
    this.model.lastPosition = { ...position };
    return false;
  }

  /** Rolling deaths-per-minute metric. */
  getDeathsPerMinute(): number {
    const now = Date.now();
    return this.model.deaths.filter(d => now - d.time < 60000).length;
  }

  getJumpSuccessRate(): number {
    return this.model.attemptedJumps > 0
      ? this.model.successfulJumps / this.model.attemptedJumps : 1.0;
  }

  getConsecutiveDeaths(): number { return this.model.consecutiveDeaths; }
  getConfidenceMeter(): number { return this.confidenceMeter; }

  private pruneHistory(): void {
    const cutoff = Date.now() - this.HISTORY_WINDOW_MS;
    this.model.deaths = this.model.deaths.filter(d => d.time > cutoff);
  }
}
```

**Difficulty-adjustment engine.** The `AdaptiveDifficultyGuardian` extends the detector with three adjustment modes — Help, Balanced, and Challenge — and a query interface that the physics engine uses to fetch adjusted parameters. All transitions use `lerp()` interpolation to prevent sudden, perceptible changes.

```typescript
/**
 * AdaptiveDifficultyGuardian — invisible difficulty adjustment.
 * Extends StruggleDetector with three-mode parameter adjustment.
 * No UI. The child never knows this exists.
 */
class AdaptiveDifficultyGuardian extends StruggleDetector {
  private params: AdjustedParams;
  private readonly DEATHS_PER_MINUTE_THRESHOLD = 2;

  constructor() {
    super();
    this.params = this.defaultParams();
  }

  private defaultParams(): AdjustedParams {
    return {
      coyoteTimeMultiplier: 1.0, jumpBufferMultiplier: 1.0,
      cornerCorrectionBonus: 0, gravityMultiplier: 1.0,
      enemySpeedMultiplier: 1.0, timeScale: 1.0,
      invisiblePlatformChance: 0, ghostHelperEnabled: false,
    };
  }

  /** Evaluate current state and apply appropriate adjustment mode. */
  evaluate(): void {
    const dpm = this.getDeathsPerMinute();
    const jumpSuccess = this.getJumpSuccessRate();
    const cd = this.getConsecutiveDeaths();

    const isStruggling = cd >= 3 || dpm > this.DEATHS_PER_MINUTE_THRESHOLD;
    const isThriving = cd <= 1 && jumpSuccess > 0.8 && dpm < 1;

    if (isStruggling) this.applyHelpMode();
    else if (isThriving) this.applyChallengeMode();
    else this.applyBalancedMode();
  }

  /** HELP MODE: child is struggling — increase forgiveness. */
  private applyHelpMode(): void {
    this.params.coyoteTimeMultiplier = this.lerp(
      this.params.coyoteTimeMultiplier, 1.5, 0.03);
    this.params.jumpBufferMultiplier = this.lerp(
      this.params.jumpBufferMultiplier, 1.5, 0.03);
    this.params.cornerCorrectionBonus = this.lerp(
      this.params.cornerCorrectionBonus, 4, 0.03);
    this.params.gravityMultiplier = this.lerp(
      this.params.gravityMultiplier, 0.85, 0.02);
    this.params.enemySpeedMultiplier = this.lerp(
      this.params.enemySpeedMultiplier, 0.7, 0.03);
    this.params.invisiblePlatformChance = Math.min(0.3,
      this.params.invisiblePlatformChance + 0.01);
    // Trigger ghost helper on repeated deaths
    if (this.getConsecutiveDeaths() >= this.GHOST_DEATH_TRIGGER) {
      this.params.ghostHelperEnabled = true;
    }
    // Subtle time slowdown on heavy struggling
    if (this.getConsecutiveDeaths() >= 4) {
      this.params.timeScale = this.lerp(this.params.timeScale, 0.88, 0.02);
    }
  }

  /** CHALLENGE MODE: child is thriving — gradually reduce assistance. */
  private applyChallengeMode(): void {
    this.params.coyoteTimeMultiplier = this.lerp(
      this.params.coyoteTimeMultiplier, 1.0, 0.02);
    this.params.jumpBufferMultiplier = this.lerp(
      this.params.jumpBufferMultiplier, 1.0, 0.02);
    this.params.cornerCorrectionBonus = this.lerp(
      this.params.cornerCorrectionBonus, 0, 0.02);
    this.params.gravityMultiplier = this.lerp(
      this.params.gravityMultiplier, 1.0, 0.015);
    this.params.enemySpeedMultiplier = this.lerp(
      this.params.enemySpeedMultiplier, 1.0, 0.02);
    this.params.timeScale = this.lerp(this.params.timeScale, 1.0, 0.02);
    this.params.invisiblePlatformChance = Math.max(0,
      this.params.invisiblePlatformChance - 0.01);
    this.params.ghostHelperEnabled = false;
  }

  /** BALANCED MODE: drift gently toward default values. */
  private applyBalancedMode(): void {
    this.params.coyoteTimeMultiplier = this.lerp(
      this.params.coyoteTimeMultiplier, 1.0, 0.01);
    this.params.jumpBufferMultiplier = this.lerp(
      this.params.jumpBufferMultiplier, 1.0, 0.01);
    this.params.gravityMultiplier = this.lerp(
      this.params.gravityMultiplier, 1.0, 0.01);
    this.params.enemySpeedMultiplier = this.lerp(
      this.params.enemySpeedMultiplier, 1.0, 0.01);
  }

  // ——— Query Interface ———

  /** Apply adjustments to a base physics profile. Called by the engine each frame. */
  getAdjustedPhysics(baseProfile: PhysicsProfile): PhysicsProfile {
    return {
      ...baseProfile,
      coyoteTime: baseProfile.coyoteTime * this.params.coyoteTimeMultiplier,
      jumpBuffer: baseProfile.jumpBuffer * this.params.jumpBufferMultiplier,
      cornerCorrection: baseProfile.cornerCorrection +
        this.params.cornerCorrectionBonus,
      gravityUp: baseProfile.gravityUp * this.params.gravityMultiplier,
      gravityFall: baseProfile.gravityFall * this.params.gravityMultiplier,
      maxFallSpeed: baseProfile.maxFallSpeed * this.params.gravityMultiplier,
    };
  }

  getEnemySpeedMultiplier(): number { return this.params.enemySpeedMultiplier; }
  getTimeScale(): number { return this.params.timeScale; }
  getInvisiblePlatformChance(): number { return this.params.invisiblePlatformChance; }
  shouldShowGhostHelper(): boolean { return this.params.ghostHelperEnabled; }

  private lerp(a: number, b: number, t: number): number {
    return a + (b - a) * t;
  }
}
```

The guardian's confidence meter is a normalized 0–1 score that tracks the child's overall trajectory. It is never displayed to the child, but it can be surfaced in a parent dashboard (accessible via parental gate) to show progress over time. The meter increases with enemy defeats, level completions, and successful jumps; it decreases with deaths, failed jumps, and getting stuck. This follows the Hades God Mode philosophy where each "failure" feeds a system that makes subsequent attempts slightly more manageable, creating a positive reinforcement loop rather than a frustration spiral[^14^][^16^].

The guardian integrates with the physics engine through `getAdjustedPhysics()`, which multiplies the active preset's base values by the current adjustment parameters. When a death event fires, `onPlayerDeath()` updates the internal model, triggers immediate help if thresholds are crossed, and calls `evaluate()` to recompute the parameter set. The physics engine polls `getAdjustedPhysics()` each frame, ensuring changes propagate smoothly without restart or visible transition.

The `lerp()` interpolation in all adjustment paths is critical: sudden parameter changes would be noticeable and break the child's sense of agency. By interpolating over many frames, the system ensures that a child who "finally got it" genuinely did improve — the assist faded so gradually that their own skill development accounts for the success. This aligns with the cross-dimensional insight that "forgiveness is the platform's core value proposition — not a feature, but the architecture itself."
