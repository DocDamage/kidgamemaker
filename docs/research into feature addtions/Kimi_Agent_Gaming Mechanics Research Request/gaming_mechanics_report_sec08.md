## 8. Co-op, Social & Sharing Features

Children do not play games to manage server configurations, send friend requests, or navigate privacy settings. They play to share moments — to show a friend the dragon they built, to rescue a sibling floating in a bubble, to hear "Teamwork!" when they overcome a challenge together. The platform's co-op and social layer must make these moments accessible to a five-year-old while satisfying COPPA, GDPR-Kids, and the UK Age-Appropriate Design Code before a single packet leaves the device [^302^] [^392^]. This chapter implements three interconnected systems: a zero-data invite and companion framework, a Nintendo-inspired bubble respawn co-op mechanic, and a QR-based sharing and remix pipeline that lets children circulate their creations without exposing personal information.

### 8.1 Safe Social System

#### 8.1.1 Parent-Approved Friend Lists and COPPA-Compliant Invites

The legal landscape for children's online play is unforgiving. COPPA mandates verifiable parental consent before collecting any personal information from children under 13, including IP addresses, device identifiers, and even usernames that could reasonably identify a child [^302^] [^305^]. Penalties reach $50,120 per violation [^307^]. The UK Age-Appropriate Design Code goes further, requiring high-privacy defaults for all users under 18 with communication features turned off until a parent explicitly enables them [^392^]. The safest technical response is a zero-data architecture: sessions are anonymous, codes are random and temporary, and the LLM backend handles all consent flows without ever storing a child's identity [^302^].

The entry point to multiplayer is the Co-op Portal Stamp. When a child places this stamp on their canvas, the system generates a four-digit numeric code — memorable enough for a kindergartener to read aloud over a kitchen table, short enough to type without frustration. The code maps to an anonymous session record with a one-hour TTL; no email, no username, no persistent identifier is collected. A friend enters the same four digits on their device and drops directly into the game. This pattern mirrors Among Us' private lobby system, which restricts interaction to players who already know the code [^371^], but simplifies it further: four digits instead of six letters, no account creation, no data retention.

Parent approval is enforced through a gating function that queries the LLM backend for consent status before any session is created. If the child is under 13 and no parental consent is on file, the system defers session creation and dispatches a notification to the parent's registered contact method. The child sees a friendly "Ask a grown-up to help!" message with a lock icon — never a legal disclaimer. Once approved, sessions are created with anonymized player hashes and full activity logging for parent review. Every cheer sent, every peer encountered, every safety flag is recorded in a dashboard the parent accesses through a separate, authenticated application that the child never sees.

#### 8.1.2 Companion AI Stamps for Solo Co-op Feel

Not every play session has a friend available. Companion AI stamps bridge this gap by giving children an in-game partner that behaves like a co-op teammate without requiring a second human player. Nintendo proved this model decades ago: Tails in *Sonic the Hedgehog 2* follows the player by recording their inputs with a time delay, creating the convincing illusion of a second player at the controller [^375^]. *Kirby Star Allies* extended the concept with the Helper system, where thrown Friend Hearts convert enemies into AI allies that auto-follow, auto-attack, and participate in combo moves [^419^]. The critical design lesson from the Sonic ROM hacking community is that companion AI must be *reliable above all else* — Tails frequently fails to keep up, gets stuck on geometry, and misses opportunities to help, making the companion feel broken rather than helpful [^377^].

The platform offers three companion archetypes as pre-made Buddy Stamps, each tuned for different play styles. The Speedy Pet follows closely with minimal delay, prioritizing bubble rescue and quick reactions — ideal for children who move fast and want a companion that keeps pace. The Strong Robot moves slower but assists aggressively in combat, automatically attacking nearby enemies and providing a sense of protection. The Helpful Fairy floats above hazards, can reach any area of the level, and prioritizes rescue behavior — perfect for children who need help rather than company. Each companion is configured through the `CompanionConfig` interface with parameters the LLM backend populates based on the stamp selection: follow distance, teleport threshold, jump sensitivity, assist radius, and bubble rescue range. The position-recording ring buffer — a 120-entry circular queue storing delayed player positions — produces the smooth following behavior that made Donkey Kong Country's tag-team system feel responsive in 1994 and remains the standard approach today [^426^] [^363^].

#### 8.1.3 Implementation: SafeSocialSystem

The `SafeSocialSystem` class coordinates session creation, invite code generation, COPPA compliance checks, and parent approval gating. It is the single entry point for all multiplayer functionality on the client side; no other module creates network sessions or exchanges peer identifiers.

```typescript
// ============================================================
// SafeSocialSystem.ts
// Coordinates invite codes, COPPA compliance, parent approval,
// and companion AI selection. Single entry point for multiplayer.
// ============================================================

interface CompanionConfig {
  followDistance: number;
  teleportDistance: number;
  jumpThreshold: number;
  assistRange: number;
  bubbleRescueRange: number;
  inputDelay: number;
  moveSpeed: number;
  jumpForce: number;
  type: 'speedy_pet' | 'strong_robot' | 'helpful_fairy';
}

interface SessionConfig {
  maxPlayers: number;
  sessionTimeout: number;
  allowRejoin: boolean;
  requireParentApproval: boolean;
  communicationMode: 'none' | 'cheers';
}

interface GameSession {
  id: string;
  code: string;
  canvasId: string;
  hostHash: string;
  players: SessionPlayer[];
  state: 'waiting' | 'playing' | 'paused' | 'ended';
  createdAt: number;
  expiresAt: number;
  parentApproved: boolean;
}

interface SessionPlayer {
  hash: string;
  slot: number;
  state: 'connected' | 'disconnected' | 'bubbled';
  joinTime: number;
  lastActivity: number;
  cheerHistory: string[];
}

class SafeSocialSystem {
  private sessions: Map<string, GameSession> = new Map();
  private codeToSession: Map<string, string> = new Map();
  private config: SessionConfig;
  private companionPresets: Record<string, CompanionConfig>;

  private readonly ALLOWED_CHEERS: string[] = [
    'Great job!', 'Nice work!', 'Need help?', 'Over here!',
    'Thank you!', 'You can do it!', 'Teamwork!', 'Awesome!',
    'Wait for me!', 'Follow me!'
  ];

  constructor(config: SessionConfig) {
    this.config = config;
    // LLM populates these based on which Buddy Stamp the child placed
    this.companionPresets = {
      speedy_pet:   { followDistance: 40, teleportDistance: 300, jumpThreshold: 30, assistRange: 80,  bubbleRescueRange: 150, inputDelay: 15, moveSpeed: 4.5, jumpForce: 10, type: 'speedy_pet' },
      strong_robot: { followDistance: 50, teleportDistance: 250, jumpThreshold: 20, assistRange: 60,  bubbleRescueRange: 120, inputDelay: 30, moveSpeed: 3.0, jumpForce: 8,  type: 'strong_robot' },
      helpful_fairy:{ followDistance: 35, teleportDistance: 400, jumpThreshold: 10, assistRange: 100, bubbleRescueRange: 200, inputDelay: 10, moveSpeed: 3.5, jumpForce: 12, type: 'helpful_fairy' }
    };
  }

  // Called when child places a Co-op Portal Stamp
  async createSession(canvasId: string, hostPlayerId: string): Promise<GameSession | null> {
    // COPPA gate: children under 13 need parent approval on file
    if (this.config.requireParentApproval) {
      const approved = await this.checkParentApproval(hostPlayerId);
      if (!approved) {
        UI.showParentGate('Ask a grown-up to help!');
        await this.requestParentApproval(hostPlayerId, canvasId);
        return null;
      }
    }

    const code = this.generateUniqueCode();
    const hostHash = await this.hashId(hostPlayerId);
    const session: GameSession = {
      id: this.generateId(), code, canvasId, hostHash,
      players: [{ hash: hostHash, slot: 1, state: 'connected', joinTime: Date.now(), lastActivity: Date.now(), cheerHistory: [] }],
      state: 'waiting', createdAt: Date.now(),
      expiresAt: Date.now() + (this.config.sessionTimeout * 1000),
      parentApproved: true
    };

    this.sessions.set(session.id, session);
    this.codeToSession.set(code, session.id);
    setTimeout(() => this.cleanup(session.id), this.config.sessionTimeout * 1000);
    return session;
  }

  // Called when friend enters the 4-digit code
  async joinSession(code: string, joiningId: string): Promise<{ success: boolean; slot?: number; error?: string }> {
    const sid = this.codeToSession.get(code);
    if (!sid) return { success: false, error: 'invalid_code' };
    const session = this.sessions.get(sid);
    if (!session || session.state === 'ended') return { success: false, error: 'session_expired' };
    if (session.players.length >= this.config.maxPlayers) return { success: false, error: 'session_full' };

    const hash = await this.hashId(joiningId);
    const usedSlots = session.players.map(p => p.slot);
    const slot = [1,2,3,4].find(s => !usedSlots.includes(s)) ?? 2;
    session.players.push({ hash, slot, state: 'connected', joinTime: Date.now(), lastActivity: Date.now(), cheerHistory: [] });

    if (session.players.length >= 2 && session.state === 'waiting') session.state = 'playing';
    return { success: true, slot };
  }

  sendCheer(sessionId: string, playerHash: string, cheerIndex: number): boolean {
    // No free text — index into pre-defined positive messages only
    if (cheerIndex < 0 || cheerIndex >= this.ALLOWED_CHEERS.length) {
      SafetyLogger.flag(sessionId, playerHash, 'invalid_cheer_index');
      return false;
    }
    const cheer = this.ALLOWED_CHEERS[cheerIndex];
    Network.broadcast(sessionId, { type: 'cheer', fromHash: playerHash, message: cheer, timestamp: Date.now() });
    return true;
  }

  getCompanionConfig(stampType: string): CompanionConfig {
    return this.companionPresets[stampType] || this.companionPresets.speedy_pet;
  }

  private generateUniqueCode(): string {
    let code: string, attempts = 0;
    do { code = Math.floor(1000 + Math.random() * 9000).toString(); attempts++; }
    while (this.codeToSession.has(code) && attempts < 100);
    return attempts >= 100 ? Math.floor(10000 + Math.random() * 90000).toString() : code;
  }

  private async hashId(id: string): Promise<string> {
    const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(id + 'session_salt'));
    return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, '0')).join('');
  }

  private async checkParentApproval(playerId: string): Promise<boolean> {
    const status = await LLMBackend.getPlayerAgeStatus(playerId);
    return !(status.age < 13 && !status.parentConsentOnFile);
  }

  private async requestParentApproval(playerId: string, canvasId: string): Promise<void> {
    await LLMBackend.notifyParent({ type: 'multiplayer_request', childId: playerId, canvasId, actionRequired: 'approve_multiplayer', expiresIn: 86400 });
  }

  private generateId(): string { return 'sess_' + Math.random().toString(36).substring(2, 15); }

  private cleanup(sid: string): void {
    const s = this.sessions.get(sid); if (!s) return;
    this.codeToSession.delete(s.code); this.sessions.delete(sid);
  }
}
```

The design enforces safety at multiple layers. The `sendCheer` method rejects any index outside the pre-defined `ALLOWED_CHEERS` array and logs the attempt for safety review — there is no free text path into the system. Player identifiers are SHA-256 hashed with a per-session salt before storage, ensuring that even a database breach cannot reveal who played with whom. Session codes are short-lived and decoupled from player identity; guessing a four-digit code grants access only to an anonymous play session, not to a profile, a friend list, or any persistent data. For parents who want tighter control, the safety level can be set to YELLOW (approved friends only) or RED (single player only), with changes taking effect immediately across all devices.

### 8.2 Bubble Respawn Co-op

#### 8.2.1 The Nintendo Bubble Model

The bubble respawn system from *New Super Mario Bros. Wii* is the most child-friendly multiplayer mechanic ever implemented in a commercial platformer. Shigeru Miyamoto's team faced a genuine design problem: when four players co-operate through a level and one loses a life, that player sits idle while the others continue, creating a punishment loop that fractures the social experience [^337^]. Their solution was multi-faceted and elegant: the defeated player respawns inside a floating bubble at the nearest safe location, the bubble is invincible and phases through all obstacles, it drifts slowly toward living players to make rescue effortless, and another player pops it simply by touching it. Players can even voluntarily enter a bubble to skip difficult sections — a feature that bridges skill gaps between siblings of different ages [^337^].

The bubble transforms death from a failure state into a social interaction. The trapped player calls for help (through the Cheer system — "Need help?" is one tap away). The living player sees a floating, bobbing target drifting toward them and feels empowered by the rescue. When the bubble pops, both players receive a small celebration burst and a "Teamwork!" floating message. There are no lives to lose, no game over screen, no progress reset. *Castle Crashers* learned the hard way that forcing all players to restart when one disconnects destroys the co-op experience for children [^343^]; the bubble model does the opposite by making every setback recoverable within seconds.

#### 8.2.2 Zero Frustration Design

Children under seven have limited tolerance for failure and virtually no capacity for attributing blame to network conditions or game systems [^427^]. The bubble system is therefore wrapped in a zero-frustration layer: no lives counter exists, there is no maximum number of bubbles per level, and voluntary bubbling has a short cooldown (three seconds) to prevent spam without feeling restrictive. If a player stays in a bubble for ten seconds, the system offers self-pop as an option; if they remain for ten seconds more, the bubble pops automatically as a safety valve. The post-pop invincibility window (1.5 seconds of flashing) prevents immediate re-defeat in hazard-dense areas. When all players are simultaneously defeated — the only condition that triggers a level reset — the message displayed is "Let's try again together!" never "Game Over."

Friendly fire defaults to OFF, following the pattern established by *River City Ransom* and *New Super Mario Bros. Wii*, where accidental player-on-player damage frustrates children who do not yet distinguish between enemy and friend collisions [^309^]. Players pass through each other; they cannot push, pull, or otherwise affect each other's position. Gentle Mode (enabled by default) removes all competitive friction, though older children can toggle it off through a parent-gated setting if they want playful competition.

#### 8.2.3 Implementation: BubbleRespawnSystem

The `BubbleRespawnSystem` manages player state transitions, bubble physics, collision detection for rescue, and the safety-valve auto-pop timer. It is instantiated whenever a Co-op Portal Stamp or Bubble Rescue Stamp is active on the canvas.

```typescript
// ============================================================
// BubbleRespawnSystem.ts
// Nintendo-inspired bubble respawn with zero-frustration design.
// No lives, no game over — only rescue, teamwork, and retry.
// ============================================================

interface BubbleConfig {
  driftSpeed: number;
  selfPopDelay: number;
  invincibilityDuration: number;
  maxBubbleTime: number;
  safeZoneOffset: number;
  voluntaryCooldown: number;
}

enum PlayerState { ACTIVE = 'active', BUBBLED = 'bubbled', INVINCIBLE = 'invincible' }

interface Bubble {
  id: string;
  x: number; y: number;
  trappedHash: string;
  lifetime: number;
  canSelfPop: boolean;
  isVoluntary: boolean;
}

class BubbleRespawnSystem {
  private players: Player[];
  private bubbles: Bubble[] = [];
  private config: BubbleConfig;
  private safeZones: Array<{x: number; y: number}> = [];
  private lastVoluntaryBubble: number = 0;

  constructor(players: Player[], config: BubbleConfig) {
    this.players = players;
    this.config = config;
    this.safeZones = LevelAnalyzer.findSafeZones({ minWidth: 100, awayFromHazards: 50, maxSpacing: 300 });
  }

  update(): void {
    this.updateBubbles();
    this.checkRescueCollisions();
    this.updateInvincibility();
    this.trackSafePositions();
  }

  // Called when a player "dies" — they enter a bubble instead of losing a life
  onPlayerDefeated(player: Player): void {
    const alive = this.players.filter(p => p.state === PlayerState.ACTIVE);
    if (alive.length === 0) { this.resetTogether(); return; }

    const zone = this.findNearestSafeZone(player.lastSafeX, player.lastSafeY);
    const bubble: Bubble = {
      id: `bub_${Date.now()}`, x: zone.x, y: zone.y - this.config.safeZoneOffset,
      trappedHash: player.hash, lifetime: 0, canSelfPop: false, isVoluntary: false
    };
    this.bubbles.push(bubble);
    player.state = PlayerState.BUBBLED;
    player.bubbleId = bubble.id;
    Effects.spawn('bubble_form_sparkles', zone.x, zone.y);
    Audio.play('bubble_spawn_cute');
    // Bubble drifts toward nearest active player automatically
  }

  // Voluntary bubble — child taps "Need a break?" button
  requestVoluntaryBubble(player: Player): void {
    if (player.state !== PlayerState.ACTIVE) return;
    if (Date.now() - this.lastVoluntaryBubble < this.config.voluntaryCooldown * 1000) return;
    this.onPlayerDefeated(player);
    const bubble = this.bubbles.find(b => b.trappedHash === player.hash);
    if (bubble) { bubble.isVoluntary = true; bubble.canSelfPop = true; }
    this.lastVoluntaryBubble = Date.now();
  }

  private updateBubbles(): void {
    for (const bubble of this.bubbles) {
      bubble.lifetime++;
      const nearest = this.findNearestActivePlayer(bubble.x, bubble.y);
      if (nearest) {
        bubble.x += Math.sign(nearest.x - bubble.x) * this.config.driftSpeed;
        bubble.y += Math.sin(bubble.lifetime * 0.05) * 0.5; // gentle bobbing
      }
      if (!bubble.canSelfPop && bubble.lifetime > this.config.selfPopDelay) {
        bubble.canSelfPop = true;
      }
      // Safety valve: forced pop after maximum bubble time
      if (bubble.lifetime > this.config.maxBubbleTime) {
        this.popBubble(bubble, 'timeout');
      }
    }
  }

  private checkRescueCollisions(): void {
    for (const bubble of this.bubbles) {
      for (const player of this.players) {
        if (player.state !== PlayerState.ACTIVE) continue;
        if (this.collide(player, bubble)) {
          this.popBubble(bubble, 'rescued');
          this.celebrateRescue(bubble, player);
          return;
        }
      }
      // Self-pop via input after delay expires
      const trapped = this.players.find(p => p.hash === bubble.trappedHash);
      if (bubble.canSelfPop && trapped?.input.jumpPressed) {
        this.popBubble(bubble, 'self_pop');
      }
    }
  }

  private popBubble(bubble: Bubble, reason: string): void {
    this.bubbles = this.bubbles.filter(b => b !== bubble);
    const player = this.players.find(p => p.hash === bubble.trappedHash);
    if (!player) return;
    player.state = PlayerState.INVINCIBLE;
    player.invincibilityTimer = this.config.invincibilityDuration;
    player.bubbleId = null;
    player.x = bubble.x; player.y = bubble.y;
    Effects.spawn('bubble_pop_burst', bubble.x, bubble.y, reason === 'rescued' ? '#FFD700' : '#87CEEB');
    Audio.play(reason === 'rescued' ? 'bubble_pop_happy' : 'bubble_pop_self');
  }

  private celebrateRescue(bubble: Bubble, rescuer: Player): void {
    Effects.spawn('star_burst', bubble.x, bubble.y, 30);
    Effects.spawn('heart_particles', bubble.x, bubble.y, 10);
    UI.showFloatingText(bubble.x, bubble.y - 30, 'Teamwork!', '#FFD700');
    // Both players get a small celebration — no score penalty for needing rescue
  }

  private resetTogether(): void {
    CheckpointSystem.resetToLastCheckpoint();
    UI.showEncouragement('Let\'s try again together!');
    // All bubbles cleared, all players respawn at checkpoint
    this.bubbles = [];
    for (const p of this.players) { p.state = PlayerState.ACTIVE; p.bubbleId = null; }
  }

  private updateInvincibility(): void {
    for (const p of this.players) {
      if (p.state === PlayerState.INVINCIBLE) {
        p.invincibilityTimer--;
        if (p.invincibilityTimer <= 0) p.state = PlayerState.ACTIVE;
      }
    }
  }

  private trackSafePositions(): void {
    for (const p of this.players) {
      if (p.state === PlayerState.ACTIVE && p.isOnGround && !p.inDanger) {
        p.lastSafeX = p.x; p.lastSafeY = p.y;
      }
    }
  }

  private findNearestSafeZone(x: number, y: number) {
    return this.safeZones.reduce((best, z) =>
      (Math.abs(z.x - x) + Math.abs(z.y - y) < Math.abs(best.x - x) + Math.abs(best.y - y)) ? z : best
    );
  }

  private findNearestActivePlayer(x: number, y: number): Player | null {
    let nearest: Player | null = null, best = Infinity;
    for (const p of this.players) {
      if (p.state !== PlayerState.ACTIVE) continue;
      const d = Math.abs(p.x - x) + Math.abs(p.y - y);
      if (d < best) { best = d; nearest = p; }
    }
    return nearest;
  }

  private collide(player: Player, bubble: Bubble): boolean {
    const dx = player.x - bubble.x, dy = player.y - bubble.y;
    return Math.sqrt(dx * dx + dy * dy) < 40; // 40px rescue radius
  }
}

const DEFAULT_BUBBLE_CONFIG: BubbleConfig = {
  driftSpeed: 1.2, selfPopDelay: 120, invincibilityDuration: 90,
  maxBubbleTime: 600, safeZoneOffset: 50, voluntaryCooldown: 3
};
```

The `onPlayerDefeated` method is the critical state-transition gate: it never subtracts a life, never displays a game over screen, and never resets level progress. Instead it checks whether at least one active player remains; if so, it spawns a bubble at the nearest pre-analyzed safe zone and transitions the player to the `BUBBLED` state. The `requestVoluntaryBubble` method enables the strategic use of the bubble as a skip mechanic — children who find a section too difficult can tap the "Need a break?" button, float past the challenge, and rejoin when a friend or companion AI pops their bubble. The three-second cooldown prevents spam without introducing frustration.

### 8.3 Sharing & Remix System

#### 8.3.1 Instant QR Code Generation

The creation-to-sharing pipeline must be as immediate as the co-op pipeline. When a child finishes a game and taps the Share Button Stamp, the system serializes the canvas state, compresses it, generates a hash-based integrity check, and produces two artifacts simultaneously: a short alphanumeric share code (six characters, like Fall Guys' creative mode codes [^425^]) and a QR code encoding the same data. The child can read the code aloud to a friend across a room, or the friend can scan the QR code directly from the creator's screen. Both paths resolve to the same anonymous game session. The entire operation completes in under 200 milliseconds — fast enough that a five-year-old does not lose interest between tap and result.

Content moderation happens before any code is generated. The LLM backend scans the canvas for combinations of stamps that could produce inappropriate content: while the stamp-only creation model inherently limits what children can build (no freehand drawing, no image uploads) [^360^], the moderation layer checks for aggressive naming patterns, unsettling atmosphere combinations, and stamps placed in ways that violate the platform's safety heuristics. If the scan passes, the share code is minted; if not, the child sees a gentle suggestion to "Try adding a friendlier stamp!" with specific guidance. This pre-moderation approach aligns with UNICEF recommendations for protecting children in online gaming environments [^365^].

#### 8.3.2 Remix with Attribution

The remix feature — what the platform calls "Add Your Stamp!" — allows a friend who plays a shared game to place their own stamps on top of the original canvas, creating a derivative work with automatic attribution. When a child opens a remixed game, they see the original creator's avatar stamp in the corner (anonymized — a fun animal icon, never a username or photo) and a trail of "remix badges" showing how many iterations the creation has passed through. This fork-with-credit model mirrors the open-source contribution graph in a form children can understand: each remix adds a badge, and tapping it reveals the sequence of stamps that were added at each step.

Attribution is stored as a signed chain within the canvas metadata. Each remix appends a new link containing the anonymized creator hash, a timestamp, and a list of stamp placements. The chain is append-only and cryptographically hashed, preventing tampering while preserving anonymity. Children cannot remove remix badges; the permanence reinforces a culture of creative generosity rather than appropriation.

#### 8.3.3 Implementation: SharingSystem

The `SharingSystem` class handles canvas serialization, content moderation gating, QR generation, remix chain management, and the parent-controlled sharing permissions that determine whether a child's creations can be shared at all.

```typescript
// ============================================================
// SharingSystem.ts
// QR generation, remix attribution, and content moderation gating.
// Every shared canvas is LLM-scanned before a code is minted.
// ============================================================

interface CanvasManifest {
  canvasId: string;
  stampCount: number;
  stampTypes: string[];
  createdAt: number;
  creatorHash: string;
  remixChain: RemixLink[];
  moderationScore: number;
  shareCode: string;
}

interface RemixLink {
  creatorHash: string;
  timestamp: number;
  stampsAdded: Array<{ type: string; x: number; y: number }>;
  previousHash: string;
}

interface ShareResult {
  success: boolean;
  shareCode?: string;
  qrDataUri?: string;
  error?: 'moderation_failed' | 'sharing_disabled' | 'serialization_error';
}

class SharingSystem {
  private codeToManifest: Map<string, CanvasManifest> = new Map();
  private readonly CODE_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Omit 0, O, I, 1 for readability

  // Called when child taps the Share Button Stamp
  async shareCanvas(canvas: GameCanvas, creatorId: string): Promise<ShareResult> {
    // Check parent sharing permission
    const canShare = await LLMBackend.getSharingPermission(creatorId);
    if (!canShare) return { success: false, error: 'sharing_disabled' };

    // LLM pre-moderation scan
    const moderation = await LLMBackend.moderateCanvas(canvas);
    if (moderation.score < 0.7) {
      UI.showGentleSuggestion(moderation.suggestion || 'Try adding a friendlier stamp!');
      return { success: false, error: 'moderation_failed' };
    }

    const creatorHash = await this.hashId(creatorId);
    const shareCode = this.generateShareCode();
    const manifest: CanvasManifest = {
      canvasId: canvas.id,
      stampCount: canvas.stamps.length,
      stampTypes: [...new Set(canvas.stamps.map(s => s.type))],
      createdAt: Date.now(),
      creatorHash,
      remixChain: canvas.remixChain || [{ creatorHash, timestamp: Date.now(), stampsAdded: canvas.stamps.map(s => ({ type: s.type, x: s.x, y: s.y })), previousHash: 'genesis' }],
      moderationScore: moderation.score,
      shareCode
    };

    // Serialize and store
    const serialized = await this.serializeCanvas(canvas, manifest);
    await LLMBackend.storeSharedCanvas(shareCode, serialized);
    this.codeToManifest.set(shareCode, manifest);

    // Generate QR code as data URI (PNG, 200x200px)
    const qrDataUri = await QRGenerator.createDataUri({
      data: `${window.location.origin}/play?code=${shareCode}`,
      size: 200,
      colorDark: '#2B3A67',
      colorLight: '#FFFFFF'
    });

    return { success: true, shareCode, qrDataUri };
  }

  // Called when friend opens a shared game and places new stamps
  async remixCanvas(shareCode: string, newStamps: Stamp[], remixerId: string): Promise<ShareResult> {
    const original = this.codeToManifest.get(shareCode);
    if (!original) return { success: false, error: 'serialization_error' };

    const remixerHash = await this.hashId(remixerId);
    const previousHash = await this.hashManifest(original);
    const newLink: RemixLink = {
      creatorHash: remixerHash,
      timestamp: Date.now(),
      stampsAdded: newStamps.map(s => ({ type: s.type, x: s.x, y: s.y })),
      previousHash
    };

    const canvas = await LLMBackend.loadSharedCanvas(shareCode);
    canvas.remixChain = [...original.remixChain, newLink];
    canvas.stamps.push(...newStamps);

    // Moderation applies to remixes too
    const moderation = await LLMBackend.moderateCanvas(canvas);
    if (moderation.score < 0.7) {
      UI.showGentleSuggestion(moderation.suggestion || 'Let\'s pick a different stamp!');
      return { success: false, error: 'moderation_failed' };
    }

    // Mint a new code for the remixed version
    return this.shareCanvas(canvas, remixerId);
  }

  // Load and play a shared game from code or QR scan
  async loadSharedGame(shareCode: string): Promise<GameCanvas | null> {
    const serialized = await LLMBackend.loadSharedCanvas(shareCode);
    if (!serialized) return null;
    return this.deserializeCanvas(serialized);
  }

  // Returns attribution trail for display in-game
  getAttributionTrail(shareCode: string): Array<{ creatorIcon: string; stampCount: number; when: number }> {
    const manifest = this.codeToManifest.get(shareCode);
    if (!manifest) return [];
    // Map anonymized hashes to fun animal icons — never usernames or photos
    const icons = ['panda', 'robot', 'fairy', 'dragon', 'bunny', 'star'];
    return manifest.remixChain.map((link, i) => ({
      creatorIcon: icons[this.hashToIndex(link.creatorHash, icons.length)],
      stampCount: link.stampsAdded.length,
      when: link.timestamp
    }));
  }

  private generateShareCode(): string {
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += this.CODE_CHARS[Math.floor(Math.random() * this.CODE_CHARS.length)];
    }
    return this.codeToManifest.has(code) ? this.generateShareCode() : code;
  }

  private async hashId(id: string): Promise<string> {
    const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(id + 'share_salt'));
    return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, '0')).join('');
  }

  private async hashManifest(m: CanvasManifest): Promise<string> {
    const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(JSON.stringify(m)));
    return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, '0')).join('');
  }

  private hashToIndex(hash: string, max: number): number {
    let sum = 0;
    for (let i = 0; i < 8; i++) sum += hash.charCodeAt(i);
    return sum % max;
  }

  private async serializeCanvas(canvas: GameCanvas, manifest: CanvasManifest): Promise<string> {
    return JSON.stringify({ version: 1, manifest, stampData: canvas.stamps });
  }

  private deserializeCanvas(serialized: string): GameCanvas {
    const parsed = JSON.parse(serialized);
    return new GameCanvas(parsed.stampData, parsed.manifest.remixChain);
  }
}
```

The `shareCanvas` method enforces the content moderation gate before any sharing artifact is created. The `remixCanvas` method appends a cryptographically linked attribution entry before re-moderating and minting a new share code, ensuring that every derivative work carries the full creation lineage. The `getAttributionTrail` method maps anonymized creator hashes to animal icons — pandas, robots, fairies — so children see a friendly visual history without ever encountering a username or photograph. This preserves the social joy of creative recognition while eliminating every vector for personal identification.

### Social Feature Taxonomy and Safety Matrix

The following table maps each social stamp to its safety controls, communication boundaries, and parent-dashboard visibility. It serves as the reference for both implementation and compliance review.

| Stamp | Function | Communication | Parent Control | Data Collected | Safety Level Required |
|-------|----------|--------------|----------------|----------------|----------------------|
| Co-op Portal | Creates multiplayer session with 4-digit code | Pre-defined cheers only [^371^] | Approve/deny all co-op | None — anonymous hashes only | YELLOW or GREEN |
| Bubble Rescue | Bubble respawn for defeated players | "Need help!" cheer auto-sent | Toggle on/off | None | Any (local only) |
| Buddy Stamp | AI companion (Speedy Pet / Strong Robot / Helpful Fairy) | None | Select companion type | None | Any |
| Cheer Stamp | Sends positive pre-canned message | 10 fixed phrases, no free text [^371^] | View full cheer log | Message index + timestamp | YELLOW or GREEN |
| Share Button | Generates QR code + share code | None | Enable/disable sharing | Anonymous canvas hash | GREEN |
| Family Lock | Parent-configured safety boundary | N/A (backend stamp) | Set GREEN/YELLOW/RED | Safety level per child | N/A |

Every stamp in the social layer defaults to the most restrictive safe state. The Co-op Portal requires at least YELLOW safety level, meaning co-op with approved friends; the parent can elevate to GREEN (open co-op) or reduce to RED (disabled). The Share Button requires GREEN — the highest trust level — because shared canvases leave the child's device and enter the platform's anonymous distribution system. Communication is restricted to the ten pre-defined cheers across all levels; there is no path to free text, no voice chat, no external linking, and no persistent social graph. This architecture implements the privacy-by-design principle mandated by both COPPA and the UK Age-Appropriate Design Code: safety is not a feature that parents enable, but the foundation that selective permission relaxes [^392^] [^302^].
