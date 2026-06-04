## 4. Traversal & Movement Features

Movement abilities transform a static platformer into an expressive traversal playground. Research across five studio innovators reveals that every complex movement mechanic decomposes into simple primitives: a grapple is a rope joint plus pendulum force plus release timing; a wall-jump is surface detection plus direction reversal plus impulse force; a transformation is a state change with swapped physics parameters [^68^][^67^][^65^]. For a stamp-based platform, each ability reduces to a single stamp placement that triggers automatic LLM-generated physics code. The child places a "Grapple Hook Stamp" — the LLM handles the pendulum math, collision detection, and auto-release logic.

This chapter designs the complete movement stamp architecture: a five-tier progressive unlock system, a grapple physics engine with visual trajectory preview, and a transformation state machine with automatic context-aware switching. Every system is built around the same insight: children as young as 5 need auto-activation, visual previews, and invisible forgiveness mechanics like coyote time and input buffering [^13^][^73^].

### 4.1 Movement Stamp Library

#### 4.1.1 Five-Tier Progressive Unlock System

Progressive disclosure is a cognitive necessity for young children. Research shows children under 5 struggle with complex motor coordination, with reaction times averaging 200–250ms — significantly slower than adults [^73^][^134^]. The platform implements a five-tier unlock system where each tier introduces exactly one new mechanical concept, and stamps unlock only after demonstrated competence [^164^].

The `MovementAbilityManager` class serves as the central registry. It validates unlock progression via a directed acyclic graph of dependencies — a child cannot place Wall Jump before Double Jump, nor Super Dash before Dash. These gates are soft: the UI shows locked stamps grayed out with messages like "Complete 2 more levels to unlock!" preserving anticipation and goal clarity [^164^]. The manager also auto-enables invisible assists: coyote time (50–100ms window to jump after leaving a platform), jump input buffering (registering jump 50ms before landing), and auto-wall-slide. Research confirms that Celeste's nine forgiveness mechanics, not its raw physics parameters, make its controls feel satisfying [^13^].

```typescript
/**
 * MovementAbilityManager — Central coordinator for all movement stamps.
 * Handles: unlock progression, dependency validation, soft-lock prevention,
 * single-button context routing, and invisible assist tuning.
 */
class MovementAbilityManager {
  /** Dependency graph: ability → prerequisite ability IDs */
  private dependencyGraph: Map<string, string[]> = new Map([
    ["double_jump", []],
    ["wall_jump", ["double_jump"]],
    ["dash", ["double_jump"]],
    ["glide", ["double_jump"]],
    ["ground_pound", ["dash"]],
    ["grapple", ["dash", "wall_jump"]],
    ["super_dash", ["dash"]],
    ["fish_form", ["glide"]],
    ["spider_form", ["wall_jump", "grapple"]],
    ["bird_form", ["glide", "fish_form"]],
    ["bash", ["grapple", "super_dash"]],
  ]);

  private unlockedAbilities: Set<string> = new Set(["walk", "jump"]);
  private equippedAbilities: Map<string, MovementAbility> = new Map();
  private readonly MAX_ABILITY_SLOTS = 3;

  /** Invisible assists — auto-tuned by StruggleDetector */
  public assists = {
    coyoteTimeMs: 50, jumpBufferMs: 50, wallSlideSpeed: 50, autoAimAngle: Math.PI / 6,
  };

  constructor(private player: Player) { this.configureDefaultAssists(); }

  /** Equip a stamp. Validates unlock status, dependencies, and slot count. */
  equipAbility(stampId: string, ability: MovementAbility): boolean {
    if (!this.isUnlocked(stampId)) { this.showUnlockHint(stampId); return false; }
    if (!this.dependenciesMet(stampId)) { this.showDependencyHint(stampId); return false; }
    if (this.equippedAbilities.size >= this.MAX_ABILITY_SLOTS) {
      this.showSlotFullHint(); return false;
    }
    this.equippedAbilities.set(stampId, ability);
    this.onAbilitiesChanged();
    return true;
  }

  /**
   * Remove an equipped ability. CRITICAL: checks for soft-lock first.
   * If removal would make any level section unreachable, blocks and warns.
   */
  unequipAbility(stampId: string): boolean {
    if (this.wouldCauseSoftLock(stampId)) {
      const remaining = Array.from(this.equippedAbilities.keys())
        .filter(id => id !== stampId);
      const unreachable = this.player.level.getUnreachableAreas(remaining);
      this.player.level.highlightAreas(unreachable, "warning");
      return false;
    }
    this.equippedAbilities.delete(stampId);
    this.onAbilitiesChanged();
    return true;
  }

  /** Single action button — context-aware routing to the correct ability. */
  handleAction(context: ActionContext): boolean {
    if (!context.isOnGround && context.inputDown && this.has("ground_pound"))
      return this.get("ground_pound")!.activate();
    if (context.isTouchingWall && this.has("wall_jump"))
      return this.get("wall_jump")!.activate(context.wallDirection);
    if (context.nearGrapplePoint && this.has("grapple"))
      return this.get("grapple")!.activate(context.grapplePoint!);
    if (this.has("dash") && this.get("dash")!.canActivate())
      return this.get("dash")!.activate();
    if (!context.isOnGround && this.has("double_jump") &&
        this.get("double_jump")!.canActivate())
      return this.get("double_jump")!.activate();
    if (context.isOnGround) return this.player.jump();
    return false;
  }

  /** Soft-lock prevention: verify all sections remain reachable post-removal. */
  private wouldCauseSoftLock(removingId: string): boolean {
    const remaining = Array.from(this.equippedAbilities.keys())
      .filter(id => id !== removingId);
    return !this.player.level.isFullyReachable(remaining);
  }

  private dependenciesMet(id: string): boolean {
    return (this.dependencyGraph.get(id) || [])
      .every(dep => this.equippedAbilities.has(dep));
  }
  private configureDefaultAssists(): void {
    if (this.player.getAgeProfile() === "mellow") {
      this.assists.coyoteTimeMs = 100;
      this.assists.jumpBufferMs = 100;
      this.assists.wallSlideSpeed = 30;
    }
  }
  private onAbilitiesChanged(): void {
    this.player.level.onAbilitiesChanged(Array.from(this.equippedAbilities.keys()));
  }
  private has(id: string): boolean { return this.equippedAbilities.has(id); }
  private get(id: string): MovementAbility | undefined { return this.equippedAbilities.get(id); }
  private isUnlocked(id: string): boolean { return this.unlockedAbilities.has(id); }
  private showUnlockHint(id: string): void {}
  private showDependencyHint(id: string): void {}
  private showSlotFullHint(): void {}
}

interface Player {
  jump(): boolean; level: LevelPathfinder;
  getAgeProfile(): "mellow" | "growing" | "creator";
}
interface MovementAbility { activate(arg?: unknown): boolean; canActivate?(): boolean; }
interface ActionContext {
  isOnGround: boolean; isTouchingWall: boolean; inputDown: boolean;
  nearGrapplePoint: boolean; grapplePoint?: { x: number; y: number };
  wallDirection: number;
}
interface LevelPathfinder {
  isFullyReachable(abilities: string[]): boolean;
  getUnreachableAreas(abilities: string[]): Array<{ x: number; y: number }>;
  highlightAreas(areas: Array<{ x: number; y: number }>, color: string): void;
  onAbilitiesChanged(abilities: string[]): void;
}
```

#### 4.1.2 Pre-Packaged Character Variant Stamps

Pre-packaged character variants provide a simple entry point. A child who wants a bouncy platformer selects the "Jumper Character Stamp" — a complete physics and ability package requiring zero configuration. These character stamps serve as "starter decks" that implicitly teach how movement abilities combine [^11^][^151^].

| Character Variant | Included Abilities | Physics Profile | Feel Reference |
|---|---|---|---|
| **Mario-style Jumper** | Double Jump, Ground Pound | Gravity 900 px/s², Jump force 450 px/s, Variable hold height [^151^] | Snappy, weighty jumps with high fall multiplier |
| **Sonic-style Speedster** | Dash, Wall Jump | Gravity 700 px/s², Max speed 400 px/s, Fast acceleration [^157^] | Momentum-based, rewards downhill speed |
| **Ori-style Flyer** | Glide, Double Jump, Wall Jump | Gravity 500 px/s², Glide descent 40 px/s, Air control 0.9 [^14^] | Floaty, precise aerial control |

Each variant carries a complete `PhysicsProfile` that the LLM injects into the generated game. When a child places the "Mario-style Jumper" stamp, the LLM generates code with Mario's exact variable gravity system — lower gravity during ascent when the button is held, higher gravity during descent — creating that iconic snappy jump feel [^151^]. The child never sees a physics parameter; they pick the character that "feels right."

#### 4.1.3 Soft-Lock Prevention and Ability-Aware Pathfinding

The most critical safety feature is soft-lock prevention. If a child removes a movement stamp their level requires, they strand themselves in an unbeatable game [^79^]. The `MovementAbilityManager` solves this at two levels.

Pre-removal validation queries the level's pathfinding graph with the reduced ability set. The navigation mesh annotates required movement capabilities — gaps wider than base jump require Double Jump or Dash; vertical shafts require Wall Jump or Grapple. When `unequipAbility` is called, the manager checks if every platform remains reachable. If not, removal is blocked and unreachable areas highlight in amber [^79^].

Runtime protection adds emergency fallback abilities. If a child reaches an area without the required stamp, the system grants a temporary "struggle assist" — reduced functionality of the missing ability. If stuck at a wall-jump shaft without Wall Jump, the system quietly adds a tiny upward bounce on wall contact, making the obstacle barely surmountable without the assist being visible.

### 4.2 Grapple Physics & Swing Mechanics

#### 4.2.1 Bionic Commando-Inspired Pendulum Physics

Bionic Commando replaced jumping entirely with a mechanical grappling arm — the hook fires at multiple angles and the player swings as a pendulum, with cable length determining swing arc [^75^][^77^]. Unlike real physics, the swing never loses momentum; the player can swing indefinitely waiting for the right release moment [^77^].

For the stamp platform, this simplifies dramatically. The child places a "Grapple Point Stamp" on a ceiling and a "Grapple Ability Stamp" on their character; the LLM generates the complete pendulum simulation. One-button activation: when the character enters 80 pixels of a grapple point, a visual indicator appears; pressing the action button attaches the rope and begins auto-swinging [^68^].

The pendulum simulation uses `angular_acceleration = -(gravity / rope_length) * sin(angle)`. A momentum boost near the swing bottom creates a satisfying "whip." Auto-release monitors angle and velocity, releasing at 45–60 degrees on the forward swing — the optimal launch point for maximum distance [^68^]. The child decides when to start swinging; the computer handles everything else.

```typescript
/**
 * GrapplePhysicsEngine — Pendulum simulation with auto-swing and auto-release.
 * LLM generates this when "Grapple Stamp" + "Grapple Point Stamp" are placed.
 */
class GrapplePhysicsEngine {
  private playerX: number; private playerY: number;
  private readonly anchorX: number; private readonly anchorY: number;
  private readonly ropeLength: number;
  private angle: number; private angularVelocity: number; private angularAcceleration: number;

  private readonly GRAVITY = 0.5; private readonly SWING_BOOST = 0.025;
  private readonly DAMPING = 0.995; private readonly MIN_VELOCITY = 0.001;
  private readonly RELEASE_MIN = Math.PI / 4; private readonly RELEASE_MAX = Math.PI / 3;
  private readonly LAUNCH_MULT = 1.5;
  public isSwinging = false;

  constructor(playerPos: Vec2, anchorPos: Vec2, ropeLength: number) {
    this.playerX = playerPos.x; this.playerY = playerPos.y;
    this.anchorX = anchorPos.x; this.anchorY = anchorPos.y;
    this.ropeLength = ropeLength;
    const dx = this.playerX - this.anchorX, dy = this.playerY - this.anchorY;
    this.angle = Math.atan2(dx, dy);
    this.angularVelocity = 0; this.angularAcceleration = 0;
  }

  /** Per-frame physics update. Returns new player position. */
  update(): Vec2 {
    this.angularAcceleration = -(this.GRAVITY / this.ropeLength) * Math.sin(this.angle);
    if (Math.abs(this.angle) < 0.2 && Math.abs(this.angularVelocity) > 0.01)
      this.angularAcceleration += this.SWING_BOOST * Math.sign(this.angularVelocity);
    this.angularVelocity += this.angularAcceleration;
    this.angularVelocity *= this.DAMPING;
    this.angle += this.angularVelocity;
    this.playerX = this.anchorX + this.ropeLength * Math.sin(this.angle);
    this.playerY = this.anchorY + this.ropeLength * Math.cos(this.angle);
    return { x: this.playerX, y: this.playerY };
  }

  /** Auto-release at optimal angle — zero child skill required. */
  shouldAutoRelease(): boolean {
    const angleDeg = Math.abs(this.angle * 180 / Math.PI);
    const movingForward = this.angularVelocity * this.angle > 0;
    return angleDeg >= 45 && angleDeg <= 60 && movingForward
      && Math.abs(this.angularVelocity) > this.MIN_VELOCITY;
  }

  /** Compute launch velocity with satisfying boost. */
  computeReleaseVelocity(): Vec2 {
    const speed = this.angularVelocity * this.ropeLength;
    return {
      x: speed * Math.cos(this.angle) * this.LAUNCH_MULT,
      y: -speed * Math.sin(this.angle) * this.LAUNCH_MULT,
    };
  }

  /** Generate dotted-line trajectory preview points. */
  getTrajectoryPreview(numPoints = 30): Vec2[] {
    const points: Vec2[] = [];
    let simAngle = this.angle, simVel = this.angularVelocity;
    for (let i = 0; i < numPoints; i++) {
      const acc = -(this.GRAVITY / this.ropeLength) * Math.sin(simAngle);
      simVel += acc; simVel *= this.DAMPING; simAngle += simVel;
      points.push({
        x: this.anchorX + this.ropeLength * Math.sin(simAngle),
        y: this.anchorY + this.ropeLength * Math.cos(simAngle),
      });
    }
    return points;
  }

  /** Safety: auto-detach if swing goes off-screen or stalls. */
  checkBoundaryViolation(bounds: Rect): boolean {
    return this.playerX < bounds.x || this.playerX > bounds.x + bounds.w
      || this.playerY < bounds.y || this.playerY > bounds.y + bounds.h;
  }
  isStalled(): boolean { return Math.abs(this.angularVelocity) < this.MIN_VELOCITY; }

  attach(): void { this.isSwinging = true; }
  detach(): void { this.isSwinging = false; }
}

interface Vec2 { x: number; y: number; }
interface Rect { x: number; y: number; w: number; h: number; }
```

#### 4.2.2 Visual Trajectory Preview

Children need to see where they are going before committing [^14^]. When the character enters activation range of a grapple point, the engine calls `getTrajectoryPreview(30)` and renders the points as a dashed line fading from opaque white near the character to transparent at the arc's end.

The preview transforms trial-and-error into informed decision-making: the child sees the arc, judges whether it reaches the desired platform, and only then presses the button. It provides diegetic feedback reinforcing cause and effect — a core cognitive skill for ages 5–7 [^134^]. The dotted line says "if you press the button here, this is where you will go" without any text.

Auto-release timing is tuned for satisfaction over realism. The 45–60 degree release window was chosen empirically — too early produces shallow arcs, too late produces near-vertical launches. The 1.5x velocity multiplier adds a satisfying "boost." These values are parameterized so the LLM adjusts them per-level based on gap sizes.

### 4.3 Transformation State Machine

#### 4.3.1 Shantae-Inspired Animal Form Stamps

The Shantae series demonstrates that transformations are complete player-state replacements. The Monkey form has a smaller collision box and can climb walls. The Elephant form trades mobility for destructive power. The Harpy form redefines gravity [^65^][^72^]. Each is a distinct state in a finite state machine with unique physics, collision shapes, and ability bindings [^99^].

For the stamp platform, each "Animal Form Stamp" is a self-contained physics profile. The child places a form stamp and the LLM produces: a state transition table, physics parameters, collision adjustments, and auto-transform rules. Placing both a "Fish Stamp" and "Water Zone Stamp" generates: `if terrain == 'water' → transition_to(FISH)` [^65^].

The critical simplification is automatic context switching. Young children cannot manage form transitions manually — they forget their current form and become frustrated [^73^]. The state machine handles transitions automatically: step into water and become a fish, approach a narrow gap and shrink, fall into a pit and become a bird. Manual override is available but never required.

State machines are the universal architecture for movement abilities, whether explicit (Shantae's FSM) or implicit (Hollow Knight's dash state flag) [^99^][^107^]. The `TransformationStateMachine` below generalizes this pattern with form-specific profiles, auto-transform rules, and event callbacks that drive visual effects — a particle burst and form-specific animation make every transformation feel magical.

```typescript
/**
 * TransformationStateMachine — FSM for animal form stamps.
 * Each form has unique physics, collision shape, abilities, and auto-triggers.
 */
class TransformationStateMachine {
  private readonly profiles: Map<string, FormProfile>;
  private autoRules: Array<{ condition: ContextCondition; targetForm: string }> = [];
  private currentForm: string; private previousForm: string | null = null;
  private transitionCooldownMs = 0; private readonly COOLDOWN = 300;

  public get physics(): FormProfile { return this.profiles.get(this.currentForm)!; }
  public onTransform: ((from: string, to: string) => void) | null = null;

  constructor(
    profiles: Map<string, FormProfile>, initialForm: string,
    autoRules?: Array<{ condition: ContextCondition; targetForm: string }>
  ) {
    this.profiles = profiles; this.currentForm = initialForm;
    if (autoRules) this.autoRules = autoRules;
  }

  transitionTo(formId: string): boolean {
    if (formId === this.currentForm || this.transitionCooldownMs > 0
        || !this.profiles.has(formId)) return false;
    const from = this.currentForm;
    this.previousForm = from; this.currentForm = formId;
    this.transitionCooldownMs = this.COOLDOWN;
    this.onTransform?.(from, formId);
    return true;
  }

  revert(): boolean { return this.previousForm ? this.transitionTo(this.previousForm) : false; }

  /** Called every frame. Evaluates auto-transform rules. */
  update(context: TransformContext, deltaMs: number): void {
    this.transitionCooldownMs = Math.max(0, this.transitionCooldownMs - deltaMs);
    for (const rule of this.autoRules) {
      if (rule.condition(context) && this.currentForm !== rule.targetForm) {
        this.transitionTo(rule.targetForm); return;
      }
    }
  }

  getActiveAbilities(): string[] {
    const p = this.physics, a = ["move", "jump"];
    if (p.canClimbWalls) a.push("wall_climb");
    if (p.canFly) a.push("fly");
    if (p.canSwim) a.push("swim");
    if (p.specialAbility) a.push(p.specialAbility);
    return a;
  }
  isForm(id: string): boolean { return this.currentForm === id; }
  getCurrentForm(): string { return this.currentForm; }
}

interface FormProfile {
  speed: number; jumpHeight: number; gravityScale: number;
  sizeScale: number; canClimbWalls: boolean; canFly: boolean;
  canSwim: boolean; specialAbility: string | null;
}
interface TransformContext {
  terrain: "ground" | "water" | "air" | "climbable_wall";
  isInPit: boolean; nearNarrowGap: boolean; nearBreakableWall: boolean;
}
type ContextCondition = (ctx: TransformContext) => boolean;

const FORM_PROFILES: Record<string, FormProfile> = {
  human:  { speed: 120, jumpHeight: 350, gravityScale: 1.0,  sizeScale: 1.0, canClimbWalls: false, canFly: false, canSwim: false, specialAbility: null },
  monkey: { speed: 180, jumpHeight: 300, gravityScale: 0.85, sizeScale: 0.6, canClimbWalls: true,  canFly: false, canSwim: false, specialAbility: "wall_jump" },
  bird:   { speed: 100, jumpHeight: 250, gravityScale: 0.35, sizeScale: 0.75, canClimbWalls: false, canFly: true,  canSwim: false, specialAbility: "glide" },
  fish:   { speed: 160, jumpHeight: 80,  gravityScale: 0.1,  sizeScale: 0.85, canClimbWalls: false, canFly: false, canSwim: true,  specialAbility: "underwater_breathing" },
  spider: { speed: 90,  jumpHeight: 250, gravityScale: 0.9,  sizeScale: 0.5, canClimbWalls: true,  canFly: false, canSwim: false, specialAbility: "ceiling_walk" },
};

function createDefaultAutoRules(): Array<{ condition: ContextCondition; targetForm: string }> {
  return [
    { condition: ctx => ctx.terrain === "water", targetForm: "fish" },
    { condition: ctx => ctx.isInPit, targetForm: "bird" },
    { condition: ctx => ctx.nearNarrowGap, targetForm: "spider" },
  ];
}
```

#### 4.3.2 Visual Transformation Animation

When `onTransform` fires, the visual system plays a three-phase animation: a 200ms particle burst obscuring the model swap, a 150ms cross-fade to the new form, and form-specific entry particles — feathers for Bird form, water droplets for Fish form, dust for Elephant form. The particle burst serves a usability purpose beyond aesthetics: it disguises the sprite swap. Young children struggle with abrupt visual changes; a particle cloud provides continuity so the transformation feels like magic rather than a jarring replacement [^73^].

Context-aware form reminders appear for three seconds after auto-transform. A temporary overlay shows the form icon with an animated hint — a monkey icon plus wall-climbing silhouette. These auto-dismiss and never repeat for the same form in the same session, ensuring the child understands why controls changed without patronization [^73^].

#### 4.3.3 Form-Specific Physics Profiles and Navigation Re-analysis

Each form profile encodes a complete alternative physics identity. The Monkey form's `sizeScale: 0.6` enables passage through 1-tile gaps. Its `gravityScale: 0.85` creates floatier jumps synergizing with wall-climbing. The Spider form's `sizeScale: 0.5` makes it the smallest form, and `canClimbWalls: true` with `ceiling_walk` redefines navigable space — walls and ceilings become pathways [^65^].

When a transformation stamp is added, the LLM re-analyzes the level's navigation graph. The reachability checker calls `getActiveAbilities()` and re-computes platform connectivity with the augmented capability set. When a child adds a Spider Stamp, previously irrelevant ceiling surfaces become navigable, and the LLM can suggest placing secrets along those new routes [^72^].

The auto-revert safety mechanism ensures children never get stuck in an unintended form. When the player stands on stable ground for more than 2 seconds, the state machine auto-reverts to human form unless the form is explicitly "pinned." This prevents the common frustration of forgetting which form is active [^73^].

```typescript
/**
 * ContextAwareActionRouter — Single-button action dispatcher.
 * Routes the action button to the correct movement system based on
 * real-time context: ground state, wall proximity, grapple range,
 * current transformation form, and equipped abilities.
 */
class ContextAwareActionRouter {
  constructor(
    private player: Player,
    private movementMgr: MovementAbilityManager,
    private transformSM: TransformationStateMachine,
    private grappleEngine: GrapplePhysicsEngine | null,
  ) {}

  /** Called on action button press. Evaluates contexts in priority order. */
  onActionPressed(ctx: RouterContext): boolean {
    const form = this.transformSM.physics;
    if (form.specialAbility === "wall_jump" && ctx.isTouchingWall)
      return this.handleWallJump(ctx.wallDirection);
    if (form.specialAbility === "glide" && !ctx.isOnGround && ctx.jumpHeld)
      return this.handleGlide();
    if (form.specialAbility === "swim" && ctx.terrain === "water")
      return this.handleSwim();
    if (ctx.nearestGrapplePoint && this.grappleEngine
        && this.distanceTo(ctx.nearestGrapplePoint) < 80)
      return this.handleGrapple(ctx.nearestGrapplePoint);
    if (!ctx.isOnGround && ctx.inputDown)
      return this.movementMgr.handleAction({
        ...ctx, isOnGround: false, isTouchingWall: false, nearGrapplePoint: false
      });
    return this.movementMgr.handleAction({
      isOnGround: ctx.isOnGround, isTouchingWall: ctx.isTouchingWall,
      inputDown: ctx.inputDown, nearGrapplePoint: !!ctx.nearestGrapplePoint,
      grapplePoint: ctx.nearestGrapplePoint, wallDirection: ctx.wallDirection,
    });
  }

  /** Per-frame update — grapple physics and transformation state. */
  update(ctx: RouterContext, deltaMs: number): void {
    this.transformSM.update({
      terrain: ctx.terrain, isInPit: ctx.isInPit,
      nearNarrowGap: ctx.nearNarrowGap, nearBreakableWall: ctx.nearBreakableWall,
    }, deltaMs);

    if (this.grappleEngine?.isSwinging) {
      const pos = this.grappleEngine.update();
      this.player.setPosition(pos.x, pos.y);
      if (this.grappleEngine.shouldAutoRelease()) {
        const v = this.grappleEngine.computeReleaseVelocity();
        this.grappleEngine.detach(); this.player.setVelocity(v.x, v.y);
      }
      if (this.grappleEngine.checkBoundaryViolation(this.player.levelBounds)) {
        this.grappleEngine.detach(); this.player.setVelocity(0, 0);
      }
      if (this.grappleEngine.isStalled()) this.grappleEngine.detach();
    }
  }

  private handleWallJump(dir: number): boolean {
    this.player.setVelocity(dir * -300, -400);
    this.player.playEffect("wall_jump_burst"); return true;
  }
  private handleGlide(): boolean {
    this.player.setGravityScale(0.2); this.player.playAnimation("glide"); return true;
  }
  private handleSwim(): boolean {
    this.player.setGravityScale(0.05); this.player.playAnimation("swim"); return true;
  }
  private handleGrapple(p: Vec2): boolean {
    this.grappleEngine?.attach(); return true;
  }
  private distanceTo(p: Vec2): number {
    const dx = this.player.x - p.x, dy = this.player.y - p.y;
    return Math.sqrt(dx * dx + dy * dy);
  }
}

interface RouterContext {
  isOnGround: boolean; isTouchingWall: boolean; wallDirection: number;
  inputDown: boolean; jumpHeld: boolean;
  terrain: "ground" | "water" | "air" | "climbable_wall";
  isInPit: boolean; nearNarrowGap: boolean; nearBreakableWall: boolean;
  nearestGrapplePoint: Vec2 | null;
}
interface Player {
  x: number; y: number; levelBounds: Rect;
  setPosition(x: number, y: number): void;
  setVelocity(vx: number, vy: number): void;
  setGravityScale(s: number): void;
  playEffect(n: string): void;
  playAnimation(n: string): void;
}
```

The router's priority order encodes design intent: wall-specific abilities take precedence because they require precise positioning. Grapple supersedes ground-pound because grappling is constructive traversal while ground-pound is destructive. Safety checks run every frame during grapple swing — boundary violation, stall detection, and auto-release — ensuring children cannot break the game, only discover new ways to traverse it.
