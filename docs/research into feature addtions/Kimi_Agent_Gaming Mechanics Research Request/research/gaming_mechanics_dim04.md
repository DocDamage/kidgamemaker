## Dimension 04: Traversal & Special Movement

### Executive Summary

Special movement abilities are the backbone of memorable side-scrolling experiences, transforming simple run-and-jump gameplay into expressive, emergent traversal systems. From Bionic Commando's groundbreaking grapple-swing mechanic that replaced jumping entirely [^77^], to Hollow Knight's tightly integrated suite of dashes, wall-jumps, and double-jumps [^165^], these abilities define how players interact with game worlds. This research examines five major studios' innovations in traversal mechanics and derives actionable recommendations for implementing them as "movement stamps" in a zero-code, stamp-based game creation platform for children as young as 5.

The key insight from this research is that **every complex movement ability can be decomposed into a combination of simple, physically intuitive primitives**: a grapple is a rope + swing; a wall-jump is a jump + surface detection + direction reversal; a transformation is a state change with different physics parameters. For a stamp-based platform, each ability should be reduced to a single stamp placement that triggers automatic LLM-generated physics code. The LLM handles all mathematical complexity — pendulum forces, raycast detection, state machines — while the child simply places a "Grapple Hook Stamp" or "Dash Stamp" on their canvas. This approach aligns with progressive disclosure principles [^164^] where abilities unlock gradually, matching children's developing cognitive and motor skills [^73^][^134^].

The research covers five studio innovations in depth, provides production-ready code for each mechanic, designs a complete Movement Stamp taxonomy with unlock progression, analyzes edge cases including soft-lock prevention, and derives 12 specific feature recommendations with priority levels. All recommendations are grounded in evidence from GDC-postmortem-level sources, academic child development research, and real engine implementation code.

---

### Studio Innovations Analysis

#### 1. Capcom (Bionic Commando) — Multi-Angle Physics Grapple Wire

**How It Works Technically:**
Bionic Commando, directed by Tokuro Fujiwara, was revolutionary for entirely removing jumping and replacing it with a mechanical grappling arm [^75^]. The system works through several key technical components:

1. **Multi-angle firing**: The hook fires at 45 degrees by default (for swinging), straight up (for climbing), or straight forward (for grabbing items/enemies) [^77^]
2. **Pendulum physics simulation**: Once attached, the player swings as a pendulum. The cable length determines swing arc — shorter cables = smaller arcs [^77^]
3. **Momentum conservation**: Forward input starts the swing; releasing at the optimal point launches the player
4. **Cable retraction**: A second button press retracts the cable, pulling the player upward [^77^]
5. **Infinite momentum**: Unlike real physics, the swing never loses momentum — the player can swing indefinitely waiting for the right moment [^77^]

The grappling system uses what is essentially a **distance joint with swing arc calculation**: when the hook attaches at point (ax, ay), the player position (px, py) is constrained by `distance = sqrt((px-ax)² + (py-ay)²)`. The swing force combines tangential gravitational force with an arc-boosting force at the bottom of the swing [^68^].

**Stamp-Based Adaptation — "Grapple Hook Stamp":**
- Child places a "Grapple Point Stamp" (anchor points on ceilings/walls)
- Child places a "Grapple Ability Stamp" on their character
- The LLM automatically generates:
  - Pendulum physics with auto-swing (no timing required from child)
  - Auto-release at optimal angle (computer calculates best launch point)
  - Visual "swing zone" indicator showing where the character will go
  - One-button activation: child presses jump near a grapple point

**Simplification for 5-year-olds:** Instead of requiring precise timing, the stamp creates an **automatic swing arc** with a visual trajectory preview. The child sees a dotted line showing where they'll go before pressing the button. The system auto-releases at the optimal angle — no skill required, just decision-making.

---

#### 2. WayForward (Shantae Series) — Real-Time Animal Transformations

**How It Works Technically:**
The Shantae series uses a **state machine-based transformation system** where each animal form is essentially a different player state with unique physics parameters, collision shapes, and abilities [^65^]. Key technical aspects:

1. **State machine architecture**: Each transformation is a distinct state in a finite state machine (FSM) [^99^]. The human form is the default state; transformations swap in different physics behaviors
2. **Collision shape changes**: The Monkey form uses a smaller collision box for fitting through narrow passages [^65^]
3. **Physics parameter swaps**: Each form has unique speed, jump height, and gravity values:
   - Monkey: fast, small, can climb walls and wall-jump [^65^]
   - Elephant: slow, large, can barely jump, but can charge through blocks [^65^]
   - Harpy: can fly by tapping jump repeatedly, but has high horizontal inertia [^65^]
   - Spider: can crawl on background walls and ceilings [^65^]
4. **Mid-air transformation**: Shantae can transform mid-jump, enabling sequence breaking and creative platforming [^71^]
5. **Upgrade layering**: Forms can be upgraded with secondary abilities (e.g., Monkey Bullet for wall-dash) [^72^]

**Stamp-Based Adaptation — "Transformation Stamps":**
- Child places an "Animal Form Stamp" on their character (replaces or augments the base character)
- Each transformation stamp is a **character variant** with pre-configured physics:
  - "Monkey Stamp" → small size, wall-climb, fast movement
  - "Bird Stamp" → gravity reduction, jump-to-fly
  - "Fish Stamp" → water swimming, slow on land
- The LLM generates:
  - State machine with form transitions
  - Collision shape adjustments
  - Physics parameter sets for each form
  - Automatic transformation zones (step into water → auto-transform to fish)

**Simplification for 5-year-olds:** Transformations happen **automatically in context** — step into water and become a fish, approach a narrow gap and become a mouse. No button combinations. The child places the stamp once and the LLM handles all context-aware switching.

---

#### 3. Moon Studios (Ori Series) — "Bash" Mechanic

**How It Works Technically:**
The Bash mechanic is one of the most innovative traversal systems in platforming history [^14^]. Its technical implementation involves:

1. **Proximity detection sphere**: A trigger collider around the player detects bashable objects (enemies, projectiles, lanterns) within a configurable radius [^15^]
2. **Time freeze**: When bash is activated, the game enters a bullet-time state (time scale near 0) [^14^]
3. **Aiming system**: During time freeze, the player can aim in any direction using the movement input [^15^]
4. **Projectile redirection**: The bashable object is launched in the opposite direction of the player with calculated force [^14^]
5. **Mutual force application**: Both player and object receive equal and opposite impulses (Newton's third law in game physics) [^15^]
6. **Timer-based exit**: The time freeze lasts ~2 seconds or until the player releases the bash button [^15^]

**Stamp-Based Adaptation — "Bash Ability Stamp":**
- Child places a "Bash Stamp" on their character
- Child places "Bashable Object Stamps" in the level (lanterns, projectiles, enemies)
- The LLM generates:
  - Proximity detection radius around the player
  - Automatic time freeze when near bashable objects (visual: everything goes blue/white)
  - Auto-aim assist (snaps to useful directions)
  - Visual arrow showing launch trajectory
  - One-button bash activation

**Simplification for 5-year-olds:** The time freeze lasts longer (3-4 seconds) to reduce pressure. Auto-aim snaps to the most useful direction (up for height, toward gaps for crossing). Visual feedback is prominent: a big arrow shows exactly where the character will go. No timing skill required.

---

#### 4. Team Cherry (Hollow Knight) — Movement Upgrade Suite

**How It Works Technically:**
Hollow Knight's movement system is a masterclass in **layered ability progression** where each upgrade compounds with existing abilities [^165^]. The technical implementation:

1. **Mothwing Cloak (Dash)**: A state-based dash using coroutine-driven invincibility frames. The dash sets `gravityScale = 0`, applies horizontal velocity for `dashTime` seconds, then restores gravity [^13^]
2. **Mantis Claw (Wall Jump)**: Wall detection via raycasts on the left/right of the player. When touching a wall and not grounded, the player can press jump to launch away from the wall with combined upward and outward velocity [^67^]
3. **Monarch Wings (Double Jump)**: A simple jump counter system — `airJumpCounter` tracks jumps in air, reset to 0 on ground contact [^13^]
4. **Crystal Heart (Super Dash)**: A charged dash requiring hold-then-release input. Uses a charge timer and extended distance value [^165^]
5. **Ability compounding**: Dash + double-jump covers massive distances; wall-jump + dash creates vertical scaling; pogo (down-slash) + jump provides infinite height against enemies [^165^]

Hollow Knight also uses **coyote time** (brief window to jump after leaving a platform) and **jump input buffering** (registering jump slightly before landing) to make controls feel forgiving [^13^].

**Stamp-Based Adaptation — "Movement Upgrade Stamps":**
- Each upgrade is a separate stamp the child places on their character:
  - "Dash Stamp" → quick horizontal burst
  - "Double Jump Stamp" → extra jump in air
  - "Wall Jump Stamp" → stick to and jump off walls
  - "Super Dash Stamp" → charged long-distance dash
- The LLM generates:
  - Ability combination rules (can you dash after wall-jumping? Yes!)
  - Progressive gating (unlock wall-jump before super dash)
  - Auto-coyote time and jump buffering for forgiving controls
  - Visual trail effects for each ability

**Simplification for 5-year-olds:** Abilities unlock in a fixed sequence (you can't place super dash before regular dash). Each stamp shows a **visual preview** of what it does when placed. The system auto-enables coyote time and input buffering — these invisible helpers make controls forgiving without the child needing to understand them.

---

#### 5. Nintendo (Various Mario Games) — Wall-Slide, Ground-Pound, Spin-Jump

**How It Works Technically:**
Nintendo's movement innovations have become genre standards through decades of refinement [^11^][^12^]:

1. **Ground Pound**: Activated by pressing crouch in mid-air. The character enters a spinning state with increased gravity, then slams downward with high force on impact. Used for breaking blocks, activating switches, and attacking enemies below [^11^]
2. **Wall Slide**: When touching a wall while falling, the character's descent slows to ~30-70% of normal fall speed. This gives time to react and wall-jump [^119^]
3. **Spin Jump**: A rotating jump that can break certain blocks and defeat enemies that normal jumps can't. Often activated by a specific button press (e.g., shaking the controller) [^11^]
4. **Triple Jump**: Three consecutive jumps with increasing height, requiring rhythm and forward momentum [^157^]

Mario's jump physics use a **variable gravity system**: lower gravity during ascent when the button is held, higher gravity during descent ("fall multiplier"), creating the iconic snappy jump feel [^151^].

**Stamp-Based Adaptation — "Character Variant Stamps":**
- Instead of configuring abilities, each Nintendo-style character stamp comes pre-loaded:
  - "Bouncy Character Stamp" → ground pound + high jump
  - "Sticky Character Stamp" → wall slide + wall jump
  - "Spinny Character Stamp" → spin jump + floaty descent
- The LLM generates:
  - Character-specific physics parameters (gravity, speed, jump height)
  - Ability activation rules (ground pound = press down in air)
  - Visual feedback unique to each character (spin animation, impact effects)

**Simplification for 5-year-olds:** Each character stamp is a complete package. A child who wants ground-pounding picks the "Heavy Character Stamp" — no configuration needed. The stamp's icon visually shows what it does (e.g., a character mid-ground-pound).

---

### Key Findings

1. **All complex movement can be decomposed into primitives**: Grapple = rope joint + pendulum force + release timing [^68^]. Wall-jump = raycast detection + normal vector + impulse force [^67^]. Dash = coroutine + gravity override + velocity burst [^13^]. These primitives map perfectly to stamp-based code generation.

2. **State machines are the universal architecture**: Every studio uses state machines to manage movement abilities, whether explicitly (Shantae's transformation FSM [^65^]) or implicitly (Hollow Knight's dash state flag [^13^]). A stamp-based system should generate a movement state machine automatically. [^99^][^107^]

3. **Progressive enabling is essential for children's UX**: Research on progressive disclosure shows that incrementally unlocking capabilities as users gain familiarity prevents overwhelm [^164^]. For 5-year-olds, this means starting with walk + jump only, unlocking one ability at a time. [^164^][^143^]

4. **Coyote time and input buffering are invisible necessities**: These "forgiving" mechanics (brief window to jump after leaving a ledge, registering jump input before landing) are critical for children whose reaction times and motor coordination are still developing. Average reaction time for children is 200-250ms, significantly slower than adults. [^13^][^73^]

5. **Auto-activation trumps manual activation for young children**: Research shows that children under 5 struggle with complex motor coordination and two-handed use [^73^]. Movement abilities should activate automatically in context (auto-wall-jump when touching a wall, auto-grapple when near a grapple point) rather than requiring button combinations.

6. **Visual trajectory previews eliminate guesswork**: Every movement ability should show a visual preview of where the character will go — a dotted arc for jumps, a swing line for grapples, an arrow for dashes. This transforms trial-and-error into informed decision-making.

7. **Ability combinations create emergent gameplay**: The sum of movement abilities is greater than their parts. Dash + double-jump = long horizontal crossing. Wall-jump + dash = vertical scaling. Grapple + ground-pound = swing-attack. The LLM should automatically generate level sections that leverage these combinations. [^165^][^167^]

8. **Single-button control is optimal for 5-year-olds**: Research on single-button game design shows that press, hold, and rhythm are the three core interaction patterns that can be mapped to any action [^136^]. Movement abilities should use a single action button with context-aware behavior: tap = jump, hold = charge/grapple, tap in air = double-jump, tap near wall = wall-jump. [^136^]

9. **Transformation forms change the world perspective**: Shantae's transformations demonstrate that changing the player's capabilities also changes how they see the level — ceilings become floors for the spider, walls become paths for the monkey [^72^]. The LLM should re-analyze level navigation paths when transformation stamps are added.

10. **Soft-lock prevention requires ability-aware pathfinding**: The LLM must verify that every level section is reachable with the currently placed movement stamps. If a child removes a stamp that was required for progression, the LLM should flag it or auto-adjust the level. [^79^]

11. **Bash-like mechanics are too complex for 5-year-olds in pure form**: Ori's Bash requires aiming during time freeze + understanding projectile physics + predicting mutual force vectors. For young children, this must be simplified to: proximity detection + auto-aim + one-button activation. The strategic depth comes from positioning, not execution. [^14^]

12. **Testing before committing reduces frustration**: Children should be able to "try on" a movement stamp in a safe test area before placing it in their level. This prevents the frustration of placing a stamp, building around it, then discovering it doesn't work as expected. [^73^]

---

### Child-Friendly Simplifications

#### Movement Ability → Stamp Mapping

| Complex Mechanic | Studio Source | Child-Friendly Stamp | LLM-Generated Code |
|---|---|---|---|
| Pendulum grapple swing | Bionic Commando [^77^] | "Swing Point Stamp" + "Rope Stamp" | Auto-calculate swing arc, auto-release at optimal angle |
| Animal transformation | Shantae [^65^] | "Animal Character Stamp" | State machine with physics swaps, auto-transform in context |
| Bash (projectile redirect) | Ori [^14^] | "Bounce Pad Stamp" (simplified) | Auto-detect nearby objects, auto-aim, mutual force launch |
| Dash | Hollow Knight [^13^] | "Dash Stamp" | Coroutine-driven burst with trail effect |
| Wall-jump | Hollow Knight [^13^] | "Sticky Feet Stamp" | Auto-wall-slide + auto-jump-away |
| Double-jump | Various [^104^] | "Wings Stamp" | Jump counter with visual effect |
| Ground-pound | Mario [^11^] | "Heavy Character Stamp" | Downward slam with impact effect |
| Spin-jump | Mario [^11^] | "Spinny Character Stamp" | Rotating jump with block-break ability |
| Super-dash | Hollow Knight [^165^] | "Charge Dash Stamp" | Hold-to-charge, release-to-launch |
| Wall-slide | Various [^119^] | "Sticky Feet Stamp" | Slowed descent on wall contact |

#### Control Simplification Principles

For 5-year-olds, all movement abilities should follow these control principles based on child development research [^73^][^136^]:

1. **One-button context-aware actions**: A single "Action Button" that does different things based on context:
   - On ground → Jump
   - In air → Double jump (if wings stamp equipped)
   - Near wall → Wall jump (if sticky feet stamp equipped)
   - Near grapple point → Auto-swing (if rope stamp equipped)
   - Hold → Charge dash (if dash stamp equipped)

2. **Auto-activation over manual activation**: Abilities trigger automatically when contextually appropriate. The child doesn't need to know "press X to wall-jump" — they just move toward a wall and the character sticks and jumps.

3. **Visual trajectory previews**: Before any ability activates, a dotted line shows the path. For a grapple: a dotted arc shows the swing. For a dash: an arrow shows the burst direction. For a double-jump: a smaller arc shows the second jump reach.

4. **Progressive unlocking with mastery gates**: New stamps unlock only after the child demonstrates mastery of existing ones. This follows progressive disclosure principles [^164^] and prevents overwhelm. Example sequence:
   - Level 1: Walk + Jump only
   - Level 2: Unlock Double Jump (uses jump skill)
   - Level 3: Unlock Wall Jump (uses jump + direction skills)
   - Level 4: Unlock Dash (combines with previous abilities)
   - Level 5: Unlock Grapple (requires timing + spatial reasoning)

---

### Recommended Features

#### Priority 1 — Core Movement Stamps (Must-Have)

1. **Jump Stamp** (always available)
   - Variable height based on button hold duration [^151^]
   - Auto-coyote time (50ms window after leaving platform) [^13^]
   - Jump input buffering (registers jump 50ms before landing) [^13^]

2. **Double Jump Stamp** (unlockable)
   - Jump counter system: max 1 air jump [^104^]
   - Visual wing/burst effect on second jump
   - Slightly reduced height on second jump for game feel

3. **Dash Stamp** (unlockable)
   - Horizontal burst with invincibility frames [^13^]
   - Visual trail effect
   - 0.5s cooldown to prevent spam
   - Gravity disabled during dash

4. **Wall Jump Stamp** (unlockable)
   - Auto-wall-slide when touching wall while falling [^119^]
   - Auto-jump away when action button pressed
   - Visual "stick" effect on wall contact

#### Priority 2 — Advanced Movement Stamps (Should-Have)

5. **Grapple Swing Stamp** (unlockable)
   - Auto-detects nearby grapple points
   - Visual swing arc preview
   - Auto-release at optimal angle
   - Pendulum physics with momentum boost at swing bottom [^68^]

6. **Ground Pound Stamp** (unlockable)
   - Activated by pressing down in air [^11^]
   - Spin animation + increased fall speed
   - Impact effect on landing (breaks certain blocks)

7. **Transformation Character Stamps** (unlockable)
   - Pre-built animal forms with unique physics [^65^]
   - Context-aware auto-transformation
   - Visual indicator showing current form

8. **Super Dash Stamp** (unlockable)
   - Hold action button to charge, release to launch [^165^]
   - Longer distance than regular dash
   - Visual charge-up effect

#### Priority 3 — Expert Movement Stamps (Nice-to-Have)

9. **Bash/Bounce Stamp** (unlockable)
   - Simplified Ori-style bash [^14^]
   - Auto-detect nearby projectiles/enemies
   - Auto-aim to most useful direction
   - Time freeze with visual arrow indicator

10. **Glide Stamp** (unlockable)
    - Slowed descent when holding jump button
    - Visual umbrella/cape animation
    - Horizontal drift control

11. **Combo Tutorial System**
    - When multiple stamps are equipped, show short animated tutorials
    - "Try dashing then double-jumping!" with visual demonstration
    - Non-intrusive, dismissible hints

12. **Movement Test Sandbox**
    - Safe area where children can test stamps before placing in level
    - Infinite retries without penalty
    - Visual feedback for what each stamp does

---

### Code Snippets

#### 1. Grapple Physics Simulation (Python/pygame)

```python
import math
import pygame

class GrappleSystem:
    """
    Auto-swinging grapple system designed for stamp-based activation.
    The LLM generates this code when a child places a Grapple Stamp.
    
    Key features:
    - Auto-swing (no timing skill required)
    - Visual trajectory preview
    - Auto-release at optimal angle
    - Pendulum physics with arc force calculation
    """
    
    def __init__(self, player_pos, anchor_pos, rope_length):
        self.player_x, self.player_y = player_pos
        self.anchor_x, self.anchor_y = anchor_pos
        self.rope_length = rope_length
        
        # Calculate initial angle
        dx = self.player_x - self.anchor_x
        dy = self.player_y - self.anchor_y
        self.angle = math.atan2(dy, dx)
        
        # Physics parameters (auto-tuned by LLM based on level design)
        self.gravity = 0.5
        self.angular_velocity = 0.0
        self.swing_force = 0.02
        self.auto_release_angle = math.pi / 3  # 60 degrees optimal
        
    def update(self, delta_time):
        """Update pendulum physics each frame."""
        # Pendulum equation: angular_acceleration = -(g/L) * sin(angle)
        angular_acceleration = -(self.gravity / self.rope_length) * math.sin(self.angle)
        
        # Add swing force near bottom for momentum
        if abs(self.angle) < 0.3:  # Near bottom of swing
            angular_acceleration += self.swing_force * math.copysign(1, self.angular_velocity)
        
        self.angular_velocity += angular_acceleration
        self.angular_velocity *= 0.99  # Slight damping
        self.angle += self.angular_velocity
        
        # Calculate new player position
        self.player_x = self.anchor_x + self.rope_length * math.sin(self.angle)
        self.player_y = self.anchor_y + self.rope_length * math.cos(self.angle)
        
    def should_auto_release(self):
        """
        Determine if the swing has reached the optimal release point.
        This enables auto-swing without requiring child timing skill.
        """
        # Auto-release at peak of forward swing
        velocity_direction = math.copysign(1, self.angular_velocity)
        angle_deg = abs(math.degrees(self.angle))
        
        # Release at ~45-60 degrees in the forward direction
        return (angle_deg > 45 and 
                angle_deg < 75 and 
                velocity_direction > 0)
    
    def get_trajectory_preview(self, num_points=20):
        """
        Generate visual trajectory preview points.
        Shows the child where their character will swing.
        """
        preview_points = []
        sim_angle = self.angle
        sim_velocity = self.angular_velocity
        
        for _ in range(num_points):
            angular_acc = -(self.gravity / self.rope_length) * math.sin(sim_angle)
            sim_velocity += angular_acc
            sim_angle += sim_velocity
            
            px = self.anchor_x + self.rope_length * math.sin(sim_angle)
            py = self.anchor_y + self.rope_length * math.cos(sim_angle)
            preview_points.append((px, py))
            
        return preview_points
    
    def release(self):
        """Calculate launch velocity when releasing from swing."""
        # Tangential velocity at release point
        speed = self.angular_velocity * self.rope_length
        
        # Velocity components (perpendicular to rope)
        vx = speed * math.cos(self.angle)
        vy = -speed * math.sin(self.angle)
        
        return (vx * 1.5, vy * 1.5)  # 1.5x boost for satisfying feel
```

#### 2. Wall-Jump Detection System (JavaScript/Phaser)

```javascript
/**
 * Wall-Jump Detection System for stamp-based platformer.
 * Auto-generated by LLM when "Sticky Feet Stamp" is placed.
 * 
 * Features:
 * - Automatic wall detection via raycasting
 * - Auto-wall-slide (slowed descent)
 * - One-button wall jump away from wall
 * - Coyote time for wall jumps
 */
class WallJumpSystem {
    constructor(player, wallLayer) {
        this.player = player;
        this.wallLayer = wallLayer;
        
        // Detection parameters (auto-tuned by LLM)
        this.wallCheckDistance = 8;  // pixels to check
        this.wallSlideSpeed = 50;    // pixels/sec descent on wall
        this.wallJumpForceX = 300;   // horizontal push off wall
        this.wallJumpForceY = -400;  // upward push
        this.wallCoyoteTime = 100;   // ms after leaving wall
        
        // State
        this.isTouchingWall = false;
        this.wallDirection = 0;      // -1 = left wall, 1 = right wall
        this.wallCoyoteTimer = 0;
        this.isWallSliding = false;
    }
    
    update(deltaTime) {
        this.checkWallContact();
        this.handleWallSlide(deltaTime);
        this.updateCoyoteTime(deltaTime);
    }
    
    checkWallContact() {
        // Raycast left and right of player
        const leftHit = this.raycast(-this.wallCheckDistance);
        const rightHit = this.raycast(this.wallCheckDistance);
        
        this.wasTouchingWall = this.isTouchingWall;
        this.isTouchingWall = leftHit || rightHit;
        this.wallDirection = leftHit ? -1 : (rightHit ? 1 : 0);
        
        // Start coyote timer when leaving wall
        if (this.wasTouchingWall && !this.isTouchingWall) {
            this.wallCoyoteTimer = this.wallCoyoteTime;
        }
    }
    
    raycast(offsetX) {
        // Simple AABB raycast against wall layer
        const checkX = this.player.x + offsetX;
        const checkY = this.player.y;
        return this.wallLayer.hasTileAt(checkX, checkY);
    }
    
    handleWallSlide(deltaTime) {
        // Auto-wall-slide: if touching wall and falling, slow descent
        this.isWallSliding = (
            this.isTouchingWall && 
            !this.player.isOnGround && 
            this.player.velocityY > 0  // Falling
        );
        
        if (this.isWallSliding) {
            // Cap fall speed during wall slide
            this.player.velocityY = Math.min(
                this.player.velocityY, 
                this.wallSlideSpeed
            );
            
            // Visual feedback: show "stick" particles
            this.emitWallStickParticles();
        }
    }
    
    updateCoyoteTime(deltaTime) {
        if (this.wallCoyoteTimer > 0) {
            this.wallCoyoteTimer -= deltaTime;
        }
    }
    
    tryWallJump() {
        /**
         * Attempt wall jump. Called when action button is pressed.
         * Works during wall contact OR during coyote time.
         */
        const canWallJump = this.isTouchingWall || this.wallCoyoteTimer > 0;
        
        if (canWallJump && !this.player.isOnGround) {
            // Launch away from wall
            this.player.velocityX = this.wallJumpForceX * -this.wallDirection;
            this.player.velocityY = this.wallJumpForceY;
            
            // Visual feedback
            this.playWallJumpEffect();
            
            // Reset coyote timer
            this.wallCoyoteTimer = 0;
            
            return true;  // Wall jump successful
        }
        return false;
    }
    
    emitWallStickParticles() {
        // Particle effect at wall contact point
        // Implementation depends on renderer
    }
    
    playWallJumpEffect() {
        // Sound + particle burst at jump point
        // Implementation depends on renderer
    }
}
```

#### 3. Dash Implementation (C#/Unity-style)

```csharp
using System.Collections;
using UnityEngine;

/**
 * Dash ability system for stamp-based platformer.
 * Auto-generated by LLM when "Dash Stamp" is placed on character.
 * 
 * Features:
   - One-button dash with cooldown
   - Invincibility frames during dash
   - Visual trail effect
   - Gravity disabled during dash for consistent arc
 */
public class DashAbility : MonoBehaviour
{
    [Header("Dash Settings")]
    [SerializeField] private float dashSpeed = 20f;
    [SerializeField] private float dashDuration = 0.15f;
    [SerializeField] private float dashCooldown = 0.5f;
    [SerializeField] private float dashTrailSpacing = 0.1f;
    
    // References (auto-wired by LLM)
    private Rigidbody2D rb;
    private Animator animator;
    private SpriteRenderer spriteRenderer;
    
    // State
    private bool canDash = true;
    private bool isDashing = false;
    private float originalGravityScale;
    private Vector2 dashDirection;
    
    // Events for other systems
    public System.Action OnDashStart;
    public System.Action OnDashEnd;
    public bool IsDashing => isDashing;
    
    void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        originalGravityScale = rb.gravityScale;
    }
    
    void Update()
    {
        // Check for dash input (single button, context-aware)
        if (Input.GetButtonDown("Action") && canDash && !isDashing)
        {
            // Determine dash direction from input or facing
            float inputX = Input.GetAxisRaw("Horizontal");
            dashDirection = new Vector2(
                inputX != 0 ? inputX : transform.localScale.x, 
                0
            ).normalized;
            
            StartCoroutine(PerformDash());
        }
    }
    
    IEnumerator PerformDash()
    {
        // Start dash
        canDash = false;
        isDashing = true;
        OnDashStart?.Invoke();
        
        // Disable gravity for consistent horizontal dash
        rb.gravityScale = 0;
        
        // Set velocity
        rb.velocity = dashDirection * dashSpeed;
        
        // Visual effects
        animator.SetTrigger("Dash");
        StartCoroutine(SpawnDashTrail());
        
        // Wait for dash duration
        yield return new WaitForSeconds(dashDuration);
        
        // End dash
        rb.gravityScale = originalGravityScale;
        isDashing = false;
        OnDashEnd?.Invoke();
        
        // Cooldown
        yield return new WaitForSeconds(dashCooldown);
        canDash = true;
    }
    
    IEnumerator SpawnDashTrail()
    {
        // Create afterimage effect during dash
        float elapsed = 0;
        while (isDashing && elapsed < dashDuration)
        {
            CreateAfterimage();
            yield return new WaitForSeconds(dashTrailSpacing);
            elapsed += dashTrailSpacing;
        }
    }
    
    void CreateAfterimage()
    {
        // Spawn semi-transparent copy of sprite at current position
        // These fade out over time
        GameObject afterimage = new GameObject("DashTrail");
        afterimage.transform.position = transform.position;
        
        SpriteRenderer sr = afterimage.AddComponent<SpriteRenderer>();
        sr.sprite = spriteRenderer.sprite;
        sr.flipX = spriteRenderer.flipX;
        sr.color = new Color(1, 1, 1, 0.5f);
        
        // Auto-destroy after fade
        StartCoroutine(FadeAndDestroy(sr, 0.3f));
    }
    
    IEnumerator FadeAndDestroy(SpriteRenderer sr, float duration)
    {
        float elapsed = 0;
        while (elapsed < duration)
        {
            float alpha = Mathf.Lerp(0.5f, 0, elapsed / duration);
            sr.color = new Color(1, 1, 1, alpha);
            elapsed += Time.deltaTime;
            yield return null;
        }
        Destroy(sr.gameObject);
    }
    
    // Public method for other systems to check if dash would succeed
    public bool CanDash()
    {
        return canDash && !isDashing;
    }
}
```

#### 4. Transformation State Machine (Python)

```python
from enum import Enum, auto
from dataclasses import dataclass

class TransformationState(Enum):
    """All possible transformation states."""
    HUMAN = auto()
    MONKEY = auto()
    ELEPHANT = auto()
    BIRD = auto()
    FISH = auto()
    SPIDER = auto()

@dataclass
class PhysicsProfile:
    """Physics parameters for a transformation form."""
    speed: float
    jump_height: float
    gravity_scale: float
    size_scale: float
    can_climb_walls: bool
    can_fly: bool
    can_swim: bool
    special_ability: str

class TransformationStateMachine:
    """
    State machine for character transformations.
    Auto-generated by LLM when a Transformation Stamp is placed.
    
    Each form has unique physics, collision, and abilities.
    Transitions can be manual (button) or automatic (context).
    """
    
    # Physics profiles for each form (auto-configured by LLM)
    PHYSICS_PROFILES = {
        TransformationState.HUMAN: PhysicsProfile(
            speed=100, jump_height=150, gravity_scale=1.0,
            size_scale=1.0, can_climb_walls=False, 
            can_fly=False, can_swim=False,
            special_ability="none"
        ),
        TransformationState.MONKEY: PhysicsProfile(
            speed=150, jump_height=120, gravity_scale=0.8,
            size_scale=0.6, can_climb_walls=True,
            can_fly=False, can_swim=False,
            special_ability="wall_jump"
        ),
        TransformationState.ELEPHANT: PhysicsProfile(
            speed=50, jump_height=50, gravity_scale=1.5,
            size_scale=1.5, can_climb_walls=False,
            can_fly=False, can_swim=False,
            special_ability="ground_pound"
        ),
        TransformationState.BIRD: PhysicsProfile(
            speed=80, jump_height=100, gravity_scale=0.3,
            size_scale=0.7, can_climb_walls=False,
            can_fly=True, can_swim=False,
            special_ability="glide"
        ),
        TransformationState.FISH: PhysicsProfile(
            speed=120, jump_height=30, gravity_scale=0.1,
            size_scale=0.8, can_climb_walls=False,
            can_fly=False, can_swim=True,
            special_ability="underwater_breathing"
        ),
        TransformationState.SPIDER: PhysicsProfile(
            speed=90, jump_height=100, gravity_scale=0.9,
            size_scale=0.5, can_climb_walls=True,
            can_fly=False, can_swim=False,
            special_ability="ceiling_walk"
        ),
    }
    
    def __init__(self, initial_state=TransformationState.HUMAN):
        self.current_state = initial_state
        self.previous_state = None
        self.physics = self.PHYSICS_PROFILES[initial_state]
        
        # Auto-transform triggers (context-aware)
        self.auto_transform_rules = []
        
        # Event callbacks
        self.on_transform = None
    
    def transition_to(self, new_state):
        """Manual transition to a new form."""
        if new_state == self.current_state:
            return
            
        self.previous_state = self.current_state
        self.current_state = new_state
        self.physics = self.PHYSICS_PROFILES[new_state]
        
        # Notify listeners (for visual effects, sound, etc.)
        if self.on_transform:
            self.on_transform(self.previous_state, new_state)
    
    def add_auto_transform_rule(self, context_condition, target_state):
        """
        Add a rule for automatic context-aware transformation.
        Example: (is_in_water, FISH) → auto-become fish in water
        """
        self.auto_transform_rules.append((context_condition, target_state))
    
    def check_auto_transform(self, context):
        """
        Check all auto-transform rules against current context.
        Called every frame by the game loop.
        """
        for condition, target_state in self.auto_transform_rules:
            if condition(context) and self.current_state != target_state:
                self.transition_to(target_state)
                return True
        return False
    
    def revert_to_previous(self):
        """Revert to the previous transformation."""
        if self.previous_state:
            self.transition_to(self.previous_state)
    
    def get_current_abilities(self):
        """Get list of currently available abilities."""
        abilities = ["jump", "move"]
        
        if self.physics.can_climb_walls:
            abilities.append("wall_climb")
        if self.physics.can_fly:
            abilities.append("fly")
        if self.physics.can_swim:
            abilities.append("swim")
        if self.physics.special_ability != "none":
            abilities.append(self.physics.special_ability)
            
        return abilities


# Example auto-transform rules for a child's level
# (These would be auto-generated by the LLM based on stamp placement)
def create_default_auto_rules(sm):
    """Create standard auto-transform rules for young children."""
    
    # Rule: Become fish when entering water
    sm.add_auto_transform_rule(
        context_condition=lambda ctx: ctx.get('terrain') == 'water',
        target_state=TransformationState.FISH
    )
    
    # Rule: Become bird when falling into a pit (save from death)
    sm.add_auto_transform_rule(
        context_condition=lambda ctx: ctx.get('falling_into_pit', False),
        target_state=TransformationState.BIRD
    )
    
    # Rule: Become monkey when near climbable walls
    sm.add_auto_transform_rule(
        context_condition=lambda ctx: (
            ctx.get('near_wall') and 
            ctx.get('wall_type') == 'climbable'
        ),
        target_state=TransformationState.MONKEY
    )
```

#### 5. Movement Ability Manager (JavaScript — Main Integration)

```javascript
/**
 * MovementAbilityManager — Central system that coordinates all movement stamps.
 * The LLM generates an instance of this when any movement stamp is placed.
 * Handles ability combinations, priority, and state transitions.
 */
class MovementAbilityManager {
    constructor(player) {
        this.player = player;
        this.abilities = new Map();     // stamp_id → ability_instance
        this.isActive = false;
        
        // Combination rules (auto-generated by LLM)
        this.combinationRules = [
            {
                name: "dash_jump",
                requires: ["dash", "double_jump"],
                result: "Extended aerial dash",
                execute: () => this.performDashJump()
            },
            {
                name: "wall_dash",
                requires: ["wall_jump", "dash"],
                result: "Wall-dash upward",
                execute: () => this.performWallDash()
            },
            {
                name: "grapple_dash",
                requires: ["grapple", "dash"],
                result: "Mid-swing dash boost",
                execute: () => this.performGrappleDash()
            }
        ];
    }
    
    addAbility(stampId, abilityInstance) {
        /**
         * Register a new movement ability from a placed stamp.
         * Auto-validates compatibility with existing abilities.
         */
        this.abilities.set(stampId, abilityInstance);
        
        // Check for new valid combinations
        this.validateCombinations();
        
        // Notify level system to re-check path reachability
        this.notifyLevelSystem();
    }
    
    removeAbility(stampId) {
        /**
         * Remove an ability (when stamp is deleted).
         * Critical: Check if this would create a soft-lock!
         */
        const ability = this.abilities.get(stampId);
        if (!ability) return;
        
        // Check for soft-lock risk
        if (this.wouldCauseSoftLock(stampId)) {
            this.showSoftLockWarning(stampId);
            return false;  // Prevent removal
        }
        
        this.abilities.delete(stampId);
        this.validateCombinations();
        return true;
    }
    
    handleActionButton(context) {
        /**
         * Central handler for the single action button.
         * Context-aware routing to the appropriate ability.
         */
        
        // Priority 1: Ground pound (if in air + pressing down)
        if (!context.isOnGround && context.inputDown && 
            this.abilities.has('ground_pound')) {
            return this.abilities.get('ground_pound').activate();
        }
        
        // Priority 2: Wall jump (if touching wall)
        if (context.isTouchingWall && this.abilities.has('wall_jump')) {
            return this.abilities.get('wall_jump').tryWallJump();
        }
        
        // Priority 3: Grapple (if near grapple point)
        if (context.nearGrapplePoint && this.abilities.has('grapple')) {
            return this.abilities.get('grapple').startSwing();
        }
        
        // Priority 4: Dash (if on ground or in air)
        if (this.abilities.has('dash') && 
            this.abilities.get('dash').canDash()) {
            return this.abilities.get('dash').activate();
        }
        
        // Priority 5: Double jump (if in air)
        if (!context.isOnGround && 
            this.abilities.has('double_jump') &&
            this.abilities.get('double_jump').canUse()) {
            return this.abilities.get('double_jump').activate();
        }
        
        // Default: Regular jump
        if (context.isOnGround) {
            return this.player.jump();
        }
        
        return false;
    }
    
    wouldCauseSoftLock(removedStampId) {
        /**
         * Check if removing an ability would make any level section unreachable.
         * This is the critical safety check for stamp-based systems.
         */
        const remainingAbilities = Array.from(this.abilities.keys())
            .filter(id => id !== removedStampId);
        
        // Ask level pathfinder if all sections are still reachable
        return !this.player.level.isFullyReachable(remainingAbilities);
    }
    
    showSoftLockWarning(stampId) {
        // Show friendly warning: "You need this ability to reach some areas!"
        // Visual: highlight areas that would become unreachable
        const unreachableAreas = this.player.level.getUnreachableAreas();
        this.player.level.highlightAreas(unreachableAreas, 'warning');
    }
    
    validateCombinations() {
        // Check which ability combinations are currently possible
        const currentAbilities = Array.from(this.abilities.keys());
        
        for (const rule of this.combinationRules) {
            const hasAll = rule.requires.every(req => currentAbilities.includes(req));
            if (hasAll) {
                this.player.unlockComboHint(rule.name);
            }
        }
    }
    
    notifyLevelSystem() {
        // Tell the level generator to re-analyze paths
        // This may trigger auto-adjustment of level geometry
        this.player.level.onAbilitiesChanged(this.getActiveAbilities());
    }
    
    getActiveAbilities() {
        return Array.from(this.abilities.keys());
    }
}
```

---

### Edge Cases & Mitigations

#### 1. Soft-Locks from Missing Movement Stamps

**Risk:** Child removes a movement stamp (e.g., wall-jump) that is required to complete their level.

**Mitigation:**
- **Pre-removal validation**: Before allowing stamp removal, the system runs a pathfinding check from spawn to exit using only remaining abilities. If any path becomes impossible, show a warning and prevent removal [^79^].
- **Auto-adjustment option**: Offer to automatically adjust the level geometry to make it completable without the removed ability (e.g., add platforms where wall-jumps were needed).
- **Emergency abilities**: Always grant a "fallback" movement option (like a basic jump) so no level is ever truly impossible.
- **Visual unreachable highlighting**: When a stamp is removed, highlight in red any areas that become unreachable, so the child understands the consequence.

#### 2. Physics Glitching from Ability Combinations

**Risk:** Combining abilities (e.g., dash + grapple) creates physics exploits — infinite velocity, phasing through walls, or flying off-screen.

**Mitigation:**
- **Velocity caps**: Enforce maximum velocity magnitude regardless of ability combinations.
- **State exclusivity**: Certain abilities cannot overlap — cannot dash while grappling, cannot wall-jump while ground-pounding. The state machine enforces mutual exclusion.
- **Collision validation**: After any ability-driven movement, verify the player is in a valid position (not inside walls, not off-screen). If invalid, snap to nearest valid position.
- **Boundary enforcement**: The level has invisible boundary walls that no ability can bypass.

#### 3. Children Accidentally Activating Abilities

**Risk:** A 5-year-old accidentally triggers a ground-pound when they meant to jump, or wall-jumps when they didn't want to.

**Mitigation:**
- **Input buffering with cancel window**: Brief window (100ms) where the child can release the button to cancel an ability before it fully activates.
- **Context sensitivity tuning**: Abilities require stronger contextual confirmation. E.g., ground-pound requires pressing down for 200ms, not just a tap.
- **Undo system**: Allow "rewind" — press a dedicated undo button to rewind the last 3 seconds of gameplay, placing the character back before the mistake.
- **Gentle tutorials**: Each new stamp includes a mini-tutorial showing exactly when and how it activates.

#### 4. Ability Stacking Breaking Level Balance

**Risk:** Child equips too many movement stamps, making their level trivially easy or impossibly chaotic.

**Mitigation:**
- **Stamp slot limits**: Characters have a limited number of "ability slots" (e.g., 3 slots). This forces meaningful choices about which abilities to bring.
- **Auto-difficulty scaling**: The LLM adjusts enemy placement and obstacle density based on equipped abilities. More abilities = more challenging level auto-generation.
- **Ability synergy detection**: The LLM identifies powerful combinations and generates content that requires their skillful use rather than making content trivial.

#### 5. Grapple Physics Going Wrong

**Risk:** Pendulum physics can create infinite swing loops, rope stretching, or launching the player off-screen.

**Mitigation:**
- **Rope length limits**: Maximum rope length prevents extreme swings.
- **Swing decay**: Slight damping (0.5% per frame) naturally reduces swing amplitude over time.
- **Auto-detach at boundaries**: If the swing arc would take the player off-screen, auto-detach at the last safe point.
- **Minimum swing threshold**: If swing velocity drops below a threshold, auto-release to prevent getting stuck.

#### 6. Transformation Confusion

**Risk:** Child transforms into a form and doesn't understand why their controls changed or how to change back.

**Mitigation:**
- **Always-visible form indicator**: A prominent icon in the corner shows current form with a "tap to change back" hint.
- **Auto-revert on safe ground**: Transformations auto-revert to human form when standing on stable ground, unless the child explicitly pins the form.
- **Visual control reminder**: When transformed, temporary on-screen prompts show what the current form can do ("You can climb walls now!").
- **One-tap revert**: Dedicated "change back" button that is always visible during transformations.

#### 7. Movement Ability Testing Before Commitment

**Risk:** Child places a stamp, builds a level around it, then discovers the ability doesn't work as they expected.

**Mitigation:**
- **Sandbox test zone**: Every new stamp unlocks access to a "test playground" — a safe area with the new ability pre-equipped, where the child can experiment without consequences.
- **Stamp preview animation**: When hovering over a stamp in the palette, a short looping animation shows exactly what the ability does.
- **Place-and-try workflow**: Stamps can be placed in "trial mode" (ghosted appearance) — the child can test them immediately and confirm or remove without penalty.

---

### Movement Stamp Taxonomy & Unlock Progression

```
MOVEMENT STAMP HIERARCHY
========================

Level 1: FOUNDATION (Available from start)
├── Walk Stamp [always equipped]
│   └── Left/right movement
├── Jump Stamp [always equipped]
│   └── Variable height (hold for higher)
└── Basic Character Stamp
    └── Default physics: medium speed, medium jump

Level 2: VERTICALITY (Unlock after completing 1 level)
├── Double Jump Stamp ["Wings"]
│   └── One extra jump in mid-air
│   └── Visual: small wing flap effect
├── Wall Jump Stamp ["Sticky Feet"]
│   └── Auto-wall-slide + jump away from walls
│   └── Visual: character sticks to wall briefly
└── High Jumper Character Stamp
    └── Increased jump height, lower speed

Level 3: MOBILITY (Unlock after mastering Level 2 stamps)
├── Dash Stamp ["Lightning"]
│   └── Quick horizontal burst
│   └── Visual: speed lines/trail effect
├── Glide Stamp ["Parachute"]
│   └── Slowed descent when holding jump
│   └── Visual: umbrella/cape opens
└── Ground Pound Stamp ["Anvil"]
    └── Downward slam from mid-air
    └── Visual: spin then slam with impact ring

Level 4: TRAVERSAL (Unlock after mastering Level 3 stamps)
├── Grapple Swing Stamp ["Rope"]
│   └── Auto-swing from anchor points
│   └── Visual: rope line + arc preview
├── Super Dash Stamp ["Rocket"]
│   └── Hold to charge, release for long burst
│   └── Visual: charge-up particles
└── Swim/Fish Form Stamp
    └── Free movement in water areas
    └── Auto-transform on water entry

Level 5: MASTERY (Unlock after completing 10+ levels)
├── Bash Stamp ["Bounce"]
│   └── Launch off enemies/projectiles
│   └── Visual: time freeze + arrow indicator
├── Spider Form Stamp
│   └── Walk on walls and ceilings
│   └── Visual: spider form + web lines
├── Flight Form Stamp ["Bird"]
│   └── Full flight with stamina limit
│   └── Visual: bird transformation
└── Combo Tutorials
    └── "Try Dash + Double Jump!"
    └── Animated demonstrations of synergies
```

**Progression Philosophy:** Based on progressive disclosure research [^164^] and child cognitive development stages [^134^], the unlocking follows these principles:

1. **Start concrete, become abstract**: Level 1-2 abilities map directly to real-world actions (jumping, climbing). Level 4-5 abilities require more abstract thinking (grapple physics, bash redirection).

2. **One new concept at a time**: Each unlock tier introduces exactly one new mechanical concept. Verticality → Mobility → Traversal → Mastery.

3. **Mastery gating, not time gating**: Stamps unlock when the child demonstrates competence (completes levels, collects tokens), not after a timer. This respects individual learning pace.

4. **Visible but locked**: Future stamps are visible in the palette but grayed out with a "Complete 2 more levels to unlock!" message. This creates anticipation and clear goals.

---

### Sources

1. [^11^] Mario Wiki — Ground Pound: https://www.mariowiki.com/Ground_Pound (Accessed 2025)
2. [^12^] Mario Fandom — Ground Pound: https://mario.fandom.com/wiki/Ground_Pound (Accessed 2025)
3. [^13^] Terresquall Blog — Creating a Metroidvania like Hollow Knight Part 2: https://blog.terresquall.com/2023/05/creating-a-metroidvania-like-hollow-knight-part-2/ (2024)
4. [^14^] Ori and the Blind Forest Wiki — Bash: https://oriandtheblindforest.fandom.com/wiki/Bash_(Blind_Forest) (Accessed 2025)
5. [^15^] Renan.Games — 3D Bash in Unreal Engine: https://renan.games/2019/08/30/3d-bash/ (2019)
6. [^65^] Shantae Wiki — Forms: https://shantae.fandom.com/wiki/Forms (2026)
7. [^67^] Medium — Wall Jumping in Unity by Sean Duggan: https://medium.com/@sean.duggan/wall-jumping-in-unity-d51d967ed103 (2024)
8. [^68^] Opsive Forum — Grapple Hook Pendulum Physics: http://www.opsive.com/forum/index.php?threads/grapple-hook.7822/ (2022)
9. [^70^] GameDev StackExchange — Grapple Hook Implementation: https://gamedev.stackexchange.com/questions/205214/how-to-implement-grapple-hook-and-swing (2023)
10. [^71^] Reddit — Shantae Transformation Oddity: https://www.reddit.com/r/Shantae/comments/1hkx1bg/just_something_odd_i_found_out/ (2025)
11. [^72^] 8-Bit Horse — Shantae Half-Genie Hero Review: http://8bithorse.blogspot.com/2017/01/shantae-half-genie-hero.html (2019)
12. [^73^] Nielsen Norman Group — Design for Kids Based on Physical Development: https://www.nngroup.com/articles/children-ux-physical-development/ (2018)
13. [^75^] YouTube — Bionic Commando Capcom's Grappling Hook Classic: https://www.youtube.com/watch?v=8WIa0IdSLqg (2026)
14. [^76^] Dagon Dogs — Bionic Commando Review: https://dagondogs.com/2016/09/28/bionic-commando-rearmed-quick-dirty-review (2019)
15. [^77^] Waltorious Writes About Games — Console History Bionic Commando: https://waltoriouswritesaboutgames.com/2025/08/29/history-lessons-bionic-commando/ (2025)
16. [^79^] GameDesignSkills — Platformer Game Design: https://gamedesignskills.com/game-design/platformer/ (2025)
17. [^99^] GDQuest — Finite State Machine in Godot 4: https://gdquest.com/tutorial/godot/design-patterns/finite-state-machine/ (2025)
18. [^100^] Vibelf — Double Jump Mechanics in Scratch: https://www.vibelf.com/questions/double-jump-mechanics/ (2024)
19. [^104^] StackOverflow — Double Jump Implementation: https://stackoverflow.com/questions/20705928/how-can-i-double-jump-in-my-platform-game-code (2013)
20. [^107^] ShaggyDev — State Machine Design Pattern Introduction: https://shaggydev.com/2021/11/01/state-machines-intro/ (2021)
21. [^108^] Refactoring.Guru — State Pattern: https://refactoring.guru/design-patterns/state (2025)
22. [^119^] Godot Forum — Wall Slide and Wall Jump: https://forum.godotengine.org/t/wall-slide-and-wall-jump-mechanic/57434 (2024)
23. [^134^] Education Hub — Games for Building Executive Function in 3-5 Year Olds: https://theeducationhub.org.nz/games-and-activities-for-building-executive-function-in-3-5-year-olds/ (2025)
24. [^136^] Davide Aversa — Game Design Essentials Single Button Controls: https://www.davideaversa.it/blog/game-design-essentials-single-button-controls/ (2016)
25. [^143^] University XP — What Are Progression Systems in Games: https://www.universityxp.com/blog/2024/1/16/what-are-progression-systems-in-games (2024)
26. [^148^] GameMaker Forum — Grappling Hook Implementation: https://forum.gamemaker.io/index.php?threads/how-would-you-make-a-grappling-hook-mechanic-work.119275/ (2025)
27. [^150^] Kodeco — 2D Grappling Hook Game in Unity: https://www.kodeco.com/348-make-a-2d-grappling-hook-game-in-unity-part-1 (2017)
28. [^151^] Godot Forum — Mario-like Jumps: https://forum.godotengine.org/t/2d-platformer-how-to-control-jump-height-mario-like-jumps/28736 (2018)
29. [^157^] Error454 — Platformer Physics 101: https://error454.com/2013/10/23/platformer-physics-101-and-the-3-fundamental-equations-of-platformers/ (2013)
30. [^158^] GitHub — Godot Grappling Hook System: https://github.com/mujtaba-io/godot-grappling-hook (2023)
31. [^160^] Beamdog Forums — Scratch Programming for Children: https://forums.beamdog.com/discussion/88906/how-children-can-use-scratch-programming-to-create-games (2024)
32. [^162^] Kids Can Code — Godot 4 Platform Character: https://kidscancode.org/godot_recipes/4.x/2d/platform_character/index.html (Accessed 2025)
33. [^164^] UXPin — Progressive Disclosure in UX: https://www.uxpin.com/studio/blog/what-is-progressive-disclosure/ (2026)
34. [^165^] User Experience Points — The Movement of Hollow Knight: https://blog.rwittmann.com/2022/09/08/the-movement-of-hollow-knight/ (2022)
35. [^167^] DiVA Portal — Emergent Gameplay and Affordance of Features: https://www.diva-portal.org/smash/get/diva2:1783245/FULLTEXT01.pdf (Thesis)
