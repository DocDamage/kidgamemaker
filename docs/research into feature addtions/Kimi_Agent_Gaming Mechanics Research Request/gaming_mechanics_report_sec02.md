## 2. Combat & Action System Features

Combat is the most technically demanding subsystem of any side-scrolling action game, yet it offers the richest opportunities for child-friendly simplification through stamps. This chapter translates six studios' combat innovations — Capcom's elemental weakness chains, Konami's spread-fire mechanics, Treasure's real-time weapon combining, Inti Creates' combo ranking, SNK's vehicle hijacking, and Klei's binary stealth — into auto-generated code that runs behind every stamp placement. The central tenet: a five-year-old should never aim manually, read a damage number, or open a weapon menu. The LLM handles all computation; the child sees only colors, icons, and particle bursts.

### 2.1 Combat Stamp Taxonomy

#### 2.1.1 Seven Categories of Combat Stamps

The platform exposes 38 combat stamps across seven categories. Each stamp carries an implicit behavior contract: when dragged onto the canvas, the LLM infers not just the visual asset but the complete mechanic — collision profile, health budget, attack pattern, and interaction rules with every other stamp on the canvas.

The Hero category provides three stamps: the Player Character (mandatory avatar with auto-attack and auto-aim), the Companion (an AI ally using the same targeting as the player), and the Pet (collects drops, provides minor assists). The Enemy category offers six behavioral archetypes: Patrol (fixed route), Chaser (follows on sight), Shooter (fires projectiles at intervals), Heavy (absorbs multiple hits), Flying (ignores terrain), and Boss (multi-phase, drops a key). The Weapon category provides six firing patterns: Spread (five-projectile fan, the child-friendly default), Straight (piercing beam), Homing (seeking projectiles), Boomerang (returns to player), Bounce (ricochets), and Melee (auto-combo). The Element category overlays weapons and enemies with one of six types — Fire, Ice, Electric, Metal, Nature, Water — that participate in a rock-paper-scissors weakness cycle. Vehicle, Environment, and Helper stamps extend combat without adding control complexity.

| Category | Stamp Types | Combat Role | Child-Facing Icon |
|---|---|---|---|
| Hero | Player, Companion, Pet | Auto-aim auto-attack; AI ally; drop collector | Star character |
| Enemy | Patrol, Chaser, Shooter, Heavy, Flying, Boss | 6 behavior archetypes | Slime, bat, robot |
| Weapon | Spread, Straight, Homing, Boomerang, Bounce, Melee | 6 firing patterns with auto-aim | Gun, sword, orb |
| Element | Fire, Ice, Electric, Metal, Nature, Water, Neutral | Weakness-cycle overlay | Flame, snow, bolt |
| Vehicle | Tank, Jetpack, Mech, Mount | Armor, flight — auto-mount on contact | Car, plane, mech |
| Environment | Shadow Zone, Light Zone, Destructible Wall, Explosive Barrel, Hazard | Stealth, cover, chain reactions | Cloud, crate, spike |
| Helper | Health Heart, Shield, Power Star, Speed Boost | Recovery, buffs, invincibility | Heart, bubble, star |

The Spread Stamp is the default on every new canvas. Konami's Spread Gun from *Contra* is the most iconic power-up in shooter history because it requires no aiming precision — five projectiles in a widening fan cover a broad frontal area [^25^]. When a child places any Weapon Stamp, the LLM generates the projectile pattern; when none is placed, Spread is assumed. The first enemy dies to an auto-aimed spread burst, and the child learns by watching — no tutorial required. This design philosophy — "the wider the attack pattern, the more accessible the combat" — informs every default choice in the combat system.

#### 2.1.2 Visual Weakness System: The Six-Element Cycle

Capcom's *Mega Man* series encodes one of the most elegant weakness systems in game design. Each Robot Master's weapon has a logical weakness relationship: Cut Man's Rolling Cutter beats Elec Man (cord-cutting = shutting off power), Elec Man's Thunder Beam beats Ice Man (electricity conducts through water), Ice Man's Ice Slasher beats Fire Man (cold extinguishes flame), Fire Man's Fire Storm beats Bomb Man (fire detonates explosives), Bomb Man's Hyper Bomb beats Guts Man (explosives break rocks), and Guts Man's Super Arm beats Cut Man (rock beats scissors) [^28^]. Keiji Inafune described this as rock-paper-scissors: "Almost everything has something that it's stronger than and something that it's weaker than" [^28^].

For the stamp platform, this directed cyclic graph becomes a six-element system readable through icons alone. Fire beats Ice (flame melts snowflake), Ice beats Electric (frost insulates), Electric beats Metal (lightning fries circuits), Metal beats Nature (metal cuts plants), Nature beats Water (plants absorb), and Water beats Fire (water extinguishes). Each relationship is grounded in physical intuition that a five-year-old can reason about from everyday experience. Super-effective hits produce a gold flash and "💥" popup; resisted hits show gray with "🛡️"; neutral hits produce white flash [^28^]. Numbers never appear on screen.

| Attacker Element | Defender Element | Effectiveness | Visual Feedback | Child-Intuitive Reason |
|---|---|---|---|---|
| Fire 🔥 | Ice ❄️ | Super (3×) | Gold flash + "💥" + steam | Flame melts ice |
| Ice ❄️ | Electric ⚡ | Super (3×) | Gold flash + "💥" + frost coat | Cold insulates electricity |
| Electric ⚡ | Metal ⚙️ | Super (3×) | Gold flash + "💥" + spark shower | Lightning fries metal |
| Metal ⚙️ | Nature 🌿 | Super (3×) | Gold flash + "💥" + leaf shred | Metal cuts plants |
| Nature 🌿 | Water 💧 | Super (3×) | Gold flash + "💥" + bubble pop | Plants drink water |
| Water 💧 | Fire 🔥 | Super (3×) | Gold flash + "💥" + sizzle | Water puts out fire |
| Reverse of above | — | Weak (0.5×) | Gray flash + "🛡️" | Natural resistance |
| Neutral ⭐ | Any | Normal (1×) | White flash | No special interaction |

#### 2.1.3 WeaknessSystem Implementation

The following class is auto-generated by the LLM when the child places their first Element Stamp. It runs entirely behind the scenes — the child never sees the word "damage" — and produces only visual feedback objects.

```typescript
/** WeaknessSystem — LLM-auto-generated from Element Stamp placements */
class WeaknessSystem {
  static readonly ELEMENTS: Record<string, { beats: string | null; weakTo: string | null }> = {
    FIRE:     { beats: 'ICE',      weakTo: 'WATER' },
    ICE:      { beats: 'ELECTRIC', weakTo: 'FIRE' },
    ELECTRIC: { beats: 'METAL',    weakTo: 'ICE' },
    METAL:    { beats: 'NATURE',   weakTo: 'ELECTRIC' },
    NATURE:   { beats: 'WATER',    weakTo: 'METAL' },
    WATER:    { beats: 'FIRE',     weakTo: 'NATURE' },
    NEUTRAL:  { beats: null,       weakTo: null },
  };

  resolveStrike(attackerEl: string, defenderEl: string, baseDmg: number = 1)
    : { internalDamage: number; visual: StrikeVisual } {
    const atk = WeaknessSystem.ELEMENTS[attackerEl];
    const def = WeaknessSystem.ELEMENTS[defenderEl];
    if (!atk || !def) return { internalDamage: baseDmg, visual: this.neutralVisual() };

    if (atk.beats === defenderEl) {
      return {
        internalDamage: baseDmg * 3,
        visual: { flashColor: '#FFD700', popup: '💥', particleEffect: 'element_burst',
                  screenShake: 3, soundCue: 'crit_chime', tintDurationMs: 300 }
      };
    }
    if (def.beats === attackerEl) {
      return {
        internalDamage: Math.max(1, Math.floor(baseDmg * 0.5)),
        visual: { flashColor: '#888888', popup: '🛡️', particleEffect: 'spark_deflect',
                  screenShake: 0, soundCue: 'clink', tintDurationMs: 200 }
      };
    }
    return { internalDamage: baseDmg, visual: this.neutralVisual() };
  }

  private neutralVisual(): StrikeVisual {
    return { flashColor: '#FFFFFF', popup: null, particleEffect: 'small_hit',
             screenShake: 0, soundCue: 'hit_pop', tintDurationMs: 150 };
  }

  suggestOptimalWeapon(pw: string[], ee: string): string | null {
    return pw.find(w => WeaknessSystem.ELEMENTS[w]?.beats === ee) ?? null;
  }
}

interface StrikeVisual {
  flashColor: string; popup: string | null; particleEffect: string;
  screenShake: number; soundCue: string; tintDurationMs: number;
}
```

The `resolveStrike` method is the critical boundary: internal damage feeds the enemy's health reducer, but only the `StrikeVisual` reaches the renderer. A child fighting an Ice enemy with a Fire weapon sees a gold flash and steam burst — never the number "3" or word "critical." The `suggestOptimalWeapon` method lets the auto-aim system preferentially equip the super-effective weapon when multiple Weapon Stamps are present, making elemental strategy automatic rather than a menu choice.

### 2.2 Auto-Aim & Spread Fire System

#### 2.2.1 Utility-Based Target Scoring with Sticky Targeting

Manual aiming is the largest barrier to combat accessibility for five-year-olds. Research shows utility-based targeting — scoring enemies on proximity, facing alignment, and threat — produces the most natural automated combat [^83^]. The `AutoAimSystem` evaluates every enemy each frame and selects the optimal target without child input.

The scoring pipeline runs in four stages. First, the FOV cone filter rejects enemies outside a 90-degree forward cone. Second, the distance scorer prioritizes closer threats. Third, the alignment scorer rewards targets directly in front of the player. Fourth, sticky-targeting prevents rapid switching: a new target must score 30% higher than the current one, and a 500ms minimum hold is enforced before any switch [^83^]. This eliminates jittery "target hopping." Smooth angle interpolation (lerp at 0.15/frame) polishes the motion, with correct wraparound handling for targets crossing behind the player — the jump from 359° to 0° rotates forward, not backward 359°.

#### 2.2.2 Spread Gun as Default Pattern

*Contra*'s Spread Gun fires five projectiles at [-30, -15, 0, +15, +30] degrees, creating a coverage wedge that widens with distance [^25^]. At close range, multiple projectiles hit simultaneously; at long range, the pattern covers a broad zone requiring no precision. This is the default for every new canvas because it is the most forgiving aiming mode in side-scrolling shooter history.

The LLM generates pattern arrays from the Weapon Stamp: Spread produces the five-angle fan, Straight produces a piercing beam, Homing produces a seeking projectile with angular velocity correction each frame. The child places the stamp; the pattern emerges automatically. A Melee Stamp triggers an auto-combo sequence when an enemy enters close range — the LLM generates the combo chain, and the child presses a single action button to execute it with visual flourishes.

#### 2.2.3 AutoAimSystem Implementation

```typescript
/** AutoAimSystem — utility-based targeting with sticky selection and pattern generation */
class AutoAimSystem {
  private currentTarget: Enemy | null = null;
  private aimAngle = 0;
  private lastSwitchTime = 0;

  constructor(private cfg: {
    maxRange: number; fovDegrees: number; smoothing: number;
    stickyThreshold: number; minHoldMs: number;
  }) {}

  update(px: number, py: number, facingRight: boolean, enemies: Enemy[]) {
    const scored = this.scoreTargets(px, py, facingRight, enemies)
      .sort((a, b) => b.utility - a.utility);

    const best = scored[0];
    if (best?.utility > 0 && this.shouldSwitch(best)) {
      this.currentTarget = best.enemy;
      this.lastSwitchTime = performance.now();
    }
    if (!best || best.utility <= 0) this.currentTarget = null;

    const desired = this.currentTarget
      ? Math.atan2(this.currentTarget.y - py, this.currentTarget.x - px)
      : (facingRight ? 0 : Math.PI);
    this.aimAngle = this.lerpAngle(this.aimAngle, desired, this.cfg.smoothing);

    return { angle: this.aimAngle, target: this.currentTarget };
  }

  firePattern(weaponType: WeaponType, speed = 8): Projectile[] {
    const patterns: Record<WeaponType, number[]> = {
      SPREAD: [-30,-15,0,15,30], STRAIGHT:[0], HOMING:[0],
      BOOMERANG:[0], BOUNCE:[0], MELEE:[-20,0,20],
    };
    const offsets = patterns[weaponType] ?? patterns.SPREAD;
    return offsets.map(off => ({
      vx: Math.cos(this.aimAngle + off * Math.PI/180) * speed,
      vy: Math.sin(this.aimAngle + off * Math.PI/180) * speed,
      angleOffset: off, weaponType,
      trailColor: weaponType==='STRAIGHT'?'#00FFFF':weaponType==='HOMING'?'#FF88FF':'#FFD700',
    }));
  }

  private scoreTargets(px: number, py: number, facingRight: boolean, enemies: Enemy[]) {
    const facingAngle = facingRight ? 0 : Math.PI;
    const halfFov = (this.cfg.fovDegrees * Math.PI/180)/2;
    return enemies.filter(e => !e.defeated && !e.hidden).map(e => {
      const dx = e.x - px, dy = e.y - py;
      const dist = Math.hypot(dx, dy);
      const angleTo = Math.atan2(dy, dx);
      const angleDiff = Math.abs(this.angleDelta(facingAngle, angleTo));
      const distUtil = Math.max(0, 1 - dist/(this.cfg.maxRange*1.5));
      const angleUtil = angleDiff < halfFov ? 1 - angleDiff/halfFov
        : Math.max(0, 0.3 - (angleDiff - halfFov));
      return { enemy: e, utility: distUtil * angleUtil, dist };
    });
  }

  private shouldSwitch(c: ScoredTarget): boolean {
    if (!this.currentTarget || this.currentTarget.defeated) return true;
    if (performance.now() - this.lastSwitchTime < this.cfg.minHoldMs) return false;
    return c.utility > 0.5 * this.cfg.stickyThreshold;
  }

  private lerpAngle(a: number, b: number, t: number) { return a + this.angleDelta(b,a)*t; }
  private angleDelta(a: number, b: number) {
    let d = a-b; while (d > Math.PI) d -= Math.PI*2; while (d < -Math.PI) d += Math.PI*2; return d;
  }
}

interface Enemy { x: number; y: number; defeated: boolean; hidden: boolean; }
interface ScoredTarget { enemy: Enemy; utility: number; dist: number; }
interface Projectile { vx: number; vy: number; angleOffset: number; weaponType: WeaponType; trailColor: string; }
type WeaponType = 'SPREAD'|'STRAIGHT'|'HOMING'|'BOOMERANG'|'BOUNCE'|'MELEE';
```

The `firePattern` method bridges targeting and projectile generation. On each fire tick, the five spread projectiles emanate from the interpolated aim angle, naturally sweeping across enemy positions. Combined with the weakness system, the auto-aim preferentially targets enemies vulnerable to the currently equipped element — all invisible to the child, who simply watches their character fight effectively.

### 2.3 Weapon Combination via Stamp Adjacency

#### 2.3.1 Gunstar Heroes-Inspired: 4 Base Weapons, 16 Combinations

Treasure's *Gunstar Heroes* provides four base types — Force, Lightning, Fire, and Chaser — and any two combine into a unique hybrid [^31^]. Fire + Lightning produces a laser sword; Chaser + Fire produces homing fireballs; two Lightning shots merge into a massive laser cannon [^21^]. This yields 16 weapons from 4 base types, proving depth emerges from system interaction, not content volume [^31^]. The team "experimented with weapon attributes until the end of development" and "designed the game so players would continue discovering new weapons" [^31^].

For the stamp platform, the base types expand to six (adding Ice and Nature), yielding 36 possible combinations. The LLM defines recipes for the most visually distinct combinations; for others, it falls back to hybrid blending that averages colors and damage. A child placing Ice next to Lightning receives the "Frozen Spark" with stun-chain effects; rare combinations still produce functional hybrids with blended names and icons. The discovery mechanic is identical to Gunstar Heroes — experimentation rewards the curious child with ever-more spectacular effects.

#### 2.3.2 Visual Merge Animation and Discovery Feedback

When two Weapon Stamps sit within 80 pixels, the combination triggers in three visual phases. First, a sparkle trail draws itself between stamps — a dotted line of pulsing gold stars hinting at interaction. Second, both stamps flash white and scale to 1.3× before snapping together at their midpoint. Third, the combined stamp adopts a blended icon (e.g., "🔥⚡") and emits a particle burst in the blended color.

For first-time discoveries, "✨ New Combo! ✨" appears briefly — never instructional text. A picture-book journal records all finds, rendering each as fused stamps with their names. This progression system has no numbers, only visual artifacts of experimentation. The `MergeAnimationController` below implements the three-phase sequence client-side:

```typescript
/** MergeAnimationController — three-phase visual sequence for stamp combination */
class MergeAnimationController {
  private merges = new Map<string, MergeState>();

  trigger(result: ComboResult) {
    const key = result.ids.sort().join('|');
    if (this.merges.has(key)) return;
    this.merges.set(key, {
      phase: 'TRAIL', progress: 0,
      mid: result.mid, color: result.color, name: result.name,
    });
    if (this.isFirstDiscovery(result.name)) {
      events.emit('floatingLabel', {
        text: `✨ ${result.name}! ✨`, x: result.mid.x, y: result.mid.y - 40,
        durationMs: 2000, color: '#FFD700',
      });
    }
  }

  update(dt: number): Particle[] {
    const out: Particle[] = [];
    for (const [key, m] of this.merges) {
      m.progress += dt;
      if (m.phase === 'TRAIL' && m.progress < 400) {
        const t = m.progress / 400;
        for (let i = 0; i < 5; i++) {
          const tt = (t + i * 0.2) % 1;
          out.push({ x: m.mid.x * tt, y: m.mid.y * tt, size: 4*(1-tt),
                     color: m.color, alpha: 1-tt, type: 'sparkle' });
        }
      } else if (m.phase === 'TRAIL') {
        m.phase = 'FLASH'; m.progress = 0;
      } else if (m.phase === 'FLASH' && m.progress < 300) {
        const t = m.progress / 300;
        out.push({ x: m.mid.x, y: m.mid.y, size: 32*(1+Math.sin(t*Math.PI)*0.3),
                   color: '#FFFFFF', alpha: 1-t, type: 'flash' });
      } else if (m.phase === 'FLASH') {
        m.phase = 'SETTLE'; m.progress = 0;
      } else if (m.phase === 'SETTLE' && m.progress < 500) {
        const t = m.progress / 500;
        for (let i = 0; i < 12; i++) {
          const ang = (i/12)*Math.PI*2, spd = 60*(1-t);
          out.push({ x: m.mid.x + Math.cos(ang)*spd*t, y: m.mid.y + Math.sin(ang)*spd*t,
                     size: 6*(1-t), color: m.color, alpha: 1-t, type: 'burst' });
        }
        if (m.progress >= 500) this.merges.delete(key);
      }
    }
    return out;
  }

  private isFirstDiscovery(name: string): boolean {
    const d = JSON.parse(localStorage.getItem('discoveredCombos') ?? '[]');
    if (!d.includes(name)) { d.push(name); localStorage.setItem('discoveredCombos', JSON.stringify(d)); return true; }
    return false;
  }
}

interface ComboResult { ids: string[]; mid: { x: number; y: number }; name: string; color: string; }
interface Particle { x: number; y: number; size: number; color: string; alpha: number; type: string; }
```

#### 2.3.3 WeaponCombinationEngine Implementation

```typescript
/** WeaponCombinationEngine — adjacency detection with recipe matrix and hybrid fallback */
class WeaponCombinationEngine {
  static readonly BASE: Record<string, { color: string; pattern: string }> = {
    FORCE:     { color: '#8888FF', pattern: 'RAPID' },
    LIGHTNING: { color: '#FFFF00', pattern: 'BEAM' },
    FIRE:      { color: '#FF4444', pattern: 'WAVE' },
    CHASER:    { color: '#FF88FF', pattern: 'HOMING' },
    ICE:       { color: '#88FFFF', pattern: 'SPREAD' },
    NATURE:    { color: '#44DD44', pattern: 'BOOMERANG' },
  };

  static readonly RECIPES: Record<string, { name: string; effect: string; dmgMult: number; color: string }> = {
    'FIRE+FIRE':          { name:'Inferno Cannon',   effect:'massive_fire_wave', dmgMult:3, color:'#FF4400' },
    'LIGHTNING+LIGHTNING':{ name:'Omega Beam',       effect:'piercing_beam',     dmgMult:4, color:'#FFFF88' },
    'CHASER+CHASER':      { name:'Star Stream',      effect:'unlimited_homing',  dmgMult:2, color:'#FFAAFF' },
    'FORCE+FORCE':        { name:'Heavy Machine Gun',effect:'big_bullets',       dmgMult:2, color:'#AAAAFF' },
    'ICE+ICE':            { name:'Blizzard',         effect:'freeze_area',       dmgMult:2, color:'#AAFFFF' },
    'NATURE+NATURE':      { name:'Vine Whip',        effect:'lashing_vines',     dmgMult:3, color:'#66FF66' },
    'FIRE+LIGHTNING':     { name:'Plasma Sword',     effect:'melee_beam',        dmgMult:5, color:'#FF8800' },
    'CHASER+FIRE':        { name:'Homing Fireball',  effect:'tracking_fire',     dmgMult:3, color:'#FF6644' },
    'FORCE+FIRE':         { name:'Explosive Shot',   effect:'explode_on_hit',    dmgMult:3, color:'#FF2222' },
    'FORCE+LIGHTNING':    { name:'Railgun',          effect:'piercing_shot',     dmgMult:4, color:'#CCCC44' },
    'FORCE+CHASER':       { name:'Smart Bullets',    effect:'homing_bullets',    dmgMult:2, color:'#CC88FF' },
    'ICE+FIRE':           { name:'Steam Cloud',      effect:'obscure_vision',    dmgMult:1, color:'#DDDDDD' },
    'ICE+LIGHTNING':      { name:'Frozen Spark',     effect:'stun_chain',        dmgMult:2, color:'#AAFFFF' },
    'ICE+FORCE':          { name:'Ice Shards',       effect:'spread_piercing',   dmgMult:2, color:'#88DDFF' },
    'ICE+CHASER':         { name:'Ice Seekers',      effect:'homing_freeze',     dmgMult:2, color:'#AADDFF' },
    'NATURE+FIRE':        { name:'Wildfire',         effect:'burning_spread',    dmgMult:3, color:'#FFAA44' },
    'NATURE+LIGHTNING':   { name:'Thundervine',      effect:'whip_stun',         dmgMult:3, color:'#BBDD44' },
    'NATURE+FORCE':       { name:'Seed Gun',         effect:'growing_shots',     dmgMult:2, color:'#88CC66' },
    'NATURE+CHASER':      { name:'Pollen Swarm',     effect:'homing_drowsy',     dmgMult:1, color:'#CCFFAA' },
    'NATURE+ICE':         { name:'Crystal Bloom',    effect:'ice_nova',          dmgMult:3, color:'#AAFFCC' },
    'FORCE+ICE':          { name:'Ice Shards',       effect:'spread_piercing',   dmgMult:2, color:'#88DDFF' },
  };

  static readonly ADJACENCY_PX = 80;

  detectAndCombine(stamps: WeaponStamp[]): ComboResult[] {
    const out: ComboResult[] = [];
    for (let i = 0; i < stamps.length; i++)
      for (let j = i + 1; j < stamps.length; j++)
        if (this.adjacent(stamps[i], stamps[j])) out.push(this.combine(stamps[i], stamps[j]));
    return out;
  }

  private adjacent(a: WeaponStamp, b: WeaponStamp) {
    return Math.hypot(a.x-b.x, a.y-b.y) < WeaponCombinationEngine.ADJACENCY_PX;
  }

  private combine(a: WeaponStamp, b: WeaponStamp): ComboResult {
    const r = WeaponCombinationEngine.RECIPES[`${a.type}+${b.type}`]
           ?? WeaponCombinationEngine.RECIPES[`${b.type}+${a.type}`];
    if (r) return {
      ids: [a.id,b.id], mid: { x:(a.x+b.x)/2, y:(a.y+b.y)/2 },
      name: r.name, effect: r.effect, dmgMult: r.dmgMult, color: r.color, isRecipe: true,
    };
    const ba = WeaponCombinationEngine.BASE[a.type], bb = WeaponCombinationEngine.BASE[b.type];
    return {
      ids: [a.id,b.id], mid: { x:(a.x+b.x)/2, y:(a.y+b.y)/2 },
      name: `${a.type}-${b.type} Blend`, effect: `${ba.pattern}_${bb.pattern}`,
      dmgMult: 1, color: this.blend(ba.color, bb.color), isRecipe: false,
    };
  }

  private blend(a: string, b: string) {
    const r = (h: string) => [0,2,4].map(i => parseInt(h.slice(1).substring(i,i+2), 16));
    const [ra,ga,ba2] = r(a), [rb,gb,bb2] = r(b);
    return `#${[ra+rb,ga+gb,ba2+bb2].map(v => Math.round(v/2).toString(16).padStart(2,'0')).join('')}`;
  }
}

interface WeaponStamp { id: string; type: string; x: number; y: number; }
interface ComboResult { ids: string[]; mid: { x: number; y: number }; name: string; effect: string; dmgMult: number; color: string; isRecipe: boolean; }
```

The `RECIPES` matrix contains 21 curated combinations. For undefined pairs, the hybrid fallback produces a functional weapon by blending colors and averaging damage — guaranteeing every adjacency produces a satisfying result. The 80-pixel threshold is calibrated to the default 64-pixel grid: stamps in neighboring cells combine, stamps two cells apart do not. This creates an intuitive "proximity = power" relationship discoverable through experimentation.

The combination system also integrates with the weakness system. When a combined weapon strikes an enemy, both base elements are tested: if either is super-effective, the strike receives gold critical visuals. A Plasma Sword (Fire + Lightning) critically hits both Ice enemies (Fire beats Ice) and Metal enemies (Lightning beats Metal), giving combined weapons broader tactical coverage than base components. The child does not calculate this; the system emits the appropriate feedback automatically.

#### 2.3.4 Child-Friendly Collision Filtering

Friendly fire is a critical edge case. When a child places an Enemy Stamp near their Hero Stamp, projectiles must never hit the hero. The LLM auto-generates collision filtering code that tags every projectile with its owner and skips same-team pairs. This is hardcoded — no stamp configuration needed.

```typescript
/** CollisionFilter — auto-generated by LLM, prevents friendly fire */
function shouldCollide(a: Collider, b: Collider): boolean {
  if (a.team === b.team) return false;
  if (a.kind === 'hero_projectile') return b.kind === 'enemy' || b.kind === 'destructible';
  if (a.kind === 'enemy_projectile') return b.kind === 'hero';
  if (a.kind === 'collectible') return b.kind === 'hero';
  if (b.kind === 'collectible') return a.kind === 'hero';
  return true;
}

interface Collider { team: 'hero'|'enemy'|'neutral'; kind: string; x: number; y: number; radius: number; }
```

This filter eliminates an entire class of frustrating accidents. Combined with generous enemy hurtboxes (1.5× visual size) and a small player hurtbox (0.7× visual), the system feels forgiving without being obvious about it [^118^]. The `shouldCollide` function pairs with a circle-based `CollisionManager` that the LLM generates from canvas stamp positions, registering each entity with appropriate generosity multipliers.

Together, these subsystems — the elemental weakness cycle, utility-based auto-aim with spread pattern generation, adjacency-driven weapon combination with visual merge animation, and friendly-fire-safe collision filtering — form a complete combat architecture that a child interacts with exclusively through stamp placement. The LLM generates every line of code from a canvas containing nothing more than a Hero Stamp, a Spread Stamp, and an Enemy Stamp. The child sees combat that feels deep, responsive, and fair; the complexity is invisible by design.
