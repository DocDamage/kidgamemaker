## 10. Accessibility & Child-First UX

A platform for 5-year-olds must be built on a hard truth: a kindergarten student has fundamentally different capabilities than a typical gamer. Their attention span is 12–18 minutes [^1^], working memory holds only 2–3 items [^2^], fine motor control is still developing — they can write letters but struggle with precise targeting [^3^] — and they are pre-readers who rely on icons and sound, not text [^4^]. Every design decision here flows from those constraints.

The industry has spent a decade solving a parallel problem. Celeste's Assist Mode proved granular, toggleable help is more valuable than fixed difficulty levels [^6^][^7^]. Hades' God Mode showed progressive adaptation — getting slightly stronger after each failure — creates positive reinforcement instead of frustration [^14^][^15^]. Nintendo's invisible assists in Mario Odyssey and Yoshi's Crafted World showed help works best when the player does not know it is there [^11^][^13^]. The stamp platform borrows from all three, embedding accessibility into architecture rather than bolting it on [^5^].

### 10.1 Three-Tier Assist System

The platform implements three tiers that are not difficulty levels — they are fundamentally different interaction paradigms. A 5-year-old does not need an "easy" version of the same tool; they need a tool built for a brain that tracks two items at once and a hand that cannot reliably hit a 24-pixel target [^3^][^19^].

#### 10.1.1 Mellow Mode (Ages 5–6)

Mellow Mode follows HAL Laboratory's Kirby design philosophy: the default state is "impossible to fail" [^17^]. Following Kirby's Epic Yarn, there is no way to lose — falling bounces the player back with a giggle, enemies bump harmlessly, and every action produces forward progress [^18^].

Grid cells are 80×80 pixels. Touch targets are 64×64 — nearly 3× the WCAG minimum of 24×24 and above the Apple HIG recommendation of 44×44 [^19^][^27^]. Game speed is 75% of normal, increasing reaction time without the child perceiving slowdown [^7^]. Auto-correct silently fixes impossible configurations: fire over water becomes friendly steam, floating platforms gain invisible pillars. Every placement triggers a sound and sparkle — immediate positive feedback is critical for children's motivation [^21^].

Undo is infinite via a prominent 64×64 button. Auto-checkpoints fire every 10 seconds. Visual guides — subtle dotted lines — show connections between stamps, because a 5-year-old's working memory cannot hold more than two spatial relationships [^2^].

#### 10.1.2 Growing Mode (Ages 7–8)

Growing Mode introduces the first hints of consequence. The grid shrinks to 64×64 pixels, touch targets to 48×48 (matching Material Design) [^19^], game speed to 90%. Five hearts of health regenerate when standing still, following Mario Odyssey's generous model [^11^]. Visual guides shift to on-request via tap-and-hold. Undo is capped at 50 actions. Checkpoints become player-placed checkpoint stamps, following Ori's Soul Link model [^9^][^10^].

Growing Mode also activates the Struggle Detector, inspired by Hades' God Mode [^14^]. After three failures in 30 seconds, snap radius increases 10%, enemy speed drops 15%, and invisible safety platforms spawn below wide gaps. The child sees none of this — they feel themselves getting better.

#### 10.1.3 Creator Mode (Ages 9+)

Creator Mode removes most scaffolding. Stamps place freely on a 16×16 grid or with no grid. Full undo/redo (100 actions) with keyboard shortcuts. Game speed at 100%. Health has real consequences, though checkpoint stamps remain unlimited and free [^10^]. Creator Mode is never forced — transition is gradual and celebrated, offered as a choice when the platform detects readiness.

#### 10.1.4 Assist Profile Comparison

| Parameter | Mellow Mode (5–6) | Growing Mode (7–8) | Creator Mode (9+) |
|---|---|---|---|
| Grid cell size | 80×80 px | 64×64 px | 16×16 px (or free) |
| Min touch target | 64×64 px | 48×48 px | 44×44 px |
| Game speed | 75% | 90% | 100% |
| Health | Infinite | 5 hearts, regenerating | 3 hearts, consequences |
| Undo depth | Infinite | 50 actions | 100 actions |
| Visual guides | Always on | Tap-hold request | Off unless enabled |
| Auto-correct | Yes | No | No |
| Snap radius | 40 px (50% cell) | 24 px (37.5% cell) | 8 px (50% of fine cell) |
| Auto-checkpoint | Every 10s | Manual only | Manual only |
| Feedback | Every action | Every action | Milestone only |

The AssistManager implements these profiles with age-based initialization, parent overrides, and progressive adaptation.

```typescript
/**
 * AssistManager — Age-based assist with progressive adaptation.
 * Philosophy (Celeste + Hades + Nintendo): granular assists, progressive
 * adaptation rewards perseverance, snap-to-grid is invisible help.
 */

interface AssistConfig {
  assistTier: 'mellow' | 'growing' | 'creator';
  infiniteLives: boolean;
  snapToGrid: boolean;
  gridSize: number;
  snapRadius: number;
  gameSpeed: number;
  undoStackSize: number;
  autoCheckpoint: boolean;
  checkpointInterval: number;
  touchTargetMin: number;
  visualGuides: boolean;
  healthCount: number;
  healthRegen: boolean;
  autoCorrectInvalid: boolean;
  positiveFeedback: boolean;
  magneticPull: boolean;
  overlapSearchRadius: number;
}

const AGE_PROFILES: Record<number, AssistConfig> = {
  5: {
    assistTier: 'mellow', infiniteLives: true, snapToGrid: true,
    gridSize: 80, snapRadius: 40, gameSpeed: 0.75, undoStackSize: -1,
    autoCheckpoint: true, checkpointInterval: 10, touchTargetMin: 64,
    visualGuides: true, healthCount: -1, healthRegen: true,
    autoCorrectInvalid: true, positiveFeedback: true,
    magneticPull: true, overlapSearchRadius: 3,
  },
  6: {
    assistTier: 'mellow', infiniteLives: true, snapToGrid: true,
    gridSize: 72, snapRadius: 36, gameSpeed: 0.80, undoStackSize: -1,
    autoCheckpoint: true, checkpointInterval: 15, touchTargetMin: 60,
    visualGuides: true, healthCount: -1, healthRegen: true,
    autoCorrectInvalid: true, positiveFeedback: true,
    magneticPull: true, overlapSearchRadius: 3,
  },
  7: {
    assistTier: 'growing', infiniteLives: false, snapToGrid: true,
    gridSize: 64, snapRadius: 24, gameSpeed: 0.90, undoStackSize: 50,
    autoCheckpoint: false, checkpointInterval: 0, touchTargetMin: 48,
    visualGuides: false, healthCount: 5, healthRegen: true,
    autoCorrectInvalid: false, positiveFeedback: true,
    magneticPull: true, overlapSearchRadius: 2,
  },
  9: {
    assistTier: 'creator', infiniteLives: false, snapToGrid: true,
    gridSize: 16, snapRadius: 8, gameSpeed: 1.0, undoStackSize: 100,
    autoCheckpoint: false, checkpointInterval: 0, touchTargetMin: 44,
    visualGuides: false, healthCount: 3, healthRegen: false,
    autoCorrectInvalid: false, positiveFeedback: false,
    magneticPull: false, overlapSearchRadius: 1,
  },
};

class AssistManager {
  private config: AssistConfig;
  private failureCount = 0;
  private adaptationBuffer = 0;
  private readonly ADAPTATION_PER_FAILURE = 0.02;
  private readonly MAX_ADAPTATION = 0.30;

  constructor(playerAge: number, parentOverrides?: Partial<AssistConfig>) {
    const base = AGE_PROFILES[playerAge] ?? AGE_PROFILES[7];
    this.config = { ...base, ...parentOverrides };
  }

  /** Hades-style: each failure subtly increases help. */
  recordFailure(): void {
    this.failureCount++;
    if (this.config.assistTier !== 'creator') {
      this.adaptationBuffer = Math.min(
        this.adaptationBuffer + this.ADAPTATION_PER_FAILURE,
        this.MAX_ADAPTATION
      );
    }
  }

  /** Decay adaptation on success — positive reinforcement loop. */
  recordSuccess(): void {
    this.adaptationBuffer = Math.max(this.adaptationBuffer - 0.01, 0);
  }

  /** Celeste-style: slower speed = more reaction time. */
  getGameSpeed(): number {
    const adapted = this.config.gameSpeed * (1 - this.adaptationBuffer * 0.5);
    return Math.round(adapted * 100) / 100;
  }

  /** Snap-to-grid with generous tolerance. Nintendo's invisible assist. */
  snapPosition(rawX: number, rawY: number): { x: number; y: number; snapped: boolean } {
    if (!this.config.snapToGrid) return { x: rawX, y: rawY, snapped: false };

    const nearestX = Math.round(rawX / this.config.gridSize) * this.config.gridSize;
    const nearestY = Math.round(rawY / this.config.gridSize) * this.config.gridSize;
    const dist = Math.sqrt((rawX - nearestX) ** 2 + (rawY - nearestY) ** 2);

    if (dist <= this.config.snapRadius) {
      return { x: nearestX, y: nearestY, snapped: true };
    }

    // Magnetic pull: stamp gravitates toward grid (feels like skill, is assist).
    if (this.config.magneticPull && dist <= this.config.snapRadius * 2) {
      const strength = 1 - dist / (this.config.snapRadius * 2);
      return {
        x: rawX + (nearestX - rawX) * strength * 0.3,
        y: rawY + (nearestY - rawY) * strength * 0.3,
        snapped: false,
      };
    }
    return { x: rawX, y: rawY, snapped: false };
  }

  isValidTouchTarget(w: number, h: number): boolean {
    return w >= this.config.touchTargetMin && h >= this.config.touchTargetMin;
  }

  getConfig(): Readonly<AssistConfig> { return Object.freeze({ ...this.config }); }
  getAdaptationLevel(): number { return this.adaptationBuffer; }
}

export { AssistManager, AGE_PROFILES, type AssistConfig };
```

### 10.2 Snap-to-Grid & Touch Optimization

For a 5-year-old, placing a stamp precisely is genuinely difficult. Their finger covers the target, their hand tremors, and their screen depth perception is still developing [^3^]. The snap-to-grid system is the most important invisible assist in the platform.

#### 10.2.1 Magnetic Snap with Satisfying Feedback

The snap algorithm operates in three zones. Within the snap radius (50% of cell size in Mellow Mode), the stamp snaps instantly with a micro-interaction: 10ms haptic vibration, a soft "pop" sound at 40% volume, and a brief sparkle particle. These multimodal cues are essential for pre-readers [^4^][^21^].

Between the snap radius and double it, magnetic pull activates — the stamp gravitates toward the nearest grid line at 30% of the distance per frame. The child experiences this as the platform being responsive, not assisted. Nintendo pioneered this with Mario Kart's Smart Steering, which corrects trajectory while the player feels fully in control [^12^].

Snap preview is critical for children. While dragging, a semi-transparent "ghost" stamp shows the landing position, shifting from white (no snap) to yellow (near) to green (locked). This addresses the working memory limitation: the child sees the outcome in real time instead of holding spatial relationships in memory [^2^].

Overlap resolution follows a child-first principle: never block, always adjust. If a stamp would overlap another, the system performs a spiral search outward from the desired position in concentric rings until it finds a free cell. If none is found, the stamp is placed anyway — overlapping stamps are visually distinct (the new stamp gets a subtle bounce). The philosophy is Kirby-inspired: there are no invalid states [^17^].

#### 10.2.2 Touch Target Sizing

A 5-year-old's fingertip is roughly 1.6–2.0 cm wide, compared to 1.0–1.5 cm for an adult [^27^]. At 64×64 pixels, the Mellow Mode target spans roughly 17 mm, providing adequate separation between elements. A minimum 12 pixels of dead space between interactive elements prevents the "fat finger" problem where a child taps between two buttons [^40^].

The TouchTargetValidator below can be run in browser DevTools during development to audit every interactive element against the current assist tier's minimum. It accounts for padding in the computed touch area and flags elements that meet WCAG AA (44×44) but fall below the child-optimized threshold.

```typescript
/**
 * TouchTargetValidator — DevTools audit for child-friendly touch targets.
 * Run validateTouchTargets({ minSize: 64 }) in console to audit the page.
 * Accounts for padding in computed touch area. Flags child vs adult standards.
 */

function validateTouchTargets(config: { minSize?: number } = {}) {
  const MIN_CHILD = config.minSize || 64;
  const MIN_WCAG = 44;
  const selectors = [
    'button', 'a[href]', 'input', 'select', 'textarea',
    '[role="button"]', '[role="link"]', '[onclick]',
    '.stamp', '.interactive', '.touch-target',
  ];

  const elements = document.querySelectorAll(selectors.join(', '));
  const results = { passed: 0, warned: 0, failed: 0, details: [] as any[] };

  elements.forEach(el => {
    const rect = el.getBoundingClientRect();
    const style = window.getComputedStyle(el);
    const w = rect.width
      + (parseFloat(style.paddingLeft) || 0)
      + (parseFloat(style.paddingRight) || 0);
    const h = rect.height
      + (parseFloat(style.paddingTop) || 0)
      + (parseFloat(style.paddingBottom) || 0);

    const info = { tag: el.tagName, cls: el.className?.slice(0, 30), w: Math.round(w), h: Math.round(h) };

    if (w >= MIN_CHILD && h >= MIN_CHILD) { results.passed++; }
    else if (w >= MIN_WCAG && h >= MIN_WCAG) { results.warned++; results.details.push({ ...info, note: 'WCAG OK, child suboptimal' }); }
    else { results.failed++; results.details.push({ ...info, note: 'Below WCAG minimum' }); }
  });

  console.log(`Touch Target Audit: ${results.passed} passed, ${results.warned} warned, ${results.failed} failed (min: ${MIN_CHILD}×${MIN_CHILD})`);
  if (results.details.length) console.table(results.details);
  return results;
}

export { validateTouchTargets };
```

#### 10.2.3 Implementation

The SnapToGridSystem implements magnetic pull, three-state snap preview, spiral overlap resolution, and multimodal snap feedback. It reads configuration dynamically from AssistManager so the grid can adapt mid-session.

```typescript
/**
 * SnapToGridSystem — Magnetic snap with child-friendly feedback.
 * Child-first decisions: magnetic pull (invisible assist), snap preview
 * (working memory aid), overlap resolution via spiral search (never blocks).
 */

interface Vec2 { x: number; y: number; }
interface PlacedStamp { id: string; position: Vec2; size: Vec2; }

class SnapToGridSystem {
  private gridSize: number;
  private snapRadius: number;
  private magneticPull: boolean;
  private overlapSearchRadius: number;
  private placedStamps = new Map<string, PlacedStamp>();

  constructor(config: {
    gridSize: number; snapRadius: number;
    magneticPull: boolean; overlapSearchRadius: number;
  }) {
    this.gridSize = config.gridSize;
    this.snapRadius = config.snapRadius;
    this.magneticPull = config.magneticPull;
    this.overlapSearchRadius = config.overlapSearchRadius;
  }

  /** Core snap: returns the position the stamp should occupy on release. */
  snap(rawX: number, rawY: number): { position: Vec2; snapped: boolean } {
    const nearestX = Math.round(rawX / this.gridSize) * this.gridSize;
    const nearestY = Math.round(rawY / this.gridSize) * this.gridSize;
    const dist = Math.sqrt((rawX - nearestX) ** 2 + (rawY - nearestY) ** 2);

    if (dist <= this.snapRadius) {
      this.playSnapFeedback(nearestX, nearestY);
      return { position: { x: nearestX, y: nearestY }, snapped: true };
    }

    if (this.magneticPull && dist <= this.snapRadius * 2) {
      const strength = 1 - dist / (this.snapRadius * 2);
      return {
        position: {
          x: rawX + (nearestX - rawX) * strength * 0.3,
          y: rawY + (nearestY - rawY) * strength * 0.3,
        },
        snapped: false,
      };
    }
    return { position: { x: rawX, y: rawY }, snapped: false };
  }

  /** Live preview while dragging. Ghost changes color: white→yellow→green. */
  getPreview(dragX: number, dragY: number): {
    ghostPos: Vec2; wouldSnap: boolean; indicator: 'none' | 'near' | 'locked';
  } {
    const nX = Math.round(dragX / this.gridSize) * this.gridSize;
    const nY = Math.round(dragY / this.gridSize) * this.gridSize;
    const d = Math.sqrt((dragX - nX) ** 2 + (dragY - nY) ** 2);

    if (d <= this.snapRadius * 0.3) {
      return { ghostPos: { x: nX, y: nY }, wouldSnap: true, indicator: 'locked' };
    }
    if (d <= this.snapRadius) {
      return { ghostPos: { x: nX, y: nY }, wouldSnap: true, indicator: 'near' };
    }
    return { ghostPos: { x: dragX, y: dragY }, wouldSnap: false, indicator: 'none' };
  }

  /** Spiral search for nearest free cell. Never blocks — places anyway if full. */
  resolveOverlap(
    wantX: number, wantY: number, size: Vec2, excludeId?: string
  ): { position: Vec2; adjusted: boolean } {
    if (!this.overlaps(wantX, wantY, size, excludeId)) {
      return { position: { x: wantX, y: wantY }, adjusted: false };
    }
    for (let r = 1; r <= this.overlapSearchRadius; r++) {
      for (let dx = -r; dx <= r; dx++) {
        for (let dy = -r; dy <= r; dy++) {
          if (Math.abs(dx) !== r && Math.abs(dy) !== r) continue;
          const tx = wantX + dx * this.gridSize;
          const ty = wantY + dy * this.gridSize;
          if (!this.overlaps(tx, ty, size, excludeId)) {
            return { position: { x: tx, y: ty }, adjusted: true };
          }
        }
      }
    }
    return { position: { x: wantX, y: wantY }, adjusted: false };
  }

  /** Full pipeline: snap then resolve overlap. */
  placeStamp(id: string, rawX: number, rawY: number, size: Vec2): PlacedStamp {
    const snapped = this.snap(rawX, rawY);
    const resolved = this.resolveOverlap(
      snapped.position.x, snapped.position.y, size, id
    );
    const placed: PlacedStamp = { id, position: resolved.position, size };
    this.placedStamps.set(id, placed);
    if (resolved.adjusted) FeedbackSystem.showAdjustAnimation(placed.position);
    return placed;
  }

  removeStamp(id: string): void { this.placedStamps.delete(id); }

  private overlaps(x: number, y: number, size: Vec2, exclude?: string): boolean {
    for (const [id, s] of this.placedStamps) {
      if (id === exclude) continue;
      if (x < s.position.x + s.size.x && x + size.x > s.position.x &&
          y < s.position.y + s.size.y && y + size.y > s.position.y) return true;
    }
    return false;
  }

  private playSnapFeedback(x: number, y: number): void {
    AudioManager.play('snap_pop', { volume: 0.4 });
    ParticleSystem.spawn('snap_sparkle', { x, y });
    if (typeof navigator !== 'undefined' && navigator.vibrate) navigator.vibrate(10);
  }
}

interface AudioManager {
  static play(sound: string, opts?: { volume?: number }): void;
}
interface ParticleSystem {
  static spawn(effect: string, pos: Vec2): void;
}
interface FeedbackSystem {
  static showAdjustAnimation(pos: Vec2): void;
}

export { SnapToGridSystem, type Vec2, type PlacedStamp };
```

### 10.3 Parent Dashboard & Safety Controls

Children's apps face a unique constraint: the primary user must not access settings or social features, but parents need frictionless access. The parent gate is the architectural solution.

#### 10.3.1 Parent Gate Architecture

The gate follows Apple's guidelines for Kids category apps: a challenge a young child cannot solve but a parent completes in under five seconds [^23^]. Math challenges use two-digit arithmetic (17 + 8, 24 − 9) — beyond a 5-year-old's number sense. Pattern challenges use abstract sequences (circle, square, circle, square — what comes next?) requiring explicit teaching most kindergarteners lack.

The gate implements progressive lockout: three consecutive failures trigger a 60-second cooldown. All answers are verified server-side when online; offline verification uses HMAC-signed tokens with 24-hour expiry. A gesture bypass — triple two-finger tap in the upper-left corner — is available for 10 minutes after a successful gate passage [^23^].

The gate is required for: settings, assist tier changes, social features, session timer adjustments, activity reports, purchases, and external links.

#### 10.3.2 Session Controls and Monitoring

Session length management addresses the 12–18 minute attention span directly [^1^]. The default timer is 15 minutes (adjustable 5–60). At the 10-minute mark, a friendly mascot appears with "almost break time!" — a gentle heads-up, not a countdown. At timeout, the game auto-pauses with "Great job! Let's take a break!" framing the pause as achievement. A mandatory break duration (default 5 minutes) is configurable.

Activity reports track creation time, play time, stamp placements, assist tier usage, struggle events, and games shared. Reports use icon-based timelines — no clinical graphs. The dashboard flags if a child has been in Mellow Mode for an extended period, suggesting a conversation about Growing Mode, but never auto-promotes without parent approval.

#### 10.3.3 Core Accessibility Features

Beyond the tiered assist system, a set of features are always active regardless of mode.

| Feature | Implementation | Rationale |
|---|---|---|
| High contrast | All stamps maintain 4.5:1 contrast ratio minimum | WCAG AA; benefits low vision [^19^] |
| Color-blind safe | Shapes + symbols accompany all color coding | 8% of males have color vision deficiency [^22^] |
| Audio feedback | Every tap and placement has unique sound | Pre-readers depend on audio [^4^] |
| Screen reader | All text narrated with friendly voice | Visually impaired accessibility |
| No flashing | Animations avoid 3+ Hz patterns | WCAG 2.3.1 seizure prevention |
| Motor accommodation | Single-touch only in Mellow Mode | Switch control compatible [^26^] |
| Adjustable text | Three sizes: Kid, Parent, Accessibility | Visual impairment accommodation |

Every stamp type has three encoding dimensions: color, shape (circle, square, triangle, star), and pattern (solid, striped, dotted, bordered). A fire stamp is red AND star-shaped AND has flame markings. A child with deuteranopia distinguishes it by shape and pattern alone [^22^]. Color-blind mode (parent-gated) adds symbol overlays to all color-coded elements.

Motor accommodation extends beyond sizing: the platform supports the Xbox Adaptive Controller and compatible switches [^26^], allowing children who cannot use touchscreens to navigate the palette (one switch advances, one confirms), place stamps (snap advances, confirm places), and undo (dedicated switch). Dwell selection — holding a finger for 1.5 seconds — is available for children with tremors [^42^].

#### 10.3.4 Implementation

```typescript
/**
 * ParentGateSystem — Math/pattern challenges with progressive lockout.
 * Security: server-side verification online; HMAC-signed tokens offline.
 * 3 failures → 60s lockout. Gesture bypass (triple 2-finger tap) for 10 min.
 */

type ChallengeType = 'math' | 'pattern';

interface ParentChallenge {
  type: ChallengeType;
  question: string;
  correctAnswer: string;
  narration: string;
}

interface GateSession {
  passedAt: number;
  method: 'challenge' | 'gesture';
  expiresAt: number;
}

class ParentGateSystem {
  private attemptsSinceSuccess = 0;
  private readonly MAX_ATTEMPTS = 3;
  private lockoutUntil = 0;
  private lastSession: GateSession | null = null;
  private readonly BYPASS_WINDOW = 10 * 60 * 1000;
  private readonly LOCKOUT_DURATION = 60 * 1000;

  generateMathChallenge(): ParentChallenge {
    const a = Math.floor(Math.random() * 90) + 10;
    const b = Math.floor(Math.random() * 9) + 1;
    const isAdd = Math.random() > 0.5;
    const answer = isAdd ? a + b : a - b;
    return {
      type: 'math',
      question: `${a} ${isAdd ? '+' : '−'} ${b} = ?`,
      correctAnswer: answer.toString(),
      narration: `What is ${a} ${isAdd ? 'plus' : 'minus'} ${b}?`,
    };
  }

  generatePatternChallenge(): ParentChallenge {
    const patterns = [
      { seq: ['◯','◇','◯','◇','◯','?'], ans: '◇' },
      { seq: ['▲','▼','▲','▼','▲','?'], ans: '▼' },
      { seq: ['1','2','3','1','2','?'], ans: '3' },
    ];
    const p = patterns[Math.floor(Math.random() * patterns.length)];
    return {
      type: 'pattern',
      question: `Complete: ${p.seq.join(' ')}`,
      correctAnswer: p.ans,
      narration: 'What comes next in the pattern?',
    };
  }

  async promptAndVerify(): Promise<boolean> {
    if (Date.now() < this.lockoutUntil) return false;
    const challenge = Math.random() > 0.5
      ? this.generateMathChallenge()
      : this.generatePatternChallenge();
    const response = await UIParentGate.present(challenge);
    const correct = response.trim() === challenge.correctAnswer;
    if (correct) {
      this.attemptsSinceSuccess = 0;
      this.lastSession = { passedAt: Date.now(), method: 'challenge', expiresAt: Date.now() + this.BYPASS_WINDOW };
      return true;
    }
    this.attemptsSinceSuccess++;
    if (this.attemptsSinceSuccess >= this.MAX_ATTEMPTS) {
      this.lockoutUntil = Date.now() + this.LOCKOUT_DURATION;
      this.attemptsSinceSuccess = 0;
    }
    return false;
  }

  attemptGestureBypass(): boolean {
    if (this.lastSession && Date.now() < this.lastSession.expiresAt) {
      this.lastSession = { passedAt: Date.now(), method: 'gesture', expiresAt: Date.now() + this.BYPASS_WINDOW };
      return true;
    }
    return false;
  }

  isAuthenticated(): boolean {
    return !!this.lastSession && Date.now() < this.lastSession.expiresAt;
  }
}

interface UIParentGate {
  static present(challenge: ParentChallenge): Promise<string>;
}

export { ParentGateSystem, type ParentChallenge };
```

```typescript
/**
 * ParentDashboard — Session controls, activity monitoring, assist tracking.
 * All methods require ParentGateSystem.isAuthenticated().
 */

interface SessionSettings {
  maxSessionMinutes: number;
  breakReminderMinutes: number;
  mandatoryBreakMinutes: number;
}

interface DailyActivity {
  date: string;
  creationMinutes: number;
  playMinutes: number;
  stampsPlaced: number;
  stampsRemoved: number;
  struggleEvents: number;
  gamesCreated: number;
  gamesPlayed: number;
  assistTierUsed: 'mellow' | 'growing' | 'creator';
}

interface ChildProfile {
  childId: string;
  displayName: string;
  currentAssistTier: 'mellow' | 'growing' | 'creator';
  sessionSettings: SessionSettings;
  dailyActivity: DailyActivity[];
}

class ParentDashboard {
  private profile: ChildProfile;
  private gate: ParentGateSystem;
  private sessionTimer: ReturnType<typeof setTimeout> | null = null;
  private reminderTimer: ReturnType<typeof setTimeout> | null = null;
  private sessionStart = 0;

  constructor(profile: ChildProfile, gate: ParentGateSystem) {
    this.profile = profile;
    this.gate = gate;
  }

  async updateSettings(settings: Partial<SessionSettings>): Promise<void> {
    if (!this.gate.isAuthenticated()) throw new Error('Parent gate required');
    this.profile.sessionSettings = { ...this.profile.sessionSettings, ...settings };
    this.resetTimers();
    await ProfileStore.save(this.profile);
  }

  async overrideAssistTier(tier: 'mellow' | 'growing' | 'creator'): Promise<void> {
    if (!this.gate.isAuthenticated()) throw new Error('Parent gate required');
    this.profile.currentAssistTier = tier;
    await ProfileStore.save(this.profile);
  }

  startSession(): void {
    this.sessionStart = Date.now();
    const { maxSessionMinutes, breakReminderMinutes } = this.profile.sessionSettings;
    if (breakReminderMinutes > 0 && breakReminderMinutes < maxSessionMinutes) {
      this.reminderTimer = setTimeout(() => SessionUI.showBreakReminder(), breakReminderMinutes * 60 * 1000);
    }
    this.sessionTimer = setTimeout(() => this.endSession(true), maxSessionMinutes * 60 * 1000);
  }

  endSession(auto = false): void {
    if (this.sessionTimer) clearTimeout(this.sessionTimer);
    if (this.reminderTimer) clearTimeout(this.reminderTimer);
    if (auto) {
      SessionUI.showBreakCelebration(this.profile.sessionSettings.mandatoryBreakMinutes);
      SessionTracker.pauseAll();
    }
    this.logActivity({ playMinutes: Math.floor((Date.now() - this.sessionStart) / 60000) });
  }

  async weeklyReport(): Promise<{
    totalCreationMin: number; totalPlayMin: number; totalStamps: number;
    struggleEvents: number; gamesCreated: number; recommendation: string;
  }> {
    if (!this.gate.isAuthenticated()) throw new Error('Parent gate required');
    const week = this.profile.dailyActivity.slice(-7);
    const t = week.reduce((a, d) => ({
      c: a.c + d.creationMinutes, p: a.p + d.playMinutes,
      s: a.s + d.stampsPlaced, str: a.str + d.struggleEvents, g: a.g + d.gamesCreated,
    }), { c: 0, p: 0, s: 0, str: 0, g: 0 });

    let rec = 'Keep encouraging creativity!';
    if (t.str > 10) rec = 'Several challenges detected. Consider keeping Mellow Mode on.';
    else if (t.g > 3 && this.profile.currentAssistTier === 'mellow')
      rec = 'Creating frequently! Growing Mode may be a good next step.';

    return { totalCreationMin: t.c, totalPlayMin: t.p, totalStamps: t.s, struggleEvents: t.str, gamesCreated: t.g, recommendation: rec };
  }

  logActivity(partial: Partial<DailyActivity>): void {
    const today = new Date().toISOString().split('T')[0];
    let day = this.profile.dailyActivity.find(d => d.date === today);
    if (!day) {
      day = { date: today, creationMinutes: 0, playMinutes: 0, stampsPlaced: 0, stampsRemoved: 0, struggleEvents: 0, gamesCreated: 0, gamesPlayed: 0, assistTierUsed: this.profile.currentAssistTier };
      this.profile.dailyActivity.push(day);
    }
    if (partial.creationMinutes) day.creationMinutes += partial.creationMinutes;
    if (partial.playMinutes) day.playMinutes += partial.playMinutes;
    if (partial.stampsPlaced) day.stampsPlaced += partial.stampsPlaced;
    if (partial.stampsRemoved) day.stampsRemoved += partial.stampsRemoved;
    if (partial.struggleEvents) day.struggleEvents += partial.struggleEvents;
    if (partial.gamesCreated) day.gamesCreated += partial.gamesCreated;
    if (this.profile.dailyActivity.length > 90) this.profile.dailyActivity = this.profile.dailyActivity.slice(-90);
  }

  private resetTimers(): void {
    if (this.sessionTimer) clearTimeout(this.sessionTimer);
    if (this.reminderTimer) clearTimeout(this.reminderTimer);
    this.startSession();
  }
}

interface SessionUI {
  static showBreakReminder(): void;
  static showBreakCelebration(mandatoryBreakMin: number): void;
}
interface SessionTracker { static pauseAll(): void; }
interface ProfileStore { static save(profile: ChildProfile): Promise<void>; }

export { ParentDashboard, type ChildProfile, type DailyActivity, type SessionSettings };
```

The parent dashboard and assist system together form what the research identifies as an "emotional safety architecture" — preventing creative frustration (accidental deletion, impossible configurations), competitive pressure (no leaderboards, only personal progress), and cognitive overload (visual guides, snap-to-grid, auto-correct) [^5^][^20^]. The platform never tells a child an assist is active, never presents an "easy mode" dialog. It observes, adapts, and celebrates — following HAL Laboratory's principle that a game for young children should feel like play, not a test [^17^].
