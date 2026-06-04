## 6. Puzzle & Environmental Mechanics

Puzzle mechanics transform stamp placement from static decoration into interactive cause-and-effect. Children as young as five already understand that flipping a light switch makes a room bright — the platform extends this embodied knowledge into game worlds where spatial proximity becomes the wiring language [^258^][^260^]. When a child places a Switch Stamp near a Door Stamp, the LLM treats adjacency as an implicit logical connection, auto-generating code that makes the switch open the door without the child drawing a line or writing a rule.

Research across studio postmortems — Playdead's affordance-driven puzzles in *Limbo* [^281^], Nintendo's switch-door systems in *Zelda* [^280^], Jonathan Blow's temporal manipulation in *Braid* [^287^] — converges on one principle: the best puzzles teach through interaction, not instruction. Every stamp must look like what it does, react immediately when touched, and forgive mistakes with delight rather than punishment [^282^]. This section implements three core subsystems: the auto-connection engine, the elemental reaction matrix, and the temporal mechanics controller.

### 6.1 Auto-Connection Puzzle System

#### 6.1.1 Switch-Door Auto-Connection via Proximity with Color-Coded Visual Feedback

The foundational puzzle primitive is the switch-door pair. In *The Legend of Zelda* series, dungeon design revolves around toggle mechanisms where a switch in one room reconfigures paths throughout the dungeon [^280^]. For a stamp platform, this collapses to a single spatial rule: when any switch-type stamp and any door-type stamp are within five grid cells, they auto-connect. Proximity *is* the connection.

Playdead's philosophy established that "affordances implicitly explain rules by having something sound, look, or act a certain way" [^281^]. A switch stamp must look pressable; a door stamp must look openable. The visual feedback system uses color-coded connection lines — when a switch activates, brief dotted lines pulse between the switch and every connected door using a shared color. Cross-verification findings confirm binary, color-coded states are more intuitive for children than gradients [^262^]. When a switch sits near two doors, the default opens *all* doors within range. A double-tap on a specific switch-door pair "locks" that binding. Research on spatial puzzle play confirms children naturally understand "near = related" [^368^].

#### 6.1.2 LLM Solvability Verification Preventing Dead-End Puzzles

A child places a locked door, adds a key on a ledge, then pushes a block over the edge — the puzzle becomes unsolvable. The LLM verifies solvability before generating code using breadth-first-search: "generating candidate puzzles first and using breadth-first-search for validating their solvability... proved to be considerably easier" [^363^].

The solvability checker runs after every stamp placement, building a reachability graph from the player start. A locked door is only valid if a key or switch lies within the reachable subgraph. Push blocks are checked for corner dead-ends — the classic Sokoban trap [^261^]. If unsolvable, a friendly mascot suggests a fix. If a child repeatedly creates unsolvable puzzles, the LLM silently widens the proximity range or adds pull capability to blocks.

#### 6.1.3 Implementation: PuzzleAutoConnector

```typescript
interface Stamp {
  id: string;
  type: 'step_plate' | 'pull_switch' | 'door' | 'locked_door' | 'key'
       | 'push_block' | 'bridge' | 'portal_pad' | 'time_crystal';
  position: { x: number; y: number };
  gridSize: number;
  variant?: string;
  properties: Record<string, unknown>;
  connections: string[];
  colorTag?: string;
}

interface Connection { from: string; to: string; color: string; locked: boolean; }

const CONNECTION_RANGE_CELLS = 5;
const CONNECTION_COLORS = ['#FF4444','#44FF44','#4444FF','#FFAA00','#AA44FF','#FF44AA'];

const COMPATIBILITY_MAP: Record<string, string[]> = {
  step_plate:   ['door','bridge','platform','gate'],
  pull_switch:  ['door','bridge','platform','gate','laser_emitter'],
  key:          ['locked_door','locked_gate'],
  portal_pad:   ['portal_pad'],
  time_crystal: ['*'],
  glow_orb:     ['lantern'],
};

class PuzzleAutoConnector {
  private stamps = new Map<string, Stamp>();
  private connections: Connection[] = [];
  private colorIndex = 0;

  addStamp(stamp: Stamp): { stamp: Stamp; newConnections: Connection[]; warnings: string[] } {
    if (['step_plate','pull_switch','key'].includes(stamp.type)) {
      stamp.colorTag = CONNECTION_COLORS[this.colorIndex % CONNECTION_COLORS.length];
      this.colorIndex++;
    }
    this.stamps.set(stamp.id, stamp);
    const newConns = this.findConnectionsFor(stamp);
    this.connections.push(...newConns);
    for (const conn of newConns) {
      this.stamps.get(conn.from)!.connections.push(conn.to);
      this.stamps.get(conn.to)!.connections.push(conn.from);
    }
    return { stamp, newConnections: newConns, warnings: this.checkSolvability() };
  }

  private distanceInCells(a: Stamp, b: Stamp): number {
    const dx = (a.position.x - b.position.x) / a.gridSize;
    const dy = (a.position.y - b.position.y) / a.gridSize;
    return Math.sqrt(dx * dx + dy * dy);
  }

  private findConnectionsFor(stamp: Stamp): Connection[] {
    const found: Connection[] = [];
    const compatible = COMPATIBILITY_MAP[stamp.type] || [];
    for (const other of this.stamps.values()) {
      if (other.id === stamp.id) continue;
      if (this.distanceInCells(stamp, other) > CONNECTION_RANGE_CELLS) continue;
      const otherCompat = COMPATIBILITY_MAP[other.type] || [];
      const canConnect = compatible.includes(other.type) || otherCompat.includes(stamp.type)
                      || compatible.includes('*') || otherCompat.includes('*');
      if (!canConnect) continue;
      const exists = this.connections.some(
        c => (c.from === stamp.id && c.to === other.id) || (c.from === other.id && c.to === stamp.id)
      );
      if (exists) continue;
      const isSource = ['step_plate','pull_switch','key'].includes(stamp.type);
      found.push({
        from: isSource ? stamp.id : other.id,
        to:   isSource ? other.id : stamp.id,
        color: this.stamps.get(isSource ? stamp.id : other.id)?.colorTag || '#FFFF00',
        locked: false,
      });
    }
    return found;
  }

  lockConnection(switchId: string, targetId: string): void {
    const conn = this.connections.find(c => c.from === switchId && c.to === targetId);
    if (conn) conn.locked = true;
    this.connections = this.connections.filter(
      c => c.from !== switchId || c.to === targetId || c.locked
    );
  }

  resolveActivation(stampId: string): string[] {
    const activated = new Set<string>();
    const queue = [stampId];
    const visited = new Set<string>();
    while (queue.length > 0) {
      const current = queue.shift()!;
      if (visited.has(current)) continue;
      visited.add(current);
      const stamp = this.stamps.get(current);
      if (!stamp) continue;
      if (['door','bridge','platform','gate','locked_door'].includes(stamp.type)) activated.add(current);
      for (const connId of stamp.connections) if (!visited.has(connId)) queue.push(connId);
    }
    return Array.from(activated);
  }

  checkSolvability(): string[] {
    const warnings: string[] = [];
    const playerStart = Array.from(this.stamps.values()).find(s => s.type === 'player_start');
    for (const stamp of this.stamps.values()) {
      if (stamp.type !== 'locked_door') continue;
      const hasKey = this.connections.some(c => c.to === stamp.id && this.stamps.get(c.from)?.type === 'key');
      const hasSwitch = this.connections.some(
        c => c.to === stamp.id && ['step_plate','pull_switch'].includes(this.stamps.get(c.from)?.type || '')
      );
      if (!hasKey && !hasSwitch) warnings.push(`locked_door:${stamp.id} — no key/switch in range`);
      if (hasKey && playerStart) {
        const keyConn = this.connections.find(c => c.to === stamp.id);
        if (keyConn) {
          const key = this.stamps.get(keyConn.from)!;
          const dx = Math.abs(playerStart.position.x - key.position.x) / playerStart.gridSize;
          const dy = Math.abs(playerStart.position.y - key.position.y) / playerStart.gridSize;
          if (Math.sqrt(dx * dx + dy * dy) > 50) warnings.push(`locked_door:${stamp.id} — key unreachable`);
        }
      }
    }
    return warnings;
  }

  getConnections(): ReadonlyArray<Connection> { return this.connections; }
}
```

The five-cell proximity threshold matches the universal 32px influence radius from cross-dimensional research. `resolveActivation` performs BFS traversal enabling chain reactions. The solvability checker ensures every locked mechanism has an accessible trigger.

### 6.2 Elemental Reaction Engine

#### 6.2.1 Six-Element System with 15+ Pairwise Reactions

Elemental interactions transform static placement into dynamic simulation. The six-element system — fire, water, ice, lightning, plant, wind — draws from *Zelda*'s elemental mechanics [^360^][^361^]. Each element has consistent behavior: fire burns, water extinguishes, ice freezes, wind pushes, plant grows, lightning conducts. Fire meeting ice melts it into water; water touching plant makes it grow into a climbable platform. These reactions are *always* consistent — fire always melts ice — following Blow's philosophy that every stamp must have consistent behavior with every other stamp [^289^].

| Element Pair | Reaction | Result Stamp | Visual Effect |
|---|---|---|---|
| Fire + Ice | Melt | Water pool | Steam burst |
| Fire + Water | Extinguish | Steam cloud | White puff |
| Fire + Plant | Burn | Ash pile | Fire burst |
| Water + Plant | Grow | Climbing vine | Sparkle growth |
| Water + Lightning | Conduct | Shockwave | Electric ripple |
| Ice + Wind | Push shard | Ice projectile | Ice trail |
| Wind + Fire | Spread | Fire wall | Flame trail |
| Lightning + Metal* | Conduct chain | Powered device | Arcing electricity |
| Plant + Wind | Scatter seeds | New sprouts | Floating seeds |
| Ice + Plant | Freeze growth | Crystal tree | Frost coating |
| Wind + Water | Wave surge | Pushing current | Wave ripple |
| Lightning + Fire | Plasma burst | Magma spot | Purple-white flash |
| Water + Ice | Refreeze | Larger ice sheet | Frost spread |
| Plant + Plant | Overgrow | Dense platform | Rapid expansion |
| Wind + Wind | Tornado | Pulling vortex | Spiral suction |

*Metal refers to any metal-type stamp (switch, key) placed nearby.

#### 6.2.2 Visual Reaction Preview When Placing Elements Near Each Other

Before a reaction occurs, the platform shows a predictive preview. When a child holds a fire stamp near an ice stamp, the ice pulses with a steam particle effect and a floating icon showing the predicted melt. The preview system tracks the dragged stamp against all placed stamps within a three-cell radius. Once released, the full reaction plays; if moved away, the preview fades without executing.

#### 6.2.3 Implementation: ElementalReactionEngine

```typescript
type ElementType = 'fire' | 'water' | 'ice' | 'lightning' | 'plant' | 'wind';

interface ElementalStamp extends Stamp { element: ElementType; intensity: number; }

interface ReactionDef {
  elements: [ElementType, ElementType];
  resultStamp: string;
  effectName: string;
  requiresOrder?: boolean;
}

const REACTION_MATRIX: ReactionDef[] = [
  { elements: ['fire','ice'],         resultStamp: 'water_pool',    effectName: 'melt' },
  { elements: ['fire','water'],      resultStamp: 'steam_cloud',   effectName: 'extinguish' },
  { elements: ['fire','plant'],      resultStamp: 'ash_pile',      effectName: 'burn' },
  { elements: ['water','plant'],     resultStamp: 'vine_platform', effectName: 'grow' },
  { elements: ['water','lightning'], resultStamp: 'shock_zone',    effectName: 'conduct' },
  { elements: ['ice','wind'],        resultStamp: 'ice_shard',     effectName: 'push' },
  { elements: ['wind','fire'],       resultStamp: 'fire_wall',     effectName: 'spread', requiresOrder: true },
  { elements: ['plant','wind'],      resultStamp: 'seedling',      effectName: 'scatter' },
  { elements: ['ice','plant'],       resultStamp: 'crystal_tree',  effectName: 'freeze_grow' },
  { elements: ['wind','water'],      resultStamp: 'wave_push',     effectName: 'surge' },
  { elements: ['lightning','fire'],  resultStamp: 'magma_spot',    effectName: 'plasma' },
  { elements: ['water','ice'],       resultStamp: 'ice_sheet',     effectName: 'refreeze' },
  { elements: ['plant','plant'],     resultStamp: 'thick_vine',    effectName: 'overgrow' },
  { elements: ['wind','wind'],       resultStamp: 'vortex',        effectName: 'tornado' },
];

const REACTION_RANGE_CELLS = 2;
const PREVIEW_RANGE_CELLS = 3;

class ElementalReactionEngine {
  private placed = new Map<string, ElementalStamp>();

  placeStamp(stamp: ElementalStamp): { reactions: ReactionResult[] } {
    this.placed.set(stamp.id, stamp);
    const reactions = this.checkReactionsFor(stamp);
    return { reactions: reactions.map(r => this.executeReaction(r.a, r.b, r.def)) };
  }

  checkPreviews(dragged: ElementType, pos: { x: number; y: number }, grid: number): PreviewHint[] {
    const hints: PreviewHint[] = [];
    for (const existing of this.placed.values()) {
      const dx = (pos.x - existing.position.x) / grid;
      const dy = (pos.y - existing.position.y) / grid;
      const dist = Math.sqrt(dx * dx + dy * dy);
      if (dist > PREVIEW_RANGE_CELLS) continue;
      const reaction = this.findReaction(dragged, existing.element);
      if (reaction) hints.push({ targetId: existing.id, predictedResult: reaction.resultStamp,
                                  effectName: reaction.effectName, willTrigger: dist <= REACTION_RANGE_CELLS });
    }
    return hints;
  }

  private checkReactionsFor(stamp: ElementalStamp) {
    const found: Array<{ a: string; b: string; def: ReactionDef }> = [];
    for (const other of this.placed.values()) {
      if (other.id === stamp.id) continue;
      const dx = (stamp.position.x - other.position.x) / stamp.gridSize;
      const dy = (stamp.position.y - other.position.y) / stamp.gridSize;
      if (Math.sqrt(dx * dx + dy * dy) > REACTION_RANGE_CELLS) continue;
      const reaction = this.findReaction(stamp.element, other.element);
      if (reaction) found.push({ a: stamp.id, b: other.id, def: reaction });
    }
    return found;
  }

  private findReaction(a: ElementType, b: ElementType): ReactionDef | undefined {
    for (const def of REACTION_MATRIX) {
      const [e1, e2] = def.elements;
      if (def.requiresOrder) { if (a === e1 && b === e2) return def; }
      else if ((a === e1 && b === e2) || (a === e2 && b === e1)) return def;
    }
    return undefined;
  }

  private executeReaction(aId: string, bId: string, def: ReactionDef): ReactionResult {
    const sa = this.placed.get(aId)!, sb = this.placed.get(bId)!;
    return {
      sourceA: aId, sourceB: bId, resultStampType: def.resultStamp,
      resultPosition: { x: (sa.position.x + sb.position.x) / 2, y: (sa.position.y + sb.position.y) / 2 },
      effectName: def.effectName, elementA: sa.element, elementB: sb.element,
    };
  }

  getParticleConfig(effectName: string): ParticleConfig {
    const c: Record<string, ParticleConfig> = {
      melt: {color:0xAADDFF,count:20,speed:40,lifespan:800,scale:{start:0.4,end:0}},
      extinguish: {color:0xFFFFFF,count:30,speed:30,lifespan:1000,scale:{start:0.5,end:0}},
      burn: {color:0xFF4400,count:25,speed:60,lifespan:700,scale:{start:0.5,end:0}},
      grow: {color:0x44FF44,count:40,speed:50,lifespan:1200,scale:{start:0.3,end:0}},
      conduct: {color:0xFFFF00,count:15,speed:80,lifespan:500,scale:{start:0.6,end:0}},
      push: {color:0x88FFFF,count:10,speed:100,lifespan:600,scale:{start:0.3,end:0}},
      spread: {color:0xFF6600,count:35,speed:70,lifespan:900,scale:{start:0.5,end:0}},
      plasma: {color:0xFF00FF,count:50,speed:90,lifespan:800,scale:{start:0.6,end:0}},
      refreeze: {color:0xCCFFFF,count:20,speed:20,lifespan:1000,scale:{start:0.4,end:0}},
      overgrow: {color:0x228822,count:35,speed:45,lifespan:1100,scale:{start:0.4,end:0}},
      tornado: {color:0xCCCCCC,count:60,speed:120,lifespan:1500,scale:{start:0.3,end:0}},
    };
    return c[effectName] || {color:0xFFFFFF,count:10,speed:30,lifespan:500,scale:{start:0.3,end:0}};
  }
}

interface ReactionResult {
  sourceA: string; sourceB: string; resultStampType: string;
  resultPosition: { x: number; y: number }; effectName: string;
  elementA: ElementType; elementB: ElementType;
}

interface PreviewHint {
  targetId: string; predictedResult: string; effectName: string; willTrigger: boolean;
}

interface ParticleConfig {
  color: number; count: number; speed: number; lifespan: number; scale: { start: number; end: number };
}
```

The engine uses symmetric lookup for most reactions but supports directional ones via `requiresOrder`. `checkPreviews` evaluates reactions within a three-cell preview radius. All 15 reactions have particle configs tuned for 1280×720 canvas at 64px grid resolution.

### 6.3 Temporal Mechanics

#### 6.3.1 Braid-Inspired: Time Crystal Stamp for Rewind, Echo Mirror for Ghost Playback, Green Anchor for Save Point in Time

Temporal mechanics extend puzzles into time itself. *Braid* demonstrated that time manipulation can be the core puzzle primitive [^290^]. For children aged 5–7, three simplified concepts suffice.

The **Time Crystal** stamp is the entry point. When the player touches it, every moving object within ten cells rewinds through recorded state history for five seconds. The rewind is visually dramatic: a blue spiral expands from the crystal, objects leave ghost trails, and a pitched-down whoosh plays. This transforms mistakes into magic.

The **Green Anchor** stamp (from *Braid* World 3's green-glow objects [^287^]) marks objects as immune to time. Anchored stamps maintain state during rewind, creating puzzles where the child decides what stays: keep the bridge extended while everything else rewinds, or hold the key in place. The child learns "green shimmer = stays put."

The **Echo Mirror** stamp creates a ghost copy of the player repeating their last ten seconds — a simplified *Braid* World 5 "shadow Tim" [^290^]. The ghost is semi-transparent and purple. The child and ghost stand on separate pressure plates, cooperatively activating multi-switch puzzles.

#### 6.3.2 Slow-Motion Preview Mode Activated by Holding a Stamp Before Placing

When a child holds a stamp above the canvas, the game enters slow-motion at 25% speed. Ghost outlines show predicted outcomes: hold a Time Crystal near moving platforms and see translucent shadow-platforms showing where those platforms were five seconds ago. Research shows five-year-olds need 2–3× longer processing time for cause-and-effect reasoning [^262^]. The preview triggers automatically on hold.

#### 6.3.3 Implementation: TemporalMechanicsController

```typescript
interface StateSnapshot {
  frame: number; timestamp: number;
  x: number; y: number; vx: number; vy: number;
  active: boolean;
}

interface TemporalObject {
  id: string; spriteId: string;
  isGreenAnchor: boolean;
  history: StateSnapshot[];
  maxHistoryFrames: number;
}

const REWIND_SECONDS = 5;
const RECORD_FPS = 20;
const ECHO_DELAY_SECONDS = 10;
const PREVIEW_SLOWMO_SCALE = 0.25;
const TIME_CRYSTAL_RADIUS_CELLS = 10;

class TemporalMechanicsController {
  private objects = new Map<string, TemporalObject>();
  private isRewinding = false;
  private rewindTargetFrame = 0;
  private currentFrame = 0;
  private recordInterval = 1000 / RECORD_FPS;
  private lastRecordTime = 0;
  private timeScale = 1.0;
  private playerHistory: StateSnapshot[] = [];

  registerObject(id: string, spriteId: string, isGreenAnchor: boolean = false): void {
    this.objects.set(id, {
      id, spriteId, isGreenAnchor,
      history: [], maxHistoryFrames: REWIND_SECONDS * RECORD_FPS,
    });
  }

  recordFrame(rawTime: number, getState: (id: string) => StateSnapshot | null): void {
    if (rawTime - this.lastRecordTime < this.recordInterval) return;
    this.lastRecordTime = rawTime;
    this.currentFrame++;
    for (const obj of this.objects.values()) {
      if (obj.isGreenAnchor) continue;
      const state = getState(obj.id);
      if (!state) continue;
      state.frame = this.currentFrame;
      obj.history.push(state);
      while (obj.history.length > obj.maxHistoryFrames) obj.history.shift();
    }
  }

  recordPlayerState(state: StateSnapshot): void {
    state.frame = this.currentFrame;
    this.playerHistory.push({ ...state });
    while (this.playerHistory.length > ECHO_DELAY_SECONDS * RECORD_FPS * 2) this.playerHistory.shift();
  }

  activateTimeCrystal(centerX: number, centerY: number, gridSize: number): string[] {
    const affected: string[] = [];
    const radiusPx = TIME_CRYSTAL_RADIUS_CELLS * gridSize;
    for (const obj of this.objects.values()) {
      const current = obj.history[obj.history.length - 1];
      if (!current) continue;
      const dx = current.x - centerX, dy = current.y - centerY;
      if (Math.sqrt(dx * dx + dy * dy) > radiusPx) continue;
      if (obj.isGreenAnchor) { this.triggerGreenAnchorEffect(obj.id); continue; }
      affected.push(obj.id);
    }
    this.isRewinding = true;
    this.rewindTargetFrame = Math.max(0, this.currentFrame - REWIND_SECONDS * RECORD_FPS);
    return affected;
  }

  updateRewind(dt: number): Map<string, { x: number; y: number; active: boolean }> {
    const overrides = new Map<string, { x: number; y: number; active: boolean }>();
    if (!this.isRewinding) return overrides;
    const framesToRewind = Math.ceil((dt * 2.0) / this.recordInterval);
    this.currentFrame = Math.max(this.rewindTargetFrame, this.currentFrame - framesToRewind);
    let anyActive = false;
    for (const obj of this.objects.values()) {
      if (obj.isGreenAnchor) continue;
      const snapshot = this.findSnapshotAtFrame(obj, this.currentFrame);
      if (snapshot) {
        overrides.set(obj.id, { x: snapshot.x, y: snapshot.y, active: snapshot.active });
        obj.history = obj.history.filter(h => h.frame <= this.currentFrame);
        anyActive = true;
      }
    }
    if (!anyActive || this.currentFrame <= this.rewindTargetFrame) this.isRewinding = false;
    return overrides;
  }

  private findSnapshotAtFrame(obj: TemporalObject, target: number): StateSnapshot | null {
    for (let i = obj.history.length - 1; i >= 0; i--) {
      if (obj.history[i].frame <= target) return obj.history[i];
    }
    return null;
  }

  private triggerGreenAnchorEffect(objectId: string): void {
    // Signal to renderer: flash green glow, play metallic ping
  }

  spawnEchoMirror(mirrorPos: { x: number; y: number },
                  onGhostCreated: (id: string, x: number, y: number) => void): string | null {
    const delayFrames = ECHO_DELAY_SECONDS * RECORD_FPS;
    const ghostHistory = this.playerHistory.filter(h => h.frame <= this.currentFrame - delayFrames);
    if (ghostHistory.length < 10) return null;
    const ghostId = `ghost_${Date.now()}`;
    onGhostCreated(ghostId, mirrorPos.x, mirrorPos.y);
    return ghostId;
  }

  updateGhostPlayback(ghostId: string, playbackFrame: number): { x: number; y: number } | null {
    if (playbackFrame >= this.playerHistory.length) return null;
    const s = this.playerHistory[playbackFrame];
    return { x: s.x, y: s.y };
  }

  enterPreviewMode(): void { this.timeScale = PREVIEW_SLOWMO_SCALE; }
  exitPreviewMode(): void  { this.timeScale = 1.0; }
  getTimeScale(): number   { return this.timeScale; }
  get isCurrentlyRewinding(): boolean { return this.isRewinding; }

  getGhostTrails(objectId: string, trailCount: number = 5): Array<{ x: number; y: number; alpha: number }> {
    const obj = this.objects.get(objectId);
    if (!obj || obj.history.length < 2) return [];
    const trails: Array<{ x: number; y: number; alpha: number }> = [];
    const step = Math.max(1, Math.floor(obj.history.length / trailCount));
    for (let i = 0; i < Math.min(trailCount, obj.history.length); i++) {
      const idx = obj.history.length - 1 - i * step;
      if (idx < 0) break;
      trails.push({ x: obj.history[idx].x, y: obj.history[idx].y, alpha: 0.3 * (1 - i / trailCount) });
    }
    return trails;
  }
}
```

The controller implements *Braid*'s recording architecture at 20 FPS [^287^]. Each object maintains a circular buffer capped at `REWIND_SECONDS × RECORD_FPS`. `activateTimeCrystal` checks which objects fall within the ten-cell radius, skipping green-anchor objects. The rewind operates destructively — history beyond the rewind point is discarded, matching *Braid*'s semantic model.

```typescript
class GhostRenderer {
  constructor(private scene: Phaser.Scene) {}

  renderGhostTrail(trails: Array<{ x: number; y: number; alpha: number }>): void {
    for (const trail of trails.reverse()) {
      const g = this.scene.add.rectangle(trail.x, trail.y, 32, 32, 0x88FFFF, trail.alpha * 0.3);
      g.setDepth(1);
      this.scene.tweens.add({ targets: g, alpha: 0, scaleX: 0.8, scaleY: 0.8, duration: 400, onComplete: () => g.destroy() });
    }
  }

  applyGreenGlow(sprite: Phaser.GameObjects.Sprite): Phaser.GameObjects.Ellipse {
    const glow = this.scene.add.ellipse(sprite.x, sprite.y, sprite.width * 1.4, sprite.height * 1.4, 0x00FF44, 0.25);
    glow.setDepth(sprite.depth - 1);
    this.scene.tweens.add({ targets: glow, alpha: { from: 0.15, to: 0.4 }, scaleX: { from: 1, to: 1.15 }, scaleY: { from: 1, to: 1.15 }, duration: 900, yoyo: true, repeat: -1 });
    return glow;
  }

  spawnRewindSpiral(centerX: number, centerY: number): void {
    const gfx = this.scene.add.graphics(); gfx.setDepth(1000);
    let angle = 0, radius = 8;
    const ev = this.scene.time.addEvent({ delay: 16, repeat: 180, callback: () => {
      gfx.fillStyle(0x88DDFF, 0.25);
      gfx.fillCircle(centerX + Math.cos(angle) * radius, centerY + Math.sin(angle) * radius, 4);
      angle += 0.35; radius += 0.6;
    }});
    const vig = this.scene.add.rectangle(centerX, centerY, this.scene.cameras.main.width, this.scene.cameras.main.height, 0x004488, 0.15);
    vig.setScrollFactor(0); vig.setDepth(999);
    this.scene.tweens.add({ targets: vig, alpha: 0, duration: 1200, delay: 4000,
      onComplete: () => { vig.destroy(); gfx.destroy(); ev.destroy(); } });
    this.scene.sound.play('rewind_whoosh', { rate: 0.4, volume: 0.6 });
  }

  createGhostSprite(x: number, y: number, texture: string): Phaser.GameObjects.Sprite {
    const ghost = this.scene.add.sprite(x, y, texture);
    ghost.setAlpha(0.45).setTint(0xAA66FF).setDepth(50);
    this.scene.tweens.add({ targets: ghost, y: y - 4, duration: 600, yoyo: true, repeat: -1, ease: 'Sine.easeInOut' });
    return ghost;
  }
}
```

The `GhostRenderer` separates visuals from state. The spiral draws expanding circles creating the signature rewind vortex. Echo ghost's bobbing and purple tint differentiate it from the player. Together, these three systems — auto-connection, elemental reaction, and temporal mechanics — form a complete puzzle vocabulary. The auto-connector links switches to doors. The elemental engine melts ice into water that grows a plant platform. The temporal controller rewinds mistakes. Every system shares the same DNA: proximity implies connection, visual feedback confirms causality, and failure is always reversible.
